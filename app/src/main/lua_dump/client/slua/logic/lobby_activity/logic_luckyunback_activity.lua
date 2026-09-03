local test_backupOne, test_BPPath, test_BPCfg
local LuckyUnbackActivitySystem = {
  ActivityId = 0,
  ModuleId = 0,
  TimePeriodStr = "",
  ResourceType = 0,
  DropItem = nil,
  CurAwardPoolIndex = 1,
  ReturnJumpUrl = "",
  ImageLink = "",
  IsShowBubble = false,
  HasAmsGift = false,
  AmsList = {},
  bIsReq = false,
  EasterEggId = -1,
  EasterEggStatus = 0,
  EasterEggSuccessFuc = nil,
  BannerRedPoint = true,
  ActivityRedPoint = false,
  AwardPoolConfig = {},
  AwardPoolNameConfig = {},
  AwardPoolCount = 0,
  PriceConfig = {},
  DrawLogConfig = {},
  ResourceConfig = {},
  DiscountConfig = {},
  EggItem_List = {},
  CONST = {
    BaseConfigKey_TraitClassDynamicForm = "UnbackTraitClassDynamicMainForm"
  },
  ENUM_LUCKYUNBACK_ERR_CODE = {
    success = 0,
    activity_errcode_activity_have_end = 108108,
    activity_errcode_param_error = 108109,
    activity_errcode_activity_not_exist = 108101,
    luckyunback_err_need_res_not_enough = 6494,
    luckyunback_err_pay_error = 995002,
    luckyunback_err_voucher_not_exist = 995003,
    luckyunback_err_can_not_next_round = 995004
  },
  ENUM_POOL_INDEX = {Main_Pool = 1, Sub_Pool = 2},
  OldVouchers = {
    [1608021] = 30,
    [1608022] = 40,
    [1608023] = 50
  }
}
function LuckyUnbackActivitySystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    LuckyUnbackActivitySystem.AwardPoolConfig = {}
    LuckyUnbackActivitySystem.PriceConfig = {}
    LuckyUnbackActivitySystem.DrawLogConfig = {}
    LuckyUnbackActivitySystem.AwardPoolNameConfig = {}
    LuckyUnbackActivitySystem.ResourceConfig = {}
  end
end
local _380TempChangeBPPath = function(BPPath)
  return BPPath
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
      originalPrice = serverData.original_price,
      discountPrice = serverData.discount_price,
      isMinDiscount = serverData.is_min_discount,
      isHitSpecialDicCount = serverData.is_hit_special_discount
    }
  end
  return data
end
local _SetDiscountInfo = function(cfg)
  LuckyUnbackActivitySystem.DiscountConfig = {}
  for pool, v in pairs(cfg) do
    LuckyUnbackActivitySystem.DiscountConfig[pool] = {}
    for drawTimes, serverData in ipairs(v) do
      LuckyUnbackActivitySystem.DiscountConfig[pool][drawTimes] = _CreateDiscountData(serverData)
    end
  end
  LuckyUnbackActivitySystem.SetDiscountRedPoint()
end
local _SetConfig = function(lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, my_activity_data, lucky_draw_unback_global_cfg, lucky_draw_unback_bp_cfg, lucky_draw_unback_discount_cfg)
  if lucky_draw_unback_cfg then
    log_tree("[cw] lucky_draw_unback_cfg ", lucky_draw_unback_cfg)
    LuckyUnbackActivitySystem.AwardPoolConfig = lucky_draw_unback_cfg
    LuckyUnbackActivitySystem.AwardPoolCount = #lucky_draw_unback_cfg
  end
  if lucky_draw_unback_price_cfg then
    LuckyUnbackActivitySystem.PriceConfig = lucky_draw_unback_price_cfg
  end
  if my_activity_data then
    LuckyUnbackActivitySystem.DrawLogConfig = my_activity_data
    if my_activity_data.lucky_draw_unback_discount_info then
      log_tree("[SY] lucky_draw_unback_discount_cfg:", my_activity_data.lucky_draw_unback_discount_info)
      _SetDiscountInfo(my_activity_data.lucky_draw_unback_discount_info)
    else
      LuckyUnbackActivitySystem.DiscountConfig = nil
    end
  end
  if lucky_draw_unback_global_cfg then
    LuckyUnbackActivitySystem.AwardPoolNameConfig = lucky_draw_unback_global_cfg
  end
  if lucky_draw_unback_bp_cfg then
    LuckyUnbackActivitySystem.ResourceConfig = {}
    LuckyUnbackActivitySystem.ResourceConfig.bg_path = _380TempChangeBPPath(lucky_draw_unback_bp_cfg.bg_path) or nil
    LuckyUnbackActivitySystem.ResourceConfig.pool_path = {}
    if lucky_draw_unback_bp_cfg.pool_path then
      LuckyUnbackActivitySystem.ResourceConfig.pool_path[1] = _380TempChangeBPPath(lucky_draw_unback_bp_cfg.pool_path)
      LuckyUnbackActivitySystem.ResourceConfig.pool_path[2] = _380TempChangeBPPath(lucky_draw_unback_bp_cfg.pool_path)
    end
    if lucky_draw_unback_bp_cfg.pool2_path then
      LuckyUnbackActivitySystem.ResourceConfig.pool_path[2] = _380TempChangeBPPath(lucky_draw_unback_bp_cfg.pool2_path)
    end
    LuckyUnbackActivitySystem.ResourceConfig.egg_path = _380TempChangeBPPath(lucky_draw_unback_bp_cfg.egg_path) or nil
  end
  if test_BPPath then
    LuckyUnbackActivitySystem.ResourceConfig.bg_path = test_BPPath.bg_path
    LuckyUnbackActivitySystem.ResourceConfig.pool_path[1] = test_BPPath.pool_path_1
    LuckyUnbackActivitySystem.ResourceConfig.pool_path[2] = test_BPPath.pool_path_2
    LuckyUnbackActivitySystem.ResourceConfig.egg_path = test_BPPath.egg_path
    log_error(bWriteLog and "[cw][test] using test_BPPath filed, please don't forget to uncomment it after test")
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKUNYBACK_STATUS_REFRESH)
end
function LuckyUnbackActivitySystem.SetDiscountRedPoint()
  log(bWriteLog and "[SY]LuckyUnbackActivitySystem.SetDiscountRedPoint.")
  local isHaveDiscount = false
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  if LuckyUnbackActivitySystem.DiscountConfig then
    local data = LuckyUnbackActivitySystem.GetCurDiscountData()
    if data then
      isHaveDiscount = data.isHitDiscount and not data.isDraw
    end
  end
  if isHaveDiscount and not LuckyUnbackActivitySystem.HaveFinishedDraw(LuckyUnbackActivitySystem.CurAwardPoolIndex) then
    store_reddot_manager:SetActAvailableRedDot(LuckyUnbackActivitySystem.ActivityId, LuckyUnbackActivitySystem.ModuleId, true)
  else
    store_reddot_manager:CloseActAvailableRedDot(LuckyUnbackActivitySystem.ActivityId, LuckyUnbackActivitySystem.ModuleId, true)
  end
end
function LuckyUnbackActivitySystem.IsHaveDiscount()
  if next(LuckyUnbackActivitySystem.DiscountConfig) then
    return true
  end
  return false
end
local _GetBaseConfigByResourceType = function(nBackupOne)
  local baseConfigKey
  local UnbackXlsUtil = require("client.slua.logic.lobby_activity.UnbackXlsUtil")
  if UnbackXlsUtil.GetMainBgConfigByBackupOne(nBackupOne) then
    baseConfigKey = LuckyUnbackActivitySystem.CONST.BaseConfigKey_TraitClassDynamicForm
    log(bWriteLog and "[cw] find nBackupOne(" .. tostring(nBackupOne) .. ") witch is registed in xls, use dynamic form")
  end
  return baseConfigKey or "UnbackTraitClassDynamicMainForm"
end
local _CheckData = function()
  if LuckyUnbackActivitySystem.AwardPoolConfig and next(LuckyUnbackActivitySystem.AwardPoolConfig) and LuckyUnbackActivitySystem.PriceConfig and next(LuckyUnbackActivitySystem.PriceConfig) and LuckyUnbackActivitySystem.DrawLogConfig and next(LuckyUnbackActivitySystem.DrawLogConfig) and LuckyUnbackActivitySystem.AwardPoolNameConfig and next(LuckyUnbackActivitySystem.AwardPoolNameConfig) and LuckyUnbackActivitySystem.ResourceConfig and next(LuckyUnbackActivitySystem.ResourceConfig) and not LuckyUnbackActivitySystem.bIsReq then
    LuckyUnbackActivitySystem.SetDiscountRedPoint()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKUNYBACK_STATUS_REFRESH)
  else
    LuckyUnbackActivitySystem.send_get_lucky_draw_back_activity_req()
  end
end
function LuckyUnbackActivitySystem.GetBpResourcePath(callback)
  if test_BPCfg then
    log_error(bWriteLog and "[cw][test][LuckyUnbackActivitySystem] using test_BPCfg filed(" .. tostring(test_BPCfg) .. "), please don't forget to uncomment it after test")
    return test_BPCfg
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local activityBpPath = PufferManager.GetResourcePathByModuleIDAndActivityID(BP_ENUM_MODULE_LUCKY_UNBACK, LuckyUnbackActivitySystem.ActivityId)
  if LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, LuckyUnbackActivitySystem.ActivityId, callback)
    if not activityBpPath or state ~= PufferConst.ENUM_DownloadState.Done then
      activityBpPath = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/CommonMainLine/CommonMainLine_Image_BG_1.CommonMainLine_Image_BG_1"
    end
  end
  return activityBpPath
end
function LuckyUnbackActivitySystem.HandlePath(rootPath)
  local tempPath = rootPath
  if tempPath == nil or tempPath == "" then
    return "", ""
  end
  local preString, preActivityName
  local slashIndex = 1
  local nextSlashIndex = string.find(tempPath, "/", slashIndex + 1)
  while nextSlashIndex ~= nil do
    slashIndex = nextSlashIndex
    nextSlashIndex = string.find(tempPath, "/", slashIndex + 1)
  end
  local underLineIndex = string.find(tempPath, "_", slashIndex)
  preString = string.sub(tempPath, 1, slashIndex)
  preActivityName = string.sub(tempPath, slashIndex + 1, underLineIndex)
  return preString, preActivityName
end
function LuckyUnbackActivitySystem.DrawHandlePath(rootPath)
  local tempPath = rootPath
  if tempPath == nil or tempPath == "" then
    return "", ""
  end
  local preString, preActivityName
  local slashIndex = 1
  local nextSlashIndex = string.find(tempPath, "/", slashIndex + 1)
  while nextSlashIndex ~= nil do
    slashIndex = nextSlashIndex
    nextSlashIndex = string.find(tempPath, "/", slashIndex + 1)
  end
  local underLineIndex = string.find(tempPath, ".", slashIndex)
  preString = string.sub(tempPath, 1, slashIndex)
  preActivityName = string.sub(tempPath, slashIndex + 1, underLineIndex)
  return preString, ""
end
function LuckyUnbackActivitySystem.RebuildOriginalPath(preString, preActivityName, ImgName)
  return preString .. preActivityName .. ImgName .. "." .. preActivityName .. ImgName
end
function LuckyUnbackActivitySystem.RebuildImagePath(preString, preActivityName, ImgName)
  return preString .. preActivityName .. ImgName .. "_512" .. "." .. preActivityName .. ImgName .. "_512"
end
function LuckyUnbackActivitySystem.OpenMainUI(eventType, eventID, vars)
  log(bWriteLog and "LuckybackActivitySystem.OpenMainUI")
  LuckyUnbackActivitySystem.ModuleId = tonumber(vars.module)
  LuckyUnbackActivitySystem.OpenUIWithActId(vars.activityid)
end
function LuckyUnbackActivitySystem.OpenUIWithActId(actId, supplyShowCallBack)
  if actId == nil or actId == 0 then
    ShowNotice(120106)
    log(bWriteLog and "LuckyUnbackActivitySystem.OpenUIWithActId id is NULL")
    return
  end
  LuckyUnbackActivitySystem.BannerRedPoint = false
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 1)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(actId)]
  if data == nil then
    ShowNotice(4002)
    return
  end
  if LuckyUnbackActivitySystem.ActivityId ~= tonumber(actId) then
    LuckyUnbackActivitySystem.bIsReq = true
  end
  LuckyUnbackActivitySystem.ActivityId = tonumber(actId)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.ActivityId : " .. LuckyUnbackActivitySystem.ActivityId)
  LuckyUnbackActivitySystem.ResourceType = data.cfg.label_type or 0
  if data.cfg.back_up_one and data.cfg.back_up_one ~= "" then
    local str = tostring(data.cfg.back_up_one)
    LuckyUnbackActivitySystem.ResourceType = tonumber(str)
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    LuckyUnbackActivitySystem.IsShowBubble = false
  else
    LuckyUnbackActivitySystem.IsShowBubble = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 2)
  end
  LuckyUnbackActivitySystem.HasAmsGift = false
  LuckyUnbackActivitySystem.TimePeriodStart = data.cfg.start_time
  LuckyUnbackActivitySystem.TimePeriodEnd = data.cfg.end_time
  LuckyUnbackActivitySystem.TimePeriodStr = LuckyUnbackActivitySystem.GetTimePeriod(data.cfg.start_time, data.cfg.end_time)
  if test_backupOne then
    LuckyUnbackActivitySystem.ResourceType = test_backupOne
    log_error(bWriteLog and "[cw][test] using test_backupOne filed(" .. tostring(test_backupOne) .. "), please don't forget to uncomment it after test")
  end
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.ResourceType: " .. tostring(LuckyUnbackActivitySystem.ResourceType))
  LuckyUnbackActivitySystem.CurAwardPoolIndex = 1
  LuckyUnbackActivitySystem.EasterEggId = ActivityNewSystem.GetSurpriseActivityID(ActivityType.LUCKYUNBACK_SURPRISE, LuckyUnbackActivitySystem.ActivityId)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.EasterEggId: " .. LuckyUnbackActivitySystem.EasterEggId)
  LuckyUnbackActivitySystem.ImageLink = data.cfg.activity_image_link or ""
  LuckyUnbackActivitySystem.ReturnJumpUrl = data.cfg.return_jump_link or ""
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.needDelay = true
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockPopTip()
  LuckyUnbackActivitySystem.OpenUIByType(supplyShowCallBack)
  _CheckData()
end
function LuckyUnbackActivitySystem.GetOrReqUnbackData(actId)
  if not actId or actId == 0 then
    ShowNotice(120106)
    log(bWriteLog and "LuckyUnbackActivitySystem.GetOrReqUnbackData id is NULL")
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(actId)]
  if not data then
    ShowNotice(4002)
    return
  end
  if LuckyUnbackActivitySystem.ActivityId ~= tonumber(actId) then
    LuckyUnbackActivitySystem.bIsReq = true
  end
  LuckyUnbackActivitySystem.ActivityId = tonumber(actId)
  log(bWriteLog and "LuckyUnbackActivitySystem.GetOrReqUnbackData. ActivityId : " .. LuckyUnbackActivitySystem.ActivityId)
  LuckyUnbackActivitySystem.ResourceType = data.cfg.label_type or 0
  if data.cfg.back_up_one and data.cfg.back_up_one ~= "" then
    local str = tostring(data.cfg.back_up_one)
    LuckyUnbackActivitySystem.ResourceType = tonumber(str)
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityIDForSupply(nil, actId)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
  end
  LuckyUnbackActivitySystem.HasAmsGift = false
  LuckyUnbackActivitySystem.TimePeriodStart = data.cfg.start_time
  LuckyUnbackActivitySystem.TimePeriodEnd = data.cfg.end_time
  LuckyUnbackActivitySystem.TimePeriodStr = LuckyUnbackActivitySystem.GetTimePeriod(data.cfg.start_time, data.cfg.end_time)
  LuckyUnbackActivitySystem.CurAwardPoolIndex = 1
  LuckyUnbackActivitySystem.ImageLink = data.cfg.activity_image_link or ""
  LuckyUnbackActivitySystem.ReturnJumpUrl = data.cfg.return_jump_link or ""
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.needDelay = true
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockPopTip()
  _CheckData()
