local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ParachutingControl = {}
local EBtnShowState = {
  Follow = -1,
  CanJump = 0,
  OpenParachute = 1,
  CloseParachute = 2,
  TacticalSpread = 3,
  HiddenAll = 9999
}
local uEParachuteInvitationType = import("EParachuteInvitationType")
local uEInviteResponceType = import("EInviteResponceType")
function ParachutingControl:ctor()
  self.CacheLeaderPlayerState = nil
  self.uInvitationType = uEParachuteInvitationType.EInviteFollow
  self.CountDownTime = 0
  self.CountDownTimer = nil
  self.AerialShowCountDownTime = 0
  self.AerialShowCountDownTimer = nil
end
function ParachutingControl:OnInitialize()
  ParachutingControl.__super.OnInitialize(self)
end
function ParachutingControl:RegistEvents()
  ParachutingControl.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_LeavePlane, self.StartJump, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Parachute, self.OpenParachute, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CloseParachute, self.CloseParachute, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_AerialShow, self.TriggerAerialShow, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OutOfFollow, self.OutOfFollow, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Refuse, self.RefuseFollwInvite, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Agree, self.AgreeFollwInvite, self)
  if self.UIRoot.Button_TacticalSpread then
    self:AddOnClickedEventByControl(self.UIRoot.Button_TacticalSpread, self.OnClickTacticalSpread, self)
  end
  self:AddOnAnimationFinishedEvent("Out", self.HideInviteTips, self)
  self:AddOnPressedEventByControl(self.UIRoot.Button_WingUp, self.PressWingUp, self)
  self:AddOnReleasedEventByControl(self.UIRoot.Button_WingUp, self.ReleaseWingUp, self)
  self:ReceivedInitWidget()
  self:OnSpectatorChanged()
  local ParachutingUISubSystem = SubsystemMgr:Get("ParachutingUISubSystem")
  if ParachutingUISubSystem then
    local SPData = ParachutingUISubSystem:GetSuperData()
    self:AddDataListener(SPData, "IsShowEntireMap", function(_, NewValue)
      self:HandleEntireShowEvt(_, _, NewValue)
    end)
    self:AddDataListener(SPData, "BackpackVisibilityShowState", function(_, NewValue)
      self:OnBackpackVisibilityChanged(NewValue)
    end)
  end
  if Client then
    GameplayData.AddPlayerCharacterEvent(self, nil, "OnFakeOnVehicleDelegate", self.CheckAndShowAerialShowButton, self)
  end
end
function ParachutingControl:OnPostInitialize()
  ParachutingControl.__super.OnPostInitialize(self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  local NewParachutingPanel2UI = self:CreateChildWindow("CanvasPanel_ParachutingMsg", UIManager.UI_Config_InGame.NewParachutingPanel2UI)
  if not NewParachutingPanel2UI then
    print(bWriteLog and "ParachutingControl.NewParachutingPanel2UI:Initerror")
    return
  end
end
function ParachutingControl:OnSpectatorChanged()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local bIsSpectator = PlayerController:IsSpectator()
    if bIsSpectator then
      self.UIRoot:Hide()
    else
      self.UIRoot:Show()
    end
  end
end
function ParachutingControl:OnClose()
  self:StopCountDown()
  self:ClearAerialShow()
  self:HideInviteTips()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  ParachutingControl.__super.OnClose(self)
end
function ParachutingControl:StartJump()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:JumpFromPlane()
  else
    print(bWriteLog and "ParachutingControl:StartJump PlayerController is nil")
  end
end
function ParachutingControl:OpenParachute()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:OpenParachute()
  else
    print(bWriteLog and "ParachutingControl:OpenParachute PlayerController is nil")
  end
end
function ParachutingControl:CloseParachute()
  local uPlayerController = GameplayData.GetPlayerController()
  local EStateType = import("EStateType")
  if slua.isValid(uPlayerController) and uPlayerController:GetCurrentStateType() == EStateType.State_ParachuteOpen then
    uPlayerController:ServerCloseParachute()
  else
    print(bWriteLog and "ParachutingControl:CloseParachute PlayerController is nil or not in ParachuteOpen state")
  end
end
function ParachutingControl:ClearAerialShow()
  self:HideAerialShowButton()
  self:StopAerialShowCountDownTimer()
end
function ParachutingControl:TriggerAerialShow()
  local uPlayerController = GameplayData.GetPlayerController()
  if self.AerialShowCountDownTime > 0.1 then
    return
  end
  if not self:PlayerCanAerialShow() then
    return
  end
  if slua.isValid(uPlayerController) then
    uPlayerController:PlayFreeFallAerialShow()
    self:StartAerialShowCountDownTimer()
  else
    print(bWriteLog and "ParachutingControl:TriggerAerialShow PlayerController is nil")
  end
end
function ParachutingControl:StartAerialShowCountDownTimer()
  self:StopAerialShowCountDownTimer()
  self.AerialShowCountDownTime = 5
  self.AerialShowCountDownTimer = self:AddGameTimer(1, true, function()
    self.AerialShowCountDownTime = self.AerialShowCountDownTime - 1
    if self.AerialShowCountDownTime <= 0 then
      self:StopAerialShowCountDownTimer()
      self.UIRoot.CanvasPanel_AerialShowMask:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    else
      local sText = LocUtil.LocalizeResFormat("10003", tostring(self.AerialShowCountDownTime))
      self.UIRoot.Text_AerialShowCountDown:SetText(sText)
    end
  end)
  self.UIRoot.CanvasPanel_AerialShowMask:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  local sText = LocUtil.LocalizeResFormat("10003", tostring(self.AerialShowCountDownTime))
  self.UIRoot.Text_AerialShowCountDown:SetText(sText)
end
function ParachutingControl:StopAerialShowCountDownTimer()
  if self.AerialShowCountDownTimer then
    self:RemoveGameTimer(self.AerialShowCountDownTimer)
    self.AerialShowCountDownTimer = nil
    self.AerialShowCountDownTime = 0
  end
end
function ParachutingControl:ShowInviteTips()
  self.UIRoot.GridPanel_InviteTipsUI:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function ParachutingControl:HideInviteTips()
  self.UIRoot.GridPanel_InviteTipsUI:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function ParachutingControl:PressWingUp()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter:ReqSetIsWingUpControl(true)
  else
    print(bWriteLog and "ParachutingControl:PressWingUp PlayerCharacter is nil")
  end
end
function ParachutingControl:ReleaseWingUp()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      uPlayerCharacter:ReqSetIsWingUpControl(false)
    end
  else
    print(bWriteLog and "ParachutingControl:ReleaseWingUp PlayerController is nil")
  end
end
function ParachutingControl:OutOfFollow()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      print(bWriteLog and "ParachutingControl:OutOfFollow Clicked")
      uPlayerCharacter:CancelFollow()
      self:ShowBtnByPlayerControllerState()
      local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
      ClientTLogUtil.ReportGeneralCountByParachutePhase(12019, 12020)
    end
  else
    print(bWriteLog and "ParachutingControl:OutOfFollow PlayerController is nil")
  end
end
function ParachutingControl:RefuseFollwInvite()
  self:ResponseFollowInvite(uEInviteResponceType.ERefuse)
end
function ParachutingControl:AgreeFollwInvite()
  self:ResponseFollowInvite(uEInviteResponceType.EAgree)
end
function ParachutingControl:ReceivedInitWidget()
  print(bWriteLog and "ParachutingControl:ReceivedInitWidget")
end
function ParachutingControl:OnBackPackCLose()
  self:OnBackpackVisibilityChanged(false)
end
function ParachutingControl:HandleEntireShowEvt(_, __, IsShowEntireMap)
  if IsShowEntireMap then
    self:ParachutingHeightBarMoveLeft()
  else
    self:ParachutingHeightBarMoveBack()
  end
end
function ParachutingControl:PlayerInPlane()
  self:ParachutingHideBtn()
  self:SetParachutingHeightBarVisibility(false)
  EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_ENTER_PLANE)
  self:OnBackpackVisibilityChanged(false)
end
function ParachutingControl:PlayerCanJump()
  self:ShowJumpButton(true)
end
function ParachutingControl:PlayerHasAerialShow()
  local uPlayerController = GameplayData.GetPlayerController()
  local uPlayerState = GameplayData.GetPlayerState()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not (slua.isValid(uPlayerState) and slua.isValid(uPlayerCharacter)) or not slua.isValid(uPlayerController) then
    return false
  end
  if uPlayerController:IsInParachuteOpen() then
    print(bWriteLog and "ParachutingControl:PlayerHasAerialShow Parachute opened")
    return false
  end
  if uPlayerCharacter.IsFakeOnVehicle then
    return false
  end
  local ComponentClass = import("CharacterAvatarComponent2")
  local CharacterAvatarComponent = uPlayerCharacter:GetComponentByClass(ComponentClass)
  if not slua.isValid(CharacterAvatarComponent) then
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local ItemDefineID = CharacterAvatarComponent:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  local GlideID = ItemDefineID.TypeSpecificID
  if not GlideID then
    print(bWriteLog and "ParachutingControl:PlayerHasAerialShow no GlideID")
    return false
  end
  log(bWriteLog and "ParachutingControl:PlayerHasAerialShow GlideID = " .. tostring(GlideID))
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  if not AvatarUtil.IsItemHasFeature(GlideID, ENUM_FeatureType.AerialShow) then
    return false
  end
  return true
end
function ParachutingControl:PlayerCanAerialShow()
  local uPlayerController = GameplayData.GetPlayerController()
  local uPlayerState = GameplayData.GetPlayerState()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not (slua.isValid(uPlayerState) and slua.isValid(uPlayerCharacter)) or not slua.isValid(uPlayerController) then
    return false
  end
  if uPlayerController:IsInParachuteOpen() then
    print(bWriteLog and "ParachutingControl:PlayerCanAerialShow Parachute opened")
    return false
  end
  if uPlayerCharacter.IsFakeOnVehicle then
    return false
  end
  local ComponentClass = import("CharacterAvatarComponent2")
  local CharacterAvatarComponent = uPlayerCharacter:GetComponentByClass(ComponentClass)
  local EAvatarSlotType = import("EAvatarSlotType")
  local MeshComp = CharacterAvatarComponent:GetMeshCompBySlot(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  if MeshComp and MeshComp.GetAnimInstance and MeshComp:GetAnimInstance() then
    local AnimInst = MeshComp:GetAnimInstance()
    if not slua.isValid(AnimInst) then
      return false
    end
    if AnimInst:GetCurAnimStateName() ~= "Jumping" then
      return false
    end
  end
  return true
end
function ParachutingControl:PlayerOutPlane()
  self:ShowJumpButton(false)
  self:ChangeParachutingHeightBarVisibility()
  self:CheckAndShowAerialShowButton()
  EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_LEAVE_PLANE)
end
function ParachutingControl:PlayerCanOpenParachute()
  self:ShowOpenParachuteBtn()
end
function ParachutingControl:PlayerCanCloseParachute()
  print(bWriteLog and "ParachutingControl:PlayerCanCloseParachute")
  self:ShowCloseParachuteBtn()
end
function ParachutingControl:PlayerEnterParachute()
  self:ParachutingHideBtn()
  self.UIRoot.Button_WingUp:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self:ChangeParachutingHeightBarVisibility()
  EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_ENTER_PARACHUTE)
  self:HideAerialShowButton()
end
function ParachutingControl:PlayerEnterFighting()
  self:SetParachutingHeightBarVisibility(false)
end
function ParachutingControl:ShowOpenParachuteBtn()
  local bIsFollowOther = self:CheckParachuteFollowState()
  if bIsFollowOther then
    self:ShowBtnByState(EBtnShowState.Follow)
  else
    self:ShowBtnByState(EBtnShowState.OpenParachute)
  end
end
function ParachutingControl:ShowCloseParachuteBtn()
  self:ShowBtnByState(EBtnShowState.CloseParachute)
end
function ParachutingControl:HideOpenParachuteBtn()
  self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.UIRoot.ParachutingBtnPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function ParachutingControl:ParachutingHideBtn()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController.bCanJump then
    local bIsFollowOther = self:CheckParachuteFollowState()
    if bIsFollowOther then
      self:ShowBtnByState(EBtnShowState.Follow)
    else
      self:ShowBtnByState(EBtnShowState.HiddenAll)
    end
  end
end
function ParachutingControl:ShowJumpButton(bShowState)
  local nBtnShowState = EBtnShowState.HiddenAll
  if bShowState then
    self.UIRoot.ParachutingBtnPanel:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    nBtnShowState = EBtnShowState.CanJump
  else
    self.UIRoot.ParachutingBtnPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  local bIsFollowOther = self:CheckParachuteFollowState()
  if bIsFollowOther then
    nBtnShowState = EBtnShowState.Follow
  end
  self:ShowBtnByState(nBtnShowState)
end
function ParachutingControl:ShowCanOpenTips(bIsShow, sGuidText)
  if not bIsShow then
    self.UIRoot.ParachutingTips:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.UIRoot.ParachutingTips:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TipsText:SetText(sGuidText.text1)
  end
end
function ParachutingControl:CheckAndShowAerialShowButton()
  if self:PlayerHasAerialShow() then
    self:StartAerialShowCountDownTimer()
    self:ShowAerialShowButton()
  else
    self:HideAerialShowButton()
  end
end
function ParachutingControl:ShowAerialShowButton()
  print(bWriteLog and "ParachutingControl:ShowAerialShowButton")
  self.UIRoot.Border_AerialShow:SetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function ParachutingControl:HideAerialShowButton()
  print(bWriteLog and "ParachutingControl:HideAerialShowButton")
  self.UIRoot.Border_AerialShow:SetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function ParachutingControl:ShowBtnByState(BtnShowState)
  print(bWriteLog and "ParachutingControl:ShowBtnByState BtnShowState 0", BtnShowState)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if uPlayerController:IsObserver() or uPlayerController:IsDemoPlayGlobalObserver() then
    BtnShowState = EBtnShowState.HiddenAll
  end
  print(bWriteLog and "ParachutingControl:ShowBtnByState BtnShowState 1", BtnShowState)
  if not uPlayerController:IsInPlane() and not uPlayerController:IsInParachute() then
    BtnShowState = EBtnShowState.HiddenAll
  end
  print(bWriteLog and "ParachutingControl:ShowBtnByState BtnShowState 2", BtnShowState)
  if BtnShowState == EBtnShowState.Follow then
    self.UIRoot.GridPanel_ParachuteFollow:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Button_LeavePlane:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Cut:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_CloseParachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if self.UIRoot.Button_TacticalSpread then
      self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    self:HideAerialShowButton()
    EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_SHOW_FOLLOW_PARACHUTE_BTN)
  elseif BtnShowState == EBtnShowState.CanJump then
    self.UIRoot.Button_LeavePlane:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
    self.UIRoot.GridPanel_ParachuteFollow:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Cut:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_CloseParachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if self.UIRoot.Button_TacticalSpread then
      self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    self:HideAerialShowButton()
    EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_SHOW_JUMP_OUT_PLANE_BTN)
  elseif BtnShowState == EBtnShowState.OpenParachute then
    self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
    self.UIRoot.GridPanel_ParachuteFollow:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_LeavePlane:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Cut:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_CloseParachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if self.UIRoot.Button_TacticalSpread then
      self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  elseif BtnShowState == EBtnShowState.CloseParachute then
    local uPlayerController = GameplayData.GetPlayerController()
    local EStateType = import("EStateType")
    if slua.isValid(uPlayerController) and uPlayerController:GetCurrentStateType() == EStateType.State_ParachuteOpen then
      self.UIRoot.Button_CloseParachute:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
      self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_LeavePlane:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_Cut:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      if self.UIRoot.Button_TacticalSpread then
        self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
        self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      end
    end
  elseif BtnShowState == EBtnShowState.TacticalSpread then
    self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_LeavePlane:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Cut:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_CloseParachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self:HideAerialShowButton()
    if self.UIRoot.Button_TacticalSpread then
      self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
      self:UpdateTacticalSpreadTeamInfo()
      EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_SHOW_TACTICAL_SPREAD_BTN)
    end
  elseif BtnShowState == EBtnShowState.HiddenAll then
    self.UIRoot.Button_CloseParachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.GridPanel_ParachuteFollow:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_LeavePlane:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Parachute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_Cut:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self:HideAerialShowButton()
    if self.UIRoot.Button_TacticalSpread then
      self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
end
function ParachutingControl:CheckParachuteFollowState()
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPawn) then
    return false
  end
  local nPlayerIndex = uPawn:GetPlayerTeamIndex()
  local nTeammateNum = uPawn.TeammateParachuteFollowState:Num()
  if nPlayerIndex < 0 or nPlayerIndex >= nTeammateNum then
    print(bWriteLog and "ParachutingControl:OnParachutingLeaderChange nPlayerIndex is out of range")
    return
  end
  local uFollowState = uPawn.TeammateParachuteFollowState:Get(nPlayerIndex).FollowState
  local EFollowState = import("EFollowState")
  return uFollowState == EFollowState.Follower
end
function ParachutingControl:ChangeParachutingHeightBarVisibility()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if uPlayerController:IsObserver() or uPlayerController:IsDemoPlayGlobalObserver() or uPlayerController:IsFriendObserver() or uPlayerController:IsInSpectating() then
    self.UIRoot.CanvasPanel_ParachutingMsg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self:SetParachutingHeightBarVisibility(false)
  else
    self.UIRoot.CanvasPanel_ParachutingMsg:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self:SetParachutingHeightBarVisibility(true)
  end
end
function ParachutingControl:SetParachutingHeightBarVisibility(bShowState)
  if bShowState then
    self.UIRoot.CanvasPanel_ParachutingMsg:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    print(bWriteLog and "ParachutingControl::HideParachutingHeightBar")
  else
    self.UIRoot.CanvasPanel_ParachutingMsg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    print(bWriteLog and "ParachutingControl::ShowParachutingHeightBarSelfHitTestInvisible")
  end
end
function ParachutingControl:OnBackpackVisibilityChanged(bShowState)
  local vTanslation = FVector2D(0, 0)
  if bShowState then
    vTanslation.X = -500
  end
  self.UIRoot.Button_Cut:SetRenderTranslation(vTanslation)
  self.UIRoot.Button_WingUp:SetRenderTranslation(vTanslation)
  self.UIRoot.Button_Parachute:SetRenderTranslation(vTanslation)
  self.UIRoot.Button_CloseParachute:SetRenderTranslation(vTanslation)
end
function ParachutingControl:ShowBtnByPlayerControllerState()
  self.UIRoot.GridPanel_ParachuteFollow:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  print(bWriteLog and "ParachutingControl:ShowBtnByPlayerControllerState")
  if uPlayerController:IsInPlane() then
    if uPlayerController.bCanJump then
      self:ShowJumpButton(true)
    else
      self:ShowJumpButton(false)
    end
  end
  if uPlayerController:IsInParachuteJump() then
    if uPlayerController.bCanOpenParachute then
      self:ShowOpenParachuteBtn()
    else
      self:HideOpenParachuteBtn()
    end
  end
end
function ParachutingControl:ReconnectResetUIByPlayerControllerState()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if uPlayerController:IsInFight() then
    return
  end
  if uPlayerController:IsInPlane() then
    if uPlayerController.bCanJump then
      self:ShowJumpButton(true)
      local bIsFollowOther = self:CheckParachuteFollowState()
      if bIsFollowOther then
        self:OnParachutingLeaderChange()
        self.UIRoot.TextBlock_FollowPlayerName:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      end
    end
    return
  end
  if uPlayerController:IsInParachuteJump() then
    self:PlayerOutPlane()
    if uPlayerController.bCanOpenParachute then
      self:ShowOpenParachuteBtn()
    end
    local bIsFollowOther = self:CheckParachuteFollowState()
    if bIsFollowOther then
      self:OnParachutingLeaderChange()
      self.UIRoot.TextBlock_FollowPlayerName:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    end
    return
  end
  if uPlayerController:IsInParachuteOpen() then
    self:PlayerOutPlane()
    local bIsFollowOther = self:CheckParachuteFollowState()
    if bIsFollowOther then
      self:OnParachutingLeaderChange()
      self.UIRoot.TextBlock_FollowPlayerName:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      self:ShowOpenParachuteBtn()
    end
    return
  end
end
function ParachutingControl:OnParachutingLeaderChange()
  local uPlayerState = GameplayData.GetPlayerState()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerState) or not slua.isValid(uPlayerCharacter) then
    return
  end
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPawn) then
    return false
  end
  local nPlayerIndex = uPlayerCharacter:GetPlayerTeamIndex()
  print(bWriteLog and "ParachutingControl:OnParachutingLeaderChange nPlayerIndex is ", nPlayerIndex)
  local nTeammateNum = uPawn.TeammateParachuteFollowState:Num()
  if nPlayerIndex < 0 or nPlayerIndex >= nTeammateNum then
    print(bWriteLog and "ParachutingControl:OnParachutingLeaderChange nPlayerIndex is out of range")
    return
  end
  local uFollowState = uPawn.TeammateParachuteFollowState:Get(nPlayerIndex).FollowState
  local nLeaderIndex = uPawn.TeammateParachuteFollowState:Get(nPlayerIndex).LeaderIdx
  local uTeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if nLeaderIndex < 0 or nLeaderIndex >= uTeamMatePlayerStateList:Num() then
    print(bWriteLog and "ParachutingControl:OnParachutingLeaderChange LeaderIndex is not Valid")
    self.CacheLeaderPlayerStat = nil
    return
  end
  local uLeaderState = uTeamMatePlayerStateList:Get(nLeaderIndex)
  if not slua.isValid(uLeaderState) then
    return
  end
  local sLeaderName = uLeaderState.PlayerName
  if slua.isValid(self.CacheLeaderPlayerState) and sLeaderName == self.CacheLeaderPlayerState.PlayerName then
    print(bWriteLog and "ParachutingControl:OnParachutingLeaderChange LeaderName  is not change")
    return
  end
  self.UIRoot.TextBlock_FollowPlayerName:SetText(sLeaderName)
  local EFollowState = import("EFollowState")
  if uFollowState == EFollowState.Follower then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgIDAndString(30104, sLeaderName, "")
      self.CacheLeaderPlayerState = uLeaderState
    end
  end
