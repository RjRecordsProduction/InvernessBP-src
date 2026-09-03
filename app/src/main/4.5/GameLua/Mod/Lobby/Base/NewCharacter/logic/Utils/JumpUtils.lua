local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.ConstUtils")
local jump_utils = require("client.logic.store.jump_utils")
function CharacterUtils:GetJumpType(CharacterID, ItemID)
  local isDefault = self:IsCharacterDefaultItem(CharacterID, ItemID)
  if isDefault then
    return self.Enum_Jump_Type.EnumJump_Default, nil
  end
  local levelCfg = self:GetItemUnLockLevel(CharacterID, ItemID)
  if levelCfg then
    return self.Enum_Jump_Type.EnumJump_Level, levelCfg
  end
  local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
  if supply_optional_data:CheckCharacterSystemCanExchange(ItemID) then
    return self.Enum_Jump_Type.EnumJump_Exchange, nil
  end
  local jumpInfo = jump_utils.FindJumpInfoAllByToModelId(ItemID, jump_utils.MODEL_ID_SUPPLY)
  if jumpInfo and jumpInfo.jump_url and jumpInfo.jump_utils ~= "" then
    return self.Enum_Jump_Type.EnumJump_Supply, jumpInfo
  end
  local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
  local goodsCfg = CommonItemBuySystem.GetBuyCfgByItemID(ItemID)
  if goodsCfg ~= nil then
    return self.Enum_Jump_Type.EnumJump_ItemBuy, goodsCfg
  end
  return self.Enum_Jump_Type.EnumJump_None, nil
end
function CharacterUtils:GetJumpTypeName(CharacterID, ItemID)
  local jumpType, jumpCfg = self:GetJumpType(CharacterID, ItemID)
  local strText = ""
  if jumpType == self.Enum_Jump_Type.EnumJump_Default then
    strText = LocUtil.LocalizeResFormat("7781")
  elseif jumpType == self.Enum_Jump_Type.EnumJump_Level then
    local unLockLvl = 1
    if jumpCfg ~= nil then
      unLockLvl = jumpCfg.level
    end
    strText = LocUtil.LocalizeResFormat("7573", unLockLvl)
  elseif jumpType == self.Enum_Jump_Type.EnumJump_ItemBuy then
  elseif jumpType == self.Enum_Jump_Type.EnumJump_None then
    strText = LocUtil.LocalizeResFormat("6430")
  elseif jumpType == self.Enum_Jump_Type.EnumJump_Exchange then
    strText = LocUtil.LocalizeResFormat(6811)
  elseif jumpType == self.Enum_Jump_Type.EnumJump_Supply then
    strText = LocUtil.LocalizeResFormat(6473)
  end
  return strText
end
function CharacterUtils:JumpToModelFromCharacter(CharacterID, ItemID)
  local jumpType = self:GetJumpType(CharacterID, ItemID)
  if jumpType == self.Enum_Jump_Type.EnumJump_ItemBuy then
    local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
    CommonItemBuySystem.ShowBuyItemUI(ItemID)
  elseif jumpType == self.Enum_Jump_Type.EnumJump_None then
    ShowNotice(6430)
  elseif jumpType == self.Enum_Jump_Type.EnumJump_Supply then
    local jumpInfo = jump_utils.FindJumpInfoAllByToModelId(ItemID, jump_utils.MODEL_ID_SUPPLY)
    GlobalData.JumpUrl(jumpInfo.jump_url)
  elseif jumpType == self.Enum_Jump_Type.EnumJump_Exchange then
    GlobalData.JumpUrl(string.format("game://?module=%d&itemId=%d&characterId=%d", BP_ENUM_MODULE_CHARACTER_EXCHANGE, ItemID, CharacterID))
  end
end