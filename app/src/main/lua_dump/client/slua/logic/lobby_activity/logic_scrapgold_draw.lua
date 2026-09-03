local super_data = require("common.super_data")
local luck_util = require("client.slua.logic.lobby_activity.luck_util")
local TestDataOpen = false
local ENUM_EASTER_EGG_STATE = {AVAILABLE = 1, UNAVAILABLE = 2}
local LuckyScrapGoldSystem = {
  ActivityId = 0,
  ModuleId = BP_ENUM_MODULE_LUCKY_SCRAP_GOLD,
  CurAwardPoolIndex = 1,
  globalConfig = {
    startTime = 0,
    endTime = 0,
    tenDrawOriginalPrice = 0,
    big_reward_times = 100,
    videoPath = "",
    pro_show = {}
  },
  exchangeConfig = {},
  exchangeInfo = {},
  bluePathConfig = {
    bg_path = "",
    sum_award_box_img = "",
    exchangeBgBluePrintPath = ""
  },
  IsShowAnimation = {},
  resourceType = 0,
  exchangeResourceType = 0,
  dropList = {},
  SumRewardList = {},
  CurrentRewardBoxId = 0,
  playerData = super_data.CreateSuperData({
    oneDrawFinalPrice = 0,
    tenDrawFinalPrice = 0,
    hasWeekOneDrawDiscount = false,
    totalDrawTime = 0,
    draw_times_week = 0,
    CurLuckyValue = 0,
    everyday_first_got_gold_item_flag = true
  }),
  exchange_act_id = 0,
  bIsDrawAgain = false,
  ReceivedActInfo = false
}
local _DelayDecompose = function()
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.delay_item_decompose_notice()
end
local _OnlyCloseUIByType = function()
  log(bWriteLog and "[cw] _OnlyCloseUIByType(" .. tostring(LuckyScrapGoldSystem.resourceType) .. ")")
  UIManager.CloseUI(UIManager.UI_Config.LuckySpinScrapGold)
end
local _CloseUIByType = function()
  log(bWriteLog and "[cw] _CloseUIByType(" .. tostring(LuckyScrapGoldSystem.resourceType) .. ")")
  UIManager.CloseUI(UIManager.UI_Config.LuckySpinScrapGold)
end
local _UpdateDropList = function(award_info)
  LuckyScrapGoldSystem.dropList = {}
  for i, v in pairs(award_info) do
    local arrayItem = {
      res_id = v.resid,
      expire_ts = 0,
      valid_hours = v.valid_hours,
      count = v.count,
      pos_id = v.display_sort
    }
    table.insert(LuckyScrapGoldSystem.dropList, arrayItem)
  end
end
local _SetPoolItemConfig = function(itemTable)
  LuckyScrapGoldSystem.poolItemConfig = {}
  for k, v in ipairs(itemTable) do
    table.insert(LuckyScrapGoldSystem.poolItemConfig, {
      itemId = v.resid,
      itemCount = v.count,
      posId = v.display_sort,
      repeate_flag = v.repeate_flag,
      vaild_time = v.valid_hours
    })
  end
end
local _UpdatePriceInfo = function(is_uc_discount_by_week)
  local playerData = LuckyScrapGoldSystem.playerData
  playerData.hasWeekOneDrawDiscount = is_uc_discount_by_week
  if is_uc_discount_by_week then
    playerData.oneDrawFinalPrice = LuckyScrapGoldSystem.GetOneDrawDiscountPrice()
  else
    playerData.oneDrawFinalPrice = LuckyScrapGoldSystem.GetOneDrawOriginalPrice()
  end
end
local SetProShow = function(pro_show)
  for index, value in pairs(pro_show) do
    pro_show[index] = value * 100
  end
  LuckyScrapGoldSystem.globalConfig.end
