local UIBase = {}
local GMDebug = false
local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local table_remove = table.remove
local table_pack = table.pack
local table_unpack = table.unpack
local local local local local local local local local local local local local local local local local local local local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local local local ModuleManager_GetModule = ModuleManager.GetModule
local CommonModuleConfig = ModuleManager.CommonModuleConfig
local LobbyModuleConfig = ModuleManager.LobbyModuleConfig
local ui_show_manager = require("client.common.uibase.ui_show_manager")
local asset_util = require("common.asset_util")
local common = require("client.slua_ui_framework.common")
local base_config_util = require("client.common.uibase.base_config_util")
local util = require("client.slua_ui_framework.util")
local time_ticker = require("common.time_ticker")
local UIMessageSystem = require("GameLua.GameCore.Main.UIMessageSystem")
require("client.common.event.EventProxy")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local TimeUtil = require("client.common.time_util")
local FuncUtil_UE4ExecuteConsoleCommand = FuncUtil.UE4ExecuteConsoleCommand
local slua_loadUI = slua.loadUI
local slua_loadUISingleton = slua.loadUISingleton
local slua_isValid = slua.isValid
local slua_removeDelegate = slua.removeDelegate
local slua_AsyncLoadUI = slua.AsyncLoadUI
local slua_getMiliseconds = slua.getMiliseconds
local slua_CancelLoadUI = slua.CancelLoadUI
local UKismetSystemLibrary = import("KismetSystemLibrary")
local BusinessHelper = import("BusinessHelper")
local GameplayStatics = import("GameplayStatics")
local game_frontend_hud = require("game_frontend_hud")
local widget_proxy = require("client.common.uibase.widget_proxy")
local widget_proxy_util = require("client.common.uibase.widget_proxy_util")
local audio_util = require("client.common.audio_util")
local UIUtil = require("client.common.ui_util")
local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
local image_download_config = require("client.slua.logic.image_download.image_download_config")
local clock = require("client.slua.common.clock")
local tween_animation_util = require("client.common.uibase.tween_animation_util")
local SetTextureConst = require("client.slua.logic.image_download.SetTextureConst")
local loadFromCacheHandleID = 0
function UIBase:ctor(selfType, ...)
  self.UIRoot = nil
  self._IsClosed = false
  self:_SetUIRoot(nil)
  self._isShow = false
  self._config = false
  self._moduleName = ""
  self._bpPath = nil
  self.containerName = UIContainers.None
  self._loadFromPool = nil
  self._AttachPanel = nil
  self._zOrder = nil
  self._parentUI = nil
  self._childUIList = nil
  self._timesForUI = nil
  self._gameTimers = nil
  self._controlEventsForUI = nil
  self._commonEvents = nil
  self._uiMessageEvents = nil
  self._dataListeners = nil
  self._clocks = nil
  self._playList = nil
  self._loadedDelegates = nil
  self._downloadImageMgrData = nil
  self._asyncLoadDiskFile = nil
  self._promiseMap = nil
  self._AsyncLoadHandleID = nil
  self._AsyncEventCommands = nil
  self._AsyncStatUIInfo = nil
  self._AsyncJumpBackData = nil
  self._UIRootProxy = nil
  self._DebugInfo = nil
  self.bIsInCombatState = GameStatus.IsInFightingNotSocialNotMainCityNotHome()
  self._AudioListTable = nil
  self._AudioAsyncHandleTable = nil
end
function UIBase:OnConstruct(...)
end
function UIBase:InitByConfigWithBpPath(parentUIBase, panel, config, bpPath)
  self._AttachPanel = panel
  self._parentUI = parentUIBase
  self._  self._moduleName = config and config.moduleName or ""
  local containerName = config.containerName or UIContainers.Default
  log(bWriteLog and "UIBase:InitByConfigWithBpPath. keyName: " .. self:GetClassName() .. ", container: " .. tostring(containerName))
  return self:Init(bpPath or config.path, containerName, config.zOrder or EFixedZOrder.Default, config.loadFromPool, config.asy or false)
end
function UIBase:Init(path, containerName, zOrder, loadFromPool, asy)
  if not assert(type(path) == "string" and type(containerName) == "string" and type(zOrder) == "number", "UIBase:Init path should be string,containerName should be string,zOrder should be number") then
    return false
  end
  if self.UIRoot then
    log_error("UIBase:Init Can't call Init twice in UIBase!")
    return false
  end
  if not self.bIsInCombatState then
    self:_SetDebugStartTime(TimeUtil.GetMicroseconds())
  end
  self.containerName = containerName or UIContainers.None
  self._bpPath = path
  self._  if loadFromPool == nil then
    self._loadFromPool = EUIConfigPoolType.ui_pool
  else
    self._  end
  if not self.bIsInCombatState and base_config_util.EnableCDNCompress(self._config) then
    FuncUtil_UE4ExecuteConsoleCommand("s.EnableCompressFormatDownload 1")
  end
  self._canUsePool = self:_CanUsePool()
  UIManager.InitDeviceLevel()
  local ret
  if not asy then
    ret = self:_SyncInit()
    log(bWriteLog and "UIBase:Init. ret: " .. tostring(ret))
    if not self.UIRoot then
      if self._config then
        self:CloseSelf()
      end
      return nil
    end
    return ret
  end
  if not self.bIsInCombatState and UIManager.iDisableAsyHighDeviceLevel > 0 and UIManager.iTCDeviceLevel >= UIManager.iDisableAsyHighDeviceLevel then
    ret = self:_SyncInit()
    if not self.UIRoot then
      if self._config then
        self:CloseSelf()
      end
      return nil
    end
    return ret
  end
  return self:_AsyncInit()
end
function UIBase:CreateChildWindow(panel, config, ...)
  if type(panel) == "string" then
    if self.UIRoot[panel] == nil then
      log_error("UIBase:CreateChildWindow no parent. keyName:" .. self:_GetKeyName(config))
      return nil
    end
  elseif panel == nil then
    log_error("UIBase:CreateChildWindow no parent keyName:" .. self:_GetKeyName(config))
    return nil
  end
  if GMDebug then
    log(bWriteLog and string_format("UIBase:CreateChildWindow keyName:%s", self:_GetKeyName(config)))
  end
  local childUI = UIManager.ShowMountUI(self, panel, config, ...)
  if not childUI then
    log_error("UIBase:CreateChildWindow childUI = nil. keyName:" .. self:_GetKeyName(config))
    return nil
  end
  self:_AddChildWindow(childUI)
  return childUI
end
function UIBase:CreateChildWindowWithBpPath(panel, config, bpPath, ...)
  if type(panel) == "string" then
    if self.UIRoot[panel] == nil then
      log_error("UIBase:CreateChildWindowWithBpPath no parent. keyName:" .. self:_GetKeyName(config))
      return nil
    end
  elseif panel == nil then
    log_error("UIBase:CreateChildWindowWithBpPath no parent keyName:" .. self:_GetKeyName(config))
    return nil
  end
  if GMDebug then
    log(bWriteLog and string_format("UIBase:CreateChildWindowWithBpPath keyName:%s", self:_GetKeyName(config)))
  end
  config = config or UIManager.UI_Config.ChildUIWithoutBpPath
  local childUI = UIManager.ShowMountUIWithBpPath(self, panel, config, bpPath, ...)
  if not childUI then
    log_error("UIBase:CreateChildWindowWithBpPath childUI = nil keyName:" .. self:_GetKeyName(config))
    return nil
  end
  self:_AddChildWindow(childUI)
  return childUI
end
function UIBase:CreateChildWindowWithLuaAndBpPath(panel, config, moduleName, bpPath, ...)
  if type(panel) == "string" then
    if self.UIRoot[panel] == nil then
      log_error("UIBase:CreateChildWindowWithLuaAndBpPath no parent. keyName:" .. self:_GetKeyName(config))
      return nil
    end
  elseif panel == nil then
    log_error("UIBase:CreateChildWindowWithLuaAndBpPath no parent keyName:" .. self:_GetKeyName(config))
    return nil
  end
  if GMDebug then
    log(bWriteLog and string_format("UIBase:CreateChildWindowWithLuaAndBpPath keyName:%s", self:_GetKeyName(config)))
  end
  config = config or UIManager.UI_Config.ChildUIWithoutLuaAndBpPath
  local childUI = UIManager.ShowMountUIWithLuaAndBpPath(self, panel, config, moduleName, bpPath, ...)
  if not childUI then
    log_error("UIBase:CreateChildWindowWithLuaAndBpPath childUI = nil keyName:" .. self:_GetKeyName(config))
    return nil
  end
  self:_AddChildWindow(childUI)
  return childUI
end
function UIBase:InitWithParentWidget(parentUI, widget)
  if not widget then
    log_error("UIBase:InitWithParentWidget widget is nil!")
    return
  end
  parentUI:_AddChildWindow(self)
  self:InitWithWidget(widget)
end
function UIBase:AttachChildWindow(panelName, childUI)
  self:_AddChildWindow(childUI)
  self:_AddChild(panelName, childUI.UIRoot)
end
function UIBase:AttachChildWindowByControl(parentWidget, childUI)
  self:_AddChildWindow(childUI)
  self:_AddChildByControl(parentWidget, childUI.UIRoot)
end
function UIBase:AttachToPanel(panelWidget)
  self:_AddChildByControl(panelWidget, self.UIRoot)
end
function UIBase:_AddChild(panelName, ChildWidget)
  local PanelWidget = self.UIRoot[panelName]
  if not PanelWidget then
    log_error(string_format("UIBase:AddChild, Panel not Found, PanelName=[%s]", panelName))
    return
  end
  self:_AddChildByControl(PanelWidget, ChildWidget)
end
function UIBase:_AddChildByControl(panelWidget, ChildWidget)
  if not assert(slua_isValid(panelWidget), "UIBase:_AddChildByControl slua_isValid(panelWidget) fail") then
    return
  end
  if GMDebug then
    log(bWriteLog and "UIBase:_AddChildByControl type(ChildWidget):" .. type(ChildWidget) .. " keyName:" .. self:_GetKeyName(self._config) .. " panelWidget:GetChildrenCount():" .. panelWidget:GetChildrenCount())
  end
  if type(ChildWidget) == "table" then
    ChildWidget:CacheParentWidget(panelWidget)
  else
    panelWidget:AddChild(ChildWidget)
  end
end
function UIBase:_SyncInit()
  local bUnique = base_config_util.IsUniquePath(self._config)
  if self._canUsePool then
    local pool = self:_GetPool()
    self:_SetUIRoot(pool:Get(self._bpPath, function(bPoolCtor)
      if not self.bIsInCombatState then
        self:_SetDebugExtend(true, not bPoolCtor)
      end
    end, bUnique))
    if not self.UIRoot then
      return false
    end
  else
    local loadFunc = bUnique and slua_loadUISingleton or slua_loadUI
    local _, ui = xpcall(loadFunc, xpcallHandle, self._bpPath)
    self:_SetUIRoot(ui)
    if not self.bIsInCombatState then
      self:_SetDebugExtend(true, false)
    end
  end
  self:_OnSyncUILoad()
  return true
