local PlayerControllerParachuteFollowBehaviorFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
PlayerControllerParachuteFollowBehaviorFeature.ServerRPC.RPC_Server_ReportMicStatus = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
PlayerControllerParachuteFollowBehaviorFeature.ServerRPC.RPC_Server_ReportUIActivity = {
  Reliable = true,
  Params = {}
}
function PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus(bMicOpen)
  print(bWriteLog and string.format("PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus - bMicOpen=%s UID=%s", tostring(bMicOpen), tostring(self.Owner and self.Owner.UID)))
  local BehaviorSubsystem = SubsystemMgr:Get("ParachuteFollowBehaviorSubsystem")
  if not BehaviorSubsystem then
    print(bWriteLog and "PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus - Subsystem not found")
    return
  end
  local uOwner = self.Owner and self.Owner.Object
  if not slua.isValid(uOwner) then
    print(bWriteLog and "PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus - Owner invalid")
    return
  end
  local uPS = uOwner.PlayerState
  if not slua.isValid(uPS) then
    print(bWriteLog and "PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus - PlayerState invalid")
    return
  end
  BehaviorSubsystem:SetPlayerMicStatus(uPS.PlayerKey, bMicOpen)
  print(bWriteLog and string.format("PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus - Set PlayerKey=%s bMicOpen=%s", tostring(uPS.PlayerKey), tostring(bMicOpen)))
end
function PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity()
  print(bWriteLog and string.format("PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity - UID=%s", tostring(self.Owner and self.Owner.UID)))
  local BehaviorSubsystem = SubsystemMgr:Get("ParachuteFollowBehaviorSubsystem")
  if not BehaviorSubsystem then
    print(bWriteLog and "PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity - Subsystem not found")
    return
  end
  local uOwner = self.Owner and self.Owner.Object
  if not slua.isValid(uOwner) then
    print(bWriteLog and "PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity - Owner invalid")
    return
  end
  local uPS = uOwner.PlayerState
  if not slua.isValid(uPS) then
    print(bWriteLog and "PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity - PlayerState invalid")
    return
  end
  BehaviorSubsystem:SetPlayerUIActivity(uPS.PlayerKey)
  print(bWriteLog and string.format("PlayerControllerParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity - Reported for PlayerKey=%s", tostring(uPS.PlayerKey)))
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerControllerParachuteFollowBehaviorFeature = class(CFeatureBase, nil, PlayerControllerParachuteFollowBehaviorFeature)
return CPlayerControllerParachuteFollowBehaviorFeature