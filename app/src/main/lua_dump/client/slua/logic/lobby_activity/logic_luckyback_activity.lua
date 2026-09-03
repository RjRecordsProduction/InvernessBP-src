local test_backupOne, test_BPPath, test_BPCfg
local super_data = require("common.super_data")
local button_type = {
  CarType = 1,
  CopyRightType = 2,
  H5Type = 3
}
local LuckybackActivitySystem = {
  SnatchUC = {
    0,
    0,
    0
  },
  TimePeriodStr = "",
  TotalSnatchTimes = {},
  curLuckyValue = 0,
  IsDailyDiscount = 0,
  IsShowAnimation = {},
  resCfg = {},
  resMyData = {},
  RedDotMap = {},
  DiyWeaponIdMap = {},
  award_info = nil,
  tExtraGetData = nil,
  isWaitingForRes = false,
  isClicked = true,
  activityId = 0,
  moduleId = 0,
  resourceType = 0,
  entranceType = 0,
  exchangeTabId = 1,
  poolItemConfig = {},
  dropList = {},
  decomposeList = {},
  totalDrawAwardConfig = {},
  newtotalDrawAwardConfig = {},
  exchangeItemList = {},
  hasExchangeList = {},
  exchangeInfo = {},
  exchangeDataCacheTime = {},
  EXCHANGE_DATA_CATCH_TIME = 300,
  got_collected_award = false,
  globalConfig = {
    startTime = 0,
    endTime = 0,
    probability = "",
    videoPath = "",
    returnJumpUrl = "",
    oneDrawOriginalPrice = 0,
    oneDrawDailyDiscountPrice = 0,
    tenDrawOriginalPrice = 0,
    oneDrawLimitTimes = 0,
    tenDrawLimitTimes = 0,
    isUseLuckyValue = false,
    luckyHintTextKey = nil,
    totalDrawHintTextKey = nil,
    maxLuckyValue = 0,
    luckySpecialFlag = 0,
    luckyValueStageTable = {},
    debrisFxBarList = {},
    finalAwardId = 0,
    exchangeDebrisId1 = 0,
    exchangeDebrisId = 0,
    isShowDebrisIcon = 0,
    weaponJumpLink = "",
    showVehicleNewBieGuide = false,
    voucherConfig = {},
    WeaponUpdateData = {},
    goldenCollectRewardInfo = {},
    collectItemList = {},
    goldDrawBackFlag = 0,
    motion_effect_type = 0,
    title_color = 0
  },
  exchangeConfig = {
    exchangeActId = 0,
    exchangeDescriptionTextKey = nil,
    exchangeResourceType = 0,
    isExchangeOpen = false,
    exchangeBgImage = "",
    exchangeBgBluePrintPath = ""
  },
  redPoint = {
    discountRedPoint = false,
    bannerRedPoint = true,
    lastRedDot = false,
    curRedDot = false
  },
  drawRewardRed = {},
  collectRewardRed = {},
  styleConfig = {mainPoolStyle = 0},
  bluePathConfig = {
    bg_path = "",
    pan_bg_img = "",
    sum_award_box_img = "",
    sum_award_bg_img = ""
  },
  activityId2ShowPanelFunc = {},
  playerData = super_data.CreateSuperData({
    totalDrawTime = 0,
    one_draw_times = 0,
    duo_draw_times = 0,
    curLuckyValue = 0,
    hasDailyOneDrawDiscount = false,
    hasEasterEggDiscount = false,
    discountType = 0,
    oneDrawFinalPrice = 0,
    tenDrawFinalPrice = 0,
    debrisItemCount = 0,
    debrisItemCount1 = 0,
    PTPoints = 0
  }),
  Enum_DrawType = {One_Draw = 1, Ten_Draw = 2},
  Enum_Err_Code = {
    success = 0,
    activity_errcode_activity_have_end = 108108,
    activity_errcode_param_error = 108109,
    activity_errcode_activity_not_exist = 108101,
    luckyback_err_need_res_not_enough = 6494,
    luckyback_err_pay_error = 995002,
    luckyback_err_voucher_not_exist = 995003,
    luckyback_err_can_not_next_round = 995004
  },
  Enum_LuckyBack_Entrance_Type = {
    Gun = 1,
    Clothes = 2,
    Car = 4
  },
  CONST = {
    DEFAULT_LUCKY_HINT_TEXT_KEY = 48085,
    DEFAULT_TOTAL_DRAW_HINT_TEXT_KEY = 48084,
    DEFAULT_EXCHANGE_DESCRIPTION_TEXT_KEY = 48086
  },
  EggItem_List = {},
  EasterEggSuccessFuc = nil,
  MainAwardWeight = 0,
  backExchangeID = {},
  backExchangeCoinAndActID = {},
  backExchangeData = {}
}
local _SetActivityId = function(actId)
  LuckybackActivitySystem.activityId = tonumber(actId)
end
local _SetExchangeActivityId = function(exchangeActId)
  LuckybackActivitySystem.exchangeConfig.exchangeActId = tonumber(exchangeActId) or 0
end
local _SetActPeriod = function(start_time, end_time)
  LuckybackActivitySystem.globalConfig.startTime = start_time
  LuckybackActivitySystem.globalConfig.endTime = end_time
  local TimeUtil = require("client.common.time_util")
  LuckybackActivitySystem.TimePeriodStr = TimeUtil.FormatTime_timeFrame(start_time, end_time, false, true)
end
local _SetResourceType = function(label_type)
  LuckybackActivitySystem.resourceType = label_type
end
local _SetExchangeResourceType = function(type)
  LuckybackActivitySystem.exchangeConfig.exchangeResourceType = type
end
local _SetReturnJumpUrl = function(return_jump_link)
  LuckybackActivitySystem.globalConfig.returnJumpUrl = return_jump_link or ""
end
local _SetVehicleNewBieGuid = function(bShow)
  LuckybackActivitySystem.globalConfig.showVehicleNewBieGuide = bShow or false
end
local _ToggleDelayDecompose = function(isDelay)
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.needDelay = isDelay or false
end
local _DelayPopDecoMaterialTips = function()
  if LuckybackActivitySystem.decomposeList ~= nil and next(LuckybackActivitySystem.decomposeList) and LuckybackActivitySystem.award_info and next(LuckybackActivitySystem.award_info) then
    for key, v in pairs(LuckybackActivitySystem.decomposeList) do
      if LuckybackActivitySystem.award_info[key] then
        local cfg = CDataTable.GetTableData("Item", LuckybackActivitySystem.award_info[key].resid)
        if cfg and cfg.ItemName then
          for id, cnt in pairs(v) do
            local toItemCfg = CDataTable.GetTableData("Item", id)
            if toItemCfg and toItemCfg.ItemName then
              local content = LocUtil.LocalizeResFormat(6345, cfg.ItemName, cnt, toItemCfg.ItemName)
              ShowNotice(content)
            end
          end
        end
      end
    end
    LuckybackActivitySystem.decomposeList = nil
    LuckybackActivitySystem.award_info = nil
  end
end
local _DelayDecompose = function()
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.delay_item_decompose_notice()
  _DelayPopDecoMaterialTips()
end
local _ToggleBlockAchievement = function(isBlock)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockingPopTip = isBlock or false
  if isBlock then
    logic_achievement_float_tip.BlockPopTip()
  end
end
local _ClearDropList = function()
  LuckybackActivitySystem.dropList = {}
  LuckybackActivitySystem.tExtraGetData = nil
end
local _FormatData = function(data)
  local arrayItemList = {}
  for i, v in pairs(data) do
    local arrayItem = {
      res_id = v.resid,
      expire_ts = v.expire_ts or 0,
      valid_hours = v.valid_hours or 0,
      count = v.count
    }
    table.insert(arrayItemList, arrayItem)
  end
  return arrayItemList
end
local _UpdateDropList = function(award_info)
  for i, v in pairs(award_info) do
    local arrayItem = {
      res_id = v.resid,
      expire_ts = 0,
      valid_hours = v.valid_hours,
      count = v.count,
      pos_id = v.pos_id,
      recommend_level = v.recommend_level,
      rankTitleType = v.rankTitleType,
      chief_event_share_count_bak = v.chief_event_share_count_bak,
      king_event_share_count_bak = v.king_event_share_count_bak
    }
    log(bWriteLog and "[SY]_UpdateDropList." .. tostring(v.chief_event_share_count_bak) .. "    :" .. tostring(v.king_event_share_count_bak))
    table.insert(LuckybackActivitySystem.dropList, arrayItem)
  end
end
local _ReportCost = function()
  local tlog_commercial_cost = require("client.slua.config.tlog.tlog_commercial_cost")
  tlog_commercial_cost.ReportCost(tlog_commercial_cost.Enum_Scene.LuckyBack, LuckybackActivitySystem.activityId, #LuckybackActivitySystem.dropList)
end
local _SetProbability = function(probability)
  LuckybackActivitySystem.globalConfig.end
local _SetVideoPath = function(path)
  LuckybackActivitySystem.globalConfig.videoPath = path or ""
end
local _SetTotalDrawTime = function(num)
  local playerData = LuckybackActivitySystem.playerData
  playerData.totalDrawTime = num
  LuckybackActivitySystem.TotalSnatchTimes[LuckybackActivitySystem.activityId] = num
end
local _SetOneDrawTime = function(num)
  local playerData = LuckybackActivitySystem.playerData
  playerData.one_draw_times = num or 0
end
local _SetTenDrawTime = function(num)
  local playerData = LuckybackActivitySystem.playerData
  playerData.duo_draw_times = num or 0
end
local _SetFinalAward = function(itemId)
  LuckybackActivitySystem.globalConfig.finalAwardId = itemId or 0
end
local _SetDiscountInfo = function(uc_discount_by_day)
  LuckybackActivitySystem.globalConfig.oneDrawDailyDiscountPrice = uc_discount_by_day
end
local _SetPriceInfo = function(price_table)
  local playerData = LuckybackActivitySystem.playerData
  if price_table and next(price_table) then
    LuckybackActivitySystem.globalConfig.oneDrawOriginalPrice = price_table[1].price
    LuckybackActivitySystem.globalConfig.tenDrawOriginalPrice = price_table[1].price * 10
    playerData.tenDrawFinalPrice = price_table[2] and price_table[2].price or 0
    LuckybackActivitySystem.globalConfig.oneDrawLimitTimes = price_table[1] and price_table[1].limit_draw_times or 0
    LuckybackActivitySystem.globalConfig.tenDrawLimitTimes = price_table[2] and price_table[2].limit_draw_times or 0
    LuckybackActivitySystem.SnatchUC = {
      0,
      price_table[2] and price_table[2].price or 0,
      price_table[1].price
    }
  else
    LuckybackActivitySystem.globalConfig.oneDrawOriginalPrice = 0
    LuckybackActivitySystem.globalConfig.tenDrawOriginalPrice = 0
    LuckybackActivitySystem.globalConfig.oneDrawLimitTimes = 0
    LuckybackActivitySystem.globalConfig.tenDrawLimitTimes = 0
    LuckybackActivitySystem.SnatchUC = {}
  end
end
local _TransPath = function(path)
  if path and path ~= "" then
    local replacePart = "OtherSpin/1400"
    local toResult = "1400"
    local res, res2 = string.find(path, replacePart)
    if res and res2 then
      return string.gsub(path, replacePart, toResult)
    end
  end
  return path
end
local _SetBackgroundResourceConfig = function(blue_path)
  LuckybackActivitySystem.bluePathConfig.bg_path = _TransPath(blue_path)
end
local _SetExchangeBackgroundResourceConfig = function(sBgBpPath)
  if sBgBpPath then
    LuckybackActivitySystem.exchangeConfig.exchangeBgBluePrintPath = _TransPath(tostring(sBgBpPath))
  end
  if test_BPPath and test_BPPath.exchangePath then
    LuckybackActivitySystem.exchangeConfig.exchangeBgBluePrintPath = test_BPPath.exchangePath
    log_error(bWriteLog and "[cw][test] using test_BPPath.exchangePath filed(" .. tostring(test_BPPath.exchangePath) .. "), please don't forget to uncomment it after test")
  end
end
local _SetSumAwardBoxImg = function(sum_award_box_img)
  LuckybackActivitySystem.bluePathConfig.sum_award_box_img = _TransPath(sum_award_box_img)
end
local _SetSumAwardBgImg = function(sum_award_bg_img)
  LuckybackActivitySystem.bluePathConfig.sum_award_bg_img = _TransPath(sum_award_bg_img)
end
local _SetGoldenClothCollectRewardInfo = function(itemId, num, valid_hours)
  if itemId and 0 < itemId then
    LuckybackActivitySystem.globalConfig.goldenCollectRewardInfo[1] = {
      res_id = itemId,
      count = num or 1,
      valid_hours = valid_hours or 0
    }
  else
    LuckybackActivitySystem.globalConfig.goldenCollectRewardInfo = {}
  end
end
local _UpdateGoldenClothCollectGetState = function(got_collected_award)
  LuckybackActivitySystem.got_collected_award = got_collected_award or false
end
local _SetPoolResourceConfig = function(pan_bg_img)
  LuckybackActivitySystem.bluePathConfig.pan_bg_img = _TransPath(pan_bg_img)
end
local _SetIsUseLuckyInfo = function(is_use_lucky_value)
  LuckybackActivitySystem.globalConfig.isUseLuckyValue = is_use_lucky_value
end
local _SetLuckyHintTextKe = function(nKey)
  if nKey == nil or nKey == 0 then
    nKey = LuckybackActivitySystem.CONST.DEFAULT_LUCKY_HINT_TEXT_KEY
  end
  LuckybackActivitySystem.globalConfig.luckyHintTextKey = nKey
end
local _SetTotalDrawHintTextKey = function(nKey)
  if nKey == nil or nKey == 0 then
    nKey = LuckybackActivitySystem.CONST.DEFAULT_TOTAL_DRAW_HINT_TEXT_KEY
  end
  LuckybackActivitySystem.globalConfig.totalDrawHintTextKey = nKey or nil
end
local _SetMaxLuckyValue = function(max_lucky_value)
  LuckybackActivitySystem.globalConfig.maxLuckyValue = max_lucky_value
end
local _SetLuckyValueStageTable = function(lucky_value_table)
  local result = {}
  if lucky_value_table then
    for _, v in ipairs(lucky_value_table) do
      table.insert(result, {
        min = v.min_lucky_value or 0,
        max = v.max_lucky_value
      })
    end
  end
  LuckybackActivitySystem.globalConfig.luckyValueStageTable = result
end
local _UpdateLuckyValue = function(cur_lucky_value)
  if cur_lucky_value then
    local playerData = LuckybackActivitySystem.playerData
    playerData.curLuckyValue = cur_lucky_value
    LuckybackActivitySystem.curLuckyValue = cur_lucky_value
  end
end
local _SetExchangeDebrisId = function(itemId, itemId1)
  if itemId then
    LuckybackActivitySystem.globalConfig.exchangeDebrisId = itemId
  end
  LuckybackActivitySystem.globalConfig.exchangeDebrisId1 = itemId1
end
local _SetExchangeDescriptionTextKey = function(nKey)
  if nKey == nil or nKey == 0 then
    nKey = LuckybackActivitySystem.CONST.DEFAULT_EXCHANGE_DESCRIPTION_TEXT_KEY
  end
  LuckybackActivitySystem.exchangeConfig.exchangeDescriptionTextKey = nKey or nil
end
local _SetCouponSystemScene = function(gold_draw_back_flag)
  if gold_draw_back_flag then
    LuckybackActivitySystem.globalConfig.goldDrawBackFlag = gold_draw_back_flag
  end
end
function LuckybackActivitySystem.GetDrawBackFlag()
  return LuckybackActivitySystem.globalConfig.goldDrawBackFlag
end
function LuckybackActivitySystem.GetLuckyValueStageConfig()
  return LuckybackActivitySystem.globalConfig.luckyValueStageTable or {}
end
function LuckybackActivitySystem.IsLuckySpecialMode()
  return LuckybackActivitySystem.globalConfig.luckySpecialFlag == 1
end
function LuckybackActivitySystem.IsFinalAwardGot()
  if not LuckybackActivitySystem.IsLuckySpecialMode() then
    return false
  end
  local finalAwardId = LuckybackActivitySystem.globalConfig.finalAwardId
  if not finalAwardId or finalAwardId == 0 then
    return false
  end
  local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
  return StoreUtils.IsPossessed(finalAwardId) == true
end
function LuckybackActivitySystem.GetEntryAnimType()
  return LuckybackActivitySystem.globalConfig.motion_effect_type or 0
end
function LuckybackActivitySystem.GetTitleColorType()
  return LuckybackActivitySystem.globalConfig.title_color or 0
end
function LuckybackActivitySystem.CheckIsSmallRPRelated()
  local nActFlagType = LuckybackActivitySystem.GetDrawBackFlag()
  local nCurActId = LuckybackActivitySystem.activityId
  local luck_util = require("client.slua.logic.lobby_activity.luck_util")
  local bIsSmallRPRelated = luck_util.CheckLuckyBackActIsSmallRPRelated(nActFlagType, nCurActId)
  return bIsSmallRPRelated
end
local _SetExchangeBgImg = function(activity_image_link)
  if activity_image_link then
    LuckybackActivitySystem.exchangeConfig.exchangeBgImage = _TransPath(activity_image_link)
  end
end
local _UpdateDiscountRedPoint = function(bShow)
  LuckybackActivitySystem.redPoint.discountRedPoint = bShow or false
end
local _UpdateCurRedDot = function(bShow)
  LuckybackActivitySystem.redPoint.curRedDot = bShow or false
end
local _UpdateDebrisCount = function()
  local playerData = LuckybackActivitySystem.playerData
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(LuckybackActivitySystem.globalConfig.exchangeDebrisId)
  if itemData ~= nil then
    playerData.debrisItemCount = itemData.count
  else
    playerData.debrisItemCount = 0
  end
  itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(LuckybackActivitySystem.globalConfig.exchangeDebrisId1)
  playerData.debrisItemCount1 = itemData and itemData.count or 0
end
local _SetEntranceType = function(rel_activity_type)
  LuckybackActivitySystem.entranceType = rel_activity_type
end
local _SetTopRightDebrisIconShow = function(show)
  LuckybackActivitySystem.globalConfig.isShowDebrisIcon = show
end
local _SetWeaponJumpLink = function(module_jump_link)
  LuckybackActivitySystem.globalConfig.weaponJumpLink = module_jump_link or ""
end
local _SetPoolItemConfig = function(itemTable)
  LuckybackActivitySystem.poolItemConfig = {}
  LuckybackActivitySystem.globalConfig.collectItemList = {}
  LuckybackActivitySystem.MainAwardWeight = 0
  local curWeightCount = 0
  if itemTable then
    for _, v in ipairs(itemTable) do
      table.insert(LuckybackActivitySystem.poolItemConfig, {
        itemId = v.award_item_id,
        itemCount = v.award_item_num,
        style = v.style,
        posId = v.pos_id,
        award_weight = v.award_weight,
        vaild_time = v.award_item_valid_time,
        is_collected = v.is_collected,
        recommendLevel = v.recommend_level,
        imagePath = v.item_image_cdn,
        itemQuality = v.show_quality
      })
      if v.is_collected and v.is_collected == 1 then
        table.insert(LuckybackActivitySystem.globalConfig.collectItemList, {
          itemId = v.award_item_id,
          itemCount = v.award_item_num,
          posId = v.pos_id,
          vaild_time = v.award_item_valid_time
        })
      end
      if curWeightCount < 4 and v.award_weight > LuckybackActivitySystem.MainAwardWeight then
        curWeightCount = curWeightCount + 1
        LuckybackActivitySystem.MainAwardWeight = v.award_weight
      end
    end
  else
    log_error(bWriteLog and "[SY]_SetPoolItemConfig. itemTable is nil")
  end
  log(bWriteLog and "[SY]_SetPoolItemConfig." .. LuckybackActivitySystem.MainAwardWeight)
  table.sort(LuckybackActivitySystem.poolItemConfig, function(a, b)
    return a.posId < b.posId
  end)
end
local _SetDebrisFxBarList = function(show_fx_value_list)
  LuckybackActivitySystem.globalConfig.debrisFxBarList = show_fx_value_list
end
local _SetVoucherConfig = function(draw_back_voucher)
  if draw_back_voucher and next(draw_back_voucher) then
    LuckybackActivitySystem.globalConfig.voucherConfig = draw_back_voucher
  else
    LuckybackActivitySystem.globalConfig.voucherConfig = {}
  end
end
local _SetTotalDrawAwardConfig = function(sum_award_table)
  LuckybackActivitySystem.totalDrawAwardConfig = {}
  for k, v in pairs(sum_award_table) do
    local tmpAward = {
      timesCount = k,
      AwardItems = v,
      hasGet = false
    }
    table.insert(LuckybackActivitySystem.totalDrawAwardConfig, tmpAward)
  end
  table.sort(LuckybackActivitySystem.totalDrawAwardConfig, function(a, b)
    return a.timesCount < b.timesCount
  end)
end
local _SetNewTotalAwardConfig = function(new_sum_award_table)
  LuckybackActivitySystem.newtotalDrawAwardConfig = {}
  for k, v in pairs(new_sum_award_table) do
    local tmpAward = {}
    tmpAward.timesCount = k
    for i, j in pairs(v) do
      tmpAward.AwardItems = {
        [i] = j.count
      }
      tmpAward.valid_hours = j.valid_hours
      tmpAward.hasGet = false
    end
    table.insert(LuckybackActivitySystem.newtotalDrawAwardConfig, tmpAward)
  end
  table.sort(LuckybackActivitySystem.newtotalDrawAwardConfig, function(a, b)
    return a.timesCount < b.timesCount
  end)
end
local _UpdateTotalDrawAwardConfig = function(sum_draw_award_info)
  for _, v in pairs(LuckybackActivitySystem.totalDrawAwardConfig) do
    if sum_draw_award_info[v.timesCount] then
      v.hasGet = true
    end
  end
  LuckybackActivitySystem.CheckCloseAvailableAwardRedDot()
end
local _UpdateNewTotalDrawAwardConfig = function(sum_draw_award_info)
  for _, v in pairs(LuckybackActivitySystem.newtotalDrawAwardConfig) do
    if sum_draw_award_info[v.timesCount] then
      v.hasGet = true
    end
  end
end
local _UpdatePriceInfo = function(is_uc_discount_by_day, isUpdateRedPoint)
  local playerData = LuckybackActivitySystem.playerData
  playerData.hasDailyOneDrawDiscount = is_uc_discount_by_day == 1 and true or false
  if is_uc_discount_by_day == 1 then
    playerData.oneDrawFinalPrice = LuckybackActivitySystem.globalConfig.oneDrawDailyDiscountPrice
    if isUpdateRedPoint and playerData.oneDrawFinalPrice == 0 then
      _UpdateDiscountRedPoint(true)
    end
  else
    playerData.oneDrawFinalPrice = LuckybackActivitySystem.globalConfig.oneDrawOriginalPrice
  end
  LuckybackActivitySystem.IsDailyDiscount = is_uc_discount_by_day
  if is_uc_discount_by_day == 1 then
    LuckybackActivitySystem.SnatchUC[1] = LuckybackActivitySystem.globalConfig.oneDrawDailyDiscountPrice
  else
    LuckybackActivitySystem.SnatchUC[1] = LuckybackActivitySystem.SnatchUC[3]
  end
end
local _SetExchangeDataGetTime = function()
  local TimeUtil = require("client.common.time_util")
  local curTimeStamp = TimeUtil.GetServerTimeInSec()
  LuckybackActivitySystem.exchangeDataCacheTime[LuckybackActivitySystem.exchangeConfig.exchangeActId] = tonumber(curTimeStamp)
end
local _CheckIfNeedUpdateExchangeData = function()
  if not LuckybackActivitySystem.exchangeInfo[LuckybackActivitySystem.exchangeConfig.exchangeActId] or type(LuckybackActivitySystem.exchangeInfo[LuckybackActivitySystem.exchangeConfig.exchangeActId]) ~= "table" or not next(LuckybackActivitySystem.exchangeInfo[LuckybackActivitySystem.exchangeConfig.exchangeActId]) then
    return true
  end
  local TableUtil = require("common.table_util")
  local lastCacheTime = TableUtil.GetTableValue(LuckybackActivitySystem.exchangeDataCacheTime, LuckybackActivitySystem.exchangeConfig.exchangeActId)
  if not lastCacheTime or lastCacheTime == "" or lastCacheTime == 0 then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTimeStamp = TimeUtil.GetServerTimeInSec()
  local dif = math.abs(tonumber(lastCacheTime) - tonumber(curTimeStamp))
  return dif > LuckybackActivitySystem.EXCHANGE_DATA_CATCH_TIME
end
local _PostDrawEvent = function(draw_type)
  local iLen = #LuckybackActivitySystem.dropList
  local index = 1
  if draw_type and draw_type == 1 or iLen == 1 then
    index = LuckybackActivitySystem.dropList[iLen].pos_id
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_DARW_ONE_ANIMATION, index)
  else
    index = LuckybackActivitySystem.dropList[iLen].pos_id
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_DARW_TEN_ANIMATION, index)
  end
end
local _PostIconShow = function()
  local exchangeId = LuckybackActivitySystem.GetDebrisItemIdInExchange()
  if exchangeId and exchangeId ~= 0 then
    EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_CRATE_UPDATE_CURRENCY, exchangeId)
  end
end
local _PostStatusChangeEvent = function()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_STATUS_CHANGE)
end
local _PostConponChangeEvent = function()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_CONPON_STATUS_CHANGE)
end
local _PostExchangeDataRefreshEvent = function()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_REFRESH)
  EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_EXCHANGEDATA_UPDATE)
end
local _SetExchangeActData = function(data)
  _SetExchangeActivityId()
  LuckybackActivitySystem.exchangeConfig.isExchangeOpen = false
  if data and data.cfg and data.cfg.award and next(data.cfg.award) then
    local tmpcond = StrSplit(data.cfg.award[1].cond, ",")
    if tmpcond[1] then
      local actId = tonumber(tmpcond[1])
      _SetExchangeActivityId(actId)
    end
  end
  if LuckybackActivitySystem.exchangeConfig.exchangeActId > 0 then
    LuckybackActivitySystem.exchangeConfig.isExchangeOpen = true
  end
end
local _SetMotionType = function(effectType)
  LuckybackActivitySystem.globalConfig.motion_effect_type = effectType or 0
end
local _SetTitleColor = function(title_color)
  LuckybackActivitySystem.globalConfig.title_color = title_color or 0
end
local _SetConfig = function(serverConfig, myData)
  log(bWriteLog and "[SY]_SetConfig.")
  _SetProbability(serverConfig.global_table.probability)
  _SetMotionType(serverConfig.global_table.motion_effect_type)
  _SetTitleColor(serverConfig.global_table.title_color)
  _SetVideoPath(serverConfig.global_table.movie_path)
  _SetTotalDrawTime(myData.sum_draw_times)
  _SetOneDrawTime(myData.one_draw_times)
  _SetTenDrawTime(myData.duo_draw_times)
  _SetFinalAward(serverConfig.global_table.final_award_id)
  _SetEntranceType(serverConfig.global_table.rel_activity_type)
  _SetWeaponJumpLink(serverConfig.global_table.module_jump_link)
  _SetDiscountInfo(serverConfig.global_table.uc_discount_by_day)
  _SetPriceInfo(serverConfig.price_table)
  _UpdatePriceInfo(myData.is_uc_discount_by_day)
  _SetIsUseLuckyInfo(serverConfig.global_table.is_use_lucky_value)
  _SetMaxLuckyValue(serverConfig.global_table.max_lucky_value)
  LuckybackActivitySystem.globalConfig.luckySpecialFlag = serverConfig.global_table.lucky_special_flag or 0
  _SetLuckyValueStageTable(serverConfig.lucky_value_table)
  _UpdateLuckyValue(myData.cur_lucky_value)
  _SetPoolItemConfig(serverConfig.item_table)
  _SetTotalDrawAwardConfig(serverConfig.sum_award_table)
  _UpdateTotalDrawAwardConfig(myData.sum_draw_award_info)
  _SetNewTotalAwardConfig(serverConfig.new_sum_award_table)
  _UpdateNewTotalDrawAwardConfig(myData.sum_draw_award_info)
  _SetBackgroundResourceConfig(serverConfig.global_table.blue_path)
  _SetExchangeBackgroundResourceConfig(serverConfig.global_table.exchange_blue)
  _SetPoolResourceConfig(serverConfig.global_table.pan_bg_img)
  _SetSumAwardBoxImg(serverConfig.global_table.sum_award_box_img)
  _SetSumAwardBgImg(serverConfig.global_table.sum_award_bg_img)
  local global_table = serverConfig.global_table
  _SetGoldenClothCollectRewardInfo(global_table.collected_resid, global_table.collected_num, global_table.collected_valid_hours)
  _UpdateGoldenClothCollectGetState(myData.got_collected_award)
  if test_BPPath then
    if test_BPPath.bgPath then
      _SetBackgroundResourceConfig(test_BPPath.bgPath)
      log_error(bWriteLog and "[cw][test] using test_BPPath.bgPath filed(" .. tostring(test_BPPath.bgPath) .. "), please don't forget to uncomment it after test")
    end
    if test_BPPath.poolPath then
      _SetPoolResourceConfig(test_BPPath.poolPath)
      log_error(bWriteLog and "[cw][test] using test_BPPath.poolPath filed(" .. tostring(test_BPPath.poolPath) .. "), please don't forget to uncomment it after test")
    end
  end
  _SetExchangeDebrisId(serverConfig.global_table.show_output_res_id, serverConfig.global_table.precious_stone_id)
  _SetTopRightDebrisIconShow(serverConfig.global_table.top_right_res_id)
  _UpdateDebrisCount()
  _SetDebrisFxBarList(serverConfig.global_table.show_fx_value_list)
  _SetVoucherConfig(serverConfig.draw_back_voucher)
  _SetLuckyHintTextKe(serverConfig.global_table.lucky_value_text_id)
  _SetTotalDrawHintTextKey(serverConfig.global_table.draw_acc_text_id)
  _SetExchangeDescriptionTextKey(serverConfig.global_table.exchange_text_id)
  _SetCouponSystemScene(serverConfig.global_table.gold_draw_back_flag)
end
local formatItem = function(itemId, count, validTime)
  return string.format("%s_%s_%s", itemId, count, validTime)
end
local _SetExchangeConfig = function(exchange_table, mydata, activity_id, discount_cfg, sheet_shield_cfg)
  local discountInfo = mydata.exchange_discount_info or {}
  local extra_info = mydata and mydata.exchange_extra_info or {}
  local limitInfo = mydata and mydata.new_limit_exchange_info or {}
  local region = FuncUtil.GetAccountRegionForBP()
  LuckybackActivitySystem.exchangeItemList = {}
  for i, v in pairs(exchange_table) do
    local isInExchange = true
    if sheet_shield_cfg and sheet_shield_cfg[v.exchange_sheet_id] then
      local shieldData = sheet_shield_cfg[v.exchange_sheet_id]
      if shieldData[0] and shieldData[0][region] then
        isInExchange = false
      end
      if shieldData[v.pos_id] and shieldData[v.pos_id][region] then
        isInExchange = false
      end
    end
    if isInExchange then
      local discount
      if discountInfo[v.award_item_id] then
        discount = discountInfo[v.award_item_id].discount
      end
      local giftDiscount = discount_cfg[v.award_item_id] and discount_cfg[v.award_item_id][1] and discount_cfg[v.award_item_id][1].discount_value or 0
      local exchangeItem = {
        itemId = v.award_item_id,
        itemNum = v.award_item_num,
        needItemId = v.need_item_id,
        needItemNum = v.need_item_num,
        timeLimits = v.exchange_times_limit,
        iconCDNPath = v.award_picture_cdn,
        pos = v.pos_id,
        discount = v.discount,
        validTime = v.award_item_valid_time or 0,
        startTime = v.start_time or 0,
        hasExchangeCount = limitInfo[formatItem(v.award_item_id, v.award_item_num, v.award_item_valid_time or 0)] or 0,
        hasDiscount = discount_cfg[v.award_item_id] ~= nil,
        drawDiscount = discount,
        fromGiftDiscount = giftDiscount,
        hasExchangeFromGift = extra_info[v.award_item_id] ~= nil,
        original_price = v.original_price,
        activity_id = activity_id or 0,
        exchange_sheet_id = v.exchange_sheet_id or 0,
        pre_item_list = v.pre_item_list,
        post_item_list = v.post_item_list,
        pre_local_text = v.pre_local_text,
        post_local_text = v.post_local_text
      }
      table.insert(LuckybackActivitySystem.exchangeItemList, exchangeItem)
    end
  end
  table.sort(LuckybackActivitySystem.exchangeItemList, function(a, b)
    return a.pos < b.pos
  end)
  log_tree("  : LuckybackActivitySystem.exchangeItemList", LuckybackActivitySystem.exchangeItemList)
  if activity_id then
    if not LuckybackActivitySystem.exchangeInfo then
      LuckybackActivitySystem.exchangeInfo = {}
    end
    LuckybackActivitySystem.exchangeInfo[activity_id] = LuckybackActivitySystem.exchangeItemList
    _SetExchangeActivityId(activity_id)
  end
end
local _GetKeyInBaseConfig = function()
  local config = require("client.slua.logic.lobby_activity.LuckySpinConfig")
  local cfg = config.MainPool[LuckybackActivitySystem.resourceType]
  if type(cfg) == "table" then
    cfg = cfg.BaseBp
  elseif type(cfg) == "string" then
  else
    log_error(bWriteLog and "[cw] cfg is nil, please check the LuckySpinConfig base on the resource type: " .. tostring(LuckybackActivitySystem.resourceType))
    return
  end
  return cfg
end
local _OpenUIByType = function(supplyShowCallBack)
  log(bWriteLog and "[cw] _OpenUIByType(" .. tostring(LuckybackActivitySystem.resourceType) .. ")")
  local k = _GetKeyInBaseConfig()
  if k then
    if supplyShowCallBack then
      supplyShowCallBack(UIManager.UI_Config[k])
    else
      UIManager.ShowUI(UIManager.UI_Config[k])
    end
  end
end
local _OnlyCloseUIByType = function()
  log(bWriteLog and "[cw] _OnlyCloseUIByType(" .. tostring(LuckybackActivitySystem.resourceType) .. ")")
  local k = _GetKeyInBaseConfig()
  if k then
    UIManager.CloseUI(UIManager.UI_Config[k])
  end
end
local _CloseUIByType = function()
  log(bWriteLog and "[cw] _CloseUIByType(" .. tostring(LuckybackActivitySystem.resourceType) .. ")")
  local k = _GetKeyInBaseConfig()
  if k then
    UIManager.CloseUI(UIManager.UI_Config[k])
  else
    log(bWriteLog and "[SY]_CloseUIByType.k is nil")
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_MAINBASE_CLOSE)
  end
end
local _GetExchangeKeyInBaseConfig = function()
  local config = require("client.slua.logic.lobby_activity.LuckySpinConfig")
  local cfg = config.Exchange[LuckybackActivitySystem.exchangeConfig.exchangeResourceType]
  if type(cfg) == "table" then
    cfg = cfg.BaseBp
  elseif type(cfg) == "string" then
  else
    log_error(bWriteLog and "[cw] cfg is nil, please check the LuckySpinConfig base on the resource type: " .. tostring(LuckybackActivitySystem.resourceType))
    return
  end
  return cfg
end
local _OpenExchangeStoreByType = function(bUpdateWhenEntry)
  log(bWriteLog and "[cw][logic_luckyback_activity] _OpenExchangeStoreByType(" .. tostring(bUpdateWhenEntry) .. ")")
  local exchangeId = LuckybackActivitySystem.exchangeConfig.exchangeActId
  local k = _GetExchangeKeyInBaseConfig()
  if k then
    UIManager.ShowUI(UIManager.UI_Config[k], nil, bUpdateWhenEntry, exchangeId)
  end
end
local _CloseExchangeStoreBtType = function()
  local k = _GetExchangeKeyInBaseConfig()
  if k and UIManager.UI_Config[k] and UIManager.IsUIShow(UIManager.UI_Config[k]) then
    UIManager.CloseUI(UIManager.UI_Config[k])
    return true
  end
  return false
end
local _SetUpgradeRefitJumpBtn = function(award_info)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  ItemUpgradeMgr:InitRefitCfgData()
  local IsJump = function(res_id)
    for groupID, v in pairs(ItemUpgradeMgr.itemRefitConditionCfg) do
      if v.CostItem1 == res_id or v.CostItem2 == res_id then
        local itemCfg = CDataTable.GetTableData("Item", res_id) or {}
        if itemCfg.ItemSubType and itemCfg.ItemSubType == 2604 then
          return true
        end
      end
    end
  end
  for i, v in pairs(award_info) do
    if IsJump(v.res_id) then
      return true
    end
  end
  return false
end
local _ShowCommonItemPanel = function(arrayItemList)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local isAddUpgradeJumpBtn = _SetUpgradeRefitJumpBtn(arrayItemList)
  if isAddUpgradeJumpBtn then
    local strBtn2 = LocUtil.GetLocalizeResStr("40011")
    local OpenUpgradeUI = function()
      GlobalData.JumpUrl(LuckybackActivitySystem.globalConfig.weaponJumpLink)
    end
    local _itemList = arrayItemList
    local logic_decompose = require("client.logic.decompose.logic_decompose")
    local decomposeList = logic_decompose.decomposeList or {}
    if decomposeList and next(decomposeList) then
      _itemList = {}
      for i, v in pairs(arrayItemList) do
        local item = v
        for _, value in pairs(decomposeList) do
          if item and item.res_id and value and value.from_id and value.from_id == item.res_id then
            log(bWriteLog and "[bgp] from_id" .. tostring(value.res_id))
            item.to_res_id = value.res_id
            item.to_res_cnt = value.count or 0
          end
        end
        if item then
          table.insert(_itemList, item)
        end
      end
      local _decomposeList = {}
      local index = 1
      for i, data in pairs(decomposeList) do
        _decomposeList[index] = {
          itemid = data.res_id,
          count = data.count
        }
        index = index + 1
      end
      local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
      local tExtendData = {
        bCheckSpecialItem = false,
        tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateTwoGeneralBtnData(strBtn2, OpenUpgradeUI)
      }
      Logic_CommonItemGet.ShowPanel_DecomposeStyle(_itemList, _decomposeList, tExtendData)
    else
      Logic_CommonItemGet.ShowPanel_TwoBtnStyle(_itemList, strBtn2, OpenUpgradeUI)
    end
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, true)
  end
  _DelayDecompose()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_START_COIN_UPDATE)
end
function LuckybackActivitySystem.OpenMainUI(eventType, eventID, vars)
  LuckybackActivitySystem.moduleId = tonumber(vars.module)
  LuckybackActivitySystem.OpenUIWithActId(tonumber(vars.activityid))
end
function LuckybackActivitySystem.OpenExchangeMainUI(eventType, eventID, vars)
  local _ErrorMessage = function(popNoticeId, extraMessage)
    ShowNotice(popNoticeId)
    if extraMessage then
      log(bWriteLog and extraMessage)
    end
  end
  local activityId = tonumber(vars.activityid)
  if activityId == nil or activityId == 0 then
    _ErrorMessage(120106, "[cw] LuckybackActivitySystem.OpenExchangeMainUI activityId is illegal")
    return
  end
  local resourceType = tonumber(vars.resourceType)
  if resourceType == nil then
    _ErrorMessage(120106, "[cw] LuckybackActivitySystem.OpenExchangeMainUI resourceType is illegal")
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(activityId)]
  if data == nil then
    _ErrorMessage(4002, "[cw] LuckybackActivitySystem.OpenExchangeMainUI activity has end")
    return
  end
  local config = require("client.slua.logic.lobby_activity.LuckySpinConfig")
  local cfg = config.Exchange[resourceType]
  log(bWriteLog and "[cw] activityId:" .. tostring(activityId))
  log(bWriteLog and "[cw] cfg.BgBp:" .. tostring(cfg.BgBp))
  log(bWriteLog and "[cw] cfg.BgImg:" .. tostring(cfg.BgImg))
  log(bWriteLog and "[cw] resourceType:" .. tostring(resourceType))
  LuckybackActivitySystem.OpenExchangeStoreExternal(false, activityId, cfg.BgBp, cfg.BgImg, resourceType)
