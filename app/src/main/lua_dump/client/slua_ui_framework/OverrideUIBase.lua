local OverrideUIBase = {}
local GMDebug = false
local string_format = string.format
local local local local local local slua_isValid = slua.isValid
local local util = require("client.slua_ui_framework.util")
local local local string_util = require("common.string_util")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local base_config_util = require("client.common.uibase.base_config_util")
local SetTextureConst = require("client.slua.logic.image_download.SetTextureConst")
function OverrideUIBase:ctor(selfType, ...)
  self._playList = nil
  self._downloadImageMgrData = nil
  self._asyncLoadDiskFile = nil
  self.__childIU__ = nil
end
function OverrideUIBase:OnInitialize()
end
function OverrideUIBase:RegistEvents()
end
function OverrideUIBase:OnPostInitialize()
end
function OverrideUIBase:OnClose()
end
function OverrideUIBase:CreateChildWindow(panel, config, ...)
  if panel == nil then
    log_error("OverrideUIBase:CreateChildWindow no parent keyName:" .. self:_GetKeyName(config))
    return nil
  end
  if GMDebug then
    log(bWriteLog and string_format("OverrideUIBase:CreateChildWindow keyName:%s", self:_GetKeyName(config)))
  end
  local childUI = UIManager.ShowUI(config, ...)
  if not childUI then
    log_error("OverrideUIBase:CreateChildWindow childUI = nil. keyName:" .. self:_GetKeyName(config))
    return nil
  end
  self.__childIU__ = childUI
  childUI:AttachToPanel(panel)
  childUI:SetAnchors(0, 0, 1, 1)
  childUI:SetOffsets(0, 0, 0, 0)
  if config and base_config_util.IsForceLayoutPrepass(config) then
    childUI.UIRoot:ForceLayoutPrepass()
  end
  return childUI
end
function OverrideUIBase:CreateChildWindowWithBpPath(panel, config, bpPath, ...)
  if panel == nil then
    log_error("OverrideUIBase:CreateChildWindowWithBpPath no parent keyName:" .. self:_GetKeyName(config))
    return nil
  end
  if GMDebug then
    log(bWriteLog and string_format("OverrideUIBase:CreateChildWindowWithBpPath keyName:%s", self:_GetKeyName(config)))
  end
  local childUI = UIManager.ShowUIWithBpPath(config, bpPath, ...)
  if not childUI then
    log_error("OverrideUIBase:CreateChildWindowWithBpPath childUI = nil. keyName:" .. self:_GetKeyName(config))
    return nil
  end
  self.__childIU__ = childUI
  childUI:AttachToPanel(panel)
  childUI:SetAnchors(0, 0, 1, 1)
  childUI:SetOffsets(0, 0, 0, 0)
  if config and base_config_util.IsForceLayoutPrepass(config) then
    childUI.UIRoot:ForceLayoutPrepass()
  end
  return childUI
end
function OverrideUIBase:CloseChildWindow()
  if self.__childIU__ then
    self.__childIU__:Close()
    self.__childIU__ = nil
  end
end
function OverrideUIBase:GetChildUI()
  return self.__childIU__
end
function OverrideUIBase:PlayAudioByActor(audioPath, actor)
  if not audioPath or audioPath == "" then
    log_error("OverrideUIBase:PlayAudioByActor audioPath invalid")
    return
  end
  if not slua_isValid(actor) then
    log_error("OverrideUIBase:PlayAudioByActor actor invalid")
    return
  end
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioByActor(audioPath, actor)
end
function OverrideUIBase:PlayAudio(audioPath, bAsync)
  if not audioPath or audioPath == "" then
    log_error("OverrideUIBase:PlayAudio audioPath invalid")
    return
  end
  if not slua_isValid(self.Object) then
    log_error("OverrideUIBase:PlayAudio self.Object invalid")
    return
  end
  if bAsync then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudioAsync(audioPath, self.Object)
  else
    self:_PlayAudioInner(audioPath)
  end
end
function OverrideUIBase:_PlayAudioInner(audioPath)
  if type(audioPath) == "string" then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(audioPath, self.Object)
  elseif type(audioPath) == "number" then
    log_error("OverrideUIBase:_PlayAudioInner interface has been deprecated, please use the OverrideUIBase:PlayMusic interface. audioPath:" .. audioPath)
    self:PlayMusic(audioPath)
  end
end
function OverrideUIBase:PlayMusic(sound_id, disableMusicPlayer)
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  if not self._playList then
    self._playList = {}
  end
  self._playList[sound_id] = audio_manager:Start(sound_id, disableMusicPlayer)
end
function OverrideUIBase:StopMusic(sound_id)
  if not self._playList then
    log_error("OverrideUIBase:StopMusic _playList == nil id:" .. sound_id)
    return
  end
  if not self._playList[sound_id] then
    log_error("OverrideUIBase:StopMusic _playList not find id:" .. sound_id)
    return
  end
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  audio_manager:Stop(sound_id)
  self._playList[sound_id] = nil
end
function OverrideUIBase:PauseMusic(sound_id)
  if not self._playList then
    log_error("OverrideUIBase:PauseMusic _playList == nil id:" .. sound_id)
    return
  end
  if not self._playList[sound_id] then
    log_error("OverrideUIBase:PauseMusic _playList not find id:" .. sound_id)
    return
  end
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  audio_manager:Pause(sound_id)
end
function OverrideUIBase:ResumeMusic(sound_id)
  if not self._playList then
    log_error("OverrideUIBase:ResumeMusic _playList == nil id:" .. sound_id)
    return
  end
  if not self._playList[sound_id] then
    log_error("OverrideUIBase:ResumeMusic _playList not find id:" .. sound_id)
    log_error("OverrideUIBase:ResumeMusic _playList not find id:" .. sound_id)
    return
  end
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  audio_manager:Resume(sound_id)
end
function OverrideUIBase:_RemoveAllMusic()
  if not self._playList then
    return
  end
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  for id, _ in pairs(self._playList) do
    local instance_type = audio_manager:Stop(id)
    audio_manager:Release(id)
    if instance_type == UEnums.LobbyAudioType.Music then
      self:_RestoreMusic()
    end
  end
  self._playList = nil
end
function OverrideUIBase:_RestoreMusic()
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  audio_manager:EnableMusicPlayer()
end
function OverrideUIBase:SetWidgetVisible(widget, visible, isButton)
  if not assert(slua_isValid(widget), "OverrideUIBase:SetWidgetVisible widget is not valid") then
    return
  end
  if not assert(self.Object ~= widget, "Not allow set Object's visibility by call OverrideUIBase:SetWidgetVisible") then
    return
  end
  if visible then
    if isButton then
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function OverrideUIBase:SetTexture(widget, path, params)
  if not path or path == "" then
    if widget then
      widget:SetBrushFromTexture(nil, false)
      return SetTextureConst.Done
    else
      return SetTextureConst.Error
    end
  end
  params = params or {}
  local util = require("client.slua_ui_framework.util")
  if util.IsOnlineImageUrl(path) then
    return self:_DownloadImageWithCDN(widget, path, params)
  elseif string_util.StrFind(path, "/Saved/") then
    return self:_SetTextureFromDiskFile(widget, path, params)
  else
    return util.SetTexture(widget, path, params)
  end
