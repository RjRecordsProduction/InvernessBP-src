TaskManager = TaskManager or {}
Task_TState = {
  StateNone = 0,
  StateGot = 1,
  StateProgress = 2,
  StateDone = 3,
  StateComplete = 4,
  StateFail = 5
}
BaseOnlineTaskIdConfig = {
  101,
  102,
  103
}
TaskMakeUpConfig = {
  [101] = {
    TaskId = 200001,
    ActiveConfig = nil,
    ProgressConfig = {
      Operation = nil,
      Value = {
        Style = "IntProgress",
        CurValue = 0,
        AimValue = 10,
        EventType = "Trigger",
        EventName = EVENTID_PAWN_DIED
      }
    }
  },
  [102] = {
    TaskId = 200002,
    ActiveConfig = nil,
    ProgressConfig = {
      Operation = nil,
      Value = {
        Style = "OnlineTimeProgress",
        CurValue = 0,
        AimValue = 10,
        TimeInterval = 60
      }
    }
  },
  [103] = {
    TaskId = 200004,
    ActiveConfig = nil,
    ProgressConfig = {
      Operation = nil,
      Value = {
        Style = "IntReplaceProgress",
        CurValue = 0,
        AimValue = 1,
        EventType = "Trigger",
        EventName = EVENTID_FINISH_SOCAIL_ISLAND_INTERACT
      }
    }
  }
}
function TaskManager:SetTaskMakeUpConfig(MakeUpConfig)
  Taskend
function TaskManager:SetOnlineTaskConfig(OnlineConfig)
  BaseOnlineTaskIdConfig = OnlineConfig
end
function TaskManager:Init()
  TaskManager.TaskList = {}
  TaskManager.TaskPool = {}
  TaskManager:InitTaskPoor()
  EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, Task_HandleTriggerPlayerJoin)
  EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_REAL_EXIT, Task_HandleTriggerPlayerRealExit)
end
function TaskManager:InitTaskPoor()
  local TaskTable = CDataTable.GetTable("FightTaskInfo")
  for sRowName, RowData in pairs(TaskTable) do
    TaskManager.TaskPool[RowData.ID] = {
      ID = RowData.ID,
      Name = RowData.Name,
      Type = RowData.Type,
      Desc = RowData.Desc,
      Award = RowData.Award,
      JKAward = RowData.JKAward,
      FobidShow = RowData.FobidShow,
      AutoReward = RowData.AutoReward
    }
  end
end
function Task_HandleTriggerPlayerJoin(_, __, Player)
  print(bWriteLog and "HandleTriggerPlayerJoin")
  if not Game:IsValid(Player) then
    print(bWriteLog and "Task_HandleTriggerPlayerJoin uPlayer is Null")
    return
  end
  local PlayerKey = Game:GetPlayerKey(Player)
  if TaskManager.TaskList[PlayerKey] then
    return
  end
  TaskManager:InitPlayerTaskData(PlayerKey)
  TaskManager.CheckLobbyTask(PlayerKey)
end
function Task_HandleTriggerPlayerRealExit(_, __, PlayerKey)
  TaskManager:PlayerExit(PlayerKey)
end
function TaskManager.CheckLobbyTask(PlayerKey)
  if not PlayerKey then
    return
  end
  local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if not PlayerController then
    return
  end
  local UID = TaskManager.GetUID(PlayerController)
  local PlayerData = require("GameLua.Mod.SocialIsland.DS.PlayerData")
  local PlayerInfo = PlayerData.GetPlayerInfo(UID)
  if not PlayerInfo then
    return
  end
  if PlayerInfo.LuckmateUid == PlayerInfo.FriendUid and PlayerInfo.FriendUid ~= 0 then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAY_ADD_FRIEND, PlayerController)
  end
