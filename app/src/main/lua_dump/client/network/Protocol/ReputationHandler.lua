local NetManager = require("client.network.comm.NetManager")
local ReputationHandler = {}
function ReputationHandler.send_get_credit_info_v2_req()
  NetManager.SendPkg(542226375)
end
function ReputationHandler.on_get_credit_info_v2_rsp(credit_info, credit_level_table)
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  logic_reputation_system:OnGetCreditInfo(credit_info, credit_level_table)
end
function ReputationHandler.send_get_credit_conf_v2_req()
  NetManager.SendPkg(137611527)
end
function ReputationHandler.on_get_credit_conf_v2_rsp(credit_level_table)
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  logic_reputation_system:OnGetParamTab(credit_level_table)
end
function ReputationHandler.on_notify_credit_info_v2(credit_info)
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  logic_reputation_system:OnNotifyCreditInfo(credit_info)
end
function ReputationHandler.on_notify_show_notice()
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  logic_reputation_system:OnNotifyShowNotice()
end
function ReputationHandler.send_accept_credit_pact()
  NetManager.SendPkg(1304599091)
end
function ReputationHandler.on_notify_credit_punish_type_is_open(tParam)
  if not tParam then
    return
  end
  tParam = tParam[1]
  if not tParam then
    return
  end
  local ClientInGameCreditLogic = require("GameLua.Mod.BaseMod.Client.Security.Credit.ClientInGameCreditLogic")
  if tonumber(tParam.punish_type) == 1014 then
    ClientInGameCreditLogic.SetFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled(tonumber(tParam.is_open) == 1, tParam.sub_score_mode_list, tonumber(tParam.is_punish_limit) == 1)
  end
end
function ReputationHandler.send_credit_punish_return_lobby_user_reaction(nModeID, nSubModeID, nBattleID, bIsReturnLobby, is_punish_limit)
  NetManager.SendPkg(2065322091, nModeID, nSubModeID, nBattleID, bIsReturnLobby, is_punish_limit)
end
return ReputationHandler