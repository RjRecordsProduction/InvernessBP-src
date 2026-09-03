local local local local Activity_Config = {
  {
    switchType = ActivitySwitchType.CallBack,
    showType = -1,
    uiConfig = "LOBBY_ComeBack_Assembly_Set_UIBP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.come_back.logic_assembly_activity",
    funcName = "GetActivitySubData_AssemblySet",
    updateEventType = EVENTTYPE_ACTIVITY,
    updateEventID = EVENTID_ASSEMBLY_ACTIVITY_UPDATE,
    sort = 3
  },
  {
    switchType = ActivitySwitchType.CallBack,
    showType = -1,
    uiConfig = "assembly_award_page",
    hasImageUrl = true,
    moduleName = "client.slua.logic.come_back.logic_assembly_activity",
    funcName = "GetActivitySubData_AssemblyAward",
    updateEventType = EVENTTYPE_ACTIVITY,
    updateEventID = EVENTID_ASSEMBLY_ACTIVITY_UPDATE,
    sort = 3
  },
  {
    switchType = ActivitySwitchType.CallBack,
    showType = -1,
    uiConfig = "Lobby_TSL_UIBP",
    moduleName = "client.slua.logic.person_space.logic_popular_tsl_pk",
    funcName = "GetActivitySubData",
    updateEventType = EVENTTYPE_POPULAR_TSL_PK,
    updateEventID = EVENTID_POPULAR_TSL_PK_ACTIVITY_CHANGE,
    sort = 3
  },
  {
    switchType = ActivitySwitchType.IPLink,
    showType = -1,
    uiConfig = "week_sign",
    hasImageUrl = true,
    moduleName = "client.slua.logic.week_sign.logic_weeksign",
    funcName = "GetActivitySubData_WeekSign",
    sort = 10
  },
  {
    switchType = ActivitySwitchType.IPLink,
    showType = -1,
    uiConfig = "SortitionPutbackTemplate_Main",
    hasImageUrl = true,
    moduleName = "client.slua.logic.draw_turn.draw_trun",
    funcName = "GetDrawTurntable",
    sort = -1
  },
  {
    switchType = ActivitySwitchType.IPLink,
    showType = -1,
    uiConfig = "AdvertisingWheel_Main",
    hasImageUrl = true,
    moduleName = "client.slua.umg.activity.advertisingwheel.AdvertisingWheelSubTab",
    funcName = "GetSubTabTable"
  },
  {
    switchType = ActivitySwitchType.IPLink,
    showType = -1,
    uiConfig = "BlackFriday_WeekSign_UIBP",
    moduleName = "client.slua.logic.week_sign.logic_weeksign",
    funcName = "GetBlackFiveWeekSign",
    sort = -1
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Activity_RPTask_UIBP",
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_mission",
    funcName = "GetActivitySubData",
    updateEventType = EVENTTYPE_UNKNOW_PASS,
    updateEventID = EVENTID_UNKNOW_PASS_UPDATE_MISSIONUI,
    sort = 1
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "LongTermSign_UIBP",
    moduleName = "client.slua.logic.activity.LongTermSign.logic_longterm_sign",
    funcName = "GetActivitySubData_LongSign",
    hasImageUrl = true
  },
  {
    showType = -1,
    uiConfig = "Activty_PeriodicCrate_UIBP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.activity.PeriodicCrate.logic_periodic_crate",
    funcName = "GetActivitySubData_PeriodicCrate"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Rank_Popularity_main_BP",
    moduleName = "client.slua.logic.activity.logic_rank_popularity",
    hasImageUrl = true,
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Rank_Arrogance_main_BP",
    moduleName = "client.slua.logic.activity.logic_rank_pround",
    hasImageUrl = true,
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Rank_Guard_main_BP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.activity.logic_rank_guard",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Rank_Creativity_main_BP",
    hasImageUrl = false,
    moduleName = "client.slua.logic.activity.logic_rank_creativity",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Rank_Incentive_main_BP",
    hasImageUrl = false,
    moduleName = "client.slua.logic.activity.logic_rank_Incentive",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.CallBack,
    showType = -1,
    uiConfig = "Rank_IceSnow_Main_BP",
    funcName = "GetActivitySubData",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_rank_ice",
    hasImageUrl = true,
    sort = 1
  },
  {
    switchType = ActivitySwitchType.CallBack,
    showType = -1,
    uiConfig = "Rank_Collection_Main_BP",
    funcName = "GetActivitySubData",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_rank_collection",
    hasImageUrl = true,
    sort = 1
  },
  {
    switchType = ActivitySwitchType.IPLink,
    showType = -1,
    uiConfig = "ui_day_first_win",
    hasImageUrl = true,
    moduleName = "client.slua.logic.activity.day_first_win.logic_day_first_win",
    funcName = "GetActivitySubData",
    sort = 2
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Unknowpass_LimitTime_Activity",
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_mission",
    funcName = "GetLimitActTaskInfo",
    sort = 6
  },
  {
    switchType = ActivitySwitchType.Notice,
    showType = -1,
    uiConfig = "Activity_RoutineTasks1_UIBP",
    moduleName = "client.slua.logic.activity.logic_quick_question",
    funcName = "GetQuestionActTableData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Sink_Activity_UIBP",
    moduleName = "client.slua.logic.activity.sink_activity.logic_sink_activity",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Notice,
    showType = -1,
    uiConfig = "Activty_Page2_UIBP_New",
    moduleName = "client.slua.logic.activity.logic_activitycenter_notice",
    funcName = "GetNoticeData",
    updateEventType = EVENTTYPE_ACTIVITY_CENTER_NOTICE,
    updateEventID = EVENTID_ACTIVITY_CENTER_NOTICE_GOT
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    sort = 4,
    uiConfig = "Activity_Area_UIBP",
    moduleName = "client.slua.logic.activity.commom_activity_center.logic_area_group",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "LoginPunchInAct",
    moduleName = "client.slua.logic.activity.logic_login_punchin",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Activity_Gradually_UIBP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.activity.commom_activity_center.logic_activity_gradually",
    funcName = "GetActivitySubData",
    updateEventType = EVENTTYPE_ACTIVITY_PLOT,
    updateEventID = EVENTID_PLOT_UNLOCK_OR_TASK_CHANGE
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Activity_RoutineTasks1_UIBP",
    moduleName = "client.slua.logic.activity.logic_skill_task",
    funcName = "GetActivitySubData"
  },
  {
    switchType = ActivitySwitchType.Activity,
    hasImageUrl = true,
    showType = -1,
    uiConfig = "activity_ad_week",
    funcName = "GetLocalAdvertisementWeekSign",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_advertisement_BlueHole"
  },
  {
    switchType = ActivitySwitchType.Activity,
    showType = -1,
    uiConfig = "Activity_RoutineTasks1_UIBP",
    moduleName = "client.slua.logic.activity.logic_prechurn_loginreward",
    funcName = "GetActivitySubData"
  },
  {
    showType = -1,
    uiConfig = "Activity_SingleBind_UIBP",
    hasImageUrl = true,
    funcName = "GetActivitySubData_SingleBind",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_singlebind",
    sort = -2
  },
  {
    showType = -1,
    sort = 4,
    uiConfig = "UGC_Event_Theme_UIBP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.ugc.SeasonTemplate.logic_ugc_season_template",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_ugc_season_template",
    funcName = "GetActivityValidActivity"
  },
  {
    showType = -1,
    sort = 4,
    uiConfig = "UGC_Event_CollectionPage_UIBP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.ugc.SeasonTemplate.logic_ugc_season_template",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_ugc_season_template",
    funcName = "GetCollectionActData"
  },
  {
    showType = -1,
    sort = 4,
    uiConfig = "UGC_ThemePlay_ActivityTemplate_UIBP",
    hasImageUrl = true,
    moduleName = "client.slua.logic.ugc.ThemePlayActivityTemplate.logic_ugc_theme_play_activity_template",
    modulePath = "LobbyModuleConfig",
    moduleConfig = "logic_ugc_theme_play_activity_template",
    funcName = "GetThemeActData"
  }
}
local CacheList = {}
local time_ticker = require("common.time_ticker")
function Activity_Config.StartCache(time, restart)
  if Activity_Config.NTimer then
    if not restart then
      return
    else
      Activity_Config.ReleaseCash()
    end
  end
  log_warning(bWriteLog and "  :Activity_Config.StartCache time: " .. tostring(time))
  Activity_Config.NTimer = time_ticker.AddTimerOnce(time or 3, Activity_Config.ReleaseCash)
end
function Activity_Config.ReleaseCash()
  log_warning(bWriteLog and "  :Activity_Config.ReleaseCash: ")
  time_ticker.RemoveTimer(Activity_Config.NTimer)
  Activity_Config.NTimer = nil
  CacheList = {}
end
function Activity_Config.DoAction(index, cfg)
  local data
  if Activity_Config.NTimer and CacheList[index] ~= nil then
    return CacheList[index]
  end
  local funcName = cfg.funcName
  if cfg.modulePath and cfg.moduleConfig then
    if type(cfg.modulePath) ~= "string" or type(cfg.moduleConfig) ~= "string" then
      return data
    end
    local module = ModuleManager.GetModule(ModuleManager[cfg.modulePath][cfg.moduleConfig])
    if not module then
      local utility = require("common.utility")
      utility.ErrorMessageHandler(string.format("Activity_Config.DoAction Error Module Config:%s,%s"), tostring(cfg.modulePath), tostring(cfg.moduleConfig))
      return data
    end
    if module[funcName] and type(module[funcName]) == "function" then
      data = module[funcName](module)
      if Activity_Config.NTimer then
        CacheList[index] = data or false
      end
    end
  else
    if type(cfg.moduleName) ~= "string" then
      return data
    end
    local module = require(cfg.moduleName)
    if not module then
      local utility = require("common.utility")
      utility.ErrorMessageHandler(string.format("Activity_Config.DoAction Error Logic:%s"), tostring(cfg.moduleName))
      return data
    end
    if module[funcName] and type(module[funcName]) == "function" then
      data = module[funcName]()
      if Activity_Config.NTimer then
        CacheList[index] = data or false
      end
    end
  end
  return data
end
return Activity_Config