local MainCity = {}
local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
function MainCity:PostInitialize()
  print(bWriteLog and "MainCity:PostInitialize")
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if not MainCityConfig.bOptimization then
    local var = UKismetSystemLibrary.GetConsoleVariableValue("net.LogWriteReadNetObject")
    print(bWriteLog and "MainCity:PostInitialize net.LogWriteReadNetObject start " .. var)
    FuncUtil.UE4ExecuteConsoleCommand("net.LogWriteReadNetObject 1")
    var = UKismetSystemLibrary.GetConsoleVariableValue("net.LogWriteReadNetObject")
    print(bWriteLog and "MainCity:PostInitialize net.LogWriteReadNetObject end " .. var)
  end
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    if not slua.isValid(slua_GameFrontendHUD) then
      print(bWriteLog and "MainCity:PostInitialize slua_GameFrontendHUD invalid")
      return
    end
    slua_GameFrontendHUD:CreateBattleUtils()
    require("GameLua.Mod.BaseMod.Client.BattleHandler")
    local game_params = {}
    game_params.GameID = 10086
    game_params.GameModeID = "26000"
    game_params.bUsedSimulation = true
    print(bWriteLog and "MainCity:PostInitialize SyncGameInfo")
    BattleHandler.SyncGameInfo(game_params)
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameInstance) then
      print(bWriteLog and "MainCity:PostInitialize SetModeID")
      uGameInstance:SetModeID(26000)
    end
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    GameMainConfig.Clear()
    if not MainCityConfig.bOptimization then
      local t1 = slua.getMiliseconds()
      local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
      ClientGameMain.InitCurrentGameConfig()
      local t2 = slua.getMiliseconds()
      print(bWriteLog and "MainCity:PostInitialize InitCurrentGameConfig t = " .. t2 - t1 .. "ms")
    end
    self:LoadLevelWhenReplay()
  end
  if Server then
    print(bWriteLog and "MainCity:PostInitialize Server")
    local sReplayRecover = Server.GetCommandLineValue("REPLAY")
    print(bWriteLog and "MainCity:PostInitialize sReplayRecover " .. tostring(sReplayRecover))
    if sReplayRecover and sReplayRecover ~= "" then
      require("GameLua.GameCore.Main.DSPrepare").ApplyMod()
    end
  end
end
function MainCity:PostDeinitialize()
  print(bWriteLog and "MainCity:PostDeinitialize")
end
function MainCity:PreEnterMainCityBattle()
  print(bWriteLog and "MainCity:PreEnterMainCityBattle")
  if not HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseInGameUIManager", false) then
    ChangeInvalidWorldNameList({
      "Lobby_Main_int"
    })
  end
  print(bWriteLog and "MainCity:PreEnterMainCityBattle ChangeInvalidWorldNameList")
end
function MainCity:PostEnterMainCityBattle()
  print(bWriteLog and "MainCity:PostEnterMainCityBattle try SwitchUIStatus")
  slua_GameFrontendHUD:SwitchUIStatus(GameStatus.Fighting)
  local ClientData = require("GameLua.GameCore.Data.ClientData")
  ClientData._ClearData()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  if GameplayData.ClientGlobalData then
    GameplayData.ClientGlobalData.InitStandAloneEntry()
  end
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_POST_ENTER_BATTLE)
end
function MainCity:PreDestroyAutonomousChar(uChar)
  print(bWriteLog and "MainCity:PreDestroyAutonomousChar")
  if not slua.isValid(uChar) then
    return
  end
  if not uChar.getAvatarComponent2 then
    return
  end
  local uCharacterAvatarComp = uChar:getAvatarComponent2()
  if not slua.isValid(uCharacterAvatarComp) then
    return
  end
end
function MainCity:PostClearActors()
  print(bWriteLog and "MainCity:PostClearActors")
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_POST_CLEAR_ACTOR)
  local MainCity_Client_GameState_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_Client_GameState_Manager")
  local gameState = MainCity_Client_GameState_Manager.GetGameState()
  if gameState and slua.isValid(gameState.Object) then
    print(bWriteLog and "MainCity:PostClearActors 1")
    if self.ResetMainCityGameState then
      print(bWriteLog and "MainCity:PostClearActors 2")
      self:ResetMainCityGameState(gameState.Object)
    end
  end
