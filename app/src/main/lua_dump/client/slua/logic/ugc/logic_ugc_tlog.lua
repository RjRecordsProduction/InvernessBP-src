local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Logic_UGC_TLog = {}
function Logic_UGC_TLog:DefineAndResetData()
  self.curRequestId = 0
  self.TLogSwitch = true
  self.lastSelectModInfo = nil
  self.workTlogTimestamp = nil
  self.collectionsTlogTimestamp = nil
  self.workTlogTimestampUGCMain = nil
  self.tlogCacheShowModList = nil
  self.isShowModDeduplicationOpen = false
  self.origin_origin_workReachTlogTimestamp = nil
  self.Collection_id = nil
  self.SearchValue = nil
end
function Logic_UGC_TLog:OnInitialize()
end
function Logic_UGC_TLog:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "Logic_UGC_TLog OnPreSwitchGameStatus")
  self:ClearCacheData()
end
function Logic_UGC_TLog:OnLogOut()
  log(bWriteLog and "Logic_UGC_TLog OnLogOut")
  self:ClearCacheData()
end
function Logic_UGC_TLog:ClearCacheData()
  self.lastSelectModInfo = nil
  self.origin_workReachTlogTimestamp = nil
  self.workTlogTimestamp = nil
  self.workTlogTimestampUGCMain = nil
  self.tlogCacheShowModList = nil
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
local C_REASON_OFFSET = 100000
function Logic_UGC_TLog:GetUGCMatchSourceInfo(modId)
  if not modId then
    log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo modId is nil")
    return
  end
  if not (self.lastSelectModInfo and self.lastSelectModInfo.expose.mod_id) or self.lastSelectModInfo.expose.mod_id ~= modId then
    log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo modId is nil")
    return
  elseif bWriteLog then
    log_tree("lastSelectModInfo", self.lastSelectModInfo)
  end
  local ret = {}
  ret.source_type = self.lastSelectModInfo.buttonType
  ret.sub_source_id = -1
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  if logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() or self.LastThemaDataTypeDataType == "NEWBIE" then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Newbie_Match")
    ret.source_type = TLogEventDefine.UGC_Newbie_Match
    return ret
  end
  if ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Main then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Main")
    if self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.Play or self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.Mine then
      ret.sub_source_id = self.lastSelectModInfo.expose.sub_page * C_REASON_OFFSET + self.lastSelectModInfo.sub_tab_id
    end
    if self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.All then
      ret.sub_source_id = self.lastSelectModInfo.expose.sub_page * C_REASON_OFFSET + self.lastSelectModInfo.sub_tab_id
    end
    if self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.HotTheme and self.lastSelectModInfo.expose.tab ~= nil then
      local startIdx, endIdx = string.find(self.lastSelectModInfo.expose.tab, "theme_id=(%d+)")
      if startIdx and endIdx then
        local themeIdStr = string.sub(self.lastSelectModInfo.expose.tab, startIdx + 9, endIdx)
        ret.sub_source_id = tonumber(themeIdStr) or -1
      end
    end
    if self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.Random or self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.NewNewMap then
      ret.sub_source_id = self.lastSelectModInfo.expose.sub_page * C_REASON_OFFSET
    end
    if self.lastSelectModInfo.expose.sub_page == Config_UGC.Config_UGC_TabID.Tournament then
      ret.sub_source_id = self.lastSelectModInfo.expose.sub_page * C_REASON_OFFSET
    end
  end
  if ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Chat then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Chat")
    if self.lastMsgChannelVal ~= nil then
      print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo lastMsgChannelVal = " .. tostring(self.lastMsgChannelVal))
      ret.sub_source_id = self.lastMsgChannelVal
    end
  end
  if ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Banner_ThemaItem_Work then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Banner_ThemaItem_Work")
    if self.LastThemaCollectionId ~= nil then
      ret.sub_source_id = self.LastThemaCollectionId
    end
  end
  if ret.source_type == TLogEventDefine.UGC_Mod_Exposure_Moment then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Mod_Exposure_Moment")
  end
  if ret.source_type == TLogEventDefine.UGC_Personal_Masterstate_Creative_Center then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Personal_Masterstate_Creative_Center")
    ret.sub_source_id = TLogEventDefine.UGC_Personal_Masterstate_Creative_Center
  end
  if ret.source_type == TLogEventDefine.UGC_Personal_Behavior_Creative_Center then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Personal_Behavior_Creative_Center")
    ret.sub_source_id = TLogEventDefine.UGC_Personal_Behavior_Creative_Center
  end
  if ret.source_type == TLogEventDefine.UGC_Personal_AuthorHomePage then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Personal_AuthorHomePage")
    ret.sub_source_id = TLogEventDefine.UGC_Personal_AuthorHomePage
  end
  if ret.source_type == TLogEventDefine.UGC_Personal_AuthorHomePage_Guest then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Personal_AuthorHomePage_Guest")
    ret.sub_source_id = TLogEventDefine.UGC_Personal_AuthorHomePage_Guest
  end
  if ret.source_type == TLogEventDefine.UGC_Personal_PlayData_Played then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Personal_PlayData_Played")
    ret.sub_source_id = TLogEventDefine.UGC_Personal_PlayData_Played
  end
  if ret.source_type == TLogEventDefine.UGC_Personal_PlayData_Collect then
    print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo source_type is TLogEventDefine.UGC_Personal_PlayData_Collect")
    ret.sub_source_id = TLogEventDefine.UGC_Personal_PlayData_Collect
  end
  if ret.sub_source_id == nil then
    ret.sub_source_id = -1
  end
  if self.lastSelectModInfo.expose.str_value ~= nil then
    local cornerTitleVal = string.match(self.lastSelectModInfo.expose.str_value, "cornerplay=([^&]+)")
    if cornerTitleVal ~= nil then
      print(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo cornerTitle = " .. tostring(cornerTitleVal))
      local cornerTitleParts = {}
      for part in string.gmatch(cornerTitleVal, "[^_]+") do
        table.insert(cornerTitleParts, part)
      end
      if 1 <= #cornerTitleParts then
        ret.corner_title = tonumber(cornerTitleParts[1]) * 1000
      end
      if 2 <= #cornerTitleParts then
        ret.corner_title = ret.corner_title + tonumber(cornerTitleParts[2])
      end
    end
  end
  log(bWriteLog and "Logic_UGC_TLog:GetUGCMatchSourceInfo sub_source_id = " .. tostring(ret.sub_source_id))
  return ret
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
function Logic_UGC_TLog:RealReportModReachTlog(mod_id, buttonType, params)
  if not buttonType then
    log(bWriteLog and "Logic_UGC_TLog:RealReportModReachTlog no buttonType")
    return
  end
  if not self:CheckCanReportModTLog(mod_id, buttonType, params) then
    return
  end
  local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
  local mod_collection_id = LogicUGCCollectionList:GetOpenCollection() or params.mod_collection_id
  local tab_id = params.tab_id
  local sub_tab_id = params.sub_tab_id or 0
  local tlog_type = params.tlog_type
  local   local extendedStr = params.extendedStr
  local requestId = params.requestId or self.curRequestId
  local str = string.format("sub_tab_id=%s&mod_id=%s&tlog_type=%s&requestId=%s", tostring(sub_tab_id), tostring(mod_id), tostring(tlog_type), tostring(requestId))
  if extendedStr and extendedStr ~= "" then
    str = str .. "&" .. extendedStr
  end
  if mod_collection_id then
    str = str .. "&mod_collection_id=" .. tostring(mod_collection_id)
  end
  local prefix = "msgChannel"
  if params.extendedStr and string.sub(params.extendedStr, 1, string.len(prefix)) == prefix then
    self.lastMsgChannelVal = tonumber(string.sub(params.extendedStr, string.len(prefix) + 2))
    print(bWriteLog and "msgChannel = " .. tostring(self.msgChannelValue))
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if tlog_type == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SELECT then
    self.lastSelectModInfo = {
      modId = mod_id,
      requestId = requestId,
      button_type = buttonType,
      tab_id = tab_id,
      sub_tab_id = sub_tab_id or 0,
      extendedStr = extendedStr,
          }
    print(bWriteLog and mod_collection_id and "LogicUGCTLog Select mod_collection_id = " .. tostring(mod_collection_id))
  end
  log(bWriteLog and "Logic_UGC_TLog:RealReportModReachTlog buttonType = " .. tostring(buttonType) .. " mod_id = " .. tostring(mod_id) .. " reason_str = " .. str .. "tab_id = " .. tostring(tab_id))
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(buttonType, tab_id, str)
end
function Logic_UGC_TLog:CheckCanReportModTLog(mod_id, buttonType, params)
  if not self.TLogSwitch then
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportModTLog switch is not open")
    return
  end
  local tlog_type = params and params.tlog_type or nil
  if not (buttonType and tlog_type) or not mod_id then
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportModTLog buttonType or tlog_type or not mod_id is nil")
    return
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if self.isShowModDeduplicationOpen and tlog_type == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SHOW_MOD then
    self.tlogCacheShowModList = self.tlogCacheShowModList or {}
    if self.tlogCacheShowModList[mod_id] then
      return
    else
      self.tlogCacheShowModList[mod_id] = 1
    end
  end
  if self:CheckIsUGCMainTLog(buttonType) then
    return self:CheckCanReportModUGCMain(mod_id, params)
  end
  local bRet = true
  self.workTlogTimestamp = self.workTlogTimestamp or {}
  self.workTlogTimestamp[buttonType] = self.workTlogTimestamp[buttonType] or {}
  self.workTlogTimestamp[buttonType][mod_id] = self.workTlogTimestamp[buttonType][mod_id] or {}
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local TimeUtil = require("client.common.time_util")
  local cur_time = TimeUtil.GetServerTimeInSec()
  local cache_time = self.workTlogTimestamp[buttonType][mod_id][tlog_type]
  log(bWriteLog and string.format("Logic_UGC_TLog:CheckCanReportModTLog mod_id[%s] tlog_type[%s] cur_time[%s] cache_time[%s]", tostring(mod_id), tostring(tlog_type), tostring(cur_time), tostring(cache_time)))
  if not cache_time then
    self.workTlogTimestamp[buttonType][mod_id][tlog_type] = cur_time
    bRet = true
  elseif UGCMacros.TLOL_REACH_CD < cur_time - cache_time then
    self.workTlogTimestamp[buttonType][mod_id][tlog_type] = cur_time
    bRet = true
  else
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportModTLog cd \226\128\166\226\128\166")
    bRet = false
  end
  return bRet
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
function Logic_UGC_TLog:CheckCanReportModUGCMain(mod_id, params)
  if not self.TLogSwitch then
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportModUGCMain switch is not open")
    return
  end
  local tab_id = params and params.tab_id or nil
  local sub_tab_id = params and params.sub_tab_id or 0
  local tlog_type = params and params.tlog_type or nil
  if not (tab_id and tlog_type) or not mod_id then
    log(bWriteLog and string.format("Logic_UGC_TLog:CheckCanReportModUGCMain params invalid tab_id[%s] tlog_type[%s] mod_id[%s]", tostring(tab_id), tostring(tlog_type), tostring(mod_id)))
    return false
  end
  local bRet = true
  self.workTlogTimestampUGCMain = self.workTlogTimestampUGCMain or {}
  self.workTlogTimestampUGCMain[tab_id] = self.workTlogTimestampUGCMain[tab_id] or {}
  self.workTlogTimestampUGCMain[tab_id][mod_id] = self.workTlogTimestampUGCMain[tab_id][mod_id] or {}
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local TimeUtil = require("client.common.time_util")
  local cur_time = TimeUtil.GetServerTimeInSec()
  local cache_time = self.workTlogTimestampUGCMain[tab_id][mod_id][tlog_type]
  log(bWriteLog and string.format("Logic_UGC_TLog:CheckCanReportModUGCMain tab_id[%s] sub_tab_id[%s] mod_id[%s] tlog_type[%s] cur_time[%s] cache_time[%s]", tostring(tab_id), tostring(sub_tab_id), tostring(mod_id), tostring(tlog_type), tostring(cur_time), tostring(cache_time)))
  if not cache_time then
    self.workTlogTimestampUGCMain[tab_id][mod_id][tlog_type] = cur_time
    bRet = true
  elseif UGCMacros.TLOL_REACH_CD < cur_time - cache_time then
    self.workTlogTimestampUGCMain[tab_id][mod_id][tlog_type] = cur_time
    bRet = true
  else
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportModUGCMain cd \226\128\166\226\128\166")
    bRet = false
  end
  return bRet
end
function Logic_UGC_TLog:CheckIsUGCMainTLog(buttonType)
  return buttonType and buttonType == TLogEventDefine.UGC_Mod_Exposure_Main
end
function Logic_UGC_TLog:CheckCanReportWorkReach(mod_id, params)
  local tab_id = params and params.tab_id or nil
  local sub_tab_id = params and params.sub_tab_id or 0
  local tlog_type = params and params.tlog_type or nil
  local   if not (tab_id and tlog_type) or not mod_id then
    log(bWriteLog and string.format("Logic_UGC_TLog:CheckCanReportWorkReach params invalid tab_id[%s] tlog_type[%s] mod_id[%s]", tostring(tab_id), tostring(tlog_type), tostring(mod_id)))
    return false
  end
  local bRet = true
  if not self.origin_workReachTlogTimestamp then
    self.origin_workReachTlogTimestamp = {}
  end
  if not self.origin_workReachTlogTimestamp[tab_id] then
    self.origin_workReachTlogTimestamp[tab_id] = {}
  end
  if not self.origin_workReachTlogTimestamp[tab_id][mod_id] then
    self.origin_workReachTlogTimestamp[tab_id][mod_id] = {}
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local TimeUtil = require("client.common.time_util")
  local cur_time = TimeUtil.GetServerTimeInSec()
  local cache_time = self.origin_workReachTlogTimestamp[tab_id][mod_id][tlog_type]
  log(bWriteLog and string.format("Logic_UGC_TLog:CheckCanReportWorkReach tab_id[%s] sub_tab_id[%s] mod_id[%s] tlog_type[%s] cur_time[%s] cache_time[%s]", tostring(tab_id), tostring(sub_tab_id), tostring(mod_id), tostring(tlog_type), tostring(cur_time), tostring(cache_time)))
  if not cache_time then
    self.origin_workReachTlogTimestamp[tab_id][mod_id][tlog_type] = cur_time
    bRet = true
  elseif UGCMacros.TLOL_REACH_CD < cur_time - cache_time then
    self.origin_workReachTlogTimestamp[tab_id][mod_id][tlog_type] = cur_time
    bRet = true
  else
    log(bWriteLog and "Logic_UGC_TLog:CheckCanReportWorkReach cd \226\128\166\226\128\166")
    bRet = false
  end
  return bRet
end
function Logic_UGC_TLog:ReportInGameResultTlog(mod_id, params)
  log_tree("Logic_UGC_TLog:ReportInGameResultTlog", params)
  local tab_id = params.tab_id
  local sub_tab_id = params.sub_tab_id or 0
  local tlog_type = params.tlog_type
  local requestId = params.requestId or self.curRequestId
  local extendedStr = params.extendedStr
  local   local str = string.format("sub_tab_id=%s&mod_id=%s&tlog_type=%s&requestId=%s", tostring(sub_tab_id), tostring(mod_id), tostring(tlog_type), tostring(requestId))
  if extendedStr and extendedStr ~= "" then
    str = str .. "&" .. extendedStr
  end
  log(bWriteLog and "Logic_UGC_TLog:ReportWorkReachTlog mod_id = " .. tostring(mod_id) .. " reason_str = " .. str)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  self:SendModTLog(mod_id, TLogEventDefine.UGC_Mod_Exposure_Result_Recommend, params.tlog_type)
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
function Logic_UGC_TLog:SendModTLog(modId, buttonType, tlogType, params, tabId, subTabId)
  if not modId or not buttonType then
    log(bWriteLog and "Logic_UGC_TLog:SendModTLog modId is nil")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  tabId = tabId or LogicUGC:GetSelectedTabId()
  subTabId = subTabId or LogicUGC:GetSelectedSubTabId()
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local Data = logic_ugc_mode:IsModPlayedByFriend(modId)
  if Data.type == 6 then
    Data = nil
  end
  local detailTabId = LogicUGC:GetSelectedDetailTabID()
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local tlogParams = {
    mod_id = modId,
    tab_id = tabId,
    sub_tab_id = subTabId or 0,
    theme_id = params and params.theme_id or nil,
    position = params and params.position or nil,
    filtertag = params and params.filtertag or nil,
    subfiltertag = params and params.subfiltertag or nil,
    cornerplay = Data and Data.type or nil,
    detailTabId = detailTabId,
    Carousel = params and params.Carousel or nil,
    HotRankType = params and params.HotRankType or nil,
    bPromotion = params and params.bPromotion or nil,
    msgChannel = params and params.msgChannel or nil,
    DownloadType = params and params.DownloadType or nil,
    DownloadState = params and params.DownloadState or nil,
    TraceId = params and params.TraceId or nil,
    SearchValue = params and params.SearchValue or nil,
    DownloadResSize = params and params.DownloadResSize or nil
  }
  log(bWriteLog and "Logic_UGC_TLog:SendModTLog modid = " .. modId .. " buttonType = " .. buttonType .. " tlogType = " .. tlogType)
  self:NewUGCReportModTLog(buttonType, tlogParams, tlogType)
end
function Logic_UGC_TLog:SendStartGameTLog(modId)
  if not modId then
    log(bWriteLog and "Logic_UGC_TLog:SendStartGameTLog modId is nil")
    return
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if self.Collection_id then
    self:_DirectReportCollection(self.Collection_id, {play_cnt = 1})
  end
  local params = {}
  params.mod_id = modId
  self:NewUGCReportModTLog(nil, params, UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_GAME)
end
function Logic_UGC_TLog:SetParamsTabStr(params)
  local UGCNewTLogReport = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCNewTLogReport)
  local str = ""
  local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
  local mod_collection_id = LogicUGCCollectionList:GetOpenCollection() or params.mod_collection_id
  if params.sub_tab_id then
    str = str .. UGCNewTLogReport.TabStr.sub_tab_id .. tostring(params.sub_tab_id)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue sub_tab_id = " .. params.sub_tab_id)
  end
  if mod_collection_id then
    str = str .. "&" .. UGCNewTLogReport.TabStr.mod_collection_id .. tostring(mod_collection_id)
    self.Collection_id = mod_collection_id
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue Collection_id = " .. mod_collection_id)
  end
  if params.theme_id then
    str = str .. "&" .. UGCNewTLogReport.TabStr.theme_id .. tostring(params.theme_id)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue theme_id = " .. params.theme_id)
  end
  if params.filtertag then
    str = str .. "&" .. UGCNewTLogReport.TabStr.filtertag .. tostring(params.filtertag)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue filtertag = " .. params.filtertag)
  end
  if params.subfiltertag then
    str = str .. "&" .. UGCNewTLogReport.TabStr.subfiltertag .. tostring(params.subfiltertag)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue subfiltertag = " .. params.subfiltertag)
  end
  return str
