local ISettingDBInterface = require("client.slua.umg.NewSetting.GraphicsNew.ISettingDBInterface")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local StringUtil = require("common.string_util")
local UIUtil = require("client.common.ui_util")
local ERenderQuality = import("ERenderQuality")
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
local GraphicSettingDB = ISettingDBInterface:new()
GraphicSettingDB.CanOpenVulkan = "CanOpenVulkan"
GraphicSettingDB.IsVulkanEnable = "IsVulkanEnable"
GraphicSettingDB.TurboEnable = "TurboEnable"
GraphicSettingDB.TurboLastQuality = "TurboLastQuality"
GraphicSettingDB.SelectedEnergySaving = "EnergySaving"
GraphicSettingDB.SelectedShadow = "ShadowQuality"
GraphicSettingDB.SelectedWaterReflection = "WaterReflection"
GraphicSettingDB.RenderMSAASetting = "RenderMSAASetting"
GraphicSettingDB.RenderMSAAValue = "RenderMSAAValue"
GraphicSettingDB.UIRectOffset = "UIRectOffset"
GraphicSettingDB.FPSLevel = "FPSLevel"
GraphicSettingDB.CustomTab = "CustomTab"
GraphicSettingDB.SelectedFPS = "SelectedFPS"
GraphicSettingDB.SelectedQuality = "SelectedQuality"
GraphicSettingDB.GFBestQLobby = "GFBestQLobby"
GraphicSettingDB.GFBestQBattle = "GFBestQBattle"
GraphicSettingDB.RealSupportFPS = "RealSupportFPS"
GraphicSettingDB.GraphicFavor = "GraphicFavor"
GraphicSettingDB.FPSFineTuneSwitch = "FPSFineTuneSwitch"
GraphicSettingDB.FPSFineTuneNum = "FPSFineTuneNum"
GraphicSettingDB.FPSAutoInterpolation = "FPSAutoInterpolation"
GraphicSettingDB.DeviceAutoAdaptEx = "DeviceAutoAdaptEx"
GraphicSettingDB.ColorBlindnessType = "ColorBlindnessType"
GraphicSettingDB.ScreenLightness = "ScreenLightness"
GraphicSettingDB.bStyleSeparate = "bStyleSeparate"
GraphicSettingDB.BattleRenderQuality = "BattleRenderQuality"
GraphicSettingDB.BattleFPS = "BattleFPS"
GraphicSettingDB.LobbyRenderQuality = "LobbyRenderQuality"
GraphicSettingDB.LobbyFPS = "LobbyFPS"
GraphicSettingDB.MainCityRenderQuality = "MainCityRenderQuality"
GraphicSettingDB.MainCityFPS = "MainCityFPS"
GraphicSettingDB.ManorRenderQuality = "ManorRenderQuality"
GraphicSettingDB.BattleRenderStyle = "BattleRenderStyle"
GraphicSettingDB.LobbyRenderStyle = "LobbyRenderStyle"
GraphicSettingDB.bOpenSprHghQltyComparison = "bOpenSprHghQltyComparison"
GraphicSettingDB.bVerySmooth = "bVerySmooth"
GraphicSettingDB.bChangeVerySmoothSetting = "bChangeVerySmoothSetting"
GraphicSettingDB.bEnergySaveManuelChangeFlag1 = "bEnergySaveManuelChangeFlag1"
GraphicSettingDB.bEnergySaveManuelChangeFlag2 = "bEnergySaveManuelChangeFlag2"
GraphicSettingDB.nEnhancedLobbyQuality = "nEnhancedLobbyQuality"
local OldVerySmoothQuality = 6
local NewVerySmoothQuality = 1
function GraphicSettingDB:LoadUserSetting()
  self.uiDataOrigin = {}
  local gameInstance = UIUtil.GetGameInstance()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  local renderSetting = logic_setting_graphics.GetRenderSettingsApplying()
  local settingConfig = userSettings
  for key, value in pairs(GraphicSettingDB) do
    if settingConfig[key] ~= nil then
      self.uiDataOrigin[key] = settingConfig[key]
      printf("GraphicSettingDB:LoadUserSetting key:%s value:%s", key, settingConfig[key])
    end
  end
  if not Game:IsSupportVerySmooth() then
    self.uiDataOrigin[GraphicSettingDB.bVerySmooth] = false
    printf("VerySmooth: IsSupportVerySmooth value %s", tostring(self.uiDataOrigin[GraphicSettingDB.bVerySmooth]))
  else
    self.uiDataOrigin[GraphicSettingDB.bChangeVerySmoothSetting] = true
  end
  local GraphicFavor = self.uiDataOrigin[self.GraphicFavor]
  if GraphicFavor == 0 then
    local bFirstLogin = GraphicHelperUtil.IsNewAccoutFirstLogin()
    printf("GraphicSettingDB:LoadUserSetting new account default balance. GraphicFavor:%s bFirstLogin:%s", GraphicFavor, bFirstLogin)
    settingConfig[self.GraphicFavor] = GraphicConst.FavorDef.Balance
    self.uiDataOrigin[self.GraphicFavor] = GraphicConst.FavorDef.Balance
  end
  if userSettings.GFBestQLobby == 0 or userSettings.GFBestQBattle == 0 then
    local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicConst.FavorDef.BestQuality)
    self.uiDataOrigin[self.GFBestQLobby] = favorSetting.LobbyRenderQuality
    self.uiDataOrigin[self.GFBestQBattle] = favorSetting.BattleRenderQuality
    userSettings.GFBestQLobby = favorSetting.LobbyRenderQuality
    userSettings.GFBestQBattle = favorSetting.BattleRenderQuality
    printf("GraphicSettingDB:LoadUserSetting default best quality. GFBestQLobby:%s GFBestQBattle:%s", favorSetting.LobbyRenderQuality, favorSetting.BattleRenderQuality)
  end
  local offset = Client.GetUIRectOffset()
  local result = StringUtil.Split(offset, ",")
  local value = result[1]
  self.uiDataOrigin[self.UIRectOffset] = tonumber(value) or 0
  if Client.GetForceVulkanAvailable() then
    self.uiDataOrigin[self.CanOpenVulkan] = true
    printf("GraphicSettingDB:LoadUserSetting force vulkan available")
  else
    local switch = LobbySystem.CheckOpen(BP_ENUM_VULKAN_SWITCH)
    local support = Client.IsSupportVulkan()
    local white_list = LobbySystem.CheckVulkanWhiteListEnable()
    self.uiDataOrigin[self.CanOpenVulkan] = switch and support and white_list
    printf("GraphicSettingDB:LoadUserSetting vulkan switch:%s support:%s white_list:%s", switch, support, white_list)
  end
  self.uiDataOrigin[self.IsVulkanEnable] = Client.GetUserVulkanSetting()
  self.uiDataOrigin[self.CustomTab] = GraphicConst.CustomTabDef.Battle
  if not gameInstance:IsSupportSwitchRenderLevelRuntime() then
    self.uiDataOrigin[self.CustomTab] = GraphicConst.CustomTabDef.Global
    self.uiDataOrigin[self.bStyleSeparate] = false
  end
  self.uiDataOrigin[self.SelectedQuality] = userSettings.BattleRenderQuality
  self.uiDataOrigin[self.SelectedFPS] = userSettings.BattleFPS
  if self.uiDataOrigin[self.TurboEnable] and self.uiDataOrigin[self.GraphicFavor] == GraphicConst.FavorDef.Custom then
    self.uiDataOrigin[self.LobbyRenderQuality] = ERenderQuality.HIGHDEFINITIONPLUS
    self.uiDataOrigin[self.BattleRenderQuality] = ERenderQuality.HIGHDEFINITIONPLUS
    self.uiDataOrigin[self.ManorRenderQuality] = ERenderQuality.HIGHDEFINITIONPLUS
    self.uiDataOrigin[self.MainCityRenderQuality] = ERenderQuality.HIGHDEFINITIONPLUS
    self.uiDataOrigin[self.SelectedQuality] = ERenderQuality.HIGHDEFINITIONPLUS
  end
  local SelectedWaterReflection = false
  if gameInstance:GetIsFirstInitWaterReflectionSetting() then
    SelectedWaterReflection = true
  elseif gameInstance:GetWaterReflectionSetting() then
    SelectedWaterReflection = true
  else
    SelectedWaterReflection = false
  end
  self.uiDataOrigin[self.SelectedWaterReflection] = SelectedWaterReflection
  self.uiDataOrigin[self.SelectedShadow] = gameInstance:GetUserSetingShadowQuality()
  self.uiDataOrigin[self.SelectedEnergySaving] = gameInstance:GetUserSetingEnergySaving()
  self.uiDataOrigin[self.RenderMSAASetting] = renderSetting.RenderMSAASetting or false
  self.uiDataOrigin[self.RenderMSAAValue] = renderSetting.RenderMSAAValue or 0
  log_tree("GraphicSettingDB:LoadUserSetting", self.uiDataOrigin)
  local uiData = {}
  for key, value in pairs(self.uiDataOrigin) do
    uiData[key] = value
  end
  local super_data = require("common.super_data")
  self.uiData = super_data.CreateSuperData(uiData)
  self.changes = {}
end
local i = 0
function GraphicSettingDB:SaveChanges(externalChanges)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local changes = externalChanges or self.changes
  log_tree("GraphicSettingDB:SaveChanges changes", changes)
  if not changes or next(changes) == nil then
    return
  end
  i = i + 1
  local addDebug = function(msg)
    if IsEditor then
      local color = {
        0,
        255,
        0,
        255
      }
      if i % 2 == 1 then
        color = {
          255,
          0,
          255,
          255
        }
      end
      ScriptHelperClient.AddOnScreenDebugMessage(msg, -1, 30, color, {1.5, 1.5})
    end
    log(bWriteLog and msg)
  end
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local uSettingConfig = userSettings
  addDebug("[" .. i .. "]   GraphicSettingDB:SaveChanges")
  for key, value in pairs(changes) do
    if nil ~= uSettingConfig[key] and value ~= uSettingConfig[key] then
      uSettingConfig[key] = value
      addDebug(string.format("uSettingConfig[%s] = %s", key, value))
    elseif key == self.SelectedEnergySaving and value ~= self.uiDataOrigin[self.SelectedEnergySaving] then
      gameInstance:SetUserSetingEnergySaving(value)
      addDebug(string.format("gameInstance:SetUserSetingEnergySaving(%s)", value))
    elseif key == self.SelectedShadow and value ~= self.uiDataOrigin[self.SelectedShadow] then
      gameInstance:SetUserSetingShadowQuality(value)
      addDebug(string.format("gameInstance:SetUserSetingShadowQuality(%s)", value))
    elseif key == self.SelectedWaterReflection and value ~= self.uiDataOrigin[self.SelectedWaterReflection] then
      gameInstance:SetWaterReflectionSetting(value)
      addDebug(string.format("gameInstance:SetWaterReflectionSetting(%s)", value))
    end
  end
  if nil ~= changes.UIRectOffset and changes.UIRectOffset ~= self.uiDataOrigin[self.UIRectOffset] then
    self:SaveUIRectOffset(changes.UIRectOffset)
    addDebug(string.format("self:SaveUIRectOffset(%s)", changes.UIRectOffset))
  end
  for key, value in pairs(changes) do
    self.uiDataOrigin[key] = value
    self.uiData[key] = value
  end
  if nil == externalChanges then
    self.changes = {}
  end