end
function LuckyUnbackActivitySystem.OpenFromOther()
  local JumpUtils = require("client.logic.store.jump_utils")
  if next(BP_LobbyHighestBannerData) ~= nil then
    local globalUrl = BP_LobbyHighestBannerData.JumpUrl
    if JumpUtils.IsGameJumpUrl(globalUrl) then
      local StringUtil = require("common.string_util")
      local params = StringUtil.ParseURLParams(globalUrl)
      local moduleId = tonumber(params.module)
      if moduleId == BP_ENUM_MODULE_LUCKY_UNBACK then
        local jump_utils = require("client.logic.store.jump_utils")
        jump_utils.OpenJumpModule(moduleId, params)
        return
      end
    end
  end
  for k, v in pairs(LobbySystem.activityDisplayDataList) do
    local globalUrl = v.JumpUrl
    if JumpUtils.IsGameJumpUrl(globalUrl) then
      local StringUtil = require("common.string_util")
      local params = StringUtil.ParseURLParams(globalUrl)
      local moduleId = tonumber(params.module)
      if moduleId == BP_ENUM_MODULE_LUCKY_UNBACK then
        local jump_utils = require("client.logic.store.jump_utils")
        jump_utils.OpenJumpModule(moduleId, params)
        return
      end
    end
  end
  ShowNotice(4002)
end
function LuckyUnbackActivitySystem.InitRedPoint()
  local show = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 1)
  LuckyUnbackActivitySystem.BannerRedPoint = show
end
function LuckyUnbackActivitySystem.UpdateRedPoint()
  if LuckyUnbackActivitySystem.ActivityRedPoint ~= LuckyUnbackActivitySystem.BannerRedPoint then
    LuckyUnbackActivitySystem.ActivityRedPoint = LuckyUnbackActivitySystem.BannerRedPoint
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_LUCKY_UNBACK, LuckyUnbackActivitySystem.BannerRedPoint)
  end
end
function LuckyUnbackActivitySystem.IsLuckyUnbackOldVoucher(id)
  for k, v in pairs(LuckyUnbackActivitySystem.OldVouchers) do
    if id == k then
      return true
    end
  end
  return false
end
function LuckyUnbackActivitySystem.IsDrawRoundDiscount(poolId, drawIndex)
  poolId = poolId or LuckyUnbackActivitySystem.CurAwardPoolIndex
  drawIndex = drawIndex or LuckyUnbackActivitySystem.GetCurPoolDrawTime()
  local table_util = require("common.table_util")
  local data = table_util.GetTableValue(LuckyUnbackActivitySystem.DiscountConfig, poolId, drawIndex)
  if not data then
    return true
  end
  return data.isDraw
end
function LuckyUnbackActivitySystem.GetTimePeriod(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatTime_timeFrame(startTime, endTime, false, true)
end
function LuckyUnbackActivitySystem.CloseMainUI(isJump)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.UnblockPopTip()
  if isJump then
    LuckyUnbackActivitySystem.OnlyCloseUIByType()
  else
    LuckyUnbackActivitySystem.CloseUIByType()
  end
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.needDelay = false
end
function LuckyUnbackActivitySystem.OpenUIByType(supplyShowCallBack)
  local resourceConfig = UIManager.UI_Config[_GetBaseConfigByResourceType(LuckyUnbackActivitySystem.ResourceType)]
  if not resourceConfig then
    ShowNotice(6497)
    return
  end
  if supplyShowCallBack then
    supplyShowCallBack(resourceConfig, LuckyUnbackActivitySystem.ResourceType)
  else
    UIManager.ShowUI(resourceConfig, nil, LuckyUnbackActivitySystem.ResourceType)
  end
end
function LuckyUnbackActivitySystem.CloseUIByType()
  UIManager.CloseUI(UIManager.UI_Config[_GetBaseConfigByResourceType(LuckyUnbackActivitySystem.ResourceType)])
end
function LuckyUnbackActivitySystem.OnlyCloseUIByType()
  UIManager.CloseUI(UIManager.UI_Config[_GetBaseConfigByResourceType(LuckyUnbackActivitySystem.ResourceType)])
end
function LuckyUnbackActivitySystem.ShowItemGetPanel(isNeedShowDiscount)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local Extra
  if isNeedShowDiscount then
    Extra = {
      fCloseCallback = function()
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYUNBACK_SHOW_DISCOUNT)
      end
    }
  end
  Logic_CommonItemGet.ShowPanel_DefaultStyle(LuckyUnbackActivitySystem.DropItem, false, false, Extra)
  LuckyUnbackActivitySystem.DropItem = nil
end
function LuckyUnbackActivitySystem.IsShowMoreButtonToParam()
  local ActivityEntrySetSystem = require("client.slua.logic.activity.logic_activity_entry_set")
  local data = ActivityEntrySetSystem.GetData()
  if data and LuckyUnbackActivitySystem.ReturnJumpUrl ~= "" then
    return true
  end
  return false
