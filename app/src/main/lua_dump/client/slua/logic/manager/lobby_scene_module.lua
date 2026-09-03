local lobby_scene_module = {}
local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
function lobby_scene_module:DefineAndResetData()
  self.WaitingUnloadLevel = {}
  self.PreUnloadLevel = {}
  self.CurScene = nil
  self.CurLight = nil
  self.CurCameraID = nil
  self.LoadingScene = nil
  self.LoadingLight = nil
  self.LoadingCameraID = nil
  self.IsDownloading = false
  self.IsLoading = false
  self.OnLevelLoadedCallbackList = {}
  self.LevelPathCache = {}
end
function lobby_scene_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, self.OnLevelLoaded, self)
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, self.OnCameraSwitch, self)
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_REAL_CAMERA_SWITCHED, self.OnCameraSwitch, self)
end
function lobby_scene_module:GetStreamLevelFullPathByName(LevelName)
  log(bWriteLog and string.format("[lobby_scene_module:GetFullPath] Level: %s", LevelName))
  if LevelName == nil or LevelName == "" then
    return nil
  end
  if self.LevelPathCache[LevelName] then
    log(bWriteLog and string.format("[lobby_scene_module:GetFullPath] Path: %s", self.LevelPathCache[LevelName]))
    return self.LevelPathCache[LevelName]
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return nil
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return nil
  end
  local string_util = require("common.string_util")
  for _, uLevelStreaming in pairs(StreamingLevels) do
    local PackageName = uLevelStreaming:GetWorldAssetPackageFName()
    if string_util.Ends(PackageName, LevelName) then
      self.LevelPathCache[LevelName] = PackageName
      break
    end
  end
  log(bWriteLog and string.format("[lobby_scene_module:GetFullPath] Path: %s", self.LevelPathCache[LevelName]))
  return self.LevelPathCache[LevelName]
end
function lobby_scene_module:IsLevelDownloaded(LevelName)
  if IsEditor then
    return true
  end
  local Path = self:GetStreamLevelFullPathByName(LevelName)
  if not Path then
    log(bWriteLog and string.format("[lobby_scene_module:IsLevelDownloaded] No full path of Level: %s", LevelName))
    return true
  end
  local PakName = PufferManager.GetPakName(Path)
  local PakFullPath = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. PakName
  local bExist = PakName == "" or Client.IsFileExistsWithOutPakCheck(PakFullPath)
  log(bWriteLog and string.format("[lobby_scene_module:IsLevelDownloaded] Check Level: %s, Path:%s, PakName: %s, PakFullPath: %s, Exist: %s", LevelName, Path, PakName, PakFullPath, tostring(bExist)))
  return bExist
end
function lobby_scene_module:IsPufferInited()
  if PufferDownloader.InitSuccess then
    return true
  end
  return false
end
function lobby_scene_module:IsLobbyThemeLevel(LevelName)
  if LevelName == nil or LevelName == "" then
    return false
  end
  local Cfg = CDataTable.GetTableDataByFilter("HallThemeItem", "skinLevelName", LevelName)
  if Cfg then
    return true
  end
  return false
end
function lobby_scene_module:GetDefaultScene(LevelName)
  if self:IsLobbyThemeLevel(LevelName) then
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local ThemeID = HallThemeUtils.GetDefaultThemeItemID()
    local loadingSkinCfg = CDataTable.GetTableData("HallThemeItem", ThemeID)
    if loadingSkinCfg then
      return loadingSkinCfg.skinLevelName
    end
  end
  return LevelName
end
function lobby_scene_module:DownloadLevelAndLoad(SceneName, LightName)
  local Paths = {}
  local ScenePath = self:GetStreamLevelFullPathByName(SceneName)
  local LightPath = self:GetStreamLevelFullPathByName(LightName)
  if ScenePath then
    table.insert(Paths, ScenePath)
  end
  if LightPath then
    table.insert(Paths, LightPath)
  end
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, Paths, nil, function()
    if SceneName and SceneName ~= "" and self.LoadingScene == SceneName then
      LobbyLightLogic.LoadStreamLevel(true, SceneName, true, true)
    end
    if LightName and LightName ~= "" and self.LoadingLight == LightName then
      LobbyLightLogic.LoadLightLevel(LightName, true)
    end
  end)
end
function lobby_scene_module:_HandleLevelLoaded()
  self.IsLoading = false
  for _, Level in ipairs(self.WaitingUnloadLevel) do
    if Level ~= self.CurScene and Level ~= self.CurLight then
      LobbyLightLogic.LoadStreamLevel(false, Level, true, true)
    end
  end
  self.WaitingUnloadLevel = self.PreUnloadLevel
  self.PreUnloadLevel = {}
  if self.OnLevelLoadedCallbackList then
    for _, func in ipairs(self.OnLevelLoadedCallbackList) do
      func()
    end
    self.OnLevelLoadedCallbackList = {}
  end