end
function GraphicSettingDB:LoadDefaultSetting()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local defaultSetting = {}
  local UIAdaptation = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIAdaptation)
  local uiRectOffset = UIAdaptation:GetDefalutRectOffset()
  if uiRectOffset and uiRectOffset ~= "" and uiRectOffset ~= "0,0,0,0" then
    local result = StringUtil.Split(uiRectOffset, ",")
    local value = result[1]
    defaultSetting[self.UIRectOffset] = tonumber(value) or 0
  else
    defaultSetting[self.UIRectOffset] = 0
  end
  defaultSetting[self.SelectedEnergySaving] = false
  defaultSetting[self.SelectedShadow] = true
  defaultSetting[self.TurboEnable] = false
  defaultSetting[self.IsVulkanEnable] = false
  defaultSetting[self.ColorBlindnessType] = 0
  defaultSetting[self.ScreenLightness] = 1.0
  defaultSetting[self.FPSFineTuneSwitch] = false
  defaultSetting[self.FPSFineTuneNum] = 120
  defaultSetting[self.FPSAutoInterpolation] = 1
  defaultSetting[self.DeviceAutoAdaptEx] = true
  defaultSetting[self.bStyleSeparate] = false
  defaultSetting[self.LobbyRenderStyle] = 1
  defaultSetting[self.BattleRenderStyle] = 1
  defaultSetting[self.GraphicFavor] = GraphicConst.FavorDef.Balance
  defaultSetting[self.nEnhancedLobbyQuality] = (1 >= Client.GetExactDeviceLevel() or Client.GetMemorySize() <= Client.LowMemoryInGB()) and 2 or 1
  local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicConst.FavorDef.BestQuality)
  defaultSetting[self.GFBestQLobby] = favorSetting.LobbyRenderQuality
  defaultSetting[self.GFBestQBattle] = favorSetting.BattleRenderQuality
  self.end
