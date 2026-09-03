local PlayerControllerFatalDamageFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
PlayerControllerFatalDamageFeature.ClientRPC.RPC_Client_BroadcastFatalDamageToClientForLua = {
  Reliable = true,
  Params = {
    import("FatalDamageParameterCompress")
  }
}
function PlayerControllerFatalDamageFeature:ReceiveBeginPlay()
  PlayerControllerFatalDamageFeature.__super.ReceiveBeginPlay(self)
end
function PlayerControllerFatalDamageFeature:RPC_Client_BroadcastFatalDamageToClientForLua(FatalDamageParameter)
  self:BroadcastFatalDamageToClientForLua(FatalDamageParameter)
end
function PlayerControllerFatalDamageFeature:BroadcastFatalDamageToClientForLua(FatalDamageParameter)
  self:ExtractFatalDamageInfoForLua(FatalDamageParameter)
  self.Owner:BroadcastFatalDamageToClientWithStruct(FatalDamageParameter)
end
function PlayerControllerFatalDamageFeature:ExtractFatalDamageInfoForLua(FatalDamageParameter)
  self.FatalDamageExpandDataContent = slua.LuaArchiverDecode(LuaStateWrapper, FatalDamageParameter.ExpandDataContent)
end
function PlayerControllerFatalDamageFeature:GetFatalDamageInfo()
  return self.FatalDamageExpandDataContent
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerControllerFatalDamageFeature)