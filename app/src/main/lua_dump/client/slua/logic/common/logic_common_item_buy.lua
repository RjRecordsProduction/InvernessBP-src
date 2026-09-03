local CommonItemBuySystem = {limits_table = nil, need_show_result = true}
function CommonItemBuySystem.ShowBuyItemUI(nItemId, nShowSelectCount)
  local tBuyCfg = CommonItemBuySystem.GetBuyCfgByItemID(nItemId)
  if not tBuyCfg then
    return
  end
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local nLimitCount = CommonItemBuySystem.GetCurLimitByItemID(nItemId)
  local tExchangeData = {
    itemId = nItemId,
    itemNum = 0,
    validTime = 0,
    timeLimits = nLimitCount,
    hasExchangeCount = 0,
    needItemId = CoinMacro.Uc,
    needItemNum = tBuyCfg.price
  }
  local tExtra = {
    sTitle = LocUtil.GetLocalizeResStr(6177),
    sExchangeBtnText = LocUtil.GetLocalizeResStr(6177),
    nInitSelectCount = nShowSelectCount or 1,
    bIsHideAddMaxBtn = true,
    nShowAddCount = 10,
    bIsHideUpperLimitText = true,
    fExchangeCallback = function(tExchange, nSelectCount)
      local nGoodsID = CommonItemBuySystem.GetBuyGoodsIDByItemID(tExchange.itemId)
      if nGoodsID <= 0 then
        return
      end
      local nTotalPrice = nSelectCount * tExchange.needItemNum
      if nTotalPrice > DataMgr.ticket then
        local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
        CommonPayBoxMgr.ShowUcRechargeMsg(nTotalPrice)
        return
      end
      CommonItemBuySystem.send_easy_buy_req(nGoodsID, nSelectCount)
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Exchange_Confirm_UIBP, tExchangeData, tExtra)
end
function CommonItemBuySystem.GetCfgName()
  local sCfgName = "EasyBuyCfg"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    sCfgName = "EasyBuyCfg_JK"
  end
  return sCfgName
end
function CommonItemBuySystem.GetBuyCfgByItemID(nItemId)
  local uCfg = CDataTable.GetTableDataByFilter(CommonItemBuySystem.GetCfgName(), "itemid", nItemId)
  return uCfg
end
function CommonItemBuySystem.GetBuyGoodsIDByItemID(itemd_id)
  local uCfg = CommonItemBuySystem.GetBuyCfgByItemID(itemd_id)
  if not uCfg then
    return 0
  end
  return uCfg.id
end
function CommonItemBuySystem.GetBuyGoodsCfgByGoodsID(goods_id)
  if not goods_id then
    return nil
  end
  local uCfg = CDataTable.GetTableData(CommonItemBuySystem.GetCfgName(), goods_id)
  return uCfg
end
function CommonItemBuySystem.GetHasUseLimitByItemID(itemd_id)
  local goodsID = CommonItemBuySystem.GetBuyGoodsIDByItemID(itemd_id)
  if goodsID and CommonItemBuySystem.limits_table and CommonItemBuySystem.limits_table[goodsID] then
    return tonumber(CommonItemBuySystem.limits_table[goodsID])
  end
  return 0
end
function CommonItemBuySystem.GetMaxLimitByItemID(itemd_id)
  local buyCfg = CommonItemBuySystem.GetBuyCfgByItemID(itemd_id)
  if buyCfg and buyCfg.limit and buyCfg.limit > 0 then
    return buyCfg.limit
  end
  return 999
end
function CommonItemBuySystem.GetCurLimitByItemID(itemd_id)
  local max = CommonItemBuySystem.GetMaxLimitByItemID(itemd_id)
  local hasUse = CommonItemBuySystem.GetHasUseLimitByItemID(itemd_id)
  return max - hasUse
end
function CommonItemBuySystem.send_easy_buy_req(id, num, need_show_result, exchange_itemid)
  log(bWriteLog and "CommonItemBuySystem.send_easy_buy_req, id:" .. tostring(id) .. ", num:" .. tostring(num))
  if need_show_result == nil then
    CommonItemBuySystem.need_show_result = true
  else
    CommonItemBuySystem.  end
  local EasyBuyHandler = require("client.network.Protocol.EasyBuyHandler")
  EasyBuyHandler.send_easy_buy_req(id, num, exchange_itemid)
end
function CommonItemBuySystem.on_easy_buy_res(id, cnt)
  log(bWriteLog and "CommonItemBuySystem.on_easy_buy_res, id:" .. tostring(id) .. ", cnt:" .. cnt)
  local buyCfg = CommonItemBuySystem.GetBuyGoodsCfgByGoodsID(id)
  if buyCfg == nil then
    return
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_COMMON_ITEM_BUY_SUC, {id = id, count = cnt})
  if CommonItemBuySystem.need_show_result then
    local arrayItemList = {}
    local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
    local isChar = CharacterUtils:CheckIsCharacterId(buyCfg.itemid)
    local bCheckSpecialItem = true
    if isChar then
      arrayItemList = CharacterUtils:GetDefaultItemListByCharacterId(buyCfg.itemid)
      table.insert(arrayItemList, 1, {
        res_id = buyCfg.itemid,
        count = 1
      })
      bCheckSpecialItem = false
    elseif buyCfg.is_box == 1 then
      local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
      local dropList = BasicDataChestTable:GetCacheData(buyCfg.itemid)
      if dropList and next(dropList) then
        for _, v in pairs(dropList) do
          table.insert(arrayItemList, {
            res_id = v.DropItemID,
            count = v.DropItemNum
          })
        end
      end
    else
      table.insert(arrayItemList, {
        res_id = buyCfg.itemid,
        count = cnt
      })
    end
    if arrayItemList and 0 < #arrayItemList then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, bCheckSpecialItem)
    end
  end
end
function CommonItemBuySystem.on_update_easy_buy_limits(limits_table)
  log_tree("CommonItemBuySystem.on_update_easy_buy_limits limits_table: ", limits_table)
  CommonItemBuySystem.end
function CommonItemBuySystem.on_easy_buy_fail(err, id, cnt)
  CommonItemBuySystem.ShowErrorTips(err)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_COMMON_ITEM_BUY_FAIL, {
    err = err,
    id = id,
    count = cnt
  })
end
function CommonItemBuySystem.ShowErrorTips(error_id)
  local TextData = LocUtil.GetLocalizeResStr(error_id)
  if TextData ~= "" then
    ShowNotice(TextData)
  else
    ShowNotice(error_id)
  end
end
return CommonItemBuySystem