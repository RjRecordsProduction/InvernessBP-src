local FriendsListItem_BP = require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Data")
function FriendsListItem_BP:RequestProfile(UID, index)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  log(bWriteLog and "teamup_side_bar:RequestProfile profile " .. UID)
  if logic_friend_list_ui:HasReqProfile(UID) then
    return
  else
    logic_friend_list_ui:ClearProfileReqMap()
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local datas = logic_friend_list_ui:GetFriendList()
  local profileReqList = {}
  local profile_config = require("client.slua.logic.user.profile.profile_config")
  local maxIndex = math.min(index + profile_config.ENUM_REQ_SIZE.WITH_RANK, #datas)
  for i = index, maxIndex do
    local v = datas[i].uid
    if not logic_profile:GetLocalProfile() then
      logic_friend_list_ui:SetReqProfile(v)
      table.insert(profileReqList, v)
    end
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local _myselfOnIsland = MatchModeMgrSystem.IsSocialIslandMode()
  local _tag = _myselfOnIsland and Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_FRIEND_SIDE_BAR or Enum_PROFILE_REPORT_CFG.FRIEND_LIST
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  logic_profile_get_wrap.GetNormalProfiles(profileReqList, LogicTeamUpSideBar.OnProfileResponse, _tag)
end