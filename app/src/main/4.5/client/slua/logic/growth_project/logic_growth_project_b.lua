local growthprojectMgrB = {}
local TableUtil = require("common.table_util")
local ENUM_GUIDE = {
  Depot = 102,
  Xmission = 103,
  Season = 105,
  Machine = 106,
  RP = 104
}
local ENUM_STEP = {
  [ENUM_GUIDE.Xmission] = {
    None = -1,
    Init = 0,
    LobbyToXmission = 1,
    ReceReward = 2,
    XmissionToLobby = 3,
    Finish = 4
  },
  [ENUM_GUIDE.RP] = {
    None = -1,
    Init = 0,
    LobbyToRP = 1,
    ReceReward = 2,
    ScrollTo100 = 3,
    RPToLobby = 4,
    SecStartMatch = 5,
    Finish = 6
  }
}
function growthprojectMgrB.JaguarPostSwitch()
  log(bWriteLog and "growthprojectMgrB.JaguarPostSwitch")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bEnterMainCityLoading = Lobby_Main_City_Enter.bEnterMainCityLoading
  log(bWriteLog and "growthprojectMgrB.JaguarPostSwitch bEnterMainCityLoading = " .. tostring(bEnterMainCityLoading))
  if not bEnterMainCityLoading then
    logic_connection_waiting:Hide(0)
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "growthprojectMgrB.JaguarPostSwitch not lobby")
    return
  end
  growthprojectMgrB.RunNewTypeGuides()
end
function growthprojectMgrB.RunNewTypeGuides()
  log(bWriteLog and "growthprojectMgrB.RunNewTypeGuides")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local newbieGuide = DataMgr.newbieGuide
  local XmissionGuideTb = newbieGuide[LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE]
  if not XmissionGuideTb or not next(XmissionGuideTb) then
    log(bWriteLog and "[RP Guide] growthprojectMgrB.RunNewTypeGuides RunXmissionGuide")
    growthprojectMgrB.RunXmissionGuide()
    return
  end
  local rp_guide_data = newbieGuide[LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_RP_GUIDE]
  log_tree("growthprojectMgrB.RunNewTypeGuides rp_guide_data", rp_guide_data)
  if not rp_guide_data or not next(rp_guide_data) then
    growthprojectMgrB.InitRpGuide()
  end
end
function growthprojectMgrB.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "growthprojectMgrB.OnModePostSwitch")
  local CheckUseNewGuide = LobbySystem.CheckUseNewGuide()
  log(bWriteLog and "growthprojectMgrB.OnModePostSwitch CheckUseNewGuide = " .. tostring(CheckUseNewGuide))
  if CheckUseNewGuide then
    growthprojectMgrB.JaguarPostSwitch()
    return
  end
end
function growthprojectMgrB.InitRpGuide()
  log(bWriteLog and "growthprojectMgrB.InitRpGuide")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local rp_guide_data = DataMgr.newbieGuide[LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_RP_GUIDE]
  log_tree("growthprojectMgrB.InitRpGuide rp_guide_data", rp_guide_data)
  local cur_rp_step = ENUM_STEP[ENUM_GUIDE.RP].None
  for i, v in ipairs(rp_guide_data or {}) do
    cur_rp_step = i
  end
  log(bWriteLog and "growthprojectMgrB.InitRpGuide cur_rp_step = " .. tostring(cur_rp_step))
  if cur_rp_step >= ENUM_STEP[ENUM_GUIDE.RP].LobbyToRP and cur_rp_step <= ENUM_STEP[ENUM_GUIDE.RP].Finish then
    cur_rp_step = ENUM_STEP[ENUM_GUIDE.RP].Finish
  end
  growthprojectMgrB.CurGuideStep[ENUM_GUIDE.RP] = cur_rp_step
end
function growthprojectMgrB.NewGuideFirstMatch()
  log(bWriteLog and "growthprojectMgrB.NewGuideFirstMatch")
  growthprojectMgrB.DoFirstMatch = true
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_DEPOT_GUIDE_MATCH)
end
function growthprojectMgrB.NewGuideBeforeMatch()
  log(bWriteLog and "growthprojectMgrB.NewGuideBeforeMatch")
  UIManager.ShowUI(UIManager.UI_Config.Newbie_NoviceProcessGuidance_UIBP)
end
function growthprojectMgrB.RunFirstMatchGuide()
  log(bWriteLog and "growthprojectMgrB.RunFirstMatchGuide")
  if growthprojectMgrB.DoFirstMatch then
    EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_DEPOT_GUIDE_MATCH)
  end
end
function growthprojectMgrB.EnterWoWNewbieBranch()
  log(bWriteLog and "growthprojectMgrB.EnterWoWNewbieBranch")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  Util_UGC.SetUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameWoWMode)
end
function growthprojectMgrB.EndWoWNewbieBranch()
  log(bWriteLog and "growthprojectMgrB.EndWoWNewbieGuide")
  if growthprojectMgrB.CheckEnterWoWNewbieGuide() then
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    Util_UGC.SetUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameWoWModeNewbieEnd)
  else
    log(bWriteLog and "growthprojectMgrB.EndWoWNewbieGuide Error. Try ending NewbieGuide before started.")
  end
end
function growthprojectMgrB.CheckEndWoWNewbieGuide()
  log(bWriteLog and "growthprojectMgrB.CheckEndWoWNewbieGuide")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  return Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameWoWModeNewbieEnd)
end
function growthprojectMgrB.CheckEnterWoWNewbieGuide()
  log(bWriteLog and "growthprojectMgrB.CheckEnterWoWNewbieGuide")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  return Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameWoWMode)
end
function growthprojectMgrB.GetUGCModeSelectionHandGuide()
  local level = 11
  local UGCModeSelectionHandGuide = CDataTable.GetTableData("SystemConfig", "UGCModeSelectionHandGuide")
  if UGCModeSelectionHandGuide then
    level = tonumber(UGCModeSelectionHandGuide.ConfigValue)
    log(bWriteLog and "growthprojectMgrB.GetUGCModeSelectionHandGuide level = " .. tostring(level))
    if not level then
      log(bWriteLog and "growthprojectMgrB.GetUGCModeSelectionHandGuide level is nil, set to 11")
      level = 11
    end
  end
  return level
end
function growthprojectMgrB.ResetCacheData()
  log(bWriteLog and "growthprojectMgrB.ResetCacheData")
  growthprojectMgrB.bOpen = false
  growthprojectMgrB.CurGuideStep = {}
  growthprojectMgrB.CurGuideStep[ENUM_GUIDE.Xmission] = -1
  growthprojectMgrB.CurGuideStep[ENUM_GUIDE.RP] = -1
  growthprojectMgrB.PlayerWeakTip = {}
  growthprojectMgrB.StartMatchCD = 30
  growthprojectMgrB.StartMatchCD_ForceRankABTest = 10
  growthprojectMgrB.CanntClickMatch = false
  growthprojectMgrB.bInitMatch = false
  growthprojectMgrB.DoFirstMatch = false
  growthprojectMgrB.fromClickBanner = false
  if growthprojectMgrB.StartMatchtimer then
    local timer = require("common.time_ticker")
    timer.RemoveTimer(growthprojectMgrB.StartMatchtimer)
  end
  growthprojectMgrB.StartMatchtimer = nil
  growthprojectMgrB.bReceData = false
  growthprojectMgrB.CloseWaitingUITimer()
end
function growthprojectMgrB.RegisterEvents()
  log(bWriteLog and "growthprojectMgrB.RegisterEvents")
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, growthprojectMgrB.RunFirstMatchGuide)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, growthprojectMgrB.OnReceData)
end
function growthprojectMgrB.Init()
  log(bWriteLog and "growthprojectMgrB.Init")
  growthprojectMgrB.RegisterEvents()
  growthprojectMgrB.ResetCacheData()
  growthprojectMgrB.InitWeakGuide()
  growthprojectMgrB.InitWaitingUITimer()
end
function growthprojectMgrB.InitWaitingUITimer()
  log(bWriteLog and "growthprojectMgrB.InitWaitingUITimer")
  local timer_ticker = require("common.time_ticker")
  growthprojectMgrB.CloseWaitingUITimer()
  local count = 0
  growthprojectMgrB.Timer = timer_ticker.AddTimerLoop(0, function()
    local ui = UIManager.GetUI(UIManager.UI_Config.connect_wait)
    if ui then
      count = count + 1
    else
      growthprojectMgrB.CloseWaitingUITimer()
    end
    if 3 <= count then
      logic_connection_waiting:Hide(0)
      growthprojectMgrB.CloseWaitingUITimer()
    end
  end, TIMER_INFINITE, 1)
end
function growthprojectMgrB.CloseWaitingUITimer()
  log(bWriteLog and "growthprojectMgrB.CloseWaitingUITimer")
  local timer_ticker = require("common.time_ticker")
  if growthprojectMgrB.Timer then
    timer_ticker.RemoveTimer(growthprojectMgrB.Timer)
    growthprojectMgrB.Timer = nil
  end
end
function growthprojectMgrB.JaguarFinishAllNewGuide()
  log(bWriteLog and "growthprojectMgrB.JaguarFinishAllNewGuide growthprojectMgrB.bOpen = " .. tostring(growthprojectMgrB.bOpen))
  if not growthprojectMgrB.bOpen then
    return true
  end
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  log(bWriteLog and "growthprojectMgrB.JaguarFinishAllNewGuide oldplayer_flag = " .. tostring(PlayerLabelHandler.oldplayer_flag))
  if PlayerLabelHandler.oldplayer_flag then
    return true
  end
  local RPIndex = growthprojectMgrB.CurGuideStep[ENUM_GUIDE.RP]
  log(bWriteLog and "growthprojectMgrB.JaguarFinishAllNewGuide growthprojectMgrB.CurGuideStep[ENUM_GUIDE.RP] == " .. RPIndex)
  if RPIndex > ENUM_STEP[ENUM_GUIDE.RP].RPToLobby and RPIndex <= ENUM_STEP[ENUM_GUIDE.RP].Finish then
    return true
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local bHaveNewbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_ENTRY_GUIDE, 1)
  log(bWriteLog and "growthprojectMgrB.JaguarFinishAllNewGuide bHaveNewbieGuide = " .. tostring(bHaveNewbieGuide))
  if not bHaveNewbieGuide then
    return true
  end
  log(bWriteLog and "growthprojectMgrB.JaguarFinishAllNewGuide not finish newbie guide")
  return false
end
function growthprojectMgrB.IsFinishAllNewGuideAndBanner()
  log(bWriteLog and "growthprojectMgrB.IsFinishAllNewGuideAndBanner")
  local logicLevelSprint = require("client.slua.logic.activity.newbie.logic_newbie_level_sprint")
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  return growthprojectMgrB.IsFinishAllNewGuide() and (not logicLevelSprint.IsOpen() or not logic_newbie_assist.CheckIsNewbieBanner())
end
function growthprojectMgrB.IsFinishAllNewGuide()
  log(bWriteLog and "growthprojectMgrB.IsFinishAllNewGuide")
  if not growthprojectMgrB.bOpen then
    log(bWriteLog and "IsFinishAllNewGuide: growthprojectMgrB.bOpen")
    return true
  end
  if LobbySystem.CheckUseNewGuide() then
    return growthprojectMgrB.JaguarFinishAllNewGuide()
  end
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  if PlayerLabelHandler.oldplayer_flag then
    log(bWriteLog and "[qintong]  IsFinishAllNewGuide: oldplayer_flag = " .. tostring(PlayerLabelHandler.oldplayer_flag))
    return true
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = LogicNewbie.newbieTotalGameCnt
  log(bWriteLog and "[qintong]  IsFinishAllNewGuide: enter_game_num" .. tostring(enter_game_num))
  if enter_game_num and 2 <= enter_game_num then
    return true
  end
  return false
