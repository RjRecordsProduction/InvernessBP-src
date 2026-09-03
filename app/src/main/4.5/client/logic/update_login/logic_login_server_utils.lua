local logic_login_server_utils = {officialTable = nil}
function logic_login_server_utils.GetServerInfoByTypeAndRegion(type, region, subArea)
  local serverCfg = logic_login_server_utils.GetServerCfgByTypeAndRegion(type, region, subArea)
  if not serverCfg then
    log(bWriteLog and "[muidarzhang] logic_login_server_utils.GetServerInfoByTypeAndRegion, serverCfg == nil ERROR")
    return nil
  end
  serverCfg.addr = logic_login_server_utils.GetIpListByCfg(serverCfg)
  return serverCfg
end
function logic_login_server_utils.GetServerCfgByTypeAndRegion(type, region, subArea)
  if not logic_login_server_utils.officialTable then
    logic_login_server_utils.officialTable = CDataTable.GetTable("OfficialServerList")
  end
  subArea = subArea or ""
  local defaultCfg
  for _, v in pairs(logic_login_server_utils.officialTable) do
    if v.Region == region and v.Type == type then
      if subArea == v.SubArea then
        local cfg = {
          channelInfo = v.channelInfo,
          name = v.name,
          addr = v.addr,
          status = v.status,
          tab = v.tab
        }
        return cfg
      elseif v.SubArea == "" then
        defaultCfg = {
          channelInfo = v.channelInfo,
          name = v.name,
          addr = v.addr,
          status = v.status,
          tab = v.tab
        }
      end
    end
  end
  return defaultCfg
end
function logic_login_server_utils.GetIpListByCfg(cfg)
  if not cfg then
    log(bWriteLog and "[muidarzhang] logic_login_server_utils.GetIpListByCfg, cfg == nil ERROR")
    return nil
  end
  local StringUtil = require("common.string_util")
  local ipStr = cfg.addr
  local ipList = StringUtil.Split(ipStr, ";")
  local toleranceIpStr = cfg.toleranceAddr
  if toleranceIpStr and toleranceIpStr ~= "" then
    local toleranceIpList = StringUtil.Split(toleranceIpStr, ";")
    local randomIndex = #toleranceIpList
    table.insert(ipList, toleranceIpList[randomIndex])
  end
  return ipList
end
return logic_login_server_utils