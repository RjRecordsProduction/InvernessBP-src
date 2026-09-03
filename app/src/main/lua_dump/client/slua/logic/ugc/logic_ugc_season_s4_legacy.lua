local Logic_UGC_Season = {}
function Logic_UGC_Season:GetMatchModSelectNum()
  print(bWriteLog and "Logic_UGC_Season:GetMatchModSelectNum [deprecated in S5]")
  if not self.MatchModMap then
    return self.C_MatchModDefaultNum
  end
  local TableUtil = require("common.table_util")
  local BanList = self:GetMatchBanList()
  local BanNum = TableUtil.CountTable(BanList)
  local AllNum = TableUtil.CountTable(self.MatchModMap)
  return AllNum - BanNum
end
function Logic_UGC_Season:GetMatchBanList()
  print(bWriteLog and "Logic_UGC_Season:GetMatchBanList [deprecated in S5]")
  if not self.MatchBanList then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    self.MatchBanList = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCSeasonMatchBanList) or {}
  end
  return self.MatchBanList
end
function Logic_UGC_Season:RefreshMatchBanList()
  print(bWriteLog and "Logic_UGC_Season:RefreshMatchBanList [deprecated in S5]")
  local NewList = {}
  local List = self:GetMatchBanList()
  for ModID, v in pairs(List) do
    if self.MatchModMap[ModID] then
      NewList[ModID] = v
    end
  end
  self.MatchBanList = NewList
  self:SetMatchBanList()
end
function Logic_UGC_Season:StartSelectMod()
  print(bWriteLog and "Logic_UGC_Season:StartSelectMod [deprecated in S5]")
  local TableUtil = require("common.table_util")
  self.OldBanList = TableUtil.CopyTable(self.MatchBanList)
end
function Logic_UGC_Season:EndSelectMod(bNew)
  print(bWriteLog and "Logic_UGC_Season:EndSelectMod [deprecated in S5]")
  if bNew then
    self:SetMatchBanList()
  elseif self.OldBanList then
    self.MatchBanList = self.OldBanList
  end
  self.OldBanList = nil
end
function Logic_UGC_Season:SwitchMatchModBanState(ModID, bIsBan)
  local List = self:GetMatchBanList()
  if bIsBan then
    local TableUtil = require("common.table_util")
    local AllNum = TableUtil.CountTable(self.MatchModMap)
    local BanNum = TableUtil.CountTable(List)
    List[ModID] = 1
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEASON_CHANGE_MOD)
    return true
  else
    List[ModID] = nil
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEASON_CHANGE_MOD)
    return false
  end
end
function Logic_UGC_Season:SetMatchBanList()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.MatchBanList or {}, PlayerPrefsSystem.ePlayerPrefsType.eUGCSeasonMatchBanList)
end
function Logic_UGC_Season:ClearMatchBanList()
  self.MatchBanList = {}
  self:SetMatchBanList()
end
function Logic_UGC_Season:SetBannerList()
  self.BannerShowList = {}
  self.UGCSeasonData = {set_type = "UGCSeason"}
  table.insert(self.BannerShowList, self.UGCSeasonData)
  if self.MatchModIDList and next(self.MatchModIDList) then
    self.ThemeData = {
      set_type = "theme",
      title = LocUtil.GetLocalizeResStr(9641002),
      mod_list = self.MatchModIDList
    }
    table.insert(self.BannerShowList, self.ThemeData)
  end
end
function Logic_UGC_Season:ReqAchievementData()
  log(bWriteLog and "[v_yibxu]Logic_UGC_Season.ReqAchievementData start")
  if self.AchievementData then
    log(bWriteLog and "[v_yibxu]Logic_UGC_Season.ReqAchievementData have data")
    return
  end
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_get_season_rating_add_records_req()
end
function Logic_UGC_Season:OnAchievementRsq(AchievementData)
  if not AchievementData then
    log(bWriteLog and "[v_yibxu]Logic_UGC_Season.OnAchievementRsq AchievementData = nil")
    return
  end
  self.  log_tree("[v_yibxu]Logic_UGC_Season.OnAchievementRsq self.AchievementData = ", self.AchievementData)
  local ModIDList = {}
  for _, Value in pairs(self.AchievementData) do
    table.insert(ModIDList, Value.mod_id)
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModInfoList, ReqList = LogicUGC:BatchGetModInfo(ModIDList, LogicUGC.C_ModListTypes.SeasonAchievement)
  if ModInfoList and next(ModInfoList) and (not ReqList or not (0 < #ReqList)) then
    self:OnModInfoBatchRsp(ModInfoList, LogicUGC.C_ModListTypes.SeasonAchievement)
  end
end
function Logic_UGC_Season:GetAchievementData()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local TimeUtil = require("client.common.time_util")
  local StringUtil = require("common.string_util")
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local ReuseFallData = {}
  if not self.AchievementData then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season GetAchievementData self.AchievementData = nil !")
    return ReuseFallData
  end
  local Map = {}
  for k, v in pairs(self.AchievementData) do
    local year = tonumber(TimeUtil.OSDate("!%Y", v.battle_time))
    local month = tonumber(TimeUtil.OSDate("!%m", v.battle_time))
    local day = tonumber(TimeUtil.OSDate("!%d", v.battle_time))
    local formattedDate = year * 10000 + month * 100 + day
    if not Map[formattedDate] then
      Map[formattedDate] = {}
    end
    table.insert(Map[formattedDate], v)
  end
  local KeyList = {}
  for key, value in pairs(Map) do
    table.insert(KeyList, key)
  end
  table.sort(KeyList, function(a, b)
    return b < a
  end)
  for key, value in pairs(KeyList) do
    table.sort(Map[value], function(a, b)
      return a.battle_time > b.battle_time
    end)
  end
  for i, v in ipairs(KeyList) do
    local Time = {}
    Time.SubType = Config_UGC.Config_UGC_WOWAchievementReuseFallItemType.Time
    Time.Data = Map[v][1].battle_time
    table.insert(ReuseFallData, Time)
    for key, value in pairs(Map[v]) do
      local Content = {}
      Content.SubType = Config_UGC.Config_UGC_WOWAchievementReuseFallItemType.Content
      Content.Data = value
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      local ModInfo = LogicUGC:GetModByAllCache(value.mod_id)
      if not ModInfo then
        log(bWriteLog and "[v_yibxu]Logic_UGC_Season:GetAchievementData mod_id = " .. value.mod_id .. " has no modinfo!")
      else
        Content.ModInfo = ModInfo.pub_mod_meta
      end
      table.insert(ReuseFallData, Content)
    end
    local Space = {}
    Space.SubType = Config_UGC.Config_UGC_WOWAchievementReuseFallItemType.Space
    table.insert(ReuseFallData, Space)
  end
  return ReuseFallData
end
return Logic_UGC_Season