function GraphicSettingDB:ResetToDefault()
  self.uiDataOrigin = {}
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local settingConfig = userSettings
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local defaultFavor = GraphicHelperUtil.GetFavorDefaultSettings(GraphicConst.FavorDef.Balance)
  defaultFavor.BattleRenderStyle = 1
  defaultFavor.LobbyRenderStyle = 1
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  logic_setting_graphics.ApplyFavorSettings(defaultFavor, GraphicConst.FavorDef.Balance)
  logic_setting_graphics.PostQualityToApm()
  self.changes = {}
  local renderQualityApplying = gameInstance:GetRenderQualityApplying()
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    self.changes[self.SelectedQuality] = renderQualityApplying.RenderQualitySetting
  else
    self.changes[self.SelectedQuality] = gameInstance:GetRenderQualityLastSet().RenderQualitySetting
  end
  if nil == self.defaultSetting then
    self:LoadDefaultSetting()
  end
  for key, value in pairs(self.defaultSetting) do
    self.changes[key] = value
  end
  self:SaveChanges()
  for key, value in pairs(self.uiDataOrigin) do
    self.uiData[key] = value
  end
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_Vulkan_Status, 0)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Vulkan_Status, 0, "0")
  GraphicHelperUtil.ReportTLogQualityAndFPS()
end
function GraphicSettingDB:UpdateSelectedQuality(quality, bAll)
  if bAll then
    self:UpdateUIData(self.BattleRenderQuality, quality)
    self:UpdateUIData(self.LobbyRenderQuality, quality)
    self:UpdateUIData(self.ManorRenderQuality, quality)
    self:UpdateUIData(self.MainCityRenderQuality, quality)
  else
    local CustomTab = self.uiData[self.CustomTab]
    if CustomTab == GraphicConst.CustomTabDef.Battle or CustomTab == GraphicConst.CustomTabDef.Global then
      self:UpdateUIData(self.BattleRenderQuality, quality)
    elseif CustomTab == GraphicConst.CustomTabDef.Lobby then
      self:UpdateUIData(self.LobbyRenderQuality, quality)
    elseif CustomTab == GraphicConst.CustomTabDef.Home then
      self:UpdateUIData(self.ManorRenderQuality, quality)
    elseif CustomTab == GraphicConst.CustomTabDef.MainCity then
      self:UpdateUIData(self.MainCityRenderQuality, quality)
    end
  end
  self:UpdateUIData(self.SelectedQuality, quality)
end
function GraphicSettingDB:UpdateSelectedFPS(FPSIndex)
  local CustomTab = self.uiData[self.CustomTab]
  if CustomTab == GraphicConst.CustomTabDef.Battle or CustomTab == GraphicConst.CustomTabDef.Global then
    printf("GraphicSettingDB:UpdateSelectedFPS debugFPS BattleFPS FPSIndex:%s", FPSIndex)
    self:UpdateUIData(self.BattleFPS, FPSIndex)
  elseif CustomTab == GraphicConst.CustomTabDef.Lobby then
    printf("GraphicSettingDB:UpdateSelectedFPS debugFPS LobbyFPS FPSIndex:%s", FPSIndex)
    self:UpdateUIData(self.LobbyFPS, FPSIndex)
  elseif CustomTab == GraphicConst.CustomTabDef.MainCity then
    printf("GraphicSettingDB:UpdateSelectedFPS debugFPS MainCityFPS FPSIndex:%s", FPSIndex)
    self:UpdateUIData(self.MainCityFPS, FPSIndex)
  end
  self:UpdateUIData(self.SelectedFPS, FPSIndex)
end
function GraphicSettingDB:SaveUIRectOffset(value)
  printf("GraphicSettingDB:SaveUIRectOffset value:%s", value)
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  userSettings.ProfiledScreenSwitch = userSettings.ProfiledScreenSwitch + 1
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({screenValue = value}, PlayerPrefsSystem.ePlayerPrefsType.SpecialScreen)
  local SettingSystem = require("client.logic.setting.logic_setting")
  local shapedScreenParam = SettingSystem.GetShapedScreenParam()
  LobbySystem.SetUIRectOffset(shapedScreenParam)
end
return GraphicSettingDB