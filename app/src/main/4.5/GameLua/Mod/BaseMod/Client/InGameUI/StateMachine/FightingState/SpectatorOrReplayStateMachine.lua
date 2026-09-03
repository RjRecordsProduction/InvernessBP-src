local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local SpectatorOrReplayStateMachine = {}
local StateNameConfig = {
  "DummyState",
  "NormalSpectatorState",
  "HawkEyeSpectatorState",
  "DeathPlaybackState",
  "WonderfulPlaybackState"
}
function SpectatorOrReplayStateMachine:ctor()
  self.StateName = "SpectatorOrReplayStateMachine"
  self.bIsEnterPetSpectating = false
  self.CurrentState = nil
  for _, Key in pairs(StateNameConfig) do
    local StatePath = GamePlayTools.GetModPath(true, string.format("Client.InGameUI.StateMachine.FightingState.%s", Key), true)
    local StateMudule = require(StatePath)
    if StateMudule then
      self.StateInstanceConfig[Key] = StateMudule()
    end
  end
end
function SpectatorOrReplayStateMachine:Enter()
  SpectatorOrReplayStateMachine.__super.Enter(self)
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorReplayChanged, self)
  if slua.isValid(Bridge) then
    self:AddControlEvent(Bridge, "OnPlayReplayBegin", self.OnSpectatorReplayChanged, self)
    self:AddControlEvent(Bridge, "OnPlayReplayEnd", self.OnSpectatorReplayChanged, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnSpectatorReplayChanged, self)
  self:OnStateChange()
end
function SpectatorOrReplayStateMachine:OnSpectatorReplayChanged()
  self:OnStateChange()
end
function SpectatorOrReplayStateMachine:OnStateChange()
  local GameplayStatics = import("GameplayStatics")
  local PlayerController = GameplayStatics.GetPlayerController(CGameWorld, 0)
  if not slua.isValid(PlayerController) then
    return
  end
  local CurrentStateName = self:GetCurrentStateName()
  print(bWriteLog and "SpectatorOrReplayStateMachine:OnStateChange", CurrentStateName)
  if self.CurrentState then
    self.CurrentState:Exit()
  end
  self.CurrentState = self.StateInstanceConfig[CurrentStateName]
  self.CurrentState:Enter()
end
function SpectatorOrReplayStateMachine:GetCurrentStateName()
  local CurrentStateName = "DummyState"
  local GameplayStatics = import("GameplayStatics")
  local PlayerController = GameplayStatics.GetPlayerController(CGameWorld, 0)
  if not slua.isValid(PlayerController) then
    return CurrentStateName
  end
  if PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_WonderfulPlayback) then
    CurrentStateName = "WonderfulPlaybackState"
  elseif PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_DeathPlayback) then
    CurrentStateName = "DeathPlaybackState"
  elseif PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_HawkEye) then
    CurrentStateName = "HawkEyeSpectatorState"
  elseif PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_InSpectating) then
    CurrentStateName = "NormalSpectatorState"
  end
  return CurrentStateName
end
function SpectatorOrReplayStateMachine:Exit()
  if self.CurrentState then
    self.CurrentState:Exit()
    self.CurrentState = nil
  end
  SpectatorOrReplayStateMachine.__super.Exit(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateMachine")
return class(CDelegateContainer, nil, SpectatorOrReplayStateMachine)