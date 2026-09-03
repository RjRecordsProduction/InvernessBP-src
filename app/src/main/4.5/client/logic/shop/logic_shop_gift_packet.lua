local ShopGiftPacketLogic = {}
function ShopGiftPacketLogic.SendGift(touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, askIndex)
  if buyitem == nil then
    return
  end
  if buyitem.num == nil then
    buyitem.num = 1
  end
  buyitem.first_money = 1
  UIManager.CloseUI(UIManager.UI_Config.New_Shop_gift_All_UIBP)
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  if 0 < askIndex then
    MarketHandler.send_market_give_gift_req(touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, askIndex)
  else
    MarketHandler.send_market_give_gift_req(touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, nil)
  end
end
function ShopGiftPacketLogic.SendGetGiftMsgList(msgType, isClick)
  log(bWriteLog and "ShopGiftPacketLogic.SendGetGiftMsgList msgType:" .. msgType .. tostring(isClick))
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_get_giftmsg_req(msgType, isClick)
end
function ShopGiftPacketLogic.on_market_give_gift_rsp(res, askIndex)
  log(bWriteLog and "ShopGiftPacketLogic.on_market_give_gift_rsp ")
  if res == NetErrorCode_NONE then
    local giftPacketSystem = require("client.slua.logic.store.logic_store_gift_packet")
    local sGiftName = giftPacketSystem.GetGiftName()
    local sFriendName = giftPacketSystem.GetFriendDataByKey("nickName") or ""
    local msg = string.format(DataMgr.GetMsgByID(501030), sGiftName, sFriendName)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, DataMgr.GetMsgByID(102012), msg, giftPacketSystem.CloseUI, nil, LocUtil.GetLocalizeResStr("110036"))
    if askIndex ~= nil and 0 < askIndex then
      local MarketHandler = require("client.network.Protocol.MarketHandler")
      MarketHandler.send_market_get_giftmsg_req(12)
    end
  else
    log(bWriteLog and "market_give_gift_rsp failed " .. res)
    ShowNotice(res)
  end
end
function ShopGiftPacketLogic.on_market_get_giftmsg_rsp(res, msgtype, msglist)
  log(bWriteLog and "ShopGiftMsgCenter.recvGiftList res = " .. tostring(res) .. "msgtype : " .. tostring(msgtype))
  log_tree("recvGiftList", msglist)
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  giftSystem.RecvGiftList(res, msgtype, msglist)
end
function ShopGiftPacketLogic.SendMarketRefuseAskForReq(flag)
  log(bWriteLog and "ShopGiftPacketLogic.SendMarketRefuseAskForReq " .. (flag and "true" or "false"))
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_refuse_ask_for_req(flag)
end
function ShopGiftPacketLogic.on_market_refuse_ask_for_rsp(flag)
  log(bWriteLog and "on_market_refuse_ask_for_rsp " .. flag)
end
function ShopGiftPacketLogic.SendMarketGiftTakeReq(indexid)
  log(bWriteLog and "ShopGiftPacketLogic.SendMarketGiftTakeReq:" .. indexid)
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_gift_take_req(indexid)
end
function ShopGiftPacketLogic.on_market_gift_take_rsp(res, index, tItemList, tDecItemList)
  log(bWriteLog and "ShopGiftPacketLogic.on_market_gift_take_rsp " .. res)
  if res == NetErrorCode_NONE then
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.OnGetGift(index, tItemList, tDecItemList)
  else
    ShowNotice(res)
  end
end
function ShopGiftPacketLogic.SendMarketGiftAllTakeReq()
  log(bWriteLog and "ShopGiftPacketLogic.SendMarketGiftAllTakeReq:")
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_gift_all_take_req()
end
function ShopGiftPacketLogic.on_market_gift_all_take_rsp(msg, indexList, tItemList, tDecItemList)
  if msg ~= NetErrorCode_NONE and msg ~= "ver" then
    log(bWriteLog and "ShopGiftPacketLogic.on_market_gift_all_take_rsp: msg " .. tostring(msg))
    ShowNotice(msg)
    return
  end
  if next(table) ~= nil then
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.OnGetAllGift(indexList, tItemList, tDecItemList)
  end
  if msg == "ver" then
  end
