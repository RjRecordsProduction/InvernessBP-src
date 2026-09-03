local ChatSessionManager = {Owner = nil}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
function ChatSessionManager:ctor()
end
function ChatSessionManager:OnInitialize()
  self:ResetData()
end
function ChatSessionManager:ResetData()
  self.CurrentChatID = nil
  self.ChatHistory = {}
  self.ChatId2MessageDetail = {}
  self.ActiveChat = {
    ChatID = nil,
    Title = "",
    StartAt = 0,
    Messages = {},
    AIMessage = nil,
    PendingUserMsg = nil
  }
  self.TraceID2ChatID = {}
  self.LastActivityTime = 0
  self.DailyQuestionWasShown = false
end
function ChatSessionManager:GetCurrentChatID()
  return self.CurrentChatID
end
function ChatSessionManager:GetActiveChatData()
  return self.ActiveChat
end
function ChatSessionManager:GetActiveChatMessages()
  return self.ActiveChat and self.ActiveChat.Messages or {}
end
function ChatSessionManager:GetActiveAIMessage()
  return self.ActiveChat and self.ActiveChat.AIMessage or nil
end
function ChatSessionManager:HasActiveChat()
  return self.CurrentChatID ~= nil or #self.ActiveChat.Messages > 0
end
function ChatSessionManager:HasCurrentChatID()
  return self.CurrentChatID ~= nil
end
function ChatSessionManager:HasAnyChat()
  return self.CurrentChatID ~= nil or #self.ChatHistory > 0 or 0 < #self.ActiveChat.Messages
end
function ChatSessionManager:FindChatInHistory(chat_id)
  if not chat_id or not self.ChatHistory then
    return false
  end
  for _, chat in ipairs(self.ChatHistory) do
    if chat.chat_id == chat_id then
      return true
    end
  end
  return false
end
function ChatSessionManager:FinalizeAIMessageAndUpdateHistory(bSendCompleteEvent, bSendHistoryUpdateEvent)
  if bSendCompleteEvent == nil then
    bSendCompleteEvent = true
  end
  if bSendHistoryUpdateEvent == nil then
    bSendHistoryUpdateEvent = true
  end
  print(bWriteLog and "ChatSessionManager:FinalizeAIMessageAndUpdateHistory - [DEPRECATED] This method is deprecated as AIMessage is now added to Messages upon creation")
  self:AddCurrentChatToHistory()
  if bSendCompleteEvent then
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, self.ActiveChat)
  end
  if bSendHistoryUpdateEvent then
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HISTORY_UPDATE, self.ChatHistory)
  end
  return false
end
function ChatSessionManager:AddCurrentChatToHistory()
  local currentTime = os.time()
  if self.CurrentChatID and not self:FindChatInHistory(self.CurrentChatID) then
    table.insert(self.ChatHistory, {
      chat_id = self.CurrentChatID,
      title = self.ActiveChat.Title,
      start_at = self.ActiveChat.StartAt or currentTime,
      last_active = currentTime
    })
    print(bWriteLog and string.format("ChatSessionManager:AddCurrentChatToHistory - New chat added to history: %s", tostring(self.CurrentChatID)))
    return true
  end
  return false
end
function ChatSessionManager:FinalizeCurrentAIMessageBeforeNewMessage()
  print(bWriteLog and "ChatSessionManager:FinalizeCurrentAIMessageBeforeNewMessage - [DEPRECATED] AIMessage is now added to Messages upon creation")
  return false
end
function ChatSessionManager:GetChatMessageDetailInCache(chat_id)
  return self.ChatId2MessageDetail[chat_id]
end
function ChatSessionManager:GetChatIDByTraceID(trace_id)
  return self.TraceID2ChatID[trace_id]
