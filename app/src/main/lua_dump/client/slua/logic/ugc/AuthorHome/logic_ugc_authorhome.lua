local Logic_UGC_AuthorHome = {}
local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
local config_ugc_authorhome = require("client.slua.umg.ugc.AuthorHome.config_ugc_authorhome")
function Logic_UGC_AuthorHome:ctor()
  self.EditTagCntLimit = 3
  self.wow_author_homepage_map = {}
  self.my_wow_author_homepage = nil
  self.wow_author_homepage_support_info_map = {}
  self.wow_author_support_count_map = {}
  self.timer = nil
  self.cfgDataList = {}
  self.DefaultModWallLimit = 5
  self.DefaultHonorWallLimit = 3
  self.LocalHonorData = {}
  self.cur_uid = 0
end
function Logic_UGC_AuthorHome:OnInitialize()
end
function Logic_UGC_AuthorHome:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_MOD, self.OnDeleteMod, self)
end
function Logic_UGC_AuthorHome:OnLogin()
end
function Logic_UGC_AuthorHome:OnLogOut()
  self.wow_author_homepage_map = nil
  self.wow_author_homepage_support_info_map = nil
  self.wow_author_support_count_map = nil
  self.timer = nil
  self.cfgDataList = nil
  self.LocalHonorData = nil
end
function Logic_UGC_AuthorHome:ReqAuthorHomePageData(uid, bNeedRefresh)
  uid = tonumber(uid)
  if not uid then
    log(bWriteLog and "Logic_UGC_AuthorHome:ReqAuthorHomePageData uid is nil")
    return
  end
  local my_uid = tonumber(DataMgr.roleData.uid)
  local is_myself = uid == my_uid
  local has_valid_cache = is_myself and self.my_wow_author_homepage or not is_myself and (self.wow_author_homepage_map or {})[uid]
  if not bNeedRefresh and has_valid_cache then
    log(bWriteLog and "Logic_UGC_AuthorHome:ReqAuthorHomePageData uid = " .. uid .. " use cache\239\188\129")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_UPDAGE, uid)
    if uid == tonumber(DataMgr.roleData.uid) then
      self:UpdateHonorRedDot(self.my_wow_author_homepage.completed_achievement or {})
    end
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_wow_get_author_homepage_req(uid)
end
function Logic_UGC_AuthorHome:RspAuthorHomePageData(author_uid, wow_author_homepage)
  author_uid = tonumber(author_uid)
  if not author_uid then
    return
  end
  if author_uid == tonumber(DataMgr.roleData.uid) then
    self.cfgDataList = {}
    self:SetMyAuthorHomeData(wow_author_homepage)
    self:AddHonorRedDot()
    self:UpdateHonorRedDot(wow_author_homepage.completed_achievement or {})
  else
    self.wow_author_homepage_map[author_uid] = wow_author_homepage
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_UPDAGE, author_uid)
end
function Logic_UGC_AuthorHome:SetMyAuthorHomeData(wow_author_homepage)
  self.my_end
function Logic_UGC_AuthorHome:GetMyAuthorHomeData()
  return self.my_wow_author_homepage
end
function Logic_UGC_AuthorHome:ReqAuthorHomePageSupportInfo(author_uid, bNeedRefresh)
  if not author_uid then
    log(bWriteLog and "Logic_UGC_AuthorHome:ReqAuthorHomePageSupportInfo author_uid is nil")
    return
  end
  if not bNeedRefresh and self.wow_author_homepage_support_info_map and self.wow_author_homepage_support_info_map[author_uid] then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_SUPPORTINFO_UPDAGE, author_uid)
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_wow_get_author_homepage_support_info_req(author_uid)
end
function Logic_UGC_AuthorHome:RspAuthorHomePageSupportInfo(author_uid, wow_author_homepage_support_info)
  author_uid = tonumber(author_uid)
  if not author_uid then
    return
  end
  self.wow_author_homepage_support_info_map[author_uid] = wow_author_homepage_support_info
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_SUPPORTINFO_UPDAGE, author_uid)
  if self.timer then
    self:RemoveTimer(self.timer)
  end
  self.timer = self:AddTimerOnce(300, function()
    self:ClearCache()
  end)
end
function Logic_UGC_AuthorHome:ReqSupportAuthor(uid)
  if not uid then
    log(bWriteLog and "Logic_UGC_AuthorHome:ReqSupportAuthor uid is nil")
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_wow_support_author_homepage_req(uid)
end
function Logic_UGC_AuthorHome:ReqModifyData(author_homepage)
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_wow_modify_author_homepage_req(author_homepage)
end
function Logic_UGC_AuthorHome:RspModifyData(author_homepage)
  self:SetMyAuthorHomeData(author_homepage)
  self:UpdateHonorRedDot(author_homepage.completed_achievement or {})
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_UPDAGE, DataMgr.roleData.uid)
end
function Logic_UGC_AuthorHome:ReqAuthorSupportInfo(uid, bNeedRefresh)
  if not uid then
    log(bWriteLog and "Logic_UGC_AuthorHome:ReqAuthorSupportInfo uid is nil")
    return
  end
  if not bNeedRefresh and tonumber(uid) ~= tonumber(DataMgr.roleData.uid) and self.wow_author_support_count_map and self.wow_author_support_count_map[uid] then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_SUPPORTCOUNT_UPDAGE, uid)
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_wow_get_author_homepage_support_count_req(uid)
end
function Logic_UGC_AuthorHome:RspAuthorSupportInfo(author_uid, support_count)
  author_uid = tonumber(author_uid)
  if not author_uid then
    return
  end
  self.wow_author_support_count_map[author_uid] = support_count
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_SUPPORTCOUNT_UPDAGE, author_uid)
end
function Logic_UGC_AuthorHome:ReqSummaryData(uid)
  if not uid then
    log(bWriteLog and "Logic_UGC_AuthorHome:GetSummaryData uid is nil")
    return nil
  end
  local summaryData
  if tonumber(DataMgr.roleData.uid) == tonumber(uid) then
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    summaryData = LogicUGCAuthor:GetMyAuthorSummaryData()
  else
    local LogicUGCAuthorGuest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthorGuest)
    summaryData = LogicUGCAuthorGuest:GetAuthorSummaryData(self.uid)
  end
  if not summaryData then
    log(bWriteLog and "Logic_UGC_AuthorHome:GetSummaryData reqSummary")
    local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
    UGCAuthorHandler.send_ugc_author_summary_req(uid)
  else
    log(bWriteLog and "Logic_UGC_AuthorHome:GetSummaryData get chace summarydata")
  end
  return summaryData
end
function Logic_UGC_AuthorHome:IsMySelf(uid, author_uid)
  local Uid = author_uid or uid
  if tonumber(Uid) == tonumber(DataMgr.roleData.uid) then
    return true
  else
    return false
  end
end
function Logic_UGC_AuthorHome:ClearAuthorHomeData(uid)
  self.wow_author_homepage_support_info_map[uid] = nil
  self.wow_author_homepage_map[uid] = nil
  self.wow_author_support_count_map[uid] = nil
  log(bWriteLog and "Logic_UGC_AuthorHome:ClearAuthorHomeData uid = " .. uid)
end
function Logic_UGC_AuthorHome:ClearCache()
  log(bWriteLog and "Logic_UGC_AuthorHome:ClearCache")
  if self.timer then
    self:RemoveTimer(self.timer)
    self.timer = nil
  end
  self.wow_author_homepage_support_info_map = {}
  self.wow_author_homepage_map = {}
  self.wow_author_support_count_map = {}
  self.my_wow_author_homepage = nil
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_AuthorHomePage) then
    log(bWriteLog and "Logic_UGC_DataCenter:ClearCache UGC_AuthorHomePage is show")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_AUTHORHOME_REREQ)
  elseif UIManager.IsUIShow(UIManager.UI_Config.UGC_AuthorHonorPage) then
    log(bWriteLog and "Logic_UGC_DataCenter:ClearCache UGC_AuthorHonorPage is show")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_AUTHORHONOR_REREQ)
  end
end
function Logic_UGC_AuthorHome:OnNextDayZeroCome()
  self:ClearCache()
end
function Logic_UGC_AuthorHome:OnDeleteMod()
  log(bWriteLog and "Logic_UGC_AuthorHome:OnDeleteMod")
  self.my_wow_author_homepage = nil
end
function Logic_UGC_AuthorHome:CreatedMultiLvGroupIdAchiveMap()
  if not achievement_cfg_helper.tb_MultiLvGroupID2AchiveID_UGC_Map then
    log(bWriteLog and "Logic_UGC_AuthorHome : CreatedMultiLvGroupIdAchiveMap")
    achievement_cfg_helper.InitUGCMap()
  end
  return achievement_cfg_helper.tb_MultiLvGroupID2AchiveID_UGC_Map
end
function Logic_UGC_AuthorHome:CreateCondiParamAchiveMap()
  if not achievement_cfg_helper.tb_CondiParam2AchieveID_UGC_Map then
    log(bWriteLog and "Logic_UGC_AuthorHome:CreateCondiParamAchiveMap")
    achievement_cfg_helper.InitUGCMap()
  end
  return achievement_cfg_helper.tb_CondiParam2AchieveID_UGC_Map
end
function Logic_UGC_AuthorHome:CreateCondID2CfgID()
  if not achievement_cfg_helper.tb_CondID2AchieveID_UGC_Map then
    log(bWriteLog and "Logic_UGC_AuthorHome:CreateCondID2CfgID")
    achievement_cfg_helper.InitUGCMap()
  end
  return achievement_cfg_helper.tb_CondID2AchieveID_UGC_Map
end
function Logic_UGC_AuthorHome:CalculateTabDataList(tabIndex, bForceCalc)
  if bForceCalc == false and self.cfgDataList[tabIndex] ~= nil then
    return
  end
  log(bWriteLog and "Achievement_Summary_Loop_UIBP.CalculateTabDataList cfgDataList" .. tabIndex)
  local groupIdListMap = self:CreatedMultiLvGroupIdAchiveMap()
  local idListMap = groupIdListMap[tabIndex]
  if idListMap == nil then
    return nil
  end
  self.cfgDataList[tabIndex] = {}
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  for _, idList in pairs(idListMap) do
    local AchTb = {
      ShowAchID = 0,
      SortShowID = 0,
      FinishTime = 0,
      AchType = 0,
      Version = 0,
      ColorType = 0
    }
    AchTb[1] = idList
    local bCanGet = false
    AchTb.ShowAchID, AchTb.SortShowID = self:GetMultiLvGroupsShowIds(idList)
    local ShowAchIDCfg = CDataTable.GetTableData("AchievementCfg", AchTb.ShowAchID)
    local SortShowIDCfg = AchTb.ShowAchID == AchTb.SortShowID and ShowAchIDCfg or CDataTable.GetTableData("AchievementCfg", AchTb.SortShowID)
    _, AchTb.FinishTime = self:CheckAchiveCanFinishWithCfg(AchTb.SortShowID, SortShowIDCfg)
    local bExtinct = AchieveHandler.IsExtinctByID(idList[1])
    local AchCfg = CDataTable.GetTableData("AchievementCfg", idList[1])
    AchTb.AchType = AchCfg.AchType
    AchTb.ColorType = SortShowIDCfg.ColorType
    local AllNotFinish = false
    if 0 > AchTb.FinishTime then
      AllNotFinish = true
    end
    local bClientShow = self:GetIsClientShowWithCfg(AchTb.ShowAchID, ShowAchIDCfg)
    if bClientShow then
      if AchCfg.AchType == 1 then
        if AllNotFinish then
          if not bExtinct then
            table.insert(self.cfgDataList[tabIndex], AchTb)
          end
        else
          table.insert(self.cfgDataList[tabIndex], AchTb)
        end
      elseif AchCfg.AchType == 2 then
        if not AllNotFinish then
          table.insert(self.cfgDataList[tabIndex], AchTb)
        end
      else
        table.insert(self.cfgDataList[tabIndex], AchTb)
      end
    else
      log(bWriteLog and "Logic_UGC_AuthorHome:CalculateTabDataList bClientShow = false tabIndex = " .. tostring(tabIndex) .. " AchTb.ShowAchID = " .. tostring(AchTb.ShowAchID))
    end
  end
