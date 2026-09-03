local EWidgetVisible = import("EWidgetVisible")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local TeamShowState = {}
function TeamShowState:ctor()
  self.StateName = "TeamShowState"
end
function TeamShowState:Enter()
  TeamShowState.__super.Enter(self)
  local GameFrontendHUD = slua_GameFrontendHUD:GetUtils()
  if GameFrontendHUD then
    local DefaultContainer = GameFrontendHUD:GetGlobalUIContainer("Default")
    if DefaultContainer then
      DefaultContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local BottomContainer = GameFrontendHUD:GetGlobalUIContainer("Bottom")
    if BottomContainer then
      BottomContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) then
    if PlayerController.LuaHideJoystickWidgetWithTag then
      PlayerController:LuaHideJoystickWidgetWithTag("TeamShowState")
    end
    PlayerController.CharacterTouchMove = false
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.OnTurnplateBtnTouchEnd then
    MainControlBaseUI:OnTurnplateBtnTouchEnd()
  end
end
function TeamShowState:Exit()
  TeamShowState.__super.Exit(self)
  local GameFrontendHUD = slua_GameFrontendHUD:GetUtils()
  if GameFrontendHUD then
    local DefaultContainer = GameFrontendHUD:GetGlobalUIContainer("Default")
    if DefaultContainer then
      DefaultContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    local BottomContainer = GameFrontendHUD:GetGlobalUIContainer("Bottom")
    if BottomContainer then
      BottomContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) then
    sandbox.LogError("TeamShowState:Exit uPlayerController InValid")
    return
  end
  if PlayerController.ShowTouchInterface == nil then
    sandbox.LogError("TeamShowState:Exit uPlayerController not have ShowTouchInterface")
    return
  end
  if PlayerController.LuaShowJoystickWidgetWithTag then
    PlayerController:LuaShowJoystickWidgetWithTag("TeamShowState")
  end
  PlayerController.CharacterTouchMove = true
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, TeamShowState)