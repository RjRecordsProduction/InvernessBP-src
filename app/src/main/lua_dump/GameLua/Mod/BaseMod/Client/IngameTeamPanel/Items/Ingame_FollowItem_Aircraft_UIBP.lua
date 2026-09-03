local Ingame_FollowItem_Aircraft_UIBP = {}
local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local uSTExtraUIUtils = import("STExtraUIUtils")
local uEFollowState = import("EFollowState")
local uEParachuteInvitationType = import("EParachuteInvitationType")
function Ingame_FollowItem_Aircraft_UIBP:ctor(_, nIndex, TeamMatePlayerState)
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
  self.InviteTimer = nil
  self.ApplyTimer = nil
  self.bRegistResponseControl = false
end
function Ingame_FollowItem_Aircraft_UIBP:OnInitialize()
  Ingame_FollowItem_Aircraft_UIBP.__super.OnInitialize(self)
end
function Ingame_FollowItem_Aircraft_UIBP:RegistEvents()
  Ingame_FollowItem_Aircraft_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_InviteFly, self.OnClickButton_InviteFly, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ApplyFlyTogether, self.OnClickButton_ApplyFlyTogether, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UnableInviteFly, self.OnClickButton_UnableInviteFly, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UnableApplyFlyTogether, self.OnClickButton_UnableApplyFlyTogether, self)
  self:AddOnClickedEventByControl(self.UIRoot.CancelFollowBtn, self.OnClickCancelFollowBtn, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CancelApply, self.OnClickButton_CancelFollow, self)
end
function Ingame_FollowItem_Aircraft_UIBP:RegistResponseControl()
  if self.bRegistResponseControl then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    self:AddControlEventByControl(uPlayerController, "OnParachuteFollowInviteResponse", self.OnParachuteFollowInviteResponse, self)
    self.bRegistResponseControl = true
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnPostInitialize()
  Ingame_FollowItem_Aircraft_UIBP.__super.OnPostInitialize(self)
end
function Ingame_FollowItem_Aircraft_UIBP:Close()
  self.uPlayerState = nil
  Ingame_FollowItem_Aircraft_UIBP.__super.Close(self)
end
function Ingame_FollowItem_Aircraft_UIBP:RefreshState(nInTeamIdx, nPlayerInTeamIdx, PFS, PlayerPFS, eLiveState, PFSList)
  if nInTeamIdx == nPlayerInTeamIdx then
    self.UIRoot.HorizontalBox_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ApplySwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.HorizontalBox_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if PlayerPFS.EquipTwoPersonAircraftID > 0 then
    self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Btn1:SetText(LocUtil.GetLocalizeResStr(792637))
    self.UIRoot.TextBlock_Btn2:SetText(LocUtil.GetLocalizeResStr(792637))
    if PFS.AircraftLeaderIdx == nPlayerInTeamIdx then
      self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(2)
    elseif self:IsInAircraftTogetherFlyState(nPlayerInTeamIdx, PFSList) or self:IsInAircraftTogetherFlyState(nInTeamIdx, PFSList) then
      self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(1)
    else
      self.UIRoot.InviteSwitcher:SetActiveWidgetIndex(0)
    end
  else
    self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if PFS.EquipTwoPersonAircraftID > 0 then
    self.UIRoot.ApplySwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_ApplyFlyEnable:SetText(LocUtil.GetLocalizeResStr(792638))
    self.UIRoot.TextBlock_ApplyFlyUnable:SetText(LocUtil.GetLocalizeResStr(792638))
    if PlayerPFS.AircraftLeaderIdx == nInTeamIdx then
      self.UIRoot.ApplySwitcher:SetActiveWidgetIndex(2)
    elseif self:IsInAircraftTogetherFlyState(nPlayerInTeamIdx, PFSList) or self:IsInAircraftTogetherFlyState(nInTeamIdx, PFSList) then
      self.UIRoot.ApplySwitcher:SetActiveWidgetIndex(1)
    else
      self.UIRoot.ApplySwitcher:SetActiveWidgetIndex(0)
    end
  else
    self.UIRoot.ApplySwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Ingame_FollowItem_Aircraft_UIBP:CanFlyTogether(PFS, PlayerPFS)
  local TargetFollowState = PFS.FollowState
  local MyFollowState = PlayerPFS.FollowState
  if TargetFollowState == uEFollowState.None and MyFollowState == uEFollowState.None then
    return true
  end
  if TargetFollowState == uEFollowState.Leader or MyFollowState == uEFollowState.Leader then
    return true
  end
  return false
