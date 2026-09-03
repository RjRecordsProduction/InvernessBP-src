local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerDeadBoxPath = "/Game/BluePrints/PickUp/Special/PlayerDeadBox.PlayerDeadBox"
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local DeadBoxClientShowFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {
    RPC_Multicast_PawnDie = {
      Reliable = false,
      Params = {
        import("/Script/CoreUObject.Vector"),
        UEnums.EPropertyClass.Int
      }
    }
  }
}
function DeadBoxClientShowFeature:_PostConstruct()
  DeadBoxClientShowFeature.__super._PostConstruct(self)
  self.BoxLifeSpan = 8
  print(bWriteLog and "DeadBoxClientShowFeature:_PostConstruct")
end
function DeadBoxClientShowFeature:ReceiveBeginPlay()
  DeadBoxClientShowFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "DeadBoxClientShowFeature:ReceiveBeginPlay")
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_DIED, self.HandleOnPawnDie, self)
end
function DeadBoxClientShowFeature:ReceiveEndPlay(Reason)
  DeadBoxClientShowFeature.__super.ReceiveEndPlay(self, Reason)
end
function DeadBoxClientShowFeature:HandleOnPawnDie(_, __, uPawn, uKiller, TypeID)
  if not Game:IsValid(uPawn) or not uPawn.PlayerKey then
    return
  end
  if self:DsCheckIsDropDeadBox(uPawn) then
    return
  end
  if uPawn.GetRandomPutDownLocation and uKiller.GetCurrentWeapon then
    local Loc = uPawn:GetRandomPutDownLocation(80)
    local DamageWeapon = uKiller:GetCurrentWeapon()
    local AvatarID = 0
    local UBackpackUtils = import("BackpackUtils")
    local PlayerKey = tonumber(uKiller:GetPlayerKey())
    local PlayerController = GameplayData.GetPlayerController(PlayerKey)
    if slua.isValid(DamageWeapon) and DamageWeapon:GetItemDefineID().Type ~= 6 and slua.isValid(PlayerController) then
      local nCurWeaponBPID = UBackpackUtils.GetBPIDByResID(DamageWeapon:GetItemDefineID().TypeSpecificID)
      AvatarID = PlayerController:GetWeaponAvatarItemId(nCurWeaponBPID)
    end
    self:RPC_Multicast_PawnDie(Loc, AvatarID)
  end
  print(bWriteLog and "DeadBoxClientShowFeature:HandleOnPawnDie")
end
function DeadBoxClientShowFeature:RPC_Multicast_PawnDie(Loc, AvatarID)
  if not Loc or not AvatarID then
    return
  end
  print(bWriteLog and "DeadBoxClientShowFeature:RPC_Multicast_PawnDie Loc:", Loc:ToString(), " AvatarID:", AvatarID)
  if self:IsAuthority() or AvatarID <= 0 then
    return
  end
  self:ClientSpawnBox(Loc, AvatarID)
end
function DeadBoxClientShowFeature:ClientSpawnBox(Loc, AvatarID)
  local UAvatarUtils = import("AvatarUtils")
  local UBackpackUtils = import("BackpackUtils")
  local AvatarPath = UAvatarUtils.GetWeaponAvatarDeadBoxAvatarHandlePath(AvatarID)
  if not UBackpackUtils.IsBattleItemHandlePathExist(AvatarPath) then
    print(bWriteLog and "DeadBoxClientShowFeature:RPC_Multicast_PawnDie IsBattleItemHandlePathExist false ")
    return
  end
  local Util = require("client.slua_ui_framework.util")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    ActorTools.SpawnActorAsync(PlayerCharacter, PlayerDeadBoxPath .. "_C", Loc, FRotator(0, 0, 0), FVector(1, 1, 1), function(UBoxActor)
      if slua.isValid(UBoxActor) then
        UBoxActor:SetLifeSpan(self.BoxLifeSpan)
        UBoxActor:SetAvatarId(AvatarID)
        self:AddGameTimer(1, false, function()
          if slua.isValid(UBoxActor) then
            if UBoxActor.Survive_FMC_Chest1 then
              UBoxActor.Survive_FMC_Chest1:SetHiddenInGame(false, false)
            end
            if UBoxActor.DeadParticleSystem then
              UBoxActor.DeadParticleSystem:Activate(true)
            end
          end
        end)
        UBoxActor:OnRep_AvatarId()
      end
    end)
  else
    print(bWriteLog and "DeadBoxClientShowFeature:ClientSpawnBox Failed !!!! TClassObject:", AvatarPath)
  end
end
function DeadBoxClientShowFeature:SetBoxLifeSpan(BoxLifeSpan)
  if BoxLifeSpan then
    self.  end
end
function DeadBoxClientShowFeature:DsCheckIsDropDeadBox(uPawn)
  if CGameState and CGameState.IsShowDeadBox == false then
    return false
  end
  if slua.isValid(uPawn) and uPawn.bIsUseDeadBox == false then
    return false
  end
  return true
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, DeadBoxClientShowFeature)