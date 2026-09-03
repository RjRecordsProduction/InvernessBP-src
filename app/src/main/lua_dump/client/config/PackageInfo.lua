local PackageInfo = {PackageDataTable = nil, is_patch = false}
require("client.config.pubgm_package")
require("client.config.pubgm_patch")
local DeviceName, DeviceLevel, StartTime
function PackageInfo.GetDeviceName()
  if DeviceName and DeviceName ~= "" then
    return DeviceName
  end
  if not Client then
    return ""
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local DeviceName = DevicePlatformNameMacros.GetDeviceName()
  return DeviceName
end
function PackageInfo.GetDeviceLevel()
  if DeviceLevel and 0 <= DeviceLevel then
    return DeviceLevel
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  if gameInstance and gameInstance.GetDeviceLevel then
    DeviceLevel = gameInstance:GetDeviceLevel() or 0
  end
  return DeviceLevel
end
function PackageInfo.GetStartTime()
  if StartTime and StartTime ~= "" then
    return StartTime
  end
  local TimeUtil = require("client.common.time_util")
  StartTime = TimeUtil.OSDate("%Y-%m-%d %H:%M:%S", TimeUtil.GetServerTimeInSec())
  return StartTime
end
function PackageInfo.GetAssistInfoMsg()
  local AssistInfomsg = ""
  if not global_package_make_time_map or not next(global_package_make_time_map) then
    return AssistInfomsg
  end
  local Version = global_package_make_time_map["App Version"]
  if Version then
    AssistInfomsg = AssistInfomsg .. "AppVersion:[" .. Version .. "]"
  end
  local PatchVersion = global_patch_make_time_map["Patch Version"]
  if PatchVersion and not string.find(PatchVersion, "N/A") then
    AssistInfomsg = AssistInfomsg .. "|PatchVersion:[" .. PatchVersion .. "]"
  end
  local Mfg_Date = global_package_make_time_map["Mfg. Date"]
  if Mfg_Date then
    AssistInfomsg = AssistInfomsg .. "|MfgDate:[" .. Mfg_Date .. "]"
  end
  local PatchMfg_Date = global_patch_make_time_map["Mfg. Date"]
  if type(PatchMfg_Date) == "string" and not string.find(PatchMfg_Date, "N/A") then
    AssistInfomsg = AssistInfomsg .. "|PatchMfgDate:[" .. PatchMfg_Date .. "]"
  end
  if Client and Client.GetDevicePlatformName() then
    AssistInfomsg = AssistInfomsg .. "|PlatForm:[" .. Client.GetDevicePlatformName() .. "]"
  end
  local SVN_EngineRevision = global_package_make_time_map["SVN EngineRevision"]
  if SVN_EngineRevision then
    AssistInfomsg = AssistInfomsg .. "|SVNEngineRevision:[" .. SVN_EngineRevision .. "]"
  end
  local SVN_ProjectRevision = global_package_make_time_map["SVN ProjectRevision"]
  if SVN_ProjectRevision then
    AssistInfomsg = AssistInfomsg .. "|SVNProjectRevision:[" .. SVN_ProjectRevision .. "]"
  end
  local PatchSVN_EngineRevision = global_patch_make_time_map["SVN EngineRevision"]
  if PatchSVN_EngineRevision and not string.find(PatchSVN_EngineRevision, "N/A") then
    AssistInfomsg = AssistInfomsg .. "|PatchSVNEngineRevision:[" .. PatchSVN_EngineRevision .. "]"
  end
  local P4_Revision = global_package_make_time_map["P4 Revision"]
  if P4_Revision then
    AssistInfomsg = AssistInfomsg .. "|P4Revision:[" .. P4_Revision .. "]"
  end
  local PatchP4_Revision = global_patch_make_time_map["P4 Revision"]
  if PatchP4_Revision and not string.find(PatchP4_Revision, "N/A") then
    AssistInfomsg = AssistInfomsg .. "|PatchP4Revision:[" .. PatchP4_Revision .. "]"
  end
  local Branch = global_package_make_time_map.Branch
  if Branch then
    AssistInfomsg = AssistInfomsg .. "|Branch:[" .. Branch .. "]"
  end
  local Mode = global_package_make_time_map.Mode
  if Mode then
    AssistInfomsg = AssistInfomsg .. "|Mode:[" .. Mode .. "]"
  end
  local DName = PackageInfo.GetDeviceName()
  if DName and DName ~= "" then
    AssistInfomsg = AssistInfomsg .. "|DeviceName:[" .. DName .. "]"
  end
  local DLevel = PackageInfo.GetDeviceLevel()
  if DLevel and 0 <= DLevel then
    AssistInfomsg = AssistInfomsg .. "|DeviceLevel:[" .. DLevel .. "]"
  end
  local STime = PackageInfo.GetStartTime()
  if STime and STime ~= "" then
    AssistInfomsg = AssistInfomsg .. "|StartTime:[" .. STime .. "]"
  end
  if Client and NetInterface and not Client.IsReleaseVersion(NetInterface) then
    local uid = DataMgr and DataMgr.roleData and DataMgr.roleData.uid
    AssistInfomsg = AssistInfomsg .. "|UID:[" .. tostring(uid) .. "]"
  end
  if Client and NetInterface and not Client.IsReleaseVersion(NetInterface) then
    local BusinessHelper = import("BusinessHelper")
    local openID = 0
    if BusinessHelper and BusinessHelper.GetOpenId then
      openID = BusinessHelper and BusinessHelper.GetOpenId()
    end
    AssistInfomsg = AssistInfomsg .. "|OpenID:[" .. tostring(openID) .. "]"
  end
  return AssistInfomsg
end
function PackageInfo.GetGitCommit()
  local GitInfo = {}
  local GitEngine = global_patch_make_time_map["Git Engine"]
  if GitEngine and not string.find(GitEngine, "N/A") then
    GitInfo.  else
    GitEngine = global_package_make_time_map["Git Engine"]
    if GitEngine and not string.find(GitEngine, "N/A") then
      GitInfo.    end
  end
  local GitSurvive = global_patch_make_time_map["Git Survive"]
  if GitSurvive and not string.find(GitSurvive, "N/A") then
    GitInfo.  else
    GitSurvive = global_package_make_time_map["Git Survive"]
    if GitSurvive and not string.find(GitSurvive, "N/A") then
      GitInfo.    end
  end
  local GitLua = global_patch_make_time_map["Git Lua"]
  if GitLua and not string.find(GitLua, "N/A") then
    GitInfo.  else
    GitLua = global_package_make_time_map["Git Lua"]
    if GitLua and not string.find(GitLua, "N/A") then
      GitInfo.    end
  end
  return GitInfo
end
return PackageInfo