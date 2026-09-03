local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
local EBackPackDragOrigin = UEnums.EBackPackDragOrigin
function BackPackPanelUI:InitArmorSlot(ArmorSlot)
  if self.ForbidDragArmorType[ArmorSlot.ClothArmorType] ~= nil then
    print(bWriteLog and "SurfBoard Or SnowBoard Slot!!")
  else
    self:AddControlEventByControl(ArmorSlot, "ItemBeDragBegin", self.OnItemDragBegin, self)
    self:AddControlEventByControl(ArmorSlot, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
  end
end
function BackPackPanelUI:InitAllArmorSlots()
  local TableUtil = require("common.table_util")
  TableUtil.Clear(self.ArmorSlotType2WidgetMap)
  self.ArmorPlotItemArray = {
    self.ArmorSlotItem_Helmet,
    self.ArmorSlotItem_ArmoredVest,
    self.ArmorSlotItem_Package
  }
  for _, Item in pairs(self.ArmorPlotItemArray) do
    self:InitArmorSlot(Item)
    if self.ArmorSlotType2WidgetMap[Item.ClothArmorType] ~= nil then
    else
      self.ArmorSlotType2WidgetMap[Item.ClothArmorType] = Item
    end
  end
end
function BackPackPanelUI:EnsureArmorSlots(ArmorTypes)
  local ArmorSlotTypesToDelete = {}
  if not self.ArmorSlotTypesPersistent then
    self.ArmorSlotTypesPersistent = {
      EBackpackClothArmorType.Helmet,
      EBackpackClothArmorType.ArmoredVest,
      EBackpackClothArmorType.Package
    }
    if self.FriendlyBehaviorUI and self.FriendlyBehaviorUI.bEnableFriendlyBehavior then
      table.insert(self.ArmorSlotTypesPersistent, EBackpackClothArmorType.FriendlyBehavior)
    end
  end
  local TableUtil = require("common.table_util")
  ArmorSlotTypesToDelete = TableUtil.GetKeys(self.ArmorSlotType2WidgetMap)
  for _, v in ipairs(self.ArmorSlotTypesPersistent) do
    TableUtil.Remove(ArmorSlotTypesToDelete, v)
  end
  for i_1, ArmorType in pairs(ArmorTypes) do
    local SlotItem = self:GetArmorSlotItem(ArmorType)
    if Game:IsValid(SlotItem) then
    else
      print(bWriteLog and FuncUtil.GetFormatText("Create new BackPackArmorSlot_BP Type = {0} FAILED", tostring(ArmorType)))
    end
  end
  for _, v in ipairs(ArmorSlotTypesToDelete) do
    if self.ArmorSlotType2WidgetMap[v] ~= nil then
      self.ArmorSlotType2WidgetMap[v]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function BackPackPanelUI:GetArmorSlotItem(ArmorSlotType)
  local Type = ArmorSlotType
  local TableUtil = require("common.table_util")
  if self.ArmorSlotType2WidgetMap[Type] ~= nil then
    return self.ArmorSlotType2WidgetMap[Type]
  else
    print(bWriteLog and "BackPackPanelUI:GetSlotRow" .. tostring(Type))
    local SlotRow = self:GetSlotRow(Type)
    if 0 < SlotRow then
      local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local Widget = USTExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackArmorSlot_BP.BackPackArmorSlot_BP_C", self.UIRoot)
      self:InitArmorSlot(Widget)
      Widget.ClothArmor      self.IsDragEnable = self.ForbidDragArmorType[Type] == nil
      self.ArmorSlotType2WidgetMap[Type] = Widget
      TableUtil.UniqueInsert(self.ArmorPlotItemArray, Widget)
      local GridSlot = self.UniformGridPanel_Armor:AddChildToUniformGrid(Widget)
      local Row = self:GetSlotRow(Type)
      GridSlot:SetRow(Row)
      GridSlot:SetVerticalAlignment(UEnums.EVerticalAlignment.VAlign_Center)
      print(bWriteLog and FuncUtil.GetFormatText("Create new BackPackArmorSlot_BP Type = {0}", Row))
      return Widget
    else
      return nil
    end
  end
end
function BackPackPanelUI:HightLightArmorAttachSlots(ItemData)
  local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
  local IsAttach = BackPackFunctionLibrary.IsArmorAttach(ItemData.DefineID)
  if IsAttach then
    for i_6, Item in pairs(self.ArmorEquipInfoItemArray) do
      if Game:IsValid(Item) then
        Item:HighLightAttachSlot(ItemData.DefineID)
      end
    end
  end
end
function BackPackPanelUI:UpdateArmorSlotView()
  for i_2, Item in pairs(self.ArmorEquipInfoItemArray) do
    if Game:IsValid(Item) then
      Item:ResetBattleData()
      Item:UpdateSlotVisibility()
    end
  end
end
function BackPackPanelUI:UpdateArmorEquippingState()
  self:UpdateArmorSlotView()
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if Game:IsValid(PlayerController) then
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
    local BackpackUtils = import("BackpackUtils")
    local EquippedArmors = BackpackUtils.GetEuqippedArmorInBackpack(uBackpackComponent)
    for i_5, arrayelement_5 in pairs(EquippedArmors) do
      local ItemData = CDataTable.GetTableData("Item", slua.IndexReference(arrayelement_5, "DefineID").TypeSpecificID)
      local ItemSubType = ItemData and ItemData.ItemSubType or 0
      if ItemSubType == 501 then
        local Item = self.ArmorEquipInfoItemArray[3]
        if Game:IsValid(Item) then
          Item:UpdateArmorAppearanceInfo(arrayelement_5, EBackPackDragOrigin.FromBackpackWeaponDetail)
        end
      end
      if ItemSubType == 502 then
        local Item = self.ArmorEquipInfoItemArray[1]
        if Game:IsValid(Item) then
          Item:UpdateArmorAppearanceInfo(arrayelement_5, EBackPackDragOrigin.FromBackpackWeaponDetail)
        end
      end
      if ItemSubType == 503 or ItemSubType == 504 then
        local Item = self.ArmorEquipInfoItemArray[2]
        if Game:IsValid(Item) then
          Item:UpdateArmorAppearanceInfo(arrayelement_5, EBackPackDragOrigin.FromBackpackWeaponDetail)
        end
      end
    end
  end
end
function BackPackPanelUI:SetClothSlot(ClothingSlot, NewParam)
  if NewParam[ClothingSlot.ClothArmorType] ~= nil then
    local value_5 = NewParam[ClothingSlot.ClothArmorType]
    ClothingSlot:ShowClothIcon(value_5)
  else
    ClothingSlot:ShowNull()
  end
end
function BackPackPanelUI:GetArmorClothDataDict(InputPin)
  local DataTable = {}
  for i_2, arrayelement_2 in pairs(InputPin) do
    local ItemData = CDataTable.GetTableData("Item", slua.IndexReference(arrayelement_2, "DefineID").TypeSpecificID)
    local ClothEnum = self:ClothArmerType2Enum(ItemData and ItemData.ItemSubType or 0)
    if ClothEnum ~= nil then
      if DataTable[ClothEnum] ~= nil then
        if arrayelement_2.bEquipping then
          DataTable[ClothEnum] = arrayelement_2
        end
      else
        DataTable[ClothEnum] = arrayelement_2
      end
    end
  end
  return DataTable
end
function BackPackPanelUI:UpdateArmor(BattleItemData)
  if self.ArmorSlotTypesPersistent and self.ArmorSlotTypesPersistent[3] == EBackpackClothArmorType.Pistol then
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
    if not slua.isValid(uBackpackComponent) then
      return
    end
    local BackpackUtils = import("BackpackUtils")
    local Weapons = BackpackUtils.GetWeaponsInBackpack(uBackpackComponent)
    for _, Weapon in pairs(Weapons) do
      local ItemData = CDataTable.GetTableData("Item", Weapon.DefineID.TypeSpecificID)
      if ItemData and ItemData.ItemSubType == 106 then
        BattleItemData:Add(Weapon)
        break
      end
    end
  end
  self:UpdateArmorEquippingState()
  local DataDict = self:GetArmorClothDataDict(BattleItemData)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ARMOR_SLOT, DataDict)
  local TableUtil = require("common.table_util")
  local Keys = TableUtil.GetKeys(DataDict)
  self:EnsureArmorSlots(Keys)
  for i_1, Item in pairs(self.ArmorPlotItemArray) do
    self:SetArmorSlot(Item, DataDict)
  end