end
function LuckyUnbackActivitySystem.GetNextDrawCost()
  local poolIndex = LuckyUnbackActivitySystem.CurAwardPoolIndex
  local drawnTime = LuckyUnbackActivitySystem.GetCurPoolDrawTime()
  if LuckyUnbackActivitySystem.PriceConfig[poolIndex] and drawnTime <= #LuckyUnbackActivitySystem.PriceConfig[poolIndex] and LuckyUnbackActivitySystem.PriceConfig[poolIndex][drawnTime + 1] then
    return LuckyUnbackActivitySystem.PriceConfig[poolIndex][drawnTime + 1].price
  end
  return -1
end
function LuckyUnbackActivitySystem.IsCurDiscountNeedDraw(poolIndex, drawIndex)
  if LuckyUnbackActivitySystem.HaveFinishedDraw() then
    return false
  end
  local discountData = LuckyUnbackActivitySystem.GetCurDiscountData(poolIndex, drawIndex)
  if not discountData then
    return false
  end
  return discountData.isHitDiscount and not discountData.isDraw
end
function LuckyUnbackActivitySystem.IsCurActivityHaveDiscountEvent()
  return LuckyUnbackActivitySystem.DiscountConfig and next(LuckyUnbackActivitySystem.DiscountConfig) ~= nil
end
function LuckyUnbackActivitySystem.GetCurDiscountData(poolIndex, drawIndex)
  poolIndex = poolIndex or LuckyUnbackActivitySystem.CurAwardPoolIndex
  drawIndex = drawIndex or LuckyUnbackActivitySystem.GetCurPoolDrawTime() + 1
  local table_util = require("common.table_util")
  return table_util.GetTableValue(LuckyUnbackActivitySystem.DiscountConfig, poolIndex, drawIndex)
end
function LuckyUnbackActivitySystem.GetCurPoolDrawTime()
  if LuckyUnbackActivitySystem.DrawLogConfig and LuckyUnbackActivitySystem.DrawLogConfig[LuckyUnbackActivitySystem.CurAwardPoolIndex] then
    return LuckyUnbackActivitySystem.DrawLogConfig[LuckyUnbackActivitySystem.CurAwardPoolIndex].had_draw_count or 0
  end
  return 0
end
function LuckyUnbackActivitySystem.GetRateArrayFromActivity(remark_content)
  local RateArray = {}
  RateArray[1] = {}
  RateArray[2] = {}
  RateArray[3] = {}
  local StringUtil = require("common.string_util")
  local content = StringUtil.Split(remark_content, "|")
  for i, v in pairs(content) do
    local sub_content = StringUtil.Split(v, ",")
    for index, value in pairs(sub_content) do
      local res = StringUtil.Split(value, "=")
      if tonumber(res[2]) == 0 then
        RateArray[i][tonumber(res[1])] = "0"
      else
        RateArray[i][tonumber(res[1])] = tostring(tonumber(res[2]) / 100) .. "%"
      end
    end
  end
  log_tree("[cw] LuckyUnbackActivitySystem.GetRateArrayFromActivity", RateArray)
  return RateArray
end
function LuckyUnbackActivitySystem.GetItemConfigByPoolIndexAndItemIndex(poolIndex, itemIndex)
  local curPoolConfig = LuckyUnbackActivitySystem.AwardPoolConfig[poolIndex]
  if curPoolConfig then
    local itemId, itemCount, valid_hours
    for _, v in pairs(curPoolConfig) do
      if v.pos_id == itemIndex then
        itemId = v.item_id
        itemCount = v.item_num
        valid_hours = v.valid_hours
        return itemId, itemCount, valid_hours
      end
    end
  end
  return nil
end
function LuckyUnbackActivitySystem.GetPoolSize(poolIndex)
  local index = poolIndex or LuckyUnbackActivitySystem.CurAwardPoolIndex
  return #LuckyUnbackActivitySystem.PriceConfig[index]
end
function LuckyUnbackActivitySystem.GetPoolConfig(poolIndex)
  local index = poolIndex or LuckyUnbackActivitySystem.CurAwardPoolIndex
  return LuckyUnbackActivitySystem.AwardPoolConfig[index]
end
function LuckyUnbackActivitySystem.GetPoolDrawItemLog(poolIndex)
  local index = poolIndex or LuckyUnbackActivitySystem.CurAwardPoolIndex
  if LuckyUnbackActivitySystem.DrawLogConfig[index] and LuckyUnbackActivitySystem.DrawLogConfig[index].new_had_draw_info then
    return LuckyUnbackActivitySystem.DrawLogConfig[index].new_had_draw_info
  end
  return {}
end
function LuckyUnbackActivitySystem.HaveFinishedDraw(poolIndex)
  poolIndex = poolIndex or LuckyUnbackActivitySystem.CurAwardPoolIndex
  local items = LuckyUnbackActivitySystem.AwardPoolConfig[poolIndex]
  local TableUtil = require("common.table_util")
  local gotItems = TableUtil.GetTableValue(LuckyUnbackActivitySystem.DrawLogConfig, poolIndex, "new_had_draw_info")
  if not gotItems then
    return false
  end
  for k, v in pairs(items) do
    if not gotItems[k] then
      return false
    end
  end
  return true
