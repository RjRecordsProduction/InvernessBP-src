local collect_bgm_module = {}
function collect_bgm_module:DefineAndResetData()
  self.bIsPlaying = false
end
function collect_bgm_module:SwitchCollectBGM()
  self.bIsPlaying = true
end
function collect_bgm_module:IsCurrentPlaying()
  return self.bIsPlaying
end
function collect_bgm_module:PlayCollectSystemBGM()
  if not self.bIsPlaying then
    GlobalData.StopLobbyBGM()
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(sound_config.CollectSystem_BGM_Play)
    self.bIsPlaying = true
  end
end
function collect_bgm_module:StopCollectSystemBGM()
  if self.bIsPlaying == true then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(sound_config.CollectSystem_BGM_Stop)
    GlobalData.RestoreLobbyBGM()
    self.bIsPlaying = false
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_bgm_module)
return CModuleTemplate