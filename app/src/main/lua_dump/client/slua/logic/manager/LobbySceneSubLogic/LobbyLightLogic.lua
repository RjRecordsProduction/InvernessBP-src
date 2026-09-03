local LobbyLightLogic = {
  LightLevel = {},
  DelayUnLoadTimer = {}
}
local loadedLevels = {}
local LEVEL_NAME = {}
local LIGHT_LEVEL_NAME = {}
LIGHT_LEVEL_NAME.REFIT_VEHICLE = "Lobby_Refitvehicle_mesh_light"
local getTime = slua.getMicroseconds
local lastLevelName = ""
local DoExtraOnLoadLevel = function(levelName)
  local StringUtil = require("common.string_util")
  if StringUtil.Ends(levelName, "_Light") or StringUtil.Ends(levelName, "_light") then
    if levelName == "Lobby_Garage_mesh_light" then
      GlobalData.SetShadowDistanceScale(0.5)
    else
      local ShadowDistanceScale_Current_f = GlobalData.GetShadowDistanceScale()
      if ShadowDistanceScale_Current_f ~= 0 then
        GlobalData.SetShadowDistanceScale(ShadowDistanceScale_Current_f)
      end
    end
  end
end
function LobbyLightLogic.ForceUnLoadStreamLevel(levelName)
  local async = require("client.common.async")
  async.Run(function(co)
    local world = slua_GameFrontendHUD:GetWorld()
    local GameplayStatics = import("GameplayStatics")
    GameplayStatics.UnloadStreamLevel(world, levelName)
    loadedLevels[levelName] = 0
  end)
end
function LobbyLightLogic.UnloadAllLoadedLevel()
  for k, v in pairs(loadedLevels) do
    if v == 1 then
      LobbyLightLogic.ForceUnLoadStreamLevel(k)
      log(bWriteLog and "try unload level before switch scene:" .. tostring(k))
    end
  end
end
function LobbyLightLogic.IsLightLevelLoaded(levelName)
  return LobbyLightLogic.LightLevel[levelName] and true or false
end
function LobbyLightLogic.OnModePostSwitch(_, _, statusData)
  print(bWriteLog and "LobbyLightLogic.OnModePostSwitch status" .. tostring(statusData.current))
end
function LobbyLightLogic.LoadLightLevel(lightLevelName, bAync)
  print(bWriteLog and "LobbyLightLogic.LoadLightLevel lightLevelName:" .. tostring(lightLevelName) .. " bAync:" .. tostring(bAync) .. " currentLight: " .. tostring(LobbyLightLogic.currentLight))
  if lightLevelName == "Default" then
    LobbyLightLogic.LoadDefaultLightLevel()
  else
    LobbyLightLogic.LoadOtherLightLevel(lightLevelName, bAync)
  end
end
function LobbyLightLogic.LoadDefaultLightLevel()
  LobbyLightLogic.EnableLobbyMainLight(true)
  LobbyLightLogic.currentLight = "Default"
  for name, _ in pairs(LobbyLightLogic.LightLevel) do
    LobbyLightLogic.LoadStreamLevel(false, name)
    LobbyLightLogic.LightLevel[name] = false
  end
end
function LobbyLightLogic.LoadOtherLightLevel(lightLevelName, bAync)
  LobbyLightLogic.currentLight = lightLevelName
  if not bAync then
    LobbyLightLogic.EnableLobbyMainLight(false)
    LobbyLightLogic.CloseNoNeedLight()
  end
  LobbyLightLogic.LoadStreamLevel(true, lightLevelName, true, bAync)
  LobbyLightLogic.LightLevel[lightLevelName] = true
end
function LobbyLightLogic.UnLoadLightLevel(lightLevelName)
  log(bWriteLog and string.format("LobbyLightLogic.UnLoadLightLevel level=%s", tostring(lightLevelName)))
  if not lightLevelName or not LobbyLightLogic.LightLevel[lightLevelName] then
    return
  end
  LobbyLightLogic.LoadStreamLevel(false, lightLevelName)
  LobbyLightLogic.LightLevel[lightLevelName] = false
end
function LobbyLightLogic.CloseNoNeedLight()
  for name, isEnable in pairs(LobbyLightLogic.LightLevel) do
    if name ~= LobbyLightLogic.currentLight and isEnable == true then
      LobbyLightLogic.LoadStreamLevel(false, name)
      LobbyLightLogic.LightLevel[name] = false
    end
  end
