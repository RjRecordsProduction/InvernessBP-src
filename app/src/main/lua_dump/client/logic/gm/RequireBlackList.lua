local IsAllowRequire = function()
  log(bWriteLog and "IsAllowRequire is called")
  require("client.config.pubgm_package")
  if GlobalData == nil or not GlobalData.IsIOSCheck() then
    return false
  end
  if GlobalData == nil or not GlobalData.IsReviewSvrEnableGM() then
    return false
  end
  if DataMgr and DataMgr.GetBSManager() then
    return true
  end
  log(bWriteLog and "IsAllowRequire return default value true")
  return false
end
local bAllowRequire
local SetIsAllowRequire = function()
  bAllowRequire = IsAllowRequire()
end
SetIsAllowRequire()
local EventSystem = require("client.common.event.EventSystem")
require("client.slua.config.event.event_define")
EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GM_STATE_UPDATE, SetIsAllowRequire)
local canRequireBlackList = function()
  if not Client or not Client.IsReleaseVersion(NetInterface) then
    return true
  elseif bAllowRequire then
    return true
  end
  return false
end
function RequireBlackList(moduleName)
  if canRequireBlackList() then
    local result, res = pcall(require, moduleName)
    if result then
      return res
    end
    return nil
  end
  log_error("RequireBlackList error cant: " .. tostring(moduleName))
  return nil
end
function GetModuleForBlackList(config)
  if canRequireBlackList() then
    local result, res = pcall(ModuleManager.GetModule, config)
    if result then
      return res
    end
    return nil
  end
  log_error("GetModuleForBlackList error cant: " .. tostring(config and config.ModuleName))
  return nil
end