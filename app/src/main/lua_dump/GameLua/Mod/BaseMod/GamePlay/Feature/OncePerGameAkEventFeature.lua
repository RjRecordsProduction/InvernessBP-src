local UAkGameplayStatics = import("AkGameplayStatics")
local OncePerGameAkEventFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
OncePerGameAkEventFeature.ClientRPC.RPC_Client_PlayAkEvent = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function OncePerGameAkEventFeature:_PostConstruct()
  OncePerGameAkEventFeature.__super._PostConstruct(self)
  self.PlayedAkEvent = {}
end
function OncePerGameAkEventFeature:PostAkEvent(AkEventPath)
  if not self:HasAuthority() then
    return
  end
  for k, v in pairs(self.PlayedAkEvent) do
    if v == AkEventPath then
      return
    end
  end
  table.insert(self.PlayedAkEvent, AkEventPath)
  self:RPC_Client_PlayAkEvent(AkEventPath)
end
function OncePerGameAkEventFeature:RPC_Client_PlayAkEvent(AkEventPath)
  if not Client then
    return
  end
  self:AsyncLoadAsset(AkEventPath, function(AkEvent)
    if slua.isValid(AkEvent) and slua.isValid(self.Owner.Object) then
      local Pawn = self.Owner:K2_GetPawn()
      if slua.isValid(Pawn) then
        UAkGameplayStatics.PostEvent(AkEvent, Pawn, true, "")
      end
    end
  end)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, OncePerGameAkEventFeature)