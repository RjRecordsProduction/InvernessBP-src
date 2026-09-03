local GarageThemeSystem = {CanCollectPage = 2}
function GarageThemeSystem:DefineAndResetData()
  self.SelfGarageVehicleIDs = {}
  self.GarageVehicleInfo = {}
  self.bDataReceived = false
  self._TouchActor = {}
  self.themeRedDot = nil
end
function GarageThemeSystem:IsGarageTheme(ThemeID)
  local Cfg = CDataTable.GetTableDataByFilter("GarageThemeID", "ItemID", ThemeID)
  if Cfg then
    return true
  end
  return false
end
function GarageThemeSystem:IsInGarageTheme()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  local Cfg = CDataTable.GetTableDataByFilter("GarageThemeID", "SkinID", LobbyThemeManager:GetDisplayLobbySkin())
  if Cfg then
    return true
  end
  return false
end
local GenerateRedDot = function(subID)
  local data = {newCount = 0, subID = subID}
  return data
end
function GarageThemeSystem:GetGarageThemeRedDot()
  if not self.themeRedDot then
    local super_data = require("common.super_data")
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    local systemName = reddot_macro.SystemName.GarageTheme
    self.themeRedDot = super_data.CreateSuperData({desc = systemName, newCount = 0})
    self.themeRedDot[GarageThemeSystem.CanCollectPage] = GenerateRedDot(1)
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    if not reddot_manager:IsRegist(systemName) then
      reddot_manager:Regist(self.themeRedDot)
    end
  end
  return self.themeRedDot[GarageThemeSystem.CanCollectPage]
end
function GarageThemeSystem:IsHaveThemeCanCollect()
  local RedDotData = GarageThemeSystem:GetGarageThemeRedDot()
  if GarageThemeSystem:HasOwnGarageTheme(GarageThemeSystem.CanCollectPage) then
    RedDotData.newCount = 0
    return false
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local isCaneCollect = VehicleCollectSystem:GetOwnMaxTypeCarNum() >= self:GetGarageUnlockNum()
  RedDotData.newCount = isCaneCollect and 1 or 0
  return isCaneCollect
end
function GarageThemeSystem:IsGarageSkinID(SkinID)
  local Cfg = CDataTable.GetTableDataByFilter("GarageThemeID", "SkinID", SkinID)
  if Cfg then
    return true
  end
  return false
end
function GarageThemeSystem:GetUnlockGarageVehicleType()
  local GarageThemeConfig = CDataTable.GetTable("GarageThemeConfig")
  local UnLockList = {}
  local VehicleTypeWithPriority = {}
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  for VehicleType, value in pairs(GarageThemeConfig) do
    local bOpen = ThemeVehicleManager:CheckVehicleTypeHasUnlock(tonumber(VehicleType))
    if bOpen and self:HasUnlockSpecialEffect(tonumber(VehicleType)) then
      local vehicleTypeNum = tonumber(VehicleType)
      local priority = value.SidebarShowPriority or 0
      table.insert(VehicleTypeWithPriority, {vehicleType = vehicleTypeNum, priority = priority})
    end
  end
  table.sort(VehicleTypeWithPriority, function(a, b)
    if a.priority == 0 and b.priority == 0 then
      return a.vehicleType < b.vehicleType
    elseif a.priority == 0 then
      return false
    elseif b.priority == 0 then
      return true
    else
      return a.priority < b.priority
    end
  end)
  for _, item in pairs(VehicleTypeWithPriority) do
    table.insert(UnLockList, item.vehicleType)
  end
  return UnLockList
end
function GarageThemeSystem:GetGarageUnlockNum()
  return 3
end
function GarageThemeSystem:GetSpecialEffectUnlockNum(VehicleType)
  if UIManager.IsUIShow(UIManager.UI_Config.SportsCarExchangeContainer) then
    return 6
  end
  return 7
end
function GarageThemeSystem:GetMaxPositionNum()
  return 7
end
function GarageThemeSystem:GetGarageWardrobeIconPath(VehicleType)
  local GarageThemeConfig = CDataTable.GetTableData("GarageThemeConfig", VehicleType)
  if not GarageThemeConfig then
    log(bWriteLog and "GarageThemeSystem:GetGarageWardrobeIconPath VehicleType" .. tostring(VehicleType))
    return ""
  end
  return GarageThemeConfig.WardrobeIconPath