end
function UIBase:_AddToContainer()
  local startTime, strFrom
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  local ParentWidget = self._UIRootProxy and self._UIRootProxy.ParentWidget
  if self._AttachPanel then
    strFrom = "_AttachPanel"
    if type(self._AttachPanel) == "string" then
      self._parentUI:AttachChildWindow(self._AttachPanel, self)
    else
      self._parentUI:AttachChildWindowByControl(self._AttachPanel, self)
    end
    local root = self.UIRoot
    if not root then
      log_error("UIBase:_AddToContainer root = nil keyName:" .. self:_GetKeyName(self._config))
      return
    end
    if root.Slot then
      if root.Slot.SetAnchors then
        self:SetAnchors(0, 0, 1, 1)
        self:SetOffsets(0, 0, 0, 0)
      else
      end
    else
      log_error("UIBase:_AddToContainer Slot = nil keyName:" .. self:_GetKeyName(self._config))
    end
  elseif ParentWidget then
    strFrom = "widget_proxy.ParentWidget"
    ParentWidget:AddChild(self.UIRoot)
  elseif self.containerName ~= UIContainers.None then
    strFrom = "UIContainers"
    game_frontend_hud.AddToContainer(self.containerName, self.UIRoot, self._zOrder)
  else
    strFrom = "None"
  end
  if GMDebug then
    log(bWriteLog and string_format("TimeTracer UIBase:_AddToContainer keyName:%s from:%s time:[%.3fms]", self:_GetKeyName(self._config), strFrom, (TimeUtil.GetMicroseconds() - startTime) / 1000))
  end
end
function UIBase:_RemoveFromHUDContainer()
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  if self.containerName ~= UIContainers.None then
    game_frontend_hud.RemoveFromContainer(self.containerName, self.UIRoot)
  end
  if GMDebug then
    log(bWriteLog and string_format("TimeTracer UIBase:_RemoveFromHUDContainer keyName:%s time:[%.3fms]", self:_GetKeyName(self._config), (TimeUtil.GetMicroseconds() - startTime) / 1000))
  end
end
function UIBase:_OnSyncUILoad()
  self:_AddToContainer()
  self:_PostInit()
end
function UIBase:_PostInitInner()
  self:OnInitialize()
  self:RegistEvents()
  self:OnPostInitialize()
  self:AutoSwitchPosInLobbyOrMainCity()
  if not self.bIsInCombatState and base_config_util.IsSingleton(self._config) and UIManager.iTCDeviceLevel > 3 then
    self:PlayEntryAnimation()
  end
end
function UIBase:_PostInit()
  local loadUIEndTime = TimeUtil.GetMicroseconds()
  if self._config and not UIManager._ApplyPreRegisteredDepth(self._config, self) then
    UIManager._OnUIShowforDepthManager(self._config, self)
  end
  xpcall(self._PostInitInner, xpcallHandle, self)
  if not self.bIsInCombatState and bWriteLog then
    local onInitializeEndTime = TimeUtil.GetMicroseconds()
    if self._DebugInfo and self._DebugInfo.startTime then
      log(bWriteLog and string_format("TimeTracer [UIBase:Init] %s totalTime: [%.3fms]. step1 LoadUIAndAddChild time: [%.3fms] bSync=%s bPool=%s. step2 OnInitialize time: [%.3fms] MountUI:%s", self:_GetKeyName(self._config), (onInitializeEndTime - self._DebugInfo.startTime) / 1000, (loadUIEndTime - self._DebugInfo.startTime) / 1000, tostring(self._DebugInfo.bSync), tostring(self._DebugInfo.bPool), (onInitializeEndTime - loadUIEndTime) / 1000, self._AttachPanel and "true" or "false"))
    end
  end
  if not self.bIsInCombatState and type(self.Tick) == "function" then
    self:AddTimerLoop(0, function(deltaTime)
      self:Tick(deltaTime)
    end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  end
end
function UIBase:PostShowUI(showVisibility, statUIInfo)
  if self:IsAsyncLoading() then
    self._AsyncStatUIInfo = {showVisibility = showVisibility, statUIInfo = statUIInfo}
  else
    self:PostShowUIEnd(statUIInfo, showVisibility)
  end
end
function UIBase:PostShowUIEnd(statUIInfo, showVisibility)
  if not self._config then
    log("UIBase:PostShowUIEnd self._config is nil")
    return
  end
  if self.UIRoot == nil then
    log_error("UIBase:PostShowUIEnd Must load ui before call PostShowUIEnd")
    return
  end
  if showVisibility ~= nil and showVisibility ~= UIContainers.ShowVisibilityAction.DontCare then
    self:SetVisibility(showVisibility)
  end
  if not self.bIsInCombatState and statUIInfo and statUIInfo.bStatUI and statUIInfo.uiStatName then
    BusinessHelper.StopUIStat(statUIInfo.uiStatName, true)
  end
  if base_config_util.IsSingleton(self._config) then
    if not self.bIsInCombatState then
      EventSystem:postEvent(EVENTID_UI, BP_ENUM_UI_SHOW, self._config)
    else
      EventSystem:postEvent(EVENTID_UI, BP_ENUM_UI_SHOW_FOR_BATTLE, self._config)
    end
  end
  self:_AddDetectOrRemoveWhiteList(true)
end
function UIBase:_AsyncInit()
  self:_SetUIRoot(widget_proxy.Create())
  local bUnique = base_config_util.IsUniquePath(self._config)
  local AsyncLoadHandleID = loadFromCacheHandleID
  if self._canUsePool then
    local pool = self:_GetPool()
    AsyncLoadHandleID = pool:GetAsy(self._bpPath, function(UI, bPoolCtor)
      if not self.bIsInCombatState then
        self:_SetDebugExtend(false, not bPoolCtor)
      end
      if not UI then
        log(bWriteLog and "UIBase:_AsyncInit.  error")
        self:CloseSelf()
        return
      end
      if not slua_isValid(UI) then
        xpcallHandle(string_format("UIBase:_AsyncInit() slua.isValid(UI) is false type(UI):%s ", type(UI)))
        self:CloseSelf()
        return
      end
      self:_OnAsyncLoaded(UI)
    end, bUnique)
  else
    AsyncLoadHandleID = slua_AsyncLoadUI(self._bpPath, function(_, UI)
      if not self.bIsInCombatState then
        self:_SetDebugExtend(true, false)
      end
      if not UI then
        log(bWriteLog and "UIBase:_AsyncInit.  error")
        self:CloseSelf()
        return
      end
      if not slua_isValid(UI) then
        xpcallHandle(string_format("UIBase:_AsyncInit() slua.isValid(UI) is false type(UI):%s ", type(UI)))
        self:CloseSelf()
        return
      end
      self:_OnAsyncLoaded(UI)
    end, bUnique)
  end
  if AsyncLoadHandleID ~= loadFromCacheHandleID then
    self._  end
  return true
end
function UIBase:IsAsyncLoading()
  return self._AsyncLoadHandleID ~= nil
end
function UIBase:_OnAsyncLoaded(UIRoot)
  if self._AsyncStatUIInfo then
    self._AsyncStatUIInfo.time2 = slua_getMiliseconds()
  end
  if GMDebug then
    log(bWriteLog and string_format("UIBase:_OnAsyncLoaded keyName:%s self.containerName:%s", self:_GetKeyName(self._config), tostring(self.containerName)))
  end
  self._AsyncLoadHandleID = nil
  if self.UIRoot == nil then
    return
  end
  self._UIRootProxy = self.UIRoot
  self._UIRootProxy.Widget = UIRoot
  self:_SetUIRoot(UIRoot)
  if self._parentUI and self._parentUI:IsAsyncLoading() then
    return
  end
  self:_HandleAsyncLoaded()
  if self._childUIList then
    for _, childUI in ipairs(self._childUIList) do
      childUI:_HandleAsyncLoaded()
    end
  end
end
function UIBase:_HandleAsyncLoaded()
  if not self._UIRootProxy then
    return
  end
  if GMDebug then
    log(bWriteLog and string_format("UIBase:_HandleAsyncLoaded keyName:%s self.containerName:%s self._UIRootProxy.ParentWidget:%s", self:_GetKeyName(self._config), tostring(self.containerName), tostring(self._UIRootProxy.ParentWidget)))
  end
  self.UIRoot:SetWidgetRender(0)
  self:_AddToContainer()
  self:_PostInit()
  self:_AsyncPostShowUI()
  widget_proxy_util.ReplayProxy(self._UIRootProxy, self.UIRoot)
  self._UIRootProxy = nil
  if self.UIRoot then
    self:_UpdateIsShow()
    self:_AsyncAddControlEvent()
  end
  if not self.bIsInCombatState then
    self:_AsyncJumpBack()
  end
end
function UIBase:_AsyncPostShowUI()
  if self._AsyncStatUIInfo ~= nil then
    self:PostShowUIEnd(self._AsyncStatUIInfo.statUIInfo, self._AsyncStatUIInfo.showVisibility)
    self._AsyncStatUIInfo = nil
  end
end
function UIBase:_AsyncAddControlEvent()
  if not self._AsyncEventCommands then
    return
  end
  for i = 1, #self._AsyncEventCommands do
    log_error("UIBase:_AsyncAddControlEvent \228\184\186\229\149\165\228\188\154\230\156\137\229\188\130\230\173\165\229\138\160\232\189\189\230\151\182\229\128\153\239\188\140\230\179\168\229\134\140\230\142\167\228\187\182")
    local EventCmd = self._AsyncEventCommands[i]
    local Control = EventCmd[1]
    local controlType = type(Control)
    if controlType == "table" then
      Control = widget_proxy_util.GetControlByPropCmd(self.UIRoot, Control)
    elseif controlType == "string" then
      Control = self:_GetControlByName(Control)
    end
    local packValue = EventCmd[3]
    if type(packValue) == "table" then
      self:AddControlEventByControlWithCondition(Control, table_unpack(EventCmd, 2))
    else
      self:AddControlEventByControl(Control, table_unpack(EventCmd, 2))
    end
    self._AsyncEventCommands[i] = nil
  end
end
function UIBase:_UnRegistEvents()
  if self._controlEventsForUI then
    for control, events in pairs(self._controlEventsForUI) do
      if slua_isValid(control) then
        for eventName, delegate in pairs(events) do
          local eventDelegate = control[eventName]
          if slua_isValid(eventDelegate) then
            if eventDelegate.Remove then
              eventDelegate:Remove(delegate)
            else
              eventDelegate:Clear()
            end
          else
            slua_removeDelegate(delegate)
          end
        end
      else
        for _, delegate in pairs(events) do
          slua_removeDelegate(delegate)
        end
      end
      self._controlEventsForUI[control] = nil
    end
    self._controlEventsForUI = nil
  end
  if self._commonEvents then
    for eventType, events in pairs(self._commonEvents) do
      for eventID, eventFunc in pairs(events) do
        EventSystem:unregistEvent(eventType, eventID, eventFunc)
      end
      self._commonEvents[eventType] = nil
    end
    self._commonEvents = nil
  end
  self:RemoveAllDataListener()
  if self._uiMessageEvents then
    for MessageName, Func in pairs(self._uiMessageEvents) do
      UIMessageSystem.RemoveUIMessageEvent(MessageName, Func)
    end
    self._uiMessageEvents = nil
  end
  if self._luaNetListeners then
    for actor, listeners in pairs(self._luaNetListeners) do
      if slua_isValid(actor) then
        for propName, func in pairs(listeners) do
          actor:RemoveLuaNetListener(propName, func)
        end
      end
      self._luaNetListeners[actor] = nil
    end
    self._luaNetListeners = nil
  end
  if self._promiseMap then
    local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
    for p, _ in pairs(self._promiseMap) do
      p:ClearCallbacks()
      ProtoPromiseHookTool.RemovePromise(p)
    end
    self._promiseMap = nil
  end
  self._LuaObjEventContainer = nil
  if self._LuaObjListener then
    for LuaObjListener, controlListeners in pairs(self._LuaObjListener) do
      for CacheEventName, HandleFunc in pairs(controlListeners) do
        if LuaObjListener and LuaObjListener._LuaObjEvents and LuaObjListener._LuaObjEvents[CacheEventName] then
          local PackLuaEvents = LuaObjListener._LuaObjEvents[CacheEventName]
          if PackLuaEvents then
            PackLuaEvents[self] = nil
          end
        end
      end
      self._LuaObjListener[LuaObjListener] = nil
    end
  end
  self._LuaObjListener = nil
end
function UIBase:UnRegistEvents()
  self:_UnRegistEvents()
  self:OnUnRegistEvents()
end
function UIBase:RemoveAllDataListener()
  if self._dataListeners then
    for superData, listeners in pairs(self._dataListeners) do
      for fieldName, callback in pairs(listeners) do
        superData:RemoveListener(fieldName, callback)
      end
    end
    self._dataListeners = nil
  end
end
function UIBase:AddSettingOptionEvent(OptionName, handleFunc, bInitialCall)
  if not assert(OptionName and handleFunc, "UIBase:AddSettingOptionEvent param invalid") then
    return false
  end
  local SettingModule = ModuleManager_GetModule(CommonModuleConfig.SettingModule)
  if not self._settingOptionListeners then
    self._settingOptionListeners = {}
  end
  local bSuccess = SettingModule:AddOptionValueChangeEvent(OptionName, handleFunc, bInitialCall)
  if bSuccess then
    self._settingOptionListeners[OptionName] = true
  end
  return bSuccess
end
function UIBase:RemoveSettingOptionEvent(OptionName)
  if not assert(OptionName, "UIBase:RemoveSettingOptionEvent param invalid") then
    return false
  end
  if not self._settingOptionListeners then
    return
  end
  if not self._settingOptionListeners[OptionName] then
    return
  end
  local SettingModule = ModuleManager_GetModule(CommonModuleConfig.SettingModule)
  SettingModule:RemoveOptionValueChangeEvent(OptionName)
  self._settingOptionListeners[OptionName] = nil
end
function UIBase:RemoveAllSettingOptionEvent()
  if not self._settingOptionListeners then
    return
  end
  local SettingModule = ModuleManager_GetModule(CommonModuleConfig.SettingModule)
  for OptionName, _ in pairs(self._settingOptionListeners) do
    SettingModule:RemoveOptionValueChangeEvent(OptionName)
  end
  self._settingOptionListeners = nil
end
function UIBase:CloseSelf()
  if not self._config then
    log_error("UIBase:CloseSelf No Config: ", self._moduleName)
    return
  end
  if not base_config_util.IsSingleton(self._config) then
    self:Close()
    log_error("UIBase:CloseSelf is not Singleton! keyName:" .. self:_GetKeyName(self._config))
    return
  end
  UIManager.CloseUI(self._config)
end
function UIBase:_CloseChildWindows()
  if not self._childUIList or #self._childUIList <= 0 then
    return
  end
  if self.UIRoot then
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
end
function UIBase:_RemoveAllAudio()
  if self._AudioListTable then
    for AudioID, _ in pairs(self._AudioListTable) do
      audio_util.StopAudio(AudioID)
    end
  end
  if self._AudioAsyncHandleTable then
    for AsyncHandle, _ in pairs(self._AudioAsyncHandleTable) do
      asset_util.CancelAssetAsync(AsyncHandle)
    end
  end
  self._AudioListTable = nil
  self._AudioAsyncHandleTable = nil
end
function UIBase:Close()
  self._IsClosed = true
  if self._config then
    log(bWriteLog and "UIBase:Close keyName:" .. self:_GetKeyName(self._config))
  end
  if not self.bIsInCombatState and base_config_util.EnableCDNCompress(self._config) then
    FuncUtil_UE4ExecuteConsoleCommand("s.EnableCompressFormatDownload 0")
  end
  self:_RemoveImageDownloadData()
  self:_RemoveAllAsyncDiskFile()
  self._AsyncEventCommands = nil
  self._AsyncStatUIInfo = nil
  self:RemoveAllTimer()
  self:RemoveAllGameTimer()
  self:RemoveAllClock()
  self:RemoveAllMusic()
  self:RemoveAllSettingOptionEvent()
  self:_UpdateShow(false)
  self:_RemoveLoadedDelegates()
  self:_UnregistAllReddot()
  self:_RemoveAllAudio()
  if self._parentUI then
    self._parentUI:_OnChildWindowClose(self)
  end
  if self.UIRoot then
    xpcall(self.UnRegistEvents, xpcallHandle, self)
    xpcall(self._CloseChildWindows, xpcallHandle, self)
    if GMDebug and self._loadFromPool then
      log(bWriteLog and string_format("UIBase:Close: keyName:%s", self:_GetKeyName(self._config)))
    end
    if self:IsAsyncLoading() then
      if self._canUsePool then
        local pool = self:_GetPool()
        local canRet = pool:Cancel(self._AsyncLoadHandleID)
        log(bWriteLog and "UIBase:Close Cancel keyName:" .. self:_GetKeyName(self._config) .. " ,_AsyncLoadHandleID:" .. self._AsyncLoadHandleID .. " ,canRet:" .. tostring(canRet))
      else
        local canRet = slua_CancelLoadUI(self._AsyncLoadHandleID)
        log(bWriteLog and "UIBase:Close CancelLoadUI keyName:" .. self:_GetKeyName(self._config) .. " ,_AsyncLoadHandleID:" .. self._AsyncLoadHandleID .. " ,canRet:" .. tostring(canRet))
      end
      self._AsyncLoadHandleID = nil
    else
      self:_AddDetectOrRemoveWhiteList(false)
      self:_RemoveFromHUDContainer()
      xpcall(self.OnClose, xpcallHandle, self)
      if self._loadFromPool == nil then
      elseif self._canUsePool then
        local pool = self:_GetPool()
        pool:Release(self.UIRoot)
      elseif self.bIsInCombatState then
        self.UIRoot:ConditionalBeginDestroy()
      else
        self.UIRoot:RemoveFromParent()
      end
    end
    self:_ResetSwitchPosWidgetPosition()
    self._config = false
    self:_SetUIRoot(nil)
  end
end
function UIBase:_AddChildWindow(childUI)
  if not self._childUIList then
    self._childUIList = {}
  end
  self._childUIList[#self._childUIList + 1] = childUI
  childUI._parentUI = self
end
function UIBase:_OnChildWindowClose(childUI)
  if not self._childUIList or #self._childUIList <= 0 then
    return
  end
  for i = #self._childUIList, 1, -1 do
    if self._childUIList[i] == childUI then
      table_remove(self._childUIList, i)
    end
  end
end
function UIBase:GetParentUI()
  return self._parentUI
end
function UIBase:GetChildWindow(config)
  if not self._childUIList or #self._childUIList <= 0 then
    return nil
  end
  local childWindow
  for i = 1, #self._childUIList do
    local v = self._childUIList[i]
    if self._config and v._config == config then
      childWindow = v
      break
    end
  end
  return childWindow
end
function UIBase:GetChildWindowByConfigKeyName(keyName)
  if not self._childUIList or #self._childUIList <= 0 then
    return nil
  end
  local childWindow
  for i = 1, #self._childUIList do
    local v = self._childUIList[i]
    if self._config and self:_GetKeyName(v._config) == keyName then
      childWindow = v
      break
    end
  end
  return childWindow
end
function UIBase:PlayEntryAnimation()
  tween_animation_util:PlayEntryAnimation(self.UIRoot, self)
end
function UIBase:OnInitialize()
end
function UIBase:RegistEvents()
end
function UIBase:OnPostInitialize()
end
function UIBase:OnShow()
end
function UIBase:OnHide()
end
function UIBase:OnClose()
end
function UIBase:OnUnRegistEvents()
end
function UIBase:GetSwitchPosWidget()
  if not self.UIRoot or not slua_isValid(self.UIRoot) then
    return nil
  end
  return self.UIRoot.ChangePosWidget
end
function UIBase:GetSwitchPosOffset()
  return FVector2D(0, 0)
end
function UIBase:_SetDebugStartTime(startTime)
  if not bWriteLog then
    return
  end
  if not self._DebugInfo then
    self._DebugInfo = {}
  end
  self._DebugInfo.end
function UIBase:_SetDebugExtend(bSync, bPool)
  if not bWriteLog then
    return
  end
  if not self._DebugInfo then
    self._DebugInfo = {}
  end
  self._DebugInfo.  self._DebugInfo.end
function UIBase:_GetPool()
  return EUIConfigPoolType.GetModuleByType(self._loadFromPool)
end
function UIBase:_GetKeyName(config)
  return base_config_util.GetKeyName(config)
end
function UIBase:InitWithWidget(widget)
  if not widget then
    log_error("UIBase:InitWithWidget widget is nil!")
    return
  end
  self:_SetUIRoot(widget)
  xpcall(self._PostInitInner, xpcallHandle, self)
  if not self.bIsInCombatState and type(self.Tick) == "function" then
    self:AddTimerLoop(0, function(deltaTime)
      self:Tick(deltaTime)
    end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  end
end
function UIBase:InitCommonPopup(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_popup_box, widget)
end
function UIBase:InitCommonPopupWithTab(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_popup_box_with_tab, widget)
end
function UIBase:InitCommonPopupWithSubTab(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_popup_box_with_sub_tab, widget)
end
function UIBase:InitHorizontalLevelOneTextTab(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_tab_horizontal_levelone_text, widget, ...)
end
function UIBase:InitHorizontalLevelOneIconTab(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Tab_Horizontal_LevelOne_Icon_UIBP, widget, ...)
end
function UIBase:InitHomeHorizontalLevelOneTextTab(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_home_tab_horizontal_levelone_text, widget)
end
function UIBase:InitHorizontalLevelTwoTextTab(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_tab_horizontal_leveltwo_text, widget, ...)
end
function UIBase:InitHorizontalLevelThreeTextTab(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_tab_horizontal_levelthree_text, widget, ...)
end
function UIBase:InitHorizontalLevelThreeTextPaddingTab(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_tab_horizontal_levelthree_text_padding, widget, ...)
end
function UIBase:InitHorizontalSmallTextTab(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_tab_horizontal_small_text, widget, ...)
end
function UIBase:InitHorizontalCustomTab(widget, itemConfig)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.common_tab_horizontal_custom, widget, itemConfig)
end
function UIBase:InitVerticalTextTab(widget, bAutoSelect, bAutoSelectSub)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Tab_Vertical_LevelOne_Text_UIBP, widget, bAutoSelect, bAutoSelectSub)
end
function UIBase:InitVerticalIconTab(widget, bAutoSelect, noAnim)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Tab_Vertical_LevelOne_Icon_UIBP, widget, bAutoSelect, noAnim)
end
function UIBase:InitVerticalNoBgTab(widget, itemModuleName, jumpModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Tab_Vertical_NoBg_UIBP, widget, itemModuleName, jumpModuleName)
end
function UIBase:InitScrollBox(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.loop_scroll_box, widget)
end
function UIBase:InitChildClassScrollBox(widget, itemModuleName, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.loop_scroll_box, widget, itemModuleName, ...)
end
function UIBase:InitChildClassInfiniteScrollBox(widget, itemModuleName, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.infinite_loop_scroll_box, widget, itemModuleName, ...)
end
function UIBase:InitScrollBoxMultiSelect(widget, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.loop_scroll_box_multi_select, widget, itemModuleName)
end
function UIBase:InitItemSlidableLoopScrollBox(widget, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.item_slidable_loop_scroll_grid, widget, itemModuleName)
end
function UIBase:InitLazySortScrollBox(widget, config, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.lazy_sort_loop_scroll_box, widget, config, itemModuleName)
end
function UIBase:InitLazyInitScrollBox(widget, config, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.lazy_init_loop_scroll_box, widget, config, itemModuleName)
end
function UIBase:InitReuseListMultiSize(widget, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.reuse_list_multi_size, widget, itemModuleName)
end
function UIBase:InitExtendedScrollBox(widget, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.extended_loop_scroll_box, widget, itemModuleName)
end
function UIBase:InitExtendedScrollGrid(widget, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.extended_loop_scroll_grid, widget, itemModuleName)
end
function UIBase:InitExtendedScrollGridWithTail(widget, itemModuleName)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.extended_loop_scroll_grid_with_tail, widget, itemModuleName)
end
function UIBase:InitMultiItemsScrollGrid(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.multi_items_loop_scroll_grid, widget)
end
function UIBase:InitMultiItemsScrollGridWithScript(widget, itemTypeScriptPath, subItemScriptPath)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  local instance = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.multi_items_loop_scroll_grid, widget)
  if instance then
    instance._    instance._  end
  return instance
end
function UIBase:InitReuseFallMultiSize(widget, itemModuleName, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.reuse_fall_multi_size, widget, itemModuleName, ...)
end
function UIBase:InitUniformPanelProxy(widget, bpPath)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.uniform_panel_proxy, widget, bpPath)
end
function UIBase:InitCustomComboBox(widget, bWow)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.custom_combobox, widget, bWow)
end
function UIBase:InitCommonComboBoxNew(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_ComboBox_UIBP, widget, ...)
end
function UIBase:InitScrollPage(widget, itemModuleName, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.loop_scroll_page, widget, itemModuleName, ...)
end
function UIBase:InitCommonGyroscopeTemplate(widget)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Gyroscope_Template, widget)
end
function UIBase:InitBoxCoinComponent(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Coin_Box_UIBP, widget, ...)
end
function UIBase:InitUMGAASyncComponent(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.UMGAASyncComponent, widget, ...)
end
function UIBase:InitCommonSlider(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Basic_Slider_UIBP, widget, ...)
end
function UIBase:InitCommonCount(widget, ...)
  local UIComponentModule = ModuleManager_GetModule(CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_Basic_Count_UIBP, widget, ...)
end
function UIBase:_GetControlByName(controlName, control)
  control = control or self.UIRoot
  if controlName == "" then
    return control
  end
  if not string_find(controlName, ".", 1, true) then
    return control[controlName]
  end
  string_gsub(controlName, "([^.]*)", function(c)
    control = control[c]
    if not control then
      log_error(string_format("control is nil! controlName\239\188\154[%s]", controlName))
    end
  end)
  return control
end
function UIBase:InitPageGuideComponent(widget, data, ...)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_PageGuide_Component_UIBP, widget, data)
end
function UIBase:PageGuideThemeComponent(widget, data, ...)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_PageGuide_Theme_Component_UIBP, widget, data)
end
function UIBase:PageGuideThemeRoleComponent(widget, data, ...)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_PageGuide_Theme_Role_Component_UIBP, widget, data)
end
function UIBase:AddOnClickedEventByControl(control, handleFunc, ...)
  return self:AddControlEventByControl(control, "OnClicked", handleFunc, ...)
end
function UIBase:RemoveOnClickedEventByControl(control)
  return self:RemoveControlEventByControl(control, "OnClicked")
end
function UIBase:AddOnPressedEventByControl(control, handleFunc, ...)
  return self:AddControlEventByControl(control, "OnPressed", handleFunc, ...)
end
function UIBase:RemoveOnPressedEventByControl(control)
  return self:RemoveControlEventByControl(control, "OnPressed")
end
function UIBase:AddOnReleasedEventByControl(control, handleFunc, ...)
  return self:AddControlEventByControl(control, "OnReleased", handleFunc, ...)
end
function UIBase:RemoveOnReleasedEventByControl(control)
  return self:RemoveControlEventByControl(control, "OnReleased")
end
function UIBase:AddOnCheckStateChangedEventByControl(control, handleFunc, ...)
  return self:AddControlEventByControl(control, "OnCheckStateChanged", handleFunc, ...)
end
function UIBase:RemoveOnCheckStateChangedEventByControl(control)
  return self:RemoveControlEventByControl(control, "OnCheckStateChanged")
end
function UIBase:AddOnTextChangedEventByControl(control, handleFunc, ...)
  return self:AddControlEventByControl(control, "OnTextChanged", handleFunc, ...)
end
function UIBase:RemoveOnTextChangedEventByControl(control)
  return self:RemoveControlEventByControl(control, "OnTextChanged")
end
function UIBase:AddOnAnimationStartedEvent(animationlName, handleFunc, ...)
  return self:AddControlEventByControl(self.UIRoot[animationlName], "OnAnimationStarted", handleFunc, ...)
end
function UIBase:RemoveOnAnimationStartedEvent(animationlName)
  return self:RemoveControlEventByControl(self.UIRoot[animationlName], "OnAnimationStarted")
end
function UIBase:AddOnAnimationFinishedEvent(animationlName, handleFunc, ...)
  return self:AddControlEventByControl(self.UIRoot[animationlName], "OnAnimationFinished", handleFunc, ...)
end
function UIBase:RemoveOnAnimationFinishedEvent(animationlName)
  return self:RemoveControlEventByControl(self.UIRoot[animationlName], "OnAnimationFinished")
end
function UIBase:AddWidgetOnAnimationStartedEvent(widget, animationlName, handleFunc, ...)
  return self:AddControlEventByControl(widget[animationlName], "OnAnimationStarted", handleFunc, ...)
end
function UIBase:RemoveWidgetOnAnimationStartedEvent(widget, animationlName)
  return self:RemoveControlEventByControl(widget[animationlName], "OnAnimationStarted")
end
function UIBase:AddWidgetOnAnimationFinishedEvent(widget, animationlName, handleFunc, ...)
  return self:AddControlEventByControl(widget[animationlName], "OnAnimationFinished", handleFunc, ...)
end
function UIBase:RemoveWidgetOnAnimationFinishedEvent(widget, animationlName)
  return self:RemoveControlEventByControl(widget[animationlName], "OnAnimationFinished")
end
function UIBase:HasControlEventByControl(control, eventName)
  if not slua_isValid(control) then
    log_error(string_format("UIBase:HasControlEventByControl. not control eventName=%s", tostring(eventName)))
    return false
  end
  if not assert(type(eventName) == "string", "UIBase:HasControlEventByControl. eventName is not a string") then
    return false
  end
  if not self._controlEventsForUI then
    return false
  end
  local controlEvents = self._controlEventsForUI[control]
  if controlEvents then
    local funcDelegate = controlEvents[eventName]
    if funcDelegate then
      return true
    end
  end
  return false
end
function UIBase:AddControlEvent(controlName, eventName, handleFunc, ...)
  log_error(string_format("UIBase:AddControlEvent abandoned. controlName=%s, eventName=%s", tostring(controlName), tostring(eventName)))
  local control = self:_GetControlByName(controlName)
  if not control then
    log_error(string_format("UIBase:AddControlEvent. not control controlName=%s, eventName=%s", tostring(controlName), tostring(eventName)))
    return false
  end
  if self:IsAsyncLoading() then
    if not self._AsyncEventCommands then
      self._AsyncEventCommands = {}
    end
    local EventCommands = self._AsyncEventCommands
    EventCommands[#EventCommands + 1] = table_pack(controlName, eventName, handleFunc, ...)
    return true
  end
  return self:AddControlEventByControl(control, eventName, handleFunc, ...)
end
function UIBase:AddControlEventByControl(control, eventName, handleFunc, ...)
  if not control then
    xpcallHandle(string_format("UIBase:AddControlEventByControl. not control eventName=%s", tostring(eventName)))
    return false
  end
  if not slua_isValid(control) and type(control) ~= "table" then
    xpcallHandle(string_format("UIBase:AddControlEventByControl. control type=%s", tostring(type(control))))
  end
  if not assert(type(eventName) == "string", "UIBase:AddControlEventByControl. eventName is not a string") then
    return false
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) and type(eventDelegate) ~= "table" then
    xpcallHandle(string_format("UIBase:AddControlEventByControl. not eventDelegate eventName=%s", tostring(eventName)))
    return false
  end
  if not assert(type(handleFunc) == "function", "UIBase:AddControlEventByControl. handleFunc is not a function") then
    return false
  end
  if not self._controlEventsForUI then
    self._controlEventsForUI = {}
  end
  local controlEvents = self._controlEventsForUI[control]
  if not controlEvents then
    controlEvents = {}
    self._controlEventsForUI[control] = controlEvents
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate then
    if eventDelegate.Remove then
      local bIsSucceed = pcall(eventDelegate.Remove, eventDelegate, funcDelegate)
      if not bIsSucceed then
        log_error("Remove Delegate Error:" .. eventName)
      end
    else
      eventDelegate:Clear()
    end
  end
  local args = table_pack(...)
  if eventDelegate.Add then
    controlEvents[eventName] = eventDelegate:Add(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end)
  else
    controlEvents[eventName] = eventDelegate:Bind(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end)
  end
  return true
end
function UIBase:AddControlEventByControlWithCondition(control, eventName, condTable, handleFunc, ...)
  if not control then
    xpcallHandle(string_format("UIBase:AddControlEventByControlWithCondition. not control eventName=%s", tostring(eventName)))
    return false
  end
  if not slua_isValid(control) and type(control) ~= "table" then
    xpcallHandle(string_format("UIBase:AddControlEventByControlWithCondition. control type=%s", tostring(type(control))))
  end
  if not assert(type(eventName) == "string", "UIBase:AddControlEventByControlWithCondition. eventName is not a string") then
    return false
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) and type(eventDelegate) ~= "table" then
    xpcallHandle(string_format("UIBase:AddControlEventByControlWithCondition. not eventDelegate eventName=%s", tostring(eventName)))
    return false
  end
  if not assert(type(handleFunc) == "function", "UIBase:AddControlEventByControlWithCondition. handleFunc is not a function") then
    return false
  end
  if not self._controlEventsForUI then
    self._controlEventsForUI = {}
  end
  local controlEvents = self._controlEventsForUI[control]
  if not controlEvents then
    controlEvents = {}
    self._controlEventsForUI[control] = controlEvents
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate then
    if eventDelegate.Remove then
      local bIsSucceed = pcall(eventDelegate.Remove, eventDelegate, funcDelegate)
      if not bIsSucceed then
        log_error("Remove Delegate Error:" .. eventName)
      end
    else
      eventDelegate:Clear()
    end
  end
  local args = table_pack(...)
  if eventDelegate.Add then
    controlEvents[eventName] = eventDelegate:Add(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end, condTable)
  else
    controlEvents[eventName] = eventDelegate:Bind(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end, condTable)
  end
  return true
end
function UIBase:AddControlEventConditionOnly(control, eventName, condTable, handleFunc, ...)
  if not control then
    xpcallHandle(string_format("UIBase:AddControlEventConditionOnly. not control eventName=%s", tostring(eventName)))
    return false
  end
  if not slua_isValid(control) and type(control) ~= "table" then
    xpcallHandle(string_format("UIBase:AddControlEventConditionOnly. control type=%s", tostring(type(control))))
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) and type(eventDelegate) ~= "table" then
    xpcallHandle(string_format("UIBase:AddControlEventConditionOnly. not eventDelegate eventName=%s", tostring(eventName)))
    return false
  end
  if not condTable then
    log_error("UIBase:AddControlEventConditionOnly. condTable is nil")
    return
  end
  if not self._controlEventsForUI then
    self._controlEventsForUI = {}
  end
  local controlEvents = self._controlEventsForUI[control]
  if not controlEvents then
    controlEvents = {}
    self._controlEventsForUI[control] = controlEvents
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate and eventDelegate.AddCondition then
    eventDelegate:AddCondition(funcDelegate, condTable)
  end
end
function UIBase:RemoveControlEventByControl(control, eventName)
  if not self._controlEventsForUI then
    return false
  end
  if not control then
    xpcallHandle(string_format("UIBase:RemoveControlEventByControl. not control eventName=%s", tostring(eventName)))
    return false
  end
  if not slua_isValid(control) and type(control) ~= "table" then
    xpcallHandle(string_format("UIBase:RemoveControlEventByControl. control type=%s", tostring(type(control))))
  end
  if not assert(type(eventName) == "string", "UIBase:RemoveControlEventByControl. eventName is not a string") then
    return false
  end
  local eventDelegate = control[eventName]
  local controlEvents = self._controlEventsForUI[control]
  if not controlEvents then
    return false
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate then
    if slua_isValid(eventDelegate) then
      if eventDelegate.Remove then
        eventDelegate:Remove(funcDelegate)
      else
        eventDelegate:Clear()
      end
    else
      slua_removeDelegate(funcDelegate)
    end
    controlEvents[eventName] = nil
    if not next(controlEvents) then
      self._controlEventsForUI[control] = nil
    end
    return true
  else
    return false
  end
end
function UIBase:AddCommonEvent(eventType, eventID, handleFunc, ...)
  if not assert(type(eventType) == "number" and type(eventID) == "number" and type(handleFunc) == "function", "AddCommonEvent eventType should be number,eventID should be number,handleFunc should be function") then
    return
  end
  if not self._commonEvents then
    self._commonEvents = {}
  end
  local events = self._commonEvents[eventType]
  if not events then
    events = {}
    self._commonEvents[eventType] = events
  end
  local eventFunc = events[eventID]
  if eventFunc then
    log_error(string_format("UIBase:AddCommonEvent already have eventID. eventType, eventID=%s, %s", EventDefineID[eventType], EventDefineID[eventID]))
    return
  end
  local Func = function(...)
    handleFunc(...)
  end
  events[eventID] = Func
  return EventSystem:registEvent(eventType, eventID, Func, ...)
end
function UIBase:IsCommonEventExists(eventType, eventID)
  if not assert(type(eventType) == "number" and type(eventID) == "number", "IsCommonEventExists eventType should be number,eventID should be number") then
    return
  end
  if not self._commonEvents then
    self._commonEvents = {}
  end
  local events = self._commonEvents[eventType]
  return events and events[eventID] ~= nil
end
function UIBase:RemoveCommonEvent(eventType, eventID)
  if not assert(type(eventType) == "number" and type(eventID) == "number", "RemoveCommonEvent eventType should be number,eventID should be number") then
    return
  end
  if not self._commonEvents then
    self._commonEvents = {}
  end
  local events = self._commonEvents[eventType]
  if not events then
    log_error(string_format("UIBase:RemoveCommonEvent Can't remove event because eventType's[%s] events not found", eventType))
    return
  end
  local eventFunc = events[eventID]
  if not eventFunc then
    log_error(string_format("UIBase:RemoveCommonEvent Can't remove event because event not found for eventType[%s], eventID[%s]", eventType, eventID))
    return
  end
  if EventSystem:unregistEvent(eventType, eventID, eventFunc) then
    events[eventID] = nil
    return true
  end
  return false
end
function UIBase:AddUIMessageEvent(MessageName, Func, ...)
  if not self._uiMessageEvents then
    self._uiMessageEvents = {}
  end
  local PreFunc = self._uiMessageEvents[MessageName]
  if PreFunc then
    UIMessageSystem.RemoveUIMessageEvent(MessageName, PreFunc)
  end
  self._uiMessageEvents[MessageName] = function(...)
    return Func(...)
  end
  return UIMessageSystem.AddUIMessageEvent(MessageName, self._uiMessageEvents[MessageName], ...)
end
function UIBase:RemoveUIMessageEvent(MessageName)
  if not self._uiMessageEvents then
    return
  end
  local Func = self._uiMessageEvents[MessageName]
  if nil == Func then
    return
  end
  if UIMessageSystem.RemoveUIMessageEvent(MessageName, Func) then
    self._uiMessageEvents[MessageName] = nil
  end
end
function UIBase:AddDataListener(superData, fieldName, handleFunc, ...)
  local fullKey = fieldName
  if not self._dataListeners then
    self._dataListeners = {}
  end
  local dataListener = self._dataListeners[superData]
  if not dataListener then
    dataListener = {}
    self._dataListeners[superData] = dataListener
  end
  local oldListen = dataListener[fullKey]
  if oldListen then
    superData:RemoveListener(fullKey, oldListen)
  end
  local args = table_pack(...)
  local FuncWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  superData:AddListener(fullKey, FuncWrap)
  dataListener[fullKey] = FuncWrap
end
function UIBase:AddDataListenerNotFirstCallBack(superData, fieldName, handleFunc, ...)
  local fullKey = fieldName
  if not self._dataListeners then
    self._dataListeners = {}
  end
  local dataListener = self._dataListeners[superData]
  if not dataListener then
    dataListener = {}
    self._dataListeners[superData] = dataListener
  end
  local oldListen = dataListener[fullKey]
  if oldListen then
    superData:RemoveListener(fullKey, oldListen)
  end
  local args = table_pack(...)
  local FuncWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  superData:AddListener(fullKey, FuncWrap, true)
  dataListener[fullKey] = FuncWrap
end
function UIBase:RemoveDataListenerWithoutAssert(superData, fieldName)
  if not self._dataListeners then
    return
  end
  if not self._dataListeners[superData] then
    return
  end
  local fullKey = fieldName
  local callback = self._dataListeners[superData][fullKey]
  if not callback then
    return
  end
  superData:RemoveListener(fullKey, callback)
  self._dataListeners[superData][fullKey] = nil
end
function UIBase:RemoveDataListener(superData, fieldName)
  if not self._dataListeners then
    return
  end
  if not self._dataListeners[superData] then
    return
  end
  local fullKey = fieldName
  local callback = self._dataListeners[superData][fullKey]
  superData:RemoveListener(fullKey, callback)
  if not callback then
    return
  end
  self._dataListeners[superData][fullKey] = nil
end
function UIBase:AddLuaNetPropListener(actor, propName, handleFunc, ...)
  if not assert(type(propName) == "string", "UIBase:AddLuaNetPropListener. propName is not a string") then
    return
  end
  if not assert(type(handleFunc) == "function", "UIBase:AddLuaNetPropListener. handleFunc is not a function") then
    return
  end
  local args = table_pack(...)
  local funcWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if not self._luaNetListeners then
    self._luaNetListeners = {}
  end
  local listeners = self._luaNetListeners[actor]
  if not listeners then
    listeners = {}
    self._luaNetListeners[actor] = listeners
  end
  local oldFunc = listeners[propName]
  if oldFunc then
    actor:RemoveLuaNetListener(propName, oldFunc)
    listeners[propName] = nil
  end
  if actor:AddLuaNetListener(propName, funcWrap) then
    listeners[propName] = funcWrap
    funcWrap(actor[propName])
  end
end
function UIBase:RemoveLuaNetPropListener(actor, propName)
  if not self._luaNetListeners then
    return
  end
  if not assert(slua_isValid(actor), "UIBase:RemoveLuaNetPropListener. not actor") then
    return
  end
  if not assert(type(propName) == "string", "UIBase:RemoveLuaNetPropListener. propName is not a string") then
    return
  end
  local listeners = self._luaNetListeners[actor]
  if not listeners then
    return
  end
  local oldFunc = listeners[propName]
  if oldFunc then
    actor:RemoveLuaNetListener(propName, oldFunc)
    listeners[propName] = nil
  end
  if not next(listeners) then
    self._luaNetListeners[actor] = nil
  end
