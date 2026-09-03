local DeadState = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function DeadState:ctor()
  self.StateName = "DeadState"
end
function DeadState:Enter()
  DeadState.__super.Enter(self)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:MainControlPanel_HideAllUI()
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaHideJoystickWidgetWithTag("DeadState")
    PlayerController.CharacterTouchMove = false
    PlayerController.IgnoreCameraMovingIndexArray:Clear()
    PlayerController:SetVirtualStickAutoSprintStatus(false)
    local HUD = PlayerController:GetHUD()
    if slua.isValid(HUD) then
      HUD:SetActorHiddenInGame(true)
    end
    IngameTipsTools.ClearBattleGeneralTip()
  end
end
function DeadState:Exit()
  DeadState.__super.Exit(self)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:MainControlPanel_ShowAllUI()
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) then
    sandbox.LogError("DeadState:Exit uPlayerController InValid")
    return
  end
  if PlayerController.ShowTouchInterface == nil then
    sandbox.LogError("DeadState:Exit uPlayerController not have ShowTouchInterface")
    return
  end
  PlayerController:LuaShowJoystickWidgetWithTag("DeadState")
  PlayerController.CharacterTouchMove = true
  local HUD = PlayerController:GetHUD()
  if slua.isValid(HUD) then
    HUD:SetActorHiddenInGame(false)
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, DeadState)