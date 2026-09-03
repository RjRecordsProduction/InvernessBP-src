local IngamePositionItemUI = {}
local uWidgetLayoutLibrary = import("WidgetLayoutLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local USTExtraUIUtils = import("STExtraUIUtils")
local uEGameModeType = import("EGameModeType")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local uEMentorPlayerType = import("EMentorPlayerType")
local uEPlayerLiveState = import("ExtraPlayerLiveState")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function IngamePositionItemUI:ctor(_, nIndex, TeamMatePlayerState)
  self.bForbidUpdateLiveState = false
  self.SavedPlayerState = TeamMatePlayerState
  self.end
function IngamePositionItemUI:OnInitialize()
  self:InitPosItem(self.nIndex, self.SavedPlayerState)
end
function IngamePositionItemUI:RegistEvents()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if slua.isValid(uPlayerController) then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnTeammateRescueStateChanged", self.OnTeammateRescueStateChanged_Handle, self)
    local uGameState = GameplayData.GetGameState()
    if slua.isValid(uGameState) and uGameState.GameModeType == uEGameModeType.EDeathMatchGameMode then
      return
    end
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.OnPlayerEnterFlying_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStateChange", self.OnGameStateChange_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnCongregationFlagDelegate", self.OnCongregationFlagDelegate_Handle, self)
  end
  self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 0, 0))
  self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 100, 30))
end
function IngamePositionItemUI:OnShow()
  print(bWriteLog and "TeamPosition_Debug_Msg: OnShow")
end
function IngamePositionItemUI:OnClose()
  print(bWriteLog and "TeamPosition_Debug_Msg: OnClose")
  self.SavedPlayerState = nil
  if self.HideQuickTimer then
    self:RemoveGameTimer(self.HideQuickTimer)
    self.HideQuickTimer = nil
  end
  if self.DebugTimer then
    self:RemoveGameTimer(self.DebugTimer)
    self.DebugTimer = nil
  end
  self:RemoveBeingRescuedTimer()
  self:ClearDynamicIconList()
end
function IngamePositionItemUI:InitPosItem(nIndex, TeamMatePlayerState)
  print(bWriteLog and "IngamePositionItemUI:InitPosItem")
  self.UIRoot:SetSavedPlayerState(TeamMatePlayerState)
  self:InitDefaultWidgets()
  self:InitData(nIndex, TeamMatePlayerState)
  self:InitUI()
  if TeamMatePlayerState and TeamMatePlayerState.GetSuperData then
    self:AddDataListener(TeamMatePlayerState:GetSuperData(), "HeadPositionTagCount", self.OnHeadPositionTagCountChanged, self)
  end
end
function IngamePositionItemUI:InitData(nIndex, TeamMatePlayerState)
  self:RemovePlayerStateEvents(self.SavedPlayerState)
  self.SavedPlayerState = TeamMatePlayerState
  self.  self.nTeamMemberIndex = nIndex
  self.PostionItemIconUI = nil
  self.DynamicIconList = {}
  self.nReUpassShow = 0
  self.BeingRescuedTimer = nil
  self.ePlayerLiveState = nil
  self:RegistPlayerStateEvents(self.SavedPlayerState)
end
function IngamePositionItemUI:RegistPlayerStateEvents(PlayerState)
  if slua.isValid(PlayerState) then
    self:AddControlEventByControl(PlayerState, "OnLiveStateChangeEvent", self.OnTeammateHPChangeDelegate_Handle, self)
  end
end
function IngamePositionItemUI:RemovePlayerStateEvents(PlayerState)
  if slua.isValid(PlayerState) then
    self:RemoveControlEventByControl(PlayerState, "OnLiveStateChangeEvent")
    if PlayerState.GetSuperData then
      self:RemoveDataListenerWithoutAssert(PlayerState:GetSuperData(), "HeadPositionTagCount")
    end
  end
end
function IngamePositionItemUI:InitUI()
  self:SetPlayerInfo()
  self:SetColor()
  self:SetState()
  self:RefreshPetSpectatingMark()
end
function IngamePositionItemUI:OnHeadPositionTagCountChanged(_, NewCount)
  if self.SavedPlayerState then
    print(bWriteLog and string.format("IngamePositionItemUI:OnHeadPositionTagCountChanged name=%s newcount=%d", self.SavedPlayerState.PlayerName or "nil", NewCount or 0))
  else
    print(bWriteLog and string.format("IngamePositionItemUI:OnHeadPositionTagCountChanged newcount=%d", NewCount or 0))
  end
  local Visibility = 0 < NewCount and UEnums.ESlateVisibility.Collapsed or UEnums.ESlateVisibility.SelfHitTestInvisible
  self.UIRoot.CanvasPanel_VisibilityNew:SetWidgetVisibility(Visibility)
end
function IngamePositionItemUI:InitDefaultWidgets()
  local UIRoot = self.UIRoot
  if not slua.isValid(UIRoot) then
    return
  end
  UIRoot.CanvasPanel = uWidgetLayoutLibrary.SlotAsCanvasSlot(UIRoot)
  UIRoot.RootCanvasPanel = UIRoot.CanvasPanel_0
  UIRoot.ArrowImage = UIRoot.Image_Arrow
  UIRoot.TeammateGridPanel = UIRoot.GridPanel_0
  UIRoot.TeammateDistText = UIRoot.TextBlock_Distance
  UIRoot.TeammateDistPanel = UIRoot.CanvasPanel_DistanceInfo
  UIRoot.TeammateNamePanel = UIRoot.CanvasPanel_Name
end
function IngamePositionItemUI:SetPlayerInfo()
  self:SetInTeamIndex()
  self:SetName()
end
function IngamePositionItemUI:SetInTeamIndex()
  local uPlayerState = self.SavedPlayerState
  if not slua.isValid(uPlayerState) then
    return
  end
  local nPlayerTeamIndex = self.nIndex
  self.UIRoot.TextBlock_TeamIndex:SetText(nPlayerTeamIndex)
end
function IngamePositionItemUI:SetName(bCanShow)
  local uPlayerState = self.SavedPlayerState
  self:SetCollectLevel(false)
  if not slua.isValid(uPlayerState) then
    return
  end
  local TeamPanelUIConfig = GamePlayTools.GetCurrentConfig("TeamPanelUIConfig")
  bCanShow = TeamPanelUIConfig.bShowAliasInfo
  if bCanShow == nil then
    bCanShow = true
  end
  local UIRoot = self.UIRoot
  local sName = uPlayerState.PlayerName
  local nUpassShow = uPlayerState.UpassShow
  local AliasInfo = slua.IndexReference(uPlayerState, "AliasInfo"):clone()
  local nUpKeepBuy = uPlayerState.UpassKeepBuy
  local nUpCurValue = uPlayerState.UpassCurValue
  local bUpIsBuy = uPlayerState.UpassIsBuy
  local pass_type = uPlayerState.pass_type
  local uid = uPlayerState.UID
  local collectScore = uPlayerState.CollectScore or 0
  local seasonCollectScore = uPlayerState.SeasonCollectScore or 0
  local collectScorePrivacy = uPlayerState.CollectScorePrivacy
  local cardCollectCareerScore = uPlayerState.CardCollectCareerScore
  if sName == "" then
    UIRoot.TextBlock_Teammate_Name:SetText("")
    UIRoot.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.Image_Prime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.BG_Frame:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if UIRoot.CanvasPanel_TreasureLv then
      UIRoot.CanvasPanel_TreasureLv:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    UIRoot.TextBlock_Teammate_Name:SetText(sName)
    local uGameState = GameplayData.GetGameState()
    self.nReUpassShow = 0
    local CanShowSubscribe = false
    if slua.isValid(uGameState) then
      local eGameModeType = uGameState.GameModeType
      if eGameModeType ~= uEGameModeType.EWarGameMode then
        CanShowSubscribe = uPlayerState.bShowSubscribe
        self.nReUpassShow = nUpassShow
      end
      local GameModeState = uGameState:GetGameModeState()
      local bIsInReadyState = GameModeState == "ReadyState" or GameModeState == "ActiveState"
      local uPlayerController = GameplayData.GetPlayerController()
      local EGameReplayType = import("EGameReplayType")
      local bCanShowAlias = bIsInReadyState and bCanShow and AliasInfo.aliasID ~= 0 and not uPlayerController:IsHawkEyeSpectator() and uPlayerController.GameReplayType ~= EGameReplayType.EGameReplayType_CompletePlayback
      if bCanShowAlias then
        if Client.IsEditor() then
          AliasInfo = TeamPanelUIConfig.TestAliasInfo
          nUpKeepBuy = 3
          bUpIsBuy = true
          nUpCurValue = 0
          pass_type = 2
        end
        UIRoot.Title_ingame_UIBP:SetAliasInfo(AliasInfo.aliasID, AliasInfo.aliasNation, AliasInfo.aliasRank, AliasInfo.aliasPartnerName, AliasInfo.aliasPartnerRelation, 0, AliasInfo.aliasRankID, AliasInfo.aliasTitle)
        UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      local bUpassBuy, bUpassIsShow = self:ParseUpassShow(self.nReUpassShow)
      if bUpassIsShow and bCanShow and bIsInReadyState then
        UIRoot.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        UIRoot.UnknowPass_ContinuousBuy_BP:SetTypeData(0, nUpKeepBuy, bUpIsBuy, 0, nUpCurValue, pass_type or 0)
      else
        UIRoot.BG_Frame:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        UIRoot.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if CanShowSubscribe and bIsInReadyState and bCanShow then
        UIRoot.Image_Prime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        UIRoot.Image_Prime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if bCanShowAlias then
        UIRoot.BG_Frame:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      else
        UIRoot.BG_Frame:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      self:SetCollectLevel(GameModeState == "ReadyState" and bCanShow, uid, collectScore, seasonCollectScore, collectScorePrivacy)
      self:SetCollectCardLevel(GameModeState == "ReadyState" and bCanShow, uid)
    end
  end
end
function IngamePositionItemUI:SetCollectLevel(bIsInReadyState, uid, collectScore, seasonCollectScore, collectScorePrivacy)
  print(bWriteLog and string.format("IngamePositionItemUI:SetCollectLevel bIsInReadyState=%s, uid=%s, collectScore=%s, seasonCollectScore=%s, collectScorePrivacy=%s,", tostring(bIsInReadyState), uid, collectScore, seasonCollectScore, collectScorePrivacy))
  local UIRoot = self.UIRoot
  if not UIRoot.CanvasPanel_TreasureLv then
    print(bWriteLog and "IngamePositionItemUI:SetCollectLevel CanvasPanel_TreasureLv is nil")
    return
  end
  if not bIsInReadyState then
    UIRoot.CanvasPanel_TreasureLv:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local collect_data = {
    total_score = collectScore,
    cur_season_collect_score = seasonCollectScore,
    privacy = {
      [collect_cfg.privacy.DoubleShowCollectLevel] = collectScorePrivacy
    }
  }
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  local privacy = collect_data.privacy or {}
  if not uid or not collect_privacy_module:CanShowCollectLevel(privacy) then
    print(bWriteLog and string.format("Common_Collect_Level_DynamicLoading_UIBP:_CheckDataValid privacy is not open"))
    UIRoot.CanvasPanel_TreasureLv:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    UIRoot.CanvasPanel_TreasureLv:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.Common_Collect_Level_DynamicLoading_UIBP:InitCollectBadge(uid, collect_data, false)
  end
end
function IngamePositionItemUI:ParseUpassShow(nReUpassShow)
  local bUpassBuy = nReUpassShow & 1 ~= 0
  local bUpassIsShow = nReUpassShow & 2 ~= 0
  return bUpassBuy, bUpassIsShow
end
function IngamePositionItemUI:SetColor(InColor)
  local UIRoot = self.UIRoot
  if slua.isValid(self.SavedPlayerState) then
    local nPlayerTeamIndex = self.nIndex
    if 0 <= nPlayerTeamIndex and nPlayerTeamIndex < 9 then
      local Color = InColor or TeamPanelConfig.TeamPlayerColorTable[nPlayerTeamIndex]
      UIRoot.Image_ParachutingBG:SetColorAndOpacity(Color)
      UIRoot.Image_InAirCraftStateBG:SetColorAndOpacity(Color)
      UIRoot.Image_PlayerFallToTheGroundBG:SetColorAndOpacity(Color)
      UIRoot.Image_PlayerDeadBG:SetColorAndOpacity(Color)
      UIRoot.Image_PlayerOffOnlineBG:SetColorAndOpacity(Color)
      UIRoot.Image_LandingTeammate:SetColorAndOpacity(Color)
    end
  end
end
function IngamePositionItemUI:SetState(ePlayerLiveState, bForceUpdate)
  if self.bForbidUpdateLiveState and bForceUpdate ~= true then
    print(bWriteLog and "IngamePositionItemUI_Debug_Msg: SetState bForbidUpdateLiveState ***RETURN***", self.bForbidUpdateLiveState)
    return
  end
  if not self.UIRoot then
    return
  end
  if not slua.isValid(self.SavedPlayerState) then
    return
  end
  ePlayerLiveState = ePlayerLiveState or self.SavedPlayerState.LiveState
  print(bWriteLog and "IngamePositionItemUI_Debug_Msg: SetState InePlayerLiveState ", ePlayerLiveState, " self.ePlayerLiveState", self.ePlayerLiveState, " bForceUpdate", bForceUpdate)
  local UIRoot = self.UIRoot
  if bForceUpdate ~= true and self.ePlayerLiveState and self.ePlayerLiveState == ePlayerLiveState then
    return
  end
  self.  local ActiveWidgetIndex = UIRoot.WidgetSwitcher_TeammateState:GetActiveWidgetIndex()
  UIRoot.TeammateNameHorizontalBox:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self:SetColor()
  if ePlayerLiveState == uEPlayerLiveState.InDefault then
    self:SetDefaultState()
  elseif ePlayerLiveState == uEPlayerLiveState.InPlane then
    self:SetInPlaneState()
  elseif ePlayerLiveState == uEPlayerLiveState.InParachute then
    self:SetInParachuteState()
  elseif ePlayerLiveState == uEPlayerLiveState.InVehicle then
    self:SetInVehicleState()
  elseif ePlayerLiveState == uEPlayerLiveState.InDying then
    self:SetInDyingState()
  elseif ePlayerLiveState == uEPlayerLiveState.InDied then
    self:SetInDiedState()
  elseif ePlayerLiveState == uEPlayerLiveState.Offline then
    self:SetOfflineState()
  end
  if ActiveWidgetIndex ~= UIRoot.WidgetSwitcher_TeammateState:GetActiveWidgetIndex() then
    EventSystem:postEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_LIVE_STATE_CHANGE, self.nTeamMemberIndex - 1, tonumber(ePlayerLiveState))
  end
end
function IngamePositionItemUI:SetDefaultState()
  self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(0)
  self:ShowInTeamIndex(true)
end
function IngamePositionItemUI:SetInPlaneState()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) and uPlayerState.LiveState == uEPlayerLiveState.InPlane then
      self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(0)
      self:ShowInTeamIndex(true)
      self.UIRoot.TeammateNameHorizontalBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(1)
      self:ShowInTeamIndex(false)
    end
  end
end
function IngamePositionItemUI:SetInParachuteState()
  self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(2)
  self:ShowInTeamIndex(false)
end
function IngamePositionItemUI:SetInVehicleState()
  self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(1)
  self:ShowInTeamIndex(false)
end
function IngamePositionItemUI:SetInDyingState()
  self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(4)
  self:ShowInTeamIndex(false)
end
function IngamePositionItemUI:SetInDiedState()
  self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(3)
  self:ShowInTeamIndex(false)
end
function IngamePositionItemUI:SetOfflineState()
  self.UIRoot.WidgetSwitcher_TeammateState:SetActiveWidgetIndex(5)
  self:ShowInTeamIndex(false)
end
function IngamePositionItemUI:ShowInTeamIndex(bIsShow)
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return
  end
  local PlayerState = PlayerController.PlayerState
  if not Game:IsValid(PlayerState) then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  local GameModeState = uGameState:GetGameModeState()
  local bIsInReadyState = GameModeState == "ReadyState" or GameModeState == "ActiveState"
  if PlayerState == self.SavedPlayerState and bIsInReadyState then
    return
  end
  if bIsShow then
    self.UIRoot.TextBlock_TeamIndex:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.UIRoot.TextBlock_TeamIndex:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngamePositionItemUI:OnCongregationFlagDelegate_Handle()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uChatComponent = uSTExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
    if slua.isValid(uChatComponent) and slua.isValid(self.SavedPlayerState) and slua.isValid(self.SavedPlayerState.CharacterOwner) then
      local sPlayerKey = self.SavedPlayerState.CharacterOwner:GetPlayerKey()
      if sPlayerKey == uChatComponent.CongregationPlayerKey then
        self.UIRoot.CanvasPanel_QuickTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self:DelayHideQuick()
      end
    end
  end
end
function IngamePositionItemUI:DelayHideQuick()
  self.HideQuickTimer = self:AddGameTimer(5, false, function()
    if self.HideQuickTimer and slua.isValid(self.UIRoot.CanvasPanel_QuickTips) then
      self.UIRoot.CanvasPanel_QuickTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end)
end
function IngamePositionItemUI:ShowDistancePanel()
  self.UIRoot.CanvasPanel_DistanceInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TeammateDistPanel = self.UIRoot.CanvasPanel_DistanceInfo
end
function IngamePositionItemUI:HideDistancePanel()
  self.UIRoot.CanvasPanel_DistanceInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TeammateDistPanel = nil
end
function IngamePositionItemUI:SetPlayerNameTDM(sName, nIndex)
  self.UIRoot.TextBlock_Teammate_Name:SetText(sName)
  self.UIRoot.TextBlock_TeamIndex:SetText(tostring(nIndex))
  self.UIRoot.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_Prime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.UIRoot.CanvasPanel_TreasureLv then
    self.UIRoot.CanvasPanel_TreasureLv:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.UIRoot.BG_Frame:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  print(bWriteLog and "IngamePositionItemUI_Debug_Msg: SetPlayerNameTDM")
end
function IngamePositionItemUI:HideAliasPanel()
  self.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  print(bWriteLog and "IngamePositionItemUI_Debug_Msg: HideAliasPanel")
end
function IngamePositionItemUI:ChangeScaleForImageList(bIsHalf)
  if bIsHalf then
    self.UIRoot.TextBlock_TeamIndex:SetRenderScale({0.5, 0.5})
  else
    self.UIRoot.TextBlock_TeamIndex:SetRenderScale({1, 1})
  end
end
function IngamePositionItemUI:InitPlayerVeteran(bIsShow, bNeedShowVeteran)
  if not self.UIRoot then
    return
  end
  if bNeedShowVeteran and bIsShow and slua.isValid(self.SavedPlayerState) then
    local eMentorPlayerType = self.SavedPlayerState:GetMentorPlayerType()
    if eMentorPlayerType == uEMentorPlayerType.MPT_NormalPlayer then
      self.UIRoot.WidgetSwitcher_Veteran:SetActiveWidgetIndex(0)
    elseif eMentorPlayerType == uEMentorPlayerType.MPT_Veteran then
      self.UIRoot.WidgetSwitcher_Veteran:SetActiveWidgetIndex(1)
      local sPath = InGameUITools.GetPlayerVeteranIconPath(self.SavedPlayerState)
      USTExtraUIUtils.SetImageTextureAsync(sPath, self.UIRoot.veteran)
    elseif eMentorPlayerType == uEMentorPlayerType.MPT_Recruit then
      self.UIRoot.WidgetSwitcher_Veteran:SetActiveWidgetIndex(2)
    end
  else
    self.UIRoot.WidgetSwitcher_Veteran:SetActiveWidgetIndex(0)
  end
