local logic_ai_take_over = {}
function logic_ai_take_over:OnInitialize()
  log(bWriteLog and "logic_ai_take_over:OnInitialize")
end
function logic_ai_take_over:OnDestroy()
  log(bWriteLog and "logic_ai_take_over:OnDestroy")
end
function logic_ai_take_over:ReportTLog(type)
  log(bWriteLog and "logic_ai_take_over:ReportTLog type = " .. type)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    return
  end
  local bOpen = 0
  if type == 0 then
    if PublishRegionMacros.IsJapanOrKorea() then
    else
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      if SettingHandler.ally_ai_takeover_zones then
        local table_util = require("common.table_util")
        local logic_zone = require("client.slua.logic.teamup.logic_zone")
        if table_util.Find(SettingHandler.ally_ai_takeover_zones, logic_zone.nChooseZoneID) ~= -1 then
          bOpen = 1
        end
      end
    end
  else
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    local bCfgOpen = SettingModule:GetOptionValue("TeammateTakeOver")
    if bCfgOpen then
      bOpen = 1
    else
      bOpen = 0
    end
  end
  log(bWriteLog and "logic_ai_take_over:ReportTLog bOpen = " .. bOpen)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LOBBY_SETTING_AI_TAKE_OVER, bOpen)
end
function logic_ai_take_over:BShowButton()
  if IsWoWEditor then
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() or PublishRegionMacros.IsJapanOrKorea() then
    print(bWriteLog and "logic_ai_take_over:BShowButton BLUEHOLE or JapanOrKorea version")
    return false
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  if SettingHandler.ally_ai_takeover_zones then
    local TableUtil = require("common.table_util")
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    log(bWriteLog and "logic_ai_take_over:BShowButton nChooseZoneID = " .. tostring(ZoneSystem.nChooseZoneID))
    if TableUtil.Find(SettingHandler.ally_ai_takeover_zones, ZoneSystem.nChooseZoneID) ~= -1 then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_ai_take_over)
return CModuleTemplate