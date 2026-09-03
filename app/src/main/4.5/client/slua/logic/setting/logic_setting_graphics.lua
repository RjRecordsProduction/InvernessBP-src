local logic_setting_graphics = {
  ServerSwitch = false,
  PrintInfoWhenSetGraphics = false,
  bNegativePlay = nil,
  SetToVerySmoothThisBattle = false,
  DowngradeFpsRecoverTimer = nil
}
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local ERenderQuality = import("ERenderQuality")
local BATTLE = 0
local LOBBY = 1
local MANOR = 2
local MAIN_CITY = 3
local bFirst = 1
local EnergySavingClose = 1
local EnergySavingOpen = 2
local NotSupportASTC = 1
local SupportASTC = 2
local EnhancedLobbyQualityClose = 1
local EnhancedLobbyQualityOpen = 2
local MaxDurationForDowngradeFpsLevel = 30
local OldVerySmoothQuality = 6
local NewVerySmoothQuality = 1
function logic_setting_graphics.OnGameStateChange(_, _, vars)
  printf("logic_setting_graphics.OnGameStateChange vars.current: %s, vars.pre: %s", vars.current, vars.pre)
  if vars.current == GameStatus.Login then
    printf("logic_setting_graphics.OnGameStateChange Login")
    return
  end
  local renderQuality = GraphicHelperUtil.GetCurrentSceneRenderQuality()
  printf("logic_setting_graphics.OnGameStateChange debugVerysmooth set SetToVerySmoothThisBattle to false")
  logic_setting_graphics.SetToVerySmoothThisBattle = false
  if vars.current == GameStatus.Fighting then
    logic_setting_graphics.MountQualityPak(renderQuality)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.SettingGraphicsQualityFight, renderQuality)
  else
    logic_setting_graphics.UnmountPakFile()
    if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Login then
      local timer_tick = require("common.time_ticker")
      timer_tick.AddTimerOnce(5, function()
        local renderQuality = GraphicHelperUtil.GetCurrentSceneRenderQuality()
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.SettingGraphicsQualityLobby, renderQuality)
      end)
    end
  end
  if vars.current == GameStatus.Lobby and bFirst == 1 then
    logic_setting_graphics.PostQualityToApm()
    bFirst = 0
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PcobSetting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePcobSetting) or {}
  if Client.IsWindowOB() and not PcobSetting.set then
    log(bWriteLog and "  : IsWindowOB and first")
    logic_setting_graphics.SetToUltraHDR()
    PlayerPrefsSystem.SaveTableToFile_N({set = true}, PlayerPrefsSystem.ePlayerPrefsType.ePcobSetting)
  end
  if IsWoWEditor then
    log(bWriteLog and "  : IsWoWEditor and first")
    logic_setting_graphics.SetToHighDefinition()
  end
end
function logic_setting_graphics.PostQualityToApm()
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  if not settingConfig.HasGraphicsSeparateConfig then
    return
  end
  local FPS, RenderQuality
  local tempValue = 0
  local gameInstance = logic_setting_graphics.GetGameInstance()
  local ShadowSwitch = gameInstance:GetApplyingShadowQuality()
  local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
  local RenderMSAA = RenderSettingsApplying.RenderMSAASetting
  local RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
  local RenderEnergySaving = gameInstance:GetUserSetingEnergySaving()
  local GraphicFavor = settingConfig.GraphicFavor
  local RenderSupportASTC = gameInstance:GetSupportsAndroidASTC()
  local nEnhancedLobbyQuality = logic_setting_graphics.GetSettingConfig().nEnhancedLobbyQuality
  tempValue = (settingConfig.LobbyRenderQuality + 1) * 1000
  tempValue = tempValue + settingConfig.LobbyRenderStyle * 100
  tempValue = tempValue + settingConfig.LobbyFPS * 10
  if RenderMSAA == true then
    tempValue = tempValue + 1
  else
    tempValue = tempValue + 0
  end
  if ShadowSwitch == true then
    tempValue = tempValue + math.fmod(20000 + GraphicFavor * 20000, 100000)
  else
    tempValue = tempValue + math.fmod(10000 + GraphicFavor * 20000, 100000)
  end
  if RenderEnergySaving == true then
    tempValue = tempValue + EnergySavingOpen * 100000
  else
    tempValue = tempValue + EnergySavingClose * 100000
  end
  if RenderSupportASTC == true then
    tempValue = tempValue + SupportASTC * 1000000
  else
    tempValue = tempValue + NotSupportASTC * 1000000
  end
  if nEnhancedLobbyQuality == 1 then
    tempValue = tempValue + EnhancedLobbyQualityOpen * 10000000
  else
    tempValue = tempValue + EnhancedLobbyQualityClose * 10000000
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    TApmHelper.PostEvent(766, tempValue, false)
    log(bWriteLog and "logic_setting_graphics:PostQualityToApm, LobbyGraphicSetting(" .. tostring(tempValue) .. ")")
    tempValue = (settingConfig.BattleRenderQuality + 1) * 1000
    tempValue = tempValue + settingConfig.BattleRenderStyle * 100
    tempValue = tempValue + settingConfig.BattleFPS * 10
    if RenderMSAA == true then
      tempValue = tempValue + 1
    else
      tempValue = tempValue + 0
    end
    if ShadowSwitch == true then
      tempValue = tempValue + math.fmod(20000 + GraphicFavor * 20000, 100000)
    else
      tempValue = tempValue + math.fmod(10000 + GraphicFavor * 20000, 100000)
    end
    if RenderEnergySaving == true then
      tempValue = tempValue + EnergySavingOpen * 100000
    else
      tempValue = tempValue + EnergySavingClose * 100000
    end
    if RenderSupportASTC == true then
      tempValue = tempValue + SupportASTC * 1000000
    else
      tempValue = tempValue + NotSupportASTC * 1000000
    end
    TApmHelper.PostEvent(767, tempValue, false)
    log(bWriteLog and "logic_setting_graphics:PostQualityToApm, FightGraphicSetting(" .. tostring(tempValue) .. ")")
  end
  local str = string.format("uid:%s,bSupportVerySmooth:%s,PlayerVerySmoothSetting:%s", DataMgr.roleData.uid, tostring(Game:IsSupportVerySmooth()), tostring(settingConfig.BattleRenderQuality == ERenderQuality.VERYSMOOTH))
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.VerySmoothSettingReport, str)
end
function logic_setting_graphics.GetSettingConfig()
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetGameFrontendHUD():GetUserSettings()
end
function logic_setting_graphics.GetGameInstance()
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetGameInstance()
end
function logic_setting_graphics.GetRenderSettingsApplying()
  local gameInstance = logic_setting_graphics.GetGameInstance()
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    return gameInstance:GetRenderQualityApplying()
  else
    return gameInstance:GetRenderQualityLastSet()
  end
end
function logic_setting_graphics.GetRenderQuality(state)
  if logic_setting_graphics.GraphicsSeparate() then
    local settingConfig = logic_setting_graphics.GetSettingConfig()
    if state == LOBBY then
      return settingConfig.LobbyRenderQuality
    elseif state == MANOR then
      return settingConfig.ManorRenderQuality
    elseif state == MAIN_CITY then
      return settingConfig.MainCityRenderQuality
    else
      return settingConfig.BattleRenderQuality
    end
  else
    return logic_setting_graphics.GetRenderSettingsApplying().RenderQualitySetting
  end
