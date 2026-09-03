local NetManager = require("client.network.comm.NetManager")
local RechargePurchaseHandler = {}
function RechargePurchaseHandler.send_direct_buy_pre_check(acitivityId)
  NetManager.SendPkg(1809102668, acitivityId)
end
function RechargePurchaseHandler.on_direct_buy_pre_check_rsp(res, activityId)
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  RechargePurchaseSystem.GetBuyPrecheckRsp(res, activityId)
end
function RechargePurchaseHandler.send_batch_query_direct_buy_info(reqList)
  NetManager.SendPkg(1239325150, reqList)
end
function RechargePurchaseHandler.on_batch_query_direct_buy_info_rsp(res, list)
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  RechargePurchaseSystem.GetPurchaseInfoRsp(res, list)
end
function RechargePurchaseHandler.send_unified_purchase(activityId, selectedNumber, couponId)
  NetManager.SendPkg(1243901004, activityId, selectedNumber, couponId)
end
function RechargePurchaseHandler.on_unified_purchase_rsp(res, item_id, item_num, need_show)
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  RechargePurchaseSystem.PurchaseItemByUCRsp(res, item_id, item_num, need_show)
end
function RechargePurchaseHandler.send_get_limited_special_chest_req()
  log(bWriteLog and "RechargePurchaseHandler.send_get_limited_special_chest_req")
  NetManager.SendPkg(1277969927)
end
function RechargePurchaseHandler.on_get_limited_special_chest_rsp(ret_tab)
  log(bWriteLog and "RechargePurchaseHandler.on_get_limited_special_chest_rsp")
  log_tree("RechargePurchaseHandler.on_get_limited_special_chest_rsp ret_tab:", ret_tab)
  local RechargeSystemJK = require("client.logic.recharge.logic_recharge_jk")
  if ret_tab and next(ret_tab) then
    if not RechargeSystemJK.bShowSpecialChestTab then
      RechargeSystemJK.bShowSpecialChestTab = true
      EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
    end
    EventSystem:postEvent(EVENTTYPE_DIRECTPURCHASE, EVENTID_DIRECTPURCHASE_LIMITEDGIFTSET, ret_tab)
    RechargeSystemJK.limited_special_list = ret_tab
  else
    RechargeSystemJK.bShowSpecialChestTab = false
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  end
end
function RechargePurchaseHandler.send_buy_limited_special_chest_req(special_id, coupon_id)
  log(bWriteLog and string.format("RechargePurchaseHandler.send_buy_limited_special_chest_req, special_id:%s", special_id))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  NetManager.SendPkg(998072919, special_id, coupon_id)
end
function RechargePurchaseHandler.on_buy_limited_special_chest_rsp(error, speical_id, limited_time_special)
  log(bWriteLog and string.format("RechargePurchaseHandler.on_buy_limited_special_chest_rsp, error, speical_id, limited_time_special:%s, %s, %s", error, speical_id, limited_time_special))
  log_tree("on_buy_limited_special_chest_rsp====", limited_time_special)
  local RechargeSystemJK = require("client.logic.recharge.logic_recharge_jk")
  if error == "uc not enough" then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg()
    return
  elseif error == "not-open" then
    ShowNotice(7809)
    RechargeSystemJK.bShowSpecialChestTab = false
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
    return
  end
  EventSystem:postEvent(EVENTTYPE_DIRECTPURCHASE, EVENTID_DIRECTPURCHASE_LIMITEDGIFTSETSINGLE, speical_id, limited_time_special)
  local itemList = RechargeSystemJK.GetAwardListBySpecialId(speical_id)
  if itemList and 0 < #itemList then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local CommonItemGet_Utils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Utils")
    local chestList = RechargeSystemJK.GetChestData(itemList)
    local tExtendData = {
      fCloseCallback = function()
        if chestList and 0 < #chestList then
          CommonItemGet_Utils.ChestItemUse(chestList[1].res_id, 2)
        end
      end
    }
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList, false, true, tExtendData)
  end
end
return RechargePurchaseHandler