local _SetConfig = function(pool_info, price_info, ext_info)
  LuckyScrapGoldSystem.bluePathConfig.bg_path = ext_info.blue_path
  LuckyScrapGoldSystem.bluePathConfig.sum_award_box_img = ext_info.sum_acc_pic
  LuckyScrapGoldSystem.bluePathConfig.exchangeBgBluePrintPath = ext_info.exchange_blue_path
  LuckyScrapGoldSystem.exchange_act_id = ext_info.exchange_act_id
  _SetPoolItemConfig(pool_info)
  local _praceinfo = price_info[1][1006]
  LuckyScrapGoldSystem.SetSumRewardList(ext_info.sum_reward_list)
  LuckyScrapGoldSystem.globalConfig.videoPath = ext_info.video_path
  LuckyScrapGoldSystem.globalConfig.tenDrawOriginalPrice = _praceinfo.one_cost * 10
  LuckyScrapGoldSystem.globalConfig.big_reward_times = ext_info.big_reward_times
  SetProShow(ext_info.pro_show)
  local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
  logic_lucky_exchange.UpdateExchangeCurrencyCount(LuckyScrapGoldSystem.exchange_act_id)
  LuckyScrapGoldSystem.playerData.everyday_first_got_gold_item_flag = ext_info.everyday_first_got_gold_item_flag == nil and true or ext_info.everyday_first_got_gold_item_flag
  LuckyScrapGoldSystem.playerData.tenDrawFinalPrice = _praceinfo.ten_cost
  _UpdatePriceInfo(ext_info.is_first_dis_for_week)
  if ext_info then
    LuckyScrapGoldSystem.tenDrawID = ext_info.voucher_list and ext_info.voucher_list[1]
    LuckyScrapGoldSystem.is_first_buy_voucher_for_version = ext_info.is_first_buy_voucher_for_version
    LuckyScrapGoldSystem.tenDrawTabID = StoreConst.Page_Special_ScrapGold_TenDraw_Pack
    LuckyScrapGoldSystem.ten_draw_market_id = ext_info.ten_draw_market_id
  end
end
function LuckyScrapGoldSystem.GetOneDrawOriginalPrice()
  if LuckyScrapGoldSystem.price_info and LuckyScrapGoldSystem.price_info[1][1006].one_cost then
    return LuckyScrapGoldSystem.price_info[1][1006].one_cost or 0
  else
    log_tree("LuckyScrapGoldSystem GetOneDrawOriginalPrice not have price_info", LuckyScrapGoldSystem.price_info)
    return 0
  end
end
function LuckyScrapGoldSystem.GetOneDrawDiscountPrice()
  if LuckyScrapGoldSystem.price_info and LuckyScrapGoldSystem.price_info[1][1006].dis_one_cost then
    return LuckyScrapGoldSystem.price_info[1][1006].dis_one_cost
  else
    log_tree("LuckyScrapGoldSystem GetOneDrawDiscountPrice not have price_info", LuckyScrapGoldSystem.price_info)
    return 0
  end
end
function LuckyScrapGoldSystem.IsHaveFirstGold()
  return LuckyScrapGoldSystem.playerData.everyday_first_got_gold_item_flag
end
function LuckyScrapGoldSystem.IsTimeInExchangeDiscountEvent()
  local TimeUtil = require("client.common.time_util")
  local extInfo = LuckyScrapGoldSystem.ext_info
  local startTime = extInfo.promote_sale_start_time or 0
  local endTime = extInfo.promote_sale_end_time or 0
  local curTime = TimeUtil.GetServerTimeInSec()
  if startTime <= 0 or endTime <= 0 then
    return false
  end
  if endTime < curTime or startTime > curTime then
    return false
  end
  return true
end
function LuckyScrapGoldSystem.IsDrawExchangeDiscount()
  local extInfo = LuckyScrapGoldSystem.ext_info
  if not extInfo then
    log_error(bWriteLog and "[SY]LuckyScrapGoldSystem.IsDrawExchangeDiscount. No ExtInfo")
    return false
  end
  if not LuckyScrapGoldSystem.IsTimeInExchangeDiscountEvent() then
    return false
  end
  if not extInfo.discount_draw_time or extInfo.discount_draw_time == 0 then
    return false
  end
  return true
end
function LuckyScrapGoldSystem.IsEventDiscountCanExchange()
  local extInfo = LuckyScrapGoldSystem.ext_info
  if not extInfo then
    log_error(bWriteLog and "[SY]LuckyScrapGoldSystem.IsHaveExchangeCount. No ExtInfo")
    return false
  end
  if not LuckyScrapGoldSystem.IsTimeInExchangeDiscountEvent() then
    return false
  end
  local curExchange, maxExchange = LuckyScrapGoldSystem.GetDiscountExchangeCount()
  return curExchange < maxExchange
end
function LuckyScrapGoldSystem.GetExchangeDiscountVal()
  local extInfo = LuckyScrapGoldSystem.ext_info
  if not extInfo then
    log_error(bWriteLog and "[SY]LuckyScrapGoldSystem.GetExchangeDiscountVal. No ExtInfo")
    return 1
  end
  if not LuckyScrapGoldSystem.IsDrawExchangeDiscount() or not LuckyScrapGoldSystem.IsEventDiscountCanExchange() then
    return 1
  end
  return extInfo.discount_value or 1
