local lua_common_doubleclick_item = {}
function lua_common_doubleclick_item:OnClose()
  self.callBack = nil
  self.param = nil
  self:_ClearData()
end
function lua_common_doubleclick_item:InitDoubleClickItem(time, callBack, ...)
  if self.callBack then
    return
  end
  log(bWriteLog and "  : InitDoubleClickItem time" .. tostring(time))
  self.nClickTime = 0
  self.nTime = time
  self.  self.param = table.pack(...)
end
function lua_common_doubleclick_item:OnClickButton()
  if not self.nClickTime then
    log_error("have not called InitDoubleClickItem")
    return
  end
  log(bWriteLog and "  :lua_common_doubleclick_item OnClickButton")
  if self.nClickTime == 1 then
    log(bWriteLog and "  :lua_common_doubleclick_item double click")
    if self.callBack then
      self.callBack(table.unpack(self.param))
    end
    self:_ClearData()
    return
  end
  self.nClickTime = 1
  self.timer = self:AddTimerOnce(self.nTime, function()
    self:_ClearData()
  end)
end
function lua_common_doubleclick_item:_ClearData()
  log(bWriteLog and "  : _ClearData")
  self.nClickTime = 0
  if self.timer then
    self:RemoveTimer(self.timer)
    self.timer = nil
  end
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_common_doubleclick_item)