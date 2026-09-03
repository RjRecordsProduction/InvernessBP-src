local logic_module_social_person_space = {}
function logic_module_social_person_space:OnInitialize()
  logic_module_social_person_space.__super.OnInitialize(self)
end
function logic_module_social_person_space:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ENTER_PERSON_SPACE, self.OnEnterPersonSpace, self)
end
function logic_module_social_person_space:OnLogin(bReLogin)
end
function logic_module_social_person_space:OnLogOut()
end
function logic_module_social_person_space:OnPreSwitchGameStatus(preState, nextState)
end
function logic_module_social_person_space:OnPostSwitchGameStatus(preState, nextState)
end
function logic_module_social_person_space:OnEnterPersonSpace(_, __, params)
  log(bWriteLog and "LogicModuleSocialPersonSpace:OnEnterPersonSpace")
  log_tree("OnEnterPersonSpace params", params)
  local uid = DataMgr.roleData.uid
  if params and params.uid and tonumber(params.uid) then
    uid = tonumber(params.uid)
  end
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  SocialPersonSpaceSystem.EnterPersonSpace(uid, true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_module_social_person_space = class(CModuleBase, nil, logic_module_social_person_space)
return Clogic_module_social_person_space