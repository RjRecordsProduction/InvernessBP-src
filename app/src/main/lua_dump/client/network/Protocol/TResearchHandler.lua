local NetManager = require("client.network.comm.NetManager")
local TResearchHandler = {}
function TResearchHandler.send_get_chest_countdown()
  log(bWriteLog and string.format("TResearchHandler.send_get_chest_countdown"))
  NetManager.SendPkg(703687636)
end
function TResearchHandler.on_get_chest_countdown_rsp(ret_code, dataList, use_accelerate)
  log(bWriteLog and string.format("TResearchHandler.on_get_chest_countdown_rsp, ret_code:%s", ret_code))
  log_tree(bWriteLog and "TResearchHandler.on_get_chest_countdown_rsp dataList", dataList)
  log(bWriteLog and string.format("TResearchHandler.on_get_chest_countdown_rsp, use_accelerate:%s", use_accelerate))
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  logic_xmission_operation:on_get_chest_countdown_rsp(ret_code, dataList, use_accelerate)
end
function TResearchHandler.send_use_chest_accelerate(inst_id, count, chestID)
  log(bWriteLog and string.format("TResearchHandler send_use_chest_accelerate, inst_id:%s count:%s chestID:%s", inst_id, count, chestID))
  NetManager.SendPkg(1173408417, inst_id, count, chestID)
end
function TResearchHandler.send_put_chest_on_console(inst_id)
  log(bWriteLog and string.format("TResearchHandler send_put_chest_on_console, inst_id:%s", inst_id))
  NetManager.SendPkg(145818892, inst_id)
end
function TResearchHandler.on_put_chest_on_console_rsp(ret_code)
  log(bWriteLog and string.format("TResearchHandler on_put_chest_on_console_rsp, ret_code:%s", ret_code))
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  logic_xmission_operation:on_put_chest_on_console_rsp(ret_code)
end
function TResearchHandler.send_receive_sys_gift()
  log(bWriteLog and "TResearchHandler send_receive_sys_gift")
  NetManager.SendPkg(1117376588)
end
function TResearchHandler.on_receive_sys_gift_rsp(ret_code, item_list)
  log(bWriteLog and string.format("TResearchHandler on_receive_sys_gift_rsp, ret_code:%s", ret_code))
  log_tree(bWriteLog and "TResearchHandler.on_receive_sys_gift_rsp item_list", item_list)
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  logic_xmission_operation:on_receive_sys_gift_rsp(ret_code, item_list)
end
function TResearchHandler.send_receive_pve_affix_guide_task_reward_req(receive_type, recevie_data)
  log(bWriteLog and "[wzp] TResearchHandler send_receive_pve_affix_guide_task_reward_req")
  local tb = {receive_type = receive_type, recevie_data = recevie_data}
  log_tree(bWriteLog and "[wzp] TResearchHandler.send_receive_pve_affix_guide_task_reward_req tb", tb)
  NetManager.SendPkg(1398566447, receive_type, recevie_data)
end
function TResearchHandler.on_receive_pve_affix_guide_task_reward_rsp(errcode, item_list)
  log(bWriteLog and string.format("[wzp] TResearchHandler on_receive_pve_affix_guide_task_reward_rsp, errcode:%s", errcode))
  if errcode ~= 0 then
    if errcode == 100251094 then
      return
    end
    ShowNotice(errcode)
    return
  end
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  logic_xmission_operation:on_get_pve_affix_guide_task_reveive_rsp(1)
  log_tree(bWriteLog and "[wzp] TResearchHandler.on_receive_pve_affix_guide_task_reward_rsp item_list", item_list)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_PVE_AFFIX_GUIDE_REWARD_RSP, item_list)
end
function TResearchHandler.send_get_pve_affix_guide_task_reveive_req()
  log(bWriteLog and "[wzp] TResearchHandler send_get_pve_affix_guide_task_reveive_data_req")
  NetManager.SendPkg(126960679)
