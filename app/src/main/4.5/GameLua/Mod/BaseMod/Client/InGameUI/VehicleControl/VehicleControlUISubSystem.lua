local VehicleControlUISubSystem = {}
local VehicleControlUIConfig = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
local VehicleMotorbikeComponentClass = import("VehicleMotorbikeComponent")
local VehicleCabrioletComponentClass = import("VehicleCabrioletComponent")
local ParseConfig = function(Config, uVehicle)
  local _UIConfig, _UIConfigKey
  if type(Config) == "table" then
    _UI    _UIConfigKey = _UIConfig.keyName
  elseif type(Config) == "string" then
    _UIConfig = UIManager.UI_Config_InGame[Config]
    if _UIConfig == nil and slua.isValid(uVehicle) then
      _UIConfig = uVehicle:GetUIConfig()
      if _UIConfig == nil then
        log_error(bWriteLog and "VehicleControlUISubSystem ParseConfig uVehicle:GetUIConfig == nil, please add your derived function")
      end
      UIManager.UI_Config_InGame[Config] = _UIConfig
      UIManager.ProcessOneConfig(Config, _UIConfig)
    end
    _UIConfigKey = Config
  end
  if Client.IsDevelopment() then
    if not _UIConfig then
      log_error(bWriteLog and string.format("VehicleControlUISubSystem ParseConfig%s cannot find uiconfig", tostring(Config)))
    end
    if not _UIConfigKey then
      log_error(bWriteLog and string.format("VehicleControlUISubSystem ParseConfig %s cannot find keyname", tostring(Config)))
    end
  end
  return _UIConfig, _UIConfigKey
end
function VehicleControlUISubSystem:ctor()
  print(bWriteLog and "VehicleControlUISubSystem:ctor")
  local super_data = require("common.super_data")
  self.Data = super_data.CreateSuperData({IsShowEntireMap = false})
  self.ChangeSkinMarkTime = 0
  self._RefCountMap = {}
  self._VehicleQueue = {}
  self.GeneralVehicleMode = 3
  self._VehicleModeInUsing = false
  self.bIsDriver = false
end
function VehicleControlUISubSystem:OnRegister()
  self:RegistEvents()
end
function VehicleControlUISubSystem:GetSuperData()
  return self.Data
end
function VehicleControlUISubSystem:OnRelease()
  print(bWriteLog and "VehicleControlUISubSystem:OnRelease")
  self:CloseVehicleControlPanel()
  self.uViewCurrentPlayerCharacter = nil
  local TableUtil = require("common.table_util")
  TableUtil.Clear(self._VehicleQueue)
  if self._RefCountMap then
    for UIConfigKey, RefCount in pairs(self._RefCountMap) do
      print(bWriteLog and "VehicleControlUISubSystem:OnRelease remove " .. (UIConfigKey or "nil"))
      self:RemoveVehicleControlUI(UIConfigKey)
    end
    TableUtil.Clear(self._RefCountMap)
  end
  VehicleControlUISubSystem.__super.OnRelease(self)
end
function VehicleControlUISubSystem:GetVehicleControlPanel(bNeedCreate)
  local VehicleControlPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlPanel)
  if not VehicleControlPanel and bNeedCreate then
    print(bWriteLog and "VehicleControlUISubSystem:GetVehicleControlPanel Create")
    VehicleControlPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.VehicleControlPanel)
  end
  return VehicleControlPanel
end
function VehicleControlUISubSystem:CloseVehicleControlPanel()
  print(bWriteLog and "VehicleControlUISubSystem:CloseVehicleControlPanel")
  local VehicleControlPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlPanel)
  if VehicleControlPanel then
    VehicleControlPanel:Collapsed()
  end
end
function VehicleControlUISubSystem:RegistEvents()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChange_Handle, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnFreeViewChangedDelegate", self.OnFreeViewChangedDelegate_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.OnPlayerQuitSpectatingForClient_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET, self.OnPlayerQuitSpectatingForClient_Handle, self)
  self:AddUIMessageEvent("UIMsg_VehicleShowDoorBtnPanel", self.UIMsg_VehicleShowDoorBtnPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT, self.OnShowAllUIForDelayResult, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_AVATAR_CHANGE_MSG, self.InitVehicleAvatarUIByEvent, self)
  if EVENTTYPE_SOCIAL_ISLAND and EVENTID_RACING_INGAME_CHANGE then
    self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_RACING_INGAME_CHANGE, self.OnRacingIngameChange, self)
  end
  self:AddSettingOptionEvent("VehicleControlMode", function(VehicleControlMode)
    self.GeneralVehicleMode = VehicleControlMode
    if self.bIsDriver then
      self:CheckSpecificVehicleModeChange()
    end
    if self._OnVehicle and not self.bIsDriver then
      local Vehicle = self:GetCurVehicle()
      if slua.isValid(Vehicle) then
        local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
        if CustomLayoutModule then
          CustomLayoutModule:SwapVehicleSlotByMode(self:GetSpecificVehicleMode(Vehicle))
        end
      end
    end
  end, true)