end
function growthprojectMgrB.OnReceData()
  log(bWriteLog and "growthprojectMgrB.OnReceData")
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  if newbieGuideManager.GetDisableInEditor() and _G.IsEditor then
    return
  end
  if GlobalData.IsIOSCheck() then
    return
  end
  if newbieGuideManager.GetNewbieDebugSwitch() then
    return
  end
  if growthprojectMgrB.bReceData then
    return
  end
  growthprojectMgrB.bReceData = true
  growthprojectMgrB.bOpen = LobbySystem.CheckOpen(BP_ENUM_PLAYER_NEW_GUIDE)
  growthprojectMgrB.CloseErrorUI()
  log(bWriteLog and "[qintong] :growthprojectMgrB.OnReceData  switch  bOpen = " .. tostring(growthprojectMgrB.bOpen))
  if growthprojectMgrB.IsFinishAllNewGuide() then
    return
  end
  if LobbySystem.CheckUseNewGuide() then
    growthprojectMgrB.RunXmissionGuide()
    growthprojectMgrB.InitRpGuide()
    return
  end
end
function growthprojectMgrB.CloseErrorUI()
  log(bWriteLog and "growthprojectMgrB.CloseErrorUI")
  local uiList = {
    "Flap_Newbie_EightDays"
  }
  for i, name in pairs(uiList) do
    local cfg = UIManager.UI_Config[name]
    local ui = UIManager.GetUI(cfg)
    if ui then
      UIManager.CloseUI(cfg)
    end
  end
end
function growthprojectMgrB.RunXmissionGuide(step)
  log(bWriteLog and "growthprojectMgrB.RunXmissionGuide")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local newbieGuide = DataMgr.newbieGuide
  local tb = newbieGuide[LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE]
  local XmissionIndex = ENUM_STEP[ENUM_GUIDE.Xmission].None
  for i, v in ipairs(tb or {}) do
    XmissionIndex = i
  end
  log_tree("[qintong] RunXmissionGuide[XmissionIndex] = " .. XmissionIndex, tb)
  if XmissionIndex >= ENUM_STEP[ENUM_GUIDE.Xmission].LobbyToXmission and XmissionIndex <= ENUM_STEP[ENUM_GUIDE.Xmission].Finish then
    XmissionIndex = ENUM_STEP[ENUM_GUIDE.Xmission].Finish
  end
  growthprojectMgrB.CurGuideStep[ENUM_GUIDE.Xmission] = XmissionIndex
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  newbie_guide_util.UpdateMCNewbieActivityTip()
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_XMISSION_GUIDE)
end
function growthprojectMgrB.JaguarCheckGuideStep(GuideType, GuideStep)
  log(bWriteLog and "growthprojectMgrB.JaguarCheckGuideStep")
  if growthprojectMgrB.IsFinishAllNewGuide() then
    return false
  end
  if LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole then
    return false
  end
  if Client and Client.IsMatchVersion and Client.IsMatchVersion() then
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return false
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local Last_Step = DataMgr.GetNewbieGuideValue(GuideType, GuideStep)
  local Cur_Step = DataMgr.GetNewbieGuideValue(GuideType, GuideStep + 1)
  local bRun = false
  local bLastFinish = false
  if GuideStep == 0 then
    if GuideType == LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE then
      bLastFinish = true
      local guidetb = DataMgr.newbieGuide[LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE]
      if guidetb and next(guidetb) then
        Cur_Step = true
      end
    elseif GuideType == LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIRST_BATTLE_AFTER_TASK then
      local lastGuide = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE
      local guidetb = DataMgr.newbieGuide[lastGuide]
      if guidetb and next(guidetb) then
        bLastFinish = true
      end
    end
    Last_Step = true
  else
    bLastFinish = true
  end
  if Last_Step and not Cur_Step and bLastFinish then
    bRun = true
  end
  log(bWriteLog and "[qintong] JaguarCheckGuideStep  GuideType = " .. GuideType .. "  GuideStep = " .. GuideStep .. tostring(bRun))
  return bRun
