local logic_gamelet_interface = {}
local gamelet_define = require("client.slua.logic.gamelet.gamelet_define")
local gamelet_config = gamelet_define.GameletAppConfig
local Enum_GameletEnv = gamelet_define.Enum_GameletEnv
local Enum_IMSDKEnv = gamelet_define.Enum_IMSDKEnv
function logic_gamelet_interface:DefineAndResetData()
  self.nonage = 1
  self.gamelet_apps_info = {}
  self.AppType2AppId = {}
  self.has_inited = false
  self.OpenedAppId = ""
  self.GAMELET_SLOW_TICK_INTERVAL = 3600
  self.gamelet_in_slow_tick_status = false
  self.ViewCreatedHandleMap = {}
  self.DisableReason = 0
  self.bOpenGamelet = false
end
function logic_gamelet_interface:OnInitialize()
  logic_gamelet_interface.__super.OnInitialize(self)
  local Gamelet, GameletSettings
  if self:gamelet_enable() then
    Gamelet = import("Gamelet")
    GameletSettings = import("GameletSettings")
  end
  if Gamelet then
    self.gamelet = Gamelet.Get()
  end
  if GameletSettings then
    self.gamelet_setting = GameletSettings.Get()
  end
end
function logic_gamelet_interface:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self.gamelet_in_slow_tick_status = true
    self:SetTickIntervalSec(self.GAMELET_SLOW_TICK_INTERVAL)
  else
    self.gamelet_in_slow_tick_status = false
    self:SetTickIntervalSec(0)
  end
end
function logic_gamelet_interface:gamelet_enable()
  log(bWriteLog and "logic_gamelet_interface:gamelet_enable.")
  local memorySize = Client.GetMemorySize()
  log(bWriteLog and "logic_gamelet_interface:gamelet_enable memory size:" .. tostring(memorySize))
  if memorySize <= 2 then
    local DisableMem2GGameletSDK = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableMem2GGameletSDK", false)
    log(bWriteLog and "logic_gamelet_interface:gamelet_enable DisableMem2GGameletSDK:" .. tostring(DisableMem2GGameletSDK))
    if DisableMem2GGameletSDK then
      self.DisableReason = gamelet_define.DisableReason.LowMem
      log(bWriteLog and "logic_gamelet_interface:gamelet_enable disabled due to low memory")
      return false
    end
  end
  local region = Client.GetPublishRegion()
  log(bWriteLog and "logic_gamelet_interface:gamelet_enable publish region:" .. tostring(region))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.BLUEHOLE then
    self.DisableReason = gamelet_define.DisableReason.RegionForbidden
    log(bWriteLog and "logic_gamelet_interface:gamelet_enable disabled due to BLUEHOLE region")
    return false
  end
  local DisableGameletSDK = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableGameletSDK", false)
  log(bWriteLog and "logic_gamelet_interface:gamelet_enable DisableGameletSDK:" .. tostring(DisableGameletSDK))
  if DisableGameletSDK == true then
    self.DisableReason = gamelet_define.DisableReason.RemoteSwitchClosed
    log(bWriteLog and "logic_gamelet_interface:gamelet_enable disabled due to remote switch closed")
    return false
  end
  log(bWriteLog and "logic_gamelet_interface:gamelet_enable all checks passed, enabled")
  return true
end
function logic_gamelet_interface:RegistEvents()
  if self.gamelet_setting then
    self:AddControlEvent(self.gamelet_setting, "OnSDKMessage", self.OnSDKMessage, self)
    self:AddControlEvent(self.gamelet_setting, "OnRefreshUserdata", self.OnRefreshUserdata, self)
    self:AddControlEvent(self.gamelet_setting, "OnViewCreated", self.OnViewCreated, self)
    self:AddControlEvent(self.gamelet_setting, "OnViewAboutToDestroy", self.OnViewAboutToDestroy, self)
    self:AddControlEvent(self.gamelet_setting, "OnReportData", self.OnReportData, self)
    self:AddControlEvent(self.gamelet_setting, "OnCoreCodeLoad", self.OnCoreCodeLoad, self)
  end
end
function logic_gamelet_interface:OnLogin(bReLogin)
end
function logic_gamelet_interface:OnLoginGameLetImpl(bReLogin)
  if self.has_inited == false then
    self:SetupPixLibrary()
    self:InitializeSDK()
    local curLanguage = Client.GetCurrentLanguage()
    local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
    if curLanguage == LanguageMacros.MY then
      self:SetFont("ZawgyiOneFont", "/Game/UMG/Font/ZawgyiOneFont.ZawgyiOneFont")
    else
      self:SetFont("TSLFont", "/Game/UMG/Font/TSLFont.TSLFont")
    end
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
      local PixUIBPLibrary = import("PixUIBPLibrary")
      if PixUIBPLibrary and PixUIBPLibrary.PixUI_SetSupportTextShape then
        PixUIBPLibrary.PixUI_SetSupportTextShape(curLanguage ~= LanguageMacros.MY)
      end
    end
    self:InitializeGameletLog()
    Client.InitIOSNotchSize()
    self.has_inited = true
  end
  local async = require("client.common.async")
  async.Run(function(co)
    async.AwaitEvent(co, 0.5, EVENTTYPE_GAMELET, EVENTID_GAMELET_DELAY_OPEN)
    self:Open()
  end)
end
function logic_gamelet_interface:OnLogOut()
  self:Close()
  local LogicGameletRedPoint = require("client.slua.logic.gamelet.LogicGameletRedPoint")
  LogicGameletRedPoint:OnLogOut()
end
function logic_gamelet_interface:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    self:CloseApp()
  end
  local LogicGameletLayer = require("client.slua.logic.gamelet.LogicGameletLayer")
  LogicGameletLayer:DestroyData()
end
function logic_gamelet_interface:OnSDKMessage(msg)
  log(bWriteLog and string.format("logic_gamelet_interface:OnSDKMessage: %s", msg))
  local message = json.decode(msg)
  local appId = message.appId
  local appType = self:get_app_type(appId) or message.appName
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:OnReceiveMessage(appType, tostring(appId), msg, message)
  return 0
end
function logic_gamelet_interface:OnRefreshUserdata()
  log(bWriteLog and "logic_gamelet_interface:OnRefreshUserdata")
  local user_data = self:get_current_user_data()
  self:RefreshUserdata(user_data)
  return 0
end
function logic_gamelet_interface:OnViewCreated(widget, app_info)
  log(bWriteLog and "logic_gamelet_interface:OnViewCreated app_info:" .. tostring(app_info))
  local AppInfo
  if app_info ~= nil and type(app_info) == "string" then
    AppInfo = json.decode(app_info)
  else
    AppInfo = {
      belongToApp = self.OpenedAppId,
      appPage = app_info and app_info.appPage
    }
  end
  log_tree("AppInfo:", AppInfo)
  local keyName = AppInfo.appPage .. AppInfo.belongToApp
  if self.ViewCreatedHandleMap[keyName] ~= nil then
    self.ViewCreatedHandleMap[keyName](widget, AppInfo)
  else
    if widget then
      local ui_depth_manager = require("client.common.uibase.ui_depth_manager")
      local depth = ui_depth_manager.ShowPandaUI(keyName)
      local game_frontend_hud = require("game_frontend_hud")
      game_frontend_hud.AddToContainer(UIContainers.Default, widget, depth)
    end
    if not UIManager.IsUIShow(UIManager.UI_Config.GameletSDK_UIBP) then
      UIManager.ShowUI(UIManager.UI_Config.GameletSDK_UIBP)
    end
  end
end
function logic_gamelet_interface:OnViewAboutToDestroy(widget, app_info)
  log(bWriteLog and "logic_gamelet_interface:OnViewAboutToDestroy")
  if widget then
    local game_frontend_hud = require("game_frontend_hud")
    game_frontend_hud.RemoveFromContainer(UIContainers.Default, widget)
  end
  local AppInfo
  if app_info ~= nil and type(app_info) == "string" then
    AppInfo = json.decode(app_info)
  end
  if AppInfo then
    local keyName = AppInfo.appPage .. AppInfo.belongToApp
    local ui_depth_manager = require("client.common.uibase.ui_depth_manager")
    ui_depth_manager.HidePandaUI(keyName)
  end
  if self.gamelet_in_slow_tick_status == true then
    self:SetTickIntervalSec(self.GAMELET_SLOW_TICK_INTERVAL)
  end
end
function logic_gamelet_interface:OnReportData(event_name, data)
  log(bWriteLog and string.format("logic_gamelet_interface:OnReportData: %s, %s", event_name, data))
end
function logic_gamelet_interface:OnCoreCodeLoad()
  log(bWriteLog and "logic_gamelet_interface:OnCoreCodeLoad")
  local gameletCoreEmbedJS = string.format("%sTemplates/Data/Gamelet/Content/gameletcore_embedded.js", Client.ProjectContentDir())
  local fileData = Client.LoadFileToArrayByFullPath(gameletCoreEmbedJS)
  return true, fileData
end
function logic_gamelet_interface:InitializeSDK()
  log(bWriteLog and "logic_gamelet_interface:InitializeSDK")
  if self.gamelet == nil then
    return
  end
  local ret = self.gamelet:Initialize(self.gamelet_setting)
  log(bWriteLog and "logic_gamelet_interface:InitializeSDK result: " .. tostring(ret))
end
function logic_gamelet_interface:SetFont(font_name, font_path)
  log(bWriteLog and string.format("logic_gamelet_interface:SetFont: %s, %s", font_name, font_path))
  if self.gamelet == nil then
    return
  end
  self.gamelet:SetFont(font_name, font_path)
end
function logic_gamelet_interface:Open()
  log(bWriteLog and "logic_gamelet_interface:Open")
  if self.bOpenGamelet then
    log(bWriteLog and "logic_gamelet_interface:Open. already open")
    return
  end
  if self.gamelet == nil then
    log(bWriteLog and "logic_gamelet_interface:Open. gamelet is nil")
    return
  end
  self.bOpenGamelet = true
  self.gamelet_apps_info = {}
  local gamelet_env = self:get_env()
  local user_data = self:get_current_user_data()
  self.gamelet:Open(gamelet_env, user_data)
end
function logic_gamelet_interface:OpenApp(app_id, args_json)
  log(bWriteLog and "logic_gamelet_interface:OpenApp")
  if self.gamelet == nil then
    return -1
  end
  self:SetTickIntervalSec(0)
  self.OpenedAppId = app_id
  log(bWriteLog and string.format("logic_gamelet_interface:OpenApp args_json: %s", args_json))
  return self.gamelet:OpenApp(app_id, args_json)
end
function logic_gamelet_interface:AddViewCreatedHandle(keyName, handleFunc, ...)
  if self.ViewCreatedHandleMap[keyName] ~= nil then
    print(bWriteLog and "logic_gamelet_interface:AddViewCreatedHandle keyName already exist" .. tostring(keyName))
    return
  end
  print(bWriteLog and "logic_gamelet_interface:AddViewCreatedHandle keyName:" .. tostring(keyName))
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  self.ViewCreatedHandleMap[keyName] = handle
end
function logic_gamelet_interface:RemoveViewCreatedHandle(keyName)
  if self.ViewCreatedHandleMap[keyName] ~= nil then
    print(bWriteLog and "logic_gamelet_interface:RemoveViewCreatedHandle keyName:" .. tostring(keyName))
    self.ViewCreatedHandleMap[keyName] = nil
  end
end
function logic_gamelet_interface:SendMessageToApp(jsonStr, appId)
  log(bWriteLog and string.format("logic_gamelet_interface:SendMessageToApp: %s", jsonStr))
  if self.gamelet == nil then
    return
  end
  if not appId or appId == "" or appId == "nil" then
    log_error_format("logic_gamelet_interface:SendMessageToApp appId is nil, json is %s", jsonStr)
    return
  end
  self.gamelet:SendMessageToApp(appId, jsonStr)
end
function logic_gamelet_interface:RefreshUserdata(user_data)
  log(bWriteLog and "logic_gamelet_interface:RefreshUserdata")
  log_tree(bWriteLog and "logic_gamelet_interface:RefreshUserdata user_data", user_data)
  if self.gamelet == nil then
    return
  end
  self.gamelet:RefreshUserdata(user_data)
end
function logic_gamelet_interface:SetScriptExternalLoadDir(external_load_dir)
  log(bWriteLog and "logic_gamelet_interface:SetScriptExternalLoadDir")
  if self.gamelet == nil then
    return
  end
  self.gamelet:SetScriptExternalLoadDir(external_load_dir)
end
function logic_gamelet_interface:CloseApp()
  log(bWriteLog and "logic_gamelet_interface:CloseApp")
  if self.gamelet == nil then
    return
  end
  if self.OpenedAppId ~= nil and #self.OpenedAppId > 0 then
    self.gamelet:CloseApp(self.OpenedAppId)
    self.OpenedAppId = ""
  end
end
function logic_gamelet_interface:Close()
  log(bWriteLog and "logic_gamelet_interface:Close")
  if self.gamelet == nil then
    log(bWriteLog and "logic_gamelet_interface:Close. gamelet is nil")
    return
  end
  self.gamelet_apps_info = {}
  self.bOpenGamelet = false
  self.gamelet:Close()
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
  HostedProtoBridge:ClearStaticState(HostedConst.HostedType.Gamelet)
end
function logic_gamelet_interface:UnInitializeSDK()
  log(bWriteLog and "logic_gamelet_interface:UnInitializeSDK")
  if self.gamelet == nil then
    return
  end
  self.gamelet:Deinitialize()
end
function logic_gamelet_interface:get_current_user_data()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local itop_app_id = tostring(Client.GetITopGameId())
  local platfom_id = 1
  local strPlatform = Client.GetDevicePlatformName()
  if strPlatform == DevicePlatformNameMacros.IOS then
    platfom_id = 0
  elseif strPlatform == DevicePlatformNameMacros.Windows then
    platfom_id = 2
  end
  local HDmpve_channel_id = Client.GetLoginChannel(NetInterface)
  local account_type = PANDORA_PLAYFORM[HDmpve_channel_id]
  local area = tostring(PandoraSystem.GetAreaId())
  local openid, atk = self:get_author_data()
  local gameVersion = PandoraSystem.GetMainAppVersion()
  local language = webModule:GetCurrentLanguage()
  local country = FuncUtil.GetAccountRegionForBP()
  local UnbindMgr = require("client.slua.logic.unbind_account.logic_unbind")
  local imsdk_channel_id = UnbindMgr.GetChannelIdByLoginPlatform(HDmpve_channel_id)
  local intlsdk_param = string.format("channelid=%d&os=%d", imsdk_channel_id, platfom_id)
  local ticket = Client.GetWebViewTicket(NetInterface)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local sGameArea = ZoneSystem.GetChooseZone()
  local user_data = {
    sOpenId = openid,
    sAppId = itop_app_id,
    sRoleId = tostring(DataMgr.roleData.uid),
    sPlatID = tostring(platfom_id),
    sServerPlatID = tostring(platfom_id),
    sAccountType = account_type,
    sArea = area,
    sPartition = "1",
    sAccessToken = atk,
    sGameVer = gameVersion,
    sPayToken = "",
    sRegion = country,
    sLanguage = language,
    sChannelID = "",
    sLoginChannel = "",
    sIntlSdkParam = intlsdk_param,
    sServiceType = "pubgm",
    sExtend = "",
    sExtCgiAttrs = "{}",
    publishRegion = tostring(Client.GetPublishRegion()),
    sTicket = ticket,
    sRoleName = DataMgr.roleData.nickName,
    sHeadUrl = DataMgr.roleData.headIconUrl,
    sIp = Client.GetIpAddr(),
    sNetType = Client.GetNetWorkType(),
    sGameArea = sGameArea,
    nNonage = self.nonage
  }
  log_tree("logic_gamelet_interface:get_current_user_data return: ", user_data)
  return user_data
end
function logic_gamelet_interface:get_app_id(AppType)
  local strRegion = Client.GetPublishRegion()
  local app_id = gamelet_config.AppIds[AppType][strRegion] or "0"
  log(bWriteLog and string.format("logic_gamelet_interface:get_app_id(%s) return: %s", AppType, app_id))
  return app_id
end
function logic_gamelet_interface:GetAppIdByShowEntrance(appType)
  if not appType then
    return nil
  end
  local appType = string.lower(appType)
  if not self.AppType2AppId[appType] then
    return nil
  end
  return self.AppType2AppId[appType]
end
function logic_gamelet_interface:get_app_type(appId)
  if not appId then
    return
  end
  local strRegion = Client.GetPublishRegion()
  for appType, regionInfo in pairs(gamelet_config.AppIds) do
    local Id = regionInfo[strRegion]
    if appId == Id then
      return appType
    end
  end
end
function logic_gamelet_interface:get_author_data()
  local token = Client.GetToken(NetInterface) or ""
  if Client.IsEditor() then
    token = "mock-token-for-editor"
  end
  return tostring(DataMgr.roleData.openID or ""), token
end
function logic_gamelet_interface:get_env()
  local gamelet_env = Enum_GameletEnv.Product
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.CE or region == PublishRegionMacros.FITCE then
    gamelet_env = Enum_GameletEnv.Tyf_Product
    if Client.GetIMSDKEnv() == Enum_IMSDKEnv.Test or _G.IsEditor then
      gamelet_env = Enum_GameletEnv.Tyf_Test
    end
  elseif Client.GetIMSDKEnv() == Enum_IMSDKEnv.Test or _G.IsEditor then
    gamelet_env = Enum_GameletEnv.Test
  end
  return gamelet_env
