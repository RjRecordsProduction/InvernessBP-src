local logic_chat_voice_const = {
  Enum_RoomUpdateType = {
    MemberJoin = 1,
    MemberQuit = 2,
    MemberStateChange = 3
  },
  Enum_MemberStateBitDefine = {
    SpeakerBit = 1,
    MicBit = 2,
    TempLeaveBit = 3
  },
  Enum_AntsVoiceRoomType = {
    Temp = 0,
    LobbyTeam = 1,
    BattleTeam = 2,
    BattleLBS = 3,
    LobbyChatRoom = 4,
    LobbyMatchRoom = 5
  },
  Enum_AntsVoiceOperationStatus = {
    Available = 1,
    InProgress = 2,
    InQueue = 3,
    Delay = 4
  },
  Enum_AntsVoiceOnlineStatus = {RealTime = 0, OffLine = 1},
  Enum_AntsVoiceProcedure = {
    Init = "init",
    UnInit = "uninit",
    Join = "join"
  },
  Const_MinRecordTime = 1000,
  Const_MaxRecordTime = 10,
  Const_MaxErrorTimes = 2,
  Const_MaxResendTimes = 2,
  Const_MaxTickRetryTimes = 4,
  Const_ProcedureResendTime = 2,
  Const_MaxReportTextLength = 1536,
  Enum_OperationErrorCode = {
    Succ = 0,
    NeedInit = 4105,
    ChangeModeError = 4102,
    ParamInvalid = 4103,
    RealtimeStateErr = 8193,
    JoinErr = 8194,
    QuitRoomNameErr = 8195,
    CreateRoomErr = 8197,
    QuitRoomErr = 8199,
    AlreadyInRoomError = 8200,
    AndroidTesterPermissionError = 200,
    IosTesterPermissionError = 201,
    AntsVoiceServiceError = 12292,
    UploadError = 12293,
    HttpBusy = 12294,
    DownloadError = 12295,
    ToTextProcessingError = 28673
  },
  Enum_RoomCode = {
    JoinSuccess = 8193,
    Timeout = 8194,
    ServerError = 8195,
    QuitRoomSuccess = 8198
  },
  Enum_InGameMicMode = {
    OFF = 0,
    ALL = 1,
    Team = 2,
    PreTeam = 3,
    OpenMic = 256,
    PTT = 512,
    OpenMic_ALL = 257,
    OpenMic_Team = 258,
    OpenMic_PreTeam = 259,
    PTT_ALL = 513,
    PTT_Team = 514,
    PTT_PreTeam = 515,
    GetChannelMode = function(MicMode)
      return MicMode & 255
    end,
    GetMicType = function(MicMode)
      return MicMode & 65280
    end
  },
  HDmpveVoiceCompleteCode = {
    JoinRoomSucc = 8193,
    JoinRoomTimeout = 8194,
    JoinRoomSVRErr = 8195,
    JoinRoomUnknown = 8196,
    JoinRoomRetryFail = 8197,
    QuitRoomSucc = 8198,
    RoomOffline = 8199,
    RoleSucc = 8200,
    RoleTimeout = 8201,
    RoleMaxAnchor = 8208,
    RoleNoChange = 8209,
    RoleSvrErr = 8210,
    GV_ON_MESSAGE_KEY_APPLIED_SUCC = 12289,
    GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT = 12290,
    GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR = 12291,
    GV_ON_REPORT_SUCC = 24577,
    GV_ON_DATA_ERROR = 24578,
    GV_ON_PUNISHED = 24579,
    GV_ON_NOT_PUNISHED = 24580,
    GV_ON_KEY_DELECTED = 24581,
    GV_ON_REPORT_SUCC_SELF = 24582,
    GV_ON_ST_SUCC = 40961,
    GV_ON_ST_HTTP_ERROR = 40962,
    GV_ON_ST_SERVER_ERROR = 40963,
    GV_ON_ST_INVALID_JSON = 40964,
    GV_ON_ST_ALREADY_EXIST = 40965,
    GV_ON_ST_RC_FAILED = 40966,
    GV_ON_UPLOAD_RECORD_DONE = 12293,
    GV_ON_UPLOAD_RECORD_ERROR = 12294,
    GV_ON_DOWNLOAD_RECORD_DONE = 12295,
    GV_ON_DOWNLOAD_RECORD_ERROR = 12296,
    GV_ON_DOWNLOAD_FILEID_NOT_EXIST = 12304,
    SpeechToTextTimeout = 16386,
    SpeechToTextServerError = 16387
  },
  HDmpveVoiceErrno = {HDMPVE_VOICE_PERMISSION_MIC_ERR = 12291, HDMPVE_VOICE_INTERNAL_TVE_ERR = 20481},
  Enum_HDmpveVoiceMicState = {
    GV_MIC_STATE_CLOSED = -1,
    GV_MIC_STATE_OPEN_FAILED = 0,
    GV_MIC_STATE_OPENED = 1,
    GV_MIC_STATE_OCCUPIED = 2
  },
  Enum_HDmpveVoiceSpeakerState = {
    GV_SPEAKER_STATE = -1,
    GV_SPEAKER_STATE_OPEN_FAILED = 0,
    GV_SPEAKER_STATE_OPENED = 1,
    GV_SPEAKER_STATE_OCCUPIED = 2
  },
  Enum_HDmpveVoiceEvent = {
    GV_EVENT_NO_DEVICE_CONNECTED = 0,
    GV_EVENT_HEADSET_DISCONNECTED = 10,
    GV_EVENT_HEADSET_CONNECTED = 11,
    GV_EVENT_BLUETOOTH_HEADSET_DISCONNECTED = 20,
    GV_EVENT_BLUETOOTH_HEADSET_CONNECTED = 21,
    GV_EVENT_MIC_STATE_OPEN_SUCC = 30,
    GV_EVENT_MIC_STATE_OPEN_ERR = 31,
    GV_EVENT_MIC_STATE_NO_OPEN = 32,
    GV_EVENT_MIC_STATE_OCCUPANCY = 33,
    GV_EVENT_SPEAKER_STATE_OPEN_SUCC = 40,
    GV_EVENT_SPEAKER_STATE_OPEN_ERR = 41,
    GV_EVENT_SPEAKER_STATE_NO_OPEN = 42,
    GV_EVENT_AUDIO_INTERRUPT_BEGIN = 50,
    GV_EVENT_AUDIO_INTERRUPT_END = 51,
    GV_EVENT_AUDIO_RECORDER_EXCEPTION = 52,
    GV_EVENT_AUDIO_RENDER_EXCEPTION = 53,
    GV_EVENT_PHONE_CALL_PICK_UP = 54,
    GV_EVENT_PHONE_CALL_HANG_UP = 55
  },
  Enum_InvokeCmd = {
    GV_SET_OFF_LINE_VOICE_REVIEW_MODE = 11,
    GV_ENABLE_MEDIA_CHANNEL_OUTPUT = 6200,
    GV_ENABLE_WWISE_PLUGIN = 8618,
    GV_SET_CALLBACK_DATA = 9606,
    GV_REPORT_WITHOUT_TEAMMATE = 9800,
    GV_SET_TSS_APP_ID = 9017,
    GV_SET_ENABLE_ENCRYPT = 9200,
    GV_OPEN_DOUBLE_MIC = 10003,
    GV_SET_ANDROID_CALL_MODE = 6550,
    GV_VOICE_CHANGE_PITCH_LOW = 6123,
    GV_VOICE_CHANGE_SPEED = 6124,
    GV_VOICE_CHANGE_SPEED_AND_PITCH = 6125,
    GV_VOICE_FIX_IOS26_BLUETOOTH = 9501,
    GV_DIRECTIONAL_CAPTURE = 10003
  },
  Enum_VoiceRoomStatus = {
    RoomStatus_None = 0,
    RoomStatus_Create = 1,
    RoomStatus_Joining = 2,
    RoomStatus_JoiningWithErr = 3,
    RoomStatus_Joined = 4,
    RoomStatus_Quiting = 5,
    RoomStatus_Quited = 6,
    RoomStatus_OffLine = 7
  },
  Enum_KwsViolationType = {
    NO_MALICIOUS = 100,
    POLITICAL = 101,
    PORN = 102,
    ADVERTISE = 106,
    ABUSE = 111
  },
  SpeechTranslateType = {
    SPEECH_TRANSLATE_STST = 0,
    SPEECH_TRANSLATE_STTT = 1,
    SPEECH_TRANSLATE_STTS = 2
  },
  ReenterRoomMaxCount = 100,
  ReenterDuration = 60,
  Enum_Error_Voice_Room = {
    err_voice_room_not_allow_join = 16030001,
    err_voice_room_member_full = 16030002,
    err_voice_room_db_err = 16030003,
    err_voice_room_param_err = 16030004,
    err_voice_room_not_in = 16030005
  },
  Enum_AntsVoiceReportType = {TextReport = 0, VoiceReport = 1},
  Enum_iOSAudioFeature = {
    Playback = 0,
    Record = 1,
    DoNotMixWithOthers = 2,
    VoiceChat = 3,
    UseReceiver = 4,
    DisableBluetoothSpeaker = 5,
    BluetoothMicrophone = 6,
    BackgroundAudio = 7,
    NumFeatures = 8
  },
  Enum_AntsVoiceRoomOpera = {Join = "Join", Quit = "Quit"},
  Enum_AntsVoiceRoomOperaStatus = {
    Idle = "Idle",
    Doing = "Doing",
    CallErr = "CallErr",
    CompleteErr = "CompleteErr",
    Finish = "Finish"
  },
  RoomOperTimeout = {
    JoinCallErr = 20.5,
    QuitDoing = 5,
    QuitCallErr = 20.5,
    Default = 20.5
  },
  RoomOperRetryMAXCount = {
    Jion = 0,
    Quit = 1,
    Default = 0
  },
  AntsVoiceLocalRecordFileName = {
    LocalRecord = "upload.voice",
    Downloaded = "down.voice"
  },
  NO_TEAM_ROOM_ROOM_NAME = "no_teamroom",
  NO_LBS_ROOM_ROOM_NAME = "no_lbsroom",
  SocialCard = "SocialCard",
  ClientCallbackParamSep = "||",
  EUGDPRVoiceVerifyStatus = {
    None = -2,
    NotSend = 0,
    NotVerified = 3,
    NotAgree = -1,
    VerifiedAndAgree = 1
  },
  Enum_ASRSceneID = {
    None = 0,
    TeammateTakeOver = 100001,
    Penguin = 100002,
    Treant = 100003,
    Centaur = 100004,
    Instructor = 100005,
    WoWCopilot = 200000
  },
  LangToLangID = {
    zh = 0,
    en = 1,
    ja = 2,
    ko = 3,
    de = 4,
    fr = 5,
    es = 6,
    tr = 8,
    ru = 9,
    pt = 10,
    vi = 11,
    id = 12,
    ms = 13,
    th = 14,
    ["zh-TW"] = 15,
    ["zh-HK"] = 15,
    ["zh-HK,zh-TW"] = 15,
    ar = 19,
    fil = 33,
    hi = 40
  },
  UploadFileSence = {SST = "f=stt"}
}
return logic_chat_voice_const