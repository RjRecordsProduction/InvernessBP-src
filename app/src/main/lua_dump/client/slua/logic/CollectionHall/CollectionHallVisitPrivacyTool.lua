local CollectionHallVisitPrivacyTool = {
  Enum_Privacy = {
    Public = 0,
    Private = 1,
    Friend = 2
  }
}
function CollectionHallVisitPrivacyTool.GetVisitPrivacy(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile and profile.collect_hall_visit_privacy then
    return profile.collect_hall_visit_privacy
  else
    return 0
  end
end
function CollectionHallVisitPrivacyTool.GetVisitPrivacyAsync(uid, callback, moduleId)
  if not uid then
    log(bWriteLog and "CollectionHallVisitPrivacyTool.GetVisitPrivacyAsync - uid is nil")
    if callback then
      callback(0, nil)
    end
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    local privacy = profile.collect_hall_visit_privacy or 0
    if callback then
      callback(privacy, profile)
    end
    return
  end
  log(bWriteLog and string.format("CollectionHallVisitPrivacyTool.GetVisitPrivacyAsync - cache miss, request remote data for uid: %s", tostring(uid)))
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function(profileList)
    local fetchedProfile
    if profileList and 0 < #profileList then
      fetchedProfile = profileList[1]
    end
    local privacy = 0
    if fetchedProfile and fetchedProfile.collect_hall_visit_privacy then
      privacy = fetchedProfile.collect_hall_visit_privacy
    end
    if callback then
      callback(privacy, fetchedProfile)
    end
  end, moduleId or 0, 0, true)
end
function CollectionHallVisitPrivacyTool.GetPlayerVisitPrivacy()
  local uid = DataMgr.roleData.uid
  return CollectionHallVisitPrivacyTool.GetVisitPrivacy(uid)
end
function CollectionHallVisitPrivacyTool.OnVisitPrivacyChange(value)
  log(bWriteLog and string.format("[114514] CollectionHallVisitPrivacyTool.OnVisitPrivacyChange"))
  local uid = DataMgr.roleData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  profile.collect_hall_visit_privacy = value
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_COLLECTIONHALL_VISIT_PRIVACY_CHANGE)
end
return CollectionHallVisitPrivacyTool