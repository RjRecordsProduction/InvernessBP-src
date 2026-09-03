local UKismetSystemLibrary = import("KismetSystemLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local PlayerPetSpectatorComponent = {
  ServerRPC = {},
  ClientRPC = {}
}
PlayerPetSpectatorComponent.ServerRPC.ServerDoTransform = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerPetSpectatorComponent.ClientRPC.ClientRPC_ServerDoTransformDone = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerPetSpectatorComponent.ClientRPC.ClientDoRecover = {Reliable = true}
PlayerPetSpectatorComponent.ServerRPC.ServerSetSpectatingPetVisible = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
PlayerPetSpectatorComponent.ServerRPC.ServerTeleportToPlayer = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerPetSpectatorComponent.ClientRPC.ClientDoTeleportToPlayer = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
local TransformState = {None = 1, Transformed = 2}
local RecoverType = {
  Normal = 1,
  OwnerReconnect = 2,
  ReSpawn = 3,
  Finish = 4
}
local CONST_TELEPORT_INTERVAL = 10
local CanUsePetInfo = require("GameLua.Mod.Library.GamePlay.Config.PetInfoDefine")
function PlayerPetSpectatorComponent:ctor()
  print(bWriteLog and "PlayerPetSpectatorComponent:ctor")
  self.InPetSpectator = false
  self.nTransformState = TransformState.None
  self.nFocusPlayerKey = 0
  self.uFocusPlayerState = nil
  self.uSpecCharacter = nil
  self.nLastTransformTime = 0.0
  self.nTransformInterval = 4
  self.SpectatorPetID = 50000
  self.nLastTeleportTime = 0.0
end
function PlayerPetSpectatorComponent:GetLifetimeReplicatedProps()
  print(bWriteLog and "PlayerPetSpectatorComponent:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "InPetSpectator",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "SpectatorPetID",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    }
  }
end
function PlayerPetSpectatorComponent:OnRep_InPetSpectator()
  print(bWriteLog and "PlayerPetSpectatorComponent:OnRep_InPetSpectator " .. tostring(self.InPetSpectator))
  local uPlayerController = self:GetOwner()
  if slua.isValid(uPlayerController) then
    uPlayerController:SetIsInPetSpectator(self.InPetSpectator)
    if not self.InPetSpectator then
      self:OnRep_PetSpectatorPawn()
    else
      self.bSendPossessONPetUIEvent = true
      uPlayerController.CharacterTouchMove = true
      EventSystem:postEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET)
      self:TrySetViewTargetOnPet()
    end
  end
end
function PlayerPetSpectatorComponent:_PostConstruct()
  PlayerPetSpectatorComponent.__super._PostConstruct(self)
  print(bWriteLog and "PlayerPetSpectatorComponent:_PostConstruct")
  local uPlayerController = self:GetOwner()
  if slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:_PostConstruct 1")
    self:AddControlEvent(uPlayerController, "PlayerControllerReconnectedDelegate", function()
      print(bWriteLog and "PlayerPetSpectatorComponent:_PostConstruct 2")
      self:OnOwnerReconnected()
    end)
    self:AddControlEvent(uPlayerController, "OnRepTeammateChange", function()
      self:OnRepTeammateChange()
    end)
  end
end
function PlayerPetSpectatorComponent:ReceiveBeginPlay()
  PlayerPetSpectatorComponent.__super.ReceiveBeginPlay(self)
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    local uPlayerController = self:GetOwner()
    if slua.isValid(uPlayerController) then
      print(bWriteLog and "PlayerPetSpectatorComponent:ReceiveBeginPlay Bind Delegates")
    end
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_BATTLE_DS_FINISHED, function()
      print(bWriteLog and "PlayerPetSpectatorComponent EVENTID_BATTLE_DS_FINISHED")
      if slua.isValid(self.PetSpectatorPawn) and self.InPetSpectator and slua.isValid(uPlayerController) then
        local Location = self.PetSpectatorPawn:K2_GetActorLocation()
        uPlayerController:K2_SetActorLocation(Location, false, nil, false)
      end
      print(bWriteLog and "PlayerPetSpectatorComponent EVENTID_BATTLE_DS_FINISHED over")
    end)
    local UGameplayStatics = import("GameplayStatics")
    local GameMode = UGameplayStatics.GetGameMode(self)
    if slua.isValid(GameMode) then
      self:AddControlEvent(GameMode, "SendTeamBattleResult", function(nInTeamID, sInReason)
        if slua.isValid(uPlayerController) and nInTeamID and nInTeamID == uPlayerController.TeamID and sInReason ~= "win" then
          print(bWriteLog and "PlayerPetSpectatorComponent EVENTID_TEAM_BATTLE_RESULT")
          if slua.isValid(self.PetSpectatorPawn) and self.InPetSpectator and slua.isValid(uPlayerController) then
            local Location = self.PetSpectatorPawn:K2_GetActorLocation()
            uPlayerController:K2_SetActorLocation(Location, false, nil, false)
            self:ClientDoRecover()
            self:ExitPetSpectator(RecoverType.Finish)
          end
          print(bWriteLog and "PlayerPetSpectatorComponent EVENTID_TEAM_BATTLE_RESULT over")
        end
      end)
    end
  else
    print(bWriteLog and "PlayerPetSpectatorComponent:ReceiveBeginPlay postEvent EVENTID_COMPONENT_BEGINPLAY")
    EventSystem:postEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_COMPONENT_BEGINPLAY)
    self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_POSSESSONPET_CLIENT_QUITSPEC, function()
      self:TrySetViewTargetOnPet()
    end)
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      local SpectatingPetVisible = SettingSubsystem:GetUserSettings_Bool("bSpectatingPetVisible")
      print(bWriteLog and "PlayerPetSpectatorComponent:ReceiveBeginPlay SettingSubsystem bSpectatingPetVisible" .. tostring(SpectatingPetVisible))
      self:ServerSetSpectatingPetVisible(SpectatingPetVisible)
      self.bTeammatePetShow = SpectatingPetVisible
      SettingSubsystem:RegisterUserSettingsDelegate_Bool("bSpectatingPetVisible", function(bSpectatingPetVisible)
        self:ServerSetSpectatingPetVisible(bSpectatingPetVisible)
        self.bTeammatePetShow = bSpectatingPetVisible
        EventSystem:postEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_SETTIN_PETSPECTATORVISABLE, self.bTeammatePetShow)
      end)
    end
  end
end
function PlayerPetSpectatorComponent:TrySetViewTargetOnPet()
  print(bWriteLog and "PlayerPetSpectatorComponent:TrySetViewTargetOnPet")
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    return
  end
  if not slua.isValid(self.PetSpectatorPawn) or not uPlayerController:IsInPetSpectator() then
    return
  end
  local target = uPlayerController:GetViewTarget()
  if slua.isValid(uPlayerController:GetViewTarget()) and self.PetSpectatorPawn ~= uPlayerController:GetViewTarget() or not slua.isValid(uPlayerController:GetViewTarget()) then
    local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
    uPlayerController:SetViewTargetWithBlend(self.PetSpectatorPawn, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
  end
end
function PlayerPetSpectatorComponent:ServerSetSpectatingPetVisible(bVisable)
  self.bTeammatePetShow = bVisable
end
function PlayerPetSpectatorComponent:ClientDoRecover()
  print(bWriteLog and "PlayerPetSpectatorComponent ClientDoRecover Server Call")
  if self.InPetSpectator then
    self:DoRecover()
    local uPlayerController = self:GetOwner()
    if not slua.isValid(uPlayerController) then
      return
    end
    if slua.isValid(uPlayerController.PlayerState) then
      uPlayerController.PlayerState:K2_SetActorLocation(uPlayerController:K2_GetActorLocation(), false, nil, false)
      print(bWriteLog and "uPlayerController.PlayerStateuPlayerController.PlayerState")
    end
  end
end
function PlayerPetSpectatorComponent:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "PlayerPetSpectatorComponent:ReceiveEndPlay")
  self.uFocusPlayerState = nil
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    local uPlayerController = self:GetOwner()
    if slua.isValid(uPlayerController) then
      self:RemoveControlEvent(uPlayerController, "OnPlayerGotoSpectatingDelegate")
      print(bWriteLog and "PlayerPetSpectatorComponent:ReceiveEndPlay Unbind Delegates")
    end
  end
  PlayerPetSpectatorComponent.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerPetSpectatorComponent:OnOwnerRespawned()
  print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerRespawned")
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    local uPlayerController = self:GetOwner()
    if not slua.isValid(uPlayerController) then
      return
    end
    self.bSendPossessONPetUIEvent = false
    uPlayerController.CharacterTouchMove = true
    self:RemoveControlEvent(uPlayerController, "PlayerControllerRespawnedDelegate")
  end
end
function PlayerPetSpectatorComponent:PerRespawnClearOtherPawn()
  self:ExitPetSpectator(RecoverType.ReSpawn)
end
function PlayerPetSpectatorComponent:OnOwnerReconnected()
  print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerReconnected222")
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerReconnected uPlayerController invalid")
    return
  end
  print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerReconnected222" .. tostring(slua.isValid(uPlayerController.DeadTombBox)))
  if self.InPetSpectator then
    uPlayerController.bAutoManageActiveCameraTarget = false
    local back = self:DoRecover()
    if back < 0 then
      self.bReconnectedGotoSpFail = true
    else
      self.bReconnectedGotoSpFail = false
    end
  elseif uPlayerController:IsInSpectating() and CGameState and CGameState.IsShowDeadBox then
    uPlayerController.bAutoManageActiveCameraTarget = false
    print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerReconnected uPlayerController.bAutoManageActiveCameraTarget = false")
  end
