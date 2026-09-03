local ResultTaskSubsystem = {}
local receiveFirstMsg = false
local receiveSecondMsg = false
function ResultTaskSubsystem:OnInit()
  log(bWriteLog and "ResultTaskSubsystem:OnInit")
  self.UICloseCb = nil
  receiveFirstMsg = false
  receiveSecondMsg = false
  local ResultTask_Config = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Config")
  for _, config in pairs(ResultTask_Config.Configs) do
    local module = require(config.Logic)
    if module.OnInit then
      module:OnInit()
    end
  end
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_RESULT_RANKING_TASK_UI_CLOSE, self.OnBattleResultTaskUIClose, self)
end
function ResultTaskSubsystem:OnRelease()
  log(bWriteLog and "ResultTaskSubsystem:OnRelease")
  local ResultTask_Config = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Config")
  for _, config in pairs(ResultTask_Config.Configs) do
    local module = require(config.Logic)
    if module.OnUnInit then
      module:OnUnInit()
    end
  end
  self.UICloseCb = nil
  receiveFirstMsg = false
  receiveSecondMsg = false
  ResultTaskSubsystem.__super.OnRelease(self)
end
function ResultTaskSubsystem:CheckShowResultTaskUI(closeCb, resultData)
  log(bWriteLog and "ResultTaskSubsystem:CheckShowResultTaskUI")
  if not self:CheckCanShowResultTaskUI(resultData) then
    log(bWriteLog and "ResultTaskSubsystem:CheckShowResultTaskUI CheckCanShowResultTaskUI false")
    return false
  end
  if UIManager and UIManager.ShowUI(UIManager.UI_Config_InGame.ResultTask_UIBP) then
    log(bWriteLog and "ResultTaskSubsystem:CheckShowResultTaskUI Show Suc")
    self.UICloseCb = closeCb
    return true
  end
  return false
end
function ResultTaskSubsystem:CheckCanShowResultTaskUI(resultData)
  log(bWriteLog and "ResultTaskSubsystem:CheckCanShowResultTaskUI")
  if not LobbySystem.CheckOpen(BP_ENUM_RESULT_TASK_SWITCH) then
    log(bWriteLog and "ResultTaskSubsystem:CheckCanShowResultTaskUI not open")
    return false
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  if nDeviceLevel < 1 then
    log(bWriteLog and "ResultTaskSubsystem:CheckCanShowResultTaskUI nDeviceLevel:" .. tostring(nDeviceLevel))
    return false
  end
  if not receiveFirstMsg or not receiveSecondMsg then
    log(bWriteLog and "ResultTaskSubsystem:CheckCanShowResultTaskUI no two msg")
    return false
  end
  if self:_CheckSkipBattleResultTask(resultData) then
    log(bWriteLog and "ResultTaskSubsystem:CheckCanShowResultTaskUI _CheckSkipBattleResultTask")
    return false
  end
  return true
end
function ResultTaskSubsystem:_CheckSkipBattleResultTask(resultData)
  if resultData == nil then
    log(bWriteLog and "ResultTaskSubsystem:_CheckSkipBattleResultTask resultData is null")
    return true
  end
  log(bWriteLog and "ResultTaskSubsystem:_CheckSkipBattleResultTask modeId:" .. tostring(resultData.sub_mode))
  if resultData.battle_owner ~= 0 then
    return true
  end
  local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
  if not ResultUtil.CheckResultProSwitch(resultData.sub_mode, ResultUtil.SwitchKey.RankingTaskSwitch) then
    return true
  end
  return false
end
function ResultTaskSubsystem:OnBattleResultTaskUIClose()
  log(bWriteLog and "ResultTaskSubsystem:OnBattleResultTaskUIClose")
  if self.UICloseCb then
    self.UICloseCb()
  end
end
function ResultTaskSubsystem:GetTaskList()
  local totalTaskList = {}
  local ResultTask_Config = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Config")
  for _, config in pairs(ResultTask_Config.Configs) do
    local module = require(config.Logic)
    if module.GetFinishedTaskList then
      local taskList = module:GetFinishedTaskList()
      if taskList then
        for _, task in ipairs(taskList) do
          table.insert(totalTaskList, task)
        end
      end
    end
  end
  for _, config in pairs(ResultTask_Config.Configs) do
    local module = require(config.Logic)
    if module.GetInProgressTaskList then
      local taskList = module:GetInProgressTaskList()
      if taskList then
        for _, task in ipairs(taskList) do
          table.insert(totalTaskList, task)
        end
      end
    end
  end
  log_tree(bWriteLog and "Before Sort, ResultTaskSubsystem:GetTaskList:", totalTaskList)
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  table.sort(totalTaskList, function(a, b)
    local takenA = a.status == ResultTask_Macro.ENUM_TaskStatus.Taken
    local takenB = b.status == ResultTask_Macro.ENUM_TaskStatus.Taken
    if takenA ~= takenB then
      return takenA
    end
    local changedA = a.cur_value ~= a.pre_value
    local changedB = b.cur_value ~= b.pre_value
    if changedA ~= changedB then
      return changedA
    end
    return a.cur_value / a.finish_value > b.cur_value / b.finish_value
  end)
  log_tree(bWriteLog and "After Sort, ResultTaskSubsystem:GetTaskList:", totalTaskList)
  return totalTaskList
end
function ResultTaskSubsystem:GetSummaryList()
  local totalSummaryList = {}
  local ResultTask_Config = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Config")
  for _, config in pairs(ResultTask_Config.Configs) do
    local module = require(config.Logic)
    if module.GetSummaryInfo then
      local info = module:GetSummaryInfo()
      if info then
        info.nShowSort = config.nShowSort
        table.insert(totalSummaryList, info)
      end
    end
  end
  table.sort(totalSummaryList, function(a, b)
    return a.nShowSort < b.nShowSort
  end)
  log_tree(bWriteLog and "ResultTaskSubsystem:GetSummaryList:", totalSummaryList)
  return totalSummaryList
end
function ResultTaskSubsystem:on_task_status_notify(flag, summary, task_status)
  log(bWriteLog and "ResultTaskSubsystem:on_task_status_notify flag:", flag)
  if not LobbySystem.CheckOpen(BP_ENUM_RESULT_TASK_SWITCH) then
    return
  end
  if flag == 0 then
    receiveFirstMsg = true
  elseif flag == 1 then
    receiveSecondMsg = true
  end
  local ResultTask_Config = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Config")
  for _, config in pairs(ResultTask_Config.Configs) do
    local module = require(config.Logic)
    if module.on_task_status_notify then
      module:on_task_status_notify(flag, summary, task_status)
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ResultTaskSubsystem)