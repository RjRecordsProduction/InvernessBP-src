local LogicSmartAssistantToolCardCfg = {
  ToolCardCfgV2 = {
    oneclick_reward = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Gift_png.Common_Icon_Gift_png",
      NameKey = 240151
    },
    rp_level_task = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_RP_png.Common_Icon_RP_png",
      NameKey = 240120
    },
    daily_task = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 33020081
    },
    wow_level_task = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240157
    },
    metro_week_task = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240208
    },
    collect_sys_task = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Range_png.Common_Icon_Range_png",
      NameKey = 240121,
      Url = "game://?module=1002300&index=16&subTab=1"
    },
    season_exchange_shop = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240030
    },
    depot_expire_item_notice = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240124
    },
    security_mail = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Mail_png.Common_Icon_Mail_png",
      NameKey = 800014,
      Url = "game://?module=1000500&tabId=5"
    },
    friend_birthday_notice = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240127
    },
    operation_activity = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240122
    },
    market_free_buy_gift = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Gift_png.Common_Icon_Gift_png",
      NameKey = 240029
    },
    collect_card_bottle = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 2026040200
    },
    collect_card_exchange = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 2026040201
    },
    collect_card_progress = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 240118
    },
    svip_system = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 69049
    },
    manor_parking_currency = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Daojishi_2_png.Common_Icon_Daojishi_2_png",
      NameKey = 791105
    },
    theme_reward_notice = {
      PaperSprite = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Gift_png.Common_Icon_Gift_png",
      NameKey = 240151
    }
  },
  ToolCardCfgs = {
    ReturnFirstBattle = {
      CardType = "ReturnFirstBattle",
      Logic = "LogicToolCardReturnFirstBattle",
      Priority = 0,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reward_png.Common_Icon_Reward_png",
      NameKey = 48950
    },
    FriendApply = {
      CardType = "FriendApply",
      Logic = "LogicToolCardFriendApply",
      Priority = 1,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Friends_png.Common_Icon_Friends_png",
      NameKey = 48937
    },
    Moments = {
      CardType = "Moments",
      Logic = "LogicToolCardMoments",
      Priority = 2,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_FriendsCircle_2_png.Common_Icon_FriendsCircle_2_png",
      NameKey = 48938
    },
    NewbieLevel = {
      CardType = "NewbieLevel",
      Logic = "LogicToolCardNewbieLevel",
      Priority = 3,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_NoviceAdvanced_png.Common_Icon_NoviceAdvanced_png",
      NameKey = 48939
    },
    SpaceGift = {
      CardType = "SpaceGift",
      Logic = "LogicToolCardSpaceGift",
      Priority = 4,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Gift_png.Common_Icon_Gift_png",
      NameKey = 48940
    },
    SeasonSegment = {
      CardType = "SeasonSegment",
      Logic = "LogicToolCardSeasonSegment",
      Priority = 5,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_SeasonTier_png.Common_Icon_SeasonTier_png",
      NameKey = 48941
    },
    Club = {
      CardType = "Club",
      Logic = "LogicToolCardCommunity",
      Priority = 6,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_FriendsCircle_2_png.Common_Icon_FriendsCircle_2_png",
      NameKey = 49614
    },
    TokenExpired = {
      CardType = "TokenExpired",
      Logic = "LogicToolCardTokenExpired",
      Priority = 7,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Cart_png.Common_Icon_Cart_png",
      NameKey = 49605
    },
    CustomerService = {
      CardType = "CustomerService",
      Logic = "LogicToolCardCustomerService",
      Priority = 8,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Service_png.Common_Icon_Service_png",
      NameKey = 49610
    },
    DelayFreeGift = {
      CardType = "DelayFreeGift",
      Logic = "LogicToolCardDelayFreeGift",
      Priority = 9,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Gift_png.Common_Icon_Gift_png",
      NameKey = 49603
    },
    ParkingCoinExpiry = {
      CardType = "ParkingCoinExpiry",
      Logic = "LogicToolCardParkingCoinExpiry",
      Priority = 10,
      Icon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Daojishi_2_png.Common_Icon_Daojishi_2_png",
      NameKey = 791105
    }
  }
}
return LogicSmartAssistantToolCardCfg