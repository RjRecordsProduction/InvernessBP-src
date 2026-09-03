local logic_teamquick_entry = {}
function logic_teamquick_entry:DefineAndResetData()
  self.isGMShow = false
end
function logic_teamquick_entry:SetGMShow(isGMShow)
  self.  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_ENTRY_UPDATE)
end
function logic_teamquick_entry:CheckCanShow()
  if self.isGMShow then
    log(bWriteLog and "logic_teamquick_entry:CheckCanShow, isGMShow: true")
    return true
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_teamquick_entry = class(CModuleBase, nil, logic_teamquick_entry)
return Clogic_teamquick_entry