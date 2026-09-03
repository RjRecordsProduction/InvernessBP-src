local NetManager = require("client.network.comm.NetManager")
local MarketHandler = {}
MarketHandler.Is_Player_Click = false
function MarketHandler.send_market_get_giftmsg_req(msgType, isClick)
  if msgType == 11 then
    MarketHandler.Is_Player_Click = isClick or false
  end
  NetManager.SendPkg(358173031, msgType, isClick)
end
function MarketHandler.on_market_get_giftmsg_rsp(res, msgtype, msglist)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_get_giftmsg_rsp(res, msgtype, msglist)
end
function MarketHandler.send_market_gift_give_count_req(give_type_id)
  NetManager.SendPkg(294984359, give_type_id)
end
function MarketHandler.on_market_gift_give_count_rsp(cur_count, max_count, give_type_id)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.market_gift_give_count_rsp(cur_count, max_count, give_type_id)
end
function MarketHandler.send_market_give_gift_req(touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, askIndex)
  NetManager.SendPkg(1243468263, touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, askIndex)
end
function MarketHandler.on_market_give_gift_rsp(res, askIndex)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_give_gift_rsp(res, askIndex)
end
function MarketHandler.send_market_ask_for_req(touid, shopid, style, msg)
  NetManager.SendPkg(1780795911, touid, shopid, style, msg)
end
function MarketHandler.on_market_ask_for_rsp(res)
end
function MarketHandler.send_market_refuse_ask_for_req(flag)
  NetManager.SendPkg(406699215, flag)
end
function MarketHandler.on_market_refuse_ask_for_rsp(flag)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_refuse_ask_for_rsp(flag)
end
function MarketHandler.send_market_gift_take_req(indexid)
  NetManager.SendPkg(1330087271, indexid)
end
function MarketHandler.on_market_gift_take_rsp(res, index, item_list, decompose_list)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_gift_take_rsp(res, index, item_list, decompose_list)
end
function MarketHandler.send_market_send_thank_req(touid, item, style, msg)
  NetManager.SendPkg(2130403323, touid, item, style, msg)
end
function MarketHandler.on_market_send_thank_rsp(res)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_send_thank_rsp(res)
end
function MarketHandler.send_market_msg_setread_req(msgtype, index, flag)
  NetManager.SendPkg(701193127, msgtype, index, flag)
end
function MarketHandler.on_market_msg_setread_rsp(res, msgtype, index)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_msg_setread_rsp(res, msgtype, index)
end
function MarketHandler.on_market_give_gift_notify(info)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_give_gift_notify(info)
end
function MarketHandler.on_market_ask_for_notify(info)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_ask_for_notify(info)
end
function MarketHandler.send_market_del_all_giftmsg_req()
  NetManager.SendPkg(955911815)
end
function MarketHandler.on_market_del_all_giftmsg_rsp(msg, del_msg)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_del_all_giftmsg_rsp(msg, del_msg)
end
function MarketHandler.send_market_gift_all_take_req()
  NetManager.SendPkg(788881511)
end
function MarketHandler.on_market_gift_all_take_rsp(msg, indexList, item_list, decompose_list)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_gift_all_take_rsp(msg, indexList, item_list, decompose_list)
end
function MarketHandler.send_market_msg_all_setread_req()
  NetManager.SendPkg(211022439)
end
function MarketHandler.on_market_msg_all_setread_rsp(list)
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.on_market_msg_all_setread_rsp(list)
end
function MarketHandler.send_shop_itemlist_req(shopType)
  NetManager.SendPkg(507735259, shopType)
end
function MarketHandler.on_shop_itemlist_rsp(res, itemlist, itemType)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_itemlist_rsp(res, itemlist, itemType)
end
function MarketHandler.send_get_single_shopitem(shop_item_id)
  NetManager.SendPkg(1790950294, shop_item_id)
end
function MarketHandler.on_get_single_shopitem_rsp(res, shop_item)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.get_single_shopitem_rsp(res, shop_item)
end
function MarketHandler.send_shop_buy_req(itemsInfo)
  NetManager.SendPkg(1095687655, itemsInfo)
end
function MarketHandler.on_shop_buy_rsp(res, itemlist)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_buy_rsp(res, itemlist)
end
function MarketHandler.on_open_chest_rsp(res, chestid, itemlist, reason, lowest_rounds, max_config_rounds, decompose_list, boxName, total_random_lucky_value)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_open_chest_rsp(res, chestid, itemlist, reason, lowest_rounds, max_config_rounds, decompose_list, boxName, total_random_lucky_value)
end
function MarketHandler.on_open_chest_ten_times_nofity(res, itemlist, decompose_list, boxName, reopenDigit, extra_chest_info, chest_id)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_open_10chest_rsp(res, itemlist, decompose_list, boxName, reopenDigit, extra_chest_info, chest_id)
end
function MarketHandler.send_shop_item_content_req(shopid)
  NetManager.SendPkg(686861451, shopid)
end
function MarketHandler.on_shop_item_content_rsp(res, item_list, id)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_shop_item_content_rsp(res, item_list, id)
end
function MarketHandler.on_shop_rounds_update_rsp(shopid, lowest_rounds, max_config_rounds)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_shop_round_update_rsp(shopid, lowest_rounds, max_config_rounds)
end
function MarketHandler.on_shop_buy_item_notify(res, itemList)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_shop_buy_item_notify_rep(res, itemList)
end
function MarketHandler.send_get_shop_limit_info(shopId)
  NetManager.SendPkg(715748756, shopId)
end
function MarketHandler.on_get_shop_limit_info_rsp(res, limit, id)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.get_shop_limit_info_rsp(res, limit, id)
end
function MarketHandler.send_get_h5_market_req()
  NetManager.SendPkg(1888045055)
end
function MarketHandler.on_get_h5_market_rsp(show_type, url, img)
  local StoreIndiaUtils = require("client.logic.store.store_india_utils")
  StoreIndiaUtils.get_h5_market_rsp(show_type, url, img)
end
function MarketHandler.on_notify_give_open(reslist)
  local logic_give_item = require("client.slua.logic.give_item.logic_give_item")
  logic_give_item.SetGiveSwitchInfo(reslist)
end
function MarketHandler.send_market_del_giftmsg_req(msg_type, indexes)
  log(bWriteLog and "[chub]MarketHandler.send_market_del_giftmsg_req, msg_type = " .. tostring(msg_type))
  log_tree("[chub]MarketHandler.send_market_del_giftmsg_req, indexes = ", indexes)
  NetManager.SendPkg(961206279, msg_type, indexes)
end
function MarketHandler.on_market_del_giftmsg_rsp(err_code)
  log(bWriteLog and "[chub]MarketHandler.on_market_del_giftmsg_rsp, err_code = " .. tostring(err_code))
  if tostring(err_code) == "ok" then
    ShowNotice(102011)
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_DELETE)
  else
    ShowNotice(err_code)
  end
end
return MarketHandler