end
function ParachutingControl:OnFollowStateChange()
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPawn) then
    return false
  end
  local bIsFollowOther = self:CheckParachuteFollowState()
  if not bIsFollowOther then
    self.CacheLeaderPlayerState = nil
  end
  self:ShowBtnByPlayerControllerState()
end
function ParachutingControl:ParachutingHeightBarMoveLeft()
  print(bWriteLog and "ParachutingControl:ParachutingHeightBarMoveLeft")
  local NewParachutingPanel2UI = UIManager.GetUI(UIManager.UI_Config_InGame.NewParachutingPanel2UI)
  if NewParachutingPanel2UI and NewParachutingPanel2UI.ShrinkLeft then
    NewParachutingPanel2UI:ShrinkLeft()
  end
end
function ParachutingControl:ParachutingHeightBarMoveBack()
  print(bWriteLog and "ParachutingControl:ParachutingHeightBarMoveBack")
  local NewParachutingPanel2UI = UIManager.GetUI(UIManager.UI_Config_InGame.NewParachutingPanel2UI)
  if NewParachutingPanel2UI and NewParachutingPanel2UI.ShrinkBack then
    NewParachutingPanel2UI:ShrinkBack()
  end
end
function ParachutingControl:ShowAllUIForDelayResult()
  self:SetParachutingHeightBarVisibility(false)
  print(bWriteLog and "ParachutingControl:ShowAllUIForDelayResult")
end
function ParachutingControl:OnReceiveParachuteFollowRequst()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  self:ShowInvitePanel(30180, 34196)
  self.uInvitationType = uEParachuteInvitationType.EInviteFollow
  local uLeader = uPlayerCharacter.Leader
  if slua.isValid(uLeader) then
    self.UIRoot.Text_Refuse_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Text_Agree_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.UIRoot.Text_Refuse_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Text_Agree_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
end
function ParachutingControl:OnReceiveTransferLeaderRequest()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  self:ShowInvitePanel(30179, 37172)
  self.uInvitationType = uEParachuteInvitationType.EInviteTransferLeader
  self.UIRoot.Text_Refuse_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Text_Agree_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function ParachutingControl:OnReceiveParachuteAirCraftFollowRequst()
  print(bWriteLog and "[AircraftFollow] ParachutingControl:OnReceiveParachuteAirCraftFollowRequst")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    log_error("[AircraftFollow] ParachutingControl:OnReceiveParachuteAirCraftFollowRequst not slua.isValid(uPlayerCharacter)")
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not uPlayerState then
    log_error("[AircraftFollow] ParachutingControl:OnReceiveParachuteAirCraftFollowRequst not slua.isValid(uPlayerCharacter)")
    return
  end
  local InviterName = uPlayerCharacter:GetLatestInviter()
  local State = uPlayerCharacter.TeammateParachuteFollowState:Get(uPlayerState:GetTeamMateIndexByName(InviterName))
  local Name = self:GetItemName(State.EquipTwoPersonAircraftID)
  local sFollowInviteTips = LocUtil.LocalizeResFormat(tostring(792641), Name)
  local sRefuseInviteTips = LocUtil.GetLocalizeResStr(tostring(37172))
  self:ShowInvitePanelByText(sFollowInviteTips, sRefuseInviteTips)
  self.uInvitationType = uEParachuteInvitationType.EInviteFollowAircraft
  self.UIRoot.Text_Refuse_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.UIRoot.Text_Agree_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function ParachutingControl:OnReceiveParachuteAircraftApplyRequst()
  print(bWriteLog and "[AircraftFollow] ParachutingControl:OnReceiveParachuteAircraftApplyRequst")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    log_error("[AircraftFollow] ParachutingControl:OnReceiveParachuteAircraftApplyRequst not slua.isValid(uPlayerCharacter)")
    return
  end
  local State = uPlayerCharacter.TeammateParachuteFollowState:Get(uPlayerCharacter:GetPlayerTeamIndex())
  local Name = self:GetItemName(State.EquipTwoPersonAircraftID)
  local sFollowInviteTips = LocUtil.LocalizeResFormat(tostring(792642), Name)
  local sRefuseInviteTips = LocUtil.GetLocalizeResStr(tostring(37172))
  self:ShowInvitePanelByText(sFollowInviteTips, sRefuseInviteTips)
  self.uInvitationType = uEParachuteInvitationType.EInviteApplyAircraft
  self.UIRoot.Text_Refuse_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Text_Agree_TimeLeft:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function ParachutingControl:ShowInvitePanel(nTipsTextID, nRtipsTextID)
  local sFollowInviteTips = LocUtil.GetLocalizeResStr(tostring(nTipsTextID))
  local sRefuseInviteTips = LocUtil.GetLocalizeResStr(tostring(nRtipsTextID))
  self:ShowInvitePanelByText(sFollowInviteTips, sRefuseInviteTips)
