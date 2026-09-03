local logic_profile_get_wrap = {}
function logic_profile_get_wrap.GetFriendProfiles(moduleId, listUid, callback, needRefresh, refreshOnlineStatus, intTag)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  return logic_profile:send_batch_get_bin_profile_req(listUid, callback, needRefresh, true, nil, refreshOnlineStatus, moduleId, intTag or 0)
end
function logic_profile_get_wrap.GetNormalProfiles(listUid, callback, moduleId, infoTag, needRefresh)
  if not moduleId and not Client.IsShipping() then
    local utility = require("common.utility")
    utility.ErrorMessageHandler("ModuleId is request by GetNormalProfiles!!!")
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  return logic_profile:send_batch_get_bin_profile_req(listUid, callback, needRefresh, false, 0, false, moduleId, infoTag)
end
function logic_profile_get_wrap.GetRankProfiles(moduleId, listUid, callback)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  return logic_profile:send_batch_get_bin_profile_req(listUid, callback, true, false, 1, false, moduleId, 1)
end
return logic_profile_get_wrap