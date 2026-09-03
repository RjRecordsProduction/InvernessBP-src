local logic_ugc_hot_page = {}
local C_GUESS_YOU_LIKE_THEME_ID = 301
function logic_ugc_hot_page:DefineAndResetData()
  logic_ugc_hot_page.__super.DefineAndResetData(self)
  self.ReqList = {
    2,
    1,
    4
  }
  self.NewReqList = {2, 1}
  self.AllReqTypeList = {}
  self.currentAuthorIndex = 1
  self.AfterAuthorShowList = {}
  self.BannerShowlist = {}
  self.HotThemeListReqCD = 70
  self.HotThemeUniqueModNum = 3
  self.HotThemeCarouselCD = 120
  self.hot_theme = nil
  self.hot_exposure_theme = {}
  self.ExposureModList = {}
  self.themeScrollOffsetCache = nil
  self.hasReqProfileUidList = nil
  self.themeDataTimeStamp = nil
  self.AutoNextReqBundleID = nil
  self.tableHotTheme = {}
  self.HotAuthorCarouselCD = 300
  self.HotThemeEntryStamp = nil
  self.HotThemeDepartureStamp = nil
  self.report = {}
  self.version = 0
  self.trans_info = {}
  self.white_list = {}
  self.HotThemeReqState = {}
  self.DisplayedThemeModIDList = {}
  self.mixed_banner_list = {}
  self.bannerData = {}
  self.BannerThemeData = {}
  self.newThemeData = {}
  self.activityData = {}
  self.showList = nil
  self.themeIndex = 0
end
function logic_ugc_hot_page:OnLogOut()
  log(bWriteLog and "logic_ugc_hot_page:OnLogOut")
  self:ClearHotThemeCacheData()
end
function logic_ugc_hot_page:ClearHotThemeCacheData()
  self.themeScrollOffsetCache = nil
  self.hasReqProfileUidList = nil
  self.hot_theme = nil
  self.hot_exposure_theme = {}
  self.ExposureModList = {}
  self.themeDataTimeStamp = nil
  self.tableHotTheme = {}
  self.HotThemeEntryStamp = nil
  self.HotThemeDepartureStamp = nil
  self.report = {}
  self.version = 0
  self.trans_info = {}
  self.HotThemeReqState = {}
  self:ClearDisplayedThemeModIDListCache()
end
function logic_ugc_hot_page:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "logic_ugc_hot_page:OnPostSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    self:ClearBannerCache()
  end
end
function logic_ugc_hot_page:ClearBannerCache()
  print(bWriteLog and "logic_ugc_hot_page:ClearBannerCache")
  self.mixed_banner_list = {}
  self.bannerData = {}
  self.BannerThemeData = {}
  self.activityData = {}
  self.showList = nil
  self.newThemeData = {}
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:ClearModCacheByType(LogicUGC.C_ModListTypes.MixedBanner)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local NewUGCMainPanel = UIManager.GetUI(UIManager.UI_Config.NewUGCMainPanel)
  if not NewUGCMainPanel then
    log(bWriteLog and "logic_ugc_hot_page:ClearBannerCache not NewUGCMainPanel")
    return
  end
  log(bWriteLog and "logic_ugc_hot_page:ClearBannerCache self:send_ugc_mixed_banner_req")
  local tabId = LogicUGC:GetSelectedTabId()
  if tabId == Config_UGC.Config_UGC_TabID.HotTheme then
    self:send_ugc_mixed_banner_req()
  end
end
function logic_ugc_hot_page:on_ugc_gallery_hot_theme_rsp(error, hot_theme)
  log(bWriteLog and "logic_ugc_hot_page:on_ugc_gallery_hot_theme_rsp error=", tostring(error))
  local tempHotTheme = {}
  for _, value in ipairs(hot_theme) do
    if value.data_type ~= "MODE_SELECT_DISCOVER" then
      table.insert(tempHotTheme, value)
    end
  end
  self:UGCHotThemeDataIntegration(tempHotTheme)
  if error ~= 0 or tempHotTheme == nil then
    self.TabInfo.theme = nil
    log(bWriteLog and "UGC HotTheme request failed or empty data")
    return
  end
  local ThemeList = self:ProcessHotThemeData(tempHotTheme)
  self.TabInfo.Showtheme = ThemeList
  self.TabInfo.theme = tempHotTheme
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModIDList = self:GetHotThemeModIDList()
  self:GetModInfoReq(ModIDList, LogicUGC.C_ModListTypes.HotTheme)
end
function logic_ugc_hot_page:on_ugc_mixed_banner_rsp(error, mixed_banner_list)
  log(bWriteLog and "logic_ugc_hot_page:on_ugc_mixed_banner_rsp error=", tostring(error))
  self:UGCBannerDataIntegration(mixed_banner_list)
  if error ~= 0 or mixed_banner_list == nil then
    self.TabInfo.banner = nil
    return
  end
  self.TabInfo.banner = mixed_banner_list
  self.BannerShowlist = self.showList
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModIDList = self:GetHotBannerModIDList()
  self:GetModInfoReq(ModIDList, LogicUGC.C_ModListTypes.MixedBanner)
end
function logic_ugc_hot_page:on_ugc_hot_theme_ext_rsp(error, hot_rank)
  log(bWriteLog and "logic_ugc_hot_page:on_ugc_hot_theme_ext_rsp error=", tostring(error))
  log_tree("logic_ugc_hot_page:on_ugc_hot_theme_ext_rsp hot_rank=", hot_rank)
  if error ~= 0 or hot_rank == nil then
    self.TabInfo.rank = nil
    return
  end
  self.TabInfo.rank = hot_rank
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModIDList = self:GetHotRankModIDList()
  self:GetModInfoReq(ModIDList, LogicUGC.C_ModListTypes.hot_theme_ext)
end
function logic_ugc_hot_page:GetModInfo()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  self:UGCBannerDataIntegration(self.TabInfo.banner)
  self.AllReqTypeList = {}
  local ModIDList = {}
  ModIDList = self:GetHotBannerModIDList()
  self:GetModInfoReq(ModIDList, LogicUGC.C_ModListTypes.MixedBanner)
  ModIDList = self:GetHotThemeModIDList()
  self:GetModInfoReq(ModIDList, LogicUGC.C_ModListTypes.HotTheme)
  ModIDList = self:GetHotRankModIDList()
  self:GetModInfoReq(ModIDList, LogicUGC.C_ModListTypes.hot_theme_ext)
end
function logic_ugc_hot_page:TabAllModInfoRsp(ReqListType, bDontRsp)
  log(bWriteLog and "logic_ugc_hot_page:TabAllModInfoRsp" .. tostring(ReqListType))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if ReqListType == LogicUGC.C_ModListTypes.MixedBanner then
    self.AllReqTypeList[LogicUGC.C_ModListTypes.MixedBanner] = true
    self:SetbIsRefreshTab(true)
    self:CheckAllBackToEvent()
  elseif ReqListType == LogicUGC.C_ModListTypes.HotTheme then
    self.AllReqTypeList[LogicUGC.C_ModListTypes.HotTheme] = true
    local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    if LogicUGCHall:CheckIsOpen() then
      self:SetbIsRefreshTab(true)
    else
      log(bWriteLog and "logic_ugc_hot_page:TabAllModInfoRsp hot_theme_ext .." .. tostring(self.AllReqTypeList[LogicUGC.C_ModListTypes.hot_theme_ext]))
      if not self.AllReqTypeList[LogicUGC.C_ModListTypes.hot_theme_ext] and self.TabInfo.rank and next(self.TabInfo.rank) then
        self:SetbIsRefreshTab(false)
      else
        self:SetbIsRefreshTab(true)
      end
    end
    self:CheckThemeIndex()
    self:CheckAllBackToEvent()
  elseif ReqListType == LogicUGC.C_ModListTypes.hot_theme_ext then
    log(bWriteLog and "logic_ugc_hot_page:TabAllModInfoRsp HotTheme .." .. tostring(self.AllReqTypeList[LogicUGC.C_ModListTypes.HotTheme]))
    self.AllReqTypeList[LogicUGC.C_ModListTypes.hot_theme_ext] = true
    if not self.AllReqTypeList[LogicUGC.C_ModListTypes.HotTheme] then
      self:SetbIsRefreshTab(false)
    else
      self:SetbIsRefreshTab(true)
    end
    self:CheckAllBackToEvent()
  end
end
function logic_ugc_hot_page:GetStringToArry(string)
  if type(string) == "string" then
    local StringUtil = require("common.string_util")
    return StringUtil.SplitToNum(string, "|")
  end
  return string
end
function logic_ugc_hot_page:GetHotThemeModIDList(ModIDList)
  if not self.TabInfo or not self.TabInfo.theme then
    log("logic_ugc_hot_page:GetHotThemeModIDList theme is nil")
    return
  end
  local ReqModIDList = ModIDList or {}
  if self.TabInfo.theme then
    for _, v in ipairs(self.TabInfo.theme) do
      if v.data_type ~= "MODE_SELECT_DISCOVER" and v.mod_list then
        for k, modid in ipairs(v.mod_list) do
          table.insert(ReqModIDList, modid)
        end
      end
      if v.data_type == "AUTHOR" and v.trans_data and v.trans_data.author_list then
        local AuthorIDList = {}
        for k, author in ipairs(v.trans_data.author_list) do
          if author.mod_list then
            local modlist = self:GetStringToArry(author.mod_list)
            for k, modid in ipairs(modlist) do
              table.insert(ReqModIDList, modid)
            end
          end
          if author.author_uid then
            table.insert(AuthorIDList, author.author_uid)
          end
        end
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        logic_profile_get_wrap.GetNormalProfiles({AuthorIDList}, function(profileList)
        end, Enum_PROFILE_REPORT_CFG.UGC)
      end
    end
  end
  return ReqModIDList
end
function logic_ugc_hot_page:GetHotBannerModIDList(ModIDList)
  if not self.TabInfo or not self.TabInfo.banner then
    log("logic_ugc_hot_page:GetHotBannerModIDList banner is nil")
    return
  end
  local ReqModIDList = ModIDList or {}
  if self.TabInfo.banner then
    local bannerModidList = self:GetNeedReqModIDs()
    self.BannerShowlist = self:SetSelectThemeBanner()
    log("logic_ugc_hot_page:GetHotBannerModIDList")
    if bannerModidList then
      for k, modid in ipairs(bannerModidList) do
        table.insert(ReqModIDList, modid)
      end
    end
  end
  return ReqModIDList
end
function logic_ugc_hot_page:GetHotRankModIDList(ModIDList)
  if not self.TabInfo or not self.TabInfo.rank then
    log("logic_ugc_hot_page:GetHotRankModIDList rank is nil")
    return
  end
  local ReqModIDList = ModIDList or {}
  if self.TabInfo.rank then
    for _, v in pairs(self.TabInfo.rank) do
      for index = 1, 6 do
        table.insert(ReqModIDList, v.mod_id_list[index])
      end
    end
  end
  return ReqModIDList
end
function logic_ugc_hot_page:CheckThemeIndex()
  if not self.TabInfo or not self.TabInfo.Showtheme then
    return
  end
  local themelist = self.TabInfo.Showtheme
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local invalidThemes = {}
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  local ThemeRefreshModNum
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  if LogicUGCHall:CheckIsOpen() then
    ThemeRefreshModNum = config_ugc_hot_theme.NewThemeRefreshModNum
  else
    ThemeRefreshModNum = config_ugc_hot_theme.ThemeRefreshModNum
  end
  log_tree("logic_ugc_hot_page:CheckThemeIndex themelist=", themelist)
  for themeIndex, themeData in ipairs(themelist) do
    if themeData.mod_list and #themeData.mod_list >= 1 then
      local validModCount = 0
      for _, modID in ipairs(themeData.mod_list) do
        if LogicUGC:GetModByWithoutPubCache(modID) then
          validModCount = validModCount + 1
        end
      end
      log(bWriteLog and "logic_ugc_hot_page:CheckThemeIndex themeIndex" .. tostring(themeIndex) .. " validModCount" .. tostring(validModCount))
      if ThemeRefreshModNum > validModCount then
        table.insert(invalidThemes, themeIndex)
      end
    end
  end
  table.sort(invalidThemes, function(a, b)
    return b < a
  end)
  for _, themeIndex in ipairs(invalidThemes) do
    log(bWriteLog and "logic_ugc_hot_page:CheckThemeIndex themeIndex ", themeIndex)
    table.remove(themelist, themeIndex)
  end
  self.TabInfo.Showtheme = themelist
end
function logic_ugc_hot_page:GetHotTabInfo()
  if not self.TabInfo then
    log(bWriteLog and "logic_ugc_hot_page:GetHotTabInfo TabInfo is nil")
    return {}
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  local reuseFallList = {}
  local bannerlist = self.BannerShowlist
  local themelist = self.TabInfo.Showtheme
  local ranklist = self.TabInfo.rank
  if self.AllReqTypeList[LogicUGC.C_ModListTypes.MixedBanner] and bannerlist and next(bannerlist) then
    local itemData = {
      dataList = bannerlist,
      style = config_ugc_hot_theme.ItemDataType.Banner
    }
    table.insert(reuseFallList, itemData)
  end
  if themelist then
    for k, theme in ipairs(themelist) do
      table.insert(reuseFallList, {
        themeIndex = k,
        themeName = theme.base and theme.base.name,
        base = theme.base,
        dataList = theme.mod_list,
        style = theme.data_type == "AUTHOR" and config_ugc_hot_theme.ItemDataType.AuthorList or config_ugc_hot_theme.ItemDataType.ModList,
        themeId = theme.base and theme.base.id,
        data_type = theme.data_type or "",
        trans_data = theme.trans_data or nil
      })
    end
  end
  if reuseFallList and next(reuseFallList) then
    local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    if LogicUGCHall:CheckIsOpen() then
      ranklist = nil
    end
    if ranklist and next(ranklist) then
      local hotRandData = {
        dataList = ranklist,
        style = config_ugc_hot_theme.ItemDataType.HotList
      }
      local bConfiguration = false
      for index, data in ipairs(reuseFallList) do
        if data.data_type and data.data_type == "RANK_OPE" then
          reuseFallList[index] = hotRandData
          bConfiguration = true
          break
        end
      end
      local num = 0
      for index, data in ipairs(reuseFallList) do
        if data.style ~= 1 and data.style ~= 4 then
          num = num + 1
        end
      end
      local hotThemeNum = self:GetHotThemeListNum()
      if num == hotThemeNum then
        if not bConfiguration then
          table.insert(reuseFallList, hotRandData)
        end
        local hotmore = {
          dataList = {},
          style = config_ugc_hot_theme.ItemDataType.More
        }
        table.insert(reuseFallList, hotmore)
      end
    else
      for index, data in ipairs(reuseFallList) do
        if data.data_type and data.data_type == "RANK_OPE" then
          table.remove(reuseFallList, index)
          break
        end
      end
    end
  end
  return reuseFallList
end
function logic_ugc_hot_page:GetTrendingTabInfo()
  if not self.TabInfo or not self.TabInfo.theme then
    log(bWriteLog and "logic_ugc_hot_page:GetTrendingTabInfo self.TabInfo or self.TabInfo.theme is nil")
    return {}
  end
  local trendingModIdList = {}
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  for k, theme in ipairs(self.TabInfo.theme) do
    if theme.base and (theme.base.id == Config_UGC.REGION_HOT_RECOMMEND_ID or theme.base.id == Config_UGC.REGION_SELF_TAG_HOT_ID) then
      for _, v in ipairs(theme.mod_list or {}) do
        table.insert(trendingModIdList, v)
      end
    end
  end
  return trendingModIdList
end
function logic_ugc_hot_page:CheckAuthorThemeQuantity()
  if not self.TabInfo then
    return
  end
  if self.TabInfo.Showtheme then
    for _, v in ipairs(self.TabInfo.Showtheme) do
      if v.data_type == "AUTHOR" and v.trans_data and v.trans_data.author_list then
        return #v.trans_data.author_list
      end
    end
  end
end
function logic_ugc_hot_page:CheckAllAuthorShow()
  if not self.TabInfo or not self.TabInfo.Showtheme then
    return
  end
  for _, v in ipairs(self.TabInfo.Showtheme) do
    if v.data_type == "AUTHOR" and v.trans_data and v.trans_data.only_config then
      return v.trans_data.only_config
    end
  end
  return 0
end
function logic_ugc_hot_page:GetHotAuthorList()
  if not self.TabInfo or not self.TabInfo.Showtheme then
    return
  end
  for k, v in ipairs(self.TabInfo.Showtheme) do
    if v.data_type == "AUTHOR" and v.trans_data and v.trans_data.author_list then
      return v.trans_data.author_list
    end
  end
end
function logic_ugc_hot_page:GetAuthorIndex(AuthorList, shouldUpdateIndex)
  if shouldUpdateIndex == false and next(self.AfterAuthorShowList) then
    return self.AfterAuthorShowList
  end
  local startIndex = 1
  if next(self.AfterAuthorShowList) then
    local lastAuthor = self.AfterAuthorShowList[#self.AfterAuthorShowList]
    for i, author in ipairs(AuthorList) do
      if author.author_uid == lastAuthor.author_uid then
        startIndex = i + 1
        break
      end
    end
  end
  local AuthorListData = {}
  local remaining = 3
  local i = startIndex
  while 0 < remaining and 0 < #AuthorList do
    if i > #AuthorList then
      i = 1
    end
    table.insert(AuthorListData, AuthorList[i])
    i = i + 1
    remaining = remaining - 1
  end
  self.AfterAuthorShowList = AuthorListData
  return AuthorListData
end
function logic_ugc_hot_page:GetAfterAuthorShowList()
  if self.AfterAuthorShowList then
    return self.AfterAuthorShowList
  end
  return nil
end
function logic_ugc_hot_page:CheckSelfTabInfo()
  if self.TabInfo.banner and self.TabInfo.theme and self:CheckThemeRefresh() then
    return true
  else
    log("logic_ugc_hot_page:CheckSelfTabInfo banner and theme is not nil")
    local TimeUtil = require("client.common.time_util")
    self.themeDataTimeStamp = TimeUtil.GetServerTimeInSec()
    return false
  end
end
function logic_ugc_hot_page:CheckThemeRefresh()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log("logic_ugc_hot_page:CheckThemeRefresh curTime:" .. tostring(curTime) .. ",self.themeDataTimeStamp:" .. tostring(self.themeDataTimeStamp) .. ",self.HotThemeListReqCD:" .. tostring(self.HotThemeListReqCD))
  return curTime <= self.themeDataTimeStamp + self.HotThemeListReqCD
end
function logic_ugc_hot_page:SetHotThemeGalleryParams(galleryParamConfig)
  log(bWriteLog and "logic_ugc_hot_page:SetHotThemeGalleryParams")
  if not galleryParamConfig then
    log(bWriteLog and "logic_ugc_hot_page:SetHotThemeGalleryParams galleryParamConfig is nil")
    return
  end
  if galleryParamConfig.HotThemeListReqCD and tonumber(galleryParamConfig.HotThemeListReqCD) then
    self.HotThemeListReqCD = tonumber(galleryParamConfig.HotThemeListReqCD)
    log(bWriteLog and "logic_ugc_hot_page:SetHotThemeGalleryParams self.HotThemeListReqCD:" .. tostring(self.HotThemeListReqCD))
  end
  if galleryParamConfig.HotThemeUniqueModNum and tonumber(galleryParamConfig.HotThemeUniqueModNum) then
    self.HotThemeUniqueModNum = tonumber(galleryParamConfig.HotThemeUniqueModNum)
    log(bWriteLog and "logic_ugc_hot_page:SetHotThemeGalleryParams self.HotThemeUniqueModNum:" .. tostring(self.HotThemeUniqueModNum))
  end
  if galleryParamConfig.HotThemeCarouselCD and tonumber(galleryParamConfig.HotThemeCarouselCD) then
    self.HotThemeCarouselCD = tonumber(galleryParamConfig.HotThemeCarouselCD) or 120
    log(bWriteLog and "logic_ugc_hot_page:SetHotThemeGalleryParams self.HotThemeCarouselCD:" .. tostring(self.HotThemeCarouselCD))
  end
end
function logic_ugc_hot_page:RollKOLTheme()
  log(bWriteLog and "logic_ugc_hot_page:RollKOLTheme")
  self.hot_theme = self:ProcessHotThemeData(self.cached_raw_hot_theme, true)
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  self.TabInfo.Showtheme = self.hot_theme
  local themeID = 0
  local TempThemeList = self:GetHotTabInfo()
  for k, temp in ipairs(TempThemeList) do
    if temp.style == config_ugc_hot_theme.ItemDataType.ModList and temp.data_type and temp.data_type == "KOL" then
      themeID = temp.themeId
      break
    end
  end
  log(bWriteLog and "logic_ugc_hot_page:RollKOLTheme themeID:" .. tostring(themeID))
  self:ClearKOLHotThemeCache(themeID)
  self:SetbIsRefreshTab(true)
  self:CheckAllBackToEvent()
end
function logic_ugc_hot_page:Clear()
  logic_ugc_hot_page.__super.Clear(self)
  self.AllReqTypeList = {}
  self.AfterAuthorShowList = {}
end
function logic_ugc_hot_page:ClearAllReqTypeList()
  self.AllReqTypeList = {}
end
function logic_ugc_hot_page:UGCHotThemeDataIntegration(hot_theme)
  if not hot_theme then
    log(bWriteLog and "logic_ugc_hot_page:UGCHotThemeDataIntegration hot_theme is nil")
    return
  end
  self.tableHotTheme = {}
  local TimeUtil = require("client.common.time_util")
  self.themeDataTimeStamp = TimeUtil.GetServerTimeInSec()
  self.HotThemeReqState = {}
  log_tree(bWriteLog and "logic_ugc_hot_page:UGCHotThemeDataIntegration hot_theme", hot_theme)
  self.cached_raw_  self.hot_theme = self:ProcessHotThemeData(hot_theme)
  log_tree(bWriteLog and "logic_ugc_hot_page:UGCHotThemeDataIntegration hot_theme new", self.hot_theme)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  for i, v in ipairs(hot_theme) do
    if v.data_type == "TRAFFIC_POOL_GROWTH" or v.data_type == "SPEC_THEME" then
      local Version = v.version or v.base and v.base.version or 0
      self.version = Version
    end
    if v.data_type == "PROMOTION" then
      self.trans_info = v.trans_info
    end
    if v.base and (v.base.id == Config_UGC.REGION_SELF_TAG_HOT_ID or v.base.id == Config_UGC.REGION_HOT_RECOMMEND_ID) and v.base.white_list then
      self.white_list = v.base.white_list
    end
  end
  log_tree("logic_ugc_hot_page:UGCHotThemeDataIntegration self.trans_info = ", self.trans_info)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_RSP)
  if self.AutoNextReqBundleID and 0 < self.AutoNextReqBundleID then
    local _, ReqIndex = self:GetHotTheme(self.AutoNextReqBundleID)
    self:ReqOneThemeNextPageModInfo(ReqIndex)
    self.AutoNextReqBundleID = nil
  end
  self:GetThemeModPlayer()
end
function logic_ugc_hot_page:ReqOneThemeNextPageModInfo(themeIndex)
  if not (themeIndex and self.hot_theme) or not self.hot_theme[themeIndex] then
    log(bWriteLog and "logic_ugc_hot_page:ReqOneThemeNextPageModInfo hot_theme is nil")
    return
  end
  local ThemeData = self.hot_theme[themeIndex]
  local ModIdList = ThemeData.mod_list or {}
  local IntModIDList = {}
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  for _, modId in ipairs(ModIdList) do
    table.insert(IntModIDList, tonumber(modId))
  end
  local ModInfoList = LogicUGC:BatchGetModInfo(IntModIDList, LogicUGC.C_ModListTypes.HotTheme, nil, {
    TypeParam = self:GetModBatchReqParam(themeIndex),
    bSplit = true
  })
  if ModInfoList and next(ModInfoList) then
    self:OnModInfoBatchRsp(IntModIDList, LogicUGC.C_ModListTypes.HotTheme, self:GetModBatchReqParam(themeIndex))
  end
end
function logic_ugc_hot_page:GetModBatchReqParam(themeIndex)
  if not themeIndex then
    return "themelist"
  end
  return "theme-" .. themeIndex
end
function logic_ugc_hot_page:GetThemeModPlayer()
  if not self.hot_theme then
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  for k, theme in pairs(self.hot_theme) do
    if theme.mod_list and #theme.mod_list >= 1 then
      logic_ugc_mode:BatchModPlayerReq(theme.mod_list)
    end
  end
end
function logic_ugc_hot_page:ProcessHotThemeData(hot_theme, bUserRoll)
  if not hot_theme then
    log(bWriteLog and "logic_ugc_hot_page:ProcessHotThemeData hot_theme is nil")
    return
  end
  hot_theme = self:RandomSelectKOL(hot_theme, bUserRoll)
  table.sort(hot_theme, function(a, b)
    local aRankValue = a.base and a.base.rank_value or 0
    local bRankValue = b.base and b.base.rank_value or 0
    return aRankValue < bRankValue
  end)
  for i, v in ipairs(hot_theme) do
    if v.base and not v.base.pos then
      v.base.pos = i + 0.5
    end
  end
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  log_tree("logic_ugc_hot_page:ProcessHotThemeData DataMgr.newbieGuide ", DataMgr.newbieGuide)
  if logic_ugc_newbie_guide:IsOngoingStrongGuide() then
    for _, v in ipairs(hot_theme) do
      if v.data_type and v.data_type == "NEWBIE" then
        v.base.pos = -9999
      end
    end
  else
    for i, v in ipairs(hot_theme) do
      if v.data_type and v.data_type == "NEWBIE" then
        table.remove(hot_theme, i)
        break
      end
    end
  end
  for _, v in ipairs(hot_theme) do
    if v.data_type and (v.data_type == "FRIEND_BASE_REC_V2" or v.data_type == "FRIEND_HOT_RECOMMEND") and self:CheckFriendMod(v.mod_list) then
      v.base.pos = -999
    end
  end
  table.sort(hot_theme, function(a, b)
    local aPos = a.base and type(a.base.pos) == "number" and a.base.pos or 0
    local bPos = b.base and type(b.base.pos) == "number" and b.base.pos or 0
    return aPos < bPos
  end)
  local newHotThemeList
  if self.HotThemeUniqueModNum and self.HotThemeUniqueModNum > 0 then
    newHotThemeList = {}
    local allModList = {}
    for _, themeData in ipairs(hot_theme) do
      local modList = themeData.mod_list or {}
      local newModList = {}
      for _, modId in ipairs(modList) do
        local ModID = tonumber(modId)
        if #newModList < self.HotThemeUniqueModNum then
          if allModList[ModID] == nil then
            table.insert(newModList, ModID)
            allModList[ModID] = 1
          end
        else
          table.insert(newModList, ModID)
        end
      end
      themeData.mod_list = newModList
      local modNum = #newModList
      local displayMinNum = themeData.base and themeData.base.display_min or 1
      local AddType = themeData.data_type and themeData.data_type == "RANK_OPE" or themeData.data_type and themeData.data_type == "AUTHOR"
      if themeData.base and modNum >= displayMinNum or AddType then
        table.insert(newHotThemeList, themeData)
      end
    end
  else
    newHotThemeList = hot_theme
  end
  return newHotThemeList
end
function logic_ugc_hot_page:RandomSelectKOL(hot_theme, bUserRoll)
  print(bWriteLog and "logic_ugc_hot_page:RandomSelectKOL")
  local Ret = {}
  local KOLThemes = {}
  for _, themeInfo in ipairs(hot_theme) do
    local DataType = themeInfo.data_type
    if DataType == "KOL" then
      table.insert(KOLThemes, themeInfo)
    else
      table.insert(Ret, themeInfo)
    end
  end
  local SelectElement, SelectElementId
  if not bUserRoll then
    self.LastrandomIndex = nil
    local ThemeId = self:GetLastSelectKOLThemeId()
    for Idx, Theme in ipairs(KOLThemes) do
      if Theme.base and Theme.base.id == ThemeId then
        print(bWriteLog and "logic_ugc_hot_page:RandomSelectKOL Cache hit " .. tostring(Idx))
        self.LastrandomIndex = Idx
        break
      end
    end
  end
  if 1 < #KOLThemes then
    local randomIndex = 1
    if self.LastrandomIndex ~= nil then
      if bUserRoll then
        randomIndex = math.random(1, #KOLThemes - 1)
        if randomIndex >= self.LastrandomIndex then
          randomIndex = randomIndex + 1
        end
      else
        randomIndex = self.LastrandomIndex
      end
    else
      randomIndex = math.random(1, #KOLThemes)
    end
    SelectElement = KOLThemes[randomIndex]
    self.Last  elseif #KOLThemes == 1 then
    table.insert(Ret, KOLThemes[1])
    self.LastrandomIndex = 1
  end
  if SelectElement then
    SelectElementId = SelectElement.base.id
    table.insert(Ret, SelectElement)
    self:SaveLastSelectKOLThemeId(SelectElementId)
  end
  return Ret
end
function logic_ugc_hot_page:CheckFriendMod(mod_list)
  if not mod_list then
    log(bWriteLog and "logic_ugc_hot_page:CheckFriendMod mod_list is nil")
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local FriendPlayingModList = logic_ugc_mode:GetFriendPlayingModList()
  for k, modID in pairs(mod_list) do
    if FriendPlayingModList[modID] then
      return true
    end
  end
  return false
end
function logic_ugc_hot_page:GetNewOneThemeShowModData(HotThemeData, bRefresh)
  if not HotThemeData or not next(HotThemeData) then
    log(bWriteLog and "logic_ugc_hot_page:GetNewOneThemeShowModData HotThemeData is nil")
    return
  end
  log_tree("logic_ugc_hot_page:GetNewOneThemeShowModData HotThemeData", HotThemeData)
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  local ThemeRefreshModNum
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  if LogicUGCHall:CheckIsOpen() then
    ThemeRefreshModNum = config_ugc_hot_theme.NewThemeRefreshModNum
  else
    ThemeRefreshModNum = config_ugc_hot_theme.ThemeRefreshModNum
  end
  local themeId = HotThemeData.base.id
  local themeData = {}
  for i, data in ipairs(self.hot_theme) do
    if data.base.id == themeId then
      themeData = data
      break
    end
  end
  log(bWriteLog and "logic_ugc_hot_page:GetNewOneThemeShowModData themeId:" .. tostring(themeId))
  log_tree("logic_ugc_hot_page:GetNewOneThemeShowModData themeData ", themeData)
  local modIdList = themeData.mod_list or {}
  local showList = {}
  local bShowAuthor = themeData.base and themeData.base.show_author == 1
  local uidsToReqProfile = {}
  self.hasReqProfileUidList = self.hasReqProfileUidList or {}
  local bShowFeedbackPanel = themeData.base and themeData.base.id == C_GUESS_YOU_LIKE_THEME_ID
  local bCompleted = false
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local flag = false
  local ModIndex
  if not bRefresh then
    flag = false
  elseif self.tableHotTheme[themeId] and next(self.tableHotTheme[themeId]) then
    for key, ModId in ipairs(modIdList) do
      if ModId == self.tableHotTheme[themeId][#self.tableHotTheme[themeId]] then
        ModIndex = key
        if ModIndex == #modIdList then
          flag = true
          break
        end
        ModIndex = key + 1
      end
    end
  end
  local insertModInfo = function(modId)
    local modInfo = LogicUGC:GetModByAllCache(tonumber(modId))
    if modInfo and modInfo.pub_mod_meta and not modInfo.pub_mod_meta.perf_off_banner then
      for key, value in ipairs(showList) do
        if value.modInfo.mod_id == modId then
          return
        end
      end
      if not self.DisplayedThemeModIDList[modId] then
        self.DisplayedThemeModIDList[modId] = {}
      end
      self.DisplayedThemeModIDList[modId] = true
      table.insert(showList, {
        hotThemeId = themeId,
        hotThemeDataType = themeData.data_type,
        modInfo = modInfo.pub_mod_meta,
        bShowFeedBackPanel = bShowFeedbackPanel
      })
      if bShowAuthor and modInfo.pub_mod_meta.base and modInfo.pub_mod_meta.base.uid then
        local uid = modInfo.pub_mod_meta.base.uid
        local profile = logic_profile:GetLocalProfile(uid)
        if not profile and not self.hasReqProfileUidList[uid] then
          self.hasReqProfileUidList[uid] = 1
          uidsToReqProfile[uid] = 1
        end
      end
    else
      if not self.DisplayedThemeModIDList[modId] then
        self.DisplayedThemeModIDList[modId] = {}
      end
      self.DisplayedThemeModIDList[modId] = true
    end
  end
  local fillShowList = function(startIndex)
    local num = 0
    for key, value in ipairs(modIdList) do
      if self.DisplayedThemeModIDList[value] then
        num = num + 1
      end
    end
    if num >= #modIdList then
      bCompleted = true
    end
    for i = startIndex, #modIdList do
      log(bWriteLog and "logic_ugc_hot_page:GetNewOneThemeShowModData bCompleted = " .. tostring(bCompleted))
      log(bWriteLog and "logic_ugc_hot_page:GetNewOneThemeShowModData self.DisplayedThemeModIDList[" .. modIdList[i] .. "] = " .. tostring(self.DisplayedThemeModIDList[modIdList[i]]))
      if bCompleted or not self.DisplayedThemeModIDList[modIdList[i]] then
        insertModInfo(modIdList[i])
      end
      if #showList >= ThemeRefreshModNum then
        break
      end
    end
  end
  if not flag then
    fillShowList(ModIndex or 1)
    if ThemeRefreshModNum > #showList then
      fillShowList(1)
    end
  else
    fillShowList(1)
  end
  self.tableHotTheme[themeId] = {}
  for key, value in ipairs(showList) do
    table.insert(self.tableHotTheme[themeId], value.modInfo.mod_id)
  end
  self.ExposureModList[themeId] = showList
  self:ReqAuthorProfile(uidsToReqProfile)
  return showList
end
function logic_ugc_hot_page:GetNewHotThemeModList(HotThemeData)
  if not HotThemeData or not next(HotThemeData) then
    log(bWriteLog and "logic_ugc_hot_page:GetNewHotThemeModList HotThemeData is nil")
    return
  end
  local themeId = HotThemeData.base.id
  local themeData = {}
  for i, data in ipairs(self.hot_theme) do
    if data.base.id == themeId then
      themeData = data
      break
    end
  end
  if not (self.tableHotTheme and next(self.tableHotTheme) and self.tableHotTheme[themeId]) or not next(self.tableHotTheme[themeId]) then
    log(bWriteLog and "logic_ugc_hot_page:GetNewHotThemeModList self.tableHotTheme is nil")
    return
  end
  log_tree("logic_ugc_hot_page:GetNewHotThemeModList self.tableHotTheme", self.tableHotTheme)
  log(bWriteLog and "logic_ugc_hot_page:GetNewHotThemeModList themeId:" .. tostring(themeId))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ShowHotTheme = {}
  log_tree("logic_ugc_hot_page:GetNewHotThemeModList themeData ", themeData)
  local bShowAuthor = themeData.base and themeData.base.show_author == 1
  local uidsToReqProfile = {}
  self.hasReqProfileUidList = self.hasReqProfileUidList or {}
  local bShowFeedbackPanel = themeData.base and themeData.base.id == C_GUESS_YOU_LIKE_THEME_ID
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, ModId in ipairs(self.tableHotTheme[themeId]) do
    local modInfo = LogicUGC:GetModByAllCache(tonumber(ModId))
    if modInfo and modInfo.pub_mod_meta and not modInfo.pub_mod_meta.perf_off_banner then
      table.insert(ShowHotTheme, {
        hotThemeId = themeId,
        hotThemeDataType = themeData.data_type,
        modInfo = modInfo.pub_mod_meta,
        bShowFeedBackPanel = bShowFeedbackPanel
      })
      if bShowAuthor and modInfo.pub_mod_meta.base and modInfo.pub_mod_meta.base.uid then
        local uid = modInfo.pub_mod_meta.base.uid
        local profile = logic_profile:GetLocalProfile(uid)
        if not profile and not self.hasReqProfileUidList[uid] then
          self.hasReqProfileUidList[uid] = 1
          uidsToReqProfile[uid] = 1
        end
      end
    end
  end
  self:ReqAuthorProfile(uidsToReqProfile)
  return ShowHotTheme
end
function logic_ugc_hot_page:ReqAuthorProfile(uidList)
  if not uidList or not next(uidList) then
    log(bWriteLog and "logic_ugc_hot_page:ReqAuthorProfile uidList is invalid")
    return
  end
  local reqList = {}
  for uid, _ in pairs(uidList) do
    table.insert(reqList, uid)
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(reqList, function(listInfo)
    if listInfo and 0 < #listInfo then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_AUTHOR_PROFILE_UPDATE, listInfo)
    end
  end, Enum_PROFILE_REPORT_CFG.UGC)
end
function logic_ugc_hot_page:GetHotSpecialThemeShowData(HotThemeData)
  if not HotThemeData or not next(HotThemeData) then
    log(bWriteLog and "logic_ugc_hot_page:GetHotSpecialThemeShowData HotThemeData is nil")
    return
  end
  log_tree("logic_ugc_hot_page:GetHotSpecialThemeShowData HotThemeData", HotThemeData)
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  local themeId = HotThemeData.base.id
  local themeData = {}
  for i, data in ipairs(self.hot_theme) do
    if data.base.id == themeId then
      themeData = data
      break
    end
  end
  log(bWriteLog and "logic_ugc_hot_page:GetHotSpecialThemeShowData themeId:" .. tostring(themeId))
  log_tree("logic_ugc_hot_page:GetHotSpecialThemeShowData themeData ", themeData)
  local modIdList = themeData.mod_list or {}
  local showList = {}
  local bShowAuthor = themeData.base and themeData.base.show_author == 1
  local uidsToReqProfile = {}
  self.hasReqProfileUidList = self.hasReqProfileUidList or {}
  local bShowFeedbackPanel = themeData.base and themeData.base.id == C_GUESS_YOU_LIKE_THEME_ID
  local bCompleted = false
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, modId in ipairs(modIdList) do
    local modInfo = LogicUGC:GetModByAllCache(tonumber(modId))
    if modInfo and modInfo.pub_mod_meta and not modInfo.pub_mod_meta.perf_off_banner then
      table.insert(showList, {
        hotThemeId = themeId,
        hotThemeDataType = themeData.data_type,
        modInfo = modInfo.pub_mod_meta,
        bShowFeedBackPanel = bShowFeedbackPanel
      })
      if bShowAuthor and modInfo.pub_mod_meta.base and modInfo.pub_mod_meta.base.uid then
        local uid = modInfo.pub_mod_meta.base.uid
        local profile = logic_profile:GetLocalProfile(uid)
        if not profile and not self.hasReqProfileUidList[uid] then
          self.hasReqProfileUidList[uid] = 1
          uidsToReqProfile[uid] = 1
        end
      end
    end
  end
  self.tableHotTheme[themeId] = {}
  for key, value in ipairs(showList) do
    table.insert(self.tableHotTheme[themeId], value.modInfo.mod_id)
  end
  self.ExposureModList[themeId] = showList
  self:ReqAuthorProfile(uidsToReqProfile)
  return showList
end
function logic_ugc_hot_page:SaveLastSelectKOLThemeId(ThemeId)
  print(bWriteLog and "logic_ugc_hot_page:SaveLastSelectKOLThemeId " .. tostring(ThemeId))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({KOLThemeId = ThemeId}, PlayerPrefsSystem.ePlayerPrefsType.eUGCThemeKOL)
end
function logic_ugc_hot_page:GetLastSelectKOLThemeId()
  print(bWriteLog and "logic_ugc_hot_page:GetLastSelectKOLThemeId")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCThemeKOL) or {}
  print(bWriteLog and "logic_ugc_hot_page:GetLastSelectKOLThemeId " .. tostring(saveData.KOLThemeId))
  return saveData.KOLThemeId
end
local tablelength = function(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end
local C_MAX_BAN_MODIDS = 2000
function logic_ugc_hot_page:SetBanGuessYouLikeModId(modid)
  print(bWriteLog and "logic_ugc_hot_page:SetBanGuessYouLikeModId " .. tostring(modid))
  local modids = self:GetBanGuessYouLikeModIds()
  if tablelength(modids) < C_MAX_BAN_MODIDS then
    modids[tostring(modid)] = true
  else
    print(bWriteLog and "logic_ugc_hot_page:SetBanGuessYouLikeModId Upperlimit" .. tostring(modid))
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({BanModIds = modids}, PlayerPrefsSystem.ePlayerPrefsType.eUGCGuessULike)
end
function logic_ugc_hot_page:GetBanGuessYouLikeModIds()
  print(bWriteLog and "logic_ugc_hot_page:GetBanGuessYouLikeModIds")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCGuessULike) or {}
  log_tree("logic_ugc_hot_page:GetBanGuessYouLikeModIds", saveData.BanModIds)
  return saveData.BanModIds or {}
end
function logic_ugc_hot_page:SetHotThemeEntryStamp()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.HotThemeEntryStamp = curTime
  log(bWriteLog and "logic_ugc_hot_page:SetHotThemeEntryStamp self.HotThemeEntryStamp = " .. tostring(self.HotThemeEntryStamp))
end
function logic_ugc_hot_page:SetHotThemeDepartureStamp()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.HotThemeDepartureStamp = curTime
  log(bWriteLog and "logic_ugc_hot_page:SetHotThemeDepartureStamp self.HotThemeDepartureStamp = " .. tostring(self.HotThemeDepartureStamp))
end
function logic_ugc_hot_page:CheckTimeInterval(style)
  if not self.HotThemeEntryStamp or not self.HotThemeDepartureStamp then
    log(bWriteLog and "logic_ugc_hot_page:CheckTimeInterval HotThemeEntryStamp or HotThemeDepartureStamp is nil")
    return false
  end
  log(bWriteLog and "logic_ugc_hot_page:CheckTimeInterval self.HotThemeEntryStamp = " .. tostring(self.HotThemeEntryStamp))
  log(bWriteLog and "logic_ugc_hot_page:CheckTimeInterval elf.HotThemeDepartureStamp = " .. tostring(self.HotThemeDepartureStamp))
  log(bWriteLog and "logic_ugc_hot_page:CheckTimeInterval return value = " .. tostring(self.HotThemeEntryStamp <= self.HotThemeDepartureStamp + self.HotThemeCarouselCD))
  if style == 2 then
    return self.HotThemeEntryStamp <= self.HotThemeDepartureStamp + self.HotThemeCarouselCD
  else
    return self.HotThemeEntryStamp <= self.HotThemeDepartureStamp + self.HotAuthorCarouselCD
  end
end
function logic_ugc_hot_page:Report()
  if not next(self.report) then
    log(bWriteLog and "logic_ugc_hot_page:Report self.report is nil")
    return
  end
  if self.version == 0 then
    log(bWriteLog and "logic_ugc_hot_page:Report self.version is 0")
    return
  end
  log_tree("logic_ugc_hot_page:Report self.report", self.report)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_report_rec_mod_view_req(self.version, self.report)
  self:ClearReport()
end
function logic_ugc_hot_page:ClearReport()
  self.report = {}
end
function logic_ugc_hot_page:AddReportDetail(mod)
  self:AddReport(mod, "detail")
end
function logic_ugc_hot_page:AddReportSelect(mod)
  self:AddReport(mod, "select")
end
function logic_ugc_hot_page:AddReportCollect(mod)
  self:AddReport(mod, "collect")
end
function logic_ugc_hot_page:AddReportExpose(mod)
  self:AddReport(mod, "expose")
end
function logic_ugc_hot_page:AddReport(mod, key)
  if not self.report then
    self.report = {}
  end
  if not mod then
    return
  end
  if not self.report[mod] then
    self.report[mod] = self:FormatReportItem()
  end
  self.report[mod][key] = 1
end
function logic_ugc_hot_page:FormatReportItem()
  return {
    detail = 0,
    select = 0,
    match = 0,
    collect = 0,
    expose = 0
  }
end
function logic_ugc_hot_page:SetHotThemeReqState(HotThemeData)
  local themeID = HotThemeData.base.id
  self.HotThemeReqState[themeID] = true
end
function logic_ugc_hot_page:GetHotThemeReqState(HotThemeData)
  local themeID = HotThemeData.base.id
  return self.HotThemeReqState[themeID]
end
function logic_ugc_hot_page:ClearKOLHotThemeCache(themeID)
  if themeID then
    self.tableHotTheme[themeID] = nil
  end
end
function logic_ugc_hot_page:ClearDisplayedThemeModIDListCache()
  log(bWriteLog and "logic_ugc_hot_page:ClearDisplayedThemeModIDListCache")
  self.DisplayedThemeModIDList = {}
end
function logic_ugc_hot_page:GetHotThemeList()
  return self.hot_theme
end
function logic_ugc_hot_page:GetShowTableHotTheme(themeId)
  return self.tableHotTheme[themeId]
end
function logic_ugc_hot_page:GetHotTheme(ID)
  if not ID then
    return nil
  end
  if not self.hot_theme then
    return nil
  end
  for i, HotThemeData in ipairs(self.hot_theme) do
    if HotThemeData.base.id == ID then
      return HotThemeData, i
    end
  end
  return nil
end
function logic_ugc_hot_page:GetHotThemeListNum()
  if not self.hot_theme then
    return 0
  end
  return #self.hot_theme
end
function logic_ugc_hot_page:CheckIsNewHotThemeOpen()
  if not DataMgr or not DataMgr.ugc_hot_theme then
    log(bWriteLog and "logic_ugc_hot_page:CheckIsNewHotThemeOpen DataMgr.roleData is nil")
    return false
  end
  return DataMgr.ugc_hot_theme == 1
end
function logic_ugc_hot_page:GetSelectHotThemeBundleName(BundleID)
  local BundleName = ""
  local Bundle = self:GetHotTheme(BundleID)
  if Bundle then
    BundleName = Bundle.base.name
  end
  return BundleName
end
function logic_ugc_hot_page:GetSelectThemeBundleModList(BundleID)
  local Bundle = self:GetHotTheme(BundleID)
  if Bundle then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local IntModList = {}
    for i, v in ipairs(Bundle.mod_list) do
      local ModID = tonumber(v)
      local ModInfo = LogicUGC:GetModByAllCache(ModID)
      if ModInfo and ModInfo.pub_mod_meta and not ModInfo.pub_mod_meta.perf_off_banner then
        table.insert(IntModList, ModID)
      end
    end
    return IntModList
  end
  return nil
end
function logic_ugc_hot_page:CheckHotThemeModListReady(BundleID)
  if not self:GetHotTheme(BundleID) then
    self.AutoNextReq    self:send_ugc_gallery_hot_theme_req()
    return false
  end
  return true
end
function logic_ugc_hot_page:send_ugc_gallery_hot_theme_req()
  if self:CheckThemeDataValid() then
    log(bWriteLog and "logic_ugc_hot_page:send_ugc_gallery_hot_theme_req dataValid no need to req")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_RSP)
    self:GetThemeModPlayer()
    return
  end
  log(bWriteLog and "logic_ugc_hot_page:send_ugc_gallery_hot_theme_req")
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_gallery_hot_theme_req()
end
function logic_ugc_hot_page:CheckThemeDataValid()
  if not self.hot_theme or #self.hot_theme <= 0 then
    log(bWriteLog and "logic_ugc_hot_page:CheckThemeDataValid hot_theme is nil")
    return false
  end
  if not self.themeDataTimeStamp then
    log(bWriteLog and "logic_ugc_hot_page:CheckThemeDataValid themeDataTimeStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.themeDataTimeStamp + self.HotThemeListReqCD
end
function logic_ugc_hot_page:GetSelectBannerBundleName(BundleID)
  local BundleName = ""
  local Bundle = self:GetBannerBundle(BundleID)
  if Bundle then
    BundleName = Bundle.title
  end
  return BundleName
end
function logic_ugc_hot_page:GetSelectBannerBundleModList(BundleID)
  local Bundle = self:GetBannerBundle(BundleID)
  if Bundle then
    local StringUtil = require("common.string_util")
    local ModList = StringUtil.Split(Bundle.mod_list, "|")
    log_tree(bWriteLog and "logic_ugc_hot_page:GetSelectBundleModList", ModList)
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local IntModList = {}
    for i, v in ipairs(ModList) do
      local ModID = tonumber(v)
      local ModInfo = LogicUGC:GetModByAllCache(ModID)
      if ModInfo and ModInfo.pub_mod_meta and not ModInfo.pub_mod_meta.perf_off_banner then
        table.insert(IntModList, ModID)
      end
    end
    log_tree(bWriteLog and "logic_ugc_hot_page:GetSelectBundleModList Int After", IntModList)
    return IntModList
  end
  return nil
end
function logic_ugc_hot_page:CheckBannerModListReady(BundleID)
  if not self:GetBannerBundle(BundleID) then
    self:send_ugc_mixed_banner_req()
    return false
  end
  return true
end
function logic_ugc_hot_page:send_ugc_mixed_banner_req()
  log(bWriteLog and "logic_ugc_hot_page.send_ugc_mixed_banner_req start")
  if self.showList then
    log(bWriteLog and "logic_ugc_hot_page.send_ugc_mixed_banner_req have data")
    return
  end
  log(bWriteLog and "logic_ugc_hot_page.send_ugc_mixed_banner_req need data")
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_mixed_banner_req()
end
function logic_ugc_hot_page:UGCBannerDataIntegration(mixed_banner_list)
  if not mixed_banner_list then
    log(bWriteLog and "logic_ugc_hot_page:UGCBannerDataIntegration mixed_banner_list = nil")
    return
  end
  self.  print(bWriteLog and "logic_ugc_hot_page:UGCBannerDataIntegration #mixed_banner_list = " .. tostring(#mixed_banner_list))
  self:SortNeedShowDataUGC()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_BANNER_LIST)
end
function logic_ugc_hot_page:SortNeedShowDataUGC()
  self.showList = {}
  self.bannerData = {}
  self.BannerThemeData = {}
  self.newThemeData = {}
  self.activityData = nil
  local _tempActivity = {}
  local _tempTheme = {}
  local _tempBanner = {}
  for key, value in ipairs(self.mixed_banner_list) do
    if value.set_type == "banner" then
      table.insert(_tempBanner, value)
    elseif value.set_type == "theme" then
      table.insert(self.BannerThemeData, value)
    elseif value.set_type == "hall" then
    else
      table.insert(_tempTheme, value)
    end
  end
  table.sort(self.BannerThemeData, function(a, b)
    return a.rank_value < b.rank_value
  end)
  table.sort(_tempBanner, function(a, b)
    return a.rank_value < b.rank_value
  end)
  local rank_value = 0
  if _tempBanner[1] and _tempBanner[1].rank_value then
    rank_value = _tempBanner[1].rank_value
  end
  self.bannerData = {
    set_type = "banner",
    showList = _tempBanner,
      }
  rank_value = 0
  if _tempTheme[1] and _tempTheme[1].rank_value then
    rank_value = _tempTheme[1].rank_value
  end
  if self.BannerThemeData and next(self.BannerThemeData) then
    local tempTheme = self.BannerThemeData[1]
    table.insert(_tempTheme, tempTheme)
  else
    log(bWriteLog and "logic_ugc_hot_page:SortNeedShowDataUGC theme count = 0")
  end
  table.sort(_tempTheme, function(a, b)
    return a.rank_value < b.rank_value
  end)
  self.newThemeData = {
    set_type = "theme",
    rank_value = rank_value,
    showList = _tempTheme
  }
  if 0 < #_tempBanner then
    table.insert(self.showList, self.bannerData)
  end
  if 0 < #_tempTheme then
    table.insert(self.showList, self.newThemeData)
  end
end
function logic_ugc_hot_page:GetNeedReqModIDs()
  if not self.mixed_banner_list or not self.showList then
    return nil
  end
  local StringUtil = require("common.string_util")
  local modid_set = {}
  local modid_list = {}
  for key, value in ipairs(self.mixed_banner_list) do
    if value.mod_list and value.set_type == "theme" and value.mod_list then
      local str_list = StringUtil.Split(value.mod_list, "|")
      for _k, _v in ipairs(str_list) do
        if not self:ValueIsInTable(modid_list, tonumber(_v)) then
          table.insert(modid_list, tonumber(_v))
          break
        end
      end
    end
  end
  for _, banner_data in ipairs(self.showList) do
    for _, item in ipairs(banner_data.showList) do
      if item.mod_list then
        local mod_ids = StringUtil.Split(item.mod_list, "|")
        for _, mod_id_str in ipairs(mod_ids) do
          local mod_id = tonumber(mod_id_str)
          if mod_id and not modid_set[mod_id] then
            modid_set[mod_id] = true
            table.insert(modid_list, mod_id)
          end
        end
      end
    end
  end
  return modid_list
end
function logic_ugc_hot_page:ValueIsInTable(myTable, myValue)
  if 0 < #myTable then
    for index, value in ipairs(myTable) do
      if value == myValue then
        return true
      end
    end
  end
  return false
end
function logic_ugc_hot_page:GetBannerThemeData()
  return self.BannerThemeData
end
function logic_ugc_hot_page:GetBannerBundle(BundleID)
  if not BundleID then
    return nil
  end
  if #self.BannerThemeData == 0 then
    return nil
  end
  for i, v in ipairs(self.BannerThemeData) do
    if v.id == BundleID then
      return v
    end
  end
  return nil
end
function logic_ugc_hot_page:SetSelectThemeBanner()
  log(bWriteLog and "logic_ugc_hot_page:SetSelectThemeBanner")
  if #self.BannerThemeData > 1 then
    self.themeIndex = self.themeIndex + 1
  end
  if self.themeIndex > #self.BannerThemeData then
    self.themeIndex = 1
  end
  for _, temp in ipairs(self.showList) do
    if temp.set_type == "theme" then
      for index, themeData in ipairs(temp.showList) do
        if themeData.set_type == "theme" then
          temp.showList[index] = self.BannerThemeData[self.themeIndex]
        end
      end
    end
  end
  log_tree("logic_ugc_hot_page:SetThemeIndex self.showList = ", self.showList)
  return self.showList
end
local class = require("class")
local logic_ugc_wowpage = require("client.slua.logic.ugc.logic_ugc_wowpage")
local Clogic_ugc_hot_page = class(logic_ugc_wowpage, nil, logic_ugc_hot_page)
return Clogic_ugc_hot_page