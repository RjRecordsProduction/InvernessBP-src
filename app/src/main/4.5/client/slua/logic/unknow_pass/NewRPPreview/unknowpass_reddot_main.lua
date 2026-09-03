local UnknowPassReddotSystem = {
  showDayReddot = false,
  showAwardReddot = false,
  showWeekAward = false,
  isNotHaveExDate = false,
  jumpBoxID = nil,
  ShowMissionReddot = false,
  AwardReddot = false,
  FirstWeek_Reddot = false,
  FirstWeek_Reddot_New = false,
  EasyTickets_Reddot = false,
  Exchange_Reddot = false,
  Privilege_Reddot = false,
  Subscription_Reddot = false,
  Subscription_MonthReddot = false,
  Subscription_ContinuousReddot = false,
  Bonus_Pass_Award_Reddot = false,
  Bonus_Pass_Task_Reddot = false
}
function UnknowPassReddotSystem.UpdateReddot()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local newSeasonredId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_ExtraScoreSeason_New
  local newSeasonRed = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, newSeasonredId)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local extraScoreCanGet = PassDataSystem.CheckExtraScoreCanGet()
  local excellentReddot = extraScoreCanGet == 2 and newSeasonRed or extraScoreCanGet == 1
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local hasUpgradeCard = UnknowPassBuySystem.HasUpgradeCard()
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassReddotSystem.showAwardReddot = UnknowPassAwardSystem.HasCanGetReward(UnknowPassTunnelSystem.bIsBattleBackToLobby)
  UnknowPassReddotSystem.AwardReddot = UnknowPassReddotSystem.showAwardReddot or hasUpgradeCard or excellentReddot
  UnknowPassTunnelSystem.bIsBattleBackToLobby = false
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  UnknowPassReddotSystem.Bonus_Pass_Award_Reddot = Logic_BonusPass:IsHasRewardCanReceive()
  UnknowPassReddotSystem.Bonus_Pass_Task_Reddot = Logic_BonusPass:IsCanReceiveTaskReward()
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassReddotSystem.UpdateExchangeReddot()
  UnknowPassReddotSystem.UpdateFirstAwardReddot()
  UnknowPassReddotSystem.UpdateEasyTicketReddot()
  UnknowPassReddotSystem.UpdatePrivilegeReddot()
  UnknowPassReddotSystem.ShowMissionReddot = UnknowPassMissionSystem.RefreshWeekTabRedDot() or excellentReddot
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_MAINTAB_REDDOT, UnknowPassReddotSystem.AwardReddot or UnknowPassReddotSystem.Bonus_Pass_Award_Reddot, UnknowPassReddotSystem.ShowMissionReddot or UnknowPassReddotSystem.EasyTickets_Reddot, UnknowPassReddotSystem.Exchange_Reddot)
  local subwaySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subway")
  local type = subwaySystem.localSaveType.labelReddot
  local isshow = false
  if not subwaySystem.IsLocalSaveTipsData(type, UnknowPassSystem.Season) then
    isshow = true
  end
  PassDataSystem.UpdateUnknowPassReddot(isshow)
  local UnknowPassRedPointData = require("client.slua.logic.unknow_pass.RedPoint.unknowpass_redpoint_data")
  UnknowPassRedPointData.AddAllRedPointData()
  local RPtaskRedPointData = require("client.slua.logic.unknow_pass.RedPoint.RPtask_redpoint_data")
  RPtaskRedPointData.AddAllRedPointData()
  if not UnknowPassSystem.IsInCurSession then
    local redpoint = UnknowPassRedPointData.GetRedPointSuperData()
    if redpoint then
      redpoint.newCount = 0
    end
  end
end
function UnknowPassReddotSystem.CanShowReddot()
  local bShow = UnknowPassReddotSystem.ShowMissionReddot or UnknowPassReddotSystem.AwardReddot or UnknowPassReddotSystem.FirstWeek_Reddot or UnknowPassReddotSystem.EasyTickets_Reddot or UnknowPassReddotSystem.Exchange_Reddot or UnknowPassReddotSystem.Subscription_Reddot or UnknowPassReddotSystem.Privilege_Reddot or UnknowPassReddotSystem.Bonus_Pass_Award_Reddot or UnknowPassReddotSystem.Bonus_Pass_Task_Reddot
  return bShow
end
function UnknowPassReddotSystem.ShowReddotType()
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local RPCrtScoreSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_crt_score")
  local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket")
  if UnknowPassAwardSystem.HasCanGetReward() or UnknowPassReddotSystem.showWeekAward or UnknowPassEasyTicketSystem.HasRewardsReddot then
    return 1
  else
    return 0
  end
end
function UnknowPassReddotSystem.UpdateFirstAwardReddot(hideReddot, hideSecReddot)
  local TimeUtil = require("client.common.time_util")
  local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards")
  local isInFirstWeek = UnknowPassRankFirstWeekAwardsSystem.InFirstWeek()
  local redId = 0
  local newSeasonVaild = false
  local firstAwardsVaild = false
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  if not isInFirstWeek then
    redId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_AwardsNewSeason_Reddot
    local endTime = UnknowPassRankFirstWeekAwardsSystem.GetFirstWeekRankEndTime()
    firstAwardsVaild = TimeUtil.InDaysFrom(endTime, 7)
  else
    redId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_AwardsFirstWeek_Reddot
  end
  UnknowPassReddotSystem.FirstWeek_Reddot_New = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, redId) and (newSeasonVaild or firstAwardsVaild)
  UnknowPassReddotSystem.FirstWeek_Reddot = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_RecordNew_Reddot) or UnknowPassReddotSystem.FirstWeek_Reddot_New
  if UnknowPassReddotSystem.FirstWeek_Reddot and hideReddot and not hideSecReddot then
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_RecordNew_Reddot)
    UnknowPassReddotSystem.FirstWeek_Reddot = UnknowPassReddotSystem.FirstWeek_Reddot_New
  end
  if UnknowPassReddotSystem.FirstWeek_Reddot_New and hideSecReddot then
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, redId)
    UnknowPassReddotSystem.FirstWeek_Reddot_New = false
    UnknowPassReddotSystem.FirstWeek_Reddot = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_RecordNew_Reddot)
  end
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    if UnknowPassReddotSystem.FirstWeek_Reddot then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_FIRSTWEEK_REDDOT, true)
    else
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_FIRSTWEEK_REDDOT, false)
    end
  end
end
function UnknowPassReddotSystem.UpdateEasyTicketReddot(hideReddot)
  local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket")
  UnknowPassReddotSystem.EasyTickets_Reddot = UnknowPassEasyTicketSystem.UpdateRedPoint(hideReddot)
  if UnknowPassReddotSystem.EasyTickets_Reddot then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EASYTICKET_REDDOT, true)
  else
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EASYTICKET_REDDOT, false)
  end
end
function UnknowPassReddotSystem.UpdatePrivilegeReddot(value)
  local privilegeReddot = value
  UnknowPassReddotSystem.Privilege_Reddot = privilegeReddot
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    if privilegeReddot then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_PRIVILEGE_REDDOT, true)
    else
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_PRIVILEGE_REDDOT, false)
    end
  end
end
function UnknowPassReddotSystem.UpdateExchangeReddot(isHide)
  if not UnknowPassReddotSystem.isNotHaveExDate then
    return
  end
  local exchangeSyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassReddotSystem.Exchange_Reddot = exchangeSyetem.UpdateRedPoint(isHide) or UnknowPassBuySystem.HasUpgradeCard()
  local tab = {}
  tab.itemId = UnknowPassReddotSystem.jumpBoxID
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_DEFAULT_WEAR, tab)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassReddotSystem.jumpBoxID = nil
  UnknowPassTunnelSystem.jumpInfo = nil
  UnknowPassReddotSystem.isNotHaveExDate = false
end
function UnknowPassReddotSystem.SetUpassBuyReddot(isShow)
  log(bWriteLog and "UnknowPassUI.SetUpassBuyReddot" .. tostring(isShow))
  UnknowPassReddotSystem.isShowUpassBuyReddot = isShow
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUYUPASS_REDDOT, isShow)
  end
end
function UnknowPassReddotSystem.InfoUpdate()
  log(bWriteLog and "UnknowPassReddotSystem.InfoUpdate UpdateUpassReddot")
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    UnknowPassReddotSystem.SetUpassBuyReddot(UnknowPassReddotSystem.isShowUpassBuyReddot)
  end
  UnknowPassReddotSystem.UpdateReddot()
end
return UnknowPassReddotSystem