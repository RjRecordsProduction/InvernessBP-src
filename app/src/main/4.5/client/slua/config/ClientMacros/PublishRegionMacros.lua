local PublishRegionMacros = {
  JAPAN = "JAPAN",
  KOREA = "KOREA",
  CE = "CE",
  VNG = "VNG",
  TW = "TW",
  BLUEHOLE = "BLUEHOLE",
  FIT = "FIT",
  FITCE = "FITCE",
  GLOBAL = "GLOBAL"
}
local cacheIsJapanOrKorea, cacheIsBLUEHOLE, cacheIsCEVersion, cacheIsFITVersion, cacheIsTWVersion, cacheIsVNGVersion, cacheIsGlobal
function PublishRegionMacros.IsJapanOrKorea()
  if cacheIsJapanOrKorea ~= nil then
    return cacheIsJapanOrKorea
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.JAPAN or region == PublishRegionMacros.KOREA then
    cacheIsJapanOrKorea = true
    return true
  end
  cacheIsJapanOrKorea = false
  return false
end
function PublishRegionMacros.IsBLUEHOLE()
  if cacheIsBLUEHOLE ~= nil then
    return cacheIsBLUEHOLE
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.BLUEHOLE then
    cacheIsBLUEHOLE = true
    return true
  end
  cacheIsBLUEHOLE = false
  return false
end
function PublishRegionMacros.IsCEVersion()
  if cacheIsCEVersion ~= nil then
    return cacheIsCEVersion
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.CE or region == PublishRegionMacros.FITCE then
    cacheIsCEVersion = true
    return true
  end
  cacheIsCEVersion = false
  return false
end
function PublishRegionMacros.IsFITVersion()
  if cacheIsFITVersion ~= nil then
    return cacheIsFITVersion
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.FIT or region == PublishRegionMacros.FITCE then
    cacheIsFITVersion = true
    return true
  end
  cacheIsFITVersion = Client.IsJaguar()
  return cacheIsFITVersion
end
function PublishRegionMacros.IsTWVersion()
  if cacheIsTWVersion ~= nil then
    return cacheIsTWVersion
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.TW then
    cacheIsTWVersion = true
    return true
  end
  cacheIsTWVersion = false
  return false
end
function PublishRegionMacros.IsVNGVersion()
  if cacheIsVNGVersion ~= nil then
    return cacheIsVNGVersion
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.VNG then
    cacheIsVNGVersion = true
    return true
  end
  cacheIsVNGVersion = false
  return false
end
function PublishRegionMacros.IsGlobalVersion()
  if cacheIsGlobal ~= nil then
    return cacheIsGlobal
  end
  if not Client then
    return false
  end
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.GLOBAL or region == PublishRegionMacros.FIT then
    cacheIsGlobal = true
    return true
  end
  cacheIsGlobal = false
  return false
end
function PublishRegionMacros.GMSetFITSwitcher()
  if IsEditor then
    cacheIsFITVersion = true
  end
end
return PublishRegionMacros