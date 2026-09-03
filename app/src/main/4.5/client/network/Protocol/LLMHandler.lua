local NetManager = require("client.network.comm.NetManager")
local LLMHandler = {}
local GetMailHandler = function()
  return require("client.network.Protocol.MailHandler")
end
local GetCopilotLogic = function()
  local ModuleManager = require("client.module_framework.ModuleManager")
  return ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
end
function LLMHandler.send_ugc_get_llm_agent_data_v2_req()
  print(bWriteLog and "LLMHandler.send_ugc_get_llm_agent_data_v2_req")
  NetManager.SendPkg(1228218795)
end
function LLMHandler.on_ugc_get_llm_agent_data_v2_rsp(err_code, card_data)
  log_tree("LLMHandler.on_ugc_get_llm_agent_data_v2_rsp card_data:", card_data)
  local Logic_UGC_Copilot = GetCopilotLogic()
  if not Logic_UGC_Copilot then
    return
  end
  if err_code ~= 0 then
    Logic_UGC_Copilot:HandleNetworkError(err_code, "LLMHandler.on_ugc_get_llm_agent_data_v2_rsp")
    return
  end
  Logic_UGC_Copilot:OnLLMQuotaRsp(card_data)
end
function LLMHandler.send_ugc_llm_get_recommend_v2_req(scene_id)
  print(bWriteLog and "LLMHandler.send_ugc_llm_get_recommend_v2_req scene_id:" .. tostring(scene_id))
  NetManager.SendPkg(699113383, scene_id)
end
function LLMHandler.on_ugc_llm_get_recommend_v2_rsp(err_code, scene_id, rsp_data)
  log_tree("LLMHandler.on_ugc_llm_get_recommend_v2_rsp rsp_data:", rsp_data)
  local Logic_UGC_Copilot = GetCopilotLogic()
  if not Logic_UGC_Copilot then
    return
  end
  if err_code ~= 0 then
    Logic_UGC_Copilot:HandleNetworkError(err_code, "LLMHandler.on_ugc_llm_get_recommend_v2_rsp")
    return
  end
  local questions = {}
  if rsp_data and rsp_data.data and rsp_data.data.choices then
    questions = rsp_data.data.choices
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_RECOMMEND_QUESTIONS, questions)
end
function LLMHandler.send_ugc_llm_get_sessions_v2_req(map_id, mainscene)
  print(bWriteLog and "LLMHandler.send_ugc_llm_get_sessions_v2_req map_id:" .. tostring(map_id) .. " mainscene:" .. tostring(mainscene))
  NetManager.SendPkg(1882725247, map_id, mainscene or 0)
end
function LLMHandler.on_ugc_llm_get_sessions_v2_rsp(err_code, map_id, rsp_data)
  log_tree("LLMHandler.on_ugc_llm_get_sessions_v2_rsp rsp_data:", rsp_data)
  local Logic_UGC_Copilot = GetCopilotLogic()
  if not Logic_UGC_Copilot then
    return
  end
  if err_code ~= 0 then
    Logic_UGC_Copilot:HandleNetworkError(err_code, "LLMHandler.on_ugc_llm_get_sessions_v2_rsp")
    return
  end
  Logic_UGC_Copilot:OnHistorySessionsRsp(rsp_data.data or {}, map_id)
end
function LLMHandler.send_ugc_llm_one_chat_v2_req(map_id, chat_id, mainscene)
  print(bWriteLog and "LLMHandler.send_ugc_llm_one_chat_v2_req map_id:" .. tostring(map_id) .. " chat_id:" .. tostring(chat_id) .. " mainscene:" .. tostring(mainscene))
  NetManager.SendPkg(391563235, map_id, chat_id, mainscene or 0)
end
function LLMHandler.on_ugc_llm_one_chat_v2_rsp(err_code, map_id, chat_id, rsp_data)
  log_tree("LLMHandler.on_ugc_llm_one_chat_v2_rsp rsp_data:", rsp_data)
  local Logic_UGC_Copilot = GetCopilotLogic()
  if not Logic_UGC_Copilot then
    return
  end
  Logic_UGC_Copilot:OnChatMsgRsp(err_code, rsp_data, chat_id, map_id)
end
function LLMHandler.send_ugc_llm_report_v2_req(chat_id, trace_id, reason_type, reason_content, mainscene)
  print(bWriteLog and "LLMHandler.send_ugc_llm_report_v2_req chat_id:" .. tostring(chat_id) .. " trace_id:" .. tostring(trace_id) .. " reason_type:" .. tostring(reason_type) .. " reason_content:" .. tostring(reason_content) .. " mainscene:" .. tostring(mainscene))
  NetManager.SendPkg(970055367, chat_id, trace_id, reason_type, reason_content, mainscene or 0)