end
function Logic_UGC_AuthorHome:GetMultiLvGroupsShowIds(idList)
  local complete_achievement = self.my_wow_author_homepage and self.my_wow_author_homepage.completed_achievement or {}
  log_tree("Logic_UGC_AuthorHome:GetMultiLvGroupsShowIds complete_achievement", complete_achievement)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local ShowId = idList[1]
  local Sort  local FinishID = -1
  local IDsNotGet = {}
  for _, AchID in ipairs(idList) do
    local bGet = self:CheckHasHonor(AchID, complete_achievement)
    if bGet then
      if AchID > FinishID then
        FinishID = AchID
      end
    else
      table.insert(IDsNotGet, AchID)
    end
  end
  if 0 < FinishID then
    for _, AchID in ipairs(IDsNotGet) do
      if AchID > FinishID then
        ShowId = AchID
        SortShowId = FinishID
        return ShowId, SortShowId
      end
    end
    ShowId = FinishID
    SortShowId = FinishID
    return ShowId, SortShowId
  end
  return ShowId, SortShowId
end
function Logic_UGC_AuthorHome:CheckAchiveCanFinishWithCfg(id)
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  if not logic_achievement.GetIsClientShowByNetDataAward(id) then
    return false, -1
  end
  local complete_achievement = self.my_wow_author_homepage and self.my_wow_author_homepage.completed_achievement or {}
  local bGet, v = self:CheckHasHonor(id, complete_achievement)
  return bGet, v
end
function Logic_UGC_AuthorHome:GetIsClientShowWithCfg(AchId, AchCfg)
  AchCfg = AchCfg or CDataTable.GetTableData("AchievementCfg", AchId)
  if not AchCfg then
    log_error(bWriteLog and "Logic_UGC_AuthorHome:GetIsClientShowWithCfg AchCfg no have AchId:" .. AchId)
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local bToShow = true
  if AchCfg and AchCfg.ClientShowTime and AchCfg.ClientShowTime ~= "" then
    local showTime = TimeUtil.TimeStringToUnixstamp(AchCfg.ClientShowTime)
    if now < showTime then
      return false
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    bToShow = AchCfg.BLUEHOLEEnable ~= 0
  elseif PublishRegionMacros.IsJapanOrKorea() then
    bToShow = AchCfg.JPKREnable ~= 0
  else
    bToShow = AchCfg.GlobalEnable ~= 0
  end
  return bToShow
