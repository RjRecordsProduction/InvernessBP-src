local C_Def_MediaPlayer_Path = "/Game/Movies/SGTMediaP.SGTMediaP"
local C_Def_Material_Path = "/Game/Movies/NewMediaPlayer_Video_Mat.NewMediaPlayer_Video_Mat"
local C_Def_MediaTexture_Path = "/Game/Movies/NewMediaPlayer_Video.NewMediaPlayer_Video"
local video_trait = {}
local Trait = require("common.trait")
local CVideo_trait = Trait(Trait.TraitPrototype, nil, video_trait)
function video_trait:PlayNormalLocalVideo(widget, videoPath, mediaPlayerPath, materialPath, texturePath, skipResetResolution)
  if not widget then
    log(bWriteLog and string.format("video_trait:PlayNormalLocalVideo widget is nil."))
    return
  end
  if not videoPath or videoPath == "" then
    log(bWriteLog and string.format("video_trait:PlayNormalLocalVideo path is nil."))
    return
  end
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:_InitMediaSource(videoPath)
  self:_InitMediaPlayer(mediaPlayerPath, texturePath, widget, skipResetResolution)
  self:_InitPlayerMaterial(materialPath)
  self:_SetMediaPlayerMaterial(widget)
  self:OnInitializeMediaPlayer()
  self:_PlayMedia()
end
function video_trait:PlayStreamLiveVideo(rootWidget, urlPath)
  if not rootWidget then
    log(bWriteLog and string.format("video_trait:PlayStreamLiveVideo rootWidget is nil."))
    return
  end
  if not urlPath or urlPath == "" then
    log(bWriteLog and string.format("video_trait:PlayStreamLiveVideo urlPath is nil."))
    return
  end
  local live_video_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.live_video_module)
  if self.liveVideoPlayer then
    self:_ClearLiveVideoPlayer()
  end
  self.liveVideoPlayer = live_video_module:CreatePlayer(self, rootWidget)
  self:_BindLiveVideoPlayerEvent()
  self:OnInitializeLiveVideo()
  live_video_module:SwitchToVideo(urlPath)
end
function video_trait:ReleaseResource(widget)
  log(bWriteLog and string.format("video_trait:ReleaseResource"))
  self:_ClearMediaPlayerEvent()
  self:_ClearPlayerMaterial()
  self:_ClearMediaSource()
  self:_ClearLiveVideoPlayer()
  self:_RemoveRetryTimer()
  if widget then
    widget:SetBrushFromMaterial(nil)
  end
end
function video_trait:PauseLiveVideoPlayer()
  if self.liveVideoPlayer then
    self.liveVideoPlayer.UIRoot:Pause()
  end
end
function video_trait:ResumeLiveVideoPlayer()
  if self.liveVideoPlayer then
    self.liveVideoPlayer.UIRoot:Resume()
  end
end
function video_trait:OnInitializeMediaPlayer()
  log(bWriteLog and string.format("video_trait:OnInitializeMediaPlayer"))
end
function video_trait:OnMediaPlayerOpenSuccess()
  log(bWriteLog and string.format("video_trait:OnMediaPlayerOpenSuccess"))
end
function video_trait:OnMediaPlayerOpenFail()
  log(bWriteLog and string.format("video_trait:OnMediaPlayerOpenFail"))
end
function video_trait:OnMediaOpenFailed(filePath)
  log(bWriteLog and string.format("video_trait:OnMediaOpenFailed path = %s", tostring(filePath)))
end
function video_trait:OnMediaOpened(filePath)
  log(bWriteLog and string.format("video_trait:OnMediaOpened path = %s", tostring(filePath)))
end
function video_trait:OnEndReached(filePath)
  log(bWriteLog and string.format("video_trait:OnEndReached path = %s", tostring(filePath)))
end
function video_trait:OnMediaClosed(filePath)
  log(bWriteLog and string.format("video_trait:OnMediaClosed path = %s", tostring(filePath)))
end
function video_trait:OnSetMediaContentResolution()
  log(bWriteLog and string.format("video_trait:OnSetMediaContentResolution"))
end
function video_trait:OnInitializeLiveVideo()
  log(bWriteLog and string.format("video_trait:OnInitializeLiveVideo"))
end
function video_trait:OnVideoLoading()
  log(bWriteLog and string.format("video_trait:OnVideoLoading"))
end
function video_trait:OnVideoPlay()
  log(bWriteLog and string.format("video_trait:OnVideoPlay"))
end
function video_trait:OnVideoError()
  log(bWriteLog and string.format("video_trait:OnVideoError"))
end
function video_trait:OnVideoSwitchToForeground()
  log(bWriteLog and string.format("video_trait:OnVideoSwitchToForeground"))
end
function video_trait:_InitMediaSource(path)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if not VideoLibrary.IsVideoFileReady(path) then
    self.source = nil
    return
  end
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.source == nil or KismetSystemLibrary.IsValid(self.source) == false then
    local FileMediaSource = import("FileMediaSource")
    self.source = FileMediaSource()
  end
  path = string.gsub(path, "MoviesPak/", "MoviesPakDir/")
  path = string.gsub(path, "./MoviesPakDir", "MoviesPakDir")
  local videoPath = ScriptHelperClient.ConvertRelativePathToFull(Client.ProjectSavedDir() .. path)
  log(bWriteLog and string.format("video_trait:_InitMediaSource path = %s, videoPath = %s", path, videoPath))
  self.source:SetFilePath(videoPath)
end
function video_trait:_GetMediaSource()
  return self.source
end
function video_trait:_ClearMediaSource()
  self.source = nil
end
function video_trait:_PlayMedia()
  local mat = self:_GetPlayerMaterial()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if mat == nil or not KismetSystemLibrary.IsValid(mat) then
    self:OnMediaPlayerOpenFail()
    return
  end
  if self.mediaPlayer == nil or not KismetSystemLibrary.IsValid(self.mediaPlayer) then
    self:OnMediaPlayerOpenFail()
    return
  end
  local medSource = self:_GetMediaSource()
  if medSource == nil or not KismetSystemLibrary.IsValid(medSource) then
    self:OnMediaPlayerOpenFail()
    return
  end
  local ret = self.mediaPlayer:OpenSource(medSource)
  log(bWriteLog and string.format("video_trait:PlayMedia ret is %s", ret))
  if ret then
    self:OnMediaPlayerOpenSuccess()
  else
    self:OnMediaPlayerOpenFail()
  end
end
function video_trait:ReplayNormalLocalMedia()
  self:_PlayMedia()
end
function video_trait:NormalLocalVideoIsReady()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    return self.mediaPlayer:IsReady()
  end
  return false
end
function video_trait:NormalLocalVideoPause()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    self.mediaPlayer:Pause()
  end
end
function video_trait:NormalLocalVideoResume()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    self.mediaPlayer:Play()
  end
end
function video_trait:GetDurationByNormalLocalVideo()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    return self.mediaPlayer:GetDuration()
  end
  return 0
end
function video_trait:GetTimeByNormalLocalVideo()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    return self.mediaPlayer:GetTime()
  end
  return 0
end
function video_trait:GetNormalLocalVideo()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    return self.mediaPlayer
  end
  return nil
end
function video_trait:_InitMediaPlayer(mediaPlayerPath, texturePath, widget, skipResetResolution)
  log(bWriteLog and string.format("video_trait:_InitMediaPlayer mediaPlayerPath = %s, texturePath = %s", mediaPlayerPath, texturePath))
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer == nil or KismetSystemLibrary.IsValid(self.mediaPlayer) == false then
    mediaPlayerPath = mediaPlayerPath or C_Def_MediaPlayer_Path
    local asset_util = require("common.asset_util")
    local logic_login_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_login_background)
    local cachedPlayer = logic_login_background:GetCachedAssetByPath(mediaPlayerPath)
    if slua.isValid(cachedPlayer) then
      self.mediaPlayer = cachedPlayer
    else
      self.mediaPlayer = asset_util.GetAssetSync(mediaPlayerPath)
    end
    self:_BindMediaPlayerEvent(texturePath, widget, skipResetResolution)
  end
end
function video_trait:_BindMediaPlayerEvent(texturePath, widget, skipResetResolution)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if KismetSystemLibrary.IsValid(self.mediaPlayer) then
    local openMediaSuccessMark = false
    local _retry = function(bRetryWithAndroid)
      if self:_IsNeedCreateRetryTimer(bRetryWithAndroid) then
        if self.tryingToRetry then
          log(bWriteLog and string.format("video_trait:_retry self.tryingToRetry == true"))
          return true
        else
          openMediaSuccessMark = false
          log(bWriteLog and string.format("video_trait:_retry openMediaSuccessMark == false"))
          local res = self:_CreateRetryTimer(widget)
          log(bWriteLog and string.format("video_trait:_retry res == %s", res))
          if res then
            return true
          end
        end
      else
        log(bWriteLog and string.format("video_trait:_retry self.tryingToRetry == false"))
      end
      return false
    end
    local _onMediaOpenFailed = function(filePath)
      log(bWriteLog and string.format("video_trait:_BindMediaPlayerEvent _onMediaOpenFailed filePath = %s", filePath))
      if _retry() then
        log(bWriteLog and string.format("_onMediaOpenFailed currently retrying."))
        return
      end
      self:OnMediaOpenFailed(filePath)
    end
    local _onMediaOpened = function(filePath)
      openMediaSuccessMark = true
      self:_RemoveRetryTimer()
      self:OnMediaOpened(filePath)
      log(bWriteLog and string.format("video_trait:_BindMediaPlayerEvent _onMediaOpened filePath = %s", filePath))
      self:AddTimerOnce(0.15, function()
        self:_SetContentResolution(texturePath, widget, skipResetResolution)
      end)
    end
    local _onEndReached = function(filePath)
      log(bWriteLog and string.format("video_trait:_BindMediaPlayerEvent _onEndReached filePath = %s", filePath))
      self:OnEndReached(filePath)
    end
    local _onMediaClosed = function(filePath)
      log(bWriteLog and string.format("video_trait:_BindMediaPlayerEvent _onMediaClosed filePath = %s", filePath))
      local LadderDrawSystem = require("client.slua.logic.lobby_activity.logic_ladder_draw")
      if not LadderDrawSystem.bSkipRetryPlay then
        if _retry(true) then
          log(bWriteLog and string.format("video_trait:_onMediaClosed currently retrying."))
          return
        else
          log(bWriteLog and string.format("video_trait: _onMediaClosed OnMediaClosed"))
        end
      end
      self:OnMediaClosed(filePath)
    end
    self:AddControlEventByControl(self.mediaPlayer, "OnMediaOpenFailed", _onMediaOpenFailed)
    self:AddControlEventByControl(self.mediaPlayer, "OnMediaOpened", _onMediaOpened)
    self:AddControlEventByControl(self.mediaPlayer, "OnEndReached", _onEndReached)
    self:AddControlEventByControl(self.mediaPlayer, "OnMediaClosed", _onMediaClosed)
  end
end
function video_trait:_ClearMediaPlayerEvent()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) then
    self:RemoveControlEventByControl(self.mediaPlayer, "OnMediaOpenFailed")
    self:RemoveControlEventByControl(self.mediaPlayer, "OnMediaOpened")
    self:RemoveControlEventByControl(self.mediaPlayer, "OnEndReached")
    self:RemoveControlEventByControl(self.mediaPlayer, "OnMediaClosed")
    self.mediaPlayer:Close()
    self.mediaPlayer = nil
  end
end
function video_trait:_InitPlayerMaterial(materialPath)
  log(bWriteLog and string.format("video_trait:_InitPlayerMaterial materialPath = %s", materialPath))
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.playerMaterial == nil or KismetSystemLibrary.IsValid(self.playerMaterial) == false then
    materialPath = materialPath or C_Def_Material_Path
    local asset_util = require("common.asset_util")
    self.playerMaterial = asset_util.GetAssetSync(materialPath)
  end
end
function video_trait:_GetPlayerMaterial()
  return self.playerMaterial
end
function video_trait:_ClearPlayerMaterial()
  self.playerMaterial = nil
end
function video_trait:_SetMediaPlayerMaterial(widget)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if widget and KismetSystemLibrary.IsValid(widget) and widget.SetBrushFromMaterial then
    if self.playerMaterial and KismetSystemLibrary.IsValid(self.playerMaterial) then
      widget:SetBrushFromMaterial(self.playerMaterial)
    else
      log_warning("video_trait:SetMediaPlayerMaterial playerMaterial is nil.")
    end
  else
    log_warning("video_trait:SetMediaPlayerMaterial widget is nil.")
  end
