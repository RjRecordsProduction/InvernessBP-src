local Logic_LukcyOptionalTurntable = {}
local old_actid_list = {
  [238253001] = true,
  [638253001] = true,
  [253247002] = true,
  [639253001] = true,
  [239253001] = true,
  [639253002] = true
}
function Logic_LukcyOptionalTurntable:DefineAndResetData()
  Logic_LukcyOptionalTurntable.__super.DefineAndResetData(self)
  self.tTurnTableActData = nil
  self.tPoolInfo = nil
  self.tPriceInfo = nil
  self.tExtraInfo = nil
  self.tAllPrizeInfo = {}
  self.tCacheOptionalPrize = {}
  self.tCacheOptionalPrizeByIndex = {}
  self.tCacheProgressPrize = {}
  self.tCachePlayAnimPoolData = {}
  self.tCacheFinalPrizeData = {}
  self.tGetRewardInfo = nil
  self.tDecomposeList = nil
  self.bIsShowDrawDesTips = true
  self.bIsShowChestDesTips = true
  self.bIsShowRandomSelectDrawTips = true
  self.bIsShowRandomSelectChestDesTips = true
end
function Logic_LukcyOptionalTurntable:OnInitialize()
  Logic_LukcyOptionalTurntable.__super.OnInitialize(self)
end
function Logic_LukcyOptionalTurntable:RegistEvents()
  Logic_LukcyOptionalTurntable.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnDataChangeList, self)
end
function Logic_LukcyOptionalTurntable:OnLogin(bReLogin)
  Logic_LukcyOptionalTurntable.__super.OnLogin(self, bReLogin)
end
function Logic_LukcyOptionalTurntable:SetIsJumpPlayDrawAnim(isJump)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tCacheLocal = {}
  tCacheLocal.isJumpoptionalAnim = isJump
  PlayerPrefsSystem.SaveTableToFile_N(tCacheLocal, PlayerPrefsSystem.ePlayerPrefsType.eLukcyOptionalJumpAnimation)
end
function Logic_LukcyOptionalTurntable:GetIsJumpPlayDrawAnim()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tCacheLocal = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLukcyOptionalJumpAnimation) or {}
  return tCacheLocal.isJumpoptionalAnim
end
function Logic_LukcyOptionalTurntable:GetOptionalTurntableActId()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tOptionalTurntable = ActivityNewSystem.GetActivityListByType(ActivityType.OPTIONAL_TURNTABLE)
  local TableUtil = require("common.table_util")
  local nActId = TableUtil.GetTableValue(tOptionalTurntable, 1, "ID")
  return nActId
end
function Logic_LukcyOptionalTurntable:GetOptionalTurntableActData()
  return self.tExtraInfo
end
function Logic_LukcyOptionalTurntable:GetOptionalNumInfo()
  if self.tExtraInfo and self.tExtraInfo.max_custom_list then
    local tPageInfo = {}
    local tMaxOptionNumInfo
    tMaxOptionNumInfo = self:GetFinalMaxOptionalNum()
    for i, v in pairs(tMaxOptionNumInfo) do
      tPageInfo[#tPageInfo + 1] = {custom_level = i, maxNum = v}
    end
    table.sort(tPageInfo, function(a, b)
      return a.custom_level > b.custom_level
    end)
    return tPageInfo
  end
  return
end
function Logic_LukcyOptionalTurntable:GetExtraOptionalNumInfo()
  if self.tExtraInfo and self.tExtraInfo.max_custom_list then
    local tPageInfo = {}
    for i, v in pairs(self.tExtraInfo.max_custom_list) do
      tPageInfo[#tPageInfo + 1] = {custom_level = i, maxNum = v}
    end
    table.sort(tPageInfo, function(a, b)
      return a.custom_level > b.custom_level
    end)
    return tPageInfo
  end
  return
end
function Logic_LukcyOptionalTurntable:GetFinalMaxOptionalNum()
  if not self.tExtraInfo then
    return
  end
  local TableUtil = require("common.table_util")
  local tMaxOptionNumInfo = TableUtil.CopyTable(self.tExtraInfo.max_custom_list)
  if not tMaxOptionNumInfo then
    return
  end
  local minKey
  for k in pairs(tMaxOptionNumInfo) do
    if minKey == nil or k < minKey then
      minKey = k
    end
  end
  if minKey then
    tMaxOptionNumInfo[minKey] = nil
    return tMaxOptionNumInfo
  end
  return
end
function Logic_LukcyOptionalTurntable:GetMaxOptionalNumByLevel(level)
  if not self.tExtraInfo or not self.tExtraInfo.max_custom_list then
    return 0
  end
  return self.tExtraInfo.max_custom_list[level]
end
function Logic_LukcyOptionalTurntable:GetProgressBoxMaxNum(draw_count)
  if not self.tExtraInfo or not self.tExtraInfo.progress_custom_count_list then
    return 0
  end
  return self.tExtraInfo.progress_custom_count_list[draw_count]
end
function Logic_LukcyOptionalTurntable:GetAllPrizeMaxOptionalNum()
  local nMaxOptionNum = 0
  if not self.tExtraInfo or not self.tExtraInfo.max_custom_list then
    return nMaxOptionNum
  end
  local tMaxOptionNumInfo
  tMaxOptionNumInfo = self:GetFinalMaxOptionalNum()
  for _, v in pairs(tMaxOptionNumInfo) do
    nMaxOptionNum = nMaxOptionNum + v
  end
  return nMaxOptionNum
end
function Logic_LukcyOptionalTurntable:GetProgressRewardList()
  if not self.tExtraInfo or not self.tExtraInfo.progress_reward_list then
    return
  end
  local tFinalProgressList = {}
  for key, value in pairs(self.tExtraInfo.progress_reward_list) do
    for _, v in pairs(value) do
      v.draw_count = key
    end
    tFinalProgressList[#tFinalProgressList + 1] = value
  end
  table.sort(tFinalProgressList, function(a, b)
    return a[1].draw_count < b[2].draw_count
  end)
  return tFinalProgressList
end
function Logic_LukcyOptionalTurntable:GetBoxRewardDataByDrawcount(draw_count)
  log(bWriteLog and "Logic_LukcyOptionalTurntable:GetBoxRewardDataByDrawcount  " .. tostring(draw_count))
  if not draw_count then
    return
  end
  local tAllBoxRewardList = self:GetProgressRewardList()
  for _, v in pairs(tAllBoxRewardList) do
    if v[1].draw_count == draw_count then
      return v
    end
  end
end
function Logic_LukcyOptionalTurntable:GetResetPoolCostInfo(nResetTimes)
  if self.tExtraInfo and self.tExtraInfo.reset_cost_info then
    return self.tExtraInfo.reset_cost_info[nResetTimes]
  end
  return
end
function Logic_LukcyOptionalTurntable:GetesetPoolCostInfoCount()
  if self.tExtraInfo and self.tExtraInfo.reset_cost_info then
    return #self.tExtraInfo.reset_cost_info
  end
  return 0
end
function Logic_LukcyOptionalTurntable:GetHasOptionalRewardData(custom_level)
  if not custom_level then
    return {}
  end
  if self.tCacheFinalPrizeData[custom_level] then
    return self.tCacheFinalPrizeData[custom_level]
  end
  local tActData = self.tTurnTableActData
  local tFinalRewardData = {}
  local tCurLevelRewardData = self:GetPrizeListByLevel(custom_level)
  for unique_id, _ in pairs(tActData.custom_item_list[custom_level]) do
    for _, v in pairs(tCurLevelRewardData) do
      if v.unique_id == unique_id then
        table.insert(tFinalRewardData, v)
        break
      end
    end
  end
  self.tCacheFinalPrizeData[custom_level] = tFinalRewardData
  return tFinalRewardData
end
function Logic_LukcyOptionalTurntable:GetProgressBoxDrawInfo(draw_count)
  if self.tTurnTableActData and self.tTurnTableActData.progress_reward_list then
    return self.tTurnTableActData.progress_reward_list[draw_count]
  end
  return
end
function Logic_LukcyOptionalTurntable:GetTotalDrawTimes()
  if self.tTurnTableActData and self.tTurnTableActData.total_draw_times then
    return self.tTurnTableActData.total_draw_times
  end
  return
end
function Logic_LukcyOptionalTurntable:GetProgressBoxNum()
  local nBoxNum = 0
  if self.tTurnTableActData and self.tTurnTableActData.progress_reward_list then
    for _, _ in pairs(self.tTurnTableActData.progress_reward_list) do
      nBoxNum = nBoxNum + 1
    end
  end
  return nBoxNum
end
function Logic_LukcyOptionalTurntable:GetRedQualityPrizeData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPrizeLevel = tLevelInfo[1].custom_level
  local tRedPrizeList = self:GetHasOptionalRewardData(nPrizeLevel)
  return tRedPrizeList
end
function Logic_LukcyOptionalTurntable:GetPinkQualityPrizeData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPrizeLevel = tLevelInfo[2].custom_level
  local tPinkPrizeList = self:GetHasOptionalRewardData(nPrizeLevel)
  return tPinkPrizeList
end
function Logic_LukcyOptionalTurntable:GetPurpleQualityPrizeData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPurplePrizeLevel = tLevelInfo[3].custom_level
  local tPurplePrizeList = self:GetHasOptionalRewardData(nPurplePrizeLevel)
  return tPurplePrizeList
end
function Logic_LukcyOptionalTurntable:GetBlueQualityPrizeData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nBluePrizeLevel = tLevelInfo[4].custom_level
  local tBluePrizeList = self:GetPrizeListByLevel(nBluePrizeLevel)
  local mergedData = {}
  for _, item in pairs(tBluePrizeList) do
    local resid = item.resid
    if not mergedData[resid] then
      mergedData[resid] = {
        resid = resid,
        custom_level = item.custom_level,
        weight = item.weight,
        count = item.count,
        unique_id = item.unique_id,
        no_need_consider_own = item.no_need_consider_own,
        not_add_chest_flag = item.not_add_chest_flag,
        valid_hours = item.valid_hours
      }
    else
      mergedData[resid].count = mergedData[resid].count + item.count
      mergedData[resid].weight = mergedData[resid].weight + item.weight
    end
  end
  local result = {}
  for _, item in pairs(mergedData) do
    table.insert(result, item)
  end
  return result
end
function Logic_LukcyOptionalTurntable:GetItemMinAndMaxCountByItemId(itemId)
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nBluePrizeLevel = tLevelInfo[4].custom_level
  local tBluePrizeList = self:GetPrizeListByLevel(nBluePrizeLevel)
  local tFilterItemById = {}
  for _, v in pairs(tBluePrizeList) do
    if v.resid == itemId then
      table.insert(tFilterItemById, v)
    end
  end
  local minCount = 1
  local maxCount = 1
  if #tFilterItemById == 1 then
    return tFilterItemById[1].count, tFilterItemById[1].count
  end
  for _, item in pairs(tFilterItemById) do
    if minCount > item.count then
      minCount = item.count
    end
    if maxCount < item.count then
      maxCount = item.count
    end
  end
  return minCount, maxCount
end
function Logic_LukcyOptionalTurntable:GetItemDataByItemId(itemId)
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nBluePrizeLevel = tLevelInfo[4].custom_level
  local tBluePrizeList = self:GetPrizeListByLevel(nBluePrizeLevel)
  local tFilterItemById = {}
  for _, v in pairs(tBluePrizeList) do
    if v.resid == itemId then
      table.insert(tFilterItemById, v)
    end
  end
  return tFilterItemById
end
function Logic_LukcyOptionalTurntable:IsHasOptionalReward()
  if not self.tTurnTableActData then
    return false
  end
  if not self.tTurnTableActData.custom_item_list or not next(self.tTurnTableActData.custom_item_list) then
    return false
  end
  return true
end
function Logic_LukcyOptionalTurntable:GetProgressCustomItemList(draw_count)
  if not draw_count then
    return
  end
  if not self.tTurnTableActData then
    return
  end
  local tProgressList = self.tTurnTableActData.progress_custom_item_list
  if not tProgressList or not next(tProgressList) then
    return
  end
  return tProgressList[draw_count]
end
function Logic_LukcyOptionalTurntable:GetProgressRewardStateInfo()
  if self.tTurnTableActData and self.tTurnTableActData.progress_reward_list then
    return self.tTurnTableActData.progress_reward_list
  end
  return
end
function Logic_LukcyOptionalTurntable:IsHasUseTenDrawDiscount()
  if not self.tTurnTableActData then
    return false
  end
  return self.tTurnTableActData.discount_used
end
function Logic_LukcyOptionalTurntable:GetCurFreeResetPoolTimes()
  if self.tTurnTableActData and self.tTurnTableActData.cur_free_reset_times then
    log(bWriteLog and "Logic_LukcyOptionalTurntable:GetCurFreeResetPoolTimes " .. tostring(self.tTurnTableActData.cur_free_reset_times))
    return self.tTurnTableActData.cur_free_reset_times
  end
  return 0
end
function Logic_LukcyOptionalTurntable:GetCurHasResetPoolTimes()
  if self.tTurnTableActData and self.tTurnTableActData.cur_reset_pool_times then
    return self.tTurnTableActData.cur_reset_pool_times
  end
  return 0
end
function Logic_LukcyOptionalTurntable:GetPrizeListByLevel(level)
  if not (self.tPoolInfo and self.tPoolInfo[1]) or not level then
    return
  end
  if self.tAllPrizeInfo[level] then
    return self.tAllPrizeInfo[level]
  end
  self.tAllPrizeInfo[level] = {}
  for _, v in pairs(self.tPoolInfo[1]) do
    if v.custom_level == level then
      table.insert(self.tAllPrizeInfo[level], v)
    end
  end
  return self.tAllPrizeInfo[level]
end
function Logic_LukcyOptionalTurntable:GetAllPrizeList()
  return self.tAllPrizeInfo
end
function Logic_LukcyOptionalTurntable:GetOneDrawPrice()
  local tUcPriceInfo = self.tPriceInfo[1]
  return tUcPriceInfo[1006].one_cost
end
function Logic_LukcyOptionalTurntable:GetTenDrawPrice()
  local tUcPriceInfo = self.tPriceInfo[1]
  return tUcPriceInfo[1006].ten_cost
end
function Logic_LukcyOptionalTurntable:GetTenDrawDiscountPrice()
  local tUcPriceInfo = self.tPriceInfo[1]
  return tUcPriceInfo[1006].discount_ten_cost
end
function Logic_LukcyOptionalTurntable:GetDailyFistDrawDisPrice()
  local tUcPriceInfo = self.tPriceInfo[1]
  return tUcPriceInfo[1006].discount_uc_cost
end
function Logic_LukcyOptionalTurntable:GetIsHasFirstDrawDis()
  return self.tExtraInfo.is_first_dis
end
function Logic_LukcyOptionalTurntable:ReqOptionakTurntableData()
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tCacheLocal = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLukcyOptionalReqActInfoTime) or {}
  local TimeUtil = require("client.common.time_util")
  local nCurServerTime = TimeUtil.GetServerTimeInSec()
  local nActId = self:GetOptionalTurntableActId()
  if not nActId then
    return
  end
  if not self.tExtraInfo then
    tCacheLocal.lastReqTime = nCurServerTime
    PlayerPrefsSystem.SaveTableToFile_N(tCacheLocal, PlayerPrefsSystem.ePlayerPrefsType.eLukcyOptionalReqActInfoTime)
    SpecialLuckNetWork.send_get_draw_act_info_req(nActId)
  else
    local nLastReqTime = tCacheLocal.lastReqTime
    if nLastReqTime then
      local bIsSameDay = TimeUtil.IsSameDay(nLastReqTime, nCurServerTime)
      if not bIsSameDay then
        SpecialLuckNetWork.send_get_draw_act_info_req(nActId)
        tCacheLocal.lastReqTime = nCurServerTime
        PlayerPrefsSystem.SaveTableToFile_N(tCacheLocal, PlayerPrefsSystem.ePlayerPrefsType.eLukcyOptionalReqActInfoTime)
      end
    else
      SpecialLuckNetWork.send_get_draw_act_info_req(nActId)
      tCacheLocal.lastReqTime = nCurServerTime
      PlayerPrefsSystem.SaveTableToFile_N(tCacheLocal, PlayerPrefsSystem.ePlayerPrefsType.eLukcyOptionalReqActInfoTime)
    end
  end
end
function Logic_LukcyOptionalTurntable:OnGetDrawActInfoRsp(activity_id, pool_info, price_info, ext_info)
  if activity_id ~= self:GetOptionalTurntableActId() then
    return
  end
  log(bWriteLog and "Logic_LukcyOptionalTurntable:OnOptionalActInfoRsp activity_id = " .. tostring(activity_id))
  self.tPoolInfo = pool_info
  self.tPriceInfo = price_info
  self.tExtraInfo = ext_info
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_ACTRSP)
end
function Logic_LukcyOptionalTurntable:SendDrawActReq(DrawTimes)
  local nCurDrawPrice = 0
  local sTipContent = ""
  if DrawTimes == 1 then
    nCurDrawPrice = self:GetOneDrawPrice()
    sTipContent = LocUtil.GetLocalizeResStr(7625)
  else
    if self:IsHasUseTenDrawDiscount() then
      nCurDrawPrice = self:GetTenDrawPrice()
    else
      nCurDrawPrice = self:GetTenDrawDiscountPrice()
    end
    sTipContent = LocUtil.GetLocalizeResStr(7626)
  end
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._LukcyOptionalTurntable
  local tPriceList = {}
  local bIsFirstPrice = self:GetIsHasFirstDrawDis()
  if DrawTimes == 1 and bIsFirstPrice then
    local data = {
      price = self:GetDailyFistDrawDisPrice()
    }
    table.insert(tPriceList, data)
  end
  local title = LocUtil.GetLocalizeResStr(6177)
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._TheBest,
    sTitle = title,
    sTipContent = sTipContent,
    nMainScene = CouponSystem._Enum_Scene._LukcyOptionalTurntable,
    nCurPrice = nCurDrawPrice,
    fConfirmCallback = function(confirmData)
      local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
      local nActId = self:GetOptionalTurntableActId()
      SpecialLuckNetWork.send_do_draw_act_req(nActId, confirmData.nCurCouponId, 1006, DrawTimes, nil)
    end,
    tExtraData = {
      fixPriceList = tPriceList,
      SpecialScene = CouponSystem._Enum_Scene._LukcyOptionalTurntable
    }
  }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
end
function Logic_LukcyOptionalTurntable:OnDoDrawActRsp(activity_id, item_list, decompose_list, ext_info)
  if activity_id ~= self:GetOptionalTurntableActId() then
    return
  end
  log(bWriteLog and "Logic_LukcyOptionalTurntable:OnOptionalDrawRsp  " .. tostring(activity_id))
  self.tGetRewardInfo = item_list
  self.tDecomposeList = decompose_list
  self.tExtraInfo.is_first_dis = ext_info.is_first_dis
  self:CheckShowAvailableAwardRedDot()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_UPDATE_DRAW_PRICE)
  if self:GetIsJumpPlayDrawAnim() then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_JUMPANIMATION)
    return
  end
  if 1 < #item_list then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_DARW_TEN_ANIMATION, item_list)
  else
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_DARW_ONE_ANIMATION, item_list)
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_LUCKYACTIVITY_DRAW_ANIMATION_START, function()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_JUMPANIMATION)
  end)
end
function Logic_LukcyOptionalTurntable:ShowItem()
  local nDrawNum = #self.tGetRewardInfo
  local DrawAgain = function()
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    local nAgainDrawPrice = 0
    if 1 < nDrawNum then
      nAgainDrawPrice = self:GetTenDrawPrice()
    else
      local bIsFirstPrice = self:GetIsHasFirstDrawDis()
      if bIsFirstPrice then
        nAgainDrawPrice = self:GetDailyFistDrawDisPrice()
      else
        nAgainDrawPrice = self:GetOneDrawPrice()
      end
    end
    local IsHaveCouldUseCoupon = CouponSystem.IsHaveCouldUseCoupon(CouponSystem._cur_coupon_scene, nAgainDrawPrice)
    if IsHaveCouldUseCoupon then
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_ONE_MORE_DRAW, nDrawNum)
    elseif nAgainDrawPrice <= DataMgr.ticket then
      local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
      local nActId = self:GetOptionalTurntableActId()
      SpecialLuckNetWork.send_do_draw_act_req(nActId, nil, 1006, nDrawNum, nil)
    else
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(nAgainDrawPrice)
    end
  end
  local nPrice = 0
  if 1 < nDrawNum then
    nPrice = self:GetTenDrawPrice()
  else
    local bIsFirstPrice = self:GetIsHasFirstDrawDis()
    if bIsFirstPrice then
      nPrice = self:GetDailyFistDrawDisPrice()
    else
      nPrice = self:GetOneDrawPrice()
    end
  end
  local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
  local tExtendData = {
    tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateConsecutiveDrawBtnData(1 < nDrawNum, nPrice, DrawAgain)
  }
  function tExtendData.fCloseCallback()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_ON_GET_END)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if self.tDecomposeList and next(self.tDecomposeList) then
    tExtendData.bCheckSpecialItem = false
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(self.tGetRewardInfo, self.tDecomposeList, tExtendData)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(self.tGetRewardInfo, false, false, tExtendData)
  end
  self.tGetRewardInfo = nil
  self.tDecomposeList = nil
end
function Logic_LukcyOptionalTurntable:ReqDrawSumReward(sum_times)
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  local nActId = self:GetOptionalTurntableActId()
  SpecialLuckNetWork.send_get_draw_sum_reward_req(nActId, sum_times, true)
end
function Logic_LukcyOptionalTurntable:OnGetDrawSumRewardRsp(activity_id, award_list, decompose_list)
  if activity_id ~= self:GetOptionalTurntableActId() then
    return
  end
  log(bWriteLog and "Logic_LukcyOptionalTurntable:OnOptionalDrawSumRsp activity_id =  " .. tostring(activity_id))
  log_tree("Logic_LukcyOptionalTurntable:OnOptionalDrawSumRsp award_list ", award_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if decompose_list and next(decompose_list) then
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(award_list, decompose_list)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  end
  self:CheckShowAvailableAwardRedDot()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_UPDATE_SELECT_CHEST)
end
function Logic_LukcyOptionalTurntable:ConfirmCustomDrawReq()
  local OptionalTurntableHandler = require("client.network.Protocol.OptionalTurntableHandler")
  local nActId = self:GetOptionalTurntableActId()
  OptionalTurntableHandler.send_confirm_custom_draw_req(nActId, self.tCacheOptionalPrize)
end
function Logic_LukcyOptionalTurntable:ConfirmCustomDrawRsp(activity_id)
  log(bWriteLog and "Logic_LukcyOptionalTurntable:ConfirmCustomDrawRsp  " .. tostring(activity_id))
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_CLOSE_OPTIONALMAIN)
end
function Logic_LukcyOptionalTurntable:ConfirmCustomDrawProgressReq(sum_times)
  local OptionalTurntableHandler = require("client.network.Protocol.OptionalTurntableHandler")
  local nActId = self:GetOptionalTurntableActId()
  OptionalTurntableHandler.send_confirm_custom_draw_progress_reward_req(nActId, sum_times, self.tCacheProgressPrize[sum_times])
end
function Logic_LukcyOptionalTurntable:ConfirmCustomDrawProgressRsp(activity_id)
  log(bWriteLog and "Logic_LukcyOptionalTurntable:ConfirmCustomDrawProgressRsp  " .. tostring(activity_id))
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_UPDATE_SELECT_CHEST)
end
function Logic_LukcyOptionalTurntable:ResetCustomDrawPoolDataReq()
  local nFreeResetCount = self:GetCurFreeResetPoolTimes()
  local nCurPrice
  if 0 < nFreeResetCount then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local sTitle = LocUtil.GetLocalizeResStr(18130057)
    local sMsg = LocUtil.LocalizeResFormat(18130083, self:GetCurFreeResetPoolTimes())
    local fClickOkCallback = function()
      local OptionalTurntableHandler = require("client.network.Protocol.OptionalTurntableHandler")
      local nActId = self:GetOptionalTurntableActId()
      self:ResetCacheFinalPrizeData()
      OptionalTurntableHandler.send_reset_custom_draw_pool_req(nActId)
    end
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sMsg, fClickOkCallback)
  else
    local nCurResetTimes = self:GetCurHasResetPoolTimes()
    local nMaxResetTimes = self:GetesetPoolCostInfoCount()
    local nTimes = nCurResetTimes + 1
    if nMaxResetTimes <= nTimes then
      nTimes = nMaxResetTimes
    end
    local tCostInfo = self:GetResetPoolCostInfo(nTimes)
    nCurPrice = tCostInfo.count
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._LuckySpin
    local tShowCfg = {
      nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
      sTitle = LocUtil.GetLocalizeResStr(18130057),
      sTipContent = LocUtil.LocalizeResFormat(18130058),
      nMainScene = CouponSystem._Enum_Scene._LukcyOptionalTurntable,
      nCurPrice = nCurPrice,
      bIsShowConfirmBtnPrice = true,
      fConfirmCallback = function(confirmData)
        local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
        if QRcodeRestrictManager:IsRestrictUC() then
          QRcodeRestrictManager:ShowRestrictTips()
          return
        end
        local OptionalTurntableHandler = require("client.network.Protocol.OptionalTurntableHandler")
        local nActId = self:GetOptionalTurntableActId()
        self:ResetCacheFinalPrizeData()
        OptionalTurntableHandler.send_reset_custom_draw_pool_req(nActId, confirmData.nCurCouponId)
      end
    }
    UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
  end
