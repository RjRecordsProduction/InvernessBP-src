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
local _fReportConfigError = function(sErrorMsg)
  log(bWriteLog and string.format("[ERROR]CommonItem_Utils _fReportConfigError : %s", sErrorMsg))
  if Client and Client.IsDevelopment() then
    local utility = require("common.utility")
    utility.ErrorMessageHandlerExtra(sErrorMsg, nil, sErrorMsg)
    log(bWriteLog and "[ERROR]CommonItem_Utils: Reporting module unavailable, error message logged")
  end
end
local _tAllZOrderCache = {}
local _tAllReportedKeys = {}
local _tChildNameRegistry = {}
local _tDupReported = {}
local _fCheckDuplicateChildName = function(sTableName, tCache)
  if not Client or not Client.IsDevelopment() then
    return
  end
  for sChildName, _ in pairs(tCache) do
    local sExistTableName = _tChildNameRegistry[sChildName]
    if sExistTableName == nil then
      _tChildNameRegistry[sChildName] = sTableName
    elseif sExistTableName ~= sTableName and not _tDupReported[sChildName] then
      local sErrorMsg = string.format("Duplicate ChildName [%s] found in ZOrder tables [%s] and [%s], please rename to ensure uniqueness", tostring(sChildName), sExistTableName, sTableName)
      _fReportConfigError(sErrorMsg)
      _tDupReported[sChildName] = true
    end
  end
end
local _fLoadZOrderCache = function(sTableName, tDefaultValues)
  if _tAllZOrderCache[sTableName] ~= nil then
    return _tAllZOrderCache[sTableName]
  end
  local tCache = {}
  local uAllCfg = CDataTable.GetTable(sTableName)
  if not uAllCfg then
    local sErrorMsg = string.format("Config table %s not found, using default values", sTableName)
    _fReportConfigError(sErrorMsg)
    if tDefaultValues then
      for k, v in pairs(tDefaultValues) do
        tCache[k] = v
      end
    end
    _tAllZOrderCache[sTableName] = tCache
    _fCheckDuplicateChildName(sTableName, tCache)
    return tCache
  end
  for sChildName, uRow in pairs(uAllCfg) do
    if uRow.ZOrder ~= nil then
      tCache[sChildName] = uRow.ZOrder
    else
      local sErrorMsg = string.format("Config table %s row %s missing ZOrder field, using default value 0", sTableName, tostring(sChildName))
      _fReportConfigError(sErrorMsg)
      tCache[sChildName] = 0
    end
  end
  if tDefaultValues then
    for k, v in pairs(tDefaultValues) do
      if tCache[k] == nil then
        tCache[k] = v
      end
    end
  end
  _tAllZOrderCache[sTableName] = tCache
  _fCheckDuplicateChildName(sTableName, tCache)
  return tCache
end
function CommonItem_Utils.CreateZOrderEnum(sTableName, tDefaultValues)
  _tAllReportedKeys[sTableName] = _tAllReportedKeys[sTableName] or {}
  return setmetatable({}, {
    __index = function(_, aKey)
      local tCache = _fLoadZOrderCache(sTableName, tDefaultValues)
      local nZOrderValue = tCache[aKey]
      if nZOrderValue == nil then
        local tReported = _tAllReportedKeys[sTableName]
        if not tReported[aKey] then
          local sErrorMsg = string.format("ZOrder key %s not found in %s, using default value 0", tostring(aKey), sTableName)
          _fReportConfigError(sErrorMsg)
          tReported[aKey] = true
        end
        return 0
      end
      return nZOrderValue
    end,
    __newindex = function(_, _, _)
      log_error(bWriteLog and string.format("CommonItem_Utils:CreateZOrderEnum: [ERROR] ZOrder enum %s is read-only and cannot be modified", sTableName))
    end
  })
end
return CommonItem_Utils