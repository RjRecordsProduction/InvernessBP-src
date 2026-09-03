globalConfig = globalConfig or {
  isDirectConnect = true,
  isShowFaceSlapOnWindows = false,
  isOpenTickNetMaxTime = false,
  isSupervision = false
}
function globalConfig.IsDirectConnect()
  if Client.IsWindowOB() and Client.IsShipping() then
    return true
  end
  return globalConfig.isDirectConnect
end