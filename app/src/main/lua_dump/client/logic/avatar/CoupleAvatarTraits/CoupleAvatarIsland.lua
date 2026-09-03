local CoupleAvatarIsland = {}
function CoupleAvatarIsland:ReqSocialIslandStatus(uid)
  log(bWriteLog and "ReqSocialIslandStatus:" .. tostring(uid))
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not (profile and profile.frd_status_id) or profile.frd_status_id <= 0 then
    log(bWriteLog and "CoupleAvatarIsland:ReqSocialIslandStatus profile or status empty")
  else
    local cfg = CDataTable.GetTableData("FriendStatusCfg", profile.frd_status_id)
    if cfg and cfg.type == 7 then
      log(bWriteLog and "CoupleAvatarIsland:ReqSocialIslandStatus friend is hiding")
      self:HideIslandStatus()
      return
    end
  end
  if tostring(DataMgr.roleData.uid) == tostring(uid) then
    log(bWriteLog and "ReqSocialIslandStatus is same")
    self:HideIslandStatus()
    return
  end
  self.IslandStatusUID = tonumber(uid)
  if self.islandStatus[self.IslandStatusUID] then
    self:CheckIslandStatus(self.IslandStatusUID, self.socialLandType[self.IslandStatusUID])
  else
    local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
    logic_island_status:get_socialland_status_req(self.IslandStatusUID)
  end
end
function CoupleAvatarIsland:GetTargetIslandStatusRsp(_, _, target_uid, result)
  log(bWriteLog and "GetTargetIslandStatusRsp target_uid:" .. tostring(target_uid))
  log_tree("GetTargetIslandStatusRsp result", result)
  if self.IslandStatusUID == target_uid then
    local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
    self.islandStatus[target_uid] = logic_island_status:CheckIslandStatus(result.socialland_type, result.game_id, result.land_id)
    self.socialLandType[target_uid] = result.socialland_type
    self:CheckIslandStatus(target_uid, result.socialland_type)
  end
end
function CoupleAvatarIsland:CheckIslandStatus(target_uid, socialland_type)
  local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
  if self.islandStatus[target_uid] ~= logic_island_status.ENUM_ISLAND_STATUS.TARGET_ON_ISLAND then
    return
  end
  local timerID
  timerID = self:AddTimerLoop(0, function()
    if self.avatars[1] == nil then
      return
    end
    local ui = UIManager.GetUI(UIManager.UI_Config.avatar_social_island_status)
    if not ui then
      local social_name
      if socialland_type == 1 then
        social_name = LocUtil.GetLocalizeResStr("9561")
      elseif socialland_type == 2 then
        social_name = LocUtil.GetLocalizeResStr("9563")
      end
      ui = UIManager.ShowUI(UIManager.UI_Config.avatar_social_island_status, target_uid, social_name)
    else
      ui:RefreshPos()
    end
    self:RemoveTimer(timerID)
  end, TIMER_INFINITE, 0.1)
end
function CoupleAvatarIsland:HideIslandStatus()
  log(bWriteLog and "CoupleAvatarIsland.HideIslandStatus")
  self.IslandStatusUID = 0
  self.islandStatus = {}
  self.socialLandType = {}
  UIManager.CloseUI(UIManager.UI_Config.avatar_social_island_status)
end
local Trait = require("common.trait")
local TCoupleAvatarIsland = Trait(Trait.TraitPrototype, nil, CoupleAvatarIsland)
return TCoupleAvatarIsland