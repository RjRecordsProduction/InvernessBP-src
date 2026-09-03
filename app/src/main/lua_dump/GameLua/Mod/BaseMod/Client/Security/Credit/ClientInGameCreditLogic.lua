local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local ASTExtraGameStateBase = import("STExtraGameStateBase")
local SecurityClientUtils = require("GameLua.Mod.BaseMod.Client.Security.SecurityClientUtils")
local FormatLog = FuncUtil.FormatLog
local ClientInGameCreditLogic = {
  _bIsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = false,
  _tFirstExitTeamBeforeBoardingReturnLobbyNoticeModeIDTable = {},
  _bIsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabledButOnlyAlert = false
}
function ClientInGameCreditLogic.SetFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled(bIsEnabled, tModeIDTable, bIsEnabledButOnlyAlert)
  FormatLog("bIsEnabled=%s, bIsEnabledButOnlyAlert=%s", bIsEnabled, bIsEnabledButOnlyAlert)
  SecurityCommonUtils.SetBoolMember(ClientInGameCreditLogic, bIsEnabled, "_bIsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled", {ClearValue = false})
  SecurityCommonUtils.SetTableMember(ClientInGameCreditLogic, tModeIDTable, "_tFirstExitTeamBeforeBoardingReturnLobbyNoticeModeIDTable", {
    ClearValue = {}
  })
  SecurityCommonUtils.SetBoolMember(ClientInGameCreditLogic, bIsEnabledButOnlyAlert, "_bIsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabledButOnlyAlert", {ClearValue = false})
end
function ClientInGameCreditLogic._IsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled()
  if IsEditor then
    FormatLog("is editor")
    return true
  end
  if not ClientInGameCreditLogic._bIsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled then
    FormatLog("is not enabled")
    return false
  end
  local nModeID = SecurityCommonUtils.GetCurrentBattleMainModeID()
  FormatLog("%s", nModeID)
  if ClientInGameCreditLogic._tFirstExitTeamBeforeBoardingReturnLobbyNoticeModeIDTable[nModeID] then
    return true
  end
  return false
end
function ClientInGameCreditLogic._SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice(bIsReturnLobby, bIsOnlyAlertButNotPunish)
  local ReputationHandler = require("client.network.Protocol.ReputationHandler")
  local nModeID = SecurityCommonUtils.GetCurrentBattleMainModeID()
  local nSubModeID = SecurityClientUtils.GetInBattleSubModeID()
  local nBattleID = SecurityClientUtils.GetInBattleBattleID()
  local nIsPunishLimit = 0
  if bIsOnlyAlertButNotPunish then
    nIsPunishLimit = 1
  end
  ReputationHandler.send_credit_punish_return_lobby_user_reaction(nModeID, nSubModeID, nBattleID, bIsReturnLobby, nIsPunishLimit)
  FormatLog("nModeID=%s, nSubModeID=%s, nBattleID=%s, bIsReturnLobby=%s, nIsPunishLimit=%s", nModeID, nSubModeID, nBattleID, bIsReturnLobby, nIsPunishLimit)
end
function ClientInGameCreditLogic.ShowReturnLobbyIfFirstExitTeamBeforeBoarding(fOnClickConfirm)
  if not SecurityCommonUtils.IsFunction(fOnClickConfirm) then
    FormatLog("invalid fOnClickConfirm")
    return false
  end
  if not ClientInGameCreditLogic._IsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled() then
    FormatLog("not enabled")
    return false
  end
  if not GameStatus.IsInFightingStatus() then
    FormatLog("not InCombatState")
    return false
  end
  local uController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uController, ASTExtraPlayerController) then
    FormatLog("invalid uController")
    return false
  end
  if uController:IsTeammateExitTeamBeforeBoarding() then
    FormatLog("IsTeammateExitTeamBeforeBoarding")
    return false
  end
  if uController:IsRoomMode() then
    FormatLog("IsRoomMode")
    return false
  end
  if not SecurityClientUtils.IsMyHealthStatusHealthy() then
    FormatLog("health status not healthy")
    return false
  end
  if not SecurityCommonUtils.IsGameModeReadyStateInBattle() then
    FormatLog("not ready game state")
    return false
  end
  if SecurityClientUtils.HasOtherTeammateOffline() then
    FormatLog("has offline teammate")
    return false
  end
  if not SecurityClientUtils.HasOtherHealthyOnlineTeammate() then
    FormatLog("no healthy online teammate")
    return false
  end
  local sMessage = LocUtil.GetLocalizeResStr(77002)
  local bIsOnlyAlertButNotPunish = false
  if ClientInGameCreditLogic._bIsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabledButOnlyAlert then
    FormatLog("enabled but only alert")
    sMessage = LocUtil.GetLocalizeResStr(77003)
    bIsOnlyAlertButNotPunish = true
  end
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(IngameTipsTools.MSGBOX_SHOW_TYPE_TWO, nil, sMessage, function()
    ClientInGameCreditLogic._SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice(true, bIsOnlyAlertButNotPunish)
    fOnClickConfirm()
  end, function()
    ClientInGameCreditLogic._SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice(false, bIsOnlyAlertButNotPunish)
  end, nil, nil, {
    androidCallback = function()
      ClientInGameCreditLogic._SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice(false, bIsOnlyAlertButNotPunish)
    end
  })
  FormatLog("show")
  return true
end
return ClientInGameCreditLogic