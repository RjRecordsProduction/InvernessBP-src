local Logic_SmallRPUtils = require("client.slua.logic.specialoffer.SmallRP.Logic_SmallRPUtils")
local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
require("client.slua.logic.manager.LobbySceneMgr")
local ConstAvatarDislay = {
  ESceneType = {
    Store = 1,
    Crate = 2,
    GiveStore = 3,
    PreviewSingle = 4,
    PreviewTwo = 5,
    PreviewMulti = 6,
    GoldenPreviewSingle = 7,
    GoldenPreviewThree = 8,
    GoldenPreviewMulti = 9,
    ExchangeSmall = 10,
    ExchangeBig = 11,
    ExchangeGolden = 12,
    ExchangeAirDrop = 13,
    XSuitPreview = 14,
    Pictorial = 15,
    Activity = 16,
    CharacterBox = 17,
    AllStar = 18,
    GoldenPreviewStore = 19,
    StoreWeaponTab = 20,
    SmallRP300 = 21,
    SmallRP300_BuyScore = 22,
    SmallRP300_Exchange = 23,
    RpPreview = 24,
    XSuitExchange = 25,
    CollectAward = 26,
    MilestoneEdit = 27,
    MilestoneView = 28,
    Wardrobe = 29,
    FashionBag = 30,
    VehicleWorkshop = 31,
    PeakGameRank = 32,
    Lobby_RP_Supply_mesh = 33,
    XSuitWorkshop = 34,
    Heirloom = 35,
    WowPassMain = 36,
    WowPassBuyLevel = 37,
    WowPassPrivilge = 38,
    WOWInventory = 39,
    CollectionHallRewardInfo = 40,
    ThemeTreasure = 41
  },
  PaddingTopVoice = 156,
  oldResSeprateTypeStandard = 2100
}
local Const_DeadBox_Location = {
  C_SpawnLocation_Def = FVector(-5374, 1965, -19361.148438),
  C_SpawnLocation_Pre = FVector(10, -434, -14438),
  C_SpawnLocation_Gold = FVector(-5344, 27303, -19353),
  C_SpawnLocation_Gold_Store = FVector(-5390, 27260, -19353),
  C_SpawnLocation_Weapon = FVector(-55, -434, -14438),
  C_SpawnLocation_SmallRP = FVector(-17079.355, -403, -14379),
  C_SpawnLocation_SmallRPBuuScore = FVector(-17179, -403, -14379),
  C_SpawnLocation_SmallRPExchangeShop = FVector(-17149, -403, -14379),
  C_SpawnLocation_Xsuit_Pre = FVector(0, -22.0, -29708.0)
}
local Const_HitEffect_Location = {
  C_SpawnLocation_Def = FVector(-5400, 1965, -19273),
  C_SpawnLocation_Pre = FVector(10, -434, -14350),
  C_SpawnLocation_Gold = FVector(-5344, 27323, -19280),
  C_SpawnLocation_Gold_Store = FVector(-5390, 27323, -19280),
  C_SpawnLocation_Weapon = FVector(-55, -434, -14350),
  C_SpawnLocation_SmallRP = FVector(-17079.355, -403, -14339),
  C_SpawnLocation_SmallRPBuuScore = FVector(-17179, -403, -14379),
  C_SpawnLocation_SmallRPExchangeShop = FVector(-17149, -403, -14329),
  C_SpawnLocation_Xsuit_Pre = FVector(0, 0, -29617.0),
  C_SpawnLocation_RpPreview = FVector(-55, -434, -14337)
}
local InitConst = function()
  ConstAvatarDislay.PaddingLeft2D = {
    [ConstAvatarDislay.ESceneType.Store] = -60,
    [ConstAvatarDislay.ESceneType.Crate] = -60,
    [ConstAvatarDislay.ESceneType.GiveStore] = -60,
    [ConstAvatarDislay.ESceneType.PreviewSingle] = 200,
    [ConstAvatarDislay.ESceneType.PreviewTwo] = 150,
    [ConstAvatarDislay.ESceneType.PreviewMulti] = -20,
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = 200,
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = 0,
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = -20,
    [ConstAvatarDislay.ESceneType.ExchangeSmall] = -20,
    [ConstAvatarDislay.ESceneType.ExchangeBig] = -20,
    [ConstAvatarDislay.ESceneType.ExchangeGolden] = -20,
    [ConstAvatarDislay.ESceneType.ExchangeAirDrop] = -20,
    [ConstAvatarDislay.ESceneType.XSuitPreview] = -20,
    [ConstAvatarDislay.ESceneType.Pictorial] = -20,
    [ConstAvatarDislay.ESceneType.Activity] = -20,
    [ConstAvatarDislay.ESceneType.CharacterBox] = -20,
    [ConstAvatarDislay.ESceneType.AllStar] = -100,
    [ConstAvatarDislay.ESceneType.SmallRP300] = 220,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = -120,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = 40,
    [ConstAvatarDislay.ESceneType.RpPreview] = -170,
    [ConstAvatarDislay.ESceneType.XSuitExchange] = -20,
    [ConstAvatarDislay.ESceneType.CollectAward] = 220,
    [ConstAvatarDislay.ESceneType.VehicleWorkshop] = 220,
    [ConstAvatarDislay.ESceneType.Lobby_RP_Supply_mesh] = -170,
    [ConstAvatarDislay.ESceneType.WowPassMain] = -170,
    [ConstAvatarDislay.ESceneType.WowPassBuyLevel] = -170,
    [ConstAvatarDislay.ESceneType.WowPassPrivilge] = 60,
    [ConstAvatarDislay.ESceneType.ThemeTreasure] = -120
  }
  ConstAvatarDislay.LevelName = {
    [ConstAvatarDislay.ESceneType.Store] = LobbySceneManager.LEVEL_NAME.MALL,
    [ConstAvatarDislay.ESceneType.Crate] = LobbySceneManager.LEVEL_NAME.MALL,
    [ConstAvatarDislay.ESceneType.GiveStore] = LobbySceneManager.LEVEL_NAME.MALL,
    [ConstAvatarDislay.ESceneType.PreviewSingle] = LobbySceneManager.LEVEL_NAME.PREVIEW_NEW,
    [ConstAvatarDislay.ESceneType.PreviewTwo] = LobbySceneManager.LEVEL_NAME.PREVIEW_NEW,
    [ConstAvatarDislay.ESceneType.PreviewMulti] = LobbySceneManager.LEVEL_NAME.PREVIEW_NEW,
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = LobbySceneManager.LEVEL_NAME.GOLDEN_CLOTHES,
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = LobbySceneManager.LEVEL_NAME.GOLDEN_CLOTHES,
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = LobbySceneManager.LEVEL_NAME.GOLDEN_CLOTHES,
    [ConstAvatarDislay.ESceneType.ExchangeSmall] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.ExchangeBig] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.ExchangeGolden] = LobbySceneManager.LEVEL_NAME.GOLDEN_CLOTHES,
    [ConstAvatarDislay.ESceneType.ExchangeAirDrop] = LobbySceneManager.LEVEL_NAME.SUPER_AIRDROP,
    [ConstAvatarDislay.ESceneType.XSuitPreview] = LobbySceneManager.LEVEL_NAME.PREVIEW_NEW,
    [ConstAvatarDislay.ESceneType.Pictorial] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.Activity] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.CharacterBox] = "",
    [ConstAvatarDislay.ESceneType.AllStar] = LobbySceneManager.LEVEL_NAME.ALLSTAR_SHOP,
    [ConstAvatarDislay.ESceneType.SmallRP300] = Logic_SmallRPUtils.GetSceneName,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = Logic_SmallRPUtils.GetSceneName,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = Logic_SmallRPUtils.GetSceneName,
    [ConstAvatarDislay.ESceneType.RpPreview] = UnknowPassTunnelSystem.GetRpSceneName,
    [ConstAvatarDislay.ESceneType.XSuitExchange] = LobbySceneManager.LEVEL_NAME.GLIDE_PREVIEW,
    [ConstAvatarDislay.ESceneType.CollectAward] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.MilestoneEdit] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.MilestoneView] = LobbySceneManager.LEVEL_NAME.SUPPLY,
    [ConstAvatarDislay.ESceneType.VehicleWorkshop] = LobbySceneManager.LEVEL_NAME.ITEMUPGRADE,
    [ConstAvatarDislay.ESceneType.PeakGameRank] = LobbySceneManager.LEVEL_NAME.LOBBY_ZENITHCLASH,
    [ConstAvatarDislay.ESceneType.Lobby_RP_Supply_mesh] = LobbySceneManager.LEVEL_NAME.Lobby_RP_Supply_mesh,
    [ConstAvatarDislay.ESceneType.Heirloom] = LobbySceneManager.LEVEL_NAME.Heirloom,
    [ConstAvatarDislay.ESceneType.WowPassMain] = LobbySceneManager.LEVEL_NAME.WOW_PASS,
    [ConstAvatarDislay.ESceneType.WowPassBuyLevel] = LobbySceneManager.LEVEL_NAME.WOW_PASS,
    [ConstAvatarDislay.ESceneType.WowPassPrivilge] = LobbySceneManager.LEVEL_NAME.WOW_PASS,
    [ConstAvatarDislay.ESceneType.WOWInventory] = LobbySceneManager.LEVEL_NAME.MALL,
    [ConstAvatarDislay.ESceneType.CollectionHallRewardInfo] = "",
    [ConstAvatarDislay.ESceneType.ThemeTreasure] = LobbySceneManager.LEVEL_NAME.SUPPLY
  }
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  ConstAvatarDislay.CameraID = {
    [ConstAvatarDislay.ESceneType.Store] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.Crate] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.GiveStore] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.PreviewSingle] = Lobby_camera_manager_module.Enum_CameraID.item_preview,
    [ConstAvatarDislay.ESceneType.PreviewTwo] = Lobby_camera_manager_module.Enum_CameraID.item_preview,
    [ConstAvatarDislay.ESceneType.PreviewMulti] = Lobby_camera_manager_module.Enum_CameraID.item_preview,
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = Lobby_camera_manager_module.Enum_CameraID.Golden_Clothes,
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = Lobby_camera_manager_module.Enum_CameraID.Golden_Clothes,
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = Lobby_camera_manager_module.Enum_CameraID.Golden_Clothes,
    [ConstAvatarDislay.ESceneType.ExchangeSmall] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.ExchangeBig] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.ExchangeGolden] = Lobby_camera_manager_module.Enum_CameraID.Golden_Clothes,
    [ConstAvatarDislay.ESceneType.ExchangeAirDrop] = Lobby_camera_manager_module.Enum_CameraID.Super_Airdrop,
    [ConstAvatarDislay.ESceneType.XSuitPreview] = Lobby_camera_manager_module.Enum_CameraID.XsuitPreview,
    [ConstAvatarDislay.ESceneType.Pictorial] = Lobby_camera_manager_module.Enum_CameraID.Pictorial,
    [ConstAvatarDislay.ESceneType.Activity] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.CharacterBox] = 0,
    [ConstAvatarDislay.ESceneType.AllStar] = Lobby_camera_manager_module.Enum_CameraID.Lobby_Default,
    [ConstAvatarDislay.ESceneType.SmallRP300] = Lobby_camera_manager_module.Enum_CameraID.SmallRP300,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = Lobby_camera_manager_module.Enum_CameraID.SmallRP300_BuyScore,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = Lobby_camera_manager_module.Enum_CameraID.SmallRP300_Exchange,
    [ConstAvatarDislay.ESceneType.RpPreview] = Lobby_camera_manager_module.Enum_CameraID.RpPreview,
    [ConstAvatarDislay.ESceneType.XSuitExchange] = Lobby_camera_manager_module.Enum_CameraID.XsuitExchange,
    [ConstAvatarDislay.ESceneType.CollectAward] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.MilestoneEdit] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.MilestoneView] = Lobby_camera_manager_module.Enum_CameraID.store_supply,
    [ConstAvatarDislay.ESceneType.VehicleWorkshop] = Lobby_camera_manager_module.Enum_CameraID.VehicleWorkshop,
    [ConstAvatarDislay.ESceneType.PeakGameRank] = Lobby_camera_manager_module.Enum_CameraID.PeakGameRank,
    [ConstAvatarDislay.ESceneType.Lobby_RP_Supply_mesh] = Lobby_camera_manager_module.Enum_CameraID.RpPreview,
    [ConstAvatarDislay.ESceneType.XSuitWorkshop] = Lobby_camera_manager_module.Enum_CameraID.XsuitWorkshop,
    [ConstAvatarDislay.ESceneType.WowPassMain] = Lobby_camera_manager_module.Enum_CameraID.WowPassMain,
    [ConstAvatarDislay.ESceneType.WowPassBuyLevel] = Lobby_camera_manager_module.Enum_CameraID.WowPassBuyLevel,
    [ConstAvatarDislay.ESceneType.WowPassPrivilge] = Lobby_camera_manager_module.Enum_CameraID.WowPassPrivilge,
    [ConstAvatarDislay.ESceneType.WOWInventory] = Lobby_camera_manager_module.Enum_CameraID.WOWInventory,
    [ConstAvatarDislay.ESceneType.ThemeTreasure] = Lobby_camera_manager_module.Enum_CameraID.store_supply
  }
  ConstAvatarDislay.AvatarPos = {
    [ConstAvatarDislay.ESceneType.Store] = {},
    [ConstAvatarDislay.ESceneType.Crate] = {},
    [ConstAvatarDislay.ESceneType.GiveStore] = {},
    [ConstAvatarDislay.ESceneType.PreviewSingle] = {
      x = 25,
      y = -383,
      z = -14347
    },
    [ConstAvatarDislay.ESceneType.PreviewTwo] = {
      x = 0,
      y = -383,
      z = -14347
    },
    [ConstAvatarDislay.ESceneType.PreviewMulti] = {
      x = -25,
      y = -383,
      z = -14347
    },
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = {
      x = -5330,
      y = 27323,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = {
      x = -5360,
      y = 27323,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = {
      x = -5400,
      y = 27323,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.ExchangeSmall] = {
      x = -5380,
      y = 1965,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.ExchangeBig] = {},
    [ConstAvatarDislay.ESceneType.ExchangeGolden] = {
      x = -5380,
      y = 27323,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.ExchangeAirDrop] = {},
    [ConstAvatarDislay.ESceneType.XSuitPreview] = {
      x = 0,
      y = 0.0,
      z = -29617
    },
    [ConstAvatarDislay.ESceneType.Pictorial] = {},
    [ConstAvatarDislay.ESceneType.Activity] = {
      x = -5390,
      y = 1965,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.CharacterBox] = {},
    [ConstAvatarDislay.ESceneType.AllStar] = {
      x = -77,
      y = -398,
      z = -14347
    },
    [ConstAvatarDislay.ESceneType.XSuitExchange] = {
      x = 0,
      y = 0.0,
      z = -29617
    },
    [ConstAvatarDislay.ESceneType.CollectAward] = {
      x = -5320,
      y = 1965,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.MilestoneView] = {
      x = -5320,
      y = 1965,
      z = -19273
    },
    [ConstAvatarDislay.ESceneType.XSuitWorkshop] = {
      x = 0,
      y = 0.0,
      z = -29617
    },
    [ConstAvatarDislay.ESceneType.ThemeTreasure] = {}
  }
  ConstAvatarDislay.SpawnLocationByDeadBox = {
    [ConstAvatarDislay.ESceneType.PreviewSingle] = Const_DeadBox_Location.C_SpawnLocation_Pre,
    [ConstAvatarDislay.ESceneType.PreviewTwo] = Const_DeadBox_Location.C_SpawnLocation_Pre,
    [ConstAvatarDislay.ESceneType.PreviewMulti] = Const_DeadBox_Location.C_SpawnLocation_Pre,
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = Const_DeadBox_Location.C_SpawnLocation_Gold,
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = Const_DeadBox_Location.C_SpawnLocation_Gold,
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = Const_DeadBox_Location.C_SpawnLocation_Gold,
    [ConstAvatarDislay.ESceneType.GoldenPreviewStore] = Const_DeadBox_Location.C_SpawnLocation_Gold_Store,
    [ConstAvatarDislay.ESceneType.StoreWeaponTab] = Const_DeadBox_Location.C_SpawnLocation_Weapon,
    [ConstAvatarDislay.ESceneType.SmallRP300] = Const_DeadBox_Location.C_SpawnLocation_SmallRP,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = Const_DeadBox_Location.C_SpawnLocation_SmallRPBuuScore,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = Const_DeadBox_Location.C_SpawnLocation_SmallRPExchangeShop,
    [ConstAvatarDislay.ESceneType.XSuitPreview] = Const_DeadBox_Location.C_SpawnLocation_Xsuit_Pre,
    [ConstAvatarDislay.ESceneType.XSuitExchange] = Const_DeadBox_Location.C_SpawnLocation_Xsuit_Pre
  }
  ConstAvatarDislay.SpawnLocationByHitEffect = {
    [ConstAvatarDislay.ESceneType.PreviewSingle] = Const_HitEffect_Location.C_SpawnLocation_Pre,
    [ConstAvatarDislay.ESceneType.PreviewTwo] = Const_HitEffect_Location.C_SpawnLocation_Pre,
    [ConstAvatarDislay.ESceneType.PreviewMulti] = Const_HitEffect_Location.C_SpawnLocation_Pre,
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = Const_HitEffect_Location.C_SpawnLocation_Gold,
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = Const_HitEffect_Location.C_SpawnLocation_Gold,
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = Const_HitEffect_Location.C_SpawnLocation_Gold,
    [ConstAvatarDislay.ESceneType.GoldenPreviewStore] = Const_HitEffect_Location.C_SpawnLocation_Gold_Store,
    [ConstAvatarDislay.ESceneType.StoreWeaponTab] = Const_HitEffect_Location.C_SpawnLocation_Weapon,
    [ConstAvatarDislay.ESceneType.SmallRP300] = Const_HitEffect_Location.C_SpawnLocation_SmallRP,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = Const_HitEffect_Location.C_SpawnLocation_SmallRPBuuScore,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = Const_HitEffect_Location.C_SpawnLocation_SmallRPExchangeShop,
    [ConstAvatarDislay.ESceneType.XSuitPreview] = Const_HitEffect_Location.C_SpawnLocation_Xsuit_Pre,
    [ConstAvatarDislay.ESceneType.XSuitExchange] = Const_HitEffect_Location.C_SpawnLocation_Xsuit_Pre,
    [ConstAvatarDislay.ESceneType.RpPreview] = Const_HitEffect_Location.C_SpawnLocation_RpPreview
  }
  ConstAvatarDislay.UIRestrictZone = {
    [ConstAvatarDislay.ESceneType.Crate] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 620,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.PreviewSingle] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 100,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.PreviewTwo] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 320,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.PreviewMulti] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 480,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 100,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.GoldenPreviewThree] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 480,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.GoldenPreviewMulti] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 540,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.ExchangeSmall] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 480,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.ExchangeBig] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 620,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.ExchangeGolden] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 620,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.ExchangeAirDrop] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 100,
      Right = 620,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.XSuitPreview] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 480,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.Pictorial] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 540,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.Activity] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 100,
      Right = 620,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.AllStar] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 100,
      Right = 620,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.SmallRP300] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 320,
      Right = 320,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 30,
      Right = 720,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 30,
      Right = 410,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.XSuitExchange] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 480,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.CollectAward] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 150,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.MilestoneView] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 150,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.Lobby_RP_Supply_mesh] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 750,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.WowPassMain] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 750,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.WowPassBuyLevel] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 0,
      Right = 630,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.WowPassPrivilge] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 100,
      Right = 500,
      Up = 0,
      Down = 50
    },
    [ConstAvatarDislay.ESceneType.WOWInventory] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 200,
      Right = 500,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.CharacterBox] = {
      ScreenX = 1136,
      ScreenY = 640,
      Left = 200,
      Right = 500,
      Up = 0,
      Down = 0
    },
    [ConstAvatarDislay.ESceneType.ThemeTreasure] = {
      ScreenX = 1136,
      ScreenY = 750,
      Left = 0,
      Right = 780,
      Up = 0,
      Down = 0
    }
  }
  ConstAvatarDislay.CenterPreviewScene = {
    [ConstAvatarDislay.ESceneType.PreviewSingle] = true,
    [ConstAvatarDislay.ESceneType.GoldenPreviewSingle] = true,
    [ConstAvatarDislay.ESceneType.PreviewTwo] = true,
    [ConstAvatarDislay.ESceneType.SmallRP300] = true,
    [ConstAvatarDislay.ESceneType.XSuitWorkshop] = true,
    [ConstAvatarDislay.ESceneType.CollectAward] = true,
    [ConstAvatarDislay.ESceneType.FashionBag] = true
  }
  ConstAvatarDislay.InitShowAvatar = {
    [ConstAvatarDislay.ESceneType.GiveStore] = true,
    [ConstAvatarDislay.ESceneType.RpPreview] = true,
    [ConstAvatarDislay.ESceneType.ExchangeBig] = true,
    [ConstAvatarDislay.ESceneType.CharacterBox] = true,
    [ConstAvatarDislay.ESceneType.AllStar] = true,
    [ConstAvatarDislay.ESceneType.MilestoneEdit] = true,
    [ConstAvatarDislay.ESceneType.Lobby_RP_Supply_mesh] = true,
    [ConstAvatarDislay.ESceneType.ThemeTreasure] = true
  }
  ConstAvatarDislay.StoreCrateScene = {
    [ConstAvatarDislay.ESceneType.Store] = true,
    [ConstAvatarDislay.ESceneType.Crate] = true,
    [ConstAvatarDislay.ESceneType.GiveStore] = true,
    [ConstAvatarDislay.ESceneType.StoreWeaponTab] = true
  }
  ConstAvatarDislay.SmallRPScene = {
    [ConstAvatarDislay.ESceneType.SmallRP300] = true,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = true,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = true,
    [ConstAvatarDislay.ESceneType.RpPreview] = true,
    [ConstAvatarDislay.ESceneType.ExchangeBig] = true
  }
  ConstAvatarDislay.RPScene = {
    [ConstAvatarDislay.ESceneType.RpPreview] = true
  }
  ConstAvatarDislay.FiXSceneLevel = {
    [ConstAvatarDislay.ESceneType.SmallRP300] = true,
    [ConstAvatarDislay.ESceneType.SmallRP300_Exchange] = true,
    [ConstAvatarDislay.ESceneType.SmallRP300_BuyScore] = true,
    [ConstAvatarDislay.ESceneType.XSuitPreview] = true,
    [ConstAvatarDislay.ESceneType.XSuitExchange] = true
  }
  ConstAvatarDislay.ForceSceneType = {
    [ConstAvatarDislay.ESceneType.RpPreview] = true
  }
end
function ConstAvatarDislay.GetPaddingX(SceneType)
  local PaddingLeft2D = ConstAvatarDislay.PaddingLeft2D[SceneType] or 0
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local adapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
  if adapt == Lobby_camera_manager_module.Enum_CameraRatio.WideScreen then
    PaddingLeft2D = PaddingLeft2D - 20
  elseif adapt == Lobby_camera_manager_module.Enum_CameraRatio.LongScreen then
    PaddingLeft2D = PaddingLeft2D + 40
  end
  log(bWriteLog and string.format("ConstAvatarDislay.GetPaddingX PaddingLeft2D = %d, adapt = %d", PaddingLeft2D, adapt))
  return PaddingLeft2D
end
function ConstAvatarDislay.IsCenterPreview(SceneType)
  if ConstAvatarDislay.CenterPreviewScene[SceneType] then
    return true
  end
  return false
end
function ConstAvatarDislay.IsStoreCrate(SceneType)
  if SceneType == ConstAvatarDislay.ESceneType.Store or SceneType == ConstAvatarDislay.ESceneType.Crate or SceneType == ConstAvatarDislay.ESceneType.GiveStore or SceneType == ConstAvatarDislay.ESceneType.StoreWeaponTab then
    return true
  end
  return false
end
function ConstAvatarDislay.IsStore(SceneType)
  if SceneType == ConstAvatarDislay.ESceneType.Store then
    return true
  end
  return false
end
function ConstAvatarDislay.IsCrate(SceneType)
  if SceneType == ConstAvatarDislay.ESceneType.Crate then
    return true
  end
  return false
end
function ConstAvatarDislay.IsOldGolden(ItemID)
  local itemInfo = CDataTable.GetTableData("OnlyStoreItem", ItemID)
  if itemInfo and itemInfo.isOldGolden == 1 then
    return true
  end
  return false
end
function ConstAvatarDislay.IsDisableCameraAnimInPreview(ItemID)
  local itemInfo = CDataTable.GetTableData("OnlyStoreItem", ItemID)
  if itemInfo then
    return true
  end
  return false
end
function ConstAvatarDislay.GetSpawnLocationByDeadBox(SceneType)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if Lobby_camera_manager_module:GetCurrentCameraID() == Lobby_camera_manager_module.Enum_CameraID.Golden_Clothes then
    SceneType = ConstAvatarDislay.ESceneType.GoldenPreviewStore
  end
  return ConstAvatarDislay.SpawnLocationByDeadBox[SceneType] or Const_DeadBox_Location.C_SpawnLocation_Def
end
function ConstAvatarDislay.GetSpawnRotationByDeadBox(path)
  local config = CDataTable.GetTableByFilter("ItemUpgradeEffectConfig", "DeadBox", path)
  local SpawnRotation = FRotator(0, 0, 0)
  for i, v in pairs(config) do
    SpawnRotation.Yaw = v.OffsetRotateZ or 0
    return SpawnRotation
  end
  config = CDataTable.GetTableByFilter("ItemUpgradeEffectConfig", "DeadShow", path)
  for i, v in pairs(config) do
    SpawnRotation.Yaw = v.OffsetRotateZ or 0
    break
  end
  return SpawnRotation
end
function ConstAvatarDislay.GetSpawnLocationByHitEffect(SceneType)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if Lobby_camera_manager_module:GetCurrentCameraID() == Lobby_camera_manager_module.Enum_CameraID.Golden_Clothes then
    SceneType = ConstAvatarDislay.ESceneType.GoldenPreviewStore
  end
  return ConstAvatarDislay.SpawnLocationByHitEffect[SceneType] or Const_HitEffect_Location.C_SpawnLocation_Def
end
function ConstAvatarDislay.IsNeedShowAvatar(SceneType)
  if ConstAvatarDislay.InitShowAvatar[SceneType] then
    return true
  end
  return false
end
function ConstAvatarDislay.IsStoreCrateScene(SceneType)
  if ConstAvatarDislay.StoreCrateScene[SceneType] then
    return true
  end
  return false
end
function ConstAvatarDislay.IsSmallRPScene(SceneType)
  if ConstAvatarDislay.SmallRPScene[SceneType] then
    return true
  end
  return false
end
function ConstAvatarDislay.IsRPScene(SceneType)
  if ConstAvatarDislay.RPScene[SceneType] then
    return true
  end
  return false
end
function ConstAvatarDislay.IsFixedSceneLevel(SceneType)
  if ConstAvatarDislay.FiXSceneLevel[SceneType] then
    return true
  end
  return false
end
function ConstAvatarDislay.GetCameraIDByScene(nSceneType)
  if not nSceneType then
    return nil
  end
  local nCameraID = ConstAvatarDislay.CameraID[nSceneType]
  if not nCameraID or nCameraID <= 0 then
    return nil
  end
  return nCameraID
end
InitConst()
return ConstAvatarDislay