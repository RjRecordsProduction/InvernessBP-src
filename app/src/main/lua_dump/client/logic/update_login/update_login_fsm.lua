UpdateAndLoginFSM = UpdateAndLoginFSM or {
  ARRAY_ServerList_Info = {},
  SelectedShowServerInfo = 0,
  UIStatReportHander = nil
}
local local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
local _InitStyles = function()
  Client.SetAllFontStyle()
  local image_style = require("client.common.image_style")
  image_style.AddImageStyle()
  Client.SetAllLinkStyle()
end
local _InitGameStatusMap = function()
  local StatusToMap = {
    Login = "/Game/Maps/UImap/Editor_login",
    Lobby = "/Game/Maps/UImap/Lobby_Main_int",
    CreateRole = "/Game/Maps/UImap/Createrole",
    Loading = "/Game/Maps/UImap/Loading"
  }
  if IsWoWEditor then
    StatusToMap.Lobby = "/Game/Maps/UImap/EmptyForTestLeak"
  end
  Client.SetGameStatusMap(GameFrontendHUD, StatusToMap)
end
local _InitTimeDisplay = function()
  local SettingTimeDisplay = require("client.logic.setting.logic_setting_time_display")
  SettingTimeDisplay.LoadTimeDisplay()
end
local _InitConfigs = function()
  _InitGameStatusMap()
  _InitStyles()
  _InitTimeDisplay()
end
function UpdateAndLoginFSM.InitOnlyOne()
  Client.SetBtnClickInCdFunc()
  local utility = require("common.utility")
  xpcall(_InitConfigs, utility.ErrorMessageHandler)
  xpcall(FuncUtil.InitRemoteCfg, utility.ErrorMessageHandler)
  ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_apple_gamecenter_achievement)
  ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_google_play_achievement)
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  if ToolReportUtil:IsClientToolOpen() then
    if slua_GameFrontendHUD.OnReportClientTool and not UpdateAndLoginFSM.ReportClientToolHander then
      UpdateAndLoginFSM.ReportClientToolHander = slua_GameFrontendHUD.OnReportClientTool:Add(function(msg, type)
        ClientToolsReport:SendReport(type, msg)
      end)
    end
    if slua_GameFrontendHUD.OnUIStatReport and not UpdateAndLoginFSM.UIStatReportHander then
      UpdateAndLoginFSM.UIStatReportHander = slua_GameFrontendHUD.OnUIStatReport:Add(function(result)
        ClientToolsReport:SendReport(ClientToolsReport.Enum_SvrReport_Type.Enum_Capability, result)
      end)
    end
  end
end
function UpdateAndLoginFSM.GetUpdater()
  local updater = slua_GameFrontendHUD:GetUpdater()
  if updater == nil then
    log(bWriteLog and "UpdateAndLoginFSM:GetUpdater, result = " .. tostring(updater))
  end
  return updater
end