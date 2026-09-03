local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.IsPremiumCrate(shop_id)
  if not shop_id then
    return false
  end
  if GlobalData.IsJapanOrKorea() then
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
      return StoreUtils.IsPremiumCrateOfJP(shop_id)
    else
      return StoreUtils.IsPremiumCrateOfKR(shop_id)
    end
  else
    return 101000 <= shop_id and shop_id <= 101999
  end
end
function StoreUtils.IsClassicCrate(shop_id)
  if not shop_id then
    return false
  end
  if GlobalData.IsJapanOrKorea() then
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
      return StoreUtils.IsCollectorCrateOfJP(shop_id)
    else
      return StoreUtils.IsCollectorCrateOfKR(shop_id)
    end
  else
    return 100001 <= shop_id and shop_id <= 100999
  end
end
function StoreUtils.IsActShopId(nShopId)
  if not nShopId then
    return false
  end
  local actMinId, actMaxId = StoreUtils.GetMinAndMaxActShopId()
  return nShopId >= actMinId and nShopId <= actMaxId
end
function StoreUtils.IsSupplyCrate(shop_id)
  if not shop_id then
    return false
  end
  if GlobalData.IsJapanOrKorea() then
    return false
  else
    return 102000 <= shop_id and shop_id <= 102999
  end
end
function StoreUtils.IsOpenJKCouponUse()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.JAPAN then
    return LobbySystem.CheckOpen(BP_ENUM_COUPON_JAPAN)
  elseif strRegion == PublishRegionMacros.KOREA then
    return LobbySystem.CheckOpen(BP_ENUM_COUPON_KOREA)
  else
    return true
  end
end
function StoreUtils.IsVanguardSupplyForGlobal(shop_id)
  if not shop_id then
    return false
  end
  local str_region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if str_region ~= PublishRegionMacros.JAPAN and str_region ~= PublishRegionMacros.KOREA then
    return shop_id == 11001 or shop_id == 11002 or shop_id == 11003
  end
end
function StoreUtils.GetMinAndMaxActShopId()
  local actMinId, actMaxId
  if GlobalData.IsJapanOrKorea() then
    actMinId = 104001
    actMaxId = 104999
  else
    actMinId = 103000
    actMaxId = 103999
  end
  return actMinId, actMaxId
end
function StoreUtils.GetMinAndMaxSTreasureShopId()
  local actMinId = 0
  local actMaxId = 0
  if GlobalData.IsJapanOrKorea() then
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.KR then
      actMinId = 206001
      actMaxId = 206999
    else
      actMinId = 202001
      actMaxId = 202999
    end
  end
  return actMinId, actMaxId
end
function StoreUtils.IsSkrTreasureBoxById(nShopID)
  local nMinId, nMaxId = StoreUtils.GetMinAndMaxSTreasureShopId()
  nShopID = tonumber(nShopID)
  if nShopID and nMinId <= nShopID and nMaxId >= nShopID then
    return true
  end
  return false
end
function StoreUtils.JumpToCommonExchangeStore(nItemID)
  local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", nItemID)
  if jumpConfig then
    log(bWriteLog and string.format("StoreUtils.JumpToCommonExchangeStore, jumpConfig.JumpExchangeUrl:%s", jumpConfig.JumpExchangeUrl))
    local actID = tonumber(string.match(jumpConfig.JumpExchangeUrl, "activityid=(%d+)"))
    local highLevelItemID = tonumber(string.match(jumpConfig.JumpExchangeUrl, "highLevelItemID=(%d+)"))
    local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
    LuckybackHandler.bShowCommonExchange = true
    LuckybackHandler.    local ShopSystem = require("client.logic.shop.logic_shop")
    ShopSystem.CommonExchangeId = actID
    LuckybackHandler.send_get_exchange_activity_info_req(actID)
    return true
  else
    log(bWriteLog and "[v_vyhhzhang] CurItem JumpConfig Lost: " .. tostring(nItemID))
    return false
  end
end
function StoreUtils.IsPremiumCrateOfJP(shop_id)
  return 203001 <= shop_id and shop_id <= 203999
end
function StoreUtils.IsPremiumCrateOfKR(shop_id)
  return 207001 <= shop_id and shop_id <= 207999
end
function StoreUtils.IsSurvivorCrateOfJP(shop_id)
  return 202001 <= shop_id and shop_id <= 202999
end
function StoreUtils.IsSurvivorCrateOfKR(shop_id)
  return 206001 <= shop_id and shop_id <= 206999
end
function StoreUtils.IsCollectorCrateOfJP(shop_id)
  return 201001 <= shop_id and shop_id <= 201999
end
function StoreUtils.IsCollectorCrateOfKR(shop_id)
  return 205001 <= shop_id and shop_id <= 205999
end
local JKSupplyTabDefaultIconConfig = {
  {
    min = 201001,
    max = 201999,
    path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_box_c.Store_int_box_c"
  },
  {
    min = 202001,
    max = 202999,
    path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_box_s.Store_int_box_s"
  },
  {
    min = 203001,
    max = 203999,
    path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_box_t.Store_int_box_t"
  },
  {
    min = 205001,
    max = 205999,
    path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_box_c.Store_int_box_c"
  },
  {
    min = 206001,
    max = 206999,
    path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_box_s.Store_int_box_s"
  },
  {
    min = 207001,
    max = 207999,
    path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_box_t.Store_int_box_t"
  }
}
local JKStoreTabDefaultIconConfig = {
  [StoreConst.Page_ID_Exchange] = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_banner_23.Store_int_banner_23",
  [StoreConst.Page_ID_Collect] = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_int_banner_24.Store_int_banner_24"
}
function StoreUtils.GetSubDefaultTabBgIconByJR(shop_id)
  if shop_id then
    for i, v in ipairs(JKSupplyTabDefaultIconConfig) do
      if shop_id >= v.min and shop_id <= v.max then
        return v.path
      end
    end
    if JKStoreTabDefaultIconConfig[shop_id] then
      return JKStoreTabDefaultIconConfig[shop_id]
    end
  end
  return ""
end
function StoreUtils.GetSupplyCouponScene(tabId)
  if not StoreUtils.IsOpenJKCouponUse() then
    return nil
  end
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  if StoreUtils.IsClassicCrate(tabId) then
    return CouponSystem._Enum_Scene._SupplyBox1
  elseif StoreUtils.IsPremiumCrate(tabId) then
    return CouponSystem._Enum_Scene._SupplyBox2
  elseif StoreUtils.IsActShopId(tabId) then
    return CouponSystem._Enum_Scene._SupplyBoxAct
  elseif StoreUtils.IsSkrTreasureBoxById(tabId) then
    return CouponSystem._Enum_Scene._SupplyBoxCst
  else
    local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
    if supply_optional_data:IsCharacterBox(tabId) then
      return CouponSystem._Enum_Scene._CharacterBox
    end
    return nil
  end
end
function StoreUtils.IsCSTSupply(tabId)
  if StoreUtils.IsClassicCrate(tabId) then
    return true
  elseif StoreUtils.IsPremiumCrate(tabId) then
    return true
  elseif StoreUtils.IsSkrTreasureBoxById(tabId) then
    return true
  else
    return false
  end
end