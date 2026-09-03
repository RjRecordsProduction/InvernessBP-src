local logic_custom_presentation = {}
local savedCPData
function logic_custom_presentation:OnInitialize()
  log(bWriteLog and "logic_custom_presentation:OnInitialize")
end
function logic_custom_presentation:RegistEvents()
  log(bWriteLog and "logic_custom_presentation:RegistEvents")
end
function logic_custom_presentation:OnLogOut()
  savedCPData = nil
end
function logic_custom_presentation:GetData()
  if not savedCPData then
    local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
    savedCPData = LobbySystem.roleData.custom_presentation or custom_presentation_config.DefaultPresentationData
  end
  return savedCPData
end
function logic_custom_presentation:SetData(custom_presentation)
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  savedCPData = custom_presentation or custom_presentation_config.DefaultPresentationData
end
function logic_custom_presentation:SetCurDragData(dragData)
  self.end
function logic_custom_presentation:GetCurDragData()
  return self.dragData
end
function logic_custom_presentation:SetInformationType(typeIdx)
  self.end
function logic_custom_presentation:GetInformationType()
  return self.typeIdx
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_custom_presentation)