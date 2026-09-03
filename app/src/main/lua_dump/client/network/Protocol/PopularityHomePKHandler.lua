local NetManager = require("client.network.comm.NetManager")
local PopularityHomePKHandler = {
  bGMTest = false,
  GMState = 0,
  GMActTimeState = 0,
  err_manor_pk_is_ban = 13065018,
  err_manor_pk_not_signed = 13065014,
  err_manor_pk_not_duel = 13065004
}
function PopularityHomePKHandler.send_get_manor_pk_data_req()
  NetManager.SendPkg(494817687)
end
function PopularityHomePKHandler.on_get_manor_pk_data_rsp(err_code, ret_data)
  log(bWriteLog and "PopularityHomePKHandler.on_get_manor_pk_data_rsp, err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("PopularityHomePKHandler.on_get_manor_pk_data_rsp, ret_data = ", ret_data)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_get_manor_pk_data_rsp(ret_data)
end
function PopularityHomePKHandler.send_manor_pk_enroll_req()
  NetManager.SendPkg(2024609411)
end
function PopularityHomePKHandler.on_manor_pk_enroll_rsp(err_code, ret_data)
  log(bWriteLog and "PopularityHomePKHandler.on_manor_pk_enroll_rsp, err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    if err_code == 13065006 then
      local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
      local actCfg = logic_popular_home_pk:GetActConfig()
      if actCfg then
        local strTips = LocUtil.LocalizeResFormat(68004, actCfg.manor_prosperity)
        ShowNotice(strTips)
        return
      end
    end
    ShowNotice(err_code)
    return
  end
  log_tree("PopularityHomePKHandler.on_manor_pk_enroll_rsp, ret_data = ", ret_data)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_manor_pk_enroll_rsp(ret_data)
end
function PopularityHomePKHandler.send_get_manor_pk_detail_req(target_uid)
  log(bWriteLog and "PopularityHomePKHandler.send_get_manor_pk_detail_req, target_uid = " .. tostring(target_uid))
  NetManager.SendPkg(1600015291, target_uid)
end
function PopularityHomePKHandler.on_get_manor_pk_detail_rsp(err_code, target_uid, ret_pk_detail)
  log(bWriteLog and "PopularityHomePKHandler.on_get_manor_pk_detail_rsp err_code = " .. tostring(err_code) .. ", target_uid = " .. tostring(target_uid))
  log_tree("PopularityHomePKHandler.on_get_manor_pk_detail_rsp ret_pk_detail = ", ret_pk_detail)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  if err_code ~= 0 then
    if err_code == PopularityHomePKHandler.err_manor_pk_is_ban then
      logic_popular_home_pk:ClearPKData(target_uid)
    elseif err_code ~= PopularityHomePKHandler.err_manor_pk_not_signed and err_code ~= PopularityHomePKHandler.err_manor_pk_not_duel then
      ShowNotice(err_code)
    end
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_DATA_FAIL, target_uid)
    return
  end
  logic_popular_home_pk:on_get_manor_pk_detail_rsp(target_uid, ret_pk_detail)
end
function PopularityHomePKHandler.send_get_manor_pk_records_req(source)
  NetManager.SendPkg(1433838311, source)
end
function PopularityHomePKHandler.on_get_manor_pk_records_rsp(err_code, source, record_list)
  log(bWriteLog and "PopularityHomePKHandler.on_get_manor_pk_records_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(string.format("on_get_manor_pk_records_rsp source is: %d, record_list is ", source), record_list)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_get_manor_pk_records_rsp(source, record_list)
end
function PopularityHomePKHandler.send_manor_pk_receive_awards_req(level)
  NetManager.SendPkg(1609021443, level)
end
function PopularityHomePKHandler.on_manor_pk_receive_awards_rsp(err_code, level, pk_level_awards, items_list)
  log(bWriteLog and "PopularityHomePKHandler.on_manor_pk_receive_awards_rsp err_code = " .. tostring(err_code) .. ", level = " .. tostring(level))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("on_manor_pk_receive_awards_rsp pk_level_awards = ", pk_level_awards)
  log_tree("on_manor_pk_receive_awards_rsp items_list = ", items_list)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_manor_pk_receive_awards_rsp(level, pk_level_awards, items_list)
end
function PopularityHomePKHandler.send_get_manor_pk_push_info_req()
  NetManager.SendPkg(1196713159)
end
function PopularityHomePKHandler.on_get_manor_pk_push_info_rsp(err_code, push_cfg_list)
end
function PopularityHomePKHandler.on_manor_pk_vote_notify(ntf_info)
  log_tree("PopularityHomePKHandler.on_manor_pk_vote_notify ntf_info = ", ntf_info)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_manor_pk_vote_notify(ntf_info)
end
function PopularityHomePKHandler.send_batch_get_manor_pk_surface_url_req(uid_list)
  log_tree("PopularityHomePKHandler.send_batch_get_manor_pk_surface_url_req uid_list = ", uid_list)
  NetManager.SendPkg(1994583783, uid_list)
end
function PopularityHomePKHandler.on_batch_get_manor_pk_surface_url_rsp(err_code, ret_data_list, ret_thumbnail_data)
  log(bWriteLog and "PopularityHomePKHandler.on_batch_get_manor_pk_surface_url_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  ret_data_list = slua.LuaArchiverDecode(LuaStateWrapper, ret_data_list)
  log_tree("on_batch_get_manor_pk_surface_url_rsp, ret_data_list = ", ret_data_list)
  ret_thumbnail_data = slua.LuaArchiverDecode(LuaStateWrapper, ret_thumbnail_data)
  log_tree("on_batch_get_manor_pk_surface_url_rsp, ret_thumbnail_data = ", ret_thumbnail_data)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:ProcSurfaceUrlRsp(ret_data_list, ret_thumbnail_data)
end
function PopularityHomePKHandler.send_manor_scene_req(uid)
  log(bWriteLog and "PopularityHomePKHandler.send_manor_scene_req uid = " .. tostring(uid))
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_scene_req", uid)
end
function PopularityHomePKHandler.on_manor_scene_rsp(err_code, uid, scene)
  log(bWriteLog and "PopularityHomePKHandler.on_manor_scene_rsp err_code = " .. tostring(err_code) .. ", uid = " .. tostring(uid))
  scene = slua.LuaArchiverDecode(LuaStateWrapper, scene)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:ProcManorSceneRsp(err_code, uid, scene)
end
function PopularityHomePKHandler.send_manor_pk_recommend_req()
  NetManager.SendPkg(973174279)
end
function PopularityHomePKHandler.on_manor_pk_recommend_rsp(err, data_list)
  log(bWriteLog and "PopularityHomePKHandler.on_manor_pk_recommend_rsp err" .. tostring(err))
  log_tree("PopularityHomePKHandler.on_manor_pk_recommend_rsp ", data_list)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_manor_pk_recommend_rsp(err, data_list)
end
function PopularityHomePKHandler.send_get_manor_pk_info_by_uid_list_req(uid_list)
  NetManager.SendPkg(1155254647, uid_list)
end
function PopularityHomePKHandler.on_get_manor_pk_info_by_uid_list_rsp(err, results)
  log(bWriteLog and "PopularityHomePKHandler.on_get_manor_pk_info_by_uid_list_rsp err" .. tostring(err))
  log_tree("PopularityHomePKHandler.on_get_manor_pk_info_by_uid_list_rsp ", results)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:on_get_manor_pk_info_by_uid_list_rsp(err, results)
end
return PopularityHomePKHandler