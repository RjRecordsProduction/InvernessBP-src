local ClientReplayUISubsystem = {}
local EGameReplayType = import("EGameReplayType")
local EWonderfulKeepState = import("EWonderfulKeepState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function ClientReplayUISubsystem:OnInit()
  printf("ClientReplayUISubsystem:OnInit")
  self.CompletePlaybackUI = nil
  self.WonderfulLoadingUI = nil
  self.WonderfulTeamPanel = nil
  if not self.bHasRegist then
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_FETCH_CURRENT_TIME, self.FetchCurrentTime, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_FETCH_CLIENT_VERSION, self.FetchClientVersion, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_RETURN_TO_BATTLERESULT, self.ReturnToBattleResult, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_SEND_TLOG, self.OnSendTlog, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_KEEPSTATE_CHANGED, self.OnKeepStateChanged, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_FETCH_PROFILE, self.OnFetchProfile, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_SWITCHPERIOD, self.OnSwitchPeriod, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_CLIENT_RECORD_MEMORY_WARNING, self.OnMemoryWarning, self)
    self.bHasRegist = true
  end
  Game:SetTimer(0.1, false, function()
    self:HideUIOnCompleteReplay()
  end)
end
function ClientReplayUISubsystem:OnRelease()
  printf("ClientReplayUISubsystem:OnRelease")
  self.bHasRegist = nil
  self.CompletePlaybackUI = nil
  if self.WonderfulLoadingUI then
    self.WonderfulLoadingUI:Clear()
    self.WonderfulLoadingUI = nil
  end
  local CompletePlaybackUISwitch = require("GameLua.Mod.BaseMod.Client.Replay.CompletePlaybackUISwitch")
  CompletePlaybackUISwitch.OnRelease()
  ClientReplayUISubsystem.__super.OnRelease(self)
end
function ClientReplayUISubsystem:InitReplayUI(_, __, nReplayType)
  printf("ClientReplayUISubsystem:InitReplayUI ReplayType[%d]", nReplayType)
  if nReplayType == EGameReplayType.EGameReplayType_WonderfulPlayback then
    self:ShowHideCompletePlaybackUI(true)
    if self.CompletePlaybackUI and self.CompletePlaybackUI.UIRoot then
      self.CompletePlaybackUI.UIRoot:InitWonderfulPlayback()
    else
      printf("ClientReplayUISubsystem:InitReplayUI CompletePlaybackUI is nil")
    end
  end
end
function ClientReplayUISubsystem:ShowHideReplayUI(_, __, nReplayType, bShow)
  printf("ClientReplayUISubsystem:ShowHideReplayUI nReplayType[%d], bShow[%s]", nReplayType, tostring(bShow))
  if nReplayType == EGameReplayType.EGameReplayType_WonderfulPlayback then
    self:ShowHideCompletePlaybackUI(bShow)
  end
end
function ClientReplayUISubsystem:ShowHideCompletePlaybackUI(bShow)
  printf("ClientReplayUISubsystem:ShowHideCompletePlaybackUI bShow[%s]", tostring(bShow))
  if UIManager then
    if bShow and UIManager.UI_Config_InGame.CompletePlaybackUI then
      self.CompletePlaybackUI = UIManager.ShowUI(UIManager.UI_Config_InGame.CompletePlaybackUI)
      printf("ClientReplayUISubsystem:InitReplayUI Set CompletePlaybackUI")
    else
      UIManager.HideUI(UIManager.UI_Config_InGame.CompletePlaybackUI)
    end
  end
end
function ClientReplayUISubsystem:FetchCurrentTime(_, __, Type)
  printf("ClientReplayUISubsystem:FetchCurrentTime", Type)
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) then
      local TimeUtil = require("client.common.time_util")
      ClientInGameReplayInstance:SetSaveTimestamp(TimeUtil.GetServerTimeInSec() or 0, Type)
    end
  end
end
function ClientReplayUISubsystem:FetchClientVersion(_, __, Type)
  printf("ClientReplayUISubsystem:FetchClientVersion", Type)
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) then
      ClientInGameReplayInstance:SetClientVersion(Client.GetAppVersion() or 0, Client.GetSrcVersion() or 0, Type)
    end
  end
end
function ClientReplayUISubsystem:ReturnToBattleResult(_, __)
  printf("ClientReplayUISubsystem:ReturnToBattleResult")
  EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_SHOWHIDE_REPLAYUI, EGameReplayType.EGameReplayType_WonderfulPlayback, false)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.CastUIMsg then
    uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
  end
  if self.WonderfulTeamPanel then
    self.WonderfulTeamPanel:ShowOrHideAllTeammatePositionItem(false)
  end
end
function ClientReplayUISubsystem:OnSendTlog(_, __)
  printf("ClientReplayUISubsystem:OnSendTlog")
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  local tlog = replay_macro.TLOG
  logic_replay.reportTlog({
    tlog.Sub_Scene.RESULT,
    tlog.Action.PLAY
  })
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  logic_share_replay.SetOpenReplayInfo(tlog.Sub_Scene.RESULT)
end
function ClientReplayUISubsystem:OnKeepStateChanged(_, __)
  printf("ClientReplayUISubsystem:OnKeepStateChanged")
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) then
      local KeepState = ClientInGameReplayInstance.WonderfulKeepState
      if KeepState == EWonderfulKeepState.EWonderfulKeepState_Success then
        local logic_replay = require("client.slua.logic.replay.logic_replay")
        local replay_macro = require("client.slua.logic.replay.replay_macro")
        local tlog = replay_macro.TLOG
        local tlogContent = {
          tlog.Sub_Scene.RESULT,
          tlog.Action.TYPE
        }
        local tWonderfulTypes = ClientInGameReplayInstance:GetAllWonderfulPeriodType()
        for index, value in pairs(tWonderfulTypes) do
          table.insert(tlogContent, value)
        end
        log_tree("ClientReplayUISubsystem:OnKeepStateChanged tlogContent", tlogContent)
        logic_replay.reportTlog(tlogContent)
      end
    end
  end
end
function ClientReplayUISubsystem:OnFetchProfile(_, __)
  printf("ClientReplayUISubsystem:OnFetchProfile")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if slua.isValid(uGameInstance) and uGameInstance.GetWonderfulPlayback ~= nil then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    if slua.isValid(uWonderfulPlayback) then
      local nTargetUID = uWonderfulPlayback:GetTargetUID()
      local UIDList = {}
      table.insert(UIDList, nTargetUID)
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(UIDList, function(list)
        self:ReceiveProfileData(list)
      end, Enum_PROFILE_REPORT_CFG.REPLAY, 0, false)
    end
  end
end
function ClientReplayUISubsystem:ReceiveProfileData(list)
  printf("ClientReplayUISubsystem:ReceiveProfileData")
  local sName = ""
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if slua.isValid(uGameInstance) and uGameInstance.GetWonderfulPlayback ~= nil then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    if slua.isValid(uWonderfulPlayback) then
      sName = uWonderfulPlayback:GetTargetPlayerName()
    end
  end
  for k, v in pairs(list) do
    local sUID = tostring(v.uid) or ""
    local sPicUrl = v.picUrl or ""
    local nGender = tonumber(v.sex) or 0
    local nAvatarBoxID = tonumber(v.cur_avatar_box_id) or 0
    local sNation = v.nation or ""
    printf("ClientReplayUISubsystem:ReceiveProfileData sUID[%s] sName[%s] sPicUrl[%s] nGender[%d] nAvatarBoxID[%d] sNation[%s]", sUID, sName, sPicUrl, nGender, nAvatarBoxID, sNation)
    EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_SET_PROFILE, sUID, sName, sPicUrl, nGender, nAvatarBoxID, sNation)
    return
  end
end
function ClientReplayUISubsystem:OnSwitchPeriod(_, __, bShow, type)
  printf("ClientReplayUISubsystem:OnSwitchPeriod bShow[%s] type[%d]", tostring(bShow), type)
  if UIManager then
    if bShow == true and self.WonderfulLoadingUI == nil then
      self.WonderfulLoadingUI = UIManager.ShowUI(UIManager.UI_Config_InGame.WonderfulLoadingUI)
    end
  else
    printf("ClientReplayUISubsystem:OnSwitchPeriod UIManager is nil")
    return
  end
  if self.WonderfulLoadingUI then
    self.WonderfulLoadingUI:ShowHideLoadingUI(bShow, type)
  end
  if not bShow then
    self.WonderfulTeamPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.WonderfulTeamPanel)
    self.WonderfulTeamPanel:ShowOrHideAllTeammatePositionItem(true)
  elseif self.WonderfulTeamPanel then
    self.WonderfulTeamPanel:ShowOrHideAllTeammatePositionItem(false)
    UIManager.CloseUI(UIManager.UI_Config_InGame.WonderfulTeamPanel)
  end
end
function ClientReplayUISubsystem:OnMemoryWarning()
  print(bWriteLog and "ClientReplayUISubsystem:OnMemoryWarning")
  IngameTipsTools.BattleGeneralTip(11606)
end
function ClientReplayUISubsystem:HideUIOnCompleteReplay()
  print(bWriteLog and "ClientReplayUISubsystem:HideUIOnCompleteReplay")
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if not IngameEntry.IsReplayClient() and not Client.IsEditor() then
    printf("ClientReplayUISubsystem:HideUIOnCompleteReplay Fail not IngameEntry.IsReplayClient()")
    return
  end
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if not USTExtraBlueprintFunctionLibrary.IsRunningForWesee() and not USTExtraBlueprintFunctionLibrary.IsRunningForDSWonderful() then
    printf("ClientReplayUISubsystem:HideUIOnCompleteReplay Fail Not IsRunningForWesee()")
    return
  end
  local CompletePlaybackUISwitch = require("GameLua.Mod.BaseMod.Client.Replay.CompletePlaybackUISwitch")
  CompletePlaybackUISwitch.OnInit()
  print(bWriteLog and "ClientReplayUISubsystem:HideUIOnCompleteReplay Success")
  if UIManager.UI_Config_InGame then
    local PhoneStateUI = UIManager.GetUI(UIManager.UI_Config_InGame.PhoneStateUI)
    if PhoneStateUI then
      print(bWriteLog and "ClientReplayUISubsystem:HideUIOnCompleteReplay CloseUI PhoneStateUI")
      UIManager.CloseUI(UIManager.UI_Config_InGame.PhoneStateUI)
    else
      print(bWriteLog and "ClientReplayUISubsystem:HideUIOnCompleteReplay No PhoneStateUI")
    end
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if MainControlBaseUI and MainControlBaseUI.TextBlock_BID then
      MainControlBaseUI.TextBlock_BID:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      MainControlBaseUI.TextBlock_Hour:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    print(bWriteLog and "ClientReplayUISubsystem:HideUIOnCompleteReplay No UIManager.UI_Config_InGame")
  end
  Game:SetTimer(0.3, false, function()
    local UIUtil = require("client.common.ui_util")
    local CompletePlaybackUI = UIUtil.GetWidgetByLogicName("complete_playback")
    if CompletePlaybackUI and CompletePlaybackUI.TextBlock_DeathPlaybackTips1 then
      CompletePlaybackUI.TextBlock_DeathPlaybackTips1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      CompletePlaybackUI.CanvasPanel_time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      local WatchGame_PlayerInfo_UIBP = CompletePlaybackUI.WatchGame_PlayerInfo_UIBP
      WatchGame_PlayerInfo_UIBP.CanvasPanel_VideoInspection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      print(bWriteLog and "ClientReplayUISubsystem:HideUIOnCompleteReplay No CompletePlaybackUI")
    end
  end)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientReplayUISubsystem)