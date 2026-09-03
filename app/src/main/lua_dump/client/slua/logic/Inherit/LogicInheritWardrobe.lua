local LogicInheritWardrobe = {}
function LogicInheritWardrobe:DefineAndResetData()
  self.bBackendIsOK = false
  self.inherit_pet_data = {}
  self.used_inherit_items = {}
  self.refit_map_inherit = {}
  self.XSuitStateInfo = nil
  self.dragon_ball_unlock_state = nil
end
function LogicInheritWardrobe:OnLogin(bReLogin)
  print(bWriteLog and "LogicInheritWardrobe:OnLogin" .. tostring(bReLogin))
  self.bBackendIsOK = false
end
function LogicInheritWardrobe:CacheWardrobeData(depot, source)
  if source == 2 then
    self.bBackendIsOK = true
  end
  if not depot then
    log(bWriteLog and "LogicInheritWardrobe:CacheWardrobeData not depot")
    return
  end
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
  DataEntity:InitData({
    depot.items
  })
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RECEIVE_INHERIT_DATA)
end
function LogicInheritWardrobe:CacheInheritPetData(inherit_pet_data)
  log_tree("LogicInheritWardrobe:CacheInheritPetData inherit_pet_data", inherit_pet_data)
  self.inherit_pet_data = inherit_pet_data or {}
  if self.inherit_pet_data and self.inherit_pet_data.pets then
    local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
    for key, value in pairs(self.inherit_pet_data.pets) do
      if value.id and value.id > 0 then
        value.ins_id = logic_pet:ConvertToInsID(value.id, EPetSource.Inherit)
      end
    end
  end
end
function LogicInheritWardrobe:GetInheritPetData()
  return self.inherit_pet_data
end
function LogicInheritWardrobe:HasPet(PetInsID)
  local PetData = self:GetPetDataByInsID(PetInsID)
  if PetData and next(PetData) then
    return true
  end
  return false
end
function LogicInheritWardrobe:GetPetDataByInsID(PetInsID)
  if not self.inherit_pet_data or not self.inherit_pet_data.pets then
    return
  end
  for key, value in pairs(self.inherit_pet_data.pets) do
    if value.ins_id == PetInsID then
      return value
    end
  end
  return nil
end
function LogicInheritWardrobe:CacheUsingInheritItem(used_inherit_items)
  self.used_inherit_items = used_inherit_items or {}
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
  if DataEntity.bInit then
    log(bWriteLog and "LogicInheritWardrobe:CacheUsingInheritItem DataEntity Has Init")
    return
  end
  DataEntity:InitData({used_inherit_items})
  if LobbySystem.WaitDepotInfo then
    LobbySystem.CreatLobbyAvatar()
  end
end
function LogicInheritWardrobe:CacheRefitMapInherit(refit_map_inherit)
  self.end
function LogicInheritWardrobe:GetRefitMapInherit()
  return self.refit_map_inherit
end
function LogicInheritWardrobe:CacheXSuitStateInfo(StateInfo)
  self.XSuitStateInfo = StateInfo or {}
end
function LogicInheritWardrobe:GetXSuitStateInfo()
  return self.XSuitStateInfo
end
function LogicInheritWardrobe:ChangeXSuitStateInfo(key, value)
  self.XSuitStateInfo = self.XSuitStateInfo or {}
  self.XSuitStateInfo[key] = value
end
function LogicInheritWardrobe:CacheDragonBallUnlockState(state)
  self.dragon_ball_unlock_state = state or false
end
function LogicInheritWardrobe:GetDragonBallUnlockState()
  return self.dragon_ball_unlock_state
end
function LogicInheritWardrobe:ClearInheritData()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
  DataEntity:ClearData()
  self:DefineAndResetData()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLEAR_INHERIT_DATA)
end
function LogicInheritWardrobe:GetArrayHallDepotItemInfo()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
  return DataEntity:GetData()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicInheritWardrobe = class(CModuleBase, nil, LogicInheritWardrobe)
return CLogicInheritWardrobe