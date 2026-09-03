local HostedProtoConfig = {}
HostedProtoConfig.Const = {DefaultCD = 0.5}
HostedProtoConfig.Proto = {
  PandoraReady = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "PandoraReady",
    AllowHighFreq = true
  },
  PandoraEnd = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "PandoraEnd"
  },
  PandoraPakReady = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "PandoraPakReady",
    AllowHighFreq = true
  },
  JumpUrl = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "JumpUrl"
  },
  JumpScene = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "JumpScene"
  },
  PicShare = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "PicShare"
  },
  HandleTips = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "HandleTips"
  },
  HandleLoading = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "HandleLoading",
    AllowHighFreq = true
  },
  UpdateRedPoint = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "UpdateRedPoint",
    AllowHighFreq = true
  },
  RefreshCoin = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "RefreshCoin"
  },
  ReLogin = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "ReLogin"
  },
  PanelOpen = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "PanelOpen",
    AllowHighFreq = true
  },
  BackLobby = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "BackLobby"
  },
  ShowNoticePanel = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "ShowNoticePanel"
  },
  QueryCoin = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "QueryCoinRet"
  },
  QueryItem = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "QueryItemRet",
    needTime = true
  },
  PanelClose = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "OnPanelClose",
    AllowHighFreq = true
  },
  ShowItemTip = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ShowItemTip"
  },
  CloseItemTip = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "CloseItemTip",
    AllowHighFreq = true
  },
  ShowCongratulation = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ShowItemGetPanel"
  },
  GameViewOpen = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "GameViewOpen"
  },
  GetIsResDownloaded = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetIsResDownloaded"
  },
  GetFriendListCount = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedFriendProtocol",
    func = "GetFriendListCount"
  },
  GetFriendList = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedFriendProtocol",
    func = "GetFriendList",
    AllowHighFreq = true,
    needTime = true
  },
  SearchFriend = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedFriendProtocol",
    func = "SearchFriend"
  },
  AddFriend = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "AddFriend"
  },
  ShowPackagePreviewPanel = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "ShowPackagePreviewPanel"
  },
  GetItemNum = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetItemNum",
    needTime = true
  },
  ScreenShot = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ScreenShot"
  },
  GetDeviceLevel = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetDeviceLevel",
    Static = true
  },
  OpenBarrage = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "OpenBarrage"
  },
  CloseBarrage = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "CloseBarrage",
    AllowHighFreq = true
  },
  SendBarrage = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "SendBarrage"
  },
  ClearBarrage = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "ClearBarrage",
    AllowHighFreq = true
  },
  PlaySound = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "PlaySound",
    AllowHighFreq = true
  },
  StopLobbyBGM = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "StopLobbyBGM",
    AllowHighFreq = true
  },
  ResumeLobbyBGM = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ResumeLobbyBGM",
    AllowHighFreq = true
  },
  PlayVideo = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "PlayVideo"
  },
  StopVideo = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "StopVideo",
    AllowHighFreq = true
  },
  GetUserData = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetUserData"
  },
  GetCurrency = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetCurrency"
  },
  MoveBanner = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "MoveBanner"
  },
  CloseWardrobe = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "CloseWardrobe",
    AllowHighFreq = true
  },
  OpenChatByUID = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "OpenChatByUID"
  },
  ShareMore = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "ShareMore"
  },
  GetFriendsByRegion = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedFriendProtocol",
    func = "GetFriendsByRegion",
    needTime = true
  },
  GetDateFormat = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetDateFormat"
  },
  GetHeadCfg = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetHeadCfg",
    Static = true
  },
  ShowPreview = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ShowPreview"
  },
  GetTeamCapture = {
    logic = "client.slua.logic.HostedProtoBridge.ImplProtocol.HostedTeamProtocol",
    func = "GetTeamCapture"
  },
  CopyToClipBoard = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "CopyToClipBoard"
  },
  GetIntimacyList = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetIntimacyList"
  },
  ShowExchange = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ShowExchange"
  },
  GetItemIcon = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "GetItemIcon",
    needTime = true
  },
  SentMsgToFriend = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "SentMsgToFriend"
  },
  GetQRcodeState = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetQRcodeState"
  },
  QueryPet = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "QueryPet"
  },
  QueryWarZone = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "QueryWarZone",
    CD = 1
  },
  QueryElement = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "QueryElement"
  },
  ModifyElement = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "ModifyElement"
  },
  RedPacketRemainingTime = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "RedPacketRemainingTime"
  },
  QueryAct = {
    modulePath = "CommonModuleConfig",
    moduleName = "pandora_common_protocol",
    func = "QueryAct"
  },
  GetActConfig = {
    logic = "client.slua.logic.sa.PandoraOneclickRewardComp",
    func = "handle_GetActConfig",
    AllowHighFreq = true,
    toSelf = true
  },
  GiftStatus = {
    logic = "client.slua.logic.sa.PandoraOneclickRewardComp",
    func = "handle_GiftStatus",
    AllowHighFreq = true,
    toSelf = true
  },
  StartGetGift = {
    logic = "client.slua.logic.sa.PandoraOneclickRewardComp",
    func = "handle_StartGetGift",
    AllowHighFreq = true,
    toSelf = true
  },
  GetGiftRes = {
    logic = "client.slua.logic.sa.PandoraOneclickRewardComp",
    func = "handle_GetGiftRes",
    AllowHighFreq = true,
    toSelf = true
  },
  pandoraShowEntrance = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "pandoraShowEntrance",
    AllowHighFreq = true
  },
  JumpWeb = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "JumpWeb",
    AllowHighFreq = true
  },
  CloseWeb = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "CloseWeb",
    AllowHighFreq = true
  },
  ChessBegin = {
    modulePath = "CommonModuleConfig",
    moduleName = "LogicLudo",
    func = "ChessBegin_Pandora"
  },
  ChessEnd = {
    modulePath = "CommonModuleConfig",
    moduleName = "LogicLudo",
    func = "ChessEnd_Pandora"
  },
  HomePanelClose = {
    modulePath = "CommonModuleConfig",
    moduleName = "LogicLudo",
    func = "PanelClose_Pandora"
  },
  VoiceSwitch = {
    modulePath = "CommonModuleConfig",
    moduleName = "LogicLudo",
    func = "VoiceSwitch_Pandora"
  },
  MicSwitch = {
    modulePath = "CommonModuleConfig",
    moduleName = "LogicLudo",
    func = "MicSwitch_Pandora"
  },
  ShareToChat = {
    modulePath = "CommonModuleConfig",
    moduleName = "LogicLudo",
    func = "ShareToChat_Pandora"
  },
  pandoraNotifyAppClose = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "pandoraNotifyAppClose",
    AllowHighFreq = true
  },
  pandoraOpenUrl = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "pandoraOpenUrl",
    AllowHighFreq = true
  },
  pandoraShowRedpoint = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "pandoraShowRedpoint",
    AllowHighFreq = true
  },
  pandoraGoPandora = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "pandoraGoPandora",
    AllowHighFreq = true
  },
  GetMargin = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetMargin",
    AllowHighFreq = true
  },
  openRewardResp = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "openRewardResp",
    AllowHighFreq = true
  },
  EagleReplay = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "EagleReplay"
  },
  SendWowUnReadMessage = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "OnWowUnReadMessageRsp"
  },
  QueryReadyStatus = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "QueryReadyStatus"
  },
  panameraGetLabelsData = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "panameraGetLabelsData"
  },
  QueryShowTeam = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "QueryShowTeam"
  },
  ModifyShowTeam = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ModifyShowTeam"
  },
  NationalEsportsInvite = {
    modulePath = "LobbyModuleConfig",
    moduleName = "logic_national_esports",
    func = "OnNationalEsportsInvite"
  },
  NationalEsportsSecurityCheck = {
    modulePath = "LobbyModuleConfig",
    moduleName = "logic_national_esports",
    func = "OnSecurityCheck"
  },
  MagicTreeStat = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "MagicTreeStat"
  },
  MagicTreePercent = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "MagicTreePercent"
  },
  GetDesktopToolType = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetDesktopToolType"
  },
  MagicTreeWaterInfo = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "MagicTreeWaterInfo"
  },
  tuxInitDone = {
    modulePath = "LobbyModuleConfig",
    moduleName = "LogicUGCWOWQuestionnaire",
    func = "tuxInitDone"
  },
  tuxShowEntrance = {
    modulePath = "LobbyModuleConfig",
    moduleName = "LogicUGCWOWQuestionnaire",
    func = "tuxShowEntrance"
  },
  ActivityAllDone = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ActivityAllDone"
  },
  ShareToClub = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "ShareToClub"
  },
  GetWoWMapStatus = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "GetWoWMapStatus"
  },
  DownloadWoWMap = {
    modulePath = "CommonModuleConfig",
    moduleName = "HostedCommonProtocol",
    func = "DownloadWoWMap"
  }
}
return HostedProtoConfig