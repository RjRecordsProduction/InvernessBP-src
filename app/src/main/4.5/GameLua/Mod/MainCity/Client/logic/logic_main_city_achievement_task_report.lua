local logic_main_city_achievement_task_report = {
  isClickStartGameInMainCity = false,
  isOnMCChanel = false,
  action = "",
  actionList = {
    OpenShop = "OpenShop",
    AddMCFriendInMC = "AddMCFriendInMC",
    speakOnMCChannel = "speakOnMCChannel",
    InviteFriend = "InviteFriend"
  }
}
function logic_main_city_achievement_task_report.ReportEnterBattleFromMainCityClickStart()
  if logic_main_city_achievement_task_report.isClickStartGameInMainCity then
    logic_main_city_achievement_task_report.isClickStartGameInMainCity = false
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.EnterBattleFromMainCityClickStart, 0, "", true)
  end
end
function logic_main_city_achievement_task_report.ReportOpenShopInMainCity()
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_main_city_achievement_task_report.ReportOpenShopInMainCity")
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ActionInMainCity, 0, logic_main_city_achievement_task_report.actionList.OpenShop, true)
  else
    log(bWriteLog and "logic_main_city_achievement_task_report.ReportOpenShopInMainCity not in main city")
  end
end
function logic_main_city_achievement_task_report.ReportAddFriendInMainCity(uidList)
  if GameStatus.IsInMainCity() then
    local canReport = false
    local callback = function(StatusList)
      canReport = logic_main_city_achievement_task_report._CheckFriendInMainCity(StatusList)
      log(bWriteLog and "logic_main_city_achievement_task_report.ReportAddFriendInMainCity" .. tostring(canReport))
      if canReport then
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.ActionInMainCity, 0, logic_main_city_achievement_task_report.actionList.AddMCFriendInMC, true)
      end
    end
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.MainCityInfoCard, uidList, callback)
  end
end
function logic_main_city_achievement_task_report.ReportSpeakOnMCChannelInMainCity()
  if GameStatus.IsInMainCity() and logic_main_city_achievement_task_report.isClickMainCityChanel then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ActionInMainCity, 0, logic_main_city_achievement_task_report.actionList.speakOnMCChannel, true)
  end
end
function logic_main_city_achievement_task_report.ReportInviteFriend()
  if GameStatus.IsInMainCity() then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ActionInMainCity, 0, logic_main_city_achievement_task_report.actionList.InviteFriend, true)
  end
end
function logic_main_city_achievement_task_report.ClickStartGameInMainCity(isStart)
  log(bWriteLog and "logic_main_city_achievement_task_report:ClickStartGameInMainCity" .. tostring(isStart))
  if not isStart then
    logic_main_city_achievement_task_report.isClickStartGameInMainCity = false
    return
  end
  if GameStatus.IsInMainCity() then
    logic_main_city_achievement_task_report.isClickStartGameInMainCity = true
  else
    logic_main_city_achievement_task_report.isClickStartGameInMainCity = false
  end
end
function logic_main_city_achievement_task_report.ClickMainCityChanel(isMCChanel)
  logic_main_city_achievement_task_report.isClickMainCityChanel = isMCChanel
end
function logic_main_city_achievement_task_report._CheckFriendInMainCity(StatusList)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if GameStatus.IsInMainCity() then
    for _, status in pairs(StatusList) do
      log_tree("logic_main_city_achievement_task_report._CheckFriendInMainCity", status)
      local isInMainCity = PlayerStatusUtil.IsMainCity(status)
      log(bWriteLog and "logic_main_city_achievement_task_report.ReportAddFriendInMainCity" .. tostring(isInMainCity))
      return isInMainCity
    end
  end
  return false
end
return logic_main_city_achievement_task_report