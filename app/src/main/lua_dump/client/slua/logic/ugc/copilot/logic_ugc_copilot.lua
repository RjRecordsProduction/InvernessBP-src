local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local Logic_UGC_Copilot = {}
function Logic_UGC_Copilot:DefineAndResetData()
  Logic_UGC_Copilot.__super.DefineAndResetData(self)
  self.bOpenLLMSceneEdit = false
  if self.SessionManager then
    self.SessionManager:ResetData()
  end
  if self.StateMachine then
    self.StateMachine:ResetData()
  end
  if self.OperationHandler then
    self.OperationHandler:ResetData()
  end
  if self.MessageHandler then
    self.MessageHandler:ResetData()
  end
  if self.QuotaManager then
    self.QuotaManager:DefineAndResetQuotaData()
  end
  if self.GenerateModelFeature then
    self.GenerateModelFeature:ResetData()
  end
  if self.PlacePrefabFeature then
    self.PlacePrefabFeature:ResetData()
  end
  if self.PrefabIconFeature then
    self.PrefabIconFeature:ResetData()
  end
end
function Logic_UGC_Copilot:OnInitialize()
  if self.SessionManager then
    self.SessionManager:OnInitialize()
  end
  if self.StateMachine then
    self.StateMachine:OnInitialize()
  end
  if self.OperationHandler then
    self.OperationHandler:OnInitialize()
  end
  if self.MessageHandler then
    self.MessageHandler:OnInitialize()
  end
  if self.QuotaManager then
    self.QuotaManager:OnInitialize()
  end
  if self.GenerateModelFeature then
    self.GenerateModelFeature:OnInitialize()
  end
  if self.PlacePrefabFeature then
    self.PlacePrefabFeature:OnInitialize()
  end
  if self.PrefabIconFeature then
    self.PrefabIconFeature:OnInitialize()
  end
end
function Logic_UGC_Copilot:RegistEvents()
  Logic_UGC_Copilot.__super.RegistEvents(self)
  if self.PlacePrefabFeature and self.PlacePrefabFeature.RegistEvents then
    self.PlacePrefabFeature:RegistEvents()
  end
  if self.GenerateModelFeature and self.GenerateModelFeature.RegistEvents then
    self.GenerateModelFeature:RegistEvents()
  end
end
function Logic_UGC_Copilot:RefreshOpenLLMChatV2(bOpenLLMChatV2)
  print(bWriteLog and "Logic_UGC_Copilot:RefreshOpenLLMChatV2 " .. tostring(bOpenLLMChatV2))
  if DataMgr and DataMgr.roleData then
    DataMgr.roleData.open_llm_chat_v2 = bOpenLLMChatV2
    self:OnSyncInfoUpdated()
  end
end
function Logic_UGC_Copilot:RefreshOpenLLMSceneEdit(bOpenLLMSceneEdit)
  print(bWriteLog and "Logic_UGC_Copilot:RefreshOpenLLMSceneEdit " .. tostring(bOpenLLMSceneEdit))
  self.bOpenLLMSceneEdit = bOpenLLMSceneEdit or false
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_TOPICCARD_REFRESH)
end
function Logic_UGC_Copilot:IsLLMSceneEditEnabled()
  return self.bOpenLLMSceneEdit or false
end
function Logic_UGC_Copilot:OnSyncInfoUpdated()
  print(bWriteLog and "Logic_UGC_Copilot:OnSyncInfoUpdated")
  local bOpenLLMChatV2 = DataMgr.roleData.open_llm_chat_v2
  local bOpenLLMSceneEdit = DataMgr.roleData.open_llm_scene_edit
  if bOpenLLMChatV2 then
    self.NetworkProtocolFeature:SetInterfaceVersion(2)
  else
    self.NetworkProtocolFeature:SetInterfaceVersion(1)
  end
end
function Logic_UGC_Copilot:OnLogin(bReLogin)
end
function Logic_UGC_Copilot:OnLogOut()
  self:DefineAndResetData()
