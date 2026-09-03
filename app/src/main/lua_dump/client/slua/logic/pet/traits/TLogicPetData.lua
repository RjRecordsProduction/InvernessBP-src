local EPetFeatureType = import("EPetFeatureType")
local PetConfig = require("client.slua.logic.pet.pet_config")
local LogicPetData = {}
local Trait = require("common.trait")
local TLogicPetData = Trait(Trait.TraitPrototype, nil, LogicPetData)
local local local 
function LogicPetData:GetOwnedPetItemIDByPetID(pet_id)
  for k, v in pairs(self.MyPetInfo.pets) do
    if v.id == pet_id then
      return v.id
    end
  end
  return nil
end
function LogicPetData:IsPetTimeLimitedOwning(pet_item_id)
  if self.MyPetInfo and self.MyPetInfo.pets then
    if self.MyPetInfo.pets[pet_item_id] and self.MyPetInfo.pets[pet_item_id].expire_time then
      return true, self.MyPetInfo.pets[pet_item_id].expire_time
    end
  else
    log_warning("LogicPetData.MyPetInfo or self.MyPetInfo.pets is nil")
    self:get_pet_data_req()
  end
  return false, nil
end
function LogicPetData:IsDressTimeLimitedOwning(dress_item_id)
  if self.MyPetInfo and self.MyPetInfo.dresses then
    if self.MyPetInfo.dresses[dress_item_id] and self.MyPetInfo.dresses[dress_item_id].expire_time then
      return true, self.MyPetInfo.dresses[dress_item_id].expire_time
    end
  else
    log_warning("self.MyPetInfo or self.MyPetInfo.dresses is nil")
    self:get_pet_data_req()
  end
  return false, nil
end
function LogicPetData:GetExpiredPetsOnline(data, expiredPets, expiredDresses)
  local bHasPetExpired = false
  local bHasDressExpired = false
  if self.MyPetInfo and self.MyPetInfo.pets then
    for k, v in pairs(self.MyPetInfo.pets) do
      if not data.pets or not data.pets[k] then
        expiredPets[k] = true
      end
    end
    if next(expiredPets) then
      bHasPetExpired = true
      log_tree("LogicPetData:GetExpiredPetsOnline: Expired Pets:", expiredPets)
    end
  end
  if self.MyPetInfo and self.MyPetInfo.dresses then
    for k, v in pairs(self.MyPetInfo.dresses) do
      if not data.dresses or not data.dresses[k] then
        expiredDresses[k] = true
      end
    end
    if next(expiredDresses) then
      bHasDressExpired = true
      log_tree("LogicPetData:GetExpiredPetsOnline: Expired Dresses:", expiredDresses)
    end
  end
  return bHasPetExpired, bHasDressExpired
end
function LogicPetData:HavePermanentPet()
  if not self.MyPetInfo or not self.MyPetInfo.pets then
    return false
  end
  for _, v in pairs(self.MyPetInfo.pets) do
    if not v.expire_time then
      return true
    end
  end
  return false
end
function LogicPetData:HasPet(pet_id_both)
  if self.MyPetInfo == nil or self.MyPetInfo.pets == nil then
    log(bWriteLog and "LogicPetData:HasPet self.MyPetInfo = nil")
    return false
  end
  if self.MyPetInfo.pet_cnt == nil or self.MyPetInfo.pet_cnt == 0 then
    local cnt = 0
    for _, v in pairs(self.MyPetInfo.pets) do
      cnt = cnt + 1
    end
    self.MyPetInfo.pet_    if self.MyPetInfo.pet_cnt == 0 then
      return false
    end
  end
  for i, v in pairs(self.MyPetInfo.pets) do
    if pet_id_both == v.id or pet_id_both == v.id then
      return true
    end
  end
  return false
end
function LogicPetData:IsPetFrozen(pet_id_both)
  if self.MyPetInfo == nil or self.MyPetInfo.pets == nil then
    log(bWriteLog and "LogicPetData:IsPetFrozen self.MyPetInfo = nil")
    return false
  end
  log(bWriteLog and string.format("[lesterzy] LogicPetData:IsPetFrozen pet_id_both %s", pet_id_both))
  if self.MyPetInfo.pets[pet_id_both] == nil then
    return false
  end
  return self.MyPetInfo.pets[pet_id_both].locked
end
function LogicPetData:HasPetIncludeInherit(PetInsID)
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  return self:HasPet(PetInsID) or LogicInheritWardrobe:HasPet(PetInsID)
end
function LogicPetData:HasPetPermanently(pet_id_both)
  local TimeLimitedOwning, _ = self:IsPetTimeLimitedOwning(pet_id_both)
  return self:HasPet(pet_id_both) and not TimeLimitedOwning
end
function LogicPetData:HasPetDressPermanently(dress_id_both)
  local TimeLimitedOwning, _ = self:IsDressTimeLimitedOwning(dress_id_both)
  return self:_HasPetDress(self.MyPetInfo, dress_id_both) and not TimeLimitedOwning
end
function LogicPetData:HasValidPetDress(dress_id_both)
  local TimeLimitedOwning, _ = self:IsDressTimeLimitedOwning(dress_id_both)
  return self:_HasPetDress(self.MyPetInfo, dress_id_both)
end
function LogicPetData:HasPetActionDress(PetInsID, action_id)
  if not self.ActionDressMap then
    self:GetActionDressMap()
  end
  local dresses = self.ActionDressMap[action_id]
  if not dresses or not next(dresses) then
    return false, 0
  end
  local PetInfo = self:GetPetInfo(PetInsID)
  for i, v in ipairs(dresses) do
    if self:_HasPetDress(PetInfo, v) then
      return true, v
    end
  end
  return false, 0
end
function LogicPetData:IsPetDressFrozen(petInsID, dress_item_id)
  local petInfo = self:GetPetInfo(petInsID)
  return petInfo.dresses[dress_item_id].locked
end
function LogicPetData:HasPetDress(PetInsID, dress_item_id)
  return self:_HasPetDress(self:GetPetInfo(PetInsID), dress_item_id)
end
function LogicPetData:_HasPetDress(PetInfo, dress_item_id)
  if PetInfo == nil then
    log(bWriteLog and "LogicPetData:HasPetDress PetInfo = nil")
    return false
  end
  if PetInfo.dresses == nil then
    return false
  end
  if PetInfo.dresses[dress_item_id] ~= nil then
    return true
  end
  return false
end
function LogicPetData:IsInDress(PetInsID, dress_item_id)
  local PetID, Source = self:ConvertToPetID(PetInsID)
  local PetInfo = self:GetPetInfo(PetInsID)
  if PetInfo == nil then
    log(bWriteLog and "LogicPetData:IsInDress PetInfo = nil")
    return false
  end
  if PetInfo.pets[PetID] == nil then
    return false
  end
  if PetInfo.pets[PetID].dress == nil then
    return false
  end
  if PetInfo.pets[PetID].dress[dress_item_id] ~= nil then
    return true
  end
  return false
end
function LogicPetData:IsPetEquip(PetInsID)
  if self.MyPetInfo == nil then
    log(bWriteLog and "LogicPetData:IsPetEquip self.MyPetInfo = nil")
    return false
  end
  return self.MyPetInfo.equip_pet_ins_id == PetInsID
end
function LogicPetData:GetEquipedPetInsID()
  if self.MyPetInfo == nil then
    return 0
  end
  return self.MyPetInfo.equip_pet_ins_id or 0
end
function LogicPetData:GetEquipedPetItemID()
  local InsID = self:GetEquipedPetInsID()
  local PetID, _ = self:ConvertToPetID(InsID) or 0
  return PetID
end
function LogicPetData:HasEquipedPet()
  local equipedPet = self:GetEquipedPetInsID()
  if equipedPet ~= 0 then
    return equipedPet
  end
  return false
end
function LogicPetData:GetPetDataIncludeInherit()
  local PetDataMap = {}
  if self.MyPetInfo and self.MyPetInfo.pets then
    for key, value in pairs(self.MyPetInfo.pets) do
      PetDataMap[value.ins_id] = value
    end
  end
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  if LogicInheritWardrobe:GetInheritPetData() and LogicInheritWardrobe:GetInheritPetData().pets then
    for key, value in pairs(LogicInheritWardrobe:GetInheritPetData().pets) do
      PetDataMap[value.ins_id] = value
    end
  end
  return PetDataMap
end
function LogicPetData:IsInheritPet(InsID)
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  local Data = LogicInheritWardrobe:GetPetDataByInsID(InsID)
  if Data then
    return true
  end
  return false
end
function LogicPetData:GetCurLevelExp(pet_item_id, exp)
  if exp < 0 then
    return 0
  end
  local PetLevelCfg = self:GetPetLevelCfg()
  for k, v in ipairs(PetLevelCfg) do
    if v.PetID == pet_item_id then
      if exp >= v.PetNeedExp then
        exp = exp - v.PetNeedExp
      else
        return exp
      end
    end
  end
  return exp
