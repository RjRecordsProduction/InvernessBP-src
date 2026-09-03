local VehicleCollectSystem = {
  LobbyContainerPath = "/Game/Arts_PlayerBluePrints/Vehicle/VehicleContainer/VehicleContainer_Lobby.VehicleContainer_Lobby_C",
  ENUM_VEHICLE_SYSTEM = {COLLECT = 1, REFIT = 2},
  DEFAULT_LICENSE_NUM = "A00001",
  CameraConfig = {
    [1] = {
      ControlRotation = FRotator(5, 0, 0),
      CameraRotation = FRotator(0, 0, 0),
      FOV = 40
    },
    [2] = {
      ControlRotation = FRotator(-10, 0, 0),
      CameraRotation = FRotator(-10, 0, 0),
      FOV = 50
    },
    [3] = {
      ControlRotation = FRotator(-5, 0, 0),
      CameraRotation = FRotator(-10, 0, 0),
      FOV = 50
    },
    [4] = {
      ControlRotation = FRotator(-5, 0, 0),
      CameraRotation = FRotator(0, 0, 0),
      FOV = 40
    }
  }
}
local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
function VehicleCollectSystem:DefineAndResetData()
  self.car_voice_switch = nil
  self.EffectVehicleList = {}
  self.BrandData = nil
  self.CollectCarInfo = {}
end
function VehicleCollectSystem:GetVehicleBrandData()
  if self.BrandData then
    return self.BrandData
  end
  local CollectCarBranndCfg = CDataTable.GetTable("CollectCarBrandCfg")
  local TimeUtil = require("client.common.time_util")
  local VehicleBrandData = {}
  for _, value in pairs(CollectCarBranndCfg) do
    local carCollecitonUnlockTable = self:GetCarCollectionUnlockTable()
    local ValidTimeString = carCollecitonUnlockTable and carCollecitonUnlockTable[value.VehicleType]
    local ValidTime = TimeUtil.TimeStringToUnixstamp(ValidTimeString, false)
    local ServerTime = FuncUtil.GetServerTimeInSec()
    if ValidTime < ServerTime then
      table.insert(VehicleBrandData, value)
    end
  end
  table.sort(VehicleBrandData, function(a, b)
    return a.Weight > b.Weight
  end)
  log_tree("VehicleCollectSystem VehicleBrandData", VehicleBrandData)
  self.BrandData = VehicleBrandData
  return VehicleBrandData
end
function VehicleCollectSystem:GetVehicleListByCollectType(VehicleType)
  if self.EffectVehicleList[VehicleType] then
    return self.EffectVehicleList[VehicleType]
  end
  local CollectCarInfo = CDataTable.GetTableByFilter("BetterVehicleEffect", "VehicleType", VehicleType)
  local VehicleList = {}
  for _, value in pairs(CollectCarInfo) do
    if value.VehicleType == VehicleType then
      table.insert(VehicleList, value.ID)
    end
  end
  log_tree("VehicleCollectSystem VehicleList", VehicleList)
  self.EffectVehicleList[VehicleType] = VehicleList
  return self.EffectVehicleList[VehicleType]
end
function VehicleCollectSystem:GetVehicleListBySort(VehicleType)
  if self.CollectCarInfo[VehicleType] then
    return self.CollectCarInfo[VehicleType]
  end
  local CollectCarInfo = CDataTable.GetTableByFilter("CollectCarInfo", "Type", VehicleType)
  local VehicleList = {}
  for _, value in pairs(CollectCarInfo) do
    if value.Type == VehicleType then
      VehicleList[value.ShowIndex] = value.ItemID
    end
  end
  self.CollectCarInfo[VehicleType] = VehicleList
  return self.CollectCarInfo[VehicleType]
end
function VehicleCollectSystem:GetVehicleType(VehicleID)
  local CollectCarInfo = CDataTable.GetTableData("CollectCarInfo", VehicleID)
  if not CollectCarInfo then
    return -1
  end
  return CollectCarInfo.Type
end
function VehicleCollectSystem:GetSumVehicleNumByType(VehicleType)
  local VehicleList = self:GetVehicleListByCollectType(VehicleType)
  local count = 0
  for _ in pairs(VehicleList) do
    count = count + 1
  end
  return count
end
function VehicleCollectSystem:GetOwnVehicleNumByType(VehicleType, Source)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local OwnNum = 0
  VehicleType = tonumber(VehicleType)
  local VehicleList = self:GetVehicleListByCollectType(VehicleType)
  for _, ItemID in pairs(VehicleList) do
    local HasPermanentItem = wardrobe_data:HasItem(ItemID, true, Source)
    local tCarData = wardrobe_data:GetHallDepotItemDataByResID(ItemID, Source)
    local bIsFreeze = tCarData and tCarData.lock_cnt and 0 < tCarData.lock_cnt
    if HasPermanentItem and not bIsFreeze then
      OwnNum = OwnNum + 1
    end
  end
  return OwnNum
end
function VehicleCollectSystem:GetOneOwnVehicleIdByType(VehicleType)
  if not VehicleType then
    return nil
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  VehicleType = tonumber(VehicleType)
  local VehicleList = self:GetVehicleListByCollectType(VehicleType)
  for _, ItemID in pairs(VehicleList) do
    local HasPermanentItem = wardrobe_data:HasItem(ItemID, false)
    if HasPermanentItem then
      return ItemID
    end
  end
  return nil
end
function VehicleCollectSystem:GetOwnMaxTypeCarNum()
  local CollectCarInfo = CDataTable.GetTable("BetterVehicleEffect")
  local VehicleOwnNumList = {}
  local MaxCarNum = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, value in pairs(CollectCarInfo) do
    if value.VehicleType and 0 < value.VehicleType then
      local HasPermanentItem = wardrobe_data:CheckHasPermanentItem(value.ID)
      local tCarData = wardrobe_data:GetHallDepotItemDataByResID(value.ID)
      local bIsLock = tCarData and tCarData.lock_cnt and 0 < tCarData.lock_cnt
      if HasPermanentItem and not bIsLock then
        VehicleOwnNumList[value.VehicleType] = (VehicleOwnNumList[value.VehicleType] or 0) + 1
        if MaxCarNum < VehicleOwnNumList[value.VehicleType] then
          MaxCarNum = VehicleOwnNumList[value.VehicleType]
        end
      end
    end
  end
  return MaxCarNum
end
function VehicleCollectSystem:GetTitleByType(VehicleType)
  local CollectCarBranndCfg = CDataTable.GetTableData("CollectCarBrandCfg", VehicleType)
  if not CollectCarBranndCfg then
    return ""
  end
  return CollectCarBranndCfg.Title
end
function VehicleCollectSystem:GetFeatureNameByID(FeatureID)
  local FeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not FeatureCfg then
    return ""
  end
  return FeatureCfg.ShowName
end
function VehicleCollectSystem:GetBrandNameByType(VehicleType)
  local CollectCarBranndCfg = CDataTable.GetTableData("CollectCarBrandCfg", VehicleType)
  if not CollectCarBranndCfg then
    return ""
  end
  return CollectCarBranndCfg.BrandName
end
function VehicleCollectSystem:GetFeatureVoiceData(FeatureID)
  local VoiceList = {}
  local FeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not FeatureCfg then
    log_error("[VehicleCollect] GetFeatureVoiceData FeatureCfg is nil FeatureID:" .. tostring(FeatureID))
    return {}
  end
  local StringUtil = require("common.string_util")
  local soundTimeList = StringUtil.Split(FeatureCfg.VoiceTime, "|")
  local DriverVoice = {
    VoiceText = FeatureCfg.DriverVoiceText,
    VoiceID = FeatureCfg.DriverVoiceID,
    time = tonumber(soundTimeList[1]) or 0
  }
  table.insert(VoiceList, DriverVoice)
  local PassengerVoice = {
    VoiceText = FeatureCfg.PassengerVoiceText,
    VoiceID = FeatureCfg.PassengerVoiceID,
    time = tonumber(soundTimeList[2]) or 0
  }
  table.insert(VoiceList, PassengerVoice)
  return VoiceList
end
function VehicleCollectSystem:GetKillBoxData(VehicleType)
  local KillBoxData = {}
  local VehicleList = self:GetVehicleListBySort(VehicleType)
  for _, ItemID in pairs(VehicleList) do
    local Data = CDataTable.GetTableData("CollectCarKillBox", ItemID)
    table.insert(KillBoxData, Data)
  end
  return KillBoxData
end
function VehicleCollectSystem:GetHighTireData(VehicleType)
  local HighTireData = {}
  local VehicleList = self:GetVehicleListBySort(VehicleType)
  for _, ItemID in pairs(VehicleList) do
    local Data = CDataTable.GetTableData("CollectCarHighTire", ItemID)
    table.insert(HighTireData, Data)
  end
  return HighTireData
end
function VehicleCollectSystem:GetLevelByType(VehicleType)
  local Level = 0
  local OwnNum = self:GetOwnVehicleNumByType(VehicleType)
  local Cfg = VehiclePlateLicenseUtil.GetCollectCarCfgByType(VehicleType)
  if not Cfg then
    return Level, 0
  end
  for _, value in pairs(Cfg) do
    if OwnNum >= value.UnlockNum then
      Level = Level + 1
    end
  end
  return Level, #Cfg
end
function VehicleCollectSystem:GetLevelForFeatureType(VehicleType, FeatureType)
  local Cfg = VehiclePlateLicenseUtil.GetCollectCarCfgByType(VehicleType)
  if not Cfg then
    return 0
  end
  for key, value in pairs(Cfg) do
    if FeatureType == value.FeatureType then
      return key
    end
  end
  return 0
end
function VehicleCollectSystem:HasUnLockFeature(VehicleType, FeatureType, Source)
  local UnlockNum = VehiclePlateLicenseUtil.GetUnlockNum(VehicleType, FeatureType)
  local OwnNum = self:GetOwnVehicleNumByType(VehicleType, Source)
  return UnlockNum <= OwnNum
end
function VehicleCollectSystem:HasUnlockFeature2(VehicleType, FeatureID)
  local UnlockNum = VehiclePlateLicenseUtil.GetFeatureUnlockNum(FeatureID)
  local OwnNum = self:GetOwnVehicleNumByType(VehicleType)
  return UnlockNum <= OwnNum
end
function VehicleCollectSystem:GetSpinActivityData(VehicleType)
  local CollectCarBranndCfg = CDataTable.GetTableData("CollectCarBrandCfg", VehicleType)
  if not CollectCarBranndCfg then
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData CollectCarBranndCfg is nil VehicleType:" .. tostring(VehicleType))
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local ActivityID = CollectCarBranndCfg.ActivityID
  if GlobalData.IsJapanOrKorea() then
    ActivityID = CollectCarBranndCfg.JKActivityID
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData IsJapanOrKorea ActivityID" .. tostring(ActivityID))
  elseif PublishRegionMacros.IsBLUEHOLE() then
    ActivityID = CollectCarBranndCfg.IndianActivityID
  end
  if not ActivityID then
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData ActivityID is nil VehicleType:" .. tostring(VehicleType))
    return
  end
  local LadderDrawSystem = require("client.slua.logic.lobby_activity.logic_ladder_draw")
  local ActivityData = LadderDrawSystem.GetActData(ActivityID)
  if not ActivityData or not next(ActivityData) then
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData ActivityData is nil ActivityID:" .. tostring(ActivityID))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local isOpen = now > ActivityData.StartTime and now < ActivityData.EndTime
  if not isOpen then
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData not isOpen ActivityID:" .. tostring(ActivityID))
    return
  end
  local ActivityConfig = LadderDrawSystem.GetParamConfig(ActivityID)
  if not ActivityConfig or not ActivityConfig.exchange_car_item_id then
    log(bWriteLog and "[VehicleCollect] not ActivityConfig ")
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardrobeNum = wardrobe_data:GetHallDepotItemCountByResID(ActivityConfig.exchange_car_item_id, true)
  local OwnExchangeItem = 0 < WardrobeNum
  local Data = {
    OwnExchangeItem = OwnExchangeItem,
    LuckySpinJumpPath = CollectCarBranndCfg.LuckySpinJumpPath,
    StoreJumpPath = CollectCarBranndCfg.StoreJumpPath
  }
  if GlobalData.IsJapanOrKorea() then
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData IsJapanOrKorea")
    Data.LuckySpinJumpPath = CollectCarBranndCfg.JKLuckySpinJumpPath
    Data.StoreJumpPath = CollectCarBranndCfg.JKStoreJumpPath
  elseif PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "[VehicleCollect] GetSpinActivityData IsBLUEHOLE")
    Data.LuckySpinJumpPath = CollectCarBranndCfg.IndianStoreJumpPath
    Data.StoreJumpPath = CollectCarBranndCfg.IndianLuckySpinJumpPath
  end
  log_tree("[VehicleCollect] GetSpinActivityData Data", Data)
  return Data
end
function VehicleCollectSystem:send_edit_car_plate_number_req(car_type, plate_number)
  log(bWriteLog and "[VehicleCollect] send_edit_car_plate_number_req car_type:" .. tostring(car_type) .. " plate_number:" .. tostring(plate_number))
  local VehicleCollectHandler = require("client.network.Protocol.VehicleCollectHandler")
  VehicleCollectHandler.send_edit_car_plate_number_req(car_type, plate_number)
end
function VehicleCollectSystem:on_edit_car_plate_number_rsp(car_type, plate_number)
  log(bWriteLog and "[VehicleCollect] on_edit_car_plate_number_rsp: car_type" .. tostring(car_type) .. " plate_number:" .. tostring(plate_number))
  ShowNotice(49951)
  DataMgr.car_plate_info = DataMgr.car_plate_info or {}
  DataMgr.car_plate_info[car_type] = plate_number
  EventSystem:postEvent(EVENTTYPE_VEHICLE_COLLECT, EVENTID_VEHICLE_COLLECT_LICENSE_CHANGE)
end
function VehicleCollectSystem:GetVehicleLicense(ItemID, Source)
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(ItemID)
  if VehicleType < 1 then
    return nil
  end
  local Plate
  if Source == EWardrobeDataSource.InheritWardrobe then
    log(bWriteLog and "[VehicleCollect] GetVehicleLicense inherit ItemID:" .. tostring(ItemID) .. " Plate:" .. tostring(Plate))
    Plate = self.inherit_car_collection and self.inherit_car_collection[VehicleType] and self.inherit_car_collection[VehicleType].plate_number
    return Plate
  end
  Plate = DataMgr.car_plate_info and DataMgr.car_plate_info[VehicleType]
  log(bWriteLog and "[VehicleCollect] GetVehicleLicense wardrobe ItemID:" .. tostring(ItemID) .. " Plate:" .. tostring(Plate))
  return Plate
end
function VehicleCollectSystem:GetShowVehicleLincese(ItemID)
  local LinceseNum = self:GetVehicleLicense(ItemID, EWardrobeDataSource.Wardrobe)
  if not LinceseNum or LinceseNum == "" then
    LinceseNum = self.DEFAULT_LICENSE_NUM
  end
  return LinceseNum
end
function VehicleCollectSystem:GetLobbyContainerAvatarID(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return
  end
  return CollectCarFeatureCfg.ContainerAvatarID
end
function VehicleCollectSystem:GetIntroductionData()
  local IntroductionData = {}
  local SupercarCollectIntroductionCfg = CDataTable.GetTable("SupercarCollectIntroductionCfg")
  if not SupercarCollectIntroductionCfg then
    return IntroductionData
  end
  for _, value in pairs(SupercarCollectIntroductionCfg) do
    local Data = {
      ID = value.ID,
      CDNPath = value.CDNPath,
      Title = value.Title,
      Content = value.Content
    }
    table.insert(IntroductionData, Data)
  end
  local sort = function(a, b)
    return a.ID < b.ID
  end
  table.sort(IntroductionData, sort)
  return IntroductionData
end
function VehicleCollectSystem:GetDefaultShowVehicle(VehicleType, VehicleID)
  local VehicleList = self:GetVehicleListBySort(VehicleType)
  if not VehicleList then
    return 1915005
  end
  local DefaultID = VehicleList[1]
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local isHaveJumpBack = type(VehicleID) == "number"
  if isHaveJumpBack then
    for _, ItemID in pairs(VehicleList) do
      if ItemID == VehicleID then
        return VehicleID
      end
    end
  end
  for _, ItemID in pairs(VehicleList) do
    local WardrobeNum = wardrobe_data:GetHallDepotItemCountByResID(ItemID, true)
    if 0 < WardrobeNum then
      DefaultID = ItemID
      break
    end
  end
  return DefaultID
end
function VehicleCollectSystem:GetPreviewVehicleList(VehicleType)
  local PreviewVehicleList = {}
  local VehicleList = self:GetVehicleListBySort(VehicleType)
  if not VehicleList then
    log_error("VehicleCollectSystem GetPreviewVehicleList VehicleType is not Valid VehicleType:" .. tostring(VehicleType))
    return {}
  end
  for _, ItemID in pairs(VehicleList) do
    local PreviewData = self:GetItemPreviewData(ItemID)
    table.insert(PreviewVehicleList, PreviewData)
  end
  return PreviewVehicleList
end
function VehicleCollectSystem:GetItemPreviewData(ItemID)
  local PreviewData = {}
  PreviewData.  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local HasPermanentItem = wardrobe_data:HasItem(ItemID, true)
  PreviewData.bOwn = HasPermanentItem
  local CollectCarInfo = CDataTable.GetTableData("CollectCarInfo", ItemID)
  if CollectCarInfo then
    PreviewData.UnlockIconPath = CollectCarInfo.UnlockIconPath
    PreviewData.LockIconPath = CollectCarInfo.LockIconPath
    PreviewData.bIsHiddenType = CollectCarInfo.IsHiddenType
  else
    PreviewData.UnlockIconPath = ""
    PreviewData.LockIconPath = ""
    PreviewData.bIsHiddenType = false
  end
  return PreviewData
end
function VehicleCollectSystem:GetVehiclePlateConsumeNum(VehicleType)
  local tCarCost = self:GetCarCostUCTable()
  if tCarCost and tCarCost[VehicleType] then
    return tCarCost[VehicleType].cost_uc_num
  end
  return 0
end
function VehicleCollectSystem:NeedShowRedPoint()
  local NeedShowFeatureIDList = self:GetNeedShowRedPointFeatureList()
  if NeedShowFeatureIDList and next(NeedShowFeatureIDList) then
    return true
  end
  return false
end
function VehicleCollectSystem:FeatureNeedShowRedPoint(FeatureID)
  local NeedShowFeatureIDList = self:GetNeedShowRedPointFeatureList()
  for _, _FeatureID in pairs(NeedShowFeatureIDList) do
    if _FeatureID == FeatureID then
      return true
    end
  end
end
function VehicleCollectSystem:GetNeedShowRedPointFeatureList()
  local NeedShowFeatureIDList = {}
  local BrandData = self:GetVehicleBrandData()
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local SportCarCollectNewType = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eSportCarCollectNewType)
  SportCarCollectNewType = SportCarCollectNewType or {}
  for _, Data in pairs(BrandData) do
    local VehicleType = Data.VehicleType
    local CollectCfg = VehiclePlateLicenseUtil.GetCollectCarCfgByType(VehicleType)
    local OwnNum = self:GetOwnVehicleNumByType(VehicleType)
    for _, Cfg in pairs(CollectCfg) do
      if OwnNum >= Cfg.UnlockNum then
        local FeatureID = Cfg.FeatureID
        if SportCarCollectNewType[FeatureID] == nil or SportCarCollectNewType[FeatureID] == 0 then
          table.insert(NeedShowFeatureIDList, FeatureID)
        end
      end
    end
  end
  return NeedShowFeatureIDList
end
function VehicleCollectSystem:EliminateRedPoint(FeatureID)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local SportCarCollectNewType = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eSportCarCollectNewType)
  SportCarCollectNewType = SportCarCollectNewType or {}
  SportCarCollectNewType[FeatureID] = 1
  LogicPlayerPrefs.SaveDataToFile_N(SportCarCollectNewType, PlayerPrefsConfig.eSportCarCollectNewType)
end
function VehicleCollectSystem:OpenVehicleWorkShop(SystemID, vars)
  log(bWriteLog and "VehicleCollectSystem OpenVehicleWorkShop SystemID" .. tostring(SystemID))
  log_tree("VehicleCollectSystem OpenVehicleWorkShop vars", vars)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_VEHICLE_REFIT_SWITCH, true) then
    log(bWriteLog and "VehicleCollectSystem OpenVehicleWorkShop CheckLobbyMenuOpen false")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.VehicleSystem_Main_UIBP, SystemID, vars)
