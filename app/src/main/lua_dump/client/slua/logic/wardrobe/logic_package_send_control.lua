local logic_package_send_control = {}
local package_send_control_config = require("client.slua.logic.wardrobe.package_send_control_config")
function logic_package_send_control:OnInitialize()
  log(bWriteLog and "logic_package_send_control:OnInitialize")
end
function logic_package_send_control:OnDestroy()
  log(bWriteLog and "logic_package_send_control:OnDestroy")
end
function logic_package_send_control:CanSendPackage(msgName, bTips)
  log(bWriteLog and "logic_package_send_control:CanSendPackage msgName = " .. msgName)
  local info = package_send_control_config[msgName]
  if not info then
    return true
  end
  local tNow = FuncUtil.GetServerTimeInSec()
  if info.cur_count == nil then
    info.cur_time = tNow
    info.cur_count = 0
  end
  if tNow > info.cur_time + info.max_time then
    info.cur_time = tNow
    info.cur_count = 0
  end
  if info.cur_count >= info.max_count then
    if bTips then
      ShowNotice(100140005)
    end
    return false
  end
  return true
end
function logic_package_send_control:MarkSendPackage(msgName)
  log(bWriteLog and "logic_package_send_control:MarkSendPackage msgName = " .. msgName)
  local info = package_send_control_config[msgName]
  if not info then
    return
  end
  info.cur_count = info.cur_count + 1
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_package_send_control)
return CModuleTemplate