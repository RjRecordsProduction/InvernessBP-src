local UKismetSystemLibrary = import("KismetSystemLibrary")
local ECarryBackState = import("ECarryBackState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local CharacterCarryBackComponent = {
  bUseTickCorrect = true,
  nDelayStopCarryTime = 15,
  nManualBreakNotAllowedCarryTime = 60,
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local MaliciousTeammateConfig = {nTimeThresholdInSeconds = 5.0, nRefreshIntervalInSeconds = 1.0}
CharacterCarryBackComponent.ServerRPC.RPC_ServerManualBreakCarryBackState = {
  Reliable = false,
  Params = {}
}
function CharacterCarryBackComponent:ctor(selfType)
  self.nCheckTimer = nil
  self.nDelayStopTimer = nil
  self.nPutDownIndex = 0
  self.nDelayForceDetachTimer = nil
  self.bDebugPutDownLocation = false
  self.ManualBreakTimerRecord = {}
end
function CharacterCarryBackComponent:ReceiveBeginPlay()
  CharacterCarryBackComponent.__super.ReceiveBeginPlay(self)
  self:AddGameTimer(0.1, false, function()
    local uOwnerPawn = self:GetOwner()
    if slua.isValid(uOwnerPawn) and not uOwnerPawn.bEnsure then
      uOwnerPawn:OnRep_CarryBackStateChanged()
    end
  end)
  if self:_IsAuthority() then
    self:_RegisterMaliciousCallbackInBeginPlay()
  end
  self.bIsStandAlone = false
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  self.bIsStandAlone = UKismetSystemLibrary.IsStandalone(self)
end
function CharacterCarryBackComponent:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "CharacterCarryBackComponent:ReceiveEndPlay")
  CharacterCarryBackComponent.__super.ReceiveEndPlay(self, EndPlayReason)
end
function CharacterCarryBackComponent:_PrintRoleAndName(sPrintInfo, ...)
  if not bWriteLog then
    return
  end
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  print(bWriteLog and string.format("%s:%s Role:%d, Name:%s", self.ActorComponentName, sPrintInfo, uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety()), ...)
end
function CharacterCarryBackComponent:_PrintCarryInfo(sPrintInfo)
  if bWriteLog == nil then
    return
  end
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local sCarryBackCharacterName = "None"
  if slua.isValid(self.CarryBackCharacter) then
    sCarryBackCharacterName = self.CarryBackCharacter:GetPlayerNameSafety()
  end
  local sBeCarriedBackCharacterName = "None"
  if slua.isValid(self.BeCarriedBackCharacter) then
    sBeCarriedBackCharacterName = self.BeCarriedBackCharacter:GetPlayerNameSafety()
  end
  print(bWriteLog and string.format("%s:%s %s->%s, Role:%d, Name:%s", self.ActorComponentName, sPrintInfo, sCarryBackCharacterName, sBeCarriedBackCharacterName, uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety()))
end
function CharacterCarryBackComponent:OnRep_CarryBackStateChanged()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local ECarryBackState = import("ECarryBackState")
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  local LocalNetCarryBackState = slua.IndexReference(uOwnerPawn, "NetCarryBackState"):clone()
  if slua.isValid(LocalNetCarryBackState.CarryBackCharacter) and slua.isValid(LocalNetCarryBackState.BeCarriedBackCharacter) then
    print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged CurState:%d, NetState:%d, DetachMethod:%d, %s->%s, Role:%d, Name:%s", self.ActorComponentName, self.State, LocalNetCarryBackState.State, LocalNetCarryBackState.DetachMethod, LocalNetCarryBackState.CarryBackCharacter:GetPlayerNameSafety(), LocalNetCarryBackState.BeCarriedBackCharacter:GetPlayerNameSafety(), uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety()))
  else
    print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged CurState:%d, NetState:%d, DetachMethod:%d, None->None, Role:%d, Name:%s", self.ActorComponentName, self.State, LocalNetCarryBackState.State, LocalNetCarryBackState.DetachMethod, uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety()))
  end
  if LocalNetCarryBackState.State ~= ECarryBackState.None and slua.isValid(LocalNetCarryBackState.CarryBackCharacter) and slua.isValid(LocalNetCarryBackState.BeCarriedBackCharacter) and LocalNetCarryBackState.CarryBackCharacter == uOwnerPawn then
    if LocalNetCarryBackState.State == ECarryBackState.InCarryBack then
      print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged InCarryBack", self.ActorComponentName))
      self:StartPreCarryBack(LocalNetCarryBackState.BeCarriedBackCharacter, LocalNetCarryBackState.SubState)
    elseif LocalNetCarryBackState.State == ECarryBackState.CarryBackDone then
      if self.State == ECarryBackState.InCarryBack then
        print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged CarryBackDone", self.ActorComponentName))
        self:CompleteCarryBack(LocalNetCarryBackState.SubState)
      else
        print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged InCarryBack and CarryBackDone", self.ActorComponentName))
        self:StartPreCarryBack(LocalNetCarryBackState.BeCarriedBackCharacter, LocalNetCarryBackState.SubState)
        self:CompleteCarryBack(LocalNetCarryBackState.SubState)
      end
    else
      print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged SetCarryBackState Only", self.ActorComponentName))
      self:SetCarryBackState(LocalNetCarryBackState.State, LocalNetCarryBackState.CarryBackCharacter, LocalNetCarryBackState.BeCarriedBackCharacter, true, LocalNetCarryBackState.SubState)
    end
  end
  if LocalNetCarryBackState.State == ECarryBackState.None and not slua.isValid(LocalNetCarryBackState.CarryBackCharacter) and not slua.isValid(LocalNetCarryBackState.BeCarriedBackCharacter) then
    if slua.isValid(self.CarryBackCharacter) and self.CarryBackCharacter == uOwnerPawn then
      if LocalNetCarryBackState.DetachMethod == EPutDownDetachMethod.Skill_Front or LocalNetCarryBackState.DetachMethod == EPutDownDetachMethod.Skill_Back then
        print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged CompletePutDown", self.ActorComponentName))
        self:CompletePutDown(LocalNetCarryBackState.DetachMethod == EPutDownDetachMethod.Skill_Front)
      elseif LocalNetCarryBackState.DetachMethod == EPutDownDetachMethod.CarryToVehicle then
        print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged CarryToVehicleFinished", self.ActorComponentName))
        self:CarryToVehicleFinished(LocalNetCarryBackState.DetachMethod)
      else
        print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged StopCarryBack", self.ActorComponentName))
        self:SetStopCarryBackContent(LocalNetCarryBackState.DetachObjectContent)
        self:StopCarryBack(LocalNetCarryBackState.DetachMethod)
      end
      return
    end
    if not slua.isValid(self.CarryBackCharacter) and slua.isValid(self.BeCarriedBackCharacter) then
      print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged Only BeCarriedBackCharacter StopBeCarriedBack", self.ActorComponentName))
      self:StopBeCarriedBack(LocalNetCarryBackState.DetachMethod)
    elseif slua.isValid(self.CarryBackCharacter) and not slua.isValid(self.BeCarriedBackCharacter) then
      print(bWriteLog and string.format("%s:OnRep_CarryBackStateChanged Only CarryBackCharacter StopCarryBack", self.ActorComponentName))
      self:SetStopCarryBackContent(LocalNetCarryBackState.DetachObjectContent)
      self:StopCarryBack(LocalNetCarryBackState.DetachMethod)
    end
  end
end
function CharacterCarryBackComponent:IsTeamate(uOtherCharacter)
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and slua.isValid(uOtherCharacter) and uOwnerPawn.TeamID == uOtherCharacter.TeamID then
    return true
  end
  return false
end
function CharacterCarryBackComponent:RecordManualBreakTime(uBeCarriedBackCharacter)
  if slua.isValid(uBeCarriedBackCharacter) and self:IsTeamate(uBeCarriedBackCharacter) then
    local UGameplayStatics = import("GameplayStatics")
    local nCurTime = UGameplayStatics.GetTimeSeconds(self.Object)
    if self.ManualBreakTimerRecord == nil then
      self.ManualBreakTimerRecord = {}
    end
    self.ManualBreakTimerRecord[uBeCarriedBackCharacter.PlayerKey] = nCurTime
  end
end
function CharacterCarryBackComponent:CheckCanCarryBack(uBeCarriedBackCharacter, InSubState)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  if slua.isValid(uBeCarriedBackCharacter) and self:IsTeamate(uBeCarriedBackCharacter) then
    local UGameplayStatics = import("GameplayStatics")
    local nCurTime = UGameplayStatics.GetTimeSeconds(self.Object)
    local nLastBreakTime = self.ManualBreakTimerRecord[uBeCarriedBackCharacter.PlayerKey]
    if nLastBreakTime and nCurTime - nLastBreakTime < self.nManualBreakNotAllowedCarryTime then
      local nLeftTime = math.floor(self.nManualBreakNotAllowedCarryTime - (nCurTime - nLastBreakTime))
      IngameTipsTools.BattleNormalSAPTipsByTextID(47639, nLeftTime, "", "", uOwnerPawn.PlayerKey, false)
      return false
    end
  end
  return true
end
function CharacterCarryBackComponent:CompletePutDown(bFront)
  local uOwnerPawn = self:GetOwner()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  if bFront then
    self.DetachMethod = EPutDownDetachMethod.Skill_Front
  else
    self.DetachMethod = EPutDownDetachMethod.Skill_Back
  end
  self:_PrintRoleAndName(string.format("CompletePutDown(LuaOverride) State:%d, DetachMethod:%d", self.State, self.DetachMethod))
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_COMPLETE_PUT_DOWN, uOwnerPawn, self.BeCarriedBackCharacter)
  if slua.isValid(self.BeCarriedBackCharacter) then
    local uBeCarriedBackComp = self.BeCarriedBackCharacter:GetCarryBackComp()
    if slua.isValid(uBeCarriedBackComp) then
      uBeCarriedBackComp:CompleteBePutDown(bFront)
    end
  end
  self:LocalExitCarryBackState(self.DetachMethod)
  self:ResetCarryBackState()
end
function CharacterCarryBackComponent:CompleteBePutDown(bFront)
  local uOwnerPawn = self:GetOwner()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  if bFront then
    self.DetachMethod = EPutDownDetachMethod.Skill_Front
  else
    self.DetachMethod = EPutDownDetachMethod.Skill_Back
  end
  self:_PrintRoleAndName(string.format("CompleteBePutDown(LuaOverride) State:%d, DetachMethod:%d", self.State, self.DetachMethod))
  self:LocalExitBeCarriedBackState(self.DetachMethod)
  self:ResetCarryBackState()
end
function CharacterCarryBackComponent:StopCarryBack(InDetachMethod)
  local uOwnerPawn = self:GetOwner()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self.DetachMethod = InDetachMethod
  self:_PrintRoleAndName(string.format("StopCarryBack(LuaOverride) State:%d, DetachMethod:%d", self.State, self.DetachMethod))
  if slua.isValid(self.BeCarriedBackCharacter) then
    local uBeCarriedBackComp = self.BeCarriedBackCharacter:GetCarryBackComp()
    if slua.isValid(uBeCarriedBackComp) then
      if slua.isValid(self.DetachObjectContent) then
        uBeCarriedBackComp:SetStopCarryBackContent(self.DetachObjectContent)
      end
      uBeCarriedBackComp:StopBeCarriedBack(InDetachMethod)
    end
  end
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  if self.DetachMethod == EPutDownDetachMethod.CarryToVehicle then
    self:LocalExitCarryToVehicleState(self.DetachMethod)
  else
    self:LocalExitCarryBackState(self.DetachMethod)
  end
  self:ResetCarryBackState()
end
function CharacterCarryBackComponent:StopBeCarriedBack(InDetachMethod)
  local uOwnerPawn = self:GetOwner()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self.DetachMethod = InDetachMethod
  self:_PrintRoleAndName(string.format("StopBeCarriedBack(LuaOverride) State:%d, DetachMethod:%d", self.State, self.DetachMethod))
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  if self.DetachMethod == EPutDownDetachMethod.CarryToVehicle then
    self:LocalExitBeCarriedToVehicle(self.DetachMethod)
  else
    self:LocalExitBeCarriedBackState(self.DetachMethod)
  end
  self:ResetCarryBackState()
end
function CharacterCarryBackComponent:LocalEnterCarryBackState()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintCarryInfo("LocalEnterCarryBackState")
  self:RemoveForcePutDownTimer()
  local EPawnState = import("EPawnState")
  if slua.isValid(self.CarryBackCharacter) then
    self.CarryBackCharacter:EnterState(EPawnState.CarryBack)
    self.CarryBackCharacter:RefreshMoveAttrModifier()
  end
  self:RefreshBeCarriedCharacterVisible(true)
  self:BindEnterCarryBackEvent()
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_RESCUE_BTN, uOwnerPawn)
  end
  if uOwnerPawn.Role == ENetRole.ROLE_Authority then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED, uOwnerPawn, self.BeCarriedBackCharacter, 1)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED_EX, uOwnerPawn, self.BeCarriedBackCharacter, 1, self.SubState)