end
function ParachutingControl:ShowInvitePanelByText(sFollowInviteTips, sRefuseInviteTips)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not Game:IsValid(MainControlPanelTochButton) then
    print(bWriteLog and "ParachutingControl:OnReceiveParachuteFollowRequst MainControlPanelTochButton is nil")
    return
  end
  local uParentPanel = MainControlPanelTochButton.ParachutingLayer
  if not uParentPanel then
    print(bWriteLog and "ParachutingControl:OnReceiveParachuteFollowRequst uParentPanel is nil")
    return
  end
  uParentPanel:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TextBlock_Tips:SetText(sFollowInviteTips)
  self.UIRoot.TextBlock_RTips:SetText(sRefuseInviteTips)
  self:ReconnectResetUIByPlayerControllerState()
  local uPlayerState = GameplayData.GetPlayerState()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerState) or not slua.isValid(uPlayerCharacter) then
    return
  end
  local sLatestInviter = uPlayerCharacter:GetLatestInviter()
  local uInviterState = uPlayerState:GetTeammateByName(sLatestInviter)
  if not slua.isValid(uInviterState) then
    return
  end
  local nTeamMateIndex = uPlayerState:GetTeamMateIndex(uInviterState) + 1
  self.UIRoot.TextBlock_TeamIDx:SetText(tostring(nTeamMateIndex))
  self.UIRoot.TextBlock_PlayerName:SetText(sLatestInviter)
  local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
  local BGCfg = TeamPanelConfig.TeamPlayerColorTable[nTeamMateIndex]
  self.UIRoot.Image_TeamBG:SetColorAndOpacity(BGCfg)
  self.CountDownTime = 5
  self.IsCountDown = true
  self:StartCountDown()
  self:ShowInviteTips()
  self.UIRoot:StopAnimation(self.UIRoot.Out)
  self:PlayUserWidgetAnimation(self.UIRoot.In, 0, 1, 0, 1)
end
function ParachutingControl:StartCountDown()
  if self.CountDownTime <= 0 then
    return
  end
  self:StopCountDown()
  self:ShowCountDownInfo()
  self.CountDownTimer = self:AddGameTimer(1, true, function()
    self:OnCountDown()
  end)
end
function ParachutingControl:StopCountDown()
  if self.CountDownTimer then
    self:RemoveGameTimer(self.CountDownTimer)
    self.CountDownTimer = nil
  end
end
function ParachutingControl:OnCountDown()
  self.CountDownTime = self.CountDownTime - 1
  self:ShowCountDownInfo()
  if self.CountDownTime <= 0 then
    self:ResponseFollowInvite(uEInviteResponceType.ETimeout)
  end
end
function ParachutingControl:ShowCountDownInfo()
  if self.UIRoot then
    local sText = LocUtil.LocalizeResFormat("10003", tostring(self.CountDownTime))
    self.UIRoot.Text_Refuse_TimeLeft:SetText(sText)
    self.UIRoot.Text_Agree_TimeLeft:SetText(sText)
  end
