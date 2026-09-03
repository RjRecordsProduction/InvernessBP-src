local StoreUtils = require("client.slua.logic.store.utils.store_utils")
local storeCurrencyRoot = {
  [StoreConst.label_price_type_bp] = "Btn_Gold",
  [StoreConst.label_price_type_chip] = "Btn_Silver",
  [StoreConst.label_price_type_uc] = "Btn_UC",
  [StoreConst.label_price_type_battle] = "Btn_Battle",
  [StoreConst.label_price_type_exchage] = "Button_NewDis",
  [StoreConst.label_price_type_gold_chip] = "Btn_GoldChip",
  [StoreConst.label_price_type_diamond] = "Button_Diamond",
  [StoreConst.label_price_type_fp] = "Btn_Zhupai",
  [StoreConst.label_price_type_season] = "Button_Season",
  [StoreConst.label_price_type_region_quartz] = "Button_Crystal",
  [StoreConst.label_price_type_allstar] = "Button_Esport",
  [StoreConst.lobel_price_itemID_pet_exchange_coin] = "Button_Exchange"
}
local voucherCfg = {
  best = {
    fragment = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_Icon_jipinsuipian_png.Shop_Icon_jipinsuipian_png",
    whole = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_Icon_jipin_png.Shop_Icon_jipin_png",
    tipsStr = 31072
  },
  collection = {
    fragment = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_Icon_diancangsuipian_png.Shop_Icon_diancangsuipian_png",
    whole = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_Icon_diancang_png.Shop_Icon_diancang_png",
    tipsStr = 31073
  },
  supply = {
    fragment = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_Icon_bujisuipian_png.Shop_Icon_bujisuipian_png",
    whole = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_Icon_buji_png.Shop_Icon_buji_png",
    tipsStr = 31074
  },
  character = {tipsStr = 157126}
}
local currencyGroup = {
  best = {
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_exchage
  },
  collection = {
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_exchage
  },
  supply = {
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_exchage,
    StoreConst.label_price_type_diamond
  },
  act = {
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_diamond
  },
  vanguard = {
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_bp
  },
  banner = {
    StoreConst.label_price_type_uc
  },
  character = {
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_exchage
  }
}
local storeCurrencyConfig, curZoneKey
local moneyComponentSystem = {}
moneyComponentSystem.CurrencyGroup = currencyGroup
moneyComponentSystem.StoreCurrencyRoot = storeCurrencyRoot
moneyComponentSystem.Tab_Vehicle_Refit_Save = 100
function moneyComponentSystem.GetCurrencyGroupByShopID(shopID, isActivity)
  if StoreUtils.IsPremiumCrate(shopID) then
    return currencyGroup.best, voucherCfg.best
  elseif StoreUtils.IsClassicCrate(shopID) then
    return currencyGroup.collection, voucherCfg.collection
  elseif StoreUtils.IsSupplyCrate(shopID) then
    return currencyGroup.supply, voucherCfg.supply
  elseif StoreUtils.IsActShopId(shopID) then
    return currencyGroup.act
  elseif StoreUtils.IsVanguardSupplyForGlobal(shopID) then
    return currencyGroup.vanguard
  elseif isActivity then
    return currencyGroup.banner
  else
    local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
    if supply_optional_data:IsCharacterBox(shopID) then
      return currencyGroup.character, voucherCfg.character
    end
    return currencyGroup.act
  end
end
function moneyComponentSystem.CheckCouponShowForSupply(scene)
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local list = CouponSystem.GetChildCouponList(scene)
  if list and next(list) then
    return true
  end
  return false
end
function moneyComponentSystem.GetFragmentIDByCouponId(couponId)
  local cacheComposeConfig = CDataTable.GetTable("ItemCompose")
  if cacheComposeConfig then
    for i, v in pairs(cacheComposeConfig) do
      if couponId == v.CstItemID then
        return v.ItemID
      end
    end
  end
  return nil
end
function moneyComponentSystem.GetStoreCurrencyConfig()
  local storeHandler = require("client.network.Protocol.StoreHandler")
  storeHandler.send_get_market_support_currency_req()
end
function moneyComponentSystem.RspStoreCurrencyConfig(info, zone_key)
  if info and type(info) == "table" then
    storeCurrencyConfig = info
    curZoneKey = zone_key
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_GET_CURRENCY_CONFIG)
  end
end
function moneyComponentSystem.GetStoreCurrencyGroup(tabID, subTabID)
  local data = moneyComponentSystem.GetCurrencyConfigByTab(tabID, subTabID)
  if not data.support_currency then
    return {}
  end
  local result = {}
  for i, coin in ipairs(data.support_currency) do
    local id = tonumber(coin) or -1
    table.insert(result, id)
  end
  return result
end
function moneyComponentSystem.GetCurrencyConfigByTab(tabID, subTabID)
  if not storeCurrencyConfig then
    moneyComponentSystem.GetStoreCurrencyConfig()
    return {}
  end
  local data = {}
  if storeCurrencyConfig[tabID] and storeCurrencyConfig[tabID][subTabID] then
    data = storeCurrencyConfig[tabID][subTabID]
    if type(data) ~= "table" then
      return {}
    end
    local TableUtil = require("common.table_util")
    if TableUtil.CountTable(data) > 1 then
      local key = curZoneKey or 0
      data = storeCurrencyConfig[tabID][subTabID][key] or {}
    else
      for i, v in pairs(storeCurrencyConfig[tabID][subTabID]) do
        data = v
        break
      end
    end
  end
  return data
end
function moneyComponentSystem.GetCrystalsIcon(tabID, subTabID)
  local def_icon, select_icon = "", ""
  local data = moneyComponentSystem.GetCurrencyConfigByTab(tabID, subTabID)
  def_icon = data.crystal_ICON or ""
  select_icon = data.crystal_selected_ICON or ""
  return def_icon, select_icon
end
function moneyComponentSystem.GetCrystalsID(tabID, subTabID)
  local data = moneyComponentSystem.GetCurrencyConfigByTab(tabID, subTabID)
  return data.crystal_ID
end
function moneyComponentSystem.ClearStoreCurrencyData()
  storeCurrencyConfig = nil
  curZoneKey = nil
end
return moneyComponentSystem