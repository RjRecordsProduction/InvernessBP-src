local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerCharacterBHFAFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
PlayerCharacterBHFAFeature.ServerRPC.RPC_Server_OnCharacterTakePhoto = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerCharacterBHFAFeature.ClientRPC.RPC_Client_OnCharacterOpenChestFailed = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterBHFAFeature:RPC_Server_OnCharacterTakePhoto(Index)
  print(bWriteLog and string.format("PlayerCharacterBHFAFeature:RPC_Server_OnCharacterTakePhoto, Index:%d", Index))
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateBHFAFeature and self.Owner then
    GameState.GameStateBHFAFeature:OnCharacterTakePhoto(Index, self.Owner.PlayerKey)
  end
end
function PlayerCharacterBHFAFeature:RPC_Client_OnCharacterOpenChestFailed(Index)
  print(bWriteLog and string.format("PlayerCharacterBHFAFeature:RPC_Client_OnCharacterOpenChestFailed, Index:%d", Index))
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateBHFAFeature and self.Owner then
    GameState.GameStateBHFAFeature:OnCharacterOpenChestFailed(Index, self.Owner.PlayerKey)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerCharacterBHFAFeature)