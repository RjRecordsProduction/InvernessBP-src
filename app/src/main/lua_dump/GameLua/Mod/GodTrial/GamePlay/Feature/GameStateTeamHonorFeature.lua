local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
local GodTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.GodTrialConfig")
local STExtraPlayerState = import("/Script/ShadowTrackerExtra.STExtraPlayerState")
local TableUtil = require("common.table_util")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ECollisionChannel = import("ECollisionChannel")
local GameStateTeamHonorFeature = {
  LuaEventContainer = {
    "OnRep_TeamTotalScoreList",
    "OnRep_bDungeonLevelVisible"
  }
}
function GameStateTeamHonorFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "TeamTotalScoreList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      import("/Script/CoreUObject.Vector2D")
    },
    {
      "TeamGoldenCoinList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      import("/Script/CoreUObject.Vector2D")
    },
    {
      "ArenaAreaCloseTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "BoseAreaCloseTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "ArenaFinalPos",
      ELifetimeCondition.COND_None,
      import("/Script/CoreUObject.Vector")
    },
    {
      "bDungeonLevelVisible",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "ArenaBeginTeleportServerTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
  return RepTable
end
function GameStateTeamHonorFeature:_PostConstruct()
  GameStateTeamHonorFeature.__super._PostConstruct(self)
  self.MapConfig = {}
  self.Config = {}
  self.ArenaMinimumScore = 0
  self.ArenaChoosenTeamNum = 4
  self.SummonLightActorList = {}
  self.SummonLightMarkInstIDsMap = {}
  self.ArenaInitialPos = nil
  self.ArenaFinalPos = FVector(0, 0, 0)
  self.bDungeonLevelVisible = false
  self.FakeIslandActor = nil
  self.ChoosenTeamList = {}
  self.ArenaAreaCloseTime = 0
  self.BoseAreaCloseTime = 0
  self.HiredCentaurTeamID = -1
  self.HiredCentaurPlayerKey = -1
  self.SinglePlayerStateList = slua.Map(UEnums.EPropertyClass.Int, UEnums.EPropertyClass.Object, UEnums.EPropertyClass.Int, STExtraPlayerState)
  if self:HasAuthority() then
    self.TeamHonorDataList = {}
    if not self.TeamTotalScoreList then
      self.TeamTotalScoreList = slua.Array(FVector2D)
    end
  end
end
function GameStateTeamHonorFeature:ReceiveBeginPlay()
  GameStateTeamHonorFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "GameStateTeamHonorFeature:ReceiveBeginPlay")
  self:InitConfig()
  if not self.MapConfig or not self.MapConfig.ArenaBeginTeleportTime then
    print(bWriteLog and "GameStateTeamHonorFeature:ReceiveBeginPlay - MapConfig not found")
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICTILE_CREATE, self._OnDungeonTileCreated, self)
  if self:HasAuthority() then
    self.TeamHonorDataList = {}
    if not self.TeamTotalScoreList then
      self.TeamTotalScoreList = slua.Array(FVector2D)
    end
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChange, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_CHAR_KILL, self.OnPlayerKill, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_ADD_KILLS, self.HandleOnAddKill, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_DIED_ASSIST, self.OnPlayerAssist, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_RESCUE, self.OnPlayerRescue, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVE_COMMON_SUCCESS_NUM, self.OnReviveCommonSuccessNum, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYERSETTLEMENT_START, self.OnPlayerSettlementStart, self)
    self:AddCommonEvent(EVENTTYPE_GODTRIAL_NORMAL, EVENTIT_SERVER_THE_DESCENDED_SKY, self.OnTheDescendedSky, self)
    self:AddCommonEvent(EVENTTYPE_GODTRIAL_NORMAL, EVENTIT_SERVER_THE_DESCENDED_SKY_END, self.OnTheDescendedSkyEnd, self)
  end
end
function GameStateTeamHonorFeature:InitConfig()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType == "Neon" then
    print(bWriteLog and "GameStateTeamHonorFeature:InitConfig - MapType=Neon")
    return
  end
  self.MapConfig = GodTrialConfig.GetMapConfig(MapType)
  if not self.MapConfig then
    print(bWriteLog and "GameStateTeamHonorFeature:InitConfig - MapConfig not found")
    return
  end
  local PlayerNumPerTeam = CGameState.PlayerNumPerTeam or 4
  self.ArenaMinimumScore = self.MapConfig.ArenaMinimumScore and self.MapConfig.ArenaMinimumScore[PlayerNumPerTeam] or 0
  self.ArenaChoosenTeamNum = self.MapConfig.ArenaChoosenTeamNum and self.MapConfig.ArenaChoosenTeamNum[PlayerNumPerTeam] or 4
  print(bWriteLog and string.format("GameStateTeamHonorFeature:InitConfig - ArenaMinimumScore=%s ArenaChoosenTeamNum= %s", self.ArenaMinimumScore, self.ArenaChoosenTeamNum))
  if CGameMode and CGameMode.DungeonFeature then
    CGameMode.DungeonFeature.MapConfig = self.MapConfig
  end
end
function GameStateTeamHonorFeature:_OnDungeonTileCreated(_, __, DynamicTileActor)
  if not slua.isValid(DynamicTileActor) then
    return
  end
  local DungeonLevelPaths = GodTrialConfig.DUNGEON_LEVEL_PATHS
  local LevelPathToLoadList = DynamicTileActor.LevelPathToLoadList
  if not LevelPathToLoadList or LevelPathToLoadList:Num() == 0 then
    return
  end
  local bIsDungeonTile = false
  for _, DungeonPath in pairs(DungeonLevelPaths) do
    for _, LoadedPath in pairs(LevelPathToLoadList) do
      if LoadedPath == DungeonPath then
        bIsDungeonTile = true
        break
      end
    end
    if bIsDungeonTile then
      break
    end
  end
  if not bIsDungeonTile then
    return
  end
  if self.bDungeonLevelVisible then
    return
  end
  self:SetDungeonLevelVisible(false)
end
function GameStateTeamHonorFeature:OnRep_bDungeonLevelVisible()
  if not self.bDungeonLevelVisible then
    return
  end
  print(bWriteLog and string.format("GameStateTeamHonorFeature:OnRep_bDungeonLevelVisible - enabling dungeon levels on client"))
  self:SetDungeonLevelVisible(true)
