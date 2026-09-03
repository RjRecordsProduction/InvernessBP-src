local NetManager = require("client.network.comm.NetManager")
local AOSDeleteHandler = {}
function AOSDeleteHandler.send_aos_del_account_req()
  NetManager.SendPkg(169082903)
end
function AOSDeleteHandler.on_aos_del_account_rsp(err_code)
  local LogicDeleteAccount = require("client.slua.logic.gdpr.logic_deleteaccount")
  LogicDeleteAccount.AOSDeleteAccountRsp(err_code)
end
function AOSDeleteHandler.send_aos_cancle_del_account_req()
  NetManager.SendPkg(1149773831)
end
function AOSDeleteHandler.on_aos_cancle_del_account_rsp(err_code)
  local LogicDeleteAccount = require("client.slua.logic.gdpr.logic_deleteaccount")
  LogicDeleteAccount.AOSCancelDeleteAccountRsp(err_code)
end
return AOSDeleteHandler