end
function LogicPetData:GetMyPetLevel(pet_item_id)
  local level = 1
  local petData = self:GetPetDataByPetItemID(pet_item_id)
  if petData == nil then
    return level
  end
  level = self:GetPetLevelByExp(pet_item_id, petData.exp)
  return level
end
function LogicPetData:GetPetLevelByExp(pet_item_id, exp)
  local pet_id = pet_item_id
  local level = 1
  exp = exp or 0
  if exp < 0 then
    return level
  end
  local PetLevelCfg = self:GetPetLevelCfg()
  for _, v in ipairs(PetLevelCfg) do
    if v.PetID == pet_id then
      level = v.PetLevel
      if exp >= v.PetNeedExp then
        exp = exp - v.PetNeedExp
      else
        return level
      end
    end
  end
  return level
end
function LogicPetData:GetAddExpByFoodID(foodID)
  local FoodCfg = self:GetFoodCfg()
  for _, v in pairs(FoodCfg) do
    if foodID == v.FoodID then
      return v.FoodAddExp
    end
  end
  return 0
end
function LogicPetData:GetCurDressItems(pet_item_id)
  if self.MyPetInfo.pets and self.MyPetInfo.pets[pet_item_id] == nil then
    return nil
  end
  if self.MyPetInfo.pets and self.MyPetInfo.pets[pet_item_id].dress == nil then
    return nil
  end
  if self.MyPetInfo.pets and next(self.MyPetInfo.pets[pet_item_id].dress) ~= nil then
    return self.MyPetInfo.pets[pet_item_id].dress
  end
  return nil
end
function LogicPetData:GetCurDressItemsByInsID(PetInsID)
  local PetID, Source = self:ConvertToPetID(PetInsID)
  if Source == EPetSource.Inherit then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    local Data = LogicInheritWardrobe:GetPetDataByInsID(PetInsID)
    if Data then
      return Data.dress
    end
  else
    return self:GetCurDressItems(PetID)
  end
end
function LogicPetData:IsActionUnLock(PetInsID, petActionID)
  local PetID = self:ConvertToPetID(PetInsID)
  if self:HasPetIncludeInherit(PetInsID) then
    local petData = self:GetPetDataByInsID(PetInsID)
    local level = self:GetPetLevelByExp(PetID, petData.exp)
    local curPetLevelData = self:GetPetLevelItemCfg(PetID, level)
    local StringUtil = require("common.string_util")
    local allAction = StringUtil.Split(curPetLevelData.AllAction, "|")
    for _, v in pairs(allAction) do
      if tostring(petActionID) == v then
        return true
      end
    end
    local hasDress, DressItemID = self:HasPetActionDress(PetInsID, petActionID)
    if hasDress then
      return true
    end
  end
  return false
end
function LogicPetData:GetPetExpireTime(pet_item_id)
  if self.MyPetInfo == nil then
    log(bWriteLog and "LogicPetData:GetPetExpireTime self.MyPetInfo = nil")
    return nil
  end
  if self.MyPetInfo.pets == nil then
    return nil
  end
  if self.MyPetInfo.pets[pet_item_id] == nil then
    return nil
  end
  return self.MyPetInfo.pets[pet_item_id].expire_time
end
function LogicPetData:GetPetInfo(PetInsID)
  local PetID, Source = self:ConvertToPetID(PetInsID)
  local PetInfo
  if Source == EPetSource.Inherit then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    PetInfo = LogicInheritWardrobe:GetInheritPetData()
  else
    PetInfo = self.MyPetInfo
  end
  return PetInfo
end
function LogicPetData:GetDressExpireTime(PetInsID, dress_item_id)
  local PetInfo = self:GetPetInfo(PetInsID)
  if PetInfo == nil then
    log(bWriteLog and "LogicPetData:GetDressExpireTime PetInfo = nil")
    return nil
  end
  if PetInfo.dresses == nil then
    return nil
  end
  if PetInfo.dresses[dress_item_id] == nil then
    return nil
  end
  return PetInfo.dresses[dress_item_id].expire_time
end
function LogicPetData:GetPetDataByPetItemID(pet_item_id)
  local petData
  if self.MyPetInfo == nil then
    log(bWriteLog and "LogicPetData:GetPetDataByPetItemID self.MyPetInfo = nil")
    self:get_pet_data_req()
    return nil
  end
  if self.MyPetInfo.pets == nil then
    self:get_pet_data_req()
    log(bWriteLog and "LogicPetData:GetPetDataByPetItemID self.MyPetInfo.pets = nil")
    return nil
  end
  petData = self.MyPetInfo.pets[pet_item_id]
  if not petData then
    return nil
  end
  if not petData.dress then
    petData.dress = {}
  end
  return petData