end
function Logic_UGC_TLog:SetParamsStrValue(params)
  local UGCNewTLogReport = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCNewTLogReport)
  local str = ""
  if params.cornerplay then
    str = str .. UGCNewTLogReport.StrValue.cornerplay .. params.cornerplay
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue cornerplay = " .. params.cornerplay)
  end
  if params.Carousel then
    str = str .. "&" .. UGCNewTLogReport.StrValue.Carousel .. params.Carousel
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue Carousel = " .. params.Carousel)
  end
  if params.HotRankType then
    str = str .. "&" .. UGCNewTLogReport.StrValue.HotRankType .. tostring(params.HotRankType)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue HotRankType = " .. params.HotRankType)
  end
  if params.detailTabId then
    str = str .. "&" .. UGCNewTLogReport.StrValue.detailTabId .. tostring(params.detailTabId)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue detailTabId = " .. params.detailTabId)
  end
  if params.bPromotion then
    str = str .. "&" .. UGCNewTLogReport.StrValue.bPromotion .. tostring(params.bPromotion)
    log(bWriteLog and "Logic_UGC_TLog:SetParamsStrValue bPromotion = " .. params.bPromotion)
  end
  if params.DownloadType then
    str = str .. "&" .. UGCNewTLogReport.StrValue.DownloadType .. tostring(params.DownloadType)
  end
  if params.DownloadState then
    str = str .. "&" .. UGCNewTLogReport.StrValue.DownloadState .. tostring(params.DownloadState)
  end
  if params.TraceId then
    str = str .. "&" .. UGCNewTLogReport.StrValue.TraceId .. tostring(params.TraceId)
  end
  if params.DownloadResSize then
    str = str .. "&" .. UGCNewTLogReport.StrValue.DownloadResSize .. tostring(params.DownloadResSize)
  end
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  if logic_ugc_hall:CheckIsOpen() then
    local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local curPage = lobbyMainLogic.curPage
    if curPage == ENUM_LobbyPageType.Right then
      str = str .. "&" .. UGCNewTLogReport.StrValue.UgcHall
    end
  end
  return str