end
function CharacterCarryBackComponent:LocalCompleteCarryBackState()
  self:_PrintCarryInfo("LocalCompleteCarryBackState")
  self:RemoveForcePutDownTimer()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role ~= ENetRole.ROLE_Authority then
    self:ReplaceCharacterAnimation(true)
    if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy or self.bIsStandAlone then
      EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_PUT_DOWN_BTN, uOwnerPawn, true)
    end
  end
end
function CharacterCarryBackComponent:LocalEnterCarryToVehicleState()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintCarryInfo("LocalEnterCarryBackState")
  self:RemoveForcePutDownTimer()
  local EPawnState = import("EPawnState")
  if slua.isValid(self.CarryBackCharacter) then
    self:_PrintCarryInfo("USTCharacterCarryBackComp LocalEnterCarryBackState")
    self.CarryBackCharacter:EnterState(EPawnState.CarryBack)
    self.CarryBackCharacter:RefreshMoveAttrModifier()
  end
  self:RefreshBeCarriedCharacterVisible(true)
  self:RegisterEnterCarryToVehicleEvent()
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_RESCUE_BTN, uOwnerPawn)
  end
  if uOwnerPawn.Role == ENetRole.ROLE_Authority then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED, uOwnerPawn, self.BeCarriedBackCharacter, 1)
  end
end
function CharacterCarryBackComponent:LocalExitCarryToVehicleState(DetachMethod)
  self:_PrintCarryInfo(string.format("LocalExitCarryToVehicleState DetachMethod:%d", DetachMethod))
  self:RemoveForcePutDownTimer()
  local EPawnState = import("EPawnState")
  if slua.isValid(self.CarryBackCharacter) then
    self:_PrintCarryInfo(string.format("USTCharacterCarryBackComp LocalExitCarryBackState"))
    self.CarryBackCharacter:LeaveState(EPawnState.CarryBack)
    self.CarryBackCharacter:RefreshMoveAttrModifier()
  end
  self:_PrintRoleAndName(string.format("LocalExitCarryToVehicleState(LuaOverride) UnBindCorrectAttachRelative."))
  self:UnBindCorrectAttachRelative()
  self:UnRegisterEnterCarryToVehicleEvent()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role ~= ENetRole.ROLE_Authority then
    self:ReplaceCharacterAnimation(false)
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy or slua.isValid(uPlayerController) then
      EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_PUT_DOWN_BTN, uOwnerPawn)
    end
  end
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED, uOwnerPawn, self.BeCarriedBackCharacter, 2)
  end
end
function CharacterCarryBackComponent:LocalExitCarryBackState(DetachMethod)
  self:_PrintCarryInfo(string.format("LocalExitCarryBackState DetachMethod:%d", DetachMethod))
  self:RemoveForcePutDownTimer()
  local EPawnState = import("EPawnState")
  if slua.isValid(self.CarryBackCharacter) then
    self.CarryBackCharacter:LeaveState(EPawnState.CarryBack)
    self.CarryBackCharacter:RefreshMoveAttrModifier()
  end
  self:RefreshBeCarriedCharacterVisible(false)
  self:UnBindEnterCarryBackEvent()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role ~= ENetRole.ROLE_Authority then
    self:ReplaceCharacterAnimation(false)
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy or slua.isValid(uPlayerController) then
      EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_PUT_DOWN_BTN, uOwnerPawn)
    end
  end
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED, uOwnerPawn, self.BeCarriedBackCharacter, 2)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED_EX, uOwnerPawn, self.BeCarriedBackCharacter, 2, self.SubState)
end
function CharacterCarryBackComponent:LocalEnterBeCarriedBackState()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintCarryInfo("LocalEnterBeCarriedBackState")
  local EPawnState = import("EPawnState")
  local ENetRole = import("ENetRole")
  if slua.isValid(self.BeCarriedBackCharacter) then
    self:_PrintCarryInfo("USTCharacterCarryBackComp LocalEnterBeCarriedBackState EnterState(EPawnState.BeCarriedBack)")
    self.BeCarriedBackCharacter:EnterState(EPawnState.BeCarriedBack)
    local uBeCarriedBackController = self.BeCarriedBackCharacter:GetPlayerControllerSafety()
    if slua.isValid(uBeCarriedBackController) then
      uBeCarriedBackController:SetMovable(false)
    end
    if self.BeCarriedBackCharacter.bEnsure then
      local AIController = self.BeCarriedBackCharacter:GetControllerSafety()
      if slua.isValid(AIController) and AIController.K2_ClearFocus then
        AIController:K2_ClearFocus()
        log(bWriteLog and "CharacterCarryBackComponent:LocalEnterBeCarriedBackState Clear AI Focus Action")
      end
    end
  end
  self:AttachToOtherCharacter(true)
  self:RefreshBeCarriedCharacterVisible(true)
  if slua.isValid(self.BeCarriedBackCharacter) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    self.BeCarriedBackCharacter:SwitchPoseState(UEnums.ESTEPoseState.DyingBeCarried, true, true, true, false)
  end
  local ECarryBackState = import("ECarryBackState")
  if self:IsInBeCarriedBackState() then
    local uOwnerPawn = self:GetOwner()
    if slua.isValid(uOwnerPawn) then
      if uOwnerPawn.Role == ENetRole.ROLE_Authority then
        self:ServerObserveCarryCharacter(true)
      else
        self:ClientObserveCarryCharacter(true, uOwnerPawn.Role)
      end
    end
  end
  if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(self.BeCarriedBackCharacter) and slua.isValid(self.CarryBackCharacter) and self.BeCarriedBackCharacter.TeamID == self.CarryBackCharacter.TeamID then
    UIManager.ShowUI(UIManager.UI_Config_InGame.CarryBackBreakUI)
  end
  if uOwnerPawn.Role == ENetRole.ROLE_Authority then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED, uOwnerPawn, self.CarryBackCharacter, 3)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED_EX, uOwnerPawn, self.BeCarriedBackCharacter, 3, self.SubState)
end
function CharacterCarryBackComponent:LocalCompleteBeCarriedBackState()
  self:_PrintCarryInfo("LocalCompleteBeCarriedBackState")
end
function CharacterCarryBackComponent:LocalExitBeCarriedBackState(DetachMethod)
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintCarryInfo(string.format("LocalExitBeCarriedBackState DetachMethod:%d", DetachMethod))
  local ECarryBackState = import("ECarryBackState")
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role ~= ENetRole.ROLE_Authority and DetachMethod ~= EPutDownDetachMethod.StateInterrupted_OtherDead then
    if DetachMethod == EPutDownDetachMethod.Skill_Front or DetachMethod == EPutDownDetachMethod.Skill_Back then
      uOwnerPawn:StopAnimMontageOriginal()
    else
      uOwnerPawn:StopAnimMontage()
    end
  end
  self:AttachToOtherCharacter(false)
  self:RefreshBeCarriedCharacterVisible(false)
  if self:IsInBeCarriedBackState() then
    if uOwnerPawn.Role == ENetRole.ROLE_Authority then
      self:ServerObserveCarryCharacter(false)
    else
      self:ClientObserveCarryCharacter(false, uOwnerPawn.Role)
    end
  end
  local EPawnState = import("EPawnState")
  if slua.isValid(self.BeCarriedBackCharacter) then
    self.BeCarriedBackCharacter:LeaveState(EPawnState.BeCarriedBack)
    local uBeCarriedBackController = self.BeCarriedBackCharacter:GetPlayerControllerSafety()
    if slua.isValid(uBeCarriedBackController) then
      uBeCarriedBackController:SetMovable(true)
    end
  end
  if slua.isValid(self.BeCarriedBackCharacter) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    if uOwnerPawn:IsNearDeath() then
      self.BeCarriedBackCharacter:SwitchPoseState(UEnums.ESTEPoseState.Dying, true, true, true, false)
    else
      self.BeCarriedBackCharacter:SwitchPoseState(UEnums.ESTEPoseState.Stand, true, true, true, false)
    end
  end
  if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(self.BeCarriedBackCharacter) and slua.isValid(self.CarryBackCharacter) and self.BeCarriedBackCharacter.TeamID == self.CarryBackCharacter.TeamID then
    UIManager.HideUI(UIManager.UI_Config_InGame.CarryBackBreakUI)
  end
  if uOwnerPawn.Role == ENetRole.ROLE_Authority then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED, uOwnerPawn, self.CarryBackCharacter, 4)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CARRYBACK_STATE_CHANGED_EX, uOwnerPawn, self.BeCarriedBackCharacter, 4, self.SubState)
end
function CharacterCarryBackComponent:LocalEnterPutDownState()
  self:_PrintCarryInfo("LocalEnterPutDownState")
  self.nPutDownIndex = self.nPutDownIndex + 1
  self:AddForcePutDownTimer(self.nPutDownIndex)
end
function CharacterCarryBackComponent:LocalEnterBePutDownState()
  self:_PrintCarryInfo("LocalEnterBePutDownState")
end
function CharacterCarryBackComponent:LocalCarryBackFailed()
  self:_PrintCarryInfo("LocalCarryBackFailed")
  self:RemoveForcePutDownTimer()
  local ENetRole = import("ENetRole")
  local uOwnerPawn
  if self.GetOwner then
    uOwnerPawn = self:GetOwner()
  end
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy and uOwnerPawn.RescueOtherComponent and slua.isValid(uOwnerPawn.RescueOtherComponent) then
    uOwnerPawn.RescueOtherComponent:RefreshTargetChangeNotifyHUD()
  end
end
function CharacterCarryBackComponent:LocalPutDownFailed()
  self:_PrintCarryInfo("LocalPutDownFailed")
  self:RemoveForcePutDownTimer()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and (uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy or self.bIsStandAlone) then
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_PUT_DOWN_BTN, uOwnerPawn, false)
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      self:_PrintCarryInfo("LocalPutDownFailed--SetIgnoreLookInput false")
      uPlayerController:SetIgnoreLookInput(false)
    end
  end
end
function CharacterCarryBackComponent:HandleCarrySkillEndEvent(StopReason, SkillID)
  self:_PrintCarryInfo(string.format("HandleCarrySkillEndEvent StopReason:%d, SkillID:%d", StopReason, SkillID))
  local UTSkillStopReason = import("UTSkillStopReason")
  if StopReason ~= UTSkillStopReason.SkillStopReason_Finished then
    return
  end
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and (uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy or self.bIsStandAlone) then
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_PUT_DOWN_BTN, uOwnerPawn, false)
  end
end
function CharacterCarryBackComponent:AddForcePutDownTimer(nPutDownIndex)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role == ENetRole.ROLE_Authority then
    local ForcePutDownDuration = self:GetCarryBackSkillPhaseDuration(1)
    self:_PrintRoleAndName(self.ActorComponentName .. ":AddForcePutDownTimer", uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety() .. ", ForcePutDownDuration:" .. tostring(ForcePutDownDuration))
    ForcePutDownDuration = ForcePutDownDuration + 1.0
    self.nDelayForceDetachTimer = self:AddGameTimer(ForcePutDownDuration, false, function()
      self:RemoveForcePutDownTimer()
      local uOwnerPawn = self:GetOwner()
      if not slua.isValid(uOwnerPawn) then
        return
      end
      self:_PrintRoleAndName(self.ActorComponentName .. ":AddForcePutDownTimer StopCarryBack", uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety(), self.nPutDownIndex, nPutDownIndex)
      if self.nPutDownIndex == nPutDownIndex then
        local EPutDownDetachMethod = import("EPutDownDetachMethod")
        self:StopCarryBack(EPutDownDetachMethod.Unkown)
      end
    end)
  end
end
function CharacterCarryBackComponent:RemoveForcePutDownTimer()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  if self.nDelayForceDetachTimer then
    self:_PrintRoleAndName(self.ActorComponentName .. ":RemoveForcePutDownTimer", uOwnerPawn.Role, uOwnerPawn:GetPlayerNameSafety())
    self:RemoveGameTimer(self.nDelayForceDetachTimer)
    self.nDelayForceDetachTimer = nil
  end