end
function Logic_LukcyOptionalTurntable:ResetCustomDrawPoolRsp(activity_id)
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.send_get_draw_act_info_req(activity_id)
  UIManager.ShowUI(UIManager.UI_Config.Optional_Main_UIBP)
end
function Logic_LukcyOptionalTurntable:OnDataChangeList(_, _, changeList)
  local actId = self:GetOptionalTurntableActId()
  if changeList and changeList.idList and changeList.idList[actId] then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local tActData = ActivityNewSystem.GetActivityByID(actId)
    self.tTurnTableActData = tActData.other
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_UPDATE_PROGRESS_BOX)
  end
end
function Logic_LukcyOptionalTurntable:GetActRuleDesc()
  local actId = self:GetOptionalTurntableActId()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tActData = ActivityNewSystem.GetActivityByID(actId)
  return tActData.Desc
end
function Logic_LukcyOptionalTurntable:CacheOptionalPrizeData(itemData)
  if not itemData then
    log(bWriteLog and "Logic_LukcyOptionalTurntable:CacheOptionalPrizeData not itemData ")
    return
  end
  local nCurPrizeLevel = itemData.custom_level
  if not self.tCacheOptionalPrize[nCurPrizeLevel] then
    self.tCacheOptionalPrize[nCurPrizeLevel] = {}
    self.tCacheOptionalPrizeByIndex[nCurPrizeLevel] = {}
  end
  local tSelectPrizeData = self.tCacheOptionalPrizeByIndex[nCurPrizeLevel]
  for i, v in pairs(tSelectPrizeData) do
    if v.unique_id == itemData.unique_id then
      tSelectPrizeData[i] = nil
    end
  end
  local tCurLevelPrizeData = self.tCacheOptionalPrize[nCurPrizeLevel]
  if tCurLevelPrizeData[itemData.unique_id] then
    for i, v in pairs(tCurLevelPrizeData) do
      if v.resid == itemData.resid then
        tCurLevelPrizeData[i] = nil
        return
      end
    end
  end
  local nCurMaxOptionalNum = self:GetMaxOptionalNumByLevel(nCurPrizeLevel)
  local nSelectCurNum = 0
  for _ in pairs(tCurLevelPrizeData) do
    nSelectCurNum = nSelectCurNum + 1
  end
  if nCurMaxOptionalNum <= nSelectCurNum then
    ShowNotice(LocUtil.LocalizeResFormat(18130043, nCurMaxOptionalNum))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nCurMiSec = math.floor(TimeUtil.GetMicroseconds()) or 0
  tCurLevelPrizeData[itemData.unique_id] = {
    resid = itemData.resid,
    count = itemData.count,
    valid_hours = itemData.valid_hours
  }
  local tTempData = {}
  tTempData = tCurLevelPrizeData[itemData.unique_id]
  tTempData.unique_id = itemData.unique_id
  tTempData.  local tTempDataByIndex = {}
  for _, v in pairs(tSelectPrizeData) do
    table.insert(tTempDataByIndex, v)
  end
  table.insert(tTempDataByIndex, tTempData)
  table.sort(tTempDataByIndex, function(a, b)
    return a.nCurMiSec < b.nCurMiSec
  end)
  local TableUtil = require("common.table_util")
  self.tCacheOptionalPrizeByIndex[nCurPrizeLevel] = TableUtil.CopyTable(tTempDataByIndex)
end
function Logic_LukcyOptionalTurntable:GetCurLevelCachePrizeData(custom_level)
  if self.tCacheOptionalPrize and self.tCacheOptionalPrize[custom_level] then
    return self.tCacheOptionalPrize[custom_level]
  end
  return
end
function Logic_LukcyOptionalTurntable:GetCurLevelByIndexCachePrizeData(custom_level)
  if self.tCacheOptionalPrizeByIndex and self.tCacheOptionalPrizeByIndex[custom_level] then
    return self.tCacheOptionalPrizeByIndex[custom_level]
  end
  return
end
function Logic_LukcyOptionalTurntable:GetOptionalAllPrizeNum()
  local nAllPrizeNum = 0
  for _, v in pairs(self.tCacheOptionalPrize) do
    for _ in pairs(v) do
      nAllPrizeNum = nAllPrizeNum + 1
    end
  end
  return nAllPrizeNum
end
function Logic_LukcyOptionalTurntable:GetOptionalProgressRewardNum(draw_count)
  local nAllPrizeNum = 0
  local tCurBoxList = self.tCacheProgressPrize[draw_count]
  if not tCurBoxList then
    return nAllPrizeNum
  end
  for _ in pairs(tCurBoxList) do
    nAllPrizeNum = nAllPrizeNum + 1
  end
  return nAllPrizeNum
end
function Logic_LukcyOptionalTurntable:IsHasRemovePrize(draw_count, unique_id)
  local tCurBoxList = self:GetProgressCustomItemList(draw_count)
  if not tCurBoxList then
    return false
  end
  for id, _ in pairs(tCurBoxList) do
    if id == unique_id then
      return false
    end
  end
  return true
end
function Logic_LukcyOptionalTurntable:CacheOptionProgressPrizeData(itemData)
  if not itemData then
    log(bWriteLog and "Logic_LukcyOptionalTurntable:CacheOptionProgressPrizeData not itemData ")
    return
  end
  local nCurDrawCount = itemData.draw_count
  if not self.tCacheProgressPrize[nCurDrawCount] then
    self.tCacheProgressPrize[nCurDrawCount] = {}
  end
  local tCurDrawCountPrizeData = self.tCacheProgressPrize[nCurDrawCount]
  if tCurDrawCountPrizeData[itemData.unique_id] then
    for i, v in pairs(tCurDrawCountPrizeData) do
      if v.resid == itemData.resid and v.count == itemData.count then
        tCurDrawCountPrizeData[i] = nil
        return
      end
    end
  end
  local nCurMaxOptionalNum = self:GetProgressBoxMaxNum(nCurDrawCount)
  local nSelectCurNum = 0
  for _ in pairs(tCurDrawCountPrizeData) do
    nSelectCurNum = nSelectCurNum + 1
  end
  if nCurMaxOptionalNum <= nSelectCurNum then
    ShowNotice(LocUtil.LocalizeResFormat(18130043, nCurMaxOptionalNum))
    return
  end
  tCurDrawCountPrizeData[itemData.unique_id] = {
    resid = itemData.resid,
    count = itemData.count,
    valid_hours = itemData.valid_hours
  }
