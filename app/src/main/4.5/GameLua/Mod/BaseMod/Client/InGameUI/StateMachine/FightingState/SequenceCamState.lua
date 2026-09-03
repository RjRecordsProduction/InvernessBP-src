local EWidgetVisible = import("EWidgetVisible")
local SequenceCamState = {}
function SequenceCamState:ctor()
  self.StateName = "SequenceCamState"
end
function SequenceCamState:Enter()
  SequenceCamState.__super.Enter(self)
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
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.OnTurnplateBtnTouchEnd then
    MainControlBaseUI:OnTurnplateBtnTouchEnd()
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:ExitFreeCamera(true)
  end
  local uPlayerCharacter = GameplayData.GetLocalCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter.bIsHideCrossHairType = true
  end
end
function SequenceCamState:Exit()
  SequenceCamState.__super.Exit(self)
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
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:ExitFreeCamera(true)
  end
  local uPlayerCharacter = GameplayData.GetLocalCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter.bIsHideCrossHairType = false
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, SequenceCamState)