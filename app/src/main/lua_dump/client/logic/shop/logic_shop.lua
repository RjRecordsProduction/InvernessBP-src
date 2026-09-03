local ShopSystem = {
  jkActivePrice = nil,
  ItemInfoList = {},
  LastBuyInfo = {},
  BoxList = {},
  BoxIcon = {},
  GoldBoxIndex = 0,
  JumpBoxIndex = 0,
  ItemPlayModleList = {},
  CrateLastBuyInfo = {},
  UIRootTranslationOfKJ = nil,
  OpenBoxVideoCfg = nil
}
function ShopSystem.Enter()
  log(bWriteLog and "ShopSystem enter")
  ShopSystem.shop_itemlist_req()
end
function ShopSystem.InitOpenBoxVideoCfg()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_CRATEBOX_VIDEO) then
    return
  end
  local sCfgName = "KR_ChestVideo"
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
    sCfgName = "JP_ChestVideo"
  end
  local uChestAllVideoCfg = CDataTable.GetTable(sCfgName)
  local tQualityVideoMap = {}
  for _, v in pairs(uChestAllVideoCfg) do
    if tQualityVideoMap[v.Quality] == nil then
      tQualityVideoMap[v.Quality] = {}
    end
    tQualityVideoMap[v.Quality][v.ID] = v.Probability / 100
  end
  ShopSystem.OpenBoxVideoCfg = tQualityVideoMap
end
function ShopSystem.GetRandomVideo(quality)
  log(bWriteLog and "ShopSystem.GetRandomVideo quality = " .. tostring(quality))
  if not ShopSystem.OpenBoxVideoCfg then
    ShopSystem.InitOpenBoxVideoCfg()
  end
  if quality <= 4 then
    quality = 4
  end
  local video = ""
  if ShopSystem.OpenBoxVideoCfg and ShopSystem.OpenBoxVideoCfg[quality] then
    local tag = math.random()
    local base = 0
    for VideoID, VideoProp in pairs(ShopSystem.OpenBoxVideoCfg[quality]) do
      base = base + VideoProp
      if tag <= base then
        local cfg = CDataTable.GetTableData("OpenBoxVideo", VideoID)
        if cfg then
          local PufferConst = require("client.slua.logic.download.puffer_const")
          local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
          local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
            "/Game/MoviesPak/" .. cfg.videoName
          })
          if state == PufferConst.ENUM_DownloadState.Done then
            video = cfg.videoName
            break
          end
          PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
            "/Game/MoviesPak/" .. cfg.videoName
          })
        end
        break
      end
    end
  end
  if video ~= "" then
    video = "./MoviesPakDir/" .. video .. ".mp4"
  end
  log(bWriteLog and "ShopSystem.GetRandomVideo video = " .. video)
  return video
end
function ShopSystem.shop_itemlist_req(shopType)
end
function ShopSystem.shop_item_content_req(shopid)
end
function ShopSystem.get_single_shopitem(shop_item_id)
end
function ShopSystem.shop_buy_req(itemsInfo)
  log(bWriteLog and "shop_buy_req")
  if itemsInfo == nil or next(itemsInfo) == nil then
    return
  end
  ShopSystem.LastBuyInfo = itemsInfo
  log_tree("itemsInfo", itemsInfo)
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_shop_buy_req(itemsInfo)
end
function ShopSystem.get_shop_limit_info(shopId)
  local MarketHandler = require("client.network.Protocol.MarketHandler")
  MarketHandler.send_get_shop_limit_info(shopId)
