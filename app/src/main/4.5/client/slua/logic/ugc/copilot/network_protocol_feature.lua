local NetworkProtocolFeature = {Owner = nil, InterfaceVersion = 2}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local UGCHandler = require("client.network.Protocol.UGCHandler")
local UGCAIHandler = require("client.network.Protocol.UGCAIHandler")
local LLMHandler = require("client.network.Protocol.LLMHandler")
local _IsChatRateLimitMockEnabled = function()
  local mockConfig = Config_UGC_Copilot.ChatRateLimitMock
  return _G.UGCCopilotMockChatRateLimit == true or mockConfig and mockConfig.Enable == true
end
local _BuildMockChatRateLimitPayload = function(chat_id, map_id)
  local mockConfig = Config_UGC_Copilot.ChatRateLimitMock or {}
  local traceID = "mock_rate_limit_" .. tostring(os.time())
  local chatID = chat_id and tostring(chat_id) or "mock_chat_rate_limit"
  local data = {
    trace_id = traceID,
    chat_id = chatID,
    task_type = mockConfig.TaskType or "task_ui",
    current_usage = mockConfig.CurrentUsage or 10,
    max_usage = mockConfig.MaxUsage or 10,
    next_available_time = mockConfig.NextAvailableTime or os.time() + 3600,
    reason = mockConfig.Reason or "ui_usage_limit"
  }
  local cbData = {
    map_id = map_id or "0",
    chat_id = chatID,
    trace_id = traceID
  }
  return data, cbData
end
function NetworkProtocolFeature:ctor()
  print(bWriteLog and "NetworkProtocolFeature:ctor")
end
function NetworkProtocolFeature:OnInitialize()
end
function NetworkProtocolFeature:RegistEvents()
end
function NetworkProtocolFeature:SetInterfaceVersion(version)
  if version == 1 or version == 2 then
    self.InterfaceVersion = version
    print(bWriteLog and "NetworkProtocolFeature:SetInterfaceVersion to " .. tostring(version))
  else
    print("Warning: Invalid interface version, must be 1 or 2")
  end
  if IsEditor then
    self.InterfaceVersion = 2
    print(bWriteLog and "NetworkProtocolFeature:SetInterfaceVersion force to 2")
  end
end
function NetworkProtocolFeature:GetInterfaceVersion()
  return self.InterfaceVersion
end
function NetworkProtocolFeature:SendChatMessage(chat_id, content, scene_id, map_id, ext_info)
  if _IsChatRateLimitMockEnabled() then
    local rateLimitData, cbData = _BuildMockChatRateLimitPayload(chat_id, map_id)
    local rateLimitEvent = Config_UGC_Copilot.MessageRspEvenToV2Chat[Config_UGC_Copilot.MessageRspEventTypeEnum.ChatRateLimit]
    local finishEvent = Config_UGC_Copilot.MessageRspEvenToV2Chat[Config_UGC_Copilot.MessageRspEventTypeEnum.Finish]
    log(bWriteLog and string.format("NetworkProtocolFeature:ChatRateLimitMock - trigger mock rate limit. trace_id=%s chat_id=%s map_id=%s usage=%s/%s next_available_time=%s reason=%s", tostring(cbData.trace_id), tostring(cbData.chat_id), tostring(cbData.map_id), tostring(rateLimitData.current_usage), tostring(rateLimitData.max_usage), tostring(rateLimitData.next_available_time), tostring(rateLimitData.reason)))
    self.Owner:AddTimerOnce(0.1, function()
      log(bWriteLog and string.format("NetworkProtocolFeature:ChatRateLimitMock - dispatch event=%s then finish=%s trace_id=%s", tostring(rateLimitEvent), tostring(finishEvent), tostring(cbData.trace_id)))
      self:OnAIMessageNetworkRsp(0, rateLimitEvent, rateLimitData, cbData)
      self:OnAIMessageNetworkRsp(0, finishEvent, {}, cbData)
    end)
    return
  end
  if self:GetInterfaceVersion() == 2 then
    local v2_chat_id = chat_id and tonumber(chat_id) or nil
    local v2_map_id = map_id or "0"
    local v2_ext_info = ext_info or {}
    if v2_ext_info.subscene == nil then
      v2_ext_info.subscene = 0
    end
    log(bWriteLog and string.format("[copilot_uigen:dsl:send] SendChatMessage v2 | chat_id=%s | scene_id=%s | map_id=%s | subscene=%s", tostring(chat_id), tostring(scene_id), tostring(v2_map_id), tostring(v2_ext_info.subscene)))
    log(bWriteLog and string.format("[copilot_uigen:dsl:send] SendChatMessage FINAL before protocol send | ui_dsl_length=%d | ui_dsl_type=%s", v2_ext_info.params and v2_ext_info.params.ui_dsl and #v2_ext_info.params.ui_dsl or -1, type(v2_ext_info.params and v2_ext_info.params.ui_dsl)))
    LLMHandler.send_ugc_llm_chat_message_v2_req(chat_id, scene_id, v2_map_id, content, v2_ext_info)
  else
    UGCAIHandler.send_ugc_llm_chat_message_req(chat_id, content, scene_id)
  end
end
function NetworkProtocolFeature:SendGetSessionsReq(map_id)
  if self:GetInterfaceVersion() == 2 then
    local v2_map_id = map_id or "0"
    print(string.format("[Copilot_Debug] SendGetSessionsReq - map_id: %s, traceback: %s", tostring(map_id), debug.traceback("", 2)))
    LLMHandler.send_ugc_llm_get_sessions_v2_req(v2_map_id)
  else
    UGCAIHandler.send_ugc_llm_get_sessions_req()
  end
end
function NetworkProtocolFeature:SendGetOneChatReq(chat_id, map_id)
  if self:GetInterfaceVersion() == 2 then
    local v2_    local v2_map_id = map_id or "0"
    LLMHandler.send_ugc_llm_one_chat_v2_req(v2_map_id, v2_chat_id)
  else
    UGCAIHandler.send_ugc_llm_one_chat_req(chat_id)
  end
end
function NetworkProtocolFeature:SendGetRecommendReq(scene_id)
  if self:GetInterfaceVersion() == 2 then
    LLMHandler.send_ugc_llm_get_recommend_v2_req(scene_id)
  else
    UGCAIHandler.send_ugc_llm_get_recommend_req(scene_id)
  end
end
function NetworkProtocolFeature:SendChatStopReq(trace_id, chat_id, map_id, stop_reason)
  if self:GetInterfaceVersion() == 2 then
    local v2_map_id = map_id or "0"
    local serverReason = Config_UGC_Copilot.StopChatReasonToServerReason[stop_reason] or 1
    LLMHandler.send_ugc_llm_chat_stop_v2_req(v2_map_id, serverReason)
  else
    local UGCAIHandler = require("client.network.Protocol.UGCAIHandler")
    UGCAIHandler.send_ugc_llm_chat_stop_req(trace_id)
  end
end
function NetworkProtocolFeature:SendGetLLMAgentDataReq()
  if self:GetInterfaceVersion() == 2 then
    self.Owner:AddTimerOnce(0.1, function()
      self.Owner:OnLLMQuotaRsp({
        day_limit = {limit = 99999, count = 0}
      })
    end)
  else
    UGCAIHandler.send_ugc_get_llm_agent_data_req()
  end
end
function NetworkProtocolFeature:SendLLMReq(prompt)
  UGCAIHandler.send_llm_generate_image_req(prompt)
end
function NetworkProtocolFeature:SendChatRatingReq(chat_id, trace_id, action)
  if self:GetInterfaceVersion() == 2 then
    LLMHandler.send_ugc_llm_chat_rating_v2_req(chat_id, trace_id, action)
  else
    print("Warning: Chat rating feature only available in v2 interface")
    UGCAIHandler.send_ugc_llm_chat_rating_req(chat_id, trace_id, action)
  end
end
function NetworkProtocolFeature:SendChatOpResultReq(chat_id, trace_id, type_id, result, err_msg)
  if self:GetInterfaceVersion() == 2 then
    LLMHandler.send_ugc_llm_chat_op_result_req(chat_id, trace_id, type_id, result, err_msg)
  else
    print("Warning: Chat operation result feature only available in v2 interface")
  end
end
function NetworkProtocolFeature:SendUseLLMCardReq(inst_id)
  if self:GetInterfaceVersion() == 2 then
  else
    print("Warning: Use LLM card feature only available in v2 interface")
  end
end
function NetworkProtocolFeature:OnAIMessageNetworkRsp(err, event, data, cb_data)
  if self:GetInterfaceVersion() == 1 then
    self.Owner.OperationHandler:OnAIMessageNetworkRsp(err, event, data, cb_data)
  elseif self:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Data) then
    local v2type = data.content.type or Config_UGC_Copilot.Enum_Copilot_MessageType.Messages
    local v1type = Config_UGC_Copilot.MessageTypeV2ToEnum[v2type] or v2type
    data.content.type = v1type
    local config = Config_UGC_Copilot.GetCopilotMessageTypeConfig(v1type)
    if config and config.ContentKey and data.content[config.ContentKey] then
      data.content.content = data.content[config.ContentKey]
      data.content[config.ContentKey] = nil
    end
    Config_UGC_Copilot.HandleMessageTypeConversion(data.content)
    local data_v1 = {
      choices = {
        [1] = {
          delta = data.content
        }
      }
    }
    if data.custom_data then
      data_v1.choices[1].delta.custom_data = data.custom_data
    end
    self.Owner.OperationHandler:OnAIMessageNetworkRsp(err, event, data_v1, cb_data)
  elseif self:IsEventType(event, Config_UGC_Copilot.MessageRspEventTypeEnum.Error) then
    if data and data.ret_code then
      data.ret = data.ret_code
      data.ret_code = nil
    end
    self.Owner.OperationHandler:OnAIMessageNetworkRsp(err, event, data, cb_data)
  else
    self.Owner.OperationHandler:OnAIMessageNetworkRsp(err, event, data, cb_data)
  end
end
function NetworkProtocolFeature:OnHistorySessionsRsp(sessions, map_id)
  if self:GetInterfaceVersion() == 1 then
    self.Owner.OperationHandler:OnHistorySessionsRsp(sessions, map_id)
  else
    if sessions == nil then
      print("Warning: OnHistorySessionsRsp sessions is nil")
      self.Owner.OperationHandler:OnHistorySessionsRsp(nil, map_id)
      return
    end
    local v1_compatible_sessions = self:_ConvertV2ToV1Sessions(sessions)
    self.Owner.OperationHandler:OnHistorySessionsRsp(v1_compatible_sessions, map_id)
  end
end
function NetworkProtocolFeature:_ConvertV2ToV1Sessions(v2_sessions)
  local v1_sessions = {
    sessions = {},
    total_sessions = v2_sessions.total_sessions or 0
  }
  if v2_sessions.sessions and #v2_sessions.sessions > 0 then
    for _, session in ipairs(v2_sessions.sessions) do
      local v1_session = {
        chat_id = session.chat_id or "",
        start_at = session.start_time or 0,
        title = session.title or "",
        totals = session.total_messages or 0,
        latest_at = session.update_time or 0
      }
      table.insert(v1_sessions.sessions, v1_session)
    end
  end
  return v1_sessions.sessions
end
function NetworkProtocolFeature:OnChatMsgRsp(err, rsp_data, chat_id, map_id)
  if self:GetInterfaceVersion() == 1 then
    self.Owner.OperationHandler:OnChatMsgRsp(err, rsp_data)
  else
    if rsp_data == nil or rsp_data.data == nil then
      print("Warning: OnChatMsgRsp data is nil")
      local rspErr = err ~= 0 and err or Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NETWORK
      self.Owner.OperationHandler:OnChatMsgRsp(rspErr, rsp_data, chat_id, map_id)
      return
    end
    rsp_data.data.title = ""
    rsp_data.data.start_at = rsp_data.data.start_time
    rsp_data.data.start_time = nil
    if rsp_data.data and rsp_data.data.messages then
      print("[copilot_uigen_debug_history] OnChatMsgRsp: total messages=" .. #rsp_data.data.messages .. ", chat_id=" .. tostring(rsp_data.data.chat_id))
      for idx, message in pairs(rsp_data.data.messages) do
        print("[copilot_uigen_debug_history] OnChatMsgRsp msg[" .. idx .. "]: role=" .. tostring(message.role) .. ", type=" .. tostring(message.type) .. ", trace_id=" .. tostring(message.trace_id) .. ", content_len=" .. tostring(message.content and #tostring(message.content) or 0))
        if message.role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
          local fields = {}
          for k, v in pairs(message) do
            table.insert(fields, k .. "(" .. type(v) .. ")")
          end
          print("[copilot_uigen_debug_history] OnChatMsgRsp msg[" .. idx .. "] fields: " .. table.concat(fields, ", "))
        end
        if message.role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
          message.content_struct = {}
          local contentKeyToTypeMap = Config_UGC_Copilot.GetContentKeyToTypeMapping()
          if message.type == "chat" or message.type == "text" then
            contentKeyToTypeMap.content = Config_UGC_Copilot.Enum_Copilot_MessageType.Messages
            for fieldName, messageType in pairs(contentKeyToTypeMap) do
              if message[fieldName] then
                table.insert(message.content_struct, {
                  type = messageType,
                  content = message[fieldName]
                })
              end
            end
          else
            local config = Config_UGC_Copilot.GetCopilotMessageTypeConfig(message.type)
            if config and config.ContentKey and message[config.ContentKey] then
              table.insert(message.content_struct, {
                type = message.type,
                content = message[config.ContentKey]
              })
            end
          end
          print("[copilot_uigen_debug_history] OnChatMsgRsp msg[" .. idx .. "] content_struct built, count=" .. #message.content_struct)
        end
      end
    end
    self.Owner.OperationHandler:OnChatMsgRsp(err, rsp_data, chat_id, map_id)
  end
end
function NetworkProtocolFeature:IsEventType(EventVal, MessageRspEventTypeEnum)
  local eventMapping
  if self:GetInterfaceVersion() == 1 then
    eventMapping = Config_UGC_Copilot.MessageRspEvenToV1Chat
  else
    eventMapping = Config_UGC_Copilot.MessageRspEvenToV2Chat
  end
  local expectedEventVal = eventMapping[MessageRspEventTypeEnum]
  if expectedEventVal then
    return EventVal == expectedEventVal
  end
  return false
end
function NetworkProtocolFeature:SendUgcLlmReportReq(chat_id, trace_id, reason_type, reason_content)
  if self:GetInterfaceVersion() == 1 then
    UGCAIHandler.send_ugc_llm_report_req(chat_id, trace_id, reason_type, reason_content)
  else
    LLMHandler.send_ugc_llm_report_v2_req(chat_id, trace_id, reason_type, reason_content)
  end
end
function NetworkProtocolFeature:SendUGCLLMChatClearSessionsReq(map_id)
  print(bWriteLog and "NetworkProtocolFeature:SendUGCLLMChatClearSessionsReq")
  local map_id = map_id or "0"
  LLMHandler.send_ugc_llm_chat_clear_sessions_req(map_id)
end
local class = require("class")
local object = require("object")
return class(object, nil, NetworkProtocolFeature)