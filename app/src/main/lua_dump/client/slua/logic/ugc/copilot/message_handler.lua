local MessageHandler = {Owner = nil}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local TableUtil = require("common.table_util")
function MessageHandler:ctor()
end
function MessageHandler:OnInitialize()
  self:ResetData()
end
function MessageHandler:ResetData()
  self.PendingAsyncInteractions = {}
  self.RefImagePathCache = self.RefImagePathCache or {}
end
function MessageHandler:CacheRefImagePath(ObjectKey, LocalImagePath)
  if not (ObjectKey and ObjectKey ~= "" and LocalImagePath) or LocalImagePath == "" then
    return
  end
  if not self.RefImagePathCache then
    self.RefImagePathCache = {}
  end
  self.RefImagePathCache[ObjectKey] = LocalImagePath
end
function MessageHandler:GetCachedRefImagePath(ObjectKey)
  if not ObjectKey or ObjectKey == "" then
    return nil
  end
  return self.RefImagePathCache and self.RefImagePathCache[ObjectKey] or nil
end
function MessageHandler:CreateStandardMessage(Role, Content, TraceID, Options)
  local currentTime = os.time()
  Options = Options or {}
  local message = {
    Role = Role,
    Content = Content,
    TraceID = TraceID or "local-" .. tostring(currentTime),
    TS = Options.TS or currentTime,
    HideMessageBG = Options.HideMessageBG or false,
    HideFeedback = Options.HideFeedback or false,
    feedback = Options.feedback or {},
    Info = Options.Info or {}
  }
  return message
end
function MessageHandler:OnUserMsgInput(Content)
  local stateMachine = self.Owner.StateMachine
  if stateMachine:GetCurrentState() ~= Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING then
    return
  end
  local contentSegments = {
    {
      type = Config_UGC_Copilot.Enum_Copilot_MessageType.Messages,
      content = Content
    }
  }
  if self.PendingUserRefImage then
    table.insert(contentSegments, {
      type = Config_UGC_Copilot.Enum_Copilot_MessageType.UserRefImage,
      content = self.PendingUserRefImage
    })
    self.PendingUserRefImage = nil
  end
  local userMessage = self:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.User, contentSegments, "user-" .. tostring(os.time()), {HideFeedback = true})
  local activeChat = self.Owner.SessionManager.ActiveChat
  if self.Owner.NetworkProtocolFeature:GetInterfaceVersion() == 2 then
    activeChat.PendingUserMsg = userMessage
    self:SetLoadingOnTop(true)
    if self.Owner.SessionManager.CurrentChatID then
      self.Owner.SessionManager.TraceID2ChatID[userMessage.TraceID] = self.Owner.SessionManager.CurrentChatID
    end
  else
    local activeChat = self.Owner.SessionManager.ActiveChat
    table.insert(activeChat.Messages, userMessage)
    if not self.Owner.SessionManager.CurrentChatID or #activeChat.Messages == 1 then
      activeChat.Title = Content
    end
    self.Owner.SessionManager.TraceID2ChatID[userMessage.TraceID] = self.Owner.SessionManager.CurrentChatID
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, userMessage, userMessage.Content)
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, activeChat)
  end
end
function MessageHandler:OnUserInputConfirmed(bCanShow)
  local ActiveChat = self.Owner.SessionManager.ActiveChat
  if not ActiveChat then
    return
  end
  local LoadingMsg = self:SetLoadingOnTop(false)
  if self.Owner.NetworkProtocolFeature:GetInterfaceVersion() == 1 and self.Owner.SessionManager.ActiveChat and self.Owner.SessionManager.ActiveChat.Messages then
    LoadingMsg = self.Owner.SessionManager.ActiveChat.Messages[1]
  end
  if not bCanShow and LoadingMsg then
    ActiveChat.PendingUserMsg = nil
    LoadingMsg.Role = Config_UGC_Copilot.Enum_Copilot_RoleType.System
    LoadingMsg.Content[1].type = Config_UGC_Copilot.Enum_Copilot_MessageType.CensoredFailed
    LoadingMsg.HideMessageBG = true
    local LastMsg = LoadingMsg.Content[1]
    local Content = Util_UGC.GetLocalizeResStr(Config_UGC_Copilot.Enum_UGC_System_Msg.FORBIDDEN_CHAT)
    LoadingMsg.Content = {
      [1] = {
        type = Config_UGC_Copilot.Enum_Copilot_MessageType.System,
        content = Content
      },
      [2] = LastMsg
    }
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, LoadingMsg.TraceID, self.Owner.SessionManager.CurrentChatID, LoadingMsg)
    return
  end
  local UserMessage = ActiveChat.PendingUserMsg
  if UserMessage == nil then
    print(bWriteLog and "MessageHandler:OnUserInputConfirmed UserMessage == nil")
    return
  end
  if LoadingMsg == nil then
    print(bWriteLog and "MessageHandler:OnUserInputConfirmed LoadingMsg == nil")
    return
  end
  TableUtil.OverrideTable(LoadingMsg, UserMessage)
  if not self.Owner.SessionManager.CurrentChatID or #ActiveChat.Messages == 1 then
    local Content = UserMessage.Content[1].content
    ActiveChat.Title = Content
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, LoadingMsg.TraceID, self.Owner.SessionManager.CurrentChatID, LoadingMsg)
end
function MessageHandler:SetLoadingOnTop(bCanShow)
  print("MessageHandler:SetLoadingOnTop", bCanShow)
  local Messages = self.Owner.SessionManager.ActiveChat.Messages
  local TraceID
  if Messages and 0 < #Messages then
    for Idx = #Messages, 1, -1 do
      if Messages[Idx].Role == Config_UGC_Copilot.Enum_Copilot_RoleType.User then
        local LastUserMsg = Messages[Idx]
        if LastUserMsg.Content and LastUserMsg.Content[1].type == Config_UGC_Copilot.Enum_Copilot_MessageType.Censoring then
          LastUserMsg.HideMessageBG = false
          return LastUserMsg
        end
      end
    end
  end
  local ActiveChat = self.Owner.SessionManager.ActiveChat
  local UserMessage = ActiveChat.PendingUserMsg
  if UserMessage then
    TraceID = UserMessage.TraceID
    ActiveChat.HideMessageBG = false
    if bCanShow then
      self:SimulateUserResponse({ret = 0, msg = "success"}, {}, "", Config_UGC_Copilot.Enum_Copilot_MessageType.Censoring, TraceID, true)
    end
  else
    print(bWriteLog and "USerData missing")
  end
end
function MessageHandler:SendSystemMsg(Content)
  if Content == nil then
    return
  end
  Content = Util_UGC.GetLocalizeResStr(Content)
  local systemMessage = self:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.System, {
    {
      type = Config_UGC_Copilot.Enum_Copilot_MessageType.System,
      content = Content
    }
  }, "system-" .. tostring(os.time()))
  local activeChat = self.Owner.SessionManager.ActiveChat
  table.insert(activeChat.Messages, systemMessage)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, systemMessage, systemMessage.Content, 0, true)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, activeChat)
end
function MessageHandler:RevokeLastUserMessage()
  local messages = self.Owner.SessionManager.ActiveChat.Messages
  if not messages or #messages == 0 then
    return
  end
  for i = #messages, 1, -1 do
    if messages[i].Role == Config_UGC_Copilot.Enum_Copilot_RoleType.User then
      local lastUserMsg = messages[i]
      for _, segment in ipairs(lastUserMsg.Content) do
        if segment.type == Config_UGC_Copilot.Enum_Copilot_MessageType.Messages then
          segment.content = "***"
        end
      end
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, lastUserMsg.TraceID, self.Owner.SessionManager.CurrentChatID, lastUserMsg)
      return
    end
  end
end
function MessageHandler:RevokeAIMessageByTraceID(traceId)
  print(bWriteLog and string.format("MessageHandler:RevokeAIMessageByTraceID - called with traceID: %s", traceId))
  if not traceId then
    return
  end
  local sessionManager = self.Owner.SessionManager
  local targetMsg
  local isActiveMessage = false
  if sessionManager.ActiveChat.AIMessage and sessionManager.ActiveChat.AIMessage.TraceID == traceId then
    targetMsg = sessionManager.ActiveChat.AIMessage
    isActiveMessage = true
    print(bWriteLog and "Found target message in ActiveChat.AIMessage")
  else
    local messages = sessionManager.ActiveChat.Messages
    if messages and 0 < #messages then
      for i = #messages, 1, -1 do
        local msg = messages[i]
        if msg.Role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant and msg.TraceID == traceId then
          targetMsg = msg
          break
        end
      end
    end
  end
  if not targetMsg then
    print(bWriteLog and string.format("No AI message found with traceID: %s", traceId))
    return
  end
  local newContentText = LocUtil.GetLocalizeResStr(17005211)
  targetMsg.Content = {
    Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, newContentText)
  }
  targetMsg.questions = nil
  targetMsg.citations = nil
  targetMsg.images = nil
  self.Owner.StateMachine._RevokedTraceIDs[traceId] = true
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, traceId, sessionManager.CurrentChatID, targetMsg)
  print(bWriteLog and string.format("Revoked AI message. TraceID: %s, Source: %s", traceId, isActiveMessage and "ActiveChat.AIMessage" or "Messages"))
end
function MessageHandler:IsMessageExceedMaxLimit(Content)
  local MaxChar = Config_UGC_Copilot.Copilot_Consts.MAX_MSG_CHAR_CNT_CHAT
  local NowLen = Util_UGC.GetTextLengthAndSubStr(Content, MaxChar)
  return MaxChar < NowLen
end
function MessageHandler:SetActiveChatReportData(chatID, traceID, action)
  local feedback = {
    likes = action == 1 and 1 or 0,
    dislikes = action == 1 and 0 or 1
  }
  local activeChat = self.Owner.SessionManager.ActiveChat
  if activeChat.ChatID == chatID then
    for _, v in pairs(activeChat.Messages) do
      if v.TraceID == traceID then
        v.        return
      end
    end
  end
end
function MessageHandler:ConvertChatDataToStandardFormat(chat_data)
  local formatted_data = {
    ChatID = chat_data.chat_id,
    Title = chat_data.title,
    StartAt = chat_data.start_at,
    Messages = {},
    AIMessage = nil
  }
  local bActiveChat = true
  if not chat_data.messages then
    return formatted_data
  end
  log_tree(" MessageHandler:ConvertChatDataToStandardFormat", chat_data.messages)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local FileType = PlayerPrefsSystem.ePlayerPrefsType.eUGCAICopilotReportData
  local SavedData = PlayerPrefsSystem.LoadFileToTable_N(FileType)
  SavedData = SavedData and SavedData[chat_data.chat_id] or {}
  for _, msg in ipairs(chat_data.messages) do
    local isUserMessage = msg.role == Config_UGC_Copilot.Enum_Copilot_RoleType.User
    local formatted_msg = {
      Role = msg.role,
      TraceID = msg.trace_id or "history-" .. tostring(msg.ts or os.time()),
      TS = msg.ts,
      Info = msg.info or {},
      feedback = msg.feedback or msg.feedback_status or {},
      Content = {},
      HideMessageBG = false,
      HideFeedback = isUserMessage
    }
    formatted_msg.feedback.Report = formatted_msg.feedback.report or nil
    if msg.role == Config_UGC_Copilot.Enum_Copilot_RoleType.User then
      table.insert(formatted_msg.Content, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, msg.content or "", msg.role))
    elseif msg.role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
      if SavedData[formatted_msg.TraceID] then
        formatted_msg.feedback = formatted_msg.feedback or {}
        formatted_msg.feedback.Report = 1
      end
      local msgType = msg.type
      if msg.feedback_status and msg.feedback_status.terminate == 1 then
        table.insert(formatted_msg.Content, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, LocUtil.GetLocalizeResStr(97000036), Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant))
        formatted_msg.HideFeedback = true
        bActiveChat = false
      else
        if Config_UGC_Copilot.IsLongTaskType(msgType) then
          local status = msg.status or 0
          if status == -1 then
            Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_GEN, tonumber(msg.result) or -1, Config_UGC_Copilot.ErrorOutputType.HISTORY, {formattedMsg = formatted_msg})
          elseif status == 0 and self.Owner.StateMachine.CurrentState == Config_UGC_Copilot.Enum_UGC_LLM_State.INITIALIZING then
            local GenContext = {
              trace_id = msg.trace_id,
              [Config_UGC_Copilot.Enum_Copilot_MessageType.GenPrecheck] = {
                predict_duration = 60,
                precheck_result = 0,
                error_msg = "",
                gen_type = msg.type
              },
              StartTime = msg.timestamp / 1000.0
            }
            if msg.timestamp and os.time() - msg.timestamp / 1000.0 > 120 then
              table.insert(formatted_msg.Content, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, LocUtil.GetLocalizeResStr(97000042), Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant))
              bActiveChat = false
            else
              self:SimulateInGenResponsePending(msg.trace_id, GenContext)
              table.insert(formatted_msg.Content, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.InGeneration, GenContext, Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant))
              formatted_msg.HideFeedback = true
              formatted_msg.HideMessageBG = true
            end
          end
        end
        if msg.content_struct and type(msg.content_struct) == "table" then
          for _, deltaData in ipairs(msg.content_struct) do
            local deltaDataType = deltaData.type
            local deltaDataTypeConfig = Config_UGC_Copilot.Copilot_MessageTypeConfig[deltaDataType]
            local wasSplit = Config_UGC_Copilot.HandleMessageSplitting(deltaData, formatted_msg.Content, formatted_msg.trace_id)
            if not wasSplit and deltaData.type then
              table.insert(formatted_msg.Content, deltaData)
            end
            if deltaDataTypeConfig and deltaDataTypeConfig.PreCheck then
              deltaDataTypeConfig.PreCheck(deltaData, formatted_msg.trace_id, formatted_msg)
            end
          end
        elseif msg.content then
          table.insert(formatted_msg.Content, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, msg.content, msg.role))
        end
      end
    end
    table.insert(formatted_data.Messages, formatted_msg)
  end
  return formatted_data, bActiveChat
end
function MessageHandler:SimulateAIResponse(errorData, cbData, responseContent, MsgRole, MsgType, TraceID, ExtData)
  local sessionManager = self.Owner.SessionManager
  ExtData = ExtData or {}
  local simulatedMessage = self:CreateStandardMessage(MsgRole or Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {
    {
      type = MsgType or Config_UGC_Copilot.Enum_Copilot_MessageType.Messages,
      content = responseContent
    }
  }, TraceID, {
    HideMessageBG = ExtData.HideMessageBG or false,
    HideFeedback = ExtData.HideFeedback or false,
    Info = {
      simulated = true,
      original_error = {
        code = errorData and errorData.ret,
        message = errorData and errorData.msg
      }
    }
  })
  table.insert(sessionManager.ActiveChat.Messages, simulatedMessage)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, simulatedMessage, simulatedMessage.Content, 0, true)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, sessionManager.ActiveChat)
  sessionManager:AddCurrentChatToHistory()
  print(bWriteLog and string.format("MessageHandler:SimulateAIResponse - Simulated message added: %s", responseContent))
end
function MessageHandler:SimulateUserResponse(errorData, cbData, responseContent, MsgType, TraceID, bHideBg)
  local sessionManager = self.Owner.SessionManager
  local simulatedMessage = self:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.User, {
    {
      type = MsgType or Config_UGC_Copilot.Enum_Copilot_MessageType.Messages,
      content = responseContent
    }
  }, TraceID or "local-simulated-user-" .. tostring(os.time()), {
    HideMessageBG = bHideBg == true,
    HideFeedback = true,
    Info = {
      simulated = true,
      original_error = {
        code = errorData and errorData.ret,
        message = errorData and errorData.msg
      }
    }
  })
  table.insert(sessionManager.ActiveChat.Messages, simulatedMessage)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, simulatedMessage, simulatedMessage.Content, 0, true)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, sessionManager.ActiveChat)
  sessionManager:AddCurrentChatToHistory()
  print(bWriteLog and string.format("MessageHandler:SimulateUserResponse - Simulated user message added: %s", responseContent))
end
function MessageHandler:SimulateAdvancedMessage(TraceID, TType, Data, ExtData)
  local sessionManager = self.Owner.SessionManager
  local messages = sessionManager.ActiveChat.Messages
  local targetMessage
  ExtData = ExtData or {}
  local bHideFeedback = ExtData.HideFeedback or false
  local bHideMessageBG = ExtData.HideMessageBG or false
  local bClearContent = ExtData.ClearContent or false
  if TraceID and messages and 0 < #messages then
    for i = #messages, 1, -1 do
      if messages[i].TraceID == TraceID then
        targetMessage = messages[i]
        break
      end
    end
  end
  if targetMessage then
    print(bWriteLog and string.format("MessageHandler:SimulateAdvancedMessage - Found message with TraceID '%s'. Merging content.", TraceID))
    if bClearContent then
      print(bWriteLog and string.format("MessageHandler:SimulateAdvancedMessage - Clearing all content for TraceID '%s'", TraceID))
      targetMessage.Content = {}
    end
    if TType and Data then
      local newContentSegment = {type = TType, content = Data}
      table.insert(targetMessage.Content, newContentSegment)
    end
    if not bClearContent then
      for i = #targetMessage.Content, 1, -1 do
        local message = targetMessage.Content[i]
        if message.type == Config_UGC_Copilot.Enum_Copilot_MessageType.InGeneration then
          table.remove(targetMessage.Content, i)
        end
      end
    end
    targetMessage.HideFeedback = bHideFeedback
    targetMessage.HideMessageBG = bHideMessageBG
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, TraceID, sessionManager.CurrentChatID, targetMessage)
    return
  end
  print(bWriteLog and string.format("MessageHandler:SimulateAdvancedMessage - No message found with TraceID '%s'. Creating a new message.", TraceID or "nil"))
  local simulatedMessage = self:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {
    {type = TType, content = Data}
  }, TraceID or "local-advanced-" .. tostring(os.time()), {HideFeedback = bHideFeedback, HideMessageBG = bHideMessageBG})
  table.insert(sessionManager.ActiveChat.Messages, simulatedMessage)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, simulatedMessage, simulatedMessage.Content, 0, true)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, sessionManager.ActiveChat)
  sessionManager:AddCurrentChatToHistory()
end
function MessageHandler:SimulateInGenResponsePending(TraceID, InGenData)
  local stateMachine = self.Owner.StateMachine
  stateMachine:SimulateInGenResponsePending(TraceID, InGenData)
end
function MessageHandler:SendDailyQuestionMsg(Questions)
  print(bWriteLog and "MessageHandler:SendDailyQuestionMsg - called" or "")
  if not Questions or #Questions == 0 then
    return
  end
  local sessionManager = self.Owner.SessionManager
  for _, v in pairs(sessionManager.ActiveChat.Messages) do
    if v.Params and v.Params == "DailyQuestion" then
      print(bWriteLog and "Daily question already exists in messages. Aborting.")
      return
    end
  end
  if sessionManager.DailyQuestionWasShown then
    print(bWriteLog and "Daily question was already shown in this session. Aborting.")
    return
  end
  sessionManager.DailyQuestionWasShown = true
  local dailyQuestionMessage = self:CreateStandardMessage(Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {
    {
      type = Config_UGC_Copilot.Enum_Copilot_MessageType.Questions,
      content = Questions,
      isDailyQuestion = true
    }
  }, "DailyQuestion-" .. tostring(os.time()))
  dailyQuestionMessage.Params = "DailyQuestion"
  table.insert(sessionManager.ActiveChat.Messages, dailyQuestionMessage)
  print(bWriteLog and "Daily question message added to ActiveChat.Messages")
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_PARTIAL, dailyQuestionMessage, dailyQuestionMessage.Content, 0, true)
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_COMPLETE, sessionManager.ActiveChat)
  print(bWriteLog and "Daily question message processing complete")
end
function MessageHandler:OnInteraction(data, cb_data)
  print(bWriteLog and "MessageHandler:OnInteraction - called" or "")
  local MapID = self.Owner.SessionManager:GetMapID()
  local ChatID = cb_data.chat_id or ""
  local TraceID = cb_data.trace_id or ""
  print(bWriteLog and "MessageHandler:OnInteraction - MapID: " .. tostring(MapID) .. ", ChatID: " .. tostring(ChatID) .. ", TraceID: " .. tostring(TraceID))
  if not (MapID and ChatID) or not TraceID then
    print(bWriteLog and "MessageHandler:OnInteraction - MapID, ChatID, or TraceID is nil")
    return
  end
  local seq_id = data.seq_id or "none"
  local ttype = data.type or "none"
  print("ChatOperationHandler:OnAIMessageNetworkRsp Interaction: seq_id = " .. seq_id .. ", type = " .. ttype)
  data.start_time = os.time()
  data.status = data.status or Config_UGC_Copilot.InteractionStatusEnum.Pending
  local InteractionConfig = Config_UGC_Copilot.InteractionConfig[ttype]
  if InteractionConfig and InteractionConfig.InitUIState then
    data.ui_state = InteractionConfig.InitUIState(data)
  end
  local CurrentDetail = self.Owner.SessionManager:GetTraceDetailByKey(TraceID, Config_UGC_Copilot.MessageDetailKeyEnum.InteractionDetails) or {}
  CurrentDetail[tonumber(seq_id)] = data
  self.Owner.SessionManager:SetTraceDetailByKey(TraceID, Config_UGC_Copilot.MessageDetailKeyEnum.InteractionDetails, CurrentDetail)
  if InteractionConfig and InteractionConfig.bAsync then
    self:StartAsyncInteraction(TraceID, seq_id, ttype, data, cb_data, InteractionConfig)
  else
    if InteractionConfig and InteractionConfig.OnInteractionHandler then
      InteractionConfig.OnInteractionHandler(TraceID, data)
    end
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_INTERACTION_UPDATE, TraceID)
    local LLMHandler = require("client.network.Protocol.LLMHandler")
    LLMHandler.send_ugc_llm_client_interact_result_req(MapID, ChatID, TraceID, data)
  end
  print(bWriteLog and "MessageHandler:OnInteraction - data: " .. tostring(data))
end
function MessageHandler:StartAsyncInteraction(TraceID, seq_id, ttype, data, cb_data, InteractionConfig)
  print(bWriteLog and "MessageHandler:StartAsyncInteraction - TraceID: " .. tostring(TraceID) .. ", type: " .. tostring(ttype))
  local TimeoutSeconds = InteractionConfig.TimeoutSeconds or 30
  self.PendingAsyncInteractions[TraceID] = {
    seq_id = seq_id,
    ttype = ttype,
    data = data,
    cb_data = cb_data,
    start_time = os.time(),
    timer_handle = nil,
    countdown_timer_handle = nil,
    result_data = nil
  }
  if self.Owner and self.Owner.AddGameTimer then
    self.PendingAsyncInteractions[TraceID].timer_handle = self.Owner:AddGameTimer(TimeoutSeconds, false, function()
      self:OnAsyncInteractionTimeout(TraceID)
    end)
  end
  local ui_state = data.ui_state
  if ui_state and ui_state.countdown_duration and self.Owner and self.Owner.AddGameTimer then
    local countdownDuration = ui_state.countdown_duration
    print(bWriteLog and "MessageHandler:StartAsyncInteraction - Setting up countdown timer: " .. tostring(countdownDuration) .. "s")
    self.PendingAsyncInteractions[TraceID].countdown_timer_handle = self.Owner:AddGameTimer(countdownDuration, false, function()
      self:OnAsyncInteractionCountdownComplete(TraceID)
    end)
  end
  if InteractionConfig.OnInteractionHandler then
    InteractionConfig.OnInteractionHandler(TraceID, data, function(ResultData)
      self:OnAsyncInteractionComplete(TraceID, ResultData)
    end)
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_INTERACTION_UPDATE, TraceID)
end
function MessageHandler:OnAsyncInteractionCountdownComplete(TraceID)
  print(bWriteLog and "MessageHandler:OnAsyncInteractionCountdownComplete - TraceID: " .. tostring(TraceID))
  local PendingInfo = self.PendingAsyncInteractions[TraceID]
  if not PendingInfo then
    print(bWriteLog and "MessageHandler:OnAsyncInteractionCountdownComplete - No pending interaction for TraceID: " .. tostring(TraceID))
    return
  end
  local ui_state = PendingInfo.data.ui_state
  if ui_state and ui_state.completed then
    print(bWriteLog and "MessageHandler:OnAsyncInteractionCountdownComplete - Already completed, skipping")
    return
  end
  if ui_state then
    ui_state.completed = true
  end
  local InteractionConfig = Config_UGC_Copilot.InteractionConfig[PendingInfo.ttype]
  if InteractionConfig and InteractionConfig.BuildDefaultResult then
    local DefaultResultData = InteractionConfig.BuildDefaultResult(PendingInfo.data)
    print(bWriteLog and "MessageHandler:OnAsyncInteractionCountdownComplete - Built default result")
    if InteractionConfig.OnCountdownComplete then
      print(bWriteLog and "MessageHandler:OnAsyncInteractionCountdownComplete - Using OnCountdownComplete for async processing")
      InteractionConfig.OnCountdownComplete(TraceID, PendingInfo.data, DefaultResultData, function(FilteredResponse)
        self:OnAsyncInteractionComplete(TraceID, FilteredResponse)
      end)
    else
      self:OnAsyncInteractionComplete(TraceID, DefaultResultData)
    end
  else
    local ResultData = {
      seq_id = PendingInfo.data.seq_id,
      type = PendingInfo.ttype,
      selected = {},
      auto_completed = true
    }
    self:OnAsyncInteractionComplete(TraceID, ResultData)
  end
