local UKismetMathLibrary = import("KismetMathLibrary")
local BattleFlagConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.BattleFlagConfig")
local PlayerCharacterBattleFlagFeature = {
  ServerRPC = {}
}
function PlayerCharacterBattleFlagFeature:ctor()
  print(bWriteLog and "PlayerCharacterBattleFlagFeature:ctor")
end
function PlayerCharacterBattleFlagFeature:ReceiveBeginPlay()
  PlayerCharacterBattleFlagFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerCharacterBattleFlagFeature:ReceiveBeginPlay")
end
function PlayerCharacterBattleFlagFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "PlayerCharacterBattleFlagFeature:ReceiveEndPlay")
  PlayerCharacterBattleFlagFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerCharacterBattleFlagFeature:RequestEnhanceShootBullet(ShootWeapon, StartLoc, StartRot, BulletSpeed, ShootID)
  if not slua.isValid(ShootWeapon) then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterBattleFlagFeature:RequestEnhanceShootBullet - Sent RPC ShootID=%d", ShootID))
  self:ServerRPC_EnhanceShootBullet(ShootWeapon, StartLoc, StartRot, BulletSpeed, ShootID)
end
PlayerCharacterBattleFlagFeature.ServerRPC.ServerRPC_EnhanceShootBullet = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    import("/Script/CoreUObject.Vector"),
    import("/Script/CoreUObject.Rotator"),
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet(ShootWeapon, StartLoc, StartRot, BulletSpeed, ShootID)
  if Client then
    return
  end
  local uOwnerPawn = self.Owner and self.Owner.Object
  if not slua.isValid(uOwnerPawn) then
    return
  end
  if not slua.isValid(ShootWeapon) then
    return
  end
  if not uOwnerPawn:HasBuffID(BattleFlagConfig.EnhanceBuffID) then
    print(bWriteLog and "PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet - EnhanceBuff not active, skip")
    return
  end
  local EnhanceBulletClass = slua.loadClass(BattleFlagConfig.EnhanceBulletPath)
  if not EnhanceBulletClass then
    print(bWriteLog and "PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet - Failed to load bullet class")
    return
  end
  local SpawnTransform = UKismetMathLibrary.MakeTransform(StartLoc, StartRot, FVector(1, 1, 1))
  local UGameplayStatics = import("GameplayStatics")
  local ESpawnActorCollisionHandlingMethod = UEnums.ESpawnActorCollisionHandlingMethod
  local uBullet = UGameplayStatics.BeginDeferredActorSpawnFromClass(ShootWeapon, EnhanceBulletClass, SpawnTransform, ESpawnActorCollisionHandlingMethod.AlwaysSpawn, ShootWeapon)
  if not slua.isValid(uBullet) then
    print(bWriteLog and "PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet - Failed to spawn bullet")
    return
  end
  uBullet.  uBullet.ShootDir = UKismetMathLibrary.GetForwardVector(StartRot)
  uBullet.Instigator = uOwnerPawn
  UGameplayStatics.FinishSpawningActor(uBullet, SpawnTransform)
  uBullet:ForceNetUpdate()
  self:AddGameTimer(0, false, function()
    if slua.isValid(uBullet) and slua.isValid(ShootWeapon) and slua.isValid(uOwnerPawn) then
      print(bWriteLog and "PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet - Delayed launch")
      uBullet:LaunchOnServerFromLua(BulletSpeed, SpawnTransform, ShootWeapon, uOwnerPawn, ShootID)
    else
      print(bWriteLog and "PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet - Delayed launch aborted, invalid objects")
    end
  end)
  uOwnerPawn:RemoveBuffByID(BattleFlagConfig.EnhanceBuffID, nil, -1, 0)
  print(bWriteLog and string.format("PlayerCharacterBattleFlagFeature:ServerRPC_EnhanceShootBullet - Launched enhance bullet ShootID=%d", ShootID))
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerCharacterBattleFlagFeature)