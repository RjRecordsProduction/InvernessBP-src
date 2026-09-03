local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
local Logic_SmallRPConst = {
  Enum_Task = {
    Unfinished = 0,
    Completed = 1,
    Received = 2,
    Lock = 3
  },
  Enum_TaskProRewardStatus = {NotReceived = 0, Received = 1},
  Enum_ExchangeTab = {ExchangeShop = 1, Chest = 2},
  Enum_UnlockSourceType = {
    MainUI = 1,
    Task = 2,
    LevelGuideTip = 3
  },
  Enum_MultiType = {
    Two = 2,
    Three = 3,
    Four = 4
  },
  Enum_ScoreReason = {
    LuckyDraw = 1,
    TaskAward = 2,
    BatchTaskReward = 3,
    Decompose = 4,
    BuyScore = 5,
    GmAdd = 6
  },
  Enum_EntranceType = {
    Invalid = 0,
    LuckyDraw = 1,
    DontPutBack = 2,
    SportCar = 3,
    SportBox = 4
  }
}
local Enum_MultiType = Logic_SmallRPConst.Enum_MultiType
Logic_SmallRPConst.MultiSelectOneItemBP = {
  [Enum_MultiType.Two] = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_Award_2Choose1_Item_UIBP.SmallRP_Award_2Choose1_Item_UIBP",
  [Enum_MultiType.Three] = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_Award_3Choose1_Item_UIBP.SmallRP_Award_3Choose1_Item_UIBP",
  [Enum_MultiType.Four] = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_Award_4Choose1_Item_UIBP.SmallRP_Award_4Choose1_Item_UIBP"
}
local Enum_EntranceType = Logic_SmallRPConst.Enum_EntranceType
Logic_SmallRPConst.EntranceUrlTemplate = {
  [Enum_EntranceType.LuckyDraw] = nil,
  [Enum_EntranceType.DontPutBack] = nil,
  [Enum_EntranceType.SportCar] = nil,
  [Enum_EntranceType.SportBox] = "game://?module=1008201&Tab1=%s"
}
Logic_SmallRPConst.DefaultEntranceImagePath = "/Game/UMG/Texture_200/Atlas/SpecialOffer/Frames"
Logic_SmallRPConst.EntranceImageName = {
  [1] = "SmallRP_Lottery_Entrance_01",
  [2] = "SmallRP_Lottery_Entrance_02"
}
Logic_SmallRPConst.EntranceTittleID = {
  [Enum_EntranceType.LuckyDraw] = 74025,
  [Enum_EntranceType.DontPutBack] = 76582,
  [Enum_EntranceType.SportCar] = 79653,
  [Enum_EntranceType.SportBox] = 79654
}
Logic_SmallRPConst.NotRelatedRPScoreTypeMap = {
  [Enum_EntranceType.SportCar] = true,
  [Enum_EntranceType.SportBox] = true
}
return Logic_SmallRPConst