end
function MessageHandler:OnAsyncInteractionComplete(TraceID, ResultData)
  print(bWriteLog and "MessageHandler:OnAsyncInteractionComplete - TraceID: " .. tostring(TraceID))
  local PendingInfo = self.PendingAsyncInteractions[TraceID]
  if not PendingInfo then
    print(bWriteLog and "MessageHandler:OnAsyncInteractionComplete - No pending interaction for TraceID: " .. tostring(TraceID))
    return
  end
  if not self:IsTraceIDActive(TraceID) then
    print(bWriteLog and "MessageHandler:OnAsyncInteractionComplete - TraceID no longer active: " .. tostring(TraceID))
    self:CleanupAsyncInteraction(TraceID)
    return
  end
  if PendingInfo.timer_handle and self.Owner and self.Owner.RemoveGameTimer then
    self.Owner:RemoveGameTimer(PendingInfo.timer_handle)
  end
  local InteractionConfig = Config_UGC_Copilot.InteractionConfig[PendingInfo.ttype]
  if InteractionConfig and InteractionConfig.OnFinish then
    InteractionConfig.OnFinish(TraceID, PendingInfo.data, false, ResultData)
  end
  local bSkipProtocol = false
  if InteractionConfig and InteractionConfig.bSkipProtocolOnFailed then
    local errorCode = ResultData and ResultData.error_code
    if errorCode and errorCode ~= 0 then
      bSkipProtocol = true
      print(bWriteLog and "MessageHandler:OnAsyncInteractionComplete - bSkipProtocolOnFailed triggered, error_code: " .. tostring(errorCode))
    end
  end
  if not bSkipProtocol then
    local MapID = self.Owner.SessionManager:GetMapID()
    local ChatID = PendingInfo.cb_data.chat_id or ""
    local LLMHandler = require("client.network.Protocol.LLMHandler")
    LLMHandler.send_ugc_llm_client_interact_result_req(MapID, ChatID, TraceID, ResultData)
    print(bWriteLog and "MessageHandler:OnAsyncInteractionComplete - Sent result for TraceID: " .. tostring(TraceID))
  else
    print(bWriteLog and "MessageHandler:OnAsyncInteractionComplete - Skipped protocol for TraceID: " .. tostring(TraceID))
  end
  self:CleanupAsyncInteraction(TraceID)
end
function MessageHandler:OnAsyncInteractionTimeout(TraceID)
  print(bWriteLog and "MessageHandler:OnAsyncInteractionTimeout - TraceID: " .. tostring(TraceID))
  local PendingInfo = self.PendingAsyncInteractions[TraceID]
  if not PendingInfo then
    return
  end
  local ResponseData = {
    seq_id = PendingInfo.data.seq_id,
    type = PendingInfo.ttype,
    selected = {},
    error_code = -1,
    error_msg = "Async interaction timeout"
  }
  local InteractionConfig = Config_UGC_Copilot.InteractionConfig[PendingInfo.ttype]
  if InteractionConfig and InteractionConfig.OnFinish then
    InteractionConfig.OnFinish(TraceID, PendingInfo.data, true, ResponseData)
  end
  local bSkipProtocol = false
  if InteractionConfig and InteractionConfig.bSkipProtocolOnFailed then
    bSkipProtocol = true
    print(bWriteLog and "MessageHandler:OnAsyncInteractionTimeout - bSkipProtocolOnFailed triggered")
  end
  if not bSkipProtocol then
    local MapID = self.Owner.SessionManager:GetMapID()
    local ChatID = PendingInfo.cb_data.chat_id or ""
    local LLMHandler = require("client.network.Protocol.LLMHandler")
    LLMHandler.send_ugc_llm_client_interact_result_req(MapID, ChatID, TraceID, ResponseData)
    print(bWriteLog and "MessageHandler:OnAsyncInteractionTimeout - Sent timeout error for TraceID: " .. tostring(TraceID))
  else
    print(bWriteLog and "MessageHandler:OnAsyncInteractionTimeout - Skipped protocol for TraceID: " .. tostring(TraceID))
  end
  self:CleanupAsyncInteraction(TraceID)
end
function MessageHandler:CancelAsyncInteraction(TraceID)
  print(bWriteLog and "MessageHandler:CancelAsyncInteraction - TraceID: " .. tostring(TraceID))
  local PendingInfo = self.PendingAsyncInteractions[TraceID]
  if not PendingInfo then
    return
  end
  if PendingInfo.timer_handle and self.Owner and self.Owner.RemoveGameTimer then
    self.Owner:RemoveGameTimer(PendingInfo.timer_handle)
  end
  local MapID = self.Owner.SessionManager:GetMapID()
  local ChatID = PendingInfo.cb_data.chat_id or ""
  local ResponseData = PendingInfo.data
  ResponseData.result = {
    error_code = -2,
    error_msg = "Async interaction cancelled"
  }
  local LLMHandler = require("client.network.Protocol.LLMHandler")
  LLMHandler.send_ugc_llm_client_interact_result_req(MapID, ChatID, TraceID, ResponseData)
  self:CleanupAsyncInteraction(TraceID)
end
function MessageHandler:IsTraceIDActive(TraceID)
  local StateMachine = self.Owner.StateMachine
  if StateMachine._RevokedTraceIDs and StateMachine._RevokedTraceIDs[TraceID] then
    return false
  end
  local ActiveTraceID = StateMachine:GetActiveTraceID()
  if ActiveTraceID and ActiveTraceID ~= TraceID then
    local Messages = self.Owner.SessionManager.ActiveChat.Messages
    if Messages then
      for i = #Messages, 1, -1 do
        if Messages[i].TraceID == TraceID then
          return true
        end
      end
    end
    return false
  end
  return true
end
function MessageHandler:HasPendingAsyncInteraction(TraceID)
  return self.PendingAsyncInteractions[TraceID] ~= nil
end
function MessageHandler:CleanupAsyncInteraction(TraceID)
  local PendingInfo = self.PendingAsyncInteractions[TraceID]
  if PendingInfo then
    if PendingInfo.timer_handle and self.Owner and self.Owner.RemoveGameTimer then
      self.Owner:RemoveGameTimer(PendingInfo.timer_handle)
    end
    if PendingInfo.countdown_timer_handle and self.Owner and self.Owner.RemoveGameTimer then
      self.Owner:RemoveGameTimer(PendingInfo.countdown_timer_handle)
    end
    self.PendingAsyncInteractions[TraceID] = nil
  end
end
function MessageHandler:ExtendAsyncInteractionCountdown(TraceID, NewTotalDuration)
  print(bWriteLog and "MessageHandler:ExtendAsyncInteractionCountdown - TraceID: " .. tostring(TraceID) .. ", NewTotalDuration: " .. tostring(NewTotalDuration))
  local PendingInfo = self.PendingAsyncInteractions[TraceID]
  if not PendingInfo then
    print(bWriteLog and "MessageHandler:ExtendAsyncInteractionCountdown - No pending interaction for TraceID: " .. tostring(TraceID))
    return
  end
  local startTime = PendingInfo.start_time or os.time()
  local elapsed = os.time() - startTime
  local remainingTime = NewTotalDuration - elapsed
  print(bWriteLog and "MessageHandler:ExtendAsyncInteractionCountdown - Elapsed: " .. tostring(elapsed) .. "s, Remaining: " .. tostring(remainingTime) .. "s")
  if remainingTime <= 0 then
    print(bWriteLog and "MessageHandler:ExtendAsyncInteractionCountdown - Time already expired, triggering countdown complete")
    self:OnAsyncInteractionCountdownComplete(TraceID)
    return
  end
  if PendingInfo.countdown_timer_handle and self.Owner and self.Owner.RemoveGameTimer then
    self.Owner:RemoveGameTimer(PendingInfo.countdown_timer_handle)
    PendingInfo.countdown_timer_handle = nil
  end
  if self.Owner and self.Owner.AddGameTimer then
    PendingInfo.countdown_timer_handle = self.Owner:AddGameTimer(remainingTime, false, function()
      self:OnAsyncInteractionCountdownComplete(TraceID)
    end)
  end
end
function MessageHandler:CancelAllAsyncInteractions()
  print(bWriteLog and "MessageHandler:CancelAllAsyncInteractions")
  for TraceID, _ in pairs(self.PendingAsyncInteractions) do
    self:CancelAsyncInteraction(TraceID)
  end
end
local class = require("class")
local object = require("object")
return class(object, nil, MessageHandler)