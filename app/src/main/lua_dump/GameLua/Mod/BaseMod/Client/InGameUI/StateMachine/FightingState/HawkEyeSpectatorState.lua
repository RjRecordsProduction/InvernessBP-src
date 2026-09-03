local HawkEyeSpectatorState = {}
function HawkEyeSpectatorState:Enter()
  HawkEyeSpectatorState.__super.Enter(self)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  uPlayerController.CharacterTouchMove = true
end
local class = require("class")
local NormalSpectatorStateClass = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.FightingState.NormalSpectatorState")
return class(NormalSpectatorStateClass, nil, HawkEyeSpectatorState)