end
function LuckyScrapGoldSystem.GetDiscountExchangeCount()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetActivityByID(LuckyScrapGoldSystem.ActivityId)
  if not ActivityData then
    log_error("LuckyScrapGoldSystem.GetDiscountExchangeCount not ActivityData")
    return 0, 0
  end
  local extInfo = ActivityData.other.ext_info
  if not extInfo then
    return 0, 0
  end
  return extInfo.exchanged_count or 0, LuckyScrapGoldSystem.ext_info.promote_sale_total_count or 0
end
function LuckyScrapGoldSystem.IsItemShowUp(ItemID)
  for key, value in pairs(LuckyScrapGoldSystem.pool_info) do
    if value.resid == ItemID then
      return value.is_show_up
    end
  end
  log(bWriteLog and "LuckyScrapGoldSystem IsItemShowUp Can`t find item " .. tostring(ItemID))
  return false
end
function LuckyScrapGoldSystem.IsItemShowNewVersion(ItemID, clicked)
  if not clicked then
    for key, value in pairs(LuckyScrapGoldSystem.pool_info) do
      if value.resid == ItemID then
        return value.show_new
      end
    end
  end
  log(bWriteLog and "LuckyScrapGoldSystem IsItemShowNewVersion Can`t find item " .. tostring(ItemID))
  return false
end
function LuckyScrapGoldSystem.GetItemEndTime(ItemID)
  for key, value in pairs(LuckyScrapGoldSystem.pool_info) do
    if value.resid == ItemID then
      return value.close_time
    end
  end
end
local _ShowCommonItemPanel = function(arrayItemList)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, false)
  _DelayDecompose()
end
local _PostStatusChangeEvent = function()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_STATUS_CHANGE)
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.golden)
end
local _PostDrawEvent = function()
  local iLen = #LuckyScrapGoldSystem.dropList
  local index = 1
  if UIManager.GetUI(UIManager.UI_Config.LuckySpinScrapGold) then
    if iLen == 1 then
      index = LuckyScrapGoldSystem.dropList[iLen].pos_id
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_DARW_ONE_ANIMATION, index)
    else
      index = LuckyScrapGoldSystem.dropList[iLen].pos_id
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_DARW_TEN_ANIMATION, index)
    end
  end
end
function LuckyScrapGoldSystem.ClearPoolData()
  LuckyScrapGoldSystem.pool_info = nil
  LuckyScrapGoldSystem.price_info = nil
  LuckyScrapGoldSystem.ext_info = nil
  LuckyScrapGoldSystem.ReceivedActInfo = false
end
function LuckyScrapGoldSystem.JumpPrint(widget, itemId)
  LuckyScrapGoldSystem.JumpCoin(widget, itemId, 63035, "print_jump_link")
end
function LuckyScrapGoldSystem.JumpGold(widget, itemId)
  LuckyScrapGoldSystem.JumpCoin(widget, itemId, 63037, "gold_jump_link")
