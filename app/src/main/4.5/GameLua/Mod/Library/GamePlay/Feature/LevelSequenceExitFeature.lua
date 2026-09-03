local LevelSequenceExitFeature = {
  ServerRPC = {
    ServerRPC_ExitLevelSequence = {Reliable = true},
    ServerRPC_EarlyQuit = {Reliable = true}
  },
  ClientRPC = {},
  MulticastRPC = {}
}
function LevelSequenceExitFeature:ServerRPC_ExitLevelSequence()
  if self.Owner and slua.isValid(self.Owner.Object) then
    local Character = self.Owner:GetPlayerCharacterSafety()
    if slua.isValid(Character) then
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SEQUENCE_FORSHOW_CLIENT_BUTTON_EXIT, Character)
    end
  end
end
function LevelSequenceExitFeature:RegisterCheckInSpot(InCheckInSpot)
  self.CheckInSpot = InCheckInSpot
end
function LevelSequenceExitFeature:ServerRPC_EarlyQuit()
  if self.CheckInSpot then
    self.CheckInSpot:HandleOnePlayerEarlyEnd(self.Owner.PlayerKey)
    self.CheckInSpot = nil
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, LevelSequenceExitFeature)