end
function Logic_LukcyOptionalTurntable:IsBoxPrizeSelected(draw_count, unique_id)
  if not draw_count or not unique_id then
    log(bWriteLog and "Logic_LukcyOptionalTurntable:IsPrizeSelected")
    return false
  end
  local tCurLevelPrizeData = self.tCacheProgressPrize[draw_count]
  if tCurLevelPrizeData and tCurLevelPrizeData[unique_id] then
    return true
  end
  return false
end
function Logic_LukcyOptionalTurntable:RandomProgressPrize(draw_count, isNotShowTips)
  local tTempProgressPrize = {}
  local bIsCancelRandomSelect = false
  local nItemNum = self:GetProgressBoxMaxNum(draw_count)
  local tDrawcountItems = self:GetRandomItemsFromDrawcount(draw_count, nItemNum, isNotShowTips)
  if next(tDrawcountItems) then
    tTempProgressPrize = tDrawcountItems
  else
    bIsCancelRandomSelect = true
  end
  if not bIsCancelRandomSelect then
    self.tCacheProgressPrize[draw_count] = tTempProgressPrize
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_UPDATE_RANDOM_SELECT)
  end
end
function Logic_LukcyOptionalTurntable:GetRandomItemsFromDrawcount(draw_count, nCount, isNotShowTips)
  local tProgressRewardData = self.tExtraInfo.progress_reward_list[draw_count]
  if not tProgressRewardData then
    return {}
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local store_commodity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_commodity_manager)
  local tNotOwnedData = {}
  local tOwnedData = {}
  for _, v in pairs(tProgressRewardData) do
    local tItemCfg = CDataTable.GetTableData("Item", v.resid)
    local colorID, patternID = self:GetCustomClothColorIDAndPatternID(v.resid)
    local bIsHave = store_commodity_manager:CheckAlreadyOwnByType(tItemCfg.ItemType, tItemCfg.ItemSubType, v.resid, colorID, patternID)
    if v.no_need_consider_own == 0 then
      if bIsHave then
        tOwnedData[#tOwnedData + 1] = v
      else
        tNotOwnedData[#tNotOwnedData + 1] = v
      end
    else
      tNotOwnedData[#tNotOwnedData + 1] = v
    end
  end
  local fConfirmCallBack = function(bIsCheck)
    if bIsCheck ~= nil then
      self.bIsShowRandomSelectChestDesTips = not bIsCheck
    end
    self:RandomProgressPrize(draw_count, true)
  end
  local fCancelCallback = function(bIsCheck)
    if bIsCheck ~= nil then
      self.bIsShowRandomSelectChestDesTips = not bIsCheck
    end
  end
  if nCount > #tNotOwnedData and not isNotShowTips and self.bIsShowRandomSelectChestDesTips then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local sContentKey = 18130137
    if self:IsOldActId() then
      sContentKey = 18130081
    end
    local sMsg = LocUtil.GetLocalizeResStr(sContentKey)
    local tExtraData = {
      isShowCheckBox = true,
      checkBoxText = LocUtil.GetLocalizeResStr(27297)
    }
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, nil, sMsg, fConfirmCallBack, fCancelCallback, nil, nil, tExtraData)
    return {}
  end
  local RandomPickFromPool = function(tPool, nPickCount)
    local tAvailableIndices = {}
    for k, _ in pairs(tPool) do
      table.insert(tAvailableIndices, k)
    end
    local tResult = {}
    local nPickNum = math.min(nPickCount, #tAvailableIndices)
    for i = 1, nPickNum do
      local nRandomPos = math.random(1, #tAvailableIndices)
      local nSelectedIndex = tAvailableIndices[nRandomPos]
      local item = tPool[nSelectedIndex]
      tResult[item.unique_id] = {
        resid = item.resid,
        count = item.count,
        valid_hours = item.valid_hours
      }
      table.remove(tAvailableIndices, nRandomPos)
    end
    return tResult
  end
  local tResult = RandomPickFromPool(tNotOwnedData, nCount)
  local nPickedCount = 0
  for _ in pairs(tResult) do
    nPickedCount = nPickedCount + 1
  end
  if nCount > nPickedCount then
    local nNeedMore = nCount - nPickedCount
    local tOwnedResult = RandomPickFromPool(tOwnedData, nNeedMore)
    for unique_id, v in pairs(tOwnedResult) do
      tResult[unique_id] = v
    end
  end
  return tResult
end
function Logic_LukcyOptionalTurntable:ResetCacheOptionProgressPrizeData()
  self.tCacheProgressPrize = {}
end
function Logic_LukcyOptionalTurntable:ResetCacheFinalPrizeData()
  self.tCacheFinalPrizeData = {}
end
function Logic_LukcyOptionalTurntable:GetCurLevelOptionalPrizeNum(custom_level)
  local tCurLevelPrizeData = self.tCacheOptionalPrize[custom_level]
  local nCurOptionalPrizeNum = 0
  if not tCurLevelPrizeData then
    return nCurOptionalPrizeNum
  end
  for _ in pairs(tCurLevelPrizeData) do
    nCurOptionalPrizeNum = nCurOptionalPrizeNum + 1
  end
  return nCurOptionalPrizeNum
end
function Logic_LukcyOptionalTurntable:ResetCacheOptionalPrizeData()
  self.tCacheOptionalPrize = {}
  self.tCacheOptionalPrizeByIndex = {}
end
function Logic_LukcyOptionalTurntable:IsPrizeSelected(custom_level, unique_id)
  if not custom_level or not unique_id then
    log(bWriteLog and "Logic_LukcyOptionalTurntable:IsPrizeSelected")
    return false
  end
  local tCurLevelPrizeData = self.tCacheOptionalPrize[custom_level]
  if tCurLevelPrizeData and tCurLevelPrizeData[unique_id] then
    return true
  end
  return false
end
function Logic_LukcyOptionalTurntable:IsInPriceList(custom_level, unique_id)
  local tCurLevelPrizeData = self.tCacheFinalPrizeData[custom_level]
  if tCurLevelPrizeData then
    for _, v in pairs(tCurLevelPrizeData) do
      if v.unique_id == unique_id then
        return true
      end
    end
  end
  return false
end
function Logic_LukcyOptionalTurntable:RandomOptionalPrize(isNotShowTips)
  local TableUtil = require("common.table_util")
  local tTempOptionalPrize = {}
  local tTempOptionalPrizeByIndex = {}
  local bIsCancelRandomSelect = false
  local tMaxOptionNumInfo
  tMaxOptionNumInfo = self:GetFinalMaxOptionalNum()
  for nLevel, nCount in pairs(tMaxOptionNumInfo) do
    local tLevelItems = self:GetRandomItemsFromLevel(nLevel, nCount, isNotShowTips)
    if next(tLevelItems) then
      tTempOptionalPrize[nLevel] = tLevelItems
      local tTempData = TableUtil.CopyTable(tLevelItems)
      for unique_id, v in pairs(tTempData) do
        v.      end
      tTempOptionalPrizeByIndex[nLevel] = tTempData
    else
      bIsCancelRandomSelect = true
      tTempOptionalPrize = {}
      tTempOptionalPrizeByIndex = {}
      break
    end
  end
  if not bIsCancelRandomSelect then
    self.tCacheOptionalPrize = {}
    self.tCacheOptionalPrizeByIndex = {}
    for i, v in pairs(tTempOptionalPrize) do
      self.tCacheOptionalPrize[i] = v
    end
    local TimeUtil = require("client.common.time_util")
    for i, v in pairs(tTempOptionalPrizeByIndex) do
      for _, vv in pairs(v) do
        vv.nCurMiSec = math.floor(TimeUtil.GetMicroseconds()) or 0
      end
      self.tCacheOptionalPrizeByIndex[i] = v
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYOPTIONAL_TURNTABLE_UPDATE_RANDOM_SELECT)
  end
end
function Logic_LukcyOptionalTurntable:GetRandomItemsFromLevel(nLevel, nCount, isNotShowTips)
  local tLevelData = self:GetPrizeListByLevel(nLevel)
  if not tLevelData then
    return {}
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local store_commodity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_commodity_manager)
  local tCurCanSelectData = {}
  local tOwnedData = {}
  for _, v in pairs(tLevelData) do
    local tItemCfg = CDataTable.GetTableData("Item", v.resid)
    local colorID, patternID = self:GetCustomClothColorIDAndPatternID(v.resid)
    local bIsHave = store_commodity_manager:CheckAlreadyOwnByType(tItemCfg.ItemType, tItemCfg.ItemSubType, v.resid, colorID, patternID)
    if v.no_need_consider_own == 0 then
      if bIsHave then
        tOwnedData[#tOwnedData + 1] = v
      else
        tCurCanSelectData[#tCurCanSelectData + 1] = v
      end
    else
      tCurCanSelectData[#tCurCanSelectData + 1] = v
    end
  end
  local fConfirmCallBack = function(bIsCheck)
    if bIsCheck ~= nil then
      self.bIsShowRandomSelectDrawTips = not bIsCheck
    end
    self:RandomOptionalPrize(true)
  end
  local fCancelCallback = function(bIsCheck)
    if bIsCheck ~= nil then
      self.bIsShowRandomSelectDrawTips = not bIsCheck
    end
  end
  if not (nCount > #tCurCanSelectData) or isNotShowTips or not self.bIsShowRandomSelectDrawTips then
  else
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local sContentKey = 18130136
    if self:IsOldActId() then
      sContentKey = 18130080
    end
    local sMsg = LocUtil.GetLocalizeResStr(sContentKey)
    local tExtraData = {
      isShowCheckBox = true,
      checkBoxText = LocUtil.GetLocalizeResStr(27297)
    }
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, nil, sMsg, fConfirmCallBack, fCancelCallback, nil, nil, tExtraData)
    return {}
  end
  local tNotOwnedData = tCurCanSelectData
  local RandomPickFromPool = function(tPool, nPickCount)
    local tAvailableIndices = {}
    for k, _ in pairs(tPool) do
      table.insert(tAvailableIndices, k)
    end
    local tResult = {}
    local nPickNum = math.min(nPickCount, #tAvailableIndices)
    for i = 1, nPickNum do
      local nRandomPos = math.random(1, #tAvailableIndices)
      local nSelectedIndex = tAvailableIndices[nRandomPos]
      local item = tPool[nSelectedIndex]
      tResult[item.unique_id] = {
        resid = item.resid,
        count = item.count,
        valid_hours = item.valid_hours
      }
      table.remove(tAvailableIndices, nRandomPos)
    end
    return tResult, nPickNum
  end
  local tResult, nPickedCount = RandomPickFromPool(tNotOwnedData, nCount)
  if nCount > nPickedCount then
    local nNeedMore = nCount - nPickedCount
    local tOwnedResult = RandomPickFromPool(tOwnedData, nNeedMore)
    for unique_id, v in pairs(tOwnedResult) do
      tResult[unique_id] = v
    end
  end
  return tResult
end
function Logic_LukcyOptionalTurntable:GetPlayAnimNeedPoolData(tAllPoolData, nItemNum, custom_level)
  if self.tCachePlayAnimPoolData[custom_level] then
    return self.tCachePlayAnimPoolData[custom_level]
  end
  if not tAllPoolData or not nItemNum then
    return
  end
  local tAllResults = {}
  local nCurrentPos = 1
  local nTotalLength = #tAllPoolData
  for i = 1, 2 do
    local tResult = {}
    for j = 1, nItemNum do
      if nCurrentPos > nTotalLength then
        nCurrentPos = 1
      end
      tResult[j] = {
        custom_level = tAllPoolData[nCurrentPos].custom_level,
        count = tAllPoolData[nCurrentPos].count,
        resid = tAllPoolData[nCurrentPos].resid,
        unique_id = tAllPoolData[nCurrentPos].unique_id,
        valid_hours = tAllPoolData[nCurrentPos].valid_hours
      }
      nCurrentPos = nCurrentPos + 1
    end
    tAllResults[i] = tResult
  end
  self.tCachePlayAnimPoolData[custom_level] = tAllResults
  return tAllResults
end
function Logic_LukcyOptionalTurntable:GetBigPrizePoolData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPrizeLevel = tLevelInfo[1].custom_level
  local tBigPrizeList = self:GetPrizeListByLevel(nPrizeLevel)
  local tBigPoolData = self:GetPlayAnimNeedPoolData(tBigPrizeList, 5, nPrizeLevel)
  return tBigPoolData
end
function Logic_LukcyOptionalTurntable:GetMiddlePrizePoolData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPrizeLevel = tLevelInfo[2].custom_level
  local tBigPrizeList = self:GetPrizeListByLevel(nPrizeLevel)
  local tBigPoolData = self:GetPlayAnimNeedPoolData(tBigPrizeList, 4, nPrizeLevel)
  return tBigPoolData
end
function Logic_LukcyOptionalTurntable:GetSmallPrizePoolData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPurplePrizeLevel = tLevelInfo[3].custom_level
  local tCurPoolData = self:GetPlayAnimNeedPoolData(self:HandleSmallPrizePoolData(), 6, nPurplePrizeLevel)
  return tCurPoolData
end
function Logic_LukcyOptionalTurntable:HandleSmallPrizePoolData()
  local tLevelInfo = self:GetExtraOptionalNumInfo()
  local nPurplePrizeLevel = tLevelInfo[3].custom_level
  local tPurplePrizeList = self:GetPrizeListByLevel(nPurplePrizeLevel)
  local nBluePrizeLevel = tLevelInfo[4].custom_level
  local tBluePrizeList = self:GetPrizeListByLevel(nBluePrizeLevel)
  local tResult = {}
  local nIndex = 1
  local nLen1 = #tPurplePrizeList
  local nLen2 = #tBluePrizeList
  for i = 1, nLen1 do
    tResult[nIndex] = {
      unique_id = tPurplePrizeList[i].unique_id,
      valid_hours = tPurplePrizeList[i].valid_hours,
      custom_level = tPurplePrizeList[i].custom_level,
      count = tPurplePrizeList[i].count,
      resid = tPurplePrizeList[i].resid
    }
    nIndex = nIndex + 1
    if i <= nLen2 then
      tResult[nIndex] = {
        unique_id = tBluePrizeList[i].unique_id,
        valid_hours = tBluePrizeList[i].valid_hours,
        custom_level = tBluePrizeList[i].custom_level,
        count = tBluePrizeList[i].count,
        resid = tBluePrizeList[i].resid
      }
      nIndex = nIndex + 1
    end
  end
  return tResult
end
function Logic_LukcyOptionalTurntable:GetPoolDataByIndex(tCurPoolData, nPlayAnimCount)
  if not tCurPoolData or not nPlayAnimCount then
    return
  end
  local nTotalSegments = #tCurPoolData
  local nActualSegment = (nPlayAnimCount - 1) % nTotalSegments + 1
  return tCurPoolData[nActualSegment]
end
function Logic_LukcyOptionalTurntable:CheckShowAvailableAwardRedDot()
  local tRewardStateInfo = self:GetProgressRewardStateInfo()
  local nActId = self:GetOptionalTurntableActId()
  if not tRewardStateInfo or not nActId then
    return
  end
  log_tree("Logic_LukcyOptionalTurntable:CheckShowAvailableAwardRedDot ", tRewardStateInfo)
  local Logic_LukcyTurntable_Const = require("client.slua.logic.lobby_activity.LukcyOptionalTurntable.Logic_LukcyTurntable_Const")
  local EnumBoxState = Logic_LukcyTurntable_Const.Enum_Consum_Box_State
  for _, v in pairs(tRewardStateInfo) do
    if v.state == EnumBoxState.CanGet then
      local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
      store_reddot_manager:SetActAvailableRedDot(nActId, BP_ENUM_MODULE_OPTIONAL_TURNTABLE_MAIN)
      return
    end
  end
  if self.tTurnTableActData.red_point_new and self.tTurnTableActData.red_point_new == 1 then
    return
  end
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:CloseActAvailableRedDot(self:GetOptionalTurntableActId(), BP_ENUM_MODULE_OPTIONAL_TURNTABLE_MAIN)
end
function Logic_LukcyOptionalTurntable:GetDrawRateInfo()
  return self.tExtraInfo.quality_level_pro
end
function Logic_LukcyOptionalTurntable:SortBoxRewardList(itemList)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local store_commodity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_commodity_manager)
  for _, v in pairs(itemList) do
    local tItemCfg = CDataTable.GetTableData("Item", v.resid)
    local colorID, patternID = self:GetCustomClothColorIDAndPatternID(v.resid)
    local bIsHave = store_commodity_manager:CheckAlreadyOwnByType(tItemCfg.ItemType, tItemCfg.ItemSubType, v.resid, colorID, patternID)
    if v.no_need_consider_own == 0 and bIsHave then
      v.sortIndex = 1
    elseif self:IsHasRemovePrize(v.draw_count, v.unique_id) then
      v.sortIndex = 0
    else
      v.sortIndex = 2
    end
  end
  table.sort(itemList, function(a, b)
    if a.sortIndex == b.sortIndex then
      return a.unique_id < b.unique_id
    else
      return a.sortIndex > b.sortIndex
    end
  end)
  return itemList
end
function Logic_LukcyOptionalTurntable:SetIsShowDrawDecTips(bIsShow)
  self.bIsShowDrawDesTips = bIsShow
end
function Logic_LukcyOptionalTurntable:GetIsShowDrawDecTips()
  return self.bIsShowDrawDesTips
end
function Logic_LukcyOptionalTurntable:SetIsShowChestDecTips(bIsShow)
  self.bIsShowChestDesTips = bIsShow
end
function Logic_LukcyOptionalTurntable:GetIsShowChestDecTips()
  return self.bIsShowChestDesTips
end
function Logic_LukcyOptionalTurntable:IsOldActId()
  local nActId = self:GetOptionalTurntableActId()
  if old_actid_list[nActId] then
    return true
  end
  return false
end
function Logic_LukcyOptionalTurntable:GetPoolBlueprint()
  local tPoolBlueprint = {
    [2] = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/LukcyOptionalTurntable_SelectionPool_Item01_UIBP.LukcyOptionalTurntable_SelectionPool_Item01_UIBP",
    [3] = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/LukcyOptionalTurntable_SelectionPool_Item02_UIBP.LukcyOptionalTurntable_SelectionPool_Item02_UIBP",
    [4] = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/LukcyOptionalTurntable_SelectionPool_Item03_UIBP.LukcyOptionalTurntable_SelectionPool_Item03_UIBP"
  }
  local tLevelInfo = self:GetOptionalNumInfo()
  local nPrizeCount = tLevelInfo[1].maxNum
  return tPoolBlueprint[nPrizeCount]
end
function Logic_LukcyOptionalTurntable:GetLimitedPrizeListByLevel(level)
  local tLevelData = self:GetPrizeListByLevel(level)
  if not tLevelData then
    return {}
  end
  local tLimitedList = {}
  for _, v in pairs(tLevelData) do
    if v.not_add_chest_flag and v.not_add_chest_flag == 1 then
      tLimitedList[#tLimitedList + 1] = v
    end
  end
  return tLimitedList
end
function Logic_LukcyOptionalTurntable:GetCustomClothColorIDAndPatternID(resid)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tHallDepotItemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(resid)
  local colorID = tHallDepotItemData and tHallDepotItemData.colorID
  local patternID = tHallDepotItemData and tHallDepotItemData.patternID
  return colorID, patternID
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_LukcyOptionalTurntable = class(CModuleBase, nil, Logic_LukcyOptionalTurntable)
return CLogic_LukcyOptionalTurntable