end
function UIBase:BindLuaObjEvent(LuaObj, eventName, handleFunc, ...)
  if LuaObj and LuaObj.LuaEventContainer then
    if LuaObj._LuaEventContainerSet == nil then
      LuaObj._LuaEventContainerSet = {}
      local LuaTable = LuaObj
      if LuaObj._GetRawClass then
        LuaTable = LuaObj:_GetRawClass()
      end
      self:_UpdateLuaEventContainerSet(LuaObj, LuaTable)
    end
    if not LuaObj._LuaEventContainerSet[eventName] then
      return false
    end
  end
  if not LuaObj._LuaObjEventContainer then
    LuaObj._LuaObjEventContainer = {}
  end
  if not LuaObj._LuaObjEventContainer._LuaObjEvents then
    LuaObj._LuaObjEventContainer._LuaObjEvents = {}
  end
  local args = table_pack(...)
  local PackFunAndArgs = table_pack(handleFunc, args)
  local PackLuaEvents = LuaObj._LuaObjEventContainer._LuaObjEvents[eventName]
  if not PackLuaEvents then
    PackLuaEvents = {}
    LuaObj._LuaObjEventContainer._LuaObjEvents[eventName] = PackLuaEvents
  end
  PackLuaEvents[self] = PackFunAndArgs
  if not self._LuaObjListener then
    self._LuaObjListener = {}
  end
  local controlListeners = self._LuaObjListener[LuaObj._LuaObjEventContainer]
  if not controlListeners then
    controlListeners = {}
    self._LuaObjListener[LuaObj._LuaObjEventContainer] = controlListeners
  end
  controlListeners[eventName] = handleFunc
  return true
end
function UIBase:_UpdateLuaEventContainerSet(LuaObj, RawClass)
  if RawClass then
    if RawClass.LuaEventContainer then
      for _, str in ipairs(RawClass.LuaEventContainer) do
        if LuaObj._LuaEventContainerSet[str] then
          log(bWriteLog and string_format("BindLuaObjEvent, Declared duplicate event names %s in %s !!", str, LuaObj))
        end
        LuaObj._LuaEventContainerSet[str] = true
      end
    end
    local superClass = RawClass.__super
    if superClass and superClass.__inner_impl then
      self:_UpdateLuaEventContainerSet(LuaObj, superClass.__inner_impl)
    end
  end
end
function UIBase:_GetRawClass()
  return self
end
function UIBase:UnBindLuaObjEvent(LuaObj, eventName)
  if not LuaObj then
    return
  end
  if not LuaObj._LuaObjEventContainer then
    return
  end
  if not LuaObj._LuaObjEventContainer._LuaObjEvents then
    return
  end
  local PackLuaEvents = LuaObj._LuaObjEventContainer._LuaObjEvents[eventName]
  if not PackLuaEvents then
    return
  end
  PackLuaEvents[self] = nil
  if not self._LuaObjListener then
    return
  end
  local controlListeners = self._LuaObjListener[LuaObj._LuaObjEventContainer]
  if controlListeners then
    controlListeners[eventName] = nil
  end
end
function UIBase:UnBindAllEvent(eventName)
  for LuaObjEventContainer, controlListeners in pairs(self._LuaObjListener) do
    for CacheEventName, HandleFunc in pairs(controlListeners) do
      if eventName == CacheEventName then
        if not LuaObjEventContainer then
          return
        end
        if not LuaObjEventContainer._LuaObjEvents then
          return
        end
        local PackLuaEvents = LuaObjEventContainer._LuaObjEvents[eventName]
        if not PackLuaEvents then
          return
        end
        PackLuaEvents[self] = nil
        controlListeners[eventName] = nil
      end
    end
  end
end
function UIBase:LuaBroadcast(eventName, ...)
  if self._LuaObjEventContainer and self._LuaObjEventContainer._LuaObjEvents then
    local PackLuaEvents = self._LuaObjEventContainer._LuaObjEvents[eventName]
    if not PackLuaEvents then
      return
    end
    for EventListener, args in pairs(PackLuaEvents) do
      common.CallCombinationArgs(args[1], args[2], ...)
    end
  end
end
function UIBase:AddTimer(delay, func)
  if not self._timesForUI then
    self._timesForUI = {}
  end
  local handle
  handle = time_ticker.AddTimer(delay, function(...)
    func(...)
    self._timesForUI[handle] = nil
  end)
  self._timesForUI[handle] = true
  return handle
end
function UIBase:AddTimerLoop(delay, func, count, timeInterval)
  if not self._timesForUI then
    self._timesForUI = {}
  end
  local handle
  handle = time_ticker.AddTimerLoop(delay, func, count, timeInterval)
  self._timesForUI[handle] = true
  return handle
end
function UIBase:AddTimerOnce(delay, func)
  if not self._timesForUI then
    self._timesForUI = {}
  end
  local handle
  handle = time_ticker.AddTimerOnce(delay, function(...)
    func(...)
    self._timesForUI[handle] = nil
  end)
  self._timesForUI[handle] = true
  return handle
end
function UIBase:RemoveTimer(handle)
  time_ticker.RemoveTimer(handle)
  if self._timesForUI and self._timesForUI[handle] then
    self._timesForUI[handle] = nil
  end
  return true
end
function UIBase:RemoveAllTimer()
  if not self._timesForUI then
    return
  end
  for handle, _ in pairs(self._timesForUI) do
    time_ticker.RemoveTimer(handle)
    self._timesForUI[handle] = nil
  end
end
function UIBase:AddGameTimer(nTime, bLoop, fCallback)
  if not self._gameTimers then
    self._gameTimers = {}
  end
  local nTimerID
  nTimerID = Game:SetTimer(nTime, bLoop, function(...)
    fCallback(...)
    if not bLoop then
      self._gameTimers[nTimerID] = nil
    end
  end)
  self._gameTimers[nTimerID] = true
  return nTimerID
end
function UIBase:RemoveGameTimer(nTimerID)
  Game:ClearTimer(nTimerID)
  if self._gameTimers and self._gameTimers[nTimerID] then
    self._gameTimers[nTimerID] = nil
  end
  return true
end
function UIBase:RemoveAllGameTimer()
  if not self._gameTimers then
    return
  end
  for index, _ in pairs(self._gameTimers) do
    Game:ClearTimer(index)
    self._gameTimers[index] = nil
  end
end
function UIBase:TryRemoveNamedGameTimer(Name, this)
  if this == nil then
    this = self
  end
  if this[Name] then
    self:RemoveGameTimer(this[Name])
    this[Name] = nil
  end
end
function UIBase:Show()
  self:SetVisibility(UEnums.ESlateVisibility.Visible)
end
function UIBase:Hide()
  self:SetVisibility(UEnums.ESlateVisibility.Hidden)
end
function UIBase:Collapsed()
  self:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UIBase:HitTestInvisible()
  self:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function UIBase:SelfHitTestInvisible()
  self:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function UIBase:GetVisibility()
  return self.UIRoot:GetVisibility()
end
function UIBase:SetVisibility(InVisibility)
  if self.UIRoot == nil then
    log_error("UIBase:SetVisibility Must load ui before call SetVisibility")
    return
  end
  self.UIRoot:SetVisibility(InVisibility)
  if self:IsAsyncLoading() then
    return
  end
  local ESlateVisibility = UEnums.ESlateVisibility
  local isShow = InVisibility == ESlateVisibility.Visible or InVisibility == ESlateVisibility.HitTestInvisible or InVisibility == ESlateVisibility.SelfHitTestInvisible
  self:_UpdateShow(isShow)
end
function UIBase:SetWidgetVisibility(InVisibility)
  return self:SetVisibility(InVisibility)
end
function UIBase:WidgetVisible(widget)
  widget:SetVisibility(UEnums.ESlateVisibility.Visible)
end
function UIBase:WidgetCollapse(widget)
  widget:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UIBase:WidgetHidden(widget)
  widget:SetVisibility(UEnums.ESlateVisibility.Hidden)
end
function UIBase:WidgetHitInv(widget)
  widget:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function UIBase:WidgetSelfHit(widget)
  widget:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function UIBase:_UpdateShow(isShow)
  if self._isShow ~= isShow then
    self._    if isShow then
      self:OnShow()
    else
      self:OnHide()
    end
  end
end
function UIBase:_UpdateIsShow()
  local ESlateVisibility = UEnums.ESlateVisibility
  local InVisibility = self:GetVisibility()
  local isShow = InVisibility == ESlateVisibility.Visible or InVisibility == ESlateVisibility.HitTestInvisible or InVisibility == ESlateVisibility.SelfHitTestInvisible
  self:_UpdateShow(isShow)
end
function UIBase:IsShow()
  return self._isShow
end
function UIBase:SetWidgetVisible(widget, visible, isButton)
  if not widget then
    log_error("UIBase:SetWidgetVisible widget is nil")
    return
  end
  if self.UIRoot == widget then
    log_error("UIBase:SetWidgetVisible Not allow set UIRoot's visibility")
    return
  end
  if visible then
    if isButton then
      widget:SetVisibility(UEnums.ESlateVisibility.Visible)
    else
      widget:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    widget:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UIBase:_CallSlotfunc(funcName, param)
  if not self.UIRoot then
    log_error("UIBase:_CallSlotfunc UIBase Must load ui before call funcName:" .. funcName)
    return
  end
  local Root = self.UIRoot
  if self:IsAsyncLoading() then
    Root[funcName](Root, "__Asy_Slot", param)
    return
  end
  local Slot = Root.Slot
  if not Slot then
    log_error("UIBase:_CallSlotfunc Slot = nil funcName:" .. funcName .. " UIRoot:" .. tostring(self.UIRoot))
    return
  end
  if not Slot[funcName] then
    return
  end
  return Slot[funcName](Slot, param)
end
function UIBase:SetAnchors(minX, minY, maxX, maxY)
  local anchors = FAnchors(minX, minY, maxX, maxY)
  self:_CallSlotfunc("SetAnchors", anchors)
end
function UIBase:SetAnchorsOne(anchors)
  self:_CallSlotfunc("SetAnchors", anchors)
end
function UIBase:SetOffsets(left, top, right, bottom)
  local margin = FMargin(left, top, right, bottom)
  self:_CallSlotfunc("SetOffsets", margin)
end
function UIBase:SetOffsetsOne(margin)
  self:_CallSlotfunc("SetOffsets", margin)
end
function UIBase:SetHorizontalAlignment(alignment)
  self:_CallSlotfunc("SetHorizontalAlignment", alignment)
end
function UIBase:SetAlignment(x, y)
  local pos = FVector2D(x, y)
  self:_CallSlotfunc("SetAlignment", pos)
end
function UIBase:SetPosition(left, top)
  local pos = FVector2D(left, top)
  self:_CallSlotfunc("SetPosition", pos)
end
function UIBase:SetSize(width, height)
  local size = FVector2D(width, height)
  self:_CallSlotfunc("SetSize", size)
end
function UIBase:SetZOrder(ZOrder)
  log(bWriteLog and "UIBase:SetZOrder. keyName: " .. tostring(self._config and self._config.keyName) .. ", ZOrder:" .. tostring(ZOrder))
  self:_CallSlotfunc("SetZOrder", ZOrder)
