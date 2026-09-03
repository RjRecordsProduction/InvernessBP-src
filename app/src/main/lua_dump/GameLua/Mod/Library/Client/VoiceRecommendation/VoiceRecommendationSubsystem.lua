local VoiceRecommendationSubsystem = {}
local UGameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local EGameModeType = import("EGameModeType")
function VoiceRecommendationSubsystem:_PostConstruct()
  print(bWriteLog and "VoiceRecommendationSubsystem:_PostConstruct")
end
function VoiceRecommendationSubsystem:OnRegister()
  print(bWriteLog and "VoiceRecommendationSubsystem:OnRegister")
  self.ConditionTable = {}
  self.TotalRecommendationTimes = {}
  self.UseRecommendationTimes = {}
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnBattleResult, self)
  self:InitVoiceCondition()
end
function VoiceRecommendationSubsystem:AddTotalRecommendationTimes(VoiceType)
  if not VoiceType then
    return
  end
  if not self.TotalRecommendationTimes[VoiceType] then
    self.TotalRecommendationTimes[VoiceType] = 0
  end
  self.TotalRecommendationTimes[VoiceType] = self.TotalRecommendationTimes[VoiceType] + 1
  self:SetFrequencyTLog(VoiceType)
end
function VoiceRecommendationSubsystem:AddUseRecommendationTimes(VoiceType)
  if not VoiceType then
    return
  end
  if not self.UseRecommendationTimes[VoiceType] then
    self.UseRecommendationTimes[VoiceType] = 0
  end
  self.UseRecommendationTimes[VoiceType] = self.UseRecommendationTimes[VoiceType] + 1
  self:SetFrequencyTLog(VoiceType)
end
function VoiceRecommendationSubsystem:SetFrequencyTLog(VoiceType)
  local ClientTLogManager = SubsystemMgr:Get("ClientTLogManager")
  if not ClientTLogManager then
    return
  end
  if not self.InitTLog then
    ClientTLogManager:SetValueByIndex("VoiceRecommendation", 1, 0)
    ClientTLogManager:SetValueByIndex("VoiceRecommendation", 2, 0)
    ClientTLogManager:SetValueByIndex("VoiceRecommendation", 3, 0)
    ClientTLogManager:SetValueByIndex("VoiceRecommendation", 4, 0)
    self.InitTLog = true
    print(bWriteLog and "VoiceRecommendationSubsystem:InitTLog ")
  end
  if self.TotalRecommendationTimes[VoiceType] == nil or self.TotalRecommendationTimes[VoiceType] == 0 or self.UseRecommendationTimes[VoiceType] == nil then
    ClientTLogManager:SetValueByIndex("VoiceRecommendation", VoiceType, 0)
    return
  end
  local UseFrequency = self.UseRecommendationTimes[VoiceType] / self.TotalRecommendationTimes[VoiceType]
  if 1 < UseFrequency then
    UseFrequency = 1
  end
  UseFrequency = math.floor(UseFrequency * 1000)
  ClientTLogManager:SetValueByIndex("VoiceRecommendation", VoiceType, UseFrequency)
end
function VoiceRecommendationSubsystem:InitVoiceCondition()
  local VoiceRecommendationConfig = GamePlayTools.GetCurrentConfig("VoiceRecommendationConfig")
  if not VoiceRecommendationConfig or not VoiceRecommendationConfig.VoiceConfig then
    return
  end
  for key, VoiceConfigItem in pairs(VoiceRecommendationConfig.VoiceConfig) do
    local ConfigCondition = VoiceConfigItem.Condition
    if ConfigCondition then
      local ConditionItemClass = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendConditionItem")
      local ConditionItem = ConditionItemClass(ConfigCondition)
      local NewCondition = {
        Condition = ConditionItem,
        Priority = VoiceConfigItem.Priority,
        Voice = VoiceConfigItem.Voice,
        Type = VoiceConfigItem.Type
      }
      table.insert(self.ConditionTable, NewCondition)
    end
  end
  table.sort(self.ConditionTable, function(a, b)
    return a.Priority < b.Priority
  end)
end
function VoiceRecommendationSubsystem:DoCheckCondition()
  if self.bIsBattleOver then
    return nil, -1
  end
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) and (uGameState.GameModeType == EGameModeType.EDeathMatchGameMode or uGameState.GameModeType == EGameModeType.EVehicleWar_CAMP or uGameState.GameModeType == EGameModeType.EXAndT) then
    return nil, -1
  end
  self.TeammateLocAndPos = {}
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return nil, -1
  end
  local uTeammateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if not uTeammateList then
    return nil, -1
  end
  local HasTeammate = false
  self.MyLoc = uPlayerState:GetPlayerCurLoc()
  for Index, TeammateState in pairs(uTeammateList) do
    if slua.isValid(TeammateState) then
      local TeammateLoc = TeammateState:GetPlayerCurLoc()
      local TeammateDis = FVector.DistSquared2D(self.MyLoc, TeammateLoc)
      self.TeammateLocAndPos[Index] = {Location = TeammateLoc, Distance = TeammateDis}
      HasTeammate = true
    end
  end
  if not HasTeammate then
    return nil, -1
  end
  for Index, ConditionInfo in pairs(self.ConditionTable) do
    if ConditionInfo.Condition:DoCheckCondition() then
      print(bWriteLog and "VoiceRecommendationSubsystem:DoCheckCondition Type: " .. ConditionInfo.Type)
      return ConditionInfo.Voice, ConditionInfo.Type
    end
  end
  return nil, -1
end
function VoiceRecommendationSubsystem:GetTeammateLocation(Index)
  if self.TeammateLocAndPos and self.TeammateLocAndPos[Index] then
    return self.TeammateLocAndPos[Index].Location
  else
    return nil
  end
end
function VoiceRecommendationSubsystem:GetTeammateDistance(Index)
  if self.TeammateLocAndPos and self.TeammateLocAndPos[Index] then
    return self.TeammateLocAndPos[Index].Distance
  else
    return nil
  end
end
function VoiceRecommendationSubsystem:OnBattleResult()
  print(bWriteLog and "VoiceRecommendationSubsystem:OnBattleResult")
  self.bIsBattleOver = true
end
function VoiceRecommendationSubsystem:OnRelease()
  print(bWriteLog and "VoiceRecommendationSubsystem:OnRelease")
  VoiceRecommendationSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VoiceRecommendationSubsystem)