end
function GameStateTeamHonorFeature:SetDungeonLevelVisible(bVisible)
  local DungeonLevelPaths = GodTrialConfig.DUNGEON_LEVEL_PATHS
  local ELevelDisableReason = import("ELevelDisableReason")
  local uWorld = CGameWorld
  local bDisable = not bVisible
  if not slua.isValid(uWorld) then
    return
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return
  end
  for _, LevelPath in pairs(DungeonLevelPaths) do
    local uLevelStreaming = uWorldComposition:GetDynamicTile(LevelPath)
    if slua.isValid(uLevelStreaming) then
      uLevelStreaming:SetDisableByReason(ELevelDisableReason.GameLogic, bDisable)
      print(bWriteLog and string.format("GameStateTeamHonorFeature:_OnDungeonTileCreated - disabled immediately: %s", LevelPath))
    end
  end
end
function GameStateTeamHonorFeature:AddPlayerHonorScore(uPlayerState, HonorType, Score)
  if not slua.isValid(uPlayerState) then
    return
  end
  if not uPlayerState.PlayerStateHonorFeature then
    return
  end
  uPlayerState.PlayerStateHonorFeature:AddScore(HonorType, Score)
  print(bWriteLog and string.format("GameStateTeamHonorFeature:AddPlayerHonorScore - PlayerKey=%s, HonorType=%s, Score=%s", uPlayerState.PlayerKey, HonorType, Score))
end
function GameStateTeamHonorFeature:HandleOnAddKill(_, _, uKillerPS, uVictimPawn)
  if not self.MapConfig then
    return
  end
  local Score = self.MapConfig.HonorScoreKill
  if not Score or Score <= 0 then
    return
  end
  if not slua.isValid(uKillerPS) then
    return
  end
  local uKillerCharacter = uKillerPS:GetPlayerCharacter()
  if not slua.isValid(uKillerCharacter) then
    return
  end
  if slua.isValid(uVictimPawn) then
    local VictimPS = uVictimPawn:GetPlayerStateSafety()
    if slua.isValid(VictimPS) and VictimPS.TeamID == uKillerPS.TeamID then
      return
    end
  end
  if uKillerCharacter.GetOwner and uKillerCharacter.GetMasterPlayerState then
    local uMasterPlayerState = uKillerCharacter:GetMasterPlayerState()
    if slua.isValid(uMasterPlayerState) then
      self:AddPlayerHonorScore(uMasterPlayerState, Enum.EHonorType.Kill, Score)
    end
  end
end
function GameStateTeamHonorFeature:OnPlayerKill(_, __, uKillerPlayerState, uVictimPawn)
  if not self.MapConfig then
    return
  end
  local Score = self.MapConfig.HonorScoreKill
  if not Score or Score <= 0 then
    return
  end
  if not slua.isValid(uKillerPlayerState) then
    return
  end
  if slua.isValid(uVictimPawn) then
    local VictimPS = uVictimPawn:GetPlayerStateSafety()
    if slua.isValid(VictimPS) and VictimPS.TeamID == uKillerPlayerState.TeamID then
      return
    end
  end
  self:AddPlayerHonorScore(uKillerPlayerState, Enum.EHonorType.Kill, Score)
end
function GameStateTeamHonorFeature:OnPlayerAssist(_, __, uVictimPawn, uAssistPS, TypeID)
  if not self.MapConfig then
    return
  end
  local Score = self.MapConfig.HonorScoreAssist
  if not Score or Score <= 0 then
    return
  end
  if not slua.isValid(uAssistPS) then
    return
  end
  if slua.isValid(uVictimPawn) then
    local VictimPS = uVictimPawn:GetPlayerStateSafety()
    if slua.isValid(VictimPS) and VictimPS.TeamID == uAssistPS.TeamID then
      return
    end
  end
  self:AddPlayerHonorScore(uAssistPS, Enum.EHonorType.Assist, Score)
end
function GameStateTeamHonorFeature:OnPlayerRescue(_, __, uRescuerPawn, uRescuedPawn)
  if not self.MapConfig then
    return
  end
  local Score = self.MapConfig.HonorScoreRescue
  if not Score or Score <= 0 then
    return
  end
  if not slua.isValid(uRescuerPawn) then
    return
  end
  local RescuerPS = uRescuerPawn:GetPlayerStateSafety()
  if not slua.isValid(RescuerPS) then
    return
  end
  self:AddPlayerHonorScore(RescuerPS, Enum.EHonorType.Rescue, Score)
end
function GameStateTeamHonorFeature:OnReviveCommonSuccessNum(_, _, nReviveType, nRecallerPlayerKey, nRecallCount)
  if not self.MapConfig then
    return
  end
  local Score = self.MapConfig.HonorScoreRevive
  if not Score or Score <= 0 or nReviveType ~= 1 or not nRecallCount then
    return
  end
  Score = Score * nRecallCount
  local ReviverPS = Game:GetPlayerStateByPlayerKey(nRecallerPlayerKey)
  if not slua.isValid(ReviverPS) then
    return
  end
  self:AddPlayerHonorScore(ReviverPS, Enum.EHonorType.Revive, Score)
end
function GameStateTeamHonorFeature:OnGameModeStateChange(_, _, sState)
  if sState == "FightingState" then
    self:OnFightingStart()
  elseif sState == "FinishedState" then
    print(bWriteLog and string.format("GameStateTeamHonorFeature:OnGameModeStateChange FinishedState"))
  end
