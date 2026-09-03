local SocialReddotSystem = {}
function SocialReddotSystem.HaveBaseInfoReddot(uid)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  if not LobbySocialSystem.IsSelf(uid) then
    return false
  end
  local hasReddot = false
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  hasReddot = RoleInfoAvatarSystem.HaveNewHeadportrait()
  if not hasReddot then
    local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
    hasReddot = RoleInfoAvatarFrameSystem.HaveNew()
  end
  if not hasReddot then
    local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
    hasReddot = RoleInfoAliasSystem.hasRedpoint()
  end
  if not hasReddot then
    local RoleInfoNameFrameSystem = require("client.slua.logic.person_space.logic_roleinfo_nameframe")
    hasReddot = RoleInfoNameFrameSystem.HaveNew()
  end
  if not hasReddot then
    local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
    hasReddot = logic_roleInfo_TeamUpFrame:HaveNew()
  end
  if not hasReddot then
    local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
    hasReddot = logic_roleinfo_carte_frame:HaveRed()
  end
  if not hasReddot then
    local logic_home_door_plate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_door_plate)
    hasReddot = logic_home_door_plate:HaveNew()
  end
  return hasReddot
end
function SocialReddotSystem.HaveRelationReddot()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  return PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) or PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) or PersonSpaceSystem.HasIntimacyCanGetRewardReddot() or PersonSpaceSystem.HasCohabitReddot()
end
function SocialReddotSystem.HaveAllianceReddot(uid)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  if not LobbySocialSystem.IsSelf(uid) then
    return false
  end
  return false
end
function SocialReddotSystem.HavePopularityReddot(uid)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  if not LobbySocialSystem.IsSelf(uid) then
    return false
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local isShowReddot = RoleInfoPopularitySystem.IsShowReddot or RoleInfoPopularitySystem.IsShowMsgReddot or RoleInfoPopularitySystem.IsShowMyGuardReddot
  return isShowReddot
end
function SocialReddotSystem.HavePhotoReddot(uid)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  if not LobbySocialSystem.IsSelf(uid) then
    return false
  end
  local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SOCIAL_LOBBY, LobbySocialSystem.SOCIAL_PHOTO_TIPS)
  return bNewbie
end
return SocialReddotSystem