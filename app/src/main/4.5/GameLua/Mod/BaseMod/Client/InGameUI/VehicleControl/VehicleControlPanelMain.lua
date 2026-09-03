local EPawnState = import("EPawnState")
local ESTExtraVehicleType = import("ESTExtraVehicleType")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
local ESTEScopeType = import("ESTEScopeType")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
local VehicleControlPanelIMP = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleControlPanelIMP")
require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleControlPanelAutoTest")
require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleControlPanelSpectating")
local CantShowSkinPanelVehicleShape = {
  [ESTExtraVehicleShapeType.VST_UAV] = true,
  [ESTExtraVehicleShapeType.VST_HeavyDacia] = true,
  [ESTExtraVehicleShapeType.VST_HeavyPickup] = true,
  [ESTExtraVehicleShapeType.VST_HeavyBuggy] = true,
  [ESTExtraVehicleShapeType.VST_HeavyUAZ] = true,
  [ESTExtraVehicleShapeType.VST_HeavyUH60] = true,
  [ESTExtraVehicleShapeType.VST_Snowboard] = true,
  [ESTExtraVehicleShapeType.VST_UH60] = true,
  [ESTExtraVehicleShapeType.VST_Bike] = true,
  [ESTExtraVehicleShapeType.VST_CatapultMachine] = true,
  [ESTExtraVehicleShapeType.VST_MegaDrop] = true,
  [ESTExtraVehicleShapeType.VST_SciFi] = true,
  [ESTExtraVehicleShapeType.VST_TrackVehicle] = true,
  [ESTExtraVehicleShapeType.VST_ATGMotorCycle] = true,
  [ESTExtraVehicleShapeType.VST_LootTruck] = true,
  [ESTExtraVehicleShapeType.VST_Unknown] = true,
  [ESTExtraVehicleShapeType.VST_UAVVine] = true
}
function VehicleControlPanelIMP:ctor()
  print(bWriteLog and "VehicleControlPanelIMP:ctor")
  self._CurrentStyleIndex = 1
  self.VehicleWeaponUI = nil
  self.bUsedVehicleWeapon = false
  self.bIsDriving = false
  self.bIsShowVehicleControlUI = false
  self.CurrentSeatGeneralUIConfig = UIManager.UI_Config_InGame.DefaultSeatGeneralUI
  local super_data = require("common.super_data")
  self.Data = super_data.CreateSuperData({})
  self.Data.bLoaded = false
end
function VehicleControlPanelIMP:GetSuperData()
  return self.Data
end
function VehicleControlPanelIMP:OnInitialize()
  print(bWriteLog and "VehicleControlPanelIMP:OnInitialize")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.VehicleControlLayer then
    self:AttachToPanel(MainControlPanelTochButton.VehicleControlLayer)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
  end
  self.Data.bLoaded = true
  self.UIRoot.VehicleWeaponUISocket:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:CreateChildWindow(self.UIRoot.CanvasPanel_SeatSocket, self.CurrentSeatGeneralUIConfig)
  self:CreateChildWindow(self.UIRoot.PanelVehicleCommonGUI2, UIManager.UI_Config_InGame.BackToDriverButton)
  self:CreateChildWindow("Carrier_WeaponIconSlot", UIManager.UI_Config.DriverLastWeaponUI)
end
function VehicleControlPanelIMP:RegistEvents()
  print(bWriteLog and "VehicleControlPanelIMP:RegistEventsDelay")
  self:AddControlEventByControl(self.UIRoot.RightCarSpeaker, "OnPressed", self.OnPressed_RightCarSpeaker, self)
  self:AddControlEventByControl(self.UIRoot.RightCarSpeaker, "OnReleased", self.OnReleased_RightCarSpeaker, self)
  self:AddControlEventByControl(self.UIRoot.Button_ShootingOnTheVehile, "OnClicked", self.OnClicked_Button_ShootingOnTheVehile, self)
  self:AddControlEventByControl(self.UIRoot.BtnLeaveVehicle, "OnMouseButtonDownEvent", self.OnMouseButtonDown_BtnLeaveVehicle, self)
  self:AddControlEventByControl(self.UIRoot.ButtonRacingReset, "OnMouseButtonDownEvent", self.OnClickRacingReset, self)
  self:AddControlEventByControl(self.UIRoot.Button_PhotoEdit, "OnClicked", self.OnButton_PhotoEditClick, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT, self.OnShowAllUIForDelayResult, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_OPERATION_CHANGE, self.OnSwitchUIOperation, self)
  GameplayData.AddSelfPlayerControllerEventWithCondition(self, "OnCharacterStatesChangeWithFilterState", {
    State = {
      EPawnState.LeanOutVehicle
    }
  }, self.OnLeanOutVehicleChanged, self)
  self:ReceivedInitWidget()
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_LeaveVehicle, self, "VehicleControlPanel_LeaveVehicle")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_SeatSocket, self, "VehicleSeatUI")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Miscellaneous, self, "VehicleMiscellaneous")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      local CurrentUsingSlot = WeaponManager:GetCurrentUsingPropSlot()
      local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
      self:WeaponChange(CurrentUsingSlot, CurWeapon)
    end
  end
  self:AddSettingOptionEvent("VehicleControlMode", function(VehicleControlMode)
    self:OnVehicleControlModeChange()
  end)
end
function VehicleControlPanelIMP:OnVehicleControlModeChange()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "VehicleControlPanelIMP:DoVehicleWeaponGUI VehicleUserComponent nil")
    return
  end
  local bShowVehicleWeaponUI = VehicleUserComponent:ShowVehicleWeaponUI()
  local VehicleWeapon = VehicleUserComponent:GetCharacterVehicleWeapon()
  if not bShowVehicleWeaponUI or not slua.isValid(VehicleWeapon) then
    return
  end
  local VehicleWeaponUIBP = self:GetVehicleWeaponUIBP()
  if not slua.isValid(VehicleWeaponUIBP) then
    print(bWriteLog and "VehicleControlPanelIMP:DoVehicleWeaponGUI VehicleWeaponUIBP nil")
    return
  end
  VehicleWeaponUIBP:UpdateUseVehicleWeaponUI(bShowVehicleWeaponUI, VehicleWeapon)
  VehicleWeaponUIBP:ShowVehicleWeaponUI(self.bIsDriving)
end
function VehicleControlPanelIMP:WeaponChange(TargetChangeSlot, CurWeapon)
  print(bWriteLog and "VehicleControlPanelIMP:WeaponChange 0")
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  if TargetChangeSlot == ESurviveWeaponPropSlot.SWPS_VehicleWeapon and slua.isValid(CurWeapon) then
    print(bWriteLog and "VehicleControlPanelIMP:WeaponChange 1")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:BroadcastUIMessage("UIMsg_HideSideSight", 0, "", "")
    end
    self:OnUpdateVehicleWeaponUI(true, CurWeapon)
  end
end
function VehicleControlPanelIMP:BindButtonEvent()
end
function VehicleControlPanelIMP:OnPostInitialize()
  self:TryAttachVehicleWeaponUIBP()
end
function VehicleControlPanelIMP:ReceivedInitWidget()
  print(bWriteLog and "VehicleControlPanelIMP:ReceivedInitWidget")
  GameComponentData.AddSelfWeaponManagerComponentEvent(self, "ChangeInventoryDataDelegate", self.OnChangeInventoryData, self)
  GameComponentData.AddSelfWeaponManagerComponentEvent(self, "ChangeCurrentUsingWeaponDelegate", self.OnChangeCurrentUsingWeapon, self)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModTypeString, _ = GameMainConfig.GetModType()
  if ModTypeString == "VehicleWar" then
    self:SetWidgetInVehicleWar()
  end
  self:OnChangeInventoryData()
  self:OnChangeCurrentUsingWeapon()
end
function VehicleControlPanelIMP:OnRacingIngameChange(bIngame)
end
function VehicleControlPanelIMP:OnClickRacingReset()
  print(bWriteLog and "VehicleControlPanelIMP:OnClickRacingReset")
  local RacingClientHandler = require("GameLua.Mod.SocialIsland.Client.Handler.SocialIsland_Racing_Client_Handler")
  RacingClientHandler.send_racing_vehicle_reset_req()
end
function VehicleControlPanelIMP:OnButton_PhotoEditClick()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem then
    IngameSelfieSubsystem:OnButton_PhotoEditClick(self.UIRoot.Image_PhotoEditReddot)
  end
end
function VehicleControlPanelIMP:OnSwitchUIOperation(_, _, UIOperation)
  print(bWriteLog and "VehicleControlPanelIMP:OnSwitchUIOperation" .. tostring(UIOperation))
  if self.CheckVehicleShootingStateTimer then
    return
  end
  self.CheckVehicleShootingStateTimer = self:AddGameTimer(0, false, function()
    self.CheckVehicleShootingStateTimer = nil
    self:CheckVehicleShootingState()
  end)
end
function VehicleControlPanelIMP:OnShowAllUIForDelayResult()
  print(bWriteLog and "VehicleControlPanelIMP:OnShowAllUIForDelayResult")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:OnShowAllUIForDelayResult VehicleUserComponent nil")
    return
  end
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_AsDriver then
    print(bWriteLog and "VehicleControlPanelIMP:OnShowAllUIForDelayResult VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_AsDriver")
    return
  end
  self:ShowVehicleControlGUI(true)
end
function VehicleControlPanelIMP:SetWidgetInVehicleWar()
  print(bWriteLog and "VehicleControlPanelIMP:SetWidgetInVehicleWar")
  local UIRoot = self.UIRoot
  UIRoot.CanvasPanel_CarSpeaker:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.BtnLeaveVehicle:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function VehicleControlPanelIMP:OnChangeInventoryData(_, _)
  print(bWriteLog and "VehicleControlPanelIMP:OnChangeInventoryData")
  self:UpdateDriverLastWeaponUI()
end
function VehicleControlPanelIMP:OnChangeCurrentUsingWeapon(_)
  print(bWriteLog and "VehicleControlPanelIMP:OnChangeCurrentUsingWeapon")
  self:CheckVehicleShootingState()
end
function VehicleControlPanelIMP:OnPressed_RightCarSpeaker()
  print(bWriteLog and "VehicleControlPanelIMP:OnPressed_RightCarSpeaker")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:OnPressed_RightCarSpeaker nil")
    return
  end
  if not slua.isValid(VehicleUserComponent.Vehicle) then
    print(bWriteLog and "VehicleControlPanelIMP:OnPressed_RightCarSpeaker Vehicle is not valid")
    return
  end
  print(bWriteLog and "VehicleControlPanelIMP:OnPressed_RightCarSpeaker bUseHornWithPreludes:" .. tostring(VehicleUserComponent.Vehicle.bUseHornWithPreludes))
  VehicleUserComponent:TryUseHorn(true)
end
function VehicleControlPanelIMP:OnReleased_RightCarSpeaker()
  print(bWriteLog and "VehicleControlPanelIMP:OnReleased_RightCarSpeaker")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:OnReleased_RightCarSpeaker nil")
    return
  end
  if not slua.isValid(VehicleUserComponent.Vehicle) then
    print(bWriteLog and "VehicleControlPanelIMP:OnReleased_RightCarSpeaker Vehicle is not valid")
    return
  end
  VehicleUserComponent:TryUseHorn(false)
end
function VehicleControlPanelIMP:OnClicked_Button_ShootingOnTheVehile()
  print(bWriteLog and "VehicleControlPanelIMP:OnClicked_Button_ShootingOnTheVehile")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:OnClicked_Button_ShootingOnTheVehile nil")
    return
  end
  if VehicleUserComponent:CheckCanLeanOutVehicle() then
    VehicleUserComponent:TryLeanOutOrIn(false, false)
  else
    VehicleUserComponent:TryChangeFreeFireSeatAndLeanOut()
  end
end
function VehicleControlPanelIMP:SpeakerPress()
  print(bWriteLog and "VehicleControlPanelIMP:SpeakerPress")
  self:OnPressed_RightCarSpeaker()
end
function VehicleControlPanelIMP:SpeakerRelease()
  print(bWriteLog and "VehicleControlPanelIMP:SpeakerRelease")
  self:OnReleased_RightCarSpeaker()
end
function VehicleControlPanelIMP:OnMouseButtonDown_BtnLeaveVehicle()
  print(bWriteLog and "VehicleControlPanelIMP:OnMouseButtonDown_BtnLeaveVehicle")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:OnMouseButtonDown_BtnLeaveVehicle VehicleUserComponent nil")
    return WidgetBlueprintLibrary.Handled()
  end
  local Vehicle = VehicleUserComponent.Vehicle
  if not slua.isValid(VehicleUserComponent) or not slua.isValid(Vehicle) then
    print(bWriteLog and "VehicleControlPanelIMP:OnMouseButtonDown_BtnLeaveVehicle Vehicle nil")
    return WidgetBlueprintLibrary.Handled()
  end
  VehicleUserComponent:ExitVehicle()
  return WidgetBlueprintLibrary.Handled()
end
function VehicleControlPanelIMP:RefreshLeaveVehicleButton(CurrentVehicle)
  if not self.Data.bLoaded then
    return
  end
  self.UIRoot.TextBlock_LeaveVehicle:SetText(LocUtil.GetLocalizeResStr(7853))
  self.UIRoot.Image_LeaveVehicle:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_xiache_png.ZD_icon_xiache_png", false)
  if slua.isValid(CurrentVehicle) then
    if CurrentVehicle.LeaveVehicleTextID then
      self.UIRoot.TextBlock_LeaveVehicle:SetText(LocUtil.GetLocalizeResStr(CurrentVehicle.LeaveVehicleTextID))
    end
    if CurrentVehicle.LeaveVehicleIconPath then
      self.UIRoot.Image_LeaveVehicle:SetBrushFromPathAsync(CurrentVehicle.LeaveVehicleIconPath, false)
    end
  end
end
function VehicleControlPanelIMP:SetVehicleIcon(CommonItemBP, ResId)
  local TargetUI = CommonItemBP.targetUI
  if TargetUI.Image_Wardrobe_CarLogo and TargetUI.Image_Wardrobe_GunLogo then
    TargetUI.Image_Wardrobe_CarLogo:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    TargetUI.Image_Wardrobe_GunLogo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local UIUtil = require("client.common.ui_util")
    local ItemBigIcon = UIUtil.GetItemBigIcon(ResId)
    CommonItemBP:SetTexture(TargetUI.Image_Wardrobe_CarLogo, ItemBigIcon)
  end
end
function VehicleControlPanelIMP:ToggleDriverUI(bShow)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Driver, bShow)
end
function VehicleControlPanelIMP:ShowVehicleControlGUI(bIsDriving)
  print(bWriteLog and "VehicleControlPanelIMP:ShowVehicleControlGUI")
  self.  self.bIsShowVehicleControlUI = true
  self.UIRoot.PanelVehicleCommonGUI2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.CanvasPanel_Driver:SetWidgetVisibility(bIsDriving and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if slua.isValid(MainControlPanelTochButton) then
    MainControlPanelTochButton:ShowDriveUI()
  end
  local VehicleUserComponent = self:GetVehicleUserComponent()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  local Vehicle
  if slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle) then
    Vehicle = VehicleUserComponent.Vehicle
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_CarSpeaker, VehicleUserComponent:CanUseVehicleHorn())
    local bCanShoot = not bIsDriving and slua.isValid(PlayerCharacter) and VehicleUserComponent:CanVehicleShoot(PlayerCharacter)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_ShootingOnTheVehile, bCanShoot)
    if bCanShoot then
      self:AddGameTimer(0.5, false, function()
        if slua.isValid(self.UIRoot) then
          self:OnLeanOutVehicleChanged()
        end
      end)
    end
    self:DoVehicleWeaponGUI()
    self:RefreshSeat(Vehicle, PlayerCharacter)
    self:RefreshLeaveVehicleButton(Vehicle)
    self:RefreshHeightUI(true, Vehicle)
    self:RefreshSkinMusic(bIsDriving, Vehicle)
    self:RefreshFuelCapacity(true, Vehicle)
    self:UpdateDriverLastWeaponUI()
    EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_CONTROL_PANEL_SHOW, Vehicle, self.bIsDriving)
    if bIsDriving then
      self:RefreshVehicleIcon(Vehicle.VehicleType)
      self:InvalidateLayoutCache()
      VehicleUserComponent:MoveVehicleForward(0)
    end
    self:ClearInvalidationBoxesCache()
  end
