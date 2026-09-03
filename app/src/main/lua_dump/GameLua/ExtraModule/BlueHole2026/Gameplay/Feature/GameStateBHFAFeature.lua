local GameStateBHFAFeature = {}
function GameStateBHFAFeature:ctor()
  self.ParticipationTeamIdList = {}
  self.PhotoInteractActorList = {}
end
function GameStateBHFAFeature:ReceiveBeginPlay()
  GameStateBHFAFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "GameStateBHFAFeature:ReceiveBeginPlay")
  self.ParticipationTeamIdList = {}
  self.PhotoInteractActorList = {}
end
function GameStateBHFAFeature:ReceiveEndPlay(EndPlayReason)
  self.ParticipationTeamIdList = {}
  self.PhotoInteractActorList = {}
  GameStateBHFAFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GameStateBHFAFeature:IsParticipationTeam(TeamId)
  return self.ParticipationTeamIdList[TeamId] ~= nil
end
function GameStateBHFAFeature:AddParticipationTeam(TeamId)
  self.ParticipationTeamIdList[TeamId] = true
end
function GameStateBHFAFeature:AddDSPhotoInteractActor(TargetActor)
  self.PhotoInteractActorList[#self.PhotoInteractActorList + 1] = TargetActor
  return #self.PhotoInteractActorList
end
function GameStateBHFAFeature:AddClientPhotoInteractActor(TargetActor, Index)
  self.PhotoInteractActorList[Index] = TargetActor
end
function GameStateBHFAFeature:OnCharacterTakePhoto(Index, PlayerKey)
  print(bWriteLog and string.format("GameStateBHFAFeature:OnCharacterTakePhoto, Index:%d, PlayerKey:%d", Index, PlayerKey))
  if self.PhotoInteractActorList[Index] then
    self.PhotoInteractActorList[Index]:OnOpenChest(PlayerKey)
  end
end
function GameStateBHFAFeature:OnCharacterOpenChestFailed(Index, PlayerKey)
  print(bWriteLog and string.format("GameStateBHFAFeature:OnCharacterOpenChestFailed, Index:%d, PlayerKey:%d", Index, PlayerKey))
  if self.PhotoInteractActorList[Index] then
    self.PhotoInteractActorList[Index]:OnOpenChestFailed(PlayerKey)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateBHFAFeature)