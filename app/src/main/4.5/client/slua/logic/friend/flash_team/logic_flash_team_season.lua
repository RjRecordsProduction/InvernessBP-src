local logic_flash_team_season = {}
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local TimeUtil = require("client.common.time_util")
logic_flash_team_season.ReminderType = {
  Lobby_Tips_Remind = "Lobby_Tips_Remind",
  TeamList_ShowLevel_Remind = "TeamList_ShowLevel_Remind",
  TeamMain_ShowSeason_Remind = "TeamMain_ShowSeason_Remind",
  TeamMain_Effect_Remind = "TeamMain_Effect_Remind"
}
function logic_flash_team_season:OnInitialize()
  self.ReminderFileType = PlayerPrefsSystem.ePlayerPrefsType.FlashTeamSeasonRemind
end
function logic_flash_team_season:GetCurSeasonId()
  if not self.SeasonBaseTable then
    self.SeasonBaseTable = CDataTable.GetTable("SeasonInfo")
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  for _, seasonData in pairs(self.SeasonBaseTable) do
    local beginTime = seasonData.StartTime and TimeUtil.TimeStringToUnixstamp(seasonData.StartTime)
    local endTime = seasonData.EndTime and TimeUtil.TimeStringToUnixstamp(seasonData.EndTime)
    if beginTime and endTime and currentTime >= beginTime and currentTime <= endTime then
      return seasonData.SeasonID
    end
  end
  return 0
end
function logic_flash_team_season:GetCurSeasonName()
  if not self.SeasonBaseTable then
    self.SeasonBaseTable = CDataTable.GetTable("SeasonInfo")
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  for _, seasonData in pairs(self.SeasonBaseTable) do
    local beginTime = seasonData.StartTime and TimeUtil.TimeStringToUnixstamp(seasonData.StartTime)
    local endTime = seasonData.EndTime and TimeUtil.TimeStringToUnixstamp(seasonData.EndTime)
    if beginTime and endTime and currentTime >= beginTime and currentTime <= endTime then
      return seasonData.SeasonNameNew
    end
  end
  return 0
end
function logic_flash_team_season:CheckAndHandleSeasonTransition(curSeasonId)
  local currentSeasonId = curSeasonId or self:GetCurSeasonId()
  if not currentSeasonId or currentSeasonId <= 0 then
    return false
  end
  local reminderData = PlayerPrefsSystem.LoadFileToTable_N(self.ReminderFileType) or {}
  local storedSeasonId = reminderData.lastSeasonId or 0
  if currentSeasonId ~= storedSeasonId then
    log(bWriteLog and string.format("logic_flash_team_season:CheckAndHandleSeasonTransition Season transition detected! From %d to %d", storedSeasonId, currentSeasonId))
    self:ResetRemindersForNewSeason(currentSeasonId)
    return true
  end
  return false
end
function logic_flash_team_season:HasRemindedThisSeason(remindType)
  self:CheckAndHandleSeasonTransition()
  local reminderData = PlayerPrefsSystem.LoadFileToTable_N(self.ReminderFileType)
  if not reminderData or not reminderData.reminders then
    return false
  end
  return reminderData.reminders[remindType] or false
end
function logic_flash_team_season:MarkAsRemindedThisSeason(remindType)
  local currentSeasonId = self:GetCurSeasonId()
  self:CheckAndHandleSeasonTransition(currentSeasonId)
  if not currentSeasonId or currentSeasonId <= 0 then
    return
  end
  local reminderData = PlayerPrefsSystem.LoadFileToTable_N(self.ReminderFileType) or {}
  if not reminderData.reminders then
    reminderData.reminders = {}
  end
  if reminderData.lastSeasonId == currentSeasonId and reminderData.reminders[remindType] then
    return
  else
    log(bWriteLog and string.format("logic_flash_team_season:MarkAsRemindedThisSeason Marked reminder '%s' as shown for season %d", remindType, currentSeasonId))
  end
  reminderData.lastSeasonId = currentSeasonId
  reminderData.reminders[remindType] = true
  reminderData.lastUpdateTime = TimeUtil.GetServerTimeInSec()
  PlayerPrefsSystem.SaveTableToFile_N(reminderData, self.ReminderFileType)
end
function logic_flash_team_season:ResetRemindersForNewSeason(newSeasonId)
  local reminderData = {
    lastSeasonId = newSeasonId,
    reminders = {},
    resetTime = TimeUtil.GetServerTimeInSec(),
    seasonStartTime = TimeUtil.GetServerTimeInSec()
  }
  PlayerPrefsSystem.SaveTableToFile_N(reminderData, self.ReminderFileType)
  log(bWriteLog and string.format("logic_flash_team_season:ResetRemindersForNewSeason Reset all reminders for new season %d", newSeasonId))
end
function logic_flash_team_season:CheckAndExecuteReminder(remindType, reminderCallback)
  local currentSeasonId = self:GetCurSeasonId()
  local isNewSeason = self:CheckAndHandleSeasonTransition(currentSeasonId)
  if currentSeasonId <= 0 then
    return false
  end
  if not self:HasRemindedThisSeason(remindType) then
    log(bWriteLog and string.format("logic_flash_team_season:CheckAndExecuteReminder Reminding seasonId:%s remindType:%s", currentSeasonId, remindType))
    if reminderCallback and type(reminderCallback) == "function" then
      local success = reminderCallback()
      if success then
        self:MarkAsRemindedThisSeason(remindType)
        return true
      end
    end
  end
  return false
end
function logic_flash_team_season:GetSeasonInfo()
  local currentSeasonId = self:GetCurSeasonId()
  local reminderData = PlayerPrefsSystem.LoadFileToTable_N(self.ReminderFileType) or {}
  return {
    currentSeasonId = currentSeasonId,
    storedSeasonId = reminderData.lastSeasonId or 0,
    isNewSeason = currentSeasonId ~= (reminderData.lastSeasonId or 0),
    reminders = reminderData.reminders or {},
    lastResetTime = reminderData.resetTime,
    seasonStartTime = reminderData.seasonStartTime
  }
end
function logic_flash_team_season:ForceResetAllReminders()
  local currentSeasonId = self:GetCurSeasonId()
  self:ResetRemindersForNewSeason(currentSeasonId)
  log(bWriteLog and string.format("logic_flash_team_season:ForceResetAllReminders Force reset all reminders for season %d", currentSeasonId))
end
function logic_flash_team_season:IsInSeasonCoolDownPeriod()
  log(bWriteLog and "SeasonSystem:IsInSeasonCoolDownPeriod")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local logic_season_config = require("client.logic.season.logic_season_config")
  local seasonConfig = logic_season_config.SeasonConfig
  if not seasonConfig or not next(seasonConfig) then
    return nil
  end
  local seasonIds = {}
  for seasonId, _ in pairs(seasonConfig) do
    table.insert(seasonIds, tonumber(seasonId))
  end
  table.sort(seasonIds)
  for i = 1, #seasonIds - 1 do
    local currentSeasonId = seasonIds[i]
    local nextSeasonId = seasonIds[i + 1]
    local currentSeason = seasonConfig[currentSeasonId]
    local nextSeason = seasonConfig[nextSeasonId]
    if currentSeason and nextSeason then
      local seasonEndTime = currentSeason.end_timestamp
      local nextSeasonStartTime = nextSeason.begin_timestamp
      if currentTime > seasonEndTime and currentTime < nextSeasonStartTime then
        local coolDownDuration = nextSeasonStartTime - seasonEndTime
        if 7200 <= coolDownDuration then
          return nextSeasonId
        end
      end
    end
  end
  local lastSeasonId = seasonIds[#seasonIds]
  local lastSeason = seasonConfig[lastSeasonId]
  if lastSeason and currentTime > lastSeason.end_timestamp then
    return lastSeasonId + 1
  end
  return nil
end
function logic_flash_team_season:GetSeasonTimeStr()
  local logic_season_config = require("client.logic.season.logic_season_config")
  local seasonId = self:GetCurSeasonId()
  local SeasonCfg = logic_season_config.GetSeasonConfig(seasonId)
  local seasonTime = ""
  if SeasonCfg then
    local TimeUtil = require("client.common.time_util")
    seasonTime = TimeUtil.FormatTime_timeFrame(SeasonCfg.begin_timestamp, SeasonCfg.end_timestamp, false, true)
  end
  return seasonTime
end
function logic_flash_team_season:ClearSeasonRemindKey()
  PlayerPrefsSystem.SaveTableToFile_N({}, self.ReminderFileType)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_flash_team_season)