local supply_optional_data = {}
local TimeUtil = require("client.common.time_util")
local SupplyOptionalHandler = require("client.network.Protocol.SupplyOptionalHandler")
local StoreUtils = require("client.slua.logic.store.utils.store_utils")
function supply_optional_data:DefineAndResetData()
  self.characterBoxIdList = {}
  self.optional_item_info = {}
  self.must_reward_info = {}
  self.must_reward_resid = {}
  self.curSupplyId = 0
  self.wait_decompose_list = {}
  self.bInitExchangeData = false
  self.rawExchangeData = nil
  self.exchangeList = nil
end
function supply_optional_data:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CHARACTER_EXCHANGE, self.JumpToCharacterSystemExchangeShop)
end
function supply_optional_data:InitExchangeRawData(exchangeItems)
  if self.bInitExchangeData then
    return
  end
  self.exchangeHistory = {}
  self.currencyList = {}
  self.rawExchangeData = exchangeItems
  self.bInitExchangeData = true
end
function supply_optional_data:InitExchangeList(exchangeItems)
  if not exchangeItems then
    return
  end
  self.exchangeList = {}
  local currencyList = {}
  for itemId, data in pairs(exchangeItems) do
    if data.start_time and data.start_time > 0 then
      local itemConfig = CDataTable.GetTableData("item", itemId)
      table.insert(self.exchangeList, {
        shopId = itemId,
        itemId = itemId,
        count = 1,
        limitBuyCount = 1,
        itemConfig = itemConfig,
        shopConfig = data
      })
      for currencyId, _ in pairs(data.consume_items) do
        if not currencyList[currencyId] then
          currencyList[currencyId] = true
        end
      end
    end
  end
  for currencyId, _ in pairs(currencyList) do
    table.insert(self.currencyList, currencyId)
  end
  table.sort(self.currencyList, function(a, b)
    return a < b
  end)
  self.bInitExchangeData = false
end
function supply_optional_data:SetExchangeHistory(exchangeHistory)
  self.end
function supply_optional_data:SetCharacterBoxIdList(ID)
  if not self.characterBoxIdList[ID] then
    self.characterBoxIdList[ID] = true
  end
end
function supply_optional_data:SetOptionalItemInfo(supplyId, temp_optional_item_info)
  self.optional_item_info[supplyId] = temp_optional_item_info
end
function supply_optional_data:SetMustRewardInfo(supplyId, must_reward_info)
  self.must_reward_info[supplyId] = must_reward_info
end
function supply_optional_data:SetMustRewardResid(supplyId, must_reward_resid)
  self.must_reward_resid[supplyId] = must_reward_resid
end
function supply_optional_data:OnExchange(itemId)
  self.exchangeHistory[tostring(itemId)] = true
end
function supply_optional_data:SetCurSupplyId(supplyId)
  self.curSupplyId = supplyId
end
function supply_optional_data:SetWaitDecomposeList(wait_decompose_list)
  self.wait_decompose_list = wait_decompose_list or {}
end
function supply_optional_data:IsCharacterBox(ID)
  return self.characterBoxIdList[ID]
end
function supply_optional_data:GetOptionalItemInfo(supplyId)
  return self.optional_item_info[supplyId]
end
function supply_optional_data:GetMustRewardInfo(supplyId)
  return self.must_reward_info[supplyId]
end
function supply_optional_data:GetMustRewardResid(supplyId)
  return self.must_reward_resid[supplyId]
end
function supply_optional_data:CheckExchanged(itemId)
  local bExchange = self.exchangeHistory[tostring(itemId)]
  return bExchange and 1 or 0
end
function supply_optional_data:GetExchangeList()
  if not self.exchangeList and not self.bInitExchangeData then
    local CharacterHandler = require("client.network.Protocol.CharacterHandler")
    CharacterHandler.send_character_info_req()
    return {}
  elseif self.bInitExchangeData then
    self:InitExchangeList(self.rawExchangeData)
  end
  return self.exchangeList
end
function supply_optional_data:GetCurrencyList()
  return self.currencyList or {}
end
function supply_optional_data:CheckCharacterSystemCanExchange(itemId)
  self:GetExchangeList()
  local data = self.rawExchangeData and self.rawExchangeData[itemId]
  if not data then
    return true
  end
  return self:CheckExchangeItemTimeValid(data.start_time, data.end_time)
end
function supply_optional_data:CheckExchangeItemTimeValid(beginTime, endTime)
  if beginTime and 0 < beginTime and endTime and 0 < endTime then
    local curTime = TimeUtil.GetServerTimeInSec()
    return beginTime <= curTime and endTime >= curTime
  elseif beginTime and 0 < beginTime then
    return beginTime <= TimeUtil.GetServerTimeInSec()
  end
  return false
end
function supply_optional_data:GetCurSupplyId()
  return self.curSupplyId
end
function supply_optional_data:CheckWaitDecompose(itemId)
  for index, item in pairs(self.wait_decompose_list or {}) do
    if item.resid == itemId then
      return index
    end
  end
  return nil
end
function supply_optional_data:JumpToCharacterSystemExchangeShop(_, url_params)
  SupplyOptionalHandler.send_get_role_exchange_history_info_req()
  UIManager.ShowUI(UIManager.UI_Config.supply_optional_exchange, tonumber(url_params.itemId), tonumber(url_params.characterId))
end
function supply_optional_data:BuyCharacterBox(exchangeItemId, price_type, draw_type, couponId, realPrice)
  if exchangeItemId and 0 < exchangeItemId then
    price_type = exchangeItemId
  elseif price_type and 0 < price_type then
    price_type = StoreUtils.MoneyTypeToFiveMoneyType(price_type)
  end
  SupplyOptionalHandler.send_role_chest_custom_buy_req({
    price_type = price_type,
    draw_type = draw_type,
    coupon_id = couponId,
    real_price = realPrice
  })
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, supply_optional_data)
return CModuleTemplate