end
function PlayerPetSpectatorComponent:OnRepTeammateChange()
  if self.bReconnectedGotoSpFail and self.InPetSpectator then
    local back = self:DoRecover()
    if back < 0 then
      self.bReconnectedGotoSpFail = true
    else
      self.bReconnectedGotoSpFail = false
    end
  else
    self.bReconnectedGotoSpFail = false
  end
end
function PlayerPetSpectatorComponent:OnOwnerGotoSpectating()
  print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerGotoSpectating")
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerGotoSpectating uPlayerController invalid")
    return
  end
  print(bWriteLog and "PlayerPetSpectatorComponent:OnOwnerGotoSpectating transformstate" .. self.nTransformState)
  self:ExitPetSpectator(RecoverType.Normal)
end
function PlayerPetSpectatorComponent:CanCurrentPetGotoPetSpectator(PetID)
  if PetID == 50000 then
    return true
  end
  local petInfo = self:GetPetInfo(PetID)
  if petInfo and CanUsePetInfo[petInfo.PetId] then
    return true
  else
    return false
  end
end
function PlayerPetSpectatorComponent:SetPlayerId(nInPlayerId)
  self.nPlayerId = nInPlayerId
end
function PlayerPetSpectatorComponent:ServerDoTransform(PetID)
  print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform PetID = ", PetID)
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform not ds")
    return
  end
  if self.nTransformState ~= TransformState.None then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform nTransformState invalid")
    return
  end
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform uPlayerController invalid")
    return
  end
  if not uPlayerController.bIsSpectating then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform bIsSpectating false")
    self:CanntChange()
    return
  end
  if CGameMode.RoomType == "match" or CGameMode.RoomType == "allstar" then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform CGameMode.RoomTyp" .. tostring(CGameMode.RoomTyp))
    self:CanntChange()
    return
  end
  local nCurTime = CGameState:GetServerWorldTimeSeconds()
  if nCurTime < self.nLastTransformTime + self.nTransformInterval then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform time invalid")
    return
  end
  self.nLastTransformTime = nCurTime
  if uPlayerController.IsFriendOrEnemySpectator and uPlayerController:IsFriendOrEnemySpectator() then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform invalid Spectating type")
    self:CanntChange()
    return
  end
  if not self:CanCurrentPetGotoPetSpectator(PetID) then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform \229\189\147\229\137\141\229\174\160\231\137\169\231\177\187\229\158\139\230\151\160\230\179\149\232\191\155\229\133\165\229\174\160\231\137\169\232\167\130\230\136\152")
    self:CanntChange()
    return
  end
  if not uPlayerController.IsBREnterPlayerController or not uPlayerController:IsBREnterPlayerController() then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform not brmode")
    self:CanntChange()
    return
  end
  local uTeamMateCharacter = uPlayerController:GetCurPawn()
  if slua.isValid(uTeamMateCharacter) then
    local uTeamMatePC = uTeamMateCharacter:GetPlayerControllerSafety()
    if not slua.isValid(uTeamMatePC) then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform uTeamMatePC nil")
      self:CanntChange()
      return
    end
    local PCState = uTeamMatePC:GetCurrentStateType()
    local EStateType = import("EStateType")
    if PCState == EStateType.State_InPlane or PCState == EStateType.State_InExPlane or PCState == EStateType.State_Launch or PCState == EStateType.State_ParachuteJump or PCState == EStateType.State_ParachuteOpen or PCState == EStateType.State_Dead then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform InPlaneCannt Change PetSpectator")
      self:CanntChange()
      return
    end
    local EPawnState = import("EPawnState")
    if uTeamMateCharacter:HasState(EPawnState.ControlUnmannedVehicle) then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform  Change PetSpectator pawnstate")
      self:CanntChange()
      return
    end
    if uTeamMateCharacter.CannotChangeIntoPetSpectator and uTeamMateCharacter:CannotChangeIntoPetSpectator() then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerDoTransform  CannotChangeIntoPetSpectator")
      self:CanntChange()
      return
    end
  end
  self:GoToPetSpectator(PetID)
  self:ClientRPC_ServerDoTransformDone(PetID)
end
function PlayerPetSpectatorComponent:ClientDoTeleportToPlayer(nTeleportCD)
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:ClientDoTeleportToPlayer uPlayerController invalid")
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_PET_SPECTATOR_TELEPORT, nTeleportCD)
end
function PlayerPetSpectatorComponent:ClientRPC_ServerDoTransformDone(PetID)
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:ClientRPC_ServerDoTransformDone uPlayerController invalid")
    return
  end
  print(bWriteLog and "PlayerPetSpectatorComponent:ClientRPC_ServerDoTransformDone PetID=" .. PetID)
  uPlayerController:QuitSpectatingReSetData()
