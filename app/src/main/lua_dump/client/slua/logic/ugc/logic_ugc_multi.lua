local LogicUGCMulti = {
  REPORT_GAP = 10,
  COLLECT_BUNDLE_ID = 0,
  Activity_BUNDLE_ID = 0,
  DEFAULT_BUNDLE_ID = -1,
  MULTI_MAIN_MODE_OLD = 1010,
  MULTI_MAIN_MODE = 1015,
  MULTI_SELECT_IMAGE_PATH = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/UGC/Lobby_match_MapEntrance_MultipleChoiceMatching.Lobby_match_MapEntrance_MultipleChoiceMatching"
}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local PufferConst = require("client.slua.logic.download.puffer_const")
function LogicUGCMulti:DefineAndResetData()
  self.bIsBundleMatch = false
  self.BundleSelect = nil
  self.BundleType = 0
  self.BundleModList = nil
  self.MatchSubModID = nil
  self.bIsBundleUpdated = false
  self.DownloadReportTimer = nil
  self.HasReportDic = {}
  self:_SetDownloadReportTimer()
end
function LogicUGCMulti:OnPostSwitchGameStatus(preState, nextState)
  self.MatchSubModID = nil
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:_ClearDownloadReportTimer()
  elseif nextState == GameStatus.Lobby then
    self:_SetDownloadReportTimer()
  end
end
function LogicUGCMulti:OnLogin()
  self.HasReportDic = {}
end
function LogicUGCMulti:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MINE_MODS, self.OnMyCollectRsp, self, true)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_COLLECT, self.OnUpdateCollectRsp, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_RANDOM_RECOMMEND_DATA_READY, self.OnRandomListUpdated, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_MODINFO_RSP, self.OnHotThemeUpdated, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_MIXEDBANNER_UPDATE, self.OnBannerUpdated, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_BATCH_REQUESTCOLLECTION_META, self.OnCollectionUpdated, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_SEASON_GET_MOD_LIST, self.OnSeasonUpdated, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_LEADER_NOTIFY, self.OnTeamChangeLeader, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_THEME_FLASH, self._ReportModDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, self.OnMatchReload, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_SEASON_CONFIG, self.OnMatchReload, self)
end
local IsListEqual = function(t1, t2)
  if not t1 or not t2 then
    return false
  end
  if #t1 ~= #t2 then
    return false
  end
  local TableUtil = require("common.table_util")
  local Section = TableUtil.Intersection(t1, t2)
  return #t1 == #Section
end
function LogicUGCMulti:CheckMyCollectUpdated()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Collect then
    return
  end
  if self.bIsBundleUpdated then
    return
  end
  if not self.BundleModList then
    return
  end
  if not self.bIsBundleMatch then
    log(bWriteLog and "[edward] LogicUGCMulti:CheckMyCollectUpdated, no in bundle match")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CollectList = LogicUGC:GetCollectKeyInfoList()
  if not CollectList then
    return
  end
  local LocCollectList = {}
  for k, v in pairs(CollectList) do
    table.insert(LocCollectList, k)
  end
  if not IsListEqual(self.BundleModList, LocCollectList) then
    self.bIsBundleUpdated = true
    ShowNotice(8600140)
  end
end
function LogicUGCMulti:CheckDataUpdated()
  if self.bIsBundleUpdated then
    log(bWriteLog and "[edward] LogicUGCMulti:OnCheckDataUpdated, is already show notice")
    return
  end
  if not self.bIsBundleMatch then
    log(bWriteLog and "[edward] LogicUGCMulti:OnCheckDataUpdated, no in bundle match")
    return
  end
  if not self.BundleModList or not self.BundleSelect then
    return
  end
  if Config_UGC.NewWOWHall == 2 and self.BundleType == Config_UGC.Enum_Bundle_Type.HotTheme then
    log(bWriteLog and "LogicUGCMulti:CheckDataUpdated self.BundleType is HotTheme")
    return
  end
  local BundleID = self.BundleSelect and self.BundleSelect[1]
  local NewModList = self:GetModList(self.BundleType, BundleID)
  if not IsListEqual(self.BundleModList, NewModList) then
    self.bIsBundleUpdated = true
    ShowNotice(8600140)
  end
end
function LogicUGCMulti:StartMatch()
  if not Config_UGC.IsUGCReleased() then
    log(bWriteLog and "[edward] LogicUGCMulti:StartMatch ugc not release")
    return
  end
  if LobbySystem.isInMatch then
    ShowNotice(6244)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(70010)
    return
  end
  local bIsSeasonMatch = self.BundleType == Config_UGC.Enum_Bundle_Type.Season
  if not bIsSeasonMatch and not LobbySystem.CheckOpen(BP_ENUM_MULTI_UGC_SWITCH) then
    log(bWriteLog and "[edward] LogicUGCMulti:StartMatch not open")
    ShowNotice(48978)
    return
  end
  if not self.BundleSelect then
    return
  end
  local MatchModList = self.BundleModList
  if not MatchModList then
    print(bWriteLog and "[edward] LogicUGCMulti:StartMatch, MatchModList is nil")
    ShowNotice(8600139)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local TeamNum = TeamUpNewSystem.GetTeamNum()
  local MaxTeamSize = self:GetMaxTeamSize()
  if TeamNum > MaxTeamSize then
    ShowNotice(8600142)
    return
  end
  local State, cSize, tSize = self:GetResState()
  if State ~= PufferConst.ENUM_DownloadState.Done then
    local title = LocUtil.GetLocalizeResStr(101001)
    local btnOK = LocUtil.LocalizeResFormat(7420)
    local msg = LocUtil.LocalizeResFormat(63000, string.format("%.1f", math.max(tSize - cSize, 0.1)))
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, msg, function(isCheck)
      self:DownloadMultiModList()
    end, nil, btnOK)
    return
  end
  self:CheckDataUpdated()
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_multi_match_req(MatchModList, false, nil, false, bIsSeasonMatch)
end
function LogicUGCMulti:SetMatchMod(MatchSubModID)
  self.  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_MATCH_SUC)
end
function LogicUGCMulti:GetMatchMod()
  return self.MatchSubModID
end
function LogicUGCMulti:BundleType2ListType(BundleType)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
    return UGCMacros.ENUM_MODE_TYPE.Collections
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Banner then
    return UGCMacros.ENUM_MODE_TYPE.MixedBanner
  elseif BundleType == Config_UGC.Enum_Bundle_Type.HotTheme then
    return UGCMacros.ENUM_MODE_TYPE.HotTheme
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Random then
    return UGCMacros.ENUM_MODE_TYPE.Random
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Collect then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.IsTeamLeader() then
      return UGCMacros.ENUM_MODE_TYPE.Collect
    else
      return UGCMacros.ENUM_MODE_TYPE.OtherCollect
    end
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Season then
    return UGCMacros.ENUM_MODE_TYPE.Season
  elseif BundleType == Config_UGC.Enum_Bundle_Type.TourNament then
    return UGCMacros.ENUM_MODE_TYPE.Match_tab
  else
    return ""
  end
end
function LogicUGCMulti:IsInBundleModList(ModId)
  if self.BundleModList then
    for _, ModID in ipairs(self.BundleModList) do
      if ModID == ModId then
        return true
      end
    end
  end
  return false
end
function LogicUGCMulti:GetMaxTeamSize(ModList)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local DefaultTeamSize = TeamUpNewSystem.GetDefaultMaxTeamNum()
  local List
  if ModList then
    List = ModList
  else
    List = self.BundleModList
    log(bWriteLog and "[edward] LogicUGCMulti:GetMaxTeamSize, is bundle mod list")
  end
  if not List then
    return DefaultTeamSize
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local TeamSize = 1
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ReqModList = {}
  for _, ModID in ipairs(List) do
    local ModInfo = LogicUGC:GetModByAllCache(ModID)
    if not ModInfo then
      table.insert(ReqModList, ModID)
    else
      if ModInfo.pub_mod_meta then
        ModInfo = ModInfo.pub_mod_meta
      end
      local ModTeamSize = Util_UGC.GetModTeamSize(ModInfo)
      if TeamSize < ModTeamSize then
        TeamSize = ModTeamSize
      end
    end
  end
  if 0 < #ReqModList then
    log(bWriteLog and "[edward] LogicUGCMulti:GetMaxTeamSize, data is not ready")
    return DefaultTeamSize, false
  else
    log(bWriteLog and "[edward] LogicUGCMulti:GetMaxTeamSize, TeamSize = " .. tostring(TeamSize))
    return TeamSize, true
  end
end
function LogicUGCMulti:GetCollectList()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsTeamLeader() then
    if self.BundleSelect and self.BundleSelect[1] then
      return self.BundleModList, false
    end
  else
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local CollectList = LogicUGC:GetCollectKeyInfoList()
    if CollectList then
      local LocCollectList = {}
      for ModID, v in pairs(CollectList) do
        local ModInfo = LogicUGC:GetModByAllCache(ModID)
        if ModInfo then
          table.insert(LocCollectList, ModID)
        end
      end
      return LocCollectList, true
    end
  end
  return {}
end
function LogicUGCMulti:RefreshIsBundleMatch()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local MatchMode = logic_mode_selection:GetCurSelectInfo()
  MatchMode = tonumber(MatchMode)
  self.bIsBundleMatch = MatchMode and (MatchMode == self.MULTI_MAIN_MODE or MatchMode == self.MULTI_MAIN_MODE_OLD)
  log(bWriteLog and "[edward] LogicUGCMulti:RefreshIsBundleMatch, bIsBundleMatch = " .. tostring(self.bIsBundleMatch))
  if self.bIsBundleMatch then
    if self.BundleType == Config_UGC.Enum_Bundle_Type.Season then
      local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
      if Logic_UGC_Season:IsDuringSeasonFrozen() then
        print(bWriteLog and "LogicUGCMulti:RefreshIsBundleMatch, is during season frozen")
        logic_mode_selection:ForceResetModeToAvailableMap()
        return
      end
    end
    local timer_tick = require("common.time_ticker")
    timer_tick.AddTimer(0.5, function()
      self:CheckAndReqNeedData()
    end)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_BUNDLE)
end
function LogicUGCMulti:OnMatchReload()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local MatchMode = logic_mode_selection:GetCurSelectInfo()
  MatchMode = tonumber(MatchMode)
  local bIsBundleMatch = MatchMode and (MatchMode == self.MULTI_MAIN_MODE or MatchMode == self.MULTI_MAIN_MODE_OLD)
  log(bWriteLog and "[yintaoxu] LogicUGCMulti:OnMatchReloa, bIsBundleMatch = " .. tostring(bIsBundleMatch))
  if bIsBundleMatch and self.BundleType == Config_UGC.Enum_Bundle_Type.Season then
    local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
    if Logic_UGC_Season:IsDuringSeasonFrozen() then
      print(bWriteLog and "LogicUGCMulti:RefreshIsBundleMatch, is during season frozen")
      logic_mode_selection:ForceResetModeToAvailableMap()
    end
  end
end
function LogicUGCMulti:GetSelectBundleModCount()
  if not self.BundleModList or not next(self.BundleModList) then
    return 0
  end
  return #self.BundleModList
