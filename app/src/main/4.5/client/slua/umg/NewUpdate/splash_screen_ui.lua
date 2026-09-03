local SplashScreenUI = {}
local gem_report_utils = require("client.logic.store.gem_report_utils")
function SplashScreenUI:OnPostInitialize()
  log(bWriteLog and "SplashScreenUI:OnPostInitialize")
  SplashScreenUI.__super.OnPostInitialize(self)
  self:Initialize()
  if Client.IsShipping() then
    self.UIRoot.refactorLabel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.refactorLabel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SplashScreenUI:Initialize()
  log_shipping_client("SplashScreenUI:Initialize, global_patch_make_time = " .. tostring(global_patch_make_time))
  log_shipping_client("SplashScreenUI:Initialize, global_package_make_time = " .. tostring(global_package_make_time))
  if Client.IsDevelopment() then
    local uBusinessHelper = import("BusinessHelper")
    local buildUrl = uBusinessHelper.GetBuildURL()
    local PipelineUrl = string.format("https://%s/console/pipeline/pubgm-client/%s/outputs", FuncUtil.GetDomainByID(3366211), buildUrl)
    log(bWriteLog and "  debug. PipelineUrl: " .. tostring(PipelineUrl))
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = login_module,
    funcName = "ReportSysInfoToGEM",
    param = login_module,
    debugInfo = "ReportSysInfoToGEM",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Login, task)
  self:AssetUseHistoryInfo()
  local switchHitTest = 0
  if _G.IsEditor then
    switchHitTest = 1
  else
    switchHitTest = HDmpveRemote.HDmpveRemoteConfigGetInt("GEnableHitTestOptimization", 0)
  end
  log_shipping_client("SplashScreenUI:Initialize switchHitTest = " .. switchHitTest)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("s.GEnableHitTestOptimization", switchHitTest)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() then
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:InitializePuffer(true)
  end
end
function SplashScreenUI:OnShow()
  log(bWriteLog and "SplashScreenUI:OnShow")
  SplashScreenUI.__super.OnShow(self)
  local utility = require("common.utility")
  xpcall(self.RefreshUI, function(err)
    utility.ErrorMessageHandler(err)
    self:OnAnimationFinished()
  end, self)
  self:AddTimer(0, function()
    local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
    logic_cost_collector:ReportElapsedTimeAfterLaunch(logic_cost_collector.EVENT_KEYS.BEFORE_SPLASH)
    logic_cost_collector:MarkEventStart(logic_cost_collector.EVENT_KEYS.SPLASH)
    local time_step_macros = require("client.slua.logic.performance.time_step_macros")
    local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
    logic_time_cost_report:ReportTimeCostBeForeEngineInit()
    logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.SplashEndToSplashAniStart)
    logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.SplashAniStartToSplashAniEnd)
  end)
  log_shipping_client(bWriteLog and "rain profile SplashScreen")
end
function SplashScreenUI:OnClose()
  log(bWriteLog and "SplashScreenUI:OnClose")
  local time_step_macros = require("client.slua.logic.performance.time_step_macros")
  local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
  logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.SplashAniStartToSplashAniEnd)
  logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.SplashEndToUpdatePatchStart)
end
function SplashScreenUI.AssetUseHistoryInfo()
  if Client.IsReleaseVersion(NetInterface) then
    log(bWriteLog and "SplashScreenUI.AssetUseHistoryInfo return for IsReleaseVersion")
    return
  end
  local UIUtil = require("client.common.ui_util")
  local StringUtil = require("common.string_util")
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local PakCollectResEnableOnlyDev = HDmpveRemote.HDmpveRemoteConfigGetInt("PakCollectResEnableOnlyDev", 1)
  log(bWriteLog and "SplashScreenUI.AssetUseHistoryInfo PakCollectResEnableOnlyDev: " .. PakCollectResEnableOnlyDev)
  if not Client.IsDevelopment() and 0 < PakCollectResEnableOnlyDev then
    log(bWriteLog and "SplashScreenUI.AssetUseHistoryInfo return for not IsDevelopment")
    return
  end
  local PakCollectResEnable = HDmpveRemote.HDmpveRemoteConfigGetInt("PakCollectResEnable", 0)
  log(bWriteLog and "SplashScreenUI.AssetUseHistoryInfo s.EnableCollectRes: " .. PakCollectResEnable)
  gameInstance:ExecuteCMD("s.EnableCollectRes", PakCollectResEnable)
  if PakCollectResEnable < 100 then
    log(bWriteLog and "SplashScreenUI.AssetUseHistoryInfo return for PakCollectResEnable < 100")
    return
  end
  log(bWriteLog and "AssetUseHistoryInfo IsDevelopment upload OpenReadList beg")
  local str_1 = Client.LoadFileToString("ResUseColect/OpenReadList.log")
  local Lines_1 = StringUtil.Split(str_1, "\n")
  if next(Lines_1) then
    local instanceID = FuncUtil.GetHDmpveInstanceId()
    local cnt = 1
    local cntTotal = #Lines_1
    local UploadCnt = 1
    SplashScreenUI.timer_ticker = require("common.time_ticker")
    SplashScreenUI.timerReport = SplashScreenUI.timer_ticker.AddTimerLoop(0, function()
      if cnt > cntTotal then
        log(bWriteLog and "timerReport stop for cnt > cntTotal " .. UploadCnt .. "/" .. cnt .. "/" .. cntTotal .. " | instanceID: " .. tostring(instanceID))
        SplashScreenUI.timer_ticker.RemoveTimer(SplashScreenUI.timerReport)
        SplashScreenUI.timerReport = nil
        SplashScreenUI.timer_ticker = nil
      else
        TmpMax = math.min(cntTotal, cnt + 5)
        log(bWriteLog and "timerReport once cnt: " .. TmpMax .. "/" .. cnt .. "/" .. cntTotal .. " | instanceID: " .. tostring(instanceID))
        for Idx = cnt, TmpMax do
          Line = Lines_1[Idx]
          if string.find(Line, "../../../") ~= nil then
            local SyncInfo = StringUtil.Split(Line, ",")
            local WorldNameInfo = ""
            if 3 <= #SyncInfo then
              WorldNameInfo = SyncInfo[3]
            end
            if 2 <= #SyncInfo then
              local itemParam = {
                tostring(SyncInfo[1]),
                tostring(SyncInfo[2]),
                tostring(instanceID),
                tostring(WorldNameInfo),
                tostring(UploadCnt)
              }
              log(bWriteLog and ">>>>timerReport upload Idx: " .. UploadCnt .. "/" .. cnt .. "/" .. cntTotal .. ": " .. Line)
              Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "OpenReadAssetListInfo", itemParam)
              UploadCnt = UploadCnt + 1
            end
          end
          cnt = cnt + 1
        end
      end
    end, TIMER_INFINITE, 0.1)
  end
  log(bWriteLog and "AssetUseHistoryInfo IsDevelopment upload OpenReadList end")
end
function SplashScreenUI:OnAnimationFinished()
  local updater
  if slua_GameFrontendHUD then
    updater = slua_GameFrontendHUD:GetUpdater()
  else
    log_shipping_client("SplashScreenUI:OnAnimationFinished, slua_GameFrontendHUD = nil")
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local gotoNextStateFunc = function()
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    local bSkipUpdating = version_up_module.NeedSkipAppUpdatingInBlueHole and version_up_module:NeedSkipAppUpdatingInBlueHole()
    log(bWriteLog and "SplashScreenUI:OnAnimationFinished NeedSkipAppUpdatingInBlueHole return " .. tostring(bSkipUpdating))
    if not bSkipUpdating and updater then
      if updater:IsUpdating() then
        login_module:Transition(login_module.ELoginFSMEvent.Event_SSTVU)
      else
        login_module:Transition(login_module.ELoginFSMEvent.Event_SSTL)
      end
    else
      login_module:Transition(login_module.ELoginFSMEvent.Event_SSTL)
    end
  end
  local logic_http_dns = require("client.slua.logic.httpdns.logic_http_dns")
  logic_http_dns:Init()
  if gem_report_utils.IsPublishVersion() ~= true then
    local forceQuit = HDmpveRemote.HDmpveRemoteConfigGetBool("ForceQuit", false)
    if forceQuit then
      GameStatus.QuitGame()
    end
  end
  local PublishAreaMgr = import("PublishAreaMgr")
  local areaString = PublishAreaMgr.GetPublishAreas()
  log(bWriteLog and "[Russia] after splash area string: " .. tostring(areaString))
  if areaString and areaString ~= "" and areaString ~= "DEFAULT" then
    UIManager.ShowUI(UIManager.UI_Config.SelectArea_UIBP, areaString, gotoNextStateFunc)
  else
    gotoNextStateFunc()
  end
end
function SplashScreenUI:RefreshUI()
  local cr = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  log_shipping_client("SplashScreenUI:RefreshUI GetPublishRegion = " .. cr)
  local path = "/Game/Mod/Lobby/Base/Login/Update/SplashScreen_GL.SplashScreen_GL"
  if cr == PublishRegionMacros.JAPAN then
    path = "/Game/Mod/Lobby/Base/Login/Update/SplashScreen_JP.SplashScreen_JP"
  elseif cr == PublishRegionMacros.KOREA then
    path = "/Game/Mod/Lobby/Base/Login/Update/SplashScreen_KR.SplashScreen_KR"
  elseif cr == PublishRegionMacros.BLUEHOLE then
    path = "/Game/Mod/Lobby/Base/Login/Update/SplashScreen_BH.SplashScreen_BH"
  end
  local SplashAniFinishCallback = function()
    self:OnAnimationFinished()
  end
  local childUI = self:CreateChildWindowWithBpPath("CanvasPanel_0", UIManager.UI_Config.splash_screen_ani_ui, path, SplashAniFinishCallback)
  if childUI then
    log_shipping_client(bWriteLog and "SplashScreenUI:RefreshUI, load UI = " .. tostring(path) .. " success. Waiting for animation finished")
  else
    log_shipping_client(bWriteLog and "SplashScreenUI:RefreshUI, load UI = " .. tostring(path) .. " failed.")
    self:OnAnimationFinished()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSplashScreenUI = class(ui_base, nil, SplashScreenUI)
return CSplashScreenUI