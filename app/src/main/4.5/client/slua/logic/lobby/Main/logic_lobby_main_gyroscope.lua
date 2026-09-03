local logic_lobby_main_gyroscope = {
  maxGyroScopeOffset = 15,
  maxGyroScopeOffsetZ = 4,
  maskGyScopeLeftTime = 0,
  cameraPosList = {},
  bIsValidInput = true,
  validGyroScopeDelta = 10
}
function logic_lobby_main_gyroscope.Init()
  log(bWriteLog and "logic_lobby_main_gyroscope.Init")
  logic_lobby_main_gyroscope.bIsValidInput = true
  logic_lobby_main_gyroscope.curGyroScopeDeltaYaw = 0
  logic_lobby_main_gyroscope.curGyroScopeDeltaPitch = 0
  logic_lobby_main_gyroscope.lastDeltaX = nil
  logic_lobby_main_gyroscope.initPos = nil
  logic_lobby_main_gyroscope.maskGyScopeLeftTime = 3
  local cameraIdList = {10001, 10002}
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  logic_lobby_main_gyroscope.cameraPosList = {}
  for i = 1, #cameraIdList do
    local cfg = Lobby_camera_manager_module:GetLobbyCameraLocationByCameraID(cameraIdList[i])
    if cfg and next(cfg) then
      logic_lobby_main_gyroscope.cameraPosList[i] = cfg
    end
  end
  EventSystem:registEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, logic_lobby_main_gyroscope.OnGyroScopeInput)
  EventSystem:registEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, logic_lobby_main_gyroscope.OnCameraSwitched)
  local time_ticker = require("common.time_ticker")
  log(bWriteLog and "logic_lobby_main_gyroscope.OnGyroScopeTimer")
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  logic_lobby_main_gyroscope.gyroScopeTimer = time_ticker.AddTimerLoop(time_ticker.MINIMUM_STEP_TIME, function()
    if logic_lobby_main_gyroscope.maskGyScopeLeftTime > 0 then
      logic_lobby_main_gyroscope.maskGyScopeLeftTime = logic_lobby_main_gyroscope.maskGyScopeLeftTime - 0.03
    end
    local bInLobby = UIManager.IsAndroidStackEmpty()
    if Lobby_Main_Control.bAni == false and Lobby_Main_Control.curPage == 1 and bInLobby and logic_lobby_main_gyroscope.maskGyScopeLeftTime <= 0 then
      logic_lobby_main_gyroscope.MoveCamera(ui.Lobby20_Control_Comp)
    else
      logic_lobby_main_gyroscope.curGyroScopeDeltaYaw = 0
      logic_lobby_main_gyroscope.curGyroScopeDeltaPitch = 0
      logic_lobby_main_gyroscope.initPos = nil
    end
  end, TIMER_INFINITE, time_ticker.MINIMUM_STEP_TIME)
end
function logic_lobby_main_gyroscope.Destroy()
  log(bWriteLog and "logic_lobby_main_gyroscope.Destroy")
  EventSystem:unregistEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, logic_lobby_main_gyroscope.OnGyroScopeInput)
  EventSystem:unregistEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, logic_lobby_main_gyroscope.OnCameraSwitched)
  local time_ticker = require("common.time_ticker")
  if logic_lobby_main_gyroscope.gyroScopeTimer then
    time_ticker.RemoveTimer(logic_lobby_main_gyroscope.gyroScopeTimer)
    logic_lobby_main_gyroscope.gyroScopeTimer = nil
  end
end
function logic_lobby_main_gyroscope.OnGyroScopeInput(_, __, deltaX, deltaY, deltaZ)
  if not logic_lobby_main_gyroscope.bIsValidInput then
    return
  end
  if not logic_lobby_main_gyroscope.lastDeltaX then
    logic_lobby_main_gyroscope.lastDeltaX = deltaX
  end
  if math.abs(logic_lobby_main_gyroscope.lastDeltaX - deltaX) > logic_lobby_main_gyroscope.validGyroScopeDelta then
    logic_lobby_main_gyroscope.curGyroScopeDeltaYaw = 0
    logic_lobby_main_gyroscope.curGyroScopeDeltaPitch = 0
    logic_lobby_main_gyroscope.bIsValidInput = false
    return
  end
  logic_lobby_main_gyroscope.curGyroScopeDeltaYaw = logic_lobby_main_gyroscope.curGyroScopeDeltaYaw + deltaX
  logic_lobby_main_gyroscope.curGyroScopeDeltaPitch = logic_lobby_main_gyroscope.curGyroScopeDeltaPitch + deltaY
end
function logic_lobby_main_gyroscope.OnCameraSwitched(_, __, cameraId)
  log(bWriteLog and "logic_lobby_main_gyroscope.OnCameraSwitched cameraId = " .. cameraId)
  logic_lobby_main_gyroscope.maskGyScopeLeftTime = 2
end
function logic_lobby_main_gyroscope.MoveCamera(controlComp)
  if logic_lobby_main_gyroscope.curGyroScopeDeltaYaw == 0 and logic_lobby_main_gyroscope.curGyroScopeDeltaPitch == 0 then
    return
  end
  local camera = controlComp:GetCamera()
  if not slua.isValid(camera) then
    return
  end
  local cameraLocation = camera:K2_GetActorLocation()
  if logic_lobby_main_gyroscope.initPos == nil then
    logic_lobby_main_gyroscope.initPos = cameraLocation
  end
  cameraLocation.X = cameraLocation.X + logic_lobby_main_gyroscope.curGyroScopeDeltaYaw * 0.4
  cameraLocation.Z = cameraLocation.Z + logic_lobby_main_gyroscope.curGyroScopeDeltaPitch * 0.1
  if cameraLocation.X < logic_lobby_main_gyroscope.initPos.X - logic_lobby_main_gyroscope.maxGyroScopeOffset then
    cameraLocation.X = logic_lobby_main_gyroscope.initPos.X - logic_lobby_main_gyroscope.maxGyroScopeOffset
  elseif cameraLocation.X > logic_lobby_main_gyroscope.initPos.X + logic_lobby_main_gyroscope.maxGyroScopeOffset then
    cameraLocation.X = logic_lobby_main_gyroscope.initPos.X + logic_lobby_main_gyroscope.maxGyroScopeOffset
  end
  if cameraLocation.Z < logic_lobby_main_gyroscope.initPos.Z - logic_lobby_main_gyroscope.maxGyroScopeOffsetZ then
    cameraLocation.Z = logic_lobby_main_gyroscope.initPos.Z - logic_lobby_main_gyroscope.maxGyroScopeOffsetZ
  elseif cameraLocation.Z > logic_lobby_main_gyroscope.initPos.Z + logic_lobby_main_gyroscope.maxGyroScopeOffsetZ then
    cameraLocation.Z = logic_lobby_main_gyroscope.initPos.Z + logic_lobby_main_gyroscope.maxGyroScopeOffsetZ
  end
  if logic_lobby_main_gyroscope.CheckCameraPosValid(cameraLocation) then
    camera:K2_SetActorLocation(cameraLocation, false, nil, false)
  else
  end
  logic_lobby_main_gyroscope.curGyroScopeDeltaYaw = 0
  logic_lobby_main_gyroscope.curGyroScopeDeltaPitch = 0
end
function logic_lobby_main_gyroscope.CheckCameraPosValid(position)
  for i = 1, #logic_lobby_main_gyroscope.cameraPosList do
    local cfg = logic_lobby_main_gyroscope.cameraPosList[i]
    if position.X >= cfg[1] - logic_lobby_main_gyroscope.maxGyroScopeOffset and position.X <= cfg[1] + logic_lobby_main_gyroscope.maxGyroScopeOffset and position.Y >= cfg[2] - logic_lobby_main_gyroscope.maxGyroScopeOffsetZ and position.Y <= cfg[2] + logic_lobby_main_gyroscope.maxGyroScopeOffsetZ then
      return true
    end
  end
  return false
end
return logic_lobby_main_gyroscope