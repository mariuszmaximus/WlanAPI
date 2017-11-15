unit WlanAPIutils;

interface

uses
  nduCType, nduL2cmn, nduWlanTypes, nduWinDot11, nduWinNT, Windows, nduEapTypes,
  nduWlanAPI, TypInfo, SysUtils;

function NotificationSource_To_String(NotificationSource: DWORD ): string;
function NotificationCode_To_String(NotificationCode: DWORD; NotificationSource: DWord ): string;
function DOT11_AUTH_ALGORITHM_To_String( Dummy :Tndu_DOT11_AUTH_ALGORITHM):String;
function DOT11_CIPHER_ALGORITHM_To_String( Dummy :Tndu_DOT11_CIPHER_ALGORITHM):String;



const
  WLAN_NOTIFICATION_SOURCE_NONE = 0;
  WLAN_NOTIFICATION_SOURCE_ONEX = 4;
  WLAN_NOTIFICATION_SOURCE_ACM = 8;
  WLAN_NOTIFICATION_SOURCE_MSM = $10;
  WLAN_NOTIFICATION_SOURCE_SECURITY = $20;
  WLAN_NOTIFICATION_SOURCE_IHV = $40;
  WLAN_NOTIFICATION_SOURCE_HNWK = $80;
  WLAN_NOTIFICATION_SOURCE_ALL = $FFFF;

implementation




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




end.
