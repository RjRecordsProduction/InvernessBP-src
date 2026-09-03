local PistolInfoItemUI = {}
local EAirDropType = import("EAirDropType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function PistolInfoItemUI:ctor()
  self.bPistolInfoItem = true
end
function PistolInfoItemUI:OnInitialize()
  PistolInfoItemUI.__super.OnInitialize(self)
  local UIRoot = self.UIRoot
  UIRoot.HitRecordTag:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.TextBlock_ForbidReload:SetText(LocUtil.LocalizeResFormat(12455))
end
function PistolInfoItemUI:UpdateCoreSlot()
end
function PistolInfoItemUI:HideSinkSlotVisiblity()
  self.UIRoot.FitingSlotItem_BP_C_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function PistolInfoItemUI:GetCurrentWeaponItemArray()
  local UIRoot = self.UIRoot
  return {
    UIRoot.FitingSlotItem_BP,
    UIRoot.FitingSlotItem_BP_C_0,
    UIRoot.FitingSlotItem_BP_C_1,
    UIRoot.FitingSlotItem_BP_C_3,
    UIRoot.FitingSlotItem_BP_C_2
  }
end
function PistolInfoItemUI:UpdateWeaponAppearanceInfo(TypeSpecificID, ItemData, DragOrigin)
  PistolInfoItemUI.__super.UpdateWeaponAppearanceInfo(self, TypeSpecificID, ItemData, DragOrigin)
  self:CheckShowImage(ItemData)
  local UIRoot = self.UIRoot
  if TypeSpecificID == 0 then
    UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    local uPlayerController = GameplayData.GetPlayerController()
    self:RemoveControlEventByControl(uPlayerController, "OnPlayerInOutWhiteCircleChangedDelegate")
    if not Game:IsValid(uPlayerController) then
      print(bWriteLog and "PistolInfoItemUI:UpdateWeaponAppearanceInfo uPlayerController is not valid")
      UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    local uWeapon = self:GetCurrentWeapon()
    if not Game:IsValid(uWeapon) then
      print(bWriteLog and "PistolInfoItemUI:UpdateWeaponAppearanceInfo uWeapon is not valid")
      UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    local ASTExtraFlareGunShootWeapon = import("STExtraFlareGunShootWeapon")
    if not Game:IsClassOf(uWeapon, ASTExtraFlareGunShootWeapon) then
      print(bWriteLog and "PistolInfoItemUI:UpdateWeaponAppearanceInfo uWeapon is not STExtraFlareGunShootWeapon")
      UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self:AddControlEventByControl(uPlayerController, "OnPlayerInOutWhiteCircleChangedDelegate", self.UpdateAirDropType, self)
    self:SetAirDropType(uWeapon:GetCurrentAirDropType())
  end
end
function PistolInfoItemUI:CheckShowImage(BattleData)
  local UIRoot = self.UIRoot
  UIRoot.Image_Equipment:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if BattleData and BattleData.AdditionalData then
    local HandleItemOwnerSubsystem = SubsystemMgr:Get("HandleItemOwnerSubsystem")
    if HandleItemOwnerSubsystem then
      local uPlayerState = GameplayData.GetPlayerState()
      if slua.isValid(uPlayerState) then
        local IsTeamMateOwner = HandleItemOwnerSubsystem:IsTeamMateOwner(BattleData.AdditionalData, uPlayerState)
        if IsTeamMateOwner then
          UIRoot.Image_Equipment:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
end
function PistolInfoItemUI:UpdateAirDropType(IsInWhiteCircle)
  local UIRoot = self.UIRoot
  if UIRoot.CanvasPanel_AirdropInfo:GetVisibility() == UEnums.ESlateVisibility.HitTestInvisible then
    local uWeapon = self:GetCurrentWeapon()
    if Game:IsValid(uWeapon) and uWeapon.GetCurrentAirDropType then
      self:SetAirDropType(uWeapon:GetCurrentAirDropType())
    end
  end
end
function PistolInfoItemUI:SetAirDropType(AirDropType)
  local UIRoot = self.UIRoot
  if AirDropType == EAirDropType.AirDrop_SuperAirDrop then
    UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    UIRoot.WidgetSwitcher_BoxState:SetActiveWidgetIndex(1)
    UIRoot.WidgetSwitcher_VehicleState:SetActiveWidgetIndex(0)
  elseif AirDropType == EAirDropType.AirDrop_VehicleAirDrop then
    UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    UIRoot.WidgetSwitcher_BoxState:SetActiveWidgetIndex(0)
    UIRoot.WidgetSwitcher_VehicleState:SetActiveWidgetIndex(1)
  else
    UIRoot.CanvasPanel_AirdropInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PistolInfoItemUI:InitGunHitInfoTag()
  local CurrentWeapon = self:GetCurrentWeapon()
  if not slua.isValid(CurrentWeapon) then
    print(bWriteLog and "PistolInfoItemUI:InitGunHitInfoTag CheckCurrentWeapon failed")
    return
  end
  if CurrentWeapon:GetCanRecordHitDetailFromEntity() then
    self.UIRoot.HitRecordTag:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.UIRoot.HitRecordTag:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PistolInfoItemUI:GetWeaponInfoName()
  return "PistolInfo"
end
local class = require("class")
local WeaponInfoItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.WeaponInfoItemBase")
return class(WeaponInfoItemBase, nil, PistolInfoItemUI)