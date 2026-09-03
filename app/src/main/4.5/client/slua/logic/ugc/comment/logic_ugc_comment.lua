local logic_ugc_comment = {}
logic_ugc_comment.ReplyFeedbackModeType = {Single = 1, Batch = 2}
function logic_ugc_comment:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_UGC_TRANSLATE_STATE_CHANGE, self.OnTranslateStateChange, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_UGC_TRANSLATE_CALLBACK, self.OnTransRsp, self)
end
function logic_ugc_comment:DefineAndResetData()
  self.translateStateList = nil
  self.reportDataCache = nil
  self.supportCommentData = nil
  self.AllFeedbackList = {}
  self.FeedbackDetailData = {}
  self.FeedbackBriefInfoData = {}
  self.PendingFeedbackList = nil
  self.MailIDData = {
    [1] = {mailID = 11428, DesText = 10120097},
    [2] = {mailID = 11429, DesText = 10120098},
    [3] = {mailID = 11430, DesText = 10120099},
    [4] = {mailID = 11431, DesText = 10120100}
  }
end
function logic_ugc_comment:GetTranslateStateByListType(commentListType)
  if not commentListType then
    log(bWriteLog and "logic_ugc_comment:GetTranslateStateByListType commentListType is nil")
    return false
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local IsOpenOutState = LogicUGC:GetClientOutsideAutoTransEnabled()
  local bDetailTranslate = LogicUGC:GetDetailTranslateState()
  if IsOpenOutState then
    if not self.translateStateList then
      return true
    end
    local ret = self.translateStateList[commentListType]
    if ret == nil or ret == false then
      self.translateStateList[commentListType] = true
      ret = true
    end
    log(bWriteLog and "logic_ugc_comment:GetTranslateStateByListType transState:" .. tostring(ret))
    return ret
  end
  if not bDetailTranslate then
    if not self.translateStateList then
      return false
    end
    local ret = self.translateStateList[commentListType]
    log(bWriteLog and "logic_ugc_comment:GetTranslateStateByListType not bDetailTranslate transState:" .. tostring(ret))
    return ret
  end
  return false
end
function logic_ugc_comment:SetTranslateStateByListType(commentListType, bIsTranslated)
  if not commentListType then
    log(bWriteLog and "logic_ugc_comment:SetTranslateStateByListType commentListType is nil or translateStateList is nil")
    return
  end
  log(bWriteLog and "logic_ugc_comment:GetTranslateStateByListType commentListType:" .. tostring(commentListType) .. " bIsTranslated:" .. tostring(bIsTranslated))
  if not self.translateStateList then
    self.translateStateList = {}
  end
  self.translateStateList[commentListType] = bIsTranslated and true or false
end
function logic_ugc_comment:GetReportDataCache()
  return self.reportDataCache
end
function logic_ugc_comment:SetReportDataCache(data)
  log_tree(bWriteLog and "logic_ugc_comment:SetReportDataCache:", data)
  self.reportDataCache = data
end
function logic_ugc_comment:CheckIsUGCCommentMail(mailInfo)
  if not (mailInfo and mailInfo.opt and mailInfo.opt.type) or not mailInfo.opt.subtype then
    log(bWriteLog and "logic_ugc_comment:CheckIsUGCCommentMail no mailInfo or no opt")
    return false
  end
  local logic_ugc_comment_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_switch)
  if not logic_ugc_comment_switch:CheckCommentSwitchOpen() then
    log(bWriteLog and "logic_ugc_comment:CheckIsUGCCommentMail switch not open")
    return false
  end
  if not self:GetUGCCommentMailModId(mailInfo) then
    log(bWriteLog and "logic_ugc_comment:CheckIsUGCCommentMail no mod_id")
    return false
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local EMailType = MailMacro.Enum_Mail_Type
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  local isUGCCommentMail = mailInfo.opt.type == EMailType.System and mailInfo.opt.subtype == logic_ugc_comment_macro.CommentMailSubType
  log(bWriteLog and "logic_ugc_comment:CheckIsUGCCommentMail isUGCCommentMail:" .. tostring(isUGCCommentMail))
  return isUGCCommentMail
end
function logic_ugc_comment:GetUGCCommentMailModId(mailInfo)
  if not (mailInfo and mailInfo.opt) or not mailInfo.opt.mod_id then
    log(bWriteLog and "logic_ugc_comment:GetUGCCommentMailModId no mailInfo")
    return
  end
  local modId = mailInfo.opt.mod_id
  log(bWriteLog and "logic_ugc_comment:GetUGCCommentMailModId modId:" .. tostring(modId))
  return modId
end
function logic_ugc_comment:SetSupportCommentData(support_comment_data)
  log_tree(bWriteLog and "logic_ugc_comment:SetSupportCommentData:", support_comment_data)
  self.supportCommentData = support_comment_data
end
function logic_ugc_comment:HaveSupportComment(comment_id)
  log(bWriteLog and "logic_ugc_comment:HaveSupportComment comment_id:" .. tostring(comment_id))
  if self.supportCommentData == nil or self.supportCommentData.support_comment_list == nil then
    log(bWriteLog and "logic_ugc_comment:HaveSupportComment no supportCommentData")
    return false
  end
  log(bWriteLog and "logic_ugc_comment:HaveSupportComment comment_id:" .. tostring(comment_id))
  log_tree(bWriteLog and "logic_ugc_comment:HaveSupportComment support_comment_list:", self.supportCommentData.support_comment_list)
  local timestamp = self.supportCommentData.support_comment_list[comment_id] or 0
  return 0 < timestamp
end
function logic_ugc_comment:HaveSupportReply(comment_id)
  log(bWriteLog and "logic_ugc_comment:HaveSupportReply comment_id:" .. tostring(comment_id))
  if self.supportCommentData == nil or self.supportCommentData.support_reply_list == nil then
    log(bWriteLog and "logic_ugc_comment:HaveSupportReply no supportCommentData")
    return false
  end
  log(bWriteLog and "logic_ugc_comment:HaveSupportReply comment_id:" .. tostring(comment_id))
  log_tree(bWriteLog and "logic_ugc_comment:HaveSupportReply support_reply_list:", self.supportCommentData.support_reply_list)
  local timestamp = self.supportCommentData.support_reply_list[comment_id] or 0
  return 0 < timestamp
end
function logic_ugc_comment:HaveReplyComment(comment_id)
  log(bWriteLog and "logic_ugc_comment:HaveReplyComment comment_id:" .. tostring(comment_id))
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  local commentDetail = logic_ugc_comment_detail:GetCommentDetail(comment_id)
  if not commentDetail then
    log(bWriteLog and "logic_ugc_comment_detail:HaveReplyComment no commentDetail")
    return false
  end
  log(bWriteLog and "logic_ugc_comment:HaveReplyComment author_reply:" .. tostring(commentDetail.author_reply))
  return commentDetail.author_reply
end
function logic_ugc_comment:GetAuthorCommentText(mod_id)
  local modInfo = self:GetModInfo(mod_id)
  if modInfo and modInfo.author_comment_text then
    return modInfo.author_comment_text
  else
    return nil
  end
end
function logic_ugc_comment:CanOpenAuthorComment(mod_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAuthorComment)
  if not record or not record[mod_id] then
    log(bWriteLog and "logic_ugc_comment:CanOpenAuthorComment no record")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if not TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), record[mod_id].date) then
    log(bWriteLog and "logic_ugc_comment:CanOpenAuthorComment not same day")
    return true
  end
  log(bWriteLog and "logic_ugc_comment:CanOpenAuthorComment times:" .. tostring(record[mod_id].times))
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  return record[mod_id].times < logic_ugc_comment_macro.MaxAuthorCommentTimes
end
function logic_ugc_comment:GetModInfo(mod_id)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modCache = LogicUGC:GetModByAllCache(mod_id)
  if not modCache then
    log(bWriteLog and "logic_ugc_comment:GetModInfo no modCache")
    return nil
  end
  return modCache.pub_mod_meta
end
function logic_ugc_comment:IsAuthor(mod_id)
  local modInfo = self:GetModInfo(mod_id)
  if not modInfo then
    log(bWriteLog and "logic_ugc_comment:IsAuthor no modInfo")
    return false
  end
  local authorUid = modInfo.base and modInfo.base.uid or 0
  return authorUid == tonumber(DataMgr.roleData.uid)
end
function logic_ugc_comment:send_reply_comment_req(mod_id, comment_id, reply_content)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_reply_comment_req(mod_id, comment_id, reply_content)
end
function logic_ugc_comment:on_reply_comment_rsp(mod_id, comment_id, author_reply_content)
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  logic_ugc_comment_detail:SetAuthorReply(comment_id, author_reply_content)
  ShowNotice(64083)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REPLY_COMMENT_RSP, comment_id)
