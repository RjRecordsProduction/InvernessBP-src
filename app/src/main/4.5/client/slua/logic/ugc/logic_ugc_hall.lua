local logic_ugc_hall = {}
local CONST_HALL_BANNER_MAX_COUNT = 4
function logic_ugc_hall:CheckIsOpen()
  local switch = LobbySystem.CheckOpen(BP_ENUM_WOW_RIGHT_MODE)
  log(bWriteLog and "logic_ugc_hall:CheckIsOpen switch = " .. tostring(switch))
  local isOpen = LobbySystem.roleData.wow_hall_is_open
  log(bWriteLog and "logic_ugc_hall:CheckIsOpen isOpen = " .. tostring(isOpen))
  return switch and isOpen
end
function logic_ugc_hall:DefineAndResetData()
  logic_ugc_hall.__super.DefineAndResetData(self)
  self.ReqList = {1, 2}
  self.AllReqTypeList = {}
  self.jumpModeInfo = nil
  self.RoughDataRspCount = 2
  self.TabInfo.req_banner_mod_list = {}
  self.TabInfo.req_theme_mod_list = {}
  self.reqBannerModListDone = false
  self.reqThemeModListDone = false
  self.bannerSelectedIndex = 1
end
function logic_ugc_hall:GetTabInformation(bForce)
  logic_ugc_hall.__super.GetTabInformation(self, bForce)
end
function logic_ugc_hall:CheckTabInfomation()
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  local inRefreshCD = logic_ugc_hot_page.themeDataTimeStamp and logic_ugc_hot_page:CheckThemeRefresh()
  if not inRefreshCD then
    return false
  end
  if not self.TabInfo.recommend_banner and not self.TabInfo.recommend_theme then
    return false
  end
  self:GetModInfo()
  return true
end
function logic_ugc_hall:GetModInfoReq(ModIDList, ModListType)
  if not ModIDList or not ModListType then
    log(bWriteLog and "logic_ugc_wowpage:GetModInfoReq ModIDList or ModListType is nil")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CacheModInfoList, ReqList, NotReqList, BanList = LogicUGC:BatchGetModInfo(ModIDList, ModListType, nil, {
    bGetPlayReq = true,
    bNotPostEvent = true,
    TypeParam = "logic_ugc_hall"
  })
  return CacheModInfoList, ReqList
end
function logic_ugc_hall:GetHallBannerModList()
  local StringUtil = require("common.string_util")
  local bannerCount = 0
  local bannerInfoMap = {}
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if self.TabInfo.recommend_banner and next(self.TabInfo.recommend_banner) then
    for _, banner in ipairs(self.TabInfo.recommend_banner) do
      if banner.mod_list and banner.rank_value then
        local rankIdx = tonumber(banner.rank_value)
        local mod_ids = StringUtil.Split(banner.mod_list, "|")
        for _, mod_id in ipairs(mod_ids) do
          local modId = tonumber(mod_id)
          local banned = LogicUGC:GetModIsBan(modId)
          if not banned and rankIdx and 1 <= rankIdx then
            local info = {}
            info.id = modId
            info.rank_value = rankIdx
            if banner.hall_tag then
              info.hall_tag = banner.hall_tag
            end
            bannerInfoMap[modId] = info
            bannerCount = bannerCount + 1
          end
        end
      end
    end
  end
  local hasBannerConfig = self.TabInfo.recommend_banner and next(self.TabInfo.recommend_banner)
  local bannerReady = not hasBannerConfig or self.reqBannerModListDone
  if bannerReady and self.TabInfo.recommend_theme and bannerCount < CONST_HALL_BANNER_MAX_COUNT then
    for _, theme in ipairs(self.TabInfo.recommend_theme) do
      if theme.mod_list then
        for _, mod in ipairs(theme.mod_list) do
          if bannerCount >= CONST_HALL_BANNER_MAX_COUNT then
            break
          end
          local modId = tonumber(mod)
          local banned = LogicUGC:GetModIsBan(modId)
          if modId and not banned then
            local info = {}
            info.id = modId
            bannerInfoMap[modId] = info
            bannerCount = bannerCount + 1
          end
        end
      end
    end
  end
  if bannerCount == 0 then
    return {}
  end
  local bannerModIdList = {}
  for id, _ in pairs(bannerInfoMap) do
    table.insert(bannerModIdList, id)
  end
  table.sort(bannerModIdList, function(a, b)
    local aRank = bannerInfoMap[a].rank_value
    local bRank = bannerInfoMap[b].rank_value
    if aRank == nil and bRank == nil then
      return
    elseif aRank == nil then
      return false
    elseif bRank == nil then
      return true
    end
    return aRank < bRank
  end)
  local bannerDataList = {}
  local CacheModList, _, _, BanList = LogicUGC:BatchGetModInfo(bannerModIdList, nil, nil, {bExportArray = true})
  if CacheModList and next(CacheModList) then
    for _, modInfo in ipairs(CacheModList) do
      local bannerData = {}
      bannerData.hall_tag = bannerInfoMap[modInfo.pub_mod_meta.mod_id].hall_tag or nil
      bannerData.pub_mod_meta = modInfo.pub_mod_meta
      table.insert(bannerDataList, bannerData)
    end
  else
    local banCount = 0
    if BanList and next(BanList) then
      for i, banId in ipairs(BanList) do
        if bannerInfoMap[tonumber(banId)] then
          banCount = banCount + 1
        end
      end
    end
    if banCount == bannerCount then
      return {}
    end
    local table_util = require("common.table_util")
    bannerModIdList = table_util.ArrayDifference(bannerModIdList, BanList)
    for i = 1, CONST_HALL_BANNER_MAX_COUNT do
      local bannerData = {}
      bannerData.mod_id = bannerModIdList[i] or -1
      table.insert(bannerDataList, bannerData)
    end
    return bannerDataList
  end
  local table_util = require("common.table_util")
  bannerDataList = table_util.slice(bannerDataList, 1, CONST_HALL_BANNER_MAX_COUNT, 1)
  if next(bannerDataList) then
    self.TabInfo.show_banner_list = bannerDataList
  end
  log_tree(bWriteLog and "logic_ugc_hall:GetRecommendList - recommendList:", bannerDataList)
  return bannerDataList
end
function logic_ugc_hall:GetTrendingModList()
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  local trendingModIdList = logic_ugc_hot_page:GetTrendingTabInfo()
  if not next(trendingModIdList) then
    log(bWriteLog and "logic_ugc_hall:GetTrendingTabInfo - trendingModIdList is empty")
    return
  end
  local table_util = require("common.table_util")
  if self.TabInfo.show_banner_list and next(self.TabInfo.show_banner_list) then
    local bannerModIdList = {}
    for _, v in ipairs(self.TabInfo.show_banner_list) do
      table.insert(bannerModIdList, v.pub_mod_meta.mod_id)
    end
    trendingModIdList = table_util.ArrayDifference(trendingModIdList, bannerModIdList)
  end
  local trendingModCount = #trendingModIdList
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local trendingDataList = {}
  local CacheModList, _, _, BanList = LogicUGC:BatchGetModInfo(trendingModIdList, nil, nil, {bExportArray = true})
  if CacheModList and next(CacheModList) then
    for _, modInfo in ipairs(CacheModList) do
      local trendingData = {}
      trendingData.pub_mod_meta = modInfo.pub_mod_meta
      table.insert(trendingDataList, trendingData)
    end
  else
    local banCount = 0
    if BanList and next(BanList) then
      banCount = #table_util.ArrayDifference(BanList, trendingModIdList)
    end
    if banCount == trendingModCount then
      return {}
    end
    trendingModIdList = table_util.ArrayDifference(trendingModIdList, BanList)
    for i = 1, CONST_HALL_BANNER_MAX_COUNT do
      local trendingData = {}
      trendingData.mod_id = trendingModIdList[i] or -1
      table.insert(trendingDataList, trendingData)
    end
    return trendingDataList
  end
  trendingDataList = table_util.slice(trendingDataList, 1, CONST_HALL_BANNER_MAX_COUNT)
  if next(trendingDataList) then
    self.TabInfo.show_trending_list = trendingDataList
  end
  log_tree(bWriteLog and "logic_ugc_hall:GetTrendingTabInfo - trendingList:", trendingDataList)
  return trendingDataList
