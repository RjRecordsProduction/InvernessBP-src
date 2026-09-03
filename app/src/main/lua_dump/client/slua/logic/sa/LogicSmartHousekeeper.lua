local LogicSmartHousekeeper = {}
function LogicSmartHousekeeper:DefineAndResetData()
end
function LogicSmartHousekeeper:OnInitialize()
end
function LogicSmartHousekeeper:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SMARTHELPER, self.ShowSmarthelperTips, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_USETOOLNOTICE, self.UseToolsTips, self)
end
function LogicSmartHousekeeper:OnLogin(bReLogin)
end
function LogicSmartHousekeeper:OnLogOut()
end
function LogicSmartHousekeeper:OnPreSwitchGameStatus(preState, nextState)
end
function LogicSmartHousekeeper:OnPostSwitchGameStatus(preState, nextState)
end
function LogicSmartHousekeeper:ShowSmarthelperTips()
  local title = LocUtil.GetLocalizeResStr(76418)
  local content = LocUtil.GetLocalizeStrConcatenation(76419)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content, nil, nil, nil, nil, nil, nil, true)
end
function LogicSmartHousekeeper:UseToolsTips()
  local title = LocUtil.GetLocalizeResStr(76415)
  local content = LocUtil.GetLocalizeResStr(76417)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content, nil, nil, nil, nil, nil, nil, true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicSmartHousekeeper = class(CModuleBase, nil, LogicSmartHousekeeper)
return CLogicSmartHousekeeper