end
function LuckybackActivitySystem.ClearActData()
  LuckybackActivitySystem.activityId = 0
  LuckybackActivitySystem.resourceType = 0
  LuckybackActivitySystem.exchangeConfig.exchangeResourceType = 0
end
function LuckybackActivitySystem.PreSetActData(actId)
  if actId == nil or actId == 0 then
    ShowNotice(120106)
    log(bWriteLog and "LuckybackActivitySystem.OpenUIWithActId id is NULL")
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(actId)]
  if not data or not data.cfg then
    LuckybackActivitySystem.ClearActData()
    log(bWriteLog and "[cw] activity has end")
    ShowNotice(4002)
    return
  end
  _SetActivityId(actId)
  log(bWriteLog and "[cw] data.cfg.label_type:" .. tostring(data.cfg and data.cfg.label_type))
  _SetResourceType(data.cfg.label_type or 0)
  _SetExchangeResourceType(data.cfg.label_type or 0)
  local backUpOne = data.cfg.back_up_one or ""
  log(bWriteLog and "[cw] data.cfg.back_up_one:" .. tostring(data.cfg.back_up_one))
  if test_backupOne then
    backUpOne = test_backupOne
    log_error(bWriteLog and "[cw][test] using test_backupOne filed(" .. tostring(test_backupOne) .. "), please don't forget to uncomment it after test")
  end
  if backUpOne and backUpOne ~= "" then
    local str = tostring(backUpOne)
    if string.find(str, "|") then
      local p1, p2 = string.match(str, "(%d*)|(%d*)")
      _SetResourceType(tonumber(p1))
      _SetExchangeResourceType(tonumber(p2))
    else
      local p1 = tonumber(str)
      _SetResourceType(p1)
    end
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
  end
  _SetActPeriod(data.cfg.start_time, data.cfg.end_time)
  _UpdateCurRedDot(LuckybackActivitySystem.redPoint.discountRedPoint and LuckybackActivitySystem.redPoint.bannerRedPoint)
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 2)
  _SetExchangeActData(data)
  _SetReturnJumpUrl(data.cfg.return_jump_link)
  _SetVehicleNewBieGuid(DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 3))
  return true
end
function LuckybackActivitySystem.OpenUIWithActId(actId, supplyShowCallBack)
  log(bWriteLog and "[cw] LuckybackActivitySystem.OpenUIWithActId(" .. tostring(actId) .. ") ")
  if not LuckybackActivitySystem.PreSetActData(actId) then
    return false
  end
  _ToggleDelayDecompose(true)
  _ToggleBlockAchievement(true)
  _OpenUIByType(supplyShowCallBack)
  return true
end
function LuckybackActivitySystem.ActIsEnd(actID, CurServerTime)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local data = ActivityNewSystem.GetActivityByID(actID)
  if data == nil then
    return false
  end
  if CurServerTime > data.StartTime and CurServerTime < data.EndTime then
    return true
  else
    return false
  end
end
function LuckybackActivitySystem.CloseMainUI(isJump)
  if isJump then
    _OnlyCloseUIByType()
  else
    _CloseUIByType()
    _ClearDropList()
  end
  _ToggleDelayDecompose(false)
  _ToggleBlockAchievement(false)
end
function LuckybackActivitySystem.IsSumAwardCanGet(index)
  local boxConfig = LuckybackActivitySystem.totalDrawAwardConfig[index]
  if not boxConfig then
    return false, 0
  end
  return not boxConfig.hasGet and LuckybackActivitySystem.playerData.totalDrawTime >= boxConfig.timesCount, boxConfig.timesCount
end
function LuckybackActivitySystem.OpenRewardBox(id)
  LuckybackActivitySystem.CurrentRewardBoxId = id
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.LuckySpinRewardBox, id)
  end
end
function LuckybackActivitySystem.CloseRewardBox()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.LuckySpinRewardBox)
  end
end
local _ShowItemGetPanel = function(tAllItem, tDecomposeList, tExtraData)
  local tExtraGetData = LuckybackActivitySystem.tExtraGetData
  local nAddIPScore = 0
  local bIsExtraGet = false
  local bIsShowExtraGetTip = false
  if tExtraGetData and next(tExtraGetData) then
    nAddIPScore = tExtraGetData.count
    bIsExtraGet = true
    bIsShowExtraGetTip = true
  end
  local cObj_smallRPModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nIPScoreItemId = cObj_smallRPModule:GetIPScoreId()
  local Logic_SmallRPUtils = require("client.slua.logic.specialoffer.SmallRP.Logic_SmallRPUtils")
  local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
  local nCurScore = Logic_ItemUtils.GetItemCount(nIPScoreItemId) or 0
  local nMaxScore = Logic_SmallRPUtils.GetIPLineMaxProgressScore() or 0
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if nMaxScore > nCurScore - nAddIPScore and bIsExtraGet then
    tExtraGetData.nItemGetGroupId = 2
    table.insert(tAllItem, tExtraGetData)
    tExtraData.tAllGroupTitle = {
      [1] = LocUtil.GetLocalizeResStr(76906),
      [2] = LocUtil.GetLocalizeResStr(76907)
    }
    Logic_CommonItemGet.ShowPanel_RewardGroupShow(tAllItem, tDecomposeList, tExtraData)
    bIsShowExtraGetTip = false
  elseif tDecomposeList then
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(tAllItem, tDecomposeList, tExtraData)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(LuckybackActivitySystem.dropList, false, false, tExtraData)
  end
  if bIsShowExtraGetTip then
    ShowNotice(76904)
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_START_COIN_UPDATE)
  _DelayDecompose()
  _ClearDropList()
end
function LuckybackActivitySystem:IsHaveFirstDraw()
  local allConfig = LuckybackActivitySystem.globalConfig
  local originalPrice = allConfig.oneDrawOriginalPrice or 0
  local dailyPrice = allConfig.oneDrawDailyDiscountPrice
  return LuckybackActivitySystem.playerData.hasDailyOneDrawDiscount and dailyPrice ~= originalPrice
end
function LuckybackActivitySystem.ShowItemGetPanel(dontDecompose)
  if LuckybackActivitySystem.dropList == nil or next(LuckybackActivitySystem.dropList) == nil then
    return
  end
  log_tree("hhy LuckybackActivitySystem.ShowItemGetPanel dropList:", LuckybackActivitySystem.dropList)
  local CommonItemGet_Utils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Utils")
  if not dontDecompose then
    local decomposeList = {}
    for i, v in pairs(LuckybackActivitySystem.decomposeList) do
      local itemid, count
      for index, item in pairs(v) do
        itemid = index
        count = item
      end
      decomposeList[i] = {itemid = itemid, count = count}
    end
    local _checkIsUpgradeGun = function(itemId)
      local itemCfg = CDataTable.GetTableData("Item", itemId)
      if not itemCfg then
        log_error("LuckybackActivitySystem.ShowItemGetPanel no item: " .. tostring(itemId))
        return false
      end
      if itemCfg.ItemType ~= 1 then
        return false
      end
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local upgradeConfig = ItemUpgradeMgr:GetUpgradeCfg(itemId)
      if upgradeConfig then
        log_tree("[chub]log_upgradeConfig, upgradeConfig = ", upgradeConfig)
        return ItemUpgradeMgr:CheckIsValid(upgradeConfig.GroupID)
      end
    end
    local store_detail_data_select_chest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_detail_data_select_chest)
    local chestData = {chestId = 0, count = 0}
    local list = {}
    for _, v in pairs(LuckybackActivitySystem.dropList) do
      local item = {
        res_id = v.res_id,
        valid_hours = v.valid_hours,
        count = v.count,
        isUpgradeGun = _checkIsUpgradeGun(v.res_id),
        rankTitleType = v.rankTitleType,
        chief_event_share_count_bak = v.chief_event_share_count_bak,
        king_event_share_count_bak = v.king_event_share_count_bak
      }
      log(bWriteLog and "[SY]_UpdateDropList222." .. tostring(v.chief_event_share_count_bak) .. "    :" .. tostring(v.king_event_share_count_bak))
      if store_detail_data_select_chest:CheckIfCustomSelectChest(v.res_id) then
        chestData.chestId = v.res_id
        chestData.count = chestData.count + 1
        chestData.hasChest = true
      end
      table.insert(list, item)
    end
    LuckybackActivitySystem.RemoveDecomposedItem()
    local nPrices = LuckybackActivitySystem.SnatchUC[1]
    local nPostNum = 1
    local specialText
    if #LuckybackActivitySystem.dropList > 1 then
      nPrices = LuckybackActivitySystem.SnatchUC[2]
      nPostNum = 2
    elseif LuckybackActivitySystem.IsHaveDrawReplaceTicket() or not LuckybackActivitySystem.IsHaveDrawOnePrice() then
      nPrices = 0
      specialText = LocUtil.GetLocalizeResStr(18485)
    end
    local OpenUpgradeUI = function()
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_ONE_MORE_DRAW, nPostNum)
    end
    local bIsShowOpenBtn, _ = CommonItemGet_Utils.CheckIsShowChestOpenBtn(list)
    local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
    local tExtendData = {
      bCheckSpecialItem = bIsShowOpenBtn or false,
      tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateConsecutiveDrawBtnData(nPostNum ~= 1, nPrices, OpenUpgradeUI, nil, specialText),
      fCloseCallback = function()
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_ITEM_GET_PANEL_CLOSE)
      end
    }
    local Logic_DetailUtils = require("client.slua.logic.common.Logic_DetailUtils")
    local bIsSelectChest = Logic_DetailUtils.CheckIfCustomSelectChest(chestData.chestId)
    local cExcCommonGet = function(is_can_decompose)
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local OpenChest = function()
        local tItemData = wardrobe_data:GetHallDepotItemDataByResID(chestData.chestId)
        if not tItemData then
          return
        end
        if is_can_decompose then
          local itemCfg = CDataTable.GetTableData("Item", chestData.chestId)
          local CommonUseItemSystem = require("client.slua.logic.common.logic_common_use_items")
          local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
          logic_wardrobe_new:SetClickItemInsId(tItemData.insID)
          GLOBAL_USE_ITEM = tItemData.insID
          CommonUseItemSystem.ShowDecomposeItem(itemCfg, tItemData.count, tItemData.expireTS > 0)
          return
        end
        local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
        WardRobeHandler.send_use_item(tItemData.insID, chestData.count)
      end
      if #LuckybackActivitySystem.dropList > 1 and chestData.hasChest then
        local sBtn3Str = LocUtil.LocalizeResFormat(27962)
        if is_can_decompose then
          sBtn3Str = LocUtil.GetLocalizeResStr(73121)
        end
        table.insert(tExtendData.tAllBtnShowData, CommonItemGet_BtnCfgUtils.CustomNormalBtnData(sBtn3Str, 2, OpenChest))
      end
      EventSystem:postEvent(EVENTTYPE_COMMON_SCORE_PRO_BAR, EVENTID_COMMON_SCORE_PRO_BAR_CHECK_SHOW)
      _ShowItemGetPanel(list, decomposeList, tExtendData)
    end
    if bIsSelectChest then
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local DecomposeHandler = require("client.network.Protocol.DecomposeHandler")
      local tChestData = wardrobe_data:GetHallDepotItemDataByResID(chestData.chestId)
      if not tChestData then
        cExcCommonGet()
        return
      end
      DecomposeHandler.send_search_optional_chest_decompose_status_req(tChestData.insID):Then(function(_, is_can_decompose, _)
        local logic_decompose = require("client.logic.decompose.logic_decompose")
        logic_decompose.GetItemDecomposeInfo(chestData.chestId)
        cExcCommonGet(is_can_decompose)
      end)
    else
      cExcCommonGet()
    end
  else
    log(bWriteLog and "LuckybackActivitySystem.ShowItemGetPanel" .. #LuckybackActivitySystem.dropList)
    local bDiyTur = UIManager and UIManager.IsUIShow(UIManager.UI_Config.Weapon_Diy_Turntable)
    local tAllItem = LuckybackActivitySystem.dropList
    local tExtendData
    if bDiyTur and CommonItemGet_Utils.CheckPickOneBox(tAllItem) == -1 and CommonItemGet_Utils:CheckNeedShareItem(tAllItem) == false then
      local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
      local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
      local Enum_BtnStyle = CommonItemGet_Const.Enum_BtnStyle
      if 1 < #tAllItem then
        local sBtnStr = LocUtil.LocalizeResFormat(6949, tostring(LuckybackActivitySystem.SnatchUC[2]))
        tExtendData = {
          CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
          CommonItemGet_BtnCfgUtils.CustomNormalBtnData(sBtnStr, Enum_BtnStyle.Orange, function()
            EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_ONE_MORE_DRAW, 2)
          end)
        }
      elseif #tAllItem == 1 then
        local sBtnStr = LocUtil.LocalizeResFormat(6948, tostring(LuckybackActivitySystem.SnatchUC[2]))
        tExtendData = {
          CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
          CommonItemGet_BtnCfgUtils.CustomNormalBtnData(sBtnStr, Enum_BtnStyle.Orange, function()
            EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_ONE_MORE_DRAW, 1)
          end)
        }
      end
    end
    tExtendData = tExtendData or {}
    function tExtendData.fCloseCallback()
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_ITEM_GET_PANEL_CLOSE)
    end
    _ShowItemGetPanel(LuckybackActivitySystem.dropList, nil, tExtendData)
  end
  _PostIconShow()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_START_COIN_UPDATE)
end
function LuckybackActivitySystem.RemoveDecomposedItem()
  local decomposeList = LuckybackActivitySystem.decomposeList
  local award_info = LuckybackActivitySystem.award_info
  local TableUtil = require("common.table_util")
  local decomposeNum = TableUtil.CountTable(decomposeList)
  local decomposeResIds = {}
  if 0 < decomposeNum and award_info and next(award_info) then
    for key, v in pairs(LuckybackActivitySystem.decomposeList) do
      if LuckybackActivitySystem.award_info[key] then
        table.insert(decomposeResIds, LuckybackActivitySystem.award_info[key].resid)
      end
    end
  end
end
function LuckybackActivitySystem.GetIsShowAnimation()
  local activity = LuckybackActivitySystem.activityId or 0
  if LuckybackActivitySystem.IsShowAnimation[activity] == nil then
    LuckybackActivitySystem.IsShowAnimation[activity] = true
  end
  return LuckybackActivitySystem.IsShowAnimation[activity]
end
function LuckybackActivitySystem.GetCircleSector()
  local sector = LuckybackActivitySystem.bluePathConfig.pan_bg_img
  if not sector or type(sector) ~= "string" or sector == "" then
    return "/Game/Arts_UI/LuckyWidget/LuckySector/style1/Sectore_UIBP.Sectore_UIBP"
  end
  return sector
end
function LuckybackActivitySystem.SetIsShowAnimation(status)
  local activity = LuckybackActivitySystem.activityId or 0
  LuckybackActivitySystem.IsShowAnimation[activity] = status
end
function LuckybackActivitySystem.IsFirstPriceValid(actId)
  actId = actId or LuckybackActivitySystem.activityId
  local TimeUtil = require("client.common.time_util")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[actId]
  if data == nil then
    return false
  end
  if data.cfg and data.cfg.award and data.cfg.award[1] and data.cfg.award[1].cond_list and data.cfg.award[1].cond_list[5] then
    local days = tonumber(data.cfg.award[1].cond_list[5])
    if days and 0 < days then
      local start_time = data.cfg.start_time
      local cur_time = TimeUtil.GetServerTimeInSec()
      if cur_time > start_time + (days - 1) * 24 * 60 * 60 + TimeUtil.GetTodayTimestamp() then
        return false
      end
    end
  end
  return true
end
function LuckybackActivitySystem.GetDefaultBPPath()
  local activityBpPath = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplateNew/CommonLuckySpin/CommonLuckySpin_Image_BG_L.CommonLuckySpin_Image_BG_L"
  if LuckybackActivitySystem.IsCarType() then
    log(bWriteLog and "[SY]LuckybackActivitySystem.GetDefaultBPPath.CarDeafultPath")
    activityBpPath = "/Game/Arts_UI/FromUmg/LotteryTemplate/CarLuckyPutbackTemplate/CommonLuckySpin/CommonLuckySpin_Image_Car_BG_L"
  end
  return activityBpPath
end
function LuckybackActivitySystem.OnlyGetBpResourcePath(actId)
  if test_BPCfg then
    log_error(bWriteLog and "[cw][test][LuckybackActivitySystem] using test_BPCfg filed(" .. tostring(test_BPCfg) .. "), please don't forget to uncomment it after test")
    return test_BPCfg
  end
  actId = actId or LuckybackActivitySystem.activityId
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local activityBpPath = PufferManager.GetResourcePathByModuleIDAndActivityID(BP_ENUM_MODULE_LUCKY_BACK, actId)
  activityBpPath = activityBpPath or LuckybackActivitySystem.GetDefaultBPPath()
  return activityBpPath
end
function LuckybackActivitySystem.GetBpResourcePath(actId, callback)
  if test_BPCfg then
    log_error(bWriteLog and "[cw][test][LuckybackActivitySystem] using test_BPCfg filed(" .. tostring(test_BPCfg) .. "), please don't forget to uncomment it after test")
    return test_BPCfg
  end
  actId = actId or LuckybackActivitySystem.activityId
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local activityBpPath = PufferManager.GetResourcePathByModuleIDAndActivityID(BP_ENUM_MODULE_LUCKY_BACK, actId)
  log(bWriteLog and "[hhy]LuckybackActivitySystem.GetBpResourcePath actId: " .. tostring(actId) .. " activityBpPath: " .. tostring(activityBpPath))
  local state
  if LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId, callback)
    if not activityBpPath or state ~= PufferConst.ENUM_DownloadState.Done then
      activityBpPath = LuckybackActivitySystem.GetDefaultBPPath()
    end
  end
  return activityBpPath, state
end
function LuckybackActivitySystem.GetOldBpResourcePath(actId, callback)
  if test_BPCfg then
    log_error(bWriteLog and "[cw][test][LuckybackActivitySystem] using test_BPCfg filed(" .. tostring(test_BPCfg) .. "), please don't forget to uncomment it after test")
    return test_BPCfg
  end
  actId = actId or LuckybackActivitySystem.activityId
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local activityBpPath = PufferManager.GetResourcePathByModuleIDAndActivityID(BP_ENUM_MODULE_LUCKY_BACK, actId)
  log(bWriteLog and "[hhy]LuckybackActivitySystem.GetBpResourcePath actId: " .. tostring(actId) .. " activityBpPath: " .. tostring(activityBpPath))
  local state
  if LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId, callback)
    if not activityBpPath or state ~= PufferConst.ENUM_DownloadState.Done then
      activityBpPath = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplate/CommonLuckySpin/CommonLuckySpin_Image_BG_L.CommonLuckySpin_Image_BG_L"
    end
  end
  return activityBpPath, state
end
function LuckybackActivitySystem.SetDoneStateEventByActivityID(actId, doneCallBack)
  if test_BPCfg then
    return true
  end
  actId = actId or LuckybackActivitySystem.activityId
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local state
  if LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    state = PufferManager.SetDownEventByModuleIDActivityIDForSupply(nil, actId, doneCallBack)
    if state == PufferConst.ENUM_DownloadState.Done then
      return true
    end
  end
  return false
end
function LuckybackActivitySystem.SetBPResourcePath_GM(BpPath)
  test_BPCfg = BpPath
end
function LuckybackActivitySystem.IsMainAward(index)
  local poolData = LuckybackActivitySystem.poolItemConfig[index]
  if not poolData or not poolData.award_weight then
    return false
  end
  return poolData.award_weight <= LuckybackActivitySystem.MainAwardWeight
end
function LuckybackActivitySystem.IsCarType()
  return LuckybackActivitySystem.resCfg.global_table.button_type == button_type.CarType
end
function LuckybackActivitySystem.IsH5Type()
  return LuckybackActivitySystem.resCfg.global_table.button_type == button_type.H5Type
end
function LuckybackActivitySystem.IsCopyRightType()
  return LuckybackActivitySystem.resCfg.global_table.button_type == button_type.CopyRightType
end
function LuckybackActivitySystem.GetAnimEffectType()
  return LuckybackActivitySystem.resCfg.global_table.GetAnimEffectType
end
function LuckybackActivitySystem.OpenExchangeStoreExternal(bWithCache, exchangeActivityId, exchangeBp, exchangeBg, exchangeResourceType)
  _SetExchangeActivityId(exchangeActivityId)
  _SetExchangeBackgroundResourceConfig(exchangeBp)
  _SetExchangeBgImg(exchangeBg)
  _SetExchangeResourceType(exchangeResourceType)
  if bWithCache and not _CheckIfNeedUpdateExchangeData() then
    log(bWriteLog and "[cw][spin][exhcnage external] find data for exchange activity " .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId))
    LuckybackActivitySystem.exchangeItemList = LuckybackActivitySystem.exchangeInfo[LuckybackActivitySystem.exchangeConfig.exchangeActId]
    _OpenExchangeStoreByType(true)
  else
    log(bWriteLog and "[cw][spin][exchange external] no data for exchange activity " .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId) .. ", try to get data from server")
    LuckybackActivitySystem.get_exchange_activity_info_req()
    _OpenExchangeStoreByType()
  end
end
function LuckybackActivitySystem.OpenExchangeStoreInternal(bForceUpdateData)
  local TimeUtil = require("client.common.time_util")
  local timeStamp = TimeUtil.GetServerTimeInSec()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[LuckybackActivitySystem.activityId]
  _SetExchangeActData(data)
  _SetExchangeResourceType(data and data.cfg and data.cfg.label_type or 0)
  local backUpOne = data and data.cfg and data.cfg.back_up_one or ""
  if test_backupOne then
    backUpOne = test_backupOne
  end
  if backUpOne and backUpOne ~= "" then
    local str = tostring(backUpOne)
    if string.find(str, "|") then
      local _, p2 = string.match(str, "(%d*)|(%d*)")
      _SetExchangeResourceType(tonumber(p2))
    end
  end
  log(bWriteLog and "[YY]OpenExchangeStoreInternal==exchangeActId==" .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId))
  if data == nil or timeStamp > data.cfg.end_time then
    ShowNotice(4002)
    return
  end
  local exchangeData = activityDataTable[LuckybackActivitySystem.exchangeConfig.exchangeActId]
  local TableUtil = require("common.table_util")
  _SetExchangeBgImg(TableUtil.GetTableValue(exchangeData, "cfg", "activity_image_link"))
  if bForceUpdateData or _CheckIfNeedUpdateExchangeData() then
    if bForceUpdateData then
      log(bWriteLog and "[cw][spin][exhcnage internal] force to update exchange data for exchange activity " .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId))
    else
      log(bWriteLog and "[cw][spin][exchange internal] no data for exchange activity " .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId))
    end
    _OpenExchangeStoreByType()
    LuckybackActivitySystem.get_exchange_activity_info_req()
  else
    log(bWriteLog and "[cw][spin][exhcnage internal] find data for exchange activity " .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId))
    LuckybackActivitySystem.exchangeItemList = LuckybackActivitySystem.exchangeInfo[LuckybackActivitySystem.exchangeConfig.exchangeActId]
    _OpenExchangeStoreByType(true)
  end
end
function LuckybackActivitySystem.TryToGetExchangeStoreData(activityID)
  log(bWriteLog and "[cw] TryToGetExchangeStoreData ")
  local TimeUtil = require("client.common.time_util")
  local timeStamp = TimeUtil.GetServerTimeInSec()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(activityID) or LuckybackActivitySystem.activityId]
  if data == nil or timeStamp > data.cfg.end_time then
    return false
  end
  LuckybackActivitySystem.get_exchange_activity_info_req(activityID)
  return true
end
function LuckybackActivitySystem.GetDebrisItemIdInExchange(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[actId or LuckybackActivitySystem.exchangeConfig.exchangeActId]
  if data and data.cfg.award and data.cfg.award[1] then
    local tmpcond = StrSplit(data.cfg.award[1].cond, ",")
    if tmpcond[1] then
      local itemId = tonumber(tmpcond[1])
      return itemId
    end
  end
  return 0
end
function LuckybackActivitySystem.send_take_activity_award_req(successFunc)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_activity_award_req(LuckybackActivitySystem.activityId, 1, 1)
  LuckybackActivitySystem.EasterEggSuccessFuc = successFunc or nil
end
function LuckybackActivitySystem.on_take_activity_award_res(item_list, activityId)
  if LuckybackActivitySystem.EasterEggSuccessFuc then
    LuckybackActivitySystem.EasterEggSuccessFuc(item_list, activityId)
  end
end
function LuckybackActivitySystem.on_draw_lucky_surprising_item_ntf(item_list, activityID)
  LuckybackActivitySystem.EggItem_List[activityID] = item_list
end
function LuckybackActivitySystem.GetEggType()
  if not LuckybackActivitySystem.EggItem_List[LuckybackActivitySystem.activityId] then
    return 0
  end
  for _, value in pairs(LuckybackActivitySystem.EggItem_List[LuckybackActivitySystem.activityId]) do
    return value.voucher_type or 0
  end
end
function LuckybackActivitySystem.IsShowEgg(eggType)
  eggType = eggType or 0
  if not LuckybackActivitySystem.EggItem_List[LuckybackActivitySystem.activityId] then
    return false
  end
  for _, value in pairs(LuckybackActivitySystem.EggItem_List[LuckybackActivitySystem.activityId]) do
    log(bWriteLog and "[SY]LuckybackActivitySystem.IsShowEgg." .. tostring(value.voucher_type))
    local voucher_type = value.voucher_type or 0
    if value.flag == 0 and voucher_type == eggType then
      return true
    end
  end
  return false
end
function LuckybackActivitySystem.GetEggCouponID()
  local data = LuckybackActivitySystem.GetEggSpecialVoucherListData()
  return data and data.resid or 0
end
function LuckybackActivitySystem.GetEggSpecialVoucherListData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByID(LuckybackActivitySystem.activityId)
  if not (activityData and activityData.other) or not activityData.other.special_voucher_list then
    return nil
  end
  local key = next(activityData.other.special_voucher_list)
  if key then
    return activityData.other.special_voucher_list[key]
  end
  return nil
end
function LuckybackActivitySystem.GetEggDiscountUseScene()
  local couponID = LuckybackActivitySystem.GetEggCouponID()
  if not couponID or couponID == 0 then
    return 0
  end
  local voucherData = LuckybackActivitySystem.GetEggSpecialVoucherListData()
  return voucherData and voucherData.use_scene or 0
end
function LuckybackActivitySystem.GetEggExpireTime()
  local voucherData = LuckybackActivitySystem.GetEggSpecialVoucherListData()
  if not voucherData then
    return 0
  end
  return voucherData.expire_ts or 0
end
function LuckybackActivitySystem.IsHaveEasterEgg(drawCount)
  local voucherData = LuckybackActivitySystem.GetEggSpecialVoucherListData()
  if not voucherData then
    return false
  end
  if voucherData.use_scene ~= drawCount then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local endtime = voucherData.expire_ts
  if endtime < TimeUtil.GetServerTimeInSec() then
    return false
  end
  return LuckybackActivitySystem.GetEggDiscountValue(drawCount) > 0
end
function LuckybackActivitySystem.GetEggDiscountValue(drawCount)
  drawCount = drawCount or 1
  local useScene = LuckybackActivitySystem.GetEggDiscountUseScene()
  if useScene ~= drawCount then
    return 0
  end
  local couponID = LuckybackActivitySystem.GetEggCouponID()
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  return CouponSystem.GetCouponInfoByItemId(couponID).value or 0
end
function LuckybackActivitySystem.GetDebrisItemCount()
  log(bWriteLog and "Debris ID : " .. LuckybackActivitySystem.globalConfig.exchangeDebrisId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(LuckybackActivitySystem.globalConfig.exchangeDebrisId)
  if itemData ~= nil then
    return itemData.count
  end
  return 0
end
function LuckybackActivitySystem.GetDebrisItemCountInExchange(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[actId or LuckybackActivitySystem.exchangeConfig.exchangeActId]
  local needItemId = 0
  if data and data.cfg.award and data.cfg.award[1] then
    local tmpcond = StrSplit(data.cfg.award[1].cond, ",")
    if tmpcond[1] then
      local itemId = tonumber(tmpcond[1])
      needItemId = itemId
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(needItemId)
  if itemData ~= nil then
    return itemData.count
  end
  return 0
end
function LuckybackActivitySystem.GetDrawReplaceTicketId()
  if LuckybackActivitySystem and LuckybackActivitySystem.resCfg and LuckybackActivitySystem.resCfg.price_table then
    local cfg = LuckybackActivitySystem.resCfg.price_table[1]
    return cfg and cfg.replace_res_id or 0
  end
  return 0
end
function LuckybackActivitySystem.IsHaveDrawReplaceTicket()
  local id = LuckybackActivitySystem.GetDrawReplaceTicketId()
  if id == 0 then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  return wardrobe_data:HasItem(id)
end
function LuckybackActivitySystem.IsHaveDrawOnePrice()
  local allConfig = LuckybackActivitySystem.globalConfig
  local originalPrice = allConfig.oneDrawOriginalPrice
  if originalPrice == 0 then
    return false
  end
  return 0 < originalPrice
end
function LuckybackActivitySystem.GetShareConfig()
  local cfg = CDataTable.GetTableData("LuckySpinShareCfg", LuckybackActivitySystem.resourceType)
  if not cfg then
    return
  end
  return cfg.sharePath
end
function LuckybackActivitySystem.IsHaveCollectRewardRed(activityID)
  if not LuckybackActivitySystem.collectRewardRed[activityID] == nil then
    local table_util = require("common.table_util")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local ActivityData = ActivityNewSystem.GetActivityByID(actId)
    local awardRedPoint = table_util.GetTableValue(ActivityData, "other", "red_point_award")
    LuckybackActivitySystem.collectRewardRed[LuckybackActivitySystem.activityId] = awardRedPoint and awardRedPoint == 1
  end
  return LuckybackActivitySystem.collectRewardRed[activityID]
end
function LuckybackActivitySystem.HasGoldenClothCollectRedDot()
  local bShowRed = false
  local isHaveGoldenRewardInfo = #LuckybackActivitySystem.globalConfig.goldenCollectRewardInfo > 0
  local isNotGotReward = not LuckybackActivitySystem.got_collected_award
  local isCollectionComplete = LuckybackActivitySystem:IsCollectionComplete()
  string.format("[SY]HasGoldenClothCollectRedDot isHaveGoldenRewardInfo, %s  isNotGotReward  %s,  isCollectionComplete%s", tostring(isHaveGoldenRewardInfo), tostring(isHaveGoldenRewardInfo), tostring(isHaveGoldenRewardInfo))
  if isHaveGoldenRewardInfo and isNotGotReward and isCollectionComplete then
    bShowRed = true
  end
  LuckybackActivitySystem.collectRewardRed[LuckybackActivitySystem.activityId] = bShowRed
  return bShowRed
end
function LuckybackActivitySystem:IsCollectionComplete()
  if next(LuckybackActivitySystem.globalConfig.collectItemList) then
    log_tree("[SY]collectItemList= ", LuckybackActivitySystem.globalConfig.collectItemList)
    local curProgress = 0
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    for i, v in pairs(LuckybackActivitySystem.globalConfig.collectItemList) do
      if wardrobe_data:CheckHavePermanentItemForCollect(tonumber(v.itemId)) then
        curProgress = curProgress + 1
      else
        log(bWriteLog and "[SY]LuckybackActivitySystem:IsCollectionComplete.NoItem" .. tostring(v.itemId))
      end
    end
    return curProgress == #LuckybackActivitySystem.globalConfig.collectItemList
  end
  return false
end
function LuckybackActivitySystem.CloseExchangeStore()
  local doClose = _CloseExchangeStoreBtType()
  _PostStatusChangeEvent()
  return doClose
end
function LuckybackActivitySystem.OpenExchangeConfirm(index, bIncludeAllExchangeItems, source)
  if not UIManager then
    return
  end
  local exchangeItem = LuckybackActivitySystem.exchangeItemList[index]
  if not exchangeItem or type(exchangeItem) ~= "table" or not next(exchangeItem) then
    log_error(bWriteLog and "[cw] exchangeItem is illegal: " .. tostring(exchangeItem))
    return
  end
  local discountPrice = math.floor(exchangeItem.needItemNum * exchangeItem.fromGiftDiscount / 100)
  local pos = exchangeItem.pos
  local tExchangeData = {
    itemId = exchangeItem.itemId,
    itemNum = exchangeItem.itemNum,
    validTime = exchangeItem.validTime,
    timeLimits = exchangeItem.timeLimits,
    hasExchangeCount = exchangeItem.hasExchangeCount,
    needItemId = exchangeItem.needItemId,
    needItemNum = source and source == 1 and discountPrice or exchangeItem.needItemNum,
    pos = pos,
      }
  local tPreviewItemsIDs = bIncludeAllExchangeItems and LuckybackActivitySystem.exchangeItemList
  local tExtra = {
    bIsShowItemPreview = true,
    tPreviewItemsIDs = tPreviewItemsIDs,
    nActId = LuckybackActivitySystem.exchangeConfig.exchangeActId,
    sTitle = LocUtil.GetLocalizeResStr(448801)
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Exchange_Confirm_UIBP, tExchangeData, tExtra)
end
function LuckybackActivitySystem.CloseExchangeConfirm()
  UIManager.CloseUI(UIManager.UI_Config.Common_Exchange_Confirm_UIBP)
end
function LuckybackActivitySystem.GetItemUpgradeInfo()
  local finalAwardId = LuckybackActivitySystem.globalConfig.finalAwardId
  local itemUpgradeCfg = CDataTable.GetTableByFilter("ItemUpgradeConfig", "FavourateItemID", finalAwardId)
  local upgradeInfo = {}
  if not itemUpgradeCfg then
    return upgradeInfo
  end
  for _, v in pairs(itemUpgradeCfg) do
    table.insert(upgradeInfo, v)
  end
  table.sort(upgradeInfo, function(a, b)
    return a.level < b.level
  end)
  return upgradeInfo
end
function LuckybackActivitySystem.GetUpgradeMaxLevel()
  local upgradeInfo = LuckybackActivitySystem.GetItemUpgradeInfo() or {}
  return #upgradeInfo
end
function LuckybackActivitySystem.GetItemCurUpgradeLevel()
  local upgradeInfo = LuckybackActivitySystem.GetItemUpgradeInfo() or {}
  if next(upgradeInfo) then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local level = 0
    for i, v in ipairs(upgradeInfo) do
      if wardrobe_data:GetHallDepotItemDataByResID(v.ItemID) then
        level = i
      end
    end
    if level == 0 then
      level = 1
    end
    return level
  else
    return 0
  end
end
function LuckybackActivitySystem.GetItemCurLevelUpgradeCfg(level)
  local upgradeInfo = LuckybackActivitySystem.GetItemUpgradeInfo() or {}
  if upgradeInfo[level] then
    return upgradeInfo[level]
  end
  return nil
end
function LuckybackActivitySystem.GetItemUpgradeHasNumByLevel(level)
  local upgradeInfo = LuckybackActivitySystem.GetItemUpgradeInfo() or {}
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local hasNum1 = 0
  local hasNum2 = 0
  if upgradeInfo[level] then
    local itemData1 = wardrobeData:GetHallDepotItemDataByResID(upgradeInfo[level].CostItem1)
    local itemData2 = wardrobeData:GetHallDepotItemDataByResID(upgradeInfo[level].CostItem2)
    hasNum1 = itemData1 and itemData1.count or 0
    hasNum2 = itemData2 and itemData2.count or 0
  end
  return hasNum1, hasNum2
end
function LuckybackActivitySystem.IsMoreButtonToParam1()
  local ActivityEntrySetSystem = require("client.slua.logic.activity.logic_activity_entry_set")
  local data = ActivityEntrySetSystem.GetData()
  if data and LuckybackActivitySystem.globalConfig.returnJumpUrl ~= "" then
    return true
  end
  return false
end
function LuckybackActivitySystem.NeedShowFx(count)
  if LuckybackActivitySystem.entranceType ~= 2 and LuckybackActivitySystem.entranceType ~= 3 then
    return 0
  end
  local idx = 0
  for i, v in ipairs(LuckybackActivitySystem.globalConfig.debrisFxBarList) do
    if count >= tonumber(v) then
      idx = i
    else
      break
    end
  end
  if idx == 0 then
    return 0
  end
  if idx == #LuckybackActivitySystem.globalConfig.debrisFxBarList then
    LuckybackActivitySystem.SaveDebrisFx(idx, LuckybackActivitySystem.activityId)
    return 2
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLuckyBackTips)
  if not (saveData and saveData.FxValueTable) or not saveData.FxValueTable[tostring(LuckybackActivitySystem.activityId)] then
    LuckybackActivitySystem.SaveDebrisFx(idx, LuckybackActivitySystem.activityId)
    return 1
  end
  local lastIndex = saveData.FxValueTable[tostring(LuckybackActivitySystem.activityId)]
  log_tree("saveData.BubbleValueTable", saveData.FxValueTable)
  log(bWriteLog and "LuckybackActivitySystem.NeedShowBubble" .. idx .. lastIndex)
  if idx > lastIndex then
    LuckybackActivitySystem.SaveDebrisFx(idx, LuckybackActivitySystem.activityId)
    return 1
  end
  return 0
end
function LuckybackActivitySystem.SaveDebrisFx(index, actId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLuckyBackTips)
  saveData = saveData or {}
  saveData.FxValueTable = saveData.FxValueTable or {}
  saveData.FxValueTable[tostring(actId)] = index
  log_tree("saveData.FxValueTable", saveData.FxValueTable)
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eLuckyBackTips)
end
function LuckybackActivitySystem.GetDropItemsLastPos()
  if not LuckybackActivitySystem.dropList or not next(LuckybackActivitySystem.dropList) then
    return 1
  else
    return LuckybackActivitySystem.dropList[#LuckybackActivitySystem.dropList].pos_id
  end
end
function LuckybackActivitySystem.NeedShowBubble()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLuckyBackTips)
  if not (saveData and saveData.HasBubbleShow) or not saveData.HasBubbleShow[tostring(LuckybackActivitySystem.activityId)] then
    saveData = saveData or {}
    saveData.HasBubbleShow = saveData.HasBubbleShow or {}
    saveData.HasBubbleShow[tostring(LuckybackActivitySystem.activityId)] = true
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eLuckyBackTips)
    return true
  end
  log_tree("saveData.HasBubbleShow", saveData.HasBubbleShow)
  return false
end
function LuckybackActivitySystem.RegisterItemGetShowFunc(activityId, func)
  if not activityId or type(func) ~= "function" then
    return
  end
  LuckybackActivitySystem.activityId2ShowPanelFunc[activityId] = func
end
function LuckybackActivitySystem.GetActIdListByType(type)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actTable = ActivityNewSystem.GetActivityListByType(ActivityType.LUCKYBACK)
  local actList = {}
  for i, cfg in pairs(actTable) do
    if tonumber(cfg.TabType) == type then
      log(bWriteLog and "LuckybackActivitySystem.GetActIdByType findAct ,Type = " .. tostring(type) .. " || id = " .. tostring(cfg.ID))
      table.insert(actList, cfg.ID)
    end
  end
  log(bWriteLog and "LuckybackActivitySystem.GetActIdByType NoAct ,Type = " .. tostring(type))
  return actList
end
function LuckybackActivitySystem.GetExchangeItemByActId(activity_id)
  if LuckybackActivitySystem.exchangeInfo and activity_id then
    return LuckybackActivitySystem.exchangeInfo[activity_id]
  end
  return nil
end
function LuckybackActivitySystem.GetActivityIdByDiyWeaponId(itemId)
  if next(LuckybackActivitySystem.DiyWeaponIdMap) == nil then
    LuckybackActivitySystem.InitDiyWeaponIdMap()
  end
  if itemId == nil or itemId == 0 and next(LuckybackActivitySystem.DiyWeaponIdMap) then
    for _, v in pairs(LuckybackActivitySystem.DiyWeaponIdMap) do
      return v
    end
  end
  if LuckybackActivitySystem.DiyWeaponIdMap[itemId] ~= nil then
    return LuckybackActivitySystem.DiyWeaponIdMap[itemId]
  end
  return nil
end
function LuckybackActivitySystem.ResetDataWhileLogin()
  _UpdateDiscountRedPoint(false)
  LuckybackActivitySystem.RedDotMap = {}
  LuckybackActivitySystem.exchangeInfo = {}
end
function LuckybackActivitySystem.IsShowRedPoint()
  if LuckybackActivitySystem.redPoint.lastRedDot ~= LuckybackActivitySystem.redPoint.curRedDot then
    LuckybackActivitySystem.redPoint.lastRedDot = LuckybackActivitySystem.redPoint.curRedDot
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_LUCKY_BACK, LuckybackActivitySystem.redPoint.curRedDot)
  end
end
function LuckybackActivitySystem.CheckCanShowBannerRedPoint()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local list = ActivityNewSystem.GetActivityListByType(ActivityType.LUCKYBACK)
  log(bWriteLog and "LuckybackActivitySystem.CanShowBannerRedPoint" .. #list)
  if 1 < #list then
    LuckybackActivitySystem.redPoint.bannerRedPoint = false
  else
    LuckybackActivitySystem.redPoint.bannerRedPoint = true
  end
end
function LuckybackActivitySystem.CanShowBannerRedPoint()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local list = ActivityNewSystem.GetActivityListByType(ActivityType.LUCKYBACK)
  log(bWriteLog and "LuckybackActivitySystem.CanShowBannerRedPoint" .. #list)
  if 1 < #list then
    return false
  end
  return true
end
function LuckybackActivitySystem.InitRedPoint()
  local NeedBioChemicalShow = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 2)
  log(bWriteLog and "luckyback Latest Banner " .. tostring(NeedBioChemicalShow))
  _UpdateCurRedDot((NeedBioChemicalShow or LuckybackActivitySystem.redPoint.discountRedPoint) and LuckybackActivitySystem.redPoint.bannerRedPoint)
  log(bWriteLog and "luckyback Latest Banner2 " .. tostring(LuckybackActivitySystem.redPoint.curRedDot))
end
function LuckybackActivitySystem.GetTitle()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[LuckybackActivitySystem.activityId]
  if data and data.cfg and data.cfg.activity_name then
    return data.cfg.activity_name
  else
    return ""
  end
end
function LuckybackActivitySystem.GetRedDotIsShowByType(type)
  local list = LuckybackActivitySystem.GetActIdListByType(type)
  for i, data in pairs(list) do
    if LuckybackActivitySystem.RedDotMap[data] == true then
      return true
    end
  end
  return false
end
function LuckybackActivitySystem.InitDiyWeaponIdMap()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local list = ActivityNewSystem.GetActivityListByType(ActivityType.LUCKYBACK)
  for i, cfg in pairs(list) do
    if tonumber(cfg.TabType) == 2 and cfg.List and cfg.List[1] and cfg.List[1].Condition and cfg.List[1].Condition[4] ~= 0 then
      local info = cfg.List[1]
      LuckybackActivitySystem.DiyWeaponIdMap[tonumber(info.Condition[4])] = tonumber(info.ID)
    end
  end
end
function LuckybackActivitySystem.GetMaterialIsEnough()
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local level = 0
  if next(LuckybackActivitySystem.WeaponUpdateData) then
    for i, j in pairs(LuckybackActivitySystem.WeaponUpdateData) do
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      if wardrobe_data:GetHallDepotItemDataByResID(j.ItemID) ~= nil then
        level = i
      end
    end
  end
  if 0 < level then
    local data = LuckybackActivitySystem.WeaponUpdateData[level + 1]
    local itemData1 = wardrobeData:GetHallDepotItemDataByResID(data.CostItem1)
    local itemData2 = wardrobeData:GetHallDepotItemDataByResID(data.CostItem2)
    if itemData1 and itemData2 and itemData1.count >= data.CostItemNum1 and itemData2.count >= data.CostItemNum2 then
      log(bWriteLog and "[ljw] canAutoUpdate")
      return true
    end
  end
  return false
end
function LuckybackActivitySystem.send_get_lucky_draw_collect_award_req()
  if LuckybackActivitySystem.activityId > 0 then
    local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
    LuckybackHandler.send_get_lucky_draw_collect_award_req(LuckybackActivitySystem.activityId)
  else
    log(bWriteLog and "LuckybackActivitySystem.send_get_lucky_draw_collect_award_req not activityId")
  end
end
function LuckybackActivitySystem.on_get_lucky_draw_collect_award_rsp(activity_id)
  if activity_id == LuckybackActivitySystem.activityId then
    _UpdateGoldenClothCollectGetState(true)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_GET_COLLECT_REWARD, LuckybackActivitySystem.globalConfig.goldenCollectRewardInfo)
  end
end
function LuckybackActivitySystem.get_lucky_draw_back_activity_req()
  log(bWriteLog and "[cw] LuckybackActivitySystem.get_lucky_draw_back_activity_req: " .. tostring(LuckybackActivitySystem.activityId))
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  if LuckybackActivitySystem.activityId and LuckybackActivitySystem.activityId ~= 0 then
    LuckybackHandler.send_get_lucky_draw_back_activity_req(LuckybackActivitySystem.activityId)
  end
end
function LuckybackActivitySystem.get_lucky_draw_back_activity_rsp(rs, cfg, myData, activityData)
  log(bWriteLog and "[cw] LuckybackActivitySystem.get_lucky_draw_back_activity_rsp.rs:" .. tostring(rs))
  log_tree("[cw] LuckybackActivitySystem.rs", rs)
  if rs == LuckybackActivitySystem.Enum_Err_Code.success then
    log_tree("[cw] LuckybackActivitySystem.cfg", cfg)
    log_tree("[cw] LuckybackActivitySystem.myData", myData)
    if myData.activity_id ~= LuckybackActivitySystem.activityId then
      return true
    end
    if activityData then
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      ActivityNewSystem.UpdateOneActivityData(LuckybackActivitySystem.activityId, activityData)
    end
    LuckybackActivitySystem.resCfg = cfg
    LuckybackActivitySystem.resMyData = myData
    LuckybackActivitySystem.PreSetActData(myData.activity_id)
    _SetConfig(cfg, myData)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_GET_ACTIVITY_DATA)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_UPDATE)
  else
    ShowNotice(rs)
    return true
  end
end
function LuckybackActivitySystem.do_one_draw_back_by_activity_req(draw_type, coupon_id)
  local Logic_LuckyDouble_Activity = require("client.slua.logic.lobby_activity.logic_luckydouble_activity")
  local playerData = LuckybackActivitySystem.playerData
  local isEnough = true
  local price = 0
  if draw_type == 1 then
    isEnough, price = Logic_LuckyDouble_Activity.JudgeIsEnoughUC(playerData.oneDrawFinalPrice, coupon_id)
  else
    isEnough, price = Logic_LuckyDouble_Activity.JudgeIsEnoughUC(playerData.tenDrawFinalPrice, coupon_id)
  end
  if isEnough then
    local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
    if coupon_id and 0 < coupon_id then
      LuckybackHandler.send_do_one_draw_back_by_activity_req(LuckybackActivitySystem.activityId, draw_type, nil, coupon_id)
    else
      LuckybackHandler.send_do_one_draw_back_by_activity_req(LuckybackActivitySystem.activityId, draw_type)
    end
  else
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(price)
  end
end
function LuckybackActivitySystem.do_one_draw_by_tick(ticket)
  if not LuckybackActivitySystem.IsHaveDrawReplaceTicket() then
    return
  end
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_do_one_draw_back_by_activity_req(LuckybackActivitySystem.activityId, 1, ticket)
end
function LuckybackActivitySystem.do_one_draw_back_by_activity_rsp(rs, myData, award_info, decompose_list, draw_type, addition_awards)
  log(bWriteLog and "[cw] LuckybackActivitySystem.do_one_draw_back_by_activity_rsp rs:  " .. tostring(rs))
  log_tree("[hhy] myData:", myData)
  log_tree("[cw] award_info:", award_info)
  log_tree("[cw] decompose_list:", decompose_list)
  log(bWriteLog and "[YY]do_one_draw_back_by_activity_rsp===draw_type==" .. tostring(draw_type))
  if decompose_list then
    for k, v in pairs(decompose_list) do
      for nItemId, _ in pairs(v) do
        if nItemId == award_info[k].resid then
          v[nItemId] = nil
          break
        end
      end
    end
  end
  LuckybackActivitySystem.isWaitingForRes = false
  if rs ~= LuckybackActivitySystem.Enum_Err_Code.success then
    ShowNotice(rs)
    if rs == LuckybackActivitySystem.Enum_Err_Code.luckyback_err_need_res_not_enough then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
    end
  else
    _ClearDropList()
    _UpdateDropList(award_info)
    _ReportCost()
    _SetTotalDrawTime(myData.sum_draw_times)
    _SetOneDrawTime(myData.one_draw_times)
    _SetTenDrawTime(myData.duo_draw_times)
    _UpdateLuckyValue(myData.cur_lucky_value)
    _UpdateDiscountRedPoint(false)
    _UpdatePriceInfo(myData.is_uc_discount_by_day)
    _UpdateDebrisCount()
    LuckybackActivitySystem.RedDotMap[LuckybackActivitySystem.activityId] = LuckybackActivitySystem.redPoint.discountRedPoint
    _UpdateCurRedDot(LuckybackActivitySystem.redPoint.discountRedPoint and LuckybackActivitySystem.redPoint.bannerRedPoint)
    LuckybackActivitySystem.    LuckybackActivitySystem.tExtraGetData = addition_awards
    LuckybackActivitySystem.decomposeList = decompose_list
    _PostDrawEvent(draw_type)
    _PostStatusChangeEvent()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_REFRESH)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_GET_DRAW_BACK, LuckybackActivitySystem.award_info)
    LuckybackActivitySystem.CheckShowAvailableAwardRedDot()
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_STOP_COIN_UPDATE_TIMER)
end
function LuckybackActivitySystem.get_sum_draw_award_by_activity_req(times)
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_get_sum_draw_award_by_activity_req(LuckybackActivitySystem.activityId, times, true)
end
function LuckybackActivitySystem.get_sum_draw_award_by_activity_rsp(rs, myData, award_info)
  log(bWriteLog and "[cw] LuckybackActivitySystem.get_sum_draw_award_by_activity_rsp:" .. tostring(rs))
  if rs ~= LuckybackActivitySystem.Enum_Err_Code.success then
    ShowNotice(rs)
    return
  end
  log_tree("[cw] myData ", myData)
  log_tree("[cw] award_info:", award_info)
  _ShowCommonItemPanel(award_info)
  _UpdatePriceInfo(myData.is_uc_discount_by_day)
  _UpdateLuckyValue(myData.cur_lucky_value)
  _SetTotalDrawTime(myData.sum_draw_times)
  _SetOneDrawTime(myData.one_draw_times)
  _SetTenDrawTime(myData.duo_draw_times)
  _UpdateDebrisCount()
  _UpdateTotalDrawAwardConfig(myData.sum_draw_award_info)
  _UpdateNewTotalDrawAwardConfig(myData.sum_draw_award_info)
  _PostStatusChangeEvent()
  _PostIconShow()
  LuckybackActivitySystem.CloseRewardBox()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_TAKE_CUMULATIVE_AWARD)
end
function LuckybackActivitySystem.do_exchange_by_activity_id_rsp(rs, myData, award_info, activity_id)
  log(bWriteLog and "[cw] LuckybackActivitySystem.do_exchange_by_activity_id_rsp: " .. tostring(rs))
  if rs ~= LuckybackActivitySystem.Enum_Err_Code.success then
    ShowNotice(rs)
    return
  end
  log_tree("[cw] myData:", myData)
  log_tree("[cw] award_info ", award_info)
  log(bWriteLog and "[cw] activity_id:" .. tostring(activity_id))
  if not activity_id then
    log_error(bWriteLog and "[cw] LuckybackActivitySystem.do_exchange_by_activity_id_rsp with nil activity_id")
    return
  end
  local arrayItemList = _FormatData(award_info)
  local MemoryID
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  if activity_id == logic_xsuit_activity:GetExchangeActivityID() then
    local periodList = logic_xsuit_activity:GetGiftPeriodList()
    if award_info then
      for _, v in pairs(award_info) do
        for _, period in pairs(periodList) do
          if v.resid == logic_xsuit_activity:GetMemoryID(period) then
            MemoryID = v.resid
            break
          end
        end
        if MemoryID then
          break
        end
      end
    end
  end
  if MemoryID then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(MemoryID)
    if itemData then
      local itemCfg = CDataTable.GetTableData("Item", MemoryID)
      if itemCfg.itemSubType == 6012 then
        local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
        LogicXSuit.ShowSelectStateUI(tonumber(itemData.insID))
      else
        local XSuitHandler = require("client.network.Protocol.XSuitHandler")
        XSuitHandler.send_open_gold_dress_req(tonumber(itemData.insID))
      end
    else
      log_error("MemoryID not found in Depot !!  " .. tostring(MemoryID))
    end
  elseif LuckybackActivitySystem.activityId2ShowPanelFunc[activity_id] then
    LuckybackActivitySystem.activityId2ShowPanelFunc[activity_id](arrayItemList)
  else
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
  end
  local extra_info = myData and myData.exchange_extra_info or {}
  local limitInfo = myData and myData.new_limit_exchange_info or {}
  for i, v in pairs(LuckybackActivitySystem.exchangeItemList) do
    if limitInfo then
      for key, value in pairs(limitInfo) do
        if string.find(key, tostring(v.itemId)) then
          v.hasExchangeCount = limitInfo[key] or 0
        end
      end
    else
      v.hasExchangeCount = 0
    end
    if extra_info[v.itemId] then
      v.hasExchangeFromGift = true
    else
      v.hasExchangeFromGift = false
    end
  end
  if LuckybackActivitySystem.exchangeInfo[activity_id] then
    for i, v in pairs(LuckybackActivitySystem.exchangeInfo[activity_id]) do
      if limitInfo then
        v.hasExchangeCount = limitInfo[formatItem(v.itemId, v.itemNum, v.validTime)] or v.hasExchangeCount
      else
        v.hasExchangeCount = 0
      end
      if extra_info[v.itemId] then
        v.hasExchangeFromGift = true
      else
        v.hasExchangeFromGift = false
      end
    end
  end
  local LuckyMixActivitySystem = require("client.slua.logic.lobby_activity.logic_luckmix_activity")
  LuckyMixActivitySystem.UpdateDebrisCount()
  _UpdateDebrisCount()
  LuckybackActivitySystem.CloseExchangeConfirm()
  _PostExchangeDataRefreshEvent()
