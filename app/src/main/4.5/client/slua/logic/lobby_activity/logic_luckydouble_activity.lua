local super_data = require("common.super_data")
local test_BPCfg
local ENUM_EASTER_EGG_STATE = {AVAILABLE = 1, UNAVAILABLE = 2}
local LuckyDoubleActivitySystem = {
  Data = {},
  ActivityId = 0,
  ModuleID = BP_ENUM_MODULE_LUCKY_DOUBLE,
  EasterEggId = -1,
  EasterEggSuccessFuc = nil,
  TimePeriodStr = "",
  TimePeriodStrUTC = "",
  TimePeriodStrWithDesc = "",
  TicketId = 0,
  DropUcReturn = 0,
  DropItem = nil,
  tExtraGetData = nil,
  tDecomposeList = nil,
  ResourceConfig = {},
  IsJumpAnim = false,
  CurAwardPoolIndex = 1,
  CurRoundIndex = 1,
  CurBigAwardPoolConfig = {},
  CurSmallAwardPoolConfig = {},
  CurRoundDrawTimes = 0,
  CurPrice = 0,
  DiscountPrice = 0,
  CurCouponList = {},
  IsFinishedCurPool = false,
  EggItem_List = {},
  ResourceType = 0,
  ImageLink = "",
  ReturnJumpUrl = "",
  ENUM_EASTER_EGG_STATE = ENUM_EASTER_EGG_STATE,
  ENUM_LUCKY_DOUBLE_ERR_CODE = {
    SUCCESS = 0,
    double_round_draw_act_not_open_err = 100900001,
    double_round_draw_param_err = 100900002,
    double_round_draw_conf_err = 100900003,
    double_round_draw_db_err = 100900004,
    double_round_should_sync_db_data_err = 100900005,
    double_round_draw_uc_pay_err = 100900006,
    double_round_draw_err = 100900007,
    double_round_draw_uc_not_enough_err = 100900008,
    double_round_draw_voucher_not_enough_err = 100900009
  },
  playerData = super_data.CreateSuperData({
    EasterEggState = ENUM_EASTER_EGG_STATE.UNAVAILABLE
  })
}
local _PrintData = function()
  local d = LuckyDoubleActivitySystem
  log(bWriteLog and "[cw] d.CurAwardPoolIndex: " .. d.CurAwardPoolIndex)
  log(bWriteLog and "[cw] d.TicketId: " .. d.TicketId)
  log(bWriteLog and "[cw] d.CurRoundIndex: " .. d.CurRoundIndex)
  log_tree("[cw] d.ResourceConfig:", d.ResourceConfig)
  log_tree("[cw] d.CurBigAwardPoolConfig:", d.CurBigAwardPoolConfig)
  log_tree("[cw] d.CurSmallAwardPoolConfig:", d.CurSmallAwardPoolConfig)
  log_tree("[cw] d.CurPriceConfig:", d.CurPriceConfig)
end
local _GetExtInfo = function()
  return LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].extInfo
end
local _GetCurActInfo = function()
  return LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].actInfo[LuckyDoubleActivitySystem.CurAwardPoolIndex]
end
local _CreateDiscountData = function(serverData)
  local data = {
    discountList = serverData.discount_list,
    isDraw = serverData.draw_discount_flag,
    rate = serverData.discount_ratio,
    isHitDiscount = serverData.is_hit_discount
  }
  if serverData.is_hit_discount then
    data.discountValue = {
      discountType = serverData.hit_discount_type,
      discountPos = serverData.hit_discount,
      isMinDiscount = serverData.is_min_discount,
      isHitSpecialDicCount = serverData.is_hit_special_discount
    }
  end
  return data
end
local _SetDiscountCfg = function(cfg)
  if not cfg then
    return
  end
  local discountCfg = {}
  for pool, v in pairs(cfg) do
    discountCfg[pool] = {}
    for drawTimes, serverData in ipairs(v) do
      discountCfg[pool][drawTimes] = _CreateDiscountData(serverData)
    end
  end
  return discountCfg
end
local _UpdateCurActInfo = function(actInfo)
  local data = LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId]
  data.end
local _UpdateTicketID = function()
  LuckyDoubleActivitySystem.TicketId = _GetExtInfo().ticket_id
end
local _UpdateCurRound = function()
  LuckyDoubleActivitySystem.CurRoundIndex = _GetCurActInfo().cur_rounds
end
local _UpdateCurRoundDrawTimes = function()
  LuckyDoubleActivitySystem.CurRoundDrawTimes = _GetCurActInfo().little_pool_times
end
local _GetBigPoolInfo = function()
  return LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].bigPoolInfo
end
local _GetSmallPoolInfo = function()
  return LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].smallPoolInfo
end
local _GetPriceInfo = function()
  local data = LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId]
  if data and data.priceInfo then
    return data.priceInfo
  end
  return nil
end
local _GetCurPoolCurRoundAllPriceConfig = function()
  if _GetPriceInfo() and _GetPriceInfo()[LuckyDoubleActivitySystem.CurAwardPoolIndex] and _GetPriceInfo()[LuckyDoubleActivitySystem.CurAwardPoolIndex][LuckyDoubleActivitySystem.CurRoundIndex] then
    return _GetPriceInfo()[LuckyDoubleActivitySystem.CurAwardPoolIndex][LuckyDoubleActivitySystem.CurRoundIndex]
  else
    return nil
  end
