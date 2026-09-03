local BlackFridayMacros = {}
BlackFridayMacros.UNIX_DAY = 86400
BlackFridayMacros.nGroupMemberMaxNum = 3
BlackFridayMacros.ActivityType = {
  Sign = 0,
  Gun = 1,
  GroupBuy = 2,
  Vow = 3,
  Upgrade = 4,
  Pass = 5,
  RPGroup = 6,
  Subscribe = 7
}
BlackFridayMacros.Act2Title = {
  [BlackFridayMacros.ActivityType.GroupBuy] = 86403,
  [BlackFridayMacros.ActivityType.Upgrade] = 86446,
  [BlackFridayMacros.ActivityType.Gun] = 44621,
  [BlackFridayMacros.ActivityType.Pass] = 86595,
  [BlackFridayMacros.ActivityType.Vow] = 54032,
  [BlackFridayMacros.ActivityType.Subscribe] = 18140014,
  [BlackFridayMacros.ActivityType.RPGroup] = 16178
}
BlackFridayMacros.Act2Rules = {
  [BlackFridayMacros.ActivityType.GroupBuy] = 86359,
  [BlackFridayMacros.ActivityType.Vow] = 54033,
  [BlackFridayMacros.ActivityType.Upgrade] = 86442,
  [BlackFridayMacros.ActivityType.Pass] = 86596,
  [BlackFridayMacros.ActivityType.Subscribe] = 18140015,
  [BlackFridayMacros.ActivityType.RPGroup] = 18140051
}
BlackFridayMacros.RedDotType = {
  None = -1,
  New = 0,
  Hot = 1,
  Award = 2,
  Back = 3,
  Day = 4
}
BlackFridayMacros.Audio = {
  EntryAudio = "/Game/WwiseEvent/Activity/Activity_350/MysteryShop_350/Play_MysteryShop_Enter_350.Play_MysteryShop_Enter_350",
  EntryStopAudio = "/Game/WwiseEvent/Activity/Activity_350/MysteryShop_350/Stop_MysteryShop_Enter_350.Stop_MysteryShop_Enter_350",
  TurnUpNormalAudio = "/Game/WwiseEvent/Activity/Activity_350/MysteryShop_350/Play_MysteryShop_Draw.Play_MysteryShop_Draw",
  TurnUpAdvancedAudio = "/Game/WwiseEvent/Activity/Activity_350/MysteryShop_350/Play_MysteryShop_Draw_Golden.Play_MysteryShop_Draw_Golden",
  ScrollNumberAudio = "/Game/WwiseEvent/Activity/Activity_350/MysteryShop_350/Play_MysteryShop_Enter_350.Play_MysteryShop_Enter_350",
  ScrollNumberStopAudio = "/Game/WwiseEvent/Activity/Activity_350/MysteryShop_350/Stop_MysteryShop_Clock.Stop_MysteryShop_Clock",
  GroupBuyRebateAudio = "/Game/WwiseEvent/Activity/Activity_410/BlackFriday_UI_410/Play_BlackFriday_UI_UcGain.Play_BlackFriday_UI_UcGain"
}
BlackFridayMacros.CoinConfig = {
  [BlackFridayMacros.ActivityType.Gun] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  },
  [BlackFridayMacros.ActivityType.GroupBuy] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  },
  [BlackFridayMacros.ActivityType.Vow] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  },
  [BlackFridayMacros.ActivityType.Upgrade] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  },
  [BlackFridayMacros.ActivityType.Pass] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  },
  [BlackFridayMacros.ActivityType.RPGroup] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  },
  [BlackFridayMacros.ActivityType.Subscribe] = {
    coins = {1006},
    adds = {
      [1006] = true
    }
  }
}
BlackFridayMacros.CostScene = {
  VowExchange = 1,
  TaskDirectBuy = 4,
  GunCustomBox = 5
}
BlackFridayMacros.GroupBuy = {
  EarlyBirdStatus = {
    None = 0,
    Done = 1,
    Get = 2,
    Expire = 3
  }
}
BlackFridayMacros.Enum_ReceivePopupSourceType = {RPTeamReceive = 0, LinkageReceive = 1}
BlackFridayMacros.Enum_LinkageReceiveStatus = {
  NotAchieved = 0,
  CanReceive = 1,
  Received = 2,
  Expired = 3
}
BlackFridayMacros.ENum_QuickGroupShowType = {
  SubCreateAndJoin = 0,
  SubJoin = 1,
  SubQuickJoin = 2,
  RPQuickJoin = 3
}
local ENum_SubJoinGroupSrc = {
  InviteRecord = 1,
  WorldChat = 2,
  FriendChat = 3,
  BuySucPopup = 4,
  QuickJoinPopup = 5,
  GroupRecordPopup = 6
}
BlackFridayMacros.BlackFridayMacros.ENum_LinkageRewardType = {Personal = 1, Group = 2}
BlackFridayMacros.ENum_LinkageSubscribeType = {
  RPAndPrime = 101,
  RPAandPrimePlus = 201,
  RPAndPrimeAndPrimePlus = 302
}
return BlackFridayMacros