end
function ChatSessionManager:GetMessageDetailByTraceId(trace_id)
  local chat_id = self:GetChatIDByTraceID(trace_id)
  if chat_id then
    if self.ActiveChat and chat_id == self.ActiveChat.ChatID then
      if self.ActiveChat.AIMessage and self.ActiveChat.AIMessage.TraceID == trace_id then
        return self.ActiveChat.AIMessage
      end
      if self.ActiveChat.Messages and #self.ActiveChat.Messages > 0 then
        for _, Message in ipairs(self.ActiveChat.Messages) do
          if Message.TraceID == trace_id then
            return Message
          end
        end
      end
      return
    end
    local MessageDetail = self:GetChatMessageDetailInCache(chat_id)
    if MessageDetail and 0 < #MessageDetail then
      for _, Message in ipairs(MessageDetail) do
        if Message.TraceID == trace_id then
          return Message
        end
      end
    end
    return MessageDetail
  else
    print(bWriteLog and "ChatSessionManager:GetMessageDetailByTraceId - ChatID not found for TraceID: " .. tostring(trace_id))
    if self.ActiveChat then
      if self.ActiveChat.AIMessage and self.ActiveChat.AIMessage.TraceID == trace_id then
        return self.ActiveChat.AIMessage
      end
      if self.ActiveChat.Messages and #self.ActiveChat.Messages > 0 then
        for _, Message in ipairs(self.ActiveChat.Messages) do
          if Message.TraceID == trace_id then
            return Message
          end
        end
      end
    end
  end
end
function ChatSessionManager:SetTraceDetailByKey(trace_id, key, value)
  print(bWriteLog and "ChatSessionManager:SetTraceDetailByKey TraceId = " .. tostring(trace_id))
  print(bWriteLog and "ChatSessionManager:SetTraceDetailByKey Key = " .. tostring(key))
  print(bWriteLog and "ChatSessionManager:SetTraceDetailByKey Value = " .. tostring(value))
  local MessageDetail = self:GetMessageDetailByTraceId(trace_id)
  if MessageDetail then
    MessageDetail[key] = value
    return true
  end
  return false
end
function ChatSessionManager:GetTraceDetailByKey(trace_id, key)
  local MessageDetail = self:GetMessageDetailByTraceId(trace_id)
  if MessageDetail then
    return MessageDetail[key]
  end
end
function ChatSessionManager:ClearCurrentChatContext(bAllowRedunantClear, Reason)
  print(bWriteLog and "ChatSessionManager:ClearCurrentChatContext - called")
  if self.Owner.MessageHandler then
    self.Owner.MessageHandler:CancelAllAsyncInteractions()
  end
  local currentState = self.Owner.StateMachine:GetCurrentState()
  local allowedStates = {
    [Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE] = true,
    [Config_UGC_Copilot.Enum_UGC_LLM_State.ERROR] = true
  }
  if not allowedStates[currentState] then
    print(bWriteLog and "ClearCurrentChatContext failed: concurrent request in state " .. tostring(currentState))
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST
  end
  if self.CurrentChatID == nil and not bAllowRedunantClear then
    print(bWriteLog and "ClearCurrentChatContext failed: no active chat")
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_TRANSITION
  end
  if self.ActiveChat and self.ActiveChat.Messages then
    for i = #self.ActiveChat.Messages, 1, -1 do
      local message = self.ActiveChat.Messages[i]
      if message and message.Content and type(message.Content) == "table" then
        for j = #message.Content, 1, -1 do
          local subMessage = message.Content[j]
          if subMessage and subMessage.type then
            local messageType = subMessage.type
            local messageConfig = Config_UGC_Copilot.GetCopilotMessageTypeConfig(messageType)
            if messageConfig and messageConfig.OnContextClear then
              print(bWriteLog and "Found OnContextClear handler for sub-message type: " .. tostring(messageType) .. " in message at index " .. i)
              messageConfig.OnContextClear(message, self.ActiveChat.Messages, i, self.CurrentChatID, Reason)
              break
            end
          end
        end
      end
    end
    if self.ActiveChat and self.ActiveChat.AIMessage then
      local message = self.ActiveChat.AIMessage
      for j = #message.Content, 1, -1 do
        local subMessage = message.Content[j]
        if subMessage and subMessage.type then
          local messageType = subMessage.type
          local messageConfig = Config_UGC_Copilot.GetCopilotMessageTypeConfig(messageType)
          if messageConfig and messageConfig.OnContextClear then
            print(bWriteLog and "Found OnContextClear handler for ai sub-message type: " .. tostring(messageType))
            messageConfig.OnContextClear(message, {
              self.ActiveChat.AIMessage
            }, 1, self.CurrentChatID, Reason)
            break
          end
        end
      end
      self:FinalizeAIMessageAndUpdateHistory(false, false)
    end
    if self.CurrentChatID then
      self.ChatId2MessageDetail[self.CurrentChatID] = self.ActiveChat.Messages or {}
    end
  end
  self.Owner.StateMachine.ActiveTraceID = nil
  local oldChatID = self.CurrentChatID
  self.CurrentChatID = nil
  self.ActiveChat = {
    ChatID = nil,
    Title = "",
    StartAt = 0,
    Messages = {},
    AIMessage = nil
  }
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CHAT_SWITCHED, {
    oldChatID = oldChatID,
    newChatID = nil,
    reason = "clear_context"
  })
  if currentState ~= Config_UGC_Copilot.Enum_UGC_LLM_State.ERROR then
    self.Owner.StateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "ContextCleared")
  end
  self.CurCodeTaskContext = nil
  print(bWriteLog and "Current chat context cleared.")
  return 0
