local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Medicine = {
  TreatmentDeviceLeftUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.TreatmentDeviceLeftUI",
    path = "/Game/BluePrints/ControlInput/TreatmentDeviceUI.TreatmentDeviceUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "TreatmentDeviceLeftUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  TreatmentDeviceRightUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.TreatmentDeviceRightUI",
    path = "/Game/BluePrints/ControlInput/TreatmentDeviceUI.TreatmentDeviceUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "TreatmentDeviceRightUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  }
}
return UIConfig_Medicine