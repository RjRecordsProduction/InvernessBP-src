local DeviceOSInfo = {
  InfoList = {
    ClientVersion = "",
    SystemSoftware = "",
    SystemHardware = "",
    TelecomOper = "",
    NetWork = "",
    ScreenWidth = 0,
    ScreenHight = 0,
    Density = 0,
    CpuHardware = "",
    Memory = 0,
    GLRender = "",
    GLVersion = "",
    DeviceId = "",
    vClientIP = "",
    DeviceName = "",
    EmulatorName = "",
    AdvertisingID = "",
    DeviceQualityLevel = 0,
    ExactDeviceLevel = 0,
    XID = "",
    L1XID = "",
    DeviceModel = "",
    AndroidVersion = "",
    DeviceMake = "",
    DeviceGradeLevel = "",
    BattleFPS = 0
  }
}
function DeviceOSInfo.getDeviceOSInfo()
  DeviceOSInfo.InfoList.ClientVersion = Client.GetAppVersion()
  DeviceOSInfo.InfoList.SystemSoftware = Client.GetOSVersion()
  DeviceOSInfo.InfoList.SystemHardware = Client.GetPhoneType()
  DeviceOSInfo.InfoList.TelecomOper = Client.GetTelecomSvr()
  DeviceOSInfo.InfoList.NetWork = Client.GetNetWorkType()
  DeviceOSInfo.InfoList.ScreenWidth = Client.GetScreenWidth()
  DeviceOSInfo.InfoList.ScreenHight = Client.GetScreenHight()
  DeviceOSInfo.InfoList.Density = Client.GetScreenDensity()
  DeviceOSInfo.InfoList.CpuHardware = Client.GetCpuType()
  DeviceOSInfo.InfoList.Memory = Client.GetMemorySize()
  DeviceOSInfo.InfoList.GLRender = Client.GetGLType()
  DeviceOSInfo.InfoList.GLVersion = Client.GetGLVersion()
  DeviceOSInfo.InfoList.DeviceId = Client.GetPhoneDeviceID()
  DeviceOSInfo.InfoList.vClientIP = Client.GetIpAddr()
  DeviceOSInfo.InfoList.DeviceName = DeviceOSInfo.GetDeviceName()
  DeviceOSInfo.InfoList.DeviceQualityLevel = Client.GetDeviceQualityLevel()
  DeviceOSInfo.InfoList.ExactDeviceLevel = Client.GetExactDeviceLevel()
  DeviceOSInfo.InfoList.IsVPN = DeviceOSInfo.GetIsPlayerUsingVPN()
  DeviceOSInfo.InfoList.DeviceModel = string.lower(Client.GetDeviceModel())
  DeviceOSInfo.InfoList.AndroidVersion = string.lower(Client.GetAndroidVersion())
  DeviceOSInfo.InfoList.DeviceMake = string.lower(Client.GetDeviceMake())
  DeviceOSInfo.InfoList.PhysicalScreenWidth = Client.GetPhysicalScreenWidth()
  DeviceOSInfo.InfoList.PhysicalScreenHeight = Client.GetPhysicalScreenHeight()
  DeviceOSInfo.InfoList.UserDefineDeviceName = Client.GetDeivceNickName()
  DeviceOSInfo.InfoList.GPUFamily = DeviceOSInfo.GetGPUFamily()
  DeviceOSInfo.InfoList.DeviceGradeLevel = Client.GetTCDeviceLevel()
  DeviceOSInfo.InfoList.AdvertisingID = ""
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    DeviceOSInfo.InfoList.XID = DeviceOSInfo.GetXID()
    local l1xid = ""
    DeviceOSInfo.InfoList.L1XID = tostring(l1xid)
    local OAID = TApmHelper.GetDataFromTGPA("OAID", "")
    DeviceOSInfo.InfoList.OAID = tostring(OAID)
  else
    DeviceOSInfo.InfoList.XID = ""
    DeviceOSInfo.InfoList.L1XID = ""
    DeviceOSInfo.InfoList.OAID = ""
  end
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  DeviceOSInfo.InfoList.BattleFPS = LogicSettingGraphics.GetBattleFPS_CloudGame(nil)
  local logic_tt_ban = require("client.logic.login.logic_tt_ban")
  DeviceOSInfo.InfoList.IsTTVPN = logic_tt_ban:IsVPNConnected()
  DeviceOSInfo.InfoList.TTCarrierInfo = logic_tt_ban:GetShortCarrier()
  DeviceOSInfo.InfoList.TTTimeZone = logic_tt_ban:GetSysTimeZone()
  local firebaseHelper = import("FirebaseHelper").GetInstance()
  DeviceOSInfo.InfoList.FirebaseInstanceID = firebaseHelper:GetFIRAppInstanceId()
  if IsWoWEditor then
    DeviceOSInfo.InfoList.SystemHardware = string.format("%s+%s", DeviceOSInfo.InfoList.DeviceMake, DeviceOSInfo.InfoList.DeviceModel)
  end
end
function DeviceOSInfo.GetXID()
  local L2XID = ""
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    L2XID = logic_cloud_game:GetCloudGameClientXID()
  else
    local TApmHelper = import("TApmHelper")
    local xid = TApmHelper.GetDataFromTGPA("XID", "WithoutInit")
    L2XID = tostring(xid)
  end
  return L2XID
end
function DeviceOSInfo.GetGPUFamily()
  local gpuFamily = ""
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    gpuFamily = logic_cloud_game:GetCloudGameClientGPUFamily()
  else
    gpuFamily = Client.GetGPUFamily()
  end
  return gpuFamily
end
function DeviceOSInfo.GetDeviceName()
  local deviceName = ""
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    deviceName = logic_cloud_game:GetCloudGameClientDeviceName()
  else
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    deviceName = device_module.sDeviceName
  end
  return deviceName
end
function DeviceOSInfo.GetIsPlayerUsingVPN()
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    return logic_cloud_game:IsClientVPNConnected()
  else
    return Client.GetIsPlayerUsingVPN()
  end
end
return DeviceOSInfo