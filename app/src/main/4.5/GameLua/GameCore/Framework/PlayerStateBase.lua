local PlayerStateBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {
    "OnbVoiceChangedChange",
    "EVENTID_PLAYER_REVIVAL_FINISH",
    "OnParachuteCaptainChanged",
    "OnAIAllocateSuccess"
  }
}
local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local EGameModeType = import("EGameModeType")
local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
local GameplayStatics = import("GameplayStatics")
local version_util = require("client.common.version_util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local ELifetimeCondition = import("ELifetimeCondition")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EnablePlayerUnderAttackGameModeType = {
  [EGameModeType.ETypicalGameMode] = true,
  [EGameModeType.EXAndT] = true,
  [EGameModeType.EDeathMatchGameMode] = true,
  [EGameModeType.EFourInOneGameMode] = true
}
PlayerStateBase.ServerRPC.ReportClientPing = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
PlayerStateBase.ServerRPC.ServerRPC_RecordOperationCount = {
  Reliable = true,
  Params = {
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    UEnums.EPropertyClass.Bool
  }
}
PlayerStateBase.ServerRPC.ServerRPC_EnableVoiceChanger = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
PlayerStateBase.ServerRPC.ServerRPC_AddCommonTLogData = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Int
  }
}
PlayerStateBase.ClientRPC.ClientRPCTeammateRealExit = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.UInt32
  }
}
PlayerStateBase.ClientRPC.ClientRPC_VersionTaskChanged = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
PlayerStateBase.MulticastRPC.MultiCast_GenericRPC = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Byte
    }
  }
}
function PlayerStateBase:ClientRPCTeammateRealExit(TeamIndex, PlayerKey)
  print(bWriteLog and "PlayerStateBase:ClientRPCTeammateRealExit, TeamIndex = " .. tostring(TeamIndex) .. ", PlayerKey = " .. tostring(PlayerKey))
  self.RealExit_  self.RealExit_  local SuperData = self:GetSuperData()
  SuperData.RealExitTeamNum = SuperData.RealExitTeamNum + 1
end
function PlayerStateBase:ctor(selfType)
  print(bWriteLog and "PlayerStateBase:ctor")
  self._SuperData = nil
  self.TlogData = {
    VehicleSpeedKills = 0,
    HurtByPlayers = {}
  }
  self.SuspiciousFlag = nil
  self.nLeftBuyLifeCounts = 0
  self.nReviveType = 0
  self.ClientPing = 0
  self.ClientDisplayPing = 0
  self.nWingman_skin = 0
  self.XSuitIconId = 0
  self.NicknameColor = 0
  self.CollectScore = 0
  self.SeasonCollectScore = 0
  self.CollectScorePrivacy = false
  self.bShowSubscribe = false
  self.bEnableTireLight = false
  self.EliminationKingEffectID = 0
  self.AliasData = nil
  self.GeneralTLogData = nil
  self.bIsFirstPossess = true
  self.IntimacyValue = 0
  self.IntimacyRelation = 0
  self.IntimacyTargetUID = 0
  self.PeakSegmentID = 0
  self.bCanSelfRevival = false
  self.bIsKingElimination = false
  self.bDisablePetSpectate = false
  self.AllowedGeneralCounter = {}
  self.GeneralCounterKey = slua.Array(UEnums.EPropertyClass.Int)
  self.GeneralCounterValue = slua.Array(UEnums.EPropertyClass.Int)
  local SuperData = self:GetSuperData()
  SuperData.nLeftBuyLifeCounts = self.nLeftBuyLifeCounts
  SuperData.bIsLostConnection = false
  SuperData.RealExitTeamNum = 0
  SuperData.HeadPositionTagCount = 0
  SuperData.bIsKingElimination = self.bIsKingElimination
  SuperData.bIsGeneralCounterChange = false
  self.bCanBeRevived = true
  self.VersionTaskTable = {}
  self.VersionTaskIDs = {}
  self.bNeedInitVersionTask = false
  self.bHasSendOperationResult = false
  self.OperatingFrequencyReport = {}
  self.PromotionLayer = 0
  self.CurSegLevel = 0
  self.UnlockSegLevel = 0
  self.bPromotionProtected = false
  self.PromotionProgressCount = 0
  self.PromotionNeedPersonRank = 0
  self.DiedPlayerCount = 0
  self.CardCollectCareerScore = 0
  self.CabinShowActorID = 0
  self._SquadBroadcastStyleIdsArrived = false
  self._SquadBroadcastTeamNamesArrived = false
  self.SquadBroadcastMaxCount = 2
end
function PlayerStateBase:InitGeneralCounterFromServer()
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local GeneralCounter = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(self.UID), ExtendAttribute.GeneralCounter)
  if GeneralCounter then
    for k, v in pairs(GeneralCounter) do
      if k and v and self:IsGeneralCounterAlreadyExist(k) == false then
        self.GeneralCounterKey:Add(k)
        self.GeneralCounterValue:Add(v)
      end
    end
  end
  print(bWriteLog and "PlayerStateBase:InitGeneralCounterFromServer, Num = " .. tostring(self.GeneralCounterKey:Num()))
  self:PrintGeneralCounter()
  if self.ThemeTaskFeature and self.ThemeTaskFeature.InitRewardState then
    self.ThemeTaskFeature:InitRewardState()
  end
end
function PlayerStateBase:OnLostConnectionStateChange()
  local SuperData = self:GetSuperData()
  SuperData.bIsLostConnection = self.isLostConnection
end
function PlayerStateBase:IsGeneralCounterAlreadyExist(TLogID)
  local Hit = false
  local Num = self.GeneralCounterKey:Num()
  for index = 0, Num - 1 do
    local Key = self.GeneralCounterKey:Get(index)
    if Key == TLogID then
      Hit = true
      print(bWriteLog and "PlayerStateBase:IsGeneralCounterAlreadyExist, Hit = " .. tostring(Hit) .. ", TLogID = " .. tostring(TLogID))
      break
    end
  end
  return Hit
end
function PlayerStateBase:GetValueByTLogIDInCounter(TLogID)
  local Value = 0
  local Hit = false
  local Num = self.GeneralCounterKey:Num()
  for index = 0, Num - 1 do
    local Key = self.GeneralCounterKey:Get(index)
    if Key == TLogID then
      Value = self.GeneralCounterValue:Get(index)
      Hit = true
      break
    end
  end
  print(bWriteLog and "PlayerStateBase:GetValueByTLogIDInCounter, TLogID = " .. tostring(TLogID) .. ", Value = " .. tostring(Value) .. ", Hit = " .. tostring(Hit))
  return Value
end
function PlayerStateBase:PrintGeneralCounter()
  local Num = self.GeneralCounterKey:Num()
  print(bWriteLog and "PlayerStateBase:PrintGeneralCounter, Num = " .. tostring(Num) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  for index = 0, Num - 1 do
    local Key = self.GeneralCounterKey:Get(index)
    local Value = self.GeneralCounterValue:Get(index)
    print(bWriteLog and "PlayerStateBase:PrintGeneralCounter, Key = " .. tostring(Key) .. ", Value = " .. tostring(Value))
  end
end
function PlayerStateBase:OnRep_GeneralCounterKey()
  local SuperData = self:GetSuperData()
  SuperData.bIsGeneralCounterChange = not SuperData.bIsGeneralCounterChange
end
function PlayerStateBase:OnRep_GeneralCounterValue()
  print(bWriteLog and "PlayerStateBase:OnRep_GeneralCounterValue, KeyNum = " .. tostring(self.GeneralCounterKey:Num()) .. ", ValueNum = " .. tostring(self.GeneralCounterValue:Num()))
  self:PrintGeneralCounter()
  local SuperData = self:GetSuperData()
  SuperData.bIsGeneralCounterChange = not SuperData.bIsGeneralCounterChange
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_THEMETASKGENERALCOUNTER_REP, self.Object)
end
function PlayerStateBase:OnAllowToAddGeneralCount(TLogID)
  local Hit = false
  local Result = true
  local DependentID = 0
  if self.AllowedGeneralCounter[TLogID] then
    return Result
  else
    local ThemeTaskInfo = CDataTable.GetTable("ThemeTaskInfo")
    for ID, Value in pairs(ThemeTaskInfo) do
      if Value.TLogID == TLogID then
        DependentID = Value.PreTaskID
        Hit = true
        break
      end
    end
    if 0 < DependentID then
      local Info = CDataTable.GetTableData("ThemeTaskInfo", DependentID)
      if Info then
        local TargetNum = Info.AimProgress
        if TargetNum and 0 < TargetNum then
          local CurNum = self:GetValueByTLogIDInCounter(Info.TLogID)
          if TargetNum > CurNum then
            Result = false
          else
            self.AllowedGeneralCounter[TLogID] = true
          end
        else
          print(bWriteLog and "PlayerStateBase:OnAllowToAddGeneralCount, TargetNum = " .. tostring(TargetNum) .. " when DependentID = " .. tostring(DependentID))
        end
      else
        print(bWriteLog and "PlayerStateBase:OnAllowToAddGeneralCount, Info = nil when DependentID = " .. tostring(DependentID))
      end
    end
  end
  print(bWriteLog and "PlayerStateBase:OnAllowToAddGeneralCount, TLogID = " .. tostring(TLogID) .. ", Result = " .. tostring(Result) .. ", Hit = " .. tostring(Hit))
  return Result
end
function PlayerStateBase:OnHandleGenerelCountChanged(TLogID, DeltaCnt, CurCnt)
  self:RecordGeneralCountTime(TLogID, DeltaCnt)
  if TLogID and CurCnt then
    local NeedCache = false
    local ThemeTaskInfo = CDataTable.GetTable("ThemeTaskInfo")
    for ID, Value in pairs(ThemeTaskInfo) do
      if Value.TLogID == TLogID then
        NeedCache = true
        break
      end
    end
    local bIsVersionTask = false
    for k, v in pairs(self.VersionTaskIDs) do
      if v == TLogID then
        NeedCache = true
        bIsVersionTask = true
        break
      end
    end
    print(bWriteLog and "PlayerStateBase:OnHandleGenerelCountChanged, TLogID = " .. tostring(TLogID) .. ", DeltaCnt = " .. tostring(DeltaCnt) .. ", CurCnt = " .. tostring(CurCnt) .. ", NeedCache = " .. tostring(NeedCache))
    if not NeedCache then
      return
    end
    self:PrintGeneralCounter()
    local Hit = false
    local Num = self.GeneralCounterKey:Num()
    local NewValue = 0
    for index = 0, Num - 1 do
      local Key = self.GeneralCounterKey:Get(index)
      if Key == TLogID then
        NewValue = self.GeneralCounterValue:Get(index) + DeltaCnt
        self.GeneralCounterValue:Set(index, NewValue)
        Hit = true
        break
      end
    end
    if Hit == false then
      NewValue = CurCnt
      self.GeneralCounterKey:Add(TLogID)
      self.GeneralCounterValue:Add(DeltaCnt)
    end
    self:PrintGeneralCounter()
    if bIsVersionTask then
      self:ClientRPC_VersionTaskChanged(TLogID, NewValue)
    end
  end
  if self.ThemeTaskFeature and self.ThemeTaskFeature.GeneralCountChanged then
    self.ThemeTaskFeature:GeneralCountChanged(TLogID, CurCnt)
  end
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_THEMETASKGENERALCOUNTER_REP, self.Object, TLogID)
end
function PlayerStateBase:RecordGeneralCountTime(TLogID, DeltaCnt)
  if not Client then
    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    if DSCommonTLogSubsystem then
      DSCommonTLogSubsystem:RecordGeneralCountTime(self.Object, TLogID, DeltaCnt)
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local TLogConfig = GamePlayTools.GetCurrentConfig("TLogConfig")
      if TLogConfig and TLogConfig.PlayerTlogToRoundTlog and TLogConfig.PlayerTlogToRoundTlog[TLogID] then
        DSCommonTLogSubsystem:AddCommonTLog(TLogConfig.PlayerTlogToRoundTlog[TLogID], DeltaCnt, false)
      end
    end
  end
end
function PlayerStateBase:AddGeneralTLog(Type, Param1, Param2, Param3, Count, bRest)
  if Type == nil or Count == nil or type(Count) ~= "number" then
    print(bWriteLog and "PlayerStateBase:AddGeneralTLog, Type == nil or Count == nil or type[Count] ~= number")
    return
  end
  if self.GeneralTLogData == nil then
    self.GeneralTLogData = {}
  end
  if self.GeneralTLogData[Type] == nil then
    self.GeneralTLogData[Type] = {}
  end
  if Param1 == nil and Param2 == nil and Param3 == nil then
    if self.GeneralTLogData[Type][0] == nil or bRest then
      local Delta      if self.GeneralTLogData[Type][0] then
        DeltaCount = Count - self.GeneralTLogData[Type][0]
      end
      self.GeneralTLogData[Type][0] = Count
      self:UpdateTaskProgress(Type, 0, 0, 0, DeltaCount)
    else
      local TypeOfCached = type(self.GeneralTLogData[Type][0])
      local TypeOfCount = type(Count)
      if TypeOfCached == TypeOfCount then
        if TypeOfCached == "number" then
          self.GeneralTLogData[Type][0] = self.GeneralTLogData[Type][0] + Count
          self:UpdateTaskProgress(Type, 0, 0, 0, Count)
        else
          print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCount = " .. tostring(TypeOfCount))
        end
      else
        print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCached = " .. tostring(TypeOfCached) .. ", but TypeOfCount = " .. tostring(TypeOfCount))
      end
    end
  elseif Param2 == nil and Param3 == nil then
    if self.GeneralTLogData[Type][Param1] == nil or bRest then
      local Delta      if self.GeneralTLogData[Type][Param1] then
        DeltaCount = Count - self.GeneralTLogData[Type][Param1]
      end
      self.GeneralTLogData[Type][Param1] = Count
      self:UpdateTaskProgress(Type, Param1, 0, 0, DeltaCount)
    else
      local TypeOfCached = type(self.GeneralTLogData[Type][Param1])
      local TypeOfCount = type(Count)
      if TypeOfCached == TypeOfCount then
        if TypeOfCached == "number" then
          self.GeneralTLogData[Type][Param1] = self.GeneralTLogData[Type][Param1] + Count
          self:UpdateTaskProgress(Type, Param1, 0, 0, Count)
        else
          print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCount = " .. tostring(TypeOfCount))
        end
      else
        print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCached = " .. tostring(TypeOfCached) .. ", but TypeOfCount = " .. tostring(TypeOfCount))
      end
    end
  elseif Param3 == nil then
    if self.GeneralTLogData[Type][Param1] == nil then
      self.GeneralTLogData[Type][Param1] = {}
    end
    if self.GeneralTLogData[Type][Param1][Param2] == nil or bRest then
      local Delta      if self.GeneralTLogData[Type][Param1][Param2] then
        DeltaCount = Count - self.GeneralTLogData[Type][Param1][Param2]
      end
      self.GeneralTLogData[Type][Param1][Param2] = Count
      self:UpdateTaskProgress(Type, Param1, Param2, 0, DeltaCount)
    else
      local TypeOfCached = type(self.GeneralTLogData[Type][Param1][Param2])
      local TypeOfCount = type(Count)
      if TypeOfCached == TypeOfCount then
        if TypeOfCached == "number" then
          self.GeneralTLogData[Type][Param1][Param2] = self.GeneralTLogData[Type][Param1][Param2] + Count
          self:UpdateTaskProgress(Type, Param1, Param2, 0, Count)
        else
          print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCount = " .. tostring(TypeOfCount))
        end
      else
        print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCached = " .. tostring(TypeOfCached) .. ", but TypeOfCount = " .. tostring(TypeOfCount))
      end
    end
  else
    if self.GeneralTLogData[Type][Param1] == nil then
      self.GeneralTLogData[Type][Param1] = {}
    end
    if self.GeneralTLogData[Type][Param1][Param2] == nil then
      self.GeneralTLogData[Type][Param1][Param2] = {}
    end
    if self.GeneralTLogData[Type][Param1][Param2][Param3] == nil or bRest then
      local Delta      if self.GeneralTLogData[Type][Param1][Param2][Param3] then
        DeltaCount = Count - self.GeneralTLogData[Type][Param1][Param2][Param3]
      end
      self.GeneralTLogData[Type][Param1][Param2][Param3] = Count
      self:UpdateTaskProgress(Type, Param1, Param2, Param3, DeltaCount)
    else
      local TypeOfCached = type(self.GeneralTLogData[Type][Param1][Param2][Param3])
      local TypeOfCount = type(Count)
      if TypeOfCached == TypeOfCount then
        if TypeOfCached == "number" then
          self.GeneralTLogData[Type][Param1][Param2][Param3] = self.GeneralTLogData[Type][Param1][Param2][Param3] + Count
          self:UpdateTaskProgress(Type, Param1, Param2, Param3, Count)
        else
          print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCount = " .. tostring(TypeOfCount))
        end
      else
        print(bWriteLog and "PlayerStateBase:AddGeneralTLog, TypeOfCached = " .. tostring(TypeOfCached) .. ", but TypeOfCount = " .. tostring(TypeOfCount))
      end
    end
  end
end
function PlayerStateBase:UpdateTaskProgress(Type, Param1, Param2, Param3, DeltaCount)
  local Result, EventsID = Game:NeedReport(Type, Param1, Param2, Param3)
  if Result and EventsID and 0 < #EventsID then
    local TableStr = "return {" .. EventsID .. "}"
    local EventsIDTable = load(TableStr)()
    for k, v in pairs(EventsIDTable) do
      self:AddGeneralTLogJustForDelegate(v, DeltaCount, 0)
    end
  end
end
function PlayerStateBase:_PostConstruct()
  PlayerStateBase.__super._PostConstruct(self)
  self:InitVersionTask()
end
function PlayerStateBase:TestPromotionData()
  if not CGame:IsEditor() then
    return
  end
  if Client then
    return
  end
  self.PromotionLayer = 1
  self.CurSegLevel = 801
  self.UnlockSegLevel = 801
  self.bPromotionProtected = false
  self.PromotionProgressCount = 2
  self.PromotionNeedPersonRank = 15
end
function PlayerStateBase:InitRevivalCountImpl(InController, InCharacter)
  print(bWriteLog and "PlayerStateBase:InitRevivalCountImpl, self.bIsFirstPossess = " .. tostring(self.bIsFirstPossess))
  if self.bIsFirstPossess then
    local Need, IsAI = self:IsNeedInitRevivalCount(InController)
    if Need then
      self.bIsFirstPossess = false
      local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
      if DSReviveSubsystem and DSReviveSubsystem:GetInitRevivalCount() > 0 then
        local DefaultRevivalCount = DSReviveSubsystem:GetInitRevivalCount(UEnums.RevivalWay.General)
        if 0 < DefaultRevivalCount then
          self:SetRevivalCount(DefaultRevivalCount, InCharacter)
        end
        local DefaultBuyLifeCount = DSReviveSubsystem:GetInitRevivalCount(UEnums.RevivalWay.Store)
        if 0 < DefaultBuyLifeCount then
          if IsAI then
            local ReviveInfoConfig = DSReviveSubsystem:GetReviveInfoByModeType()
            if ReviveInfoConfig and ReviveInfoConfig.AIProbability then
              local AIProbability = ReviveInfoConfig.AIProbability.Store or -1
              math.randomseed(InCharacter.PlayerKey)
              local Temp = math.random()
              if AIProbability >= Temp then
                self:SetBuyReviveCount(DefaultBuyLifeCount, InCharacter)
                print(bWriteLog and "PlayerStateBase:InitRevivalCountImpl, " .. tostring(Temp) .. " <= " .. tostring(AIProbability) .. ", PlayerKey = " .. tostring(InCharacter.PlayerKey))
              else
                print(bWriteLog and "PlayerStateBase:InitRevivalCountImpl, " .. tostring(Temp) .. " > " .. tostring(AIProbability) .. ", PlayerKey = " .. tostring(InCharacter.PlayerKey))
              end
            end
          else
            self:SetBuyReviveCount(DefaultBuyLifeCount, InCharacter)
          end
        end
        if CGameState and CGameState.bReInitUIAfterReCreatePawn and CGameState.bReInitUIAfterReCreatePawn == true then
          CGameState.bReInitUIAfterReCreatePawn = false
        end
      else
        print(bWriteLog and "PlayerStateBase:InitRevivalCountImpl, DSReviveSubsystem = " .. tostring(DSReviveSubsystem))
      end
    else
      print(bWriteLog and "PlayerStateBase:InitRevivalCountImpl, Need = " .. tostring(Need) .. ", PlayerKey = " .. tostring(InCharacter.PlayerKey))
    end
  end
end
function PlayerStateBase:IsNeedInitRevivalCount(InController)
  local Result, IsAI = self:CanAddRevivalCount(InController)
  if Result == true then
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    if DSReviveSubsystem and DSReviveSubsystem:CanAddInitRevivalCount(InController) then
    else
      Result = false
    end
  end
  return Result, IsAI
end
function PlayerStateBase:CanAddRevivalCount(InController)
  if CGameState == nil or slua.isValid(CGameState) == false then
    print(bWriteLog and "PlayerStateBase:CanAddRevivalCount, return false because CGameState is invalid")
    return false
  end
  if CGameState:GetGameModeState() == "FinishedState" then
    print(bWriteLog and "PlayerStateBase:CanAddRevivalCount, return true because of FinishedState")
    return true
  end
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if DSReviveSubsystem then
    if DSReviveSubsystem:IsOpenedBySubModeId() == false then
      return false
    end
    if DSReviveSubsystem:GetRevivalClosedResult() == true then
      return false
    end
    if Game:IsClassOf(InController, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) then
      return true, false
    elseif Game:IsClassOf(InController, import("NewFakePlayerAIController")) and InController.IsMLAI and InController.FakePlayerBornType ~= 1 then
      return true, true
    end
  end
  return false
end
function PlayerStateBase:GetLifetimeReplicatedProps()
  print(bWriteLog and "PlayerStateBase:GetLifetimeReplicatedProps")
  return {
    {
      "SuspiciousFlag",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "nLeftBuyLifeCounts",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "bIsRealExit",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "nReviveType",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nVst_skin",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nWingman_skin",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "fDiedTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "XSuitIconId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "NicknameColor",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "CollectScore",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "SeasonCollectScore",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "CollectScorePrivacy",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bShowSubscribe",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bEnableTireLight",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "IntimacyValue",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "IntimacyRelation",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "IntimacyTargetUID",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int64
    },
    {
      "GeneralCounterKey",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "GeneralCounterValue",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "PeakSegmentID",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "bCanSelfRevival",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bIsKingElimination",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bDisablePetSpectate",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "EliminationKingEffectID",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "bNeedInitVersionTask",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "CurSegLevel",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "UnlockSegLevel",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "PromotionLayer",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "bPromotionProtected",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "PromotionProgressCount",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "PromotionNeedPersonRank",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "CabinShowActorID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "bVoiceChanged",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "SquadBroadcastStyleIds",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "SquadBroadcastTeamNames",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Str
    }
  }
end
function PlayerStateBase:SetCanSelfRevival(bCan)
  self.bCanSelfRevival = bCan
  print(bWriteLog and "PlayerStateBase:SetCanSelfRevival, bCan = " .. tostring(self.bCanSelfRevival) .. ", PlayerKey = " .. tostring(self.PlayerKey))
end
function PlayerStateBase:OnRep_bCanSelfRevival()
  print(bWriteLog and "PlayerStateBase:OnRep_bCanSelfRevival, bCan = " .. tostring(self.bCanSelfRevival) .. ", PlayerKey = " .. tostring(self.PlayerKey))
end
function PlayerStateBase:SetKingEliminationState(bIsKingElimination)
  self.  print(bWriteLog and "PlayerStateBase:SetKingEliminationState: ", self.bIsKingElimination, ", PlayerKey = ", self.PlayerKey)
end
function PlayerStateBase:OnRep_bIsKingElimination()
  local SuperData = self:GetSuperData()
  SuperData.bIsKingElimination = self.bIsKingElimination
  print(bWriteLog and "PlayerStateBase:OnRep_bIsKingElimination: ", self.bIsKingElimination, ", PlayerKey = ", self.PlayerKey)
end
function PlayerStateBase:SetCabinShowActorID(ActorID)
  print(bWriteLog and string.format("PlayerStateBase:SetCabinShowActorID - ActorID=%d", ActorID or 0))
  self.CabinShowActorID = ActorID or 0
  self:ForceNetUpdate()
end
function PlayerStateBase:OnRep_CabinShowActorID()
  print(bWriteLog and string.format("PlayerStateBase:OnRep_CabinShowActorID - CabinShowActorID=%d", self.CabinShowActorID))
end
function PlayerStateBase:OnRep_SquadBroadcastStyleIds()
  print(bWriteLog and string.format("PlayerStateBase:OnRep_SquadBroadcastStyleIds - Count=%d PlayerKey=%s", self.SquadBroadcastStyleIds:Num(), tostring(self.PlayerKey)))
  self._SquadBroadcastStyleIdsArrived = true
  self:_CheckSquadBroadcastReady()
end
function PlayerStateBase:OnRep_SquadBroadcastTeamNames()
  print(bWriteLog and string.format("PlayerStateBase:OnRep_SquadBroadcastTeamNames - Count=%d PlayerKey=%s", self.SquadBroadcastTeamNames:Num(), tostring(self.PlayerKey)))
  self._SquadBroadcastTeamNamesArrived = true
  self:_CheckSquadBroadcastReady()
end
function PlayerStateBase:_CheckSquadBroadcastReady()
  if not self._SquadBroadcastStyleIdsArrived or not self._SquadBroadcastTeamNamesArrived then
    return
  end
  print(bWriteLog and string.format("PlayerStateBase:_CheckSquadBroadcastReady - both arrays ready, Count=%d PlayerKey=%s", self.SquadBroadcastStyleIds:Num(), tostring(self.PlayerKey)))
end
function PlayerStateBase:GetSquadBroadcastList()
  if not Client then
    return nil
  end
  if not self._SquadBroadcastStyleIdsArrived or not self._SquadBroadcastTeamNamesArrived then
    return {}
  end
  local Result = {}
  local Count = math.min(self.SquadBroadcastStyleIds:Num(), self.SquadBroadcastTeamNames:Num())
  for i = 0, Count - 1 do
    Result[#Result + 1] = {
      style_id = self.SquadBroadcastStyleIds:Get(i),
      team_name = self.SquadBroadcastTeamNames:Get(i)
    }
  end
  return Result
end
function PlayerStateBase:OnRep_bVoiceChanged()
  print(bWriteLog and "PlayerStateBase:OnRep_bVoiceChanged: ", self.bVoiceChanged, ", PlayerKey = ", self.PlayerKey)
  self:LuaBroadcast("OnbVoiceChangedChange", self.bVoiceChanged)
end
function PlayerStateBase:OnRep_ParachuteCaptain()
  print(bWriteLog and string.format("PlayerStateBase:OnRep_ParachuteCaptain - bIsParachuteCaptain=%s, PlayerKey=%s", tostring(self.bIsParachuteCaptain), tostring(self.PlayerKey)))
  self:LuaBroadcast("OnParachuteCaptainChanged", self.bIsParachuteCaptain)
end
function PlayerStateBase:OnRep_PromotionLayer()
  local uPlayerController = GameplayStatics.GetPlayerController(self, 0)
  print(bWriteLog and string.format("PlayerStateBase:OnRep_PromotionLayer - PromotionLayer=%d, PlayerKey=%s %s", self.PromotionLayer, tostring(self.PlayerKey), tostring(slua.isValid(uPlayerController) and uPlayerController.PlayerKey)))
  if slua.isValid(uPlayerController) and uPlayerController.PlayerKey == self.PlayerKey and 0 < self.PromotionLayer then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if MainControlBaseUI then
      print(bWriteLog and "PlayerStateBase:OnRep_PromotionLayer, MainControlBaseUI is valid")
      MainControlBaseUI:UIMSG_GameModeDisplayNameChanged()
    else
      print(bWriteLog and "PlayerStateBase:OnRep_PromotionLayer, MainControlBaseUI is nil")
    end
  end
end
function PlayerStateBase:ServerRPC_EnableVoiceChanger(bVoiceChanged)
  self.end
function PlayerStateBase:ServerRPC_AddCommonTLogData(nTLogID, sInfoID, nCount)
  print(bWriteLog and string.format("PlayerStateBase:ServerRPC_AddCommonTLogData - nTLogID=%s nInfoID=%s nCount=%s", tostring(nTLogID), tostring(sInfoID), tostring(nCount)))
  if not self.CommonTLogDataMap then
    self.CommonTLogDataMap = {}
  end
  if not self.CommonTLogDataMap[nTLogID] then
    self.CommonTLogDataMap[nTLogID] = {}
  end
  local nPrev = self.CommonTLogDataMap[nTLogID][sInfoID] or 0
  self.CommonTLogDataMap[nTLogID][sInfoID] = nPrev + (nCount or 1)
end
function PlayerStateBase:FlushCommonTLogData()
  print(bWriteLog and string.format("PlayerStateBase:FlushCommonTLogData"))
  if not self.CommonTLogDataMap then
    return
  end
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if not DSCommonTLogSubsystem then
    return
  end
  for nTLogID, tInfoMap in pairs(self.CommonTLogDataMap) do
    local tParts = {}
    for nInfoID, nCount in pairs(tInfoMap) do
      tParts[#tParts + 1] = tostring(nInfoID) .. ":" .. tostring(nCount)
    end
    local sValue = table.concat(tParts, ";")
    DSCommonTLogSubsystem:AddPlayerCommonTLogData(self.UID, nTLogID, sValue, true)
  end
end
function PlayerStateBase:ReportClientPing(InClientPing, InClientDisplayPing)
  self.ClientPing = InClientPing
  self.ClientDisplayPing = InClientDisplayPing
end
function PlayerStateBase:GetBuyReviveCount()
  return math.floor(self.nLeftBuyLifeCounts + 0.1)
end
function PlayerStateBase:SetBuyReviveCount(Count, Character)
  if Count > self.nLeftBuyLifeCounts then
    local Controller = self:GetOwner()
    if Game:IsValid(Controller) and self:CanAddRevivalCount(Controller) == false then
      print(bWriteLog and "PlayerStateBase:SetBuyReviveCount, dont allow to add LifeCount, PlayerKey = " .. tostring(self.PlayerKey))
      return false
    end
  end
  if self.nLeftBuyLifeCounts == Count then
    print(bWriteLog and "PlayerStateBase:SetBuyReviveCount, Count = " .. tostring(Count) .. " = nLeftBuyLifeCounts")
    return false
  end
  print(bWriteLog and "PlayerStateBase:SetBuyReviveCount, Count = " .. tostring(Count) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  self.nLeftBuyLifeCounts = Count
  if self.nLeftBuyLifeCounts < 0 then
    self.nLeftBuyLifeCounts = 0
  end
  self:OnReviveCountChanged(Character)
  self:AIPerceptionLeftBuyLifeCount()
  return true
end
function PlayerStateBase:GetSuspiciousFlag()
  return self.SuspiciousFlag
end
function PlayerStateBase:SetSuspiciousFlag(NewValue)
  print(bWriteLog and "PlayerStateBase:SetSuspiciousFlag", NewValue)
  self.SuspiciousFlag = NewValue
end
function PlayerStateBase:GetHelpRevivalCount()
  local RevivalCount = self:GetTotalReviveCount()
  return RevivalCount
end
function PlayerStateBase:LuaGetLeftBuyLifeCounts()
  return self:GetBuyReviveCount()
end
function PlayerStateBase:LuaSetLeftBuyLifeCounts(Count, Character)
  self:SetBuyReviveCount(Count, Character)
end
function PlayerStateBase:OnReviveCountChanged(Character)
  print(bWriteLog and "PlayerStateBase:OnReviveCountChanged, PlayerKey = " .. tostring(self.PlayerKey))
  if self:HasAnyReviveChance() == false then
    self.IsInWaittingRevivalState = false
  end
  self:SetCharacterDestroyAndAnimationBlueprintVariable(Character)
  self:SendBattleResultIfNeedAndDisappearOnDeath(Character)
end
function PlayerStateBase:SetCharacterDestroyAndAnimationBlueprintVariable(Character)
  local uPlayerCharacter = self:GetPlayerCharacter() or Character
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    if self:HasAnyReviveChance() == false then
      uPlayerCharacter.DestroyOnDeath = true
      print(bWriteLog and "PlayerStateBase:SetCharacterDestroyAndAnimationBlueprintVariable, DestroyOnDeath = true and bRespawnResetAnimBP = false")
    else
      uPlayerCharacter.DestroyOnDeath = false
      uPlayerCharacter.bRespawnResetAnimBP = true
      print(bWriteLog and "PlayerStateBase:SetCharacterDestroyAndAnimationBlueprintVariable, DestroyOnDeath = false and bRespawnResetAnimBP = true")
    end
  else
    print(bWriteLog and "PlayerStateBase:SetCharacterDestroyAndAnimationBlueprintVariable, uPlayerCharacter = " .. tostring(uPlayerCharacter))
  end
end
function PlayerStateBase:SendBattleResultIfNeedAndDisappearOnDeath(Character)
  if self:HasAuthority() and self:HasAnyReviveChance() == false and self:IsAlive() == false then
    print(bWriteLog and "PlayerStateBase:SendBattleResultIfNeedAndDisappearOnDeath, self.bHasSendBattleResult = " .. tostring(self.bHasSendBattleResult))
    if self.bHasSendBattleResult == false then
      Game:CheckSendBattleResult(CGameMode, self.Object, true)
      local uPlayerCharacter = self:GetPlayerCharacter() or Character
      if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
        self:AddGameTimer(uPlayerCharacter.AnimDeathLifeSpan, false, function()
          if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
            uPlayerCharacter:DisappearOnDeath()
          end
        end)
      end
    end
  end
end
function PlayerStateBase:SetRevivalCount(nRevivalCount, Character)
  if nRevivalCount > self.RemainingRevivalCount then
    local Controller = self:GetOwner()
    if Game:IsValid(Controller) and self:CanAddRevivalCount(Controller) == false then
      print(bWriteLog and "PlayerStateBase:SetRevivalCount, dont allow to add RevivalCount, PlayerKey = " .. tostring(self.PlayerKey))
      return false
    end
  end
  if self.RemainingRevivalCount == nRevivalCount then
    print(bWriteLog and "PlayerStateBase:SetRevivalCount, nRevivalCount = " .. tostring(nRevivalCount) .. " = RemainingRevivalCount")
    return false
  end
  print(bWriteLog and "PlayerStateBase:SetRevivalCount, nRevivalCount = " .. tostring(nRevivalCount) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  self.RemainingRevivalCount = nRevivalCount
  if self.RemainingRevivalCount < 0 then
    self.RemainingRevivalCount = 0
  end
  self:OnReviveCountChanged(Character)
  self:SetRevivalIconByBackpackInfo()
  return true
end
function PlayerStateBase:HasAnyReviveChance()
  local Counts = self:GetRevivalCount() + self:GetBuyReviveCount() + self:GetSpecialReviveCount()
  print(bWriteLog and "PlayerStateBase:HasAnyReviveChance, Counts = " .. tostring(Counts) .. " when PlayerKey = " .. tostring(self.PlayerKey))
  return 0 < Counts
end
function PlayerStateBase:GetSpecialReviveCount()
  return 0
end
function PlayerStateBase:SetSpecialReviveCount(SpecialReviveCount)
end
function PlayerStateBase:GetTotalReviveCount()
  return self:GetRevivalCount() + self:GetBuyReviveCount() + self:GetSpecialReviveCount()
end
function PlayerStateBase:ClearAllReviveCounts()
  if self:GetRevivalCount() > 0 then
    self:SetRevivalCount(0)
  end
  if 0 < self:GetBuyReviveCount() then
    self:SetBuyReviveCount(0)
  end
  if 0 < self:GetSpecialReviveCount() then
    self:SetSpecialReviveCount(0)
  end
end
function PlayerStateBase:GetRevivalCount()
  return self.RemainingRevivalCount
end
function PlayerStateBase:OnRep_RemainingRevivalCount()
  print(bWriteLog and "PlayerStateBase:OnRep_RemainingRevivalCount, RemainingRevivalCount = " .. tostring(self.RemainingRevivalCount) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_REVIVE_COUNT_REP, self)
end
function PlayerStateBase:OnRep_nReviveType()
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_REVIVE_TYPE_CHANGE, self)
end
function PlayerStateBase:OnRep_ChangeRevivalState()
  print(bWriteLog and "PlayerStateBase 1 self.IsInWaittingRevivalState:", self.IsInWaittingRevivalState)
  self.Super:OnRep_ChangeRevivalState()
  self:CheckSpectatingWhendReconnet()
  self:CheckQuitSpectating()
end
function PlayerStateBase:CheckSpectatingWhendReconnet()
  local bNeedSpectating = false
  if self.IsInWaittingRevivalState then
    local uPlayerController = GameplayStatics.GetPlayerController(self, 0)
    if slua.isValid(uPlayerController) and uPlayerController.PlayerState == self.Object then
      print(bWriteLog and "PlayerStateBase 2 self.IsInWaittingRevivalState:", self.IsInWaittingRevivalState)
      if not uPlayerController:IsInSpectating() then
        print(bWriteLog and "PlayerStateBase 3 self.IsInWaittingRevivalState:", self.IsInWaittingRevivalState)
        bNeedSpectating = true
      end
    end
    if uPlayerController == nil or uPlayerController.PlayerState == nil then
      bNeedSpectating = true
    end
  end
  if bNeedSpectating then
    self:AddGameTimer(5, false, function()
      if GameplayStatics and self.Object then
        local uPlayerController = GameplayStatics.GetPlayerController(self.Object, 0)
        if slua.isValid(uPlayerController) and uPlayerController.PlayerState == self.Object then
          if uPlayerController.bIsForReplay then
            return
          end
          if not uPlayerController:IsInSpectating() and not uPlayerController:IsInPetSpectator() and self.IsInWaittingRevivalState then
            print(bWriteLog and "PlayerStateBase 4 self.IsInWaittingRevivalState:", self.IsInWaittingRevivalState)
            if not self.bHasSendBattleResult and self:HasAnyReviveChance() then
              uPlayerController:GotoSpectating(0)
            end
          end
        end
      end
    end)
  end
end
function PlayerStateBase:CheckQuitSpectating()
  if self.IsInWaittingRevivalState == false and self.LiveState ~= ExtraPlayerLiveState.InDied then
    local uPlayerController = GameplayStatics.GetPlayerController(self, 0)
    if slua.isValid(uPlayerController) and uPlayerController.IsSpectator and uPlayerController.PlayerState == self.Object and uPlayerController:IsSpectator() and not uPlayerController:IsPureSpectator() and not uPlayerController:IsDemoPlayGlobalObserver() and not uPlayerController:IsDemoPlaySpectator() then
      print(bWriteLog and "PlayerStateBase CheckQuitSpectating PlayerKey:", self.PlayerKey)
      uPlayerController:QuitSpectating()
    end
  end
end
function PlayerStateBase:CanSelfRevive()
  print(bWriteLog and "revivaldebug PlayerStateBase CanSelfRevive call")
  local bCanselfRevival = false
  if self:GetRevivalCount() > 0 then
    if self.GetHaveSinglePlayerReviveItem and self:GetHaveSinglePlayerReviveItem() then
      bCanselfRevival = true
      print(bWriteLog and "PlayerStateBase:CanSelfRevive, true because of ItemRevive")
    end
    if not bCanselfRevival and CGameState and CGameState.ReviveState then
      local HelicopterWaitingTime = CGameState.ReviveState:GetConfigHelicopterWaitingTime()
      if HelicopterWaitingTime and 0 < HelicopterWaitingTime then
        bCanselfRevival = true
        print(bWriteLog and "PlayerStateBase:CanSelfRevive, true because of HelicopterRevive")
      end
    end
  end
  bCanselfRevival = bCanselfRevival or self.Super:CanSelfRevive()
  print(bWriteLog and "revivaldebug PlayerStateBase CanSelfRevive bCanselfRevival:", bCanselfRevival)
  return bCanselfRevival
end
function PlayerStateBase:RespondToPawnRescuingStatusChange(HelpTarget, OwnerPawn, bTurningInto, RemainingRescueTime, RemainingRescueTotalTime, bFirstPlayerHelper, RescueSourceID)
  self.IsShowingRescueingUI = bTurningInto
  print(bWriteLog and string.format("PlayerStateBase:RespondToPawnRescuingStatusChange IsBegin=%s IsFirstPlayerHelper=%s", tostring(bTurningInto), tostring(bFirstPlayerHelper)))
  local TPlayerController = GameplayStatics.GetPlayerController(self, 0)
  local TargetController = slua.isValid(self.Owner) and self.Owner or nil
  local IsSpectator = false
  if not slua.isValid(TargetController) and slua.isValid(TPlayerController) and TPlayerController.IsSpectator and TPlayerController:IsSpectator() and not TPlayerController.IsCurrentSpectatorFreeView then
    TargetController = TPlayerController
    IsSpectator = true
  end
  if not slua.isValid(TargetController) or not TargetController.GetCurPlayerCharacter then
    return
  end
  print(bWriteLog and string.format("PlayerStateBase:RespondToPawnRescuingStatusChange show rescue ishelper=%s isbegin=%s", tostring(bFirstPlayerHelper), tostring(bTurningInto)))
  TargetController.RescueRemainingSeconds = RemainingRescueTime
  TargetController.RescueTotalSeconds = RemainingRescueTotalTime
  TargetController.  if bTurningInto then
    print(bWriteLog and "1PlayerStateBase:RespondToPawnRescuingStatusChange show rescue", bFirstPlayerHelper, OwnerPawn, HelpTarget)
    if bFirstPlayerHelper then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_CDBAR, UEnums.CDBarType.RescueOther, {})
    elseif HelpTarget ~= OwnerPawn or IsSpectator then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_CDBAR, UEnums.CDBarType.BeingRescue, {})
    end
  elseif bFirstPlayerHelper then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, UEnums.CDBarType.RescueOther, {})
  else
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, UEnums.CDBarType.BeingRescue, {})
  end
end
function PlayerStateBase:OnRep_PlayerLiveState()
  if self.Super.OnRep_PlayerLiveState then
    self.Super:OnRep_PlayerLiveState()
  end
  if Client then
    local uPlayerController = GameplayStatics.GetPlayerController(self, 0)
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState uPlayerController Is nil")
      return
    end
    if uPlayerController.IsInSpectating and uPlayerController:IsInSpectating() and self.PlayerDeadLocation and self.PlayerDeadLocation.IsNearlyZero then
      printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState IsInSpectating")
      local uCurPawn = uPlayerController:GetCurPawn()
      if slua.isValid(uCurPawn) and uCurPawn.PlayerKey == self.PlayerKey then
        printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState PlayerName[%s] LiveState[%d]", uCurPawn:GetPlayerNameSafety(), self.LiveState)
        if self.LiveState >= ExtraPlayerLiveState.InDying and not self.PlayerDeadLocation:IsNearlyZero(0.01) then
          local DeadLocation = self.PlayerDeadLocation
          DeadLocation.Z = self.PlayerDeadLocation.Z + 100
          uPlayerController:K2_SetActorLocation(DeadLocation, false, nil, false)
          printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState K2_SetActorLocation x[%f] y[%f] z[%f]", DeadLocation.X, DeadLocation.Y, DeadLocation.Z)
        end
      end
    elseif uPlayerController.bIsForReplay then
      printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState bIsForReplay")
      local uGameInstance = GameplayStatics.GetGameInstance(self)
      if slua.isValid(uGameInstance) and self.LiveState < 4 then
        print(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState bIsForReplay 111")
        local uReplay = uGameInstance:GetCompletePlayback()
        local uCharacter = self:GetPlayerCharacter()
        if slua.isValid(uReplay) and slua.isValid(uCharacter) then
          printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState bIsForReplay Replay:GetSpectatorName(): %s", uReplay:GetSpectatorName())
          if uReplay:GetSpectatorName() == uCharacter.PlayerUID then
            printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState bIsForReplay 222")
            if not uReplay:GetCanChangeViewTarget() then
              uReplay:SetCanChangeViewTarget(true)
            end
            uGameInstance:AttachCameraViewToCharacter(uCharacter)
            printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState before castuimsg")
            uPlayerController:CastUIMsg("UIMsg_GameReplay_SyncPlayerState", "")
            printf(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState after castuimsg")
          end
        end
      end
    end
    self:CheckQuitSpectating()
    if uPlayerController.GetCurPawn then
      local uCurPawn = uPlayerController:GetCurPawn()
      if self.LiveState <= ExtraPlayerLiveState.InDying and slua.isValid(uCurPawn) and uCurPawn.PlayerKey == self.PlayerKey and uPlayerController.FadeSceneToGrayOnDeath then
        uPlayerController:FadeSceneToGrayOnDeath(false)
      end
    end
    if self.LastLiveState ~= self.LiveState then
      print(bWriteLog and "PlayerStateBase:OnRep_PlayerLiveState LiveState change", self.LastLiveState, self.LiveState, self:GetPlayerKey())
      if self.LastLiveState == ExtraPlayerLiveState.InDied and self.LiveState ~= ExtraPlayerLiveState.Offline then
        EventSystem:postEventSafety(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_PLAYERSTATE_REVIVAL, self:GetPlayerKey(), self:GetPlayerCharacter(), self:GetTeamId())
      end
      self.LastLiveState = self.LiveState
    end
  end
end
function PlayerStateBase:ReceiveBeginPlay()
  print(bWriteLog and "PlayerStateBase:ReceiveBeginPlay", self.PlayerKey, self.PlayerName, self.TeamID, self.IdxInTeam)
  PlayerStateBase.__super.ReceiveBeginPlay(self)
  if self.LuaReceiveBeginPlay then
    self:LuaReceiveBeginPlay()
  end
  GameplayData.BindPlayerState(self.Object)
  if self:HasAuthority() then
    self:SetRevivalIconByBackpackInfo()
    self:AddControlEvent(self.Object, "AllowToAddGeneralCount", self.OnAllowToAddGeneralCount, self)
    self:AddControlEvent(self.Object, "OnGenerelCountChanged", self.OnHandleGenerelCountChanged, self)
    self.bSkipComparePropertiesForReplay = true
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.OnGameFinished, self)
    self:BindLuaObjEvent(self, "OnAIAllocateSuccess", self.OnAIAllocateSuccessReportAttributes, self)
  else
    local uPlayerController = GameplayStatics.GetPlayerController(self.Object, 0)
    if slua.isValid(uPlayerController) and uPlayerController.IsObserver and uPlayerController:IsObserver() then
      self:AddControlEvent(self.Object, "OnPlayerUnderAttack", self.OnPlayerUnderAttackClient, self)
    end
  end
  if Client then
    self:AddSettingOptionEvent("bVoiceChanger", function(bValue)
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local PlayerState = GameplayData.GetPlayerState()
      if slua.isValid(PlayerState) then
        PlayerState:ServerRPC_EnableVoiceChanger(bValue)
      end
    end, true)
    local VoiceChatSubsystem = SubsystemMgr:Get("VoiceChatSubsystem")
    if VoiceChatSubsystem then
      local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
      VoiceChatSubsystem:SetPreTeamState(SettingModule:GetOptionValue("bLastMicPreTeam"))
    end
  end
  self:OnLostConnectionStateChange()
end
function PlayerStateBase:OnPlayerUnderAttackClient()
  local uPlayerController = GameplayStatics.GetPlayerController(self.Object, 0)
  if slua.isValid(uPlayerController) and uPlayerController.IsObserver and uPlayerController:IsObserver() then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_PLAYER_UNDER_ATTACK, self)
  end
end
function PlayerStateBase:SetRevivalIconByBackpackInfo()
  if self:GetRevivalCount() > 0 then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local ReviveConfig = GamePlayTools.GetCurrentConfig("ReviveConfig")
    if ReviveConfig and ReviveConfig.RevivalWayToIconKey then
      local uPlayerController = self:GetOwner()
      if uPlayerController and slua.isValid(uPlayerController) then
        local uBackpackComponent = uPlayerController.BackpackComponent
        local BackpackUtils = import("BackpackUtils")
        for _, ItemID in pairs(ReviveConfig.RevivalWayToIconKey) do
          if ItemID ~= 0 then
            local nCount = BackpackUtils.GetItemCountByResID(uBackpackComponent, ItemID)
            if 0 < nCount then
              print(bWriteLog and "PlayerStateBase:SetRevivalIconByBackpackInfo, ItemID = " .. tostring(ItemID) .. ", PlayerKey = " .. tostring(self.PlayerKey))
              self.nReviveType = ItemID
              return
            end
          end
        end
      end
    end
    self.nReviveType = 0
    print(bWriteLog and "PlayerStateBase:SetRevivalIconByBackpackInfo, RevivalCount = " .. tostring(self:GetRevivalCount()) .. ", PlayerKey = " .. tostring(self.PlayerKey) .. ", but with no RevivalItems")
  else
    self.nReviveType = 0
    print(bWriteLog and "PlayerStateBase:SetRevivalIconByBackpackInfo, RevivalCount = " .. tostring(self:GetRevivalCount()) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  end
end
function PlayerStateBase:OnHandlePickupItem(EventType, EventID, PlayerKey, ItemID, Count, Reason, Source)
  if PlayerKey == self.PlayerKey then
  end
end
function PlayerStateBase:ReceiveEndPlay(nDeltaSeconds)
  print(bWriteLog and string.format("PlayerStateBase ReceiveEndPlay() PlayerKey:%d", tonumber(self:GetPlayerKey())))
  GameplayData.UnbindPlayerState(self.Object)
  self._SuperData = nil
  PlayerStateBase.__super.ReceiveEndPlay(self, nDeltaSeconds)
end
function PlayerStateBase:BPKill(uVictimPawn)
  if not Game:IsValid(uVictimPawn) then
    return
  end
  local uCharacter = self:GetPlayerCharacter()
  if not Game:IsValid(uCharacter) then
    return
  end
  if uCharacter:GetTeamId() == uVictimPawn:GetTeamId() then
    return
  end
  self:VehicleSpeedKills()
end
function PlayerStateBase:OnRep_AliasInfo()
  print(bWriteLog and "OnRep_AliasInfo aliasID lua: ", self.UID, self.AliasInfo.aliasID)
end
function PlayerStateBase:VehicleSpeedKills()
  local uCharacter = self:GetPlayerCharacter()
  if not Game:IsValid(uCharacter) then
    return
  end
  if uCharacter.bEnsure then
    return
  end
  if uCharacter:HasState(UEnums.EPawnState.InVehicle) then
    local uVehicle = uCharacter:GetCurrentVehicle()
    if Game:IsValid(uVehicle) then
      local nVehicleSpeed = uVehicle:GetForwardSpeed()
      nVehicleSpeed = nVehicleSpeed / 100 * 3.6
      if 30 < nVehicleSpeed then
        self.TlogData.VehicleSpeedKills = self.TlogData.VehicleSpeedKills + 1
        PlayerDataMgr.AddVehicleSpeedKills(self.UID, 1)
      end
    end
  end
end
function PlayerStateBase:AddDamager(Damager, DamageType)
  if not Game:IsValid(Damager) then
    return
  end
  if not Damager.PlayerKey or Damager.PlayerKey <= 0 then
    return
  end
  local PlayerHealth = self:GetPlayerHealth()
  if 0 < PlayerHealth then
    if not self.TlogData.HurtByPlayers[Damager.PlayerKey] then
      self.TlogData.HurtByPlayers[Damager.PlayerKey] = 1
      PlayerDataMgr.AddHurtByPlayers(self.UID, 1)
    end
  elseif self.TlogData.HurtByPlayers[Damager.PlayerKey] then
    self.TlogData.HurtByPlayers[Damager.PlayerKey] = nil
    PlayerDataMgr.AddHurtByPlayers(self.UID, -1)
  end
  local DamagerPlayerName = Damager:GetPlayerNameSafety()
  print(bWriteLog and "TakeDamage_Debug_Msg: DamagerName = " .. DamagerPlayerName .. " DamageType = " .. DamageType .. " SelfName = " .. self.playerName)
  if CGameMode and DamageType ~= UEnums.DamageType.PoisonDamage and DamageType ~= UEnums.DamageType.FallingDamage and DamageType ~= UEnums.DamageType.DrowningDamage then
    print(bWriteLog and "TakeDamage_Debug_Msg: GameModeType = " .. CGameMode.GameModeType)
    if CGameMode.GameModeType and EnablePlayerUnderAttackGameModeType[CGameMode.GameModeType] and self.RPC_OnPlayerUnderAttack then
      self:RPC_OnPlayerUnderAttack()
    end
  end
end
function PlayerStateBase:GetCurrentReviveType()
  return self.nReviveType
end
function PlayerStateBase:OnRep_nLeftBuyLifeCounts()
  print(bWriteLog and "PlayerStateBase:OnRep_nLeftBuyLifeCounts, Count = " .. tostring(self.nLeftBuyLifeCounts))
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_BUY_LIFE_COUNT_REP, self)
  local SuperData = self:GetSuperData()
  SuperData.nLeftBuyLifeCounts = self.nLeftBuyLifeCounts
end
function PlayerStateBase:InitTeamShowData()
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local uid = tonumber(self.UID)
  local playerInfo = ServerPlayerDataMgr.GetPlayerInfo(uid)
  if not playerInfo then
    print(bWriteLog and "PlayerStateBase:InitTeamShowData. playerInfo is nil ")
    return
  end
  if playerInfo.all_knapsack_ext_info and playerInfo.use_rolewear and playerInfo.all_knapsack_ext_info[playerInfo.use_rolewear] then
    local wingman_skin = playerInfo.all_knapsack_ext_info[playerInfo.use_rolewear].wingman_skin
    print(bWriteLog and "PlayerStateBase:InitTeamShowData. wingman_skin = " .. tostring(wingman_skin))
    if wingman_skin ~= nil then
      self.nWingman_skin = wingman_skin
    end
    local Vst_skin = playerInfo.vst_skin
    print(bWriteLog and "PlayerStateBase:InitTeamShowData. vst_skin = " .. tostring(Vst_skin))
    if Vst_skin ~= nil then
      self.n    else
      log_error("Vst_skin is nil")
    end
  end
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  self.XSuitIconId = XSuitAvatarDataUtil:GetValidXSuitIconId(uid)
  print(bWriteLog and "PlayerStateBase:InitTeamShowData, XSuitIconId = " .. tostring(self.XSuitIconId))
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local SubscribeInfo = PlayerDataMgr.GetPlayerProgressFromServer(uid, ExtendAttribute.SubscribeInfo)
  if SubscribeInfo then
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, bShowSubscribe = true")
    self.bShowSubscribe = true
  end
  self.NicknameColor = PlayerDataMgr.GetPlayerProgressFromServer(uid, ExtendAttribute.NicknameColor) or 0
  local CollectData = PlayerDataMgr.GetPlayerProgressFromServer(uid, ExtendAttribute.CollectScore)
  if CollectData then
    if CollectData.total_score then
      self.CollectScore = math.floor(CollectData.total_score)
    else
      self.CollectScore = 0
    end
    self.SeasonCollectScore = CollectData.cur_season_collect_score or 0
    if CollectData.privacy then
      self.CollectScorePrivacy = CollectData.privacy[1] == true or CollectData.privacy[1] == nil
    end
  end
  local Alias = PlayerDataMgr.GetPlayerProgressFromServer(uid, ExtendAttribute.WeaponCapabilityAlias)
  if Alias then
    self.AliasData = Alias
  end
  if self.nVst_skin then
    local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
    self.bEnableTireLight = VehiclePlateLicenseUtil.NeedOpenHighTire(uid, self.nVst_skin)
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, self.bEnableTireLight = " .. tostring(self.bEnableTireLight))
  end
  local IntimacyInfo = ServerPlayerDataMgr.GetPlayerProgressFromServer(uid, ExtendAttribute.IntimacyInfo)
  if IntimacyInfo and IntimacyInfo.intimacy and IntimacyInfo.relation and IntimacyInfo.friend_uid then
    self.IntimacyValue = IntimacyInfo.intimacy
    self.IntimacyRelation = IntimacyInfo.relation
    self.IntimacyTargetUID = IntimacyInfo.friend_uid
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, IntimacyInfo intimacy:" .. IntimacyInfo.intimacy .. " relation:" .. IntimacyInfo.relation .. " friend_uid:" .. IntimacyInfo.friend_uid)
  end
  if playerInfo and playerInfo.peak_rating_info then
    log_tree("PlayerStateBase peak_rating_info:" .. self.UID, playerInfo.peak_rating_info)
    if playerInfo.peak_rating_info.segment_id then
      self.PeakSegmentID = playerInfo.peak_rating_info.segment_id
    end
  end
  if playerInfo then
    if playerInfo.cur_mode_seg_level then
      log_tree("PlayerStateBase" .. self.UID .. " cur_mode_seg_level:" .. playerInfo.cur_mode_seg_level)
      self.CurSegLevel = playerInfo.cur_mode_seg_level
    end
    if playerInfo.unlocked_mode_seg_level then
      log_tree("PlayerStateBase" .. self.UID .. " unlocked_mode_seg_level:" .. playerInfo.unlocked_mode_seg_level)
      self.UnlockSegLevel = playerInfo.unlocked_mode_seg_level
    end
    if playerInfo.promotion_layer then
      self.PromotionLayer = playerInfo.promotion_layer
      print(bWriteLog and "PlayerStateBase:InitTeamShowData, promotion_layer:" .. tostring(self.PromotionLayer))
    end
    if playerInfo.promotion_locked_info then
      self.bPromotionProtected = playerInfo.promotion_locked_info.can_protect
      self.PromotionProgressCount = playerInfo.promotion_locked_info.progress
      self.PromotionNeedPersonRank = playerInfo.promotion_locked_info.need_person_rank
      self.PromotionContinueWinCount = playerInfo.promotion_locked_info.continue_win_cnt
      print(bWriteLog and "PlayerStateBase:InitTeamShowData, promotion_locked_info Name:" .. self.PlayerName .. " bPromotionProtected:" .. tostring(self.bPromotionProtected) .. " PromotionProgressCount:" .. tostring(self.PromotionProgressCount) .. " PromotionNeedPersonRank:" .. tostring(self.PromotionNeedPersonRank) .. " PromotionContinueWinCount:" .. tostring(self.PromotionContinueWinCount))
    else
      print(bWriteLog and "PlayerStateBase:InitTeamShowData, promotion_locked_info is nil")
    end
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  self.EliminationKingEffectID = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(uid, ExtendAttribute.EliminationKingEffect) or 0
  print(bWriteLog and "PlayerStateBase:InitTeamShowData, EliminationKingEffect = " .. tostring(self.EliminationKingEffectID))
  if playerInfo.card_collect_career_score then
    self.CardCollectCareerScore = playerInfo.card_collect_career_score
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, CardCollectCareerScore = " .. tostring(self.CardCollectCareerScore))
  else
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, CardCollectCareerScore = nil")
  end
  local LocalCabinShowActorInfo = ServerPlayerDataMgr.GetPlayerProgressFromServer(uid, ExtendAttribute.CabinShowActorInfo)
  if LocalCabinShowActorInfo and LocalCabinShowActorInfo[1] then
    if self.SetCabinShowActorID then
      self:SetCabinShowActorID(LocalCabinShowActorInfo[1])
    else
      self.CabinShowActorID = LocalCabinShowActorInfo[1]
    end
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, CabinShowActorID = " .. tostring(LocalCabinShowActorInfo[1]))
  else
    print(bWriteLog and "PlayerStateBase:InitTeamShowData, CabinShowActorID = nil")
  end
  self:InitSquadBroadcastData(uid)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_PLAYERSTATE_READY, self.Object)
end
function PlayerStateBase:InitSquadBroadcastData(uid)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local RawData = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(uid), ExtendAttribute.TeamShowSquadBroadcast)
  if IsEditor then
    RawData = {
      squads = {
        {
          squad_id = 12345,
          squad_name = "\233\187\145\233\185\176\229\176\143\233\152\159",
          broadcast_id = 62530001,
          rapport_level = 4,
          member_uids = {
            1001,
            1002,
            1003
          }
        },
        {
          squad_id = 67890,
          squad_name = "\229\145\168\230\156\171\229\143\140\230\142\146",
          broadcast_id = 62530001,
          rapport_level = 1,
          member_uids = {1001, 1004}
        }
      }
    }
  end
  if not RawData or not RawData.squads then
    print(bWriteLog and "PlayerStateBase:InitSquadBroadcastData, SquadBroadcastData is nil or no squads")
    return
  end
  local SortedTeams = {}
  for _, Squad in ipairs(RawData.squads) do
    if Squad and type(Squad.squad_name) == "string" and Squad.squad_name ~= "" and type(Squad.broadcast_id) == "number" and Squad.broadcast_id >= 0 and type(Squad.rapport_level) == "number" and Squad.rapport_level >= 0 and Squad.rapport_level <= 6 then
      SortedTeams[#SortedTeams + 1] = Squad
    else
      print(bWriteLog and string.format("PlayerStateBase:InitSquadBroadcastData - skip invalid squad, squad_name=%s broadcast_id=%s rapport_level=%s", tostring(Squad and Squad.squad_name), tostring(Squad and Squad.broadcast_id), tostring(Squad and Squad.rapport_level)))
    end
  end
  table.sort(SortedTeams, function(A, B)
    return A.rapport_level > B.rapport_level
  end)
  for i = 1, math.min(#SortedTeams, self.SquadBroadcastMaxCount) do
    local Squad = SortedTeams[i]
    self.SquadBroadcastStyleIds:Add(Squad.broadcast_id)
    self.SquadBroadcastTeamNames:Add(Squad.squad_name)
  end
  print(bWriteLog and string.format("PlayerStateBase:InitSquadBroadcastData - TeamCount=%d PlayerKey=%s", self.SquadBroadcastStyleIds:Num(), tostring(self.UID)))
end
function PlayerStateBase:SetDiedTime()
  self.fDiedTime = CGameState:GetServerWorldTimeSeconds()
end
function PlayerStateBase:GetDiedTime()
  if self.fDiedTime then
    return self.fDiedTime
  else
    return 0
  end
end
function PlayerStateBase:SetDiedPlayerCount()
  if CGameState then
    self.DiedPlayerCount = CGameState:GetAlivePlayerNum() + 1
    if CGameMode and CGameMode.ReducePlayersNumAfterDied == false and CGameMode:IsRevivalGameMode(self.Object) and CGameMode:IsPlayerCanSelfRevival(self.Object) then
      self.DiedPlayerCount = self.DiedPlayerCount - 1
    end
    print(bWriteLog and "PlayerStateBase:SetDiedPlayerCount, PlayerKey = " .. tostring(self.PlayerKey) .. ", DiedPlayerCount = " .. tostring(self.DiedPlayerCount))
  else
    print(bWriteLog and "PlayerStateBase:SetDiedPlayerCount, PlayerKey = " .. tostring(self.PlayerKey) .. ", CGameState = nil")
  end
end
function PlayerStateBase:ResetDiedPlayerCount()
  self.DiedPlayerCount = 0
  print(bWriteLog and "PlayerStateBase:ResetDiedPlayerCount, PlayerKey = " .. tostring(self.PlayerKey))
end
function PlayerStateBase:GetDiedPlayerCount()
  return self.DiedPlayerCount
end
function PlayerStateBase:HandleSetCharacterIntProperty(StrPlayerKey, KeyName, InValue)
  self:InnerHandleSetCharacterProperty(StrPlayerKey, KeyName, InValue)
end
function PlayerStateBase:HandleSetCharacterStringProperty(StrPlayerKey, KeyName, InValue)
  self:InnerHandleSetCharacterProperty(StrPlayerKey, KeyName, InValue)
end
function PlayerStateBase:InnerHandleSetCharacterProperty(StrPlayerKey, KeyName, InValue)
  if not Client then
    return
  end
  if slua.isValid(CGameState) and CGameState.CacheSetIntProperty and #CGameState.CacheSetIntProperty > 0 then
    local Res = false
    local Length = #CGameState.CacheSetIntProperty
    local TempData
    local RemoveIndexs = {}
    for i = 1, Length do
      TempData = CGameState.CacheSetIntProperty[i]
      Res = self:TryHandleSetCharacterProperty(TempData[1], TempData[2], TempData[3])
      if Res == true then
        table.insert(RemoveIndexs, i)
      end
    end
    Length = #RemoveIndexs
    for j = Length, 1, -1 do
      RIndex = RemoveIndexs[j]
      table.remove(CGameState.CacheSetIntProperty, RIndex)
    end
  end
  if self:TryHandleSetCharacterProperty(StrPlayerKey, KeyName, InValue) == false and slua.isValid(CGameState) then
    if CGameState.CacheSetIntProperty == nil then
      CGameState.CacheSetIntProperty = {}
    end
    local CacheData = {
      StrPlayerKey,
      KeyName,
      InValue
    }
    table.insert(CGameState.CacheSetIntProperty, CacheData)
  end
end
function PlayerStateBase:TryHandleSetCharacterProperty(StrPlayerKey, KeyName, InValue)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local Character = GameplayData.GetPlayerCharacter(tonumber(StrPlayerKey))
  if slua.isValid(Character) then
    if Character[KeyName] ~= nil then
      if KeyName == "MLEnsureStyle" then
        local DebugLastMLEnsureStyle = string.format("%d_%.1f", Character[KeyName], CGameState:GetServerWorldTimeSeconds())
        Character:AddDebugAIInfoTable("LastMLAIStyle", DebugLastMLEnsureStyle)
        Character:SetMEnsure(0 < InValue)
      elseif KeyName == "MLEnsureExtraInfo" then
        Character:AddDebugAIInfoTable("MLExtraInfo", InValue)
      end
      if type(Character[KeyName]) == "boolean" and type(InValue) == "number" then
        if 0 < InValue then
          Character[KeyName] = true
        else
          Character[KeyName] = false
        end
      else
        Character[KeyName] = InValue
      end
      print(bWriteLog and "PlayerStateBase:TryHandleSetCharacterProperty, " .. KeyName .. ":" .. InValue)
    else
      Character[KeyName] = InValue
      print(bWriteLog and "PlayerStateBase:TryHandleSetCharacterProperty, Debug Key:" .. KeyName .. ":" .. InValue)
    end
    return true
  else
    return false
  end
end
function PlayerStateBase:ClientReportTeammateDisappearInfo()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if uPlayerController.ReportCrashKitFeature and uPlayerController.ReportCrashKitFeature.ReportTeammateDisappear then
    uPlayerController.ReportCrashKitFeature:ReportTeammateDisappear(self.Object)
  end
end
function PlayerStateBase:GetPlayerTotalShootNum()
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  local ShootNum = 0
  if WeaponRecordSubSystem then
    ShootNum = WeaponRecordSubSystem:GetPlayerTotalShootNum(self.PlayerKey)
  end
  print(bWriteLog and "PlayerStateBase:GetPlayerTotalShootNum", ShootNum)
  return ShootNum
end
function PlayerStateBase:GetWeaponReportByWeaponRecord()
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  print(bWriteLog and "PlayerStateBase:GetWeaponReportByWeaponRecord", self.PlayerKey, self.UID)
  if WeaponRecordSubSystem then
    local OnePlayerWeapon = WeaponRecordSubSystem:InitWeaponReportByWeaponRecord(self.PlayerKey, self.UID)
    return OnePlayerWeapon
  end
  return {}
end
function PlayerStateBase:_CheckSelfRescueItem()
  local Config = require("GameLua.Mod.BaseMod.DS.Config.SelfRescueConfig")
  local ItemID = Config.SelfRescueItemId
  if ItemID ~= 0 then
    local uPlayerController = self:GetOwner()
    if uPlayerController and slua.isValid(uPlayerController) then
      local uBackpackComponent = uPlayerController.BackpackComponent
      local BackpackUtils = import("BackpackUtils")
      local nCount = BackpackUtils.GetItemCountByResID(uBackpackComponent, ItemID)
      print(bWriteLog and "PlayerStateBase:_CheckSelfRescueItem, nCount = " .. tostring(nCount) .. ", PlayerKey = " .. tostring(self.PlayerKey))
      return 0 < nCount
    else
      print(bWriteLog and "PlayerStateBase:_CheckSelfRescueItem, uPlayerController = " .. tostring(uPlayerController) .. ", PlayerKey = " .. tostring(self.PlayerKey))
    end
  end
end
function PlayerStateBase:_CheckSelfRescueResource()
  return self:_CheckSelfRescueItem()
end
function PlayerStateBase:CheckCanSelfRescue(bDontNeedCheck)
  local bCanSelfRescue = bDontNeedCheck or self:_CheckSelfRescueResource()
  local uPlayerCharacter = self:GetPlayerCharacter()
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    if bCanSelfRescue then
      uPlayerCharacter:SetAttrValue("bCanSelfRescue", 1, -1)
    else
      uPlayerCharacter:SetAttrValue("bCanSelfRescue", 0, -1)
    end
    local CurrentValue = uPlayerCharacter:GetAttrValue("bCanSelfRescue")
    print(bWriteLog and "PlayerStateBase:CheckCanSelfRescue SetAttrValue = " .. tostring(CurrentValue) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  else
    print(bWriteLog and "PlayerStateBase:CheckCanSelfRescue, uPlayerCharacter = " .. tostring(uPlayerCharacter) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  end
  return bCanSelfRescue
end
function PlayerStateBase:LostSelfRescueResource()
  local bCanSelfRescue = self:CheckCanSelfRescue()
  if bCanSelfRescue then
    return
  end
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if self.LiveState == ExtraPlayerLiveState.InDying then
    local uPlayerCharacter = self:GetPlayerCharacter()
    if Game:IsValid(uPlayerCharacter) and not uPlayerCharacter.bEnsure and Game:IsValid(uPlayerCharacter.NearDeatchComponent) then
      local Component = uPlayerCharacter.NearDeatchComponent
      if Component:HasAnyTeamatesCanHelp() == false then
        Component:ClearNearDeathTeammate()
        Component.NDDecreaseRate = 1000
        print(bWriteLog and "PlayerStateBase:LostSelfRescueResource, set NDDecreaseRate = 1000, PlayerKey = " .. tostring(PlayerKey))
      end
    end
  end
end
function PlayerStateBase:_ConsumeSelfRescueResource()
  local Config = require("GameLua.Mod.BaseMod.DS.Config.SelfRescueConfig")
  if self:_CheckSelfRescueItem() then
    local uPlayerCharacter = self:GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      Game:ConsumeItem(uPlayerCharacter, Config.SelfRescueItemId, 1)
    end
  else
    print(bWriteLog and "PlayerStateBase:ConsumeSelfRescue, error: not buff or item, PlayerKey = " .. tostring(PlayerKey))
  end
  self:CheckCanSelfRescue()
end
function PlayerStateBase:AfterSelfRescueSucceed()
  local uPlayerCharacter = self:GetPlayerCharacter()
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    self:_ConsumeSelfRescueResource()
  else
    print(bWriteLog and "PlayerStateBase:AfterSelfRescueSucceed, uPlayerCharacter = " .. tostring(uPlayerCharacter) .. ", PlayerKey = " .. tostring(self.PlayerKey))
  end
end
function PlayerStateBase:BeRescuedSucceed()
end
function PlayerStateBase:AddHideHeadPositionTag(Tag)
  if not self.HeadPositionTagTable then
    self.HeadPositionTagTable = {}
  end
  if type(Tag) ~= "string" then
    log_error("PlayerStateBase:AddHideHeadPositionTag need a string")
    return
  end
  if self.HeadPositionTagTable[Tag] then
    print(bWriteLog and "PlayerStateBase:AddHideHeadPositionTag Tag is exist: ", Tag)
    return
  end
  print(bWriteLog and string.format("PlayerStateBase:AddHideHeadPositionTag Tag: %s, Name:%s", Tag, self.PlayerName))
  self.HeadPositionTagTable[Tag] = true
  local SuperData = self:GetSuperData()
  SuperData.HeadPositionTagCount = SuperData.HeadPositionTagCount + 1
end
function PlayerStateBase:RemoveHideHeadPositionTag(Tag)
  if not self.HeadPositionTagTable then
    return
  end
  if self.HeadPositionTagTable[Tag] then
    print(bWriteLog and string.format("PlayerStateBase:RemoveHideHeadPositionTag Tag: %s, Name:%s", Tag, self.PlayerName))
    self.HeadPositionTagTable[Tag] = nil
    local SuperData = self:GetSuperData()
    SuperData.HeadPositionTagCount = SuperData.HeadPositionTagCount - 1
  end
end
function PlayerStateBase:InitVersionTask()
  if not Client then
    local bIsThemeMode = GamePlayTools.IsThemeBRMode()
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local MapType = GameMainConfig.GetMapType()
    if not bIsThemeMode then
      print(bWriteLog and "PlayerStateBase:InitVersionTask, bIsThemeMode == " .. tostring(bIsThemeMode) .. " MapType == " .. tostring(MapType))
      return
    end
    local bIsRoomType = CGameState and CGameState.RoomType and CGameState.RoomType ~= ""
    if bIsRoomType then
      print(bWriteLog and "PlayerStateBase:InitVersionTask, bIsRoomType == " .. tostring(bIsRoomType))
      return
    end
    self.VersionTaskIDs = self:GetVersionTaskTlogIDs()
    self.bNeedInitVersionTask = true
  end
end
function PlayerStateBase:OnRep_bNeedInitVersionTask()
  print(bWriteLog and "PlayerStateBase:OnRep_bNeedInitVersionTask " .. tostring(self.bNeedInitVersionTask))
  if not self.bNeedInitVersionTask then
    return
  end
  if not self:IsThemeTaskOpen() then
    print(bWriteLog and "PlayerStateBase:OnRep_bNeedInitVersionTask, not theme task open")
    return
  end
  self.VersionTaskIDs = self:GetVersionTaskTlogIDs()
  self.VersionTaskTable = self:InitVersionTaskTable(self.VersionTaskIDs)
end
function PlayerStateBase:IsThemeTaskOpen()
  local TimeUtil = require("client.common.time_util")
  local ThemeOtherShowConfig = CDataTable.GetTable("ThemeOtherShowConfig")
  if not ThemeOtherShowConfig then
    print(bWriteLog and "PlayerStateBase:IsThemeTaskOpen, ThemeOtherShowConfig is nil")
    return false
  end
  local taskStartTimeStr = ThemeOtherShowConfig.task_show_start_time.value
  local taskEndTimeStr = ThemeOtherShowConfig.task_show_end_time.value
  local startTime = TimeUtil.TimeStringToUnixstamp(taskStartTimeStr)
  local endTime = TimeUtil.TimeStringToUnixstamp(taskEndTimeStr)
  local curTime = TimeUtil.GetServerTimeInSec()
  if startTime <= curTime and endTime > curTime then
    print(bWriteLog and "PlayerStateBase:IsThemeTaskOpen open")
    return true
  else
    print(bWriteLog and tostring(startTime) .. " " .. tostring(curTime) .. " " .. tostring(endTime))
    print(bWriteLog and "PlayerStateBase:IsThemeTaskOpen close")
    return false
  end
end
function PlayerStateBase:InitVersionTaskTable(TlogIDs)
  local TaskTable = {}
  for k, TlogID in pairs(TlogIDs) do
    if not TaskTable[TlogID] then
      TaskTable[TlogID] = {}
    end
    TaskTable[TlogID].ID = TlogID
    TaskTable[TlogID].CurProgress = self:GetValueByTLogIDInCounter(TlogID)
  end
  local ConfigDataTable = CDataTable.GetTable("ThemeModTaskConfig")
  for index, value in pairs(ConfigDataTable) do
    if TaskTable[value.TlogID] and TaskTable[value.TlogID].CurProgress >= value.Progress2 then
      TaskTable[value.TlogID] = nil
    end
  end
  return TaskTable
end
function PlayerStateBase:GetVersionTaskTlogIDs()
  local TlogIDs = {}
  local ThemeModTaskConfig = CDataTable.GetTable("ThemeModTaskConfig")
  local curVersion = ""
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType = GameMainConfig.GetModType()
  if Client then
    curVersion = Client.GetAppVersion()
  end
  for k, v in pairs(ThemeModTaskConfig) do
    if curVersion ~= "" then
      if (v.Mod == "" or v.Mod == ModType) and version_util.CompareVersionMain(curVersion, v.Version) == 0 then
        table.insert(TlogIDs, v.TlogID)
      end
    else
      table.insert(TlogIDs, v.TlogID)
    end
  end
  return TlogIDs
end
function PlayerStateBase:ClientRPC_VersionTaskChanged(TlogID, TaskValue)
  print(bWriteLog and "PlayerStateBase:ClientRPC_VersionTaskChanged TlogID: " .. TlogID .. " TaskValue: " .. TaskValue)
  if self.VersionTaskTable[TlogID] then
    self.VersionTaskTable[TlogID].CurProgress = TaskValue
  end
end
function PlayerStateBase:GetVersionTaskTable()
  return self.VersionTaskTable
end
function PlayerStateBase:CheckVersionTaskReady()
  return self.VersionTaskTable and next(self.VersionTaskTable)
end
function PlayerStateBase:ServerRPC_RecordOperationCount(OperationCount, bIsLast)
  log(bWriteLog and "PlayerStateBase:ServerRPC_RecordOperationCount, Record Start, bIsLast = " .. tostring(bIsLast))
  local OperationName = {
    "Crouch",
    "Prone",
    "Jump",
    "Fire",
    "Peek",
    "Reload",
    "SwitchWeapon",
    "Aim",
    "QuickMark",
    "Joystick"
  }
  if self.OperatingFrequencyReport and OperationCount:Num() == #OperationName then
    local OneRoundOperation = {
      CrouchNum = 0,
      ProneNum = 0,
      JumpNum = 0,
      FireNum = 0,
      PeekNum = 0,
      ReloadNum = 0,
      SwitchWeaponNum = 0,
      AimNum = 0,
      QuickMarkNum = 0,
      JoystickNum = 0
    }
    OneRoundOperation.CrouchNum = OperationCount:Get(0)
    OneRoundOperation.ProneNum = OperationCount:Get(1)
    OneRoundOperation.JumpNum = OperationCount:Get(2)
    OneRoundOperation.FireNum = OperationCount:Get(3)
    OneRoundOperation.PeekNum = OperationCount:Get(4)
    OneRoundOperation.ReloadNum = OperationCount:Get(5)
    OneRoundOperation.SwitchWeaponNum = OperationCount:Get(6)
    OneRoundOperation.AimNum = OperationCount:Get(7)
    OneRoundOperation.QuickMarkNum = OperationCount:Get(8)
    OneRoundOperation.JoystickNum = OperationCount:Get(9)
    table.insert(self.OperatingFrequencyReport, OneRoundOperation)
    if bIsLast then
      self:SendOperationReport()
    end
  end
  log(bWriteLog and "PlayerStateBase:ServerRPC_RecordOperationCount, Record End")
end
function PlayerStateBase:OnGameFinished()
  if self:HasAuthority() and not self.bPSEnsure then
    log(bWriteLog and "PlayerStateBase:OnGameFinished, bPSEnsure = false")
    self:AddGameTimer(3.0, false, function()
      self:SendOperationReport()
    end)
  end
end
function PlayerStateBase:SendOperationReport()
  if not self.bHasSendOperationResult and self.OperatingFrequencyReport then
    log(bWriteLog and "PlayerStateBase:SendOperationReport, Send OperatingFrequencyReport" .. ", PlayerKey:" .. tostring(self.PlayerKey) .. ", PlayerName:" .. tostring(self.PlayerName))
    self.bHasSendOperationResult = true
    local OperatingReport = {}
    OperatingReport.UID = self.UID
    OperatingReport.Data = self.OperatingFrequencyReport
    NetUtil.SendPacket("OperatingFrequencyReport", OperatingReport)
    log_tree(bWriteLog and "PlayerStateBase:SendOperationReport, OperatingFrequency = ", OperatingReport)
  end
end
function PlayerStateBase:AIPerceptionLeftBuyLifeCount()
  if Client then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_MLAI_CHARACTER_ATTRIBUTE_CHANGE, self.PlayerKey, 1000001, self.nLeftBuyLifeCounts)
end
function PlayerStateBase:OnAIAllocateSuccessReportAttributes(uMLAIController, uAIBotPawn)
  self:AIPerceptionLeftBuyLifeCount()
end
function PlayerStateBase:OnInitWithParams(UID, PlayerKey, PlayerType)
  if Client then
    return
  end
  if self.SyncDataFeature then
    self.SyncDataFeature:OnInitWithParams(UID, PlayerKey, PlayerType)
  end
end
function PlayerStateBase:MultiCast_GenericRPC(ID, Bytes)
  local GenericRPCEnums = require("GameLua.Mod.BaseMod.GamePlay.GenericRPC.GenericRPCEnums")
  local GenericRPCUtil = require("GameLua.Mod.BaseMod.GamePlay.GenericRPC.GenericRPCUtil")
  GenericRPCUtil._OnRecv(self, ID, GenericRPCEnums.EGenericRPCDirection.Multicast, Bytes)
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CPlayerStateBase = class(CActorBase, nil, PlayerStateBase)
return require("combine_class").DeclareFeature(CPlayerStateBase, {
  {
    PhotoGrapherFeature = "GameLua.Mod.Library.Gameplay.Feature.Camera.PhotoGrapherFeature"
  },
  {
    StoreFeature = "GameLua.Mod.BaseMod.GamePlay.Store.BRPlayerStateStoreFeature"
  },
  {
    TeammateTakeOverFeature = "GameLua.Mod.BaseMod.GamePlay.AI.TeammateTakeOverFeature"
  },
  {
    SyncDataFeature = "GameLua.GameCore.Feature.PlayerStateSyncDataFeature"
  }
}, "PlayerStateBase")