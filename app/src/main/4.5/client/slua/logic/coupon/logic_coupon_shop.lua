local StoreUtils = require("client.slua.logic.store.utils.store_utils")
local ShopCouponSystem = {
  Logic_ARRAY_CouponsMallID = {},
  CachedItemID_Reflect_ShopID = {},
  CachedCouponId_Reflect_ITEMID = {}
}
setmetatable(ShopCouponSystem, {
  __index = require("client.slua.logic.coupon.logic_coupon")
})
function ShopCouponSystem.OnSupplyDataUpdate(event_type, event_id, shopdata)
  if shopdata and shopdata.data and next(shopdata.data) then
    for i, v in pairs(shopdata.data) do
      if i == StoreConst.label_market_index_market_list then
        for shopid, vv in pairs(v) do
          if vv[StoreConst.label_item_index_voucher] and next(vv[StoreConst.label_item_index_voucher]) then
            ShopCouponSystem.Logic_ARRAY_CouponsMallID[shopid] = vv[StoreConst.label_item_index_voucher]
          end
        end
      end
    end
  end
  log_tree("ShopCouponSystem.Logic_ARRAY_CouponsMallID", ShopCouponSystem.Logic_ARRAY_CouponsMallID)
end
function ShopCouponSystem.IsShopSoldCouponID(id)
  local itemcfg = CDataTable.GetTableData("Item", id)
  if not itemcfg or itemcfg.ItemSubType ~= 1607 then
    return false
  end
  if not ShopCouponSystem._Ori_Coupon_List or not next(ShopCouponSystem._Ori_Coupon_List) then
    log_error("no ShopCouponSystem._Ori_Coupon_List ")
    return false
  end
  if ShopCouponSystem._Ori_Coupon_List[id] then
    return true
  end
  return false
end
function ShopCouponSystem.CachedCouponID_Reflect_ItemID(res)
  if res and next(res) then
    for i, v in pairs(res) do
      ShopCouponSystem.CachedItemID_Reflect_ShopID[v.item_id] = i
      if v.voucher and next(v.voucher) then
        for i, vv in pairs(v.voucher) do
          if ShopCouponSystem.CachedCouponId_Reflect_ITEMID[vv] == nil then
            ShopCouponSystem.CachedCouponId_Reflect_ITEMID[vv] = {}
          end
          table.insert(ShopCouponSystem.CachedCouponId_Reflect_ITEMID[vv], v.item_id)
        end
      end
    end
  end
  for i, v in pairs(ShopCouponSystem.CachedCouponId_Reflect_ITEMID) do
    log_tree("v", v)
    table.sort(v, function(a, b)
      local shopa = ShopCouponSystem.GetShopIDByItemId(a)
      local shopb = ShopCouponSystem.GetShopIDByItemId(b)
      if shopa and shopb then
        return shopa > shopb
      end
    end)
  end
end
function ShopCouponSystem.GetShopIDByItemId(itemid)
  if itemid then
    return ShopCouponSystem.CachedItemID_Reflect_ShopID[itemid]
  end
end
function ShopCouponSystem.GetReflectItemIdToJumpByCouponItemID(CouponItemID)
  log(bWriteLog and "GetReflectItemIdToJumpByCouponItemID")
  if CouponItemID and ShopCouponSystem.CachedCouponId_Reflect_ITEMID[CouponItemID] and next(ShopCouponSystem.CachedCouponId_Reflect_ITEMID[CouponItemID]) then
    for i, v in pairs(ShopCouponSystem.CachedCouponId_Reflect_ITEMID[CouponItemID]) do
      if not StoreUtils.IsPossessed(v) then
        return v
      end
    end
  end
end
function ShopCouponSystem.SetCurTabData(tab, subTab)
  ShopCouponSystem.CurShopTab = tab
  ShopCouponSystem.CurShopSubTab = subTab
end
function ShopCouponSystem.ClearCurTabData()
  ShopCouponSystem.CurShopTab = nil
  ShopCouponSystem.CurShopSubTab = nil
