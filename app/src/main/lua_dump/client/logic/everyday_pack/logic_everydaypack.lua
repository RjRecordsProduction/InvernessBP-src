local EveryDayPackSystem = {
  uiSwitch = 0,
  open_ui_type = {everydaypack = 1, everydaypack_v2 = 2},
  everydaySystemData = {},
  everydayV2SystemData = {},
  shopPageType = 0,
  dropBoxType = {V2_LuckyBox = 1, V1_LuckBox = 2},
  sLastUIName = nil,
  sVersionResourcePathChange = "4.1.0"
}
EveryDayPackSystem.isWaitingBuyResult = false
function EveryDayPackSystem.ReSetEverydayPackSystemData()
end
function EveryDayPackSystem.GetKV(key)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPack)
  if not cfg then
    return nil
  end
  return cfg[key]
end
function EveryDayPackSystem.SaveKV(key, value)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPack)
  cfg = cfg or {}
  cfg[key] = value
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPack)
end
function EveryDayPackSystem.OnLoginSuccess()
  local EverydayV2PackHandler = require("client.network.Protocol.EverydayV2PackHandler")
  EverydayV2PackHandler.send_daily_direct_buy_v2_get_cfg_req()
end
function EveryDayPackSystem.OnJumpUrl(_, _, tParam)
  log(bWriteLog and "EveryDayPackSystem.OnJumpUrl")
  log_tree("[ljw] tParam", tParam)
  if tParam and type(tParam) == "table" then
    EveryDayPackSystem.sLastUIName = tParam.uiName
  end
  local handler = require("client.network.Protocol.EveryDayPackHandler")
  handler.send_daily_direct_buy_get_cfg()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    if EveryDayPackSystem.everydaySystemData and next(EveryDayPackSystem.everydaySystemData) then
      special_offer_module:OpenDailySpecialBundle()
    end
  end)
end
function EveryDayPackSystem.OnJumpEverydayPackV2()
  log(bWriteLog and "EveryDayPackSystem.OnJumpEverydayPackV2")
  local handler = require("client.network.Protocol.EverydayV2PackHandler")
  handler.send_daily_direct_buy_v2_get_cfg_req()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    if next(EveryDayPackSystem.everydayV2SystemData) then
      special_offer_module:OpenDailyFortunePack()
    end
  end)
end
function EveryDayPackSystem.SetEverydayPackData(sync_data)
  log_tree("EveryDayPackSystem.SetEverydayPackData", sync_data)
  local data = {}
  for i = 1, #sync_data.box_list do
    local syncData = sync_data.box_list[i]
    local boxData = {}
    boxData.itemid = syncData.item_id
    boxData.itemcnt = syncData.buy_cnt .. "/" .. tostring("1")
    boxData.buyCnt = syncData.buy_cnt
    boxData.canBuy = syncData.can_buy
    boxData.productid = syncData.product_id
    boxData.payitem = syncData.pay_item
    boxData.country = syncData.country
    boxData.currency = syncData.currency
    boxData.curency_unit = syncData.currency_unit
    boxData.price = syncData.price
    boxData.CentauriPrice = syncData.Centauri_price
    boxData.discount_view = syncData.discount_view
    data.award = data.award or {}
    table.insert(data.award, boxData)
  end
  data.big_prize_id = sync_data.chest_id
  data.actId = sync_data.act_id
  data.endTime = sync_data.end_time
  data.startTime = sync_data.begin_time
  data.finalId = sync_data.final_id
  data.priceId = sync_data.piece_id
  data.priceNum = sync_data.piece_num
  data.initLuckyNum = sync_data.lucky_init
  data.stateLucky = sync_data.lucky_stage
  data.max_stage = sync_data.max_stage
  data.currStage = sync_data.curr_stage
  data.tomorrowStage = sync_data.tomorrow_stage
  data.all_chest_id_list = sync_data.all_chest_id_list
  data.begin_ts = sync_data.begin_time
  data.end_ts = sync_data.end_time
  data.bg_pic = sync_data.bg_pic
  data.final_buy_cnt = sync_data.final_buy_cnt
  data.final_buy_limit = sync_data.final_buy_limit
  return data
