local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local time_ticker = require("common.time_ticker")
local xqueue = require("client.common.uibase.xqueue")
local HDmpveVoiceCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local Enum_AntsVoiceRoomOpera = logic_chat_voice_const.Enum_AntsVoiceRoomOpera
local Enum_AntsVoiceRoomOperaStatus = logic_chat_voice_const.Enum_AntsVoiceRoomOperaStatus
local Enum_OperationErrorCode = logic_chat_voice_const.Enum_OperationErrorCode
local logic_chat_voice_room_operation_manager = {
  tick_interval = 0.3,
  ticker_timer = nil,
  current_task = nil,
  room_operate_queue = nil,
  failed_operate_queue = nil
}
function logic_chat_voice_room_operation_manager:Initialize()
  log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:Initialize"))
  if logic_chat_voice_room_operation_manager.room_operate_queue == nil then
    logic_chat_voice_room_operation_manager.room_operate_queue = xqueue.Create(30)
  end
  logic_chat_voice_room_operation_manager.failed_operate_queue = xqueue.Create(20)
  self.ticker_timer = time_ticker.AddTimer(0, function()
    while true do
      self:Tick(self.tick_interval)
      coroutine.yield(self.tick_interval)
    end
  end)
end
function logic_chat_voice_room_operation_manager:Tick(delta_time)
  if logic_chat_voice_room_operation_manager.current_task ~= nil then
    self:TickCurRoomOperationTask(delta_time, logic_chat_voice_room_operation_manager.current_task)
    return
  end
  local queue_len = logic_chat_voice_room_operation_manager.room_operate_queue:Len()
  if queue_len <= 0 then
    return
  end
  while 3 < queue_len do
    local first_taks = logic_chat_voice_room_operation_manager.room_operate_queue:Get(1)
    local second_taks = logic_chat_voice_room_operation_manager.room_operate_queue:Get(2)
    if first_taks.operate == Enum_AntsVoiceRoomOpera.Join and second_taks.operate == Enum_AntsVoiceRoomOpera.Quit then
      log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:Tick skip room jion/quit %s", first_taks.room_info.room_id or ""))
      logic_chat_voice_room_operation_manager.room_operate_queue:Pop()
      logic_chat_voice_room_operation_manager.room_operate_queue:Pop()
      queue_len = logic_chat_voice_room_operation_manager.room_operate_queue:Len()
    else
      break
    end
  end
  logic_chat_voice_room_operation_manager.current_task = logic_chat_voice_room_operation_manager.room_operate_queue:Pop()
end
function logic_chat_voice_room_operation_manager:AddRoomOperation(type, func, room_info)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(400)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:AddRoomOperation: %s %s", tostring(type), room_info.room_id or ""))
  if type == Enum_AntsVoiceRoomOpera.Join then
    local queue = logic_chat_voice_room_operation_manager.room_operate_queue
    if queue and queue:Len() > 0 then
      local dataList = queue.dataList
      local bRemove = false
      for i = #dataList, 1, -1 do
        local task = dataList[i]
        if task.operate == Enum_AntsVoiceRoomOpera.Join then
          local roomType = task.room_info.room_type
          local roomID = task.room_info.room_id
          if roomType == room_info.room_type then
            printf("logic_chat_voice_room_operation_manager:AddRoomOperation join remove exist task. roomType:%s, room_id:%s", roomType, roomID)
            table.remove(dataList, i)
            bRemove = true
          end
        end
      end
      if bRemove then
        log_tree("logic_chat_voice_room_operation_manager:AddRoomOperation queue", dataList)
      end
    end
  end
  local opera_task = {
    operate = type,
    func = func,
    retry = 0,
    timeout_counter = 0,
    room_info = room_info,
    add_time = 0,
    start_time = 0,
    status = Enum_AntsVoiceRoomOperaStatus.Idle
  }
  if logic_chat_voice_room_operation_manager.room_operate_queue == nil then
    logic_chat_voice_room_operation_manager.room_operate_queue = xqueue.Create(30)
  end
  logic_chat_voice_room_operation_manager.room_operate_queue:Push(opera_task)
  local queue = logic_chat_voice_room_operation_manager.room_operate_queue
  if queue:Len() == 2 and queue:Get(1).operate == Enum_AntsVoiceRoomOpera.Quit and queue:Get(2).operate == Enum_AntsVoiceRoomOpera.Join then
    printf("logic_chat_voice_room_operation_manager:AddRoomOperation normal expection")
  else
    log_tree("logic_chat_voice_room_operation_manager:AddRoomOperation", queue)
  end
end
function logic_chat_voice_room_operation_manager:OnRoomOperationReturn(operate, result_code, room_id, extra)
  room_id = room_id or ""
  extra = extra or ""
  log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:OnRoomOperationReturn: %s %s %s", operate, room_id, tostring(result_code)))
  if logic_chat_voice_room_operation_manager.current_task == nil then
    log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:OnRoomOperationReturn return by current_task is nil"))
    return
  end
  if logic_chat_voice_room_operation_manager.current_task.operate ~= operate then
    log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:OnRoomOperationReturn return by operate notmatch"))
    return
  end
  if operate == Enum_AntsVoiceRoomOpera.Join then
    if result_code == Enum_OperationErrorCode.AlreadyInRoomError or result_code == Enum_OperationErrorCode.NeedInit or result_code == Enum_OperationErrorCode.ParamInvalid or result_code == Enum_OperationErrorCode.RealtimeStateErr then
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.Finish)
    else
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.CallErr)
    end
  elseif operate == Enum_AntsVoiceRoomOpera.Quit then
    if result_code == Enum_OperationErrorCode.QuitRoomNameErr or result_code == Enum_OperationErrorCode.NeedInit or result_code == Enum_OperationErrorCode.ParamInvalid or result_code == Enum_OperationErrorCode.RealtimeStateErr then
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.Finish)
    else
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.CallErr)
    end
  end
end
function logic_chat_voice_room_operation_manager:OnRoomOperationCompleteCallback(operate, result_code, room_id, extra)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:OnRoomOperationCompleteCallback: %s %s %s", operate, room_id, tostring(result_code)))
  if operate == Enum_AntsVoiceRoomOpera.Join then
    if result_code == HDmpveVoiceCompleteCode.JoinRoomSucc then
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.Finish)
    else
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.CompleteErr)
    end
  elseif operate == Enum_AntsVoiceRoomOpera.Quit then
    if result_code == HDmpveVoiceCompleteCode.QuitRoomSucc then
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.Finish)
    else
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.CompleteErr)
    end
  end
end
function logic_chat_voice_room_operation_manager:TickCurRoomOperationTask(delta_time, opera_task)
  if opera_task.status == Enum_AntsVoiceRoomOperaStatus.Idle then
    local TimeUtil = require("client.common.time_util")
    opera_task.start_time = TimeUtil.OSTime()
    self:SwitchTaskStatus(opera_task, Enum_AntsVoiceRoomOperaStatus.Doing)
    self:DoRoomOpera(opera_task)
  elseif opera_task.status == Enum_AntsVoiceRoomOperaStatus.Doing or opera_task.status == Enum_AntsVoiceRoomOperaStatus.CallErr or opera_task.status == Enum_AntsVoiceRoomOperaStatus.CompleteErr then
    opera_task.timeout_counter = opera_task.timeout_counter + delta_time
    if opera_task.timeout_counter > self:GetTimeout(opera_task.operate, opera_task.status) then
      if opera_task.retry >= self:GetRetryCount(opera_task.operate) then
        log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:TickCurRoomOperationTask failed: %s %s", opera_task.operate, opera_task.room_info.room_id or ""))
        logic_chat_voice_room_operation_manager.failed_operate_queue:Push(opera_task)
        logic_chat_voice_room_operation_manager.current_task = nil
      else
        log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:TickCurRoomOperationTask retry: %d %s %s", opera_task.retry + 1, opera_task.operate, opera_task.room_info.room_id or ""))
        opera_task.retry = opera_task.retry + 1
        self:DoRoomOpera(opera_task)
      end
      opera_task.timeout_counter = 0
    end
  elseif opera_task.status == Enum_AntsVoiceRoomOperaStatus.Finish then
    logic_chat_voice_room_operation_manager.current_task = nil
  end
end
function logic_chat_voice_room_operation_manager:SwitchTaskStatus(task, status)
  if task ~= nil then
    task.    task.timeout_counter = 0
  end
end
function logic_chat_voice_room_operation_manager:DoRoomOpera(opera_task)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_room_operation_manager:DoRoomOpera %s", opera_task.operate))
  if opera_task.operate == Enum_AntsVoiceRoomOpera.Join then
    opera_task.func(opera_task.room_info)
  elseif opera_task.operate == Enum_AntsVoiceRoomOpera.Quit then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    if logic_antsvoice_interface:GetTeamRoomName() == logic_chat_voice_const.NO_TEAM_ROOM_ROOM_NAME then
      self:SwitchTaskStatus(logic_chat_voice_room_operation_manager.current_task, Enum_AntsVoiceRoomOperaStatus.Finish)
    else
      opera_task.func(opera_task.room_info)
    end
  else
    log(bWriteLog and "[WSL] logic_chat_voice_room_operation_manager:DoTaskAction do nothing in idle")
  end
end
function logic_chat_voice_room_operation_manager:IsJoinOperaInLast(room_id)
  local queue_len = 0
  if logic_chat_voice_room_operation_manager.room_operate_queue then
    queue_len = logic_chat_voice_room_operation_manager.room_operate_queue:Len()
  end
  if room_id == nil then
    if 0 < queue_len then
      local latest_task = logic_chat_voice_room_operation_manager.room_operate_queue:Get(queue_len)
      if latest_task.operate == Enum_AntsVoiceRoomOpera.Join then
        return true
      end
    elseif logic_chat_voice_room_operation_manager.current_task and logic_chat_voice_room_operation_manager.current_task.operate == Enum_AntsVoiceRoomOpera.Join then
      return true
    end
  elseif 0 < queue_len then
    for i = queue_len, 1, -1 do
      local latest_task = logic_chat_voice_room_operation_manager.room_operate_queue:Get(i)
      if latest_task.operate == Enum_AntsVoiceRoomOpera.Join and latest_task.room_info.room_id == room_id then
        return true
      elseif latest_task.operate == Enum_AntsVoiceRoomOpera.Quit then
        return false
      end
    end
  elseif logic_chat_voice_room_operation_manager.current_task and logic_chat_voice_room_operation_manager.current_task.operate == Enum_AntsVoiceRoomOpera.Join and logic_chat_voice_room_operation_manager.current_task.room_info.room_id == room_id then
    return true
  end
  return false
end
function logic_chat_voice_room_operation_manager:IsAllTaskFinished()
  local is_all_task_finished = (logic_chat_voice_room_operation_manager.room_operate_queue == nil or logic_chat_voice_room_operation_manager.room_operate_queue:Len() <= 0) and logic_chat_voice_room_operation_manager.current_task == nil
  return is_all_task_finished
end
function logic_chat_voice_room_operation_manager:GetTimeout(opera_type, opera_status)
  local timeout_key = string.format("%s%s", opera_type, opera_status)
  local timeout = logic_chat_voice_const.RoomOperTimeout[timeout_key] or logic_chat_voice_const.RoomOperTimeout.Default
  return timeout
end
function logic_chat_voice_room_operation_manager:GetRetryCount(opera_type)
  local retry_count = logic_chat_voice_const.RoomOperRetryMAXCount[opera_type] or logic_chat_voice_const.RoomOperRetryMAXCount.Default
  return retry_count
end
return logic_chat_voice_room_operation_manager