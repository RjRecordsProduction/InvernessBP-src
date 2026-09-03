local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local AvatarUtils = import("AvatarUtils")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local BackpackUtils = import("BackpackUtils")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local ESlateVisibility = import("ESlateVisibility")
local EBackpackItemSortType = import("EBackpackItemSortType")
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local TableUtil = require("common.table_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local Config = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackItemListUI_Config")
local ExpandListConfig = Config.ExpandList
local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
function BackPackPanelUI:PreLoadItem()
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if not ScriptHelperEngine.IsLowMemoryDevice() then
    for i = 1, 10 do
      local ItemUI = self:_CreateListItem("Default")
      ItemUI:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
end
function BackPackPanelUI:UpdateClothItemList()
  local EBackpackTab = UEnums.EBackpackTab
  if self.CurChosenTab == EBackpackTab.AvatarItem then
    self:UpdateScrollItemListEvent()
  end
end
function BackPackPanelUI:UpdateScrollItemList(_, _, uBackpackComponent)
  self:UpdateScrollItemListEvent(uBackpackComponent)
end
function BackPackPanelUI:UpdateScrollItemListEvent(uBackpackComponent)
  if self.UIRoot:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    return
  end
  self:UpdateCapacity()
  local Tab = self.CurChosenTab
  local time_ticker = require("common.time_ticker")
  local EBackpackTab = UEnums.EBackpackTab
  if Tab == EBackpackTab.AllItem then
    if not slua.isValid(uBackpackComponent) then
      uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
    end
    if not slua.isValid(uBackpackComponent) then
      return
    end
    local AllItems = BackpackUtils.GetAllItemsInBackpack(uBackpackComponent, false, self.CurExpandingStoreAreaType)
    if self:IsInAllItemFilterMode() then
      AllItems = self:FilterAllExcludedItems(AllItems)
    end
    self:UpdateScrollItemListItems_2(AllItems)
    self:AddTimer(0, function()
      if not slua.isValid(uBackpackComponent) then
        uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
      end
      if not slua.isValid(uBackpackComponent) then
        return
      end
      self:ResetAttachSlots()
      if not self.ItemBeDragged then
        self:ResetUpgradeWeapon()
      end
      coroutine.yield(time_ticker.NEXT_FRAME)
      if slua.isValid(uBackpackComponent) then
        local Weapons = BackpackUtils.GetWeaponsInBackpack(uBackpackComponent)
        self:UpdateWeaponItems(Weapons)
      end
      coroutine.yield(time_ticker.NEXT_FRAME)
      if slua.isValid(uBackpackComponent) then
        local ClothingAndArmor = BackpackUtils.GetClothingAndArmorInBackpack(uBackpackComponent)
        self:UpdateArmor(ClothingAndArmor)
      end
      self:OnUpdateScrollItems()
      if self.ArmorSlotTypesPersistent and self.ArmorSlotTypesPersistent[3] == EBackpackClothArmorType.Pistol then
        local uPlayerPawn = GameplayData.GetPlayerCharacter()
        if slua.isValid(uPlayerPawn) then
          local uWeaponManager = uPlayerPawn:GetWeaponManager()
          local MainWeapon3 = uWeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_SubShootWeapon)
          if not MainWeapon3 then
            self.UIRoot.ArmorSlotItem_Package:ShowNull()
          end
        end
      end
    end)
  elseif Tab == EBackpackTab.WeaponFitItem then
    self:AddTimer(0, function()
      if not slua.isValid(uBackpackComponent) then
        uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
      end
      if not slua.isValid(uBackpackComponent) then
        return
      end
      local AllItems = BackpackUtils.GetAllItemsInBackpackWithType(uBackpackComponent, {1, 2}, true, self.CurExpandingStoreAreaType)
      self:ResetAttachSlots()
      self:UpdateScrollItemListItems_2(AllItems)
      local Weapons = BackpackUtils.GetWeaponsInBackpack(uBackpackComponent)
      coroutine.yield(time_ticker.NEXT_FRAME)
      self:UpdateWeaponItems(Weapons)
      local ClothingAndArmor = BackpackUtils.GetClothingAndArmorInBackpack(uBackpackComponent)
      coroutine.yield(time_ticker.NEXT_FRAME)
      self:UpdateArmor(ClothingAndArmor)
      self:OnUpdateScrollItems()
    end)
  elseif Tab == EBackpackTab.ConsumableItem then
    self:AddTimer(0, function()
      if not slua.isValid(uBackpackComponent) then
        uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
      end
      if not slua.isValid(uBackpackComponent) then
        return
      end
      local AllItems = BackpackUtils.GetAllItemsInBackpackWithType(uBackpackComponent, {3, 6}, true, self.CurExpandingStoreAreaType)
      coroutine.yield(time_ticker.NEXT_FRAME)
      self:UpdateScrollItemListItems_2(AllItems)
    end)
  elseif Tab == EBackpackTab.AvatarItem then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_MARK_CLOTH_DIRTY)
  elseif Tab == EBackpackTab.ArmorItem then
    self:AddTimer(0, function()
      if not slua.isValid(uBackpackComponent) then
        uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
      end
      if not slua.isValid(uBackpackComponent) then
        return
      end
      local AllItems = BackpackUtils.GetAllItemsInBackpackWithType(uBackpackComponent, {5, 10}, true, self.CurExpandingStoreAreaType)
      self:ResetAttachSlots()
      self:UpdateScrollItemListItems_2(AllItems)
      local ClothingAndArmor = BackpackUtils.GetClothingAndArmorInBackpack(uBackpackComponent)
      coroutine.yield(time_ticker.NEXT_FRAME)
      self:UpdateArmor(ClothingAndArmor)
      self:OnUpdateScrollItems()
    end)
  elseif Tab == EBackpackTab.SundriesItem then
    if not slua.isValid(uBackpackComponent) then
      uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
    end
    if not slua.isValid(uBackpackComponent) then
      return
    end
    local AllItems = BackpackUtils.GetAllItemsInBackpackWithType(uBackpackComponent, {30, 42}, true, self.CurExpandingStoreAreaType)
    self:UpdateScrollItemListItems_2(AllItems)
  elseif Tab == EBackpackTab.AllExcludedItem then
    if not slua.isValid(uBackpackComponent) then
      uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
    end
    if not slua.isValid(uBackpackComponent) then
      return
    end
    local AllItems = BackpackUtils.GetAllItemsInBackpack(uBackpackComponent, false, self.CurExpandingStoreAreaType)
    AllItems = self:FilterAllExcludedItems(AllItems, true)
    self:UpdateScrollItemListItems_2(AllItems)
  end
end
function BackPackPanelUI:UpdateScrollItemListItems_2(BackpackItemDataArray)
  local bFind = false
  local itemIndex = 0
  local DiscardIndex = 0
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  self.LocalBackpackItemArray = BackpackItemDataArray
  local IsActiveBackpackTabAndSort = STExtraModLogicSwitchLibrary.IsActiveBackpackTabAndSort()
  if IsActiveBackpackTabAndSort and self.CurSortType ~= EBackpackItemSortType.EIS_Default then
    BackpackUtils.SortBattleItemsByType(self.LocalBackpackItemArray, self.CurSortType)
  end
  self:GetWeaponAttach()
  local ItemDataArray = self:_GetBackpackItemDatas()
  itemIndex = -1
  local UseListItem
  local ItemBPType = "Default"
  for ArrayIndex, CurData in pairs(ItemDataArray) do
    itemIndex = ArrayIndex - 1
    bFind = false
    DiscardIndex = -1
    local DefineID = slua.IndexReference(CurData.ItemData, "DefineID")
    local TypeSpecificID = DefineID.TypeSpecificID
    ItemBPType = BackpackConfig.SpecialItemID[TypeSpecificID] or "Default"
    if ItemBPType == "Default" then
      local ItemType = DefineID.Type
      ItemBPType = BackpackConfig.SpecialItemType[ItemType] or "Default"
    end
    local ItemListCount = #self.tScrollListItemsUI
    local nReplaceIndex = itemIndex + 1
    for Index = itemIndex, ItemListCount - 1 do
      local ListItem = self.tScrollListItemsUI[Index + 1]
      if slua.IndexReference(ListItem.ItemData, "DefineID").TypeSpecificID == TypeSpecificID then
        bFind = true
        Use        nReplaceIndex = Index + 1
        break
      elseif DiscardIndex < 0 then
        local DiscardItem = self.tScrollListItemsUI[Index + 1]
        if DiscardItem and DiscardItem.ItemBPType == ItemBPType then
          Discard        end
      end
    end
    if bFind then
      self:_ChangeListItemType(UseListItem, CurData, itemIndex, nReplaceIndex, ItemBPType)
    elseif 0 <= DiscardIndex then
      UseListItem = self.tScrollListItemsUI[DiscardIndex + 1]
      self:_ChangeListItemType(UseListItem, CurData, itemIndex, DiscardIndex + 1, ItemBPType)
    else
      UseListItem = self.tScrollListItemsUI[itemIndex + 1]
      self:_ChangeListItemType(UseListItem, CurData, itemIndex, itemIndex + 1, ItemBPType)
    end
  end
  local nEndItemListCount = #self.tScrollListItemsUI
  if itemIndex + 1 <= nEndItemListCount - 1 then
    for Index_1 = itemIndex + 1, nEndItemListCount - 1 do
      local ListItem = self.tScrollListItemsUI[Index_1 + 1]
      ListItem:SetWidgetVisibility(ESlateVisibility.Collapsed)
      if ListItem then
        ListItem:ResetHandleBtns()
      end
    end
  end
end
function BackPackPanelUI:_GetBackpackItemDatas()
  local ItemDataArray = {}
  local BackpackComponentFromController = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(GameplayData.GetPlayerController())
  for ArrayIndex, CurData in pairs(self.LocalBackpackItemArray) do
    local DefineID = slua.IndexReference(CurData, "DefineID")
    local IsTaskItemType = BackpackUtils.IsTaskItemType(DefineID.Type)
    local IsScoreItemType = BackpackUtils.IsScoreItemType(DefineID.TypeSpecificID)
    local IsBackpackNeedToShowItemNew = BackpackUtils.IsBackpackNeedToShowItemNew(BackpackComponentFromController, DefineID.Type, IsScoreItemType, IsTaskItemType, CurData.bEquipping)
    IsBackpackNeedToShowItemNew = IsBackpackNeedToShowItemNew or self:LuaCheckBackpackNeedToShowItemNew(DefineID.TypeSpecificID, DefineID.Type)
    IsBackpackNeedToShowItemNew = self:LuaCheckBackpackNeedToShowItemOnMod(IsBackpackNeedToShowItemNew, DefineID.TypeSpecificID, DefineID.Type)
    local IsUseless = self:IsUseless(CurData)
    if not (IsBackpackNeedToShowItemNew or self:IsMeleeWeapon(CurData)) or TableUtil.Find(self.NotShowInBackpackItems, DefineID.TypeSpecificID) ~= -1 then
    else
      table.insert(ItemDataArray, {ItemData = CurData, IsUseless = IsUseless})
    end
  end
  return ItemDataArray
end
function BackPackPanelUI:LuaCheckBackpackNeedToShowItemOnMod(IsBackpackNeedToShowItemNew, TypeSpecificID, Type)
  return IsBackpackNeedToShowItemNew
end
function BackPackPanelUI:LuaCheckBackpackNeedToShowItemNew(TypeSpecificID, Type)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if BackpackConfig.LuaCheckBackpackNeedToShowItemType and BackpackConfig.LuaCheckBackpackNeedToShowItemType[Type] then
    local ItemSubType = BackpackUtils.GetItemSubType(TypeSpecificID)
    if BackpackConfig.LuaCheckBackpackNeedToShowItemSubType and BackpackConfig.LuaCheckBackpackNeedToShowItemSubType[ItemSubType] then
      return true
    end
  end
  return false
