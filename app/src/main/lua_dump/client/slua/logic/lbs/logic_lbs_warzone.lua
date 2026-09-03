local logic_lbs_warzone = {}
function logic_lbs_warzone:OnInitialize()
  self.zone_id_list = nil
  self.logic_lbs_warzone_enum = {
    NoPermission = 1,
    HasPermission = 2,
    GetGPSZoneSuccess = 3
  }
  self.latitude = 0
  self.longitude = 0
end
function logic_lbs_warzone:OnLogin(bReLogin)
end
function logic_lbs_warzone:InitLocationInterface()
  log(bWriteLog and "logic_lbs_warzone:InitLocationInterface")
  local locationInterface = require("client.slua.logic.lbs.logic_location_interface")
  locationInterface:Init()
end
function logic_lbs_warzone:DestroyLocationInterface()
  log(bWriteLog and "logic_lbs_warzone:DestroyLocationInterface")
  local locationInterface = require("client.slua.logic.lbs.logic_location_interface")
  locationInterface:Destroy()
  self:HideWaitingUI()
end
function logic_lbs_warzone:IsOpenLBS()
  if not self:IsAdult() then
    log(bWriteLog and "logic_lbs_warzone:IsOpenLBS not adult")
    ShowNotice(113100010)
    return
  end
  local locationInterface = require("client.slua.logic.lbs.logic_location_interface")
  local hasPermission = locationInterface:HasLocationPermission()
  log(bWriteLog and "logic_lbs_warzone:IsOpenLBS permission status: " .. tostring(hasPermission))
  if hasPermission then
    return self.logic_lbs_warzone_enum.HasPermission
  else
    self:ShowMsgBoxMgr(self.logic_lbs_warzone_enum.NoPermission)
    return self.logic_lbs_warzone_enum.NoPermission
  end
end
function logic_lbs_warzone:GetCurrentLocation()
  if not self:IsAdult() then
    log(bWriteLog and "logic_lbs_warzone:GetCurrentLocation not adult")
    ShowNotice(113100010)
    return
  end
  local locationInterface = require("client.slua.logic.lbs.logic_location_interface")
  local hasPermission = locationInterface:HasLocationPermission()
  log(bWriteLog and "logic_lbs_warzone:GetCurrentLocation permission status: " .. tostring(hasPermission))
  if not hasPermission then
    self:ShowMsgBoxMgr(self.logic_lbs_warzone_enum.NoPermission)
    return self.logic_lbs_warzone_enum.NoPermission
  end
  local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
  local leftTime2 = logic_lbs.GetLastGPSZoneLeftTime()
  if 0 < leftTime2 and logic_lbs.gpsInfo.zone_for_gps and next(logic_lbs.gpsInfo.zone_for_gps) then
    log(bWriteLog and "logic_lbs_warzone:GetCurrentLocation use zone_for_gps")
    self.zone_id_list = logic_lbs.gpsInfo.zone_for_gps
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_LOCATION_INFO, self.logic_lbs_warzone_enum.GetGPSZoneSuccess)
    return
  end
  locationInterface:QueryLocation()
  local uiText = LocUtil.LocalizeResFormat(75481)
  logic_connection_waiting:Show(0, true, true, uiText)
  local time_ticker = require("common.time_ticker")
  self.WaitingTimer = time_ticker.AddTimerOnce(31, function()
    log(bWriteLog and "logic_lbs_warzone:GetCurrentLocation WaitingTimerTimeOut")
    self:WaitingTimerTimeOut()
  end)
  log(bWriteLog and "logic_lbs_warzone:GetCurrentLocation query started")
end
function logic_lbs_warzone:ShowMsgBoxMgr(msgType)
  log(bWriteLog and "logic_lbs_warzone:ShowMsgBoxMgr msgType" .. tostring(msgType))
  if UIManager.IsUIShow(UIManager.UI_Config.WarZoneRanking_Popup_08_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.WarZoneRanking_Popup_08_UIBP)
  end
  if msgType == self.logic_lbs_warzone_enum.NoPermission then
    UIManager.ShowUI(UIManager.UI_Config.WarZoneRanking_Popup_09_UIBP)
  else
    UIManager.ShowUI(UIManager.UI_Config.WarZoneRanking_Popup_08_UIBP, msgType)
  end
end
function logic_lbs_warzone:OnLocationSuccess(latitude, longitude)
  log_format("logic_lbs_warzone:OnLocationSuccess - latitude:%s longitude:%s", latitude, longitude)
  self:HideWaitingUI()
  latitude = tonumber(latitude)
  longitude = tonumber(longitude)
  if latitude and longitude then
    self.    self.    local LBSHandler = require("client.network.Protocol.LBSHandler")
    LBSHandler.send_lbs_get_gps_zone_req(self.latitude, self.longitude)
  else
    log_format("logic_lbs_warzone:OnLocationSuccess sendfail - latitude:%s longitude:%s", latitude, longitude)
  end
end
function logic_lbs_warzone:on_lbs_get_gps_zone_rsp(err_code, zone_id_list, query_ts)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  if zone_id_list and next(zone_id_list) then
    local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
    logic_lbs.SetZoneForGps(zone_id_list, query_ts)
    self.    self.    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_LOCATION_INFO, self.logic_lbs_warzone_enum.GetGPSZoneSuccess)
  end
end
function logic_lbs_warzone:send_lbs_set_zone_by_gps_req()
  log_tree("logic_lbs_warzone:send_lbs_set_zone_by_gps_req self.zone_id_list", self.zone_id_list)
  local LBSHandler = require("client.network.Protocol.LBSHandler")
  LBSHandler.send_lbs_set_zone_by_gps_req(self.zone_id_list)
end
function logic_lbs_warzone:on_lbs_set_zone_by_gps_rsp(err_code, zone_id_list, update_ts)
  log(bWriteLog and "logic_lbs_warzone:on_lbs_set_zone_by_gps_rsp err_code:" .. tostring(err_code) .. " update_ts:" .. tostring(update_ts))
  log_tree("logic_lbs_warzone:on_lbs_set_zone_by_gps_rsp zone_id_list", zone_id_list)
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  if err_code == 0 then
    LbsMgr.UpdateMyZone(zone_id_list, update_ts)
    LbsMgr.ClearLBSWarZoneReddot()
    local zoneName = LbsMgr.GetMySetZoneConcatName("-")
    local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
    if next(SocialCardSystem.MySocialCard) then
      SocialCardSystem.SocialCard = SocialCardSystem.MySocialCard
    end
    SocialCardSystem.SocialCard.lbs = zoneName
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    RoleInfoSystem.modify_social_card()
  else
    ShowNotice(err_code)
  end
end
function logic_lbs_warzone:CheackIsOpenZoneGPS()
  local isGPS1 = false
  local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
  local gpsNum = logic_lbs.lbs_switch_table and logic_lbs.lbs_switch_table.gps or 0
  isGPS1 = gpsNum == 1
  return isGPS1
end
function logic_lbs_warzone:CheackHasFinishFirstSet()
  log(bWriteLog and "logic_lbs_warzone:CheackHasFinishFirstSet enter")
  local hasFinish = false
  local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
  local gpsNum = logic_lbs.gpsInfo.total_count_gps or 0
  log(bWriteLog and "logic_lbs_warzone:CheackHasFinishFirstSet gpsNum" .. tostring(gpsNum))
  log_tree("logic_lbs_warzone:CheackHasFinishFirstSet logic_lbs.gpsInfo", logic_lbs.gpsInfo)
  if 0 < gpsNum then
    hasFinish = true
  end
  log(bWriteLog and "logic_lbs_warzone:CheackHasFinishFirstSet hasFinish" .. tostring(hasFinish))
  return hasFinish
end
function logic_lbs_warzone:GetLbsNameByGPSZone()
  local nameTable = {}
  local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
  if not self.zone_id_list or not next(self.zone_id_list) then
    if logic_lbs.gpsInfo.zone_for_gps and next(logic_lbs.gpsInfo.zone_for_gps) then
      self.zone_id_list = logic_lbs.gpsInfo.zone_for_gps
    else
      log(bWriteLog and "logic_lbs_warzone:GetLbsNameByGPSZone no zone info")
      return
    end
  end
  log_tree("logic_lbs_warzone:GetLbsNameByGPSZone self.zone_id_list", self.zone_id_list)
  local lbs_zone_table = require("client.slua.logic.lbs.lbs_zone_table")
  for i = logic_lbs.RegionCountry, logic_lbs.RegionStreet do
    local zoneID = self.zone_id_list[i]
    if zoneID then
      local data = lbs_zone_table.GetZoneCfg(zoneID)
      if data and data.hide and tonumber(data.hide) ~= 1 then
        local zoneName = lbs_zone_table.GetZoneName(data)
        if zoneName and zoneName ~= "" then
          nameTable[#nameTable + 1] = zoneName
        end
      end
    end
  end
  local name = table.concat(nameTable, "-")
  return name
end
function logic_lbs_warzone:RefreshGPSZone(hideNotice)
  log(bWriteLog and "logic_lbs_warzone:RefreshGPSZone enter")
  local isOpenGPS1 = self:CheackIsOpenZoneGPS()
  if isOpenGPS1 then
    local isFinishFirst = self:CheackHasFinishFirstSet()
    log(bWriteLog and "logic_lbs_warzone:RefreshGPSZone isFinishFirst" .. tostring(isFinishFirst))
    if not isFinishFirst then
      log(bWriteLog and "logic_lbs_warzone:RefreshGPSZone is first")
      if self:IsOpenLBS() == self.logic_lbs_warzone_enum.HasPermission then
        self:ShowMsgBoxMgr(2)
      end
    else
      local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
      local leftTime1 = logic_lbs.GetSetGPSLeftTime()
      if 0 < leftTime1 then
        local days = math.ceil(leftTime1 / 86400)
        local text = LocUtil.LocalizeResFormat(75464, days)
        log(bWriteLog and "logic_lbs_warzone:RefreshGPSZone cd1 " .. tostring(leftTime1))
        if not hideNotice then
          ShowNotice(text)
        end
        return 1
      else
        local leftTime2 = logic_lbs.GetLastGPSZoneLeftTime()
        if 0 < leftTime2 then
          log(bWriteLog and "logic_lbs_warzone:RefreshGPSZone cd2 " .. tostring(leftTime2))
          if not hideNotice then
            ShowNotice(LocUtil.LocalizeResFormat(75465))
          end
          return 2
        else
          self:ShowMsgBoxMgr(4)
        end
      end
    end
  else
    UIManager.ShowUI(UIManager.UI_Config.ui_lbs_gps_reset)
  end
end
function logic_lbs_warzone:IsAdult()
  local gdpr_user_type = DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.user_type or 1
  local gdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  local bIsEUGDPRUser = gdprSystem.IsEUGDPRUser(gdpr_user_type)
  log(bWriteLog and "logic_lbs_warzone:IsAdult gdpr_user_type:" .. tostring(gdpr_user_type))
  if gdpr_user_type ~= 0 and bIsEUGDPRUser and gdpr_user_type ~= 7 then
    local gdpr_config = require("client.slua.logic.gdpr.gdpr_config")
    if gdpr_user_type == gdpr_config.EUserType.EUGDPR_EU_ADULT or gdpr_user_type == gdpr_config.EUserType.EUGDPR_EU_PERSON then
      return true
    else
      return false
    end
  end
  local agegate_state = DataMgr.minor_cert_status
  log(bWriteLog and "logic_lbs_warzone:IsAdult agegate_state:" .. tostring(agegate_state))
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  return agegate_state == logic_compliance.Enum_Minor_Cert_Status.Finish
end
function logic_lbs_warzone:WaitingTimerTimeOut()
  log(bWriteLog and "logic_lbs_warzone:WaitingTimerTimeOut")
  ShowNotice(75477)
  self:HideWaitingUI()
end
function logic_lbs_warzone:HideWaitingUI()
  log(bWriteLog and "logic_lbs_warzone:HideWaitingUI")
  logic_connection_waiting:Hide(0)
  if self.WaitingTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.WaitingTimer)
    self.WaitingTimer = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_lbs_warzone)
return CModuleTemplate