local CClientGlueHiaSystem = {}
function CClientGlueHiaSystem:LuaFunc1(uEnemyCharacter)
  if not slua.isValid(uEnemyCharacter) then
    return true
  end
  return true
end
function CClientGlueHiaSystem:LuaFunc2()
end
function CClientGlueHiaSystem:LuaFunc3(nPlayerKey)
end
function CClientGlueHiaSystem:LuaFunc4(nPlayerKey)
  return false
end
function CClientGlueHiaSystem:LuaFunc5(nPlayerKey)
  return false
end
function CClientGlueHiaSystem:LuaFunc6(nPlayerKey)
  return false
end
function CClientGlueHiaSystem:LuaFunc7(nPlayerKey)
  return false
end
function CClientGlueHiaSystem:LuaFunc8(nPlayerKey)
  return false
end
function CClientGlueHiaSystem:LuaFunc9(nPlayerKey)
end
local class = require("class")
local object = require("object")
return class(object, nil, CClientGlueHiaSystem)