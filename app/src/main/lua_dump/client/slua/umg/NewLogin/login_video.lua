local LoginVideo = {}
local asset_util = require("common.asset_util")
function LoginVideo:ctor(selfUI, videoList)
  self.videoList = videoList or {}
  self.source = nil
  self.mediaPlayer = nil
  self.playerMaterial = nil
  self.videoIndex = 0
end
function LoginVideo:OnInitialize()
  LoginVideo.__super.OnInitialize(self)
  self.UIRoot.MediaContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local EStretch = import("EStretch")
  self.UIRoot.ScaleBox_0:SetStretch(EStretch.ScaleToFitY)
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.VNG then
    self.UIRoot.Image_Logo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    if region == PublishRegionMacros.TW then
      self:SetTexture(self.UIRoot.Image_Logo, "/Game/UMG/Texture/LoginUpdateUI/RGBA32/JS_image_POP_logo_TW.JS_image_POP_logo_TW")
    end
    self.UIRoot.Image_Logo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LoginVideo:OnShow()
  LoginVideo.__super.OnShow(self)
  self:PlayNextVideo()
end
function LoginVideo:PlayNextVideo()
  if self.videoIndex >= #self.videoList then
    self.videoIndex = 1
  else
    self.videoIndex = self.videoIndex + 1
  end
  if self.videoIndex <= #self.videoList then
    self:PlayVideo(self.videoList[self.videoIndex])
  else
    log(bWriteLog and "[jonahwei]LoginVideo:PlayNextVideo\239\188\140 Empty Video List ")
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_VIDEO_CLOSE)
  end
end
function LoginVideo:PlayVideo(videoPath)
  if not _G.IsEditor then
    local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
    if VideoLibrary.IsVideoFileReady(videoPath) == true then
      local tempPath = string.gsub(videoPath, "%./MoviesPakDir", "MoviesPakDir")
      videoPath = ScriptHelperClient.ConvertRelativePathToFull(Client.ProjectSavedDir() .. tempPath)
    else
      log(bWriteLog and "[jonahwei]LoginVideo:PlayVideo Failed, Can't move to save")
      table.remove(self.videoList, self.videoIndex)
      self.videoIndex = self.videoIndex - 1
      self:PlayNextVideo()
      return
    end
  end
  log(bWriteLog and "[trace][video] LoginVideo:PlayVideo begin path: " .. videoPath)
  local _beginTime = slua.getMiliseconds()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.source == nil or KismetSystemLibrary.IsValid(self.source) == false then
    local FileMediaSource = import("FileMediaSource")
    self.source = FileMediaSource()
  end
  self.source:SetFilePath(videoPath)
  local logic_login_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_login_background)
  if self.mediaPlayer == nil or KismetSystemLibrary.IsValid(self.mediaPlayer) == false then
    local cachedPlayer = logic_login_background:GetCachedAssetByPath("/Game/Movies/SGTMediaP.SGTMediaP")
    if slua.isValid(cachedPlayer) then
      self.mediaPlayer = cachedPlayer
    else
      self.mediaPlayer = asset_util.GetAssetSync("/Game/Movies/SGTMediaP.SGTMediaP")
    end
    if not self.mediaPlayer then
      log(bWriteLog and "[jonahwei]LoginVideo:PlayVideo Failed, Missing mediaPlayer")
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_VIDEO_CLOSE)
      return
    end
    self:BindMediaPlayerEvent()
  end
  if self.playerMaterial == nil or KismetSystemLibrary.IsValid(self.playerMaterial) == false then
    local cachedMaterial = logic_login_background:GetCachedAssetByPath("/Game/Movies/NewMediaPlayer_Video_Mat.NewMediaPlayer_Video_Mat")
    if slua.isValid(cachedMaterial) then
      self.playerMaterial = cachedMaterial
    else
      self.playerMaterial = asset_util.GetAssetSync("/Game/Movies/NewMediaPlayer_Video_Mat.NewMediaPlayer_Video_Mat")
    end
    if not self.playerMaterial then
      log(bWriteLog and "[jonahwei]LoginVideo:PlayVideo Failed, Missing playerMaterial")
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_VIDEO_CLOSE)
      return
    end
  end
  self.UIRoot.MediaContainer:SetBrushFromMaterial(self.playerMaterial)
  local ret = self.mediaPlayer:OpenSource(self.source)
  if not ret then
    log(bWriteLog and "[jonahwei]LoginVideo:PlayVideo OpenSource Failed, path = " .. tostring(self.source))
    table.remove(self.videoList, self.videoIndex)
    self.videoIndex = self.videoIndex - 1
    self:PlayNextVideo()
  end
  log(bWriteLog and "[trace][video] LoginVideo:PlayVideo total cost: " .. slua.getMiliseconds() - _beginTime)
end
function LoginVideo:BindMediaPlayerEvent()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if KismetSystemLibrary.IsValid(self.mediaPlayer) then
    self:AddControlEventByControl(self.mediaPlayer, "OnMediaOpened", self.OnMediaOpened, self)
    self:AddControlEventByControl(self.mediaPlayer, "OnEndReached", self.OnEndReached, self)
  end
end
function LoginVideo:OnEndReached()
  self:PlayNextVideo()
end
function LoginVideo:OnClose()
  self:ReleaseResource()
  local logic_login_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_login_background)
  logic_login_background:ClearLoadedVideoResources()
end
function LoginVideo:ReleaseResource()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaPlayer and KismetSystemLibrary.IsValid(self.mediaPlayer) == true then
    self:RemoveControlEventByControl(self.mediaPlayer, "OnMediaOpened")
    self:RemoveControlEventByControl(self.mediaPlayer, "OnEndReached")
    self.mediaPlayer:Close()
    self.mediaPlayer = nil
  end
  self.playerMaterial = nil
  self.mediaTexture = nil
  self.source = nil
  self.UIRoot.MediaContainer:SetBrushFromMaterial(nil)
end
function LoginVideo:OnMediaOpened()
  self.UIRoot.MediaContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:AddTimerOnce(0.5, function()
    self:SetContentResolution()
  end)
end
function LoginVideo:SetContentResolution()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if self.mediaTexture == nil or KismetSystemLibrary.IsValid(self.mediaTexture) == false then
    self.mediaTexture = asset_util.GetAssetSync("/Game/Movies/NewMediaPlayer_Video.NewMediaPlayer_Video")
  end
  local width = self.mediaTexture:GetWidth()
  local height = self.mediaTexture:GetHeight()
  if width < 16 then
    width = 1920
  end
  if height < 9 then
    height = 880
  end
  local brush = slua.IndexReference(self.UIRoot.MediaContainer, "Brush"):clone()
  brush.ImageSize = FVector2D(width, height)
  self.UIRoot.MediaContainer:SetBrush(brush)
  self.UIRoot.Image_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLoginVideo = class(ui_base, nil, LoginVideo)
return CLoginVideo