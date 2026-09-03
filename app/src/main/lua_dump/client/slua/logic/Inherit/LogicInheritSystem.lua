local LogicInheritSystem = {}
function LogicInheritSystem:DefineAndResetData()
  self.IsWaitingToOpenUI = false
  self.WaitingToClearData = false
end
function LogicInheritSystem:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RECEIVE_INHERIT_DATA, self.OnReceiveInheritData, self)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  local InheritData = collect_inherit_data:GetInheritData(false)
  self:AddDataListener(InheritData, "state", self.OnStateChange, self)
end
function LogicInheritSystem:OnStateChange(OldValue, Value)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  log(bWriteLog and "LogicInheritSystem:OnStateChange OldValue:" .. tostring(OldValue) .. " NewValue:" .. tostring(Value))
  if OldValue == collect_inherit_data:GetStates().using and Value ~= collect_inherit_data:GetStates().using then
    log(bWriteLog and "LogicInheritSystem:OnStateChange Break")
    LobbySystem.roleData.has_inherit_data = false
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BREAK_INHERIT)
  elseif OldValue ~= collect_inherit_data:GetStates().using and Value == collect_inherit_data:GetStates().using then
    log(bWriteLog and "LogicInheritSystem:OnStateChange Create")
    LobbySystem.roleData.has_inherit_data = true
  end
end
function LogicInheritSystem:OnReceiveInheritData()
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  if self.IsWaitingToOpenUI and LogicInheritWardrobe.bBackendIsOK then
    self.IsWaitingToOpenUI = false
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    WardrobeLogicManager:Enter(nil, nil, nil, wardrobe_macro.EWardrobeEditMode.Inherit)
  end
end
function LogicInheritSystem:EnterInheritWardrobe()
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  if not LogicInheritWardrobe.bBackendIsOK then
    self.IsWaitingToOpenUI = true
    local InheritHandle = require("client.network.Protocol.InheritHandle")
    InheritHandle.send_get_inherit_data_req()
    return
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  WardrobeLogicManager:Enter(nil, nil, nil, wardrobe_macro.EWardrobeEditMode.Inherit)
end
function LogicInheritSystem:ClearInheritItem()
  self.WaitingToClearData = true
  self:PutOffInhertiWear()
  self:PutOffInheritVehicle()
  self:PutOffInheritWeapon()
  self:PutOffInheritPet()
  self:PutOffWeaponPandent()
  self:UpdateWearInfo()
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  LogicInheritWardrobe:ClearInheritData()
  self.WaitingToClearData = false
end
function LogicInheritSystem:PutOffInhertiWear()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local putOff = {}
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:UpdateInvalidWearInfo(putOff)
  local itemData
  for _, v in ipairs(putOff) do
    itemData = wardrobe_data:GetHallDepotItemDataByInsID(v)
    if itemData ~= nil then
      logic_wardrobe_avatar:AvatarChange(itemData.resID, false)
    end
  end
end
function LogicInheritSystem:PutOffInheritVehicle()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if wardrobe_data:GetItemSource(DataMgr.vst_skin) ~= EWardrobeDataSource.InheritWardrobe then
    return
  end
  DataMgr.vst_skin = nil
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  ThemeVehicleManager:ShowThemeVehicle()
end
function LogicInheritSystem:UpdateWearInfo()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
  end, {bForceReq = true}, Enum_AvatarShowSource.WardrobeLogic)
end
function LogicInheritSystem:PutOffInheritWeapon()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if wardrobe_data:GetItemSource(DataMgr.Weapon_Skin_InsID) ~= EWardrobeDataSource.InheritWardrobe then
    return
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.UnEquipWeapon(DataMgr.roleData.uid)
  DataMgr.InitWeaponData(0, 0, 0)
end
function LogicInheritSystem:PutOffWeaponPandent()
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  logic_weapon_pendant:ProcessInvalidPendant()
end
function LogicInheritSystem:PutOffInheritPet()
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local _, Source = logic_pet:ConvertToPetID(logic_pet.MyPetInfo.equip_pet_ins_id)
  if Source ~= EPetSource.Inherit then
    return
  end
  logic_pet.MyPetInfo.equip_pet_ins_id = 0
  local PetData = logic_pet:FormatPetDataByServerInfo(DataMgr.roleData.uid, nil)
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicInheritSystem = class(CModuleBase, nil, LogicInheritSystem)
return CLogicInheritSystem