end
function growthprojectMgrB.CheckGuideStep(GuideType, GuideStep)
  log(bWriteLog and "growthprojectMgrB.CheckGuideStep")
  if LobbySystem.CheckUseNewGuide() then
    return growthprojectMgrB.JaguarCheckGuideStep(GuideType, GuideStep)
  end
  return false
end
function growthprojectMgrB.SaveGuideInfo(GuideType, GuideStep)
  log(bWriteLog and "growthprojectMgrB.SaveGuideInfo GuideType = " .. tostring(GuideType) .. " GuideStep = " .. tostring(GuideStep))
  if growthprojectMgrB.CurGuideStep == nil then
    return
  end
  growthprojectMgrB.CurGuideStep[GuideType] = GuideStep
  DataMgr.SetNewbieGuide(GuideType, GuideStep)
  log(bWriteLog and "[qintong] growthprojectMgrB.SaveGuideInfo GuideType=" .. GuideType .. "  ,GuideStep=" .. GuideStep)
end
function growthprojectMgrB.SkipXmissionReward()
  log(bWriteLog and "growthprojectMgrB.SkipXmissionReward")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE
  growthprojectMgrB.SaveGuideInfo(GuideType, 2)
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_XMISSION_GUIDE)
end
function growthprojectMgrB.IsSkipOldRPGuide()
  log(bWriteLog and "growthprojectMgrB.IsSkipOldRPGuide")
  if growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "[qintong] growthprojectMgrB.IsSkipOldRPGuide IsFinishAllNewGuide")
    return false
  end
  return true
end
function growthprojectMgrB.CanSwitchUI()
  log(bWriteLog and "growthprojectMgrB.CanSwitchUI")
  if LobbySystem.CheckUseNewGuide() then
    if growthprojectMgrB.JaguarFinishAllNewGuide() then
      return true
    else
      local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
      local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
      if lobbyMain and Lobby_Main_Control.curPage == ENUM_LobbyPageType.Mid then
        local midBannerUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Activity_UIBP)
        if midBannerUI ~= nil then
          local root = midBannerUI.UIRoot
          if root and root.GuidePanel and root.GuidePanel:GetVisibility() == UEnums.ESlateVisibility.Visible then
            return false
          end
        end
        local midShopUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Shop_UIBP)
        if midShopUI then
          local root = midShopUI.UIRoot
          if root and root.GuidePanel and root.GuidePanel:GetVisibility() == UEnums.ESlateVisibility.Visible then
            return false
          end
        end
        local mainMatchUI = lobbyMain:GetChildUI(UIManager.UI_Config.match_new_entry)
        if mainMatchUI then
          local root = mainMatchUI.UIRoot
          if root and root.GuidePanel and root.GuidePanel:GetVisibility() == UEnums.ESlateVisibility.Visible then
            return false
          end
        end
      end
    end
    return true
  end
  local GuideUI = UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP)
  local value
  if GuideUI then
    value = false
  else
    value = true
  end
  log(bWriteLog and "[qintong] growthprojectMgrB.CanSwitchUI  value =" .. tostring(value))
  return value
end
function growthprojectMgrB.OnClickMatchEntry()
  log(bWriteLog and "growthprojectMgrB.OnClickMatchEntry")
  if growthprojectMgrB.IsFinishAllNewGuide() then
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIRST_BATTLE_AFTER_TASK
  local bGuideCheck = growthprojectMgrB.CheckGuideStep(GuideType, 0)
  if bGuideCheck then
    growthprojectMgrB.SaveGuideInfo(GuideType, 1)
  end
