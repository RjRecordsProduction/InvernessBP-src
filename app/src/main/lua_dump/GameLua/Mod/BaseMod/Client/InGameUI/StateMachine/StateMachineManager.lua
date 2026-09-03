local EStateType = import("EStateType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local StateMachineManager = {}
function StateMachineManager:ctor()
  self.CurrentStateMachine = nil
  self.StateMachineInstanceConfig = {}
  local FightingStateStateMachinePath = GamePlayTools.GetModPath(true, "Client.InGameUI.StateMachine.FightingStateStateMachine", true)
  local StateMudule = require(FightingStateStateMachinePath)
  if StateMudule then
    self.StateMachineInstanceConfig.FightingState = StateMudule()
  end
  self.StateMachineInstanceConfig.ActiveState = self.StateMachineInstanceConfig.FightingState
  self.StateMachineInstanceConfig.ReadyState = self.StateMachineInstanceConfig.FightingState
  self.StateMachineInstanceConfig.FightingState = self.StateMachineInstanceConfig.FightingState
end
function StateMachineManager:OnInit()
  print(bWriteLog and "StateMachineManager:OnInit")
  self:RegistEvents()
end
function StateMachineManager:RegistEvents()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStateChange", self.OnGameModeStateChangedNative, self)
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameModeState ~= nil then
    self:OnGameModeStateChangedNative(GameState.GameModeState)
  end
end
function StateMachineManager:GetFightState()
  return self.StateMachineInstanceConfig.FightingState
end
function StateMachineManager:OnGameModeStateChangedNative(GameModeState)
  if not self.StateMachineInstanceConfig[GameModeState] then
    return
  end
  if self.CurrentStateMachine == self.StateMachineInstanceConfig[GameModeState] then
    return
  end
  if self.CurrentStateMachine then
    self.CurrentStateMachine:Exit()
  end
  self.CurrentStateMachine = self.StateMachineInstanceConfig[GameModeState]
  self.CurrentStateMachine:Enter()
end
function StateMachineManager:OnRelease()
  if self.CurrentStateMachine then
    self.CurrentStateMachine:Exit()
  end
  for _, StateMachineInstance in pairs(self.StateMachineInstanceConfig) do
    StateMachineInstance:OnRelease()
  end
  self.CurrentStateMachine = nil
  self.StateMachineInstanceConfig = {}
  StateMachineManager.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, StateMachineManager)