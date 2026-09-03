local NetManager = require("client.network.comm.NetManager")
local WarmUpGroupHandler = {
  PreTeamErrorCodeMap = {
    [200000100] = 88011,
    [200000101] = 88012,
    [200000102] = 88013,
    [200000103] = 88014,
    [200000104] = 88015,
    [200000105] = 88016,
    [200000106] = 88017,
    [200000107] = 88018,
    [200000108] = 88019,
    [200000109] = 88020,
    [200000111] = 88021,
    [200000112] = 88022,
    [200000113] = 88023,
    [200000114] = 88024,
    [200000115] = 88025,
    [200000116] = 88026,
    [200000117] = 88027,
    [200000118] = 88030
  }
}
function WarmUpGroupHandler.CheckErrorCodeMapping(errCode)
  if WarmUpGroupHandler.PreTeamErrorCodeMap[errCode] ~= nil then
    ShowNotice(WarmUpGroupHandler.PreTeamErrorCodeMap[errCode])
    return true
  end
end
function WarmUpGroupHandler.send_pre_team_act_query_team_info(bGetDataSilent)
  WarmUpGroupHandler.  NetManager.SendPkg(62992652)
end
function WarmUpGroupHandler.on_pre_team_act_query_team_info_rsp(err_code, data)
  if not WarmUpGroupHandler.bGetDataSilent and WarmUpGroupHandler.CheckErrorCodeMapping(err_code) then
    return true
  end
  if err_code ~= 0 then
    if not WarmUpGroupHandler.bGetDataSilent then
      ShowNotice(LocUtil.LocalizeResFormat(79221, err_code))
    else
      log_error("WarmUpGroupHandler error_code" .. tostring(err_code))
    end
    return true
  end
  local Logic_Warm_Up_Group = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.Logic_Warm_Up_Group)
  Logic_Warm_Up_Group:ResponseGetActData(data)
end
function WarmUpGroupHandler.send_pre_team_act_create_team()
  NetManager.SendPkg(1945201548)
end
function WarmUpGroupHandler.on_pre_team_act_create_team_rsp(err_code, data)
  if WarmUpGroupHandler.CheckErrorCodeMapping(err_code) then
    return true
  end
  if err_code ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(79221, err_code))
    return true
  end
  local Logic_Warm_Up_Group = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.Logic_Warm_Up_Group)
  Logic_Warm_Up_Group:ResponseCreateTeam(data)
end
function WarmUpGroupHandler.send_pre_team_act_invite_join(target_uid)
  NetManager.SendPkg(394812812, target_uid)
end
function WarmUpGroupHandler.on_pre_team_act_invite_join_rsp(err_code, team_id, uid)
  if WarmUpGroupHandler.CheckErrorCodeMapping(err_code) then
    return true
  end
  if err_code ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(79221, err_code))
    return true
  end
  local Logic_Warm_Up_Group = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.Logic_Warm_Up_Group)
  Logic_Warm_Up_Group:ResponseInviteToJoinTeam({team_id = team_id, uid = uid})
end
function WarmUpGroupHandler.send_pre_team_act_join_team(team_id)
  NetManager.SendPkg(190127340, team_id)
end
function WarmUpGroupHandler.on_pre_team_act_join_team_rsp(err_code, data)
  if WarmUpGroupHandler.CheckErrorCodeMapping(err_code) then
    return true
  end
  if err_code ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(79221, err_code))
    return true
  end
  local Logic_Warm_Up_Group = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.Logic_Warm_Up_Group)
  Logic_Warm_Up_Group:ResponseJoinTeam(data)
end
function WarmUpGroupHandler.send_pre_team_act_get_reward(member_count)
  NetManager.SendPkg(1934596886, member_count)
end
function WarmUpGroupHandler.on_pre_team_act_get_reward_rsp(err_code, data)
  if WarmUpGroupHandler.CheckErrorCodeMapping(err_code) then
    return true
  end
  if err_code ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(79221, err_code))
    return true
  end
  local Logic_Warm_Up_Group = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.Logic_Warm_Up_Group)
  Logic_Warm_Up_Group:ResponseGetReward(data)
end
function WarmUpGroupHandler.send_pre_team_act_get_friend_teams(team_ids)
  NetManager.SendPkg(2007057542, team_ids)
end
function WarmUpGroupHandler.on_pre_team_act_get_friend_teams_rsp(err_code, data)
  if WarmUpGroupHandler.CheckErrorCodeMapping(err_code) then
    return true
  end
  if err_code ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(79221, err_code))
    return true
  end
  local Logic_Warm_Up_Group = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.Logic_Warm_Up_Group)
  Logic_Warm_Up_Group:ResponseGetFriendTeam(data)
end
local reqRsp = {
  send_pre_team_act_query_team_info = "on_pre_team_act_query_team_info_rsp",
  send_pre_team_act_create_team = "on_pre_team_act_create_team_rsp",
  send_pre_team_act_invite_join = "on_pre_team_act_invite_join_rsp",
  send_pre_team_act_join_team = "on_pre_team_act_join_team_rsp",
  send_pre_team_act_get_reward = "on_pre_team_act_get_reward_rsp",
  send_pre_team_act_get_friend_teams = "on_pre_team_act_get_friend_teams_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, WarmUpGroupHandler)
return WarmUpGroupHandler