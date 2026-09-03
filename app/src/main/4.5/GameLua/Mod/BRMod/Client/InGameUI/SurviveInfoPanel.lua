local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local SurviveInfoPanel = {}
function SurviveInfoPanel:ctor()
  self.LowPlayerNum = 10
  self.LastAliveNumUpdate = 0
  self.TNeedRecordGunSlot = {}
  self.bRegistAliveNumEvent = false
end
function SurviveInfoPanel:OnInitialize()
  print(bWriteLog and "SurviveInfoPanel:OnInitialize")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    return
  end
  self:AttachToPanel(MainControlBaseUI.CanvasPanelSurviveKill)
  self:SetAnchors(0, 0, 1, 1)
  self:InitKillNumFontMaterial()
end
function SurviveInfoPanel:RegistEvents()
  print(bWriteLog and "SurviveInfoPanel:RegistEvents")
  self:BindEvents()
  self:AddControlEventByControl(self.UIRoot.ButtonOpenDetail, "OnClicked", self.OnClickButtonOpenDetail, self)
  self:AddUIMessageEvent("RefreshKillNum", self.RefreshKillNum, self)
  self:AddUIMessageEvent("UIMsg_ForceUpdate_KillNums", self.UIMsg_ForceUpdate_KillNums, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerState", self.OnPlayerStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.CloseGunRecordHitInfoWindow, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_KILLNUM_CHANGED, self.RefreshKillNum, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.OnGamePlaySyncPlayerState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.OnGamePlaySyncPlayerState, self)
end
function SurviveInfoPanel:BindEvents()
  print(bWriteLog and "SurviveInfoPanel:BindEvents")
  self:PlayerNumChange()
  self:RefreshKillNum()
  GameplayData.AddGameStateEvent(self, "OnPlayerNumChange", self.PlayerNumChange, self)
  GameplayData.AddGameStateEvent(self, "OnBeKilledNumChange", self.PlayerNumChange, self)
  self:AddUIMessageEvent("OnViewTargetChanged", self.OnViewTargetChanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnViewTargetChange", self.OnViewTargetChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_AFTER_SET_VIEWTARGET, function()
    print(bWriteLog and "SurviveInfoPanel EVENTID_AFTER_SET_VIEWTARGET")
    self:RefreshKillNum()
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_SPECTATING, self.OnEnterSpectating, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnEnterObserve, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerHitInfoUpdate", self.HandleGunHitInfoUpdate, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnectResetUIByPlayerControllerStateDelegate, self)
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  if slua.isValid(Bridge) then
    self:AddControlEventByControl(Bridge, "OnPlayReplayBegin", self.RefreshKillNum, self)
    self:AddControlEventByControl(Bridge, "OnPlayReplayEnd", self.RefreshKillNum, self)
  end
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.RefreshKillNum, self)
end
function SurviveInfoPanel:ForceUpdateAliveNum()
  if not slua.isValid(CGameState) then
    return
  end
  local LastAliveNumText = self.UIRoot.SurviveCountText:GetText()
  self.UIRoot.SurviveCountText:SetText(CGameState.AlivePlayerNum)
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.AlivePlayerNum == nil then
    self:ReportInfo("GameState is nil")
    return
  end
  if LastAliveNumText ~= tostring(CGameState.AlivePlayerNum) then
    local ErrorMsg = string.format("LastAliveNum: %s, GameState.AlivePlayerNum: %s", LastAliveNumText, tostring(CGameState.AlivePlayerNum))
    self:ReportInfo(ErrorMsg)
    if not self.bRegistAliveNumEvent then
      self.bRegistAliveNumEvent = true
      self:AddControlEventByControl(CGameState, "OnPlayerNumChange", self.PlayerNumChange, self)
    end
  end
end
function SurviveInfoPanel:ReportInfo(ErrorMsg)
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  local AliveNumInfoError = "AliveNumInfoError"
  if GameReportUtils.CheckCanBugglyPostException(AliveNumInfoError) then
    GameReportUtils.BugglyPostExceptionFull(AliveNumInfoError, ErrorMsg, false)
  end
end
function SurviveInfoPanel:OnEnterSpectating()
  print(bWriteLog and "SurviveInfoPanel:OnEnterSpectating")
  self:DelayRefreshKillNum(2)
end
function SurviveInfoPanel:OnEnterObserve(_, _, ViewWho, ObserverType)
  print(bWriteLog and "SurviveInfoPanel:OnEnterObserve", ViewWho, ObserverType, ViewWho and ViewWho.STExtraPlayerState or "-")
  self:DelayRefreshKillNum(2)
end
function SurviveInfoPanel:OnReconnectResetUIByPlayerControllerStateDelegate()
  self:UIMsg_ForceUpdate_KillNums()
  self:UIMsg_ForceUpdate_SurviveNums()
end
function SurviveInfoPanel:OnGamePlaySyncPlayerState()
  self:BindEvents()
  self:UIMsg_ForceUpdate_KillNums()
  self:UIMsg_ForceUpdate_SurviveNums()
  self:HitTestInvisible()
end
function SurviveInfoPanel:InitKillNumFontMaterial()
  self.UIRoot.WidgetSwitcher_IsEffect:SetActiveWidgetIndex(0)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  if uPlayerState.EliminationKingEffectID and uPlayerState.EliminationKingEffectID ~= 0 then
    local Cfg = CDataTable.GetTableData("EliminationKingEffectCfg", uPlayerState.EliminationKingEffectID)
    if Cfg and Cfg.KillNumFontMat then
      local asset_util = require("common.asset_util")
      local FontMaterial = asset_util.GetAssetSync(Cfg.KillNumFontMat)
      if FontMaterial then
        local FontInfo = self.UIRoot.SlainCountText.Font
        FontInfo.        FontInfo.Size = 17
        self.UIRoot.SlainCountText_Effect:SetFont(FontInfo)
      end
    end
  end
end
function SurviveInfoPanel:OnPlayerStateChange(_, PlayerState)
  self:PlayerKillsChange()
  if not slua.isValid(PlayerState) or not PlayerState.OnPlayerKillsChangeDelegate then
    return
  end
  GameplayData.AddSelfPlayerStateEvent(self, "OnPlayerKillsChangeDelegate", self.PlayerKillsChange, self)
end
function SurviveInfoPanel:OnClickButtonOpenDetail()
  print(bWriteLog and "SurviveInfoPanel:OnClickButtonOpenDetail")
  if BattleShowHitDistributionInfo then
    BattleShowHitDistributionInfo(true)
  end
  self.UIRoot.InfoUpdateEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.RecordHitInfoGunCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioAsync(sound_config.click)
end
function SurviveInfoPanel:PlayerKillsChange()
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or PlayerState.Kills == nil then
    return
  end
  self.UIRoot.SlainCountText:SetText(PlayerState.Kills)
end
function SurviveInfoPanel:HandleGunHitInfoUpdate()
  self.UIRoot.InfoUpdateEffect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_1, 0, 1, 0, 1)
end
function SurviveInfoPanel:CloseGunRecordHitInfoWindow()
  if BattleShowHitDistributionInfo then
    BattleShowHitDistributionInfo(false)
  end
end
function SurviveInfoPanel:OnViewTargetChanged()
  print(bWriteLog and "SurviveInfoPanel:OnViewTargetChanged")
  self:RefreshKillNum()
end
function SurviveInfoPanel:PlayerNumChange()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.AlivePlayerNum == nil then
    return
  end
  print(bWriteLog and "SurviveInfoPanel:PlayerNumChange: " .. GameState.AlivePlayerNum)
  self.UIRoot.SurviveCountText:SetText(GameState.AlivePlayerNum)
  if GameState:GetGameModeState() ~= "FightingState" then
    return
  end
  if GameState.AlivePlayerNum > self.LowPlayerNum then
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Remaining)
    return
  end
  local EGameModeType = import("EGameModeType")
  local EGameModeSubCPPType = import("EGameModeSubType")
  if (GameState.GameModeSubType == EGameModeSubCPPType.ESinkGameMode or GameState.GameModeType == EGameModeType.ETypicalGameMode) and GameState.AlivePlayerNum ~= self.LastAliveNumUpdate then
    self.LastAliveNumUpdate = GameState.AlivePlayerNum
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Remaining, 0, 1, 0, 1)
  end
end
function SurviveInfoPanel:UIMsg_HandleEquipCanRecordHitInfoGun(nWeaponSlot)
  if not self:CheckCanShowRecordeHitInfo() then
    return
  end
  self.TNeedRecordGunSlot[nWeaponSlot] = true
  if self:CheckRecordeHitInfoShow() then
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_1, 0, 1, 0, 1)
  self.UIRoot.InfoUpdateEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.RecordHitInfoGunCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function SurviveInfoPanel:UIMsg_HandleUnEquipCanRecordHitInfoGun(nWeaponSlot)
  local bHasRecordHitGun = false
  self.TNeedRecordGunSlot[nWeaponSlot] = nil
  for _, Value in pairs(self.TNeedRecordGunSlot) do
    if Value then
      bHasRecordHitGun = true
      break
    end
  end
  if bHasRecordHitGun then
    return
  end
  self.UIRoot.InfoUpdateEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.RecordHitInfoGunCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if BattleShowHitDistributionInfo then
    BattleShowHitDistributionInfo(false)
  end
end
function SurviveInfoPanel:UIMsg_HandleEquipChangeSwap(nWeaponSlot, bNeedRecord)
  self.TNeedRecordGunSlot[nWeaponSlot] = bNeedRecord
end
function SurviveInfoPanel:UIMsg_HandleCloseRecordHitInfo()
  if BattleShowHitDistributionInfo then
    BattleShowHitDistributionInfo(false)
  end
end
function SurviveInfoPanel:UIMsg_HandleGunHitWindowClose()
  self.UIRoot.RecordHitInfoGunCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SurviveInfoPanel:CheckCanShowRecordeHitInfo()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController.IsInSpectating == nil then
    return false
  end
  return not PlayerController:IsInSpectating()
end
function SurviveInfoPanel:CheckRecordeHitInfoShow()
  return self.UIRoot.RecordHitInfoGunCanvas:IsVisible()
end
function SurviveInfoPanel:DelayRefreshKillNum(Time)
  self:RefreshKillNum()
  self:AddGameTimer(Time, false, function()
    self:RefreshKillNum()
  end)
end
function SurviveInfoPanel:RefreshKillNum()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController.GetCurPlayerState == nil then
    print(bWriteLog and "SurviveInfoPanel:RefreshKillNum invalid PlayerController")
    return
  end
  local CurrentPlayerState = PlayerController:GetCurPlayerState()
  if not slua.isValid(CurrentPlayerState) then
    print(bWriteLog and "SurviveInfoPanel:RefreshKillNum invalid CurrentPlayerState")
    return
  end
  print(bWriteLog and "SurviveInfoPanel:RefreshKillNum", CurrentPlayerState.PlayerKey, CurrentPlayerState.Kills)
  if not slua.isValid(self.UIRoot) then
    return
  end
  if CurrentPlayerState.Kills >= 5 then
    self.UIRoot.WidgetSwitcher_IsEffect:SetActiveWidgetIndex(1)
    self.UIRoot.SlainCountText_Effect:SetText(CurrentPlayerState.Kills)
  else
    self.UIRoot.WidgetSwitcher_IsEffect:SetActiveWidgetIndex(0)
    self.UIRoot.SlainCountText:SetText(CurrentPlayerState.Kills)
  end
end
function SurviveInfoPanel:UIMsg_ForceUpdate_SurviveNums()
  self:PlayerNumChange()
end
function SurviveInfoPanel:UIMsg_ForceUpdate_KillNums()
  self:RefreshKillNum()
end
function SurviveInfoPanel:ShowRemainNumGuidTips()
  self:PlayUserWidgetAnimation(self.UIRoot.Anima_Refresh, 0, 1, 0, 1)
  self.UIRoot.Image_guide:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function SurviveInfoPanel:ShowSurvivePanel(bShow)
  if not bShow then
    self:Collapsed()
    return
  end
  self:SelfHitTestInvisible()
  local UGameplayStatics = import("GameplayStatics")
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  local PlayerController = UGameplayStatics.GetPlayerController(CGameWorld, 0)
  if slua.isValid(PlayerController) and PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_DeathPlayback) then
    self:Collapsed()
  end
end
function SurviveInfoPanel:SetWidgetScale(WidgetName, Scale)
  local Widget = self.UIRoot[WidgetName]
  if Widget then
    Widget:SetRenderScale(Scale)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, SurviveInfoPanel)