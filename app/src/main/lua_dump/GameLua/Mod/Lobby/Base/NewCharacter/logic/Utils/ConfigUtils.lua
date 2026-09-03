local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.ConstUtils")
local StringUtil = require("common.string_util")
function CharacterUtils:GetCharacterIDByItemID(ItemID)
  local itemcfg = CDataTable.GetTableData("Item", ItemID)
  if not itemcfg or itemcfg.ItemType <= 0 or 0 >= itemcfg.ItemSubType then
    return 0
  end
  if itemcfg.ItemType == self.Enum_Item_Type.EnumType_Character then
    return ItemID
  end
  local paramCfg = CDataTable.GetTableData("character_param_table", ItemID)
  if not paramCfg or 0 >= paramCfg.character_param then
    return 0
  end
  return paramCfg.character_param
end
function CharacterUtils:IsCharacterSuit(ItemID)
  local itemcfg = CDataTable.GetTableData("Item", ItemID)
  local itemCfgChar = CDataTable.GetTableData("character_param_table", ItemID)
  if not itemcfg or not itemCfgChar then
    return false
  end
  if itemcfg.ItemType == self.Enum_Item_Type.EnumType_Skin and itemcfg.ItemSubType == self.Enum_Item_SubType.EnumType_Clothes and itemCfgChar.character_param > 0 then
    return true
  end
  return false
end
function CharacterUtils:IsSkin(ItemID)
  local itemcfg = CDataTable.GetTableData("Item", ItemID)
  return itemcfg and itemcfg.ItemType == self.Enum_Item_Type.EnumType_Skin
end
function CharacterUtils:IsVoice(ItemID)
  local itemcfg = CDataTable.GetTableData("Item", ItemID)
  return itemcfg and itemcfg.ItemType == self.Enum_Item_Type.EnumType_Sound
end
function CharacterUtils:CheckIsCharacterId(ItemID)
  local itemcfg = CDataTable.GetTableData("Item", ItemID)
  if not itemcfg then
    return false
  end
  return itemcfg.ItemType == self.Enum_Item_Type.EnumType_Character
end
function CharacterUtils:GetDefaultItemListByCharacterId(CharacterID)
  local arrList = {}
  if not CharacterID or CharacterID <= 0 then
    return arrList
  end
  local cfg = CDataTable.GetTableData("character_table", CharacterID)
  if not cfg then
    return arrList
  end
  local TempList = {}
  if cfg.default_suit and cfg.default_suit ~= "" then
    TempList = StringUtil.Split(cfg.default_suit, "|")
    for _, v in pairs(TempList) do
      if v ~= "" and 0 < tonumber(v) then
        table.insert(arrList, {
          res_id = tonumber(v),
          count = 1
        })
      end
    end
  end
  if cfg.default_com_action and cfg.default_com_action ~= "" then
    TempList = StringUtil.Split(cfg.default_com_action, "|")
    for _, v in pairs(TempList) do
      if v ~= "" and 0 < tonumber(v) then
        table.insert(arrList, {
          res_id = tonumber(v),
          count = 1
        })
      end
    end
  end
  if cfg.default_total_action and cfg.default_total_action ~= "" then
    TempList = StringUtil.Split(cfg.default_total_action, "|")
    for _, v in pairs(TempList) do
      if v ~= "" and 0 < tonumber(v) then
        table.insert(arrList, {
          res_id = tonumber(v),
          count = 1
        })
      end
    end
  end
  if cfg.default_sound and cfg.default_sound ~= "" then
    TempList = StringUtil.Split(cfg.default_sound, "|")
    for _, v in pairs(TempList) do
      if v ~= "" and 0 < tonumber(v) then
        table.insert(arrList, {
          res_id = tonumber(v),
          count = 1
        })
      end
    end
  end
  return arrList
end
function CharacterUtils:ConvertBoxExpToNum(CharacterID, CharacterExp)
  local BoxNeedExp = self.CHARACTER_EXP_CARD_VALUE
  local boxCfg = CDataTable.GetTableData("character_box", CharacterID)
  if boxCfg and boxCfg.need_box_exp then
    BoxNeedExp = boxCfg.need_box_exp
  end
  local box_num = 0
  if CharacterExp and BoxNeedExp and 0 < CharacterExp then
    box_num = math.floor(CharacterExp / BoxNeedExp)
  end
  return box_num
end
function CharacterUtils:GetBoxByID(BoxID)
  local CharBoxCfg = CDataTable.GetTableByFilter("character_box", "box_id", BoxID)
  if CharBoxCfg then
    for i, v in pairs(CharBoxCfg) do
      if v.box_id == BoxID then
        return v
      end
    end
  end
  return nil
end
function CharacterUtils:GetItemByID(list, res_id)
  if list and next(list) then
    for i, v in pairs(list) do
      if v.res_id and tonumber(v.res_id) == tonumber(res_id) then
        return v
      end
    end
    return list[1]
  end
  return nil
end
function CharacterUtils:GetDefaultSuitItemID(CharacterID)
  if not CharacterID or CharacterID <= 0 then
    return nil
  end
  local cfg = CDataTable.GetTableData("character_table", CharacterID)
  if not cfg then
    return nil
  end
  if cfg.default_suit and cfg.default_suit ~= "" then
    local TempList = StringUtil.Split(cfg.default_suit, "|")
    local retArr = {}
    for _, v in pairs(TempList) do
      table.insert(retArr, tonumber(v))
    end
    return retArr
  end
  return nil
end
function CharacterUtils:IsCharacterBoxDisabled(CharacterID)
  local cfg = CDataTable.GetTableData("character_table", CharacterID)
  return cfg and cfg.disable_box or false
end
function CharacterUtils:GetCharacterLevelListByID(CharacterID)
  local levelList = {}
  local CharLevelCfg = CDataTable.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID)
  if CharLevelCfg then
    for _, v in pairs(CharLevelCfg) do
      if v.character_id == CharacterID then
        table.insert(levelList, v)
      end
    end
  end
  return levelList
end
function CharacterUtils:GetCharacterMaxLevel(CharacterID)
  local levelList = self:GetCharacterLevelListByID(CharacterID)
  if levelList == nil then
    return 0
  end
  return #levelList
end
function CharacterUtils:JudgeIsCoundUnLock(itemConfig)
  if not itemConfig or not itemConfig.item_id then
    return false
  end
  local CharacterID = self:GetCharacterIDByItemID(itemConfig.item_id)
  if not CharacterID or CharacterID <= 0 then
    ShowNotice(7032)
    return false
  end
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  if not NewCharacterNetSystem:IsUnLockedCharacter(CharacterID) then
    ShowNotice(7017)
    return false
  end
  local owned_itemidnum1 = 0
  local owned_itemidnum2 = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local materialItem
  if itemConfig.item_id1 then
    materialItem = wardrobe_data:GetHallDepotItemDataByResID(itemConfig.item_id1)
    if materialItem ~= nil then
      owned_itemidnum1 = materialItem.count or 0
    end
  end
  if itemConfig.item_id2 then
    materialItem = wardrobe_data:GetHallDepotItemDataByResID(itemConfig.item_id2)
    if materialItem ~= nil then
      owned_itemidnum2 = materialItem.count or 0
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
  if 0 < itemConfig.item_num1 and owned_itemidnum1 >= itemConfig.item_num1 then
    if itemConfig.item_id2 and 0 < itemConfig.item_id2 then
    else
      return true
    end
  else
    if PublishRegionMacros.IsJapanOrKorea() then
      ShowNotice(997002)
    else
      CommonItemBuySystem.ShowBuyItemUI(itemConfig.item_id1, itemConfig.item_num1 - owned_itemidnum1)
    end
    return false
  end
  if 0 < itemConfig.item_num2 and owned_itemidnum2 >= itemConfig.item_num2 then
    return true
  else
    if PublishRegionMacros.IsJapanOrKorea() then
      ShowNotice(997002)
    else
      CommonItemBuySystem.ShowBuyItemUI(itemConfig.item_id2, itemConfig.item_num2 - owned_itemidnum2)
    end
    return false
  end