end
function GameStateTeamHonorFeature:OnFightingStart()
  local PlayerNumPerTeam = CGameState.PlayerNumPerTeam or 4
  if PlayerNumPerTeam == 1 then
    self.SinglePlayerStateList:Clear()
    local AllPlayerStates = Game:GetAllPlayerAndFakePlayerAIStates(true)
    if AllPlayerStates and AllPlayerStates:Num() > 0 then
      for _, PlayerState in pairs(AllPlayerStates) do
        if slua.isValid(PlayerState) and PlayerState.TeamID then
          self.SinglePlayerStateList:Add(PlayerState.TeamID, PlayerState)
        end
      end
      print(bWriteLog and string.format("GameStateTeamHonorFeature:OnFightingStart - Single player mode, initialized %d players", self.SinglePlayerStateList:Num()))
    end
  end
  self:SetPlayerHonorState(-1, nil, Enum.EHonorArenaState.HonorCollecting)
  self:UpdateAllTeamHonorData()
  if self.MapConfig.ArenaBeginTeleportTime then
    self:AddGameTimer(self.MapConfig.ArenaBeginTeleportTime, false, function()
      self:BeginArenaChoosingProcess()
    end)
    if slua.isValid(CGameState) then
      self.ArenaBeginTeleportServerTime = CGameState:GetServerWorldTimeSeconds() + self.MapConfig.ArenaBeginTeleportTime
    end
  end
  if CGameMode and slua.isValid(CGameMode.CircleMgr) and self.MapConfig.ArenaCircleIndex then
    for i = 0, self.MapConfig.ArenaCircleIndex do
      CGameMode.CircleMgr:PreCalculateCircle(i)
    end
    self.ArenaInitialPos = CGameMode.CircleMgr:GetWhiteCircle(self.MapConfig.ArenaCircleIndex)
    self.ArenaInitialPos.Z = self.MapConfig.ArenaInitialHeight
    self.ArenaFinalPos = self.ArenaInitialPos
    self.ArenaFinalPos.Z = self.MapConfig.ArenaFinalHeight
    print(bWriteLog and string.format("GameStateTeamHonorFeature:OnFightingStart - ArenaInitialPos=%s", self.ArenaInitialPos:ToString()))
    if CGameMode and CGameMode.DungeonFeature then
      CGameMode.DungeonFeature:GenerateDungeonLevel(self.ArenaInitialPos, self.ArenaFinalPos, true)
      print(bWriteLog and string.format("GameStateTeamHonorFeature:OnFightingStart - GenerateDungeonLevel early with disable"))
    end
    local FakeIslandClass = slua.loadClass(GodTrialConfig.FakeIslandClass)
    if slua.isValid(FakeIslandClass) then
      self.FakeIslandActor = CGameWorld:SpawnActor(FakeIslandClass, self.ArenaInitialPos + self.MapConfig.FakeIslandOffset, FRotator(0), nil)
    end
    self:AddGameTimer(self.MapConfig.ArenaBeginDescendTime, false, function()
      self:StartDecend()
    end)
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    local ReviveConfig = DSReviveSubsystem:GetPlaneInfoRevivedBySelf()
    ReviveConfig.AvoidPOI = {
      {
        X = self.ArenaInitialPos.X,
        Y = self.ArenaInitialPos.Y,
        Z = self.MapConfig.AvoidPOIRadius
      }
    }
    if slua.isValid(CGameState) and slua.isValid(CGameState.AirAttack) then
      CGameState.AirAttack.AreaCenterPosi = FVector(self.ArenaInitialPos.X, self.ArenaInitialPos.Y, self.ArenaInitialPos.Z)
      print(bWriteLog and string.format("GameStateTeamHonorFeature:OnFightingStart - AirAttack.AreaCenterPosi=%s", CGameState.AirAttack.AreaCenterPosi:ToString()))
    end
  end
end
function GameStateTeamHonorFeature:OnRep_ArenaBeginTeleportServerTime()
  print(bWriteLog and "GameStateTeamHonorFeature:OnRep_ArenaBeginTeleportServerTime")
  if self.ArenaBeginTeleportServerTime > 0 then
    local TimeCountingUI = UIManager.GetUI(UIManager.UI_Config_InGame.TimeCountingUI)
    TimeCountingUI = TimeCountingUI or UIManager.ShowUI(UIManager.UI_Config_InGame.TimeCountingUI)
    local ProgressData = {
      CountingDownTimeStamp = self.ArenaBeginTeleportServerTime,
      ImgPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Castle_png.ZD_Icon_Castle_png"
    }
    if TimeCountingUI then
      TimeCountingUI:SetProgressData(ProgressData, 0)
    end
  end
end
function GameStateTeamHonorFeature:BeginArenaChoosingProcess()
  self.ChoosenTeamList = {}
  local DelayGenerateSummonLightTime = 5
  for nRank, TeamData in pairs(self.TeamTotalScoreList) do
    local TeamID = math.floor(TeamData.X + 0.5)
    local TotalScore = TeamData.Y
    if nRank < self.ArenaChoosenTeamNum and TotalScore >= self.ArenaMinimumScore then
      table.insert(self.ChoosenTeamList, TeamID)
      print(bWriteLog and string.format("GameStateTeamHonorFeature:BeginArenaChoosingProcess - TeamID=%d, TotalScore=%f", TeamID, TotalScore))
    end
  end
  self:AddGameTimer(DelayGenerateSummonLightTime, false, function()
    self:GenerateSummonLight()
  end)
  self:SetPlayerHonorState(-1, nil, Enum.EHonorArenaState.WaitEnterArena)
  if not self.HonorDungeonMapMark and self.ArenaFinalPos then
    self.HonorDungeonMapMark = InGameMarkTools.ServerAddMapMark(440004, self.ArenaFinalPos)
    InGameMarkTools.UpdateMapMarkCustomState(self.HonorDungeonMapMark, 1)
  end
  local AllPlayerStates = Game:GetAllPlayerAndFakePlayerAIStates(true)
  if AllPlayerStates and AllPlayerStates:Num() > 0 then
    for _, PlayerState in pairs(AllPlayerStates) do
      if slua.isValid(PlayerState) then
        local TeamID = PlayerState.TeamID
        local HonorData = self.TeamHonorDataList[TeamID]
        if TeamID and HonorData and HonorData.TotalScore then
          PlayerState:AddGeneralCount(2125, HonorData.TotalScore, true)
          print(bWriteLog and string.format("GameStateTeamHonorFeature:BeginArenaChoosingProcess - 2125 TeamID=%d, TotalScore=%f", TeamID, HonorData.TotalScore))
        end
        if TeamID and HonorData and HonorData.TypeScoreList then
          for Name, Value in pairs(Enum.EHonorType) do
            local nID = GodTrialConfig.EHonorTypeToTlogIDMap2[Value]
            local nCount = HonorData.TypeScoreList[Value]
            if nID and nCount then
              PlayerState:AddGeneralCount(nID, nCount, true)
              print(bWriteLog and string.format("GameStateTeamHonorFeature:BeginArenaChoosingProcess AddGeneralCount nID = %s, nCount = %s PlayerKey= %s", nID, nCount, PlayerState.PlayerKey))
            end
          end
        end
        if PlayerState:IsAlive() then
          PlayerState:AddGeneralCount(2126, 1, true)
          print(bWriteLog and string.format("GameStateTeamHonorFeature:BeginArenaChoosingProcess - 2126 TeamID=%d", TeamID))
          if self:IsChoosenTeam(TeamID) then
            PlayerState:AddGeneralCount(2127, 1, true)
            self:AddGameTimer(DelayGenerateSummonLightTime, false, function()
              Game:UIShowImageTips(PlayerState.PlayerKey, 4401004)
            end)
            print(bWriteLog and string.format("GameStateTeamHonorFeature:BeginArenaChoosingProcess - 2127 TeamID=%d", TeamID))
          else
            self:AddGameTimer(DelayGenerateSummonLightTime, false, function()
              Game:UIShowImageTips(PlayerState.PlayerKey, 4401003)
            end)
          end
        end
      end
    end
  end
  if CGameMode and CGameMode.DungeonFeature then
    CGameMode.DungeonFeature:BeginArenaChoosingProcess()
  end
end
function GameStateTeamHonorFeature:RemoveDungeonMapMark()
  if self.HonorDungeonMapMark then
    InGameMarkTools.HideMapMark(self.HonorDungeonMapMark)
    self.HonorDungeonMapMark = nil
  end
end
function GameStateTeamHonorFeature:GenerateSummonLight()
  local SummonLightActorClass = slua.loadClass(GodTrialConfig.ArenaLightClass)
  for _, TeamID in ipairs(self.ChoosenTeamList) do
    local PlayerStateList = self:GetPlayerStatesByTeamID(TeamID)
    for _, PlayerState in pairs(PlayerStateList) do
      if slua.isValid(PlayerState) and slua.isValid(CGameWorld) then
        local PlayerCharacter = PlayerState:GetPlayerCharacter()
        if slua.isValid(PlayerCharacter) then
          self:_SpawnSummonLightForPlayer(SummonLightActorClass, PlayerCharacter, PlayerState)
        end
        self:AIPerceptionChoosenState(PlayerState.PlayerKey)
      end
    end
  end
  self:AddGameTimer(self.MapConfig.ArenaLightLastingTime, false, function()
    self:_ClearAllSummonLightScreenMarks()
    for _, uActor in pairs(self.SummonLightActorList) do
      if slua.isValid(uActor) then
        uActor:K2_DestroyActor()
      end
    end
    print(bWriteLog and string.format("GameStateTeamHonorFeature:GenerateSummonLight - DestroyActor"))
  end)
end
function GameStateTeamHonorFeature:_ClearAllSummonLightScreenMarks()
  if not self.SummonLightMarkInstIDsMap then
    return
  end
  for _, MarkInstIDs in pairs(self.SummonLightMarkInstIDsMap) do
    if MarkInstIDs then
      for _, InstID in ipairs(MarkInstIDs) do
        InGameMarkTools.HideMapMark(InstID)
      end
    end
  end
  self.SummonLightMarkInstIDsMap = {}
  print(bWriteLog and "GameStateTeamHonorFeature:_ClearAllSummonLightScreenMarks - all marks hidden")
end
function GameStateTeamHonorFeature:_SpawnSummonLightForPlayer(SummonLightActorClass, PlayerCharacter, OwnerPlayerState)
  local PlayerLocation = PlayerCharacter:K2_GetActorLocation()
  if PlayerCharacter.bOnNTPreheat and slua.isValid(PlayerCharacter.CacheNTPreHeatActor) then
    local ActorLocation = PlayerCharacter.CacheNTPreHeatActor:K2_GetActorLocation()
    local Radius = math.random(self.MapConfig.ArenaLightOffsetMixDistance, self.MapConfig.ArenaLightOffsetMaxDistance)
    local HalfAngle = self.MapConfig.ArenaLightRandomHalfAngle or 60
    local AngleOffset = math.random(-HalfAngle, HalfAngle)
    local PlayerRotation = PlayerCharacter:K2_GetActorRotation()
    local FinalYaw = math.rad(PlayerRotation.Yaw + AngleOffset)
    local OffsetX = Radius * math.cos(FinalYaw)
    local OffsetY = Radius * math.sin(FinalYaw)
    local Location = ActorLocation + FVector(OffsetX, OffsetY, 10)
    Location = Game:GetGroundLocation(Location, -10000)
    self:_TrySpawnSummonLight(SummonLightActorClass, Location, false, OwnerPlayerState)
    print(bWriteLog and string.format("GameStateTeamHonorFeature:_SpawnSummonLightForPlayer - NTPreheat, spawn around NTPreheatActor at %s", Location:ToString()))
    return
  end
  local uTrialManager = PlayerCharacter.TrialFeature and PlayerCharacter.TrialFeature.uTrialManager
  if slua.isValid(uTrialManager) then
    local Positions = uTrialManager:GetSummonLightPositions()
    if Positions then
      for _, Pos in ipairs(Positions) do
        Pos = Game:GetGroundLocation(Pos, -1000)
        self:_TrySpawnSummonLight(SummonLightActorClass, Pos, true, OwnerPlayerState)
      end
      print(bWriteLog and string.format("GameStateTeamHonorFeature:_SpawnSummonLightForPlayer - TrialType=%s, spawn at trial positions", uTrialManager.TrialType))
      return
    end
  end
  local HighAltitudeThreshold = GodTrialConfig.ArenaLightHighAltitudeThreshold or 500
  local GroundLocation = Game:GetGroundLocation(FVector(PlayerLocation.X, PlayerLocation.Y, PlayerLocation.Z + 100), -200000)
  local HeightAboveGround = PlayerLocation.Z - GroundLocation.Z
  if HighAltitudeThreshold < HeightAboveGround then
    self:_TrySpawnSummonLight(SummonLightActorClass, GroundLocation, false, OwnerPlayerState)
    print(bWriteLog and string.format("GameStateTeamHonorFeature:_SpawnSummonLightForPlayer - Airborne (height=%.0f), spawn at ground XY", HeightAboveGround))
    return
  end
  local Radius = math.random(self.MapConfig.ArenaLightOffsetMixDistance, self.MapConfig.ArenaLightOffsetMaxDistance)
  local HalfAngle = self.MapConfig.ArenaLightRandomHalfAngle or 60
  local AngleOffset = math.random(-HalfAngle, HalfAngle)
  local PlayerRotation = PlayerCharacter:K2_GetActorRotation()
  local FinalYaw = math.rad(PlayerRotation.Yaw + AngleOffset)
  local OffsetX = Radius * math.cos(FinalYaw)
  local OffsetY = Radius * math.sin(FinalYaw)
  local Location = PlayerLocation + FVector(OffsetX, OffsetY, 10)
  Location = Game:GetGroundLocation(Location, -10000)
  self:_TrySpawnSummonLight(SummonLightActorClass, Location, false, OwnerPlayerState)
