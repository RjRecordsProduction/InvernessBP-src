local Logic_UGC_Season = {}
function Logic_UGC_Season:OpenStoreModule(bJump, SelectIndex)
  print(bWriteLog and "Logic_UGC_Season:OpenStoreModule")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySeason, 0, "seasonAward")
  local Tab = self:GetOpenTab()
  local ctorData = {}
  ctorData.tabId = Tab
  ctorData.bJump = bJump or false
  ctorData.jumpAwardIndex = SelectIndex
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_UGC_SEASON_STORE, ctorData)
end
function Logic_UGC_Season:ResetStoreItemList()
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:ResetStoreItemList")
  self.StoreItemList = nil
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_Season_Shop_UIBP) then
    self:ReqGetStoreItemList()
  end
end
function Logic_UGC_Season:OnNextDayZeroCome()
  self:ResetStoreItemList()
end
function Logic_UGC_Season:GetOpenTab()
  if self.UGCSegmentData.segment_id == self.SegmentMax and not self:IsShowRewardReddot() and self:CheckShopOpen() then
    return 2
  else
    return 1
  end
end
function Logic_UGC_Season:OnNextDayZeroCome()
  self:ResetStoreItemList()
end
function Logic_UGC_Season:CheckShopOpen()
  if LobbySystem.CheckOpen(BP_ENUM_UGC_SEASON_STORE) then
    return true
  else
    return false
  end
end
function Logic_UGC_Season:ResetStoreItemList()
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:ResetStoreItemList")
  self.StoreItemList = nil
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_Season_Shop_UIBP) then
    self:ReqGetStoreItemList()
  end
end
function Logic_UGC_Season:OpenStoreModule(bJump, SelectIndex)
  print(bWriteLog and "Logic_UGC_Season:OpenStoreModule")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySeason, 0, "seasonAward")
  local Tab = self:GetOpenTab()
  local ctorData = {}
  ctorData.tabId = Tab
  ctorData.bJump = bJump or false
  ctorData.jumpAwardIndex = SelectIndex
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_UGC_SEASON_STORE, ctorData)
end
function Logic_UGC_Season:CheckItemIsHas(subItem)
  if subItem.res_owned_check and subItem.res_owned_check == 1 then
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    local have = StoreUtils.IsPossessed(subItem.resid)
    if subItem.res_owned_count > 0 or have then
      return true
    end
  end
  return false
end
function Logic_UGC_Season:ReqGetStoreItemList()
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_season_get_exchange_list_req()
end
function Logic_UGC_Season:SeasonExchangeListRsp(exchange_shop_list)
  if exchange_shop_list == nil or not next(exchange_shop_list) then
    log(bWriteLog and "Logic_UGC_Season:SeasonExchangeListRsp exchange_shop_list is nil")
  end
  local version_util = require("client.common.version_util")
  local TimeUtil = require("client.common.time_util")
  self.StoreItemList = {}
  local version = Client.GetApplicationVersion()
  for key, value in pairs(exchange_shop_list) do
    local UGCSeasonStoreCfg = CDataTable.GetTableData("UGCSeasonStoreConfig", value.id)
    if not UGCSeasonStoreCfg then
      log(bWriteLog and "Logic_UGC_Season:SeasonExchangeListRsp UGCSeasonStoreCfg is nil, id = " .. value.id)
      break
    end
    if version_util.CompareVersionFull(version, UGCSeasonStoreCfg.BeginVer) >= 0 and TimeUtil.UnixTimeStrBetween(UGCSeasonStoreCfg.BeginTime, UGCSeasonStoreCfg.EndTime) == 0 then
      local item_cfg = CDataTable.GetTableData("Item", value.resid)
      if item_cfg then
        value.itemQuality = item_cfg.ItemQuality or 1
        value.ItemType = item_cfg.ItemType
        self.StoreItemList[key] = value
      else
        log(bWriteLog and "Logic_UGC_Season:SeasonExchangeListRsp item_cfg is invalid id = " .. value.resid)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_GET_SEASONSTORE_CONFIG)
end
function Logic_UGC_Season:GetUGCSeasonStoreData()
  if self.StoreItemList then
    return self.StoreItemList
  end
  self:ReqGetStoreItemList()
  return nil
end
function Logic_UGC_Season:TakeExchangeByIDReq(itemId, itemCount)
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_season_take_exchange_by_id_req(itemId, itemCount)
end
function Logic_UGC_Season:TakeExchangeByIDRsp(shop_id, shop_count, on_exchange_shop_list)
  self:UpdateStoreItemList(shop_id, on_exchange_shop_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(on_exchange_shop_list)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEASON_EXCHANGE_SUCCESS, shop_id)
end
function Logic_UGC_Season:UpdateStoreItemList(shop_id, on_exchange_shop_list)
  for key, value in pairs(self.StoreItemList) do
    if value.id == shop_id then
      value.buy_count = value.buy_count + on_exchange_shop_list[1].count
      value.valid_hours = on_exchange_shop_list[1].valid_hours
      break
    end
  end
end
return Logic_UGC_Season