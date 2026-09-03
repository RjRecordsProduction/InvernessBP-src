local PMGCEntrySystem = {}
local PMGCEntryInfo = {}
function PMGCEntrySystem.InitConfig()
  if PMGCEntryInfo and next(PMGCEntryInfo) then
    return
  end
  PMGCEntryInfo = {}
  local TimeUtil = require("client.common.time_util")
  local data = CDataTable.GetTableData("PMGCLobbyEntryTimeTable", 2022)
  if data then
    PMGCEntryInfo = {
      openTime = TimeUtil.TimeStringToUnixstamp(data.openTime or ""),
      liveStartTime1 = TimeUtil.TimeStringToUnixstamp(data.liveStartTime1 or ""),
      liveEndTime1 = TimeUtil.TimeStringToUnixstamp(data.liveEndTime1 or ""),
      liveStartTime2 = TimeUtil.TimeStringToUnixstamp(data.liveStartTime2 or ""),
      liveEndTime2 = TimeUtil.TimeStringToUnixstamp(data.liveEndTime2 or ""),
      endTime = TimeUtil.TimeStringToUnixstamp(data.endTime or ""),
      closeTime = TimeUtil.TimeStringToUnixstamp(data.closeTime or "")
    }
  end
end
function PMGCEntrySystem.GetLobbyMainUI()
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  return lobbyMainUI
end
function PMGCEntrySystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
  end
end
function PMGCEntrySystem.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, PMGCEntrySystem.OnNextDayZeroCome)
end
function PMGCEntrySystem.OnNextDayZeroCome()
end
function PMGCEntrySystem.IsPMGCEntryOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_MODULE_PMGC_SWITCH) then
    return false
  end
  if not next(PMGCEntryInfo) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local result = TimeUtil.UnixTimeBetween(PMGCEntryInfo.openTime, PMGCEntryInfo.closeTime)
  if result ~= 0 then
    return false
  end
  return true
end
function PMGCEntrySystem.IsShowLive()
  local TimeUtil = require("client.common.time_util")
  local result = TimeUtil.UnixTimeBetween(PMGCEntryInfo.liveStartTime1, PMGCEntryInfo.liveEndTime1)
  if result == 0 then
    return true
  end
  result = TimeUtil.UnixTimeBetween(PMGCEntryInfo.liveStartTime2, PMGCEntryInfo.liveEndTime2)
  if result == 0 then
    return true
  end
  result = PMGCEntryInfo.endTime
  local now = TimeUtil.GetServerTimeInSec()
  if result < now then
    return true
  end
  return false
end
function PMGCEntrySystem.GetOnLiveStartTime()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if now <= PMGCEntryInfo.liveStartTime1 then
    return TimeUtil.FormatCountDownTime_D_or_HMS(PMGCEntryInfo.liveStartTime1 - now)
  end
  if now >= PMGCEntryInfo.liveEndTime1 and now <= PMGCEntryInfo.liveStartTime2 then
    return TimeUtil.FormatCountDownTime_D_or_HMS(PMGCEntryInfo.liveStartTime2 - now)
  end
  if now >= PMGCEntryInfo.liveEndTime2 and now <= PMGCEntryInfo.endTime then
    return TimeUtil.FormatCountDownTime_D_or_HMS(PMGCEntryInfo.endTime - now)
  end
  return TimeUtil.FormatCountDownTime_D_or_HMS(PMGCEntryInfo.endTime - now)
end
function PMGCEntrySystem.CheckAndAddPMGCEntryUI()
  local lobbyMainUI = PMGCEntrySystem.GetLobbyMainUI()
  if not lobbyMainUI then
    return
  end
  if PMGCEntrySystem.IsPMGCEntryOpen() then
    lobbyMainUI:AddChildUI("Border_PMGC", UIManager.UI_Config.Lobby_Mid_PMGC_UIBP)
  elseif lobbyMainUI:GetChildUI(UIManager.UI_Config.Lobby_Mid_PMGC_UIBP) then
    lobbyMainUI:CloseChildUI(UIManager.UI_Config.Lobby_Mid_PMGC_UIBP)
  end
end
return PMGCEntrySystem