local WingmanHelipad = {}
local WingmanSequencePath = "/Game/Library/Res/Actors/WingPlane/SequenceActor/BP_WingmanBornIslandSequenceActor.BP_WingmanBornIslandSequenceActor_C"
local CallWingmanCdTime = 200
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function WingmanHelipad:ctor(selfType)
  self.collisonGroupMap = {}
  self.bHasPlayedSeqOnDS = false
  self.SequenceActor = nil
  self.callWingmanTimeList = {}
  self.canShowInteraciveUI = true
end
function WingmanHelipad:ReceiveBeginPlay()
  WingmanHelipad.__super.ReceiveBeginPlay(self)
  if self:HasAuthority() then
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "ReadyState"
    }, self.HandleEnterReadyState, self)
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.HandleEnterGame, self)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.HandleEnterGame_Client, self)
    self:SetParticles()
  end
end
function WingmanHelipad:ReceiveEndPlay(EndPlayReason)
  WingmanHelipad.__super.ReceiveEndPlay(self, EndPlayReason)
  self:DestroyAllCollison()
end
function WingmanHelipad:HandleEnterReadyState(...)
  print(bWriteLog and "WingmanHelipad:HandleEnterReadyState")
  local GameplayStatics = import("GameplayStatics")
  local uGameState = GameplayStatics.GetGameState(self)
  local EGameModeType = import("EGameModeType")
  if not slua.isValid(uGameState) then
    print(bWriteLog and "WingmanHelipad:HandleEnterReadyState GameState Not Valid")
    return
  end
  if uGameState.GameModeType == EGameModeType.ESocialIsland then
    print(bWriteLog and "WingmanHelipad:HandleEnterReadyState GameState ESocialIsland")
    return
  end
  local interactiveComponent = self:GetInteractiveComponent()
  local GameMode = GameplayStatics.GetGameMode(self)
  if not slua.isValid(GameMode) or not slua.isValid(GameMode.ShowVehicle) then
    print(bWriteLog and "WingmanHelipad:HandleEnterReadyState invalid ShowVehicle")
    if slua.isValid(interactiveComponent) then
      interactiveComponent:SetEnable(false)
    end
    return
  end
  if slua.isValid(interactiveComponent) then
    interactiveComponent:SetEnable(true)
  end
  local CollisonSpawnInfo = self:GetWingmanCollisonSpawnInfo()
  if not CollisonSpawnInfo then
    print(bWriteLog and "WingmanHelipad:HandleEnterReadyState collisonClass CollisonSpawnInfo")
    return
  end
  local GameMode = GameplayStatics.GetGameMode(self)
  local uBRReadyStateGroupComponent = GameMode:GetComponentByClass(import("BRReadyStateGroupComponent"))
  if not uBRReadyStateGroupComponent then
    print(bWriteLog and "WingmanHelipad:HandleEnterReadyState uBRReadyStateGroupComponent invalid")
    return
  end
  local worldIds = uBRReadyStateGroupComponent:GetParallelWorldIds()
  local world = GameMode:GetWorld()
  local spawnRot = FRotator(0, 0, 0)
  local collisonClass = import(CollisonSpawnInfo.classPath)
  if not collisonClass then
    print(bWriteLog and "WingmanHelipad:HandleEnterReadyState collisonClass invalid")
    return
  end
  for i = 0, worldIds:Num() - 1 do
    local groupId = worldIds:Get(i)
    if groupId and not slua.isValid(self.collisonGroupMap[groupId]) then
      local WingmanCollison = world:SpawnActor(collisonClass, CollisonSpawnInfo.spawnLoc, spawnRot, nil)
      if WingmanCollison then
        print(bWriteLog and "WingmanHelipad:HandleEnterReadyState Spawn WingmanCollison groupId:" .. tostring(groupId))
        WingmanCollison:SetParallelWorldId(groupId, 0)
        self.collisonGroupMap[groupId] = WingmanCollison
      end
    end
  end
end
function WingmanHelipad:HandleEnterGame(...)
  print(bWriteLog and "WingmanHelipad:HandleEnterGame")
  local GameplayStatics = import("GameplayStatics")
  local GameState = GameplayStatics.GetGameState(self)
  local EGameModeType = import("EGameModeType")
  if not slua.isValid(GameState) then
    print(bWriteLog and "WingmanHelipad:HandleEnterGame GameState Not Valid")
    return
  end
  self:DestroyAllCollison()
  local interactiveComponent = self:GetInteractiveComponent()
  if slua.isValid(interactiveComponent) then
    interactiveComponent:SetEnable(false)
  end
