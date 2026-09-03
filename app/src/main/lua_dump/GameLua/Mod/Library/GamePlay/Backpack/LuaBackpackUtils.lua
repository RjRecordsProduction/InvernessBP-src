local LuaBackpackUtils = {}
local UBackpackUtils_C = import("BackpackUtils")
local TableUtil = require("common.table_util")
local AvatarUtils = import("AvatarUtils")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EItemAssociationType = import("EItemAssociationType")
function LuaBackpackUtils.GetEmptyChipSlotIdx(ItemData, SupportChipNum)
  local CacheEquipSlot = {}
  TableUtil.Clear(CacheEquipSlot)
  for ArrayIndex, ArrayElement in pairs(ItemData.Associations) do
    if ArrayElement.AssociationType == EItemAssociationType.ChipSlot1 then
      CacheEquipSlot[1] = true
    elseif ArrayElement.AssociationType == EItemAssociationType.ChipSlot2 then
      CacheEquipSlot[2] = true
    elseif ArrayElement.AssociationType == EItemAssociationType.ChipSlot3 then
      CacheEquipSlot[3] = true
    end
  end
  for Index = 1, SupportChipNum do
    if CacheEquipSlot[Index] then
    else
      return Index
    end
  end
  return 0
end
function LuaBackpackUtils.GetCanUseChipSlotIdx(ItemData, SupportChipNum, ItemTableData, EquipItemData)
  local SelectIndex = -1
  local SelectDuability = ItemTableData.Durability
  local ExchangeDuability = LuaBackpackUtils.GetArmorCurHP(EquipItemData.AdditionalData)
  if ExchangeDuability then
    SelectDuability = ExchangeDuability
  end
  local BackpackComponentFromController = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(GameplayData.GetPlayerController())
  for ArrayIndex, ArrayElement in pairs(ItemData.Associations) do
    if ArrayElement.AssociationType == EItemAssociationType.ChipSlot1 or ArrayElement.AssociationType == EItemAssociationType.ChipSlot2 or ArrayElement.AssociationType == EItemAssociationType.ChipSlot3 then
      local Num = LuaBackpackUtils.GetChipIndexFormAssociationType(ArrayElement.AssociationType)
      local uBattleData = BackpackComponentFromController:GetItemByDefineID(ArrayElement.AssociationTargetDefineID)
      if slua.isValid(uBattleData) then
        local CurrentDuability = LuaBackpackUtils.GetArmorCurHP(uBattleData.AdditionalData)
        if CurrentDuability and SelectDuability > CurrentDuability then
          SelectIndex = Num
          SelectDuability = CurrentDuability
        end
      end
    end
  end
  return SelectIndex
end
function LuaBackpackUtils.GetChipIndexFormAssociationType(InEItemAssociationType)
  if InEItemAssociationType == EItemAssociationType.ChipSlot1 then
    return 1
  elseif InEItemAssociationType == EItemAssociationType.ChipSlot2 then
    return 2
  elseif InEItemAssociationType == EItemAssociationType.ChipSlot3 then
    return 3
  end
end
function LuaBackpackUtils.GetArmorCurHP(ItemDataAdditionalData)
  local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
  for index = 0, ItemDataAdditionalData:Num() - 1 do
    local ItemDataAdditional = ItemDataAdditionalData:Get(index)
    if ItemDataAdditional.EDataType == EBattleItemAdditionalDataType.RemainingDuability then
      return ItemDataAdditional.FloatData
    end
  end
end
function LuaBackpackUtils.GetEquipChipSlot(ItemDataList, CanEquipItemMap, UseEmptySlot, ItemTableData, BattleItem)
  local DefineID
  for ArrayIndex, ArrayElement in pairs(ItemDataList) do
    DefineID = ArrayElement.DefineID
    local TypeSpecificID = DefineID.TypeSpecificID
    if CanEquipItemMap:Get(TypeSpecificID) ~= nil then
      local CanEquipChipInfo = AvatarUtils.GetCanEquipChipInfo(TypeSpecificID)
      if UseEmptySlot then
        local EmptyIdx = LuaBackpackUtils.GetEmptyChipSlotIdx(ArrayElement, CanEquipChipInfo.SupportChipNum)
        if 0 < EmptyIdx then
          local BattleItemUseTarget = FBattleItemUseTarget()
          BattleItemUseTarget.Target          BattleItemUseTarget.TargetAssociationType = LuaBackpackUtils.GetChipAssociationType(EmptyIdx)
          BattleItemUseTarget.TargetActor = nil
          return true, BattleItemUseTarget
        end
      elseif ItemTableData.ItemType == ENUM_ITEM_TYPE.TKFProperty_10 and ItemTableData.ItemSubType == ENUM_ITEM_SUBTYPE.Armor_Piece_Item then
        local CanUseIdx = LuaBackpackUtils.GetCanUseChipSlotIdx(ArrayElement, CanEquipChipInfo.SupportChipNum, ItemTableData, BattleItem)
        if 0 < CanUseIdx then
          local BattleItemUseTarget = FBattleItemUseTarget()
          BattleItemUseTarget.Target          BattleItemUseTarget.TargetAssociationType = LuaBackpackUtils.GetChipAssociationType(CanUseIdx)
          BattleItemUseTarget.TargetActor = nil
          return true, BattleItemUseTarget
        end
      else
        local BattleItemUseTarget_1 = FBattleItemUseTarget()
        BattleItemUseTarget_1.Target        BattleItemUseTarget_1.TargetAssociationType = EItemAssociationType.ChipSlot1
        BattleItemUseTarget_1.TargetActor = nil
        return true, BattleItemUseTarget_1
      end
    end
  end
  local BattleItemUseTarget_2 = FBattleItemUseTarget()
  if DefineID == nil then
    BattleItemUseTarget_2.TargetDefineID.Type = 0
    BattleItemUseTarget_2.TargetDefineID.TypeSpecificID = 0
  else
    BattleItemUseTarget_2.Target  end
  BattleItemUseTarget_2.TargetAssociationType = EItemAssociationType.None
  BattleItemUseTarget_2.TargetActor = nil
  return false, BattleItemUseTarget_2
end
function LuaBackpackUtils.GetChipAssociationType(index)
  if index == 1 then
    return EItemAssociationType.ChipSlot1
  elseif index == 2 then
    return EItemAssociationType.ChipSlot2
  elseif index == 3 then
    return EItemAssociationType.ChipSlot3
  end
end
function LuaBackpackUtils.GetEquipChipNum(ItemData)
  local ChipNum = 0
  ChipNum = 0
  for ArrayIndex, ArrayElement in pairs(ItemData.Associations) do
    if ArrayElement.AssociationType == EItemAssociationType.ChipSlot1 or ArrayElement.AssociationType == EItemAssociationType.ChipSlot2 or ArrayElement.AssociationType == EItemAssociationType.ChipSlot3 then
      ChipNum = ChipNum + 1
    end
  end
  return ChipNum
end
function LuaBackpackUtils.IsUAV(ItemID)
  return ItemID == 604006
end
function LuaBackpackUtils.IsElectromagneticBack(ItemID)
  return ItemID == 501201
end
return LuaBackpackUtils