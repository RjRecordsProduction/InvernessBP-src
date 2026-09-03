local JumpModuleBase = {}
function JumpModuleBase:JumpCheck(ctorData)
  return true
end
function JumpModuleBase:ShowModule(ctorData)
end
function JumpModuleBase:CloseModule()
end
function JumpModuleBase:GetDataForJumpBack()
  return {
    uiData = {},
    ctorData = {}
  }
end
function JumpModuleBase:JumpBack(uiData)
end
function JumpModuleBase:OnClearJump(ctorData, uiData)
end
function JumpModuleBase:GetPreLoadUIConfig()
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CJumpModuleBase = class(CModuleBase, nil, JumpModuleBase)
return CJumpModuleBase