end
function LogicPetData:GetPetDataByInsID(PetInsID)
  if not PetInsID then
    return
  end
  local PetID, Source = self:ConvertToPetID(PetInsID)
  local data
  if Source == EPetSource.Inherit then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    data = LogicInheritWardrobe:GetPetDataByInsID(PetInsID)
  else
    data = self:GetPetDataByPetItemID(PetID)
  end
  return data
end
function LogicPetData:GetPetNames()
  if not self.PetNameMap then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    self.PetNameMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetNames)
    if not self.PetNameMap then
      self.PetNameMap = {}
      if not self.PetNameMap[tostring(DataMgr.roleData.uid)] then
        self.PetNameMap[tostring(DataMgr.roleData.uid)] = {}
      end
    end
  end
  return self.PetNameMap
end
function LogicPetData:UpdatePetNames()
  self:GetPetNames()
  local PetData = self:GetPetDataIncludeInherit()
  if PetData then
    for InsID, v in pairs(PetData) do
      if v.name then
        if not self.PetNameMap[tostring(DataMgr.roleData.uid)] then
          self.PetNameMap[tostring(DataMgr.roleData.uid)] = {}
        end
        self.PetNameMap[tostring(DataMgr.roleData.uid)][tostring(InsID)] = v.name
      end
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.PetNameMap, PlayerPrefsSystem.ePlayerPrefsType.ePetNames)
end
function LogicPetData:GetPetNameLocal(PetInsID)
  self:GetPetNames()
  if not self.PetNameMap[tostring(DataMgr.roleData.uid)] then
    self.PetNameMap[tostring(DataMgr.roleData.uid)] = {}
  end
  return self.PetNameMap[tostring(DataMgr.roleData.uid)][tostring(PetInsID)]
end
function LogicPetData:OnGetPetDressTimeUrl(data)
  data = data or {}
  local TimeUtil = require("client.common.time_util")
  for k, v in pairs(data) do
    local sJumpUrl = v.JumpUrl
    local sLaunchTime = v.LaunchTime
    local sOpenTime = v.OpenTime
    local sEndTime = v.EndTime
    if GlobalData.IsJapanOrKorea() then
      local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
      if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
        sJumpUrl = v.JumpUrl_JP ~= "" and v.JumpUrl_JP or sJumpUrl
        sLaunchTime = v.LaunchTime_JP ~= "" and v.LaunchTime_JP or sLaunchTime
        sOpenTime = v.OpenTime_JP ~= "" and v.OpenTime_JP or sOpenTime
        if v.EndTime_JP ~= "" then
          sEndTime = v.EndTime_JP or sEndTime
        end
      else
        sJumpUrl = v.JumpUrl_KR ~= "" and v.JumpUrl_KR or sJumpUrl
        sLaunchTime = v.LaunchTime_KR ~= "" and v.LaunchTime_KR or sLaunchTime
        sOpenTime = v.OpenTime_KR ~= "" and v.OpenTime_KR or sOpenTime
        sEndTime = v.EndTime_KR ~= "" and v.EndTime_KR or sEndTime
      end
    end
    local tTempData = {
      launch_time = TimeUtil.TimeStringToUnixstamp(sLaunchTime),
      open_time = TimeUtil.TimeStringToUnixstamp(sOpenTime),
      end_time = TimeUtil.TimeStringToUnixstamp(sEndTime),
      jump_url = sJumpUrl
    }
    self.DressTimeUrl[k] = tTempData
  end
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_TIME_INFO_UPDATE)
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_CHANGE, self.DressTimeUrl)
end
function LogicPetData:UpdateCarryPetInfo()
  local MyPets = self.MyPetInfo.pets
  self._CarryPets = {}
  self._CarryCount = 0
  if not MyPets then
    return
  end
  local CarryPets = self._CarryPets
  local MaxCarryCount = self:GetMaxCarryPetCount()
  local InsertToCarryPets = function(PetsList)
    for id, v in pairs(PetsList) do
      if v.carry == 1 then
        self._CarryCount = self._CarryCount + 1
        CarryPets[self._CarryCount] = v.ins_id
        if self._CarryCount >= MaxCarryCount then
          break
        end
      end
    end
  end
  InsertToCarryPets(MyPets)
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  local InheritPetData = LogicInheritWardrobe:GetInheritPetData()
  if InheritPetData and InheritPetData.pets then
    InsertToCarryPets(InheritPetData.pets)
  end
  table.sort(self._CarryPets, function(a, b)
    return b < a
  end)
  if MaxCarryCount > self._CarryCount then
    for i = self._CarryCount + 1, MaxCarryCount do
      CarryPets[i] = 0
    end
  end
