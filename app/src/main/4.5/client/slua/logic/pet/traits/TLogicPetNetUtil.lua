local PetConfig = require("client.slua.logic.pet.pet_config")
local LogicPetNetUtil = {}
local local local Trait = require("common.trait")
local TLogicPetNetUtil = Trait(Trait.TraitPrototype, nil, LogicPetNetUtil)
function LogicPetNetUtil:ConvertToInsID(PetID, Source)
  if not PetID then
    return
  end
  PetID = tonumber(PetID)
  if PetID < 0.01 then
    return 0
  end
  assert_format(10000 <= PetID and PetID < 100000, "LogicPetNetUtil:ConvertPetIDToInsID PetID is not Valid %s", tostring(PetID))
  if not Source or Source == EPetSource.Self then
    return PetID
  end
  return PetID * 10 + Source
end
function LogicPetNetUtil:ConvertToPetID(InsID)
  if not InsID then
    return
  end
  InsID = tonumber(InsID)
  if 10000 <= InsID and InsID < 100000 then
    return InsID, EPetSource.Self
  end
  local PetID = math.floor(InsID / 10)
  local Source = InsID % 10
  return PetID, Source
end
function LogicPetNetUtil:get_pet_data_req()
  log(bWriteLog and "LogicPetNetUtil:get_pet_data_req")
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_get_pet_data_req()
  self:CheckToShowPetMain()
end
function LogicPetNetUtil:sync_pet_data(data)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local NetManager = require("client.network.comm.NetManager")
  if NetManager.bIsMuteMsgForReLogin and not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if data == nil then
    log(bWriteLog and "LogicPetNetUtil:sync_pet_data data == nil")
    self.isReadyToShowPetMain = false
    return
  else
    self.PetDataInited = true
    if self:ValidateDataOutDated(data) then
      return
    end
    self:AddInsIDToPetInfo(data.pets, EPetSource.Self)
    local bPetDressDataChanged
    if self.MyPetInfo.dresses then
      for k, v in pairs(self.MyPetInfo.dresses) do
        if not data.dresses[k] then
          bPetDressDataChanged = true
          break
        end
      end
      if not bPetDressDataChanged then
        for k, v in pairs(data.dresses) do
          if not self.MyPetInfo.dresses[k] then
            bPetDressDataChanged = true
            break
          end
        end
      end
    end
    local PetID = data.equip_pet_id
    data.equip_pet_ins_id = self:ConvertToInsID(PetID, data.equip_pet_source)
    local bPetDataChanged = false
    local petData = {}
    if (self.MyPetInfo == nil or self.MyPetInfo.equip_pet_ins_id ~= data.equip_pet_ins_id or bPetDressDataChanged) and TeamAvatarManager.GetMainAvatar() then
      petData = self:GetPetDataByInsID(data.equip_pet_ins_id)
      if petData and data.pets[PetID] then
        petData.ExpireTime = data.pets[PetID].expire_time
      end
      bPetDataChanged = true
    end
    if self.HasPetExpiredOffline == nil and self.HasDressExpiredOffline == nil then
      self.ExpiredPetsOffline = {}
      self.ExpiredDressesOffline = {}
      self.HasPetExpiredOffline, self.HasDressExpiredOffline = self:GetExpiredPetsOffline(data, self.ExpiredPetsOffline, self.ExpiredDressesOffline)
    end
    self:UpdatePetExpirationState(data)
    local expiredPets = {}
    local expiredDresses = {}
    local bHasPetExpired, bHasDressExpired = self:GetExpiredPetsOnline(data, expiredPets, expiredDresses)
    self.MyPetInfo = data
    self:UpdatePetNames()
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_GET_PET_DATA, data)
    if bHasPetExpired then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PET_EXPIRED, expiredPets)
    else
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PET_UPDATE_EXPIRATION_STATE)
    end
    if bHasDressExpired then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_EXPIRED, expiredDresses)
    else
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_UPDATE_EXPIRATION_STATE)
    end
    if bPetDataChanged then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, petData)
    end
    if bPetDressDataChanged then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_CHANGE)
    end
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    local roleData = BasicDataAvatarWearInfo:GetCacheData(DataMgr.roleData.uid)
    if roleData and (bPetDataChanged or bPetDressDataChanged or bHasPetExpired or bHasDressExpired) then
      BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
      end, {bForceReq = true}, Enum_AvatarShowSource.PetSystem)
    end
    self:UpdateCarryPetInfo()
    if self:GetEquipedPetInsID() ~= 0 then
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      LobbyAvatarManager.CreateMyPet()
    end
  end
  self:ResetDefaultMiniFightShow()
end
function LogicPetNetUtil:notice_pet_event_res(notice_info)
  log(bWriteLog and string.format("LogicPetNetUtil:notice_pet_event_res. notice_info=%s", tostring(notice_info)))
  log_tree("LogicPetNetUtil:notice_pet_event_res notice_info: ", notice_info)
  if notice_info == nil then
    return
  end
  local PetData = self:FormatPetDataByServerInfo(notice_info.send_uid, notice_info.pet_info)
  if notice_info.type == self.Enum_PetNoticeType.EnumPetPlayAction then
    PetData.PetActionID = notice_info.action_id
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PLAY_ACTION, PetData)
  elseif notice_info.type == self.Enum_PetNoticeType.EnumPetLevelUp then
    local level = self:GetPetLevelByExp(notice_info.pet_id, notice_info.exp)
    PetData.ServerInfo.exp = notice_info.exp
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_LEVEL_UP, PetData)
  elseif notice_info.type == self.Enum_PetNoticeType.EnumPetUnequip then
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
  elseif notice_info.type == self.Enum_PetNoticeType.EnumPetEquip then
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
  elseif notice_info.type == self.Enum_PetNoticeType.EnumPetRename then
    PetData.PetName = notice_info.name
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_RENAME, PetData)
  elseif notice_info.type == self.Enum_PetNoticeType.EnumPetColorChange then
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
  else
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
  end
  self:UpdateTeammatePetInfo(PetData.UID, PetData.ServerInfo)
end
function LogicPetNetUtil:notice_pet_change(pets, sourece)
  log_tree("LogicPetNetUtil:notice_pet_change, pets:", pets)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if pets == nil then
    log(bWriteLog and "LogicPetNetUtil:notice_pet_change pets == nil")
    return
  end
  local PetInfo = self.MyPetInfo
  if sourece == EPetSource.Inherit then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    PetInfo = LogicInheritWardrobe:GetInheritPetData()
  end
  if PetInfo == nil then
    log(bWriteLog and "LogicPetNetUtil:notice_pet_change MyPetInfo == nil")
    return
  end
  local hasNewPet = false
  if not PetInfo.pets then
    PetInfo.pets = {}
  end
  if self.DressPetMap == nil then
    self:GetDressPetMap()
  end
  for _, v in pairs(pets) do
    if PetInfo.pets[v.id] == nil then
      self.bShowEquipTips = true
      if PetInfo.dresses then
        for dress_id, _ in pairs(PetInfo.dresses) do
          if self.DressPetMap[dress_id] and self.DressPetMap[dress_id] == v.id then
            self:pet_used_dress_req(v.id, dress_id)
          end
        end
      end
      local reddotPet = require("client.slua.logic.pet.reddot_pet")
      reddotPet:NewPet(v.id)
      hasNewPet = true
      if next(PetInfo.pets) then
        local maxCarryCount = self:GetMaxCarryPetCount()
        if maxCarryCount > self._CarryCount then
          local bContain = false
          for i = 1, self._CarryCount do
            local CarryPetItemID = self:ConvertToPetID(self._CarryPets[i])
            if CarryPetItemID and CarryPetItemID == v.id then
              bContain = true
              break
            end
          end
          if not bContain then
            log(bWriteLog and "LogicPetNetUtil:notice_pet_change. need to add carry list: " .. v.id)
            self:ReqAddPetToCarryList(v.ins_id)
          end
        end
      end
    else
      local oldLevel = self:GetPetLevelByExp(v.id, PetInfo.pets[v.id].exp)
      local newLevel = self:GetPetLevelByExp(v.id, v.exp)
      if oldLevel < newLevel then
        local reddotPet = require("client.slua.logic.pet.reddot_pet")
        reddotPet:UpGrade(v.id, newLevel, oldLevel)
      end
    end
    PetInfo.pets[v.id] = v
  end
  local cnt = 0
  for _, v in pairs(PetInfo.pets) do
    cnt = cnt + 1
  end
  PetInfo.pet_  if hasNewPet then
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE)
  end
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_CHANGE)
end
function LogicPetNetUtil:AddInsIDToPetInfo(data, Source)
  if not data then
    return
  end
  for key, value in pairs(data) do
    if value.id and value.id > 0 then
      value.ins_id = self:ConvertToInsID(value.id, Source)
    end
  end
end
function LogicPetNetUtil:notice_dress_change(dressData)
  if dressData == nil then
    return
  end
  if self.DressPetMap == nil then
    self:GetDressPetMap()
  end
  if self.MyPetInfo and self.MyPetInfo.dresses then
    for _, v in pairs(dressData) do
      if self.MyPetInfo.dresses[v.item_id] == nil then
        local pet_item_id = self.DressPetMap[v.item_id]
        local PetInsID = self:ConvertToInsID(pet_item_id, EPetSource.Self)
        self:pet_used_dress_req(PetInsID, v.item_id)
        local reddotPet = require("client.slua.logic.pet.reddot_pet")
        reddotPet:NewDress(v.item_id)
        if self.NewDresses[pet_item_id] == nil then
          self.NewDresses[pet_item_id] = {}
        end
        self.NewDresses[pet_item_id][v.item_id] = true
      end
      self.MyPetInfo.dresses[v.item_id] = {}
      if v.expire_time ~= nil then
        self.MyPetInfo.dresses[v.item_id].expire_time = v.expire_time
      end
      self.MyPetInfo.dresses[v.item_id].item_id = v.item_id
      self.MyPetInfo.dresses[v.item_id].dress_id = v.dress_id
    end
  end
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_CHANGE)
end
function LogicPetNetUtil:pet_add_exp_req(pet_item_id, food_id, cnt)
  log(bWriteLog and "LogicPetNetUtil:pet_add_exp_rep")
  self.curFoodId = food_id
  local PetHandler = require("client.network.Protocol.PetHandler")
  self.OldExp = self.OldExp or {}
  if not self.MyPetInfo then
    self:get_pet_data_req()
    return
  end
  self.OldExp[pet_item_id] = self.MyPetInfo.pets[pet_item_id].exp
  PetHandler.send_pet_add_exp_req(pet_item_id, food_id, cnt)
end
function LogicPetNetUtil:pet_add_exp_rsp(code, pet_item_id, exp)
  if self:HandleErrorCode(code) then
    local oldExp = self.OldExp[pet_item_id]
    local oldLevel = self:GetPetLevelByExp(pet_item_id, oldExp)
    local newLevel = self:GetPetLevelByExp(pet_item_id, exp)
    if oldLevel < newLevel then
      local data = {}
      data.PetID = pet_item_id
      data.UID = DataMgr.roleData.uid
      data.PetLevel = newLevel
      log(bWriteLog and "pet level up")
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_SELF_PET_LEVEL_UP, data)
    end
    local addExp = exp - oldExp
    self.MyPetInfo.pets[pet_item_id].    local petData = {}
    petData.UID = DataMgr.roleData.uid
    petData.PetID = pet_item_id
    petData.PetExp = exp
    petData.PetAddExp = addExp
    petData.ServerInfo = self:GetPetDataByPetItemID(pet_item_id)
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_ADD_EXP_SUCCESS, petData)
  end
end
function LogicPetNetUtil:HandleErrorCode(errorCode)
  log(bWriteLog and "LogicPetNetUtil:HandleErrorCode code: " .. tostring(errorCode))
  if errorCode == 0 then
    return true
  elseif errorCode == 530001 then
    ShowNotice(530001)
  elseif errorCode == 530002 then
    ShowNotice(530002)
  elseif errorCode == 530003 then
    ShowNotice(530003)
  elseif errorCode == 530004 then
    ShowNotice(530004)
  elseif errorCode == 530005 then
    ShowNotice(530005)
  elseif errorCode == 530006 then
    ShowNotice(530006)
  elseif errorCode == 530007 then
    ShowNotice(530007)
  elseif errorCode == 530008 then
    ShowNotice(530008)
  elseif errorCode == 530009 then
    ShowNotice(530010)
  elseif errorCode == 530010 then
    ShowNotice(530010)
  elseif errorCode == 530011 then
    ShowNotice(530011)
  elseif errorCode == 530012 then
    ShowNotice(530012)
  elseif errorCode == 530013 then
    ShowNotice(530013)
  elseif errorCode == 530014 then
    ShowNotice(120164)
  elseif errorCode == 530025 then
    ShowNotice(530025)
  elseif errorCode == 65535 then
    ShowNotice(65535)
  end
  return false
end
function LogicPetNetUtil:on_get_pet_tab_info_rsp(param1, param2)
  log_tree("LogicPetNetUtil:on_get_pet_taon_get_pet_tab_info_rsp param1", param1)
  log_tree("LogicPetNetUtil:on_get_pet_taon_get_pet_tab_info_rsp param2", param2)
  self.PetTimeUrl = param2
  self:GetOrderPetList()
  self:SetCurrentSelectPet()
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_TIME_GET_PET)
end
function LogicPetNetUtil:equip_pet_req(PetInsID)
  log(bWriteLog and "LogicPetNetUtil:equip_pet_req PetInsID: " .. tostring(PetInsID))
  local PetID, Source = self:ConvertToPetID(PetInsID)
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_equip_pet_req(PetID, Source)
end
function LogicPetNetUtil:equip_pet_rsp(code, PetInsID)
  log(bWriteLog and "LogicPetNetUtil:equip_pet_rsp code:" .. tostring(code) .. "PetInsID:" .. tostring(PetInsID))
  if self:HandleErrorCode(code) then
    local OldEquipPetID = self.MyPetInfo.equip_pet_ins_id or 0
    self.MyPetInfo.equip_pet_ins_id = PetInsID
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_SUCCESS, PetInsID)
    local ServerInfo = self:GetPetDataByInsID(PetInsID)
    local PetData = self:FormatPetDataByServerInfo(DataMgr.roleData.uid, ServerInfo)
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
    local PetID, Source = self:ConvertToPetID(PetInsID)
    local bInCarryList = self:IsSameItemIDInCarryList(PetID)
    if bInCarryList then
      self:ReqDelPetFromCarryListByItemID(PetID)
      if OldEquipPetID ~= 0 then
        local _PetID, _Source = self:ConvertToPetID(OldEquipPetID)
        local PetHandler = require("client.network.Protocol.PetHandler")
        PetHandler.send_carry_pet_req(_PetID, 1, _Source)
      end
    end
  end
end
function LogicPetNetUtil:unequip_pet_req()
  log(bWriteLog and "LogicPetNetUtil:unequip_pet_rep")
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_unequip_pet_req()
end
function LogicPetNetUtil:unequip_pet_rsp(code)
  log(bWriteLog and "LogicPetNetUtil:equip_pet_rsp code:" .. tostring(code))
  if self:HandleErrorCode(code) then
    self.MyPetInfo.equip_pet_ins_id = 0
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_UNEQUIP_PET_SUCCESS)
    local PetData = self:FormatPetDataByServerInfo(DataMgr.roleData.uid, nil)
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
  end
end
function LogicPetNetUtil:pet_reanme_req(pet_item_id, name)
  log(bWriteLog and "LogicPetNetUtil:pet_reanme_req")
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_pet_reanme_req(pet_item_id, name)
end
function LogicPetNetUtil:pet_reanme_rsp(code, pet_item_id, name, oldName)
  log(bWriteLog and "LogicPetNetUtil:pet_reanme_rsp")
  if self:HandleErrorCode(code) then
    self.MyPetInfo.pets[pet_item_id].    local petData = self:FormatPetData(DataMgr.roleData.uid, pet_item_id)
    petData.PetName = name
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_RENAME, petData)
  end
  self:UpdatePetNames()
end
function LogicPetNetUtil:pet_action_req(action_id)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if TeamAvatarManager.GetAvatarCount() == 1 then
    local petInsID = self.MyPetInfo.equip_pet_ins_id or 0
    if self:IsActionUnLock(petInsID, action_id) == true then
      local petData = {}
      petData.UID = DataMgr.roleData.uid
      petData.PetActionID = action_id
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PLAY_ACTION, petData)
    else
    end
    return
  end
  log(bWriteLog and "LogicPetNetUtil:pet_action_req")
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_pet_action_req(action_id)
end
function LogicPetNetUtil:pet_action_rsp(code, action_id)
  log(bWriteLog and "LogicPetNetUtil:pet_action_rsp code:" .. tostring(code) .. "pet_item_id:" .. tostring(action_id))
  if self:HandleErrorCode(code) then
    local petData = {}
    petData.UID = DataMgr.roleData.uid
    petData.PetActionID = action_id
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PLAY_ACTION, petData)
  end
end
function LogicPetNetUtil:pet_used_dress_req(PetInsID, dress_item_id)
  local PetID, Source = self:ConvertToPetID(PetInsID)
  log(bWriteLog and "LogicPetNetUtil:pet_used_dress_req")
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_pet_used_dress_req(PetID, dress_item_id, Source)
end
function LogicPetNetUtil:pet_used_dress_rsp(errCode, pet_item_id, dress_item_id, source)
  log(bWriteLog and "LogicPetNetUtil:pet_used_dress_rsp")
  if self:HandleErrorCode(errCode) then
    local PetInsID = self:ConvertToInsID(pet_item_id, source)
    local PetInfo = self:GetPetInfo(PetInsID)
    if PetInfo and PetInfo.pets[pet_item_id] then
      if not PetInfo.pets[pet_item_id].dress then
        PetInfo.pets[pet_item_id].dress = {}
      end
      PetInfo.pets[pet_item_id].dress[dress_item_id] = {}
      PetInfo.pets[pet_item_id].dress[dress_item_id].id = CDataTable.GetTableData("Item", dress_item_id).BPID
    end
    local ServerInfo = self:GetPetDataByInsID(PetInsID)
    local PetData = self:FormatPetDataByServerInfo(DataMgr.roleData.uid, ServerInfo)
    if self:GetEquipedPetInsID() == PetInsID then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
    end
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_CHANGE)
  end
end
function LogicPetNetUtil:pet_unload_dress_req(PetInsID, dress_item_id)
  local PetID, Source = self:ConvertToPetID(PetInsID)
  log(bWriteLog and "LogicPetNetUtil:pet_unload_dress_req")
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_pet_unload_dress_req(PetID, dress_item_id, Source)
end
function LogicPetNetUtil:pet_unload_dress_rsp(errCode, pet_item_id, dress_item_id, source)
  if self:HandleErrorCode(errCode) then
    local PetInsID = self:ConvertToInsID(pet_item_id, source)
    local PetInfo = self:GetPetInfo(PetInsID)
    if PetInfo and PetInfo.pets[pet_item_id] then
      PetInfo.pets[pet_item_id].dress[dress_item_id] = nil
    end
    local ServerInfo = self:GetPetDataByInsID(PetInsID)
    local PetData = self:FormatPetDataByServerInfo(DataMgr.roleData.uid, ServerInfo)
    if self:GetEquipedPetInsID() == PetInsID then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, PetData)
    end
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_DRESS_CHANGE)
  end
end
function LogicPetNetUtil:query_pet_dress_shop_info_rsp(data)
  log(bWriteLog and "LogicPetNetUtil:query_pet_dress_shop_info_rsp")
  self.PetDressShopData = data
end
function LogicPetNetUtil:on_pet_decompose_list_rsp(code, decompose_list)
  if self:HandleErrorCode(code) and decompose_list and 0 < #decompose_list then
    log_tree("[HZA] decompose_list", decompose_list)
    local filteredDecomposeList = {}
    for i, v in ipairs(decompose_list) do
      if v.valid_hours ~= nil and tonumber(v.valid_hours) ~= nil then
        table.insert(filteredDecomposeList, v)
      end
    end
    if 0 < #filteredDecomposeList then
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PET_ITEM_DECOMPOSED, filteredDecomposeList)
    end
  end
end
function LogicPetNetUtil:send_set_pet_color_req(pet_id, color)
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_set_pet_color_req(pet_id, color)
end
function LogicPetNetUtil:on_set_pet_color_rsp(err_code, pet_id, color)
  if err_code == 0 then
    local PetData = self:GetPetDataByPetItemID(pet_id)
    if PetData then
      PetData.      if GameStatus.IsInFightingNotMainCity() then
        print(bWriteLog and "LogicPetNetUtil:on_set_pet_color_rsp GameStatus.IsInFightingNotMainCity()")
        return
      end
      EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_SELF_PET_COLOR_CHANGE, color)
    end
  end
end
function LogicPetNetUtil:ReqAddPetToCarryList(PetInsID)
  if not PetInsID or PetInsID == 0 then
    return false
  end
  local maxCarryCount = self:GetMaxCarryPetCount()
  if maxCarryCount <= self._CarryCount then
    ShowNotice(65534)
    return false
  end
  local PetID, Source = self:ConvertToPetID(PetInsID)
  if self.MyPetInfo then
    if self.MyPetInfo.equip_pet_ins_id == PetInsID then
      ShowNotice(65535)
      return false
    end
    local EquipItemID = self:ConvertToPetID(self.MyPetInfo.equip_pet_ins_id)
    if EquipItemID and EquipItemID == PetID then
      ShowNotice(65535)
      return false
    end
  end
  if self:IsSameItemIDInCarryList(PetID) then
    ShowNotice(530025)
    return false
  end
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_carry_pet_req(PetID, 1, Source)
  return true
end
function LogicPetNetUtil:ReqDelPetFromCarryListByItemID(PetItemID)
  if not PetItemID or PetItemID == 0 then
    return false
  end
  local _CarrayPetInsID = self:GetInsIDFormCarryList(PetItemID)
  if not _CarrayPetInsID then
    return false
  end
  local PetID, Source = self:ConvertToPetID(_CarrayPetInsID)
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_carry_pet_req(PetID, 0, Source)
  return true
end
function LogicPetNetUtil:ReqDelPetFromCarryList(PetInsID)
  if not PetInsID or PetInsID == 0 then
    return false
  end
  local FindIndex
  for i = 1, self._CarryCount do
    if self._CarryPets[i] == PetInsID then
      FindIndex = i
      break
    end
  end
  if not FindIndex then
    return false
  end
  local PetID, Source = self:ConvertToPetID(PetInsID)
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_carry_pet_req(PetID, 0, Source)
  return true
end
function LogicPetNetUtil:IsSameItemIDInCarryList(PetID)
  for i = 1, self._CarryCount do
    local CarryPetItemID = self:ConvertToPetID(self._CarryPets[i])
    if CarryPetItemID and CarryPetItemID == PetID then
      return true
    end
  end
  return false
end
function LogicPetNetUtil:GetInsIDFormCarryList(PetItemID)
  for i = 1, self._CarryCount do
    local CarryPetItemID = self:ConvertToPetID(self._CarryPets[i])
    if CarryPetItemID and CarryPetItemID == PetItemID then
      return self._CarryPets[i]
    end
  end
  return nil
end
function LogicPetNetUtil:RspAddPetToCarryList(PetInsID)
  local maxCarryCount = self:GetMaxCarryPetCount()
  if maxCarryCount <= self._CarryCount then
    return
  end
  for i = 1, self._CarryCount do
    if self._CarryPets[i] == PetInsID then
      return
    end
  end
  self._CarryCount = self._CarryCount + 1
  self._CarryPets[self._CarryCount] = PetInsID
  table.sort(self._CarryPets, function(a, b)
    return b < a
  end)
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_CARRY_LIST_CHANGE)
end
function LogicPetNetUtil:ReplacePetInCarryList(DelPetInsID, AddPetInsID)
  if not DelPetInsID or not AddPetInsID then
    return false
  end
  if not self:IsSameItemIDInCarryList(DelPetInsID) then
    return self:ReqAddPetToCarryList(AddPetInsID)
  end
  local DelPetItemID, DelSource = self:ConvertToPetID(DelPetInsID)
  local AddPetItemID, AddSource = self:ConvertToPetID(AddPetInsID)
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_carry_pet_req(DelPetItemID, 0, DelSource)
  PetHandler.send_carry_pet_req(AddPetItemID, 1, AddSource)
  return true
end
function LogicPetNetUtil:RspDelPetFromCarryList(PetInsID)
  local FindIndex
  for i = 1, self._CarryCount do
    if self._CarryPets[i] == PetInsID then
      FindIndex = i
      break
    end
  end
  if not FindIndex then
    return
  end
  self._CarryPets[FindIndex] = self._CarryPets[self._CarryCount]
  self._CarryPets[self._CarryCount] = 0
  self._CarryCount = self._CarryCount - 1
  table.sort(self._CarryPets, function(a, b)
    return b < a
  end)
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_CARRY_LIST_CHANGE)
end
function LogicPetNetUtil:carry_pet_rsp(err_code, PetInsID, carry_type)
  if self:HandleErrorCode(err_code) then
    if carry_type == 0 then
      self:RspDelPetFromCarryList(PetInsID)
    elseif carry_type == 1 then
      self:RspAddPetToCarryList(PetInsID)
    end
  end
end
function LogicPetNetUtil:send_change_pet_model_req(PetInsID, change_type)
  local PetID, Source = self:ConvertToPetID(PetInsID)
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_change_pet_model_req(PetID, change_type, Source)
end
function LogicPetNetUtil:on_change_pet_model_rsp(pet_id, change_type, source)
  local PetInsID = self:ConvertToInsID(pet_id, source)
  local PetData = self:GetPetDataByInsID(PetInsID)
  if not PetData then
    return
  end
  PetData.change = change_type
  if GameStatus.IsInFightingNotMainCity() then
    print(bWriteLog and "LogicPetNetUtil:on_change_pet_model_rsp GameStatus.IsInFightingNotMainCity()")
    return
  end
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_MODEL_ENLARGE_STATE_CHANGE, pet_id, change_type or 0)
end
function LogicPetNetUtil:on_get_collect_award_privilege_rsp(data)
  self:_ProcessCollectPrivilegeData(data)
end
function LogicPetNetUtil:on_notify_collect_privilege_data(data)
  self:_ProcessCollectPrivilegeData(data)
end
function LogicPetNetUtil:_ProcessCollectPrivilegeData(data)
  self.bHasSlotExpandPriv = false
  if data and data.pet_slot_expand_priv then
    self.bHasSlotExpandPriv = true
  end
end
function LogicPetNetUtil:on_get_pet_switch_effect_rsp(effect_info)
  if not effect_info then
    return
  end
  self._ownEffectMap = effect_info.all_effect or {}
  self._equipEffect = 0
  if effect_info and effect_info.equiped_effect then
    for itemId, _ in pairs(effect_info.equiped_effect) do
      self._equipEffect = itemId
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PORTAL_CHANGE)
end
function LogicPetNetUtil:ReqSetEquipEffect(effectItemId)
  local PetHandler = require("client.network.Protocol.PetHandler")
  if effectItemId then
    PetHandler.send_set_equip_pet_switch_effect_req({effectItemId})
  else
    PetHandler.send_set_equip_pet_switch_effect_req({})
  end
end
function LogicPetNetUtil:on_set_equip_pet_switch_effect_rsp(effect_list)
  self._equipEffect = 0
  if effect_list then
    for itemId, _ in pairs(effect_list) do
      self._equipEffect = itemId
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PORTAL_CHANGE)
end
function LogicPetNetUtil:ResetDefaultMiniFightShow()
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local data = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eResetMiniTvShowFlag) or {}
  local state = data.bHasSetFlag
  if state then
    return
  end
  local petID = self:GetEquipedPetItemID()
  local bOpenDefault = false
  if petID and petID ~= 0 and petID ~= 50000 and petID ~= 50001 then
    bOpenDefault = true
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self.bShowLocal = SettingModule:SetOptionValue("ShowMiniTvInFighting", bOpenDefault)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local reportValue = 0
  if type(bOpenDefault) == "number" then
    reportValue = bOpenDefault
  else
    reportValue = bOpenDefault and 1 or 0
  end
  BasicDataTLogReport:ReportDelay(TLogEventDefine.FightingShowSwitchSetting, reportValue)
  log(bWriteLog and "LogicPetNetUtil:ResetDefaultMiniFightShow save to file current: " .. tostring(bOpenDefault))
  data.bHasSetFlag = true
  LogicPlayerPrefs.SaveDataToFile_N(data, PlayerPrefsConfig.eResetMiniTvShowFlag)
end
return TLogicPetNetUtil