end
function logic_setting_graphics.GraphicsSeparate()
  if IsEditor then
    return true
  end
  local gameInstance = logic_setting_graphics.GetGameInstance()
  local supportRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  local ServerSwitch = DataMgr.roleData.image_quality_open_flag
  printf("logic_setting_graphics.GraphicsSeparate  ServerSwitch:%s,  SupportRuntime:%s", ServerSwitch, supportRuntime)
  return ServerSwitch
end
function logic_setting_graphics.GenerateSeparatedGraphicsSettings()
  local game_frontend_hud = require("game_frontend_hud")
  local gameFrontendHUDInst = game_frontend_hud.GetInstance()
  local settingConfig = gameFrontendHUDInst:GetUserSettings()
  local bHasGraphicsSeparateConfig = settingConfig.HasGraphicsSeparateConfig
  printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings bHasGraphicsSeparateConfig: %s", bHasGraphicsSeparateConfig)
  gameFrontendHUDInst:BeginModifyUserSettings()
  local renderSettingApplying = logic_setting_graphics.GetRenderSettingsApplying()
  local RenderStyle = renderSettingApplying.RenderStyleSetting
  local RenderQuality = renderSettingApplying.RenderQualitySetting
  local FPS = settingConfig.FPSLevel
  printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings RenderStyle: %s, RenderQuality: %s, FPS: %s", RenderStyle, RenderQuality, FPS)
  if bHasGraphicsSeparateConfig then
    if settingConfig.MainCityRenderQuality == 0 or settingConfig.MainCityFPS == 0 then
      settingConfig.MainCity      settingConfig.MainCity      printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings init MainCityRenderQuality: %s, MainCityFPS: %s", settingConfig.MainCityRenderQuality, settingConfig.MainCityFPS)
    end
  else
    local graphicFavor = settingConfig.GraphicFavor
    if graphicFavor == 0 then
      printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings no graphicFavor settingConfig.BattleRenderQuality: %s, settingConfig.LobbyRenderQuality: %s, settingConfig.MainCityRenderQuality %s", settingConfig.BattleRenderQuality, settingConfig.LobbyRenderQuality, settingConfig.MainCityRenderQuality)
      local defaultSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicConst.FavorDef.Balance)
      settingConfig.BattleFPS = defaultSetting.BattleFPS
      settingConfig.Battle      settingConfig.BattleRenderQuality = defaultSetting.BattleRenderQuality
      settingConfig.LobbyFPS = defaultSetting.LobbyFPS
      settingConfig.Lobby      settingConfig.LobbyRenderQuality = defaultSetting.LobbyRenderQuality
      settingConfig.ManorRenderQuality = defaultSetting.ManorRenderQuality
      settingConfig.MainCityRenderQuality = defaultSetting.MainCityRenderQuality
      settingConfig.MainCityFPS = defaultSetting.MainCityFPS
      settingConfig.GraphicFavor = GraphicConst.FavorDef.Balance
    else
      printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings GraphicFavor:%s", settingConfig.GraphicFavor)
      printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings BattleFPS:%s, LobbyFPS:%s, MainCityFPS:%s", settingConfig.BattleFPS, settingConfig.LobbyFPS, settingConfig.MainCityFPS)
      printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings BattleRenderQuality:%s, LobbyRenderQuality:%s, MainCityRenderQuality:%s, ManorRenderQuality:%s", settingConfig.BattleRenderQuality, settingConfig.LobbyRenderQuality, settingConfig.MainCityRenderQuality, settingConfig.ManorRenderQuality)
      printf("logic_setting_graphics.GenerateSeparatedGraphicsSettings BattleRenderStyle:%s, LobbyRenderStyle:%s", settingConfig.BattleRenderStyle, settingConfig.LobbyRenderStyle)
    end
    settingConfig.HasGraphicsSeparateConfig = true
  end
  gameFrontendHUDInst:FinishModifyUserSettings()
end
function logic_setting_graphics.SaveSeparatedGraphicsSettings(state, FPS, RenderQuality, RenderStyle)
  log(bWriteLog and "[LogicSettingGraphics] SaveSeparatedGraphicsSettings")
  local game_frontend_hud = require("game_frontend_hud")
  local gameFrontendHUDInst = game_frontend_hud.GetInstance()
  local settingConfig = gameFrontendHUDInst:GetUserSettings()
  gameFrontendHUDInst:BeginModifyUserSettings()
  if state == BATTLE then
    settingConfig.Battle    settingConfig.Battle    settingConfig.Battle    log(bWriteLog and "  :SelectedQuality BattleRenderQuality RenderQuality: " .. tostring(RenderQuality))
  elseif state == LOBBY then
    settingConfig.Lobby    settingConfig.Lobby    settingConfig.Lobby  elseif state == MANOR then
    settingConfig.Manor  end
  gameFrontendHUDInst:FinishModifyUserSettings()
  logic_setting_graphics.PostQualityToApm()
end
function logic_setting_graphics.RenderQualityNormalization(UI)
  local isValid = false
  for _, value in pairs(ERenderQuality) do
    if UI.SelectedArtQuality == value then
      isValid = true
      break
    end
  end
  if not isValid then
    UI.SelectedArtQuality = ERenderQuality.Default
  end
end
function logic_setting_graphics.RenderStyleNormalization(UI)
  local ERenderStyle = import("ERenderStyle")
  local isValid = false
  for _, value in pairs(ERenderStyle) do
    if UI.SelectedArtStyle == value then
      isValid = true
      break
    end
  end
  if not isValid then
    UI.SelectedArtStyle = ERenderStyle.Default
  end