end
function VehicleControlUISubSystem:OnRacingIngameChange(_, _, bIngame)
  print(bWriteLog and "VehicleControlUISubSystem:OnRacingIngameChange", bIngame)
  local VehicleControlPanel = self.GetVehicleControlPanel(false)
  if not VehicleControlPanel then
    print(bWriteLog and "VehicleControlUISubSystem:InitVehicleAvatarUIByEvent nil")
    return
  end
  VehicleControlPanel:OnRacingIngameChange(bIngame)
end
function VehicleControlUISubSystem:ShowVehicleControlLayer()
  print(bWriteLog and "VehicleControlUISubSystem:ShowVehicleControlLayer")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.VehicleControlLayer then
    MainControlPanelTochButton.VehicleControlLayer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function VehicleControlUISubSystem:HideVehicleControlLayer()
  print(bWriteLog and "VehicleControlUISubSystem:HideVehicleControlLayer")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.VehicleControlLayer then
    MainControlPanelTochButton.VehicleControlLayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function VehicleControlUISubSystem:UIMsg_VehicleShowDoorBtnPanel()
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_DOOR_BTN_PANEL)
end
function VehicleControlUISubSystem:InitVehicleAvatarUIByEvent(_, _, ...)
end
function VehicleControlUISubSystem:GetControlUIConfig(uVehicle)
  if not slua.isValid(uVehicle) then
    return
  end
  if uVehicle.GetDynamicVehicleControlUIConfig then
    return uVehicle:GetDynamicVehicleControlUIConfig()
  end
  local _ControlUIConfig = VehicleControlUIConfig[uVehicle.VehicleType]
  if _ControlUIConfig == nil then
    _ControlUIConfig = uVehicle.GetVehicleControlUIConfig and uVehicle:GetVehicleControlUIConfig()
    if _ControlUIConfig == nil then
      log_error(bWriteLog and "VehicleControlUISubSystem:ShowDriverUI Vehicle:GetVehicleControlUIConfig == nil, please add your derived function")
    end
    VehicleControlUIConfig[uVehicle.VehicleType] = _ControlUIConfig
  end
  return _ControlUIConfig
end
function VehicleControlUISubSystem:ShowDriverUI()
  local VehicleControlPanel = self:GetVehicleControlPanel(true)
  if not VehicleControlPanel then
    print(bWriteLog and "VehicleControlUISubSystem:ShowDriverUI cont find VehicleControlPanel")
    return
  end
  VehicleControlPanel:SelfHitTestInvisible()
  print(bWriteLog and "VehicleControlUISubSystem:ShowDriverUI")
  self.bIsDriver = true
  self._OnVehicle = true
  local VehicleUserComponent = self:GetVehicleUserComponent()
  local Vehicle = slua.isValid(VehicleUserComponent) and VehicleUserComponent.Vehicle
  if slua.isValid(Vehicle) then
    local _ControlUIConfig = self:GetControlUIConfig(Vehicle)
    if _ControlUIConfig == nil then
      _ControlUIConfig = Vehicle:GetVehicleControlUIConfig()
      if _ControlUIConfig == nil then
      end
      VehicleControlUIConfig[Vehicle.VehicleType] = _ControlUIConfig
    end
    print(bWriteLog and "VehicleControlUISubSystem:ShowDriverUI Vehicle " .. Vehicle.VehicleType)
    if _ControlUIConfig and _ControlUIConfig.HideAllVehicleUI then
      self:DisableTouchBehaviour()
      VehicleControlPanel:Collapsed()
      return
    else
      VehicleControlPanel:ShowVehicleControlGUI(true)
    end
    self:NewVehicleInQueue(Vehicle.VehicleType, 1)
    if _ControlUIConfig then
      self:SwitchControlUIByMode(self:GetSpecificVehicleMode(Vehicle))
      if _ControlUIConfig.DriverUIGroup then
        for _, ConfigKey in ipairs(_ControlUIConfig.DriverUIGroup) do
          self:AddVehicleControlUI(ConfigKey)
        end
      end
      if _ControlUIConfig.CommonUIGroup then
        for _, ConfigKey in ipairs(_ControlUIConfig.CommonUIGroup) do
          self:AddVehicleControlUI(ConfigKey, true)
        end
      end
    else
      self:SwitchControlUIByMode(self.GeneralVehicleMode)
      self:AddVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUISpeed)
      local VehicleMotorbikeComponent = Vehicle:GetComponentByClass(VehicleMotorbikeComponentClass)
      if slua.isValid(VehicleMotorbikeComponent) then
        self:AddVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUIBike)
      end
      if Vehicle.ShowUpDownGUI then
        self:AddVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUIVTOL)
      end
      if slua.isValid(Vehicle.NeutralThrottleComp) then
        self:AddVehicleControlUI(UIManager.UI_Config_InGame.BoomThrottleUI)
      end
      local VehicleCabrioletComponent = Vehicle:GetComponentByClass(VehicleCabrioletComponentClass)
      if slua.isValid(VehicleCabrioletComponent) then
        self:AddVehicleControlUI(UIManager.UI_Config_InGame.CabrioletUI)
      end
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if not PublishRegionMacros.IsCEVersion() then
        self:AddVehicleControlUI(UIManager.UI_Config_InGame.PanoramicSunroofUI)
      end
      self:AddVehicleControlUI(UIManager.UI_Config_InGame.VehicleHybridUI)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_VEHICLE_CONTROL_UI_SHOW, self.bIsDriver)
end
function VehicleControlUISubSystem:ShowPassengerUI()
  local VehicleControlPanel = self:GetVehicleControlPanel(true)
  if not VehicleControlPanel then
    print(bWriteLog and "VehicleControlPanel:ShowPassengerUI cont find VehicleControlPanel")
    return
  end
  VehicleControlPanel:SelfHitTestInvisible()
  print(bWriteLog and "VehicleControlUISubSystem:ShowPassengerUI")
  self.bIsDriver = false
  self._OnVehicle = true
  local VehicleUserComponent = self:GetVehicleUserComponent()
  local Vehicle = slua.isValid(VehicleUserComponent) and VehicleUserComponent.Vehicle
  if slua.isValid(Vehicle) then
    print(bWriteLog and "VehicleControlUISubSystem:ShowPassengerUI Vehicle " .. Vehicle.VehicleType)
    local _ControlUIConfig = self:GetControlUIConfig(Vehicle)
    if _ControlUIConfig and _ControlUIConfig.HideAllVehicleUI then
      self:DisableTouchBehaviour()
      VehicleControlPanel:Collapsed()
      return
    else
      VehicleControlPanel:ShowVehicleControlGUI(false)
    end
    self:NewVehicleInQueue(Vehicle.VehicleType)
    if _ControlUIConfig and _ControlUIConfig.CommonUIGroup then
      for _, ConfigKey in ipairs(_ControlUIConfig.CommonUIGroup) do
        self:AddVehicleControlUI(ConfigKey, true)
      end
    end
    local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
    if CustomLayoutModule then
      CustomLayoutModule:SwapVehicleSlotByMode(self:GetSpecificVehicleMode(Vehicle))
    end
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_VEHICLE_CONTROL_UI_SHOW, self.bIsDriver)
  end
end
function VehicleControlUISubSystem:DoVehicleWeaponGUI()
  local VehicleControlPanel = self:GetVehicleControlPanel(false)
  if not VehicleControlPanel then
    print(bWriteLog and "VehicleControlPanel:DoVehicleWeaponGUI cont find VehicleControlPanel")
    return
  end
  print(bWriteLog and "VehicleControlUISubSystem:DoVehicleWeaponGUI")
  VehicleControlPanel:DoVehicleWeaponGUI()
end
function VehicleControlUISubSystem:OnShowAllUIForDelayResult()
  print(bWriteLog and "VehicleControlUISubSystem:OnShowAllUIForDelayResult")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlUISubSystem:OnShowAllUIForDelayResult VehicleUserComponent nil")
    return
  end
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_AsDriver then
    print(bWriteLog and "VehicleControlUISubSystem:OnShowAllUIForDelayResult VehicleUserComponent VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_AsDriver")
    return
  end
  local VehicleControlPanel = self:GetVehicleControlPanel(true)
  if not Game:IsValid(VehicleControlPanel) then
    print(bWriteLog and "VehicleControlUISubSystem:OnShowAllUIForDelayResult VehicleUserComponent VehicleControlPanel nil")
    return
  end
  VehicleControlPanel:SelfHitTestInvisible()
  VehicleControlPanel:ShowVehicleControlGUI(true)