end
function LuckyUnbackActivitySystem.GetAnimationQueue(targetIndex)
  local left = {}
  local items = LuckyUnbackActivitySystem.GetPoolConfig()
  local drawLog = LuckyUnbackActivitySystem.GetPoolDrawItemLog()
  for k, v in pairs(items) do
    if not drawLog[k] then
      table.insert(left, v.pos_id)
    end
  end
  table.insert(left, targetIndex)
  table.sort(left)
  local queue = {}
  local CopyTableToQueue = function(copyFrom, copyTo, copyTimes)
    for i = 1, copyTimes do
      for j = 1, #copyFrom do
        table.insert(copyTo, copyFrom[j])
      end
    end
  end
  local CopyTableToQueueUntilTargetNum = function(copyFrom, copyEnd, copyTo)
    for i = 1, #copyFrom do
      table.insert(copyTo, copyFrom[i])
      if copyFrom[i] == copyEnd then
        break
      end
    end
  end
  if #left == 1 then
    table.insert(queue, targetIndex)
  elseif 4 < #left then
    CopyTableToQueue(left, queue, 1)
    CopyTableToQueueUntilTargetNum(left, targetIndex, queue)
  elseif 2 < #left then
    CopyTableToQueue(left, queue, 2)
    CopyTableToQueueUntilTargetNum(left, targetIndex, queue)
  else
    CopyTableToQueue(left, queue, 3)
    CopyTableToQueueUntilTargetNum(left, targetIndex, queue)
  end
  return queue
end
function LuckyUnbackActivitySystem.ShowTemplateEasterEggPanel()
  local eggBpPath = LuckyUnbackActivitySystem.ResourceConfig.egg_path
  local UnbackXlsUtil = require("client.slua.logic.lobby_activity.UnbackXlsUtil")
  local audioType = UnbackXlsUtil.GetAudioStyleByBackUpOne(LuckyUnbackActivitySystem.ResourceType)
  local activityBpPath = LuckyUnbackActivitySystem.GetBpResourcePath()
  local particleColorStyle = UnbackXlsUtil.GetParticleColorStyleByBackUpOne(LuckyUnbackActivitySystem.ResourceType)
  UIManager.ShowUI(UIManager.UI_Config.UnbackTraitClassDynamicEggForm, eggBpPath, activityBpPath, audioType, particleColorStyle)
end
function LuckyUnbackActivitySystem.GetAwardPoolDataByPoolIndex(nPoolIndex)
  local TableUtil = require("common.table_util")
  local items = LuckyUnbackActivitySystem.AwardPoolConfig[nPoolIndex]
  local gotItems = TableUtil.GetTableValue(LuckyUnbackActivitySystem.DrawLogConfig, nPoolIndex, "new_had_draw_info") or {}
  local data = {}
  for k, itemInfo in pairs(items) do
    data[itemInfo.pos_id] = {
      itemId = itemInfo.item_id,
      item_num = itemInfo.item_num,
      hasGot = gotItems[k] and true or false,
      weight = itemInfo.weight
    }
  end
  return data
end
function LuckyUnbackActivitySystem.GetAwardPoolListByPoolIndex(nPoolIndex)
  local items = LuckyUnbackActivitySystem.AwardPoolConfig[nPoolIndex]
  local data = {}
  for k, itemInfo in pairs(items) do
    data[itemInfo.pos_id] = {
      itemId = itemInfo.item_id,
      item_num = itemInfo.item_num,
      pos_id = itemInfo.pos_id,
      key = k,
      valid_hours = itemInfo.valid_hours,
      weight = itemInfo.weight
    }
  end
  return data
end
function LuckyUnbackActivitySystem.IsGotAwardByPos(nPoolIndex, key)
  local TableUtil = require("common.table_util")
  local gotItems = TableUtil.GetTableValue(LuckyUnbackActivitySystem.DrawLogConfig, nPoolIndex, "new_had_draw_info") or {}
  return gotItems[key] and true or false
end
function LuckyUnbackActivitySystem.CheckEasterEgg()
  if LuckyUnbackActivitySystem.EasterEggId <= 0 then
    LuckyUnbackActivitySystem.EasterEggStatus = 0
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYUNBACK_EGG_STATUS_CHANGE, LuckyUnbackActivitySystem.EasterEggStatus == 1)
    return
  end
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.EasterEggId: " .. LuckyUnbackActivitySystem.EasterEggId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  if not (activityDataTable and LuckyUnbackActivitySystem.EasterEggId and activityDataTable[LuckyUnbackActivitySystem.EasterEggId]) or LuckyUnbackActivitySystem.EasterEggId < 0 then
    return
  end
  local EasterEggData = activityDataTable[LuckyUnbackActivitySystem.EasterEggId].data
  if EasterEggData and EasterEggData.award[1] then
    LuckyUnbackActivitySystem.EasterEggStatus = EasterEggData.award[1].status
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYUNBACK_EGG_STATUS_CHANGE, LuckyUnbackActivitySystem.EasterEggStatus == 1)
  end
end
function LuckyUnbackActivitySystem.IsHaveAmsGift()
  if LuckyUnbackActivitySystem.AmsList and #LuckyUnbackActivitySystem.AmsList > 0 then
    LuckyUnbackActivitySystem.HasAmsGift = true
  else
    LuckyUnbackActivitySystem.HasAmsGift = false
  end
  return LuckyUnbackActivitySystem.HasAmsGift
