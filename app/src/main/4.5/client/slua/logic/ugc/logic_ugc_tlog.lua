local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local C_ExposeCounterUnit = 1000
local Logic_UGC_TLog = {}
function Logic_UGC_TLog:DefineAndResetData()
  self.curRequestId = 0
  self.TLogSwitch = true
  self.workTlogTimestamp = nil
  self.collectionsTlogTimestamp = nil
  self.workTlogTimestampUGCMain = nil
  self.tlogCacheShowModList = nil
  self.isShowModDeduplicationOpen = false
  self.origin_origin_workReachTlogTimestamp = nil
  self.LastSelectModInfo = nil
  self.LastSelectCollection = nil
  self.Collection_id = nil
  self.SearchValue = nil
  self.BattleID = nil
  self.ExposeCounter = 0
end
function Logic_UGC_TLog:OnInitialize()
  log(bWriteLog and "Logic_UGC_TLog OnInitialize")
  self:UpdateRequestId()
end
function Logic_UGC_TLog:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "Logic_UGC_TLog OnPreSwitchGameStatus")
  self:ClearCacheData()
  if nextState == GameStatus.Lobby then
    self:UpdateRequestId()
    self.BattleID = nil
  end
end
function Logic_UGC_TLog:OnLogOut()
  log(bWriteLog and "Logic_UGC_TLog OnLogOut")
  self:ClearCacheData()
  self.LastSelectModInfo = nil
end
function Logic_UGC_TLog:ClearCacheData()
  self.origin_workReachTlogTimestamp = nil
  self.workTlogTimestamp = nil
  self.workTlogTimestampUGCMain = nil
  self.tlogCacheShowModList = nil
  self.LastSelectCollection = nil
end
function Logic_UGC_TLog:UpdateRequestId()
  local TimeUtil = require("client.common.time_util")
  self.curRequestId = math.floor(TimeUtil.GetServerTimeInSecWithFraction() * 1000)
  log(bWriteLog and "Logic_UGC_TLog RefreshRequestId UpdateRequestId:" .. tostring(self.curRequestId))
  self.TLogSwitch = true
  local UGCNewTLogReport = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCNewTLogReport)
  UGCNewTLogReport:ClearExposedCache()
end
function Logic_UGC_TLog:UpdateSearchValue()
  local TimeUtil = require("client.common.time_util")
  self.SearchValue = math.floor(TimeUtil.GetServerTimeInSecWithFraction() * 1000)
end
function Logic_UGC_TLog:GetSearchValue()
  return self.SearchValue
end
function Logic_UGC_TLog:StartRecordShowModDeduplication()
  self.tlogCacheShowModList = {}
  self.isShowModDeduplicationOpen = true
end
function Logic_UGC_TLog:EndRecordShowModDeduplication()
  self.tlogCacheShowModList = {}
  self.isShowModDeduplicationOpen = false
end
function Logic_UGC_TLog:SetTLogSwitch(switch)
  self.TLogSwitch = switch and true or false
end
function Logic_UGC_TLog:RecordLastThemaCollectionId(ThemaCollectionId)
  print(bWriteLog and "Logic_UGC_TLog:RecordLastThemaCollectionId ThemaCollectionId = " .. tostring(ThemaCollectionId))
  self.Lastend
function Logic_UGC_TLog:RecordLastThemaDataType(DataType)
  print(bWriteLog and "Logic_UGC_TLog:RecordLastThemaDataType DataType = " .. tostring(DataType))
  self.LastThemaDataTypeend
function Logic_UGC_TLog:ReportCollectionsTlog(mod_collection_id, tlog_event, ext)
  if not tlog_event then
    log(bWriteLog and "Logic_UGC_TLog:ReportCollectionsTlog no tlog_event")
    return
  end
  if not self:_CheckCanReportCollections(mod_collection_id, tlog_event, ext) then
    log(bWriteLog and "Logic_UGC_TLog:ReportCollectionsTlog cd modId:" .. tostring(mod_collection_id))
    return
  end
  local str = string.format("mod_collection_id=%s", tostring(mod_collection_id))
  if ext then
    for K, V in pairs(ext) do
      str = string.format("%s&%s=%s", str, tostring(K), tostring(V))
    end
  end
  log(bWriteLog and "Logic_UGC_TLog:ReportCollectionsTlog tlog_event = " .. tostring(tlog_event))
  log(bWriteLog and "Logic_UGC_TLog:ReportCollectionsTlog mod_collection_id = " .. tostring(mod_collection_id) .. " reason_str = " .. str)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(tlog_event, nil, str)
end
function Logic_UGC_TLog:_CheckCanReportCollections(mod_collection_id, tlog_event, ext)
  local bRet = true
  self.collectionsTlogTimestamp = self.collectionsTlogTimestamp or {}
  self.collectionsTlogTimestamp[tlog_event] = self.collectionsTlogTimestamp[tlog_event] or {}
  self.collectionsTlogTimestamp[tlog_event][mod_collection_id] = self.collectionsTlogTimestamp[tlog_event][mod_collection_id] or {}
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local TimeUtil = require("client.common.time_util")
  local cur_time = TimeUtil.GetServerTimeInSec()
  ext = ext or 0
  local cache_time = self.collectionsTlogTimestamp[tlog_event][mod_collection_id][ext]
  log(bWriteLog and string.format("Logic_UGC_TLog:_CheckCanReportCollections mod_collection_id[%s] ext[%s] cur_time[%s] cache_time[%s]", tostring(mod_collection_id), tostring(ext), tostring(cur_time), tostring(cache_time)))
  if not cache_time then
    self.collectionsTlogTimestamp[tlog_event][mod_collection_id][ext] = cur_time
    bRet = true
  elseif UGCMacros.TLOG_COLLECTION_REACH_CD < cur_time - cache_time then
    self.collectionsTlogTimestamp[tlog_event][mod_collection_id][ext] = cur_time
    bRet = true
  else
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportModTLog cd \226\128\166\226\128\166")
    bRet = false
  end
  return bRet
