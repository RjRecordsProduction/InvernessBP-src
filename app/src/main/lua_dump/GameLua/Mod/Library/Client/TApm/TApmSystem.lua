local TApmSystem = {}
function TApmSystem.Init()
  local DelegateContainerC = require("common.delegate_container")
  if TApmSystem.DelegateContainer and TApmSystem.DelegateContainer.UnRegistEvents then
    TApmSystem.DelegateContainer:UnRegistEvents()
  end
  TApmSystem.DelegateContainer = TApmSystem.DelegateContainer or DelegateContainerC()
  TApmSystem.DelegateContainer:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY, TApmSystem.OnControllerBeginPlay)
  TApmSystem.DelegateContainer:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SYNC_CIRCILE_INFO, TApmSystem.OnSyncCircleInfo)
end
function TApmSystem.OnControllerBeginPlay()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    TApmSystem.DelegateContainer:AddControlEvent(uPlayerController, "OnGameStartCountDownDelegate", TApmSystem.OnGameStartCountDown)
  end
end
function TApmSystem.OnGameStartCountDown(nReadyStateTime)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    if 0 < nReadyStateTime then
      TApmHelper.PostGameStatusToTGPASS("18", "1:" .. nReadyStateTime)
    end
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    TApmSystem.DelegateContainer:RemoveControlEvent(uPlayerController, "OnGameStartCountDownDelegate")
  end
end
function TApmSystem.OnSyncCircleInfo(_, __, nCircleInfo)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local strRegion = Client.GetPublishRegion()
    if strRegion ~= PublishRegionMacros.BLUEHOLE then
      local ECircleInfo = import("ECircleInfo")
      if nCircleInfo == ECircleInfo.BlueCirclePreWarning then
        local nCurCircleStatusLastTime = uGameState.CurCircleStatusLastTime
        local TApmHelper = import("TApmHelper")
        if 0 < nCurCircleStatusLastTime then
          TApmHelper.PostGameStatusToTGPASS("18", "2:" .. nCurCircleStatusLastTime)
        end
      elseif nCircleInfo == ECircleInfo.SafeZoneTips then
        local TApmHelper = import("TApmHelper")
        TApmHelper.PostGameStatusToTGPASS("18", "3:0")
      end
    end
  end
end
function TApmSystem.ShutdownReport()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    if TApmHelper then
      print(bWriteLog and "TApmSystem.PostGameStatusToTGPASS 18 4,0")
      TApmHelper.PostGameStatusToTGPASS("18", "4:0")
    end
  end
end
function TApmSystem.Shutdown()
  TApmSystem.ShutdownReport()
  if TApmSystem.DelegateContainer then
    TApmSystem.DelegateContainer:Dispose()
  end
end
return TApmSystem