end
function LobbyLightLogic.LoadStreamLevel(isLoad, levelName, bMakeVisibleAfterLoad, bAync)
  log(bWriteLog and "LobbyLightLogic.LoadStreamLevel isLoad = " .. tostring(isLoad) .. ", levelName = " .. tostring(levelName) .. ", bAync = " .. tostring(bAync))
  if levelName == nil then
    local utility = require("common.utility")
    utility.ErrorMessageHandler("LobbyLightLogic.LoadStreamLevel levelName is nil")
    return
  end
  if bMakeVisibleAfterLoad == nil then
    bMakeVisibleAfterLoad = true
  end
  if LobbyLightLogic.DelayUnLoadTimer[levelName] then
    log(bWriteLog and "LobbyLightLogic cancel Unload " .. tostring(levelName))
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(LobbyLightLogic.DelayUnLoadTimer[levelName])
    LobbyLightLogic.DelayUnLoadTimer[levelName] = nil
  end
  if isLoad == true then
    LobbyLightLogic.DoLoadStreamLevel(levelName, bMakeVisibleAfterLoad, bAync)
  else
    if lastLevelName == levelName then
      lastLevelName = ""
    end
    local level = LobbySceneManager.LobbySceneMgrHelper.GetStreamingLevel(levelName)
    if level then
      level.bShouldBeVisible = false
      local callback = function()
        local CurLightLevelName = LobbyLightLogic.currentLight
        if CurLightLevelName and type(CurLightLevelName) == "string" and levelName == CurLightLevelName then
          print(bWriteLog and "LobbyLightLogic.LoadStreamLevel Same light dont destroy ")
          return
        end
        LobbyLightLogic.DoUnloadStreamLevel(levelName)
      end
      local time_ticker = require("common.time_ticker")
      LobbyLightLogic.DelayUnLoadTimer[levelName] = time_ticker.AddTimerOnce(10, callback)
    end
  end
end
local Blockload = true
function LobbyLightLogic.GMSetForceAsyncLoadLevel()
  Blockload = false
end
function LobbyLightLogic.DoLoadStreamLevel(levelName, bMakeVisibleAfterLoad, bAync)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_PRELOADED, levelName)
  log(bWriteLog and "Laten load level " .. tostring(levelName))
  if levelName == nil or type(levelName) ~= "string" then
    return
  end
  local startTime = getTime()
  lastLevelName = levelName
  local Needblock = Blockload
  if bAync then
    Needblock = false
  end
  local async = require("client.common.async")
  async.Run(function(co)
    loadedLevels[levelName] = 1
    local world = slua_GameFrontendHUD:GetWorld()
    local GameplayStatics = import("GameplayStatics")
    if slua.isValid(world) then
      GameplayStatics.LoadStreamLevel(world, levelName, bMakeVisibleAfterLoad, Needblock)
    end
    LobbyLightLogic.OnLevelLoaded(levelName)
    local endTime = getTime()
    log(bWriteLog and string.format("TimeTracer LobbyLightLogic:LoadStreamLevel finish levelName:%s time:[%.3fms]", levelName, (endTime - startTime) / 1000))
  end)
  DoExtraOnLoadLevel(levelName)
end
function LobbyLightLogic.OnLevelLoaded(levelName)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, levelName)
  local world = slua_GameFrontendHUD:GetWorld()
  LobbySceneManager.LobbySceneMgrHelper.UpdateMPCLightDirection(world)
end
function LobbyLightLogic.SetLastLevelName(levelName)
  lastLevelName = levelName
end
function LobbyLightLogic.DoUnloadStreamLevel(levelName)
  local level = LobbySceneManager.LobbySceneMgrHelper.GetStreamingLevel(levelName)
  if not level then
    return
  end
  if level.bShouldBeVisible == false then
    local async = require("client.common.async")
    async.Run(function(co)
      local world = slua_GameFrontendHUD:GetWorld()
      local GameplayStatics = import("GameplayStatics")
      GameplayStatics.UnloadStreamLevel(world, levelName)
      loadedLevels[levelName] = 0
      if not slua.isValid(world) then
        world = slua_GameFrontendHUD:GetWorld()
      end
      LobbySceneManager.LobbySceneMgrHelper.UpdateMPCLightDirection(world)
      log(bWriteLog and "LobbyLightLogic real unload level:" .. levelName)
    end)
  else
    log(bWriteLog and "LobbyLightLogic unload level but level visible:" .. levelName)
  end
end
function LobbyLightLogic.EnableLobbyMainLight(enableLobbyLight)
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  if frontendUtils then
    frontendUtils:EnableLobbyMainLight(enableLobbyLight)
  end
end
function LobbyLightLogic.GetLastLevelName()
  return lastLevelName
end
function LobbyLightLogic.Clear()
end
function LobbyLightLogic.unloadStreamLevelByMap(levelMap)
  local world = slua_GameFrontendHUD:GetWorld()
  local async = require("client.common.async")
  local GameplayStatics = import("GameplayStatics")
  for _, levelName in pairs(levelMap) do
    async.Run(function(co)
      GameplayStatics.UnloadStreamLevel(world, levelName)
      print(bWriteLog and "Laten unloaded:", levelName)
    end)
  end
  log_shipping_client("LobbySceneManager unloadStreamLevelByMap")
end
function LobbyLightLogic.SetCurLightVisible(bVisible)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  local StringUtil = require("common.string_util")
  local CurLightLevelName = LobbyLightLogic.currentLight
  if not CurLightLevelName or type(CurLightLevelName) ~= "string" then
    return
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    local PackageName = uLevelStreaming:GetWorldAssetPackageFName()
    if StringUtil.Ends(PackageName, CurLightLevelName) then
      print(bWriteLog and "SetCurLightVisible LevelName:" .. CurLightLevelName)
      uLevelStreaming.bShouldBeVisible = bVisible
      return
    end
  end
end
function LobbyLightLogic.SwitchTeamLight()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local bOpen = TeamUpNewSystem.GetTeamNum() == 1
  local SpotLightArr = FuncUtil.GetAllActorsByTag("SpotLight", "TeamClose")
  for k, v in pairs(SpotLightArr) do
    v.SpotLightComponent:SetVisibility(bOpen, false)
  end
end
return LobbyLightLogic