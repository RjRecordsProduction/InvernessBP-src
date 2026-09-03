local DevicePlatformNameMacros = {
  Android = "Android",
  HTML5 = "HTML5",
  IOS = "IOS",
  Linux = "Linux",
  Mac = "Mac",
  Switch = "Switch",
  Windows = "Windows",
  PS4 = "PS4"
}
function DevicePlatformNameMacros.IsPC()
  local DevicePlatformName = Client.GetDevicePlatformName()
  return DevicePlatformName == DevicePlatformNameMacros.Windows or DevicePlatformName == DevicePlatformNameMacros.Mac
end
function DevicePlatformNameMacros.GetDeviceName()
  local DevicePlatformName = Client.GetDevicePlatformName()
  local DeviceName = ""
  if DevicePlatformName == DevicePlatformNameMacros.Android then
    local OMobileFBPL = import("OMobileFBPL")
    DeviceName = OMobileFBPL.GetDeviceName()
  elseif DevicePlatformName == DevicePlatformNameMacros.IOS then
    DeviceName = Client.GetActiveProfileName()
  elseif IsWoWEditor then
    DeviceName = "WOW Editor Pro"
  else
    DeviceName = "SM-G9550"
  end
  return DeviceName
end
return DevicePlatformNameMacros