local LoadingSystem = require("client.slua.logic.loading.logic_loading")
local TimeUtil = require("client.common.time_util")
local util = require("client.slua_ui_framework.util")
local BCanTick = false
local _StartTime = 0
local NPercent = 0
local BLoaded = false
local CHANGE_TIME_INTERVAL = 10
local UI_Loading = {}
function UI_Loading:ctor()
  self._bInitBgShow = false
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  local nDeviceLevel = gameInstance:GetDeviceLevel()
  self._  self._nChangeTimer = nil
  self._tDownloadParams = nil
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  self._bIsSpecialRegion = strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea()
end
function UI_Loading:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_LoadingGm, self.OnClickGm, self)
end
function UI_Loading:OnPostInitialize()
  log(bWriteLog and "[loading]UI_Loading:OnPostInitialize")
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  NPercent = 0
  self:UpdatePercent(math.random(10, 26) / 100)
  FuncUtil.AddCrashContextMainFlow("50")
  log(bWriteLog and "   LoadingUI.RegistControlEvent EnableIosStuckWork false")
  _StartTime = slua.getMicroseconds()
  log_shipping_client("[LoadingUI]---show LoadingUI---")
  Client.EnableIosStuckWork(GameFrontendHUD, false)
  self:InitLoading()
  if LoadingSystem.GetUseGm() then
    log(bWriteLog and "  : loading Gm ing")
    self:AddTimerOnce(2, function()
      LoadingSystem.RefreshLoadPercent(1)
    end)
  end
  local nCount = 0
  local dotNumList = {
    [0] = ".",
    [1] = "..",
    [2] = "..."
  }
  local dotNumListAR = {
    [0] = ".  ",
    [1] = ".. ",
    [2] = "..."
  }
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local curLanguage = Client.GetCurrentLanguage()
  self:AddTimerLoop(0.1, function()
    if curLanguage == LanguageMacros.AR or curLanguage == LanguageMacros.UR then
      self.UIRoot.TextBlock_Check:SetText(LocUtil.GetLocalizeResStr(32980) .. dotNumListAR[nCount % 3])
    else
      self.UIRoot.TextBlock_Dot:SetText(dotNumList[nCount % 3])
    end
    nCount = nCount + 1
  end, TIMER_INFINITE, 0.5)
  local time_ticker = require("common.time_ticker")
  self:AddTimerLoop(0, function()
    self:TickInternal()
    self:Check65PercentBlock()
  end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  self:RefreshTimeShow()
  self:AddTimerLoop(0, function()
    self:RefreshTimeShow()
  end, TIMER_INFINITE, CHANGE_TIME_INTERVAL)
end
function UI_Loading:OnClickGm()
  print(bWriteLog and "UI_Loading:OnClickGm")
  self:PlayAudio(sound_config.click_v1)
  if Client.IsShipping() then
    print(bWriteLog and "UI_Loading:OnClickGm Client.IsShipping()")
    return
  end
  local loading_macro = require("client.slua.logic.loading.loading_macro")
  local CurStagePercent = loading_macro.EnterBattleStagePercentMap
  local curState = ""
  for k, v in pairs(loading_macro.EnterBattleStagePercentMap or {}) do
    if v > NPercent then
      curState = k
      break
    end
  end
  if self.UIRoot.TextBlock_GmState then
    self.UIRoot.TextBlock_GmState:SetText(curState)
  end
end
function UI_Loading:UseOther(bIsUseDefault)
  if bIsUseDefault then
    LoadingSystem.SetLoadingTipStr()
    self:SetTexture(self.UIRoot.BackImage, LoadingSystem.GetDefaultPath(), {sync = true})
  else
    if bWriteLog then
      print(" >>>>> UI_Loading:UseOther Currently using an undedownloaded image, restoring the previous one")
    end
    LoadingSystem.GetLoadingShowData(false)
    self:RefreshBgAndTipShow(true)
  end
end
function UI_Loading:SendTLog()
  local nId = LoadingSystem.GetSelectedLoadingId()
  local TableUtil = require("common.table_util")
  local uid = TableUtil.GetTableValue(DataMgr, "roleData", "uid")
  if nId and uid and tonumber(uid) and (tonumber(uid) % 100 == 6 or Client.IsDevelopment()) then
    if bWriteLog then
      print(" >>>>> Loading tLog >>>>> ", uid, nId, TimeUtil.FormatTime_YMDHMS(TimeUtil.GetServerTimeInSec()))
    end
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_report_loading_pic_req(nId)
  end
end
function UI_Loading:InitLoading()
  BCanTick = true
  BLoaded = false
  local toLobby = LoadingSystem.GetToLobby() or false
  local UIUtil = require("client.common.ui_util")
  self.UIRoot.HorizontalBox_2:SetWidgetVisibility(UIUtil.BoolToVisible(not toLobby))
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local curLanguage = Client.GetCurrentLanguage()
  if curLanguage == LanguageMacros.AR or curLanguage == LanguageMacros.UR then
    self.UIRoot.TextBlock_Dot:SetWidgetVisibility(UIUtil.BoolToVisible(false))
    self.UIRoot.TextBlock_Check:SetText(LocUtil.GetLocalizeResStr(32980) .. "   ")
  else
    self.UIRoot.TextBlock_Dot:SetWidgetVisibility(UIUtil.BoolToVisible(not toLobby))
    self.UIRoot.TextBlock_Check:SetText(LocUtil.GetLocalizeResStr(32980))
  end
  self:RefreshBgAndTipShow()
  self:SetLogo()
  self.UIRoot.Image_1:SetWidgetVisibility(UIUtil.BoolToVisible(UIUtil.CheckShow18Logo()))
  UIUtil.GetGameFrontendHUD():NotifyLoadingUIOperation(0)
  if not self.UIRoot.Button_LoadingGm then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Button_LoadingGm, not Client.IsShipping())
end
function UI_Loading:Refresh(sub_mode, main_mode)
  log(bWriteLog and string.format("UI_Loading:Refresh, sub_mode:%s", sub_mode))
  log(bWriteLog and string.format("UI_Loading:Refresh, main_mode:%s", main_mode))
  self:RefreshLoadingGuide(main_mode, sub_mode)
end
function UI_Loading:RefreshLoadingGuide(main_mode, sub_mode)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
  local view_id = logic_mode_utils.GetViewIDByModeID(logic_mode_mgr.nInGameModeID)
  log(bWriteLog and string.format("UI_Loading:RefreshLoadingGuide nInGameModeID[%s] viewID[%s]", tostring(logic_mode_mgr.nInGameModeID), tostring(view_id)))
  local loading_attach_ui_config = require("client.slua.logic.loading.loading_attach_ui_config")
  local guideConfig = LoadingSystem.GetGuideConfig()
  for _, config in ipairs(guideConfig) do
    if config.showFunc(main_mode, sub_mode) and not self.guideUIBP then
      self.guideUIBP = self:CreateChildWindow("CanvasPanel_Attach", config.uiConfig)
      if config.guideType == loading_attach_ui_config.EAttachUIType.UGC_Edit then
        self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
        break
      end
      self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      break
    end
  end
end
function UI_Loading:GetDownloadParams()
  if not self._tDownloadParams then
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local DiskCacheTypeEnum = image_download_mgr:GetDiskCacheTypeEnum()
    local tParams = {
      enableCDNCompress = true,
      diskCacheType = DiskCacheTypeEnum.WeeklyUpdate,
      isSyncDiskLoad = true,
      bDownloadOnModeSwitch = true,
      bIsIgnoreCheck = true,
      onDownloadSuccess = function(_, sPicUrl)
        LoadingSystem.RemoveDownloadPicCache(nil, sPicUrl)
      end,
      onDownloadFail = function(sPicUrl)
        LoadingSystem.RemoveDownloadPicCache(nil, sPicUrl)
        if slua.isValid(self.UIRoot) then
          self:TriggerChangeNextShowTimer()
        end
      end
    }
    self._tDownloadParams = tParams
  end
  return self._tDownloadParams
end
function UI_Loading:RefreshBgAndTipShow()
  local path = LoadingSystem.GetBgPath()
  local Image_Bg = self.UIRoot.BackImage
  if util.IsOnlineImageUrl(path) then
    local tParams = self:GetDownloadParams()
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local nDownloadIndex = image_download_mgr:DownloadImageByHttpWrapper(path, tParams.onDownloadSuccess, tParams.onDownloadFail, tParams)
    if nDownloadIndex and 0 < nDownloadIndex then
      LoadingSystem.AddDownloadPicCache(path)
      if not self._bInitBgShow then
        local sDefaultPath = LoadingSystem.GetDefaultPath()
        self:SetTexture(Image_Bg, sDefaultPath)
      end
      self:TriggerChangeNextShowTimer()
    else
      self:SetTexture(Image_Bg, path, {
        defaultIcon = LoadingSystem.GetDefaultPath(),
        bIsInCombatState = false
      })
      self:SwitchRoundFinish()
    end
  else
    local pak_util = require("client.common.pak_util")
    local bIsExistImage = pak_util.IsFileExist(path)
    log(bWriteLog and "UI_Loading:RefreshBgAndTipShow >>> Check File Is Exist, path = " .. path .. " >>> pak_util.IsFileExist(path) = " .. tostring(bIsExistImage))
    if bIsExistImage then
      self:SetTexture(Image_Bg, path, {sync = true}, {
        defaultIcon = LoadingSystem.GetDefaultPath(),
        bIsInCombatState = false
      })
      self:SwitchRoundFinish()
    else
      log(bWriteLog and "UI_Loading:RefreshBgAndTipShow TriggerLoadingPicPakDownload >>> " .. path)
      LoadingSystem.AddDownloadPicCache(path)
      LoadingSystem.TriggerLoadingPicPakDownload(path)
      self:SetTexture(Image_Bg, LoadingSystem.GetDefaultPath(), {sync = true})
      self:TriggerChangeNextShowTimer()
    end
  end
  self._bInitBgShow = true
end
function UI_Loading:SwitchRoundFinish()
  self:SendTLog()
  LoadingSystem.SaveMapGroupShowIndex()
  local sTip = LoadingSystem.GetLoadingTipInfo()
  self.UIRoot.RichText_LoadingTip:SetText(sTip)
  self:TriggerChangeNextShowTimer()
end
function UI_Loading:RefreshTimeShow()
  local bIsSpecialRegion = self._bIsSpecialRegion
  local sGameTimeStr = TimeUtil.FormatTime_YMDHM(TimeUtil.GetServerTimeInSec(), bIsSpecialRegion, not bIsSpecialRegion)
  local node_root = self.UIRoot
  self:SetWidgetVisible(node_root.TextBlock_GameTime, true)
  self.UIRoot.TextBlock_GameTime:SetText(sGameTimeStr)
end
function UI_Loading:SetLogo()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local index = 0
  if region == PublishRegionMacros.TW then
    index = 1
  elseif region == PublishRegionMacros.BLUEHOLE then
    index = 2
  end
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(index)
end
function UI_Loading:TickInternal()
  LoadingSystem.Tick()
end
function UI_Loading:TriggerChangeNextShowTimer()
  local nDeviceLevel = self._nDeviceLevel or 1
  if 1 <= nDeviceLevel then
    if self._nChangeTimer then
      self:RemoveTimer(self._nChangeTimer)
    end
    self._nChangeTimer = self:AddTimerOnce(CHANGE_TIME_INTERVAL, function()
      LoadingSystem.GetLoadingShowData(true)
      self:RefreshBgAndTipShow()
    end)
  end
end
function UI_Loading:UpdatePercent(percent)
  if BLoaded then
    return
  end
  log(bWriteLog and "UI_Loading:UpdatePercent NPercent:" .. tostring(NPercent) .. " percent:" .. tostring(percent))
  if percent > NPercent then
    NPercent = percent
    self.UIRoot.ProgressBar_Loading:SetPercent(NPercent)
    self:RefreshPercentText()
    if percent == 0.65 then
      self.check65PercentBlockTime = TimeUtil.GetServerTimeInSec()
    end
    EventSystem:postEvent(EVENTTYPE_WOW_EDITOR, EVENTID_WOW_EDITOR_LOADING, percent * 100)
  end
  if 1 <= NPercent then
    BLoaded = true
    self.UIRoot.ProgressBar_Loading:SetPercent(NPercent)
    self:RefreshPercentText()
    local bNeedCloseUI = self:GetIsNeedCloseUI()
    if bNeedCloseUI then
      self:AddTimerOnce(0.1, function()
        log(bWriteLog and "UI_Loading:UpdatePercent CloseSelf")
        self:CloseSelf()
      end)
    else
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      local bHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
      log(bWriteLog and "UI_Loading:UpdatePercent bHomeMode = " .. tostring(bHomeMode))
      if bHomeMode then
        self:SetWaitTimeoutTimer()
      elseif GameStatus.IsCollectionHallMode() then
        self:SetCollectionHallWaitTimeoutTimer()
      else
        local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
        logic_main_city_enter:SetMainCityLoadingTimeOutTimer()
      end
    end
  end
end
function UI_Loading:RefreshPercentText()
  local percent_100 = math.floor(NPercent * 100 + 0.5)
  if 100 < percent_100 then
    percent_  end
  log(bWriteLog and "UI_Loading:RefreshPercentText percent_100:" .. tostring(percent_100))
  self.UIRoot.Text_Progress:SetText("" .. percent_100 .. "%")
