local logic_ugc_work_detail_featured_comment = {}
function logic_ugc_work_detail_featured_comment:DefineAndResetData()
  self.sortedCommentList = {}
  self.curCommentPage = 0
  self.modID = 0
  self.modInfo = nil
  self.index = 0
  self.MessageTop = false
end
function logic_ugc_work_detail_featured_comment:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_POST_COMMENTSort_RSP, self.OnUpDateCommentSort, self)
end
function logic_ugc_work_detail_featured_comment:SetModID(modId)
  log("logic_ugc_work_detail_featured_comment:SetModID " .. modId .. "")
  self.modID = modId
end
function logic_ugc_work_detail_featured_comment:ReqCommentDetailByPage(is_featured_comment, source)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  local onePageCount = logic_ugc_comment_macro.OnePageCount
  local comment_id_list = {}
  self.curCommentPage = (self.curCommentPage or 0) + 1
  local collected = 0
  for idx = (self.curCommentPage - 1) * onePageCount + 1, #self.sortedCommentList do
    if self.sortedCommentList[idx] and self.sortedCommentList[idx].comment_id then
      table.insert(comment_id_list, self.sortedCommentList[idx].comment_id)
      collected = collected + 1
      if onePageCount <= collected then
        break
      end
    end
  end
  if 0 < #comment_id_list then
    log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:ReqCommentDetailByPage comment_id_list:", comment_id_list)
    local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
    logic_ugc_comment_detail:send_batch_get_comment_data_req(comment_id_list, is_featured_comment, source)
  else
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:ReqCommentDetailByPage empty comment_id_list")
  end
end
function logic_ugc_work_detail_featured_comment:SetCommentList(modInfo)
  self.sortedCommentList = {}
  if modInfo.featured_comment_list then
    for comment_id, comment in pairs(modInfo.featured_comment_list) do
      table.insert(self.sortedCommentList, {comment_id = comment_id, comment = comment})
    end
  end
  if self.AppreciationCommentList then
    for _, comment in ipairs(self.AppreciationCommentList) do
      local comment1 = {
        is_appreciation_comment = true,
        comment_score = comment.score,
        comment_time = comment.timestamp,
        mod_id = comment.mod_id,
        support_count = comment.support_count,
        uid = comment.uid,
        author_reply_content = comment.author_reply_content,
        comment_text = comment.comment,
        author_reply = comment.author_reply,
        is_set_top = comment.is_top,
        author_reply_time = comment.author_reply_content and comment.author_reply_content.reply_time or 0
      }
      table.insert(self.sortedCommentList, {comment = comment1})
    end
  end
  self:SortCommentList()
  self.curCommentPage = 0
end
function logic_ugc_work_detail_featured_comment:GetHistoryPlayTime(comment_id)
  for _, comment_data in ipairs(self.sortedCommentList) do
    if comment_data.comment_id == comment_id then
      return comment_data.comment.history_play_time
    end
  end
  return nil
end
function logic_ugc_work_detail_featured_comment:GetCommentList()
  log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:GetCommentList allCommentList:", self.sortedCommentList)
  return self.sortedCommentList
end
function logic_ugc_work_detail_featured_comment:OnUpDateCommentSort(_, _, index)
  self.end
