local access_restriction_config = require("client.logic.common.access_restriction_config")
local EPlayerType = access_restriction_config.EPlayerType
local EAccessType = access_restriction_config.EAccessType
local AccessRestrictionSystem = {
  EPlayerType = EPlayerType,
  EAccessType = EAccessType,
  CurrPlayerType = EPlayerType.Normal_Player,
  TouristMaxSegment = 301
}
local AccessRestrictionConfig = {
  [EAccessType.BattleResult] = {
    [EPlayerType.Normal_Player] = false,
    [EPlayerType.Doubtful_Player] = false,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = true,
    [EPlayerType.Doubtful_Tourist] = true,
    [EPlayerType.Low_Priority_Player] = true
  },
  [EAccessType.SegmentLimit] = {
    [EPlayerType.Normal_Player] = false,
    [EPlayerType.Doubtful_Player] = false,
    [EPlayerType.Normal_Tourist] = true,
    [EPlayerType.High_Kill_Tourist] = true,
    [EPlayerType.Doubtful_Tourist] = true,
    [EPlayerType.Low_Priority_Player] = true
  },
  [EAccessType.SelectZone] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.SelectMatchCount] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = true,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.TeamInvite] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.Mentor] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = true
  },
  [EAccessType.TeamPlatform] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.GameAgain] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.TeamRecruit] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.TeamCode] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.Matching] = {
    [EPlayerType.Normal_Player] = false,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = true,
    [EPlayerType.Doubtful_Tourist] = true,
    [EPlayerType.Low_Priority_Player] = true
  },
  [EAccessType.FriendWatch] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.SocialIsland] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = true,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.WorldChat] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.Wireless] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.LocalRank] = {
    [EPlayerType.Normal_Player] = false,
    [EPlayerType.Doubtful_Player] = false,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.NoLocalRank] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.WarRank] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = false,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.SpaceGift] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  },
  [EAccessType.ClubChat] = {
    [EPlayerType.Normal_Player] = true,
    [EPlayerType.Doubtful_Player] = true,
    [EPlayerType.Normal_Tourist] = false,
    [EPlayerType.High_Kill_Tourist] = false,
    [EPlayerType.Doubtful_Tourist] = false,
    [EPlayerType.Low_Priority_Player] = false
  }
}
local AccessRestrictionTipsConfig = {
  [EAccessType.BattleResult] = nil,
  [EAccessType.SegmentLimit] = 22005,
  [EAccessType.SelectZone] = 22002,
  [EAccessType.SelectMatchCount] = 22003,
  [EAccessType.TeamInvite] = 22007,
  [EAccessType.Mentor] = nil,
  [EAccessType.TeamPlatform] = 11548,
  [EAccessType.GameAgain] = nil,
  [EAccessType.TeamRecruit] = 22006,
  [EAccessType.TeamCode] = 22006,
  [EAccessType.Matching] = nil,
  [EAccessType.FriendWatch] = 22006,
  [EAccessType.SocialIsland] = 22006,
  [EAccessType.WorldChat] = 22006,
  [EAccessType.Wireless] = 22010,
  [EAccessType.LocalRank] = nil,
  [EAccessType.NoLocalRank] = nil,
  [EAccessType.WarRank] = nil,
  [EAccessType.SpaceGift] = 22009,
  [EAccessType.ClubChat] = 22006
}
function AccessRestrictionSystem.init()
end
function AccessRestrictionSystem.GetPlayerType()
  return AccessRestrictionSystem.CurrPlayerType
end
function AccessRestrictionSystem.IsTourist()
  return AccessRestrictionSystem.CurrPlayerType == EPlayerType.Doubtful_Tourist or AccessRestrictionSystem.CurrPlayerType == EPlayerType.High_Kill_Tourist or AccessRestrictionSystem.CurrPlayerType == EPlayerType.Normal_Tourist
end
function AccessRestrictionSystem.CheckAccess(AccessType)
  local Config = AccessRestrictionConfig[AccessType]
  if Config == nil then
    return true
  end
  local Access = Config[AccessRestrictionSystem.CurrPlayerType]
  if Access == nil then
    return true
  end
  return Access
end
function AccessRestrictionSystem.GetPopTips(AccessType)
  return AccessRestrictionTipsConfig[AccessType]
end
function AccessRestrictionSystem.CheckAccessAndPopTips(AccessType)
  if not AccessRestrictionSystem.CheckAccess(AccessType) then
    local tips = AccessRestrictionSystem.GetPopTips(AccessType)
    if tips then
      ShowNotice(tips)
    end
    return false
  end
  return true
end
function AccessRestrictionSystem.on_player_cheat_state_notify(player_cheat_state)
  log(bWriteLog and "on_player_cheat_state_notify:" .. tostring(player_cheat_state))
  AccessRestrictionSystem.CurrPlayerType = player_cheat_state
  EventSystem:postEvent(EVENTTYPE_ACCESS_RESTRICTION, EVENTID_ACCESS_RESTRICTION_NOTIFY, player_cheat_state)
end
function AccessRestrictionSystem.CheckLowPriorityPlayer(AccessType)
  local Config = AccessRestrictionConfig[AccessType]
  if Config then
    return Config[AccessRestrictionSystem.CurrPlayerType]
  end
  return true
end
return AccessRestrictionSystem