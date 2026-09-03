local ScrollBgPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/AirdropCarnival/AirdropCarnival_Tips_Bg_02.AirdropCarnival_Tips_Bg_02"
local IconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/AirdropCarnival/AirdropCarnival_Icon_Ball.AirdropCarnival_Icon_Ball"
local logic_newbie_task_segment_activity = {}
function logic_newbie_task_segment_activity:DefineAndResetData()
  self.segmentProtectionTimes = 0
  self.segmentAddScoreTimes = 0
end
function logic_newbie_task_segment_activity:GetSegmentActivityShowData()
  local segmentProtectionConfig = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_daily_protect_times")
  local segmentAddScoreConfig = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_daily_team_adtnl_times")
  local segmentAddScoreNumConfig = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_daily_team_adtnl_num")
  local result = {
    pConfig = segmentProtectionConfig,
    pTimes = self.segmentProtectionTimes,
    asConfig = segmentAddScoreConfig,
    asTimes = self.segmentAddScoreTimes,
    asnConfig = segmentAddScoreNumConfig
  }
  return result
end
function logic_newbie_task_segment_activity:IsOpen()
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  if not newbie_guide_util.IsNewbieAndIsInNewbieABTest() then
    log_warning(bWriteLog and "logic_newbie_task_segment_activity:IsOpen return not in ABTest")
    return false
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.matchMode) then
    log_warning(bWriteLog and "logic_newbie_task_segment_activity:IsOpen return matchMode not unlock")
    return false
  end
  return true
end
function logic_newbie_task_segment_activity:GetSegmentEntranceIconInfo()
  return ScrollBgPath, IconPath
end
function logic_newbie_task_segment_activity:GetValidActivityCount()
  local typeList = self:GetValidTypeList()
  return typeList and #typeList or 0, typeList and typeList[1].protect_id
end
function logic_newbie_task_segment_activity:CheckValidActTypeInAct()
  log(bWriteLog and "logic_newbie_task_segment_activity.CheckValidActTypeInAct")
  if not self:IsOpen() then
    log_warning(bWriteLog and "logic_newbie_task_segment_activity.CheckValidActTypeInAct return not open")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, _, __ = logic_mode_selection:GetCurSelectInfo()
  if not self:IsClassicRankMode(matchMode) then
    log_warning(bWriteLog and "logic_newbie_task_segment_activity.CheckValidActTypeInAct return not classic rank mode")
    return false
  end
  local actList = self:GetValidTypeList()
  if not actList or not next(actList) then
    return false
  end
  return true, actList
end
function logic_newbie_task_segment_activity:IsClassicRankMode(matchMode)
  return matchMode == 101 or matchMode == 102 or matchMode == 103 or matchMode == 401 or matchMode == 402 or matchMode == 403
end
function logic_newbie_task_segment_activity:GetValidTypeList()
  local result = self:GetSegmentActivityShowData()
  local temp1 = {
    protect_id = 37,
    totalNum = tonumber(result.pConfig.Value),
    progressNum = result.pTimes
  }
  local temp2 = {
    protect_id = 38,
    totalNum = tonumber(result.asConfig.Value),
    progressNum = result.asTimes
  }
  return {temp1, temp2}
end
function logic_newbie_task_segment_activity:GoToActMainUI(isLevelUnlock)
  UIManager.ShowUI(UIManager.UI_Config.NewbieTraining_Popup_UIBP, isLevelUnlock)
end
function logic_newbie_task_segment_activity:IsActScoreProtectFirst()
  local list = self:GetValidTypeList()
  if list[2].totalNum > list[2].progressNum then
    return true
  end
  return false
end
function logic_newbie_task_segment_activity:UpdateActivityCount(rating_protect_cnt, rating_adtnl_cnt)
  if rating_protect_cnt then
    self.segmentProtectionTimes = rating_protect_cnt
  end
  if rating_adtnl_cnt then
    self.segmentAddScoreTimes = rating_adtnl_cnt
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_UPDATE_RATING_PROTECT_INFO)
end
function logic_newbie_task_segment_activity:send_newbie_rating_protect_info_req()
  local NewbieTaskHandler = require("client.network.Protocol.NewbieTaskHandler")
  NewbieTaskHandler.send_newbie_rating_protect_info_req()
end
function logic_newbie_task_segment_activity:on_newbie_rating_protect_info_rsp(rating_protect_cnt, rating_adtnl_cnt)
  self:UpdateActivityCount(rating_protect_cnt, rating_adtnl_cnt)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_newbie_task_segment_activity = class(CModuleBase, nil, logic_newbie_task_segment_activity)
return Clogic_newbie_task_segment_activity