end
local _GetCurPriceConfig = function()
  if _GetCurPoolCurRoundAllPriceConfig() and _GetCurPoolCurRoundAllPriceConfig()[LuckyDoubleActivitySystem.CurRoundDrawTimes] then
    return _GetCurPoolCurRoundAllPriceConfig()[LuckyDoubleActivitySystem.CurRoundDrawTimes]
  else
    return nil
  end
end
local _GetCurBigPoolConfig = function()
  return _GetBigPoolInfo()[LuckyDoubleActivitySystem.CurAwardPoolIndex]
end
local _GetCurSmallPoolConfig = function()
  return _GetSmallPoolInfo()[LuckyDoubleActivitySystem.CurAwardPoolIndex][LuckyDoubleActivitySystem.CurRoundIndex]
end
local _GetCurBigPoolDrawLog = function()
  return _GetCurActInfo().main_reward_info
end
local _GetCurSmallPoolDrawLog = function()
  return _GetCurActInfo().little_reward_info
end
local _UpdateIsFinishedCurPool = function()
  LuckyDoubleActivitySystem.IsFinishedCurPool = _GetCurActInfo().has_finish or false
end
local _UpdateCurBigPoolInfo = function()
  local awardConfig = _GetCurBigPoolConfig()
  local drawLog = _GetCurBigPoolDrawLog()
  for k, v in pairs(drawLog) do
    if v then
      awardConfig[k].got = true
    end
  end
  LuckyDoubleActivitySystem.CurBigAwardPoolConfig = awardConfig
end
local _UpdateCurSmallPoolInfo = function()
  local awardConfig = _GetCurSmallPoolConfig()
  local drawLog = _GetCurSmallPoolDrawLog()
  for k, v in pairs(drawLog) do
    if v then
      awardConfig[k].got = true
    end
  end
  LuckyDoubleActivitySystem.CurSmallAwardPoolConfig = awardConfig
end
local _UpdateCurPriceInfo = function()
  if _GetCurPriceConfig() then
    local disCountCfg = LuckyDoubleActivitySystem.GetDiscountDataByRound()
    LuckyDoubleActivitySystem.CurPrice = _GetCurPriceConfig().price_value
    if disCountCfg and disCountCfg.isHitDiscount then
      local discountVal = LuckyDoubleActivitySystem.GetDiscountValByRound()
      LuckyDoubleActivitySystem.DiscountPrice = math.floor(LuckyDoubleActivitySystem.CurPrice * discountVal)
    else
      LuckyDoubleActivitySystem.DiscountPrice = LuckyDoubleActivitySystem.CurPrice
    end
  else
    LuckyDoubleActivitySystem.CurPrice = -1
    LuckyDoubleActivitySystem.DiscountPrice = -1
  end
end
local _UpdateCurCouponList = function()
  if _GetCurPriceConfig() then
    LuckyDoubleActivitySystem.CurCouponList = _GetCurPriceConfig().voucher_list
  else
    LuckyDoubleActivitySystem.CurCouponList = {}
  end
end
local _380TempChangeBPPath = function(BPPath)
  local func_util = require("common.func_util")
  if func_util.CompareVersion(Client.GetAppVersion(), "3.8.0.00000") then
    local newPath = string.gsub(BPPath, "LuckyWidget", "FromUMG/LotteryTemplate")
    log(bWriteLog and "[SY]AsyncContainer:NewVersionBP." .. tostring(newPath))
    return newPath
  end
  return BPPath
end
local _UpdateBpPath = function()
  local ext_info = _GetExtInfo()
  LuckyDoubleActivitySystem.ResourceConfig = {
    bg_path = _380TempChangeBPPath(ext_info.act_main_blue_path),
    tip_path = ext_info.tips_blue_path,
    ticket_path = _380TempChangeBPPath(ext_info.ticket_blue_path),
    pool_path = _380TempChangeBPPath(ext_info.pool_blue_path),
    big_pool_sector_path = _380TempChangeBPPath(ext_info.main_draw_blue_path),
    small_pool_sector_path = _380TempChangeBPPath(ext_info.little_draw_blue_path),
    easter_egg_path = _380TempChangeBPPath(ext_info.lucky_egg_blue_path)
  }
end
local _RefreshData = function()
  _UpdateCurRound()
  _UpdateCurRoundDrawTimes()
  _UpdateCurBigPoolInfo()
  _UpdateCurSmallPoolInfo()
  _UpdateCurPriceInfo()
  _UpdateCurCouponList()
  _UpdateIsFinishedCurPool()
  LuckyDoubleActivitySystem.SetDiscountRedPoint(LuckyDoubleActivitySystem.ActivityId)
end
local _SwitchPoolTo = function(poolIndex)
  LuckyDoubleActivitySystem.CurAwardPoolIndex = poolIndex
  _RefreshData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_REFRESH_PAGE)
end
local _SetData = function()
  _UpdateBpPath()
  _UpdateTicketID()
  _RefreshData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKDOUBLE_INIT_UI)