end
function logic_gamelet_interface:SetGameletReady(appId, appType, bReady)
  local key = tostring(appId)
  appType = string.lower(appType)
  log_format("logic_gamelet_interface:SetGameletReady. appId=%s, appType=%s, bReady=%s ", tostring(appId), tostring(appType), tostring(bReady))
  self.AppType2AppId[appType] = appId
  self.gamelet_apps_info[key] = {ready = bReady, appType = appType}
end
function logic_gamelet_interface:IsInterfaceReady(app_id)
  if not app_id or not self.gamelet_apps_info[tostring(app_id)] then
    return false
  end
  return self.gamelet_apps_info[tostring(app_id)].ready == true
end
function logic_gamelet_interface:GetAppType(appId)
  if not appId or not self.gamelet_apps_info[tostring(appId)] then
    return nil
  end
  local info = self.gamelet_apps_info[tostring(appId)]
  return info.appType
end
function logic_gamelet_interface:SetTickIntervalSec(TickIntervalSec)
  log(bWriteLog and "logic_gamelet_interface:SetTickIntervalSec: " .. tostring(TickIntervalSec))
  if self.gamelet == nil then
    return
  end
  self.gamelet:SetTickIntervalSec(TickIntervalSec)
  if TickIntervalSec == 0 then
    local msg = {
      cmd = 100001,
      args = {ticks = 5}
    }
    self.gamelet:SendMessageToSdk(json.encode(msg))
  end
end
function logic_gamelet_interface:SetupPixLibrary()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return
  end
  local BusinessHelper = import("BusinessHelper")
  local isAppFromStore = BusinessHelper.IsAppFromStore()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and isAppFromStore then
    local so_path = Client.GetSOStoredPath()
    local PandoraVideoBP = import("BP_PixVideoLibrary")
    if PandoraVideoBP then
      PandoraVideoBP.SetPixVideoLibraryPath(so_path)
    end
    local PixUIVideoBP = import("PixUIBPLibrary")
    if PixUIVideoBP then
      PixUIVideoBP.PixUI_SetDynamicLibraryPath(so_path .. "/")
      PixUIVideoBP.PixUI_AddDynamicLibraryPath(so_path .. "/")
    end
  end
end
function logic_gamelet_interface:SetUserDataNonage(is_nonage)
  if is_nonage ~= self.nonage then
    self.nonage = is_nonage
    local user_data = self:get_current_user_data()
    if not user_data or type(user_data) == "boolean" then
      log_format(bWriteLog and "logic_gamelet_interface:SetUserDataNonage: user_data is nil")
      return
    end
    self:RefreshUserdata(user_data)
  end
end
function logic_gamelet_interface:InitializeGameletLog()
  local enable = false
  local IsDev = Client and Client.IsDevelopment()
  enable = enable or IsDev
  local GainCrashLogInfoBackground = HDmpveRemote.HDmpveRemoteConfigGetInt("GainCrashLogInfoBackground", 0)
  enable = enable or GainCrashLogInfoBackground ~= 0
  self:EnableLog(enable)
end
function logic_gamelet_interface:EnableLog(enable)
  print(string.format("logic_gamelet_interface:EnableLog, enable=%s", tostring(enable)))
  if self.gamelet then
    self.gamelet:EnableLog(enable)
  end
  if self.gamelet_setting then
    self.gamelet_setting.ForbiddenSyncServerLogConf = not enable
  end
end
local GameletModule = {
  [BP_ENUM_MODULE_HOSTED_WOW_BBS] = true,
  [BP_ENUM_MODULE_HOSTED_CS] = true,
  [BP_ENUM_MODULE_HOSTED_SAFETY_CENTER] = true,
  [BP_ENUM_MODULE_HOSTED_WIKI] = true,
  [BP_ENUM_MODULE_HOSTED_GAMELET_ACT] = true,
  [BP_ENUM_MODULE_HOSTED_CREATOR_BASE] = true,
  [BP_ENUM_MODULE_HOSTED_NATIONNALESPORTS_OFFICIAL] = true,
  [BP_ENUM_MODULE_HOSTED_NATIONNOLESPORTS_ENTERTAINMENT] = true
}
function logic_gamelet_interface:IsGameletModule(moduleId)
  return GameletModule[tonumber(moduleId)] == true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_gamelet_interface = class(CModuleBase, nil, logic_gamelet_interface)
return Clogic_gamelet_interface