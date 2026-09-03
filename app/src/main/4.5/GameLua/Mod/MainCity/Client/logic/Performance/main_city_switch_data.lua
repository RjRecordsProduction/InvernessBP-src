local main_city_switch_data = {}
function main_city_switch_data:InitSwitch()
  log(bWriteLog and "main_city_switch_data:InitSwitch")
  self.switch_data_map = {}
end
function main_city_switch_data:OpenSwitch(type)
  log(bWriteLog and "main_city_switch_data:OpenSwitch type = " .. type)
  self.switch_data_map[type] = true
end
function main_city_switch_data:CloseSwitch(type)
  log(bWriteLog and "main_city_switch_data:CloseSwitch type = " .. type)
  self.switch_data_map[type] = nil
end
function main_city_switch_data:GetSwitchVal()
  for k, v in pairs(self.switch_data_map) do
    if v then
      return true
    end
  end
  return false
end
local class = require("class")
local object = require("object")
return class(object, nil, main_city_switch_data)