local NetManager = require("client.network.comm.NetManager")
local SmartAssistantHandler = {}
function SmartAssistantHandler.send_assistant_get_cfg_req()
  NetManager.SendPkg(1635409435)
end
function SmartAssistantHandler.on_assistant_get_cfg_rsp(main_page_cfg, extend_page_cfgs, reward_switch_cfg, club_page_cfgs)
  local LogicSmartAssistantCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicSmartAssistantCfg)
  LogicSmartAssistantCfg:on_assistant_get_cfg_rsp(main_page_cfg, extend_page_cfgs, reward_switch_cfg, club_page_cfgs)
end
function SmartAssistantHandler.send_robot_assistant_llm_chat_req(chat_id, content, ext_info)
  printf("SmartAssistantHandler.send_robot_assistant_llm_chat_req chat_id:%s, content:%s", chat_id, content)
  NetManager.SendPkg(1252649575, chat_id, content, ext_info)
end
function SmartAssistantHandler.on_robot_assistant_llm_chat_rsp(err_code, event_id, chat_data, ext_info)
  print(bWriteLog and "SmartAssistantHandler.on_robot_assistant_llm_chat_rsp err_code:" .. tostring(err_code) .. " event_id:" .. tostring(event_id) .. " chat_data:" .. json.encode(chat_data) .. " ext_info:" .. json.encode(ext_info))
  if err_code == 560002 then
    local BattleHander = require("client.network.Protocol.BattleHander")
    BattleHander.send_get_ban_id_req(240)
    printf("SmartAssistantHandler.on_robot_assistant_llm_chat_rsp send_get_ban_id_req by err_code: %s", err_code)
    return
  end
  local SAChatMsgMgr = require("client.slua.umg.SmartAssistantV2.SAChatMsgMgr")
  SAChatMsgMgr:on_robot_assistant_llm_chat_rsp(err_code, event_id, chat_data, ext_info)
end
function SmartAssistantHandler.on_notify_minitv_action(action_desc)
  log_tree("SmartAssistantHandler.on_notify_minitv_action action_desc:", action_desc)
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant:on_notify_minitv_action(action_desc)
end
function SmartAssistantHandler.send_robot_assistant_llm_cancel_chat_req(chat_id)
  print(bWriteLog and "SmartAssistantHandler.send_robot_assistant_llm_cancel_chat_req chat_id:" .. chat_id)
  NetManager.SendPkg(1637865383, chat_id)
end
function SmartAssistantHandler.on_robot_assistant_llm_cancel_chat_rsp(err_code)
  print(bWriteLog and "SmartAssistantHandler.on_robot_assistant_llm_cancel_chat_rsp err_code:" .. err_code)
end
function SmartAssistantHandler.send_minitv_daily_lottery_draw_req()
  print(bWriteLog and "SmartAssistantHandler.send_minitv_daily_lottery_draw_req")
  NetManager.SendPkg(1281041139)
end
function SmartAssistantHandler.on_minitv_daily_lottery_draw_rsp(err_code, data)
  log_tree("SmartAssistantHandler.on_minitv_daily_lottery_draw_rsp err_code:" .. tostring(err_code), data)
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant.sd_minitv_user_info.can_daily_draw_flag = false
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function SmartAssistantHandler.send_get_minitv_user_info_req()
  print(bWriteLog and "SmartAssistantHandler.send_get_minitv_user_info_req")
  NetManager.SendPkg(657057767)
end
function SmartAssistantHandler.on_get_minitv_user_info_rsp(err_code, data)
  log_tree("SmartAssistantHandler.on_get_minitv_user_info_rsp err_code:" .. tostring(err_code), data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant.sd_minitv_user_info = data
end
function SmartAssistantHandler.send_robot_assistant_report_ai_req(report_type, report_content)
  NetManager.SendPkg(865422343, report_type, report_content)
end
function SmartAssistantHandler.on_robot_assistant_report_ai_rsp(err_code)
end
function SmartAssistantHandler.send_robot_assistant_response_answer_req(chat_id, msg_id, opertype)
  printf("SmartAssistantHandler.send_robot_assistant_response_answer_req chat_id:%s, msg_id:%s, opertype:%s", chat_id, msg_id, opertype)
  NetManager.SendPkg(1934474747, chat_id, msg_id, opertype)
end
function SmartAssistantHandler.on_robot_assistant_response_answer_rsp(err_code)
  printf("SmartAssistantHandler.on_robot_assistant_response_answer_rsp err_code:%s", err_code)
end
function SmartAssistantHandler.send_get_robot_assistant_reward_task_notice_req()
  printf("SmartAssistantHandler.send_get_robot_assistant_reward_task_notice_req")
  NetManager.SendPkg(1777356839)
end
function SmartAssistantHandler.on_get_robot_assistant_reward_task_notice_rsp(err_code, info)
  printf("SmartAssistantHandler.on_get_robot_assistant_reward_task_notice_rsp err_code:%s, info:%s", err_code, json.encode(info))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant:on_get_robot_assistant_reward_task_notice_rsp(info)
end
function SmartAssistantHandler.send_robot_assistant_reward_task_report_req(info)
  printf("SmartAssistantHandler.send_robot_assistant_reward_task_report_req info:%s", json.encode(info))
  NetManager.SendPkg(1413388615, info)
end
function SmartAssistantHandler.on_robot_assistant_reward_task_report_rsp(err_code)
  printf("SmartAssistantHandler.on_robot_assistant_reward_task_report_rsp err_code:%s", err_code)
end
function SmartAssistantHandler.send_robot_assistant_notice_module_change_req(key)
  NetManager.SendPkg(991574623, key)
end
function SmartAssistantHandler.send_report_minitv_raw_event_req(raw_event_id, args)
  printf("SmartAssistantHandler.send_report_minitv_raw_event_req raw_event_id:%s, args:%s", raw_event_id, args and json.encode(args) or "nil")
  NetManager.SendPkg(320480793, raw_event_id, args)
end
function SmartAssistantHandler.send_robot_assistant_get_reward_req(module_key)
  printf("SmartAssistantHandler.send_robot_assistant_get_reward_req module_key:%s", module_key)
  NetManager.SendPkg(1820907207, module_key)
end
function SmartAssistantHandler.on_robot_assistant_get_reward_rsp(err_code, info)
  printf("SmartAssistantHandler.on_robot_assistant_get_reward_rsp err_code:%s, info:%s", err_code, info and json.encode(info) or "nil")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function SmartAssistantHandler.on_robot_assistant_safe_operation_notify(operation_key)
  log_tree("SmartAssistantHandler.on_robot_assistant_safe_operation_notify operation_key:", operation_key)
  ShowNotice(240133)
  UIManager.CloseUI(UIManager.UI_Config.SmartAssistantV2_MainDialogue_UIBP)
end
function SmartAssistantHandler.send_robot_assistant_get_soul_recommend_topic_req()
  printf("SmartAssistantHandler.send_robot_assistant_get_soul_recommend_topic_req")
  NetManager.SendPkg(982471719)
end
function SmartAssistantHandler.on_robot_assistant_get_soul_recommend_topic_rsp(err_code, info)
  printf("SmartAssistantHandler.on_robot_assistant_get_soul_recommend_topic_rsp err_code:%s, info:%s", err_code, info and json.encode(info) or "nil")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function SmartAssistantHandler.send_report_minitv_user_action_req(event_id, uniq_id, args)
  printf("SmartAssistantHandler.send_report_minitv_user_action_req event_id:%s, uniq_id:%s, args:%s", event_id, uniq_id, args and json.encode(args) or "nil")
  NetManager.SendPkg(1726040191, event_id, uniq_id, args)
end
function SmartAssistantHandler.on_report_minitv_user_action_rsp(err_code)
  printf("SmartAssistantHandler.on_report_minitv_user_action_rsp err_code:%s", err_code)
end
local MOCK_DELAY_SECONDS = 0.5
function SmartAssistantHandler.send_load_auto_equipment_req(scene_type)
  printf("SmartAssistantHandler.send_load_auto_equipment_req scene_type:%s", scene_type)
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  if LogicSmartAssistant:IsUseTestData(scene_type) then
    local mockRecomItems = LogicSmartAssistant:GetTestRawRecomItems(scene_type)
    printf("SmartAssistantHandler.send_load_auto_equipment_req [MOCK] scene_type:%s, delay:%.1fs", scene_type, MOCK_DELAY_SECONDS)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(MOCK_DELAY_SECONDS, function()
      printf("SmartAssistantHandler.send_load_auto_equipment_req [MOCK] firing rsp for scene_type:%s", scene_type)
      SmartAssistantHandler.on_load_auto_equipment_rsp(0, scene_type, mockRecomItems)
    end)
    return
  end
  NetManager.SendPkg(802992287, scene_type)
end
function SmartAssistantHandler.on_load_auto_equipment_rsp(err_code, sceneType, recom_items)
  printf("SmartAssistantHandler.on_load_auto_equipment_rsp err_code:%s, sceneType:%s, recom_items:%s", err_code, sceneType, recom_items and json.encode(recom_items) or "nil")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  local recommendData = LogicSmartAssistant:BuildRecommendDataFromResponse(sceneType, recom_items)
  LogicSmartAssistant:SetCachedRecommendData(sceneType, recommendData)
end
local reqRsp = {
  send_robot_assistant_llm_cancel_chat_req = "on_robot_assistant_llm_cancel_chat_rsp",
  send_minitv_daily_lottery_draw_req = "on_minitv_daily_lottery_draw_rsp",
  send_get_minitv_user_info_req = "on_get_minitv_user_info_rsp",
  send_robot_assistant_report_ai_req = "on_robot_assistant_report_ai_rsp",
  send_robot_assistant_response_answer_req = "on_robot_assistant_response_answer_rsp",
  send_get_robot_assistant_reward_task_notice_req = "on_get_robot_assistant_reward_task_notice_rsp",
  send_robot_assistant_reward_task_report_req = "on_robot_assistant_reward_task_report_rsp",
  send_robot_assistant_get_reward_req = "on_robot_assistant_get_reward_rsp",
  send_robot_assistant_get_soul_recommend_topic_req = "on_robot_assistant_get_soul_recommend_topic_rsp",
  send_report_minitv_user_action_req = "on_report_minitv_user_action_rsp",
  send_load_auto_equipment_req = "on_load_auto_equipment_rsp",
  send_assistant_get_cfg_req = "on_assistant_get_cfg_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, SmartAssistantHandler)
return SmartAssistantHandler