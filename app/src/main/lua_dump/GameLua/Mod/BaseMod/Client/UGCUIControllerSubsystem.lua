local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local BattleUIControllerConfig = require("GameLua.Mod.BaseMod.Client.Config.BattleUIControllerConfig")
local UGCUIControllerSubsystem = {}
function UGCUIControllerSubsystem:ctor()
  self.UGCSettingConfig = {}
  self.VehicleExitOperationFlag = nil
end
function UGCUIControllerSubsystem:OnInit()
  print(bWriteLog and "UGCUIControllerSubsystem:OnInit")
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW_FOR_BATTLE, self.OnHaveUIShow, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SET_BATTLE_MAIN_UI_SWITCH, self.OnSetBattleMainUISwitchHandle, self)
end
function UGCUIControllerSubsystem:OnSetBattleMainUISwitchHandle(_, __, BattleUIType, Switch)
  print(bWriteLog and "UGCUIControllerSubsystem:OnSetBattleMainUISwitchHandle BattleUIType:" .. tostring(BattleUIType) .. " Switch:" .. tostring(Switch))
  local bhide = not Switch
  self.UGCSettingConfig[BattleUIType] = Switch
  for key, value in pairs(BattleUIControllerConfig.Enum_BattleUIType) do
    if value == BattleUIType then
      local handelFuncName = "Handle" .. tostring(key)
      if self[handelFuncName] ~= nil then
        self[handelFuncName](self, bhide)
      end
    end
  end
end
function UGCUIControllerSubsystem:GetUIIsHideByBattleUIType(BattleUIType)
  local bSwitch = self.UGCSettingConfig[BattleUIType]
  if bSwitch ~= nil then
    return bSwitch == false
  end
  return false
end
function UGCUIControllerSubsystem:OnHaveUIShow(_, __, UIConfig)
  if not UIManager.UI_Config_InGame then
    return
  end
  if UIManager.UI_Config_InGame.TeamPanel and UIManager.UI_Config_InGame.TeamPanel.moduleName == UIConfig.moduleName and self.UGCSettingConfig[BattleUIControllerConfig.Enum_BattleUIType.IngameTeamPanelMain] ~= nil then
    local CurrentSetting = self.UGCSettingConfig[BattleUIControllerConfig.Enum_BattleUIType.IngameTeamPanelMain]
    self:OnSetBattleMainUISwitchHandle(_, __, BattleUIControllerConfig.Enum_BattleUIType.IngameTeamPanelMain, CurrentSetting)
  elseif UIManager.UI_Config_InGame.NavigatorPanel and UIManager.UI_Config_InGame.NavigatorPanel.moduleName == UIConfig.moduleName and self.UGCSettingConfig[BattleUIControllerConfig.Enum_BattleUIType.NavigatorPanel] ~= nil then
    local CurrentSetting = self.UGCSettingConfig[BattleUIControllerConfig.Enum_BattleUIType.NavigatorPanel]
    self:OnSetBattleMainUISwitchHandle(_, __, BattleUIControllerConfig.Enum_BattleUIType.NavigatorPanel, CurrentSetting)
  end
end
function UGCUIControllerSubsystem:HandleMiniMapAndSetting(bHide)
  local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.HideMiniMapAndSettingForUGC, bHide)
end
function UGCUIControllerSubsystem:HandleBackpackPanel(bHide)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return
  end
  local BackpackPanel = MainControlBaseUI.BackpackClothingEntryUIRoot
  if not slua.isValid(BackpackPanel) then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  BackpackPanel:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandleCircleChasingProgress(bHide)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return
  end
  local CircleChasingProgress = MainControlBaseUI.CircleChasingProgress
  if not slua.isValid(CircleChasingProgress) then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  CircleChasingProgress:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandleIngameTeamPanelMain(bHide)
  local TeamPanel = UIManager.GetUI(UIManager.UI_Config_InGame.TeamPanel)
  if not TeamPanel then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide or CGameState and CGameState.bIsCreativeWoW then
    Scale = FVector2D(0, 0)
  end
  TeamPanel.UIRoot:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandlePlayerInfoPanel(bHide)
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  local PlayerInfoPanelMain = UIManager.GetUI(UIManager.UI_Config_InGame.PlayerInfoPanelMain)
  if not PlayerInfoPanelMain then
    return
  end
  PlayerInfoPanelMain:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandleNavigatorPanel(bHide)
  local NavigatorPanel = UIManager.GetUI(UIManager.UI_Config_InGame.NavigatorPanel)
  if not NavigatorPanel then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  NavigatorPanel.UIRoot:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandleWeaponSlot(bHide)
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if not slua.isValid(ShootingUIPanel) then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  ShootingUIPanel.MultiLayer_Pistol:SetRenderScale(Scale)
  ShootingUIPanel.MultiLayer_LeftWeaponSlot:SetRenderScale(Scale)
  ShootingUIPanel.MultiLayer_RightWeaponSlot:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandleSurviveInfoPanelSurvive(bHide)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide or CGameState and CGameState.bIsCreativeWoW then
    Scale = FVector2D(0, 0)
  end
  MainControlBaseUI.CanvasPanelSurviveKill:SetRenderScale(Scale)
end
function UGCUIControllerSubsystem:HandleSurviveInfoPanelKilled(bHide)
  local SurviveInfoPanel = InGameUITools.GetSurviveInfoPanel()
  if not slua.isValid(SurviveInfoPanel) then
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide or CGameState and CGameState.bIsCreativeWoW then
    Scale = FVector2D(0, 0)
  end
  SurviveInfoPanel:SetWidgetScale("CanvasPanel_Killed", Scale)
end
function UGCUIControllerSubsystem:GetVehicleExitOperationFlag()
  return self.VehicleExitOperationFlag
end
function UGCUIControllerSubsystem:HandleVehicleExitPanel(bHide)
  self.VehicleExitOperationFlag = not bHide
  local VehicleControlUIFlag = require("GameLua.Mod.BaseMod.Client.Config.VehicleControlUIFlag")
  EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_UIVISIBILITY_CHANGED, VehicleControlUIFlag.VehicleExitOperation, self.VehicleExitOperationFlag)
end
function UGCUIControllerSubsystem:SetShootingPanelElemState(ElemItem, bShow)
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if not slua.isValid(ShootingUIPanel) then
    return
  end
  if ShootingUIPanel[ElemItem] then
    local Scale = FVector2D(1, 1)
    if not bShow then
      Scale = FVector2D(0, 0)
    end
    ShootingUIPanel[ElemItem]:SetRenderScale(Scale)
  end
end
function UGCUIControllerSubsystem:HandleClimbButton(bHide)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerPawn) and uPlayerPawn.bVaultBtnIsHideFlag ~= nil then
    uPlayerPawn.bVaultBtnIsHideFlag = -1
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_VAULT_UIVISIBILITY_CHANGED, bHide)
end
function UGCUIControllerSubsystem:HandleJumpButton(bHide)
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_JUMP_UIVISIBILITY_CHANGED, bHide)
end
function UGCUIControllerSubsystem:HandleBuffListPanel(bNotUseTwoBox)
  print(bWriteLog and "UGCUIControllerSubsystem:HandleBuffListPanel", bNotUseTwoBox)
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UPDATE_BUFFLIST_MODE, not bNotUseTwoBox)
end
function UGCUIControllerSubsystem:OnRelease()
  self.UGCSettingConfig = {}
  UGCUIControllerSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, UGCUIControllerSubsystem)