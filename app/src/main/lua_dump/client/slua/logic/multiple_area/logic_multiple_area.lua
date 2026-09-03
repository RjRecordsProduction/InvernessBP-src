local logic_multiple_area = {}
local RUSSIAL_AREA_STRING = "RU"
local areaList
local isRussiaVersion = false
local isConnectToRussia
function logic_multiple_area:OnInitialize()
  logic_multiple_area.__super.OnInitialize(self)
  local PublishAreaMgr = import("PublishAreaMgr")
  local areaString = PublishAreaMgr.GetPublishAreas()
  log(bWriteLog and "[sherlock] logic_multiple_area:OnInitialize " .. areaString)
  isConnectToRussia = nil
  local StringUtil = require("common.string_util")
  areaList = StringUtil.Split(areaString, ",")
  isRussiaVersion = false
  for i, v in ipairs(areaList) do
    areaList[i] = StringUtil.StrTrim(v)
    if areaList[i] == RUSSIAL_AREA_STRING then
      isRussiaVersion = true
    end
  end
end
function logic_multiple_area:IsRussiaVersion()
  return isRussiaVersion
end
function logic_multiple_area:SelectArea(area)
  local PublishAreaMgr = import("PublishAreaMgr")
  PublishAreaMgr.SelectArea(area)
  isConnectToRussia = nil
end
function logic_multiple_area:IsPaymentSupport()
  if isRussiaVersion then
    local result = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_RUSSIA_SWITCH_PAYMENT, false)
    return result
  end
  return true
end
function logic_multiple_area:ShowPaymentNotSupportNotice()
  ShowNotice(33805)
end
function logic_multiple_area:IsConnectToRussiaArea()
  if isConnectToRussia == nil then
    isConnectToRussia = false
    if isRussiaVersion then
      local PublishAreaMgr = import("PublishAreaMgr")
      local currentArea = PublishAreaMgr.GetArea()
      isConnectToRussia = currentArea == RUSSIAL_AREA_STRING
    end
    log(bWriteLog and "[sherlock] logic_multiple_area:IsConnectToRussiaArea result: " .. tostring(isConnectToRussia))
  end
  return isConnectToRussia
end
function logic_multiple_area:GetDisplayNameByZoneID(zoneID)
  if not zoneID then
    return ""
  end
  if self:IsConnectToRussiaArea() and zoneID == 2 then
    local regionCfg = CDataTable.GetTableData("RegionConfig", RUSSIAL_AREA_STRING)
    if regionCfg then
      return regionCfg.RegionName
    end
  end
  local zoneCfg = CDataTable.GetTableData("ZoneConfig", zoneID)
  if not zoneCfg then
    return ""
  end
  return zoneCfg.NameInChinese
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicMultipleArea = class(CModuleBase, nil, logic_multiple_area)
return CLogicMultipleArea