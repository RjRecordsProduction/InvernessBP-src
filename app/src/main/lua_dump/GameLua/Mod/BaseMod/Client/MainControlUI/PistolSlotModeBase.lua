local PistolSlotModeBase = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local WeaponSlotsConfig = require("GameLua.Mod.BaseMod.Client.PlayerInfoPanel.WeaponSlots.WeaponSlotsConfig")
local OutOfAmmoRed = FLinearColor(0.871367, 0.048172, 0.0, 1.0)
local NormalAmmoGrey = FLinearColor(1, 1, 1, 0.8)
local NormalAmmoWhite = FLinearColor(1, 1, 1, 1)
function PistolSlotModeBase:ctor(selfType)
  self.AttachmentType = 2
  self.AnimationQueue = {}
  self.CountYellow = 0.0
  self.CountRed = 0.0
  self.WeaponDurabilityColor = nil
  self.WeaponDurabilityStatus = 0
  self.BulletWeapon = 0
  self.BulletBack = 0
end
function PistolSlotModeBase:RegistEvents()
  print(bWriteLog and "PistolSlotModeBase:RegistEvents")
  PistolSlotModeBase.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "ClickOnSwitchWeapon", self.ClickOnSwitchWeapon, self, ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
  self:AddControlEventByControl(self.UIRoot, "ShowLongGunFireMode", self.ShowLongGunFireMode, self)
end
function PistolSlotModeBase:OnInitialize()
  print(bWriteLog and "PistolSlotModeBase:OnInitialize")
  PistolSlotModeBase.__super.OnInitialize(self)
end
function PistolSlotModeBase:ClickOnSwitchWeapon(Slot)
  print(bWriteLog and "PistolSlotModeBase:ClickOnSwitchWeapon " .. tostring(Slot))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "PistolSlotModeBase:ClickOnSwitchWeapon not uPlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "PistolSlotModeBase:ClickOnSwitchWeapon not WeaponManager")
    return
  end
  local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(Slot)
  if Weapon then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
    if not ShootingUIPanelLuaClass then
      return
    end
    ShootingUIPanelLuaClass:HandleTopRightWeaponSwitch(Slot)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 or ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:SendQuickNeedText(23)
    end
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.SwitchWeapon, 1)
  end
end
function PistolSlotModeBase:ShowLongGunFireMode(bShow)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if not ShootingUIPanelLuaClass then
    return
  end
  ShootingUIPanelLuaClass:ShowLongGunFireMode(bShow)
end
function PistolSlotModeBase:UpdateWeaponDurability(ShootWeapon)
  if slua.isValid(ShootWeapon) then
    local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
    local WeaponDurability = ShootWeapon:GetWeaponDurability()
    if IsEnableWeaponDurability then
      local ConstantWeaponDurability = ShootWeapon:GetConstantWeaponDurabilityFromEntity()
      local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
      local OutColor, Status = GlobalBattleUIFunctionLibrary.GetDurabilityColorConfig(WeaponDurability, ConstantWeaponDurability)
      local SpecifiedColor = OutColor.SpecifiedColor
      self.WeaponDurabilityColor = SpecifiedColor
      self.WeaponDurability      self:UpdateWeaponDurabilityColor()
    end
  end
end
function PistolSlotModeBase:UpdateWeaponDurabilityColor()
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if not IsEnableWeaponDurability then
    return
  end
  if self.WeaponDurabilityStatus == 0 then
    self.UIRoot.WeaponDurabilitySelected:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.WeaponDurabilityUnselected:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  else
    self.UIRoot.WeaponDurabilitySelected:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.WeaponDurabilityUnselected:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.WeaponDurabilitySelected:SetColorAndOpacity(self.WeaponDurabilityColor)
    self.UIRoot.WeaponDurabilityUnselected:SetColorAndOpacity(self.WeaponDurabilityColor)
  end
end
function PistolSlotModeBase:SetRenderScale(Scale)
  if self.UIRoot then
    self.UIRoot:SetRenderScale(Scale)
  end
