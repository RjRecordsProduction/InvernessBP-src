local GeneralShowSpotConfig = require("GameLua.Mod.BRMod.Gameplay.Config.GeneralShowSpotConfig")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EAttachmentRule = import("EAttachmentRule")
local EDetachmentRule = import("EDetachmentRule")
local ENetRole = import("ENetRole")
local FCameraOffsetData = import("CameraOffsetData")
local UKismetMathLibrary = import("KismetMathLibrary")
local SHOW_SPOT_CAMERA_FOV_TAG = "GeneralShowSpotCameraFovTag"
local PlayerCharacterGeneralShowSpotFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
PlayerCharacterGeneralShowSpotFeature.ClientRPC.RPC_Client_EnterShowSpot = {
  Reliable = true,
  Params = {}
}
PlayerCharacterGeneralShowSpotFeature.ServerRPC.RPC_Server_OnEnterShowSpotFailed = {
  Reliable = true,
  Params = {}
}
local EGeneralShowSpotState = {
  None = 0,
  WaitEnterSelfie = 1,
  PlayShow = 2
}
function PlayerCharacterGeneralShowSpotFeature:ctor()
  self.bHasRegisteredEvent = false
  self.OriginLocation = nil
  self.OriginRotation = nil
  self.uClientMontageAsset = nil
  self.uClientSpotSelfMontageAsset = nil
  self.uClientCacheSpotComp = nil
  self.nPlayingSpotAudioID = nil
  self.nDSBookedSpotIndex = 0
  self.nRandomAnimIndex = 0
  self.bHasSwitchedWeapon = false
  self._bClientExitingSelfie = false
  self._fClientLastExitSelfieTime = 0
  self._fDSLastExitSelfieTime = 0
  self._uShowSpotFovCameraData = nil
  self._ClientScreenMarkInstIDs = nil
  self.ShowSpotTipsTimer = nil
  self._PendingShowSpotTipsData = nil
end
function PlayerCharacterGeneralShowSpotFeature:ReceiveBeginPlay()
  PlayerCharacterGeneralShowSpotFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ReceiveBeginPlay")
end
function PlayerCharacterGeneralShowSpotFeature:RegisterEvent()
  if self.bHasRegisteredEvent then
    return
  end
  if Client then
    if self.Owner and self.Owner.Role == ENetRole.ROLE_AutonomousProxy then
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE, self._OnClientEnterSelfieMode, self)
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE, self._OnClientExitSelfieMode, self)
      self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self._OnClientBattleResult, self)
      if slua.isValid(self.Owner.Object) then
        self:AddControlEvent(self.Owner.Object, "OnPostRepAttachment", self.HandleOnPostRepAttachment, self)
      end
    end
    if self.Owner and slua.isValid(self.Owner.Object) then
      local uAvatarComp = self.Owner.Object.CharacterAvatarComp2_BP
      if slua.isValid(uAvatarComp) then
        self:AddControlEvent(uAvatarComp, "OnAvatarAllMeshLoaded", self.HandleOnAvatarAllMeshLoaded, self)
      end
    end
  elseif self.Owner and slua.isValid(self.Owner.Object) then
    self:BindLuaObjEvent(self.Owner.Object, "OnDSEnterSelfieMode", self._OnDSEnterSelfieMode, self)
    self:BindLuaObjEvent(self.Owner.Object, "OnDSExitSelfieMode", self._OnDSExitSelfieMode, self)
    self:AddControlEvent(self.Owner.Object, "OnShootVerifyScaleDelegate", self.HandleOnOnShootVerifyScaleDelegate, self)
  end
  self.bHasRegisteredEvent = true
end
function PlayerCharacterGeneralShowSpotFeature:UnregisterEvent()
  if not self.bHasRegisteredEvent then
    return
  end
  if Client then
    if self.Owner and self.Owner.Role == ENetRole.ROLE_AutonomousProxy then
      self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE)
      self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE)
      self:RemoveCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT)
    end
    if self.Owner and slua.isValid(self.Owner.Object) then
      self:RemoveControlEvent(self.Owner.Object, "OnPostRepAttachment")
    end
    if self.Owner and slua.isValid(self.Owner.Object) then
      local uAvatarComp = self.Owner.Object.CharacterAvatarComp2_BP
      if slua.isValid(uAvatarComp) then
        self:RemoveControlEvent(uAvatarComp, "OnAvatarAllMeshLoaded")
      end
    end
  elseif self.Owner and slua.isValid(self.Owner.Object) then
    self:UnBindLuaObjEvent(self.Owner.Object, "OnDSEnterSelfieMode")
    self:UnBindLuaObjEvent(self.Owner.Object, "OnDSExitSelfieMode")
    self:RemoveControlEvent(self.Owner.Object, "OnShootVerifyScaleDelegate")
  end
  self.bHasRegisteredEvent = false