end
function TaskManager.IsJKVersion(PlayerKey)
  if not PlayerKey then
    return false
  end
  local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if not PlayerController then
    return false
  end
  local UID = TaskManager.GetUID(PlayerController)
  local PlayerData = require("GameLua.Mod.SocialIsland.DS.PlayerData")
  local PlayerInfo = PlayerData.GetPlayerInfo(UID)
  if not PlayerInfo then
    return false
  end
  if PlayerInfo.GameAppID ~= nil and string.find(PlayerInfo.GameAppID, "1321") then
    return true
  end
  return false
end
function TaskManager.RepGetAward(PlayerKey, TaskId)
  print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId)
  if TaskManager.TaskList and TaskManager.TaskList[PlayerKey] then
    local TaskDetailList = TaskManager.TaskList[PlayerKey].TaskDetailList
    if TaskDetailList then
      for index = 1, #TaskDetailList do
        if TaskDetailList[index] and TaskDetailList[index].TaskId == TaskId then
          if TaskDetailList[index].State == Task_TState.StateDone then
            local AwardList = {}
            if TaskManager.TaskPool[TaskId] then
              local AllAwardStr = TaskManager.IsJKVersion(PlayerKey) and TaskManager.TaskPool[TaskId].JKAward or TaskManager.TaskPool[TaskId].Award
              print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId .. " AllAwardStr:" .. AllAwardStr)
              if AllAwardStr ~= "" then
                local AwardStrList = Game:SplitString(AllAwardStr, ";")
                if 0 < #AwardStrList then
                  for StrIndex = 1, #AwardStrList do
                    local AwardStuctStr = Game:SplitString(AwardStrList[StrIndex], ":")
                    local Player = Game:GetPlayerByPlayerKey(PlayerKey)
                    if Player then
                      AwardList[#AwardList + 1] = {
                        ItemId = tonumber(AwardStuctStr[1]),
                        ItemNum = tonumber(AwardStuctStr[2])
                      }
                      if TaskId == 200005 or TaskId == 200006 or TaskId == 200007 or TaskId == 200008 or TaskId == 200009 then
                        CGameState:NotifyPlayerGetNewAlias(Player.PlayerUID, tonumber(AwardStuctStr[1]))
                      else
                        Game:AddItemByResID(Player, tonumber(AwardStuctStr[1]), tonumber(AwardStuctStr[2]))
                      end
                      print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId .. " Award:" .. AwardStuctStr[1])
                    end
                  end
                end
              end
            else
              print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId .. " error TaskPool doesn't has this task")
            end
            TaskDetailList[index].State = Task_TState.StateComplete
            print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId .. " AddItemByResID ok, task state is StateComplete")
            local CurValue = 0
            if TaskDetailList[index].ProgressList and TaskDetailList[index].ProgressList[1] then
              CurValue = TaskDetailList[index].ProgressList[1].CurValue
            end
            if next(AwardList) then
              CGame:TaskRecordRewardInfo(TaskDetailList[index].PlayerKey, TaskDetailList[index].TaskId, AwardList)
            end
            CGame:TaskModifyTask(TaskDetailList[index].PlayerKey, TaskDetailList[index].TaskId, CurValue, TaskDetailList[index].State)
            return
          else
            print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId .. " error TaskSate is:" .. TaskDetailList[index].State)
          end
        end
      end
    else
      print(bWriteLog and "TaskManager.RepGetAward Key" .. PlayerKey .. " TaskID:" .. TaskId .. " TaskDetailList is nil")
    end
  end
end
function TaskManager.RefreshTaskStoreInfo(PlayerKey)
  local TaskValue = TaskManager.TaskList[PlayerKey]
  if not TaskValue then
    return
  end
  local TaskDetailList = TaskValue.TaskDetailList
  if TaskDetailList then
    TaskManager.AddRandomTaskTo(TaskDetailList, PlayerKey)
    local TaskSyncList = {}
    for index = 1, #TaskDetailList do
      TaskDetailList[index]:RefreshTaskStoreInfo()
      local TaskSync = {}
      TaskSync.TaskId = TaskDetailList[index].TaskId
      TaskSync.State = TaskDetailList[index].State
      TaskSync.CurProgress = TaskDetailList[index].ProgressList[1].CurValue
      TaskSync.AimProgress = TaskDetailList[index].ProgressList[1].AimValue
      TaskSync.FobidShow = TaskDetailList[index].FobidShow
      TaskSync.TaskType = TaskDetailList[index].TaskType
      TaskSyncList[#TaskSyncList + 1] = TaskSync
    end
    CGame:TaskSyncList(PlayerKey, TaskSyncList)
  end
end
function TaskManager.AddRandomTaskTo(TaskDetailList, PlayerKey)
  print(bWriteLog and "TaskManager.AddRandomTaskTo PlayerKey:" .. PlayerKey)
  local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if Game:IsValid(PlayerController) then
    local TaskStore = PlayerController.DailyTaskStoreList
    if TaskStore then
      for i = 0, TaskStore:Num() - 1 do
        local TaskData = TaskStore:Get(i)
        local bFind = false
        for index = 1, #TaskDetailList do
          if TaskDetailList[index].TaskId == TaskData.TaskId then
            bFind = true
            break
          end
        end
        if not bFind then
          local ObjectTemp = {}
          local class = require("class")
          local TTaskBase = require("GameLua.Mod.Library.DS.Task.NTaskBase")
          local CObjectPool = class(TTaskBase, nil, ObjectTemp)
          local Task = CObjectPool()
          Task.          local TaskConfig = TaskManager.GetTaskMakeUpConfig(TaskData.TaskId)
          if TaskConfig then
            Task:Init(TaskConfig)
            local TaskDetailList = TaskManager.TaskList[PlayerKey].TaskDetailList
            TaskDetailList[#TaskDetailList + 1] = Task
            print(bWriteLog and "TaskInfo-- CreatePlayerTask " .. PlayerKey .. " " .. Task.TaskId)
            EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_TASK_CREATE, Task.PlayerKey, Task.TaskId)
          end
        end
      end
    end
  end
end
function TaskManager.GetTaskMakeUpConfig(TaskId)
  for nIndex, uTaskData in pairs(TaskMakeUpConfig) do
    if uTaskData.TaskId == TaskId then
      return uTaskData
    end
  end
  return nil
end
function TaskManager.CollapseTaskInfo(PlayerKey)
  local TaskValue = TaskManager.TaskList[PlayerKey]
  if not TaskValue then
    return
  end
  local TaskDetailList = TaskValue.TaskDetailList
  if TaskDetailList and 0 < #TaskDetailList then
    for index = 1, #TaskDetailList do
      if TaskDetailList[index] then
        TaskDetailList[index]:CollapseTaskInfo()
      end
    end
  end
  TaskManager.RefreshTaskStoreInfo(PlayerKey)
end
function TaskManager:PlayerExit(PlayerKey)
  if TaskManager.TaskList and TaskManager.TaskList[PlayerKey] then
    local TaskDetailList = TaskManager.TaskList[PlayerKey].TaskDetailList
    if TaskDetailList then
      for index = 1, #TaskDetailList do
        if TaskDetailList[index] then
          TaskDetailList[index]:ClearEvents()
        end
      end
    end
    TaskManager.TaskList[PlayerKey] = nil
  end
end
function TaskManager:InitPlayerTaskData(PlayerKey)
  for index, value in ipairs(BaseOnlineTaskIdConfig) do
    TaskManager:CreatePlayerTask(PlayerKey, value)
  end
  if TaskManager.TaskList and TaskManager.TaskList[PlayerKey] then
    local TaskDetailList = TaskManager.TaskList[PlayerKey].TaskDetailList
    TaskManager.AddRandomTaskTo(TaskDetailList, PlayerKey)
    if TaskDetailList then
      local TaskSyncList = {}
      for index = 1, #TaskDetailList do
        local TaskSync = {}
        TaskSync.TaskId = TaskDetailList[index].TaskId
        TaskSync.State = TaskDetailList[index].State
        TaskSync.CurProgress = TaskDetailList[index].ProgressList[1].CurValue
        TaskSync.AimProgress = TaskDetailList[index].ProgressList[1].AimValue
        TaskSync.FobidShow = TaskDetailList[index].FobidShow
        TaskSync.TaskType = TaskDetailList[index].TaskType
        TaskSyncList[#TaskSyncList + 1] = TaskSync
      end
      CGame:TaskSyncList(PlayerKey, TaskSyncList)
    end
  end
end
function TaskManager:CreatePlayerTask(PlayerKey, TaskConfigId)
  if PlayerKey <= 0 then
    return
  end
  if not TaskMakeUpConfig[TaskConfigId] then
    return
  end
  if 0 >= TaskMakeUpConfig[TaskConfigId].TaskId then
    return
  end
  if not TaskManager.TaskList then
    return
  end
  if not TaskManager.TaskList[PlayerKey] then
    TaskManager.TaskList[PlayerKey] = {}
    TaskManager.TaskList[PlayerKey].TaskDetailList = {}
    TaskManager.TaskList[PlayerKey].TaskSyncList = {}
  end
  local ObjectTemp = {}
  local class = require("class")
  local TTaskBase = require("GameLua.Mod.Library.DS.Task.NTaskBase")
  local CObjectPool = class(TTaskBase, nil, ObjectTemp)
  local Task = CObjectPool()
  Task.  Task:Init(TaskMakeUpConfig[TaskConfigId])
  local TaskDetailList = TaskManager.TaskList[PlayerKey].TaskDetailList
  TaskDetailList[#TaskDetailList + 1] = Task
  print(bWriteLog and "TaskInfo-- CreatePlayerTask " .. PlayerKey .. " " .. Task.TaskId)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_TASK_CREATE, Task.PlayerKey, Task.TaskId)
end
function TaskManager.ChangeMakeWishCount(uPlayerController)
  if uPlayerController and Game:IsValid(uPlayerController) and uPlayerController.PlayerKey and TaskManager.TaskList then
    local TaskDetailList = TaskManager.TaskList[uPlayerController.PlayerKey].TaskDetailList
    if TaskDetailList then
      for index = 1, #TaskDetailList do
        if TaskDetailList[index].TaskId == 200301 then
          if TaskDetailList[index].ProgressList[1].AimValue == 1 then
            TaskDetailList[index].ProgressList[1].AimValue = 10000
          else
            TaskDetailList[index].ProgressList[1].AimValue = 1
          end
          TaskDetailList[index].ProgressList[1].CurValue = 0
          CGame:TaskModifyTask(uPlayerController.PlayerKey, 200301, 0, 2)
          break
        end
      end
    end
  end
end
function TaskManager:CreateTask(TaskConfigId)
  if not TaskMakeUpConfig[TaskConfigId] then
    return
  end
  local TaskCon = TaskMakeUpConfig[TaskConfigId]
  if not BaseOnlineTaskIdConfig[TaskCon.TaskId] then
    return
  end
  if not TaskManager.TaskPool[TaskCon.TaskId] then
    return
  end
end
function TaskManager.GetUID(uController)
  if not Game:IsValid(uController) then
    return 0
  end
  local UID = uController.UID or 0
  if UID <= 0 then
    if Game:IsValid(uController.PlayerState) then
      UID = uController.PlayerState.UID or 0
    end
    if UID <= 0 and uController.GetPlayerCharacterSafety then
      local Character = uController:GetPlayerCharacterSafety()
      if Character and Character.GetPlayerStateSafety then
        local uPlayerState = Character:GetPlayerStateSafety()
        if uPlayerState then
          UID = uPlayerState.UID
        end
      end
    end
  end
  return UID
end
local class = require("class")
local object = require("object")
local CTaskManager = class(object, nil, TaskManager)
return CTaskManager