end
function PistolSlotModeBase:SetColorAndOpacity(Color)
  if self.UIRoot then
    self.UIRoot:SetColorAndOpacity(Color)
  end
end
function PistolSlotModeBase:SetBorderOpacity(Opacity)
  if self.UIRoot then
    self.UIRoot.Border_WeaponIcon1:SetContentColorAndOpacity(FLinearColor(1, 1, 1, Opacity))
  end
end
function PistolSlotModeBase:GetAttachmentImage(DefineID)
  local ItemData = CDataTable.GetTableData("Item", DefineID)
  if ItemData then
    local AttachmentType = 2
    if ItemData.ItemType == AttachmentType then
      return ItemData.ItemSmallIcon
    end
  end
  return ""
end
function PistolSlotModeBase:PlayAnimationInQueue()
  local bIsPlaying = self.UIRoot:IsAnimationPlaying(self.UIRoot.DX_GetItem)
  if bIsPlaying then
    return
  end
  if #self.AnimationQueue > 0 then
    local Icon = table.remove(self.AnimationQueue, 1)
    if not slua.isValid(Icon) then
      return
    end
    self.UIRoot.Item:SetBrushFromTexture(Icon, false)
    self.UIRoot.Item:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      local BPVehicleUser = PlayerController:GetVehicleUserComp()
      if slua.isValid(BPVehicleUser) then
        local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
        local VehicleUserState = BPVehicleUser.VehicleUserState
        if VehicleUserState == ESTExtraVehicleUserState.EVUS_OutOfVehicle or VehicleUserState == ESTExtraVehicleUserState.EVUS_ASPassenger then
          self:PlayUserWidgetAnimation(self.UIRoot.DX_GetItem, 0, 1, 0, 1)
        end
      end
    end
  end
end
function PistolSlotModeBase:InitAccessoryDescItemUI()
  self.AccessoryDescWiddgetTable = {}
  for i = 1, 4 do
    local AccessoryDescItemUI = UIManager.ShowUI(UIManager.UI_Config_InGame.AccessoryDescItemUI)
    if AccessoryDescItemUI then
      AccessoryDescItemUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.Box_AttributeItem:AddChild(AccessoryDescItemUI.UIRoot)
      AccessoryDescItemUI:SetAnchors(0, 0, 1, 1)
      self.AccessoryDescWiddgetTable[i] = AccessoryDescItemUI
    else
      print(bWriteLog and "PistolSlotModeBase:InitAccessoryDescItemUI: AccessoryDescItemUI is nil")
    end
  end
end
function PistolSlotModeBase:HideAllAccessoryDesc()
  for ArrayIndex, ArrayElement in pairs(self.AccessoryDescWiddgetTable) do
    ArrayElement:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PistolSlotModeBase:ShowItemAccessoryDesc(ItemID)
  print(bWriteLog and "PistolSlotModeBase:UpdateAccessoryDesc")
  local UIRoot = self.UIRoot
  local AccessoryDescData = CDataTable.GetTableData("AccessoryDesc", ItemID)
  if not AccessoryDescData then
    self:HideAllAccessoryDesc()
    return
  end
  local MarksArray = AccessoryDescData.Marks_a
  local DescriptionsArray = AccessoryDescData.Descriptions2_a
  if MarksArray:Num() ~= DescriptionsArray:Num() or MarksArray:Num() == 0 then
    self:HideAllAccessoryDesc()
    return
  end
  local NumOfMarks = MarksArray:Num()
  for Num = 1, NumOfMarks do
    local AccessoryDesc = self.AccessoryDescWiddgetTable[Num]
    if not AccessoryDesc then
      print(bWriteLog and "PistolSlotModeBase:ShowItemAccessoryDesc: AccessoryDesc is nil" .. tostring(Num))
      return
    end
    if Num <= NumOfMarks then
      AccessoryDesc:UpdateAccessoryDescUI(Num, DescriptionsArray)
    else
      AccessoryDesc:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function PistolSlotModeBase:AddAttachmentAnimationToQuereAsync(Icon, ItemID)
  if not slua.isValid(Icon) then
    return
  end
  table.insert(self.AnimationQueue, Icon)
  self:PlayAnimationInQueue()