end
function ShopSystem.updateItemInfo(shopId, newItemInfo)
  ShopSystem.ItemInfoList[shopId] = {
    product_id = shopId,
    item_id = newItemInfo.itemid,
    pruduct_name = newItemInfo.shop_name,
    product_desc = newItemInfo.shop_desc,
    product_type = newItemInfo.shop_type,
    product_sub_type = newItemInfo.subtype,
    product_gold_price = newItemInfo.gold_price,
    product_sort = newItemInfo.display_sort,
    item_icon = newItemInfo.icon,
    price_type = newItemInfo.price_type,
    fp_token_price = newItemInfo.fp_token_price or 0,
    is_fp_token_valid = newItemInfo.is_fp_token_valid or false,
    ticket_price = newItemInfo.ticket_price,
    lowest_rounds = newItemInfo.lowest_rounds,
    max_config_rounds = newItemInfo.max_config_rounds,
    preview_items = newItemInfo.preview_items,
    drop_rate = newItemInfo.drop_rate,
    start_time = newItemInfo.begin_time,
    end_time = newItemInfo.end_time,
    icon = newItemInfo.box_icon,
    is_cur_season = newItemInfo.is_cur_season,
    gender = newItemInfo.gender,
    key_item_id = newItemInfo.key_item_id,
    key_number = newItemInfo.key_number,
    ten_price = newItemInfo.ten_price,
    play_modle = newItemInfo.play_modle,
    act = newItemInfo.act,
    is_rate_up = newItemInfo.is_rate_up,
    rate_up_end_time = newItemInfo.rate_up_end_time
  }
  log_tree("updateItemInfo:", ShopSystem.ItemPlayModleList)
  log_tree("updateItemInfo1:", newItemInfo)
  ShopSystem.ItemPlayModleList[newItemInfo.itemid] = newItemInfo.play_modle
  local itemData = CDataTable.GetTableData("Item", newItemInfo.itemid)
  if itemData ~= nil then
    ShopSystem.ItemInfoList[shopId].pruduct_name = itemData.ItemName
    ShopSystem.ItemInfoList[shopId].product_desc = itemData.ItemDesc
  end
end
function ShopSystem.on_itemlist_rsp(res, itemlist, itemType)
  log(bWriteLog and "on_itemlist_rsp: " .. res)
  if res == NetErrorCode_NONE then
    if itemType == 17 then
      ShopSystem.GetStoreGiftBox(itemlist)
      return
    end
    ShopSystem.ItemInfoList = {}
    ShopSystem.ItemPlayModleList = {}
    for k, v in pairs(itemlist) do
      local shopId = tonumber(k)
      ShopSystem.updateItemInfo(shopId, v)
    end
    local tempList = {}
    for k, v in pairs(ShopSystem.ItemInfoList) do
      table.insert(tempList, v)
    end
    table.sort(tempList, function(a, b)
      return a.product_sort > b.product_sort
    end)
    for i, v in ipairs(tempList) do
      if v.price_type == 0 then
        ShopSystem.GoldBoxIndex = v.product_id
      end
    end
    ShopSystem.BoxList = {}
    for i, v in ipairs(tempList) do
      table.insert(ShopSystem.BoxList, v.product_id)
    end
    ShopSystem.BoxIcon = {}
    for i, v in ipairs(tempList) do
      table.insert(ShopSystem.BoxIcon, ShopSystem.ItemInfoList[v.product_id].icon)
    end
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_UPDATE_BOX_COUNT, #ShopSystem.BoxIcon)
    EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST)
  else
    log(bWriteLog and "on_itemlist_rep failed ")
  end
end
function ShopSystem.GetStoreGiftBox(itemlist)
  ShopSystem.GiftBoxList = {}
  for k, v in pairs(itemlist) do
    local shopId = tonumber(k)
    ShopSystem.GiftBoxList[shopId] = {
      product_id = shopId,
      item_id = v.itemid,
      pruduct_name = v.shop_name,
      product_desc = v.shop_desc,
      product_type = v.shop_type,
      product_sub_type = v.subtype,
      product_gold_price = v.gold_price,
      product_sort = v.display_sort,
      item_icon = v.icon,
      price_type = v.price_type,
      ticket_price = v.ticket_price,
      lowest_rounds = v.lowest_rounds,
      max_config_rounds = v.max_config_rounds,
      preview_items = v.preview_items,
      drop_rate = v.drop_rate,
      start_time = v.begin_time,
      end_time = v.end_time,
      icon = v.box_icon,
      is_cur_season = v.is_cur_season,
      gender = v.gender,
      got_num = v.item_got_num,
      act = v.act
    }
    local itemData = CDataTable.GetTableData("Item", v.itemid)
    if itemData ~= nil then
      ShopSystem.GiftBoxList[shopId].pruduct_name = itemData.ItemName
      ShopSystem.GiftBoxList[shopId].product_desc = itemData.ItemDesc
    end
  end
  local tempList = {}
  for k, v in pairs(ShopSystem.GiftBoxList) do
    table.insert(tempList, v)
  end
  ShopSystem.BoxGiftList = {}
  for i, v in ipairs(tempList) do
    table.insert(ShopSystem.BoxGiftList, v.product_id)
  end
  EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_BOX_LIST)