end
function LogicUGCMulti:GetSelectBundleName()
  local BundleName = LocUtil.GetLocalizeResStr(48973)
  if not self.BundleSelect or not next(self.BundleSelect) then
    return BundleName
  end
  local BundleID = self.BundleSelect[1]
  if self.BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    BundleName = LogicUGCCollectionList:GetSelectBundleName(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Banner then
    local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
    BundleName = logic_ugc_hot_page:GetSelectBannerBundleName(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.HotTheme then
    local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
    BundleName = logic_ugc_hot_page:GetSelectHotThemeBundleName(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Random then
    local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
    BundleName = logic_ugc_random_recommend:GetSelectBundleName(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Collect then
    BundleName = LocUtil.GetLocalizeResStr(70067)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Season then
    local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
    BundleName = Logic_UGC_Season:GetSelectBundleName(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.TourNament then
    local logic_ugc_match_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_match_tab)
    BundleName = logic_ugc_match_tab:GetSelectBundleName(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.ActivityTemplate then
    BundleName = LocUtil.GetLocalizeResStr(69262)
  else
    local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
    BundleName = logic_ugc_random_recommend:GetSelectBundleName(BundleID)
  end
  return BundleName
end
function LogicUGCMulti:GetSelectBundlePic()
  local TexturePath = self.MULTI_SELECT_IMAGE_PATH
  local bIsLocal = true
  if not self.BundleSelect or not next(self.BundleSelect) then
    return TexturePath, bIsLocal
  end
  local BundleID = self.BundleSelect[1]
  if self.BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    local Pic = LogicUGCCollectionList:GetSelectBundlePic(BundleID)
    if Pic and Pic ~= "" then
      TexturePath = Pic
      bIsLocal = false
    end
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Season then
    local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
    TexturePath = Logic_UGC_Season:GetSelectBundlePic(BundleID)
  else
    local List = self.BundleModList
    if List and next(List) then
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      for _, ModID in ipairs(List) do
        local Cache = LogicUGC:GetModByAllCache(ModID)
        if Cache then
          local ModInfo = Cache.pub_mod_meta
          local Util_UGC = require("client.slua.logic.ugc.util_ugc")
          local Pic = Util_UGC.GetCoverImageUrl(ModInfo.setting, ModInfo.base.template_id, false)
          if Pic then
            TexturePath = Pic
            bIsLocal = false
            break
          end
        end
      end
    else
      log(bWriteLog and "[edward] LogicUGCMulti:GetSelectBundlePic ,BundleType, BundleID = " .. string.format("%d-%s", self.BundleType, tostring(self.BundleSelect and self.BundleSelect[1])))
    end
  end
  return TexturePath, bIsLocal
end
function LogicUGCMulti:IsMatchSuccessByUGCMulti()
  local MatchSubModID = self:GetMatchMod()
  if not MatchSubModID then
    log(bWriteLog and "[edward] LogicUGCMulti:IsMatchSuccessByUGCMulti return false, no MatchSubModID")
    return false
  end
  if not self.bIsBundleMatch then
    log(bWriteLog and "[edward] LogicUGCMulti:IsMatchSuccessByUGCMulti return false, self.bIsBundleMatch is false")
    return false
  end
  return true
end
function LogicUGCMulti:ReqSetUGCModBundle(BundleType, BundleID)
  log(bWriteLog and "[edward] LogicUGCMulti:ReqSetUGCModBundle ,BundleType, BundleID = " .. string.format("%d-%s", BundleType, tostring(BundleID)))
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnClickEntry, is not team leader!!!")
    ShowNotice(500045)
    return false
  end
  if not Config_UGC.IsUGCReleased() then
    log(bWriteLog and "[edward] LogicUGCMulti:ReqSetUGCModBundle ugc not release")
    return false
  end
  if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for UID, MemberInfo in pairs(TeamUpNewSystem.teamInfo.members) do
      if tonumber(UID) ~= TeamUpNewSystem.GetSelfUID() then
        local Level = MemberInfo.level
        if not Config_UGC.IsUGCUnlock(Level) then
          ShowNotice(LocUtil.LocalizeResFormat(7925, MemberInfo.name))
          return
        end
      end
    end
  end
  local bIsSeasonMatch = BundleType == Config_UGC.Enum_Bundle_Type.Season
  if not bIsSeasonMatch and not LobbySystem.CheckOpen(BP_ENUM_MULTI_UGC_SWITCH) then
    log(bWriteLog and "[edward] LogicUGCMulti:ReqSetUGCModBundle not open")
    ShowNotice(48978)
    return false
  end
  if LobbySystem.isInMatch then
    ShowNotice(6244)
    return false
  end
  if TeamUpNewSystem.GetTeamNum() > TeamUpNewSystem.GetDefaultMaxTeamNum() then
    ShowNotice(8600136)
    return false
  end
  local ModList
  ModList, BundleID = self:GetModList(BundleType, BundleID)
  if ModList and 0 < #ModList then
    ModList = self:FilterSubMode(ModList)
    if ModList and #ModList == 0 then
      ShowNotice(78399)
      return false
    end
  end
  if not ModList or #ModList == 0 then
    log(bWriteLog and "[edward] LogicUGCMulti:ReqSetUGCModBundle return, no ModList")
    if BundleType == Config_UGC.Enum_Bundle_Type.Collect then
      ShowNotice(8600138)
    elseif BundleType == Config_UGC.Enum_Bundle_Type.ActivityTemplate then
      ShowNotice(8600138)
    elseif BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
      ShowNotice(8600139)
    end
    return false
  end
  local MaxTeamSize = self:GetMaxTeamSize(ModList)
  if MaxTeamSize < TeamUpNewSystem.GetTeamNum() then
    ShowNotice(8600142)
    return false
  end
  local TLogSourceTable = {}
  TLogSourceTable.source_type = TLogEventDefine.UGC_Bundle_Match
  TLogSourceTable.sub_source_id = BundleType
  print(bWriteLog and "[edward] LogicUGCMulti:ReqSetUGCModBundle TLogSourceTable.sub_source_id = " .. TLogSourceTable.sub_source_id)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_set_ugc_mod_bundle_req({BundleID}, BundleType, ModList, TLogSourceTable)
  self.bIsBundleUpdated = false
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Clear()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SELECT_MOD)
  return true
end
function LogicUGCMulti:FilterSubMode(ModList)
  if not ModList or #ModList == 0 then
    return ModList
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local FilteredModList = {}
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  for _, ModID in ipairs(ModList) do
    local ModInfo = LogicUGC:GetModByAllCache(ModID)
    if not Util_UGC.IsSubModeGameMod(ModInfo and ModInfo.pub_mod_meta) then
      table.insert(FilteredModList, ModID)
    end
  end
  return FilteredModList
end
function LogicUGCMulti:GetModList(BundleType, BundleID)
  local ModList
  if BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    ModList = LogicUGCCollectionList:GetSelectBundleModList(BundleID)
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Banner then
    local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
    ModList = logic_ugc_hot_page:GetSelectBannerBundleModList(BundleID)
  elseif BundleType == Config_UGC.Enum_Bundle_Type.HotTheme then
    local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
    ModList = logic_ugc_hot_page:GetSelectThemeBundleModList(BundleID)
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Random then
    BundleID = self.DEFAULT_BUNDLE_ID
    local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
    ModList = logic_ugc_random_recommend:GetSelectBundleModList(BundleID)
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Collect then
    BundleID = self.COLLECT_BUNDLE_ID
    ModList = self:GetCollectList()
    if 30 < #ModList then
      local TempModList = {}
      for i = 1, 30 do
        table.insert(TempModList, ModList[i])
      end
      ModList = TempModList
    end
  elseif BundleType == Config_UGC.Enum_Bundle_Type.Season then
    BundleID = self.DEFAULT_BUNDLE_ID
    local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
    ModList = Logic_UGC_Season:GetSelectBundleModList(BundleID)
  elseif BundleType == Config_UGC.Enum_Bundle_Type.TourNament then
    local logic_ugc_match_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_match_tab)
    ModList = logic_ugc_match_tab:GetSelectBundleModList(BundleID)
  elseif BundleType == Config_UGC.Enum_Bundle_Type.ActivityTemplate then
    BundleID = self.Activity_BUNDLE_ID
    ModList = self:GetActivityTemplateList()
    if 4 < #ModList then
      local TempModList = {}
      for i = 1, 4 do
        table.insert(TempModList, ModList[i])
      end
      ModList = TempModList
    end
  else
    BundleID = self.DEFAULT_BUNDLE_ID
    local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
    ModList = logic_ugc_random_recommend:GetSelectBundleModList(BundleID)
  end
  return ModList, BundleID
end
function LogicUGCMulti:OnSetUGCModBundleRsp(ErrorCode, Bundle, BundleType, ModList)
  if ErrorCode ~= 0 then
    ShowNotice(ErrorCode)
    return
  end
  log(bWriteLog and "[edward] LogicUGCMulti:OnSetUGCModBundleRsp, Bundle, BundleType = " .. string.format("%d-%d", Bundle[1], BundleType))
  log_tree(bWriteLog and "[edward] LogicUGCMulti:OnSetUGCModBundleRsp", ModList)
  self.bIsBundleMatch = true
  self.  self.BundleSelect = Bundle
  self.Bundle  if self.BundleModList then
    for i = #self.BundleModList, 1, -1 do
      if 0 >= self.BundleModList[i] then
        table.remove(self.BundleModList, i)
      end
    end
  end
  self:BatchReqBundleUGCPubModInfo()
  self:_ReportModDownloadState()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_BUNDLE)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowExtraTeamUI()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Season and (TeamUpNewSystem:GetTeamNum() == 1 or TeamUpNewSystem.IsTeamLeader()) then
    ShowNotice(8600149)
  end
  if self.BundleType == Config_UGC.Enum_Bundle_Type.Season then
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    if self.BundleModList then
      for _, v in pairs(self.BundleModList) do
        Logic_UGC_TLog:SendModTLog(v, TLogEventDefine.UGC_Mod_Season_Main, UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_GAME)
      end
    else
      log(bWriteLog and "[edward] LogicUGCMulti:OnSetUGCModBundleRsp, ModList is nil")
    end
  end
end
function LogicUGCMulti:CheckAndReqNeedData()
  if not self.bIsBundleMatch then
    return
  end
  if not self.BundleSelect or not next(self.BundleSelect) then
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    UGCModHandler.send_get_ugc_mod_bundle_req()
    return
  end
  self:BatchReqBundleUGCPubModInfo()
  local BundleID = self.BundleSelect and self.BundleSelect[1]
  if not BundleID then
    return
  end
  if self.BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    LogicUGCCollectionList:CheckModListReady(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Banner then
    local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
    logic_ugc_hot_page:CheckBannerModListReady(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.HotTheme then
    local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
    logic_ugc_hot_page:CheckHotThemeModListReady(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Random then
    local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
    logic_ugc_random_recommend:CheckModListReady(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Collect then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if not LogicUGC:GetCollectKeyInfoList() then
      LogicUGC:ReqGetAllMetaKey()
    end
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.Season then
    local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
    Logic_UGC_Season:CheckModListReady(BundleID)
  elseif self.BundleType == Config_UGC.Enum_Bundle_Type.TourNament then
    local logic_ugc_match_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_match_tab)
    logic_ugc_match_tab:CheckModListReady(BundleID)
  else
    local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
    logic_ugc_random_recommend:CheckModListReady(BundleID)
  end
end
function LogicUGCMulti:OnGetUGCModBundleRsp(BundleInfo)
  if not BundleInfo or type(BundleInfo) ~= "table" then
    self.bIsBundleMatch = false
    self.BundleType = 0
    self.BundleSelect = nil
    self.BundleModList = nil
    return
  end
  log_tree(bWriteLog and "[edward] LogicUGCMulti:OnGetUGCModBundleRsp BundleInfo = ", BundleInfo)
  self.BundleType = BundleInfo.ugc_bundle_type or 0
  self.BundleSelect = BundleInfo.ugc_bundle_list
  self.BundleModList = BundleInfo.ugc_mod_list
  if self.BundleModList then
    for i = #self.BundleModList, 1, -1 do
      if 0 >= self.BundleModList[i] then
        table.remove(self.BundleModList, i)
      end
    end
  end
  self:RefreshIsBundleMatch()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowExtraTeamUI()
end
function LogicUGCMulti:OnMyCollectRsp()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CollectList = LogicUGC:GetCollectKeyInfoList()
  if CollectList then
    local ModList = {}
    for k, v in pairs(CollectList) do
      table.insert(ModList, k)
    end
    LogicUGC:BatchGetModInfo(ModList, LogicUGC.C_ModListTypes.Collect)
  end
  self:CheckMyCollectUpdated()
  self:ReportModDownloadState()
end
function LogicUGCMulti:OnUpdateCollectRsp()
  self:CheckMyCollectUpdated()
end
function LogicUGCMulti:OnRandomListUpdated()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Random then
    return
  end
  self:ReportModDownloadState()
end
function LogicUGCMulti:OnHotThemeUpdated()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.HotTheme then
    return
  end
  self:ReportModDownloadState()
end
function LogicUGCMulti:OnBannerUpdated()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Banner then
    return
  end
  self:ReportModDownloadState()
end
function LogicUGCMulti:OnCollectionUpdated()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Bundle then
    return
  end
  self:ReportModDownloadState()
end
function LogicUGCMulti:OnSeasonUpdated()
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Season then
    return
  end
  self:ReportModDownloadState()
end
function LogicUGCMulti:BatchReqBundleUGCPubModInfo(bSkipCheckOtherModule)
  if not self.bIsBundleMatch then
    log(bWriteLog and "[edward] LogicUGCMulti:BatchReqBundleUGCPubModInfo, not in multi")
    return
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local TempCache = LogicUGC:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.UgcMatch) or {}
  local TempReqCache = LogicUGC:GetMatchModIsReq() or {}
  LogicUGC:ClearModCacheByType(UGCMacros.ENUM_MODE_TYPE.UgcMatch, true)
  if self.BundleModList then
    for _, ModID in ipairs(self.BundleModList) do
      local ModInfo = TempCache[ModID]
      if ModInfo then
        LogicUGC:SetMatchCache(ModID, ModInfo)
      end
      if TempReqCache[ModID] then
        LogicUGC:SetMatchReqCache(ModID)
      end
    end
    local ModInfoList, ReqList = LogicUGC:BatchGetModInfo(self.BundleModList, LogicUGC.C_ModListTypes.UgcMatch)
    if ModInfoList and next(ModInfoList) and (not ReqList or not (0 < #ReqList)) then
      self:OnModInfoBatchRsp(ModInfoList, LogicUGC.C_ModListTypes.UgcMatch)
    end
  end
end
function LogicUGCMulti:OnModInfoBatchRsp(MetaList, ListType, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.UgcMatch) then
    return
  end
  self:_ReportModDownloadState()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_BUNDLE)
end
function LogicUGCMulti:OnMultiMatchRsp(MatchModCount)
  if not self.bIsBundleMatch then
    return
  end
  if not self.BundleModList then
    return
  end
  self.bIsBundleUpdated = false
  if MatchModCount and 0 < MatchModCount then
    local ReqMatchModCount = #self.BundleModList
    if ReqMatchModCount ~= MatchModCount then
      local Tips = LocUtil.LocalizeResFormat(8600137, tostring(MatchModCount))
      ShowNotice(Tips)
    end
  end
end
function LogicUGCMulti:OnTeamChangeLeader()
  if not self.bIsBundleMatch then
    return
  end
  if self.BundleType ~= Config_UGC.Enum_Bundle_Type.Collect then
    return
  end
  log(bWriteLog and "[edward] LogicUGCMulti:OnTeamChangeLeader, will notice mod list changed")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsTeamLeader() then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local CollectList = LogicUGC:GetCollectKeyInfoList()
    if not CollectList then
      log(bWriteLog and "[edward] LogicUGCMulti:OnTeamChangeLeader, no cache")
      LogicUGC:ReqGetAllMetaKey()
    else
      log(bWriteLog and "[edward] LogicUGCMulti:OnTeamChangeLeader, notice changed")
      self:CheckMyCollectUpdated()
    end
  end
end
function LogicUGCMulti:GetResState()
  if not self.bIsBundleMatch then
    return PufferConst.ENUM_DownloadState.Done
  end
  local List = self.BundleModList
  if not List then
    return PufferConst.ENUM_DownloadState.Done
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local Mods = {}
  for _, ModID in ipairs(List) do
    local ModInfo = LogicUGC:GetModByAllCache(ModID)
    if ModInfo then
      table.insert(Mods, ModInfo.pub_mod_meta)
    end
  end
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local LoaderType = LogicUGCResManager.DownloaderType.ModList
  return LogicUGCResManager:GetResState(LoaderType, Mods), LogicUGCResManager:GetResSize(LoaderType, Mods)
end
function LogicUGCMulti:CheckResDownloadDoneAtLeast()
  if not self.bIsBundleMatch then
    return true
  end
  local List = self.BundleModList
  if not List then
    return true
  end
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  for _, ModID in ipairs(List) do
    local ModInfo = LogicUGC:GetModByAllCache(ModID)
    if ModInfo then
      local State = LogicUGCResManager:GetResState(LogicUGCResManager.DownloaderType.ModCopy, ModInfo.pub_mod_meta)
      if State == PufferConst.ENUM_DownloadState.Done then
        return true
      end
    end
  end
  return false
end
function LogicUGCMulti:DownloadMultiModList()
  if not self.bIsBundleMatch then
    return
  end
  local List = self.BundleModList
  if not List then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local Mods = {}
  for _, ModID in ipairs(List) do
    local ModInfo = LogicUGC:GetModByAllCache(ModID)
    if ModInfo then
      table.insert(Mods, ModInfo.pub_mod_meta)
    end
  end
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  LogicUGCResManager:DownloadRes(LogicUGCResManager.DownloaderType.ModList, Mods)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_DOWNLOAD_STATE)
end
function LogicUGCMulti:_SetDownloadReportTimer()
  self:_ClearDownloadReportTimer()
  local time_ticker = require("common.time_ticker")
  self.DownloadReportTimer = time_ticker.AddTimerLoop(0, function()
    self:_ReportModDownloadState()
  end, TIMER_INFINITE, self.REPORT_GAP)
end
function LogicUGCMulti:_CheckReportSingleMod(ModID)
  if self.HasReportDic[ModID] then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modInfo = LogicUGC:GetModByAllCache(ModID)
  if not modInfo then
    return
  end
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  if LogicUGCResManager:GetResState(LogicUGCResManager.DownloaderType.ModCopy, modInfo.pub_mod_meta) ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  log(bWriteLog and "_SetDownloadReportTimer send " .. tostring(modInfo.pub_mod_meta.mod_id))
  LogicUGCResManager:Send_update_client_mod_info_ByModInfo(modInfo.pub_mod_meta)
  self.HasReportDic[ModID] = true
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_DOWNLOAD_STATE)
end
function LogicUGCMulti:_ReportModDownloadState()
  local List = self.BundleModList
  if not List then
    return
  end
  for _, ModID in pairs(List) do
    self:_CheckReportSingleMod(ModID)
  end
end
function LogicUGCMulti:_ClearDownloadReportTimer()
  local time_ticker = require("common.time_ticker")
  if self.DownloadReportTimer then
    time_ticker.RemoveTimer(self.DownloadReportTimer)
    self.DownloadReportTimer = nil
  end
end
function LogicUGCMulti:ReportModDownloadState()
  if not self.bIsBundleMatch then
    return
  end
  self:_ReportModDownloadState()
end
function LogicUGCMulti:ClearReportCache(bReport)
  self.HasReportDic = {}
  if bReport then
    self:_SetDownloadReportTimer()
  end
end
function LogicUGCMulti:GetActivityTemplateList()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsTeamLeader() then
    if self.BundleSelect and self.BundleSelect[1] then
      return self.BundleModList, false
    end
  else
    local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
    local firstValidActID = Logic_UGC_ThemePlay_ActivityTemplate:GetCurrActivetID()
    local modList = Logic_UGC_ThemePlay_ActivityTemplate:GetCurActModIDList(firstValidActID)
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if modList then
      local LocCollectList = {}
      for k, ModID in pairs(modList) do
        local ModInfo = LogicUGC:GetModByAllCache(ModID)
        if ModInfo then
          table.insert(LocCollectList, ModID)
        end
      end
      return LocCollectList, true
    end
  end
  return {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCMulti = class(CModuleBase, nil, LogicUGCMulti)
return CLogicUGCMulti