end
function GarageThemeSystem:GetVehicleData()
  local SocialBottomVehicleSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_vehicle")
  SocialBottomVehicleSystem.InitVehicleList()
  local Result = {}
  for category, _ in pairs(SocialBottomVehicleSystem.vehicleCategory) do
    if self:NeedShowInEditorSubTab(category) then
      local VehicleName = SocialBottomVehicleSystem.GetTabStringByID(category)
      local VehicleList = self:GetEditVehicleList(category)
      table.insert(Result, {VehicleName = VehicleName, VehicleList = VehicleList})
    end
  end
  return Result
end
function GarageThemeSystem:GetEditVehicleList(category)
  local SocialBottomVehicleSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_vehicle")
  local VehicleList = SocialBottomVehicleSystem.GetVehicleSkin(category, true)
  local Result = {}
  for _, itemInfo in pairs(VehicleList) do
    local WardrobeVehiclesTaxonomy = CDataTable.GetTableDataByFilter("WardrobeVehiclesTaxonomy", "ItemSubType", itemInfo.itemSubType)
    if WardrobeVehiclesTaxonomy and WardrobeVehiclesTaxonomy.UseInGarage == 1 then
      table.insert(Result, itemInfo)
    end
  end
  return Result
end
function GarageThemeSystem:HasOwnGarageTheme(nPageIndex)
  local Cfg = CDataTable.GetTableDataByFilter("GarageThemeID", "No", nPageIndex)
  if Cfg then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local WardrobeNum = wardrobe_data:GetHallDepotItemCountByResID(Cfg.ItemID, true)
    if 0 < WardrobeNum then
      return true
    end
  end
  return false
end
function GarageThemeSystem:HasUnlockSpecialEffect(VehicleType)
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local OwnNum = VehicleCollectSystem:GetOwnVehicleNumByType(VehicleType)
  local UnlockNum = self:GetSpecialEffectUnlockNum(VehicleType)
  return OwnNum >= UnlockNum
end
function GarageThemeSystem:NeedShowInEditorSubTab(VehicleType)
  local SocialBottomVehicleSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_vehicle")
  if VehicleType == SocialBottomVehicleSystem.ENUM_VEHICLE_CATEGORY_TYPE.Boat or VehicleType == SocialBottomVehicleSystem.ENUM_VEHICLE_CATEGORY_TYPE.Wingman then
    return false
  end
  return true
end
function GarageThemeSystem:GetSelfGarageVehicleIDs()
  local GarageVehicleInfo = self:GetGarageVehicleInfo()
  if not GarageVehicleInfo then
    return {}
  end
  local GarageVehicleIDs = {}
  for Index, Info in pairs(GarageVehicleInfo) do
    GarageVehicleIDs[Index] = Info.res_id
  end
  return GarageVehicleIDs
end
function GarageThemeSystem:GetSelfGarageVehicleAndSource()
  local GarageVehicleInfo = self:GetGarageVehicleInfo()
  if not GarageVehicleInfo then
    return {}
  end
  local Result = {}
  for Index, Info in pairs(GarageVehicleInfo) do
    Result[Index] = {
      ItemID = Info.res_id,
      Source = EWardrobeDataSource.Wardrobe
    }
  end
  return Result
end
function GarageThemeSystem:GetGarageVehicleInfo()
  if not self.bDataReceived then
    self:ReqGarageData()
    return
  end
  return self.GarageVehicleInfo
end
function GarageThemeSystem:ReqGarageData()
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_get_car_main_page_data_req()
end
function GarageThemeSystem:OnReceiveGarageData(VehicleInfo)
  self.Garage  self.bDataReceived = true
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  ThemeVehicleManager:ShowThemeVehicle()
end
function GarageThemeSystem:GetGarageVehicleID(Position)
  local GarageVehicleIDs = self:GetSelfGarageVehicleIDs()
  return GarageVehicleIDs[Position]
end
function GarageThemeSystem:IsVehicleUsing(ItemID)
  local GarageVehicleIDs = self:GetSelfGarageVehicleIDs()
  for key, value in pairs(GarageVehicleIDs) do
    if value == ItemID then
      return true
    end
  end
  return false
