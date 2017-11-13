unit uWifiScanner;
//This delphi source code was downloaded from www.delphibasics.info
//Author: RRUZ & Arhitect
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, ExtCtrls, ComCtrls,  nduWlanAPI,
  nduWlanTypes, TypInfo;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    hClient              : THandle;
    { Private declarations }
    procedure WlanOpen();
    procedure WlanClose();
    procedure WlanScan();
    procedure RegisterNotification;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


const
  WLAN_NOTIFICATION_SOURCE_NONE = 0;
  WLAN_NOTIFICATION_SOURCE_ONEX = 4;
  WLAN_NOTIFICATION_SOURCE_ACM = 8;
  WLAN_NOTIFICATION_SOURCE_MSM = $10;
  WLAN_NOTIFICATION_SOURCE_SECURITY = $20;
  WLAN_NOTIFICATION_SOURCE_IHV = $40;
  WLAN_NOTIFICATION_SOURCE_HNWK = $80;
  WLAN_NOTIFICATION_SOURCE_ALL = $FFFF;


function NotificationSource_To_String(NotificationSource: DWORD ): string;
begin
  Result:='';
  case NotificationSource of
    WLAN_NOTIFICATION_SOURCE_NONE : Result:= 'WLAN_NOTIFICATION_SOURCE_NONE';
    WLAN_NOTIFICATION_SOURCE_ONEX : Result:= 'WLAN_NOTIFICATION_SOURCE_ONEX';
    WLAN_NOTIFICATION_SOURCE_ACM : Result:= 'WLAN_NOTIFICATION_SOURCE_ACM';
    WLAN_NOTIFICATION_SOURCE_MSM : Result:= 'WLAN_NOTIFICATION_SOURCE_MSM';
    WLAN_NOTIFICATION_SOURCE_SECURITY : Result:= 'WLAN_NOTIFICATION_SOURCE_SECURITY';
    WLAN_NOTIFICATION_SOURCE_IHV : Result:= 'WLAN_NOTIFICATION_SOURCE_IHV';
    WLAN_NOTIFICATION_SOURCE_HNWK : Result:= 'WLAN_NOTIFICATION_SOURCE_HNWK';
    WLAN_NOTIFICATION_SOURCE_ALL : Result:= 'WLAN_NOTIFICATION_SOURCE_ALL';
  else
    Result := 'NotificationSource???';
  end;
end;

//NotificationCode,wlanData^.NotificationSource)
function NotificationCode_To_String(NotificationCode: DWORD; NotificationSource: DWord ): string;
begin
  Result:='';
  case NotificationSource of
    WLAN_NOTIFICATION_SOURCE_NONE : Result:= 'WLAN_NOTIFICATION_SOURCE_NONE';
    WLAN_NOTIFICATION_SOURCE_ONEX : Result:= 'WLAN_NOTIFICATION_SOURCE_ONEX';
    WLAN_NOTIFICATION_SOURCE_ACM : Result:=  TypInfo.GetEnumName(System.TypeInfo(WLAN_NOTIFICATION_ACM),integer(NotificationCode));
    WLAN_NOTIFICATION_SOURCE_MSM : Result:= TypInfo.GetEnumName(System.TypeInfo(WLAN_NOTIFICATION_MSM),integer(NotificationCode));
    WLAN_NOTIFICATION_SOURCE_SECURITY : Result:= 'WLAN_NOTIFICATION_SOURCE_SECURITY';
    WLAN_NOTIFICATION_SOURCE_IHV : Result:= 'WLAN_NOTIFICATION_SOURCE_IHV';
    WLAN_NOTIFICATION_SOURCE_HNWK : Result:= 'WLAN_NOTIFICATION_SOURCE_HNWK';
    WLAN_NOTIFICATION_SOURCE_ALL : Result:= 'WLAN_NOTIFICATION_SOURCE_ALL';
  else
    Result := 'NotificationSource???='+inttostr(NotificationSource);
  end;
end;

function DOT11_AUTH_ALGORITHM_To_String( Dummy :Tndu_DOT11_AUTH_ALGORITHM):String;
begin
    Result:='';
    case Dummy of
        DOT11_AUTH_ALGO_80211_OPEN          : Result:= '80211_OPEN';
        DOT11_AUTH_ALGO_80211_SHARED_KEY    : Result:= '80211_SHARED_KEY';
        DOT11_AUTH_ALGO_WPA                 : Result:= 'WPA';
        DOT11_AUTH_ALGO_WPA_PSK             : Result:= 'WPA_PSK';
        DOT11_AUTH_ALGO_WPA_NONE            : Result:= 'WPA_NONE';
        DOT11_AUTH_ALGO_RSNA                : Result:= 'RSNA';
        DOT11_AUTH_ALGO_RSNA_PSK            : Result:= 'RSNA_PSK';
        DOT11_AUTH_ALGO_IHV_START           : Result:= 'IHV_START';
        DOT11_AUTH_ALGO_IHV_END             : Result:= 'IHV_END';
    end;
end;