end
function growthprojectMgrB.StartMatchTimer()
  log(bWriteLog and "growthprojectMgrB.StartMatchTimer")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = LogicNewbie.GetTotalGameCount()
  if growthprojectMgrB.StartMatchtimer then
    log_warning(bWriteLog and "growthprojectMgrB.StartMatchTimer already start")
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  if status == ENUM_MatchStatus.Matching then
    log_warning(bWriteLog and "growthprojectMgrB.StartMatchTimer is Matching")
    return
  end
  local StartMatchCD
  if enter_game_num == 0 and not growthprojectMgrB.bInitMatch then
    log(bWriteLog and "growthprojectMgrB.StartMatchTimer first match")
    growthprojectMgrB.CanntClickMatch = true
    growthprojectMgrB.bInitMatch = true
    StartMatchCD = growthprojectMgrB.StartMatchCD
  end
  local logic_newbie_guide_force_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_guide_force_rank)
  if logic_newbie_guide_force_rank:NeedShowGuide() then
    log(bWriteLog and "growthprojectMgrB.StartMatchTimer second match and ABTest")
    growthprojectMgrB.CanntClickMatch = true
    StartMatchCD = growthprojectMgrB.StartMatchCD_ForceRankABTest
  end
  log_format("growthprojectMgrB.StartMatchTimer StartMatchCD = %s", StartMatchCD)
  if not StartMatchCD then
    return
  end
  growthprojectMgrB.ClearStartMatchTimer()
  local time_ticker = require("common.time_ticker")
  growthprojectMgrB.StartMatchtimer = time_ticker.AddTimerLoop(0, function()
    StartMatchCD = StartMatchCD - 1
    log(bWriteLog and "growthprojectMgrB.StartMatchTimer Count Down = %s", StartMatchCD)
    if StartMatchCD <= 0 then
      growthprojectMgrB.CanntClickMatch = false
      EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_ACTION_MATCH_EVENT)
      if growthprojectMgrB.StartMatchtimer then
        time_ticker.RemoveTimer(growthprojectMgrB.StartMatchtimer)
        growthprojectMgrB.StartMatchtimer = nil
      end
    end
  end, TIMER_INFINITE, 1)
end
function growthprojectMgrB.ClearStartMatchTimer()
  if growthprojectMgrB.StartMatchtimer then
    timer.RemoveTimer(growthprojectMgrB.StartMatchtimer)
    growthprojectMgrB.StartMatchtimer = nil
  end
end
function growthprojectMgrB.GetDepotGuideItemId()
  log(bWriteLog and "growthprojectMgrB.GetDepotGuideItemId")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local id = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIGHT_GUIDE
  local itemID = DataMgr.GetNewbieGuideValue(id, -1)
  return itemID
end
function growthprojectMgrB.InitPlayerMarkLabel(labels)
  log(bWriteLog and "growthprojectMgrB.InitPlayerMarkLabel")
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  for _, id in pairs(labels or {}) do
    PlayerLabelHandler.markLabelResult[id] = true
  end
end
function growthprojectMgrB.CheckPlayerLabelByID(id)
  log(bWriteLog and "growthprojectMgrB.CheckPlayerLabelByID")
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  local data = PlayerLabelHandler.markLabelResult
  log_tree(id .. type(id) .. "CheckPlayerLabelByID data" .. tostring(data[tonumber(id)]))
  if data[tonumber(id)] then
    return true
  else
    return false
  end
end
function growthprojectMgrB.InitWeakGuide()
  log(bWriteLog and "growthprojectMgrB.InitWeakGuide")
  for guide_id = 2, 8 do
    local step = {}
    step[1] = false
    if guide_id == 1 or guide_id == 5 or guide_id == 7 then
      step[2] = false
    end
    growthprojectMgrB.PlayerWeakTip[guide_id] = {step = step}
  end
end
function growthprojectMgrB.UpdateWeakGuide(sync_cond_info)
  log(bWriteLog and "growthprojectMgrB.UpdateWeakGuide")
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_WEAK_GUIDE_SHOW)
end
function growthprojectMgrB.HideWeakGuide(guide_id, step_id)
  log(bWriteLog and "growthprojectMgrB.HideWeakGuide")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return
  end
  if growthprojectMgrB.PlayerWeakTip[guide_id] then
    growthprojectMgrB.PlayerWeakTip[guide_id].step[step_id] = false
    if growthprojectMgrB.PlayerWeakTip[guide_id].step[step_id - 1] then
      growthprojectMgrB.PlayerWeakTip[guide_id].step[step_id - 1] = false
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_WEAK_GUIDE_HIDE)
end
function growthprojectMgrB.IsWeakGuideTaskStep1()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideTaskStep1")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[1] then
    if growthprojectMgrB.PlayerWeakTip[1].step[1] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideTaskStep2()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideTaskStep2")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[1] then
    if growthprojectMgrB.PlayerWeakTip[1].step[2] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideTaskMoreMode()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideTaskMoreMode")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[3] then
    if growthprojectMgrB.PlayerWeakTip[3].step[1] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideTeamPlatform()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideTeamPlatform")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[4] then
    if growthprojectMgrB.PlayerWeakTip[4].step[1] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideCorpStep1()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideCorpStep1")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[5] then
    if growthprojectMgrB.PlayerWeakTip[5].step[1] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideCorpStep2()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideCorpStep2")
  if growthprojectMgrB.PlayerWeakTip == nil then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[5] then
    if growthprojectMgrB.PlayerWeakTip[5].step[2] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideSocialIsland()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideSocialIsland")
  if growthprojectMgrB.PlayerWeakTip[6] then
    if growthprojectMgrB.PlayerWeakTip[6].step[1] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideSeasonStep1()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideSeasonStep1")
  if not growthprojectMgrB.PlayerWeakTip then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[7] then
    if growthprojectMgrB.PlayerWeakTip[7].step[1] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideSeasonStep2()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideSeasonStep2")
  if growthprojectMgrB.PlayerWeakTip[7] then
    if growthprojectMgrB.PlayerWeakTip[7].step[2] then
      return true
    else
      return false
    end
  end
  return false
end
function growthprojectMgrB.IsWeakGuideDeleteResidEntentry()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideDeleteResidEntentry")
  if not growthprojectMgrB.PlayerWeakTip or not growthprojectMgrB.PlayerWeakTip[8] then
    return false
  end
  if growthprojectMgrB.PlayerWeakTip[8].step and growthprojectMgrB.PlayerWeakTip[8].step[1] then
    return true
  end
  return false
end
function growthprojectMgrB.SaveCustomEntryData(keyWord, value)
  log(bWriteLog and "growthprojectMgrB.SaveCustomEntryData")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCustomEntry) or {}
  saveData[keyWord] = value
  log(bWriteLog and "[ZH] keyWord: " .. tostring(keyWord))
  log_tree("[ZH] saveData", saveData)
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eCustomEntry)
end
function growthprojectMgrB.IsWeakGuideCustomEntry()
  log(bWriteLog and "growthprojectMgrB.IsWeakGuideCustomEntry")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCustomEntry) or {}
  local system_entrance_config = DataMgr.roleData.system_entrance_config or {}
  local config = system_entrance_config[1] or {}
  growthprojectMgrB.entrance_count = system_entrance_config.entrance_count or 0
  growthprojectMgrB.last_entrance_show_guide = system_entrance_config.last_entrance_show_guide
  if not system_entrance_config or not system_entrance_config[1] then
    log(bWriteLog and "[ZH] system_entrance_config is nil")
    return
  end
  if DataMgr.roleData.level >= config.level and system_entrance_config.more_entrance_count and system_entrance_config.more_entrance_count == config.open_count and not saveData.hasTriggerCustomEntry then
    log(bWriteLog and "[ZH] condition one")
    return true, 7, true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if growthprojectMgrB.last_entrance_show_guide and curTime - growthprojectMgrB.last_entrance_show_guide < config.cd_hour * 3600 then
    log(bWriteLog and "[ZH] cd time is less")
    return false
  end
  if growthprojectMgrB.entrance_count > config.max_count then
    log(bWriteLog and "[ZH] show more times")
    return false
  end
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local serverData = logic_lobby_system_extension:GetServerData()
  if serverData and 0 < #serverData then
    log(bWriteLog and "[ZH] has show custom")
    return false
  end
  local idList = growthprojectMgrB.GetTimesByTime(saveData.tabTimesList, 24, config.enter_count or 0)
  if not idList or not next(idList) then
    log(bWriteLog and "[ZH] no id More than n time")
    return false
  end
  local mainSystemTable = CDataTable.GetTable("MainUISystem")
  local maxPriId = 7
  local maxPriValue = 100
  for k, v in pairs(idList) do
    if mainSystemTable[v] and mainSystemTable[v].Weights and maxPriValue > mainSystemTable[v].Weights then
      log(bWriteLog and "[ZH] maxPriId: " .. tostring(v))
      log(bWriteLog and "[ZH] mainSystemTable[v].Weights: " .. tostring(mainSystemTable[v].Weights))
      maxPriId = v
      maxPriValue = mainSystemTable[v].Weights
    end
  end
  return true, maxPriId
