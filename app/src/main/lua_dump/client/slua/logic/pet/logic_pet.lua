local TimeTicker = require("common.time_ticker")
local PetConfig = require("client.slua.logic.pet.pet_config")
local logic_pet = {}
local Trait = require("common.trait")
local ModuleBase = require("client.module_framework.ModuleBase")
local Traits = {
  require("client.slua.logic.pet.traits.TLogicPetCfg"),
  require("client.slua.logic.pet.traits.TLogicPetData"),
  require("client.slua.logic.pet.traits.TLogicPetNetUtil")
}
local Clogic_pet = Trait.TraitClass(ModuleBase, nil, logic_pet, Traits)
local 
function logic_pet:DefineAndResetData()
  log(bWriteLog and "logic_pet:DefineAndResetData.")
  self.PetDataInited = false
  self.RetryGetDataTimes = 0
  self.PetSystemClosed = false
  self.PetCfg = nil
  self.PetLevelCfg = nil
  self.PetActionCfg = nil
  self.FoodCfg = nil
  self.PetDressCfg = nil
  self.ActionDressMap = nil
  self.DressActionMap = nil
  self.PetActionMap = nil
  self.PetNameMap = nil
  self.DressPetMap = nil
  self.NewDresses = {}
  self.DressTimeUrl = {}
  self.MyPetInfo = {}
  self.PetDressShopData = {}
  self.bShowEquipTips = false
  self.isReadyToShowPetMain = false
  self.PetTimeUrl = {}
  self.state = nil
  self.PetDependResourceMap = nil
  self.orderPetList = nil
  self.PetExpirationState = nil
  self.Enum_PetExpirationState = {
    EnumExpired = 1,
    EnumPermanentOwning = 2,
    EnumTimeLimitedOwning = 3,
    EnumNeverOwned = 4
  }
  self.Enum_CfgType = {
    Pet = 1,
    Dress = 2,
    Action = 3
  }
  self.Enum_AccessType = {EnumPet = 1, EnumFood = 2}
  self.Enum_PetJumpType = {
    EnumJumpToStore = 1,
    EnumJumpToSupply = 2,
    EnumJumpToPass = 3
  }
  self.Enum_PetNoticeType = {
    EnumPetEquip = 1,
    EnumPetUnequip = 2,
    EnumPetLevelUp = 3,
    EnumPetPlayAction = 4,
    EnumPetRename = 5,
    EnumPetDress = 7,
    EnumPetUndress = 8,
    EnumPetColorChange = 9
  }
  self.Enum_TagType = {EnumAction = 1, EnumDress = 2}
  self.desiredShowPetID = 0
  self.curFoodId = 0
  self._CarryPets = {}
  self._CarryCount = 0
  self.ENUM_PetShowType = {
    Avatar = 1,
    Workshop = 2,
    Preview = 3
  }
  self.bHasSlotExpandPriv = false
  self.ItemID2PetIDMap = nil
  self.PetCfgInited = false
end
function logic_pet:OnLogOut()
  self.PetCfg = nil
  self.PetLevelCfg = nil
  self.PetActionCfg = nil
  self.DressActionMap = nil
  self.FoodCfg = nil
  self.MyPetInfo = {}
  self.bShowEquipTips = false
  self.isReadyToShowPetMain = false
  self.PetDataInited = false
  self.bHasSlotExpandPriv = false
end
function logic_pet:OnLogin(bReLogin)
  log(bWriteLog and string.format("logic_pet:OnLogin. bReLogin=%s", tostring(bReLogin)))
  self:GetPetDressTimeUrlReq()
end
function logic_pet:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self.PetCfg = nil
    self.PetLevelCfg = nil
    self.DressActionMap = nil
    self.FoodCfg = nil
  end
