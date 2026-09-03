local NetworkProtocolFeature = {Owner = nil, InterfaceVersion = 2}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local UGCHandler = require("client.network.Protocol.UGCHandler")
local UGCAIHandler = require("client.network.Protocol.UGCAIHandler")
local LLMHandler = require("client.network.Protocol.LLMHandler")
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
  if self:GetInterfaceVersion() == 2 then
    local v2_chat_id = chat_id and tonumber(chat_id) or nil
    local v2_map_id = map_id or "0"
    local v2_ext_info = ext_info or {subscene = 0}
    LLMHandler.send_ugc_llm_chat_message_v2_req(chat_id, scene_id, v2_map_id, content, v2_ext_info)
  else
    UGCAIHandler.send_ugc_llm_chat_message_req(chat_id, content, scene_id)
  end
end
function NetworkProtocolFeature:SendGetSessionsReq(map_id)
  if self:GetInterfaceVersion() == 2 then
    local v2_map_id = map_id or "0"
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
    if rsp_data == nil then
      print("Warning: OnChatMsgRsp data is nil")
      return
    end
    rsp_data.data.title = ""
    rsp_data.data.start_at = rsp_data.data.start_time
    rsp_data.data.start_time = nil
    if rsp_data.data and rsp_data.data.messages then
      for idx, message in pairs(rsp_data.data.messages) do
        if message.role == Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant then
          message.content_struct = {}
          local contentKeyToTypeMap = Config_UGC_Copilot.GetContentKeyToTypeMapping()
          if message.type == "chat" then
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