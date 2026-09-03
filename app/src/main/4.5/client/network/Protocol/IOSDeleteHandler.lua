local NetManager = require("client.network.comm.NetManager")
local IOSDeleteHandler = {}
function IOSDeleteHandler.send_ios_del_account_req()
  NetManager.SendPkg(1344131559)
end
function IOSDeleteHandler.on_ios_del_account_rsp(err_code)
  local LogicDeleteAccount = require("client.slua.logic.gdpr.logic_deleteaccount")
  LogicDeleteAccount.DeleteAccountRsp(err_code)
end
function IOSDeleteHandler.send_ios_cancle_del_account_req()
  NetManager.SendPkg(1041557767)
end
function IOSDeleteHandler.on_ios_cancle_del_account_rsp(err_code)
  local LogicDeleteAccount = require("client.slua.logic.gdpr.logic_deleteaccount")
  LogicDeleteAccount.CancelDeleteAccountRsp(err_code)
end
return IOSDeleteHandler