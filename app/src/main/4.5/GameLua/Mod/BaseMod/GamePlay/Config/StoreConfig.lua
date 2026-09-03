local StoreConfig = {
  GoldID = 3000324,
  BRTDMStoreGoldID = 3000328,
  NextAirDropItemId = 3000320,
  NextAirDropMapMarkId = 56,
  WeaponType = 1,
  AccessoryType = 2,
  BulletType = 3,
  ArmorType = 5,
  DesignatedStore = 1006,
  BRTDMStore = 1007,
  CarriedStore = 1008,
  DesertStore = 1009,
  DiscountStore = 1010,
  CarloStore = 1011,
  KFCStore = 1012,
  UGCStore = 1013,
  BuyAndSellStore = 1014,
  NeonPremiumStore = 1015,
  SteamTrainStore = 1016,
  D350_Store = 3001,
  CallPenguinStore1 = 1017,
  CallPenguinStore2 = 1018,
  CallPenguinStore3 = 1019,
  CallPenguinStore4 = 1020,
  CallPenguinStore5 = 1021,
  FixPenguinStore = 1022,
  StoreDataEncodeMagnification = 10000,
  HideFarStoreScreenMarkTime = 60,
  DesignatedStoreMaxDropItemNum = 6,
  DesignatedStoreCanBuyIcon = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Team_btn_LV2_huangse_png.Team_btn_LV2_huangse_png",
  DesignatedStoreCannotBuyIcon = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Team_btn_LV1_bukedian_png.Team_btn_LV1_bukedian_png",
  CarryAccessoriesText = 26206,
  PlayerLimitText = 26203,
  BattleLimitText = 26204,
  TimeLimitText = 26205,
  StoreLimitText = 16003646,
  TeamLimitText = 16003647,
  CloseStoreReason = {
    BuyGoods = 1,
    ClickCloseButton = 2,
    BeHit = 3,
    NearDeath = 4
  },
  DiscountType = 0,
  BuyItemType = 0,
  BuyTeammateLifeType = 1,
  BuyTeammateEmptyType = 2,
  GiftBoxType = 3,
  BuyItemDropListType = 4,
  ExchangeItemType = 5,
  CustomScriptItemType = 6,
  ExchangeTicketType = 7,
  ItemGoodsHandle = "GameLua.Mod.BaseMod.GamePlay.Store.Handle.ItemGoodsHandle",
  BuyTeammateLifeHandle = "GameLua.Mod.BaseMod.GamePlay.Store.Handle.BuyTeammateLifeHandle",
  ItemDropListHandle = "GameLua.Mod.BaseMod.GamePlay.Store.Handle.ItemDropListHandle",
  ItemExchangeHandle = "GameLua.Mod.BaseMod.GamePlay.Store.Handle.ItemExchangeHandle",
  ExchangeTicketHandle = "GameLua.Mod.BaseMod.GamePlay.Store.Handle.ExchangeTicketHandle",
  TeammateIndexIcon = {
    [1] = "/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_01.ResurrectTeammates_01",
    [2] = "/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_02.ResurrectTeammates_02",
    [3] = "/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_03.ResurrectTeammates_03",
    [4] = "/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_04.ResurrectTeammates_04"
  },
  DiscountTeammateItemBG = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_SeaIslandBG02.ResidentStore_SeaIslandBG02",
  TeammateItemBG = "/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_BG.ResurrectTeammates_BG",
  DiscountTeammateItemInfoBG = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_SeaIslandBG01.ResidentStore_SeaIslandBG01",
  TeammateItemInfoBG = "/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_BG02.ResurrectTeammates_BG02",
  DisabledTimeAfterDied = 4,
  DiscountGoodIDs = {
    "DiscountGoodID1",
    "DiscountGoodID2",
    "DiscountGoodID3",
    "DiscountGoodID4",
    "DiscountGoodID5",
    "DiscountGoodID6"
  },
  OriginPrices = {
    "OriginPrice1",
    "OriginPrice2",
    "OriginPrice3",
    "OriginPrice4",
    "OriginPrice5",
    "OriginPrice6"
  },
  DiscountRates = {
    "DiscountRate1",
    "DiscountRate2",
    "DiscountRate3",
    "DiscountRate4",
    "DiscountRate5",
    "DiscountRate6"
  },
  DiscountPrices = {
    "DiscountPrice1",
    "DiscountPrice2",
    "DiscountPrice3",
    "DiscountPrice4",
    "DiscountPrice5",
    "DiscountPrice6"
  },
  OperateType = {
    Invalid = 0,
    Enter = 1,
    Leave = 2,
    OpenStore = 3,
    CloseStore = 4,
    BuyGoods = 5,
    ExchangeGoods = 6,
    OperateTypeMax = 99
  },
  StoreBuyLifeWeaponPoor = {
    TimePoint = 360,
    BeforeWeaponPoor = {
      BeginEquip = {
        [1] = {
          [{
            {305001, 90},
            {501001, 1},
            {502001, 1},
            {503113, 1},
            {601011, 6},
            {108005, 1}
          }] = 100
        },
        [2] = {
          [{
            {102002, 1}
          }] = 33
        }
      }
    },
    AfterWeaponPoor = {
      BeginEquip = {
        [1] = {
          [{
            {305001, 90},
            {501002, 1},
            {502002, 1},
            {503114, 1},
            {601011, 6},
            {601012, 1},
            {1004001, 1},
            {108005, 1}
          }] = 100
        },
        [2] = {
          [{
            {102002, 1}
          }] = 33
        }
      }
    }
  },
  GoldTipsShowTime = 2,
  tNeedCheckBezelWeaponID = {
    [105001] = true,
    [105002] = true
  },
  tNeedCheckGunLockWeaponID = {
    [101002] = true,
    [101009] = true,
    [103004] = true,
    [103006] = true,
    [103009] = true,
    [103010] = true,
    [103100] = true
  },
  tNeedCheckTacticalAttachWeaponID = {
    [107001] = true
  },
  BezelItemID = 207001,
  GunLockItemID = 208001,
  TacticalAttachItemID = 209001,
  FriendlyGiftBoxItemId = 606100,
  StoreGoodsAccessoryType = 3,
  CarloStoreAccessoryType = 4,
  BezelTipsAnimShowTime = 5,
  HideBezelMods = {
    CreativeBase = true,
    SocialIsland = true,
    NewbieGame = false,
    SlayTheBot = true,
    Sink2 = true,
    WarGame = true
  },
  HideNewAccessoriesInfoMods = {
    TDM = true,
    BRTDM = true,
    TPlan = true,
    SingleTraining = true
  },
  nStorePanelBezelAnimShowTime = 5,
  tStoreTags = {
    "StoreSpotErangel",
    "StoreSpot",
    "StoreSpotOfficialLivik"
  },
  tLimitType = {
    [1] = "TeamLimitCount",
    [2] = "PlayerLimitCount"
  },
  ExchangeTicketConfig = {
    AdvancedWeaponTicket = {
      TicketItemID = 6041008,
      GiftBoxItemID = 6041010,
      TipTextID = 33020035,
      TipTimes = 3,
      StoreTipTextID = 33020043
    },
    ReviveTicket = {
      TicketItemID = 6041009,
      GiftBoxItemID = 6041011,
      AutoGiveOnRevive = true,
      TipTextID = 33020036,
      TipTimes = 3,
      GuideTextID = 33020037,
      StoreTipTextID = 33020044
    }
  },
  RandomEventConfig = {
    TriggerRate = 0.2,
    CannotInteractTime = 2,
    ExtraDropID = 33022501,
    QuestionTipTitleID = 33020038,
    QuestionTipTextID = 33020039,
    TipID = 12341,
    DisableModType = {Sink2 = true}
  }
}
StoreConfig.PatchGoodsList = {
  [StoreConfig.DesignatedStore] = "DesignatedStorePatchGoodsList",
  [StoreConfig.BRTDMStore] = "BRTDMStorePatchGoodsList",
  [StoreConfig.DiscountStore] = "DiscountStorePatchGoodsList",
  [StoreConfig.CarloStore] = "CarloStorePatchGoodsList",
  [StoreConfig.KFCStore] = "KFCStorePatchGoodsList",
  [StoreConfig.BuyAndSellStore] = "BuyAndSellStorePatchGoodsList",
  [StoreConfig.NeonPremiumStore] = "NeonPremiumStorePatchGoodsList",
  [StoreConfig.SteamTrainStore] = "DesignatedStorePatchGoodsList",
  [StoreConfig.CallPenguinStore1] = "DesignatedStorePatchGoodsList",
  [StoreConfig.CallPenguinStore2] = "DesignatedStorePatchGoodsList",
  [StoreConfig.CallPenguinStore3] = "DesignatedStorePatchGoodsList",
  [StoreConfig.CallPenguinStore4] = "DesignatedStorePatchGoodsList",
  [StoreConfig.CallPenguinStore5] = "DesignatedStorePatchGoodsList",
  [StoreConfig.FixPenguinStore] = "DesignatedStorePatchGoodsList",
  [StoreConfig.D350_Store] = "DesignatedStorePatchGoodsList"
}
StoreConfig.StoreHideGoodsList = {
  [StoreConfig.DesignatedStore] = "DesignatedStoreHideGoodsList",
  [StoreConfig.BRTDMStore] = "BRTDMStoreHideGoodsList",
  [StoreConfig.DiscountStore] = "DiscountStoreHideGoodsList",
  [StoreConfig.CarloStore] = "CarloStoreHideGoodsList",
  [StoreConfig.NeonPremiumStore] = "DesignatedStoreHideGoodsList",
  [StoreConfig.SteamTrainStore] = "DesignatedStoreHideGoodsList",
  [StoreConfig.CallPenguinStore1] = "DesignatedStoreHideGoodsList",
  [StoreConfig.CallPenguinStore2] = "DesignatedStoreHideGoodsList",
  [StoreConfig.CallPenguinStore3] = "DesignatedStoreHideGoodsList",
  [StoreConfig.CallPenguinStore4] = "DesignatedStoreHideGoodsList",
  [StoreConfig.CallPenguinStore5] = "DesignatedStoreHideGoodsList",
  [StoreConfig.FixPenguinStore] = "DesignatedStoreHideGoodsList",
  [StoreConfig.D350_Store] = "DesignatedStoreHideGoodsList"
}
StoreConfig.BuyGoodsList = {
  [StoreConfig.DesignatedStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.DesertStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.BRTDMStore] = "BRTDMStoreBuyGoodsList",
  [StoreConfig.DiscountStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.CarloStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.KFCStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.UGCStore] = "StoreBuyGoodsList",
  [StoreConfig.BuyAndSellStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.NeonPremiumStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.SteamTrainStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.CallPenguinStore1] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.CallPenguinStore2] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.CallPenguinStore3] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.CallPenguinStore4] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.CallPenguinStore5] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.FixPenguinStore] = "DesignatedStoreBuyGoodsList",
  [StoreConfig.D350_Store] = "DesignatedStoreBuyGoodsList"
}
StoreConfig.CostCoinID = {
  [StoreConfig.BRTDMStore] = StoreConfig.BRTDMStoreGoldID
}
StoreConfig.ShouldSplitType = {
  [StoreConfig.WeaponType] = true,
  [StoreConfig.AccessoryType] = true,
  [StoreConfig.BulletType] = true,
  [StoreConfig.ArmorType] = true
}
StoreConfig.StoreTlogEventID = {
  [StoreConfig.DesignatedStore] = 232,
  [StoreConfig.CarriedStore] = 241,
  [StoreConfig.NeonPremiumStore] = 232
}
StoreConfig.StoreNameTextID = {
  [StoreConfig.DesignatedStore] = 26201,
  [StoreConfig.DesertStore] = 39048,
  [StoreConfig.DiscountStore] = 44383,
  [StoreConfig.CarloStore] = 26201,
  [StoreConfig.KFCStore] = 62971,
  [StoreConfig.BuyAndSellStore] = 66680,
  [StoreConfig.NeonPremiumStore] = 79433,
  [StoreConfig.SteamTrainStore] = 3600040,
  [StoreConfig.CallPenguinStore1] = 4101217,
  [StoreConfig.CallPenguinStore2] = 4101217,
  [StoreConfig.CallPenguinStore3] = 4101217,
  [StoreConfig.CallPenguinStore4] = 4101217,
  [StoreConfig.CallPenguinStore5] = 4101217,
  [StoreConfig.FixPenguinStore] = 4101217,
  [StoreConfig.D350_Store] = 26201
}
StoreConfig.TitleType = {
  [0] = {
    TypeID = 0,
    TextID = 30400,
    IconPath = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_Icon_010.ResidentStore_Icon_010"
  },
  [1] = {
    TypeID = 1,
    TextID = 6296,
    IconPath = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_Icon_07.ResidentStore_Icon_07"
  },
  [2] = {
    TypeID = 2,
    TextID = 6299,
    IconPath = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_Icon_08.ResidentStore_Icon_08"
  },
  [3] = {
    TypeID = 3,
    TextID = 6297,
    IconPath = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_Icon_09.ResidentStore_Icon_09"
  },
  [4] = {
    TypeID = 4,
    TextID = 4965,
    IconPath = "/Game/Arts/UI/NoAtlas/ResidentStore/ResidentStore_Icon_010.ResidentStore_Icon_010"
  }
}
StoreConfig.NormalStoreCurrency = {
  StoreConfig.GoldID,
  StoreConfig.BRTDMStoreGoldID
}
StoreConfig.ScreenMarkID = {
  [StoreConfig.DesignatedStore] = 1002,
  [StoreConfig.DiscountStore] = 1005,
  [StoreConfig.KFCStore] = 1199,
  [StoreConfig.BuyAndSellStore] = 1198,
  [StoreConfig.NeonPremiumStore] = 1002,
  [StoreConfig.SteamTrainStore] = 1198,
  [StoreConfig.CallPenguinStore1] = 1198,
  [StoreConfig.CallPenguinStore2] = 1198,
  [StoreConfig.CallPenguinStore3] = 1198,
  [StoreConfig.CallPenguinStore4] = 1198,
  [StoreConfig.CallPenguinStore5] = 1198,
  [StoreConfig.FixPenguinStore] = 1198,
  [StoreConfig.D350_Store] = 1198
}
StoreConfig.NeedCheckInteractive = {
  [StoreConfig.DesignatedStore] = true,
  [StoreConfig.DiscountStore] = true,
  [StoreConfig.CarloStore] = true,
  [StoreConfig.KFCStore] = true,
  [StoreConfig.BuyAndSellStore] = true,
  [StoreConfig.NeonPremiumStore] = true,
  [StoreConfig.SteamTrainStore] = true,
  [StoreConfig.CallPenguinStore1] = true,
  [StoreConfig.CallPenguinStore2] = true,
  [StoreConfig.CallPenguinStore3] = true,
  [StoreConfig.CallPenguinStore4] = true,
  [StoreConfig.CallPenguinStore5] = true,
  [StoreConfig.FixPenguinStore] = true,
  [StoreConfig.D350_Store] = true
}
StoreConfig.UploadConfig = {
  UploadItemIDs = {
    [1] = 1702820,
    [2] = 1702821
  },
  UploadUIParam = {
    IconPath = "/Game/Mod/EasternRealm/Arts/UI/Atlas/Frames/ZD_Icon_Upload_png_png.ZD_Icon_Upload_png_png",
    TextID = 76672
  }
}
StoreConfig.GoodsOpenConfig = {
  Halloween5 = {
    Baltic = {
      [604157] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604158] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604159] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604166] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604167] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604168] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604163] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604164] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604165] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604175] = {
        [107] = true,
        [108] = true
      },
      [604176] = {
        [107] = true,
        [108] = true
      },
      [604177] = {
        [107] = true,
        [108] = true
      },
      [604172] = {
        [107] = true,
        [108] = true
      },
      [604173] = {
        [107] = true,
        [108] = true
      },
      [604174] = {
        [107] = true,
        [108] = true
      },
      [604160] = {
        [108] = true
      },
      [604161] = {
        [108] = true
      },
      [604162] = {
        [108] = true
      },
      [604169] = {
        [108] = true
      },
      [604170] = {
        [108] = true
      },
      [604171] = {
        [108] = true
      }
    },
    Neon = {
      [604157] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604158] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604159] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604166] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604167] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604168] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604163] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604164] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604165] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604175] = {
        [107] = true,
        [108] = true
      },
      [604176] = {
        [107] = true,
        [108] = true
      },
      [604177] = {
        [107] = true,
        [108] = true
      },
      [604172] = {
        [107] = true,
        [108] = true
      },
      [604173] = {
        [107] = true,
        [108] = true
      },
      [604174] = {
        [107] = true,
        [108] = true
      },
      [604160] = {
        [108] = true
      },
      [604161] = {
        [108] = true
      },
      [604162] = {
        [108] = true
      },
      [604169] = {
        [108] = true
      },
      [604170] = {
        [108] = true
      },
      [604171] = {
        [108] = true
      }
    },
    Livik = {
      [604160] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604161] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604162] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604166] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604167] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604168] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604163] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604164] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604165] = {
        [106] = true,
        [107] = true,
        [108] = true
      },
      [604175] = {
        [107] = true,
        [108] = true
      },
      [604176] = {
        [107] = true,
        [108] = true
      },
      [604177] = {
        [107] = true,
        [108] = true
      },
      [604172] = {
        [107] = true,
        [108] = true
      },
      [604173] = {
        [107] = true,
        [108] = true
      },
      [604174] = {
        [107] = true,
        [108] = true
      },
      [604157] = {
        [108] = true
      },
      [604158] = {
        [108] = true
      },
      [604159] = {
        [108] = true
      },
      [604169] = {
        [108] = true
      },
      [604170] = {
        [108] = true
      },
      [604171] = {
        [108] = true
      }
    }
  }
}
function StoreConfig.IsGoodsItemOpen(GoodConfig)
  if not GoodConfig then
    print(bWriteLog and "StoreConfig.IsGoodsItemOpen GoodConfig is nil")
    return false
  end
  if not CGameState then
    print(bWriteLog and "StoreConfig.IsGoodsItemOpen CGameState is nil")
    return false
  end
  local bOpen = true
  if GoodConfig.TimeID_a and GoodConfig.TimeID_a:Num() > 0 then
    bOpen = false
    for _, TimeID in pairs(GoodConfig.TimeID_a) do
      if CGameState:HasTimeIDSwitch(TimeID) then
        bOpen = true
        break
      end
    end
  end
  return bOpen
end
StoreConfig.CustomItemDisplayConfig = {}
StoreConfig.CustomItemDisplayConfigByType = {}
StoreConfig.DefaultItemScriptPath = "GameLua.Mod.BaseMod.Client.Store.Items.StoreItemDefault"
return StoreConfig