end
function logic_setting_graphics.ChangeGraphicsWhenModeSwitch()
  printf("logic_setting_graphics.ChangeGraphicsWhenModeSwitch debugRenderQuality")
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  if not settingConfig.HasGraphicsSeparateConfig then
    printf("logic_setting_graphics.ChangeGraphicsWhenModeSwitch: No Graphics Separate Config")
    return
  end
  local FPS, RenderMSAA, RenderMSAAValue, RenderStyle, RenderQuality
  local gameInstance = logic_setting_graphics.GetGameInstance()
  local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
  local gameInstance = logic_setting_graphics.GetGameInstance()
  local supportRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if not supportRuntime then
    RenderQuality = settingConfig.BattleRenderQuality
    FPS = settingConfig.BattleFPS
    local logic_setting = require("client.logic.setting.logic_setting")
    local Quality = logic_setting.GetQualitySetting()
    if Quality and Quality == ERenderQuality.VERYSMOOTH then
      RenderQuality = ERenderQuality.VERYSMOOTH
      printf("logic_setting_graphics.ChangeGraphicsWhenModeSwitch: Set Quality to Very Smooth")
      logic_setting.SetQualityToVerySmooth(Quality)
    end
    logic_setting.SetQuality_ExtraParam(Quality)
  end
  local nEnhancedLobbyQuality = settingConfig.nEnhancedLobbyQuality
  if GameStatus.IsIn2DLobby() then
    printf("logic_setting_graphics.ChangeGraphicsWhenModeSwitch: Lobby")
    FPS = FPS or settingConfig.LobbyFPS
    RenderMSAA = RenderSettingsApplying.RenderMSAASetting
    RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
    RenderStyle = settingConfig.LobbyRenderStyle
    RenderQuality = RenderQuality or settingConfig.LobbyRenderQuality
    local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
    if nEnhancedLobbyQuality == 1 and not Client.IsEmulator() and not string.find(APILevel, "ES2") then
      printf("logic_setting_graphics.ChangeGraphicsWhenModeSwitch nEnhancedLobbyQuality true")
      local DeviceFPSHDR = gameInstance:GetDeviceFPSHDR()
      local DeviceFPSHigh = gameInstance:GetDeviceFPSHigh()
      local DeviceFPSLow = gameInstance:GetDeviceFPSLow()
      local GradeLevel = Client.GetTCDeviceLevel()
      local bDefaultOpenHDR = 1 < DeviceFPSHDR
      if DeviceFPSHigh < 1 then
        if gameInstance:GetInitMobileContentScaleFactor() < 0.8 then
          gameInstance:SetMobileContentScaleFactorAOS(0.8)
        else
          gameInstance:SetMobileContentScaleFactorAOS(1.1)
        end
      end
      if 1 < DeviceFPSHigh then
        gameInstance:ExecuteCMD("r.EnableLowFPSRender", 0)
        if 61 < DeviceFPSLow or 8 <= GradeLevel then
          gameInstance:ExecuteCMD("r.EnableSSSM", 1)
          gameInstance:ExecuteCMD("r.SSSMMipMaxCascadeNum", 3)
          gameInstance:SetSSSMBoundsScale(1.0)
          gameInstance:SetSSSMBoundsZOffset(0)
          gameInstance:SetDisableSSShadowSoft(false)
        elseif DeviceFPSHDR <= 30 then
          gameInstance:SetMobileContentScaleFactorAOS(1.2)
        end
      end
      if bDefaultOpenHDR and RenderQuality < ERenderQuality.HIGHDEFINITIONPLUS then
        gameInstance:ExecuteCMD("r.BloomKarisAverage", 1)
        gameInstance:ExecuteCMD("r.BloomThreshold", 0.01)
        gameInstance:ExecuteCMD("r.BloomMoreShiningIntensityScale", 5)
      end
      if 31 < DeviceFPSHDR then
        gameInstance:SetMobileContentScaleFactorAOS(1.5)
        if 61 < DeviceFPSLow then
          gameInstance:SetMobileContentScaleFactorIOS(3.0)
        end
      end
      if 1 < DeviceFPSHigh then
        RenderQuality = ERenderQuality.HIGHDEFINITION
      end
      if bDefaultOpenHDR then
        RenderQuality = ERenderQuality.HIGHDEFINITIONPLUS
      end
      if 4 < FPS then
        FPS = 4
      end
    end
    logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
    logic_setting_graphics.SetFPS(gameInstance, FPS)
    logic_setting_graphics.PrintOnScreen(FPS, RenderMSAA, RenderStyle, RenderQuality)
  elseif GameStatus.IsInFightingStatus() or GameStatus.IsInMainCity() then
    printf("logic_setting_graphics.ChangeGraphicsWhenModeSwitch: Battle debugRenderQuality")
    FPS = FPS or GraphicHelperUtil.GetCurrentSceneFPS()
    RenderMSAA = RenderSettingsApplying.RenderMSAASetting
    RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
    RenderStyle = settingConfig.BattleRenderStyle
    RenderQuality = RenderQuality or GraphicHelperUtil.GetCurrentSceneRenderQuality()
    local enableShadow = gameInstance:GetUserSetingShadowQuality()
    local iRendQuality, iFps, bEnableShadow = GraphicHelperUtil.GetCollectRendQualityAndFPS()
    if iRendQuality ~= -1 then
      RenderQuality = iRendQuality
    end
    if iFps ~= -1 then
      FPS = iFps
    end
    if bEnableShadow ~= nil then
      enableShadow = bEnableShadow
    end
    logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
    logic_setting_graphics.SetFPS(gameInstance, FPS)
    logic_setting_graphics.PrintOnScreen(FPS, RenderMSAA, RenderStyle, RenderQuality)
    EventRefreshArtQualityLabel()
    gameInstance:SetUserSetingShadowQuality(enableShadow)
    local enableEnergySaving = gameInstance:GetUserSetingEnergySaving()
    gameInstance:SetUserSetingEnergySaving(enableEnergySaving)
    gameInstance:ExecuteCMD("r.EnableSSSM", 0)
    gameInstance:ExecuteCMD("r.EnableLowFPSRender", 1)
    local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
    local bInFighting = GameStatus.IsInFightingNotSocialNotMainCityNotHome()
    local bIsVerySmooth = RenderQuality == ERenderQuality.VERYSMOOTH
    if bInFighting and bIsVerySmooth and ClientEVOConfig.IsSuperFrameScaleFactorDownEnable() then
      gameInstance:SetMobileContentScaleFactorAOS(0.85)
      printf("ChangeGraphicsWhenModeSwitch: SuperFrameScaleFactorDown -> 0.85")
    else
      gameInstance:SetToInitMobileContentScaleFactor()
      printf("ChangeGraphicsWhenModeSwitch: SetToInitMobileContentScaleFactor")
    end
    gameInstance:ExecuteCMD("r.BloomThreshold", -1)
    gameInstance:ExecuteCMD("r.BloomKarisAverage", 0)
    gameInstance:ExecuteCMD("r.BloomMoreShiningIntensityScale", -1)
  end
end
function logic_setting_graphics.ProcessDefaultSettings()
  printf("logic_setting_graphics.ProcessDefaultSettings")
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  if settingConfig.nEnhancedLobbyQuality == 0 then
    settingConfig.nEnhancedLobbyQuality = (Client.GetExactDeviceLevel() <= 1 or Client.GetMemorySize() <= Client.LowMemoryInGB()) and 2 or 1
    printf("logic_setting_graphics.ProcessDefaultSettings: Set nEnhancedLobbyQuality to %s", settingConfig.nEnhancedLobbyQuality)
  end
  if settingConfig.GraphicFavor == 0 then
    printf("logic_setting_graphics.ProcessDefaultSettings: Set GraphicFavor to Balance")
    settingConfig.GraphicFavor = GraphicConst.FavorDef.Balance
  end
  if settingConfig.LobbyRenderStyle == 0 then
    printf("logic_setting_graphics.ProcessDefaultSettings: Set LobbyRenderStyle to 1")
    settingConfig.LobbyRenderStyle = 1
  end
  if settingConfig.BattleRenderStyle == 0 then
    printf("logic_setting_graphics.ProcessDefaultSettings: Set BattleRenderStyle to 1")
    settingConfig.BattleRenderStyle = 1
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function logic_setting_graphics.DowngradeFpsLevelTemporarily(IsDowngrade, MaxDuration)
  if IsDowngrade then
    local TargetFpsLevel = 7
    local TargetFps = logic_setting_graphics.Level2FpsString(TargetFpsLevel)
    local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local MaxFps = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.MaxFPS")
    while 1 < TargetFpsLevel and not (MaxFps > tonumber(TargetFps)) do
      TargetFpsLevel = TargetFpsLevel - 1
      TargetFps = logic_setting_graphics.Level2FpsString(TargetFpsLevel)
    end
    log(bWriteLog and string.format("DowngradeFpsLevelTemporarily Start. curMaxFPS: %d, targetLevel: %d, set t.OverrideMaxFPS to %s", MaxFps, TargetFpsLevel, TargetFps))
    logic_setting_graphics.ModifyOverrideMaxFPS(TargetFps)
    MaxDuration = MaxDuration or MaxDurationForDowngradeFpsLevel
    local timer_tick = require("common.time_ticker")
    if logic_setting_graphics.DowngradeFpsRecoverTimer then
      timer_tick.RemoveTimer(logic_setting_graphics.DowngradeFpsRecoverTimer)
    end
    logic_setting_graphics.DowngradeFpsRecoverTimer = timer_tick.AddTimerOnce(MaxDuration, function()
      log(bWriteLog and "DowngradeFpsLevelTemporarily Timeout. Reset t.OverrideMaxFPS to 0, MaxDuration: " .. tostring(MaxDuration))
      logic_setting_graphics.ModifyOverrideMaxFPS(0)
    end)
  else
    log(bWriteLog and "DowngradeFpsLevelTemporarily End. Reset t.OverrideMaxFPS to 0")
    logic_setting_graphics.ModifyOverrideMaxFPS(0)
    if logic_setting_graphics.DowngradeFpsRecoverTimer then
      local timer_tick = require("common.time_ticker")
      timer_tick.RemoveTimer(logic_setting_graphics.DowngradeFpsRecoverTimer)
      logic_setting_graphics.DowngradeFpsRecoverTimer = nil
    end
  end
end
function logic_setting_graphics.ModifyOverrideMaxFPS(TargetFPS)
  if tonumber(TargetFPS) == 90 then
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      log(bWriteLog and "ModifyOverrideMaxFPS modify targetFPS from 90 to 80 at IOS")
      TargetFPS = 80
    end
  end
  local gameInstance = logic_setting_graphics.GetGameInstance()
  gameInstance:ExecuteCMD("t.OverrideMaxFPS", TargetFPS)
end
function logic_setting_graphics.NeedTempShutOffMSAA()
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  local Graphics = gameInstance:GetRenderQualityApplying()
  log(bWriteLog and "NeedTempShutOffMSAA Check Start")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "NeedTempShutOffMSAA Device Not IOS")
    return false
  end
  if Graphics.RenderQualitySetting < 4 then
    log(bWriteLog and "NeedTempShutOffMSAA RenderQuality < HDR")
    return false
  end
  if Graphics.RenderMSAASetting == false then
    log(bWriteLog and "NeedTempShutOffMSAA Do not Open MSAA")
    return false
  end
  if not GameStatus.IsIn2DLobby() then
    log(bWriteLog and "NeedTempShutOffMSAA Not In Lobby")
    return false
  end
  log(bWriteLog and "NeedTempShutOffMSAA Need Shut Off")
  return true
end
function logic_setting_graphics.DoTempShutOffMSAA()
  log(bWriteLog and "Tempflag DoTempShutOffMSAA")
  local gameInstance = logic_setting_graphics.GetGameInstance()
  for _, v in pairs(gameInstance.MobileMSAACloseConfig) do
    gameInstance:ExecuteCMD(v.RenderKey, v.RenderValue)
  end
end
function logic_setting_graphics.FixWoWEditorAntiAliasing(gameInstance, RenderMSAA)
  if not IsWoWEditor then
    return
  end
  if RenderMSAA then
    gameInstance:ExecuteCMD("r.DefaultFeature.AntiAliasing", 1)
  end
end
function logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, MSAAValue)
  printf("logic_setting_graphics.SetQuality Quality: %s, Style: %s, MSAA: %s, MSAAValue: %s", RenderQuality, RenderStyle, RenderMSAA, MSAAValue)
  local FRenderQualitySettings = FRenderQualitySettings(RenderQuality or ERenderQuality.Default, RenderStyle, RenderMSAA, MSAAValue)
  local logic_setting = require("client.logic.setting.logic_setting")
  local Quality = logic_setting.GetQualitySetting()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local manager = PufferManager.GetDownloadManager(PufferConst.ENUM_DownloadType.RES)
    if not manager:IsFitShaderExist() then
      FRenderQualitySettings.RenderQualitySetting = 1
      printf("logic_setting_graphics.SetQuality: Set Quality to 1")
    end
  end
  gameInstance:SetRenderQuality(FRenderQualitySettings)
  logic_setting_graphics.FixWoWEditorAntiAliasing(gameInstance, RenderMSAA)
  local enableShadow = gameInstance:GetUserSetingShadowQuality()
  gameInstance:SetUserSetingShadowQuality(enableShadow)
  logic_setting.SetQualityToVerySmooth(FRenderQualitySettings.RenderQualitySetting)
  logic_setting.SetQuality_ExtraParam(FRenderQualitySettings.RenderQualitySetting)
  if logic_setting_graphics.NeedTempShutOffMSAA() then
    logic_setting_graphics.DoTempShutOffMSAA()
  end
  local SetStreamingPoolSizeOnSetting = HDmpveRemote.HDmpveRemoteConfigGetInt("SetStreamingPoolSizeOnSetting", 0)
  if 0 < SetStreamingPoolSizeOnSetting then
    gameInstance:ExecuteCMD("r.Streaming.PoolSize", SetStreamingPoolSizeOnSetting)
    gameInstance:ExecuteCMD("r.Streaming.AdditionalPoolSize", 0)
  end
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  local bInFighting = GameStatus.IsInFightingNotSocialNotMainCityNotHome()
  local bIsVerySmooth = FRenderQualitySettings.RenderQualitySetting == ERenderQuality.VERYSMOOTH
  if bInFighting and bIsVerySmooth and ClientEVOConfig.IsSuperFrameScaleFactorDownEnable() then
    gameInstance:SetMobileContentScaleFactorAOS(0.85)
    printf("SetQuality: SuperFrameScaleFactorDown -> 0.85")
  elseif bInFighting and not bIsVerySmooth and ClientEVOConfig.IsSuperFrameScaleFactorDownEnable() then
    gameInstance:SetToInitMobileContentScaleFactor()
    printf("SetQuality: SuperFrameScaleFactorDown disabled, restore init")
  end
end
function logic_setting_graphics.GetBattleFPS_CloudGame(FPSLevel)
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  local fpsLevelMap = {
    [1] = 15,
    [2] = 20,
    [3] = 25,
    [4] = 30,
    [5] = 40,
    [6] = 60,
    [7] = 90,
    [8] = 120
  }
  return fpsLevelMap[FPSLevel or settingConfig.BattleFPS] or 30
