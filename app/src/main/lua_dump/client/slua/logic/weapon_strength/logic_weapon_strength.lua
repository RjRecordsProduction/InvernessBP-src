local logic_weapon_strength = {}
function logic_weapon_strength:ctor()
  self.weapon_power_data_fake = nil
  self.weapon_type_config = nil
  self.weapon_rank_config = nil
  self.weapon_id_to_rank_config = nil
  self.weapon_history_segment_data = {}
  self.lastSendWeaponId = 0
  self.bIsfake = false
end
function logic_weapon_strength:RegistEvents()
end
function logic_weapon_strength:send_get_weapon_power_data_req()
  log(bWriteLog and "logic_weapon_strength:send_get_weapon_power_data_req")
  local WeaponStrengthHandler = require("client.network.Protocol.WeaponStrengthHandler")
  WeaponStrengthHandler.send_get_weapon_power_data_req()
end
function logic_weapon_strength:proc_get_weapon_power_data_rsp(cur_weapon_power_data, history_weapon_power_data)
  log(bWriteLog and "logic_weapon_strength:proc_get_weapon_power_data_rsp ")
  log_tree("logic_weapon_strength:cur_weapon_power_data", cur_weapon_power_data)
  log_tree("logic_weapon_strength:history_weapon_power_data", history_weapon_power_data)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(tonumber(DataMgr.roleData.uid))
  if profile then
    profile.weapon_power_data.cur_weapon_power_table = cur_weapon_power_data
    local newHistoryTable = {}
    for k, v in pairs(history_weapon_power_data) do
      if v.power_count ~= 0 then
        newHistoryTable[k] = v
      end
    end
    profile.weapon_power_data.history_weapon_power_table = newHistoryTable
  end
  EventSystem:postEvent(EVENTTYPE_WEAPONSTRENGTH, EVENTID_SEASON_WEAPONSTRENGTH_DATA_RSP)
end
function logic_weapon_strength:send_get_weapon_history_segment_data_req(weapon_id)
  log(bWriteLog and "logic_weapon_strength:send_get_weapon_history_segment_data_req")
  local WeaponStrengthHandler = require("client.network.Protocol.WeaponStrengthHandler")
  WeaponStrengthHandler.send_get_weapon_history_segment_data_req(weapon_id)
  self.lastSendWeaponId = weapon_id
end
function logic_weapon_strength:proc_get_weapon_history_segment_data_rsp(record)
  log(bWriteLog and "logic_weapon_strength:proc_get_weapon_history_segment_data_rsp")
  log_tree("logic_weapon_strength:history_segment_data", record)
  if record and next(record) then
    for k, v in pairs(record) do
      if self.lastSendWeaponId > 0 then
        self.weapon_history_segment_data[self.lastSendWeaponId] = record
      end
    end
    EventSystem:postEvent(EVENTTYPE_WEAPONSTRENGTH, EVENTID_WEAPONSTRENGTH_HISTORY_SEGEMENT_DATA, record)
  else
    log(bWriteLog and "logic_weapon_strength:proc_get_weapon_history_segment_data_rsp record is nil")
  end
end
function logic_weapon_strength:CheckIsOpenWeaponStrength()
  if self.bIsfake then
    log(bWriteLog and "logic_weapon_strength:CheckIsOpenWeaponStrength bIsfake == true")
    return true
  end
  local bSeason = DataMgr.season_id >= 45
  local Region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Region == PublishRegionMacros.BLUEHOLE then
    bSeason = DataMgr.season_id >= 44
  end
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_WEAPON_USAGE_SCORE_SWITCH)
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local openVersion = "4.0.0.00000"
  local bVersion = version_util.CompareVersionStandard(curVersion, openVersion) >= 0
  local bSeasonTime = false
  local season_cfg = CDataTable.GetTableData("SeasonInfo", DataMgr.season_id)
  if season_cfg then
    local TimeUtil = require("client.common.time_util")
    bSeasonTime = TimeUtil.UnixTimeStrBetween(season_cfg.StartTime, season_cfg.EndTime) == 0
  else
    log(bWriteLog and "logic_weapon_strength:CheckIsOpenWeaponStrength season_cfg is nil")
  end
  log(bWriteLog and string.format("logic_weapon_strength:CheckIsOpenWeaponStrength bSeason = %s, bSwitch = %s, bVersion = %s, bSeasonTime = %s", tostring(bSeason), tostring(bSwitch), tostring(bVersion), tostring(bSeasonTime)))
  return bSeason and bSwitch and bVersion and bSeasonTime
end
function logic_weapon_strength:GetWeaponTypeConfig()
  if self.weapon_type_config == nil then
    self.weapon_type_config = CDataTable.GetTable("WeaponStrengthWeaponType")
  end
  local res = {}
  for _, v in pairs(self.weapon_type_config) do
    table.insert(res, v)
  end
  return res
end
function logic_weapon_strength:GetWeaponRankConfig()
  if self.weapon_rank_config == nil then
    self.weapon_rank_config = CDataTable.GetTable("WeaponStrengthWeapon")
  end
  local res = {}
  for _, v in pairs(self.weapon_rank_config) do
    table.insert(res, v)
  end
  return res
end
function logic_weapon_strength:GetWeaponRankConfigByWeaponID(weapon_id)
  if self.weapon_id_to_rank_config == nil then
    local weapon_rank_config_list = self:GetWeaponRankConfig()
    self.weapon_id_to_rank_config = {}
    for _, v in pairs(weapon_rank_config_list) do
      self.weapon_id_to_rank_config[v.WeaponID] = v
    end
  end
  local res = self.weapon_id_to_rank_config[weapon_id]
  return res
end
function logic_weapon_strength:GetWeaponRankConfigsByType(type_id)
  local filter_weapons = {}
  for _, v in pairs(self:GetWeaponRankConfig()) do
    if v.Type == type_id then
      table.insert(filter_weapons, v)
    end
  end
  return filter_weapons
end
function logic_weapon_strength:GetWeaponHistorySegmentData(weapon_id)
  log(bWriteLog and "logic_weapon_strength:GetWeaponHistorySegmentData")
  if self.weapon_history_segment_data and next(self.weapon_history_segment_data) and self.weapon_history_segment_data[weapon_id] then
    return self.weapon_history_segment_data[weapon_id]
  else
    log(bWriteLog and "logic_weapon_strength:GetWeaponHistorySegmentData weapon_id = " .. weapon_id .. " not found")
    return nil
  end
end
function logic_weapon_strength:ParseRankId(rank_id)
  log(bWriteLog and string.format("logic_weapon_strength:ParseRankId rank_id = %s", tostring(rank_id)))
  if not rank_id or rank_id <= 0 then
    log(bWriteLog and "logic_weapon_strength:ParseRankId invalid rank_id")
    return nil
  end
  local result = {
    country_zone_id = -1,
    weapon_rank_id = -1,
    season_id = -1
  }
  if rank_id <= 70999 then
    result.weapon_rank_id = math.floor(rank_id / 1000)
    result.season_id = rank_id % 1000
    log(bWriteLog and string.format("logic_weapon_strength:ParseRankId old format - weapon_rank_id = %s, season_id = %s", tostring(result.weapon_rank_id), tostring(result.season_id)))
  else
    result.season_id = rank_id % 1000
    local temp = math.floor(rank_id / 1000)
    result.weapon_rank_id = temp % 100
    result.country_zone_id = math.floor(temp / 100)
    log(bWriteLog and string.format("logic_weapon_strength:ParseRankId new format - country_zone_id = %s, weapon_rank_id = %s, season_id = %s", tostring(result.country_zone_id), tostring(result.weapon_rank_id), tostring(result.season_id)))
  end
  return result
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_weapon_strength = class(CModuleBase, nil, logic_weapon_strength)
return Clogic_weapon_strength