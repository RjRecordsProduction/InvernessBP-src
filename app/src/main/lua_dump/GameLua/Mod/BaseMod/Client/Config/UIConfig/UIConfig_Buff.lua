local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Buff = {
  BuffList = {
    moduleName = "GameLua.Mod.BaseMod.Client.BuffList.BuffList",
    path = "/Game/BluePrints/ControlInput/IngameUI/BuffList/ingame_BuffList_UIBP.ingame_BuffList_UIBP",
    isMainUI = false,
    isSingleton = true,
    isWindowsOBHide = true,
    zOrder = 0,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "CanvasPanel_BuffList"
    },
    uiStat = {name = "BuffList"},
    autoCreate = true
  }
}
return UIConfig_Buff