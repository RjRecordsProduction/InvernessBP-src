local FormatLog = FuncUtil.FormatLog
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function _ENV:watchgame_RegisterUI()
  InGameUIManager.SubUIWidgetList(self, {
    {
      Path = "/Game/BluePrints/ControlInput/ResultsshareUI/WatchGame_UIBP.WatchGame_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
end
WatchGameUI = WatchGameUI or {}
local nHawkUIErrorCode = 0
local nTimerRound = 0
local tHawkUIErrorCdoeStat = {
  [1] = 0,
  [2] = 0,
  [3] = 0,
  [4] = 0,
  [5] = 0,
  [6] = 0,
  [7] = 0
}
local bHasShownButtonNext = false
local bReported = false
function WatchGameUI.ReportExcepion()
  if not bReported and not bHasShownButtonNext and 0 < nTimerRound and WatchGameUI._IsDuringHawkEyePatrol() then
    local sHawkUIErrorStat = ""
    for ErrorCode, Count in ipairs(tHawkUIErrorCdoeStat) do
      if sHawkUIErrorStat ~= "" then
        sHawkUIErrorStat = sHawkUIErrorStat .. string.format(",%d:%d", ErrorCode, Count)
      else
        sHawkUIErrorStat = sHawkUIErrorStat .. string.format("%d:%d", ErrorCode, Count)
      end
    end
    local ExceptionType = "hawkui"
    local ErrorMessage = string.format("%d,%d,%s", nTimerRound, nHawkUIErrorCode, sHawkUIErrorStat)
    UnrealNet.HandleSpectateException("hawkui", ErrorMessage)
    bReported = true
    FormatLog("WatchGameUI._StopHawkEyeTimer ErrorMessage:%s", ErrorMessage)
  end
end
function WatchGameUI:GetVisibility()
  log(bWriteLog and "WatchGameUI:GetVisibility")
  if watchgame then
    local UIUtil = require("client.common.ui_util")
    local uiRoot = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
    if not uiRoot then
      log(bWriteLog and "WatchGameUI:GetVisibility not uiroot false")
      return false
    elseif uiRoot and not uiRoot:IsVisible() then
      log(bWriteLog and "WatchGameUI:GetVisibility uiroot not visible false")
      return false
    else
      log(bWriteLog and "WatchGameUI:GetVisibility true")
      return true
    end
  else
    log(bWriteLog and "WatchGameUI:GetVisibility not watchgame false")
    return false
  end
end
function WatchGameUI:ShowSpectatingUI()
  print(bWriteLog and "WatchGameUI:ShowSpectatingUI", watchgame)
  if watchgame then
    InGameUIManager.HandleDynamicCreation(watchgame)
    InGameUIManager.HandleUIMessage(watchgame, "ShowSpectatingUI")
    local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
    if IngameLikeClientSubSystem then
      IngameLikeClientSubSystem:OnRepPlayerState()
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_SPECTATING)
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, WatchGameUI.HideSpectatingUI)
    EventSystem:registEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_GAMEOVER_TO_RESULT, WatchGameUI.HideSpectatingUI)
    WatchGameUI._StartHawkEyeTimer()
  end
end
function WatchGameUI:HideSpectatingUI()
  print(bWriteLog and "WatchGameUI:HideSpectatingUI", watchgame)
  if watchgame then
    InGameUIManager.HandleUIMessage(watchgame, "HideSpectatingUI")
    EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, WatchGameUI.HideSpectatingUI)
    EventSystem:unregistEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_GAMEOVER_TO_RESULT, WatchGameUI.HideSpectatingUI)
    WatchGameUI._StopHawkEyeTimer()
  end
end
function WatchGameUI:WarmodeEnterSpectating()
  if watchgame then
    InGameUIManager.HandleDynamicCreation(watchgame)
    InGameUIManager.HandleUIMessage(watchgame, "OnEnterSpectatingInWarMode")
  end
end
function WatchGameUI:ExitWatchGame(bIsDontShowWatchFriendBattleEndTips)
  if watchgame then
    InGameUIManager.HandleDynamicCreation(watchgame)
    if not bIsDontShowWatchFriendBattleEndTips then
      InGameUIManager.HandleUIMessage(watchgame, "OnWatchFriendBattleEnd")
    end
  else
    log(bWriteLog and "WatchGameUI:ExitWatchGame watchgame is nil")
  end
end
function WatchGameUI:CloseBattleEndedTips()
  if not watchgame then
    if bWriteLog then
      log(bWriteLog and "WatchGameUI:CloseBattleEndedTips, invalid watchgame")
    end
    return
  end
  InGameUIManager.HandleDynamicCreation(watchgame)
  InGameUIManager.HandleUIMessage(watchgame, "CloseBattleEndedTips")
  if bWriteLog then
    log(bWriteLog and "WatchGameUI:CloseBattleEndedTips, closed")
  end
end
function WatchGameUI:OnCollectedResult()
  if watchgame then
    InGameUIManager.HandleDynamicCreation(watchgame)
    InGameUIManager.HandleUIMessage(watchgame, "InitCollectButtonByItemID")
  end
end
function WatchGameUI:HandleSpectateGiveUpRevive()
  if watchgame then
    print(bWriteLog and "WatchGameUI:HandleSpectateGiveUpRevive")
    InGameUIManager.HandleDynamicCreation(watchgame)
    InGameUIManager.HandleUIMessage(watchgame, "HandleSpectateGiveUpRevive")
  end
end
function WatchGameUI:HandleSendGiftNotify(giftID, giftCount, reciverName)
  if watchgame then
    local content = DataMgr.GetFormatMsgByIDForBattleText(801084, reciverName, "PopularityGift" .. tostring(giftID), giftCount)
    BP_WATCHUI_SEND_GIFT_MSG = content
    InGameUIManager.HandleDynamicCreation(watchgame)
    InGameUIManager.HandleUIMessage(watchgame, "HandleSendGiftNotify")
    log(bWriteLog and "WatchGameUI:HandleSendGiftNotify " .. BP_WATCHUI_SEND_GIFT_MSG)
  end
end
function WatchGameUI:HandleReverseResponse()
  if watchgame then
    InGameUIManager.HandleDynamicCreation(watchgame)
    InGameUIManager.HandleUIMessage(watchgame, "InitAppointmentState")
    log(bWriteLog and " WatchGameUI:HandleReverseResponse")
  end
end
function WatchGameUI.SetFreindInviteState(UID)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local UIUtil = require("client.common.ui_util")
  local uiRoot = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
  local nUID = tonumber(UID)
  if LogicFriend and uiRoot and nUID then
    local AppointmentSwitch = uiRoot.AppointmentSwitch
    if AppointmentSwitch == nil then
      return
    end
    local ImprisonPanel = uiRoot.CanvasPanel_ImprisonPanel
    if ImprisonPanel and ImprisonPanel:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
      AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    if LogicFriend.IsMyFriend(nUID) == false then
      AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      local State = LogicFriend.GetReserveState(nUID)
      if State == 0 then
        AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      elseif State == 1 then
        AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        AppointmentSwitch:SetActiveWidgetIndex(0)
      elseif State == 2 then
        AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        AppointmentSwitch:SetActiveWidgetIndex(1)
      elseif State == 3 then
        AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        AppointmentSwitch:SetActiveWidgetIndex(2)
        if uiRoot.TextBlock_3 then
          uiRoot.TextBlock_3:SetText(DataMgr.GetMsgByID(7555))
        end
      end
    end
    local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
    if ClientHawkEyePatrolSubsystem and ClientHawkEyePatrolSubsystem:IsDuringHawkEyePatrol() then
      AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      uiRoot.UTRichTextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      uiRoot.UTRichTextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function WatchGameUI.SetAceImprintItem(AceImprintShowID, AceImprintBaseID)
  local WatchGameInGamePlayerInfo = UIManager.GetUI(UIManager.UI_Config_InGame.WatchGameInGamePlayerInfo)
  if WatchGameInGamePlayerInfo then
    WatchGameInGamePlayerInfo:SetAceImprintItem(AceImprintShowID, AceImprintBaseID)
  end
end
function WatchGameUI.HandleReverseBtn(UID)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local nUID = tonumber(UID)
  if LogicFriend and nUID then
    LogicFriend.ReserveFriend(nUID)
  end
end
function WatchGameUI.SetSegmentSubIcon(SegmentLv)
  local WatchGameInGamePlayerInfo = UIManager.GetUI(UIManager.UI_Config_InGame.WatchGameInGamePlayerInfo)
  if WatchGameInGamePlayerInfo then
    WatchGameInGamePlayerInfo:SetSegmentSubIcon(SegmentLv)
  end
end
function WatchGameUI.HideSegmentInJaguar()
  local WatchGameInGamePlayerInfo = UIManager.GetUI(UIManager.UI_Config_InGame.WatchGameInGamePlayerInfo)
  if WatchGameInGamePlayerInfo then
    WatchGameInGamePlayerInfo:HideSegmentInJaguar()
  end
end
function WatchGameUI.HideBackToLobby()
  local UIUtil = require("client.common.ui_util")
  local uiRoot = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
  if not uiRoot then
    return
  end
  if uiRoot.GridPanel_Exit then
    uiRoot.GridPanel_Exit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    uiRoot:HideBackToLobby()
  end
end
function WatchGameUI._StartHawkEyeTimer()
  if WatchGameUI._nHawkEyeTimer then
    FormatLog("timer exists")
    return
  end
  nHawkUIErrorCode = 0
  nTimerRound = 0
  for ErrorCode, nCount in ipairs(tHawkUIErrorCdoeStat) do
    tHawkUIErrorCdoeStat[ErrorCode] = 0
  end
  WatchGameUI._nHawkEyeTimer = Game:SetTimer(1, true, function()
    nTimerRound = nTimerRound + 1
    if not GameStatus.IsInFightingStatus() then
      WatchGameUI._StopHawkEyeTimer()
      FormatLog("WatchGameUI._nHawkEyeTimer return, not GameStatus.IsInFightingStatus(), nTimerRound:%d", nTimerRound)
      nHawkUIErrorCode = 1
      return
    end
    if not WatchGameUI._IsDuringHawkEyePatrol() then
      FormatLog("WatchGameUI._nHawkEyeTimer return, not WatchGameUI._IsDuringHawkEyePatrol(), nTimerRound:%d", nTimerRound)
      nHawkUIErrorCode = 2
      return
    end
    local UIUtil = require("client.common.ui_util")
    local UIRoot = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
    if not UIRoot then
      FormatLog("WatchGameUI._nHawkEyeTimer return, not UIRoot, nTimerRound:%d", nTimerRound)
      nHawkUIErrorCode = 3
      return
    end
    local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
    if not ClientHawkEyePatrolSubsystem then
      FormatLog("WatchGameUI._nHawkEyeTimer return, not ClientHawkEyePatrolSubsystem, nTimerRound:%d", nTimerRound)
      nHawkUIErrorCode = 4
      return
    end
    FormatLog("WatchGameUI._nHawkEyeTimer start update UI Button_Next, nTimerRound:%d", nTimerRound)
    if UIRoot.Button_PetSpectate then
      UIRoot.Button_PetSpectate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if UIRoot.UTRichTextBlock_1 then
      local nUsedPatrolSeconds = ClientHawkEyePatrolSubsystem:GetUsedDailyTimeInSeconds()
      local nUsedPatrolMinutes = math.floor(nUsedPatrolSeconds / 60)
      local sUsedPatrol = LocUtil.LocalizeResFormat(119600003, nUsedPatrolMinutes)
      UIRoot.UTRichTextBlock_1:SetText(sUsedPatrol)
    end
    if UIRoot.Border_0 and UIRoot.Button_Next and UIRoot.TextBlock_6 then
      bHasShownButtonNext = true
      UIRoot.Border_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIRoot.Button_Next:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      local nNextPatrolRemainingSeconds = ClientHawkEyePatrolSubsystem:GetForbidNextPatrolRemainingTimeInSeconds()
      local sNextPatrolButtonText = LocUtil.GetLocalizeResStr(36669)
      if 0.1 < nNextPatrolRemainingSeconds then
        sNextPatrolButtonText = string.format("%s(%ss)", sNextPatrolButtonText, math.ceil(nNextPatrolRemainingSeconds))
        UIRoot.Button_Next:SetIsEnabled(false)
        UIRoot.Border_0:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 0.6))
      else
        UIRoot.Button_Next:SetIsEnabled(true)
        UIRoot.Border_0:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 1))
      end
      UIRoot.TextBlock_6:SetText(sNextPatrolButtonText)
      if ClientHawkEyePatrolSubsystem:HasReported() then
        UIRoot.TextBlock_5:SetText(LocUtil.GetLocalizeResStr(119600001))
      else
        UIRoot.TextBlock_5:SetText(LocUtil.GetLocalizeResStr(49266))
      end
    else
      if not UIRoot.Border_0 then
        nHawkUIErrorCode = 5
      end
      if not UIRoot.Button_Next then
        nHawkUIErrorCode = 6
      end
      if not UIRoot.TextBlock_6 then
        nHawkUIErrorCode = 7
      end
    end
  end)
end
function WatchGameUI._StopHawkEyeTimer()
  if WatchGameUI._nHawkEyeTimer then
    Game:ClearTimer(WatchGameUI._nHawkEyeTimer)
    WatchGameUI._nHawkEyeTimer = nil
  end
end
function WatchGameUI._IsDuringHawkEyePatrol()
  local uMyController = GameplayData.GetPlayerController()
  if slua.isValid(uMyController) and uMyController.IsHawkEyeSpectator and uMyController:IsHawkEyeSpectator() then
    return true
  end
  return false
end