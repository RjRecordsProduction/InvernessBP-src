local logic_island_status = {
  myGameId = 0,
  myLandId = 0,
  ENUM_ISLAND_STATUS = {
    NONE_ON_ISLAND = 1,
    ME_ON_ISLAND = 2,
    TARGET_ON_ISLAND = 4,
    ON_DIFFERENT_ISLAND = 5,
    ON_SAME_ISLAND = 6
  }
}
function logic_island_status:CheckIslandStatus(target_socialland_type, target_game_id, target_land_id)
  log(bWriteLog and string.format(" logic_island_status:CheckIslandStatus target_socialland_type:%s, target_game_id:%s, target_land_id:%s", target_socialland_type, target_game_id, target_land_id))
  log(bWriteLog and string.format(" logic_island_status:CheckIslandStatus myGameId:%s, myLandId:%s", self.myGameId, self.myLandId))
  target_socialland_type = target_socialland_type or 0
  target_game_id = target_game_id or 0
  target_land_id = target_land_id or 0
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local myselfOnIsland = MatchModeMgrSystem.IsSocialIslandMode()
  log(bWriteLog and "CheckIslandStatus myselfOnIsland:" .. tostring(myselfOnIsland))
  if myselfOnIsland then
    if target_socialland_type == 0 then
      return self.ENUM_ISLAND_STATUS.ME_ON_ISLAND
    elseif self.myGameId == target_game_id and self.myLandId == target_land_id then
      return self.ENUM_ISLAND_STATUS.ON_SAME_ISLAND
    else
      return self.ENUM_ISLAND_STATUS.ON_DIFFERENT_ISLAND
    end
  elseif target_socialland_type == 0 then
    return self.ENUM_ISLAND_STATUS.NONE_ON_ISLAND
  else
    return self.ENUM_ISLAND_STATUS.TARGET_ON_ISLAND
  end
end
function logic_island_status:get_socialland_status_req(target_uid)
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  SocialIslandHandler.send_get_socialland_status_req(tonumber(target_uid))
end
function logic_island_status:on_get_socialland_status_rsp(res, target_uid, result)
  log_tree("logic_island_status:on_get_socialland_status_rsp", result)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_TARGET_ISLAND_STATUS_RES, target_uid, result)
end
function logic_island_status:SetMyLandData(land_id, game_id)
  log(bWriteLog and string.format(" logic_island_status:SetMyLandData land_id:%s, game_id:%s", land_id, game_id))
  self.myLandId = land_id
  self.myGameId = game_id
end
return logic_island_status