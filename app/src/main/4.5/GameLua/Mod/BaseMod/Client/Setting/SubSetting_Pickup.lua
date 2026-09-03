local SubSetting_Pickup = {}
function SubSetting_Pickup:OnInit()
  print(bWriteLog and "SubSetting_Pickup:OnInit")
  local SettingSharedUtils = require("client.logic.NewSetting.SettingSharedUtils")
  SettingSharedUtils.SetSeasonAutoLoot()
end
function SubSetting_Pickup:OnRelease()
  print(bWriteLog and "SubSetting_Pickup:OnRelease")
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CSubSetting_Pickup = class(CDelegateContainer, nil, SubSetting_Pickup)
return CSubSetting_Pickup