local LockLobbyCameraLogic = {}
local lockLobbyCamera = false
local CheckSwitchCameraNeedLock = function()
  if UIManager.IsUIShow(UIManager.UI_Config.Lobby_Main_UIBP) then
    log(bWriteLog and "xcc LockLobbyCameraLogic CheckSwitchCameraNeedLock unlock")
    return false
  end
  log(bWriteLog and "xcc LockLobbyCameraLogic CheckSwitchCameraNeedLock lock")
  return true
end
function LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera()
  log(bWriteLog and "[cw][team] LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera()")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if ui then
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local page = Lobby_Main_Control.curPage
    if page == ENUM_LobbyPageType.Left then
      log(bWriteLog and "[cw][team] LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera() page == ENUM_LobbyPageType.Left")
      return true
    end
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  if lockLobbyCamera then
    log(bWriteLog and "[cw][team]LobbySceneManager:SwitchCheck--LobbySceneManager.lockLobbyCamera " .. tostring(lockLobbyCamera))
    return false
  elseif logicCreateRole.NCreateRoleLobbyToAvatar == 1 then
    log(bWriteLog and "[cw][team]LobbySceneManager:SwitchCheck--BP_CreateRole_LobbyToAvatar " .. tostring(logicCreateRole.NCreateRoleLobbyToAvatar))
    return true
  elseif UnknowPassTunnelSystem.isShowRP then
    log(bWriteLog and "[cw][team][ZH] UnknowPassTunnelSystem.isShowRP: " .. tostring(UnknowPassTunnelSystem.isShowRP))
    return true
  elseif store_supply_manager:GetCurrentFrame() ~= nil then
    log(bWriteLog and "[cw][team]LobbySceneManager:CheckCanSwitchToLobbyCamera, In NewStoreSystem and do not change camera.")
    return true
  elseif RoleInfoMainSystem.IsShow() then
    log(bWriteLog and "[cw][team]LobbySceneManager:CheckCanSwitchToLobbyCamera, In RoleInfoUI and do not change camera.")
    return true
  elseif CheckSwitchCameraNeedLock() then
    log(bWriteLog and "[cw][team] avatar lock camera")
    return true
  elseif UIManager.GetUI(UIManager.UI_Config.fashion_bag_overview) then
    return true
  else
    log(bWriteLog and "[cw][team] LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera() else ")
    return false
  end
end
function LockLobbyCameraLogic.SwitchMainOrTeamCamera(force)
  log(bWriteLog and "[cw][team] LockLobbyCameraLogic.SwitchMainOrTeamCamera(" .. tostring(force) .. ")")
  if LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera() then
    log(bWriteLog and "[cw][team] LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera()")
    return
  end
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if Lobby_Main_Control.curPage ~= ENUM_LobbyPageType.Mid and not force then
    log(bWriteLog and "[cw][team] Lobby_Main_Control.curPage ~= ENUM_LobbyPageType.Mid and not force")
    return
  end
  if Lobby_Main_Control.bAni and Lobby_Main_Control.toPage ~= ENUM_LobbyPageType.Mid then
    log(bWriteLog and "[cw][team] Lobby_Main_Control.bAni and Lobby_Main_Control.toPage ~= ENUM_LobbyPageType.Mid")
    return
  end
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "[cw][team] Lobby_Main_Control.bAni and IsInMainCity")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if TeamUpNewSystem.GetTeamNum() == 1 then
    log(bWriteLog and "[cw][team] TeamUpNewSystem.GetTeamNum() == 1")
    log(bWriteLog and "[cw][team] Lobby_camera_manager_module.currentCameraID:" .. tostring(Lobby_camera_manager_module.currentCameraID))
    log(bWriteLog and "[cw][team] Lobby_camera_manager_module.Enum_CameraID.Lobby_Default:" .. tostring(Lobby_camera_manager_module.Enum_CameraID.Lobby_Default))
    if Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Default then
      log(bWriteLog and "[cw][team] Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team")
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Default, 0.7)
    end
  else
    log(bWriteLog and "[cw][team] TeamUpNewSystem.GetTeamNum() ~= 1")
    log(bWriteLog and "[cw][team] Lobby_camera_manager_module.currentCameraID:" .. tostring(Lobby_camera_manager_module.currentCameraID))
    log(bWriteLog and "[cw][team] Lobby_camera_manager_module.Enum_CameraID.Lobby_Default:" .. tostring(Lobby_camera_manager_module.Enum_CameraID.Lobby_Team))
    if Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team then
      log(bWriteLog and "[cw][team] Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team")
      if Lobby_camera_manager_module.currentCameraID == Lobby_camera_manager_module.Enum_CameraID.RpPreview then
        Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Team)
      else
        Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Team, 0.7)
      end
    end
  end
end
function LockLobbyCameraLogic.SetLockLobbyCamera(isLock)
  lockLobbyCamera = isLock
end
return LockLobbyCameraLogic