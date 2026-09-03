local music_manager = {}
local logic_music_const = require("client.slua.logic.pubgm_music.logic_music_const")
local logic_pubgm_music_download = require("client.slua.logic.pubgm_music.logic_pubgm_music_download")
local logic_pubgm_music_option = require("client.slua.logic.pubgm_music.logic_pubgm_music_option")
local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local TableUtil = require("common.table_util")
local audio_util = require("client.common.audio_util")
local TimeUtil = require("client.common.time_util")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local util = require("client.slua_ui_framework.util")
local UIUtil = require("client.common.ui_util")
local StringUtil = require("common.string_util")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local E_MusicPlayMode = logic_music_const.E_MusicPlayMode
local E_MusicPlayStage = logic_music_const.E_MusicPlayStage
local E_CurPage = logic_music_const.E_CurPage
local E_CurMusicTime = logic_music_const.E_CurMusicTime
local E_DontPlaySamplePage = logic_music_const.E_DontPlaySamplePage
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
function music_manager:DefineAndResetData()
  logic_pubgm_music_option.OnMusicBoxDataRsp()
  self:ReSetData()
  self.bOpenMusicBox = false
  self.newMusicData = nil
  self.EmotionToMusic = nil
  self.bBlackRegion = false
end
function music_manager:ReSetData()
  self.curMusicList = {}
  self.curMode = E_MusicPlayMode.Loop
  self.playerTicker = nil
  self.curMusicId = nil
  self.curMusicIndex = 0
  self.oldPlayProgress = nil
  self.curMusicStartTime = nil
  self.curMusicTime = nil
  self.curPlayTime = {
    [E_CurMusicTime.Duration] = 0,
    [E_CurMusicTime.PlayTime] = 0,
    [E_CurMusicTime.RemainTime] = 0
  }
  self.nextMusicId = nil
  self.nextMusicIndex = 0
  self.curMusicPage = E_CurPage.Lobby
  self.curMusicState = E_MusicPlayStage.Stop
  self.needSwitchLobbyMusic = false
end
function music_manager:GetCurMusicTime()
  return self.curPlayTime
end
function music_manager:GetCurMusicId(bGuarantee)
  if self.curMusicId then
    return self.curMusicId
  end
  if bGuarantee and self.nextMusicId then
    return self.nextMusicId
  end
  return nil
end
function music_manager:GetCurMusicIndex(bGuarantee)
  if self.curMusicIndex then
    return self.curMusicIndex
  end
  if bGuarantee and self.nextMusicIndex then
    return self.nextMusicIndex
  end
  return nil
end
function music_manager:GetCurMusicInfo(bGuarantee)
  if self.curMusicIndex then
    return self.curMusicList[self.curMusicIndex]
  end
  if bGuarantee and self.nextMusicIndex then
    return self.curMusicList[self.nextMusicIndex]
  end
  return nil
end
function music_manager:GetCurMusicList()
  return self.curMusicList or {}
end
function music_manager:GetMusicInfoByIndex(index)
  if not self.curMusicList or not next(self.curMusicList) then
    return nil
  end
  return self.curMusicList[index]
end
function music_manager:GetCurrentPage()
  return self.curMusicPage
end
function music_manager:GetCurPlayStage()
  return self.curMusicState
end
function music_manager:GetOpenMusicBox()
  return self.bOpenMusicBox
end
function music_manager:RePlayCurMusic()
  if self.curMusicIndex and not self.playerTicker then
    self:PlayMusic(self.curMusicIndex)
  end
end
function music_manager:GetIsBlackRegion()
  return self.bBlackRegion