end
function video_trait:_SetContentResolution(texturePath, widget, skipResetResolution)
  log(bWriteLog and string.format("video_trait:_SetContentResolution texturePath = %s", texturePath))
  if not widget then
    log(bWriteLog and string.format("video_trait:SetContentResolution widget is nil."))
    return
  end
  if skipResetResolution then
    self:_SetMediaPlayerMaterial(widget)
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:OnSetMediaContentResolution()
    return
  end
  texturePath = texturePath or C_Def_MediaTexture_Path
  local asset_util = require("common.asset_util")
  local mediaTexture = asset_util.GetAssetSync(texturePath)
  local width = 1920
  local height = 880
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if mediaTexture and KismetSystemLibrary.IsValid(mediaTexture) then
    width = mediaTexture:GetWidth()
    height = mediaTexture:GetHeight()
  end
  if width < 16 then
    log(bWriteLog and "video_trait:SetContentResolution, change width = " .. tostring(width) .. " to default 1920.")
    width = 1920
  end
  if height < 9 then
    log(bWriteLog and "video_trait:SetContentResolution, change height =  " .. tostring(height) .. " to default 880.")
    height = 880
  end
  local brush = slua.IndexReference(widget, "Brush"):clone()
  brush.ImageSize = FVector2D(width, height)
  widget:SetBrush(brush)
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:OnSetMediaContentResolution()
end
function video_trait:_ClearLiveVideoPlayer()
  if self.liveVideoPlayer then
    local live_video_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.live_video_module)
    live_video_module:ClosePlayer()
    self.liveVideoPlayer = nil
  end
end
function video_trait:_BindLiveVideoPlayerEvent()
  self:AddCommonEvent(EVENTTYPE_LIVE_VIDEO, EVENTID_LIVE_VIDEO_LOADING, self.OnVideoLoading, self)
  self:AddCommonEvent(EVENTTYPE_LIVE_VIDEO, EVENTID_LIVE_VIDEO_PLAY, self.OnVideoPlay, self)
  self:AddCommonEvent(EVENTTYPE_LIVE_VIDEO, EVENTID_LIVE_VIDEO_ERROR, self.OnVideoError, self)
  self:AddCommonEvent(EVENTTYPE_LIVE_VIDEO, EVENTID_LIVE_VIDEO_SWITCH_TO_FOREGROUND, self.OnVideoSwitchToForeground, self)
end
function video_trait:_IsNeedCreateRetryTimer(bRetryWithAndroid)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  return Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS or bRetryWithAndroid
end
function video_trait:_CreateRetryTimer(widget)
  if self.tryingToRetry then
    log(bWriteLog and string.format("video_trait:CreateRetryTimer it's already in an attempted retry state."))
    return true
  end
  local Const = require("client.slua.umg.common.video_player_retry_config")
  if self.tryPlayTimes and self.tryPlayTimes > Const.MaxRetryTimes then
    log(bWriteLog and string.format("video_trait:CreateRetryTimer tryPlayTimes over the maximum. --"))
    return false
  end
  self:_RemoveRetryTimer()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  log(bWriteLog and string.format("VideoPlayerSystem:CreateRetryTimer nDeviceLevel = %s", nDeviceLevel))
  self.tryingToRetry = true
  self.tryPlayTimes = 0
  self.retryTimer = self:AddTimerLoop(0, function()
    local Const = require("client.slua.umg.common.video_player_retry_config")
    if not self.tryingToRetry then
      self:_RemoveRetryTimer()
      log(bWriteLog and string.format("video_trait:_CreateRetryTimer not in retry state."))
      return
    end
    self.tryPlayTimes = self.tryPlayTimes + 1
    if self.tryPlayTimes > Const.MaxRetryTimes then
      ShowNotice(46037)
      self:_RemoveRetryTimer()
      self:OnMediaPlayerOpenFail()
      log(bWriteLog and string.format("video_trait:CreateRetryTimer tryPlayTimes over the maximum."))
      return
    end
    log(bWriteLog and string.format("video_trait:_CreateRetryTimer replay."))
    self:_SetMediaPlayerMaterial(widget)
    self:_PlayMedia()
  end, Const.MaxRetryTimes, Const.RetryDelay[nDeviceLevel] or Const.DefaultDelay)
  return true
end
function video_trait:_RemoveRetryTimer()
  self.tryingToRetry = false
  self.tryPlayTimes = 0
  if self.retryTimer then
    self:RemoveTimer(self.retryTimer)
    self.retryTimer = nil
  end
end
return CVideo_trait