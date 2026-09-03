local EPawnState = import("EPawnState")
local EStateType = import("EStateType")
local EGameModeType = import("EGameModeType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local STExtraGameplayStatics = import("STExtraGameplayStatics")
local FightingStateStateMachine = {}
local StateNameConfig = {
  "TeamShowState",
  "SwimState",
  "DivingState",
  "DeadState",
  "DeadStateForNoHideUI",
  "ParachuteState",
  "NormalFightingState",
  "VehicleStateMachine",
  "PetSpectatorState",
  "NormalSpectatorState",
  "HawkEyeSpectatorState",
  "BattleResultState",
  "SpectatorOrReplayStateMachine",
  "JumpShowState",
  "LifterControlState",
  "SequenceCamState"
}
function FightingStateStateMachine:ctor()
  self.StateName = "FightingStateStateMachine"
  self.CurrentState = nil
  self.bEnterVehicle = false
  self.bEnterTeamShow = false
  self.bIsOnBattleResult = false
  self.bIsOnResultCountdown = false
  self.PawnCurrentStates = -1
  self.bIsEnterPetSpectating = false
  self.bIsInSpectatorReplayState = false
  self.bEnterJumpShowState = false
  self.bIsInLifterControlState = false
  self.bEnterSequenceCam = false
  for _, Key in pairs(StateNameConfig) do
    local StatePath = GamePlayTools.GetModPath(true, string.format("Client.InGameUI.StateMachine.FightingState.%s", Key), true)
    local StateMudule = require(StatePath)
    if StateMudule then
      self.StateInstanceConfig[Key] = StateMudule()
    end
  end
end
function FightingStateStateMachine:Enter()
  FightingStateStateMachine.__super.Enter(self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTTYPE_PLAYEREVENT_PAWN_ENTER_STATE_SWIM, self.OnSwimStateChange, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTTYPE_PLAYEREVENT_PAWN_LEAVE_STATE_SWIM, self.OnSwimStateChange, self)
  GameplayData.AddSelfPlayerControllerEventWithCondition(self, "OnCharacterStatesChangeWithFilterState", {
    State = {
      EPawnState.Diving
    }
  }, self.OnDivingStateChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorReplayChanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", self.HandlePlayerControllerStateChanged, self)
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  if slua.isValid(Bridge) then
    self:AddControlEvent(Bridge, "OnPlayReplayBegin", self.OnSpectatorReplayChanged, self)
    self:AddControlEvent(Bridge, "OnPlayReplayEnd", self.OnSpectatorReplayChanged, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_START, self.OnResultCountdownStart, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END, self.OnResultCountdownEnd, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnEnterBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_STOP_PROCESS, self.BattleResultStopProcess, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_CONTINUE_PROCESS, self.OnEnterBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_WOW_BATTLE_RESULT_ENTER, self.OnEnterWowBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_WOW_BATTLE_RESULT_EXIT, self.OnExitWowBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_TEAM_SHOW, self.OnExitTeamShow, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_TEAM_SHOW, self.OnEnterTeamShow, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_SEQUENCE_CAM, self.OnExitSequenceCam, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_SEQUENCE_CAM, self.OnEnterSequenceCam, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnSpectatorReplayChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET, self.EnterPetSpectating, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_UNPOSSESSONPET, self.ExitPetSpectating, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnCharacterNearDeathOrRescueingOtherNotifyDelegate", self.OnHealthStatusChangeDelegate, self)
  self:AddUIMessageEvent("UIMsgEnterVehicleCompleted", self.EnterVehicle, self)
  self:AddUIMessageEvent("UIMsgExitVehicleCompleted", self.ExitVehicle, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterJumpShow", self.OnEnterJumpShowState, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerExitJumpShow", self.OnExitJumpShowState, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTTYPE_PLAYEREVENT_LIFTER_CONTROL_STATE_CHANGED, self.OnLifterControlStateChanged, self)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator then
    self.bIsEnterPetSpectating = PlayerController:IsInPetSpectator()
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    self.PawnCurrentStates = PlayerCharacter.CurrentStates
  end
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController2 = UGameplayStatics.GetPlayerController(CGameWorld, 0)
  if slua.isValid(PlayerController2) then
    local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
    self.bIsInSpectatorReplayState = PlayerController2:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay)
  end
  self:OnFightingStateChange()
  self:CheckOnVehicle()
  print(bWriteLog and "FightingStateStateMachine:Enter End")
end
function FightingStateStateMachine:GetVehicleUserComponent()
  print(bWriteLog and "FightingStateStateMachine: GetVehicleUserComponent")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "FightingStateStateMachine: GetVehicleUserComponent PlayerController nil")
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "FightingStateStateMachine: GetVehicleUserComponent VehicleUserComponent nil")
    return nil
  end
  return VehicleUserComponent
end
local GetStateName = function(State)
  if State and State.StateName then
    return State.StateName
  end
  return "None"
end
function FightingStateStateMachine:HandlePlayerControllerStateChanged()
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnEnterJumpShowState()
  print(bWriteLog and "FightingStateStateMachine:OnEnterJumpShowState")
  self.bEnterJumpShowState = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnExitJumpShowState()
  print(bWriteLog and "FightingStateStateMachine:OnExitJumpShowState")
  self.bEnterJumpShowState = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnLifterControlStateChanged(_, __, IsEnter)
  self.bIsInLifterControlState = IsEnter
  print(bWriteLog and string.format("FightingStateStateMachine:OnLifterControlStateChanged %s", IsEnter))
  self:OnFightingStateChange()
end
function FightingStateStateMachine:EnterVehicle()
  print(bWriteLog and "FightingStateStateMachine:EnterVehicle")
  self.bEnterVehicle = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:ExitVehicle()
  print(bWriteLog and "FightingStateStateMachine:ExitVehicle")
  self.bEnterVehicle = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnResultCountdownStart()
  print(bWriteLog and "FightingStateStateMachine:OnResultCountdownStart")
  self.bIsOnResultCountdown = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnResultCountdownEnd()
  print(bWriteLog and "FightingStateStateMachine:OnResultCountdownEnd")
  self.bIsOnResultCountdown = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnEnterBattleResult()
  print(bWriteLog and "FightingStateStateMachine:OnEnterBattleResult")
  self.bIsOnBattleResult = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnEnterWowBattleResult()
  print(bWriteLog and "FightingStateStateMachine:OnEnterWowBattleResult")
  self.bIsOnBattleResult = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnExitWowBattleResult()
  print(bWriteLog and "FightingStateStateMachine:OnExitWowBattleResult")
  self.bIsOnBattleResult = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:BattleResultStopProcess()
  print(bWriteLog and "FightingStateStateMachine:BattleResultStopProcess")
  self.bIsOnBattleResult = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:BattleResultContinueProcess()
  print(bWriteLog and "FightingStateStateMachine:BattleResultContinueProcess")
  self.bIsOnBattleResult = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnEnterTeamShow()
  print(bWriteLog and "FightingStateStateMachine:OnEnterTeamShow")
  self.bEnterTeamShow = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnExitTeamShow()
  print(bWriteLog and "FightingStateStateMachine:OnExitTeamShow")
  self.bEnterTeamShow = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnEnterSequenceCam()
  print(bWriteLog and "FightingStateStateMachine:OnEnterSequenceCam")
  self.bEnterSequenceCam = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnExitSequenceCam()
  print(bWriteLog and "FightingStateStateMachine:OnExitSequenceCam")
  self.bEnterSequenceCam = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnReconnect()
  if not self.CurrentState then
    return
  end
  print(bWriteLog and string.format("FightingStateStateMachine:OnReconnect State:%s", GetStateName(self.CurrentState)))
  self:OnFightingStateChange(true)
  self:CheckOnVehicle()
end
function FightingStateStateMachine:CheckOnVehicle()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
    if VehicleUserComponent.VehicleUserState == ESTExtraVehicleUserState.EVUS_AsDriver or VehicleUserComponent.VehicleUserState == ESTExtraVehicleUserState.EVUS_ASPassenger then
      print(bWriteLog and "FightingStateStateMachine:CheckOnVehicle EnterVehicle 0")
      self:EnterVehicle()
    end
  end
end
function FightingStateStateMachine:OnSwimStateChange(_, __, Character, PawnState, bSwimming)
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnDivingStateChange()
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnSpectatorReplayChanged()
  self.bIsInSpectatorReplayState = false
  local GameplayStatics = import("GameplayStatics")
  local PlayerController = GameplayStatics.GetPlayerController(CGameWorld, 0)
  if slua.isValid(PlayerController) then
    local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
    self.bIsInSpectatorReplayState = PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator) or PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Replay)
  end
  self:OnFightingStateChange()
end
function FightingStateStateMachine:EnterPetSpectating()
  print(bWriteLog and "FightingStateStateMachine:EnterPetSpectating")
  self.bIsEnterPetSpectating = true
  self:OnFightingStateChange()
end
function FightingStateStateMachine:ExitPetSpectating()
  print(bWriteLog and "FightingStateStateMachine:ExitPetSpectating")
  self.bIsEnterPetSpectating = false
  self:OnFightingStateChange()
end
function FightingStateStateMachine:OnHealthStatusChangeDelegate()
  self:OnFightingStateChange()
end
function FightingStateStateMachine:CanGotoBattleResultState()
  return self.bIsOnBattleResult and not self.bIsOnResultCountdown
end
function FightingStateStateMachine:CanGotoPetSpectatorState()
  return self.bIsEnterPetSpectating
end
function FightingStateStateMachine:CanGotoSpectatorOrReplayStateMachine()
  return self.bIsInSpectatorReplayState
end
function FightingStateStateMachine:CanGotoTeamShowState()
  return self.bEnterTeamShow
end
function FightingStateStateMachine:CanGotoSequenceCamState()
  return self.bEnterSequenceCam
end
function FightingStateStateMachine:CanGotoJumpShowState()
  return self.bEnterJumpShowState
end
function FightingStateStateMachine:CanGotoLifterControlState()
  return self.bIsInLifterControlState
end
function FightingStateStateMachine:CanGotoVehicleStateMachine()
  return self.bEnterVehicle
end
function FightingStateStateMachine:CanGotoDeadState()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  if PlayerCharacter.HealthStatus == ECharacterHealthStatus.FinishedLastBreath or PlayerCharacter.HealthStatus == ECharacterHealthStatus.WaitingForRevival then
    return true
  end
  return false
end
function FightingStateStateMachine:CanGotoDeadStateForNoHideUI()
  if not self:HideUIAfterDeadWithMod() then
    return true
  end
  return false
end
function FightingStateStateMachine:HideUIAfterDeadWithMod()
  local IsHide = self:HideUIAfterDead()
  if not IsHide then
    return false
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  if PlayerCharacter:GetAttrValue("RevivalCount") > 1.0E-4 then
    return false
  else
    return true
  end
end
function FightingStateStateMachine:HideUIAfterDead()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.GameModeType == nil then
    return true
  end
  local GameModeType = GameState.GameModeType
  if GameModeType == EGameModeType.EWarGameMode or GameModeType == EGameModeType.EDeathMatchGameMode or GameModeType == EGameModeType.EFourInOneGameMode then
    return false
  end
  return true
end
function FightingStateStateMachine:CanGotoSwimState()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  local EStateType = import("EStateType")
  if PlayerCharacter:HasState(EPawnState.Swim) then
    return true
  end
  return false
end
function FightingStateStateMachine:CanGotoParachuteState()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local EStateType = import("EStateType")
  local CurrentControllerstateType = PlayerController:GetCurrentStateType()
  if CurrentControllerstateType == EStateType.State_InPlane or CurrentControllerstateType == EStateType.State_InExPlane or CurrentControllerstateType == EStateType.State_ParachuteJump or CurrentControllerstateType == EStateType.State_ParachuteOpen or CurrentControllerstateType == EStateType.State_Launch then
    return true
  end
  return false
end
function FightingStateStateMachine:CanGotoDivingState()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  if PlayerCharacter:HasState(EPawnState.Diving) then
    return true
  end
  return false
end
function FightingStateStateMachine:OnFightingStateChange(bReconnect)
  self:OnFightingStateChangeInternal(bReconnect)
end
function FightingStateStateMachine:OnFightingStateChangeInternal(bReconnect)
  local CurrentStateName = self:GetCurrentStateName(bReconnect)
  self:TryChangeState(CurrentStateName, bReconnect)
end
function FightingStateStateMachine:GetCurrentStateName(bReconnect)
  local CurrentStateName = "NormalFightingState"
  if self:CanGotoBattleResultState() then
    CurrentStateName = "BattleResultState"
  elseif self:CanGotoPetSpectatorState() then
    CurrentStateName = "PetSpectatorState"
  elseif self:CanGotoSpectatorOrReplayStateMachine() then
    CurrentStateName = "SpectatorOrReplayStateMachine"
  elseif self:CanGotoTeamShowState() then
    CurrentStateName = "TeamShowState"
  elseif self:CanGotoSequenceCamState() then
    CurrentStateName = "SequenceCamState"
  elseif self:CanGotoVehicleStateMachine() then
    CurrentStateName = "VehicleStateMachine"
  elseif self:CanGotoJumpShowState() then
    CurrentStateName = "JumpShowState"
  elseif self:CanGotoLifterControlState() then
    CurrentStateName = "LifterControlState"
  elseif self:CanGotoDeadState() then
    CurrentStateName = "DeadState"
    if self:CanGotoDeadStateForNoHideUI() then
      CurrentStateName = "DeadStateForNoHideUI"
    end
  elseif self:CanGotoSwimState() then
    CurrentStateName = "SwimState"
  elseif self:CanGotoDivingState() then
    CurrentStateName = "DivingState"
  elseif self:CanGotoParachuteState() then
    CurrentStateName = "ParachuteState"
  else
    CurrentStateName = "NormalFightingState"
  end
  return CurrentStateName
end
function FightingStateStateMachine:TryChangeState(StateName, bReconnect)
  print(bWriteLog and string.format("FightingStateStateMachine:TryChangeState %s %s", StateName, bReconnect))
  if self.CurrentState == self.StateInstanceConfig[StateName] and bReconnect ~= true then
    return
  end
  local OldState = self.CurrentState
  local OldStateName = self.CurrentStateName
  self.CurrentState = self.StateInstanceConfig[StateName]
  self.Current  print(bWriteLog and string.format("FightingStateStateMachine:TryChangeState State:%s->%s bReconnect=%s", GetStateName(OldState), GetStateName(self.CurrentState), tostring(bReconnect or false)))
  if OldState then
    OldState:Exit()
  end
  if self.CurrentState then
    self.CurrentState:Enter(bReconnect)
  end
  self:OnPlayerUIStateChange(OldStateName, self.CurrentStateName, bReconnect)
end
local UIStateIDs = {
  NormalFightingState = 0,
  BattleResultState = 1,
  PetSpectatorState = 2,
  SpectatorOrReplayStateMachine = 3,
  TeamShowState = 4,
  VehicleStateMachine = 5,
  JumpShowState = 6,
  LifterControlState = 7,
  DeadState = 8,
  DeadStateForNoHideUI = 9,
  SwimState = 10,
  DivingState = 11,
  ParachuteState = 12,
  DeadGhostState = 13,
  DummyState = 14,
  NormalSpectatorState = 15,
  HawkEyeSpectatorState = 16
}
function FightingStateStateMachine:OnPlayerUIStateChange(OldStateName, CurrentStateName, bReconnect)
  local OldStateID = OldStateName and UIStateIDs[OldStateName] or -1
  local CurrentStateID = CurrentStateName and UIStateIDs[CurrentStateName] or -1
  print(bWriteLog and "FightingStateStateMachine:OnPlayerUIStateChange", OldStateName, OldStateID, CurrentStateName, CurrentStateID, bReconnect)
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  if GameReportUtils then
    GameReportUtils.ReplayReportData(1, {
      OldStateID,
      CurrentStateID,
      bReconnect and 1 or 0
    })
  end
end
function FightingStateStateMachine:Exit()
  FightingStateStateMachine.__super.Exit(self)
  if self.CurrentState then
    self.CurrentState:Exit()
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateMachine")
return class(CDelegateContainer, nil, FightingStateStateMachine)