end
function CharacterCarryBackComponent:RegisterEnterCarryToVehicleEvent()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority and self:IsInCarryBackState() then
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      self:AddControlEvent(uPlayerController, "PlayerControllerLostDelegate", function()
        local uOwnerPawn = self:GetOwner()
        if slua.isValid(uOwnerPawn) then
          self:_PrintRoleAndName(self.ActorComponentName .. "RegisterEnterCarryToVehicleEvent PlayerControllerLostDelegate", uOwnerPawn:GetPlayerNameSafety())
        end
        self:_PrintRoleAndName("Reconnect PlayerControllerLostDelegate ... Ready to CarryToVehicleFinished==>,CurState:%d", self.State)
        local ECarryBackState = import("ECarryBackState")
        if self.State == ECarryBackState.CarryToVehicle then
          self:CarryToVehicleFinished(0)
        end
      end)
      self:AddControlEvent(uPlayerController, "PlayerControllerReconnectedDelegate", function()
        local uOwnerPawn = self:GetOwner()
        if slua.isValid(uOwnerPawn) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":PlayerControllerReconnectedDelegate", uOwnerPawn:GetPlayerNameSafety())
        end
        self:_PrintRoleAndName("Reconnect ...PlayerControllerReconnectedDelegate  Ready to CarryToVehicleFinished==>,CurState:%d", self.State)
        local ECarryBackState = import("ECarryBackState")
        if self.State == ECarryBackState.CarryToVehicle then
          self:CarryToVehicleFinished(0)
        end
      end)
    end
  end
end
function CharacterCarryBackComponent:UnRegisterEnterCarryToVehicleEvent()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority and self:IsInCarryBackState() then
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      if self:HasControlEventByControl(uPlayerController, "PlayerControllerLostDelegate") then
        self:_PrintRoleAndName("UnRegisterEnterCarryToVehicleEvent PlayerControllerLostDelegate")
        self:RemoveControlEvent(uPlayerController, "PlayerControllerLostDelegate")
      end
      if self:HasControlEventByControl(uPlayerController, "PlayerControllerReconnectedDelegate") then
        self:_PrintRoleAndName("UnRegisterEnterCarryToVehicleEvent PlayerControllerReconnectedDelegate")
        self:RemoveControlEvent(uPlayerController, "PlayerControllerReconnectedDelegate")
      end
    end
  end
end
function CharacterCarryBackComponent:BindEnterCarryBackEvent()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority and self:IsInCarryBackState() then
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      self:AddControlEvent(uPlayerController, "PlayerControllerLostDelegate", function()
        local uOwnerPawn = self:GetOwner()
        if slua.isValid(uOwnerPawn) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":PlayerControllerLostDelegate", uOwnerPawn:GetPlayerNameSafety())
        end
        self:AddDelayTimeToStopCarryBack()
      end)
      self:AddControlEvent(uPlayerController, "PlayerControllerAboutToExitDelegate", function()
        local uOwnerPawn = self:GetOwner()
        if slua.isValid(uOwnerPawn) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":PlayerControllerAboutToExitDelegate", uOwnerPawn:GetPlayerNameSafety())
        end
        self:AddDelayTimeToStopCarryBack()
      end)
      self:AddControlEvent(uPlayerController, "PlayerControllerReconnectedDelegate", function()
        local uOwnerPawn = self:GetOwner()
        if slua.isValid(uOwnerPawn) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":PlayerControllerReconnectedDelegate", uOwnerPawn:GetPlayerNameSafety())
        end
        self:RemoveDelayTimeToStopCarryBack()
      end)
      self:AddControlEvent(uPlayerController, "PlayerControllerRecoveredDelegate", function()
        local uOwnerPawn = self:GetOwner()
        if slua.isValid(uOwnerPawn) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":PlayerControllerRecoveredDelegate", uOwnerPawn:GetPlayerNameSafety())
        end
        self:RemoveDelayTimeToStopCarryBack()
      end)
    end
  end
end
function CharacterCarryBackComponent:UnBindEnterCarryBackEvent()
  local ENetRole = import("ENetRole")
  local uOwnerPawn = self:GetOwner()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority and self:IsInCarryBackState() then
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      self:RemoveDelayTimeToStopCarryBack()
      if self:HasControlEventByControl(uPlayerController, "PlayerControllerLostDelegate") then
        self:RemoveControlEvent(uPlayerController, "PlayerControllerLostDelegate")
      end
      if self:HasControlEventByControl(uPlayerController, "PlayerControllerAboutToExitDelegate") then
        self:RemoveControlEvent(uPlayerController, "PlayerControllerAboutToExitDelegate")
      end
      if self:HasControlEventByControl(uPlayerController, "PlayerControllerReconnectedDelegate") then
        self:RemoveControlEvent(uPlayerController, "PlayerControllerReconnectedDelegate")
      end
      if self:HasControlEventByControl(uPlayerController, "PlayerControllerRecoveredDelegate") then
        self:RemoveControlEvent(uPlayerController, "PlayerControllerRecoveredDelegate")
      end
    end
  end
end
function CharacterCarryBackComponent:AddDelayTimeToStopCarryBack()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintRoleAndName(self.ActorComponentName .. ":AddDelayTimeToStopCarryBack", uOwnerPawn:GetPlayerNameSafety())
  self.nDelayStopTimer = self:AddGameTimer(self.nDelayStopCarryTime, false, function()
    local uOwnerPawn = self:GetOwner()
    if slua.isValid(uOwnerPawn) then
      self:_PrintRoleAndName(self.ActorComponentName .. ":AddDelayTimeToStopCarryBack, is time to StopCarryBack", uOwnerPawn:GetPlayerNameSafety())
    end
    local EPutDownDetachMethod = import("EPutDownDetachMethod")
    self:StopCarryBack(EPutDownDetachMethod.NoConnectOutOfTime)
  end)
end
function CharacterCarryBackComponent:RemoveDelayTimeToStopCarryBack()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintRoleAndName(self.ActorComponentName .. ":RemoveDelayTimeToStopCarryBack", uOwnerPawn:GetPlayerNameSafety())
  if self.nDelayStopTimer then
    self:RemoveGameTimer(self.nDelayStopTimer)
    self.nDelayStopTimer = nil
  end
end
function CharacterCarryBackComponent:BindCorrectAttachRelative()
  if self.bUseTickCorrect then
    self:StartCorrectBeCarriedState(true, true)
    return
  end
  if self:IsInBeCarriedBackState() and slua.isValid(self.BeCarriedBackCharacter) then
    self.nCheckTimer = self:AddGameTimer(0.2, true, function()
      if not slua.isValid(self.CarryBackCharacter) or not slua.isValid(self.BeCarriedBackCharacter) then
        return
      end
      local uCarryBackCharacterComponent = self.CarryBackCharacter:GetCarryBackComp()
      if not slua.isValid(uCarryBackCharacterComponent) then
        return
      end
      if self:IsInBeCarriedBackState() then
        if not slua.isValid(self.BeCarriedBackCharacter.RootComponent.AttachParent) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":CheckAttachRelative Reset Actor Attach", self.BeCarriedBackCharacter.Role, self.State)
          self.BeCarriedBackCharacter:K2_AttachToActor(self.CarryBackCharacter, "", 2, 2, 1, false)
          self.BeCarriedBackCharacter:K2_SetActorRelativeLocation(uCarryBackCharacterComponent.CarryRelativeLocOffset, false, nil, false)
          self.BeCarriedBackCharacter:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
          return
        end
        local uRootComponentLocation = self.BeCarriedBackCharacter.RootComponent.RelativeLocation
        local LocDiff = uRootComponentLocation - uCarryBackCharacterComponent.CarryRelativeLocOffset
        if not self:IsNearlyZero(LocDiff.X, LocDiff.Y, LocDiff.Z) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":CheckAttachRelative Reset Actor RelativeLocation", self.BeCarriedBackCharacter.Role, self.State, uRootComponentLocation.X, uRootComponentLocation.Y, uRootComponentLocation.Z)
          self.BeCarriedBackCharacter:K2_SetActorRelativeLocation(self.CarryRelativeLocOffset, false, nil, false)
        end
        local uRootComponentRotation = self.BeCarriedBackCharacter.RootComponent.RelativeRotation
        if not self:IsNearlyZero(uRootComponentRotation.Pitch, uRootComponentRotation.Yaw, uRootComponentRotation.Roll) then
          self:_PrintRoleAndName(self.ActorComponentName .. ":CheckAttachRelative Reset Actor RelativeRotation", self.BeCarriedBackCharacter.Role, self.State, uRootComponentRotation.Pitch, uRootComponentRotation.Yaw, uRootComponentRotation.Roll)
          self.BeCarriedBackCharacter:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
        end
        local ECollisionChannel = import("ECollisionChannel")
        local ECollisionResponse = import("ECollisionResponse")
        if self.BeCarriedBackCharacter.CapsuleComponent:GetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn) == ECollisionResponse.ECR_Block then
          self:_PrintRoleAndName(self.ActorComponentName .. ":CheckAttachRelative Reset Actor ECC_Pawn CollisionResponse", self.BeCarriedBackCharacter.Role, self.State)
          self.BeCarriedBackCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Ignore)
        end
        if self.BeCarriedBackCharacter.CapsuleComponent:GetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle) == ECollisionResponse.ECR_Block then
          self:_PrintRoleAndName(self.ActorComponentName .. ":CheckAttachRelative Reset Actor ECC_Vehicle CollisionResponse", self.BeCarriedBackCharacter.Role, self.State)
          self.BeCarriedBackCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, ECollisionResponse.ECR_Ignore)
        end
      end
    end)
  end
end
function CharacterCarryBackComponent:UnBindCorrectAttachRelative()
  if self.bUseTickCorrect then
    self:StartCorrectBeCarriedState(false, false)
    return
  end
  if self.nCheckTimer then
    self:RemoveGameTimer(self.nCheckTimer)
    self.nCheckTimer = nil
  end
end
function CharacterCarryBackComponent:IsNearlyZero(X, Y, Z, tolerance)
  if tolerance == nil then
    tolerance = 1.0E-4
  end
  return tolerance >= math.abs(X) and tolerance >= math.abs(Y) and tolerance >= math.abs(Z)
