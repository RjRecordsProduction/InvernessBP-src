local logic_region_block = {
  blockRechargeCfg = {},
  lastShowTime = 0
}
local GetPayChannelNum = function()
  local paltform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if paltform == DevicePlatformNameMacros.IOS then
    return 2
  end
  local aosShop = Client.GetAOSSHOP()
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  if aosShop == AOSSHOPMacros.Google then
    return 1
  elseif aosShop == AOSSHOPMacros.ThirdPartyPayment then
    return 3
  end
  return 4
end
function logic_region_block.GetBlockType()
  local curBlockType = 0
  local curPromptID = 0
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local ipRegion = login_module.sIpRegion or "ALL"
  local province = login_module.province or "ALL"
  log(bWriteLog and "[DeanJYT] logic_region_block.GetBlockType ipRegion = " .. tostring(ipRegion) .. ", province = " .. tostring(province))
  local TableUtil = require("common.table_util")
  local versionDefaultCfg = TableUtil.GetTableValue(logic_region_block.blockRechargeCfg, "ALL", "ALL")
  local ipDefaultCfg = TableUtil.GetTableValue(logic_region_block.blockRechargeCfg, ipRegion, "ALL")
  local cfg = TableUtil.GetTableValue(logic_region_block.blockRechargeCfg, ipRegion, province)
  cfg = cfg or ipDefaultCfg or versionDefaultCfg
  log_tree("[DeanJYT] logic_region_block.GetBlockType cfg = ", cfg)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local channel = tostring(GetPayChannelNum())
  local StringUtil = require("common.string_util")
  for _, v in pairs(cfg) do
    local channelCfg = StringUtil.Split(v.channel or "", ";")
    local channelMatch = false
    for _, v in pairs(channelCfg) do
      if tostring(v) == tostring(channel) then
        channelMatch = true
      end
    end
    log(bWriteLog and "[DeanJYT] logic_region_block.GetBlockType channelMatch = " .. tostring(channelMatch))
    if channelMatch then
      local curBeginTime = tonumber(v.begin_time) or 0
      local curEndTime = tonumber(v.end_time) or 0
      local promptStyle = tonumber(v.prompt_style) or 0
      local promptID = tonumber(v.prompt_key) or 0
      if v.is_block and curTime > curBeginTime and curTime <= curEndTime then
        curBlockType = promptStyle
        curPromptID = promptID
      end
    end
  end
  return curBlockType, curPromptID
end
function logic_region_block.MakeUrlCallBack(ipRegion)
  local login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local UrlCallBack = function(metaData)
    if metaData.url == "AppDownload" then
      login:backLogin()
      logic_region_block.JumpToAppDownload(ipRegion)
    elseif metaData.url == "OfficialWebsite" then
      login:backLogin()
      logic_region_block.JumpToOfficialSite(ipRegion)
    end
  end
  return UrlCallBack
end
function logic_region_block.ShowCrossRegionRechargeNotify(callback)
  if type(callback) ~= "function" then
    return
  end
  local curBlockType, curPromptID = logic_region_block.GetBlockType()
  log(bWriteLog and "[DeanJYT] logic_region_block.ShowCrossRegionRechargeNotify curBlockType = " .. tostring(curBlockType))
  if curBlockType < 1 then
    callback()
  end
  if curBlockType == 1 then
    logic_region_block.ShowLimitRechargeNotice(callback, curPromptID)
  else
    if curBlockType == 2 then
      logic_region_block.ShowBlockRechargeNotice(curPromptID)
    else
    end
  end
end
function logic_region_block.ShowLimitRechargeNotice(callback, promptID)
  log(bWriteLog and "[DeanJYT] logic_region_block.ShowLimitRechargeNotice lastShowTime = " .. tostring(logic_region_block.lastShowTime))
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.IsSameDay(logic_region_block.lastShowTime, TimeUtil.GetServerTimeInSec()) then
    callback()
    return
  end
  local content = LocUtil.GetLocalizeResStr(promptID)
  local WrappedCallback = function(isChecked)
    callback()
    if isChecked then
      logic_region_block.lastShowTime = TimeUtil.GetServerTimeInSec()
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.SaveTableToFile_N({
        lastShowTime = logic_region_block.lastShowTime
      }, PlayerPrefsSystem.ePlayerPrefsType.etcBlockNotice)
    end
  end
  local agreeTxt = LocUtil.GetLocalizeResStr(8139)
  local cancelTxt = LocUtil.GetLocalizeResStr(8140)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local ipRegion = login_module.sIpRegion or "ALL"
  local extraData = {
    urlHandle = logic_region_block.MakeUrlCallBack(ipRegion),
    isShowCheckBox = true
  }
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, LocUtil.GetLocalizeResStr(5077), content, LocUtil.GetLocalizeResStr(12096), agreeTxt, cancelTxt, WrappedCallback, nil, extraData)
end
function logic_region_block.ShowBlockRechargeNotice(promptID)
  local content = LocUtil.GetLocalizeResStr(promptID)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local ipRegion = login_module.sIpRegion or "ALL"
  local extraData = {
    urlHandle = logic_region_block.MakeUrlCallBack(ipRegion)
  }
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, LocUtil.GetLocalizeResStr(5077), content, nil, LocUtil.GetLocalizeResStr(8139), nil, nil, nil, extraData)
end
function logic_region_block.ShowBlockRegionNotice(ipRegion, key)
  log(bWriteLog and "[DeanJYT] logic_region_block.ShowBlockRegionNotice, ipRegion = " .. tostring(ipRegion) .. ", key = " .. tostring(key))
  local content = LocUtil.GetLocalizeResStr(key)
  if not content or content == "" then
    log(bWriteLog and "[DeanJYT] logic_region_block.ShowBlockRegionNotice not found key = " .. tostring(key))
    content = LocUtil.GetLocalizeResStr(19336)
  end
  local backLogin = function()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:backLogin()
  end
  backLogin()
  local title = LocUtil.GetLocalizeResStr(5077)
  local extraData = {
    urlHandle = logic_region_block.MakeUrlCallBack(ipRegion)
  }
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 0, title, content, nil, nil, nil, backLogin, backLogin, extraData)
end
function logic_region_block.JumpToAppDownload(ipRegion)
  log(bWriteLog and "[DeanJYT] logic_region_block.JumpToAppDownload ipRegion = " .. tostring(ipRegion))
  local linkInfo = CDataTable.GetTableData("RegionBlockLinkTable", ipRegion)
  linkInfo = linkInfo or CDataTable.GetTableData("RegionBlockLinkTable", "ALL")
  local url = ""
  local paltform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if paltform == DevicePlatformNameMacros.IOS then
    url = linkInfo.ios
  elseif paltform == DevicePlatformNameMacros.Android then
    local aosShop = Client.GetAOSSHOP()
    url = linkInfo[aosShop]
    if url == "" then
      url = linkInfo.Google
    end
  else
    log(bWriteLog and "[DeanJYT] logic_region_block.JumpToAppDownload - device not recognized")
  end
  log(bWriteLog and "[DeanJYT] logic_region_block.JumpToAppDownload url = " .. tostring(url))
  GlobalData.JumpUrl(url)
end
function logic_region_block.JumpToOfficialSite(ipRegion)
  local linkInfo = CDataTable.GetTableData("RegionBlockLinkTable", ipRegion)
  if not (linkInfo and linkInfo.OfficialWebsite) or linkInfo.OfficialWebsite == "" then
    linkInfo = CDataTable.GetTableData("RegionBlockLinkTable", "ALL")
  end
  local website = linkInfo.OfficialWebsite or ""
  log(bWriteLog and "[DeanJYT] logic_region_block.JumpToOfficialSite OfficialWebsite = " .. tostring(website))
  GlobalData.JumpUrl(website)
end
function logic_region_block.IsCrossRegionPlayer()
  if not LobbySystem.CheckOpen(BP_ENUM_RECHARGE_BLOCK) then
    return false
  end
  local cfg = logic_region_block.blockRechargeCfg
  if cfg and next(cfg) then
    return true
  end
  return false
end
function logic_region_block.OnLogin()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastTime = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.etcBlockNotice) or {}
  logic_region_block.lastShowTime = lastTime.lastShowTime or 0
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.multi_region_charge_block_table, logic_region_block.InitblockRechargeCfg)
end
function logic_region_block.InitblockRechargeCfg(_, cfg)
  log(bWriteLog and "[DeanJYT] logic_region_block.InitblockRechargeCfg appID = " .. tostring(Client.GetITopGameId()))
  log_tree("[DeanJYT] logic_region_block.InitblockRechargeCfg cfg = ", cfg)
  if not cfg or type(cfg) ~= "table" then
    return
  end
  logic_region_block.blockRechargeCfg = {}
  for k, v in pairs(cfg) do
    if tostring(k) == tostring(Client.GetITopGameId()) then
      logic_region_block.blockRechargeCfg = v
    end
  end
  log_tree("[DeanJYT] logic_region_block.InitblockRechargeCfg blockRechargeCfg = ", logic_region_block.blockRechargeCfg)
end
return logic_region_block