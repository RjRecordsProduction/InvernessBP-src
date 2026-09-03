local BackPackItemUI = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local AvatarUtils = import("AvatarUtils")
local BackpackUtils = import("BackpackUtils")
local KismetSystemLibrary = import("KismetSystemLibrary")
local PaperSprite = import("PaperSprite")
local PaperSpriteBlueprintLibrary = import("PaperSpriteBlueprintLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local STExtraUIUtils = import("STExtraUIUtils")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local EBattleItemDropReason = import("EBattleItemDropReason")
local EBattleItemUseReason = import("EBattleItemUseReason")
local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
local ESearchCase = import("ESearchCase")
local ESlateVisibility = import("ESlateVisibility")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
local TableUtil = require("common.table_util")
local Config = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackItemListUI_Config")
local LuaBackpackUtils = require("GameLua.Mod.Library.GamePlay.Backpack.LuaBackpackUtils")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local ExpandListConfig = Config.ExpandList
function BackPackItemUI:ctor(_, BackPackUI, Type)
  self.  self.ItemBPend
function BackPackItemUI:OnInitialize()
  BackPackItemUI.__super.OnInitialize(self)
  self.ItemData = slua.isValid(self.UIRoot) and self.UIRoot.ItemData or nil
  self.bIsHandleBtnsShow = false
  self.bIsUseless = false
  self.bIsInSelected = false
  self.ButtonMenu = nil
  self.ButtonItemPool = nil
  self.IsItemUAV = false
  self.Record = slua.IndexReference(self.UIRoot, "Record")
  self.bBindSingleItemUpdate = false
  self.EnergyWidget = nil
  self.Quality = 0
  self.SlotStatusWidget = nil
  self.BaseItemRecord = slua.IndexReference(self.UIRoot, "BaseItemRecord")
  self.BaseItemRecordItemID = 0
  self.CacheElectricityItemID = 0
  self.LastTableData = nil
  self:ReceivedInitWidget()
end
function BackPackItemUI:RegistEvents()
  BackPackItemUI.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchStartedImplementation", self.OnTouchStartedImplementation, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEndedImplementation", self.OnTouchEndedImplementation, self)
  self:AddControlEventByControl(self.UIRoot, "OnMouseLeaveImplementation", self.OnMouseLeaveImplementation, self)
  local BackPackUI = self.BackPackUI
  if BackPackUI then
    self:AddControlEventByControl(self.UIRoot, "HandleBtnsStateChange", BackPackUI.RecordClickItem, BackPackUI)
    self:AddControlEventByControl(self.UIRoot, "ItemBeDropped", BackPackUI.ShowDropCountSliderByStuff, BackPackUI)
    self:AddControlEventByControl(self.UIRoot, "ItemBeDragBegin", BackPackUI.OnItemDragBegin, BackPackUI)
    self:AddControlEventByControl(self.UIRoot, "ItemBeDragCancelled", BackPackUI.OnItemDragCancelled, BackPackUI)
  end
end
function BackPackItemUI:OnClose()
  local Util = require("client.slua_ui_framework.util")
  if self.OnLoadedDelegate then
    Util.ClearAssetAsync(self.OnLoadedDelegate)
    self.OnLoadedDelegate = nil
  end
  self:RemoveAllGameTimer()
  self.ButtonMenuRef = nil
  self.BackPackUI = nil
end
function BackPackItemUI:OnClicked_Button_Use()
  self:UseItem()
end
function BackPackItemUI:OnClicked_Button_Equip()
  if self.bIsUseless then
  else
    self:EquipItem()
  end
end
function BackPackItemUI:OnClicked_Button_DropPartly()
  self.UIRoot.ItemBeDropped:BroadCast(self.ItemData, false)
end
function BackPackItemUI:OnClicked_Button_Drop()
  self:DropAllItem()
end
function BackPackItemUI:OnMouseLeave(MouseEvent)
  self:SetSelectedState(false)
end
function BackPackItemUI:OnMouseLeaveImplementation()
  self:SetSelectedState(false)
end
function BackPackItemUI:OnClicked_Button_DropAll()
  self:DropAllItem()
end
function BackPackItemUI:OnDragCancelled(PointerEvent, Operation)
  self.UIRoot.ItemBeDragCancelled:BroadCast()
end
function BackPackItemUI:ReceivedInitWidget()
  if EVENTTYPE_TPLAN and EVENTID_TPLAN_SAFETYBOX_BUTTON_SWITCH_STATE then
    self:AddCommonEvent(EVENTTYPE_TPLAN, EVENTID_TPLAN_SAFETYBOX_BUTTON_SWITCH_STATE, function(_, __, ...)
      self:ResetHandleBtns(...)
    end)
  end
  self:CheckInitialSlotStatus()
  self:RegisterCustomEvent()
  local UIRoot = self.UIRoot
  UIRoot.HorizontalBox_Weight:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.HorizontalBox_Value:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.TextBlock_ItemNum:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
end
function BackPackItemUI:UpdateItemData(ItemData, IsUseless, ButtonMenu)
  local TempItemID = 0
  local ItemDataTemp = ItemData:clone()
  self.ItemData = ItemDataTemp
  self.UIRoot.ItemData = ItemDataTemp
  self.b  self.ButtonMenuRef = ButtonMenu
  TempItemID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
  local uGameState = self:GetGameState()
  if Game:IsValid(uGameState) and uGameState.IsEnableRedirectItemIdToAvatarID and uGameState:IsEnableRedirectItemIdToAvatarID() then
    local RedirectAvatarID = uGameState:GetRedirectAvatarID(TempItemID)
    if 0 ~= RedirectAvatarID then
      TempItemID = RedirectAvatarID
      print(bWriteLog and "BackPackItemUI:UpdateItemData RedirectItemID=" .. RedirectAvatarID)
    end
  end
  self.BaseItemRecordItemID = TempItemID
  local ItemTableData = CDataTable.GetTableData("Item", TempItemID)
  if ItemTableData ~= nil then
    self.Quality = ItemTableData.ItemQuality
    local IsUAV = LuaBackpackUtils.IsUAV(ItemTableData.ItemID)
    self.IsItemUAV = IsUAV
    if IsUAV then
      if self:IsLastUsedUAV() then
        self.UIRoot.ItemContent2:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self:InnerUpdateItemData(ItemTableData)
      else
        self.UIRoot.ItemContent2:SetWidgetVisibility(ESlateVisibility.Collapsed)
        self:InnerUpdateItemData(ItemTableData)
      end
    else
      self:InnerUpdateItemData(ItemTableData)
    end
  end
  self:ShowUAVMenu()
  self:SetSelectedState(false)
  self.UIRoot.TextBlock_Time:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self:ShowRecycItemPrice(ItemData, IsUseless, ButtonMenu)
