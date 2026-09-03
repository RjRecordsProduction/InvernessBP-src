local logic_roleInfo_HonourCertificate = {}
function logic_roleInfo_HonourCertificate:DefineAndResetData()
  self.CertificateStates = {}
  self.FirstShowCertificates = {}
  self.UidToCertificatesInfo = {}
  self.showNum = 0
  self.versionRequestedUids = {}
  self.certListRequestedUids = {}
  self.pendingListCallbacks = {}
  self.pendingVersionCallbacks = {}
  self.pendingVersionIsSelfMap = {}
  self._hideReqTimestamps = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHonourCertificateVersion)
  if localData and localData.version then
    self.cachedVersion = localData.version
  else
    self.cachedVersion = nil
  end
  self._pendingCertList = {}
  self._pendingCertUid = nil
  self._pendingVersionUid = nil
end
function logic_roleInfo_HonourCertificate:RequestVersionIfNeeded(certUid, isSelf, callback)
  log(bWriteLog and string.format("logic_roleInfo_HonourCertificate:RequestVersionIfNeeded certUid=%s, isSelf=%s", tostring(certUid), tostring(isSelf)))
  certUid = tonumber(certUid)
  if not certUid or certUid <= 0 then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    certUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  end
  if (not certUid or certUid <= 0) and isSelf then
    certUid = tonumber(DataMgr.roleData.uid)
  end
  if not certUid or certUid <= 0 then
    log(bWriteLog and "logic_roleInfo_HonourCertificate:RequestVersionIfNeeded - [ERROR] certUid still invalid after fallback, abort, isSelf=%s", tostring(isSelf))
    return
  end
  self.pendingVersionIsSelfMap[certUid] = isSelf
  local cachedData = self.versionRequestedUids[certUid]
  if cachedData then
    log_format("[HonourCert][RED] RequestVersionIfNeeded HIT CACHE: certUid=%s, cachedVersion=%s, cachedVisibleNum=%s (red dot NOT re-evaluated)", tostring(certUid), tostring(cachedData.version), tostring(cachedData.visibleNum))
    self.showNum = cachedData.visibleNum or 0
    if callback then
      callback(self.showNum)
    end
    return
  end
  self.pendingVersionCallbacks[certUid] = callback
  self._pendingVersionUid = certUid
  log_format("[HonourCert][RED] RequestVersionIfNeeded SEND REQ: certUid=%s, cachedVersion=%s", tostring(certUid), tostring(self.cachedVersion))
  local HonourCertificateHandler = require("client.network.Protocol.HonourCertificateHandler")
  HonourCertificateHandler.send_honour_cert_get_version_req(certUid)
end
function logic_roleInfo_HonourCertificate:OnVersionRsp(err_code, version, visibleNum)
  log_format("[HonourCert][RED] OnVersionRsp ENTER: err_code=%s, version=%s, visibleNum=%s, pendingUid=%s, cachedVersion=%s", tostring(err_code), tostring(version), tostring(visibleNum), tostring(self._pendingVersionUid), tostring(self.cachedVersion))
  local certUid = self._pendingVersionUid
  self._pendingVersionUid = nil
  if not certUid then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    certUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  end
  local isSelf = self.pendingVersionIsSelfMap[certUid]
  local oldVersion = self.cachedVersion
  self.showNum = visibleNum or 0
  self.cachedVersion = version
  self.versionRequestedUids[certUid] = {
    version = version,
    visibleNum = visibleNum or 0
  }
  if isSelf and self.showNum > 0 and (oldVersion == nil or oldVersion ~= version) then
    log_format("[HonourCert][RED] OnVersionRsp SET RED: isSelf=%s, showNum=%d, oldVersion=%s, newVersion=%s", tostring(isSelf), self.showNum, tostring(oldVersion), tostring(version))
    local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
    roleinfo_red_data.RefreshHonourCertificateRed(true)
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({version = version}, PlayerPrefsSystem.ePlayerPrefsType.eHonourCertificateVersion)
  else
    log_format("[HonourCert][RED] OnVersionRsp SKIP RED: isSelf=%s, showNum=%d, oldVersion=%s, newVersion=%s", tostring(isSelf), self.showNum, tostring(oldVersion), tostring(version))
    if isSelf and oldVersion == nil then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.SaveTableToFile_N({version = version}, PlayerPrefsSystem.ePlayerPrefsType.eHonourCertificateVersion)
    end
  end
  local cb = self.pendingVersionCallbacks[certUid]
  self.pendingVersionCallbacks[certUid] = nil
  if cb then
    cb(self.showNum)
  end
end
function logic_roleInfo_HonourCertificate:RequestCertListWithCallback(certUid, callback)
  log_format("logic_roleInfo_HonourCertificate:RequestCertListWithCallback certUid=%s", tostring(certUid))
  certUid = tonumber(certUid)
  if self.certListRequestedUids[certUid] then
    self.CertificateStates = self.UidToCertificatesInfo[certUid] or {}
    if callback then
      callback()
    end
    return
  end
  self.pendingListCallbacks[certUid] = callback
  self._pendingCertList = {}
  self._pendingCertUid = certUid
  local HonourCertificateHandler = require("client.network.Protocol.HonourCertificateHandler")
  HonourCertificateHandler.send_honour_cert_get_cert_list_req(certUid, 0, 20)
end
function logic_roleInfo_HonourCertificate:OnCertListRsp(err_code, cert_list, is_finish, next_page)
  log_format("logic_roleInfo_HonourCertificate:OnCertListRsp err_code=%s, is_finish=%s, next_page=%s", tostring(err_code), tostring(is_finish), tostring(next_page))
  log_tree("logic_roleInfo_HonourCertificate:OnCertListRsp cert_list=", cert_list)
  if cert_list then
    for _, item in ipairs(cert_list) do
      table.insert(self._pendingCertList, item)
    end
  end
  if not is_finish and next_page then
    local HonourCertificateHandler = require("client.network.Protocol.HonourCertificateHandler")
    HonourCertificateHandler.send_honour_cert_get_cert_list_req(self._pendingCertUid, next_page, 20)
    return
  end
  self.CertificateStates = self._pendingCertList or {}
  self._pendingCertList = {}
  table.sort(self.CertificateStates, function(a, b)
    return (a.grant_time or 0) < (b.grant_time or 0)
  end)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local certUid = self._pendingCertUid or tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  self._pendingCertUid = nil
  self.certListRequestedUids[certUid] = true
  self.UidToCertificatesInfo[certUid] = self.CertificateStates
  local isSelfForCert = self.pendingVersionIsSelfMap[certUid]
  self.pendingVersionIsSelfMap[certUid] = nil
  if isSelfForCert then
    self:CollectFirstShowCertificates()
  end
  local cb = self.pendingListCallbacks[certUid]
  self.pendingListCallbacks[certUid] = nil
  if cb then
    cb()
  end
  EventSystem:postEvent(EVENTID_HONOUR_CERTIFICATE_TYPE, EVENTID_HONOUR_CERTIFICATE_DATA_UPDATE)
end
function logic_roleInfo_HonourCertificate:RequestHonourCertificateHide(cert_id, privacy_status)
  log(bWriteLog and string.format("logic_roleInfo_HonourCertificate:RequestHonourCertificateHide cert_id=%s, privacy_status=%s", tostring(cert_id), tostring(privacy_status)))
  local currentTime = os.time()
  local windowStart = currentTime - 10
  local validTimestamps = {}
  for _, ts in ipairs(self._hideReqTimestamps) do
    if ts > windowStart then
      validTimestamps[#validTimestamps + 1] = ts
    end
  end
  self._hideReqTimestamps = validTimestamps
  if #self._hideReqTimestamps >= 4 then
    log(bWriteLog and "logic_roleInfo_HonourCertificate:RequestHonourCertificateHide rate limited")
    ShowNotice(87969)
    return
  end
  self._hideReqTimestamps[#self._hideReqTimestamps + 1] = currentTime
  local HonourCertificateHandler = require("client.network.Protocol.HonourCertificateHandler")
  HonourCertificateHandler.send_honour_cert_set_hide_req(cert_id, privacy_status)
end
function logic_roleInfo_HonourCertificate:OnHonourCertificateHideRsp(cert_id, privacy_status)
  log(bWriteLog and string.format("logic_roleInfo_HonourCertificate:OnHonourCertificateHideRsp cert_id=%s, privacy_status=%s", tostring(cert_id), tostring(privacy_status)))
  self:SetCertificateHideLocal(cert_id, privacy_status)
end
function logic_roleInfo_HonourCertificate:RequestSetHasShow(cert_id)
  log(bWriteLog and string.format("logic_roleInfo_HonourCertificate:RequestSetHasShow cert_id=%s", tostring(cert_id)))
  for _, state in ipairs(self.CertificateStates) do
    if state.cert_id == cert_id then
      state.hasShow = 1
      break
    end
  end
end
function logic_roleInfo_HonourCertificate:CollectFirstShowCertificates()
  log_format("logic_roleInfo_HonourCertificate:CollectFirstShowCertificates")
  self.FirstShowCertificates = {}
  for _, state in ipairs(self.CertificateStates) do
    if not state.hasShow or state.hasShow == 0 then
      table.insert(self.FirstShowCertificates, state)
    end
  end
end
function logic_roleInfo_HonourCertificate:CheckIsEmpty()
  if self.CertificateStates and #self.CertificateStates > 0 then
    return false
  end
  return true
end
function logic_roleInfo_HonourCertificate:GetShowNum()
  return self.showNum or 0
end
function logic_roleInfo_HonourCertificate:UpdateRed()
end
function logic_roleInfo_HonourCertificate:ClearRedDot()
  local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
  roleinfo_red_data.RefreshHonourCertificateRed(false)
end
function logic_roleInfo_HonourCertificate:SetCertificateHideLocal(cert_id, privacy_status)
  log(bWriteLog and string.format("logic_roleInfo_HonourCertificate:SetCertificateHideLocal cert_id=%s, privacy_status=%s", tostring(cert_id), tostring(privacy_status)))
  for _, state in ipairs(self.CertificateStates) do
    if state.cert_id == cert_id then
      state.      break
    end
  end
  EventSystem:postEvent(EVENTID_HONOUR_CERTIFICATE_TYPE, EVENTID_HONOUR_CERTIFICATE_HIDE_SET, cert_id, privacy_status)
end
function logic_roleInfo_HonourCertificate:ClearFirstShowCertificates()
  log_format("logic_roleInfo_HonourCertificate:ClearFirstShowCertificates")
  self.FirstShowCertificates = {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_HonourCertificate = class(CModuleBase, nil, logic_roleInfo_HonourCertificate)
return Clogic_roleInfo_HonourCertificate