end
function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    local AssetCostSubSystem = SubsystemMgr:Get("CreativeModeAssetCostSubSystem")
    if AssetCostSubSystem and AssetCostSubSystem:IsExtremeMap() then
      log(bWriteLog and "logic_setting_graphics:SetFPS ExtremeMap Can not Change FPS")
      return
    end
  end
  printf("logic_setting_graphics.SetFPS debugFPS FPSLevel: %s", FPSLevel)
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  local StrFPS = logic_setting_graphics.Level2FpsString(FPSLevel)
  local renderApplying = gameInstance:GetRenderQualityApplying()
  if renderApplying.RenderQualitySetting == ERenderQuality.VERYSMOOTH then
    local nFPS = tonumber(StrFPS)
    local ret = gameInstance:IsPartlyImproveFPSInVerySmooth(nFPS)
    if ret then
      if nFPS == 40 then
        nFPS = 35
      elseif nFPS == 60 then
        nFPS = 50
      end
      StrFPS = tostring(nFPS)
      printf("logic_setting_graphics.SetFPS debugFPS IsPartlyImproveFPSInVerySmooth after: %s", nFPS)
    end
  end
  if FPSLevel == 6 then
    gameInstance:ExecuteCMD("Jank.CollectionTimeThresholdNoRelease", 40)
  elseif FPSLevel == 7 then
    gameInstance:ExecuteCMD("Jank.CollectionTimeThresholdNoRelease", 25)
  elseif FPSLevel == 8 then
    gameInstance:ExecuteCMD("Jank.CollectionTimeThresholdNoRelease", 25)
    if settingConfig.FPSFineTuneSwitch then
      local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
      local IsIOS = Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS
      StrFPS = tostring(settingConfig.FPSFineTuneNum)
      if IsIOS and settingConfig.FPSFineTuneNum == 90 then
        StrFPS = "91"
      end
    else
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local ModeID = GameMainConfig.GetModeID()
      local IsThemeBRMode = GamePlayTools.IsThemeBRMode(ModeID)
      local RecommendFPS = gameInstance:GetDeviceRecommendFPS()
      StrFPS = tostring(RecommendFPS)
    end
  end
  local GraphicsNewData = require("client.slua.umg.NewSetting.GraphicsNew.GraphicsNewData")
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local game_mode = logic_enter_game:GetSubModeId()
  if GameStatus.IsInFightingStatus() and game_mode and GraphicsNewData.LockFPSMod4High[game_mode] and settingConfig.BattleRenderQuality >= GraphicsNewData.LockFPSMod4High.Quality then
    StrFPS = tostring(math.min(GraphicsNewData.LockFPSMod4High.FPS, tonumber(StrFPS)))
  end
  if GameStatus.IsInFightingStatus() then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uGameState = GameplayData.GetGameState()
    if Game:IsValid(uGameState) and uGameState.RoomType == "match" and uGameState.MaxFPSInMatch and uGameState.MaxFPSInMatch > 0 then
      local nStrFPS = tonumber(StrFPS)
      if nStrFPS and nStrFPS > uGameState.MaxFPSInMatch then
        StrFPS = tostring(uGameState.MaxFPSInMatch)
        printf("logic_setting_graphics.SetFPS debugFPS clamp to MaxFPSInMatch: %s", StrFPS)
      end
    end
  end
  printf("logic_setting_graphics.SetFPS debugFPS StrFPS: %s", StrFPS)
  gameInstance:ExecuteCMD("t.MaxFPS", StrFPS)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    TApmHelper.PostGameStatusToTGPAIS(7, StrFPS)
  end
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  ClientEVOConfig.OnPostSetFPS(FPSLevel)
end
function logic_setting_graphics.PrintOnScreen(FPS, RenderMSAA, RenderStyle, RenderQuality)
  if Client.IsShipping() then
    return
  end
  if logic_setting_graphics.PrintInfoWhenSetGraphics then
    ScriptHelperClient.ShowScreenDebugMessage(string.format("FPS : %s", FPS))
    ScriptHelperClient.ShowScreenDebugMessage(string.format("MSAA : %s", RenderMSAA))
    ScriptHelperClient.ShowScreenDebugMessage(string.format("Style : %s", RenderStyle))
    ScriptHelperClient.ShowScreenDebugMessage(string.format("Quality : %s", RenderQuality))
  end
end
function logic_setting_graphics.GetGraphicsSeparateRedPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGraphicsSeparate)
  data = data or {
    LobbyRed = true,
    BattleRed = true,
    ManorRed = true
  }
  return data
end
function logic_setting_graphics.HasSuperHighRedPoint()
  local gameInstance = logic_setting_graphics.GetGameInstance()
  if gameInstance and (gameInstance:GetDeviceMaxSupportLevel() < ERenderQuality.ULTRAHIGHDEFINITION or gameInstance:GetDeviceMaxSupportLevel() == ERenderQuality.VERYSMOOTH) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSettingSuperHigh)
  if not data or data.redPoint then
    return true
  else
    return false
  end
end
function logic_setting_graphics.HasGraphicsSeparateRedPoint()
  if not logic_setting_graphics.GraphicsSeparate() then
    return false
  end
  if logic_setting_graphics.HasSuperHighRedPoint() then
    return true
  end
  local data = logic_setting_graphics.GetGraphicsSeparateRedPoint()
  if data.LobbyRed or data.BattleRed then
    return true
  else
    return false
  end
end
function logic_setting_graphics.SetUltraHighRedPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({redPoint = false}, PlayerPrefsSystem.ePlayerPrefsType.eSettingSuperHigh)
end
function logic_setting_graphics.SetGraphicsSeparateRedPoint(Type)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = logic_setting_graphics.GetGraphicsSeparateRedPoint()
  if Type == LOBBY then
    data.LobbyRed = false
  elseif Type == BATTLE then
    data.BattleRed = false
  elseif Type == MANOR then
    data.ManorRed = false
  end
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eGraphicsSeparate)
end
function logic_setting_graphics.MountQualityPak(renderQuality)
  local gameInstance = logic_setting_graphics.GetGameInstance()
  if gameInstance and gameInstance:GetDeviceMaxSupportLevel() >= ERenderQuality.ULTRAHIGHDEFINITION and renderQuality == ERenderQuality.ULTRAHIGHDEFINITION then
    logic_setting_graphics.MountPakFile()
  else
    logic_setting_graphics.UnmountPakFile()
  end
end
function logic_setting_graphics.MountPakFile()
  log(bWriteLog and "[LogicSettingGraphics] Mount Pak File")
  local path = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. "res_baltichd_" .. Client.GetApplicationVersion() .. ".pak"
  Client.MountPakFile(path, "")
end
function logic_setting_graphics.UnmountPakFile()
  log(bWriteLog and "[LogicSettingGraphics] Unmount Pak File")
  local path = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. "res_baltichd_" .. Client.GetApplicationVersion() .. ".pak"
  Client.UnmountPakFile(path)
end
function logic_setting_graphics.SetNegativePlayGuideFlag(isNegative)
  log(bWriteLog and "[v_wllwu] logic_setting_graphics.SetNegativePlayGuideFlag, isNegative = " .. tostring(isNegative))
  logic_setting_graphics.bNegativePlay = isNegative
end
function logic_setting_graphics.CanPopNegativePlayGuide(isPopLobbyUI)
  if logic_setting_graphics.bNegativePlay then
    log(bWriteLog and "[v_wllwu] logic_setting_graphics.CanPopNegativePlayGuide return true, force bNegativePlay ")
    return true
  end
  log(bWriteLog and "[v_wllwu] logic_setting_graphics.CanPopNegativePlayGuide, isPopLobbyUI = " .. tostring(isPopLobbyUI))
  local preLossMacros = require("client.logic.pre_loss.pre_loss_macros")
  local logic_pre_loss = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_pre_loss)
  local isCanShow
  if isPopLobbyUI then
    isCanShow = logic_pre_loss:CanShowDisPlayTypeUI(preLossMacros.Display_Type.SettingGuide)
  else
    isCanShow = logic_pre_loss:IsPreLossDisPlayTypeExist(preLossMacros.Display_Type.SettingGuide)
  end
  if not isCanShow then
    log(bWriteLog and "[v_wllwu] logic_setting_graphics.CanPopNegativePlayGuide return false, proto not canShow ")
    return
  end
  local selectedQuality = logic_setting_graphics.GetRenderQuality(BATTLE)
  log(bWriteLog and "[v_wllwu] logic_setting_graphics.CanPopNegativePlayGuide, selectedQuality = " .. tostring(selectedQuality))
  if selectedQuality == ERenderQuality.Default or selectedQuality == ERenderQuality.SMOOTH or selectedQuality == ERenderQuality.VERYSMOOTH then
    log(bWriteLog and "[v_wllwu] logic_setting_graphics.CanPopNegativePlayGuide return false, ERenderQuality has set minimum ")
    return
  end
  log(bWriteLog and "[v_wllwu] logic_setting_graphics.CanPopNegativePlayGuide return true")
  return true
end
function logic_setting_graphics.PopNegativePlayGuide()
  if not logic_setting_graphics.CanPopNegativePlayGuide(true) then
    return
  end
  local content = LocUtil.GetLocalizeResStr(44807)
  local jumpBtnInfo = {}
  function jumpBtnInfo.callback()
    log(bWriteLog and "[v_wllwu] logic_setting_graphics.PopNegativePlayGuide")
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    SettingUtil.Enter("Graphic")
  end
  local autoHideTime = 10
  local cfg = CDataTable.GetTableData("PreventLoseParamsCfg", "setting_guide_pop_time")
  if cfg then
    autoHideTime = cfg.ParamValue
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  RightPopSystem.ShowPopupTip(content, true, false, jumpBtnInfo, autoHideTime)
end
function logic_setting_graphics.SetToUltraHDR()
  local quality = import("ERenderQuality").ULTRAHIGHDEFINITION
  log(bWriteLog and "  : ULTRAHIGHDEFINITION is quality " .. tostring(quality))
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  logic_setting_graphics.SaveSeparatedGraphicsSettings(0, settingConfig.BattleFPS, quality, settingConfig.BattleRenderStyle)
  logic_setting_graphics.SaveSeparatedGraphicsSettings(1, settingConfig.LobbyFPS, quality, settingConfig.LobbyRenderStyle)
end
function logic_setting_graphics.SetToHighDefinition()
  local quality = import("ERenderQuality").HIGHDEFINITIONPLUS
  log(bWriteLog and "  : HIGHDEFINITION is quality " .. tostring(quality))
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  logic_setting_graphics.SaveSeparatedGraphicsSettings(0, settingConfig.BattleFPS, quality, settingConfig.BattleRenderStyle)
  logic_setting_graphics.SaveSeparatedGraphicsSettings(1, settingConfig.LobbyFPS, quality, settingConfig.LobbyRenderStyle)
end
function logic_setting_graphics.GetSettingByState(state)
  log(bWriteLog and "logic_setting_graphics.GetSettingByState state = " .. tostring(state))
  local SelectedFPS, SelectedStyle, SelectedQuality
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  local gameInstance = logic_setting_graphics.GetGameInstance()
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    if state == BATTLE then
      log(bWriteLog and "logic_setting_graphics.GetSettingByState BATTLE")
      SelectedFPS = settingConfig.BattleFPS
      SelectedStyle = settingConfig.BattleRenderStyle
      SelectedQuality = settingConfig.BattleRenderQuality
    elseif state == LOBBY then
      log(bWriteLog and "logic_setting_graphics.GetSettingByState LOBBY")
      SelectedFPS = settingConfig.LobbyFPS
      SelectedStyle = settingConfig.LobbyRenderStyle
      SelectedQuality = settingConfig.LobbyRenderQuality
    elseif state == MANOR then
      log(bWriteLog and "logic_setting_graphics.GetSettingByState MANOR")
      SelectedFPS = settingConfig.BattleFPS
      SelectedStyle = settingConfig.BattleRenderStyle
      SelectedQuality = settingConfig.ManorRenderQuality or settingConfig.BattleRenderQuality
    elseif state == MAIN_CITY then
      log(bWriteLog and "logic_setting_graphics.GetSettingByState MAINCITY")
      SelectedFPS = settingConfig.MainCityFPS
      SelectedStyle = settingConfig.BattleRenderStyle
      SelectedQuality = settingConfig.MainCityRenderQuality
    else
      log(bWriteLog and "logic_setting_graphics.GetSettingByState NORMAL")
      local renderQuality = gameInstance:GetRenderQualityApplying()
      SelectedFPS = settingConfig.FPSLevel
      SelectedStyle = renderQuality.RenderStyleSetting
      SelectedQuality = renderQuality.RenderQualitySetting
    end
  else
    printf("logic_setting_graphics.GetSettingByState IsSupportSwitchRenderLevelRuntime false")
    local renderQuality = gameInstance:GetRenderQualityApplying()
    SelectedFPS = settingConfig.FPSLevel
    SelectedStyle = renderQuality.RenderStyleSetting
    SelectedQuality = renderQuality.RenderQualitySetting
  end
  log(bWriteLog and "logic_setting_graphics.GetSettingByState SelectedFPS = " .. tostring(SelectedFPS) .. " SelectedStyle = " .. tostring(SelectedStyle) .. " SelectedQuality = " .. tostring(SelectedQuality))
  return SelectedFPS, SelectedStyle, SelectedQuality
end
function logic_setting_graphics.InitializeUserSetting()
  printf("logic_setting_graphics.InitializeUserSetting dbgGraphicSetting")
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_SWITCH_NEW_SETTING_GRAPHICS, logic_setting_graphics.ShowNewSettingPopup)
  if slua_GameFrontendHUD then
    slua_GameFrontendHUD:BeginModifyUserSettings()
    local saveGame = slua_GameFrontendHUD:GetUserSettings()
    if saveGame ~= nil then
      logic_setting_graphics.InitMicAndSpeakerVolum(saveGame)
      logic_setting_graphics.InitGraphicsSettings(saveGame)
      logic_setting_graphics.InitSoundSetting(saveGame)
    else
      log_shipping_client("logic_setting_graphics.InitializeUserSetting saveGame is nil")
    end
  end
end
function logic_setting_graphics.InitGraphicsSettings(saveGame)
  printf("logic_setting_graphics.InitGraphicsSettings start")
  local gameInstance = logic_setting_graphics.GetGameInstance()
  gameInstance:ExecuteCMD("r.Mobile.Brightness", tostring(saveGame.ScreenLightness))
  local GraphicFavor = saveGame.GraphicFavor
  if GraphicFavor ~= 0 and GraphicFavor ~= GraphicConst.FavorDef.Custom then
    local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicFavor)
    if GraphicFavor == GraphicConst.FavorDef.BestQuality then
      favorSetting.LobbyRenderQuality = saveGame.LobbyRenderQuality
      favorSetting.BattleRenderQuality = saveGame.BattleRenderQuality
    end
    if GraphicFavor == GraphicConst.FavorDef.FrameRate then
      favorSetting.FPSAutoInterpolation = saveGame.FPSAutoInterpolation
    end
    logic_setting_graphics.ApplyFavorSettings(favorSetting, GraphicFavor)
  end
  logic_setting_graphics.InitRenderQuality(saveGame.FPSLevel)
end
function logic_setting_graphics.ShowNewSettingPopup()
  printf("logic_setting_graphics.ShowNewSettingPopup")
  UIManager.ShowUI(UIManager.UI_Config.Setting_Picture_Popup_UIBP)