end
function music_manager:InitMusicList(musicList, mode, curPage, repeatSongId, bRePlay)
  log_tree(bWriteLog and "music_manager:InitMusicList", musicList)
  self.curMusicPage = curPage
  self.curMode = mode
  self.curMusicList = {}
  self.curMusicId = self:GetCurMusicId(true) or repeatSongId
  self.nextMusicId = nil
  self.nextMusicIndex = nil
  if not musicList or not next(musicList) then
    log(bWriteLog and "music_manager.InitMusicList, musicList = nil")
    return
  end
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  local musicId = audio_manager:GetCurPlayingMusicId()
  self.curMusicId = self.curMusicId or musicId
  self.curMusicList = musicList
  if self.curMode == E_MusicPlayMode.SingleLoop then
    self.nextMusicId = repeatSongId
    self.nextMusicIndex = 1
    log(bWriteLog and "music_manager:InitMusicList E_MusicPlayMode.REPEAT self.nextMusicId = " .. tostring(self.nextMusicId) .. "self.nextMusicIndex = " .. tostring(self.nextMusicIndex))
  end
  if not self.nextMusicId and self.curMusicId then
    local index = TableUtil.FindTable(musicList, function(_, music)
      self:RefreshMusicDownloadState(music)
      return music.nID == self.curMusicId
    end)
    if index and 0 < index and index <= #musicList then
      self.nextMusicIndex = index
      self.nextMusicId = musicList[index].nID
      log(bWriteLog and "music_manager:InitMusicList self.curMusicId self.nextMusicId = " .. tostring(self.nextMusicId) .. "self.nextMusicIndex = " .. tostring(self.nextMusicIndex))
    end
  end
  if bRePlay then
    self.curMusicIndex = nil
    self.curMusicId = nil
  end
  log(bWriteLog and "music_manager:InitMusicList ENUM_DownloadState.Done self.nextMusicId = " .. tostring(self.nextMusicId) .. "self.nextMusicIndex = " .. tostring(self.nextMusicIndex))
end
function music_manager:BeginPlayMusicList()
  if not self.curMusicList or not next(self.curMusicList) then
    log(bWriteLog and "music_manage:BeginPlayMusicList: self.curMusicList == nil")
    self:StopMusic()
    return false
  end
  if self.curMode == E_MusicPlayMode.SingleLoop and self.nextMusicId then
    local music = self.curMusicList[self.nextMusicIndex] or self.curMusicList[1]
    self:RefreshMusicDownloadState(music)
    if music.nState ~= ENUM_DownloadState.Done then
      return false
    end
    self:PlayMusic(1)
    return true
  end
  if self.nextMusicId and self.nextMusicIndex and self.nextMusicIndex <= #self.curMusicList then
    local music = self.curMusicList[self.nextMusicIndex]
    self:RefreshMusicDownloadState(music)
    if music.nState ~= ENUM_DownloadState.Done then
      return false
    end
    self:PlayMusic(self.nextMusicIndex)
    return true
  end
  if self.curMode == E_MusicPlayMode.Random then
    local index = self:GetRandomMusic()
    self:PlayMusic(index)
    return true
  end
  local bPlay = false
  for index, music in pairs(self.curMusicList) do
    self:RefreshMusicDownloadState(music)
    if not bPlay and music.nState == ENUM_DownloadState.Done then
      self:PlayMusic(index)
      bPlay = true
    end
  end
  return bPlay
end
function music_manager:PlayMusic(index)
  local music = index and self.curMusicList and self.curMusicList[index]
  if not music then
    self:StopMusic()
    log(bWriteLog and "music_manager:PlayMusic music = nil, then stop music")
    return false
  end
  local path = TableUtil.GetTableValue(music, "cfg", "play_event")
  if not path then
    log(bWriteLog and "music_manager:PlayMusic, path = nil" .. tostring(music.nID))
    return false
  end
  log(bWriteLog and string.format("music_manager:PlayMusic music id = %d", music.nID))
  local isLocked = TableUtil.GetTableValue(music, "data") == nil
  self.nextMusicId = music.nID
  self.nextMusicIndex = index
  self:RefreshMusicDownloadState(music)
  if music.nState ~= ENUM_DownloadState.Done then
    log(bWriteLog and "music_manager:PlayMusic, music.nState ~= ENUM_DownloadState.Done. ")
    if isLocked then
      log(bWriteLog and "music_manager:PlayMusic, self.StopMusic().")
      self:StopMusic()
      return
    else
      local nextIndex = self:GetNextMusic(index)
      if nextIndex then
        self:PlayMusic(nextIndex)
        return true
      end
    end
    log(bWriteLog and "music_manager:PlayMusic, \233\135\141\230\150\176\232\142\183\229\143\150\228\184\139\232\189\189\231\138\182\230\128\129\229\144\142: nstate = " .. tostring(music.nState))
    return false
  end
  self:StopMusic()
  self.oldPlayProgress = nil
  self.curMusicState = E_MusicPlayStage.Play
  self.curMusicId = music.nID
  self.curMusicIndex = index
  self.nextMusicId = nil
  self.nextMusicIndex = nil
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  audio_manager:Start(self.curMusicId, true)
  log(bWriteLog and "music_manager:PlayMusic, self.curMusicPage\239\188\140 " .. tostring(self.curMusicPage))
  if not E_DontPlaySamplePage[self.curMusicPage] and isLocked then
    self:UpdateCurMusicTime(music and music.PreviewDuration or logic_music_const.SAMPLETIME)
  else
    self:UpdateCurMusicTime(TableUtil.GetTableValue(music, "cfg", "duration") or 0)
  end
  self:ResetTicker()
  EventSystem:postEvent(EVENTTYPE_MUSIC_PLAYER, EVENTID_MUSIC_PLAYER_PLAY, true)
  return true
end
function music_manager:GetPreMusic(curIndex, bClick, bDownload)
  curIndex = curIndex or 0
  log(bWriteLog and "music_manager:GetPreMusic")
  if not self.curMusicList or not next(self.curMusicList) then
    return nil
  end
  if not bClick and self.curMode == E_MusicPlayMode.SingleLoop then
    local music = self.curMusicList[curIndex]
    self:RefreshMusicDownloadState(music, bDownload)
    return music.nState == ENUM_DownloadState.Done and curIndex
  elseif self.curMode == E_MusicPlayMode.Random then
    return self:GetRandomMusic(bDownload)
  end
  if 1 <= curIndex - 1 then
    for i = curIndex - 1, 1, -1 do
      local music = self.curMusicList[i]
      self:RefreshMusicDownloadState(music, bDownload)
      local isLocked = TableUtil.GetTableValue(music, "data") == nil
      if isLocked and i == curIndex - 1 then
        return i
      elseif music.nState == ENUM_DownloadState.Done then
        return i
      end
    end
  end
  for i = #self.curMusicList, curIndex, -1 do
    local music = self.curMusicList[i]
    self:RefreshMusicDownloadState(music, bDownload)
    local isLocked = TableUtil.GetTableValue(music, "data") == nil
    if isLocked and i == #self.curMusicList then
      return i
    elseif music.nState == ENUM_DownloadState.Done then
      return i
    end
  end
  return nil
end
function music_manager:CleanTicker()
  if self.playerTicker ~= nil then
    log(bWriteLog and "music_manager.ResetTicker, self.playerTicker ~= nil")
    self:RemoveTimer(self.playerTicker)
    self.playerTicker = nil
    self.oldPlayProgress = nil
  end
end
function music_manager:ResetTicker()
  self:CleanTicker()
  if self.curPlayTime[E_CurMusicTime.RemainTime] <= 0 then
    return
  end
  self.curMusicStartTime = TimeUtil.GetServerTimeInSec()
  local endTime = self.curMusicStartTime + self.curPlayTime[E_CurMusicTime.RemainTime]
  self.playerTicker = self:AddTimerLoop(0, function()
    self.curMusicTime = TimeUtil.GetServerTimeInSec()
    if self.curMusicTime >= endTime then
      local nextIndex = self:GetNextMusic(self:GetCurMusicIndex(true), false, false)
      self:PlayMusic(nextIndex)
      return
    end
    if self.curMusicState == E_MusicPlayStage.Play then
      local oldPlayProgress = self.oldPlayProgress or 0
      local playTime = self.curMusicTime - self.curMusicStartTime + oldPlayProgress
      self:UpdateCurMusicTime(nil, playTime)
      EventSystem:postEvent(EVENTTYPE_MUSIC_PLAYER, EVENTID_MUSIC_PLAYER_UPDATE)
    end
  end, 0, 1)
end
function music_manager:StopMusic()
  log(bWriteLog and "music_manager.StopMusic")
  self:PauseCurMusic()
  self:UpdateCurMusicTime(0)
  self:CleanTicker()
  audio_util.PlayAudio(sound_config.music_stop)
  audio_util.PlayAudio(sound_config.TPlan_Stop_BGM)
  self.curMusicState = E_MusicPlayStage.Stop
  self.curPlayingPage = nil
  self.oldPlayProgress = nil
  EventSystem:postEvent(EVENTTYPE_MUSIC_PLAYER, EVENTID_MUSIC_PLAYER_END)
end
function music_manager:PauseCurMusic()
  self.curMusicState = E_MusicPlayStage.Pause
  self:CleanTicker()
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  local musicId = audio_manager:GetCurPlayingMusicId()
  local _ = musicId and audio_manager:Pause(musicId)
end
function music_manager:ResumeCurMusic()
  log(bWriteLog and "music_manager.ResumeCurMusic")
  self.oldPlayProgress = nil
  if self.curMusicState == E_MusicPlayStage.Pause then
    self.curMusicState = E_MusicPlayStage.Play
    if self:CheckMusicTime() then
      local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
      local musicId = self:GetCurMusicId(true)
      audio_manager:Resume(musicId)
      self:ResetTicker()
      self.oldPlayProgress = self.curPlayTime[E_CurMusicTime.PlayTime]
    else
      local index = self:GetCurMusicIndex(true)
      local nextIndex = index and self:GetNextMusic(index + 1)
      self:PlayMusic(nextIndex)
    end
  else
    self.nextMusicIndex = self:GetCurMusicIndex(true)
    self.nextMusicId = self:GetCurMusicId(true)
    return self:BeginPlayMusicList()
  end
end
function music_manager:PlayCurMusicAtTime(time)
  log(bWriteLog and "music_manager.PlayCurMusicAtTime, time = " .. time)
  local index = self:GetCurMusicIndex(true)
  local music = self.curMusicList[index]
  if not music then
    log(bWriteLog and "music_manager:PlayCurMusicAtTime, music = nil")
    return
  end
  self:UpdateCurMusicTime(nil, time)
  if self.curPlayTime[E_CurMusicTime.RemainTime] <= 0 then
    local nextIndex = index and self:GetNextMusic(index + 1)
    self:PlayMusic(nextIndex)
  else
    self:RefreshMusicDownloadState(music)
    if music.nState == ENUM_DownloadState.Done then
      local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
      local musicId = self:GetCurMusicId(true)
      audio_manager:ResumeAtTime(musicId, time * 1000)
      self:ResetTicker()
      self.oldPlayProgress = time
      self.curMusicState = E_MusicPlayStage.Play
      EventSystem:postEvent(EVENTTYPE_MUSIC_PLAYER, EVENTID_MUSIC_PLAYER_PLAY, false)
    end
  end
end
function music_manager:IsInHome()
  return self.curMusicPage == E_CurPage.Home or self.curMusicPage == E_CurPage.HomeConsoleMusic or self.curMusicPage == E_CurPage.Wedding
end
function music_manager:PlayLobbyMusic()
  log(bWriteLog and "music_manager:PlayDefaultBGM")
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  if not logic_pubgm_music.IsOpen() then
    log(bWriteLog and "music_manager:PlayDefaultBGM is not open")
    return false
  end
  local lobbyList, repeatMode, repeatSong = logic_pubgm_music_option.GetLobbyDetailData()
  lobbyList = self:RemoveExpireMusicByMusicList(lobbyList)
  if not lobbyList or not next(lobbyList) then
    self:StopMusic()
    log(bWriteLog and "music_manager:PlayDefaultBGM lobbyList is nil")
    return false
  end
  local TLogReasonStr = json.encode({
    lobbyBgmCount = lobbyList and #lobbyList or 0
  })
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LOBBY_BGM_TLOG, 0, TLogReasonStr)
  if not self:CheckMusicListDownloadState(lobbyList) then
    self.needSwitchLobbyMusic = self.needSwitchLobbyMusic == nil
    log(bWriteLog and "music_manager:PlayLobbyMusic download done count is 0")
    return false
  end
  if self.bOpenMusicBox then
    log(bWriteLog and "xcc music play by pubgm_music_main")
    return true
  end
  if not GameStatus.IsIn2DLobby() then
    log(bWriteLog and "music_manager:PlayLobbyMusic status is not lobby")
    return true
  end
  local bRePlay = self.curMusicState ~= E_MusicPlayStage.Play
  self:InitMusicList(lobbyList, repeatMode, E_CurPage.Lobby, repeatSong, bRePlay)
  if not bRePlay then
    log(bWriteLog and "music_manager:PlayLobbyMusic music is playing")
    return true
  end
  log(bWriteLog and "music_manager:PlayLobbyMusic re beginplay")
  return self:BeginPlayMusicList()
end
function music_manager:RemoveExpireMusicByMusicList(musicList)
  local serverTime = FuncUtil.GetServerTimeInSec()
  local newMusicList = {}
  if not musicList or not next(musicList) then
    return musicList
  end
  for key, value in pairs(musicList) do
    if TableUtil.GetTableValue(value, "data") and (serverTime <= value.data.expire_time or value.data.expire_time == 0) then
      table.insert(newMusicList, value)
    end
  end
  return newMusicList
end
function music_manager:CheckMusicListDownloadState(musicList)
  local notReadyMusicCount = 0
  if not musicList or not next(musicList) then
    return false
  end
  for key, music in pairs(musicList) do
    self:RefreshMusicDownloadState(music, true)
    if music.nState ~= ENUM_DownloadState.Done then
      notReadyMusicCount = notReadyMusicCount + 1
    end
  end
  if notReadyMusicCount == #musicList then
    return false
  end
  return true
end
function music_manager:SwitchToLobbyBgm()
  if self.needSwitchLobbyMusic == nil then
    return true
  end
  if self.needSwitchLobbyMusic then
    self.needSwitchLobbyMusic = false
    GlobalData.StopLobbyBGM()
    local switchOk = self:PlayDefaultBGM()
    return switchOk
  end
  return false
end
function music_manager:EnterMusicBox()
  self.curMusicState = E_MusicPlayStage.Stop
  GlobalData.StopLobbyBGM()
  audio_util.SetRTPCValue("MusicPlayer_Volume", 1, 0)
  audio_util.SetRTPCValue("VolumeControl_Music", 100, 0)
  self.bOpenMusicBox = true
end
function music_manager:ExitMusicBox()
  local saveGame = slua_GameFrontendHUD:GetUserSettings()
  if saveGame.BGMVolumSwitcher then
    audio_util.SetRTPCValue("MusicPlayer_Volume", saveGame.BGMVolumValue, 0)
    audio_util.SetRTPCValue("VolumeControl_Music", saveGame.BGMVolumValue * 100, 0)
  else
    audio_util.SetRTPCValue("MusicPlayer_Volume", 0, 0)
    audio_util.SetRTPCValue("VolumeControl_Music", 0, 0)
  end
  self:StopMusic()
  self.oldPlayProgress = nil
  self.bOpenMusicBox = false
  local logic_lobby_music = require("client.slua.logic.lobby.logic_lobby_music")
  logic_lobby_music.SwitchLobbyBGM()
end
function music_manager:PlayNextMusic()
  local nextIndex = self:GetNextMusic(self:GetCurMusicIndex(true), true, true)
  self:PlayMusic(nextIndex)
end
function music_manager:PlayPreMusic()
  local preIndex = self:GetPreMusic(self:GetCurMusicIndex(true), true, true)
  self:PlayMusic(preIndex)
end
function music_manager:UpdateCurMusicTime(duration, playTime)
  if duration and duration == 0 then
    self.curPlayTime[E_CurMusicTime.Duration] = 0
    self.curPlayTime[E_CurMusicTime.PlayTime] = 0
    self.curPlayTime[E_CurMusicTime.RemainTime] = 0
  elseif duration and 0 < duration then
    self.curPlayTime[E_CurMusicTime.Duration] = duration
    self.curPlayTime[E_CurMusicTime.PlayTime] = 0
    self.curPlayTime[E_CurMusicTime.RemainTime] = duration
  elseif playTime then
    self.curPlayTime[E_CurMusicTime.PlayTime] = playTime
    self.curPlayTime[E_CurMusicTime.RemainTime] = self.curPlayTime[E_CurMusicTime.Duration] - playTime
  end
end
function music_manager:RefreshMusicDownloadState(music, bDownload)
  if music and music.nState ~= ENUM_DownloadState.Done then
    music.nState = logic_pubgm_music_download.GetMusicDownloadStateByID(music.nID)
    local needDownload = bDownload or PufferSwitch.BanAutoDownload
    if needDownload and music.nState == ENUM_DownloadState.Not then
      if self.curMusicPage == E_CurPage.OtherSocialLobby then
        logic_pubgm_music_download.DownloadOtherMusic(music.nID)
      else
        logic_pubgm_music_download.Download(music.nID)
      end
    end
  end
end
function music_manager:GetNextMusic(curIndex, bClick, bDownload)
  curIndex = curIndex or 1
  log(bWriteLog and "music_manager:GetNextMusic curIndex:" .. tostring(curIndex))
  if not self.curMusicList or not next(self.curMusicList) then
    return nil
  end
  if not bClick and self.curMode == E_MusicPlayMode.SingleLoop then
    local music = self.curMusicList[curIndex]
    self:RefreshMusicDownloadState(music, bDownload)
    return music.nState == ENUM_DownloadState.Done and curIndex
  elseif self.curMode == E_MusicPlayMode.Random then
    return self:GetRandomMusic(bDownload)
  end
  if curIndex + 1 <= #self.curMusicList then
    for i = curIndex + 1, #self.curMusicList do
      local music = self.curMusicList[i]
      self:RefreshMusicDownloadState(music, bDownload)
      local isLocked = TableUtil.GetTableValue(music, "data") == nil
      if isLocked and i == curIndex + 1 then
        return i
      elseif music.nState == ENUM_DownloadState.Done then
        return i
      end
    end
  end
  for i = 1, curIndex do
    local music = self.curMusicList[i]
    self:RefreshMusicDownloadState(music, bDownload)
    local isLocked = TableUtil.GetTableValue(music, "data") == nil
    if isLocked and i == 1 then
      return i
    elseif music.nState == ENUM_DownloadState.Done then
      return i
    end
  end
  return nil
end
function music_manager:GetRandomMusic(bDownload)
  local downloadMusicList = {}
  for index, music in ipairs(self.curMusicList) do
    self:RefreshMusicDownloadState(music, bDownload)
    if music.nState == ENUM_DownloadState.Done then
      table.insert(downloadMusicList, index)
    end
  end
  if 0 < #downloadMusicList then
    local randomIndex = math.random(1, 100000)
    local index = randomIndex % #downloadMusicList + 1
    return downloadMusicList[index]
  end
end
function music_manager:CheckMusicTime()
  if self.curPlayTime[E_CurMusicTime.PlayTime] >= self.curPlayTime[E_CurMusicTime.Duration] then
    return false
  else
    return true
  end
end
function music_manager:SwitchScheme(mode)
  self.curMode = mode or E_MusicPlayMode.Loop
end
function music_manager:IsNewVersionMusic(musicData)
  if not musicData then
    log(bWriteLog and "music_manager:IsNewVersionMusic, musicData = nil")
    return false
  end
  if not self.newMusicData then
    self.newMusicData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewMusicData) or {}
  end
  if musicData.bNew and not self.newMusicData[musicData.nID] then
    return true
  end
  return false
end
function music_manager:SaveNewVersionMusic(musicId)
  log(bWriteLog and "music_manager:SaveNewVersionMusic for musicId: " .. tostring(musicId))
  if not self.newMusicData then
    self.newMusicData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewMusicData) or {}
  end
  self.newMusicData[musicId] = 1
  PlayerPrefsSystem.SaveTableToFile_N(self.newMusicData, PlayerPrefsSystem.ePlayerPrefsType.eNewMusicData)
end
function music_manager:SetEmotionMusicQuality(imageWidget, itemData)
  if not self.EmotionToMusic then
    self.EmotionToMusic = {}
    local EmotionToMusicCache = CDataTable.GetTable("EmotionToMusic")
    for EmotionID, music in pairs(EmotionToMusicCache) do
      self.EmotionToMusic[music.MusicID] = EmotionID
    end
  end
  if self.EmotionToMusic[itemData.nID] then
    local itemCfg = CDataTable.GetTableData("Item", self.EmotionToMusic[itemData.nID])
    local imagePath = UIUtil.GetBgQualityPath(itemCfg.ItemQuality)
    util.SetTexture(imageWidget, imagePath)
    imageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    imageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function music_manager:IsBlackWithRegionAndPath(region, path, bSetIpMute)
  region = region or FuncUtil.GetAccountRegionForBP()
  local bJP = PublishRegionMacros.IsJapanOrKorea() and region == AccountRegionForBPMacros.JP
  local AkGameplayStatics = import("AkGameplayStatics")
  local _ = bSetIpMute and AkGameplayStatics.SetRegionIpMute(bJP)
  if bJP then
    self.bBlackRegion = true
    local strings = StringUtil.Split(path, ".")
    if 0 < #strings and CDataTable.GetTableData("JpHideSoundCfg", strings[#strings]) then
      return true
    end
  end
  return false
end
function music_manager:CheckMusicLimit(musicInfo)
  local hasEndTime = 0 < (TableUtil.GetTableValue(musicInfo, "cfg", "end_time") or 0)
  local hasExpTime = 0 < (TableUtil.GetTableValue(musicInfo, "data", "expire_time") or 0)
  local isNoPermanent = (TableUtil.GetTableValue(musicInfo, "data", "permanent_count") or 0) == 0
  local isLimited = hasEndTime or hasExpTime and isNoPermanent
  return isLimited
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cmusic_manager = class(CModuleBase, nil, music_manager)
return Cmusic_manager