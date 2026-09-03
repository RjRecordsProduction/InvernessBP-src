local WeaponPoolSubSystem = {}
function WeaponPoolSubSystem:_PostConstruct()
  print(bWriteLog and "WeaponPoolSubSystem:_PostConstruct")
end
function WeaponPoolSubSystem:OnInit()
  print(bWriteLog and "WeaponPoolSubSystem:OnInit")
  if self:IsWeaponPoolValid() then
    self:EnableWeaponPool(true)
  else
    self:EnableWeaponPool(false)
  end
end
function WeaponPoolSubSystem:OnRelease()
  print(bWriteLog and "WeaponPoolSubSystem:OnRelease")
  if self:IsWeaponPoolValid() then
    self:EnableWeaponPool(false)
  end
  WeaponPoolSubSystem.__super.OnRelease(self)
end
function WeaponPoolSubSystem:IsWeaponPoolValid()
  if Client then
    if _G.IsEditor then
      return true
    end
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local CurrentModeId = GameMainConfig.GetModeID()
    if CurrentModeId == 2001 or CurrentModeId == 2002 or CurrentModeId == 2003 then
      return true
    end
  end
end
function WeaponPoolSubSystem:EnableWeaponPool(Enable)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, WeaponPoolSubSystem)