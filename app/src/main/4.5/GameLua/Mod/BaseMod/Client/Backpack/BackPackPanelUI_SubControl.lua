local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local EBattleItemDropReason = import("EBattleItemDropReason")
local EBackpackItemSortType = import("EBackpackItemSortType")
local EFreshWeaponStateType = import("EFreshWeaponStateType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function BackPackPanelUI:ShowDropCountSliderByStuff(Stuff, ForceDrop)
  local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
  local bCanDrop = BackPackFunctionLibrary.IsCanDropItem(Stuff)
  if bCanDrop and Stuff then
    local DropCount = Stuff.Count
    if DropCount == 1 or ForceDrop then
      local STExtraUIUtils = import("STExtraUIUtils")
      local uCharacter = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
      if slua.isValid(uCharacter) then
        local uCurrentShootWeapon = uCharacter:GetCurrentShootWeapon()
        if slua.isValid(uCurrentShootWeapon) then
          uCurrentShootWeapon:StopFire(EFreshWeaponStateType.FreshWeaponStateType_Idle)
        end
      end
      self:HandleClickDeleteConfirm(_, _, Stuff, UEnums.DropItem.Ground, Stuff.Count)
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame.BackpackDeleteControl, Stuff, UEnums.DropItem.Ground, 20303, 20305)
    end
  else
    IngameTipsTools.BattleNormalTipsByTextID(14136)
  end
end
function BackPackPanelUI:HandleClickDeleteConfirm(EventType, EventID, Stuff, DropTarget, ThrowCount)
  if not (DropTarget and DropTarget == UEnums.DropItem.Ground and ThrowCount) or ThrowCount <= 0 then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) or not Game:IsValid(uPlayerController.PlayerState) then
    return
  end
  if not self:CharacterIsAlive() then
    print(bWriteLog and "BackPackPanelUI:HandleClickDeleteConfirm Character Is Not Alive")
    return
  end
  if not self:ShouldDropItemFunc(Stuff.DefineID) then
    return
  end
  uPlayerController:ServerDropItem(Stuff.DefineID, ThrowCount, EBattleItemDropReason.Manually)
  uPlayerController:UserDropItemOperation(Stuff.DefineID)
  self.PendingDropDefineIDInstanceIDs[Stuff.DefineID.InstanceID] = true
  local bIsUseless = false
  local bFind = false
  for nIndex, ListItem in pairs(self.tScrollListItemsUI) do
    local BackpackUtils = import("BackpackUtils")
    if BackpackUtils.IsSameInstance(ListItem.ItemData.DefineID, Stuff.DefineID) then
      bIsUseless = ListItem.bIsUseless
      bFind = true
      break
    end
  end
  if not bFind and not Stuff.bEquipping then
    print(bWriteLog and "BackPackPanelUI:HandleClickDeleteConfirm warning Cannt FindInList and NotEquip:" .. tostring(Stuff.DefineID.TypeSpecificID))
  end
  if self.TlogOpenBagPanelNotSendTlog then
    self.TlogOpenBagPanelNotSendTlog = false
    uPlayerController.PlayerState:RPC_ServerAddGeneralCount(10527, 1, false)
  end
  if bIsUseless then
    uPlayerController.PlayerState:RPC_ServerAddGeneralCount(10526, 1, false)
  else
    uPlayerController.PlayerState:RPC_ServerAddGeneralCount(10528, 1, false)
  end
  print(bWriteLog and string.format("BackPackPanelUI:HandleClickDeleteConfirm ServerDrop Pending: TypeSpecificID = %s, InstanceID = %s", Stuff.DefineID.TypeSpecificID, Stuff.DefineID.InstanceID))
  print(bWriteLog and "BackPackPanelUI:HandleClickDeleteConfirm RPC_ServerAddGeneralCount TlogOpenBagPanelNotSendTlog:" .. tostring(self.TlogOpenBagPanelNotSendTlog) .. " bIsUseless:" .. tostring(bIsUseless))
end
function BackPackPanelUI:ShowToolTips()
  local ClickItemData = self.CrtClickItem.ItemData
  local TypeSpecificID = slua.IndexReference(ClickItemData, "DefineID").TypeSpecificID
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) and uGameState.IsEnableRedirectItemIdToAvatarID and uGameState:IsEnableRedirectItemIdToAvatarID() then
    local RedirectAvatarID = uGameState:GetRedirectAvatarID(TypeSpecificID)
    if 0 ~= RedirectAvatarID then
      TypeSpecificID = RedirectAvatarID
      print(bWriteLog and "BackPackPanelUI:ShowToolTips RedirectItemID=" .. RedirectAvatarID)
    end
  end
  local ItemData = CDataTable.GetTableData("Item", TypeSpecificID)
  self.PickUpItemTips:UpdateData(ItemData and ItemData.ItemSmallIcon or "", ItemData and ItemData.ItemName or "", ItemData and ItemData.ItemDesc or "", ClickItemData.Count, ItemData and ItemData.UnitWeight_f or 0, TypeSpecificID)
  self.PickUpItemTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SHOW_TOOL_TIPS)
end
function BackPackPanelUI:HideToolTips()
  self.PickUpItemTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BackPackPanelUI:ShowArmoToolTips_SkillProp(SpecificID, Brush)
  if self.CrtClickItem then
    self.CrtClickItem:ResetHandleBtns()
  end
  local ItemData = CDataTable.GetTableData("Item", SpecificID)
  self.PickUpItemTips:UpdateData(ItemData and ItemData.ItemSmallIcon or "", ItemData and ItemData.ItemName or "", ItemData and ItemData.ItemDesc or "", 1, ItemData and ItemData.UnitWeight_f or 0, SpecificID)
  self.PickUpItemTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function BackPackPanelUI:CharacterIsAlive()
  local Character = self.UIRoot:GetOwningPlayerPawn()
  if slua.isValid(Character) then
    return Character:IsAlive()
  else
    return true
  end
end
function BackPackPanelUI:ShowTabPanel(_, __, Tab, SwitcherIndex)
  if self.CurChosenTab ~= Tab then
    self.CurChosen    self:SetActiveWidget(self.WidgetSwitcher_0, SwitcherIndex)
    self:UpdateScrollItemListEvent()
    self:HighLightChosenTab()
    for _, Widget in pairs(self.tExtraWidgets) do
      if slua.isValid(Widget) then
        Widget:HandleClickTab()
      end
    end
    if self.CrtClickItem then
      self.CrtClickItem:ResetHandleBtns()
    end
    if self.FriendlyInfoPanel then
      self.FriendlyInfoPanel:Hide()
    end
  end
end
function BackPackPanelUI:SetActiveWidget(switcher, index)
  switcher:SetActiveWidgetIndex(index)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ONSWITCHTAB, index)
end
function BackPackPanelUI:HighLightChosenTab()
  self:ShowFitGroupImage(self.CurChosenTab)
  self.Image_All:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.Image_Cloth:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.Image_Store:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.Image_ArmorFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.Image_WeaponFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.Image_OthersFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.Image_ConsumFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  self.GridPanel_WeaponInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.CanvasPanel_ClothingGroup:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.CanvasPanel_StoreGroup:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  if self.Image_AllExcluded then
    self.Image_AllExcluded:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  end
  local Tab = self.CurChosenTab
  local EBackpackTab = UEnums.EBackpackTab
  if Tab == EBackpackTab.AllItem then
    self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_WeaponInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_All:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif Tab == EBackpackTab.WeaponFitItem then
    self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_WeaponInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_WeaponFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif Tab == EBackpackTab.ConsumableItem then
    self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_ConsumFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif Tab == EBackpackTab.AvatarItem then
    if self.bOpenChangeWearing then
      self:CreateBackpackClothPanel()
      self.CanvasPanel_ClothingGroup:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.Image_Cloth:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    end
  elseif Tab == EBackpackTab.ArmorItem then
    self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_WeaponInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_ArmorFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif Tab == EBackpackTab.SundriesItem then
    self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_OthersFit:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif Tab == EBackpackTab.StoreItem then
    self.CanvasPanel_StoreGroup:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Store:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif Tab == EBackpackTab.AllExcludedItem then
    self.GridPanel_BackPackList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_BackPackListParent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_AllExcluded:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
end
local ImagePath = {
  Image_All = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_All_1_png.BackPack_Icon_All_1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_All_2_png.BackPack_Icon_All_2_png"
  },
  Image_WeaponFit = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Gun_1_png.BackPack_Icon_Gun_1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Gun_2_png.BackPack_Icon_Gun_2_png"
  },
  Image_ArmorFit = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Helmet_1_png.BackPack_Icon_Helmet_1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Helmet_2_png.BackPack_Icon_Helmet_2_png"
  },
  Image_ConsumFit = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Consumables_1_png.BackPack_Icon_Consumables_1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Consumables_2_png.BackPack_Icon_Consumables_2_png"
  },
  Image_OthersFit = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Sundries_1_png.BackPack_Icon_Sundries_1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/BackPack_Icon_Sundries_2_png.BackPack_Icon_Sundries_2_png"
  },
  Image_AllExcluded = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/WH_Icon_Sprop_png.WH_Icon_Sprop_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/WH_Icon_Sprop_png.WH_Icon_Sprop_png"
  }
}
function BackPackPanelUI:ShowFitGroupImage(Tab)
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local returnvalue_33 = STExtraModLogicSwitchLibrary.IsActiveBackpackTabAndSort()
  if returnvalue_33 then
    if ImagePath.Image_All and ImagePath.Image_All[1] then
      self.Image_All:SetBrushFromPathAsync(ImagePath.Image_All[1], false)
    end
    if ImagePath.Image_WeaponFit and ImagePath.Image_WeaponFit[1] then
      self.Image_WeaponFit:SetBrushFromPathAsync(ImagePath.Image_WeaponFit[1], false)
    end
    if ImagePath.Image_ArmorFit and ImagePath.Image_ArmorFit[1] then
      self.Image_ArmorFit:SetBrushFromPathAsync(ImagePath.Image_ArmorFit[1], false)
    end
    if ImagePath.Image_ConsumFit and ImagePath.Image_ConsumFit[1] then
      self.Image_ConsumFit:SetBrushFromPathAsync(ImagePath.Image_ConsumFit[1], false)
    end
    if ImagePath.Image_OthersFit and ImagePath.Image_OthersFit[1] then
      self.Image_OthersFit:SetBrushFromPathAsync(ImagePath.Image_OthersFit[1], false)
    end
    if self.Image_AllExcluded and ImagePath.Image_AllExcluded and ImagePath.Image_AllExcluded[1] then
      self.Image_AllExcluded:SetBrushFromPathAsync(ImagePath.Image_AllExcluded[1], false)
    end
    self.Image_All:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    local EBackpackTab = UEnums.EBackpackTab
    if Tab == EBackpackTab.AllItem then
      if ImagePath.Image_All and ImagePath.Image_All[2] then
        self.Image_All:SetBrushFromPathAsync(ImagePath.Image_All[2], false)
      end
    elseif Tab == EBackpackTab.WeaponFitItem then
      if ImagePath.Image_WeaponFit and ImagePath.Image_WeaponFit[2] then
        self.Image_WeaponFit:SetBrushFromPathAsync(ImagePath.Image_WeaponFit[2], false)
      end
    elseif Tab == EBackpackTab.ConsumableItem then
      if ImagePath.Image_ConsumFit and ImagePath.Image_ConsumFit[2] then
        self.Image_ConsumFit:SetBrushFromPathAsync(ImagePath.Image_ConsumFit[2], false)
      end
    elseif Tab == EBackpackTab.ArmorItem then
      if ImagePath.Image_ArmorFit and ImagePath.Image_ArmorFit[2] then
        self.Image_ArmorFit:SetBrushFromPathAsync(ImagePath.Image_ArmorFit[2], false)
      end
    elseif Tab == EBackpackTab.SundriesItem then
      if ImagePath.Image_OthersFit and ImagePath.Image_OthersFit[2] then
        self.Image_OthersFit:SetBrushFromPathAsync(ImagePath.Image_OthersFit[2], false)
      end
    elseif Tab == EBackpackTab.AllExcludedItem and ImagePath.Image_AllExcluded and ImagePath.Image_AllExcluded[2] then
      self.Image_AllExcluded:SetBrushFromPathAsync(ImagePath.Image_AllExcluded[2], false)
    end
  end
end
function BackPackPanelUI:InitBackpackSortTag()
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local returnvalue_2 = STExtraModLogicSwitchLibrary.IsActiveBackpackTabAndSort()
  if returnvalue_2 then
    self.GridPanel_AttachmentFit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_ConsumFit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_OthersFit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.GridPanel_ClothFit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:OnSelectSortType(EBackpackItemSortType.ECT_Type)
    local returnvalue_9 = STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack()
    if returnvalue_9 then
      self.GridPanel_ArmorFit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.GridPanel_ArmorFit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.GridPanel_ArmorFit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.GridPanel_AttachmentFit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.GridPanel_ConsumFit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.GridPanel_OthersFit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.ClothFitActive then
      self.GridPanel_ClothFit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.GridPanel_AllExcluded then
    if self:IsInAllItemFilterMode() then
      self.GridPanel_AllExcluded:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.GridPanel_AllExcluded:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function BackPackPanelUI:OnSelectSortType(SortType)
  local returnvalue_3 = SortType ~= self.CurSortType
  if returnvalue_3 then
    self.Cur    local returnvalue_7 = self.CurSortType == EBackpackItemSortType.EIS_Default
    if returnvalue_7 then
      local localbackpackitemarray_1 = self.LocalBackpackItemArray
      local BackpackUtils = import("BackpackUtils")
      BackpackUtils.SortBattleItemsByType(localbackpackitemarray_1, EBackpackItemSortType.EIS_Default)
      self:UpdateScrollItemListItems_2(self.LocalBackpackItemArray)
    else
      self:UpdateScrollItemListItems_2(self.LocalBackpackItemArray)
    end
  end
end
function BackPackPanelUI:CreateBackpackClothPanel()
  if self.bOpenChangeWearing and self.CanvasPanel_ClothingGroup:GetChildrenCount() == 0 then
    if self.BackpackClothPanel then
      return
    end
    self.BackpackClothPanel = self:CreateChildWindow("CanvasPanel_ClothingGroup", UIManager.UI_Config_InGame.MainBackpackAvatarPanel)
  end
end