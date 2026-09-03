local StringUtil = require("common.string_util")
local BRGameStateBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {
    MulticastRPC_CheckAndUpdateModeState = {
      Reliable = true,
      Params = {
        UEnums.EPropertyClass.Str
      }
    }
  }
}
BRGameStateBase.MulticastRPC.RPC_UpdateAlivePlayerNum = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function BRGameStateBase:RPC_UpdateAlivePlayerNum(AlivePlayerNum)
  if Client then
    if AlivePlayerNum ~= 0 and self.AlivePlayerNum ~= AlivePlayerNum then
      local bNeedReset = false
      local CurState = self:GetGameModeState()
      if CurState == "ActiveState" or CurState == "ReadyState" then
        if AlivePlayerNum > self.AlivePlayerNum then
          bNeedReset = true
        end
      elseif (CurState == "FightingState" or CurState == "FinishedState") and AlivePlayerNum < self.AlivePlayerNum then
        bNeedReset = true
      end
      if bNeedReset then
        print(bWriteLog and "BRGameStateBase:RPC_UpdateAlivePlayerNum, Change " .. tostring(self.AlivePlayerNum) .. " to " .. tostring(AlivePlayerNum))
        self.        self:OnRep_AlivePlayerNum()
      else
        print(bWriteLog and "BRGameStateBase:RPC_UpdateAlivePlayerNum, Num = " .. tostring(AlivePlayerNum) .. ", but bNeedReset = false")
      end
    else
      print(bWriteLog and "BRGameStateBase:RPC_UpdateAlivePlayerNum, Equal to " .. tostring(AlivePlayerNum))
    end
  end
end
function BRGameStateBase:ctor()
  self.bHasSetReadyState = false
  self.bHasSetFightingState = false
end
function BRGameStateBase:_PostConstruct()
  BRGameStateBase.__super._PostConstruct(self)
  if Client then
    self:AddControlEvent(self, "OnDSSwitchChanged", self.HandleOnDSSwitchChanged, self)
  end
end
function BRGameStateBase:ReceiveBeginPlay()
  BRGameStateBase.__super.ReceiveBeginPlay(self)
  self:CreateMyLandScape()
  if Client then
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.HandleEnterGameModeFightingState, self)
    self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.HandleOnBattleResult, self)
    self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_RETURN_TO_LOBBY, self.HandleOnReturnToLobby, self)
  else
    if self.OnPlayerNumChange then
      self:AddControlEvent(self.Object, "OnPlayerNumChange", self.OnHandlePlayerNumChanged, self)
    else
      print(bWriteLog and "BRGameStateBase:ReceiveBeginPlay, have no OnPlayerNumChange delegate")
    end
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_INIT, self.PostGameModeInit, self)
  end
end
function BRGameStateBase:OnHandlePlayerNumChanged()
  print(bWriteLog and "BRGameStateBase:OnHandlePlayerNumChanged, Num = " .. tostring(self.AlivePlayerNum))
  self:RPC_UpdateAlivePlayerNum(self.AlivePlayerNum)
end
function BRGameStateBase:ReceiveEndPlay(EndPlayReason)
  self:DestroyMyLandScape()
  BRGameStateBase.__super.ReceiveEndPlay(self, EndPlayReason)
end
function BRGameStateBase:CreateMyLandScape()
  if Client and slua.isValid(CGameWorld) then
    local uLeveScriptActor = CGameWorld.PersistentLevel.LevelScriptActor
    if slua.isValid(uLeveScriptActor) then
      if self.OverrideLevelScriptActorContent ~= nil then
        self:OverrideLevelScriptActorContent(uLeveScriptActor)
      end
      if uLeveScriptActor.MatSoftObj ~= nil or uLeveScriptActor.GeoSoftObj ~= nil then
        local UGameplayStatics = import("GameplayStatics")
        local uMyLandscapeCls = import("/Script/ShadowTrackerExtra.MyLandscape")
        local uMyLandscapeArray = UGameplayStatics.GetAllActorsOfClass(self.Object, uMyLandscapeCls, slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")))
        if uMyLandscapeArray:Num() <= 0 then
          local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
          self.bSpawnedMyLandScape = USTExtraBlueprintFunctionLibrary.CreateMyLandscapeBySoftRef(self, uLeveScriptActor.MatSoftObj, uLeveScriptActor.GeoSoftObj, uLeveScriptActor.HoleGeoSoftObj, uLeveScriptActor.LowDeviceGeoSoftObj, uLeveScriptActor.ExtendDataGeoSoftObj, uLeveScriptActor.GeoSoftObjNew)
        end
      end
    end
  end
end
function BRGameStateBase:DestroyMyLandScape()
  if Client then
    local UGameplayStatics = import("GameplayStatics")
    local uMyLandscapeCls = import("/Script/ShadowTrackerExtra.MyLandscape")
    local uMyLandscapeArray = UGameplayStatics.GetAllActorsOfClass(self.Object, uMyLandscapeCls, slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")))
    for _, uMyLandscape in pairs(uMyLandscapeArray) do
      if slua.isValid(uMyLandscape) then
        uMyLandscape:K2_DestroyActor()
      end
    end
  end
end
function BRGameStateBase:HandleEnterGameModeFightingState()
  if not Client then
    return
  end
  print(bWriteLog and "BRGameStateBase:HandleEnterGameModeFightingState")
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  print(bWriteLog and "BRGameStateBase:HandleEnterGameModeFightingState ModNameEnterBattle: " .. logic_enter_game.ModNameEnterBattle)
  Client.SyncLoadPackageUpdateCurrentWorldStage(logic_enter_game.ModNameEnterBattle .. "_StartCollect")
end
function BRGameStateBase:HandleOnReturnToLobby()
  print(bWriteLog and "BRGameStateBase:HandleOnReturnToLobby")
  Client.SyncLoadPackageUpdateCurrentWorldStage("")
  Client.SyncLoadPackageUpdateCurrentWorldName("")
end
function BRGameStateBase:HandleOnBattleResult()
  if not Client then
    return
  end
  print(bWriteLog and "BRGameStateBase:HandleOnBattleResult")
  Client.SyncLoadPackageUpdateCurrentWorldStage("")
  Client.SyncLoadPackageUpdateCurrentWorldName("")
end
function BRGameStateBase:HandleOnDSSwitchChanged()
  print(bWriteLog and "BRGameStateBase:HandleOnDSSwitchChanged")
  EventSystem:postEvent(EVENTTYPE_GAMESTATE, EVENTID_GAMESTATE_DSSWITCHCHANGED)
end
function BRGameStateBase:CheckIsBROrTPlanMode()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeID = GameMainConfig.GetModeID()
  local bBRMode = GamePlayTools.IsBRMode(ModeID)
  local GameModeType, _ = GameMainConfig.GetModType()
  if bBRMode or GameModeType == "TPlan" or StringUtil.StrFind(GameModeType, "TPlan") then
    return true
  end
  return false
end
function BRGameStateBase:OnGameModeStateChange(_, __, sState)
  BRGameStateBase.__super.OnGameModeStateChange(self, _, __, sState)
  if not self:CheckIsBROrTPlanMode() then
    return
  end
  print(bWriteLog and "BRGameStateBase:HandleDSEnterGameModeState")
  if sState == "ReadyState" then
    self:AddGameTimer(15, false, function()
      self:MulticastRPC_CheckAndUpdateModeState("ReadyState")
    end)
  elseif sState == "FightingState" then
    self:AddGameTimer(5, false, function()
      self:MulticastRPC_CheckAndUpdateModeState("FightingState")
    end)
  end
end
function BRGameStateBase:MulticastRPC_CheckAndUpdateModeState(sState)
  if Client then
    print(bWriteLog and "BRGameStateBase:MulticastRPC_CheckAndUpdateModeState")
    local sCurState = self:GetGameModeState()
    print(bWriteLog and "BRGameStateBase:MulticastRPC_CheckAndUpdateModeState: ClientState:" .. tostring(sCurState) .. " DSState: " .. tostring(sState))
    if sState == "ReadyState" then
      if sCurState == "ActiveState" then
        self:SetGameModeState("ReadyState")
        self:OnRep_GameModeState()
        self:ReportGameModeStateError(sCurState, sState)
      end
    elseif sState == "FightingState" then
      local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
      if slua.isValid(uPlayerController) and not uPlayerController.CheckBattleHasBeginPlay then
        return
      end
      if slua.isValid(uPlayerController) and not uPlayerController:CheckBattleHasBeginPlay() then
        return
      end
      if sCurState == "ActiveState" or sCurState == "ReadyState" then
        self:SetGameModeState("FightingState")
        self:OnRep_GameModeState()
        self:ReportGameModeStateError(sCurState, sState)
      end
    end
  end
end
function BRGameStateBase:OnRep_GameModeState()
  if Client then
    local sCurState = self:GetGameModeState()
    if self:CheckIsBROrTPlanMode() and (sCurState == "ReadyState" or sCurState == "FightingState") then
      if sCurState == "ReadyState" and not self.bHasSetReadyState then
        self.bHasSetReadyState = true
        self.Super:OnRep_GameModeState()
      elseif sCurState == "FightingState" and not self.bHasSetFightingState then
        self.bHasSetFightingState = true
        self.Super:OnRep_GameModeState()
      end
    else
      self.Super:OnRep_GameModeState()
    end
    print(bWriteLog and "BRGameStateBase:OnRep_GameModeState ModeState = " .. tostring(sCurState))
  end
end
function BRGameStateBase:ReportGameModeStateError(sCurState, sState)
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  local CrashKitReportString = string.format("ClientState:%s, DSState:%s", tostring(sCurState), tostring(sState))
  local bResult = GameReportUtils.BugglyPostExceptionFull("ClientGameModeStateError", CrashKitReportString, Client.IsEditor() or Client.IsDevelopment())
  if bResult and (Client.IsEditor() or Client.IsDevelopment()) then
    print(bWriteLog and "BRGameStateBase:ReportGameModeStateError: ClientState:" .. tostring(sCurState) .. " DSState: " .. tostring(sState))
  end
end
function BRGameStateBase:OnRep_FlightInfoList()
  print(bWriteLog and "BRGameStateBase:OnRep_FlightInfoList")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local MyPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(MyPlayerController) and self.FlightInfoList and self.FlightInfoList:Num() > 0 then
    if not MyPlayerController.IsObserver or not MyPlayerController:IsObserver() then
      local FlightAmount = self.FlightInfoList:Num()
      local MyFlightNo = MyPlayerController.TeamID % FlightAmount
      if MyFlightNo == 0 then
        MyFlightNo = FlightAmount
      end
      print(bWriteLog and string.format("BRGameStateBase:OnRep_FlightInfoList FlightAmount is %d", FlightAmount))
      for CurrrentIndex, OneFlightInfo in pairs(self.FlightInfoList) do
        if MyFlightNo ~= OneFlightInfo.FlightNo then
          EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SECONDE_AIRLINE_INFO, OneFlightInfo)
          break
        end
      end
    else
      print(bWriteLog and "BRGameStateBase:OnRep_FlightInfoList IsSpectatorOrDemoPlayer")
      local bHasPlane = false
      for CurrrentIndex, OneFlightInfo in pairs(self.FlightInfoList) do
        if OneFlightInfo and OneFlightInfo.Plane and slua.isValid(OneFlightInfo.Plane) then
          bHasPlane = true
          break
        end
      end
      if bHasPlane then
        MyPlayerController:BroadcastUIMessage("OnViewThePlane", 0, "", "")
      else
        MyPlayerController:BroadcastUIMessage("OnNotViewThePlane", 0, "", "")
      end
    end
  end
end
function BRGameStateBase:PostGameModeInit()
  print(bWriteLog and "BRGameStateBase:PostGameModeInit")
  if not Client and slua.isValid(self.GlobalPickupManagerComponent) then
    self.GlobalPickupManagerComponent:AddItemGeneratorDelegate()
  end
end
local class = require("class")
local CGameStateBase = require("GameLua.GameCore.Framework.GameStateBase")
local CBRGameStateBase = class(CGameStateBase, nil, BRGameStateBase)
return require("combine_class").DeclareFeature(CBRGameStateBase, {
  {
    StoreFeature = "GameLua.Mod.BaseMod.Gameplay.Store.BRGameStateStoreFeature"
  },
  {
    BlazingFeature = "GameLua.Mod.BRMod.Gameplay.Feature.Blazing.GameStateBlazingFeature"
  }
}, "BRGameStateBase")