end
function logic_ugc_comment:send_del_reply_comment_req(comment_id)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_del_reply_comment_req(comment_id)
end
function logic_ugc_comment:on_del_reply_comment_rsp(comment_id)
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  logic_ugc_comment_detail:DeleteAuthorReply(comment_id)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_REPLY_COMMENT_RSP, comment_id)
end
function logic_ugc_comment:send_ugc_support_comment_req(mod_id, comment_id, opt_type, opt_obj, only_delete_record)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_support_comment_req(mod_id, comment_id, opt_type, opt_obj, only_delete_record)
end
function logic_ugc_comment:on_ugc_support_comment_rsp(comment_id, opt_type, opt_obj, timestamp)
  if opt_obj == 0 then
    self:UpdateSupportComment(comment_id, opt_type, timestamp)
  elseif opt_obj == 1 then
    self:UpdateSupportReply(comment_id, opt_type, timestamp)
  end
end
function logic_ugc_comment:send_author_set_featured_comment_req(mod_id, comment_id, source)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCSetFeaturedComment)
  if saveData and saveData.isShowGuide then
    local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
    UgcCommentHandler.send_author_set_featured_comment_req(mod_id, comment_id, source)
  else
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(64034)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, function()
      local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
      UgcCommentHandler.send_author_set_featured_comment_req(mod_id, comment_id, source)
    end)
    local saveData = {isShowGuide = true}
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eUGCSetFeaturedComment)
  end
end
function logic_ugc_comment:on_author_set_featured_comment_rsp(mod_id, comment_id, source)
  local logic_ugc_featured_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_featured_comment_summary)
  logic_ugc_featured_comment_summary:AddComment(mod_id, comment_id)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  if source == logic_ugc_comment_macro.CommentOptSource.OneWorkManage then
    local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
    logic_ugc_work_detail_featured_comment:AddComment(mod_id, comment_id)
  end
  local logic_ugc_common_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_common_comment_summary)
  logic_ugc_common_comment_summary:DeleteComment(mod_id, comment_id)
  ShowNotice(64032)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHOR_SET_FEATURED_COMMENT)
end
function logic_ugc_comment:send_author_del_featured_comment_req(mod_id, comment_id, source)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCCancelFeaturedComment)
  if saveData and saveData.isShowGuide then
    local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
    UgcCommentHandler.send_author_del_featured_comment_req(mod_id, comment_id, source)
  else
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(64035)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, function()
      local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
      UgcCommentHandler.send_author_del_featured_comment_req(mod_id, comment_id, source)
    end)
    local saveData = {isShowGuide = true}
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eUGCCancelFeaturedComment)
  end
end
function logic_ugc_comment:on_author_del_featured_comment_rsp(mod_id, comment_id, is_insert_unfeatured_comment, source)
  if is_insert_unfeatured_comment then
    local logic_ugc_common_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_common_comment_summary)
    logic_ugc_common_comment_summary:AddComment(mod_id, comment_id, source)
  end
  local logic_ugc_featured_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_featured_comment_summary)
  logic_ugc_featured_comment_summary:DeleteComment(mod_id, comment_id)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  if source == logic_ugc_comment_macro.CommentOptSource.OneWorkManage or source == logic_ugc_comment_macro.CommentOptSource.WorkDetail then
    local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
    logic_ugc_work_detail_featured_comment:DeleteComment(mod_id, comment_id)
  end
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  logic_ugc_comment_detail:ClearSupportCount(comment_id)
  ShowNotice(64033)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHOR_CANCEL_FEATURED_COMMENT)
end
function logic_ugc_comment:send_delete_comment_req(author_uid, mod_id, comment_id, is_featured_comment, source)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCDeleteComment)
  if saveData and saveData.isShowGuide then
    local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
    UgcCommentHandler.send_delete_comment_req(author_uid, mod_id, comment_id, is_featured_comment, source)
  else
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(64054)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, function()
      local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
      UgcCommentHandler.send_delete_comment_req(author_uid, mod_id, comment_id, is_featured_comment, source)
    end)
    local saveData = {isShowGuide = true}
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eUGCDeleteComment)
  end
end
function logic_ugc_comment:on_delete_comment_rsp(mod_id, comment_id, is_featured_comment, source)
  if is_featured_comment then
    local logic_ugc_featured_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_featured_comment_summary)
    logic_ugc_featured_comment_summary:DeleteComment(mod_id, comment_id)
    local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
    if source == logic_ugc_comment_macro.CommentOptSource.OneWorkManage or source == logic_ugc_comment_macro.CommentOptSource.WorkDetail then
      local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
      logic_ugc_work_detail_featured_comment:DeleteComment(mod_id, comment_id)
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_FEATURED_COMMENT)
  else
    local logic_ugc_common_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_common_comment_summary)
    logic_ugc_common_comment_summary:DeleteComment(mod_id, comment_id)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_COMMON_COMMENT)
  end
