local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.CheckIsJPCustomSpecially(crateId)
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if not GlobalData.IsJapanOrKorea() or FuncUtil.GetAccountRegionForBP() ~= AccountRegionForBPMacros.JP then
    return false
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local tableName = StoreConst.custom_crate_ban_table_kr_names.custom_chest_quality_times_jpkr
  local banData = BasicDataServerTable:GetCacheData(tableName) or {}
  for i, _ in pairs(banData) do
    if i == crateId then
      return true
    end
  end
  return false
end
function StoreUtils.CanCustomBanByConfig(crateId, limitRegion)
  local banInfo
  local banData = {}
  local isJPCustomSpecially = StoreUtils.CheckIsJPCustomSpecially(crateId)
  banData = StoreUtils.GetJapanOrKoreaData(isJPCustomSpecially, limitRegion)
  if not banData or type(banData) ~= "table" then
    return
  end
  if next(banData) then
    for i, v in pairs(banData) do
      if i == crateId then
        banInfo = v
      end
    end
  end
  if banInfo ~= nil then
    if isJPCustomSpecially then
      return banInfo
    else
      local TimeUtil = require("client.common.time_util")
      local currentTime = TimeUtil.GetServerTimeInSec()
      local startTime = banInfo.begin_time_ts
      local endTime = banInfo.end_time_ts
      if currentTime >= startTime and currentTime < endTime then
        return banInfo
      else
        return nil
      end
    end
  end
  return nil
end
function StoreUtils.GetBanInfo(table_name, crateId)
  local banInfo
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local banData = BasicDataServerTable:GetCacheData(table_name)
  if banData and next(banData) then
    for i, v in pairs(banData) do
      if i == crateId then
        banInfo = v
      end
    end
  end
  return banInfo
end
function StoreUtils.GetBanPayType(crateId)
  local type = StoreConst.custom_crate_ban_pay_type.pay_uc
  local isJPCustomSpecially = StoreUtils.CheckIsJPCustomSpecially(crateId)
  if isJPCustomSpecially then
    type = StoreConst.custom_crate_ban_pay_type.pay_integral
  end
  return type
end
function StoreUtils.HaveShowedTipsWhenCanFreeBan(crateId)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showTipsRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eShowedTipsWhenCanFreeBan)
  local haveShowed = false
  if showTipsRecord ~= nil then
    haveShowed = showTipsRecord[tostring(crateId)]
  end
  return haveShowed
end
function StoreUtils.SaveShowedTipsWhenCanFreeBan(crateId)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showTipsRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eShowedTipsWhenCanFreeBan)
  local key = tostring(crateId)
  if showTipsRecord == nil then
    showTipsRecord = {}
    showTipsRecord[key] = true
  else
    showTipsRecord[key] = true
  end
  playerPrefsSystem.SaveTableToFile_N(showTipsRecord, playerPrefsSystem.ePlayerPrefsType.eShowedTipsWhenCanFreeBan)
  return
end