end
function BackPackItemUI:ShowRecycItemPrice(ItemData, IsUseless, ButtonMenu)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local CurrentMapType = GameMainConfig.GetMapType()
  if CurrentMapType ~= "Neon" then
    return
  end
  if not GameMainConfig.ShouldShowRecycItemPrice() then
    return
  end
  local Visibility = UEnums.ESlateVisibility.Collapsed
  local Config = CDataTable.GetTableData("RecycleStore", ItemData.DefineID.TypeSpecificID)
  if Config then
    Visibility = UEnums.ESlateVisibility.HitTestInvisible
    self.UIRoot.TextBlock_Price:SetText(Config.Price)
  end
  self.UIRoot.HorizontalBox_Price:SetWidgetVisibility(Visibility)
end
function BackPackItemUI:InnerUpdateItemData(ItemTableData)
  local Count = self.ItemData.Count
  if 1 < Count then
    local Text = tostring(Count)
    self.UIRoot.TextBlock_ItemNum:SetText(Text)
    self.UIRoot.TextBlock_NumLeft:SetText(Text)
  else
    self.UIRoot.TextBlock_ItemNum:SetText("")
    self.UIRoot.TextBlock_NumLeft:SetText("")
  end
  self:SetUseless(self.bIsUseless, slua.IndexReference(self.ItemData, "DefineID").Type == 2)
  local AvatarItemID = self:GetAvatarID(self.ItemData)
  self.CacheElectricityItemID = AvatarItemID
  self:CheckInitialSlotStatus()
  if self.bIsInSelected then
    self:ShowHandleBtns()
    self:UpdateItemClickedData()
  end
  self:CheckUpgradeItemUseless()
  self:UpdateItemTableData(ItemTableData)
  self:UpdateItemDataMod(ItemTableData)
end
function BackPackItemUI:UpdateItemTableData(ItemTableData)
  if self.LastTableData == nil or self.LastTableData ~= ItemTableData then
    local UIRoot = self.UIRoot
    UIRoot.ItemContent3:SetText(ItemTableData.ItemName)
    UIRoot.Image_ItemIcon:SetWidgetVisibility(ESlateVisibility.Hidden)
    local Util = require("client.slua_ui_framework.util")
    if self.OnLoadedDelegate then
      Util.ClearAssetAsync(self.OnLoadedDelegate)
      self.OnLoadedDelegate = nil
    end
    self.OnLoadedDelegate = Util.GetAssetAsync(ItemTableData.ItemSmallIcon, function(LoadObj)
      if slua.isValid(LoadObj) then
        UIRoot.Image_ItemIcon:SetBrushFromPathAsync(ItemTableData.ItemSmallIcon, false)
        UIRoot.Image_ItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.OnLoadedDelegate = nil
      end
    end)
    self:UpdateSpecialIcon(ItemTableData.SpecialIcon)
    self.LastTableData = ItemTableData
  end
end
function BackPackItemUI:UseItem()
  local uPlayerController = self:GetPlayerController()
  if Game:IsValid(uPlayerController) then
    local TypeSpecificID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
    if self:CheckIsUpgradeItem() then
      self:UseUpgradeItem()
      return
    end
    self:UpdateIceDrinkEmoteID(TypeSpecificID)
    local ItemDefineID = FItemDefineIDDefault()
    local BattleItemUseTarget = FBattleItemUseTarget()
    BattleItemUseTarget.TargetDefineID = ItemDefineID
    local EItemAssociationType = import("EItemAssociationType")
    BattleItemUseTarget.TargetAssociationType = EItemAssociationType.None
    BattleItemUseTarget.TargetActor = nil
    uPlayerController:ServerUseItem(slua.IndexReference(self.ItemData, "DefineID"), BattleItemUseTarget, EBattleItemUseReason.Manually)
    local IsUAV = LuaBackpackUtils.IsUAV(TypeSpecificID)
    if IsUAV then
      local uPlayerCharacter = self:GetPlayerCharacter()
      if slua.isValid(uPlayerCharacter) then
        uPlayerCharacter:StopMove()
      end
    end
  end
end
function BackPackItemUI:DisUseItem()
  local uPlayerController = self:GetPlayerController()
  if Game:IsValid(uPlayerController) then
    local DefineID = slua.IndexReference(self.ItemData, "DefineID")
    uPlayerController:ServerDisuseItem(DefineID, EBattleItemUseReason.Manually)
  end
end
function BackPackItemUI:HandleItemClick()
  if self.bIsHandleBtnsShow then
    self:ResetHandleBtns()
    self:ResetUpgradeItem()
  else
    self:ShowHandleBtns()
    if self.IsItemUAV then
      self.UIRoot.ItemBeClicked:BroadCast()
    end
  end
  self:InvalidateLayoutCache(2)
end
function BackPackItemUI:EquipItem()
  local EItemAssociationType = import("EItemAssociationType")
  local DefineID = slua.IndexReference(self.ItemData, "DefineID")
  local ItemType = slua.IndexReference(self.ItemData, "DefineID").Type
  if ItemType ~= 10 then
    local uPlayerController = self:GetPlayerController()
    if slua.isValid(uPlayerController) then
      if ItemType == 1 or ItemType == 5 then
        local ItemSubType = BackpackUtils.GetItemSubType(DefineID.TypeSpecificID)
        local IsActivePickupEquipIntoPack = STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack()
        if IsActivePickupEquipIntoPack or ItemSubType == 108 then
          local ItemDefineID = FItemDefineIDDefault()
          local BattleItemUseTarget_1 = FBattleItemUseTarget()
          BattleItemUseTarget_1.TargetDefineID = ItemDefineID
          BattleItemUseTarget_1.TargetAssociationType = EItemAssociationType.None
          BattleItemUseTarget_1.TargetActor = nil
          uPlayerController:ServerUseItem(DefineID, BattleItemUseTarget_1, EBattleItemUseReason.EquipAndRecovery)
        end
      else
        local defineID = self:FindWeapon()
        if defineID and defineID.TypeSpecificID ~= 0 then
          local BattleItemUseTarget = FBattleItemUseTarget()
          BattleItemUseTarget.TargetDefineID = defineID
          BattleItemUseTarget.TargetAssociationType = EItemAssociationType.None
          BattleItemUseTarget.TargetActor = nil
          uPlayerController:ServerUseItem(DefineID, BattleItemUseTarget, EBattleItemUseReason.Manually)
        end
      end
    end
  else
    self:EquipChip()
  end
