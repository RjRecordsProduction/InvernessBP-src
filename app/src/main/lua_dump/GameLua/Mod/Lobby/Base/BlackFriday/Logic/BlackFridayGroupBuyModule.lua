local BlackFridayGroupBuyModule = {}
local TableUtil = require("common.table_util")
local BlackFridayMacros = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMacros")
function BlackFridayGroupBuyModule:DefineAndResetData()
  self.BasicInfo = nil
  self.Info = nil
  self.extra_discount = 0
  self.ProgressList = nil
end
function BlackFridayGroupBuyModule:HandleExtraData(extraData)
  self.BasicInfo = extraData.group_buy_info
end
function BlackFridayGroupBuyModule:DestroyGroupBuyInfo()
  self:DefineAndResetData()
end
function BlackFridayGroupBuyModule:GetGroupBuyInfo()
  return self.Info
end
local GetActOtherData = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByType(ActivityType.BlackFriday_GroupBuy)
  if not actData then
    return nil
  end
  return actData.other
end
function BlackFridayGroupBuyModule:GetPeriod()
  local otherData = GetActOtherData()
  if not otherData then
    return 0
  end
  return otherData.cur_period
end
function BlackFridayGroupBuyModule:GetEarlyBirdItemStatus()
  local otherData = GetActOtherData()
  if not otherData then
    return BlackFridayMacros.GroupBuy.EarlyBirdStatus.None
  end
  local ItemStatus = otherData.early_bird_item_status
  if not ItemStatus then
    return BlackFridayMacros.GroupBuy.EarlyBirdStatus.None
  end
  local cur_week = self:GetPeriod()
  return ItemStatus[cur_week]
end
local GetReturnUCInfo = function(week)
  local otherData = GetActOtherData()
  if not otherData then
    return nil
  end
  local returnUcInfo = otherData.return_uc_info
  if not returnUcInfo or not returnUcInfo[week] then
    return nil
  end
  return returnUcInfo[week]
end
local GetBuyItemInfo = function(week)
  local otherData = GetActOtherData()
  if not otherData then
    return nil
  end
  local buy_item_info = otherData.group_buy_item_info
  if not buy_item_info or not buy_item_info[week] then
    return nil
  end
  return buy_item_info[week]
end
function BlackFridayGroupBuyModule:GetLastWeekRebateNum()
  if not self.Info then
    return 0
  end
  local lastWeek = self:GetPeriod() - 1
  local returnUcInfo = GetReturnUCInfo(lastWeek)
  if not returnUcInfo then
    return 0
  end
  return returnUcInfo.return_uc
end
function BlackFridayGroupBuyModule:GetRebateNum()
  if not self.Info then
    return 0
  end
  local cur_week = self:GetPeriod()
  local returnUcInfo = GetReturnUCInfo(cur_week)
  if not returnUcInfo then
    return 0
  end
  return returnUcInfo.return_uc
