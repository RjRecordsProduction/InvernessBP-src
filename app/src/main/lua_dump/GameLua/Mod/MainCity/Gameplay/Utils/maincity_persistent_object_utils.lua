local maincity_persistent_object_utils = {}
local _curPersistentObjectID = 1
function maincity_persistent_object_utils.EnablePersistentObject()
  print(bWriteLog and "maincity_persistent_object_utils.EnablePersistentObject")
  POManager.SetPOEnabled(true)
end
function maincity_persistent_object_utils.DisablePersistentObject()
  print(bWriteLog and "maincity_persistent_object_utils.DisablePersistentObject")
  POManager.SetPOEnabled(false)
  POManager.ClearAll()
  POManager.DestroyInstance()
end
function maincity_persistent_object_utils.DSAutoRegisterPersistentObject(persistentObject)
  if Client then
    print(bWriteLog and "maincity_persistent_object_utils.DSAutoRegisterPersistentObject Client not allowed")
    return
  end
  POManager.RegisterUniqueID(_curPersistentObjectID, persistentObject)
  _curPersistentObjectID = _curPersistentObjectID + 1
end
function maincity_persistent_object_utils.DSRegisterPersistentObject(persistentObject, id)
  if Client then
    print(bWriteLog and "maincity_persistent_object_utils.DSRegisterPersistentObject Client not allowed")
    return
  end
  if id < 10000 then
    print(bWriteLog and "maincity_persistent_object_utils.DSRegisterPersistentObject id is invalid")
    return
  end
  POManager.RegisterUniqueID(id, persistentObject)
end
function maincity_persistent_object_utils.GetValidPersistentObjectIDList()
  local PersistentObjectIDConfig = require("GameLua.Mod.MainCity.Gameplay.Config.PersistentObjectIDConfig")
  local existIDMap = {}
  local idList = {}
  for k, v in pairs(PersistentObjectIDConfig) do
    if v < 10000 then
      print(bWriteLog and "maincity_persistent_object_utils.GetValidPersistentObjectIDList PersistentObjectIDConfig invalid")
      return {}
    end
    if existIDMap[v] then
      print(bWriteLog and "maincity_persistent_object_utils.GetValidPersistentObjectIDList PersistentObjectIDConfig duplicate")
      return {}
    end
    table.insert(idList, v)
    existIDMap[v] = true
  end
  return idList
end
return maincity_persistent_object_utils