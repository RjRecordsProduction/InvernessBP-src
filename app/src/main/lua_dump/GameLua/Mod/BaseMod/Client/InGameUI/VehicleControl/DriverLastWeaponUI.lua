local DriverLastWeaponUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local VehicleControlUIConfig = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIConfig")
function DriverLastWeaponUI:ctor()
  self.CurrLastWeapon = nil
  self.ModWeaponUI = {}
end
function DriverLastWeaponUI:OnInitialize()
  log(bWriteLog and "DriverLastWeaponUI:OnInitialize")
end
function DriverLastWeaponUI:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_AMMO_3, self.RefreshLastVehicleWeaponInfo, self)
end
function DriverLastWeaponUI:OnPostInitialize()
  log(bWriteLog and "DriverLastWeaponUI:OnPostInitialize")
end
function DriverLastWeaponUI:OnClose()
  log(bWriteLog and "DriverLastWeaponUI:OnClose")
  for WeaponID, WeaponLabelUI in pairs(self.ModWeaponUI) do
    if WeaponLabelUI.LabelUI then
      WeaponLabelUI.LabelUI:Close()
    end
    if WeaponLabelUI.SlotUI then
      WeaponLabelUI.SlotUI:Close()
    end
    WeaponLabelUI = nil
    self.ModWeaponUI[WeaponID] = nil
  end
end
function DriverLastWeaponUI:UpdateWeaponImage(Weapon)
  if not self.UIRoot then
    return
  end
  if not slua.isValid(Weapon) then
    return
  end
  local ItemDefineID = Weapon:GetItemDefineID()
  local ItemInfo = CDataTable.GetTableData("Item", ItemDefineID.TypeSpecificID)
  if ItemInfo then
    self.UIRoot.ProfileImg:SetBrushFromPathAsync(ItemInfo.ItemWhiteIcon, false)
    self.UIRoot.ProfileImg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local STExtraShootWeapon = import("STExtraShootWeapon")
  if Game:IsClassOf(Weapon, STExtraShootWeapon) then
    self.UIRoot.BulletsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshBullets(Weapon)
  else
    self.UIRoot.BulletsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:UpdateModWeaponUI(Weapon)
end
function DriverLastWeaponUI:UpdateModWeaponUI(Weapon)
  local ItemDefineID = Weapon:GetItemDefineID()
  local ItemID = ItemDefineID.TypeSpecificID
  for WeaponID, ModWeaponUI in pairs(self.ModWeaponUI) do
    if ModWeaponUI and ItemID ~= WeaponID then
      if ModWeaponUI.LabelUI then
        ModWeaponUI.LabelUI:Close()
      end
      if ModWeaponUI.SlotUI then
        ModWeaponUI.SlotUI:Close()
      end
      self.ModWeaponUI[WeaponID] = nil
    end
  end
  local ModWeaponConfig = GamePlayTools.GetCurrentConfig("ModWeaponConfig")
  local WeaponConfig = ModWeaponConfig[ItemID]
  if ModWeaponConfig and WeaponConfig and (WeaponConfig.LabelUIConfig or WeaponConfig.WeaponSlotUI) then
    local ModWeaponUI = self.ModWeaponUI[ItemID]
    if not ModWeaponUI then
      self.ModWeaponUI[ItemID] = {LabelUI = nil, SlotUI = nil}
    end
    local ModWeaponLabel = self.ModWeaponUI[ItemID].LabelUI
    if not ModWeaponLabel then
      local LabelUIConfig = WeaponConfig.LabelUIConfig
      if LabelUIConfig then
        local LabelConfig = UIManager.UI_Config_InGame[LabelUIConfig]
        self.ModWeaponUI[ItemID].LabelUI = self:CreateChildWindow("CanvasPanel_UIEffect", LabelConfig, 1)
      end
    else
      ModWeaponLabel:SelfHitTestInvisible()
    end
    local ModWeaponSlot = self.ModWeaponUI[ItemID].SlotUI
    if not ModWeaponSlot then
      local WeaponSlotUIConfig = WeaponConfig.WeaponSlotUI
      if WeaponSlotUIConfig then
        local WeaponSlotConfig = UIManager.UI_Config_InGame[WeaponSlotUIConfig]
        local SlotUI = self:CreateChildWindow("CanvasPanel_2", WeaponSlotConfig)
        self.ModWeaponUI[ItemID].        if SlotUI and SlotUI.UpdateCurrentWeapon then
          SlotUI:UpdateCurrentWeapon(Weapon)
        end
        if not ModWeaponConfig.bShowWeaponSlotProfileImg then
          self.UIRoot.ProfileImg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      end
    else
      ModWeaponSlot:SelfHitTestInvisible()
      if not ModWeaponConfig.bShowWeaponSlotProfileImg then
        self.UIRoot.ProfileImg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  elseif ItemID ~= 0 then
    self.UIRoot.ProfileImg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function DriverLastWeaponUI:RefreshBullets(ShootingWeapon)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local WeaponEntityComponent = ShootingWeapon:GetWeaponEntityComponent()
  if slua.isValid(WeaponEntityComponent) then
    local BulletType = WeaponEntityComponent:GetBulletType()
    if BulletType.Type ~= 0 and BulletType.TypeSpecificID ~= 0 then
      self.UIRoot.BulletsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local CurrentBulletNumInClip = ShootingWeapon:GetCurrentBulletNumInClip(0)
      self.UIRoot.TextBlock_CarrierBullets_Surplus:SetText(tostring(CurrentBulletNumInClip))
      local Backpackcomp = PlayerController:GetBackpackComponent()
      if slua.isValid(Backpackcomp) then
        if ShootingWeapon:GetReloadWithNoCostFromEntity() then
          self.UIRoot.TextBlock_CarrierBullets_Total:SetText("\226\136\158")
        else
          local AvatarUtils = import("AvatarUtils")
          local AvailableBulletsNumInBackpackByDefineID = AvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(Backpackcomp, WeaponEntityComponent.BulletType)
          self.UIRoot.TextBlock_CarrierBullets_Total:SetText(tostring(AvailableBulletsNumInBackpackByDefineID))
        end
      end
      if ShootingWeapon:IsShowBulletRemainPercentForUI() then
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
        self.UIRoot.ProgressBar_0:SetPercent(ShootingWeapon:GetCurBulletRemainPercent())
      else
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
      end
    else
      self.UIRoot.BulletsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.BulletsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function DriverLastWeaponUI:RegisterCurLastUseWeapon(LastWeapon)
  if not slua.isValid(LastWeapon) then
    return
  end
  if self.CurrLastWeapon == LastWeapon then
    return
  end
  if self.CurrLastWeapon and slua.isValid(self.CurrLastWeapon) then
    if self.CurrLastWeapon.OnWeaponShootDelegate then
      self:RemoveControlEventByControl(self.CurrLastWeapon, "OnWeaponShootDelegate", self.RefreshLastVehicleWeaponInfo, self)
    end
    if self.CurrLastWeapon.OnCurBulletChange then
      self:RemoveControlEventByControl(self.CurrLastWeapon, "OnCurBulletChange", self.RefreshLastVehicleWeaponInfo, self)
    end
  end
  self.Curr  if slua.isValid(self.CurrLastWeapon) then
    if self.CurrLastWeapon.OnWeaponShootDelegate then
      self:AddControlEventByControl(self.CurrLastWeapon, "OnWeaponShootDelegate", self.RefreshLastVehicleWeaponInfo, self)
    end
    if self.CurrLastWeapon.OnCurBulletChange then
      self:AddControlEventByControl(self.CurrLastWeapon, "OnCurBulletChange", self.RefreshLastVehicleWeaponInfo, self)
    end
  end