end
function PistolSlotModeBase:AddAttachmentAnimationToQuere(DefineID)
  local AttachmentImage = self:GetAttachmentImage(DefineID.TypeSpecificID)
  local util = require("client.slua_ui_framework.util")
  util.GetAssetAsync(AttachmentImage, function(LoadObj)
    if LoadObj then
      self:AddAttachmentAnimationToQuereAsync(LoadObj, nil)
    end
  end)
end
function PistolSlotModeBase:SetLeftBulletRate(CountYellow, CountRed)
  self.  self.end
function PistolSlotModeBase:RefreshWeaponImage(ImagePath)
  if self.UIRoot then
    self.UIRoot.profile1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if ImagePath and type(ImagePath) == "string" then
      self.UIRoot.profile1:SetBrushFromPathAsync(ImagePath, false)
    end
  end
end
function PistolSlotModeBase:ChangeWeaponImage(ImagePath)
  self.UIRoot.profile1:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self:RefreshWeaponImage(ImagePath)
end
function PistolSlotModeBase:UpdatePistol()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local CurrWeapon = self:GetCurrWeapon()
  if not CurrWeapon or not slua.isValid(CurrWeapon) then
    return
  end
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  local bCanRecordHitDetailFromEntity = CurrWeapon:GetCanRecordHitDetailFromEntity()
  if bCanRecordHitDetailFromEntity then
    self.UIRoot.HitRecordTagSelected:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.HitRecordTagUnselected:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.UIRoot.HitRecordTagSelected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.HitRecordTagUnselected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local CurrentUsingPropSlot = WeaponManager:GetCurrentUsingPropSlot()
  if CurrentUsingPropSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    if CurrWeapon:IsShowBulletRemainPercentForUI() then
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
      self.UIRoot.profile1:SetRenderTranslation(FVector2D(-10, 3))
    else
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
      self.UIRoot.profile1:SetRenderTranslation(FVector2D(0, 0))
    end
    self:SetFireModeText(CurrWeapon)
    self:ShowOrHideFireMode(true)
    local uPlayerController = GameplayData.GetPlayerController()
    local uBackpackComponent = uPlayerController:GetBackpackComponent()
    if not slua.isValid(uBackpackComponent) then
      return
    end
    local WeaponEntityComponent = CurrWeapon.GetWeaponEntityComponent and CurrWeapon:GetWeaponEntityComponent()
    if not WeaponEntityComponent or not slua.isValid(WeaponEntityComponent) then
      return
    end
    local AvatarUtils = import("AvatarUtils")
    local nAvailableBulletsNumInBackpack = AvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(uBackpackComponent, WeaponEntityComponent.BulletType)
    local nCurrentBulletNumInClip = CurrWeapon:GetCurrentBulletNumInClip(0)
    self:UpdateBulletCounts(nCurrentBulletNumInClip, nAvailableBulletsNumInBackpack, WeaponEntityComponent.BulletType)
    self:UpdateWeaponDurability(CurrWeapon)
    local ItemDefineID = CurrWeapon:GetItemDefineID()
    local TypeSpecificID = ItemDefineID.TypeSpecificID
    local ItemData = CDataTable.GetTableData("Item", TypeSpecificID)
    if ItemData then
      local SlotConfig = WeaponSlotsConfig.PistolWeaponConfig[TypeSpecificID]
      local sImagePath = ItemData.ItemWhiteIcon
      if SlotConfig and SlotConfig.ImagePath then
        sImagePath = SlotConfig.ImagePath
      end
      self:ChangeWeaponImage(sImagePath)
    end
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self:UpdateWeaponDurability(CurrWeapon)
    self:UpdateWeaponLittleIcon(CurrWeapon)
  end
