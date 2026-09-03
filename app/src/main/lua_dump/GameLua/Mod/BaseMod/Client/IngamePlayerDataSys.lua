local IngamePlayerDataSys = {}
function IngamePlayerDataSys:GetPlayerLevel()
  local CurrentLv = -1
  if DataMgr and DataMgr.roleData and DataMgr.roleData.level then
    CurrentLv = DataMgr.roleData.level
  end
  log(bWriteLog and "IngamePlayerDataSys.GetPlayerLevel: " .. tostring(CurrentLv))
  return CurrentLv
end
local class = require("class")
local object = require("object")
local CIngamePlayerDataSys = class(object, nil, IngamePlayerDataSys)
return CIngamePlayerDataSys