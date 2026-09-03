local ThemeConfig = {}
ThemeConfig.SubSystem = {
  GameIntroduction = "introduction",
  MapIntroduction = "mapIntroduction",
  Task = "task",
  ExchangeStore = "exchange",
  OfflineBox = "chest",
  FindTreasure = "findTreasure",
  NarutoMain = "narutoMain"
}
ThemeConfig.ThemeTaskTabID = 3
ThemeConfig.MapIntroType = {
  NomalBig = 1,
  NomalSmall = 2,
  MapBig = 3,
  MapSmall = 4,
  Activity = 5,
  ClassicMapUpdate = 6
}
ThemeConfig.ThemeActivityState = {
  None = 1,
  Online = 2,
  Preheat = 3,
  SessionUpdate = 4
}
ThemeConfig.ThemeRedDotType = {
  NewVersion = 1,
  OfflineBox = 2,
  ExchangeNew = 3,
  NextVersionPreheat = 4,
  NewActivity = 5,
  TaskFinished = 6,
  ThemeActOpen = 9,
  ThemeActReward = 10
}
ThemeConfig.ExchangeTabType = {Other = 1, Souvenir = 2}
ThemeConfig.ThemeEntryMat = "/Game/Mod/Lobby/Split/MatchSelectMap/450/ModeSelection_New/MapEntrance/Big/DX_FlowLight_DH09_Inst7.DX_FlowLight_DH09_Inst7"
ThemeConfig.ThemeEntryLoopMat = "/Game/Mod/Lobby/Split/MatchSelectMap/450/ModeSelection_New/MapEntrance/Big/DX_FlowLight_Mode.DX_FlowLight_Mode"
ThemeConfig.ThemeEntryMat2 = "/Game/UMG/UI_Effect/Materials/Big/DX_FlowLight_DH09_Inst7_2.DX_FlowLight_DH09_Inst7_2"
ThemeConfig.ThemeEntryLoopMat2 = "/Game/UMG/UI_Effect/Materials/Big/DX_FlowLight_Mode_2.DX_FlowLight_Mode_2"
function ThemeConfig.GetThemeSystemIntroduction()
  ThemeConfig.ThemeIntroductionList = {}
  local ThemeConfigs = CDataTable.GetTableByFilter("ThemeIntroductionConfig", "IsOpen", true)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, config in pairs(ThemeConfigs) do
    local timeCfg = ThemeConfig.GetThemeIntroductionTime(config)
    local preTime = TimeUtil.TimeStringToUnixstamp(timeCfg.PreheatingTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(timeCfg.OfflineTime)
    if curTime < endTime and curTime >= preTime then
      local temp = {}
      for k, v in pairs(config) do
        temp[k] = v
      end
      temp.themeId = config.ThemeId
      temp.preheatingTime = timeCfg.PreheatingTime
      temp.onlineTime = timeCfg.OnlineTime
      temp.offlineTime = timeCfg.OfflineTime
      temp.tabTitle = config.TabTitle
      temp.collectionURL = config.CollectionURL
      temp.aAchievementURL = config.AchievementURL
      temp.albumURL = config.AlbumURL
      ThemeConfig.ThemeIntroductionList[#ThemeConfig.ThemeIntroductionList + 1] = temp
    end
  end
  return ThemeConfig.ThemeIntroductionList
end
function ThemeConfig.GetThemeSystemConfig()
  if not ThemeConfig.themeSystemConfig then
    local config = CDataTable.GetTableData("ThemeIntroductionConfig", 1)
    if not config or config.IsOpen == false then
      return nil
    end
    local timeCfg = ThemeConfig.GetThemeIntroductionTime(config)
    local themeConfig = {}
    for k, v in pairs(config) do
      themeConfig[k] = v
    end
    themeConfig.themeId = config.ThemeId
    themeConfig.preheatingTime = timeCfg.PreheatingTime
    themeConfig.onlineTime = timeCfg.OnlineTime
    themeConfig.offlineTime = timeCfg.OfflineTime
    themeConfig.clientVersion = timeCfg.ClientVersion
    themeConfig.tabTitle = config.TabTitle
    themeConfig.collectionURL = config.CollectionURL
    themeConfig.aAchievementURL = config.AchievementURL
    themeConfig.albumURL = config.AlbumURL
    ThemeConfig.themeSystemConfig = themeConfig
  end
  return ThemeConfig.themeSystemConfig
end
function ThemeConfig.GetCurrentVersionOverviewConfig()
  if not ThemeConfig.CurrentVersionPreviewConfig then
    ThemeConfig.CurrentVersionPreviewConfig = CDataTable.GetTableData("ThemeOverviewConfig", 1)
  end
  return ThemeConfig.CurrentVersionPreviewConfig
end
function ThemeConfig.GetNextVersionOverviewConfig()
  if not ThemeConfig.NextVersionPreviewConfig then
    ThemeConfig.NextVersionPreviewConfig = CDataTable.GetTableData("ThemeOverviewConfig", 2)
  end
  return ThemeConfig.NextVersionPreviewConfig
end
function ThemeConfig.GetThemeIntroductionTime(themeConfig)
  local timeCfg = {
    PreheatingTime = "",
    OnlineTime = "",
    OfflineTime = ""
  }
  local StringUtil = require("common.string_util")
  local tPreheatTime = StringUtil.Split(themeConfig.PreheatingTime, "|")
  local tOnlineTime = StringUtil.Split(themeConfig.OnlineTime, "|")
  local tOfflineTime = StringUtil.Split(themeConfig.OfflineTime, "|")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local currentVersionIndex = Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE and 1 or 2
  timeCfg.PreheatingTime = tPreheatTime[currentVersionIndex]
  timeCfg.OnlineTime = tOnlineTime[currentVersionIndex]
  timeCfg.OfflineTime = tOfflineTime[currentVersionIndex]
  return timeCfg
end
function ThemeConfig.GetThemeActivityState()
  local item = ThemeConfig.GetThemeSystemConfig()
  if not item then
    return ThemeConfig.ThemeActivityState.None
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and string.format("ThemeConfig.GetThemeActivityState nowTime=%s", tostring(nowTime)))
  local switchSessionTime = TimeUtil.TimeStringToUnixstamp(item.SwitchSessionTime)
  log(bWriteLog and string.format("ThemeConfig.GetThemeActivityState switchSessionTime=%s", tostring(switchSessionTime)))
  if 0 < switchSessionTime and nowTime >= switchSessionTime then
    return ThemeConfig.ThemeActivityState.SessionUpdate
  end
  local swtichPreheatingTime = TimeUtil.TimeStringToUnixstamp(item.SwitchPreheatingTime)
  log(bWriteLog and string.format("ThemeConfig.GetThemeActivityState swtichPreheatingTime=%s", tostring(swtichPreheatingTime)))
  if 0 < swtichPreheatingTime and nowTime >= swtichPreheatingTime then
    return ThemeConfig.ThemeActivityState.Preheat
  end
  local onlineTime = TimeUtil.TimeStringToUnixstamp(item.OnlineTime)
  log(bWriteLog and string.format("ThemeConfig.GetThemeActivityState onlineTime=%s", tostring(onlineTime)))
  if 0 < onlineTime and nowTime >= onlineTime then
    return ThemeConfig.ThemeActivityState.Online
  end
  log(bWriteLog and "ThemeConfig.GetThemeActivityState return none")
  return ThemeConfig.ThemeActivityState.None
end
function ThemeConfig.GetThemeBannerConfig(themeId)
  if not ThemeConfig.ThemeBannerConfig then
    ThemeConfig.ThemeBannerConfig = {}
  end
  if ThemeConfig.ThemeBannerConfig[themeId] then
    return ThemeConfig.ThemeBannerConfig[themeId]
  end
  local BannerConfigs = CDataTable.GetTableByFilter("ThemeBannerConfig", "ThemeId", themeId)
  local banners = {}
  for _, config in pairs(BannerConfigs) do
    local temp = {
      Id = config.ID,
      themeId = config.ThemeId,
      bannerURL = config.BannerURL,
      videoPath = config.ThemeVideoPath
    }
    banners[#banners + 1] = temp
  end
  ThemeConfig.ThemeBannerConfig[themeId] = banners
  return banners
end
function ThemeConfig.GetThemeExchangeActivityID()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local exchangeList = CDataTable.GetTable("ThemeExchangeConfig")
  for i, config in pairs(exchangeList) do
    local startTime = TimeUtil.TimeStringToUnixstamp(config.StartTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(config.EndTime)
    if curTime > startTime and curTime <= endTime then
      return config.ExchangeActivityID or 0
    end
  end
  return 0
end
function ThemeConfig.GetTabList()
  local tabList = {
    {
      tabName = 86132,
      tabType = ThemeConfig.SubSystem.GameIntroduction,
      UIConfig = UIManager.UI_Config.Theme_Overview_UIBP,
      attachPanel = "CanvasPanel_AvatarDetails"
    },
    {
      tabName = 450176,
      tabType = ThemeConfig.SubSystem.NarutoMain,
      UIConfig = UIManager.UI_Config.Theme_Naruto_UIBP,
      attachPanel = "CanvasPanel_AvatarDetails"
    },
    {
      tabName = 86133,
      tabType = ThemeConfig.SubSystem.MapIntroduction,
      UIConfig = UIManager.UI_Config.Theme_Preheat_UIBP,
      attachPanel = "CanvasPanel_BoxRoot"
    }
  }
  local logic_theme_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_task)
  if logic_theme_task:IsThemeTaskOpen() then
    local taskTab = {
      tabName = 450177,
      tabType = ThemeConfig.SubSystem.Task,
      UIConfig = UIManager.UI_Config.Theme_NarutoTask_UIBP,
      attachPanel = "CanvasPanel_BoxRoot"
    }
    table.insert(tabList, ThemeConfig.ThemeTaskTabID, taskTab)
  end
  local exchangeID = ThemeConfig.GetThemeExchangeActivityID()
  if 0 < exchangeID then
    local exchangeTab = {
      tabName = 66613,
      tabType = ThemeConfig.SubSystem.ExchangeStore,
      UIConfig = UIManager.UI_Config.Theme_Exchange_UIBP,
      attachPanel = "CanvasPanel_Show"
    }
    table.insert(tabList, exchangeTab)
  end
  return tabList
end
function ThemeConfig.GetEntryBannerConfig()
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not LogicPufferBundle.IsFitLobbyResDownloaded() then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local entryConfig = CDataTable.GetTableData("EntryBannerConfig", 1)
  if entryConfig then
    local startTime = TimeUtil.TimeStringToUnixstamp(entryConfig.StartTime)
    if curTime > startTime then
      return entryConfig
    end
  end
  return nil
end
function ThemeConfig.GetNextVersionEntryBannerConfig()
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not LogicPufferBundle.IsFitLobbyResDownloaded() then
    return nil
  end
  local entryConfig = CDataTable.GetTableData("EntryBannerConfig", 2)
  return entryConfig
end
function ThemeConfig.GetThemActLinkByCfg(uConfig)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return uConfig.JKLink
  elseif PublishRegionMacros.IsBLUEHOLE() then
    return uConfig.INLink
  else
    return uConfig.GlobalLink
  end
end
function ThemeConfig.GetThemActEntranceIconByCfg(uConfig)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local accountregion = FuncUtil.GetAccountRegionForBP()
    if accountregion == "JP" then
      return uConfig.JPIconUrl
    else
      return uConfig.KRIconUrl
    end
  elseif PublishRegionMacros.IsBLUEHOLE() then
    return uConfig.INIconUrl
  else
    return uConfig.GlobalIconUrl
  end
end
function ThemeConfig.GetCurrentThemeActivityJump(themeId)
  if not themeId then
    return ""
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local targetUrl = ""
  local entranceIcon = ""
  local configList = {}
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetMainFormat(Client.GetAppVersion())
  local uThemeAllUrl = CDataTable.GetTableByFilter("ThemeActLinkCfg", "ThemeId", themeId, "Version", curVersion) or {}
  for _, v in pairs(uThemeAllUrl) do
    table.insert(configList, v)
  end
  table.sort(configList, function(a, b)
    local aStartTime = TimeUtil.TimeStringToUnixstamp(a.StartTime)
    local bStartTime = TimeUtil.TimeStringToUnixstamp(b.StartTime)
    return aStartTime < bStartTime
  end)
  for _, uConfig in ipairs(configList) do
    local startTime = TimeUtil.TimeStringToUnixstamp(uConfig.StartTime)
    if curTime < startTime then
      break
    end
    targetUrl = ThemeConfig.GetThemActLinkByCfg(uConfig)
    entranceIcon = ThemeConfig.GetThemActEntranceIconByCfg(uConfig)
  end
  if string.find(targetUrl, "|") then
    local StringUtil = require("common.string_util")
    targetUrl = StringUtil.Split(targetUrl, "|")
    local accountregion = FuncUtil.GetAccountRegionForBP()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      if accountregion == "JP" then
        targetUrl = targetUrl[2]
      else
        targetUrl = targetUrl[1]
      end
    end
  end
  return targetUrl, entranceIcon
end
function ThemeConfig.GetCurrentThemeShopActJump()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetMainFormat(Client.GetAppVersion())
  local uThemeAllUrl = CDataTable.GetTableByFilter("ThemeActLinkCfg", "Version", curVersion) or {}
  local configList = {}
  for _, v in pairs(uThemeAllUrl) do
    table.insert(configList, v)
  end
  table.sort(configList, function(a, b)
    return a.ID < b.ID
  end)
  local targetUrl = ""
  for _, uConfig in ipairs(configList) do
    local startTime = TimeUtil.TimeStringToUnixstamp(uConfig.StartTime)
    if curTime < startTime then
      break
    end
    targetUrl = ThemeConfig.GetThemActLinkByCfg(uConfig)
  end
  if string.find(targetUrl, "|") then
    local StringUtil = require("common.string_util")
    targetUrl = StringUtil.Split(targetUrl, "|")
    local accountregion = FuncUtil.GetAccountRegionForBP()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      if accountregion == "JP" then
        targetUrl = targetUrl[2]
      else
        targetUrl = targetUrl[1]
      end
    end
  end
  return targetUrl
end
function ThemeConfig.GetThemeParam(key)
  local data = CDataTable.GetTableData("ThemeParamConfig", key)
  if not data then
    log_error(bWriteLog and "ThemeConfig.GetThemeParam no key")
    return
  end
  return data.Value
end
function ThemeConfig.GetBoxDropItemsConfig()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local currentThemeDropConfig = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local dropConfig = CDataTable.GetTable("ThemeBoxDropConfig")
  for _, cfg in pairs(dropConfig) do
    local startTime = 0
    local endTime = 0
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      startTime = TimeUtil.TimeStringToUnixstamp(cfg.IndianStartTime)
      endTime = TimeUtil.TimeStringToUnixstamp(cfg.IndianEndTime)
    else
      startTime = TimeUtil.TimeStringToUnixstamp(cfg.StartTime)
      endTime = TimeUtil.TimeStringToUnixstamp(cfg.EndTime)
    end
    if curTime > startTime and curTime < endTime then
      table.insert(currentThemeDropConfig, cfg)
    end
  end
  return currentThemeDropConfig
end
function ThemeConfig.GetCurrentBoxDropItemsConfig()
  local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
  local dropCfg = ThemeConfig.GetBoxDropItemsConfig()
  local dropDetails = {}
  for _, cfg in ipairs(dropCfg) do
    local isLimitTime = false
    local itemCfg = CDataTable.GetTableData("Item", cfg.DropItemID)
    local isExTime = itemCfg and itemCfg.ExTime ~= ""
    isLimitTime = cfg.LimitDays ~= 0 or isExTime
    table.insert(dropDetails, {
      DropWeight = 0,
      DropItemID = cfg.DropItemID,
      is_limit_time = isLimitTime,
      item_time_limit = cfg.LimitDays * 24,
      DropType = cfg.DropType,
      DropItemNum = cfg.DropNum
    })
  end
  return dropDetails
end
function ThemeConfig.GetMapIntroductionConfig()
  local TimeUtil = require("client.common.time_util")
  local StringUtil = require("common.string_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local config = {}
  local mapBigCnt = 0
  local mapSmallCnt = 0
  local ThemeMapShowConfig = CDataTable.GetTable("ThemeMapShowConfig")
  for k, v in pairs(ThemeMapShowConfig) do
    if v.Type == ThemeConfig.MapIntroType.MapBig then
      mapBigCnt = mapBigCnt + 1
    elseif v.Type == ThemeConfig.MapIntroType.MapSmall then
      mapSmallCnt = mapSmallCnt + 1
    end
    local bInTime = false
    if v.StartShowTime == "" and v.EndShowTime == "" then
      bInTime = true
    else
      local startTime = TimeUtil.TimeStringToUnixstamp(v.StartShowTime)
      local endTime = TimeUtil.TimeStringToUnixstamp(v.EndShowTime)
      if curTime >= startTime and curTime < endTime then
        bInTime = true
      end
    end
    if bInTime then
      if not config[v.Type] then
        config[v.Type] = {}
      end
      table.insert(config[v.Type], {
        ID = v.ID,
        Name = v.Name,
        Type = v.Type,
        PositionID = v.PositionID,
        NeedAnimation = v.NeedAnimation,
        CountDownTimeStamp = TimeUtil.TimeStringToUnixstamp(v.CountDownTime),
        IconPath = v.IconPath,
        AwardPath = v.AwardPath,
        RightBottomPath = v.RightBottomPath,
        LabelText = v.LabelText,
        IntroductionList = StringUtil.Split(v.IntroductionInfo, "|"),
        IntroductionJumpUrl = v.IntroductionJumpUrl,
        NeedJump = v.NeedJump,
        JumpIconPath = v.JumpIconPath,
        JumpText = v.JumpText,
        JumpStartTimeStamp = TimeUtil.TimeStringToUnixstamp(v.JumpStartTime),
        JumpEndTimeStamp = TimeUtil.TimeStringToUnixstamp(v.JumpEndTime),
        TabType = v.TabType
      })
    end
  end
  return config, mapBigCnt, mapSmallCnt
end
function ThemeConfig.GetOperationActivityConfig()
  local ThemeMapShowConfig = CDataTable.GetTable("ThemeMapShowConfig")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(ThemeMapShowConfig) do
    if v.Type == ThemeConfig.MapIntroType.Activity then
      local bInTime = false
      if v.StartShowTime == "" and v.EndShowTime == "" then
        bInTime = true
      else
        local startTime = TimeUtil.TimeStringToUnixstamp(v.StartShowTime)
        local endTime = TimeUtil.TimeStringToUnixstamp(v.EndShowTime)
        if curTime >= startTime and curTime < endTime then
          bInTime = true
        end
      end
      if bInTime then
        return v
      end
    end
  end
  return nil
end
return ThemeConfig