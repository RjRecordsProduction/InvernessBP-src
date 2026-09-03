local logic_ugc_hot_theme = {}
function logic_ugc_hot_theme:DefineAndResetData()
  self.hot_theme = nil
  self.hot_exposure_theme = {}
  self.ExposureModList = {}
  self.themeScrollOffsetCache = nil
  self.hasReqProfileUidList = nil
  self.themeDataTimeStamp = nil
  self.HotThemeListReqCD = 3
  self.HotThemeUniqueModNum = 6
  self.AutoNextReqBundleID = nil
  self.tableHotTheme = {}
  self.HotThemeCarouselCD = 120
  self.HotAuthorCarouselCD = 300
  self.HotThemeEntryStamp = nil
  self.HotThemeDepartureStamp = nil
  self.report = {}
  self.version = 0
  self.trans_info = {}
  self.HotThemeReqState = {}
  self.DisplayedThemeModIDList = {}
end
function logic_ugc_hot_theme:OnLogOut()
  log(bWriteLog and "logic_ugc_hot_theme:OnLogOut")
  self:ClearCacheData()
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
end
function logic_ugc_hot_theme:ClearCacheData()
  self.themeScrollOffsetCache = nil
  self.hasReqProfileUidList = nil
  self:ClearDisplayedThemeModIDListCache()
end
function logic_ugc_hot_theme:GetHotThemeList()
  return self.hot_theme
end
function logic_ugc_hot_theme:GetShowTableHotTheme(themeId)
  return self.tableHotTheme[themeId]
end
function logic_ugc_hot_theme:GetHotTheme(ID)
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
function logic_ugc_hot_theme:GetHotThemeListNum()
  if not self.hot_theme then
    return 0
  end
  return #self.hot_theme
end
function logic_ugc_hot_theme:CheckIsNewHotThemeOpen()
  if not DataMgr or not DataMgr.ugc_hot_theme then
    log(bWriteLog and "logic_ugc_hot_theme:CheckIsNewHotThemeOpen DataMgr.roleData is nil")
    return false
  end
  return DataMgr.ugc_hot_theme == 1
end
function logic_ugc_hot_theme:GetSelectBundleName(BundleID)
  local BundleName = ""
  local Bundle = self:GetHotTheme(BundleID)
  if Bundle then
    BundleName = Bundle.base.name
  end
  return BundleName
end
function logic_ugc_hot_theme:GetSelectBundleModList(BundleID)
  local Bundle = self:GetHotTheme(BundleID)
  if Bundle then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local IntModList = {}
    for i, v in ipairs(Bundle.mod_list) do
      local ModID = tonumber(v)
      local ModInfo = LogicUGC:GetModByAllCache(ModID)
      if ModInfo then
        table.insert(IntModList, ModID)
      end
    end
    return IntModList
  end
  return nil
end
function logic_ugc_hot_theme:CheckModListReady(BundleID)
  if not self:GetHotTheme(BundleID) then
    self.AutoNextReq    self:send_ugc_gallery_hot_theme_req()
    return false
  end
  return true
end
function logic_ugc_hot_theme:SetHotThemeGalleryParams(galleryParamConfig)
  log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeGalleryParams")
  if not galleryParamConfig then
    log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeGalleryParams galleryParamConfig is nil")
    return
  end
  if galleryParamConfig.HotThemeListReqCD and tonumber(galleryParamConfig.HotThemeListReqCD) then
    self.HotThemeListReqCD = tonumber(galleryParamConfig.HotThemeListReqCD)
    log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeGalleryParams self.HotThemeListReqCD:" .. tostring(self.HotThemeListReqCD))
  end
  if galleryParamConfig.HotThemeUniqueModNum and tonumber(galleryParamConfig.HotThemeUniqueModNum) then
    self.HotThemeUniqueModNum = tonumber(galleryParamConfig.HotThemeUniqueModNum)
    log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeGalleryParams self.HotThemeUniqueModNum:" .. tostring(self.HotThemeUniqueModNum))
  end
  if galleryParamConfig.HotThemeCarouselCD and tonumber(galleryParamConfig.HotThemeCarouselCD) then
    self.HotThemeCarouselCD = tonumber(galleryParamConfig.HotThemeCarouselCD) or 120
    log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeGalleryParams self.HotThemeCarouselCD:" .. tostring(self.HotThemeCarouselCD))
  end
end
function logic_ugc_hot_theme:InsertCurShowThemeListData(showList, startThemeIndex, endThemeIndex)
  showList = showList or {}
  if not self.hot_theme then
    log(bWriteLog and "logic_ugc_hot_theme:GetCurShowThemeListData hot_theme is nil")
    return showList
  end
  if not (endThemeIndex and not (endThemeIndex <= 0) and startThemeIndex) or startThemeIndex <= 0 or endThemeIndex < startThemeIndex then
    log(bWriteLog and "logic_ugc_hot_theme:GetCurShowThemeListData params is invalid")
    return showList
  end
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  for i = startThemeIndex, endThemeIndex do
    if self.hot_theme[i] and self.hot_theme[i].mod_list then
      local modIdList = self.hot_theme[i].mod_list
      local modInfoList = {}
      local hasModToShow = false
      hasModToShow = self.hot_theme[i].data_type and self.hot_theme[i].data_type == "RANK_OPE" or self.hot_theme[i].data_type and self.hot_theme[i].data_type == "AUTHOR"
      for _, modId in ipairs(modIdList) do
        local modInfo = LogicUGC:GetModByAllCache(tonumber(modId))
        if modInfo and modInfo.pub_mod_meta then
          hasModToShow = true
          break
        end
      end
      if hasModToShow then
        table.insert(showList, {
          themeIndex = i,
          themeName = self.hot_theme[i].base and self.hot_theme[i].base.name,
          base = self.hot_theme[i].base,
          dataList = modIdList,
          style = self.hot_theme[i].data_type == "AUTHOR" and config_ugc_hot_theme.ItemDataType.AuthorList or config_ugc_hot_theme.ItemDataType.ModList,
          themeId = self.hot_theme[i].base and self.hot_theme[i].base.id,
          data_type = self.hot_theme[i].data_type or "",
          trans_data = self.hot_theme[i].trans_data or nil
        })
      else
        log(bWriteLog and "logic_ugc_hot_theme:GetCurShowThemeListData no mod info found themeIndex:" .. tostring(i))
        break
      end
    end
  end
  return showList
end
function logic_ugc_hot_theme:InsertRecommendAuthorData(data)
  if not self.hot_theme then
    log(bWriteLog and "logic_ugc_hot_theme:InsertRecommendAuthorData hot_theme is nil")
    return data
  end
  if data and 1 <= #data then
    local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
    local DataList = data
    for k, v in pairs(data) do
      if data.style == config_ugc_hot_theme.ItemDataType.AuthorList then
        return DataList
      end
    end
    for k, v in pairs(self.hot_theme) do
      if v.data_type == "AUTHOR" then
        table.insert(DataList, {
          themeIndex = k,
          themeName = v.base and v.base.name,
          base = v.base,
          style = config_ugc_hot_theme.ItemDataType.AuthorList,
          themeId = v.base and v.base.id,
          data_type = v.data_type or "",
          trans_data = v.trans_data or nil
        })
      end
    end
    return DataList
  else
    local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
    local DataList = {}
    for k, v in pairs(self.hot_theme) do
      if v.data_type == "AUTHOR" then
        table.insert(DataList, {
          themeIndex = k,
          themeName = v.base and v.base.name,
          base = v.base,
          style = config_ugc_hot_theme.ItemDataType.AuthorList,
          themeId = v.base and v.base.id,
          data_type = v.data_type or "",
          trans_data = v.trans_data or nil
        })
      end
    end
    return DataList
  end
end
function logic_ugc_hot_theme:ReqOnePageThemeModInfo(startThemeIndex, endThemeIndex, startModIndex, endModeIndex)
  if not self.hot_theme then
    log(bWriteLog and "logic_ugc_hot_theme:ReqOnePageThemeModInfo hot_theme is nil")
    return false
  end
  if not (startThemeIndex and endThemeIndex and startModIndex and endModeIndex) or endThemeIndex < startThemeIndex or endModeIndex < startModIndex then
    log(bWriteLog and "logic_ugc_hot_theme:ReqOnePageThemeModInfo params is invalid")
    return false
  end
  log(bWriteLog and "logic_ugc_hot_theme:ReqOnePageThemeModInfo startThemeIndex:" .. tostring(startThemeIndex) .. " endThemeIndex:" .. tostring(endThemeIndex) .. " startModIndex:" .. tostring(startModIndex) .. " endModeIndex:" .. tostring(endModeIndex))
  local ModToReq = {}
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  for i = startThemeIndex, endThemeIndex do
    if self.hot_theme[i] and self.hot_theme[i].mod_list then
      local modList = self.hot_theme[i].mod_list
      for index = startModIndex, endModeIndex do
        local modId = tonumber(modList[index])
        table.insert(ModToReq, modId)
      end
    end
  end
  local ModInfoList, ReqList = LogicUGC:BatchGetModInfo(ModToReq, LogicUGC.C_ModListTypes.HotTheme, nil, {
    TypeParam = self:GetModBatchReqParam(),
    bNotPostEvent = true
  })
  local bNeedReq = ReqList and 0 < #ReqList
  if ModInfoList and next(ModInfoList) and not bNeedReq then
    log(bWriteLog and "logic_ugc_hot_theme:ReqOnePageThemeModInfo OnModInfoBatchRsp")
    self:OnModInfoBatchRsp(ModInfoList, LogicUGC.C_ModListTypes.HotTheme, self:GetModBatchReqParam())
  end
  return bNeedReq
end
local C_GUESS_YOU_LIKE_THEME_ID = 301
function logic_ugc_hot_theme:GetOneThemeShowModData(themeIndex)
  if not (themeIndex and self.hot_theme) or not self.hot_theme[themeIndex] then
    log(bWriteLog and "logic_ugc_hot_theme:ReqOnePageThemeModInfo hot_theme is nil")
    return
  end
  local themeData = self.hot_theme[themeIndex]
  print(bWriteLog and "logic_ugc_hot_theme:GetOneThemeShowModData themeData.data_type:" .. tostring(themeData.data_type))
  local modIdList = themeData.mod_list or {}
  local showList = {}
  local bShowAuthor = themeData.base and themeData.base.show_author == 1
  local uidsToReqProfile = {}
  self.hasReqProfileUidList = self.hasReqProfileUidList or {}
  local bShowFeedbackPanel = themeData.base and themeData.base.id == C_GUESS_YOU_LIKE_THEME_ID
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, modId in ipairs(modIdList) do
    local modInfo = LogicUGC:GetModByAllCache(tonumber(modId))
    if modInfo and modInfo.pub_mod_meta then
      table.insert(showList, {
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
  return showList
end
function logic_ugc_hot_theme:GetNewOneThemeShowModData(HotThemeData, bRefresh)
  if not HotThemeData or not next(HotThemeData) then
    log(bWriteLog and "logic_ugc_hot_theme:GetNewOneThemeShowModData HotThemeData is nil")
    return
  end
  log_tree("logic_ugc_hot_theme:GetNewOneThemeShowModData HotThemeData", HotThemeData)
  local config_ugc_hot_theme = require("client.slua.logic.ugc.hot_theme.config_ugc_hot_theme")
  local ThemeRefreshModNum = config_ugc_hot_theme.ThemeRefreshModNum
  local themeId = HotThemeData.base.id
  local themeData = {}
  for i, data in ipairs(self.hot_theme) do
    if data.base.id == themeId then
      themeData = data
      break
    end
  end
  log(bWriteLog and "logic_ugc_hot_theme:GetNewOneThemeShowModData themeId:" .. tostring(themeId))
  log_tree("logic_ugc_hot_theme:GetNewOneThemeShowModData themeData ", themeData)
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
    if modInfo and modInfo.pub_mod_meta then
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
      log(bWriteLog and "logic_ugc_hot_theme:GetNewOneThemeShowModData bCompleted = " .. tostring(bCompleted))
      log(bWriteLog and "logic_ugc_hot_theme:GetNewOneThemeShowModData self.DisplayedThemeModIDList[" .. modIdList[i] .. "] = " .. tostring(self.DisplayedThemeModIDList[modIdList[i]]))
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
function logic_ugc_hot_theme:GetNewHotThemeModList(HotThemeData)
  if not HotThemeData or not next(HotThemeData) then
    log(bWriteLog and "logic_ugc_hot_theme:GetNewHotThemeModList HotThemeData is nil")
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
    log(bWriteLog and "logic_ugc_hot_theme:GetNewHotThemeModList self.tableHotTheme is nil")
    return
  end
  log_tree("logic_ugc_hot_theme:GetNewHotThemeModList self.tableHotTheme", self.tableHotTheme)
  log(bWriteLog and "logic_ugc_hot_theme:GetNewHotThemeModList themeId:" .. tostring(themeId))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ShowHotTheme = {}
  log_tree("logic_ugc_hot_theme:GetNewHotThemeModList themeData ", themeData)
  local bShowAuthor = themeData.base and themeData.base.show_author == 1
  local uidsToReqProfile = {}
  self.hasReqProfileUidList = self.hasReqProfileUidList or {}
  local bShowFeedbackPanel = themeData.base and themeData.base.id == C_GUESS_YOU_LIKE_THEME_ID
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, ModId in ipairs(self.tableHotTheme[themeId]) do
    local modInfo = LogicUGC:GetModByAllCache(tonumber(ModId))
    if modInfo and modInfo.pub_mod_meta then
      table.insert(ShowHotTheme, {
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
function logic_ugc_hot_theme:ReqOneThemeNextPageModInfo(themeIndex)
  if not (themeIndex and self.hot_theme) or not self.hot_theme[themeIndex] then
    log(bWriteLog and "logic_ugc_hot_theme:ReqOneThemeNextPageModInfo hot_theme is nil")
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
function logic_ugc_hot_theme:GetModBatchReqParam(themeIndex)
  if not themeIndex then
    return "themelist"
  end
  return "theme-" .. themeIndex
end
function logic_ugc_hot_theme:SetThemeScrollOffsetCache(themeIndex, offset)
  if not themeIndex or not offset then
    log(bWriteLog and "logic_ugc_hot_theme:SetThemeScrollOffsetCache params is invalid")
    return
  end
  self.themeScrollOffsetCache = self.themeScrollOffsetCache or {}
  log(bWriteLog and "logic_ugc_hot_theme:SetThemeScrollOffsetCache themeIndex:" .. tostring(themeIndex) .. " offset:" .. tostring(offset))
  self.themeScrollOffsetCache[themeIndex] = offset
end
function logic_ugc_hot_theme:GetThemeScrollOffsetCache(themeIndex)
  if not themeIndex then
    log(bWriteLog and "logic_ugc_hot_theme:GetThemeScrollOffsetCache themeIndex is invalid")
    return 0
  end
  return self.themeScrollOffsetCache and self.themeScrollOffsetCache[themeIndex] or 0
end
function logic_ugc_hot_theme:ReqAuthorProfile(uidList)
  if not uidList or not next(uidList) then
    log(bWriteLog and "logic_ugc_hot_theme:GetThemeScrollOffsetCache uidList is invalid")
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
function logic_ugc_hot_theme:RandomSelectKOL(hot_theme, bUserRoll)
  print(bWriteLog and "logic_ugc_hot_theme:RandomSelectKOL")
  local Ret = {}
  local KOLThemes = {}
  for _, themeInfo in pairs(hot_theme) do
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
    for Idx, Theme in pairs(KOLThemes) do
      if Theme.base and Theme.base.id == ThemeId then
        print(bWriteLog and "logic_ugc_hot_theme:RandomSelectKOL Cache hit " .. tostring(Idx))
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
function logic_ugc_hot_theme:SaveLastSelectKOLThemeId(ThemeId)
  print(bWriteLog and "logic_ugc_hot_theme:SaveLastSelectKOLThemeId " .. tostring(ThemeId))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({KOLThemeId = ThemeId}, PlayerPrefsSystem.ePlayerPrefsType.eUGCThemeKOL)
end
function logic_ugc_hot_theme:GetLastSelectKOLThemeId()
  print(bWriteLog and "logic_ugc_hot_theme:GetLastSelectKOLThemeId")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCThemeKOL) or {}
  print(bWriteLog and "logic_ugc_hot_theme:GetLastSelectKOLThemeId " .. tostring(saveData.KOLThemeId))
  return saveData.KOLThemeId
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end
local C_MAX_BAN_MODIDS = 2000
function logic_ugc_hot_theme:SetBanGuessYouLikeModId(modid)
  print(bWriteLog and "logic_ugc_hot_theme:SetBanGuessYouLikeModId " .. tostring(modid))
  local modids = self:GetBanGuessYouLikeModIds()
  if tablelength(modids) < C_MAX_BAN_MODIDS then
    modids[tostring(modid)] = true
  else
    print(bWriteLog and "logic_ugc_hot_theme:SetBanGuessYouLikeModId Upperlimit" .. tostring(modid))
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({BanModIds = modids}, PlayerPrefsSystem.ePlayerPrefsType.eUGCGuessULike)
end
function logic_ugc_hot_theme:GetBanGuessYouLikeModIds()
  print(bWriteLog and "logic_ugc_hot_theme:GetBanGuessYouLikeModIds")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCGuessULike) or {}
  log_tree("logic_ugc_hot_theme:GetBanGuessYouLikeModIds", saveData.BanModIds)
  return saveData.BanModIds or {}
end
function logic_ugc_hot_theme:FilterGuessULikeByBanIds(hot_theme)
  print(bWriteLog and "logic_ugc_hot_theme:FilterGuessULikeByBanIds")
  local Ret = {}
  local GuessULikeInfo = {}
  for _, themeInfo in pairs(hot_theme) do
    local DataType = themeInfo.data_type
    if themeInfo.base.id == 301 then
      GuessULikeInfo = themeInfo
    else
      table.insert(Ret, themeInfo)
    end
  end
  if GuessULikeInfo.base ~= nil then
    local tmp_modlist = {}
    local ban_mod_ids = self:GetBanGuessYouLikeModIds()
    for _, mod_id in ipairs(GuessULikeInfo.mod_list) do
      if ban_mod_ids[tostring(mod_id)] == nil then
        table.insert(tmp_modlist, mod_id)
      end
    end
    GuessULikeInfo.mod_list = tmp_modlist
    table.insert(Ret, GuessULikeInfo)
  end
  return Ret
end
function logic_ugc_hot_theme:ProcessHotThemeData(hot_theme, bUserRoll)
  if not hot_theme then
    log(bWriteLog and "logic_ugc_hot_theme:ProcessHotThemeData hot_theme is nil")
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
  if logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() then
    for _, v in ipairs(hot_theme) do
      if v.data_type and v.data_type == "NEWBIE" then
        v.base.pos = -9999
      end
    end
  else
    for _, v in ipairs(hot_theme) do
      if v.data_type and v.data_type == "NEWBIE" then
        table.remove(hot_theme, _)
        break
      end
    end
  end
  for _, v in pairs(hot_theme) do
    if v.data_type and v.data_type == "FRIEND_BASE_REC_V2" and self:CheckFriendMod(v.mod_list) then
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
function logic_ugc_hot_theme:CheckFriendMod(mod_list)
  if not mod_list then
    log(bWriteLog and "logic_ugc_hot_theme:CheckFriendMod mod_list is nil")
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
function logic_ugc_hot_theme:CheckThemeDataValid()
  if not self.hot_theme or #self.hot_theme <= 0 then
    log(bWriteLog and "logic_ugc_hot_theme:CheckThemeDataValid hot_theme is nil")
    return false
  end
  if not self.themeDataTimeStamp then
    log(bWriteLog and "logic_ugc_hot_theme:CheckThemeDataValid themeDataTimeStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.themeDataTimeStamp + self.HotThemeListReqCD
end
function logic_ugc_hot_theme:RollKOLTheme()
  log(bWriteLog and "logic_ugc_hot_theme:RollKOLTheme")
  self.hot_theme = self:ProcessHotThemeData(self.cached_raw_hot_theme, true)
  log_tree(bWriteLog and "logic_ugc_hot_theme:on_ugc_gallery_hot_theme_rsp hot_theme new", self.hot_theme)
  return self.hot_theme
end
function logic_ugc_hot_theme:RefreshThemeData()
  log(bWriteLog and "logic_ugc_hot_theme:RefreshThemeData")
  self.hot_theme = self:ProcessHotThemeData(self.cached_raw_hot_theme, false)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_RSP, true)
end
function logic_ugc_hot_theme:send_ugc_gallery_hot_theme_req()
  if self:CheckThemeDataValid() then
    log(bWriteLog and "logic_ugc_hot_theme:send_ugc_gallery_hot_theme_req dataValid no need to req")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_RSP)
    self:GetThemeModPlayer()
    return
  end
  log(bWriteLog and "logic_ugc_hot_theme:send_ugc_gallery_hot_theme_req")
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_gallery_hot_theme_req()
end
function logic_ugc_hot_theme:on_ugc_gallery_hot_theme_rsp(hot_theme)
  if not hot_theme then
    log(bWriteLog and "logic_ugc_hot_theme:on_ugc_gallery_hot_theme_rsp hot_theme is nil")
    return
  end
  self.tableHotTheme = {}
  local TimeUtil = require("client.common.time_util")
  self.themeDataTimeStamp = TimeUtil.GetServerTimeInSec()
  self.HotThemeReqState = {}
  log_tree(bWriteLog and "logic_ugc_hot_theme:on_ugc_gallery_hot_theme_rsp hot_theme", hot_theme)
  self.cached_raw_  self.hot_theme = self:ProcessHotThemeData(hot_theme)
  log_tree(bWriteLog and "logic_ugc_hot_theme:on_ugc_gallery_hot_theme_rsp hot_theme new", self.hot_theme)
  for i, v in ipairs(hot_theme) do
    if v.data_type == "TRAFFIC_POOL_GROWTH" or v.data_type == "SPEC_THEME" then
      local Version = v.version or v.base and v.base.version or 0
      self.version = Version
    end
    if v.data_type == "PROMOTION" then
      self.trans_info = v.trans_info
    end
  end
  log_tree("logic_ugc_hot_theme:on_ugc_gallery_hot_theme_rsp self.trans_info = ", self.trans_info)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_RSP)
  if self.AutoNextReqBundleID and 0 < self.AutoNextReqBundleID then
    local _, ReqIndex = self:GetHotTheme(self.AutoNextReqBundleID)
    self:ReqOneThemeNextPageModInfo(ReqIndex)
    self.AutoNextReqBundleID = nil
  end
  self:GetThemeModPlayer()
end
function logic_ugc_hot_theme:GetThemeModPlayer()
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
function logic_ugc_hot_theme:OnModInfoBatchRsp(MetaList, ListType, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.HotTheme) then
    return
  end
  local bIsDirty = false
  if next(MetaList) then
    bIsDirty = true
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_MODINFO_RSP, ListType, bIsDirty, MetaList, Param, FilterOfflineModList)
end
function logic_ugc_hot_theme:SetHotThemeEntryStamp()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.HotThemeEntryStamp = curTime
  log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeEntryStamp self.HotThemeEntryStamp = " .. tostring(self.HotThemeEntryStamp))
end
function logic_ugc_hot_theme:SetHotThemeDepartureStamp()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.HotThemeDepartureStamp = self.HotThemeEntryStamp
  log(bWriteLog and "logic_ugc_hot_theme:SetHotThemeDepartureStamp self.HotThemeDepartureStamp = " .. tostring(self.HotThemeDepartureStamp))
end
function logic_ugc_hot_theme:CheckTimeInterval(style)
  if not self.HotThemeEntryStamp or not self.HotThemeDepartureStamp then
    log(bWriteLog and "logic_ugc_hot_theme:CheckTimeInterval HotThemeEntryStamp or HotThemeDepartureStamp is nil")
    return false
  end
  log(bWriteLog and "logic_ugc_hot_theme:CheckTimeInterval self.HotThemeEntryStamp = " .. tostring(self.HotThemeEntryStamp))
  log(bWriteLog and "logic_ugc_hot_theme:CheckTimeInterval elf.HotThemeDepartureStamp = " .. tostring(self.HotThemeDepartureStamp))
  log(bWriteLog and "logic_ugc_hot_theme:CheckTimeInterval return value = " .. tostring(self.HotThemeEntryStamp <= self.HotThemeDepartureStamp + self.HotThemeCarouselCD))
  if style == 2 then
    return self.HotThemeEntryStamp <= self.HotThemeDepartureStamp + self.HotThemeCarouselCD
  else
    return self.HotThemeEntryStamp <= self.HotThemeDepartureStamp + self.HotAuthorCarouselCD
  end
end
function logic_ugc_hot_theme:Report()
  if not next(self.report) then
    log(bWriteLog and "logic_ugc_hot_theme:Report self.report is nil")
    return
  end
  if self.version == 0 then
    log(bWriteLog and "logic_ugc_hot_theme:Report self.version is 0")
    return
  end
  log_tree("logic_ugc_hot_theme:Report self.report", self.report)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_report_rec_mod_view_req(self.version, self.report)
  self:ClearReport()
end
function logic_ugc_hot_theme:ClearReport()
  self.report = {}
end
function logic_ugc_hot_theme:AddReportDetail(mod)
  self:AddReport(mod, "detail")
end
function logic_ugc_hot_theme:AddReportSelect(mod)
  self:AddReport(mod, "select")
end
function logic_ugc_hot_theme:AddReportCollect(mod)
  self:AddReport(mod, "collect")
end
function logic_ugc_hot_theme:AddReportExpose(mod)
  self:AddReport(mod, "expose")
end
function logic_ugc_hot_theme:AddReport(mod, key)
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
function logic_ugc_hot_theme:FormatReportItem()
  return {
    detail = 0,
    select = 0,
    match = 0,
    collect = 0,
    expose = 0
  }
end
function logic_ugc_hot_theme:SetHotThemeReqState(HotThemeData)
  local themeID = HotThemeData.base.id
  self.HotThemeReqState[themeID] = true
end
function logic_ugc_hot_theme:GetHotThemeReqState(HotThemeData)
  local themeID = HotThemeData.base.id
  return self.HotThemeReqState[themeID]
end
function logic_ugc_hot_theme:ClearKOLHotThemeCache(themeID)
  if themeID then
    self.tableHotTheme[themeID] = nil
  end
end
function logic_ugc_hot_theme:ClearDisplayedThemeModIDListCache()
  log(bWriteLog and "logic_ugc_hot_theme:ClearDisplayedThemeModIDListCache")
  self.DisplayedThemeModIDList = {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_hot_theme = class(CModuleBase, nil, logic_ugc_hot_theme)
return Clogic_ugc_hot_theme