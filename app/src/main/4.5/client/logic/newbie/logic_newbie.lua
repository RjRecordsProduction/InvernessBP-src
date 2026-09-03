local LogicNewbie = {
  newbieType = 0,
  abcTestGroup = nil,
  newbieTotalGameCnt = 0,
  VehicleMainGuideStep = nil,
  NEWBIE_GUIDE_MODULE_ID_NewNewbie = 35,
  NEWBIE_GUIDE_MODULE_ID_OLDFRIEND = 100,
  NEWBIE_GUIDE_MODULE_ID_FIGHT_GUIDE = 101,
  NEWBIE_GUIDE_MODULE_ID_STRONG_DEPOT_GUIDE = 102,
  NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE = 103,
  NEWBIE_GUIDE_MODULE_ID_STRONG_SEASON_GUIDE = 105,
  NEWBIE_GUIDE_MODULE_ID_STRONG_MACHINE_GUIDE = 106,
  NEWBIE_GUIDE_MODULE_ID_STRONG_RP_GUIDE = 104,
  NEWBIE_GUIDE_MODULE_ID_MATCH_FIRST_SELECT = 107,
  NEWBIE_GUIDE_MODULE_ID_LBS_GUIDE = 110,
  NEWBIE_GUIDE_MODULE_ID_FIRST_BATTLE_AFTER_TASK = 111,
  NEWBIE_GUIDE_ACTIVITY_MOUDULE = 1001,
  NEWBIE_GUIDE_FIRST_LOTTERY = 112,
  NEWBIE_GUIDE_MODULE_ID_UGC = 113,
  NEWBIE_GUIDE_MODULE_ID_PICK_EMOJI_CARD = 114,
  NEWBIE_GUIDE_MODULE_ID_PLAY_MARCHING_EMOTE = 115,
  NEWBIE_GUIDE_MODULE_ID_RUN_STATE_WHEN_MARCHING_EMOTE = 116,
  NEWBIE_GUIDE_MODULE_ID_XMISSION_WAR_PRESET = 117,
  NEWBIE_GUIDE_MODULE_ID_XMISSION_SOUVENIRS = 119,
  NEWBIE_GUIDE_HOME_CRYSTAL_TAB_EMOTION = 128,
  NEWBIE_GUIDE_XMISSION_SOUVENIRS_EDIT = 131,
  NEWBIE_GUIDE_MODULE_ID_LEVEL_UNLOCK = 132,
  NEWBIE_GUIDE_MODULE_WARDROBE_XSUIT = 139,
  NEWBIE_GUIDE_MODULE_ID_SEASON_SWITCH_SLAP = 140,
  FaceSlapEnded = false
}
ENUM_NewbieState = {
  Not = 0,
  Week = 1,
  Force = 2
}
ENUM_Newbie_Friend = {Entrance = 0, Invite = 1}
function LogicNewbie.IsNewbie(SkipCheckOpen)
  if Client and Client.IsMatchVersion and Client.IsMatchVersion() then
    return false
  end
  if not SkipCheckOpen and not LobbySystem.CheckOpen(70026) then
    log(bWriteLog and "LogicNewbie.IsNewbie switch close")
    return false
  end
  if LogicNewbie.newbieType and LogicNewbie.newbieType > 1 then
    log(bWriteLog and "LogicNewbie.IsNewbie newbieType = " .. tostring(LogicNewbie.newbieType))
    return false
  end
  local newbeeTime = 259200
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec() - DataMgr.registertime
  if time < 0 then
    log(bWriteLog and "LogicNewbie.IsNewbie TimeUtil.GetServerTimeInSec() < DataMgr.registertime")
    return false
  end
  return newbeeTime > time
end
function LogicNewbie.NeedShowNewbieGuide(id)
  log_format("LogicNewbie.NeedShowNewbieGuide id = %s", id)
  if DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, id) then
    log_warning(bWriteLog and "LogicNewbie.NeedShowNewbieGuide already show")
    return false
  end
  local rule, tableName
  if LogicNewbie.abcTestGroup then
    tableName = "NewerGuide" .. string.upper(LogicNewbie.abcTestGroup) .. "Table"
  else
    tableName = "NewerGuideTable"
  end
  log_format("LogicNewbie.NeedShowNewbieGuide tableName = %s", tableName)
  rule = CDataTable.GetTableData(tableName, id)
  if rule then
    if DataMgr.roleData.level < rule.NeedLevel then
      log_format("LogicNewbie.NeedShowNewbieGuide level limit. current = %s, need = %s", DataMgr.roleData.level, rule.NeedLevel)
      return false
    end
    local totalCount = LogicNewbie.GetTotalGameCount()
    if totalCount >= rule.Start and totalCount < rule.End then
      log_format("LogicNewbie.NeedShowNewbieGuide game count limit. current = %s, start = %s, end = %s", LogicNewbie.newbieTotalGameCnt, rule.Start, rule.End)
      return true
    end
  end
  return false
end
function LogicNewbie.GetConfig(id)
  local rule, tableName
  if LogicNewbie.abcTestGroup then
    tableName = "NewerGuide" .. string.upper(LogicNewbie.abcTestGroup) .. "Table"
  else
    tableName = "NewerGuideTable"
  end
  return CDataTable.GetTableData(tableName, id)
end
function LogicNewbie.GetNewbieGuideState(id)
  log(bWriteLog and "LogicNewbie.GetNewbieGuideState id = " .. tostring(id))
  if DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, id) then
    return ENUM_NewbieState.Not
  end
  local rule
  if LogicNewbie.abcTestGroup then
    local tableName = "NewerGuide" .. string.upper(LogicNewbie.abcTestGroup) .. "Table"
    rule = CDataTable.GetTableData(tableName, id)
  else
    rule = CDataTable.GetTableData("NewerGuideTable", id)
  end
  if rule then
    if DataMgr.roleData.level < rule.NeedLevel then
      return ENUM_NewbieState.Not
    end
    if LogicNewbie.newbieTotalGameCnt >= rule.Start and LogicNewbie.newbieTotalGameCnt < rule.End then
      if rule.SwitchID > 0 and LobbySystem.CheckOpen(rule.SwitchID) then
        log(bWriteLog and "LogicNewbie.GetNewbieGuideState rule.SwitchID open " .. tostring(rule.SwitchID))
        return ENUM_NewbieState.Force
      end
      return ENUM_NewbieState.Week
    end
  end
  return ENUM_NewbieState.Not
end
function LogicNewbie.IsForceNewbieGuideOpen(id)
  if LogicNewbie.NeedShowNewbieGuide(id) then
    local rule = CDataTable.GetTableData("NewerGuideTable", id)
    if rule and rule.SwitchID > 0 and LobbySystem.CheckOpen(rule.SwitchID) then
      return true
    end
  end
  return false
end
function LogicNewbie.IsNeedVehicleNewbieGuide()
  local _step = 1
  local module_id = DataMgr.NEWBIE_GUIDE_MODULE_ID_VEHICIE_MAIN
  for key = 1, 3 do
    local val = DataMgr.HaveNewbieGuide(module_id, key)
    if val then
      _step = key
      break
    end
  end
  if _step == 3 then
    return false, 3
  else
    return true, _step
  end
end
function LogicNewbie.IsPopVehicleMainPopFloatTip()
  if LogicNewbie.VehicleMainGuideStep == 2 then
    return true
  else
    return false
  end
end
function LogicNewbie.SetVehicleMainGuideStep(Step)
  LogicNewbie.VehicleMainGuideend
function LogicNewbie.CheckSlideShow()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not lobbyMain or lobbyMain:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    log(bWriteLog and "LogicNewbie.CheckSlideShow isn't in lobby!")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  if not growthprojectMgrB.IsFinishAllNewGuide() or enter_guide.executeFightGuide then
    log(bWriteLog and "LogicNewbie.CheckSlideShow has the new guide!")
    return false
  end
  local uiConfig = LogicNewbie.GetWelcomeUIConfig()
  if UIManager.IsUIShow(uiConfig) or UIManager.IsUIShow(uiConfig) then
    log(bWriteLog and "LogicNewbie.CheckSlideShow Newbie_Guide_Welcome or Common_Welcome_UIBP show")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.ui_season_switch_mgr) then
    log(bWriteLog and "LogicNewbie.CheckSlideShow ui_season_switch_mgr show")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.eu_gdpr_jpage) then
    log(bWriteLog and "LogicNewbie.CheckSlideShow eu_gdpr_jpage show")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Newbie_Friends_Recommend) then
    log(bWriteLog and "LogicNewbie.CheckSlideShow Newbie_Friends_Recommend show")
    return false
  end
  if Client.IsWindowOB() then
    log(bWriteLog and "LogicNewbie.CheckSlideShow Client is Window OB")
    return false
  end
  if LogicNewbie.IsNewbie() then
    log(bWriteLog and "LogicNewbie.CheckSlideShow Is Newbie")
    return false
  end
  if DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, 20007) then
    log(bWriteLog and "LogicNewbie.CheckSlideShow Guide is valid")
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local isSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  if not isSlapEnd then
    log(bWriteLog and "LogicNewbie.CheckSlideShow NewFaceSlapSystem is not end")
    return false
  end
  local logic_lobby_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_guide_manager)
  local bCanGuide = logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide()
  log(bWriteLog and "LogicNewbie.CheckSlideShow bCanGuide = " .. tostring(bCanGuide))
  if not bCanGuide then
    return false
  end
  return true
end
function LogicNewbie.ShowSlideGuide()
  if LogicNewbie.CheckSlideShow() then
    UIManager.ShowUI(UIManager.UI_Config.Lab_Main_Newbie_Slide_UIBP)
  end
end
function LogicNewbie.Show430LobbyGuide()
  log_format("LogicNewbie.Show430LobbyGuide.")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_NewBie_430_UIBP)
end
function LogicNewbie.IsCanShow430LobbyGuide()
  log_format("LogicNewbie.IsCanShow430LobbyGuide.")
  local guideKey = 10700
  local value = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideKey) or 0
  log_format("LogicNewbie.IsCanShow430LobbyGuide. value=%s", value)
  if 0 < value then
    log(bWriteLog and "LogicNewbie.IsCanShow430LobbyGuide Guide is valid")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log_format("LogicNewbie.IsCanShow430LobbyGuide. not finish all new guide")
    DataMgr.SetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideKey, 1)
    return false
  end
  DataMgr.SetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideKey, 1)
  return true
end
function LogicNewbie.GetTotalGameCount()
  return LogicNewbie.newbieTotalGameCnt
end
LogicNewbie.UseUI25Welcome = false
function LogicNewbie.GetWelcomeUIConfig()
  log_format("LogicNewbie.GetWelcomeUIConfig. UseUI25Welcome = [%s]", LogicNewbie.UseUI25Welcome)
  if LogicNewbie.UseUI25Welcome then
    return UIManager.UI_Config.Newbie_Guide_Welcome_UI25
  end
  return UIManager.UI_Config.Newbie_Guide_Welcome
end
return LogicNewbie