end
function VehicleControlPanelIMP:IsHelicopterVehicle_AutoDrive(Vehicle)
  if Vehicle and Vehicle:IsHelicopter() and Vehicle.bAutoDrive then
    return true
  end
  return false
end
function VehicleControlPanelIMP:RefreshHeightUI(bShow, InVehicle)
  bShow = bShow and InVehicle.ShowUpDownGUI and not InVehicle.HideHeightUI and not self:IsHelicopterVehicle_AutoDrive(InVehicle)
  if bShow then
    local FlyVehicleHeightUI = UIManager.GetUI(UIManager.UI_Config_InGame.FlyVehicleHeightUI)
    if not FlyVehicleHeightUI or not FlyVehicleHeightUI:IsShow() then
      self:CreateChildWindow("CanvasPanel_0", UIManager.UI_Config_InGame.FlyVehicleHeightUI)
    end
  else
    local FlyVehicleHeightUI = UIManager.GetUI(UIManager.UI_Config_InGame.FlyVehicleHeightUI)
    if FlyVehicleHeightUI and FlyVehicleHeightUI:IsShow() then
      UIManager.CloseUI(UIManager.UI_Config_InGame.FlyVehicleHeightUI)
    end
  end
end
function VehicleControlPanelIMP:RefreshSkinMusic(bShow, InVehicle)
  bShow = bShow and not CantShowSkinPanelVehicleShape[InVehicle.VehicleShapeType]
  if bShow then
    local UI = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleSkinAndMusicButton)
    if not UI then
      self:CreateChildWindow(self.UIRoot.CanvasPanel_Miscellaneous, UIManager.UI_Config_InGame.VehicleSkinAndMusicButton)
    elseif UI:IsShow() then
      UI:OnShow()
    else
      UI:SelfHitTestInvisible()
    end
  else
    local UI = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleSkinAndMusicButton)
    if UI then
      UI:Collapsed()
    end
  end
end
function VehicleControlPanelIMP:RefreshFuelCapacity(bShow, InVehicle)
  bShow = bShow and InVehicle.GetShowStateUI and InVehicle:GetShowStateUI() and not self:IsHelicopterVehicle_AutoDrive(InVehicle)
  local UI = UIManager.GetUI(UIManager.UI_Config_InGame.FuelCapacityUI)
  if bShow and not UI then
    self:CreateChildWindow(self.UIRoot.CanvasPanel_Miscellaneous, UIManager.UI_Config_InGame.FuelCapacityUI)
  elseif bShow and UI then
    if UI:IsShow() then
      UI:OnShow()
    else
      UI:SelfHitTestInvisible()
    end
  elseif UI then
    UI:Collapsed()
  end
end
function VehicleControlPanelIMP:HideVehicleControlGUI()
  print(bWriteLog and "VehicleControlPanelIMP:HideVehicleControlGUI")
  self.UIRoot.PanelVehicleCommonGUI2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:CloseCurrentSeatUI()
  self:RefreshFuelCapacity(false)
  self.bIsShowVehicleControlUI = false
  EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_CONTROL_PANEL_HIDE)
  self:ClearInvalidationBoxesCache()
