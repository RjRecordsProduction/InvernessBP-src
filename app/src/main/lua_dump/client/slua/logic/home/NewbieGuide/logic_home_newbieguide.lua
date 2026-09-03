local logic_home_newbieguide = {}
function logic_home_newbieguide:DefineAndResetData()
  self.newbieGuideStatusMap = {}
  self.startTaskId = 100
  self.levelUpTaskId = 109
  self.templateSelectTaskId = 111
  self.endTaskId = 1000
  self.bFirstFinishStartTask = false
  self.bFetchedNewbieGuideTaskStatus = false
end
function logic_home_newbieguide:OnInitialize()
end
function logic_home_newbieguide:RegistEvents()
end
function logic_home_newbieguide:OnLogin(bReLogin)
end
function logic_home_newbieguide:OnLogOut()
end
function logic_home_newbieguide:OnPreSwitchGameStatus(preState, nextState)
end
function logic_home_newbieguide:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_home_newbieguide:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState) or "")
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() and self.bFetchedNewbieGuideTaskStatus == false then
    self:ReqHomeNewbieGuideTaskStatus()
  end
end
function logic_home_newbieguide:CheckHomeNewbieGuideSwitch()
  log(bWriteLog and "logic_home_newbieguide:CheckHomeNewbieGuideSwitch")
  local switchId = 92047
  local switch = LobbySystem.CheckOpen(switchId)
  log(bWriteLog and "logic_home_newbieguide:CheckHomeNewbieGuideSwitch switch = " .. tostring(switch))
  return switch
end
function logic_home_newbieguide:IsFinishNewbieGuideTask()
  log(bWriteLog and "logic_home_newbieguide:IsFinishNewbieGuideTask")
  if not self:CheckHomeNewbieGuideSwitch() then
    log(bWriteLog and "logic_home_newbieguide:IsFinishNewbieGuideTask switch is off")
    return true
  end
  if self.newbieGuideStatusMap then
    log(bWriteLog and "logic_home_newbieguide:IsFinishNewbieGuideTask check")
    local taskId = self.startTaskId
    while taskId do
      local status = self.newbieGuideStatusMap[taskId]
      if not status or status.finish_status ~= 1 then
        break
      end
      local config = self:GetPlanPHTaskConfig(taskId)
      if not config then
        break
      end
      taskId = config.NextID
    end
    log(bWriteLog and "logic_home_newbieguide:IsFinishNewbieGuideTask check taskId = " .. tostring(taskId))
    if taskId == self.endTaskId then
      return true
    end
  end
  return false
end
function logic_home_newbieguide:GetNextTaskId(taskId)
  log(bWriteLog and "logic_home_newbieguide:GetNextTaskId in taskId = " .. tostring(taskId))
  while taskId ~= self.endTaskId do
    local status = self.newbieGuideStatusMap[taskId]
    if not status or status.finish_status ~= 1 then
      break
    end
    local config = self:GetPlanPHTaskConfig(taskId)
    if not config then
      break
    end
    taskId = config.NextID
  end
  log(bWriteLog and "logic_home_newbieguide:GetNextTaskId out taskId = " .. tostring(taskId))
  return taskId
end
function logic_home_newbieguide:GetPlanPHTaskConfig(taskId)
  local newbieGuideTaskConfig = CDataTable.GetTableData("PlanPH_NewbieGuideTask", taskId)
  return newbieGuideTaskConfig
end
function logic_home_newbieguide:GetAllPlanPHTaskConfig()
  local PlanPH_NewbieGuideTask = CDataTable.GetTable("PlanPH_NewbieGuideTask")
  return PlanPH_NewbieGuideTask
end
function logic_home_newbieguide:GetRewardContent(taskId)
  log(bWriteLog and "logic_home_newbieguide:GetRewardContent taskId = " .. tostring(taskId))
  local taskConfig = self:GetPlanPHTaskConfig(taskId)
  if taskConfig then
    local RewardItem = taskConfig.RewardItem
    local RewardNum = taskConfig.RewardNum
    log(bWriteLog and "logic_home_newbieguide:GetRewardContent RewardItem = " .. tostring(RewardItem) .. " RewardNum = " .. tostring(RewardNum))
    if RewardItem and RewardItem ~= "" and RewardNum and RewardNum ~= "" then
      local StringUtil = require("common.string_util")
      local RewardItemArray = StringUtil.SplitToNum(RewardItem, "|")
      local RewardNumArray = StringUtil.SplitToNum(RewardNum, "|")
      log_tree("RewardItemArray = ", RewardItemArray)
      log_tree("RewardNumArray = ", RewardNumArray)
      local content = ""
      for index, itemId in pairs(RewardItemArray) do
        local num = RewardNumArray[index]
        log(bWriteLog and "logic_home_newbieguide:GetRewardContent num = " .. tostring(num))
        local itemCfg = CDataTable.GetTableData("PlanPH_ItemCfg", itemId)
        if itemCfg and itemCfg.Name and num then
          if content and content ~= "" then
            content = content .. " "
          end
          content = content .. itemCfg.Name .. "x" .. tostring(num)
        end
      end
      log(bWriteLog and "logic_home_newbieguide:GetRewardContent content = " .. tostring(content))
      return content
    end
  end
  log(bWriteLog and "logic_home_newbieguide:GetRewardContent nil")
  return nil
end
function logic_home_newbieguide:GetNewbieGuideTaskProgress(assetId, resourceType, operationType)
  log(bWriteLog and "logic_home_newbieguide:GetNewbieGuideTaskProgress assetId = " .. tostring(assetId) .. " resourceType = " .. tostring(resourceType) .. " operationType = " .. tostring(operationType))
  local taskId = self:GetNextTaskId(self.startTaskId)
  if taskId == self.endTaskId then
    return taskId, 0, 0
  end
  local taskConfig = self:GetPlanPHTaskConfig(taskId)
  local mainType = taskConfig.ItemMainType
  local subType = taskConfig.ItemSubType
  local itemNum = taskConfig.ItemNum
  local taskPlan = taskConfig.TaskPlan
  local completeNum = 0
  if taskPlan == 1 then
    completeNum = self:GetInstanceObjectNum(mainType, subType)
  elseif taskPlan == 2 then
    completeNum = self:GetInteractionProgress(mainType, assetId, resourceType, operationType)
  end
  log(bWriteLog and "logic_home_newbieguide:GetNewbieGuideTaskProgress taskId = " .. tostring(taskId) .. " completeNum = " .. tostring(completeNum) .. " itemNum = " .. tostring(itemNum))
  return taskId, completeNum, itemNum
end
function logic_home_newbieguide:GetInstanceObjectNum(mainType, subType)
  log(bWriteLog and "logic_home_newbieguide:GetInstanceObjectNum mainType = " .. tostring(mainType) .. " subType = " .. tostring(subType))
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local homeAreaInfo = PlanPH_HomeArea_Manager.GetCurEditHome()
  if not homeAreaInfo then
    return 0
  end
  local num = 0
  local PlanPH_SceneObject_Config = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.Config.PlanPH_SceneObject_Config")
  if mainType == PlanPH_SceneObject_Config.E_MainResourceType.Structure then
    local instances = homeAreaInfo.sceneObjectSystem:GetAllSceneObjectInstances()
    for _, instance in pairs(instances) do
      local assetID = instance.assetID
      local cfg = CDataTable.GetTableData("PlanPH_StructureItemCfg", assetID)
      if cfg and cfg.SubType == subType then
        num = num + 1
      end
    end
  elseif mainType == PlanPH_SceneObject_Config.E_MainResourceType.Material then
    local instances = homeAreaInfo.sceneObjectSystem:GetAllSceneObjectInstances()
    for _, instance in pairs(instances) do
      for _, mats in pairs(instance.matList) do
        for __, matID in pairs(mats) do
          local cfg = CDataTable.GetTableData("PlanPH_WallpaperItemCfg", matID)
          if cfg and cfg.MatType == subType then
            num = num + 1
          end
        end
      end
    end
  elseif mainType == PlanPH_SceneObject_Config.E_MainResourceType.Decoration then
    local decorationInstances = homeAreaInfo.sceneObjectSystem:GetAllDecorationObjectInst()
    for _, instance in pairs(decorationInstances) do
      local assetID = instance.assetID
      local cfg = CDataTable.GetTableData("PlanPH_DecorateItemCfg", assetID)
      if cfg and cfg.DecoType == subType then
        num = num + 1
      end
    end
  end
  return num
end
function logic_home_newbieguide:GetInteractionProgress(mainType, assetId, resourceType, operationType)
  log(bWriteLog and "logic_home_newbieguide:GetInteractionProgress mainType = " .. tostring(mainType) .. " assetId = " .. tostring(assetId) .. " resourceType = " .. tostring(resourceType) .. " operationType = " .. tostring(operationType))
  if mainType ~= resourceType then
    log(bWriteLog and "logic_home_newbieguide:GetInteractionProgress type is not match")
    return 0
  end
  local PlanPH_SceneObject_Config = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.Config.PlanPH_SceneObject_Config")
  if operationType == PlanPH_SceneObject_Config.E_OperationType.Add and self.operationMap and self.operationMap[mainType] and self.operationMap[mainType][assetId] and self.operationMap[mainType][assetId][PlanPH_SceneObject_Config.E_OperationType.Modify] then
    self.operationMap[mainType][assetId] = nil
    return 1
  end
  if not self.operationMap then
    self.operationMap = {}
  end
  if not self.operationMap[mainType] then
    self.operationMap[mainType] = {}
  end
  if not self.operationMap[mainType][assetId] then
    self.operationMap[mainType][assetId] = {}
  end
  self.operationMap[mainType][assetId][operationType] = true
  return 0
end
function logic_home_newbieguide:CorrectItemCountMap()
  log(bWriteLog and "logic_home_newbieguide:CorrectItemCountMap")
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bEditHomeMode = PlanPH_GamePlay_Tools.IsEditHomeMode()
  log(bWriteLog and "logic_home_newbieguide:CorrectItemCountMap bEditHomeMode = " .. tostring(bEditHomeMode))
  if not bEditHomeMode then
    return
  end
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local homeAreaInfo = PlanPH_HomeArea_Manager.GetCurEditHome()
  if not homeAreaInfo then
    log(bWriteLog and "logic_home_newbieguide:CorrectItemCountMap homeAreaInfo is invalid ")
    return
  end
  local sceneObjectSystem = homeAreaInfo.sceneObjectSystem
  if not sceneObjectSystem then
    log(bWriteLog and "logic_home_newbieguide:CorrectItemCountMap sceneObjectSystem is invalid ")
    return
  end
  local PlanPH_BinFile_Tools = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.Tools.PlanPH_BinFile_Tools")
  local itemMapDraft = PlanPH_BinFile_Tools.GetItemCountMap(sceneObjectSystem.objectInstList.storeFileInfo, true)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  LogicPHomeStore:SetManorUseItemDetails(itemMapDraft)
end
function logic_home_newbieguide:ReqHomeNewbieGuideTaskStatus()
  log(bWriteLog and "logic_home_newbieguide:ReqHomeNewbieGuideTaskStatus")
  local PlanPHNewbieGuideHandler = require("client.network.Protocol.PlanPHNewbieGuideHandler")
  PlanPHNewbieGuideHandler.send_get_manor_newbie_guide_req()
end
function logic_home_newbieguide:OnGetHomeNewbieGuideTaskStatus(status)
  log(bWriteLog and "logic_home_newbieguide:OnGetHomeNewbieGuideTaskStatus")
  self.newbieGuideStatusMap = status
  self.bFetchedNewbieGuideTaskStatus = true
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_PLANPH_GET_NEWBIEGUIDE_TASK_STATUS)
end
function logic_home_newbieguide:ReqFinishHomeNewbieGuideTask(taskId)
  log(bWriteLog and "logic_home_newbieguide:ReqFinishHomeNewbieGuideTask taskId = " .. tostring(taskId))
  local PlanPH_NewbieGuide_Client_Handler = require("GameLua.Mod.PlanPH.Client.Handler.PlanPH_NewbieGuide_Client_Handler")
  PlanPH_NewbieGuide_Client_Handler.send_PlanPH_finish_manor_newbie_guide_req(taskId)
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local homeIndex = PlanPH_HomeArea_Manager.curHomeIndex
  local PlanPH_SceneObject_RepActorList_Client = require("GameLua.Mod.PlanPH.Client.HomeArea.SceneObject.PlanPH_SceneObject_RepActorList_Client")
  PlanPH_SceneObject_RepActorList_Client.ClearRepActorMap(homeIndex)
  self:CorrectItemCountMap()
end
function logic_home_newbieguide:OnFinishHomeNewbieGuideTask(taskIds, bAuto)
  log(bWriteLog and "logic_home_newbieguide:OnFinishHomeNewbieGuideTask bAuto = " .. tostring(bAuto))
  log_tree("OnFinishHomeNewbieGuideTask taskIds = ", taskIds)
  for _, taskId in pairs(taskIds) do
    if self.newbieGuideStatusMap[taskId] then
      self.newbieGuideStatusMap[taskId].finish_status = 1
    else
      if taskId == self.startTaskId then
        self.bFirstFinishStartTask = true
      end
      local taskStatus = {finish_status = 1}
      self.newbieGuideStatusMap[taskId] = taskStatus
    end
    local logic_newbieguide_config = require("client.slua.logic.home.NewbieGuide.logic_newbieguide_config")
    if not bAuto then
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_PLANPH_NEWBIE_GUIDE_START_EVENT, taskId, logic_newbieguide_config.ENewbieGuideStartEventType.Protocol)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_newbieguide = class(CModuleBase, nil, logic_home_newbieguide)
return Clogic_home_newbieguide