end
function CharacterUtils:GetCharacterVoiceBagItem(CharacterID)
  local cfg = CDataTable.GetTableData("character_table", CharacterID)
  if cfg and cfg.voice_bag_id then
    local item_cfg = CDataTable.GetTableData("Item", cfg.voice_bag_id)
    return item_cfg
  end
  return nil
end
function CharacterUtils:GetCharacterLevelCfgByID(CharacterID, CharacterLevel)
  return CDataTable.GetSplitTableDataByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID, "level", CharacterLevel)
end
function CharacterUtils:IsCharacterDefaultItem(CharacterID, ItemID)
  if not (CharacterID and not (CharacterID <= 0) and ItemID) or ItemID <= 0 then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return false
  end
  local CharCfg = CDataTable.GetTableData("character_table", CharacterID)
  if not CharCfg then
    return false
  end
  local TempList = {}
  if itemCfg.ItemType == self.Enum_Item_Type.EnumType_Skin then
    if CharCfg.default_suit and CharCfg.default_suit ~= "" then
      TempList = StringUtil.Split(CharCfg.default_suit, "|")
      for _, v in pairs(TempList) do
        if v ~= "" and tonumber(v) == ItemID then
          return true
        end
      end
    end
  elseif itemCfg.ItemType == self.Enum_Item_Type.EnumType_Sound then
    if CharCfg.default_sound and CharCfg.default_sound ~= "" then
      TempList = StringUtil.Split(CharCfg.default_sound, "|")
      for _, v in pairs(TempList) do
        if v ~= "" and tonumber(v) == ItemID then
          return true
        end
      end
    end
  elseif itemCfg.ItemType == self.Enum_Item_Type.EnumType_Com_Action then
    if CharCfg.default_com_action and CharCfg.default_com_action ~= "" then
      TempList = StringUtil.Split(CharCfg.default_com_action, "|")
      for _, v in pairs(TempList) do
        if v ~= "" and tonumber(v) == ItemID then
          return true
        end
      end
    end
  elseif itemCfg.ItemType == self.Enum_Item_Type.EnumType_Total_Action and CharCfg.default_total_action and CharCfg.default_total_action ~= "" then
    TempList = StringUtil.Split(CharCfg.default_total_action, "|")
    for _, v in pairs(TempList) do
      if v ~= "" and tonumber(v) == ItemID then
        return true
      end
    end
  end
  return false
end
function CharacterUtils:GetItemUnLockLevel(CharacterID, ItemID)
  if not (CharacterID and not (CharacterID <= 0) and ItemID) or ItemID <= 0 then
    return nil
  end
  local CharLevelCfg = CDataTable.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID)
  if not CharLevelCfg then
    return nil
  end
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return nil
  end
  local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
  for _, v in pairs(CharLevelCfg) do
    if v.unlock_id1 and 0 < v.unlock_id1 then
      if itemCfg.ItemType == self.Enum_Item_Type.EnumType_Sound then
        local unLockCfg = CDataTable.GetTableData("Item", v.unlock_id1)
        if unLockCfg and unLockCfg.ItemType == self.Enum_Item_Type.EnumType_Box then
          local dataList = BasicDataChestTable:GetOrReqData(v.unlock_id1)
          if dataList and next(dataList) then
            for _, u in pairs(dataList) do
              if u.DropItemID == ItemID then
                return v
              end
            end
          end
        end
      end
      if v.unlock_id1 == ItemID then
        return v
      end
    end
  end
  return nil
end