end
function LuckyScrapGoldSystem.JumpCoin(widget, itemID, contentId, key)
  local ext_info = LuckyScrapGoldSystem.GetExtInfo()
  local url = ext_info and ext_info[key]
  if not url or url == "" then
    log_warning(bWriteLog and "  : no  " .. tostring(key))
    return
  end
  local JumpTo = function()
    GlobalData.JumpUrl(url)
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tItemCfg = CDataTable.GetTableData("Item", itemID)
  local TipsParam = {
    widget = widget,
    title = tItemCfg and tItemCfg.ItemName or "",
    content = LocUtil.GetLocalizeResStr(contentId),
    jumpText = LocUtil.GetLocalizeResStr(63036),
    jumpCallback = JumpTo,
    offsetX = -100,
    offsetY = 70
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function LuckyScrapGoldSystem.OpenMainUI(vars)
  log_tree("LuckyScrapGoldSystem OpenMainUI", vars)
  if TestDataOpen then
    vars = {}
    vars.module = 1006018
    vars.activityid = 122020803
  end
  LuckyScrapGoldSystem.ModuleId = tonumber(vars.module)
  LuckyScrapGoldSystem.OpenUI()
  LuckyScrapGoldSystem.OpenUIWithActId(tonumber(vars.activityid))
end
function LuckyScrapGoldSystem.SetResourceType(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local data = ActivityNewSystem.GetActivityByID(tonumber(actId))
  if not data or not data.cfg then
    return
  end
  log(bWriteLog and "data.cfg.back_up_one:" .. tostring(data.BackupParam1))
  if data.BackupParam1 and data.BackupParam1 ~= "" then
    local str = tostring(data.BackupParam1)
    if string.find(str, "|") then
      local p1, p2 = string.match(str, "(%d*)|(%d*)")
      LuckyScrapGoldSystem.resourceType = tonumber(p1)
      LuckyScrapGoldSystem.exchangeResourceType = tonumber(p2)
    else
      local p1 = tonumber(str)
      LuckyScrapGoldSystem.resourceType = p1
    end
  end
end
function LuckyScrapGoldSystem.OpenUIWithActId(actId)
  if not luck_util.ActIsValid(actId) and not TestDataOpen then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetStateByModuleIDActivityID(nil, actId)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  luck_util.SetDecomposeDelay(true)
  luck_util.SetAchievementPopBlock(true)
  LuckyScrapGoldSystem.CurAwardPoolIndex = 1
  LuckyScrapGoldSystem.SetResourceType(actId)
  LuckyScrapGoldSystem.SetActPeriod(actId)
  LuckyScrapGoldSystem.UpdateTotalDrawTime(actId)
  LuckyScrapGoldSystem.UpdateWeekDrawTime(actId)
end
function LuckyScrapGoldSystem.SetActPeriod(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local data = ActivityNewSystem.GetActivityByID(tonumber(actId))
  LuckyScrapGoldSystem.globalConfig.startTime = data.StartTime
  LuckyScrapGoldSystem.globalConfig.endTime = data.EndTime
end
function LuckyScrapGoldSystem.CloseMainUI(isJump)
  log(bWriteLog and "[SY]LuckyScrapGoldSystem.CloseMainUI.")
  if isJump then
    _OnlyCloseUIByType()
  else
    _CloseUIByType()
  end
  luck_util.SetDecomposeDelay(false)
  luck_util.SetAchievementPopBlock(false)
end
function LuckyScrapGoldSystem.ReqActInfo(actId)
  log(bWriteLog and "LuckyScrapGoldSystem ReqActInfo" .. tostring(actId))
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.send_get_draw_act_info_req(actId)
end
function LuckyScrapGoldSystem.OnActInfoRsp(activity_id, pool_info, price_info, ext_info)
  log(bWriteLog and "OnActInfoRsp activity_id" .. tostring(activity_id))
  if activity_id ~= LuckyScrapGoldSystem.ActivityId then
    return
  end
  log(bWriteLog and "OnActInfoRsp activity_id" .. tostring(activity_id))
  LuckyScrapGoldSystem.  LuckyScrapGoldSystem.  LuckyScrapGoldSystem.  LuckyScrapGoldSystem.ReceivedActInfo = true
  _SetConfig(pool_info, price_info, ext_info)
  LuckyScrapGoldSystem.UpdatePlayerData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_GET_ACTIVITY_DATA)
end
function LuckyScrapGoldSystem.DrawEventExchangeDiscount(actId)
  log(bWriteLog and "[SY]LuckyScrapGoldSystem.DrawEventExchangeDiscount." .. actId)
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.send_do_draw_discount_req(actId)
end
function LuckyScrapGoldSystem.OnDrawEventExchangeDiscountRsp(activityid, discount_value, discount_draw_time)
  if not activityid == LuckyScrapGoldSystem.ActivityId then
    return
  end
  if not LuckyScrapGoldSystem.IsTimeInExchangeDiscountEvent() then
    return
  end
  log(bWriteLog and "[SY]LuckyScrapGoldSystem.OnDrawEventExchangeDiscountRsp. discount_value" .. tostring(discount_value) .. " drawTime " .. tostring(discount_draw_time))
  LuckyScrapGoldSystem.ext_info.discount_value = discount_value or 1
  LuckyScrapGoldSystem.ext_info.discount_draw_time = discount_draw_time or 0
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_SCRAPGOLD_DISCOUNT_UPDATE)
end
function LuckyScrapGoldSystem.GetBigImage()
  if not LuckyScrapGoldSystem.ext_info or not LuckyScrapGoldSystem.ext_info.big_image_cdn then
    log(bWriteLog and "LuckyScrapGoldSystem.GetImageList not LuckyScrapGoldSystem.ext_info.cdn_pic_path_list")
    return
  end
  return LuckyScrapGoldSystem.ext_info.big_image_cdn
end
function LuckyScrapGoldSystem.UpdatePlayerData()
  LuckyScrapGoldSystem.UpdateLuckyValue()
end
function LuckyScrapGoldSystem.UpdateLuckyValue()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetActivityByID(LuckyScrapGoldSystem.ActivityId)
  if ActivityData and ActivityData.other.ext_info and ActivityData.other.ext_info.cur_luck_value then
    LuckyScrapGoldSystem.playerData.CurLuckyValue = ActivityData.other.ext_info.cur_luck_value
  else
    log(bWriteLog and "LuckyScrapGoldSystem.UpdateLuckyValue ActivityId" .. tostring(LuckyScrapGoldSystem.ActivityId))
    log_tree("UpdateLuckyValue ActivityData ", ActivityData)
    LuckyScrapGoldSystem.playerData.CurLuckyValue = 0
  end
end
function LuckyScrapGoldSystem.GetLuckyLevel(CurValue)
  if not LuckyScrapGoldSystem.ext_info or not LuckyScrapGoldSystem.ext_info.luck_probality_promotion then
    return 0
  end
  for index, LevelValue in ipairs(LuckyScrapGoldSystem.ext_info.luck_probality_promotion) do
    if CurValue < LevelValue.start_value then
      return index
    end
  end
  return #LuckyScrapGoldSystem.ext_info.luck_probality_promotion + 1
end
function LuckyScrapGoldSystem.GetCurLuckyValue()
  return LuckyScrapGoldSystem.playerData.CurLuckyValue
end
function LuckyScrapGoldSystem.GetMaxLuckyValue()
  if LuckyScrapGoldSystem.ext_info and LuckyScrapGoldSystem.ext_info.print_must_drop_value then
    return LuckyScrapGoldSystem.ext_info.print_must_drop_value
  else
    log(bWriteLog and "LuckyScrapGoldSystem.GetMaxLuckyValue ActivityId" .. tostring(LuckyScrapGoldSystem.ActivityId))
    log_tree("GetCurLuckyValue ext_info ", LuckyScrapGoldSystem.ext_info)
    return 0
  end
end
function LuckyScrapGoldSystem.GetLuckyProgress()
  local CurLuckyValue = LuckyScrapGoldSystem.GetCurLuckyValue()
  local MaxLuckyValue = LuckyScrapGoldSystem.GetMaxLuckyValue()
  if not MaxLuckyValue or MaxLuckyValue == 0 then
    log(bWriteLog and "LuckyScrapGoldSystem GetLuckyRate MaxLuckyValue" .. tostring(MaxLuckyValue))
    return 0
  end
  return CurLuckyValue / MaxLuckyValue
end
function LuckyScrapGoldSystem.SetIsShowAnimation(status)
  local activity = LuckyScrapGoldSystem.ActivityId or 0
  LuckyScrapGoldSystem.IsShowAnimation[activity] = status
end
function LuckyScrapGoldSystem.GetIsShowAnimation()
  local activity = LuckyScrapGoldSystem.ActivityId or 0
  if LuckyScrapGoldSystem.IsShowAnimation[activity] == nil then
    LuckyScrapGoldSystem.IsShowAnimation[activity] = true
  end
  return LuckyScrapGoldSystem.IsShowAnimation[activity]
end
function LuckyScrapGoldSystem.GetNextProcess(CurValue, Activity)
  local Config = LuckyScrapGoldSystem.GetTotalDrawAwardConfig(Activity or LuckyScrapGoldSystem.ActivityId)
  local progress = 0
  if not Config then
    log(bWriteLog and "LuckyScrapGoldSystem GetNextProcess not Config" .. tostring(Activity))
    return
  end
  for _, value in pairs(Config) do
    progress = value.progress
    if CurValue < progress then
      return value.progress
    end
  end
  return progress
end
function LuckyScrapGoldSystem.CanGetSumReward(Activity)
  local Config = LuckyScrapGoldSystem.GetTotalDrawAwardConfig(Activity or LuckyScrapGoldSystem.ActivityId)
  for key, value in pairs(Config) do
    if value.status == ActivityProgressStatus.Done then
      return true
    end
  end
  return false
end
function LuckyScrapGoldSystem.GetEndWeekTime()
  if not LuckyScrapGoldSystem.ext_info then
    return 0
  end
  return LuckyScrapGoldSystem.ext_info.end_week_timestamp
end
function LuckyScrapGoldSystem.GetExtInfo()
  return LuckyScrapGoldSystem.ext_info
end
function LuckyScrapGoldSystem.DoDraw(draw_type, coupon_id)
  log(bWriteLog and "LuckyScrapGoldSystem DoDraw draw_type: " .. tostring(draw_type) .. " coupon_id: " .. tostring(coupon_id))
  local Logic_LuckyDouble_Activity = require("client.slua.logic.lobby_activity.logic_luckydouble_activity")
  local playerData = LuckyScrapGoldSystem.playerData
  local price = 0
  local isEnough = true
  local DrawTimes = 0
  if draw_type == 1 then
    if not LuckyScrapGoldSystem.IsLotteryTicket(coupon_id) then
      isEnough, price = Logic_LuckyDouble_Activity.JudgeIsEnoughUC(playerData.oneDrawFinalPrice, coupon_id)
    end
    DrawTimes = 1
  else
    if not LuckyScrapGoldSystem.IsLotteryTicket(coupon_id) then
      isEnough, price = Logic_LuckyDouble_Activity.JudgeIsEnoughUC(playerData.tenDrawFinalPrice, coupon_id)
    end
    DrawTimes = 10
  end
  if isEnough then
    local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
    local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
    SpecialLuckNetWork.send_do_draw_act_req(LuckyScrapGoldSystem.ActivityId, coupon_id, CoinMacro.Uc, DrawTimes)
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_SKIP_ANDROIDBACK)
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SCRAPGOLD_STOP_COIN_UPDATE)
  else
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(price)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SCRAPGOLD_CLOSE_REWRAD)
  end
end
function LuckyScrapGoldSystem.OnDoDrawRsp(activity_id, item_list, decompose_list, ext_info)
  log_tree(" LuckyScrapGoldSystem.OnDoDrawRsp item_list", item_list)
  log_tree(" LuckyScrapGoldSystem.OnDoDrawRsp decompose_list", decompose_list)
  log_tree(" LuckyScrapGoldSystem.OnDoDrawRsp ext_info", ext_info)
  local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
  logic_lucky_exchange.UpdateExchangeCurrencyCount(LuckyScrapGoldSystem.exchange_act_id)
  LuckyScrapGoldSystem.award_info = item_list
  LuckyScrapGoldSystem.decomposeList = decompose_list
  LuckyScrapGoldSystem.playerData.everyday_first_got_gold_item_flag = ext_info.everyday_first_got_gold_item_flag
  LuckyScrapGoldSystem.UpdatePlayerData()
  LuckyScrapGoldSystem.UpdateTotalDrawTime(activity_id)
  LuckyScrapGoldSystem.UpdateWeekDrawTime(activity_id)
  _UpdatePriceInfo(ext_info.is_first_dis_for_week)
  _UpdateDropList(item_list)
  _PostDrawEvent()
  _PostStatusChangeEvent()
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SCRAPGOLD_STOP_COIN_UPDATE_TIMER)
end
function LuckyScrapGoldSystem.SetDrawAgain(bIsDrawAgain)
  LuckyScrapGoldSystem.end
function LuckyScrapGoldSystem.GetDrawAgain()
  return LuckyScrapGoldSystem.bIsDrawAgain
end
function LuckyScrapGoldSystem.SetSumRewardList(sum_reward_list)
  LuckyScrapGoldSystem.SumRewardList = sum_reward_list
end
function LuckyScrapGoldSystem.UpdateTotalDrawTime(activity_id)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetActivityByID(activity_id)
  if not ActivityData then
    log_error("LuckyScrapGoldSystem.UpdateTotalDrawTime not ActivityData")
    return
  end
  log_tree("LuckyScrapGoldSystem.UpdateTotalDrawTime ActivityData", ActivityData)
  if ActivityData.other.ext_info then
    LuckyScrapGoldSystem.playerData.totalDrawTime = ActivityData.other.ext_info.total_draw_times
  else
    log_error("LuckyScrapGoldSystem ext_info is nil activity_id " .. tostring(activity_id))
    LuckyScrapGoldSystem.playerData.totalDrawTime = 0
  end
end
function LuckyScrapGoldSystem.UpdateWeekDrawTime(activity_id)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetActivityByID(activity_id)
  log_tree("LuckyScrapGoldSystem.UpdateWeekDrawTime ActivityData", ActivityData)
  if ActivityData and ActivityData.other and ActivityData.other.ext_info then
    LuckyScrapGoldSystem.playerData.draw_times_week = ActivityData.other.ext_info.draw_times_week
  else
    log_error("LuckyScrapGoldSystem ext_info is nil activity_id " .. tostring(activity_id))
    LuckyScrapGoldSystem.playerData.draw_times_week = 0
  end
