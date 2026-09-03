local M = {
  CMD = {
    CMD_INIT = 1,
    CMD_PERMISSION_CHANGED = 2,
    CMD_REQ_PERMISSION = 3,
    CMD_REQ_LOCATION = 4
  },
  RET_CODE = {
    SUCCESS = 0,
    ERR_PERMISSION = 1,
    ERR_TIMEOUT = 2,
    ERR_LOCATION_INVALID = 3
  }
}
function M:Init()
  if self.LocationHelperInstance ~= nil then
    log(bWriteLog and "LocationHelperInstance:Init do nothing by LocationHelperInstance is not nil")
    return
  end
  local CLocationHelper = import("LocationHelper")
  if CLocationHelper ~= nil then
    self.LocationHelperInstance = CLocationHelper:GetInstance()
    self.LocationHelperInstance:Initialize()
    self.LocationHelperInstance.LocationCompleteCallback:Clear()
    self.LocationHelperInstance.LocationCompleteCallback:Add(function(retJson)
      log(bWriteLog and "LocationHelperInstance:LocationCompleteCallback" .. retJson)
      self:LocationCallbackHandler(retJson)
    end)
  end
end
function M:HasLocationPermission()
  local SystemPermissionHelper = import("SystemPermissionHelper")
  local instance = SystemPermissionHelper.GetInstance()
  if instance ~= nil then
    return instance:IsPermissionGranted(3)
  else
    return false
  end
end
function M:RequestLocationPermission(callback_func)
  local SystemPermissionHelper = import("SystemPermissionHelper")
  local instance = SystemPermissionHelper.GetInstance()
  if instance ~= nil then
    self.permission_    instance.RequestPermissionResultCallback:Clear()
    instance.RequestPermissionResultCallback:Add(function(requestCode, permissionType, grantedRet)
      log(bWriteLog and "OnRequestPermissionResultComplete: " .. tostring(requestCode) .. ", " .. tostring(permissionType) .. ", " .. tostring(grantedRet))
      if requestCode == 2335 and permissionType == 3 then
        local bGranted = false
        if grantedRet == 1 then
          bGranted = true
        end
        self:OnRequestPermissionResult(bGranted)
      end
    end)
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and self.iOSPermissionStatus == "2" then
      self:OnRequestPermissionResult(false)
      return
    end
    instance:RequestPermissions(3, 2335)
  else
    log(bWriteLog and "LocationHelperInstance:RequestLocationPermission do nothing by SystemPermissionHelper is nil")
  end
end
function M:QueryLocation()
  if self.LocationHelperInstance ~= nil then
    self.LocationHelperInstance:QueryLocation(30000)
  else
    log(bWriteLog and "LocationHelperInstance:QueryLocation do by LocationHelperInstance is nil")
  end
end
function M:LocationCallbackHandler(retJson)
  log(bWriteLog and "LocationHelperInstance:LocationCallbackHandler" .. retJson)
  local ret = json.decode(retJson)
  if ret.cmd == M.CMD.CMD_REQ_LOCATION then
    if ret.code == M.RET_CODE.SUCCESS then
      local StringUtil = require("common.string_util")
      local coords = StringUtil.Split(ret.msg, "|")
      local lattitude = coords[1]
      local longitude = coords[2]
      log(bWriteLog and "LocationHelperInstance:LocationCallbackHandler: " .. lattitude .. " " .. longitude)
      local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
      logic_lbs_warzone:OnLocationSuccess(lattitude, longitude)
    elseif ret.code == M.RET_CODE.ERR_PERMISSION then
      log(bWriteLog and "LocationHelperInstance:LocationCallbackHandler ERR_PERMISSION ERROR request permission first!")
    else
      local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
      logic_lbs_warzone:WaitingTimerTimeOut()
      log(bWriteLog and "LocationHelperInstance:LocationCallbackHandler: " .. tostring(ret.code))
    end
  elseif ret.cmd == M.CMD.CMD_REQ_PERMISSION then
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      self.iOSPermissionStatus = ret.msg
      if ret.msg == "3" or ret.msg == "4" or ret.msg == "5" then
        self:OnRequestPermissionResult(true)
      else
        self:OnRequestPermissionResult(false)
      end
    end
  elseif ret.cmd == M.CMD.CMD_INIT and ret.cbtype == M.CMD.CMD_PERMISSION_CHANGED then
    self.iOSPermissionStatus = ret.msg
  end
end
function M:OnRequestPermissionResult(result)
  log(bWriteLog and "LocationHelperInstance:OnRequestPermissionResult: " .. tostring(result))
  if self.permission_callback_func ~= nil then
    self.permission_callback_func(result)
  else
    log(bWriteLog and "LocationHelperInstance:OnRequestPermissionResult do nothing by permission_callback_func is nil")
  end
  self.permission_callback_func = nil
end
function M:Destroy()
  if self.LocationHelperInstance ~= nil then
    self.LocationHelperInstance.LocationCompleteCallback:Clear()
    self.LocationHelperInstance:Destroy()
    self.LocationHelperInstance = nil
  end
end
return M