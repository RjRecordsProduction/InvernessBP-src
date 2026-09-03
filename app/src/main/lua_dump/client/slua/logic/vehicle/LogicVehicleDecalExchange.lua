local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local ENUM_DECAL_EXCHANGE_GUIDE_STATUS = {
  SHOW_STATUS_UNKNOWN = -1,
  SHOW_STATUS_NOT = 0,
  SHOW_STATUS_HAS_SHOWN = 1
}
local GUIDE_SUB_TYPE_DECAL_EXCHANGE = 1
local LogicVehicleDecalExchange = {ENUM_DECAL_EXCHANGE_GUIDE_STATUS = ENUM_DECAL_EXCHANGE_GUIDE_STATUS}
function LogicVehicleDecalExchange:DefineAndResetData()
end
function LogicVehicleDecalExchange:OpenDecalExchangeList()
  UIManager.ShowUI(UIManager.UI_Config.Spray_Shop_Exchange_Popup_UIBP)
end
function LogicVehicleDecalExchange:CloseDecalExchangeList()
  UIManager.CloseUI(UIManager.UI_Config.Spray_Shop_Exchange_Popup_UIBP)
end
function LogicVehicleDecalExchange:OpenDecalExchangeDetail(ItemID)
  if not ItemID then
    return
  end
  self:CheckCfgAndOpenDetail(ItemID)
end
function LogicVehicleDecalExchange:CheckCfgAndOpenDetail(ItemID)
  if not self:IsDecalCanExchange(ItemID) then
    ShowNotice(76216)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Spray_Shop_Exchange_Popup02_UIBP, ItemID)
end
function LogicVehicleDecalExchange:CloseDecalExchangeDetail()
  UIManager.CloseUI(UIManager.UI_Config.Spray_Shop_Exchange_Popup02_UIBP)
end
function LogicVehicleDecalExchange:GetExchangeCfg(nExchangeId)
  return CDataTable.GetTableData("VehicleExchangeCfg", nExchangeId)
end
function LogicVehicleDecalExchange:ReqDecalExchange(pattern_id, pattern_count, cost_list)
  log(bWriteLog and "exchange_diy_pattern_req:" .. tostring(pattern_id) .. ",pattern_count:" .. tostring(pattern_count))
  log_tree("cost_list", cost_list)
  local VehicleDIYHandler = require("client.network.Protocol.VehicleDIYHandler")
  VehicleDIYHandler.send_depot_exchange_req(pattern_id, pattern_count, cost_list)
end
function LogicVehicleDecalExchange:OnDepotExchangeRsp(pattern_id, pattern_count)
  local tip_items = {}
  table.insert(tip_items, {res_id = pattern_id, count = pattern_count})
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
  local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
  local Enum_BtnStyle = CommonItemGet_Const.Enum_BtnStyle
  local tExtendData
  if not UIManager.IsUIShow(UIManager.UI_Config.Vehicle_DetailShow_Applique_UIBP) and not UIManager.IsUIShow(UIManager.UI_Config.item_upgrade) then
    tExtendData = {
      tAllBtnShowData = {
        CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
        CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(77000), Enum_BtnStyle.Orange, function()
          log(bWriteLog and "LogicVehicleDecalExchange:OnDepotExchangeRsp. CustomButton")
          local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
          local VehicleSystem_Main_Show_Config = require("client.slua.umg.vehicle.config.VehicleSystem_Main_Show_Config")
          local FeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType.VEHICLE_DIY
          local JumpVehicleItemID = self:GetAutoJumpVehicleItemID()
          log(bWriteLog and "LogicVehicleDecalExchange:OnDepotExchangeRsp. JumpVehicleItemID: " .. tostring(JumpVehicleItemID))
          if JumpVehicleItemID then
            VehicleCollectSystem:OpenVehicleWorkShop(VehicleSystem_Main_Show_Config.ENUM_Vehicle_UITYPE.COLLECT, {VehicleID = JumpVehicleItemID, JumpType = FeatureType})
          else
            log_error("LogicVehicleDecalExchange:OnDepotExchangeRsp can not find a car for jump which can use decal")
          end
        end)
      }
    }
  end
  Logic_CommonItemGet.ShowPanel_DefaultStyle(tip_items, nil, nil, tExtendData)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_DECAL_EXCHANGE)
end
function LogicVehicleDecalExchange:GetAutoJumpVehicleItemID()
  local CfgList = CDataTable.GetTableByFilter("VehicleDIYCfg", "BanUse", 0)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local TimeUtil = require("client.common.time_util")
  local timeNow = TimeUtil.GetServerTimeInSec()
  local DefaultVehicle
  for k, v in pairs(CfgList) do
    local bVehicleOpen = true
    if v.Time and v.Time ~= "" then
      local openTime = TimeUtil.TimeStringToUnixstamp(v.Time)
      if timeNow < openTime then
        bVehicleOpen = false
      end
    end
    if bVehicleOpen then
      if DefaultVehicle == nil then
        local BetterVehicleEffectConfig = CDataTable.GetTableData("BetterVehicleEffect", v.ID)
        if not BetterVehicleEffectConfig or not BetterVehicleEffectConfig.IfHiddenCar then
          DefaultVehicle = v.ID
        end
      end
      if wardrobe_data:HasItem(v.ID, true) then
        return v.ID
      end
    end
  end
  return DefaultVehicle
end
function LogicVehicleDecalExchange:GetDecalGuideStatus()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local GuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVehicleDecalGuide) or {}
  return GuideData[GUIDE_SUB_TYPE_DECAL_EXCHANGE] or ENUM_DECAL_EXCHANGE_GUIDE_STATUS.SHOW_STATUS_UNKNOWN
end
function LogicVehicleDecalExchange:NeedShowDecalGuide()
  local CurrentStatus = self:GetDecalGuideStatus()
  return CurrentStatus ~= ENUM_DECAL_EXCHANGE_GUIDE_STATUS.SHOW_STATUS_HAS_SHOWN
end
function LogicVehicleDecalExchange:SetDecalGuideShowFlag()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local GuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVehicleDecalGuide) or {}
  GuideData[GUIDE_SUB_TYPE_DECAL_EXCHANGE] = ENUM_DECAL_EXCHANGE_GUIDE_STATUS.SHOW_STATUS_HAS_SHOWN
  PlayerPrefsSystem.SaveTableToFile_N(GuideData, PlayerPrefsSystem.ePlayerPrefsType.eVehicleDecalGuide)
end
function LogicVehicleDecalExchange:IsDecalCanExchange(DecalItemID, uExchangeCfg)
  if not DecalItemID then
    return false
  end
  if not uExchangeCfg then
    uExchangeCfg = self:GetExchangeCfg(DecalItemID)
    if not uExchangeCfg then
      return false
    end
  end
  if uExchangeCfg.ExchangeType ~= 1 then
    return false
  end
  if uExchangeCfg.MinVersion and uExchangeCfg.MinVersion ~= "" then
    local clientVersion = Client.GetAppVersion()
    local version_util = require("client.common.version_util")
    if version_util.CompareVersionStandard(clientVersion, uExchangeCfg.MinVersion) < 0 then
      return false
    end
  end
  if uExchangeCfg.StartTime and uExchangeCfg.StartTime ~= "" then
    local TimeUtil = require("client.common.time_util")
    local nStartTime = TimeUtil.TimeStringToUnixstamp(uExchangeCfg.StartTime)
    local timeNow = TimeUtil.GetServerTimeInSec()
    if nStartTime > timeNow then
      return false
    end
  end
  return true
end
function LogicVehicleDecalExchange:IsVehicleDecalLocked()
  local bMcLarenLocked = false
  local cfg = CDataTable.GetTableData("BetterVehicleEffect", 1907054)
  if cfg and cfg.Time and cfg.Time ~= "" then
    local TimeUtil = require("client.common.time_util")
    local current = TimeUtil.GetServerTimeInSec()
    local show = TimeUtil.TimeStringToUnixstamp(cfg.Time)
    if current < show then
      bMcLarenLocked = true
    end
  end
  return bMcLarenLocked
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicVehicleDecalExchange = class(CModuleBase, nil, LogicVehicleDecalExchange)
return CLogicVehicleDecalExchange