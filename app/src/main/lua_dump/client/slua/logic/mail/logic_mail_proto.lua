local logic_mail_proto = {}
function logic_mail_proto.query_mail_summary_req(source)
  log(bWriteLog and "[chub]logic_mail_proto.query_mail_summary_req")
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_on_query_mail_summary_v2(true, source)
end
function logic_mail_proto.on_query_mail_summary_res(mailsList)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleQueryMailRes(mailsList)
end
function logic_mail_proto.on_query_mail_summary_v2_res(mailsList)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleQueryMailRes(mailsList)
  local mail_notify_popup = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.mail_notify_popup)
  mail_notify_popup:CheckOutLinePoppupNotify()
end
function logic_mail_proto.batch_fetch_friend_mail_req(list)
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_batch_fetch_friend_mail_req(list, 1)
end
function logic_mail_proto.on_batch_fetch_friend_mail_rsp(list)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleFetchFriendMailRes(list)
end
function logic_mail_proto.req_delete_mail_list(mailIdList)
  log_tree(bWriteLog and "[v_wllwu] logic_mail.req_delete_mail_list mailIdList is ", mailIdList)
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_on_delete_mail_list(mailIdList)
end
function logic_mail_proto.on_delete_mail_list_res(res)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleDeleteMailListRes()
end
function logic_mail_proto.get_friend_misc_info_req(frdUid)
  local rejoin_num
  if frdUid then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local friendProfile = logic_profile:GetLocalProfile(frdUid)
    if friendProfile and friendProfile.rejoin_start_time and friendProfile.dynamic_life_time then
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      local rejoin_start_time = friendProfile.rejoin_start_time
      local rejoin_end_time = rejoin_start_time + friendProfile.dynamic_life_time * 86400
      if serverTime >= rejoin_start_time and serverTime < rejoin_end_time then
        rejoin_num = friendProfile.rejoin_num
      end
      log(bWriteLog and "[v_wllwu] get_friend_misc_info_req, rejoin_start_time is: " .. tostring(rejoin_start_time) .. "; rejoin_end_time is: " .. tostring(rejoin_end_time) .. "; serverTime is: " .. tostring(serverTime))
    end
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_friend_misc_info_req(frdUid, rejoin_num)
end
function logic_mail_proto.on_get_friend_misc_info_rsp(result)
  if result == nil or result.recvLeftGoldCnt == nil then
    return
  end
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleGetFriendMiscInfoRes(result)
end
function logic_mail_proto.send_on_set_mail_readflag(mailId)
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_on_set_mail_readflag(mailId, true)
end
function logic_mail_proto.send_on_read_mail_list(mailIdList)
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_on_read_mail_list(mailIdList)
end
function logic_mail_proto.fetch_mail_attach(mailId)
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_on_fetch_mail_attach(mailId)
end
function logic_mail_proto.on_fetch_attach_res(state, mailId, decomposeInfo, item_list)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleFetchAttachRes(state, mailId, decomposeInfo, item_list)
end
function logic_mail_proto.on_new_mail_notify(mailType, subType, senderUid, mailInfo, indexId)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleNewMailNotify(mailType, subType, senderUid, mailInfo, indexId)
  local logic_security = require("client.slua.logic.security.logic_security")
  logic_security.CheckIsSlapFaceNotify(mailInfo)
  logic_security.CheckIsSlapWarningPenalty(mailInfo)
  local mail_notify_popup = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.mail_notify_popup)
  mail_notify_popup:CheckPoppupNotify(mailInfo)
end
function logic_mail_proto.send_batch_fetch_all_mail_req(mailIdList, invokeType)
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_batch_fetch_all_mail_req(mailIdList, invokeType)
end
function logic_mail_proto.on_batch_fetch_all_attach_res(result_reward_id_list)
  if not result_reward_id_list or #result_reward_id_list <= 0 then
    log(bWriteLog and "[v_wllwu] logic_mail_proto.on_batch_fetch_all_attach_res return, result_reward_id_list is empty")
    return
  end
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.HandleBatchAttachRes(result_reward_id_list)
end
return logic_mail_proto