end
function IngamePositionItemUI:OnPlayerEnterFlying_Handle()
  self:SetPlayerInfo()
end
function IngamePositionItemUI:OnGameStateChange_Handle(sGameState)
  if sGameState == "FightingState" then
    log(bWriteLog and "xcc IngamePositionItemUI:OnGameStateChange_Handle FightingState")
    self:SetPlayerInfo()
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) then
      return
    end
    local LocalPlayerState = PlayerController.PlayerState
    if LocalPlayerState == self.SavedPlayerState then
      self:SetCurrentWidgetVisible(false)
    end
  elseif sGameState ~= "ReadyState" then
    log(bWriteLog and "xcc IngamePositionItemUI:OnGameStateChange_Handle not ReadyState")
    self:SetCollectLevel(false)
  end
end
function IngamePositionItemUI:SetCurrentWidgetVisible(bVisible, bIncludeSelf)
  if slua.isValid(self.SavedPlayerState) and self.SavedPlayerState.PlayerName then
    print(bWriteLog and "IngamePositionItemUI:SetCurrentWidgetVisible PlayerName " .. self.SavedPlayerState.PlayerName .. " bVisible " .. tostring(bVisible))
  else
    print(bWriteLog and "IngamePositionItemUI:SetCurrentWidgetVisible " .. tostring(bVisible))
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return
  end
  local SelfPlayerState = PlayerController.PlayerState
  if not Game:IsValid(SelfPlayerState) then
    return
  end
  if bVisible then
    if self.SavedPlayerState ~= SelfPlayerState or bIncludeSelf == true then
      self.UIRoot.CanvasPanel_SelfVisibility:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  else
    self.UIRoot.CanvasPanel_SelfVisibility:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  end
end
function IngamePositionItemUI:UpdatePlayerRevivalTime(nRemainingRevivalTime, nMaxRevivalTime)
end
function IngamePositionItemUI:UpdatePlayerRevivalState(bInRevivalState, bIsIDCapPick)
end
function IngamePositionItemUI:OnTeammateHPChangeDelegate_Handle()
  if slua.isValid(self.SavedPlayerState) then
    local PlayerLiveState = self.SavedPlayerState.LiveState
    if PlayerLiveState and PlayerLiveState == uEPlayerLiveState.InDying then
      self:UpdateDyingHP()
    end
  end
end
function IngamePositionItemUI:OnTeammateRescueStateChanged_Handle()
  self:SetBeingRescuedIcon()
end
function IngamePositionItemUI:SetBeingRescuedIcon()
  if not slua.isValid(self.SavedPlayerState) then
    return
  end
  if self.SavedPlayerState.RescueTime and self.SavedPlayerState.RescueTime.bBeingRescued then
    self.BeingRescuedTimer = self:AddGameTimer(0.1, true, function()
      self:SetBeingRescuedTimer()
    end)
  else
    self:RemoveBeingRescuedTimer()
    self:UpdateDyingHP()
  end
end
function IngamePositionItemUI:SetBeingRescuedTimer()
  if not slua.isValid(self.SavedPlayerState) then
    return
  end
  if not self.SavedPlayerState.RescueTime then
    return
  end
  local nBeginTime = self.SavedPlayerState.RescueTime.RescueStartTime or 0
  local nEndTime = self.SavedPlayerState.RescueTime.RescueExpectedEndTime or 0
  local nTatolRescueTime = nEndTime - nBeginTime
  if not (0 < nTatolRescueTime) then
    nTatolRescueTime = 10
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local nCurrentTime = uGameState:GetServerWorldTimeSeconds()
  local nRestTime = nEndTime - nCurrentTime
  if 0 <= nRestTime and self.SavedPlayerState.RescueTime.bBeingRescued then
    self:GetImageProgress():SetColorAndOpacity(TeamPanelConfig.BeingRescuedColor)
    local nRestPercent = nRestTime / nTatolRescueTime
    self:SetSavingProgress(nRestPercent)
  else
    self:RemoveBeingRescuedTimer()
  end
