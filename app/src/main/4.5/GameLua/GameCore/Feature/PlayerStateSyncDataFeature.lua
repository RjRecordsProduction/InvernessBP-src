local PlayerStateSyncDataFeature = {}
function PlayerStateSyncDataFeature:ctor()
end
function PlayerStateSyncDataFeature:OnInitWithParams(UID, PlayerKey, PlayerType)
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local PlayerData = PlayerDataMgr.GetPlayerInfo(UID)
  self:HandleAliasInfo(PlayerData)
end
function PlayerStateSyncDataFeature:HandleAliasInfo(PlayerData)
  local PlayerState = self.Owner
  if not PlayerState then
    return
  end
  if IsEditor then
    PlayerState.AliasInfo.aliasID = 2493080
    PlayerState.AliasInfo.aliasTitle = ""
    PlayerState.AliasInfo.aliasNation = ""
    PlayerState.AliasInfo.aliasRank = 6
    PlayerState.AliasInfo.aliasPartnerName = "JoJo"
    PlayerState.AliasInfo.aliasPartnerRelation = 3
    PlayerState.AliasInfo.aliasRankID = 0
    return
  end
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  ServerPlayerDataMgr.HandleAliasInfo(PlayerData, PlayerState)
end
function PlayerStateSyncDataFeature:_GetCurrentTime()
  if CGameMode and type(CGameMode.ServerStartTime) == "number" and CGameMode.ServerStartTime ~= 0 then
    return CGameMode.ServerStartTime + CGameState:GetServerWorldTimeSeconds()
  end
  return os.time()
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStateSyncDataFeature)