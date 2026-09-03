local EntireMapTaskItem = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local VersionTaskType = 101
function EntireMapTaskItem:ctor()
  self.TaskItemMap = {}
  self.LastMainItemVis = {}
end
function EntireMapTaskItem:SetUIRoot(UIRoot)
  self.end
function EntireMapTaskItem:OnRegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TASK_COLLAPSE_BUTTON_CLICK, self.CollapseTaskList, self)
end
function EntireMapTaskItem:TestLQA()
  self:GetMyLogic():TestData()
  self:CreateItems()
end
function EntireMapTaskItem:OnInitUI()
  printf("EntireMapTaskItem:OnInitUI")
  self.TitleAndIcon = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig").TitleConfig
  self.EntireMapConfig = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig")
  self:RefreshDataAndAssets()
end
function EntireMapTaskItem:AsynItemAssets()
  if self.bCreateItems then
    return
  end
  if self.UIRoot then
    self:CreateItems()
  end
end
function EntireMapTaskItem:CreateItems()
  if self.bCreateItems then
    return
  end
  if not self.TaskItemMap then
    self.TaskItemMap = {}
  end
  local LocalData = self:GetTaskData()
  if not LocalData then
    return
  end
  local IndexTable = {}
  for index, value in pairs(LocalData) do
    table.insert(IndexTable, index)
  end
  if self.TitleAndIcon then
    table.sort(IndexTable, function(a, b)
      local AHasPriority = self.TitleAndIcon[a] and self.TitleAndIcon[a].Priority
      local BHasPriority = self.TitleAndIcon[b] and self.TitleAndIcon[b].Priority
      if AHasPriority and BHasPriority then
        return self.TitleAndIcon[a].Priority < self.TitleAndIcon[b].Priority
      elseif AHasPriority then
        return true
      elseif BHasPriority then
        return false
      else
        return a < b
      end
    end)
  end
  for index, value in ipairs(IndexTable) do
    self:CreateItem(value, LocalData[value])
  end
  local Cfg = {}
  Cfg = UIManager.UI_Config_InGame.EntireMapTaskItemTipsUI
  local TailItem = UIManager.ShowUI(Cfg)
  self.UIRoot.ScrollBox_Task:AddChild(TailItem.UIRoot)
  self:RefreshTailItem(TailItem)
  self:SaveTaskItem(true, TailItem, 999)
  self.bCreateItems = true
  log_tree("EntireMapTaskItem:CreateItems TaskItemMap = ", self.TaskItemMap)
end
function EntireMapTaskItem:CreateItem(index, value)
  if index ~= 1 or index == 1 and #value ~= 0 then
    local Cfg = {}
    local mainItem
    Cfg = UIManager.UI_Config_InGame.EntireMapTaskItemTitleUI
    mainItem = UIManager.ShowUI(Cfg)
    self.UIRoot.ScrollBox_Task:AddChild(mainItem.UIRoot)
    self:RefreshMainItem(index, mainItem)
    self:SaveTaskItem(true, mainItem, index)
    for subIndex, subValue in ipairs(value) do
      local subItem
      local Cfg = {}
      if index == 1 then
        Cfg = UIManager.UI_Config_InGame.ThemeTaskItemDetailsUI
      elseif index == VersionTaskType then
        Cfg = UIManager.UI_Config_InGame.EntireMapVersionTaskItemDetailsUI
      else
        Cfg = UIManager.UI_Config_InGame.EntireMapTaskItemDetailsUI
      end
      subItem = UIManager.ShowUI(Cfg)
      self.UIRoot.ScrollBox_Task:AddChild(subItem.UIRoot)
      self:RefreshSubItem(subValue, subItem, index)
      self:SaveTaskItem(false, subItem, index, subIndex)
    end
    if index == 1 then
      local Cfg = {}
      Cfg = UIManager.UI_Config_InGame.ThemeTaskButtonItemUI
      local RewardItem = UIManager.ShowUI(Cfg)
      self.UIRoot.ScrollBox_Task:AddChild(RewardItem.UIRoot)
      self:RefreshRewardItem(RewardItem, index)
      local RewardIndex = #value + 1
      self:SaveTaskItem(false, RewardItem, index, RewardIndex)
    end
  end
end
function EntireMapTaskItem:RefreshMainItem(index, widget)
  if widget and widget.RefreshUI then
    widget:RefreshUI(nil, index)
  end
  local LocalData = self:GetTaskData()
  local vis = 0 < #LocalData[index]
  if self.LastMainItemVis[index] == nil or self.LastMainItemVis[index] ~= vis then
    if vis then
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.LastMainItemVis[index] = vis
  end
end
function EntireMapTaskItem:RefreshSubItem(subValue, widget, index)
  if widget and widget.RefreshUI then
    widget:RefreshUI(subValue, index)
  end
end
function EntireMapTaskItem:RefreshTailItem(widget)
  if widget and widget.RefreshUI then
    widget:RefreshUI()
  end
end
function EntireMapTaskItem:RefreshRewardItem(widget, index)
  if widget and widget.RefreshUI then
    widget:RefreshUI(nil, index)
  end
end
function EntireMapTaskItem:ResetAllTeskItem()
  local LocalData = self:GetTaskData()
  for index, value in pairs(self.TaskItemMap) do
    if index ~= 999 then
      self:RefreshMainItem(index, value.ItemWidget)
    else
      self:RefreshTailItem(value.ItemWidget)
    end
    for subIndex, subItemUI in ipairs(value.Content) do
      local subItemInfo = LocalData[index][subIndex]
      if subItemInfo then
        self:RefreshSubItem(subItemInfo, subItemUI, index)
      end
    end
  end
end
function EntireMapTaskItem:OnClose()
  for index, value in pairs(self.TaskItemMap) do
    if value.ItemWidget then
      value.ItemWidget:Close()
    end
    for subIndex, subItemUI in ipairs(value.Content) do
      if subItemUI then
        subItemUI:Close()
      end
    end
  end
  self.TaskItemMap = nil
  EntireMapTaskItem.__super.OnClose(self)
end
function EntireMapTaskItem:RefreshAllItem()
  self:RefreshDataAndAssets()
  local AllComplete = self:CheckComplete()
  if not AllComplete then
    self:ResetAllTeskItem()
  else
    local EntireTaskUI = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapTaskUI)
    EntireTaskUI:AddCompleteType("Task")
  end
end
function EntireMapTaskItem:RefreshDataAndAssets()
  local LocalController = GameplayData.GetPlayerController()
  if not slua.isValid(LocalController) then
    return
  end
  if LocalController.IsSpectator and LocalController:IsSpectator() or LocalController.IsDemoPlaySpectator and LocalController:IsDemoPlaySpectator() then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if slua.isValid(LocalController) and LocalController.IsInPetSpectator and LocalController:IsInPetSpectator() then
    log(bWriteLog and "EntireMapLeftWidgetLogic:SetData IsInPetSpectator")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self:GetMyLogic():RefreshData()
  self:AsynItemAssets()
end
function EntireMapTaskItem:CheckIsMatch()
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local MatchModeList = {
    111,
    112,
    113,
    411,
    412,
    413
  }
  if not slua.isValid(uGameInstance) then
    return false
  end
  local TableUtil = require("common.table_util")
  local MainModeID = uGameInstance:GetMainModeID()
  if TableUtil.Find(MatchModeList, MainModeID) ~= -1 then
    return true
  else
    return false
  end
end
function EntireMapTaskItem:CollapseTaskList(_, __, index, bIsOpen)
  if self.TaskItemMap[index] == nil then
    return
  end
  if self.TaskItemMap[index].bViewOpen == nil then
    self.TaskItemMap[index].bViewOpen = true
  end
  self.TaskItemMap[index].bViewOpen = not self.TaskItemMap[index].bViewOpen
  if self.TaskItemMap[index] and self.TaskItemMap[index].Content then
    for key, value in pairs(self.TaskItemMap[index].Content) do
      if value then
        value:SetWidgetVisibility(self.TaskItemMap[index].bViewOpen and UEnums.ESlateVisibility.HitTestInvisible or UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function EntireMapTaskItem:SaveTaskItem(bIsMainItem, Widget, index, subIndex)
  if not self.TaskItemMap[index] then
    self.TaskItemMap[index] = {
      ItemWidget = nil,
      Content = {}
    }
  end
  if bIsMainItem then
    self.TaskItemMap[index].Item  else
    self.TaskItemMap[index].Content[subIndex] = Widget
  end
end
function EntireMapTaskItem:GetTaskData()
  local TaskData = {}
  TaskData = self:GetMyLogic():GetTaskData()
  return TaskData
end
function EntireMapTaskItem:GetMyLogic()
  if self.MyLogic then
    return self.MyLogic
  end
  self.MyLogic = SubsystemMgr:Get("EntireMapLeftWidgetLogic")
  return self.MyLogic
end
function EntireMapTaskItem:CheckComplete()
  print("EntireMapTaskItem:CheckComplete" .. tostring(self:GetMyLogic():CheckTaskComplete()))
  return self:GetMyLogic():CheckTaskComplete()
end
local class = require("class")
local ItemBase = require("GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftItemBase")
local CEntireMapTaskItem = class(ItemBase, nil, EntireMapTaskItem)
return CEntireMapTaskItem