end
function ShopCouponSystem.GetCurShopTabIsShow()
  local list, result = {}, {}
  local isShow, num = false, 0
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local scene = ShopCouponSystem.GetCurShopScene()
  if scene then
    isShow = true
    list = ShopCouponSystem.GetCouponListByScene(scene) or {}
  end
  for i, v in pairs(list) do
    local itemList = WardrobeData:GetHallDepotItemListByResID(i)
    for k, info in pairs(itemList) do
      if DataMgr.IsValidTime(info.expireTS) then
        local temptable = {
          scenes = list[info.resID].scenes or {},
          value = list[info.resID].value or 0,
          price_limit = list[info.resID].price_limit or 0,
          expireTS = info.expireTS or 0,
          resID = info.resID,
          count = info.count or 0,
          isNew = info.isNew,
          insID = info.insID
        }
        table.insert(result, temptable)
        num = num + temptable.count
      end
    end
  end
  return isShow, result, num
end
function ShopCouponSystem.GetCurShopScene()
  if ShopCouponSystem.CurShopTab == StoreConst.Page_New_ID_Cloth then
    return ShopCouponSystem._Enum_Scene._ClothesBuy
  elseif StoreUtils.IsDirectBuyTab(ShopCouponSystem.CurShopTab) then
    return ShopCouponSystem._Enum_Scene._TresureBuy
  elseif StoreUtils.IsUCSpecialPackageTab(ShopCouponSystem.CurShopTab, ShopCouponSystem.CurShopSubTab) then
    return ShopCouponSystem._Enum_Scene._UCGiftBag
  elseif StoreUtils.IsSubscribeLimitTab(ShopCouponSystem.CurShopTab, ShopCouponSystem.CurShopSubTab) then
    return ShopCouponSystem._Enum_Scene._SubscribeLimit
  end
  return nil
end
function ShopCouponSystem.IsKrJpTreasure()
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  if ShopCouponSystem.CurShopTab == StoreConst.Page_ID_Item then
    return true
  else
    return false
  end
end
function ShopCouponSystem.ShowBuyWindowByItemID(itemid)
  local JumpUtils = require("client.logic.store.jump_utils")
  if itemid then
    local shop_id = ShopCouponSystem.GetShopIDByItemId(itemid)
    if shop_id then
      local info = JumpUtils.FindJumpInfoFirst(itemid, JumpUtils.MODEL_ID_STORE)
      if info then
        info.bValid = false
        log_tree("ShopCouponSystem_jumpinfo ", info)
        local pageData = StoreConst.store_data[info.Tab1]
        if pageData then
          local buyInfo = pageData[StoreConst.label_market_index_market_list][shop_id]
          if buyInfo then
            log_tree("ShopCouponSystem_buyInfo", buyInfo)
            local priceInfo = StoreUtils.GetExchangeMoneyInfo(buyInfo[StoreConst.label_item_index_price_list])
            if priceInfo then
              local shopInfo = StoreUtils.ConvertToShopInfo(buyInfo, info.Tab1, info.Tab2)
              if shopInfo then
                log_tree("shopinfo", shopInfo)
                local issoldout = StoreUtils.IsSoldOut(shopInfo.id, shopInfo.daily_buy_limit, shopInfo.week_buy_limit, shopInfo.permanet_buy_limit)
                if not issoldout then
                  StoreUtils.PurchaseItem(shopInfo, 2)
                end
              end
            end
          end
        end
      end
    end
  end
end
function ShopCouponSystem.GetPlayerHasCoupons()
  local OwnCoupons = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  for k, v in pairs(arrayHallDepotItemInfo) do
    if ShopCouponSystem._Ori_Coupon_List[v.resID] and DataMgr.IsValidTime(v.expireTS) then
      table.insert(OwnCoupons, v.resID)
    end
  end
  return OwnCoupons
