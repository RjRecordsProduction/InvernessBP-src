UIManager = {}
local UI_Config = require("client.slua.config.base_config")
UIManager.UIManager.UI_Config_InGame = {}
UIManager.Optimized_Page_Count = 0
UIManager.iTCDeviceLevel = -1
UIManager.iDisableAsyHighDeviceLevel = 0
local ESlateVisibility = UEnums.ESlateVisibility
local Collapsed = ESlateVisibility.Collapsed
local SelfHitTestInvisible = ESlateVisibility.SelfHitTestInvisible
local DefaultShowVisibility = SelfHitTestInvisible
local DefaultHideVisibility = Collapsed
local UI_Instances = {}
local MAX_HIDDEN_COUNT = 0
local UI_HiddenInstances = {}
local AutoCreateUITable = {}
local LoadSceneMap = {}
local bClearing
local local local table_remove = table.remove
local table_pack = table.pack
local local local local local local local local Client_AddCrashContextData = Client.AddCrashContextData
local local utility = require("common.utility")
local LuaAsyncTaskSubsystem
if GbUIClearAlgorithm then
  LuaAsyncTaskSubsystem = utility.GetGameInstanceSubsystemByName("LuaAsyncTasksSubsystem")
else
  LuaAsyncTaskSubsystem = utility.GetGameInstanceSubsystemByName("LuaAsyncTaskSubsystem")
end
local local local local xpcallHandle = utility.ErrorMessageHandler
local base_config_util = require("client.common.uibase.base_config_util")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferConst = require("client.slua.logic.download.puffer_const")
local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
local ui_depth_manager = require("client.common.uibase.ui_depth_manager")
local ui_scene_component = require("client.slua.logic.lobby_camera.ui_scene_component")
local ModuleManager_GetModule = ModuleManager.GetModule
local CommonModuleConfig = ModuleManager.CommonModuleConfig
local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
local gc_util = require("common.gc_util")
local asy_ui_config = require("client.slua.config.asy_ui_config")
local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
local slua_isValid = slua.isValid
local string_format = string.format
local local FindHiddenUIByName = function(keyName)
  for i, v in pairs(UI_HiddenInstances) do
    if v == keyName then
      return i
    end
  end