end
function UI_Loading:GetIsNeedCloseUI()
  log(bWriteLog and "UI_Loading:GetIsNeedCloseUI")
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
  log(bWriteLog and "UI_Loading:GetIsNeedCloseUI bHomeMode = " .. tostring(bHomeMode))
  if bHomeMode then
    local logic_home_loading = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_loading)
    local bHomeLoadingTimeOut = logic_home_loading:GetHomeLoadingTimeOut()
    if bHomeLoadingTimeOut then
      logic_home_loading:SetHomeLoadingTimeOut(false)
      return true
    end
    local bHomeSceneLoadedFinish = logic_home_loading:GetHomeSceneLoadedFinish()
    log(bWriteLog and "UI_Loading:GetIsNeedCloseUI bHomeSceneLoadedFinish = " .. tostring(bHomeSceneLoadedFinish))
    return bHomeSceneLoadedFinish
  elseif GameStatus.IsCollectionHallMode() then
    local LogicCollectionHallLoading = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicCollectionHallLoading)
    local bHallLoadingTimeOut = LogicCollectionHallLoading:GetHallLoadingTimeOut()
    if bHallLoadingTimeOut then
      LogicCollectionHallLoading:SetHallLoadingTimeOut(false)
      return true
    end
    local bHallSceneLoadedFinish = LogicCollectionHallLoading:GetHallSceneLoadedFinish()
    log(bWriteLog and "UI_Loading:GetIsNeedCloseUI bHallSceneLoadedFinish = " .. tostring(bHallSceneLoadedFinish))
    return bHallSceneLoadedFinish
  end
  local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
  local IsNeedMainCityLoadingClose = logic_main_city_enter:CheckIsNeedLoadingClose()
  log(bWriteLog and "UI_Loading:GetIsNeedCloseUI IsNeedMainCityLoadingClose = " .. tostring(IsNeedMainCityLoadingClose))
  return IsNeedMainCityLoadingClose
end
function UI_Loading:SetWaitTimeoutTimer()
  log(bWriteLog and "UI_Loading:SetWaitTimeoutTimer")
  local logic_home_loading = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_loading)
  logic_home_loading:SetWaitingSceneLoaingFinish(true)
  local tickCount = 1
  self.timeoutTimer = self:AddTimerLoop(8, function()
    tickCount = tickCount + 1
    local bClose = false
    if 30 < tickCount then
      bClose = true
    end
    local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
    local homeAreaInfo = PlanPH_HomeArea_Manager.FindHomeArea(PlanPH_HomeArea_Manager.curHomeIndex)
    if homeAreaInfo then
      local sceneObjectSystem = homeAreaInfo.sceneObjectSystem
      if sceneObjectSystem.loadStatus.bLoadStructFinish then
        bClose = true
      end
    end
    if bClose then
      self:RemoveTimer(self.timeoutTimer)
      self.timeoutTimer = nil
      self:CloseSelf()
    end
  end, 60, 1)
end
function UI_Loading:SetCollectionHallWaitTimeoutTimer()
  log(bWriteLog and "UI_Loading:SetCollectionHallWaitTimeoutTimer")
  local LogicCollectionHallLoading = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicCollectionHallLoading)
  LogicCollectionHallLoading:SetWaitingSceneLoadingFinish(true)
  local tickCount = 1
  self.timeoutTimer = self:AddTimerLoop(1, function()
    tickCount = tickCount + 1
    local bClose = false
    if 30 < tickCount then
      bClose = true
    end
    if not bClose then
      local LogicCollectionHallLoading = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicCollectionHallLoading)
      local bHallSceneLoadedFinish = LogicCollectionHallLoading:GetHallSceneLoadedFinish()
      if bHallSceneLoadedFinish then
        bClose = true
      end
    end
    if bClose then
      self:RemoveTimer(self.timeoutTimer)
      self.timeoutTimer = nil
      self:CloseSelf()
    end
  end, 60, 1)
end
function UI_Loading:OnClose()
  NPercent = 0
  BLoaded = false
  log_shipping_client(bWriteLog and string.format("TimeTracer [LoadingUI]---hide LoadingUI--- time:[%.3fms]", (slua.getMicroseconds() - _StartTime) / 1000))
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH)
  LoadingSystem.LoadingFinishedRelease()
  LoadingSystem.SetNBreakMinValue(0.55)
  local UIUtil = require("client.common.ui_util")
  UIUtil.GetGameFrontendHUD():NotifyLoadingUIOperation(2)
  Client.EnableIosStuckWork(GameFrontendHUD, true)
  local time_step_macros = require("client.slua.logic.performance.time_step_macros")
  local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
  logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.SyncBaseInfoEndToLoadingUIClose)
end
function UI_Loading:Check65PercentBlock()
  if NPercent ~= 0.65 then
    return
  end
  if not self.check65PercentBlockTime then
    return
  end
  local currentTime = TimeUtil.GetServerTimeInSec()
  if currentTime - self.check65PercentBlockTime > 5 and currentTime - self.check65PercentBlockTime < 10 then
    ShowNotice(46880169)
    self.check65PercentBlockTime = currentTime - 2
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CNotice_UIBP = class(ui_base, nil, UI_Loading)
return CNotice_UIBP