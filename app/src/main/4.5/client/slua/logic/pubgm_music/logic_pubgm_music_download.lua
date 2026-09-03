local logic_music_const = require("client.slua.logic.pubgm_music.logic_music_const")
local logic_pubgm_music_util = require("client.slua.logic.pubgm_music.logic_pubgm_music_util")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local E_MusicDownloadType = logic_music_const.E_MusicDownloadType
local E_MusicOwnedState = logic_music_const.E_MusicOwnedState
local logic_pubgm_music_download = {configs = nil}
function logic_pubgm_music_download.GetMusicDownloadStateByID(id)
  if not logic_pubgm_music_download.configs then
    logic_pubgm_music_download.configs = logic_pubgm_music_util.GetConfig()
  end
  if logic_pubgm_music_download.configs[id] then
    return logic_pubgm_music_download.GetMusicDownloadState(id, logic_pubgm_music_download.configs[id])
  end
  local logic_home_music = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_music)
  local homeMusicConfig = logic_home_music:GetHomeMusicConfig()
  if homeMusicConfig and homeMusicConfig[id] then
    return logic_pubgm_music_download.GetMusicDownloadState(id, homeMusicConfig[id])
  end
  log(bWriteLog and "[muidarzhang] logic_pubgm_music_download.GetMusicDownloadStateByID(id) there is no configs")
  return ENUM_DownloadState.Not
end
function logic_pubgm_music_download.GetMusicDownloadState(id, cfg)
  if not id or not cfg then
    log(bWriteLog and "[muidarzhang] ERROR: logic_pubgm_music_download.GetMusicDownloadState, not id or not cfg. ")
    return ENUM_DownloadState.Not
  end
  if cfg.download_type == E_MusicDownloadType.HDmpve then
    local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {id})
    return dowloadState
  elseif cfg.content_url and cfg.content_url ~= "" then
    local savePath = Client.ProjectSavedDir() .. string.format("MusicPlayer/%s", logic_pubgm_music_util.GetPakNameConcatVersion(cfg.content_url))
    local cdn_downloader = require("client.common.cdn_downloader")
    log(bWriteLog and string.format("logic_pubgm_music_download.GetMusicDownloadState, id:%s", id))
    if cdn_downloader.MountPakFile(savePath) then
      log(bWriteLog and "logic_pubgm_music_download.GetMusicDownloadState, cdn_downloader.MountPakFile(savePath). ")
      return ENUM_DownloadState.Done
    else
      log(bWriteLog and "logic_pubgm_music_download.GetMusicDownloadState, else. ")
      return ENUM_DownloadState.Not
    end
  end
  return ENUM_DownloadState.Not
end
function logic_pubgm_music_download.RefreshDownloadingState(id, list)
  if not logic_pubgm_music_download.configs then
    logic_pubgm_music_download.configs = logic_pubgm_music_util.GetConfig()
  end
  for k, v in ipairs(logic_pubgm_music_download.configs) do
    if k == id then
      v.state = ENUM_DownloadState.Download
      break
    end
  end
  if list then
    for _, v in ipairs(list) do
      if id == v.nID then
        v.nState = ENUM_DownloadState.Download
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_DOWNLOAD)
end
function logic_pubgm_music_download.OnDownloadFromHDmpve(id, list)
  logic_pubgm_music_download.RefreshDownloadingState(id, list)
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {id}, nil, logic_pubgm_music_download.OnDownloadPak)
end
function logic_pubgm_music_download.DownLoadFromCDN(id, url, list)
  logic_pubgm_music_download.RefreshDownloadingState(id, list)
  local cdn_downloader = require("client.common.cdn_downloader")
  local downloadPath = string.format("%sPatchFile/%s.pak", cdn_downloader.GetCDNFileDir("AFD"), url)
  local savePath = Client.ProjectSavedDir() .. string.format("MusicPlayer/%s", logic_pubgm_music_util.GetPakNameConcatVersion(url))
  cdn_downloader.DownloadPak(downloadPath, savePath, logic_pubgm_music_download.OnDownloadCDN)
end
function logic_pubgm_music_download.OnDownloadPak(id)
  logic_pubgm_music_download.UpdateAllMusicDownloadState()
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  if not logic_pubgm_music.CheckPlayingOtherBGM() then
    EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_DOWNLOAD_FINISH, id)
  end
end
function logic_pubgm_music_download.OnDownloadCDN(isSuccess)
  log(bWriteLog and "[muidarzhang]  logic_pubgm_music_download.OnDownloadCDN" .. tostring(isSuccess))
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  if isSuccess and not logic_pubgm_music.CheckPlayingOtherBGM() then
    logic_pubgm_music_download.UpdateAllMusicDownloadState()
    EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_DOWNLOAD_FINISH)
  end
end
function logic_pubgm_music_download.UpdateAllMusicDownloadState()
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  local TableUtil = require("common.table_util")
  for i = 1, TableUtil.CountTable(E_MusicOwnedState) do
    local list = logic_pubgm_music.GetMusicDataByOwnedState(i)
    for _, v in ipairs(list) do
      v.nState = logic_pubgm_music_download.GetMusicDownloadState(v.nID, v.cfg)
    end
  end
end
function logic_pubgm_music_download.Download(id)
  log(bWriteLog and "[muidarzhang] logic_pubgm_music_download.Download, id:" .. tostring(id))
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  local list = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.All)
  for _, v in ipairs(list) do
    if id == v.nID then
      if v.cfg.download_type == E_MusicDownloadType.HDmpve then
        logic_pubgm_music_download.OnDownloadFromHDmpve(id, list)
        break
      end
      if v.cfg.content_url and v.cfg.content_url ~= "" then
        logic_pubgm_music_download.DownLoadFromCDN(id, v.cfg.content_url, list)
      end
      break
    end
  end
end
function logic_pubgm_music_download.DownloadOtherMusic(id)
  if not logic_pubgm_music_download.configs then
    logic_pubgm_music_download.configs = logic_pubgm_music_util.GetConfig()
  end
  for k, v in pairs(logic_pubgm_music_download.configs) do
    if id == k then
      if v.download_type == E_MusicDownloadType.HDmpve then
        logic_pubgm_music_download.OnDownloadOtherFromHDmpve(id)
        break
      end
      if v.content_url and v.content_url ~= "" then
        logic_pubgm_music_download.DownLoadOtherFromCDN(id, v.content_url)
      end
      break
    end
  end
end
function logic_pubgm_music_download.OnDownloadOtherFromHDmpve(id)
  logic_pubgm_music_download.RefreshDownloadingState(id)
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {id}, nil, logic_pubgm_music_download.OnDownloadOtherPak)
end
function logic_pubgm_music_download.DownLoadOtherFromCDN(id, url)
  logic_pubgm_music_download.RefreshDownloadingState(id)
  local cdn_downloader = require("client.common.cdn_downloader")
  local downloadPath = string.format("%sPatchFile/%s.pak", cdn_downloader.GetCDNFileDir("AFD"), url)
  local savePath = Client.ProjectSavedDir() .. string.format("MusicPlayer/%s", logic_pubgm_music_util.GetPakNameConcatVersion(url))
  cdn_downloader.DownloadPak(downloadPath, savePath, logic_pubgm_music_download.OnDownloadOtherPak)
end
function logic_pubgm_music_download.OnDownloadOtherPak(id)
  log(bWriteLog and string.format("[muidarzhang] logic_pubgm_music_download.OnDownloadOtherPak, id:%s", id))
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_DOWNLOAD_FINISH, id)
end
return logic_pubgm_music_download