end
function UIBase:GetZOrder()
  return self:_CallSlotfunc("GetZOrder")
end
function UIBase:SetAutoSize(bAutoSize)
  self:_CallSlotfunc("SetAutoSize", bAutoSize)
end
function UIBase:SetWidgetPosition(widget, left, top)
  if not self.UIRoot then
    log_error("UIBase:SetWidgetPosition UIBase Must load ui before call SetWidgetPosition!")
    return
  end
  if widget.Slot and widget.Slot.SetPosition then
    local pos = FVector2D(left, top)
    widget.Slot:SetPosition(pos)
  else
    log_warning("UIBase:SetWidgetPosition failed! Because self.UIRoot.Slot.SetPosition is nil")
  end
end
function UIBase:SetWidgetAutoSize(widget, bAutoSize)
  if widget.Slot and widget.Slot.SetAutoSize then
    widget.Slot:SetAutoSize(bAutoSize)
  end
end
function UIBase:SetPadding(left, top, right, bottom)
  if not self.UIRoot then
    return
  end
  local padding = FMargin(left, top, right, bottom)
  self.UIRoot:SetPadding(padding)
end
function UIBase:ConvertToAnimationNameWithLOD(inAnimationName)
  return UIUtil.ConvertToAnimationNameWithLOD(self.UIRoot, inAnimationName)