end
function BackPackItemUI:OnTouchStartedImplementation(MyGeometry, InTouchEvent)
  if self.UIRoot then
    self:SetSelectedState(true)
  end
end
function BackPackItemUI:OnTouchEndedImplementation(MyGeometry, InTouchEvent)
  self:SetSelectedState(false)
  self:HandleItemClick()
end
function BackPackItemUI:FindWeapon()
  local weaponManager, currUsingGunID
  local DefineID = slua.IndexReference(self.ItemData, "DefineID")
  local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
    weaponManager = OwningPlayerPawnOrVehicleDriver:GetWeaponManager()
    local CurrentUsingWeapon = weaponManager:GetCurrentUsingWeapon()
    if slua.isValid(CurrentUsingWeapon) then
      local ItemDefineID_2 = CurrentUsingWeapon:GetItemDefineID()
      local isGun_ = self:IsGun(ItemDefineID_2)
      if isGun_ then
        currUsingGunID = ItemDefineID_2
        local canAdd_1 = self:CanGunAddAttachment(currUsingGunID, DefineID, true)
        if canAdd_1 then
          return currUsingGunID
        end
      end
    end
    local SlotWeaponTypeList = {
      ESurviveWeaponPropSlot.SWPS_MainShootWeapon1,
      ESurviveWeaponPropSlot.SWPS_MainShootWeapon2,
      ESurviveWeaponPropSlot.SWPS_SubShootWeapon
    }
    for ArrayIndex, ArrayElement in pairs(SlotWeaponTypeList) do
      local InventoryWeaponByPropSlot = weaponManager:GetInventoryWeaponByPropSlot(ArrayElement)
      if slua.isValid(InventoryWeaponByPropSlot) then
        local ItemDefineID = InventoryWeaponByPropSlot:GetItemDefineID()
        local canAdd = self:CanGunAddAttachment(ItemDefineID, DefineID, true)
        if canAdd then
          return ItemDefineID
        end
      end
    end
    local canAdd_2 = self:CanGunAddAttachment(currUsingGunID, DefineID, false)
    if canAdd_2 then
      return currUsingGunID
    else
      for ArrayIndex_1, ArrayElement_1 in pairs(SlotWeaponTypeList) do
        local InventoryWeaponByPropSlot_1 = weaponManager:GetInventoryWeaponByPropSlot(ArrayElement_1)
        if slua.isValid(InventoryWeaponByPropSlot_1) then
          local ItemDefineID_3 = InventoryWeaponByPropSlot_1:GetItemDefineID()
          local canAdd_3 = self:CanGunAddAttachment(ItemDefineID_3, DefineID, false)
          if canAdd_3 then
            return ItemDefineID_3
          end
        end
      end
      local ItemDefineID_4 = FItemDefineIDDefault()
      return ItemDefineID_4
    end
  end
end
function BackPackItemUI:IsGun(defineID_)
  local TypeSpecificID = defineID_.TypeSpecificID
  local ItemTableData = CDataTable.GetTableData("Item", TypeSpecificID)
  if ItemTableData ~= nil then
    return ItemTableData.ItemSubType ~= 108 and ItemTableData.ItemType == 1
  end
end
function BackPackItemUI:CanGunAddAttachment(gunID_, attachID_, opyEmpty)
  print(bWriteLog and "BackPackItemUI:CanGunAddAttachment")
  local OcupyEmpty = false
  OcupyEmpty = opyEmpty
  local AttachDefineID = attachID_
  local GunDefineID = gunID_
  if not AttachDefineID or not GunDefineID then
    return false
  end
  local uBackPackComponent = self:GetBackPackComponent()
  if not slua.isValid(uBackPackComponent) then
    return false
  end
  local nAttachItemID = AttachDefineID.TypeSpecificID
  print(bWriteLog and "BackPackItemUI:CanGunAddAttachment nAttachItemID:" .. nAttachItemID)
  local IsGunSupportAttachByRes = AvatarUtils.IsGunSupportAttachByRes(nAttachItemID, GunDefineID.TypeSpecificID, false, EWeaponAttachmentSocketType.GunPoint)
  if not IsGunSupportAttachByRes then
    return false
  end
  local nAttachmentSocket = BackpackUtils.getSocketByAttachResID(nAttachItemID)
  local WeaponsInBackpack = BackpackUtils.GetWeaponsInBackpack(uBackPackComponent)
  local EItemAssociationType = import("EItemAssociationType")
  for ArrayIndex, ArrayElement in pairs(WeaponsInBackpack) do
    local IsSameInstance = BackpackUtils.IsSameInstance(GunDefineID, slua.IndexReference(ArrayElement, "DefineID"))
    if IsSameInstance then
      if OcupyEmpty then
        for ArrayIndex_1, ArrayElement_1 in pairs(ArrayElement.Associations) do
          if ArrayElement_1.AssociationType ~= EItemAssociationType.Parent then
            local socket_1 = BackpackUtils.getSocketByAttachResID(ArrayElement_1.AssociationTargetDefineID.TypeSpecificID)
            if socket_1 == nAttachmentSocket then
              return false
            end
          end
        end
        return true
      else
        return true
      end
    end
  end
  return false
end
function BackPackItemUI:getBPIDbyDefineID(itemDefineID_)
  local ItemData = CDataTable.GetTableData("Item", itemDefineID_.TypeSpecificID)
  if ItemData ~= nil then
    return ItemData.BPID
  end
  return 0
