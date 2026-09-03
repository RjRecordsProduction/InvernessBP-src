local audio_manager = {player_mode = -1}
local local local local local local local string_format = string.format
local UEnums.LobbyAudioType = {
  Music = 1,
  UI = 2,
  SoundEffect = 3
}
local C_HighAudioPufferKey = "res_audiohigh"
local C_LowAudioPufferKey = "res_audiolow"
local audio_instances = {}
local C_DefalutPosition = -1
function audio_manager:OnInitialize()
  audio_manager.__super.OnInitialize(self)
  log(bWriteLog and "[DeanJYT] audio_manager:OnInitialize")
  self:InitSoundEffectQuality()
  self.curPlayingMusicId = nil
  self.bActiveStop = false
end
function audio_manager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, self.OnApplicationReactivated, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnApplicationDeactivated, self)
  self:AddCommonEvent(EVENTTYPE_WEB, EVENTID_WEB_REACTIVATED, self.OnWebReactivated, self)
  self:AddCommonEvent(EVENTTYPE_WEB, EVENTID_WEB_DEACTIVATED, self.OnWebDeactivated, self)
end
function audio_manager:OnLogOut()
  self:ReleaseAll()
  self:DisableMusicPlayer()
end
function audio_manager:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and string_format("audio_manager:OnPreSwitchGameStatus. pre=%s, nextState=%s", tostring(preState), tostring(nextState)))
  self:ReleaseAll()
  self:DisableMusicPlayer()
end
function audio_manager:Start(sound_id, disableMusicPlayer)
  if not disableMusicPlayer then
    log(bWriteLog and "audio_manager:Start, not music_player. ")
    self:DisableMusicPlayer()
    self:SetPlayerMode(0)
  end
  local sound_config = CDataTable.GetTableData("SoundTable", sound_id)
  if not sound_config then
    log_error(bWriteLog and string_format("Error: audio_manager:Start, sound_id:%s", sound_id))
    return
  end
  if sound_config.Type == UEnums.LobbyAudioType.Music then
    self:_PauseCurrentPlayMusic()
  end
  local audio_instance = audio_instances[sound_id]
  if not audio_instance then
    local audio_base_class = require("client.common.audio.audio_base")
    audio_instance = audio_base_class()
    audio_instance:InitBySoundConfig(sound_config)
    audio_instances[sound_id] = audio_instance
  end
  audio_instance:Start()
  self:UpdateCurPlayMusicId(sound_id)
  return audio_instance
end
function audio_manager:Stop(sound_id)
  local audio_instance = audio_instances[sound_id]
  if not audio_instance then
    log_error("audio_manager:Stop audio_instances not find id:" .. sound_id)
    return nil
  end
  local instance_type = audio_instance:Stop()
  self.bActiveStop = true
  return instance_type
end
function audio_manager:Pause(sound_id)
  if not sound_id then
    return nil
  end
  local audio_instance = audio_instances[sound_id]
  if not audio_instance then
    log_error("audio_manager:Pause audio_instances not find id:" .. tostring(sound_id))
    return nil
  end
  audio_instance:Pause()
  self.bActiveStop = true
  return audio_instance
end
function audio_manager:Resume(sound_id)
  local audio_instance = audio_instances[sound_id]
  if not audio_instance then
    log_error("audio_manager:Resume audio_instances not find id:" .. tostring(sound_id))
    return nil
  end
  audio_instance:Resume()
  self:UpdateCurPlayMusicId(sound_id)
  return audio_instance
end
function audio_manager:ResumeAtTime(sound_id, time)
  local audio_instance = audio_instances[sound_id]
  if not audio_instance then
    log_error("audio_manager:ResumeAtTime audio_instances not find id:" .. tostring(sound_id))
    return nil
  end
  audio_instance:ResumeAtTime(time)
  self:UpdateCurPlayMusicId(sound_id)
  return audio_instance
end
function audio_manager:Release(sound_id)
  local audio_instance = audio_instances[sound_id]
  audio_instances[sound_id] = nil
  if not audio_instance then
    log_error("audio_manager:Release audio_instances not find id:" .. sound_id)
    return
  end
  audio_instance:OnRelease()
end
function audio_manager:ReleaseAll()
  log(bWriteLog and "audio_manager:ReleaseAll")
  for k, audio_instance in pairs(audio_instances) do
    audio_instance:OnRelease()
  end
  audio_instances = {}
end
function audio_manager:_GetCurrentPlayMusic()
  log(bWriteLog and "audio_manager:_GetCurrentPlayMusic curPlayingMusicId:" .. tostring(self.curPlayingMusicId))
  log(bWriteLog and "audio_manager:_GetCurrentPlayMusic bActiveStop:" .. tostring(self.bActiveStop))
  if self.curPlayingMusicId and not self.bActiveStop then
    local audio_instance = audio_instances[self.curPlayingMusicId]
    if audio_instance and audio_instance:GetSourcePlayPosition() ~= C_DefalutPosition then
      return audio_instance
    end
  end
  return nil
end
function audio_manager:GetCurPlayingMusicId()
  return self.curPlayingMusicId
end
function audio_manager:_PauseCurrentPlayMusic()
  local cur_music = self:_GetCurrentPlayMusic()
  if cur_music then
    cur_music:Pause()
  end
end
function audio_manager:_GetCurrentPauseMusic()
  if self.curPlayingMusicId and not self.bActiveStop then
    local audio_instance = audio_instances[self.curPlayingMusicId]
    if audio_instance and audio_instance:GetSourcePausePosition() ~= C_DefalutPosition then
      return audio_instance
    end
  end
  return nil
