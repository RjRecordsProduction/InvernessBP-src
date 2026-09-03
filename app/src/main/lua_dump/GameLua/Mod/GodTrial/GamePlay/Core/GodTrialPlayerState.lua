local GodTrialPlayerState = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function GodTrialPlayerState:ctor()
  self.bAddCustomPlayersForComplaint = true
  self.ComplaintAIPrefixID = 88130
end
function GodTrialPlayerState:_PostConstruct()
  GodTrialPlayerState.__super._PostConstruct(self)
  self.LockMapLocation = FVector.ZeroVector
end
function GodTrialPlayerState:ReceiveBeginPlay()
  GodTrialPlayerState.__super.ReceiveBeginPlay(self)
end
function GodTrialPlayerState:ReceiveEndPlay(EndPlayReason)
  GodTrialPlayerState.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GodTrialPlayerState:GetLifetimeReplicatedProps()
  local BaseRepTable = GodTrialPlayerState.__super:GetLifetimeReplicatedProps() or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "MapID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "LockMapLocation",
      ELifetimeCondition.COND_None,
      import("/Script/CoreUObject.Vector")
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function GodTrialPlayerState:OnRep_MapID()
  print(bWriteLog and "GodTrialPlayerState:OnRep_MapID " .. tostring(self.MapID) .. " " .. tostring(self.PlayerKey))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_AREA_ID_CHANGED, self.PlayerKey, self.MapID)
end
function GodTrialPlayerState:GetMapID()
  return self.MapID
end
function GodTrialPlayerState:IsInParkourDungeon()
  return self.DungeonId > 44800
end
function GodTrialPlayerState:SetDungeonId(DungeonId)
  GodTrialPlayerState.__super.SetDungeonId(self, DungeonId)
  print(bWriteLog and string.format("GodTrialPlayerState:SetDungeonId %s", DungeonId))
  if self:IsInParkourDungeon() then
    local PlayerCharacter = self:GetPlayerCharacter()
    if PlayerCharacter and PlayerCharacter.TeleportPawnFeature and PlayerCharacter.TeleportPawnFeature.LocationBeforeTeleport then
      self.LockMapLocation = PlayerCharacter.TeleportPawnFeature.LocationBeforeTeleport
      print(bWriteLog and string.format("GodTrialPlayerState:SetDungeonId LockMapLocation = %s", self.LockMapLocation:ToString()))
    end
  else
    self.LockMapLocation = FVector.ZeroVector
    print(bWriteLog and string.format("GodTrialPlayerState:SetDungeonId LockMapLocation = 0"))
  end
  self:ForceNetUpdate()
end
local class = require("class")
local CPlayerStateBase = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerStateBase")
local CGodTrialPlayerState = class(CPlayerStateBase, nil, GodTrialPlayerState)
local combine_class = require("combine_class")
combine_class.DeclareFeature(CGodTrialPlayerState, {
  {
    PlayerStateHonorFeature = "GameLua.Mod.GodTrial.Gameplay.Feature.PlayerStateHonorFeature"
  },
  {
    MercenaryFeature = "GameLua.ExtraModule.MLAI.Mercenary.Feature.PlayerStateMercenaryFeature"
  },
  {
    ThemeTaskFeature = "GameLua.Mod.Library.GamePlay.Task.ThemeTask.ThemeTaskFeature"
  },
  {
    BattleFlagArmorFeature = "GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.Feature.PlayerStateBattleFlagArmorFeature"
  }
}, "GodTrialPlayerState")
return CGodTrialPlayerState