end
function Ingame_FollowItem_Aircraft_UIBP:IsAircraftTeamFull(Idx, PFSList)
  for key, PFS in pairs(PFSList) do
    if Idx ~= key and PFS.AircraftLeaderIdx == Idx then
      return true
    end
  end
  return false
end
function Ingame_FollowItem_Aircraft_UIBP:IsInAircraftTogetherFlyState(Idx, PFSList)
  for key, PFS in pairs(PFSList) do
    if Idx == key then
      if PFS.AircraftLeaderIdx > -1 then
        return true
      end
    elseif PFS.AircraftLeaderIdx == Idx then
      return true
    end
  end
  return false
end
function Ingame_FollowItem_Aircraft_UIBP:OnClickButton_InviteFly()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    local sPlayerName = uPawn:GetPlayerNameSafety()
    if self.sTeammateName ~= "" and self.sTeammateName ~= sPlayerName then
      self:RegistResponseControl()
      uPawn:InviteTeammate(self.sTeammateName, uEParachuteInvitationType.EInviteFollowAircraft)
      self.InviteTimer = self:AddGameTimer(TeamPanelConfig.InviteCD, false, function()
        self.UIRoot.loading:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end)
      self.UIRoot.loading:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnClickButton_ApplyFlyTogether()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    local sPlayerName = uPawn:GetPlayerNameSafety()
    if self.sTeammateName ~= "" and self.sTeammateName ~= sPlayerName then
      self:RegistResponseControl()
      uPawn:InviteTeammate(self.sTeammateName, uEParachuteInvitationType.EInviteApplyAircraft)
      self.ApplyTimer = self:AddGameTimer(TeamPanelConfig.InviteCD, false, function()
        self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.ApplySwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end)
      self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.ApplySwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnClickButton_UnableInviteFly()
  if self.LocalPlayerFollowState and self.nLocalPlayerTeamIndex == self.LocalPlayerFollowState.LeaderIdx then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(30101)
    end
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnClickButton_UnableApplyFlyTogether()
  if self.LocalPlayerFollowState and self.nInPlayerTeamIndex == self.LocalPlayerFollowState.LeaderIdx then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(30100)
    end
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnClickCancelFollowBtn()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    uPawn:KickOutOtherFollowAircraft(self.sTeammateName)
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnClickButton_CancelFollow()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    uPawn:CancelFollowAircraft()
  end
end
function Ingame_FollowItem_Aircraft_UIBP:OnInviteRep()
  if self.InviteTimer then
    self:RemoveGameTimer(self.InviteTimer)
    self.InviteTimer = nil
  end
  self.UIRoot.loading:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.InviteSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Ingame_FollowItem_Aircraft_UIBP:OnApplyRep()
  if self.ApplyTimer then
    self:RemoveGameTimer(self.ApplyTimer)
    self.ApplyTimer = nil
  end
  self.UIRoot.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.ApplySwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Ingame_FollowItem_Aircraft_UIBP:OnParachuteFollowInviteResponse(InvitedName, Res, InvitationType)
  print(bWriteLog and "Ingame_FollowItem_Aircraft_UIBP:OnParachuteFollowInviteResponse", InvitedName, Res, InvitationType, self.sTeammateName)
  if InvitedName ~= self.sTeammateName then
    return
  end
  if InvitationType == uEParachuteInvitationType.EInviteFollowAircraft then
    self:OnInviteRep()
  elseif InvitationType == uEParachuteInvitationType.EInviteApplyAircraft then
    self:OnApplyRep()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Ingame_FollowItem_Aircraft_UIBP)