end
function lobby_scene_module:OnLevelLoaded(_, _, LevelName)
  local bIsLevelLoaded = false
  if LevelName == self.LoadingScene then
    self.CurScene = self.LoadingScene
    self.LoadingScene = nil
    bIsLevelLoaded = true
  end
  if LevelName == self.LoadingLight or self.LoadingLight == "Default" then
    self.CurLight = self.LoadingLight
    self.LoadingLight = nil
    bIsLevelLoaded = true
    LobbyLightLogic.EnableLobbyMainLight(false)
    LobbyLightLogic.CloseNoNeedLight()
  end
  if bIsLevelLoaded and self.LoadingScene == nil and self.LoadingLight == nil then
    log(bWriteLog and string.format("[lobby_scene_module:OnLevelLoaded] AsyncLoad: CurScene: %s, CurLight %s, CurCameraID: %s", self.CurScene, self.CurLight, self.CurCameraID))
    self:_HandleLevelLoaded()
  else
    log(bWriteLog and string.format("[lobby_scene_module:OnLevelLoaded] Not LoadingLevel, LoadingScene: %s, LoadingLight: %s, Input: %s", self.LoadingScene, self.LoadingLight, LevelName))
  end
end
function lobby_scene_module:IsMainLobbyCameraID(CameraID)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  return CameraID == Lobby_camera_manager_module.Enum_CameraID.Lobby_Default or CameraID == Lobby_camera_manager_module.Enum_CameraID.Lobby_Team or CameraID == 10008 or CameraID == 10160
end
function lobby_scene_module:OnCameraSwitch(_, _, CameraID)
  if self:IsMainLobbyCameraID(CameraID) then
    log(bWriteLog and string.format("[lobby_scene_module:OnCameraSwitch] Back to lobby, WaitingUnloadLevel = %d", #self.WaitingUnloadLevel))
    self.LoadingScene = nil
    self.LoadingLight = nil
    self.LoadingCameraID = nil
    self.CurScene = nil
    self.CurLight = nil
    self.Cur    self.OnLevelLoadedCallbackList = {}
    self:_HandleLevelLoaded()
  end
  if self.LoadingCameraID and CameraID ~= self.LoadingCameraID then
    self.LoadingScene = nil
    self.LoadingCameraID = nil
    self.LoadingLight = nil
    self.IsLoading = false
    self.OnLevelLoadedCallbackList = {}
  end
end
function lobby_scene_module:OnPlayAction(actionID)
  if self.IsLoading then
    self.PlayingActionID = actionID
  else
    self.PlayingActionID = nil
  end
end
local _GetLightLevelNameByCameraID = function(CameraID)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local info = Lobby_camera_manager_module:GetLobbyCameraInfoByCameraID(CameraID)
  if not info then
    return nil
  end
  local ui_util = require("client.common.ui_util")
  local GameInstance = ui_util.GetGameInstance()
  local LightName
  if GameInstance:GetExactDeviceLevel() <= 0 and info.LightLevelNameLow ~= "" then
    LightName = info.LightLevelNameLow
  else
    LightName = info.LightLevelName
  end
  if LightName == "" then
    LightName = nil
  end
  return LightName
end
function lobby_scene_module:LoadDefaultScene(SceneName, CameraID)
  if SceneName ~= self.LoadingScene then
    table.insert(self.WaitingUnloadLevel, SceneName)
  end
  local async = require("client.common.async")
  async.Run(function(co)
    local uWorld = slua_GameFrontendHUD:GetWorld()
    local GameplayStatics = import("GameplayStatics")
    if slua.isValid(uWorld) then
      GameplayStatics.LoadStreamLevel(uWorld, SceneName, true, true)
      log(bWriteLog and string.format("[lobby_scene_module:LoadDefaultScene] Dafault Scene Loaded"))
    end
  end)
end
function lobby_scene_module:SwitchCameraAfterLoadLevel(CameraID)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if CameraID then
    Lobby_camera_manager_module:SwitchCamera(CameraID, self.BlendTime, true)
    self.BlendTime = 0
    self.Cur    self.LoadingCameraID = nil
  end
end
local SetDefaultValue = function(Extra)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Extra = Extra or {}
  Extra.bAsync = Extra.bAsync or false
  if Extra.bShowDefaultScene == nil then
    Extra.bShowDefaultScene = true
  end
  Extra.Callback = Extra.Callback or nil
  Extra.DefaultScene = Extra.DefaultScene or LobbySceneManager.LEVEL_NAME.PREVIEW_NEW
  Extra.DefaultCameraID = Extra.DefaultCameraID or Lobby_camera_manager_module.Enum_CameraID.item_preview
  Extra.bExclusive = Extra.bExclusive or false
  return Extra
end
function lobby_scene_module:LoadStreamLevel(SceneName, CameraID, LightName, Extra)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Extra = SetDefaultValue(Extra)
  log(bWriteLog and string.format("[lobby_scene_module:LoadStreamLevel] Input: Scene: %s, CameraID: %s, Light: %s, Async: %s", SceneName, CameraID, LightName, Extra.bAsync))
  local bAsync = Extra.bAsync or false
  if SceneName == "" then
    SceneName = nil
  end
  if LightName == "" then
    LightName = nil
  end
  if Extra.bExclusive and self.LoadingScene then
    table.insert(self.WaitingUnloadLevel, self.LoadingScene)
    log(bWriteLog and string.format("[lobby_scene_module:LoadStreamLevel] Abort Prev Scene: %s", self.LoadingScene))
  elseif SceneName == self.LoadingScene then
    if Extra.Callback then
      table.insert(self.OnLevelLoadedCallbackList, Extra.Callback)
    end
    log(bWriteLog and string.format("[lobby_scene_module:LoadStreamLevel] Repeat Load Scene: %s", SceneName))
    return
  end
  if CameraID and (LightName == nil or LightName == "") then
    local ExtraLightName = Lobby_camera_manager_module:GetLightLevelNameByCameraID(CameraID)
    LightName = ExtraLightName
    log(bWriteLog and string.format("[lobby_scene_module:LoadStreamLevel] Real Loading Light: %s", LightName))
  end
  local bSceneDownloaded = self:IsLevelDownloaded(SceneName)
  local bLightDownloaded = LightName == nil or self:IsLevelDownloaded(LightName)
  log(bWriteLog and string.format("[lobby_scene_module:LoadStreamLevel] bSceneDownloaded: " .. tostring(bSceneDownloaded) .. " bLightDownloaded: " .. tostring(bLightDownloaded)))
  self.IsLoading = true
  self.PlayingActionID = nil
  self.OnLevelLoadedCallbackList = {}
  local OnLevelLoadedCallback = function()
    self:SwitchCameraAfterLoadLevel(CameraID)
    if Extra.Callback then
      Extra.Callback()
    end
  end
  table.insert(self.OnLevelLoadedCallbackList, OnLevelLoadedCallback)
  self.LoadingScene = SceneName
  self.LoadingLight = LightName
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  if bAsync and self.CurScene == nil and Extra.bShowDefaultScene and not LobbyThemeManager:IsPreviewStatus() then
    if CameraID == nil then
      CameraID = Lobby_camera_manager_module:GetCurrentCameraID()
      self.Cur    end
    log(bWriteLog and string.format("[lobby_scene_module:LoadStreamLevel] Input: DefaultScene: %s, DefaultCameraID: %s", Extra.DefaultScene, Extra.DefaultCameraID))
    self:LoadDefaultScene(Extra.DefaultScene)
    Lobby_camera_manager_module:SwitchCamera(Extra.DefaultCameraID)
  end
  self.Loading  if (not bSceneDownloaded or not bLightDownloaded) and self:IsPufferInited() then
    self:DownloadLevelAndLoad(SceneName, LightName)
  else
    if not bSceneDownloaded then
      SceneName = self:GetDefaultScene(SceneName)
    end
    if SceneName ~= nil and SceneName ~= "" then
      LobbyLightLogic.LoadStreamLevel(true, SceneName, true, bAsync)
    end
    if LightName ~= nil and LightName ~= "" then
      LobbyLightLogic.LoadLightLevel(LightName, bAsync)
    end
  end
  if (bSceneDownloaded and bLightDownloaded or not self:IsPufferInited()) and not bAsync then
    self.CurScene = self.LoadingScene
    self.CurLight = self.LoadingLight
    self.LoadingScene = nil
    self.LoadingLight = nil
    log(bWriteLog and string.format("[lobby_scene_module:OnLevelLoaded] SyncLoad: CurScene: %s, CurLight: %s, CurCameraID: %s", self.CurScene, self.CurLight, self.CurCameraID))
    self:_HandleLevelLoaded()
  end
end
function lobby_scene_module:UnloadStreamLevel(LevelName, bForce)
  if bForce == true then
    LobbyLightLogic.LoadStreamLevel(false, LevelName, true, true)
    if LevelName == self.CurScene then
      self.CurScene = nil
    elseif LevelName == self.CurLight then
      self.CurLight = nil
    elseif LevelName == self.LoadingScene then
      self.LoadingScene = nil
    elseif LevelName == self.LoadingLight then
      self.LoadingLight = nil
    end
  else
    self.WaitingUnloadLevel = self.WaitingUnloadLevel or {}
    table.insert(self.WaitingUnloadLevel, LevelName)
  end
end
function lobby_scene_module:PreUnloadStreamLevel(LevelName)
  table.insert(self.PreUnloadLevel, LevelName)
end
function lobby_scene_module:IsCurScene(Scene, CameraID, Light)
  local res = true
  if Scene then
    res = res and Scene == self.CurScene
  end
  if CameraID then
    res = res and CameraID == self.CurCameraID
  end
  if Light then
    res = res and Light == self.CurLight
  end
  return res
end
function lobby_scene_module:IsLoadingScene(Scene, CameraID, Light)
  local res = self.IsLoading
  if Scene then
    res = res and Scene == self.LoadingScene
  end
  if CameraID then
    res = res and CameraID == self.LoadingCameraID
  end
  if Light then
    res = res and Light == self.LoadingLight
  end
  return res
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbySceneModule = class(CModuleBase, nil, lobby_scene_module)
return CLobbySceneModule