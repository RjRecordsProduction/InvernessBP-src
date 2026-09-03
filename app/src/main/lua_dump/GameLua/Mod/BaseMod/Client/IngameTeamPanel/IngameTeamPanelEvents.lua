local IngameTeamPanel = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local uEGameModeType = import("EGameModeType")
local CustomType = require("client.logic.setting.CustomType")
local bUseNewShowAliasInfo = true
function IngameTeamPanel:RegistEvents()
  IngameTeamPanel.__super.RegistEvents(self)
  print(bWriteLog and "TeamPanel_Debug_Msg: !!! TeamPanel RegistEvents !!!")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.OnRepPlayerState_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnTeammateHPChangeDelegate", self.OnTeammateHPChangeDelegate_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnLostConnection", self.OnLostConnection_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnExitGame", self.OnExitGame_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerExitJumping", self.OnPlayerExitJumping_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnMapMarkChangeDelegate", self.OnMapMarkChangeDelegate_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.OnPlayerEnterFlying_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStateChange", self.OnGameStateChange_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnectResetUIByPlayerControllerStateDelegate_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnTeamFollowStageChangeDelegate", self.OnTeamFollowStageChangeDelegate, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnParachuteFollowInviteResponse", self.OnTeamFollowStageChangeDelegate, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnRemindTeammateShoot", self.RemindTeammateShoot_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterJumping", self.OnPlayerEnterParachute_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterParachute", self.OnPlayerEnterParachute_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnShowHideSelfMarkDelegate", self.OnShowHideSelfMarkDelegate_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnShowAllTeammatePosDelegate", self.OnShowAllTeammatePosDelegate_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnShowAliasInfoDelegate", self.OnShowAliasInfoDelegate_Handle, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.UpdateSelfInPlaneBox, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnRepTeammateChange", self.OnRepTeammateChange_Handle, self)
    self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactived, self)
  end
  if slua.isValid(CGameState) then
    local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
    local uMySingletonObj = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
    if slua.isValid(uMySingletonObj) then
      self:AddControlEventByControl(uMySingletonObj, "OnCharacterStateChangeDelegate", self.OnCharacterStateChangeDelegate_Handle, self)
      self:AddControlEventByControl(uMySingletonObj, "OnTeammatePetSpectatingStateChange", self.OnTeammatePetSpectatingStateChange_Handle, self)
    end
  end
  self:AddOnClickedEventByControl(self.UIRoot.Button_ParachuteFollow, self.OnClicked_Button_ParachuteFollow, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Aircraft, self.OnClicked_Button_Aircraft, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_HideFollowList, self.OnClicked_Button_HideFollowList, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OneClickInvitation, self.OnClicked_Button_OneClickInvitation, self)
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if slua.isValid(MainControlPanelTochButton) then
    self:AddControlEventByControl(MainControlPanelTochButton, "ED_ShowSelfieUI ", self.ED_ShowSelfieUI_Handle, self)
    self:AddControlEventByControl(MainControlPanelTochButton, "ED_HideSelfieUI", self.ED_HideSelfieUI_Handle, self)
    self:AddControlEventByControl(MainControlPanelTochButton, "ED_OnShowWinnerTime", self.ED_OnShowWinnerTime_Handle, self)
    self:AddControlEventByControl(MainControlPanelTochButton, "ED_GameReplay_UpdateTeamInfo", self.ED_GameReplay_UpdateTeamInfo_Handle, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_ADDCUSTOM_STATUS_MARK, self.EventAddStatusMarkToTeamItem, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT, self.ShowAllUIForDelayResult_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_MEMBERVOICE, self.MemberVoice_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.HideTeamPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_ALL_UI, self.ShowTeamPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.ShowTeamPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_REVIVE_SINGLE_PLAYER_ONPLAN, self.ShowTeamPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_MVP_CAMERA_CLOSE, self.HideMainTeamPos, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_REPLAYUI, self.EnterBattleReplay_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.HandleOnGameModeStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_ALL_MIC_FX, self.ED_HideAllMicFx_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_SPECTATING_CHAIN, self.OnEnterSpectatingChain, self)
  self:AddUIMessageEvent("UseNewShowAliasInfo", self.UseNewShowAliasInfoCheck, self)
  self:AddUIMessageEvent("ClearAliasInfoListPanel", self.ClearAliasInfoListPanel, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerState", self.OnPlayerStateChange, self)
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
  local AreaSelectSubsystem = SubsystemMgr:Get("AreaSelectSubsystem")
  if AreaSelectSubsystem then
    self:AddDataListener(AreaSelectSubsystem:GetSuperData(), "CaptainIndex", self.OnCaptainIndexUpdated, self)
  end
end
function IngameTeamPanel:SetPositionPanelState(bIsShow)
  local Visibility = bIsShow and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed
  self.UIRoot.CanvasPanel_TeammatePosition:SetWidgetVisibility(Visibility)
  self.UIRoot.OtherInfoPanel:SetWidgetVisibility(Visibility)
end
function IngameTeamPanel:OnPlayerStateChange(_, PlayerState)
  if not slua.isValid(PlayerState) or not PlayerState.GetSuperData then
    return
  end
  self:AddDataListener(PlayerState:GetSuperData(), "RealExitTeamNum", function(_, RealExitTeamNum)
    self:OnPlayerExitGameNew(PlayerState.RealExit_TeamIndex, PlayerState.RealExit_PlayerKey)
  end)
end
function IngameTeamPanel:UseNewShowAliasInfoCheck(Num)
  bUseNewShowAliasInfo = 0 < Num
end
function IngameTeamPanel:ClearAliasInfoListPanel()
  self:ClearAliasInfo()
end
function IngameTeamPanel:OnRepPlayerState_Handle()
  print(bWriteLog and "IngameTeamPanel:OnRepPlayerState_Handle")
  self:InitTeamPanel()
  self:InitSpecialUI()
  self:ReInitDynamicUI()
  print(bWriteLog and "IngameTeamPanel:OnRepPlayerState_Handle End")
end
function IngameTeamPanel:OnTeammateHPChangeDelegate_Handle()
  self:UpdateTeamMateHP()
end
function IngameTeamPanel:OnCharacterStateChangeDelegate_Handle(eLiveState, uTargetCharacter)
  self:UpdateTeamMateState(eLiveState, uTargetCharacter)
  self:Update_HorizontalBox_PlaneTeammate_Visibility()
end
function IngameTeamPanel:OnPlayerExitJumping_Handle()
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) and uGameState:GetGameModeState() == "ReadyState" then
    return
  end
  self.UIRoot.FollowParachute_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:HideMatchStragetyLabel()
end
function IngameTeamPanel:OnPlayerEnterParachute_Handle()
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) and uGameState:GetGameModeState() == "ReadyState" then
    return
  end
  self.UIRoot.FollowParachute_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamPanel:OnMapMarkChangeDelegate_Handle(nTeamMateSerialNumber)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "IngameTeamPanel:OnMapMarkChangeDelegate_Handle - PlayerState is nil")
  end
  local TeamItem = self.TeamItemList[nTeamMateSerialNumber + 1]
  if TeamItem then
    TeamItem:UpdateTeamMateMapMark()
    if TeamItem:IsMapMarkVisible() and TeamItem.uPlayerState ~= PlayerState then
      self.TeammateMarks[nTeamMateSerialNumber + 1] = true
      local Visibility = self.UIRoot.CanvasPanel_FollowPanel:GetVisibility()
      if Visibility == UEnums.ESlateVisibility.Visible and self.IsShowAircraftPanel == false then
        TeamItem:ShowFollowButton(false)
      else
        TeamItem:ShowFollowButton(true)
      end
    else
      self.TeammateMarks[nTeamMateSerialNumber + 1] = false
      TeamItem:ShowFollowButton(false)
    end
  end
end
function IngameTeamPanel:OnPlayerEnterFlying_Handle()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.GameModeType == uEGameModeType.EWarGameMode then
    local TeamItemList = self.TeamItemList or {}
    for _, TeamItem in pairs(TeamItemList) do
      if TeamItem and slua.isValid(TeamItem.uPlayerState) then
        TeamItem:SetState(TeamItem.uPlayerState.LiveState)
      end
    end
  end
end
function IngameTeamPanel:OnGameStateChange_Handle(sGameState)
  if sGameState ~= "ReadyState" then
    self:ClearAliasInfo()
    self:HideMainTeamPos()
  end
  self:UpdateVeteranStatus()
