local PickUpItem_BP = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local KismetInputLibrary = import("KismetInputLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local DIYItemIDs = {
  [1400708] = true,
  [1499999] = true,
  [1406225] = true,
  [140070801] = true,
  [140070802] = true,
  [140070803] = true,
  [140070804] = true,
  [140070805] = true,
  [140070806] = true
}
local WhiteColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
function PickUpItem_BP:ctor()
  self.CacheItemTable = {}
  self.ModItemLabel = nil
end
function PickUpItem_BP:Construct()
  self:BindQuickSignDel()
  self:AddControlEvent(self.Image_ItemIcon, "OnSetBrushAsyncComplete", function()
    self.Image_ItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
  if EVENTTYPE_CREATIVE then
    self:AddCommonEvent(EVENTTYPE_CREATIVE, EVENTID_TRANS_CLIENT_REFRESH, self.OnRefreshText, self)
  end
end
function PickUpItem_BP:UpdateItemNameAndIcon(nItemID, AdditionalData)
  print(bWriteLog and "PickUpItem_BP:UpdateItemNameAndIcon", nItemID, AdditionalData)
  local TableUtil = require("common.table_util")
  local ColorID, PatternID = 0, 0
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) and uGameState.IsEnableRedirectItemIdToAvatarID and uGameState:IsEnableRedirectItemIdToAvatarID() then
    local RedirectAvatarID = uGameState:GetRedirectAvatarID(nItemID)
    if 0 ~= RedirectAvatarID then
      nItemID = RedirectAvatarID
      print(bWriteLog and "PickUpItem_BP:UpdateItemNameAndIcon RedirectItemID=" .. RedirectAvatarID)
    end
  end
  self._  self._  if DIYItemIDs[nItemID] then
    ColorID, PatternID = self:GetDIYClothColorAndPattern(AdditionalData)
  end
  print(bWriteLog and "ListItemUIBase:UpdateItemNameAndIcon", self.ModItemLabel)
  if self.ModItemLabel then
    self.ModItemLabel:UpdateItem(nItemID)
  end
  local ItemData = self:GetItemTableData(nItemID)
  if not ItemData then
    return
  end
  self:CheckAndShowCriticalIcon()
  self:ShowItemTeamInfo()
  if self:CheckItemValueChanged(self.LastItemID, nItemID) and self:CheckItemValueChanged(self.LastColor, ColorID) and self:CheckItemValueChanged(self.LastPatternID, PatternID) then
    return
  end
  local TrueName = 0 < ColorID and self:GetDIYClothName(ItemData.ItemName or "", ColorID, PatternID) or ItemData.ItemName
  self.ItemContent11:SetText(TrueName)
  self.LastColor = ColorID
  self.Last  if self:CheckItemValueChanged(self.LastItemID, nItemID) then
    return
  end
  self.Image_ItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if ItemData.ItemSmallIcon then
    self.Image_ItemIcon:SetBrushFromPathAsync(ItemData.ItemSmallIcon, false)
  end
  self.IconPath = ItemData.ItemSmallIcon
  if self:NeedShowPickupDesc(ItemData) then
    self.ItemPickupDesc:SetText(ItemData.PickupDesc or "")
    self.ItemPickupDesc:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
  else
    self.ItemPickupDesc:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  self.LastItemID = nItemID
  self:OnLongPressCancel()
end
function PickUpItem_BP:OnRefreshText()
  print(bWriteLog and "PickUpItem_BP:OnRefreshText")
  self.LastItemID = 0
  if self._nItemID then
    self:UpdateItemNameAndIcon(self._nItemID, self._AdditionalData)
  end
end
function PickUpItem_BP:CheckAndShowCriticalIcon()
  print(bWriteLog and "PickUpItem_BP:CheckAndShowCriticalIcon [1]")
  if not self.CanvasPanel_Crit or not slua.isValid(self.CanvasPanel_Crit) then
    return
  end
  self.CanvasPanel_Crit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PickUpItemResult = slua.IndexReference(self, "ItemDataStructure")
  if not PickUpItemResult or not PickUpItemResult.MainItemData then
    print(bWriteLog and "PickUpItem_BP:CheckAndShowCriticalIcon [4] No pickup item data")
    return
  end
  local bIsCriticalDrop = false
  local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
  if PickUpItemResult.Wrapper and slua.isValid(PickUpItemResult.Wrapper) and PickUpItemResult.Wrapper.SavedAdditionalDataList then
    for i = 0, PickUpItemResult.Wrapper.SavedAdditionalDataList:Num() - 1 do
      local AdditionalData = PickUpItemResult.Wrapper.SavedAdditionalDataList:Get(i)
      if AdditionalData and AdditionalData.EDataType == EBattleItemAdditionalDataType.ExtraData01 and AdditionalData.IntData == 999 then
        bIsCriticalDrop = true
        print(bWriteLog and "PickUpItem_BP:CheckAndShowCriticalIcon [5] Critical drop detected from SavedAdditionalDataList")
        break
      end
    end
  end
  print(bWriteLog and "PickUpItem_BP:CheckAndShowCriticalIcon [6] bIsCriticalDrop: " .. tostring(bIsCriticalDrop))
  local Visbility = bIsCriticalDrop and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed
  self.CanvasPanel_Crit:SetWidgetVisibility(Visbility)
  self.Image_Crit:SetWidgetVisibility(Visbility)
end
function PickUpItem_BP:NeedShowPickupDesc(ItemData)
  return ItemData.ItemType == UEnums.EBackpackItemType.Weapon and ItemData.ItemSubType ~= UEnums.EBackpackItemSubType.MeleeWeapon
end
function PickUpItem_BP:CheckItemValueChanged(LastValue, Value)
  return LastValue ~= nil and LastValue == Value
end
function PickUpItem_BP:GetItemTableData(ItemID)
  if not self.CacheItemTable then
    self.CacheItemTable = {}
  end
  local ItemData = self.CacheItemTable[ItemID]
  if not ItemData then
    ItemData = CDataTable.GetTableData("Item", ItemID)
    self.CacheItemTable[ItemID] = ItemData
  end
  return ItemData
end
function PickUpItem_BP:OnDestroy()
  self:RemoveLongPressTimer()
  print(bWriteLog and "PickUpItemTips:OnDestroy")
  self:Dispose()
end
function PickUpItem_BP:OnLongPressCancel()
  self:RemoveLongPressTimer()
  self.ProgressBar_LongPress:SetPercent(0)
end
function PickUpItem_BP:RemoveLongPressTimer()
  print(bWriteLog and "PickUpItem_BP:RemoveLongPressTimer")
  if self.LongPressTimer then
    self:RemoveGameTimer(self.LongPressTimer)
    self.LongPressTimer = nil
  end
end
function PickUpItem_BP:TouchBegin(mouseEvent)
  print(bWriteLog and "PickUpItem_BP:TouchBegin")
  local ScreenPosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(mouseEvent)
  self.StartPoint = ScreenPosition
  self.bIsLongPress = false
  self.bHasStartedTouchIn = true
  self:RemoveLongPressTimer()
  if self.IsAnimationPlaying(self.fadein_click) then
    self.fadein_click:StopAnimation()
    self.Image_Marked:SetRenderTranslation(FVector2D(0, 0))
    self.Image_Marked:SetOpacity(1)
  end
  self.ProgressBar_LongPress:SetPercent(0)
  self.CurPercent = -0.5
  self.LongPressTimer = self:AddGameTimer(0.05, true, function()
    self:OnLongPressTick()
  end)
