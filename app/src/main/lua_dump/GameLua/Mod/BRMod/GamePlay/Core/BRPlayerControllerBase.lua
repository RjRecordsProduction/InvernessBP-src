local BRPlayerControllerBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
local BackpackUtils = import("BackpackUtils")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local EBattleItemUseReason = import("EBattleItemUseReason")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EMovementMode = import("EMovementMode")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local EParachuteState = import("EParachuteState")
function BRPlayerControllerBase:ctor()
  self.IsForceJump = false
end
function BRPlayerControllerBase:_PostConstruct()
  BRPlayerControllerBase.__super._PostConstruct(self)
end
function BRPlayerControllerBase:ReceiveBeginPlay()
  if Client then
    local ScriptHelperEngine = import("ScriptHelperEngine")
    if ScriptHelperEngine.IsLowMemoryDevice() and slua_GameFrontendHUD.CurrentMapName == "PUBG_Desert" then
      local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
      if LevelStreamingMgr then
        LevelStreamingMgr:SetStreamingDistanceScaleAllLevel(0.95)
      end
    end
  end
  self.InitialNetConsiderFrequency = self.Object.NetConsiderFrequency
  self.InitialNetUpdateFrequency = self.Object.NetUpdateFrequency
  self.InitialMinNetUpdateFrequency = self.Object.MinNetUpdateFrequency
  print(bWriteLog and "PlayerControllerBase:ReceiveBeginPlay NetConsiderFrequency:" .. tostring(self.Object.NetConsiderFrequency) .. ",NetUpdateFrequency:" .. tostring(self.Object.NetUpdateFrequency) .. ",MinNetUpdateFrequency:" .. tostring(self.Object.MinNetUpdateFrequency))
  BRPlayerControllerBase.__super.ReceiveBeginPlay(self)
  if CGameMode then
    if self:IsBREnterPlayerController() and not Client and CGameMode.RoomType ~= "match" and CGameMode.RoomType ~= "allstar" then
      local PetSpectatorComponent_C = import("/Game/BluePrints/PET/PetSpectator/BP_PlayerPetSpectatorComponent.BP_PlayerPetSpectatorComponent_C")
      Game:AddComponent(PetSpectatorComponent_C, self, "PlayerPetSpectatorComponent")
    end
    if self:CanUseTransform() and not self.BP_PlayerTransformComponent and not Client and CGameMode.RoomType ~= "match" and CGameMode.RoomType ~= "allstar" then
      local PlayerTransformComponent_C = import("/Game/Mod/EvoBase/BluePrints/Component/BP_CommonPlayerTransformComponent.BP_CommonPlayerTransformComponent_C")
      Game:AddComponent(PlayerTransformComponent_C, self, "BP_PlayerTransformComponent")
    end
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_MAXFPS_CHANGED, self.OnMaxFPSChanged, self)
  if self:HasAuthority() then
    print(bWriteLog and "BRPlayerControllerBase:ReceiveBeginPlay")
    self:AddControlEvent(self, "OnPlayerEnterFighting", self.HandleOnPlayerEnterFighting, self)
    self:AddControlEvent(self, "OnPlayerForceJump", self.HandleOnPlayerForceJump, self)
  else
    GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChangeHandle, self)
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameInstance) then
      local uGameReplay = uGameInstance:GetCompletePlayback()
      if slua.isValid(uGameReplay) then
        self:AddControlEvent(uGameReplay, "OnReplayResetViewTargetDelegate", self.OnReplayResetViewTarget, self)
      end
    end
  end
end
function BRPlayerControllerBase:OnMaxFPSChanged(_, _, NewFPS, Type)
  local FPSFactor = NewFPS / 18.0
  if Type == 1 then
    self.Object.NetConsiderFrequency = self.InitialNetConsiderFrequency * FPSFactor
    self.Object.NetUpdateFrequency = self.InitialNetUpdateFrequency * FPSFactor
    self.Object.MinNetUpdateFrequency = self.InitialMinNetUpdateFrequency * FPSFactor
  end
  print(bWriteLog and "PlayerControllerBase:OnMaxFPSChanged " .. tostring(NewFPS) .. ",NetConsiderFrequency:" .. tostring(self.Object.NetConsiderFrequency) .. ",NetUpdateFrequency:" .. tostring(self.Object.NetUpdateFrequency) .. ",MinNetUpdateFrequency:" .. tostring(self.Object.MinNetUpdateFrequency))
end
function BRPlayerControllerBase:ReceiveEndPlay(EndPlayReason)
  if self.CheckSimulateSyncTimer ~= nil then
    self:RemoveGameTimer(self.CheckSimulateSyncTimer)
    self.CheckSimulateSyncTimer = nil
  end
  BRPlayerControllerBase.__super.ReceiveEndPlay(self, EndPlayReason)
end
function BRPlayerControllerBase:HandleOnPlayerForceJump(nPlaneType)
  if nPlaneType == 1 then
    print(bWriteLog and "PlayerControllerBase HandleOnPlayerForceJump")
    self.IsForceJump = true
  end
end
function BRPlayerControllerBase:IsForceJumpForBornPlane()
  return self.IsForceJump
end
function BRPlayerControllerBase:BindWinInputControl()
  print(bWriteLog and "PlayerControllerBase BindWinInputControl")
end
function BRPlayerControllerBase:OnRep_FriendObservers()
  IngameChat.RefreshFriendObserverDetails()
end
function BRPlayerControllerBase:IsBREnterPlayerController()
  local UGameplayStatics = import("GameplayStatics")
  local GameState = UGameplayStatics.GetGameState(self)
  local uEGameModeType = import("EGameModeType")
  if slua.isValid(GameState) and GameState.GameModeType == uEGameModeType.EEntertainmentGameMode then
    return false
  end
  return true
end
function BRPlayerControllerBase:CanUseTransform()
  return self:IsBREnterPlayerController()
end
function BRPlayerControllerBase:GotoParachuteJumpIfFromExPlane()
  if Client then
    return
  end
  local StateMachine = self.NewStateMachineComp
  if StateMachine and slua.isValid(StateMachine) then
    local EStateType = import("EStateType")
    if StateMachine.CurrentStateType == EStateType.State_InExPlane then
      self:AddGameTimer(1, false, function()
        if slua.isValid(self.Object) and slua.isValid(StateMachine) then
          if StateMachine.CurrentStateType == EStateType.State_Fight then
            print(bWriteLog and "BRPlayerControllerBase:GotoParachuteJumpIfFromExPlane, PlayerKey = " .. tostring(self.PlayerKey) .. ", GotoParachuteJump")
            self:SetCanJump(true)
            local EMsgType = import("EMsgType")
            self:HandleMsg(EMsgType.EMsg_PCGotoParachuteJump)
            self:SetCanJump(false)
          else
            print(bWriteLog and "BRPlayerControllerBase:GotoParachuteJumpIfFromExPlane, PlayerKey = " .. tostring(self.PlayerKey) .. ", CurrentStateType = " .. tostring(StateMachine.CurrentStateType))
          end
        else
          print(bWriteLog and "BRPlayerControllerBase:GotoParachuteJumpIfFromExPlane, Object or StateMachine is invalid")
        end
      end)
    end
  end
end
function BRPlayerControllerBase:HandleOnPlayerEnterFighting()
  print(bWriteLog and "BRPlayerControllerBase:HandleOnPlayerEnterFighting")
  self:GotoParachuteJumpIfFromExPlane()
  local ESTEPoseState = import("ESTEPoseState")
  local uCharacter = self:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) then
    return
  end
  local bIsDying = uCharacter.PoseState == ESTEPoseState.Dying or uCharacter.PoseState == ESTEPoseState.DyingBeCarried or uCharacter.PoseState == ESTEPoseState.DyingSwim
  if bIsDying and uCharacter.SwitchPoseState then
    uCharacter:SwitchPoseState(ESTEPoseState.Stand, true, true, false, false)
    print(bWriteLog and "HandleOnPlayerEnterFighting SwitchPoseState dying to stand")
  end
  if not ItemConfig.MelleeWeaponList then
    return
  end
  local ownerCharacter = self:GetPlayerCharacterSafety()
  if not slua.isValid(ownerCharacter) then
    return
  end
  local uBackPackComp = self:GetBackpackComponent()
  local WeaponManager = ownerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
  local ShootWeapon1 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon1)
  local ShootWeapon2 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon2)
  if slua.isValid(ShootWeapon1) or slua.isValid(ShootWeapon2) then
    return
  end
  if slua.isValid(uBackPackComp) and self.bAutoEquipMelleeWeaponLanded then
    for index, MelleeWeaponListId in ipairs(ItemConfig.MelleeWeaponList) do
      local MelleeItemCount = uBackPackComp:GetItemCountByItemSpecialID(MelleeWeaponListId)
      if 0 < MelleeItemCount then
        local ItemHandle = uBackPackComp:GetFirstItemByDefineIDIgnoreInstance(BackpackUtils.GetItemDefineIDByItemID(MelleeWeaponListId))
        if ItemHandle.DefineID.bValidInstance then
          local BattleItemUseTarget = FBattleItemUseTarget()
          self.bMelleeWeaponAutoCreated = not self.bAutoEquipMelleeWeaponLanded
          self:ServerUseItem(ItemHandle.DefineID, BattleItemUseTarget, EBattleItemUseReason.Manually)
          self.bMelleeWeaponAutoCreated = true
        end
        break
      end
    end
  end
end
function BRPlayerControllerBase:GetPlayerTransformComponent()
  if slua.isValid(self.BP_PlayerTransformComponent) then
    return self.BP_PlayerTransformComponent
  else
    local PlayerTransformComponent_C = import("/Game/Mod/EvoBase/BluePrints/Component/BP_CommonPlayerTransformComponent.BP_CommonPlayerTransformComponent_C")
    local uComponentsArray = self:GetComponentsByClass(PlayerTransformComponent_C)
    if uComponentsArray then
      for i = 0, uComponentsArray:Num() - 1 do
        local Comp = uComponentsArray:Get(i)
        if self:IsValid(Comp) then
          return Comp
        end
      end
    end
  end
end
function BRPlayerControllerBase:OnSpectatorChangeHandle()
  local ViewTarget
  if self.GetCurPlayerCharacter then
    ViewTarget = self:GetCurPlayerCharacter()
  end
  if not slua.isValid(ViewTarget) then
    return
  end
  if ViewTarget.LifterControl then
    local IsUsingLifter = ViewTarget.LifterControl:IsUsingLifter()
    print(bWriteLog and string.format("BRPlayerControllerBase:OnSpectatorChangeHandle switch to PlayerKey = %s, IsUsingLifter = %s", ViewTarget.PlayerKey, IsUsingLifter))
    ViewTarget.LifterControl:EnsureCameraLag(IsUsingLifter)
  end
  if ViewTarget.GetPlayerStateSafety then
    local uPlayerState = ViewTarget:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and uPlayerState.CheckDungeon then
      uPlayerState:CheckDungeon(ViewTarget)
    end
  end
end
function BRPlayerControllerBase:OnReplayResetViewTarget()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = uPlayerController:GetCurPawn()
  local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return
  end
  if slua.isValid(uPlayerCharacter) and uPlayerController.bIsForReplay then
    print(bWriteLog and string.format("BRPlayerControllerBase:OnReplayResetViewTarget PlayerKey = %s | DungeonId = %s", uPlayerCharacter.PlayerKey, uPlayerState.DungeonId))
    if uPlayerState.CheckDungeon then
      uPlayerState:CheckDungeon(uPlayerCharacter)
    end
  end
end
function BRPlayerControllerBase:CheckSimulateSync()
  local tAllCharacters = GameplayData.GetAllCharacters()
  if #tAllCharacters == 0 then
    return
  end
  for i, Character in ipairs(tAllCharacters) do
    if slua.isValid(Character) and Character.Role == 1 and Character.bReplicateMovement == true and Character.ParachuteState == EParachuteState.PS_None then
      local uAttachParent = Character:GetAttachParentActor()
      if uAttachParent == nil then
        self:CheckSimulateSyncForCharacter(Character)
      end
    end
  end
end
function BRPlayerControllerBase:CheckSimulateSyncForCharacter(Character)
  local uCharacterMoveComp = Character.STCharacterMovement
  printf(bWriteLog and "BRPlayerControllerBase:CheckSimulateSyncForCharacter, PlayerKey:%u ", Character.PlayerKey)
  local CharacterMovemntMode = uCharacterMoveComp.MovementMode
  if uCharacterMoveComp and uCharacterMoveComp.bIsActive == true and CharacterMovemntMode ~= EMovementMode.MOVE_Custom and CharacterMovemntMode ~= EMovementMode.MOVE_None then
    local RepBaseMovement = Character.ReplicatedBasedMovement
    if RepBaseMovement.MovementBase and RepBaseMovement.MovementBase.Mobility == 2 then
      local ActorLoc = Character:K2_GetActorLocation()
      local ActorRepMovement = Character.ReplicatedMovement
      local ActorRepLoc = ActorRepMovement.Location
      local fDist = FVector.Distance(ActorLoc, ActorRepLoc)
      if 500 < fDist then
        local Success = false
        local EndLoc = ActorRepLoc + FVector(0, 0, -150)
        local Actor_C = import("/Script/Engine.Actor")
        local HitResult = import("/Script/Engine.HitResult")()
        local uIgnoreActorArray = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
        uIgnoreActorArray:Add(Character)
        Success, HitResult = STExtraBlueprintFunctionLibrary.TraceBlock(Character, ActorRepLoc, EndLoc, HitResult, uIgnoreActorArray, false)
        if HitResult.bBlockingHit and slua.isValid(HitResult.Component) then
          Character.ReplicatedBasedMovement.MovementBase = HitResult.Component
          Character:OnRep_ReplicatedBasedMovement()
          local PlayerKey = Character.PlayerKey or 0
          printf(bWriteLog and "BRPlayerControllerBase:CheckSimulateSyncForCharacter, SetNewBase PlayerKey:%u fDist:%f", PlayerKey, fDist)
        end
      end
    end
  end
end
local class = require("class")
local CPlayerController = require("GameLua.GameCore.Framework.PlayerControllerBase")
local CBRPlayerControllerBase = class(CPlayerController, nil, BRPlayerControllerBase)
return require("combine_class").DeclareFeature(CBRPlayerControllerBase, {
  {
    HeroPropFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.PlayerControllerHeroPropFeature"
  },
  {
    OptionalGarageFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.OptionalGarageFeature"
  },
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerControllerSkyTransitionFeature"
  },
  {
    AvatarBagFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.PlayerControllerAvatarBagFeature"
  },
  {
    CheckParachuteOpenFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.CheckParachuteOpenFeature"
  },
  {
    LevelSequenceExitFeature = "GameLua.Mod.Library.GamePlay.Feature.LevelSequenceExitFeature"
  },
  {
    ParachuteFollowBehaviorFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerControllerParachuteFollowBehaviorFeature"
  }
}, "BRPlayerControllerBase")