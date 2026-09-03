local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local DeathPlaybackState = {}
function DeathPlaybackState:ctor()
  self.StateName = "DeathPlaybackState"
end
local CloseUIConfig = {
  "BackpackClothingEntryUI"
}
function DeathPlaybackState:Enter()
  print(bWriteLog and "DeathPlaybackState:Enter")
  DeathPlaybackState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:LuaHideJoystickWidgetWithTag("DeathPlaybackState")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:MainControlPanel_HideAllUI()
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_SpectatingControl then
    MainControlBaseUI.Emote_SpectatingControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if UIManager and UIManager.UI_Config_InGame then
    for i, UIConfigName in ipairs(CloseUIConfig) do
      if CloseUIConfig and UIManager.UI_Config_InGame[UIConfigName] and UIManager.GetUI(UIManager.UI_Config_InGame[UIConfigName]) then
        UIManager.CloseUI(UIManager.UI_Config_InGame[UIConfigName])
      end
    end
  end
end
function DeathPlaybackState:Exit()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWidgetWithTag("DeathPlaybackState")
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:MainControlPanel_ShowAllUI()
    end
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_SpectatingControl then
    MainControlBaseUI.Emote_SpectatingControl:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  DeathPlaybackState.__super.Exit(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, DeathPlaybackState)