end
function VehicleControlUISubSystem:OnExitVehicle()
  print(bWriteLog and "VehicleControlUISubSystem:OnExitVehicle")
  self:CloseVehicleControlPanel()
  self.bIsDriver = false
  self._Boosting = false
  self._Forwarding = false
  self._OnVehicle = false
  local LastVehicleUIGroup = self._VehicleQueue[1]
  if LastVehicleUIGroup then
    print(bWriteLog and "VehicleControlUISubSystem:OnExitVehicle " .. LastVehicleUIGroup.Type)
    local toRemove = {}
    for Index, UIConfigKey in ipairs(LastVehicleUIGroup.Map) do
      local ControlUI = UIManager.GetUI(UIManager.UI_Config_InGame[UIConfigKey])
      if ControlUI and ControlUI.bRetainOnExit then
        self:ToggleVehicleControlUI(UIManager.UI_Config_InGame[UIConfigKey], false)
      elseif ControlUI then
        self:RemoveVehicleControlUI(UIManager.UI_Config_InGame[UIConfigKey])
        table.insert(toRemove, Index)
      end
    end
    for i = #toRemove, 1, -1 do
      table.remove(self._VehicleQueue[1].Map, toRemove[i])
    end
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    if self._VehicleModeInUsing == 1 or self._VehicleModeInUsing == 3 then
      PlayerController:LuaHideJoystickWidgetWithTag("Driver")
    end
    PlayerController:LuaShowJoystickWidgetWithTag("Driver")
    PlayerController:ShowTouchInterface(true)
  end
  local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
  if CustomLayoutModule then
    CustomLayoutModule:SwapVehicleSlotByMode(2)
  end
end
function VehicleControlUISubSystem:ShowInteractiveButton(Component)
  print(bWriteLog and "VehicleControlUISubSystem:ShowInteractiveButton")
  local VehicleControlPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlPanel)
  if VehicleControlPanel then
    local VehicleInteractUI = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleInteractUI)
    if VehicleInteractUI and slua.isValid(Component) then
      VehicleInteractUI.Interactive    end
    if VehicleInteractUI then
      VehicleInteractUI:SelfHitTestInvisible()
    else
      VehicleControlPanel:CreateChildWindow("CanvasPanel_0", UIManager.UI_Config_InGame.VehicleInteractUI, Component)
    end
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      local uCurPawn = uPlayerController:GetCurPlayerCharacter()
      if Game:IsValid(uCurPawn) and VehicleInteractUI and uCurPawn:IsCastingSkillIDFix(Component.skillID) then
        VehicleInteractUI:Collapsed()
      end
    end
  end
end
function VehicleControlUISubSystem:CloseInteractiveUI(Component)
  print(bWriteLog and "VehicleControlUISubSystem:CloseInteractiveUI")
  if UIManager.UI_Config_InGame.VehicleInteractUI then
    local Panel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleInteractUI)
    if Panel then
      Panel:Collapsed()
    end
  end
end
function VehicleControlUISubSystem:OnSpectatorChange_Handle()
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnSpectatorChange_Handle")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnSpectatorChange_Handle uPlayerController nil")
    return
  end
  if slua.isValid(self.uViewCurrentPlayerCharacter) then
    self:RemoveControlEvent(self.uViewCurrentPlayerCharacter, "OnAttachedToVehicle")
    self:RemoveControlEvent(self.uViewCurrentPlayerCharacter, "OnDetachedFromVehicle")
  end
  self.uViewCurrentPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
  if slua.isValid(self.uViewCurrentPlayerCharacter) then
    self:AddControlEvent(self.uViewCurrentPlayerCharacter, "OnAttachedToVehicle", self.OnViewAttachedToVehicle_Handle, self)
    self:AddControlEvent(self.uViewCurrentPlayerCharacter, "OnDetachedFromVehicle", self.OnViewDetachedFromVehicle_Handle, self)
    local uCurVehicle = self.uViewCurrentPlayerCharacter.CurrentVehicle
    local VehicleControlPanel = self:GetVehicleControlPanel(true)
    if VehicleControlPanel then
      if slua.isValid(uCurVehicle) then
        VehicleControlPanel:ShowSpectatorModeControlUI(uCurVehicle)
      else
        VehicleControlPanel:CloseSpectatorModeControlUI()
      end
    end
  end
