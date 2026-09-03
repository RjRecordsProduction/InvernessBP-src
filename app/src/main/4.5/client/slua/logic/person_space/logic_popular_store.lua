local logic_popular_store = {}
function logic_popular_store:DefineAndResetData()
  self.exchange_info = nil
  self.exchange_shop_conf = nil
end
local _IsMatchVersionAndAppId = function(ver, app_ver_list)
  local version_util = require("client.common.version_util")
  local curVersion = Client.GetAppVersion()
  if not version_util.HigherVersion(curVersion, ver) then
    log(bWriteLog and "logic_popular_store:_IsMatchVersionAndAppId, return false and ver is:" .. tostring(actData.cli_ver_str) .. ";curVersion is: " .. tostring(curVersion))
    return false
  end
  local gameId = Client.GetITopGameId()
  if app_ver_list then
    if app_ver_list[gameId] then
      return true
    end
    log_tree(bWriteLog and "_IsMatchVersionAndAppId return false, app_ver_list is:", app_ver_list)
    return false
  end
  return true
end
function logic_popular_store:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_POPULARITY_STORE, self.OnJumpStoreUI, self)
end
function logic_popular_store:OnLogOut()
  self:DefineAndResetData()
end
function logic_popular_store:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  end
end
function logic_popular_store:OnJumpStoreUI()
  log(bWriteLog and "logic_popular_store:OnJumpStoreUI")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    ShowNotice(33631)
    return
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local PopularityMacros = require("client.slua.logic.person_space.popularity_macro")
  RoleInfoPopularitySystem.OpenPopularityUI(tonumber(DataMgr.roleData.uid), PopularityMacros.ENUM_TAB_TYPE.Store)
end
function logic_popular_store:GetShowList()
  if not self.exchange_shop_conf then
    log(bWriteLog and "logic_popular_store:GetShowList not self.exchange_shop_conf")
    return {}
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local PopularityMacros = require("client.slua.logic.person_space.popularity_macro")
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local popularLevel = RoleInfoPopularitySystem.GetPopularityLevel(DataMgr.roleData.uid)
  local count = wardrobe_data:GetHallDepotItemCountByResID(PopularityMacros.COIN_ITEM_ID)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local showList = {}
  for k, v in pairs(self.exchange_shop_conf) do
    if _IsMatchVersionAndAppId(v.ver, v.app_ver_list) and curTime >= v.begin_timestamp and curTime < v.end_timestamp then
      v.itemID = k
      v.bEnoughCoin = count >= v.exchange_need_cnt
      v.bAllExchanged = v.buy_limit and self:GetItemExchangedCount(k) >= v.buy_limit or false
      v.bLock = v.devote_level_limit and popularLevel < v.devote_level_limit or false
      if v.bEnoughCoin and not v.bAllExchanged and not v.bLock then
        v.bCanExchange = true
      else
        v.bCanExchange = false
      end
      table.insert(showList, v)
    end
  end
  table.sort(showList, function(a, b)
    if a.bCanExchange ~= b.bCanExchange then
      return a.bCanExchange == true and b.bCanExchange == false
    elseif a.bCanExchange and b.bCanExchange then
      return (a.serial_no or 0) > (b.serial_no or 0)
    elseif a.bAllExchanged == b.bAllExchanged then
      return (a.serial_no or 0) > (b.serial_no or 0)
    else
      return a.bAllExchanged == false and b.bAllExchanged == true
    end
  end)
  return showList
end
function logic_popular_store:GetItemExchangedCount(itemID)
  if self.exchange_info and self.exchange_info[itemID] then
    return self.exchange_info[itemID]
  end
  return 0
end
function logic_popular_store:CheckNeedRequestPKLevel()
  if not self.exchange_shop_conf then
    log(bWriteLog and "logic_popular_store:CheckNeedRequestPKLevel not self.exchange_shop_conf")
    return false
  end
  for k, v in pairs(self.exchange_shop_conf) do
    if v.unlock_pk_level and v.unlock_pk_level ~= 0 then
      log(bWriteLog and "logic_popular_store:CheckNeedRequestPKLevel find limit item, ID = " .. tostring(k))
      return true
    end
  end
  log(bWriteLog and "logic_popular_store:CheckNeedRequestPKLevel not limit item")
  return false
end
function logic_popular_store:GetCurPKLevel()
  return self.pk_level or 0
end
function logic_popular_store:OnGetShopInfoRsp(exchange_info, exchange_shop_conf)
  self.  self.  EventSystem:postEvent(EVENTTYPE_POPULAR_STORE, EVENTID_POPULAR_STORE_GET_STORE_INFO_RSP)
end
function logic_popular_store:OnExchangeInfoNotify(exchange_info)
  self.  EventSystem:postEvent(EVENTTYPE_POPULAR_STORE, EVENTID_POPULAR_STORE_EXCHANGE_INFO_NOTIFY)
end
function logic_popular_store:OnPKLevelRsp(pk_level)
  self.  EventSystem:postEvent(EVENTTYPE_POPULAR_STORE, EVENTID_POPULAR_STORE_PK_LEVEL_RSP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_store = class(CModuleBase, nil, logic_popular_store)
return Clogic_popular_store