end
function VehicleControlPanelIMP:CheckVehicleShootingState()
  print(bWriteLog and "VehicleControlPanelIMP:CheckVehicleShootingState")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "VehicleControlPanelIMP:CheckVehicleShootingState VehicleUserComponent nil")
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:VehicleShootingCheckShootingState()
  end
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_ASPassenger then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "VehicleControlPanelIMP:CheckVehicleShootingState PlayerCharacter nil")
    return
  end
  local Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  if not VehicleUserComponent:CanVehicleShoot(PlayerCharacter) then
    Visibility = UEnums.ESlateVisibility.Collapsed
  end
  if self.UIRoot then
    self.UIRoot.CanvasPanel_ShootingOnTheVehile:SetWidgetVisibility(Visibility)
  end
end
function VehicleControlPanelIMP:OnLeanOutVehicleChanged()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and self.bIsShowVehicleControlUI then
    local bLeanOut = PlayerCharacter:HasState(EPawnState.LeanOutVehicle)
    print(bWriteLog and "OnLeanOutVehicleChanged " .. tostring(bLeanOut))
    self:SetWidgetVisible(self.UIRoot.Image_LeanOut_On, bLeanOut)
    self:SetWidgetVisible(self.UIRoot.Image_LeanOut_Off, not bLeanOut)
    if PlayerCharacter.bIsGunADS and not bLeanOut and not self.bUsedVehicleWeapon then
      PlayerCharacter:ScopeOut(ESTEScopeType.Normal)
    end
  end
end
function VehicleControlPanelIMP:RefreshSeat(Vehicle)
  if slua.isValid(Vehicle) then
    local bIsHelicopter = Vehicle:IsHelicopter()
    local NeedShowSeatGeneralUIConfig = UIManager.UI_Config_InGame.DefaultSeatGeneralUI
    if bIsHelicopter then
      if Vehicle.bAutoDrive then
        print(bWriteLog and "VehicleControlPanelIMP:RefreshSeat Vehicle AutoDrive")
        return
      end
      NeedShowSeatGeneralUIConfig = UIManager.UI_Config_InGame.HelicopterSeatGeneralUI
    end
    self:CloseCurrentSeatUI()
    if self:CanChangeSeat(Vehicle) then
      if NeedShowSeatGeneralUIConfig ~= self.CurrentSeatGeneralUIConfig then
        UIManager.CloseUI(self.CurrentSeatGeneralUIConfig)
        self.CurrentSeatGeneralUIConfig = NeedShowSeatGeneralUIConfig
        self:CreateChildWindow(self.UIRoot.CanvasPanel_SeatSocket, self.CurrentSeatGeneralUIConfig)
      end
      self.UIRoot.CanvasPanel_SeatSocket:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local SeatUI = UIManager.GetUI(self.CurrentSeatGeneralUIConfig)
      if SeatUI and SeatUI.OnEnterVehicle then
        SeatUI:OnEnterVehicle()
      end
    end
  end
end
function VehicleControlPanelIMP:CloseCurrentSeatUI()
  self.UIRoot.CanvasPanel_SeatSocket:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.CurrentSeatGeneralUIConfig then
    local SeatUI = UIManager.GetUI(self.CurrentSeatGeneralUIConfig)
    if SeatUI then
      SeatUI:CloseSeatPopupUI()
    end
  end
end
function VehicleControlPanelIMP:SwitchDriverFireState(bFire)
  print(bWriteLog and "VehicleControlPanelIMP:SwitchDriverFireState", bFire)
  if slua.isValid(self.VehicleWeaponUI) then
    self.VehicleWeaponUI:SwitchDriverFireState(false)
  end
end
function VehicleControlPanelIMP:OnUpdateVehicleWeaponUIImp(Use, VehicleWeapon)
  print(bWriteLog and "VehicleControlPanelIMP:OnUpdateVehicleWeaponUIImp")
  self.bUsedVehicleWeapon = Use
  local VehicleWeaponUIBP = self:GetVehicleWeaponUIBP(true)
  if slua.isValid(VehicleWeaponUIBP) then
    VehicleWeaponUIBP:UpdateUseVehicleWeaponUI(Use, VehicleWeapon)
    VehicleWeaponUIBP:ShowVehicleWeaponUI(self.bIsDriving)
    self:DoVehicleWeaponGUI()
  end
