local lobby_camera_function_library = {}
function lobby_camera_function_library:OnViewportSizeChanged(vViewportOld, vViewportNew)
  if not Client then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:OnViewportSizeChanged(vViewportOld, vViewportNew)
end
function lobby_camera_function_library:GetCurrentCameraActor()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  return Lobby_camera_manager_module:GetCurrentCamera()
end
function lobby_camera_function_library:SwitchCamera(nCameraID, nBlendTime, bIgnoreLight)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(nCameraID, nBlendTime, bIgnoreLight)
end
function lobby_camera_function_library:SwitchCamera_Only(nCameraID, nBlendTime)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera_Only(nCameraID, nBlendTime)
end
function lobby_camera_function_library:LevelSequence_ExecuteEndCallback()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:_ExecuteLevelSequenceEndCallback()
end
function lobby_camera_function_library:LevelSequence_ExecuteStartCallback()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:_ExecuteLevelSequenceBeginCallback()
end
local class = require("class")
local object = require("object")
local LobbyCameraFunctionLibraryClass = class(object, nil, lobby_camera_function_library)
return LobbyCameraFunctionLibraryClass