end
function BlackFridayGroupBuyModule:GetProgressNum()
  local lastNode = self.ProgressList[#self.ProgressList]
  local num = self.Info.global_participation_info.current_num
  return math.min(lastNode.originInfo.low_boundary, math.ceil(num))
end
function BlackFridayGroupBuyModule:GetLastWeekProgressNum()
  if not self.Info then
    return 0
  end
  local lastWeek = self:GetPeriod() - 1
  local returnUcInfo = GetReturnUCInfo(lastWeek)
  if not returnUcInfo then
    return 0
  end
  return returnUcInfo.global_hot_value or 0
end
function BlackFridayGroupBuyModule:GetExtraDiscount()
  return self.extra_discount
end
function BlackFridayGroupBuyModule:GetLastWeekExtraDiscount()
  if not self.Info then
    return 0
  end
  local lastWeek = self:GetPeriod() - 1
  local returnUcInfo = GetReturnUCInfo(lastWeek)
  if not returnUcInfo then
    return 0
  end
  return returnUcInfo.global_discout or 0
end
function BlackFridayGroupBuyModule:GetGoodsBuyStatus(id)
  if not self.Info then
    return false
  end
  local cur_week = self:GetPeriod()
  local buy_item_info = GetBuyItemInfo(cur_week)
  if not buy_item_info or not buy_item_info[id] then
    return false
  end
  return true
end
function BlackFridayGroupBuyModule:GetRebateRecordList()
  local result = {}
  if not self.Info then
    return result
  end
  local cur_week = self:GetPeriod()
  local buy_item_info = GetBuyItemInfo(cur_week)
  if not buy_item_info then
    return result
  end
  local goods_info_list = TableUtil.GetTableValue(self.Info, "buy_item_list")
  for id, record in pairs(buy_item_info) do
    record.    local goodInfo = goods_info_list[id]
    record.count = goodInfo.count
    record.valid_hours = goodInfo.valid_hours
    record.buy_global_discount = record.buy_global_discount or 0
    record.extra_discount = record.extra_discount or 0
    result[#result + 1] = record
  end
  table.sort(result, function(a, b)
    return a.id < b.id
  end)
  return result
end
function BlackFridayGroupBuyModule:HandleProgressList()
  self.ProgressList = {}
  local show_info = self.Info.global_participation_info.show_info
  local last_low_boundary = 0
  for _, info in ipairs(show_info) do
    if info.low_boundary ~= 0 then
      self.ProgressList[#self.ProgressList + 1] = {originInfo = info, last_low_boundary = last_low_boundary}
      last_low_boundary = info.low_boundary
    end
  end
  return self.ProgressList
end
function BlackFridayGroupBuyModule:IsLastStage()
  if not self.ProgressList then
    return true
  end
  local lastNode = self.ProgressList[#self.ProgressList]
  local num = self.Info.global_participation_info.current_num
  return num >= lastNode.originInfo.low_boundary
end
function BlackFridayGroupBuyModule:GetNextDiscount()
  if not self.ProgressList then
    return 0
  end
  local num = self.Info.global_participation_info.current_num
  for _, progressInfo in ipairs(self.ProgressList) do
    if num < progressInfo.originInfo.low_boundary then
      return progressInfo.originInfo.discount
    end
  end
  return 0
end
function BlackFridayGroupBuyModule:GetLastDiscount()
  if not self.ProgressList then
    return 0
  end
  return self.ProgressList[#self.ProgressList].originInfo.discount
end
function BlackFridayGroupBuyModule:GetProgressList()
  return self.ProgressList
end
function BlackFridayGroupBuyModule:HandleExtraDiscount()
  local cur_num = self.Info.global_participation_info.current_num
  self.extra_discount = 0
  for _, ProgressInfo in ipairs(self.ProgressList) do
    if cur_num >= ProgressInfo.originInfo.low_boundary then
      self.extra_discount = ProgressInfo.originInfo.discount
    else
      break
    end
  end
end
function BlackFridayGroupBuyModule:CanClaimRebate(IsRed)
  local cur_week = self:GetPeriod()
  if not cur_week or cur_week == 0 then
    return false
  end
  local last_week = cur_week - 1
  local returnUcInfo = GetReturnUCInfo(last_week)
  if not returnUcInfo then
    return false
  end
  local rebateNum = returnUcInfo.return_uc
  if rebateNum == 0 then
    return false
  end
  local status = returnUcInfo.status
  if status == 1 then
    return false
  end
  local valid_status = returnUcInfo.valid_status
  if not valid_status then
    if not IsRed then
      ShowNotice(86393)
    end
    return false
  end
  return true
end
function BlackFridayGroupBuyModule:on_get_black_friday_group_buy_info_rsp(err_code, info)
  self.Info = info
  self:CheckRebateShow()
  self:HandleProgressList()
  self:HandleExtraDiscount()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GROUP_BUY_INFO_UPDATED)
end
function BlackFridayGroupBuyModule:on_black_friday_group_buy_global_notify(global_participation_info)
  if not self.Info then
    return
  end
  self.Info.  self:HandleExtraDiscount()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_POPUP_CLEAR)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GROUP_BUY_GLOBAL_INFO_UPDATED)
end
function BlackFridayGroupBuyModule:on_buy_black_friday_group_item_rsp(err_code, period_id, id, item_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local BlackFridayPopupUtil = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayPopupUtil")
  BlackFridayPopupUtil.Push({
    Func = Logic_CommonItemGet.ShowPanel_DefaultStyle,
    Params = {item_list},
    MustShow = true
  }, true)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GROUP_BUY_ITEM_UPDATED)
  self:UpdateGroupBuyRedDot()
end
function BlackFridayGroupBuyModule:on_get_black_friday_early_bird_item_rsp(err_code, item_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local BlackFridayPopupUtil = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayPopupUtil")
  BlackFridayPopupUtil.Push({
    Func = Logic_CommonItemGet.ShowPanel_DefaultStyle,
    Params = {item_list},
    MustShow = true
  }, true)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GROUP_BUY_EARLY_BIRD_UPDATED)
  self:UpdateGroupBuyRedDot()
end
function BlackFridayGroupBuyModule:on_get_black_friday_discount_reward_rsp(err_code, period_id, uc_count)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GROUP_BUY_TAKE_REBATE)
  self:UpdateGroupBuyRedDot()
end
function BlackFridayGroupBuyModule:CheckRebateShow()
  if not self:CanClaimRebate() then
    return
  end
  local BlackFridayPopupUtil = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayPopupUtil")
  BlackFridayPopupUtil.Push({
    UIConfig = UIManager.UI_Config.BlackFriday_GroupBuy_Rebate_UIBP
  }, true)
end
function BlackFridayGroupBuyModule:HasAnyAward()
  if self:CanClaimRebate(true) then
    return true
  end
  local Status = self:GetEarlyBirdItemStatus()
  if Status == BlackFridayMacros.GroupBuy.EarlyBirdStatus.Done then
    return true
  end
  return false
end
function BlackFridayGroupBuyModule:GetNextUpdateTime()
  if not self.BasicInfo then
    return
  end
  return self.BasicInfo[2].start_time
end
function BlackFridayGroupBuyModule:UpdateGroupBuyRedDot()
  local BlackFridayMacros = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMacros")
  local BlackFridayRedDotModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRedDotModule)
  BlackFridayRedDotModule:UpdateDirectRedDot(BlackFridayMacros.ActivityType.GroupBuy)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlackFridayGroupBuyModule = class(CModuleBase, nil, BlackFridayGroupBuyModule)
return CBlackFridayGroupBuyModule