end
function VehicleControlPanelIMP:GetVehicleWeaponUIBP(bNeedCreate)
  if not slua.isValid(self.VehicleWeaponUI) and bNeedCreate then
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    self.VehicleWeaponUI = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/IngameUI/Ingame_ArmedVehicle_UIBP.Ingame_ArmedVehicle_UIBP_C", slua_GameFrontendHUD:GetGameInstance())
    if slua.isValid(self.VehicleWeaponUI) then
      self:TryAttachVehicleWeaponUIBP()
    else
      print(bWriteLog and "VehicleControlPanelIMP:GetVehicleWeaponUIBP IsValid == false")
    end
  end
  return self.VehicleWeaponUI
end
function VehicleControlPanelIMP:TryAttachVehicleWeaponUIBP()
  local VehicleWeaponUIBP = self:GetVehicleWeaponUIBP(false)
  if slua.isValid(VehicleWeaponUIBP) and type(self.UIRoot) ~= "table" then
    self.UIRoot.VehicleWeaponUISocket:AddChild(self.VehicleWeaponUI)
    self.VehicleWeaponUI.Slot:SetAnchors(FAnchors(0.0, 0.0, 1.0, 1.0))
    self.VehicleWeaponUI.Slot:SetOffsets(FMargin(0.0, 0.0, 0.0, 0.0))
  end
end
function VehicleControlPanelIMP:DoVehicleWeaponGUI()
  print(bWriteLog and "VehicleControlPanelIMP:DoVehicleWeaponGUI")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "VehicleControlPanelIMP:DoVehicleWeaponGUI VehicleUserComponent nil")
    return
  end
  local bShowVehicleWeaponUI = VehicleUserComponent:ShowVehicleWeaponUI()
  local VehicleWeaponUIBP = self:GetVehicleWeaponUIBP(bShowVehicleWeaponUI)
  if not slua.isValid(VehicleWeaponUIBP) then
    print(bWriteLog and "VehicleControlPanelIMP:DoVehicleWeaponGUI VehicleWeaponUIBP nil")
    return
  end
  local VehicleWeapon = VehicleUserComponent:GetCharacterVehicleWeapon()
  if not bShowVehicleWeaponUI or not slua.isValid(VehicleWeapon) then
    VehicleWeaponUIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideWeaponSlot, false)
    return
  end
  VehicleWeaponUIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.VehicleWeaponUI:UpdateUseVehicleWeaponUI(self.bUsedVehicleWeapon, VehicleWeapon)
  self.VehicleWeaponUI:ShowVehicleWeaponUI(self.bIsDriving)
end
function VehicleControlPanelIMP:UpdateDriverLastWeaponUI()
  print(bWriteLog and "VehicleControlPanelIMP:UpdateDriverLastWeaponUI")
  local DriverLastWeaponUI = UIManager.GetUI(UIManager.UI_Config_InGame.DriverLastWeaponUI)
  if DriverLastWeaponUI then
    DriverLastWeaponUI:UpdateLastWeaponUI(self.bIsDriving)
  end
end
function VehicleControlPanelIMP:CanChangeSeat(InVehicle)
  if not slua.isValid(InVehicle) then
    print(bWriteLog and "VehicleControlPanelIMP:CanChangeSeat false")
    return false
  end
  if not slua.isValid(InVehicle.VehicleSeats) or not InVehicle.VehicleSeats.bShowSeatUI then
    print(bWriteLog and "VehicleControlPanelIMP:CanChangeSeat false")
    return false
  end
  local OwnershipComponentClass = import("/Script/ShadowTrackerExtra.OwnershipComponent")
  local OwnershipComponent = InVehicle:GetComponentByClass(OwnershipComponentClass)
  if not slua.isValid(OwnershipComponent) then
    print(bWriteLog and "VehicleControlPanelIMP:CanChangeSeat true")
    return true
  end
  if OwnershipComponent:CanBorrow() then
    print(bWriteLog and "VehicleControlPanelIMP:CanChangeSeat true")
    return true
  end
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    local PlayerKey = PlayerState:GetPlayerKey()
    return OwnershipComponent:BelongToBP(PlayerKey) or OwnershipComponent:BorrowedByBP(PlayerKey)
  end
  return true
