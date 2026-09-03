local FatalDamageSubsystem = {}
function FatalDamageSubsystem:ShouldSendFatalDamageToClient(Causer, Victim)
  if slua.isValid(Causer) then
    return true
  end
  return false
end
local class = require("class")
local SubsystemBase = require("GameLua.Mod.Library.DS.FatalDamageExpandData.FatalDamageSubsystem")
return class(SubsystemBase, nil, FatalDamageSubsystem)