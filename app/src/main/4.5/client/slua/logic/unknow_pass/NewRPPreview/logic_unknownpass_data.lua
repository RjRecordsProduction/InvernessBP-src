BP_UnknowPass_Mission_NotFinish = 0
BP_UnknowPass_Mission_Finished = 1
BP_UnknowPass_Mission_HasGet = 2
BP_UnknowPass_Mission_Expired = 3
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local UnknownPassDataSystem = {
  UCAndDiamondShowType = 3,
  UCAndDiamondIconId = 1110,
  UCAndDiamondIconId2 = 1112,
  UCAndDiamondIconId3 = 1113,
  UCAndDiamondIconId4 = 1114,
  UCAndDiamondIconId5 = 1116,
  UCAndDiamondIconId6 = 1117,
  rp_extra_score = {},
  nHighScoreLastReqTime = 0,
  is_experience = 0,
  experience_level = 0,
  nUCCountLackTip = 0,
  CurRpPanel = 0,
  tThrowCouponList = {},
  tPercentCouponIdList = {},
  tSeasonIdList = {
    59,
    60,
    61
  },
  tRpResourceDownloadList = nil,
  tPrivilegeConfig = nil,
  tPrivilegeSeason = nil
}
local E_PassUIName = {
  "unknowpass_award",
  "unknowpass_exchange",
  "UnknowPass_Exchange_New_BP",
  "UnknowPass_EncoreBoxLottery_New_UIBP",
  "unknowpass_mission_sec",
  "UnknowPass_Award_Branch_BP",
  "unknowpass_toy_get",
  "BranchRP_Task_UIBP"
}
local reloginCantColseUI = {
  unknowpass_award = true,
  unknowpass_exchange = true,
  Lobby_UnknowPass_UIBP_1_0_0 = true,
  activity_buy_upass = true,
  UnknowPass_Award_Branch_BP = true,
  BranchRP_Task_UIBP = true,
  unknowpass_branch_award_buyscore = true
}
function UnknownPassDataSystem.GetPassUI()
  return E_PassUIName
end
function UnknownPassDataSystem.GetReloginCantColseUI()
  return reloginCantColseUI
end
local E_TabType = {
  curTab = 0,
  none = 0,
  award = 1,
  mission = 2,
  exchange = 3,
  rank = 4,
  subExchange = 5,
  RPRecord = 7
}
local ENUM_RewardPanelType = {MainRp = 1, BranchRp = 2}
function UnknownPassDataSystem.GetTabType()
  return E_TabType
end
function UnknownPassDataSystem.SetCurTab(tabtype)
  E_TabType.curTab = tabtype or 0
end
function UnknownPassDataSystem.GetCurTab()
  return E_TabType.curTab or 0
end
function UnknownPassDataSystem.GetPanelType()
  return ENUM_RewardPanelType
end
function UnknownPassDataSystem.SetCurPanelType(panelType)
  UnknownPassDataSystem.CurRpPanel = panelType or 0
end
function UnknownPassDataSystem.GetCurRpPanelType()
  return UnknownPassDataSystem.CurRpPanel or 0
end
function UnknownPassDataSystem.TurnToRPAwardPanel()
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassTunnelSystem.jumpInfo = nil
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local panelType = PassDataSystem.GetPanelType()
  PassDataSystem.SetCurPanelType(panelType.MainRp)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_VALUETASK_BUTTON)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_TASK_UPDATE_ANNUAL)
  local mainRp = UIManager.GetUI(UIManager.UI_Config.unknowpass_award)
  local branchRp = UIManager.GetUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP)
  if branchRp then
    branchRp:Collapsed()
  end
  if mainRp then
    UnknowPassTunnelSystem.UpdateCameraAndBg(true)
    mainRp:SelfHitTestInvisible()
  else
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    local ver = UnknowPassUtil.GetVersionNumber()
    local bpPath = string.format("/Game/Arts_UI/UnknowPass/%s/UIBP_Main/UnknowPass_Award_New_BP.UnknowPass_Award_New_BP", ver)
    UIManager.ShowUIWithBpPath(UIManager.UI_Config.unknowpass_award, bpPath)
    local time_ticker = require("common.time_ticker")
    local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
    time_ticker.AddTimerOnce(UnknowPassMacro.ENUM_Timer.Main.requestTimer, function()
      PassDataSystem.upass_get_req()
    end)
  end
end
function UnknownPassDataSystem.TurnToBPAwardPanel()
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local panelType = PassDataSystem.GetPanelType()
  PassDataSystem.SetCurPanelType(panelType.BranchRp)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_VALUETASK_BUTTON)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_TASK_UPDATE_ANNUAL)
  local mainRp = UIManager.GetUI(UIManager.UI_Config.unknowpass_award)
  local branchRp = UIManager.GetUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP)
  if mainRp then
    mainRp:Collapsed()
  end
  if branchRp then
    branchRp:SelfHitTestInvisible()
    UnknowPassAwardSystem.bIsFirstOpenBonus = false
  else
    local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
    Logic_BonusPass:InitBonusPassConfig()
    local seasonInfo = Logic_BonusPass:GetBranchSeasonData()
    if seasonInfo and seasonInfo.seasonID == UnknowPassSystem.Season then
      local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
      local ver = UnknowPassUtil.GetVersionNumber()
      local bpPath = string.format("/Game/Arts_UI/UnknowPass/%s/UIBP_Main/UnknowPass_Award_Branch_BP.UnknowPass_Award_Branch_BP", ver)
      UIManager.ShowUIWithBpPath(UIManager.UI_Config.UnknowPass_Award_Branch_BP, bpPath)
    end
    UnknowPassAwardSystem.bIsFirstOpenBonus = false
  end
