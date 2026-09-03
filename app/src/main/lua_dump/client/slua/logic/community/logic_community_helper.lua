local logic_community = require("client.slua.logic.community.logic_community_def")
local EClubStateValue = logic_community.EClubStateValue
function logic_community.CheckInClub(uid)
  local suid = tostring(uid)
  local state = logic_community.ClubMemberStatusCache[suid]
  if state == nil then
    return false
  end
  if state.stateValue == EClubStateValue.CHAT_STATE_OFFLINE then
    return false
  end
  return true
end
function logic_community.GetShowTextInClub(uid)
  local suid = tostring(uid)
  local state = logic_community.ClubMemberStatusCache[suid]
  log_tree("state", state)
  if state == nil then
    return LocUtil.GetLocalizeResStr(27550)
  end
  if state.stateValue == EClubStateValue.CHAT_STATE_OFFLINE then
    return LocUtil.GetLocalizeResStr(27550)
  elseif state.stateValue == EClubStateValue.CHAT_STATE_ONLINE then
    return LocUtil.GetLocalizeResStr(27551)
  elseif state.stateValue == EClubStateValue.CHAT_STATE_WATCH_LIVE then
    return LocUtil.GetLocalizeResStr(27552)
  end
  return LocUtil.GetLocalizeResStr(27550)
end
function logic_community.CheckShowInTeamUpSideBar(uid)
  if logic_community.GetShowEntry() == true and logic_community.CheckInClub(uid) then
    return true
  end
  return false
end
function logic_community.ParseCommunityParams(parms)
  if not parms or type(parms) ~= "table" or not next(parms) then
    return nil, nil
  end
  local game_scene
  local param_string = ""
  local first = true
  for k, v in pairs(parms) do
    if k == "game_scene" then
      game_scene = v
    else
      param_string = param_string .. (first and "" or "&") .. tostring(k) .. "=" .. Client.UrlEncode(tostring(v))
      first = false
    end
  end
  return param_string, game_scene
end