end
function LuckyScrapGoldSystem.GetTotalDrawAwardConfig(activity_id)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetActivityByID(activity_id or LuckyScrapGoldSystem.ActivityId)
  if not ActivityData then
    log(bWriteLog and "LuckyScrapGoldSystem GetTotalDrawAwardConfig activity_id " .. tostring(activity_id) .. "ActivityId " .. tostring(LuckyScrapGoldSystem.ActivityId))
    return {}
  end
  local data = ActivityData.other.sum_reward_list
  local list = {}
  for _, v in pairs(data) do
    if v.Status == ActivityProgressStatus.Get then
      v.hasGet = true
    end
    table.insert(list, v)
  end
  table.sort(list, function(a, b)
    return a.progress < b.progress
  end)
  return list
end
function LuckyScrapGoldSystem.OpenUI()
  UIManager.ShowUI(UIManager.UI_Config.LuckySpinScrapGold)
end
function LuckyScrapGoldSystem.ShowItemGetPanel(JumpAnim)
  if LuckyScrapGoldSystem.dropList == nil or next(LuckyScrapGoldSystem.dropList) == nil then
    return
  end
  local decomposeList = {}
  for i, v in pairs(LuckyScrapGoldSystem.decomposeList) do
    decomposeList[i] = {
      itemid = v.resid,
      count = v.count
    }
  end
  local list = {}
  for _, v in pairs(LuckyScrapGoldSystem.dropList) do
    local item = {
      res_id = v.res_id,
      valid_hours = v.valid_hours,
      count = v.count
    }
    table.insert(list, item)
  end
  local Config = {
    DrawPrice = LuckyScrapGoldSystem.playerData.oneDrawFinalPrice,
    DrawNum = 1,
      }
  if #LuckyScrapGoldSystem.dropList > 1 then
    Config.DrawPrice = LuckyScrapGoldSystem.playerData.tenDrawFinalPrice
    Config.DrawNum = 10
  end
  UIManager.ShowUI(UIManager.UI_Config.ScrapGold_Reward_UIBP, list, decomposeList, Config)
  LuckyScrapGoldSystem.dropList = {}
end
function LuckyScrapGoldSystem.RemoveDecomposedItem()
  local decomposeList = LuckyScrapGoldSystem.decomposeList
  local award_info = LuckyScrapGoldSystem.award_info
  local TableUtil = require("common.table_util")
  local decomposeNum = TableUtil.CountTable(decomposeList)
  local decomposeResIds = {}
  if 0 < decomposeNum and award_info and next(award_info) then
    for key, v in pairs(LuckyScrapGoldSystem.decomposeList) do
      if LuckyScrapGoldSystem.award_info[key] then
        table.insert(decomposeResIds, LuckyScrapGoldSystem.award_info[key].resid)
      end
    end
  end
