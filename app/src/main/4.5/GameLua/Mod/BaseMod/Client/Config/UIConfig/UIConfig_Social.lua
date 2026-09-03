local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Social = {
  CommonExpression = {
    moduleName = "GameLua.Mod.BaseMod.Client.Emote.QuickExpressionWrap",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickExpressionUIBP.QuickExpressionUIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "CommonExpression"
    }
  },
  DanceStageButtonUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DanceStageButtonUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Perspective_Entrance_UIBP.Perspective_Entrance_UIBP",
    uiStat = {
      name = "DanceStageButtonUI"
    },
    isMainUI = false,
    asy = true,
    zOrder = 0,
    loadFromPool = EUIConfigPoolType.None
  },
  DanceTogether_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.Emote.DanceTogether_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/DanceTogether_UIBP.DanceTogether_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "DanceTogether_UIBP"
    }
  },
  IngameLikeUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Like.IngameLikeUIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Like/Ingame_Like_UIBP.Ingame_Like_UIBP",
    containerName = UIContainers.Default,
    zOrder = -10,
    mountPanel = {
      mountOuterName = "MainControlPanelTochButton",
      mountName = "CanvasPanel_IPX"
    },
    uiStat = {name = "mountPanel"},
    isMainUI = false,
    asy = true
  },
  IngameSocialUIBP = {
    moduleName = "GameLua.Mod.Library.Client.Social.Socialize_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Socialize_UIBP.Socialize_UIBP",
    containerName = UIContainers.Bottom,
    zOrder = 0,
    uiStat = {
      name = "IngameSocialUIBP"
    },
    isMainUI = false
  },
  Ingame_WatchLike_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Like.Ingame_WatchLike_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Like/Ingame_WatchLike_UIBP.Ingame_WatchLike_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "Ingame_WatchLike_UIBP"
    },
    isMainUI = false
  },
  IngameFriendPop = {
    moduleName = "GameLua.Mod.Library.Client.Social.Socialize_FriendRequests_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Socialize_FriendRequests_UIBP.Socialize_FriendRequests_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "IngameFriendPop"
    },
    isMainUI = false,
    asy = true
  },
  QuickExpression = {
    moduleName = "GameLua.Mod.BaseMod.Client.Emote.QuickExpressionWrap",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickExpressionUIBP.QuickExpressionUIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "QuickExpression"
    }
  },
  QuickExpressionDecalSubPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.Emote.QuickExpressionDecalSubPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickExpressionDecalSubPanel.QuickExpressionDecalSubPanel",
    uiStat = {
      name = "QuickExpressionDecalSubPanel"
    },
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  QuickExpressionDecalUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Emote.QuickExpressionDecalUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickExpressionDecalUI.QuickExpressionDecalUI",
    uiStat = {
      name = "QuickExpressionDecalUI"
    },
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    autoCreate = true,
    AndroidBackType = EAndroidBackType.Skip
  },
  CommonExpressionNew = {
    moduleName = "GameLua.Mod.BaseMod.Client.Emote.QuickExpressionWrap",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickExpressionUIBP.QuickExpressionUIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "CommonExpressionNew"
    }
  },
  QuickExpressionDecalItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Emote.QuickExpressionDecalItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickExpressionDecalItem.QuickExpressionDecalItem",
    uiStat = {
      name = "QuickExpressionDecalItem"
    },
    isMainUI = false,
    isSingleton = false,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Skip,
    showVisibility = UEnums.ESlateVisibility.Collapsed,
    loadFromPool = EUIConfigPoolType.item_pool
  }
}
return UIConfig_Social