end
function LLMHandler.on_ugc_llm_report_v2_rsp(err_code, rsp_data)
  print(bWriteLog and "LLMHandler.on_ugc_llm_report_v2_rsp err_code:" .. tostring(err_code))
  log_tree("LLMHandler.on_ugc_llm_report_v2_rsp rsp_data:", rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  else
  end
end
function LLMHandler.send_ugc_llm_chat_rating_v2_req(chat_id, trace_id, action, mainscene)
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_rating_v2_req chat_id:" .. tostring(chat_id) .. " trace_id:" .. tostring(trace_id) .. " action:" .. tostring(action) .. " mainscene:" .. tostring(mainscene))
  NetManager.SendPkg(1727247847, chat_id, trace_id, action, mainscene or 0)
end
function LLMHandler.on_ugc_llm_chat_rating_v2_rsp(err_code, rsp_data, chat_id, trace_id, action)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_rating_v2_rsp err_code:" .. tostring(err_code) .. " chat_id:" .. tostring(chat_id) .. " trace_id:" .. tostring(trace_id))
  log_tree("LLMHandler.on_ugc_llm_chat_rating_v2_rsp rsp_data:", rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(17005222))
  end
  local Logic_UGC_Copilot = GetCopilotLogic()
  if Logic_UGC_Copilot and err_code == 0 then
    Logic_UGC_Copilot:SetActiveChatReportData(chat_id, trace_id, action)
  end
end
function LLMHandler.send_ugc_llm_chat_message_v2_req(chat_id, scene_id, map_id, content, ext_info)
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_message_v2_req chat_id:" .. tostring(chat_id) .. " scene_id:" .. tostring(scene_id) .. " map_id:" .. tostring(map_id) .. " content:" .. tostring(content))
  log_tree("LLMHandler.send_ugc_llm_chat_message_v2_req ext_info:", ext_info)
  NetManager.SendPkg(1203510071, chat_id, scene_id, map_id, content, ext_info)
end
function LLMHandler.on_ugc_llm_chat_message_v2_rsp(err_code, event, data, cb_data, card_data)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_message_v2_rsp err_code:" .. tostring(err_code) .. " event:" .. tostring(event))
  log_tree("LLMHandler.on_ugc_llm_chat_message_v2_rsp data:", data)
  log_tree("LLMHandler.on_ugc_llm_chat_message_v2_rsp cb_data:", cb_data)
  log_tree("LLMHandler.on_ugc_llm_chat_message_v2_rsp card_data:", card_data)
  local Logic_UGC_Copilot = GetCopilotLogic()
  if not Logic_UGC_Copilot then
    return
  end
  Logic_UGC_Copilot:OnAIMessageNetworkRsp(err_code, tostring(event), data, cb_data)
  if card_data then
    Logic_UGC_Copilot:OnLLMQuotaRsp(card_data)
  end
end
function LLMHandler.send_ugc_llm_chat_stop_v2_req(map_id, stop_reason)
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_stop_v2_req map_id:" .. tostring(map_id) .. " stop_reason:" .. tostring(stop_reason))
  NetManager.SendPkg(943877799, map_id, stop_reason or 1)
end
function LLMHandler.on_ugc_llm_chat_stop_v2_rsp(err_code, map_id, chat_id, trace_id)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_stop_v2_rsp err_code:" .. tostring(err_code) .. " chat_id:" .. tostring(chat_id) .. " map_id:" .. tostring(map_id) .. " ret:" .. tostring(ret))
  local Logic_UGC_Copilot = GetCopilotLogic()
  Logic_UGC_Copilot:OnchatStopRsp(trace_id)
end
function LLMHandler.send_ugc_llm_chat_resouce_finish_ntf()
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_resouce_finish_ntf")
  log_tree("LLMHandler.send_ugc_llm_chat_resouce_finish_ntf ntf_data:", ntf_data)
  NetManager.SendPkg(438762404, ntf_data)
end
function LLMHandler.on_ugc_llm_chat_resouce_finish_ntf_rsp(err_code)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_resouce_finish_ntf_rsp err_code:" .. tostring(err_code))
end
function LLMHandler.send_ugc_llm_chat_op_result_req(chat_id, trace_id, type_id, result, err_msg)
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_op_result_req chat_id:" .. tostring(chat_id) .. " trace_id:" .. tostring(trace_id) .. " type_id:" .. tostring(type_id) .. " result:" .. tostring(result) .. " err_msg:" .. tostring(err_msg))
  NetManager.SendPkg(1122577031, chat_id, trace_id, type_id, result, err_msg)
end
function LLMHandler.on_ugc_llm_chat_op_result_rsp(err_code, rsp_data)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_op_result_rsp err_code:" .. tostring(err_code))
  log_tree("LLMHandler.on_ugc_llm_chat_op_result_rsp rsp_data:", rsp_data)
end
function LLMHandler.send_ugc_use_llm_card_v2_req(inst_id)
  print(bWriteLog and "LLMHandler.send_ugc_use_llm_card_v2_req inst_id:" .. tostring(inst_id))
  NetManager.SendPkg(1934726431, inst_id)
end
function LLMHandler.on_ugc_use_llm_card_v2_rsp(err_code, inst_id, card_data)
  print(bWriteLog and "LLMHandler.on_ugc_use_llm_card_v2_rsp err_code:" .. tostring(err_code) .. " inst_id:" .. tostring(inst_id))
  log_tree("LLMHandler.on_ugc_use_llm_card_v2_rsp card_data:", card_data)
end
local example_ntf_data = {
  user_id = "user_123456",
  trace_id = "trace_789012",
  map_id = "map_001",
  chat_id = "chat_456789",
  msg_time = "2024-01-15 14:30:25",
  type = "modgen",
  result = 0,
  error_msg = "",
  content = {
    {
      id = "res_001",
      path = "models/character_model.fbx",
      bucket = "ugc-resources",
      region = "ap-southeast-1",
      icon = {
        "icons/char_icon.png"
      },
      name = "\228\184\187\232\167\146\230\168\161\229\158\139"
    },
    {
      id = "res_002",
      path = "models/weapon_model.fbx",
      bucket = "ugc-resources",
      region = "ap-southeast-1",
      icon = {
        "icons/weapon_icon.png"
      },
      name = "\230\173\166\229\153\168\230\168\161\229\158\139"
    }
  }
}
local example_ntf_data = {
  user_id = "user_123456",
  trace_id = "trace_789012",
  map_id = "map_001",
  chat_id = "chat_456789",
  msg_time = "2024-01-15 14:30:25",
  type = "modcap",
  result = 0,
  error_msg = "",
  content = {
    {
      id = "res_001",
      path = "animations/welcome_anim.mp4",
      bucket = "ugc-resources",
      region = "ap-southeast-1",
      length = 45.2
    }
  }
}
function LLMHandler.on_ugc_llm_agent_res_finish_ntf(ntf_data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_Ugc_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  Logic_Ugc_Copilot:HandleResourceFinishNtf(ntf_data)
end
function LLMHandler.send_ugc_llm_client_result_req(map_id, chat_id, trace_id, result_detail)
  NetManager.SendPkg(1055887615, map_id, chat_id, trace_id, result_detail)
end
function LLMHandler.on_ugc_llm_client_result_rsp(err_code)
  print(bWriteLog and "LLMHandler.on_ugc_llm_client_result_rsp")
end
function LLMHandler.send_ugc_llm_chat_clear_sessions_req(map_id, mainscene)
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_clear_sessions_req map_id:" .. tostring(map_id) .. " mainscene:" .. tostring(mainscene))
  NetManager.SendPkg(59987411, map_id, mainscene or 0)
end
function LLMHandler.on_ugc_llm_chat_clear_sessions_rsp(err_code, map_id)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_clear_sessions_rsp")
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_clear_sessions_rsp err_code:" .. tostring(err_code) .. " map_id:" .. tostring(map_id))
  if err_code ~= 0 then
    local Text = LocUtil.GetLocalizeResStr(511070) .. "(" .. tostring(err_code) .. ")"
    ShowNotice(Text)
  end
end
function LLMHandler.send_ugc_llm_client_code_result_req(map_id, chat_id, trace_id, result_detail)
  print(bWriteLog and "LLMHandler.send_ugc_llm_client_code_result_req", map_id, chat_id, trace_id, result_detail)
  NetManager.SendPkg(447748967, map_id, chat_id, trace_id, result_detail)
end
function LLMHandler.on_ugc_llm_client_code_result_rsp(err_code)
  print(bWriteLog and "LLMHandler.on_ugc_llm_client_code_result_rsp")
  if err_code ~= 0 then
    local Text = LocUtil.GetLocalizeResStr(511070) .. "(" .. tostring(err_code) .. ")"
    ShowNotice(Text)
  end
end
function LLMHandler.send_ugc_llm_client_interact_result_req(map_id, chat_id, trace_id, result_detail)
  print(bWriteLog and "LLMHandler.send_ugc_llm_client_interact_result_req")
  NetManager.SendPkg(1321099783, map_id, chat_id, trace_id, result_detail)
end
function LLMHandler.on_ugc_llm_client_interact_result_rsp(err_code)
  print(bWriteLog and "LLMHandler.on_ugc_llm_client_interact_result_rsp")
  if err_code ~= 0 then
    local Text = LocUtil.GetLocalizeResStr(511070) .. "(" .. tostring(err_code) .. ")"
    ShowNotice(Text)
  end
end
function LLMHandler.send_ugc_llm_chat_switch_v2_req()
  print(bWriteLog and "LLMHandler.send_ugc_llm_chat_switch_v2_req")
  NetManager.SendPkg(1429595143)
end
function LLMHandler.on_ugc_llm_chat_switch_v2_rsp(flag, extra_switchs)
  print(bWriteLog and "LLMHandler.on_ugc_llm_chat_switch_v2_rsp")
  local Logic_UGC_Copilot = GetCopilotLogic()
  if not Logic_UGC_Copilot then
    return
  end
  Logic_UGC_Copilot:RefreshOpenLLMChatV2(flag)
  if not flag then
    print("V2 assistant not available")
    if extra_switchs == nil then
      print("Extra switch status is nil")
    end
  else
    print("V2 assistant is available")
    if extra_switchs then
      if extra_switchs.edit_switch ~= nil then
        print("Scene edit switch: " .. tostring(extra_switchs.edit_switch))
        Logic_UGC_Copilot:RefreshOpenLLMSceneEdit(extra_switchs.edit_switch)
      end
      if extra_switchs.blockylua_edit_switch ~= nil then
        print("BlockyLua edit switch: " .. tostring(extra_switchs.blockylua_edit_switch))
        Logic_UGC_Copilot:RefreshOpenBlockyluaEdit(extra_switchs.blockylua_edit_switch)
        EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_BLOCKYLUA_VISIBILITY_CHANGE, extra_switchs.blockylua_edit_switch)
      end
      if extra_switchs.pilot_switch ~= nil then
        print("Pilot switch: " .. tostring(extra_switchs.pilot_switch))
        Logic_UGC_Copilot:RefreshOpenUIGen(extra_switchs.pilot_switch)
      end
    end
  end
end
function LLMHandler.on_ugc_llm_edit_auto_eva_ntf(ntf_data)
  if type(ntf_data) ~= "table" then
    return
  end
  if Client and not Client.IsDevelopment() then
    log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - not in development mode, skip processing")
    return
  end
  local op = ntf_data.op
  if not op then
    log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - op is nil, skip processing")
    return
  end
  if op == "enter_game" then
    if not ntf_data.slot then
      log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - enter_game failed, slot is nil")
      return
    end
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    UGCModHandler.send_update_client_mod_info({
      [ntf_data.mod_id] = 3
    })
    UGCModHandler.send_start_ugc_edit_game_req(ntf_data.slot, ntf_data.try_play, ntf_data.tutorial_id)
    log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - enter_game, slot:" .. tostring(ntf_data.slot))
  elseif op == "execute_code" then
    log(bWriteLog and string.format("LLMHandler.on_ugc_llm_edit_auto_eva_ntf - execute_code, trace_id:%s, code:%s", tostring(ntf_data.trace_id), tostring(ntf_data.code)))
    if not ntf_data.code or ntf_data.code == "" then
      log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - execute_code failed, code is nil or empty")
      return
    end
    local uPlayerCtrl = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    local CallbackEventHandle, TimeoutTimerHandle
    local CALLBACK_TIMEOUT = 30
    local CleanupListener = function()
      if CallbackEventHandle then
        EventSystem:unregistEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CODE_EXECALLBACK, CallbackEventHandle)
        CallbackEventHandle = nil
      end
      if TimeoutTimerHandle then
        local time_ticker = require("common.time_ticker")
        time_ticker.RemoveTimer(TimeoutTimerHandle)
        TimeoutTimerHandle = nil
      end
    end
    local OnCodeExecCallback = function(_, _, result, args)
      CleanupListener()
      log(bWriteLog and "[jackey] MailHandler.on_echo - execute_code callback, result:" .. tostring(result))
      log_tree(bWriteLog and "[jackey] MailHandler.on_echo - execute_code callback, args:", args)
      local result_code = result == 0 and 0 or -1
      local ResultData = {
        result = result_code,
        content = {},
        contentx = nil,
        err_msg = ""
      }
      if result_code == 0 then
        if type(args) == "table" then
          ResultData.content = args.content
          ResultData.contentx = args.contentx
        end
      else
        if type(args) == "table" and args[1] then
          ResultData.err_msg = tostring(args[1])
        elseif type(args) == "string" then
          ResultData.err_msg = args
        else
          ResultData.err_msg = "unknown error: " .. tostring(args)
        end
        log(bWriteLog and string.format("MailHandler.on_echo - execute_code callback error, result:%s, err_msg:%s", tostring(result_code), tostring(ResultData.err_msg)))
      end
      if ntf_data.callback then
        local base64 = require("client.slua.logic.lobby_watermark.base64")
        local EncodeResult = slua.LuaArchiverEncode(LuaStateWrapper, ResultData)
        local base64EncodeResult = base64.EncodeBase64(EncodeResult)
        local send_msg = string.format("%s(\"%s\", \"%s\", \"%s\")", ntf_data.callback, ntf_data.trace_id, ntf_data.request_id, tostring(base64EncodeResult))
        GetMailHandler().send_exec(send_msg)
      end
    end
    CallbackEventHandle = OnCodeExecCallback
    EventSystem:registEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CODE_EXECALLBACK, CallbackEventHandle)
    local time_ticker = require("common.time_ticker")
    TimeoutTimerHandle = time_ticker.AddTimerOnce(CALLBACK_TIMEOUT, function()
      if CallbackEventHandle then
        log(bWriteLog and string.format("LLMHandler.on_ugc_llm_edit_auto_eva_ntf - execute_code timeout, trace_id:%s", tostring(ntf_data.trace_id)))
        CleanupListener()
      end
    end)
    if uPlayerCtrl and slua.isValid(uPlayerCtrl) then
      local MCPFeature = uPlayerCtrl.CreativeModeMCPFeature
      local RuntimeCodeFeature = uPlayerCtrl.CreativemodeRuntimeCodeFeature
      local bCodeExecuted = false
      local executeErr
      if MCPFeature then
        local bSuccess, err = pcall(function()
          MCPFeature:UpdateCanEditObj()
          MCPFeature:UpdateMapCost()
          MCPFeature:ServerRPC_ExecuteCode(ntf_data.code)
        end)
        if bSuccess then
          bCodeExecuted = true
        else
          executeErr = err
        end
      end
      if not bCodeExecuted and RuntimeCodeFeature then
        local bSuccess, err = pcall(function()
          RuntimeCodeFeature:ServerRPC_ExeCode(ntf_data.code)
        end)
        if bSuccess then
          bCodeExecuted = true
        else
          executeErr = err
        end
      end
      if not bCodeExecuted then
        log(bWriteLog and string.format("MailHandler.on_echo - execute_code failed, error:%s", tostring(executeErr)))
        CleanupListener()
        return
      end
    else
      CleanupListener()
      log(bWriteLog and "MailHandler.on_echo - execute_code failed, PlayerController is invalid")
    end
  elseif op == "capture" then
    log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - capture, trace_id:" .. tostring(ntf_data.trace_id) .. ", request_id:" .. tostring(ntf_data.request_id))
    local capture_type = ntf_data.capture_type
    local ScreenshotMaker = import("ScreenshotMaker")
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_START_CAMERA_SCREENSHOT)
    local time_ticker = require("common.time_ticker")
    local bAllCaptureCompleted = false
    local ActiveTimerHandles = {}
    local CAPTURE_TIMEOUT = capture_type == "after" and 60 or 30
    local TrackTimer = function(handle)
      if handle then
        table.insert(ActiveTimerHandles, handle)
      end
      return handle
    end
    local CleanupAllTimers = function()
      for i = 1, #ActiveTimerHandles do
        if ActiveTimerHandles[i] then
          time_ticker.RemoveTimer(ActiveTimerHandles[i])
          ActiveTimerHandles[i] = nil
        end
      end
    end
    local uPlayerCtrl = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    local PlayerCameraManager = uPlayerCtrl and slua.isValid(uPlayerCtrl) and uPlayerCtrl.PlayerCameraManager or nil
    local OrigRotation = PlayerCameraManager and slua.isValid(PlayerCameraManager) and PlayerCameraManager:GetCameraRotation() or nil
    local OrigFOV
    if PlayerCameraManager and slua.isValid(PlayerCameraManager) then
      local bOk, fov = pcall(function()
        return PlayerCameraManager:GetFOVAngle()
      end)
      if bOk and fov then
        OrigFOV = fov
      end
    end
    log(bWriteLog and string.format("LLMHandler - capture camera state: OrigFOV:%s, OrigRotation:%s", tostring(OrigFOV), tostring(OrigRotation)))
    local CapturePresets
    if capture_type == "after" then
      CapturePresets = {
        {
          name = "normal",
          yaw_offset = 0,
          fov_factor = nil
        },
        {
          name = "left45",
          yaw_offset = -45,
          fov_factor = nil
        },
        {
          name = "right45",
          yaw_offset = 45,
          fov_factor = nil
        },
        {
          name = "zoomin",
          yaw_offset = 0,
          fov_factor = 0.65
        },
        {
          name = "zoomout",
          yaw_offset = 0,
          fov_factor = 1.4
        }
      }
    else
      CapturePresets = {
        {
          name = "normal",
          yaw_offset = 0,
          fov_factor = nil
        }
      }
    end
    local EffectiveCaptureType = capture_type or "before"
    local CapturedCount = 0
    local FastBase64Encode = function(data)
      local b64str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
      local b64 = {}
      for i = 0, 63 do
        b64[i] = string.byte(b64str, i + 1)
      end
      local eq = string.byte("=")
      local parts = {}
      local n_parts = 0
      local len = #data
      local i = 1
      while i <= len - 2 do
        local b1, b2, b3 = string.byte(data, i, i + 2)
        local n = b1 * 65536 + b2 * 256 + b3
        n_parts = n_parts + 1
        parts[n_parts] = string.char(b64[math.floor(n / 262144)], b64[math.floor(n / 4096) % 64], b64[math.floor(n / 64) % 64], b64[n % 64])
        i = i + 3
      end
      local remaining = len - i + 1
      if remaining == 2 then
        local b1, b2 = string.byte(data, i, i + 1)
        local n = b1 * 65536 + b2 * 256
        n_parts = n_parts + 1
        parts[n_parts] = string.char(b64[math.floor(n / 262144)], b64[math.floor(n / 4096) % 64], b64[math.floor(n / 64) % 64], eq)
      elseif remaining == 1 then
        local b1 = string.byte(data, i)
        local n = b1 * 65536
        n_parts = n_parts + 1
        parts[n_parts] = string.char(b64[math.floor(n / 262144)], b64[math.floor(n / 4096) % 64], eq, eq)
      end
      return table.concat(parts)
    end
    local ReadAndEncodeScreenshot = function(ShotPath)
      if not ShotPath then
        log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot ShotPath is nil")
        return nil
      end
      log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot ShotPath:" .. tostring(ShotPath))
      ScreenshotMaker.ResizePicture(ShotPath, ntf_data.size or 0.5, ShotPath)
      local File = io.open(ShotPath, "rb")
      if not File then
        log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot io.open failed with original path, try abs path")
        local bOk, BusinessHelper = pcall(import, "BusinessHelper")
        if bOk and BusinessHelper then
          local AbsPath = BusinessHelper.GetMobileBasePath(ShotPath)
          log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot AbsPath:" .. tostring(AbsPath))
          File = io.open(AbsPath, "rb")
          if not File then
            log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot io.open failed with abs path")
            return nil
          end
        else
          log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot BusinessHelper not available")
          return nil
        end
      end
      local Buffer = File:read("*a")
      File:close()
      if Buffer and 0 < #Buffer then
        local RawSize = #Buffer
        local encoded = FastBase64Encode(Buffer)
        Buffer = nil
        log(bWriteLog and string.format("LLMHandler - ReadAndEncodeScreenshot raw_size:%d, base64_size:%d, ratio:%.2f", RawSize, #encoded, #encoded / RawSize))
        return encoded
      end
      log(bWriteLog and "LLMHandler - ReadAndEncodeScreenshot file read empty, Buffer:" .. tostring(Buffer and #Buffer or "nil"))
      return nil
    end
    local RestoreCamera = function()
      if OrigRotation and uPlayerCtrl and slua.isValid(uPlayerCtrl) then
        uPlayerCtrl:ClientSetRotation(OrigRotation, true)
      end
      if OrigFOV and uPlayerCtrl and slua.isValid(uPlayerCtrl) then
        uPlayerCtrl:FOV(OrigFOV)
      end
    end
    local OnAllCapturesDone = function()
      if bAllCaptureCompleted then
        return
      end
      bAllCaptureCompleted = true
      CleanupAllTimers()
      RestoreCamera()
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_END_CAMERA_SCREENSHOT)
      log(bWriteLog and string.format("LLMHandler - all captures finished, count:%d, trace_id:%s", CapturedCount, tostring(ntf_data.trace_id)))
    end
    local TakeOnePicture = function(imgPath, onDone)
      local UIUtil = require("client.common.ui_util")
      local GameInstance = UIUtil.GetGameInstance()
      if not GameInstance then
        onDone(nil)
        return
      end
      GameInstance.EnginePreTick:Add(function()
        ScreenshotMaker.SetDefaultShowUI(false)
        local ShotPath = ScreenshotMaker.MakePictureByName(imgPath, false)
        GameInstance.EnginePreTick:Clear()
        if ShotPath then
          TrackTimer(time_ticker.AddTimer(0.01, function()
            repeat
              coroutine.yield(0.01)
            until ScreenshotMaker.HasCaptured(ShotPath) or bAllCaptureCompleted
            if not bAllCaptureCompleted then
              coroutine.yield(0.25)
              onDone(ShotPath)
            end
          end))
        else
          onDone(nil)
        end
      end)
    end
    local function ProcessPreset(index)
      if index > #CapturePresets or bAllCaptureCompleted then
        OnAllCapturesDone()
        return
      end
      local preset = CapturePresets[index]
      if preset.yaw_offset ~= 0 and OrigRotation and uPlayerCtrl and slua.isValid(uPlayerCtrl) then
        local NewRotation = FRotator(OrigRotation.Pitch, OrigRotation.Yaw + preset.yaw_offset, OrigRotation.Roll)
        uPlayerCtrl:ClientSetRotation(NewRotation, true)
      end
      if preset.fov_factor and OrigFOV and uPlayerCtrl and slua.isValid(uPlayerCtrl) then
        local NewFOV = math.max(10, math.min(170, OrigFOV * preset.fov_factor))
        uPlayerCtrl:FOV(NewFOV)
        log(bWriteLog and string.format("LLMHandler - FOV adjusted: %s -> %s for %s", tostring(OrigFOV), tostring(NewFOV), preset.name))
      end
      TrackTimer(time_ticker.AddTimerOnce(0.3, function()
        if bAllCaptureCompleted then
          return
        end
        if index == 1 then
          Client.DeleteDirectory(Client.ProjectSavedDir() .. "Screenshots/")
        end
        local imgPath = string.format("%sScreenshots/%s_%s_%s.jpg", Client.ProjectSavedDir(), EffectiveCaptureType, preset.name, tostring(ntf_data.trace_id))
        TakeOnePicture(imgPath, function(ShotPath)
          if bAllCaptureCompleted then
            return
          end
          local ImgBase64 = ReadAndEncodeScreenshot(ShotPath)
          if ImgBase64 and ntf_data.callback then
            CapturedCount = CapturedCount + 1
            local ImageName = string.format("%s_%s_%s", EffectiveCaptureType, preset.name, tostring(ntf_data.trace_id))
            local ImagePayload = string.format("%s|%s|%s|%d|%d|%s", EffectiveCaptureType, preset.name, ImageName, index, #CapturePresets, ImgBase64)
            local send_msg = string.format("%s(\"%s\", \"%s\", \"%s\")", ntf_data.callback, ntf_data.trace_id, ntf_data.request_id, ImagePayload)
            GetMailHandler().send_exec(send_msg)
          end
          log(bWriteLog and string.format("LLMHandler - captured [%d/%d] %s_%s, base64_size:%d", index, #CapturePresets, EffectiveCaptureType, preset.name, ImgBase64 and #ImgBase64 or 0))
          RestoreCamera()
          TrackTimer(time_ticker.AddTimerOnce(0.15, function()
            ProcessPreset(index + 1)
          end))
        end)
      end))
    end
    TrackTimer(time_ticker.AddTimerOnce(CAPTURE_TIMEOUT, function()
      if not bAllCaptureCompleted then
        log(bWriteLog and "LLMHandler - capture timeout, trace_id:" .. tostring(ntf_data.trace_id))
        OnAllCapturesDone()
      end
    end))
    TrackTimer(time_ticker.AddTimerOnce(0.1, function()
      ProcessPreset(1)
    end))
  elseif op == "check_asset" then
    log(bWriteLog and string.format("LLMHandler.on_ugc_llm_edit_auto_eva_ntf - check_asset, trace_id:%s, request_id:%s", tostring(ntf_data.trace_id), tostring(ntf_data.request_id)))
    local selected = ntf_data.selected
    local trace_id = ntf_data.trace_id
    local request_id = ntf_data.request_id
    local callback_name = ntf_data.callback
    if not selected or type(selected) ~= "table" or #selected == 0 then
      log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - check_asset failed, selected is empty")
      return
    end
    log_tree("LLMHandler - check_asset selected:", selected)
    local ModuleManager = require("client.module_framework.ModuleManager")
    local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
    local PlacePrefabFeat = Logic_UGC_Copilot and Logic_UGC_Copilot.PlacePrefabFeature
    local time_ticker = require("common.time_ticker")
    local OVERALL_TIMEOUT = 30
    local TotalCount = #selected
    local CompletedCount = 0
    local bAllCompleted = false
    local TimeoutHandle
    local ItemCompleted = {}
    local Results = {}
    for i = 1, TotalCount do
      Results[i] = {
        category = selected[i].category or "",
        id = selected[i].id or 0,
        type = selected[i].type or 0,
        real_asset_id = 0,
        result_code = 5,
        error_msg = "Timeout"
      }
    end
    local OnAllItemsCompleted = function()
      if bAllCompleted then
        return
      end
      bAllCompleted = true
      if TimeoutHandle then
        time_ticker.RemoveTimer(TimeoutHandle)
        TimeoutHandle = nil
      end
      log(bWriteLog and string.format("LLMHandler - check_asset all completed, trace_id:%s, completed:%d/%d", tostring(trace_id), CompletedCount, TotalCount))
      if callback_name then
        log(bWriteLog and "LLMHandler - check_asset send_exec callback:" .. tostring(callback_name))
        log_tree("LLMHandler - check_asset final results:", Results)
        local base64 = require("client.slua.logic.lobby_watermark.base64")
        local EncodeResult = slua.LuaArchiverEncode(LuaStateWrapper, Results)
        local base64EncodeResult = base64.EncodeBase64(EncodeResult)
        local send_msg = string.format("%s(\"%s\", \"%s\", \"%s\")", callback_name, tostring(trace_id), tostring(request_id), tostring(base64EncodeResult))
        GetMailHandler().send_exec(send_msg)
      end
    end
    local OnItemComplete = function(index, real_asset_id, result_code, error_msg)
      if bAllCompleted or ItemCompleted[index] then
        return
      end
      ItemCompleted[index] = true
      Results[index].real_asset_id = real_asset_id or 0
      Results[index].result_code = result_code or 0
      Results[index].error_msg = error_msg or ""
      CompletedCount = CompletedCount + 1
      log(bWriteLog and string.format("LLMHandler - check_asset item [%d/%d] done, category:%s, result_code:%s, real_asset_id:%s", CompletedCount, TotalCount, tostring(Results[index].category), tostring(result_code), tostring(real_asset_id)))
      if CompletedCount >= TotalCount then
        OnAllItemsCompleted()
      end
    end
    local DoPutDownAndComplete = function(index, RealAssetID)
      log(bWriteLog and string.format("LLMHandler - check_asset DoPutDown, index:%d, RealAssetID:%s, category:%s", index, tostring(RealAssetID), tostring(Results[index].category)))
      local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
      logic_ugc_prefab_mall_asset_mgr:PutDown(RealAssetID, function()
        OnItemComplete(index, RealAssetID, 0, "")
      end, {SilentPutDown = true})
    end
    for i, item in ipairs(selected) do
      local itemType = item.type
      local itemId = item.id
      log(bWriteLog and string.format("LLMHandler - check_asset processing [%d/%d], category:%s, id:%s, type:%s", i, TotalCount, tostring(item.category), tostring(itemId), tostring(itemType)))
      if itemType == 1 then
        log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=1 backpack, skip directly", i))
        OnItemComplete(i, itemId, 0, "")
      elseif itemType == 2 then
        if not PlacePrefabFeat then
          OnItemComplete(i, 0, 4, "PlacePrefabFeature not available")
        else
          local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
          local MetaInfo = logic_ugc_prefab_mall and logic_ugc_prefab_mall:GetPrefabMeta(itemId)
          if MetaInfo then
            log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=2 meta cached, AssetId:%s", i, tostring(MetaInfo.Meta.AssetId)))
            DoPutDownAndComplete(i, MetaInfo.Meta.AssetId)
          else
            log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=2 meta not cached, fetching prefab_id:%s", i, tostring(itemId)))
            PlacePrefabFeat:FetchPublicPrefabMeta(itemId, function(Success, FetchedMeta)
              if Success and FetchedMeta then
                log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=2 meta fetched ok, AssetId:%s", i, tostring(FetchedMeta.Meta.AssetId)))
                DoPutDownAndComplete(i, FetchedMeta.Meta.AssetId)
              else
                log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=2 meta fetch failed, prefab_id:%s", i, tostring(itemId)))
                OnItemComplete(i, 0, 4, "Meta fetch failed for prefab_id: " .. tostring(itemId))
              end
            end)
          end
        end
      elseif itemType == 3 then
        if not PlacePrefabFeat then
          OnItemComplete(i, 0, 4, "PlacePrefabFeature not available")
        else
          local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
          if logic_ugc_prefab_mall_private:IsPrivateMetaCompleted() then
            local MetaInfo = logic_ugc_prefab_mall_private:GetPrivateMeta(itemId)
            if MetaInfo then
              log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=3 private meta found, AssetId:%s", i, tostring(MetaInfo.Meta.AssetId)))
              DoPutDownAndComplete(i, MetaInfo.Meta.AssetId)
            else
              log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=3 private meta not found, slot:%s", i, tostring(itemId)))
              OnItemComplete(i, 0, 3, "Private meta not found for slot: " .. tostring(itemId))
            end
          else
            log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=3 private meta list not loaded, fetching slot:%s", i, tostring(itemId)))
            PlacePrefabFeat:FetchPrivatePrefabMetaManaged(itemId, nil, function(Success, FetchedMeta)
              if Success and FetchedMeta then
                log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=3 private meta fetched ok, AssetId:%s", i, tostring(FetchedMeta.Meta.AssetId)))
                DoPutDownAndComplete(i, FetchedMeta.Meta.AssetId)
              else
                log(bWriteLog and string.format("LLMHandler - check_asset [%d] type=3 private meta fetch failed, slot:%s", i, tostring(itemId)))
                OnItemComplete(i, 0, 4, "Private meta fetch failed for slot: " .. tostring(itemId))
              end
            end)
          end
        end
      else
        log(bWriteLog and string.format("LLMHandler - check_asset [%d] invalid type:%s", i, tostring(itemType)))
        OnItemComplete(i, 0, 1, "Invalid type: " .. tostring(itemType))
      end
    end
    TimeoutHandle = time_ticker.AddTimerOnce(OVERALL_TIMEOUT, function()
      if not bAllCompleted then
        log(bWriteLog and string.format("LLMHandler - check_asset timeout, trace_id:%s, completed:%d/%d", tostring(trace_id), CompletedCount, TotalCount))
        OnAllItemsCompleted()
      end
    end)
  elseif op == "end_game" then
    local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
    ClientEntryHandler.send_giveup_enter_game(true)
    LobbySystem.ReturnToLobby()
    log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - end_game")
  else
    log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - unknown op:" .. tostring(op))
  end
  log(bWriteLog and "LLMHandler.on_ugc_llm_edit_auto_eva_ntf - op:" .. tostring(op))
end
function LLMHandler.send_ugc_llm_ui_apply_result_req(trace_id, result, reason, err_msg)
  reason = reason or result == 1 and "success" or ""
  err_msg = err_msg or ""
  print(bWriteLog and "LLMHandler.send_ugc_llm_ui_apply_result_req trace_id:" .. tostring(trace_id) .. " result:" .. tostring(result) .. " reason:" .. tostring(reason) .. " err_msg:" .. tostring(err_msg))
  NetManager.SendPkg(305901367, trace_id or "", result or 0, reason, err_msg)
end
function LLMHandler.on_ugc_llm_ui_apply_result_rsp(err_code)
  print(bWriteLog and "LLMHandler.on_ugc_llm_ui_apply_result_rsp err_code:" .. tostring(err_code))
end
return LLMHandler