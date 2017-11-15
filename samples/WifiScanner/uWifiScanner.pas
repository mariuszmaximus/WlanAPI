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
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    hClient              : THandle;
    pInterfaceGuid       : PGUID;

    { Private declarations }
    procedure WlanOpen();
    procedure WlanClose();
    procedure WlanList();
    procedure RegisterNotification;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


uses WlanAPIutils;


procedure TFORM1.WlanList();
const
  WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES =$00000001;
var
  ResultInt            : DWORD;
  pInterface           : Pndu_WLAN_INTERFACE_INFO_LIST;
  i                    : Integer;
  j                    : Integer;
  pAvailableNetworkList: Pndu_WLAN_AVAILABLE_NETWORK_LIST;
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
   COMBOBOX1.ItemIndex := COMBOBOX1.Items.Count-1;
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
  WlanList();
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  RegisterNotification();
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  WlanScan(hClient,pInterfaceGuid,nil,nil,nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  hClient := 0;
  WlanOpen();
  WlanList();
  RegisterNotification();
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

   if wlanData^.NotificationCode = Integer(wlan_notification_msm_connected) then
   begin
     Writeln('wlan_notification_msm_connected: ', 'wlanConnectionMode=',
      TypInfo.GetEnumName(System.TypeInfo(WLAN_CONNECTION_MODE),integer(PWLAN_MSM_NOTIFICATION_DATA(wlanData^.pData)^.wlanConnectionMode)));
     Writeln('wlan_notification_msm_connected: ', 'strProfileName=',PWLAN_MSM_NOTIFICATION_DATA(wlanData^.pData)^.strProfileName);

     Writeln('wlan_notification_msm_connected: ', 'strProfileName=',PWLAN_MSM_NOTIFICATION_DATA(wlanData^.pData)^.strProfileName);


   end;




   Writeln('');
end;

procedure TForm1.RegisterNotification;
begin
  //WlanRegisterNotification( hClient, NDU_WLAN_NOTIFICATION_SOURCE_ALL, False, @NotificationCallback,nil,nil,0);
  WlanRegisterNotification( hClient, WLAN_NOTIFICATION_SOURCE_ACM, False, @NotificationCallback,nil,nil,0);

  WlanScan(hClient,pInterfaceGuid,nil,nil,nil);

end;


end.