end
function logic_ugc_hall:GetRecommendModByTeamNum(curMatchModId, curTeamNum)
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  local trendingModIdList = logic_ugc_hot_page:GetTrendingTabInfo()
  if not next(trendingModIdList) then
    log(bWriteLog and "logic_ugc_hall:GetRecommendModByTeamNum - trendingModIdList is empty")
    return
  end
  local table_util = require("common.table_util")
  table_util.Remove(trendingModIdList, curMatchModId)
  if self.TabInfo.show_trending_list and next(self.TabInfo.show_trending_list) then
    local showTrendingModIdList = {}
    for _, mod_data in pairs(self.TabInfo.show_trending_list) do
      table.insert(showTrendingModIdList, mod_data.pub_mod_meta.mod_id or mod_data.mod_id)
    end
    trendingModIdList = table_util.ArrayDifference(trendingModIdList, showTrendingModIdList)
  end
  local getRecommendPlayerNum = function(modInfo)
    if not modInfo or not modInfo.setting then
      log(bWriteLog and "logic_ugc_hall.getRecommendPlayerNum no modInfo or setting")
      return 0
    end
    local recommendNum = 0
    if modInfo.setting.team_size == -1 then
      recommendNum = modInfo.setting.max_num
    else
      local min_team_size = modInfo.setting.team_min_size or modInfo.setting.team_size
      if min_team_size == nil then
        return 0
      end
      if modInfo.setting.min_start_team_num == nil then
        return min_team_size
      end
      recommendNum = min_team_size * modInfo.setting.min_start_team_num
    end
    log(bWriteLog and "logic_ugc_hall.getRecommendPlayerNum min_size = " .. recommendNum)
    return recommendNum
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CacheModList = LogicUGC:BatchGetModInfo(trendingModIdList, nil, nil, {bExportArray = true})
  if CacheModList and next(CacheModList) then
    local trendingModDataList = {}
    for _, mod in ipairs(CacheModList) do
      local recommendNum = getRecommendPlayerNum(mod.pub_mod_meta)
      if curTeamNum <= recommendNum then
        table.insert(trendingModDataList, mod)
      end
    end
    trendingModDataList = table_util.slice(trendingModDataList, 1, 8)
    return trendingModDataList
  end
  log(bWriteLog and "logic_ugc_hall:GetRecommendModByTeamNum - CacheModList is empty")
  return {}
end
function logic_ugc_hall:on_ugc_mixed_banner_rsp(error, mixed_banner_list)
  log(bWriteLog and "logic_ugc_hall:on_ugc_mixed_banner_rsp error=", tostring(error))
  if error ~= 0 or mixed_banner_list == nil then
    return
  end
  local banner_list = {}
  if type(mixed_banner_list) == "table" then
    for _, value in ipairs(mixed_banner_list) do
      if value.set_type == "hall" then
        table.insert(banner_list, value)
      end
    end
  end
  self.TabInfo.recommend_banner = banner_list
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modid_set = {}
  local modid_list = {}
  local StringUtil = require("common.string_util")
  for _, hall_data in ipairs(banner_list) do
    if hall_data.mod_list then
      local mod_ids = StringUtil.Split(hall_data.mod_list, "|")
      for _, mod_id_str in ipairs(mod_ids) do
        local mod_id = tonumber(mod_id_str)
        if mod_id and not modid_set[mod_id] then
          modid_set[mod_id] = true
          table.insert(modid_list, mod_id)
        end
      end
    end
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local matchModInfo = LogicUGCMatch:GetUgcMatchModInfo()
  if matchModInfo then
    for _, mod_id in ipairs(modid_list) do
      if mod_id == matchModInfo.mod_id then
        LogicUGC:SetModCache(LogicUGC.C_ModListTypes.MixedBanner, mod_id, {pub_mod_meta = matchModInfo})
        break
      end
    end
  end
  local _, ReqList = self:GetModInfoReq(modid_list, LogicUGC.C_ModListTypes.MixedBanner)
  if ReqList and 0 < #ReqList then
    self.reqBannerModListDone = false
    self.TabInfo.req_banner_mod_list = ReqList
  end
