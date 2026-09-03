local ChatOperationHandler = {Owner = nil, DebugHooks = nil}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local _GetRequestSceneID = function()
  if GameStatus and GameStatus.IsInLobbyOrMainCity and GameStatus.IsInLobbyOrMainCity() then
    return Config_UGC_Copilot.Enum_UGC_LLM_RequestSceneID.NonFight
  end
  if IsWoWEditor then
    return Config_UGC_Copilot.Enum_UGC_LLM_RequestSceneID.WoWEditor
  end
  return Config_UGC_Copilot.Enum_UGC_LLM_RequestSceneID.Fight
end
local C_NOT_INTEREST_ERRCODE = {
  [Config_UGC_Copilot.EnumServerChatErrorCode.UserSensitiveWord] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.ModelSensitiveWord] = true
}
local C_UIGEN_ERRCODE = {
  [Config_UGC_Copilot.EnumServerChatErrorCode.UnknownErrorCommon] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.TextAuditRejected] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.ImageAuditRejected] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.AuditTimeout] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.AuditServiceError] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenProcessError] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenRequestError] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenImageGenError] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenImageUploadError] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenConvertError] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenConvertTimeout] = true,
  [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenDslInvalid] = true
}
local C_RATE_LIMIT_USAGE_EXCEEDED_TEXT_ID = 2026051150
local C_STOP_CHAT_SEND_COOLDOWN_SECONDS = 15
local C_STOP_CHAT_COOLDOWN_REPLY_TEXT_ID = 2026060804
local _FinishHistoryInitAsEmpty = function(owner, reason)
  local stateMachine = owner and owner.StateMachine
  local sessionManager = owner and owner.SessionManager
  if not stateMachine or not sessionManager then
    return false
  end
  local currentState = stateMachine:GetCurrentState()
  if currentState == Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING then
    log(bWriteLog and string.format("ChatOperationHandler:_FinishHistoryInitAsEmpty during init. reason=%s", tostring(reason)))
    sessionManager.ChatHistory = sessionManager.ChatHistory or {}
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HISTORY_UPDATE, sessionManager.ChatHistory)
    stateMachine:SetInitRequestComplete("History")
    return true
  end
  if currentState == Config_UGC_Copilot.Enum_UGC_LLM_State.HISTORY_LOADING then
    log(bWriteLog and string.format("ChatOperationHandler:_FinishHistoryInitAsEmpty during history loading. reason=%s", tostring(reason)))
    stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "HistoryLoadFailed")
    return true
  end
  return false
end
local _IsActiveUIGenLongTask = function(owner, traceId)
  if not (owner and owner.StateMachine and traceId) or traceId == "" then
    return false
  end
  local longTaskContext = owner.StateMachine:GetCurrentLongTaskContext()
  local precheck = longTaskContext and longTaskContext.precheck
  local genPrecheck = precheck and precheck.gen_precheck
  if not genPrecheck then
    return false
  end
  if longTaskContext.trace_id ~= traceId then
    return false
  end
  return genPrecheck.gen_type == Config_UGC_Copilot.Enum_Copilot_MessageType.ChatUIDsl
end
local _TryNotifyUIGenProgressFinish = function(owner, traceId)
  if not _IsActiveUIGenLongTask(owner, traceId) then
    return false
  end
  local ntfData = {
    trace_id = traceId,
    type = Config_UGC_Copilot.Enum_Copilot_MessageType.ChatUIDsl,
    result = 0
  }
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_LONGTASK_NOTIFY, traceId, 0, ntfData)
  return true
end
local _TryCommitUIGenLongTaskFinish = function(owner, traceId)
  if not _IsActiveUIGenLongTask(owner, traceId) then
    return false
  end
  owner:CommitLongTaskFinish(traceId, 0, Config_UGC_Copilot.Enum_Copilot_MessageType.ChatUIDsl)
  return true
end
local _IsActiveBlockyLuaLongTask = function(owner, traceId)
  if not (owner and owner.StateMachine and traceId) or traceId == "" then
    return false
  end
  local longTaskContext = owner.StateMachine:GetCurrentLongTaskContext()
  local precheck = longTaskContext and longTaskContext.precheck
  local genPrecheck = precheck and precheck.gen_precheck
  if not genPrecheck then
    return false
  end
  if longTaskContext.trace_id ~= traceId then
    return false
  end
  return genPrecheck.gen_type == Config_UGC_Copilot.Enum_Copilot_MessageType.BlockyEdit
end
local _TryNotifyBlockyLuaProgressFinish = function(owner, traceId)
  if not _IsActiveBlockyLuaLongTask(owner, traceId) then
    return false
  end
  local ntfData = {
    trace_id = traceId,
    type = Config_UGC_Copilot.Enum_Copilot_MessageType.BlockyEdit,
    result = 0
  }
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_LONGTASK_NOTIFY, traceId, 0, ntfData)
  return true
end
local _TryCommitBlockyLuaLongTaskFinish = function(owner, traceId)
  if not _IsActiveBlockyLuaLongTask(owner, traceId) then
    return false
  end
  owner:CommitLongTaskFinish(traceId, 0, Config_UGC_Copilot.Enum_Copilot_MessageType.BlockyEdit)
  return true
end
function ChatOperationHandler:ctor()
end
function ChatOperationHandler:OnInitialize()
  self:ResetData()
end
function ChatOperationHandler:ResetData()
  self.CacheTlogContext = nil
  self.bStopPending = false
  self.bStopPendingIsSend = false
  self.LastSendMessageTime = 0
  self.LastStopChatTime = 0
  self.StopCooldownSimulatedSeq = 0
  self.PendingRequestMapID = nil
  self.PendingRequestChatID = nil
  self.RateLimitedTraceID = nil
  self.CurrentSubsceneID = nil
end
function ChatOperationHandler:GetCurrentSubsceneID()
  return self.CurrentSubsceneID
end
function ChatOperationHandler:SetCurrentSubsceneID(subsceneID)
  log(bWriteLog and string.format("ChatOperationHandler:SetCurrentSubsceneID - subsceneID: %s", tostring(subsceneID)))
  self.CurrentSubsceneID = subsceneID
end
function ChatOperationHandler:ClearCurrentSubsceneID()
  log(bWriteLog and "ChatOperationHandler:ClearCurrentSubsceneID")
  self.CurrentSubsceneID = nil
end
function ChatOperationHandler:_FormatRateLimitAvailableTime(nextAvailableTime)
  local timestamp = tonumber(nextAvailableTime)
  if not timestamp or timestamp <= 0 then
    return nil
  end
  return os.date("%Y-%m-%d %H:%M", timestamp)
end
function ChatOperationHandler:_BuildRateLimitReplyMessage(data)
  data = data or {}
  local maxUsage = tonumber(data.max_usage) or 10
  local availableTime = self:_FormatRateLimitAvailableTime(data.next_available_time) or ""
  return LocUtil.LocalizeResFormat(C_RATE_LIMIT_USAGE_EXCEEDED_TEXT_ID, maxUsage, availableTime)
end
function ChatOperationHandler:ShowRateLimitReplyMessage(traceID, message)
  local messageHandler = self.Owner and self.Owner.MessageHandler
  if not messageHandler or not messageHandler.SimulateAdvancedMessage then
    log(bWriteLog and "ChatOperationHandler:ShowRateLimitReplyMessage - MessageHandler unavailable")
    return
  end
  local replyTraceID = traceID and tostring(traceID) .. "_rate_limit" or "rate_limit_" .. tostring(os.time())
  messageHandler:SimulateAdvancedMessage(replyTraceID, Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, message, {
    HideFeedback = true,
    HideMessageBG = false,
    ClearContent = true
  })
end
function ChatOperationHandler:IsInStopChatSendCooldown()
  local lastStopTime = tonumber(self.LastStopChatTime) or 0
  if lastStopTime <= 0 then
    return false
  end
  return os.time() - lastStopTime < C_STOP_CHAT_SEND_COOLDOWN_SECONDS
end
function ChatOperationHandler:_AllocStopCooldownTraceID()
  self.StopCooldownSimulatedSeq = (self.StopCooldownSimulatedSeq or 0) + 1
  return string.format("stop_cooldown_%d_%d", os.time(), self.StopCooldownSimulatedSeq)
end
function ChatOperationHandler:EnterStopChatSendCooldown(reason)
  self.LastStopChatTime = os.time()
  log(bWriteLog and string.format("ChatOperationHandler:EnterStopChatSendCooldown reason=%s", tostring(reason)))
end
function ChatOperationHandler:SimulateStopCooldownReply(content, is_new_chat, ExtInfo)
  local stateMachine = self.Owner.StateMachine
  local sessionManager = self.Owner.SessionManager
  local messageHandler = self.Owner.MessageHandler
  local replyTraceID = self:_AllocStopCooldownTraceID()
  if (is_new_chat or not sessionManager:GetCurrentChatID()) and sessionManager:ClearCurrentChatContext(true) ~= 0 then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST
  end
  local currentChatID = sessionManager:GetCurrentChatID()
  if currentChatID then
    sessionManager.TraceID2ChatID[replyTraceID] = currentChatID
  end
  if not stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING, "SimulateStopCooldownReply") then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_TRANSITION
  end
  sessionManager:UpdateSessionActivity()
  messageHandler:OnUserMsgInput(content, ExtInfo)
  messageHandler:OnUserInputConfirmed(true)
  stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "SimulateStopCooldownReplyComplete")
  stateMachine:SetActiveTraceID(nil)
  local replyMessage = string.format("<resid>%d</>", C_STOP_CHAT_COOLDOWN_REPLY_TEXT_ID)
  local locUtilInst = rawget(_G, "LocUtil")
  if locUtilInst and type(locUtilInst.GetLocalizeResStr) == "function" then
    local bOk, localizeText = pcall(locUtilInst.GetLocalizeResStr, C_STOP_CHAT_COOLDOWN_REPLY_TEXT_ID)
    if bOk and localizeText ~= nil then
      replyMessage = tostring(localizeText)
    end
  end
  messageHandler:SimulateAdvancedMessage(replyTraceID, Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, replyMessage, {
    HideFeedback = true,
    HideMessageBG = false,
    ClearContent = true
  })
  self.PendingRequestMapID = nil
  self.PendingRequestChatID = nil
  self:ClearCurrentSubsceneID()
  return 0
end
function ChatOperationHandler:IsRateLimitFinish(cb_data)
  if not self.RateLimitedTraceID then
    return false
  end
  return cb_data and cb_data.trace_id == self.RateLimitedTraceID
end
function ChatOperationHandler:OnAIMessageRateLimit(data, cb_data)
  data = data or {}
  cb_data = cb_data or {}
  local traceID = cb_data.trace_id or data.trace_id
  self.RateLimitedTraceID = traceID
  self:EnterStopChatSendCooldown("OnAIMessageRateLimit")
  local replyMessage = self:_BuildRateLimitReplyMessage(data)
  log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageRateLimit - received rate limit. trace_id=%s chat_id=%s task_type=%s usage=%s/%s next_available_time=%s reason=%s reply_message=%s", tostring(traceID), tostring(cb_data.chat_id or data.chat_id), tostring(data.task_type), tostring(data.current_usage), tostring(data.max_usage), tostring(data.next_available_time), tostring(data.reason), tostring(replyMessage)))
  self.PendingRequestMapID = nil
  self.PendingRequestChatID = nil
  local stateMachine = self.Owner.StateMachine
  if not stateMachine:IsChatIdle() then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageRateLimit - transition to IDLE. current_state=%s trace_id=%s", tostring(stateMachine:GetCurrentState()), tostring(traceID)))
    stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "OnAIMessageRateLimit")
  end
  if not traceID or stateMachine.ActiveTraceID == traceID then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageRateLimit - clear active trace. active_trace_id=%s incoming_trace_id=%s", tostring(stateMachine.ActiveTraceID), tostring(traceID)))
    stateMachine:SetActiveTraceID(nil)
  end
  if self.Owner.MessageHandler and self.Owner.MessageHandler.OnUserInputConfirmed then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageRateLimit - confirm user message visible. trace_id=%s", tostring(traceID)))
    self.Owner.MessageHandler:OnUserInputConfirmed(true)
  end
  log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageRateLimit - show reply message. trace_id=%s", tostring(traceID)))
  self:ShowRateLimitReplyMessage(traceID, replyMessage)
  self:ClearCurrentSubsceneID()
end
function ChatOperationHandler:_NormalizeMapID(map_id)
  if map_id == nil then
    return nil
  end
  return tostring(map_id)
end
function ChatOperationHandler:IsCallbackForCurrentMap(cb_data)
  if not cb_data then
    return true
  end
  local callbackMapID = self:_NormalizeMapID(cb_data.map_id)
  if not callbackMapID then
    return true
  end
  local sessionManager = self.Owner and self.Owner.SessionManager
  local currentMapID = sessionManager and self:_NormalizeMapID(sessionManager:GetMapID()) or nil
  if not currentMapID then
    return true
  end
  return callbackMapID == currentMapID
end
function ChatOperationHandler:TryBindActiveTraceFromResponse(event, cb_data)
  if not cb_data or not cb_data.trace_id then
    return
  end
  local stateMachine = self.Owner.StateMachine
  if stateMachine.ActiveTraceID ~= nil then
    return
  end
  if stateMachine:GetCurrentState() ~= Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING then
    return
  end
  if self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Error) then
    return
  end
  stateMachine:SetActiveTraceID(cb_data.trace_id)
  if cb_data.chat_id then
    self.Owner.SessionManager.TraceID2ChatID[cb_data.trace_id] = cb_data.chat_id
  end
  log(bWriteLog and string.format("ChatOperationHandler:TryBindActiveTraceFromResponse - bind active trace_id: %s", tostring(cb_data.trace_id)))
end
function ChatOperationHandler:ShouldIgnoreErrorForTraceIsolation(cb_data)
  if not cb_data then
    return false
  end
  local stateMachine = self.Owner.StateMachine
  if cb_data.trace_id and stateMachine:IsTraceIdRevoked(cb_data.trace_id) then
    log(bWriteLog and string.format("ChatOperationHandler:Ignore error for revoked trace_id: %s", tostring(cb_data.trace_id)))
    return true
  end
  if cb_data.chat_id and cb_data.trace_id and stateMachine:IsMessageStale(cb_data.chat_id, cb_data.trace_id) then
    log(bWriteLog and string.format("ChatOperationHandler:Ignore stale error trace_id: %s", tostring(cb_data.trace_id)))
    return true
  end
  if cb_data.trace_id and stateMachine.ActiveTraceID and stateMachine.ActiveTraceID ~= cb_data.trace_id then
    log(bWriteLog and string.format("ChatOperationHandler:Ignore mismatched error trace_id. active=%s incoming=%s", tostring(stateMachine.ActiveTraceID), tostring(cb_data.trace_id)))
    return true
  end
  return false
end
function ChatOperationHandler:ShouldIgnoreErrorBeforeTraceBound(cb_data)
  local stateMachine = self.Owner.StateMachine
  if stateMachine.ActiveTraceID ~= nil then
    return false
  end
  if stateMachine:GetCurrentState() ~= Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING then
    return false
  end
  if not cb_data then
    log(bWriteLog and "ChatOperationHandler:Ignore error before trace bound - cb_data is nil")
    return true
  end
  local incomingTraceID = cb_data.trace_id
  local incomingChatID = cb_data.chat_id
  local incomingMapID = self:_NormalizeMapID(cb_data.map_id)
  local currentMapID = self:_NormalizeMapID(self.Owner.SessionManager:GetMapID())
  if incomingMapID and currentMapID and incomingMapID ~= currentMapID then
    log(bWriteLog and string.format("ChatOperationHandler:Ignore error before trace bound - map mismatch. current=%s incoming=%s", tostring(currentMapID), tostring(incomingMapID)))
    return true
  end
  if self.PendingRequestChatID and incomingChatID and tostring(self.PendingRequestChatID) ~= tostring(incomingChatID) then
    log(bWriteLog and string.format("ChatOperationHandler:Ignore error before trace bound - pending chat mismatch. pending=%s incoming=%s", tostring(self.PendingRequestChatID), tostring(incomingChatID)))
    return true
  end
  local lastActiveTraceID = stateMachine:GetLastActiveTraceID()
  if incomingTraceID and lastActiveTraceID and incomingTraceID == lastActiveTraceID then
    log(bWriteLog and string.format("ChatOperationHandler:Ignore error before trace bound - stale last trace. trace_id=%s", tostring(incomingTraceID)))
    return true
  end
  if not incomingTraceID then
    log(bWriteLog and "ChatOperationHandler:Ignore error before trace bound - missing trace_id")
    return true
  end
  return false
end
function ChatOperationHandler:SendMessage(content, is_new_chat, TLogContext, ExtInfo)
  local stateMachine = self.Owner.StateMachine
  local quotaManager = self.Owner.QuotaManager
  local sessionManager = self.Owner.SessionManager
  local messageHandler = self.Owner.MessageHandler
  if not stateMachine:IsChatIdle() and not self.Owner:IsLocalBoot() then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NOT_INITED
  end
  if self:IsInStopChatSendCooldown() then
    if messageHandler:IsMessageExceedMaxLimit(content) then
      return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_MESSAGE_TOO_LONG
    end
    return self:SimulateStopCooldownReply(content, is_new_chat, ExtInfo)
  end
  if quotaManager:IsLLMOutofQuota() and not self.Owner:IsLocalBoot() and self.Owner:IsQuotaSysEnabled() then
    quotaManager:ShowQuotaExceeded()
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_OUT_OF_QUOTA
  end
  if messageHandler:IsMessageExceedMaxLimit(content) then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_MESSAGE_TOO_LONG
  end
  if self.bStopPending then
    ShowNotice(LocUtil.GetLocalizeResStr(8500487))
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST
  end
  local NowTime = os.time()
  if NowTime - self.LastSendMessageTime < 3 then
    ShowNotice(LocUtil.GetLocalizeResStr(8500487))
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST
  end
  self.LastSendMessageTime = NowTime
  stateMachine:MarkRequestStart()
  sessionManager:_CheckMessageLimitAndStartNewSession(ExtInfo)
  sessionManager:UpdateSessionActivity()
  self.CacheTlogContext = TLogContext
  if is_new_chat or not sessionManager:GetCurrentChatID() then
    self:StartNewChatInnerWithMsg(content, ExtInfo)
  else
    self:ContinueChatInner(sessionManager:GetCurrentChatID(), content, ExtInfo)
  end
  return 0
end
function ChatOperationHandler:StartNewChatInnerWithMsg(content, ExtInfo)
  local stateMachine = self.Owner.StateMachine
  local sessionManager = self.Owner.SessionManager
  if sessionManager:ClearCurrentChatContext(true) ~= 0 then
    return
  end
  if not stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING, "StartNewChatInnerWithMsg") then
    return
  end
  sessionManager.ActiveChat.Title = content
  local SceneID = _GetRequestSceneID()
  local MapID = self.Owner.SessionManager:GetMapID()
  local subsceneID = ExtInfo and ExtInfo.subscene or 0
  self:SetCurrentSubsceneID(subsceneID)
  self.PendingRequest  self.PendingRequestChatID = nil
  log(bWriteLog and string.format("[copilot_uigen:dsl:send] StartNewChatInnerWithMsg | scene_id=%s | map_id=%s | subscene=%s | mainscene=%s", tostring(SceneID), tostring(MapID), tostring(subsceneID), tostring(ExtInfo and ExtInfo.mainscene)))
  log(bWriteLog and string.format("[copilot_uigen:dsl:send] StartNewChatInnerWithMsg | ui_dsl_length=%d", ExtInfo and ExtInfo.params and ExtInfo.params.ui_dsl and #ExtInfo.params.ui_dsl or -1))
  self.Owner.NetworkProtocolFeature:SendChatMessage(nil, content, SceneID, MapID, ExtInfo)
  self.Owner.MessageHandler:OnUserMsgInput(content, ExtInfo)
end
function ChatOperationHandler:ContinueChatInner(chat_id, content, ExtInfo)
  local stateMachine = self.Owner.StateMachine
  if not stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING, "ContinueChatInner") then
    return
  end
  local SceneID = _GetRequestSceneID()
  local MapID = self.Owner.SessionManager:GetMapID()
  local subsceneID = ExtInfo and ExtInfo.subscene or 0
  self:SetCurrentSubsceneID(subsceneID)
  self.PendingRequest  self.PendingRequestChatID = chat_id
  log(bWriteLog and string.format("[copilot_uigen:dsl:send] ContinueChatInner | chat_id=%s | scene_id=%s | map_id=%s | subscene=%s | mainscene=%s", tostring(chat_id), tostring(SceneID), tostring(MapID), tostring(subsceneID), tostring(ExtInfo and ExtInfo.mainscene)))
  log(bWriteLog and string.format("[copilot_uigen:dsl:send] ContinueChatInner | ui_dsl_length=%d", ExtInfo and ExtInfo.params and ExtInfo.params.ui_dsl and #ExtInfo.params.ui_dsl or -1))
  self.Owner.NetworkProtocolFeature:SendChatMessage(chat_id, content, SceneID, MapID, ExtInfo)
  self.Owner.MessageHandler:OnUserMsgInput(content, ExtInfo)
end
function ChatOperationHandler:Initialize()
  local stateMachine = self.Owner.StateMachine
  if stateMachine:IsInitializationComplete() then
    return 0
  end
  if stateMachine:GetCurrentState() ~= Config_UGC_Copilot.Enum_UGC_LLM_State.INIT then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST
  end
  if not stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING, "INIT") then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_TRANSITION
  end
  stateMachine.initPendingRequests = {LLMQuotaRsp = false, History = false}
  self.Owner.QuotaManager:FetchLLMQuota()
  self:FetchHistorySessions()
  return 0
end
function ChatOperationHandler:FetchHistorySessions()
  self.Owner.NetworkProtocolFeature:SendGetSessionsReq(self.Owner.SessionManager:GetMapID())
end
function ChatOperationHandler:OpenChatDetail(chat_id)
  local stateMachine = self.Owner.StateMachine
  local allowedStates = {
    [Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING] = true
  }
  if not allowedStates[stateMachine:GetCurrentState()] then
    stateMachine:HandleError(Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST, "OpenChatDetail")
    return
  end
  self.Owner.SessionManager.CurrentChatID = chat_id
  local MapID = self.Owner.SessionManager:GetMapID()
  self.Owner.NetworkProtocolFeature:SendGetOneChatReq(chat_id, MapID)
end
function ChatOperationHandler:LoadHistoryChatInfo(chat_id)
  if self.Owner.StateMachine.CurrentState ~= Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE then
    print(bWriteLog and "ChatOperationHandler:LoadHistoryChatInfo Failed to load history chat info")
    return false
  end
  local chatInfo = self.Owner.SessionManager:FindChatInHistory(chat_id)
  if not chatInfo then
    print(bWriteLog and string.format("Chat %s not found in history", chat_id))
    return false
  end
  local alreadyLoaded = self.Owner.SessionManager:GetChatMessageDetailInCache(chat_id) ~= nil
  if chat_id == self.CurrentChatID then
    alreadyLoaded = true
  end
  if alreadyLoaded then
    print(bWriteLog and string.format("Chat %s already loaded", chat_id))
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CHAT_LOADED, self.Owner.sessionManager.ActiveChat)
    return true
  end
  if not self.Owner.StateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.HISTORY_LOADING, "LoadHistoryChatInfo") then
    print(bWriteLog and "Failed to transition to HISTORY_LOADING state")
    return false
  end
  local MapID = self.Owner.SessionManager:GetMapID()
  self.Owner.NetworkProtocolFeature:SendGetOneChatReq(chat_id, MapID)
  return true
end
function ChatOperationHandler:StartNewChat()
  if not self.Owner.StateMachine:IsInitializationComplete() then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NOT_INITED
  end
  local Ret = self.Owner.SessionManager:ClearCurrentChatContext()
  if Ret == 0 then
    self.Owner.MessageHandler:SendSystemMsg(Config_UGC_Copilot.Enum_UGC_System_Msg.START_NEW_CHAT)
  end
  return Ret
end
function ChatOperationHandler:StopChat(stopReason)
  print(bWriteLog and "ChatOperationHandler:StopChat")
  local stateMachine = self.Owner.StateMachine
  if not stateMachine:IsInitializationComplete() then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NOT_INITED
  end
  if not stateMachine:IsStreamingChatStoppable() then
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_TRANSITION
  end
  stopReason = stopReason or Config_UGC_Copilot.Enum_StopChatReason.UserStop
  self:EnterStopChatSendCooldown("StopChat")
  local sessionManager = self.Owner.SessionManager
  if sessionManager.CurrentChatID then
    stateMachine.stoppedChats[sessionManager.CurrentChatID] = true
  end
  if stateMachine.ActiveTraceID then
    stateMachine.stoppedTraceIDs[stateMachine.ActiveTraceID] = true
  end
  if stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING then
    self.bStopPending = true
    self.bStopPendingIsSend = false
  end
  local traceId = stateMachine.ActiveTraceID or "none"
  local subsceneId = self.CurrentSubsceneID or 0
  if stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "StopChat") then
    self.Owner.QuotaManager:IncrementUsageCount()
  end
  stateMachine:OnStop()
  if self.Owner.MessageHandler then
    self.Owner.MessageHandler:CancelAllAsyncInteractions()
  end
  self:ClearCurrentSubsceneID()
  if sessionManager.ActiveChat then
    if sessionManager.CurrentChatID == nil then
      sessionManager.CurrentChatID = "dummy-chat-id-" .. tostring(os.time())
    end
    sessionManager:AddCurrentChatToHistory()
  end
  local ActiveTraceID = stateMachine.ActiveTraceID
  local ActiveChatID = self.Owner:GetCurrentChatID()
  if ActiveTraceID and ActiveChatID then
    local MapID = self.Owner.SessionManager:GetMapID()
    self.Owner.NetworkProtocolFeature:SendChatStopReq(ActiveTraceID, ActiveChatID, MapID, stopReason)
  end
  local RetCode = self.Owner.SessionManager:ClearCurrentChatContext(true, Config_UGC_Copilot.Enum_ContentClearReason.OnStop)
  if RetCode == 0 then
    self.Owner.MessageHandler:SendSystemMsg(Config_UGC_Copilot.Enum_UGC_System_Msg.STOP_NOW_CHAT)
    local tlogStr = string.format("trace_id=%s&subscene_id=%d&stop_reason=%d", tostring(traceId), subsceneId, stopReason)
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_PauseQuestion, 0, tlogStr)
  else
    print(bWriteLog and "StopChat rejected - ClearCurrentChatContext failed")
  end
  return 0
end
function ChatOperationHandler:FetchRecommendQuestions()
  print(bWriteLog and "Logic_UGC_Copilot:FetchRecommendQuestions - called")
  if self.Owner.StateMachine.CurrentState ~= Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE and self.Owner.StateMachine.CurrentState ~= Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING then
    print(bWriteLog and "FetchRecommendQuestions rejected: invalid state")
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_STATE
  end
  local SceneID = _GetRequestSceneID()
  self.Owner.NetworkProtocolFeature:SendGetRecommendReq(SceneID)
  return 0
end
function ChatOperationHandler:OnHistorySessionsRsp(sessions)
  local stateMachine = self.Owner.StateMachine
  local sessionManager = self.Owner.SessionManager
  sessionManager.ChatHistory = sessions or {}
  table.sort(sessionManager.ChatHistory, function(a, b)
    return a.start_at < b.start_at
  end)
  if stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING then
    if #sessionManager.ChatHistory > 0 then
      local recent_chat = sessionManager.ChatHistory[#sessionManager.ChatHistory]
      self:OpenChatDetail(recent_chat.chat_id)
    else
      stateMachine:SetInitRequestComplete("History")
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HISTORY_UPDATE, sessionManager.ChatHistory)
end
function ChatOperationHandler:OnChatMsgRsp(err, rsp_data)
  log(bWriteLog and string.format("ChatOperationHandler:OnChatMsgRsp: err = %d, rsp_data type = %s", err, type(rsp_data)))
  if err ~= 0 then
    if _FinishHistoryInitAsEmpty(self.Owner, "OnChatMsgRspError:" .. tostring(err)) then
      return
    end
    self.Owner:HandleNetworkError(err, "ChatOperationHandler:OnChatMsgRsp")
    return
  end
  if not rsp_data or type(rsp_data) ~= "table" then
    log(bWriteLog and "ChatOperationHandler:OnChatMsgRsp ERROR: \229\147\141\229\186\148\230\149\176\230\141\174\230\160\188\229\188\143\230\151\160\230\149\136 (\233\157\158table\231\177\187\229\158\139)")
    _FinishHistoryInitAsEmpty(self.Owner, "OnChatMsgRspInvalidData")
    return
  end
  log_tree("ChatOperationHandler:OnChatMsgRsp rsp_data = ", rsp_data)
  if not rsp_data.data or type(rsp_data.data) ~= "table" then
    log(bWriteLog and "ChatOperationHandler:OnChatMsgRsp ERROR: \231\188\186\229\176\145data\229\173\151\230\174\181\230\136\150data\233\157\158table\231\177\187\229\158\139")
    _FinishHistoryInitAsEmpty(self.Owner, "OnChatMsgRspMissingData")
    return
  end
  local chatData = rsp_data.data
  chatData.messages = chatData.messages or {}
  local requiredFields = {
    "chat_id",
    "messages",
    "title",
    "start_at"
  }
  for _, field in ipairs(requiredFields) do
    if chatData[field] == nil then
      log(bWriteLog and string.format("ChatOperationHandler:OnChatMsgRsp ERROR: \231\188\186\229\176\145\229\191\133\232\166\129\229\173\151\230\174\181 [%s] in chatData", field))
      _FinishHistoryInitAsEmpty(self.Owner, "OnChatMsgRspMissingField:" .. tostring(field))
      return
    end
  end
  local validMessages = 0
  for i, msg in ipairs(chatData.messages) do
    if type(msg) == "table" and msg.role and msg.content then
      if msg.role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
        local content_struct_str = msg.content_struct
        if content_struct_str and type(content_struct_str) == "string" then
          local success, decoded_struct = pcall(json.decode, content_struct_str)
          if success and decoded_struct and decoded_struct.choices then
            msg.content_struct = decoded_struct.choices
          else
            log(bWriteLog and string.format("ChatOperationHandler:OnChatMsgRsp WARNING: \230\182\136\230\129\175#%d content_struct JSON\232\167\163\231\160\129\229\164\177\232\180\165", i))
            msg.content_struct = nil
          end
        end
      end
      if msg.role == Config_UGC_Copilot.Enum_Copilot_RoleType.User and msg.trace_id then
        msg.trace_id = msg.trace_id .. "_user"
      end
      validMessages = validMessages + 1
    else
      log(bWriteLog and string.format("ChatOperationHandler:OnChatMsgRsp WARNING: \230\182\136\230\129\175#%d \230\160\188\229\188\143\230\151\160\230\149\136\230\136\150\231\188\186\229\176\145role/content", i))
    end
  end
  if validMessages == 0 and 0 < #chatData.messages then
    log(bWriteLog and "ChatOperationHandler:OnChatMsgRsp ERROR: \230\156\170\230\137\190\229\136\176\228\187\187\228\189\149\230\156\137\230\149\136\231\154\132\230\182\136\230\129\175\229\134\133\229\174\185")
  end
  self:OnChatDetailRsp(chatData)
end
function ChatOperationHandler:OnChatDetailRsp(chat_data)
  log_tree("ChatOperationHandler:OnChatDetailRsp chat_data = ", chat_data)
  if not chat_data then
    log(bWriteLog and "ChatOperationHandler:OnChatDetailRsp: chat_data is nil")
    return
  end
  local stateMachine = self.Owner.StateMachine
  local sessionManager = self.Owner.SessionManager
  local messageHandler = self.Owner.MessageHandler
  if chat_data.messages then
    for _, message in ipairs(chat_data.messages) do
      if message.trace_id then
        sessionManager.TraceID2ChatID[message.trace_id] = chat_data.chat_id
      end
      if message.feedback_status and message.feedback_status.terminate == 1 then
        stateMachine:MarkMessageStale(message.trace_id, chat_data.chat_id)
      end
    end
  end
  local standardData, bActiveChat = messageHandler:ConvertChatDataToStandardFormat(chat_data)
  if stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING then
    sessionManager.ActiveChat = standardData
    sessionManager.CurrentChatID = chat_data.chat_id
    if not bActiveChat then
      stateMachine:MarkMessageStale(chat_data.chat_id)
    end
    stateMachine:SetInitRequestComplete("History")
  else
    sessionManager.ChatId2MessageDetail[chat_data.chat_id] = standardData.Messages
    stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "HistoryChatInfoLoaded")
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CHAT_LOADED, standardData)
end
function ChatOperationHandler:OnAIMessageNetworkRsp(err, event, data, cb_data)
  log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp: event = %s, trace_id = %s", event, cb_data and cb_data.trace_id or "N/A"))
  log(bWriteLog and string.format("[copilot_uigen:dsl:receive] OnAIMessageNetworkRsp | err=%s | event=%s | trace_id=%s", tostring(err), tostring(event), tostring(cb_data and cb_data.trace_id)))
  log_tree("Stream response data = ", data)
  log_tree("Callback data = ", cb_data)
  if self.DebugHooks and self.DebugHooks.OnAIMessageNetworkRsp then
    local hookResult = self.DebugHooks.OnAIMessageNetworkRsp(self, err, event, data, cb_data)
    if hookResult then
      err = hookResult.err or err
      event = hookResult.event or event
      data = hookResult.data or data
      cb_data = hookResult.cb_data or cb_data
      log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp - Hook applied: event = %s", tostring(event)))
    end
  end
  if err ~= 0 then
    self.Owner:HandleNetworkError(err, "ChatOperationHandler:OnAIMessageNetworkRsp")
    return
  end
  if not self:IsCallbackForCurrentMap(cb_data) then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp - Ignore cross-map callback. current_map=%s incoming_map=%s", tostring(self.Owner.SessionManager:GetMapID()), tostring(cb_data and cb_data.map_id)))
    return
  end
  self:TryBindActiveTraceFromResponse(event, cb_data)
  local stateMachine = self.Owner.StateMachine
  if cb_data and cb_data.trace_id and stateMachine.ActiveTraceID == cb_data.trace_id and stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.STREAMING then
    stateMachine:ResetCurrentStateTimeout()
  end
  if self.bStopPending and not self.bStopPendingIsSend and cb_data and cb_data.trace_id then
    local MapID = self.Owner.SessionManager:GetMapID()
    self.Owner.NetworkProtocolFeature:SendChatStopReq(cb_data.trace_id, cb_data.chat_id, MapID)
    self.bStopPendingIsSend = true
  end
  if self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Data) then
    if not (data and type(data) == "table" and data.choices) or #data.choices == 0 or not data.choices[1].delta then
      log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp ERROR: \230\151\160\230\149\136\231\154\132data\230\160\188\229\188\143 (event 100)")
      return
    end
    if not cb_data or not cb_data.trace_id then
      log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp WARNING: \231\188\186\229\176\145trace_id\229\155\158\232\176\131\230\149\176\230\141\174 (event 100)")
      cb_data = cb_data or {
        trace_id = "unknown_" .. tostring(os.time())
      }
    end
    local validData = {
      trace_id = cb_data.trace_id,
      delta = data.choices[1].delta
    }
    local delta = data.choices[1].delta
    local customData = delta and delta.custom_data
    if customData and customData.ui_dsl_key and customData.ui_dsl_key ~= "" then
      local uigenFeature = self.Owner.UIGenFeature
      if uigenFeature and uigenFeature.OnDslKeyReceived then
        uigenFeature:OnDslKeyReceived(customData.ui_dsl_key, cb_data.trace_id)
      end
    end
    self:OnAIMessagePartial(validData, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Finish) then
    if not cb_data or not cb_data.trace_id then
      log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp WARNING: \231\187\147\230\157\159\229\140\133\231\188\186\229\176\145trace_id")
      cb_data = cb_data or {
        trace_id = self.Owner.StateMachine.ActiveTraceID or "end_" .. tostring(os.time())
      }
    end
    if self:IsRateLimitFinish(cb_data) then
      log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp - skip finish after ChatRateLimit. event=%s trace_id=%s chat_id=%s", tostring(event), tostring(cb_data.trace_id), tostring(cb_data.chat_id)))
      self.RateLimitedTraceID = nil
      return
    end
    local traceId = cb_data and cb_data.trace_id or self.Owner.StateMachine.ActiveTraceID or "none"
    local duration = self.Owner.StateMachine:GetExecutionDuration()
    local subsceneId = self.CurrentSubsceneID or 0
    local tlogStr = string.format("trace_id=%s&duration=%d&subscene_id=%d", tostring(traceId), duration, subsceneId)
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_Succeed, 0, tlogStr)
    if self.CurrentSubsceneID == Config_UGC_Copilot.Enum_ChatSceneId.SceneEdit then
      self:ReportAICopilotSceneEditSuccessToServer(duration)
    end
    if self.CurrentSubsceneID == Config_UGC_Copilot.Enum_ChatSceneId.BlockyLuaEdit then
      log(bWriteLog and "NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Finish) - BlockyLuaEdit scene, hiding progress bar")
      _TryNotifyBlockyLuaProgressFinish(self.Owner, cb_data and cb_data.trace_id)
      local messageHandler = self.Owner.MessageHandler
      if messageHandler and messageHandler.WithdrawTrailingBlockyLuaProgress then
        local withdrawResult = messageHandler:WithdrawTrailingBlockyLuaProgress(cb_data.trace_id)
        if 0 < withdrawResult then
          local sessionManager = self.Owner.SessionManager
          local activeChat = sessionManager and sessionManager.ActiveChat
          local aiMessage = activeChat and activeChat.AIMessage
          if aiMessage and aiMessage.TraceID == cb_data.trace_id then
            EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, cb_data.trace_id, sessionManager.CurrentChatID, aiMessage)
          end
        end
      end
    end
    self:OnAIMessageComplete(data, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Error) then
    if self:ShouldIgnoreErrorBeforeTraceBound(cb_data) then
      return
    end
    if self:ShouldIgnoreErrorForTraceIsolation(cb_data) then
      return
    end
    local ReasonCode = data and data.ret or -1
    if not C_NOT_INTEREST_ERRCODE[ReasonCode] then
      local traceId = cb_data and cb_data.trace_id or self.Owner.StateMachine.ActiveTraceID or "none"
      local duration = self.Owner.StateMachine:GetExecutionDuration()
      local subsceneId = self.CurrentSubsceneID or 0
      local errorData = data or {}
      errorData.trace_id = traceId
      errorData.error_source = "server"
      errorData.      errorData.subscene_id = subsceneId
      local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_Fail, ReasonCode, json.encode(errorData))
    end
    log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp ERROR: \230\148\182\229\136\176\233\148\153\232\175\175\228\186\139\228\187\182")
    self:OnAIMessageError(data, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatAudit) then
    log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp")
    local ok = data.ret_code == 0
    local AIGCCreateSkAnimSubSystem = SubsystemMgr:Get("AIGCCreateSkAnimSubSystem")
    if AIGCCreateSkAnimSubSystem and cb_data and cb_data.subscene == Config_UGC_Copilot.Enum_ChatSceneId.SkeletalAnimaGen then
      AIGCCreateSkAnimSubSystem:OnVideoAudit(ok)
    end
    local AIGC3DModelSubSystem = SubsystemMgr:Get("AIGC3DModelSubSystem")
    if AIGC3DModelSubSystem and cb_data and (cb_data.subscene == Config_UGC_Copilot.Enum_ChatSceneId.SimpleModelGenByImage or cb_data.subscene == Config_UGC_Copilot.Enum_ChatSceneId.PixelModelGenByImage) then
      AIGC3DModelSubSystem:OnImageAudit(ok)
    end
    if not ok then
      local MessageHandler = self.Owner.MessageHandler
      local stateMachine = self.Owner.StateMachine
      if stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING then
        stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "MessageRspEventTypeEnum.ChatAudit nil")
      end
      self.Owner.SessionManager:ClearCurrentChatContext(true)
    end
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Hint) then
    log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp Hint")
    if not data or type(data) ~= "table" then
      log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp ERROR: \230\151\160\230\149\136\231\154\132data\230\160\188\229\188\143 (event hint)")
      return
    end
    if not cb_data or not cb_data.trace_id then
      log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp WARNING: \231\188\186\229\176\145trace_id\229\155\158\232\176\131\230\149\176\230\141\174 (event 100)")
      cb_data = cb_data or {
        trace_id = "unknown_" .. tostring(os.time())
      }
    end
    local hints = data and data.hints or {}
    local final_delta = {
      content = {},
      type = Config_UGC_Copilot.Enum_Copilot_MessageType.Questions
    }
    for _, hint in pairs(hints) do
      table.insert(final_delta.content, hint.content)
    end
    local validData = {
      trace_id = cb_data.trace_id,
      delta = final_delta
    }
    self:OnAIMessagePartial(validData, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.InputSafety) then
    log(bWriteLog and "NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.InputSafety)")
    local MessageHandler = self.Owner.MessageHandler
    MessageHandler:OnUserInputConfirmed(true)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatCode) then
    log(bWriteLog and "NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatCode)")
    local CodeContent = data and data.content or {}
    log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp ChatCode: ")
    local PartialData = {
      delta = {
        content = CodeContent,
        type = Config_UGC_Copilot.Enum_Copilot_MessageType.ChatCode
      }
    }
    self:OnAIMessagePartial(PartialData, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.BlockyEdit) then
    log(bWriteLog and "NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.BlockyEdit)")
    local BlockyContent = data
    local PartialData = {
      delta = {
        content = BlockyContent,
        type = Config_UGC_Copilot.Enum_Copilot_MessageType.BlockyEdit
      }
    }
    self:OnAIMessagePartial(PartialData, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatUIDsl) then
    log(bWriteLog and "NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatUIDsl)")
    local dslText = data and data.content and data.content.text or ""
    local resources = data and data.resources or {}
    local traceId = cb_data and cb_data.trace_id or ""
    log(bWriteLog and string.format("[copilot_uigen:dsl:receive] ChatUIDsl received | trace_id=%s | dsl_length=%d | resources_count=%d", tostring(traceId), #dslText, tostring(next(resources) and #resources or 0)))
    if data then
      for k, v in pairs(data) do
        if type(v) == "table" then
          log(bWriteLog and string.format("[copilot_uigen:dsl:receive] ChatUIDsl data.%s = (table)", tostring(k)))
        else
          log(bWriteLog and string.format("[copilot_uigen:dsl:receive] ChatUIDsl data.%s = %s", tostring(k), tostring(v)))
        end
      end
    end
    if cb_data then
      for k, v in pairs(cb_data) do
        log(bWriteLog and string.format("[copilot_uigen:dsl:receive] ChatUIDsl cb_data.%s = %s", tostring(k), tostring(v)))
      end
    end
    local uigenFeature = self.Owner.UIGenFeature
    if uigenFeature and uigenFeature.OnDslReceived then
      local serverMode = data and data.content and data.content.mode
      cb_data = cb_data or {}
      cb_data.apply_mode = serverMode or "rebuild"
      log(bWriteLog and string.format("[copilot_uigen:dsl:receive] ChatUIDsl forwarding to UIGenFeature | apply_mode=%s | content.mode=%s", tostring(cb_data.apply_mode), tostring(serverMode)))
      uigenFeature:OnDslReceived(traceId, dslText, resources, cb_data)
    else
      local PartialData = {
        delta = {
          content = dslText,
          type = Config_UGC_Copilot.Enum_Copilot_MessageType.Messages
        }
      }
      self:OnAIMessagePartial(PartialData, cb_data)
    end
    if dslText and dslText ~= "" then
      _TryNotifyUIGenProgressFinish(self.Owner, traceId)
    end
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatTaskInteraction) then
    local PartialData = {
      delta = {
        interaction_data = data,
        type = Config_UGC_Copilot.Enum_Copilot_MessageType.Interaction
      }
    }
    self:OnAIMessagePartial(PartialData, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.ChatRateLimit) then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp - dispatch ChatRateLimit event=%s trace_id=%s chat_id=%s", tostring(event), tostring(cb_data and cb_data.trace_id), tostring(cb_data and cb_data.chat_id)))
    self:OnAIMessageRateLimit(data, cb_data)
  elseif self.Owner.NetworkProtocolFeature:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.HeartBeat) then
    log(bWriteLog and "ChatOperationHandler:OnAIMessageNetworkRsp HeartBeat received")
    if cb_data and cb_data.trace_id and stateMachine.ActiveTraceID == cb_data.trace_id then
      log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp HeartBeat - Resetting timeout for trace_id: %s", cb_data.trace_id))
      stateMachine:ResetCurrentStateTimeout()
      local mapID = cb_data.map_id or self.Owner.SessionManager:GetMapID()
      local chatID = cb_data.chat_id or self.Owner.SessionManager:GetCurrentChatID() or ""
      local pongConfig = Config_UGC_Copilot.HeartBeatPongConfig
      local resultDetail = {
        [pongConfig.PongField] = pongConfig.PongValue
      }
      local LLMHandler = require("client.network.Protocol.LLMHandler")
      LLMHandler.send_ugc_llm_client_interact_result_req(mapID, chatID, cb_data.trace_id, resultDetail)
      log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp HeartBeat - sent interact_result_req trace_id=%s chat_id=%s map_id=%s", tostring(cb_data.trace_id), tostring(chatID), tostring(mapID)))
    else
      log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp HeartBeat - Ignoring heartbeat for different trace_id. Current: %s, Received: %s", tostring(stateMachine.ActiveTraceID), tostring(cb_data and cb_data.trace_id or "nil")))
    end
  else
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageNetworkRsp WARNING: \230\156\170\231\159\165\228\186\139\228\187\182\231\177\187\229\158\139: %s", event))
  end
