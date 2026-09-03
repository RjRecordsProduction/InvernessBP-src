local ui_show_manager = {
  bSwitch = true,
  CloseWaitingInfo = nil,
  ShowWaitingInfo = nil,
  AsyHandleInfo = {
    bUICompleted = true,
    bMeshCompleted = true,
    bLightCompleted = true,
    uiConfig = nil,
    meshLevelName = "",
    lightLevelName = ""
  },
  XMissionBGNeedClose = false,
  MainCityWeatherClose = false
}
ui_show_manager.LobbyType = {
  Normal = 1,
  XMission = 2,
  MainCity = 3
}
local local 
function ui_show_manager.SetCloseWaitingInfo(uiJumpManagerNode)
  ui_show_manager.CloseWaitingInfo = uiJumpManagerNode
end
function ui_show_manager.SetShowWaitingInfo(uiJumpManagerNode)
  log(bWriteLog and "ui_show_manager.SetShowWaitingInfo uiJumpManagerNode = " .. tostring(uiJumpManagerNode))
  ui_show_manager.ShowWaitingInfo = uiJumpManagerNode
end
function ui_show_manager.CheckHasShowWaitingInfo()
  return ui_show_manager.ShowWaitingInfo ~= nil
end
function ui_show_manager.Handle(isShow, config)
  if isShow then
    EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_OPEN, config)
  else
    EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_CLOSE, config)
  end
  if ui_show_manager._CheckAsy() then
    ui_show_manager._AsyHandle(isShow)
    return nil
  else
    return ui_show_manager._DoHandle(isShow)
  end
end
function ui_show_manager.HideCurLobby()
  log(bWriteLog and "ui_show_manager.HideCurLobby")
  ui_show_manager._CloseLobby()
end
function ui_show_manager.HandleJumpBackSubUI(_FrameSubUIList)
  if not _FrameSubUIList or #_FrameSubUIList <= 0 then
    return
  end
  log(bWriteLog and "ui_show_manager.HandleJumpBackSubUI")
  for index = 1, #_FrameSubUIList do
    local subUINode = _FrameSubUIList[index]
    if subUINode.config.handleJumpEvent == ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW then
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      ui_jump_manager.OnSubUIOpen(subUINode.config)
      ui_show_manager._ShowOne(subUINode, false)
    end
  end
end
function ui_show_manager._CheckAsy()
  if not ui_show_manager.bSwitch then
    log(bWriteLog and "ui_show_manager._CheckAsy: bSwitch is false")
    return false
  end
  if not ui_show_manager.CloseWaitingInfo or not ui_show_manager.CloseWaitingInfo.config then
    log(bWriteLog and "ui_show_manager._CheckAsy: not CloseWaitingInfo.config")
    return false
  end
  if not ui_show_manager.ShowWaitingInfo or not ui_show_manager.ShowWaitingInfo.config then
    log(bWriteLog and "ui_show_manager._CheckAsy: not ShowWaitingInfo")
    return false
  end
  local closeConfig = ui_show_manager.CloseWaitingInfo.config
  local showConfig = ui_show_manager.ShowWaitingInfo.config
  if ui_show_manager.CloseWaitingInfo.isModuleNode then
    local module = ModuleManager.GetModule(closeConfig)
    if module then
      closeConfig = module:GetPreLoadUIConfig()
      if not closeConfig then
        log(bWriteLog and "ui_show_manager._CheckAsy: close module not uiConfig")
        return false
      end
    else
      log(bWriteLog and "ui_show_manager._CheckAsy: close module not found")
      return false
    end
  end
  if ui_show_manager.ShowWaitingInfo.isModuleNode then
    local module = ModuleManager.GetModule(showConfig)
    if module then
      showConfig = module:GetPreLoadUIConfig()
      if not showConfig then
        log(bWriteLog and "ui_show_manager._CheckAsy: show module not uiConfig")
        return false
      end
    else
      log(bWriteLog and "ui_show_manager._CheckAsy: show module not found")
      return false
    end
  end
  local scene_module_cfg = require("client.slua.logic.lobby_camera.scene_module_cfg")
  local SceneCfg = scene_module_cfg[showConfig.sceneID]
  if showConfig.asy ~= true and (not SceneCfg or SceneCfg.bAsync ~= true) then
    log(bWriteLog and "ui_show_manager._CheckAsy keyName:" .. tostring(showConfig.keyName) .. " return of not asy")
    return false
  end
  ui_show_manager.AsyHandleInfo.uiConfig = showConfig
  log(bWriteLog and "ui_show_manager._CheckAsy close:" .. tostring(closeConfig.keyName) .. ", show:" .. tostring(showConfig.keyName))
  return true
end
function ui_show_manager._AsyHandle(isShow)
  local AsyHandleInfo = ui_show_manager.AsyHandleInfo
  AsyHandleInfo.bUICompleted = false
  AsyHandleInfo.bMeshCompleted = false
  AsyHandleInfo.bLightCompleted = false
  AsyHandleInfo.  local showConfig = AsyHandleInfo.uiConfig
  local scene_module_cfg = require("client.slua.logic.lobby_camera.scene_module_cfg")
  local SceneCfg = scene_module_cfg[showConfig.sceneID]
  ui_show_manager._AsyLoadScene(SceneCfg)
  ui_show_manager._AsyLoadUI(showConfig)
end
function ui_show_manager._AsyLoadScene(SceneCfg)
  if not SceneCfg or not SceneCfg.bAsync then
    local AsyHandleInfo = ui_show_manager.AsyHandleInfo
    AsyHandleInfo.bMeshCompleted = true
    AsyHandleInfo.bLightCompleted = true
    ui_show_manager._AsyLoadCompleted()
    return
  end
  local AsyHandleInfo = ui_show_manager.AsyHandleInfo
  AsyHandleInfo.meshLevelName = SceneCfg.MeshLevelName or ""
  AsyHandleInfo.lightLevelName = SceneCfg.LightLevelName or ""
  if AsyHandleInfo.lightLevelName == "" then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    AsyHandleInfo.lightLevelName = Lobby_camera_manager_module.GetLightLevelNameByCameraID(SceneCfg.CameraID)
    ui_show_manager.AsyHandleInfo.bLightCompleted = true
  end
  EventSystem:registEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, ui_show_manager._OnLevelLoaded)
  LobbySceneManager.LoadStreamLevel(true, AsyHandleInfo.meshLevelName, nil, AsyHandleInfo.lightLevelName)
end
function ui_show_manager._OnLevelLoaded(_, _, LevelName)
  local AsyHandleInfo = ui_show_manager.AsyHandleInfo
  if AsyHandleInfo.meshLevelName and AsyHandleInfo.meshLevelName == LevelName then
    AsyHandleInfo.bMeshCompleted = true
  end
  if AsyHandleInfo.lightLevelName and AsyHandleInfo.lightLevelName == LevelName then
    AsyHandleInfo.bLightCompleted = true
  end
  ui_show_manager._AsyLoadCompleted()
end
function ui_show_manager._AsyLoadUI(config)
  local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
  local pool = EUIConfigPoolType.GetModuleByType(config.loadFromPool)
  if pool then
    pool:GetAsy(config.path, function(_, obj)
      pool:Release(obj)
      ui_show_manager._OnUILoaded()
    end)
  else
    slua.AsyncLoadUI(config.path, function(_, obj)
      ui_show_manager._OnUILoaded()
    end)
  end
end
function ui_show_manager._OnUILoaded()
  ui_show_manager.AsyHandleInfo.bUICompleted = true
  ui_show_manager._AsyLoadCompleted()