end
local CheckAndRemoveHiddenUI = function()
  if #UI_HiddenInstances > MAX_HIDDEN_COUNT then
    for index = 1, #UI_HiddenInstances do
      local config = UIManager.GetConfigByKey(UI_HiddenInstances[index])
      if config and (config.bPermanentDuringThisBattle == nil or config.bPermanentDuringThisBattle == false) then
        table_remove(UI_HiddenInstances, index)
        UIManager.CloseUI(config)
        break
      end
    end
  end
  if 0 < #UI_HiddenInstances then
    local ClearHandle = function(bNeedClear)
      if bNeedClear then
        local tPermentCacheTable = {}
        for index = 1, #UI_HiddenInstances do
          local config = UIManager.GetConfigByKey(UI_HiddenInstances[index])
          if config then
            if config.bPermanentDuringThisBattle then
              tPermentCacheTable[#tPermentCacheTable + 1] = UI_HiddenInstances[index]
            else
              UIManager.CloseUI(config)
            end
          end
        end
        UI_HiddenInstances = tPermentCacheTable
      end
    end
    if GbUIClearAlgorithm then
      LuaAsyncTaskSubsystem:IsNeedClear(GnMaxClearMemory, GnMaxClearObjectNum, ClearHandle)
    else
      LuaAsyncTaskSubsystem:IsNeedClear(slua_GameFrontendHUD, ClearHandle)
    end
  end
end
local CheckToUseBatchOptimization = function(keyName, bOpen)
  if ForceControlBatchOptimization then
    return
  end
  local config = UIManager.GetConfigByKey(keyName)
  if config and config.useBatchOptimization then
    local STExtraGameInstance = import("STExtraGameInstance")
    local gameInstance = STExtraGameInstance.GetInstance()
    if bOpen then
      if UIManager.Optimized_Page_Count == 0 then
      end
      UIManager.Optimized_Page_Count = UIManager.Optimized_Page_Count + 1
    else
      UIManager.Optimized_Page_Count = UIManager.Optimized_Page_Count - 1
      if UIManager.Optimized_Page_Count <= 0 then
        gameInstance:ExecuteCMD("Slate.EnableTuneElements", 0)
      end
    end
  end
end
local OnUIShowCheckHideUI = function(keyName)
  local index = FindHiddenUIByName(keyName)
  if index then
    table_remove(UI_HiddenInstances, index)
  end
  CheckAndRemoveHiddenUI()
end
local GetStatUIInfo = function(config)
  local bBeforeLogin = GameStatus.GetGameStatus() == GameStatus.None or GameStatus.GetGameStatus() == GameStatus.Login
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  local bStatUI = not bBeforeLogin and not ToolReportUtil:IsReleaseVersion() and not GameStatus.IsInFightingStatus()
  local uiStatName = config.keyName
  if bStatUI and config.uiStat then
    uiStatName = config.uiStat.name
  end
  return {bStatUI = bStatUI, uiStatName = uiStatName}
end
function UIManager.ShowUI(config, ...)
  if ui_show_queue_manager.CheckCanUseQueue(config, ...) then
    return ui_show_queue_manager.AddOneUI(config, ...)
  end
  return UIManager.DirectShowUI(config, ...)
end
function UIManager.DirectShowUI(config, ...)
  return UIManager._ShowUI(nil, nil, config, nil, nil, ...)
end
function UIManager.ShowUIWithBpPath(config, bpPath, ...)
  return UIManager._ShowUI(nil, nil, config, nil, bpPath, ...)
end
function UIManager.ShowUIWithLuaAndBpPath(config, moduleName, bpPath, ...)
  return UIManager._ShowUI(nil, nil, config, moduleName, bpPath, ...)
end
function UIManager.ShowMountUI(parentUIBase, panel, config, ...)
  return UIManager._ShowUI(parentUIBase, panel, config, nil, nil, ...)
end
function UIManager.ShowMountUIWithBpPath(parentUIBase, panel, config, bpPath, ...)
  return UIManager._ShowUI(parentUIBase, panel, config, nil, bpPath, ...)
end
function UIManager.ShowMountUIWithLuaAndBpPath(parentUIBase, panel, config, moduleName, bpPath, ...)
  return UIManager._ShowUI(parentUIBase, panel, config, moduleName, bpPath, ...)
end
function UIManager.HideUI(config)
  if not assert(config ~= nil, "UIManager.HideUI config should not be nil") then
    return
  end
  log(bWriteLog and "UIManager.HideUI keyName:" .. config.keyName)
  local ui = UI_Instances[config.keyName]
  if ui then
    if base_config_util.IsCloseOnHide(config) then
      UIManager.CloseUI(config)
    else
      ui:SetVisibility(DefaultHideVisibility)
      UIManager._OnUIHide(config)
    end
  end
end
function UIManager.CloseUI(config, queueParamTable)
  if not assert(config ~= nil, "UIManager.CloseUI config should not be nil") then
    return
  end
  if ui_jump_manager.IsInit() then
    if config.jumpModuleID then
      ui_jump_manager.OnModuleClose(config)
      return
    end
    if config.handleJumpEvent and base_config_util.IsSingleton(config) then
      ui_jump_manager.OnSubUIClose(config)
    end
  end
  UIManager._ProcessCloseUI(config, queueParamTable)
end
function UIManager._PreCreateSingletonUI(config)
  return UIManager._OnUIShowForNavigationManager(config)
end
function UIManager._PostCreateSingletonUI(config)
  UIManager._OnUIShow(config)
  return OnUIShowCheckHideUI(config.keyName)
end
function UIManager._PreCreateUICheck(config, bpPath)
  local uPC = slua_GameFrontendHUD:GetPlayerController()
  local bIsOB = GameStatus.IsInFightingStatus() and slua_isValid(uPC) and uPC.IsObserver and uPC:IsObserver()
  if config.isWindowsOBHide and (GetWindowOBState() or bIsOB) then
    log(bWriteLog and "UIManager._PreCreateUICheck in Windows OB: " .. config.keyName)
    return false
  end
  if config.isCEHideLobbyUI and GetCEHideLobbyUI() then
    log(bWriteLog and "UIManager._PreCreateUICheck in CE: " .. config.keyName)
    return false
  end
  if config.limitScene == GameStatus.Lobby then
    if GameStatus.IsInLobbyOrMainCity() then
      return true
    else
      return false
    end
  elseif config.limitScene and config.limitScene ~= GameStatus.GetGameStatus() then
    log(bWriteLog and "UIManager._PreCreateUICheck invalid scene = " .. config.limitScene)
    return false
  end
  if UIManager._ShowTXmissionTips(config) then
    return false
  end
  local bCheck = GameStatus.IsInLobbyOrSpecialFighting()
  if bCheck and UIManager._ShowUIDownloadTips(config, bpPath) then
    return false
  end
  return true
end
function UIManager._ShowTXmissionTips(config)
  if config and config.jumpModuleID then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() and LogicTxMissionMain.IsForbiddenUI(config.jumpModuleID) then
      ShowNotice(33631)
      return true
    end
  end
  return false
end
function UIManager._ShowUIDownloadTips(config, bpPath)
  local path = bpPath or config.path
  local pakName = PufferManager.GetPakName(path)
  if pakName == "" then
    return false
  end
  if config.ODPackID and PufferManager.CheckAndDownload(PufferConst.ENUM_DownloadType.ODPACK, {
    config.ODPackID
  }) then
    log(bWriteLog and string_format("UIManager._ShowUIDownloadTips ODPackID:%s", config.ODPackID))
    return true
  end
  if PufferManager.CheckAndDownload(PufferConst.ENUM_DownloadType.ODPAK, {path}) then
    log(bWriteLog and string_format("UIManager._ShowUIDownloadTips path:%s", path))
    return true
  end
  return false
end
function UIManager._OnUIShow(config)
  if not config then
    log_error(bWriteLog and "UIManager.OnUIShow config is nil")
    return
  end
  return CheckToUseBatchOptimization(config.keyName, true)
end
function UIManager._OnUIHide(config)
  UIManager._OnUIHideforDepthManager(config)
  UIManager._OnUIHideforNavigationManager(config)
  CheckToUseBatchOptimization(config.keyName, false)
  EventSystem:postEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, config.keyName)
  if UI_Instances[config.keyName] and not FindHiddenUIByName(config.keyName) then
    UI_HiddenInstances[#UI_HiddenInstances + 1] = config.keyName
  end
end
function UIManager._ShowUI(parentUIBase, panel, config, moduleName, bpPath, ...)
  if not assert(config ~= nil, "UIManager._ShowUI config should not be nil") then
    return nil
  end
  Client_AddCrashContextData(8, base_config_util.GetKeyName(config), false, 100)
  local canCreateUI = UIManager._PreCreateUICheck(config, bpPath)
  if not canCreateUI then
    return nil
  end
  if MainCity_GamePlay_Tools.GetCurrState() ~= main_city_config.ESceneType.Fighting and ui_jump_manager.IsInit() then
    if config.jumpModuleID then
      return ui_jump_manager.OnModuleOpen(config, table_pack(...))
    end
    if config.handleJumpEvent and base_config_util.IsSingleton(config) then
      ui_jump_manager.OnSubUIOpen(config)
    end
  end
  return UIManager._ProcessShowUI(parentUIBase, panel, config, moduleName, bpPath, ...)
end
function UIManager._ProcessShowUI(parentUIBase, panel, config, moduleName, bpPath, ...)
  local IsSingleton = base_config_util.IsSingleton(config)
  if bClearing and IsSingleton then
    log_error(string_format("UIManager._ProcessShowUI bClearing keyName[%s]!", config.keyName))
    return nil
  end
  if not assert(config ~= nil, "UIManager._ProcessShowUI config should not be nil") then
    return nil
  end
  if MainCity_GamePlay_Tools.GetCurrState() ~= main_city_config.ESceneType.Fighting then
    if config and asy_ui_config.UIConfig and asy_ui_config.UIConfig[config] then
      FuncUtil.OpenFlushAsyncLoading(true, asy_ui_config.GetTickFrame())
    end
    UIManager._ShowScene(config)
  end
  local statUIInfo = GetStatUIInfo(config)
  if statUIInfo and statUIInfo.bStatUI and statUIInfo.uiStatName then
    local BusinessHelper = import("BusinessHelper")
    BusinessHelper.StartUIStat(statUIInfo.uiStatName)
  end
  moduleName = moduleName or config.moduleName
  local ui
  if IsSingleton then
    ui = UI_Instances[config.keyName]
    if not ui then
      local UIClass = require(moduleName)
      if not assert_format(type(UIClass) == "table", "Module[%s] must be a class type! ", moduleName) then
        return nil
      end
      ui = UIClass(...)
      UI_Instances[config.keyName] = ui
      UIManager._PreCreateSingletonUI(config)
      ui:InitByConfigWithBpPath(parentUIBase, panel, config, bpPath)
      if ui:IsAsyncLoading() then
        UIManager._OnUIShowforDepthManager(config, nil)
      end
    else
      UIManager._PreCreateSingletonUI(config)
      UIManager._OnUIShowforDepthManager(config, ui)
      ui:OnConstruct(...)
    end
    UIManager._PostCreateSingletonUI(config)
  else
    local UIClass = require(moduleName)
    if not assert_format(type(UIClass) == "table", "Module[%s] must be a class type! ", moduleName) then
      return nil
    end
    ui = UIClass(...)
    ui:InitByConfigWithBpPath(parentUIBase, panel, config, bpPath)
  end
  ui:PostShowUI(config.showVisibility or DefaultShowVisibility, statUIInfo)
  return ui
end
function UIManager._ProcessCloseUI(config, queueParamTable)
  if not assert(config ~= nil, "UIManager._ProcessCloseUI config should not be nil") then
    return
  end
  Client_AddCrashContextData(9, config.keyName, false, 100)
  if config and asy_ui_config.UIConfig and asy_ui_config.UIConfig[config] then
    FuncUtil.OpenFlushAsyncLoading(false)
  end
  UIManager._CloseScene(config)
  local ui = UI_Instances[config.keyName]
  if ui then
    xpcall(function()
      ui:Close()
    end, xpcallHandle)
    UI_Instances[config.keyName] = nil
    UIManager._OnUIHide(config)
    local index = FindHiddenUIByName(config.keyName)
    if index then
      table_remove(UI_HiddenInstances, index)
    end
    UIManager.GCByMaxObject(config)
  end
  ui_show_queue_manager.OnUIClose(config, queueParamTable)
end
function UIManager.GetUI(config)
  if not assert(config ~= nil, "UIManager.GetUI config should not be nil") then
    return
  end
  return UI_Instances[config.keyName]
end
function UIManager.IsUIShow(config)
  local ui = UIManager.GetUI(config)
  if ui then
    return ui:IsShow()
  end
  return false
end
function UIManager.GetUIInstances()
  return UI_Instances
end
function UIManager.GetConfigByKey(keyName)
  if UIManager.UI_Config[keyName] then
    return UIManager.UI_Config[keyName]
  else
    return nil
  end
end
function UIManager.InitUITypeMap()
  UIManager._ProcessConfig(UIManager.UI_Config)
end
function UIManager.InitConfigInGame(configs)
  UIManager.UnInitConfigInGame()
  UIManager.UI_Config_InGame = configs
  UIManager._ProcessConfig(UIManager.UI_Config_InGame)
end
function UIManager.UnInitConfigInGame()
  AutoCreateUITable = {}
end
function UIManager.InitExtraUITypeMap(configs)
  UIManager._ProcessConfig(configs)
end
function UIManager._ProcessConfig(configs)
  for keyName, config in pairs(configs) do
    config.    UI_Config[keyName] = config
    ui_depth_manager.RegisterUI(keyName)
    if true == config.autoCreate then
      AutoCreateUITable[keyName] = true
    end
  end
end
function UIManager.ProcessOneConfig(keyName, config)
  if config == nil then
    return
  end
  config.  UI_Config[keyName] = config
  ui_depth_manager.RegisterUI(keyName)
  if true == config.autoCreate then
    AutoCreateUITable[keyName] = true
  end
end
function UIManager.ShowAutoCreateUI()
  for UIName, _ in pairs(AutoCreateUITable) do
    if UIManager.UI_Config_InGame[UIName] then
      UIManager.ShowUI(UIManager.UI_Config_InGame[UIName])
    end
  end
end
function UIManager._ShowScene(config)
  if config and config.sceneID and tonumber(config.sceneID) > 0 then
    log(bWriteLog and "UIManager._ShowScene keyName:" .. tostring(config.keyName))
    local SceneComponent = ui_scene_component()
    LoadSceneMap[config.sceneID] = SceneComponent
    SceneComponent:SwitchScene(config.sceneID)
  end
end
function UIManager._CloseScene(config)
  if config and config.sceneID and tonumber(config.sceneID) > 0 then
    log(bWriteLog and "UIManager._CloseScene keyName:" .. tostring(config.keyName))
    local LoadScene = LoadSceneMap[config.sceneID]
    if LoadScene then
      LoadScene:ExitCurrentScene()
      LoadScene:Destroy()
      LoadScene = nil
      LoadSceneMap[config.sceneID] = nil
    end
  end
end
local OnWidgetShow = function(className)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  if ui_navigation_manager:DontNeedPush(className, ui_navigation_manager.EnumStyleType.OldUI) then
    return
  end
  ui_navigation_manager:UIPushOn(className, ui_navigation_manager.EnumStyleType.OldUI)
  CheckAndRemoveHiddenUI()
end
local OnWidgetHide = function(className)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:UIPop(className)
  if GameStatus.IsInFightingStatus() then
    return
  end
  EventSystem:postEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, className)
