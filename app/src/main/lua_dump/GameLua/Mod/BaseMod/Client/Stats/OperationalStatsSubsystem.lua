local KismetSystemLibrary = import("KismetSystemLibrary")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TimeInternal = 180
local OperationalStatsSubsystem = {
  StatsDataKey = {
    Crouch = "Crouch",
    Prone = "Prone",
    Jump = "Jump",
    Fire = "Fire",
    Peek = "Peek",
    Reload = "Reload",
    SwitchWeapon = "SwitchWeapon",
    Aim = "Aim",
    QuickMark = "QuickMark",
    Joystick = "Joystick"
  },
  Key2TlogID = {
    Crouch = 11839,
    Prone = 11840,
    Jump = 11841,
    Fire = 11843,
    Peek = 11844,
    Reload = 11845,
    SwitchWeapon = 11846,
    Aim = 11847,
    QuickMark = 11848,
    Joystick = 11842
  }
}
function OperationalStatsSubsystem:ctor()
  self.bTouchOnJoystick = false
  self.StartTouchTime = 0
  self.ReportRound = 0
  self.StatsData = {}
end
function OperationalStatsSubsystem:OnInit()
  local ModeID = GameMainConfig.GetModeID()
  local IsBRMode = GamePlayTools.IsBRMode(ModeID)
  log(bWriteLog and string.format("OperationalStatsSubsystem:OnInit IsBRMode = %s", IsBRMode))
  if not IsBRMode then
    return
  end
  OperationalStatsSubsystem.__super.OnInit(self)
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.HandleEnterFighting, self)
  self.TimerHandle = nil
end
function OperationalStatsSubsystem:HandleEnterFighting()
  log(bWriteLog and string.format("OperationalStatsSubsystem:HandleEnterFighting, Set Report Timer"))
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerTouchedStartInArea", self.HandleTouchBegin, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerTouchEnd", self.HandleTouchEnd, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnBattleResult, self)
  self.TimerHandle = self:AddGameTimer(TimeInternal, true, function()
    self:ReportOperationalStats(false)
  end)
end
function OperationalStatsSubsystem:OnBattleResult()
  log(bWriteLog and "OperationalStatsSubsystem:OnBattleResult, Report Last Operational Stats")
  if self.TimerHandle then
    self:RemoveGameTimer(self.TimerHandle)
    self.TimerHandle = nil
  end
  self:ReportOperationalStats(true)
end
function OperationalStatsSubsystem:HandleTouchBegin()
  if not slua.isValid(CGameState) then
    return
  end
  self.bTouchOnJoystick = true
  self.StartTouchTime = KismetSystemLibrary.GetGameTimeInSeconds(CGameState)
end
function OperationalStatsSubsystem:HandleTouchEnd()
  if not self.bTouchOnJoystick then
    return
  end
  if not slua.isValid(CGameState) then
    return
  end
  self.bTouchOnJoystick = false
  local CostTime = KismetSystemLibrary.GetGameTimeInSeconds(CGameState) - self.StartTouchTime
  self:AddOperationalStats(self.StatsDataKey.Joystick, math.floor(CostTime + 0.5))
end
function OperationalStatsSubsystem:AddOperationalStats(Key, Count)
  if not self.Key2TlogID[Key] then
    return
  end
  if not self.StatsData[Key] then
    self.StatsData[Key] = 0
  end
  self.StatsData[Key] = self.StatsData[Key] + Count
end
function OperationalStatsSubsystem:ReportOperationalStats(IsLastReport)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    log(bWriteLog and "OperationalStatsSubsystem:ReportOperationalStats, PlayerState is invalid")
    return
  end
  log_tree(bWriteLog and "OperationalStatsSubsystem:ReportOperationalStats, StatsData = ", self.StatsData)
  if not PlayerState.IsAlive then
    log(bWriteLog and "OperationalStatsSubsystem:ReportOperationalStats, IsAlive is nil")
    return
  end
  if not PlayerState:IsAlive() and next(self.StatsData) == nil then
    log(bWriteLog and "OperationalStatsSubsystem:ReportOperationalStats, PlayerState is not alive and no stats data")
    return
  end
  local KeyToIndexMap = {
    Crouch = 1,
    Prone = 2,
    Jump = 3,
    Fire = 4,
    Peek = 5,
    Reload = 6,
    SwitchWeapon = 7,
    Aim = 8,
    QuickMark = 9,
    Joystick = 10
  }
  local ArrayStatsData = {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  }
  for Key, Count in pairs(self.StatsData) do
    local index = KeyToIndexMap[Key]
    if index then
      ArrayStatsData[index] = Count
    end
  end
  if PlayerState.ServerRPC_RecordOperationCount then
    log(bWriteLog and "OperationalStatsSubsystem:ReportOperationalStats, Report Operation Send")
    PlayerState:ServerRPC_RecordOperationCount(ArrayStatsData, IsLastReport)
  end
  self.StatsData = {}
end
function OperationalStatsSubsystem:TriggerTouchStats(CustomType, TouchEventType, TouchEvent)
end
function OperationalStatsSubsystem:OnRelease()
  log(bWriteLog and "OperationalStatsSubsystem:OnRelease")
  OperationalStatsSubsystem.__super.OnRelease(self)
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, OperationalStatsSubsystem)