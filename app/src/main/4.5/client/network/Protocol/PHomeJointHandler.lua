local NetManager = require("client.network.comm.NetManager")
local PHomeJointHandler = {}
function PHomeJointHandler.send_manor_joint_info_req()
  log(bWriteLog and "PHomeJointHandler.send_manor_joint_info_req")
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_joint_info_req")
end
function PHomeJointHandler.on_manor_joint_info_rsp(err, joint_info)
  log(bWriteLog and "PHomeJointHandler.on_manor_joint_info_rsp err = " .. err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  joint_info = Decode(joint_info)
  log_tree("joint_info = ", joint_info)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_info_rsp(joint_info)
end
function PHomeJointHandler.send_manor_joint_invite_req(invitee, master_uid)
  log(bWriteLog and "PHomeJointHandler.send_manor_joint_invite_req invitee = " .. invitee .. ", master_uid = " .. master_uid)
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_joint_invite_req", invitee, master_uid)
end
function PHomeJointHandler.on_manor_joint_invite_rsp(err, invitee, joint_cd)
  log(bWriteLog and "PHomeJointHandler.on_manor_joint_invite_rsp err = " .. err .. ", invitee = " .. tostring(invitee))
  if err == 19810238 then
    local TimeUtil = require("client.common.time_util")
    local cdTimeStr = TimeUtil.FormatCountDownTime_D_or_HMS(joint_cd, 1)
    ShowNotice(LocUtil.LocalizeResFormat(19810238, cdTimeStr))
    return
  end
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_invite_rsp(invitee)
end
function PHomeJointHandler.on_manor_joint_invite_notify(inviter, master_uid)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_invite_notify(inviter, master_uid)
end
function PHomeJointHandler.send_manor_joint_reply_req(inviter, agree)
  log(bWriteLog and "[DeanJYT] PHomeJointHandler.send_manor_joint_reply_req inviter = " .. tostring(inviter) .. ", agree = " .. tostring(agree))
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_joint_reply_req", inviter, agree)
end
function PHomeJointHandler.on_manor_joint_reply_rsp(err, inviter, master_uid, do_joint_time)
  log(bWriteLog and "[DeanJYT] PHomeJointHandler.on_manor_joint_reply_rsp err = " .. tostring(err))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_reply_rsp(inviter, master_uid, do_joint_time)
end
function PHomeJointHandler.on_manor_joint_start_notify(invitee, master_uid, do_joint_time)
end
function PHomeJointHandler.on_manor_joint_finish_notify(err, mate_uid, master_uid)
  log(bWriteLog and "[DeanJYT] PHomeJointHandler.on_manor_joint_finish_notify err = " .. tostring(err))
  PHomeJointHandler.send_manor_joint_info_req()
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
  local home_macros = require("client.slua.logic.home.home_macros")
  logic_home_detail:GetOrReqHomeDetail(tonumber(DataMgr.roleData.uid), nil, true, home_macros.ENUM_DETAIL_SCENE_TYPE.MainLobby)
end
function PHomeJointHandler.send_manor_joint_terminate_apply_req(force)
  log(bWriteLog and "PHomeJointHandler.send_manor_joint_terminate_apply_req force = " .. tostring(force))
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_joint_terminate_apply_req", force)
end
function PHomeJointHandler.on_manor_joint_terminate_apply_rsp(err)
  log(bWriteLog and "PHomeJointHandler.on_manor_joint_terminate_apply_rsp err = " .. err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_terminate_apply_rsp()
end
function PHomeJointHandler.on_manor_joint_terminate_apply_notify()
  log(bWriteLog and "PHomeJointHandler.on_manor_joint_terminate_apply_notify")
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_terminate_apply_notify()
end
function PHomeJointHandler.send_manor_joint_terminate_reply_req(agree)
  log(bWriteLog and "PHomeExchangeDealerHandler.send_manor_joint_terminate_reply_req agree = " .. tostring(agree))
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_joint_terminate_reply_req", agree)
end
function PHomeJointHandler.on_manor_joint_terminate_reply_rsp(err)
  log(bWriteLog and "PHomeJointHandler.on_manor_joint_terminate_reply_rsp err = " .. tostring(err))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_terminate_reply_rsp()
end
function PHomeJointHandler.on_manor_joint_terminate_reply_notify(agree)
  log(bWriteLog and "[dongkaizha] PHomeJointHandler.on_manor_joint_terminate_reply_notify agree = " .. tostring(agree))
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:proc_manor_joint_terminate_reply_notify(agree)
end
function PHomeJointHandler.send_last_joint_manor_to_model_req(slot_id)
  log(bWriteLog and "PHomeJointHandler.send_last_joint_manor_to_model_req slot_id = " .. tostring(slot_id))
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("last_joint_manor_to_model_req", slot_id)
end
function PHomeJointHandler.on_last_joint_manor_to_model_rsp(err, slot_id, expect_level)
  log(bWriteLog and "PHomeJointHandler.on_last_joint_manor_to_model_rsp err = " .. tostring(err))
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if err == 19810001 then
    logic_home_joint:ShowHasSaveJoint()
    return
  end
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  logic_home_joint:proc_on_last_joint_manor_to_model_rsp(slot_id, expect_level)
end
return PHomeJointHandler