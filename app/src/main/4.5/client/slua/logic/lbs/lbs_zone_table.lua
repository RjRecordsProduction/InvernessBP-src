local lbs_zone_table = {
  resZoneData = nil,
  bIndiaVersion = nil,
  bCountryHasProvinceMap = {},
  lbsNameExample = nil
}
function lbs_zone_table.GetZoneName(zoneData)
  if not zoneData then
    log(bWriteLog and "lbs_zone_table.GetZoneName: zoneData is nil")
    return ""
  end
  if zoneData.name_notranslation and zoneData.name_notranslation ~= "" then
    log(bWriteLog and "lbs_zone_table.GetZoneName: using name_notranslation - " .. tostring(zoneData.name_notranslation))
    return zoneData.name_notranslation
  end
  if zoneData.name and zoneData.name ~= "" then
    log(bWriteLog and "lbs_zone_table.GetZoneName: using name - " .. tostring(zoneData.name))
    return zoneData.name
  end
  log(bWriteLog and "lbs_zone_table.GetZoneName: both name_notranslation and name are empty")
  return ""
end
function lbs_zone_table.ProcGetZoneData(resZoneData)
  log(bWriteLog and "lbs_zone_table.ProcGetZoneData")
  log_tree("resZoneData = ", resZoneData)
  lbs_zone_table.end
function lbs_zone_table.GetZoneCfg(id)
  log(bWriteLog and "lbs_zone_table.GetZoneCfg id = " .. tostring(id))
  if not id then
    return nil
  end
  if lbs_zone_table.resZoneData then
    local cfg = lbs_zone_table.resZoneData[id]
    if cfg then
      return cfg
    end
  end
  if lbs_zone_table.bIndiaVersion == nil then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    lbs_zone_table.bIndiaVersion = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  end
  if lbs_zone_table.bIndiaVersion then
    return CDataTable.GetTableData("LBSRegionLevelConfigBLUEHOLE", id)
  else
    return CDataTable.GetTableData("LBSRegionLevelConfig", id)
  end
end
function lbs_zone_table.CheckCountryHasProvince(ID)
  if lbs_zone_table.bCountryHasProvinceMap[ID] ~= nil then
    log(bWriteLog and "lbs_zone_table.CheckCountryHasProvince lbs_zone_table.bCountryHasProvinceMap[ID]")
    return lbs_zone_table.bCountryHasProvinceMap[ID]
  end
  local resZoneData = lbs_zone_table.resZoneData
  if resZoneData then
    for k, v in pairs(resZoneData) do
      if v.father == ID and v.level == 30 then
        lbs_zone_table.bCountryHasProvinceMap[ID] = true
        log(bWriteLog and "lbs_zone_table.CheckCountryHasProvince resZoneData")
        return true
      end
    end
  end
  local tb
  if lbs_zone_table.bIndiaVersion then
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfigBLUEHOLE", "father", ID, "level", 30)
  else
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfig", "father", ID, "level", 30)
  end
  for k, v in pairs(tb) do
    lbs_zone_table.bCountryHasProvinceMap[ID] = true
    log(bWriteLog and "lbs_zone_table.CheckCountryHasProvince tb")
    return true
  end
  log(bWriteLog and "lbs_zone_table.CheckCountryHasProvince false")
  lbs_zone_table.bCountryHasProvinceMap[ID] = false
  return false
end
function lbs_zone_table.GetMyLBSNameExample()
  log(bWriteLog and "lbs_zone_table.GetMyLBSNameExample")
  if lbs_zone_table.lbsNameExample ~= nil then
    return lbs_zone_table.lbsNameExample
  end
  local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
  local myZoneCfg = lbs_zone_table.GetZoneCfg(logic_lbs.myCountry)
  if not myZoneCfg then
    return ""
  end
  local exampleName = lbs_zone_table.GetZoneName(myZoneCfg)
  local tb
  if lbs_zone_table.bIndiaVersion then
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfigBLUEHOLE", "father", myZoneCfg.ID, "level", 30)
  else
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfig", "father", myZoneCfg.ID, "level", 30)
  end
  local cfg
  for k, v in pairs(tb) do
    cfg = v
    break
  end
  if cfg == nil then
    lbs_zone_table.lbsNameExample = exampleName
    return exampleName
  end
  exampleName = exampleName .. "-" .. lbs_zone_table.GetZoneName(cfg)
  if lbs_zone_table.bIndiaVersion then
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfigBLUEHOLE", "father", cfg.ID, "level", 40)
  else
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfig", "father", cfg.ID, "level", 40)
  end
  cfg = nil
  for k, v in pairs(tb) do
    cfg = v
    break
  end
  if cfg == nil then
    lbs_zone_table.lbsNameExample = exampleName
    return exampleName
  end
  exampleName = exampleName .. "-" .. lbs_zone_table.GetZoneName(cfg)
  if lbs_zone_table.bIndiaVersion then
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfigBLUEHOLE", "father", cfg.ID, "level", 50)
  else
    tb = CDataTable.GetTableByFilter("LBSRegionLevelConfig", "father", cfg.ID, "level", 50)
  end
  cfg = nil
  for k, v in pairs(tb) do
    cfg = v
    break
  end
  if cfg == nil then
    return exampleName
  end
  exampleName = exampleName .. "-" .. lbs_zone_table.GetZoneName(cfg)
  lbs_zone_table.lbsNameExample = exampleName
  log(bWriteLog and "lbs_zone_table.GetMyLBSNameExample " .. exampleName)
  return exampleName
end
return lbs_zone_table