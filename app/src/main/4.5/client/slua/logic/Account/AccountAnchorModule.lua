local AccountAnchorModule = {}
local OperationType = {
  Recharge = "Recharge",
  SendGift = "SendGift",
  SendPopularity = "SendPopularity",
  PopularityExchange = "PopularityExchange"
}
local AnchorType = {
  None = 0,
  Influencer = 1,
  Event = 2,
  Exhibition = 3,
  Supplier = 4,
  InternalTest = 5,
  InternalDemo = 6
}
AccountAnchorModule.AccountAnchorModule.local LimitAnchorMap = {
  [OperationType.Recharge] = {
    [AnchorType.Influencer] = false,
    [AnchorType.Event] = false,
    [AnchorType.Exhibition] = false,
    [AnchorType.Supplier] = false
  },
  [OperationType.SendGift] = {
    [AnchorType.Influencer] = false,
    [AnchorType.Event] = false,
    [AnchorType.Exhibition] = false,
    [AnchorType.Supplier] = false,
    [AnchorType.InternalDemo] = false
  },
  [OperationType.SendPopularity] = {
    [AnchorType.Influencer] = false,
    [AnchorType.Event] = false,
    [AnchorType.Exhibition] = false,
    [AnchorType.Supplier] = false
  },
  [OperationType.PopularityExchange] = {
    [AnchorType.Influencer] = false,
    [AnchorType.Event] = false,
    [AnchorType.Exhibition] = false,
    [AnchorType.Supplier] = false
  }
}
function AccountAnchorModule:DefineAndResetData()
  self.PopularityDailyData = nil
  self.AnchorMap = nil
end
function AccountAnchorModule:OnInitialize()
  if self:IsSendPopularityLimitAccount() then
    local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
    PopularityGiftHandler.send_get_self_daily_pop_gift_req()
  end
end
function AccountAnchorModule:CanDoSomething(OperationType)
  if not self.AnchorMap then
    self:InitAnchorMap()
  end
  if not LimitAnchorMap[OperationType] then
    return true
  end
  local LimitOperationMap = LimitAnchorMap[OperationType]
  for AnchorType, _ in pairs(self.AnchorMap) do
    if LimitOperationMap[AnchorType] == false then
      return false
    end
  end
  return true
end
function AccountAnchorModule:CanRecharge()
  return self:CanDoSomething(OperationType.Recharge)
end
function AccountAnchorModule:CanSendGift()
  return self:CanDoSomething(OperationType.SendGift)
end
function AccountAnchorModule:IsSendPopularityLimitAccount()
  return self:CanDoSomething(OperationType.SendPopularity)
end
function AccountAnchorModule:CanExchangePopularity()
  return self:CanDoSomething(OperationType.PopularityExchange)
end
function AccountAnchorModule:CanSendPopularity()
  local bCanDoSomething = self:CanDoSomething(OperationType.SendPopularity)
  if bCanDoSomething then
    return true
  end
  return self:IsSendPopularityUnReachUpper()
end
function AccountAnchorModule:IsSendPopularityUnReachUpper()
  if not self.PopularityDailyData or not self.PopularityDailyData.update_time then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local lastUpdateTime = self.PopularityDailyData.update_time
  if not TimeUtil.IsToday(lastUpdateTime) then
    return true
  end
  local sendSummary = self.PopularityDailyData.daily_pop or 0
  if sendSummary < 4000 then
    return true
  end
  return false
end
function AccountAnchorModule:AddSendPopularityValue(InAddValue, InUpdateTime)
  if not self.PopularityDailyData then
    return
  end
  self.PopularityDailyData.daily_pop = self.PopularityDailyData.daily_pop or 0
  self.PopularityDailyData.daily_pop = self.PopularityDailyData.daily_pop + InAddValue
  self.PopularityDailyData.update_time = InUpdateTime
end
function AccountAnchorModule:GetAnchorTag()
  if not self.AnchorMap then
    self:InitAnchorMap()
  end
  local string = ""
  for AnchorType, _ in pairs(self.AnchorMap) do
    string = string .. AnchorType .. " "
  end
  return string
end
function AccountAnchorModule:on_get_self_daily_pop_gift_rsp(ret)
  self.PopularityDailyData = ret
end
function AccountAnchorModule:InitAnchorMap()
  self.AnchorMap = {}
  for _, Type in pairs(self.AnchorType) do
    if self:ExistsAnchor(Type) then
      self.AnchorMap[Type] = true
    end
  end
end
function AccountAnchorModule:ExistsAnchor(Type)
  if not DataMgr.anchor_origin then
    return false
  end
  local anchor_origin = math.tointeger(DataMgr.anchor_origin)
  local mask = 1 << Type - 1
  return anchor_origin & mask ~= 0
end
local Class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
local CAccountAnchorModule = Class(ModuleBase, nil, AccountAnchorModule)
return CAccountAnchorModule