local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local ArenaRedDotSystem = {pve_level = 0, red_dot_info = nil}
local match_redpoint_data = require("client.slua.logic.match.red_point.match_redpoint_data")
function ArenaRedDotSystem.OnBasePveLvNotify(cur_pve_lv)
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  save_data = save_data or {
    pve_lv = 0,
    weapon_info = {},
    tab_info = {}
  }
  if cur_pve_lv < (save_data.pve_lv or 0) then
    save_data.weapon_info = {}
    save_data.tab_info = {}
  end
  save_data.pve_lv = cur_pve_lv
  ArenaRedDotSystem.red_dot_info = save_data
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
end
function ArenaRedDotSystem.OnPveLvNotify(cur_pve_lv)
  if not cur_pve_lv then
    log_error("ArenaRedDotSystem.OnPveLvNotify get nil pve level")
    return
  end
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  save_data = save_data or {
    pve_lv = 0,
    weapon_info = {},
    tab_info = {}
  }
  local cfg = CDataTable.GetTable("ArenaPrepareWeapon")
  for k, v in pairs(cfg) do
    if v.UnlockType == "pve_level" and v.UnlockNum > save_data.pve_lv and cur_pve_lv >= v.UnlockNum then
      local id_str = tostring(v.ID)
      local type_str = tostring(v.WeaponType)
      if save_data.weapon_info[id_str] then
        save_data.weapon_info[id_str].weapon_unlock = true
      else
        save_data.weapon_info[id_str] = {weapon_unlock = true}
      end
      if save_data.tab_info[type_str] then
        save_data.tab_info[type_str] = {}
      end
      if not save_data.tab_info[type_str] then
        save_data.tab_info[type_str] = {}
      end
      save_data.tab_info[type_str][id_str] = true
      match_redpoint_data.AddWeaponRed(tonumber(id_str))
    end
  end
  save_data.pve_lv = cur_pve_lv
  ArenaRedDotSystem.red_dot_info = save_data
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
end
function ArenaRedDotSystem.OnWeaponLvNotify(new_lv, before_level, weapon_id)
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  save_data = save_data or {
    pve_lv = 0,
    weapon_info = {},
    tab_info = {}
  }
  local cfg = CDataTable.GetTableData("ArenaPrepareWeapon", weapon_id)
  weapon_id = tostring(weapon_id)
  if not save_data.weapon_info[weapon_id] then
    save_data.weapon_info[weapon_id] = {}
  end
  if before_level and 0 < before_level then
    save_data.weapon_info[weapon_id].lv = before_level
  end
  if not save_data.weapon_info[weapon_id].lv then
    save_data.weapon_info[weapon_id].lv = 0
  end
  local pre_lv = save_data.weapon_info[weapon_id].lv
  if not save_data.weapon_info[weapon_id].comps then
    save_data.weapon_info[weapon_id].comps = {}
  end
  for i = 1, 20 do
    if i > pre_lv and i <= new_lv then
      local compstr = cfg["UnlockComp" .. i]
      if compstr ~= "" and compstr ~= "0" then
        local StringUtil = require("common.string_util")
        local comps = StringUtil.Split(compstr, ";")
        for k, v in ipairs(comps) do
          save_data.weapon_info[weapon_id].comps[tostring(v)] = true
          match_redpoint_data.AddCompRed(string.format("%s;%s", weapon_id, tostring(v)))
        end
      end
    end
  end
  save_data.weapon_info[weapon_id].lv = new_lv
  ArenaRedDotSystem.red_dot_info = save_data
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
end
function ArenaRedDotSystem.UnsetComp(weapon_id, comp_id)
  weapon_id = tostring(weapon_id)
  comp_id = tostring(comp_id)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  if ArenaRedDotSystem.red_dot_info and ArenaRedDotSystem.red_dot_info.weapon_info and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id] and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id].comps then
    ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id].comps[comp_id] = nil
    PlayerPrefsSystem.SaveTableToFile_N(ArenaRedDotSystem.red_dot_info, PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  match_redpoint_data.RemoveCompRed(string.format("%s;%s", weapon_id, comp_id))
end
function ArenaRedDotSystem.UnsetWeapon(weapon_id)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  weapon_id = tostring(weapon_id)
  if ArenaRedDotSystem.red_dot_info and ArenaRedDotSystem.red_dot_info.weapon_info and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id] then
    ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id].weapon_unlock = nil
    local weapon_data = ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id]
    if not weapon_data.weapon_unlock then
      local cfg = CDataTable.GetTableData("ArenaPrepareWeapon", weapon_id)
      local type_str = tostring(cfg.WeaponType)
      if ArenaRedDotSystem.red_dot_info.tab_info[type_str] then
        ArenaRedDotSystem.red_dot_info.tab_info[type_str][weapon_id] = nil
      end
    end
    PlayerPrefsSystem.SaveTableToFile_N(ArenaRedDotSystem.red_dot_info, PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  match_redpoint_data.RemoveWeaponRed(weapon_id)
end
function ArenaRedDotSystem.GetTabRed(weapon_type)
  weapon_type = tostring(weapon_type)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  return ArenaRedDotSystem.red_dot_info and ArenaRedDotSystem.red_dot_info.tab_info and ArenaRedDotSystem.red_dot_info.tab_info[weapon_type] and next(ArenaRedDotSystem.red_dot_info.tab_info[weapon_type])
end
function ArenaRedDotSystem.GetWeaponRed(weapon_id)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  weapon_id = tostring(weapon_id)
  return ArenaRedDotSystem.red_dot_info and ArenaRedDotSystem.red_dot_info.weapon_info and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id] and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id].weapon_unlock