end
local _SetConfig = function(main_pool_info, little_pool_info, price_info, activity_info, ext_info)
  local nCurDataActId = ext_info.activity_id
  if not nCurDataActId then
    return
  end
  local discountCfg = _SetDiscountCfg(activity_info.discount_info)
  LuckyDoubleActivitySystem.Data[nCurDataActId] = {
    bigPoolInfo = main_pool_info,
    smallPoolInfo = little_pool_info,
    priceInfo = price_info,
    actInfo = activity_info,
    discountCfg = discountCfg,
    extInfo = ext_info
  }
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKDOUBLE_GOT_ACT_DATA)
  LuckyDoubleActivitySystem.SetDiscountRedPoint(nCurDataActId)
  if LuckyDoubleActivitySystem.ActivityId ~= nCurDataActId then
    return
  end
  _SetData()
end
local _BlockAchievementPop = function()
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockPopTip()
end
local _UnblockAchievementPop = function()
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.UnblockPopTip()
end
local _SetActivityID = function(actID)
  LuckyDoubleActivitySystem.ActivityId = actID
end
local _SetEasterEggId = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  LuckyDoubleActivitySystem.EasterEggId = ActivityNewSystem.GetSurpriseActivityID(ActivityType.LUCKYUNBACK_SURPRISE, LuckyDoubleActivitySystem.ActivityId)
  LuckyDoubleActivitySystem.UpdateEasterEgg()
end
local _SetTimePeriodStr = function(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  local startTimeStr = TimeUtil.FormatTime_YMD(startTime)
  local endTimeStr = TimeUtil.FormatTime_YMD(endTime)
  LuckyDoubleActivitySystem.TimePeriodStrWithDesc = LocUtil.LocalizeResFormat(6515, startTimeStr, endTimeStr)
  LuckyDoubleActivitySystem.TimePeriodStr = TimeUtil.FormatTime_timeFrame(tonumber(startTime), tonumber(endTime), true)
  LuckyDoubleActivitySystem.TimePeriodStrUTC = TimeUtil.FormatTime_timeFrame(startTime, endTime, nil, true)
end
local _InitCurAwardPoolIndex = function()
  LuckyDoubleActivitySystem.CurAwardPoolIndex = 1
end
local _SetImageLink = function(imgLink)
  LuckyDoubleActivitySystem.ImageLink = imgLink
end
local _SetResourceType = function(label_type, back_up_one)
  if back_up_one and back_up_one ~= "" then
    LuckyDoubleActivitySystem.ResourceType = tonumber(back_up_one)
  else
    LuckyDoubleActivitySystem.ResourceType = label_type
  end
  log(bWriteLog and "[YY]_SetResourceType==" .. tostring(back_up_one))
end
local _SetJumpLink = function(jumpLink)
  LuckyDoubleActivitySystem.ReturnJumpUrl = jumpLink or ""
end
local _DelayDecompose = function()
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.needDelay = true
end
local _ReopenDecompose = function()
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.needDelay = false
end
local _OpenUIByType = function(supplyShowCallBack)
  local LuckyDoubleConfig = require("client.slua.logic.lobby_activity.LuckyDoubleConfig")
  local resourceConfig = LuckyDoubleConfig[LuckyDoubleActivitySystem.ResourceType]
  if not resourceConfig then
    ShowNotice(6497)
    return
  end
  if supplyShowCallBack then
    supplyShowCallBack(UIManager.UI_Config[resourceConfig.MainPool])
  else
    UIManager.ShowUI(UIManager.UI_Config[resourceConfig.MainPool])
  end
end
local _CheckData = function()
  if LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId] and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].bigPoolInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].smallPoolInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].priceInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].actInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].extInfo then
    _SetData()
  else
    LuckyDoubleActivitySystem.send_get_lucky_double_activity_req(LuckyDoubleActivitySystem.ActivityId)
  end
end
local _OnlyCloseUIByType = function()
  local config = require("client.slua.logic.lobby_activity.LuckyDoubleConfig")
  local KeyName = config and config[LuckyDoubleActivitySystem.ResourceType] and config[LuckyDoubleActivitySystem.ResourceType].MainPool
  if KeyName then
    UIManager.CloseUI(UIManager.UI_Config[KeyName])
  end
end
local _CloseUIByType = function()
  local config = require("client.slua.logic.lobby_activity.LuckyDoubleConfig")
  local KeyName = config and config[LuckyDoubleActivitySystem.ResourceType] and config[LuckyDoubleActivitySystem.ResourceType].MainPool
  if KeyName then
    UIManager.CloseUI(UIManager.UI_Config[KeyName])
  end
end
local _ShowUCNotEnough = function(price)
  local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
  CommonPayBoxMgr.ShowUcRechargeMsg(price)
end
function LuckyDoubleActivitySystem.OpenMainUI(eventType, eventID, vars)
  LuckyDoubleActivitySystem.OpenUIWithActId(vars.activityid or vars.Id)
