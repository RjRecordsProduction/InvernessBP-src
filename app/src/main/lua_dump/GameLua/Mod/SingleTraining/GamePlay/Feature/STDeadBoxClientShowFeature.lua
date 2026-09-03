local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerDeadBoxPath = "/Game/BluePrints/PickUp/Special/PlayerDeadBox.PlayerDeadBox"
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local STDeadBoxClientShowFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function STDeadBoxClientShowFeature:_PostConstruct()
  STDeadBoxClientShowFeature.__super._PostConstruct(self)
  self.BoxLifeSpan = 20
  print(bWriteLog and "STDeadBoxClientShowFeature:_PostConstruct")
end
function STDeadBoxClientShowFeature:ReceiveBeginPlay()
  STDeadBoxClientShowFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "STDeadBoxClientShowFeature:ReceiveBeginPlay")
end
function STDeadBoxClientShowFeature:ReceiveEndPlay(Reason)
  STDeadBoxClientShowFeature.__super.ReceiveEndPlay(self, Reason)
end
function STDeadBoxClientShowFeature:HandleOnPawnDie(_, __, uPawn, uKiller, TypeID)
  if not Game:IsValid(uPawn) or not uPawn.PlayerKey then
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
      PlayerController:ClientRPC_SpawnDeadBox(Loc, AvatarID)
    end
  end
  print(bWriteLog and "STDeadBoxClientShowFeature:HandleOnPawnDie")
end
function STDeadBoxClientShowFeature:SpawnSTDeadBox(Loc, AvatarID)
  if not Loc or not AvatarID then
    return
  end
  print(bWriteLog and "STDeadBoxClientShowFeature:RPC_PawnDie Loc:", Loc:ToString(), " AvatarID:", AvatarID)
  if self:IsAuthority() or AvatarID <= 0 then
    return
  end
  self:ClientSpawnBox(Loc, AvatarID)
end
function STDeadBoxClientShowFeature:CleanAIDeadBox()
  print(bWriteLog and "STDeadBoxClientShowFeature:CleanAIDeadBox")
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local uActorArray = ActorTools.GetAllActors(CGameState, "PlayerTombBox")
  for _, uActor in pairs(uActorArray) do
    if uActor and slua.isValid(uActor) then
      Game:RemoveActor(uActor)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.DeadBoxClientShowFeature")
return class(CFeatureBase, nil, STDeadBoxClientShowFeature)