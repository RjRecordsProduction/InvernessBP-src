local NetManager = require("client.network.comm.NetManager")
local MailHandler = {}
function MailHandler.send_on_query_mail_summary()
  NetManager.SendPkg(653577495)
end
function MailHandler.on_on_query_mail_summary_res(mailslist)
  log(bWriteLog and "[chub]MailHandler.on_on_query_mail_summary_res")
  log_tree(bWriteLog and "[chub] MailHandler.on_on_query_mail_summary_res = ", mailslist)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_query_mail_summary_res(mailslist)
end
function MailHandler.send_on_set_mail_readflag(themailid, readflag)
  log(bWriteLog and "[chub]MailHandler.send_on_set_mail_readflag, themailid = " .. tostring(themailid) .. "readflag =" .. tostring(readflag))
  NetManager.SendPkg(2135051847, themailid, readflag)
end
function MailHandler.send_on_read_mail_list(mailidlist)
  log_tree(bWriteLog and "[chub] MailHandler.send_on_read_mail_list, mailidlist = ", mailidlist)
  NetManager.SendPkg(1876302299, mailidlist)
end
function MailHandler.send_on_fetch_mail_attach(mailid, decompose)
  log(bWriteLog and "[chub]MailHandler.send_on_fetch_mail_attach, mailid = " .. tostring(mailid) .. "decompose =" .. tostring(decompose))
  NetManager.SendPkg(1626423949, mailid, decompose)
end
function MailHandler.on_on_fetch_attach_res(state, mailid, decompose_info, item_list)
  log(bWriteLog and "[chub]MailHandler.on_on_fetch_attach_res, state = " .. tostring(state) .. "mailid =" .. tostring(mailid))
  log_tree(bWriteLog and "[chub] MailHandler.on_on_fetch_attach_res, decompose_info = ", decompose_info)
  log_tree(bWriteLog and "[v_wllwu] on_on_fetch_attach_res, item_list is:", item_list)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_fetch_attach_res(state, mailid, decompose_info, item_list)
end
function MailHandler.send_on_delete_mail_list(mailidlist)
  log_tree(bWriteLog and "[chub] MailHandler.send_on_delete_mail_list, mailidlist = ", mailidlist)
  NetManager.SendPkg(1613255579, mailidlist)
end
function MailHandler.on_on_delete_mail_list_res(str)
  log(bWriteLog and "[chub]MailHandler.on_on_delete_mail_list_res, str = " .. tostring(str))
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_delete_mail_list_res(str)
end
function MailHandler.send_delete_account_bind_req(type)
  log(bWriteLog and "[chub]MailHandler.send_delete_account_bind_req, type = " .. tostring(type))
  NetManager.SendPkg(629923815, type)
end
function MailHandler.on_delete_account_bind_rsp(ok)
  local StoreIndiaUtils = require("client.logic.store.store_india_utils")
  StoreIndiaUtils.delete_account_bind_rsp(ok)
end
function MailHandler.on_on_new_mail_notify(mail_type, subtype, sender_uid, mail_info, index_id)
  log(bWriteLog and "[chub]MailHandler.on_on_new_mail_notify, mail_type = " .. tostring(mail_type) .. "subtype =" .. tostring(subtype) .. "sender_uid =" .. tostring(sender_uid) .. "index_id =" .. tostring(index_id))
  log_tree(bWriteLog and "[chub] MailHandler.on_on_new_mail_notify, mail_info = ", mail_info)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_new_mail_notify(mail_type, subtype, sender_uid, mail_info, index_id)
end
function MailHandler.send_batch_fetch_friend_mail_req(list, num)
  log_tree(bWriteLog and "[chub] MailHandler.send_batch_fetch_friend_mail_req, list = ", list)
  NetManager.SendPkg(472158123, list, num)
end
function MailHandler.on_batch_fetch_friend_mail_rsp(list)
  if not list then
    return
  end
  log_tree(bWriteLog and "[chub] MailHandler.on_batch_fetch_friend_mail_rsp, list = ", list)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_batch_fetch_friend_mail_rsp(list)
end
function MailHandler.send_exec(long_str)
  log(bWriteLog and "send_exec " .. tostring(long_str))
  NetManager.SendPkg(801897474, long_str)
end
function MailHandler.on_echo(msg)
  log(bWriteLog and "on_echo " .. tostring(msg))
  EventSystem:postEvent(EVENTTYPE_GM, EVENTID_GM_ON_ECHO, msg)
  local logic_gm_wear = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_wear")
  if logic_gm_wear then
    logic_gm_wear.OnAddItem(msg)
  end
end
function MailHandler.send_on_query_mail_summary_v2(is_simplified, source)
  log(bWriteLog and "[chub]MailHandler.send_on_query_mail_summary_v2, source is " .. tostring(source))
  NetManager.SendPkg(1372154611, is_simplified, source)
end
function MailHandler.on_on_query_mail_summary_v2_res(mailslist)
  log(bWriteLog and "[chub]MailHandler.on_on_query_mail_summary_v2_res")
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_query_mail_summary_v2_res(mailslist)
end
function MailHandler.send_batch_fetch_all_mail_req(list, invoke_type)
  log_tree(bWriteLog and "[v_wllwu] MailHandler.send_batch_fetch_all_mail_req, list is:", list)
  NetManager.SendPkg(1934347914, list, invoke_type)
end
function MailHandler.on_batch_fetch_all_attach_res(result_reward_id_list, flag)
  log(bWriteLog and "[v_wllwu] MailHandler.on_batch_fetch_all_attach_res, flag is:" .. tostring(flag))
  log_tree(bWriteLog and "[v_wllwu] MailHandler.on_batch_fetch_all_attach_res, result_reward_id_list is:", result_reward_id_list)
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  if flag == MailMacro.Enum_BatchReceiveAttach_InvokeType.MiniTV then
    local OneClickReward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
    OneClickReward.HandleMailReward(result_reward_id_list)
  elseif flag == MailMacro.Enum_BatchReceiveAttach_InvokeType.Mail then
    local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
    logic_mail_proto.on_batch_fetch_all_attach_res(result_reward_id_list, flag)
  end
end
function MailHandler.on_report_result_mail_notify(report_info)
  log(bWriteLog and "MailHandler.on_report_result_mail_notify")
  log_tree(bWriteLog and "MailHandler.on_batch_fetch_all_attach_res, report_info is:", report_info)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REPORT_RESULT_MAIL, report_info)
end
return MailHandler