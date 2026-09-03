local TheFirstChargeSystem = {
  timer = nil,
  showSmallUI = false,
  red_dot = false,
  info = {},
  buyInfo = {},
  award1 = {},
  award2 = {},
  awardIndex = 0,
  seasonTitle = "",
  seasonDesc1 = "",
  seasonDesc2 = "",
  buy_SeasonTime = ""
}
function TheFirstChargeSystem.ShowSmallUI()
  if TheFirstChargeSystem.showSmallUI then
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_SEASON_FIRST_DISPLAY, true)
  end
end
function TheFirstChargeSystem.CloseSmallUI()
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_SEASON_FIRST_DISPLAY, false)
end
function TheFirstChargeSystem.TryShowFirstCharge()
  TheFirstChargeSystem.showSmallUI = true
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.ReqGetSeasonRechargeInfo(false)
end
function TheFirstChargeSystem.SetData()
  TheFirstChargeSystem.buyInfo = {}
  TheFirstChargeSystem.award1 = {}
  TheFirstChargeSystem.award2 = {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local firstChargeInfo = ActivityNewSystem.GetFirstChargeInfo()
  if firstChargeInfo then
    if firstChargeInfo.show_info then
      log_tree("[cw] firstChargeInfo.show_info:", firstChargeInfo.show_info)
      TheFirstChargeSystem.buyInfo.total_recharged = firstChargeInfo.total_recharged
      TheFirstChargeSystem.buyInfo.status = firstChargeInfo.bargain_status
      TheFirstChargeSystem.buyInfo.itemId = firstChargeInfo.show_info.bargain_id
      TheFirstChargeSystem.buyInfo.num = firstChargeInfo.show_info.bargain_num
      TheFirstChargeSystem.buyInfo.orgin_price = firstChargeInfo.show_info.bargain_orgin_price
      TheFirstChargeSystem.buyInfo.price = firstChargeInfo.show_info.bargain_price
      TheFirstChargeSystem.buyInfo.seasonIndex = firstChargeInfo.season_index
    end
    if firstChargeInfo.award_status and firstChargeInfo.show_info.award then
      TheFirstChargeSystem.award1.itemId = firstChargeInfo.show_info.award[1].id
      TheFirstChargeSystem.award1.num = firstChargeInfo.show_info.award[1].num
      TheFirstChargeSystem.award1.condUC = firstChargeInfo.show_info.award[1].cond
      TheFirstChargeSystem.award1.status = firstChargeInfo.award_status[1]
      TheFirstChargeSystem.award2.itemId = firstChargeInfo.show_info.award[2].id
      TheFirstChargeSystem.award2.num = firstChargeInfo.show_info.award[2].num
      TheFirstChargeSystem.award2.condUC = firstChargeInfo.show_info.award[2].cond
      TheFirstChargeSystem.award2.status = firstChargeInfo.award_status[2]
    end
    if firstChargeInfo and TheFirstChargeSystem.award2.condUC > 0 then
      TheFirstChargeSystem.buyInfo.process_f = firstChargeInfo.total_recharged / TheFirstChargeSystem.award2.condUC
    end
  end
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  if subscribeModuleObj:GetIsPrimeOpen() == true then
    TheFirstChargeSystem.seasonDesc1 = LocUtil.GetLocalizeResStr(6358)
  else
    TheFirstChargeSystem.seasonDesc1 = ""
  end
  TheFirstChargeSystem.seasonDesc2 = LocUtil.GetLocalizeResStr(6359)
  TheFirstChargeSystem.buy_SeasonTime = ""
  if UnknowPassSystem.SeasonInfo and UnknowPassSystem.SeasonInfo.in_cur_season and UnknowPassSystem.SeasonInfo.cfg then
    TheFirstChargeSystem.buy_SeasonTime = UnknowPassSystem.SeasonInfo.cfg.show_time or ""
  end
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_THE_FIRST_CHARGE_INFO_CHANGE)
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.recharge)
end
function TheFirstChargeSystem.IsHaveRewardRed()
  return TheFirstChargeSystem.award1.status == 2 or TheFirstChargeSystem.award2.status == 2
end
function TheFirstChargeSystem.UpdateUI()
  local RechargeJKSystem = require("client.logic.recharge.logic_recharge_jk")
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  local isFirstchargeShowing = RechargeSystem.GetFirstChargeShowingState() or RechargeJKSystem.GetFirstChargeShowingState()
  if isFirstchargeShowing then
    TheFirstChargeSystem.RefreshData()
    log(bWriteLog and "[cw] post event EVENTID_RECHARGE_THE_FIRST_CHARGE_INFO_CHANGE ")
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_THE_FIRST_CHARGE_INFO_CHANGE)
  else
    log(bWriteLog and "[cw]TheFirstChargeUI.UpdateUI, IsUIShow == false!")
  end
end
function TheFirstChargeSystem.RefreshData()
  TheFirstChargeSystem.ResetData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.FIRST_RECHARGE_ADD)
  for _, activity in ipairs(activityData) do
    if activity.other and activity.other.is_first_recharge then
      TheFirstChargeSystem.info.hasCharged = activity.other.is_first_recharge
    end
    if activity.ID then
      TheFirstChargeSystem.info.actId = activity.ID
    end
    if activity.List and activity.List[1] then
      local info = activity.List[1]
      if info.Status then
        TheFirstChargeSystem.info.status = info.Status
      end
    end
  end
  local actInfo = TheFirstChargeSystem.info
  if actInfo.actId == 0 or actInfo.status == 2 then
    actInfo.handleFlag = 0
  elseif actInfo.hasCharged == false then
    actInfo.handleFlag = 1
  elseif actInfo.hasCharged == true then
    actInfo.handleFlag = 2
  end
  return actInfo.handleFlag
end
function TheFirstChargeSystem.ResetData()
  TheFirstChargeSystem.info.handleFlag = 0
  TheFirstChargeSystem.info.hasCharged = false
  TheFirstChargeSystem.info.status = 0
  TheFirstChargeSystem.info.actId = 0
  TheFirstChargeSystem.info.isJK = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    TheFirstChargeSystem.info.isJK = true
  else
    TheFirstChargeSystem.info.isJK = false
  end
end
function TheFirstChargeSystem.EventBuySkin()
  local MallSystem = require("client.logic.mall.logic_mall")
  if TheFirstChargeSystem.info.status == 0 then
  elseif TheFirstChargeSystem.info.status == 1 then
    local strBuy = LocUtil.GetLocalizeResStr("301185")
    local tip = LocUtil.GetLocalizeResStr("301372")
    local content = LocUtil.GetLocalizeResStr("5015")
    tip = LocUtil.LocalizeResFormatByStr(tip, "180", content)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strBuy, tip, function()
      local activityId = TheFirstChargeSystem.info.actId
      if activityId ~= nil and activityId ~= 0 then
        MallSystem.HandleReqNum()
        local StoreHandler = require("client.network.Protocol.StoreHandler")
        StoreHandler.send_activity_market_buy_req(activityId)
      end
    end)
  elseif TheFirstChargeSystem.info.status == 2 then
    local tip = LocUtil.GetLocalizeResStr(4793)
    tip = tip .. LocUtil.GetLocalizeResStr(5015)
    ShowNotice(tip)
  end
end
function TheFirstChargeSystem.ChangedNotify(data)
  if data then
    if data.total_recharged then
      TheFirstChargeSystem.buyInfo.total_recharged = data.total_recharged
    end
    if data.award then
      if data.award[1] then
        TheFirstChargeSystem.award1.status = data.award[1]
      end
      if data.award[2] then
        TheFirstChargeSystem.award2.status = data.award[2]
      end
    end
    if data.bargain_status then
      TheFirstChargeSystem.buyInfo.status = data.bargain_status
    end
  end
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.recharge)
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_THE_FIRST_CHARGE_INFO_CHANGE)
  TheFirstChargeSystem.CheckFirstChargeRedDot()
  TheFirstChargeSystem.CheckIsFinished()
end
function TheFirstChargeSystem.CheckIsFinished()
  log(bWriteLog and "[cw]TheFirstChargeUI.CheckIsFinished")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local firstChargeInfo = ActivityNewSystem.GetFirstChargeInfo()
  if firstChargeInfo and firstChargeInfo.award_status and firstChargeInfo.buyInfo and firstChargeInfo.buyInfo.status and firstChargeInfo.bargain_status == 3 and firstChargeInfo.award_status[1] == 3 and firstChargeInfo.buyInfo.status[2] == 3 then
    log(bWriteLog and "TheFirstChargeUI.CheckIsFinished Hide First Charge")
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    RechargeSystem.isHideFirstCharge = true
    local RechargeJKSystem = require("client.logic.recharge.logic_recharge_jk")
    RechargeJKSystem.SetIsHideFirstCharge(true)
    LobbySystem.RefreshBannerDisplayList()
  end