end
function VehicleControlPanelIMP:RefreshVehicleIcon(VehicleType)
  if not slua.isValid(self.UIRoot) then
    return
  end
  local VehicleType, ButtonStyle
  local ButtonStyleIndex = self._CurrentStyleIndex
  if VehicleType == ESTExtraVehicleType.VT_Bike or VehicleType == ESTExtraVehicleType.VT_Bike_WithRack or VehicleType == ESTExtraVehicleType.VT_SciFi then
    ButtonStyleIndex = 2
  else
    ButtonStyleIndex = 1
  end
  if ButtonStyleIndex ~= self._CurrentStyleIndex then
    self._CurrentStyleIndex = ButtonStyleIndex
    ButtonStyle = self.UIRoot.HornButtonStyleMap:Get(ButtonStyleIndex)
    if ButtonStyle then
      self.UIRoot.RightCarSpeaker:SetStyle(ButtonStyle)
    end
  end
end
function VehicleControlPanelIMP:OnSwitchDriverFireState(bFire)
  self:SwitchDriverFireState(bFire)
  return false
end
function VehicleControlPanelIMP:OnUpdateVehicleWeaponUI(bUse, VehicleWeapon)
  self:OnUpdateVehicleWeaponUIImp(bUse, VehicleWeapon)
  return false
end
function VehicleControlPanelIMP:RefreshChargingState(State)
  return false
end
function VehicleControlPanelIMP:PlayBtnAnim(AnimToPlay, AnimToStop)
  if slua.isValid(AnimToStop) then
    self.UIRoot:StopAnimation(AnimToStop)
  end
  if slua.isValid(AnimToPlay) then
    Client.RequireSlateTickEveryFrameBeforeTargetFrame(65)
    self:PlayUserWidgetAnimation(AnimToPlay, 0, 1, 0, 1)
  end
end
function VehicleControlPanelIMP:GetVehicleUserComponent()
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    return VehicleControlUISubSystem:GetVehicleUserComponent()
  end
end
function VehicleControlPanelIMP:GetCurVehicle()
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    return VehicleControlUISubSystem:GetCurVehicle()
  end
end
function VehicleControlPanelIMP:GetVehicleType()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle) then
    return VehicleUserComponent.Vehicle.VehicleType
  end
  return ESTExtraVehicleType.VT_Unknown
end
function VehicleControlPanelIMP:GetVehicleShapeType()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle) then
    print(bWriteLog and "VehicleControlPanelIMP: GetVehicleShapeType ", VehicleUserComponent.Vehicle.VehicleShapeType)
    return VehicleUserComponent.Vehicle.VehicleShapeType
  end
  return ESTExtraVehicleShapeType.VST_Unknown
end
function VehicleControlPanelIMP:IsDriving()
  return self.bIsDriving
end
function VehicleControlPanelIMP:SetColorAndOpacity(InColor)
  self.UIRoot:SetColorAndOpacity(InColor)
end
function VehicleControlPanelIMP:DestroyVehicleWeaponUI()
  print(bWriteLog and "VehicleControlPanelIMP:DestroyVehicleWeaponUI 0")
  local VehicleWeaponUI = self:GetVehicleWeaponUIBP(false)
  if Game:IsValid(VehicleWeaponUI) then
    self.VehicleWeaponUI = nil
    VehicleWeaponUI:RemoveFromParent()
    local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideWeaponSlot, false)
    print(bWriteLog and "VehicleControlPanelIMP:DestroyVehicleWeaponUI 1")
  end
end
function VehicleControlPanelIMP:OnHide()
  self:DestroyVehicleWeaponUI()
  self:HideVehicleControlGUI()
end
function VehicleControlPanelIMP:OnClose()
  print(bWriteLog and "VehicleControlPanelIMP:OnClose")
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_LeaveVehicle)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_SeatSocket)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Miscellaneous)
  UIManager.CloseUI(UIManager.UI_Config_InGame.VehicleSkinAndMusicButton)
  VehicleControlPanelIMP.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, VehicleControlPanelIMP)