end
function PickUpItem_BP:OnLongPressTick()
  if self.CurPercent < 0 then
    self.CurPercent = self.CurPercent + 0.05
    return
  end
  if self:GetVisibility() == UEnums.GSlateVisibility.Collapsed then
    self:RemoveLongPressTimer()
    return
  end
  if not self.isBoxItem then
    local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
    if PickUpListPanel and PickUpListPanel:GetVisibility() == UEnums.GSlateVisibility.Collapsed then
      self:RemoveLongPressTimer()
      return
    end
  end
  print(bWriteLog and "PickUpItem_BP:OnLongPressTick : " .. self.CurPercent)
  self.CurPercent = self.CurPercent + 0.1
  self.ProgressBar_LongPress:SetPercent(self.CurPercent)
  if self.CurPercent > 0 then
    self.ProgressBar_LongPress:SetFillColorAndOpacity(WhiteColor)
  end
  if self.CurPercent >= 1 then
    self:PlayUserWidgetAnimation(self.fadein_click, 0, 1, 0, 1)
    self:OnLongPressItem()
    self:RemoveLongPressTimer()
  end
end
function PickUpItem_BP:TouchMove(mouseEvent)
  if self.LongPressTimer == nil then
    return
  end
  local ScreenPosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(mouseEvent)
  if ScreenPosition.X == 0 and ScreenPosition.Y == 0 then
    return
  end
  local diffX = ScreenPosition.X - self.StartPoint.X
  local diffY = ScreenPosition.Y - self.StartPoint.Y
  if 5 <= diffX or diffX <= -5 or 5 <= diffY or diffY <= -5 then
    self:RemoveLongPressTimer()
    self.ProgressBar_LongPress:SetPercent(0)
    self.CurPercent = 0
  end
end
function PickUpItem_BP:ShowDurableInternal(PickupItemResult)
  local CurDuability = 0
  local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
  local ItemTableData = self:GetItemTableData(self.TypeSpecificID)
  if not ItemTableData then
    self.ProgressBar_Damage:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local LocalDurability = ItemTableData.Durability
  if LocalDurability and LocalDurability ~= 0 then
    CurDuability = -1.0
    for ArrayIndex, ArrayElement in pairs(slua.IndexReference(PickupItemResult, "MainItemData", "AdditionalDataList")) do
      if ArrayElement.EDataType == EBattleItemAdditionalDataType.RemainingDuability then
        CurDuability = ArrayElement.FloatData
        break
      end
    end
    self.ProgressBar_Damage:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if slua.isValid(PickupItemResult.Wrapper) and PickupItemResult.Wrapper.bDropedByPlayer then
      if CurDuability < 0.0 then
        CurDuability = LocalDurability
        self.ProgressBar_Damage:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      else
        self.ProgressBar_Damage:SetPercent(1.0 - CurDuability / LocalDurability)
      end
    else
      self.ProgressBar_Damage:SetPercent(0.0)
    end
  else
    self.ProgressBar_Damage:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:ShowRecycItemPrice(PickupItemResult)
end
function PickUpItem_BP:ShowRecycItemPrice(PickupItemResult)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local CurrentMapType = GameMainConfig.GetMapType()
  if CurrentMapType ~= "Neon" then
    return
  end
  if not GameMainConfig.ShouldShowRecycItemPrice() then
    return
  end
  local Visibility = UEnums.ESlateVisibility.Collapsed
  local Config = CDataTable.GetTableData("RecycleStore", self.TypeSpecificID)
  if Config then
    Visibility = UEnums.ESlateVisibility.HitTestInvisible
    self.TextBlock_Value:SetText(Config.Price)
  end
  self.HorizontalBox_Value:SetWidgetVisibility(Visibility)
end
function PickUpItem_BP:PickupDetailEvent()
  local PickUpItemResult
  if self.isBoxItem then
    PickUpItemResult = slua.IndexReference(self, "SortInfo", "pickUpItemResult")
  else
    PickUpItemResult = slua.IndexReference(self, "ItemDataStructure")
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_WEAPONDETIAL_PICKUP_WIDGET_OPEN_AND_UPDATE, PickUpItemResult, self.isBoxItem or false)
  local MainItemDataID = slua.IndexReference(PickUpItemResult, "MainItemData", "ID")
  self.CurShowDetailWeaponID = MainItemDataID.TypeSpecificID
end
function PickUpItem_BP:LuaMouseLeave()
  print(bWriteLog and "PickUpItem_BP:LuaMouseLeave")
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    PickUpListPanel:HideToolTips()
  end
