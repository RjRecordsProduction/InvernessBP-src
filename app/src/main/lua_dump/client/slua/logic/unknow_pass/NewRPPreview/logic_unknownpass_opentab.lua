local UnknowPassOpenUISystem = {
  openFrom = 0,
  isJumpClose = false,
  isJumpBack = false,
  isExperienceUI = false,
  isOpenBranchAward = false,
  awardPanelType = {
    RpAward = 1,
    BpAward = 2,
    XYearBox = 3
  }
}
local E_JumpTab = {
  Award = 1,
  Exchange = 2,
  ReturnExchange = 3,
  TaskPanel = 4,
  SubwayExchange = 5,
  BackBox = 6,
  RPRecord = 7,
  RPRank = 8
}
UnknowPassOpenUISystem.local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
local E_TabType = PassDataSystem.GetTabType()
local tabTypeToJumpType = {
  [E_TabType.award] = E_JumpTab.Award,
  [E_TabType.mission] = E_JumpTab.TaskPanel,
  [E_TabType.exchange] = E_JumpTab.Exchange,
  [E_TabType.rank] = E_JumpTab.RPRank,
  [E_TabType.subExchange] = E_JumpTab.SubwayExchange
}
function UnknowPassOpenUISystem.JumpToDepot()
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassTunnelSystem.CloseRP(true)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new:Enter(wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar, wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit)
end
function UnknowPassOpenUISystem.JumpToPass(jumpinfo)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassTunnelSystem.ShowRP(jumpinfo)
  ClientSendBAReport(TLogEventDefine.JumpToUnKnowPass, 0)
end
function UnknowPassOpenUISystem.JumpPassInternal(jumpInfo)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    log(bWriteLog and "[v_wllwu] UnknowPassOpenUISystem.JumpPassInternal\239\188\140RP is Show and run jumpinfo")
    UnknowPassTunnelSystem.    UnknowPassOpenUISystem.JumpInToRPTab()
    return
  end
  UnknowPassTunnelSystem.ShowRP(jumpInfo)
end
function UnknowPassOpenUISystem.SetIsOpenBonusPassAward(bIsOpen)
  UnknowPassOpenUISystem.isOpenBranchAward = bIsOpen
end
function UnknowPassOpenUISystem.GetIsOpenBonusPassAward()
  return UnknowPassOpenUISystem.isOpenBranchAward
end
function UnknowPassOpenUISystem.GetJumpTabByTabType(tabType)
  return tabTypeToJumpType[tabType] or 1
end
function UnknowPassOpenUISystem.JumpInToRPTab(bIsJumpBack)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local Tab1 = UnknowPassTunnelSystem.jumpInfo and UnknowPassTunnelSystem.jumpInfo.Tab1 or 0
  log(bWriteLog and "[ZH] Tab1: " .. tostring(Tab1))
  if Tab1 ~= E_TabType.award and Tab1 ~= 0 then
    if UnknowPassOpenUISystem.isJumpBack then
      UnknowPassOpenUISystem.OpenTab(Tab1)
    else
      local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
      local time_ticker = require("common.time_ticker")
      UnknowPassTunnelSystem.JumpTimer = time_ticker.AddTimerOnce(UnknowPassMacro.ENUM_Timer.Main.jumpTimer, function()
        UnknowPassOpenUISystem.OpenTab(Tab1)
      end)
    end
  else
    PassDataSystem.SetCurTab(E_TabType.award)
    local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
    UnknowPassAwardSystem.OpenAwardUI(not bIsJumpBack)
    local panelType = PassDataSystem.GetPanelType()
    local curPanel = PassDataSystem.GetCurRpPanelType()
    if curPanel ~= panelType.BranchRp then
      UnknowPassAwardSystem.bIsFirstOpenAward = false
    end
  end
end
function UnknowPassOpenUISystem.GoToRPAward(isNeedGet, jumpinfo)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if not UnknowPassTunnelSystem.isShowRP then
    if isNeedGet then
      UnknowPassSystem.isNeedGetAllAward = true
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_AWARD_TRIGGER)
    UnknowPassTunnelSystem.ShowRP(jumpinfo)
  else
    if not UIManager.GetUI(UIManager.UI_Config.unknowpass_award) then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
      local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
      PassPreviewSystem.StopAction()
      local OpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
      OpenUISystem.OpenAward()
    else
      local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
      UnknowPassAwardSystem.SwitchToAwardPanel()
    end
    if isNeedGet then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GETALL_AWARD)
    end
  end
end
function UnknowPassOpenUISystem.OpenTab(TabType)
  local OpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  if TabType == E_JumpTab.TaskPanel then
    OpenUISystem.OpenMission()
  elseif TabType == E_JumpTab.SubwayExchange then
    OpenUISystem.OpenSubwayExchange()
  elseif TabType == E_JumpTab.Exchange then
    OpenUISystem.OpenExchange()
  else
    if TabType == E_JumpTab.RPRank then
      OpenUISystem.OpenRank()
    else
    end
  end
end
function UnknowPassOpenUISystem.CheckAndCloseTab(TabType)
  local curTab = E_TabType.curTab
  if TabType and TabType == curTab then
    return false
  end
  if curTab == E_TabType.award then
    local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
    UnknowPassAwardSystem.CloseAwardUI()
  elseif curTab == E_TabType.exchange then
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.AvatarClearEquip()
    local exchangeLogic = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
    exchangeLogic.CloseExchangeUI()
  elseif curTab == E_TabType.mission then
    local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
    UnknowPassMissionSystem.CloseNewMissionUI()
  elseif curTab == E_TabType.rank then
    local RankSystem = require("client.slua.logic.unknow_pass.rank.logic_unknowpass_rank")
    RankSystem.ClosePassRankUI()
  end
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassTunnelSystem.UpdateCameraAndBg(true)
  log(bWriteLog and "[ZH] current click TabType: " .. tostring(TabType))
  PassDataSystem.SetCurTab(TabType)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB, TabType)
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  Lobby_camera_manager_module:ZoomOutLobbyCamera(ModelDisplayer.GetShowingAvatar(), UnknowPassMacro.UnknowPass_CameraId)
  return true
