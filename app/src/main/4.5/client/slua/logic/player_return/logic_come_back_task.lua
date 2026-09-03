local logic_come_back_task = {
  ext_info = nil,
  get_task_list = nil,
  curDay = 0,
  active_cfg = nil,
  dropsList = nil
}
local PlayerRetrunHandler = require("client.network.Protocol.PlayerReturnHandler")
function logic_come_back_task.GetRedPoint()
  if not logic_come_back_task.get_task_list then
    return false
  end
  for k, taskList in pairs(logic_come_back_task.get_task_list) do
    for _, task in pairs(taskList) do
      if task.status == 1 then
        return true
      end
    end
  end
  local act_cfg = logic_come_back_task.active_cfg
  local ext_info = logic_come_back_task.ext_info
  for k = 1, 5 do
    if act_cfg[k] and ext_info.cur_active >= act_cfg[k].cond_val and not ext_info.got_index[k] then
      return true
    end
  end
  return false
end
function logic_come_back_task.send_backuser_get_task_list_req()
  PlayerRetrunHandler.send_backuser_get_task_list_req()
end
function logic_come_back_task.on_backuser_get_task_list_res(res, task_list, ext_info, active_cfg, is_flush_task_per_day, task_reward_cfg)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  logic_come_back_task.  logic_come_back_task.get_task_list = {}
  logic_come_back_task.get_task_list2 = {}
  logic_come_back_task.  logic_come_back_task.  logic_come_back_task.  for k, v in pairs(task_list) do
    local day = math.floor(k / 100)
    if not logic_come_back_task.get_task_list[day] then
      logic_come_back_task.get_task_list[day] = {}
    end
    table.insert(logic_come_back_task.get_task_list[day], v)
    v.task_no = k
  end
  for k, v in pairs(task_reward_cfg) do
    local day = v.day
    if not logic_come_back_task.get_task_list2[day] then
      logic_come_back_task.get_task_list2[day] = {}
    end
    table.insert(logic_come_back_task.get_task_list2[day], v)
    v.task_no = k
  end
  log_tree("god test  logic_come_back_task.ext_info", logic_come_back_task.ext_info)
  log_tree("god test  logic_come_back_task.active_cfg ", logic_come_back_task.active_cfg)
  log_tree("god test  logic_come_back_task.task_reward_cfg ", logic_come_back_task.task_reward_cfg)
  log_tree("god test task_list ", task_list)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_TASK_REDPOINT)
end
function logic_come_back_task.send_backuser_get_active_reward_req(index, drop_idx)
  PlayerRetrunHandler.send_backuser_get_active_reward_req(index, drop_idx)
end
function logic_come_back_task.on_backuser_get_active_reward_res(res, index, drop_idx)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local arrayItemList = {}
  local act_cfg = logic_come_back_task.active_cfg
  log_tree("god test act_cfg1 ", act_cfg)
  log(bWriteLog and "god test act_cfg1 index " .. tostring(index))
  if act_cfg and act_cfg[index] then
    local arrayItem = {}
    if drop_idx then
      arrayItem.res_id = act_cfg[index]["res_id" .. drop_idx]
      arrayItem.count = act_cfg[index]["res_num" .. drop_idx]
    else
      arrayItem.res_id = act_cfg[index].res_id1
      arrayItem.count = act_cfg[index].res_num1
    end
    table.insert(arrayItemList, arrayItem)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
  logic_come_back_task.ext_info.got_index[index] = true
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_TASK_REDPOINT)
end
function logic_come_back_task.on_backuser_task_change_notify(task_no, one_task)
  log_tree("god test one_task ", one_task)
  if not logic_come_back_task.get_task_list then
    logic_come_back_task.send_backuser_get_task_list_req()
    return
  end
  for k, taskList in pairs(logic_come_back_task.get_task_list) do
    for _, task in pairs(taskList) do
      if task.task_no == task_no then
        task.para1 = one_task.para1
        task.para2 = one_task.para2
        task.status = one_task.status
        task.progress = one_task.progress
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_TASK_REDPOINT)
end
return logic_come_back_task