end
function BackPackItemUI:DropAllItem()
  local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
  local bCanDrop = BackPackFunctionLibrary.IsCanDropItem(self.ItemData)
  if not bCanDrop then
    BattleNormalTipsByTextID(14136)
    return
  end
  local uPlayerController = self:GetPlayerController()
  local bIsControllerValid = slua.isValid(uPlayerController)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  local CanNotDropItemLuaConfig = BackpackConfig.CanNotDropItemID
  local ItemID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
  local bCanNotDrop = TableUtil.Find(CanNotDropItemLuaConfig, ItemID) ~= -1
  if not bCanNotDrop then
    local ItemAttrsTableData = CDataTable.GetTableData("ItemAttrs", ItemID)
    bCanNotDrop = ItemAttrsTableData and ItemAttrsTableData.CannotManualDrop
  end
  if bCanNotDrop then
    if bIsControllerValid then
      uPlayerController:DisplayGameTipWithMsgID(30128)
      return
    else
      return
    end
  end
  if bIsControllerValid then
    local uPlayerCharacter = self:GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local DefineID = slua.IndexReference(self.ItemData, "DefineID")
      local ReturnValue = uPlayerCharacter:ShouldDropBagItem(DefineID)
      if ReturnValue and self:CharacterIsAlive() then
        uPlayerController:ServerDropItem(DefineID, self.ItemData.Count, EBattleItemDropReason.Manually)
        uPlayerController:UserDropItemOperation(DefineID)
        local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
        if PickUpListPanel then
          PickUpListPanel:PauseAutoPick(ItemID, true)
          self:ResetUpgradeItem()
        end
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local BackpackUI = InGameUITools.GetBackpackUI()
        if BackpackUI and Game:IsValid(uPlayerController.PlayerState) then
          local uPlayerState = uPlayerController.PlayerState
          if BackpackUI.TlogOpenBagPanelNotSendTlog then
            BackpackUI.TlogOpenBagPanelNotSendTlog = false
            uPlayerState:RPC_ServerAddGeneralCount(10527, 1, false)
          end
          if self.bIsUseless then
            uPlayerState:RPC_ServerAddGeneralCount(10526, 1, false)
          else
            uPlayerState:RPC_ServerAddGeneralCount(10528, 1, false)
          end
          print(bWriteLog and "BackPackItemUI:DropAllItem RPC_ServerAddGeneralCount TlogOpenBagPanelNotSendTlog:" .. tostring(BackpackUI.TlogOpenBagPanelNotSendTlog) .. " bIsUseless:" .. tostring(self.bIsUseless))
        end
      end
    end
  end
end
function BackPackItemUI:DropAddItemToPauseAutoPickList()
  local ClientIngameUIFunctionLibrary = require("GameLua.Mod.Library.Client.ClientIngameUIFunctionLibrary")
  local InputControlPanel = ClientIngameUIFunctionLibrary.GetInputControlPanel()
  if slua.isValid(InputControlPanel) then
    InputControlPanel.MainControlBaseUI.BackPackPickUpPanel_BP.PickUpListPanel_BP:PauseAutoPick(slua.IndexReference(self.ItemData, "DefineID"), true)
    self:ResetUpgradeItem()
  end
end
function BackPackItemUI:ResetHandleBtns()
  self:CollapseMenu()
  if self.bIsHandleBtnsShow then
    self.bIsHandleBtnsShow = false
    self.bIsInSelected = false
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local BackpackUI = InGameUITools.GetBackpackUI()
    if BackpackUI then
      BackpackUI:RecordClickItem(self.UIRoot, false)
    end
    if self.ButtonMenu then
      self.ButtonMenu.UIRoot:RemoveFromParent()
      self.ButtonMenu = nil
    end
  end
end
function BackPackItemUI:CheckInVehicle()
  local uVehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(uVehicleUserComponent) then
    if uVehicleUserComponent.VehicleUserState == ESTExtraVehicleUserState.EVUS_AsDriver then
      return true
    elseif uVehicleUserComponent.VehicleUserState == ESTExtraVehicleUserState.EVUS_ASPassenger then
      return true
    end
  end
  return false
end
function BackPackItemUI:ShowHandleBtns()
  self.bIsHandleBtnsShow = true
  self.bIsInSelected = true
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  if BackpackUI then
    BackpackUI:RecordClickItem(self.UIRoot, true)
  end
  if self.ButtonMenu then
    self.ButtonMenu:UpdateButtonState(self.bIsUseless, self.ItemData)
    self.ButtonMenu.Parent = self
  elseif self.ButtonMenuRef then
    self.ButtonMenu = self.ButtonMenuRef
    self.UIRoot.VerticalBox_0:AddChild(self.ButtonMenu.UIRoot)
    self.ButtonMenu:UpdateButtonState(self.bIsUseless, self.ItemData)
    self.ButtonMenu.Parent = self
  end
  self:CollapseMenu()
  local DefineID = slua.IndexReference(self.ItemData, "DefineID")
  local ItemType = DefineID.Type
  if self.ButtonMenu then
    if ItemType == 1 then
      self.ButtonMenu.GridPanel_WeaponFit:SetWidgetVisibility(ESlateVisibility.Visible)
    elseif ItemType == 2 then
      self.ButtonMenu.GridPanel_WeaponFit:SetWidgetVisibility(ESlateVisibility.Visible)
    elseif ItemType == 3 then
      self.ButtonMenu.GridPanel_Throw:SetWidgetVisibility(ESlateVisibility.Visible)
    elseif ItemType == 4 then
      local ItemData = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
      if ItemData ~= nil and ItemData.ItemSubType == 4181 then
        self.ButtonMenu.GridPanel_UseDisuseAvarat:SetWidgetVisibility(ESlateVisibility.Visible)
      end
    elseif ItemType == 5 then
      self.ButtonMenu.GridPanel_WeaponFit:SetWidgetVisibility(ESlateVisibility.Visible)
    elseif ItemType == 6 then
      local ItemData = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
      if ItemData ~= nil then
        local IsUAV = LuaBackpackUtils.IsUAV(ItemData.ItemID)
        if IsUAV then
          self:UpdateUAV()
        else
          self.ButtonMenu.GridPanel_Throw:SetWidgetVisibility(ESlateVisibility.Visible)
          if ItemData.ItemSubType == 601 then
            self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
          elseif ItemData.ItemSubType == 602 then
            local IsCanUseInBackpack = BackpackUtils.IsCanUseInBackpack(ItemData.ItemID)
            if IsCanUseInBackpack then
              self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
            end
          elseif ItemData.ItemSubType == 603 then
            if self:CheckInVehicle() then
              self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
            end
          elseif ItemData.ItemSubType == 604 then
            self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
          elseif ItemData.ItemSubType == 606 then
            self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
          elseif ItemData.ItemSubType == 616 then
            self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
          elseif ItemData.ItemSubType == 617 then
            self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
          end
          if ItemData.ItemSubType == 30004 then
            self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Visible)
            self.ButtonMenu.GridPanel_Throw:SetWidgetVisibility(ESlateVisibility.Collapsed)
          end
        end
      end
    elseif ItemType == 10 then
      self.ButtonMenu.GridPanel_WeaponFit:SetWidgetVisibility(ESlateVisibility.Visible)
    elseif ItemType == 12 or ItemType == 30 or ItemType == 42 then
      self.ButtonMenu.GridPanel_Throw:SetWidgetVisibility(ESlateVisibility.Visible)
    end
  end
  self:CheckUpgradeItemUseless()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SHOW_HANDLE_BTNS, self)