end
function GarageThemeSystem:GetTeamGarageVehicleIDs(uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local CarInfo = TeamUpNewSystem.GetGarageCarInfo(uid)
  if not CarInfo then
    log(bWriteLog and "GarageThemeSystem:GetTeamGarageVehicleIDs not CarInfo")
    return {}
  end
  local List = {}
  for Index, Info in pairs(CarInfo) do
    List[Index] = Info.res_id
  end
  return List
end
function GarageThemeSystem:EquipVehicle(Position, InsID)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_update_car_main_page_slot_req(Position, InsID)
end
function GarageThemeSystem:OnEquipVehicle(slot_id, item_inst_id)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Data = WardrobeData:GetValidHallDepotItemDataByInsID(item_inst_id)
  if not Data then
    self.GarageVehicleInfo[slot_id] = nil
  else
    self.GarageVehicleInfo[slot_id] = {
      inst_id = item_inst_id,
      res_id = Data.resID
    }
  end
  self:ReportSpecialEffectTlog()
  EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE)
end
function GarageThemeSystem:GetRemainInsID(ItemID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemList = WardrobeData:GetHallDepotItemListByResIDValidExpireTime(ItemID)
  log_tree("GarageThemeSystem:GetRemainInsID", {
    ItemList,
    self.GarageVehicleInfo
  })
  local RemainVehicle = {}
  for key, value in pairs(ItemList) do
    local insID = value.insID
    RemainVehicle[insID] = (RemainVehicle[insID] or 0) + value.count
  end
  for key, VehicleInfo in pairs(self.GarageVehicleInfo) do
    if RemainVehicle[tonumber(VehicleInfo.inst_id)] then
      RemainVehicle[tonumber(VehicleInfo.inst_id)] = RemainVehicle[tonumber(VehicleInfo.inst_id)] - 1
    end
  end
  for insID, Count in pairs(RemainVehicle) do
    if 0 < Count then
      return insID
    end
  end
  return nil
end
function GarageThemeSystem:GetRemainCount(ItemID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemList = WardrobeData:GetHallDepotItemListByResIDValidExpireTime(ItemID)
  local Count = 0
  for key, value in pairs(ItemList) do
    Count = Count + value.count
  end
  for key, VehicleInfo in pairs(self.GarageVehicleInfo) do
    if VehicleInfo.res_id == ItemID then
      Count = Count - 1
    end
  end
  return Count
end
function GarageThemeSystem:ReportSpecialEffectTlog()
  local bTriggerSpecialEffect = 1
  local _VehicleType
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local _count = 0
  for key, VehicleInfo in pairs(self.GarageVehicleInfo) do
    local ItemID = VehicleInfo.res_id
    local VehicleType = VehicleCollectSystem:GetVehicleType(ItemID)
    if not _VehicleType then
      _    elseif _VehicleType ~= VehicleType then
      bTriggerSpecialEffect = 0
      break
    end
    _count = _count + 1
  end
  if _count ~= 7 then
    bTriggerSpecialEffect = 0
  end
  log(bWriteLog and "GarageThemeSystem:ReportSpecialEffectTlog bTriggerSpecialEffect:" .. tostring(bTriggerSpecialEffect) .. " VehicleType:" .. tostring(_VehicleType))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.GarageThemeSpecialEffect, bTriggerSpecialEffect, _VehicleType)
end
function GarageThemeSystem:BatchEquipVehicle(InsIDList)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_batch_put_on_sportscar_req(InsIDList)
end
function GarageThemeSystem:OnBatchEquipVehicleRsp(instid_list)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for slot_id, item_inst_id in pairs(instid_list) do
    local Data = WardrobeData:GetValidHallDepotItemDataByInsID(item_inst_id)
    if not Data then
      self.GarageVehicleInfo[slot_id] = nil
    else
      self.GarageVehicleInfo[slot_id] = {
        inst_id = item_inst_id,
        res_id = Data.resID
      }
    end
  end
  self:ReportSpecialEffectTlog()
  EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE)
end
function GarageThemeSystem:GetTeamCarStyleList(UID, ItemID, Position)
  local dbStyleList
  if self:IsInGarageTheme() then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    dbStyleList = TeamUpNewSystem.GetGarageRefitList(UID, Position)
  else
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local _, _dbStyleList = HallThemeUtils.GetTeamMemberVehicle(UID)
    dbStyleList = _dbStyleList
  end
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  local StyleList = VehicleRefitHandler.GetCarStyleList(ItemID, nil, nil, dbStyleList)
  return StyleList