end
function UIManager._OldUIInit()
  local UAEUserWidget = import("/Script/UnrealArchExt.UAEUserWidget")
  local OnWidgetShowDelegate = slua.createDelegate(OnWidgetShow)
  local OnWidgetHideDelegate = slua.createDelegate(OnWidgetHide)
  UAEUserWidget.SetOnWidgetShow(OnWidgetShowDelegate)
  UAEUserWidget.SetOnWidgetHide(OnWidgetHideDelegate)
  UIManager._delegates = {OnWidgetShowDelegate, OnWidgetHideDelegate}
end
function UIManager.Init()
  log(bWriteLog and "UIManager.Init()")
  UIManager._OldUIInit()
  local mode_switch_util = require("client.slua_ui_framework.util.mode_switch_util")
  mode_switch_util.Init()
  UIManager.InitUITypeMap()
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GM_STATE_UPDATE, UIManager._OnGmStateUpdate)
  UIManager._OnGmStateUpdate()
  ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
end
function UIManager.ClearOnModePreSwitch(PreStatus, gameStatus)
  bClearing = true
  for _, uiInstance in pairs(UI_Instances) do
    if uiInstance.OnModePreSwitch then
      xpcall(uiInstance.OnModePreSwitch, xpcallHandle, uiInstance, PreStatus, gameStatus)
    end
  end
  for keyName in pairs(UI_Instances) do
    local config = UIManager.GetConfigByKey(keyName)
    if base_config_util.IsCloseOnSwitch(config) then
      xpcall(UIManager.CloseUI, xpcallHandle, config)
    end
  end
  bClearing = false
