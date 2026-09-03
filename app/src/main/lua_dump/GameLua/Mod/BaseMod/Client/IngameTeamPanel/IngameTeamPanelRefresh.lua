local IngameTeamPanel = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local uEPlayerLiveState = import("ExtraPlayerLiveState")
local uEFollowState = import("EFollowState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local uEMentorPlayerType = import("EMentorPlayerType")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local uSTExtraUIUtils = import("STExtraUIUtils")
function IngameTeamPanel:InitTeammateStatusIconUI()
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  local TeammateStatusIconConfig = ClientGameMain.GetUIOtherSetting("TeammateStatusIconConfig")
  if TeammateStatusIconConfig then
    self:InitTeammateStatusIconUIImp(TeammateStatusIconConfig)
  else
    self:InitTeammateStatusIconUIImp(self.DefaultTeammateStatusIconConfig)
  end
end
function IngameTeamPanel:InitTeammateStatusIconUIImp(StatusConfigList)
  if not StatusConfigList then
    print(bWriteLog and "TeamPanel_Debug_Msg: InitTeammateStatusIconUIImp StatusConfigList is nil")
    return
  end
  for _, StateConfig in ipairs(StatusConfigList) do
    self:AddTeammateStatusIconRegisteConfig(StateConfig)
  end
end
function IngameTeamPanel:ReInitDynamicUI()
  self:_ReCreateDynamicStateIcons()
  self:_ReInitTeammateStatusIconUI()
  self:_ReInitPositionItemStatusIconUI()
end
function IngameTeamPanel:AddTeammateStatusIconRegisteConfig(StateConfig)
  if not StateConfig then
    return
  end
  table.insert(self.StatusConfigList, StateConfig)
  local TeamItemList = self.TeamItemList
  if TeamItemList then
    for _, TeamItem in pairs(TeamItemList) do
      if TeamItem then
        TeamItem:AddCustomStatusIconByUIConfig(StateConfig)
      end
    end
  end
end
function IngameTeamPanel:_ReInitTeammateStatusIconUI()
  print(bWriteLog and "TeamPanel_Debug_Msg: _ReInitTeammateStatusIconUI")
  local TeamItemList = self.TeamItemList or {}
  local StatusConfigList = self.StatusConfigList or {}
  for _, StateConfig in pairs(StatusConfigList) do
    for _, TeamItem in pairs(TeamItemList) do
      if TeamItem then
        TeamItem:AddCustomStatusIconByUIConfig(StateConfig)
      end
    end
  end
end
function IngameTeamPanel:AddPositionItemStatusIconRegisteConfig(StateConfig)
  if not StateConfig then
    return
  end
  StateConfig.Position = "CanvasPanel_StateIcon_Slot"
  table.insert(self.PositionStatusConfigList, StateConfig)
  local TeammatePosItemList = self.TeammatePosItemList
  for _, TeamItem in pairs(TeammatePosItemList) do
    if TeamItem then
      TeamItem:AddCustomStatusIconByUIConfig(StateConfig)
    end
  end
end
function IngameTeamPanel:_ReInitPositionItemStatusIconUI()
  print(bWriteLog and "TeamPanel_Debug_Msg: _ReInitPositionItemStatusIconUI")
  local TeammatePosItemList = self.TeammatePosItemList or {}
  local PositionStatusConfigList = self.PositionStatusConfigList or {}
  for _, StateConfig in pairs(PositionStatusConfigList) do
    for _, TeamItem in pairs(TeammatePosItemList) do
      if TeamItem then
        TeamItem:AddCustomStatusIconByUIConfig(StateConfig)
      end
    end
  end
end
function IngameTeamPanel:UpdateTeamMateHP()
  local TeamItemList = self.TeamItemList or {}
  for nIndex, TeamItem in pairs(TeamItemList) do
    local uItemPlayerState = TeamItem.uPlayerState
    if slua.isValid(uItemPlayerState) then
      local nHealthPercent = uItemPlayerState:GetPlayerHealthPercent()
      local eLiveState = uItemPlayerState.LiveState
      if not (0 < nHealthPercent) and (eLiveState == uEPlayerLiveState.InDying or eLiveState == uEPlayerLiveState.InDied or eLiveState == uEPlayerLiveState.Offline) then
        local nBreathPercentage = uItemPlayerState:GetBreathPercentage()
        TeamItem:SetHP(nBreathPercentage, eLiveState == uEPlayerLiveState.InDying)
      else
        TeamItem:SetHP(nHealthPercent, false)
      end
    end
  end
end
function IngameTeamPanel:FollowPanelControl()
  self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Button_OneClickInvitation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.bDisableFollowPanel then
    self.UIRoot.FollowParachute_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self:UpdateTeamPFList()
  local eLiveState = self.uLocalOwnerPlayerstate.LiveState
  local nValidTeammateCount = self:GetValidTeammateStateNum()
  local uGameState = GameplayData.GetGameState()
  local bIsReadyState, bIsInPlane
  if slua.isValid(uGameState) then
    bIsReadyState = uGameState:GetGameModeState() == "ReadyState"
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    bIsInPlane = uPlayerController:IsInPlane()
  end
  local bCanShowParachuteFollow = bIsReadyState or bIsInPlane
  if eLiveState == uEPlayerLiveState.InDied or nValidTeammateCount <= 1 or not bCanShowParachuteFollow then
    self.UIRoot.Button_ParachuteFollow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:ShowHideFollowButton(false)
  else
    self.UIRoot.Button_ParachuteFollow:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function IngameTeamPanel:ClearAliasInfo()
  if self.ShowOtherPositionItemUITimer then
    self:RemoveGameTimer(self.ShowOtherPositionItemUITimer)
  end
  self.ShowOtherPositionItemUITimer = nil
  for _, Item in pairs(self.OtherPositionItemList) do
    if Item then
      Item:Close()
    end
  end
  self.OtherPositionItemList = {}
  self.UIRoot.OtherInfoPanel:ClearChildren()
end
function IngameTeamPanel:UpdateTeamMateState(eLiveState, uTargetCharacter)
  if self.bInfectMode then
    return
  end
  local TeamItemList = self.TeamItemList or {}
  for _, TeamItem in pairs(TeamItemList) do
    local uItemPlayerState = TeamItem.uPlayerState
    if TeamItemList and slua.isValid(uItemPlayerState) then
      TeamItem:SetState(uItemPlayerState.LiveState)
    end
  end
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, TeammatePosItem in pairs(TeammatePosItemList) do
    if TeammatePosItem and slua.isValid(TeammatePosItem.SavedPlayerState) then
      local ePlayerLiveState = TeammatePosItem.SavedPlayerState.LiveState
      TeammatePosItem:SetState(ePlayerLiveState)
      if ePlayerLiveState ~= uEPlayerLiveState.InDied then
        if self.uMainTeammatePos and self.uMainTeammatePos == TeammatePosItem then
          print(bWriteLog and "TeamPanel_Debug_Msg: Dont show MainTeammatePos")
        else
          TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
  self:CheckNeedUpdateTeamPFList()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) and (uPlayerState.LiveState == uEPlayerLiveState.InPlane or uPlayerState.LiveState == uEPlayerLiveState.InParachute) then
      self:UpdateSelfInPlaneBox()
    end
  end
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  if IngameLikeClientSubSystem then
    IngameLikeClientSubSystem:OnRepPlayerState()
  end
end
function IngameTeamPanel:InitOnPlanePosItems(TeamMatePlayerStateList)
  print(bWriteLog and "TeamPanel_Debug_Msg: InitOnPlanePosItems")
  local OnPlanePosItemList = {}
  local insert = table.insert
  local OnPlanePosItemConfig = UIManager.UI_Config_InGame.IngameOnPlanePositionItem_New
  if OnPlanePosItemConfig then
    for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
      if slua.isValid(TeamMatePlayerState) then
        local InTeamIndex = self:GetInTeamIndex(TeamMatePlayerState)
        InTeamIndex = InTeamIndex + 1
        local OnPlanePosItem = UIManager.ShowUI(OnPlanePosItemConfig, InTeamIndex, TeamMatePlayerState)
        if OnPlanePosItem then
          self:AttachChildWindow("HorizontalBox_PlaneTeammate", OnPlanePosItem)
          OnPlanePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          insert(OnPlanePosItemList, OnPlanePosItem)
        end
      end
    end
  end
  self.  self:UpdateSelfInPlaneBox()
end
function IngameTeamPanel:UpdateSelfInPlaneBox()
  print(bWriteLog and "IngameTeamPanel:UpdateSelfInPlaneBox")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController:GetCurPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  if not uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  self:RefreshViewTargetIdx()
  if uPlayerState.LiveState == uEPlayerLiveState.InPlane then
    if self.TeammatePosItemList[self.nViewTargetTeamMemberIdx] then
      self.TeammatePosItemList[self.nViewTargetTeamMemberIdx]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    for index, TeammatePosItem in pairs(self.TeammatePosItemList) do
      if TeammatePosItem and self.OnPlanePosItemList[index] then
        if slua.isValid(TeammatePosItem.SavedPlayerState) and TeammatePosItem.SavedPlayerState.LiveState == uEPlayerLiveState.InPlane then
          self.OnPlanePosItemList[index]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          if slua.isValid(uPlayerState.Plane) and slua.isValid(TeammatePosItem.SavedPlayerState.Plane) and uPlayerState.Plane ~= TeammatePosItem.SavedPlayerState.Plane then
            self.OnPlanePosItemList[index]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            if slua.isValid(TeammatePosItem.SavedPlayerState) and slua.isValid(self.uLocalOwnerPlayerstate) and TeammatePosItem.SavedPlayerState ~= self.uLocalOwnerPlayerstate then
              TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end
          end
        else
          self.OnPlanePosItemList[index]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          if slua.isValid(TeammatePosItem.SavedPlayerState) and slua.isValid(self.uLocalOwnerPlayerstate) and TeammatePosItem.SavedPlayerState ~= self.uLocalOwnerPlayerstate then
            TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
        end
      end
    end
  else
    self:OnShowAllTeammatePosDelegate_Handle(true)
  end
  if uPlayerController.IsSpectator and uPlayerController:IsSpectator() then
    self:Update_HorizontalBox_PlaneTeammate_Visibility()
  end
end
function IngameTeamPanel:Update_HorizontalBox_PlaneTeammate_Visibility()
  local PlayerController = GameplayData.GetPlayerController()
  local Visibility = UEnums.ESlateVisibility.Collapsed
  if slua.isValid(PlayerController) then
    local PlayerState = PlayerController:GetCurPlayerState()
    local EPlayerLiveState = import("ExtraPlayerLiveState")
    if slua.isValid(PlayerState) and PlayerState.LiveState == EPlayerLiveState.InPlane then
      Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
    end
  end
  self.UIRoot.HorizontalBox_PlaneTeammate:SetWidgetVisibility(Visibility)
end
function IngameTeamPanel:RefreshViewTargetIdx()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController:GetCurPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local TeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
    if slua.isValid(TeamMatePlayerState) and TeamMatePlayerState == uPlayerState then
      self.nViewTargetTeamMemberIdx = nIndex + 1
      return
    end
  end
  for nIndex, TeammatePosItem in pairs(TeammatePosItemList) do
    if TeammatePosItem and slua.isValid(TeammatePosItem.SavedPlayerState) and TeammatePosItem.SavedPlayerState == uPlayerState then
      self.nViewTargetTeamMemberIdx = nIndex
      return
    end
  end
end
function IngameTeamPanel:UpdateVeteranStatus()
  self.bIsVeteranRecruit = false
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.PlayerState) then
    local uPlayerState = uPlayerController.PlayerState
    if uPlayerState.GetMentorPlayerType then
      local ePlayerType = uPlayerState:GetMentorPlayerType()
      if ePlayerType ~= uEMentorPlayerType.MPT_NormalPlayer and not self.bIsVeteranRecruit then
        self.bIsVeteranRecruit = true
      end
    end
    local uGameState = GameplayData.GetGameState()
    if slua.isValid(uGameState) then
      local GameModeState = uGameState:GetGameModeState()
      if GameModeState == "ReadyState" and self.bIsVeteranRecruit then
        uPlayerController:CastUIMsg("BeginShowTips", "ingamesub")
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_BEGIN_SHOW_TIPS)
      else
        uPlayerController:CastUIMsg("EndShowTips", "ingamesub")
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_END_SHOW_TIPS)
      end
      local bNeedShowVeteran = InGameUITools.NeedShowVeteran()
      if GameModeState ~= "ReadyState" and GameModeState ~= "FightingState" then
        self:SwitchVeteranStatus_TeamItem(false, bNeedShowVeteran)
        self:SwitchVeteranStatus_TeamPositionItem(false, bNeedShowVeteran)
      else
        self:SwitchVeteranStatus_TeamItem(true, bNeedShowVeteran)
        self:SwitchVeteranStatus_TeamPositionItem(true, bNeedShowVeteran)
      end
    end
  end
end
function IngameTeamPanel:SwitchVeteranStatus_TeamItem(bIsShowVeteran, bNeedShowVeteran)
  local TeamItemList = self.TeamItemList or {}
  for _, TeamItem in pairs(TeamItemList) do
    if TeamItem then
      TeamItem:InitPlayerVeteran(bIsShowVeteran, bNeedShowVeteran)
    end
  end
end
function IngameTeamPanel:SwitchVeteranStatus_TeamPositionItem(bIsShowVeteran, bNeedShowVeteran)
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, PositionItem in pairs(TeammatePosItemList) do
    if PositionItem then
      PositionItem:InitPlayerVeteran(bIsShowVeteran, bNeedShowVeteran)
    end
  end
end
function IngameTeamPanel:OnLostDelegate(uPlayerState)
  print(bWriteLog and "TeamPanel_Debug_Msg: OnLostDelegate Handle PlayerName = " .. uPlayerState.PlayerName)
end
function IngameTeamPanel:OnReconnected(uPlayerState)
  print(bWriteLog and "TeamPanel_Debug_Msg: OnReconnected Handle PlayerName = " .. uPlayerState.PlayerName)
  local TeamItemList = self.TeamItemList or {}
  for nIndex, TeamItem in pairs(TeamItemList) do
    if TeamItem and slua.isValid(TeamItem.uPlayerState) then
      local bIsReconnected = TeamItem.uPlayerState.isReconnected
      local eLiveState = TeamItem.uPlayerState.LiveState
      if bIsReconnected then
        print(bWriteLog and "TeamPanel_Debug_Msg: Real Reconnect PlayerName = " .. TeamItem.uPlayerState.PlayerName)
        TeamItem.bisLostOrExit = false
        TeamItem:SetState(eLiveState, true)
        local Color = IngameTeamPanel.TeamPlayerColorTable[nIndex]
        if Color then
          TeamItem.UIRoot.Image_IDBG:SetColorAndOpacity(Color)
        end
      end
    end
  end
end
function IngameTeamPanel:OnPlayerExitGame(uPlayerState)
  print(bWriteLog and "TeamPanel_Debug_Msg: OnPlayerExitGame Handle PlayerName = " .. uPlayerState.PlayerName)
end
function IngameTeamPanel:OnPlayerExitGameNew(TeamIndex, PlayerKey)
  if not TeamIndex or not PlayerKey then
    return
  end
  TeamIndex = TeamIndex + 1
  local TeamItemList = self.TeamItemList or {}
  local TeamItem = TeamItemList[TeamIndex]
  if not TeamItem then
    return
  end
  TeamItem:SetState(uEPlayerLiveState.Offline)
  TeamItem.bisLostOrExit = true
  print(bWriteLog and "IngameTeamPanel:OnPlayerExitGameNew, TeamIndex = " .. tostring(TeamIndex) .. ", PlayerKey = " .. tostring(PlayerKey))
end
function IngameTeamPanel:OnAITakeOverStateChange(uPlayerState, bAITakeOver, nMasterIndex)
  print(bWriteLog and "TeamPanel_Debug_Msg: OnAITakeOver Handle PlayerName = " .. uPlayerState.PlayerName)
  local TeamItemList = self.TeamItemList or {}
  for nIndex, TeamItem in pairs(TeamItemList) do
    if TeamItem and slua.isValid(TeamItem.uPlayerState) and TeamItem.uPlayerState == uPlayerState then
      if bAITakeOver and TeamItem.SetTakeOverState then
        TeamItem.bAITakeOver = true
        TeamItem:SetTakeOverState()
        local LeaderTeamItem = TeamItemList[nMasterIndex + 1]
        if LeaderTeamItem then
          TeamItem.UIRoot.Image_AITakeOverBG:SetColorAndOpacity(LeaderTeamItem.UIRoot.Image_IDBG.ColorAndOpacity)
        end
        TeamItem.UIRoot.TextBlock_MasterIndex:SetText(tostring(nMasterIndex + 1))
      else
        TeamItem.bAITakeOver = false
        TeamItem:SetState(uEPlayerLiveState.Offline)
      end
    end
  end
end
function IngameTeamPanel:OnTeamFollowStageChangeDelegate()
  self:UpdateTeamPFList()
  self:RefreshAircraftControl()
end
function IngameTeamPanel:UpdateTeamPFList()
  if self.bDisableFollowPanel then
    return
  end
  local bIsInfectGameMode = self:IsInfectMode()
  if bIsInfectGameMode then
    return
  end
  local bIsNeedUpdate = self:IsNeedUpdatePFList()
  if not bIsNeedUpdate then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.PlayerState) then
    local uPlayerState = uPlayerController.PlayerState
    local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
    if slua.isValid(uPawn) and slua.isValid(uPlayerState) then
      if not uPlayerState.GetTeamMatePlayerStateList then
        return
      end
      local nPlayerIndex = uPawn:GetPlayerTeamIndex()
      local TeammateParachuteFollowStateList = uPawn.TeammateParachuteFollowState
      local TeammateParachuteFollowStateListLength = TeammateParachuteFollowStateList:Num()
      local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false) or {}
      local TeamItemList = self.TeamItemList or {}
      for nIndex, TeammatePlayerState in pairs(TeammatePlayerStateList) do
        if slua.isValid(TeammatePlayerState) then
          if nIndex < TeammateParachuteFollowStateListLength and 0 <= nIndex then
            local TeammateParachuteFollowState = TeammateParachuteFollowStateList:Get(nIndex)
            if TeamItemList[nIndex + 1] then
              local TeamItem = TeamItemList[nIndex + 1]
              if TeamItem then
                TeamItem:SetParachuteFollowState(TeammateParachuteFollowState)
                local nLeaderIndex = TeammateParachuteFollowState.LeaderIdx
                local LeaderTeamItem = TeamItemList[nLeaderIndex + 1]
                if LeaderTeamItem then
                  TeamItem.UIRoot.Image_ParachuteBG:SetColorAndOpacity(LeaderTeamItem.UIRoot.Image_IDBG.ColorAndOpacity)
                end
                local AircraftFollowIndex = TeammateParachuteFollowState.AircraftLeaderIdx
                if -1 < AircraftFollowIndex then
                  local Aircraft_LeaderTeamItem = TeamItemList[AircraftFollowIndex + 1]
                  if Aircraft_LeaderTeamItem and TeamItem.UIRoot.Image_AircraftBG then
                    TeamItem.UIRoot.Image_AircraftBG:SetColorAndOpacity(Aircraft_LeaderTeamItem.UIRoot.Image_IDBG.ColorAndOpacity)
                  end
                end
              end
              local FollowItemList = self.FollowItemList or {}
              local FollowItem = FollowItemList[nIndex + 1]
              local AircraftFollowItemList = self.AircraftFollowItemList or {}
              local AircraftFollowItem = AircraftFollowItemList[nIndex + 1]
              if self.IsShowAircraftPanel then
                if FollowItem then
                  FollowItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                end
                if AircraftFollowItem and 0 <= nPlayerIndex and nPlayerIndex < TeammateParachuteFollowStateListLength then
                  AircraftFollowItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                  AircraftFollowItem:RefreshState(nIndex, nPlayerIndex, TeammateParachuteFollowState, TeammateParachuteFollowStateList:Get(nPlayerIndex), TeammatePlayerState.LiveState, TeammateParachuteFollowStateList)
                end
              else
                if AircraftFollowItem then
                  AircraftFollowItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                end
                if FollowItem and 0 <= nPlayerIndex and nPlayerIndex < TeammateParachuteFollowStateListLength then
                  FollowItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                  FollowItem:RefreshState(nIndex, nPlayerIndex, TeammateParachuteFollowState, TeammateParachuteFollowStateList:Get(nPlayerIndex), TeammatePlayerState.LiveState)
                end
              end
            end
          else
            print(bWriteLog and "TeamPanel_Debug_Msg: ===ERROR=== UpdateTeamPFList TeammateParachuteFollowStateList Out of Range")
          end
        end
      end
      uPlayerController:CastUIMsg("UIMSG_ParachutingLeaderChange", "ingame")
      local eFollowState = uPawn.FollowState
      if eFollowState == uEFollowState.None or eFollowState == uEFollowState.Leader then
        self.UIRoot.Button_OneClickInvitation:SetIsEnabled(true)
      else
        self.UIRoot.Button_OneClickInvitation:SetIsEnabled(false)
      end
    end
  end
  if self.UIRoot.CanvasPanel_FollowPanel:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    self:ShowHideFollowButton(true)
  end
end
function IngameTeamPanel:HideMatchStragetyLabel()
  local TeamItemList = self.TeamItemList or {}
  for _, TeamItem in pairs(TeamItemList) do
    if TeamItem then
      TeamItem:HideMatchStragetyRoot()
    end
  end
end
function IngameTeamPanel:ShowTeamInfo(bShow)
  print(bWriteLog and "TeamPanel_Debug_Msg: ShowTeamInfo", bShow)
  if not self.UIRoot then
    return
  end
  if bShow then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.bIsShow = true
  else
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.bIsShow = false
  end
end
function IngameTeamPanel:CheckNeedUpdateTeamPFList()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local bIsInPlane = uPlayerController:IsInNormalPlane()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local GameModeState = uGameState:GetGameModeState()
  local uCurPlayerState = uPlayerController:GetCurPlayerState()
  if slua.isValid(uCurPlayerState) then
    local nValidTeammateCount = self:GetValidTeammateStateNum()
    if 1 < nValidTeammateCount and (bIsInPlane or GameModeState == "ReadyState") then
      self.UIRoot.Button_ParachuteFollow:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self:UpdateTeamPFList()
    else
      self.UIRoot.Button_ParachuteFollow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:ShowHideFollowButton(false)
    end
    self.UIRoot.CanvasPanel_FollowPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_OneClickInvitation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamPanel:EventAddStatusMarkToTeamItem(_, _, uPlayerState, sMarkPath, sTag)
  local TeamItemList = self.TeamItemList or {}
  for _, TeamItem in pairs(TeamItemList) do
    if TeamItem and TeamItem.uPlayerState and TeamItem.uPlayerState == uPlayerState then
      TeamItem:AddCustomStatusMarkByUIPath(sMarkPath, sTag)
    end
  end
end
function IngameTeamPanel:RemindTeammateShoot_Handle(sPlayerKey, bShow, nDist)
  if nDist <= self.ShotRemindDist then
    local TeamItemList = self.TeamItemList
    for _, TeamItem in pairs(TeamItemList) do
      if TeamItem and slua.isValid(TeamItem.uPlayerState) then
        local uPawn = TeamItem.uPlayerState:GetPlayerCharacter()
        if slua.isValid(uPawn) and uPawn:GetPlayerKey() == sPlayerKey then
          TeamItem:UpdateShoot(true)
        end
      end
    end
  end
end
function IngameTeamPanel:HideTeamMateDistance()
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, TeammatePosItem in pairs(TeammatePosItemList) do
    if TeammatePosItem then
      TeammatePosItem:HideDistancePanel()
    end
  end
end
function IngameTeamPanel:ShoworHideAllTeamPos(bIsShow, bIncludeMe)
  print(bWriteLog and "IngameTeamPanel:ShoworHideAllTeamPos " .. tostring(bIsShow))
  local TeammatePosItemList = self.TeammatePosItemList
  for _, TeammatePosItem in pairs(TeammatePosItemList) do
    if TeammatePosItem and (not bIncludeMe and self.uMainTeammatePos == TeammatePosItem or bIncludeMe) then
      if bIsShow and slua.isValid(TeammatePosItem.SavedPlayerState) then
        TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        TeammatePosItem:SetCurrentWidgetVisible(true)
      else
        TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        TeammatePosItem:SetCurrentWidgetVisible(false)
      end
    end
  end
end
function IngameTeamPanel:ShowMainTeamPos()
  if slua.isValid(self.uMainTeammatePos) then
    self.uMainTeammatePos:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) or not uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  local TeammatePosItem = self.TeammatePosItemList[self.nLocalOwnerTeamMemberIdx + 1]
  if not TeammatePosItem or not TeammatePosItem.SetSavedPlayerState then
    return
  end
  TeammatePosItem:SetSavedPlayerState(uPlayerState)
  self.uCurTeammateItem = TeammatePosItem
  TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  TeammatePosItem:SetPlayerInfo()
  self.uMainTeammatePos = TeammatePosItem
  local TeamItemList = self.TeamItemList
  for nIndex, TeamItem in pairs(TeamItemList) do
    local Color = IngameTeamPanel.TeamPlayerColorTable[nIndex]
    TeamItem:InitPlayerColor(Color)
    if self.nLocalOwnerTeamMemberIdx + 1 == nIndex and slua.isValid(self.uCurTeammateItem) then
      self.uCurTeammateItem:SetColor()
      self.uCurTeammateItem:SetState()
    end
  end
end
function IngameTeamPanel:HideMainTeamPos()
  if self:CanShowSelfPositionItem() then
    return
  end
  if slua.isValid(self.uMainTeammatePos) then
    self.uMainTeammatePos:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.uMainTeammatePos:SetCurrentWidgetVisible(false)
  end
end
function IngameTeamPanel:HideTeamPanel()
  self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  print(bWriteLog and "TeamPanel_Debug_Msg: HideTeamPanel()")
end
function IngameTeamPanel:ShowTeamPanel()
  self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  print(bWriteLog and "TeamPanel_Debug_Msg: ShowTeamPanel()")
end
function IngameTeamPanel:OnCaptainIndexUpdated(_, CaptainIndex)
  print(bWriteLog and "IngameTeamPanel:OnCaptainIndexUpdated - CaptainIndex: ", tostring(CaptainIndex))
  if not self.TeamItemList then
    print(bWriteLog and "IngameTeamPanel:OnCaptainIndexUpdated - self.TeamItemList is nil")
    return
  end
  for Index, TeamItem in ipairs(self.TeamItemList) do
    if Index == CaptainIndex + 1 then
      TeamItem:ShowCaptainImage(true)
    else
      TeamItem:ShowCaptainImage(false)
    end
  end
end