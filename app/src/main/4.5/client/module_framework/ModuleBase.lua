local ModuleBase = {}
function ModuleBase:DefineAndResetData()
end
function ModuleBase:ctor(_, ModuleConfig)
  self._config = ModuleConfig
end
function ModuleBase:OnInitialize()
end
function ModuleBase:OnDestroy()
end
function ModuleBase:RegistEvents()
end
function ModuleBase:OnLogin(bReLogin)
end
function ModuleBase:OnLogOut()
end
function ModuleBase:OnPreSwitchGameStatus(preState, nextState)
end
function ModuleBase:OnPostSwitchGameStatus(preState, nextState)
end
function ModuleBase:UnRegist()
  ModuleBase.__super.Dispose(self)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, ModuleBase)