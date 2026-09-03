local NetManager = require("client.network.comm.NetManager")
local PHomeHandler = {}
function PHomeHandler.ChangeGMRecordState()
  log(bWriteLog and "PHomeHandler.ChangeGMRecordState")
  if PHomeHandler._recordOpen then
    PHomeHandler._recordOpen = nil
    log_tree("PHomeHandler records manor_on_client_call_req:", PHomeHandler._records)
    return
  end
  PHomeHandler._records = {}
  PHomeHandler._recordOpen = true
  PHomeHandler._nowRecTime = 0
end
function PHomeHandler.RecordSendCall(msg)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetMiliseconds()
  PHomeHandler._records = PHomeHandler._records or {}
  if curTime - PHomeHandler._nowRecTime > 10000 then
    PHomeHandler._records[curTime] = {
      count = 1,
      msgs = {msg}
    }
    PHomeHandler._nowRecTime = PHomeHandler._nowRecTime == 0 and curTime or PHomeHandler._nowRecTime + 10000
  else
    PHomeHandler._records[PHomeHandler._nowRecTime] = PHomeHandler._records[PHomeHandler._nowRecTime] or {
      count = 0,
      msgs = {}
    }
    PHomeHandler._records[PHomeHandler._nowRecTime].count = PHomeHandler._records[PHomeHandler._nowRecTime].count + 1
    table.insert(PHomeHandler._records[PHomeHandler._nowRecTime].msgs, msg)
  end
end
function PHomeHandler.send_manor_on_client_call_req(msg, ...)
  log(bWriteLog and "PHomeHandler.send_manor_on_client_call_req msg = " .. msg)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen(true) then
    log(bWriteLog and "PHomeHandler.send_manor_on_client_call_req switch not open")
    return
  end
  if logic_home_switch:CheckHomeLimit(false) then
    log(bWriteLog and "PHomeHandler.send_manor_on_client_call_req limit")
    return
  end
  NetManager.SendPkg(1828043943, msg, ...)
  if not PHomeHandler._recordOpen then
    return
  end
  PHomeHandler.RecordSendCall(msg)
end
function PHomeHandler.on_manor_on_client_call_rsp(msg, err)
  log(bWriteLog and "PHomeHandler.on_manor_on_client_call_rsp msg = " .. msg)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
end
function PHomeHandler.send_manor_encrypt_module_data_req(manor_owner_uid, module_id)
  NetManager.SendPkg(1346261623, manor_owner_uid, module_id)
end
function PHomeHandler.on_manor_encrypt_module_data_rsp(err_code, manor_owner_uid, module_id, str_encrypt_module)
  log(bWriteLog and "PHomeHandler.on_manor_encrypt_module_data_rsp module_id = " .. tostring(module_id) .. ", str_encrypt_module = " .. tostring(str_encrypt_module))
  if err_code ~= 0 then
    print(bWriteLog and "[DeanJYT] PHomeHandler.on_manor_encrypt_module_data_rsp err_code = " .. tostring(err_code))
    return
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_owner_id = logic_home_entry:GetManorOwnerId()
  local manor_key = logic_home_entry:GetManorKey()
  if manor_owner_id ~= manor_owner_uid and manor_owner_uid ~= manor_key then
    print(bWriteLog and "[DeanJYT] PHomeHandler.on_manor_encrypt_module_data_rsp not in correct manor, manor_owner_uid = " .. tostring(manor_owner_uid) .. ", current manor owner uid = " .. tostring(manor_owner_id) .. ", manor_key = " .. tostring(manor_key))
    return
  end
  local PlanPH_BackendDataRoute_Client_Handler = require("GameLua.Mod.PlanPH.Client.Handler.PlanPH_BackendDataRoute_Client_Handler")
  PlanPH_BackendDataRoute_Client_Handler.send_pass_backend_encrypt_module_data_req(str_encrypt_module)
end
return PHomeHandler