end
function ChatOperationHandler:OnCodeExecuteResult(result, args)
  print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback")
  local LLMHandler = require("client.network.Protocol.LLMHandler")
  print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback result: " .. tostring(result))
  if self.CurCodeTaskContext then
    local traceId = self.CurCodeTaskContext.trace_id
    local doExecuteSeqId = self:FindInteractionSeqIdByType(traceId, Config_UGC_Copilot.InteractionEnum.DoExecute)
    if result == 0 then
      if doExecuteSeqId then
        self.Owner:UpdateInteractionStatus(traceId, doExecuteSeqId, Config_UGC_Copilot.InteractionStatusEnum.Success)
      end
      LLMHandler.send_ugc_llm_client_code_result_req(self.CurCodeTaskContext.map_id, self.CurCodeTaskContext.chat_id, traceId, {
        result = result,
        content = args and args.content,
        contentx = args and args.contentx,
        err_msg = ""
      })
    else
      if doExecuteSeqId then
        self.Owner:UpdateInteractionStatus(traceId, doExecuteSeqId, Config_UGC_Copilot.InteractionStatusEnum.Failed)
      end
      print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback result: " .. tostring(result))
      if args and args[1] then
        print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback args[1]: " .. tostring(args[1]))
        LLMHandler.send_ugc_llm_client_code_result_req(self.CurCodeTaskContext.map_id, self.CurCodeTaskContext.chat_id, traceId, {
          result = -1,
          content = {},
          err_msg = args[1]
        })
      elseif type(args) == "string" then
        print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback args is string")
        print(bWriteLog and "Error : " .. tostring(args))
        LLMHandler.send_ugc_llm_client_code_result_req(self.CurCodeTaskContext.map_id, self.CurCodeTaskContext.chat_id, traceId, {
          result = result or -1,
          content = {},
          err_msg = args
        })
      else
        print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback args is nil")
        LLMHandler.send_ugc_llm_client_code_result_req(self.CurCodeTaskContext.map_id, self.CurCodeTaskContext.chat_id, traceId, {
          result = -1,
          content = {},
          err_msg = "unknown error:" .. tostring(args)
        })
      end
    end
  else
    print(bWriteLog and "ChatOperationHandler:OnExeCodeCalback CurCodeTaskContext is nil")
  end
end
function ChatOperationHandler:FindInteractionSeqIdByType(traceId, interactionType)
  if not traceId or not interactionType then
    return nil
  end
  local CurrentDetail = self.Owner.SessionManager:GetTraceDetailByKey(traceId, Config_UGC_Copilot.MessageDetailKeyEnum.InteractionDetails) or {}
  local foundSeqId
  for seqId, data in pairs(CurrentDetail) do
    if data.type == interactionType and (not foundSeqId or seqId > foundSeqId) then
      foundSeqId = seqId
    end
  end
  return foundSeqId
end
function ChatOperationHandler:OnAIMessagePartial(data, cb_data)
  local stateMachine = self.Owner.StateMachine
  local sessionManager = self.Owner.SessionManager
  if stateMachine:IsMessageStale(cb_data.chat_id, cb_data.trace_id) or stateMachine:IsTraceIdRevoked(cb_data.trace_id) then
    log(bWriteLog and "WARNING: Stale partial message received, ignoring.")
    return
  end
  if stateMachine:IsChatIdle() or stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.ERROR then
    stateMachine:HandleError(Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_STALE_RESPONSE, "OnAIMessagePartial::StateNotMatch")
    return
  end
  if stateMachine:GetCurrentState() == Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING then
    stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.STREAMING, "OnAIMessagePartial::NewChat")
    stateMachine:SetActiveTraceID(cb_data.trace_id)
    sessionManager.TraceID2ChatID[stateMachine.ActiveTraceID] = cb_data.chat_id
    if not sessionManager.CurrentChatID then
      sessionManager.CurrentChatID = cb_data.chat_id
      sessionManager.ActiveChat.ChatID = cb_data.chat_id
      sessionManager.ActiveChat.StartAt = os.time()
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_NEW_CHAT_CREATED, {
        chat_id = sessionManager.CurrentChatID
      })
      for _, Message in pairs(sessionManager.ActiveChat.Messages) do
        if Message.TraceID then
          sessionManager.TraceID2ChatID[Message.TraceID] = cb_data.chat_id
        end
      end
    end
    if self.CacheTlogContext then
      local QuestionContent = self.CacheTlogContext.question_content
      local bIsRecommendQuestionStr = self.CacheTlogContext.is_recommend_question
      local logData = {
        user_id = DataMgr.roleData.uid,
        chat_id = cb_data.chat_id or "none",
        trace_id = cb_data.trace_id,
        timestamp = os.time(),
        question_content = QuestionContent,
        is_recommend_question = bIsRecommendQuestionStr,
        subscene_id = self.CurrentSubsceneID or 0
      }
      local logStr = ""
      for k, v in pairs(logData) do
        logStr = logStr .. string.format("%s=%s&", k, tostring(v))
      end
      logStr = logStr:sub(1, -2)
      print(bWriteLog and "Logic_UGC_Copilot:OnAIMessagePartial: logStr: " .. logStr)
      local ModuleManager = require("client.module_framework.ModuleManager")
      local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_RaiseQuestion, 0, logStr)
    end
  end
  sessionManager:UpdateSessionActivity()
  local bNewMessage = false
  local messageHandler = self.Owner.MessageHandler
  if not sessionManager.ActiveChat.AIMessage then
    sessionManager.ActiveChat.AIMessage = messageHandler:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {}, cb_data.trace_id)
    table.insert(sessionManager.ActiveChat.Messages, sessionManager.ActiveChat.AIMessage)
    bNewMessage = true
  elseif sessionManager.ActiveChat.AIMessage.TraceID ~= cb_data.trace_id then
    sessionManager.ActiveChat.AIMessage = messageHandler:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {}, cb_data.trace_id)
    table.insert(sessionManager.ActiveChat.Messages, sessionManager.ActiveChat.AIMessage)
    bNewMessage = true
  end
  local delta_segments = {}
  local delta = data.delta
  local ttype = delta and delta.type
  if delta then
    local Config = Config_UGC_Copilot.GetCopilotMessageTypeConfig(ttype)
    local wasSplit = Config_UGC_Copilot.HandleMessageSplitting(delta, delta_segments, data.trace_id)
    if not wasSplit and Config and Config.UIKey ~= "NULL" then
      table.insert(delta_segments, delta)
    end
    if Config and Config.PreCheck then
      Config.PreCheck(delta, data.trace_id, sessionManager.ActiveChat.AIMessage)
    end
  end
  if not sessionManager.ActiveChat.AIMessage then
    local recoveredMessage
    for i = #sessionManager.ActiveChat.Messages, 1, -1 do
      local msg = sessionManager.ActiveChat.Messages[i]
      if msg and msg.TraceID == cb_data.trace_id then
        recoveredMessage = msg
        break
      end
    end
    if recoveredMessage then
      print(bWriteLog and "ChatOperationHandler:OnAIMessagePartial WARNING: AIMessage cleared; recovered existing message by trace")
      sessionManager.ActiveChat.AIMessage = recoveredMessage
    else
      print(bWriteLog and "ChatOperationHandler:OnAIMessagePartial WARNING: AIMessage cleared; creating fallback empty message")
      sessionManager.ActiveChat.AIMessage = messageHandler:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {}, cb_data.trace_id)
      table.insert(sessionManager.ActiveChat.Messages, sessionManager.ActiveChat.AIMessage)
    end
    bNewMessage = true
  elseif sessionManager.ActiveChat.AIMessage.TraceID ~= cb_data.trace_id then
    print(bWriteLog and string.format("ChatOperationHandler:OnAIMessagePartial WARNING: AIMessage trace mismatch after PreCheck, re-creating. active=%s, incoming=%s", tostring(sessionManager.ActiveChat.AIMessage.TraceID), tostring(cb_data.trace_id)))
    local recoveredMessage
    for i = #sessionManager.ActiveChat.Messages, 1, -1 do
      local msg = sessionManager.ActiveChat.Messages[i]
      if msg and msg.TraceID == cb_data.trace_id then
        recoveredMessage = msg
        break
      end
    end
    if recoveredMessage then
      sessionManager.ActiveChat.AIMessage = recoveredMessage
    else
      sessionManager.ActiveChat.AIMessage = messageHandler:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {}, cb_data.trace_id)
      table.insert(sessionManager.ActiveChat.Messages, sessionManager.ActiveChat.AIMessage)
    end
    bNewMessage = true
  end
  local aiMessage = sessionManager.ActiveChat.AIMessage
  if not aiMessage then
    log(bWriteLog and "ChatOperationHandler:OnAIMessagePartial WARNING: AIMessage was cleared after creation, re-creating to preserve message")
    aiMessage = messageHandler:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {}, cb_data.trace_id)
    sessionManager.ActiveChat.AIMessage = aiMessage
    table.insert(sessionManager.ActiveChat.Messages, aiMessage)
    bNewMessage = true
  end
  local withdraw_count = 0
  if delta and delta.custom_data then
    aiMessage.custom_data = delta.custom_data
  end
  if 0 < #delta_segments and ttype ~= Config_UGC_Copilot.Enum_Copilot_MessageType.Interaction and ttype ~= Config_UGC_Copilot.Enum_Copilot_MessageType.InGeneration and messageHandler.WithdrawTrailingUIGenProgress then
    withdraw_count = messageHandler:WithdrawTrailingUIGenProgress(cb_data.trace_id)
  end
  local lastContent = aiMessage.Content[#aiMessage.Content]
  local currentDelta = delta_segments[1]
  if currentDelta and currentDelta.type == Config_UGC_Copilot.Enum_Copilot_MessageType.Messages and lastContent and lastContent.type == Config_UGC_Copilot.Enum_Copilot_MessageType.Messages then
    lastContent.content = lastContent.content .. (currentDelta.content or "")
    currentDelta.content = lastContent.content
    table.remove(aiMessage.Content)
    withdraw_count = 1
  end
  for _, segment in ipairs(delta_segments) do
    table.insert(aiMessage.Content, segment)
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, aiMessage, delta_segments, withdraw_count, bNewMessage)
  if ttype == Config_UGC_Copilot.Enum_Copilot_MessageType.Interaction then
    print(bWriteLog and "ChatOperationHandler:OnAIMessagePartial: Interaction")
    local MessageHandler = self.Owner.MessageHandler
    if delta and delta.interaction_data then
      MessageHandler:OnInteraction(data.delta.interaction_data, cb_data)
    end
  end
  if ttype == Config_UGC_Copilot.Enum_Copilot_MessageType.ChatCode then
    local CodeContent = delta.content
    if CodeContent and next(CodeContent) then
      local MessageHandler = self.Owner.MessageHandler
      self.CurCodeTaskContext = cb_data
      local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
      if uPlayerController and slua.isValid(uPlayerController) then
        uPlayerController.CreativeModeMCPFeature:UpdateCanEditObj()
        uPlayerController.CreativeModeMCPFeature:UpdateMapCost()
        uPlayerController.CreativeModeMCPFeature:ServerRPC_ExecuteCode(CodeContent)
      end
    else
      print("ChatOperationHandler error. ChatCode invalid!!")
    end
  end
  if ttype == Config_UGC_Copilot.Enum_Copilot_MessageType.BlockyEdit then
    local SubSystem = SubsystemMgr:Get("AICopilotSubSystem")
    SubSystem:SetDraggableTips(LocUtil.LocalizeResFormat(2026040469), -1)
  end
end
function ChatOperationHandler:OnAIMessageComplete(data, cb_data)
  self.bStopPending = false
  local stateMachine = self.Owner.StateMachine
  local sessionManager = self.Owner.SessionManager
  if self.Owner.MessageHandler then
    self.Owner.MessageHandler._autoSeqId = 0
  end
  if stateMachine:IsMessageStale(cb_data.chat_id, cb_data.trace_id) then
    log(bWriteLog and "WARNING: Stale complete message received, ignoring.")
    return
  end
  if stateMachine:IsChatIdle() then
    log(bWriteLog and "ChatOperationHandler:OnAIMessageComplete: not pending request, ignoring.")
    return
  end
  sessionManager:UpdateSessionActivity()
  if stateMachine.CurrentState == Config_UGC_Copilot.Enum_UGC_LLM_State.LONG_TASK_RUNNING then
    if _IsActiveUIGenLongTask(self.Owner, cb_data and cb_data.trace_id) then
      local finalDelta = data and data.choices and data.choices[1] and data.choices[1].delta
      if finalDelta and finalDelta.content then
        finalDelta.type = finalDelta.type or Config_UGC_Copilot.Enum_Copilot_MessageType.Messages
        self:OnAIMessagePartial({
          trace_id = cb_data.trace_id,
          delta = finalDelta
        }, cb_data)
      end
    end
    if _TryCommitUIGenLongTaskFinish(self.Owner, cb_data and cb_data.trace_id) then
      return
    end
    if _TryCommitBlockyLuaLongTaskFinish(self.Owner, cb_data and cb_data.trace_id) then
      return
    end
    log(bWriteLog and "ChatOperationHandler:OnAIMessageComplete: long task finish ack.")
    return
  end
  self.PendingRequestMapID = nil
  self.PendingRequestChatID = nil
  stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "OnAIMessageComplete")
  stateMachine:SetActiveTraceID(nil)
  if sessionManager.ActiveChat.AIMessage then
    local final_delta = data and data.choices and data.choices[1] and data.choices[1].delta
    if final_delta and final_delta.content then
      local lastContent = sessionManager.ActiveChat.AIMessage.Content[#sessionManager.ActiveChat.AIMessage.Content]
      if lastContent and lastContent.type == Config_UGC_Copilot.Enum_Copilot_MessageType.Messages then
        lastContent.content = lastContent.content .. final_delta.content
      else
        table.insert(sessionManager.ActiveChat.AIMessage.Content, final_delta)
      end
    end
    sessionManager.ActiveChat.AIMessage = nil
    print(bWriteLog and "ChatOperationHandler:OnAIMessageComplete - AIMessage cleared after streaming complete")
  end
  sessionManager:AddCurrentChatToHistory()
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, sessionManager.ActiveChat)
  self.Owner.QuotaManager:IncrementUsageCount()
  self.CurCodeTaskContext = nil
  self.CurBlockyTaskContext = nil
  self:ClearCurrentSubsceneID()
end
function ChatOperationHandler:OnAIMessageError(data, cb_data)
  log(bWriteLog and "ChatOperationHandler:OnAIMessageError")
  data = data or {}
  cb_data = cb_data or {}
  if not self:IsCallbackForCurrentMap(cb_data) then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageError - Ignore cross-map error callback. current_map=%s incoming_map=%s", tostring(self.Owner.SessionManager:GetMapID()), tostring(cb_data and cb_data.map_id)))
    return
  end
  if self:ShouldIgnoreErrorForTraceIsolation(cb_data) then
    return
  end
  self.PendingRequestMapID = nil
  self.PendingRequestChatID = nil
  local stateMachine = self.Owner.StateMachine
  local messageHandler = self.Owner.MessageHandler
  if data.ret == Config_UGC_Copilot.EnumServerChatErrorCode.UserSensitiveWord then
    if not stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "OnAIMessageError::3010") then
      stateMachine:HandleError(Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_STATE_TRANSITION_FAILED, "failed_to_transition_to_idle")
      return
    end
    messageHandler:OnUserInputConfirmed(false)
    local traceId = cb_data and cb_data.trace_id or stateMachine.ActiveTraceID or "none"
    local tlogStr = string.format("trace_id=%s", tostring(traceId))
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_UserSensitiveWord, 0, tlogStr)
  elseif data.ret == Config_UGC_Copilot.EnumServerChatErrorCode.ModelSensitiveWord then
    if stateMachine:GetCurrentState() ~= Config_UGC_Copilot.Enum_UGC_LLM_State.STREAMING then
      stateMachine:HandleError(Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_TRANSITION, "invalid_state_for_3012_handling")
      return
    end
    if cb_data.trace_id and stateMachine.ActiveTraceID ~= cb_data.trace_id then
      log(bWriteLog and "WARNING: Ignoring 3012 error for stale trace_id.")
      return
    end
    if not stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "OnAIMessageError::3012") then
      stateMachine:HandleError(Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_STATE_TRANSITION_FAILED, "failed_to_transition_to_idle_3012")
      return
    end
    local traceId = cb_data and cb_data.trace_id or stateMachine.ActiveTraceID or "none"
    local tlogStr = string.format("trace_id=%s", tostring(traceId))
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Copilot_ModelSensitiveWord, 0, tlogStr)
    messageHandler:RevokeAIMessageByTraceID(stateMachine.ActiveTraceID)
    self.Owner.SessionManager:ClearCurrentChatContext(true)
  elseif data.ret == Config_UGC_Copilot.EnumServerChatErrorCode.ModgenOverload then
    print(bWriteLog and "ChatOperationHandler:OnAIMessageError: model overload")
    local Text = LocUtil.GetLocalizeResStr(511070) .. "(" .. tostring(data.ret) .. ")"
    ShowNotice(Text)
    local TraceID = cb_data.trace_id
    Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_CHAT, data.ret, Config_UGC_Copilot.ErrorOutputType.CHAT, {
      traceId = TraceID,
      hideFeedback = true,
      hideMessageBG = false,
      clearContent = true
    })
    stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "OnAIMessageError::ModgenOverload")
  elseif C_UIGEN_ERRCODE[data.ret] then
    log(bWriteLog and string.format("ChatOperationHandler:OnAIMessageError: UIGen error %d", data.ret))
    local TraceID = cb_data.trace_id
    Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_CHAT, data.ret, Config_UGC_Copilot.ErrorOutputType.CHAT, {
      traceId = TraceID,
      hideFeedback = true,
      hideMessageBG = false,
      clearContent = true
    })
    stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "OnAIMessageError::UIGen_" .. tostring(data.ret))
    stateMachine:SetActiveTraceID(nil)
    local uigenFeature = self.Owner.UIGenFeature
    if uigenFeature then
      uigenFeature:ClearPendingState()
    end
  else
    local errorMsg = string.format("Unhandled error code: %d - %s", data.ret or -1, data.msg or "unknown")
    local Text = LocUtil.GetLocalizeResStr(511070) .. "(" .. tostring(data.ret) .. ")"
    ShowNotice(Text)
    local TraceID = cb_data.trace_id
    local sessionManager = self.Owner.SessionManager
    log(bWriteLog and string.format("[copilot_uigen:error] OnAIMessageError BEFORE OutputError | ret=%s | msg=%s | trace_id=%s | state=%s | chat_id=%s | messages_count=%d", tostring(data.ret), tostring(data.msg), tostring(TraceID), tostring(stateMachine:GetCurrentState()), tostring(sessionManager.CurrentChatID), sessionManager.ActiveChat and sessionManager.ActiveChat.Messages and #sessionManager.ActiveChat.Messages or -1))
    if TraceID then
      Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_CHAT, data.ret or -1, Config_UGC_Copilot.ErrorOutputType.CHAT, {
        traceId = TraceID,
        hideFeedback = true,
        hideMessageBG = false,
        clearContent = true
      })
    end
    log(bWriteLog and string.format("[copilot_uigen:error] OnAIMessageError AFTER OutputError, BEFORE HandleError | messages_count=%d", sessionManager.ActiveChat and sessionManager.ActiveChat.Messages and #sessionManager.ActiveChat.Messages or -1))
    stateMachine:HandleError(data.ret or Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_UNKNOWN, errorMsg)
    log(bWriteLog and string.format("[copilot_uigen:error] OnAIMessageError AFTER HandleError | state=%s | chat_id=%s | messages_count=%d", tostring(stateMachine:GetCurrentState()), tostring(sessionManager.CurrentChatID), sessionManager.ActiveChat and sessionManager.ActiveChat.Messages and #sessionManager.ActiveChat.Messages or -1))
  end
  self:ClearCurrentSubsceneID()
end
function ChatOperationHandler:OnchatStopRsp(trace_id, ret)
  log(bWriteLog and "ChatOperationHandler:OnchatStopRsp() trace_id :" .. tostring(trace_id) .. " ret = " .. tostring(ret))
  self.bStopPending = false
end
function ChatOperationHandler:RegisterDebugHook(hookName, hookFunc)
  if not self.DebugHooks then
    self.DebugHooks = {}
  end
  self.DebugHooks[hookName] = hookFunc
  log(bWriteLog and string.format("ChatOperationHandler:RegisterDebugHook - Registered hook: %s", tostring(hookName)))
end
function ChatOperationHandler:ClearDebugHook(hookName)
  if not self.DebugHooks then
    return
  end
  if hookName then
    self.DebugHooks[hookName] = nil
    log(bWriteLog and string.format("ChatOperationHandler:ClearDebugHook - Cleared hook: %s", tostring(hookName)))
  else
    self.DebugHooks = nil
    log(bWriteLog and "ChatOperationHandler:ClearDebugHook - Cleared all hooks")
  end
end
function ChatOperationHandler:ReportAICopilotSceneEditSuccessToServer(duration)
  log(bWriteLog and string.format("ChatOperationHandler:ReportAICopilotSceneEditSuccessToServer duration:%d", duration or -1))
  local uPlayerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
  if not uPlayerController or not slua.isValid(uPlayerController) then
    log(bWriteLog and "ChatOperationHandler:ReportAICopilotSceneEditSuccessToServer - PlayerController not valid")
    return
  end
  local TlogFeature = uPlayerController.CreativeTlogPlayerFeature
  if not TlogFeature then
    log(bWriteLog and "ChatOperationHandler:ReportAICopilotSceneEditSuccessToServer - CreativeTlogPlayerFeature not found")
    return
  end
  local successCount = 1
  local successDuration = duration and 0 < duration and duration or 0
  TlogFeature:ServerRPC_AddAICopilotSceneEditStat(successCount, successDuration)
  log(bWriteLog and string.format("ChatOperationHandler:ReportAICopilotSceneEditSuccessToServer - Reported count:%d, duration:%d", successCount, successDuration))
end
local class = require("class")
local object = require("object")
return class(object, nil, ChatOperationHandler)