end
function IngamePositionItemUI:GetImageProgress()
  return self.UIRoot.Image_Progress
end
function IngamePositionItemUI:UpdateDyingHP()
  if not slua.isValid(self.SavedPlayerState) then
    return
  end
  if self.SavedPlayerState.RescueTime and self.SavedPlayerState.RescueTime.bBeingRescued then
  else
    self:GetImageProgress():SetColorAndOpacity(TeamPanelConfig.PosItemDyingColor)
    local nBreathPercentage = self.SavedPlayerState:GetBreathPercentage()
    self:SetSavingProgress(1 - nBreathPercentage)
  end
end
function IngamePositionItemUI:RemoveBeingRescuedTimer()
  if self.BeingRescuedTimer then
    self:RemoveGameTimer(self.BeingRescuedTimer)
    self.BeingRescuedTimer = nil
  end
end
function IngamePositionItemUI:SetSavingProgress(nPercent)
  local uMaterialInstDynamic = self:GetImageProgress():GetDynamicMaterial()
  if slua.isValid(uMaterialInstDynamic) then
    uMaterialInstDynamic:SetScalarParameterValue("Mask_Percent", nPercent)
  end
end
function IngamePositionItemUI:DebugMsgTest()
  self.DebugTimer = self:AddGameTimer(5, true, function()
    if not slua.isValid(self.SavedPlayerState) then
      return
    end
    local uCharacterOwner = self.SavedPlayerState.CharacterOwner
    if not slua.isValid(uCharacterOwner) then
      return
    end
    local Loc = uCharacterOwner:K2_GetActorLocation()
    print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: ", self.SavedPlayerState.PlayerName, "Loc: ", Loc.X, Loc.Y, Loc.Z)
  end)
end
function IngamePositionItemUI:AddCustomStatusIconByUIConfig(Config)
  print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: Try AddCustomStatusIconByUIConfig", Config.Tag)
  if not Config.UIConfig then
    print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: AddCustomStatusIconByUIConfig UIConfig is nil!")
    return
  end
  local UIConfig = Config.UIConfig
  if type(UIConfig) == "string" then
    UIConfig = UIManager.UI_Config_InGame[UIConfig]
  end
  if slua.isValid(self.UIRoot[Config.Position]) then
    local StateIconUI = self:FindCurrentDynamicIcon(Config)
    if StateIconUI then
      StateIconUI:InitPosItemPlayerStateWidget(self.SavedPlayerState)
    else
      StateIconUI = UIManager.ShowUI(UIConfig, self.SavedPlayerState)
      if StateIconUI then
        table.insert(self.DynamicIconList, {UI = StateIconUI, DynamicConfig = Config})
        self:AttachChildWindow("CanvasPanel_StateIcon_Slot", StateIconUI)
        StateIconUI:SetAnchors(0.5, 0.5, 0.5, 0.5)
        StateIconUI:SetOffsets(0, 0, 0, 0)
        StateIconUI:SetAlignment(0.5, 0.5)
        print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: AddCustomStatusIconByUIConfig ShowUI!", Config.Tag)
      end
    end
  else
    print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: AddCustomStatusIconByUIConfig Position widget not valid!", Config.Tag)
  end
end
function IngamePositionItemUI:FindCurrentDynamicIcon(Config)
  local DynamicIconList = self.DynamicIconList
  for _, DynamicIcon in pairs(DynamicIconList) do
    if Config.Tag == DynamicIcon.DynamicConfig.Tag and Config.Position == DynamicIcon.DynamicConfig.Position then
      return DynamicIcon.UI
    end
  end
end
function IngamePositionItemUI:ClearDynamicIconList()
  for _, DynamicIcon in pairs(self.DynamicIconList) do
    if DynamicIcon.UI then
      DynamicIcon.UI:Close()
    end
    DynamicIcon = nil
  end
  self.DynamicIconList = {}