end
function Logic_UGC_TLog:ReportShareCollection(CollectionId)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_CollectionList_Share, 0, "mod_collection_id=" .. tostring(CollectionId))
end
function Logic_UGC_TLog:_DirectReportCollection(CollectionId, Data)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_mod_collection_report_data_req(CollectionId, Data)
end
function Logic_UGC_TLog:ReportRoomShare(RoomId)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Room_Share, 0, "room_id=" .. tostring(RoomId))
end
function Logic_UGC_TLog:ReportStay(params, from)
  local tab_id = params.tab_id or 0
  local SearchModType = params.SearchModType or ""
  local FilterTags = params.FilterTags or ""
  local requestId = params.requestId or self.curRequestId
  local OpenTime = params.OpenTime or 0
  local from = from or 0
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local stay_time = now - OpenTime
  local str = ""
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  str = string.format("tab_id=%s&SearchModType=%s&FilterTags=%s&stay_time=%s&requestId=%sfrom=%s", tostring(tab_id), tostring(SearchModType), tostring(FilterTags), tostring(stay_time), tostring(requestId), tostring(from))
  log(bWriteLog and "Logic_UGC_TLog:ReportStay str " .. tostring(str) .. "  buttonType = " .. tostring(TLogEventDefine.UGC_Rank_Stay))
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Rank_Stay, 0, str)
end
function Logic_UGC_TLog:ReportBrowsingDepth(buttonType, params)
  local tab_id = params.tab_id
  local SearchModType = params.SearchModType
  local FilterTags = params.FilterTags
  local requestId = params.requestId or self.curRequestId
  local ScreenModLine = params.ScreenModLine
  local GlidesLine = params.GlidesLine
  local str = string.format("tab_id=%s&SearchModType=%s&FilterTags=%s&ScreenModLine=%s&GlidesLine=%s", tostring(tab_id), tostring(SearchModType), tostring(FilterTags), tostring(requestId), tostring(ScreenModLine), tostring(GlidesLine))
  log(bWriteLog and "Logic_UGC_TLog:ReportBrowsingDepth str " .. tostring(str))
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(buttonType, 0, str)
end
function Logic_UGC_TLog:ReportAddFansCount(buttonType, params)
  local operate_type = params.operate_type or -1
  local author_uid = params.author_uid or 0
  local mod_id = params.mod_id or 0
  local source = params.source or 0
  local requestId = params.requestId or self.curRequestId
  local str = string.format("operate_type=%d&author_uid=%d&mod_id=%d&source=%d&requestId=%d", operate_type, author_uid, mod_id, source, requestId)
  log(bWriteLog and "Logic_UGC_TLog:ReportAddFansCount str = " .. tostring(str) .. "  buttonType = " .. tostring(buttonType))
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(buttonType, 0, str)
end
function Logic_UGC_TLog:ReportCommercialClick(params)
  local source = params.source or 0
  local requestId = params.requestId or self.curRequestId
  local str = string.format("source=%d&requestId=%d", source, requestId)
  log(bWriteLog and "Logic_UGC_TLog:ReportCommercialClick str " .. tostring(str) .. "  buttonType = " .. tostring(TLogEventDefine.UGC_Commercialization_Click))
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Commercialization_Click, 0, str)
end
function Logic_UGC_TLog:ReportAuthorHomeClick(params)
  local source = params.source or 0
  local requestId = params.requestId or self.curRequestId
  local str = string.format("source=%d&requestId=%d", source, requestId)
  log(bWriteLog and "Logic_UGC_TLog:ReportAuthorHomeClick str " .. tostring(str) .. "  buttonType = " .. tostring(TLogEventDefine.UGC_AuthorHome_Click))
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_AuthorHome_Click, 0, str)
end
function Logic_UGC_TLog:SendModTLog(ModID, ButtonType, Params)
  if not ModID then
    log(bWriteLog and "Logic_UGC_TLog:SendModTLog ModID is nil")
    return
  end
  if type(Params) ~= "table" then
    if Params ~= nil then
      log(bWriteLog and "Logic_UGC_TLog:SendModTLog Params is not a table, got " .. type(Params) .. ", ModID=" .. tostring(ModID))
    end
    Params = {}
  end
  if Params.msgChannel then
    self.LastMsgChannelVal = Params.msgChannel
  end
  local Expose = self:NewExposeTLogData(ModID, ButtonType, Params)
  local UGCNewTLogReport = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCNewTLogReport)
  if UGCNewTLogReport and UGCNewTLogReport.ExposeTLog then
    UGCNewTLogReport:ExposeTLog(Expose)
  else
    log(bWriteLog and "Logic_UGC_TLog:SendModTLog UGCNewTLogReport or ExposeTLog is nil")
  end
end
local IsDownloadPopupAction = function(action)
  if not action then
    return false
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  for _, popupAction in pairs(UGCMacros.ENU_UGC_DOWNLOAD_POPUP_ACTION) do
    if action == popupAction then
      return true
    end
  end
  return false