end
function Logic_UGC_TLog:NewUGCReportModTLog(buttonType, params, tlogType)
  if not tlogType then
    log(bWriteLog and "Logic_UGC_TLog:NewUGCReportModTLog tlogType is nil")
  end
  local UGCNewTLogReport = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCNewTLogReport)
  local expose = {}
  expose.mod_id = params.mod_id
  expose.sub_page = params.tab_id or nil
  expose.position = params.position
  expose.tab = self:SetParamsTabStr(params)
  expose.page = buttonType or 0
  expose.request_id = self.curRequestId
  expose.value = params.SearchValue
  expose.str_value = self:SetParamsStrValue(params)
  log(bWriteLog and "Logic_UGC_TLog:NewUGCReportModTLog buttonType = " .. tostring(expose.page) .. " mod_id = " .. tostring(params.mod_id) .. " tlogType = " .. tostring(tlogType) .. " position = " .. tostring(params.position) .. "request_id = " .. tostring(expose.request_id))
  log(bWriteLog and "Logic_UGC_TLog:NewUGCReportModTLog tab = " .. tostring(expose.tab) .. " str_value = " .. tostring(expose.str_value))
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if tlogType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SELECT then
    self.lastSelectModInfo = {
      expose = expose,
      buttonType = buttonType,
      sub_tab_id = params.sub_tab_id
    }
  end
  if params.msgChannel then
    self.lastMsgChannelVal = params.msgChannel
  end
  if tlogType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_GAME then
    if not self.lastSelectModInfo or not self.lastSelectModInfo.expose then
      log(bWriteLog and "ogic_UGC_TLog:NewUGCReportModTLog not lastSelectModInfo")
      return
    end
    self.lastSelectModInfo.expose.str_value = self.lastSelectModInfo.expose.str_value .. expose.str_value
    UGCNewTLogReport:TLogReport(self.lastSelectModInfo.buttonType, self.lastSelectModInfo.expose, tlogType)
  else
    UGCNewTLogReport:TLogReport(buttonType, expose, tlogType)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_TLog = class(CModuleBase, nil, Logic_UGC_TLog)
return CLogic_UGC_TLog