end
function logic_ugc_comment:send_ugc_get_comment_redpoint_req(mod_id)
  local logic_ugc_comment_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_switch)
  if not logic_ugc_comment_switch:CheckCommentSwitchOpen() then
    log(bWriteLog and "logic_ugc_comment:send_ugc_get_comment_redpoint_req not open")
    return
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_get_comment_redpoint_req(mod_id)
end
function logic_ugc_comment:on_ugc_get_comment_redpoint_rsp(redpoint_info, mod_id, club_redpoint_ret)
  local redPointCount = 0
  local redPointCountClub = 0
  redpoint_info = redpoint_info or {}
  club_redpoint_ret = club_redpoint_ret or {}
  if mod_id then
    redPointCount = redpoint_info[mod_id] or 0
  else
    for _, count in pairs(redpoint_info) do
      redPointCount = redPointCount + count
    end
  end
  if mod_id then
    redPointCountClub = club_redpoint_ret[mod_id] or 0
  else
    for _, count in pairs(club_redpoint_ret) do
      redPointCountClub = redPointCountClub + count
    end
  end
  self.  log(bWriteLog and "logic_ugc_comment:on_ugc_get_comment_redpoint_rsp mod_id:" .. tostring(mod_id) .. " redPointCount:" .. tostring(redPointCount))
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_REDPOINT_RSP, mod_id, redPointCount, redPointCountClub)
end
function logic_ugc_comment:send_ugc_delete_comment_redpoint_req(mod_id, need_clean_club_redpoint)
  local logic_ugc_comment_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_switch)
  if not logic_ugc_comment_switch:CheckCommentSwitchOpen() then
    log(bWriteLog and "logic_ugc_comment:send_ugc_delete_comment_redpoint_req not open")
    return
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_delete_comment_redpoint_req(mod_id, need_clean_club_redpoint)
end
function logic_ugc_comment:send_set_ugc_comment_display_req(switch, mod_id)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_set_ugc_comment_display_req(switch, mod_id)
end
function logic_ugc_comment:on_set_ugc_comment_display_rsp(switch, mod_id)
end
function logic_ugc_comment:send_query_ugc_comment_display_req(mod_id)
  if not LobbySystem.CheckOpen(BP_ENUM_UGC_REFUSE_COMMENT_SWITCH) then
    log(bWriteLog and "logic_ugc_comment:send_query_ugc_comment_display_req switch close")
    return
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_query_ugc_comment_display_req(mod_id)
end
function logic_ugc_comment:on_query_ugc_comment_display_rsp(total_switch, map_switch, mod_id)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REFUSE_COMMENT_SWITCH_UPDATE, total_switch, map_switch, mod_id)
end
function logic_ugc_comment:send_ugc_query_author_mod_comment_display_req(author_uid, mod_id)
  if not LobbySystem.CheckOpen(BP_ENUM_UGC_REFUSE_COMMENT_SWITCH) then
    log(bWriteLog and "logic_ugc_comment:send_ugc_query_author_mod_comment_display_req switch close")
    return
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_query_author_mod_comment_display_req(author_uid, mod_id)
end
function logic_ugc_comment:on_ugc_query_author_mod_comment_display_rsp(total_switch, map_switch, mod_id)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_QUERY_AUTHOR_COMMENT_SWITCH, total_switch, map_switch, mod_id)
end
function logic_ugc_comment:send_ugc_author_post_comment_for_map_req(mod_id, comment_text)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_author_post_comment_for_map_req(mod_id, comment_text)
end
function logic_ugc_comment:on_ugc_author_post_comment_for_map_rsp(mod_id, comment_text)
  self:UpdateAuthorCommentText(mod_id, comment_text)
  ShowNotice(64317)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHOR_COMMENT_OK)
end
function logic_ugc_comment:send_ugc_author_delete_comment_for_map_req(mod_id)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_author_delete_comment_for_map_req(mod_id)
end
function logic_ugc_comment:on_ugc_author_delete_comment_for_map_rsp(mod_id)
  self:UpdateAuthorCommentText(mod_id)
  ShowNotice(64324)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHOR_DELETE_COMMENT_OK)