end
function ShopGiftPacketLogic.SendMarketDelAllGiftMsgReq()
  log(bWriteLog and "ShopGiftPacketLogic.SendMarketGiftAllTakeReq:")
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_del_all_giftmsg_req()
end
function ShopGiftPacketLogic.on_market_del_all_giftmsg_rsp(msg, del_msg)
  log(bWriteLog and "on_market_del_all_giftmsg_rsp.msg:" .. tostring(msg))
  log_tree("on_market_del_all_giftmsg_rsp.del_msg:", del_msg)
  if msg == NetErrorCode_NONE then
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.OnDelAllGifts(del_msg)
  else
    ShowNotice(msg)
  end
end
function ShopGiftPacketLogic.SendMarketMsgAllSetReadReq()
  log(bWriteLog and "SendMarketMsgAllSetReadReq")
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_msg_all_setread_req()
end
function ShopGiftPacketLogic.on_market_msg_all_setread_rsp(list)
  log_tree("ShopGiftPacketLogic.on_market_msg_all_setread_rsp list = ", list)
  for i = 1, #list do
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.OnGetSetRead(list[i][1], list[i][2])
  end
end
function ShopGiftPacketLogic.SendMarketSendThankReq(touid, item, style, msg)
  log(bWriteLog and "ShopGiftPacketLogic.SendMarketSendThankReq")
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_send_thank_req(touid, item, style, msg)
end
function ShopGiftPacketLogic.on_market_send_thank_rsp(res)
  log(bWriteLog and "ShopGiftPacketLogic.on_market_send_thank_rsp:" .. res)
end
function ShopGiftPacketLogic.SendMarketMsgSetReadReq(msgtype, index, flag)
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_msg_setread_req(msgtype, index, flag)
end
function ShopGiftPacketLogic.on_market_msg_setread_rsp(res, msgtype, index)
  if res ~= NetErrorCode_NONE then
    return
  end
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  giftSystem.OnGetSetRead(msgtype, index)
end
function ShopGiftPacketLogic.on_market_give_gift_notify(info)
  log_tree("ShopGiftPacketLogic.on_market_give_gift_notify", {info})
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_get_giftmsg_req(11)
end
function ShopGiftPacketLogic.on_market_ask_for_notify(info)
  log_tree("ShopGiftPacketLogic.on_market_ask_for_notify", {info})
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_get_giftmsg_req(12)
end
function ShopGiftPacketLogic.on_market_send_thank_notify(info)
end
function ShopGiftPacketLogic.market_gift_give_count_req(give_type_id)
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_market_gift_give_count_req(give_type_id)
end
function ShopGiftPacketLogic.market_gift_give_count_rsp(cur_count, max_count, give_type_id)
  if not (cur_count and max_count) or not give_type_id then
    log(bWriteLog and " ShopGiftPacketLogic.market_gift_give_count_rsp Error >>>> " .. tostring(cur_count) .. " " .. tostring(max_count) .. " " .. tostring(give_type_id))
    return
  end
  EventSystem:postEvent(EVENTTYPE_GIVE_SYSTEM, EVENTID_GIVE_LIMIT_COUNT, cur_count, max_count, give_type_id)
end
function ShopGiftPacketLogic.ShowShare(data)
  data = data or {}
  local tAllData = {
    uid = data.uid,
    itemId = data.item
  }
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    sceneType = 9,
    isOld = true,
    nItemId = data.item,
    campaign = "shop_item",
    reasonStr = json.encode(tAllData),
    share_type = ShareBtnTLogShareTypeDefine.WishBoxSharing
  }
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.WishBoxSharing, nil, nil)
  Util.ShowShare(shareCfg, UIManager.UI_Config.ShopGift_Share, data)
end
return ShopGiftPacketLogic