end
function ui_show_manager._AsyLoadCompleted()
  local AsyHandleInfo = ui_show_manager.AsyHandleInfo
  if not (AsyHandleInfo.bUICompleted and AsyHandleInfo.bMeshCompleted) or not AsyHandleInfo.bLightCompleted then
    return
  end
  EventSystem:unregistEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, ui_show_manager._OnLevelLoaded)
  ui_show_manager._DoHandle(AsyHandleInfo.isShow)
end
function ui_show_manager._DoHandle(isShow)
  local utility = require("common.utility")
  xpcall(ui_show_manager._DoClose, utility.ErrorMessageHandler)
  local _, uiInstance = xpcall(ui_show_manager._DoShow, utility.ErrorMessageHandler, isShow)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OnHandleFinish()
  if isShow then
    return uiInstance
  end
end
function ui_show_manager._DoClose()
  local closeWaitingInfo = ui_show_manager.CloseWaitingInfo
  ui_show_manager.CloseWaitingInfo = nil
  if closeWaitingInfo then
    if closeWaitingInfo.isModuleNode then
      local module = ModuleManager.GetModule(closeWaitingInfo.config)
      if module then
        module:CloseModule()
      end
    elseif closeWaitingInfo.config then
      log(bWriteLog and "[jonahwei]UIJumpManager:DoClose  " .. closeWaitingInfo.config.keyName)
      UIManager._ProcessCloseUI(closeWaitingInfo.config)
    end
    if closeWaitingInfo.uiData and closeWaitingInfo.uiData._FrameSubUIList then
      for _, subUINode in ipairs(closeWaitingInfo.uiData._FrameSubUIList) do
        local subConfig = subUINode.config
        log(bWriteLog and "[jonahwei]UIJumpManager:DoClose  " .. subConfig.keyName)
        UIManager._ProcessCloseUI(subConfig)
      end
    end
    if closeWaitingInfo.moduleID == BP_ENUM_MODULE_LOBBY then
      ui_show_manager._CloseLobby()
    end
  end
end
function ui_show_manager._CloseLobby()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local closeType = ui_show_manager.LobbyType.Normal
  if GameStatus.IsInMainCity() then
    closeType = ui_show_manager.LobbyType.MainCity
  elseif ui_show_manager._isInTxMission() then
    closeType = ui_show_manager.LobbyType.XMission
  end
  log(bWriteLog and "ui_show_manager._CloseLobby closeType = " .. tostring(closeType))
  if closeType == ui_show_manager.LobbyType.MainCity then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    Lobby_Main_City_Enter.LeaveMainCity_Jump()
    EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_JUMPOUT)
    ui_show_manager.MainCityWeatherClose = true
    EventSystem:registEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, ui_show_manager._OnCameraSwitch)
    return
  end
  if closeType == ui_show_manager.LobbyType.XMission then
    ui_show_manager.XMissionBGNeedClose = true
    LogicTxMissionMain.JumpOutLobby()
    return
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
end
function ui_show_manager._OnCameraSwitch()
  log(bWriteLog and "ui_show_manager.OnCameraSwitch")
  EventSystem:unregistEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, ui_show_manager._OnCameraSwitch)
  if ui_show_manager.MainCityWeatherClose then
    ui_show_manager.MainCityWeatherClose = false
    local MainCity_Leave_Weather = require("client.slua.logic.lobby.MainCity.Main.Leave.MainCity_Leave_Weather")
    MainCity_Leave_Weather.LeaveMainCity_Weather()
  end
