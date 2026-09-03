local PlayerStatusEnum = {}
PlayerStatusEnum.Enum_TeamState = {
  Idle = 0,
  Team = 1,
  Battle = 2,
  Room = 3,
  Watch = 4,
  Free = 5,
  Busy = 6,
  Stealth = 7,
  doNotBother = 8
}
PlayerStatusEnum.Enum_FreeInOutFailReason = {
  NoStatus = "no_status",
  NotBattle = "not_battle",
  NoMod = "no_mod",
  NotFreeInOut = "not_free_inout"
}
PlayerStatusEnum.Enum_FreeInOutFromType = {FriendList = 1}
return PlayerStatusEnum