end
function ParachutingControl:ResponseFollowInvite(InviteResponceType)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local LatestInviter = PlayerCharacter:GetLatestInviter()
  if LatestInviter == "" then
    return
  end
  local bNotAllowInvitedLater = self.UIRoot.CheckBox_Tips:GetCheckedState() == UEnums.ECheckBoxState.Checked
  PlayerCharacter:ResponceInvite(LatestInviter, InviteResponceType, self.uInvitationType, bNotAllowInvitedLater)
  self:StopCountDown()
  self.UIRoot:StopAnimation(self.UIRoot.IN)
  self:PlayUserWidgetAnimation(self.UIRoot.Out, 0, 1, 0, 1)
end
function ParachutingControl:GetItemName(ItemID)
  printf("ParachutingControl:GetItemName ItemID = %s", ItemID)
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return ""
  end
  return itemCfg.ItemName or ""
end
function ParachutingControl:UpdateTacticalSpreadTeamInfo()
  print(bWriteLog and "ParachutingControl:UpdateTacticalSpreadTeamInfo")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "ParachutingControl:UpdateTacticalSpreadTeamInfo - PlayerCharacter is invalid")
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "ParachutingControl:UpdateTacticalSpreadTeamInfo - PlayerState is invalid")
    return
  end
  local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
  local TeamIdxWidgets = {
    self.UIRoot.Ingame_TeamIdx_1,
    self.UIRoot.Ingame_TeamIdx_2,
    self.UIRoot.Ingame_TeamIdx_3
  }
  for _, Widget in ipairs(TeamIdxWidgets) do
    if Widget then
      Widget:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
  local nTeammateNum = uPlayerCharacter.TeammateParachuteFollowState:Num()
  local nMyIndex = uPlayerCharacter:GetPlayerTeamIndex()
  local EFollowState = import("EFollowState")
  local nWidgetIdx = 1
  for i = 0, nTeammateNum - 1 do
    if i ~= nMyIndex then
      local FollowData = uPlayerCharacter.TeammateParachuteFollowState:Get(i)
      if FollowData and FollowData.FollowState == EFollowState.Follower and FollowData.LeaderIdx == nMyIndex then
        local Widget = TeamIdxWidgets[nWidgetIdx]
        if Widget then
          Widget:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
          local nTeamIdx = i + 1
          if Widget.TextBlock_TeamIdx then
            Widget.TextBlock_TeamIdx:SetText(tostring(nTeamIdx))
          end
          local BGColor = TeamPanelConfig.TeamPlayerColorTable[nTeamIdx]
          if BGColor and Widget.Image_IDBG then
            Widget.Image_IDBG:SetColorAndOpacity(BGColor)
          end
          print(bWriteLog and string.format("ParachutingControl:UpdateTacticalSpreadTeamInfo - Widget %d, TeamIdx %d", nWidgetIdx, nTeamIdx))
          nWidgetIdx = nWidgetIdx + 1
        end
      end
    end
  end
  print(bWriteLog and string.format("ParachutingControl:UpdateTacticalSpreadTeamInfo - Total followers displayed: %d", nWidgetIdx - 1))
end
function ParachutingControl:OnClickTacticalSpread()
  print(bWriteLog and "ParachutingControl:OnClickTacticalSpread")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "ParachutingControl:OnClickTacticalSpread - PlayerCharacter is invalid")
    return
  end
  if uPlayerCharacter.ParachuteFormation then
    uPlayerCharacter.ParachuteFormation:RequestTacticalSpread()
  end
end
function ParachutingControl:OnFormationStateChanged(nFormationState)
  print(bWriteLog and string.format("ParachutingControl:OnFormationStateChanged - State: %d", nFormationState))
  if 2 <= nFormationState then
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local EFollowState = import("EFollowState")
      local EJumpFromPlaneType = import("EJumpFromPlaneType")
      if uPlayerCharacter.FollowState == EFollowState.Leader and uPlayerCharacter.JumpFromPlaneType == EJumpFromPlaneType.Born then
        self:ShowBtnByState(EBtnShowState.TacticalSpread)
        return
      end
    end
  end
  if nFormationState == 0 then
    if self.UIRoot.Button_TacticalSpread then
      self.UIRoot.CustomPanel_Disband:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.Button_TacticalSpread:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    self:ShowBtnByPlayerControllerState()
  end
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, ParachutingControl)