end
function ShopCouponSystem.IsCouPonsShopItem(shopid)
  log_tree("Logic_ARRAY_CouponsMallID", ShopCouponSystem.Logic_ARRAY_CouponsMallID)
  log(bWriteLog and "zino shopid  " .. shopid)
  local playerowncouponIDList = ShopCouponSystem.GetPlayerHasCoupons()
  if not playerowncouponIDList and not next(playerowncouponIDList) then
    return false
  else
    for k, v in pairs(playerowncouponIDList) do
      if ShopCouponSystem.Logic_ARRAY_CouponsMallID[shopid] then
        for kk, vv in pairs(ShopCouponSystem.Logic_ARRAY_CouponsMallID[shopid]) do
          if v == vv then
            log(bWriteLog and "IsCouPonsShopItem_true----------")
            return true
          end
        end
      else
        return false
      end
    end
  end
end
function ShopCouponSystem.GetDisCountValueByID(id)
  return ShopCouponSystem._Ori_Coupon_List[id].value or -1
end
function ShopCouponSystem.Get_Cur_Coupon_CouldUse_List(shopid)
  local CouponDataList = {}
  local playerowncouponIDList = ShopCouponSystem.GetPlayerHasCoupons()
  log_tree("ShopCouponSystem.Logic_ARRAY_CouponsMallID", ShopCouponSystem.Logic_ARRAY_CouponsMallID)
  for k, v in pairs(playerowncouponIDList) do
    if ShopCouponSystem.Logic_ARRAY_CouponsMallID[shopid] then
      for kk, vv in pairs(ShopCouponSystem.Logic_ARRAY_CouponsMallID[shopid]) do
        if v == vv then
          log(bWriteLog and "true---------------------------------------------------")
          local price = ShopCouponSystem.GetDisCountValueByID(vv)
          local describe = LocUtil.LocalizeResFormat(6611, price)
          local tempCouponData = {
            ID = vv,
            discount = price,
                      }
          table.insert(CouponDataList, tempCouponData)
        end
      end
    end
    if ShopCouponSystem.CurShopTab == StoreConst.Page_New_ID_Cloth then
      log(bWriteLog and "StoreGeneralPage.tabId " .. tostring(ShopCouponSystem.CurShopTab))
      local Scene_Coupon_List = ShopCouponSystem.GetCouponListByScene(ShopCouponSystem._Enum_Scene._ClothesBuy)
      local itemcfg = CDataTable.GetTableData("Item", v)
      if itemcfg and itemcfg.ItemSubType ~= 1607 and Scene_Coupon_List[v] then
        local price = ShopCouponSystem.GetDisCountValueByID(v)
        if 0 <= price then
          local describe = LocUtil.LocalizeResFormat(6611, price)
          local tempCouponData = {
            ID = v,
            discount = price,
                      }
          table.insert(CouponDataList, tempCouponData)
        end
      end
    end
    if StoreUtils.IsDirectBuyTab(ShopCouponSystem.CurShopTab) or StoreUtils.IsUCSpecialPackageTab(ShopCouponSystem.CurShopTab, ShopCouponSystem.CurShopSubTab) or StoreUtils.IsSubscribeLimitTab(ShopCouponSystem.CurShopTab, ShopCouponSystem.CurShopSubTab) then
      local Scene_Coupon_List = ShopCouponSystem.GetCouponListByScene(ShopCouponSystem._Enum_Scene._TresureBuy)
      if Scene_Coupon_List and next(Scene_Coupon_List) then
        local itemcfg = CDataTable.GetTableData("Item", v)
        if itemcfg and itemcfg.ItemSubType ~= 1607 and Scene_Coupon_List[v] then
          local price = ShopCouponSystem.GetDisCountValueByID(v)
          if 0 <= price then
            local describe = LocUtil.LocalizeResFormat(6611, price)
            local tempCouponData = {
              ID = v,
              discount = price,
                          }
            table.insert(CouponDataList, tempCouponData)
          end
        end
      end
    end
  end
  local StoreGeneralPage = UIManager.GetUI(UIManager.UI_Config.StoreGeneralPage)
  if StoreGeneralPage and StoreGeneralPage.tabId then
    log(bWriteLog and "StoreGeneralPage.tabId " .. tostring(StoreGeneralPage.tabId))
    if StoreGeneralPage.tabId == StoreConst.Page_New_ID_Cloth then
      ShopCouponSystem.IsShowCouponAndShowCouponList(ShopCouponSystem._Enum_Scene._ShopBuy)
    end
  end
  table.sort(CouponDataList, function(a, b)
    return a.discount < b.discount
  end)
  log_tree("CouponDataList", CouponDataList)
  return CouponDataList
end
function ShopCouponSystem.Get_Shop_Coupon_CouldUse_List(shopid)
  local CouponDataList = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local AddCoupon = function(itemId)
    local itemDatas = wardrobe_data:GetHallDepotItemListByResID(itemId)
    for index, itemData in pairs(itemDatas) do
      if itemData and next(itemData) then
        local couponData = ShopCouponSystem.GetCouponInfoByItemId(itemId)
        table.insert(CouponDataList, {
          insID = itemData.insID,
          resID = itemId,
          item_id = itemId,
          value = couponData.value or -1,
          ItemName = LocUtil.LocalizeResFormat(6611, couponData.value or -1),
          count = itemData.count,
          expireTS = itemData.expireTS,
          price_limit = couponData.price_limit or nil
        })
      end
    end
  end
  local voucherData = ShopCouponSystem.Logic_ARRAY_CouponsMallID[shopid]
  if voucherData and next(voucherData) then
    for index, itemId in pairs(voucherData) do
      AddCoupon(itemId)
    end
  end
  local scene = ShopCouponSystem.GetCurShopScene()
  if scene then
    local Scene_Coupon_List = ShopCouponSystem.GetCouponListByScene(scene) or {}
    for itemId, couponData in pairs(Scene_Coupon_List) do
      AddCoupon(itemId)
    end
  end
  table.sort(CouponDataList, function(a, b)
    return a.value < b.value
  end)
  if next(CouponDataList) then
    return true, CouponDataList
  else
    return false, CouponDataList
  end
end
function ShopCouponSystem.OnRecevedStoreData()
  log(bWriteLog and "ItemTipsMgr.OnRecevedStoreData()")
  if StoreUtils.DelayNetCo then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      local rs = coroutine.resume(StoreUtils.DelayNetCo)
      if not rs then
        log(bWriteLog and "OnRecevedStoreData")
      end
    end)
  end
end
function ShopCouponSystem.IsHaveCouldUseCoupon(shop_id, scene, price)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ishaveDaiJinCoupon = ShopCouponSystem.IsCouPonsShopItem(shop_id)
  local isHaveManJianCoupon = false
  local cur_scene_list = {}
  cur_scene_list = ShopCouponSystem.GetCouponListByScene(scene)
  if cur_scene_list then
    for i, v in pairs(cur_scene_list) do
      if ShopCouponSystem._Ori_Coupon_List[i] and price >= ShopCouponSystem._Ori_Coupon_List[i].price_limit then
        local isHave = wardrobe_data:HasValidItem(tonumber(i))
        if isHave then
          isHaveManJianCoupon = true
        end
      end
    end
  end
  return ishaveDaiJinCoupon or isHaveManJianCoupon or false
end
function ShopCouponSystem.GetMaxDiscountWithCouponList(finalPrice, CouponList)
  local maxDiscountValue = 0
  for i, disInfo in ipairs(CouponList) do
    if disInfo.price_limit then
      if finalPrice >= disInfo.price_limit and maxDiscountValue < disInfo.value then
        maxDiscountValue = disInfo.value
      end
    elseif maxDiscountValue < disInfo.value then
      maxDiscountValue = disInfo.value
    end
  end
  if finalPrice < maxDiscountValue then
    maxDiscountValue = finalPrice
  end
  return maxDiscountValue
end
function ShopCouponSystem.CheckSpecialBox(itemData)
  if not itemData then
    return true
  end
  if itemData.lowestPriceList then
    for i, v in pairs(itemData.lowestPriceList) do
      if v.currency == StoreConst.label_price_type_uc and v.originalPrice > 0 then
        return itemData and (itemData.isPreferencesGift or itemData.isZeroUC)
      end
    end
  end
  return true
end
return ShopCouponSystem