end
function logic_ugc_hall:on_ugc_gallery_hot_theme_rsp(error, hot_theme)
  log(bWriteLog and "logic_ugc_hall:on_ugc_gallery_hot_theme_rsp error=", tostring(error))
  if error ~= 0 or hot_theme == nil then
    log(bWriteLog and "UGC HotTheme request failed or empty data")
    return
  end
  local theme_list = {}
  if type(hot_theme) == "table" then
    for _, value in ipairs(hot_theme) do
      if value.data_type == "MODE_SELECT_DISCOVER" then
        table.insert(theme_list, value)
      end
    end
  end
  self.TabInfo.recommend_theme = theme_list
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modid_set = {}
  local modid_list = {}
  for _, hall_data in ipairs(self.TabInfo.recommend_theme) do
    if hall_data.mod_list then
      for _, mod_id in ipairs(hall_data.mod_list) do
        if not modid_set[mod_id] then
          modid_set[mod_id] = true
          table.insert(modid_list, mod_id)
        end
      end
    end
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local matchModInfo = LogicUGCMatch:GetUgcMatchModInfo()
  if matchModInfo then
    for _, mod_id in ipairs(modid_list) do
      if mod_id == matchModInfo.mod_id then
        LogicUGC:SetModCache(LogicUGC.C_ModListTypes.HotTheme, mod_id, {pub_mod_meta = matchModInfo})
        break
      end
    end
  end
  local _, ReqList = self:GetModInfoReq(modid_list, LogicUGC.C_ModListTypes.HotTheme)
  if ReqList and 0 < #ReqList then
    self.reqThemeModListDone = false
    self.TabInfo.req_theme_mod_list = ReqList
  end
end
function logic_ugc_hall:OnModInfoBatchRsp(_, _, ReqListType, bIsDirty, MetaList, ClientParam, filter_offline_mod_list)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if ReqListType ~= LogicUGC.C_ModListTypes.MixedBanner and ReqListType ~= LogicUGC.C_ModListTypes.HotTheme then
    return
  end
  local table_util = require("common.table_util")
  if not MetaList or table_util.CountTable(MetaList) <= 0 then
    return
  end
  if ReqListType == LogicUGC.C_ModListTypes.MixedBanner then
    local reqBannerModList = {}
    for _, mod_id in ipairs(self.TabInfo.req_banner_mod_list or {}) do
      if not MetaList[mod_id] then
        table.insert(reqBannerModList, mod_id)
      end
    end
    self.TabInfo.req_banner_mod_list = reqBannerModList
    if 0 >= #self.TabInfo.req_banner_mod_list and not self.reqBannerModListDone then
      self.reqBannerModListDone = true
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HALL_REFRESH_TABINFO)
    end
  elseif ReqListType == LogicUGC.C_ModListTypes.HotTheme then
    local reqThemeModList = {}
    for _, mod_id in ipairs(self.TabInfo.req_theme_mod_list or {}) do
      if not MetaList[mod_id] then
        table.insert(reqThemeModList, mod_id)
      end
    end
    self.TabInfo.req_theme_mod_list = reqThemeModList
    if 0 >= #self.TabInfo.req_theme_mod_list and not self.reqThemeModListDone then
      self.reqThemeModListDone = true
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HALL_REFRESH_TABINFO)
    end
  end
end
function logic_ugc_hall:SetTeamInviteInfo(info)
  self.teamInviteInfo = info or {}
end
function logic_ugc_hall:ClearTeamInviteInfo()
  self.teamInviteInfo = {}
end
function logic_ugc_hall:RegistEvents()
  logic_ugc_hall.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_NEW_MAIN_PANEL, self.OnUrlModeJump, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_MAIN_JUMP, self.OnMainJump, self)
end
function logic_ugc_hall:OnLogOut()
  log(bWriteLog and "logic_ugc_hall:OnLogOut")
end
function logic_ugc_hall:OnUrlModeJump(event_type, event_id, params)
  if not self:CheckCanJump() then
    log_warning(bWriteLog and "logic_ugc_hall:OnUrlModeJump, CheckCanJump return false")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.UGCMainPanelFindWorksHall, params)
end
function logic_ugc_hall:OnMainJump(event_type, event_id, params)
  if not self:CheckCanJump() then
    log_warning(bWriteLog and "logic_ugc_hall:OnMainJump, CheckCanJump return false")
    return
  end
  local modeID = params.modId
  local creationTab = params.creationTab
  local isOpen = self:CheckIsOpen()
  if isOpen then
    local openParams = {creationTab = creationTab}
    local extendedParams = {ugcModId = modeID}
    UIManager.ShowUI(UIManager.UI_Config.UGCMainPanelFindWorksHall, openParams, extendedParams)
    return
  end
  local jump_utils = require("client.logic.store.jump_utils")
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_MATCH_MODE_SELECTION, {
    menuList = mode_selection_macro.Enum_TabID.UGC,
    creationTab = creationTab,
    modId = modeID
  })
end
function logic_ugc_hall:CheckCanJump()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    log_warning(bWriteLog and "logic_ugc_hall:CheckCanJump, is not team leader!!!")
    ShowNotice(500045)
    return false
  end
  if LobbySystem.isInMatch then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom and not UGCPlayHallRoom:GetRoomMatchInfo() then
      log_warning(bWriteLog and "logic_ugc_hall:CheckCanJump, is matching!!!")
      ShowNotice(110014)
      return false
    end
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if DataMgr.roleData.level < Config_UGC.UGCActivationLevel then
    ShowNotice(LocUtil.LocalizeResFormat(29726, "WOW", Config_UGC.UGCActivationLevel))
    return false
  end
  return true
end
function logic_ugc_hall:SetJumpModInfo(modInfo)
  self.jumpModeInfo = modInfo
end
function logic_ugc_hall:GetJumpModInfo()
  return self.jumpModeInfo
end
function logic_ugc_hall:ClearJumpModInfo()
  self.jumpModeInfo = nil
end
function logic_ugc_hall:RequestUGCHallReddotData()
  log(bWriteLog and "logic_ugc_hall:RequestUGCHallReddotData")
  if not self:CheckIsOpen() then
    return
  end
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  if logic_ugc_inventory and not logic_ugc_inventory.personal_depot then
    logic_ugc_inventory:InventoryReq()
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler:send_ugc_get_review_panel_info_req()
end
function logic_ugc_hall:ShouldShowReddot()
  if not self:CheckIsOpen() then
    return false
  end
  local currentReddots = self:GetReddotState() or {}
  local lastReddots = self:GetLastVisitReddotState() or {}
  for reddot, _ in pairs(currentReddots) do
    if not lastReddots[reddot] then
      return true
    end
  end
  return false
end
function logic_ugc_hall:GetReddotState()
  local reddots = {}
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  local bShowPassRedPoint = logic_ugc_WOWPass and logic_ugc_WOWPass:GetWOWPassRedDotState() or false
  if bShowPassRedPoint then
    log(bWriteLog and "logic_ugc_hall:GetReddotState. pass red point")
    reddots.pass = true
  end
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  local RedDotData = UGCCenterRedDotData.GetData()
  if RedDotData and RedDotData.newCount > 0 then
    log(bWriteLog and "logic_ugc_hall:GetReddotState. creative red point")
    reddots.creative = true
  end
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  local bShowInventoryRedPoint = logic_ugc_inventory and logic_ugc_inventory:HasNewItems() or false
  if bShowInventoryRedPoint then
    log(bWriteLog and "logic_ugc_hall:GetReddotState. inventory red point")
    reddots.inventory = true
  end
  local logic_ugc_appreciation_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_appreciation_group)
  if logic_ugc_appreciation_group then
    local bShowAppreciationTaskRedPoint = logic_ugc_appreciation_group:HasAppreciationAward()
    local bShowAppreciationHistoryRedPoint = logic_ugc_appreciation_group:HasHistoryAppreciationAward()
    if bShowAppreciationTaskRedPoint or bShowAppreciationHistoryRedPoint then
      log(bWriteLog and "logic_ugc_hall:GetReddotState. appreciation red point")
      reddots.appreciation = true
    end
  end
  return reddots
end
function logic_ugc_hall:SetLastVisitReddotState()
  log(bWriteLog and "logic_ugc_hall:SaveLastVisitReddotState")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local WowHallVisitInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWOWHallVisitInfo)
  WowHallVisitInfo = WowHallVisitInfo or {}
  local reddots = self:GetReddotState()
  WowHallVisitInfo.lastVisitReddotState = reddots
  PlayerPrefsSystem.SaveTableToFile_N(WowHallVisitInfo, PlayerPrefsSystem.ePlayerPrefsType.eUGCWOWHallVisitInfo)
end
function logic_ugc_hall:GetLastVisitReddotState()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local WowHallVisitInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWOWHallVisitInfo)
  if not WowHallVisitInfo then
    return {}
  end
  return WowHallVisitInfo.lastVisitReddotState
end
local class = require("class")
local logic_ugc_wowpage = require("client.slua.logic.ugc.logic_ugc_wowpage")
local Clogic_ugc_hall = class(logic_ugc_wowpage, nil, logic_ugc_hall)
return Clogic_ugc_hall