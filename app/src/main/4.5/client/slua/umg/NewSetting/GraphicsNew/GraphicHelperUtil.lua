local GraphicHelperUtil = {}
local UIUtil = require("client.common.ui_util")
local ERenderQuality = import("ERenderQuality")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local FPSNum2Level = {
  [15] = 1,
  [20] = 2,
  [25] = 3,
  [30] = 4,
  [40] = 5,
  [60] = 6,
  [90] = 7,
  [120] = 8
}
function GraphicHelperUtil.CanCombatStateSwitchQuality(quality)
  if GameStatus.IsInLobbyOrMainCity() then
    printf("GraphicHelperUtil.CanCombatStateSwitchQuality IsLobbyOrMainCity")
    return true
  end
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  local renderQuality = LogicSettingGraphics.GetRenderSettingsApplying().RenderQualitySetting
  if renderQuality == ERenderQuality.ULTRAHIGHDEFINITION or quality == ERenderQuality.ULTRAHIGHDEFINITION then
    ShowNotice(35067)
    return false
  end
  return true
end
function GraphicHelperUtil.CanChangeArtQuality(quality)
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  if GameStatus.IsInLobbyOrMainCity() then
    printf("GraphicHelperUtil.CanChangeArtQuality IsLobbyOrMainCity")
    if not PufferDownloader.PufferJsonDownloadReturn and quality and quality >= ERenderQuality.ULTRAHIGHDEFINITION and quality ~= ERenderQuality.VERYSMOOTH then
      local fileName = "res_baltichd_" .. Client.GetApplicationVersion() .. ".pak"
      local realFileName = PufferDownloader.GetRealFilename(fileName)
      if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFileName) then
        return true
      elseif not _G.IsEditor and not Client.IsWindows() then
        ShowNotice(301239)
        return true
      end
    end
  else
    printf("GraphicHelperUtil.CanChangeArtQuality IsCombatState")
    local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
    local renderQuality = LogicSettingGraphics.GetRenderSettingsApplying().RenderQualitySetting
    if renderQuality == ERenderQuality.ULTRAHIGHDEFINITION or quality == ERenderQuality.ULTRAHIGHDEFINITION then
      ShowNotice(35067)
      return false
    end
    if quality and quality == ERenderQuality.HIGHDEFINITION then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      if PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {
        "res_maptexmd"
      }) ~= PufferConst.ENUM_DownloadState.Done then
        printf("GraphicHelperUtil.CanChangeArtQuality quality = %s", quality)
        ShowNotice(512307)
        return false
      end
    end
  end
  return true
end
function GraphicHelperUtil.ShouldShowEnergySavingBtn()
  local UIUtil = require("client.common.ui_util")
  local deviceLevel = UIUtil.GetGameInstance():GetDeviceLevel()
  if deviceLevel < 2 then
    return false
  end
  return true
end
function GraphicHelperUtil.ShouldShowShadowBtn()
  local Quality = GraphicHelperUtil.GetCurrentSceneRenderQuality()
  if Quality > ERenderQuality.SMOOTH and Quality ~= ERenderQuality.VERYSMOOTH then
    local USmartBearerManagerBPLibrary = import("SmartBearerManagerBPLibrary")
    if USmartBearerManagerBPLibrary.IsSuperFrameOptSwitcherEnable(28) then
      local STExtraGameInstance = import("STExtraGameInstance")
      local GameInstance = STExtraGameInstance.GetInstance()
      local nDeviceLevel = GameInstance:GetExactDeviceLevel()
      local UserShadowQuality = GameInstance:GetUserSetingShadowQuality()
      printf("GraphicHelperUtil.ShouldShowShadowBtn nDeviceLevel = %s, UserShadowQuality = %s", nDeviceLevel, UserShadowQuality)
      if nDeviceLevel < 0 then
        if UserShadowQuality then
          return true
        else
          return false
        end
      else
        return true
      end
    else
      printf("GraphicHelperUtil.ShouldShowShadowBtn IsSuperFrameOptSwitcherEnable false")
      return true
    end
  else
    printf("GraphicHelperUtil.ShouldShowShadowBtn Quality is low. Quality = %s", Quality)
    return false
  end
end
function GraphicHelperUtil.IsSupportHDR()
  local gameInstance = UIUtil.GetGameInstance()
  local isSupportHDR = gameInstance:GetDeviceMaxSupportLevel() >= ERenderQuality.HIGHDEFINITIONPLUS
  return isSupportHDR
end
function GraphicHelperUtil.GetCurrentSceneRenderQuality()
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  local gameInstance = UIUtil.GetGameInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bSupportSwitchRenderLevelRuntime then
    local Quality
    local gameStatus = GameStatus.GetGameStatus()
    if GameStatus.IsIn2DLobby() then
      Quality = logic_setting_graphics.GetRenderQuality(1)
      printf("GraphicHelperUtil.GetCurrentSceneRenderQuality Lobby. Quality:%s", Quality)
      return Quality
    elseif GameStatus.IsInMainCity() then
      Quality = logic_setting_graphics.GetRenderQuality(3)
      printf("GraphicHelperUtil.GetCurrentSceneRenderQuality MainCity. Quality:%s", Quality)
      return Quality
    elseif GameStatus.IsInFightingStatus() then
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      local IsPHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
      if IsPHomeMode then
        Quality = logic_setting_graphics.GetRenderQuality(2)
        printf("GraphicHelperUtil.GetCurrentSceneRenderQuality PHomeMode. Quality:%s", Quality)
        return Quality
      elseif GameStatus.IsInMainCity() then
        Quality = logic_setting_graphics.GetRenderQuality(3)
        printf("GraphicHelperUtil.GetCurrentSceneRenderQuality MainCity. Quality:%s", Quality)
        return Quality
      else
        Quality = logic_setting_graphics.GetRenderQuality(0)
        printf("GraphicHelperUtil.GetCurrentSceneRenderQuality Battle. Quality:%s", Quality)
        return Quality
      end
    end
    Quality = logic_setting_graphics.GetRenderQuality(1)
    printf("GraphicHelperUtil:GetCurrentSceneRenderQuality fallback to Lobby quality for gameStatus:%s, Quality:%s", gameStatus, Quality)
    return Quality
  else
    local userSettings = slua_GameFrontendHUD:GetUserSettings()
    printf("GraphicHelperUtil.GetCurrentSceneRenderQuality userSettings.BattleRenderQuality:%s", userSettings.BattleRenderQuality)
    return userSettings.BattleRenderQuality
  end
end
function GraphicHelperUtil.GetCurrentSceneFPS()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local gameStatus = GameStatus.GetGameStatus()
  local gameInstance = UIUtil.GetGameInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bSupportSwitchRenderLevelRuntime then
    local FPS
    if GameStatus.IsIn2DLobby() then
      FPS = userSettings.LobbyFPS
      printf("GraphicHelperUtil.GetCurrentSceneFPS Lobby FPS = %s", FPS)
    elseif GameStatus.IsInMainCity() then
      FPS = userSettings.MainCityFPS
      printf("GraphicHelperUtil.GetCurrentSceneFPS MainCity FPS = %s", FPS)
    elseif GameStatus.IsInFightingStatus() then
      if GameStatus.IsInMainCity() then
        FPS = userSettings.MainCityFPS
        printf("GraphicHelperUtil.GetCurrentSceneFPS MainCity FPS = %s", FPS)
      else
        FPS = userSettings.BattleFPS
        printf("GraphicHelperUtil.GetCurrentSceneFPS Battle FPS = %s", FPS)
        if Client.IsMatchVersion and Client.IsMatchVersion() and RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.battle_custom_cfg and RoomSystem.CurrentRoomInfo.battle_custom_cfg.FrameLimit then
          local roomFps = tonumber(RoomSystem.CurrentRoomInfo.battle_custom_cfg.FrameLimit)
          printf("GraphicHelperUtil.GetCurrentSceneFPS Battle roomFps = %s", roomFps)
          if roomFps and 0 < roomFps then
            FPS = math.min(roomFps, FPS)
            printf("GraphicHelperUtil.GetCurrentSceneFPS Battle FPS = %s", FPS)
          end
        end
      end
    end
    printf("GraphicHelperUtil.GetCurrentSceneFPS gameStatus:%s, FPS:%s", gameStatus, FPS)
    return FPS
  else
    local userSettings = slua_GameFrontendHUD:GetUserSettings()
    printf("GraphicHelperUtil.GetCurrentSceneFPS userSettings.BattleFPS:%s", userSettings.BattleFPS)
    return userSettings.BattleFPS
  end
end
function GraphicHelperUtil.ReportTLogQualityAndFPS()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local reasonStr = json.encode({
    LobbyRenderQuality = userSettings.LobbyRenderQuality,
    LobbyFPS = userSettings.LobbyFPS,
    BattleRenderQuality = userSettings.BattleRenderQuality,
    BattleFPS = userSettings.BattleFPS
  })
  log_tree("GraphicHelperUtil:ReportTLogQualityAndFPS reasonStr", reasonStr)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SettingGraphicsQualityAndFPS, 0, reasonStr or "")
end
function GraphicHelperUtil.GetMaxFPSForQuality(quality, maxFPS)
  local gameInstance = UIUtil.GetGameInstance()
  local FPS = gameInstance:GetDeviceMaxFPSByDeviceLevel(quality)
  printf("GraphicHelperUtil.GetMaxFPSForQuality quality = %s, FPS = %s", quality, FPS)
  if 90 < FPS then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local BLUEHOLE120 = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("t.BLUEHOLE120")
      if BLUEHOLE120 == 0 then
        FPS = 90
      end
    end
  end
  if maxFPS and maxFPS < FPS then
    FPS = maxFPS
  end
  printf("GraphicHelperUtil.GetMaxFPSForQuality maxFPS:%s, FPS:%s", maxFPS, FPS)
  return GraphicHelperUtil.FPSNum2Level(FPS)
end
function GraphicHelperUtil.PUBGDeviceFPSHigh()
  local value = UKismetSystemLibrary.GetConsoleVariableValue("r.PUBGDeviceFPSHigh")
  return tonumber(value)
end
function GraphicHelperUtil.PUBGDeviceFPSMid()
  local value = UKismetSystemLibrary.GetConsoleVariableValue("r.PUBGDeviceFPSMid")
  return tonumber(value)
end
function GraphicHelperUtil.PUBGDeviceFPSLow()
  local value = UKismetSystemLibrary.GetConsoleVariableValue("r.PUBGDeviceFPSLow")
  return tonumber(value)
end
function GraphicHelperUtil.PUBGDeviceFPSHDR()
  local value = UKismetSystemLibrary.GetConsoleVariableValue("r.PUBGDeviceFPSHDR")
  printf("GraphicHelperUtil.PUBGDeviceFPSHDR value = %s", value)
  return tonumber(value)
end
function GraphicHelperUtil.PUBGDeviceFPSUltralHigh()
  local value = UKismetSystemLibrary.GetConsoleVariableValue("r.PUBGDeviceFPSUltralHigh")
  return tonumber(value)
end
function GraphicHelperUtil.GetLobbyMaxFPSLevel(favor, BestQuality_Quality)
  if favor == GraphicConst.FavorDef.BestQuality then
    local fpsNum = 0
    if BestQuality_Quality == GraphicHelperUtil.GetEffectiveQuality(ERenderQuality.HIGHDEFINITIONPLUS) then
      fpsNum = GraphicHelperUtil.PUBGDeviceFPSHDR()
    elseif BestQuality_Quality == GraphicHelperUtil.GetEffectiveQuality(ERenderQuality.HIGHDEFINITION) then
      fpsNum = GraphicHelperUtil.PUBGDeviceFPSHigh()
    elseif BestQuality_Quality == GraphicHelperUtil.GetEffectiveQuality(ERenderQuality.ULTRAHIGHDEFINITION) then
      fpsNum = GraphicHelperUtil.PUBGDeviceFPSUltralHigh()
    end
    printf("GraphicHelperUtil.GetLobbyMaxFPS BestQuality fpsNum = %s, BestQuality_Quality = %s", fpsNum, BestQuality_Quality)
    if fpsNum == 0 then
      local gameInstance = slua_GameFrontendHUD:GetGameInstance()
      fpsNum = gameInstance:GetDeviceMaxFPSByDeviceLevel(ERenderQuality.BALANCE)
      printf("GraphicHelperUtil.GetLobbyMaxFPS BestQuality fpsNum = %s", fpsNum)
    end
    fpsNum = math.min(fpsNum, 30)
    return GraphicHelperUtil.FPSNum2Level(fpsNum)
  elseif favor == GraphicConst.FavorDef.Balance then
    local fpsNum = GraphicHelperUtil.PUBGDeviceFPSMid()
    printf("GraphicHelperUtil.GetLobbyMaxFPS Balance fpsNum = %s", fpsNum)
    fpsNum = math.min(fpsNum, 30)
    return GraphicHelperUtil.FPSNum2Level(fpsNum)
  elseif favor == GraphicConst.FavorDef.FrameRate then
    local fpsNum = GraphicHelperUtil.PUBGDeviceFPSLow()
    printf("GraphicHelperUtil.GetLobbyMaxFPS FrameRate fpsNum = %s", fpsNum)
    fpsNum = math.min(fpsNum, 30)
    return GraphicHelperUtil.FPSNum2Level(fpsNum)
  else
    return 4
  end
end
function GraphicHelperUtil.FPSNum2Level(fpsNum)
  return FPSNum2Level[fpsNum] or 4
end
function GraphicHelperUtil.GetEffectiveQuality(targetQuality)
  local gameInstance = UIUtil.GetGameInstance()
  local DeviceMaxSupportLevel = gameInstance:GetDeviceMaxSupportLevel()
  if targetQuality == ERenderQuality.VERYSMOOTH then
    printf("GraphicHelperUtil.GetEffectiveQuality return verysmooth")
    return ERenderQuality.VERYSMOOTH
  end
  if targetQuality > DeviceMaxSupportLevel then
    printf("GraphicHelperUtil.GetEffectiveQuality return %s", DeviceMaxSupportLevel)
    return DeviceMaxSupportLevel
  end
  printf("GraphicHelperUtil.GetEffectiveQuality return %s", targetQuality)
  return targetQuality
end
function GraphicHelperUtil.GetFavorDefaultSettings(favor)
  local FrameRate_HPDevice = false
  local DeviceFPSHigh = GraphicHelperUtil.PUBGDeviceFPSHigh()
  if 40 <= DeviceFPSHigh then
    FrameRate_HPDevice = true
  end
  local BestQuality_DefaultQuality = ERenderQuality.HIGHDEFINITION
  local DeviceFPSHDR = GraphicHelperUtil.PUBGDeviceFPSHDR()
  if 60 <= DeviceFPSHDR then
    BestQuality_DefaultQuality = ERenderQuality.HIGHDEFINITIONPLUS
  end
  local HDROrHDRPlus_OrMax = GraphicHelperUtil.GetEffectiveQuality(BestQuality_DefaultQuality)
  local HDR_OrMax = GraphicHelperUtil.GetEffectiveQuality(ERenderQuality.HIGHDEFINITION)
  local Banlance_DefualtQuality = ERenderQuality.BALANCE
  if DeviceFPSHDR == 0 then
    Banlance_DefualtQuality = ERenderQuality.SMOOTH
  end
  local Banlance_DefualtQuality_Lobby
  local GradeLevel = Client.GetTCDeviceLevel()
  printf("GraphicHelperUtil.GetFavorDefaultSettings GradeLevel:%s", GradeLevel)
  if GradeLevel == 1 or GradeLevel == 2 or GradeLevel == 3 then
    Banlance_DefualtQuality_Lobby = ERenderQuality.SMOOTH
  elseif GradeLevel == 4 or GradeLevel == 5 then
    Banlance_DefualtQuality_Lobby = ERenderQuality.BALANCE
  else
    Banlance_DefualtQuality_Lobby = ERenderQuality.HIGHDEFINITION
  end
  local settings = {
    [GraphicConst.FavorDef.BestQuality] = {
      LobbyRenderQuality = HDROrHDRPlus_OrMax,
      BattleRenderQuality = HDR_OrMax,
      ManorRenderQuality = HDR_OrMax,
      MainCityRenderQuality = HDROrHDRPlus_OrMax,
      LobbyFPS = GraphicHelperUtil.GetLobbyMaxFPSLevel(GraphicConst.FavorDef.BestQuality, BestQuality_DefaultQuality),
      BattleFPS = GraphicHelperUtil.GetMaxFPSForQuality(HDROrHDRPlus_OrMax),
      MainCityFPS = GraphicHelperUtil.GetMaxFPSForQuality(HDROrHDRPlus_OrMax, 30),
      EnergySaving = false,
      DeviceAutoAdaptEx = false,
      FPSFineTuneSwitch = false,
      FPSAutoInterpolation = 1,
      RenderMSAASetting = true,
      RenderMSAAValue = 4,
      GraphicFavor = favor
    },
    [GraphicConst.FavorDef.Balance] = {
      LobbyRenderQuality = Banlance_DefualtQuality_Lobby,
      BattleRenderQuality = Banlance_DefualtQuality,
      ManorRenderQuality = Banlance_DefualtQuality,
      MainCityRenderQuality = HDR_OrMax,
      LobbyFPS = GraphicHelperUtil.GetLobbyMaxFPSLevel(GraphicConst.FavorDef.Balance),
      BattleFPS = GraphicHelperUtil.GetMaxFPSForQuality(Banlance_DefualtQuality),
      MainCityFPS = GraphicHelperUtil.GetMaxFPSForQuality(HDR_OrMax, 40),
      EnergySaving = false,
      DeviceAutoAdaptEx = true,
      FPSFineTuneSwitch = false,
      FPSAutoInterpolation = 1,
      RenderMSAASetting = false,
      RenderMSAAValue = 0,
      GraphicFavor = favor
    },
    [GraphicConst.FavorDef.FrameRate] = {
      LobbyRenderQuality = FrameRate_HPDevice and ERenderQuality.HIGHDEFINITION or ERenderQuality.SMOOTH,
      BattleRenderQuality = ERenderQuality.SMOOTH,
      ManorRenderQuality = ERenderQuality.SMOOTH,
      MainCityRenderQuality = HDR_OrMax,
      LobbyFPS = GraphicHelperUtil.GetLobbyMaxFPSLevel(GraphicConst.FavorDef.FrameRate),
      BattleFPS = GraphicHelperUtil.GetMaxFPSForQuality(ERenderQuality.SMOOTH),
      MainCityFPS = GraphicHelperUtil.GetMaxFPSForQuality(HDR_OrMax, 60),
      EnergySaving = true,
      DeviceAutoAdaptEx = true,
      FPSFineTuneSwitch = false,
      FPSAutoInterpolation = 1,
      RenderMSAASetting = false,
      RenderMSAAValue = 0,
      GraphicFavor = favor
    }
  }
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local bVerySmoothOpen = userSettings.bVerySmooth
  local favorSetting = settings[favor]
  if favorSetting then
    favorSetting.TurboEnable = false
    if 4 < favorSetting.MainCityFPS then
      favorSetting.MainCityFPS = 4
    end
    if favor == GraphicConst.FavorDef.FrameRate then
      if bVerySmoothOpen then
        favorSetting.BattleRenderQuality = ERenderQuality.VERYSMOOTH
        favorSetting.BattleFPS = GraphicHelperUtil.GetMaxFPSForQuality(ERenderQuality.VERYSMOOTH)
      end
      printf("GraphicHelperUtil.GetFavorDefaultSettings VerySmooth: IsSupportVerySmooth value %s BattlerenderQuality[%s] BattleFPS[%s]", bVerySmoothOpen, favorSetting.BattleRenderQuality, favorSetting.BattleFPS)
    end
    if favor == GraphicConst.FavorDef.Balance then
      local gameInstance = UIUtil.GetGameInstance()
      local deviceLevel = gameInstance:GetDeviceLevel()
      if deviceLevel == 0 then
        printf("GraphicHelperUtil.GetFavorDefaultSettings deviceLevel 0 set to smooth")
        local ERenderQuality = import("ERenderQuality")
        favorSetting.BattleRenderQuality = ERenderQuality.SMOOTH
        favorSetting.LobbyRenderQuality = ERenderQuality.SMOOTH
        favorSetting.MainCityRenderQuality = ERenderQuality.SMOOTH
        favorSetting.ManorRenderQuality = ERenderQuality.SMOOTH
      end
    end
  end
  return favorSetting
end
function GraphicHelperUtil.IsNewAccoutFirstLogin()
  local TableUtil = require("common.table_util")
  local lastLoginTime = TableUtil.GetTableValue(DataMgr, "roleData", "old_last_login_time")
  if lastLoginTime == nil then
    return true
  end
  return false
end
function GraphicHelperUtil.CanShowNewSettingPopup()
  printf("GraphicHelperUtil.CanShowNewSettingPopup")
  return false
end
function GraphicHelperUtil.GetQualityTextWithPrefix(renderQuality)
  local noPrefixTextID = GraphicHelperUtil.GetQualityText(renderQuality)
  return LocUtil.LocalizeResFormat(200000435, noPrefixTextID)
end
function GraphicHelperUtil.GetQualityText(renderQuality)
  local mapping = {
    [ERenderQuality.VERYSMOOTH] = 20121,
    [ERenderQuality.SMOOTH] = 7794,
    [ERenderQuality.BALANCE] = 7795,
    [ERenderQuality.HIGHDEFINITION] = 7796,
    [ERenderQuality.HIGHDEFINITIONPLUS] = 7797,
    [ERenderQuality.ULTRAHIGHDEFINITION] = 7798
  }
  local qualityTextID = mapping[renderQuality]
  if not qualityTextID then
    log_error("GraphicHelperUtil.GetQualityTextNoPrefix renderQuality not found: " .. tostring(renderQuality))
    qualityTextID = 7794
  end
  return LocUtil.GetLocalizeResStr(qualityTextID)
end
function GraphicHelperUtil.GetFPSText(fpsLevel)
  local level2Text = {
    [1] = 119600025,
    [2] = 119600016,
    [3] = 119600017,
    [4] = 119600018,
    [5] = 119600019,
    [6] = 119600020,
    [7] = 119600021,
    [8] = 119600040
  }
  return LocUtil.LocalizeResFormat(200000436, LocUtil.GetLocalizeResStr(level2Text[fpsLevel]))
end
function GraphicHelperUtil.IsCurrentGraphicFavorBalance()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
  return SettingConfig.GraphicFavor == GraphicConst.FavorDef.Balance
end
function GraphicHelperUtil.ChangeGraphicFavorToBalance()
  if GraphicHelperUtil.IsCurrentGraphicFavorBalance() then
    printf("GraphicHelperUtil.ChangeGraphicFavorToBalance current graphic favor is balance, do nothing")
    return
  end
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicConst.FavorDef.Balance)
  logic_setting_graphics.ApplyFavorSettings(favorSetting, GraphicConst.FavorDef.Balance)
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function GraphicHelperUtil.IsSupportVivoTurbo()
  if IsEditor then
    return true
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local OMobileFBPL = import("OMobileFBPL")
  local deviceName = OMobileFBPL.GetDeviceName()
  if not deviceName or type(deviceName) ~= "string" then
    printf("GraphicHelperUtil.IsSupportVivoTurbo deviceName is nil or not string, deviceName:%s", tostring(deviceName))
    return false
  end
  local isSupportHDR = GraphicHelperUtil.IsSupportHDR()
  local TurboDeviceList = "vivo NEX S|vivo 1805|V1824A|V1824BA|V1824T|V1821A|V1821T|V1922A|V1924A"
  local isTurboDevice = string.find(TurboDeviceList, deviceName, 1, true)
  local isShow = region ~= PublishRegionMacros.JAPAN and region ~= PublishRegionMacros.KOREA and isTurboDevice and isSupportHDR
  printf("GraphicHelperUtil.IsSupportVivoTurbo isShow:%s, region:%s, deviceName:%s, isSupportHDR:%s, isTurboDevice:%s", isShow, region, deviceName, isSupportHDR, isTurboDevice)
  return isShow
end
function GraphicHelperUtil.GetCollectRendQualityAndFPS()
  local RenderQuality = -1
  local FPS = -1
  local enableShadow
  local bCollectionHallMode = GameStatus.IsCollectionHallMode()
  if bCollectionHallMode then
    local gameInstance = UIUtil.GetGameInstance()
    local DeviceFPSHDR = gameInstance:GetDeviceFPSHDR()
    local DeviceFPSHigh = gameInstance:GetDeviceFPSHigh()
    RenderQuality = ERenderQuality.SMOOTH
    if 1 < DeviceFPSHigh then
      RenderQuality = ERenderQuality.HIGHDEFINITION
      FPS = 4
    end
    if 1 < DeviceFPSHDR then
      RenderQuality = ERenderQuality.HIGHDEFINITIONPLUS
    end
    local TCDeviceLevel = Client.GetTCDeviceLevel()
    if TCDeviceLevel <= 6 then
      enableShadow = false
    end
  end
  printf("GraphicHelperUtil.GetCollectRendQualityAndFPS Is CollectionHallMode renderQuality: %d, FPS: %d, enableShadow: %s, bCollectionHallMode: %s", RenderQuality, FPS, tostring(enableShadow), tostring(bCollectionHallMode))
  return RenderQuality, FPS, enableShadow
end
return GraphicHelperUtil