end
function UIManager.ClearAll()
  bClearing = true
  for keyName in pairs(UI_Instances) do
    local config = UIManager.GetConfigByKey(keyName)
    UIManager.CloseUI(config)
  end
  bClearing = false
end
function UIManager._OnUIShowforDepthManager(config, UIBase)
  local keyName = config.keyName
  return ui_depth_manager.ShowSluaUI(keyName, UIBase, config)
end
function UIManager._ApplyPreRegisteredDepth(config, UIBase)
  return ui_depth_manager.ApplyPreRegisteredDepth(config.keyName, UIBase)
end
function UIManager._OnUIHideforDepthManager(config)
  if not base_config_util.IsSingleton(config) then
    return
  end
  if not base_config_util.IsMainUI(config) then
    return
  end
  local keyName = config.keyName
  return ui_depth_manager.HideSluaUI(keyName)
end
function UIManager._OnUIShowForNavigationManager(config)
  local keyName = config.keyName
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:UIPop(keyName)
  if not base_config_util.IsSingleton(config) then
    return
  end
  if not base_config_util.IsMainUI(config) then
    return
  end
  if ui_navigation_manager:DontNeedPush(keyName, ui_navigation_manager.EnumStyleType.SLuaUI) then
    return
  end
  return ui_navigation_manager:UIPushOn(keyName, ui_navigation_manager.EnumStyleType.SLuaUI)
end
function UIManager._OnUIHideforNavigationManager(config)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:UIPop(config.keyName)
end
function UIManager.GetTopUIName()
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:GetTopUIName()
end
function UIManager.GetTopVisibleUIName()
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:GetTopVisibleUIName()
end
function UIManager.GetTopLargeVisibleUIName(minScreenRatio, blacklist)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:GetTopLargeVisibleUIName(minScreenRatio, blacklist)
end
function UIManager.GetTopUINameList(n)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:GetTopUINameList(n)
end
function UIManager.AndroidBackToLobby()
  ui_jump_manager.Clear()
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  if GameStatus.IsInMainCity() then
    ui_navigation_manager:AndroidBackToUI(UI_Config.MainCity_Main_UIBP.keyName)
  else
    ui_navigation_manager:AndroidBackToLobby()
  end
end
function UIManager.ForceBackToLobby()
  ui_jump_manager.Clear()
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  if GameStatus.IsInMainCity() then
    ui_navigation_manager:AndroidBackToUI(UI_Config.MainCity_Main_UIBP.keyName, true)
  else
    ui_navigation_manager:ForceAndroidBackToLobby()
  end
end
function UIManager.ForceBackTo2DLobby()
  ui_jump_manager.Clear()
  if GameStatus.IsInMainCity() then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    Lobby_Main_City_Enter.LeaveMainCity()
  end
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:ForceAndroidBackToLobby()
end
function UIManager.AndroidBackToUI(keyName)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:AndroidBackToUI(keyName)
end
function UIManager.IsAndroidStackEmpty(filterMap)
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:IsAndroidStackEmpty(filterMap)
end
function UIManager.GCByMaxObject(config)
  if not base_config_util.IsMainUI(config) then
    return
  end
  gc_util.GCByMaxObjectOrMemory()
end
function UIManager._OnGmStateUpdate()
  local black_config_manager = RequireBlackList("blacklist.slua.config.black_config_manager")
  if black_config_manager then
    black_config_manager.InitBlackList()
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GM_STATE_UPDATE, UIManager._OnGmStateUpdate)
  end
end
function UIManager.InitDeviceLevel()
  if UIManager.iTCDeviceLevel == -1 then
    UIManager.iTCDeviceLevel = Client and Client.GetTCDeviceLevel() or -1
    local HDmpveRemote = require("client.slua.logic.HDmpveRemote.HDmpveRemote")
    local iDisableAsyHighDeviceLevel = HDmpveRemote.HDmpveRemoteConfigGetInt("DisableAsyHighDeviceLevel", 0)
    if UIManager.iDisableAsyHighDeviceLevel ~= iDisableAsyHighDeviceLevel then
      UIManager.    end
  end
end
function UIManager.DEV_GetRealTopUIConfig()
  local ui_navigation_manager = ModuleManager_GetModule(CommonModuleConfig.ui_navigation_manager)
  return ui_navigation_manager:DEV_GetRealTopUIConfig()
end
return UIManager