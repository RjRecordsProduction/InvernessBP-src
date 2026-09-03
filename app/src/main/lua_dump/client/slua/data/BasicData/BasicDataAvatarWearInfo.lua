local DeviceUtils = require("common.DeviceUtils")
local BasicDataAvatarWearInfo = {}
local ENum_MemorySize = DeviceUtils.ENum_MemorySize
local _tDataCacheMaxCount = {
  [ENum_MemorySize.GreaterThan4G] = 100,
  [ENum_MemorySize.GreaterThan3G] = 50,
  [ENum_MemorySize.GreaterThan2G] = 30,
  [ENum_MemorySize.GreaterThan1G] = 15,
  [ENum_MemorySize.LessThan1G] = 10
}
function BasicDataAvatarWearInfo:DefineAndResetData()
  BasicDataAvatarWearInfo.__super.DefineAndResetData(self)
  self.RepNum = {}
end
function BasicDataAvatarWearInfo:OnInitialize()
  BasicDataAvatarWearInfo.__super.OnInitialize(self)
  local nMemoryType = DeviceUtils.GetDeviceMemoryType()
  local nDataCacheMaxCount = _tDataCacheMaxCount[nMemoryType]
  self:SetCacheMaxCount(nDataCacheMaxCount)
end
function BasicDataAvatarWearInfo:GetCacheData(key, bIsCheckSelf)
  key = tonumber(key)
  if bIsCheckSelf and tonumber(DataMgr.roleData.uid) == key then
    return nil
  end
  return BasicDataAvatarWearInfo.__super.GetCacheData(self, key)
end
function BasicDataAvatarWearInfo:GetOrReqData(key, callback, extraParams, ...)
  key = tonumber(key)
  if tonumber(DataMgr.roleData.uid) == key then
    extraParams = extraParams or {}
    extraParams.bForceReq = true
  end
  return BasicDataAvatarWearInfo.__super.GetOrReqData(self, key, callback, extraParams, ...)
end
function BasicDataAvatarWearInfo:OnSendReqMsg(uid, source)
  local ProfileHander = require("client.network.Protocol.ProfileHander")
  ProfileHander.send_get_avatar_show_req(uid, source)
end
function BasicDataAvatarWearInfo:on_get_avatar_show_rsp(res, target_uid, data)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if res == "data_not_exist" then
    data = self:_CreateEmptyRoleData(1)
    self:OnHandleMsgDataAndCallback(target_uid, data)
    return
  end
  if res ~= NetErrorCode_NONE then
    return
  end
  self.RepNum[target_uid] = self.RepNum[target_uid] or 0
  self.RepNum[target_uid] = (self.RepNum[target_uid] + 1) % 100
  data.uid = target_uid
  local bFillTheme = false
  if data.client_ver == nil or data.client_ver == "" then
    bFillTheme = true
  else
    local StringUtil = require("common.string_util")
    local arr = StringUtil.Split(data.client_ver, ".")
    if arr and arr[2] and tonumber(arr[2]) < 12 then
      bFillTheme = true
    end
  end
  if bFillTheme then
    if data.wear_ext == nil then
      data.wear_ext = {}
    end
    if data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BACKGROUD] == nil then
      data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BACKGROUD] = {}
    end
    if data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] == nil then
      data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] = {}
    end
    data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BACKGROUD][1] = HallThemeUtils.GetDefaultThemeItemID()
    data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN][1] = 1908001
    log(bWriteLog and "BasicDataAvatarWearInfo:get_avatar_show_rsp fill theme")
  end
  if not data.wear_ext and data.wear ~= nil then
    data.wear_ext = {}
    for k, v in pairs(data.wear) do
      data.wear_ext[k] = {
        v,
        0,
        0
      }
    end
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] and data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID] then
    local period = LogicXSuit.GetPeriodByItemId(data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID])
    if period then
      local newItemID = data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID]
      local Source = data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.Source] or 0
      if data.gold_dress_set_info and data.gold_dress_set_info[period] and Source ~= 1 then
        data.gold_dress_set_info.originalItem = data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID]
        newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, data.gold_dress_set_info[period])
      end
      if data.gold_dress_set_info_all and data.gold_dress_set_info_all[period] then
        local state = data.gold_dress_set_info_all[period].bicolor_state
        if state then
          data.gold_dress_set_info_all.originalItem = data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID]
          newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
          data.gold_dress_set_info_all.displayItem = newItemID
        end
      end
      data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID] = newItemID
    end
    if DataMgr.roleData.uid ~= tostring(target_uid) then
      if data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ShapeInfo] then
        logic_suit_multi_shape:SetSuitShapeInfo(target_uid, data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID], 1, data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][6])
      else
        logic_suit_multi_shape:ClearSuitShapeInfo(target_uid, data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID])
      end
    end
  end
  if data.wear and data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] then
    local period = LogicXSuit.GetPeriodByItemId(data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH])
    if period then
      local newItemID = data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
      if data.gold_dress_set_info and data.gold_dress_set_info[period] then
        data.gold_dress_set_info.originalItem = data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
        newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, data.gold_dress_set_info[period])
      end
      if data.gold_dress_set_info_all and data.gold_dress_set_info_all[period] then
        local state = data.gold_dress_set_info_all[period].bicolor_state
        if state then
          data.gold_dress_set_info_all.originalItem = data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
          newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
          data.gold_dress_set_info_all.displayItem = newItemID
        end
      end
      data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] = newItemID
    end
  end
  if data.pspace_wear_ext and data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] and data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1] then
    local period = LogicXSuit.GetPeriodByItemId(data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1])
    if period then
      local newItemID = data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1]
      local Source = data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.Source] or 0
      if data.gold_dress_set_info and data.gold_dress_set_info[period] and Source ~= 1 then
        data.gold_dress_set_info.pOriginalItem = data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1]
        newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, data.gold_dress_set_info[period])
      end
      if data.gold_dress_set_info_all and data.gold_dress_set_info_all[period] then
        local state = data.gold_dress_set_info_all[period].bicolor_state
        if state then
          data.gold_dress_set_info_all.pOriginalItem = data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1]
          newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
          data.gold_dress_set_info_all.displayItem = newItemID
        end
      end
      data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1] = newItemID
    end
    if DataMgr.roleData.uid ~= tostring(target_uid) then
      if data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1] and data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ShapeInfo] then
        logic_suit_multi_shape:SetSuitShapeInfo(target_uid, data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID], 1, data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][6])
      else
        logic_suit_multi_shape:ClearSuitShapeInfo(target_uid, data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][ENUM_AVATAR_DATA_TYPE.ItemID])
      end
    end
  end
  if DataMgr.roleData.uid ~= tostring(target_uid) then
    local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
    logic_weapon_pendant:UpdatePendantData(target_uid, data.weapon_pendants)
    logic_weapon_pendant:UpdatePendantData(target_uid, data.pspace_weapon_pendants)
  end
  data = BasicDataAvatarWearInfo:_RemoveNotFoundItem(data)
  self:OnHandleMsgDataAndCallback(target_uid, data)
end
function BasicDataAvatarWearInfo:UpdateRoleSexByUid(uid, gender)
  local info = self:GetCacheData(uid)
  if info then
    info.  else
    self:GetOrReqData(uid, function(_, callInfo)
      if callInfo then
        callInfo.      end
    end, nil, Enum_AvatarShowSource.DataAvatarWearInfoMgr)
  end
end
function BasicDataAvatarWearInfo:GetPetInfo(UID)
  local Data = self:GetCacheData(UID)
  if not Data then
    log(bWriteLog and "BasicDataAvatarWearInfo GetPetInfo Data is nil UID:" .. tostring(UID))
    return
  end
  return Data.pet_info
end
function BasicDataAvatarWearInfo:GetGender(UID)
  local Data = self:GetCacheData(UID)
  if not Data then
    log(bWriteLog and "BasicDataAvatarWearInfo GetSex Data is nil UID:" .. tostring(UID))
    return
  end
  return Data.gender
end
function BasicDataAvatarWearInfo:GetShowGender(UID)
  local Data = self:GetCacheData(UID)
  if not Data then
    printf("[WARN]BasicDataAvatarWearInfo:GetShowGender UID:%s no data,need req data", UID)
    return false
  end
  if Data.pspace_wear_ext and Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] and Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1] then
    local clothItemID = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH][1]
    local cfg = CDataTable.GetTableData("FixGenderAvatarTable", clothItemID)
    if cfg then
      printf("BasicDataAvatarWearInfo:GetShowGender UID:%s ,clothItemID:%s, gender:%s", UID, clothItemID, cfg.Gender + 1)
      return true, cfg.Gender + 1
    end
    printf("BasicDataAvatarWearInfo:GetShowGender UID:%s not found cfg clothItemID:%s, use role gender:%s", UID, clothItemID, Data.gender)
    return true, Data.gender
  end
  printf("BasicDataAvatarWearInfo:GetShowGender UID:%s no clothItemID, use role gender:%s", UID, Data.gender)
  return true, Data.gender
end
function BasicDataAvatarWearInfo:GetHeadID(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.pspace_wear_ext) or not Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD] then
    log(bWriteLog and "BasicDataAvatarWearInfo GetHeadID Data is nil UID:" .. tostring(UID))
    return 0
  end
  return Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD][1] or 0
end
function BasicDataAvatarWearInfo:GetPoseItemID(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.pspace_wear_ext) or not Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_POSTRUE] then
    return 0
  end
  local PoseItemID = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_POSTRUE][1]
  if not PoseItemID or PoseItemID == 0 then
    return 0
  end
  return PoseItemID
end
function BasicDataAvatarWearInfo:GetWearInfoList(UID)
  local Data = self:GetCacheData(UID)
  if not Data or not Data.pspace_wear_ext then
    return
  end
  local WearInfo = {}
  WearInfo[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_FACE] = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_FACE]
  WearInfo[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
  WearInfo[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_PANTS] = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_PANTS]
  WearInfo[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_SHOES] = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_SHOES]
  WearInfo[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HAIR] = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HAIR]
  WearInfo[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BEARD_INFO] = Data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BEARD_INFO]
  return WearInfo
end
function BasicDataAvatarWearInfo:GetVehicleShowSetting(UID)
  local Data = self:GetCacheData(UID)
  if not Data or not Data.depot_show_info then
    return true
  end
  return Data.depot_show_info.vehicle
end
function BasicDataAvatarWearInfo:GetVehicleShowTireFeature(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.wear_ext) or not Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] then
    return false
  end
  return Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN][ENUM_AVATAR_VEHICLE_SUB_TYPE.SHOW_TIRE]
end
function BasicDataAvatarWearInfo:GetVehicleRifitList(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.wear_ext) or not Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] then
    return {}
  end
  local RIFIT_LIST = Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN][ENUM_AVATAR_VEHICLE_SUB_TYPE.RIFIT_LIST]
  if not RIFIT_LIST then
    return {}
  end
  return RIFIT_LIST
end
function BasicDataAvatarWearInfo:GetVehicleAccessoryList(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.wear_ext) or not Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] then
    return {}
  end
  return Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN][ENUM_AVATAR_VEHICLE_SUB_TYPE.ACCESSORY_LIST]
end
function BasicDataAvatarWearInfo:GetVehicleChassisLight(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.wear_ext) or not Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] then
    return {}
  end
  return Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN][ENUM_AVATAR_VEHICLE_SUB_TYPE.CHASSIS_LIGHT]
end
function BasicDataAvatarWearInfo:GetVehicleAppliqueList(UID)
  local Data = self:GetCacheData(UID)
  if not (Data and Data.wear_ext) or not Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN] then
    return {}
  end
  return Data.wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN][ENUM_AVATAR_VEHICLE_SUB_TYPE.APPLIQUE_LIST]
end
function BasicDataAvatarWearInfo:GetAvatarIsShow(UID)
  local Data = self:GetCacheData(UID)
  if not Data then
    return false
  end
  return Data.bshow
end
function BasicDataAvatarWearInfo:GetRepNum(uid)
  uid = tonumber(uid)
  return self.RepNum[uid] or 0
end
function BasicDataAvatarWearInfo:GetMiniTVDressID(UID)
  local Data = self:GetCacheData(UID)
  if not Data then
    log(bWriteLog and "BasicDataAvatarWearInfo GetMiniTVDressID Data is nil UID:" .. tostring(UID))
    return
  end
  return Data.robot_info and Data.robot_info.dress_id
end
function BasicDataAvatarWearInfo:_RemoveNotFoundItem(data)
  for k, v in pairs(data.wear_ext or {}) do
    local itemId = v[1]
    local cfg = CDataTable.GetTableData("Item", itemId)
    if cfg == nil then
      data.wear_ext[k][1] = 0
    end
  end
  for k, v in pairs(data.wear or {}) do
    local itemId = v
    local cfg = CDataTable.GetTableData("Item", itemId)
    if cfg == nil then
      data.wear[k] = 0
    end
  end
  return data
end
function BasicDataAvatarWearInfo:_CreateEmptyRoleData(sex)
  local roleInfo = {
    gender = sex,
    bshow = true,
    wear_ext = {
      [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD] = {
        401993,
        0,
        0
      },
      [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HAIR] = {
        40601001,
        0,
        0
      },
      [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON] = {
        0,
        0,
        0
      },
      [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN] = {
        0,
        0,
        0
      }
    }
  }
  if roleInfo.gender == nil or roleInfo.gender == 0 then
    roleInfo.gender = 2
  end
  return roleInfo
end
local class = require("class")
local BasicDataBaseClass = require("client.slua.data.BasicData.BaseClass.BasicDataBaseClass")
local CBasicDataX = class(BasicDataBaseClass, nil, BasicDataAvatarWearInfo)
return CBasicDataX