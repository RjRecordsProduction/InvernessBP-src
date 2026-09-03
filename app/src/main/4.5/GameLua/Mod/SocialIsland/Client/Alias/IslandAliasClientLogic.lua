local IslandAliasClientLogic = {
  my_alias_list = {},
  players_equip_alias_list = {}
}
function IslandAliasClientLogic.my_alias_list_notify(message)
  IslandAliasClientLogic.my_alias_list = {}
  for _, v in pairs(message.alias_id_list) do
    IslandAliasClientLogic.add_my_alias(v)
  end
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_UPDATE_ALIAS_LIST, message)
end
function IslandAliasClientLogic.new_alias_notify(alias_id)
  IslandAliasClientLogic.add_my_alias(alias_id)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_Add_NEW_ALIAS, alias_id)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_OPNE_REDPOINT_STATUS_CHANGE, Enum_Social_Island_LT_RedHot_Type.Alias, true)
  log(bWriteLog and "IslandAliasClientLogic:new_alias_notify CurAliasNum " .. #IslandAliasClientLogic.my_alias_list)
  log_tree("IslandAliasClientLogic:new_alias_notify my_alias_list:", IslandAliasClientLogic.my_alias_list)
  if #IslandAliasClientLogic.my_alias_list > 1 then
    local cfg = CDataTable.GetTableData("SocialIslandAliasCfg", alias_id)
    if cfg then
      local tipstr = LocUtil.GetLocalizeResStr(11086)
      tipstr = LocUtil.GeneralFormat(tipstr, cfg.AliasName)
      ShowNotice(tipstr)
    end
  end
end
function IslandAliasClientLogic.equip_alias_res(message)
  IslandAliasClientLogic.add_player_equip_alias(tonumber(DataMgr.roleData.uid), message.alias_id)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_EQUIP_ALIAS, message)
  local cfg = CDataTable.GetTableData("SocialIslandAliasCfg", message.alias_id)
  if cfg then
    if message.is_auto_equip == 0 then
      local tipstr = LocUtil.GetLocalizeResStr(11087)
      tipstr = LocUtil.GeneralFormat(tipstr, cfg.AliasName)
      ShowNotice(tipstr)
    else
      local tipstr = LocUtil.GetLocalizeResStr(11085)
      tipstr = LocUtil.GeneralFormat(tipstr, cfg.AliasName)
      ShowNotice(tipstr)
    end
  end
end
function IslandAliasClientLogic.add_my_alias(alias_id)
  for _, v in pairs(IslandAliasClientLogic.my_alias_list) do
    if v == alias_id then
      return
    end
  end
  table.insert(IslandAliasClientLogic.my_alias_list, alias_id)
end
function IslandAliasClientLogic.get_my_alias_list()
  return IslandAliasClientLogic.my_alias_list
end
function IslandAliasClientLogic.add_all_player_equip_alias(state_list)
  IslandAliasClientLogic.players_equip_alias_list = {}
  for _, v in pairs(state_list) do
    IslandAliasClientLogic.add_player_equip_alias(v.uid, v.equip_alias_id)
  end
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_NOTIFY_EQUIPED_ALIAS)
end
function IslandAliasClientLogic.add_player_equip_alias(uid, alias_id)
  if not uid or not alias_id then
    return
  end
  IslandAliasClientLogic.players_equip_alias_list[tonumber(uid)] = alias_id
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_UPDATA_OHTER_PLAYER_EQUIPED_ALIAS, uid)
end
function IslandAliasClientLogic.get_player_equip_alias_id(uid)
  return IslandAliasClientLogic.players_equip_alias_list[tonumber(uid)]
end
function IslandAliasClientLogic.get_player_equip_alias_name(uid)
  local alias_id = IslandAliasClientLogic.get_player_equip_alias_id(uid)
  if alias_id then
    local cfg = CDataTable.GetTableData("SocialIslandAliasCfg", alias_id)
    if cfg then
      return cfg.AliasName
    end
  end
  return ""
end
function IslandAliasClientLogic.get_player_equip_alias_config(uid)
  local alias_id = IslandAliasClientLogic.get_player_equip_alias_id(uid)
  print(bWriteLog and "IslandAliasClientLogic:get_player_equip_alias_config alias_id:" .. tostring(alias_id))
  if alias_id then
    return CDataTable.GetTableData("SocialIslandAliasCfg", alias_id)
  end
end
function IslandAliasClientLogic.clear_data()
  IslandAliasClientLogic.my_alias_list = {}
  IslandAliasClientLogic.players_equip_alias_list = {}
end
function IslandAliasClientLogic.OnModePostSwitch(preState, nextState)
  IslandAliasClientLogic.clear_data()
end
return IslandAliasClientLogic