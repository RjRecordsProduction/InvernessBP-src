local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Backpack = {
  BackPackDropSlideUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackDropSlideUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPack_SlideDelete_Item_BP.BackPack_SlideDelete_Item_BP",
    uiStat = {
      name = "BackPackDropSlideUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    asy = true
  },
  BackPackPanelUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/MainBackPackPanel_New_BP.MainBackPackPanel_New_BP",
    uiStat = {
      name = "BackPackPanelUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 2,
    autoCreate = true,
    showVisibility = UEnums.GSlateVisibility.Collapsed
  },
  BackpackClothingBox_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.Clothing.BackpackClothingBox_UIBP",
    path = "/Game/BluePrints/ControlInput/BackpackClothingBox_UIBP.BackpackClothingBox_UIBP",
    uiStat = {
      name = "\230\151\182\232\163\133\232\131\140\229\140\133\229\136\151\232\161\168\233\157\162\230\157\191"
    },
    isMainUI = false
  },
  BackpackClothingEntryUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackpackClothingEntryUI",
    path = "/Game/BluePrints/ControlInput/BackpackClothingEntryUI.BackpackClothingEntryUI",
    containerName = UIContainers.Default,
    zOrder = 0,
    uiStat = {
      name = "BackpackClothingEntryUI"
    },
    isMainUI = false,
    autoCreate = true,
    asy = true
  },
  BackpackDeleteControl = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackpackDeleteControl",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackpackDeleteWidget.BackpackDeleteWidget",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 5,
    asy = true,
    uiStat = {
      name = "BackpackDeleteControl"
    }
  },
  EmicBackpack_Duability = {
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/EmicBackpack_Duability.EmicBackpack_Duability",
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.EmicBackpack_Duability",
    uiStat = {
      name = "\231\148\181\231\163\129\229\185\178\230\137\176\232\131\140\229\140\133UI"
    },
    zOrder = -1,
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  FriendlyBehavior_InfoPanel_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_FriendlyInfoPanel",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackArmorSlot_Material_TipsPopup_BP.BackPackArmorSlot_Material_TipsPopup_BP",
    asy = false
  },
  FriendlyBehavior_Slot_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_FriendlySlot",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackArmorSlot_Material_BP.BackPackArmorSlot_Material_BP",
    asy = false
  },
  MainBackpackAvatarPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.MainBackpackAvatarPanel",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/MainBackpackAvatarPanel_BP.MainBackpackAvatarPanel_BP",
    uiStat = {
      name = "MainBackpackAvatarPanel"
    },
    containerName = UIContainers.Default,
    isMainUI = false,
    isSingleton = true,
    asy = true
  },
  MeleeInfoItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.MeleeInfoItemUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/MeleeInfoItem_BP.MeleeInfoItem_BP",
    uiStat = {
      name = "MeleeInfoItem"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1
  },
  PickUpListPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.PickUpListPanel",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/PickUpListPanel_New_BP.PickUpListPanel_New_BP",
    fullScreen = false,
    uiStat = {
      name = "PickUpListPanel"
    },
    containerName = UIContainers.Default,
    isSingleton = true,
    isMainUI = false,
    isAndroidBack = false,
    zOrder = 0,
    autoCreate = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  PickUpListItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.PickUpListItem",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/PickUpItem_SNew_BP.PickUpItem_SNew_BP",
    fullScreen = false,
    uiStat = {
      name = "PickUpListItem"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false,
    asy = false
  },
  TombBoxListItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.TombBoxListItem",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/PickUpItem_New_BP.PickUpItem_New_BP",
    fullScreen = false,
    uiStat = {
      name = "TombBoxListItem"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false,
    asy = false
  },
  PistolInfoItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.PistolInfoItemUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/PistolInfoItem_BP.PistolInfoItem_BP",
    uiStat = {
      name = "PistolInfoItem"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1
  },
  PickUpItemTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.PickUpItemTips",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/PickUpItemTips_BP.PickUpItemTips_BP",
    uiStat = {
      name = "PickUpItemTips"
    },
    isMainUI = false,
    closeOnHide = false,
    showVisibility = UEnums.GSlateVisibility.Collapsed,
    zOrder = 1
  },
  WeaponBezelInfoUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.WeaponBezelInfoUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Parts_Tips_BP.Parts_Tips_BP",
    uiStat = {
      name = "WeaponBezelInfoUI"
    },
    zOrder = 5,
    asy = true,
    isSingleton = true,
    containerName = UIContainers.Default
  },
  AccessoryDescItemUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.AccessoryDescItemUI",
    path = "/Game/BluePrints/ControlInput/SwitchWeaponSlot_AttributeItem.SwitchWeaponSlot_AttributeItem",
    uiStat = {
      name = "AccessoryDescItemUI"
    },
    isSingleton = false,
    asy = true,
    isMainUI = false,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  BackpackItemDaggerOfTimeAdv = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.DaggerOfTimeAdvUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackItem_BP.BackPackItem_BP",
    uiStat = {
      name = "DaggerOfTimeAdvUI"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    isSingleton = false,
    zOrder = 0
  },
  BackpackItemDefault = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackItemUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackItem_BP.BackPackItem_BP",
    uiStat = {
      name = "BackPackItemUI"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    isSingleton = false,
    zOrder = 0
  },
  BackpackItemFireworks = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackFireworksItemUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackItem_New_02_UIBP.BackPackItem_New_02_UIBP",
    uiStat = {
      name = "BackPackFireworksItemUI"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    isSingleton = false,
    zOrder = 0
  },
  MainBackPackRolewearTab = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.Clothing.MainBackPackRolewearTab",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/MainBackPackRolewearTab.MainBackPackRolewearTab",
    uiStat = {
      name = "\230\151\182\232\163\133\232\131\140\229\140\133\229\136\151\232\161\168\233\161\185"
    },
    isSingleton = false
  },
  MainWeaponInfoItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.MainWeaponInfoItemUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/MainWeaponInfoItem_BP.MainWeaponInfoItem_BP",
    uiStat = {
      name = "MainWeaponInfoItem"
    },
    isSingleton = false,
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1
  }
}
return UIConfig_Backpack