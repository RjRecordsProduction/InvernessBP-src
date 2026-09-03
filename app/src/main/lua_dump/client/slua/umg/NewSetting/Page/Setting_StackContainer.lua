local Setting_StackContainer = {}
local table_insert = table.insert
function Setting_StackContainer:ctor(_, Content)
  self.Stack  self.OptionUIList = {}
  self._LoadingTimer = false
  self.bLoadStackByFrame = true
end
function Setting_StackContainer:OnInitialize()
  self.StackContainerWidget = self.UIRoot.ScrollBox_Stack
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_OPTION_FORCEUPDATE, self.OnUpdateSingleOption, self)
end
function Setting_StackContainer:OnPostInitialize()
  self:LoadStack(self.StackContent, self.StackContainerWidget)
end
function Setting_StackContainer:LoadStack(StackContent, ContainerWidget)
  local time_ticker = require("common.time_ticker")
  if not StackContent or not slua.isValid(ContainerWidget) then
    return
  end
  self.  local Count = #StackContent
  if self.bLoadStackByFrame then
    self._LoadingTimer = self:AddTimer(0, function()
      local isyieldable = coroutine.isyieldable
      local yield = coroutine.yield
      for Index = 1, Count do
        local Item = StackContent[Index]
        if not Item.VisibilityFunc or Item.VisibilityFunc() then
          if Item.UI then
            local UI = self:CreateChildWindow(ContainerWidget, Item.UI, Item)
            table_insert(self.OptionUIList, UI)
          else
            print(string.format("Setting_StackContainer:OnInitialize %s has no ui config", Item.Key))
          end
        end
        if isyieldable() then
          yield(time_ticker.NEXT_FRAME)
        end
      end
      self._LoadingTimer = false
      self:OnStackLoaded()
      if self._FuncOnceLoaded then
        self._FuncOnceLoaded(self)
        self._FuncOnceLoaded = false
      end
    end)
  else
    for Index = 1, Count do
      local Item = StackContent[Index]
      if not Item.VisibilityFunc or Item.VisibilityFunc() then
        if Item.UI then
          local UI = self:CreateChildWindow(ContainerWidget, Item.UI, Item)
          table_insert(self.OptionUIList, UI)
        else
          print(string.format("Setting_StackContainer:OnInitialize %s has no ui config", Item.Key))
        end
      end
    end
    self:OnStackLoaded()
  end
end
function Setting_StackContainer:OnStackLoaded()
end
function Setting_StackContainer:UnloadStack()
  if self._LoadingTimer then
    self:RemoveTimer(self._LoadingTimer)
    self._LoadingTimer = nil
  end
  local Count = #self.OptionUIList
  for Index = 1, Count do
    if self.OptionUIList[Index] then
      self.OptionUIList[Index]:Close()
      self.OptionUIList[Index] = nil
    end
  end
end
function Setting_StackContainer:ReloadStack(StackContent, ContainerWidget)
  ContainerWidget = ContainerWidget or self.StackContainerWidget
  self:UnloadStack()
  self:LoadStack(StackContent, ContainerWidget)
  if ContainerWidget.ScrollToStart then
    ContainerWidget:ScrollToStart()
  end
end
function Setting_StackContainer:SetLoadedDelegate(func)
  if self._LoadingTimer then
    self._FuncOnceLoaded = func
  else
    func(self)
  end
end
function Setting_StackContainer:InitItemWithWidget(Widget, ItemData)
  if not assert(ItemData ~= nil and ItemData.UI and ItemData.UI.moduleName, "Setting_StackContainer:InitWithExistingWidget invalid ItemData") then
    return nil
  end
  local childClass = require(ItemData.UI.moduleName)
  local childWindow = childClass(ItemData)
  childWindow:InitWithParentWidget(self, Widget)
  return childWindow
end
function Setting_StackContainer:GetItemUI(Key)
  local Count = #self.OptionUIList
  for Index = 1, Count do
    local ItemUI = self.OptionUIList[Index]
    if ItemUI and ItemUI.Data and ItemUI.Data.Key == Key then
      return ItemUI
    end
  end
end
function Setting_StackContainer:RefreshAll()
  local Count = #self.OptionUIList
  for Index = 1, Count do
    local ItemUI = self.OptionUIList[Index]
    if ItemUI and ItemUI.OnRefreshOption then
      ItemUI:OnRefreshOption()
    end
  end
end
function Setting_StackContainer:OnUpdateSingleOption(_, __, key)
  local OptionUI = self:GetItemUI(key)
  if OptionUI and OptionUI.OnRefreshOption then
    OptionUI:OnRefreshOption()
  end
end
function Setting_StackContainer:OnClose()
  self:UnloadStack()
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, Setting_StackContainer)