end
function Logic_UGC_Copilot:OnClose()
  Logic_UGC_Copilot.__super.OnClose(self)
  if self.QuotaManager then
    self.QuotaManager:OnClose()
  end
  if self.StateMachine then
    self.StateMachine:ClearAllTimeouts()
  end
  if self.PrefabIconFeature then
    self.PrefabIconFeature:CleanupAllRequests()
  end
end
function Logic_UGC_Copilot:Initialize()
  return self.OperationHandler:Initialize()
end
function Logic_UGC_Copilot:SendMessage(content, is_new_chat, TLogContext, ExtInfo)
  if _G.bSendUGCLLM then
    local ID = "llm-chat-id-" .. tostring(os.time())
    self.MessageHandler:SimulateUserResponse({ret = 0}, nil, content, Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, ID)
    local utility = require("common.utility")
    xpcall(self.NetworkProtocolFeature.SendLLMReq, utility.ErrorMessageHandler, self.NetworkProtocolFeature, content)
    _G.CurrentTempChat    return 0
  end
  return self.OperationHandler:SendMessage(content, is_new_chat, TLogContext, ExtInfo)
end
function Logic_UGC_Copilot:SendDailyQuestionMsg(Questions)
  self.MessageHandler:SendDailyQuestionMsg(Questions)
end
function Logic_UGC_Copilot:SimulateAIResponse(errorData, cbData, responseContent)
  return self.MessageHandler:SimulateAIResponse(errorData, cbData, responseContent)
end
function Logic_UGC_Copilot:CommitLongTaskFinish(TraceID, result_code, msgtype, LocResParam)
  return self.StateMachine:CommitLongTaskFinish(TraceID, result_code, msgtype, LocResParam)
end
function Logic_UGC_Copilot:SendChatRatingReq(chat_id, trace_id, action)
  self.NetworkProtocolFeature:SendChatRatingReq(chat_id, trace_id, action)
  self:SetActiveChatReportData(chat_id, trace_id, action)
end
function Logic_UGC_Copilot:StartNewChat()
  return self.OperationHandler:StartNewChat()
end
function Logic_UGC_Copilot:StopChat(stopReason)
  return self.OperationHandler:StopChat(stopReason)
end
function Logic_UGC_Copilot:ClearCurrentChatContext(bAllowRedunantClear)
  return self.SessionManager:ClearCurrentChatContext(bAllowRedunantClear)
end
function Logic_UGC_Copilot:LoadHistoryChatInfo(chat_id)
  return self.OperationHandler:LoadHistoryChatInfo(chat_id)
end
function Logic_UGC_Copilot:FetchRecommendQuestions()
  return self.OperationHandler:FetchRecommendQuestions()
end
function Logic_UGC_Copilot:JumpUrl(Url)
  print(bWriteLog and "Logic_UGC_Copilot:JumpUrl - called. Url: " .. Url)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_JUMP_URL, Url)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_Link, 0, Url)
  self:JumpLobbyUI(Url)
end
function Logic_UGC_Copilot:JumpLobbyUI(url)
  if GameStatus and GameStatus.IsInFightingNotMainCity() then
    return
  end
  local mName = url.match(url, "^(.-)://")
  if mName ~= "game" then
    print(bWriteLog and "Logic_UGC_Copilot:JumpLobbyUI not game")
    ShowNotice(17005207)
    return
  end
  GlobalData.JumpUrl(url)
end
function Logic_UGC_Copilot:SetActiveChatReportData(chatID, traceID, action)
  self.MessageHandler:SetActiveChatReportData(chatID, traceID, action)
end
function Logic_UGC_Copilot:GetCurrentState()
  return self.StateMachine:GetCurrentState()
end
function Logic_UGC_Copilot:GetActiveTraceID()
  return self.StateMachine:GetActiveTraceID()
end
function Logic_UGC_Copilot:GetCurrentChatID()
  return self.SessionManager:GetCurrentChatID()
end
function Logic_UGC_Copilot:GetActiveChatData()
  return self.SessionManager:GetActiveChatData()
end
function Logic_UGC_Copilot:GetActiveChatMessages()
  return self.SessionManager:GetActiveChatMessages()
end
function Logic_UGC_Copilot:GetActiveAIMessage()
  return self.SessionManager:GetActiveAIMessage()
end
function Logic_UGC_Copilot:GetRecentActiveChatMessages(count, roleFilter)
  local messages = self.SessionManager:GetActiveChatMessages()
  local chatId = self.SessionManager:GetCurrentChatID()
  if not messages or #messages == 0 then
    log(bWriteLog and "Logic_UGC_Copilot:GetRecentActiveChatMessages - No active chat messages")
    return {}, chatId
  end
  local result = {}
  if roleFilter then
    for _, msg in ipairs(messages) do
      if msg.Role == roleFilter then
        table.insert(result, msg)
      end
    end
  else
    for _, msg in ipairs(messages) do
      table.insert(result, msg)
    end
  end
  local aiMessage = self.SessionManager:GetActiveAIMessage()
  if aiMessage and (not roleFilter or roleFilter == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant) then
    local aiTraceId = aiMessage.TraceID
    local alreadyIncluded = false
    for _, msg in ipairs(result) do
      if msg.TraceID == aiTraceId then
        alreadyIncluded = true
        break
      end
    end
    if not alreadyIncluded then
      table.insert(result, aiMessage)
    end
  end
  if count and 0 < count and count < #result then
    local startIdx = #result - count + 1
    local trimmedResult = {}
    for i = startIdx, #result do
      table.insert(trimmedResult, result[i])
    end
    result = trimmedResult
  end
  log(bWriteLog and string.format("Logic_UGC_Copilot:GetRecentActiveChatMessages - Returned %d messages, ChatID: %s", #result, tostring(chatId)))
  return result, chatId
end
function Logic_UGC_Copilot:GetLastUserMessage()
  local messages = self.SessionManager:GetActiveChatMessages()
  local chatId = self.SessionManager:GetCurrentChatID()
  if not messages or #messages == 0 then
    return nil, chatId
  end
  for i = #messages, 1, -1 do
    local msg = messages[i]
    if msg.Role == Config_UGC_Copilot.Enum_Copilot_RoleType.User then
      return msg, chatId
    end
  end
  return nil, chatId
end
function Logic_UGC_Copilot:GetLastAssistantMessage()
  local chatId = self.SessionManager:GetCurrentChatID()
  local aiMessage = self.SessionManager:GetActiveAIMessage()
  if aiMessage then
    return aiMessage, chatId
  end
  local messages = self.SessionManager:GetActiveChatMessages()
  if not messages or #messages == 0 then
    return nil, chatId
  end
  for i = #messages, 1, -1 do
    local msg = messages[i]
    if msg.Role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
      return msg, chatId
    end
  end
  return nil, chatId
end
function Logic_UGC_Copilot:GetLatestConversationPair()
  local lastUserMsg, chatId = self:GetLastUserMessage()
  local lastAssistantMsg = self:GetLastAssistantMessage()
  return lastUserMsg, lastAssistantMsg, chatId
end
function Logic_UGC_Copilot:GetChatMessageDetailInCache(chat_id)
  return self.SessionManager:GetChatMessageDetailInCache(chat_id)
end
function Logic_UGC_Copilot:GetChatIDByTraceID(trace_id)
  return self.SessionManager:GetChatIDByTraceID(trace_id)
end
function Logic_UGC_Copilot:GetCurrentSubsceneID()
  return self.OperationHandler:GetCurrentSubsceneID()
end
function Logic_UGC_Copilot:SetCurrentSubsceneID(subsceneID)
  self.OperationHandler:SetCurrentSubsceneID(subsceneID)
end
function Logic_UGC_Copilot:ClearCurrentSubsceneID()
  self.OperationHandler:ClearCurrentSubsceneID()
end
function Logic_UGC_Copilot:GetCopyTextByTraceID(trace_id)
  if not trace_id then
    log(bWriteLog and "Logic_UGC_Copilot:GetCopyTextByTraceID - trace_id is nil")
    return nil
  end
  local messageDetail = self.SessionManager:GetMessageDetailByTraceId(trace_id)
  if not messageDetail then
    log(bWriteLog and string.format("Logic_UGC_Copilot:GetCopyTextByTraceID - Message not found for TraceID: %s", trace_id))
    return nil
  end
  if not messageDetail.Content or type(messageDetail.Content) ~= "table" then
    log(bWriteLog and string.format("Logic_UGC_Copilot:GetCopyTextByTraceID - Invalid Content for TraceID: %s", trace_id))
    return nil
  end
  local copyTexts = {}
  for _, contentItem in ipairs(messageDetail.Content) do
    if contentItem.type and contentItem.content then
      local messageConfig = Config_UGC_Copilot.GetCopilotMessageTypeConfig(contentItem.type)
      if messageConfig and messageConfig.GetCopyText then
        local copyText = messageConfig.GetCopyText(contentItem.content)
        if copyText and copyText ~= "" then
          table.insert(copyTexts, copyText)
        end
      end
    end
  end
  if 0 < #copyTexts then
    local result = table.concat(copyTexts, [[
]])
    log(bWriteLog and string.format("Logic_UGC_Copilot:GetCopyTextByTraceID - Generated copy text for TraceID: %s, length: %d", trace_id, #result))
    return result
  end
  log(bWriteLog and string.format("Logic_UGC_Copilot:GetCopyTextByTraceID - No copyable content for TraceID: %s", trace_id))
  return nil
end
function Logic_UGC_Copilot:IsInitializationComplete()
  return self.StateMachine:IsInitializationComplete()
end
function Logic_UGC_Copilot:IsLoadingHistory()
  return self.StateMachine:IsLoadingHistory()
end
function Logic_UGC_Copilot:IsStreamingChatStoppable()
  return self.StateMachine:IsStreamingChatStoppable()
end
function Logic_UGC_Copilot:IsChatIdle()
  return self.StateMachine:IsChatIdle()
end
function Logic_UGC_Copilot:IsLongTaskRunning()
  return self:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.LONG_TASK_RUNNING
end
function Logic_UGC_Copilot:HasActiveChat()
  return self.SessionManager:HasActiveChat()
end
function Logic_UGC_Copilot:HasAnyChat()
  return self.SessionManager:HasAnyChat()
end
function Logic_UGC_Copilot:FindNextUnloadedChat(current_chat_id)
  return self.SessionManager:FindNextUnloadedChat(current_chat_id)
end
function Logic_UGC_Copilot:IsMessageExceedMaxLimit(Content)
  return self.MessageHandler:IsMessageExceedMaxLimit(Content)
end
function Logic_UGC_Copilot:UpdateInteractionStatus(traceId, seqId, status)
  if not traceId or not seqId then
    print(bWriteLog and "Logic_UGC_Copilot:UpdateInteractionStatus - Invalid parameters")
    return false
  end
  local seqIdNum = tonumber(seqId)
  if not seqIdNum then
    print(bWriteLog and "Logic_UGC_Copilot:UpdateInteractionStatus - Invalid seqId")
    return false
  end
  local CurrentDetail = self.SessionManager:GetTraceDetailByKey(traceId, Config_UGC_Copilot.MessageDetailKeyEnum.InteractionDetails) or {}
  local interactionData = CurrentDetail[seqIdNum]
  if interactionData then
    interactionData.    self.SessionManager:SetTraceDetailByKey(traceId, Config_UGC_Copilot.MessageDetailKeyEnum.InteractionDetails, CurrentDetail)
    print(bWriteLog and string.format("Logic_UGC_Copilot:UpdateInteractionStatus - Updated TraceID: %s, SeqID: %s, Status: %s", tostring(traceId), tostring(seqId), tostring(status)))
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_INTERACTION_STATUS_UPDATE, traceId, seqIdNum, status)
    return true
  else
    print(bWriteLog and string.format("Logic_UGC_Copilot:UpdateInteractionStatus - Interaction not found: TraceID: %s, SeqID: %s", tostring(traceId), tostring(seqId)))
    return false
  end
end
function Logic_UGC_Copilot:GetInteractionStatus(traceId, seqId)
  if not traceId or not seqId then
    return nil
  end
  local seqIdNum = tonumber(seqId)
  if not seqIdNum then
    return nil
  end
  local CurrentDetail = self.SessionManager:GetTraceDetailByKey(traceId, Config_UGC_Copilot.MessageDetailKeyEnum.InteractionDetails) or {}
  local interactionData = CurrentDetail[seqIdNum]
  if interactionData then
    return interactionData.status or Config_UGC_Copilot.InteractionStatusEnum.Pending
  end
  return nil
end
function Logic_UGC_Copilot:IsTraceIdRevoked(traceId)
  self.StateMachine:IsTraceIdRevoked(traceId)
end
function Logic_UGC_Copilot:GetMaxMessagesPerChat()
  return Config_UGC_Copilot.Copilot_Consts.MAX_MESSAGES_PER_CHAT
end
function Logic_UGC_Copilot:IsDebugMode()
  if _G.UGCCopliotDebugMode then
    return true
  end
  if Config_UGC_Copilot.bForceOpenDebugMode then
    return true
  end
  if self:IsLocalBoot() then
    return true
  end
  return false
end
function Logic_UGC_Copilot:IsLocalBoot()
  if Client then
    if not Client.IsDevelopment() then
      return false
    end
    local uid = DataMgr.roleData.uid
    return uid == ""
  end
  return false
end
function Logic_UGC_Copilot:OnHistorySessionsRsp(sessions, map_id)
  self.NetworkProtocolFeature:OnHistorySessionsRsp(sessions, map_id)
end
function Logic_UGC_Copilot:OnChatMsgRsp(err, rsp_data, chat_id, map_id)
  self.NetworkProtocolFeature:OnChatMsgRsp(err, rsp_data, chat_id, map_id)
end
function Logic_UGC_Copilot:OnAIMessageNetworkRsp(err, event, data, cb_data)
  self.NetworkProtocolFeature:OnAIMessageNetworkRsp(err, event, data, cb_data)
end
function Logic_UGC_Copilot:OnLLMQuotaRsp(quota_data)
  if self.StateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING then
    self.StateMachine:SetInitRequestComplete("LLMQuotaRsp")
  end
  self.QuotaManager:OnLLMQuotaRsp(quota_data)
end
function Logic_UGC_Copilot:IsQuotaSysEnabled()
  if self.NetworkProtocolFeature:GetInterfaceVersion() == 2 then
    return false
  end
  return true
end
function Logic_UGC_Copilot:OnchatStopRsp(trace_id, ret)
  self.OperationHandler:OnchatStopRsp(trace_id, ret)
end
function Logic_UGC_Copilot:HandleNetworkError(ErrCode, Reason)
  print(bWriteLog and "Logic_UGC_Copilot:HandleNetworkError - called. ErrCode: " .. ErrCode .. " Reason: " .. Reason)
  if ErrCode == 0 then
    return
  end
  local Text = LocUtil.GetLocalizeResStr(511070) .. "(" .. ErrCode .. ")"
  if ErrCode == 511103 then
    Text = LocUtil.GetLocalizeResStr(8500487)
    print(bWriteLog and "Logic_UGC_Copilot:JumpLobbyUI UsedToday = " .. tostring(self.QuotaManager.LLMQuota.UsedToday))
    self.QuotaManager.LLMQuota.UsedToday = self.QuotaManager.LLMQuota.UsedToday - 1
  end
  ShowNotice(Text)
  self.StateMachine:HandleError(Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NETWORK, "HandleNetworkError: " .. Reason .. tostring(ErrCode))
  if self.OperationHandler then
    self.OperationHandler.bStopPending = false
  end
end
function Logic_UGC_Copilot:SendUGCLLMReportReq(chat_id, trace_id, SelectedReason, _sInputBoxContent)
  self.NetworkProtocolFeature:SendUgcLlmReportReq(chat_id, trace_id, SelectedReason, _sInputBoxContent)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eUGCAICopilotReportData
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  if not savedData[chat_id] then
    savedData[chat_id] = {}
  end
  savedData[chat_id][trace_id] = true
  if not savedData.trash then
    savedData.trash = {}
  end
  savedData.trash[trace_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(savedData, fileType)
  local Messages = self.SessionManager:GetChatMessageDetailInCache(chat_id) or self.SessionManager:GetActiveChatData().Messages
  if Messages then
    print("Logic_UGC_Copilot:SendUGCLLMReportReq mark chat to deleted,", chat_id)
    for _, Msg in pairs(Messages) do
      if Msg.TraceID == trace_id and Msg.Role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
        Msg.feedback = Msg.feedback or {}
        Msg.feedback.Report = 1
        EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REPORTED, chat_id, Msg)
        return
      end
    end
  end
end
function Logic_UGC_Copilot:HandleResourceFinishNtf(ntf_data)
  if not ntf_data or type(ntf_data) ~= "table" then
    print("Error: Invalid ntf_data parameter")
    return nil
  end
  print("=== UGC Resource Completion Notification Data ===")
  print("user_id:", ntf_data.user_id or "nil")
  print("trace_id:", ntf_data.trace_id or "nil")
  print("map_id:", ntf_data.map_id or "nil")
  print("chat_id:", ntf_data.chat_id or "nil")
  print("msg_time:", ntf_data.msg_time or "nil")
  print("type:", ntf_data.type or "nil")
  print("result:", ntf_data.result or "nil")
  print("error_msg:", ntf_data.error_msg or "nil")
  if ntf_data.result ~= nil and ntf_data.result ~= 0 then
    print("Error: Invalid result code")
    ShowDevNotice("(Dev) Error: HandleResourceFinishNtf " .. tostring(ntf_data.error_msg))
  end
  if not (ntf_data.user_id and ntf_data.trace_id) or not ntf_data.type then
    print("Error: HandleResourceFinishNtf " .. tostring(ntf_data))
    return nil
  end
  local NtfTraceID = ntf_data.trace_id
  local NtfMapID = ntf_data.map_id
  if self.StateMachine.CurrentLongTaskContext == nil then
    print(bWriteLog and "Logic_UGC_Copilot:HandleResourceFinishNtf No CurrentLongTaskContext")
    return
  end
  local LongTaskCtx = self.StateMachine.CurrentLongTaskContext
  if NtfTraceID ~= LongTaskCtx.trace_id then
    print(bWriteLog and "Logic_UGC_Copilot:HandleResourceFinishNtf InEqual TraceID")
    return
  end
  if self.StateMachine:IsMessageStale(nil, ntf_data.trace_id) then
    print(bWriteLog and "Logic_UGC_Copilot:HandleResourceFinishNtf Stale")
    return
  end
  if NtfMapID ~= self.SessionManager:GetMapID() then
    print(bWriteLog and "Logic_UGC_Copilot:HandleResourceFinishNtf InEqual MapID")
    return
  end
  local result_code = ntf_data.result or 0
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_LONGTASK_NOTIFY, ntf_data.trace_id, result_code, ntf_data)
  if result_code ~= 0 then
    print("Processing failed, error message:", ntf_data.error_msg or "Unknown error")
    self:CommitLongTaskFinish(ntf_data.trace_id, result_code, ntf_data.type)
    return nil
  end
  self:CommitLongTaskFinish(ntf_data.trace_id, result_code, ntf_data.type)
  if not ntf_data.content or type(ntf_data.content) ~= "table" or #ntf_data.content == 0 then
    print("Error: Invalid or empty content field")
    return nil
  end
  local processed_resources = {}
  local resource_type = ntf_data.type or "unknown"
  if Config_UGC_Copilot.HandleResourceFinish(ntf_data) then
    log(bWriteLog and string.format("Resource finish handled by config for type: %s", tostring(resource_type)))
    return
  end
  log(bWriteLog and string.format("Unknown resource type: %s", tostring(resource_type)))
  if #processed_resources == 0 then
    print("Warning: No valid resources processed")
    return nil
  end
end
function Logic_UGC_Copilot:SimulateAdvancedMessage(TraceID, TType, Data, ExtData)
  self.MessageHandler:SimulateAdvancedMessage(TraceID, TType, Data, ExtData)
end
function Logic_UGC_Copilot:CheckWoWCopilotDisplay()
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  log(bWriteLog and string.format("Logic_UGC_Copilot:CheckWoWCopilotDisplay bWoWCopilotDisplay = %s", tostring(LogicSettingBasic.bWoWCopilotDisplay)))
  return LogicSettingBasic.bWoWCopilotDisplay
end
function Logic_UGC_Copilot:GetAgreementText()
  if self.NetworkProtocolFeature:GetInterfaceVersion() == 1 then
    return LocUtil.GetLocalizeResStr(17005224)
  end
  return LocUtil.GetLocalizeResStr(17005227)
end
function Logic_UGC_Copilot:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[edward] Logic_UGC_Copilot:OnPreSwitchGameStatus")
  self.workReachTlogTimestamp = nil
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if LogicUGC and LogicUGC:IsUGCGameMod() then
      self:DefineAndResetData()
    end
  elseif nextState == GameStatus.Lobby then
    self:DefineAndResetData()
  end
  self:RemoveAllTimer()
end
function Logic_UGC_Copilot:ClearChatHistory()
  return self.SessionManager:ClearChatHistory()
end
function Logic_UGC_Copilot:OnCodeExecuteResult(result, args)
  print(bWriteLog and "Logic_UGC_Copilot:OnCodeExecuteResult")
  self.OperationHandler:OnCodeExecuteResult(result, args)
end
function Logic_UGC_Copilot:Debug_StoreUGCHistoryToLocalBinaryFile()
  return self.SessionManager:Debug_StoreUGCHistoryToLocalBinaryFile()
end
function Logic_UGC_Copilot:Debug_LoadLocalBinaryFile()
  return self.SessionManager:Debug_LoadLocalBinaryFile()
end
local NamedFeatures = {
  QuotaManager = "client.slua.logic.ugc.copilot.quota_management_feature",
  NetworkProtocolFeature = "client.slua.logic.ugc.copilot.network_protocol_feature",
  SessionManager = "client.slua.logic.ugc.copilot.chat_session_manager",
  StateMachine = "client.slua.logic.ugc.copilot.state_machine_manager",
  OperationHandler = "client.slua.logic.ugc.copilot.chat_operation_handler",
  MessageHandler = "client.slua.logic.ugc.copilot.message_handler",
  GenerateModelFeature = "client.slua.logic.ugc.copilot.generate_model_feature",
  PlacePrefabFeature = "client.slua.logic.ugc.copilot.place_prefab_feature.place_prefab_feature",
  PrefabIconFeature = "client.slua.logic.ugc.copilot.place_prefab_feature.prefab_icon_feature",
  PromptFeature = "client.slua.logic.ugc.copilot.prompt_feature"
}
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_Copilot = class(CModuleBase, nil, Logic_UGC_Copilot)
return require("combine_class").GenerateNamedFeatureClass(CLogic_UGC_Copilot, NamedFeatures)