end
function LuckybackActivitySystem.get_exchange_activity_info_req(activityID)
  log(bWriteLog and "[cw] LuckybackActivitySystem.get_exchange_activity_info_req(" .. tostring(activityID or LuckybackActivitySystem.exchangeConfig.exchangeActId) .. ") ")
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  if activityID then
    log(bWriteLog and "[cw] send with activityID " .. tostring(activityID) .. " type: " .. tostring(type(activityID)))
  else
    log(bWriteLog and "[cw] send with systemRecord " .. tostring(LuckybackActivitySystem.exchangeConfig.exchangeActId) .. " type: " .. tostring(type(LuckybackActivitySystem.exchangeConfig.exchangeActId)))
  end
  LuckybackHandler.send_get_exchange_activity_info_req(tonumber(activityID) or LuckybackActivitySystem.exchangeConfig.exchangeActId)
end
function LuckybackActivitySystem.get_exchange_activity_info_rsp(rs, exchange_table, mydata, activity_id, discount_cfg, sheet_shield_cfg)
  log(bWriteLog and "[cw] LuckybackActivitySystem.get_exchange_activity_info_rsp: " .. tostring(rs))
  if rs == LuckybackActivitySystem.Enum_Err_Code.success then
    _SetExchangeConfig(exchange_table, mydata, activity_id, discount_cfg or {}, sheet_shield_cfg)
    _UpdateDebrisCount()
    _SetExchangeDataGetTime()
    _PostExchangeDataRefreshEvent()
  else
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_EXCHANGE_ERROR, rs)
    ShowNotice(rs)
  end
end
function LuckybackActivitySystem.on_draw_exchange_discount_by_actid_rsp(activity_id, itemid, discount)
  local itemList = LuckybackActivitySystem.exchangeInfo[activity_id]
  if itemList then
    for _, v in pairs(itemList) do
      if v.itemId == itemid then
        v.drawDiscount = discount
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_REFRESH_DISCOUNT, itemid, discount)
end
function LuckybackActivitySystem.get_lucky_draw_back_redpoint_rsp(need_redpoint_activity)
  log_tree("LuckybackActivitySystem.get_lucky_draw_back_redpoint_rsp", need_redpoint_activity)
  _UpdateDiscountRedPoint(need_redpoint_activity and #need_redpoint_activity == 1)
  _UpdateCurRedDot(LuckybackActivitySystem.redPoint.discountRedPoint)
  if need_redpoint_activity then
    for i, j in pairs(need_redpoint_activity) do
      LuckybackActivitySystem.RedDotMap[j] = true
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      local actInfo = ActivityNewSystem.GetActivityByID(j)
      if actInfo and actInfo.TabType == 2 then
        _UpdateDiscountRedPoint(false)
      end
    end
  end
  _UpdateDebrisCount()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_RED_DOT_INIT)
end
function LuckybackActivitySystem.send_get_lucky_draw_back_voucher_req(activity_id)
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_get_lucky_draw_back_voucher_req(activity_id)
end
function LuckybackActivitySystem.on_get_lucky_draw_back_voucher_rsp(rs, todayCoupon)
  if rs ~= 0 then
    return
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(todayCoupon)
  _PostConponChangeEvent()
end
function LuckybackActivitySystem.do_one_to_batch_exchange_by_activity_id_req(activity_id, award_item_list)
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_do_one_to_batch_exchange_by_activity_id_req(activity_id, award_item_list)
end
function LuckybackActivitySystem.do_one_to_batch_exchange_by_activity_id_rsp(err_code, my_activity_data, award_list, activity_id)
  if err_code == 0 then
    local level = 0
    if next(LuckybackActivitySystem.WeaponUpdateData) then
      for i, j in pairs(LuckybackActivitySystem.WeaponUpdateData) do
        local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
        if wardrobe_data:GetHallDepotItemDataByResID(j.ItemID) ~= nil then
          level = i
        end
      end
    end
    local callback = function()
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      ItemUpgradeMgr.needAutoUpdate = true
      ItemUpgradeMgr.AutoUpdateInfo = LuckybackActivitySystem.WeaponUpdateData
      ItemUpgradeMgr.AutoUpdatelevel = level + 1
      GlobalData.JumpUrl(LuckybackActivitySystem.globalConfig.weaponJumpLink)
    end
    if LuckybackActivitySystem.GetMaterialIsEnough() then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_TwoBtnStyle(award_list, "\231\171\139\229\141\179\229\141\135\231\186\167\239\188\136\228\184\180\230\151\182\239\188\137", callback)
    else
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
    end
    _PostStatusChangeEvent()
  else
    ShowNotice(err_code)
  end
end
function LuckybackActivitySystem.UpdateDebrisCount()
  _UpdateDebrisCount()
end
function LuckybackActivitySystem.ShouldShowVideo(save)
  local needShow = false
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local videoPlayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eLuckybackVideoPlayRecord)
  local key = tostring(LuckybackActivitySystem.activityId)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  serverTime = TimeUtil.FormatTime_YMD(serverTime, true)
  if videoPlayRecord == nil then
    log(bWriteLog and "[HZA][video]SpinVideoPlayer:PlayVideoWhenNeed, LoadFileToTable failed.")
    videoPlayRecord = {}
    videoPlayRecord[key] = serverTime
    needShow = true
  elseif videoPlayRecord[key] == nil then
    videoPlayRecord[key] = serverTime
    log(bWriteLog and "[HZA][video]SpinVideoPlayer:PlayVideoWhenNeed, first show.")
    needShow = true
  else
    log(bWriteLog and "[HZA][video][record] serverTime:" .. tostring(serverTime))
    log(bWriteLog and "[HZA][video][record] videoPlayRecord[key]:" .. tostring(videoPlayRecord[key]))
    if serverTime == videoPlayRecord[key] then
      log(bWriteLog and "[HZA][video]SpinVideoPlayer:PlayVideoWhenNeed, have showed.")
      needShow = false
    else
      if save then
        videoPlayRecord[key] = serverTime
      end
      log(bWriteLog and "[HZA][video]SpinVideoPlayer:PlayVideoWhenNeed, new day.")
      log_tree("videoPlayRecord", videoPlayRecord)
      needShow = true
    end
  end
  if save and needShow then
    log(bWriteLog and "  : save playVideo")
    playerPrefsSystem.SaveTableToFile_N(videoPlayRecord, playerPrefsSystem.ePlayerPrefsType.eLuckybackVideoPlayRecord)
  end
  return needShow
end
function LuckybackActivitySystem.JumpLuckExchange(_, _, vars)
  if not vars or not next(vars) then
    log_warning(bWriteLog and "  :LuckybackActivitySystem.JumpExchange vars error")
    return
  end
  local actId = tonumber(vars.activityid)
  local exchangeId = tonumber(vars.exchangeid)
  if not actId or not exchangeId then
    log_warning(bWriteLog and "  :LuckybackActivitySystem.JumpExchange id error")
    return
  end
  LuckybackActivitySystem.activityId = actId
  log_warning(bWriteLog and "  :JumpLuckExchange actId: " .. tostring(actId))
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_get_lucky_draw_back_activity_req(LuckybackActivitySystem.activityId):Then(function(_)
    if GameStatus.IsInLobbyOrMainCity() then
      if not LuckybackActivitySystem.PreSetActData(actId) then
        log_warning(bWriteLog and "  : cant jump exchangeConfig")
        return
      end
      LuckybackActivitySystem.exchangeTabId = tonumber(vars.tabid) or 1
      LuckybackActivitySystem.SetBackActData()
      local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
      local extraData = {ExchangeActivityID_HasBeOpen = true}
      local resourceType = LuckybackActivitySystem.exchangeConfig.exchangeResourceType
      local exchangeList = LuckybackActivitySystem.backExchangeData[exchangeId]
      if exchangeList and next(exchangeList) then
        for _, v in pairs(exchangeList) do
          logic_lucky_exchange.send_get_exchange_activity_info_req(v)
          logic_lucky_exchange.OpenExchange(resourceType, v, extraData)
        end
        logic_lucky_exchange.OpenExchange(resourceType, exchangeId, extraData)
      else
        logic_lucky_exchange.CloseExchangeUIByKey(resourceType)
        logic_lucky_exchange.OpenExchange(resourceType, exchangeId)
      end
    end
  end)
end
function LuckybackActivitySystem.IsHaveAvailableAwardRed(actId)
  if actId == nil or actId == 0 then
    return false
  end
  if LuckybackActivitySystem.drawRewardRed[actId] == nil then
    local table_util = require("common.table_util")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local ActivityData = ActivityNewSystem.GetActivityByID(actId)
    local awardRedPoint = table_util.GetTableValue(ActivityData, "other", "red_point_award")
    LuckybackActivitySystem.drawRewardRed[actId] = awardRedPoint and awardRedPoint == 1
  end
  return LuckybackActivitySystem.drawRewardRed[actId]
end
function LuckybackActivitySystem.CheckShowAvailableAwardRedDot()
  local totalDrawTimes = LuckybackActivitySystem.playerData.totalDrawTime
  local boxConfig = LuckybackActivitySystem.totalDrawAwardConfig
  log(bWriteLog and string.format("LuckybackActivitySystem.CheckShowAvailableAwardRedDot "))
  if not boxConfig or not next(boxConfig) then
    log_error(bWriteLog and "[cw][BackStyleTotalDrawBoxManager_Supply] UpdateAllTotalDrawBox boxConfig is illegal")
    return false
  end
  for i, v in ipairs(boxConfig) do
    if not v.hasGet and totalDrawTimes >= v.timesCount then
      local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
      store_reddot_manager:SetActAvailableRedDot(LuckybackActivitySystem.activityId, LuckybackActivitySystem.moduleId)
      LuckybackActivitySystem.drawRewardRed[LuckybackActivitySystem.activityId] = true
      return true
    end
  end
  return false
end
function LuckybackActivitySystem.CheckCloseAvailableAwardRedDot()
  local totalDrawTimes = LuckybackActivitySystem.playerData.totalDrawTime
  local boxConfig = LuckybackActivitySystem.totalDrawAwardConfig
  log(bWriteLog and string.format("LuckybackActivitySystem.CheckAvailableAward "))
  if not boxConfig or not next(boxConfig) then
    log_error(bWriteLog and "[cw][BackStyleTotalDrawBoxManager_Supply] UpdateAllTotalDrawBox boxConfig is illegal")
    return false
  end
  local availableMark = false
  for i, v in ipairs(boxConfig) do
    if not v.hasGet and totalDrawTimes >= v.timesCount then
      availableMark = true
      break
    end
  end
  if not availableMark then
    LuckybackActivitySystem.drawRewardRed[LuckybackActivitySystem.activityId] = false
    local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
    store_reddot_manager:CloseActAvailableRedDot(LuckybackActivitySystem.activityId, LuckybackActivitySystem.moduleId)
  end
end
function LuckybackActivitySystem.SetBackActData()
  LuckybackActivitySystem.ClearExchangeData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActData = ActivityNewSystem.GetActivityListByType(74)
  if not ActData then
    log_error(bWriteLog and "[jinqiang] Can't get ActData or is nil ")
  end
  local table_util = require("common.table_util")
  for id, data in pairs(ActData) do
    table.insert(LuckybackActivitySystem.backExchangeID, data.ID)
    local condition = table_util.GetTableValue(data, "List", 1, "Condition", 1)
    if condition and type(condition) == "number" and condition ~= 0 then
      LuckybackActivitySystem.backExchangeCoinAndActID[data.ID] = condition
    end
  end
  LuckybackActivitySystem.assembleActIDAndCoin()
end
function LuckybackActivitySystem.ClearExchangeData()
  LuckybackActivitySystem.backExchangeID = {}
  LuckybackActivitySystem.backExchangeCoinAndActID = {}
  LuckybackActivitySystem.backExchangeData = {}
end
function LuckybackActivitySystem.assembleActIDAndCoin()
  log(bWriteLog and "[SY]LuckybackActivitySystem:assembleActIDAndCoin.")
  for id_one, coinID_one in pairs(LuckybackActivitySystem.backExchangeCoinAndActID) do
    local temp = {}
    table.insert(temp, #temp + 1, id_one)
    for id_two, coinID_two in pairs(LuckybackActivitySystem.backExchangeCoinAndActID) do
      if id_two ~= id_one and coinID_one == coinID_two then
        table.insert(temp, #temp + 1, id_two)
      end
    end
    if 1 < #temp then
      LuckybackActivitySystem.backExchangeData[temp[1]] = temp
    end
  end
end
function LuckybackActivitySystem.GetExchangeActData()
  if not LuckybackActivitySystem.backExchangeData then
    log_error(bWriteLog and "[jinqiang] Can't get LuckybackActivitySystem.backExchangeData or is nil")
  end
  return LuckybackActivitySystem.backExchangeData
end
return LuckybackActivitySystem