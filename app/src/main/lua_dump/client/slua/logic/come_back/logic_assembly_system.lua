local logic_assembly_system = {}
local assembly_macro = require("client.slua.logic.come_back.assembly_macro")
function logic_assembly_system:DefineAndResetData()
end
function logic_assembly_system:_OnJumpToAssembly(_, _, params)
  self:ShowMainUI(params and params.tabType or assembly_macro.ENUM_TAB_TYPE.Task)
end
function logic_assembly_system:OnInitialize()
end
function logic_assembly_system:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ASSEMBLY, self._OnJumpToAssembly, self)
end
function logic_assembly_system:OnLogin(bReLogin)
end
function logic_assembly_system:OnLogOut()
end
function logic_assembly_system:OnPreSwitchGameStatus(preState, nextState)
end
function logic_assembly_system:OnPostSwitchGameStatus(preState, nextState)
end
function logic_assembly_system:ShowMainUI(tabType)
  UIManager.ShowUI(UIManager.UI_Config.Assembly_Main_UIBP, tabType or assembly_macro.ENUM_TAB_TYPE.Task)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_assembly_system = class(CModuleBase, nil, logic_assembly_system)
return Clogic_assembly_system