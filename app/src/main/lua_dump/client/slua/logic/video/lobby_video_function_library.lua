local VideoLibrary = {
  haveCopiedVideos = {}
}
function VideoLibrary.PlayVideo(videoPath, extra, bMask, ParamTable)
  log(bWriteLog and string.format("VideoLibrary.PlayVideo videoPath = %s, bMask = %s", videoPath, bMask))
  local result = false
  if VideoLibrary.IsCanVideoFileAndReady(videoPath) then
    if bMask and not ParamTable then
      UIManager.ShowUI(UIManager.UI_Config.video_player_mask)
    end
    UIManager.ShowUI(UIManager.UI_Config.video_player_system, videoPath, extra, ParamTable)
    result = true
  end
  log(bWriteLog and string.format("VideoLibrary.PlayVideo  result = %s", result))
  return result
end
function VideoLibrary.ClearHaveCopiedVideos()
  VideoLibrary.haveCopiedVideos = {}
end
function VideoLibrary.IsVideoFileReady(videoPath)
  if type(videoPath) ~= "string" or videoPath == "" then
    log(bWriteLog and "VideoLibrary.IsVideoFileReady invalid videoPath")
    return false
  end
  if VideoLibrary.IsStreamPath(videoPath) then
    log(bWriteLog and string.format("VideoLibrary.IsVideoFileReady is stream path, videoPath = %s", videoPath))
    return true
  elseif VideoLibrary.haveCopiedVideos[videoPath] ~= nil then
    log(bWriteLog and string.format("VideoLibrary.IsVideoFileReady already copied, videoPath = %s", videoPath))
    return true
  else
    local path = DataMgr.GetVideoDownloadPath(videoPath)
    log(bWriteLog and string.format("VideoLibrary.IsVideoFileReady, download resource path = %s", path))
    local FBI = require("client.slua.logic.fbi.logic_fbi")
    if FBI.IsIllegalTime(path) then
      log(bWriteLog and string.format("VideoLibrary.IsVideoFileReady download time has not yet arrived. path = %s", path))
      return false
    end
    if path == "" then
      if string.find(videoPath, "/Movies/") then
        VideoLibrary.haveCopiedVideos[videoPath] = true
        return true
      end
      return false
    else
      local pak_util = require("client.common.pak_util")
      local exist = pak_util.IsVideoFileExist(videoPath)
      log(bWriteLog and string.format("VideoLibrary.IsVideoFileReady relative file path = %s, exist = %s", path, exist))
      if exist then
        local fileName, Ext = VideoLibrary.GetFileNameAndExtension(videoPath)
        local force = VideoLibrary.IsMovieFileSizeEqual(fileName) == false
        local result = Client.MediaCopyFromPakToLocal(fileName, force)
        if result == true then
          VideoLibrary.haveCopiedVideos[videoPath] = true
          return true
        end
      end
    end
  end
  return false
end
function VideoLibrary.IsInGameVideoFileReady(VideoPath)
  if type(VideoPath) ~= "string" or VideoPath == "" then
    print(bWriteLog and "VideoLibrary.IsInGameVideoFileReady, invalid VideoPath")
    return false
  end
  if VideoLibrary.haveCopiedVideos[VideoPath] ~= nil then
    print(bWriteLog and "VideoLibrary.IsInGameVideoFileReady, already copied, VideoPath = " .. VideoPath)
    return true
  else
    local Path = DataMgr.GetVideoDownloadPath(VideoPath)
    print(bWriteLog and "VideoLibrary.IsInGameVideoFileReady, download resource path = " .. Path)
    if Path == "" then
      return false
    else
      local pak_util = require("client.common.pak_util")
      local Exist = pak_util.IsVideoFileExist(VideoPath)
      print(bWriteLog and "VideoLibrary.IsInGameVideoFileReady, Exist = " .. tostring(Exist) .. ", Path = " .. Path)
      if Exist then
        local FileName, Ext = VideoLibrary.GetFileNameAndExtension(VideoPath)
        local Force = VideoLibrary.IsMovieFileSizeEqual(FileName) == false
        local Result = Client.MediaCopyFromPakToLocal(FileName, Force)
        if Result == true then
          VideoLibrary.haveCopiedVideos[VideoPath] = true
          return true
        end
      end
    end
  end
  return false
end
function VideoLibrary.IsStreamPath(path)
  if not path or path == "" then
    return false
  end
  if string.find(path, "http://") or string.find(path, "https://") then
    return true
  end
  return false
end
function VideoLibrary.GetFileNameAndExtension(fullName, defExt)
  if not fullName then
    log(bWriteLog and string.format("VideoLibrary.GetFileNameAndExtension fullName is nil !"))
    return "", ""
  end
  defExt = defExt or "mp4"
  local StringUtil = require("common.string_util")
  local list = StringUtil.Split(fullName, "/")
  list = StringUtil.Split(list[#list], ".")
  local ext = list[2] or defExt
  ext = "." .. ext
  local fileName = list[1] .. ext
  log(bWriteLog and string.format("VideoLibrary.GetFileNameAndExtension fullName = %s, fileName = %s, ext = %s", fullName, fileName, ext))
  return fileName, ext
end
function VideoLibrary.IsMovieFileSizeEqual(fileName)
  local srcPath = Client.ProjectContentDir() .. "MoviesPak/" .. tostring(fileName)
  local savePath = Client.ProjectSavedDir() .. "MoviesPakDir/" .. tostring(fileName)
  local srcSize = Client.GetFileSizeOnDisk(srcPath)
  local saveSize = Client.GetFileSizeOnDisk(savePath)
  log(bWriteLog and string.format("VideoLibrary.IsMovieFileSizeEqual srcFilePath = %s, saveFilePath = %s, srcFileSize = %s, saveFileSize = %s", srcPath, savePath, srcSize, saveSize))
  return srcSize == saveSize
end
function VideoLibrary.IsCanPlayVideo()
  local result = true
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_PLAY_VIDEO) == false then
    result = false
    log(bWriteLog and "VideoLibrary.IsCanPlayVideo, BP_ENUM_LOBBY_PLAY_VIDEO is closed.")
  end
  if LobbySystem.CheckVideoOpenStatus() == false then
    result = false
    log(bWriteLog and "VideoLibrary.IsCanPlayVideo, the device is in blacklist.")
  end
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  log(bWriteLog and "[qintong] : VideoLibrary.IsCanPlayVideo  enter_guide.executeFightGuide" .. tostring(enter_guide.executeFightGuide))
  if enter_guide.executeFightGuide then
    result = false
  end
  log(bWriteLog and "VideoLibrary.IsCanPlayVideo, result = " .. tostring(result))
  return result
end
function VideoLibrary.IsCanVideoFileAndReady(videoPath)
  return VideoLibrary.IsCanPlayVideo() and VideoLibrary.IsVideoFileReady(videoPath)
end
function VideoLibrary.CheckPlayAirdropVideo(path)
  local result = false
  local videoDownloadPath = DataMgr.GetVideoDownloadPath(path)
  if videoDownloadPath ~= "" then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local nState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {videoDownloadPath})
    if nState ~= PufferConst.ENUM_DownloadState.Done then
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {videoDownloadPath})
    elseif nState == PufferConst.ENUM_DownloadState.Done then
      result = true
    end
  end
  return result
end
function VideoLibrary.StopCardVoice()
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.StopSound()
end
function VideoLibrary.PlayVideoPure(videoPath)
  log(bWriteLog and "[tinghaohu]VideoLibrary.PlayPureVideo, videoPath = " .. tostring(videoPath))
  if VideoLibrary.IsCanPlayVideo() == false then
    return false
  end
  if VideoLibrary.IsVideoFileReady(videoPath) == false then
    return false
  end
  local tempPath = string.gsub(videoPath, "./MoviesPakDir", "MoviesPakDir")
  local realVideoPath = ScriptHelperClient.ConvertRelativePathToFull(Client.ProjectSavedDir() .. tempPath)
  EventSystem:postEvent(EVENTTYPE_VIDEO_PURE, EVENTID_VIDEO_PURE_CHANGE, realVideoPath)
  UIManager.ShowUI(UIManager.UI_Config.video_player_system_pure, realVideoPath)
  return true
end
function VideoLibrary.StopVideoPure()
  UIManager.CloseUI(UIManager.UI_Config.video_player_system_pure)
end
function VideoLibrary.IsIOS16()
  local SystemSoftware = tonumber(Client.GetOSVersion())
  local PlatformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  log(bWriteLog and string.format("VideoLibrary.IsIOS16 SystemSoftware:" .. tostring(SystemSoftware) .. " PlatformName:" .. tostring(PlatformName)))
  if PlatformName == DevicePlatformNameMacros.IOS and SystemSoftware and 16 <= SystemSoftware then
    return true
  end
  return false
end
function VideoLibrary.PlayUGCVideo(videoPath, extra, bMask, ParamTable)
  log(bWriteLog and string.format("VideoLibrary.PlayVideo videoPath = %s, bMask = %s", videoPath, bMask))
  local result = false
  if VideoLibrary.IsCanVideoFileAndReady(videoPath) then
    if bMask and not ParamTable then
      UIManager.ShowUI(UIManager.UI_Config.video_player_mask)
    end
    UIManager.ShowUI(UIManager.UI_Config.UGC_WoWGudie_Video_UIBP, videoPath, extra, ParamTable)
    result = true
  end
  log(bWriteLog and string.format("VideoLibrary.PlayVideo  result = %s", result))
  return result
end
function VideoLibrary.OnLogOut()
  VideoLibrary.ClearHaveCopiedVideos()
end
return VideoLibrary