end
function Logic_UGC_TLog:SendInteractionTLog(InteractionType, ModID, Params)
  if type(InteractionType) ~= "number" then
    log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog InteractionType is not a number, got " .. type(InteractionType))
    return
  end
  local TableUtil = require("common.table_util")
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local UGCNewTLogReport = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCNewTLogReport)
  if InteractionType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_MATCH then
    if Params and Params.MultiModList then
      self.LastSelectCollection = Params
      return
    end
    self.LastSelectCollection = nil
    if self.Collection_id then
      self:_DirectReportCollection(self.Collection_id, {play_cnt = 1})
    end
    if not self.LastSelectModInfo then
      log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog Direct Start Match, ModID = " .. tostring(ModID))
      self:SendModTLog(ModID, TLogEventDefine.UGC_Mod_Exposure_Login, Params)
      self:SendInteractionTLog(UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SELECT, ModID, Params)
    end
    if self.LastSelectModInfo then
      if Params then
        self.LastSelectModInfo = TableUtil.MergeTable(self.LastSelectModInfo, Params)
      end
      UGCNewTLogReport:InteractionTLog(self.LastSelectModInfo, InteractionType)
    end
  elseif InteractionType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.RESULT_COLLECT or InteractionType >= UGCMacros.ENU_UGC_TLOG_REACH_TYPE.MATCH_SUCCESS and InteractionType <= UGCMacros.ENU_UGC_TLOG_REACH_TYPE.END_GAME then
    if InteractionType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.MATCH_SUCCESS and ModID and self.LastSelectCollection then
      local Expose = self:NewExposeTLogData(ModID, TLogEventDefine.UGC_Bundle_Match, Params or {})
      self.LastSelectModInfo = TableUtil.MergeTable(Expose, self.LastSelectCollection)
      UGCNewTLogReport:InteractionTLog(self.LastSelectModInfo, InteractionType, self.BattleID)
      self.LastSelectCollection = nil
    elseif self.LastSelectModInfo then
      if Params then
        self.LastSelectModInfo = TableUtil.MergeTable(self.LastSelectModInfo, Params)
      end
      UGCNewTLogReport:InteractionTLog(self.LastSelectModInfo, InteractionType, self.BattleID)
    else
      log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog InteractionType =" .. InteractionType .. ", No LastSelectModInfo")
    end
  else
    if not ModID then
      log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog InteractionType =" .. InteractionType .. ", Operation must have mod_id")
      return
    end
    Params = Params or {}
    local Expose = UGCNewTLogReport:GetExposeData(ModID, Params.page)
    if not Expose then
      log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog, No Expose, Fix One, ModId = " .. ModID .. ", Page = " .. tostring(Params.page))
      local Page = Params.page or TLogEventDefine.UGC_Mod_Exposure_Main
      self:SendModTLog(ModID, Page, Params)
      Expose = UGCNewTLogReport:GetExposeData(ModID, Page)
      if not Expose then
        log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog Error!!!! Need Expose Before, Check Please! ModId = " .. ModID)
        return
      end
    end
    local bIsDownloadPopup = InteractionType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.Download and IsDownloadPopupAction(Params.action)
    if not bIsDownloadPopup and Expose.request_id ~= self.curRequestId then
      log(bWriteLog and "Logic_UGC_TLog:SendInteractionTLog request_id not match, ModId = " .. ModID)
      return
    end
    local Interaction = TableUtil.LiteCopy(Expose)
    Interaction = TableUtil.MergeTable(Interaction, Params)
    UGCNewTLogReport:InteractionTLog(Interaction, InteractionType)
    if InteractionType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SELECT then
      self.LastSelectModInfo = Interaction
      self.LastSelectCollection = nil
    end
  end
end
function Logic_UGC_TLog:NewExposeTLogData(ModID, Scene, Params)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if not Params.tab_id then
    Params.tab_id = LogicUGC:GetSelectedTabId()
  end
  if not Params.sub_tab_id then
    Params.sub_tab_id = LogicUGC:GetSelectedSubTabId()
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local Data = logic_ugc_mode:IsModPlayedByFriend(ModID)
  if Data and Data.type ~= 6 then
    Params.CornerPlay = Data.type
    Params.CornerPlayNum = Data.display_num
  end
  Params.mod_id = ModID
  Params.page = Scene or 0
  Params.request_id = self.curRequestId
  local TimeUtil = require("client.common.time_util")
  Params.expose_id = math.floor(TimeUtil.GetMicroseconds()) * C_ExposeCounterUnit + self.ExposeCounter % C_ExposeCounterUnit
  self.ExposeCounter = self.ExposeCounter + 1
  return Params
end
local C_REASON_OFFSET = 100000
function Logic_UGC_TLog:GetUGCMatchSourceInfo(ModID)
  if not ModID then
    log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo modId is nil")
    return
  end
  if not self.LastSelectModInfo or not self.LastSelectModInfo.mod_id then
    log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo modId is nil")
    return
  end
  if self.LastSelectModInfo.mod_id ~= ModID then
    log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo select and start mod id is not match")
    return
  end
  if bWriteLog then
    log_tree("Logic_UGC_TLog:GetUGCMatchSourceInfo, LastSelectModInfo", self.LastSelectModInfo)
  end
  local ret = {
    source_type = self.LastSelectModInfo.page or 0,
    sub_source_id = -1
  }
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  if logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() or self.LastThemaDataTypeDataType == "NEWBIE" then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Newbie_Match")
    ret.source_type = TLogEventDefine.UGC_Newbie_Match
    return ret
  end
  if ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Main then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Main")
    if self.LastSelectModInfo.tab_id == Config_UGC.Config_UGC_TabID.Play or self.LastSelectModInfo.tab_id == Config_UGC.Config_UGC_TabID.Mine or self.LastSelectModInfo.tab_id == Config_UGC.Config_UGC_TabID.All then
      ret.sub_source_id = self.LastSelectModInfo.tab_id * C_REASON_OFFSET + (self.LastSelectModInfo.sub_tab_id or 0)
    elseif self.LastSelectModInfo.tab_id == Config_UGC.Config_UGC_TabID.HotTheme then
      ret.sub_source_id = self.LastSelectModInfo.theme_id
    elseif self.LastSelectModInfo.tab_id then
      ret.sub_source_id = self.LastSelectModInfo.tab_id * C_REASON_OFFSET
    end
  elseif ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Chat then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Chat")
    if self.LastMsgChannelVal ~= nil then
      print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo LastMsgChannelVal = " .. tostring(self.LastMsgChannelVal))
      ret.sub_source_id = self.LastMsgChannelVal
    end
  elseif ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Banner_ThemaItem_Work then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Banner_ThemaItem_Work")
    if self.LastThemaCollectionId ~= nil then
      ret.sub_source_id = self.LastThemaCollectionId
    end
  elseif ret.source_type >= TLogEventDefine.UGC_Hall_Mod_Exposure_Banner and ret.source_type <= TLogEventDefine.UGC_Hall_Mod_Exposure_Recommend then
    ret.sub_source_id = TLogEventDefine.UGC_Hall_Select_Mod
  elseif ret.source_type > 0 then
    ret.sub_source_id = ret.source_type
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is " .. tostring(ret.sub_source_id))
  end
  if not ret.sub_source_id then
    ret.sub_source_id = -1
  end
  log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo sub_source_id = " .. tostring(ret.sub_source_id))
  if self.LastSelectModInfo.CornerPlay then
    ret.corner_title = (self.LastSelectModInfo.CornerPlay or 0) * 1000
    if self.LastSelectModInfo.CornerPlayNum then
      ret.corner_title = ret.corner_title + (self.LastSelectModInfo.CornerPlayNum or 0)
    end
  end
  return ret
end
function Logic_UGC_TLog:SetSelectedDetailTabID(TabID)
  log(bWriteLog and "Logic_UGC_TLog:SetSelectedDetailTabID TabID " .. tostring(TabID))
  self.SelectedDetailend
function Logic_UGC_TLog:GetSelectedDetailTabID()
  return self.SelectedDetailTabID
end
function Logic_UGC_TLog:SetSelectedThemeId(ThemeId)
  log(bWriteLog and "Logic_UGC_TLog:SetSelectedThemeId ThemeId " .. tostring(ThemeId))
  self.Selectedend
function Logic_UGC_TLog:GetSelectedThemeId()
  return self.SelectedThemeId
end
function Logic_UGC_TLog:SetBattleID(BattleID)
  self.end
function Logic_UGC_TLog:NewUGCReportModTLog(buttonType, params, tlogType)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_TLog = class(CModuleBase, nil, Logic_UGC_TLog)
return CLogic_UGC_TLog