end
function LuckyUnbackActivitySystem.send_get_lucky_draw_back_activity_req()
  log(bWriteLog and "[SY]LuckyUnbackActivitySystem.send_get_lucky_draw_back_activity_req.")
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_lucky_draw_unback_activity_req(LuckyUnbackActivitySystem.ActivityId)
end
function LuckyUnbackActivitySystem.get_lucky_draw_unback_activity_rsp(res, lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, my_activity_data, lucky_draw_unback_global_cfg, lucky_draw_unback_resource_cfg, lucky_draw_unback_bp_cfg, lucky_draw_unback_discount_cfg)
  if res == LuckyUnbackActivitySystem.ENUM_LUCKYUNBACK_ERR_CODE.success then
    if LuckyUnbackActivitySystem.ActivityId and LuckyUnbackActivitySystem.ActivityId ~= my_activity_data.activity_id then
      LuckyUnbackActivitySystem.OnlyCloseUIByType()
      return
    end
    log_tree("[cw] lucky_draw_unback_resource_cfg:", lucky_draw_unback_resource_cfg)
    _SetConfig(lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, my_activity_data, lucky_draw_unback_global_cfg, lucky_draw_unback_bp_cfg, lucky_draw_unback_discount_cfg)
    LuckyUnbackActivitySystem.bIsReq = false
  end
end
function LuckyUnbackActivitySystem.do_one_draw_by_activity_rsp(res, my_activity_data, award_info, award_List)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.do_one_draw_by_activity_rsp(" .. tostring(res) .. ", " .. tostring(my_activity_data) .. ", " .. tostring(award_info) .. ")")
  log_tree("[cw] my_activity_data:", my_activity_data)
  log_tree("[hhy] award_info:", award_info)
  if res ~= LuckyUnbackActivitySystem.ENUM_LUCKYUNBACK_ERR_CODE.success then
    ShowNotice(res)
    if res == LuckyUnbackActivitySystem.ENUM_LUCKYUNBACK_ERR_CODE.luckyunback_err_need_res_not_enough then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
    end
  else
    local tlog_commercial_cost = require("client.slua.config.tlog.tlog_commercial_cost")
    tlog_commercial_cost.ReportCost(tlog_commercial_cost.Enum_Scene.LuckyUnback, LuckyUnbackActivitySystem.ActivityId, LuckyUnbackActivitySystem.CurAwardPoolIndex, LuckyUnbackActivitySystem.GetCurPoolDrawTime() + 1)
    LuckyUnbackActivitySystem.DrawLogConfig = my_activity_data
    if my_activity_data and my_activity_data.lucky_draw_unback_discount_info and LuckyUnbackActivitySystem.DiscountConfig then
      local cfg = my_activity_data.lucky_draw_unback_discount_info
      _SetDiscountInfo(cfg)
    end
    LuckyUnbackActivitySystem.DropItem = {}
    for i, v in pairs(award_List) do
      local item = {}
      item.res_id = v.resid
      item.count = v.count
      item.pos_id = v.pos_id
      item.rankTitleType = v.rankTitleType
      item.chief_event_share_count_bak = v.chief_event_share_count_bak
      item.king_event_share_count_bak = v.king_event_share_count_bak
      item.valid_hours = v.valid_hours
      table.insert(LuckyUnbackActivitySystem.DropItem, item)
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYUNBACK_DARW_ANIMATION, LuckyUnbackActivitySystem.DropItem[1].pos_id)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKUNYBACK_STATUS_CHANGE)
  end
end
function LuckyUnbackActivitySystem.send_take_activity_award_req(successFunc)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_activity_award_req(LuckyUnbackActivitySystem.ActivityId, 1, 1)
  LuckyUnbackActivitySystem.EasterEggSuccessFuc = successFunc or nil
end
function LuckyUnbackActivitySystem.on_take_activity_award_res(item_list, activity_id)
  if LuckyUnbackActivitySystem.EasterEggSuccessFuc and activity_id == LuckyUnbackActivitySystem.ActivityId then
    LuckyUnbackActivitySystem.EasterEggSuccessFuc(item_list)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKUNYBACK_STATUS_CHANGE)
  end
  LuckyUnbackActivitySystem.EggItem_List[activity_id] = item_list
end
function LuckyUnbackActivitySystem.on_notify_ams_lucky_draw_unback_info(award_index)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.on_notify_ams_lucky_draw_unback_info: " .. tostring(award_index))
  if award_index ~= nil then
    if LuckyUnbackActivitySystem.AmsList == nil then
      LuckyUnbackActivitySystem.AmsList = {}
    end
    table.insert(LuckyUnbackActivitySystem.AmsList, award_index)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_LUCKUNBACK_AMS, EVENTID_LUCKUNBACK_AMS_NOTIFY, award_index)
  end
end
function LuckyUnbackActivitySystem.req_get_ams_luck_draw_unback_info(activity_id)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.req_get_ams_unback_info: activity_id = " .. tostring(activity_id))
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_ams_lucky_draw_unback_req(activity_id)
end
function LuckyUnbackActivitySystem.on_get_ams_lucky_draw_unback_rsp(errcode, awards_list)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.on_get_ams_lucky_draw_unback_rsp ")
  if awards_list then
    log_tree("[cw] awards_list:", awards_list)
  end
  if errcode == 0 and awards_list ~= nil then
    LuckyUnbackActivitySystem.AmsList = awards_list
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_LUCKUNBACK_AMS, EVENTID_LUCKUNBACK_AMS_GET_ACTIVITY_INFO)
  end
end
function LuckyUnbackActivitySystem.req_take_award_ams_lucky_unback(activity_id, award_index)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.req_take_award_ams_lucky_unback ")
  log(bWriteLog and "[cw] activity_id: " .. activity_id)
  log(bWriteLog and "[cw] award_index: " .. award_index)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_ams_lucky_draw_unback_egg_req(activity_id, award_index)