end
function ChatSessionManager:UpdateSessionActivity()
  self.LastActivityTime = os.time()
  print(bWriteLog and string.format("Session activity updated at %d", self.LastActivityTime))
end
function ChatSessionManager:_CheckMessageLimitAndStartNewSession(ExtInfo)
  if not self.CurrentChatID or not self.ActiveChat then
    return
  end
  local GetMaxIdleTime = function()
    return 300
  end
  local currentTime = os.time()
  local idleTime = currentTime - self.LastActivityTime
  local bIsStale = self.Owner.StateMachine:IsMessageStale(self.CurrentChatID)
  local bNeedNewSession = false
  local reason = ""
  if idleTime >= GetMaxIdleTime() then
    bNeedNewSession = true
    reason = string.format("Session timed out after %d seconds", idleTime)
  elseif bIsStale then
    bNeedNewSession = true
    reason = "Message is stale"
  end
  if not bNeedNewSession and ExtInfo then
    local requestedSceneID = ExtInfo.subscene or 0
    local currentChatIDStr = tostring(self.CurrentChatID)
    local lastUnderscorePos = currentChatIDStr:find("_[^_]*$")
    if lastUnderscorePos then
      local subsceneIDStr = currentChatIDStr:sub(lastUnderscorePos + 1)
      local currentSubsceneID = tonumber(subsceneIDStr)
      if currentSubsceneID then
        local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
        local isRequestedExclusive = Config_UGC_Copilot.IsExclusiveChatScene(requestedSceneID)
        local isCurrentExclusive = Config_UGC_Copilot.IsExclusiveChatScene(currentSubsceneID)
        if isRequestedExclusive and currentSubsceneID ~= requestedSceneID or not isRequestedExclusive and isCurrentExclusive then
          bNeedNewSession = true
          reason = string.format("Scene conflict: current=%s, requested=%s", tostring(currentSubsceneID), tostring(requestedSceneID))
        end
      end
    end
  end
  if bNeedNewSession then
    local oldChatID = self.CurrentChatID
    self:ClearCurrentChatContext(true)
    self.Owner.MessageHandler:SendSystemMsg(Config_UGC_Copilot.Enum_UGC_System_Msg.START_NEW_CHAT)
    log(bWriteLog and string.format("ChatSessionManager:_CheckMessageLimitAndStartNewSession %s. Old chat: %s", reason, tostring(oldChatID)))
  end
end
function ChatSessionManager:Debug_StoreUGCHistoryToLocalBinaryFile()
  print(bWriteLog and "ChatSessionManager:Debug_StoreUGCHistoryToLocalBinaryFile")
  local StatusDictionary = {
    ChatHistory = self.ChatHistory,
    ChatId2MessageDetail = self.ChatId2MessageDetail,
    ActiveChat = self.ActiveChat,
    ActiveTraceID = self.Owner.StateMachine.ActiveTraceID,
    Version = 1
  }
  local success, SerializedStatusDict = pcall(json.encode, StatusDictionary)
  if not success then
    print(string.format("ChatSessionManager: Failed to encode debug data, error: %s", tostring(SerializedStatusDict)))
    return false
  end
  local filePath = self:Debug_GetSavedStatJsonPath()
  local file, errorMsg = io.open(filePath, "w")
  if not file then
    print(string.format("ChatSessionManager: Failed to open file %s for writing, error: %s", filePath, errorMsg))
    return false
  end
  local writeSuccess, writeError = pcall(function()
    file:write(SerializedStatusDict)
    file:close()
  end)
  if writeSuccess then
    print(string.format("ChatSessionManager: Debug data saved successfully to %s", filePath))
  else
    print(string.format("ChatSessionManager: Failed to save debug data to %s, error: %s", filePath, writeError))
  end
  return writeSuccess
end
function ChatSessionManager:Debug_LoadLocalBinaryFile()
  print(bWriteLog and "ChatSessionManager:Debug_LoadLocalBinaryFile")
  local filePath = self:Debug_GetSavedStatJsonPath()
  local file = io.open(filePath, "r")
  if not file then
    print(string.format("ChatSessionManager: Debug data file not found at %s", filePath))
    return false
  end
  local fileContent = file:read("*a")
  file:close()
  if not fileContent or fileContent == "" then
    print(string.format("ChatSessionManager: File is empty or could not be read from %s", filePath))
    return false
  end
  local success, StatusDictionary = pcall(json.decode, fileContent)
  if not success then
    print(string.format("ChatSessionManager: Failed to parse JSON data from %s, error: %s", filePath, StatusDictionary))
    return false
  end
  if not StatusDictionary or type(StatusDictionary) ~= "table" then
    print(string.format("ChatSessionManager: Invalid data format in %s", filePath))
    return false
  end
  self.ChatHistory = StatusDictionary.ChatHistory or {}
  self.ChatId2MessageDetail = StatusDictionary.ChatId2MessageDetail or {}
  self.ActiveChat = StatusDictionary.ActiveChat or self.ActiveChat
  if StatusDictionary.ActiveTraceID then
    self.Owner.StateMachine:SetActiveTraceID(StatusDictionary.ActiveTraceID)
  end
  print(string.format("ChatSessionManager: Debug data loaded successfully from %s", filePath))
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HISTORY_UPDATE, self.ChatHistory)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CHAT_LOADED, self.ActiveChat)
  return true
end
function ChatSessionManager:Debug_GetSavedStatJsonPath()
  return Client.ProjectSavedDir() .. "/DebugCopilotStatDict.json"
end
function ChatSessionManager:FindNextUnloadedChat(current_chat_id)
  if type(self.ChatHistory) ~= "table" or #self.ChatHistory == 0 then
    return nil
  end
  if not current_chat_id or current_chat_id == "" then
    return self.ChatHistory[#self.ChatHistory].chat_id
  end
  local found = false
  for i = #self.ChatHistory, 1, -1 do
    local chat = self.ChatHistory[i]
    if type(chat) == "table" and type(chat.chat_id) == "string" then
      if found then
        return chat.chat_id
      end
      if chat.chat_id == current_chat_id then
        found = true
      end
    end
  end
  return nil
end
function ChatSessionManager:GetMapID()
  local bIsInFighting = GameStatus and GameStatus.IsInFightingNotMainCity()
  if bIsInFighting then
    local CreativeModeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
    return CreativeModeUtility:GetDraftModUniqueID()
  else
    return "0"
  end
end
function ChatSessionManager:ClearChatHistory()
  print(bWriteLog and "ChatSessionManager:ClearChatHistory")
  local currentState = self.Owner.StateMachine:GetCurrentState()
  local allowedStates = {
    [Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE] = true,
    [Config_UGC_Copilot.Enum_UGC_LLM_State.ERROR] = true
  }
  if not allowedStates[currentState] then
    print(bWriteLog and "ChatSessionManager:ClearChatHistory: concurrent request in state " .. tostring(currentState))
    return Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST
  end
  if #self.ChatHistory > 0 then
    self.Owner.NetworkProtocolFeature:SendUGCLLMChatClearSessionsReq(self:GetMapID())
  end
  self:ResetData()
  if currentState ~= Config_UGC_Copilot.Enum_UGC_LLM_State.ERROR then
    self.Owner.StateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE, "ContextCleared")
  end
  self.Owner.StateMachine:ClearActiveStates()
  return 0
end
local class = require("class")
local object = require("object")
return class(object, nil, ChatSessionManager)