end
function EveryDayPackSystem.GetPropsNum(propsId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local propNum = wardrobe_data:GetHallDepotItemCountByResID(propsId)
  return propNum or 0
end
function EveryDayPackSystem.GetUIByType()
  local ui
  if EveryDayPackSystem.uiSwitch == EveryDayPackSystem.open_ui_type.everydaypack then
    ui = UIManager.GetUI(UIManager.UI_Config.everydaypack_activity)
  elseif EveryDayPackSystem.uiSwitch == EveryDayPackSystem.open_ui_type.everydaypack_v2 then
    ui = UIManager.GetUI(UIManager.UI_Config.everydaypack_activity_v2)
  end
  return ui
end
function EveryDayPackSystem.HasRedPoint()
  local TimeUtil = require("client.common.time_util")
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  local data = EveryDayPackSystem.everydaySystemData
  if not data then
    return false
  end
  local show_red = false
  if EveryDayPackSystem.IsFullAttendancePrizeCanDraw() then
    show_red = true
    log(bWriteLog and "[dailybuy] reddot IsFullAttendancePrizeCanDraw")
  end
  if EveryDayPackSystem.IsLittlePrizeAwardCanDraw() then
    show_red = true
    log(bWriteLog and "[dailybuy] reddot IsLittlePrizeAwardCanDraw")
  end
  local shown_date = EveryDayPackSystem.GetKV("shown_date")
  if shown_date and not TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), tonumber(shown_date) or 0) then
    show_red = true
    log(bWriteLog and "[dailybuy] reddot not IsSameDay")
  end
  return show_red
end
function EveryDayPackSystem.IsEverydayV2RedPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local actJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPackV2) or {}
  if not actJson or not actJson.actId then
    return true
  end
  if actJson.actId and EveryDayPackSystem.everydayV2SystemData and EveryDayPackSystem.everydayV2SystemData.actId and tonumber(actJson.actId) ~= EveryDayPackSystem.everydayV2SystemData.actId then
    return true
  end
  return false
end
function EveryDayPackSystem.SaveLocalData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local actJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPackV2) or {}
  if EveryDayPackSystem.everydayV2SystemData.actId then
    actJson.actId = EveryDayPackSystem.everydayV2SystemData.actId
  end
  PlayerPrefsSystem.SaveTableToFile_N(actJson, PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPackV2)
end
function EveryDayPackSystem.DirectPurchaseCentauriRsp(eventType, eventID, result)
  log(bWriteLog and "EveryDayPackSystem.DirectPurchaseCentauriRsp result:" .. tostring(result))
  EveryDayPackSystem.isWaitingBuyResult = false
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_BUY_GOODS_NOTIFY, EveryDayPackSystem.DirectPurchaseCentauriRsp)
end
function EveryDayPackSystem.RegistCentauriCallback()
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_BUY_GOODS_NOTIFY, EveryDayPackSystem.DirectPurchaseCentauriRsp)
end
function EveryDayPackSystem.GetBuyCount()
  local data = EveryDayPackSystem.everydaySystemData
  return data.buy_cnt or 0
end
function EveryDayPackSystem.GetFullAttendanceBuyLimit()
  local data = EveryDayPackSystem.everydaySystemData
  return data.award_times or 0
end
function EveryDayPackSystem.IsFullAttendancePrizeGot()
  local data = EveryDayPackSystem.everydaySystemData
  return data.is_big_prize_got == true
end
function EveryDayPackSystem.IsCompleteFullAttendance()
  local buyLimit = EveryDayPackSystem.GetFullAttendanceBuyLimit()
  local buy_cnt = EveryDayPackSystem.GetBuyCount()
  return buyLimit <= buy_cnt
end
function EveryDayPackSystem.FullAttendanceNeedBuyNum()
  local buyLimit = EveryDayPackSystem.GetFullAttendanceBuyLimit()
  local buyCount = EveryDayPackSystem.GetBuyCount()
  return buyLimit - buyCount
end
function EveryDayPackSystem.IsFullAttendancePrizeCanDraw()
  return EveryDayPackSystem.IsCompleteFullAttendance() and not EveryDayPackSystem.IsFullAttendancePrizeGot()
end
function EveryDayPackSystem.GetFullAttendanceBigPrizeID()
  local data = EveryDayPackSystem.everydaySystemData
  return data.big_prize_id
end
function EveryDayPackSystem.GetLittlePrizeCanDrawNum()
  local limit = EveryDayPackSystem.GetLittlePrizeConditionCount()
  local buyCount = EveryDayPackSystem.GetBuyCount()
  local usedNum = EveryDayPackSystem.GetLittlePrizeDrawUsedNum()
  return math.floor(buyCount / limit) - usedNum
end
function EveryDayPackSystem.GetLittlePrizeDrawUsedNum()
  local data = EveryDayPackSystem.everydaySystemData
  return data.little_prize_count or 0
end
function EveryDayPackSystem.GetLittlePrizeID()
  local data = EveryDayPackSystem.everydaySystemData
  return data.little_prize_id
end
function EveryDayPackSystem.IsLittlePrizeAwardCanDraw()
  local num = EveryDayPackSystem.GetLittlePrizeCanDrawNum()
  return 0 < num
end
function EveryDayPackSystem.GetLittlePrizeDrawUsedNumOfCurrentRound()
  local data = EveryDayPackSystem.everydaySystemData
  return EveryDayPackSystem.GetBuyCount() % EveryDayPackSystem.GetLittlePrizeConditionCount()
end
function EveryDayPackSystem.GetLittlePrizeConditionCount()
  local data = EveryDayPackSystem.everydaySystemData
  return data.little_award_times
end
function EveryDayPackSystem.GetDrawAwardPicPath()
  local data = EveryDayPackSystem.everydaySystemData
  return EveryDayPackSystem.HandleVersionResource(data.draw_award_pic_path or "")
end
function EveryDayPackSystem.GetTodayIsBuy()
  local data = EveryDayPackSystem.everydaySystemData
  return data.is_today_buy
end
function EveryDayPackSystem.GetDirectBuyData()
  local data = EveryDayPackSystem.everydaySystemData
  return data.direct_buy_data
end
function EveryDayPackSystem.GetUCCount()
  local data = EveryDayPackSystem.everydaySystemData
  return data.daily_uc_count
end
function EveryDayPackSystem.GetDailyChestID()
  local data = EveryDayPackSystem.everydaySystemData
  return data.daily_chest_id
end
function EveryDayPackSystem.GetDirectBuyPicPath()
  local data = EveryDayPackSystem.everydaySystemData
  return EveryDayPackSystem.HandleVersionResource(data.direct_buy_pic_path or "")
end
function EveryDayPackSystem.HandleVersionResource(sPath)
  if not FuncUtil.IsNewVersion(EveryDayPackSystem.sVersionResourcePathChange) then
    local sNewPath = string.gsub(sPath, "/Game/UMG/Texture_200/Lobby_NoAtlas/SpecialOffer/EveryDayPack/", "/Game/Arts_UI/FromUMG/SpecialOffer/EverydayPack/Texture/")
    log(bWriteLog and "[SY]EveryDayPackSystem.HandleVersionResource1." .. tostring(sNewPath) .. "sPath:" .. tostring(sPath))
    return sNewPath
  end
  log(bWriteLog and "[SY]EveryDayPackSystem.HandleVersionResource2." .. tostring(sPath))
  return sPath
end
function EveryDayPackSystem.RefreshTodayAndBuyStatus()
  local data = EveryDayPackSystem.everydaySystemData
  local preDay = data.day
  local today = EveryDayPackSystem.GetToday()
  if today and preDay and preDay < today then
    data.day = today
    data.is_today_buy = false
    log(bWriteLog and "[dailybuy] daycross today" .. tostring(today) .. "preday" .. tostring(preDay) .. "delta" .. tostring(delta))
  end
end
function EveryDayPackSystem.GetToday()
  local data = EveryDayPackSystem.everydaySystemData
  local startTime = data.begin_ts
  local startTimeOfDayStart = math.floor(startTime / 86400) * 86400
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local currentTimeOfDayStart = math.floor(currentTime / 86400) * 86400
  local delta = currentTimeOfDayStart - startTimeOfDayStart
  local today = 1
  if 0 < delta then
    today = delta // 86400 + 1
  end
  local endTime = data.end_ts
  local endTimeOfDayStart = math.floor(endTime / 86400) * 86400
  local maxDay = (endTimeOfDayStart - startTimeOfDayStart) // 86400 + 1
  today = math.min(today, maxDay)
  return today
end
function EveryDayPackSystem.IsLastDay()
  local data = EveryDayPackSystem.everydaySystemData
  local endTime = data.end_ts
  local TimeUtil = require("client.common.time_util")
  local bLastDay = TimeUtil.IsToday(endTime)
  return bLastDay
end
function EveryDayPackSystem.GetDrawUsedNum()
  local littlePrizeCount = EveryDayPackSystem.GetLittlePrizeDrawUsedNum()
  local bigPrizeCount = EveryDayPackSystem.IsFullAttendancePrizeGot() and 1 or 0
  return littlePrizeCount + bigPrizeCount
end
function EveryDayPackSystem.GetLeftDay()
  local data = EveryDayPackSystem.everydaySystemData
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local currentTimeOfDayStart = math.floor(currentTime / 86400) * 86400
  local endTime = data.end_ts
  local endTimeOfDayStart = math.floor(endTime / 86400) * 86400
  local leftDay = (endTimeOfDayStart - currentTimeOfDayStart) // 86400
  return leftDay
end
function EveryDayPackSystem.GetBackgroundPicPaths()
  local data = EveryDayPackSystem.everydaySystemData
  if not data then
    return nil, nil
  end
  return data.left_background_pic, data.right_background_pic
end
return EveryDayPackSystem