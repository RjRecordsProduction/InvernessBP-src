local logic_bind_discord = {}
function logic_bind_discord.ResetData()
  logic_bind_discord.activityData = nil
  logic_bind_discord.missionData = nil
end
function logic_bind_discord.InitData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.BindDiscord)
  log_tree("xcc logic_bind_discord.InitData activityData", activityData)
  local StringUtil = require("common.string_util")
  for index, activity in pairs(activityData) do
    local conditions = StringUtil.Split(activity.Condition, ",")
    local channel = conditions and conditions[1] or 0
    if tonumber(channel) == BP_ENUM_IMSDK_CHANNEL_DISCORD then
      logic_bind_discord.activityData = activity
      logic_bind_discord.missionData = activity and activity.List and activity.List[1]
      break
    end
  end
  log(bWriteLog and "xcc logic_bind_discord.InitData logic_bind_discord.activityData", logic_bind_discord.activityData)
end
function logic_bind_discord.GetActivityData()
  if not logic_bind_discord.activityData then
    logic_bind_discord.InitData()
  end
  return logic_bind_discord.activityData
end
function logic_bind_discord.GetMissionData()
  if not logic_bind_discord.missionData then
    logic_bind_discord.InitData()
  end
  return logic_bind_discord.missionData
end
function logic_bind_discord.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    local timeIndex = 0
    local time_ticker = require("common.time_ticker")
    timeIndex = time_ticker.AddTimerOnce(2.5, function()
      if logic_bind_discord.CheckActState() then
        log(bWriteLog and "[bgp] logic_bind_discord.OnModePostSwitch")
        logic_bind_discord.RegistEventByActChange()
      end
    end)
  elseif nextState == GameStatus.Login then
    logic_bind_discord.UnRegistEventActChange()
    logic_bind_discord.ResetData()
  elseif GameStatus.IsInFightingNotMainCity() then
    logic_bind_discord.UnRegistEventActChange()
    logic_bind_discord.ResetData()
  end
end
function logic_bind_discord.CheckActShowAndState()
  local state = logic_bind_discord.CheckActState()
  if state and state == ActivityProgressStatus.Not then
    local channel_util = require("client.logic.setting.bind.channel_util")
    return channel_util.CanShowLogin(ShareSource.Discord)
  end
  return false
end
function logic_bind_discord.CheckBindItemTip(channel)
  if channel == ShareSource.Discord then
    local state = logic_bind_discord.CheckActState()
    if state and state == ActivityProgressStatus.Not then
      return true
    end
  end
  return false
end
function logic_bind_discord.CheckActState()
  if not logic_bind_discord.missionData then
    logic_bind_discord.InitData()
  end
  if not logic_bind_discord.CheckActTime() then
    return nil
  end
  return logic_bind_discord.missionData and logic_bind_discord.missionData.Status or nil
end
function logic_bind_discord.CheckActTime()
  local data = logic_bind_discord.GetActivityData()
  if not data then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  if data.StartTime and data.StartTime > 0 and data.EndTime and 0 < data.EndTime and nNowTime > data.StartTime and nNowTime < data.EndTime then
    return true
  elseif data.StartTime and data.StartTime > 0 and nNowTime > data.StartTime then
    return true
  elseif data.EndTime and 0 < data.EndTime and nNowTime < data.EndTime then
    return true
  end
  return false
end
function logic_bind_discord.RegistEventByActChange()
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, logic_bind_discord.OnActivityDataChanged)
end
function logic_bind_discord.UnRegistEventActChange()
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, logic_bind_discord.OnActivityDataChanged)
end
function logic_bind_discord.OnActivityDataChanged(eventType, eventID, act_change_list)
  if act_change_list and act_change_list.typeList then
    local data = logic_bind_discord.GetActivityData()
    for actType, _ in pairs(act_change_list.typeList) do
      if data.Type == actType and data.tabType ~= ActivitySwitchType.None then
        local state = logic_bind_discord.CheckActState()
        local bShow = state and state ~= ActivityProgressStatus.Get or false
        local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
        local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
        local RedDotType = bShow and ActivityMacros.RedDotType.Reward or ActivityMacros.RedDotType.None
        ActivityCenterModule:SetExternalImageRedDot(data.ID, false, bShow, RedDotType)
        return
      end
    end
  end
end
function logic_bind_discord.ClickActEnterance()
  local data = logic_bind_discord.GetActivityData()
  if not data or data.tabType == ActivitySwitchType.None then
    return
  end
  local state = logic_bind_discord.CheckActState()
  local isShow = state and state ~= ActivityProgressStatus.Get or false
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = isShow and ActivityMacros.RedDotType.Reward or ActivityMacros.RedDotType.None
  ActivityCenterModule:SetExternalImageRedDot(data.ID, false, isShow, RedDotType)
end
function logic_bind_discord.GetAwardBySendRsp()
  local mission = logic_bind_discord.GetMissionData()
  if mission and mission.Status and mission.Status == 1 then
    mission.Status = 2
  end
end
return logic_bind_discord