end
function PistolSlotModeBase:UpdateWeaponLittleIcon(CurWeapon)
  local ItemDefineID = CurWeapon:GetItemDefineID()
  local TypeSpecificID = ItemDefineID.TypeSpecificID or 0
  local SlotConfig = WeaponSlotsConfig.PistolWeaponConfig
  if SlotConfig[TypeSpecificID] and CurWeapon.bIsPistol then
    if CDataTable.GetTableData("Item", TypeSpecificID) ~= nil then
      local sPath = tostring(CDataTable.GetTableData("Item", tostring(TypeSpecificID)).ItemWhiteIcon)
      if SlotConfig[TypeSpecificID].ImagePath then
        sPath = SlotConfig[TypeSpecificID].ImagePath
      end
      self.UIRoot.Little_Icon:SetBrushFromPathAsync(sPath, true)
      self.UIRoot.Little_Icon.Slot:SetSize(FVector2D(SlotConfig[TypeSpecificID].Size.X, SlotConfig[TypeSpecificID].Size.Y))
    end
  else
    self.UIRoot.Little_Icon:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_shouqiang_1_png.ZD_icon_shouqiang_1_png", true)
    self.UIRoot.Little_Icon.Slot:SetSize(FVector2D(43, 32))
  end
end
function PistolSlotModeBase:SetDropIconByDropCategory(Weapon)
  if not slua.isValid(Weapon) then
    return
  end
  local sCurrentDropCategory = Weapon:GetCurrentDropCategory()
  if sCurrentDropCategory == "AirdropTank" then
    self.UIRoot.WidgetSwitcher_AirDropType:SetActiveWidgetIndex(2)
  elseif sCurrentDropCategory == "Revive" then
    self.UIRoot.WidgetSwitcher_AirDropType:SetActiveWidgetIndex(3)
  end
end
function PistolSlotModeBase:UpdateAirDropType(IsInWhiteCircle)
  if self.UIRoot.CanvasPanel_AirDrop:GetVisibility() == UEnums.ESlateVisibility.HitTestInvisible then
    local uWeapon = self:GetCurrWeapon()
    if Game:IsValid(uWeapon) and IsInWhiteCircle then
      self.UIRoot.WidgetSwitcher_AirDropType:SetActiveWidgetIndex(0)
    else
      self.UIRoot.WidgetSwitcher_AirDropType:SetActiveWidgetIndex(1)
    end
  end
end
function PistolSlotModeBase:ShowOrHideFireMode(bIsShow)
  print(bWriteLog and "PistolSlotModeBase:ShowOrHideFireMode 0")
  if not self.UIRoot then
    return
  end
  self.UIRoot.CanvasPanel_AirDrop:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  local CurrWeapon = self:GetCurrWeapon()
  if not CurrWeapon or not slua.isValid(CurrWeapon) then
    return
  end
  if bIsShow and self:CanShowFireModeSwitchBtn(CurrWeapon) then
    self.UIRoot.fireModePanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Button_ChangeShootingType:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetFireModeText(CurrWeapon)
  else
    self.UIRoot.fireModePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.Button_ChangeShootingType:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if slua.isValid(CurrWeapon) and CurrWeapon.GetCurrentAirDropType then
      print(bWriteLog and "PistolSlotModeBase:ShowOrHideFireMode 1")
      local nCurrentAirDropType = CurrWeapon:GetCurrentAirDropType()
      local EAirDropType = import("EAirDropType")
      if nCurrentAirDropType == EAirDropType.AirDrop_SuperAirDrop then
        self.UIRoot.WidgetSwitcher_AirDropType:SetActiveWidgetIndex(0)
      elseif nCurrentAirDropType == EAirDropType.AirDrop_VehicleAirDrop then
        self.UIRoot.WidgetSwitcher_AirDropType:SetActiveWidgetIndex(1)
      end
      if nCurrentAirDropType == EAirDropType.AirDrop_SuperAirDrop or nCurrentAirDropType == EAirDropType.AirDrop_VehicleAirDrop then
        self:SetDropIconByDropCategory(CurrWeapon)
        self.UIRoot.CanvasPanel_AirDrop:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        local uPlayerController = GameplayData.GetPlayerController()
        self:RemoveControlEventByControl(uPlayerController, "OnPlayerInOutWhiteCircleChangedDelegate")
        self:AddControlEventByControl(uPlayerController, "OnPlayerInOutWhiteCircleChangedDelegate", self.UpdateAirDropType, self)
      end
    end
  end
end
function PistolSlotModeBase:CanShowFireModeSwitchBtn(Weapon)
  if not slua.isValid(Weapon) then
    return
  end
  if not slua.isValid(Weapon.ShootWeaponComponent) then
    return
  end
  local ShootWeaponEntityComponent = Weapon.ShootWeaponComponent.ShootWeaponEntityComponent
  if not slua.isValid(ShootWeaponEntityComponent) then
    return
  end
  local nHasSingleFireMode = ShootWeaponEntityComponent.bHasSingleFireMode and 1 or 0
  local nHasBurstFireMode = ShootWeaponEntityComponent.bHasBurstFireMode and 1 or 0
  local nHasAutoFireMode = ShootWeaponEntityComponent.bHasAutoFireMode and 1 or 0
  return 1 < nHasSingleFireMode + nHasBurstFireMode + nHasAutoFireMode
end
function PistolSlotModeBase:SetFireModeText(Weapon)
  if not slua.isValid(Weapon) then
    return
  end
  local ShootType = Weapon:GetShootTypeFromEntity()
  local ESTEWeaponShootType = import("ESTEWeaponShootType")
  if ShootType == ESTEWeaponShootType.OneBulletBursting then
    self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(4439))
  elseif ShootType == ESTEWeaponShootType.MultiBulletsBursting then
    self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(4440))
  elseif ShootType == ESTEWeaponShootType.Auto then
    self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(4441))
  end
end
function PistolSlotModeBase:IsLowBulletToYellow()
  if self.CountRed == 0 and self.CountYellow == 0 then
    return false
  end
  local CurrWeapon = self:GetCurrWeapon()
  if not CurrWeapon or not slua.isValid(CurrWeapon) then
    return false
  end
  local nCurMaxBulletNumInOneClip = CurrWeapon.CurMaxBulletNumInOneClip
  if not nCurMaxBulletNumInOneClip or nCurMaxBulletNumInOneClip <= 4 then
    return false
  end
  local nCurrBullets = tonumber(self.UIRoot.pistol_CurrBullets2:GetText())
  return nCurrBullets <= math.ceil(nCurMaxBulletNumInOneClip * self.CountYellow)
end
function PistolSlotModeBase:IsLowBulletToRed()
  if self.CountRed == 0 and self.CountYellow == 0 then
    return false
  end
  local CurrWeapon = self:GetCurrWeapon()
  if not CurrWeapon or not slua.isValid(CurrWeapon) then
    return false
  end
  local nCurMaxBulletNumInOneClip = CurrWeapon.CurMaxBulletNumInOneClip
  if not nCurMaxBulletNumInOneClip or nCurMaxBulletNumInOneClip <= 4 then
    return false
  end
  local nCurrBullets = tonumber(self.UIRoot.pistol_CurrBullets2:GetText())
  return nCurrBullets <= math.ceil(nCurMaxBulletNumInOneClip * self.CountRed)
end
function PistolSlotModeBase:ChangeImageAndTextColor(IsGunRunOutOfAmmo)
  if IsGunRunOutOfAmmo then
    self.UIRoot.TextBlock_42:SetColorAndOpacity(FSlateColor(OutOfAmmoRed))
    self.UIRoot.pistol_MaxTBullets2:SetColorAndOpacity(FSlateColor(OutOfAmmoRed))
    self.UIRoot.pistol_CurrBullets2:SetColorAndOpacity(FSlateColor(OutOfAmmoRed))
    self.UIRoot.profile1:SetColorAndOpacity(OutOfAmmoRed)
  else
    self.UIRoot.TextBlock_42:SetColorAndOpacity(FSlateColor(NormalAmmoWhite))
    self.UIRoot.pistol_CurrBullets2:SetColorAndOpacity(FSlateColor(NormalAmmoWhite))
    self.UIRoot.pistol_MaxTBullets2:SetColorAndOpacity(FSlateColor(NormalAmmoGrey))
    self.UIRoot.profile1:SetColorAndOpacity(NormalAmmoWhite)
    if self.UIRoot.WidgetSwitcher_0:GetActiveWidgetIndex() == 1 and self:IsLowBulletToYellow() then
      self.UIRoot.pistol_CurrBullets2:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0.7, 0, 1)))
    end
    if self.UIRoot.WidgetSwitcher_0:GetActiveWidgetIndex() == 1 and self:IsLowBulletToRed() then
      self.UIRoot.pistol_CurrBullets2:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0, 0, 1)))
    end
  end
end
function PistolSlotModeBase:GetBackpackBulletNum()
  local uPlayerController = GameplayData.GetPlayerController()
  local uBackpackComponent = uPlayerController:GetBackpackComponent()
  local CurrWeapon = self:GetCurrWeapon()
  local WeaponEntityComponent = CurrWeapon.WeaponEntityComponent
  if slua.isValid(uBackpackComponent) and slua.isValid(WeaponEntityComponent) then
    local nAvailableBulletsNumInBackpack = WeaponEntityComponent:GetAvailableBulletsNumInBackpackByDefineID(uBackpackComponent, WeaponEntityComponent.BulletType)
    return nAvailableBulletsNumInBackpack
  end
  return 0
end
function PistolSlotModeBase:UpdateBulletCounts(BulletInWeapon, BulletInBackpack, BulletType)
  self.BulletWeapon = BulletInWeapon
  self.BulletBack = BulletInBackpack
  local CurrWeapon = self:GetCurrWeapon()
  if not CurrWeapon or not slua.isValid(CurrWeapon) then
    return
  end
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  if BulletType.Type ~= 0 and BulletType.TypeSpecificID ~= 0 then
    self.UIRoot.HorizontalBox_BulletNum:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.BulletWeapon >= 0 then
      if self.UIRoot.pistol_CurrBullets2:GetText() ~= tostring(self.BulletWeapon) then
        self:PlayUserWidgetAnimation(self.UIRoot.BulletChangeAnim, 0, 1, 0, 1)
      end
      self.UIRoot.pistol_CurrBullets2:SetText(tostring(self.BulletWeapon))
      self.UIRoot.pistol_CurrBullets2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.BulletBack >= 0 then
      if CurrWeapon:GetReloadWithNoCostFromEntity() then
        self.UIRoot.pistol_MaxTBullets2:SetText("\226\136\158")
      else
        self.UIRoot.pistol_MaxTBullets2:SetText(tostring(self.BulletBack))
      end
      self.UIRoot.TextBlock_42:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.pistol_MaxTBullets2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.BulletWeapon > 0 then
    else
      self.BulletBack = self:GetBackpackBulletNum()
    end
    local bIsGunRunOutOfAmmo = self.BulletWeapon <= 0 and self.BulletBack <= 0
    self:ChangeImageAndTextColor(bIsGunRunOutOfAmmo)
    if self.UIRoot.WidgetSwitcher_1:GetActiveWidgetIndex() == 1 then
      local nCurBulletRemainPercent = CurrWeapon:GetCurBulletRemainPercent()
      self.UIRoot.ProgressBar_0:SetPercent(nCurBulletRemainPercent)
    end
  else
    self.UIRoot.HorizontalBox_BulletNum:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:ChangeImageAndTextColor(false)
  end
end
function PistolSlotModeBase:GetCurrWeapon()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  return WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
end
function PistolSlotModeBase:UpdateWeaponDurabilityAnimation()
  local ShootWeapon = self:GetCurrWeapon()
  if not ShootWeapon or not slua.isValid(ShootWeapon) then
    return
  end
  local WeaponDurability = ShootWeapon:GetWeaponDurability()
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if IsEnableWeaponDurability and WeaponDurability <= 0 then
    if self.UIRoot.WeaponDurabilitySelected:IsVisible() then
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_WeaponDurabilitySelected, 0, 1, 0, 1)
    end
    if self.UIRoot.WeaponDurabilityUnselected:IsVisible() then
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_WeaponDurabilityUnSelected, 0, 1, 0, 1)
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, PistolSlotModeBase)