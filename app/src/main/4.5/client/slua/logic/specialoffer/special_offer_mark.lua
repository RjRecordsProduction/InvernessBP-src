local special_offer_mark = {}
local markType = {
  Got = 1,
  New = 2,
  Hot = 3,
  BuyAble = 4,
  Lost = 5,
  Day = 6,
  Red = 7
}
local markDir = {
  [markType.New] = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item05.Reddot_Anchor_Item05",
  [markType.Got] = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item03.Reddot_Anchor_Item03",
  [markType.Hot] = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item11.Reddot_Anchor_Item11",
  [markType.Lost] = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item01.Reddot_Anchor_Item01",
  [markType.BuyAble] = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item12.Reddot_Anchor_Item12",
  [markType.Red] = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item01.Reddot_Anchor_Item01"
}
special_offer_mark.local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
local UIUtil = require("client.common.ui_util")
local HasClickedMark = function(id, markTp)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  return special_offer_module:HasClickedMark(id, markTp, markTp == markType.New)
end
local IsHot = function(id)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  return special_offer_module:IsHotMark(id)
end
function special_offer_mark.GetMarkDir(markTp)
  return markDir[markTp] or markDir[markType.Red]
end
special_offer_mark[cfg.golden] = function()
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  local awards = logic_scrapgold_draw.GetTotalDrawAwardConfig(logic_scrapgold_draw.ActivityId)
  if not next(awards) then
    return
  end
  local markTb
  for _, award in ipairs(awards) do
    if award.status < ActivityProgressStatus.Done then
      break
    end
    if award.status == ActivityProgressStatus.Done then
      return markType.Got
    end
  end
  markTb = markType.New
  if not HasClickedMark(cfg.golden, markTb) then
    return markTb
  end
  if IsHot(cfg.golden) then
    markTb = markType.Hot
    if not HasClickedMark(cfg.golden, markTb) then
      return markTb
    end
  end
end
local ActHasMark = function(actType)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByTypeAndLabel(actType, ActivitySwitchType.SpecialOffer)
  if not actData then
    return
  end
  local list = actData and actData.List
  if list then
    for _, oneAct in ipairs(list) do
      if oneAct.Status == ActivityProgressStatus.Done then
        return markType.Got
      end
    end
  end
  local id = actData.ID
  local markTb = markType.New
  if not HasClickedMark(id, markTb) then
    return markTb
  end
  if IsHot(id) then
    markTb = markType.Hot
    if not HasClickedMark(id, markTb) then
      return markTb
    end
  end
  if actData.EndTime and UIUtil.IsCountDown(actData.EndTime, 3) then
    return markType.Day, actData.EndTime
  end
end
special_offer_mark[cfg.ACTIVITY_TYPE_CONSUME_UC] = function()
  return ActHasMark(ActivityType.ACTIVITY_TYPE_CONSUME_UC)
end
special_offer_mark[cfg.CONSUME_UC] = function()
  return ActHasMark(ActivityType.CONSUME_UC)
end
special_offer_mark[cfg.DailySpecialBundle] = function()
  if not cfg.id2CheckShow[cfg.DailySpecialBundle]() then
    return
  end
  local markTb = markType.New
  if not HasClickedMark(cfg.DailySpecialBundle, markTb) then
    return markTb
  end
  local everydayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  local actData = everydayPackSystem.everydaySystemData
  if actData and actData.end_ts and UIUtil.IsCountDown(actData.end_ts, 3) then
    return markType.Day, actData.end_ts
  end
end
special_offer_mark[cfg.MaterialsGift] = function()
  if not cfg.id2CheckShow[cfg.MaterialsGift]() then
    return
  end
  local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
  local data = logic_special_offer_material:CheckGiftData()
  if not data then
    return
  end
  local markTb
  markTb = markType.New
  if not HasClickedMark(cfg.MaterialsGift, markTb) then
    return markTb
  end
  if IsHot(cfg.MaterialsGift) then
    markTb = markType.Hot
    if not HasClickedMark(cfg.MaterialsGift, markTb) then
      return markTb
    end
  end
  local store_limited_subscribe_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
  if logic_special_offer_material:HasReUpdate() or store_limited_subscribe_data:HaveMaterialSpecialOffer() then
    return markType.BuyAble
  end
end
special_offer_mark[cfg.ConditionsGift] = function()
  if not cfg.id2CheckShow[cfg.ConditionsGift]() then
    return
  end
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  local data = logic_special_offer_condition:CheckGiftData()
  if not data then
    return
  end
  local markTb
  markTb = markType.New
  if not HasClickedMark(cfg.ConditionsGift, markTb) then
    return markTb
  end
  if IsHot(cfg.ConditionsGift) then
    markTb = markType.Hot
    if not HasClickedMark(cfg.ConditionsGift, markTb) then
      return markTb
    end
  end
  local time = logic_special_offer_condition:GetCountDown()
  if time and 0 < time and UIUtil.IsCountDown(time, 3) then
    return markType.Day, time
  end
  local bIsCanBuy = logic_special_offer_condition:IsCanBuyGifts()
  if bIsCanBuy then
    markTb = markType.BuyAble
    if not HasClickedMark(cfg.ConditionsGift, markTb) then
      return markTb
    end
    local bIsCanGetAward = logic_special_offer_condition:IsCanGetAward()
    markTb = markType.Got
    if bIsCanGetAward then
      return markTb
    end
  end
end
special_offer_mark[cfg.subscribe] = function()
  if not cfg.id2CheckShow[cfg.subscribe]() then
    return
  end
  local markTb
  local nCurId = cfg.subscribe
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  if subscribeModuleObj:GetIsPurchasedSub() and (subscribeModuleObj:HasDailyReward() or subscribeModuleObj:HasWeekReward()) then
    return markType.Got
  end
  markTb = markType.New
  if not HasClickedMark(nCurId, markTb) then
    return markTb
  end
  if IsHot(nCurId) then
    markTb = markType.Hot
    if not HasClickedMark(nCurId, markTb) then
      return markTb
    end
  end
  local TimeUtil = require("client.common.time_util")
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local nNormalEndTime = subscribeModuleObj:Get_Left_Time(SubscribeEnumConfig.ENUM_SubId.Normal)
  local nSuperTime = subscribeModuleObj:Get_Left_Time(SubscribeEnumConfig.ENUM_SubId.Super)
  local nEndTime = nSuperTime
  if nEndTime == 0 or nCurTime > nEndTime and nNormalEndTime ~= 0 then
    nEndTime = nNormalEndTime
  end
  if nEndTime == 0 then
    return
  elseif nCurTime > nEndTime then
    markTb = markType.Lost
    if not HasClickedMark(nCurId, markTb) then
      return markTb
    end
  else
    markTb = markType.Day
    if not HasClickedMark(nCurId, markTb) then
      local nRemainderTime = nEndTime - nCurTime
      local nDay = TimeUtil.FormatCountDownTime_D_SocialCard(nRemainderTime)
      return markTb, nDay
    end
  end
end
special_offer_mark[cfg.SmallRP] = function()
  if not cfg.id2CheckShow[cfg.SmallRP]() then
    return
  end
  local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
  if not Logic_SmallRPRedMgr:GetIsOpenedAct() then
    return markType.New
  end
  if Logic_SmallRPRedMgr:GetTaskIsRed() or Logic_SmallRPRedMgr:GetLevelRewardIsRed() then
    return markType.Got
  end
  local SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local _, EndTime = SmallRP:GetActTime()
  if EndTime and UIUtil.IsCountDown(EndTime, 3) then
    return markType.Day, EndTime
  end
  return markType.Done
end
special_offer_mark[cfg.Financial] = function()
  if cfg and cfg.id2CheckShow and not cfg.id2CheckShow[cfg.Financial]() then
    return
  end
  local Logic_Financial = require("client.slua.logic.Financial.Logic_Financial")
  if Logic_Financial.HasAvailableTask() and not Logic_Financial.GetIsBuyGift() then
    return markType.Got
  end
  local _, EndTime = Logic_Financial.GetActivityTime()
  if EndTime and UIUtil.IsCountDown(EndTime, 3) then
    return markType.Day, EndTime
  end
end
special_offer_mark[cfg.PandoraPopular] = function()
  if not cfg.id2CheckShow[cfg.PandoraPopular]() then
    return
  end
  local logic_pandora_red = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_pandora_red)
  if logic_pandora_red:IsNeedShowNewRed() then
    return markType.New
  end
end
special_offer_mark[cfg.DailyFortunePack] = function()
  if not cfg.id2CheckShow[cfg.DailyFortunePack]() then
    return
  end
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  local data = EveryDayPackSystem.everydayV2SystemData
  local markTb = markType.New
  if not HasClickedMark(cfg.DailyFortunePack, markTb) then
    return markTb
  end
  if data.end_ts and UIUtil.IsCountDown(data.end_ts, 3) then
    return markType.Day, data.end_ts
  end
end
special_offer_mark[cfg.OPTIONAL_RECHARGE] = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tActData = ActivityNewSystem.GetActivityByType(ActivityType.OPTIONAL_RECHARGE)
  if not tActData then
    return
  end
  local markTb = markType.New
  if not HasClickedMark(cfg.OPTIONAL_RECHARGE, markTb) then
    return markTb
  end
  if tActData.EndTime and UIUtil.IsCountDown(tActData.EndTime, 3) then
    return markType.Day, tActData.EndTime
  end
end
special_offer_mark[cfg.recharge] = function()
  local TheFirstChargeSystem = require("client.slua.logic.recharge.logic_the_first_charge")
  if TheFirstChargeSystem.IsHaveRewardRed() then
    return markType.Got
  end
end
special_offer_mark[cfg.DiscountDirect] = function()
  if not cfg.id2CheckShow[cfg.DiscountDirect]() then
    return
  end
  local Discount_Direct_Logic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Discount_Direct_Logic)
  local data = Discount_Direct_Logic:GetGiftsData()
  if not (data and data[1]) or not data[1].endTime then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local timeEnd = TimeUtil.TimeStringToUnixstamp(data[1].endTime)
  if timeEnd and UIUtil.IsCountDown(timeEnd, 3) then
    return markType.Day, timeEnd
  end
end
special_offer_mark[cfg.TEMU] = function()
  if not cfg.id2CheckShow[cfg.TEMU]() then
    return
  end
  local nCurId = cfg.TEMU
  local markTb = markType.New
  if not HasClickedMark(nCurId, markTb) then
    return markTb
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  local timeEnd = Logic_temu:GetCurEndTime()
  if timeEnd and UIUtil.IsCountDown(timeEnd, 3) then
    return markType.Day, timeEnd
  end
  if Logic_temu:IsNeedShowReddot() then
    return markType.Red
  end
end
special_offer_mark[cfg.NewGroupBuy] = function()
  if not cfg.id2CheckShow[cfg.NewGroupBuy]() then
    return
  end
  local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
  if not logic_group_buying:HasClickedAct() then
    return markType.New
  end
  if logic_group_buying:BuyAble() then
    return markType.BuyAble
  end
  if not logic_group_buying:HasNewGroupBag() then
    return markType.New
  end
  if logic_group_buying:HasAward() then
    return markType.Got
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  if not logic_bargain or not logic_bargain:IsShow() then
    return
  end
  if not logic_bargain:HasClickedAct() then
    return markType.Red, nil, true
  end
  if not logic_bargain:HasClickedNewGift() then
    return markType.Red, nil, true
  end
  if logic_bargain:HasReadyToBuyGift() then
    return markType.BuyAble
  end
  if logic_bargain:HasBuyAward() then
    return markType.Got
  end
  if logic_bargain:HasFriendCutRedDot() or logic_bargain:HasTaskCutRedDot() then
    return markType.Red
  end
end
special_offer_mark.return special_offer_mark