end
function growthprojectMgrB.GetTimesByTime(tabTimesList, someTime, clickTimes)
  log(bWriteLog and "growthprojectMgrB.GetTimesByTime")
  local idList = {}
  local time = someTime * 3600
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(tabTimesList or {}) do
    local num = 0
    for kk, clickTime in pairs(v) do
      if time > curTime - clickTime then
        num = num + 1
      end
    end
    if clickTimes <= num then
      table.insert(idList, k)
    end
  end
  log_tree("[ZH] idList", idList)
  return idList
end
function growthprojectMgrB.IsGetNewPlayerGift()
  log(bWriteLog and "growthprojectMgrB.IsGetNewPlayerGift")
  if growthprojectMgrB.IsFinishAllNewGuide() then
    return true
  end
  local res_id = growthprojectMgrB.GetDepotGuideItemId()
  if res_id and 1 < res_id then
    return true
  end
  return false
end
function growthprojectMgrB.InGameRecordGrowthGuideInfo(id)
  log(bWriteLog and "growthprojectMgrB.InGameRecordGrowthGuideInfo id = " .. tostring(id))
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIGHT_GUIDE = 101
  DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIGHT_GUIDE, id)
end
function growthprojectMgrB.CheckNeedMatchEntryGuide()
  log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide")
  if growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide finish newbie guide")
    return false
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = LogicNewbie.newbieTotalGameCnt
  log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide enter_game_num = " .. tostring(enter_game_num))
  local canStartMatchEntryGuide = false
  if DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIGHT_GUIDE, -2) then
    log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide finish newbie guide 1")
    canStartMatchEntryGuide = enter_game_num and 1 <= enter_game_num
  else
    log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide finish newbie guide 2")
    canStartMatchEntryGuide = enter_game_num and 2 <= enter_game_num
  end
  log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide finish newbie guide canStartMatchEntryGuide = " .. tostring(canStartMatchEntryGuide))
  if not canStartMatchEntryGuide then
    return false
  end
  local LastGuide = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE
  local guidetb = DataMgr.newbieGuide[LastGuide]
  log_tree(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide guidetb = ", guidetb)
  if guidetb == nil or not next(guidetb) then
    return false
  end
  local bHaveNewbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_ENTRY_GUIDE, 1)
  log(bWriteLog and "growthprojectMgrB.CheckNeedMatchEntryGuide bHaveNewbieGuide = " .. tostring(bHaveNewbieGuide))
  if not bHaveNewbieGuide then
    return false
  end
  return true
end
function growthprojectMgrB.EnterWoWHallNewbieBranch()
  log(bWriteLog and "growthprojectMgrB.EnterWoWHallNewbieBranch")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  Util_UGC.SetUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterWoWNewHall)
end
function growthprojectMgrB.CheckEnterWoWHallNewbieBranch()
  log(bWriteLog and "growthprojectMgrB.CheckEnterWoWHallNewbieBranch")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  return Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterWoWNewHall)
end
function growthprojectMgrB.CheckEndWoWHallWoWNewbieGuide()
  log(bWriteLog and "growthprojectMgrB.CheckEndWoWHallWoWNewbieGuide")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  return Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterWoWHallNewbieEnd)
end
return growthprojectMgrB