local LogicNewbieMain = {}
LogicNewbieMain.activityDef = {
  Training = 1,
  Achievement = 2,
  Spin = 3,
  Sprint = 4,
  EightDay = 5,
  Main = 6,
  FriendsGathering = 7,
  Reward = 8,
  Privilege = 9,
  NewBieSevenDay = 10,
  NewBieTask = 11,
  NewBieDailyWish = 12,
  NewBiePrivileges = 13,
  NewBieTraining = 14
}
LogicNewbieMain.config = {
  {
    uiConfig = "Activity_Newbie_Training",
    uiConfig_New = "NewbieTraining_New_UIBP",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_task",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Training,
    checkUseNewUIFunc = function()
      local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
      return newbie_guide_util.IsInNewbieABTest()
    end
  },
  {
    uiConfig = "Activity_Newbie_FriendsGathering",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_friends_gathering",
    funcName = "GetActivitySubData",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.FriendsGathering
  },
  {
    uiConfig = "Activity_Newbie_Achievement",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_achievement",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Achievement
  },
  {
    uiConfig = "new_player_spin_main_uibp",
    moduleName = "client.slua.logic.growth_project.logic_new_player_spin",
    funcName = "GetNewbieSpinInfo",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Spin
  },
  {
    uiConfig = "Activity_Newbie_LevelSprint",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_level_sprint",
    funcName = "GetActivitySubData",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Sprint
  },
  {
    uiConfig = "Activity_Newbie_EightDays",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_eight_day",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.EightDay
  }
}
LogicNewbieMain.NewbieRewardABTestConfig = {
  {
    uiConfig = "Newbie_Reward_Homepage_UIBP",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_reward",
    funcName = "GetActivitySubData",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Reward
  },
  {
    uiConfig = "Newbie_Reward_Eight_Days_UIBP",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_reward_eight_day",
    funcName = "GetActivitySubData",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.EightDay
  },
  {
    uiConfig = "Newbie_Reward_Level_Sprint_UIBP",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_reward_level_sprint",
    funcName = "GetActivitySubData",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Sprint
  },
  {
    uiConfig = "NewbiePrivileges_Activity_HomePage_UIBP",
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_privileges",
    funcName = "GetActivitySubData",
    OpenFunc = "IsOpen",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.Privilege
  }
}
LogicNewbieMain.ABTestConfig = {
  {
    uiConfig = "NewRecruit_SevenDayTask_UIBP",
    moduleName = "client.slua.logic.activity.newbie_opt.logic_newbie_seven_task_opt",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.NewBieSevenDay
  },
  {
    uiConfig = "NewRecruit_NewbieTask_UIBP",
    moduleName = "client.slua.logic.activity.newbie_opt.logic_newbie_task_opt",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.NewBieTask
  },
  {
    uiConfig = "NewRecruit_DailyWish_UIBP",
    moduleName = "client.slua.logic.activity.newbie_opt.logic_newbie_daily_wish_opt",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.NewBieDailyWish
  },
  {
    uiConfig = "NewRecruit_Welfare_UIBP",
    moduleName = "client.slua.logic.activity.newbie_opt.logic_newbie_welfare_opt",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.NewBiePrivileges
  },
  {
    uiConfig = "NewRecruit_NewcomerTutorial_UIBP",
    moduleName = "client.slua.logic.activity.newbie_opt.logic_newbie_tutorial_opt",
    funcName = "GetActivitySubData",
    redDotCount = "UpdateRedDotCount",
    activityType = LogicNewbieMain.activityDef.NewBieTraining
  }
}
return LogicNewbieMain