function DOT11_CIPHER_ALGORITHM_To_String( Dummy :Tndu_DOT11_CIPHER_ALGORITHM):String;
begin
    Result:='';
    case Dummy of
  	DOT11_CIPHER_ALGO_NONE      : Result:= 'NONE';
    DOT11_CIPHER_ALGO_WEP40     : Result:= 'WEP40';
    DOT11_CIPHER_ALGO_TKIP      : Result:= 'TKIP';
    DOT11_CIPHER_ALGO_CCMP      : Result:= 'CCMP';
    DOT11_CIPHER_ALGO_WEP104    : Result:= 'WEP104';
    DOT11_CIPHER_ALGO_WPA_USE_GROUP : Result:= 'WPA_USE_GROUP OR RSN_USE_GROUP';
    //DOT11_CIPHER_ALGO_RSN_USE_GROUP : Result:= 'RSN_USE_GROUP';
    DOT11_CIPHER_ALGO_WEP           : Result:= 'WEP';
    DOT11_CIPHER_ALGO_IHV_START     : Result:= 'IHV_START';
    DOT11_CIPHER_ALGO_IHV_END       : Result:= 'IHV_END';
    end;
end;

procedure TFORM1.WlanScan();
const
  WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES =$00000001;
var
  ResultInt            : DWORD;
  pInterface           : Pndu_WLAN_INTERFACE_INFO_LIST;
  i                    : Integer;
  j                    : Integer;
  pAvailableNetworkList: Pndu_WLAN_AVAILABLE_NETWORK_LIST;
  pInterfaceGuid       : PGUID;
  SDummy               : string;
  l:tlistItem;
begin
  //

  ResultInt:=WlanEnumInterfaces(hClient, nil, @pInterface);
  if  ResultInt<> ERROR_SUCCESS then
  begin
     WriteLn('Error Enum Interfaces '+IntToStr(ResultInt));
     exit;
  end;

  COMBOBOX1.Clear;
  listview1.Clear;

  for i := 0 to pInterface^.dwNumberOfItems - 1 do
  begin
   COMBOBOX1.Items.Add('Interface       ' + pInterface^.InterfaceInfo[i].strInterfaceDescription);
   edit1.Text:=('GUID            ' + GUIDToString(pInterface^.InterfaceInfo[i].InterfaceGuid));

   pInterfaceGuid:= @pInterface^.InterfaceInfo[pInterface^.dwIndex].InterfaceGuid;

      ResultInt:=WlanGetAvailableNetworkList(hClient,pInterfaceGuid,WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES,nil,pAvailableNetworkList);
      if  ResultInt<> ERROR_SUCCESS then
      begin
         WriteLn('Error WlanGetAvailableNetworkList '+IntToStr(ResultInt));
         Exit;
      end;

        for j := 0 to pAvailableNetworkList^.dwNumberOfItems - 1 do
        Begin
          l:=listview1.Items.Add;

           SDummy:=PAnsiChar(@pAvailableNetworkList^.Network[j].dot11Ssid.ucSSID);
           l.Caption:=(SDummy);
           l.SubItems.Add(Format('%d ',[pAvailableNetworkList^.Network[j].wlanSignalQuality])+'%');
           //SDummy := GetEnumName(TypeInfo(Tndu_DOT11_AUTH_ALGORITHM),integer(pAvailableNetworkList^.Network[j].dot11DefaultAuthAlgorithm)) ;
           SDummy:=DOT11_AUTH_ALGORITHM_To_String(pAvailableNetworkList^.Network[j].dot11DefaultAuthAlgorithm);
           l.SubItems.Add(SDummy);
           SDummy:=DOT11_CIPHER_ALGORITHM_To_String(pAvailableNetworkList^.Network[j].dot11DefaultCipherAlgorithm);
           l.SubItems.Add(SDummy);

        End;

      WlanFreeMemory(pAvailableNetworkList);
  end;



end;
procedure TForm1.WlanClose;
begin
   WlanCloseHandle(hClient, nil);
end;

procedure TForm1.WlanOpen;
var
  ResultInt            : DWORD;
  dwVersion            : DWORD;
begin
  ResultInt:=WlanOpenHandle(1, nil, @dwVersion, @hClient);
  if  ResultInt<> ERROR_SUCCESS then
  begin
    hClient := 0;
     WriteLn('Error Open CLient'+IntToStr(ResultInt));
     Exit;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  WlanOpen();
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  WlanScan();
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  RegisterNotification();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  hClient := 0;
  WlanOpen();
  WlanScan();
end;


procedure NotificationCallback(wlanData:Pndu_WLAN_NOTIFICATION_DATA; context: pointer); stdcall;
begin
   AllocConsole;
   Writeln('NotificationSource=',NotificationSource_To_String(wlanData^.NotificationSource));
   Writeln('NotificationCode=',  NotificationCode_To_String(wlanData^.NotificationCode,wlanData^.NotificationSource) );
   Writeln('InterfaceGuid=', GUIDToString( wlanData^.InterfaceGuid));
   Writeln('dwDataSize=',wlanData^.dwDataSize);

   if wlanData^.NotificationCode = Integer(wlan_notification_msm_signal_quality_change) then
   begin
     Writeln('signal_quality_change: ', pcardinal(wlanData^.pData)^);
   end;
   

   Writeln('');
end;

procedure TForm1.RegisterNotification;
begin
  WlanRegisterNotification( hClient, NDU_WLAN_NOTIFICATION_SOURCE_ALL, False,
   @NotificationCallback,nil,nil,0);
end;

end.