function logic_ugc_work_detail_featured_comment:GetShowCommentList()
  local showCommentList = {}
  local normalCommentList = {}
  local qualityCommentList = {}
  local topComment = {}
  local appreciationTopComment = {}
  local logic_ugc_comment_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_detail)
  for _, comment_data in ipairs(self.sortedCommentList) do
    local commentDetail = comment_data.comment_id and logic_ugc_comment_detail:GetCommentDetail(comment_data.comment_id)
    if comment_data.comment.is_appreciation_comment then
      if comment_data.comment.is_set_top then
        appreciationTopComment = comment_data
      else
        table.insert(qualityCommentList, comment_data)
      end
    elseif commentDetail then
      if comment_data.comment and comment_data.comment.is_set_top then
        topComment = comment_data
      elseif comment_data.comment and comment_data.comment.recommend_flag then
        table.insert(qualityCommentList, comment_data)
      else
        table.insert(normalCommentList, comment_data)
      end
    end
  end
  if self.index == 0 then
    self.index = 1
  end
  local Enum_CommentSort = require("client.slua.umg.ugc.comment.Featured_Comment_Item_Send").Enum_CommentSort
  if self.index == Enum_CommentSort.CompRank then
    self:SortCompRankLikes(normalCommentList)
    self:SortCompRankLikes(qualityCommentList)
  elseif self.index == Enum_CommentSort.Like then
    self:SortsupportLikes(normalCommentList)
    self:SortsupportLikes(qualityCommentList)
  elseif self.index == Enum_CommentSort.Reply then
    self:SortcommenttimeLikes(normalCommentList)
    self:SortcommenttimeLikes(qualityCommentList)
  elseif self.index == Enum_CommentSort.Issue then
    self:SortreplytimeLikes(normalCommentList)
    self:SortreplytimeLikes(qualityCommentList)
  elseif self.index == Enum_CommentSort.Default then
    self:SortByLikes(normalCommentList)
    self:SortByLikes(qualityCommentList)
  elseif self.index == Enum_CommentSort.Appreciation then
    self:SortAppreciationFirst(normalCommentList)
    self:SortAppreciationFirst(qualityCommentList)
  end
  if next(appreciationTopComment) then
    table.insert(showCommentList, appreciationTopComment)
  end
  if next(topComment) then
    table.insert(showCommentList, topComment)
  end
  for k, v in pairs(qualityCommentList) do
    table.insert(showCommentList, v)
  end
  for k, v in pairs(normalCommentList) do
    table.insert(showCommentList, v)
  end
  if next(showCommentList) then
    if showCommentList[1].comment.is_set_top ~= nil then
      self.MessageTop = true
    else
      self.MessageTop = false
    end
  end
  log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:GetShowCommentList allCommentList:", self.sortedCommentList)
  log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:GetShowCommentList showCommentList:", showCommentList)
  return showCommentList
end
function logic_ugc_work_detail_featured_comment:GetComment(comment_id)
  for _, comment_data in ipairs(self.sortedCommentList) do
    if comment_data.comment_id == comment_id then
      return comment_data.comment
    end
  end
  return nil
end
function logic_ugc_work_detail_featured_comment:AddComment(mod_id, comment_id)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:AddComment mod_id:" .. tostring(mod_id))
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:AddComment comment_id:" .. tostring(comment_id))
  if self.modID ~= mod_id then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:AddComment not same mod")
    return
  end
  local logic_ugc_common_comment_summary = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_common_comment_summary)
  local comment = logic_ugc_common_comment_summary:GetComment(mod_id, comment_id)
  if not comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:AddComment no comment")
    return
  end
  comment.support_count = 0
  table.insert(self.sortedCommentList, {comment_id = comment_id, comment = comment})
end
function logic_ugc_work_detail_featured_comment:DeleteComment(mod_id, comment_id)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:DeleteComment comment_id:" .. tostring(comment_id))
  for idx, comment_data in ipairs(self.sortedCommentList) do
    if comment_data.comment_id == comment_id then
      log(bWriteLog and "logic_ugc_work_detail_featured_comment:DeleteComment OK")
      table.remove(self.sortedCommentList, idx)
      break
    end
  end
end
function logic_ugc_work_detail_featured_comment:ResetData()
  self:DefineAndResetData()
end
function logic_ugc_work_detail_featured_comment:SetData(mod_id, meta_data)
  self.modID = mod_id
  self.modInfo = meta_data
  self:SetCommentList(meta_data)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_PUB_META_FOR_COMMENT_RSP, self.modID)
end
function logic_ugc_work_detail_featured_comment:SetCommentTop(comment_id, isTop)
  local comment = self:GetComment(comment_id)
  if not comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:SetCommentTop no comment")
    return
  end
  comment.is_set_top = isTop
  self:SortCommentList()