end
function UnknowPassOpenUISystem.CloseOtherExceptTab(TabType)
  if TabType ~= E_TabType.award then
    local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
    UnknowPassAwardSystem.CloseAwardUI()
  end
  if TabType ~= E_TabType.exchange then
    local exchangeLogic = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
    exchangeLogic.CloseExchangeUI()
  end
  if TabType ~= E_TabType.mission then
    local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
    UnknowPassMissionSystem.CloseNewMissionUI()
  end
  if TabType ~= E_TabType.rank then
    local RankSystem = require("client.slua.logic.unknow_pass.rank.logic_unknowpass_rank")
    RankSystem.ClosePassRankUI()
  end
end
function UnknowPassOpenUISystem.OpenAward()
  local TabType = E_TabType.award
  if not UnknowPassOpenUISystem.CheckAndCloseTab(TabType) then
    return
  end
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  UnknowPassAwardSystem.OpenAwardUI(false)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassAward)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassAward)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.SetEncoreBoxJumpReturn(false)
end
function UnknowPassOpenUISystem.OpenMission()
  local TabType = E_TabType.mission
  if not UnknowPassOpenUISystem.CheckAndCloseTab(TabType) then
    return
  end
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.OpenNewMissionUI()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassMission)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassMission)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.SetEncoreBoxJumpReturn(false)
end
function UnknowPassOpenUISystem.OpenBranchMission()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_SHOW_AWARDUI, false)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_HIDE_TAB)
  UIManager.ShowUI(UIManager.UI_Config.BranchRP_Task_UIBP)
end
function UnknowPassOpenUISystem.CloseBranchMission()
  PassDataSystem.SetCurTab(E_TabType.award)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_SHOW_AWARDUI, true)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_TAB)
end
function UnknowPassOpenUISystem.OpenExchange()
  local TabType = E_TabType.exchange
  if not UnknowPassOpenUISystem.CheckAndCloseTab(TabType) then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_INNER_JUMP)
    return
  end
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local jumpInfo = UnknowPassTunnelSystem.jumpInfo
  if UnknowPassSystem.Season >= 59 then
    if jumpInfo and jumpInfo.panelType and jumpInfo.panelType == UnknowPassOpenUISystem.awardPanelType.XYearBox then
      local Logic_RP_EncoreBox = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_RP_EncoreBox)
      Logic_RP_EncoreBox:send_get_rp_custom_chest_data_req()
    end
  elseif jumpInfo and jumpInfo.panelType and jumpInfo.panelType == UnknowPassOpenUISystem.awardPanelType.XYearBox then
    local Logic_RP_EncoreBox = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_RP_EncoreBox)
    Logic_RP_EncoreBox:send_get_rp_custom_chest_data_req()
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_EncoreBoxLottery_Old_UIBP)
    return
  end
  local exchangeLogic = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  exchangeLogic.OpenExchangeUI()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassExchange)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassExchange)
end
function UnknowPassOpenUISystem.OpenSubwayExchange()
  local TabType = E_TabType.subExchange
  if not UnknowPassOpenUISystem.CheckAndCloseTab(TabType) then
    return
  end
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.upass_exchange_list_req()
  local subwayLogic = require("client.slua.logic.unknow_pass.logic_unknowpass_subway")
  subwayLogic.OpenSubwayExchnageUI()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassSubwayExchange)
end
function UnknowPassOpenUISystem.OpenRank()
  local TabType = E_TabType.rank
  if not UnknowPassOpenUISystem.CheckAndCloseTab(TabType) then
    return
  end
  local RankSystem = require("client.slua.logic.unknow_pass.rank.logic_unknowpass_rank")
  RankSystem.OpenPassRankUI()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassRank)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassRank)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.SetEncoreBoxJumpReturn(false)
end
function UnknowPassOpenUISystem.OPenBuy()
  local UnknowPassBuySyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySyetem.OpenBuyUI()
end
function UnknowPassOpenUISystem.NewSeason()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  UIManager.ShowUI(UIManager.UI_Config.UPassIntroduceUIBP, true)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassPlayAnimation)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassPlayAnimation)
end
function UnknowPassOpenUISystem.OpenScoreCardUseUI()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_DecomposePopups_UIBP)
  end
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassUseScoreCard)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassUseScoreCard)
end
function UnknowPassOpenUISystem.CloseScoreCardUseUI()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.unknowpass_DecomposePopups_UIBP)
  end
end
function UnknowPassOpenUISystem.PlayPassVideo()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local videoPath = ""
  local season = UnknowPassMacro.UnKnowPass_NextSeason - 1
  local cfg = CDataTable.GetTableData("UnknowPassSeasonResource", season)
  videoPath = cfg.IntroVideo
  if VideoLibrary.IsCanPlayVideo() then
    VideoLibrary.PlayVideo(videoPath, {bRestoreLobbyMusic = false})
  end
end
function UnknowPassOpenUISystem.CloseSecUIWhenJumpInSide()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UPASS_ACT)
  UnknowPassUtil.CheckCloseUI(UIManager.UI_Config.UnknowPass_RecordPreview_UIBP)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_CLOSE_BUYLEVEL)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_CLOSE_COREAWARD)
end
function UnknowPassOpenUISystem.OpenExtraScoreUI()
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_Award_New_Popup_UIBP)
end
return UnknowPassOpenUISystem