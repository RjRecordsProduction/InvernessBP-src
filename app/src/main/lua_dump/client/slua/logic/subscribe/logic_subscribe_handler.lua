local logic_subscribe_handler = {}
function logic_subscribe_handler.GetSubscribeModuleObj()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_korea)
  else
    return ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_global)
  end
end
function logic_subscribe_handler.GetIsBuyPrimeAndPrice()
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local tItemInfo = subscribeModuleObj:Get_Discount_Item_Info()
  if not tItemInfo then
    log(bWriteLog and "logic_subscribe_handler.GetIsBuyPrimeAndPrice tItemInfo is nil")
    return false
  end
  if subscribeModuleObj:IsBuyPrime() then
    local priceData = {
      ori_price = tItemInfo.ori_price or 0,
      final_price = tItemInfo.sale_price or 0,
      discount = tItemInfo.ori_price and tItemInfo.sale_price and math.floor((tItemInfo.ori_price - tItemInfo.sale_price) / tItemInfo.ori_price * 100) or 0
    }
    return true, priceData
  end
  return false
end
function logic_subscribe_handler.GetImmediateRewardsCfgBySubId(nSubId)
  local nAppId = Client.GetITopGameId()
  local uCurShowCfg = CDataTable.GetTableDataByFilter("SubscribeRewardDesc", "PrimeType", nSubId, "AppID", nAppId)
  if not uCurShowCfg then
    log(bWriteLog and "logic_subscribe_handler.GetImmediateRewardsCfgBySubId display configuration error => SubscribeRewardDesc " .. "not PrimeType = " .. nSubId .. " and not AppID = " .. nAppId .. " Data")
    return {}
  end
  return uCurShowCfg
end
function logic_subscribe_handler.GetPrivilegeShowData()
  local tShowSortData = {}
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubInfoID = SubscribeEnumConfig.ENUM_SubInfoID
  local ENUM_KoreaSubInfoID = SubscribeEnumConfig.ENUM_KoreaSubInfoID
  local tPrivilegeCfg = GlobalData.IsJapanOrKorea() and ENUM_KoreaSubInfoID or ENUM_SubInfoID
  for _, v in pairs(tPrivilegeCfg) do
    table.insert(tShowSortData, v)
  end
  table.sort(tShowSortData, function(a, b)
    if a == tPrivilegeCfg.SHARE_BAG then
      return true
    elseif b == tPrivilegeCfg.SHARE_BAG then
      return false
    else
      return a < b
    end
  end)
  return tShowSortData
end
function logic_subscribe_handler.IsShowDiscountItemRedDot(nId)
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubInfoID = SubscribeEnumConfig.ENUM_SubInfoID
  if nId ~= ENUM_SubInfoID.DISCOUNT_ITEM then
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return false
  end
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local ENUM_SubStatus = SubscribeEnumConfig.ENUM_SubStatus
  if subscribeModuleObj:GetSubStatus() < ENUM_SubStatus.SuperStatus then
    return false
  end
  if not subscribeModuleObj:Get_Discount_Is_Could_Buy() then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSubscribePanel) or {}
  local nLastTime = tLocalCache.nClickDiscountItemRedDotLastTime or 0
  local TimeUtil = require("client.common.time_util")
  local bIsShow = TimeUtil.IsSameDay(nLastTime, TimeUtil.GetServerTimeInSec())
  return not bIsShow
end
return logic_subscribe_handler