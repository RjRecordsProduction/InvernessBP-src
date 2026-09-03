local logic_unknowpass_activity_collection = {
  page_info = nil,
  player_save_data = nil,
  permanent_act_data = nil
}
local NEW_ACT_DAY = 2
local is_inited_player_save_data = false
local is_inited_permanent_act_data = false
local is_skip_guide = false
local PASS_INNER_MODULE_ID = {
  BP_ENUM_MODULE_UNKNOW_PASS
}
local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
function logic_unknowpass_activity_collection.InitData()
  logic_unknowpass_activity_collection.ReqGetCollectionPageInfo()
end
function logic_unknowpass_activity_collection.CheckSwitchIsOpen()
  local is_open = LobbySystem.CheckOpen(BP_ENUM_UNKNOWPASS_ACTIVITY_COLLECTION_ID)
  log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection CheckSwitchIsOpen= " .. tostring(is_open))
  return is_open
end
local IsVersionMatch = function(act_info)
  local min_version = act_info.min_cli_ver or ""
  local current_version = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  if min_version ~= "" and version_util.LowerVersion(current_version, min_version) then
    log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection IsVersionMatch false id = " .. tostring(act_info.id))
    return false
  end
  return true
end
function logic_unknowpass_activity_collection.CheckIsNeedShowNewBieGuide(step)
  if is_skip_guide then
    return false
  end
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return false
  end
  local version_util = require("client.common.version_util")
  if step == UnknowPassMacro.Enum_Activity_Collection_Step.PassMainEntrance and not version_util.IsMatchVersion(UnknowPassMacro.Activity_Collection_NewBie_Guide_Version) then
    log(bWriteLog and "[v_wllwu]CheckIsNeedShowNewBieGuide, IsMatchVersion is false")
    return false
  end
  local save_data = logic_unknowpass_activity_collection:GetActEntraceGuideInfo()
  if save_data and save_data[step] then
    return false
  end
  return true
end
local _IsRPExtraScoreShow = function(tActInfo)
  if tActInfo.act_type == BP_ENUM_MODULE_UNKNOW_PASS_EXTRASCORE and (UnknowPassSystem.Level < UnknowPassSystem.MaxLevel or not UnknowPassSystem.IsBuyElite) then
    return false
  end
  return true
end
local IsActOpen = function(act_info)
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  if now_time >= act_info.end_time then
    return false
  end
  if act_info.act_type == BP_ENUM_MODULE_UNKNOW_PASS_EXTRASCORE and not _IsRPExtraScoreShow(act_info) then
    return false
  end
  if now_time >= act_info.open_time or now_time >= act_info.pre_open_time then
    return true
  end
  return false
end
function logic_unknowpass_activity_collection.CanOpenActUI(act_data)
  if not act_data then
    log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection CanOpenActUI act_data is nil")
    return false
  end
  local open_state = logic_unknowpass_activity_collection.GetActOpenState(act_data)
  if open_state ~= UnknowPassMacro.Enum_Activity_Open_State.InProgress then
    log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection CanOpenActUI act not open")
    if open_state == UnknowPassMacro.Enum_Activity_Open_State.NotStart then
      ShowNotice(7809)
    else
      ShowNotice(4002)
    end
    return false
  end
  return true
end
function logic_unknowpass_activity_collection.GetActOpenState(act_info)
  if not act_info then
    log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection GetActOpenState act_info is nil")
    return
  end
  local start_time = act_info.open_time or 0
  local end_time = act_info.end_time or 0
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  if start_time > now_time then
    return UnknowPassMacro.Enum_Activity_Open_State.NotStart
  elseif end_time <= now_time then
    return UnknowPassMacro.Enum_Activity_Open_State.End
  end
  return UnknowPassMacro.Enum_Activity_Open_State.InProgress
end
function logic_unknowpass_activity_collection.IsNeedShowTimeTips(act_info)
  if not act_info then
    log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection IsNeedShowTimeTips act_info is nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  local pre_open_time = act_info.pre_open_time or 0
  local pre_end_time = act_info.pre_end_time or 0
  local open_time = act_info.open_time or 0
  local end_time = act_info.end_time or 0
  if now_time >= pre_open_time and now_time < open_time then
    return true
  end
  if now_time >= open_time and now_time < end_time and now_time >= pre_end_time then
    return true
  end
  return false
end
local LocalSortFunc = function(a, b)
  if a.open_time == b.open_time then
    if a.end_time == b.end_time then
      return a.order > b.order
    else
      return a.end_time < b.end_time
    end
  else
    return a.open_time < b.open_time
  end
end
function logic_unknowpass_activity_collection.GetActListData()
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return
  end
  if not logic_unknowpass_activity_collection.page_info then
    return
  end
  local act_list = {}
  for _, v in pairs(logic_unknowpass_activity_collection.page_info) do
    if IsVersionMatch(v) and IsActOpen(v) then
      table.insert(act_list, v)
    end
  end
  if #act_list <= 1 then
    return act_list
  end
  table.sort(act_list, LocalSortFunc)
  return act_list
end
function logic_unknowpass_activity_collection.GetNewActId()
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return
  end
  if not logic_unknowpass_activity_collection.page_info then
    log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection page_info is nil")
    return
  end
  local new_act = {}
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(logic_unknowpass_activity_collection.page_info) do
    if v.act_type == BP_ENUM_MODULE_UNKNOW_PASS_EXTRASCORE and (UnknowPassSystem.Level < UnknowPassSystem.MaxLevel or not UnknowPassSystem.IsBuyElite) then
    elseif IsVersionMatch(v) then
      local open_time = v.open_time or 0
      local dur_time = now_time - open_time
      log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection dur_time = " .. dur_time)
      if 0 < dur_time and dur_time < NEW_ACT_DAY * 86400 then
        table.insert(new_act, v)
      end
    end
  end
  local len = #new_act
  if len <= 0 then
    return nil
  end
  if 1 < len then
    table.sort(new_act, LocalSortFunc)
  end
  return new_act[1].id
end
function logic_unknowpass_activity_collection.CanShowLobbyBubbleTips(act_id)
  log(bWriteLog and "[v_wllwu]  CanShowLobbyBubbleTips")
  if not act_id then
    log(bWriteLog and "[v_wllwu]  CanShowLobbyBubbleTips act_id is nil!")
    return false
  end
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return false
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() ~= ENUM_DownloadState.Done then
    log(bWriteLog and "[v_wllwu]  CanShowLobbyBubbleTips GetRpResourceDownloadState false")
    return false
  end
  local enter_type = UnknowPassMacro.Enum_ActCollect_BubbleEnter_Define.Lobby
  local save_data = logic_unknowpass_activity_collection.GetBubbleShowInfo(enter_type)
  return logic_unknowpass_activity_collection.CanShowBubbleTipsBySaveData(save_data, act_id)
end
function logic_unknowpass_activity_collection.CanShowBtnActEnterBubbleTips(act_id)
  log(bWriteLog and "[v_wllwu]  CanShowBtnActEnterBubbleTips")
  if not act_id then
    log(bWriteLog and "[v_wllwu]  CanShowBtnActEnterBubbleTips act_id is nil!")
    return false
  end
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return false
  end
  local enter_type = UnknowPassMacro.Enum_ActCollect_BubbleEnter_Define.PassMain
  local save_data = logic_unknowpass_activity_collection.GetBubbleShowInfo(enter_type)
  return logic_unknowpass_activity_collection.CanShowBubbleTipsBySaveData(save_data, act_id)
end
function logic_unknowpass_activity_collection.CanShowBubbleTipsBySaveData(save_data, act_id)
  if not save_data then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local last_time = save_data.show_time or 0
  local now_time = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(now_time, last_time) then
    log(bWriteLog and "[v_wllwu]  CanShowBubbleTipsBySaveData IsSameDay false")
    return false
  end
  if not act_id then
    log(bWriteLog and "[v_wllwu]  CanShowBubbleTipsBySaveData GetNewActId false")
    return false
  end
  if save_data.show_act_list and save_data.show_act_list[act_id] then
    log(bWriteLog and "[v_wllwu]  CanShowBubbleTipsBySaveData show_act_list false")
    return false
  end
  log(bWriteLog and "[v_wllwu]  CanShowBubbleTipsBySaveData true")
  return true
end
function logic_unknowpass_activity_collection.GetInProgressActList()
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return
  end
  if not logic_unknowpass_activity_collection.page_info then
    return
  end
  local act_list = {}
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(logic_unknowpass_activity_collection.page_info) do
    if IsVersionMatch(v) and _IsRPExtraScoreShow(v) and now_time >= v.open_time and now_time < v.end_time then
      table.insert(act_list, v)
    end
  end
  if 1 < #act_list then
    table.sort(act_list, LocalSortFunc)
  end
  return act_list
end
function logic_unknowpass_activity_collection.GetActInfoByID(act_id)
  if not act_id then
    return
  end
  local act_data = logic_unknowpass_activity_collection.page_info or {}
  for _, v in pairs(act_data) do
    if v.id == act_id then
      return v
    end
  end
  return nil
end
function logic_unknowpass_activity_collection.IsKoiOpen()
  local act_date = logic_unknowpass_activity_collection.page_info or {}
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(act_date) do
    if v.act_name == 27691 and now > v.open_time and now < v.end_time then
      return true
    end
  end
  return false
end
function logic_unknowpass_activity_collection.GetPermanentActInfo()
  if not logic_unknowpass_activity_collection.CheckSwitchIsOpen() then
    return
  end
  if not logic_unknowpass_activity_collection.page_info then
    log(bWriteLog and "[v_wllwu] GetPermanentActInfo logic_unknowpass_activity_collection.page_info is nil")
    return
  end
  local act_id = logic_unknowpass_activity_collection.GetLocalPermanentActID()
  local act_info = logic_unknowpass_activity_collection.GetActInfoByID(act_id)
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  if act_info ~= nil and now_time >= act_info.open_time and now_time < act_info.end_time then
    return act_info
  end
  local act_list = logic_unknowpass_activity_collection.GetInProgressActList() or {}
  if 0 < #act_list then
    act_id = act_list[1].id
    act_info = logic_unknowpass_activity_collection.GetActInfoByID(act_id)
    return act_info
  end
  log(bWriteLog and "[v_wllwu] GetPermanentActInfo info is nil")
  return nil
end
function logic_unknowpass_activity_collection.GetStrByLocalizeId(id, param)
  return LocUtil.LocalizeResFormat(id, param or "")
end
function logic_unknowpass_activity_collection.ReportTLog(reason_str, activity_id)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TLogReasonTable = {
    event_name = "UnknowPass_Activity_Collection_Report",
    entrance = reason_str
  }
  if activity_id then
    TLogReasonTable.  end
  local TLogReasonStr = json.encode(TLogReasonTable)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.UnknowPass_Activity_Collection_Report, 0, TLogReasonStr)
  log(bWriteLog and "TLog new format, logic_unknowpass_activity_collection.ReportTLog, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
end
function logic_unknowpass_activity_collection.InitLocalSaveData()
  if is_inited_player_save_data then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassActCollect) or {}
  logic_unknowpass_activity_collection.player_save_data = cfg
  is_inited_player_save_data = true
end
function logic_unknowpass_activity_collection.GetBubbleShowInfo(enter_type)
  logic_unknowpass_activity_collection.InitLocalSaveData()
  local data = logic_unknowpass_activity_collection.player_save_data
  if data ~= nil and data.bubble_data then
    return data.bubble_data[enter_type]
  end
  return nil
end
function logic_unknowpass_activity_collection.SaveBubbleShowInfo(enter_type, act_id)
  if not logic_unknowpass_activity_collection.player_save_data then
    logic_unknowpass_activity_collection.player_save_data = {}
  end
  if not logic_unknowpass_activity_collection.player_save_data.bubble_data then
    logic_unknowpass_activity_collection.player_save_data.bubble_data = {}
  end
  if not logic_unknowpass_activity_collection.player_save_data.bubble_data[enter_type] then
    logic_unknowpass_activity_collection.player_save_data.bubble_data[enter_type] = {}
  end
  local TimeUtil = require("client.common.time_util")
  logic_unknowpass_activity_collection.player_save_data.bubble_data[enter_type].show_time = TimeUtil.GetServerTimeInSec()
  if not logic_unknowpass_activity_collection.player_save_data.bubble_data[enter_type].show_act_list then
    logic_unknowpass_activity_collection.player_save_data.bubble_data[enter_type].show_act_list = {}
  end
  logic_unknowpass_activity_collection.player_save_data.bubble_data[enter_type].show_act_list[act_id] = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_unknowpass_activity_collection.player_save_data, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassActCollect)
end
function logic_unknowpass_activity_collection.GetLocalPermanentActID()
  if not is_inited_permanent_act_data then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassPermanentEnter) or {}
    logic_unknowpass_activity_collection.permanent_act_data = cfg
    is_inited_permanent_act_data = true
  end
  if logic_unknowpass_activity_collection.permanent_act_data ~= nil then
    return logic_unknowpass_activity_collection.permanent_act_data.act_id
  end
  return nil
end
function logic_unknowpass_activity_collection.SetLocalPermanentActID(act_id)
  if not logic_unknowpass_activity_collection.permanent_act_data then
    logic_unknowpass_activity_collection.permanent_act_data = {}
  end
  logic_unknowpass_activity_collection.permanent_act_data.  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_unknowpass_activity_collection.permanent_act_data, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassPermanentEnter)
end
function logic_unknowpass_activity_collection.GetActEntraceGuideInfo()
  logic_unknowpass_activity_collection.InitLocalSaveData()
  local data = logic_unknowpass_activity_collection.player_save_data
  if data ~= nil and data.newbie_data then
    return data.newbie_data
  end
  return nil
end
function logic_unknowpass_activity_collection.SaveActEntraceGuideInfo(step)
  if not logic_unknowpass_activity_collection.player_save_data then
    logic_unknowpass_activity_collection.player_save_data = {}
  end
  if not logic_unknowpass_activity_collection.player_save_data.newbie_data then
    logic_unknowpass_activity_collection.player_save_data.newbie_data = {}
  end
  logic_unknowpass_activity_collection.player_save_data.newbie_data[step] = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_unknowpass_activity_collection.player_save_data, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassActCollect)
end
function logic_unknowpass_activity_collection.GMClearBubbleData()
  logic_unknowpass_activity_collection.InitLocalSaveData()
  logic_unknowpass_activity_collection.InitLocalSaveData()
  if not logic_unknowpass_activity_collection.player_save_data then
    return
  end
  logic_unknowpass_activity_collection.player_save_data.bubble_data = nil
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_unknowpass_activity_collection.player_save_data, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassActCollect)
end
function logic_unknowpass_activity_collection.GMClearNewBieData()
  logic_unknowpass_activity_collection.InitLocalSaveData()
  if not logic_unknowpass_activity_collection.player_save_data then
    return
  end
  logic_unknowpass_activity_collection.player_save_data.newbie_data = nil
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_unknowpass_activity_collection.player_save_data, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassActCollect)
end
function logic_unknowpass_activity_collection.GMSetSkipNewBieGuide(is_skip)
  is_skip_guide = is_skip
end
function logic_unknowpass_activity_collection.GMGetSkipNewBieGuide()
  return is_skip_guide
end
function logic_unknowpass_activity_collection.GMClearPermentActData()
  logic_unknowpass_activity_collection.SetLocalPermanentActID()
end
function logic_unknowpass_activity_collection.ReqGetCollectionPageInfo()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_get_abstract_page_req()
end
function logic_unknowpass_activity_collection.OnGetCollectionPageInfoRsp(page_info)
  if not page_info then
    return
  end
  logic_unknowpass_activity_collection.  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_ACT_COLLECTION_PAGEINFO)
end
function logic_unknowpass_activity_collection.IsNeedAddJumpChain(url)
  log(bWriteLog and "[v_wllwu] logic_unknowpass_activity_collection.IsNeedAddJumpChain: url = " .. tostring(url))
  if url == nil or url == "" then
    return false
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local module_id = tonumber(params.module)
  local TableUtil = require("common.table_util")
  return TableUtil.Find(PASS_INNER_MODULE_ID, module_id) < 0
end
function logic_unknowpass_activity_collection.JumpToOtherModule(url)
  GlobalData.JumpUrl(url)
end
function logic_unknowpass_activity_collection.ClearJumpChain()
  log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection ClearJumpChain")
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_activity_collection_page)
end
local Tab_Rank = 8
function logic_unknowpass_activity_collection.IsPassRankJumpUrl(url)
  log(bWriteLog and "[v_wllwu]  logic_unknowpass_activity_collection.JumpToActUrl is " .. tostring(url))
  if not url or url == "" then
    return
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsGameJumpUrl(url) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(url)
    local module_id = tonumber(params.module)
    local tab_id = tonumber(params.Tab1)
    if module_id == BP_ENUM_MODULE_UNKNOW_PASS and tab_id == Tab_Rank then
      return true
    end
  end
  return false
end
function logic_unknowpass_activity_collection.OnModePostSwitch(preState, nextState)
  if GameStatus.IsInLobbyOrMainCity() then
    logic_unknowpass_activity_collection.InitData()
  else
    logic_unknowpass_activity_collection.ResetData()
  end
end
function logic_unknowpass_activity_collection.ResetData()
  is_inited_player_save_data = false
  is_inited_permanent_act_data = false
  is_skip_guide = false
  logic_unknowpass_activity_collection.page_info = nil
  logic_unknowpass_activity_collection.player_save_data = nil
  logic_unknowpass_activity_collection.permanent_act_data = nil
end
return logic_unknowpass_activity_collection