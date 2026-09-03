local UnknowPassEasyTicketSystem = {
  SeasonID = 0,
  HasRewardsReddot = false,
  TicketID = 0,
  TicketBuyID = 0
}
local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
function UnknowPassEasyTicketSystem.OpenEasyTicketUI()
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_easy_ticket)
  end
end
function UnknowPassEasyTicketSystem.HideEasyTicketUI()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.unknowpass_easy_ticket)
  end
end
function UnknowPassEasyTicketSystem.GetTicketsConfig()
  if UnknowPassEasyTicketSystem.SeasonID ~= UnknowPassSystem.Season then
    UnknowPassEasyTicketSystem.TicketConfigs = {}
    UnknowPassEasyTicketSystem.SeasonID = UnknowPassSystem.Season
    local cfgs = CDataTable.GetTable("UnknowPassEasyTicketCfg")
    for i, cfg in pairs(cfgs) do
      if cfg.SeasonId == UnknowPassSystem.Season and cfg.PriceItemId == 1006 then
        local data = {
          price = cfg.Price,
          id = cfg.ID
        }
        UnknowPassEasyTicketSystem.TicketConfigs[cfg.Count] = data
      end
    end
  end
  return UnknowPassEasyTicketSystem.TicketConfigs
end
function UnknowPassEasyTicketSystem.GetCurrentTicketsLevel()
  return UnknowPassSystem.GetKeeyBuy()
end
function UnknowPassEasyTicketSystem.HasBuyTicket()
  if UnknowPassSystem.Data.play_card then
    return true
  end
  return false
end
function UnknowPassEasyTicketSystem.HasGetRewardsTicket()
  if UnknowPassSystem.Data.play_card then
    if UnknowPassSystem.Data.play_card.reward_time then
      local TimeUtil = require("client.common.time_util")
      return UnknowPassEasyTicketSystem.is_same_pass_week(UnknowPassSystem.Data.play_card.reward_time, TimeUtil.GetServerTimeInSec())
    else
      return false
    end
  end
  return false
end
function UnknowPassEasyTicketSystem.JumpToMissionNextWeek()
  UnknowPassEasyTicketSystem.HideEasyTicketUI()
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  UnknowPassOpenUISystem.CloseSecUIWhenJumpInSide()
  local jumpInfo = {}
  jumpInfo.Tab1 = 4
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassTunnelSystem.  if not UnknowPassTunnelSystem.isShowRP then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_AWARD_TRIGGER)
    UnknowPassTunnelSystem.ShowRP(jumpInfo)
  elseif not UIManager.IsUIShow(UIManager.UI_Config.unknowpass_mission_sec) then
    local OpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
    OpenUISystem.OpenMission()
  else
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_JUMP_NEWEST_WEEKMISSION)
  end
end
function UnknowPassEasyTicketSystem.JumpToMissionOpenBox()
  UnknowPassEasyTicketSystem.HideEasyTicketUI()
  local OpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  OpenUISystem.OpenMission()
end
function UnknowPassEasyTicketSystem.GetNewSeasonRedPoint(hideReddot)
  local newSeasonredId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketNewSeason_Reddot
  local newSeasonRed = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, newSeasonredId)
  if newSeasonRed then
    local TimeUtil = require("client.common.time_util")
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    local seasonStartTime = UnknowPassUtil.GetSeasonStartTime()
    local newSeasonVaild = TimeUtil.InDaysFrom(seasonStartTime, 3)
    newSeasonRed = newSeasonRed and newSeasonVaild and 3 <= UnknowPassSystem.GetKeeyBuy()
  end
  if hideReddot and newSeasonRed then
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, newSeasonredId)
  end
  return newSeasonRed
end
function UnknowPassEasyTicketSystem.UpdateRedPoint(hideReddot)
  local totalRedPoint = false
  totalRedPoint = totalRedPoint or UnknowPassEasyTicketSystem.GetNewSeasonRedPoint(hideReddot)
  local keepRedPoint = false
  local keepBuyCount = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketKeepBuy_Reddot)
  local level = UnknowPassEasyTicketSystem.GetCurrentTicketsLevel()
  if keepBuyCount then
    keepRedPoint = keepBuyCount ~= level
  else
    keepRedPoint = true
  end
  if hideReddot and keepRedPoint then
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketKeepBuy_Reddot, level)
  end
  local newWeekRedPoint = false
  local RewardsTicketRedPoint = false
  local weekIndex = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketNewWeek_Reddot)
  local curWeekIndex = UnknowPassSystem.Data.cur_week_index
  local hasBuyCard = UnknowPassEasyTicketSystem.HasBuyTicket()
  if hasBuyCard then
    if weekIndex then
      newWeekRedPoint = weekIndex ~= curWeekIndex
    else
      newWeekRedPoint = true
    end
    RewardsTicketRedPoint = not UnknowPassEasyTicketSystem.HasGetRewardsTicket()
    totalRedPoint = totalRedPoint or newWeekRedPoint
  end
  UnknowPassEasyTicketSystem.HasRewardsReddot = RewardsTicketRedPoint
  if hideReddot then
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketNewWeek_Reddot, curWeekIndex)
    totalRedPoint = false
  end
  totalRedPoint = totalRedPoint or RewardsTicketRedPoint
  if UnknowPassSystem.IsBuyElite and UnknowPassSystem.GetKeeyBuy() >= 3 and not UnknowPassEasyTicketSystem.HasBuyTicket() then
    totalRedPoint = true
  end
  return totalRedPoint
end
function UnknowPassEasyTicketSystem.IsTaskNewWeek()
  local newWeek = false
  local weekIndex = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketTaskNewWeek_Reddot)
  local curWeekIndex = UnknowPassSystem.Data.cur_week_index
  if weekIndex then
    newWeek = weekIndex ~= curWeekIndex
  else
    newWeek = true
  end
  return newWeek
end
function UnknowPassEasyTicketSystem.SetTaskWeek(index)
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketTaskNewWeek_Reddot, index)
end
function UnknowPassEasyTicketSystem.NeedShowNewGuide()
  local guideId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketTips_Reddot
  local newSeasonRed = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, guideId)
  return newSeasonRed
end
function UnknowPassEasyTicketSystem.SetShowNewGuide()
  local guideId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_EasyTicketTips_Reddot
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, guideId, 1)
end
function UnknowPassEasyTicketSystem.BuyTicket()
  if UnknowPassEasyTicketSystem.TicketID == 0 then
    local level = UnknowPassEasyTicketSystem.GetCurrentTicketsLevel()
    if level == 0 then
      level = 1
    end
    if 3 <= level then
      level = 3
    end
    local tickets = UnknowPassEasyTicketSystem.GetTicketsConfig()
    local currentConfig = tickets[level]
    if currentConfig then
      do
        local price = currentConfig.price
        local itemName = LocUtil.LocalizeResFormat(7012, UnknowPassSystem.Season)
        itemName = LocUtil.LocalizeResFormat(7021)
        local content
        if price == 0 then
          content = LocUtil.LocalizeResFormat(7013, itemName)
        else
          content = LocUtil.LocalizeResFormat(29619, price, itemName)
        end
        UnknowPassEasyTicketSystem._ShowBuyTip(LocUtil.GetLocalizeResStr("301185"), content, function()
          if price ~= 0 and price > DataMgr.ticket then
            local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
            if LogicTxMissionMain.IsInXMission() then
              ShowNotice(502006)
              return
            end
            local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
            CommonPayBoxMgr.ShowUcRechargeMsg(price)
            return
          end
          local PassHander = require("client.network.Protocol.PassHander")
          PassHander.send_upass_buy_play_card_req(currentConfig.id)
        end, price ~= 0)
      end
    end
  else
    local name = CDataTable.GetTableData("Item", UnknowPassEasyTicketSystem.TicketID).ItemName
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr("301185"), LocUtil.LocalizeResFormat("9764", name, 1, LocUtil.GetLocalizeResStr(7021)), function()
      local PassHander = require("client.network.Protocol.PassHander")
      PassHander.send_upass_buy_play_card_req(UnknowPassEasyTicketSystem.TicketBuyID)
    end)
  end
end
function UnknowPassEasyTicketSystem.OnBuyTicket()
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_RPCard()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
  UpassHandle.send_general_task_sync_all_req()
end
function UnknowPassEasyTicketSystem.GetTaskCardAwards()
  local PassHander = require("client.network.Protocol.PassHander")
  PassHander.send_upass_play_card_weekly_reward_req()
end
function UnknowPassEasyTicketSystem.OnGetTaskTicket(rewards)
  log_tree("rewards", rewards)
  local allData = {}
  for i, v in pairs(rewards) do
    local data = {}
    data.res_id = v.item_id
    data.count = v.item_num
    data.valid_hours = 0
    data.expire_time = 0
    table.insert(allData, data)
  end
  if next(allData) then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(allData)
  end
  local TimeUtil = require("client.common.time_util")
  if nil == UnknowPassSystem.Data.play_card then
    local play_card = {
      reward_time = TimeUtil.GetServerTimeInSec()
    }
    UnknowPassSystem.Data.  else
    UnknowPassSystem.Data.play_card.reward_time = TimeUtil.GetServerTimeInSec()
  end
  local num = 2
  if rewards[1] and rewards[1].item_num then
    num = rewards[1].item_num
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EASY_TICKETS_TASK_UPDATE)
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_general_task_sync_all_req()
end
function UnknowPassEasyTicketSystem.is_same_pass_week(time1, time2)
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  if not cfg then
    return
  end
  local week1 = (time1 - cfg.begin_timestamp + 604800 - 1) // 604800
  local week2 = (time2 - cfg.begin_timestamp + 604800 - 1) // 604800
  return week1 == week2
end
function UnknowPassEasyTicketSystem.GetEighthWeekStartTime()
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  if not cfg then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.GetServerTimeInSec() + 4233600
  end
  return cfg.begin_timestamp + 4233600
end
function UnknowPassEasyTicketSystem._ShowBuyTip(title, content, callback, isNeedPolicy)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local msgData = {
    styleType = 2,
    title = title,
    msg = content,
    clickOkCallback = callback
  }
  CommonMsgBoxMgr.ShowUSPolicyTip(msgData, nil, not isNeedPolicy)
end
return UnknowPassEasyTicketSystem