end
function PlayerCharacterGeneralShowSpotFeature:ReceiveEndPlay(EndPlayReason)
  if Client then
    self:_RemoveClientScreenMark()
    self:_ClearShowSpotTipsTimer()
    self._PendingShowSpotTipsData = nil
  end
  PlayerCharacterGeneralShowSpotFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerCharacterGeneralShowSpotFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "uCurShowSpotActor",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    },
    {
      "nCurSpotIndex",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nShowSpotState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nRandomAnimIndex",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  if PlayerCharacterGeneralShowSpotFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = PlayerCharacterGeneralShowSpotFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function PlayerCharacterGeneralShowSpotFeature:NotifyClientEnterShowSpot(ShowSpotActor, nSpotIndex)
  if Client then
    return false
  end
  if not slua.isValid(ShowSpotActor) or self.nShowSpotState ~= EGeneralShowSpotState.None then
    return false
  end
  if self.Owner then
    self.OriginLocation = self.Owner:K2_GetActorLocation()
    self.OriginRotation = self.Owner:K2_GetActorRotation()
  end
  self.uCur  self.nDSBookedSpotIndex = nSpotIndex
  self:_SetShowSpotState(EGeneralShowSpotState.WaitEnterSelfie)
  self:_StopAndDisableSkillsForShowSpot()
  self:_ApplyDisabledPawnStates(true)
  self:RPC_Client_EnterShowSpot()
  return true
end
function PlayerCharacterGeneralShowSpotFeature:_SetShowSpotState(nState)
  if Client or nState == nil then
    return
  end
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetShowSpotState nState:" .. tostring(nState))
  self.nShowSpotState = nState
  self:OnShowSpotStateChanged()
end
function PlayerCharacterGeneralShowSpotFeature:IsInShowSpot()
  return self.nShowSpotState ~= nil and self.nShowSpotState ~= EGeneralShowSpotState.None
end
function PlayerCharacterGeneralShowSpotFeature:IsWaitEnterSelfie()
  return self.nShowSpotState == EGeneralShowSpotState.WaitEnterSelfie
end
function PlayerCharacterGeneralShowSpotFeature:ResetPendingShowSpotState()
  if Client then
    return
  end
  if self.nShowSpotState == EGeneralShowSpotState.WaitEnterSelfie then
    print(bWriteLog and "[BRMod] PlayerCharacterGeneralShowSpotFeature:ResetPendingShowSpotState reset from WaitEnterSelfie")
    self:_SetAllSkillsDisabled(false)
    self:_ApplyDisabledPawnStates(false)
    self:_SetShowSpotState(EGeneralShowSpotState.None)
    return
  end
  if self.nShowSpotState ~= nil and self.nShowSpotState ~= EGeneralShowSpotState.None then
    print(bWriteLog and "[BRMod] PlayerCharacterGeneralShowSpotFeature:ResetPendingShowSpotState misuse, skip. state:" .. tostring(self.nShowSpotState))
  end
end
function PlayerCharacterGeneralShowSpotFeature:RPC_Server_OnEnterShowSpotFailed()
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:RPC_Server_OnEnterShowSpotFailed Actor:%s", Game:GetPlainName(self.uCurShowSpotActor)))
  if not slua.isValid(self.uCurShowSpotActor) or not self.uCurShowSpotActor.OnServerEnterShowSpotFailed then
    return
  end
  if not slua.isValid(self.Owner) then
    return
  end
  self.uCurShowSpotActor:OnServerEnterShowSpotFailed(self.Owner)
end
function PlayerCharacterGeneralShowSpotFeature:_OnDSEnterSelfieMode()
  if Client then
    return
  end
  if self.nShowSpotState ~= EGeneralShowSpotState.WaitEnterSelfie then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSEnterSelfieMode Owner invalid")
    return
  end
  local bCanUse, nNewSpotIndex = false
  if slua.isValid(self.uCurShowSpotActor) and self.uCurShowSpotActor.NotifyAndDoubleCheckShowSpotEnter then
    bCanUse, nNewSpotIndex = self.uCurShowSpotActor:NotifyAndDoubleCheckShowSpotEnter(self.Owner.Object, self.nDSBookedSpotIndex)
  end
  if bCanUse then
    self.nCurSpotIndex = nNewSpotIndex or self.nDSBookedSpotIndex
    self:_DecideRandomAnimIndex(self.nCurSpotIndex)
    if self:_AttachCharacterToSpot(self.Owner.Object, self.nCurSpotIndex) then
      self:_SwitchWeapon(false)
      self:RecordTLog()
      self:_SetShowSpotState(EGeneralShowSpotState.PlayShow)
      self.uCurShowSpotActor:_AddOccupiedPawn(self.Owner.Object)
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSEnterSelfieMode Start Show Success SpotIndex:" .. tostring(self.nCurSpotIndex))
      return
    end
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSEnterSelfieMode Attach failed, fallback abort")
  end
  self:AddGameTimer(0, false, function()
    if not self or not self.Owner then
      return
    end
    if self.nShowSpotState ~= EGeneralShowSpotState.WaitEnterSelfie then
      return
    end
    self:_AbortPendingEnterShowSpot()
  end)
end
function PlayerCharacterGeneralShowSpotFeature:RecordTLog()
  if slua.isValid(self.uCurShowSpotActor) and self.uCurShowSpotActor.TlogID and self.uCurShowSpotActor.TlogID > 0 and self.Owner and slua.isValid(self.Owner.Object) and self.Owner.Object.GetPlayerStateSafety then
    local uPlayerState = self.Owner.Object:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:RecordTLog AddGeneralCount TlogID: " .. tostring(self.uCurShowSpotActor.TlogID))
      uPlayerState:AddGeneralCount(self.uCurShowSpotActor.TlogID, 1, self.uCurShowSpotActor.bReset)
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:HandleOnOnShootVerifyScaleDelegate()
  if Client then
    return
  end
  if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
    return
  end
  if self.Owner and slua.isValid(self.uCurShowSpotActor) and slua.isValid(self.Owner.Object) then
    local SpotData = self.uCurShowSpotActor:GetShowSpotConfig(self.nCurSpotIndex)
    if SpotData and SpotData.nHitBoxScaleNum and type(SpotData.nHitBoxScaleNum) == "number" then
      self.Owner.Object.FeatureDynamicVertifyHitBoxScale = self.Owner.Object.FeatureDynamicVertifyHitBoxScale * SpotData.nHitBoxScaleNum
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:_SwitchWeapon(bRestore)
  if Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SwitchWeapon Owner invalid")
    return
  end
  local EPawnState = import("EPawnState")
  if bRestore then
    if not self.bHasSwitchedWeapon then
      return
    end
    self.bHasSwitchedWeapon = false
    self.Owner.Object:SetPawnStateDisabled(EPawnState.SwitchWeapon, false)
    if self.Owner.Object.IsPawnStateDisabled and self.Owner.Object:IsPawnStateDisabled(EPawnState.SwitchWeapon) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SwitchWeapon PawnStateDisabled")
      return
    end
    if self.Owner.Object.SwitchToLastNoneGrenageWeapon then
      self.Owner.Object:SwitchToLastNoneGrenageWeapon(true, true, false, true)
    end
  else
    if not self.Owner.Object.SwitchWeaponBySlot then
      return
    end
    local uSkillManagerComp = self.Owner.Object:GetSkillManager()
    if slua.isValid(uSkillManagerComp) then
      local UTSkillStopReason = import("UTSkillStopReason")
      uSkillManagerComp:StopSkillAll(UTSkillStopReason.SkillStopReason_Interrupted)
    end
    if self.Owner.Object.IsPawnStateDisabled and self.Owner.Object:IsPawnStateDisabled(EPawnState.SwitchWeapon) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SwitchWeapon PawnStateDisabled")
      return
    end
    local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
    self.Owner.Object:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, true, true, true)
    self.bHasSwitchedWeapon = true
    self.Owner.Object:SetPawnStateDisabled(EPawnState.SwitchWeapon, true)
  end
end
function PlayerCharacterGeneralShowSpotFeature:_AbortPendingEnterShowSpot()
  if Client then
    return
  end
  print(bWriteLog and "[BRMod] PlayerCharacterGeneralShowSpotFeature:_AbortPendingEnterShowSpot")
  self:_SwitchWeapon(true)
  self:_ApplyDisabledPawnStates(false)
  self:_SetAllSkillsDisabled(false)
  if slua.isValid(self.uCurShowSpotActor) and self.uCurShowSpotActor.OnServerEnterShowSpotFailed and slua.isValid(self.Owner) then
    self.uCurShowSpotActor:OnServerEnterShowSpotFailed(self.Owner)
  end
  if self.Owner then
    local uPlayerState = self.Owner:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and uPlayerState.PhotoGrapherFeature then
      uPlayerState.PhotoGrapherFeature:ExitPhotoGrapher()
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:_OnDSExitSelfieMode()
  if Client then
    return
  end
  if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSExitSelfieMode Owner invalid")
    return
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_OnDSExitSelfieMode SpotIndex:%s Actor:%s", tostring(self.nCurSpotIndex), Game:GetPlainName(self.uCurShowSpotActor)))
  local uShowSpotActor = self.uCurShowSpotActor
  local nSpotIndex = self.nCurSpotIndex
  if slua.isValid(uShowSpotActor) and uShowSpotActor.NotifyShowSpotLeft then
    uShowSpotActor:NotifyShowSpotLeft(self.Owner.Object)
  end
  self.Owner.Object:K2_DetachFromActor(EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld)
  self.Owner.Object:SetAttachment(nil, nil, FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), "None")
  self:_SetCharacterMovementEnabled(true)
  local EPawnState = import("EPawnState")
  local bIsDyingOrDead = self.Owner.Object:HasState(EPawnState.Dying) or self.Owner.Object:HasState(EPawnState.Dead)
  if not bIsDyingOrDead then
    self.Owner.Object:EnsureDynamicFeature("TeleportPawnFeature")
    if self.OriginLocation and self.Owner.Object.TeleportPawnFeature and self.OriginRotation then
      local bSuccess = self.Owner.Object.TeleportPawnFeature:RemoteTeleport(self.OriginLocation, self.OriginRotation)
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSExitSelfieMode Teleport Success:" .. tostring(bSuccess))
      if not bSuccess then
        local NearbyLocArr = CGame:FindNearbyGroundLoc(3, self.OriginLocation, 100, 300, 58000, 3)
        if slua.isValid(NearbyLocArr) then
          for _, LocPoint in pairs(NearbyLocArr) do
            if slua.isValid(LocPoint) then
              local bRetrySuccess = self.Owner.Object.TeleportPawnFeature:RemoteTeleport(LocPoint, self.OriginRotation)
              print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSExitSelfieMode Retry Teleport Success:" .. tostring(bRetrySuccess))
              if bRetrySuccess then
                break
              end
            end
          end
        end
      end
    end
  else
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnDSExitSelfieMode skip teleport: player dying/dead")
  end
  self:_SwitchWeapon(true)
  self:_ApplyDisabledPawnStates(false)
  self:_SetAllSkillsDisabled(false)
  self.Owner.Object:ForceNetUpdate()
  if slua.isValid(CGameState) and CGameState.GetServerWorldTimeSeconds then
    self._fDSLastExitSelfieTime = CGameState:GetServerWorldTimeSeconds()
  end
  self:_SetShowSpotState(EGeneralShowSpotState.None)
end
function PlayerCharacterGeneralShowSpotFeature:_AttachCharacterToSpot(Character, nSpotIndex)
  if not (slua.isValid(Character) and nSpotIndex) or not slua.isValid(self.uCurShowSpotActor) then
    return false
  end
  local SpotData = self.uCurShowSpotActor:GetShowSpotConfig(self.nCurSpotIndex)
  local uSpotComp = self.uCurShowSpotActor:GetSpotSceneComponent(self.nCurSpotIndex)
  if not slua.isValid(uSpotComp) then
    return false
  end
  local RelativeLocation = FVector(0, 0, 0)
  local RelativeRotation = FRotator(0, 0, 0)
  if GeneralShowSpotConfig.DefaultAttachRelativeLocation then
    RelativeLocation = GeneralShowSpotConfig.DefaultAttachRelativeLocation
  end
  if GeneralShowSpotConfig.DefaultAttachRelativeRotation then
    RelativeRotation = GeneralShowSpotConfig.DefaultAttachRelativeRotation
  end
  self:_SetCharacterMovementEnabled(false)
  local sSocketName = "None"
  if self.uCurShowSpotActor.GetSpotAttachSocketName then
    sSocketName = self.uCurShowSpotActor:GetSpotAttachSocketName(self.nCurSpotIndex, self.nRandomAnimIndex) or "None"
  end
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_AttachCharacterToSpot sSocketName:" .. tostring(sSocketName))
  Character:K2_AttachToComponent(uSpotComp, sSocketName, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.KeepWorld, false)
  Character:K2_SetActorRelativeRotation(RelativeRotation, false, nil, false)
  Character:K2_SetActorRelativeLocation(RelativeLocation, false, nil, false)
  local uRotation = self.Owner.Object:K2_GetActorRotation()
  local uPlayerController = self.Owner.Object:GetPlayerControllerSafety()
  if slua.isValid(uPlayerController) then
    uPlayerController:SetControlRotation(uRotation, "ShowSpot")
  end
  Character:ForceNetUpdate()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_AttachCharacterToSpot SpotIndex:" .. tostring(nSpotIndex))
  return true
end
function PlayerCharacterGeneralShowSpotFeature:_SetCharacterMovementEnabled(bEnable)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_SetCharacterMovementEnabled bEnable:%s", tostring(bEnable)))
  if bEnable then
    self.Owner.Object:ActivateCharacterMovement()
  else
    self.Owner.Object:DeactivateCharacterMovement(true)
  end
end
function PlayerCharacterGeneralShowSpotFeature:OnShowSpotStateChanged()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:OnShowSpotStateChanged nShowSpotState:" .. tostring(self.nShowSpotState))
  if self.nShowSpotState == EGeneralShowSpotState.None then
    if Client and self._bShowSpotActivated then
      self:_OnClientExitSelfieMode()
    end
    self:UnregisterEvent()
  else
    self:RegisterEvent()
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  if self.nShowSpotState == EGeneralShowSpotState.None then
    if self._bShowSpotActivated then
      self.Owner.bUseControllerRotationYaw = true
      if Client then
        self:_SetCharacterMovementEnabled(true)
        self:ClientStopMontage()
        if self.LoadAnimAssetHandle then
          self:CancelAsyncLoad(self.LoadAnimAssetHandle)
          self.LoadAnimAssetHandle = nil
        end
      else
        self:ResetSpotInfo()
      end
      self._bShowSpotActivated = false
    end
  elseif self.nShowSpotState == EGeneralShowSpotState.PlayShow then
    self._bShowSpotActivated = true
    self.Owner.bUseControllerRotationYaw = false
    if Client then
      self:_SetCharacterMovementEnabled(false)
      self:CheckCanPlayMontage()
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:ResetSpotInfo()
  if not Client then
    self.nCurSpotIndex = 0
    self.uCurShowSpotActor = nil
    self.OriginLocation = nil
    self.OriginRotation = nil
    self.nRandomAnimIndex = 0
    self.bHasSwitchedWeapon = false
  end