end
function TResearchHandler.on_get_pve_affix_guide_task_reveive_rsp(is_get)
  log(bWriteLog and string.format("[wzp] TResearchHandler on_get_pve_affix_guide_task_reveive_data_rsp, is_get:%s", is_get))
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_IS_GOT_REWARD_RSP, is_get)
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  logic_xmission_operation:on_get_pve_affix_guide_task_reveive_rsp(is_get)
end
function TResearchHandler.send_metro_decompose_item_req(inst_id)
  log(bWriteLog and string.format("TResearchHandler.send_metro_decompose_item_req, inst_id:%s", inst_id))
  NetManager.SendPkg(330748711, inst_id)
end
function TResearchHandler.on_metro_decompose_item_rsp(err_code, item_id, item_num)
  log(bWriteLog and string.format("TResearchHandler.on_metro_decompose_item_rsp, err_code:%s", err_code))
  log(bWriteLog and string.format("TResearchHandler.on_metro_decompose_item_rsp, item_id:%s", item_id))
  log(bWriteLog and string.format("TResearchHandler.on_metro_decompose_item_rsp, item_num:%s", item_num))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  logic_xmission_operation:OnMetroDecomposeItemRsp(item_id, item_num)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_DECOMPOSE_ITEM_RSP)
end
function TResearchHandler.send_metro_affix_upgrade_req(inst_id)
  log(bWriteLog and string.format("TResearchHandler.send_metro_affix_upgrade_req, inst_id:%s", inst_id))
  NetManager.SendPkg(125504855, inst_id)
end
function TResearchHandler.on_metro_affix_upgrade_rsp(err_code, inst_id, item)
  log(bWriteLog and string.format("TResearchHandler.on_metro_affix_upgrade_rsp, err_code:%s", err_code))
  log(bWriteLog and string.format("TResearchHandler.on_metro_affix_upgrade_rsp, inst_id:%s", inst_id))
  log_tree(bWriteLog and "TResearchHandler.on_metro_affix_upgrade_rsp item", item)
  if err_code == 100251209 then
    ShowNotice(64925)
    return
  end
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  logic_xmission_warpre.ChangeItemInfo(inst_id, item)
end
function TResearchHandler.send_receive_affix_guide_task_reward_req(inst_id)
  log(bWriteLog and string.format("TResearchHandler.send_receive_affix_guide_task_reward_req, inst_id:%s", inst_id))
  NetManager.SendPkg(882279855, inst_id)
end
function TResearchHandler.on_receive_affix_guide_task_reward_rsp(err_code, item_info, sent_pve_reward)
  log(bWriteLog and string.format("TResearchHandler.on_receive_affix_guide_task_reward_rsp, err_code:%s", err_code))
  log_tree(bWriteLog and "TResearchHandler.on_receive_affix_guide_task_reward_rsp item_info", item_info)
  log(bWriteLog and string.format("TResearchHandler.on_receive_affix_guide_task_reward_rsp, sent_pve_reward:%s", sent_pve_reward))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local rewardList = {}
  local UIUtil = require("client.common.ui_util")
  for itemID, value in pairs(item_info) do
    table.insert(rewardList, {resid = itemID, count = value})
  end
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  if sent_pve_reward == 1 then
    local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
    XMissionConversationSystem.PushConversation(200038, XMissionConversationSystem.E_ConversationAwardType.Item, rewardList)
    logic_xmission_info:SetMetroValueByKey("pve_affix_guide_task_reward", 1)
  else
    local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
    XMissionConversationSystem.PushConversation(200037, XMissionConversationSystem.E_ConversationAwardType.Item, rewardList)
  end
  logic_xmission_info:SetMetroValueByKey("affix_guide_task_status", 1)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_PVEAFFIX_ISNEW_UPDATE)
end
local reqRsp = {
  send_metro_decompose_item_req = "on_metro_decompose_item_rsp",
  send_metro_affix_upgrade_req = "on_metro_affix_upgrade_rsp",
  send_receive_affix_guide_task_reward_req = "on_receive_affix_guide_task_reward_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, TResearchHandler)
return TResearchHandler