end
function BackPackPanelUI:_CreateListItem(Type)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if not BackpackConfig.ItemUIConfig[Type] then
    Type = "Default"
  end
  local Item = BackpackConfig.ItemUIConfig[Type]
  local ItemConfig = UIManager.UI_Config_InGame[Item]
  if type(Item) ~= "table" and ItemConfig then
    return self:_CreateListItem_NewVersion(ItemConfig, Type)
  else
    return self:_CreateListItem_OldVersion(Type)
  end
end
function BackPackPanelUI:_CreateListItem_NewVersion(ItemConfig, Type)
  local ListItem = self:CreateChildWindow(self.ScrollBox_ItemList, ItemConfig, self, Type)
  if ListItem.BackPackUI and ListItem.BackPackUI.tScrollListItemsUI and ListItem.BackPackUI.ItemMap then
    self.tScrollListItemsUI[#self.tScrollListItemsUI + 1] = ListItem
    self.ItemMap[ListItem.UIRoot] = ListItem
  end
  return ListItem
end
function BackPackPanelUI:_CreateListItem_OldVersion(Type)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  local ListItemBP, ListItem
  if not self.MultiBackPackItemPoolInfos[Type] then
    local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
    local ItemPool = UIBPFunctionLibrary.GenerateOneUIItemPool(slua.getWorld())
    ItemPool.bActiveItemListHold = true
    ItemPool:InitItemPool(BackpackConfig.ItemUIConfig[Type].UIPath, 2, false)
    self.MultiBackPackItemPoolInfos[Type] = {
      Pool = ItemPool,
      Module = GamePlayTools.GetModPath(true, BackpackConfig.ItemUIConfig[Type].ModulePath, true)
    }
  end
  local Pool = self.MultiBackPackItemPoolInfos[Type].Pool
  ListItemBP = Pool:GetOneItem()
  if not slua.isValid(ListItemBP) then
    local utility = require("common.utility")
    local UIPath = BackpackConfig.ItemUIConfig[Type].UIPath
    UIPath = string.sub(UIPath, 1, #UIPath - 2)
    local _, TempListItemBP = xpcall(slua.loadUI, utility.ErrorMessageHandler, UIPath)
    ListItemBP = TempListItemBP
  end
  if not slua.isValid(ListItemBP) then
    return
  end
  ListItem = require(self.MultiBackPackItemPoolInfos[Type].Module)()
  ListItem:InitWithWidget(ListItemBP)
  ListItem.ItemBP  self:AttachChildWindowByControl(self.ScrollBox_ItemList, ListItem)
  self.tScrollListItemsUI[#self.tScrollListItemsUI + 1] = ListItem
  self.ItemMap[ListItemBP] = ListItem
  self:AddControlEventByControl(ListItemBP, "HandleBtnsStateChange", self.RecordClickItem, self)
  self:AddControlEventByControl(ListItemBP, "ItemBeDropped", self.ShowDropCountSliderByStuff, self)
  self:AddControlEventByControl(ListItemBP, "ItemBeDragBegin", self.OnItemDragBegin, self)
  self:AddControlEventByControl(ListItemBP, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
  return ListItem
end
function BackPackPanelUI:_UpdateListItem(ListItem, CurData, itemIndex)
  ListItem:UpdateItemData(CurData.ItemData, CurData.IsUseless, self.ButtonMenu)
  ListItem:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  ListItem:RegisterCustomEvent()
  self.ScrollBox_ItemList:SwitchChildToIndex(ListItem.UIRoot, itemIndex)
  self:CheckItemFold(ListItem, false)
  ListItem:RefreshTimeOutItems()
end
function BackPackPanelUI:_ChangeListItemType(ListItem, CurData, itemIndex, nReplaceIndex, TargetType)
  if ListItem ~= nil then
    local OriType = ListItem.ItemBPType
    local Status = true
    if OriType == TargetType then
      Status = pcall(self._UpdateAndRefreshItemPos, self, itemIndex, nReplaceIndex, CurData, ListItem)
      if Status then
        print(bWriteLog and "BackPackPanelUI:_ChangeListItemType ", TargetType, " ID: " .. slua.IndexReference(CurData.ItemData, "DefineID").TypeSpecificID)
        return
      end
    end
    if not self.UselessItem[OriType] then
      self.UselessItem[OriType] = {}
    end
    if Status then
      table.insert(self.UselessItem[OriType], ListItem)
      ListItem:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    else
      pcall(ListItem.SetWidgetVisibility, ListItem, UEnums.GSlateVisibility.Collapsed)
    end
  end
  local NewItemUI
  if self.UselessItem and self.UselessItem[TargetType] and #self.UselessItem[TargetType] > 0 then
    NewItemUI = table.remove(self.UselessItem[TargetType], 1)
  else
    itemIndex = #self.tScrollListItemsUI
    NewItemUI = self:_CreateListItem(TargetType)
  end
  print(bWriteLog and string.format("BackPackPanelUI:_ChangeListItemType %s ID: %s", TargetType, slua.IndexReference(CurData.ItemData, "DefineID").TypeSpecificID))
  if NewItemUI then
    pcall(self._UpdateAndRefreshItemPos, self, itemIndex, nReplaceIndex, CurData, NewItemUI)
  end
end
function BackPackPanelUI:_UpdateAndRefreshItemPos(ItemIndex, ReplaceIndex, CurData, ItemUI)
  ItemUI:UpdateItemData(CurData.ItemData, CurData.IsUseless, self.ButtonMenu)
  ItemUI:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  ItemUI:RegisterCustomEvent()
  self.ScrollBox_ItemList:SwitchChildToIndex(ItemUI.UIRoot, ItemIndex)
  if ReplaceIndex ~= ItemIndex + 1 then
    self:SwapScrollListItemsUI(ItemIndex + 1, ReplaceIndex)
  end
  self:CheckItemFold(ItemUI, false)
end
function BackPackPanelUI:SwapScrollListItemsUI(itemIndex, nReplaceIndex)
  print(bWriteLog and "BackPackPanelUI:SwapScrollListItemsUI itemIndex:" .. itemIndex .. " nReplaceIndex:" .. nReplaceIndex)
  if not self.tScrollListItemsUI[itemIndex] or not self.tScrollListItemsUI[nReplaceIndex] then
    print(bWriteLog and "BackPackPanelUI:SwapScrollListItemsUI Error itemIndex:" .. itemIndex .. " nReplaceIndex:" .. nReplaceIndex .. " #self.tScrollListItemsUI" .. #self.tScrollListItemsUI)
    return
  end
  local ListItem = self.tScrollListItemsUI[itemIndex]
  self.tScrollListItemsUI[itemIndex] = self.tScrollListItemsUI[nReplaceIndex]
  self.tScrollListItemsUI[nReplaceIndex] = ListItem
end
function BackPackPanelUI:IsUseless(CurData)
  local CurDataDefineID = slua.IndexReference(CurData, "DefineID")
  local DefineID_Type = CurDataDefineID.Type
  local DefineID_TypeSpecificID = CurDataDefineID.TypeSpecificID
  local IsUseless = false
  if DefineID_Type == 10 then
    IsUseless = not self:IsSupportChip(DefineID_TypeSpecificID, DefineID_Type)
  elseif DefineID_Type == 2 or DefineID_Type == 3 then
    IsUseless = not self:IsGunSupportItem(DefineID_TypeSpecificID, DefineID_Type)
  end
  return IsUseless
end
function BackPackPanelUI:UpdateCapacity()
  local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
  if slua.isValid(uBackpackComponent) then
    self.TextBlock_MaxItemNum_Classic:SetText(tostring(math.floor(uBackpackComponent.Capacity)))
    local KismetMathLibrary = import("KismetMathLibrary")
    self.TextBlock_CurrentItemNum_Classic:SetText(tostring(KismetMathLibrary.FCeil(uBackpackComponent.OccupiedCapacity)))
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_BACKPACK_CAPACITY, self.CurExpandingStoreAreaType)
    print(bWriteLog and "BackPackPanelUI:UpdateCapacity Capacity:" .. uBackpackComponent.Capacity .. " OccupiedCapacity:" .. uBackpackComponent.OccupiedCapacity)
  end
end
function BackPackPanelUI:CloseAllScrollItemButton()
  for nIndex, ListItem in pairs(self.tScrollListItemsUI) do
    if ListItem then
      ListItem:ResetHandleBtns()
      if slua.isValid(self.DragDropWidgetWeaponDetail) and self.DragDropWidgetWeaponDetail:IsVisible() then
        self.DragDropWidgetWeaponDetail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function BackPackPanelUI:RecordClickItem(Widget, IsClicked, bForbidTips)
  local ListItem = self.ItemMap[Widget]
  if IsClicked then
    if ListItem ~= self.CrtClickItem and self.CrtClickItem then
      self.CrtClickItem:ResetHandleBtns()
    end
    self:ResetAttachSlots()
    self:ResetUpgradeWeapon()
    self:HightLightAttachSlots(Widget.ItemData)
    self:HighLightUpgradeWeapon(Widget.ItemData)
    self.CrtClickItem = ListItem
    self.ScrollBox_ItemList:ScrollWidgetIntoView(self.CrtClickItem.UIRoot, true, UEnums.EDescendantScrollDestination.IntoView)
    if not bForbidTips then
      self:ShowToolTips()
    end
  else
    self:HideToolTips()
    local BackpackDeleteControl = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackDeleteControl)
    if BackpackDeleteControl then
      BackpackDeleteControl:CloseSelf()
    end
    self:ResetAttachSlots()
    self:ResetUpgradeWeapon()
    self.CrtClickItem = nil
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_RECORD_CLICK_ITEM, Widget, IsClicked)
end
function BackPackPanelUI:ResetSelectItem()
  if self.CrtClickItem then
    self.CrtClickItem:ResetHandleBtns()
  end
end
function BackPackPanelUI:IsGunSupportItem(ItemId, ItemType)
  if #self.WeaponList > 0 then
    if ItemType == 2 then
      for i_23, Weapon in pairs(self.WeaponList) do
        if slua.isValid(Weapon) and Weapon.GetItemDefineID then
          local DefineID = Weapon:GetItemDefineID()
          local IsSupport = AvatarUtils.IsGunSupportAttachByRes(ItemId, DefineID.TypeSpecificID, false, EWeaponAttachmentSocketType.GunPoint)
          if IsSupport then
            return true
          end
        end
      end
      return false
    elseif ItemType == 3 then
      for i_26, Weapon in pairs(self.WeaponList) do
        if slua.isValid(Weapon) and Weapon.GetItemDefineID then
          local DefineID = Weapon:GetItemDefineID()
          local IsSupport = AvatarUtils.IsGunSupportBullet(ItemId, DefineID.TypeSpecificID)
          if IsSupport then
            return true
          else
            local ASTExtraShootWeapon = import("STExtraShootWeapon")
            if Game:IsClassOf(Weapon, ASTExtraShootWeapon) then
              local grenadelaunchcomponent = Weapon.GrenadeLaunchComponent
              if slua.isValid(grenadelaunchcomponent) and grenadelaunchcomponent.CanUseGrenadeLaunch and ItemId == grenadelaunchcomponent.BulletType.TypeSpecificID then
                return true
              end
            end
          end
        end
      end
    else
      return false
    end
  else
    return false
  end
end
function BackPackPanelUI:IsSupportChip(InItemID, InItemType)
  if InItemType == 10 then
    local ItemData = CDataTable.GetTableData("Item", InItemID)
    local CanEquipItemMap = AvatarUtils.GetChipCanEquipItemList(ItemData and ItemData.ItemSubType or 0)
    local PlayerController = self.UIRoot:GetOwningPlayer()
    if slua.isValid(PlayerController) then
      local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
      local EquippedArmors = BackpackUtils.GetEuqippedArmorInBackpack(uBackpackComponent)
      for i_7, Armor in pairs(EquippedArmors) do
        local Result = CanEquipItemMap:Get(slua.IndexReference(Armor, "DefineID").TypeSpecificID) ~= nil
        if Result then
          return true
        end
      end
      return false
    end
  else
    return false
  end
end
function BackPackPanelUI:IsSupportUpgradeItem(InItemID, InItemType)
  local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
  if not ItemConfig.WeaponUpgradeSkill[InItemID] then
    return false
  end
  local Weapon1 = self.WeaponInfoItem_Weapon1:GetCurrentWeapon()
  local Weapon2 = self.WeaponInfoItem_Weapon2:GetCurrentWeapon()
  local WeaponUpgradeConfig = require("GameLua.Mod.Livik.GamePlay.Weapon.WeaponUpgradeCfg")
  if Weapon1 and not Weapon1:HasUpgrade() and WeaponUpgradeConfig.UpgradeCfg[InItemID][Weapon1:GetItemDefineID().TypeSpecificID] then
    return true
  end
  if Weapon2 and not Weapon2:HasUpgrade() and WeaponUpgradeConfig.UpgradeCfg[InItemID][Weapon2:GetItemDefineID().TypeSpecificID] then
    return true
  end
  return false
end
function BackPackPanelUI:FilterAllExcludedItems(Items, ShouldDisplay)
  local FilteredItems = {}
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  local AllExcludedItemTypeConfig = BackpackConfig.AllExcludedItemTypeConfig
  local AllExcludedItemIDConfig = BackpackConfig.AllExcludedItemIDConfig
  for _, Item in pairs(Items) do
    local Type = Item.DefineID.Type
    local ItemID = Item.DefineID.TypeSpecificID
    local ItemSubType = BackpackUtils.GetItemSubType(Item.DefineID.TypeSpecificID)
    local bIsExcludedItemType = AllExcludedItemTypeConfig[Type] and ItemSubType == AllExcludedItemTypeConfig[Type]
    local bIsExcludedItemID = TableUtil.Find(AllExcludedItemIDConfig, ItemID) ~= -1
    if ShouldDisplay and (bIsExcludedItemType or bIsExcludedItemID) then
      table.insert(FilteredItems, Item)
    end
    if not ShouldDisplay and not bIsExcludedItemType and not bIsExcludedItemID then
      table.insert(FilteredItems, Item)
    end
  end
  return FilteredItems
end
local UtilsForFoldList = {
  SetImageWidth = function(Image, Width)
    if not Image then
      return
    end
    local Brush = slua.IndexReference(Image, "Brush"):clone()
    Brush.ImageSize = FVector2D(Width, Brush.ImageSize.Y)
    Image:SetBrush(Brush)
  end,
  SetImagePositionX = function(Image, PositionX)
    if not Image then
      return
    end
    local CanvasPanelSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(Image)
    local Pos = CanvasPanelSlot:GetPosition()
    CanvasPanelSlot:SetPosition(FVector2D(PositionX, Pos.Y))
  end,
  SetWidgetPaddingRight = function(Widget, WidgetPaddingRight)
    local GridSlot = WidgetLayoutLibrary.SlotAsGridSlot(Widget)
    if GridSlot then
      GridSlot:SetPadding(FMargin(0, 0, WidgetPaddingRight, 0))
    end
  end,
  SetDropWidgetPaddingRight = function(Widget, WidgetPaddingRight)
    local GridSlot = WidgetLayoutLibrary.SlotAsGridSlot(Widget)
    GridSlot:SetPadding(FMargin(0, 0, WidgetPaddingRight, 90))
  end,
  GetExpandIndex = function(bIsExpand)
    if bIsExpand then
      return ExpandListConfig.EState.Expand
    else
      return ExpandListConfig.EState.Fold
    end
  end
}
function BackPackPanelUI:InitFoldList()
  self.ItemFoldCleanList = {}
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self.bIsExpand = SettingConfig.bIsBackpackExpand
  printf("BackPackPanelUI:InitFoldList self.bIsExpand = %s", self.bIsExpand)
  self:UpdateExpandState()
  if self:IsTPlanMod() then
    self.bIsExpand = true
    self.UIRoot.Button_ToggleItemList:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SHOW_HANDLE_BTNS, self._OnShowHandleBtns, self)
    self:AddOnClickedEventByControl(self.UIRoot.Button_ToggleItemList, self.ToggleItemList, self)
  end
end
function BackPackPanelUI:_OnShowHandleBtns(_, __, ListItem)
  printf("BackPackPanelUI:_OnShowHandleBtns %s", ListItem)
  self:CheckItemFold(ListItem, true)
end
function BackPackPanelUI:ToggleItemList()
  if self:IsTPlanMod() then
    return
  end
  if self.isTogglingList then
    return
  end
  self.isTogglingList = true
  self.bIsExpand = not self.bIsExpand
  TableUtil.Clear(self.ItemFoldCleanList)
  self:UpdateExpandState()
  slua_GameFrontendHUD:BeginModifyUserSettings()
  slua_GameFrontendHUD:GetUserSettings().bIsBackpackExpand = self.bIsExpand
  slua_GameFrontendHUD:FinishModifyUserSettings()
  printf("BackPackPanelUI Set UserSettings bIsBackpackExpand = %s", slua_GameFrontendHUD:GetUserSettings().bIsBackpackExpand)
  self:AddGameTimer(0, false, function()
    if self.isTogglingList then
      self.isTogglingList = false
    end
  end)
end
function BackPackPanelUI:UpdateExpandState()
  if self:IsTPlanMod() then
    return
  end
  printf("BackPackPanelUI:UpdateExpandState bIsExpand = %s", self.bIsExpand)
  self:_UpdateContainerExpandState()
  self:_UpdateItemsExpandState()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_EXPAND_STATE, self.bIsExpand)
end
function BackPackPanelUI:_UpdateContainerExpandState()
  local bIsExpand = self.bIsExpand
  local ExpandIndex = UtilsForFoldList.GetExpandIndex(bIsExpand)
  UtilsForFoldList.SetImageWidth(self.UIRoot.Image_BackPackBG, ExpandListConfig.ItemListContainerWidth[ExpandIndex])
  UtilsForFoldList.SetImagePositionX(self.UIRoot.Image_BackPackBG1, ExpandListConfig.Background1PositionX[ExpandIndex])
  if bIsExpand then
    self.UIRoot.SizeBox_ExpandItemList:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.UIRoot.Image_CollapseItemList:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.TextBlock_Backpack:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.CanvasPanel_9:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetWidgetAutoSize(self.UIRoot.CanvasPanel_CapacityDisplay, false)
  else
    self.UIRoot.SizeBox_ExpandItemList:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Image_CollapseItemList:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.UIRoot.TextBlock_Backpack:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_9:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:SetWidgetAutoSize(self.UIRoot.CanvasPanel_CapacityDisplay, true)
  end
  local WidgetPaddingRight = ExpandListConfig.PopupWidgetPaddingRight[ExpandIndex]
  local DropPaddingRight = ExpandListConfig.DropPaddingRight[ExpandIndex]
  UtilsForFoldList.SetDropWidgetPaddingRight(self.UIRoot.CanvasPanel_BackpackDelete, DropPaddingRight)
  UtilsForFoldList.SetWidgetPaddingRight(self.PickUpItemTips.UIRoot, WidgetPaddingRight)
end
function BackPackPanelUI:_UpdateItemsExpandState()
  for _, ListItem in pairs(self.ItemMap) do
    self:CheckItemFold(ListItem, false)
  end
end
function BackPackPanelUI:CheckItemFold(ListItem, bForce)
  local ItemKey = tostring(ListItem)
  if self.ItemFoldCleanList[ItemKey] == nil or bForce == true then
    self.ItemFoldCleanList[ItemKey] = true
    ListItem:UpdateItemExpandState(self.bIsExpand, UtilsForFoldList)
  end
end