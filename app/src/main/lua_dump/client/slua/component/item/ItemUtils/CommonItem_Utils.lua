local CommonItem_Utils = {}
local _GoldenQuality = 10
local _OldGoldenQuality = 8
local _tShowSmallIconCfg = {
  [ENUM_ITEM_TYPE.Currency] = 0,
  [ENUM_ITEM_TYPE.CYCLE_Memory_Item] = {
    [ENUM_ITEM_SUBTYPE.ExchangeCoin] = true,
    [ENUM_ITEM_SUBTYPE.SpecialCoin] = true
  }
}
function CommonItem_Utils.GetQuality(nItemId, tExtraData)
  tExtraData = tExtraData or {}
  if tExtraData.affixs and next(tExtraData.affixs) or tExtraData.haveAffix then
    return _GoldenQuality
  end
  local uObj_itemCfg
  if tExtraData.displayResId and tExtraData.displayResId ~= 0 then
    uObj_itemCfg = CDataTable.GetTableData("Item", tExtraData.displayResId)
  else
    uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  end
  if not uObj_itemCfg then
    return 0
  end
  if tExtraData.is_chest and uObj_itemCfg.ItemQuality == _OldGoldenQuality then
    return _GoldenQuality
  end
  local logic_xmission_heirloom_equip = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_heirloom_equip)
  if logic_xmission_heirloom_equip:CheckIsHeirloomEuqip(nItemId) and uObj_itemCfg.ItemQuality == _OldGoldenQuality then
    return _GoldenQuality
  end
  return uObj_itemCfg.ItemQuality
end
function CommonItem_Utils.GetIconPath(nItemId, uObj_itemCfg, uObj_iconWidget, bIsShowBigIcon, bIsShowBigIcon2)
  uObj_itemCfg = uObj_itemCfg or CDataTable.GetTableData("Item", nItemId)
  local UIUtil = require("client.common.ui_util")
  local nItemType = uObj_itemCfg and uObj_itemCfg.ItemType or 0
  local nItemSubType = uObj_itemCfg and uObj_itemCfg.ItemSubType or 0
  local tIconShow = _tShowSmallIconCfg[nItemType]
  if tIconShow == 0 then
    return UIUtil.GetItemSmallIcon(nItemId, uObj_iconWidget)
  elseif type(tIconShow) == "table" and tIconShow[nItemSubType] then
    if not Client.IsJaguar() then
      return UIUtil.GetItemSmallIcon(nItemId, uObj_iconWidget)
    end
  elseif bIsShowBigIcon2 then
    return UIUtil.GetItemBigIcon2(nItemId, uObj_iconWidget)
  elseif bIsShowBigIcon then
    return UIUtil.GetItemBigIcon(nItemId, uObj_iconWidget)
  end
  local bHasAddKnownMissing = false
  local sIconPath = ""
  local sItemSmallIcon2 = uObj_itemCfg and uObj_itemCfg.ItemSmallIcon2 or ""
  if sItemSmallIcon2 ~= "" then
    sIconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon2(nItemId, uObj_iconWidget)
  else
    sIconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(nItemId, uObj_iconWidget)
  end
  return sIconPath, bHasAddKnownMissing
end
function CommonItem_Utils.CheckIsValidTimeItem(nItemId, nValidTime)
  if not nItemId then
    return false
  end
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if not uObj_itemCfg then
    return false
  end
  nValidTime = nValidTime or 0
  local bIsNotValidTime = nValidTime <= 0
  local bIsNotExTime = not uObj_itemCfg.ExTime or uObj_itemCfg.ExTime == ""
  local bIsNotValidTimesCfg = not uObj_itemCfg.ValidTimes or uObj_itemCfg.ValidTimes == 0
  if bIsNotValidTime then
    if CommonItem_Utils.SpecialCheckIsValidTimeItem(nItemId) then
      return true
    elseif bIsNotExTime and bIsNotValidTimesCfg then
      return false
    end
  end
  return true
end
function CommonItem_Utils.SpecialCheckIsValidTimeItem(nItemId)
  nItemId = tonumber(nItemId)
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if uObj_itemCfg and uObj_itemCfg.ItemType == ENUM_ITEM_TYPE.AssemblyCoin and uObj_itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.AssemblyCoin then
    local logic_assembly_activity_utils = require("client.slua.logic.come_back.logic_assembly_activity_utils")
    local valid_hours = logic_assembly_activity_utils.GetCoinExpireHour()
    return 0 < valid_hours, valid_hours
  end
  return false
end
return CommonItem_Utils