end
function BackPackItemUI:UpdateSpecialIcon(IconPath)
  if IconPath == "" then
    self.UIRoot.Logo:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    STExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsyncWithFuncName(KismetSystemLibrary.MakeSoftObjectPath(IconPath), slua.createDelegate(function(...)
      self:RefreshSpecialIcon(...)
    end))
  end
end
function BackPackItemUI:RefreshSpecialIcon(Icon)
  if slua.isValid(Icon) then
    local AsPaperSprite = Icon
    if Game:IsClassOf(AsPaperSprite, PaperSprite) then
      self.UIRoot.Logo:SetBrush(PaperSpriteBlueprintLibrary.MakeBrushFromSprite(AsPaperSprite, 0, 0))
      self.UIRoot.Logo:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function BackPackItemUI:UpdateItemClickedData()
  if self.ItemData.Count > 1 then
    local IsVisible = self.ButtonMenu.GridPanel_Throw:IsVisible()
    if IsVisible then
      self.ButtonMenu.Button_DropPartly:SetWidgetVisibility(ESlateVisibility.Visible)
      self.ButtonMenu.GridPanel_DropPartlyDisableState:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  else
    local IsVisible = self.ButtonMenu.GridPanel_Throw:IsVisible()
    if IsVisible then
      self.ButtonMenu.Button_DropPartly:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.ButtonMenu.GridPanel_DropPartlyDisableState:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.bIsUseless then
    local IsVisible_1 = self.ButtonMenu.GridPanel_WeaponFit:IsVisible()
    if IsVisible_1 then
      self.ButtonMenu.Button_Equip:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.ButtonMenu.UnableToEquip:SetWidgetVisibility(ESlateVisibility.Visible)
    end
  else
    local IsVisible_1 = self.ButtonMenu.GridPanel_WeaponFit:IsVisible()
    if IsVisible_1 then
      self.ButtonMenu.Button_Equip:SetWidgetVisibility(ESlateVisibility.Visible)
      self.ButtonMenu.UnableToEquip:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
end
function BackPackItemUI:InitHandleBtns(ButtonMenu)
  self.end
function BackPackItemUI:CharacterIsAlive()
  local uPlayerCharacter = self:GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    return uPlayerCharacter:IsAlive()
  end
  return true
end
function BackPackItemUI:CallBack()
  local uPlayerController = self:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uVehicleUserComponent = self:GetVehicleUserComp()
    if slua.isValid(uVehicleUserComponent) then
      uPlayerController:CastUIMsg("UIMsg_UAVCallback", "ingame")
    end
  end
end
function BackPackItemUI:Controll()
  local uPlayerController = self:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uVehicleUserComponent = self:GetVehicleUserComp()
    if slua.isValid(uVehicleUserComponent) then
      uPlayerController:CastUIMsg("UIMsg_UAVUse", "ingame")
    end
  end
end
function BackPackItemUI:CollapseMenu()
  if self.ButtonMenu then
    self.ButtonMenu.Button_Use:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_Throw:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_WeaponFit:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_UAV_DropAndUse:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_UAV_CallbackAndUse:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_UAV_DropAndDisuse:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_UAV_DisdropAndDisuse:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ButtonMenu.GridPanel_UseDisuseAvarat:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BackPackItemUI:UpdateUAV()
  local beyondCD = false
  if self.ButtonMenu then
    local uVehicleUserComponent = self:GetVehicleUserComponent()
    if slua.isValid(uVehicleUserComponent) then
      if uVehicleUserComponent.LastUsedItemDefineID.TypeSpecificID == 0 then
        self.ButtonMenu.GridPanel_UAV_DropAndUse:SetWidgetVisibility(ESlateVisibility.Visible)
        return
      else
        local IsSameInstance = BackpackUtils.IsSameInstance(uVehicleUserComponent.LastUsedItemDefineID, slua.IndexReference(self.ItemData, "DefineID"))
        local uGameState = self:GetGameState()
        if slua.isValid(uGameState) then
          beyondCD = uGameState:GetServerWorldTimeSeconds() + 0.5 > uVehicleUserComponent.LastFinishCD
          if IsSameInstance then
            if beyondCD then
              if slua.isValid(uVehicleUserComponent.UnmannedVehicle) then
                self.ButtonMenu.GridPanel_UAV_CallbackAndUse:SetWidgetVisibility(ESlateVisibility.Visible)
                return
              else
                self.ButtonMenu.GridPanel_UAV_DropAndUse:SetWidgetVisibility(ESlateVisibility.Visible)
                return
              end
            else
              self.ButtonMenu.GridPanel_UAV_DisdropAndDisuse:SetWidgetVisibility(ESlateVisibility.Visible)
              return
            end
          elseif slua.isValid(uVehicleUserComponent.UnmannedVehicle) then
            self.ButtonMenu.GridPanel_UAV_DropAndDisuse:SetWidgetVisibility(ESlateVisibility.Visible)
            return
          elseif beyondCD then
            self.ButtonMenu.GridPanel_UAV_DropAndUse:SetWidgetVisibility(ESlateVisibility.Visible)
            return
          else
            self.ButtonMenu.GridPanel_UAV_DropAndDisuse:SetWidgetVisibility(ESlateVisibility.Visible)
            return
          end
        end
      end
    else
      self.ButtonMenu.GridPanel_UAV_DropAndUse:SetWidgetVisibility(ESlateVisibility.Visible)
      return
    end
  end
