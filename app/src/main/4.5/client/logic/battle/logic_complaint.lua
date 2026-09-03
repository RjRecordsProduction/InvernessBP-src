local ComplaintConfig = require("client.slua.umg.complaint.complaint_config")
local EComplaintModule = ComplaintConfig.EComplaintModule
local EComplaintSceneTLogType = ComplaintConfig.EComplaintSceneTLogType
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local SecurityClientUtils = require("GameLua.Mod.BaseMod.Client.Security.SecurityClientUtils")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local IsNonemptyString = SecurityCommonUtils.IsNonemptyString
local IsString = SecurityCommonUtils.IsString
local FormatLog = FuncUtil.FormatLog
local bIsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local StaticShowSecurityAlertInDev = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent").StaticShowSecurityAlertInDev
local LogicComplaint = {
  _tAlreadyReportedPlayers = {}
}
LogicComplaint.EComplaintFrom = ComplaintConfig.EComplaintFrom
local tMaskingOutBattleIDSceneTLogTypeMap = {
  [EComplaintSceneTLogType.LobbyRoleInfo] = true,
  [EComplaintSceneTLogType.MomentPost] = true,
  [EComplaintSceneTLogType.MomentComment] = true,
  [EComplaintSceneTLogType.Corpus] = true,
  [EComplaintSceneTLogType.ChatText] = true,
  [EComplaintSceneTLogType.ChatPortrait] = true,
  [EComplaintSceneTLogType.ChatNickname] = true
}
local _IsInBattleResult = function()
  local uController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uController) then
    FormatLog("invalid controller")
    return false
  end
  if uController.bIsInResultView then
    return true
  end
  FormatLog("uController.bIsInResultView=%s", uController.bIsInResultView)
  return false
