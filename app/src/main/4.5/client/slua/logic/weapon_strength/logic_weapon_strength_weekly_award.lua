local rank_data = require("client.slua.logic.rank.rank_data")
local logic_weapon_strength_weekly_award = {}
function logic_weapon_strength_weekly_award:DefineAndResetData()
  self.last_weapon_power_rank_reward_data = nil
  self.reward_data = nil
  self.bFake = false
end
function logic_weapon_strength_weekly_award:OnInitialize()
  log(bWriteLog and "logic_weapon_strength_weekly_award:OnInitialize")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(tonumber(DataMgr.roleData.uid))
  if profile and profile.weapon_power_data and profile.weapon_power_data.last_weapon_power_rank_reward_data then
    log_tree(bWriteLog and "logic_weapon_strength_weekly_award:OnInitialize profile.weapon_power_data", profile.weapon_power_data)
    self.last_weapon_power_rank_reward_data = profile.weapon_power_data.last_weapon_power_rank_reward_data
  end
end
function logic_weapon_strength_weekly_award:RegistEvents()
end
function logic_weapon_strength_weekly_award:GetRewardData()
  log(bWriteLog and "logic_weapon_strength_weekly_award:GetRewardData")
  log_tree(bWriteLog and "logic_weapon_strength_weekly_award:GetRewardData self.reward_data", self.reward_data)
  if self.reward_data == nil then
    log(bWriteLog and "logic_weapon_strength_weekly_award:GetRewardData data is nil")
    return nil
  end
  local res = {}
  local rank_config = CDataTable.GetTable("WeaponStrengthWeapon")
  local reward_data = self.reward_data
  for zone_id, rank_id2data in pairs(reward_data) do
    for rank_id, v in pairs(rank_id2data.zone_rank_reward) do
      local data = {}
      local logic_weaponstrength_tool = require("client.slua.umg.Season_WeaponStrength.logic_weaponstrength_tool")
      local parsed_rank_id = logic_weaponstrength_tool.ParseRankId(rank_id)
      data.weapon_id = rank_config[parsed_rank_id.weapon_rank_id].WeaponID
      data.      if parsed_rank_id.country_zone_id ~= -1 then
        data.zone_id = parsed_rank_id.country_zone_id
      end
      data.no = v.rank_no
      local alias_id
      local logic_weapon_strength = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength)
      local weapon_rank_cfg = logic_weapon_strength:GetWeaponRankConfigByWeaponID(data.weapon_id)
      alias_id = weapon_rank_cfg.GlobalAliasID
      if logic_weaponstrength_tool.IsRegion(data.zone_id) then
        alias_id = weapon_rank_cfg.ZoneAliasID
      elseif logic_weaponstrength_tool.IsCountry(data.zone_id) then
        alias_id = weapon_rank_cfg.CountryAliasID
      end
      if alias_id == nil then
        log(bWriteLog and "logic_weapon_strength_weekly_award:GetRewardData wrong data")
        log_tree(bWriteLog and "logic_weapon_strength_weekly_award:GetRewardData reward_data", self.reward_data)
        return {}
      end
      data.      data.power_count = v.power_count
      table.insert(res, data)
    end
  end
  return res
end
function logic_weapon_strength_weekly_award:SavePlayerPrefs()
  if self.bFake then
    log(bWriteLog and "logic_weapon_strength_weekly_award:SavePlayerPrefs bFake == true")
    return
  end
  if self.reward_data == nil then
    return
  end
  self.reward_data = nil
  local TimeUtil = require("client.common.time_util")
  local server_time = TimeUtil.GetServerTimeInSec()
  local save_data = {last_reward_get_time = server_time}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eWeaponStrengthWeeklyRewardPopup)
end
function logic_weapon_strength_weekly_award:CanJump()
  if self.bFake then
    log(bWriteLog and "logic_weapon_strength_weekly_award:CanJump bFake == true")
    return true
  end
  if self.reward_data == nil then
    log(bWriteLog and "logic_weapon_strength_weekly_award:CanJump reward_data == nil")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Season_WeekResult_ShareInterface_UIBP) then
    log(bWriteLog and "logic_weapon_strength_weekly_award:CanJump Season_WeekResult_ShareInterface_UIBP has show")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWeaponStrengthWeeklyRewardPopup) or {}
  if save_data.last_reward_get_time then
    local TimeUtil = require("client.common.time_util")
    local server_time = TimeUtil.GetServerTimeInSec()
    if TimeUtil.IsSameWeek(tonumber(save_data.last_reward_get_time), server_time) then
      log(bWriteLog and string.format("logic_weapon_strength_weekly_award:CanJump last_reward_get_time = %s, server_time = %s", tostring(save_data.last_reward_get_time), tostring(server_time)))
      return false
    end
  end
  return true
end
function logic_weapon_strength_weekly_award:send_get_last_weapon_power_rank_reward_req()
  log(bWriteLog and "logic_weapon_strength_weekly_award:send_get_last_weapon_power_rank_reward_req")
  if self.bFake then
    log(bWriteLog and "logic_weapon_strength_weekly_award:send_get_last_weapon_power_rank_reward_req bFake == true")
    return
  end
  local WeaponStrengthHandler = require("client.network.Protocol.WeaponStrengthHandler")
  WeaponStrengthHandler.send_get_last_weapon_power_rank_reward_req()
end
function logic_weapon_strength_weekly_award:proc_get_last_weapon_power_rank_reward_rsp(reward_data)
  log(bWriteLog and "logic_weapon_strength_weekly_award:proc_get_last_weapon_power_rank_reward_rsp")
  if reward_data and next(reward_data) then
    self.  end
  EventSystem:postEvent(EVENTTYPE_WEAPONSTRENGTH, EVENTID_SEASON_WEAPONSTRENGTH_WEEKLY_AWARD)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_weapon_strength_weekly_award = class(CModuleBase, nil, logic_weapon_strength_weekly_award)
return Clogic_weapon_strength_weekly_award