local ClientDataStatistcsSubsystem = {}
function ClientDataStatistcsSubsystem:OnInit()
  local BattlePingCheckNum = CDataTable.GetTableData("ParamConfig", "BattlePingCheckNum")
  if BattlePingCheckNum and BattlePingCheckNum.ParamValue then
    self.MaxDelayPing = BattlePingCheckNum.ParamValue
  else
    self.MaxDelayPing = 200
  end
  local BattlePingCheckTime = CDataTable.GetTableData("ParamConfig", "BattlePingCheckTime")
  if BattlePingCheckTime and BattlePingCheckTime.ParamValue then
    self.MaxDelayCount = tonumber(BattlePingCheckTime.ParamValue) or 5
  else
    self.MaxDelayCount = 5
  end
  print(bWriteLog and "ClientDataStatistcsSubsystem:OnInit", self.MaxDelayPing, self.MaxDelayCount)
  self.DelayCount = 0
  self.bReport = false
  self:StartToCheck()
end
function ClientDataStatistcsSubsystem:OnRelease()
  print(bWriteLog and "ClientDataStatistcsSubsystem:OnRelease")
  self:ResetData()
  ClientDataStatistcsSubsystem.__super.OnRelease(self)
end
function ClientDataStatistcsSubsystem:StartToCheck()
  if self.bReport or Client.IsWindowOB() then
    return
  end
  self.ReportPingDelayTimer = self:AddGameTimer(5, true, function()
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not (slua.isValid(uPlayerController) and uPlayerController.GetCurPlayerState) or not self then
      return
    end
    local PS = uPlayerController:GetCurPlayerState()
    if slua.isValid(PS) and PS.Ping and self.MaxDelayPing and tonumber(self.MaxDelayPing) and PS.Ping * 4 > tonumber(self.MaxDelayPing) then
      self.DelayCount = self.DelayCount + 1
      print(bWriteLog and "ClientDataStatistcsSubsystem check long ping", PS.Ping, self.DelayCount)
    else
      self.DelayCount = 0
    end
    if self.MaxDelayCount and self.DelayCount >= self.MaxDelayCount then
      print(bWriteLog and "ClientDataStatistcsSubsystem Report ping delay")
      self:ResetData()
      self.bReport = true
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "LongPingCnt", 1)
    end
  end)
end
function ClientDataStatistcsSubsystem:ResetData()
  self.DelayCount = 0
  if self.ReportPingDelayTimer then
    self:RemoveGameTimer(self.ReportPingDelayTimer)
    self.ReportPingDelayTimer = nil
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientDataStatistcsSubsystem)