local supply_ban_manager = {}
function supply_ban_manager:DefineAndResetData()
  self:ClearBanData()
end
function supply_ban_manager:ClearBanData()
  self.SupplyBanInfo = {}
  self.SupplyBanFree = {}
  self.SupplyBanProbability = {}
  self.SupplyBanDataRequestStatus = false
  if self.banEndTime and next(self.banEndTime) then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    for k, v in pairs(self.banEndTime) do
      if serverTime <= v.endTime then
        self:RequestCustomCrateInfo(k)
        v.clearAndResetData = true
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CLEAR_BAN_DATA)
end
function supply_ban_manager:OnLogin(bReLogin)
end
function supply_ban_manager:OnLogOut()
  self.SupplyBanInfo = nil
  self.SupplyBanFree = nil
  self.SupplyBanProbability = nil
  self.SupplyBanDataRequestStatus = nil
end
function supply_ban_manager:GetServerCfgNameList()
  local tAllReqName = StoreConst.custom_crate_ban_table_glo_names
  if GlobalData.IsJapanOrKorea() then
    tAllReqName = StoreConst.custom_crate_ban_table_kr_names
  end
  return tAllReqName
end
function supply_ban_manager:GetAllServerCfgIsExist()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local tAllReqName = self:GetServerCfgNameList()
  for _, sName in pairs(tAllReqName) do
    local tCfgData = BasicDataServerTable:GetCacheData(sName)
    if not tCfgData then
      return false
    end
  end
  return true
end
function supply_ban_manager:RequestServerTableConfig(fCallback)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local tAllTableName = {}
  local tAllReqName = self:GetServerCfgNameList()
  for _, sName in pairs(tAllReqName) do
    table.insert(tAllTableName, sName)
  end
  BasicDataServerTable:BatchGetOrReqData(tAllTableName, fCallback)
end
function supply_ban_manager:GetOldBanItems(crateId)
  return self.SupplyBanInfo[crateId]
end
function supply_ban_manager:RequestCustomCrateInfo(crateId)
  log(bWriteLog and string.format("supply_ban_manager:RequestCustomCrateInfo crateId = %s", crateId))
  if self.SupplyBanInfo[crateId] ~= nil then
    log(bWriteLog and "have data and return immediately.")
    local param = {}
    param.    param.data = {
      usedFree = self.SupplyBanFree[crateId] or false,
      banItems = self.SupplyBanInfo[crateId] or {},
      probability = self.SupplyBanProbability[crateId] or {}
    }
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_BAN_DATA, param)
  else
    local CustomCrateHandler = require("client.network.Protocol.CustomCrateHandler")
    CustomCrateHandler.send_custom_chest_get_data_req(crateId)
  end
end
function supply_ban_manager:RespondCustomCrateInfo(crateId, banItems, haveUsedFree, probability)
  log(bWriteLog and string.format("RespondCustomCrateInfo, crateId = %s, haveUsedFree = %s", crateId, haveUsedFree))
  log_tree("banItems = ", banItems)
  log_tree("probability = ", probability)
  if crateId == nil then
    return
  end
  self.SupplyBanFree[crateId] = haveUsedFree
  self.SupplyBanInfo[crateId] = banItems
  self.SupplyBanProbability[crateId] = probability
  if self.banEndTime and self.banEndTime[crateId] and self.banEndTime[crateId].clearAndResetData then
    self.banEndTime[crateId].clearAndResetData = false
    return
  end
  local param = {}
  param.  param.data = {
    usedFree = haveUsedFree or false,
    banItems = banItems or {},
    probability = probability or {}
  }
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_BAN_DATA, param)
end
function supply_ban_manager:RequestCustomBanCrateItems(crateId, items, cost, pay_method)
  log(bWriteLog and string.format("supply_ban_manager:RequestCustomBanCrateItems crateId = %s, items = %s, cost = %s, pay_method = %s", crateId, items, cost, pay_method))
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local CustomCrateHandler = require("client.network.Protocol.CustomCrateHandler")
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
    if StoreUtils.CheckIsJPCustomSpecially(crateId) then
      log(bWriteLog and "[chub]CustomCrateHandler.send_custom_chest_jpkr_ban_item_req ")
      CustomCrateHandler.send_custom_chest_jpkr_ban_item_req(crateId, items)
    else
      log(bWriteLog and "[chub]CustomCrateHandler.send_custom_chest_jp_ban_item_req ")
      CustomCrateHandler.send_custom_chest_jp_ban_item_req(crateId, items, cost, pay_method)
    end
  else
    log(bWriteLog and "[chub]CustomCrateHandler.send_custom_chest_kr_ban_item_req ")
    CustomCrateHandler.send_custom_chest_kr_ban_item_req(crateId, items, cost, pay_method)
  end
end
function supply_ban_manager:RespondCustomBanCrateItems(crateId, items, cost, errCode)
  log(bWriteLog and string.format("supply_ban_manager:RespondCustomBanCrateItems crateId = %s, cost = %s, errCode = %s", crateId, cost, errCode))
  log_tree("supply_ban_manager:RespondCustomBanCrateItems, items = ", items)
  if errCode == 0 then
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    self.SupplyBanFree[crateId] = not StoreUtils.CheckIsJPCustomSpecially(crateId)
    self.SupplyBanInfo[crateId] = items
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_BAN_ITEMS, crateId)
  else
    if errCode == StoreConst.cc_cost_not_same and not self.SupplyBanDataRequestStatus then
      self.SupplyBanDataRequestStatus = true
      self:RequestServerTableConfig()
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(3, function()
        self.SupplyBanDataRequestStatus = false
      end)
    end
    ShowNotice(errCode)
  end
end
function supply_ban_manager:NotFreeToUseBanByCrateId(crateId)
  if self.SupplyBanFree[crateId] ~= nil then
    log(bWriteLog and string.format("NotFreeToUseBanByCrateId, crateId = %s, have used = %s", crateId, self.SupplyBanFree[crateId]))
    return self.SupplyBanFree[crateId]
  end
  log(bWriteLog and string.format("NotFreeToUseBanByCrateId, crateId = %s, have used = true", crateId))
  return true
end
function supply_ban_manager:FilterBanItem(itemList, boxItemId)
  if not self.SupplyBanInfo or not self.SupplyBanInfo[boxItemId] then
    return itemList or {}
  end
  local banData = self.SupplyBanInfo[boxItemId]
  local newTable = {}
  for i, v in ipairs(itemList) do
    if not banData[v.shopId] then
      table.insert(newTable, v)
    end
  end
  return newTable
end
function supply_ban_manager:ChckExItemBanState(reflectionId, extraId)
  if self.extraToBan and self.extraToBan[extraId] then
    for k, v in pairs(self.extraToBan[extraId]) do
      if k == reflectionId then
        return true
      end
    end
  end
  return false
end
function supply_ban_manager:AddExtraToBanList(extraId, banList)
  if not self.extraToBan then
    self.extraToBan = {}
  end
  self.extraToBan[extraId] = banList
end
function supply_ban_manager:AddBanEndTime(crateId, endTime)
  if not self.banEndTime then
    self.banEndTime = {}
  end
  self.banEndTime[crateId] = {endTime = endTime, clearAndResetData = false}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, supply_ban_manager)
return CModuleTemplate