end
function GameStateTeamHonorFeature:_TrySpawnSummonLight(SummonLightActorClass, Location, SkipCheck, OwnerPlayerState)
  local bShouldSpawn, NearestLightActor = self:ShouldSpawnLight(Location)
  if not bShouldSpawn and not SkipCheck then
    if slua.isValid(NearestLightActor) and slua.isValid(OwnerPlayerState) then
      self:_AddScreenMarkOnSummonLight(NearestLightActor, OwnerPlayerState)
    end
    return
  end
  local uActor = CGameWorld:SpawnActor(SummonLightActorClass, Location, FRotator(0), nil)
  if slua.isValid(uActor) then
    table.insert(self.SummonLightActorList, uActor)
    if slua.isValid(OwnerPlayerState) then
      self:_AddScreenMarkOnSummonLight(uActor, OwnerPlayerState)
    end
    local TraceStart = FVector(Location.X, Location.Y, Location.Z + 50)
    local TraceEnd = FVector(Location.X, Location.Y, Location.Z - 200)
    local bHit, HitResult = UKismetSystemLibrary.LineTraceSingleForObjects(CGameWorld, TraceStart, TraceEnd, {
      Game:ConvertToObjectType(ECollisionChannel.ECC_WorldStatic),
      Game:ConvertToObjectType(ECollisionChannel.ECC_WorldDynamic)
    }, false, nil, 0, nil, false, FLinearColor.Red, FLinearColor.Green, 1)
    if bHit and HitResult and slua.isValid(HitResult.Actor) and HitResult.Actor:ActorHasTag("MoveablePlatform") then
      local uRootComp = HitResult.Actor:K2_GetRootComponent()
      if slua.isValid(uRootComp) then
        local EAttachmentRule = import("EAttachmentRule")
        uActor:K2_AttachToComponent(uRootComp, "None", EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, false)
        print(bWriteLog and string.format("GameStateTeamHonorFeature:_TrySpawnSummonLight - Attached to MoveablePlatform actor=%s at %s", tostring(HitResult.Actor), Location:ToString()))
      end
    end
    print(bWriteLog and string.format("GameStateTeamHonorFeature:_TrySpawnSummonLight - SpawnActor at %s", Location:ToString()))
  end
end
function GameStateTeamHonorFeature:IsChoosenTeam(TeamID)
  return TableUtil.Find(self.ChoosenTeamList, TeamID) > 0
end
function GameStateTeamHonorFeature:ShouldSpawnLight(Location)
  local NearestActor
  local NearestDist = math.huge
  for _, uActor in pairs(self.SummonLightActorList) do
    if slua.isValid(uActor) then
      local uActorLocation = uActor:K2_GetActorLocation()
      local Dist = FVector.DistXY(uActorLocation, Location)
      if Dist < self.MapConfig.ArenaMinimumDistance and NearestDist > Dist then
        Nearest        NearestActor = uActor
      end
    end
  end
  if NearestActor then
    return false, NearestActor
  end
  return true, nil
end
function GameStateTeamHonorFeature:_AddScreenMarkOnSummonLight(uLightActor, OwnerPlayerState)
  if not slua.isValid(uLightActor) or not slua.isValid(OwnerPlayerState) then
    return
  end
  local Location = uLightActor:K2_GetActorLocation()
  local CountdownTime = self.MapConfig.ArenaLightLastingTime or 0
  CountdownTime = math.floor(CountdownTime + CGameState:GetServerWorldTimeSeconds() + 0.5)
  local InstID = InGameMarkTools.ServerAddMapMark(440017, Location, CountdownTime, UEnums.EAddMarkFlag.EAMF_Screen, 0, UEnums.EMarkDispatchRange.EMAMDT_TEAMMATE, OwnerPlayerState, uLightActor)
  if not InstID then
    return
  end
  if not self.SummonLightMarkInstIDsMap[uLightActor] then
    self.SummonLightMarkInstIDsMap[uLightActor] = {}
  end
  table.insert(self.SummonLightMarkInstIDsMap[uLightActor], InstID)
  print(bWriteLog and string.format("GameStateTeamHonorFeature:_AddScreenMarkOnSummonLight - InstID=%s, TeamID=%s", tostring(InstID), tostring(OwnerPlayerState.TeamID)))
end
function GameStateTeamHonorFeature:StartDecend()
  print(bWriteLog and string.format("GameStateTeamHonorFeature:StartDecend"))
  self:AddGameTimer(self.MapConfig.RealIslandGenerateTime, false, function()
    print(bWriteLog and string.format("GameStateTeamHonorFeature:StartDecend - EnableDungeonLevel"))
    self.bDungeonLevelVisible = true
    self:SetDungeonLevelVisible(true)
    self:ForceNetUpdate()
  end)
  if slua.isValid(self.FakeIslandActor) then
    local Trans = self.FakeIslandActor:GetTransform()
    Game:PlayLevelSequence(self.FakeIslandActor, GodTrialConfig.TheDescendedSeq, Trans, GodTrialConfig.SequenceActorPath, true, {
      BP_FakeIsland = self.FakeIslandActor
    })
    print(bWriteLog and string.format("GameStateTeamHonorFeature:StartDecend - PlayLevelSequence"))
  end
end
function GameStateTeamHonorFeature:UpdateAllTeamHonorData()
  if not self:HasAuthority() then
    return
  end
  local TeamIDs = self:GetAllTeamIDs()
  if not TeamIDs or TeamIDs:Num() == 0 then
    return
  end
  self.TeamHonorDataList = {}
  if self.TeamTotalScoreList then
    self.TeamTotalScoreList:Clear()
  else
    self.TeamTotalScoreList = slua.Array(FVector2D)
  end
  for _, TeamID in pairs(TeamIDs) do
    local TeamHonorData = self:CalculateTeamHonor(TeamID)
    if TeamHonorData then
      self.TeamHonorDataList[TeamID] = TeamHonorData
      local TeamTotalScore = FVector2D(TeamID, TeamHonorData.TotalScore)
      self.TeamTotalScoreList:Add(TeamTotalScore)
    end
  end
  self:SortTeamTotalScoreList()
  self:UpdateAllPlayersTeamHonorData()
end
function GameStateTeamHonorFeature:SortTeamTotalScoreList()
  if not self.TeamTotalScoreList or self.TeamTotalScoreList:Num() == 0 then
    return
  end
  local SortedList = {}
  for Index = 0, self.TeamTotalScoreList:Num() - 1 do
    local Data = self.TeamTotalScoreList:Get(Index)
    if Data then
      table.insert(SortedList, Data)
    end
  end
  table.sort(SortedList, function(A, B)
    return A.Y > B.Y
  end)
  self.TeamTotalScoreList:Clear()
  for _, Data in ipairs(SortedList) do
    self.TeamTotalScoreList:Add(Data)
  end
  print(bWriteLog and "GameStateTeamHonorFeature:SortTeamTotalScoreList - Team total score list sorted")
end
function GameStateTeamHonorFeature:UpdateTeamHonorData(TeamID)
  if not self:HasAuthority() then
    return
  end
  local TeamHonorData = self:CalculateTeamHonor(TeamID)
  if not TeamHonorData then
    return
  end
  self.TeamHonorDataList[TeamID] = TeamHonorData
  local bFound = false
  for Index = 0, self.TeamTotalScoreList:Num() - 1 do
    local ExistingData = self.TeamTotalScoreList:Get(Index)
    if ExistingData and ExistingData.X == TeamID then
      self.TeamTotalScoreList:Set(Index, FVector2D(TeamID, TeamHonorData.TotalScore))
      bFound = true
      break
    end
  end
  if not bFound then
    local TeamTotalScore = FVector2D(TeamID, TeamHonorData.TotalScore)
    self.TeamTotalScoreList:Add(TeamTotalScore)
  end
  self:SortTeamTotalScoreList()
  self:UpdateAllPlayersTeamHonorData()
  self:AIPerceptionHonorOrGoldenCoin(TeamID, TeamHonorData.TotalScore, false)
  print(bWriteLog and string.format("GameStateTeamHonorFeature:UpdateTeamHonorData TeamID=%s, Kill=%s, GodTrial=%s, FireAltar=%s, Total=%s", TeamID, TeamHonorData.KillScore, TeamHonorData.GodTrialScore, TeamHonorData.FireAltarScore, TeamHonorData.TotalScore))
end
function GameStateTeamHonorFeature:UpdateTeamGoldenCoin(TeamID, GoldenCoin)
  if not self:HasAuthority() then
    return
  end
  local TeamGoldenCoin = self:CalculateTeamGoldenCoin(TeamID)
  if not TeamGoldenCoin then
    return
  end
  if TeamGoldenCoin >= self.MapConfig.ArenaOpenNeedCoinNum then
    local TeamStates = self:GetPlayerStatesByTeamID(TeamID)
    for _, PlayerState in pairs(TeamStates) do
      if slua.isValid(PlayerState) and CGameMode.DungeonFeature:IsInSingleDungeon(PlayerState) and PlayerState.PlayerStateHonorFeature then
        self:SetPlayerHonorState(nil, PlayerState, Enum.EHonorArenaState.GoldenFinished)
      end
    end
  else
    local TeamStates = self:GetPlayerStatesByTeamID(TeamID)
    for _, PlayerState in pairs(TeamStates) do
      if slua.isValid(PlayerState) and CGameMode.DungeonFeature:IsInSingleDungeon(PlayerState) and PlayerState.PlayerStateHonorFeature then
        self:SetPlayerHonorState(nil, PlayerState, Enum.EHonorArenaState.GoldenCollecting)
      end
    end
  end
  local bFound = false
  for Index = 0, self.TeamGoldenCoinList:Num() - 1 do
    local ExistingData = self.TeamGoldenCoinList:Get(Index)
    if ExistingData and ExistingData.X == TeamID then
      self.TeamGoldenCoinList:Set(Index, FVector2D(TeamID, TeamGoldenCoin))
      bFound = true
      break
    end
  end
  if not bFound then
    local TeamTotalScore = FVector2D(TeamID, TeamGoldenCoin)
    self.TeamGoldenCoinList:Add(TeamTotalScore)
  end
  self:AIPerceptionHonorOrGoldenCoin(TeamID, TeamGoldenCoin, true)
  print(bWriteLog and string.format("GameStateTeamHonorFeature:UpdateTeamGoldenCoin TeamID=%s, GoldenCoin=%s", TeamID, GoldenCoin))
end
function GameStateTeamHonorFeature:GetTeamGoldenCoin(TeamID)
  for Index = 0, self.TeamGoldenCoinList:Num() - 1 do
    local ExistingData = self.TeamGoldenCoinList:Get(Index)
    if ExistingData and ExistingData.X == TeamID then
      return ExistingData.Y
    end
  end
  return 0
end
function GameStateTeamHonorFeature:CalculateTeamGoldenCoin(TeamID)
  local PlayerStates = self:GetPlayerStatesByTeamID(TeamID)
  if not PlayerStates or PlayerStates:Num() == 0 then
    return nil
  end
  local TotalGoldenCoin = 0
  for _, PlayerState in pairs(PlayerStates) do
    if slua.isValid(PlayerState) and PlayerState.PlayerStateHonorFeature then
      TotalGoldenCoin = TotalGoldenCoin + PlayerState.PlayerStateHonorFeature:GetGoldenCoin()
    end
  end
  for _, PlayerState in pairs(PlayerStates) do
    if slua.isValid(PlayerState) and PlayerState.PlayerStateHonorFeature then
      PlayerState.PlayerStateHonorFeature.TeamGoldenCoinCount = TotalGoldenCoin
    end
  end
  return TotalGoldenCoin
end
function GameStateTeamHonorFeature:HaveEnoughGoldenCoin(Character)
  if not slua.isValid(Character) then
    return false
  end
  local TeamID = Character.TeamID
  local TeamGoldenCoin = self:GetTeamGoldenCoin(TeamID)
  if TeamGoldenCoin >= self.MapConfig.ArenaOpenNeedCoinNum then
    return true
  end
  return false
end
function GameStateTeamHonorFeature:CalculateTeamHonor(TeamID)
  local PlayerStates = self:GetPlayerStatesByTeamID(TeamID)
  if not PlayerStates or PlayerStates:Num() == 0 then
    return nil
  end
  local TeamHonorData = {
    TeamID = TeamID,
    TypeScoreList = {},
    TotalScore = 0
  }
  for _, PlayerState in pairs(PlayerStates) do
    if slua.isValid(PlayerState) then
      local HonorFeature = PlayerState.PlayerStateHonorFeature
      if HonorFeature and HonorFeature.TypeScoreList then
        for Name, Value in pairs(Enum.EHonorType) do
          if not TeamHonorData.TypeScoreList[Value] then
            TeamHonorData.TypeScoreList[Value] = 0
          end
          TeamHonorData.TypeScoreList[Value] = HonorFeature:GetScore(Value) + TeamHonorData.TypeScoreList[Value]
        end
      end
    end
  end
  for Name, Value in pairs(Enum.EHonorType) do
    TeamHonorData.TotalScore = TeamHonorData.TotalScore + TeamHonorData.TypeScoreList[Value]
  end
  return TeamHonorData
end
function GameStateTeamHonorFeature:GetTeamHonorData(TeamID)
  if not self.TeamHonorDataList then
    return nil
  end
  return self.TeamHonorDataList[TeamID]
end
function GameStateTeamHonorFeature:GetSortedTeamHonorList(HonorType, bDescending, Limit)
  if not self.TeamHonorDataList or not next(self.TeamHonorDataList) then
    return {}
  end
  local TeamList = {}
  for _, TeamData in pairs(self.TeamHonorDataList) do
    table.insert(TeamList, TeamData)
  end
  local GetSortKey = function(Data)
    if HonorType == -1 then
      return Data.TotalScore
    elseif HonorType == Enum.EHonorType.Kill then
      return Data.KillScore
    elseif HonorType == Enum.EHonorType.GodTrial then
      return Data.GodTrialScore
    elseif HonorType == Enum.EHonorType.FireAltar then
      return Data.FireAltarScore
    else
      return Data.TotalScore
    end
  end
  bDescending = bDescending == nil or bDescending
  local SortFunc = bDescending and function(A, B)
    return GetSortKey(A) > GetSortKey(B)
  end or function(A, B)
    return GetSortKey(A) < GetSortKey(B)
  end
  table.sort(TeamList, SortFunc)
  if Limit and 0 < Limit and Limit < #TeamList then
    local Result = {}
    for i = 1, Limit do
      table.insert(Result, TeamList[i])
    end
    return Result
  end
  return TeamList
end
function GameStateTeamHonorFeature:GetTopTeamsByTotalScore(TopN)
  return self:GetSortedTeamHonorList(-1, true, TopN)
end
function GameStateTeamHonorFeature:GetTeamRank(TeamID)
  local SortedList = self:GetSortedTeamHonorList(-1, true)
  for Rank, TeamData in ipairs(SortedList) do
    if TeamData.TeamID == TeamID then
      return Rank
    end
  end
  return nil
end
function GameStateTeamHonorFeature:GetTeamHonorLeaderboard(HonorType, TopN)
  HonorType = HonorType or -1
  TopN = TopN or 10
  local SortedList = self:GetSortedTeamHonorList(HonorType, true, TopN)
  local Leaderboard = {}
  for Rank, TeamData in ipairs(SortedList) do
    table.insert(Leaderboard, {
      Rank = Rank,
      TeamID = TeamData.TeamID,
      KillScore = TeamData.KillScore,
      GodTrialScore = TeamData.GodTrialScore,
      FireAltarScore = TeamData.FireAltarScore,
      TotalScore = TeamData.TotalScore
    })
  end
  return Leaderboard
end
function GameStateTeamHonorFeature:UpdateAllPlayersTeamHonorData()
  if not self:HasAuthority() then
    return
  end
  if not self.TeamHonorDataList or not next(self.TeamHonorDataList) then
    return
  end
  for TeamID, TeamData in pairs(self.TeamHonorDataList) do
    if TeamData then
      local PlayerStates = self:GetPlayerStatesByTeamID(TeamID)
      if PlayerStates and PlayerStates:Num() > 0 then
        for _, PlayerState in pairs(PlayerStates) do
          if slua.isValid(PlayerState) then
            local PlayerHonorFeature = PlayerState.PlayerStateHonorFeature
            if PlayerHonorFeature then
              PlayerHonorFeature.TeamKillScore = TeamData.KillScore
              PlayerHonorFeature.TeamGodTrialScore = TeamData.GodTrialScore
              PlayerHonorFeature.TeamFireAltarScore = TeamData.FireAltarScore
              PlayerHonorFeature.TeamTotalScore = TeamData.TotalScore
            end
          end
        end
      end
    end
  end
end
function GameStateTeamHonorFeature:UpdatePlayerTeamHonorData()
  if not self:HasAuthority() then
    return
  end
  local MyPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(MyPlayerController) then
    return
  end
  local MyPlayerState = MyPlayerController.PlayerState
  if not slua.isValid(MyPlayerState) then
    return
  end
  local TeamID = MyPlayerState.TeamID
  local TeamHonorData = self:GetTeamHonorData(TeamID)
  if TeamHonorData then
    local PlayerHonorFeature = MyPlayerState.PlayerStateHonorFeature
    if PlayerHonorFeature then
      PlayerHonorFeature.TeamKillScore = TeamHonorData.KillScore
      PlayerHonorFeature.TeamGodTrialScore = TeamHonorData.GodTrialScore
      PlayerHonorFeature.TeamFireAltarScore = TeamHonorData.FireAltarScore
      PlayerHonorFeature.TeamTotalScore = TeamHonorData.TotalScore
      print(bWriteLog and string.format("GameStateTeamHonorFeature:UpdatePlayerTeamHonorData PlayerKey = %s, TotalScore = %s", MyPlayerState.PlayerKey, TeamHonorData.TotalScore))
    end
  end
end
function GameStateTeamHonorFeature:GetAllTeamIDs()
  local PlayerNumPerTeam = CGameState.PlayerNumPerTeam or 4
  if PlayerNumPerTeam == 1 then
    if self.SinglePlayerStateList and self.SinglePlayerStateList:Num() > 0 then
      local TeamIDs = slua.Array(UEnums.EPropertyClass.Int)
      for TeamID, PlayerState in pairs(self.SinglePlayerStateList) do
        TeamIDs:Add(TeamID)
      end
      return TeamIDs
    end
    return nil
  end
  return Game:GetAllTeamIDs()
end
function GameStateTeamHonorFeature:SetPlayerHonorState(TeamID, uPlayerState, nState)
  if slua.isValid(uPlayerState) and uPlayerState.PlayerStateHonorFeature then
    uPlayerState.PlayerStateHonorFeature:SetPlayerHonorState(nState)
    print(bWriteLog and string.format("GameStateTeamHonorFeature:SetPlayerHonorState uPlayerState = %s, nState = %s", uPlayerState.PlayerKey, nState))
    return
  end
  print(bWriteLog and string.format("GameStateTeamHonorFeature:SetPlayerHonorState TeamID = %s, nState = %s", TeamID, nState))
  if 0 < TeamID then
    local PlayerStates = self:GetPlayerStatesByTeamID(TeamID)
    if PlayerStates then
      for _, PlayerState in pairs(PlayerStates) do
        if slua.isValid(PlayerState) and PlayerState.PlayerStateHonorFeature then
          PlayerState.PlayerStateHonorFeature:SetPlayerHonorState(nState)
        end
      end
    end
  end
  if TeamID < 0 then
    local TeamIDs = self:GetAllTeamIDs()
    for _, TeamID in pairs(TeamIDs) do
      local PlayerStates = self:GetPlayerStatesByTeamID(TeamID)
      if PlayerStates then
        for _, PlayerState in pairs(PlayerStates) do
          if slua.isValid(PlayerState) and PlayerState.PlayerStateHonorFeature then
            PlayerState.PlayerStateHonorFeature:SetPlayerHonorState(nState)
          end
        end
      end
    end
  end
end
function GameStateTeamHonorFeature:AIPerceptionChoosenState(PlayerKey)
  if Client then
    return
  end
  if PlayerKey then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_MLAI_CHARACTER_ATTRIBUTE_CHANGE, PlayerKey, 4400001, 1)
  end
end
function GameStateTeamHonorFeature:OnPlayerSettlementStart(_, __, nUID, tResult)
  if nUID then
    print(bWriteLog and string.format("GameStateTeamHonorFeature:OnPlayerSettlementStart nUID = %s", nUID))
    local PlayerState = Game:GetPlayerStateByUID(nUID)
    if slua.isValid(PlayerState) then
      local TeamID = PlayerState.TeamID
      local HonorData = self.TeamHonorDataList[TeamID]
      if TeamID and HonorData and HonorData.TypeScoreList then
        for Name, Value in pairs(Enum.EHonorType) do
          local nID = GodTrialConfig.EHonorTypeToTlogIDMap[Value]
          local nCount = HonorData.TypeScoreList[Value]
          if nID and nCount then
            tResult.GeneralCounterMap[nID] = nCount
            print(bWriteLog and string.format("GameStateTeamHonorFeature:OnPlayerSettlementStart AddGeneralCount nID = %s, nCount = %s PlayerKey= %s", nID, nCount, PlayerState.PlayerKey))
          end
        end
        tResult.GeneralCounterMap[2124] = HonorData.TotalScore
        print(bWriteLog and string.format("GameStateTeamHonorFeature:OnPlayerSettlementStart AddGeneralCount nID = %s, nCount = %s PlayerKey= %s", 2124, HonorData.TotalScore, PlayerState.PlayerKey))
      end
      if tResult.Reason == "win" and slua.isValid(CGameState.uCacheCentaur) and CGameState.uCacheCentaur:IsAlive() and PlayerState.TeamID == self.HiredCentaurTeamID then
        tResult.GeneralCounterMap[2191] = 1
        print(bWriteLog and string.format("GameStateTeamHonorFeature:OnPlayerSettlementStart TLog 2191 PlayerKey=%s", PlayerState.PlayerKey))
        if PlayerState.PlayerKey == self.HiredCentaurPlayerKey then
          tResult.GeneralCounterMap[2172] = 1
          print(bWriteLog and string.format("GameStateTeamHonorFeature:OnPlayerSettlementStart TLog 2172 PlayerKey=%s", PlayerState.PlayerKey))
        end
      end
    end
  end
end
function GameStateTeamHonorFeature:AIPerceptionHonorOrGoldenCoin(nTeamID, nScore, bGoldenCoin)
  if Client then
    return
  end
  if nTeamID and nScore and 0 <= nScore and bGoldenCoin ~= nil then
    local PlayerStates = self:GetPlayerStatesByTeamID(nTeamID)
    if PlayerStates then
      for _, PlayerState in pairs(PlayerStates) do
        if slua.isValid(PlayerState) and PlayerState.PlayerKey then
          if bGoldenCoin then
            EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_MLAI_CHARACTER_ATTRIBUTE_CHANGE, PlayerState.PlayerKey, 4400011, nScore)
          else
            EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_MLAI_CHARACTER_ATTRIBUTE_CHANGE, PlayerState.PlayerKey, 4400010, nScore)
          end
        end
      end
    end
  end
end
function GameStateTeamHonorFeature:OnTheDescendedSky(_, __, obj)
  if Client then
    return
  end
  local AllPawnsArr = Game:GetAllPlayerPawns()
  for _, AIPawn in pairs(AllPawnsArr) do
    if slua.isValid(AIPawn) and AIPawn.SkyTransition then
      AIPawn.SkyTransition:SetStateActive(440004, true)
    end
  end
  print(bWriteLog and "GameStateTeamHonorFeature:OnTheDescendedSky")
end
function GameStateTeamHonorFeature:OnTheDescendedSkyEnd(_, __, obj)
  if Client then
    return
  end
  local AllPawnsArr = Game:GetAllPlayerPawns()
  for _, AIPawn in pairs(AllPawnsArr) do
    if slua.isValid(AIPawn) and AIPawn.SkyTransition then
      AIPawn.SkyTransition:SetStateActive(440004, false)
    end
  end
  print(bWriteLog and "GameStateTeamHonorFeature:OnTheDescendedSkyEnd")
end
function GameStateTeamHonorFeature:OnRep_TeamTotalScoreList()
  print(bWriteLog and "GameStateTeamHonorFeature:OnRep_TeamTotalScoreList - Team total score updated")
  if not self.TeamTotalScoreList or self.TeamTotalScoreList:Num() == 0 then
    return
  end
  for Index = 0, self.TeamTotalScoreList:Num() - 1 do
    local TeamScoreData = self.TeamTotalScoreList:Get(Index)
    if TeamScoreData then
      print(bWriteLog and string.format("GameStateTeamHonorFeature:OnRep_TeamTotalScoreList - TeamID:%s, TotalScore:%s", TeamScoreData.X, TeamScoreData.Y))
    end
  end
  self:LuaBroadcast("OnRep_TeamTotalScoreList", self.TeamTotalScoreList)
end
function GameStateTeamHonorFeature:OnRep_TeamGoldenCoinList()
  print(bWriteLog and "GameStateTeamHonorFeature:OnRep_TeamGoldenCoinList - Team total score updated")
  if not self.TeamGoldenCoinList or self.TeamGoldenCoinList:Num() == 0 then
    return
  end
  for Index = 0, self.TeamGoldenCoinList:Num() - 1 do
    local TeamScoreData = self.TeamGoldenCoinList:Get(Index)
    if TeamScoreData then
      print(bWriteLog and string.format("GameStateTeamHonorFeature:OnRep_TeamGoldenCoinList - TeamID:%s, TotalGoldenCoin:%s", TeamScoreData.X, TeamScoreData.Y))
    end
  end
  EventSystem:postEvent(EVENTTYPE_GODTRIAL_NORMAL, EVENTID_CLIENT_ARENA_GOLDEN_COIN_CHANGE)
end
function GameStateTeamHonorFeature:OnRep_ArenaFinalPos()
  print(bWriteLog and string.format("GameStateTeamHonorFeature:OnRep_ArenaFinalPos - ArenaFinalPos=%s", tostring(self.ArenaFinalPos)))
  local SuperData = self:GetSuperData()
  if SuperData then
    SuperData.ArenaFinalPos = self.ArenaFinalPos
  end
end
function GameStateTeamHonorFeature:ClientGetTeamTotalScore(TeamID)
  if not self.TeamTotalScoreList or self.TeamTotalScoreList:Num() == 0 then
    return nil
  end
  for Index = 0, self.TeamTotalScoreList:Num() - 1 do
    local TeamScoreData = self.TeamTotalScoreList:Get(Index)
    if TeamScoreData and TeamScoreData.X == TeamID then
      return TeamScoreData.Y, Index + 1
    end
  end
  return nil
end
function GameStateTeamHonorFeature:GetPlayerStatesByTeamID(TeamID)
  local PlayerNumPerTeam = CGameState.PlayerNumPerTeam or 4
  if PlayerNumPerTeam == 1 then
    if self.SinglePlayerStateList and self.SinglePlayerStateList:Num() > 0 then
      local PlayerState = self.SinglePlayerStateList:Get(TeamID)
      if slua.isValid(PlayerState) then
        local Result = slua.Array(UEnums.EPropertyClass.Object, STExtraPlayerState)
        Result:Add(PlayerState)
        return Result
      end
    end
    return nil
  end
  return Game:GetPlayerStatesByTeamID(TeamID)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateTeamHonorFeature)