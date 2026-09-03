local CheckParachuteOpenFeature = {
  ServerRPC = {}
}
local ENetRole = import("ENetRole")
local EParachuteState = import("EParachuteState")
local ParachuteOpenConfig = {
  DelayShowParachuteCloseUITime = 0.5,
  ParachuteOpenInitParams = {CloseParachuteHeight = 650}
}
function CheckParachuteOpenFeature:ctor()
  self.CheckShowParachuteOpenTimer = nil
  self.CheckShowParachuteCloseUITimer = nil
  self.nParachuteOpenUIState = UEnums.EParachuteOpenUIState.EState_None
  self.bCanStartCheckShowParachuteCloseUITimer = false
  self.bCanCheckShowUI = true
  self.bSwitchedWeapon = false
end
function CheckParachuteOpenFeature:ReceiveBeginPlay()
  CheckParachuteOpenFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "CheckParachuteOpenFeature:ReceiveBeginPlay")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModeType2 = GameMainConfig.GetModType()
  if ModType == "SteamTrain" then
    print(bWriteLog and "CheckParachuteOpenFeature:ReceiveBeginPlay SteamTrain Go other")
    return
  end
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.HandleEnterGameModeFightingState, self)
  if Client then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    GameplayData.AddSelfPlayerCharacterEvent(self, "HandleParachuteStateChangedOver", self.HandleParachuteStateChangedOver, self)
  end
end
function CheckParachuteOpenFeature:CanStartCheckShowParachuteOpen(uCharacter)
  if slua.isValid(uCharacter) and uCharacter.GetAttachParentActor and uCharacter:GetAttachParentActor() == nil and uCharacter.Health > 1.0E-5 and not uCharacter:ActorHasTag("NotCheckParachuteOpen") and uCharacter.ParachuteState == EParachuteState.PS_None then
    local SwimComponet = uCharacter.SwimComponet
    if slua.isValid(SwimComponet) and SwimComponet:IsEnterWaterSuface() then
      print(bWriteLog and "CheckParachuteOpenFeature:CanStartCheckShowParachuteOpen IsEnterWaterSuface")
      return false
    end
    return true
  end
  return false
end
function CheckParachuteOpenFeature:HandleEnterGameModeFightingState()
  local uCharacterController = self.Owner
  if uCharacterController and uCharacterController.Role == ENetRole.ROLE_Authority then
    local uCharacter = uCharacterController:GetPlayerCharacterSafety()
    if slua.isValid(uCharacter) then
      self.bAlreadyRegFallingDistanceSatisfyDelegate = true
      self:AddControlEvent(uCharacter, "FallingDistanceSatisfyDelegate", self.HandleFallingDistanceSatisfy, self)
      if slua.isValid(uCharacter.ParachuteComponent) then
        self:AddControlEvent(uCharacter.ParachuteComponent, "OnLanded", self.OnPlayerExitParachuteCallback, self)
      end
    end
  end
end
function CheckParachuteOpenFeature:HandleFallingDistanceSatisfy(bFallingDistanceSatisfy)
  local uCharacterController = self.Owner
  if uCharacterController then
    local uCharacter = uCharacterController:GetPlayerCharacterSafety()
    if slua.isValid(uCharacter) then
      print(bWriteLog and "CheckParachuteOpenFeature:HandleFallingDistanceSatisfy:", bFallingDistanceSatisfy)
      if bFallingDistanceSatisfy and self:CanStartCheckShowParachuteOpen(uCharacter) and self.bCanCheckShowUI then
        if self.nParachuteOpenUIState ~= UEnums.EParachuteOpenUIState.EState_ShowParachuteOpenUI then
          self.nParachuteOpenUIState = UEnums.EParachuteOpenUIState.EState_ShowParachuteOpenUI
        end
      else
        self:ClearCheckShowParachuteOpenTimer()
      end
    end
  end
end
function CheckParachuteOpenFeature:ClearTimerAndState()
  self:ClearCheckShowParachuteOpenTimer()
  self:ClearCheckShowParachuteCloseUITimer()
  self.nParachuteOpenUIState = UEnums.EParachuteOpenUIState.EState_None
end
function CheckParachuteOpenFeature:ResetCheckShowUI()
  print(bWriteLog and "CheckParachuteOpenFeature:ResetCheckShowUI")
  self.bCanCheckShowUI = true
end
function CheckParachuteOpenFeature:ReceiveEndPlay()
  self:ClearTimerAndState()
  print(bWriteLog and "CheckParachuteOpenFeature:ReceiveEndPlay")
  CheckParachuteOpenFeature.__super.ReceiveEndPlay(self)
end
function CheckParachuteOpenFeature:CharacterSwitchWeapon(bInSwitchWeapon, uCharacter)
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  if bInSwitchWeapon and not self.bSwitchedWeapon and slua.isValid(uCharacter) then
    self.bSwitchedWeapon = true
    local uWeaponManager = uCharacter:GetWeaponManager()
    self.nWeaponSlot = uWeaponManager:GetCurrentUsingPropSlot()
    uCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
  end
  if not bInSwitchWeapon and slua.isValid(uCharacter) then
    if self.bSwitchedWeapon then
      uCharacter:SwitchWeaponBySlot(self.nWeaponSlot, false, true, true)
    end
    self.bSwitchedWeapon = false
  end
end
function CheckParachuteOpenFeature:ClearCheckShowParachuteOpenTimer()
  print(bWriteLog and "CheckParachuteOpenFeature:ClearCheckShowParachuteOpenTimer")
  if self.CheckShowParachuteOpenTimer then
    self:RemoveGameTimer(self.CheckShowParachuteOpenTimer)
    self.CheckShowParachuteOpenTimer = nil
  end
  if self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_ShowParachuteOpenUI then
    self.nParachuteOpenUIState = UEnums.EParachuteOpenUIState.EState_None
  end
end
function CheckParachuteOpenFeature:ClearCheckShowParachuteCloseUITimer()
  print(bWriteLog and "CheckParachuteOpenFeature:ClearCheckShowParachuteCloseUITimer")
  if self.CheckShowParachuteCloseUITimer then
    self:RemoveGameTimer(self.CheckShowParachuteCloseUITimer)
    self.CheckShowParachuteCloseUITimer = nil
  end
end
function CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
  print(bWriteLog and "CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI")
  if not self.bCanStartCheckShowParachuteCloseUITimer then
    print(bWriteLog and bWriteLog and "CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI  not CanStartCheckShowParachuteCloseUITimer")
    return
  end
  self.bCanStartCheckShowParachuteCloseUITimer = false
  self:ClearTimerAndState()
  local uCharacterController = self.Owner
  if uCharacterController then
    local uCharacter = uCharacterController:GetPlayerCharacterSafety()
    if slua.isValid(uCharacter) then
      self.CheckShowParachuteCloseUITimer = self:AddGameTimer(ParachuteOpenConfig.DelayShowParachuteCloseUITime, false, function()
        if uCharacter and uCharacter.ParachuteState == EParachuteState.PS_Opening then
          self.nParachuteOpenUIState = UEnums.EParachuteOpenUIState.EState_SlowParachuteCloseUI
          self.bCanCheckShowUI = false
        end
      end)
    end
  end
end
function CheckParachuteOpenFeature:ShowParachuteOpenUI()
  if UIManager.UI_Config_InGame.ParachuteOpenUI and not UIManager.IsUIShow(UIManager.UI_Config_InGame.ParachuteOpenUI) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end
function CheckParachuteOpenFeature:CloseParachuteOpenUI()
  if UIManager.UI_Config_InGame.ParachuteOpenUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end
function CheckParachuteOpenFeature:GetCurrentParachuteOpenUIState()
  return self.nParachuteOpenUIState
end
function CheckParachuteOpenFeature:OnRep_nParachuteOpenUIState()
  print(bWriteLog and "CheckParachuteOpenFeature:OnRep_nParachuteOpenUIState:", self.nParachuteOpenUIState)
  if self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_None then
    self:CloseParachuteOpenUI()
  else
    self:ShowParachuteOpenUI()
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_REFRESH_PARACHUTE_UI_STATE, self.nParachuteOpenUIState)
  end
end
function CheckParachuteOpenFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "nParachuteOpenUIState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
CheckParachuteOpenFeature.ServerRPC.RPC_ServerParachuteOpen = {
  Reliable = true,
  Params = {}
}
function CheckParachuteOpenFeature:RPC_ServerParachuteOpen()
  self:ParachuteOpenOrClose(true)
end
CheckParachuteOpenFeature.ServerRPC.RPC_ServerParachuteClose = {
  Reliable = true,
  Params = {}
}
function CheckParachuteOpenFeature:RPC_ServerParachuteClose()
  self:ParachuteOpenOrClose(false)
end
function CheckParachuteOpenFeature:ParachuteOpenOrClose(bOpenParachute)
  print(bWriteLog and "CheckParachuteOpenFeature:ParachuteOpenOrClose:", bOpenParachute)
  local uPlayerController = self.Owner
  if uPlayerController and uPlayerController.Role == ENetRole.ROLE_Authority then
    local uCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uCharacter) then
      local EStateType = import("EStateType")
      if bOpenParachute and self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_ShowParachuteOpenUI then
        if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
          self.bCanStartCheckShowParachuteCloseUITimer = true
          local ESTEPoseState = import("ESTEPoseState")
          uCharacter:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
          uPlayerController:ReInitParachuteItem()
          uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteOpen)
          self:ChangeForceOpenAndCloseParachuteHeight()
          self:CharacterSwitchWeapon(bOpenParachute, uCharacter)
          local uPlayerState = uCharacter:GetPlayerStateSafety()
          if slua.isValid(uPlayerState) then
            uPlayerState:AddGeneralCount(1108, 1, false)
          end
          if slua.isValid(uCharacter.ParachuteComponent) then
            local EParachuteType = import("/Script/ShadowTrackerExtra.EParachuteType")
            uCharacter.ParachuteComponent.ParachuteReason = EParachuteType.FallFromHeight
          end
        end
      elseif not bOpenParachute and self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_SlowParachuteCloseUI then
        local MachineCompent = uPlayerController:GetStateMachineCompent()
        if slua.isValid(MachineCompent) and MachineCompent.CurrentState and MachineCompent.CurrentState.bShouldTriggerLandingSkill then
          MachineCompent.CurrentState.bShouldTriggerLandingSkill = false
        end
        if uPlayerController.ServerChangeStatePC then
          uPlayerController:ServerChangeStatePC(EStateType.State_Fight)
        end
        if slua.isValid(MachineCompent) and MachineCompent.CurrentState and MachineCompent.CurrentState.bShouldTriggerLandingSkill == nil then
          MachineCompent.CurrentState.bShouldTriggerLandingSkill = true
        end
        self:CharacterSwitchWeapon(bOpenParachute, uCharacter)
        local uPlayerState = uCharacter:GetPlayerStateSafety()
        if slua.isValid(uPlayerState) then
          uPlayerState:AddGeneralCount(1109, 1, false)
        end
      end
    end
  end
end
function CheckParachuteOpenFeature:ChangeForceOpenAndCloseParachuteHeight()
  print(bWriteLog and "CheckParachuteOpenFeature:ChangeForceOpenAndCloseParachuteHeight")
  local uPlayerController = self.Owner
  if uPlayerController and uPlayerController.Role == ENetRole.ROLE_Authority then
    if not self.CacheParachuteSpeedParam then
      self.CacheParachuteSpeedParam = {}
    end
    self.CacheParachuteSpeedParam.CloseParachuteHeight = uPlayerController.CloseParachuteHeight
    uPlayerController.CloseParachuteHeight = ParachuteOpenConfig.ParachuteOpenInitParams.CloseParachuteHeight
  end
end
function CheckParachuteOpenFeature:RecoverParachuteOpenParam()
  if not self.CacheParachuteSpeedParam then
    return
  end
  local uPlayerController = self.Owner
  if uPlayerController and uPlayerController.Role == ENetRole.ROLE_Authority then
    uPlayerController.CloseParachuteHeight = self.CacheParachuteSpeedParam.CloseParachuteHeight
  end
  self.CacheParachuteSpeedParam = nil
  print(bWriteLog and "CheckParachuteOpenFeature:RecoverParachuteOpenParam")
end
function CheckParachuteOpenFeature:OnPlayerExitParachuteCallback()
  print(bWriteLog and "CheckParachuteOpenFeature:OnPlayerExitParachuteCallback")
  self:ClearTimerAndState()
  local uPlayerController = self.Owner
  if uPlayerController and uPlayerController.Role == ENetRole.ROLE_Authority then
    local uCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uCharacter) then
      self:CharacterSwitchWeapon(false, uCharacter)
    end
  end
end
function CheckParachuteOpenFeature:HandleParachuteStateChangedOver(newstate)
  local EParachuteState = import("EParachuteState")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  print(bWriteLog and "CheckParachuteOpenFeature:HandleParachuteStateChangedOver newstate:" .. tostring(newstate) .. tostring(PlayerCharacter.bHaveSetParachutepersonState) .. tostring(PlayerCharacter.bParachteFromParachuteOpen) .. "PlayerCharacter.IsNetFPP:" .. tostring(PlayerCharacter.IsNetFPP))
  if newstate == EParachuteState.PS_None and slua.isValid(PlayerCharacter) and PlayerCharacter.bHaveSetParachutepersonState then
    PlayerCharacter.bHaveSetParachutepersonState = false
    PlayerCharacter:SetCurrentPersonPerspective(true, false)
    PlayerCharacter:LocalSwitchPersonPerspective(true, true, true)
    PlayerCharacter.bForceChangePersonPerspective = false
    PlayerCharacter.bParachteFromParachuteOpen = false
    print(bWriteLog and "CheckParachuteOpenFeature:HandleParachuteStateChangedOver bHaveSetParachutepersonState false")
  end
  if slua.isValid(PlayerCharacter) and newstate ~= EParachuteState.PS_None and not PlayerCharacter.bHaveSetParachutepersonState and PlayerCharacter.bParachteFromParachuteOpen then
    local IsFPP = PlayerCharacter.IsNetFPP
    print(bWriteLog and "CheckParachuteOpenFeature:HandleParachuteStateChangedOver set TF")
    PlayerCharacter.bParachteFromParachuteOpen = false
    if IsFPP then
      print(bWriteLog and "CheckParachuteOpenFeature:HandleParachuteStateChangedOver bHaveSetParachutepersonState true")
      PlayerCharacter.bHaveSetParachutepersonState = true
      PlayerCharacter.bForceChangePersonPerspective = true
    end
    PlayerCharacter:SetCurrentPersonPerspective(false, false)
    PlayerCharacter:LocalSwitchPersonPerspective(false, true, true)
  end
end
function CheckParachuteOpenFeature:AIServerParachuteOpen(uMLAIParachuteJumpComp, uCurController)
  local EMLAIJumpingPhase = import("EMLAIJumpingPhase")
  uMLAIParachuteJumpComp.JumpingPhase = EMLAIJumpingPhase.FreeFalling
  if slua.isValid(uCurController) then
    if uCurController.AddItemForAI then
      uCurController:AddItemForAI(702042, 1, false, false, true)
    end
    local uCharacter = uCurController:GetPlayerCharacterSafety()
    if slua.isValid(uCharacter) and slua.isValid(uCharacter.ParachuteComponent) then
      local EParachuteType = import("/Script/ShadowTrackerExtra.EParachuteType")
      uCharacter.ParachuteComponent.ParachuteReason = EParachuteType.FallFromHeight
    end
  end
  uMLAIParachuteJumpComp:OpenParachute()
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, CheckParachuteOpenFeature)