end
function Logic_UGC_AuthorHome:SortHonorList(completed_achievement, all, sort_type, select_achievement_map)
  local TableUtil = require("common.table_util")
  local obtained, not_obtained = {}, {}
  for i, v in pairs(all) do
    local bHas, GetTime = self:CheckHasHonor(v[1][1], completed_achievement)
    if bHas then
      local data = TableUtil.CopyTable(v)
      data.FinishTime = GetTime
      table.insert(obtained, data)
    else
      table.insert(not_obtained, v)
    end
  end
  local selected, not_selected, not_selected_map = {}, {}, {}
  for i, v in pairs(obtained) do
    not_selected_map[v[1][1]] = v
  end
  for i, honorID in pairs(select_achievement_map) do
    for _, v in pairs(obtained) do
      if v[1][1] == honorID then
        table.insert(selected, v)
        not_selected_map[v[1][1]] = nil
        break
      end
    end
  end
  for i, v in pairs(not_selected_map) do
    table.insert(not_selected, v)
  end
  if sort_type.ID == config_ugc_authorhome.C_HonorSortID.Time then
    table.sort(not_selected, function(a, b)
      return self:SortByFinishTime(a, b)
    end)
  elseif sort_type.ID == config_ugc_authorhome.C_HonorSortID.Sort then
    table.sort(not_selected, function(a, b)
      return self:SortByQuality(a, b)
    end)
  end
  table.sort(not_obtained, function(a, b)
    return a.ColorType > b.ColorType
  end)
  local sorted = {}
  for _, ach in ipairs(selected) do
    table.insert(sorted, ach)
  end
  for _, ach in ipairs(not_selected) do
    table.insert(sorted, ach)
  end
  for _, ach in ipairs(not_obtained) do
    table.insert(sorted, ach)
  end
  return sorted
end
function Logic_UGC_AuthorHome:CheckHasHonor(id, completed_achievement)
  log(bWriteLog and "UGC_AuthorHonorPage:CheckHasHonor id = " .. id)
  for i, v in pairs(completed_achievement) do
    if i == id then
      return true, v
    end
  end
  return false, -1
end
function Logic_UGC_AuthorHome:SortByFinishTime(a, b)
  local aFinishTime = a.FinishTime or -1
  local bFinishTime = b.FinishTime or -1
  return aFinishTime < bFinishTime
end
function Logic_UGC_AuthorHome:SortByQuality(a, b)
  local aFinishTime = a.FinishTime or -1
  local bFinishTime = b.FinishTime or -1
  if a.ColorType ~= b.ColorType then
    return a.ColorType > b.ColorType
  else
    return aFinishTime < bFinishTime
  end
end
function Logic_UGC_AuthorHome:CheckShowAuthorHomePage(uid, bGuestUGCAuthorInfo)
  log(bWriteLog and "Logic_UGC_AuthorHome:CheckShowAuthorHomePage")
  local cfg = CDataTable.GetTable("UGCAuthorFuncConfig")
  local Logic_UGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if not Logic_UGCAuthor:NewCheckPlayerIsAuthor(uid, bGuestUGCAuthorInfo) then
    log(bWriteLog and "Logic_UGC_AuthorHome:CheckShowAuthorHomePage uid is not author")
    return false
  end
  if Logic_UGCAuthor:CheckPlayerIsBannedByProfile(uid) then
    log(bWriteLog and "Logic_UGC_AuthorHome:CheckShowAuthorHomePage uid is banned")
    return false
  end
  local level = Logic_UGCAuthor:GetAuthorLevelByProfile(uid)
  if cfg.HomePageLimit and level >= cfg.HomePageLimit.Value then
    return true
  end
  return false
end
function Logic_UGC_AuthorHome:CheckFirstEnterAuthorHomePage()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local NewAuthorHomeSlapData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAuthorHomeSlap)
  if NewAuthorHomeSlapData and next(NewAuthorHomeSlapData) then
    return false
  end
  return true
end
function Logic_UGC_AuthorHome:SetFirstEnterAuthorHomePage()
  log(bWriteLog and "Logic_UGC_AuthorHome:SetFirstEnterAuthorHomePage")
  local version_util = require("client.common.version_util")
  local VersionStr = version_util.ExcludeTheBuildNumber(Client.GetAppVersion())
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({Version = VersionStr}, PlayerPrefsSystem.ePlayerPrefsType.eUGCAuthorHomeSlap)
end
function Logic_UGC_AuthorHome:AddHonorRedDot()
  self:CalculateTabDataList(config_ugc_authorhome.C_HonorGroupID.All, false)
  self:CalculateTabDataList(config_ugc_authorhome.C_HonorGroupID.HonorSeason, false)
  self:CalculateTabDataList(config_ugc_authorhome.C_HonorGroupID.HonorCreate, false)
  local all_data = self.cfgDataList[config_ugc_authorhome.C_HonorGroupID.All] or {}
  local ugc_playlevel_reddot_data = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
  for i, v in pairs(all_data) do
    ugc_playlevel_reddot_data.AddAuthorHomeRedDotData(config_ugc_authorhome.C_HonorGroupID.All, v.SortShowID)
  end
  local Season_data = self.cfgDataList[config_ugc_authorhome.C_HonorGroupID.HonorSeason] or {}
  for i, v in pairs(Season_data) do
    ugc_playlevel_reddot_data.AddAuthorHomeRedDotData(config_ugc_authorhome.C_HonorGroupID.HonorSeason, v.SortShowID)
  end
  local Create_data = self.cfgDataList[config_ugc_authorhome.C_HonorGroupID.HonorCreate] or {}
  for i, v in pairs(Create_data) do
    ugc_playlevel_reddot_data.AddAuthorHomeRedDotData(config_ugc_authorhome.C_HonorGroupID.HonorCreate, v.SortShowID)
  end
  log(bWriteLog and "Logic_UGC_AuthorHome:AddHonorRedDot end")
end
function Logic_UGC_AuthorHome:CancelHonorRedDot(honorID)
  local ugc_playlevel_reddot_data = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
  local tabID = self:GetTabIDByHonorID(honorID)
  local bRed = ugc_playlevel_reddot_data.GetAuthorHomeRedDot(honorID)
  if bRed then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local My_LocalHonorData = {}
    local bHas = false
    for i, v in pairs(self.LocalHonorData) do
      if v.UID == tonumber(DataMgr.roleData.uid) then
        My_LocalHonorData = v.RedDot
        bHas = true
        break
      end
    end
    if not bHas then
      table.insert(self.LocalHonorData, {
        UID = tonumber(DataMgr.roleData.uid),
        RedDot = My_LocalHonorData
      })
    end
    local CfgInfo = CDataTable.GetTableData("AchievementCfg", honorID)
    if not CfgInfo then
      log(bWriteLog and "Logic_UGC_AuthorHome:CancelHonorRedDot honorID = " .. honorID .. " not found in AchievementCfg")
      return
    end
    local logic_achievement_util = require("client.slua.logic.achievement.logic_achievement_util")
    local bMulti = logic_achievement_util.IsMultiAchievement(CfgInfo)
    if bMulti then
      local dataMap = self:CreatedMultiLvGroupIdAchiveMap()
      if dataMap == nil or dataMap[CfgInfo.GroupID] == nil or dataMap[CfgInfo.GroupID][CfgInfo.MultiLvGroupID] == nil then
        return
      end
      local dataList = dataMap[CfgInfo.GroupID][CfgInfo.MultiLvGroupID]
      for i, honor_id in pairs(dataList) do
        if honor_id <= honorID then
          ugc_playlevel_reddot_data.UpdateAuthorHomeRedDotData(tabID, honor_id)
          log(bWriteLog and "Logic_UGC_AuthorHome:CancelHonorRedDot tabID = " .. tabID .. " honorID = " .. honor_id .. " canel reddot " .. " bMulti = " .. tostring(bMulti))
          My_LocalHonorData[honor_id] = honor_id
        end
      end
    else
      ugc_playlevel_reddot_data.UpdateAuthorHomeRedDotData(tabID, honorID)
      My_LocalHonorData[honorID] = honorID
      log(bWriteLog and "Logic_UGC_AuthorHome:CancelHonorRedDot tabID = " .. tabID .. " honorID = " .. honorID .. " canel reddot " .. " bMulti = " .. tostring(bMulti))
    end
    PlayerPrefsSystem.SaveTableToFile_N(self.LocalHonorData or {}, PlayerPrefsSystem.ePlayerPrefsType.eUGCAuthorHonorRedDot)
  end
end
function Logic_UGC_AuthorHome:UpdateHonorRedDot(completed_achievement)
  log_tree("Logic_UGC_AuthorHome:UpdateHonorRedDot completed_achievement = ", completed_achievement)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.LocalHonorData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAuthorHonorRedDot) or {}
  log_tree("Logic_UGC_AuthorHome:UpdateHonorRedDot LocalHonorData = ", self.LocalHonorData)
  local My_LocalHonorData = {}
  for i, v in pairs(self.LocalHonorData) do
    if type(v) == "table" and v.UID == tonumber(DataMgr.roleData.uid) then
      My_LocalHonorData = v.RedDot or {}
      break
    end
  end
  log_tree("Logic_UGC_AuthorHome:UpdateHonorRedDot My_LocalHonorData = ", My_LocalHonorData)
  for honorID, v in pairs(completed_achievement) do
    if self:CheckNewHonor(honorID, My_LocalHonorData) then
      local tabID = self:GetTabIDByHonorID(honorID)
      local ugc_playlevel_reddot_data = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
      log(bWriteLog and "Logic_UGC_AuthorHome:UpdateHonorRedDot tabID = " .. tabID .. " honorID = " .. honorID .. " show reddot")
      ugc_playlevel_reddot_data.UpdateAuthorHomeRedDotData(tabID, honorID, true)
    end
  end
end
function Logic_UGC_AuthorHome:CheckNewHonor(honorID, LocalHonorData)
  log(bWriteLog and "Logic_UGC_AuthorHome:CheckNewHonor honorID = " .. honorID)
  for i, honor_ID in pairs(LocalHonorData) do
    if honor_ID == honorID then
      return false
    end
  end
  return true
end
function Logic_UGC_AuthorHome:GetTabIDByHonorID(honorID)
  local tabID = config_ugc_authorhome.C_HonorGroupID.HonorSeason
  self:CalculateTabDataList(config_ugc_authorhome.C_HonorGroupID.HonorCreate, false)
  local data = self.cfgDataList[config_ugc_authorhome.C_HonorGroupID.HonorCreate] or {}
  for i, v in pairs(data) do
    local muilti_honor_id = v[1] or {}
    for k, honor_id in pairs(muilti_honor_id) do
      if honorID == honor_id then
        tabID = config_ugc_authorhome.C_HonorGroupID.HonorCreate
        break
      end
    end
  end
  return tabID
end
function Logic_UGC_AuthorHome:UGCCreatorRankRsp(rank_source, res, rank_info)
  if rank_source ~= "wow_author_level" then
    return
  end
  if res ~= 0 then
    return
  end
  log_tree("Logic_UGC_AuthorHome:UGCCreatorRankRsp " .. rank_source .. " res=" .. tostring(res), rank_info)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rank_util = require("client.slua.logic.rank.rank_util")
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local rank = 0
  if rank_info and next(rank_info) and RankDataMgr.FilterDifferentPlatforms(rank_info.uid) then
    if rank_info.rank_no then
      if rank_info.rank_no <= 10000 then
        rank = tonumber(rank_info.rank_no)
      elseif rank_info.top1w then
        local score
        if tostring(rank_info.uid) == tostring(DataMgr.roleData.uid) then
          score = AchieveHandler.GetMyAchieveScore()
        else
          score = rank_info.score
        end
        local temp = rank_util.calc_topn_percentage(score, rank_info.top1w, "wow_author_level", rank_info.rank_no)
        rank = tonumber(temp)
      end
    elseif rank_info.top1w then
      local score
      if tostring(rank_info.uid) == tostring(DataMgr.roleData.uid) then
        score = AchieveHandler.GetMyAchieveScore()
      else
        score = rank_info.score
      end
      local temp = rank_util.calc_topn_percentage(score, rank_info.top1w, "wow_author_level", 0)
      rank = tonumber(temp)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CREATORRANK_RSP, rank)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_AuthorHome = class(CModuleBase, nil, Logic_UGC_AuthorHome)
return CLogic_UGC_AuthorHome