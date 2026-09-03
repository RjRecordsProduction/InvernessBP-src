local logic_ds_monitor = {}
local RecordInterval = 300
local RecordTableMaxLen = 130
function logic_ds_monitor:DefineAndResetData()
  self.datas = {}
  self.bOpenClientMonitor = false
  self.data_send_len = 0
  self.data_recv_len = 0
end
function logic_ds_monitor:GetProtoIndex(messageName)
  local config = require("client.network.comm.DSProto2IndexConfig")
  if not config[messageName] then
    log_error(string.format("logic_ds_monitor:GetProtoIndex: messageName not found: %s", messageName))
    return nil
  end
  return config[messageName].hashCode, config[messageName].paraCnt
end
function logic_ds_monitor:OnRecordMsg(messageName, size, isSend)
  if Client and not self.bOpenClientMonitor then
    return
  end
  print(bWriteLog and string.format("logic_ds_monitor:OnRecordMsg: messageName = %s, isSend = %s", messageName, isSend and "true" or "false"))
  local index, paraCnt = self:GetProtoIndex(messageName)
  if not index then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local current_time = TimeUtil.GetServerTimeInSec()
  if #self.datas == 0 then
    self:NewRecord(current_time)
  end
  local data = self.datas[#self.datas]
  if current_time >= data.time + RecordInterval then
    self:NewRecord(current_time)
    data = self.datas[#self.datas]
  end
  print(bWriteLog and string.format("logic_ds_monitor:OnRecordMsg: size = %s", size))
  if isSend then
    if data.table_send[index] then
      data.table_send[index].count = data.table_send[index].count and data.table_send[index].count + 1 or 1
      data.table_send[index].size = data.table_send[index].size and data.table_send[index].size + size or size
    else
      data.table_send[index] = {size = size, count = 1}
      self.data_send_len = self.data_send_len + 1
    end
  elseif data.table_recv[index] then
    data.table_recv[index].count = data.table_recv[index].count and data.table_recv[index].count + 1 or 1
    data.table_recv[index].size = data.table_recv[index].size and data.table_recv[index].size + size or size
  else
    data.table_recv[index] = {count = 1, size = size}
    self.data_recv_len = self.data_recv_len + 1
  end
  if self.data_send_len >= RecordTableMaxLen or self.data_recv_len >= RecordTableMaxLen then
    self:NewRecord(current_time)
  end
end
function logic_ds_monitor:SetClientMonitor(open)
  self.bOpenClientMonitor = open
end
function logic_ds_monitor:NewRecord(new_time)
  print(bWriteLog and "logic_ds_monitor:NewRecord new_time: " .. new_time)
  log_tree("logic_ds_monitor:NewRecord", self.datas)
  print(bWriteLog and string.format("logic_ds_monitor:NewRecord data_send_len = %s, data_recv_len = %s", self.data_send_len, self.data_recv_len))
  self.data_send_len = 0
  self.data_recv_len = 0
  if #self.datas > 0 then
    local upload_data = self.datas[#self.datas]
    if upload_data then
      upload_data.time_over = new_time
      log_tree("logic_ds_monitor:NewRecord upload_data: ", upload_data)
      if not Client and NetUtil and NetUtil.SendPacket then
        NetUtil.SendPacket("DSProtocolFrequencyReport", upload_data)
      end
      table.remove(self.datas, #self.datas)
    end
  end
  table.insert(self.datas, {
    time = new_time,
    time_over = 0,
    table_send = {},
    table_recv = {}
  })
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ds_monitor = class(CModuleBase, nil, logic_ds_monitor)
return Clogic_ds_monitor