end
function LogicComplaint.ShowComplaint(sFrom, tExtraParam)
  FormatLog("sFrom=%s", tostring(sFrom))
  if type(sFrom) ~= "string" then
    sFrom = ComplaintConfig.EComplaintFrom.Default
  end
  tExtraParam = tExtraParam or {}
  tExtraParam.  if LogicComplaint.IsShowDeathMatchResult() then
    LogicComplaint.ShowHandle(EComplaintModule.DeathMatch, tExtraParam, true)
  elseif LogicComplaint.IsShowBattleResultInfection() then
    LogicComplaint.ShowHandle(EComplaintModule.Infection, tExtraParam, true)
  elseif LogicComplaint.IsShowBattleResultVehicle() then
    LogicComplaint.ShowHandle(EComplaintModule.Vehicle, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.SocialIsland then
    LogicComplaint.ShowHandle(EComplaintModule.SocialIsland, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.Lobby then
    LogicComplaint.ShowHandle(EComplaintModule.Lobby, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.Chat then
    LogicComplaint.ShowHandle(EComplaintModule.Chat, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.Moment then
    LogicComplaint.ShowHandle(EComplaintModule.Moment, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.DeathMatchHistory then
    LogicComplaint.ShowHandle(EComplaintModule.DeathMatch, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.Wonderful then
    LogicComplaint.ShowHandle(EComplaintModule.Wonderful, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.DeathReplay then
    LogicComplaint.ShowHandle(EComplaintModule.DeathReplay, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.XMissionMetro then
    LogicComplaint.ShowHandle(EComplaintModule.XMissionMetro, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.Escape then
    LogicComplaint.ShowHandle(EComplaintModule.Escape, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.UGC then
    LogicComplaint.ShowHandle(EComplaintModule.UGC, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.UGCCopy then
    LogicComplaint.ShowHandle(EComplaintModule.UGCCopy, tExtraParam, true)
  elseif sFrom == ComplaintConfig.EComplaintFrom.UGCRank then
    LogicComplaint.ShowHandle(EComplaintModule.UGCRank, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.UGCCollections then
    LogicComplaint.ShowHandle(EComplaintModule.UGCCollections, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.HomeMessage then
    LogicComplaint.ShowHandle(EComplaintModule.HomeMessage, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.UGCVideo then
    LogicComplaint.ShowHandle(EComplaintModule.UGCRecommendVideo, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.IntimateRelation then
    LogicComplaint.ShowHandle(EComplaintModule.IntimateRelation, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.TeamQuick then
    LogicComplaint.ShowHandle(EComplaintModule.TeamQuick, tExtraParam, false)
  elseif sFrom == ComplaintConfig.EComplaintFrom.PlanBT then
    LogicComplaint.ShowHandle(EComplaintModule.PlanBT, tExtraParam, true)
  else
    LogicComplaint.ShowHandle(EComplaintModule.Classic, tExtraParam, true)
  end
end
function LogicComplaint.ShowHandle(sComplaintModule, tExtraParam, bIsMountToParent, tParentUI)
  if type(sComplaintModule) ~= "string" then
    return
  end
  tExtraParam = tExtraParam or {}
  FormatLog("sComplaintModule=%s", sComplaintModule)
  LogicComplaint._sCurrentComplaintModule = sComplaintModule
  tExtraParam.  LogicComplaint._bIsBattleHistory = false
  if tExtraParam and tExtraParam.bIsBattleHistory then
    LogicComplaint._bIsBattleHistory = true
  end
  LogicComplaint._bIsHistoryInTxmission = tExtraParam and tExtraParam.bIsHistoryInTxmission
  local nBattleTime
  if tExtraParam then
    nBattleTime = tonumber(tExtraParam.nBattleTime)
  end
  if not nBattleTime or not (0 < nBattleTime) then
    nBattleTime = 0
  end
  LogicComplaint._  local nPlayerCount
  if tExtraParam then
    nPlayerCount = tonumber(tExtraParam.nPlayerCount)
  end
  if not nPlayerCount or not (0 < nPlayerCount) then
    nPlayerCount = 1
  end
  LogicComplaint._  local sFrom
  if tExtraParam then
    sFrom = tExtraParam.sFrom
  end
  if type(sFrom) ~= "string" then
    sFrom = ""
  end
  LogicComplaint._  local sUIName = ComplaintConfig.EComplaintUI[sComplaintModule].sUIName
  local sReasonType = ComplaintConfig.EComplaintUI[sComplaintModule].sReasonType
  if bIsMountToParent and not tParentUI then
    tParentUI = UIManager.ShowUI(UIManager.UI_Config.ui_complaint_base)
  end
  log(bWriteLog and "LogicComplaint.ShowHandle sUIName:" .. tostring(sUIName))
  if not UIManager.UI_Config[sUIName] then
    return
  end
  LogicComplaint._tComplaintPanel = UIManager.ShowUI(UIManager.UI_Config[sUIName], sReasonType, tExtraParam, tParentUI)
  if bIsMountToParent and tParentUI and tParentUI.SetChildWidget then
    tParentUI:SetChildWidget(LogicComplaint._tComplaintPanel)
  end
  return LogicComplaint._tComplaintPanel
end
function LogicComplaint.ReturnToLobby()
  if not slua.isValid(LogicComplaint._tComplaintPanel) then
    LogicComplaint._tComplaintPanel = nil
    return
  end
  if LogicComplaint._tComplaintPanel.CloseWindow then
    LogicComplaint._tComplaintPanel:CloseWindow(false)
  end
  LogicComplaint._tComplaintPanel = nil
end
function LogicComplaint.ClearPanel()
  if not slua.isValid(LogicComplaint._tComplaintPanel) then
    LogicComplaint._tComplaintPanel = nil
    return
  end
  if LogicComplaint._tComplaintPanel.CloseWindow then
    LogicComplaint._tComplaintPanel:CloseWindow(false)
  end
  LogicComplaint._tComplaintPanel = nil
end
function LogicComplaint.GetSelectReasonMax()
  return ComplaintConfig.EComplaintUI[LogicComplaint.GetCurrentComplaintModule()].nNumSelectedReasonMax
end
function LogicComplaint.SetBattleID(nBattleID)
  if type(nBattleID) ~= "number" then
    return
  end
  g_game_id = nBattleID
end
function LogicComplaint.GetBattleID()
  if type(g_game_id) ~= "number" then
    return 0
  end
  return g_game_id
end
function LogicComplaint.SetPlayerCountByGameState()
  local ASTExtraGameStateBase = import("STExtraGameStateBase")
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not Game:IsClassOf(uGameState, ASTExtraGameStateBase) then
    return
  end
  LogicComplaint._nPlayerCount = uGameState.PlayerNum
  FormatLog("uGameState.PlayerNum=%d", LogicComplaint._nPlayerCount)
end
function LogicComplaint.IsBattleHistory()
  return LogicComplaint._bIsBattleHistory
end
function LogicComplaint.GetTeammatesInBattleHistory()
  if LogicComplaint.IsShowDeathMatchHistory() then
    FormatLog("no teammate in death match history")
    return {}
  end
  if not LogicComplaint.IsBattleHistory() then
    return {}
  end
  local tBattleRecord = LogicComplaint.GetBattleHistoryRawData(LogicComplaint.GetBattleID())
  if not tBattleRecord then
    return {}
  end
  local tBattleRecordTeammateList = tBattleRecord.TeammateList
  if not tBattleRecordTeammateList or not next(tBattleRecordTeammateList) then
    return {}
  end
  local tResultArray = {}
  for _, tTeammateInfo in pairs(tBattleRecordTeammateList) do
    table.insert(tResultArray, {
      sPlayerName = tTeammateInfo.Name,
      nUID = tonumber(tTeammateInfo.UID)
    })
  end
  return tResultArray
end
function LogicComplaint.GetBattleHistoryRawData(nBattleID)
  nBattleID = tonumber(nBattleID)
  if not nBattleID then
    return {}
  end
  if LogicComplaint._bIsHistoryInTxmission then
    local logic_xmission_history_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_history_record)
    return logic_xmission_history_record:GetHistoryRecordDetailInfo(tonumber(DataMgr.roleData.uid), nBattleID) or {}
  end
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  if not RoleInfoHistorySystem then
    return {}
  end
  if not RoleInfoHistorySystem.role_history_record then
    return {}
  end
  local tBattleRecord = RoleInfoHistorySystem.role_history_record[nBattleID]
  if not tBattleRecord then
    return {}
  end
  return tBattleRecord
end
function LogicComplaint.IsShowDeathMatchResult()
  if not _IsInBattleResult() then
    return false
  end
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem and BattleResultSubSystem:InResultProcess() and BattleResultSubSystem.IsTDM then
    return true
  end
  return false
end
function LogicComplaint.IsShowDeathMatchHistory()
  return LogicComplaint._sFrom == ComplaintConfig.EComplaintFrom.DeathMatchHistory
end
function LogicComplaint.IsShowBattleResultInfection()
  if BattleResultInfectionUI and BattleResultInfectionUI.GetIsUIBP_Active() then
    return true
  end
  return false
end
function LogicComplaint.IsShowBattleResultVehicle()
  if BattleResultVehicleUI and BattleResultVehicleUI.GetIsUIBP_Active() then
    return true
  end
  return false
end
function LogicComplaint._SetAlreadyReported(sBeReportedName, nBattleID)
  if type(sBeReportedName) ~= "string" or sBeReportedName == "" then
    return
  end
  nBattleID = tonumber(nBattleID) or 0
  if not LogicComplaint._tAlreadyReportedPlayers[sBeReportedName] then
    LogicComplaint._tAlreadyReportedPlayers[sBeReportedName] = {}
  end
  table.insert(LogicComplaint._tAlreadyReportedPlayers[sBeReportedName], {
    nBattleID = nBattleID,
    sComplaintModule = LogicComplaint.GetCurrentComplaintModule()
  })
end
function LogicComplaint.IsAlreadyReported(sBeReportedName, nBattleID)
  if type(sBeReportedName) ~= "string" or sBeReportedName == "" then
    return false
  end
  nBattleID = tonumber(nBattleID) or 0
  local sComplaintModule = LogicComplaint.GetCurrentComplaintModule()
  local tArray = LogicComplaint._tAlreadyReportedPlayers[sBeReportedName]
  if not tArray then
    return false
  end
  local bIsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
  log(bWriteLog and "LogicComplaint.IsAlreadyReported  bInLobby = " .. tostring(bIsInLobbyOrMainCity))
  if sComplaintModule == "Chat" and bIsInLobbyOrMainCity then
    nBattleID = 0
    log(bWriteLog and "LogicComplaint.IsAlreadyReported  Set nBattleID as 0 ")
  end
  for _, tInfo in ipairs(tArray) do
    if nBattleID == tInfo.nBattleID and sComplaintModule == tInfo.sComplaintModule then
      return true
    end
  end
  return false
end
function LogicComplaint.Submit(sBeReportedName, bIsAI, bIsTeammate, tReasonArray, sInputBoxContent, nTeamMode, tSubReasonArray, tTeammateUidList, sReplayURL, nBattleID, nComplaintScene, nBeReportedPlayerUID, sBeReportedOpenID, sBeReportedText, tBeReportedPictureURLArray, nMomentID, nMomentCommentID, nMomentReplyID, nModeID, nSubModeID, nMapID, bIsImprisonPossible, nMsgType, nChatType, sDebugInfo, snBeReportedOriginalUID, bIsMLAI, nBotType, nCliSourceId, UGCRankModID, UGCCollectionId, UgcHotSearch, UGCReportType, bBlockChat, PrefabId, nBitMap, sExtraInfo)
  local bIsOpenBattlePlayback = Client and Client.GetIsOpenBattlePlayback(GameFrontendHUD) or false
  local nPlayerCount = LogicComplaint._nPlayerCount
  if nPlayerCount and nPlayerCount <= 0 then
    nPlayerCount = 1
  end
  local nBattleTime = LogicComplaint._nBattleTime
  if nBattleTime and nBattleTime <= 0 then
    nBattleTime = nil
  end
  if type(sBeReportedName) ~= "string" or sBeReportedName == "" then
    sBeReportedName = nil
  end
  if type(sInputBoxContent) ~= "string" or sInputBoxContent == "" then
    sInputBoxContent = nil
  end
  nTeamMode = tonumber(nTeamMode)
  if nTeamMode and nTeamMode <= 0 then
    nTeamMode = nil
  end
  if type(sReplayURL) ~= "string" or sReplayURL == "" then
    sReplayURL = nil
  end
  nBeReportedPlayerUID = tonumber(nBeReportedPlayerUID)
  if nBeReportedPlayerUID and nBeReportedPlayerUID <= 0 then
    nBeReportedPlayerUID = nil
  end
  if type(sBeReportedOpenID) ~= "string" or sBeReportedOpenID == "" then
    sBeReportedOpenID = nil
  end
  if not IsString(snBeReportedOriginalUID) and not tonumber(snBeReportedOriginalUID) then
    snBeReportedOriginalUID = nil
  end
  local nComplaintType2
  nComplaintScene = tonumber(nComplaintScene)
  if nComplaintScene and 0 < nComplaintScene then
    nComplaintType2 = nComplaintScene
  end
  nBattleID = tonumber(nBattleID)
  if not nBattleID or not (0 < nBattleID) then
    nBattleID = LogicComplaint.GetBattleID()
  end
  if tMaskingOutBattleIDSceneTLogTypeMap[nComplaintScene] then
    nBattleID = nil
  end
  local nReportCamp = 2
  if type(bIsTeammate) == "number" then
    nReportCamp = bIsTeammate
    FormatLog("LogicComplaint.Submit: bIsTeammate is number, ReportCamp=%s (override)", nReportCamp)
  elseif bIsTeammate then
    nReportCamp = 1
  end
  if type(sBeReportedText) ~= "string" or sBeReportedText == "" then
    sBeReportedText = nil
  end
  if not tBeReportedPictureURLArray or not next(tBeReportedPictureURLArray) then
    tBeReportedPictureURLArray = nil
  end
  local MomentNum = tonumber(nMomentID)
  if MomentNum and MomentNum <= 0 then
    nMomentID = nil
  end
  nMomentCommentID = tonumber(nMomentCommentID)
  if nMomentCommentID and nMomentCommentID <= 0 then
    nMomentCommentID = nil
  end
  nMomentReplyID = tonumber(nMomentReplyID)
  if nMomentReplyID and nMomentReplyID <= 0 then
    nMomentReplyID = nil
  end
  nModeID = tonumber(nModeID)
  if nModeID and nModeID <= 0 then
    nModeID = nil
  end
  nSubModeID = tonumber(nSubModeID)
  if nSubModeID and nSubModeID <= 0 then
    nSubModeID = nil
  end
  nMapID = tonumber(nMapID)
  if nMapID and nMapID <= 0 then
    nMapID = nil
  end
  if not IsNonemptyString(sDebugInfo) then
    sDebugInfo = nil
  end
  if not tTeammateUidList or not next(tTeammateUidList) then
    tTeammateUidList = nil
  end
  local nReasonCodeSum = 0
  if tReasonArray and next(tReasonArray) then
    for _, nReasonCode in pairs(tReasonArray) do
      nReasonCodeSum = nReasonCodeSum | nReasonCode
    end
  else
    nReasonCodeSum = nil
  end
  local nSubReasonCodeSum = 0
  if tSubReasonArray and next(tSubReasonArray) then
    for _, nSubReasonCode in pairs(tSubReasonArray) do
      nSubReasonCode = math.floor(2 ^ (nSubReasonCode - 1))
      nSubReasonCodeSum = nSubReasonCodeSum | nSubReasonCode
    end
  else
    nSubReasonCodeSum = nil
  end
  local nIsRoomMode = 0
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if logic_enter_game:IsEnterBattleByRoom() then
    nIsRoomMode = 1
  end
  local sMyOpenID = tostring(DataMgr.roleData.openID)
  local sMyRoleID = LogicComplaint.GetMyUIDString()
  local nReportScene = LogicComplaint.GetReportScene()
  local nAIType = 0
  if bIsMLAI then
    nAIType = 1
  end
  if nBotType == 5 then
    nAIType = 5
  end
  local nUGCModID
  if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch then
      local tUGCMatchInfo = LogicUGCMatch:GetCurrentMatchInfoForFight()
      if tUGCMatchInfo then
        nUGCModID = tUGCMatchInfo.mod_id
        FormatLog("nUGCModID=%s", nUGCModID)
      else
        FormatLog("invalid tUGCMatchInfo")
      end
    else
      FormatLog("invalid LogicUGCMatch")
    end
  else
    FormatLog("Not UGC GameState")
    nUGCModID = UGCRankModID
  end
  local nUGCCommentID
  local chatMacro = require("client.slua.logic.lobby_chat.chat_macro")
  if nCliSourceId == chatMacro.CliSourceId.UGCComment or nCliSourceId == chatMacro.CliSourceId.UGCCommentAuthorReply or nCliSourceId == chatMacro.CliSourceId.UGCCommentAuthor then
    local logic_ugc_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment)
    local data = logic_ugc_comment:GetReportDataCache()
    nUGCCommentID = data and data.comment_id
    nUGCModID = data and data.mod_id
  end
  UGCReportType = UGCReportType or 0
  bBlockChat = bBlockChat or false
  local tReportTLog = {
    BattleID = nBattleID,
    UserName = sBeReportedName,
    IsAI = bIsAI,
    ReportOpenID = sMyOpenID,
    ReportRoleID = tonumber(sMyRoleID),
    ReportCamp = nReportCamp,
    TeamUidList = tTeammateUidList,
    BattleTime = nBattleTime,
    ComplaintType = nReasonCodeSum,
    ComplaintType2 = nComplaintType2,
    ComplaintContents = sInputBoxContent,
    RankType = nTeamMode,
    BattlePlayerNumber = nPlayerCount,
    IsOpenBattlePlayback = bIsOpenBattlePlayback,
    ComplaintSubType = nSubReasonCodeSum,
    ComplaintReplayUrl = sReplayURL,
    UID = nBeReportedPlayerUID,
    OpenID = sBeReportedOpenID,
    UserRoleID = nBeReportedPlayerUID,
    BeReportedOriginalUID = snBeReportedOriginalUID,
    ComplaintContents2 = sBeReportedText,
    ComplaintPicUrlArray = tBeReportedPictureURLArray,
    param1 = nMomentID,
    param2 = nMomentCommentID,
    param3 = nMomentReplyID,
    ModeID = nModeID,
    SubModeID = nSubModeID,
    MapID = nMapID,
    MsgType = nMsgType,
    ChatType = nChatType,
    IsRoomMode = nIsRoomMode,
    ReportSceneType = nReportScene,
    AIType = nAIType,
    BotType = nBotType or 0,
    CliSourceId = nCliSourceId,
    UGCModID = nUGCModID,
    UGCCommentID = nUGCCommentID,
    UGCCollectionId = UGCCollectionId,
    UgcHotSearch = UgcHotSearch,
    UGCReportType = UGCReportType,
    bBlockChat = bBlockChat,
    PrefabId = PrefabId,
    BitMap = nBitMap,
    ExtraInfo = sExtraInfo
  }
  if chatMacro.NeedReadSaveComplaintDataCliSourceCfg[nCliSourceId] and LogicComplaint.cacheReportData then
    for k, v in pairs(LogicComplaint.cacheReportData) do
      tReportTLog[k] = v
    end
    LogicComplaint.cacheReportData = nil
  end
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  local bIsControllerValid = slua.isValid(uMyController)
  local bIsExtraController = Game:IsClassOf(uMyController, ASTExtraPlayerController)
  local sGameStatus = GameStatus.GetGameStatus()
  if GameStatus.IsInMainCity() then
    tReportTLog.ReportSceneType = ComplaintConfig.EReportSceneType.InMainCity
  end
  local sLogString = string.format([[
nBattleID=%s, sBeReportedName=%s, bIsAI=%s, sMyOpenID=%s, sMyRoleID=%s, nReportCamp=%s
nBattleTime=%s, nReasonCodeSum=%s, nComplaintType2=%s, sInputBoxContent=%s, nTeamMode=%s
nPlayerCount=%s, bIsOpenBattlePlayback=%s, nSubReasonCodeSum=%s, sReplayURL=%s
nBeReportedPlayerUID=%s, sBeReportedOpenID=%s, sBeReportedText=%s, nMomentID=%s
nMomentCommentID=%s, nMomentReplyID=%s, nModeID=%s, nSubModeID=%s, nMapID=%s, nMsgType=%s, nChatType=%s,nCliSourceId=%s, nIsRoomMode=%s
IsControllerValid=%s, IsExtraController=%s, ReportSceneType=%s
GameStatus=%s, UGCModID=%s, UGCCommentID=%s, UGCReportType=%s, bBlockChat=%s, nBitMap=%s
DebugInfo=%s, BotType = %s]], nBattleID, sBeReportedName, bIsAI, sMyOpenID, sMyRoleID, nReportCamp, nBattleTime, nReasonCodeSum, nComplaintType2, sInputBoxContent, nTeamMode, nPlayerCount, bIsOpenBattlePlayback, nSubReasonCodeSum, sReplayURL, nBeReportedPlayerUID, sBeReportedOpenID, sBeReportedText, nMomentID, nMomentCommentID, nMomentReplyID, nModeID, nSubModeID, nMapID, nMsgType, nChatType, nCliSourceId, nIsRoomMode, bIsControllerValid, bIsExtraController, nReportScene, sGameStatus, nUGCModID, nUGCCommentID, UGCReportType, bBlockChat, nBitMap, sDebugInfo, tostring(nBotType))
  FormatLog(sLogString)
  LogicComplaint._SetAlreadyReported(sBeReportedName, nBattleID)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_report_info(tReportTLog)
  EventSystem:postEvent(EVENTTYPE_COMPLAINT, EVENTID_SUBMIT_COMPLAINT, tReportTLog)
  if bIsImprisonPossible then
    LogicComplaint._ImprisonTeammateIfConditionIsTrue(nBeReportedPlayerUID, nReasonCodeSum)
  end
  if bIsDevelopment and not nComplaintType2 then
    StaticShowSecurityAlertInDev(uMyController, string.format([[
LogicComplaint.Submit, nComplaintType2 is nil
%s]], sLogString), true)
  end
end
function LogicComplaint.SetReportDataCache(reportData)
  log_tree(bWriteLog and "[v_wllwu] LogicComplaint.SetReportDataCache, reportData is:", reportData)
  LogicComplaint.cacheReportData = reportData
end
function LogicComplaint.SubmitQuickReportMaliciousTeammate(sTeammateName, nBeReportedUID, sBeReportedOpenID)
  local uMyPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyPlayerController, ASTExtraPlayerController) then
    return
  end
  if not slua.isValid(uMyPlayerController.PlayerState) then
    return
  end
  LogicComplaint.SetPlayerCountByGameState()
  local nReportReasonType = ComplaintConfig.EComplaintReasonType.HurtTeammate
  local nTeammateSize = 0
  local uTeammatePlayerStateArray = uMyPlayerController.PlayerState:GetTeamMatePlayerStateList({}, false)
  local tTeammateUIDList = {}
  for nTeammateIndex = 1, uTeammatePlayerStateArray:Num() do
    local uTeammatePlayerState = uTeammatePlayerStateArray:Get(nTeammateIndex - 1)
    if slua.isValid(uTeammatePlayerState) then
      nTeammateSize = nTeammateSize + 1
      local sTeammatePlayerUID = uTeammatePlayerState.PlayerUID
      if sTeammatePlayerUID ~= LogicComplaint.GetMyUIDString() then
        local nTeammateUID = tonumber(sTeammatePlayerUID)
        if nTeammateUID then
          table.insert(tTeammateUIDList, nTeammateUID)
        end
      end
    end
  end
  local nRankMode = ComplaintConfig.ConvertTeamModeTypeForTLog(nTeammateSize)
  local nComplaintScene = ComplaintConfig.EComplaintSceneTLogType.InBattleQuickReport
  LogicComplaint.Submit(sTeammateName, false, true, {nReportReasonType}, "", nRankMode, {}, tTeammateUIDList, nil, nil, nComplaintScene, nBeReportedUID, sBeReportedOpenID, nil, nil, nil, nil, nil, SecurityCommonUtils.GetCurrentBattleMainModeID(), SecurityClientUtils.GetInBattleSubModeID(), SecurityClientUtils.GetInBattleMapID(), true, nil, nil, "QuickReportMaliciousTeammate", nBeReportedUID)
end
function LogicComplaint._ImprisonTeammateIfConditionIsTrue(nBeReportedPlayerUID, nReasonCodeSum)
  if type(nBeReportedPlayerUID) ~= "number" then
    return
  end
  if type(nReasonCodeSum) ~= "number" then
    return
  end
  if slua.isValid(CGameState) and slua.isValid(CGameState.IsCreativeMode) and CGameState:IsCreativeMode() then
    FormatLog("UGC")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uPlayerController, ASTExtraPlayerController) then
    return
  end
  if not uPlayerController:IsCanImprisonmentTeammate() then
    return
  end
  if nReasonCodeSum & ComplaintConfig.EComplaintReasonType.HurtTeammate == 0 then
    return
  end
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerCharacter) then
    local ECharacterHealthStatus = import("ECharacterHealthStatus")
    if uPlayerCharacter.HealthStatus == ECharacterHealthStatus.HealthyAlive or uPlayerCharacter.HealthStatus == ECharacterHealthStatus.HasLastBreath then
      return
    end
  end
  local uSecurityImprisonComp = uPlayerController.SecurityImprisonComp
  if slua.isValid(uSecurityImprisonComp) then
    uSecurityImprisonComp:ImprisonmentTeammate(nBeReportedPlayerUID, true)
    FormatLog("executed, nBeReportedPlayerUID=%s", nBeReportedPlayerUID)
  end
end
function LogicComplaint.GetMyUIDString()
  return tostring(DataMgr.roleData.uid)
end
function LogicComplaint.GetCurrentComplaintModule()
  local sCurrentModule = LogicComplaint._sCurrentComplaintModule
  if type(sCurrentModule) ~= "string" then
    return ""
  end
  return sCurrentModule
end
function LogicComplaint.OnClose()
  BattleResultUI.SetIsReportComplaintShow(false)
  LogicComplaint._tComplaintPanel = nil
end
function LogicComplaint.ClearAlreadyReportedPlayers()
  LogicComplaint._tAlreadyReportedPlayers = {}
  FormatLog()
end
function LogicComplaint.GetReportScene()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  local nReportScene = ComplaintConfig.EReportSceneType.Others
  if GameStatus.IsInFightingStatus() and slua.isValid(uGameState) then
    local sGameModeState = uGameState:GetGameModeState()
    if sGameModeState == "ReadyState" then
      nReportScene = ComplaintConfig.EReportSceneType.InIsland
    elseif sGameModeState == "FightingState" then
      local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
      if slua.isValid(uPlayerController) then
        local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
        if slua.isValid(uPlayerCharacter) then
          local ECharacterHealthStatus = import("ECharacterHealthStatus")
          if uPlayerCharacter.HealthStatus == ECharacterHealthStatus.HealthyAlive or uPlayerCharacter.HealthStatus == ECharacterHealthStatus.HasLastBreath then
            nReportScene = ComplaintConfig.EReportSceneType.InBattle
          end
        end
        if uPlayerController:IsInPlane() then
          nReportScene = ComplaintConfig.EReportSceneType.InPlane
        end
      end
    end
  end
  return nReportScene
end
function LogicComplaint.SaveTodayNoShowWarningTime()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local TimeStamp = TimeUtil.GetServerTimeInSec()
  local Data = {time = TimeStamp}
  PlayerPrefsSystem.SaveTableToFile_N(Data, PlayerPrefsSystem.ePlayerPrefsType.eUGCWarningTodayNoShowTime)
end
function LogicComplaint.IsTodayNoShowWarning()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWarningTodayNoShowTime) or {}
  local TimeStamp = TimeRecord.time or 0
  log(bWriteLog and "LogicComplaint.IsTodayNoShow, TimeStamp = " .. tostring(TimeStamp))
  local TimeUtil = require("client.common.time_util")
  local CurrStamp = TimeUtil.GetServerTimeInSec()
  if 0 < TimeStamp and math.floor(CurrStamp / 86400) == math.floor(CurrStamp / 86400) then
    return true
  end
  return false
end
return LogicComplaint