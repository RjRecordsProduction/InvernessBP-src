local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Audio = {
  MicphoneSettingPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.MicphoneSettingPanel",
    path = "/Game/BluePrints/ControlInput/MainBaseUIItem/MicphonePanel_UIBP.MicphonePanel_UIBP",
    uiStat = {
      name = "MicphoneSettingPanel"
    },
    containerName = UIContainers.Default,
    isAndroidBack = true,
    zOrder = 0,
    asy = true
  },
  SpeakerSettingPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.SpeakerSettingPanel",
    path = "/Game/BluePrints/ControlInput/SpeakerSettingPanel.SpeakerSettingPanel",
    uiStat = {
      name = "SpeakerSettingPanel"
    },
    containerName = UIContainers.Default,
    isAndroidBack = true,
    zOrder = 0
  },
  SpeechToText = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.SpeechToTextUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/SpeechToText_UIBP.SpeechToText_UIBP",
    uiStat = {
      name = "SpeechToText"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = true,
    asy = true
  },
  VoiceChangerPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Communication.VoiceChangerPanel",
    path = "/Game/BluePrints/ControlInput/MainBaseUIItem/VoiceChangePanel.VoiceChangePanel",
    uiStat = {
      name = "VoiceChangerPanel"
    },
    isSingleton = true,
    asy = true
  },
  MicrophoneButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Communication.MicrophoneButton",
    path = "/Game/BluePrints/ControlInput/MainBaseUIItem/MicrophoneButton.MicrophoneButton",
    uiStat = {
      name = "MicrophoneButton"
    },
    isSingleton = true,
    asy = true,
    zOrder = 0,
    autoCreate = true
  },
  PTTPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Communication.PTTPanel",
    path = "/Game/BluePrints/ControlInput/MainBaseUIItem/PTTPanel.PTTPanel",
    uiStat = {name = "PTTPanel"},
    isSingleton = true,
    closeOnHide = false,
    asy = true
  },
  PTTPanel_Simple = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Communication.PTTPanel_Simple",
    path = "/Game/BluePrints/ControlInput/MainBaseUIItem/PTTPanel.PTTPanel",
    uiStat = {
      name = "PTTPanel_Simple"
    },
    isSingleton = true,
    closeOnHide = false,
    asy = true
  },
  STTResultPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Communication.STTResultPanel",
    path = "/Game/BluePrints/ControlInput/MainBaseUIItem/STTResultPanel.STTResultPanel",
    uiStat = {
      name = "STTResultPanel"
    },
    AndroidBackType = EAndroidBackType.Skip,
    isSingleton = true
  },
  MainSoundVisualizationUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.SoundVisualization.MainSoundVisualizationUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/SoundVisualization/SoundVisualization_UIBP.SoundVisualization_UIBP",
    isSingleton = false,
    uiStat = {
      name = "MainSoundVisualizationUI"
    },
    closeOnHide = false,
    asy = true,
    zOrder = 0
  }
}
return UIConfig_Audio