end
function MainCity:PreShutdownUnrealNetwork()
  print(bWriteLog and "MainCity:PreShutdownUnrealNetwork")
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_UNREAL_NETWORK_SHUTDOWN)
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local game_id = logic_enter_game.cache_game_id
  print(bWriteLog and "MainCity:PreShutdownUnrealNetwork game_id " .. tostring(game_id))
  if GameStatus.IsInLobbyOrMainCity() and game_id and not Lobby_Main_City.IsRecentMainCityGameID(game_id) then
    print(bWriteLog and "MainCity:PreShutdownUnrealNetwork clear waitingEnterBattleStartTime")
    NetUtil.waitingEnterBattleStartTime = 0
  end
end
function MainCity:PostShutdownUnrealNetwork()
  print(bWriteLog and "MainCity:PostShutdownUnrealNetwork")
  if not GameStatus.IsInLobbyOrMainCity() then
    print(bWriteLog and "MainCity:PostShutdownUnrealNetwork 1")
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_MAINCITY_SWAP_ROLE) then
    print(bWriteLog and "MainCity:PostShutdownUnrealNetwork 2")
    return
  end
  local MainCity_Leave_Pawn = require("client.slua.logic.lobby.MainCity.Main.Leave.MainCity_Leave_Pawn")
  MainCity_Leave_Pawn.LeaveMainCity_SwapRole()
end
function MainCity:PostPlayerActorChannelOpen()
  print(bWriteLog and "MainCity:PostPlayerActorChannelOpen, !!!!===>>>InitialCharacterPlayerKey:" .. tostring(Game:GetPlayerKey(self.InitialCharacter)))
  if Game:isValid(self.InitialCharacter) then
  else
    print(bWriteLog and "[Warning]MainCity:PostPlayerActorChannelOpen, InitialCharacter=nil")
  end
  if self.CacheGameid == nil then
  else
    print(bWriteLog and "[Warning]MainCity:PostPlayerActorChannelOpen,!!!!===>>>GameId:" .. tostring(self.CacheGameid))
    if self.InitialCharacter.ResetStatusWhenJumpNewMainCity then
      self.InitialCharacter:ResetStatusWhenJumpNewMainCity()
    else
      print(bWriteLog and "[Warning]MainCity:PostPlayerActorChannelOpen, InitialCharacter.ResetStatusWhenJumpNewMainCity=nil")
    end
  end
  self.CacheGameid = g_game_id
end
function MainCity:LoadLevelWhenReplay()
  print(bWriteLog and "MainCity:LoadLevelWhenReplay")
  if not Client then
    print(bWriteLog and "MainCity:LoadLevelWhenReplay not client")
    return
  end
  if not Client.IsWindows() then
    print(bWriteLog and "MainCity:LoadLevelWhenReplay not windows")
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local uGameInstance = GameplayStatics.GetGameInstance(self)
  if not slua.isValid(uGameInstance) then
    print(bWriteLog and "MainCity:LoadLevelWhenReplay uGameInstance invalid")
    return
  end
  local uGameReplay = uGameInstance:GetCompletePlayback()
  if not slua.isValid(uGameReplay) then
    print(bWriteLog and "MainCity:LoadLevelWhenReplay uGameReplay invalid")
    return
  end
  if not uGameReplay:IsInPlayState() then
    print(bWriteLog and "MainCity:LoadLevelWhenReplay not IsInPlayState")
    return
  end
  local uLevelStreaming = GameplayStatics.GetStreamingLevel(uGameInstance, "MainCityMap")
  if slua.isValid(uLevelStreaming) then
    print(bWriteLog and "MainCity:LoadLevelWhenReplay uLevelStreaming valid")
    uLevelStreaming.bShouldBlockOnLoad = true
    uLevelStreaming.bShouldBeLoaded = true
    uLevelStreaming.bShouldBeVisible = true
    uLevelStreaming.LevelLODIndex = -1
  else
    print(bWriteLog and "MainCity:LoadLevelWhenReplay invalid")
  end
end
local class = require("class")
local object = require("object")
return class(object, nil, MainCity)