end
function PlayerPetSpectatorComponent:CanntChange()
  print(bWriteLog and "PlayerPetSpectatorComponent:CanntChange")
  local uPlayerController = self:GetOwner()
  if slua.isValid(uPlayerController) then
    uPlayerController:DisplayGameTipWithMsgID(49354)
  end
end
function PlayerPetSpectatorComponent:DoRecover()
  print(bWriteLog and "PlayerPetSpectatorComponent:DoRecover")
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent:DoRecover uPlayerController invalid")
    return 0
  end
  local back = uPlayerController:GotoSpectating(self.nPlayerId or 0)
  print(bWriteLog and "PlayerPetSpectatorComponent:DoRecover " .. tostring(back))
  return back
end
function PlayerPetSpectatorComponent:GetCharacter()
  if self.uEnterCharacter ~= nil then
    return self.uEnterCharacter
  end
  if not slua.isValid(self:GetOwner()) then
    printf(bWriteLog and "PlayerPetSpectatorComponent GetCharacter self:GetOwner() nil")
    return nil
  end
  local uCharacter = self:GetOwner():GetPlayerCharacterSafety()
  return uCharacter
end
function PlayerPetSpectatorComponent:GetPlayerId()
  return self.nPlayerId or 0
end
function PlayerPetSpectatorComponent:GetPetInfo(PetID)
  if slua.isValid(self:GetOwner()) then
    if PetID and self:GetOwner().AdditionalPetInfo then
      for k, v in pairs(self:GetOwner().AdditionalPetInfo) do
        if PetID == v.PetID then
          return v
        end
      end
    end
    if self:GetOwner().InitialPetInfo then
      return self:GetOwner().InitialPetInfo
    end
  end
  print(bWriteLog and "PlayerPetSpectatorComponent GetPetInfo  nil")
  return nil
end
function PlayerPetSpectatorComponent:GoToPetSpectator(PetID)
  local Controller = self:GetOwner()
  if not slua.isValid(Controller) then
    print(bWriteLog and "PlayerPetSpectatorComponent GotoaPetSpectator Controller nil")
    return
  end
  local uCurPawn = Controller:GetCurPawn()
  if not slua.isValid(uCurPawn) then
    print(bWriteLog and "PlayerPetSpectatorComponent GotoaPetSpectator uCurPawn nil")
    return
  end
  self:SwitchCameraMode(true)
  local UGameplayStatics = import("GameplayStatics")
  local SpawnTransform = FTransform()
  local Location = uCurPawn:K2_GetActorLocation()
  Location = FVector(Location.X, Location.Y, Location.Z)
  SpawnTransform:SetTranslationAndScale3D(Location, FVector(1, 1, 1))
  local uClass = slua.loadClass("/Game/BluePrints/PET/PetSpectator/PetSpectatorCharacterBase.PetSpectatorCharacterBase")
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  if slua.isValid(self.PetSpectatorPawn) then
    self.PetSpectatorPawn:OnRespawned()
    self.PetSpectatorPawn.DSOnRecycled = false
    self.PetSpectatorPawn:K2_SetActorLocation(Location, false, nil, false)
  else
    self.PetSpectatorPawn = self:SpawnPetSpectator(uClass, SpawnTransform, Controller)
  end
  if not slua.isValid(self.PetSpectatorPawn) then
    print(bWriteLog and "PlayerPetSpectatorComponent GotoaPetSpectator PetSpectatorPawn nil")
    return
  end
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
  local ResolveParams = FResolvePenetrationParams()
  slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCurPawn)
  slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCurPawn)
  self.PetSpectatorPawn.BornMaxForwardDis = 300
  if uCurPawn.GetCurrentVehicle then
    local uVehicle = uCurPawn:GetCurrentVehicle()
    if slua.isValid(uVehicle) then
      slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uVehicle)
      slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uVehicle)
    end
    self.PetSpectatorPawn.BornMaxForwardDis = 600
  end
  local backin
  local MoveRight, LocationBack = self.PetSpectatorPawn:SpectatorPetBornRightPostion(uCurPawn, ResolveParams, backin)
  if MoveRight then
    local distance = FVector.DistXY(LocationBack, Location)
    if 10000 < distance then
      MoveRight = false
    end
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator distance:" .. tostring(distance) .. " LocationBack:" .. LocationBack:ToString() .. " Location:" .. Location:ToString())
  end
  self.PetSpectatorPawn:SetBase(nil, "", true)
  if MoveRight then
    self.PetSpectatorPawn:K2_SetActorLocation(LocationBack, false, nil, false)
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator LocationBack:" .. LocationBack:ToString())
  else
    self.PetSpectatorPawn:K2_SetActorLocation(Location, false, nil, false)
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator Location:" .. Location:ToString())
  end
  local UKismetMathLibrary = import("KismetMathLibrary")
  local lookAtRotation = UKismetMathLibrary.FindLookAtRotation(self.PetSpectatorPawn:K2_GetActorLocation(), Location)
  lookAtRotation.Yaw = FRotator.ClampAxis(lookAtRotation.Yaw)
  lookAtRotation.Pitch = 0
  self.PetSpectatorPawn:K2_SetActorRotation(lookAtRotation, false)
  if slua.isValid(self.PetSpectatorPawn.SpringArm) then
    self.PetSpectatorPawn.SpringArm.bDoCollisionTest = true
  end
  self.PetSpectatorPawn:OnPostCreate(uCurPawn)
  local PetInfo
  if PetID == 50000 then
    local FGameModePlayerPetInfo = import("GameModePlayerPetInfo")
    PetInfo = FGameModePlayerPetInfo()
    PetInfo.PetId = 50000
    PetInfo.PetLevel = 1
    PetInfo.PetCfgId = PetInfo.PetId * 10000 + PetInfo.PetLevel
    local MiniTVDataUtil = require("GameLua.Activity.Commercialize.GamePlay.MiniTV.MiniTVDataUtil")
    local UID = Controller.UID
    if UID then
      local MiniTVDressID = MiniTVDataUtil:GetPlayerMiniTVDressID(UID) or 0
      if MiniTVDressID ~= 0 then
        PetInfo.PetAvatarList:Add(MiniTVDressID)
      end
    end
  else
    PetInfo = self:GetPetInfo(PetID)
  end
  self.Spectator  if slua.isValid(self.PetSpectatorPawn) and PetInfo and slua.isValid(self.PetSpectatorPawn.PetSpectatorAvatarComponent_BP) then
    self.PetSpectatorPawn.    local FPetLevelInfo = import("/Script/ShadowTrackerExtra.PetLevelInfo")
    local UFPetLevelInfo = FPetLevelInfo()
    UFPetLevelInfo.PetId = PetInfo.PetId
    UFPetLevelInfo.PetLevel = PetInfo.PetLevel
    self.PetSpectatorPawn.PetLevelInfo = UFPetLevelInfo
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator PetID: ", PetInfo.PetId)
    self.PetSpectatorPawn.PetSpectatorAvatarComponent_BP:CheckToEquipDefaultAvatar(PetInfo.PetAvatarList)
    for key, value in pairs(PetInfo.PetAvatarList) do
      local itemDefineID = FItemDefineID(self.PetSpectatorPawn.PetSpectatorAvatarComponent_BP.ItemType, tostring(value))
      self.PetSpectatorPawn.PetSpectatorAvatarComponent_BP:HandleEquipItem(itemDefineID, FAvatarCustomDefault())
    end
    self.PetSpectatorPawn:SetPawnSize()
    local Pawn = Controller:K2_GetPawn()
    self.nFocusPlayerKey = uCurPawn.PlayerKey
    self.uFocusPlayerState = Controller:GetSpecOrDemoPlayerState()
    self.uSpecCharacter = uCurPawn
    self:AddControlEvent(uCurPawn, "OnDeathDelegate", function()
      if slua.isValid(Controller) and slua.isValid(Controller.PlayerState) then
        local TeammatePlayerState = Controller.PlayerState:GetTeamMatePlayerStateList({}, true)
        local CanChangeOtherTeamMate = false
        for key, Teammate in pairs(TeammatePlayerState) do
          if slua.isValid(Teammate) and Teammate:IsAlive() then
            CanChangeOtherTeamMate = true
          end
        end
        if not CanChangeOtherTeamMate then
          print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator alldie nochange")
          return
        end
      end
      print(bWriteLog and "PlayerPetSpectatorComponent:OnDeathDelegate ClientDoRecover")
      self:ClientDoRecover()
    end)
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator nFocusPlayerKey " .. self.nFocusPlayerKey)
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator - Delayed possess execution")
    if not slua.isValid(Controller) then
      print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator - Controller is invalid after delay")
      return
    end
    if not slua.isValid(self.PetSpectatorPawn) then
      print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator - PetSpectatorPawn is invalid after delay")
      return
    end
    Controller:QuitSpectating()
    Controller:Possess(self.PetSpectatorPawn)
    self.InPetSpectator = true
    Controller:SetIsInPetSpectator(self.InPetSpectator)
    self:OnTransformFinish()
    self:ForceNetUpdate()
    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    if not self.PlayerHaveGameRport then
      self.PlayerHaveGameRport = true
      if DSCommonTLogSubsystem then
        DSCommonTLogSubsystem:AddCommonTLog(250, 1, false)
      end
    end
    if DSCommonTLogSubsystem and slua.isValid(Controller.PlayerState) then
      DSCommonTLogSubsystem:AddPlayerCommonTLogData(Controller.PlayerState.UID, 164, tostring(PetInfo.PetId), false)
    end
  end
end
function PlayerPetSpectatorComponent:ExitPetSpectator(InType)
  print(bWriteLog and "PlayerPetSpectatorComponent ExitPetSpectator " .. tostring(InType))
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent ExitPetSpectator uPlayerController nil")
    return
  end
  if not self.InPetSpectator then
    print(bWriteLog and "PlayerPetSpectatorComponent:ExitPetSpectator invalid transformstate " .. self.nTransformState)
    return
  end
  local utility = require("common.utility")
  xpcall(self.SafeExit, utility.ErrorMessageHandler, self, InType)
  self.nTransformState = TransformState.None
  self.RecoverPlayerId = -1
  self.nFocusPlayerKey = 0
  self.uFocusPlayerState = nil
  self.InPetSpectator = false
  uPlayerController:SetIsInPetSpectator(self.InPetSpectator)
  self:SwitchCameraMode(false)
  self:OnRecoverFinish()
  self:ForceNetUpdate()
  print(bWriteLog and "PlayerPetSpectatorComponent ExitPetSpectator Finish")
end
function PlayerPetSpectatorComponent:SafeExit(InType)
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerPetSpectatorComponent ExitPetSpectator uPlayerController2 nil")
    return
  end
  local LastCharacter = self:GetCharacter()
  local CurrentPawn = uPlayerController:K2_GetPawn()
  local CurrentViewTarget = uPlayerController:GetViewTarget()
  if slua.isValid(LastCharacter) then
    if not slua.isValid(CurrentPawn) or CurrentPawn ~= LastCharacter then
      uPlayerController:UnPossess()
      uPlayerController:K2_SetPawn(LastCharacter)
    end
  else
    uPlayerController:UnPossess()
  end
  if slua.isValid(CurrentViewTarget) and slua.isValid(self.PetSpectatorPawn) and CurrentViewTarget ~= self.PetSpectatorPawn then
    uPlayerController:SetViewTargetTest(CurrentViewTarget)
  end
  if slua.isValid(self.PetSpectatorPawn) then
    if InType >= RecoverType.ReSpawn then
      self.PetSpectatorPawn:K2_DestroyActor()
      self.PetSpectatorPawn = nil
    else
      self.PetSpectatorPawn:OnRecycled()
      self.PetSpectatorPawn.DSOnRecycled = true
    end
  end
  if slua.isValid(self.uSpecCharacter) then
    self:RemoveControlEvent(self.uSpecCharacter, "OnDeathDelegate")
  end
end
function PlayerPetSpectatorComponent:OnTransformFinish()
  self.nTransformState = TransformState.Transformed
  self.nLastTransformTime = CGameState:GetServerWorldTimeSeconds()
  local uPlayerController = self:GetOwner()
  if slua.isValid(uPlayerController) then
    uPlayerController:BecomeAGhost(true)
  end
  print(bWriteLog and "PlayerPetSpectatorComponent OnTransformFinish nLastTransformTime" .. self.nLastTransformTime)
end
function PlayerPetSpectatorComponent:OnRecoverFinish()
  print(bWriteLog and "PlayerPetSpectatorComponent OnRecoverFinish")
  local uPlayerController = self:GetOwner()
  if slua.isValid(uPlayerController) then
    uPlayerController:BecomeAGhost(false)
  end
end
function PlayerPetSpectatorComponent:SwitchCameraMode(bEnter)
  if self.bLocalBindCameraSwitch then
    local uCharacter = self:GetCharacter()
    local EPawnState = import("EPawnState")
    if slua.isValid(uCharacter) then
      if bEnter then
        uCharacter.IsNetFPP = false
        uCharacter:SetPawnStateDisabled(EPawnState.SwitchPP, true)
      else
        uCharacter.IsNetFPP = false
        uCharacter:ResetPawnStateDisabled(EPawnState.SwitchPP)
      end
    end
  end
end
function PlayerPetSpectatorComponent:IsClientViewCharacter()
  local ENetRole = import("ENetRole")
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local currentPawn = uPlayerController:GetCurPawn()
  if not slua.isValid(currentPawn) then
    return false
  end
  if not currentPawn.IsLocalControlOrView then
    return false
  end
  if currentPawn:IsLocalControlOrView() then
    return true
  end
  if currentPawn.Role == ENetRole.ROLE_Authority then
    return false
  end
  if uPlayerController.IsSpectator == nil or uPlayerController.IsDemoPlaySpectator == nil then
    return false
  end
  local uViewTarget = uPlayerController:GetViewTarget()
  local uCarryBackComp = currentPawn:GetCarryBackComp()
  if uCarryBackComp and uViewTarget == uCarryBackComp.CarryBackCharacter then
    return true
  end
  return false
end
function PlayerPetSpectatorComponent:OnRep_PetSpectatorPawn()
  print(bWriteLog and "OnRep_PetSpectatorPawn OnPlayerQuitSpectating")
  if not slua.isValid(self.PetSpectatorPawn) or not self.InPetSpectator then
    local uPlayerController = self:GetOwner()
    EventSystem:postEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_UNPOSSESSONPET)
    if slua.isValid(uPlayerController) and self.bSendPossessONPetUIEvent then
      self.bSendPossessONPetUIEvent = false
      if uPlayerController:IsInSpectating() then
        uPlayerController.CharacterTouchMove = false
        local currentPawn = uPlayerController:GetCurPawn()
        if slua.isValid(currentPawn) and currentPawn.GetIsFPP and currentPawn:GetIsFPP() then
          currentPawn.FPPSpringArm:SetActive(true, true)
          currentPawn.ObserverCameraFPPMode:SetActive(true, true)
          print(bWriteLog and "OnRep_PetSpectatorPawn OnPlayerQuitSpectating  currentPawn.ObserverCameraFPPMode")
        end
        local ESTEScopeType = import("ESTEScopeType")
        local ESTEScopeState = import("ESTEScopeState")
        local ViewTarget = uPlayerController:GetViewTarget()
        local selfTarget = self:GetCharacter()
        if slua.isValid(ViewTarget) and ViewTarget ~= selfTarget and ViewTarget.GetFPPComp and slua.isValid(ViewTarget:GetFPPComp()) and ViewTarget:GetFPPComp():GetCurrentESTEScopeState() == ESTEScopeState.ScopeIn then
          ViewTarget:ScopeOut(ESTEScopeType.Normal)
          ViewTarget:ScopeIn(ESTEScopeType.Normal)
        end
      end
    end
  else
    if slua.isValid(self.PetSpectatorPawn.SpringArm) then
      self.PetSpectatorPawn.SpringArm.bDoCollisionTest = true
    end
    local uPlayerController = self:GetOwner()
    if slua.isValid(uPlayerController) then
      self:AddControlEvent(uPlayerController, "PlayerControllerRespawnedDelegate", function()
        self:OnOwnerRespawned()
      end)
    end
    self:TrySetViewTargetOnPet()
    if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.STExtraUnderWaterEffectComp) then
      print(bWriteLog and "PlayerPetSpectatorComponent:OnRep_PetSpectatorPawn open UnderWaterEffectComp")
      uPlayerController.STExtraUnderWaterEffectComp:SetComponentTickEnabled(true)
    end
  end
end
function PlayerPetSpectatorComponent:GetCurrentSpectatorPetID()
  return self.SpectatorPetID
end
function PlayerPetSpectatorComponent:ServerTeleportToPlayer(PlayerID)
  print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer PlayerID = ", PlayerID)
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer not ds")
    return
  end
  if CGameMode.RoomType == "match" or CGameMode.RoomType == "allstar" then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer CGameMode.RoomType" .. tostring(CGameMode.RoomTyp))
    self:CannotTeleport()
    return
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local StringUtil = require("common.string_util")
  if StringUtil.StrFind(ModType, "Egypt2") then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer - current mod is not support teleporting: " .. tostring(ModType))
    return
  end
  if not slua.isValid(self.PetSpectatorPawn) then
    return
  end
  local Controller = self:GetOwner()
  if not slua.isValid(Controller) then
    print(bWriteLog and "PlayerPetSpectatorComponent ServerTeleportToPlayer Controller nil")
    return
  end
  local nCurTime = CGameState:GetServerWorldTimeSeconds()
  if nCurTime < self.nLastTeleportTime + CONST_TELEPORT_INTERVAL then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer time invalid")
    return
  end
  self.nLastTeleportTime = nCurTime
  if Controller.IsFriendOrEnemySpectator and Controller:IsFriendOrEnemySpectator() then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer invalid Spectating type")
    self:CannotTeleport()
    return
  end
  if not Controller.IsBREnterPlayerController or not Controller:IsBREnterPlayerController() then
    print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer not brmode")
    self:CannotTeleport()
    return
  end
  local uCurPlayerState = Controller.PlayerState
  local uCurPawn
  if slua.isValid(uCurPlayerState) and uCurPlayerState.GetTeamMatePlayerStateList then
    local TeamMatePlayerStateList = uCurPlayerState:GetTeamMatePlayerStateList({}, true)
    for nIndex, TeammatePlayerState in pairs(TeamMatePlayerStateList) do
      if slua.isValid(TeammatePlayerState) and TeammatePlayerState.PlayerID == PlayerID and TeammatePlayerState.GetPlayerCharacter then
        uCurPawn = TeammatePlayerState:GetPlayerCharacter()
      end
    end
  end
  if not slua.isValid(uCurPawn) then
    print(bWriteLog and "PlayerPetSpectatorComponent ServerTeleportToPlayer uCurPawn nil")
    return
  end
  local uTeamMateCharacter = uCurPawn
  if slua.isValid(uTeamMateCharacter) then
    local uTeamMatePC = uTeamMateCharacter:GetPlayerControllerSafety()
    if not slua.isValid(uTeamMatePC) then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer uTeamMatePC nil")
      self:CannotTeleport()
      return
    end
    local PCState = uTeamMatePC:GetCurrentStateType()
    local EStateType = import("EStateType")
    if PCState == EStateType.State_InPlane or PCState == EStateType.State_InExPlane or PCState == EStateType.State_Launch or PCState == EStateType.State_ParachuteJump or PCState == EStateType.State_ParachuteOpen or PCState == EStateType.State_Dead then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer InPlaneCannt Change PetSpectator")
      self:CannotTeleport()
      return
    end
    local EPawnState = import("EPawnState")
    if uTeamMateCharacter:HasState(EPawnState.ControlUnmannedVehicle) then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer  Change PetSpectator pawnstate")
      self:CannotTeleport()
      return
    end
    if uTeamMateCharacter.CannotChangeIntoPetSpectator and uTeamMateCharacter:CannotChangeIntoPetSpectator() then
      print(bWriteLog and "PlayerPetSpectatorComponent:ServerTeleportToPlayer  CannotChangeIntoPetSpectator")
      self:CannotTeleport()
      return
    end
  end
  local SpawnTransform = FTransform()
  local Location = uCurPawn:K2_GetActorLocation()
  Location = FVector(Location.X, Location.Y, Location.Z)
  SpawnTransform:SetTranslationAndScale3D(Location, FVector(1, 1, 1))
  self.PetSpectatorPawn:K2_SetActorLocation(Location, false, nil, false)
  local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
  local ResolveParams = FResolvePenetrationParams()
  slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCurPawn)
  slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCurPawn)
  self.PetSpectatorPawn.BornMaxForwardDis = 300
  if uCurPawn.GetCurrentVehicle then
    local uVehicle = uCurPawn:GetCurrentVehicle()
    if slua.isValid(uVehicle) then
      slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uVehicle)
      slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uVehicle)
    end
    self.PetSpectatorPawn.BornMaxForwardDis = 600
  end
  local backin
  local MoveRight, LocationBack = self.PetSpectatorPawn:SpectatorPetBornRightPostion(uCurPawn, ResolveParams, backin)
  if MoveRight then
    local distance = FVector.DistXY(LocationBack, Location)
    if 10000 < distance then
      MoveRight = false
    end
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator distance:" .. tostring(distance) .. " LocationBack:" .. LocationBack:ToString() .. " Location:" .. Location:ToString())
  end
  if MoveRight then
    self.PetSpectatorPawn:K2_SetActorLocation(LocationBack, false, nil, false)
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator LocationBack:" .. LocationBack:ToString())
  else
    self.PetSpectatorPawn:K2_SetActorLocation(Location, false, nil, false)
    print(bWriteLog and "PlayerPetSpectatorComponent:GoToPetSpectator Location:" .. Location:ToString())
  end
  local UKismetMathLibrary = import("KismetMathLibrary")
  local lookAtRotation = UKismetMathLibrary.FindLookAtRotation(self.PetSpectatorPawn:K2_GetActorLocation(), Location)
  lookAtRotation.Yaw = FRotator.ClampAxis(lookAtRotation.Yaw)
  lookAtRotation.Pitch = 0
  self.PetSpectatorPawn:K2_SetActorRotation(lookAtRotation, false)
  if slua.isValid(self.PetSpectatorPawn) and self.PetSpectatorPawn.RPC_OnTeleportStart then
    self.PetSpectatorPawn:RPC_OnTeleportStart()
  end
  self:ClientDoTeleportToPlayer(CONST_TELEPORT_INTERVAL)
end
function PlayerPetSpectatorComponent:CannotTeleport()
  print(bWriteLog and "PlayerPetSpectatorComponent:CannotTeleport")
  local uPlayerController = self:GetOwner()
  if slua.isValid(uPlayerController) then
    uPlayerController:DisplayGameTipWithMsgID(87376)
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CCharacterCarryBackComponent = class(CActorComponentBase, nil, PlayerPetSpectatorComponent)
return CCharacterCarryBackComponent