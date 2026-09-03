local SDKMacros = {
  SDKCallBackType = {
    SDK_CB_None = 0,
    SDK_CB_VLINK_OPEN = 1,
    SDK_CB_VLINK_CLOSE = 2,
    SDK_CB_NET_TRACE = 3
  },
  TraceTrigger = {Server = 1, NetworkBroken = 2},
  IMSDKShareType = {
    IMSDKShareTextSilence = 0,
    IMSDKShareTextDialog = 1,
    IMSDKShareLinkSilence = 2,
    IMSDKShareLinkDialog = 3,
    IMSDKShareImageSilence = 4,
    IMSDKShareImageDialog = 5
  },
  IMSDKErrorCode = {
    UNKNOWN = 0,
    SUCCESS = 1,
    CANCEL = 2,
    SYSTEM_ERROR = 3,
    NETWORK_ERROR = 4,
    SERVER_ERROR = 5,
    TIMEOUT = 6,
    NOT_SUPPORT = 7,
    FILE_SYSTEM_ERROR = 8,
    NEED_PLUGIN = 9,
    NEED_LOGIN = 10,
    INVALID_ARGUMENT = 11,
    NEED_SYSTEM_PERMISSION = 12,
    NEED_CONFIG = 13,
    SERVICE_REFUSE = 14,
    NEED_INSTALL_APP = 15,
    APP_NEED_UPGRADE = 16,
    INITIALIZE_FAILED = 17,
    EMPTY_CHANNEL = 18,
    FUNCTION_DISABLE = 19,
    API_DEPRECATED = 999,
    LOGIN_UNKNOWN_ERROR = 1000,
    LOGIN_NO_CACHED_DATA = 1001,
    LOGIN_TOKEN_EXPIRED = 1002,
    LOGIN_NEED_GUID = 1003,
    LOGIN_KEY_STORE_VERIFY_ERROR = 1004,
    LOGIN_NEED_USER_DATA = 1005,
    LOGIN_UNKOWN_ERROR = 1100,
    BIND_CMD_NEED_PROCESS_BY_SVR = 1501,
    THIRD_LOGIN_FAILED = 9999,
    USER_CANCEL_AUTH = 106,
    USER_CANCEL_AUTH2 = 107,
    USER_CANCEL_AUTH3 = 109,
    AUTO_AUTH_FAIL = 200,
    THIRD_PARTY_ERROR = 211,
    PROTECTION_TRIGGER = 611,
    GC_NOT_LOGGED_IN = 701
  },
  IMSDKQRCodeStatus = {
    CREATED = 1,
    SCANED = 2,
    LOGINED = 3,
    FINISHED = 4,
    EXPIRED = 5,
    INVALID = 6
  },
  IMSDKQRCodeServerErrorCode = {
    PARAMETER_ERROR = 1004,
    IP_BANED = 2190,
    RATE_LIMITED = 12000,
    EXPIRED = 11500,
    DB_ERROR = 11501,
    CONFIG_ERROR = 11502,
    INVALID = 11503,
    CREATE_MAX_LIMITED = 11505,
    NOT_CREATED_STATUS = 11506,
    PARAMETER_INVALID = 11507,
    STATUS_SAME = 11508,
    STATUS_ROLLBACK = 11509,
    CREATE_RATE_LIMITED = 11510,
    STATUS_UPDATE_INVALID_FLOW = 11511,
    FORMAT_INVALID = 11512
  },
  IMSDKWebviewAction = {
    Open = "1",
    Close = "2",
    JSCallNative = "3",
    EnterFullScreen = "5",
    ExitFullScreen = "6",
    OpenFailed = "30"
  },
  IMSDKUnifiedAccountSubType = {
    None = 0,
    Email = 1,
    Phone = 2
  },
  IMSDKRequestVerifyCodeType = {
    Register = 1,
    RegisterAndLogin = 2,
    Modify = 3
  },
  IMSDKVerifyCodeSendType = {SMS = 0, WhatsApp = 1},
  LoginThirdCode = {IP_BLACKLIST = 2146},
  IMSDKServerErrorCode = {
    SUCCESS = 1,
    CHANNEL_OPENID_BANED = -134,
    INVALID_FB_APP = -217,
    BIND_OPENID_ALREADY_EXIST = -307,
    VALIDKEY_INVALID = -905
  },
  FirebaseMacro = {
    ConsentType = {
      AD_STORAGE = 0,
      ANALYTICS_STORAGE = 1,
      AD_USER_DATA = 2,
      AD_PERSONALIZATION = 3
    },
    ConsentValue = {DENIED = 0, GRANTED = 1}
  },
  PixVideo = {
    PlayerEventId = {
      None = -1,
      Loading = 0,
      Start = 1,
      Error = 2,
      Resolution = 3,
      Progress = 4,
      End = 5,
      Seek = 6,
      SeekEnd = 7,
      Closed = 8,
      GetData = 9,
      AppStatusChanged = 10
    },
    PlayerAppStatus = {ToForground = 0, ToBackground = 1}
  }
}
return SDKMacros