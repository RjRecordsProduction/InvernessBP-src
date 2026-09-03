local GameStateBase = {
  MulticastRPC = {},
  LuaEventContainer = {
    "DefaultLuaEventPlaceholder"
  }
}
local KismetSystemLibrary = import("KismetSystemLibrary")
GameStateBase.MulticastRPC.MultiCast_GenericRPC = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Object,
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Byte
    }
  }
}
function GameStateBase:ctor(selfType)
  self.bIsClient = false
  self.CodeRecord = {}
  self.GlobalCachePool = {}
  self.bLuaGameStateInit = false
  self.SkillManagerEntry = nil
  self._SuperData = nil
  self.MatchReadyConfirmed = false
  self.EnterFightingTime = 0
  self.SelfRescueEndTime = 0
  self.bHaveRevive = false
  local SuperData = self:GetSuperData()
  SuperData.bHaveRevive = self.bHaveRevive
  self.CountdownTime = 0
  self.MaxFPSInMatch = 0
  self.FireworkBGMFlag = -1
  self.nBattleType = 0
  self.MatchZoneId = 0
end
function GameStateBase:_PostConstruct()
  GameStateBase.__super._PostConstruct(self)
  self:AddControlEvent(self, "OnDSOptimGrayPublishFlagsChanged", self.HandleOnDSOptimGrayPublishFlagsChanged, self)
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  if not Client then
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    if slua.isValid(GameInstance) and not STExtraGameplayStatics.IsShipping() then
      local MaxPlayerNum = -1
      GameInstance:ExecuteCMD("ParallelWorld.Debug.MaxPlayerNum", MaxPlayerNum)
    end
  else
    self:AddControlEvent(self, "StartCompleteRecordingDelegate", self.OnStartCompleteRecording, self)
  end
end
function GameStateBase:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "MatchReadyConfirmed",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "SelfRescueEndTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "EnterFightingTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "bHaveRevive",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "CountdownTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "MaxFPSInMatch",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "FireworkBGMFlag",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nBattleType",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "MatchZoneId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function GameStateBase:OnRep_MatchZoneId()
  print(bWriteLog and "GameStateBase:OnRep_MatchZoneId, MatchZoneId = " .. tostring(self.MatchZoneId))
end
function GameStateBase:OnRep_nBattleType()
  print(bWriteLog and "GameStateBase:OnRep_nBattleType", self.nBattleType)
end
function GameStateBase:GetBattleType()
  return self.nBattleType
end
function GameStateBase:IsRankMode()
  local BattleType = self.nBattleType
  print(bWriteLog and "GameStateBase:IsRankMode, BattleType = " .. tostring(BattleType))
  return BattleType == 101 or BattleType == 102 or BattleType == 103 or BattleType == 401 or BattleType == 402 or BattleType == 403
end
function GameStateBase:UpdateCountdownTime(CountdownTime)
  print(bWriteLog and "GameStateBase:UpdateCountdownTime, CountdownTime = " .. tostring(self.CountdownTime))
  local CountdownTimeInt = math.floor(CountdownTime)
  self.CountdownTime = CountdownTimeInt
end
function GameStateBase:UpdateFireworkBGMFlag(InFireworkBGMFlag)
  print(bWriteLog and "GameStateBase:UpdateFireworkBGMFlag, InFireworkBGMFlag = " .. tostring(InFireworkBGMFlag))
  self.FireworkBGMFlag = InFireworkBGMFlag
end
function GameStateBase:OnStartCompleteRecording()
  print(bWriteLog and "GameStateBase:OnStartCompleteRecording")
  local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  if slua.isValid(SettingSubsystem_CPP) then
    SettingSubsystem_CPP:OnReportSettingConfigStart()
  end
end
function GameStateBase:OnRep_CountdownTime()
  local NewYearCountdownSubsystem = SubsystemMgr:Get("NewYearCountdownSubsystem")
  if NewYearCountdownSubsystem then
    NewYearCountdownSubsystem:OnRepCurrentTime(self.CountdownTime)
  else
    print(bWriteLog and "GameStateBase:OnRep_CountdownTime, NewYearCountdownSubsystem = nil")
  end
end
function GameStateBase:OnRep_FireworkBGMFlag()
  local NewYearCountdownSubsystem = SubsystemMgr:Get("NewYearCountdownSubsystem")
  if NewYearCountdownSubsystem then
    NewYearCountdownSubsystem:OnRepFireworkBGMFlag(self.FireworkBGMFlag)
  else
    print(bWriteLog and "GameStateBase:OnRep_FireworkBGMFlag, NewYearCountdownSubsystem = nil")
  end
end
function GameStateBase:OnRep_MaxFPSInMatch()
  print(bWriteLog and string.format("GameStateBase:OnRep_MaxFPSInMatch, RoomType[%s]", self.RoomType))
  if self.RoomType and self.RoomType == "match" then
    print(bWriteLog and string.format("GameStateBase:OnRep_MaxFPSInMatch, MaxFPSInMatch[%d]", self.MaxFPSInMatch))
    if self.MaxFPSInMatch > 0 then
      local UIUtil = require("client.common.ui_util")
      local GameInstance = UIUtil.GetGameInstance()
      local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local CurrentMaxFps = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.MaxFPS")
      if CurrentMaxFps > self.MaxFPSInMatch then
        GameInstance:ExecuteCMD("t.MaxFPS", self.MaxFPSInMatch)
        print(bWriteLog and string.format("GameStateBase:OnRep_MaxFPSInMatch, ExecuteCMD t.MaxFPs to [%d]", self.MaxFPSInMatch))
      end
      print(bWriteLog and string.format("GameStateBase:OnRep_MaxFPSInMatch, update t.MaxFPs to [%d]", self.MaxFPSInMatch))
    end
  end
end
function GameStateBase:ReportPlayersNumberWhoSawFireworks()
  if CGameState and CGameState:GetGameModeState() == "FinishedState" then
    print(bWriteLog and "GameStateBase:ReportPlayersNumberWhoSawFireworks, In FinishedState")
    return
  end
  local PlayersNumber = 0
  local NotAliveNumber = 0
  local PlayerArray = Game:GetAllPlayerPawns()
  for i = 0, PlayerArray:Num() - 1 do
    local Pawn = PlayerArray:Get(i)
    if Pawn and slua.isValid(Pawn) and Game:IsPlayer(Pawn) and self:IsSeeingFirework(Pawn) then
      local uPlayerState = Pawn:GetPlayerStateSafety()
      if uPlayerState and slua.isValid(uPlayerState) then
        if uPlayerState:IsAlive() then
          PlayersNumber = PlayersNumber + 1
        else
          NotAliveNumber = NotAliveNumber + 1
        end
      end
    end
  end
  print(bWriteLog and "GameStateBase:ReportPlayersNumberWhoSawFireworks, PlayersNumber = " .. tostring(PlayersNumber) .. ", NotAliveNumber = " .. tostring(NotAliveNumber))
  if 0 < PlayersNumber then
    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    if DSCommonTLogSubsystem then
      DSCommonTLogSubsystem:AddCommonTLog(489, PlayersNumber, true)
    end
  end
end
function GameStateBase:IsSeeingFirework(Pawn)
  return true
end
function GameStateBase:HandleOnDSOptimGrayPublishFlagsChanged()
  if Client then
    if Client.IsEnableDSGrayPublishFlag(2199023255552) or Client.IsEditor() then
      KismetSystemLibrary.ExecuteConsoleCommand(self, "chara.enablevehiclerep 0")
    end
    if Client.IsEnableDSGrayPublishFlag(1048576) or Client.IsEditor() then
      KismetSystemLibrary.ExecuteConsoleCommand(self, "p.DelayNotifyComponentOverlap 1")
      KismetSystemLibrary.ExecuteConsoleCommand(self, "p.DebugDelayNotifyComponentOverlap 1")
    end
    if Client.IsEnableDSGrayPublishFlag(134217728) or Client.IsEditor() then
      KismetSystemLibrary.ExecuteConsoleCommand(self, "Vehicle.Protection.ImpulseImpl 1")
    end
  end
end
function GameStateBase:ReceiveBeginPlay()
  print(bWriteLog and "GameStateBase:ReceiveBeginPlay()")
  GameStateBase.__super.ReceiveBeginPlay(self)
  KismetSystemLibrary.ExecuteConsoleCommand(self, "GunCollision.BulletTrajectoryTolerateLength 100")
  KismetSystemLibrary.ExecuteConsoleCommand(self, "char.ViewSelfOnDeathReplayIfNoAttacker 0")
  if Server and Server.IsEnableDSGrayPublishFlag(1048576) then
    KismetSystemLibrary.ExecuteConsoleCommand(self, "p.DelayNotifyComponentOverlap 1")
    KismetSystemLibrary.ExecuteConsoleCommand(self, "p.DebugDelayNotifyComponentOverlap 1")
    print(bWriteLog and "GameStateBase:_PostConstruct, p.DelayNotifyComponentOverlap 1")
  end
  if Server and Server.IsEnableDSGrayPublishFlag(134217728) then
    KismetSystemLibrary.ExecuteConsoleCommand(self, "Vehicle.Protection.ImpulseImpl 1")
  end
  if Server and (not Server.IsEnableDSGrayPublishFlag(16777216) or IsEditor) then
    KismetSystemLibrary.ExecuteConsoleCommand(self, "slua.LuaParamDefaultValueMetas 0")
  end
  self:HandleOnDSOptimGrayPublishFlagsChanged()
  self.GameplayData = require("GameLua.GameCore.Data.GameplayData")
  if self.GameplayData then
    self.GameplayData.BindGameState(self.Object)
  end
  local WeaponSystem = require("GameLua.GameCore.Module.Weapon.WeaponSystem")
  WeaponSystem:InitWeaponAttrReloadTable(self.Object)
  self:RegistEvent()
  self:Init()
  if self:HasAuthority() then
    local Config = require("GameLua.Mod.BaseMod.DS.Config.SelfRescueConfig")
    self:UpdateSelfRescueEndTime(Config.SelfRescueInvalidTime)
    local GameMode = CGameMode
    if GameMode and GameMode.CircleMgr then
      GameMode.CircleMgr.bEnableWorldTickTime = false
      self:AddControlEvent(GameMode.CircleMgr, "OnCircleInfoChanged", self.OnCircleInfoChanged, self)
    end
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    if DSReviveSubsystem and DSReviveSubsystem:IsOpenedBySubModeId() == true then
      self.bHaveRevive = true
    end
  end
  if not Client then
    self.nBattleType = ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.battle_type or 0
    print(bWriteLog and string.format("GameStateBase:ReceiveBeginPlay, nBattleType[%d]", self.nBattleType))
    self.MatchZoneId = ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.zone_id or 0
    print(bWriteLog and "GameStateBase:ReceiveBeginPlay, MatchZoneId = " .. tostring(self.MatchZoneId))
  end
  if self.hasAuthority then
    local RoomType = ""
    if ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.room_type then
      RoomType = ServerDataMgr.SyncGameParams.room_type
      log_tree("GameStateBase:ReceiveBeginPlay ServerDataMgr.SyncGameParams", ServerDataMgr.SyncGameParams)
    end
    print(bWriteLog and string.format("GameStateBase:ReceiveBeginPlay, RoomType: %s", RoomType))
    if RoomType == "match" and ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.battle_custom_cfg and ServerDataMgr.SyncGameParams.battle_custom_cfg.FrameLimit then
      self.MaxFPSInMatch = ServerDataMgr.SyncGameParams.battle_custom_cfg.FrameLimit
      print(bWriteLog and string.format("GameStateBase:ReceiveBeginPlay, MaxFPSInMatch[%d]", self.MaxFPSInMatch))
    end
  end
end
function GameStateBase:UpdateSelfRescueEndTime(InvalidTime)
  local ClearTime = InvalidTime or 0
  local ReadyStateTime = math.floor(Game:GetReadyTimeBeforePlane() + 0.5)
  self.SelfRescueEndTime = ClearTime + ReadyStateTime
  print(bWriteLog and "GameStateBase:UpdateSelfRescueEndTime, InvalidTime = " .. tostring(InvalidTime) .. ", SelfRescueEndTime = " .. tostring(self.SelfRescueEndTime))
end
function GameStateBase:OnRep_SelfRescueEndTime()
  print(bWriteLog and "GameStateBase:OnRep_SelfRescueEndTime, SelfRescueEndTime = " .. tostring(self.SelfRescueEndTime))
end
function GameStateBase:OnRep_bHaveRevive()
  print(bWriteLog and "GameStateBase:OnRep_SelfRescueEndTime, bHaveRevive = " .. tostring(self.bHaveRevive))
  local SuperData = self:GetSuperData()
  SuperData.bHaveRevive = self.bHaveRevive
end
function GameStateBase:ReceiveEndPlay(nDeltaSeconds)
  print(bWriteLog and "GameStateBase:ReceiveEndPlay()")
  if self.SkillManagerEntry then
    self.SkillManagerEntry:Clear()
  end
  if Client then
    local CISDrinkSystem = SubsystemMgr:Get("CISDrinkSystem")
    if CISDrinkSystem then
      CISDrinkSystem:ResetTableData()
    end
    local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
    if slua.isValid(SettingSubsystem_CPP) and SettingSubsystem_CPP.ClearSettingDataForReport then
      SettingSubsystem_CPP:ClearSettingDataForReport()
    end
  end
  self._SuperData = nil
  GameStateBase.__super.ReceiveEndPlay(self, nDeltaSeconds)
end
function GameStateBase:RegistEvent()
  print(bWriteLog and "GameStateBase:RegistEvent()")
  if not Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_SKILLBUFF, EVENTID_SKILLEVENT_TRIGGER_SUCCESS, self.OnSkillTriggerSuccess, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChange, self)
  end
end
function GameStateBase:OnGameModeStateChange(_, _, sState)
  print(bWriteLog and "GameStateBase:OnGameModeStateChange", sState)
  if sState == "FightingState" then
    self.EnterFightingTime = CGameState:GetServerWorldTimeSeconds()
  elseif sState == "FinishedState" and slua.isValid(CGameWorld) and slua.isValid(CGameWorld.NetDriver) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "Log LogRep Log")
    CGameWorld.NetDriver:PrintRPCFunctionCallInfo()
    UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "Log LogRep Log")
  end
end
function GameStateBase:GetGameState()
  local uGameState = CGameState
  if uGameState == nil then
    uGameState = slua_GameFrontendHUD:GetGameState()
  end
  return uGameState
end
function GameStateBase:Init()
  self.bLuaGameStateInit = true
  self.bIsClient = Client ~= nil
  local PlayerEventSubsystem = SubsystemMgr:Get("PlayerEventSystem")
  if PlayerEventSubsystem then
    PlayerEventSubsystem:OnInit()
  end
end
function GameStateBase:GetSuperData()
  if self._SuperData then
    return self._SuperData
  end
  local SuperData = require("common.super_data")
  self._SuperData = SuperData.CreateSuperData(self:_DataDefine())
  return self._SuperData
end
function GameStateBase:_DataDefine()
  return {}
end
function GameStateBase:GetCharacter(nPlayerKey)
  if self.GameplayData == nil then
    self.GameplayData = require("GameLua.GameCore.Data.GameplayData")
  end
  local uFindCharacter = self.GameplayData.GetPlayerCharacter(nPlayerKey)
  if slua.isValid(uFindCharacter) then
    return uFindCharacter
  else
    print(bWriteLog and "GameStateBase:GetCharacter nil nPlayerKey:", nPlayerKey)
  end
end
function GameStateBase:GetAllCharacters()
  if self.GameplayData == nil then
    self.GameplayData = require("GameLua.GameCore.Data.GameplayData")
  end
  return self.GameplayData.GetAllPlayerCharacters()
end
function GameStateBase:SetCodeState(nCode, bState)
  self.CodeRecord[nCode] = bState
end
function GameStateBase:IsCodeOpen(nCode)
  if not nCode then
    return true
  end
  if nCode <= 0 then
    return true
  end
  if not self.CodeRecord[nCode] then
    return false
  end
  return self.CodeRecord[nCode]
end
function GameStateBase:OnSkillTriggerSuccess(_, _, PlayerUID, SkillID)
  if not Client then
    print(bWriteLog and "GameStateBase:OnSkillTriggerSuccess PlayerUID:" .. PlayerUID .. " SkillID:" .. tostring(SkillID))
    local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
    PlayerDataMgr.AddSkillTriggerSuccessTLog(tonumber(PlayerUID), SkillID)
    local uPlayerState = CGameState:GetPlayerStateByUID(tonumber(PlayerUID))
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralTLog(4, SkillID, nil, nil, 1, false)
    end
  end
end
function GameStateBase:SetReviveEndTime(nTime)
  print(bWriteLog and "GameStateBase:SetReviveEndTime")
  if self.ReviveState then
    return self.ReviveState:SetReviveEndTime(nTime)
  end
end
function GameStateBase:GetReviveEndTime()
  if self.ReviveState then
    return self.ReviveState:GetReviveEndTime()
  end
  return 0
end
function GameStateBase:CheckReviveTimeEnd()
  local ReviveState = self.ReviveState
  if ReviveState then
    return ReviveState:CheckReviveTimeEnd()
  end
  return true
end
function GameStateBase:IsEnableRedirectItemIdToAvatarID()
  if self.GlobalAvatar then
    return self.GlobalAvatar:IsEnableRedirectItemIdToAvatarID()
  end
end
function GameStateBase:GetRedirectAvatarID(InItemID)
  if self.GlobalAvatar then
    return self.GlobalAvatar:GetRedirectAvatarID(InItemID)
  end
end
function GameStateBase:RoomTypeChanged()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_GAMESTATE_ROOMTYPECHANGE)
end
function GameStateBase:QueryHitData(QueryKey, HitPlayerKey, Duration, WeaponID)
  print(bWriteLog and "GameStateBase:QueryHitData", QueryKey, HitPlayerKey, Duration, WeaponID)
  QueryKey = tonumber(QueryKey)
  HitPlayerKey = tonumber(HitPlayerKey)
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  if WeaponRecordSubSystem and QueryKey and HitPlayerKey then
    return WeaponRecordSubSystem:QueryHitData(QueryKey, HitPlayerKey, Duration, WeaponID)
  end
  return {}
end
function GameStateBase:GetWeaponDamageFromRecord(PlayerKey, TargetWeaponType)
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  if WeaponRecordSubSystem then
    return WeaponRecordSubSystem:GetWeaponDamageFromRecord(PlayerKey, TargetWeaponType)
  end
end
function GameStateBase:GetGeneralMapMarkSyncActor()
  if not Client then
    local MapMarkSyncActorCls = import("MapMarkSyncActor")
    local EMarkFastSyncTarget = import("EMarkFastSyncTarget")
    if self.MapMarkSyncActor == nil then
      self.MapMarkSyncActor = CGameWorld:SpawnActor(MapMarkSyncActorCls, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
      if not slua.isValid(self.MapMarkSyncActor) then
        print(bWriteLog and "GameStateBase:GetGeneralMapMarkSyncActor", "MapMarkSyncActor is nil")
        self.MapMarkSyncActor = nil
        return nil
      end
      self.MapMarkSyncActor.TargetType = EMarkFastSyncTarget.All
    end
    return self.MapMarkSyncActor
  end
end
function GameStateBase:OnCircleInfoChanged(InCircleMgr, CircleInfoType, Time)
  if slua.isValid(InCircleMgr) then
    if not self.CircleInfo then
      self.CircleInfo = "circleInfo|"
      if InCircleMgr.TimerRegister:Num() > 0 then
        local CircleStepCount = 4
        local TimerRegisterLen = InCircleMgr.TimerRegister:Num()
        local CircleRegisterInfoTable = {}
        local CircleContentParams = ""
        for CurrentIndex = 0, TimerRegisterLen / CircleStepCount - 1 do
          CircleRegisterInfoTable = {}
          table.insert(CircleRegisterInfoTable, "" .. CurrentIndex)
          for InnerCurrentIndex = 0, 3 do
            for _, fTime in pairs(InCircleMgr.TimerRegister:Get(CurrentIndex * CircleStepCount + InnerCurrentIndex).times) do
              table.insert(CircleRegisterInfoTable, "" .. math.floor(fTime))
            end
          end
          CircleContentParams = table.concat(CircleRegisterInfoTable, ",")
          self.CircleInfo = self.CircleInfo .. CircleContentParams
          self.CircleInfo = self.CircleInfo .. ";"
        end
      end
    else
      self.CircleInfo = self.CircleInfo .. ";"
    end
    local ContentTable = {}
    table.insert(ContentTable, "" .. CircleInfoType)
    table.insert(ContentTable, "" .. Time)
    table.insert(ContentTable, "" .. math.floor(InCircleMgr:GetWorldEffectiveTimeDilation()))
    table.insert(ContentTable, "" .. math.floor(self:GetServerWorldTimeSeconds()))
    table.insert(ContentTable, "" .. math.floor(InCircleMgr:GetTimerCurTime()))
    local ContentParams = table.concat(ContentTable, ",")
    self.CircleInfo = self.CircleInfo .. ContentParams
    print(bWriteLog and "GameStateBase:OnCircleInfoChanged:", self.CircleInfo)
  end
end
function GameStateBase:GetCircleInfo()
  return self.CircleInfo
end
function GameStateBase:GetLuaWonderfulAdditionMap()
  local AdditionMap = {}
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  print(bWriteLog and "GameStateBase:GetLuaWonderfulAdditionMap-", uPlayerController)
  if not slua.isValid(uPlayerController) or not slua.isValid(uPlayerController.PlayerState) then
    return AdditionMap
  end
  local PeakSegmentID = uPlayerController.PlayerState.PeakSegmentID
  if PeakSegmentID and 0 < PeakSegmentID then
    AdditionMap.  end
  log_tree(bWriteLog and "GameStateBase:GetLuaWonderfulAdditionMap PeakSegmentID:" .. PeakSegmentID .. "name:" .. uPlayerController.PlayerState.PlayerName, AdditionMap)
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uClientInGameReplay = uGameInstance:GetClientInGameReplay()
    if slua.isValid(uClientInGameReplay) and uClientInGameReplay.BattleWonderfulInfo then
      local WonderfulPeriodNum = uClientInGameReplay.BattleWonderfulInfo.WonderfulPeriodInfoArray:Num()
      print(bWriteLog and "GameStateBase:GetLuaWonderfulAdditionMap WonderfulPeriodNum:" .. WonderfulPeriodNum)
      if 0 < WonderfulPeriodNum then
        AdditionMap.      end
    end
  end
  return AdditionMap
end
function GameStateBase:GetCurrentModeType()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local _, ModType2 = GameMainConfig.GetModType()
  if ModType2 == nil or ModType2 == "" then
    ModType2 = GameMainConfig.GetMapType()
    if ModType2 == nil or ModType2 == "" or ModType2 == "UnknownMap" then
      print(bWriteLog and "GameStateBase:GetCurrentModeType, ModType2 = " .. tostring(ModType2) .. ", and set to Default.")
      ModType2 = "Default"
    else
      print(bWriteLog and "GameStateBase:GetCurrentModeType, GetMapType ModType2 = " .. tostring(ModType2))
    end
  else
    print(bWriteLog and "GameStateBase:GetCurrentModeType, ModType2 = " .. tostring(ModType2))
  end
  print(bWriteLog and "GameStateBase:GetCurrentModeType:" .. tostring(ModType2))
  return ModType2
end
function GameStateBase:OnPhysicsAggregateBoundsInflateExt(InComponent, InData)
  if not Client or not slua.isValid(InComponent) then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local IsPlayingPlayback = slua.isValid(GameInstance) and GameInstance:IsPlayingAnyPlayback()
  if Client.IsDevelopment() and not IsPlayingPlayback then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local ComponentName = KismetSystemLibrary.GetDisplayName(InComponent)
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(1, "Physical bounds abnormally expanded" .. CGame:GetCurDateTimeString(), string.format([[
Please get the log and contact <walkercbwu> for confirmation:
%s
%s]], ComponentName, InData))
  end
end
function GameStateBase:MultiCast_GenericRPC(ID, Object, Bytes)
  local GenericRPCEnums = require("GameLua.Mod.BaseMod.GamePlay.GenericRPC.GenericRPCEnums")
  local GenericRPCUtil = require("GameLua.Mod.BaseMod.GamePlay.GenericRPC.GenericRPCUtil")
  GenericRPCUtil._OnRecv(self, ID, GenericRPCEnums.EGenericRPCDirection.Multicast, Bytes, Object)
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CGameStateBase = class(CActorBase, nil, GameStateBase)
return require("combine_class").DeclareFeature(CGameStateBase, {
  {
    GlobalAvatar = "GameLua.GameCore.Feature.GlobalAvatarFeature"
  },
  {
    ReviveState = "GameLua.Mod.BaseMod.GamePlay.Revive.ReviveGameStateFeature"
  },
  {
    KingEliminationFeature = "GameLua.GameCore.Feature.KingEliminationFeature"
  },
  {
    FatalDamageFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.GameStateFatalDamageFeature"
  }
}, "GameStateBase")