end
function VehicleControlUISubSystem:OnViewAttachedToVehicle_Handle(uInVehicle)
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewAttachedToVehicle_Handle")
  if not Game:IsValid(self.uViewCurrentPlayerCharacter) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewAttachedToVehicle_Handle uViewCurrentPlayerCharacter nil")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewAttachedToVehicle_Handle uPlayerController nil")
    return
  end
  local uCurPawn = uPlayerController:GetCurPlayerCharacter()
  if not Game:IsValid(uCurPawn) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewAttachedToVehicle_Handle uCurPawn nil")
    return
  end
  if uCurPawn == self.uViewCurrentPlayerCharacter then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewAttachedToVehicle_Handle uCurPawn == self.uViewCurrentPlayerCharacter")
    local VehicleControlPanel = self:GetVehicleControlPanel(true)
    if VehicleControlPanel then
      if slua.isValid(uInVehicle) then
        VehicleControlPanel:ShowSpectatorModeControlUI(uInVehicle)
      else
        VehicleControlPanel:CloseSpectatorModeControlUI()
      end
    end
  end
end
function VehicleControlUISubSystem:OnFreeViewChangedDelegate_Handle()
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnFreeViewChangedDelegate_Handle")
  local VehicleControlPanel = self:GetVehicleControlPanel()
  if VehicleControlPanel then
    VehicleControlPanel:CloseSpectatorModeControlUI()
  end
end
function VehicleControlUISubSystem:OnPlayerQuitSpectatingForClient_Handle()
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnPlayerQuitSpectatingForClient_Handle")
  local VehicleControlPanel = self:GetVehicleControlPanel()
  if VehicleControlPanel then
    VehicleControlPanel:HideSpectatorModeControlUI()
  end
end
function VehicleControlUISubSystem:OnViewDetachedFromVehicle_Handle(uLastVehicle)
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewDetachedFromVehicle_Handle")
  if not Game:IsValid(self.uViewCurrentPlayerCharacter) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewDetachedFromVehicle_Handle uViewCurrentPlayerCharacter nil")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewDetachedFromVehicle_Handle uPlayerController nil")
    return
  end
  local uCurPawn = uPlayerController:GetCurPlayerCharacter()
  if not Game:IsValid(uCurPawn) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnViewDetachedFromVehicle_Handle uCurPawn nil")
    return
  end
  if uCurPawn == self.uViewCurrentPlayerCharacter then
    local VehicleControlPanel = self:GetVehicleControlPanel(true)
    if VehicleControlPanel then
      VehicleControlPanel:CloseSpectatorModeControlUI()
    end
  end
end
function VehicleControlUISubSystem:OnChangedVehicleSeat_Handle(_, _, uVehicle)
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnChangedVehicleSeat_Handle")
  if not slua.isValid(uVehicle) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnChangedVehicleSeat_Handle uVehicle nil")
    return
  end
  print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: OnChangedVehicleSeat_Handle VehicleType = ", uVehicle.VehicleType)
end
function VehicleControlUISubSystem:IsnowVehicleIsHelicopter(Vehicle)
  print(bWriteLog and "VehicleControlUISubSystem:IsnowVehicleIsHelicopter")
  if not slua.isValid(Vehicle) then
    return false
  end
  local STExtraHelicopterVehicleClass = import("STExtraHelicopterVehicle")
  if not Game:IsClassOf(Vehicle, STExtraHelicopterVehicleClass) then
    return false
  end
  return true
end
function VehicleControlUISubSystem:GetUserSettingsVehicleControlMode()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig and SettingConfig.VehicleControlMode then
    return SettingConfig.VehicleControlMode
  end
  return -999
end
function VehicleControlUISubSystem:GetVehicleUserComponent()
  if slua.isValid(self._VehicleUserComponentCache) then
    return self._VehicleUserComponentCache
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: GetVehicleUserComponent PlayerController nil")
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "VehicleControlUISubSystem_Debug_Msg: GetVehicleUserComponent VehicleUserComponent nil")
    return nil
  end
  self._VehicleUserComponentCache = VehicleUserComponent
  return VehicleUserComponent
end
function VehicleControlUISubSystem:InitCommonVehicleSkillItem(ParentWidget, Widget, SkillConfig, nSkillState)
  nSkillState = nSkillState or 1
  local CommonVehicleSkillItem = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleItem.CommonVehicleSkill")
  local SkillItem = CommonVehicleSkillItem(SkillConfig, nSkillState)
  SkillItem:InitWithParentWidget(ParentWidget, Widget)
  return SkillItem
end
function VehicleControlUISubSystem:GetCurVehicle()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    return VehicleUserComponent.Vehicle
  end
end
function VehicleControlUISubSystem:GetVehicleModeInUsing()
  return self._VehicleModeInUsing
end
function VehicleControlUISubSystem:GetSpecificVehicleMode(Vehicle)
  if not slua.isValid(Vehicle) then
    Vehicle = self:GetCurVehicle()
  end
  local VehicleType = slua.isValid(Vehicle) and Vehicle.VehicleType
  if VehicleType then
    local SpecificVehicleMode
    local _ControlConfig = VehicleControlUIConfig[VehicleType]
    if _ControlConfig then
      if _ControlConfig.VModeKey then
        local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
        if slua.isValid(SettingConfig) then
          SpecificVehicleMode = SettingConfig.SVControlMode:Get(_ControlConfig.VModeKey)
        end
      end
      if not SpecificVehicleMode then
        if type(_ControlConfig.VehicleMode) == "number" then
          SpecificVehicleMode = _ControlConfig.VehicleMode
        elseif _ControlConfig.VehicleMode == "General" then
          SpecificVehicleMode = self.GeneralVehicleMode
        end
      end
    else
      SpecificVehicleMode = self.GeneralVehicleMode
    end
    return SpecificVehicleMode
  end
end
function VehicleControlUISubSystem:CheckSpecificVehicleModeChange()
  local SpecificVehicleMode = self:GetSpecificVehicleMode()
  if SpecificVehicleMode and self._VehicleModeInUsing ~= SpecificVehicleMode then
    self:SwitchControlUIByMode(SpecificVehicleMode)
    local Vehicle = self:GetCurVehicle()
    if slua.isValid(Vehicle) and Vehicle.bEnableAutoMoveForJoystick then
      local PlayerController = GameplayData.GetPlayerController()
      if slua.isValid(PlayerController) then
        PlayerController:SetVehicleAutoMoveState(false)
      end
      local VehicleUserComponent = self:GetVehicleUserComponent()
      if slua.isValid(VehicleUserComponent) then
        VehicleUserComponent:SetVehicleAutoMoveForward(false)
        VehicleUserComponent:MoveVehicleForward(0)
      end
      local BioVehicleControlUIAutoMove = UIManager.GetUI(UIManager.UI_Config_InGame.BioVehicleControlUIAutoMove)
      if BioVehicleControlUIAutoMove then
        BioVehicleControlUIAutoMove:OnSpecificVehicleModeChange(SpecificVehicleMode)
      end
    end
  end