end
function TheFirstChargeSystem.CheckFirstChargeRedDot()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local firstChargeInfo = ActivityNewSystem.GetFirstChargeInfo()
  local redDot = false
  if firstChargeInfo then
    if firstChargeInfo.bargain_status == 2 then
      redDot = true
    end
    if firstChargeInfo.award_status and (firstChargeInfo.award_status[1] == 2 or firstChargeInfo.award_status[2] == 2) then
      redDot = true
    end
    if TheFirstChargeSystem.award1.status == 2 or TheFirstChargeSystem.award2.status == 2 or TheFirstChargeSystem.info.status == 2 then
      redDot = true
    end
    if firstChargeInfo.is_first_login then
      redDot = true
    end
  end
  if not LogicNewbie.IsNewbie() or LogicNewbie.NeedShowNewbieGuide(10603) then
    TheFirstChargeSystem.red_dot = redDot
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON, redDot)
  end
end
function TheFirstChargeSystem.SetAllDone()
  TheFirstChargeSystem.buyInfo.status = 3
  TheFirstChargeSystem.award1.status = 3
  TheFirstChargeSystem.award2.status = 3
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.recharge)
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_THE_FIRST_CHARGE_INFO_CHANGE)
end
function TheFirstChargeSystem.GetActIsFinish()
  return TheFirstChargeSystem.buyInfo.status == 3 and TheFirstChargeSystem.award1.status == 3 and TheFirstChargeSystem.award2.status == 3
end
function TheFirstChargeSystem.SetOpenCountDown(data)
  local time_ticker = require("common.time_ticker")
  if TheFirstChargeSystem.timer then
    time_ticker.RemoveTimer(TheFirstChargeSystem.timer)
  end
  if data and 0 < data then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    if data > serverTime then
      TheFirstChargeSystem.timer = time_ticker.AddTimerOnce(data - serverTime + 5, TheFirstChargeSystem.get_season_recharge_info_req)
    end
  end
end
function TheFirstChargeSystem.get_season_recharge_info_req()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "[cw]TheFirstChargeUI.timer____send")
  if not LogicNewbie.IsNewbie() or LogicNewbie.NeedShowNewbieGuide(10603) then
    TheFirstChargeSystem.red_dot = true
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON, true)
  end
end
function TheFirstChargeSystem.EventBuy()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  local strBuy = LocUtil.GetLocalizeResStr(301185)
  local itemCfg = CDataTable.GetTableData("Item", TheFirstChargeSystem.buyInfo.itemId)
  local tip
  if itemCfg then
    if TheFirstChargeSystem.buyInfo.price <= DataMgr.ticket then
      tip = LocUtil.GetLocalizeResStr("301372")
    else
      tip = LocUtil.GetLocalizeResStr("4826")
    end
    tip = LocUtil.LocalizeResFormatByStr(tip, TheFirstChargeSystem.buyInfo.price, itemCfg.ItemName)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strBuy, tip, function()
      local Logic_QRCodeRestrictUtils = require("client.slua.logic.QRCodeLogin.Logic_QRCodeRestrictUtils")
      if Logic_QRCodeRestrictUtils.IsUcUseLimit() then
        return
      end
      if TheFirstChargeSystem.buyInfo.price <= DataMgr.ticket then
        local ActivityHandler = require("client.network.Protocol.ActivityHandler")
        ActivityHandler.send_season_recharge_buy_req()
      else
        ShowNotice(12545)
      end
    end)
  else
    log_error("[cw]EventFirstChargeBuyClick itemCfg error")
  end
end
function TheFirstChargeSystem.EventPay()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  TheFirstChargeSystem.CloseSmallUI()
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.OpenRechargeUI()
end
function TheFirstChargeSystem.EventAwardClick()
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_season_recharge_award_req(TheFirstChargeSystem.awardIndex)
end
function TheFirstChargeSystem.ResetIsShowSmall()
  TheFirstChargeSystem.showSmallUI = false
end
function TheFirstChargeSystem.GetIsShowFirstRechargeUCBg()
  local season_id = tonumber(DataMgr.season_id)
  local uSeasonCfg = CDataTable.GetTableData("SeasonInfo", season_id)
  if not uSeasonCfg then
    return false
  end
  local sSeasonTime = uSeasonCfg.StartTime
  local TimeUtil = require("client.common.time_util")
  local nTimeStamp = TimeUtil.TimeStringToUnixstamp(sSeasonTime)
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if math.ceil((nCurTime - nTimeStamp) / 86400) > 7 then
    return false
  end
  local nItem1State = TheFirstChargeSystem.award1.status
  local nItem2State = TheFirstChargeSystem.award2.status
  local nItem3State = TheFirstChargeSystem.buyInfo.status
  if nItem1State and nItem1State < 3 and nItem2State and nItem2State < 3 and nItem3State and nItem3State < 3 then
    return true
  end
  return false
end
function TheFirstChargeSystem.GetIsUnlockedFirstCharge()
  local nItem2State = TheFirstChargeSystem.award2.status or 0
  return 1 < nItem2State or nItem2State == 0
end
return TheFirstChargeSystem