end
function BackPackItemUI:SetUseless(isUseless, isAttach)
  if self.ButtonMenu then
    if isUseless then
      self.ButtonMenu.Button_Equip:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.ButtonMenu.UnableToEquip:SetWidgetVisibility(ESlateVisibility.Visible)
      self.ButtonMenu.Button_Use:SetIsEnabled(false)
    else
      self.ButtonMenu.Button_Equip:SetWidgetVisibility(ESlateVisibility.Visible)
      self.ButtonMenu.UnableToEquip:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.ButtonMenu.Button_Use:SetIsEnabled(true)
    end
  end
  if isUseless then
    self.UIRoot.Image_Useless:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    self.UIRoot.Image_Useless:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BackPackItemUI:ShowUAVMenu()
  local IsUAV = LuaBackpackUtils.IsUAV(slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID)
  if IsUAV and self.ButtonMenu then
    self:CollapseMenu()
    self:ShowHandleBtns()
  end
end
function BackPackItemUI:UAVCanNotDrop()
  local beyondCD = false
  local uVehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(uVehicleUserComponent) then
    local IsSameInstance = BackpackUtils.IsSameInstance(uVehicleUserComponent.LastUsedItemDefineID, slua.IndexReference(self.ItemData, "DefineID"))
    if IsSameInstance then
      local uGameState = self:GetGameState()
      if slua.isValid(uGameState) then
        beyondCD = uGameState:GetServerWorldTimeSeconds() > uVehicleUserComponent.LastFinishCD
        if beyondCD then
          if slua.isValid(uVehicleUserComponent.UnmannedVehicle) then
            return true
          else
            return false
          end
        else
          return true
        end
      end
    else
      return false
    end
  end
end
function BackPackItemUI:SetCurrUsedUAVCDTime(Cd)
  if 0 < Cd then
    self.UIRoot.ItemContent2:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
    local Text = GlobalBattleUIFunctionLibrary.GetLocalizeBattleText("20074", self.UIRoot)
    local kismet_string_library = require("common.kismet_string_library")
    self.UIRoot.ItemContent2:SetText(tostring(kismet_string_library.Replace(Text, "{0}", tostring(Cd), kismet_string_library.ESearchCase.CaseSensitive)))
  else
    self.UIRoot.ItemContent2:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:ShowDropAndUse()
  end
end
function BackPackItemUI:ShowDropAndUse()
  self:CollapseMenu()
  if self.ButtonMenu then
    self.ButtonMenu.GridPanel_UAV_DropAndUse:SetWidgetVisibility(ESlateVisibility.Visible)
  end
end
function BackPackItemUI:GetItemAttrValue(inArray, inName, inDefault)
  local ret = 0
  ret = inDefault
  for ArrayIndex, ArrayElement in pairs(inArray) do
    if inName == ArrayElement.Name then
      local FloatData = ArrayElement.FloatData
      if 0.0 < FloatData then
        ret = FloatData
      else
        local IntData = ArrayElement.IntData
        if 0 < IntData then
          ret = IntData
        end
      end
    end
  end
  return ret
end
function BackPackItemUI:BindUpdateSingleItem()
  if not self.bBindSingleItemUpdate then
    self.bBindSingleItemUpdate = true
    local uBackPackComponent = self:GetBackPackComponent()
    if slua.isValid(uBackPackComponent) then
      self:AddControlEventByControl(uBackPackComponent, "SingleItemUpdatedDelegate", self.UpdateSingleItem, self)
    else
      print(bWriteLog and "BackPackItemUI:BindUpdateSingleItem: uBackPackComponent is invalid")
    end
  end
end
function BackPackItemUI:UnBindUpdateSingleItem()
  if self.bBindSingleItemUpdate then
    self.bBindSingleItemUpdate = false
    local uBackPackComponent = self:GetBackPackComponent()
    if slua.isValid(uBackPackComponent) then
      self:RemoveControlEventByControl(uBackPackComponent, "SingleItemUpdatedDelegate")
    else
      print(bWriteLog and "BackPackItemUI:UnBindUpdateSingleItem: uBackPackComponent is invalid")
    end
  end
end
function BackPackItemUI:UpdateSingleItem(DefineID)
  local uBackPackComponent = self:GetBackPackComponent()
  if slua.isValid(uBackPackComponent) then
    for _, ArrayElement in pairs(uBackPackComponent:GetItemListByDefineID(DefineID)) do
      local DefineID_1 = slua.IndexReference(ArrayElement, "DefineID")
      local IsSameInstance = BackpackUtils.IsSameInstance(DefineID, DefineID_1)
      local IsSameInstance_1 = BackpackUtils.IsSameInstance(DefineID_1, slua.IndexReference(self.ItemData, "DefineID"))
      if IsSameInstance and IsSameInstance_1 then
        self.ItemData = ArrayElement
        self:ExtraUpdateSingleItem(ArrayElement)
      end
    end
  end
  self:ShowUAVMenu()
end
function BackPackItemUI:ExtraUpdateSingleItem(Item)
end
function BackPackItemUI:GetAvatarID(inData)
  local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
  for ArrayIndex, ArrayElement in pairs(slua.IndexReference(inData, "AdditionalData")) do
    local IntData = ArrayElement.IntData
    if ArrayElement.EDataType == EBattleItemAdditionalDataType.WeaponAvatar and 0 < IntData then
      return IntData
    end
  end
  return slua.IndexReference(inData, "DefineID").TypeSpecificID