end
function LuckyScrapGoldSystem.GetDropItemsLastPos()
  if not LuckyScrapGoldSystem.dropList or not next(LuckyScrapGoldSystem.dropList) then
    return 1
  else
    return LuckyScrapGoldSystem.dropList[#LuckyScrapGoldSystem.dropList].pos_id
  end
end
local _GetExchangeKeyInBaseConfig = function()
  local config = require("client.slua.logic.lobby_activity.LuckySpinConfig")
  local cfg = config.Exchange[LuckyScrapGoldSystem.exchangeResourceType]
  if type(cfg) == "table" then
    cfg = cfg.BaseBp
  elseif type(cfg) == "string" then
  else
    log_error(bWriteLog and "[cw] cfg is nil, please check the LuckySpinConfig base on the resource type: " .. tostring(LuckybackActivitySystem.resourceType))
    return
  end
  return cfg
end
function LuckyScrapGoldSystem.OnDrawSumRsp(activity_id, award_list)
  _ShowCommonItemPanel(award_list)
  local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
  logic_lucky_exchange.UpdateExchangeCurrencyCount(LuckyScrapGoldSystem.exchange_act_id)
  _PostStatusChangeEvent()
end
function LuckyScrapGoldSystem.OnExtraRewardRsp(activity_id, item_list)
  _ShowCommonItemPanel(item_list)
  _PostStatusChangeEvent()
end
function LuckyScrapGoldSystem.OpenExchangeStore(pageID, itemId)
  local isCanDrawDiscount = LuckyScrapGoldSystem.IsTimeInExchangeDiscountEvent() and not LuckyScrapGoldSystem.IsDrawExchangeDiscount()
  if isCanDrawDiscount then
    UIManager.ShowUI(UIManager.UI_Config.ScrapGold_Discount_UIBP, pageID, itemId)
  else
    if itemId then
      local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
      logic_lucky_exchange.SetCurSelectItemID(LuckyScrapGoldSystem.exchange_act_id, itemId)
    end
    UIManager.ShowUI(UIManager.UI_Config.ScrapGold_Exchange_UIBP, pageID)
  end
end
function LuckyScrapGoldSystem.IsFirstPriceValid()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  local data = activityDataTable[logic_scrapgold_draw.ActivityId]
  if data == nil then
    return false
  end
  if data.cfg and data.cfg.award and data.cfg.award[1] and data.cfg.award[1].cond_list and data.cfg.award[1].cond_list[5] then
    local days = tonumber(data.cfg.award[1].cond_list[5])
    if days and 0 < days then
      local start_time = data.cfg.start_time
      local TimeUtil = require("client.common.time_util")
      local cur_time = TimeUtil.GetServerTimeInSec()
      if cur_time > start_time + (days - 1) * 24 * 60 * 60 + TimeUtil.GetTodayTimestamp() then
        return false
      end
    end
  end
  local originalPrice = logic_scrapgold_draw.GetOneDrawOriginalPrice()
  local oneDrawFinalPrice = logic_scrapgold_draw.playerData.oneDrawFinalPrice
  if originalPrice == oneDrawFinalPrice then
    return false
  end
  return true
end
function LuckyScrapGoldSystem.GetBluePrintPath()
  return "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_Main_UIBP.ScrapGold_Main_UIBP"
end
function LuckyScrapGoldSystem.UpdateBuyGiftPackage(_, _, info)
  local nMarketID = LuckyScrapGoldSystem.GetLotteryTicketGiftMarketID()
  if info and info.market_id ~= nMarketID then
    return
  end
  LuckyScrapGoldSystem.is_first_buy_voucher_for_version = false
  log(bWriteLog and "LuckyScrapGoldSystem has buy gift")
end
function LuckyScrapGoldSystem.HasBuyLotteryTicketGift()
  return LuckyScrapGoldSystem.is_first_buy_voucher_for_version ~= true
end
function LuckyScrapGoldSystem.NeedShowLotteryTicketGift()
  return not LuckyScrapGoldSystem.HasBuyLotteryTicketGift()
end
function LuckyScrapGoldSystem.ReqBuyLotteryTicket(tData, tInfo, tExtraData, nCurCouponId)
  if not LuckyScrapGoldSystem.ActivityId then
    log_error("[LuckyScrapGoldSystem] no actid")
    return
  end
  local data = {}
  data[StoreConst.label_buy_param_id] = tData.goodsId
  data[StoreConst.label_buy_param_price_type] = tData.priceType
  data[StoreConst.label_buy_param_tab_id] = tData.tabId
  data[StoreConst.label_buy_param_valid_hours] = tData.valid_hours
  data[StoreConst.label_buy_param_count] = tExtraData and tExtraData.count and tExtraData.count or tData.itemNum
  if nCurCouponId and 0 < nCurCouponId then
    data[StoreConst.label_buy_param_voucher] = nCurCouponId
  end
  data[StoreConst.label_buy_param_act_id] = LuckyScrapGoldSystem.ActivityId
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:buy_market_by_id_req(data)
end
function LuckyScrapGoldSystem.GetTenDrawLotteryTicketCount()
  local nResID = LuckyScrapGoldSystem.GetTenDrawLotteryTicketID()
  if not nResID then
    return 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local item_cfg = CDataTable.GetTableData("Item", nResID)
  if not item_cfg then
    log_error("LuckyScrapGoldSystem itemcfg is nil" .. tostring(nResID))
    return 0
  end
  local nCount = wardrobe_data:GetHallDepotItemCountByResID(nResID, item_cfg.ValidTimes and item_cfg.ValidTimes ~= 0)
  return nCount or 0
end
function LuckyScrapGoldSystem.GetTenDrawLotteryTicketID()
  return LuckyScrapGoldSystem.tenDrawID
end
function LuckyScrapGoldSystem.GetLotteryTicketGiftTabID()
  return LuckyScrapGoldSystem.tenDrawTabID
end
function LuckyScrapGoldSystem.GetLotteryTicketGiftMarketID()
  return LuckyScrapGoldSystem.ten_draw_market_id
end
function LuckyScrapGoldSystem.IsLotteryTicket(nCouponID)
  if not nCouponID then
    return false
  end
  local nLotteryTicketID = LuckyScrapGoldSystem.GetTenDrawLotteryTicketID()
  return nCouponID == nLotteryTicketID
end
local EventSystem = require("client.common.event.EventSystem")
if EventSystem then
  EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, LuckyScrapGoldSystem.UpdateBuyGiftPackage)
  if log then
    log(bWriteLog and "LuckyScrapGoldSystem register UpdateBuyGiftPackage")
  end
end
return LuckyScrapGoldSystem