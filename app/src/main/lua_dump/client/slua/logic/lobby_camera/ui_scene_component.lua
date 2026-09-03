local ui_scene_component = {}
local IdentifierCount = 0
function ui_scene_component:ctor(_)
  log(bWriteLog and "ui_scene_component ctor")
  self.SceneData = nil
  IdentifierCount = IdentifierCount + 1
  self.Identifier = IdentifierCount
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:RegisterSceneComp(self)
end
function ui_scene_component:SwitchScene(SceneID)
  if SceneID == nil then
    return
  end
  local SceneCfgs = require("client.slua.logic.lobby_camera.scene_module_cfg")
  local SceneCfg = SceneCfgs[SceneID]
  if SceneCfg then
    local TableUtil = require("common.table_util")
    self.SceneData = TableUtil.DeepCloneTable(SceneCfg)
    self.  end
  if not self.SceneData or not self.SceneData.CameraID then
    return
  end
  self:ProcessSceneData()
  log_tree("ui_scene_component SwtichScene", self.SceneData)
  if self.SceneData.bAsync then
    self:AsyncSwtichScene()
  else
    self:SyncSwitchScene()
  end
end
function ui_scene_component:ProcessSceneData()
  if not self.SceneData.LightLevelName or self.SceneData.LightLevelName == "" then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    local CfgLightLevelName = Lobby_camera_manager_module:GetLightLevelNameByCameraID(self.SceneData.CameraID)
    self.SceneData.LightLevelName = CfgLightLevelName
  end
  self.SceneData.LightLoading = false
  self.SceneData.MeshLoading = false
end
function ui_scene_component:SyncSwitchScene()
  if not self.SceneData then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if self.SceneData.MeshLevelName and self.SceneData.MeshLevelName ~= "" then
    LobbySceneManager.LoadStreamLevel(true, self.SceneData.MeshLevelName, self.SceneData.CameraID, self.SceneData.LightLevelName)
  else
    Lobby_camera_manager_module:SwitchCamera_CustomLight(self.SceneData.CameraID, self.SceneData.LightLevelName, 0)
  end
  if self.SceneData.DefaultLightType then
    LobbySceneManager.ChangeLight(self.SceneData.DefaultLightType)
  end
end
function ui_scene_component:AsyncSwtichScene()
  if not self.SceneData then
    return
  end
  if not self.SceneData.LightLevelName or self.SceneData.LightLevelName == "" or self.SceneData.LightLevelName == "Default" then
  else
    self.SceneData.LightLoading = true
  end
  if self.SceneData.MeshLevelName and self.SceneData.MeshLevelName ~= "" then
    self.SceneData.MeshLoading = true
  end
  if not self.SceneData.MeshLoading and not self.SceneData.LightLoading then
    self:OnLevelsLoadDone()
  else
    self:AddCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, self.OnLevelLoaded, self)
    if self.SceneData.LightLoading then
      LobbySceneManager.LoadLightLevel(self.SceneData.LightLevelName, true)
    end
    if self.SceneData.MeshLoading then
      LobbySceneManager.LoadStreamLevel(true, self.SceneData.MeshLevelName)
    end
  end
end
function ui_scene_component:OnLevelLoaded(_, _, LevelName)
  log(bWriteLog and "ui_scene_component:OnLevelLoaded" .. LevelName)
  if not self.SceneData then
    return
  end
  if LevelName == self.SceneData.LightLevelName then
    self.SceneData.LightLoading = false
  end
  if LevelName == self.SceneData.MeshLevelName then
    self.SceneData.MeshLoading = false
  end
  if not self.SceneData.MeshLoading and not self.SceneData.LightLoading then
    self:OnLevelsLoadDone()
  end
end
function ui_scene_component:OnLevelsLoadDone()
  self:RemoveCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED)
  if not self.SceneData then
    return
  end
  if self.SceneData.LightLevelName then
    local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
    if self.SceneData.LightLevelName == "Default" then
      LobbyLightLogic.LoadDefaultLightLevel()
    else
      self:SetLevelVisible(self.SceneData.LightLevelName, true)
      LobbyLightLogic.EnableLobbyMainLight(false)
      LobbyLightLogic.CloseNoNeedLight()
    end
  end
  if self.SceneData.DefaultLightType then
    LobbySceneManager.ChangeLight(self.SceneData.DefaultLightType)
  end
  self:SetLevelVisible(self.SceneData.MeshLevelName, true)
  if self.SceneData.CameraID then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(self.SceneData.CameraID, 0, true)
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    MallSystemWeaponModelHandler.RefreshWeaponLocation()
  end
  self.SceneData.Switched = true
  EventSystem:postEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_LIGHTLEVENL_MESHLEVEL_ALL_LOADED, self.SceneID)
end
function ui_scene_component:SetLevelVisible(LevelName, bVisible)
  if LevelName and LevelName ~= "" then
    local LobbySceneMgrHelper = require("client.slua.logic.manager.LobbySceneSubLogic.LobbySceneMgrHelper")
    local Level = LobbySceneMgrHelper.GetStreamingLevel(LevelName)
    if Level then
      Level.bShouldBeVisible = bVisible
    end
  end
end
function ui_scene_component:HideLobbyMainUI()
  local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
  logic_lobby.HideLobbyUI()
end
function ui_scene_component:ExitCurrentScene()
  if not self.SceneData then
    return
  end
  if not self.SceneData.LightLevelName or self.SceneData.LightLevelName == "" or self.SceneData.LightLevelName == "Default" then
  else
    self.SceneData.LightLoading = true
  end
  if self.SceneData.MeshLevelName and self.SceneData.MeshLevelName ~= "" then
    LobbySceneManager.LoadStreamLevel(false, self.SceneData.MeshLevelName)
  end
end
function ui_scene_component:Destroy()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:UnRegisterSceneComp(self)
  self:Dispose()
end
local class = require("class")
local object = require("common.delegate_container")
local CUISceneComponent = class(object, nil, ui_scene_component)
return CUISceneComponent