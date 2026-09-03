local CorpsShopSystem = {
  corps_shop_item_class_clothing = 1,
  corps_shop_item_class_headportrait = 2,
  corps_shop_item_class_alias = 3
}
CorpsShopSystem.CorpsShopInfoList = {}
CorpsShopSystem.CurrentShopHasStr = ""
CorpsShopSystem.ShopItemType = {Clothing = 1, Headpotrait = 2}
CorpsShopSystem.icon_change_time = 0
CorpsShopSystem.CorpsShopCurrentBuyShopItemId = 0
CorpsShopSystem.level = 0
CorpsShopSystem.money = 0
CorpsShopSystem.corpsPosition = 0
local table_pool = require("common.table_pool").Create()
function CorpsShopSystem.Init()
  CorpsShopSystem.level = DataMgr.corpsInfo.level
  CorpsShopSystem.money = DataMgr.corps_money
  CorpsShopSystem.corpsPosition = DataMgr.corpsInfo.selfMember.position
  CorpsShopSystem.GetShopDataReq(CorpsShopSystem.CurrentShopHasStr, CorpsShopSystem.icon_change_time)
  CorpsShopSystem.GetShopLimitBuyReq()
  log(bWriteLog and "CorpsShopSystem.Init")
end
function CorpsShopSystem.Release()
  log(bWriteLog and "CorpsShopSystem.Release")
end
function CorpsShopSystem.ClearData()
  log(bWriteLog and "CorpsShopSystem.ClearData")
  CorpsShopSystem.CurrentShopHasStr = ""
  CorpsShopSystem.icon_change_time = 0
  table_pool:RecycleAll(CorpsShopSystem.CorpsShopInfoList)
  CorpsShopSystem.CorpsShopInfoList = {}
end
function CorpsShopSystem.HasNewOpenShopItem()
  return false
end
function CorpsShopSystem.GetItemInfoById(itemId)
  for k, v in pairs(CorpsShopSystem.CorpsShopInfoList) do
    if v.item_id == itemId then
      return v
    end
  end
end
function CorpsShopSystem.UpdateItemLimitNum(itemId, currentHasBuyNum)
  log(bWriteLog and "CorpsShopSystem.UpdateItemLimitNum")
  currentHasBuyNum = currentHasBuyNum or 0
  for k, v in pairs(CorpsShopSystem.CorpsShopInfoList) do
    if v.item_id == itemId then
      v.has_buy_num = currentHasBuyNum
      return
    end
  end
end
function CorpsShopSystem.ResetItemLimitNumAndCd()
  for k, v in pairs(CorpsShopSystem.CorpsShopInfoList) do
    v.has_buy_num = 0
    v.time_cd = 0
  end
end
function CorpsShopSystem.UpdateItemLimitNumAndCd(itemId, item_limit_buy_info_by_day)
  for k, v in pairs(CorpsShopSystem.CorpsShopInfoList) do
    if v.item_id == itemId then
      v.has_buy_num = item_limit_buy_info_by_day.item_num
      if item_limit_buy_info_by_day.cd_time < 0 then
        v.has_buy_num = 0
      end
      v.time_cd = item_limit_buy_info_by_day.cd_time
      return
    end
  end
end
function CorpsShopSystem.ShowNotEnoughMoneyBox()
  local funcConfirm = function()
    local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
    CorpsTrainingSystem.OpenTrainingUI()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("410046"), funcConfirm)
end
function CorpsShopSystem.ListSort(a, b)
  if a.sort_id ~= b.sort_id then
    return a.sort_id < b.sort_id
  end
  if a.item_id ~= b.item_id then
    return a.item_id < b.item_id
  end
  if a.unlock_corps_level ~= b.unlock_corps_level then
    return a.unlock_corps_level < b.unlock_corps_level
  end
  return false
end
function CorpsShopSystem.GetShopDataReq(shopHashStr, icon_change_time)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "CorpsShopSystem.GetShopDataReq shopHashStr:" .. shopHashStr)
  if CorpsMgr.IsInCorps() then
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_shoplist_req(shopHashStr, icon_change_time)
  end
end
function CorpsShopSystem.GetShopDataRes(retResult, shopHashStr, corps_shop_item, corps_shop_item_no_icon, icon_change_time, param1, param2, param3)
  log(bWriteLog and "CorpsShopSystem.GetShopDataRes")
  if retResult == NetErrorCode_NONE then
    if shopHashStr == nil or shopHashStr == "" then
      return
    end
    log(bWriteLog and shopHashStr)
    CorpsShopSystem.CurrentShopHasStr = shopHashStr
    CorpsShopSystem.    CorpsShopSystem.CorpsShopInfoList = {}
    local corpsShopClothingTable = corps_shop_item[CorpsShopSystem.corps_shop_item_class_clothing]
    local tempTable = corps_shop_item_no_icon[CorpsShopSystem.corps_shop_item_class_clothing]
    if tempTable ~= nil then
      for k, v in pairs(tempTable) do
        corpsShopClothingTable[k] = v
      end
    end
    if corpsShopClothingTable ~= nil then
      for k, v in pairs(corpsShopClothingTable) do
        local clothingInfo = table_pool:Get()
        clothingInfo.sort_id = v.sort_id
        clothingInfo.item_id = v.item_id
        clothingInfo.consume_corps_money = v.consume_corps_money
        clothingInfo.unlock_corps_level = v.unlock_corps_level
        clothingInfo.limit_buy_num = v.limitbuy_num
        clothingInfo.has_buy_num = 0
        clothingInfo.limit_buy_cd_num_by_day = v.limit_buy_cd_num_by_day
        clothingInfo.limit_buy_item_num_by_day = v.limit_buy_item_num_by_day
        clothingInfo.permanet_limit_buy_num = v.permanet_limit_buy_num
        clothingInfo.position_limit = v.position_limit
        clothingInfo.valid_hours = v.valid_hours or 0
        clothingInfo.cnt = v.cnt or 1
        table.insert(CorpsShopSystem.CorpsShopInfoList, clothingInfo)
      end
    end
    if #CorpsShopSystem.CorpsShopInfoList > 0 then
      table.sort(CorpsShopSystem.CorpsShopInfoList, CorpsShopSystem.ListSort)
    end
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.UpdateRedPoint()
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_SHOP_ITEMS_CHANGE)
  elseif type(retResult) == "number" then
    ShowNotice(retResult)
  end