end
function ArenaRedDotSystem.GetCompRed(weapon_id, comp_id)
  weapon_id = tostring(weapon_id)
  comp_id = tostring(comp_id)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  return ArenaRedDotSystem.red_dot_info and ArenaRedDotSystem.red_dot_info.weapon_info and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id] and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id].comps and ArenaRedDotSystem.red_dot_info.weapon_info[weapon_id].comps[comp_id]
end
function ArenaRedDotSystem.GetSlotRed(weapon_id, slot_index)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  local arenaPreCfg = CDataTable.GetTableData("ArenaPrepareWeapon", weapon_id)
  local slotstr = arenaPreCfg["Slot" .. slot_index]
  if slotstr and slotstr ~= "" and slotstr ~= "0" then
    local StringUtil = require("common.string_util")
    local list = StringUtil.Split(slotstr, ";")
    for k, v in ipairs(list) do
      if ArenaRedDotSystem.GetCompRed(weapon_id, v) then
        return true
      end
    end
  end
  return false
end
function ArenaRedDotSystem.GetPreMainSlotRedState(slot_id)
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  local slotCfg = CDataTable.GetTableData("ArenaPrepareSlot", slot_id)
  local StringUtil = require("common.string_util")
  local weaponList = StringUtil.Split(slotCfg.WeaponList, ";")
  local weaponMap = {}
  for k, v in ipairs(weaponList) do
    weaponMap[tonumber(v)] = true
  end
  if not ArenaRedDotSystem.red_dot_info or not ArenaRedDotSystem.red_dot_info.weapon_info then
    return false
  end
  for k, v in pairs(ArenaRedDotSystem.red_dot_info.weapon_info) do
    local weapon_cfg = CDataTable.GetTableData("ArenaPrepareWeapon", k)
    if weapon_cfg and weaponMap[tonumber(weapon_cfg.WeaponType)] and v.weapon_unlock then
      return true
    end
  end
  return false
end
function ArenaRedDotSystem.GetEntranceRedState()
  if not ArenaRedDotSystem.red_dot_info then
    ArenaRedDotSystem.red_dot_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  end
  if not ArenaRedDotSystem.red_dot_info or not ArenaRedDotSystem.red_dot_info.weapon_info then
    return true
  end
  for k, v in pairs(ArenaRedDotSystem.red_dot_info.weapon_info) do
    if v.weapon_unlock then
      return true
    end
  end
  return false
end
function ArenaRedDotSystem.SetEntranceRedState()
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  save_data = save_data or {
    pve_lv = 0,
    weapon_info = {},
    tab_info = {}
  }
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
end
function ArenaRedDotSystem.SaveData()
end
return ArenaRedDotSystem