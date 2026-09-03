local BattleResultProcessBaseLogic = {}
function BattleResultProcessBaseLogic:OnBaseInit(battleResultSubSystem)
  self.BattleResultSubSystem = battleResultSubSystem
  self.USE_TEST = battleResultSubSystem.ResusltTest
  self.CurResultProcessIndex = -1
  self:OnInit()
end
function BattleResultProcessBaseLogic:OnBaseRelease()
  self:OnRelease()
  self:Dispose()
  self.BattleResultSubSystem = nil
  self.CurResultProcessIndex = -1
end
function BattleResultProcessBaseLogic:StartResultProcess(index)
  local utility = require("common.utility")
  if not self:OnSwitchCheck() then
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, self.ProcessName, UEnums.BattleResultProcessEndReason.SwitchCheckFailed)
    return false
  end
  self.CurResultProcessIndex = index
  if not self:OnResultProcessStart() then
    self.CurResultProcessIndex = -1
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, self.ProcessName, UEnums.BattleResultProcessEndReason.ProcessStartFailed)
    return false
  end
  print(bWriteLog and "BattleResultProcessBaseLogic:StartResultProcess", self.ProcessName)
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_START_PHASE, self.ProcessName)
  return true
end
function BattleResultProcessBaseLogic:EndResultProcess()
  self:OnResultProcessEnd()
  self.BattleResultSubSystem:EndResultProcess(self)
  print(bWriteLog and "BattleResultProcessBaseLogic:EndResultProcess", self.ProcessName)
  local utility = require("common.utility")
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, self.ProcessName, UEnums.BattleResultProcessEndReason.Normal)
  self.CurResultProcessIndex = -1
end
function BattleResultProcessBaseLogic:ResultProcessExecuting()
  return self.CurResultProcessIndex ~= -1
end
function BattleResultProcessBaseLogic:OnSwitchCheck()
  return true
end
function BattleResultProcessBaseLogic:OnInit()
end
function BattleResultProcessBaseLogic:OnRelease()
end
function BattleResultProcessBaseLogic:OnBattleResult(result)
end
function BattleResultProcessBaseLogic:OnOBBattleResult(room_result, room_stat, customize_result)
end
function BattleResultProcessBaseLogic:OnResultProcessStart()
  return false
end
function BattleResultProcessBaseLogic:OnResultProcessEnd()
end
function BattleResultProcessBaseLogic:OnResultProcessStop(curProcessIndex)
end
function BattleResultProcessBaseLogic:OnResultProcessContinue(curProcessIndex)
end
function BattleResultProcessBaseLogic:OnPostReconnection(curProcessIndex)
  print(bWriteLog and "BattleResultProcessBaseLogic:OnPostReconnection", curProcessIndex)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
    if WatchGameUI then
      WatchGameUI:HideSpectatingUI()
    end
    if ReviveSpectateTips then
      ReviveSpectateTips.HideSpectateTipsUI()
    end
  end
end
function BattleResultProcessBaseLogic:GetBattleResultData()
  return self.BattleResultSubSystem:GetBattleResultData()
end
function BattleResultProcessBaseLogic:GetResultProcessLogic(processName)
  local proLogic = self.BattleResultSubSystem:GetResultProcessLogic(processName)
  if proLogic == nil then
    log(bWriteLog and "BattleResultProcessBaseLogic:GetResultProcessLogic is nil processName:" .. processName)
  end
  return proLogic
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBattleResultProcessBaseLogic = class(CDelegateContainer, nil, BattleResultProcessBaseLogic)
return CBattleResultProcessBaseLogic