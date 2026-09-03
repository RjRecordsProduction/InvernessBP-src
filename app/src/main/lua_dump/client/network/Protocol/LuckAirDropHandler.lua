local NetManager = require("client.network.comm.NetManager")
local LuckAirDropHandler = {}
function LuckAirDropHandler.on_sync_luck_airdrop(luckairtabledata)
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  LuckAirDropSystem.DataPushShowUI(luckairtabledata)
end
function LuckAirDropHandler.send_buy_luck_airdrop_req(itemid, num, use_ag)
  log(bWriteLog and "[ : use_ag" .. tostring(use_ag))
  NetManager.SendPkg(480057639, itemid, num, use_ag)
end
function LuckAirDropHandler.on_buy_luck_airdrop_rsp(msg, resId, resCount)
  local MallSystem = require("client.logic.mall.logic_mall")
  if msg == NetErrorCode_NONE then
    local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
    if LuckAirDropSystem.LuckAirData.items_info and next(LuckAirDropSystem.LuckAirData.items_info) then
      for i, v in pairs(LuckAirDropSystem.LuckAirData.items_info) do
        if v.res_id == resId and v.has_buy_num then
          v.has_buy_num = v.has_buy_num + resCount
        end
      end
    end
    LuckAirDropSystem.AfterBuy()
    MallSystem.ResetItemCache()
    local itemCfg = CDataTable.GetTableData("Item", resId)
    local validhours = 0
    if itemCfg.ValidTimes then
      log(bWriteLog and "itemCfg.ValidTimes " .. itemCfg.ValidTimes)
      validhours = itemCfg.ValidTimes
    end
    if itemCfg.ItemType ~= 15 then
      local cacheItemInfo = {}
      local itemData = {
        res_id = resId,
        count = resCount,
        valid_hours = validhours,
        expire_ts = 0
      }
      table.insert(cacheItemInfo, itemData)
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(cacheItemInfo)
    end
  elseif msg == 9930004 then
    local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
    local nNeedCount = LuckAirDropSystem.GetNeedUCCount()
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(nNeedCount)
  elseif msg == 9930007 then
    ShowNotice(9910003)
  elseif msg == 9930002 then
    ShowNotice(421010)
  elseif msg == 9930011 then
    ShowNotice(102100019)
  elseif msg == "qrcode_login_limit" then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
  else
    ShowNotice(msg)
    log(bWriteLog and "luckairdrop_buy_failure " .. tostring(msg))
  end
end
function LuckAirDropHandler.send_set_luck_airdrop_item_score_req(item_id, score)
  NetManager.SendPkg(2140118583, item_id, score)
end
function LuckAirDropHandler.on_set_luck_airdrop_item_score_rsp(err_code, item_id, score)
  if not err_code then
    log(bWriteLog and "exception_set_luck_airdrop_item_score_rsp err_code ")
    return
  end
  if not item_id then
    log(bWriteLog and "exception_set_luck_airdrop_item_score_rsp item_id ")
    return
  end
  if not score then
    log(bWriteLog and "exception_set_luck_airdrop_item_score_rsp score ")
    return
  end
  if err_code == 0 then
    EventSystem:postEvent(EVENTTYPE_LUCKAIR, EVENTID_EVALUATE_RSPDATA, item_id, score)
  else
    ShowNotice(err_code)
  end
end
function LuckAirDropHandler.send_report_luck_airdrop_statistics(open_sec)
  NetManager.SendPkg(549813956, open_sec)
end
function LuckAirDropHandler.send_get_luck_airdrop_info_after_ad(res_id, watch_ad_time, ad_index)
  NetManager.SendPkg(1629629772, res_id, watch_ad_time, ad_index)
end
function LuckAirDropHandler.on_get_luck_airdrop_info_after_ad_rsp(error)
  ShowNotice(error)
end
function LuckAirDropHandler.send_target_airdrop_trigger_req(scene_id)
  NetManager.SendPkg(857286632, scene_id)
end
function LuckAirDropHandler.on_target_airdrop_trigger_res(ret, scene_id, airdrop_list, end_time, discount, pre_price, cur_price, is_first)
  log(bWriteLog and "LuckAirDropHandler.on_target_airdrop_trigger_res " .. ret)
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  if ret ~= 0 then
    return
  end
  LuckAirDropSystem.HandleTargetAirdropData(scene_id, airdrop_list, end_time, discount, pre_price, cur_price, is_first)
end
function LuckAirDropHandler.on_target_airdrop_info_notify(scene_list)
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  LuckAirDropSystem.HandleTargetAirdropAllData(scene_list)
end
function LuckAirDropHandler.send_target_airdrop_buy_req(scene_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  NetManager.SendPkg(1077644359, scene_id)
end
function LuckAirDropHandler.on_target_airdrop_buy_rsp(ret, scene_id, reward_list)
  log(bWriteLog and "on_target_airdrop_buy_rsp " .. ret)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("reward_list ", reward_list)
  local rewards = {}
  for i, v in ipairs(reward_list) do
    table.insert(rewards, {
      res_id = v.resid,
      count = v.count,
      0
    })
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards)
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  LuckAirDropSystem.ClearData()
  local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
  AirDropMesh.Clear()
  if LuckAirDropSystem.target_airdrop_data and LuckAirDropSystem.target_airdrop_data[scene_id] then
    LuckAirDropSystem.target_airdrop_data[scene_id].is_buy = true
  end
  log_tree("LuckAirDropSystem.on_target_airdrop_buy_rsp", LuckAirDropSystem.target_airdrop_data[scene_id])
  EventSystem:postEvent(EVENTTYPE_LUCKAIR_TARGET, EVENTID_LUCKY_AIRDROP_TARGET_HIDE)
end
return LuckAirDropHandler