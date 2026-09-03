local logic_social_battle_info = {
  MaxOptionCount = 3,
  ModeSuffix = 100,
  PeriodSuffix = 1000,
  options_config = {
    {titleID = 616, keyName = "game_num"},
    {titleID = 613, keyName = "win_num"},
    {
      titleID = 614,
      keyName = "top10_count"
    },
    {titleID = 617, keyName = "kill_num"},
    {
      titleID = 615,
      keyName = "kd_v2",
      bRound = true,
      format = "%.2f"
    },
    {
      titleID = 618,
      keyName = "win_rate",
      suffix = "%"
    },
    {
      titleID = 619,
      keyName = "top10_rate",
      suffix = "%"
    },
    {
      titleID = 620,
      keyName = "avg_shot_hit_ratio",
      multiplier = 100,
      suffix = "%"
    },
    {
      titleID = 621,
      keyName = "head_shot_ratio",
      multiplier = 100,
      suffix = "%"
    },
    {
      titleID = 622,
      keyName = "head_shot_num"
    },
    {
      titleID = 623,
      keyName = "avg_hurt",
      bRound = true
    },
    {
      titleID = 624,
      keyName = "total_hurt",
      bRound = true
    }
  }
}
function logic_social_battle_info.send_set_battleinfo_show_options_req(options)
  log(bWriteLog and "[logic_social_battle_info] send_set_battleinfo_show_options_req")
  if not options or #options ~= logic_social_battle_info.MaxOptionCount then
    log(bWriteLog and "[logic_social_battle_info] invalid options count")
    return
  end
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_set_battleinfo_show_options_req(options)
end
function logic_social_battle_info.on_set_battleinfo_show_options_rsp(err_info, options)
  log(bWriteLog and "[logic_social_battle_info] on_set_battleinfo_show_options_rsp: " .. tostring(err_info))
  if err_info ~= "ok" then
    return
  end
  DataMgr.roleData.battleinfo_show_  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_DISPLAY_CHANGE)
end
function logic_social_battle_info.EncodeOptions(period_index, mode_index, data_id)
  return period_index * logic_social_battle_info.PeriodSuffix + mode_index * logic_social_battle_info.ModeSuffix + data_id
end
function logic_social_battle_info.GetModeIndex(ViewMode, TeamSize)
  return (ViewMode - 1) * 3 + TeamSize
end
function logic_social_battle_info.DecodeOptions(option)
  local period_index = math.modf(option / logic_social_battle_info.PeriodSuffix)
  option = option % logic_social_battle_info.PeriodSuffix
  local mode_index = math.modf(option / logic_social_battle_info.ModeSuffix)
  option = option % logic_social_battle_info.ModeSuffix
  return option, period_index, mode_index
end
function logic_social_battle_info.EncodeShowOptions(raw_option_list, mode_index, period_index)
  if not mode_index or not period_index then
    return
  end
  if not raw_option_list or #raw_option_list ~= logic_social_battle_info.MaxOptionCount then
    return
  end
  local option_list = {}
  for _, raw_option in ipairs(raw_option_list) do
    table.insert(option_list, raw_option + mode_index * logic_social_battle_info.ModeSuffix + period_index * logic_social_battle_info.PeriodSuffix)
  end
  return option_list
end
function logic_social_battle_info.DecodeShowOptions(option_list)
  local raw_option_list = {}
  local period_index = 0
  local mode_index = 0
  if option_list then
    for _, option in ipairs(option_list) do
      local tail_num = option
      period_index = math.modf(tail_num / logic_social_battle_info.PeriodSuffix)
      tail_num = tail_num % logic_social_battle_info.PeriodSuffix
      mode_index = math.modf(tail_num / logic_social_battle_info.ModeSuffix)
      tail_num = tail_num % logic_social_battle_info.ModeSuffix
      table.insert(raw_option_list, tail_num)
    end
  end
  if not raw_option_list or not next(raw_option_list) then
    raw_option_list = {
      2,
      3,
      5
    }
  end
  if period_index == 0 then
    period_index = 2
  end
  if mode_index == 0 then
    mode_index = 1
  end
  return raw_option_list, mode_index, period_index
end
function logic_social_battle_info.GetSelfShowOptions()
  return logic_social_battle_info.DecodeShowOptions(DataMgr.roleData.battleinfo_show_options)
end
function logic_social_battle_info.GetDataByEncodeOption(uid, option)
  if not uid or not option then
    log(bWriteLog and "[logic_social_battle_info] invalid params")
    return
  end
  local raw_option = 0
  local period_index = 0
  local mode_index = 0
  local tail_num = option
  period_index = math.modf(tail_num / logic_social_battle_info.PeriodSuffix)
  tail_num = tail_num % logic_social_battle_info.PeriodSuffix
  mode_index = math.modf(tail_num / logic_social_battle_info.ModeSuffix)
  tail_num = tail_num % logic_social_battle_info.ModeSuffix
  raw_option = tail_num
  return logic_social_battle_info.GetDataByRawOption(uid, raw_option, mode_index, period_index)
end
function logic_social_battle_info.GetDataByRawOption(uid, raw_option, mode_index, period_index)
  if not (uid and raw_option and mode_index) or not period_index then
    log(bWriteLog and "[logic_social_battle_info] invalid params")
    return 0
  end
  local option_config = logic_social_battle_info.options_config[raw_option]
  if not option_config then
    log(bWriteLog and "[logic_social_battle_info] nil option config")
    return 0
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local combat_data
  if period_index == 1 then
    combat_data = LobbySocialSystem.GetCombatInfo(uid)
  elseif period_index == 2 then
    combat_data = LobbySocialSystem.GetCareerCombatInfo(uid)
  elseif period_index == 3 then
    combat_data = LobbySocialSystem.GetPeakCombatInfo(uid)
  end
  if not combat_data or not next(combat_data) then
    log(bWriteLog and "[logic_social_battle_info] nil combat data: " .. tostring(uid))
    return logic_social_battle_info.PostProcessData(0, option_config)
  end
  local mode_combat_data = combat_data[mode_index]
  if not mode_combat_data or not next(mode_combat_data) then
    log(bWriteLog and "[logic_social_battle_info] nil mode combat data: " .. tostring(mode_index))
    return logic_social_battle_info.PostProcessData(0, option_config)
  end
  local a = mode_combat_data[option_config.keyName]
  return logic_social_battle_info.PostProcessData(mode_combat_data[option_config.keyName] or 0, option_config)
end
function logic_social_battle_info.PostProcessData(data, config)
  if not data or not config then
    log(bWriteLog and "[logic_social_battle_info] invalid params")
    return
  end
  if type(data) == "string" then
    local num = data:gsub("[^%d%.%-]", "")
    data = tonumber(num)
  end
  local value = tonumber(data)
  value = value * (config.multiplier or 1)
  local format = config.format or "%.0f"
  if config.suffix then
    value = string.format(format, value)
    if config.suffix == "%" then
      value = LocUtil.LocalizeResFormat(8973143, value)
    else
      value = value .. config.suffix
    end
  elseif config.bRound then
    value = string.format(format, value)
  end
  return value
end
function logic_social_battle_info.GetOptionConfig()
  local AllTagList = prealloctable(6, 0)
  local TableUtil = require("common.table_util")
  for index = 1, 6 do
    AllTagList[index] = TableUtil.CopyTable(logic_social_battle_info.options_config)
  end
  return AllTagList
end
return logic_social_battle_info