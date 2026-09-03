local logic_login_backup = {}
local save_slot_name = {
  ServerIPs = "LoginBackupServers",
  CloudIPs = "LoginBackupClouds",
  LastIP = "LoginBackupLast"
}
function logic_login_backup.SaveTableToJsonWithXOR(fileType, _ip_tb)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  LogicPlayerPrefs.PlayerDataDict[fileType] = _ip_tb
  local saveStr = json.encode(_ip_tb)
  local StringUtil = require("common.string_util")
  xpcall(function()
    saveStr = StringUtil.EncodeXOR(saveStr, true, "login_backup")
  end, function()
    saveStr = nil
  end)
  logic_login_backup.SaveGame(fileType, saveStr)
end
function logic_login_backup.LoadTableToJsonWithXOR(fileType)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local StringUtil = require("common.string_util")
  if LogicPlayerPrefs.PlayerDataDict[fileType] ~= nil then
    return LogicPlayerPrefs.PlayerDataDict[fileType]
  end
  local str = logic_login_backup.LoadGame(fileType)
  if str then
    xpcall(function()
      str = StringUtil.EncodeXOR(str, false, "login_backup")
    end, function()
      str = nil
    end)
  end
  if str == nil or str == "" then
    return nil
  else
    local data = json.decode(str)
    LogicPlayerPrefs.PlayerDataDict[fileType] = data
    return data
  end
end
function logic_login_backup.HandleLobbyServerIPs(ip_table)
  log_tree("HandleLobbyServerIPs", ip_table)
  local _ip_tb = {}
  if ip_table and type(ip_table) == "table" then
    for k, v in pairs(ip_table) do
      table.insert(_ip_tb, string.format("%s:%d", v.ip, v.port))
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  logic_login_backup.SaveTableToJsonWithXOR(save_slot_name.ServerIPs, _ip_tb)
end
local _FetchAndSaveUrlFromHDmpveRemote = function(key, saveSlotName, ipList, ipHasSet)
  if not key or key == "" then
    return
  end
  if not saveSlotName or saveSlotName == "" then
    return
  end
  if not ipList or not ipHasSet then
    return
  end
  local urlJson = HDmpveRemote.HDmpveRemoteConfigGetString(key, "")
  local cloudUrls
  if urlJson and urlJson ~= "" then
    cloudUrls = json.decode(urlJson)
    logic_login_backup.SaveTableToJsonWithXOR(saveSlotName, cloudUrls)
  else
    cloudUrls = logic_login_backup.LoadTableToJsonWithXOR(saveSlotName)
  end
  if cloudUrls and type(cloudUrls) == "table" then
    for _, v in pairs(cloudUrls) do
      if not ipHasSet[v] then
        table.insert(ipList, v)
        ipHasSet[v] = true
      end
    end
  end
end
function logic_login_backup.InitBackUpIPs(addrArray)
  local ips = {}
  local _ip_has_set = {}
  local urlJson = HDmpveRemote.HDmpveRemoteConfigGetString("GCloudBackUpUrl", "")
  if urlJson and urlJson ~= "" then
    local cloudUrls = json.decode(urlJson)
    if cloudUrls and type(cloudUrls) == "table" then
      for _, v in pairs(cloudUrls) do
        if not _ip_has_set[v] then
          table.insert(ips, v)
          _ip_has_set[v] = true
        end
      end
    end
  end
  for _, v in pairs(addrArray) do
    if not _ip_has_set[v] then
      table.insert(ips, v)
      _ip_has_set[v] = true
    end
  end
  local fileType = save_slot_name.ServerIPs
  local server_ip = logic_login_backup.LoadTableToJsonWithXOR(fileType)
  if server_ip then
    local lastip_str = logic_login_backup.LoadTableToJsonWithXOR(save_slot_name.LastIP)
    if lastip_str and lastip_str[1] then
      local lastip = lastip_str[1]
      for k, v in pairs(server_ip) do
        if v == lastip then
          local temp = server_ip[1]
          server_ip[1] = v
          server_ip[k] = temp
          break
        end
      end
    end
    for k, v in pairs(server_ip) do
      if not _ip_has_set[v] then
        table.insert(ips, v)
        _ip_has_set[v] = true
      end
    end
  end
  _FetchAndSaveUrlFromHDmpveRemote("CloudBackUpIP", save_slot_name.CloudIPs, ips, _ip_has_set)
  if #ips < 1 then
    log_error("logic_login_backup.InitBackUpIPs no valid ip!!!")
    return
  end
  local lastIpIndex = 1
  logic_login_backup.TryCount = #ips - 1
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  logic_login_backup.loginLobbyUrlArray = ips
  logic_login_backup.loginLobbyIndex = lastIpIndex
  login_module:SetLobbyUrl(ips[lastIpIndex])
end
function logic_login_backup.PollingNextIp()
  if not logic_login_backup.TryCount or logic_login_backup.TryCount <= 0 then
    return false
  end
  local ip_length = #logic_login_backup.loginLobbyUrlArray
  logic_login_backup.loginLobbyIndex = logic_login_backup.loginLobbyIndex + 1
  if ip_length < logic_login_backup.loginLobbyIndex then
    logic_login_backup.loginLobbyIndex = logic_login_backup.loginLobbyIndex % ip_length
  end
  log(bWriteLog and "PollingNextIp index = " .. tostring(logic_login_backup.loginLobbyIndex) .. " length = " .. tostring(ip_length))
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:SetLobbyUrl(logic_login_backup.loginLobbyUrlArray[logic_login_backup.loginLobbyIndex])
  logic_login_backup.TryCount = logic_login_backup.TryCount - 1
  local connect_ip = {}
  table.insert(connect_ip, login_module.loginLobbyInfo.Url)
  logic_login_backup.SaveTableToJsonWithXOR(save_slot_name.LastIP, connect_ip)
  return true
end
function logic_login_backup.SaveGame(param_name, value)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.loginBackUp)
  saveData = saveData or {}
  saveData[param_name] = value
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.loginBackUp)
end
function logic_login_backup.LoadGame(param_name)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.loginBackUp)
  if saveData then
    return saveData[param_name]
  else
    return nil
  end
end
return logic_login_backup