end
function logic_ugc_work_detail_featured_comment:CheckCommentTop(comment_id)
  local comment = self:GetComment(comment_id)
  if not comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckCommentTop no comment")
    return
  end
  return comment.is_set_top
end
function logic_ugc_work_detail_featured_comment:GetCommentScoreData(modInfo)
  modInfo = modInfo or self.modInfo
  if not modInfo then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:GetCommentScoreData no modInfo")
    return nil
  end
  return modInfo.comment_data
end
function logic_ugc_work_detail_featured_comment:GetCommentAppreciationData(modInfo)
  modInfo = modInfo or self.modInfo
  if not modInfo then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:GetCommentAppreciationData no modInfo")
    return nil
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    return nil
  end
  local LobbySystem = require("client.logic.login.logic_lobby")
  if not LobbySystem.CheckOpen(BP_ENUM_UGC_APPRECIATION_GROUP) then
    return nil
  end
  return modInfo.review_panel_data
end
function logic_ugc_work_detail_featured_comment:SetSupportAppreciationCommentData(support_appreciation_comment_data)
  log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:SetSupportAppreciationCommentData:", support_appreciation_comment_data)
  self.SupportAppreciationCommentData = support_appreciation_comment_data
end
function logic_ugc_work_detail_featured_comment:GetAppreciationComment(comment_uid)
  for _, comment_data in ipairs(self.sortedCommentList) do
    if comment_data.comment and comment_data.comment.is_appreciation_comment and comment_data.comment.uid == comment_uid then
      return comment_data.comment
    end
  end
  return nil
end
function logic_ugc_work_detail_featured_comment:DeleteAppreciationComment(comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:DeleteAppreciationComment comment_uid:" .. tostring(comment_uid))
  for idx, comment_data in ipairs(self.sortedCommentList) do
    if comment_data.comment.uid == comment_uid then
      log(bWriteLog and "logic_ugc_work_detail_featured_comment:DeleteAppreciationComment OK")
      table.remove(self.sortedCommentList, idx)
      break
    end
  end
end
function logic_ugc_work_detail_featured_comment:CheckAppreciationCommentTop(comment_uid)
  local comment = self:GetAppreciationComment(comment_uid)
  if not comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentTop no comment")
    return
  end
  return comment.is_set_top
end
function logic_ugc_work_detail_featured_comment:CheckAppreciationCommentReply(comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentReply comment_uid:" .. tostring(comment_uid))
  local commentDetail = self:GetAppreciationComment(comment_uid)
  if not commentDetail then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentReply no commentDetail")
    return false
  end
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentReply author_reply:" .. tostring(commentDetail.author_reply))
  return commentDetail.author_reply
end
function logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport(mod_id, comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport mod_id:" .. tostring(mod_id) .. " comment_uid:" .. tostring(comment_uid))
  if self.SupportAppreciationCommentData == nil or self.SupportAppreciationCommentData.support_comment_list == nil then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport no SupportAppreciationCommentData")
    return false
  end
  local support_key = tostring(mod_id) .. "_" .. tostring(comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport support_key:" .. support_key)
  local support_info = self.SupportAppreciationCommentData.support_comment_list[support_key]
  if not support_info then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport no support info for key:" .. support_key)
    return false
  end
  local appreciation_comment = self:GetAppreciationComment(comment_uid)
  if not appreciation_comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport no appreciation comment found for uid:" .. tostring(comment_uid))
    return false
  end
  local comment_version = appreciation_comment.comment_time or 0
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationCommentSupport comment_version:" .. tostring(comment_version) .. " support_version:" .. tostring(support_info.version or 0))
  local timestamp = support_info.support_time or 0
  local version_match = (support_info.version or 0) == comment_version
  return 0 < timestamp and version_match
end
function logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport(mod_id, comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport mod_id:" .. tostring(mod_id) .. " comment_uid:" .. tostring(comment_uid))
  if self.SupportAppreciationCommentData == nil or self.SupportAppreciationCommentData.support_reply_list == nil then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport no SupportAppreciationCommentData")
    return false
  end
  local support_key = tostring(mod_id) .. "_" .. tostring(comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport support_key:" .. support_key)
  local support_info = self.SupportAppreciationCommentData.support_reply_list[support_key]
  if not support_info then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport no support info for key:" .. support_key)
    return false
  end
  local appreciation_comment = self:GetAppreciationComment(comment_uid)
  if not appreciation_comment or not appreciation_comment.author_reply_content then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport no appreciation comment found for uid:" .. tostring(comment_uid))
    return false
  end
  local comment_version = appreciation_comment.author_reply_content.reply_time or 0
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:CheckAppreciationReplySupport comment_version:" .. tostring(comment_version) .. " support_version:" .. tostring(support_info.version or 0))
  local timestamp = support_info.support_time or 0
  local version_match = (support_info.version or 0) == comment_version
  return 0 < timestamp and version_match
end
function logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportComment(mod_id, comment_uid, opt_type, timestamp)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportComment mod_id:" .. tostring(mod_id) .. " comment_uid:" .. tostring(comment_uid) .. " opt_type:" .. tostring(opt_type))
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  local support_key = tostring(mod_id) .. "_" .. tostring(comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportComment support_key:" .. support_key)
  if opt_type == logic_ugc_comment_macro.SupportOptType.Support then
    if self.SupportAppreciationCommentData == nil then
      self.SupportAppreciationCommentData = {}
    end
    if self.SupportAppreciationCommentData.support_comment_list == nil then
      self.SupportAppreciationCommentData.support_comment_list = {}
    end
    local appreciation_comment = self:GetAppreciationComment(comment_uid)
    if not appreciation_comment then
      log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportComment no appreciation comment found for uid:" .. tostring(comment_uid))
      return
    end
    local comment_version = appreciation_comment.comment_time or 0
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportComment comment_version:" .. tostring(comment_version))
    self.SupportAppreciationCommentData.support_comment_list[support_key] = {
      support_time = timestamp or os.time(),
      version = comment_version
    }
  elseif opt_type == logic_ugc_comment_macro.SupportOptType.CancelSupport then
    if self.SupportAppreciationCommentData == nil or self.SupportAppreciationCommentData.support_comment_list == nil then
      log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportComment no SupportAppreciationCommentData")
      return
    end
    self.SupportAppreciationCommentData.support_comment_list[support_key] = nil
  end
  self:UpdateAppreciationSupportCommentCount(comment_uid, opt_type)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATION_SUPPORT_COMMENT_RSP, mod_id, comment_uid, opt_type, timestamp)
end
function logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportCommentCount(comment_uid, opt_type)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportCommentCount comment_uid:" .. tostring(comment_uid) .. " opt_type:" .. tostring(opt_type))
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  local appreciation_comment = self:GetAppreciationComment(comment_uid)
  if not appreciation_comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportCommentCount no appreciation comment found for uid:" .. tostring(comment_uid))
    return
  end
  local support_count = appreciation_comment.support_count or 0
  if opt_type == logic_ugc_comment_macro.SupportOptType.Support then
    appreciation_comment.support_count = support_count + 1
  elseif opt_type == logic_ugc_comment_macro.SupportOptType.CancelSupport and 0 < support_count then
    appreciation_comment.support_count = support_count - 1
  end
end
function logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReply(mod_id, comment_uid, opt_type, timestamp)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReply mod_id:" .. tostring(mod_id) .. " comment_uid:" .. tostring(comment_uid) .. " opt_type:" .. tostring(opt_type))
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  local support_key = tostring(mod_id) .. "_" .. tostring(comment_uid)
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReply support_key:" .. support_key)
  if opt_type == logic_ugc_comment_macro.SupportOptType.Support then
    if self.SupportAppreciationCommentData == nil then
      self.SupportAppreciationCommentData = {}
    end
    if self.SupportAppreciationCommentData.support_reply_list == nil then
      self.SupportAppreciationCommentData.support_reply_list = {}
    end
    local appreciation_comment = self:GetAppreciationComment(comment_uid)
    if not appreciation_comment or not appreciation_comment.author_reply_content then
      log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReply no appreciation comment found for uid:" .. tostring(comment_uid))
      return
    end
    local comment_version = appreciation_comment.author_reply_content.reply_time or 0
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReply comment_version:" .. tostring(comment_version))
    self.SupportAppreciationCommentData.support_reply_list[support_key] = {
      support_time = timestamp or os.time(),
      version = comment_version
    }
  elseif opt_type == logic_ugc_comment_macro.SupportOptType.CancelSupport then
    if self.SupportAppreciationCommentData == nil or self.SupportAppreciationCommentData.support_reply_list == nil then
      log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReply no SupportAppreciationCommentData")
      return
    end
    self.SupportAppreciationCommentData.support_reply_list[support_key] = nil
  end
  self:UpdateAppreciationSupportReplyCount(comment_uid, opt_type)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATION_SUPPORT_REPLY_RSP, mod_id, comment_uid, opt_type, timestamp)
end
function logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReplyCount(comment_uid, opt_type)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  local appreciation_comment = self:GetAppreciationComment(comment_uid)
  if not appreciation_comment or not appreciation_comment.author_reply_content then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReplyCount no commentDetail")
    return
  end
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReplyCount opt_type:" .. tostring(opt_type))
  log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReplyCount commentDetail before:", appreciation_comment)
  local support_count = appreciation_comment.author_reply_content.reply_support_count or 0
  if opt_type == logic_ugc_comment_macro.SupportOptType.Support then
    appreciation_comment.author_reply_content.reply_support_count = support_count + 1
  elseif opt_type == logic_ugc_comment_macro.SupportOptType.CancelSupport and 0 < support_count then
    appreciation_comment.author_reply_content.reply_support_count = support_count - 1
  end
  log_tree(bWriteLog and "logic_ugc_work_detail_featured_comment:UpdateAppreciationSupportReplyCount commentDetail after:", appreciation_comment)
end
function logic_ugc_work_detail_featured_comment:SetAppreciationCommentAuthorReply(comment_uid, author_reply_content)
  local commentDetail = self:GetAppreciationComment(comment_uid)
  if not commentDetail then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:SetAppreciationCommentAuthorReply no commentDetail")
    return
  end
  commentDetail.  commentDetail.author_reply = true
end
function logic_ugc_work_detail_featured_comment:DeleteAppreciationCommentAuthorReply(comment_uid)
  local commentDetail = self:GetAppreciationComment(comment_uid)
  if not commentDetail then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:DeleteAppreciationCommentAuthorReply no commentDetail")
    return
  end
  commentDetail.author_reply_content = nil
  commentDetail.author_reply = false
end
function logic_ugc_work_detail_featured_comment:SetAppreciationCommentTop(comment_uid, isTop)
  local comment = self:GetAppreciationComment(comment_uid)
  if not comment then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:SetAppreciationCommentTop no comment")
    return
  end
  comment.is_set_top = isTop
  self:SortCommentList()
end
function logic_ugc_work_detail_featured_comment:send_ugc_get_pub_meta_for_comment_req(mod_id)
  self.modInfo = nil
  self.bMetaDataReady = false
  local UgcCommentHandler = require("client.network.Protocol.UgcCommentHandler")
  UgcCommentHandler.send_ugc_get_pub_meta_for_comment_req(mod_id)
end
function logic_ugc_work_detail_featured_comment:on_ugc_get_pub_meta_for_comment_rsp(mod_id, meta_data)
  if self.modID > 0 and self.modID ~= mod_id then
    self:SetAppreciationNotRequired()
  end
  self.modID = mod_id
  self.modInfo = meta_data
  self.bMetaDataReady = true
  self:TrySetData()
end
function logic_ugc_work_detail_featured_comment:SetPubMetaCommentNotRequired()
  self.bMetaDataReady = true
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:SetPubMetaCommentNotRequired bMetaDataReady:" .. tostring(self.bMetaDataReady))
end
function logic_ugc_work_detail_featured_comment:send_ugc_get_review_panel_comment_info_req(mod_id)
  self.AppreciationCommentList = nil
  self.bAppreciationReady = false
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_get_review_panel_comment_info_req(mod_id)
end
function logic_ugc_work_detail_featured_comment:on_ugc_get_review_panel_comment_info_rsp(mod_id, comment_list)
  if not self.modID or self.modID <= 0 then
    self.modID = mod_id
  end
  if self.modID == mod_id then
    self.AppreciationCommentList = comment_list
  end
  self.bAppreciationReady = true
  self:TrySetData()
end
function logic_ugc_work_detail_featured_comment:TrySetData()
  if self.bMetaDataReady and self.bAppreciationReady and self.modInfo then
    log(bWriteLog and "logic_ugc_work_detail_featured_comment:TrySetData success")
    self:SetData(self.modID, self.modInfo)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_APPRECIATIONGROUP_COMMENT_RSP, self.modID)
    return
  end
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:TrySetData failed bMetaDataReady:" .. tostring(self.bMetaDataReady) .. " bAppreciationReady:" .. tostring(self.bAppreciationReady) .. " modInfo:" .. tostring(self.modInfo) .. "")
end
function logic_ugc_work_detail_featured_comment:SetAppreciationNotRequired()
  self.AppreciationCommentList = nil
  self.bAppreciationReady = true
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:SetAppreciationNotRequired bAppreciationReady:" .. tostring(self.bAppreciationReady))
end
function logic_ugc_work_detail_featured_comment:send_ugc_review_panel_del_comment_req(mod_id)
  local title = LocUtil.GetLocalizeResStr(101001)
  local msg = LocUtil.GetLocalizeResStr(64054)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, msg, function()
    local UgcHandler = require("client.network.Protocol.UgcHandler")
    UgcHandler.send_ugc_review_panel_del_comment_req(mod_id)
  end)
end
function logic_ugc_work_detail_featured_comment:on_ugc_review_panel_del_comment_rsp(mod_id)
  local comment_uid = tonumber(DataMgr.roleData.uid)
  self:DeleteAppreciationComment(comment_uid)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_FEATURED_COMMENT)
end
function logic_ugc_work_detail_featured_comment:send_ugc_review_panel_support_comment_req(mod_id, comment_id, opt_type, opt_obj)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_review_panel_support_comment_req(mod_id, comment_id, opt_type, opt_obj)
end
function logic_ugc_work_detail_featured_comment:on_ugc_review_panel_support_comment_rsp(mod_id, comment_uid, opt_type, opt_obj, timestamp)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  if opt_obj == logic_ugc_comment_macro.SupportOptTarget.Comment then
    self:UpdateAppreciationSupportComment(mod_id, comment_uid, opt_type, timestamp)
  elseif opt_obj == logic_ugc_comment_macro.SupportOptTarget.Reply then
    self:UpdateAppreciationSupportReply(mod_id, comment_uid, opt_type, timestamp)
  end
end
function logic_ugc_work_detail_featured_comment:send_ugc_review_panel_top_comment_req(mod_id, comment_uid, opt_type)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_review_panel_top_comment_req(mod_id, comment_uid, opt_type)
end
function logic_ugc_work_detail_featured_comment:on_ugc_review_panel_top_comment_rsp(mod_id, comment_uid, opt_type, old_comment_uid)
  local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
  self:SetAppreciationCommentTop(comment_uid, opt_type == 0)
  if old_comment_uid then
    self:SetAppreciationCommentTop(old_comment_uid, false)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SET_TOP_APPRECIATION_COMMENT_RSP, comment_uid, opt_type)
  if opt_type == logic_ugc_comment_macro.TopOptType.Top then
    ShowNotice(64311)
  else
    ShowNotice(64313)
  end
end
function logic_ugc_work_detail_featured_comment:send_ugc_review_panel_reply_comment_req(mod_id, comment_uid, reply_content)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_review_panel_reply_comment_req(mod_id, comment_uid, reply_content)
end
function logic_ugc_work_detail_featured_comment:on_ugc_review_panel_reply_comment_rsp(mod_id, comment_uid, author_reply_content)
  self:SetAppreciationCommentAuthorReply(comment_uid, author_reply_content)
  ShowNotice(64083)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REPLY_APPRECIATION_COMMENT_RSP, comment_uid)