end
function logic_ugc_comment:send_ugc_set_top_comment_req(mod_id, comment_id)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_set_top_comment_req(mod_id, comment_id)
end
function logic_ugc_comment:on_ugc_set_top_comment_rsp(mod_id, comment_id, old_comment_id)
  local logic_ugc_featured_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_featured_comment_summary)
  logic_ugc_featured_comment_summary:SetCommentTop(mod_id, comment_id, true)
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:SetCommentTop(comment_id, true)
  if old_comment_id then
    logic_ugc_featured_comment_summary:SetCommentTop(mod_id, old_comment_id, false)
    logic_ugc_work_detail_featured_comment:SetCommentTop(old_comment_id, false)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REPLACE_OLD_TOP_COMMENT, old_comment_id)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SET_TOP_COMMENT_RSP, comment_id)
  ShowNotice(64311)
end
function logic_ugc_comment:send_ugc_delete_top_comment_req(mod_id, comment_id)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_delete_top_comment_req(mod_id, comment_id)
end
function logic_ugc_comment:on_ugc_delete_top_comment_rsp(mod_id, comment_id)
  local logic_ugc_featured_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_featured_comment_summary)
  logic_ugc_featured_comment_summary:SetCommentTop(mod_id, comment_id, false)
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:SetCommentTop(comment_id, false)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_TOP_COMMENT_RSP, comment_id)
  ShowNotice(64313)
end
function logic_ugc_comment:UpdateSupportComment(comment_id, opt_type, timestamp)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  if opt_type == logic_ugc_comment_macro.SupportOptType.Support then
    if self.supportCommentData == nil then
      self.supportCommentData = {}
    end
    if self.supportCommentData.support_comment_list == nil then
      self.supportCommentData.support_comment_list = {}
    end
    self.supportCommentData.support_comment_list[comment_id] = timestamp
  elseif opt_type == logic_ugc_comment_macro.SupportOptType.CancelSupport then
    if self.supportCommentData == nil or self.supportCommentData.support_comment_list == nil then
      log(bWriteLog and "logic_ugc_comment:UpdateSupportComment no supportCommentData")
      return
    end
    self.supportCommentData.support_comment_list[comment_id] = nil
  end
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  logic_ugc_comment_detail:UpdateSupportComment(comment_id, opt_type)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SUPPORT_COMMENT_RES, comment_id)
end
function logic_ugc_comment:UpdateSupportReply(comment_id, opt_type, timestamp)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  if opt_type == logic_ugc_comment_macro.SupportOptType.Support then
    if self.supportCommentData == nil then
      self.supportCommentData = {}
    end
    if self.supportCommentData.support_reply_list == nil then
      self.supportCommentData.support_reply_list = {}
    end
    self.supportCommentData.support_reply_list[comment_id] = timestamp
  elseif opt_type == logic_ugc_comment_macro.SupportOptType.CancelSupport then
    if self.supportCommentData == nil or self.supportCommentData.support_reply_list == nil then
      log(bWriteLog and "logic_ugc_comment:UpdateSupportReply no supportCommentData")
      return
    end
    self.supportCommentData.support_reply_list[comment_id] = nil
  end
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  logic_ugc_comment_detail:UpdateSupportReply(comment_id, opt_type)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SUPPORT_REPLY_RES, comment_id)
end
function logic_ugc_comment:UpdateAuthorCommentText(mod_id, comment_text)
  local modInfo = self:GetModInfo(mod_id)
  if not modInfo then
    return
  end
  modInfo.author_end
function logic_ugc_comment:send_ugc_get_feedback_list_req()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local modList = LogicUGC:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub)
  local modIDList = {}
  if not modList or not next(modList) then
    self:RequestOnePageModData()
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local SortedPubModList = LogicUGC:GetSortedPubModList()
    if SortedPubModList and next(SortedPubModList) then
      for k, v in pairs(SortedPubModList) do
        table.insert(modIDList, v.modId)
      end
    end
  elseif modList and next(modList) then
    for k, v in pairs(modList) do
      table.insert(modIDList, k)
    end
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  if modIDList and next(modIDList) then
    UgcCommentHandler.send_ugc_get_feedback_list_req(modIDList)
  end
end
function logic_ugc_comment:GetfeedbackListReqSingle(modID)
  if not modID then
    log(bWriteLog and "logic_ugc_comment:GetfeedbackListReqSingle modid = nil")
    return
  end
  log(bWriteLog and "logic_ugc_comment:GetfeedbackListReqSingle modid = " .. tostring(modID))
  local modIDList = {
    [1] = modID
  }
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_get_feedback_list_req(modIDList)
end
function logic_ugc_comment:on_ugc_get_feedback_list_rsp(err_code, data)
  if err_code ~= 0 then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK, self.AllFeedbackList)
    return
  end
  self.AllFeedbackList = {}
  local feedback_IDList = {}
  for k, v in pairs(data) do
    for k2, v2 in pairs(v) do
      local data = {
        feedback_ID = k2,
        is_read = v2.is_read,
        is_anonymous = v2.is_anonymous,
        uid = v2.uid,
        feedback_time = v2.feedback_time,
        rebirth_count = v2.rebirth_count,
        feedback_type = v2.feedback_type,
        modid = k,
        is_reply = v2.is_reply
      }
      if not self.AllFeedbackList[k] then
        self.AllFeedbackList[k] = {}
      end
      table.insert(self.AllFeedbackList[k], data)
      table.insert(feedback_IDList, k2)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK, self.AllFeedbackList)
  self:on_ugc_batch_get_feedback_detail_req(feedback_IDList)
end
function logic_ugc_comment:CheckInfoIsRead()
  if not self.AllFeedbackList or not next(self.AllFeedbackList) then
    log(bWriteLog and "logic_ugc_comment:CheckInfoIsRead AllFeedbackList is empty")
    return false
  end
  for _, modFeedbackList in pairs(self.AllFeedbackList) do
    if modFeedbackList and next(modFeedbackList) then
      for _, feedback in pairs(modFeedbackList) do
        if feedback and not feedback.is_read then
          return true
        end
      end
    end
  end
  return false
end
function logic_ugc_comment:GetSelectedDropFeedbackList(modid, isAll)
  local AllList = {}
  if not self.AllFeedbackList then
    return AllList
  end
  if isAll then
    for k, v in pairs(self.AllFeedbackList) do
      for k2, v2 in pairs(v) do
        table.insert(AllList, v2)
      end
    end
  else
    local modFeedbackList = self.AllFeedbackList[modid]
    if not modFeedbackList then
      return AllList
    end
    for k, v in pairs(modFeedbackList) do
      table.insert(AllList, v)
    end
  end
  table.sort(AllList, function(item1, item2)
    local is_read1 = item1.is_read or false
    local is_read2 = item2.is_read or false
    if is_read1 ~= is_read2 then
      return not is_read1 and is_read2
    end
    return (item1.feedback_time or 0) > (item2.feedback_time or 0)
  end)
  for i = 1, #AllList do
    local item = AllList[i]
    if item.is_read then
      item.is_top_read = true
      break
    end
  end
  return AllList
end
function logic_ugc_comment:GetFeedbackOriginList()
  return self.AllFeedbackList
end
function logic_ugc_comment:send_ugc_get_feedback_detail_req(feedback_id)
  if self.FeedbackDetailData[feedback_id] then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK_DETAIL, feedback_id, self.FeedbackDetailData[feedback_id])
    return
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_get_feedback_detail_req(feedback_id)
end
function logic_ugc_comment:on_ugc_get_feedback_detail_rsp(err_code, feedback_id, data)
  if not feedback_id then
    print(bWriteLog and "logic_ugc_comment:on_ugc_get_feedback_detail_rsp - feedback_id is nil, skipping")
    return
  end
  if not self.FeedbackDetailData then
    self.FeedbackDetailData = {}
  end
  self.FeedbackDetailData[feedback_id] = data
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK_DETAIL, feedback_id, data)
end
function logic_ugc_comment:send_ugc_batch_delete_feedbacks_req(feedback_table)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_batch_delete_feedbacks_req(feedback_table, false)
end
function logic_ugc_comment:on_ugc_batch_delete_feedbacks_rsp(modid, feedback_id)
  self:Deletefeedback(modid, feedback_id)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK_UPDATE)
end
function logic_ugc_comment:send_ugc_mark_feedback_read_status_req(feedback_table, mailID)
  self:Readfeedback(feedback_table, mailID)
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_mark_feedback_read_status_req(feedback_table, mailID)
end
function logic_ugc_comment:on_ugc_mark_feedback_read_status_rsp(data)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_MARK_FEEDBACK, data)
end
function logic_ugc_comment:Readfeedback(feedback_table, mailID)
  for k, v in pairs(feedback_table) do
    for k2, v2 in pairs(v) do
      if self.AllFeedbackList[k] then
        for k3, v3 in pairs(self.AllFeedbackList[k]) do
          if v3.feedback_ID == v2 then
            v3.is_read = true
            if mailID then
              v3.is_reply = true
            end
          end
        end
      end
    end
  end
end
function logic_ugc_comment:Deletefeedback(feedback_table)
  for k, v in pairs(feedback_table) do
    if self.AllFeedbackList[k] and next(self.AllFeedbackList[k]) then
      for k2, v2 in pairs(v) do
        for k3, v3 in pairs(self.AllFeedbackList[k]) do
          if v2 and v3.feedback_ID == k2 then
            self.AllFeedbackList[k][k3] = nil
          end
        end
      end
      if not next(self.AllFeedbackList[k]) then
        self.AllFeedbackList[k] = nil
      end
    end
  end
end
function logic_ugc_comment:GetModMateData(ModID)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local modList = LogicUGC:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub) or {}
  if not modList or not next(modList) then
    self:RequestOnePageModData()
  end
  local modMate = modList[ModID] or {}
  return modMate.pub_mod_meta
end
function logic_ugc_comment:RequestOnePageModData()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local SortedPubModList = LogicUGC:GetSortedPubModList()
  if not SortedPubModList or not next(SortedPubModList) then
    log(bWriteLog and "UI_UGC_Mine_Works:RequestOnePageModData list is invalid")
    return false
  end
  local ModIDList = {}
  for _, modInfo in ipairs(SortedPubModList) do
    local ModID = modInfo.modId or 0
    table.insert(ModIDList, ModID)
  end
  LogicUGC:BatchGetModInfo(ModIDList, LogicUGC.C_ModListTypes.Pub, nil, {bSimple = true})
  return true
end
function logic_ugc_comment:GetFeedbackBriefInfo(feedback_id)
  if self.FeedbackBriefInfoData[feedback_id] then
    local data = self.FeedbackBriefInfoData[feedback_id]
    if data.isTranslated then
      local LogicUGCTrans = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTrans)
      local transText, _ = LogicUGCTrans:GetTransByStrWithState(data.origintext)
      if transText and transText ~= "" then
        return transText
      end
    end
    return data.origintext or ""
  end
  return nil
end
function logic_ugc_comment:safe_substring_utf8(str, max_len)
  if not str or str == "" then
    return ""
  end
  local utf8_len = function(s)
    local count = 0
    local i = 1
    while i <= #s do
      local byte = string.byte(s, i)
      if byte < 128 then
        i = i + 1
      elseif byte < 224 then
        i = i + 2
      elseif byte < 240 then
        i = i + 3
      else
        i = i + 4
      end
      count = count + 1
    end
    return count
  end
  if max_len >= utf8_len(str) then
    return str
  end
  local char_count = 0
  local byte_pos = 0
  local i = 1
  while i <= #str and max_len > char_count do
    local byte = string.byte(str, i)
    if byte < 128 then
      byte_pos = i
      i = i + 1
    elseif byte < 224 then
      byte_pos = i + 1
      i = i + 2
    elseif byte < 240 then
      byte_pos = i + 2
      i = i + 3
    else
      byte_pos = i + 3
      i = i + 4
    end
    char_count = char_count + 1
  end
  return LocUtil.LocalizeResFormat(8600314, string.sub(str, 1, byte_pos))
end
function logic_ugc_comment:on_ugc_batch_get_feedback_detail_req(feedback_IDList)
  if not feedback_IDList or #feedback_IDList == 0 then
    return
  end
  self.PendingFeedbackList = feedback_IDList
  local BATCH_SIZE = 20
  local MAX_REQUEST_COUNT = 60
  local current_batch_count = math.min(BATCH_SIZE, #self.PendingFeedbackList, MAX_REQUEST_COUNT)
  local batch_list = {}
  for i = 1, current_batch_count do
    table.insert(batch_list, self.PendingFeedbackList[i])
  end
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_batch_get_feedback_detail_req(batch_list)
end
function logic_ugc_comment:on_ugc_batch_get_feedback_detail_rsp(feedback_data_list)
  for k, v in pairs(feedback_data_list) do
    self:SetFeedbackBriefInfo(k, v.feedback_content)
  end
  local BATCH_SIZE = 20
  local MAX_REQUEST_COUNT = 60
  if self.PendingFeedbackList and BATCH_SIZE < #self.PendingFeedbackList and MAX_REQUEST_COUNT >= #self.PendingFeedbackList then
    local remaining_list = {}
    for i = BATCH_SIZE + 1, #self.PendingFeedbackList do
      table.insert(remaining_list, self.PendingFeedbackList[i])
    end
    self.PendingFeedbackList = remaining_list
    local batch_list = {}
    for i = 1, math.min(BATCH_SIZE, #self.PendingFeedbackList) do
      table.insert(batch_list, self.PendingFeedbackList[i])
    end
    local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
    UgcCommentHandler.send_ugc_batch_get_feedback_detail_req(batch_list)
  else
    self.PendingFeedbackList = nil
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK_BRIEFINFO_UPDATE)
end
function logic_ugc_comment:SetFeedbackBriefInfo(feedback_id, content, bForceUpdate, bIsTranslation)
  if not self.FeedbackBriefInfoData then
    self.FeedbackBriefInfoData = {}
  end
  if not bForceUpdate and self.FeedbackBriefInfoData[feedback_id] then
    return
  end
  if not self.FeedbackBriefInfoData[feedback_id] then
    local content_text = content or ""
    local LogicUGCTrans = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTrans)
    local transText, _ = LogicUGCTrans and LogicUGCTrans:GetTransByStrWithState(content_text)
    local bHasTranslationCache = transText and transText ~= ""
    self.FeedbackBriefInfoData[feedback_id] = {origintext = content_text, isTranslated = bHasTranslationCache}
    return
  end
  if bIsTranslation then
    self.FeedbackBriefInfoData[feedback_id].isTranslated = true
  else
    local content_text = content or ""
    self.FeedbackBriefInfoData[feedback_id].origintext = content_text
    local LogicUGCTrans = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTrans)
    local transText, _ = LogicUGCTrans and LogicUGCTrans:GetTransByStrWithState(content_text)
    local bHasTranslationCache = transText and transText ~= ""
    self.FeedbackBriefInfoData[feedback_id].isTranslated = bHasTranslationCache
  end
end
function logic_ugc_comment:OnTranslateStateChange(_, _, str, bIsForbidden)
  if not str or str == "" then
    return
  end
  if not self.FeedbackBriefInfoData then
    return
  end
  for feedback_id, content in pairs(self.FeedbackBriefInfoData) do
    if content.origintext == str then
      self:SetFeedbackBriefInfo(feedback_id, str, true, true)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK_BRIEFINFO_UPDATE)
end
function logic_ugc_comment:OnTransRsp(_, _, chatMsg)
  if not (chatMsg and chatMsg.msg) or not chatMsg.transOrOrgText then
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMENT_PLAYER_FEEDBACK_BRIEFINFO_UPDATE)
end
function logic_ugc_comment:GetMailIDByIndex(index)
  if not index or not self.MailIDData then
    return nil
  end
  local item = self.MailIDData[index]
  return item and item.mailID or nil
end
function logic_ugc_comment:GetReportBugConfig()
  if self._reportBugConfigCache then
    return self._reportBugConfigCache
  end
  local ReportConfig = require("GameLua.Mod.CreativeBase.Client.Config.BattleReportConfig")
  local BattleReportBugConfig = ReportConfig.ReportBugConfig
  local UGCExtra = ReportConfig.UGCExtra
  local reportBugConfig = {}
  for _, value in ipairs(BattleReportBugConfig) do
    table.insert(reportBugConfig, value)
  end
  for _, value in ipairs(UGCExtra) do
    local TableUtil = require("common.table_util")
    local Data = TableUtil.FastCopyTable(value)
    local NewContent = {}
    for i, temp in ipairs(Data.Content) do
      table.insert(NewContent, temp)
    end
    Data.Content = NewContent
    table.insert(reportBugConfig, Data)
  end
  self._reportBugConfigCache = reportBugConfig
  return reportBugConfig
end
function logic_ugc_comment:GetErrorRealIndex(index)
  local ReportBugConfig = self:GetReportBugConfig()
  local mainText = ""
  local subText = ""
  local finalText = ""
  local count = 0
  for i = 1, #ReportBugConfig do
    for j = 1, #ReportBugConfig[i].Content do
      count = count + 1
      if count == index then
        mainText = LocUtil.GetLocalizeResStr(ReportBugConfig[i].TitleTextID)
        if ReportBugConfig[i].Content[j].CreateExtreHandle then
          local name = ""
          subText = LocUtil.LocalizeResFormat(ReportBugConfig[i].Content[j].ReportBugTextID, name)
        else
          subText = LocUtil.GetLocalizeResStr(ReportBugConfig[i].Content[j].ReportBugTextID)
        end
        finalText = mainText .. "-" .. subText
      end
    end
  end
  return finalText
end
function logic_ugc_comment:ClearReportBugConfigCache()
  self._reportBugConfigCache = nil
end
function logic_ugc_comment:ShowReplyFeedbackPopup(title, content, onSelected, modeType)
  local data = {
    title = title or "",
    content = content or "",
    onSelected = onSelected,
    modeType = modeType or logic_ugc_comment.ReplyFeedbackModeType.Single
  }
  UIManager.ShowUI(UIManager.UI_Config.UGC_Comment_ReplyFeedback_Popup_InGame_UIBP, data)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_comment = class(CModuleBase, nil, logic_ugc_comment)
return Clogic_ugc_comment