local ParachuteFollowBehaviorConfig = {}
ParachuteFollowBehaviorConfig.DSSwitchID = 119
ParachuteFollowBehaviorConfig.FollowWeightK1 = 0.6
ParachuteFollowBehaviorConfig.FollowWeightK2 = 0.4
ParachuteFollowBehaviorConfig.BehaviorScoreItems = {
  MapMarker = {
    Score = 1000,
    Enabled = true,
    Desc = "Player has placed a map marker"
  },
  MicOpen = {
    Score = 1000,
    Enabled = true,
    Desc = "Player has mic open (push-to-talk or always-on)"
  },
  StartLike = {
    Score = 500,
    Enabled = true,
    Desc = "Player performed start-of-game like"
  },
  PreTeamMember = {
    Score = 1000,
    Enabled = true,
    Desc = "Per pre-made team member bonus (multiplied by member count)"
  }
}
ParachuteFollowBehaviorConfig.IdleDetection = {
  CheckInterval = 3.0,
  PositionThreshold = 1.0,
  RotationThreshold = 1.0
}
function ParachuteFollowBehaviorConfig.GetBehaviorScore(ItemName)
  local Item = ParachuteFollowBehaviorConfig.BehaviorScoreItems[ItemName]
  if not Item or not Item.Enabled then
    return 0
  end
  return Item.Score or 0
end
function ParachuteFollowBehaviorConfig.IsBehaviorEnabled(ItemName)
  local Item = ParachuteFollowBehaviorConfig.BehaviorScoreItems[ItemName]
  return Item ~= nil and Item.Enabled == true
end
function ParachuteFollowBehaviorConfig.IsDSSwitchOpen()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  print(bWriteLog and "ParachuteFollowBehaviorConfig.IsDSSwitchOpen")
  if not slua.isValid(uGameState) or not uGameState.CheckDSSwitchOpen then
    return false
  end
  print(bWriteLog and "ParachuteFollowBehaviorConfig.IsDSSwitchOpen 2")
  return uGameState:CheckDSSwitchOpen(ParachuteFollowBehaviorConfig.DSSwitchID) or IsEditor
end
return ParachuteFollowBehaviorConfig