end
local E_leftItemType = {
  curItemType = 0,
  none = 0,
  upgradeUI = 1,
  model = 2,
  icon = 3,
  plating = 4
}
function UnknownPassDataSystem.GetLeftAllType()
  return E_leftItemType
end
function UnknownPassDataSystem.SetCurItemType(tabtype)
  E_TabType.curItemType = tabtype or 0
end
function UnknownPassDataSystem.GetCurItemType()
  return E_TabType.curItemType or 0
end
function UnknownPassDataSystem.ShowRPDownloadTips()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() == ENUM_DownloadState.Done then
    return false
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local size = string.format("%.2f", PassDataSystem.GetRPResDownloadSize())
  local askTips = LocUtil.LocalizeResFormat(23950, size)
  local ok = function()
    PassDataSystem.DownloadRPRes()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, askTips, ok)
  return true
end
function UnknownPassDataSystem.DownloadRPRes(b4GNotDownload)
  local list = UnknownPassDataSystem.GetRpResourceDownloadList()
  local extraData = {bAutoDownload = b4GNotDownload, bSkipPopUp = true}
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, list, nil, nil, extraData)
end
function UnknownPassDataSystem.GetRPResDownloadSize()
  local list = UnknownPassDataSystem.GetRpResourceDownloadList()
  local size = 0
  local _, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, list)
  size = totalSize / PufferConst.MB
  log(bWriteLog and "UnknowPassSystem.GetRPResDownloadSize size = " .. tostring(size))
  return size
end
function UnknownPassDataSystem.GetRpResourceDownloadList()
  if UnknownPassDataSystem.tRpResourceDownloadList then
    return UnknownPassDataSystem.tRpResourceDownloadList
  end
  local tResourcesList = {}
  local defaultPakName = PufferManager.GetPakName("/Game/Arts_UI/UnknowPass/Common/0_10_5/Atlas/Frames/Battlepass_di_png.Battlepass_di_png")
  table.insert(tResourcesList, defaultPakName)
  local sBasePath = "/Game/Arts_UI/UnknowPass/%s/UIBP_Main/UnknowPass_Award_New_BP.UnknowPass_Award_New_BP"
  for _, seasonId in ipairs(UnknownPassDataSystem.tSeasonIdList) do
    local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", seasonId)
    if cfg and cfg.SeasonEndTime and cfg.SeasonEndTime ~= "" then
      local resourcePath = string.format(sBasePath, cfg.ResourseVerion)
      local pakName = PufferManager.GetPakName(resourcePath)
      if pakName and pakName ~= "" then
        table.insert(tResourcesList, pakName)
      end
    end
  end
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  for _, seasonId in pairs(UnknownPassDataSystem.tSeasonIdList) do
    local tRPSeasonCfg = CDataTable.GetTableData("UnknowpassRecordSeasonCfg", seasonId)
    if tRPSeasonCfg and tRPSeasonCfg.SeasonScene and tRPSeasonCfg.SeasonScene ~= "" then
      local ScenePath = LobbySceneModule:GetStreamLevelFullPathByName(tRPSeasonCfg.SeasonScene)
      local pakName = PufferManager.GetPakName(ScenePath)
      if pakName and pakName ~= "" then
        table.insert(tResourcesList, pakName)
      end
    end
    local tBPSeasonCfg = CDataTable.GetTableDataByFilter("BranchSeasonControl", "SeasonID", seasonId)
    if tBPSeasonCfg and tBPSeasonCfg.SeasonScene and tBPSeasonCfg.SeasonScene ~= "" then
      local ScenePath = LobbySceneModule:GetStreamLevelFullPathByName(tBPSeasonCfg.SeasonScene)
      local pakName = PufferManager.GetPakName(ScenePath)
      if pakName and pakName ~= "" then
        table.insert(tResourcesList, pakName)
      end
    end
  end
  local pakName = PufferManager.GetPakName("/Game/Arts_UI/FromUMG/UnknowPass/Lobby_UnknowPass_UIBP.Lobby_UnknowPass_UIBP")
  table.insert(tResourcesList, pakName)
  log_tree("UnknownPassDataSystem.GetRpResourceDownloadList", tResourcesList)
  UnknownPassDataSystem.tRpResourceDownloadList = tResourcesList
  return tResourcesList
end
function UnknownPassDataSystem.GetRpResourceDownloadSize()
  local list = UnknownPassDataSystem.GetRpResourceDownloadList()
  local _, size = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, list)
  log(bWriteLog and "UnknowPassSystem.GetRPResDownloadSize size = " .. tostring(size))
  return size
end
function UnknownPassDataSystem.GetRpResourceDownloadState()
  if not UnknowPassSystem.IsInCurSession then
    return ENUM_DownloadState.Done
  end
  local list = UnknownPassDataSystem.GetRpResourceDownloadList()
  return PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, list)