end
function PlayerCharacterGeneralShowSpotFeature:_ApplyDisabledPawnStates(bDisable)
  if Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  local DisabledStates = GeneralShowSpotConfig.DisabledPawnStatesOnShowSpot
  if type(DisabledStates) ~= "table" or #DisabledStates == 0 then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_ApplyDisabledPawnStates PlayerKey = %s, bDisable = %s, DisablePawnStates = {%s}", self.Owner.Object.PlayerKey, bDisable, table.concat(DisabledStates, ", ")))
  if bDisable then
    for _, PawnState in pairs(DisabledStates) do
      self.Owner.Object:SetPawnStateDisabled(PawnState, true)
    end
  else
    for _, PawnState in pairs(DisabledStates) do
      self.Owner.Object:ResetPawnStateDisabled(PawnState)
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:_StopAndDisableSkillsForShowSpot()
  if Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  local uSkillManagerComp = self.Owner.Object:GetSkillManager()
  if slua.isValid(uSkillManagerComp) then
    local UTSkillStopReason = import("UTSkillStopReason")
    uSkillManagerComp:StopSkillAll(UTSkillStopReason.SkillStopReason_Interrupted)
  end
  self:_SetAllSkillsDisabled(true)
end
function PlayerCharacterGeneralShowSpotFeature:_SetAllSkillsDisabled(bDisable)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  local SkillMgr = self.Owner.Object.GetSkillManager and self.Owner.Object:GetSkillManager() or nil
  if not slua.isValid(SkillMgr) then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_SetAllSkillsDisabled bDisable:%s", tostring(bDisable)))
  SkillMgr:SetSkillTagsDisable({0}, bDisable, "ShowSpot")
end
function PlayerCharacterGeneralShowSpotFeature:_DecideRandomAnimIndex(nSpotIndex)
  if Client then
    return
  end
  self.nRandomAnimIndex = 0
  if not slua.isValid(self.uCurShowSpotActor) or not self.uCurShowSpotActor.GetShowSpotConfig then
    return
  end
  local SpotData = self.uCurShowSpotActor:GetShowSpotConfig(nSpotIndex)
  if not SpotData then
    return
  end
  if SpotData.PoseAnimationPath and SpotData.PoseAnimationPath ~= "" then
    return
  end
  if not self.uCurShowSpotActor.GetRandomPoseConfig then
    return
  end
  local nIndex, sPath = self.uCurShowSpotActor:GetRandomPoseConfig()
  self.nRandomAnimIndex = nIndex or 0
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_DecideRandomAnimIndex SpotIndex:%s nRandomAnimIndex:%s path:%s", tostring(nSpotIndex), tostring(self.nRandomAnimIndex), tostring(sPath)))
end
function PlayerCharacterGeneralShowSpotFeature:IsPlayShow()
  return self.nShowSpotState == EGeneralShowSpotState.PlayShow
end
function PlayerCharacterGeneralShowSpotFeature:OnRep_nShowSpotState()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:OnRep_nShowSpotState: ", self.nShowSpotState)
  self:OnShowSpotStateChanged()
end
function PlayerCharacterGeneralShowSpotFeature:OnRep_nCurSpotIndex()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:OnRep_nCurSpotIndex: ", self.nCurSpotIndex)
  self:CheckCanPlayMontage()
end
function PlayerCharacterGeneralShowSpotFeature:OnRep_uCurShowSpotActor()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:OnRep_uCurShowSpotActor: ", self.uCurShowSpotActor)
  self:CheckCanPlayMontage()
  if self._bPendingActorCameraDispatch then
    self:_SetCameraByActorConfig()
  end
  self:_AddClientScreenMark()
end
function PlayerCharacterGeneralShowSpotFeature:OnRep_nRandomAnimIndex()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:OnRep_nRandomAnimIndex: ", self.nRandomAnimIndex)
  self:CheckCanPlayMontage()
end
function PlayerCharacterGeneralShowSpotFeature:RPC_Client_EnterShowSpot()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:RPC_Client_EnterShowSpot")
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:RPC_Client_EnterShowSpot no IngameSelfieSubsystem")
    self:RPC_Server_OnEnterShowSpotFailed()
    return
  end
  if not IngameSelfieSubsystem:EnterSelfie() then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:RPC_Client_EnterShowSpot EnterSelfie failed")
    self:RPC_Server_OnEnterShowSpotFailed()
    return
  end
  function self.EnterSelfieCallBack()
    local PhotoUI = UIManager.UI_Config_InGame.Ingame_Photo_UIBP and UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_Photo_UIBP) or nil
    if PhotoUI and PhotoUI.RefreshPhotoUIDisplayState then
      PhotoUI:SetExternalPhotoUIDisplayState(3)
      PhotoUI:RefreshPhotoUIDisplayState()
      PhotoUI:InitWeather()
      if PhotoUI.SetWeatherPanelOpen then
        PhotoUI:SetWeatherPanelOpen(true)
      end
      self:CheckSetCamera()
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:_OnClientEnterSelfieMode()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientEnterSelfieMode")
  self.bApplyingHighLightLayout = true
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
    MainControlPanelTochButton:ApplyLayout(UILayoutConfig.LayoutNameConfig.HighLightLayout)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self.LastShowTouchInterface = PlayerController.bIsJoyStickShow == true
    PlayerController:ShowTouchInterface(false)
  end
  self:_SetAllSkillsDisabled(true)
  if self.EnterSelfieCallBack then
    self.EnterSelfieCallBack()
    self.EnterSelfieCallBack = nil
  end
  self:_AddClientScreenMark()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.AddIgnoreDamageType then
    IngameSelfieSubsystem:AddIgnoreDamageType(13)
  end
  if self._PendingShowSpotTipsData then
    self:_TryScheduleShowSpotTips(self._PendingShowSpotTipsData)
    self._PendingShowSpotTipsData = nil
  end
end
function PlayerCharacterGeneralShowSpotFeature:_OnClientExitSelfieMode()
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientExitSelfieMode")
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.RemoveIgnoreDamageType then
    IngameSelfieSubsystem:RemoveIgnoreDamageType(13)
  end
  self:_RemoveClientScreenMark()
  self:_ClearShowSpotTipsTimer()
  self._PendingShowSpotTipsData = nil
  self._bClientExitingSelfie = true
  self._bPendingActorCameraDispatch = false
  if self._uShowSpotFovCameraData then
    if self.Owner and slua.isValid(self.Owner.CustomSpringArm) and self.Owner.CustomSpringArm.SetCameraStateEnable then
      self.Owner.CustomSpringArm:SetCameraStateEnable(SHOW_SPOT_CAMERA_FOV_TAG, false)
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientExitSelfieMode disable CameraFov tag")
    end
    self._uShowSpotFovCameraData = nil
  end
  if self._bShowSpotCameraRotApplied then
    if self.Owner and slua.isValid(self.Owner.Camera) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientExitSelfieMode restore Camera RelRot: ")
      self.Owner.Camera:K2_SetRelativeRotation(FRotator(0, 0, 0), false, nil, false)
    end
    self._bShowSpotCameraRotApplied = false
  end
  if self._bShowSpotCameraFovApplied then
    if self.Owner and slua.isValid(self.Owner.Camera) and self._fShowSpotOriginalCameraFov then
      self.Owner.Camera.FieldOfView = self._fShowSpotOriginalCameraFov
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientExitSelfieMode restore Camera FOV: " .. tostring(self._fShowSpotOriginalCameraFov))
    end
    self._bShowSpotCameraFovApplied = false
    self._fShowSpotOriginalCameraFov = nil
  end
  self:ClientStopMontage()
  if self.bApplyingHighLightLayout then
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
      MainControlPanelTochButton:UnApplyLayout(UILayoutConfig.LayoutNameConfig.HighLightLayout)
    end
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:ShowTouchInterface(true)
    end
    self.bApplyingHighLightLayout = false
    self:_SetAllSkillsDisabled(false)
  end
  if self.ExitSelfieCallBack then
    self.ExitSelfieCallBack()
    self.ExitSelfieCallBack = nil
  end
  self._bClientExitingSelfie = false
  if slua.isValid(CGameState) and CGameState.GetServerWorldTimeSeconds then
    self._fClientLastExitSelfieTime = CGameState:GetServerWorldTimeSeconds()
  end
end
function PlayerCharacterGeneralShowSpotFeature:IsClientInExitSelfieDebounce()
  if not Client then
    return false
  end
  if self._bClientExitingSelfie then
    return true
  end
  local fCooldown = GeneralShowSpotConfig.ExitSelfieDebounceTime or 1.0
  if fCooldown <= 0 then
    return false
  end
  if not slua.isValid(CGameState) or not CGameState.GetServerWorldTimeSeconds then
    return false
  end
  local fNow = CGameState:GetServerWorldTimeSeconds()
  return fCooldown > fNow - (self._fClientLastExitSelfieTime or 0)
end
function PlayerCharacterGeneralShowSpotFeature:IsDSInExitSelfieCooldown()
  if Client then
    return false
  end
  local fCooldown = GeneralShowSpotConfig.ExitSelfieDebounceTime or 1.0
  if fCooldown <= 0 then
    return false
  end
  if not slua.isValid(CGameState) or not CGameState.GetServerWorldTimeSeconds then
    return false
  end
  local fNow = CGameState:GetServerWorldTimeSeconds()
  return fCooldown > fNow - (self._fDSLastExitSelfieTime or 0)
end
function PlayerCharacterGeneralShowSpotFeature:_OnClientBattleResult()
  if not self.Owner or self.Owner.Role ~= ENetRole.ROLE_AutonomousProxy then
    return
  end
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientBattleResult")
  if self.nShowSpotState == EGeneralShowSpotState.None then
    return
  end
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_OnClientBattleResult force exit selfie, state:" .. tostring(self.nShowSpotState))
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.ExitSelfie then
    IngameSelfieSubsystem:ExitSelfie()
  end
end
function PlayerCharacterGeneralShowSpotFeature:CheckCanPlayMontage()
  if not Client then
    return false
  end
  if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
    return false
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:CheckCanPlayMontage empty actor"))
    return false
  end
  if not self.nCurSpotIndex or self.nCurSpotIndex <= 0 then
    print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:CheckCanPlayMontage invaild index"))
    return false
  end
  if not self.uCurShowSpotActor.GetShowSpotConfig then
    return false
  end
  local SpotData = self.uCurShowSpotActor:GetShowSpotConfig(self.nCurSpotIndex)
  if not SpotData then
    print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:CheckCanPlayMontage empty path, SpotIndex:%s Actor:%s", tostring(self.nCurSpotIndex), Game:GetPlainName(self.uCurShowSpotActor)))
    return false
  end
  if self.uCurShowSpotActor and self.uCurShowSpotActor.OnClientPlayMontage then
    self.uCurShowSpotActor:OnClientPlayMontage(self.Owner, self.nCurSpotIndex)
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:CheckCanPlayMontage play SpotIndex:%s", tostring(self.nCurSpotIndex)))
  self:ClientPlayMontage(SpotData)
  return true
end
function PlayerCharacterGeneralShowSpotFeature:CheckSetCamera()
  if not Client then
    return false
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    return false
  end
  if not self.nCurSpotIndex or self.nCurSpotIndex <= 0 then
    return false
  end
  if not self.uCurShowSpotActor.GetShowSpotConfig then
    return false
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:CheckSetCamera play SpotIndex:%s", tostring(self.nCurSpotIndex)))
  self:ClientSetCamera()
  return true
end
function PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage(SpotData)
  if not SpotData then
    return
  end
  local AnimMontagePath
  if not SpotData.PoseAnimationPath or SpotData.PoseAnimationPath == "" then
    if self.nRandomAnimIndex and self.nRandomAnimIndex > 0 and slua.isValid(self.uCurShowSpotActor) and self.uCurShowSpotActor.GetRandomPoseConfigByIndex then
      AnimMontagePath = self.uCurShowSpotActor:GetRandomPoseConfigByIndex(self.nRandomAnimIndex)
    end
  else
    AnimMontagePath = SpotData.PoseAnimationPath
  end
  if SpotData.EnabledSpotSelfMontage then
    self:_ClientPlaySpotSelfMontage(SpotData)
  end
  if self.LoadAnimAssetHandle or AnimMontagePath == nil then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage LoadAnimAssetHandle is not nil")
    return
  end
  self.LoadAnimAssetHandle = self:AsyncLoadAsset(AnimMontagePath, function(CharacterAnimMontage)
    self.LoadAnimAssetHandle = nil
    if not slua.isValid(CharacterAnimMontage) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage CharacterAnimMontage is not valid")
      return
    end
    if not self.Owner or not slua.isValid(self.Owner.Object) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage uOwnerPawn is nil")
      return
    end
    local uCharAnimInstance = self.Owner:GetCurrentMainLogicAnimInstance(false)
    if not slua.isValid(uCharAnimInstance) then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage uCharAnimInstance is not valid")
      return
    end
    if not uCharAnimInstance:Montage_IsPlaying(CharacterAnimMontage) then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      uCharAnimInstance:Montage_Play(CharacterAnimMontage, 1, EMontagePlayReturnType.MontageLength, 0)
      self.uClientMontageAsset = CharacterAnimMontage
      if SpotData and SpotData.SetClothMeshForceLod then
        self.Owner:SetClothMeshForceLod(true)
        print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage SetClothMeshForceLod:true")
      end
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage CharacterAnimMontage:" .. tostring(AnimMontagePath))
      if SpotData and SpotData.SpotAudioPath and SpotData.SpotAudioPath ~= "" then
        self:PlaySpotAudio(SpotData.SpotAudioPath)
      end
      if self.Owner and self.Owner.Role == ENetRole.ROLE_AutonomousProxy then
        self._PendingShowSpotTipsData = SpotData
        if self.Owner.GetIsSelfieMode and self.Owner:GetIsSelfieMode() then
          self:_TryScheduleShowSpotTips(SpotData)
          self._PendingShowSpotTipsData = nil
        end
      end
      return true
    end
  end)
end
function PlayerCharacterGeneralShowSpotFeature:_TryScheduleShowSpotTips(SpotData)
  if not Client then
    return
  end
  if not self.Owner or self.Owner.Role ~= ENetRole.ROLE_AutonomousProxy then
    return
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    return
  end
  local nTipsID, fDelayTime
  if SpotData and SpotData.ShowSpotTipsID and SpotData.ShowSpotTipsID > 0 then
    nTipsID = SpotData.ShowSpotTipsID
  elseif self.uCurShowSpotActor.ShowSpotTipsID and self.uCurShowSpotActor.ShowSpotTipsID > 0 then
    nTipsID = self.uCurShowSpotActor.ShowSpotTipsID
  end
  if not nTipsID then
    return
  end
  if SpotData and SpotData.ShowSpotTipsDelayTime and 0 < SpotData.ShowSpotTipsDelayTime then
    fDelayTime = SpotData.ShowSpotTipsDelayTime
  elseif self.uCurShowSpotActor.ShowSpotTipsDelayTime and 0 < self.uCurShowSpotActor.ShowSpotTipsDelayTime then
    fDelayTime = self.uCurShowSpotActor.ShowSpotTipsDelayTime
  else
    fDelayTime = 0
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_TryScheduleShowSpotTips TipsID:%s Delay:%s", tostring(nTipsID), tostring(fDelayTime)))
  self:_ClearShowSpotTipsTimer()
  if 0 < fDelayTime then
    self.ShowSpotTipsTimer = self:AddGameTimer(fDelayTime, false, function()
      self.ShowSpotTipsTimer = nil
      self:_ShowSpotTips(nTipsID)
    end)
  else
    self:_ShowSpotTips(nTipsID)
  end
end
function PlayerCharacterGeneralShowSpotFeature:_ShowSpotTips(nTipsID)
  if not Client or not nTipsID then
    return
  end
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_ShowSpotTips TipsID:" .. tostring(nTipsID))
  IngameTipsTools.BattleGeneralSAPTip(nTipsID, "", "")
end
function PlayerCharacterGeneralShowSpotFeature:_ClearShowSpotTipsTimer()
  if self.ShowSpotTipsTimer then
    self:RemoveGameTimer(self.ShowSpotTipsTimer)
    self.ShowSpotTipsTimer = nil
  end
end
function PlayerCharacterGeneralShowSpotFeature:ClientStopMontage()
  self:_ClearShowSpotTipsTimer()
  self._PendingShowSpotTipsData = nil
  self:_ClientStopSpotSelfMontage()
  self:StopSpotAudio()
  if not self.Owner then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientStopMontage Owner is nil")
    return
  end
  if self.uClientMontageAsset == nil then
    return
  end
  local uCharAnimInstance = self.Owner:GetCurrentMainLogicAnimInstance(false)
  if not slua.isValid(uCharAnimInstance) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientStopMontage uCharAnimInstance is not valid")
    return
  end
  self.Owner:SetClothMeshForceLod(false)
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientPlayMontage SetClothMeshForceLod:false")
  if uCharAnimInstance:Montage_IsPlaying(self.uClientMontageAsset) then
    uCharAnimInstance:Montage_Stop(0, self.uClientMontageAsset)
    self.uClientMontageAsset = nil
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientStopMontage CharacterAnimMontage:")
  end
end
function PlayerCharacterGeneralShowSpotFeature:ClientSetCamera()
  if not Client then
    return
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    return
  end
  if self.uCurShowSpotActor.UseShowSpotActorCameraConfig and self.uCurShowSpotActor:UseShowSpotActorCameraConfig() then
    self:_SetCameraByActorConfig()
  else
    self:_SetCameraBySpotConfig()
  end
end
function PlayerCharacterGeneralShowSpotFeature:_SetCameraBySpotConfig()
  local SpotData = self.uCurShowSpotActor:GetShowSpotConfig(self.nCurSpotIndex)
  if not SpotData then
    print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_SetCameraBySpotConfig empty path, SpotIndex:%s Actor:%s", tostring(self.nCurSpotIndex), Game:GetPlainName(self.uCurShowSpotActor)))
    return false
  end
  if SpotData.FreeCameraRotation then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.StartFreeCamera then
      local uRotation = self.Owner.Object:K2_GetActorRotation()
      uPlayerController:SetControlRotation(uRotation, "ShowSpot")
      uPlayerController:StartFreeCamera(0)
      local uSpringArm = uPlayerController.GetTargetedSpringArm and uPlayerController:GetTargetedSpringArm() or nil
      if slua.isValid(uSpringArm) and uSpringArm.DelayRotationBackLagEnabled then
        local fDelay = GeneralShowSpotConfig.FreeCameraRotationDelay or 0.5
        uSpringArm:DelayRotationBackLagEnabled(true, fDelay, SpotData.FreeCameraRotation)
        uPlayerController.SelfieFreeCamPrevFigureResultDelta = SpotData.FreeCameraRotation
        print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig FreeCameraRotation P:%s Y:%s R:%s", tostring(SpotData.FreeCameraRotation.Pitch), tostring(SpotData.FreeCameraRotation.Yaw), tostring(SpotData.FreeCameraRotation.Roll)))
      else
        print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig SpringArm invalid")
      end
    else
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig PlayerController invalid")
    end
  end
  if SpotData.CameraArmLengthRate then
    local PhotoUI = UIManager.UI_Config_InGame.Ingame_Photo_UIBP and UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_Photo_UIBP) or nil
    if PhotoUI then
      PhotoUI:SetSpecificZoom(SpotData.CameraArmLengthRate)
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig SetSpecificZoom:" .. tostring(SpotData.CameraArmLengthRate))
    else
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig PhotoUI is nil")
    end
  end
  if SpotData.CameraFov then
    if self.Owner and slua.isValid(self.Owner.CustomSpringArm) and self.Owner.CustomSpringArm.SetCustomCameraDataEnableWithTag then
      local uCameraData = self._uShowSpotFovCameraData
      if not uCameraData then
        uCameraData = FCameraOffsetData()
        self._uShowSpotFovCameraData = uCameraData
      end
      uCameraData.FixedFov = SpotData.CameraFov
      self.Owner.CustomSpringArm:SetCustomCameraDataEnableWithTag(uCameraData, SHOW_SPOT_CAMERA_FOV_TAG, true)
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig CameraFov:" .. tostring(SpotData.CameraFov))
    else
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:ClientSetCameraConfig CustomSpringArm invalid for CameraFov")
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:HandleOnPostRepAttachment(uAttachParent)
  if not slua.isValid(self.uCurShowSpotActor) then
    return
  end
  if slua.isValid(uAttachParent) and uAttachParent ~= self.uCurShowSpotActor then
    return
  end
  if self and self.Owner and slua.isValid(self.Owner.Object) then
    local RelativeLocation = FVector(0, 0, 0)
    local RelativeRotation = FRotator(0, 0, 0)
    if GeneralShowSpotConfig.DefaultAttachRelativeLocation then
      RelativeLocation = GeneralShowSpotConfig.DefaultAttachRelativeLocation
    end
    if GeneralShowSpotConfig.DefaultAttachRelativeRotation then
      RelativeRotation = GeneralShowSpotConfig.DefaultAttachRelativeRotation
    end
    self.Owner.Object:K2_SetActorRelativeLocation(RelativeLocation, false, nil, false)
    self.Owner.Object:K2_SetActorRelativeRotation(RelativeRotation, false, nil, false)
  end
  if not self._bPendingActorCameraDispatch then
    return
  end
  self:_ConsumePendingActorCameraDispatch("OnPostRepAttachment")
end
function PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig()
  if not Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    self._bPendingActorCameraDispatch = true
    return
  end
  local uAttachParent = self.Owner.Object.GetAttachParentActor and self.Owner.Object:GetAttachParentActor() or nil
  if not slua.isValid(uAttachParent) or uAttachParent ~= self.uCurShowSpotActor then
    self._bPendingActorCameraDispatch = true
    return
  end
  self:_ConsumePendingActorCameraDispatch("Immediate")
end
function PlayerCharacterGeneralShowSpotFeature:_ConsumePendingActorCameraDispatch(sReason)
  print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_ConsumePendingActorCameraDispatch " .. tostring(sReason))
  self._bPendingActorCameraDispatch = false
  if not slua.isValid(self.Owner and self.Owner.Object) then
    return
  end
  self:_DoSetCameraByActorConfig()
end
function PlayerCharacterGeneralShowSpotFeature:_DoSetCameraByActorConfig()
  if not Client then
    return
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig invalid actor")
    return
  end
  local uActorSpringArm = self.uCurShowSpotActor:GetShowSpotSpringArm()
  if not slua.isValid(uActorSpringArm) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig invalid actor SpringArm")
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig invalid Owner")
    return
  end
  if not slua.isValid(self.Owner.CustomSpringArm) then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig invalid Owner CustomSpringArm")
    return
  end
  local uPlayerSpringArm = self.Owner.CustomSpringArm
  local A_SAWorldLoc = uActorSpringArm:K2_GetComponentLocation()
  local P_SAWorldLoc = uPlayerSpringArm:K2_GetComponentLocation()
  if not A_SAWorldLoc or not P_SAWorldLoc then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig invalid SpringArm location")
    return
  end
  local WorldDelta = FVector(A_SAWorldLoc.X - P_SAWorldLoc.X, A_SAWorldLoc.Y - P_SAWorldLoc.Y, A_SAWorldLoc.Z - P_SAWorldLoc.Z)
  local OwnerRotator = self.Owner.Object:K2_GetActorRotation()
  local TargetOffset = UKismetMathLibrary.LessLess_VectorRotator(WorldDelta, OwnerRotator)
  if uPlayerSpringArm.TargetOffset then
    TargetOffset = TargetOffset - uPlayerSpringArm.TargetOffset
  end
  local uCameraData = self._uShowSpotFovCameraData
  if not uCameraData then
    uCameraData = FCameraOffsetData()
    self._uShowSpotFovCameraData = uCameraData
  end
  uCameraData.  if uActorSpringArm.TargetArmLength ~= nil then
    uCameraData.SpringArmLength = uActorSpringArm.TargetArmLength
  end
  if uActorSpringArm.SocketOffset ~= nil then
    uCameraData.SocketOffset = uActorSpringArm.SocketOffset
  end
  uPlayerSpringArm:SetCustomCameraDataEnableWithTag(uCameraData, SHOW_SPOT_CAMERA_FOV_TAG, true)
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig SpringArmLength:%s FixedFov:%s TargetOffset:(%s,%s,%s)", tostring(uCameraData.SpringArmLength), tostring(uCameraData.FixedFov), tostring(TargetOffset.X), tostring(TargetOffset.Y), tostring(TargetOffset.Z)))
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.SetControlRotation then
    local A_SAWorldRot = uActorSpringArm:K2_GetComponentRotation()
    if A_SAWorldRot then
      uPlayerController:SetControlRotation(FRotator(A_SAWorldRot.Pitch, A_SAWorldRot.Yaw, 0), "ShowSpot")
    end
  end
  self._bShowSpotCameraRotApplied = false
  self._bShowSpotCameraFovApplied = false
  if self.uCurShowSpotActor.GetShowSpotCamera then
    local uActorCamera = self.uCurShowSpotActor:GetShowSpotCamera()
    local uPlayerCamera = self.Owner and self.Owner.Camera
    if slua.isValid(uActorCamera) and slua.isValid(uPlayerCamera) and uPlayerCamera.K2_SetRelativeRotation then
      local ACamRelRot = uActorCamera.RelativeRotation
      if ACamRelRot then
        print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig SetControlRotation:" .. ACamRelRot:ToString())
        uPlayerCamera:K2_SetRelativeRotation(ACamRelRot, false, nil, false)
        self._bShowSpotCameraRotApplied = true
      end
      local fActorFov = uActorCamera.FieldOfView
      if fActorFov and 0 < fActorFov then
        self._fShowSpotOriginalCameraFov = uPlayerCamera.FieldOfView
        uPlayerCamera.FieldOfView = fActorFov
        self._bShowSpotCameraFovApplied = true
        print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_SetCameraByActorConfig SetFov:" .. tostring(fActorFov))
      end
    end
  end
end
function PlayerCharacterGeneralShowSpotFeature:_ClientPlaySpotSelfMontage(SpotData)
  if not SpotData or not slua.isValid(self.uCurShowSpotActor) then
    return
  end
  local sMontagePath
  if not SpotData.SpotSelfMontagePath or SpotData.SpotSelfMontagePath == "" then
    if self.nRandomAnimIndex and self.nRandomAnimIndex > 0 and self.uCurShowSpotActor.GetRandomSpotSelfAnimByIndex then
      sMontagePath = self.uCurShowSpotActor:GetRandomSpotSelfAnimByIndex(self.nRandomAnimIndex)
    end
  else
    sMontagePath = SpotData.SpotSelfMontagePath
  end
  if self.LoadSpotSelfMontageHandle or sMontagePath == nil then
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_ClientPlaySpotSelfMontage LoadSpotSelfMontageHandle is not nil or sMontagePath == nil")
    return
  end
  self.LoadSpotSelfMontageHandle = self:AsyncLoadAsset(sMontagePath, function(uMontage)
    self.LoadSpotSelfMontageHandle = nil
    if not slua.isValid(uMontage) then
      return
    end
    if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
      return
    end
    if not slua.isValid(self.uCurShowSpotActor) then
      return
    end
    local uSpotComp = self.uCurShowSpotActor:GetSpotSceneComponent(self.nCurSpotIndex)
    if not slua.isValid(uSpotComp) or not uSpotComp.GetAnimInstance then
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_ClientPlaySpotSelfMontage uSpotComp invalid")
      return
    end
    local uAnimInst = uSpotComp:GetAnimInstance()
    if not slua.isValid(uAnimInst) then
      return
    end
    if not uAnimInst:Montage_IsPlaying(uMontage) then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      uAnimInst:Montage_Play(uMontage, 1, EMontagePlayReturnType.MontageLength, 0)
      self.uClientCacheSpotComp = uSpotComp
      self.uClientSpotSelfMontageAsset = uMontage
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_ClientPlaySpotSelfMontage play:" .. tostring(sMontagePath))
    end
  end)
end
function PlayerCharacterGeneralShowSpotFeature:_ClientStopSpotSelfMontage()
  if self.LoadSpotSelfMontageHandle then
    self:CancelAsyncLoad(self.LoadSpotSelfMontageHandle)
    self.LoadSpotSelfMontageHandle = nil
  end
  if self.uClientSpotSelfMontageAsset == nil then
    return
  end
  if slua.isValid(self.uClientCacheSpotComp) and self.uClientCacheSpotComp.GetAnimInstance then
    local uAnimInst = self.uClientCacheSpotComp:GetAnimInstance()
    if slua.isValid(uAnimInst) and uAnimInst:Montage_IsPlaying(self.uClientSpotSelfMontageAsset) then
      uAnimInst:Montage_Stop(0, self.uClientSpotSelfMontageAsset)
    end
  end
  self.uClientCacheSpotComp = nil
  self.uClientSpotSelfMontageAsset = nil
end
function PlayerCharacterGeneralShowSpotFeature:PlaySpotAudio(sAudioPath)
  self:StopSpotAudio()
  if not sAudioPath or self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
    return
  end
  if not slua.isValid(self.uCurShowSpotActor) then
    return
  end
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioByActorAsync(sAudioPath, self.uCurShowSpotActor, function(PlayingID)
    if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
      local audio_util = require("client.common.audio_util")
      audio_util.StopSound(PlayingID)
      print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:PlaySpotAudio. nShowSpotState ~= EGeneralShowSpotState.PlayShow StopAudioID: " .. tostring(PlayingID))
      return
    end
    self:StopSpotAudio()
    self.nPlayingSpotAudioID = PlayingID
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:PlaySpotAudio. Play Audio ID: " .. tostring(self.nPlayingSpotAudioID))
  end, true)
end
function PlayerCharacterGeneralShowSpotFeature:StopSpotAudio()
  if self.nPlayingSpotAudioID and self.nPlayingSpotAudioID ~= 0 then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.nPlayingSpotAudioID)
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:StopSpotAudio. Stop Audio: " .. tostring(self.nPlayingSpotAudioID))
    self.nPlayingSpotAudioID = nil
  end
end
function PlayerCharacterGeneralShowSpotFeature:_AddClientScreenMark()
  if not Client then
    return
  end
  if not self.Owner then
    return
  end
  if self.Owner.Role ~= ENetRole.ROLE_AutonomousProxy then
    return
  end
  if self._ClientScreenMarkInstIDs then
    return
  end
  if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
    return
  end
  if not slua.isValid(self.uCurShowSpotActor) or not self.uCurShowSpotActor.GetBubbleScreenMarkConfig then
    return
  end
  local BubbleScreenMarkConfig = self.uCurShowSpotActor:GetBubbleScreenMarkConfig()
  if not BubbleScreenMarkConfig then
    return
  end
  local uMarkLoc = self.uCurShowSpotActor:K2_GetActorLocation()
  local InstIDs = {}
  for nScreenMarkID, Cfg in pairs(BubbleScreenMarkConfig) do
    if type(nScreenMarkID) == "number" and 0 < nScreenMarkID then
      local nInstID = InGameMarkTools.ClientAddMapMark(nScreenMarkID, uMarkLoc, nScreenMarkID, "", UEnums.EAddMarkFlag.EAMF_Screen, self.uCurShowSpotActor)
      if nInstID then
        InstIDs[#InstIDs + 1] = nInstID
        print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_AddClientScreenMark MarkID:" .. tostring(nScreenMarkID) .. " InstID:" .. tostring(nInstID))
      else
        print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_AddClientScreenMark failed MarkID:" .. tostring(nScreenMarkID))
      end
    end
  end
  if 0 < #InstIDs then
    self._ClientScreenMark  end
end
function PlayerCharacterGeneralShowSpotFeature:_RemoveClientScreenMark()
  if not Client then
    return
  end
  if not self._ClientScreenMarkInstIDs then
    return
  end
  for _, nInstID in ipairs(self._ClientScreenMarkInstIDs) do
    print(bWriteLog and "PlayerCharacterGeneralShowSpotFeature:_RemoveClientScreenMark InstID:" .. tostring(nInstID))
    InGameMarkTools.HideMapMark(nInstID)
  end
  self._ClientScreenMarkInstIDs = nil
end
function PlayerCharacterGeneralShowSpotFeature:HandleOnAvatarAllMeshLoaded()
  if not Client then
    return
  end
  if self.nShowSpotState ~= EGeneralShowSpotState.PlayShow then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterGeneralShowSpotFeature:HandleOnAvatarAllMeshLoaded replay montage, SpotIndex:%s PlayerKey:%s", tostring(self.nCurSpotIndex), self.Owner and self.Owner.PlayerKey or 0))
  self:_ClientStopSpotSelfMontage()
  self.uClientMontageAsset = nil
  self.uClientSpotSelfMontageAsset = nil
  self.uClientCacheSpotComp = nil
  if self.LoadAnimAssetHandle then
    self:CancelAsyncLoad(self.LoadAnimAssetHandle)
    self.LoadAnimAssetHandle = nil
  end
  if self.LoadSpotSelfMontageHandle then
    self:CancelAsyncLoad(self.LoadSpotSelfMontageHandle)
    self.LoadSpotSelfMontageHandle = nil
  end
  self:CheckCanPlayMontage()
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerCharacterGeneralShowSpotFeature = class(CFeatureBase, nil, PlayerCharacterGeneralShowSpotFeature)
return CPlayerCharacterGeneralShowSpotFeature