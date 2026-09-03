local FeatureMusic = {}
local Trait = require("common.trait")
local TFeatureMusic = Trait(Trait.TraitPrototype, nil, FeatureMusic)
function FeatureMusic:PlayMusicFeature()
  log(bWriteLog and "StoreDetail:PlayMusic")
  local logic_music_const = require("client.slua.logic.pubgm_music.logic_music_const")
  local E_MusicPlayMode = logic_music_const.E_MusicPlayMode
  local E_CurPage = logic_music_const.E_CurPage
  local audio_util = require("client.common.audio_util")
  if self.nPlayingMusicID and self.nPlayingMusicID ~= 0 then
    audio_util.StopSound(self.nPlayingMusicID)
  end
  audio_util.PlayAudioByActor(sound_config.musicGameStop)
  audio_util.PlayAudioByActor(sound_config.musicSprayStop)
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  if not self.randomMusicList or not next(self.randomMusicList) then
    self.randomMusicList = logic_pubgm_music.GetRandomDownloadedMusicList()
  end
  if not self.randomMusicList or not next(self.randomMusicList) then
    log(bWriteLog and "StoreDetail:PlayMusic not self.randomMusicList ")
    return
  end
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  musicManager:InitMusicList(self.randomMusicList, E_MusicPlayMode.Random, E_CurPage.Component, nil)
  self.bPlayingMusic = musicManager:BeginPlayMusicList()
  self.nPlayingMusicID = musicManager:GetCurMusicId(true)
end
function FeatureMusic:StopMusicFeature(close, dontStopAction)
  if self.bPlayingMusic then
    local audio_util = require("client.common.audio_util")
    if self.nPlayingMusicID and self.nPlayingMusicID ~= 0 then
      audio_util.StopSound(self.nPlayingMusicID)
    end
    if not dontStopAction then
      audio_util.PlayAudioByActor(sound_config.musicGameStop)
      audio_util.PlayAudioByActor(sound_config.musicSprayStop)
      GlobalData.RestoreLobbyBGM()
    end
  end
end
return TFeatureMusic