local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
function Lobby_InviteFriend_BP:ReqRecentData()
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local reqRes = logic_friend_interact_record:send_get_not_fir_interaction_req()
  if not reqRes then
    self:CheckMemberStatus()
  end
end
function Lobby_InviteFriend_BP:RequestUpdateFriendReserveData()
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:GetHistoryReserveInfoReq()
end
function Lobby_InviteFriend_BP:OnRecentReqResponse()
  log(bWriteLog and "teamup_side_bar:OnRecentReqResponse")
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.OnRecentReqResponse()
  self:RefreshOnlineRecentNumber()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  if tabID == FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
    self:SetOneTabData(true)
  end
  self:CheckMemberStatus()
end
function Lobby_InviteFriend_BP:CheckMemberStatus()
  local batchReqIDList = {}
  local batchReqIDMap = {}
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local allData = LogicTeamUpSideBar.GetRecent() or {}
  for i, v in pairs(allData) do
    if not PlayerStatusMgr:GetStatusData(v.uid) and not batchReqIDMap[v.uid] then
      table.insert(batchReqIDList, v.uid)
      batchReqIDMap[v.uid] = true
    end
  end
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  allData = LBSFriendMgr:GetNearFriendList() or {}
  for k, v in pairs(allData) do
    if not PlayerStatusMgr:GetStatusData(v.uid) and not batchReqIDMap[v.uid] then
      table.insert(batchReqIDList, v.uid)
      batchReqIDMap[v.uid] = true
    end
  end
  if 0 < #batchReqIDList then
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.AddFriend, batchReqIDList, function(infos)
    end)
  end
end