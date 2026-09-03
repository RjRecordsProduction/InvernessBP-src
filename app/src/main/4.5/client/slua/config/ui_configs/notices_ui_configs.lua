local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local ESlateVisibility = UEnums and UEnums.ESlateVisibility or {}
require("client.slua.config.ClientMacros.bp_macros")
require("client.common.game_status")
require("client.slua.config.ClientMacros.EFixedZOrder")
require("client.slua.config.ClientMacros.UIContainers")
local notices_ui_configs = {
  Notices_Main_UIBP = {
    keyName = "Notices_Main_UIBP",
    moduleName = "client.slua.umg.Notices.Notices_Main_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/Other/Notices/Notices_Main_UIBP.Notices_Main_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\133\172\229\145\138-\228\184\187\231\149\140\233\157\162"
    }
  },
  Notices_ImageOrBlueprint_UIBP = {
    keyName = "Notices_ImageOrBlueprint_UIBP",
    moduleName = "client.slua.umg.Notices.Notices_ImageOrBlueprint_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/Other/Notices/Notices_ImageOrBlueprint_UIBP.Notices_ImageOrBlueprint_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\133\172\229\145\138-\229\155\190\231\137\135/\232\147\157\229\155\190\230\139\141\232\132\184"
    }
  },
  Notices_JKB_UIBP = {
    keyName = "Notices_JKB_UIBP",
    moduleName = "client.slua.umg.Notices.Notices_JKB_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/Other/Notices/Notices_JKB_UIBP.Notices_JKB_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\133\172\229\145\138-\230\151\165\233\159\169\229\141\176"
    }
  },
  Notices_CollectionPage_UIBP = {
    keyName = "Notices_CollectionPage_UIBP",
    moduleName = "client.slua.umg.Notices.Notices_CollectionPage_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/Other/Notices/Notices_CollectionPage_UIBP.Notices_CollectionPage_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\133\172\229\145\138-\229\133\172\229\145\138\233\155\134\229\144\136\233\161\181"
    }
  },
  Notices_CollectionPage_Theme_UIBP = {
    keyName = "Notices_CollectionPage_Theme_UIBP",
    moduleName = "client.slua.umg.Notices.Notices_CollectionPage_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/Other/Notices/Notices_CollectionPage_Theme_UIBP.Notices_CollectionPage_Theme_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\133\172\229\145\138-\229\133\172\229\145\138\233\155\134\229\144\136\233\161\181-\228\184\187\233\162\152"
    }
  },
  Notices_Gamelet_UIBP = {
    keyName = "GameletContainer_UIBP",
    moduleName = "client.slua.umg.GameletSDK.GameletFaceSlapContainer_UIBP",
    path = "/Game/Mod/Lobby/Base/Gamelet/GameletFaceSlapContainer_UIBP.GameletFaceSlapContainer_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\172\229\145\138-Gamelet"
    }
  }
}
return notices_ui_configs