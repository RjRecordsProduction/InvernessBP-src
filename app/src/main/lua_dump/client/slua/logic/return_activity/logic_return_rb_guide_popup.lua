local logic_return_rb_guide_popup = {}
local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
local timeUtil = require("client.common.time_util")
local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
function logic_return_rb_guide_popup:DefineAndResetData()
  self.tShowRecord = {}
  self.showPopList = {
    [1] = {
      popType = return_activity_macro.Enum_RightBottom_Guide_Popup_Type.TeamUp,
      checkShowFunc = self.CheckRBGuideTeamUpPopup,
      uiName = "Return_Team_Recommend_UIBP"
    },
    [2] = {
      popType = return_activity_macro.Enum_RightBottom_Guide_Popup_Type.StartGame,
      checkShowFunc = self.CheckRBGuideStartGamePopup,
      uiName = "Return_Team_Guidance_UIBP"
    },
    [3] = {
      popType = return_activity_macro.Enum_RightBottom_Guide_Popup_Type.ShareCard,
      checkShowFunc = self.CheckRBGuideShareCardPopup,
      uiName = "Return_Team_Guidance_UIBP"
    }
  }
  self.startGameCfg = {
    firstGame = {
      title = 78331,
      desc = 78337,
      btnType = 4,
      goFunc = self.StartGame
    },
    shareCard = {
      title = 78339,
      desc = 78340,
      btnType = 1,
      goFunc = self.OpenFrdSideBar
    },
    guideType = {
      [return_activity_macro.Enum_Guide_Type.Achievement] = {title = 78327, desc = 78333},
      [return_activity_macro.Enum_Guide_Type.Social] = {title = 78328, desc = 78334},
      [return_activity_macro.Enum_Guide_Type.Content] = {title = 78329, desc = 78335},
      [return_activity_macro.Enum_Guide_Type.TryNeW] = {title = 78330, desc = 78336},
      [return_activity_macro.Enum_Guide_Type.Unknow] = {title = 78330, desc = 78336},
      btnType = 1,
      goFunc = self.StartGame
    }
  }
  self.checkCD = 0
  self.lastCheckTime = nil
  self.checkTimerID = nil
  self.sShowingPopupUIName = ""
end
function logic_return_rb_guide_popup:_CheckPrerequisites()
  if IsWoWEditor then
    return false
  end
  for index, popCfg in ipairs(self.showPopList) do
    if popCfg.checkShowFunc then
      local result = popCfg.checkShowFunc(self)
      if result == true then
        log_format("logic_return_rb_guide_popup:_CheckPrerequisites found displayable popup at index:%s", tostring(index))
        self.sShowingPopupUIName = popCfg.uiName
        return index
      elseif result == 0 then
        log(bWriteLog and "logic_return_rb_guide_popup:_CheckPrerequisites need continue checking but not show")
        return 0
      end
    end
  end
  log(bWriteLog and "logic_return_rb_guide_popup:_CheckPrerequisites no displayable popup found")
  return false
end
function logic_return_rb_guide_popup:RemoveCheckTimer()
  log(bWriteLog and "logic_return_rb_guide_popup:RemoveCheckTimer removing check timer")
  if self.checkTimerID then
    self:RemoveTimer(self.checkTimerID)
    self.checkTimerID = nil
    self.lastCheckTime = nil
  end
end
function logic_return_rb_guide_popup:_StartDetectingFree()
  log(bWriteLog and "logic_return_rb_guide_popup:_StartDetectingFree start detecting free")
  log_tree(bWriteLog and "logic_return_rb_guide_popup, back_uesr_data", DataMgr.roleData.back_user_data)
  self:RemoveCheckTimer()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.backuser_client_guide_popup_cfg, function(cfgName, cfg)
    log_tree(bWriteLog and "logic_return_rb_guide_popup:_StartDetectingFree cfg", cfg)
    local backUserData = DataMgr.roleData.back_user_data
    self.checkCD = backUserData and backUserData.BackUserGuidePopupStartCheckCD or 30
    local startCheckTime = backUserData and backUserData.BackUserGuidePopupStartCheckTime or 130
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    self.checkTimerID = self:AddTimerLoop(startCheckTime, function()
      if self:CanShowRBGuide() then
        local index = self:_CheckPrerequisites()
        if index == 0 then
          return
        end
      end
    end, TIMER_INFINITE, 5)
  end)
  self:_CheckVersionUpdateGuide()