end
function LuckyDoubleActivitySystem.OpenUIWithActId(actId, supplyShowCallBack)
  if actId == nil or tonumber(actId) == 0 then
    ShowNotice(120106)
    log(bWriteLog and "[cw] actId is NULL")
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(actId)]
  if data == nil then
    log(bWriteLog and "[cw] not exist ")
    ShowNotice(4002)
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
  end
  _SetActivityID(tonumber(actId))
  _SetEasterEggId()
  _DelayDecompose()
  _BlockAchievementPop()
  _InitCurAwardPoolIndex()
  _SetResourceType(data.cfg.label_type or 0, data.cfg.back_up_one or "")
  _SetJumpLink(data.cfg.return_jump_link)
  _SetImageLink(data.cfg.activity_image_link or "")
  _SetTimePeriodStr(data.cfg.start_time, data.cfg.end_time)
  _OpenUIByType(supplyShowCallBack)
  _CheckData()
end
function LuckyDoubleActivitySystem.IsDataReady()
  if LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId] and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].bigPoolInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].smallPoolInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].priceInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].actInfo and LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId].extInfo then
    return true
  end
  return false
end
function LuckyDoubleActivitySystem.CloseMainUI(isJump)
  if isJump then
    _OnlyCloseUIByType()
  else
    _CloseUIByType()
  end
  _ReopenDecompose()
  _UnblockAchievementPop()
end
function LuckyDoubleActivitySystem.CheckDataInit()
  log(bWriteLog and "[YY]CheckDataInit===" .. tostring(111111))
  _CheckData()
end
function LuckyDoubleActivitySystem.UpdateData()
  _RefreshData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_REFRESH_PAGE)
end
function LuckyDoubleActivitySystem.ShowItemGetPanel(isNeedShowDiscountDraw)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local dropItems = LuckyDoubleActivitySystem.DropItem
  if not dropItems then
    return
  end
  local tExtraGetData = LuckyDoubleActivitySystem.tExtraGetData
  local nAddIPScore = 0
  local bIsExtraGet = false
  local bIsShowExtraGetTip = false
  if tExtraGetData and next(tExtraGetData) then
    nAddIPScore = tExtraGetData.count
    bIsExtraGet = true
    bIsShowExtraGetTip = true
  end
  local tDecomposeList = LuckyDoubleActivitySystem.tDecomposeList
  local bIsExistDecList = tDecomposeList and next(tDecomposeList)
  local cObj_smallRPModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nIPScoreItemId = cObj_smallRPModule:GetIPScoreId()
  local Logic_SmallRPUtils = require("client.slua.logic.specialoffer.SmallRP.Logic_SmallRPUtils")
  local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
  local nCurScore = Logic_ItemUtils.GetItemCount(nIPScoreItemId) or 0
  local nMaxScore = Logic_SmallRPUtils.GetIPLineMaxProgressScore() or 0
  local tExtraData = {}
  if isNeedShowDiscountDraw then
    function tExtraData.fCloseCallback()
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYDOBULE_SHOW_DISCOUNT)
    end
  end
  if nMaxScore > nCurScore - nAddIPScore and bIsExtraGet then
    tExtraGetData.nItemGetGroupId = 2
    tExtraGetData.bDisableGoodItem = false
    tExtraGetData.bCheckSpecialItem = false
    table.insert(dropItems, tExtraGetData)
    tExtraData.tAllGroupTitle = {
      [1] = LocUtil.GetLocalizeResStr(76906),
      [2] = LocUtil.GetLocalizeResStr(76907)
    }
    Logic_CommonItemGet.ShowPanel_RewardGroupShow(dropItems, tDecomposeList, tExtraData)
    bIsShowExtraGetTip = false
  elseif bIsExistDecList then
    tExtraGetData.bDisableGoodItem = false
    tExtraGetData.bCheckSpecialItem = false
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(dropItems, tDecomposeList, tExtraData)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(dropItems, false, false, tExtraData)
  end
  if bIsShowExtraGetTip then
    ShowNotice(76904)
  end
  if bIsExistDecList then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    for k, v in pairs(tDecomposeList) do
      if dropItems[k] then
        local uObj_OriItemCfg = CDataTable.GetTableData("Item", dropItems[k].resid)
        local sOriItemName = uObj_OriItemCfg and uObj_OriItemCfg.ItemName or ""
        local uObj_toItemCfg = CDataTable.GetTableData("Item", v.resid)
        local sToItemName = uObj_toItemCfg and uObj_toItemCfg.ItemName or ""
        local nToCount = v.count or 1
        if sOriItemName ~= "" and sToItemName ~= "" then
          local content = LocUtil.LocalizeResFormat(6345, sOriItemName, nToCount, sToItemName)
          ShowNotice(content)
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_COMMON_SCORE_PRO_BAR, EVENTID_COMMON_SCORE_PRO_BAR_CHECK_SHOW)
  LuckyDoubleActivitySystem.tDecomposeList = nil
  LuckyDoubleActivitySystem.tExtraGetData = nil
  LuckyDoubleActivitySystem.DropItem = nil
  LuckyDoubleActivitySystem.DropUcReturn = 0
end
function LuckyDoubleActivitySystem.SwitchPool()
  if LuckyDoubleActivitySystem.CurAwardPoolIndex == 1 then
    _SwitchPoolTo(2)
  elseif LuckyDoubleActivitySystem.CurAwardPoolIndex == 2 then
    _SwitchPoolTo(1)
  end
end
function LuckyDoubleActivitySystem.GetActDataByActId(nActId)
  return LuckyDoubleActivitySystem.Data[nActId]
end
function LuckyDoubleActivitySystem.GetActivityId()
  return LuckyDoubleActivitySystem.ActivityId
end
function LuckyDoubleActivitySystem.GetCurActEggItem()
  local nActId = LuckyDoubleActivitySystem.ActivityId
  return LuckyDoubleActivitySystem.EggItem_List[nActId]
end
function LuckyDoubleActivitySystem.SetCurActEggItem(nEggItem)
  local nActId = LuckyDoubleActivitySystem.ActivityId
  LuckyDoubleActivitySystem.EggItem_List[nActId] = nEggItem
end
function LuckyDoubleActivitySystem.GetCurBigPoolAwardConfig()
  return LuckyDoubleActivitySystem.CurBigAwardPoolConfig
end
function LuckyDoubleActivitySystem.GetCurSmallPoolAwardConfig()
  return LuckyDoubleActivitySystem.CurSmallAwardPoolConfig
end
function LuckyDoubleActivitySystem.GetCurPoolDrawPriceList()
  local res = {}
  local priceCfg = _GetCurPoolCurRoundAllPriceConfig()
  if not priceCfg or type(priceCfg) ~= "table" then
    return res
  end
  for k, v in pairs(priceCfg) do
    if v.price_value then
      table.insert(res, v.price_value)
    end
  end
  return res
end
function LuckyDoubleActivitySystem.GetRestDrawTotalCost()
  local res = 0
  local priceList = _GetCurPoolCurRoundAllPriceConfig()
  local dt = LuckyDoubleActivitySystem.CurRoundDrawTimes
  if not priceList or type(priceList) ~= "table" then
    return res
  end
  for i = dt, #priceList do
    res = res + priceList[i].price_value
  end
  local discountVal = LuckyDoubleActivitySystem.GetDiscountValByRound()
  return math.floor(res * discountVal), res
end
function LuckyDoubleActivitySystem.GetTicketItemName()
  local cfg = CDataTable.GetTableData("Item", LuckyDoubleActivitySystem.TicketId)
  if cfg then
    return cfg.ItemName
  end
  return ""
end
function LuckyDoubleActivitySystem.UpdateEasterEgg()
  local e = LuckyDoubleActivitySystem.ENUM_EASTER_EGG_STATE
  if not LuckyDoubleActivitySystem.EasterEggId or LuckyDoubleActivitySystem.EasterEggId <= 0 then
    LuckyDoubleActivitySystem.playerData.EasterEggState = e.UNAVAILABLE
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local TableUtil = require("common.table_util")
  local EasterEggData = TableUtil.GetTableValue(activityDataTable, LuckyDoubleActivitySystem.EasterEggId, "data", "award", 1)
  if not EasterEggData then
    LuckyDoubleActivitySystem.playerData.EasterEggState = e.UNAVAILABLE
    return
  end
  LuckyDoubleActivitySystem.playerData.EasterEggState = EasterEggData.status
end
function LuckyDoubleActivitySystem.GetBpResourcePath(actId, callback)
  if test_BPCfg then
    log_error(bWriteLog and "[cw][test][LuckyDoubleActivitySystem] using test_BPCfg filed(" .. tostring(test_BPCfg) .. "), please don't forget to uncomment it after test")
    return test_BPCfg
  end
  actId = actId or LuckyDoubleActivitySystem.ActivityId
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local activityBpPath = PufferManager.GetResourcePathByModuleIDAndActivityID(BP_ENUM_MODULE_LUCKY_DOUBLE, actId)
  if LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId, LuckyDoubleActivitySystem.DownLoadComplete)
    if not activityBpPath or state ~= PufferConst.ENUM_DownloadState.Done then
      activityBpPath = "/Game/Arts_UI/FromUMG/LotteryTemplate/LuckyDoubleTemplate/LuckyDouble_RightLeft_Template/CommonDoubleLucky/CommonDoubleLucky_Image_BG_01.CommonDoubleLucky_Image_BG_01"
    end
  end
  return activityBpPath
end
function LuckyDoubleActivitySystem.DownLoadComplete()
  log(bWriteLog and "[SY]UI_LuckyDoubleTemplate_Supply:ChangeMainBgSkin.DownLoadComplete")
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYDOBULE_BGRESOURCE_DOWNLOAD_COMPLETE)
end
function LuckyDoubleActivitySystem.GetVersionKeyFromPath()
  local path = LuckyDoubleActivitySystem.GetBpResourcePath()
  if not path then
    return
  end
  local _, endAt = string.find(path, "LuckyDouble/")
  if not endAt then
    return
  end
  local version = string.sub(path, endAt + 1, endAt + 4)
  log(bWriteLog and "[YY]version===" .. tostring(version))
  version = tonumber(version)
  return version
end
function LuckyDoubleActivitySystem.SetBPResourcePath_GM(BpPath)
  test_BPCfg = BpPath
end
function LuckyDoubleActivitySystem.GetAudioCfg()
  local cfg = CDataTable.GetTableData("DoubleUnBackDrawAudioStyleCfg", LuckyDoubleActivitySystem.ResourceType)
  if cfg then
    return cfg
  end
  return nil
end
function LuckyDoubleActivitySystem.GetCurPoolDrawRound()
  return #_GetCurBigPoolConfig()
end
function LuckyDoubleActivitySystem.GetBigPoolNum()
  return #_GetBigPoolInfo()
end
function LuckyDoubleActivitySystem.JudgeIsEnoughUC(cost, voucher_id)
  local userUc = DataMgr.ticket or 0
  local voucherNum = 0
  if voucher_id then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    voucherNum = CouponSystem.GetCouponInfoByItemId(voucher_id).value or 0
  end
  local finalNum = userUc + voucherNum - cost
  return 0 <= finalNum, cost - voucherNum
end
function LuckyDoubleActivitySystem.CheckUCRestrict(cost, voucher_id)
  local userUc = DataMgr.ticket or 0
  local voucherNum = 0
  if voucher_id then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    voucherNum = CouponSystem.GetCouponInfoByItemId(voucher_id).value or 0
  end
  local result = false
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if cost > voucherNum and QRcodeRestrictManager:IsRestrictUC() then
    QRcodeRestrictManager:ShowRestrictTips()
    result = true
  end
  log(bWriteLog and "LuckyDoubleActivitySystem.CheckUCRestrict = " .. tostring(result))
  return result
end
function LuckyDoubleActivitySystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login then
    LuckyDoubleActivitySystem.Data = {}
    LuckyDoubleActivitySystem.ActivityId = 0
  end
end
function LuckyDoubleActivitySystem.IsCurDiscountNeedDraw(activityId, poolIndex, round)
  activityId = activityId or LuckyDoubleActivitySystem.ActivityId
  if activityId ~= LuckyDoubleActivitySystem.ActivityId then
    return false
  end
  if LuckyDoubleActivitySystem.IsFinishedCurPool then
    return false
  end
  local discountData = LuckyDoubleActivitySystem.GetDiscountDataByRound(activityId, poolIndex, round)
  if not discountData then
    return false
  end
  return discountData.isHitDiscount and not discountData.isDraw
end
function LuckyDoubleActivitySystem.GetDiscountData(ActivityId)
  ActivityId = ActivityId or LuckyDoubleActivitySystem.ActivityId
  local data = LuckyDoubleActivitySystem.Data[LuckyDoubleActivitySystem.ActivityId]
  if data and data.discountCfg then
    return data.discountCfg
  end
  return nil
end
function LuckyDoubleActivitySystem.GetDiscountDataByRound(ActivityId, poolIndex, round)
  ActivityId = ActivityId or LuckyDoubleActivitySystem.ActivityId
  local data = LuckyDoubleActivitySystem.GetDiscountData(ActivityId)
  if not data then
    return nil
  end
  poolIndex = poolIndex or LuckyDoubleActivitySystem.CurAwardPoolIndex
  round = round or LuckyDoubleActivitySystem.CurRoundIndex
  return data[poolIndex][round]
end
function LuckyDoubleActivitySystem.GetDiscountValByRound(poolIndex, round)
  local data = LuckyDoubleActivitySystem.GetDiscountDataByRound(LuckyDoubleActivitySystem.ActivityId, poolIndex, round)
  if not data or not data.discountValue then
    return 1
  end
  return data.discountValue.discountType
end
function LuckyDoubleActivitySystem.SetDiscountRedPoint(ActivityId)
  log(bWriteLog and "[SY]LuckyDoubleActivitySystem.SetDiscountRedPoint.")
  ActivityId = ActivityId or LuckyDoubleActivitySystem.ActivityId
  local table_util = require("common.table_util")
  local actInfo = table_util.GetTableValue(LuckyDoubleActivitySystem.Data, ActivityId, "actInfo")
  if not actInfo then
    return
  end
  local discountData = LuckyDoubleActivitySystem.GetDiscountData(ActivityId)
  local isHaveDiscount = false
  if discountData then
    for poolIndex, roundList in ipairs(discountData) do
      if actInfo[poolIndex] then
        local roundIndex = actInfo[poolIndex].cur_rounds
        local data = roundList[roundIndex]
        if data and data.isHitDiscount and not data.isDraw then
          isHaveDiscount = true
          break
        end
      end
    end
  end
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  if isHaveDiscount and not LuckyDoubleActivitySystem.IsFinishedCurPool then
    store_reddot_manager:SetActAvailableRedDot(ActivityId, LuckyDoubleActivitySystem.ModuleID, true)
  else
    store_reddot_manager:CloseActAvailableRedDot(ActivityId, LuckyDoubleActivitySystem.ModuleID, true)
  end
end
function LuckyDoubleActivitySystem.send_get_lucky_double_activity_req(activity_id)
  local LuckyDoubleHandler = require("client.network.Protocol.LuckyDoubleHandler")
  LuckyDoubleHandler.send_get_double_draw_activity_req(activity_id)
end
function LuckyDoubleActivitySystem.on_get_lucky_double_activity_rsp(err_code, main_pool_info, little_pool_info, price_info, activity_info, ext_info)
  if err_code == LuckyDoubleActivitySystem.ENUM_LUCKY_DOUBLE_ERR_CODE.SUCCESS then
    _SetConfig(main_pool_info, little_pool_info, price_info, activity_info, ext_info)
  else
    ShowNotice(err_code)
  end
end
function LuckyDoubleActivitySystem.send_do_one_lucky_double_draw_by_activity_req(pool_id, activity_id, voucher_id, cost)
  local isEnough, price = LuckyDoubleActivitySystem.JudgeIsEnoughUC(cost, voucher_id)
  local isRestrict = LuckyDoubleActivitySystem.CheckUCRestrict(cost, voucher_id)
  if isRestrict then
    return
  end
  if isEnough then
    local LuckyDoubleHandler = require("client.network.Protocol.LuckyDoubleHandler")
    LuckyDoubleHandler.send_double_draw_activity_req(pool_id, activity_id, voucher_id, cost)
  else
    _ShowUCNotEnough(price)
  end
end
function LuckyDoubleActivitySystem.on_do_one_lucky_double_draw_by_activity_rsp(err_code, flag, activity_info, reward_info, addition_awards, decompose_list)
  if err_code == LuckyDoubleActivitySystem.ENUM_LUCKY_DOUBLE_ERR_CODE.SUCCESS then
    log_tree("[hhy] reward_info:", reward_info)
    local awardConfig
    local pos = 0
    local tlog_commercial_cost = require("client.slua.config.tlog.tlog_commercial_cost")
    tlog_commercial_cost.ReportCost(tlog_commercial_cost.Enum_Scene.LuckyDouble, LuckyDoubleActivitySystem.ActivityId, LuckyDoubleActivitySystem.CurAwardPoolIndex, LuckyDoubleActivitySystem.CurRoundIndex, LuckyDoubleActivitySystem.CurRoundDrawTimes)
    for k, v in pairs(reward_info) do
      if awardConfig then
        break
      end
      pos = k
      awardConfig = {
        expire_ts = v.valid_hours,
        count = v.item_num,
        resid = v.item_id,
        rankTitleType = v.rankTitleType,
        chief_event_share_count_bak = v.chief_event_share_count_bak,
        king_event_share_count_bak = v.king_event_share_count_bak
      }
    end
    LuckyDoubleActivitySystem.DropItem = {
      [1] = awardConfig
    }
    LuckyDoubleActivitySystem.tExtraGetData = addition_awards
    LuckyDoubleActivitySystem.tDecomposeList = {
      [1] = decompose_list and decompose_list[pos]
    }
    _UpdateCurActInfo(activity_info)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_GET_DRAW_RSP, flag, pos)
  else
    ShowNotice(err_code)
    if err_code == LuckyDoubleActivitySystem.ENUM_LUCKY_DOUBLE_ERR_CODE.double_round_draw_uc_not_enough_err then
      _ShowUCNotEnough()
    end
  end
end
function LuckyDoubleActivitySystem.send_double_draw_on_shot_req(nPoolId, nActivityId, nCost, couponId)
  local pool_id = nPoolId or LuckyDoubleActivitySystem.CurAwardPoolIndex
  local activity_id = nActivityId or LuckyDoubleActivitySystem.ActivityId
  local cost = nCost or LuckyDoubleActivitySystem.GetRestDrawTotalCost()
  local isEnough, price = LuckyDoubleActivitySystem.JudgeIsEnoughUC(cost, couponId)
  local isRestrict = LuckyDoubleActivitySystem.CheckUCRestrict(cost, couponId)
  if isRestrict then
    return
  end
  if isEnough then
    local LuckyDoubleHandler = require("client.network.Protocol.LuckyDoubleHandler")
    LuckyDoubleHandler.send_double_draw_on_shot_req(pool_id, activity_id, cost, couponId)
  else
    _ShowUCNotEnough(price)
  end