end
function ShopSystem.GetGiftBoxIndex(boxId)
  local ans = 0
  local tmpGiftBox = {}
  for k, v in pairs(ShopSystem.GiftBoxList) do
    table.insert(tmpGiftBox, {
      id = v.product_id,
      sort = v.product_sort
    })
  end
  table.sort(tmpGiftBox, function(a, b)
    return a.sort > b.sort
  end)
  for i, v in pairs(tmpGiftBox) do
    if v.id == boxId then
      log(bWriteLog and "xzx boxId = " .. boxId .. ", i = " .. i)
      ans = i - 1
      break
    end
  end
  return ans
end
function ShopSystem.getBoxIndex(shopid)
  log(bWriteLog and "shopid = " .. shopid)
  ShopSystem.JumpBoxIndex = 0
  if ShopSystem.BoxList ~= nil then
    log_tree("BoxList:", ShopSystem.BoxList)
    for i, v in ipairs(ShopSystem.BoxList) do
      if shopid == v then
        ShopSystem.JumpBoxIndex = i
        return
      end
    end
  end
end
function ShopSystem.GetShopItemInfoByKeyItemId(keyItemId)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local list = store_supply_manager:GetOptimizeSupplyInfo()
  for shopID, values in pairs(list) do
    if values and values.key_item == keyItemId then
      return shopID
    end
  end
  return nil
end
function ShopSystem.HasRateUpItem()
  for k, v in pairs(ShopSystem.GiftBoxList) do
    if v.rate_up then
      return true
    end
  end
  return false
end
function ShopSystem.get_single_shopitem_rsp(res, shop_item)
  log(bWriteLog and "get_single_shopitem_rsp: " .. res)
  if res == NetErrorCode_NONE then
    local shopId = tonumber(shop_item.itemid)
    local iteminfo = ShopSystem.ItemInfoList[shopId]
    if iteminfo ~= nil then
      local update = iteminfo.product_gold_price ~= shop_item.gold_price
      if update then
        iteminfo.product_gold_price = shop_item.gold_price
        EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE)
      end
    end
  end
end
function ShopSystem.on_buy_rsp(res, itemlist)
  if res == NetErrorCode_NONE then
    log(bWriteLog and "on_buy_rsp success ")
    for k, v in pairs(itemlist) do
      local shopId = tonumber(k)
      ShopSystem.get_single_shopitem(shopId)
    end
    local arrayItemData = {}
    for k, v in pairs(itemlist) do
      local shopId = tonumber(k)
      log(bWriteLog and "ShopSystem.on_buy_rsp shopid " .. tostring(shopId))
      local iteminfo = ShopSystem.ItemInfoList[shopId]
      if iteminfo ~= nil then
        local itemdata = CDataTable.GetTableData("Item", iteminfo.item_id)
        log(bWriteLog and "ShopSystem.on_buy_rsp item_id " .. tostring(iteminfo.item_id))
        if itemdata ~= nil and itemdata.ItemSubType ~= 1501 then
          table.insert(arrayItemData, {
            res_id = iteminfo.item_id,
            count = v
          })
        end
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if not (PublishRegionMacros.IsJapanOrKorea() and 20002 <= shopId) or shopId <= 20599 then
        end
      end
    end
    if 0 < #arrayItemData then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
    end
    EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_KEY_UPDATE)
  else
    if res == "qrcode_login_limit" then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
      return
    end
    log(bWriteLog and "on_buy_rsp failed :" .. res)
    if res == 9910010 then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
    end
    if res == 5000001 then
      EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_TIME_OUT)
    end
    ShowNotice(res)
  end