end
function logic_pet:GetExpiredPetsOffline(newPetData, expiredPets, expiredDresses)
  local bHasPetExpired = false
  local bHasDressExpired = false
  newPetData = newPetData or self.MyPetInfo
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local petCfgs = CDataTable.GetTable("PetTable")
  local dressCfgs = CDataTable.GetTable("PetDressTable")
  local myPets = newPetData.pets
  local myDresses = newPetData.dresses
  local PetLastOnlineOwnershipState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetLastOnlineOwnership)
  if type(PetLastOnlineOwnershipState) ~= "table" then
    PetLastOnlineOwnershipState = {}
  end
  if PetLastOnlineOwnershipState == nil or not next(PetLastOnlineOwnershipState) then
    PetLastOnlineOwnershipState = {}
    for k, v in pairs(myPets) do
      local petID = k
      PetLastOnlineOwnershipState[tostring(petID)] = true
    end
    for k, v in pairs(myDresses) do
      local dressID = k
      PetLastOnlineOwnershipState[tostring(dressID)] = true
    end
  end
  if petCfgs then
    for k, v in pairs(petCfgs) do
      if v.PetID ~= 50000 and PetLastOnlineOwnershipState[tostring(v.PetID)] and not myPets[v.PetID] then
        expiredPets[v.PetID] = true
        bHasPetExpired = true
      end
    end
  end
  for k, v in pairs(dressCfgs) do
    if v.PetID ~= 50000 and PetLastOnlineOwnershipState[tostring(v.DressItemID)] and not myDresses[v.DressItemID] then
      expiredDresses[v.PetID] = true
      bHasDressExpired = true
    end
  end
  return bHasPetExpired, bHasDressExpired
end
function logic_pet:GetMyPetData()
  return self.MyPetInfo and self.MyPetInfo.pets or {}
end
function logic_pet:UpdatePetExpirationState(newPetData)
  newPetData = newPetData or self.MyPetInfo
  self.PetExpirationState = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local petCfgs = CDataTable.GetTable("PetTable")
  local dressCfgs = CDataTable.GetTable("PetDressTable")
  local myPets = newPetData.pets
  local myDresses = newPetData.dresses
  local PetOwnershipState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetOwnershipState)
  local PetLastOnlineOwnershipState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetLastOnlineOwnership)
  if PetOwnershipState == nil then
    PetOwnershipState = {}
    for k, v in pairs(myPets) do
      PetOwnershipState[tostring(k)] = true
    end
    for k, v in pairs(myDresses) do
      PetOwnershipState[tostring(k)] = true
    end
  end
  if PetLastOnlineOwnershipState == nil then
    PetLastOnlineOwnershipState = {}
    for k, v in pairs(myPets) do
      PetLastOnlineOwnershipState[tostring(k)] = true
    end
    for k, v in pairs(myDresses) do
      PetLastOnlineOwnershipState[tostring(k)] = true
    end
  end
  if petCfgs then
    for k, v in pairs(petCfgs) do
      if myPets[v.PetID] then
        PetOwnershipState[tostring(v.PetID)] = true
        PetLastOnlineOwnershipState[tostring(v.PetID)] = true
        local bIsPetTimeLimited = newPetData.pets[v.PetID] and newPetData.pets[v.PetID].expire_time
        local expire_time = newPetData.pets[v.PetID].expire_time
        if bIsPetTimeLimited then
          self.PetExpirationState[v.PetID] = self.Enum_PetExpirationState.EnumTimeLimitedOwning
        else
          self.PetExpirationState[v.PetID] = self.Enum_PetExpirationState.EnumPermanentOwning
        end
      elseif PetOwnershipState[tostring(v.PetID)] and not myPets[v.PetID] then
        self.PetExpirationState[v.PetID] = self.Enum_PetExpirationState.EnumExpired
        PetLastOnlineOwnershipState[tostring(v.PetID)] = false
      elseif not PetOwnershipState[tostring(v.PetID)] and not myPets[v.PetID] then
        self.PetExpirationState[v.PetID] = self.Enum_PetExpirationState.EnumNeverOwned
        PetLastOnlineOwnershipState[tostring(v.PetID)] = false
      end
    end
  end
  for k, v in pairs(dressCfgs) do
    if myDresses[v.DressItemID] then
      PetOwnershipState[tostring(v.DressItemID)] = true
      PetLastOnlineOwnershipState[tostring(v.DressItemID)] = true
      local bIsDressTimeLimited = myDresses[v.DressItemID] and myDresses[v.DressItemID].expire_time
      local expire_time = myDresses[v.DressItemID].expire_time
      if bIsDressTimeLimited then
        self.PetExpirationState[v.DressItemID] = self.Enum_PetExpirationState.EnumTimeLimitedOwning
      else
        self.PetExpirationState[v.DressItemID] = self.Enum_PetExpirationState.EnumPermanentOwning
      end
    elseif PetOwnershipState[tostring(v.DressItemID)] and not myDresses[v.DressItemID] then
      PetLastOnlineOwnershipState[tostring(v.DressItemID)] = false
      self.PetExpirationState[v.DressItemID] = self.Enum_PetExpirationState.EnumExpired
    elseif not PetOwnershipState[tostring(v.DressItemID)] and not myDresses[v.DressItemID] then
      self.PetExpirationState[v.DressItemID] = self.Enum_PetExpirationState.EnumNeverOwned
      PetLastOnlineOwnershipState[tostring(v.DressItemID)] = false
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(PetOwnershipState, PlayerPrefsSystem.ePlayerPrefsType.ePetOwnershipState)
  PlayerPrefsSystem.SaveTableToFile_N(PetLastOnlineOwnershipState, PlayerPrefsSystem.ePlayerPrefsType.ePetLastOnlineOwnership)
  return self.PetExpirationState
end
function logic_pet:GetDownloadList(pet_id_or_dress_id)
  local IsPet, PetID = self:IsPetOrDress(pet_id_or_dress_id)
  local DownloadList = {}
  if IsPet then
    table.insert(DownloadList, PetID)
  else
    table.insert(DownloadList, PetID)
    table.insert(DownloadList, pet_id_or_dress_id)
  end
  return DownloadList
end
function logic_pet:GetJumpPetID(pet_id_or_dress_id)
  local IsPet, Id = self:IsPetOrDress(pet_id_or_dress_id)
  if IsPet then
    return pet_id_or_dress_id
  else
    local DressPetMap = self:GetDressPetMap()
    return DressPetMap[pet_id_or_dress_id]
  end
end
function logic_pet:GetShopData(dress_item_id)
  if self.PetDressShopData == nil or next(self.PetDressShopData) == nil then
    return nil
  end
  local shopID = 0
  local data = {}
  for i, v in pairs(self.PetDressShopData) do
    if dress_item_id == v.item_id then
      data = v
      shopID = i
    end
  end
  if shopID == 0 then
    return nil
  end
  local dressShopData = {}
  dressShopData[StoreConst.label_buy_param_id] = shopID
  dressShopData[StoreConst.label_buy_param_price_type] = data.money1_type
  dressShopData[StoreConst.label_buy_param_tab_id] = StoreConst.Page_New_ID_Other
  dressShopData[StoreConst.label_buy_param_sub_id] = StoreConst.subtype_new_other_pre
  dressShopData[StoreConst.label_buy_param_ver] = StoreConst.store_version
  dressShopData[StoreConst.label_buy_param_valid_hours] = 0
  dressShopData[StoreConst.label_buy_param_count] = 1
  return dressShopData
end
function logic_pet:GetShopID(dress_item_id)
  if self.PetDressShopData == nil or next(self.PetDressShopData) == nil then
    return 0
  end
  local shopID = 0
  for i, v in pairs(self.PetDressShopData) do
    if dress_item_id == v.item_id then
      shopID = i
    end
  end
  return shopID
end
function logic_pet:NeedShowExpirationNotice()
  return UIManager.IsUIShow(UIManager.UI_Config.pet_main)
end
function logic_pet:ValidateDataOutDated(data)
  if not data then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local bServerDataOutDated = false
  if data.pets then
    for k, v in pairs(data.pets) do
      if v.expire_time and now > v.expire_time then
        bServerDataOutDated = true
        break
      end
    end
  end
  if data.dresses then
    for k, v in pairs(data.dresses) do
      if v.expire_time and now > v.expire_time then
        bServerDataOutDated = true
        break
      end
    end
  end
  if bServerDataOutDated then
    log_error("[HZA] Server Responsed Dress Data Outdated")
    log_tree("[HZA] Current Local Pet Data is:", self.MyPetInfo)
    log_tree("[HZA] Latest Server Pet Data is:", data)
    TimeTicker.AddTimerOnce(1, function()
      self.RetryGetDataTimes = self.RetryGetDataTimes + 1
      if self.RetryGetDataTimes < 3 then
        self:get_pet_data_req()
      end
    end)
  else
    self.RetryGetDataTimes = 0
  end
  return bServerDataOutDated
end
function logic_pet:OpenPetWorkShop(PetInsIDOrDressID, extraParam)
  log(bWriteLog and "logic_pet OpenPetWorkShop PetInsIDOrDressID" .. tostring(PetInsIDOrDressID))
  log_tree("logic_pet OpenPetWorkShop extraParam", extraParam)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_PET_SWITCH, true) then
    log(bWriteLog and "VehicleCollectSystem OpenVehicleWorkShop CheckLobbyMenuOpen false")
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.pet_main, PetInsIDOrDressID, extraParam)
  return true
end
function logic_pet:CheckToShowPetMain()
  if self.isReadyToShowPetMain and (GameStatus.GetGameStatus() == GameStatus.Lobby or GameStatus.IsInLobbyOrMainCity()) and UIManager then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      if self:OpenPetWorkShop(self.desiredShowPetID) then
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
        self.desiredShowPetID = 0
      end
    end)
  end
  self.isReadyToShowPetMain = false
end
function logic_pet:AdjustPetDress(pet, needDress, curModelDress)
  if curModelDress == nil then
    if pet and needDress then
      for itemID, _ in pairs(needDress) do
        pet:PutOnOrPutOff(itemID, true)
      end
    end
  elseif pet and needDress and curModelDress then
    for _, itemID in pairs(curModelDress) do
      pet:PutOnOrPutOff(itemID)
    end
    local timer_tick = require("common.time_ticker")
    timer_tick.AddTimer(0, function()
      for itemID, _ in pairs(needDress) do
        pet:PutOnOrPutOff(itemID, true)
      end
    end)
  end
end
function logic_pet:IsPetLaunch(pet_item_id)
  local pet_id = pet_item_id
  if self.ClosePetShield then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if self.PetTimeUrl ~= nil and self.PetTimeUrl[pet_id] and self.PetTimeUrl[pet_id].launch_time then
    local launchTime = TimeUtil.TimeStringToUnixstamp(self.PetTimeUrl[pet_id].launch_time)
    local nowTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "[HZA] startTimeNum: " .. tostring(self.PetTimeUrl[pet_id].launch_time))
    if launchTime > nowTime then
      log(bWriteLog and string.format("[HZA] self.IsPetLaunch, pet item id: %d, pet id: %d, Not launch", pet_item_id, pet_id))
      return false
    else
      log(bWriteLog and string.format("[HZA] self.IsPetLaunch, pet item id: %d, launched", pet_item_id))
      return true
    end
  end
  return false
end
function logic_pet:IsPetStartAccessible(pet_item_id)
  local pet_id = pet_item_id
  local TimeUtil = require("client.common.time_util")
  if self.PetTimeUrl ~= nil and self.PetTimeUrl[pet_id] and self.PetTimeUrl[pet_id].start_time then
    local startTime = TimeUtil.TimeStringToUnixstamp(self.PetTimeUrl[pet_id].start_time)
    local nowTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "[HZA] startTimeNum: " .. tostring(self.PetTimeUrl[pet_id].start_time))
    if startTime > nowTime then
      log(bWriteLog and string.format("[HZA] self.IsPetStartAccessible, pet item id: %d, pet id: %d, Not open", pet_item_id, pet_id))
      return false
    else
      log(bWriteLog and string.format("[HZA] self.IsPetStartAccessible,  pet item id: %d, pet id: %d, Opened", pet_item_id, pet_id))
      return true
    end
  end
  return false
end
function logic_pet:IsPetInAccessibleTime(pet_item_id)
  local pet_id = pet_item_id
  local TimeUtil = require("client.common.time_util")
  if self.PetTimeUrl ~= nil and self.PetTimeUrl[pet_id] and self.PetTimeUrl[pet_id].start_time then
    local startTime = TimeUtil.TimeStringToUnixstamp(self.PetTimeUrl[pet_id].start_time)
    local endTime = TimeUtil.TimeStringToUnixstamp(self.PetTimeUrl[pet_id].end_time)
    log(bWriteLog and "[HZA] startTimeNum: " .. tostring(self.PetTimeUrl[pet_id].start_time))
    if TimeUtil.UnixTimeBetween(startTime, endTime) == 0 then
      log(bWriteLog and string.format("[HZA] self.IsPetInAccessibleTime, pet item id: %d, pet id: %d, Opened", pet_item_id, pet_id))
      return true
    else
      log(bWriteLog and string.format("[HZA] self.IsPetInAccessibleTime, pet item id: %d, pet id: %d, Not open", pet_item_id, pet_id))
      return false
    end
  end
  return false
end
function logic_pet:IsOutOfAccessibleEndTime(pet_item_id)
  local TimeUtil = require("client.common.time_util")
  local petTimeCfg = self.PetTimeUrl[pet_item_id]
  local petEndTime = 0
  log_tree("[HZA] self.PetTimeUrl", self.PetTimeUrl)
  if petTimeCfg and next(petTimeCfg) then
    petEndTime = TimeUtil.TimeStringToUnixstamp(petTimeCfg.end_time)
  else
    return false
  end
  local nowTimeNum = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[HZA] nowTimeNum: " .. tostring(nowTimeNum))
  log(bWriteLog and "[HZA] endTime: " .. tostring(petEndTime))
  if petEndTime < nowTimeNum then
    return true
  end
  return false
end
function logic_pet:GetPetState(PetInsID)
  if self:HasPetIncludeInherit(PetInsID) then
    if self:IsPetEquip(PetInsID) then
      self.state = 2
    else
      self.state = 0
    end
  elseif self:IsPetInAccessibleTime(PetInsID) then
    self.state = 1
  else
    self.state = 3
  end
  if self:IsPetFrozen(PetInsID) then
    self.state = 6
  end
  return self.state
end
function logic_pet:IsNotGyrfalcon(pet_item_id)
  if tonumber(pet_item_id) ~= 50001 then
    return true
  end
  return false
end
function logic_pet:HasJumpUrl(pet_item_id)
  return self.PetTimeUrl[pet_item_id] and self.PetTimeUrl[pet_item_id].url and self.PetTimeUrl[pet_item_id].url ~= ""
end
function logic_pet:IsMaxLevel(pet_item_id)
  local curLevel = self:GetMyPetLevel(pet_item_id)
  local cfg = self:GetPetItemCfgByPetItemID(pet_item_id)
  return curLevel == cfg.PetMaxLevel
end
function logic_pet:GetNextPetId(pet_item_id)
  local pet_id = pet_item_id
  if self.orderPetList and next(self.orderPetList) then
    local canReturn = false
    for key, value in pairs(self.orderPetList) do
      if canReturn then
        return value.id
      end
      if pet_id == value.id then
        canReturn = true
      end
    end
    if canReturn ~= false then
      return self.orderPetList[1].id
    else
      log_warning(bWriteLog and "[ZH] can not find pet_id:" .. tostring(pet_id))
      return nil
    end
  end
  log_warning(bWriteLog and "[ZH] self.orderPetList is nil")
  return nil
end
function logic_pet:GetPrePetId(pet_item_id)
  local pet_id = pet_item_id
  if self.orderPetList and next(self.orderPetList) ~= nil then
    local preValue = self.orderPetList[#self.orderPetList]
    for key, value in pairs(self.orderPetList) do
      if pet_id == value.id then
        return preValue.id
      end
      preValue = value
    end
    log_warning(bWriteLog and "[ZH] can not find pet_id" .. tostring(pet_id))
  end
  return nil
end
function logic_pet:GetOrderPetList()
  self:UpdateOrderPetList(self.PetTimeUrl)
  return self.orderPetList
end
function logic_pet:GetPetListIncludeInherit()
  local TableUtil = require("common.table_util")
  local PetList = TableUtil.DeepCloneTable(self:GetOrderPetList())
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  local GetIndex = function(PetID)
    if self.PetTimeUrl and self.PetTimeUrl[PetID] then
      return self.PetTimeUrl[PetID].index
    end
    return 1
  end
  local InheritPetList = LogicInheritWardrobe:GetInheritPetData()
  if InheritPetList and InheritPetList.pets then
    for key, value in pairs(InheritPetList.pets) do
      local petInfo = {
        id = value.id,
        ins_id = value.ins_id,
        state = self:GetPetState(value.ins_id),
        index = GetIndex(value.id)
      }
      local petCfg = CDataTable.GetTableData("PetTable", value.id)
      if petCfg then
        petInfo.PetImage = petCfg.PetImage
        petInfo.BrandLogo = petCfg.BrandLogo
      end
      table.insert(PetList, petInfo)
    end
  end
  table.sort(PetList, function(a, b)
    if a.index == b.index then
      local PetID1, Source1 = self:ConvertToPetID(a.ins_id)
      local PetID2, Source2 = self:ConvertToPetID(b.ins_id)
      return Source1 < Source2
    end
    return a.index > b.index
  end)
  return PetList
end
function logic_pet:GetFirstPetIndex()
  if next(self.orderPetList) ~= nil then
    for i, value in ipairs(self.orderPetList) do
      if self:IsPetLaunch(value.id) then
        return i
      end
    end
  end
  log_warning(bWriteLog and "[ZH] all pet does not start")
  return nil
end
function logic_pet:GetPetIndex(pet_id)
  if next(self.orderPetList) ~= nil then
    for i, value in ipairs(self.orderPetList) do
      if value.id == pet_id then
        return i
      end
    end
  end
  return nil
end
function logic_pet:UpdateOrderPetList(param)
  self.orderPetList = {}
  for key, value in pairs(param) do
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if GlobalData.IsJapanOrKorea() then
      if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
        value.url = value.url_jp or value.url
        value.launch_time = value.launch_time_jp or value.launch_time
        value.start_time = value.start_time_jp or value.start_time
        value.end_time = value.end_time_jp or value.end_time
      else
        value.url = value.url_kr or value.url
        value.launch_time = value.launch_time_kr or value.launch_time
        value.start_time = value.start_time_kr or value.start_time
        value.end_time = value.end_time_kr or value.end_time
      end
    end
    local petInfo = {
      id = key,
      ins_id = self:ConvertToInsID(key, EPetSource.Self),
      state = self:GetPetState(key),
      index = value.index,
      url = value.url
    }
    local petCfg = CDataTable.GetTableData("PetTable", key)
    if petCfg then
      petInfo.PetImage = petCfg.PetImage
      petInfo.BrandLogo = petCfg.BrandLogo
      if self:IsPetLaunch(petInfo.id) or self:HasPet(petInfo.id) then
        table.insert(self.orderPetList, petInfo)
      end
    end
  end
  table.sort(self.orderPetList, function(a, b)
    return a.index > b.index
  end)
  log_tree("[ZH] self.orderPetList", self.orderPetList)
end
function logic_pet:GetChooseBtnPic(pet_item_id)
  local PetConfig = CDataTable.GetTableData("PetTable", pet_item_id)
  if not PetConfig then
    return nil
  end
  return PetConfig.PortraitImage
end
function logic_pet:GetPetJumpUrl(pet_item_id)
  if self.orderPetList ~= nil then
    for key, value in pairs(self.orderPetList) do
      if pet_item_id == value.id then
        return value.url
      end
    end
  end
  log_tree("[ZH] url is nil, self.orderPetList", self.orderPetList)
end
function logic_pet:GetPetDressTimeUrlReq()
  log(bWriteLog and "[HZA] logic_pet:GetPetDressTimeUrlReq ")
  local uAllPetDress = CDataTable.GetTable("PetDressTable")
  self:OnGetPetDressTimeUrl(uAllPetDress)
end
function logic_pet:SetCurrentSelectPet()
  if self.orderPetList and next(self.orderPetList) then
    local index = self:GetFirstPetIndex()
    local equipedPet = self:GetEquipedPetInsID()
    local selectedInsId
    if index then
      selectedInsId = self.orderPetList[index].ins_id
    elseif equipedPet ~= 0 then
      selectedInsId = equipedPet
    end
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_CHANGE_SELECT, selectedInsId or 50001)
    return selectedInsId
  end
end
function logic_pet:JumpToVideo(petID)
  self.desiredShowPetID = petID
  self.isReadyToShowPetMain = true
  self:get_pet_data_req()
