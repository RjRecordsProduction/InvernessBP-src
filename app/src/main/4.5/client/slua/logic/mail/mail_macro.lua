local Mail_Macro = {maxSystemMailCount = 60, returnShareCardMailCfgID = 11241}
local Enum_Mail_Type = {
  System = 1,
  Friend = 2,
  MsgCenter = 3,
  GiftCenter = 4,
  Security = 5
}
Mail_Macro.local Enum_Mail_Tab_Config = {
  [Enum_Mail_Type.System] = {
    NameId = 33711,
    MaxCount = 60,
    UIConfig = "Mail_Msg_Sub_UIBP",
    GetRedDataFuncName = "GetSystemData"
  },
  [Enum_Mail_Type.Friend] = {
    NameId = 33712,
    MaxCount = 30,
    UIConfig = "Mail_Msg_Sub_UIBP",
    GetRedDataFuncName = "GetFriendData"
  },
  [Enum_Mail_Type.MsgCenter] = {
    NameId = 33713,
    MaxCount = 60,
    UIConfig = "Mail_Msg_Sub_UIBP",
    GetRedDataFuncName = "GetMessageData",
    CheckShowFunc = function()
      return true
    end
  },
  [Enum_Mail_Type.GiftCenter] = {
    NameId = 33714,
    MaxCount = 30,
    UIConfig = "ui_shop_gift_msgcenter",
    GetRedDataFuncName = "GetGiftCenterData",
    CheckShowFunc = function()
      return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_SEND_GIFT)
    end
  },
  [Enum_Mail_Type.Security] = {
    NameId = 33715,
    MaxCount = 60,
    UIConfig = "secure_mail",
    GetRedDataFuncName = "GetSecurityData",
    CheckShowFunc = function()
      return LobbySystem.roleData.security_mail_switch and tonumber(LobbySystem.roleData.security_mail_switch) == 1
    end,
    ClickTabTLogFunc = function()
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.Safe_Mail_Click)
    end
  }
}
Mail_Macro.local Enum_Mail_SubType = {
  GiveCoinType1 = 1,
  GiveCoinType2 = 1000,
  GiveItem = 1006,
  XmissionEquipBack = 1007,
  MentorType1 = 9,
  MentorType2 = 10,
  FriendAgreeApply = 11,
  MentorInvite = 10065,
  FriendInviteTam = 10066,
  OldFriendGift = 10224
}
Mail_Macro.Mail_Macro.FriendMailRebateSubTypeList = {
  Enum_Mail_SubType.GiveCoinType1,
  Enum_Mail_SubType.GiveCoinType2,
  Enum_Mail_SubType.GiveItem
}
Mail_Macro.Enum_Gift_SubTabType = require("client.slua.umg.NewStoreV280.NewStoreMove.handsel.shop_gift_data").MsgCenterTabType
local Enum_Gift_SubTab_Config = {
  [1] = {
    TabType = Mail_Macro.Enum_Gift_SubTabType.rec_gift,
    SubIndex = 1,
    NameId = 33716
  },
  [2] = {
    TabType = Mail_Macro.Enum_Gift_SubTabType.ask,
    SubIndex = 2,
    NameId = 501066
  },
  [3] = {
    TabType = Mail_Macro.Enum_Gift_SubTabType.give_away,
    SubIndex = 3,
    NameId = 33717
  }
}
Mail_Macro.local Enum_Security_SubTabType = {
  Notice = 1,
  Report = 2,
  Punish = 3,
  SlapFace = 4,
  ReportButNoLink = 5,
  WarningPenalty = 6,
  TWarningPenalty = 7
}
Mail_Macro.local Enum_Security_SubTab_Config = {
  [Enum_Security_SubTabType.Notice] = {
    SubIndex = 2,
    NameId = 800015,
    ClickTabTLogID = TLogEventDefine.Safe_Mail_Click_Notice_Tab,
    ClickMailTLogID = TLogEventDefine.Safe_Mail_Click_Notice_Mail
  },
  [Enum_Security_SubTabType.Report] = {
    SubIndex = 1,
    NameId = 800016,
    ClickTabTLogID = TLogEventDefine.Safe_Mail_Click_Report_Tab,
    ClickMailTLogID = TLogEventDefine.Safe_Mail_Click_Report_Mail
  },
  [Enum_Security_SubTabType.Punish] = {
    SubIndex = 3,
    NameId = 800017,
    ClickTabTLogID = TLogEventDefine.Safe_Mail_Click_Punish_Tab,
    ClickMailTLogID = TLogEventDefine.Safe_Mail_Click_Punish_Mail
  }
}
Mail_Macro.local Enum_RedPoint_SubID = {
  SysMsg = 1,
  SysMsgWithAttach = 2,
  Msg = 3,
  MsgWithAttach = 4,
  Gift = 5,
  AskFor = 6,
  Security = 7,
  SecurityWithAttach = 8
}
Mail_Macro.local Enum_BatchReceiveAttach_InvokeType = {
  MiniTV = 1,
  Battle = 2,
  Mail = 3
}
Mail_Macro.local Enum_PictureType = {
  None = 0,
  FullScreen = 1,
  HalfScreen = 2,
  WithText = 3
}
Mail_Macro.local Enum_FriendPresent_Type = {
  old = 0,
  Return = 1,
  Anniversary = 2,
  Continuous = 3,
  Common = 4
}
Mail_Macro.local ImageBPIconConfig = {
  Coin = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_CoinSend_png.Common_Icon_CoinSend_png",
  Sliver = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_SilverSend_png.Common_Icon_SilverSend_png",
  AG = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_AGSend_png.Common_Icon_AGSend_png",
  Gift = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_GiftSend_png.Common_Icon_GiftSend_png"
}
Mail_Macro.local Enum_FriendPresentFromType = {
  BackUser = 0,
  ChatMenu = 1,
  MailRebate = 2,
  MailBatchRebate = 3,
  MiniTVOneClick = 4
}
Mail_Macro.local Enum_Request_MailList_Source = {
  Login = 1,
  OpenMail = 2,
  DeleteMail = 3
}
Mail_Macro.return Mail_Macro