end
function CharacterCarryBackComponent:AttachToOtherCharacter(bAttach)
  self:_PrintCarryInfo(string.format("AttachToOtherCharacter Attach:%s", tostring(bAttach)))
  local uCharacter = self.CarryBackCharacter
  local uAttachedCharacter = self.BeCarriedBackCharacter
  local ENetRole = import("ENetRole")
  local ECollisionChannel = import("ECollisionChannel")
  local ECollisionResponse = import("ECollisionResponse")
  if slua.isValid(uAttachedCharacter) then
    if slua.isValid(uAttachedCharacter.CharacterMovement) then
      if slua.isValid(uCharacter) and uCharacter.Role == ENetRole.ROLE_Authority then
        uAttachedCharacter:SetReplicateMovement(not bAttach)
      end
      if uAttachedCharacter.Mesh and slua.isValid(uAttachedCharacter.Mesh) then
        uAttachedCharacter.Mesh:SetEnableGravity(not bAttach)
        if slua.isValid(uCharacter) and uCharacter.Role == ENetRole.ROLE_AutonomousProxy then
          uAttachedCharacter.Mesh.NeedUpdateEveryFrame = bAttach
        end
      end
      if bAttach then
        uAttachedCharacter:SetIgnoreUpdateBaseInPlatform(true)
        uAttachedCharacter.CharacterMovement:StopMovementImmediately()
        uAttachedCharacter.CharacterMovement:SetMovementMode(0, 0)
        uAttachedCharacter.CharacterMovement:SetComponentTickEnabled(false)
        uAttachedCharacter.CharacterMovement:Deactivate()
        uAttachedCharacter.CharacterMovement:SetBase(nil, "", true)
      else
        uAttachedCharacter:SetIgnoreUpdateBaseInPlatform(false)
        if uAttachedCharacter.CharacterMovement.MovementMode == 0 then
          uAttachedCharacter.CharacterMovement:SetMovementMode(1, 0)
        end
        uAttachedCharacter.CharacterMovement:SetComponentTickEnabled(true)
        uAttachedCharacter.CharacterMovement:Activate(true)
      end
    end
    if uAttachedCharacter.bEnsure then
      local uAIController = uAttachedCharacter:GetController()
      if slua.isValid(uAIController) then
        if slua.isValid(uAIController.newFollowingComponent) then
          if bAttach then
            uAIController.newFollowingComponent:SetComponentTickEnabled(false)
            uAIController.newFollowingComponent:Deactivate()
          else
            uAIController.newFollowingComponent:SetComponentTickEnabled(true)
            uAIController.newFollowingComponent:Activate(true)
          end
        end
        if slua.isValid(uAIController.BehaviorComp) then
          if bAttach then
            uAIController.BehaviorComp:SetComponentTickEnabled(false)
            uAIController.BehaviorComp:Deactivate()
          else
            uAIController.BehaviorComp:SetComponentTickEnabled(true)
            uAIController.BehaviorComp:Activate(true)
          end
        end
      end
    end
    if bAttach then
      if slua.isValid(uCharacter) then
        local uCarryBackCharacterComponent = uCharacter:GetCarryBackComp()
        if slua.isValid(uCarryBackCharacterComponent) then
          self:_PrintCarryInfo(string.format("AttachToOtherCharacter DetachMethod:%d", self.DetachMethod))
          if uAttachedCharacter.CapsuleComponent and slua.isValid(uAttachedCharacter.CapsuleComponent) then
            uAttachedCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Ignore)
            uAttachedCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, ECollisionResponse.ECR_Ignore)
          end
          if uCharacter.CapsuleComponent and slua.isValid(uCharacter.CapsuleComponent) then
            uCharacter.CapsuleComponent:IgnoreActorWhenMoving(uAttachedCharacter, true)
          end
          uAttachedCharacter:K2_AttachToActor(uCharacter, "", 2, 2, 1, false)
          uAttachedCharacter:K2_SetActorRelativeLocation(uCarryBackCharacterComponent.CarryRelativeLocOffset, false, nil, false)
          uAttachedCharacter:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
          self:BindCorrectAttachRelative()
          if slua.isValid(uAttachedCharacter.RootComponent) then
            local uAttachParent = uAttachedCharacter.RootComponent:GetAttachParent()
            if slua.isValid(uAttachParent) and uAttachParent == uCharacter.RootComponent then
              self:_PrintRoleAndName(self.ActorComponentName .. ":AttachToOtherCharacter Success", uAttachParent)
            else
              self:_PrintRoleAndName(self.ActorComponentName .. ":AttachToOtherCharacter Failed", uAttachParent, uCharacter.RootComponent)
            end
          end
        end
      else
        self:_PrintCarryInfo("AttachToOtherCharacter failed1")
      end
    else
      if slua.isValid(uCharacter) and slua.isValid(uCharacter.BasedMovement) then
        local uMovementPlatform = uCharacter.BasedMovement.MovementBase
        if slua.isValid(uMovementPlatform) then
          local uMovementPlatformActor = uMovementPlatform:GetOwner()
          if slua.isValid(uMovementPlatformActor) and uMovementPlatformActor.ExternalTickPlatform then
            uMovementPlatformActor:ExternalTickPlatform()
          end
        end
      end
      if slua.isValid(uCharacter) and slua.isValid(uCharacter.CharacterMovement) then
        uCharacter.CharacterMovement:RefreshCharacterWithBase(true)
      end
      local uTempCharacter = slua.isValid(uCharacter) and uCharacter or uAttachedCharacter
      local UKismetMathLibrary = import("KismetMathLibrary")
      local uAttachedCharacterController = uAttachedCharacter:GetPlayerControllerSafety()
      local uLocation = uTempCharacter:K2_GetActorLocation()
      local uForwardVector = uTempCharacter:GetActorForwardVector()
      local uRightVector = uTempCharacter:GetActorRightVector()
      local uRotation = uTempCharacter:K2_GetActorRotation()
      self:_PrintCarryInfo(string.format("DetachFromOtherCharacter DetachMethod:%d", self.DetachMethod))
      uAttachedCharacter:K2_DetachFromActor(1, 1, 0)
      self:UnBindCorrectAttachRelative()
      if uAttachedCharacter.CapsuleComponent and slua.isValid(uAttachedCharacter.CapsuleComponent) then
        uAttachedCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Block)
        uAttachedCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, ECollisionResponse.ECR_Block)
      end
      if slua.isValid(uCharacter) and slua.isValid(uCharacter.CapsuleComponent) then
        uCharacter.CapsuleComponent:IgnoreActorWhenMoving(uAttachedCharacter, false)
      end
      local EPutDownDetachMethod = import("EPutDownDetachMethod")
      self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter Start, DetachMethod:%d, Location:%s, Rotation:%s", self.ActorComponentName, self.DetachMethod, uLocation:ToString(), uRotation:ToString()))
      if self.DetachMethod == EPutDownDetachMethod.Skill_Front then
        local uPassWallCheckLocation = uLocation + uForwardVector * 72.76 + uRightVector * 48 + FVector(0, 0, -15)
        local uNewLocation = uLocation + uForwardVector * 72.76 + uRightVector * 48 + FVector(0, 0, -29)
        local uNewRotation = UKismetMathLibrary.Conv_VectorToRotator(uRightVector)
        self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter Front, NewLocation:%s, NewRotation:%s", self.ActorComponentName, uNewLocation:ToString(), uNewRotation:ToString()))
        local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
        local ResolveParams = FResolvePenetrationParams()
        local boolCanPutDown = true
        if uCharacter and slua.isValid(uCharacter) then
          ResolveParams.bLineTracePassWall = true
          slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
          slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCharacter)
          boolCanPutDown = uCharacter.CheckBaseIsSmallMoveable and uCharacter:CheckBaseIsSmallMoveable() or uSTExtraBlueprintFunctionLibrary.IsNoOverlapAndNoPassWalPlace(uAttachedCharacter, uPassWallCheckLocation, uNewRotation, ResolveParams)
        end
        if self.bDebugPutDownLocation and uCharacter.Role == ENetRole.ROLE_AutonomousProxy then
          UKismetSystemLibrary.DrawDebugPoint(uCharacter, uNewLocation, 20, FLinearColor.Green, 10)
          UKismetSystemLibrary.DrawDebugPoint(uCharacter, uLocation, 20, FLinearColor.Red, 10)
        end
        self:SetAttachedCharacterMovementBase(uNewLocation, uCharacter, uAttachedCharacter)
        uAttachedCharacter:K2_SetActorRotation(uNewRotation, false, nil, true)
        if boolCanPutDown then
          uAttachedCharacter:K2_SetActorLocation(uNewLocation, false, nil, true)
        else
          local SafetyResolveParams = FResolvePenetrationParams()
          SafetyResolveParams.AdjustRadius = 50
          slua.IndexReference(SafetyResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
          slua.IndexReference(SafetyResolveParams, "PassWallIgnoreActors"):Add(uAttachedCharacter)
          uAttachedCharacter:SetActorLocationSafetyWithParams(uLocation, SafetyResolveParams)
          self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter Front SetActorLocationSafety:%s->%s", self.ActorComponentName, uLocation:ToString(), uAttachedCharacter:K2_GetActorLocation():ToString()))
        end
        if slua.isValid(uAttachedCharacterController) then
          uAttachedCharacterController:SetControlRotation(uNewRotation, "CharacterCarryBackComponent:DetachPawn")
        end
        self:PrintCharacterBaseMovementBase(uCharacter, uAttachedCharacter)
        self:SetAttachedCharacterMovementBase(uAttachedCharacter:K2_GetActorLocation(), uCharacter, uAttachedCharacter)
        return
      elseif self.DetachMethod == EPutDownDetachMethod.Skill_Back then
        local uPassWallCheckLocation = uLocation + uForwardVector * -58 + uRightVector * -10 + FVector(0, 0, -15)
        local uNewLocation = uLocation + uForwardVector * -58 + uRightVector * -10 + FVector(0, 0, -29)
        local uNewRotation = UKismetMathLibrary.Conv_VectorToRotator(UKismetMathLibrary.Multiply_VectorFloat(uRightVector, -1))
        self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter Back, NewLocation:%s, NewRotation:%s", self.ActorComponentName, uNewLocation:ToString(), uNewRotation:ToString()))
        local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
        local ResolveParams = FResolvePenetrationParams()
        local boolCanPutDown = true
        if uCharacter and slua.isValid(uCharacter) then
          ResolveParams.bLineTracePassWall = true
          slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
          slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCharacter)
          boolCanPutDown = uCharacter.CheckBaseIsSmallMoveable and uCharacter:CheckBaseIsSmallMoveable() or uSTExtraBlueprintFunctionLibrary.IsNoOverlapAndNoPassWalPlace(uAttachedCharacter, uPassWallCheckLocation, uNewRotation, ResolveParams)
        end
        if self.bDebugPutDownLocation and uCharacter.Role == ENetRole.ROLE_AutonomousProxy then
          UKismetSystemLibrary.DrawDebugPoint(uCharacter, uNewLocation, 20, FLinearColor.Green, 10)
          UKismetSystemLibrary.DrawDebugPoint(uCharacter, uLocation, 20, FLinearColor.Red, 10)
          UKismetSystemLibrary.DrawDebugLine(uCharacter, uAttachedCharacter:K2_GetActorLocation(), uPassWallCheckLocation, FLinearColor.Red, 10, 1)
          UKismetSystemLibrary.DrawDebugPoint(uCharacter, uAttachedCharacter:K2_GetActorLocation(), 10, FLinearColor.Red, 10)
          UKismetSystemLibrary.DrawDebugPoint(uCharacter, uPassWallCheckLocation, 10, FLinearColor.Green, 10)
        end
        self:SetAttachedCharacterMovementBase(uNewLocation, uCharacter, uAttachedCharacter)
        uAttachedCharacter:K2_SetActorRotation(uNewRotation, false, nil, true)
        if boolCanPutDown then
          uAttachedCharacter:K2_SetActorLocation(uNewLocation, false, nil, true)
        else
          local SafetyResolveParams = FResolvePenetrationParams()
          SafetyResolveParams.AdjustRadius = 50
          slua.IndexReference(SafetyResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
          slua.IndexReference(SafetyResolveParams, "PassWallIgnoreActors"):Add(uAttachedCharacter)
          uAttachedCharacter:SetActorLocationSafetyWithParams(uLocation, SafetyResolveParams)
          self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter Back SetActorLocationSafety:%s->%s", self.ActorComponentName, uLocation:ToString(), uAttachedCharacter:K2_GetActorLocation():ToString()))
        end
        if slua.isValid(uAttachedCharacterController) then
          uAttachedCharacterController:SetControlRotation(uNewRotation, "CharacterCarryBackComponent:DetachPawn")
        end
        self:PrintCharacterBaseMovementBase(uCharacter, uAttachedCharacter)
        self:SetAttachedCharacterMovementBase(uAttachedCharacter:K2_GetActorLocation(), uCharacter, uAttachedCharacter)
        return
      elseif self.DetachMethod == EPutDownDetachMethod.OtherReason then
        local Distance = 140
        local TraceRadius = 20
        local TargetDir = self:FindBestDetachDir(Distance, TraceRadius)
        local NewTargetPoint = uCharacter:K2_GetActorLocation() + TargetDir * Distance
        if TargetDir ~= FVector.ZeroVector then
          uLocation = NewTargetPoint
        end
        print(bWriteLog and "==>FindBestDetachDir Name:" .. tostring(uCharacter:GetPlayerNameSafety()) .. ",Role:" .. tostring(uCharacter.Role) .. ",uLocation:" .. tostring(uLocation:ToString()) .. ",NewTargetPoint:" .. tostring(NewTargetPoint:ToString()))
      end
      local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
      local ResolveParams = FResolvePenetrationParams()
      if uCharacter and slua.isValid(uCharacter) then
        slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
        if self.DetachMethod == EPutDownDetachMethod.StateInterrupted_SelfInVehicle then
          local Vehicle = self.DetachObjectContent
          local VehicleClass = import("STExtraVehicleBase")
          if slua.isValid(Vehicle) and Game:IsClassOf(Vehicle, VehicleClass) then
            slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(Vehicle)
          end
        end
      end
      local bSafetySetLocation = false
      local uRootCapsule = uAttachedCharacter:K2_GetRootComponent()
      if slua.isValid(uRootCapsule) and uRootCapsule.GetScaledCapsuleSize and uRootCapsule.SetCapsuleSize then
        local RootRadius, RootHeight = 0, 0
        RootRadius, RootHeight = uRootCapsule:GetScaledCapsuleSize(RootRadius, RootHeight)
        uRootCapsule:SetCapsuleSize(uAttachedCharacter.DyingBeCarriedRadius, uAttachedCharacter.CrouchHalfHeight, true)
        bSafetySetLocation = uAttachedCharacter:SetActorLocationSafetyWithParams(uLocation, ResolveParams)
        uRootCapsule:SetCapsuleSize(RootRadius, RootHeight, true)
      end
      if bSafetySetLocation then
        local uNewLocation = uAttachedCharacter:K2_GetActorLocation()
        local uDeltaVector = uNewLocation - uLocation
        local uNewRotation = UKismetMathLibrary.Conv_VectorToRotator(UKismetMathLibrary.GetRightVector(UKismetMathLibrary.Conv_VectorToRotator(uDeltaVector)))
        uAttachedCharacter:K2_SetActorRotation(uNewRotation, false, nil, true)
        self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter SetActorLocationSafety, NewLocation:%s, NewRotation:%s", self.ActorComponentName, uNewLocation:ToString(), uNewRotation:ToString()))
        if slua.isValid(uAttachedCharacterController) then
          uAttachedCharacterController:SetControlRotation(uNewRotation, "CharacterCarryBackComponent:DetachPawn")
        end
        self:PrintCharacterBaseMovementBase(uCharacter, uAttachedCharacter)
        self:SetAttachedCharacterMovementBase(uNewLocation, uCharacter, uAttachedCharacter)
      else
        self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter Failed No location set, Location:%s, Rotation:%s", self.ActorComponentName, uLocation:ToString(), uRotation:ToString()))
        self:SetAttachedCharacterMovementBase(uLocation, uCharacter, uAttachedCharacter)
        uAttachedCharacter:K2_SetActorLocation(uLocation, false, nil, true)
        uAttachedCharacter:K2_SetActorRotation(uRotation, false, nil, true)
        if slua.isValid(uAttachedCharacterController) then
          uAttachedCharacterController:SetControlRotation(uRotation, "CharacterCarryBackComponent:DetachPawn")
        end
      end
    end
  else
    self:_PrintCarryInfo("AttachToOtherCharacter failed2")
  end
end
function CharacterCarryBackComponent:PrintCharacterBaseMovementBase(uCharacter, uAttachedCharacter)
  if not bWriteLog then
    return
  end
  if slua.isValid(uCharacter) and slua.isValid(uAttachedCharacter) then
    local uMovementPlatform = uCharacter.BasedMovement.MovementBase
    if slua.isValid(uMovementPlatform) then
      local uLocation = uMovementPlatform:K2_GetComponentLocation()
      local uAttachedDeltaVector = uAttachedCharacter:K2_GetActorLocation() - uLocation
      local uDeltaVector = uCharacter:K2_GetActorLocation() - uLocation
      self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter PrintCharacterBaseMovementBase, PlatformLocation:%s, Base:%s, Actor:%s", self.ActorComponentName, uLocation:ToString(), UKismetSystemLibrary.GetObjectName(uMovementPlatform), UKismetSystemLibrary.GetObjectName(uMovementPlatform:GetOwner())))
      self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter PrintCharacterBaseMovementBase, uDeltaVector:%s, uAttachedDeltaVector:%s", self.ActorComponentName, uDeltaVector:ToString(), uAttachedDeltaVector:ToString()))
    end
  end
end
function CharacterCarryBackComponent:SetAttachedCharacterMovementBase(uNewLocation, uCharacter, uAttachedCharacter)
  local bHit, uMovementPlatform, sMovementPlatBoneformName = self:CheckPutDownLocationHasBase(uNewLocation, uCharacter, uAttachedCharacter)
  if bHit and slua.isValid(uMovementPlatform) then
    self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter SetAttachedCharacterMovementBase, SetBase:%s, Actor:%s", self.ActorComponentName, UKismetSystemLibrary.GetObjectName(uMovementPlatform), UKismetSystemLibrary.GetObjectName(uMovementPlatform:GetOwner())))
    if slua.isValid(uAttachedCharacter.CharacterMovement) then
      uAttachedCharacter.CharacterMovement:SetBase(uMovementPlatform, sMovementPlatBoneformName, true)
      uAttachedCharacter.CharacterMovement:K2_SaveBaseLocation()
    end
  elseif uAttachedCharacter:CheckBaseIsMoveable() then
    self:_PrintRoleAndName(self.ActorComponentName .. ":DetachFromOtherCharacter SetAttachedCharacterMovementBase SetBase nil")
    if slua.isValid(uAttachedCharacter.CharacterMovement) then
      uAttachedCharacter.CharacterMovement:SetBase(nil, "", true)
    end
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":DetachFromOtherCharacter SetAttachedCharacterMovementBase Donot Set Base")
  end
end
function CharacterCarryBackComponent:CheckPutDownLocationHasBase(uLocation, uCharacter, uAttachedCharacter)
  if slua.isValid(uCharacter) then
    local uMovementPlatform = uCharacter.BasedMovement.MovementBase
    if slua.isValid(uMovementPlatform) then
      local bPrintBase = uMovementPlatform:ComponentHasTag("SmallMoveablePlatform") or uMovementPlatform:ComponentHasTag("MoveablePlatform")
      if bPrintBase then
        self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter CheckPutDownLocationHasBase, Base:%s, Actor:%s", self.ActorComponentName, UKismetSystemLibrary.GetObjectName(uMovementPlatform), UKismetSystemLibrary.GetObjectName(uMovementPlatform:GetOwner())))
      end
      local bUseCarryCharacterPlatform = false
      local uMovementPlatformActor = uMovementPlatform:GetOwner()
      if slua.isValid(uMovementPlatformActor) then
        bUseCarryCharacterPlatform = not uMovementPlatformActor.IsPlatformInMoving or uMovementPlatformActor:IsPlatformInMoving()
        if bPrintBase then
          self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter CheckPutDownLocationHasBase, bUseCarryCharacterPlatform:%s", self.ActorComponentName, bUseCarryCharacterPlatform))
        end
      end
      if bUseCarryCharacterPlatform and uMovementPlatform:ComponentHasTag("SmallMoveablePlatform") then
        return true, uMovementPlatform, uCharacter.BasedMovement.BoneName
      end
    else
      self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter CheckPutDownLocationHasBase, Character not In Base", self.ActorComponentName))
    end
  end
  local uIngoreActorArray = slua.Array(UEnums.EPropertyClass.Object, import("Character"))
  if slua.isValid(uCharacter) then
    uIngoreActorArray:Add(uCharacter)
  end
  if slua.isValid(uAttachedCharacter) then
    uIngoreActorArray:Add(uAttachedCharacter)
  end
  local uHitResult = import("/Script/Engine.HitResult")()
  local bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(self.Object, uLocation, uLocation + FVector(0, 0, -100), 0, true, uIngoreActorArray, 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 10)
  if bHit then
    if slua.isValid(uHitResult.Component) and uHitResult.Component:ComponentHasTag("MoveablePlatform") then
      self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter CheckPutDownLocationHasBase, CheckLoc:%s, HitComp:%s", self.ActorComponentName, uLocation:ToString(), UKismetSystemLibrary.GetObjectName(uHitResult.Component)))
      return true, uHitResult.Component, uHitResult.BoneName
    end
  else
    self:_PrintRoleAndName(string.format("%s:DetachFromOtherCharacter CheckPutDownLocationHasBase, No Hit:%s", self.ActorComponentName, uLocation:ToString()))
  end
  return false, nil, ""
end
function CharacterCarryBackComponent:ServerObserveCarryCharacter(bEnter)
  self:_PrintRoleAndName(self.ActorComponentName .. ":ServerObserveCarryCharacter  Start", bEnter)
  if not self:IsInBeCarriedBackState() then
    self:_PrintRoleAndName(self.ActorComponentName .. ":ServerObserveCarryCharacter failed state is carryback Character")
    return
  end
  if slua.isValid(self.CarryBackCharacter) then
    local uBeCarriedBackCharacter = self:GetOwner()
    if slua.isValid(uBeCarriedBackCharacter) then
      local uBeCarridBackController = uBeCarriedBackCharacter:GetPlayerControllerSafety()
      if slua.isValid(uBeCarridBackController) then
        if bEnter then
          uBeCarridBackController:SetViewTargetTest(self.CarryBackCharacter)
          self:_PrintRoleAndName(self.ActorComponentName .. ":ServerObserveCarryCharacter enter")
        elseif uBeCarridBackController:IsSpectator() then
          uBeCarridBackController:SetViewTargetTest(uBeCarridBackController:GetCurPawn())
          self:_PrintRoleAndName(self.ActorComponentName .. ":ServerObserveCarryCharacter exit IsSpectator")
        else
          uBeCarridBackController:SetViewTargetTest(uBeCarriedBackCharacter)
          self:_PrintRoleAndName(self.ActorComponentName .. ":ServerObserveCarryCharacter exit not IsSpectator")
        end
      end
    end
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":ServerObserveCarryCharacter carrybackCharacter is null")
  end
end
function CharacterCarryBackComponent:ClientObserveCarryCharacter(bEnter, Role)
  if bEnter then
    self:_PrintRoleAndName(self.ActorComponentName .. ":==>>Enter ClientObserveCarryCharacter  Start", bEnter, Role)
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":==>>Exit ClientObserveCarryCharacter  Start", bEnter, Role)
  end
  if not self:IsInBeCarriedBackState() then
    self:_PrintRoleAndName(self.ActorComponentName .. ":ClientObserveCarryCharacter failed state is carryback Character")
    return
  end
  local uBeCarriedBackCharacter = self:GetOwner()
  if slua.isValid(uBeCarriedBackCharacter) then
    local ENetRole = import("ENetRole")
    local uCurPlayerController = uBeCarriedBackCharacter:GetPlayerControllerSafety()
    if slua.isValid(uCurPlayerController) then
      local uControllerGetCurPawn = uCurPlayerController:GetCurPawn()
      if not slua.isValid(uControllerGetCurPawn) or Game:IsClassOf(uControllerGetCurPawn, import("STExtraVehicleBase")) then
        return
      end
      if slua.isValid(uControllerGetCurPawn) and not Game:IsClassOf(uControllerGetCurPawn, import("STExtraPlayerCharacter")) then
        print(bWriteLog and "[Warning]CharacterCarryBackComponent:ClientObserveCarryCharacter failed!!")
        return
      end
      local bIsSpectator = uCurPlayerController:IsSpectator()
      if Role == ENetRole.ROLE_AutonomousProxy then
        if bEnter then
          self:_PrintRoleAndName(self.ActorComponentName .. ":Enter ClientObserveCarryCharacter  Start Is Local Character")
        else
          self:_PrintRoleAndName(self.ActorComponentName .. ":Exit ClientObserveCarryCharacter  Start Is Local Character")
        end
      elseif bIsSpectator then
        if bEnter then
          self:_PrintRoleAndName(self.ActorComponentName .. ":Enter ClientObserveCarryCharacter  Start Is Spectator")
        else
          self:_PrintRoleAndName(self.ActorComponentName .. ":Exit ClientObserveCarryCharacter  Start Is Spectator")
        end
      else
        return
      end
      if Role == ENetRole.ROLE_AutonomousProxy then
        uCurPlayerController:SetDisableTouchMoveInput(bEnter)
        uCurPlayerController:CallShowTouchInterface(not bEnter)
      end
      if slua.isValid(self.CarryBackCharacter) then
        if slua.isValid(self.CarryBackCharacter.ScreenAppearaceComp) then
          self.CarryBackCharacter.ScreenAppearaceComp:SetActive(bEnter, false)
        end
        if slua.isValid(self.CarryBackCharacter.SpringArmComp) then
          self.CarryBackCharacter.SpringArmComp:SetActive(bEnter, false)
        end
      end
      local EPlayerCameraMode = import("EPlayerCameraMode")
      if bEnter then
        if slua.isValid(self.CarryBackCharacter) then
          uCurPlayerController:ExitFreeCamera(false)
          uCurPlayerController:SetViewTargetTest(self.CarryBackCharacter)
          uCurPlayerController:SetControlRotation(self.CarryBackCharacter:GetControlRotation(), "BeCarriedBack Enter")
          local uBeCarriedBackCharacterSpringArm = uBeCarriedBackCharacter:GetActiveSpringArm()
          local uCarryBackCharacterSpringArm = self.CarryBackCharacter:GetActiveSpringArm()
          if slua.isValid(uCarryBackCharacterSpringArm) and slua.isValid(uBeCarriedBackCharacterSpringArm) then
            uBeCarriedBackCharacterSpringArm:ResetFreeCamera()
            uCarryBackCharacterSpringArm.bEnableCameraLag = uBeCarriedBackCharacterSpringArm.bEnableCameraLag
            print(bWriteLog and "CharacterCarryBackComponent:OnRep_BeCarriedBackCharacter - Sync camera lag speed from " .. tostring(uBeCarriedBackCharacterSpringArm.CameraLagSpeed) .. " to " .. tostring(uCarryBackCharacterSpringArm.CameraLagSpeed))
            uCarryBackCharacterSpringArm.CameraLagSpeed = uBeCarriedBackCharacterSpringArm.CameraLagSpeed
            uCarryBackCharacterSpringArm.bEnableCameraRotationLag = uBeCarriedBackCharacterSpringArm.bEnableCameraRotationLag
            uCarryBackCharacterSpringArm.CameraRotationLagSpeed = uBeCarriedBackCharacterSpringArm.CameraRotationLagSpeed
            uCarryBackCharacterSpringArm.TargetArmLength = uBeCarriedBackCharacterSpringArm.TargetArmLength
            uCarryBackCharacterSpringArm.SocketOffset = uBeCarriedBackCharacterSpringArm.SocketOffset
            uCarryBackCharacterSpringArm.TargetOffset = uBeCarriedBackCharacterSpringArm.TargetOffset
            uCarryBackCharacterSpringArm.bUsePawnControlRotation = uBeCarriedBackCharacterSpringArm.bUsePawnControlRotation
            uCarryBackCharacterSpringArm.bDoCollisionTest = uBeCarriedBackCharacterSpringArm.bDoCollisionTest
            uCarryBackCharacterSpringArm.ProbeSize = uBeCarriedBackCharacterSpringArm.ProbeSize
            uCarryBackCharacterSpringArm.ProbeChannel = uBeCarriedBackCharacterSpringArm.ProbeChannel
            uCarryBackCharacterSpringArm:K2_SetRelativeLocation(uBeCarriedBackCharacterSpringArm.RelativeLocation, true, nil, false)
            uCarryBackCharacterSpringArm:MarkResetCameraLag()
          end
          local uCurPawn = self.CarryBackCharacter
          if uCurPawn and slua.isValid(uCurPawn) and uCurPawn:IsAlive() and (slua.isValid(uControllerGetCurPawn) or Game:IsClassOf(uControllerGetCurPawn, import("STExtraPlayerCharacter"))) then
            local bLocalFPP = uCurPlayerController:ShouldForceFPPView(uControllerGetCurPawn)
            local CameraMode = bLocalFPP and EPlayerCameraMode.PCM_FPP or EPlayerCameraMode.PCM_Normal
            uCurPlayerController:SwitchCameraMode(CameraMode, uCurPawn, bLocalFPP, true)
            self:_PrintRoleAndName(self.ActorComponentName .. ":==>Enter ClientObserveCarryCharacter Finish CameraMode", CameraMode, bIsSpectator, bLocalFPP, uCurPawn:GetPlayerNameSafety())
          end
        end
      else
        if bIsSpectator then
          uCurPlayerController:SetViewTargetTest(uControllerGetCurPawn)
        else
          uCurPlayerController:SetViewTargetTest(uBeCarriedBackCharacter)
        end
        if bIsSpectator then
        else
          uCurPlayerController:SetControlRotation(uBeCarriedBackCharacter:GetControlRotation(), "BeCarriedBack Exit")
        end
        local uCurPawn = bIsSpectator and uControllerGetCurPawn or uBeCarriedBackCharacter
        if uCurPawn and slua.isValid(uCurPawn) then
          local bLocalFPP = uCurPlayerController:ShouldForceFPPView(uControllerGetCurPawn)
          local CameraMode = bLocalFPP and EPlayerCameraMode.PCM_FPP or EPlayerCameraMode.PCM_Normal
          if slua.isValid(self.CarryBackCharacter) and self.CarryBackCharacter:IsAlive() then
            uCurPlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_Normal, self.CarryBackCharacter, uCurPlayerController:ShouldForceFPPView(self.CarryBackCharacter), true)
          end
          if slua.isValid(uCurPawn) and uCurPawn:IsAlive() then
            uCurPlayerController:SwitchCameraMode(CameraMode, uCurPawn, bLocalFPP, true)
          end
          self:_PrintRoleAndName(self.ActorComponentName .. ":Exit ClientObserveCarryCharacter Finish CameraMode", CameraMode, bIsSpectator, bLocalFPP, uCurPawn:GetPlayerNameSafety())
          if slua.isValid(self.CarryBackCharacter) then
            self.CarryBackCharacter.IsFPP = self.CarryBackCharacter.IsNetFPP
          end
        else
          self:_PrintRoleAndName(self.ActorComponentName .. ":Exit ClientObserveCarryCharacter Finish error, CurPawn is nil")
        end
      end
      if slua.isValid(self.CarryBackCharacter) then
        local uMesh = self.CarryBackCharacter.Mesh
        if slua.isValid(uMesh) then
          if bEnter then
            if self.CarryBackCharacter.AvatarAnimClassCache then
              uMesh:SetAnimInstanceClass(self.CarryBackCharacter.AvatarAnimClassCache)
            else
              uMesh:SetAnimInstanceClass(self.CarryBackCharacter.MainCharAnimClass)
            end
            uMesh.NeedUpdateEveryFrame = true
          elseif self.CarryBackCharacter.MainCharTPPAnimClass then
            uMesh:SetAnimInstanceClass(self.CarryBackCharacter.MainCharTPPAnimClass)
            uMesh.NeedUpdateEveryFrame = false
          end
        end
      end
    end
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":ClientObserveCarryCharacter carrybackCharacter is null")
  end
end
function CharacterCarryBackComponent:OnHandleCameraModeChanged(CameraMode)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role ~= ENetRole.ROLE_AutonomousProxy and not uOwnerPawn:IsLocalViewed() then
    return
  end
  if slua.isValid(self.BeCarriedBackCharacter) then
    self:_PrintRoleAndName(self.ActorComponentName .. ":OnHandleCameraModeChanged", CameraMode, self.State, uOwnerPawn:GetPlayerNameSafety(), self.BeCarriedBackCharacter:GetPlayerNameSafety())
    self.BeCarriedBackCharacter:SetActorHiddenInGame(false)
    local EPlayerCameraMode = import("EPlayerCameraMode")
    if CameraMode == EPlayerCameraMode.PCM_FPP then
      if self:IsInCarryBackState() then
        self.BeCarriedBackCharacter:SetActorHiddenInGame(true)
      elseif self:IsInBeCarriedBackState() then
        self.BeCarriedBackCharacter:SetActorHiddenInGame(true)
      end
    end
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":OnHandleCameraModeChanged None", CameraMode, self.State)
  end
end
function CharacterCarryBackComponent:OnPerspectiveChanged(bFPP)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role ~= ENetRole.ROLE_AutonomousProxy then
    return
  end
  local uPlayerController = uOwnerPawn:GetControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  if slua.isValid(self.BeCarriedBackCharacter) and slua.isValid(self.CarryBackCharacter) and self:IsInBeCarriedBackState() then
    self:_PrintRoleAndName(self.ActorComponentName .. ":OnPerspectiveChanged", bFPP, self.State, self.BeCarriedBackCharacter:GetPlayerNameSafety())
    local EPlayerCameraMode = import("EPlayerCameraMode")
    if bFPP then
      self.CarryBackCharacter.IsFPP = true
      self.CarryBackCharacter:SetUseViewTranslatedTransform(true)
      uPlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_FPP, self.CarryBackCharacter, true, true)
    else
      self.CarryBackCharacter.IsFPP = false
      self.CarryBackCharacter:SetUseViewTranslatedTransform(false)
      uPlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_Normal, self.CarryBackCharacter, uPlayerController:ShouldForceFPPView(self.CarryBackCharacter), true)
    end
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":OnPerspectiveChanged None", bFPP, self.State)
  end
end
function CharacterCarryBackComponent:RefreshBeCarriedCharacterVisible(bEnter)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local ENetRole = import("ENetRole")
  if uOwnerPawn.Role == ENetRole.ROLE_SimulatedProxy and self:IsInBeCarriedBackState() and slua.isValid(self.BeCarriedBackCharacter) and not bEnter then
    self:_PrintRoleAndName(self.ActorComponentName .. ":RefreshBeCarriedCharacterVisible Simulated", uOwnerPawn.Role, self.State, bEnter, uOwnerPawn:GetPlayerNameSafety(), self.BeCarriedBackCharacter:GetPlayerNameSafety())
    self.BeCarriedBackCharacter:SetActorHiddenInGame(false)
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and self:HasControlEventByControl(uPlayerController, "OnHandleCameraModeChanged") then
      self:RemoveControlEvent(uPlayerController, "OnHandleCameraModeChanged")
    end
    return
  end
  if uOwnerPawn.Role ~= ENetRole.ROLE_AutonomousProxy and not uOwnerPawn:IsLocalViewed() then
    return
  end
  local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  if slua.isValid(self.BeCarriedBackCharacter) then
    self:_PrintRoleAndName(self.ActorComponentName .. ":RefreshBeCarriedCharacterVisible", uPlayerController.CurCameraMode, self.State, bEnter, uOwnerPawn:GetPlayerNameSafety(), self.BeCarriedBackCharacter:GetPlayerNameSafety())
    if bEnter then
      self:OnHandleCameraModeChanged(uPlayerController.CurCameraMode)
      if not self:HasControlEventByControl(uPlayerController, "OnHandleCameraModeChanged") then
        self:AddControlEvent(uPlayerController, "OnHandleCameraModeChanged", function(CameraMode)
          self:OnHandleCameraModeChanged(CameraMode)
        end)
      end
    else
      self.BeCarriedBackCharacter:SetActorHiddenInGame(false)
      if self:HasControlEventByControl(uPlayerController, "OnHandleCameraModeChanged") then
        self:RemoveControlEvent(uPlayerController, "OnHandleCameraModeChanged")
      end
    end
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":RefreshBeCarriedCharacterVisible None", uPlayerController.CurCameraMode, self.State, bEnter)
  end
end
function CharacterCarryBackComponent:PreUnsetViewTargetToLastViewTarget(uPlayerController)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) or not slua.isValid(uPlayerController) then
    return
  end
  if self:HasControlEventByControl(uPlayerController, "OnHandleCameraModeChanged") then
    self:RemoveControlEvent(uPlayerController, "OnHandleCameraModeChanged")
  end
  local uCarryBackCharacter = uOwnerPawn:GetCarryBackCharacter()
  if slua.isValid(uCarryBackCharacter) then
    local bLocalFPP = uPlayerController:ShouldForceFPPView(uPlayerController:GetCurPawn())
    self:_PrintRoleAndName("CharacterCarryBackComponent:PreUnsetViewTargetToCarryBackCharacter", uCarryBackCharacter:GetPlayerNameSafety())
    local EMeshComponentUpdateFlag = import("EMeshComponentUpdateFlag")
    if bLocalFPP then
      local uCarryBackCharacterMesh = uCarryBackCharacter.Mesh
      if slua.isValid(uCarryBackCharacterMesh) then
        uCarryBackCharacterMesh:SetAnimInstanceClass(self.CarryBackCharacter.MainCharTPPAnimClass)
        uCarryBackCharacterMesh.MeshComponentUpdateFlag = EMeshComponentUpdateFlag.AlwaysTickPose
        uCarryBackCharacterMesh.NeedUpdateEveryFrame = false
      end
    end
    uCarryBackCharacter:LocalSwitchPersonPerspective(false, false, true)
    local uSpringArm = uCarryBackCharacter:GetActiveSpringArm()
    if slua.isValid(uSpringArm) then
      uSpringArm:SetActive(false, false)
    end
    if slua.isValid(uCarryBackCharacter.SpringArmComp) then
      uCarryBackCharacter.SpringArmComp:SetActive(false, false)
    end
    if slua.isValid(uCarryBackCharacter.ThirdPersonCameraComponent) then
      uCarryBackCharacter.ThirdPersonCameraComponent:SetActive(false, false)
    end
  end
end
function CharacterCarryBackComponent:PreSetViewTargetToViewTarget(uPlayerController)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) or not slua.isValid(uPlayerController) then
    return
  end
  local uCarryBackCharacter = uOwnerPawn:GetCarryBackCharacter()
  if slua.isValid(uCarryBackCharacter) then
    self:_PrintRoleAndName("CharacterCarryBackComponent:PreUnsetViewTargetToCarryBackCharacter", uOwnerPawn:GetPlayerNameSafety())
  end
end
function CharacterCarryBackComponent:PostSetViewTargetToViewTarget(uPlayerController)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) or not slua.isValid(uPlayerController) then
    return
  end
  self:AddControlEvent(uPlayerController, "OnHandleCameraModeChanged", function(CameraMode)
    self:OnHandleCameraModeChanged(CameraMode)
  end)
  local uCarryBackCharacter
  if uOwnerPawn:IsInBeCarriedBackState() then
    uCarryBackCharacter = uOwnerPawn:GetCarryBackCharacter()
  end
  if uOwnerPawn:IsInCarryBackState() then
    uCarryBackCharacter = uOwnerPawn
  end
  if uCarryBackCharacter and slua.isValid(uCarryBackCharacter) then
    local EPlayerCameraMode = import("EPlayerCameraMode")
    local bLocalFPP = uPlayerController:ShouldForceFPPView(uPlayerController:GetCurPawn())
    local CameraMode = bLocalFPP and EPlayerCameraMode.PCM_FPP or EPlayerCameraMode.PCM_Normal
    self:_PrintRoleAndName("CharacterCarryBackComponent:PostSetViewTargetToCarryBackCharacter", uCarryBackCharacter:GetPlayerNameSafety(), CameraMode, bLocalFPP)
    uPlayerController:SwitchCameraMode(CameraMode, uCarryBackCharacter, bLocalFPP, true)
    local uSpringArm = uPlayerController:GetTargetedSpringArm()
    if slua.isValid(uSpringArm) then
      uSpringArm.bEnableCameraLag = true
      uSpringArm.CameraLagSpeed = 50.0
      uSpringArm.bEnableCameraRotationLag = false
      uSpringArm.CameraRotationLagSpeed = 9.0
    end
    local EMeshComponentUpdateFlag = import("EMeshComponentUpdateFlag")
    local uCarryBackCharacterMesh = uCarryBackCharacter.Mesh
    if slua.isValid(uCarryBackCharacterMesh) then
      uCarryBackCharacterMesh.MeshComponentUpdateFlag = EMeshComponentUpdateFlag.AlwaysTickPoseAndRefreshBones
      if bLocalFPP then
        if slua.isValid(uCarryBackCharacter.AvatarAnimClassCache) then
          uCarryBackCharacterMesh:SetAnimInstanceClass(uCarryBackCharacter.AvatarAnimClassCache)
        else
          uCarryBackCharacterMesh:SetAnimInstanceClass(uCarryBackCharacter.MainCharAnimClass)
        end
        uCarryBackCharacterMesh.NeedUpdateEveryFrame = true
      end
    end
    local uCarryBackChacterCarryComp = uCarryBackCharacter:GetCarryBackComp()
    if slua.isValid(uCarryBackChacterCarryComp) then
      uCarryBackChacterCarryComp:ReplaceCharacterAnimation(true)
    end
  end
  if self:IsInCarryBackState() then
    self:ReplaceCharacterAnimation(true)
  end
end
function CharacterCarryBackComponent:_RegisterMaliciousCallbackInBeginPlay()
  if not self:_IsAuthority() then
    return
  end
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    return
  end
  local uCarryBackComponent = uCharacter:GetCarryBackComp()
  if not slua.isValid(uCarryBackComponent) then
    return
  end
  self:AddControlEvent(uCharacter, "OnDeath", self._CheckTeammateMaliciousCarryBackOnDeath, self)
  self:AddControlEvent(uCarryBackComponent, "OnEnterBeCarriedBackState", function()
    if not self._MaliciousCarryBackTimerID then
      self._MaliciousCarryBackTimerID = self:AddGameTimer(MaliciousTeammateConfig.nRefreshIntervalInSeconds, true, function()
        self:_RefreshMaliciousTeammateTimestamp()
      end)
    end
    if self._MaliciousCarryBackRemoveTimerID then
      self:RemoveGameTimer(self._MaliciousCarryBackRemoveTimerID)
      self._MaliciousCarryBackRemoveTimerID = nil
    end
  end)
  self:AddControlEvent(uCarryBackComponent, "OnExitBeCarriedBackState", function()
    if not self._MaliciousCarryBackRemoveTimerID then
      self._MaliciousCarryBackRemoveTimerID = self:AddGameTimer(MaliciousTeammateConfig.nTimeThresholdInSeconds + 2 * MaliciousTeammateConfig.nRefreshIntervalInSeconds, false, function()
        if self._MaliciousCarryBackTimerID then
          self:RemoveGameTimer(self._MaliciousCarryBackTimerID)
          self._MaliciousCarryBackTimerID = nil
        end
        self._MaliciousCarryBackRemoveTimerID = nil
      end)
    end
  end)
end
function CharacterCarryBackComponent:_IsAuthority()
  if self.GetOwner == nil then
    if Client then
      return false
    else
      return true
    end
  end
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    return false
  end
  return uCharacter.Role == import("ENetRole").ROLE_Authority
end
function CharacterCarryBackComponent:_RefreshMaliciousTeammateTimestamp()
  if not self:_IsAuthority() then
    return
  end
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    return
  end
  local uMyPlayerController = uCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uMyPlayerController) then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local EMovementMode = import("EMovementMode")
  local nWorldTimeSeconds = UGameplayStatics.GetTimeSeconds(self.Object)
  local nWorldRealTimeSeconds = UGameplayStatics.GetRealTimeSeconds(self.Object)
  local tMaliciousCarryBackRecord = self:_GetMaliciousCarryBackRecord()
  local uVelocity = uCharacter:GetVelocity()
  uVelocity.Z = 0
  if slua.isValid(uCharacter.STCharacterMovement) and uCharacter.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and not uVelocity:IsNearlyZero(1.0E-8) then
    tMaliciousCarryBackRecord.nMovementOnGroundTimeInSeconds = nWorldTimeSeconds
    tMaliciousCarryBackRecord.nMovementOnGroundRealTimeInSeconds = nWorldRealTimeSeconds
    return
  end
  local uCarrierCharacter = uCharacter:GetCarryBackCharacter()
  if not slua.isValid(uCarrierCharacter) then
    return
  end
  local uCarrierPlayerState = uCarrierCharacter:GetPlayerStateSafety()
  if not slua.isValid(uCarrierPlayerState) then
    return
  end
  local sCarrierPlayerUID = uCarrierPlayerState:GetUIDString()
  if not uMyPlayerController:IsTeamMate(uCarrierCharacter) then
    return
  end
  tMaliciousCarryBackRecord.nBeCarriedTimeInSeconds = nWorldTimeSeconds
  tMaliciousCarryBackRecord.nBeCarriedRealTimeInSeconds = nWorldRealTimeSeconds
  tMaliciousCarryBackRecord.sTeammateCarrierPlayerUID = sCarrierPlayerUID
end
function CharacterCarryBackComponent:_CheckTeammateMaliciousCarryBackOnDeath(uDeadCharacter, ...)
  if not self:_IsAuthority() then
    return
  end
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    return
  end
  if uDeadCharacter ~= uCharacter then
    return
  end
  if self._MaliciousCarryBackTimerID then
    self:RemoveGameTimer(self._MaliciousCarryBackTimerID)
    self._MaliciousCarryBackTimerID = nil
  end
  if self._MaliciousCarryBackRemoveTimerID then
    self:RemoveGameTimer(self._MaliciousCarryBackRemoveTimerID)
    self._MaliciousCarryBackRemoveTimerID = nil
  end
  local uVictimController = uCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uVictimController) then
    return
  end
  self:_ServerForbidTeammatePickIfMaliciousCarryBackDetected(uCharacter, uVictimController)
end
function CharacterCarryBackComponent:_GetMaliciousCarryBackRecord()
  if not self:_IsAuthority() then
    return nil
  end
  if not self._MaliciousCarryBackRecord then
    self._MaliciousCarryBackRecord = {
      sTeammateCarrierPlayerUID = "",
      nBeCarriedTimeInSeconds = 0,
      nBeCarriedRealTimeInSeconds = 0,
      nMovementOnGroundTimeInSeconds = 0,
      nMovementOnGroundRealTimeInSeconds = 0
    }
  end
  return self._MaliciousCarryBackRecord
end
function CharacterCarryBackComponent:_IsRecentBeCarriedBackByTeammate(nDeathTimeInSeconds, bIsUseWorldRealTimeSeconds)
  local sLogPrefix = "CharacterCarryBackComponent:_IsRecentBeCarriedBackByTeammate"
  if not self:_IsAuthority() then
    return false
  end
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    return
  end
  local uController = uCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) then
    return
  end
  local tMaliciousCarryBackRecord = self:_GetMaliciousCarryBackRecord()
  if tMaliciousCarryBackRecord.sTeammateCarrierPlayerUID == "" then
    return false
  end
  local nCarriedBackElapsedTimeInSeconds = nDeathTimeInSeconds
  if bIsUseWorldRealTimeSeconds then
    nCarriedBackElapsedTimeInSeconds = nCarriedBackElapsedTimeInSeconds - tMaliciousCarryBackRecord.nBeCarriedRealTimeInSeconds
  else
    nCarriedBackElapsedTimeInSeconds = nCarriedBackElapsedTimeInSeconds - tMaliciousCarryBackRecord.nBeCarriedTimeInSeconds
  end
  if nCarriedBackElapsedTimeInSeconds > MaliciousTeammateConfig.nTimeThresholdInSeconds then
    print(bWriteLog and string.format("%s, nCarriedBackElapsedTimeInSeconds = %.1f > %.1f", sLogPrefix, nCarriedBackElapsedTimeInSeconds, MaliciousTeammateConfig.nTimeThresholdInSeconds))
    return false
  end
  print(bWriteLog and string.format("%s, nDeathTimeInSeconds = %.1f, nCarriedBackElapsedTimeInSeconds = %.1f", sLogPrefix, nDeathTimeInSeconds, nCarriedBackElapsedTimeInSeconds))
  local nMovementOnGroundElapsedTimeInSeconds = nDeathTimeInSeconds
  if bIsUseWorldRealTimeSeconds then
    nMovementOnGroundElapsedTimeInSeconds = nMovementOnGroundElapsedTimeInSeconds - tMaliciousCarryBackRecord.nMovementOnGroundRealTimeInSeconds
  else
    nMovementOnGroundElapsedTimeInSeconds = nMovementOnGroundElapsedTimeInSeconds - tMaliciousCarryBackRecord.nMovementOnGroundTimeInSeconds
  end
  if nMovementOnGroundElapsedTimeInSeconds < MaliciousTeammateConfig.nTimeThresholdInSeconds then
    print(bWriteLog and string.format("%s, nMovementOnGroundElapsedTimeInSeconds = %.1f < %.1f", sLogPrefix, nMovementOnGroundElapsedTimeInSeconds, MaliciousTeammateConfig.nTimeThresholdInSeconds))
    return false
  end
  print(bWriteLog and string.format("%s, nDeathTimeInSeconds = %.1f, nMovementOnGroundElapsedTimeInSeconds = %.1f", sLogPrefix, nDeathTimeInSeconds, nMovementOnGroundElapsedTimeInSeconds))
  return true
end
function CharacterCarryBackComponent:_ServerForbidTeammatePickIfMaliciousCarryBackDetected(uDeadCharacter, uVictimController)
  local sLogPrefix = "CharacterCarryBackComponent:_ServerForbidTeammatePickIfMaliciousCarryBackDetected"
  if not self:_IsAuthority() then
    return
  end
  if not slua.isValid(uDeadCharacter) then
    return
  end
  if not slua.isValid(uVictimController) then
    return
  end
  if uDeadCharacter ~= uVictimController.STExtraBaseCharacter then
    return
  end
  local DSMaliciousTeammateDetectionSubsystem = SubsystemMgr:Get("DSMaliciousTeammateDetectionSubsystem")
  if not DSMaliciousTeammateDetectionSubsystem then
    print(bWriteLog and string.format("%s, !DSMaliciousTeammateDetectionSubsystem", sLogPrefix))
    return
  end
  local ETeammateDamageType = DSMaliciousTeammateDetectionSubsystem.ETeammateDamageType
  local bIsMaliciousCarryBackDetected = false
  local bIsCharacterValid = slua.isValid(uVictimController.STExtraBaseCharacter)
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  if not bIsCharacterValid or uVictimController.STExtraBaseCharacter.HealthStatus ~= ECharacterHealthStatus.FinishedLastBreath then
    local nCharacterHealthStatus = -1
    if bIsCharacterValid then
      nCharacterHealthStatus = uVictimController.STExtraBaseCharacter.HealthStatus
    end
    print(bWriteLog and string.format("%s, !bIsDead, STExtraBaseCharacter valid = %s, HealthStatus = %d", sLogPrefix, tostring(bIsCharacterValid), nCharacterHealthStatus))
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local EDamageType = import("EDamageType")
  local nTeammateDamageType
  if not bIsMaliciousCarryBackDetected then
    if uVictimController.STExtraBaseCharacter.DamageCauserRecords:Num() > 0 then
      local nLastDamageRecordIndex = uVictimController.STExtraBaseCharacter.DamageCauserRecords:Num() - 1
      local uLastDamageRecordData = uVictimController.STExtraBaseCharacter.DamageCauserRecords:Get(nLastDamageRecordIndex)
      local bIsRecentBeCarriedByTeammate = self:_IsRecentBeCarriedBackByTeammate(uLastDamageRecordData.Time, true)
      if uLastDamageRecordData.DamageType == EDamageType.FallingDamage and uLastDamageRecordData.StatusChangeMargin == 1 and bIsRecentBeCarriedByTeammate then
        bIsMaliciousCarryBackDetected = true
        nTeammateDamageType = ETeammateDamageType.CarrybackFallingDamage
      else
        print(bWriteLog and string.format("%s, DamageType = %d, StatusChangeMargin = %d, bIsRecentBeCarriedByTeammate = %s", sLogPrefix, uLastDamageRecordData.DamageType, uLastDamageRecordData.StatusChangeMargin, tostring(bIsRecentBeCarriedByTeammate)))
      end
    else
      print(bWriteLog and string.format("%s, STExtraBaseCharacter.DamageCauserRecords:Num() == 0", sLogPrefix))
    end
  end
  if not bIsMaliciousCarryBackDetected then
    return
  end
  local sPerpetratorPlayerUID = self:_GetMaliciousCarryBackRecord().sTeammateCarrierPlayerUID
  DSMaliciousTeammateDetectionSubsystem:OnMaliciousTeammateCarryBackDetected(uDeadCharacter.PlayerUID, sPerpetratorPlayerUID, nTeammateDamageType, uDeadCharacter.HealthStatus)
