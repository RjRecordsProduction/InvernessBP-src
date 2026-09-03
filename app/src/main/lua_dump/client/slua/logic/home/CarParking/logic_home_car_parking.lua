local logic_home_car_parking = {}
local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
local homeCarParkingConfig = require("client.slua.logic.home.CarParking.Config.home_car_parking_config")
local TableUtil = require("common.table_util")
function logic_home_car_parking:DefineAndResetData()
  self.coinID = 1230
  self.coinNum = 0
  self.carCapacity = nil
  self.selfHomeIncomeRate = nil
  self.expelIncomeRate = nil
  self.bCarParkingOpen = nil
  self.sessionState = nil
  self.carParkingUpgradeTable = nil
  self.carParkingMaxLevelTable = nil
  self.carParkingSlotUnlockTable = nil
  self.carIncomeCache = {}
  self.myHomeUIDs = nil
  self.giftLevels = {}
  self.sessionConfig = nil
  self.giftConifg = nil
  self.bHomeDoorEntranceReddotEnableShow = true
  self.parkSortType = nil
end
function logic_home_car_parking:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZero, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVETNID_PLANPH_JOINT_INFO_UPDATE, self.OnJointInfoUpdate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.OnLoadingFinish, self)
end
function logic_home_car_parking:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_home_car_parking:OnPostSwitchGameStatus")
  self.carIncomeCache = {}
  self.bCarParkingOpen = nil
  self.sessionConfig = nil
  self.sessionState = nil
end
function logic_home_car_parking:IsCarParkingOpen()
  if not homeCarParkingConfig.carParkingSwitch then
    log(bWriteLog and "logic_home_car_parking:IsCarParkingOpen switch not open")
    return false
  end
  if self.bCarParkingOpen ~= nil then
    return self.bCarParkingOpen
  end
  self.bCarParkingOpen = true
  local openTime = CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "open_time").Value
  local openVersion = CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "open_version").Value
  openTime = string.gsub(openTime, "^[\"]*([^\"].*[^\"])[\"]*$", "%1")
  openVersion = string.gsub(openVersion, "^[\"]*([^\"].*[^\"])[\"]*$", "%1")
  log(bWriteLog and string.format("logic_home_car_parking:IsCarParkingOpen openTime=%s, openVersion=%s", tostring(openTime), tostring(openVersion)))
  local TimeUtil = require("client.common.time_util")
  if not TimeUtil.CheckAfterTimeStr(openTime) then
    log(bWriteLog and "logic_home_car_parking:IsCarParkingOpen before openTime")
    self.bCarParkingOpen = false
  end
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetClientFormat(Client.GetAppVersion())
  if version_util.CompareVersionStandard(curVersion, openVersion) < 0 then
    log(bWriteLog and string.format("logic_home_car_parking:IsCarParkingOpen curVersion=%s, openVersion=%s not open!", tostring(curVersion), tostring(openVersion)))
    self.bCarParkingOpen = false
  end
  return self.bCarParkingOpen
end
function logic_home_car_parking:IsCarParkingActivityValid()
  if not self:IsCarParkingOpen() then
    log(bWriteLog and "logic_home_car_parking:IsCarParkingActivityValid activity not open")
    return false
  end
  if self:GetSessionConfig() == nil then
    log(bWriteLog and "logic_home_car_parking:IsCarParkingActivityValid SessionConfig == nil")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eHomeEnterSafetyProtocol
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  if not saveData.hasAgreed then
    log(bWriteLog and "logic_home_car_parking:IsCarParkingActivityValid home enter safety protocol not agreed")
    return false
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(PlanPH_GamePlay_Tools.GetMyUid())
  local openLevel = tonumber(CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "open_manor_level").Value)
  if not homeProfile or openLevel > homeProfile.grow_info.level then
    log(bWriteLog and "logic_home_car_parking:IsCarParkingActivityValid home level not enough")
    return false
  end
  log(bWriteLog and "logic_home_car_parking:IsCarParkingActivityValid activity valid")
  return true
end
function logic_home_car_parking:GetCarCapacity()
  if not self.carCapacity then
    self.carCapacity = tonumber(CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "garage_capacity").Value)
    log(bWriteLog and string.format("logic_home_car_parking:GetCarCapacity capacity=%d", self.carCapacity))
  end
  return self.carCapacity
end
function logic_home_car_parking:GetSelfHomeParkingIncomeRate()
  if not self.selfHomeIncomeRate then
    local rate = tonumber(CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "park_owner_manor_profit").Value)
    self.selfHomeIncomeRate = math.floor(rate * 100)
    log(bWriteLog and string.format("logic_home_car_parking:GetSelfHomeParkingIncomeRate selfHomeIncomeRate=%d", self.selfHomeIncomeRate))
  end
  return self.selfHomeIncomeRate
end
function logic_home_car_parking:GetExpelIncomeRate()
  if not self.expelIncomeRate then
    local rate = tonumber(CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "park_owner_profit").Value)
    self.expelIncomeRate = math.floor(rate * 100)
    log(bWriteLog and string.format("logic_home_car_parking:GetExpelIncomeRate expelIncomeRate=%d", self.expelIncomeRate))
  end
  return self.expelIncomeRate
end
function logic_home_car_parking:GetCoinID()
  return self.coinID
end
function logic_home_car_parking:GetSessionConfig()
  if not self.sessionConfig then
    self:UpdateSessionConfig()
  end
  if self.sessionConfig then
    log(bWriteLog and string.format("logic_home_car_parking:GetSessionConfig SessionID=%s", tostring(self.sessionConfig.SessionID)))
  else
    log(bWriteLog and "logic_home_car_parking:GetSessionConfig sessionConfig==nil")
  end
  return self.sessionConfig
end
function logic_home_car_parking:GetSessionConfigByClientVersion()
  local sessionTable = CDataTable.GetTable("PlanPH_CarParkingSessionTable")
  if sessionTable == nil then
    return
  end
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetClientFormat(Client.GetAppVersion())
  for _, session in pairs(sessionTable) do
    local version = session.MinVersion
    if version_util.CompareVersionStandard(curVersion, version) == 0 then
      return session
    end
  end
end
function logic_home_car_parking:GetSessionState()
  if not self.sessionState then
    self:UpdateSessionState()
  end
  return self.sessionState
end
function logic_home_car_parking:GetCoinNum()
  return self.coinNum
end
function logic_home_car_parking:GetExpectedIncome(startTime, incomePerHour, discount)
  log(bWriteLog and string.format("logic_home_car_parking:GetExpectedIncome startTime=%d, incomePerHour=%d, discount=%s", startTime, incomePerHour, tostring(discount)))
  if not startTime or not incomePerHour then
    return 0
  end
  discount = discount or 100
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local incomeCount = math.floor((curTime - startTime) / 3600)
  local totalIncome = math.floor(incomePerHour * incomeCount * discount / 100)
  log(bWriteLog and string.format("logic_home_car_parking:GetExpectedIncome totalIncome=%d", totalIncome))
  return totalIncome
end
function logic_home_car_parking:GetParkingLotData_TargetLevel(itemID, level)
  local upgradeTable = self:GetCarParkingUpgradeTable()
  return TableUtil.GetTableValue(upgradeTable, itemID, level)
end
function logic_home_car_parking:GetParkingLotData_MaxLevel(itemID)
  local maxLevelTable = self:GetCarParkingMaxLevelTable()
  return maxLevelTable[itemID]
end
function logic_home_car_parking:GetParkingSlotUnlockLevel(itemID, slotIndex)
  local slotUnlockTable = self:GetCarParkingSlotUnlockLevelTable()
  return TableUtil.GetTableValue(slotUnlockTable, itemID, slotIndex)
end
function logic_home_car_parking:GetCarParkingUpgradeTable()
  if not self.carParkingUpgradeTable then
    local carParkingUpgradeRowTable = CDataTable.GetTable("PlanPH_CarParkingUpgrade")
    if not carParkingUpgradeRowTable then
      log_error("logic_home_car_parking:GetCarParkingUpgradeTable carParkingUpgradeTable is nil")
    end
    self.carParkingUpgradeTable = {}
    for _, rowData in pairs(carParkingUpgradeRowTable) do
      local itemID = rowData.ItemID
      local itemLevel = rowData.ItemLevel
      if not self.carParkingUpgradeTable[itemID] then
        self.carParkingUpgradeTable[itemID] = {}
      end
      self.carParkingUpgradeTable[itemID][itemLevel] = rowData
    end
    log_tree(bWriteLog and "logic_home_car_parking:GetCarParkingUpgradeTable first init, table=", self.carParkingUpgradeTable)
  end
  return self.carParkingUpgradeTable
end
function logic_home_car_parking:GetCarParkingMaxLevelTable()
  if not self.carParkingMaxLevelTable then
    self.carParkingMaxLevelTable = {}
    local carParkingUpgradeTable = self:GetCarParkingUpgradeTable()
    for itemID, itemUpgradeTale in pairs(carParkingUpgradeTable) do
      local maxLevel = -1
      local maxLevelData
      for level, levelData in pairs(itemUpgradeTale) do
        if level > maxLevel then
          maxLevel = level
          maxLevelData = levelData
        end
      end
      self.carParkingMaxLevelTable[itemID] = maxLevelData
    end
    log_tree(bWriteLog and "logic_home_car_parking:GetCarParkingMaxLevelTable first init, table=", self.carParkingMaxLevelTable)
  end
  return self.carParkingMaxLevelTable
end
function logic_home_car_parking:GetCarParkingSlotUnlockLevelTable()
  if not self.carParkingSlotUnlockTable then
    self.carParkingSlotUnlockTable = {}
    local upgradeTable = self:GetCarParkingUpgradeTable()
    for itemID, _ in pairs(upgradeTable) do
      local unlockLevelMap = {}
      local maxLevelData = self:GetParkingLotData_MaxLevel(itemID)
      local maxPublicSlotNum = maxLevelData.PublicSlotNum
      local maxFriendSlotNum = maxLevelData.FriendSlotNum
      local curPublicSlotNum = 0
      local curFriendSlotNum = 0
      local maxLevel = maxLevelData.ItemLevel
      for level = 1, maxLevel do
        local curLevelData = self:GetParkingLotData_TargetLevel(itemID, level)
        local publicSlotNum = curLevelData.PublicSlotNum
        while curPublicSlotNum < publicSlotNum do
          curPublicSlotNum = curPublicSlotNum + 1
          unlockLevelMap[curPublicSlotNum] = level
        end
        local friendSlotNum = curLevelData.FriendSlotNum
        while curFriendSlotNum < friendSlotNum do
          curFriendSlotNum = curFriendSlotNum + 1
          unlockLevelMap[curFriendSlotNum + maxPublicSlotNum] = level
        end
        if curFriendSlotNum == maxFriendSlotNum and curPublicSlotNum == maxPublicSlotNum then
          break
        end
      end
      self.carParkingSlotUnlockTable[itemID] = unlockLevelMap
    end
    log_tree(bWriteLog and "logic_home_car_parking:GetCarParkingSlotUnlockLevelTable first init, table=", self.carParkingSlotUnlockTable)
  end
  return self.carParkingSlotUnlockTable
end
function logic_home_car_parking:IsParkingLotHasCarPlatform(itemID)
  local maxLevelData = self:GetParkingLotData_MaxLevel(itemID)
  if not maxLevelData then
    log(bWriteLog and string.format("logic_home_car_parking:IsParkingLotHasCarPlatform maxLevelData is nil, itemID=%s", tostring(itemID)))
    return false
  end
  return maxLevelData.CarPlatformNum > 0
end
function logic_home_car_parking:GetCarIncome(itemID)
  if self.carIncomeCache[itemID] then
    return self.carIncomeCache[itemID]
  end
  local itemData = CDataTable.GetTableData("Item", itemID)
  if not itemData then
    return 0
  end
  local income = 0
  local quality = itemData.ItemQuality
  local qualityIncomeData = CDataTable.GetTableData("PlanPH_CarParkingQualityBuff", quality)
  if qualityIncomeData then
    income = income + qualityIncomeData.IncomeBuff
  end
  local carIncomeData = CDataTable.GetTableData("PlanPH_CarParkingCarBuff", itemID)
  if carIncomeData then
    local TimeUtil = require("client.common.time_util")
    local startTime = carIncomeData.StartTime
    local endTime = carIncomeData.EndTime
    if TimeUtil.UnixTimeStrBetween(startTime, endTime) == 0 then
      income = income + carIncomeData.IncomeBuff
    end
  end
  self.carIncomeCache[itemID] = income
  log(bWriteLog and string.format("logic_home_car_parking:GetCarIncome itemID=%s, income=%s", tostring(itemID), tostring(income)))
  return income
end
function logic_home_car_parking:GetCarIncomeBuff(itemID)
  local carIncomeData = CDataTable.GetTableData("PlanPH_CarParkingCarBuff", itemID)
  if carIncomeData then
    local TimeUtil = require("client.common.time_util")
    local startTime = carIncomeData.StartTime
    local endTime = carIncomeData.EndTime
    if TimeUtil.UnixTimeStrBetween(startTime, endTime) == 0 then
      return carIncomeData.IncomeBuff
    end
  end
  return 0
end
function logic_home_car_parking:IsInMyHomeUIDs(key)
  if not key then
    return false
  end
  if not self.myHomeUIDs then
    self:UpdateJointMembers()
    log_tree("logic_home_car_parking:IsInMyHomeUIDs homeUIDs=", self.myHomeUIDs)
  end
  return self.myHomeUIDs[key]
end
function logic_home_car_parking:GetGiftLevel(giftID)
  if not giftID then
    return 0
  end
  if not self.giftLevels[giftID] then
    local giftData = CDataTable.GetTableData("PlanPH_CarParkingGiftLevelTable", giftID)
    local level = giftData and giftData.Level or 0
    self.giftLevels[giftID] = level
    log(bWriteLog and string.format("logic_home_car_parking:GetGiftLevel [%d]->[%d]", giftID, level))
  end
  return self.giftLevels[giftID]
end
function logic_home_car_parking:GetLobbyVehicleList()
  local SocialBottomVehicleSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_vehicle")
  SocialBottomVehicleSystem.InitVehicleList()
  local tempVehicleList = {}
  for vehicleType, _ in pairs(SocialBottomVehicleSystem.vehicleCategory) do
    if vehicleType == SocialBottomVehicleSystem.ENUM_VEHICLE_CATEGORY_TYPE.Other then
      local skinItemList = SocialBottomVehicleSystem.GetVehicleSkin(vehicleType, false)
      for _, vehicleData in pairs(skinItemList) do
        local itemID = vehicleData.res_id
        local itemCfg = CDataTable.GetTableData("Item", itemID)
        if itemCfg and itemCfg.ItemSubType and homeCarParkingConfig.validSubTypesInOtherCategory[itemCfg.ItemSubType] then
          table.insert(tempVehicleList, vehicleData)
        end
      end
    elseif not TableUtil.IsInTable(homeCarParkingConfig.ignoreVehicleTypes, vehicleType) then
      local skinItemList = SocialBottomVehicleSystem.GetVehicleSkin(vehicleType, false)
      TableUtil.TableConcat(tempVehicleList, skinItemList)
    end
  end
  local myUID = PlanPH_GamePlay_Tools.GetMyUid()
  local vehicleList = {}
  local vehicleMap = {}
  for _, vehicleData in pairs(tempVehicleList) do
    local itemID = vehicleData.res_id
    local income = self:GetCarIncome(itemID)
    if 0 < income and not vehicleMap[itemID] then
      vehicleData.      vehicleData.      vehicleData.owner = myUID
      table.insert(vehicleList, vehicleData)
      vehicleMap[itemID] = true
    end
  end
  local PlanPH_CarParking_SubSystem_Client = SubsystemMgr:Get("PlanPH_CarParking_SubSystem_Client")
  table.sort(vehicleList, function(a, b)
    local itemID_a = a.itemID
    local itemID_b = b.itemID
    local income_a = self:GetCarIncome(itemID_a)
    local income_b = self:GetCarIncome(itemID_b)
    local isAdded_a = PlanPH_CarParking_SubSystem_Client:IsVehicleAdded(itemID_a)
    local isAdded_b = PlanPH_CarParking_SubSystem_Client:IsVehicleAdded(itemID_b)
    if isAdded_a and not isAdded_b then
      return false
    end
    if not isAdded_a and isAdded_b then
      return true
    end
    if income_a ~= income_b then
      return income_a > income_b
    else
      return itemID_a > itemID_b
    end
  end)
  return vehicleList
end
function logic_home_car_parking:GetParkSortType()
  if not self.parkSortType then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeCarParking) or {}
    if data.parkSortType then
      self.parkSortType = data.parkSortType
    else
      self.parkSortType = homeCarParkingConfig.ESortType.Income
    end
  end
  return self.parkSortType
end
function logic_home_car_parking:SetParkSortType(sortType)
  log(bWriteLog and string.format("logic_home_car_parking:SetParkSortType sortType=%s", tostring(sortType)))
  if self.parkSortType == sortType then
    log(bWriteLog and "logic_home_car_parking:SetParkSortType sortType is same")
    return
  end
  self.parkSortType = sortType
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeCarParking) or {}
  data.parkSortType = sortType
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eHomeCarParking)
end
function logic_home_car_parking:UpdateCoinNumber(currency)
  if currency then
    self.coinNum = tonumber(currency)
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_PARKING_COIN_UPDATE, currency)
  end
end
function logic_home_car_parking:OnNextDayZero()
  log(bWriteLog and "logic_home_car_parking:OnNextDayZero")
  self:UpdateSessionConfig()
  self:UpdateSessionState()
  self.carIncomeCache = {}
  self.bCarParkingOpen = nil
end
function logic_home_car_parking:UpdateSessionConfig()
  log(bWriteLog and "logic_home_car_parking:UpdateSessionConfig")
  self.sessionConfig = nil
  local sessionTable = CDataTable.GetTable("PlanPH_CarParkingSessionTable")
  if sessionTable == nil then
    return
  end
  local timeUtil = require("client.common.time_util")
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetClientFormat(Client.GetAppVersion())
  for _, session in pairs(sessionTable) do
    local startTime = session.StartTime
    local endTime = session.EndTime
    local minVersion = session.MinVersion
    if _G.IsEditor then
      minVersion = CDataTable.GetTableData("PlanPH_CarParkingBaseConfig", "open_version").Value
    end
    log_format(bWriteLog and "logic_home_car_parking:UpdateSessionConfig startTime=%s, endTime=%s", startTime, endTime)
    if timeUtil.UnixTimeStrBetween(startTime, endTime) == 0 and 0 <= version_util.CompareVersionStandard(curVersion, minVersion) then
      self.sessionConfig = session
      log(bWriteLog and string.format("logic_home_car_parking:UpdateSessionConfig SessionID=%s", tostring(session.SessionID)))
      return
    end
  end
end
function logic_home_car_parking:UpdateSessionState()
  local timeUtil = require("client.common.time_util")
  local curTime = timeUtil.GetServerTimeInSec()
  local sessionTable = CDataTable.GetTable("PlanPH_CarParkingSessionTable")
  if not sessionTable then
    self.sessionState = -1
    return self.sessionState
  end
  local useSession
  local minDistance = math.huge
  for _, session in ipairs(sessionTable) do
    local startTime = timeUtil.TimeStringToUnixstamp(session.StartTime)
    local endTime = timeUtil.TimeStringToUnixstamp(session.EndTime)
    if curTime >= startTime and curTime <= endTime then
      useSession = session
      break
    end
    local distanceToStart = math.abs(startTime - curTime)
    local distanceToEnd = math.abs(endTime - curTime)
    local minSessionDistance = math.min(distanceToStart, distanceToEnd)
    if minDistance > minSessionDistance then
      minDistance = minSessionDistance
      useSession = session
    end
  end
  if useSession == nil then
    log(bWriteLog and "logic_home_car_parking:UpdateSessionState useSession == nil")
    return
  end
  log(bWriteLog and string.format("logic_home_car_parking:UpdateSessionState curTime=%s, sessionID=%s", tostring(curTime), tostring(useSession.SessionID)))
  local oldState = self.sessionState
  local newState = timeUtil.UnixTimeStrBetween(useSession.StartTime, useSession.EndTime)
  if oldState == -1 and newState == 0 then
    log(bWriteLog and "logic_home_car_parking:UpdateSessionState season start")
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_CAR_PARKING_SESSION_START)
  elseif oldState == 0 and newState == 1 then
    log(bWriteLog and "logic_home_car_parking:UpdateSessionState season end")
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_CAR_PARKING_SESSION_END)
  end
  self.sessionState = newState
  return self.sessionState
end
function logic_home_car_parking:OnJointInfoUpdate()
  log(bWriteLog and "logic_home_car_parking:OnJointInfoUpdate")
  self:UpdateJointMembers()
  log_tree("logic_home_car_parking:OnJointInfoUpdate homeUIDs=", self.myHomeUIDs)
end
function logic_home_car_parking:OnLoadingFinish()
  log(bWriteLog and "logic_home_car_parking:OnLoadingFinish")
  self.carIncomeCache = {}
  self.bCarParkingOpen = nil
  self.sessionConfig = nil
  self.sessionState = nil
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if (GameStatus.IsInLobbyOrMainCity() or PlanPH_GamePlay_Tools.IsPHomeMode()) and self:IsCarParkingActivityValid() then
    self:send_manor_parking_currency_req()
  end
end
function logic_home_car_parking:UpdateJointMembers()
  log(bWriteLog and "logic_home_car_parking:UpdateJointMembers")
  self.myHomeUIDs = {}
  local myUid = PlanPH_GamePlay_Tools.GetMyUid()
  self.myHomeUIDs[myUid] = true
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if not logic_home_joint:HasJointHome() then
    return
  end
  local jointInfo = logic_home_joint:GetHomeJointInfo()
  log_tree("logic_home_car_parking:UpdateJointMembers jointInfo=", jointInfo)
  if not jointInfo then
    return
  end
  local jointMembers = {
    jointInfo.joint_id,
    jointInfo.mate_uid
  }
  for _, uid in pairs(jointMembers) do
    self.myHomeUIDs[uid] = true
  end
  log_tree("logic_home_car_parking:UpdateJointMembers myHomeUIDs=", self.myHomeUIDs)
end
function logic_home_car_parking:GetGiftItemList(giftID)
  if not self.giftConifg then
    self.giftConifg = {}
    local giftData = CDataTable.GetTable("PlanPH_DropTable")
    for key, value in pairs(giftData) do
      if not self.giftConifg[value.DropID] then
        self.giftConifg[value.DropID] = {}
      end
      self.giftConifg[value.DropID][value.DropNum] = {
        DropType = value.DropType,
        DropIsCertain = value.DropIsCertain or 0,
        DropWeight = value.DropWeight,
        DropItemID = value.DropItemID,
        DropCount = value.DropCount,
        DisplaySort = value.DisplaySort
      }
    end
  end
  if not self.giftConifg[giftID] then
    log(bWriteLog and "logic_home_car_parking:GetGiftItemList not found gift id = " .. giftID)
  end
  return self.giftConifg[giftID]
end
function logic_home_car_parking:send_manor_parking_currency_req(bForce)
  log(bWriteLog and "logic_home_car_parking:send_manor_parking_currency_req bForce=" .. tostring(bForce))
  if self.coinNum > 0 and not bForce then
    return
  end
  local PHomeCarParkingHandler = require("client.network.Protocol.PHomeCarParkingHandler")
  PHomeCarParkingHandler.send_manor_parking_currency_req()
end
function logic_home_car_parking:proc_manor_parking_currency_rsp(currency)
  self:UpdateCoinNumber(currency)
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_CAR_PARKING_COIN_RSP, currency)
end
function logic_home_car_parking:proc_manor_parking_currency_notify(currency)
  self:UpdateCoinNumber(currency)
end
function logic_home_car_parking:SetHomeDoorEntranceReddotEnable(bEnableShow)
  self.bHomeDoorEntranceReddotEnableShow = bEnableShow
end
function logic_home_car_parking:GetHomeDoorEntranceReddotEnable()
  return self.bHomeDoorEntranceReddotEnableShow
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_home_car_parking)