end
function WingmanHelipad:HandleEnterGame_Client(...)
  print(bWriteLog and "WingmanHelipad:HandleEnterGame_Client")
  if slua.isValid(self.Object) and slua.isValid(self.Object.ParticleSystem) then
    self.Object.ParticleSystem:SetActive(false, false)
  end
end
function WingmanHelipad:ShowUI(component)
  if not Client then
    return
  end
  if not self.canShowInteraciveUI then
    print(bWriteLog and "WingmanHelipad:ShowUI canShowInteraciveUI false")
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local uGameState = GameplayStatics.GetGameState(self)
  if not slua.isValid(uGameState) then
    print(bWriteLog and "WingmanHelipad:ShowUI GameState invalid")
    return
  end
  if uGameState.GetGameModeState then
    local GameModeState = uGameState:GetGameModeState() or ""
    if GameModeState ~= "ReadyState" then
      print(bWriteLog and "WingmanHelipad:ShowUI not in ReadyState")
      return
    end
  end
  WingmanHelipad.__super.ShowUI(self, component)
end
function WingmanHelipad:MustCheckResultAfterServerClick(Character, Ret, Component)
  print(bWriteLog and "WingmanHelipad:MustCheckResultAfterServerClick, result = " .. tostring(Ret))
  Component = Component or self:GetInteractiveComponent()
  if Ret and slua.isValid(Component) and slua.isValid(Character) then
    if self:IsGameStateBan() then
      print(bWriteLog and "WingmanHelipad:MustCheckResultAfterServerClick, GameState in fight")
      return
    end
    if not self:CheckCanCallWingman(Character) then
      Game:UIShowTips(Character.PlayerKey, 80050)
      return
    end
    if self:TryCallWingman(Character) then
      self.CallerPlayerKey = Character.PlayerKey
    else
    end
  end
end
function WingmanHelipad:OnClientClickInteractiveButton(Character)
  if not self:CheckCanCallWingman(Character) then
    print(bWriteLog and "WingmanHelipad:OnClientClickInteractiveButton Tips")
    IngameTipsTools.BattleNormalTipsByTextID(80050)
    return false
  end
  return true
end
function WingmanHelipad:TryCallWingman(Character)
  if not self:HasAuthority() then
    print(bWriteLog and "WingmanHelipad:TryCallWingman HasAuthority false")
    return false
  end
  if not slua.isValid(Character) then
    print(bWriteLog and "WingmanHelipad:TryCallWingman invalid Character")
    return false
  end
  local UGameplayStatics = import("GameplayStatics")
  local GameMode = UGameplayStatics.GetGameMode(self)
  if not slua.isValid(GameMode) or not slua.isValid(GameMode.ShowVehicle) then
    print(bWriteLog and "WingmanHelipad:TryCallWingman invalid ShowVehicle")
    return false
  end
  local groupId = Character:GetParallelWorldId()
  if not groupId then
    print(bWriteLog and "WingmanHelipad:TryCallWingman no groupId")
    return false
  end
  print(bWriteLog and "WingmanHelipad:TryCallWingman groupId:" .. tostring(groupId))
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if GameMode.ShowVehicle.WingmanMap and GameMode.ShowVehicle.WingmanMap:Get(groupId) then
    print(bWriteLog and "WingmanHelipad:TryCallWingman has called ")
    local leftCdTime = CallWingmanCdTime
    if self.callWingmanTimeList[groupId] and self.callWingmanTimeList[groupId] > 0 then
      local nCurTime = math.floor(GamePlayTools.GetServerWorldTimeSeconds())
      leftCdTime = CallWingmanCdTime + self.callWingmanTimeList[groupId] - nCurTime
    end
    IngameTipsTools.BattleNormalSAPTipsByTextID(80051, leftCdTime, "", "", Character.PlayerKey, false)
    return false
  end
  local wingmanInfo = self:GetWingmanInfoInBornIsland()
  if not wingmanInfo or not next(wingmanInfo) then
    print(bWriteLog and "WingmanHelipad:TryCallWingman invalid wingmanInfo")
    return false
  end
  GameMode.ShowVehicle:ShowWingmanFor(tonumber(Character.PlayerKey), wingmanInfo.classPath, wingmanInfo.spawnTransform)
  local wingmanActor = GameMode.ShowVehicle.WingmanMap:Get(groupId)
  if wingmanActor then
    self.callWingmanTimeList[groupId] = math.floor(GamePlayTools.GetServerWorldTimeSeconds())
    local wingmanCollisonActor = self.collisonGroupMap and self.collisonGroupMap[groupId]
    if slua.isValid(wingmanCollisonActor) then
      wingmanActor:SetCurGroupCollison(wingmanCollisonActor)
    end
    if wingmanActor.ModifyWingmanCallerInfo then
      wingmanActor:ModifyWingmanCallerInfo(Character)
    end
    if wingmanActor.ChangeVehicleAvatar then
      wingmanActor:ChangeVehicleAvatar(Character:GetController())
    end
  end
  print(bWriteLog and "WingmanHelipad:TryCallWingman ShowWingmanFor", tonumber(Character.PlayerKey), wingmanInfo.classPath)
  return true
end
function WingmanHelipad:DestroyAllCollison()
  print(bWriteLog and "WingmanHelipad:DestroyAllCollison")
  if not self.collisonGroupMap or not next(self.collisonGroupMap) then
    print(bWriteLog and "WingmanHelipad:DestroyAllCollison no collison")
    return
  end
  for _, collisonActor in pairs(self.collisonGroupMap) do
    if slua.isValid(collisonActor) then
      collisonActor:K2_DestroyActor()
    end
  end
  self.collisonGroupMap = {}
end
function WingmanHelipad:IsGameStateBan()
  local UGameplayStatics = import("GameplayStatics")
  local GameState = UGameplayStatics.GetGameState(self.Object)
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) and GameState.GetGameModeState then
    local GameModeState = GameState:GetGameModeState() or ""
    if GameModeState ~= "ReadyState" and GameState.GameModeType ~= EGameModeType.ESocialIsland then
      return true
    end
  end
  return false
end
function WingmanHelipad:CheckCanCallWingman(Character)
  print(bWriteLog and "WingmanHelipad:CheckCanCallWingman")
  if CGame:IsEditor() then
    return true
  end
  if not slua.isValid(Character) then
    print(bWriteLog and "WingmanHelipad:CheckCanCallWingman. Character is not Valid")
    return false
  end
  if Client then
    local controller = Character:GetPlayerControllerSafety()
    if not slua.isValid(controller) then
      print(bWriteLog and "WingmanHelipad:CheckCanCallWingman. Character is not Valid")
      return false
    end
    local CurrentIndex = controller.RolewearIndex
    if CurrentIndex and controller.InitialKnapsackExtInfo then
      local Size = controller.InitialKnapsackExtInfo:Num()
      print(bWriteLog and "WingmanHelipad:CanDrive Size = " .. tostring(Size) .. ", CurrentIndex = " .. CurrentIndex)
      if CurrentIndex < Size then
        local WearData = controller.InitialKnapsackExtInfo:Get(CurrentIndex)
        if WearData and WearData.KnapsackExtInfo then
          local skin = WearData.KnapsackExtInfo.WingmanSkin
          print(bWriteLog and "WingmanHelipad:CanDrive skin" .. tostring(skin))
          if self:CheckWingmanSkinQuality(skin) then
            return true
          end
        end
      end
    end
    return false
  end
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  if not Character.PlayerState then
    print(bWriteLog and "Character.PlayerState is nil")
    return false
  end
  local playerInfo = ServerPlayerDataMgr.GetPlayerInfo(tonumber(Character.PlayerState.UID))
  if not playerInfo then
    print(bWriteLog and "WingmanHelipad:CanDrive. playerInfo is nil ")
    return false
  end
  if playerInfo.all_knapsack_ext_info and playerInfo.use_rolewear and playerInfo.all_knapsack_ext_info[playerInfo.use_rolewear] then
    local wingman_skin = playerInfo.all_knapsack_ext_info[playerInfo.use_rolewear].wingman_skin
    print(bWriteLog and "WingmanHelipad:CanDrive. wingman_skin = " .. tostring(wingman_skin))
    if self:CheckWingmanSkinQuality(wingman_skin) then
      return true
    end
  end
  return false
end
function WingmanHelipad:CheckWingmanSkinQuality(itemID)
  if itemID == nil or itemID == 0 then
    return false
  end
  local itemData = CDataTable.GetTableData("Item", itemID)
  if not itemData then
    return false
  end
  if itemData.ItemQuality < 6 then
    return false
  end
  return true
end
function WingmanHelipad:GetWingmanInfoInBornIsland()
  local UKismetMathLibrary = import("KismetMathLibrary")
  local wingmanOffsetZ = 90
  local HelipadLocation = self:K2_GetActorLocation()
  local wingmanSpawnTranslation = FVector(HelipadLocation.X, HelipadLocation.Y, HelipadLocation.Z + wingmanOffsetZ)
  local wingmanInfo = {
    classPath = "/Game/Arts_PlayerBluePrints/Vehicle/WingMan/wing_Vehicle_BornIsland.wing_Vehicle_BornIsland_C",
    spawnTransform = UKismetMathLibrary.MakeTransform(wingmanSpawnTranslation, FRotator(0, 0, 0), FVector(1, 1, 1))
  }
  return wingmanInfo
end
function WingmanHelipad:GetWingmanCollisonSpawnInfo()
  local wingmanSpawnTranslation = self:K2_GetActorLocation()
  local wingmanInfo = {
    classPath = "/Game/Library/Res/Actors/WingPlane/Wingman_Collison_BornIsland.Wingman_Collison_BornIsland_C",
    spawnLoc = wingmanSpawnTranslation
  }
  return wingmanInfo
end
function WingmanHelipad:PlayWingmanSequenceOnDS()
  if not self:HasAuthority() then
    return
  end
  log(bWriteLog and "WingmanHelipad:PlayWingmanSequenceOnDS")
  if self.bHasPlayedSeqOnDS then
    log(bWriteLog and "WingmanHelipad:PlayWingmanSequenceOnDS bHasPlayedSeqOnDS is true")
    return
  end
  self.bHasPlayedSeqOnDS = true
  local wingmanHelipadLocation = self:K2_GetActorLocation()
  local SequenceTransform = FTransform()
  SequenceTransform:SetLocation(wingmanHelipadLocation)
  self.SequenceActor = Game:PlayLevelSequence(self, "", SequenceTransform, WingmanSequencePath, false)
  if not slua.isValid(self.SequenceActor) then
    log(bWriteLog and "WingmanHelipad:PlayWingmanSequenceOnDS invalid SequenceActor")
    return
  end
  if self.SequenceActor.BindSequenceActor then
    log(bWriteLog and "WingmanHelipad:PlayWingmanSequenceOnDS BindSequenceActor")
    self.SequenceActor:BindSequenceActor(self.Object)
    self.SequenceActor:K2_SetActorRotation(FRotator(0, 0, 0), false)
  end
  self.SequenceActor:Play(0.0)
end
function WingmanHelipad:SetParticles()
  if self:HasAuthority() then
    return
  end
  if not self:CheckIsReadyState() then
    log(bWriteLog and "WingmanHelipad:SetParticles GetGameModeState not ReadyState")
    return
  end
  local EffectPath = "/Game/Mod/EvoBase/Arts_Effect/ParticleSystems/P_Wingplane_02.P_Wingplane_02"
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(EffectPath, function(uEffect)
    print(bWriteLog and "WingmanHelipad:SetParticles callback")
    if not self:CheckIsReadyState() then
      log(bWriteLog and "WingmanHelipad:SetParticles GetGameModeState not ReadyState 2")
      return
    end
    if slua.isValid(self.Object) then
      local particleSystem = self.Object.ParticleSystem
      if uEffect and slua.isValid(particleSystem) then
        particleSystem:SetTemplate(uEffect)
        particleSystem:SetActive(true, false)
      end
    end
  end)
end
function WingmanHelipad:CheckIsReadyState()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.GetGameModeState then
    log(bWriteLog and "WingmanHelipad:CheckIsReadyState GetGameModeState no uGameState")
    return false
  end
  local CurGameState = uGameState:GetGameModeState()
  if CurGameState ~= "ReadyState" and CurGameState ~= "ActiveState" then
    log(bWriteLog and "WingmanHelipad:CheckIsReadyState GetGameModeState not ReadyState")
    return false
  end
  return true
end
function WingmanHelipad:SetIfShowInteractiveUI_Client(bShow)
  if self:HasAuthority() then
    return
  end
  print(bWriteLog and "WingmanHelipad:SetIfShowInteractiveUI_Client bShow" .. tostring(bShow))
  bShow = bShow or false
  self.canShowInteraciveUI = bShow
  if not bShow then
    self:CloseUI()
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local CWingmanHelipad = class(CActorBase, nil, WingmanHelipad)
return CWingmanHelipad