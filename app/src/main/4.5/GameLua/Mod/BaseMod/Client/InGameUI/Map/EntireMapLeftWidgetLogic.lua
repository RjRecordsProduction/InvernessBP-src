local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local VersionTaskType = 101
local version_util = require("client.common.version_util")
local FXTaskStateType = import("FXTaskStateType")
local EntireMapLeftWidgetLogic = {}
function EntireMapLeftWidgetLogic:ctor()
  self.LocalData = {}
  self.AllComplete = false
  self.LuaTaskComp = nil
end
function EntireMapLeftWidgetLogic:TestData()
  self.bIsCheat = true
  self.TestTable = {}
  local DataCfg = CDataTable.GetTable("LobbyToFightTaskInfo")
  if DataCfg then
    for ID, data in pairs(DataCfg) do
      if data.TaskDesc ~= "" then
        local pt = {}
        pt.TaskType = 1
        pt.CurProgress = 0
        pt.AimProgress = 0
        pt.TaskId = ID
        pt.State = FXTaskStateType.StateGot
        table.insert(self.TestTable, pt)
      end
    end
  end
  self:RefreshData()
end
function EntireMapLeftWidgetLogic:RefreshData()
  if self.bIsCheat then
    local TestTaskData = self.TestTable
    self:ConstructLocalData(TestTaskData)
    self.LastTaskData = TestTaskData
    return
  end
  if not slua.isValid(self.LuaTaskComp) then
    local LocalController = GameplayData.GetPlayerController()
    if not slua.isValid(LocalController) then
      return
    end
    local uLuaTaskComponent = import("LuaTaskComponent")
    self.LuaTaskComp = LocalController:GetComponentByClass(uLuaTaskComponent)
    if not slua.isValid(self.LuaTaskComp) then
      print(bWriteLog and "EntireMapLeftWidgetLogic:SetData Failed Case LuaTask Nil")
      return
    end
  end
  local TaskData = self.LuaTaskComp.TaskSyncList
  local GrowData = {}
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.ThemeTaskFeature then
    GrowData = uPlayerState.ThemeTaskFeature:GetGrowData()
  end
  local VersionTaskData = {}
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.GetVersionTaskTable then
    VersionTaskData = uPlayerState:GetVersionTaskTable()
  end
  if 0 < #GrowData then
    local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
    if slua.isValid(uPlayerState) and ThemeTaskConfig.DetailTLog and type(ThemeTaskConfig.DetailTLog) == "table" then
      for _, TLogID in pairs(ThemeTaskConfig.DetailTLog) do
        uPlayerState:RPC_ServerAddGeneralCount(TLogID, 1, false)
      end
    end
  end
  self:ConstructLocalData(TaskData, GrowData, VersionTaskData)
  self.Lastend
function EntireMapLeftWidgetLogic:ConstructLocalData(TaskData, GrowData, VersionTaskData)
  self.LocalData = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  self.AllComplete = true
  if GrowData then
    for index, value in pairs(GrowData) do
      self.AllComplete = false
      if value.ShouldHide == 0 then
        local ContentData = self.LocalData[1]
        local NewSubIndex = #ContentData + 1
        ContentData[NewSubIndex] = {
          ID = value.ID,
          Percent = value.CurPercent,
          CurProgress = value.CurProgress,
          AimProgress = value.AimProgress,
          DataType = 1,
          LockState = value.LockState
        }
      end
    end
  end
  if VersionTaskData then
    if not self.LocalData[VersionTaskType] then
      self.LocalData[VersionTaskType] = {}
    end
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType = GameMainConfig.GetModType()
    local ConfigDataTable = CDataTable.GetTable("ThemeModTaskConfig")
    for index, value in pairs(ConfigDataTable) do
      local bTime = true
      local TimeUtil = require("client.common.time_util")
      local curTime = TimeUtil.GetServerTimeInSec()
      if value.StartTime and value.StartTime ~= "" then
        local startTime = TimeUtil.TimeStringToUnixstamp(value.StartTime)
        if curTime < startTime then
          bTime = false
        end
      end
      if value.EndTime and value.EndTime ~= "" then
        local endTime = TimeUtil.TimeStringToUnixstamp(value.EndTime)
        if curTime > endTime then
          bTime = false
        end
      end
      if bTime and (value.Mod == "" or value.Mod == ModType) then
        local curVersion = Client.GetAppVersion()
        if curVersion and version_util.CompareVersionMain(curVersion, value.Version) == 0 and VersionTaskData[value.TlogID] then
          self.AllComplete = false
          local ContentData = self.LocalData[VersionTaskType]
          local NewSubIndex = #ContentData + 1
          if not ContentData[value.TlogID] then
            ContentData[value.TlogID] = {}
          end
          local CurValue = VersionTaskData[value.TlogID].CurProgress
          local Curpercent = 0
          local CurAimProgress = value.Progress1
          local CurAimItem = value.ItemID1
          if value.Progress1 == 0 then
            CurAimProgress = value.Progress2
            CurAimItem = value.ItemID2
            Curpercent = CurValue / value.Progress2
          elseif CurValue > value.Progress1 then
            Curpercent = CurValue / value.Progress2
          else
            Curpercent = CurValue / value.Progress1
          end
          ContentData[NewSubIndex] = {
            ID = value.TlogID,
            Percent = Curpercent,
            CurProgress = CurValue,
            TaskName = value.TaskName,
            AimProgress = CurAimProgress,
            AimProgress2 = value.Progress2,
            ItemID1 = CurAimItem,
            ItemID2 = value.ItemID2,
            DataType = 4
          }
        end
      end
    end
  end
  for index, value in pairs(TaskData) do
    local typeIndex = value.TaskType + 1
    if not self.LocalData[typeIndex] then
      self.LocalData[typeIndex] = {}
    end
    local ContentData = self.LocalData[typeIndex]
    local newSubIndex = #ContentData + 1
    local curValuePercent = 0.0
    if 0 < value.AimProgress then
      curValuePercent = value.CurProgress / value.AimProgress
    end
    ContentData[newSubIndex] = {
      ID = value.TaskId,
      Percent = curValuePercent,
      CurProgress = value.CurProgress,
      AimProgress = value.AimProgress,
      DataType = 2
    }
    if self.AllComplete and value.State == FXTaskStateType.StateGot or value.State == FXTaskStateType.StateProgress then
      self.AllComplete = false
    end
  end
  self:SortLocalData()
  log_tree("EntireMapLeftWidgetLogic:ConstructLocalData LocalData", self.LocalData)
end
function EntireMapLeftWidgetLogic:SortLocalData()
  for index, value in pairs(self.LocalData) do
    if index == 1 then
      table.sort(value, function(a, b)
        return a.ID < b.ID
      end)
    else
      table.sort(value, function(a, b)
        return a.Percent > b.Percent
      end)
    end
  end
end
function EntireMapLeftWidgetLogic:GetTaskData()
  return self.LocalData
end
function EntireMapLeftWidgetLogic:CheckTaskComplete()
  return self.AllComplete
end
function EntireMapLeftWidgetLogic:ResetData()
  self.LocalData = {}
  self.AllComplete = true
end
function EntireMapLeftWidgetLogic:OnRelease()
  self.LuaTaskComp = nil
  EntireMapLeftWidgetLogic.__super.OnRelease(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CDelegateContainer, nil, EntireMapLeftWidgetLogic)