end
function IngamePositionItemUI:SetForbidUpdateLiveState(bForbid)
  self.bForbidUpdateLiveState = bForbid
  print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: SetForbidUpdateLiveState ", bForbid)
end
function IngamePositionItemUI:GetPetSpectatingPawn()
  if not Game:IsValid(self.SavedPlayerState) then
    return
  end
  local PetSpactatingPawn = self.SavedPlayerState:GetPetSpectatingPawn()
  if not Game:IsValid(PetSpactatingPawn) then
    return
  end
  return PetSpactatingPawn
end
function IngamePositionItemUI:OnTeammatePetSpectatingPawnChangeDelegateHandle()
  print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: OnTeammatePetSpectatingPawnChangeDelegateHandle", self:GetPetSpectatingPawn())
  if not self:GetPetSpectatingPawn() then
    self:InitUI()
  else
    self:RefreshPetSpectatingMark()
  end
end
function IngamePositionItemUI:RefreshPetSpectatingMark()
  if self:GetPetSpectatingPawn() then
    self:SetColor(FLinearColor(1, 1, 1, 1))
    self:SetInTeamIndex()
    self:SetDefaultState()
    if Game:IsValid(self.SavedPlayerState) then
      local PlayerName = self.SavedPlayerState.PlayerName
      local PetSpectatingPawn = self:GetPetSpectatingPawn()
      if not (PetSpectatingPawn and PetSpectatingPawn.PetSpectatorAvatarComponent_BP) or not PetSpectatingPawn.PetSpectatorAvatarComponent_BP:GetPetDefaultAvatarHandle() then
        local Str = LocUtil.GetLocalizeResStr(43005)
        PlayerName = string.format(PlayerName .. "(%s)", Str)
      end
      self.UIRoot.TextBlock_Teammate_Name:SetText(PlayerName)
    end
  end
end
function IngamePositionItemUI:SetAlphaBegin(Alpha)
  self.UIRoot.AlphaBegin = 0.6
  if Alpha then
    self.UIRoot.AlphaBegin = Alpha
  end
end
function IngamePositionItemUI:SetAlphaStep(Alpha)
  self.UIRoot.AlphaStep = 0.01
  if Alpha then
    self.UIRoot.AlphaStep = Alpha
  end
end
function IngamePositionItemUI:SetSavedPlayerState(uPlayerState)
  self.UIRoot:SetSavedPlayerState(uPlayerState)
end
function IngamePositionItemUI:SetNamePanelShow(bShow)
  local UIRoot = self.UIRoot
  if not slua.isValid(UIRoot) then
    return
  end
  print(bWriteLog and "IngamePositionItemIcon_Debug_Msg: SetNamePanelShow:", bShow)
  if bShow then
    if UIRoot.InvalidationBox_0 then
      UIRoot.InvalidationBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
    if UIRoot.InvalidationBox_1 then
      UIRoot.InvalidationBox_1:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  else
    if UIRoot.InvalidationBox_0 then
      UIRoot.InvalidationBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if UIRoot.InvalidationBox_1 then
      UIRoot.InvalidationBox_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function IngamePositionItemUI:SetCollectCardLevel(bIsInReadyState, uid)
  local UIRoot = self.UIRoot
  if not UIRoot.CanvasPanel_CardLv then
    return
  end
  if not bIsInReadyState then
    UIRoot.CanvasPanel_CardLv:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local CardCollectionUtil = require("client.slua.umg.CardCollection.CardCollectionUtil")
  if not CardCollectionUtil.IsCardCollectionOpen() then
    UIRoot.CanvasPanel_CardLv:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  UIRoot.CanvasPanel_CardLv:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not self.CardCollection_Level then
    local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
    self.CardCollection_Level = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.CardCollection_Collect_Level_02, self.UIRoot.CardCollection_Level)
  end
  if self.CardCollection_Level then
    self.CardCollection_Level:SetDataByUid(uid, true)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, IngamePositionItemUI)