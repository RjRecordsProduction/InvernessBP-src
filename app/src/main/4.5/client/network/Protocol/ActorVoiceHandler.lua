local NetManager = require("client.network.comm.NetManager")
local ActorVoiceHandler = {}
function ActorVoiceHandler.send_update_voice_msgs_req(selectedVoiceList, selectedWheelVoiceList, flag, ext_msgs, ext_rotary_table, ext_feature_msgs)
  NetManager.SendPkg(991958070, selectedVoiceList, selectedWheelVoiceList, flag, ext_msgs, ext_rotary_table, ext_feature_msgs)
end
function ActorVoiceHandler.send_voice_msg_audition_req(id)
  NetManager.SendPkg(1447245243, id)
end
function ActorVoiceHandler.send_get_voice_msg_info_req()
  NetManager.SendPkg(501679559)
end
function ActorVoiceHandler.on_get_voice_msg_info_rsp(voice_data)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.GetActorVoiceInfoRes(voice_data)
end
function ActorVoiceHandler.on_voice_dubber_changed_notify(dubber, dubber_expire)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.ActorChangedNotify(dubber, dubber_expire)
end
function ActorVoiceHandler.on_voice_dubber_first_get_notify(ActorID)
  if ActorID ~= 0 then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_QUICK_MESSAGE_NEW, {ActorID})
  end
end
function ActorVoiceHandler.on_voice_changed_notify(own_msgs, msg_expire)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.ActorVoiceChangedNotify(own_msgs, msg_expire)
end
function ActorVoiceHandler.on_voice_decompose_notify(resId, items)
  log(bWriteLog and "ActorVoiceSystem.VoiceDecomposeNotify. resId = ", resId)
  log_tree("ActorVoiceSystem.VoiceDecomposeNotify. items = ", items)
end
function ActorVoiceHandler.send_select_voice_plan_change(planID)
  NetManager.SendPkg(1167693648, planID)
end
function ActorVoiceHandler.send_select_voice_enter_play_change(actorID)
  NetManager.SendPkg(2090114506, actorID)
end
function ActorVoiceHandler.send_change_dubber_collect_data_req(dubber_id, optype)
  log(bWriteLog and string.format("ActorVoiceHandler.send_change_dubber_collect_data_req. dubber_id=%s, optype=%s", tostring(dubber_id), tostring(optype)))
  NetManager.SendPkg(812072487, dubber_id, optype)
end
function ActorVoiceHandler.on_change_dubber_collect_data_rsp(retcode, dubber_id, optype, collect_time)
  log(bWriteLog and string.format("ActorVoiceHandler.on_change_dubber_collect_data_rsp. retcode=%s, dubber_id=%s, optype=%s, collect_time=%s", tostring(retcode), tostring(dubber_id), tostring(optype), tostring(collect_time)))
  if retcode ~= 0 then
    ShowNotice(retcode)
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.OnRspActorCollectInfo(dubber_id, optype == 1, collect_time)
end
return ActorVoiceHandler