local DataMigrationSystem = {
  nextStep = nil,
  haveReceived = false,
  migrationState = 1,
  migrationState_init = 1,
  migrationState_havePopuped = 2,
  migrationState_iTop_Completed = 3,
  migrationState_NotStart = 4,
  migrationState_migrating = 5,
  migrationState_Completed = 6,
  noticeId = nil
}
function DataMigrationSystem.SetNoticeId(noticeId)
  DataMigrationSystem.  log_warning(bWriteLog and "  :DataMigrationSystem.SetNoticeId noticeId: " .. tostring(noticeId))
end
function DataMigrationSystem.GetCurrentState()
  log(bWriteLog and "DataMigrationSystem.GetCurrentState, state = " .. tostring(DataMigrationSystem.migrationState))
  return DataMigrationSystem.migrationState
end
function DataMigrationSystem.HaveReceivedInfo()
  log(bWriteLog and "DataMigrationSystem.HaveReceivedInfo, haveReceived = " .. tostring(DataMigrationSystem.haveReceived))
  return DataMigrationSystem.haveReceived
end
function DataMigrationSystem.ResetData()
  DataMigrationSystem.nextStep = nil
  DataMigrationSystem.haveReceived = false
  DataMigrationSystem.migrationState = 0
end
function DataMigrationSystem.DataMigrationStateRequest()
  log(bWriteLog and "DataMigrationSystem.DataMigrationStateRequest")
  local DataMigrationHandler = require("client.network.Protocol.DataMigrationHandler")
  DataMigrationHandler.send_get_migrate_status_req()
end
function DataMigrationSystem.DataMigrationStateResponse(res, state)
  log(bWriteLog and "DataMigrationSystem.DataMigrationStateResponse, res = " .. tostring(res) .. ", state = " .. tostring(state))
  if res == 0 then
    DataMigrationSystem.migrationState = state
    DataMigrationSystem.haveReceived = true
    EventSystem:postEvent(EVENTTYPE_DATA_MIGRATION, EVENTID_DATA_MIGRATION_STATE)
  else
  end
end
function DataMigrationSystem.DataMigrationRequest()
  local DataMigrationHandler = require("client.network.Protocol.DataMigrationHandler")
  DataMigrationHandler.send_start_migrate_req()
end
function DataMigrationSystem.DataMigrationResponse(res, state)
  log(bWriteLog and "DataMigrationSystem.DataMigrationResponse, res = " .. tostring(res) .. ", state = " .. tostring(state))
  if res == 0 then
    DataMigrationSystem.migrationState = state
    if state == DataMigrationSystem.migrationState_migrating then
      UIManager.ShowUI(UIManager.UI_Config.data_migration)
    else
    end
  end
end
function DataMigrationSystem.ReportChoiceRequest(yes)
  log(bWriteLog and "DataMigrationSystem.ReportChoiceRequest, yes = " .. tostring(yes))
  local DataMigrationHandler = require("client.network.Protocol.DataMigrationHandler")
  DataMigrationHandler.send_set_migrate_status_req(DataMigrationSystem.migrationState_havePopuped, yes)
end
function DataMigrationSystem.ReportChoiceResponse(res, state, choice)
  log(bWriteLog and "DataMigrationSystem.ReportChoiceResponse, res = " .. tostring(res) .. ", state = " .. tostring(state))
  if res == 0 then
    DataMigrationSystem.migrationState = state
  end
end
function DataMigrationSystem.OpenWebview()
  log(bWriteLog and "DataMigrationSystem.OpenWebview, loginType = " .. tostring(BP_ENUM_PLAYFORM_MIGRATE))
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:LoginWithExtraInfo(BP_ENUM_PLAYFORM_MIGRATE, "{}")
  UIManager.ShowUI(UIManager.UI_Config.data_migration)
end
function DataMigrationSystem.PromptMigrateWindow(NextStep)
  local title = LocUtil.GetLocalizeResStr(21242)
  local tips = LocUtil.GetLocalizeResStr(11588)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE then
    tips = LocUtil.GetLocalizeResStr(21188)
  end
  local okLabel = LocUtil.GetLocalizeResStr(21190)
  local cancelLabel = LocUtil.GetLocalizeResStr(21191)
  local urlHandle = function()
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366050) .. "/a/support/?s=account-statistics-rank-rp&f=test&l=ko", true)
  end
  local extraData = {urlHandle = urlHandle}
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    DataMigrationSystem.OpenWebview()
    DataMigrationSystem.ReportChoiceRequest(1)
  end, function()
    DataMigrationSystem.AskIfSureRejectMigrate(NextStep)
  end, okLabel, cancelLabel, false, nil, false, false, false, nil, urlHandle, extraData)
end
function DataMigrationSystem.AskIfSureRejectMigrate(NextStep)
  local title = LocUtil.GetLocalizeResStr(21242)
  local tips = LocUtil.GetLocalizeResStr(24183)
  local okLabel = LocUtil.GetLocalizeResStr(24184)
  local cancelLabel = LocUtil.GetLocalizeResStr(24185)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    DataMigrationSystem.ReportChoiceRequest(0)
    if type(NextStep) == "function" then
      NextStep()
    end
  end, function()
    DataMigrationSystem.OpenWebview()
    DataMigrationSystem.ReportChoiceRequest(1)
  end, okLabel, cancelLabel)
end
function DataMigrationSystem.PromptConfrimIndiaPlayerWindow(NextStep)
  local title = LocUtil.GetLocalizeResStr(21242)
  local tips = LocUtil.GetLocalizeResStr(21184)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    DataMigrationSystem.PromptMigrateWindow(NextStep)
  end, function()
    DataMigrationSystem.PromptDenyIndiaPlayerTips()
  end, LocUtil.GetLocalizeResStr(21187), LocUtil.GetLocalizeResStr(21185))
end
function DataMigrationSystem.PromptDenyIndiaPlayerTips()
  local title = LocUtil.GetLocalizeResStr(21242)
  local tips = LocUtil.GetLocalizeResStr(21186)
  local backLogin = function()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:backLogin()
  end
  local extraData = {androidCallback = backLogin}
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, tips, backLogin, function()
  end, LocUtil.GetLocalizeResStr(21187), "", false, nil, false, nil, false, nil, nil, extraData)
end
function DataMigrationSystem.DataMigrationOrNextStep(NextStep)
  DataMigrationSystem.isDoneNextStep = false
  DataMigrationSystem.nextStep = NextStep
  local paramType = type(NextStep)
  log(bWriteLog and "DataMigrationSystem.DataMigrationOrNextStep, paramType = " .. tostring(paramType))
  if GameStatus.IsInLobbyOrMainCity() then
    if DataMigrationSystem.HaveReceivedInfo() == true then
      local migrationState = DataMigrationSystem.GetCurrentState()
      if migrationState == DataMigrationSystem.migrationState_init then
        DataMigrationSystem.DisablePromotionalVideo()
        local strRegion = Client.GetPublishRegion()
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if strRegion == PublishRegionMacros.BLUEHOLE then
          DataMigrationSystem.PromptConfrimIndiaPlayerWindow(NextStep)
        else
          DataMigrationSystem.PromptMigrateWindow(NextStep)
        end
      elseif migrationState == DataMigrationSystem.migrationState_havePopuped then
        if paramType == "function" then
          NextStep()
        end
      elseif migrationState == DataMigrationSystem.migrationState_iTop_Completed then
        if paramType == "function" then
          NextStep()
        end
      elseif migrationState == DataMigrationSystem.migrationState_NotStart then
        DataMigrationSystem.DataMigrationRequest()
      elseif migrationState == DataMigrationSystem.migrationState_migrating then
        UIManager.ShowUI(UIManager.UI_Config.data_migration)
      elseif migrationState == DataMigrationSystem.migrationState_Completed then
        if paramType == "function" then
          NextStep()
        end
      elseif paramType == "function" then
        NextStep()
      end
    elseif paramType == "function" then
      NextStep()
    end
  else
    log(bWriteLog and "DataMigrationSystem.DataMigrationOrNextStep, dont in lobby.")
    if paramType == "function" then
      NextStep()
    end
  end
end
function DataMigrationSystem.DisablePromotionalVideo()
  local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
  if KeyPlayVideoSystem ~= nil then
    KeyPlayVideoSystem.switch = false
    log(bWriteLog and "DataMigrationSystem.DisablePromotionalVideo")
  end
end
return DataMigrationSystem