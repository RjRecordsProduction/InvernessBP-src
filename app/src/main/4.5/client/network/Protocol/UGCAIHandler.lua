local NetManager = require("client.network.comm.NetManager")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local UGCAIHandler = {}
function UGCAIHandler.send_ugc_pass_gencover_add_task_req(associate_id, origin_pic_url, style_id, title)
  log(bWriteLog and "UGCAIHandler.send_ugc_pass_gencover_add_task_req mod_id = " .. tostring(associate_id) .. " origin_pic_url = " .. tostring(origin_pic_url) .. " style_id = " .. tostring(style_id) .. " title = " .. tostring(title))
  NetManager.SendPkg(1380469095, associate_id, origin_pic_url, style_id, title)
end
function UGCAIHandler.on_ugc_pass_gencover_add_task_rsp(err_code, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCAIHandler.on_ugc_pass_gencover_add_task_rsp task_data = ", task_data)
  local logic_ugc_ai_cover_image = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_ai_cover_image)
  logic_ugc_ai_cover_image:AddGenCoverTaskRsp(task_data)
end
function UGCAIHandler.send_ugc_pass_gencover_get_task_req(associate_id, task_id)
  log(bWriteLog and "UGCAIHandler.send_ugc_pass_gencover_get_task_req associate_id = " .. tostring(associate_id) .. "task_id = " .. tostring(task_id) .. "")
  NetManager.SendPkg(741294663, associate_id, task_id)
end
function UGCAIHandler.on_ugc_pass_gencover_get_task_rsp(err_code, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCAIHandler.on_ugc_pass_gencover_get_task_rsp task_data = ", task_data)
  local logic_ugc_ai_cover_image = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_ai_cover_image)
  logic_ugc_ai_cover_image:GetGenCoverTaskDataRsp(task_data)
end
function UGCAIHandler.send_ugc_pass_gencover_get_user_info_req()
  log(bWriteLog and "UGCAIHandler.send_ugc_pass_gencover_get_user_info_req")
  NetManager.SendPkg(1667813647)
end
function UGCAIHandler.on_ugc_pass_gencover_get_user_info_rsp(errcode, user_info)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  log_tree(bWriteLog and "UGCAIHandler.on_ugc_pass_gencover_get_user_info_rsp user_info = ", user_info)
  local logic_ugc_ai_cover_image = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_ai_cover_image)
  logic_ugc_ai_cover_image:OnGetStylesRsp(user_info)
end
function UGCAIHandler.send_ugc_pass_gencover_get_history_req(associate_id, page, page_size)
  log(bWriteLog and "UGCAIHandler.send_ugc_pass_gencover_get_history_req mod_id = " .. tostring(associate_id) .. " page = " .. tostring(page) .. " page_size = " .. tostring(page_size))
  NetManager.SendPkg(1560206887, associate_id, page, page_size)
end
function UGCAIHandler.on_ugc_pass_gencover_get_history_rsp(err_code, associate_id, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "UGCAIHandler.on_ugc_pass_gencover_get_history_rsp data = ", data)
  local logic_ugc_ai_cover_image = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_ai_cover_image)
  logic_ugc_ai_cover_image:HistoryAIDataRsp(associate_id, data)
end
function UGCAIHandler.send_ugc_pass_gencover_del_history_req(associate_id, task_id, pic)
  log(bWriteLog and "UGCAIHandler.send_ugc_pass_gencover_del_history_req mod_id = " .. tostring(associate_id) .. " task_id = " .. tostring(task_id) .. " pic = " .. tostring(pic))
  NetManager.SendPkg(866029667, associate_id, task_id, pic)
end
function UGCAIHandler.on_ugc_pass_gencover_del_history_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "UGCAIHandler.on_ugc_pass_gencover_del_history_rsp data = ", data)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DEL_AICOVERIMAGE, data)
end
function UGCAIHandler.send_ugc_pass_gencover_set_select_req(associate_id, task_id, pic, slot)
  log(bWriteLog and bwriteLog and "UGCAIHandler.send_ugc_pass_gencover_set_select_req associate_id = " .. tostring(associate_id) .. " task_id = " .. tostring(task_id) .. " pic = " .. tostring(pic))
  NetManager.SendPkg(933364327, associate_id, task_id, pic, slot)
end
function UGCAIHandler.on_ugc_pass_gencover_set_select_rsp(err_code, data)
  if err_code ~= 0 then
    if err_code == 511253 then
      ShowNotice(1050126)
      UIManager.CloseUI(UIManager.UI_Config.UGC_EditAICoverImage_UIBP)
    else
      ShowNotice(err_code)
    end
    return
  end
  log_tree(bWriteLog and "UGCAIHandler.on_ugc_pass_gencover_set_select_rsp data = ", data)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PASS_GENCOVER_SET_SELECT, data)
end
function UGCAIHandler.send_ugc_llm_chat_stop_req(trace_id)
  NetManager.SendPkg(109991, trace_id)
end
function UGCAIHandler.on_ugc_llm_chat_stop_rsp(err, trace_id, ret)
  if err ~= 0 then
    log(bWriteLog and "UGCAIHandler.on_ugc_llm_chat_stop_rsp" .. tostring(err))
    ShowNotice(err)
  end
  local logicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  logicModule:OnchatStopRsp(trace_id, ret)
end
function UGCAIHandler.send_ugc_get_llm_agent_data_req()
  NetManager.SendPkg(364292135)
end
function UGCAIHandler.on_ugc_get_llm_agent_data_rsp(err, llm_data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if err ~= 0 then
    Logic_UGC_Copilot:HandleNetworkError(err, "UGCAIHandler.on_ugc_get_llm_agent_data_rsp")
    return
  end
  Logic_UGC_Copilot:OnLLMQuotaRsp(llm_data)
end
function UGCAIHandler.send_ugc_llm_get_sessions_req()
  NetManager.SendPkg(753638183)
end
function UGCAIHandler.on_ugc_llm_get_sessions_rsp(err, rsp_data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if err ~= 0 then
    Logic_UGC_Copilot:HandleNetworkError(err, "UGCAIHandler.on_ugc_llm_get_sessions_rsp")
    return
  end
  Logic_UGC_Copilot:OnHistorySessionsRsp(rsp_data.data)
end
function UGCAIHandler.send_ugc_llm_get_recommend_req(scene_id)
  NetManager.SendPkg(102513495, scene_id)
end
function UGCAIHandler.on_ugc_llm_get_recommend_rsp(err, rsp_data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if err ~= 0 then
    Logic_UGC_Copilot:HandleNetworkError(err, "UGCAIHandler.on_ugc_llm_get_recommend_rsp")
    return
  end
  local questions = {}
  if rsp_data and rsp_data.data and rsp_data.data.choices then
    questions = rsp_data.data.choices
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_RECOMMEND_QUESTIONS, questions)
end
function UGCAIHandler.send_ugc_llm_one_chat_req(chat_id)
  NetManager.SendPkg(1843502375, chat_id)
end
function UGCAIHandler.on_ugc_llm_one_chat_rsp(err, rsp_data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  Logic_UGC_Copilot:OnChatMsgRsp(err, rsp_data)
end
function UGCAIHandler.send_ugc_llm_report_req(chat_id, trace_id, reason_type, reason_content)
  if chat_id and chat_id ~= "trash" then
    NetManager.SendPkg(330118087, chat_id, trace_id)
  end
end
function UGCAIHandler.on_ugc_llm_report_rsp(err, rsp_data)
  if err ~= 0 then
    ShowNotice(err)
  else
  end
end
function UGCAIHandler.send_ugc_llm_chat_rating_req(chat_id, trace_id, action)
  NetManager.SendPkg(84410131, chat_id, trace_id, action)
end
function UGCAIHandler.on_ugc_llm_chat_rating_rsp(err, rsp_data)
  if err ~= 0 then
    ShowNotice(err)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(17005222))
  end
end
function UGCAIHandler.send_ugc_llm_chat_message_req(chat_id, content, scene_id)
  NetManager.SendPkg(2108056167, chat_id, content, scene_id)
end
function UGCAIHandler.on_ugc_llm_chat_message_rsp(err, event, data, cb_data)
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if not Logic_UGC_Copilot then
    log(bWriteLog and "ERROR: Logic_UGC_Copilot \230\168\161\229\157\151\230\156\170\230\137\190\229\136\176!")
    return
  end
  Logic_UGC_Copilot:OnAIMessageNetworkRsp(err, event, data, cb_data)
end
function UGCAIHandler.send_ugc_use_llm_card_req(instids)
  NetManager.SendPkg(936007527, instids)
end
function UGCAIHandler.on_ugc_use_llm_card_rsp(err, instids)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  logicModule.QuotaManager:FetchLLMQuota()
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_LIMIT_UPDATE, instids)
end
function UGCAIHandler.send_llm_generate_image_req(prompt)
  print("UGCHandler.send_llm_generate_image_req", prompt)
  NetManager.SendPkg(1140902951, prompt)
end
function UGCAIHandler.on_llm_generate_image_rsp(img_url, response_text)
  print("UGCHandler.on_llm_generate_image_rsp", img_url, response_text)
  if not img_url then
    return
  end
  if type(img_url) == "table" then
    response_text = img_url.response
    img_url = img_url.image_url
  end
  local LogicMomentHelper = require("client.slua.logic.moment.logic_moment_helper")
  local CdnDomain = LogicMomentHelper.GetDomain(1)
  local Response = {
    choices = {
      {
        delta = {
          type = "images",
          content = {
            [1] = {
              title = response_text,
              url = CdnDomain .. img_url
            }
          }
        },
        finish_reason = nil
      }
    }
  }
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  _G.CurrentTempChatID = _G.CurrentTempChatID or "123-abc"
  Logic_UGC_Copilot.CurrentChatID = _G.CurrentTempChatID
  Logic_UGC_Copilot.ActiveTraceID = _G.CurrentTempChatID .. "_trace"
  local OperationHandler = Logic_UGC_Copilot.OperationHandler
  Logic_UGC_Copilot.StateMachine.CurrentState = Config_UGC_Copilot.Enum_UGC_LLM_State.NEW_CHAT_PENDING
  Logic_UGC_Copilot.MessageHandler:SimulateAIResponse({ret = 0}, "100", response_text, nil, nil, Logic_UGC_Copilot.ActiveTraceID)
  Logic_UGC_Copilot.StateMachine.CurrentState = Config_UGC_Copilot.Enum_UGC_LLM_State.STREAMING
  OperationHandler:OnAIMessageNetworkRsp(0, "100", Response, {
    trace_id = Logic_UGC_Copilot.ActiveTraceID
  })
  OperationHandler:StopChat()
  Logic_UGC_Copilot.StateMachine.CurrentState = Config_UGC_Copilot.Enum_UGC_LLM_State.IDLE
  FuncUtil.UE4ExecuteConsoleCommand("CallGMLua AddAlbum:" .. img_url)
end
return UGCAIHandler