end
function BackPackItemUI:IsLastUsedUAV()
  local uVehicleUserComponent = self:GetVehicleUserComponent()
  if slua.isValid(uVehicleUserComponent) then
    if uVehicleUserComponent.LastUsedItemDefineID.TypeSpecificID == 0 then
      return false
    else
      local IsSameInstance = BackpackUtils.IsSameInstance(slua.IndexReference(self.ItemData, "DefineID"), slua.IndexReference(uVehicleUserComponent, "LastUsedItemDefineID"))
      return IsSameInstance
    end
  else
    return false
  end
end
function BackPackItemUI:UpdateIceDrinkEmoteID(ItemID)
  local ItemData = CDataTable.GetTableData("Item", ItemID)
  if ItemData ~= nil and ItemData.ItemSubType == 30004 then
    local uPlayerController = self:GetPlayerController()
    if Game:IsValid(uPlayerController) then
      local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
      local EmoteID, VoiceName = BackPackFunctionLibrary.GetEmoteIDAndVoiceNameByItemID(ItemID)
      local PlayerCharacterSafety = uPlayerController:GetPlayerCharacterSafety()
      PlayerCharacterSafety:SetPrepareEmoteId(EmoteID)
      PlayerCharacterSafety:SetEmoteSouceEventName(VoiceName)
    end
  end
end
function BackPackItemUI:EquipChip()
  local CanEquipItemMap = {}
  local DefineID = slua.IndexReference(self.ItemData, "DefineID")
  local ItemTableData = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
  local ChipCanEquipItemList = AvatarUtils.GetChipCanEquipItemList(ItemTableData.ItemSubType)
  CanEquipItemMap = ChipCanEquipItemList
  local uPlayerController = self:GetPlayerController()
  if Game:IsValid(uPlayerController) then
    local uBackpackComponent = self:GetBackPackComponent()
    if slua.isValid(uBackpackComponent) then
      local EuqippedArmorInBackpack = BackpackUtils.GetEuqippedArmorInBackpack(uBackpackComponent)
      local IsFind, ItemUseTarget = LuaBackpackUtils.GetEquipChipSlot(EuqippedArmorInBackpack, CanEquipItemMap, true, ItemTableData, self.ItemData)
      if IsFind then
        uPlayerController:ServerUseItem(DefineID, ItemUseTarget, EBattleItemUseReason.Manually)
        return
      else
        local IsFind_1, ItemUseTarget_1 = LuaBackpackUtils.GetEquipChipSlot(EuqippedArmorInBackpack, CanEquipItemMap, false, ItemTableData, self.ItemData)
        if IsFind_1 then
          uPlayerController:ServerUseItem(DefineID, ItemUseTarget_1, EBattleItemUseReason.Manually)
          return
        elseif ItemTableData.ItemType == 10 and ItemTableData.ItemSubType == 1004 then
          BattleNormalTipsByTextID(42663)
        end
      end
    end
  end
end
function BackPackItemUI:CheckInitialSlotStatus()
end
function BackPackItemUI:SetSelectedState(bIsSelected)
  if bIsSelected then
    self.UIRoot.Image_ItemSelectFG:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    self.UIRoot.Image_ItemSelectFG:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BackPackItemUI:RegisterCustomEvent()
  if not self.HasRegisterCustomEvent then
    self.HasRegisterCustomEvent = true
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_START, self.OnWeaponUpgradeStart, self)
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local SuperData = GameplayData.GetSuperData()
    self:AddDataListener(SuperData, "CharacterDataReady", function()
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uPlayerCharacter = GameplayData.GetPlayerCharacter()
      if not slua.isValid(uPlayerCharacter) then
        return
      end
      local uSkillManager = uPlayerCharacter:GetSkillManager()
      if not slua.isValid(uSkillManager) then
        return
      end
      self:AddControlEventByControl(uSkillManager, "SkillStopEvent", self.HandleOnSkillStop, self)
    end)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_CHANGE, self.HandleUpgradeChangeInfoInClient, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DROP_PROCESS, self.HandleItemDragProcess, self)
  end
end
function BackPackItemUI:CheckIsUpgradeItem()
  local ItemID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
  if not ItemConfig.WeaponUpgradeSkill[ItemID] then
    return
  end
  return true
end
function BackPackItemUI:CheckUpgradeItemUseless()
  local ItemID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
  if not self:CheckIsUpgradeItem() then
    return
  end
  self.LockInSkillID = nil
  print(bWriteLog and "BackPackItemUI:CheckUpgradeItemUseless", ItemID)
  if self:GetNextUpgradeWeapon() then
    if self.ButtonMenu and self.ButtonMenu:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed then
      self.ButtonMenu.Button_Use:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
    self.bIsUseless = false
    self:SetUseless(false, false)
    return
  end
  self.bIsUseless = true
  self:SetUseless(true, false)
end
function BackPackItemUI:GetNextUpgradeWeapon()
  local uPlayerCharacter = self:GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BackPackItemUI:GetNextUpgradeWeapon Error uPlayerCharacter invalid")
    return
  end
  local uCurWeapon = uPlayerCharacter:GetCurrentWeapon()
  if slua.isValid(uCurWeapon) and self:CanWeaponUpgrade(uCurWeapon) then
    return uCurWeapon
  end
  local WeaponList = self:GetPlayerWeapons()
  for Slot, uWeapon in pairs(WeaponList) do
    if slua.isValid(uWeapon) and self:CanWeaponUpgrade(uWeapon) then
      return uWeapon
    end
  end
end
function BackPackItemUI:CanWeaponUpgrade(uWeapon)
  local WeaponUpgradeConfig = require("GameLua.Mod.Livik.GamePlay.Weapon.WeaponUpgradeCfg")
  local ItemID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
  return WeaponUpgradeConfig.UpgradeCfg[ItemID][uWeapon:GetItemDefineID().TypeSpecificID] and not uWeapon:HasUpgrade()
end
function BackPackItemUI:OnWeaponUpgradeStart(_, _, uPlayer, SkillID, LuaTable, BBLuaTable)
  local ItemID = slua.IndexReference(self.ItemData, "DefineID").TypeSpecificID
  if not ItemConfig.WeaponUpgradeSkill[ItemID] then
    return
  end
  self.LockInend
function BackPackItemUI:UseUpgradeItem()
  local DefineID = slua.IndexReference(self.ItemData, "DefineID")
  local ItemID = DefineID.TypeSpecificID
  local uPlayerController = self:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if self.LockInSkillID then
    print(bWriteLog and "BackPackItemUI:UseUpgradeItem", ItemID, "LockInSkill")
    return
  end
  print(bWriteLog and "BackPackItemUI:UseUpgradeItem", ItemID)
  local uUpgradeWeapon = self:GetNextUpgradeWeapon()
  if not uUpgradeWeapon then
    return
  end
  local UseTarget = FBattleItemUseTarget()
  UseTarget.TargetDefineID = uUpgradeWeapon:GetItemDefineID()
  uPlayerController:ServerUseItem(DefineID, UseTarget, 1)
  return true
end
function BackPackItemUI:GetPlayerWeapons()
  local WeaponList = {}
  local uPlayerCharacter = self:GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uPlayerCharacter:GetWeaponManager()) then
    return WeaponList
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
  local MainWeapon1 = uWeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon1)
  local MainWeapon2 = uWeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon2)
  if MainWeapon1 then
    WeaponList[ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon1] = MainWeapon1
  end
  if MainWeapon2 then
    WeaponList[ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon2] = MainWeapon2
  end
  return WeaponList
end
function BackPackItemUI:HandleOnSkillStop(SkillID, StopReason)
  if SkillID == self.LockInSkillID then
    self.LockInSkillID = nil
  end
end
function BackPackItemUI:HandleWeaponUpGrade(EventType, EventID, uCharacter, UpgradeItemID, SkillID)
  if SkillID == self.LockInSkillID then
    self.LockInSkillID = nil
  end
end
function BackPackItemUI:ResetUpgradeItem()
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADE_SET_SLOT, nil, nil)
end
function BackPackItemUI:HandleUpgradeChangeInfoInClient(EventType, EventID, uWeapon)
  self:CheckUpgradeItemUseless()
end
function BackPackItemUI:HandleItemDragProcess(EventType, EventID, ItemData)
  if slua.IndexReference(ItemData, "DefineID").InstanceID == slua.IndexReference(self.ItemData, "DefineID").InstanceID then
    self:ResetUpgradeItem()
  end
end
function BackPackItemUI:UpdateItemExpandState(bIsExpand, UtilsForFoldList)
  local Visibility = bIsExpand and ESlateVisibility.Visible or ESlateVisibility.Collapsed
  self.UIRoot.GridPanel_Right:SetWidgetVisibility(Visibility)
  if self.ButtonMenu then
    local ExpandIndex = UtilsForFoldList.GetExpandIndex(bIsExpand)
    local SizeBoxContainerWidth = ExpandListConfig.ItemSizeBoxContainerWidth[ExpandIndex]
    self.ButtonMenu.SizeBox_Container:SetWidthOverride(SizeBoxContainerWidth)
    for name, sizes in pairs(ExpandListConfig.FunctionButtonBackground) do
      UtilsForFoldList.SetImageWidth(self.ButtonMenu[name], sizes[ExpandIndex])
    end
    for name, config in pairs(ExpandListConfig.GridPanelIndex) do
      local Widget = self.ButtonMenu[name]
      if slua.isValid(Widget) then
        local GridSlot = WidgetLayoutLibrary.SlotAsGridSlot(Widget)
        GridSlot:SetRow(config.Row[ExpandIndex])
        GridSlot:SetColumn(config.Column[ExpandIndex])
      end
    end
  end
end
function BackPackItemUI:GetEmptyChipSlotIdx(ItemData, SupportChipNum)
  return LuaBackpackUtils.GetEmptyChipSlotIdx(ItemData, SupportChipNum)
end
function BackPackItemUI:GetChipAssociationType(index)
  return LuaBackpackUtils.GetChipAssociationType(index)
end
function BackPackItemUI:GetEquipChipNum(ItemData)
  return LuaBackpackUtils.GetEquipChipNum(ItemData)
end
function BackPackItemUI:GetGameState()
  if not slua.isValid(self.uGameState) then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    self.uGameState = GameplayData.GetGameState()
  end
  return self.uGameState
end
function BackPackItemUI:GetPlayerController()
  print(bWriteLog and "BackPackItemUI:GetPlayerController")
  if not slua.isValid(self.uPlayerController) then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    self.uPlayerController = GameplayData.GetPlayerController()
  end
  return self.uPlayerController
end
function BackPackItemUI:GetPlayerCharacter()
  print(bWriteLog and "BackPackItemUI:GetPlayerCharacter")
  if not slua.isValid(self.uPlayerCharacter) then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    self.uPlayerCharacter = GameplayData.GetPlayerCharacter()
  end
  return self.uPlayerCharacter
end
function BackPackItemUI:GetPlayerState()
  print(bWriteLog and "BackPackItemUI:GetPlayerState")
  if not slua.isValid(self.uPlayerState) then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    self.uPlayerState = GameplayData.GetPlayerState()
  end
  return self.uPlayerState
end
function BackPackItemUI:GetBackPackComponent()
  print(bWriteLog and "BackPackItemUI:GetBackPackComponent")
  if not slua.isValid(self.uBackpackComponent) then
    local uPlayerController = self:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "BackPackItemUI:GetBackPackComponent Error, uPlayerController is invalid")
      return
    end
    self.uBackpackComponent = uPlayerController:GetBackpackComponent()
  end
  return self.uBackpackComponent
end
function BackPackItemUI:GetVehicleUserComponent()
  print(bWriteLog and "BackPackItemUI:GetVehicleUserComponent")
  if not slua.isValid(self.uVehicleUserComponent) then
    local uPlayerController = self:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "BackPackItemUI:GetVehicleUserComponent Error, uPlayerController is invalid")
      return
    end
    self.uVehicleUserComponent = uPlayerController:GetVehicleUserComp()
  end
  return self.uVehicleUserComponent
end
function BackPackItemUI:ItemBeDragBeginNew(DragDropOpt)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  if BackpackUI then
    BackpackUI:RecordClickItem(self.UIRoot, true)
  end
end
local class = require("class")
local ListUIItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.ListItemUIBase")
local CBackPackItemUI = class(ListUIItemBase, nil, BackPackItemUI)
return CBackPackItemUI