end
function logic_pet:GetPetDependResource(pet_item_id)
  if not pet_item_id then
    return {}
  end
  local pet_id = pet_item_id
  if self.PetDependResourceMap and self.PetDependResourceMap[pet_id] then
    return self.PetDependResourceMap[pet_id]
  else
    if self.PetDependResourceMap == nil then
      self.PetDependResourceMap = {}
    end
    self.PetDependResourceMap[pet_id] = {}
    local Ret = self.PetDependResourceMap[pet_id]
    table.insert(Ret, 12204801)
    table.insert(Ret, 2211003)
    for k, v in pairs(CDataTable.GetTable("PetPlayerEmoteTable")) do
      local StringUtil = require("common.string_util")
      local tmp = StringUtil.Split(v.PlayerEmotePetId, "_")
      local emoteID = tonumber(tmp[1])
      local emotePetId = tonumber(tmp[2])
      if emotePetId == pet_id then
        table.insert(Ret, emoteID)
      end
    end
    return Ret
  end
end
function logic_pet:GetActionDiff(oldLevelAllAction, curLevelAllAction)
  local diffAction = {}
  for k, v in pairs(curLevelAllAction) do
    local found = false
    for kk, vv in pairs(oldLevelAllAction) do
      if v == vv then
        found = true
      end
    end
    if not found then
      table.insert(diffAction, v)
    end
  end
  return diffAction
end
function logic_pet:EnablePetFeature(PetID)
  return PetConfig.EnabledFeaturePets[PetID] or false
end
function logic_pet:UpdateTeammatePetInfo(UID, PetInfo)
  UID = tonumber(UID)
  if not PetInfo then
    log_error("self.UpdateTeammatePetInfo invalid PetInfo")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local PrePetInfo = TeamUpNewSystem.GetMemberPetInfo(UID)
  if PetInfo.id == 0 or PetInfo.id ~= (PrePetInfo and PrePetInfo.id) then
    PrePetInfo = nil
  end
  local CurPetInfo = PrePetInfo or PetInfo or {}
  CurPetInfo.id = PetInfo.id or CurPetInfo.id
  CurPetInfo.exp = PetInfo.exp or CurPetInfo.exp or 0
  CurPetInfo.dress = PetInfo.dress or CurPetInfo.dress
  CurPetInfo.color = PetInfo.color or CurPetInfo.color
  TeamUpNewSystem.UpdateMemberPetInfo(UID, CurPetInfo)
end
function logic_pet:FormatPetData(UID, PetID, Exp, Dress, Color, Change, nSceneType)
  local PetData = {
    UID = tostring(UID or 0),
    ShowScene = nSceneType,
    ServerInfo = {
      id = PetID or 0,
      exp = Exp or 0,
      dress = Dress,
      color = Color or 1,
      change = Change or 0
    }
  }
  return PetData
end
function logic_pet:FormatPetDataByServerInfo(UID, PetServerInfo, nSceneType)
  local TableUtil = require("common.table_util")
  local PetServerInfoCopy = TableUtil.CopyTable(PetServerInfo)
  PetServerInfoCopy.id = PetServerInfoCopy.id or 0
  PetServerInfoCopy.ins_id = PetServerInfoCopy.ins_id or 0
  PetServerInfoCopy.exp = PetServerInfoCopy.exp or 0
  PetServerInfoCopy.color = PetServerInfoCopy.color or 1
  PetServerInfoCopy.change = PetServerInfoCopy.change or 0
  local PetData = {
    UID = tostring(UID or 0),
    ServerInfo = PetServerInfoCopy,
    ShowScene = nSceneType
  }
  return PetData
end
function logic_pet:EnterPetPortal()
  local petMainUI = UIManager.GetUI(UIManager.UI_Config.pet_main)
  if petMainUI then
    petMainUI:SwitchToPortal()
  else
    self:OpenPetWorkShop(0, {bOpenPortal = true})
  end
end
function logic_pet:EnterMain()
  log(bWriteLog and "logic_pet:EnterMain")
  self.isReadyToShowPetMain = true
  self:get_pet_data_req()
  self:GetPetDressTimeUrlReq()
end
return Clogic_pet