end
function logic_ugc_work_detail_featured_comment:send_ugc_review_panel_del_reply_comment_req(mod_id, comment_uid)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_review_panel_del_reply_comment_req(mod_id, comment_uid)
end
function logic_ugc_work_detail_featured_comment:on_ugc_review_panel_del_reply_comment_rsp(mod_id, comment_uid)
  self:DeleteAppreciationCommentAuthorReply(comment_uid)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_REPLY_COMMENT_RSP, comment_uid)
end
function logic_ugc_work_detail_featured_comment:SortCommentList()
  if not next(self.sortedCommentList) then
    return
  end
  table.sort(self.sortedCommentList, function(a, b)
    local appreciationA = a.comment.is_appreciation_comment or false
    local appreciationB = b.comment.is_appreciation_comment or false
    local appreciationTopA = appreciationA and a.comment.is_set_top or false
    local appreciationTopB = appreciationB and b.comment.is_set_top or false
    local normalTopA = not appreciationA and (a.comment.is_set_top or false)
    local normalTopB = not appreciationB and (b.comment.is_set_top or false)
    if appreciationTopA ~= appreciationTopB then
      return appreciationTopA
    end
    if normalTopA ~= normalTopB then
      return normalTopA
    end
    if appreciationA ~= appreciationB then
      return appreciationA
    end
    if a.comment.support_count ~= b.comment.support_count then
      return a.comment.support_count > b.comment.support_count
    end
    return a.comment.comment_time > b.comment.comment_time
  end)
end
function logic_ugc_work_detail_featured_comment:SortByLikes(sortedCommentList)
  table.sort(sortedCommentList, function(a, b)
    local priorityResult = self:CompareSpecialPriorityLevel(a, b)
    if priorityResult ~= nil then
      return priorityResult
    end
    a.comment.history_play_time = a.comment.history_play_time or 0
    b.comment.history_play_time = b.comment.history_play_time or 0
    if a.comment.history_play_time == b.comment.history_play_time then
      return (a.comment.support_count or 0) > (b.comment.support_count or 0)
    else
      return (a.comment.history_play_time or 0) > (b.comment.history_play_time or 0)
    end
  end)
end
function logic_ugc_work_detail_featured_comment:SortsupportLikes(sortedCommentList)
  table.sort(sortedCommentList, function(a, b)
    local priorityResult = self:CompareSpecialPriorityLevel(a, b)
    if priorityResult ~= nil then
      return priorityResult
    end
    if a.comment.support_count == b.comment.support_count then
      return (a.comment.comment_time or 0) > (b.comment.comment_time or 0)
    else
      return (a.comment.support_count or 0) > (b.comment.support_count or 0)
    end
  end)
end
function logic_ugc_work_detail_featured_comment:SortcommenttimeLikes(sortedCommentList)
  table.sort(sortedCommentList, function(a, b)
    local priorityResult = self:CompareSpecialPriorityLevel(a, b)
    if priorityResult ~= nil then
      return priorityResult
    end
    a.comment.author_reply_time = a.comment.author_reply_time or 0
    b.comment.author_reply_time = b.comment.author_reply_time or 0
    if a.comment.author_reply_time and b.comment.author_reply_time then
      return (a.comment.author_reply_time or 0) > (b.comment.author_reply_time or 0)
    elseif a.comment.author_reply_time then
      return true
    elseif b.comment.author_reply_time then
      return false
    else
      return (a.comment.comment_time or 0) > (b.comment.comment_time or 0)
    end
  end)
end
function logic_ugc_work_detail_featured_comment:SortreplytimeLikes(sortedCommentList)
  table.sort(sortedCommentList, function(a, b)
    local priorityResult = self:CompareSpecialPriorityLevel(a, b)
    if priorityResult ~= nil then
      return priorityResult
    end
    return (a.comment.comment_time or 0) > (b.comment.comment_time or 0)
  end)
end
function logic_ugc_work_detail_featured_comment:SortCompRankLikes(sortedCommentList)
  table.sort(sortedCommentList, function(a, b)
    local priorityResult = self:CompareSpecialPriorityLevel(a, b)
    if priorityResult ~= nil then
      return priorityResult
    end
    local aScore = self:GetCompRankData(a)
    local bScore = self:GetCompRankData(b)
    return aScore > bScore
  end)
end
function logic_ugc_work_detail_featured_comment:GetCompRankData(data)
  local timeUtil = require("client.common.time_util")
  local serverTime = timeUtil.GetServerTimeInSec()
  local diffDateOri = math.abs(os.difftime(data.comment.comment_time, serverTime))
  local diffDate = math.floor(diffDateOri / 86400)
  local W_time = 1 / (1 + math.log(1 + diffDate, 10))
  local W_likes = math.min(1.0, data.comment.support_count / (5 + math.sqrt(diffDate)))
  local W_play = math.min(1.0, (data.comment.history_play_time or 0) / 60)
  local W_length = math.min(1.0, 1.0 / (1 + math.exp(-0.03 * ((data.comment.comment_text_len or 0) - 64))))
  local total = 0.3 * W_time + 0.25 * W_length + 0.3 * W_likes + 0.15 * W_play
  local totalStr = string.format("%.2f", total)
  local totalNumber = tonumber(totalStr) or 0
  log(bWriteLog and "logic_ugc_work_detail_featured_comment:GetCompRankData:" .. "-uid:" .. data.comment.uid .. "-comment_id:" .. (data.comment_id or 0) .. "-W_time:" .. W_time .. "-W_length:" .. W_length .. "-W_likes:" .. W_likes .. "-W_play:" .. W_play .. "-Total:" .. total .. "-TotalSTR:" .. totalStr)
  return totalNumber
end
function logic_ugc_work_detail_featured_comment:SortAppreciationFirst(sortedCommentList)
  table.sort(sortedCommentList, function(a, b)
    local priorityResult = self:CompareSpecialPriorityLevel(a, b)
    if priorityResult ~= nil then
      return priorityResult
    end
    if a.comment.support_count == b.comment.support_count then
      return (a.comment.comment_time or 0) > (b.comment.comment_time or 0)
    else
      return (a.comment.support_count or 0) > (b.comment.support_count or 0)
    end
  end)
end
function logic_ugc_work_detail_featured_comment:CompareSpecialPriorityLevel(a, b)
  local appreciationTopA = not (a.comment.is_appreciation_comment or false) or a.comment.is_set_top or false
  local appreciationTopB = not (b.comment.is_appreciation_comment or false) or b.comment.is_set_top or false
  if appreciationTopA ~= appreciationTopB then
    return appreciationTopA
  end
  local topA = a.comment.is_set_top or false
  local topB = b.comment.is_set_top or false
  if topA ~= topB then
    return topA
  end
  local appreciationA = a.comment.is_appreciation_comment or false
  local appreciationB = b.comment.is_appreciation_comment or false
  if appreciationA ~= appreciationB then
    return appreciationA
  end
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_work_detail_featured_comment = class(CModuleBase, nil, logic_ugc_work_detail_featured_comment)
return Clogic_ugc_work_detail_featured_comment