end
function CorpsShopSystem.BuyShopItemReq(itemNum)
  log(bWriteLog and "CorpsShopSystem.BuyShopItemReq itemNum: " .. itemNum or 0)
  local info = CorpsShopSystem.GetItemInfoById(CorpsShopSystem.CorpsShopCurrentBuyShopItemId)
  if not info then
    return
  end
  if info.unlock_corps_level > CorpsShopSystem.level then
    ShowNotice(48385)
    return
  end
  if info.consume_corps_money * itemNum > CorpsShopSystem.money then
    CorpsShopSystem.ShowNotEnoughMoneyBox()
  else
    local CorpsHander = require("client.network.Protocol.CorpsHandler")
    CorpsHander.send_buy_corps_shopitem_req(CorpsShopSystem.corps_shop_item_class_clothing, CorpsShopSystem.CorpsShopCurrentBuyShopItemId, itemNum)
  end
end
function CorpsShopSystem.BuyShopItemRes(retResult, itemClass, itemId, itemNum, _, corps_money, cur_item_buy_num, item_limit_buy_info_by_day, item_limit_buy_info_by_permanet, valid_hours)
  log(bWriteLog and "CorpsShopSystem.BuyShopItemRes retResult:" .. tostring(retResult))
  if itemNum then
    log(bWriteLog and "CorpsShopSystem.BuyShopItemRes itemNum:" .. itemNum)
  end
  if retResult == NetErrorCode_NONE then
    local itemData = {
      res_id = itemId,
      count = itemNum,
          }
    local itemList = {}
    table.insert(itemList, itemData)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList)
    DataMgr.    if cur_item_buy_num ~= nil then
      CorpsShopSystem.UpdateItemLimitNum(itemId, cur_item_buy_num)
    end
    if item_limit_buy_info_by_day ~= nil then
      CorpsShopSystem.UpdateItemLimitNumAndCd(itemId, item_limit_buy_info_by_day)
    end
    if item_limit_buy_info_by_permanet ~= nil then
      CorpsShopSystem.UpdateItemLimitNum(itemId, item_limit_buy_info_by_permanet)
    end
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_SHOP_ITEMS_CHANGE)
  elseif type(retResult) == "number" then
    if retResult == 100150012 then
      local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
      ShowNotice(LocUtil.LocalizeResFormat(retResult, ChannelName))
    elseif retResult == 100150013 then
      ShowNotice(retResult)
    elseif retResult == 433032 then
      ShowNotice(49298)
    elseif retResult == 433015 then
      ShowNotice(LocUtil.LocalizeResFormat(retResult, itemClass))
    else
      local noticeStr = LocUtil.GetLocalizeResStr(retResult)
      if noticeStr ~= "" then
        if itemClass then
          noticeStr = string.format(noticeStr, itemClass)
        end
        ShowNotice(noticeStr)
      else
        ShowNotice(retResult)
      end
    end
  end
end
function CorpsShopSystem.GetShopLimitBuyReq()
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_shopitem_limitbuy_req()
end
function CorpsShopSystem.GetShopLimitBuyRes(retResult, corps_shop_limit_but_by_season, corps_shop_limit_but_by_day, corps_shop_limit_but_by_permanet)
  log(bWriteLog and "CorpsShopSystem.GetShopLimitBuyRes retResult:" .. retResult)
  if retResult == NetErrorCode_NONE then
    local itemList = corps_shop_limit_but_by_season.itemlist
    CorpsShopSystem.ResetItemLimitNumAndCd()
    if itemList and type(itemList) == "table" then
      for k, v in pairs(itemList) do
        CorpsShopSystem.UpdateItemLimitNum(k, v)
      end
    end
    if corps_shop_limit_but_by_day and type(corps_shop_limit_but_by_day) == "table" then
      for k, v in pairs(corps_shop_limit_but_by_day) do
        CorpsShopSystem.UpdateItemLimitNumAndCd(k, v)
      end
    end
    if corps_shop_limit_but_by_permanet and type(corps_shop_limit_but_by_permanet) == "table" then
      for k, v in pairs(corps_shop_limit_but_by_permanet) do
        CorpsShopSystem.UpdateItemLimitNum(k, v)
      end
    end
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_SHOP_ITEMS_CHANGE)
  elseif type(retResult) == "number" then
    ShowNotice(retResult)
  end
end
return CorpsShopSystem