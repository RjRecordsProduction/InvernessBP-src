local supply_collect_chest_manager = {}
function supply_collect_chest_manager:DefineAndResetData()
  self.crate_collected_list = {}
  self.preShowTipTime = 0
  self.bReqCollectChestData = false
end
function supply_collect_chest_manager:OnLogOut()
  self.crate_collected_list = {}
  self.preShowTipTime = 0
  self.bReqCollectChestData = false
end
function supply_collect_chest_manager:send_get_all_collect_chest_data_req()
  if not LobbySystem.CheckOpen(BP_ENUM_CRATE_COLLECT_SWITCH) then
    return
  end
  if self.bReqCollectChestData then
    return
  end
  self.bReqCollectChestData = true
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_all_collect_chest_data_req()
end
function supply_collect_chest_manager:get_all_collect_chest_data_rsp(crate_collected_list)
  log_tree("[chub]log_StoreSystem.get_all_collect_chest_data_rsp, crate_collected_list = ", crate_collected_list)
  self.crate_collected_list = {}
  for itemId, v in pairs(crate_collected_list) do
    local info = {}
    info.nItemId = itemId
    info.nState = StoreConst.crate_collect_state_true
    self.crate_collected_list[v.shop_id] = info
  end
end
function supply_collect_chest_manager:chest_collect_rsp(error_code, nShopId, nNowState)
  log(bWriteLog and "[chub]log_StoreSystem.chest_collect_rsp, error_code = " .. tostring(error_code) .. " nShopId = " .. tostring(nShopId) .. " nNowState = " .. tostring(nNowState))
  if error_code == 0 then
    local crateCollectedList = self.crate_collected_list
    if crateCollectedList[nShopId] then
      crateCollectedList[nShopId].nState = nNowState
    else
      crateCollectedList[nShopId] = {nState = nNowState}
    end
    ShowNotice(LocUtil.LocalizeResFormat(nNowState == StoreConst.crate_collect_state_true and 24196 or 24197))
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_COLLECT_STATE_CHANGE, {nShopId = nShopId, nNowState = nNowState})
  elseif error_code == StoreConst.err_market_collect_limit_by_max_count then
    ShowNotice(LocUtil.GetLocalizeResStr(24235))
  else
    ShowNotice(error_code)
  end
end
function supply_collect_chest_manager:get_chest_bubble_notify_rsp(need_notify_crate_list)
  log_tree("log_StoreSystem:get_chest_bubble_notify_rsp need_notify_crate_list = ", need_notify_crate_list)
  if need_notify_crate_list and next(need_notify_crate_list) then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble) or {}
    for itemId, shopId in pairs(need_notify_crate_list) do
      table.insert(saveData, shopId)
    end
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble)
    log(bWriteLog and "[chub]log_get_chest_bubble_notify_rsp:EVENTID_CRATE_COLLECT_NOTIFY")
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_COLLECT_NOTIFY)
  end
end
function supply_collect_chest_manager:GetCrateCollectedState(shopId)
  if not self.crate_collected_list then
    return StoreConst.crate_collect_state_false
  end
  local collectInfo = self.crate_collected_list[shopId]
  return collectInfo and collectInfo.nState or StoreConst.crate_collect_state_false
end
function supply_collect_chest_manager:IsNewArrivalsCollect()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eIsArrivalCollect) or {}
  log(bWriteLog and "[chub]log_IsNewArrivalsCollect, bIsArrivalCollect = " .. tostring(saveData.bIsArrivalCollect))
  return saveData.bIsArrivalCollect == nil
end
function supply_collect_chest_manager:RecordNewArrivalsCollect()
  local saveData = {bIsArrivalCollect = true}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eIsArrivalCollect)
end
function supply_collect_chest_manager:CleanOutTimeTip(shopIdList)
  log_tree("[chub]log_CleanOutTimeTip, shopIdList = ", shopIdList)
  if not shopIdList or not next(shopIdList) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bubbleData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble) or {}
  for _, shopId in ipairs(shopIdList) do
    for index, _shopId in ipairs(bubbleData) do
      if _shopId == shopId then
        table.remove(bubbleData, index)
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(bubbleData, PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble)
end
function supply_collect_chest_manager:RemoveCollectBubble(shopId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bubbleData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble) or {}
  for index, _shopId in ipairs(bubbleData) do
    if _shopId == shopId then
      table.remove(bubbleData, index)
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(bubbleData, PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble)
end
function supply_collect_chest_manager:GetPreShowTipTime()
  return self.preShowTipTime or 0
end
function supply_collect_chest_manager:SetShowTipTime(serverTime)
  self.preShowTipTime = serverTime
end
function supply_collect_chest_manager:GetShopTabInfoByShopId(shopId)
  if not shopId then
    return nil
  end
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local list = store_supply_manager:GetOptimizeSupplyInfo()
  for id, values in pairs(list) do
    if shopId == id then
      return values
    end
  end
  return nil
end
function supply_collect_chest_manager:GetOneBubbleShopInfo()
  if not StoreConst.supply_data or not StoreConst.supply_data.supply_list then
    log(bWriteLog and "[chub]log_GetOneBubbleShopInfo:StoreConst.supply_data = nil")
    return nil
  end
  local outTimeShopIdList = {}
  local TimeUtil = require("client.common.time_util")
  local nServerTime = TimeUtil.GetServerTimeInSec()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bubbleData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectCrateBubble) or {}
  log(bWriteLog and "[chub]log_GetOneBubbleShopInfo, openId = " .. tostring(DataMgr.roleData.openID))
  log_tree("[chub]log_StoreSystem.GetOneBubbleShopInfo, eCollectCrateBubble = ", bubbleData)
  for _, shopId in ipairs(bubbleData) do
    local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
    local shopInfo = supply_collect_chest_manager:GetShopTabInfoByShopId(shopId)
    local nEndTime = shopInfo and shopInfo.end_time or 0
    if shopInfo and nServerTime < nEndTime then
      local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
      supply_collect_chest_manager:CleanOutTimeTip(outTimeShopIdList)
      return shopInfo
    end
    table.insert(outTimeShopIdList, shopId)
  end
  local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
  supply_collect_chest_manager:CleanOutTimeTip(outTimeShopIdList)
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, supply_collect_chest_manager)
return CModuleTemplate