end
function IngameTeamPanel:OnShowHideSelfMarkDelegate_Handle()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.PlayerState) then
    local uPlayerState = uPlayerController.PlayerState
    if not uPlayerState.GetTeamMatePlayerStateList then
      return
    end
    local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false) or {}
    local nCurIndex = -1
    for nIndex, TeammatePlayerState in pairs(TeammatePlayerStateList) do
      if slua.isValid(TeammatePlayerState) and TeammatePlayerState == uPlayerState then
        nCurIndex = nIndex + 1
      end
    end
    local TeamItemList = self.TeamItemList
    if 0 < nCurIndex and TeamItemList[nCurIndex] then
      local nMapMarkZ = uPlayerState.MapMark.Z
      if 0 < nMapMarkZ then
        TeamItemList[nCurIndex].UIRoot.Image_PlayerMark01:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        TeamItemList[nCurIndex].UIRoot.Image_PlayerMark01:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
      end
    end
  end
end
function IngameTeamPanel:MemberVoice_Handle()
  print(bWriteLog and "TeamPanel_Debug_Msg: MemberVoice_Handle")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local nVoiceMemberID = uPlayerController.VoiceMemberID
    local nVoiceMemberStatus = uPlayerController.VoiceMemberStatus
    local TeamItemList = self.TeamItemList or {}
    print(bWriteLog and "TeamPanel_Debug_Msg: MemberVoice_Handle TeamItemListNum : " .. #TeamItemList)
    for _, TeamItem in pairs(TeamItemList) do
      print(bWriteLog and "TeamPanel_Debug_Msg IngameTeamPanel:MemberVoice_Handle VoiceMemberID: " .. TeamItem.nPlayerID .. " : " .. nVoiceMemberID)
      if TeamItem.nPlayerID == nVoiceMemberID then
        TeamItem:UpdateVoice(nVoiceMemberStatus)
      end
    end
  end
end
function IngameTeamPanel:OnShowAllTeammatePosDelegate_Handle(bShow)
  if not slua.isValid(self.uLocalOwnerPlayerstate) then
    return
  end
  local TeammatePosItemList = self.TeammatePosItemList or {}
  if bShow then
    for _, PosItem in pairs(TeammatePosItemList) do
      if PosItem and slua.isValid(PosItem.SavedPlayerState) and self.uLocalOwnerPlayerstate ~= PosItem.SavedPlayerState and slua.isValid(PosItem.UIRoot) then
        PosItem.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  else
    for _, PosItem in pairs(TeammatePosItemList) do
      if PosItem and slua.isValid(PosItem.SavedPlayerState) and self.uLocalOwnerPlayerstate ~= PosItem.SavedPlayerState and slua.isValid(PosItem.UIRoot) then
        PosItem.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function IngameTeamPanel:OnShowAliasInfoDelegate_Handle()
  local OtherPositionItemConfig = UIManager.UI_Config_InGame.OtherPositionItem_BP
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.PlayerState) then
    local AliasInfoList = uPlayerController.PlayerState:GetPlayerAliasInfoList({})
    local insert = table.insert
    if AliasInfoList:Num() > 0 then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local TeamPanelConfig = GamePlayTools.GetCurrentConfig("TeamPanelUIConfig")
      local SortAliasInfos = {}
      for _, AliasInfoItem in pairs(AliasInfoList) do
        local AliasInfo = AliasInfoItem.aliasInfo
        local AliasID = AliasInfo.aliasID
        if not TeamPanelConfig.AliasBlackList[AliasID] then
          local AliasConfig = CDataTable.GetTableData("AliasCfg", AliasID)
          if AliasConfig and AliasConfig.ForbidOtherAlias == 0 then
            local TempAliasInfo = {
              InfoItem = AliasInfoItem,
              Quality = AliasConfig.AliasQuality
            }
            table.insert(SortAliasInfos, TempAliasInfo)
          end
        end
      end
      table.sort(SortAliasInfos, function(a, b)
        return a.Quality > b.Quality
      end)
      if bUseNewShowAliasInfo then
        self:ShowOtherPositionItemUI(SortAliasInfos, TeamPanelConfig.MaxAliasNum)
      else
        local ShowAliasIndex = 0
        for Index, AliasInfo in pairs(SortAliasInfos) do
          if ShowAliasIndex >= TeamPanelConfig.MaxAliasNum then
            break
          end
          local AliasInfoItem = AliasInfo.InfoItem
          local AliasInfo = AliasInfoItem.aliasInfo
          local sPlayerName = AliasInfoItem.playerName
          local uCharacter = AliasInfoItem.character
          if slua.isValid(uCharacter) then
            local sPlayerKey = uCharacter:GetPlayerKey()
            local nMaxAliasInfoNum = self:GetMaxAliasInfoNum()
            print(bWriteLog and "TeamPanel_Debug_Msg: OnShowAliasInfoDelegate_Handle" .. sPlayerName .. tostring(sPlayerKey))
            local OtherPosItem
            if self.OtherPositionItemList[Index] then
              OtherPosItem = self.OtherPositionItemList[Index]
            else
              OtherPosItem = UIManager.ShowUI(OtherPositionItemConfig)
            end
            if Game:IsValid(OtherPosItem) then
              ShowAliasIndex = ShowAliasIndex + 1
              if self.bShowOtherAlias then
                OtherPosItem.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
              else
                OtherPosItem.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
              end
              OtherPosItem:InitPosItem()
              OtherPosItem:InitData(uCharacter)
              OtherPosItem:SetAliasInfo(AliasInfo)
              OtherPosItem:SetOtherName(sPlayerName)
              self:AttachChildWindow("OtherInfoPanel", OtherPosItem)
              self.OtherPositionItemList[Index] = OtherPosItem
            end
          end
        end
        local MaxShowNum = math.min(#SortAliasInfos, TeamPanelConfig.MaxAliasNum) + 1
        for i = MaxShowNum, #self.OtherPositionItemList do
          local OtherPosItem = self.OtherPositionItemList[i]
          if OtherPosItem then
            OtherPosItem.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
        end
      end
    else
      local uGameState = GameplayData.GetGameState()
      if slua.isValid(uGameState) then
        local GameModeState = uGameState:GetGameModeState()
        if GameModeState ~= "ReadyState" or 0 < #self.OtherPositionItemList then
          self:ClearAliasInfo()
        end
      end
    end
  end
end
function IngameTeamPanel:ShowOtherPositionItemUI(SortAliasInfosTable, MaxAliasNum)
  local OtherPositionItemConfig = UIManager.UI_Config_InGame.OtherPositionItem_BP
  local TableLenght = #SortAliasInfosTable
  local CurrentIndex = 1
  if self.ShowOtherPositionItemUITimer then
    self:RemoveGameTimer(self.ShowOtherPositionItemUITimer)
    self.ShowOtherPositionItemUITimer = nil
  end
  self.ShowOtherPositionItemUITimer = self:AddGameTimer(0.2, true, function()
    if CurrentIndex > TableLenght or CurrentIndex > MaxAliasNum then
      if self.ShowOtherPositionItemUITimer then
        self:RemoveGameTimer(self.ShowOtherPositionItemUITimer)
      end
      self.ShowOtherPositionItemUITimer = nil
      local MaxShowNum = math.min(TableLenght, MaxAliasNum) + 1
      for i = MaxShowNum, #self.OtherPositionItemList do
        local OtherPosItem = self.OtherPositionItemList[i]
        if OtherPosItem then
          OtherPosItem.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      end
      return
    end
    local AliasInfoTemp = SortAliasInfosTable[CurrentIndex]
    local AliasInfoItem = AliasInfoTemp.InfoItem
    local AliasInfo = AliasInfoItem.aliasInfo
    local PlayerName = AliasInfoItem.playerName
    local Character = AliasInfoItem.character
    if slua.isValid(Character) then
      local PlayerKey = Character:GetPlayerKey()
      print(bWriteLog and "IngameTeamPanel:ShowOtherPositionItemUI" .. PlayerName .. tostring(PlayerKey))
      local OtherPosItem
      if self.OtherPositionItemList[CurrentIndex] then
        OtherPosItem = self.OtherPositionItemList[CurrentIndex]
      else
        OtherPosItem = UIManager.ShowUI(OtherPositionItemConfig)
      end
      if OtherPosItem then
        if self.bShowOtherAlias then
          OtherPosItem.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
          OtherPosItem.UIRoot.CanvasPanel_AliasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        OtherPosItem:InitPosItem()
        OtherPosItem:InitData(Character)
        OtherPosItem:SetAliasInfo(AliasInfo)
        OtherPosItem:SetOtherName(PlayerName)
        self:AttachChildWindow("OtherInfoPanel", OtherPosItem)
        self.OtherPositionItemList[CurrentIndex] = OtherPosItem
      end
    end
    CurrentIndex = CurrentIndex + 1
  end)
end
function IngameTeamPanel:ShowAllUIForDelayResult_Handle()
  print(bWriteLog and "TeamPanel_Debug_Msg: ShowAllUIForDelayResult_Handle Hide TeamPanel")
  self:HideTeamPanel()
end
function IngameTeamPanel:OnClicked_Button_ParachuteFollow()
  local eVisibility = self.UIRoot.CanvasPanel_FollowPanel:GetVisibility()
  if eVisibility == UEnums.ESlateVisibility.Visible and self.IsShowAircraftPanel == false then
    self.UIRoot.Button_OneClickInvitation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:ShowHideFollowButton(true)
  else
    self.IsShowAircraftPanel = false
    self.UIRoot.Button_OneClickInvitation:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:UpdateTeamPFList()
    self:HideMatchStragetyLabel()
    self:ShowHideFollowButton(false)
    EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_SHOW_FOLLOW_PARACHUTE_PANEL)
  end
end
function IngameTeamPanel:ShowHideFollowButton(bIsShow)
  print(bWriteLog and "IngameTeamPanel:ShowHideFollowButton - bIsShow", tostring(bIsShow))
  if self.bExitBornIsland then
    print(bWriteLog and "IngameTeamPanel:ShowHideFollowButton - ExitBornIsland")
    self.TeammateMarks = {}
    bIsShow = false
  end
  for Index, ItemUI in pairs(self.TeamItemList) do
    if ItemUI then
      ItemUI:ShowFollowButton(bIsShow and self.TeammateMarks[Index])
    end
  end
end
function IngameTeamPanel:OnClicked_Button_Aircraft()
  self.UIRoot.Button_OneClickInvitation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local eVisibility = self.UIRoot.CanvasPanel_FollowPanel:GetVisibility()
  if eVisibility == UEnums.ESlateVisibility.Visible and self.IsShowAircraftPanel == true then
    self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.IsShowAircraftPanel = false
  else
    self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.IsShowAircraftPanel = true
    self:UpdateTeamPFList()
    self:HideMatchStragetyLabel()
  end
end
function IngameTeamPanel:OnClicked_Button_HideFollowList()
  self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Button_OneClickInvitation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamPanel:OnClicked_Button_OneClickInvitation()
  local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
  ClientTLogUtil.ReportGeneralCountByParachutePhase(12022, 12023)
  local FollowItemList = self.FollowItemList or {}
  for _, FollowItem in pairs(FollowItemList) do
    if FollowItem then
      FollowItem:SimInvite()
    end
  end