end
function LuckyUnbackActivitySystem.on_take_ams_lucky_draw_unback_rsp(errcode, itemid, num, award_index)
  log(bWriteLog and "[cw] LuckyUnbackActivitySystem.on_take_ams_lucky_draw_unback_rsp ")
  log(bWriteLog and "[cw] errcode: " .. tostring(errcode))
  log(bWriteLog and "[cw] itemid: " .. tostring(itemid))
  log(bWriteLog and "[cw] num: " .. tostring(num))
  log(bWriteLog and "[cw] award_index: " .. tostring(award_index))
  if errcode == 0 then
    if award_index then
      local list = LuckyUnbackActivitySystem.AmsList or {}
      for i, v in ipairs(list) do
        if v == award_index then
          table.remove(list, i)
          break
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_LUCKUNBACK_AMS, EVENTID_LUCKUNBACK_AMS_RECEIVE_AWARD, itemid, num)
  end
end
function LuckyUnbackActivitySystem.on_draw_lucky_surprising_item_ntf(item_list, activityID)
  if activityID ~= LuckyUnbackActivitySystem.ActivityId then
    return
  end
  log(bWriteLog and "[SY]LuckyUnbackActivitySystem.on_draw_lucky_surprising_item_ntf.")
  LuckyUnbackActivitySystem.EggItem_List[activityID] = item_list
end
function LuckyUnbackActivitySystem.send_do_draw_discount_by_activity_req(activityID)
  if not LuckyUnbackActivitySystem.IsCurDiscountNeedDraw() then
    log(bWriteLog and "[SY]LuckyUnbackActivitySystem.send_do_draw_discount_by_activity_req.allreday draw")
    return
  end
  activityID = activityID or LuckyUnbackActivitySystem.ActivityId
  if activityID ~= LuckyUnbackActivitySystem.ActivityId then
    log(bWriteLog and "[SY]LuckyUnbackActivitySystem.send_do_draw_discount_by_activity_req.activityID not match")
    return
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_do_draw_discount_by_activity_req(activityID, LuckyUnbackActivitySystem.CurAwardPoolIndex, LuckyUnbackActivitySystem.GetCurPoolDrawTime() + 1)
end
function LuckyUnbackActivitySystem.on_do_draw_discount_by_activity_rsp(activity_id, discount_Info)
  if LuckyUnbackActivitySystem.ActivityId ~= activity_id then
    return
  end
  LuckyUnbackActivitySystem.DiscountConfig[LuckyUnbackActivitySystem.CurAwardPoolIndex][LuckyUnbackActivitySystem.GetCurPoolDrawTime() + 1] = _CreateDiscountData(discount_Info)
  LuckyUnbackActivitySystem.SetDiscountRedPoint()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYUNBACK_DRAWDISCOUNT_COMPLETE)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKUNYBACK_STATUS_CHANGE)
end
function LuckyUnbackActivitySystem.GM_SetUnbackTestField(backupOne, testBgPath, testPoolPath1, testPoolPath2, testEggPath, testPath)
  test_backupOne = tonumber(backupOne) or 1004
  if not testBgPath or testBgPath == "" then
    testBgPath = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/LuckyunbackTemplate_MainBG.LuckyunbackTemplate_MainBG"
    log(bWriteLog and "[cw][test] use Default bg_path(" .. tostring(testBgPath) .. ")")
  end
  if not testPoolPath1 or testPoolPath1 == "" then
    testPoolPath1 = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/LuckyunbackTemplate_RewardPooll_UIBP.LuckyunbackTemplate_RewardPooll_UIBP"
    log(bWriteLog and "[cw][test] use Default pool_path_1(" .. tostring(testPoolPath1) .. ")")
  end
  if not testPoolPath2 or testPoolPath2 == "" then
    testPoolPath2 = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/LuckyunbackTemplate_RewardPooll_UIBP.LuckyunbackTemplate_RewardPooll_UIBP"
    log(bWriteLog and "[cw][test] use Default pool_path_2(" .. tostring(testPoolPath2) .. ")")
  end
  if not testEggPath or testEggPath == "" then
    testEggPath = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/LuckyunbackTemplate_Egg_UIBP.LuckyunbackTemplate_Egg_UIBP"
    log(bWriteLog and "[cw][test] use Default egg_path(" .. tostring(testEggPath) .. ")")
  end
  if not testPath or testPath == "" then
    testPath = "/Game/Arts_UI/LuckyUnback/2500/Global/BurningMan/BurningMan_Image_BG_1.BurningMan_Image_BG_1"
    log(bWriteLog and "[cw][test] use Default test_BPCfg(" .. tostring(testPath) .. ")")
  end
  test_BPPath = {
    bg_path = testBgPath,
    pool_path_1 = testPoolPath1,
    pool_path_2 = testPoolPath2,
    egg_path = testEggPath
  }
  test_BPCfg = testPath
  log(bWriteLog and "[cw][test] Set test_backupOne to " .. tostring(test_backupOne))
  log(bWriteLog and "[cw][test] Set test_BPPath.bg_path to " .. tostring(test_BPPath.bg_path))
  log(bWriteLog and "[cw][test] Set test_BPPath.pool_path_1 to " .. tostring(test_BPPath.pool_path_1))
  log(bWriteLog and "[cw][test] Set test_BPPath.pool_path_2 to " .. tostring(test_BPPath.pool_path_2))
  log(bWriteLog and "[cw][test] Set test_BPPath.egg_path to " .. tostring(test_BPPath.egg_path))
  log(bWriteLog and "[cw][test] Set test_BPCfg to " .. tostring(test_BPCfg))
end
return LuckyUnbackActivitySystem