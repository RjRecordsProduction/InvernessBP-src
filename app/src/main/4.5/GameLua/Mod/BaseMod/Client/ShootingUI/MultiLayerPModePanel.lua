local MultiLayerPModePanel = {}
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESTEPoseState = import("ESTEPoseState")
local EPawnState = import("EPawnState")
function MultiLayerPModePanel:ctor(_)
  print(bWriteLog and "MultiLayerPModePanel:ctor")
  self.bShowInit = false
end
function MultiLayerPModePanel:OnInitialize()
  print(bWriteLog and "MultiLayerPModePanel:OnInitialize")
end
function MultiLayerPModePanel:OnInitShow()
  print(bWriteLog and "MultiLayerPModePanel:OnInitialize")
  if self.bShowInit then
    return
  end
  self.bShowInit = true
  self:HandleSwitchPModeVisibility()
end
function MultiLayerPModePanel:RegistEvents()
  print(bWriteLog and "MultiLayerPModePanel:RegistEvents")
  self:AddUIMessageEvent("UIMsg_FPPModeChange", self.UIMsg_FPPModeChange, self)
  self:AddUIMessageEvent("UIMsg_ScopeChanged", self.UIMsg_ScopeChanged, self)
  self:AddUIMessageEvent("PersonPerspectiveChanged", self.PersonPerspectiveChanged, self)
  self:AddControlEventByControl(self.UIRoot.Button_SwitchPMode, "OnClicked", self.OnClickedSwitchPMode, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "ClientOnEnterVehicle", self.UIMsg_FPPModeChange, self)
  GameplayData.AddSelfPlayerControllerEventWithCondition(self, "OnCharacterStatesChangeWithFilterState", {
    State = {
      EPawnState.SwitchPP
    }
  }, self.UIMsg_FPPModeChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnPerspectiveChanged", self.PersonPerspectiveChanged, self)
  self:AddCommonEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_CONTROL_PANEL_SHOW, self.HandleVehicleControlPanelShow, self)
  self:AddCommonEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_CONTROL_PANEL_HIDE, self.HandleVehicleControlPanelHide, self)
end
function MultiLayerPModePanel:OnPlayerCharacterChange(_, PlayerCharacter)
  self:UIMsg_FPPModeChange()
end
function MultiLayerPModePanel:Show()
  print(bWriteLog and "MultiLayerPModePanel:Show")
  MultiLayerPModePanel.__super.Show(self)
end
function MultiLayerPModePanel:Collapsed()
  print(bWriteLog and "MultiLayerPModePanel:Collapsed")
  MultiLayerPModePanel.__super.Collapsed(self)
end
function MultiLayerPModePanel:OnShow()
  print(bWriteLog and "MultiLayerPModePanel:OnShow")
  self:OnInitShow()
end
function MultiLayerPModePanel:OnHide()
  print(bWriteLog and "MultiLayerPModePanel:OnHide")
end
function MultiLayerPModePanel:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "MultiLayerPModePanel:Reconnect_ResetUIByPlayerControllerState")
  self:PersonPerspectiveChanged()
end
function MultiLayerPModePanel:PersonPerspectiveChanged()
  print(bWriteLog and "MultiLayerPModePanel:PersonPerspectiveChanged")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "MultiLayerPModePanel:PersonPerspectiveChanged not uPlayerCharacter")
    return
  end
  if PlayerCharacter.IsFPP then
    self.UIRoot.TextBlock_PmodeName:SetText(LocUtil.GetLocalizeResStr(100054))
  else
    self.UIRoot.TextBlock_PmodeName:SetText(LocUtil.GetLocalizeResStr(100053))
  end
end
function MultiLayerPModePanel:OnClickedSwitchPMode()
  print(bWriteLog and "MultiLayerPModePanel:OnClickedSwitchPMode")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "MultiLayerPModePanel:PersonPerspectiveChanged not uPlayerCharacter")
    return
  end
  self:ChangeCharacterPerspective(not PlayerCharacter.IsFPP)
end
function MultiLayerPModePanel:UIMsg_ScopeChanged()
  print(bWriteLog and "MultiLayerPModePanel:UIMsg_ScopeChanged")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "MultiLayerPModePanel:UIMsg_ScopeChanged not uPlayerCharacter")
    return
  end
  if PlayerCharacter.bIsGunADS or self:OnJaguarBlockTransaction() then
    self.UIRoot.CanvasPanel_PMode:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_PMode:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function MultiLayerPModePanel:OnJaguarBlockTransaction()
  print(bWriteLog and "MultiLayerPModePanel:OnJaguarBlockTransaction")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "MultiLayerPModePanel:OnJaguarBlockTransaction not uGameState")
    return false
  end
  return not GameState.IsCanSwitchFPP
