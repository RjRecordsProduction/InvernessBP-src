local NetManager = require("client.network.comm.NetManager")
local LoginHandler = {}
function LoginHandler.on_login_failed(conn_idx, reason, banInfo, banTime, uid, extra_table)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitLoginRsp)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_login_failed(conn_idx, reason, banInfo, banTime, uid, extra_table)
end
function LoginHandler.send_query_lobby_info(loginSystemLoginLobbyInfoVer)
  NetManager.SendPkg(1405487677, loginSystemLoginLobbyInfoVer)
end
function LoginHandler.on_sync_lobby_info(ret, addr, key, updateAtRuntime)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_sync_lobby_info(ret, addr, key, updateAtRuntime)
end
function LoginHandler.on_redirect(url)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_redirect(url)
end
function LoginHandler.on_kickout(msg, banInfo, banTime, localizeResID, op_type, sDeviceName, ext_info, login_channel, deviceInfo)
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bConnectDS = Lobby_Main_City_Enter.bConnectDS
  log(bWriteLog and "LoginHandler.on_kickout bConnectDS = " .. tostring(bConnectDS))
  if bConnectDS then
    Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
  end
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban_login_module:on_kickout(msg, banInfo, banTime, localizeResID, op_type, sDeviceName, ext_info, login_channel, deviceInfo)
end
function LoginHandler.send_logout(deviceOSInfoList)
  NetManager.SendPkg(423912716, deviceOSInfoList)
end
function LoginHandler.on_logout_rsp(msg)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_logout(msg)
end
function LoginHandler.on_notify_game_rest_remind(isAcc, reachTime)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_notify_game_rest_remind(isAcc, reachTime)
end
function LoginHandler.on_notify_game_rest_force(isAcc, reachTime, restTime)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_notify_game_rest_force(isAcc, reachTime, restTime)
end
function LoginHandler.on_notify_game_aas_ban(banEndTime)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_notify_game_aas_ban(banEndTime)
end
function LoginHandler.on_login_next(msg)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_login_next(msg)
end
function LoginHandler.send_login(ver, deviceOSInfoList, startup_type, ext_info, device_type, channelID, registerchannelID, currentTime, language, timezone, payPF, aosShopIndex, appVersion, tssVersion, clientGetAndroidBuildForArm, newloginFlag, subsideFeatureLevel, highestPufferPatch, fcmToken, versions)
  NetManager.SendPkg(1828975710, ver, deviceOSInfoList, startup_type, ext_info, device_type, channelID, registerchannelID, currentTime, language, timezone, payPF, aosShopIndex, appVersion, tssVersion, clientGetAndroidBuildForArm, newloginFlag, subsideFeatureLevel, highestPufferPatch, fcmToken, versions)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitLoginRsp)
end
function LoginHandler.on_login_rsp(ip_region, nation_switch, continent, commonSwitch, pingSvrPars, province)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitLoginRsp)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_login_rsp(ip_region, nation_switch, continent, commonSwitch, pingSvrPars, province)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitSyncBaseInfo)
end
function LoginHandler.on_send_last_logout_time(lastLogoutTime)
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  StarterPackSystem.SetLastLoginTime(lastLogoutTime)
end
function LoginHandler.send_get_fresher_info_req()
  NetManager.SendPkg(240135207)
end
function LoginHandler.on_get_fresher_info_rsp(fresher_info)
  BeginnerGuideSystem.on_get_fresher_info_rsp(fresher_info)
end
function LoginHandler.on_need_show_first_in_vietnam()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_need_show_first_in_vietnam()
end
function LoginHandler.send_set_vietnam_user_req()
  NetManager.SendPkg(237135783)
end
function LoginHandler.on_set_vietnam_user_rsp(res)
end
function LoginHandler.on_get_client_basic_cfg_rsp(configTbl)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:on_get_client_basic_cfg_rsp(configTbl)
end
function LoginHandler.send_competition_login(strLoginSystemNoAuthPassword)
  NetManager.SendPkg(1096641623, strLoginSystemNoAuthPassword)
end
function LoginHandler.on_competition_login_res(res)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:competition_login_res(res)
end
function LoginHandler.send_set_fresher_info_req(guide_id)
  NetManager.SendPkg(205207404, guide_id)
end
function LoginHandler.send_start_scan_qrcode_req(uuid, expire_days, sparams)
  NetManager.SendPkg(902068567, uuid, expire_days, sparams)
end
function LoginHandler.on_start_scan_qrcode_rsp(errcode, b_web_scan, device_name, expire_tm)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:on_start_scan_qrcode_rsp(errcode, b_web_scan, device_name, expire_tm)
end
function LoginHandler.send_qrcode_login_func_limit_req(limit_info)
  log(bWriteLog and "LoginHandler.send_qrcode_login_func_limit_req")
  NetManager.SendPkg(1662221415, limit_info)
end
function LoginHandler.on_qrcode_login_func_limit_rsp(err_code, limit_info)
  if err_code ~= 0 then
    if err_code == 100150049 then
      ShowNotice(200000087)
    else
      ShowNotice(err_code)
    end
  end
  log(bWriteLog and "LoginHandler.on_qrcode_login_func_limit_rsp")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:on_qrcode_login_func_limit_rsp(limit_info)
end
function LoginHandler.send_get_qrcode_login_data_req()
  log(bWriteLog and "LoginHandler.send_get_qrcode_login_data_req")
  NetManager.SendPkg(1506006923)
end
function LoginHandler.on_get_qrcode_login_data_rsp(err_code, can_scan_qrcode, qrcode_login_info, is_qrcode_login, client_qrcode_button_gray)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "LoginHandler.on_get_qrcode_login_data_rsp can_scan_qrcode = " .. tostring(can_scan_qrcode))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:on_get_qrcode_login_data_rsp(can_scan_qrcode, qrcode_login_info, client_qrcode_button_gray)
end
function LoginHandler.on_account_bind_info_change_notify(BindOperation)
  if type(BindOperation) == "table" and next(BindOperation) then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local datas = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountBindMsg)
    datas = datas or {}
    if next(datas) then
      local removeTab = {}
      for k, v in pairs(BindOperation) do
        local iOperationId = v.iOperationId
        if datas[iOperationId] then
          removeTab[k] = v
        else
          datas[iOperationId] = v
        end
      end
      if next(removeTab) then
        for k, v in pairs(removeTab) do
          BindOperation[k] = nil
        end
      end
    else
      for k, v in pairs(BindOperation) do
        local iOperationId = v.iOperationId
        datas[iOperationId] = v
      end
    end
    if next(BindOperation) then
      local time_ticker = require("common.time_ticker")
      LoginHandler.DelayPopups = time_ticker.AddTimerLoop(1, function()
        local curStatus = GameStatus.GetGameStatus()
        if GameStatus.IsInLobbyOrMainCity() then
          time_ticker.RemoveTimer(LoginHandler.DelayPopups)
          UIManager.ShowUI(UIManager.UI_Config.AccountBindingChangedPopup, BindOperation)
        end
      end, 10, 0.5)
    end
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(datas, PlayerPrefsSystem.ePlayerPrefsType.eAccountBindMsg)
  end
end
function LoginHandler.send_query_qrcode_grant_list_req(sparams)
  log(bWriteLog and "LoginHandler.send_query_qrcode_grant_list_req")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and string.format("LoginHandler.send_query_qrcode_grant_list_req return of BLUEHOLE region, region:%s", region))
    return
  end
  NetManager.SendPkg(766648687, sparams)
end
function LoginHandler.on_query_qrcode_grant_list_rsp(err, QrCodeInfo)
  log(bWriteLog and string.format("LoginHandler.on_query_qrcode_grant_list_rsp, err:%s", err))
  log_tree(bWriteLog and "LoginHandler.on_query_qrcode_grant_list_rsp QrCodeInfo", QrCodeInfo)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_qr_code = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_qr_code)
  logic_qr_code:on_query_qrcode_grant_list_rsp(QrCodeInfo)
end
function LoginHandler.send_delete_qrcode_token_req(qrcode_uuid, sparams)
  log(bWriteLog and string.format("LoginHandler.send_delete_qrcode_token_req, qrcode_uuid:%s", qrcode_uuid))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and string.format("LoginHandler.send_delete_qrcode_token_req return of BLUEHOLE region, region:%s", region))
    return
  end
  NetManager.SendPkg(1955303451, qrcode_uuid, sparams)
end
function LoginHandler.on_delete_qrcode_token_rsp(err, qrcode_uuid)
  log(bWriteLog and string.format("LoginHandler.on_delete_qrcode_token_rsp, err:%s", err))
  log(bWriteLog and string.format("LoginHandler.on_delete_qrcode_token_rsp, qrcode_uuid:%s", qrcode_uuid))
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
  local logic_qr_code = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_qr_code)
  logic_qr_code:on_delete_qrcode_token_rsp(qrcode_uuid)
end
function LoginHandler.send_check_online_req(device_id)
  NetManager.SendPkg(200953959, device_id)
end
function LoginHandler.on_check_online_rsp(err, status, rsp_data)
  log(bWriteLog and "  LoginHandler.on_check_online_rsp. err: " .. tostring(err))
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
end
function LoginHandler.send_get_two_step_download_reward_req(ver)
  printf("LoginHandler.send_get_two_step_download_reward_req. ver=%s", tostring(ver))
  NetManager.SendPkg(2100647160, ver)
end
function LoginHandler.send_get_web_login_code_req(sParams)
  NetManager.SendPkg(55694759, sParams)
end
function LoginHandler.on_get_web_login_code_rsp(err_code, url)
end
local reqRsp = {
  send_query_qrcode_grant_list_req = "on_query_qrcode_grant_list_rsp",
  send_delete_qrcode_token_req = "on_delete_qrcode_token_rsp",
  send_check_online_req = "on_check_online_rsp",
  send_get_web_login_code_req = "on_get_web_login_code_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, LoginHandler)
return LoginHandler