end
function IngameTeamPanel:ED_ShowSelfieUI_Handle()
  self:HideTeamPanel()
  print(bWriteLog and "TeamPanel_Debug_Msg: ED_ShowSelfieUI_Handle Hide TeamPanel")
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, PosItem in pairs(TeammatePosItemList) do
    if PosItem and slua.isValid(PosItem.SavedPlayerState) and slua.isValid(self.uLocalOwnerPlayerstate) and self.uLocalOwnerPlayerstate ~= PosItem.SavedPlayerState then
      PosItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function IngameTeamPanel:ED_HideSelfieUI_Handle()
  print(bWriteLog and "TeamPanel_Debug_Msg: ED_HideSelfieUI_Handle Show TeamPanel")
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, PosItem in pairs(TeammatePosItemList) do
    if PosItem and slua.isValid(PosItem.SavedPlayerState) and slua.isValid(self.uLocalOwnerPlayerstate) and self.uLocalOwnerPlayerstate ~= PosItem.SavedPlayerState then
      PosItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self:ShowTeamPanel()
end
function IngameTeamPanel:ED_OnShowWinnerTime_Handle()
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  print(bWriteLog and "TeamPanel_Debug_Msg: ED_OnShowWinnerTime_Handle Hide TeamPanel")
end
function IngameTeamPanel:ED_GameReplay_UpdateTeamInfo_Handle(bShow)
  print(bWriteLog and "TeamPanel_Debug_Msg: ED_GameReplay_UpdateTeamInfo_Handle" .. tostring(bShow))
  self:IsInfectMode()
  self:InitTeamPanel()
  self:InitSpecialUI()
  self:ReInitDynamicUI()
  self:ShowTeamInfo(bShow)
  self:OnPlayerExitJumping_Handle()
end
function IngameTeamPanel:ED_HideAllMicFx_Handle()
  local TeamItemList = self.TeamItemList or {}
  for _, TeamItem in pairs(TeamItemList) do
    if TeamItem then
      TeamItem:UpdateVoice()
    end
  end
end
function IngameTeamPanel:OnApplicationReactived()
  local bIsInBattleResult = self:CheckIsInBattleResult()
  print(bWriteLog and "IngameTeamPanel:OnApplicationReactived bIsInBattleResult" .. tostring(bIsInBattleResult))
  if bIsInBattleResult then
    self:Hide()
  end
end
function IngameTeamPanel:OnReconnectResetUIByPlayerControllerStateDelegate_Handle()
  print(bWriteLog and "TeamPanel_Debug_Msg: OnReconnectResetUIByPlayerControllerStateDelegate_Handle")
  if self:CheckIsInBattleResult() then
    self.UIRoot.Canvas_Border_Team:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "TeamPanel_Debug_Msg: OnReconnectResetUIByPlayerControllerStateDelegate_Handle Hide TeamPanel")
  end
  self:OnRepPlayerState_Handle()
  self:ShowTeamPanel()
  local uGameState = GameplayData.GetGameState()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uGameState) and slua.isValid(uPlayerController) then
    self:CheckNeedUpdateTeamPFList()
    local GameModeState = uGameState:GetGameModeState()
    if GameModeState ~= "ReadyState" then
      self:ClearAliasInfo()
    end
    if uPlayerController.IsInNormalPlane then
      local bIsInPlane = uPlayerController:IsInNormalPlane()
      if not bIsInPlane and GameModeState ~= "ReadyState" then
        self:HideMatchStragetyLabel()
      end
    end
  end
end
function IngameTeamPanel:EnterBattleReplay_Handle()
  print(bWriteLog and "TeamPanel_Debug_Msg: EnterBattleReplay_Handle CloseSelf")
  self:CloseSelf()
end
function IngameTeamPanel:OnLostConnection_Handle(TargetPlayerState)
end
function IngameTeamPanel:OnExitGame_Handle(TargetPlayerState)
end
function IngameTeamPanel:OnRepTeammateChange_Handle()
end
function IngameTeamPanel:HandleOnGameModeStateChange(_, __, sState)
  self:CheckNeedUpdateTeamPFList()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local GameModeState = uGameState:GetGameModeState()
  if GameModeState == "FightingState" then
    self:InitTeamPanel()
  end
  if sState == "FightingState" or sState == "FinishedState" then
    self.bExitBornIsland = true
    self:ShowHideFollowButton(false)
  end
end
function IngameTeamPanel:OnTeammatePetSpectatingStateChange_Handle()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local PlayerName = slua.isValid(uPlayerController.PlayerState) and uPlayerController.PlayerState.PlayerName or ""
  print(bWriteLog and "TeamPanel_Debug_Msg: OnTeammatePetSpectatingStateChange_Handle" .. PlayerName)
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, TeammatePosItem in pairs(TeammatePosItemList) do
    if TeammatePosItem then
      TeammatePosItem:OnTeammatePetSpectatingPawnChangeDelegateHandle()
    end
  end
end
function IngameTeamPanel:OnEnterSpectatingChain()
  self.UIRoot.Canvas_Border_Team:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  print(bWriteLog and "TeamPanel_Debug_Msg: OnEnterSpectatingChain Show TeamPanel")
end
function IngameTeamPanel:OnGameDataReady()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GetGameModeState and GameState:GetGameModeState() == "ReadyState" then
    self.bExitBornIsland = false
  else
    self.bExitBornIsland = true
  end
end