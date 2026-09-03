local DeviceUtils = {
  ENum_MemorySize = {
    GreaterThan4G = 1,
    GreaterThan3G = 2,
    GreaterThan2G = 3,
    GreaterThan1G = 4,
    LessThan1G = 5
  },
  ENum_DeviceLevel = {
    High = 2,
    Medium = 1,
    Low = 0
  }
}
function DeviceUtils.GetDeviceMemoryType()
  local nMemorySize = Client and Client.GetMemorySize() or 0
  if 4 < nMemorySize then
    return DeviceUtils.ENum_MemorySize.GreaterThan4G
  elseif 3 < nMemorySize then
    return DeviceUtils.ENum_MemorySize.GreaterThan3G
  elseif 2 < nMemorySize then
    return DeviceUtils.ENum_MemorySize.GreaterThan2G
  elseif 1 < nMemorySize then
    return DeviceUtils.ENum_MemorySize.GreaterThan1G
  else
    return DeviceUtils.ENum_MemorySize.LessThan1G
  end
end
function DeviceUtils.GetDeviceLevel()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if GameInstance and GameInstance.GetDeviceLevel then
    return GameInstance:GetDeviceLevel()
  end
  return DeviceUtils.ENum_DeviceLevel.Medium
end
function DeviceUtils.GetTCDeviceLevel()
  if Client and Client.GetTCDeviceLevel then
    return Client.GetTCDeviceLevel()
  end
  return 4
end
function DeviceUtils.GetCPUClockCycles()
  if Client and Client.GetCPUClockCycles then
    return Client.GetCPUClockCycles()
  end
  return 0
end
function DeviceUtils.GetCPUCoreCount()
  if Client and Client.GetCPUCoreCount then
    return Client.GetCPUCoreCount()
  end
  return 1
end
function DeviceUtils.GetCPUMaxFrequency()
  if Client and Client.GetCPUMaxFrequency then
    local nFrequencyHz = Client.GetCPUMaxFrequency()
    return nFrequencyHz / 1000000000
  end
  return 0
end
return DeviceUtils