end
function UnknownPassDataSystem.GetRpGroupDownloadList()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ver = UnknowPassUtil.GetVersionNumber()
  local sBpPath = string.format("/Game/Arts_UI/UnknowPass_BannerActivity/%s/RP_GroupBuy/UnknowPass_GroupBuy_UIBP.UnknowPass_GroupBuy_UIBP", ver)
  return {
    sBpPath,
    PufferConst.ActivityAudioItemID
  }
end
function UnknownPassDataSystem.GetRpGroupDownloadState()
  local list = UnknownPassDataSystem.GetRpGroupDownloadList()
  return PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, list)
end
function UnknownPassDataSystem.ShowRpGroupDownloadTips()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpGroupDownloadState() == ENUM_DownloadState.Done then
    return false
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local size = string.format("%.2f MB", PassDataSystem.GetRpGroupDownloadSize())
  local askTips = LocUtil.LocalizeResFormat(7921, size)
  local ok = function()
    PassDataSystem.DownloadRpGroup()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, askTips, ok)
  return true
end
function UnknownPassDataSystem.DownloadRpGroup()
  local list = UnknownPassDataSystem.GetRpGroupDownloadList()
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, list, nil, nil)
end
function UnknownPassDataSystem.GetRpGroupDownloadSize()
  local list = UnknownPassDataSystem.GetRpGroupDownloadList()
  local size = 0
  local _, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, list)
  size = totalSize / PufferConst.MB
  log(bWriteLog and "UnknownPassDataSystem.GetRpGroupDownloadSize size = " .. tostring(size))
  return size
end
function UnknownPassDataSystem.SetSeasonStatus(season_info)
  local TableUtil = require("common.table_util")
  if TableUtil.IsDataEqual(UnknowPassSystem.SeasonInfo, season_info) then
    return
  end
  UnknowPassSystem.SeasonInfo = season_info
  UnknowPassSystem.IsInCurSession = season_info.in_cur_season
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  UnknowPassMacro.UnKnowPass_NextSeason_HasSet = false
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  UnknowPassUtil.GetUnknowPassNextSeason()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    local xmission_rp = UIManager.GetUI(UIManager.UI_Config.xmission_rp)
    if xmission_rp then
      xmission_rp:ShowUnknowPassSeasonLock(UnknowPassSystem.IsInCurSession)
      xmission_rp:StartUnknowPassNextLastTimer()
    end
    return
  end
  season_info.cfg.show_time = GlobalData.AddUTCSubffix(season_info.cfg.show_time, true)
  local seasonTime = UnknowPassUtil.GetPeriodText()
  local RankSystem = require("client.slua.logic.unknow_pass.rank.logic_unknowpass_rank")
  RankSystem.sSeasonName = season_info.cfg.season_name
  RankSystem.sSeasonTime = seasonTime
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_RECEIVED, season_info.index)
end
function UnknownPassDataSystem.UpdateSelectEmotion(map, got)
  local t = ""
  local list = {}
  for i, v in ipairs(map) do
    local Cfg = CDataTable.GetTableData("Item", v)
    if i < #map then
      t = t .. Cfg.ItemName .. "\227\128\129"
    else
      t = t .. Cfg.ItemName
    end
    local logic_unknowpass_buy = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    local awardList = logic_unknowpass_buy.GetAwardInfoBySeason()
    local num = 1
    for _, value in ipairs(awardList) do
      if tonumber(value.ID) == tonumber(v) then
        num = tonumber(value.Num)
        break
      end
    end
    local info = {
      res_id = v,
      count = num,
      valid_hours = 0
    }
    table.insert(list, info)
  end
  UnknowPassSystem.EmtionData.  UnknowPassSystem.EmtionData.motions = map
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EMOTION_SELECT_DATA, map)
  if UnknowPassSystem.PassType == 2 and got then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(list)
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    passReddotMainSystem.UpdatePrivilegeReddot(false)
    local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
    local UnknowPassRedPointData = require("client.slua.logic.unknow_pass.RedPoint.unknowpass_redpoint_data")
    UnknowPassRedPointData.RemoveRedPointData(UnknowPassMacro.ENUM_REDDOT.MOTION_CARD)
  else
    local str = LocUtil.LocalizeResFormat(21151, t)
    ShowNotice(str)
  end
end
function UnknownPassDataSystem.upass_buy_score_req(diff_score, cur_level, cur_score, couponid, vouchers, nCurPrice)
  local ID
  if couponid then
    local tBuyCfg = CDataTable.GetTableDataByFilter("UnknowPassCouponCfg", "SeasonID", UnknowPassSystem.Season, "CouponID", couponid)
    if tBuyCfg then
      ID = tBuyCfg.ID
    end
  end
  log(bWriteLog and "UnknowPassSystem.upass_buy_score_rsp " .. (ID or "!"))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  UnknownPassDataSystem.nUCCountLackTip = nCurPrice or diff_score or 0
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_buy_score_req(diff_score, cur_level, cur_score, tonumber(ID), vouchers)
end
function UnknownPassDataSystem.upass_buy_score_rsp(res, score_add, price_cost, upass_score, upass_level, before_level)
  log(bWriteLog and "UnknowPassSystem.upass_buy_score_rsp, received upass_buy_score_rsp, res = " .. tostring(res))
  if res ~= 0 then
    if res == 502006 then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(UnknownPassDataSystem.nUCCountLackTip)
    else
      ShowNotice(res)
    end
  else
    UnknowPassSystem.Level = upass_level
    UnknowPassSystem.Score = upass_score
    UnknowPassSystem.BuyBeforeLevel = before_level
    local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    UnknowPassBuySystem.ReportBuyEvent(false, true, false, score_add)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_SCORE)
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.upass_get_req()
  end
end
function UnknownPassDataSystem.UPassScoreNotifyChg(value, cur_score, cur_level, before_level, reason, pre_prize_score, total_collected_pre_prize_score, acc_score, isRewardClick, experience_level)
  log(bWriteLog and "UnknowPassLevelupSystem.OnAddScore111 " .. before_level .. " " .. cur_level)
  UnknowPassSystem.Level = cur_level
  UnknowPassSystem.Score = cur_score
  UnknowPassSystem.BuyBeforeLevel = before_level
  local UnknowPassGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  UnknowPassGiftSystem.on_upass_score_notify_chg(value, pre_prize_score, total_collected_pre_prize_score)
  if UnknowPassSystem.bSendBuyReq == false then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, reason, isRewardClick)
  end
  if UnknowPassSystem.Data and UnknowPassSystem.Data.base then
    UnknowPassSystem.Data.base.  end
  UnknownPassDataSystem.end
function UnknownPassDataSystem.SyncUpassScoreCardInfo(score, itemid, count, cur_score, cur_level)
  local msg = LocUtil.GetLocalizeResStr(4579)
  if msg then
    local str = string.format(msg, tostring(score))
    ShowNotice(str)
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_USE_SCORECARD)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.upass_get_req()
  end
end
function UnknownPassDataSystem.upass_notify_data_chg()
  UnknownPassDataSystem.UpdateUnknowPassReddot(true)
end
function UnknownPassDataSystem.UpdateUnknowPassReddot(isShow)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_LOBBYREDDOT, isShow)
end
function UnknownPassDataSystem.SetPassVideoDownload(widget, isLeft, ui)
  local videoPath = ""
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local seasonId = UnknowPassMacro.UnKnowPass_NextSeason - 1
  if not UnknowPassSystem.IsInCurSession then
    seasonId = UnknowPassMacro.UnKnowPass_NextSeason
  end
  local cfg = CDataTable.GetTableData("UnknowPassSeasonResource", seasonId)
  if not cfg then
    log(bWriteLog and "[v_wllwu] \232\191\153\228\184\170\232\181\155\229\173\163\232\191\152\230\178\161\230\156\137\233\133\141\231\189\174\232\167\134\233\162\145\228\191\161\230\129\175\239\188\140seasonId = " .. tostring(seasonId))
    return
  end
  videoPath = cfg.IntroVideo
  local common_download_handler = require("client.slua.common.common_download_handler")
  local params = {}
  params.hideMask = true
  params.size = 22
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {videoPath}, widget, params)
end
function UnknownPassDataSystem.CheckUpgradeTipsType()
  log(bWriteLog and "UnknowPassSystem.CheckUpgradeTipsType " .. UnknowPassSystem.UpgradeExtraLabel)
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  if UnknowPassBuySystem.HasUpgradeCard() then
    return UnknowPassMacro.ENUM_Pass_UpgradeTipsType.UpgradeCard
  end
  if UnknowPassSystem.GetKeeyBuy() >= 2 then
    return UnknowPassMacro.ENUM_Pass_UpgradeTipsType.KeepBuy
  end
  if UnknownPassDataSystem.CheckCouponBoxType(UnknownPassDataSystem.GetBuyExceptCouponMap()) or UnknowPassSystem.hasVoucher then
    return UnknowPassMacro.ENUM_Pass_UpgradeTipsType.HasCoupon
  end
  return UnknowPassMacro.ENUM_Pass_UpgradeTipsType.None
end
function UnknownPassDataSystem.CheckCouponBoxType(except_map)
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local CouponList = CouponSystem.GetChildCouponList(CouponSystem._Enum_Scene._UnknowPass, UnknowPassSystem.Season)
  if CouponList == nil or next(CouponList) == nil then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in pairs(CouponList) do
    local cacheItem = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(i)
    if (not except_map or not except_map[i]) and cacheItem ~= nil then
      return true
    end
  end
  return false
end
function UnknownPassDataSystem.ProcLoginSyncPassData(upass)
  log(bWriteLog and "[debug][enter_server] UnknownPassDataSystem.ProcLoginSyncPassData")
  UnknowPassSystem.IsBuyElite = upass.base and upass.base.is_buy == 1
  UnknowPassSystem.IsBuyEliteSeg2 = UnknowPassSystem.IsBuyElite and upass.base and upass.base.level_limit == nil
end
function UnknownPassDataSystem.GetBuyExceptCouponMap()
  local result = {}
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season)
  if not cfg then
    return
  end
  local wearCfg = cfg.RPScoreCoupon
  local StringUtil = require("common.string_util")
  local wearCfgTable = StringUtil.Split(wearCfg, ";")
  for k, v in pairs(wearCfgTable) do
    if tonumber(v) then
      result[tonumber(v)] = true
    end
  end
  return result
end
function UnknownPassDataSystem.CheckCouponType()
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local CouponList = CouponSystem.GetChildCouponList(CouponSystem._Enum_Scene._UnknowPass, UnknowPassSystem.Season)
  if CouponList == nil or next(CouponList) == nil then
    return 0
  end
  if not UnknowPassSystem.hasCoupon and not UnknowPassSystem.hasVoucher then
    return 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in pairs(CouponList) do
    local cacheItem = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(i)
    if cacheItem ~= nil and v.price_limit <= 600 then
      return 1
    end
  end
  return 2
end
function UnknownPassDataSystem.CheckVoucher()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local voucherList = {
    UnknowPassMacro.ENUM_PASS_VOUCHER_ID[2],
    UnknowPassMacro.ENUM_PASS_VOUCHER_ID[1]
  }
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in pairs(voucherList) do
    local cacheItem = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v)
    if cacheItem ~= nil then
      return true
    end
  end
  return false
end
function UnknownPassDataSystem.GetScoreCardList()
  local retlist = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local CardTable = CDataTable.GetTable("UnknowPassScoreCardCfg")
  for i, v in pairs(CardTable) do
    local StringUtil = require("common.string_util")
    local idList = StringUtil.Split(v.SeasonId, "|")
    if tonumber(idList[1]) == 0 or UnknowPassSystem.Season == tonumber(idList[1]) or idList[2] and UnknowPassSystem.Season == tonumber(idList[2]) then
      local cacheItem = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.ItemId)
      if cacheItem ~= nil then
        table.insert(retlist, {
          ItemId = v.ItemId,
          Score = v.Score,
          Count = cacheItem.count,
          Choice = cacheItem.count,
          InstId = cacheItem.insID
        })
      end
    end
  end
  return retlist
end
function UnknownPassDataSystem.GetSeasonLastDay()
  local TimeUtil = require("client.common.time_util")
  local endTime = TimeUtil.GetServerTimeInSec()
  local SeasonTable = CDataTable.GetTable("UnknowPassSeasonTimeCfg")
  for i, cfg in pairs(SeasonTable) do
    local timeString = cfg.SeasonEndTime
    local seasonEndTime = TimeUtil.TimeStringToUnixstamp(timeString)
    if seasonEndTime > TimeUtil.GetServerTimeInSec() then
      endTime = seasonEndTime
      break
    end
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "UnknowPassSystem.GetSeasonLastDay " .. math.floor((endTime - curTime) / 86400))
  return tostring(math.floor((endTime - curTime) / 86400))
end
function UnknownPassDataSystem.upass_get_req()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_new_get_req()
end
function UnknownPassDataSystem.upass_new_get_rsp(upass_score, upass_level, res_data)
  log(bWriteLog and " UnknowPassSystem.upass_get_rsp upass_score = " .. tostring(upass_score) .. " level=" .. tostring(upass_level))
  local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local SettingSystem = require("client.logic.setting.logic_setting")
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local UnknowPassGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local LobbyEffect = require("client.logic.login.logic_LobbyEffect")
  UnknowPassRankFirstWeekAwardsSystem.Release()
  res_data.all_week_task_cfg = UnknowPassSystem.Data.all_week_task_cfg or {}
  res_data.week_task = UnknowPassSystem.Data.week_task or {}
  UnknowPassSystem.Data = res_data
  UnknowPassSystem.Data.reward_status.elite_plus = res_data.reward_status.elite_plus or {}
  UnknowPassSystem.Score = upass_score
  UnknowPassSystem.Level = upass_level
  local bIsUpdateScene = false
  if UnknowPassSystem.Season and UnknowPassSystem.Season > 0 then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    if UnknowPassSystem.Season ~= res_data.base.cur_season and Lobby_camera_manager_module:GetCurrentCameraID() == UnknowPassMacro.UnknowPass_CameraId then
      bIsUpdateScene = true
    end
  end
  UnknowPassSystem.Season = res_data.base.cur_season
  if bIsUpdateScene then
    UnknowPassTunnelSystem.UpdateCameraAndBg(true)
  end
  UnknowPassSystem.nPreBuyType = res_data.pre_buy_ticket or UnknowPassMacro.Enum_PreBuyType.None
  UnknowPassSystem.continuous_buy = res_data.continuous_buy
  UnknowPassBuySystem.UpdateRPPackId()
  UnknowPassSystem.IsBuyElite = res_data.base.is_buy == 1
  UnknowPassSystem.prebuy_data = res_data.prebuy_data
  UnknowPassSystem.IsBuyEliteSeg2 = UnknowPassSystem.IsBuyElite and res_data.base.level_limit == nil
  UnknowPassSystem.PassType = res_data.base.pass_type or 0
  UnknowPassSystem.MaxLevel = res_data.upass_max_level or 20
  UnknowPassSystem.HasUnclaimedReward = res_data.unclaimed and res_data.unclaimed.reward and 0 < #res_data.unclaimed.reward
  UnknowPassSystem.upass_newuser_state = res_data.upass_newuser_state or 0
  UnknownPassDataSystem.SetSeasonStatus(res_data.season_info)
  UnknowPassSystem.single_month_award_flag = res_data.single_month_awards
  UnknowPassSystem.upgrade_buy_opentime = res_data.upgrade_buy_opentime
  UnknowPassSystem.upgrade_buy_endtime = res_data.upgrade_buy_endtime
  UnknowPassSystem.labels = res_data.labels or {}
  UnknowPassSystem.KeepBuyCount = res_data.base.keep_buy or 0
  UnknowPassSystem.EmtionData = res_data.motion_info or {}
  UnknowPassSystem.LastBuyEliteSeason = res_data.base.buy_season_index or 0
  UnknowPassSystem.privilege_exchange_list = res_data.privilege_exchange_list
  UnknowPassSystem.switch = res_data.base.switch
  UnknowPassSystem.rp_plus_upvote_cnt = res_data.rp_plus_upvote_cnt
  log(bWriteLog and "res_data.rp_plus_upvote_cnt = " .. tostring(res_data.rp_plus_upvote_cnt))
  SettingSystem.SetUnknowPassSwitch(UnknowPassSystem.switch)
  UnknowPassExchangeSystem.SetUpassActiveShopInfo(res_data.upass_active_shop_info)
  if UnknowPassTunnelSystem.isLoginRequestMessage then
    UnknowPassGiftSystem.tCacheLocalTableData = res_data.pre_prize
  else
    UnknowPassGiftSystem.InitPrizeGiftData(res_data.pre_prize)
    UnknowPassSystem.hasCoupon = UnknownPassDataSystem.CheckCouponBoxType()
    UnknowPassSystem.hasVoucher = UnknownPassDataSystem.CheckVoucher()
  end
  UnknownPassDataSystem.is_experience = res_data.base.is_experience
  UnknownPassDataSystem.experience_level = res_data.base.experience_level
  log(bWriteLog and "UnknowPassSystem.upass_get_rsp, received upass_get_rsp, level = " .. tostring(upass_level) .. ", maxLevel = " .. tostring(res_data.upass_max_level) .. ", score = " .. tostring(upass_score) .. ", and update reddot.")
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE)
  if UnknowPassTunnelSystem.isLoginRequestMessage then
    UnknownPassDataSystem.UpdateRPInfo()
  else
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    passReddotMainSystem.InfoUpdate()
  end
  if UnknowPassSystem.isNeedGetAllAward then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GETALL_AWARD)
    UnknowPassSystem.isNeedGetAllAward = false
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_DOWNLOAD_REFRESH)
  UnknowPassExchangeSystem.exchange_hair_chest_id = res_data.upass_exchange_hair_chest_id
  UnknowPassExchangeSystem.upass_exchange_face_chest_id = res_data.upass_exchange_face_chest_id
  local ResourseVersion = UnknowPassUtil.GetVersionNumber()
  Client.SetImageVersionString("1_3_0", ResourseVersion)
  LobbyEffect.UpdateEffectUI()
  if UIManager.GetUI(UIManager.UI_Config.Lobby_UnknowPass_UIBP_1_0_0) then
    local UnknowPassSlapSystem = require("client.slua.logic.unknow_pass.NewRPInitFlow.logic_unknowpass_slap")
    UnknowPassSlapSystem.HandleExperienceAward()
  end
  if not UnknowPassTunnelSystem.hasShowExpBubble and UnknownPassDataSystem.CheckExperienceBubble() then
    UnknowPassTunnelSystem.hasShowExpBubble = true
    local LobbyBubbleConfig = require("client.slua.logic.lobby_bubble.LobbyBubbleConfig")
    EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_BUBBLE_UPDATE, {
      from_type = LobbyBubbleConfig.Enum_Lobby_Bubble_Type.RP_Experience
    })
  end
  UnknownPassDataSystem.extra_score_cfgs = res_data.extra_score_cfgs or {}
  UnknowPassTunnelSystem.isLoginRequestMessage = false
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:InitBonusPassConfig()
  Logic_BonusPass:send_rp_branch_player_data_req()
  Logic_BonusPass:send_sync_rp_branch_task_data_req()
  UnknownPassDataSystem.send_sync_upass_extra_score_req()
  if not UnknowPassExchangeSystem.ExchangeItemList or not next(UnknowPassExchangeSystem.ExchangeItemList) then
    UnknowPassExchangeSystem.upass_exchange_list_req()
  end
end
function UnknownPassDataSystem.UpdateRPInfo()
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = passReddotMainSystem,
    funcName = "InfoUpdate",
    param = passReddotMainSystem,
    debugInfo = "passReddotMainSystem",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function UnknownPassDataSystem.CheckExtraScoreCanGet()
  local taskMap = UnknownPassDataSystem.rp_extra_score.tasks or {}
  local isUnlock = UnknownPassDataSystem.rp_extra_score.is_unlock or false
  for task_id, task_data in pairs(taskMap) do
    if task_data.status == 1 then
      if isUnlock then
        return 1
      else
        return 2
      end
    end
  end
  return 0
end
function UnknownPassDataSystem.CheckExtraScoreEndRound()
  local isUnlock = UnknownPassDataSystem.rp_extra_score.is_unlock or false
  if UnknownPassDataSystem.rp_extra_score.cur_score >= UnknownPassDataSystem.extra_score_cfgs.max_score then
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE_END)
  elseif not isUnlock then
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE_NEWROUND)
  end
end
local GetAwardList = function(isExperience)
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(true, isExperience)
  if not awardLevelList then
    return nil
  end
  local reward_map = {}
  local startLevel = 1
  local endLevel = UnknowPassSystem.Level
  for i = startLevel, endLevel do
    local item = awardLevelList[i]
    if not item then
      break
    end
    for j = 1, #item.EliteAwardList do
      local item0 = item.EliteAwardList[j]
      local reward = reward_map[item0.resId]
      if reward then
        reward.item_num = reward.item_num + item0.number
      else
        local cfgItem = CDataTable.GetTableData("Item", item0.resId)
        if cfgItem then
          local reward_item = {
            item_id = item0.resId,
            item_num = item0.number,
            item_show_type = item0.item_show_type,
            item_quality = cfgItem.ItemQuality,
            item_limit = item0.isLimitTime and 120 or 0
          }
          reward_map[item0.resId] = reward_item
        end
      end
    end
  end
  local reward_array = {}
  for _, award in pairs(reward_map) do
    local item = {
      item_id = award.item_id,
      item_num = award.item_num,
      item_show_type = award.item_show_type,
      item_quality = award.item_quality,
      item_limit = award.item_limit
    }
    table.insert(reward_array, item)
  end
  table.sort(reward_array, function(a, b)
    return a.item_quality > b.item_quality
  end)
  return reward_array
end
function UnknownPassDataSystem.CheckExperienceBubble()
  if UnknowPassSystem.Season ~= 36 then
    log(bWriteLog and "UnknownPassDataSystem.CheckExperienceBubble season wrong")
    return false
  end
  local UnknowPassTipsSystem = require("client.logic.unknow_pass.logic_unknow_pass_tips")
  if not UnknowPassTipsSystem.CheckExperienceBubbleShow() then
    log(bWriteLog and "UnknownPassDataSystem.CheckExperienceBubble has show")
    return false
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if not PassDataSystem.is_experience or PassDataSystem.is_experience ~= 1 then
    log(bWriteLog and "UnknownPassDataSystem.CheckExperienceBubble not buy")
    return false
  end
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local endTime = UnknowPassUtil.GetSpecificSeasonEndTime(36)
  local diffEndTime = math.floor((endTime - FuncUtil.GetServerTimeInSec()) / 86400)
  log(bWriteLog and "UnknownPassDataSystem.CheckExperienceBubble " .. diffEndTime)
  if diffEndTime == 2 or diffEndTime == 1 or diffEndTime == 0 then
    return true
  end
  local awardList = GetAwardList(true)
  for i, v in ipairs(awardList) do
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.item_id)
    if 0 < v.item_limit and item and 0 < item.count then
      diffEndTime = math.floor((item.expireTS - FuncUtil.GetServerTimeInSec()) / 86400)
      log(bWriteLog and "UnknownPassDataSystem.CheckExperienceBubble " .. diffEndTime)
      if diffEndTime == 4 or diffEndTime == 2 or diffEndTime == 0 then
        return true
      end
    end
  end
  return false
end
function UnknownPassDataSystem.GetIsOpenHighScore()
  local isStart = false
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.extra_score_cfgs and PassDataSystem.extra_score_cfgs.round_cfgs and PassDataSystem.extra_score_cfgs.round_cfgs[1] then
    local startTime = PassDataSystem.extra_score_cfgs.round_cfgs[1].start_time
    if startTime <= FuncUtil.GetServerTimeInSec() then
      isStart = true
    end
  end
  if UnknowPassSystem.IsBuyElite and UnknowPassSystem.Level >= UnknowPassSystem.MaxLevel and isStart then
    return true
  end
  return false
end
function UnknownPassDataSystem.send_sync_upass_extra_score_req()
  if not UnknownPassDataSystem.GetIsOpenHighScore() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local nTime = nCurTime - UnknownPassDataSystem.nHighScoreLastReqTime
  if nTime < 60 and next(UnknownPassDataSystem.rp_extra_score) then
    return
  end
  UnknownPassDataSystem.nHighScoreLastReqTime = nCurTime
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_sync_upass_extra_score_req()
end
function UnknownPassDataSystem.GetPercentCouponInfo()
  if #UnknownPassDataSystem.tPercentCouponIdList > 0 then
    return UnknownPassDataSystem.tPercentCouponIdList
  end
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local tCouponList = CouponSystem.GetChildCouponList(CouponSystem._Enum_Scene._UnknowPass, UnknowPassSystem.Season)
  local tPercentCoupon = {}
  if not tCouponList then
    return tPercentCoupon
  end
  for itemId, info in pairs(tCouponList) do
    if info.voucher_type == 1 then
      tPercentCoupon = info
      tPercentCoupon.      break
    end
  end
  UnknownPassDataSystem.tPercentCouponIdList = tPercentCoupon
  return tPercentCoupon
end
function UnknownPassDataSystem.GetHallDepotUnknowPassNewCoupon()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tCoutponData
  local tCouponIdList = {}
  for _, itemId in pairs(UnknownPassDataSystem.GetAllCouponByThrow()) do
    tCoutponData = wardrobe_data:GetHallDepotItemDataByResID(itemId)
    if tCoutponData then
      tCouponIdList[#tCouponIdList + 1] = itemId
    end
  end
  return tCouponIdList
end
function UnknownPassDataSystem.GetAllCouponByThrow()
  if #UnknownPassDataSystem.tThrowCouponList >= 3 then
    return UnknownPassDataSystem.tThrowCouponList
  end
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local tAllCouponList = CouponSystem.GetChildCouponList(CouponSystem._Enum_Scene._UnknowPass, UnknowPassSystem.Season)
  local tThrowCouponList = {}
  if not tAllCouponList then
    return tThrowCouponList
  end
  for itemId, info in pairs(tAllCouponList) do
    if info.voucher_type == 1 or info.voucher_type == 2 then
      tThrowCouponList[#tThrowCouponList + 1] = itemId
    end
  end
  table.sort(tThrowCouponList, function(a, b)
    return a < b
  end)
  UnknownPassDataSystem.  return tThrowCouponList
end
function UnknownPassDataSystem.GetCurCouponId()
  local nCurShowCouponId = 0
  local tCouponList = UnknownPassDataSystem.GetPercentCouponInfo()
  local tHasCouponList = UnknownPassDataSystem.GetHallDepotUnknowPassNewCoupon()
  if 1 < #tHasCouponList then
    for _, itemId in pairs(tHasCouponList) do
      if itemId == tCouponList.itemId then
        nCurShowCouponId = itemId
        break
      end
    end
    if nCurShowCouponId == 0 then
      for _, itemId in pairs(tHasCouponList) do
        for _, id in pairs(UnknownPassDataSystem.GetAllCouponByThrow()) do
          if itemId == id then
            nCurShowCouponId = itemId
          end
        end
      end
    end
  else
    for _, itemId in pairs(tHasCouponList) do
      for _, id in pairs(UnknownPassDataSystem.GetAllCouponByThrow()) do
        if itemId == id then
          nCurShowCouponId = itemId
        end
      end
    end
  end
  return nCurShowCouponId
end
function UnknownPassDataSystem.IsShowOldCouponIcon()
  local nCouponIdList = UnknownPassDataSystem.GetHallDepotUnknowPassNewCoupon()
  if #nCouponIdList == 0 or UnknowPassSystem.UpgradeTipsType == 2 and not UnknownPassDataSystem.IsUseNewCouponUIShow() then
    return true
  end
  return false
end
function UnknownPassDataSystem.IsUseNewCouponUIShow()
  if DataMgr.can_show_rp_bubble then
    return true
  end
  return false
end
function UnknownPassDataSystem.GetCurFixedCouponInfo()
  local nItemId = UnknownPassDataSystem.GetCurCouponId()
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local tAllCouponList = CouponSystem.GetChildCouponList(CouponSystem._Enum_Scene._UnknowPass, UnknowPassSystem.Season)
  for id, info in pairs(tAllCouponList) do
    if nItemId == id then
      return info
    end
  end
  return
end
function UnknownPassDataSystem.IsShowPassValueTask()
  local bIsActOpen = UnknownPassDataSystem.GetIsOpenHighScore()
  if not bIsActOpen then
    return false
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local panelType = PassDataSystem.GetPanelType()
  local curType = PassDataSystem.GetCurRpPanelType()
  if curType ~= panelType.BranchRp then
    return false
  end
  if UnknowPassSystem.Level < 100 then
    return false
  end
  return true
end
function UnknownPassDataSystem.GetRpAnnualSalesCfg(nRpStep)
  local tAnnualSalesCfg = CDataTable.GetTableByFilter("AnnualSalesCfg", "RewardStep", nRpStep)
  if not tAnnualSalesCfg then
    return
  end
  local tConfig = {}
  for i, v in pairs(tAnnualSalesCfg) do
    tConfig[#tConfig + 1] = v
  end
  return tConfig
end
function UnknownPassDataSystem.IsShowAnnualSale()
  if UnknowPassSystem.Season ~= 59 then
    return false
  end
  if UnknowPassSystem.IsBuyElite then
    return false
  end
  if UnknowPassSystem.prebuy_data and UnknowPassSystem.prebuy_data.has_bonus then
    return false
  end
  return true
end
function UnknownPassDataSystem.GetRpPrivilegeConfig()
  if UnknownPassDataSystem.tPrivilegeSeason and UnknownPassDataSystem.tPrivilegeSeason == UnknowPassSystem.Season and UnknownPassDataSystem.tPrivilegeConfig then
    return UnknownPassDataSystem.tPrivilegeConfig
  end
  local tPrivilegeCfg = CDataTable.GetTable("RPPrivilegeConfig")
  if not tPrivilegeCfg then
    return {}
  end
  local tConfigByType = {}
  for _, value in pairs(tPrivilegeCfg) do
    if value.NewArrivalSeason == 0 or UnknowPassSystem.Season >= value.NewArrivalSeason then
      local luaV = {}
      for k, v in pairs(value) do
        luaV[k] = v
      end
      local category = luaV.PrivilegeCategory
      if not tConfigByType[category] then
        tConfigByType[category] = {}
      end
      table.insert(tConfigByType[category], luaV)
    end
  end
  for _, type_list in pairs(tConfigByType) do
    table.sort(type_list, function(a, b)
      return a.PrivilegeType < b.PrivilegeType
    end)
  end
  UnknownPassDataSystem.tPrivilegeSeason = UnknowPassSystem.Season
  UnknownPassDataSystem.tPrivilegeConfig = tConfigByType
  return tConfigByType
end
function UnknownPassDataSystem.IsShowFirstBuyPrivilege()
  if UnknowPassSystem.Season ~= 59 then
    return false
  end
  if UnknowPassSystem.IsBuyElite then
    return false
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local ENUM_NEWUSER_STATE = UnknowPassMacro.ENUM_NEWUSER_STATE
  local upassNewuserState = UnknowPassSystem.upass_newuser_state
  log(bWriteLog and "UnknownPassDataSystem.IsShowFirstBuyPrivilege  " .. tostring(UnknowPassSystem.upass_newuser_state))
  if upassNewuserState ~= ENUM_NEWUSER_STATE.NEVER_BUY then
    return false
  end
  return true
end
return UnknownPassDataSystem