end
function audio_manager:_ResumeCurrentPauseMusic()
  local cur_music = self:_GetCurrentPauseMusic()
  if cur_music then
    cur_music:Resume()
    self.bActiveStop = false
  end
end
function audio_manager:UpdateCurPlayMusicId(sound_id)
  local audio_instance = audio_instances[sound_id]
  if audio_instance and audio_instance:GetAudioType() == UEnums.LobbyAudioType.Music then
    self.curPlayingMusicId = sound_id
    self.bActiveStop = false
  end
end
function audio_manager:IsMusicBox()
  if UIManager.IsUIShow(UIManager.UI_Config.pubgm_music_main) then
    log(bWriteLog and "xcc audio_manager:IsMusicBox music play by pubgm_music_main")
    return true
  end
  return false
end
function audio_manager:CheckCanPlayLobbyBgm()
  local cur_music = self:_GetCurrentPlayMusic()
  if cur_music then
    return false
  end
  return true
end
function audio_manager:RestoreMusic()
  GlobalData.RestoreLobbyBGM()
end
function audio_manager:EnableMusicPlayer()
  GlobalData.RestoreLobbyBGM()
end
function audio_manager:DisableMusicPlayer()
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  musicManager:StopMusic()
end
function audio_manager:OnApplicationReactivated()
  if self:IsMusicBox() then
    return
  end
  self:_ResumeCurrentPauseMusic()
end
function audio_manager:OnApplicationDeactivated()
  if self:IsMusicBox() then
    return
  end
  self:_PauseCurrentPlayMusic()
end
function audio_manager:OnVideoStart()
  self:_PauseCurrentPlayMusic()
end
function audio_manager:OnVideoEnd()
  self:_ResumeCurrentPauseMusic()
end
function audio_manager:OnWebReactivated()
  log(bWriteLog and "audio_manager:OnWebReactivated")
  if not GameStatus.IsInLobbyOrMainCity() then
    printf("audio_manager:OnWebReactivated not lobby status, curStatus=%s", GameStatus.GetGameStatus())
    return
  end
  if self:IsMusicBox() then
    return
  end
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  local cur_music = self:_GetCurrentPauseMusic()
  if cur_music then
    printf("audio_manager:OnWebReactivated, cur_music=%s self:GetPlayerMode()=%s", cur_music, self:GetPlayerMode())
    cur_music:Resume()
    if self:GetPlayerMode() == 1 then
      musicManager:ResetTicker()
    end
  elseif self:GetPlayerMode() == 1 then
    log(bWriteLog and "audio_manager:OnWebReactivated, self:GetPlayerMode() == 1. ")
    musicManager:StopMusic()
  else
    log(bWriteLog and "audio_manager:OnWebReactivated, else. ")
    GlobalData.RestoreLobbyBGM()
  end
end
function audio_manager:OnWebDeactivated()
  log(bWriteLog and "audio_manager:OnWebDeactivated")
  if self:IsMusicBox() then
    return
  end
  local cur_music = self:_GetCurrentPlayMusic()
  if cur_music then
    cur_music:Pause()
  else
    log(bWriteLog and "audio_manager:OnWebDeactivated, else. ")
    local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
    musicManager:StopMusic()
  end
end
function audio_manager:GetPlayerMode()
  return self.player_mode
end
function audio_manager:SetPlayerMode(mode)
  self.player_end
function audio_manager:InitSoundEffectQuality()
  local nLevel = Client.GetSoundEffectQuality()
  log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality, nLevel = " .. tostring(nLevel))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if IsEditor then
    return
  end
  local bShouldResetToHighAudio = false
  local version_util = require("client.common.version_util")
  if nLevel == 2 and PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {C_HighAudioPufferKey}) ~= ENUM_DownloadState.Done then
    log(bWriteLog and "[DeanJYT] [DeanJYT] audio_manager:InitSoundEffectQuality was ultra, download state check failed, check local files")
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
    for _, filename in pairs(ret) do
      if string.find(filename, "res_audiohigh_") and version_util.CompareVersionStandard(string.sub(filename, 15), version_util.GetAppVersion()) then
        log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality found local high audio file, do not reset to high")
        return
      end
    end
    log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality was ultra, should reset to high")
    bShouldResetToHighAudio = true
  elseif nLevel == 0 and PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {C_LowAudioPufferKey}) ~= ENUM_DownloadState.Done then
    log(bWriteLog and "[DeanJYT] [DeanJYT] audio_manager:InitSoundEffectQuality was low, download state check failed, check local files")
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
    for _, filename in pairs(ret) do
      if string.find(filename, "res_audiolow_") and version_util.CompareVersionStandard(string.sub(filename, 14), version_util.GetAppVersion()) then
        log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality found local low audio file, do not reset to high")
        return
      end
    end
    log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality was low, should reset to high")
    bShouldResetToHighAudio = true
  end
  if bShouldResetToHighAudio and Client.SetSoundEffectQuality(1) then
    log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality should reset to high, and was successful")
  else
    log(bWriteLog and "[DeanJYT] audio_manager:InitSoundEffectQuality not reseted to high, bShouldResetToHighAudio = " .. tostring(bShouldResetToHighAudio))
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Caudio_manager = class(CModuleBase, nil, audio_manager)
return Caudio_manager