end
function VehicleCollectSystem:GetSubFeatureIDs(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return {}
  end
  local FeatureIDs = {}
  for _, FeatureID in pairs(CollectCarFeatureCfg.FeatureIDArray_a) do
    table.insert(FeatureIDs, FeatureID)
  end
  return FeatureIDs
end
function VehicleCollectSystem:GetAliasID(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return {}
  end
  return CollectCarFeatureCfg.AliasID
end
function VehicleCollectSystem:GetAliasData(AliasID)
  local AliasData = {}
  AliasData.aliasId = AliasID
  AliasData.aliasTitle = FuncUtil.Gen_title(AliasID)
  local cfg = CDataTable.GetTableData("AliasCfg", AliasID)
  if cfg ~= nil then
    AliasData.aliasIconUrl = cfg.AliasIconPath
    AliasData.aliasIconUrlBig = cfg.AliasIconPathBig
  end
  return AliasData
end
function VehicleCollectSystem:GetAliasRewardIndex(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return nil
  end
  return CollectCarFeatureCfg.RewardID
end
function VehicleCollectSystem:IsOpenHighTire(VehicleID, UID, Position, Source)
  Source = Source or EWardrobeDataSource.Wardrobe
  local VehicleType = self:GetVehicleType(VehicleID)
  if VehicleType < 0 then
    return false
  end
  if tonumber(UID) == tonumber(DataMgr.roleData.uid) or tonumber(UID) == 0 then
    local bIsUnlock = self:IsUnlockFeatureEffect(VehicleType, 6, VehicleID, Source)
    local UnLockFeature = self:HasUnLockFeature(VehicleType, VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.TIRE, Source)
    if not UnLockFeature and not bIsUnlock then
      return
    end
    local CloseTireSwitch = self:GetCloseTireSwitch(VehicleType, Source) == 1
    return not CloseTireSwitch
  else
    Position = Position or 1
    local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local show_tire_feature = false
    if GarageThemeSystem:IsInGarageTheme() then
      show_tire_feature = TeamUpNewSystem.GetGarageVehicleShowTireConfig(UID, Position)
    else
      show_tire_feature = TeamUpNewSystem.GetTeamShowTireConfig(UID)
    end
    return show_tire_feature
  end
end
function VehicleCollectSystem:IsHiddenVehicle(VehicleID)
  local CollectCarInfo = CDataTable.GetTableData("CollectCarInfo", VehicleID)
  if CollectCarInfo then
    return CollectCarInfo.IsHiddenType
  end
  return false
end
function VehicleCollectSystem:GetPlateCameraConfig(ItemID)
  print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateCameraConfig ItemID" .. tostring(ItemID))
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig or not SportsCarCollectConfig.CameraType then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateCameraConfig not SportsCarCollectConfig" .. tostring(ItemID))
    return self.CameraConfig[1]
  end
  return self.CameraConfig[SportsCarCollectConfig.CameraType]
end
function VehicleCollectSystem:NeedShowSubtabLock(FeatureID)
  local FeatureType = VehiclePlateLicenseUtil.GetFeatureType(FeatureID)
  local GarageThemeSystem = require("client.logic.lobby.GarageThemeSystem")
  local bHasGarageTheme = GarageThemeSystem:HasOwnGarageTheme()
  if FeatureType == VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.Garage and not bHasGarageTheme then
    return true
  end
  return false
end
function VehicleCollectSystem:GetSubtabDownText(FeatureID)
  local FeatureType = VehiclePlateLicenseUtil.GetFeatureType(FeatureID)
  if FeatureType ~= VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.Garage then
    return
  end
  return "\230\139\165\230\156\137\232\183\145\232\189\166\229\164\167\229\142\133\232\167\163\233\148\129"
end
function VehicleCollectSystem:GetUnlockRewardInfo(VehicleType)
  local car_collection = self:GetAllCarCollectionData(EWardrobeDataSource.Wardrobe)
  if not car_collection then
    return
  end
  local FeatureType_DIEDBOX = VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.DIEDBOX
  local FeatureType_TIRE = VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.TIRE
  local info = car_collection[VehicleType]
  if info and info.unlock_data then
    local ownCarNum = self:GetOwnVehicleNumByType(VehicleType)
    local diedBox = info.unlock_data[FeatureType_DIEDBOX]
    local trie = info.unlock_data[FeatureType_TIRE]
    if trie and trie.award_status == 0 and 2 <= ownCarNum then
      return VehicleType, FeatureType_TIRE
    end
    if diedBox and diedBox.award_status == 0 and 3 <= ownCarNum then
      return VehicleType, FeatureType_DIEDBOX
    end
  end
end
function VehicleCollectSystem:GetCurrencyInfoByTypeAndID(VehicleID, FeatureID, VehicleType)
  local CollectCarCfg = CDataTable.GetTableDataByFilter("CollectCarCfg", "VehicleType", VehicleType, "FeatureID", FeatureID)
  local FeatureType = CollectCarCfg.FeatureType
  local currencyCfg = CDataTable.GetTableDataByFilter("FeatureUnlockPriceCfg", "CarID", VehicleID, "FeatureID", FeatureType)
  if not currencyCfg then
    return
  end
  return currencyCfg.CurrencyID, currencyCfg.CurrencyNum
end
function VehicleCollectSystem:GetReturnAwardInfo(VehicleType, FeatureType)
  local car_collection = self:GetAllCarCollectionData(EWardrobeDataSource.Wardrobe)
  if not car_collection or not car_collection[VehicleType] then
    return
  end
  local unlock_data = car_collection[VehicleType].unlock_data
  if not unlock_data or not unlock_data[FeatureType] then
    return
  end
  local award_status = unlock_data[FeatureType].award_status
  local unlock_car_list = unlock_data[FeatureType].unlock_car_list
  local award_cnt = 0
  local item_id
  local vehicleID_List = {}
  for vehicle_id, list in pairs(unlock_car_list) do
    if 0 < list.unlock_item_cnt then
      table.insert(vehicleID_List, vehicle_id)
    end
    award_cnt = list.unlock_item_cnt + award_cnt
    item_id = list.unlock_item_id
  end
  return item_id, award_cnt, award_status, vehicleID_List
end
function VehicleCollectSystem:IsUnlockFeatureEffect(VehicleType, FeatureID, VehicleID, Source)
  local CollectCarCfg = CDataTable.GetTableDataByFilter("CollectCarCfg", "VehicleType", VehicleType, "FeatureID", FeatureID)
  if not CollectCarCfg then
    return false
  end
  local FeatureType = CollectCarCfg.FeatureType
  local carCollection = self:GetAllCarCollectionData(Source)
  if not carCollection or not carCollection[VehicleType] then
    return false
  end
  local unlock_data = carCollection[VehicleType].unlock_data
  if unlock_data and unlock_data[FeatureType] then
    local unlock_car_list = unlock_data[FeatureType].unlock_car_list
    if unlock_car_list[VehicleID] then
      return true
    end
  end
  return false
end
function VehicleCollectSystem:HandleUnlockFeatureEffectRsp()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
  local VehicleCollectHandler = require("client.network.Protocol.VehicleCollectHandler")
  VehicleCollectHandler.send_get_car_collection_info_req()
  ShowNotice(LocUtil.GetLocalizeResStr(77290))
end
function VehicleCollectSystem:HandleGetRewardRsp(car_type, feature_id, res_list)
  local VehicleCollectHandler = require("client.network.Protocol.VehicleCollectHandler")
  local car_collection = self:GetAllCarCollectionData(EWardrobeDataSource.Wardrobe)
  if not car_collection or not car_collection[car_type] then
    return
  end
  local unlock_data = car_collection[car_type].unlock_data
  unlock_data[feature_id].award_status = 1
  for item_id, item_num in pairs(res_list) do
    local itemInfo = {
      {
        res_id = item_id,
        count = item_num,
        valid_hours = 0
      }
    }
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemInfo)
  end
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  generalLabReddotData.ReduceReddotNum()
  local VehicleCollectHandler = require("client.network.Protocol.VehicleCollectHandler")
  VehicleCollectHandler.send_get_car_collection_info_req()
end
function VehicleCollectSystem:IsShowVehicleReddot()
  if not self.car_collection then
    return
  end
  local reddot_num = 0
  local FeatureType_DIEDBOX = VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.DIEDBOX
  local FeatureType_TIRE = VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.TIRE
  for vehicleType, info in pairs(self.car_collection) do
    if info.unlock_data then
      local ownCarNum = self:GetOwnVehicleNumByType(vehicleType)
      local diedBox = info.unlock_data[FeatureType_DIEDBOX]
      local trie = info.unlock_data[FeatureType_TIRE]
      if trie and trie.award_status == 0 and 2 <= ownCarNum then
        reddot_num = reddot_num + 1
      end
      if diedBox and diedBox.award_status == 0 and 3 <= ownCarNum then
        reddot_num = reddot_num + 1
      end
    end
  end
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  local reddotVehicle = require("client.slua.logic.vehicle.reddot_vehicle")
  local gropData = generalLabReddotData.GetReddotData(reddot_macro.SystemName.Vehicle)
  if gropData and gropData[reddotVehicle.SubSysID.VehicleCollect] and gropData[reddotVehicle.SubSysID.VehicleCollect][reddotVehicle.SubSysID.NewPlateBG] then
    log(bWriteLog and "gropData.Vehicle  " .. tostring(reddot_num))
    gropData[reddotVehicle.SubSysID.VehicleCollect][reddotVehicle.SubSysID.GetReward].newCount = reddot_num
    EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_WorkShop)
  end
end
function VehicleCollectSystem:IsHasUnlockTireFeature(VehicleType)
  local car_collection = self:GetAllCarCollectionData(EWardrobeDataSource.Wardrobe)
  if not car_collection or not car_collection[VehicleType] then
    return false
  end
  local unlock_data = car_collection[VehicleType].unlock_data
  if not unlock_data then
    return false
  end
  return true
end
function VehicleCollectSystem:GetFeatureTypeByID(VehicleType, FeatureID)
  local CollectCarCfg = CDataTable.GetTableDataByFilter("CollectCarCfg", "VehicleType", VehicleType, "FeatureID", FeatureID)
  local FeatureType = CollectCarCfg.FeatureType
  return FeatureType
end
function VehicleCollectSystem:IsBentley(ItemID)
  local VehicleType = self:GetVehicleType(ItemID)
  if VehicleType == 10 then
    return true
  end
  return false
end
function VehicleCollectSystem:UpdateVechileVoiceSwitch(car_voice_switch)
  log(bWriteLog and "VehicleCollectSystem:UpdateVechileVoiceSwitch car_voice_switch:" .. tostring(car_voice_switch))
  self.  EventSystem:postEvent(EVENTTYPE_VEHICLE_COLLECT, EVENTID_VEHICLE_VOICE_SWITCH_CHANGE)
end
function VehicleCollectSystem:CheckIsCarVoiceOpen()
  log(bWriteLog and "VehicleCollectSystem:CheckIsCarVoiceOpen car_voice_switch:" .. tostring(self.car_voice_switch))
  if self.car_voice_switch and self.car_voice_switch == 0 then
    return false
  end
  return true
end
function VehicleCollectSystem:SetVehicleVoiceSwitch(bOpen)
  log(bWriteLog and "VehicleCollectSystem:SetVehicleVoiceSwitch bOpen:" .. tostring(bOpen))
  bOpen = bOpen or false
  if bOpen == self:CheckIsCarVoiceOpen() then
    log(bWriteLog and "VehicleCollectSystem:SetVehicleVoiceSwitch same switch no need to req")
    return
  end
  local switch_value = 0
  if bOpen then
    switch_value = 1
  end
  local VehicleCollectHandler = require("client.network.Protocol.VehicleCollectHandler")
  VehicleCollectHandler.send_set_car_voice_switch_req(switch_value)
end
function VehicleCollectSystem:on_get_car_collection_info_rsp(car_collection, car_collection_unlock_table, car_cost_uc_table, inherit_car_collection)
  self.  self.  self.  self.end
function VehicleCollectSystem:GetAllCarCollectionData(Source)
  if Source == EWardrobeDataSource.InheritWardrobe then
    return self.inherit_car_collection
  end
  return self.car_collection
end
function VehicleCollectSystem:GetCarCollectionUnlockTable()
  return self.car_collection_unlock_table
end
function VehicleCollectSystem:GetCarCostUCTable()
  return self.car_cost_uc_table
end
function VehicleCollectSystem:SetTireSwitch(car_type, value)
  log(bWriteLog and "VehicleCollectSystem:SetTireSwitch car_type" .. tostring(car_type) .. " value " .. tostring(value))
  self.car_collection = self.car_collection or {}
  self.car_collection[car_type] = self.car_collection[car_type] or {}
  self.car_collection[car_type].tire_switch = value
  EventSystem:postEvent(EVENTTYPE_VEHICLE_COLLECT, EVENTID_VEHICLE_TIRE_SWITCH_CHANGE)
end
function VehicleCollectSystem:GetCloseTireSwitch(car_type, source)
  if source == EWardrobeDataSource.InheritWardrobe then
    return self.inherit_car_collection and self.inherit_car_collection[car_type] and self.inherit_car_collection[car_type].tire_switch or 0
  end
  return self.car_collection and self.car_collection[car_type] and self.car_collection[car_type].tire_switch or 0
end
function VehicleCollectSystem:IsAllCarCollected(nVehicleType)
  local nCarTotalSum = self:GetSumVehicleNumByType(nVehicleType)
  local nCarCollectedSum = self:GetOwnVehicleNumByType(nVehicleType)
  return nCarTotalSum <= nCarCollectedSum
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CVehicleCollectSystem = class(CModuleBase, nil, VehicleCollectSystem)
return CVehicleCollectSystem