end
function logic_setting_graphics.InitMicAndSpeakerVolum(saveGame)
  log_warning(bWriteLog and "login_module:InitMicAndSpeakerVolum, before MicphoneVolumSwitcher = " .. tostring(saveGame.MicphoneVolumSwitcher))
  saveGame.MicphoneVolumSwitcher = false
  log_warning(bWriteLog and "login_module:InitMicAndSpeakerVolum,  after MicphoneVolumSwitcher = " .. tostring(saveGame.MicphoneVolumSwitcher))
  saveGame.VoiceChannel = 1
  slua_GameFrontendHUD:FinishModifyUserSettings()
  local antsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if antsVoiceInterface ~= nil then
    antsVoiceInterface:SetMicphoneStatus(saveGame.MicphoneVolumSwitcher)
    antsVoiceInterface:SetMicphoneVolum(saveGame.MicphoneVolumValue)
    antsVoiceInterface:SetSpeakerStatus(saveGame.SpeakerVolumSwitcher)
    antsVoiceInterface:SetSpeakerVolum(saveGame.SpeakerVolumValue)
    antsVoiceInterface:SetLbsRoomEnableStatus(saveGame.VoiceChannel == 2)
  end
end
function logic_setting_graphics.Level2FpsString(FPSLevel)
  local StrFPS = "20"
  if FPSLevel == 1 then
    StrFPS = "15"
  elseif FPSLevel == 2 then
    StrFPS = "20"
  elseif FPSLevel == 3 then
    StrFPS = "25"
  elseif FPSLevel == 4 then
    StrFPS = "30"
  elseif FPSLevel == 5 then
    StrFPS = "40"
  elseif FPSLevel == 6 then
    StrFPS = "60"
  elseif FPSLevel == 7 then
    StrFPS = "90"
  elseif FPSLevel == 8 then
    StrFPS = "120"
  end
  return StrFPS
end
function logic_setting_graphics.InitSoundSetting(saveGame)
  local AkGameplayStatics = import("AkGameplayStatics")
  local audio_util = require("client.common.audio_util")
  if saveGame.MainVolumSwitcher then
    audio_util.SetRTPCValue("VolumeControl", saveGame.MainVolumValue * 100, 0)
  else
    audio_util.SetRTPCValue("VolumeControl", 0, 0)
  end
  if saveGame.EffectVolumSwitcher then
    audio_util.SetRTPCValue("VolumeControl_SFX", saveGame.EffectVolumValue * 100, 0)
  else
    audio_util.SetRTPCValue("VolumeControl_SFX", 0, 0)
  end
  if saveGame.UIVolumSwitcher then
    audio_util.SetRTPCValue("VolumeControl_UI", saveGame.UIVolumValue * 100, 0)
  else
    audio_util.SetRTPCValue("VolumeControl_UI", 0, 0)
  end
  if saveGame.BGMVolumSwitcher then
    audio_util.SetRTPCValue("VolumeControl_Music", saveGame.BGMVolumValue * 100, 0)
  else
    audio_util.SetRTPCValue("VolumeControl_Music", 0, 0)
  end
  audio_util.SetRTPCValue("Weapon_Volume", saveGame.WeaponVolumValue * 100, 0)
  audio_util.SetRTPCValue("Vehicle_Volume", saveGame.VehicleVolumValue * 100, 0)
  audio_util.SetRTPCValue("Voice_Volume", saveGame.VoiceVolumValue * 100, 0)
  if saveGame.BGMVolumSwitcher then
    audio_util.SetRTPCValue("MusicPlayer_Volume", saveGame.BGMVolumValue, 0)
  else
    audio_util.SetRTPCValue("MusicPlayer_Volume", 0, 0)
  end
  AkGameplayStatics.StopAll()
  local AkAudioSystem = require("client.slua.logic.audio.logic_ak_audio")
  AkAudioSystem.SetupWWiseSilenceMode()
end
function logic_setting_graphics.InitRenderQuality(FPSLevel)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  local UIUtil = require("client.common.ui_util")
  local STExtraGameInstance = UIUtil.GetGameInstance()
  if STExtraGameInstance ~= nil then
    local tempValue = 0
    local RenderQuality = STExtraGameInstance:GetRenderQualityApplying()
    if RenderQuality ~= nil then
      tempValue = (RenderQuality.RenderQualitySetting + 1) * 1000
      tempValue = tempValue + RenderQuality.RenderStyleSetting * 100
      tempValue = tempValue + FPSLevel * 10
      if RenderQuality.RenderMSAASetting == true then
        tempValue = tempValue + 1
      else
        tempValue = tempValue + 0
      end
    end
    local result = STExtraGameInstance:GetApplyingShadowQuality()
    if result == true then
      tempValue = tempValue + 20000
    else
      tempValue = tempValue + 10000
    end
    log_warning(bWriteLog and "Login_UIBP:InitRenderQuality, SetQuality(" .. tostring(tempValue) .. ")")
    if strRegion ~= PublishRegionMacros.BLUEHOLE then
      local TApmHelper = import("TApmHelper")
      TApmHelper.SetQuality(tempValue)
    end
  end
end
function logic_setting_graphics:SetManorGraphicsSetting()
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
  if not settingConfig or not RenderSettingsApplying then
    return
  end
  local RenderStyle = settingConfig.BattleRenderStyle
  local RenderQuality = settingConfig.ManorRenderQuality or settingConfig.BattleRenderQuality
  local RenderMSAA = RenderSettingsApplying.RenderMSAASetting
  local RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
  local gameInstance = logic_setting_graphics.GetGameInstance()
  logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
  log(bWriteLog and string.format("SetManorGraphicsSetting. Style = %s, Quality = %s", tostring(RenderStyle), tostring(RenderQuality)))
end
function logic_setting_graphics:SetHallGraphicsSetting()
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
  if not settingConfig or not RenderSettingsApplying then
    return
  end
  local RenderStyle = settingConfig.BattleRenderStyle
  local RenderQuality = settingConfig.HallRenderQuality or settingConfig.BattleRenderQuality
  local RenderMSAA = RenderSettingsApplying.RenderMSAASetting
  local RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
  local gameInstance = logic_setting_graphics.GetGameInstance()
  local iRendQuality, iFps, bEnableShadow = GraphicHelperUtil.GetCollectRendQualityAndFPS()
  if iRendQuality ~= -1 then
    RenderQuality = iRendQuality
  end
  local FPS = settingConfig.FPSLevel
  if iFps ~= -1 then
    FPS = iFps
  end
  local enableShadow = true
  if bEnableShadow ~= nil then
    enableShadow = bEnableShadow
  end
  logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
  logic_setting_graphics.SetFPS(gameInstance, FPS)
  gameInstance:SetUserSetingShadowQuality(enableShadow)
  log(bWriteLog and string.format("SetHallGraphicsSetting. Style = %s, Quality = %s", tostring(RenderStyle), tostring(RenderQuality)))