end
function BackPackPanelUI:SetArmorSlot(ArmorSlot, NewParam)
  if ArmorSlot.ClothArmorType == UEnums.EBackpackClothArmorType.FriendlyBehavior then
    return
  end
  if NewParam[ArmorSlot.ClothArmorType] ~= nil then
    local value_3 = NewParam[ArmorSlot.ClothArmorType]
    if value_3.Icon ~= "" then
      ArmorSlot:ShowSlot(value_3)
    else
      ArmorSlot:ShowNull()
    end
  else
    ArmorSlot:ShowNull()
  end
end
function BackPackPanelUI:ClothArmerType2Enum(SubType)
  if SubType == 401 then
    return EBackpackClothArmorType.Cap
  elseif SubType == 402 then
    return EBackpackClothArmorType.Mask
  elseif SubType == 403 then
    return EBackpackClothArmorType.Jacket
  elseif SubType == 404 then
    return EBackpackClothArmorType.Trouser
  elseif SubType == 405 then
    return EBackpackClothArmorType.Shoe
  elseif SubType == 406 then
    return EBackpackClothArmorType.Cap
  elseif SubType == 407 then
    return EBackpackClothArmorType.Glasses
  elseif SubType == 501 then
    return EBackpackClothArmorType.Package
  elseif SubType == 502 then
    return EBackpackClothArmorType.Helmet
  elseif SubType == 503 then
    return EBackpackClothArmorType.ArmoredVest
  elseif SubType == 504 then
    return EBackpackClothArmorType.NightVision
  elseif SubType == 505 then
    return EBackpackClothArmorType.Lighter
  elseif SubType == 506 then
    return EBackpackClothArmorType.SurfBoard
  elseif SubType == 507 then
    return EBackpackClothArmorType.Rabbit
  elseif SubType == 508 then
    return EBackpackClothArmorType.SnowBoard
  elseif SubType == 509 then
    return EBackpackClothArmorType.InformationCollector
  elseif SubType == 510 then
    return EBackpackClothArmorType.SkillEquipItem
  elseif SubType == 511 then
    return EBackpackClothArmorType.AutoAimEquipment
  elseif SubType == 106 then
    return EBackpackClothArmorType.Pistol
  elseif SubType == 1201 then
    return EBackpackClothArmorType.SkillProp
  else
    return EBackpackClothArmorType.Unknown
  end
end
function BackPackPanelUI:AddLightSlot(lighter)
end
function BackPackPanelUI:CollectArmorSlot()
  self.ArmorPlotItemArray = {}
  local TableUtil = require("common.table_util")
  for i = 0, self.UniformGridPanel_Armor:GetChildrenCount() - 1 do
    local AsBackpackArmorSlotBP = self.UniformGridPanel_Armor:GetChildAt(i)
    if Game:IsValid(AsBackpackArmorSlotBP) then
      TableUtil.UniqueInsert(self.ArmorPlotItemArray, AsBackpackArmorSlotBP)
    end
  end
  for i_13, Item in pairs(self.ArmorPlotItemArray) do
    if Item.ClothArmorType ~= EBackpackClothArmorType.SurfBoard then
      self:AddControlEventByControl(Item, "ItemBeDragBegin", self.OnItemDragBegin, self)
      self:AddControlEventByControl(Item, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
    else
      print(bWriteLog and "CollectArmor SurfBoard Slot!!")
    end
  end
end