end
function GarageThemeSystem:GetGaragePreviewCarList(VehicleType)
  local List = {}
  local CarList = self:GetGaragePreviewConfigCarList(VehicleType)
  for Position, ItemID in pairs(CarList) do
    if Position <= self:GetMaxPositionNum() then
      table.insert(List, ItemID)
    end
  end
  return List
end
function GarageThemeSystem:GetGarageShowCarInsIDList(VehicleType)
  local List = {}
  local CarList = self:GetGarageConfigCarList(VehicleType)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for Position, ItemID in pairs(CarList) do
    if #List < self:GetMaxPositionNum() then
      local HasItem = wardrobe_data:HasItem(ItemID, true)
      if HasItem then
        local Data = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ItemID)
        if Data then
          table.insert(List, Data.insID)
        end
      end
    end
  end
  return List
end
function GarageThemeSystem:GetGarageConfigCarList(VehicleType)
  local GarageThemeConfig = CDataTable.GetTableData("GarageThemeConfig", VehicleType)
  if not GarageThemeConfig then
    log(bWriteLog and "GarageThemeSystem:GetGarageConfigCarList VehicleType" .. tostring(VehicleType))
    return
  end
  local StringUtil = require("common.string_util")
  local List = StringUtil.SplitToNum(GarageThemeConfig.VehicleList, ";")
  return List
end
function GarageThemeSystem:GetGaragePreviewConfigCarList(VehicleType)
  local GarageThemeConfig = CDataTable.GetTableData("GarageThemeConfig", VehicleType)
  if not GarageThemeConfig then
    log(bWriteLog and "GarageThemeSystem:GetGarageConfigCarList VehicleType" .. tostring(VehicleType))
    return {}
  end
  local StringUtil = require("common.string_util")
  local List = StringUtil.SplitToNum(GarageThemeConfig.PreviewVehicleList, ";")
  return List
end
function GarageThemeSystem:SpawnEditorTouchActor()
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  local model_util = require("client.common.model_util")
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  local SceneItemID = LobbyThemeManager:GetDisplayItemID()
  if not self:IsGarageTheme(SceneItemID) then
    log(bWriteLog and "GarageThemeSystem:SpawnEditorTouchActor not garage theme")
    return
  end
  for i = 1, self:GetMaxPositionNum() do
    if not slua.isValid(self._TouchActor[i]) then
      local Actor = model_util.SpawnActor("/Game/Arts_PlayerBluePrints/Vehicle_Show/BP_GarageTouchActor.BP_GarageTouchActor")
      if slua.isValid(Actor) then
        self._TouchActor[i] = Actor
        local TransForm = ThemeVehicleManager:GetGarageThemeTransform(SceneItemID, 1908001, i)
        if TransForm then
          Actor:K2_SetActorLocation(TransForm[1], false, nil, false)
          Actor:K2_SetActorRotation(FRotator(TransForm[2].Y, TransForm[2].Z, TransForm[2].X), false)
          Actor:SetActorScale3D(TransForm[3])
        end
        Actor:SetPosition(i)
      end
    end
  end
end
function GarageThemeSystem:DestoryEditorTouchActor()
  for key, Actor in pairs(self._TouchActor) do
    if slua.isValid(Actor) then
      Actor:K2_DestroyActor()
    end
  end
  self._TouchActor = {}
end
function GarageThemeSystem:TryShowExchangeNewBie(widget)
  log(bWriteLog and "GarageThemeSystem:TryShowExchangeNewBie")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGarageNewbie)
  if cfg and cfg.hasShow then
    log(bWriteLog and "GarageThemeSystem:TryShowExchangeNewBie cfg.hasShow")
    return
  end
  cfg = {hasShow = true}
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eGarageNewbie)
  local Config = {
    Text = LocUtil.GetLocalizeResStr(77278),
      }
  UIManager.ShowUI(UIManager.UI_Config.NewGuide_Tips_02_UIBP, Config)
end
function GarageThemeSystem:CloseExchangeNewBie()
  log(bWriteLog and "GarageThemeSystem:CloseExchangeNewBie")
  UIManager.CloseUI(UIManager.UI_Config.NewGuide_Tips_02_UIBP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CGarageThemeSystem = class(CModuleBase, nil, GarageThemeSystem)
return CGarageThemeSystem