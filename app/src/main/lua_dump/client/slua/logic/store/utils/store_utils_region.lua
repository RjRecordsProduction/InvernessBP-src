local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.GetJapanOrKoreaData(isJPCustomSpecially, limitRegion)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  local banData = {}
  local tableName = ""
  local curRegion = ""
  local isLimit = false
  if isJPCustomSpecially then
    tableName = StoreConst.custom_crate_ban_table_kr_names.custom_chest_quality_times_jpkr
    curRegion = AccountRegionForBPMacros.JP
  elseif FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
    tableName = StoreConst.custom_crate_ban_table_kr_names.custom_chest_quality_times_jp
    curRegion = AccountRegionForBPMacros.JP
  else
    tableName = StoreConst.custom_crate_ban_table_kr_names.custom_chest_quality_times_kr
    curRegion = AccountRegionForBPMacros.KR
  end
  if not limitRegion or not next(limitRegion) then
    banData = BasicDataServerTable:GetCacheData(tableName) or {}
    isLimit = true
  else
    for reg, _ in pairs(limitRegion) do
      if reg == curRegion then
        banData = BasicDataServerTable:GetCacheData(tableName) or {}
        isLimit = true
        break
      end
    end
  end
  if not isLimit then
    log(bWriteLog and "[StoreOtherUtils][GetJapanOrKoreaData] The area is outside the configured restricted area.")
  end
  return banData
end