end
function logic_return_rb_guide_popup:_CheckDetectingFree()
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local tTask = {
    module = logic_return_rb_guide_popup,
    protect = true,
    funcName = "_StartDetectingFree",
    debugInfo = "logic_return_rb_guide_popup#_CheckDetectingFree"
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, tTask)
end
function logic_return_rb_guide_popup:_OnUIHide(_, _, keyName)
  for i, v in ipairs(self.showPopList) do
    if keyName == v.uiName then
      self.sShowingPopupUIName = ""
      break
    end
  end
end
function logic_return_rb_guide_popup:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self._OnUIHide, self)
end
function logic_return_rb_guide_popup:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity() then
    self:RemoveAllTimer()
  end
end
function logic_return_rb_guide_popup:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:_StartDetectingFree()
  end
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting() then
    self:_StartDetectingFree()
  end
end
function logic_return_rb_guide_popup:StartGame()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if Lobby_Main_UIBP then
    local matchEntry = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.match_new_entry)
    if matchEntry then
      matchEntry:OnClickEntry()
    end
  end
end
function logic_return_rb_guide_popup:OpenFrdSideBar()
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.LOBBY)
end
function logic_return_rb_guide_popup:CanShowRBGuide()
  if self.sShowingPopupUIName ~= "" then
    log(bWriteLog and string.format("logic_return_rb_guide_popup:CanShowRBGuide ui showing, uiName:%s", self.sShowingPopupUIName))
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  if not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide not IsAndroidStackEmpty")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local EPawnState = import("EPawnState")
  self.isMoving = false
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:HasState(EPawnState.Move) then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide is moving")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local uPS = GameplayData.GetPlayerState()
  if slua.isValid(uPS) and uPS.InteractivePlayerStateFeature and uPS.InteractivePlayerStateFeature.IsInteractiveStateIdle and not uPS.InteractivePlayerStateFeature:IsInteractiveStateIdle() then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide not Idle")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local commonConfig = require("client.slua.common.common_config")
  if commonConfig:IsBlockingPopupTip() then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide UI responsiveness testing blocked")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local lobbyMainCityEnter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if lobbyMainCityEnter.bEnterMainCityLoading then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide main city loading in progress")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local teamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if teamUpNewSystem.IsInTeam() then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide already in team")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local matchSystem = require("client.slua.logic.match.logic_match")
  if matchSystem.nMatchStatus == ENUM_MatchStatus.Matching then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide matching in progress")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local socialPersonSpaceUIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  local lobbyMainControl = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if lobbyMainControl.curPage == ENUM_LobbyPageType.Right or lobbyMainControl.curPage == ENUM_LobbyPageType.Left or socialPersonSpaceUIBP and socialPersonSpaceUIBP:IsShow() then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide lobby page showing")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if NewFaceSlapSystem:IsInSlap() then
    local notEndAndCanShow = not NewFaceSlapSystem:IsSlapEnd() and NewFaceSlapSystem:IsCanShow()
    if notEndAndCanShow then
      log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide in slap")
      self.lastCheckTime = timeUtil.GetServerTimeInSec()
      return false
    end
  end
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  if logic_team_up.IsInviteUIReadyToShow() or logic_team_up.IsInviteUIShow() then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide IsInviteUIReadyToShow or IsInviteUIShow")
    self.lastCheckTime = timeUtil.GetServerTimeInSec()
    return false
  end
  if self.lastCheckTime and timeUtil.GetServerTimeInSec() - self.lastCheckTime < self.checkCD then
    log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide checkCD not ready")
    return false
  end
  log(bWriteLog and "logic_return_rb_guide_popup:CanShowRBGuide all checks passed")
  self.lastCheckTime = timeUtil.GetServerTimeInSec()
  return true
end
function logic_return_rb_guide_popup:CheckRBGuidePopupCommon(guideType, limitCfg)
  local logicReturnActivityUtils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local bIsReturnPlayer = logicReturnActivityUtils.IsActInProgress()
  if bIsReturnPlayer then
    local backUserData = DataMgr.roleData and DataMgr.roleData.back_user_data
    if not backUserData then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon back user data not found, guideType:" .. tostring(guideType))
      return false
    end
    local noLoginDayLimit = limitCfg.no_login_days or 28
    local currentNoLoginDays = tonumber(backUserData.no_login_days) or 0
    if noLoginDayLimit > currentNoLoginDays then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon no login days not enough, guideType:" .. tostring(guideType) .. " current:" .. tostring(currentNoLoginDays) .. " limit:" .. tostring(noLoginDayLimit))
      return false
    end
    local validDayLimit = limitCfg.login_days or 7
    local rejoinStartTime = tonumber(backUserData.rejoin_start_time) or 0
    local rejoinDays = math.ceil((timeUtil.GetServerTimeInSec() - rejoinStartTime) / 86400)
    if validDayLimit < rejoinDays then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon rejoin days exceed limit, guideType:" .. tostring(guideType) .. " current:" .. tostring(rejoinDays) .. " limit:" .. tostring(validDayLimit))
      return false
    end
  end
  local showPerDayLimit = limitCfg.daily_pop_cnt or 1
  local saveData = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew) or {}
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  if saveData[guideType] then
    local currentShowTime = self:CountTodayShowTimes(saveData[guideType])
    if guideType == "TeamUp" then
      currentShowTime = logic_return_team_recommend:GetShowCnt()
    end
    if showPerDayLimit <= currentShowTime then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon daily show limit reached, guideType:" .. tostring(guideType) .. " current:" .. tostring(currentShowTime) .. " limit:" .. tostring(showPerDayLimit))
      return false
    end
    local backUserData = DataMgr.roleData and DataMgr.roleData.back_user_data
    local totalShowLimit = backUserData and backUserData.BackUserGuidePopupShowDayLimit or 2
    local totalShowCnt = self:GetTodayAllPopShowCnt()
    if totalShowLimit <= totalShowCnt then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon daily show total limit reached, guideType:" .. tostring(guideType) .. " current:" .. tostring(currentShowTime) .. " limit:" .. tostring(totalShowLimit))
      return false
    end
  end
  local showPerLoginLimit = limitCfg.pop_cnt_per_login
  if self.tShowRecord and self.tShowRecord[guideType] then
    local currentLoginShowTime = self:CountTodayShowTimes(self.tShowRecord[guideType])
    if guideType == "TeamUp" then
      currentLoginShowTime = logic_return_team_recommend:GetShowCnt()
    end
    if showPerLoginLimit <= currentLoginShowTime then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon login show limit reached, guideType:" .. tostring(guideType) .. " current:" .. tostring(currentLoginShowTime) .. " limit:" .. tostring(showPerLoginLimit))
      return false
    end
  end
  log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuidePopupCommon all checks passed, guideType:" .. tostring(guideType))
  return true
end
function logic_return_rb_guide_popup:GetTodayAllPopShowCnt()
  local saveData = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew) or {}
  local totalShowCnt = 0
  local guideTypes = {
    "startGame",
    "TeamUp",
    "shareCard"
  }
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  for _, guideType in ipairs(guideTypes) do
    if saveData[guideType] then
      local todayShowCnt = self:CountTodayShowTimes(saveData[guideType])
      if guideType == "TeamUp" then
        totalShowCnt = logic_return_team_recommend:GetShowCnt()
      end
      totalShowCnt = totalShowCnt + todayShowCnt
      log_format("logic_return_rb_guide_popup:GetTodayAllPopShowCnt guideType:%s todayCount:%s", guideType, tostring(todayShowCnt))
    end
  end
  log_format("logic_return_rb_guide_popup:GetTodayAllPopShowCnt totalShowCnt:%s", tostring(totalShowCnt))
  return totalShowCnt
end
function logic_return_rb_guide_popup:CountTodayShowTimes(showData)
  if not showData or type(showData) ~= "table" then
    return 0
  end
  local currentShowTime = 0
  local currentTime = timeUtil.GetServerTimeInSec()
  if showData[1] then
    for i, v in ipairs(showData) do
      if v and v.time and timeUtil.IsSameDay(v.time, currentTime) then
        currentShowTime = currentShowTime + 1
      end
    end
  end
  return currentShowTime
