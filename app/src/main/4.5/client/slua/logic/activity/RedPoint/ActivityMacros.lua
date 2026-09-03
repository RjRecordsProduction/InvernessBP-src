local ActivityMacros = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
ActivityMacros.RedDotType = {
  None = 0,
  Normal = 1,
  Reward = 2,
  New = 3,
  End = 4
}
ActivityMacros.RedDotSubID = {
  None = 0,
  Reward = 1,
  New = 2,
  Normal = 3,
  End = 4
}
ActivityMacros.RedDotType2SubID = {
  [ActivityMacros.RedDotType.Reward] = ActivityMacros.RedDotSubID.Reward,
  [ActivityMacros.RedDotType.New] = ActivityMacros.RedDotSubID.New,
  [ActivityMacros.RedDotType.Normal] = ActivityMacros.RedDotSubID.Normal,
  [ActivityMacros.RedDotType.End] = ActivityMacros.RedDotSubID.End,
  [ActivityMacros.RedDotType.None] = ActivityMacros.RedDotSubID.None
}
ActivityMacros.SubActType = {
  Award = 1,
  Exchange = 2,
  SelectExchange = 3,
  AwardTimeLimit = 4,
  TaskPropsCollect = 5
}
ActivityMacros.ActPageUI = {
  [ActivityShowType.Sub] = "Activity_RoutineTasks1_UIBP",
  [ActivityShowType.Notice] = "Activty_Page2_UIBP_New",
  [ActivityShowType.Image] = "Activity_Image_UIBP",
  [ActivityShowType.Text] = "Activity_Text_UIBP",
  [ActivityShowType.Banner] = "Activity_EntrySet_UIBP",
  [ActivityShowType.Progress] = "Activity_Schedule_UIBP",
  [ActivityShowType.RedeemCode] = "PassworRedEnvelope_UIBP",
  [ActivityShowType.TaskExchange] = "Activity_Exchange_UIBP",
  [ActivityShowType.TaskProgress] = "Activity_RoutineTasks2_UIBP",
  [ActivityShowType.TaskPropsCollect] = "Activity_RoutineTasks3_UIBP",
  [ActivityShowType.ASSEMBLY_FRIEND_JK] = "LOBBY_ComeBack_Task_JK_UIBP",
  [ActivityShowType.HOME_STORE_ACTIVITY] = "Elegant_Ancient_Capital_UIBP",
  [ActivityShowType.INTIMACY_DOUBLE] = "INTIMACY_DOUBLE_UIBP",
  [ActivityShowType.Bind_Discord] = "activity_bind_discord",
  [ActivityShowType.GameletContainer] = "GameletContainer_UIBP",
  [ActivityShowType.WeekMarket] = "Lobby_Exchange_Market_Main_UIBP",
  [ActivityShowType.PandoraContainer] = "PandoraContainer_UIBP"
}
ActivityMacros.ActTabIcon = {
  [ActivitySwitchType.IPLink] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_IP_png.Common_Tab_IP_png",
  [ActivitySwitchType.Activity] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Trail_png.Common_Tab_Trail_png",
  [ActivitySwitchType.CallBack] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Recall_png.Common_Tab_Recall_png",
  [ActivitySwitchType.Notice] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Announcement_png.Common_Tab_Announcement_png",
  [ActivitySwitchType.Sport] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Esports_png.Common_Tab_Esports_png",
  [ActivitySwitchType.Xmission] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Metro_png.Common_Tab_Metro_png",
  [ActivitySwitchType.Welfare] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Gift_png.Common_Tab_Gift_png",
  [ActivitySwitchType.DragonSpearSpin] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Metro_02_png.Common_Tab_Metro_02_png"
}
ActivityMacros.ActTabSelIcon = {
  [ActivitySwitchType.IPLink] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_IP_Xuanzhong_png.Common_Tab_IP_Xuanzhong_png",
  [ActivitySwitchType.Activity] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Trail_Xuanzhong_png.Common_Tab_Trail_Xuanzhong_png",
  [ActivitySwitchType.CallBack] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Recall_Xuanzhong_png.Common_Tab_Recall_Xuanzhong_png",
  [ActivitySwitchType.Notice] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Announcement_Xuanzhong_png.Common_Tab_Announcement_Xuanzhong_png",
  [ActivitySwitchType.Sport] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Esports_Xuanzhong_png.Common_Tab_Esports_Xuanzhong_png",
  [ActivitySwitchType.Xmission] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Metro_Xuanzhong_png.Common_Tab_Metro_Xuanzhong_png",
  [ActivitySwitchType.Welfare] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Gift_Xuanzhong1_png.Common_Tab_Gift_Xuanzhong1_png",
  [ActivitySwitchType.DragonSpearSpin] = "/Game/UMG/Texture_200/Atlas/NewActivty/Frames/Common_Tab_Metro_02_Xuanzhong_png.Common_Tab_Metro_02_Xuanzhong_png"
}
ActivityMacros.SubActivitySystemName = {
  reddot_macro.SystemName.ActivityCenter,
  reddot_macro.SystemName.ActivityCenterWOW,
  reddot_macro.SystemName.ActivityCenterPlanPH,
  reddot_macro.SystemName.ActivityCenterTxMission,
  reddot_macro.SystemName.ActivityCenterSport
}
ActivityMacros.DisplayScene2SystemName = {
  [ActivityDisplayScene.Default] = reddot_macro.SystemName.ActivityCenter,
  [ActivityDisplayScene.WOW] = reddot_macro.SystemName.ActivityCenterWOW,
  [ActivityDisplayScene.PlanPH] = reddot_macro.SystemName.ActivityCenterPlanPH,
  [ActivityDisplayScene.TxMission] = reddot_macro.SystemName.ActivityCenterTxMission,
  [ActivityDisplayScene.Sport] = reddot_macro.SystemName.ActivityCenterSport
}
ActivityMacros.NeedWrapperSystemName = {
  [reddot_macro.SystemName.ActivityCenterWOW] = 1
}
ActivityMacros.ActTabConfig = {
  [ActivitySwitchType.IPLink] = {
    nType = ActivitySwitchType.IPLink,
    sLocalizeID = "10464",
    nSort = 1
  },
  [ActivitySwitchType.Activity] = {
    nType = ActivitySwitchType.Activity,
    sLocalizeID = "6990",
    nSort = 3
  },
  [ActivitySwitchType.CallBack] = {
    nType = ActivitySwitchType.CallBack,
    sLocalizeID = "6992",
    nSort = 5
  },
  [ActivitySwitchType.Notice] = {
    nType = ActivitySwitchType.Notice,
    sLocalizeID = "9118",
    nSort = 7
  },
  [ActivitySwitchType.Sport] = {
    nType = ActivitySwitchType.Sport,
    sLocalizeID = "34700",
    nSort = 8
  },
  [ActivitySwitchType.Xmission] = {
    nType = ActivitySwitchType.Xmission,
    sLocalizeID = "11625",
    nSort = 9
  },
  [ActivitySwitchType.Welfare] = {
    nType = ActivitySwitchType.Welfare,
    sLocalizeID = "29861",
    nSort = 2
  },
  [ActivitySwitchType.DragonSpearSpin] = {
    nType = ActivitySwitchType.DragonSpearSpin,
    sLocalizeID = "11625",
    nSort = 10
  }
}
ActivityMacros.ActTabInfoSource = {
  Activity = 1,
  Extra = 2,
  Notice = 3
}
return ActivityMacros