end
function OverrideUIBase:_DownloadImageWithCDN(widget, path, params)
  if not path or path == "" then
    log_error(bWriteLog and "OverrideUIBase:_DownloadImageWithCDN SetTexturePreCheck can't access!")
    return SetTextureConst.Error
  end
  if not util.IsOnlineImageUrl(path) then
    log_error(bWriteLog and "OverrideUIBase:_DownloadImageWithCDN imgUrl is not OnlineImageUrl : " .. path)
    return SetTextureConst.Error
  end
  if not self._downloadImageMgrData then
    self._downloadImageMgrData = {}
  end
  params = params or {}
  params.enableCDNCompress = params.enableCDNCompress or false
  if params.needLocalize then
    path = util.GetUrlByLanguage(path)
  end
  params.ifAddRef = params.ifAddRef or false
  params.tryTimes = params.tryTimes or 1
  params.isForceUpdate = params.isForceUpdate or false
  local OnDownloadSuccess = function(texture, url)
    if slua_isValid(widget) then
      widget:SetBrushFromTexture(texture, params.bMatchSize or false)
    end
    if params.onDownloadSuccess then
      params.onDownloadSuccess(texture, url)
    end
  end
  local OnDownloadFail = function(url)
    if params.onDownloadFail then
      params.onDownloadFail(url)
    end
  end
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  return image_download_mgr:DownloadImageForBase(path, self._downloadImageMgrData, OnDownloadSuccess, OnDownloadFail, params)
end
function OverrideUIBase:CancelImageDownloadByIndex(downloadIndex)
  if not downloadIndex or downloadIndex <= 0 then
    log(bWriteLog and "OverrideUIBase:CancelImageDownloadByIndex downloadIndex is invalid")
    return
  end
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  image_download_mgr:CancelDownloadByIndex(downloadIndex)
end
function OverrideUIBase:_SetTextureFromDiskFile(widget, path, params)
  if not path or path == "" then
    log_warning("OverrideUIBase:_SetTextureFromDiskFile path is " .. tostring(path))
    if widget then
      widget:SetBrushFromTexture(nil, false)
      return SetTextureConst.Done
    else
      return SetTextureConst.Error
    end
  end
  params = params or {}
  local bMatchSize = params.bMatchSize or false
  local asset_util = require("common.asset_util")
  if params.sync == false then
    if not self._asyncLoadDiskFile then
      self._asyncLoadDiskFile = {}
    end
    if self._asyncLoadDiskFile[widget] then
      local handleId = self._asyncLoadDiskFile[widget]
      self._asyncLoadDiskFile[widget] = nil
      asset_util.CancelSavedTextureAsync(handleId - self.Config.DiskStartIndex)
    end
    local enableCDNCompress = params.enableCDNCompress or false
    local handleID = asset_util.GetSavedTextureAsync(path, enableCDNCompress, function(texture)
      if texture then
        widget:SetBrushFromTexture(texture, bMatchSize or false)
        if params.onDownloadSuccess then
          params.onDownloadSuccess(texture, path)
        end
      elseif params.onDownloadFail then
        params.onDownloadFail(path)
      end
    end)
    if not handleID or handleID == 0 then
      return SetTextureConst.Error
    end
    handleID = handleID + self.Config.DiskStartIndex
    self._asyncLoadDiskFile[widget] = handleID
    return handleID
  else
    local texture = asset_util.GetSavedTextureSync(path)
    widget:SetBrushFromTexture(texture, bMatchSize or false)
    if texture then
      if params.onDownloadSuccess then
        params.onDownloadSuccess(texture, path)
      end
      return SetTextureConst.Done
    else
      if params.onDownloadFail then
        params.onDownloadFail(path)
      end
      return SetTextureConst.Error
    end
  end
end
function OverrideUIBase:_GetKeyName(config)
  return base_config_util.GetKeyName(config)
end
function OverrideUIBase:_RemoveImageDownloadData()
  if type(self._downloadImageMgrData) ~= "table" or not next(self._downloadImageMgrData) then
    return
  end
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  image_download_mgr:RemoveImageDownloadDataForBase(self._downloadImageMgrData)
  self._downloadImageMgrData = nil
end
function OverrideUIBase:_RemoveAllAsyncDiskFile()
  if not self._asyncLoadDiskFile then
    return
  end
  local asset_util = require("common.asset_util")
  for widget, handleId in pairs(self._asyncLoadDiskFile) do
    asset_util.CancelSavedTextureAsync(handleId - self.Config.DiskStartIndex)
  end
  self._asyncLoadDiskFile = nil
end
function OverrideUIBase:GetAssetAsync(path, callback, ...)
  return self:AsyncLoadAsset(path, callback, ...)
end
function OverrideUIBase:CancelAssetAsync(HandleID)
  self:CancelAsyncLoad(HandleID)
end
function OverrideUIBase:Initialize()
end
function OverrideUIBase:OnDestroy()
end
function OverrideUIBase:Construct()
  self:OnInitialize()
  self:RegistEvents()
  self:OnPostInitialize()
end
function OverrideUIBase:Destruct()
  self:_RemoveImageDownloadData()
  self:_RemoveAllAsyncDiskFile()
  self:_RemoveAllMusic()
  self:Dispose()
  self:CloseChildWindow()
  self:OnClose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local COverrideUIBase = class(CDelegateContainer, nil, OverrideUIBase)
return COverrideUIBase