end
function CharacterCarryBackComponent:CarryToVehicleFinished(InDirType)
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  self.DetachMethod = EPutDownDetachMethod.CarryToVehicle
  self:_PrintRoleAndName(string.format("CarryToVehicleFinished(LuaOverride) State:%d, DetachMethod:%d", self.State, self.DetachMethod))
  local uOwnerPawn = self:GetOwner()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) then
    return
  end
  if slua.isValid(self.BeCarriedBackCharacter) then
    local uBeCarriedBackComp = self.BeCarriedBackCharacter:GetCarryBackComp()
    if slua.isValid(uBeCarriedBackComp) then
      uBeCarriedBackComp:BeCarriedToVehicleFinished(InDirType)
    end
  end
  self:LocalExitCarryToVehicleState(self.DetachMethod)
  self:ResetCarryBackState()
end
function CharacterCarryBackComponent:BeCarriedToVehicleFinished(InDirType)
  local uOwnerPawn = self:GetOwner()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  self.DetachMethod = EPutDownDetachMethod.CarryToVehicle
  self:_PrintRoleAndName(string.format("BeCarriedToVehicleFinished(LuaOverride) State:%d, DetachMethod:%d", self.State, self.DetachMethod))
  self:LocalExitBeCarriedToVehicle(self.DetachMethod)
  self:ResetCarryBackState()
end
function CharacterCarryBackComponent:LocalExitBeCarriedToVehicle(DetachMethod)
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  self:_PrintCarryInfo(string.format("LocalExitBeCarriedToVehicle DetachMethod:%d", DetachMethod))
  local ENetRole = import("ENetRole")
  local uAttachedCharacter = self.BeCarriedBackCharacter
  if not slua.isValid(uAttachedCharacter) then
    return
  end
  if uOwnerPawn.Role ~= ENetRole.ROLE_Authority then
    self:_PrintCarryInfo(string.format("stop anim LocalExitBeCarriedToVehicle uAttachedCharacter:%s", uAttachedCharacter))
    uAttachedCharacter:StopAnimMontageOriginal()
  end
  local ECollisionChannel = import("ECollisionChannel")
  local ECollisionResponse = import("ECollisionResponse")
  if uAttachedCharacter.CapsuleComponent and slua.isValid(uAttachedCharacter.CapsuleComponent) then
    uAttachedCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Ignore)
    uAttachedCharacter.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, ECollisionResponse.ECR_Ignore)
  end
  local EPawnState = import("EPawnState")
  if slua.isValid(self.BeCarriedBackCharacter) then
    self:_PrintCarryInfo(string.format("USTCharacterCarryBackComp LocalExitBeCarriedToVehicle:LeaveState EPawnState.BeCarriedBack"))
    self.BeCarriedBackCharacter:LeaveState(EPawnState.BeCarriedBack)
    local uBeCarriedBackController = self.BeCarriedBackCharacter:GetPlayerControllerSafety()
    if slua.isValid(uBeCarriedBackController) then
      uBeCarriedBackController:SetMovable(true)
    end
  end
  self:RefreshBeCarriedCharacterVisible(false)
  if self:IsInBeCarriedBackState() then
    local hasInVehicle = uAttachedCharacter:HasState(EPawnState.InVehicle)
    self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle ob =>hasInVehicle: "), hasInVehicle)
    if uOwnerPawn.Role == ENetRole.ROLE_Authority then
      self:ServerObserveCarryCharacter(false)
    else
      self:ClientObserveCarryCharacter(false, uOwnerPawn.Role)
    end
  end
  local BeCarriedBackComp = uAttachedCharacter:GetCarryBackComp()
  if not slua.isValid(BeCarriedBackComp) then
    self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle(LuaOverride) BeCarriedBackComp = null"))
    return
  end
  if uOwnerPawn.Role == ENetRole.ROLE_Authority then
    local playController = uOwnerPawn:GetControllerSafety()
    if not slua.isValid(playController) then
      self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle [ServerTryEnterVehicle] (LuaOverride) playController = null"))
      return
    end
    local VehicleUserComponentClass = import("VehicleUserComponentBase")
    local VehicleUser = playController:GetComponentByClass(VehicleUserComponentClass)
    if not slua.isValid(VehicleUser) then
      self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle [ServerTryEnterVehicle] (LuaOverride) VehicleUser = null"))
      return
    end
    local TargetVehicle = BeCarriedBackComp:GetCarryToTargetVehicle()
    if slua.isValid(TargetVehicle) then
      self:_PrintCarryInfo(string.format("LocalExitBeCarriedToVehicle [ServerTryEnterVehicle] BeCarriedBackComp(LuaOverride) Ready to go, TargetVehicle:%s", TargetVehicle))
      local STExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
      local nSeatType = 1
      local ValidSeatIndex = TargetVehicle.VehicleSeats:GetAvailableSeatIndex(STExtraVehicleSeatType.ESeatType_PassengersSeat)
      if 0 <= ValidSeatIndex then
        VehicleUser:ForceEnterVehicle(TargetVehicle, ValidSeatIndex, nSeatType)
      else
        local EPutDownDetachMethod = import("EPutDownDetachMethod")
        local uCharacter = self.CarryBackCharacter
        if slua.isValid(uCharacter) then
          uCharacter:StopCarryBack(EPutDownDetachMethod.OtherReason)
          self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle ValidSeatIndex<0 [StopCarryBack] (LuaOverride) EPutDownDetachMethod.OtherReason"))
        end
      end
    else
      self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle [ServerTryEnterVehicle] (LuaOverride) TargetVehicle = null, put down on the ground"))
      self:PutDownAfterFailureCarryToVehicle()
    end
  end
  local hasInVehicle = uAttachedCharacter:HasState(EPawnState.InVehicle)
  local uCurPlayerController = uAttachedCharacter:GetPlayerControllerSafety()
  if uAttachedCharacter.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(uCurPlayerController) and hasInVehicle then
    self:_PrintRoleAndName(string.format("LocalExitBeCarriedToVehicle(LuaOverride) Set last step ===> set joystick and touchable==>"))
    uCurPlayerController:SetDisableTouchMoveInput(false)
    uCurPlayerController:CallShowTouchInterface(false)
  end
  if uOwnerPawn.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(self.BeCarriedBackCharacter) and slua.isValid(self.CarryBackCharacter) and self.BeCarriedBackCharacter.TeamID == self.CarryBackCharacter.TeamID then
    UIManager.HideUI(UIManager.UI_Config_InGame.CarryBackBreakUI)
  end
end
function CharacterCarryBackComponent:PutDownAfterFailureCarryToVehicle()
  local uCharacter = self.CarryBackCharacter
  local uAttachedCharacter = self.BeCarriedBackCharacter
  if not slua.isValid(uCharacter) then
    return
  end
  if not slua.isValid(uAttachedCharacter) then
    return
  end
  if not slua.isValid(uCharacter.CharacterMovement) then
    return
  end
  uAttachedCharacter:K2_DetachFromActor(1, 1, 0)
  if uAttachedCharacter.CharacterMovement.MovementMode == 0 then
    uAttachedCharacter.CharacterMovement:SetMovementMode(1, 0)
  end
  uAttachedCharacter.CharacterMovement:SetComponentTickEnabled(true)
  uAttachedCharacter.CharacterMovement:Activate(true)
  uCharacter.CharacterMovement:RefreshCharacterWithBase(false)
  local uTempCharacter = slua.isValid(uCharacter) and uCharacter or uAttachedCharacter
  local UKismetMathLibrary = import("KismetMathLibrary")
  local uAttachedCharacterController = uAttachedCharacter:GetPlayerControllerSafety()
  local uLocation = uTempCharacter:K2_GetActorLocation()
  local uForwardVector = uTempCharacter:GetActorForwardVector()
  local uRightVector = uTempCharacter:GetActorRightVector()
  local uPassWallCheckLocation = uLocation + uForwardVector * -58 + uRightVector * -10 + FVector(0, 0, -15)
  local uNewLocation = uLocation + uForwardVector * -58 + uRightVector * -10 + FVector(0, 0, -29)
  local uNewRotation = UKismetMathLibrary.Conv_VectorToRotator(UKismetMathLibrary.Multiply_VectorFloat(uRightVector, -1))
  self:_PrintRoleAndName(self.ActorComponentName .. ":DetachFromOtherCharacter Back", uNewLocation.X, uNewLocation.Y, uNewLocation.Z, uNewRotation.Pitch, uNewRotation.Roll, uNewRotation.Yaw)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
  local ResolveParams = FResolvePenetrationParams()
  local boolCanPutDown = true
  if uCharacter and slua.isValid(uCharacter) then
    slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
    slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCharacter)
    boolCanPutDown = uCharacter.CheckBaseIsSmallMoveable and uCharacter:CheckBaseIsSmallMoveable() or uSTExtraBlueprintFunctionLibrary.IsNoOverlapAndNoPassWalPlace(uAttachedCharacter, uPassWallCheckLocation, uNewRotation, ResolveParams)
  end
  uAttachedCharacter:K2_SetActorRotation(uNewRotation, false, nil, true)
  if boolCanPutDown then
    uAttachedCharacter:K2_SetActorLocation(uNewLocation, false, nil, true)
  else
    self:_PrintRoleAndName(self.ActorComponentName .. ":DetachFromOtherCharacter Back SetActorLocationSafety")
    uAttachedCharacter:SetActorLocationSafety(uLocation)
  end
  if slua.isValid(uAttachedCharacterController) then
    uAttachedCharacterController:SetControlRotation(uNewRotation, "CharacterCarryBackComponent:DetachPawn")
  end
  self:PrintCharacterBaseMovementBase(uCharacter, uAttachedCharacter)
  self:SetAttachedCharacterMovementBase(uAttachedCharacter:K2_GetActorLocation(), uCharacter, uAttachedCharacter)
  return
end
function CharacterCarryBackComponent:RPC_ServerManualBreakCarryBackState()
  local uOwnerPawn = self:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local EPutDownDetachMethod = import("EPutDownDetachMethod")
  if uOwnerPawn:IsInCarryBackState() then
    local uCarryBackCharacter = uOwnerPawn
    local uBeCarriedBackCharacter = uOwnerPawn:GetBeCarriedBackCharacter()
    if slua.isValid(uCarryBackCharacter) and slua.isValid(uBeCarriedBackCharacter) then
      uCarryBackCharacter:StopCarryBack(EPutDownDetachMethod.OtherReason)
      local uCarryBackComp = uCarryBackCharacter:GetCarryBackComp()
      if slua.isValid(uCarryBackComp) then
        uCarryBackComp:RecordManualBreakTime(uBeCarriedBackCharacter)
      end
    end
  elseif uOwnerPawn:IsInBeCarriedBackState() then
    local uCarryBackCharacter = uOwnerPawn:GetCarryBackCharacter()
    local uBeCarriedBackCharacter = uOwnerPawn
    if slua.isValid(uCarryBackCharacter) and slua.isValid(uBeCarriedBackCharacter) then
      uCarryBackCharacter:StopCarryBack(EPutDownDetachMethod.OtherReason)
      local uCarryBackComp = uCarryBackCharacter:GetCarryBackComp()
      if slua.isValid(uCarryBackComp) then
        uCarryBackComp:RecordManualBreakTime(uBeCarriedBackCharacter)
      end
    end
  end
end
function CharacterCarryBackComponent:ClientManualBreakCarryBackState()
  self:RPC_ServerManualBreakCarryBackState()
end
function CharacterCarryBackComponent:CanCarryToVehicle(InVehicleActor)
  if not slua.isValid(InVehicleActor) then
    print(bWriteLog and "CanCarryToVehicle InVehicleActor=nil")
    return false
  end
  if InVehicleActor.bForbidCarryPlayerToVehicle then
    print(bWriteLog and "CanCarryToVehicle bForbidCarryPlayerToVehicle=1, InVehicleActor:" .. tostring(InVehicleActor))
    return false
  end
  return self.Super:CanCarryToVehicle(InVehicleActor)
end
function CharacterCarryBackComponent:CanCarryToVehicle(InVehicleActor)
  if not slua.isValid(InVehicleActor) then
    print(bWriteLog and "CanCarryToVehicle InVehicleActor=nil")
    return false
  end
  if InVehicleActor.bForbidCarryPlayerToVehicle then
    print(bWriteLog and "CanCarryToVehicle bForbidCarryPlayerToVehicle=1, InVehicleActor:" .. tostring(InVehicleActor))
    return false
  end
  return self.Super:CanCarryToVehicle(InVehicleActor)
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CCharacterCarryBackComponent = class(CActorComponentBase, nil, CharacterCarryBackComponent)
return CCharacterCarryBackComponent