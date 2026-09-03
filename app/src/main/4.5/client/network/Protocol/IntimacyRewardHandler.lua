local NetManager = require("client.network.comm.NetManager")
local IntimacyRewardHandler = {}
function IntimacyRewardHandler.send_set_posture_req(posture_id)
  NetManager.SendPkg(1459551791, posture_id)
end
function IntimacyRewardHandler.on_set_posture_rsp(res, posture_id)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.set_posture_rsp(res, posture_id)
end
function IntimacyRewardHandler.send_get_posture_info_req()
  log(bWriteLog and "IntimacyRewardHandler.send_get_posture_info_req")
  NetManager.SendPkg(1911018855)
end
function IntimacyRewardHandler.on_get_posture_info_rsp(res, cur_posture, posture_list, cur_interact_avatar_posture, interact_avatar_posture_list)
  log(bWriteLog and "IntimacyRewardHandler.on_get_posture_info_rsp")
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.get_posture_info_rsp(res, cur_posture, posture_list, cur_interact_avatar_posture, interact_avatar_posture_list)
end
function IntimacyRewardHandler.on_notify_posture_chg(cur_posture_id, posture_id, one_posture_info)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.notify_posture_chg(cur_posture_id, posture_id, one_posture_info)
end
function IntimacyRewardHandler.send_get_lobby_intimacy_partner_info_req()
  log(bWriteLog and "IntimacyRewardHandler.send_get_lobby_intimacy_partner_info_req")
  NetManager.SendPkg(55849819)
end
function IntimacyRewardHandler.on_get_lobby_intimacy_partner_info_rsp(partner_info)
  log(bWriteLog and "IntimacyRewardHandler.on_get_lobby_intimacy_partner_info_rsp")
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.get_intimacy_reward_info_rsp(partner_info)
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_GET_INFO_RSP)
end
function IntimacyRewardHandler.send_get_partner_reward_req(reward_id)
  NetManager.SendPkg(660533031, reward_id)
end
function IntimacyRewardHandler.on_get_partner_reward_rsp(res, reward_id)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.get_intimacy_reward_rsp(res, reward_id)
end
function IntimacyRewardHandler.on_notify_new_partner_reward()
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.notify_new_intimacy_reward()
end
function IntimacyRewardHandler.on_notify_interact_avatar_posture_chg(cur_interact_avatar_posture, resid, one_posture_info)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.proc_notify_interact_avatar_posture_chg(cur_interact_avatar_posture, resid, one_posture_info)
end
return IntimacyRewardHandler