end
function ui_show_manager._DoShow(isShow)
  local showWaitingInfo = ui_show_manager.ShowWaitingInfo
  ui_show_manager.SetShowWaitingInfo(nil)
  if showWaitingInfo and showWaitingInfo.moduleID ~= BP_ENUM_MODULE_LOBBY and ui_show_manager.XMissionBGNeedClose then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.UINeedChangeBG(showWaitingInfo.moduleID) then
      ui_show_manager.XMissionBGNeedClose = false
      local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
      LobbyLightLogic.LoadStreamLevel(false, "TPlan_Lobby_Light")
      local STExtraGameInstance = import("STExtraGameInstance")
      local GameInstance = STExtraGameInstance.GetInstance()
      local GameplayStatics = import("GameplayStatics")
      GameplayStatics.FlushLevelStreaming(GameInstance)
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_UPDATE_LOBBY_SCENE, false)
    end
  end
  local ui
  if showWaitingInfo and showWaitingInfo.config then
    if showWaitingInfo.isModuleNode then
      local module = ModuleManager.GetModule(showWaitingInfo.config)
      if module then
        module:ShowModule(showWaitingInfo.ctorData, isShow)
        if not isShow then
          module:JumpBack(showWaitingInfo.uiData)
        end
      end
    else
      ui = ui_show_manager._ShowOne(showWaitingInfo, isShow)
    end
    local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
    HostedProtoBridge:SendGameUIShow(showWaitingInfo.moduleID)
  end
  if showWaitingInfo and showWaitingInfo.moduleID == BP_ENUM_MODULE_LOBBY then
    ui_show_manager._ShowLobby(showWaitingInfo)
  end
  return ui
end
function ui_show_manager._ShowLobby(showWaitingInfo)
  local showType = ui_show_manager.LobbyType.Normal
  if GameStatus.IsInMainCity() then
    showType = ui_show_manager.LobbyType.MainCity
  elseif ui_show_manager._isInTxMission() then
    showType = ui_show_manager.LobbyType.XMission
  end
  log(bWriteLog and "ui_show_manager._ShowLobby showType = " .. tostring(showType))
  if showType == ui_show_manager.LobbyType.MainCity then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    Lobby_Main_City_Enter.EnterMainCity_Jump()
    EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_JUMPBACK)
  elseif showType == ui_show_manager.LobbyType.XMission then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_RETURN_LOBBY)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_UPDATE_LOBBY_SCENE, true)
    ui_show_manager.XMissionBGNeedClose = false
  else
    local UIUtil = require("client.common.ui_util")
    UIUtil.ShowLobbyUI(true)
  end
  if showWaitingInfo and showWaitingInfo.uiData then
    ui_show_manager.HandleJumpBackSubUI(showWaitingInfo.uiData._FrameSubUIList)
  end
end
function ui_show_manager._ShowOne(showInfo, isShow)
  local config = showInfo.config
  local ctorData = showInfo.ctorData
  local uiData = showInfo.uiData
  local ctorDataLength = ui_show_manager._GetCtorDataLength(ctorData)
  local ui
  log(bWriteLog and "[jonahwei]UIJumpManager:ShowOne  " .. config.keyName)
  if 0 < ctorDataLength then
    ui = UIManager._ProcessShowUI(nil, nil, config, nil, nil, table.unpack(ctorData, 1, ctorDataLength))
  else
    ui = UIManager._ProcessShowUI(nil, nil, config, nil, nil)
  end
  if not isShow then
    ui:_HandleJumpBack(uiData)
  end
  return ui
end
function ui_show_manager._isInTxMission()
  if ui_show_manager.bTXmissionStateCheck == nil then
    ui_show_manager.bTXmissionStateCheck = HDmpveRemote.HDmpveRemoteConfigGetBool("bTXmissionStateCheck", false)
    log(bWriteLog and "ui_show_manager._isInTxMission bTXmissionStateCheck = " .. tostring(ui_show_manager.bTXmissionStateCheck))
  end
  if ui_show_manager.bTXmissionStateCheck then
    local xmission_main = UIManager.GetUI(UIManager.UI_Config.xmission_main)
    return xmission_main ~= nil
  else
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    return LogicTxMissionMain.IsInXMission()
  end
end
function ui_show_manager._GetCtorDataLength(ctorData)
  if not ctorData then
    return 0
  end
  local max = 0
  for k in pairs(ctorData) do
    if type(k) == "number" and k > max then
      max = k
    end
  end
  return max
end
return ui_show_manager