end
function LogicPetData:GetCurrentCarryPets()
  return self._CarryPets
end
function LogicPetData:GetCurrentCarryCount()
  return self._CarryCount or 0
end
function LogicPetData:GetOwnedPetList(bExcludeEquipPet)
  local OwnedPetList = {}
  if not self.MyPetInfo or not self.MyPetInfo.pets then
    return OwnedPetList
  end
  for k, v in pairs(self.MyPetInfo.pets) do
    if not bExcludeEquipPet or not self:IsPetEquip(v.ins_id) then
      OwnedPetList[#OwnedPetList + 1] = v
    end
  end
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  if LogicInheritWardrobe:GetInheritPetData() and LogicInheritWardrobe:GetInheritPetData().pets then
    for k, v in pairs(LogicInheritWardrobe:GetInheritPetData().pets) do
      if v.ins_id and v.ins_id > 0 and (not bExcludeEquipPet or not self:IsPetEquip(v.ins_id)) then
        OwnedPetList[#OwnedPetList + 1] = v
      end
    end
  end
  table.sort(OwnedPetList, function(a, b)
    local CarryWeightA = 0
    local CarryWeightB = 0
    for i = 1, self._CarryCount do
      if self._CarryPets[i] == a.ins_id then
        CarryWeightA = 1
      end
      if self._CarryPets[i] == b.ins_id then
        CarryWeightB = 1
      end
    end
    if CarryWeightA == CarryWeightB then
      if a.id == b.id then
        local PetID1, Source1 = self:ConvertToPetID(a.ins_id)
        local PetID2, Source2 = self:ConvertToPetID(b.ins_id)
        return Source1 < Source2
      end
      return a.id > b.id
    end
    return CarryWeightA > CarryWeightB
  end)
  return OwnedPetList
end
function LogicPetData:GetPetExpirationStateByPetItemID(pet_item_id)
  local pet_id = pet_item_id
  if self.PetExpirationState and next(self.PetExpirationState) then
    return self.PetExpirationState[pet_id]
  else
    self:UpdatePetExpirationState()
    return self.PetExpirationState[pet_id]
  end
end
function LogicPetData:ConvertServerInfoToPetFeatureData(PetServerInfo)
  if not PetServerInfo then
    return nil
  end
  local PetFeatureData = {
    [EPetFeatureType.Color] = PetServerInfo.color or 1,
    [EPetFeatureType.Enlarge] = PetServerInfo.change or 0
  }
  return PetFeatureData
end
function LogicPetData:HasExpandSlotPriv()
  return self.bHasSlotExpandPriv
end
function LogicPetData:GetMaxCarryPetCount()
  local maxCount = PetConfig.CarryPets.MAX_CARRY_COUNT_NORMAL
  if self.bHasSlotExpandPriv then
    maxCount = maxCount + 2
  end
  if UnknowPassSystem.IsBuyElite and UnknowPassSystem.PassType == 2 and UnknowPassSystem.Season >= 59 then
    maxCount = maxCount + 1
  end
  return maxCount
end
function LogicPetData:GetSharedPetIDList(bFillEmpty)
  local result = {}
  local realCount = 0
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if logic_share_bag_privilege_util:IsMyPetShared() then
    local equipPetInsId = self:GetEquipedPetInsID()
    local equipPetID, Source = self:ConvertToPetID(equipPetInsId)
    if equipPetID and equipPetID ~= 0 and Source == EPetSource.Self then
      result[#result + 1] = equipPetID
    end
    local carryPets = self:GetCurrentCarryPets()
    if carryPets and next(carryPets) then
      for _, v in pairs(carryPets) do
        local PetID, Source = self:ConvertToPetID(v)
        if PetID and PetID ~= 0 and Source == EPetSource.Self then
          result[#result + 1] = PetID
        end
      end
    end
  end
  realCount = #result
  if bFillEmpty then
    local currentCount = #result
    local maxCount = self:GetMaxCarryPetCount() + 1
    if currentCount < maxCount then
      for i = currentCount + 1, maxCount do
        result[#result + 1] = 0
      end
    end
  end
  return result, realCount
end
function LogicPetData:GetOwnEffectMap()
  return self._ownEffectMap
end
function LogicPetData:GetCurrentEquipEffect()
  return self._equipEffect or 0
end
return TLogicPetData