end
function logic_return_rb_guide_popup:CheckRBGuideStartGamePopup()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerRBGuideWeekNoShow) or {}
  local lastShowTime = saveData[return_activity_macro.Enum_RightBottom_Guide_Popup_Type.StartGame]
  if lastShowTime and TimeUtil.IsSameWeek(lastShowTime, TimeUtil.GetServerTimeInSec()) then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideStartGamePopup return not show this week")
    return false
  end
  local logicReturnActivityUtils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logicReturnActivityUtils.IsActInProgress() then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideStartGamePopup return activity not in progress")
    return false
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  if not logic_return_activity_guide:IsHitABTest() then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideStartGamePopup AB test not hit")
    return false
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfg = BasicDataServerTable:GetCacheData(data_config_marco.backuser_client_guide_popup_cfg)
  local result = self:CheckRBGuidePopupCommon("startGame", cfg[return_activity_macro.Enum_RightBottom_Guide_Popup_Type.StartGame])
  if not result then
    return false
  end
  local bIsSuccess = self:OpenRBGuideStartGamePopup() ~= nil
  return bIsSuccess
end
function logic_return_rb_guide_popup:OpenRBGuideStartGamePopup(guideType, subType)
  if IsWoWEditor then
    return false
  end
  local guideType = guideType or self:GetStartGameGuideType()
  local guideCfg = self.startGameCfg[guideType]
  if not guideCfg then
    log(bWriteLog and string.format("logic_return_rb_guide_popup:OpenRBGuideStartGamePopup guideCfg is nil, guideType=%s", tostring(guideType)))
    return false
  end
  if guideType == "guideType" then
    local textCfg = guideCfg[subType or DataMgr.roleData.back_user_data.guide_profile_id]
    textCfg = textCfg or guideCfg[return_activity_macro.Enum_Guide_Type.Unknow]
    guideCfg.title = textCfg.title
    guideCfg.desc = textCfg.desc
  end
  guideCfg.type = return_activity_macro.Enum_RightBottom_Guide_Popup_Type.StartGame
  guideCfg.  local guideType2Enum = {
    firstGame = 1,
    shareCard = 2,
    guideType = 3
  }
  local popCfg = CDataTable.GetTable("ReturnGuidePopupCfg")
  local StringUtil = require("common.string_util")
  local icons = StringUtil.Split(popCfg[1].icons, "|")
  guideCfg.icon = icons[guideType2Enum[guideType]]
  local bIsSuccess = UIManager.ShowUI(UIManager.UI_Config.Return_Team_Guidance_UIBP, guideCfg) ~= nil
  return bIsSuccess
end
function logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup()
  local logicModeSelection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logicModeSelection and logicModeSelection:IsSingleMode() then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup is single mode")
    return false
  end
  local teamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local canTeamUp = teamUpNewSystem.CanTeamUp(false)
  if not canTeamUp then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup cannot team up")
    return false
  end
  local friendHandler = require("client.network.Protocol.FriendHandler")
  if friendHandler.friend_status_data then
    local selfStatusID = friendHandler.friend_status_data.sub_status_id or 0
    local cfg = CDataTable.GetTableData("FriendStatusCfg", selfStatusID)
    if cfg and (cfg.type == 7 or cfg.type == 6) then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup self status invisible or busy")
      return false
    end
  end
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  local logicReturnActivityUtils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if logicReturnActivityUtils.IsActInProgress() then
    local isHitABTest = logic_return_team_recommend:CheckShareCardABTest()
    if not isHitABTest then
      log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup AB test not hit")
      return false
    end
  else
    local dayShowTime, weekShowTime = logic_return_team_recommend:GetShowCnt()
    if 2 <= weekShowTime then
      log(bWriteLog and "logic_return_team_recommend:CheckRBGuideTeamUpPopup is show 2 time this week")
      return false
    elseif 1 <= dayShowTime then
      log(bWriteLog and "logic_return_team_recommend:CheckRBGuideTeamUpPopup is show 1 time today")
      return false
    end
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfg = BasicDataServerTable:GetCacheData(data_config_marco.backuser_client_guide_popup_cfg)
  local result = self:CheckRBGuidePopupCommon("TeamUp", cfg[return_activity_macro.Enum_RightBottom_Guide_Popup_Type.TeamUp])
  if not result then
    return false
  end
  local recUID = logic_return_team_recommend:GetRecommendUID()
  if not recUID then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup recommend uid is nil")
    return false
  end
  if recUID == 0 then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup recommend uid is 0, continue checking")
    return 0
  end
  local bIsSuccess = logic_return_team_recommend:ShowRBGuideTeamUpPopup(recUID) ~= nil
  log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideTeamUpPopup showing popup for uid:" .. tostring(recUID))
  return bIsSuccess
end
function logic_return_rb_guide_popup:CheckRBGuideShareCardPopup()
  if IsWoWEditor then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerRBGuideWeekNoShow) or {}
  local lastShowTime = saveData[return_activity_macro.Enum_RightBottom_Guide_Popup_Type.ShareCard]
  if lastShowTime and TimeUtil.IsSameWeek(lastShowTime, TimeUtil.GetServerTimeInSec()) then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideShareCardPopup return not show this week")
    return false
  end
  local logicReturnActivityUtils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logicReturnActivityUtils.IsActInProgress() then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideShareCardPopup return activity not in progress")
    return false
  end
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  local isHitABTest = logic_return_team_recommend:CheckShareCardABTest()
  if not isHitABTest then
    log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideShareCardPopup AB test not hit")
    return false
  end
  if not self:_CheckShareCardBasicConditions() then
    return false
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfg = BasicDataServerTable:GetCacheData(data_config_marco.backuser_client_guide_popup_cfg)
  local result = self:CheckRBGuidePopupCommon("shareCard", cfg[return_activity_macro.Enum_RightBottom_Guide_Popup_Type.ShareCard])
  if not result then
    return false
  end
  local guideCfg = {
    type = return_activity_macro.Enum_RightBottom_Guide_Popup_Type.ShareCard,
    title = 78332,
    desc = 78338,
    btnType = 1,
    goFunc = function()
      logic_return_team_recommend:OpenShareCardUI()
    end
  }
  local bIsSuccess = UIManager.ShowUI(UIManager.UI_Config.Return_Team_Guidance_UIBP, guideCfg) ~= nil
  log(bWriteLog and "logic_return_rb_guide_popup:CheckRBGuideShareCardPopup showing share card popup")
  return bIsSuccess
end
function logic_return_rb_guide_popup:_CheckShareCardBasicConditions()
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo or not shareCardInfo.share_card_info then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckShareCardBasicConditions share card info not found")
    return false
  end
  local dailyShareCount = shareCardInfo.share_card_info.daily_share_cnt or 0
  local dailyShareLimit = shareCardInfo.BackUserShareCardDailyLimit or 3
  if dailyShareCount >= dailyShareLimit then
    log_format("logic_return_rb_guide_popup:_CheckShareCardBasicConditions daily share limit reached, count:%s limit:%s", tostring(dailyShareCount), tostring(dailyShareLimit))
    return false
  end
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local shareCardItemID = 2155001
  local itemCount = wardrobeData:GetHallDepotItemCountByResID(shareCardItemID)
  if itemCount == 0 then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckShareCardBasicConditions no share card items available")
    return false
  end
  local logicFriend = require("client.slua.logic.friend.logic_new_friend")
  if not logicFriend.IsAtLeastOneOnlineAndFree() then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckShareCardBasicConditions no online and free friends")
    return false
  end
  log(bWriteLog and "logic_return_rb_guide_popup:_CheckShareCardBasicConditions all basic conditions met")
  return true
end
function logic_return_rb_guide_popup:UpdateGuideShowTimes(guideType, data)
  if not self.tShowRecord then
    self.tShowRecord = {}
  end
  if not self.tShowRecord[guideType] then
    self.tShowRecord[guideType] = {}
  end
  table.insert(self.tShowRecord[guideType], data)
  log_format("logic_return_rb_guide_popup:UpdateGuideShowTimes updated memory record for type:%s", guideType)
  local saveData = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew) or {}
  if not saveData[guideType] then
    saveData[guideType] = {}
  end
  if guideType == "TeamUp" then
    if not saveData.TeamUp[data.uid] then
      saveData.TeamUp[data.uid] = {}
    end
    saveData.TeamUp[data.uid][data.time] = true
  else
    table.insert(saveData[guideType], data)
  end
  playerPrefsSystem.SaveTableToFile_N(saveData, playerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew)
  log_format("logic_return_rb_guide_popup:UpdateGuideShowTimes updated persistent record for type:%s", guideType)
end
function logic_return_rb_guide_popup:_CheckVersionUpdateGuide()
  log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide start checking version update guide")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerRBGuideWeekNoShow) or {}
  local lastShowTime = saveData[return_activity_macro.Enum_RightBottom_Guide_Popup_Type.VersionUpdate]
  if lastShowTime and TimeUtil.IsSameWeek(lastShowTime, TimeUtil.GetServerTimeInSec()) then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide return not show this week")
    return false
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide activity not in progress")
    return false
  end
  local logic_player_return_slap = require("client.slua.logic.player_return.logic_player_return_slap")
  if logic_player_return_slap.bIsShowReturnFlag then
    log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI return of bIsShowReturnFlag")
    return false
  end
  local versionUpdateCfg = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.version_update_guide_cfg
  if not versionUpdateCfg then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide version update config not found")
    return false
  end
  local saveData = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew) or {}
  if saveData.versionUpdate and self:CountTodayShowTimes(saveData.versionUpdate) >= 1 then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide daily show limit reached")
    return false
  end
  if self.updateTimer then
    self:RemoveTimer(self.updateTimer)
    self.updateTimer = nil
  end
  self.updateTimer = self:AddTimerLoop(30, function()
    if self:CanShowRBGuide() then
      self:_ShowVersionUpdateGuide(versionUpdateCfg)
      self:RemoveTimer(self.updateTimer)
      self.updateTimer = nil
    end
  end, TIMER_INFINITE, 5)
  log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide timer started successfully")
  return true
end
function logic_return_rb_guide_popup:_ShowVersionUpdateGuide(versionUpdateCfg)
  log(bWriteLog and "logic_return_rb_guide_popup:_ShowVersionUpdateGuide showing version update guide")
  if IsWoWEditor then
    return
  end
  local guideCfg = {
    type = return_activity_macro.Enum_RightBottom_Guide_Popup_Type.VersionUpdate,
    title = LocUtil.GetLocalizeResStr(78343),
    desc = versionUpdateCfg.daily_text,
    icon = versionUpdateCfg.daily_cdn_url,
    btnType = 3,
    goFunc = function()
      self:HandleVersionUpdateJump()
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Return_Team_Guidance_UIBP, guideCfg)
end
function logic_return_rb_guide_popup:HandleVersionUpdateJump()
  log(bWriteLog and "logic_return_rb_guide_popup:HandleVersionUpdateJump handling version update jump")
  local SubsideFeatureLevelMacros = require("client.slua.config.ClientMacros.SubsideFeatureLevelMacros")
  local subsideFeatureLevel = Client.GetSubsideFeatureLevel()
  if subsideFeatureLevel == SubsideFeatureLevelMacros.Default then
    log(bWriteLog and "logic_return_rb_guide_popup:HandleVersionUpdateJump jumping to download app")
    FuncUtil.JumpToDownloadApp()
  else
    log(bWriteLog and "logic_return_rb_guide_popup:HandleVersionUpdateJump jumping to official site")
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
    logic_region_block.JumpToOfficialSite(login_module.sIpRegion or "ALL")
  end
end
function logic_return_rb_guide_popup:GetVersionUpdateContent()
  local roleData = DataMgr.roleData
  if not roleData then
    return {}
  end
  local backUserData = roleData.back_user_data
  if not backUserData then
    log(bWriteLog and "logic_return_rb_guide_popup:GetVersionUpdateContent backUserData is nil")
    return {}
  end
  local versionUpdateCfg = backUserData.version_update_guide_cfg
  if not versionUpdateCfg then
    log(bWriteLog and "logic_return_rb_guide_popup:_CheckVersionUpdateGuide version update config not found")
    return {}
  end
  local content = {}
  for i = 1, 7 do
    local keyDesc = "first_day_text" .. i
    local keyUrl = "first_cdn_url" .. i
    local desc = versionUpdateCfg[keyDesc]
    local cdnUrl = versionUpdateCfg[keyUrl]
    if desc and cdnUrl then
      table.insert(content, {
        pic_url = cdnUrl,
        func_desc_2 = desc,
        bServerTranslate = true
      })
    end
  end
  return content
end
function logic_return_rb_guide_popup:GetStartGameGuideType()
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not userData then
    return ""
  end
  if LobbySystem.CheckOpen(32020) and userData.daily_battle_data and userData.daily_battle_data.status and userData.daily_battle_data.status == 0 then
    return "firstGame"
  end
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if shareCardInfo and not shareCardInfo.is_share_card_sent and logic_return_team_recommend:CheckShareCardExist() and LogicFriend.IsAtLeastOneOnlineAndFree() then
    return "shareCard"
  end
  return "guideType"
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_rb_guide_popup = class(CModuleBase, nil, logic_return_rb_guide_popup)
return Clogic_return_rb_guide_popup