end
function MultiLayerPModePanel:HandleSwitchPModeVisibility()
  print(bWriteLog and "MultiLayerPModePanel:HandleSwitchPModeVisibility")
  self:AddSettingOptionEvent("FpViewSwitch", function(bFpp)
    print(bWriteLog and "MultiLayerPModePanel:AddOptionValueChangeEvent", bFpp)
    self:RefreshSwitchPMode(bFpp)
  end, true)
end
function MultiLayerPModePanel:UIMsg_FPPModeChange()
  print(bWriteLog and "MultiLayerPModePanel:UIMsg_FPPModeChange")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "MultiLayerPModePanel:UIMsg_FPPModeChange not GameState")
    return
  end
  if GameState.IsFPPGameMode then
    self.UIRoot.Canvas_FPPModeControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:ShowFirstTimeTips()
  else
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) or not PlayerController.GetCurPlayerCharacter then
      self.UIRoot.Canvas_FPPModeControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      print(bWriteLog and "MultiLayerPModePanel:UIMsg_FPPModeChange not slua.isValid(uPlayerController)")
      return
    end
    local PlayerCharacter = PlayerController:GetCurPlayerCharacter()
    if not slua.isValid(PlayerCharacter) then
      print(bWriteLog and "MultiLayerPModePanel:UIMsg_FPPModeChange not uPlayerCharacter")
      self.UIRoot.Canvas_FPPModeControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    local Visibility = UEnums.ESlateVisibility.Collapsed
    if PlayerCharacter:AllowState(EPawnState.SwitchPP, true) then
      Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
    end
    local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
    local uVehicleUserComp = PlayerController.BP_VehicleUser
    if slua.isValid(uVehicleUserComp) and uVehicleUserComp.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_OutOfVehicle and slua.isValid(uVehicleUserComp.Vehicle) and uVehicleUserComp.Vehicle.ForceUseTPP then
      Visibility = UEnums.ESlateVisibility.Collapsed
    end
    if self.UIRoot and self.UIRoot.Canvas_FPPModeControl then
      self.UIRoot.Canvas_FPPModeControl:SetWidgetVisibility(Visibility)
    end
  end
end
function MultiLayerPModePanel:RefreshSwitchPMode(FpViewSwitch)
  print(bWriteLog and "MultiLayerPModePanel:RefreshSwitchPMode", FpViewSwitch)
  local GameState = slua_GameFrontendHUD:GetGameState()
  if self.UIRoot and self.UIRoot.PMode_ScopeControl then
    if FpViewSwitch and slua.isValid(GameState) and GameState.IsCanSwitchFPP then
      self.UIRoot.PMode_ScopeControl:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.PMode_ScopeControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if not FpViewSwitch then
    self:ChangeCharacterPerspective(false)
  end
end
function MultiLayerPModePanel:ShowFirstTimeTips()
  local EDeathMatchSubModeType = import("EDeathMatchSubModeType")
  local Settingconfig = slua_GameFrontendHUD:GetUserSettings()
  if not Settingconfig or not Settingconfig.FirstTime_FPP_TPP then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not (GameState and slua.isValid(GameState)) or not GameState.IsFPPGameMode then
    return
  end
  if GameState.DeathMatchSubModeType ~= EDeathMatchSubModeType.DeathMatch then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.bIsForReplay then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.FirstTimeTipsFPP)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  Settingconfig.FirstTime_FPP_TPP = false
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function MultiLayerPModePanel:HandleVehicleControlPanelShow(_, _, InVehicle)
  print(bWriteLog and "MultiLayerPModePanel:HandleVehicleControlPanelShow", InVehicle)
  self:UIMsg_FPPModeChange()
end
function MultiLayerPModePanel:HandleVehicleControlPanelHide()
  print(bWriteLog and "MultiLayerPModePanel:HandleVehicleControlPanelHide")
  self:UIMsg_FPPModeChange()
end
function MultiLayerPModePanel:ChangeCharacterPerspective(bFirst)
  print(bWriteLog and "MultiLayerPModePanel:ChangeCharacterPerspective", bFirst)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeCharacterPerspective(bFirst)
  end
end
function MultiLayerPModePanel:OnClose()
  print(bWriteLog and "MultiLayerPModePanel:OnClose")
  MultiLayerPModePanel.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CMultiLayerPModePanel = class(ui_base, nil, MultiLayerPModePanel)
return CMultiLayerPModePanel