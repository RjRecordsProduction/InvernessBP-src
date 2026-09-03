local collect_badge_module = {}
function collect_badge_module:DefineAndResetData()
  self.SeasonLevelConfigCache = {}
  self.badgeAllowLightPermissionTime = nil
end
function collect_badge_module:CheckBadgeActivation(seasonLevel, uid, forceLight)
  local nUid = uid and tostring(uid) or DataMgr.roleData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(nUid)
  local collect_data = profile and profile.collect_data
  if not forceLight and not self:CheckCanLightBadge(nUid, collect_data) then
    return false
  end
  local cfg = self:GetCollectSeasonLevelConfig(seasonLevel)
  if not cfg then
    return false
  end
  return cfg.ShowSpecial
end
function collect_badge_module:GetCollectSeasonLevelConfig(seasonLevel)
  local cfg = self.SeasonLevelConfigCache[seasonLevel]
  if cfg == nil then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    cfg = collect_module:GetSplitTableDataByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id), "Level", seasonLevel)
    self.SeasonLevelConfigCache[seasonLevel] = cfg
  end
  return cfg
end
function collect_badge_module:SetBadgeAllowLit(overTime)
  self.badgeAllowLightPermissionTime = overTime
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if not overTime then
    return
  end
  if overTime >= serverTime then
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PRIVILEGE_DATA_REFRESH)
  end
end
function collect_badge_module:CheckCanLightBadge(uid, collect_data)
  if self:SpecialSeasonHandle() then
    return true
  end
  uid = tostring(uid)
  local overTime = self.badgeAllowLightPermissionTime
  if uid ~= DataMgr.roleData.uid then
    if not collect_data or not collect_data.collect_frame_priv then
      return false
    end
    overTime = collect_data.collect_frame_priv
  end
  if not overTime then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if overTime < serverTime then
    return false
  else
    return true
  end
end
function collect_badge_module:SpecialSeasonHandle()
  local needCheck = false
  local seasonId = DataMgr.season_id
  log(bWriteLog and "xcc current seasonId" .. tostring(seasonId))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    if seasonId == 36 then
      needCheck = true
    end
  elseif seasonId == 37 then
    needCheck = true
  end
  return needCheck
end
function collect_badge_module:GetNumIcon(level, dan, light)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local pathFormat = light and collect_cfg.C_Path_Format_Silver_Light or collect_cfg.C_Path_Format_Silver_Gray
  if 3 < dan then
    pathFormat = light and collect_cfg.C_Path_Format_Gold_Light or collect_cfg.C_Path_Format_Gold_Gray
  end
  local onePath, tenPath, hundredPath = "", "", ""
  local one = level % 10
  onePath = string.format(pathFormat, one, one)
  if 10 <= level then
    local ten = level % 100 // 10
    tenPath = string.format(pathFormat, ten, ten)
  end
  if 100 <= level then
    local hundred = level // 100
    hundredPath = string.format(pathFormat, hundred, hundred)
  end
  return onePath, tenPath, hundredPath
end
function collect_badge_module:GetHelmetIconPath(light)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  if light then
    return collect_cfg.C_Helmet_Icon_Light
  end
  return collect_cfg.C_Helmet_Icon_Gray
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_badge_module)
return CModuleTemplate