end
function ShopSystem.on_shop_buy_item_notify_rep(res, itemList)
  if res == NetErrorCode_NONE then
    log(bWriteLog and "on_shop_buy_item_notify_rep success ")
    log_tree("itemList", itemList)
    local rewardList = {}
    for k, v in pairs(itemList) do
      table.insert(rewardList, {res_id = k, count = v})
    end
    log_tree("rewardList", rewardList)
    if 0 < #rewardList then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(rewardList)
    end
  else
    ShowNotice(res)
  end
end
function ShopSystem.get_shop_limit_info_rsp(res, limit, id)
  log(bWriteLog and "ShopSystem.get_shop_limit_info_rsp")
  if ShopSystem.GiftBoxList[id] ~= nil then
    ShopSystem.GiftBoxList[id].got_num = limit
  end
  EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_LIMIT_UPDATE, id)
end
function ShopSystem.on_open_pandora_chest_rsp(item_list, decompose_list, other_list)
  if not item_list or #item_list <= 0 then
    return
  end
  BP_Open_Box_DecomposeItemId = 0
  decompose_list = decompose_list or {}
  for k, v in pairs(decompose_list) do
    log(bWriteLog and "on_open_pandora_chest_rsp decompose item id :" .. tostring(v.itemid))
    BP_Open_Box_DecomposeItemId = v.itemid
    break
  end
  local arrayItemData = {}
  for k, v in pairs(item_list) do
    local h = v.valid_hours or 0
    local decomposeInfo = decompose_list[k]
    if decomposeInfo == nil then
      table.insert(arrayItemData, {
        res_id = v.itemid,
        count = v.count,
        valid_hours = h
      })
    else
      local tid = decomposeInfo.itemid
      local cnt = decomposeInfo.count
      local oneTable = {
        res_id = v.itemid,
        count = v.count,
        valid_hours = h,
        to_res_id = tid,
        to_res_      }
      table.insert(arrayItemData, oneTable)
    end
  end
  local bis10Box = false
  if other_list and other_list.shop_count and other_list.shop_count == 10 then
    bis10Box = true
  end
  if UIManager.IsUIShow(UIManager.UI_Config.new_supply_get_panel) then
    local boxUI = UIManager.GetUI(UIManager.UI_Config.new_supply_get_panel)
    boxUI:TryShowSupplyGetPanel(arrayItemData, bis10Box, {needShowMovie = true})
  else
    UIManager.ShowUI(UIManager.UI_Config.new_supply_get_panel, arrayItemData, bis10Box, {needShowMovie = true})
  end
end
function ShopSystem.on_open_chest_rsp(res, chestid, itemlist, reason, lowest_rounds, _, decompose_list, boxName, total_random_lucky_value)
  log(bWriteLog and "ShopSystem.on_open_chest_rsp, res = " .. tostring(res) .. ", reason = " .. tostring(reason) .. ", boxName = " .. tostring(boxName))
  log_tree("hhy on_open_chest_rsp itemlist", itemlist)
  if res == NetErrorCode_NONE then
    log(bWriteLog and "on_open_chest_rsp success ")
    local supply_activity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_activity_manager)
    supply_activity_manager:SetLuckChangeValue(total_random_lucky_value or 0)
    BP_Open_Box_DecomposeItemId = 0
    for k, v in pairs(decompose_list) do
      for tid, cnt in pairs(v) do
        log(bWriteLog and "on_open_chest_rsp decompose item id :" .. tostring(tid))
        BP_Open_Box_DecomposeItemId = tid
        break
      end
      break
    end
    local arrayItemData = {}
    local count = 0
    for k, v in pairs(itemlist) do
      local h = v.valid_hours or 0
      if h <= 0 then
        h = ShopSystem.GetItemValidHours(v.resid)
      end
      local decomposeInfo = decompose_list[k]
      if decomposeInfo == nil then
        table.insert(arrayItemData, {
          res_id = v.resid,
          count = v.count,
          valid_hours = h,
          must_reward = v.must_reward,
          getTags = v.drop_fun,
          rankTitleType = v.rankTitleType,
          chief_event_share_count_bak = v.chief_event_share_count_bak,
          king_event_share_count_bak = v.king_event_share_count_bak
        })
      else
        for tid, cnt in pairs(decomposeInfo) do
          local hasLimitTime = ShopSystem.CheckItemHasLimitTime(tid)
          local validHours = hasLimitTime and h or 0
          local oneTable = {
            res_id = v.resid,
            count = v.count,
            valid_hours = validHours,
            to_res_id = tid,
            to_res_cnt = cnt,
            to_res_is_limit_time = hasLimitTime,
            must_reward = v.must_reward,
            getTags = v.drop_fun,
            rankTitleType = v.rankTitleType,
            chief_event_share_count_bak = v.chief_event_share_count_bak,
            king_event_share_count_bak = v.king_event_share_count_bak
          }
          table.insert(arrayItemData, oneTable)
          break
        end
      end
      count = count + v.count
    end
    if reason ~= 1 then
      local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
      if UnknowPassTunnelSystem.isShowRP then
        EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CHEST_OPEN, itemlist)
      else
        local mergedData = {}
        local newData = {}
        for _, item in pairs(arrayItemData) do
          local key
          if item.to_res_id then
            if item.getTags then
              key = item.to_res_id .. "_" .. item.getTags .. "_" .. 0
              if 0 < item.valid_hours then
                key = item.to_res_id .. "_" .. item.getTags .. "_" .. 1
              end
            else
              key = item.to_res_id .. "_" .. 0
              if 0 < item.valid_hours then
                key = item.to_res_id .. "_" .. 1
              end
            end
            if mergedData[key] then
              mergedData[key].count = mergedData[key].count + item.to_res_cnt
            else
              mergedData[key] = {
                res_id = item.to_res_id,
                count = item.to_res_cnt,
                valid_hours = item.valid_hours,
                getTags = item.getTags,
                rankTitleType = item.rankTitleType,
                chief_event_share_count_bak = item.chief_event_share_count_bak,
                king_event_share_count_bak = item.king_event_share_count_bak
              }
            end
          else
            if item.getTags then
              key = item.res_id .. "_" .. item.getTags .. "_" .. 0
              if 0 < item.valid_hours then
                key = item.res_id .. "_" .. item.getTags .. "_" .. 1
              end
            else
              key = item.res_id .. "_" .. 0
              if 0 < item.valid_hours then
                key = item.res_id .. "_" .. 1
              end
            end
            if mergedData[key] then
              mergedData[key].count = mergedData[key].count + item.count
            else
              mergedData[key] = item
            end
          end
        end
        for _, item in pairs(mergedData) do
          newData[#newData + 1] = item
        end
        local isGooglePlayPoint = CDataTable.GetTableData("GooglePlayPointConfig", chestid) ~= nil
        local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
        Logic_CommonItemGet.ShowPanel_DefaultStyle(newData, nil, nil, {isGooglePlayPoint = isGooglePlayPoint})
      end
    else
      if UIManager.IsUIShow(UIManager.UI_Config.new_supply_get_panel) then
        local boxUI = UIManager.GetUI(UIManager.UI_Config.new_supply_get_panel)
        boxUI:TryShowSupplyGetPanel(arrayItemData, false, {needShowMovie = true, chest_id = chestid})
      else
        UIManager.ShowUI(UIManager.UI_Config.new_supply_get_panel, arrayItemData, false, {needShowMovie = true, chest_id = chestid})
      end
      EventSystem:postEvent(EVENTTYPE_VIDEO, EVENTID_STORE_WISH_ITEM_GET, arrayItemData)
    end
    log(bWriteLog and "lowest_rounds:" .. lowest_rounds)
  else
    EventSystem:postEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_UNLOCK)
    log(bWriteLog and "on_open_chest_rsp failed ")
    ShowNotice(res)
  end
