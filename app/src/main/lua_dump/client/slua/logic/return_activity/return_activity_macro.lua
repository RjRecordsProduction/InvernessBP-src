local Return_Activity_Macro = {}
local Enum_MenuID = {
  LevelReward = 1,
  Assembly = 2,
  NewLevelReward = 3,
  FirstBattle = 4,
  DailySignIn = 32011,
  Task = 32012,
  Discount = 32013,
  Privilege = 32014,
  Teach = 32015,
  Newpost = 32016,
  RankGoal = 32021,
  Reback = 32022,
  Interact = 32026,
  Questionnaire = 32027
}
Return_Activity_Macro.local SoundPathConfig = {
  "/Game/WwiseEvent/UI_hall/UI_Hall_200/Play_UI_Welcome_Back_1.Play_UI_Welcome_Back_1",
  "/Game/WwiseEvent/UI_hall/UI_Hall_200/Play_UI_Welcome_Back_2.Play_UI_Welcome_Back_2",
  "/Game/WwiseEvent/UI_hall/UI_Hall_200/Play_UI_Welcome_Back_3.Play_UI_Welcome_Back_3"
}
Return_Activity_Macro.local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
local MenuEntranceInfoList = {
  [Enum_MenuID.LevelReward] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Reward_New_UIBP,
    title = 7096
  },
  [Enum_MenuID.Assembly] = {
    jumpUrl = "game://?module=1000800&idx=5&secIdx=1",
    title = 7094,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Bg103.ReturnActivity_Bg103"
  },
  [Enum_MenuID.Interact] = {
    uiConfig = UIManager.UI_Config.Return_FriendRecord_UIBP,
    red_node_name = "interactReward",
    title = 47082,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Bg102.ReturnActivity_Bg102"
  },
  [Enum_MenuID.DailySignIn] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_7days_UIBP,
    red_node_name = "dailySignInReward",
    title = 12413,
    red_dot_require_func = PlayerReturnHandler.send_backuser_get_login_reward_info_req,
    icon_url = "/Game/UMG/Texture/Atlas/PlayerReturn/Frames/New_ComeBack_RankGoal_Icon1_png.New_ComeBack_RankGoal_Icon1_png"
  },
  [Enum_MenuID.Task] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Anniversary_Tips_UIBP,
    red_node_name = "dailyTask"
  },
  [Enum_MenuID.Discount] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_SpeciallyPreferential_UIBP,
    red_node_name = "discountReward",
    title = 12415,
    icon_url = "/Game/UMG/Texture/Atlas/PlayerReturn/Frames/New_ComeBack_RankGoal_Icon3_png.New_ComeBack_RankGoal_Icon3_png",
    red_dot_require_func = PlayerReturnHandler.send_backuser_get_topup_rebate_info_req,
    helpFunc = function()
      local title = LocUtil.GetLocalizeResStr(12415)
      local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
      local endTime = logic_return_activity_utils.GetTimeEndTime()
      local TimeUtil = require("client.common.time_util")
      local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
      local backUserDesc = store_limit_buy_manager:GetBackUserPrivilegeDesc()
      local content = LocUtil.LocalizeResFormat(78060, TimeUtil.FormatTime_YMDHM(endTime, false, true), backUserDesc)
      UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
    end
  },
  [Enum_MenuID.Privilege] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_GamePrivileges_01_UIBP,
    red_node_name = "privilege",
    title = 36729,
    append_open_func = logic_player_return.IsPrivilegeOpen,
    red_dot_require_func = PlayerReturnHandler.send_backuser_get_privilege_data_req,
    needShowClock = true,
    get_clock_endtime_func = logic_player_return.GetPrivilegeEndTime,
    icon_url = "/Game/UMG/Texture/Atlas/PlayerReturn/Frames/New_ComeBack_RankGoal_Icon2_png.New_ComeBack_RankGoal_Icon2_png"
  },
  [Enum_MenuID.Teach] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Newest03_UIBP,
    red_node_name = "newPost",
    title = 12418,
    red_dot_require_func = PlayerReturnHandler.send_backuser_get_user_guide_req,
    icon_url = "/Game/UMG/Texture/Atlas/PlayerReturn/Frames/New_ComeBack_RankGoal_Icon4_png.New_ComeBack_RankGoal_Icon4_png"
  },
  [Enum_MenuID.Newpost] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Newest03_UIBP,
    red_node_name = "newPost",
    title = 12418,
    red_dot_require_func = function()
      local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
      if logic_return_activity_utils.IsTabMenuOpen(Enum_MenuID.Teach) then
        PlayerReturnHandler.send_backuser_get_user_guide_req()
      end
      PlayerReturnHandler.send_backuser_get_new_content_req()
    end,
    icon_url = "/Game/UMG/Texture/Atlas/PlayerReturn/Frames/New_ComeBack_RankGoal_Icon4_png.New_ComeBack_RankGoal_Icon4_png"
  },
  [Enum_MenuID.RankGoal] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_GamePrivileges_01_UIBP,
    red_node_name = "privilege",
    title = 36729,
    red_dot_require_func = function()
      PlayerReturnHandler.send_backuser_get_segment_goal_req()
      local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
      if logic_return_activity_utils.IsTabMenuOpen(Enum_MenuID.Privilege) and logic_player_return.IsPrivilegeOpen() then
        PlayerReturnHandler.send_backuser_get_privilege_data_req()
      end
    end,
    icon_url = "/Game/UMG/Texture/Atlas/PlayerReturn/Frames/New_ComeBack_RankGoal_Icon2_png.New_ComeBack_RankGoal_Icon2_png"
  },
  [Enum_MenuID.Questionnaire] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Questionnaire_UIBP,
    title = 656022
  },
  [Enum_MenuID.NewLevelReward] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Reward_Homepage_UIBP,
    title = 7096
  },
  [Enum_MenuID.FirstBattle] = {
    uiConfig = UIManager.UI_Config.ReturnActivity_Openning_Page_UIBP,
    title = 76350
  }
}
Return_Activity_Macro.local Enum_RedTypeDefaultIndex = {
  dailySignInReward = 2000,
  dailyTask = 3000,
  battleReward = 4000,
  rankReward = 5000,
  newPostReward = 6000,
  teachReward = 7000,
  newPostFirstEnter = 8000,
  interactReward = 9000,
  discountReward = 10000
}
Return_Activity_Macro.local Enum_DayTaskType = {
  GoParadise = 102,
  SurviveTime = 118,
  SpaceGift = 124,
  TeamUp = 116
}
Return_Activity_Macro.local Enum_MenuID_Tlog = {
  [32011] = TLogEventDefine.ReturnActivity7days,
  [32013] = TLogEventDefine.ReturnActivityDiscount,
  [32014] = TLogEventDefine.ReturnActivityPrivilege,
  [32015] = TLogEventDefine.ReturnActivityNewest,
  [32016] = TLogEventDefine.ReturnActivityNewest,
  [32021] = TLogEventDefine.ReturnActivityPrivilege,
  [32026] = TLogEventDefine.ReturnActivityFrdRecord,
  [Enum_MenuID.Questionnaire] = TLogEventDefine.ReturnActivityQuestionnaire
}
Return_Activity_Macro.local Enum_DayRecallTaskType = {
  TeamUpWithRecall = 123,
  SpaceGiftToRecall = 124,
  TeamUpAndTopWithRecall = 125,
  IncreaseIntimacy = 126
}
Return_Activity_Macro.local Enum_DiscountRewardStatus = {
  Default = 0,
  Received = 1,
  Receive = 2
}
Return_Activity_Macro.local Enum_Tag_ShowType = {
  Me = 1,
  Friend = 2,
  Assembly = 3,
  Team = 4,
  Stranger = 5,
  Other = 6
}
Return_Activity_Macro.local TagInfoList = {
  [0] = {
    name = 773214,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg.ReturnActivity_Image_Label_Bg",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773215,
      [Enum_Tag_ShowType.Team] = 773216,
      [Enum_Tag_ShowType.Other] = 773217
    }
  },
  [1] = {
    name = 773205,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg.ReturnActivity_Image_Label_Bg",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773206,
      [Enum_Tag_ShowType.Team] = 773207,
      [Enum_Tag_ShowType.Other] = 773208
    }
  },
  [2] = {
    name = 773209,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg02.ReturnActivity_Image_Label_Bg02",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773218,
      [Enum_Tag_ShowType.Team] = 773219,
      [Enum_Tag_ShowType.Other] = 773220
    }
  },
  [3] = {
    name = 773210,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg03.ReturnActivity_Image_Label_Bg03",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773221,
      [Enum_Tag_ShowType.Team] = 773222,
      [Enum_Tag_ShowType.Other] = 773223
    }
  },
  [4] = {
    name = 773211,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg04.ReturnActivity_Image_Label_Bg04",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773224,
      [Enum_Tag_ShowType.Team] = 773225,
      [Enum_Tag_ShowType.Other] = 773226
    }
  },
  [5] = {
    name = 773212,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg05.ReturnActivity_Image_Label_Bg05",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773227,
      [Enum_Tag_ShowType.Team] = 773228,
      [Enum_Tag_ShowType.Other] = 773229
    }
  },
  [6] = {
    name = 773213,
    icon_url = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/ReturnActivity/ReturnActivity_Image_Label_Bg06.ReturnActivity_Image_Label_Bg06",
    tips_locID = {
      [Enum_Tag_ShowType.Me] = 773230,
      [Enum_Tag_ShowType.Team] = 773231,
      [Enum_Tag_ShowType.Other] = 773232
    }
  }
}
Return_Activity_Macro.local Enum_ShareCard_FromType = {Wardrobe = 1, TeamUp = 2}
Return_Activity_Macro.local Enum_Guide_Type = {
  Achievement = 1,
  Social = 2,
  Content = 3,
  TryNeW = 4,
  Unknow = 5,
  ModeSelect = 6
}
Return_Activity_Macro.local Enum_Newest_Tab_Type = {
  Theme = 1,
  Teach = 2,
  Commercialization = 3
}
Return_Activity_Macro.local Enum_RightBottom_Guide_Popup_Type = {
  VersionUpdate = 0,
  StartGame = 1,
  ShareCard = 2,
  TeamUp = 3
}
Return_Activity_Macro.local Enum_Reward_UI_Show_Type = {
  NewVersionAGroup = 1,
  NewVersionBGroup = 2,
  OldVersionAGroup = 3,
  OldVersionBGroup = 4
}
Return_Activity_Macro.local Enum_FB_Mode_Type = {
  Classic = 1,
  TeamCompetition = 2,
  WOW = 3,
  Xmission = 4
}
Return_Activity_Macro.return Return_Activity_Macro