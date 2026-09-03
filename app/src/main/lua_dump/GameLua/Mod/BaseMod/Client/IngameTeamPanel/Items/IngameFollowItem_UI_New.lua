local IngameFollowItemUI = {}
local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local uSTExtraUIUtils = import("STExtraUIUtils")
local uEPlayerLiveState = import("ExtraPlayerLiveState")
local uEGameModeType = import("EGameModeType")
local uEFollowState = import("EFollowState")
local uEUAVUseType = import("EUAVUseType")
local uEUAVCharacterMsgType = import("/Script/ShadowTrackerExtra.EUAVCharacterMsgType")
local uEMentorPlayerType = import("EMentorPlayerType")
local uEParachuteInvitationType = import("EParachuteInvitationType")
function IngameFollowItemUI:ctor(_, nIndex, TeamMatePlayerState)
  self.  self.uPlayerState = TeamMatePlayerState
  self.InPlayerFollowState = nil
  self.LocalPlayerFollowState = nil
  self.sTeammateName = TeamMatePlayerState.PlayerName or ""
  self.sTextTransfer = ""
  self.sTextFollow = ""
  self.bHasParachuted = false
  self.bIsTransferLeader = false
  self.nInPlayerTeamIndex = 0
  self.nLocalPlayerTeamIndex = 0
end
function IngameFollowItemUI:OnInitialize()
  IngameFollowItemUI.__super.OnInitialize(self)
  self:InitFollowItem()
end
function IngameFollowItemUI:RegistEvents()
  IngameFollowItemUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_FollowTeammate, self.Button_FollowTeammate_Handle, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_InviteTeammate, self.Button_InviteTeammate_Handle, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UnableFollowTeammate, self.Button_UnableFollowTeammate_Handle, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UnableInviteTeammate, self.Button_UnableInviteTeammate_Handle, self)
  self:AddOnClickedEventByControl(self.UIRoot.CancelFollowBtn, self.Button_CancelFollow_Handle, self)
end
function IngameFollowItemUI:OnPostInitialize()
  IngameFollowItemUI.__super.OnPostInitialize(self)
end
function IngameFollowItemUI:Close()
  self.uPlayerState = nil
  IngameFollowItemUI.__super.Close(self)
end
function IngameFollowItemUI:InitFollowItem()
end
function IngameFollowItemUI:RefreshState(nInTeamIdx, nPlayerInTeamIdx, PFS, PlayerPFS, eLiveState)
  if uEPlayerLiveState.InParachute == eLiveState then
    self.bHasParachuted = true
  end
  self.nInPlayerTeamIndex = nInTeamIdx
  self.nLocalPlayerTeamIndex = nPlayerInTeamIdx
  self.InPlayerFollowState = PFS
  self.LocalPlayerFollowState = PlayerPFS
  if nInTeamIdx == nPlayerInTeamIdx then
    self.UIRoot.HorizontalBox_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    return
  end
  if PlayerPFS.FollowState == uEFollowState.Leader and PFS.LeaderIdx == nPlayerInTeamIdx then
    self:ShowLeaderPanel()
  else
    self:ShowFollowerPanel(nInTeamIdx, nPlayerInTeamIdx, PFS, PlayerPFS, eLiveState)
  end
end
function IngameFollowItemUI:ShowLeaderPanel()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    self.UIRoot.HorizontalBox_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local bIsDuringTransferLeader = uPawn.IsDuringTransferLeader
    if bIsDuringTransferLeader then
      local bLoadingVisible = self.UIRoot.Image_5:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
      if bLoadingVisible then
        self.UIRoot.FollowSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      else
        self.UIRoot.FollowSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      self.UIRoot.FollowCancelSwitcher:SetActiveWidgetIndex(0)
      self.UIRoot.FollowSwitcher:SetActiveWidgetIndex(1)
      if self.sTextTransfer == "" then
        self.sTextTransfer = LocUtil.GetLocalizeResStr(30171)
      end
      self.UIRoot.TextBlock_Btn2:SetText(self.sTextTransfer)
      self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(1)
    else
      self.UIRoot.FollowCancelSwitcher:SetActiveWidgetIndex(0)
      self.UIRoot.FollowSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.FollowSwitcher:SetActiveWidgetIndex(0)
      if self.sTextTransfer == "" then
        self.sTextTransfer = LocUtil.GetLocalizeResStr(30171)
      end
      self.UIRoot.TextBlock_Btn1:SetText(self.sTextTransfer)
      self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(1)
      self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.bIsTransferLeader = true
  end
end
function IngameFollowItemUI:ShowFollowerPanel(nInTeamIdx, nPlayerInTeamIdx, PFS, PlayerPFS, eLiveState)
  self.UIRoot.HorizontalBox_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.FollowSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local bCanBeInvited = (PlayerPFS.LeaderIdx ~= PFS.LeaderIdx or PlayerPFS.FollowState == uEFollowState.None) and not self.bHasParachuted
  if bCanBeInvited then
    self.UIRoot.FollowCancelSwitcher:SetActiveWidgetIndex(0)
    if self.sTextFollow == "" then
      self.sTextFollow = LocUtil.GetLocalizeResStr(30170)
    end
    self.UIRoot.TextBlock_Btn1:SetText(self.sTextFollow)
    self.UIRoot.FollowSwitcher:SetActiveWidgetIndex(0)
    self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(0)
    self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.bIsTransferLeader = false
  elseif nInTeamIdx == PlayerPFS.LeaderIdx then
    self.UIRoot.FollowCancelSwitcher:SetActiveWidgetIndex(1)
    self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(1)
    self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.FollowCancelSwitcher:SetActiveWidgetIndex(0)
    if self.sTextFollow == "" then
      self.sTextFollow = LocUtil.GetLocalizeResStr(30170)
    end
    self.UIRoot.TextBlock_Btn1:SetText(self.sTextFollow)
    self.UIRoot.FollowSwitcher:SetActiveWidgetIndex(1)
    self.UIRoot.TextBlock_Btn2:SetText(self.sTextFollow)
    self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(1)
    self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.bIsTransferLeader = false
  end
end
function IngameFollowItemUI:SimInvite()
  local InviteSwitcherIndex = self.UIRoot.InviteSwitcher:GetActiveWidgetIndex()
  local uGameFunctionLibrary = import("/Game/BluePrints/Core/BP_GameFunctionLibrary.BP_GameFunctionLibrary_C")
  local bCanSeeWidget = uGameFunctionLibrary.IsPlayerCanSeeWidget(self.UIRoot.HorizontalBox_Follow)
  if InviteSwitcherIndex == 0 and bCanSeeWidget then
    self:Button_InviteTeammate_Handle()
  end
end
function IngameFollowItemUI:Button_FollowTeammate_Handle()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    if self.bIsTransferLeader then
      ClientTLogUtil.ReportGeneralCountByParachutePhase(12021, 12021)
      uPawn:InviteTeammate(self.sTeammateName, uEParachuteInvitationType.EInviteTransferLeader)
      uPawn.IsDuringTransferLeader = true
      self:AddGameTimer(TeamPanelConfig.InviteCD, false, function()
        local uCharacter = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
        if slua.isValid(uCharacter) then
          uCharacter.IsDuringTransferLeader = false
          self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      end)
      self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.FollowSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      uPawn:FollowTeammate(self.sTeammateName)
    end
  end
end
function IngameFollowItemUI:Button_InviteTeammate_Handle()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    local sPlayerName = uPawn:GetPlayerNameSafety()
    if self.sTeammateName ~= "" and self.sTeammateName ~= sPlayerName then
      uPawn:InviteTeammate(self.sTeammateName, uEParachuteInvitationType.EInviteFollow)
      self:AddGameTimer(TeamPanelConfig.InviteCD, false, function()
        self.UIRoot.loading:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end)
      self.UIRoot.loading:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function IngameFollowItemUI:Button_UnableFollowTeammate_Handle()
  if self.LocalPlayerFollowState and self.nLocalPlayerTeamIndex == self.LocalPlayerFollowState.LeaderIdx then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(30101)
    end
  end
end
function IngameFollowItemUI:Button_UnableInviteTeammate_Handle()
  if self.LocalPlayerFollowState and self.nInPlayerTeamIndex == self.LocalPlayerFollowState.LeaderIdx then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(30100)
    end
  end
end
function IngameFollowItemUI:Button_CancelFollow_Handle()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    ClientTLogUtil.ReportGeneralCountByParachutePhase(12019, 12020)
    uPawn:CancelFollow()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, IngameFollowItemUI)