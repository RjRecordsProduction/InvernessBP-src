local logic_ping_delay_report = {}
local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
function logic_ping_delay_report:OnInitialize()
  logic_ping_delay_report.__super.OnInitialize(self)
  local LobbyPingCheckNum = CDataTable.GetTableData("ParamConfig", "LobbyPingCheckNum")
  if LobbyPingCheckNum and LobbyPingCheckNum.ParamValue then
    self.MaxDelayPing = LobbyPingCheckNum.ParamValue
  else
    self.MaxDelayPing = 200
  end
  log(bWriteLog and "logic_ping_delay_report:OnInitialize MaxDelayPing = " .. tostring(self.MaxDelayPing))
  local LobbyPingCheckTime = CDataTable.GetTableData("ParamConfig", "LobbyPingCheckTime")
  if LobbyPingCheckTime and LobbyPingCheckTime.ParamValue then
    self.MaxDelayCount = LobbyPingCheckTime.ParamValue
  else
    self.MaxDelayCount = 5
  end
  log(bWriteLog and "logic_ping_delay_report:OnInitialize MaxDelayCount = " .. tostring(self.MaxDelayCount))
  self.DelayCount = 0
  self.bReport = false
end
function logic_ping_delay_report:OnLogOut()
  self:ResetData()
  self.bReport = false
end
function logic_ping_delay_report:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_ping_delay_report:OnPostSwitchGameStatus nextState = " .. tostring(nextState))
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_ping_delay_report:OnPostSwitchGameStatus next is not equal Lobby")
    self:ResetData()
    return
  end
  if self.bReport then
    log(bWriteLog and "logic_ping_delay_report:OnPostSwitchGameStatus this login has been reported")
    return
  end
  local time_ticker = require("common.time_ticker")
  self.ReportPingDelayTimer = time_ticker.AddTimerLoop(TIMER_INFINITE, function()
    local zoneID = ZoneSystem.nChooseZoneID
    if zoneID == nil or zoneID == 0 then
      return
    end
    local delay = logic_zone_delay.GetChoosenZoneDelay(360, 10000)
    if delay and self.MaxDelayPing and delay >= self.MaxDelayPing then
      self.DelayCount = self.DelayCount + 1
    else
      self.DelayCount = 0
    end
    log(bWriteLog and "logic_ping_delay_report:OnPostSwitchGameStatus delay = " .. tostring(delay) .. " DelayCount = " .. tostring(self.DelayCount))
    if self.MaxDelayCount and self.DelayCount >= self.MaxDelayCount then
      log(bWriteLog and "logic_ping_delay_report:OnPostSwitchGameStatus Report ping delay")
      self:ResetData()
      self.bReport = true
      local PingHander = require("client.network.Protocol.PingHander")
      PingHander.send_report_lobby_ping_bad_req()
    end
  end, TIMER_INFINITE, 5)
end
function logic_ping_delay_report:ResetData()
  log(bWriteLog and "logic_ping_delay_report:ResetData")
  self.DelayCount = 0
  if self.ReportPingDelayTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.ReportPingDelayTimer)
    self.ReportPingDelayTimer = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_ping_delay_report)
return CModuleTemplate