end
function ShopSystem.on_open_10chest_rsp(res, itemlist, decompose_list, boxName, reopenDigit, info, chest_id)
  log_tree("hhy ShopSystem.on_open_10chest_rsp itemlist", itemlist)
  log_tree("ShopSystem.on_open_10chest_rsp decompose_list", decompose_list)
  log_tree("ShopSystem.on_open_10chest_rsp info", info)
  if res == NetErrorCode_NONE then
    log(bWriteLog and "on_open_10chest_rsp success ")
    local supply_activity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_activity_manager)
    supply_activity_manager:SetLuckChangeValue(info and info.total_random_lucky_value or 0)
    local arrayItemData = {}
    local count = 0
    for k, v in pairs(itemlist) do
      local h = v.valid_hours or 0
      if h <= 0 then
        h = ShopSystem.GetItemValidHours(v.resid)
      end
      local decomposeInfo = decompose_list[k]
      if decomposeInfo ~= nil then
        for tid, cnt in pairs(decomposeInfo) do
          local hasLimitTime = ShopSystem.CheckItemHasLimitTime(tid)
          local oneTable = {
            res_id = v.resid,
            count = v.count,
            valid_hours = h,
            to_res_id = tid,
            to_res_cnt = cnt,
            to_res_is_limit_time = hasLimitTime,
            must_reward = v.must_reward,
            rankTitleType = v.rankTitleType,
            chief_event_share_count_bak = v.chief_event_share_count_bak,
            king_event_share_count_bak = v.king_event_share_count_bak
          }
          table.insert(arrayItemData, oneTable)
          break
        end
      else
        table.insert(arrayItemData, {
          res_id = v.resid,
          count = v.count,
          valid_hours = h,
          must_reward = v.must_reward,
          rankTitleType = v.rankTitleType,
          chief_event_share_count_bak = v.chief_event_share_count_bak,
          king_event_share_count_bak = v.king_event_share_count_bak
        })
      end
      count = count + v.count
    end
    if UIManager.IsUIShow(UIManager.UI_Config.new_supply_get_panel) then
      local boxUI = UIManager.ShowUI(UIManager.UI_Config.new_supply_get_panel)
      boxUI:TryShowSupplyGetPanel(arrayItemData, true, {needShowMovie = true, chest_id = chest_id})
    else
      UIManager.ShowUI(UIManager.UI_Config.new_supply_get_panel, arrayItemData, true, {
        needShowMovie = true,
        oneKeyInfo = info,
              })
    end
    EventSystem:postEvent(EVENTTYPE_VIDEO, EVENTID_STORE_WISH_ITEM_GET, arrayItemData)
  else
    EventSystem:postEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_UNLOCK)
    log(bWriteLog and "on_open_10chest_rsp failed ")
    ShowNotice(res)
  end
end
function ShopSystem.GetItemValidHours(itemID)
  local cfg = CDataTable.GetTableData("Item", itemID)
  local validTime = 0
  if cfg then
    if cfg.ValidTimes and cfg.ValidTimes ~= 0 then
      validTime = cfg.ValidTimes
    end
  else
    log_warning(string.format("%s item is nil ", tostring(itemID)))
  end
  return validTime
end
function ShopSystem.CheckItemHasLimitTime(itemID)
  local cfg = CDataTable.GetTableData("Item", itemID)
  if cfg then
    if cfg.ValidTimes and cfg.ValidTimes ~= 0 then
      return true
    end
    if cfg.ExTime and cfg.ExTime ~= "" then
      return true
    end
  end
  return false
end
function ShopSystem.on_shop_round_update_rsp(shopid, lowest_rounds, max_config_rounds)
  if ShopSystem.ItemInfoList[shopid] ~= nil then
    ShopSystem.ItemInfoList[shopid].    ShopSystem.ItemInfoList[shopid].  end
end
function ShopSystem.on_shop_item_content_rsp(res, item_list, id)
  log(bWriteLog and "on_shop_item_content_rsp")
  EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, {id, item_list})
end
function ShopSystem.OpenCommonExchange(eventType, eventID, vars)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  local actID = tonumber(vars.activityid)
  local highLevelItemID = tonumber(vars.highLevelItemID)
  ShopSystem.CommonExchangeId = vars.activityid
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.bShowCommonExchange = true
  LuckybackHandler.  LuckybackHandler.send_get_exchange_activity_info_req(actID)
end
function ShopSystem.SetJkActiveData(data)
  ShopSystem.jkActivePrice = data
  log_tree("ShopSystem.jkActivePrice", ShopSystem.jkActivePrice)
end
return ShopSystem