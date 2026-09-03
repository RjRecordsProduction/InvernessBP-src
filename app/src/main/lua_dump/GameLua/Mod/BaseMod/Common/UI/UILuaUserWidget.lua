local table_remove = table.remove
local slua_isValid = slua.isValid
local string_format = string.format
local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local base_config_util = require("client.common.uibase.base_config_util")
local UILuaUserWidget = {}
local utility = require("common.utility")
function UILuaUserWidget:ctor()
  self.bNeedDelayRegistEvents = false
  self.bIsInit = false
  self.UIRoot = nil
  self._parentUI = nil
  self.bDestroy = false
  self.bHasRegistEvents = false
  self._childUIList = {}
  self.ChildrenWidgets = {}
end
function UILuaUserWidget:Construct()
  self.Super:Construct()
end
function UILuaUserWidget:Destruct()
  if self.Super then
    self.Super:Destruct()
  end
end
function UILuaUserWidget:Initialize()
  self.bDestroy = false
  self.bHasRegistEvents = false
  self.UIRoot = self.Object
  self._parentUI = nil
  if bWriteLog then
    local LuaFilePath = slua.isValid(self.Object) and self.Object.LuaFilePath or ""
    print(bWriteLog and "UILuaUserWidget:Initialize: ", LuaFilePath)
  end
  if not self.bNeedDelayRegistEvents then
    self:OnInitialize()
    self:RegistEvents()
    self:OnPostInitialize()
  end
end
function UILuaUserWidget:OnDestroy()
  if bWriteLog then
    local LuaFilePath = slua.isValid(self.Object) and self.Object.LuaFilePath or ""
    print(bWriteLog and "UILuaUserWidget:OnDestroy 0: ", LuaFilePath)
  end
  if self.bDestroy then
    return
  end
  if bWriteLog then
    local LuaFilePath = slua.isValid(self.Object) and self.Object.LuaFilePath or ""
    print(bWriteLog and "UILuaUserWidget:OnDestroy 1:", LuaFilePath)
  end
  self:__OnClose()
  self.bDestroy = true
  self.UIRoot = nil
  self._childUIList = nil
  slua.ClearTable(self)
end
function UILuaUserWidget:OnInitialize()
end
function UILuaUserWidget:RegistEvents()
end
function UILuaUserWidget:OnPostInitialize()
end
function UILuaUserWidget:OnClose()
end
function UILuaUserWidget:__OnClose()
  self:Dispose()
  self:ClearChild()
  self:OnClose()
  xpcall(self._CloseChildWindows, xpcallHandle, self)
end
function UILuaUserWidget:IsAsyncLoading()
  return false
end
function UILuaUserWidget:GetParentUI()
  return self._parentUI
end
function UILuaUserWidget:CreateChildWindow(panel, config, ...)
  if type(panel) == "string" then
    if self.UIRoot[panel] == nil then
      log_error("UILuaUserWidget:CreateChildWindow no parent. keyName:" .. self:_GetKeyName(config))
      return nil
    end
  elseif panel == nil then
    log_error("UILuaUserWidget:CreateChildWindow no parent keyName:" .. self:_GetKeyName(config))
    return nil
  end
  if GMDebug then
    log(bWriteLog and string_format("UILuaUserWidget:CreateChildWindow keyName:%s", self:_GetKeyName(config)))
  end
  local childUI = UIManager.ShowMountUI(self, panel, config, ...)
  if not childUI then
    log_error("UILuaUserWidget:CreateChildWindow childUI = nil. keyName:" .. self:_GetKeyName(config))
    return nil
  end
  self:_AddChildWindow(childUI)
  return childUI
end
function UILuaUserWidget:AttachChildWindow(panelName, childUI)
  self:_AddChildWindow(childUI)
  self:_AddChild(panelName, childUI.UIRoot)
end
function UILuaUserWidget:AttachChildWindowByControl(parentWidget, childUI)
  self:_AddChildWindow(childUI)
  self:_AddChildByControl(parentWidget, childUI.UIRoot)
end
function UILuaUserWidget:_AddChild(panelName, ChildWidget)
  local PanelWidget = self.UIRoot[panelName]
  if not PanelWidget then
    log_error(string_format("UIBase:AddChild, Panel not Found, PanelName=[%s]", panelName))
    return
  end
  self:_AddChildByControl(PanelWidget, ChildWidget)
end
function UILuaUserWidget:_AddChildByControl(PanelWidget, ChildWidget)
  if not assert(slua_isValid(PanelWidget), string_format("UIBase:_AddChildByControl slua_isValid(PanelWidget) fail")) then
    return
  end
  if type(ChildWidget) == "table" then
    ChildWidget:CacheParentWidget(PanelWidget)
  else
    PanelWidget:AddChild(ChildWidget)
  end
end
function UILuaUserWidget:_GetKeyName(config)
  return base_config_util.GetKeyName(config)
end
function UILuaUserWidget:_AddChildWindow(childUI)
  if not self._childUIList then
    self._childUIList = {}
  end
  self._childUIList[#self._childUIList + 1] = childUI
  childUI._parentUI = self
end
function UILuaUserWidget:_OnChildWindowClose(childUI)
  if not self._childUIList or #self._childUIList <= 0 then
    return
  end
  for i = #self._childUIList, 1, -1 do
    if self._childUIList[i] == childUI then
      table_remove(self._childUIList, i)
    end
  end
end
function UILuaUserWidget:_CloseChildWindows()
  if not self._childUIList or #self._childUIList <= 0 then
    return
  end
  for i = #self._childUIList, 1, -1 do
    local v = self._childUIList[i]
    if v then
      local childConfig = v._config
      if base_config_util.IsSingleton(childConfig) then
        v:CloseSelf()
      else
        v:Close()
      end
    end
  end
  self._childUIList = nil
end
function UILuaUserWidget:InitSelfWidget()
  if self.bIsInit then
    return
  end
  self.bIsInit = true
  if self.bNeedDelayRegistEvents then
    self:OnInitialize()
    self:RegistEvents()
    self:OnPostInitialize()
  end
  if bWriteLog then
    local LuaFilePath = slua.isValid(self.Object) and self.Object.LuaFilePath or ""
    print(bWriteLog and "UILuaUserWidget:InitSelfWidget: ", LuaFilePath)
  end
end
function UILuaUserWidget:AddChildWidget(Widget, LuaModulePath, ...)
  if type(Widget) == "table" then
    table.insert(self.ChildrenWidgets, Widget)
    return Widget
  elseif type(LuaModulePath) == "string" then
    local WidgetClass = require(LuaModulePath)
    local WidgetTable = WidgetClass(...)
    WidgetTable.    WidgetTable:InitWithWidget(Widget)
    table.insert(self.ChildrenWidgets, WidgetTable)
    return WidgetTable
  end
end
function UILuaUserWidget:ClearChild()
  for _, WidgetTable in ipairs(self.ChildrenWidgets) do
    if WidgetTable and WidgetTable.Close then
      print(bWriteLog and string.format("UILuaUserWidget:ClearChild %s", WidgetTable.LuaModulePath))
      xpcall(WidgetTable.Close, utility.ErrorMessageHandler, WidgetTable)
    end
  end
  self.ChildrenWidgets = {}
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CUILuaUserWidget = class(CDelegateContainer, nil, UILuaUserWidget)
return CUILuaUserWidget