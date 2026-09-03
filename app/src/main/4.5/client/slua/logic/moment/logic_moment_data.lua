local logic_moment_data = {}
local all_moments_info = {}
local all_failed_moment_ids = {}
local my_moment_info, moment_remind_info, hot_moment_info, wows_hot_moment_info, fri_recent_moment_info
local other_people_moment_info = {}
local other_people_is_banned = {}
local square_moment_info
local my_del_moment_info = {}
local my_skip_moment_info = {}
local my_skip_moment_info_count = 0
local ConstructReplyDetail = function(moment_info)
  moment_info.reply_detail = {}
  if moment_info.show_reply then
    for k, v in pairs(moment_info.show_reply) do
      table.insert(moment_info.reply_detail, v)
    end
    table.sort(moment_info.reply_detail, function(a, b)
      return a.reply_ts < b.reply_ts
    end)
    moment_info.show_reply = nil
  end
end
local ConstructLikeDetail = function(moment_info)
  moment_info.like_detail = {}
  if moment_info.show_like then
    for _, v in pairs(moment_info.show_like) do
      table.insert(moment_info.like_detail, v)
    end
    table.sort(moment_info.like_detail, function(a, b)
      return a.liked_ts < b.liked_ts
    end)
    moment_info.show_like = nil
  end
end
function logic_moment_data.update_all_moments_info(moments_info)
  for moment_id, v in pairs(moments_info) do
    if type(v) == "table" then
      if logic_moment_data.skip_moment_info(v) then
        if not my_skip_moment_info[moment_id] then
          my_skip_moment_info[moment_id] = true
          my_skip_moment_info_count = my_skip_moment_info_count + 1
        end
      else
        ConstructReplyDetail(v)
        ConstructLikeDetail(v)
        all_moments_info[tonumber(moment_id)] = v
      end
    end
  end
end
function logic_moment_data.skip_moment_info(data)
  if not data then
    return false
  end
  local moment_macro = require("client.slua.logic.moment.moment_macro")
  if moment_macro.IsManorShareType(data.type) then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if not logic_home_switch:CheckHomeSwitchOpen() or logic_home_switch:CheckHomeLimit() then
      return true
    end
  end
  return false
end
function logic_moment_data.get_all_moments_info()
  return all_moments_info
end
function logic_moment_data.get_moment_info(moment_id)
  return all_moments_info[tonumber(moment_id)]
end
function logic_moment_data.clear_all_moments_info(moment_ids)
  if moment_ids == nil then
    all_moments_info = {}
  else
    for i, moment_id in ipairs(moment_ids) do
      all_moments_info[tonumber(moment_id)] = nil
    end
  end
end
function logic_moment_data.update_single_moment_info(moment_id, paras)
  local momentinfo = all_moments_info[tonumber(moment_id)]
  if momentinfo then
    for k, v in pairs(paras) do
      momentinfo[k] = v
    end
  end
end
function logic_moment_data.get_single_moment_info(moment_id)
  return all_moments_info[moment_id]
end
function logic_moment_data.del_single_moment_info(moment_id)
  all_moments_info[moment_id] = nil
  if my_moment_info then
    my_moment_info.total_post_cnt = math.max(my_moment_info.total_post_cnt - 1, 0)
  end
end
function logic_moment_data.del_single_wow_moment_info(moment_id)
  all_moments_info[moment_id] = nil
  if my_moment_info then
    my_moment_info.total_post_cnt = math.max(my_moment_info.total_post_cnt - 1, 0)
  end
end
function logic_moment_data.set_my_moment_info(moment_info)
  my_end
function logic_moment_data.get_my_moment_info()
  return my_moment_info
end
function logic_moment_data.record_del_moment_id(moment_id)
  my_del_moment_info[#my_del_moment_info + 1] = moment_id
end
function logic_moment_data.get_my_del_moment_info()
  return my_del_moment_info
end
function logic_moment_data.clear_my_del_moment_info()
  my_del_moment_info = {}
end
function logic_moment_data.clear_my_skip_moment_info()
  my_skip_moment_info = {}
  my_skip_moment_info_count = 0
end
function logic_moment_data.get_my_skip_moment_info_count()
  return my_skip_moment_info_count
end
function logic_moment_data.set_hot_moment_info(moments_info)
  log_tree("set_hot_moment_info", moments_info)
  hot_moment_info = moments_info
end
function logic_moment_data.get_hot_moment_info()
  return hot_moment_info
end
function logic_moment_data.get_wows_hot_moment_info()
  return wows_hot_moment_info
end
function logic_moment_data.set_wows_hot_moment_info(moments_info)
  log_tree("set_wows_hot_moment_info", moments_info)
  wows_hot_moment_info = moments_info
end
function logic_moment_data.get_wows_hot_moment_info()
  return wows_hot_moment_info
end
function logic_moment_data.set_moment_remind_info(remind_info)
  moment_end
function logic_moment_data.get_moment_remind_info()
  return moment_remind_info
end
function logic_moment_data.set_fri_recent_moment_info(remind_info)
  fri_recent_moment_info = remind_info
end
function logic_moment_data.get_fri_recent_moment_info()
  return fri_recent_moment_info
end
function logic_moment_data.set_other_people_moment_info(uid, moment_ids, is_banned)
  other_people_moment_info[uid] = moment_ids
  other_people_is_banned[uid] = is_banned
end
function logic_moment_data.get_other_people_moment_info(uid)
  return other_people_moment_info[uid]
end
function logic_moment_data.get_other_people_is_banned(uid)
  return other_people_is_banned[uid]
end
function logic_moment_data.clear_other_moment_info()
  other_people_moment_info = {}
  other_people_is_banned = {}
end
function logic_moment_data.update_failed_moments_id(failed_moments_id_list)
  for _, id in ipairs(failed_moments_id_list) do
    all_failed_moment_ids[id] = true
  end
end
function logic_moment_data.is_failed_moment_id(moments_id)
  return all_failed_moment_ids[moments_id]
end
function logic_moment_data.set_square_moment_info(moment_info)
  square_end
function logic_moment_data.get_square_moment_info()
  return square_moment_info
end
return logic_moment_data