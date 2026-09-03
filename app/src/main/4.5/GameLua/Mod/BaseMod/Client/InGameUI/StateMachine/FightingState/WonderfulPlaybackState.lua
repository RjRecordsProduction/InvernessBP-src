local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local WonderfulPlaybackState = {}
function WonderfulPlaybackState:ctor()
  self.StateName = "DeathPlayback"
end
local CloseUIConfig = {
  "BackpackClothingEntryUI",
  "QuickExpressionDecalUI"
}
function WonderfulPlaybackState:Enter()
  print(bWriteLog and "WonderfulPlaybackState:Enter")
  WonderfulPlaybackState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:LuaHideJoystickWidgetWithTag("WonderfulPlaybackState")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:MainControlPanel_HideAllUI()
    MainControlPanelTochButton:ShowCompletePlaybackUI()
    if MainControlPanelTochButton.VehicleControlLayer then
      MainControlPanelTochButton.VehicleControlLayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_FreeCamera then
    MainControlBaseUI.CanvasPanel_FreeCamera:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if UIManager and UIManager.UI_Config_InGame then
    for i, UIConfigName in ipairs(CloseUIConfig) do
      if CloseUIConfig and UIManager.UI_Config_InGame[UIConfigName] and UIManager.GetUI(UIManager.UI_Config_InGame[UIConfigName]) then
        UIManager.CloseUI(UIManager.UI_Config_InGame[UIConfigName])
      end
    end
  end
end
function WonderfulPlaybackState:Exit()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWidgetWithTag("WonderfulPlaybackState")
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:MainControlPanel_ShowAllUI()
    end
  end
  WonderfulPlaybackState.__super.Exit(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, WonderfulPlaybackState)