end
function PickUpItem_BP:GetPickUpListPanelMoveOut()
  print(bWriteLog and "PickUpItem_BP:GetPickUpListPanelMoveOut")
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    return PickUpListPanel.MoveOut
  end
  return false
end
function PickUpItem_BP:GetPickUpListPanelCustomizePickUpPanelMoveOut()
  print(bWriteLog and "PickUpItem_BP:GetPickUpListPanelCustomizePickUpPanelMoveOut")
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    return PickUpListPanel.UIRoot.CustomizePickUpPanel_BP.MoveOut
  end
  return false
end
function PickUpItem_BP:SingleLuaOnTouchEnd()
  print(bWriteLog and "PickUpItem_BP:SingleLuaOnTouchEnd")
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and self.bHasStartedTouchIn then
    self.bHasStartedTouchIn = false
    self:SingleHandlePickup()
  end
end
function PickUpItem_BP:SingleHandlePickup()
  print(bWriteLog and "PickUpItem_BP:SingleHandlePickup")
  local bMoveOut = self:GetPickUpListPanelCustomizePickUpPanelMoveOut()
  if bMoveOut then
    print(bWriteLog and "PickUpItem_BP:SingleHandlePickup pickupError: by moveOut2")
  else
    local Config = CDataTable.GetTableData("Item", self.TypeSpecificID)
    local EBattleItemPickupRule = import("EBattleItemPickupRule")
    local PickUpItemResult = slua.IndexReference(self, "ItemDataStructure")
    if Config and Config.ItemPickupRule == EBattleItemPickupRule.AllCanSeeSelfCanPickUp and PickUpItemResult and PickUpItemResult.Wrapper and slua.isValid(PickUpItemResult.Wrapper) then
      local OwnerUniqueID = PickUpItemResult.Wrapper.OwnerUniqueID
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local playerState = GameplayData.GetPlayerState()
      if slua.isValid(playerState) and 0 < OwnerUniqueID and OwnerUniqueID ~= playerState.PlayerKey and OwnerUniqueID ~= playerState.PlayerId then
        print(bWriteLog and "PickUpItem_BP:SingleHandlePickup OwnerUniqueID error not alongtoyou")
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
        local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
        if BackpackConfig and BackpackConfig.SelfCanPickUpItemTipID and BackpackConfig.SelfCanPickUpItemTipID[self.TypeSpecificID] then
          BattleNormalTipsByTextID(BackpackConfig.SelfCanPickUpItemTipID[self.TypeSpecificID], "", "")
        end
        return
      end
    end
    self:HandlePickup()
  end
end
function PickUpItem_BP:DeadBoxOnTouchEnd()
  local bMoveOut = self:GetPickUpListPanelMoveOut()
  if bMoveOut then
    print(bWriteLog and "PickUpItem_BP:DeadBoxOnTouchEnd pickupError: by moveOut2")
  else
    self:HandlePickup()
  end
end
function PickUpItem_BP:ShowItemTeamInfo()
  print(bWriteLog and "PickUpItem_BP:ShowItemTeamInfo")
  local Config = CDataTable.GetTableData("Item", self.TypeSpecificID)
  local EBattleItemPickupRule = import("EBattleItemPickupRule")
  if Config and Config.ItemPickupRule == EBattleItemPickupRule.AllCanSeeSelfCanPickUp then
    local PickUpItemResult = slua.IndexReference(self, "ItemDataStructure")
    if not self.SurprisePickUpItem and self.CanvasParent then
      self.SurprisePickUpItem = UIManager.ShowUI(UIManager.UI_Config_InGame.SurprisePickUpItem)
      self.CanvasParent:AddChild(self.SurprisePickUpItem.UIRoot)
      self.SurprisePickUpItem:SetAnchors(0, 0, 1, 1)
      self.SurprisePickUpItem:SetOffsets(0, 0, 0, 0)
    end
    if self.SurprisePickUpItem then
      self.SurprisePickUpItem:SetParentAndData(self, PickUpItemResult)
    end
  elseif self.SurprisePickUpItem then
    self.SurprisePickUpItem.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, PickUpItem_BP)