end
function DriverLastWeaponUI:RefreshLastVehicleWeaponInfo()
  if not self:IsShow() then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local InventoryWeaponByLogicSocket = WeaponManager:GetInventoryWeaponByLogicSocket(WeaponManager.LastUseNoneGrenadeLogicSlot)
  local ASTExtraShootWeapon = import("STExtraShootWeapon")
  if slua.isValid(InventoryWeaponByLogicSocket) and Game:IsClassOf(InventoryWeaponByLogicSocket, ASTExtraShootWeapon) then
    self:RefreshBullets(InventoryWeaponByLogicSocket)
  end
end
function DriverLastWeaponUI:OnCurrentVehicleChange(_, CurrentVehicle)
  local Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  if not slua.isValid(CurrentVehicle) then
    Visibility = UEnums.ESlateVisibility.Collapsed
  end
  if slua.isValid(CurrentVehicle) and CurrentVehicle.bNeedWeaponSlot then
    Visibility = UEnums.ESlateVisibility.Collapsed
  end
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(Visibility)
end
function DriverLastWeaponUI:GetVehicleUserComponent()
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    return VehicleControlUISubSystem:GetVehicleUserComponent()
  end
end
function DriverLastWeaponUI:UpdateLastWeaponUI(bIsDriving)
  print(bWriteLog and "DriverLastWeaponUI:UpdateLastWeaponUI")
  if not bIsDriving then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "DriverLastWeaponUI:UpdateLastWeaponUI VehicleUserComponent nil")
    return
  end
  local Vehicle = VehicleUserComponent.Vehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "DriverLastWeaponUI:UpdateLastWeaponUI Vehicle nil")
    return
  end
  if Vehicle.bNeedWeaponSlot then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local bIsCanShowLastWeaponPanel = self:IsCanShowLastWeaponPanel(Vehicle)
  if bIsCanShowLastWeaponPanel then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(PlayerCharacter) then
      print(bWriteLog and "DriverLastWeaponUI:UpdateLastWeaponUI PlayerCharacter nil")
      return
    end
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if not slua.isValid(WeaponManager) then
      print(bWriteLog and "DriverLastWeaponUI:UpdateLastWeaponUI WeaponManager nil")
      return
    end
    local InventoryWeaponByLogicSocket = WeaponManager:GetInventoryWeaponByLogicSocket(WeaponManager.LastUseNoneGrenadeLogicSlot)
    if Game:IsValid(InventoryWeaponByLogicSocket) then
      self:UpdateWeaponImage(InventoryWeaponByLogicSocket)
      self:RegisterCurLastUseWeapon(InventoryWeaponByLogicSocket)
      self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function DriverLastWeaponUI:IsCanShowLastWeaponPanel(Vehicle)
  if not slua.isValid(Vehicle) then
    return false
  end
  local _ControlUIConfig = VehicleControlUIConfig[Vehicle.VehicleType]
  if _ControlUIConfig and _ControlUIConfig.HideLastWeaponUI then
    return false
  end
  if _ControlUIConfig and _ControlUIConfig.ShowLastWeaponUI then
    return true
  end
  local IsArmedVehicle = Vehicle:IsArmedVehicle()
  return not IsArmedVehicle and not Vehicle:IsVehicleWarVehicle()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, DriverLastWeaponUI)