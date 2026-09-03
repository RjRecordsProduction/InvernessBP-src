local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_ScreenMark = {
  DefaultScreenMarkPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.ScreenMarkUI.DefaultScreenMarkPanel",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/DefaultScreenMarkPanel.DefaultScreenMarkPanel",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = false,
    zOrder = 0,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_0"
    },
    uiStat = {
      name = "DefaultScreenMarkPanel"
    },
    autoCreate = true
  }
}
return UIConfig_ScreenMark