local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Store = {
  ClassicStoreUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Store.ClassicStoreUI",
    path = "/Game/BluePrints/ControlInput/ResidentStore/ResidentStore_UIBP.ResidentStore_UIBP",
    zOrder = 2
  },
  OpenStoreButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.Store.OpenStoreButton",
    path = "/Game/Mod/EvoBase/BluePrints/Store/OpenStoreButton.OpenStoreButton",
    containerName = UIContainers.Bottom,
    zOrder = 0,
    uiStat = {
      name = "OpenStoreButton"
    },
    isMainUI = false
  },
  BuyGoodsCritTips = {
    moduleName = "GameLua.Mod.Library.Client.UI.BuyGoodsCritTips",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/Classic_PlayStore_Crit_UIBP.Classic_PlayStore_Crit_UIBP",
    isSingleton = true,
    uiStat = {
      name = "BuyGoodsCritTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    zOrder = 10000
  },
  ResidentStoreItemTest1 = {
    moduleName = "GameLua.Mod.BaseMod.Client.Store.Items.StoreItemDefault",
    path = "/Game/BluePrints/ControlInput/ResidentStore/ResidentStore_Item_1_UIBP_test1.ResidentStore_Item_1_UIBP_test1",
    isSingleton = false,
    uiStat = {
      name = "ResidentStoreItemTest1"
    },
    isMainUI = false
  },
  ResidentStoreItemTest2 = {
    moduleName = "GameLua.Mod.BaseMod.Client.Store.Items.StoreItemTest",
    path = "/Game/BluePrints/ControlInput/ResidentStore/ResidentStore_Item_1_UIBP_test2.ResidentStore_Item_1_UIBP_test2",
    isSingleton = false,
    uiStat = {
      name = "ResidentStoreItemTest1"
    },
    isMainUI = false
  }
}
return UIConfig_Store