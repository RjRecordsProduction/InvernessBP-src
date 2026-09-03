local collect_limit_module = {}
function collect_limit_module:DefineAndResetData()
  self.limit_buy_priv = {}
  self.itemID2LimitTimes = {}
  self.shopID2LimitTimes = {}
end
function collect_limit_module:OnInitialize()
  self.limit_buy_priv = {}
end
function collect_limit_module:OnLogOut()
  self.limit_buy_priv = {}
end
function collect_limit_module:on_get_collect_award_privilege_rsp(data)
  if data then
    self.limit_buy_priv = data.limit_buy_priv or {}
  end
  log_tree("get_collect_award_privilege_rsp limit_buy_priv", self.limit_buy_priv)
end
function collect_limit_module:GetLimitBuyPrivilegeInfo()
  return self.limit_buy_priv or {}
end
function collect_limit_module:CheckBuyPrivilegeEffective()
  local result = false
  local validTime = self.limit_buy_priv.season_limit or 0
  log(bWriteLog and string.format("collect_limit_module:GetLimitBuyPrivilegeInfo validTime = %s", validTime))
  if validTime == 1 then
    result = true
  elseif 1 < validTime then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    if validTime >= serverTime then
      result = true
    end
  end
  return result
end
function collect_limit_module:GetLimitTimesByItemID(itemID)
  log(bWriteLog and string.format("collect_module:GetLimitTimesByItemID itemID = %s", itemID))
  if self.itemID2LimitTimes[itemID] then
    local data = self.itemID2LimitTimes[itemID]
    log(bWriteLog and string.format("collect_module:GetLimitTimesByItemID data.dailyAdd = %s\239\188\140 data.everyWeekAdd = %s", data.dailyAdd, data.everyWeekAdd))
    return data.dailyAdd, data.everyWeekAdd
  end
  local _dailyAdd, _everyWeekAdd = 0, 0
  log(bWriteLog and string.format("collect_module:GetLimitTimesByItemID itemID = %s", itemID))
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local list = collect_module:GetSplitTableByFilter("CollectLimitTimesConfig", collect_module.E_ColCfgMode.JK, "ItemID", itemID)
  for _, vv in pairs(list) do
    if 0 < vv.DailyAdd then
      _dailyAdd = vv.DailyAdd
    end
    if 0 < vv.EveryWeekAdd then
      _everyWeekAdd = vv.EveryWeekAdd
    end
  end
  self.itemID2LimitTimes[itemID] = {dailyAdd = _dailyAdd, everyWeekAdd = _everyWeekAdd}
  log(bWriteLog and string.format("collect_module:GetLimitTimesByItemID _dailyAdd = %s\239\188\140 _everyWeekAdd = %s", _dailyAdd, _everyWeekAdd))
  return _dailyAdd, _everyWeekAdd
end
function collect_limit_module:GetLimitTimesByShopID(shopID)
  if self.shopID2LimitTimes[shopID] then
    local data = self.shopID2LimitTimes[shopID]
    log(bWriteLog and string.format("collect_module:GetLimitTimesByItemID data.dailyAdd = %s\239\188\140 data.everyWeekAdd = %s", data.dailyAdd, data.everyWeekAdd))
    return data.dailyAdd, data.everyWeekAdd
  end
  local _dailyAdd, _everyWeekAdd = 0, 0
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local list = collect_module:GetSplitTableByFilter("CollectLimitTimesConfig", collect_module.E_ColCfgMode.JK, "ShopID", shopID)
  for _, vv in pairs(list) do
    if 0 < vv.DailyAdd then
      _dailyAdd = vv.DailyAdd
    end
    if 0 < vv.EveryWeekAdd then
      _everyWeekAdd = vv.EveryWeekAdd
    end
  end
  self.shopID2LimitTimes[shopID] = {dailyAdd = _dailyAdd, everyWeekAdd = _everyWeekAdd}
  return _dailyAdd, _everyWeekAdd
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_limit_module)
return CModuleTemplate