end
function VehicleControlUISubSystem:NewVehicleInQueue(VehicleType)
  local SameTypeIndex
  for Index, Element in ipairs(self._VehicleQueue) do
    if Element.Type == VehicleType then
      if Index == 1 then
        print(bWriteLog and string.format("VehicleControlUISubSystem:NewVehicleInQueue Same VehicleType:%d QueueSize:%d", VehicleType, #self._VehicleQueue))
        return
      else
        SameType        break
      end
    end
  end
  if SameTypeIndex then
    local SameTypeElement = table.remove(self._VehicleQueue, SameTypeIndex)
    table.insert(self._VehicleQueue, 1, SameTypeElement)
    print(bWriteLog and string.format("VehicleControlUISubSystem:NewVehicleInQueue Used VehicleType:%d QueueSize:%d", VehicleType, #self._VehicleQueue))
    return
  else
    table.insert(self._VehicleQueue, 1, {
      Type = VehicleType,
      Map = {}
    })
    print(bWriteLog and string.format("VehicleControlUISubSystem:NewVehicleInQueue New VehicleType:%d QueueSize:%d", VehicleType, #self._VehicleQueue))
    local QueueLimit = 3
    if QueueLimit < #self._VehicleQueue and self._VehicleQueue[QueueLimit + 1] then
      for _, UIConfigKey in ipairs(self._VehicleQueue[QueueLimit + 1].Map) do
        self:RemoveVehicleControlUI(UIManager.UI_Config_InGame[UIConfigKey])
      end
      table.remove(self._VehicleQueue, QueueLimit + 1)
    end
    return
  end
end
function VehicleControlUISubSystem:AddVehicleControlUI(Config, bNotOnlyDriver)
  local uVehicle
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    uVehicle = VehicleUserComponent.Vehicle
  end
  local _UIConfig, _UIConfigKey = ParseConfig(Config, uVehicle)
  if not _UIConfig or not _UIConfigKey then
    return
  end
  print(bWriteLog and string.format("VehicleControlUISubSystem:AddVehicleControlUI %s %s", _UIConfigKey, bNotOnlyDriver and "bNotOnlyDriver" or ""))
  local UIPanel = UIManager.GetUI(_UIConfig)
  if not UIPanel then
    local VehicleControlPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlPanel)
    if VehicleControlPanel then
      if not bNotOnlyDriver then
        VehicleControlPanel:CreateChildWindow("CanvasPanel_Driver", _UIConfig)
      else
        VehicleControlPanel:CreateChildWindow("CanvasPanel_0", _UIConfig)
      end
    else
      print(bWriteLog and "VehicleControlUISubSystem:AddVehicleControlUI VehicleControlPanel not exists")
    end
  elseif UIPanel:IsShow() then
    if UIPanel.OnShow_Vehicle then
      UIPanel:OnShow_Vehicle(self.bIsDriver)
    end
  else
    UIPanel:SelfHitTestInvisible()
  end
  local _CurrentQueue = self._VehicleQueue[1]
  if _CurrentQueue then
    local Count = #_CurrentQueue.Map
    for i = 1, Count do
      if _CurrentQueue.Map[i] == _UIConfigKey then
        return
      end
    end
    table.insert(_CurrentQueue.Map, _UIConfigKey)
    if self._RefCountMap[_UIConfigKey] then
      self._RefCountMap[_UIConfigKey] = self._RefCountMap[_UIConfigKey] + 1
    else
      self._RefCountMap[_UIConfigKey] = 1
    end
  else
    print(bWriteLog and "VehicleControlUISubSystem:AddVehicleControlUI Error Adding ControlUI")
  end
end
function VehicleControlUISubSystem:ToggleVehicleControlUI(Config, bShow)
  local uVehicle
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    uVehicle = VehicleUserComponent.Vehicle
  end
  local _UIConfig, _UIConfigKey = ParseConfig(Config, uVehicle)
  if not _UIConfig or not _UIConfigKey then
    return
  end
  print(bWriteLog and string.format("VehicleControlUISubSystem:ToggleVehicleControlUI %s %s", _UIConfigKey, bShow and "Show" or "Hide"))
  local UIPanel = UIManager.GetUI(_UIConfig)
  if UIPanel then
    if bShow then
      UIPanel:SelfHitTestInvisible()
    else
      UIPanel:Collapsed()
    end
  end
end
function VehicleControlUISubSystem:RemoveVehicleControlUI(Config)
  local uVehicle
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    uVehicle = VehicleUserComponent.Vehicle
  end
  local _UIConfig, _UIConfigKey = ParseConfig(Config, uVehicle)
  if not _UIConfig or not _UIConfigKey then
    return
  end
  print(bWriteLog and string.format("VehicleControlUISubSystem:RemoveVehicleControlUI %s", _UIConfigKey))
  local UIPanel = UIManager.GetUI(_UIConfig)
  if UIPanel and self._RefCountMap[_UIConfigKey] then
    self._RefCountMap[_UIConfigKey] = self._RefCountMap[_UIConfigKey] - 1
    if self._RefCountMap[_UIConfigKey] <= 0 then
      self._RefCountMap[_UIConfigKey] = nil
      UIManager.CloseUI(_UIConfig)
    else
      UIPanel:Collapsed()
    end
  end
end
function VehicleControlUISubSystem:SwitchControlUIByMode(VehicleControlMode)
  print(bWriteLog and "VehicleControlUISubSystem:SwitchControlUIByMode " .. tostring(VehicleControlMode))
  if self._VehicleModeInUsing == 1 then
    self:ToggleVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUISteering, false)
  elseif self._VehicleModeInUsing == 3 then
    self:ToggleVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUIFourButtons, false)
  end
  if VehicleControlMode then
    self._VehicleModeInUsing = VehicleControlMode
    self:ApplyTouchBehaviourByMode(VehicleControlMode)
    if VehicleControlMode == 1 then
      self:AddVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUISteering)
    elseif VehicleControlMode == 3 then
      self:AddVehicleControlUI(UIManager.UI_Config_InGame.VehicleControlUIFourButtons)
    end
    local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
    if CustomLayoutModule then
      CustomLayoutModule:SwapVehicleSlotByMode(VehicleControlMode)
    end
  else
    self._VehicleModeInUsing = false
    self:DisableTouchBehaviour()
  end
end
function VehicleControlUISubSystem:ToggleDriverUI(bShow)
  local Vehicle = self:GetCurVehicle()
  if not slua.isValid(Vehicle) then
    return
  end
  local VehicleMode = self:GetSpecificVehicleMode(Vehicle)
  local VPanel = self:GetVehicleControlPanel()
  if VPanel and VPanel.UIRoot then
    VPanel:ToggleDriverUI(bShow)
  end
  if VehicleMode == 2 then
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:ShowTouchInterface(bShow)
    end
  end
end
function VehicleControlUISubSystem:ApplyTouchBehaviourByMode(VehicleControlMode)
  local PlayerController = GameplayData.GetPlayerController()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(PlayerController) and slua.isValid(VehicleUserComponent) then
    if VehicleControlMode == 1 then
      VehicleUserComponent.AxisMoveRightFreezed = false
      VehicleUserComponent.AxisMoveForwardFreezed = true
      PlayerController:LuaHideJoystickWidgetWithTag("Driver")
      PlayerController:LuaShowJoystickWidgetWithTag("Driver")
      PlayerController:ShowTouchInterface(true)
    elseif VehicleControlMode == 2 then
      VehicleUserComponent.AxisMoveRightFreezed = false
      VehicleUserComponent.AxisMoveForwardFreezed = false
      PlayerController:LuaShowJoystickWidgetWithTag("Driver")
      PlayerController:ShowTouchInterface(true)
      local EJoystickOperatingMode = import("EJoystickOperatingMode")
      PlayerController:SetJoystickOperatingMode(EJoystickOperatingMode.JSNormal, 0)
    elseif VehicleControlMode == 3 then
      VehicleUserComponent.AxisMoveRightFreezed = true
      VehicleUserComponent.AxisMoveForwardFreezed = true
      PlayerController:LuaHideJoystickWidgetWithTag("Driver")
    end
  end
end
function VehicleControlUISubSystem:DisableTouchBehaviour()
  self:ApplyTouchBehaviourByMode(3)
end
function VehicleControlUISubSystem:Forward()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    if slua.isValid(VehicleUserComponent.Vehicle) and VehicleUserComponent.Vehicle.bBaseAutoMoveForward then
      VehicleUserComponent:SetVehicleAutoMoveForward(false)
    end
    VehicleUserComponent:MoveVehicleForward(1.0)
    self._Forwarding = true
  end
end
function VehicleControlUISubSystem:StopForward()
  self._Forwarding = false
  if self._Boosting then
    return
  end
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    VehicleUserComponent:MoveVehicleForward(0.0)
  end
end
function VehicleControlUISubSystem:Backward()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    if slua.isValid(VehicleUserComponent.Vehicle) and VehicleUserComponent.Vehicle.bBaseAutoMoveForward then
      VehicleUserComponent:SetVehicleAutoMoveForward(false)
    end
    VehicleUserComponent:MoveVehicleForward(-1.0)
    self._Backwarding = true
  end
end
function VehicleControlUISubSystem:StopBackward()
  self._Backwarding = false
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    VehicleUserComponent:MoveVehicleForward(0.0)
  end
end
function VehicleControlUISubSystem:Boost()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    VehicleUserComponent:MoveVehicleForward(1.0)
    VehicleUserComponent:SetBoosting(true)
    self._Boosting = true
    if self._VehicleModeInUsing == 2 then
      print(bWriteLog and "VehicleControlUISubSystem:Boost Freeze Joystick")
      VehicleUserComponent.AxisMoveForwardFreezed = true
    end
  end
end
function VehicleControlUISubSystem:StopBoost()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) then
    self._Boosting = false
    VehicleUserComponent:SetBoosting(false)
    if not self._Forwarding and not self._Backwarding then
      VehicleUserComponent:MoveVehicleForward(0.0)
    end
    if self._VehicleModeInUsing == 2 then
      print(bWriteLog and "VehicleControlUISubSystem:StopBoost Cancel Freeze Joystick")
      VehicleUserComponent.AxisMoveForwardFreezed = false
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VehicleControlUISubSystem)