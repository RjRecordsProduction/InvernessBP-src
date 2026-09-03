local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local BackpackUtils = import("BackpackUtils")
local EBackPackDragOrigin = UEnums.EBackPackDragOrigin
local EItemStoreArea = import("EItemStoreArea")
local EBattleItemDisuseReason = import("EBattleItemDisuseReason")
local LuaBackpackUtils = require("GameLua.Mod.Library.GamePlay.Backpack.LuaBackpackUtils")
local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
function BackPackPanelUI:HandleSafetyBoxItemDragDrop()
  if self.IsValuables and self:IsValuables() and self.CurExpandingStoreAreaType == EItemStoreArea.InSafetyBox then
    local ItemData = self.ItemBeDragged
    local BackpackTPlanLibrary = require("GameLua.Mod.TPlan.Client.Backpack.BackpackTPlanLibray")
    self.ValuablesTipUI = BackpackTPlanLibrary and BackpackTPlanLibrary.ShowValuablesTipsUI()
    if self.ValuablesTipUI then
      self:BindLuaObjEvent(self.ValuablesTipUI, "OnSureProcess", function()
        self:UnBindLuaObjEvent(self.ValuablesTipUI, "OnSureProcess")
        if not self.ItemBeDragged then
          self.ItemBeDragged = ItemData
        end
        self:HandleSafetyBoxItemDragDropImp()
      end)
      return
    end
  end
  self:HandleSafetyBoxItemDragDropImp()
end
function BackPackPanelUI:HandleSafetyBoxItemDragDropImp()
  local asbpstextraplayercontroller_4 = self.UIRoot:GetOwningPlayer()
  if slua.isValid(asbpstextraplayercontroller_4) then
    self:ChangeItemStoreArea(self.ItemBeDragged, false)
    local returnvalue_12 = self.DragItemOrigin ~= EBackPackDragOrigin.FromList
    if returnvalue_12 then
      self:UnEquipDraggedItemToSafetyBox()
    end
  end
end
function BackPackPanelUI:UnEquipDraggedItemToSafetyBox()
  local ItemBeDraggedType = self.ItemBeDragged.DefineID.Type
  local ItemBeDraggedDefineID = self.ItemBeDragged.DefineID
  if ItemBeDraggedType == 2 or ItemBeDraggedType == 10 then
    local asbpstextraplayercontroller_2 = self.UIRoot:GetOwningPlayer()
    if asbpstextraplayercontroller_2 ~= nil then
      if self.CurExpandingStoreAreaType == EItemStoreArea.InBag then
        asbpstextraplayercontroller_2:ServerDisuseItem(ItemBeDraggedDefineID, EBattleItemDisuseReason.PutIntoSafetyBox)
      elseif self.CurExpandingStoreAreaType == EItemStoreArea.InSafetyBox then
        asbpstextraplayercontroller_2:ServerDisuseItem(ItemBeDraggedDefineID, EBattleItemDisuseReason.Manually)
      end
    end
  elseif STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack() and (ItemBeDraggedType == 1 or ItemBeDraggedType == 5) then
    local asbpstextraplayercontroller_11 = self.UIRoot:GetOwningPlayer()
    if asbpstextraplayercontroller_11 ~= nil then
      if self.CurExpandingStoreAreaType == EItemStoreArea.InBag then
        asbpstextraplayercontroller_11:ServerDisuseItem(ItemBeDraggedDefineID, EBattleItemDisuseReason.PutIntoSafetyBox)
      elseif self.CurExpandingStoreAreaType == EItemStoreArea.InSafetyBox then
        asbpstextraplayercontroller_11:ServerDisuseItem(ItemBeDraggedDefineID, EBattleItemDisuseReason.PutBack)
      end
    end
  end
end
function BackPackPanelUI:InitWeaponDetailWidget()
  if STExtraModLogicSwitchLibrary.IsEnableWeaponAttachmentBindToWeapon() then
    local Widget = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/Mod/TPlan/EvoBase/BluePrints/UI/Backpack/XAndT_MainWeaponInfoItem_BP.XAndT_MainWeaponInfoItem_BP_C", self.UIRoot)
    if slua.isValid(Widget) then
      Widget:InitWidget(true)
      self.DragDropWidgetWeaponDetail = Widget
      self.CanvasPanel_WeaponDetail:AddChild(self.DragDropWidgetWeaponDetail)
      self.DragDropWidgetWeaponDetail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function BackPackPanelUI:UIMsg_UAVLastUsedItem(UAVLastUsedItem)
  self.end
function BackPackPanelUI:GetUAVBackpackItem()
  for nIndex, ListItem in pairs(self.tScrollListItemsUI) do
    if ListItem then
      local IsUAV = LuaBackpackUtils.IsUAV(ListItem.ItemData.DefineID.TypeSpecificID)
      if IsUAV then
        return ListItem.UIRoot
      end
    else
      return nil
    end
  end
  return nil
end
function BackPackPanelUI:SetUAVCDInf(Cd)
  if Cd ~= self.LastVehicleFinishCD then
    self.LastVehicleFinishCD = Cd
    for nIndex, ListItem in pairs(self.tScrollListItemsUI) do
      if ListItem then
        local ReturnValue = BackpackUtils.IsSameInstance(ListItem.ItemData.DefineID, self.UAVLastUsedItem)
        if ReturnValue then
          ListItem:SetCurrUsedUAVCDTime(self.LastVehicleFinishCD)
        else
          local ReturnValue_1 = LuaBackpackUtils.IsUAV(ListItem.ItemData.DefineID.TypeSpecificID)
          if ReturnValue_1 then
            ListItem:ShowDropAndUse()
          end
        end
      end
    end
  end
  return false
end
function BackPackPanelUI:DarkNight()
end
function BackPackPanelUI:ChangeItemStoreArea(ItemData, bFromButton)
  local EItemStoreArea = import("EItemStoreArea")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BackPackPanelUI:ChangeItemStoreArea uPlayerController is nil")
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(uPlayerController)
  if not slua.isValid(uBackpackComponent) then
    print(bWriteLog and "BackPackPanelUI:ChangeItemStoreArea uBackpackComponent is nil")
    return
  end
  local StoreArea = EItemStoreArea.InSafetyBox
  if self.CurExpandingStoreAreaType ~= EItemStoreArea.InBag then
    StoreArea = EItemStoreArea.InBag
  end
  local Capacity = uBackpackComponent:GetSafetyBoxCapacity()
  local OccupiedCapacity = uBackpackComponent.SafetyBoxOccupiedCapacity
  if StoreArea == EItemStoreArea.InBag then
    Capacity = uBackpackComponent.Capacity
    OccupiedCapacity = uBackpackComponent.OccupiedCapacity
  end
  local UnitWeight = ItemData.FeatureData.UnitWeight
  local CanSaveCount = ItemData.Count
  local DefineID = ItemData.DefineID
  if 0 < UnitWeight then
    local MaxCount = math.floor((Capacity - OccupiedCapacity) / UnitWeight)
    CanSaveCount = math.min(CanSaveCount, MaxCount)
  end
  if bFromButton then
    if 1 < CanSaveCount then
      UIManager.ShowUI(UIManager.UI_Config_InGame.BackpackDeleteControl, ItemData, nil, 69976, 69977, CanSaveCount, StoreArea, 1)
    else
      if not ItemConfig.CanSaveToSafetyBox(DefineID.TypeSpecificID) and StoreArea == EItemStoreArea.InSafetyBox then
        IngameTipsTools.BattleNormalTips(LocUtil.GetLocalizeResStr(35225))
        return
      end
      uPlayerController:ServerChangeItemStoreAreaNew(DefineID, 1, StoreArea)
      if StoreArea == EItemStoreArea.InBag then
        EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_MOVE_ITEM_OUT_SAFETYBOX, DefineID.TypeSpecificID)
      else
        EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_MOVE_ITEM_INTO_SAFETYBOX, DefineID.TypeSpecificID)
      end
    end
  else
    if not ItemConfig.CanSaveToSafetyBox(DefineID.TypeSpecificID) and StoreArea == EItemStoreArea.InSafetyBox then
      IngameTipsTools.BattleNormalTips(LocUtil.GetLocalizeResStr(35225))
      return
    end
    uPlayerController:ServerChangeItemStoreAreaNew(DefineID, ItemData.Count, StoreArea)
    if StoreArea == EItemStoreArea.InBag then
      EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_MOVE_ITEM_OUT_SAFETYBOX, DefineID.TypeSpecificID)
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_MOVE_ITEM_INTO_SAFETYBOX, DefineID.TypeSpecificID)
    end
  end
end