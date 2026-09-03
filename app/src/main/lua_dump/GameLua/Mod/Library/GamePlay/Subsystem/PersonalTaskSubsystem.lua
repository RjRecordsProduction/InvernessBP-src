local PersonalTaskSubsystem = {}
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local TableUtil = require("common.table_util")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local DSSwitchID = 103
function PersonalTaskSubsystem:OnInit()
  print(bWriteLog and "PersonalTaskSubsystem:OnInit")
  if not slua.isValid(CGameState) or Client then
    return
  end
  local DSSwitchOpen = Game:GetDSSwitchValue(DSSwitchID, true)
  if not DSSwitchOpen or DSSwitchOpen == "" and not CGame:IsEditor() then
    print(bWriteLog and "PersonalTaskSubsystem:OnInit return by DSSwitchOpen DSSwitchOpen:", DSSwitchOpen)
    return
  end
  if GamePlayTools.IsBlueHoleVersion() then
    print(bWriteLog and "PersonalTaskSubsystem:OnInit return by BlueHoleVersion")
    return
  end
  self.TeamIDToTaskIDMap = {}
  self.TeamIDToPlayerMap = {}
  self.PlayerToTaskDataMap = {}
  self:InitConfig()
  if not self.TaskConfig or not self.RawConfig then
    print(bWriteLog and "PersonalTaskSubsystem:OnInit return by TaskConfig")
    return
  end
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.OnFightingState, self)
end
function PersonalTaskSubsystem:OnRelease()
  if self.PlayerToTaskDataMap then
    for key, value in pairs(self.PlayerToTaskDataMap) do
      if value.MapMarkAction then
        InGameMarkTools.HideMapMark(value.MapMarkAction)
        value.MapMarkAction = nil
        print(bWriteLog and "PersonalTaskSubsystem:OnRelease MapMarkAction")
      end
    end
  end
end
function PersonalTaskSubsystem:InitConfig()
  local MapType = GameMainConfig.GetMapType()
  local ModeID = GameMainConfig.GetModeID()
  local PersonalTaskConfig = GamePlayTools.GetCurrentConfig("PersonalTaskConfig")
  if not PersonalTaskConfig or not PersonalTaskConfig.Default then
    print(bWriteLog and "PersonalTaskSubsystem:InitConfig Error Config!!!")
    return
  end
  if not PersonalTaskConfig.EnableModeIDs or TableUtil.Find(PersonalTaskConfig.EnableModeIDs, ModeID) < 0 then
    print(bWriteLog and "PersonalTaskSubsystem:InitConfig return PersonalTaskConfig.EnableModeIDs!!! ModeID:", ModeID)
    return
  end
  local TempTaskConfig = TableUtil.DeepCloneTable(PersonalTaskConfig.Default)
  if PersonalTaskConfig[MapType] then
    TableUtil.OverrideTable(TempTaskConfig, PersonalTaskConfig[MapType])
  end
  self.TaskConfig = TempTaskConfig
  self.RawConfig = PersonalTaskConfig
  print(bWriteLog and "PersonalTaskSubsystem:InitConfig MapType:", MapType)
end
function PersonalTaskSubsystem:OnFightingState()
  self:GenerateTaskList()
  self:GenerateTaskActors()
end
function PersonalTaskSubsystem:GenerateTaskList()
  local AllPlayerPawn = Game:GetAllPlayerPawns()
  local RandomConfig = {}
  for key, value in pairs(self.TaskConfig) do
    if not value.Weight then
      print(bWriteLog and "PersonalTaskSubsystem:GenerateTaskList Error Config not Weight key:", key)
      return
    end
    RandomConfig[key] = value.Weight
  end
  for key, PlayerPawn in pairs(AllPlayerPawn) do
    if slua.isValid(PlayerPawn) and not Game:IsAI(PlayerPawn) then
      local TeamID = PlayerPawn.TeamID
      if not self.TeamIDToTaskIDMap[TeamID] then
        local tResult = Game:RandomByWeight(RandomConfig, 1)
        self.TeamIDToTaskIDMap[TeamID] = tResult[1]
        self.TeamIDToPlayerMap[TeamID] = {}
        print(bWriteLog and "PersonalTaskSubsystem:GenerateTaskList Result TeamID:", TeamID, " Result:", tResult[1])
      end
      table.insert(self.TeamIDToPlayerMap[TeamID], PlayerPawn)
    end
  end
end
function PersonalTaskSubsystem:GenerateTaskActors()
  if not slua.isValid(CGameWorld) then
    return
  end
  for taskId, taskConfig in pairs(self.TaskConfig) do
    if taskConfig.SpawnTime then
      self:AddGameTimer(taskConfig.SpawnTime, false, function()
        self:HandleSpawnByTaskID(taskId)
      end)
    end
    if taskConfig.DestroyTime then
      self:AddGameTimer(taskConfig.DestroyTime, false, function()
        self:HandleDestroyByTaskID(taskId)
      end)
    end
  end
end
function PersonalTaskSubsystem:HandleSpawnByTaskID(InTaskID)
  for TeamID, nTaskID in pairs(self.TeamIDToTaskIDMap) do
    local CurTaskConfig = self.TaskConfig[nTaskID]
    local ActorPath = CurTaskConfig.Path
    if nTaskID == InTaskID and ActorPath and CurTaskConfig.PositionsKey and self.RawConfig[CurTaskConfig.PositionsKey] then
      local CurPointsConfig = self.RawConfig[CurTaskConfig.PositionsKey]
      local PlayerList = self.TeamIDToPlayerMap[TeamID]
      local ActorClass = slua.loadClass(ActorPath)
      local CenterPos = CurPointsConfig.CenterPos
      local TempPointsCopy = TableUtil.DeepCloneTable(CurPointsConfig.Positions)
      TempPointsCopy = Game:Shuffle(TempPointsCopy)
      local CurPointIndex = 1
      for key, uPlayer in pairs(PlayerList) do
        if slua.isValid(uPlayer) and ActorClass then
          local PlayerData = {
            ActorList = {},
            TaskID = nTaskID,
            MapMarkAction = nil
          }
          for i = 1, CurTaskConfig.Count do
            if CurPointIndex <= #TempPointsCopy then
              local Pos = FVector(TempPointsCopy[CurPointIndex][1].X, TempPointsCopy[CurPointIndex][1].Y, TempPointsCopy[CurPointIndex][1].Z)
              local Rot = FRotator(TempPointsCopy[CurPointIndex][2].Pitch, TempPointsCopy[CurPointIndex][2].Yaw, TempPointsCopy[CurPointIndex][2].Roll)
              local TaskActor = CGameWorld:SpawnActor(ActorClass, Pos, Rot, nil)
              if slua.isValid(TaskActor) and TaskActor.SetTaskOwner then
                TaskActor:SetTaskOwner(uPlayer, CurTaskConfig)
                table.insert(PlayerData.ActorList, TaskActor)
              end
              print(bWriteLog and "PersonalTaskSubsystem:GenerateTaskActors nTaskID:", nTaskID, " i:", i, " Pos:", Pos:ToString(), " CurPointIndex:", CurPointIndex)
              CurPointIndex = CurPointIndex + 1
            else
              print(bWriteLog and "PersonalTaskSubsystem:GenerateTaskActors Error Count nTaskID:", nTaskID)
            end
          end
          if CurTaskConfig.MapMarkID then
            local PlayerState = uPlayer:GetPlayerStateSafety()
            local MapMark = InGameMarkTools.ServerAddMapMark(CurTaskConfig.MapMarkID, CenterPos, nil, nil, nil, 0, PlayerState)
            PlayerData.MapMarkAction = MapMark
          end
          self.PlayerToTaskDataMap[uPlayer.PlayerKey] = PlayerData
        end
      end
    end
  end
end
function PersonalTaskSubsystem:HandleDestroyByTaskID(InTaskID)
  print(bWriteLog and "PersonalTaskSubsystem:HandleDestroyByTaskID InTaskID:", InTaskID)
  for nPlayerKey, PlayerData in pairs(self.PlayerToTaskDataMap) do
    if PlayerData and PlayerData.TaskID == InTaskID then
      if PlayerData.ActorList then
        for _, uActor in pairs(PlayerData.ActorList) do
          if slua.isValid(uActor) then
            uActor:K2_DestroyActor()
          end
        end
      end
      if PlayerData.MapMarkAction then
        InGameMarkTools.HideMapMark(PlayerData.MapMarkAction)
        PlayerData.MapMarkAction = nil
      end
    end
  end
  print(bWriteLog and "PersonalTaskSubsystem:HandleDestroyByTaskID Finished InTaskID:", InTaskID)
end
function PersonalTaskSubsystem:OnFinishActor(InPlayerKey, InActor)
  local PlayerData = self.PlayerToTaskDataMap[InPlayerKey]
  if PlayerData and PlayerData.ActorList then
    print(bWriteLog and "PersonalTaskSubsystem:OnFinishActor Finished InPlayerKey:", InPlayerKey, " PlayerData.TaskID:", PlayerData.TaskID)
    TableUtil.Remove(PlayerData.ActorList, InActor)
    if #PlayerData.ActorList < 1 and PlayerData.MapMarkAction then
      InGameMarkTools.HideMapMark(PlayerData.MapMarkAction)
      PlayerData.MapMarkAction = nil
      print(bWriteLog and "PersonalTaskSubsystem:OnFinishActor Finished Remove MapMarkAction InPlayerKey:", InPlayerKey, " PlayerData.TaskID:", PlayerData.TaskID)
    end
  end
end
function PersonalTaskSubsystem:GMSpawnAllActor(uPlayer)
  print(bWriteLog and "PersonalTaskSubsystem:GMSpawnAllActor")
  for taskId, CurTaskConfig in pairs(self.TaskConfig) do
    if CurTaskConfig.Path then
      local ActorClass = slua.loadClass(CurTaskConfig.Path)
      if ActorClass and CurTaskConfig.PositionsKey and self.RawConfig[CurTaskConfig.PositionsKey] then
        local PointConfig = self.RawConfig[CurTaskConfig.PositionsKey].Positions
        for CurPointIndex, value in pairs(PointConfig) do
          local Pos = FVector(PointConfig[CurPointIndex][1].X, PointConfig[CurPointIndex][1].Y, PointConfig[CurPointIndex][1].Z)
          local Rot = FRotator(PointConfig[CurPointIndex][2].Pitch, PointConfig[CurPointIndex][2].Yaw, PointConfig[CurPointIndex][2].Roll)
          local TaskActor = CGameWorld:SpawnActor(ActorClass, Pos, Rot, nil)
          if slua.isValid(TaskActor) and TaskActor.SetTaskOwner then
            TaskActor:SetTaskOwner(uPlayer, CurTaskConfig)
            print(bWriteLog and "PersonalTaskSubsystem:GMSpawnAllActor Spawn Actor:", CurTaskConfig.Path, " Pos:", Pos:ToString(), " Rot:", Rot:ToString())
          end
        end
      end
    end
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, PersonalTaskSubsystem)