end
function UIBase:PlayAnimation(inAnimationName, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  return self.UIRoot:PlayAnimation(self.UIRoot[inAnimationName], startAtTime, numLoopsToPlay, playMode, playbackSpeed)
end
function UIBase:PlayAnimationWithPromise(inAnimationName, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  local Promise = require("common.Promise")
  local promise = Promise.new()
  local animLevel = self:PlayAnimation(inAnimationName, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  if animLevel == -1 then
    promise:Reject("Animation not found or failed to play")
    return promise
  end
  if numLoopsToPlay == 0 then
    promise:Reject("Animation loop count is 0")
    return promise
  end
  self:AddOnAnimationFinishedEvent(inAnimationName, function()
    self:RemoveOnAnimationFinishedEvent(inAnimationName)
    promise:Resolve(animLevel)
  end)
  return self:AddPromise(promise)
end
function UIBase:PlayUserWidgetAnimation(widgetAnimation, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  return self.UIRoot:PlayAnimation(widgetAnimation, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
end
function UIBase:PlayWidgetAnimation(widget, widgetAnimation, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  if not slua_isValid(widget) then
    log(bWriteLog and "UIBase:PlayWidgetAnimation Widget is not valid")
    return -1
  end
  widget:PlayAnimation(widgetAnimation, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
end
function UIBase:StopWidgetAnimation(widget, inAnimationName)
  return UIUtil.StopWidgetAnimation(widget, inAnimationName)
end
function UIBase:IsAnimationPlaying(inAnimationName)
  return UIUtil.IsWidgetAnimationPlaying(self.UIRoot, inAnimationName)
end
function UIBase:StopAnimation(inAnimationName)
  return UIUtil.StopWidgetAnimation(self.UIRoot, inAnimationName)
end
function UIBase:GetAnimationDuration(inAnimationName)
  return UIUtil.GetAnimationDuration(self.UIRoot, inAnimationName)
end
function UIBase:SetTexture(widget, path, params)
  if not path or path == "" then
    if widget then
      widget:SetBrushFromTexture(nil, false)
      return SetTextureConst.Done
    else
      return SetTextureConst.Error
    end
  end
  params = params or {}
  if params.bIsInCombatState == nil then
    params.bIsInCombatState = self.bIsInCombatState
  end
  if util.IsOnlineImageUrl(path) then
    return self:_DownloadImageWithCDN(widget, path, params)
  elseif string.find(path, "/Saved/") then
    return self:_SetTextureFromDiskFile(widget, path, params)
  else
    return util.SetTexture(widget, path, params)
  end
end
function UIBase:_DownloadImageWithCDN(widget, path, params)
  if not path or path == "" then
    log_error("UIBase:_DownloadImageWithCDN SetTexturePreCheck can't access!")
    return SetTextureConst.Error
  end
  if not util.IsOnlineImageUrl(path) then
    log_error("UIBase:_DownloadImageWithCDN imgUrl is not OnlineImageUrl : " .. path)
    return SetTextureConst.Error
  end
  if not self._downloadImageMgrData then
    self._downloadImageMgrData = {}
  end
  params = params or {}
  if base_config_util.EnableCDNCompress(self._config) then
    params.enableCDNCompress = true
  end
  if params.needLocalize then
    path = util.GetUrlByLanguage(path)
  end
  params.ifAddRef = params.ifAddRef or false
  params.tryTimes = params.tryTimes or 1
  params.isForceUpdate = params.isForceUpdate or false
  params.bNotAutoApplyWiget = params.bNotAutoApplyWiget or false
  local OnDownloadSuccess = function(texture, url)
    if not params.bNotAutoApplyWiget and slua_isValid(widget) then
      widget:SetBrushFromTexture(texture, params.bMatchSize or false)
    end
    if params.onDownloadSuccess then
      params.onDownloadSuccess(texture, url)
    end
  end
  local OnDownloadFail = function(url)
    if params.onDownloadFail then
      params.onDownloadFail(url)
    end
  end
  local image_download_mgr = ModuleManager_GetModule(CommonModuleConfig.image_download_mgr)
  return image_download_mgr:DownloadImageForBase(path, self._downloadImageMgrData, OnDownloadSuccess, OnDownloadFail, params)
end
function UIBase:CancelImageDownloadByIndex(downloadIndex)
  if not downloadIndex or downloadIndex <= 0 then
    log(bWriteLog and "UIBase:CancelImageDownloadByIndex downloadIndex is invalid")
    return
  end
  local image_download_mgr = ModuleManager_GetModule(CommonModuleConfig.image_download_mgr)
  image_download_mgr:CancelDownloadByIndex(downloadIndex)
end
function UIBase:_SetTextureFromDiskFile(widget, path, params)
  if not path or path == "" then
    log_warning("UIBase:_SetTextureFromDiskFile path is " .. tostring(path))
    if widget then
      widget:SetBrushFromTexture(nil, false)
      return SetTextureConst.Done
    else
      return SetTextureConst.Error
    end
  end
  params = params or {}
  local bMatchSize = params.bMatchSize or false
  if params.sync == false then
    if not self._asyncLoadDiskFile then
      self._asyncLoadDiskFile = {}
    end
    if self._asyncLoadDiskFile[widget] then
      local handleId = self._asyncLoadDiskFile[widget]
      self._asyncLoadDiskFile[widget] = nil
      asset_util.CancelSavedTextureAsync(handleId - image_download_config.DiskStartIndex)
    end
    local enableCDNCompress = params.enableCDNCompress or false
    local handleID = asset_util.GetSavedTextureAsync(path, enableCDNCompress, function(texture)
      if texture then
        widget:SetBrushFromTexture(texture, bMatchSize or false)
        if params.onDownloadSuccess then
          params.onDownloadSuccess(texture, path)
        end
      elseif params.onDownloadFail then
        params.onDownloadFail(path)
      end
    end)
    if not handleID or handleID == 0 then
      return SetTextureConst.Error
    end
    handleID = handleID + image_download_config.DiskStartIndex
    self._asyncLoadDiskFile[widget] = handleID
    return handleID
  else
    local texture = asset_util.GetSavedTextureSync(path)
    widget:SetBrushFromTexture(texture, bMatchSize or false)
    if texture then
      if params.onDownloadSuccess then
        params.onDownloadSuccess(texture, path)
      end
      return SetTextureConst.Done
    else
      if params.onDownloadFail then
        params.onDownloadFail(path)
      end
      return SetTextureConst.Error
    end
  end
end
function UIBase:_RemoveImageDownloadData()
  if not self._downloadImageMgrData or not next(self._downloadImageMgrData) then
    return
  end
  local image_download_mgr = ModuleManager_GetModule(CommonModuleConfig.image_download_mgr)
  image_download_mgr:RemoveImageDownloadDataForBase(self._downloadImageMgrData)
  self._downloadImageMgrData = nil
end
function UIBase:_RemoveAllAsyncDiskFile()
  if not self._asyncLoadDiskFile then
    return
  end
  for widget, handleId in pairs(self._asyncLoadDiskFile) do
    asset_util.CancelSavedTextureAsync(handleId - image_download_config.DiskStartIndex)
  end
  self._asyncLoadDiskFile = nil
end
function UIBase:GetAssetAsync(path, callback, ...)
  if not path or path == "" then
    log_error("UIBase:GetAssetAsync path empty")
    return
  end
  if not self._loadedDelegates then
    self._loadedDelegates = {}
  end
  local args = table_pack(...)
  local HandleID = asset_util.loadFromCacheHandleID
  HandleID = asset_util.GetAssetAsync(path, function(LoadObject)
    self._loadedDelegates[HandleID] = nil
    common.CallCombinationArgs(callback, args, LoadObject)
  end)
  if HandleID ~= asset_util.loadFromCacheHandleID then
    self._loadedDelegates[HandleID] = true
    return HandleID
  end
  return nil
end
function UIBase:GetAssetListAsync(PathList, callback, ...)
  if not PathList or #PathList <= 0 then
    callback()
    return
  end
  local iTotalNum = #PathList
  local iCallBackNum = 0
  local AssetList = {}
  for _, v in pairs(PathList) do
    self:GetAssetAsync(v, function(uAsset)
      iCallBackNum = iCallBackNum + 1
      table.insert(AssetList, uAsset)
      if iCallBackNum >= iTotalNum then
        callback(AssetList)
      end
    end)
  end
end
function UIBase:CancelAssetAsync(HandleID)
  if not self._loadedDelegates then
    return
  end
  if not self._loadedDelegates[HandleID] then
    return
  end
  asset_util.CancelAssetAsync(HandleID)
  self._loadedDelegates[HandleID] = nil
end
function UIBase:_RemoveLoadedDelegates()
  if not self._loadedDelegates then
    return
  end
  for v, _ in pairs(self._loadedDelegates) do
    asset_util.CancelAssetAsync(v)
  end
  self._loadedDelegates = nil
end
function UIBase:_AddDetectOrRemoveWhiteList(bAdd)
  if self._config and self._config.closeOnSwitch == false then
    local logic_leak_check_UI = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check_UI")
    if logic_leak_check_UI then
      if bAdd then
        logic_leak_check_UI.AddToDetectWhiteList(self)
      else
        logic_leak_check_UI.RemoveFromDetectWhiteList(self)
      end
    end
  end
end
function UIBase:_HandleJumpBack(uiData)
  if self:IsAsyncLoading() then
    self._AsyncJumpBackData = {needJumpBack = true, uiData = uiData}
  else
    self:JumpBack(uiData)
    if uiData and uiData._FrameSubUIList then
      ui_show_manager.HandleJumpBackSubUI(uiData._FrameSubUIList)
    end
  end
end
function UIBase:JumpBack(uiData)
end
function UIBase:GetDataForJumpBack()
  return nil
end
function UIBase:_AsyncJumpBack()
  local data = self._AsyncJumpBackData
  if data ~= nil then
    self._AsyncJumpBackData = nil
    if data.needJumpBack then
      self:JumpBack(data.uiData)
      if data.uiData and data.uiData._FrameSubUIList then
        ui_show_manager.HandleJumpBackSubUI(data.uiData._FrameSubUIList)
      end
    end
  end
end
function UIBase:AddClock(endTime, updateFunc, endFunc)
  if not self._clocks then
    self._clocks = {}
  end
  local handleID
  handleID = clock.Init(endTime, updateFunc, function()
    if endFunc then
      endFunc()
    end
    self._clocks[handleID] = nil
  end)
  self._clocks[handleID] = true
  return handleID
end
function UIBase:RemoveClock(handleID)
  clock.Release(handleID)
  if self._clocks and self._clocks[handleID] then
    self._clocks[handleID] = nil
  end
  return true
end
function UIBase:RemoveAllClock()
  if not self._clocks then
    return
  end
  for handleID, _ in pairs(self._clocks) do
    clock.Release(handleID)
    self._clocks[handleID] = nil
  end
end
function UIBase:PlayAudio(audioPath, bAsync, bAutoStopOnClose)
  if not audioPath or audioPath == "" then
    log_error("UIBase:PlayAudio audioPath invalid")
    return
  end
  if not slua_isValid(self.UIRoot) then
    log_error("UIBase:PlayAudio UIRoot invalid")
    return
  end
  if bAsync then
    local AudioAsyncHandle = audio_util.PlayAudioAsync(audioPath, self.UIRoot)
    if bAutoStopOnClose and AudioAsyncHandle then
      if not self._AudioAsyncHandleTable then
        self._AudioAsyncHandleTable = {}
      end
      self._AudioAsyncHandleTable[AudioAsyncHandle] = true
    end
  else
    self:_PlayAudioInner(audioPath, bAutoStopOnClose)
  end
end
function UIBase:_PlayAudioInner(audioPath, bAutoStopOnClose)
  if type(audioPath) == "string" then
    local AudioID = audio_util.PlayAudio(audioPath, self.UIRoot)
    if bAutoStopOnClose and AudioID then
      if not self._AudioListTable then
        self._AudioListTable = {}
      end
      self._AudioListTable[AudioID] = true
    end
  elseif type(audioPath) == "number" then
    log_error("UIBase:_PlayAudioInner interface has been deprecated, please use the UIBase:PlayMusic interface. audioPath:" .. audioPath)
    self:PlayMusic(audioPath)
  end
end
function UIBase:PlayMusic(sound_id, disableMusicPlayer)
  local audio_manager = ModuleManager_GetModule(LobbyModuleConfig.audio_manager)
  if not self._playList then
    self._playList = {}
  end
  self._playList[sound_id] = audio_manager:Start(sound_id, disableMusicPlayer)
end
function UIBase:StopMusic(sound_id)
  if not self._playList then
    log_error("UIBase:StopMusic _playList == nil id:" .. sound_id)
    return
  end
  if not self._playList[sound_id] then
    log_error("UIBase:StopMusic _playList not find id:" .. sound_id)
    return
  end
  local audio_manager = ModuleManager_GetModule(LobbyModuleConfig.audio_manager)
  audio_manager:Stop(sound_id)
  self._playList[sound_id] = nil
end
function UIBase:PauseMusic(sound_id)
  if not self._playList then
    log_error("UIBase:PauseMusic _playList == nil id:" .. sound_id)
    return
  end
  if not self._playList[sound_id] then
    log_error("UIBase:PauseMusic _playList not find id:" .. sound_id)
    return
  end
  local audio_manager = ModuleManager_GetModule(LobbyModuleConfig.audio_manager)
  audio_manager:Pause(sound_id)
end
function UIBase:ResumeMusic(sound_id)
  if not self._playList then
    log_error("UIBase:ResumeMusic _playList == nil id:" .. sound_id)
    return
  end
  if not self._playList[sound_id] then
    log_error("UIBase:ResumeMusic _playList not find id:" .. sound_id)
    log_error("UIBase:ResumeMusic _playList not find id:" .. sound_id)
    return
  end
  local audio_manager = ModuleManager_GetModule(LobbyModuleConfig.audio_manager)
  audio_manager:Resume(sound_id)
end
function UIBase:RemoveAllMusic()
  if not self._playList then
    return
  end
  local audio_manager = ModuleManager_GetModule(LobbyModuleConfig.audio_manager)
  for id, _ in pairs(self._playList) do
    local instance_type = audio_manager:Stop(id)
    audio_manager:Release(id)
    if instance_type == UEnums.LobbyAudioType.Music then
      self:RestoreMusic()
    end
  end
  self._playList = nil
end
function UIBase:RestoreMusic()
  local audio_manager = ModuleManager_GetModule(LobbyModuleConfig.audio_manager)
  audio_manager:EnableMusicPlayer()
end
function UIBase:_UnregistAllReddot()
  local logic_reddot_limitation = ModuleManager_GetModule(LobbyModuleConfig.logic_reddot_limitation)
  logic_reddot_limitation:UnregistReddotWidget(self)
end
function UIBase:RegistReddotWidget(reddotWidget, extra)
  local logic_reddot_limitation = ModuleManager_GetModule(LobbyModuleConfig.logic_reddot_limitation)
  logic_reddot_limitation:RegistReddotWidget(self, reddotWidget, extra)
end
function UIBase:UnregistReddotWidget(reddotWidget)
  local logic_reddot_limitation = ModuleManager_GetModule(LobbyModuleConfig.logic_reddot_limitation)
  logic_reddot_limitation:UnregistReddotWidget(self, reddotWidget)
end
function UIBase:ToggleReddotActivation(reddotWidget, bShouldActivate)
  local logic_reddot_limitation = ModuleManager_GetModule(LobbyModuleConfig.logic_reddot_limitation)
  logic_reddot_limitation:ToggleReddotActivation(reddotWidget, bShouldActivate)
end
function UIBase:InvalidateLayoutCache(Times, Delay)
  Times = Times or 1
  Delay = Delay or 0
  local time_ticker = require("common.time_ticker")
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local SlateLayoutCacheStatus = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("slate.EnableLayoutCaching")
  if InvalidatingLayoutCache then
    return
  end
  InvalidatingLayoutCache = true
  self:AddTimer(Delay, function()
    local ClientEvoConfig = require("client.logic.client_evo_config.client_evo_config")
    ClientEvoConfig.ToggleSlateLayoutCache(false)
    coroutine.yield(time_ticker.NEXT_FRAME)
    log(bWriteLog and "UIBase:InvalidateLayoutCache InvalidateLayoutCache")
    coroutine.yield(time_ticker.NEXT_FRAME)
    ClientEvoConfig.ToggleSlateLayoutCache(SlateLayoutCacheStatus == 1)
    log(bWriteLog and "UIBase:InvalidateLayoutCache RestoreLayoutCache")
    InvalidatingLayoutCache = false
  end)
end
function UIBase:IsValid()
  return not self._IsClosed
end
function UIBase:AddPromise(p)
  if not self._promiseMap then
    self._promiseMap = {}
  end
  self._promiseMap[p] = true
  p:Then(function(...)
    self._promiseMap[p] = nil
  end):Catch(function(err)
    self._promiseMap[p] = nil
  end)
  return p
end
function UIBase:GetClassName()
  if not self._className and self._config ~= nil then
    self._className = self:_GetKeyName(self._config)
  end
  return self._className or ""
end
function UIBase:ShowLogByClassName(logStr, logLevel)
  if not bWriteLog then
    return
  end
  UIUtil.ShowLogByOtherName(self:GetClassName(), logStr, logLevel)
end
function UIBase:_SetUIRoot(uiRoot)
  self.UIRoot = uiRoot
  if not uiRoot then
    self.WrapRoot = nil
    return
  end
  if type(uiRoot) == "table" then
    self.WrapRoot = nil
    return
  end
  if not slua_isValid(uiRoot) then
    xpcallHandle("UIBase:_SetUIRoot uiRoot is invalid")
    self.WrapRoot = nil
    return
  end
  local wrapper = {}
  local newIndex = function(t, key)
    if not self.UIRoot then
      log_error("UIBase:_SetUIRoot uiRoot is nil")
      return nil
    end
    if self.UIRoot[key] then
      return self.UIRoot[key]
    end
    if not self.UIRoot.GetOrCreateLazyChild then
      return nil
    end
    return self.UIRoot:GetOrCreateLazyChild(key)
  end
  setmetatable(wrapper, {__index = newIndex})
  self.WrapRoot = wrapper
end
function UIBase:_GetUIRootProxy()
  return self._UIRootProxy
end
function UIBase:_CanUsePool()
  local pool_util = require("client.slua_ui_framework.pool.pool_util")
  if self._loadFromPool > EUIConfigPoolType.None and pool_util.CanUseUIPool() then
    return true
  end
  return false
end
function UIBase:CheckCanSwitchPos()
  if not self.UIRoot or not slua_isValid(self.UIRoot) then
    return false
  end
  local switchPosWidget = self:GetSwitchPosWidget()
  if not switchPosWidget or not slua.isValid(switchPosWidget) then
    return false
  end
  return true
end
function UIBase:AutoSwitchPosInLobbyOrMainCity()
  if not self:CheckCanSwitchPos() then
    return
  end
  self:SwitchPosInLobbyOrMainCity()
end
function UIBase:SwitchPosInLobbyOrMainCity()
  if not self:CheckCanSwitchPos() then
    return
  end
  local switchPosWidget = self:GetSwitchPosWidget()
  local switchPosOffset = self:GetSwitchPosOffset()
  if not self.UIRoot or not slua_isValid(self.UIRoot) then
    return
  end
  local ui_right_bottom_util = require("client.common.ui_right_bottom_util")
  ui_right_bottom_util.SetPosYByLobbyOrMainCity(switchPosWidget, self.UIRoot.LobbyPosY, self.UIRoot.MainCityPosY, switchPosOffset)
end
function UIBase:_ResetSwitchPosWidgetPosition()
  if not self:CheckCanSwitchPos() then
    return
  end
  local switchPosWidget = self:GetSwitchPosWidget()
  if not self.UIRoot or not slua_isValid(self.UIRoot) then
    return
  end
  local ui_right_bottom_util = require("client.common.ui_right_bottom_util")
  ui_right_bottom_util.ResetChangePosWidgetPosition(switchPosWidget, self.UIRoot.LobbyPosY, self.UIRoot.MainCityPosY)
end
local class = require("class")
local object = require("object")
local CUIBase = class(object, nil, UIBase)
return CUIBase