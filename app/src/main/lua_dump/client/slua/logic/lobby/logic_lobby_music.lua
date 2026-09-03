local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
local logic_lobby_music = {}
function logic_lobby_music.SwitchLobbyBGM()
  if not GameStatus.IsIn2DLobby() then
    log(bWriteLog and "logic_lobby_music.SwitchLobbyBGM() not in 2D lobby")
    return
  end
  if logic_lobby_music.playerTicker then
    log(bWriteLog and "logic_lobby_music.SwitchLobbyBGM() playerTicker is not nil")
    return
  end
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  if not logic_pubgm_music.CheckCanPlayMusic() then
    log(bWriteLog and "logic_lobby_music.SwitchLobbyBGM() CheckCanPlayMusic() false")
    return
  end
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  if not audio_manager:CheckCanPlayLobbyBgm() then
    log(bWriteLog and "logic_lobby_music.SwitchLobbyBGM() CheckCanPlayLobbyBgm() false")
    return
  end
  if not musicManager:PlayLobbyMusic() and not musicManager:GetOpenMusicBox() then
    GlobalData.StopLobbyBGM()
    musicManager:ReSetData()
    local bgmPath, bgmTime = logic_lobby_music.GetDefaultBgmPath()
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(bgmPath)
    local time_ticker = require("common.time_ticker")
    logic_lobby_music.playerTicker = time_ticker.AddTimerOnce(bgmTime, function()
      logic_lobby_music.playerTicker = nil
      local switchSuccess = musicManager:SwitchToLobbyBgm()
      if not switchSuccess then
        logic_lobby_music.SwitchLobbyBGM()
      end
    end)
  end
end
function logic_lobby_music.ClearPlayerTicker()
  if logic_lobby_music.playerTicker then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(logic_lobby_music.playerTicker)
    logic_lobby_music.playerTicker = nil
  end
end
function logic_lobby_music.GetDefaultBgmPath()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local Region = "Default"
  if PublishRegionMacros.IsBLUEHOLE() then
    Region = "BlueHole"
  elseif PublishRegionMacros.IsJapanOrKorea() then
    Region = "KRJP"
  end
  local bgmCfg = CDataTable.GetTableData("LobbyDefaultBgm", Region)
  if bgmCfg and bgmCfg.VersionBgmPath ~= "" and logic_lobby_music.CheckVersionMusicDownload(bgmCfg.VersionBgmPath) then
    return bgmCfg.VersionBgmPath, bgmCfg.VersionBgmDuration
  end
  return bgmCfg.BgmPath, bgmCfg.BgmDuration
end
function logic_lobby_music.CheckVersionMusicDownload(path)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {path})
  if state == PufferConst.ENUM_DownloadState.Done then
    return true
  end
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {path}, nil, function()
    logic_lobby_music.SwitchLobbyBGM()
  end, {bFirst = true})
  return false
end
return logic_lobby_music