end
function logic_setting_graphics.ApplyFavorSettings(favorSetting, GraphicFavor)
  local t1 = slua.getMiliseconds()
  local gameInstance = logic_setting_graphics.GetGameInstance()
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
  printf("logic_setting_graphics.ApplyFavorSettings GraphicFavor = %s, t1 = %s", GraphicFavor, t1)
  if not favorSetting then
    GraphicSettingDB:SaveChanges({GraphicFavor = GraphicFavor})
    return
  end
  GraphicSettingDB:SaveChanges(favorSetting)
  local RenderMSAASetting = favorSetting.RenderMSAASetting
  local RenderMSAAValue = favorSetting.RenderMSAAValue
  local RenderSettings = logic_setting_graphics.GetRenderSettingsApplying()
  local RenderStyle = favorSetting.BattleRenderStyle or RenderSettings.RenderStyleSetting
  local toSetRenderQuality = favorSetting.LobbyRenderQuality
  local toSetFPSLevel = favorSetting.LobbyFPS
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bSupportSwitchRenderLevelRuntime then
    if GameStatus.IsIn2DLobby() then
      toSetRenderQuality = favorSetting.LobbyRenderQuality
      toSetFPSLevel = favorSetting.LobbyFPS
      RenderStyle = favorSetting.LobbyRenderStyle or RenderStyle
      printf("logic_setting_graphics.ApplyFavorSettings IsIn2DLobby. toSetRenderQuality = %s, toSetFPSLevel = %s", toSetRenderQuality, toSetFPSLevel)
    elseif GameStatus.IsInFightingStatus() then
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      local IsPHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
      local IsInMainCity = GameStatus.IsInMainCity()
      if IsPHomeMode then
        toSetRenderQuality = favorSetting.ManorRenderQuality
        toSetFPSLevel = favorSetting.BattleFPS
        printf("logic_setting_graphics.ApplyFavorSettings IsPHomeMode. toSetRenderQuality = %s, toSetFPSLevel = %s", toSetRenderQuality, toSetFPSLevel)
      elseif IsInMainCity then
        toSetRenderQuality = favorSetting.MainCityRenderQuality
        toSetFPSLevel = favorSetting.MainCityFPS
        printf("logic_setting_graphics.ApplyFavorSettings IsInMainCity. toSetRenderQuality = %s, toSetFPSLevel = %s", toSetRenderQuality, toSetFPSLevel)
      else
        toSetRenderQuality = favorSetting.BattleRenderQuality
        toSetFPSLevel = favorSetting.BattleFPS
        printf("logic_setting_graphics.ApplyFavorSettings IsInFightingStatus. toSetRenderQuality = %s, toSetFPSLevel = %s", toSetRenderQuality, toSetFPSLevel)
      end
    end
  else
    toSetRenderQuality = favorSetting.BattleRenderQuality
    toSetFPSLevel = favorSetting.BattleFPS
    printf("logic_setting_graphics.ApplyFavorSettings bSupportSwitchRenderLevelRuntime false. toSetRenderQuality = %s, toSetFPSLevel = %s", toSetRenderQuality, toSetFPSLevel)
  end
  local iRendQuality, iFps = GraphicHelperUtil.GetCollectRendQualityAndFPS()
  if iRendQuality ~= -1 then
    toSetRenderQuality = iRendQuality
  end
  if iFps ~= -1 then
    toSetFPSLevel = iFps
  end
  logic_setting_graphics.SetQuality(gameInstance, toSetRenderQuality, RenderStyle, RenderMSAASetting, RenderMSAAValue)
  settingConfig.FPSLevel = toSetFPSLevel
  logic_setting_graphics.SetFPS(gameInstance, toSetFPSLevel)
  local t2 = slua.getMiliseconds()
  printf("logic_setting_graphics.ApplyFavorSettings GraphicFavor = %d, end = %d, cost = %d", GraphicFavor, t2, t2 - t1)
end
function logic_setting_graphics.EnterEnhancedLobbyQuality()
  printf("logic_setting_graphics.EnterEnhancedLobbyQuality")
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  if not settingConfig.HasGraphicsSeparateConfig then
    printf("logic_setting_graphics.EnterEnhancedLobbyQuality: No Graphics Separate Config")
    return
  end
  if Client.GetMemorySize() <= Client.LowMemoryInGB() then
    return
  end
  local gameInstance = logic_setting_graphics.GetGameInstance()
  if not gameInstance:IsSupportSpecialLobbyQuality() then
    return
  end
  local supportRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if not supportRuntime then
    return
  end
  local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
  if Client.IsEmulator() or string.find(APILevel, "ES2") then
    return
  end
  local nEnhancedLobbyQuality = settingConfig.nEnhancedLobbyQuality
  local DeviceFPSHDR = gameInstance:GetDeviceFPSHDR()
  local DeviceFPSHigh = gameInstance:GetDeviceFPSHigh()
  local bDefaultOpenHDR = 1 < DeviceFPSHDR
  printf("logic_setting_graphics.EnterEnhancedLobbyQuality Success %s", nEnhancedLobbyQuality)
  if nEnhancedLobbyQuality ~= 1 then
    printf("logic_setting_graphics.EnterEnhancedLobbyQuality not nEnhancedLobbyQuality")
    local FPS, RenderMSAA, RenderMSAAValue, RenderStyle, RenderQuality
    local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
    FPS = FPS or settingConfig.LobbyFPS
    RenderMSAA = RenderSettingsApplying.RenderMSAASetting
    RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
    RenderStyle = settingConfig.LobbyRenderStyle
    RenderQuality = RenderQuality or settingConfig.LobbyRenderQuality
    if bDefaultOpenHDR and RenderQuality < ERenderQuality.HIGHDEFINITIONPLUS then
      gameInstance:ExecuteCMD("r.BloomKarisAverage", 1)
      gameInstance:ExecuteCMD("r.BloomThreshold", 0.01)
      gameInstance:ExecuteCMD("r.BloomMoreShiningIntensityScale", 5)
    end
    if 1 < DeviceFPSHigh then
      RenderQuality = ERenderQuality.HIGHDEFINITION
    end
    if bDefaultOpenHDR then
      RenderQuality = ERenderQuality.HIGHDEFINITIONPLUS
    end
    logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
    logic_setting_graphics.PrintOnScreen(FPS, RenderMSAA, RenderStyle, RenderQuality)
  end
end
function logic_setting_graphics.ExitEnhancedLobbyQuality()
  printf("logic_setting_graphics.ExitEnhancedLobbyQuality")
  local settingConfig = logic_setting_graphics.GetSettingConfig()
  if not settingConfig.HasGraphicsSeparateConfig then
    printf("logic_setting_graphics.ExitEnhancedLobbyQuality: No Graphics Separate Config")
    return
  end
  if Client.GetMemorySize() <= Client.LowMemoryInGB() then
    return
  end
  local gameInstance = logic_setting_graphics.GetGameInstance()
  if not gameInstance:IsSupportSpecialLobbyQuality() then
    return
  end
  local supportRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if not supportRuntime then
    return
  end
  local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
  if Client.IsEmulator() or string.find(APILevel, "ES2") then
    return
  end
  local nEnhancedLobbyQuality = settingConfig.nEnhancedLobbyQuality
  if nEnhancedLobbyQuality ~= 1 then
    local FPS, RenderMSAA, RenderMSAAValue, RenderStyle, RenderQuality
    local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
    FPS = FPS or GraphicHelperUtil.GetCurrentSceneFPS()
    RenderMSAA = RenderSettingsApplying.RenderMSAASetting
    RenderMSAAValue = RenderSettingsApplying.RenderMSAAValue
    RenderStyle = settingConfig.BattleRenderStyle
    RenderQuality = RenderQuality or GraphicHelperUtil.GetCurrentSceneRenderQuality()
    logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
    logic_setting_graphics.PrintOnScreen(FPS, RenderMSAA, RenderStyle, RenderQuality)
    gameInstance:ExecuteCMD("r.BloomThreshold", -1)
    gameInstance:ExecuteCMD("r.BloomKarisAverage", 0)
    gameInstance:ExecuteCMD("r.BloomMoreShiningIntensityScale", -1)
  end
end
return logic_setting_graphics