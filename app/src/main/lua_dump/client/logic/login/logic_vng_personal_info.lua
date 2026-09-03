local logic_vng_personal_info = {}
function logic_vng_personal_info:ctor()
  self.openFrom = -1
  self.maxCheckTimes = 3
  self.currentCheckTimes = 0
  self.bNeedShowVNGPersonal = false
end
function logic_vng_personal_info:GetNeedShowVNGPersonal()
  return self.bNeedShowVNGPersonal
end
function logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin()
  log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.VNG then
    log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin not VNG")
    return
  end
  if self:CheckSameDay() then
    log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin same day")
    return
  end
  local baseUrl = FuncUtil.GetDomainByID(3366018) .. "/profilev2/extinfo/checkProfile?"
  local FinalUrl = self:GetFinalUrl(baseUrl)
  local header = {
    ["Content-Type"] = "application/x-www-form-urlencoded charset=utf-8",
    ["Accept-Encoding"] = "gzip"
  }
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Get(FinalUrl, header, "", nil, function(success, data)
    log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin success:" .. tostring(success))
    if success then
      local data = json.decode(data)
      if data then
        log_tree(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin data:", data)
        if tonumber(data.returnCode) ~= 0 then
          self.bNeedShowVNGPersonal = true
          LobbySystem.ShowVNGPersonalInfo()
        end
      else
        log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin decode fail")
      end
    end
  end)
end
function logic_vng_personal_info:CheckSameDay()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVNGPersonalInfo) or {}
  if not savedData.checkTime then
    log(bWriteLog and "logic_vng_personal_info:CheckSameDay no checkTime")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(curTime, savedData.checkTime) then
    log(bWriteLog and "logic_vng_personal_info:CheckSameDay same day")
    return true
  end
  log(bWriteLog and "logic_vng_personal_info:CheckSameDay not same day")
  return false
end
function logic_vng_personal_info:SaveCheckTime()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVNGPersonalInfo) or {}
  local TimeUtil = require("client.common.time_util")
  savedData.checkTime = TimeUtil.GetServerTimeInSec()
  PlayerPrefsSystem.SaveTableToFile_N(savedData, PlayerPrefsSystem.ePlayerPrefsType.eVNGPersonalInfo)
end
function logic_vng_personal_info:OpenVNGPersonalInfoUrl(openFrom)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.VNG then
    log(bWriteLog and "logic_vng_personal_info:OpenVNGPersonalInfoUrl not VNG")
    return
  end
  log(bWriteLog and "logic_vng_personal_info:OpenVNGPersonalInfoUrl openFrom:" .. tostring(openFrom))
  self.  if openFrom == 1 then
    self:SaveCheckTime()
  end
  local baseUrl = FuncUtil.GetDomainByID(3366018) .. "/profilev3/extinfo?"
  local FinalUrl = self:GetFinalUrl(baseUrl)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  webModule:JumpToWebPage(FinalUrl, false)
end
function logic_vng_personal_info:CheckVNGPersonalProfile()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.VNG then
    log(bWriteLog and "logic_vng_personal_info:CheckVNGPersonalProfile not VNG")
    return
  end
  if self.openFrom ~= 1 then
    log(bWriteLog and "logic_vng_personal_info:CheckVNGPersonalProfile should not check")
    return
  end
  self.openFrom = -1
  self:RequestVNGPersonalInfo()
end
function logic_vng_personal_info:RequestVNGPersonalInfo()
  log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfo")
  if self.currentCheckTimes > self.maxCheckTimes then
    log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfo maxCheckTimes")
    self.currentCheckTimes = 0
    return
  end
  local baseUrl = FuncUtil.GetDomainByID(3366018) .. "/profilev2/extinfo/checkProfile?"
  local FinalUrl = self:GetFinalUrl(baseUrl)
  local header = {
    ["Content-Type"] = "application/x-www-form-urlencoded charset=utf-8",
    ["Accept-Encoding"] = "gzip"
  }
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Get(FinalUrl, header, "", nil, function(success, data)
    log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfo success:" .. tostring(success))
    if success then
      local data = json.decode(data)
      if data then
        log_tree(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfo data:", data)
        if tonumber(data.returnCode) == 0 then
          self.bNeedShowVNGPersonal = false
        else
          self:OpenVNGPersonalInfoUrl(1)
        end
      else
        log(bWriteLog and "logic_vng_personal_info:RequestVNGPersonalInfo decode fail")
        self.currentCheckTimes = self.currentCheckTimes + 1
        self:RequestVNGPersonalInfo()
      end
    else
      self.currentCheckTimes = self.currentCheckTimes + 1
      self:RequestVNGPersonalInfo()
    end
  end)
end
function logic_vng_personal_info:GetFinalUrl(baseUrl)
  local appID = FuncUtil.GetKeywordByID(3377002)
  local userID = DataMgr.roleData.openID
  local TimeUtil = require("client.common.time_util")
  local timeStamp = TimeUtil.GetServerTimeInSec() * 1000
  local secretKey = "9GmriXzdRLeUdHzXWvfOFvVjjlvpK7Le"
  local needMd5String = secretKey .. appID .. timeStamp .. userID
  local sig = Client.MD5HashAnsiString(needMd5String)
  log(bWriteLog and "logic_vng_personal_info:GetFinalUrl needMd5String:" .. tostring(needMd5String))
  local FinalUrl = baseUrl .. "appID=" .. appID .. "&userID=" .. userID .. "&timestamp=" .. timeStamp .. "&sig=" .. sig
  log(bWriteLog and "logic_vng_personal_info:GetFinalUrl FinalUrl :" .. FinalUrl)
  return FinalUrl
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_vng_personal_info = class(CModuleBase, nil, logic_vng_personal_info)
return Clogic_vng_personal_info