end
function LuckyDoubleActivitySystem.on_double_draw_on_shot_rsp(err_code, activity_info, main_reward_info, little_reward_info, return_cost, addition_awards, main_decompose_list, little_decompose_list)
  if err_code == LuckyDoubleActivitySystem.ENUM_LUCKY_DOUBLE_ERR_CODE.SUCCESS then
    log_tree("[hhy] main_reward_info:", main_reward_info)
    log_tree("[hhy] little_reward_info:", little_reward_info)
    local DropItem = {}
    local tDecomposeList = {}
    local bigPoolPosInfo
    local nIndex = 1
    for k, v in pairs(main_reward_info) do
      local tmp = {
        pos = k,
        expire_ts = v.valid_hours,
        count = v.item_num,
        res_id = v.item_id,
        rankTitleType = v.rankTitleType,
        chief_event_share_count_bak = v.chief_event_share_count_bak,
        king_event_share_count_bak = v.king_event_share_count_bak
      }
      bigPoolPosInfo = k
      table.insert(DropItem, tmp)
      if main_decompose_list and main_decompose_list[k] then
        tDecomposeList[nIndex] = main_decompose_list[k]
      end
      nIndex = nIndex + 1
    end
    local littlePoolPosInfo = {}
    for k, v in pairs(little_reward_info) do
      local tmp = {
        pos = k,
        expire_ts = v.valid_hours,
        count = v.item_num,
        resid = v.item_id,
        rankTitleType = v.rankTitleType,
        chief_event_share_count_bak = v.chief_event_share_count_bak,
        king_event_share_count_bak = v.king_event_share_count_bak
      }
      table.insert(littlePoolPosInfo, k)
      table.insert(DropItem, tmp)
      if little_decompose_list and little_decompose_list[k] then
        tDecomposeList[nIndex] = little_decompose_list[k]
      end
      nIndex = nIndex + 1
    end
    if tDecomposeList and next(tDecomposeList) then
      LuckyDoubleActivitySystem.    end
    local tlog_commercial_cost = require("client.slua.config.tlog.tlog_commercial_cost")
    tlog_commercial_cost.ReportCost(tlog_commercial_cost.Enum_Scene.LuckyDouble, LuckyDoubleActivitySystem.ActivityId, LuckyDoubleActivitySystem.CurAwardPoolIndex, LuckyDoubleActivitySystem.CurRoundIndex, "DrawAll" .. tostring(LuckyDoubleActivitySystem.CurRoundDrawTimes) .. "to" .. tostring(LuckyDoubleActivitySystem.CurRoundDrawTimes + #DropItem - 1))
    _UpdateCurActInfo(activity_info)
    LuckyDoubleActivitySystem.DropUcReturn = return_cost or 0
    LuckyDoubleActivitySystem.    LuckyDoubleActivitySystem.tExtraGetData = addition_awards
    LuckyDoubleActivitySystem.SetDiscountRedPoint(LuckyDoubleActivitySystem.ActivityId)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_GET_DRAW_RSP, bigPoolPosInfo, littlePoolPosInfo)
  else
    ShowNotice(err_code)
    if err_code == LuckyDoubleActivitySystem.ENUM_LUCKY_DOUBLE_ERR_CODE.double_round_draw_uc_not_enough_err then
      _ShowUCNotEnough()
    end
  end
end
function LuckyDoubleActivitySystem.send_double_draw_discount_by_activity_req(activity_id, pool_id)
  activity_id = activity_id or LuckyDoubleActivitySystem.ActivityId
  pool_id = pool_id or LuckyDoubleActivitySystem.CurAwardPoolIndex
  local discountData = LuckyDoubleActivitySystem.GetDiscountDataByRound(activity_id, pool_id)
  if not discountData then
    log(bWriteLog and "[SY]LuckyDoubleActivitySystem.send_double_draw_discount_by_activity_req.cur round do not have discountData")
    return
  end
  if not discountData.isHitDiscount or discountData.isDraw then
    return
  end
  local LuckyDoubleHandler = require("client.network.Protocol.LuckyDoubleHandler")
  LuckyDoubleHandler.send_double_draw_discount_by_activity_req(activity_id, pool_id)
end
function LuckyDoubleActivitySystem.on_double_draw_discount_by_activity_rsp(activity_id, pool_id, round_id)
  local discountData = LuckyDoubleActivitySystem.GetDiscountDataByRound(activity_id, pool_id, round_id)
  if not discountData then
    log(bWriteLog and "[SY]LuckyDoubleActivitySystem.on_double_draw_discount_by_activity_rsp.cur round do not have discountData")
    return
  end
  discountData.isDraw = true
  LuckyDoubleActivitySystem.SetDiscountRedPoint(activity_id)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYDOUBLE_DRAWDISCOUNT_COMPLETE)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_REFRESH_PAGE)
end
function LuckyDoubleActivitySystem.send_take_activity_easterEgg_award_req(successFunc)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_activity_award_req(LuckyDoubleActivitySystem.ActivityId, 1, 1)
  LuckyDoubleActivitySystem.EasterEggSuccessFuc = successFunc or nil
end
function LuckyDoubleActivitySystem.on_draw_lucky_surprising_item_ntf(item_list, activityID)
  if activityID ~= LuckyDoubleActivitySystem.ActivityId then
    return
  end
  LuckyDoubleActivitySystem.EggItem_List[activityID] = item_list
end
function LuckyDoubleActivitySystem.on_take_activity_award_res(item_list)
  if LuckyDoubleActivitySystem.EasterEggSuccessFuc then
    LuckyDoubleActivitySystem.EasterEggSuccessFuc(item_list)
  end
  LuckyDoubleActivitySystem.UpdateEasterEgg()
end
function LuckyDoubleActivitySystem.GetCouponListWithActivityIdAndCurRound()
  if LuckyDoubleActivitySystem.ActivityId > 0 then
    local curPriceCfg = _GetCurPriceConfig()
    return curPriceCfg and curPriceCfg.voucher_list or nil
  end
  return
end
function LuckyDoubleActivitySystem.GetDrawBackFlag()
  local tExtraData = _GetExtInfo()
  if tExtraData and tExtraData.double_draw_unback_flag then
    return tExtraData.double_draw_unback_flag
  end
  return 0
end
function LuckyDoubleActivitySystem.CheckIsSmallRPRelated()
  local nActFlagType = LuckyDoubleActivitySystem.GetDrawBackFlag()
  local nCurActId = LuckyDoubleActivitySystem.ActivityId
  local luck_util = require("client.slua.logic.lobby_activity.luck_util")
  local bIsSmallRPRelated = luck_util.CheckLuckyBackActIsSmallRPRelated(nActFlagType, nCurActId)
  return bIsSmallRPRelated
end
return LuckyDoubleActivitySystem