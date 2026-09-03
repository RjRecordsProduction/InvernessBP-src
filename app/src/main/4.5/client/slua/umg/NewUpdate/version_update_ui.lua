local VersionUpdateUI = {}
local ESlateVisibility = UEnums.ESlateVisibility
local SelfHitTestInvisible = ESlateVisibility.SelfHitTestInvisible
local Hidden = ESlateVisibility.Hidden
local Collapsed = ESlateVisibility.Collapsed
local extraData = {
  showUIKey = "com_msg_box_5s"
}
function VersionUpdateUI:ctor(selfUI, gray, callback)
  log(bWriteLog and "VersionUpdateUI:ctor, selfUI = " .. tostring(selfUI) .. ", gray = " .. tostring(gray) .. ", callback = " .. tostring(callback))
  self.bShowing = false
  self.gray = gray or false
  self.callbackAfterGrayUpdate = callback
  self.versionInfo = {}
  self.retriedUpdateTimes = 0
  self.maxRetryUpdateTimes = 1
  self.haveRetried71X = false
  self.reportedErrorList = {}
  self.cancelUpdateTimes = 0
  self.preStage = "updating"
  self.currentStage = "updating"
  self.calculateSpeedState = 0
  self.haveDownloadedSize = 0
  self.lastCalculateTime = 0
  self.downloadSpeed = 0
  self.realtimeDownloadSpeedZeroCount = 0
  self.calculateAverageSpeedState = 0
  self.averageDownloadSize = 0
  self.lastCalculateAverageTime = 0
  self.averageDownloadSpeed = 0
  self.speedTimer = nil
  self.CDNImageTimer = nil
  self.CDNImage = {}
  self.CDNImageIndex = 1
  self.CDNNoticeType = "62"
  self.checkUpdateWaitTime = 0
  self.checkUpdateTimer = nil
  self.ErrCodeTimeOut = 888888888
  self.retriedUpdateAfterDeleteFileTimes = 0
  self.maxRetryUpdateAfterDeleteFileTimes = 1
  self.showSecondStageReward = false
  self.useNewComp = false
  self.TextBlock_State = nil
  self.TextBlock_DownloadSpeed = nil
  self.TextBlock_SizeInfo = nil
  self.TextBlock_RemainTime = nil
  self.secondDownloadCurSize = 0
  self.secondDownloadTotalSize = 0
  self.secondDownloadCurStage = 0
  self.isResourceUpdate = false
end
function VersionUpdateUI:OnPostInitialize()
  log(bWriteLog and "VersionUpdateUI:OnPostInitialize")
  VersionUpdateUI.__super.OnPostInitialize(self)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not self.gray then
    login_module:OnShowUpdate()
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(self.UIRoot.GridPanel_IPX)
  self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(Hidden)
  self.UIRoot.Image_LoginBG:SetWidgetVisibility(Hidden)
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_UPDATE_BACKGROUND_IMAGE, self.gray ~= true)
  if self.gray then
    self.UIRoot.GridPanel_UpdateUI:SetWidgetVisibility(Hidden)
  else
    self.UIRoot.GridPanel_UpdateUI:SetWidgetVisibility(SelfHitTestInvisible)
  end
  self:ShowBulletinEntry(false)
end
function VersionUpdateUI:OnShow()
  log(bWriteLog and "VersionUpdateUI:OnShow")
  VersionUpdateUI.__super.OnShow(self)
  self.bShowing = true
  self:InitUIComponent()
  self:RefreshUI()
  log_shipping_client(bWriteLog and "rain profile VersionUpdate")
end
function VersionUpdateUI:OnInitialize()
  log(bWriteLog and "VersionUpdateUI:OnInitialize")
  VersionUpdateUI.__super.OnInitialize(self)
end
function VersionUpdateUI:RegistEvents()
  log(bWriteLog and "VersionUpdateUI:RegistEvents")
  VersionUpdateUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SystemNotify, self.OnClickSystemNotify, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Bulletin, self.OnClickButton_Bulletin, self)
end
function VersionUpdateUI:OnClickSystemNotify()
  self:PlayAudio(sound_config.click)
  local IntlHelper = import("IntlHelper")
  IntlHelper.DirectToNotificationSetup()
end
function VersionUpdateUI:InitUIComponent(useNewComp, showReward)
  printf("VersionUpdateUI:InitUIComponent. useNewComp=%s, showReward=%s", tostring(useNewComp), tostring(showReward))
  if not useNewComp then
    self:ClosePlayer()
  end
  local compCfgs = {
    TextBlock_State = {
      "TextBlock_0",
      "TextBlock_SDLoading"
    },
    TextBlock_DownloadSpeed = {
      "TextBlock_5",
      "TextBlock_SDDLSpeed"
    },
    TextBlock_SizeInfo = {
      "TextBlock_Current",
      "TextBlock_SDProportion"
    },
    TextBlock_RemainTime = {
      "TextBlock_10",
      "TextBlock_7"
    }
  }
  self.lastCalculateTime = 0
  self.showSecondStageReward = showReward
  self.  self:SetWidgetVisible(self.UIRoot.CanvasPanel_SDDL, useNewComp)
  local hasRewardCfg = false
  local compIndex = 1
  if self.useNewComp then
    compIndex = 2
  end
  if showReward then
    local rewardCfgs = CDataTable.GetTable("SecondStageDownloadReward")
    local version_util = require("client.common.version_util")
    local version = version_util.GetCurVersionNumber()
    log(bWriteLog and "VersionUpdateUI:InitUIComponent. version = " .. tostring(version))
    for k, cfg in pairs(rewardCfgs) do
      if cfg.Version == version then
        hasRewardCfg = true
        local itemName1 = ""
        local itemName2 = ""
        local Item1 = CDataTable.GetTableData("Item", cfg.ItemID1)
        if Item1 then
          itemName1 = Item1.ItemName
        end
        local Item2 = CDataTable.GetTableData("Item", cfg.ItemID2)
        if Item2 then
          itemName2 = Item2.ItemName
        end
        self.rewardTextTips = LocUtil.LocalizeResFormat(8800603, itemName1, cfg.ItemCount1, itemName2, cfg.ItemCount2)
        for i = 1, 2 do
          local indexStr = tostring(i)
          local itemID = cfg["ItemID" .. indexStr]
          log(bWriteLog and "VersionUpdateUI:InitUIComponent. itemID = " .. tostring(itemID))
          local itemVisible = itemID and 0 < itemID
          self:SetWidgetVisible(self.UIRoot["CanvasPanel_SSRewardItem" .. indexStr], itemVisible)
          local TextBlock_Count = self.UIRoot["RewardItemCount" .. indexStr]
          local itemCount = cfg["ItemCount" .. indexStr]
          if TextBlock_Count and itemCount then
            TextBlock_Count:SetText(tostring(itemCount))
          end
        end
      end
    end
  end
  for k, compArr in pairs(compCfgs) do
    for i, compName in ipairs(compArr) do
      local comp = self.UIRoot[compName]
      if comp then
        local visible = i == compIndex
        self:SetWidgetVisible(comp, visible)
        comp:SetText("")
        if visible then
          self[k] = comp
          printf("VersionUpdateUI:InitUIComponent. k=%s, compName=%s", tostring(k), compName)
        end
      end
    end
  end
  self:SetWidgetVisible(self.UIRoot.TextBlock_1, useNewComp)
  self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(13157))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_ItemGroup, hasRewardCfg)
  self.UIRoot.WidgetSwitcher_Up:SetActiveWidgetIndex(compIndex - 1)
  self.UIRoot.WidgetSwitcher_Down:SetActiveWidgetIndex(compIndex - 1)
  self:AddTextChangeTimer()
  if useNewComp and not self.speedTimer then
    self.speedTimer = self:AddTimerLoop(0, function()
      self:OnRefreshDownloadSpeed()
    end, TIMER_INFINITE, 0.5)
  end
  self.UIRoot.TextBlock_Bulletin:SetText(LocUtil.GetLocalizeResStr(655665))
end
function VersionUpdateUI:AddTextChangeTimer()
  local textArray = {
    LocUtil.GetLocalizeResStr(8800602)
  }
  if self.rewardTextTips then
    table.insert(textArray, self.rewardTextTips)
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    table.insert(textArray, LocUtil.GetLocalizeResStr(468890121))
  end
  log_tree("VersionUpdateUI:AddTextChangeTimer. textArray = ", tostring(textArray))
  local index = 1
  self:AddTimerLoop(3, function()
    local text = textArray[index]
    self.UIRoot.TextBlock_SDDLTips:SetText(text)
    index = index + 1
    if not textArray[index] then
      index = 1
    end
  end, TIMER_INFINITE, 5)
end
function VersionUpdateUI:RefreshUI()
  if self.bShowing then
    log(bWriteLog and "VersionUpdateUI:RefreshUI")
    self.UIRoot.UpdateTips:SetText(LocUtil.GetLocalizeResStr(210018))
    self.TextBlock_DownloadSpeed:SetWidgetVisibility(Collapsed)
    self.TextBlock_RemainTime:SetWidgetVisibility(Hidden)
    self.UIRoot.VerticalBox_UpdateInfo:SetWidgetVisibility(SelfHitTestInvisible)
    self.UIRoot.TextBlock_SDDLTips:SetText(LocUtil.GetLocalizeResStr(8800602))
    local updater = self:GetUpdater()
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    local bSkipUpdating = version_up_module.NeedSkipAppUpdatingInBlueHole and version_up_module:NeedSkipAppUpdatingInBlueHole()
    log(bWriteLog and "VersionUpdateUI:RefreshUI bSkipUpdating:" .. tostring(bSkipUpdating))
    if not bSkipUpdating and updater and updater:IsUpdating() then
      logic_connection_waiting:Show(0)
      local DolphinConfig = require("client.slua.umg.NewUpdate.dolphin_updater_config")
      DolphinConfig.ExecuteDolphinInitParameters()
      if self.gray == true then
      else
        updater:StartAppUpdate()
      end
      if slua_GameFrontendHUD then
        slua_GameFrontendHUD.bIsWaitingUpdateStateData = false
      end
      local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
      pool:GetAsy(UIManager.UI_Config.Login_UIBP.path, function(obj)
        pool:Release(obj)
      end)
    else
      local LobbyAssetPreloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LobbyAssetPreloader)
      LobbyAssetPreloader:PreloadLobbyUIAsset()
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      login_module:Transition(login_module.ELoginFSMEvent.Event_VUTL)
    end
  end
end
function VersionUpdateUI:IsCEVersionOrThirdParty()
  local result = false
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if platformName ~= DevicePlatformNameMacros.IOS then
    local bCEVersion = PublishRegionMacros.IsCEVersion()
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local bThirdParty = Client.GetAOSSHOP() == AOSSHOPMacros.ThirdPartyPayment
    local BusinessHelper = import("BusinessHelper")
    local fromStore = BusinessHelper.IsAppFromStore()
    local IsBluholeWebSiteVer = false
    local SystemPermissionHelper = import("SystemPermissionHelper")
    local instance = SystemPermissionHelper.GetInstance()
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE and instance:AndroidHasDefinePermission("android.permission.REQUEST_INSTALL_PACKAGES") then
      IsBluholeWebSiteVer = true
    end
    result = bCEVersion and not fromStore or bThirdParty or IsBluholeWebSiteVer
  end
  log(bWriteLog and "VersionUpdateUI:IsCEVersionOrThirdParty, result = " .. tostring(result))
  return result
end
function VersionUpdateUI:RecursivePopup()
  log(bWriteLog and "VersionUpdateUI:RecursivePopup")
  local title = LocUtil.GetLocalizeResStr(201001)
  local tips3 = LocUtil.GetLocalizeResStr(201006)
  local tips4 = LocUtil.GetLocalizeResStr(201030)
  local tips5 = LocUtil.GetLocalizeResStr(4598)
  local tips6 = LocUtil.GetLocalizeResStr(75062)
  local tips7 = LocUtil.GetLocalizeResStr(10336)
  local tips8 = LocUtil.GetLocalizeResStr(201005)
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local content
  if platformName == DevicePlatformNameMacros.IOS then
    content = tips3
  elseif platformName == DevicePlatformNameMacros.Android then
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    if Client.GetAOSSHOP() == AOSSHOPMacros.Samsung then
      content = tips5
    elseif Client.GetAOSSHOP() == AOSSHOPMacros.Amazon then
      content = tips6
    elseif Client.GetAOSSHOP() == AOSSHOPMacros.HMS then
      content = tips7
    else
      content = tips4
    end
  end
  if FuncUtil.IsSpecialBanClient() then
    log(bWriteLog and string.format("VersionUpdateUI:RecursivePopup, FuncUtil.IsSpecialBanClient()"))
    FuncUtil.GotoNotGPUpgrade()
    content = tips8
  else
    local AppUpdate = require("client.slua.umg.NewUpdate.app_update")
    AppUpdate:UpdateApp()
  end
  local StatManager = import("StatManager")
  self:AddTimerOnce(0.01, function()
    local okCallback = function()
      self:RecursivePopup()
      StatManager.GetInstance():ReportEventWithParam(111, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    end
    local cancelCallback = function()
      StatManager.GetInstance():ReportEventWithParam(112, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, content, okCallback, cancelCallback, nil, nil, extraData)
    StatManager.GetInstance():ReportEventWithParam(110, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
  end)
end
function VersionUpdateUI:OnDolphinVersionInfo(versionInfo)
  self.versionInfo = versionInfo or {}
  self.isResourceUpdate = false
  if versionInfo and versionInfo.needDownloadSize then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    self.versionInfo.needDownloadSize = tonumber(versionInfo.needDownloadSize) / PufferConst.MB
    if self.versionInfo.isNeedUpdating == "1" then
      if self.versionInfo.isAppUpdating == "1" then
        self:OnApplicationVersionUpdate()
      elseif self.versionInfo.isAppUpdating == "2" then
        self:OnResourceVersionUpdate()
      else
        log(bWriteLog and "VersionUpdateUI:OnApplicationVersionUpdate, isAppUpdating = " .. tostring(self.versionInfo.isAppUpdating) .. ", incredable!")
      end
    end
  end
end
function VersionUpdateUI:OnApplicationVersionUpdate()
  log(bWriteLog and "VersionUpdateUI:OnApplicationVersionUpdate")
  local updater = self:GetUpdater()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  if self.versionInfo.isGrayUpdate == "1" then
    if string.len(self.versionInfo.versionString) > 0 and login_module.sIgnoreAppVersion == self.versionInfo.versionString then
      login_module:SetsIgnoreAppVersion(nil)
      if updater then
        updater:CancelAppUpdate()
      end
      return
    end
    login_module:SetsIgnoreAppVersion(nil)
  end
  self:RemoveCheckUpdateTimer()
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  local bShowNoticeEntry = NoticesModule:CanShowNotice(NoticesConst.Scene.VersionUpdate)
  self:ShowBulletinEntry(bShowNoticeEntry)
  local title = LocUtil.GetLocalizeResStr(201001)
  local tips = LocUtil.GetLocalizeResStr(201005)
  local warning = LocUtil.GetLocalizeResStr(201022)
  local okText = LocUtil.GetLocalizeResStr(201003)
  local cancelText = LocUtil.GetLocalizeResStr(110035)
  if self:IsCEVersionOrThirdParty() and 0 < self.versionInfo.needDownloadSize then
    local size = string.format(" <MessageGoldColor>(%.2fM)</> ", self.versionInfo.needDownloadSize)
    tips = tips .. size
  end
  if self.versionInfo.isForcedUpdating == "1" then
    tips = tips .. warning
  end
  log(bWriteLog and "songGT FuncUtil.IsSpecialBanClient " .. tostring(FuncUtil.IsSpecialBanClient()))
  local StatManager = import("StatManager")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    StatManager.GetInstance():ReportEventWithParam(111, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
    log(bWriteLog and string.format("VersionUpdateUI:OnApplicationVersionUpdate, CommonMsgBoxMgr.Show.clickOkCallback"))
    if self:IsCEVersionOrThirdParty() then
      log(bWriteLog and string.format("VersionUpdateUI:OnApplicationVersionUpdate, self:IsCEVersionOrThirdParty()"))
      local wifi = Client.HasActiveWifi()
      if wifi == true then
        self:StartUpdate()
      else
        local tips = LocUtil.LocalizeResFormat(201004, self.versionInfo.needDownloadSize)
        if self.versionInfo.isForcedUpdating == "1" then
          tips = tips .. warning
        end
        self:ResourceUpdatePopupWindow(tips)
        version_up_module:SetbShownWiFiTo4GTips(true)
      end
    elseif FuncUtil.IsSpecialBanClient() then
      log(bWriteLog and string.format("VersionUpdateUI:OnApplicationVersionUpdate, FuncUtil.IsSpecialBanClient()"))
      if self.versionInfo.isForcedUpdating == "1" then
        self:RecursivePopup()
      else
        if updater then
          updater:CancelAppUpdate()
        end
        FuncUtil.GotoNotGPUpgrade()
      end
    else
      log(bWriteLog and string.format("VersionUpdateUI:OnApplicationVersionUpdate, else"))
      if self.versionInfo.isForcedUpdating == "1" then
        self:RecursivePopup()
      elseif updater then
        updater:CancelAppUpdate()
        local AppUpdate = require("client.slua.umg.NewUpdate.app_update")
        AppUpdate:UpdateApp()
      end
    end
  end, function()
    StatManager.GetInstance():ReportEventWithParam(112, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
    if self.versionInfo.isForcedUpdating == "1" then
      GameStatus.QuitGame()
    else
      if self.versionInfo.isGrayUpdate ~= "1" then
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:SetsIgnoreAppVersion(self.versionInfo.versionString)
      end
      if updater then
        updater:CancelAppUpdate()
      end
    end
  end, okText, cancelText, extraData)
  StatManager.GetInstance():ReportEventWithParam(110, {
    wifi = tostring(Client.HasActiveWifi())
  }, true)
end
function VersionUpdateUI:OnResourceVersionUpdate()
  log(bWriteLog and "VersionUpdateUI:OnResourceVersionUpdate")
  self.isResourceUpdate = true
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if self.versionInfo.isGrayUpdate == "1" then
    if string.len(self.versionInfo.versionString) > 0 and login_module.sIgnoreResourceVersion == self.versionInfo.versionString then
      login_module:SetIgnoreResourceVersion(nil)
      self:CancelUpdate()
      return
    end
    login_module:SetIgnoreResourceVersion(nil)
  end
  if self.versionInfo.needDownloadSize <= 2 then
    self:StartUpdate()
  else
    self:RemoveCheckUpdateTimer()
    local wifi = Client.HasActiveWifi()
    local warning = ""
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    if self.versionInfo.isForcedUpdating == "1" and version_up_module:IsShowUpdatePrompt() ~= true then
      warning = LocUtil.GetLocalizeResStr(201022)
    end
    local bShowIOSUpdatePrompt = version_up_module:IsShowUpdatePrompt()
    local bInLoginForceLoginProgress = version_up_module:IsInLoginForceUpdateProgress()
    if wifi == true then
      local tips = LocUtil.LocalizeResFormat(5092, self.versionInfo.needDownloadSize)
      tips = tips .. warning
      if self.versionInfo.isForcedUpdating == "1" then
        if bShowIOSUpdatePrompt and bInLoginForceLoginProgress == false then
          self:ResourceUpdatePopupWindow(tips)
        else
          self:StartUpdate()
        end
      else
        self:ResourceUpdatePopupWindow(tips)
      end
    elseif bShowIOSUpdatePrompt and bInLoginForceLoginProgress == true then
      self:StartUpdate()
    else
      local tips = LocUtil.LocalizeResFormat(201004, self.versionInfo.needDownloadSize)
      tips = tips .. warning
      self:ResourceUpdatePopupWindow(tips)
      version_up_module:SetbShownWiFiTo4GTips(true)
    end
  end
end
function VersionUpdateUI:ResourceUpdatePopupWindow(tips)
  log(bWriteLog and "VersionUpdateUI:ResourceUpdatePopupWindow, tips = " .. tostring(tips))
  local title = LocUtil.GetLocalizeResStr(201001)
  local okText = LocUtil.GetLocalizeResStr(301346)
  local cancelText = LocUtil.GetLocalizeResStr(110035)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local StatManager = import("StatManager")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    self:StartUpdate()
    StatManager.GetInstance():ReportEventWithParam(111, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
  end, function()
    StatManager.GetInstance():ReportEventWithParam(112, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
    if self.versionInfo.isForcedUpdating == "1" then
      local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
      if version_up_module:IsShowUpdatePrompt() then
        self:CancelUpdate()
        version_up_module:TemporarilySwitchToLoginScreen(tips)
      else
        local logic_community = require("client.slua.logic.community.logic_community")
        logic_community.SendQuitGame()
        GameStatus.QuitGame()
      end
    elseif self.versionInfo.isAppUpdating == "1" then
      if self.versionInfo.isGrayUpdate ~= "1" then
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:SetsIgnoreAppVersion(self.versionInfo.versionString)
      end
      local updater = self:GetUpdater()
      if updater then
        updater:CancelAppUpdate()
      end
    else
      self:CancelUpdate()
    end
  end, okText, cancelText, extraData)
  StatManager.GetInstance():ReportEventWithParam(110, {
    wifi = tostring(Client.HasActiveWifi())
  }, true)
end
function VersionUpdateUI:StartUpdate()
  log(bWriteLog and "VersionUpdateUI:StartUpdate")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local updater = self:GetUpdater()
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and updater then
    updater:EnableIOSBGDownload4G(true)
  end
  self:RemoveRefreshTimer()
  if updater then
    updater:ContinueUpdate()
  end
  self.speedTimer = self:AddTimerLoop(0, function()
    self:OnRefreshDownloadSpeed()
  end, TIMER_INFINITE, 0.5)
  self.UIRoot.GridPanel_WifiUpdated:SetWidgetVisibility(SelfHitTestInvisible)
  self.UIRoot.VerticalBox_UpdateInfo:SetWidgetVisibility(SelfHitTestInvisible)
  self:InitUIComponent(true, false)
  logic_connection_waiting:Hide(0)
  if not UIManager.IsUIShow(UIManager.UI_Config.login_video) then
    self:UpdateBackgroundByCDNImage()
  end
end
function VersionUpdateUI:UpdateBackgroundByCDNImage()
  if self.CDNImageTimer then
    log(bWriteLog and "[jonahwei]VersionUpdateUI:UpdateBackgroundByCDNImage, duplicate")
    return
  end
  log(bWriteLog and "VersionUpdateUI:UpdateBackgroundByCDNImage")
  self.CDNImage = {}
  local IMSDKNotice = import("IMSDKNotice")
  local IMSDKNoticeInstance = IMSDKNotice.GetInstance()
  if IMSDKNoticeInstance ~= nil and Client.HasNotice(2, self.CDNNoticeType) == true then
    local notices = IMSDKNoticeInstance:GetNotice(self.CDNNoticeType)
    for k, v in pairs(notices) do
      for kk, vv in pairs(v.PicArray) do
        if string.len(vv.PicPath) > 0 then
          local temp = {}
          temp.url = vv.PicPath
          temp.title = vv.PicTitle
          temp.downloaded = false
          table.insert(self.CDNImage, temp)
          break
        end
      end
    end
  end
  if #self.CDNImage > 0 then
    self.CDNImageIndex = 1
    local PreDownloadImage = function(info)
      local params = {
        onDownloadSuccess = function(texture, url)
          log(bWriteLog and "PreDownloadImage, OnDownloadSuccess url = " .. tostring(url))
          for k, v in pairs(self.CDNImage) do
            if v.url == url then
              v.downloaded = true
              break
            end
          end
        end,
        onDownloadFail = function(url)
          log(bWriteLog and "PreDownloadImage, OnDownloadFailed url = " .. tostring(url))
        end
      }
      self:SetTexture(nil, info.url, params)
    end
    self.CDNImageTimer = self:AddTimerLoop(0, function()
      local current = self.CDNImage[self.CDNImageIndex]
      if current ~= nil then
        if current.downloaded == true then
          local params = {
            onDownlodaSuccess = function(texture, url)
              if url == current.url then
                EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_UPDATE_BACKGROUND_IMAGE, nil, texture)
                if current.title == nil or current.title == "" then
                  self.UIRoot.UpdateTips:SetText(LocUtil.GetLocalizeResStr(210018))
                else
                  self.UIRoot.UpdateTips:SetText(current.title)
                end
                self.CDNImageIndex = self.CDNImageIndex + 1
                if self.CDNImageIndex > #self.CDNImage then
                  self.CDNImageIndex = 1
                end
                local next = self.CDNImage[self.CDNImageIndex]
                if next ~= nil and next.downloaded == false then
                  PreDownloadImage(next)
                end
              else
                log(bWriteLog and "VersionUpdateUI:OnRefreshCDNImage, returned " .. tostring(url) .. ", but waiting for " .. tostring(current.url))
              end
            end,
            onDownloadFail = function(url)
              log(bWriteLog and "VersionUpdateUI:OnRefreshCDNImage, OnLoadFailed url = " .. tostring(url))
            end
          }
          self:SetTexture(nil, current.url, params)
        else
          PreDownloadImage(current)
        end
      end
    end, TIMER_INFINITE, 5)
  end
end
function VersionUpdateUI:RemoveRefreshTimer()
  log(bWriteLog and "VersionUpdateUI:RemoveRefreshTimer")
  if self.speedTimer ~= nil then
    self:RemoveTimer(self.speedTimer)
    self.speedTimer = nil
  end
  if self.CDNImageTimer ~= nil then
    self:RemoveTimer(self.CDNImageTimer)
    self.CDNImageTimer = nil
  end
end
function VersionUpdateUI:GetSizeInfo()
  if self.useNewComp then
    return self.secondDownloadCurSize, self.secondDownloadTotalSize
  else
    local updater = self:GetUpdater()
    if updater then
      return updater:GetCurValue(), updater:GetTotalValue()
    else
      return 0, 0
    end
  end
end
function VersionUpdateUI:OnRefreshDownloadSpeed()
  local TimeUtil = require("client.common.time_util")
  printf("VersionUpdateUI:OnRefreshDownloadSpeed. self.calculateSpeedState=%s", tostring(self.calculateSpeedState))
  if self.calculateSpeedState ~= 0 then
    if self.calculateSpeedState == 1 then
      self.calculateSpeedState = 2
      local curSize, totalSize = self:GetSizeInfo()
      self.haveDownloadedSize = curSize
      self.lastCalculateTime = TimeUtil.GetMiliseconds()
      self.downloadSpeed = 0
      self.realtimeDownloadSpeedZeroCount = 0
      self.calculateAverageSpeedState = 1
      self.averageDownloadSize = self.haveDownloadedSize
      self.lastCalculateAverageTime = self.lastCalculateTime
      self.averageDownloadSpeed = 0
    else
      local updater = self:GetUpdater()
      if updater then
        local curSize, totalSize = self:GetSizeInfo()
        local increment = curSize - self.haveDownloadedSize
        if increment < 0 then
          increment = 0
        end
        local curTime = TimeUtil.GetMiliseconds()
        local time = curTime - self.lastCalculateTime
        if time < 0 then
          time = 0
        end
        time = time / 1000
        log(bWriteLog and "VersionUpdateUI:OnRefreshDownloadSpeed, increment = " .. tostring(increment) .. ", time = " .. tostring(time))
        if time == 0 then
          self.downloadSpeed = 0
        else
          self.downloadSpeed = increment / time
        end
        if self.downloadSpeed <= 0.01 then
          self.realtimeDownloadSpeedZeroCount = self.realtimeDownloadSpeedZeroCount + 1
        else
          self.realtimeDownloadSpeedZeroCount = 0
        end
        self.haveDownloadedSize = curSize
        self.lastCalculateTime = curTime
        increment = curSize - self.averageDownloadSize
        if increment < 0 then
          increment = 0
        end
        time = curTime - self.lastCalculateAverageTime
        time = time / 1000
        if time < 0 then
          time = 0
        end
        if time == 0 then
          self.averageDownloadSpeed = 0
        elseif self.calculateAverageSpeedState == 1 then
          if 5 < time then
            self.calculateAverageSpeedState = 2
            self.averageDownloadSpeed = increment / time
            self.averageDownloadSize = curSize
            self.lastCalculateAverageTime = curTime
          else
            self.averageDownloadSpeed = increment / time
          end
        elseif 5 < time then
          self.averageDownloadSpeed = increment / time
          self.averageDownloadSize = curSize
          self.lastCalculateAverageTime = curTime
        end
        if 2 <= self.realtimeDownloadSpeedZeroCount or self.averageDownloadSpeed <= 0.01 then
          self.TextBlock_DownloadSpeed:SetWidgetVisibility(Collapsed)
          self.TextBlock_RemainTime:SetWidgetVisibility(Hidden)
        else
          self:SetWidgetVisible(self.TextBlock_DownloadSpeed, self.useNewComp)
          self:SetWidgetVisible(self.UIRoot.UpdateTips, false)
          self.TextBlock_RemainTime:SetWidgetVisibility(SelfHitTestInvisible)
          if self.useNewComp then
            if self.secondDownloadCurStage == PufferInterface.STAGE_FILE_DOWNLOADING or self.secondDownloadCurStage == nil then
              self:FormatSpeedAndLeftTime(self.downloadSpeed, (totalSize - curSize) / self.averageDownloadSpeed)
            else
              self.TextBlock_DownloadSpeed:SetText("")
            end
          end
        end
      end
    end
  end
end
function VersionUpdateUI:FormatSpeedAndLeftTime(speed, lefttime)
  log(bWriteLog and "VersionUpdateUI:FormatSpeedAndLeftTime, speed = " .. tostring(speed) .. ", lefttime = " .. tostring(lefttime))
  if 1024 < speed then
    speed = string.format("%.2f", speed / 1024)
    speed = speed .. " MB/s"
  else
    speed = string.format("%.2f", speed)
    speed = speed .. " KB/s"
  end
  self.TextBlock_DownloadSpeed:SetText(speed)
  local remainTimeText = ""
  if not self.showSecondStageReward then
    local text = LocUtil.GetLocalizeResStr(4989)
    local KismetMathLibrary = import("KismetMathLibrary")
    local timespan = KismetMathLibrary.FromSeconds(lefttime)
    local KismetTextLibrary = import("KismetTextLibrary")
    local time = KismetTextLibrary.AsTimespan_Timespan(timespan)
    remainTimeText = text .. time
  end
  self.TextBlock_RemainTime:SetText(remainTimeText)
end
function VersionUpdateUI:OnDolphinProgress(curStage)
  log(bWriteLog and "VersionUpdateUI:OnDolphinProgress, curStage = " .. tostring(curStage))
  local preStage = self.currentStage
  if preStage == "updating" then
    local time_step_macros = require("client.slua.logic.performance.time_step_macros")
    local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
    logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.SplashEndToUpdatePatchStart)
    logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.UpdatePatchStartToUpdatePatchEnd)
  end
  if 69 == curStage or 71 == curStage then
    self.currentStage = "GetingVerInfo"
  elseif 74 == curStage or 75 == curStage or 76 == curStage or 77 == curStage or 79 == curStage then
    self.currentStage = "CheckingValidity"
  elseif 31 == curStage then
    self.currentStage = "CheckingPatch"
  elseif 70 == curStage then
    self.currentStage = "StartUpdateApk"
  elseif 78 == curStage then
    self.currentStage = "ApkUpdateMergeDiff"
  elseif 91 == curStage then
    self.currentStage = "SourceUpdateDownloadList"
  elseif 92 == curStage then
    self.currentStage = "SourcePrepareUpdate"
  elseif 93 == curStage then
    self.currentStage = "SourceAnalyseDiff"
  elseif 95 == curStage then
    self.currentStage = "Extraing"
  elseif 96 == curStage then
    self.currentStage = "MergeBGDownloadResources"
  elseif 99 == curStage then
    self.currentStage = "Success"
  else
    self.currentStage = "Downloading"
  end
  log(bWriteLog and "VersionUpdateUI:OnDolphinProgress, preStage = " .. tostring(preStage) .. ", currentStage = " .. tostring(self.currentStage))
  local StatManager = import("StatManager")
  if preStage ~= self.currentStage then
    if self.currentStage == "CheckingValidity" then
      StatManager.GetInstance():ReportEventWithParam(115, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    elseif preStage == "CheckingValidity" then
      StatManager.GetInstance():ReportEventWithParam(116, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    end
    if self.currentStage == "ApkUpdateMergeDiff" then
      StatManager.GetInstance():ReportEventWithParam(117, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    elseif preStage == "ApkUpdateMergeDiff" then
      StatManager.GetInstance():ReportEventWithParam(118, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    end
    if self.currentStage == "Downloading" then
      StatManager.GetInstance():ReportEventWithParam(113, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    elseif preStage == "Downloading" then
      StatManager.GetInstance():ReportEventWithParam(114, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    end
  end
  if 94 == curStage then
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:ShowTipsWhenWiFi4GSwitched()
  end
  if self.currentStage == "GetingVerInfo" then
    if not self.checkUpdateTimer then
      local STExtraGameInstance = import("STExtraGameInstance")
      local gameInstance = STExtraGameInstance.GetInstance()
      local deviceLevel = gameInstance:GetDeviceLevel()
      local waitTime = 30
      if deviceLevel <= 0 then
        waitTime = 50
      end
      if _G.IsEditor then
        waitTime = 1
      end
      self.checkUpdateWaitTime = 0
      self.checkUpdateTimer = self:AddTimerLoop(0, function()
        if self.checkUpdateWaitTime < waitTime then
          if self.checkUpdateWaitTime >= 5 then
            self:SetWidgetVisible(self.TextBlock_RemainTime, not self.showSecondStageReward)
            local str = LocUtil.LocalizeResFormat(12432, LocUtil.LocalizeResFormat(11138, waitTime - self.checkUpdateWaitTime))
            if self.showSecondStageReward then
              str = ""
            end
            self.TextBlock_RemainTime:SetText(str)
          else
            self.TextBlock_RemainTime:SetText("")
          end
          self.checkUpdateWaitTime = self.checkUpdateWaitTime + 1
        else
          log(bWriteLog and "VersionUpdateUI:OnDolphinProgress CheckUpdate Time End, FinishUpdate")
          self.TextBlock_RemainTime:SetText("")
          if Client.HasDownloadedBasePak() then
            local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
            PufferDownloader.UpdateGrayStep = PufferDownloader.UpdateGrayStep + 100
            version_up_module:SetbAlreadyGrayUpdate(true)
            local updater = self:GetUpdater()
            if updater then
              updater:OnUpdateError(69, self.ErrCodeTimeOut)
            end
          end
        end
      end, TIMER_INFINITE, 1)
    end
  else
    self:RemoveCheckUpdateTimer()
  end
  self:UpdateTextByStage()
  self:UpdateDownloadProgress()
  self:StartCalculateDownloadSpeed()
end
function VersionUpdateUI:RemoveCheckUpdateTimer()
  if self.checkUpdateTimer then
    self.TextBlock_RemainTime:SetText("")
    self:RemoveTimer(self.checkUpdateTimer)
    self.checkUpdateTimer = nil
  end
end
function VersionUpdateUI:ShowUIWhenGrayDownloading()
  if self.gray and self.currentStage ~= "GetingVerInfo" and self.currentStage ~= "CheckingValidity" and self.currentStage ~= "StartUpdateApk" and self.currentStage ~= "SourcePrepareUpdate" and self.currentStage ~= "Success" then
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_UPDATE_BACKGROUND_IMAGE, true)
    self.UIRoot.GridPanel_UpdateUI:SetWidgetVisibility(SelfHitTestInvisible)
  end
end
function VersionUpdateUI:UpdateTextByStage()
  if self.preStage ~= self.currentStage then
    self.preStage = self.currentStage
    self:ShowUIWhenGrayDownloading()
    local text
    if self.currentStage == "GetingVerInfo" then
      text = LocUtil.GetLocalizeResStr(201018)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "CheckingValidity" then
      text = LocUtil.GetLocalizeResStr(201021)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "CheckingPatch" then
      text = LocUtil.GetLocalizeResStr(7464)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "StartUpdateApk" then
      text = LocUtil.GetLocalizeResStr(201020)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "ApkUpdateMergeDiff" then
      text = LocUtil.GetLocalizeResStr(19110)
      self.UIRoot.ProgressBar_Update:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.UpdateTips:SetWidgetVisibility(SelfHitTestInvisible)
    elseif self.currentStage == "SourceUpdateDownloadList" then
      text = LocUtil.GetLocalizeResStr(201026)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "SourcePrepareUpdate" then
      text = LocUtil.GetLocalizeResStr(201027)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "SourceAnalyseDiff" then
      text = LocUtil.GetLocalizeResStr(201028)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "Downloading" then
      text = LocUtil.GetLocalizeResStr(201019)
      self.UIRoot.ProgressBar_Update:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.UpdateTips:SetWidgetVisibility(SelfHitTestInvisible)
    elseif self.currentStage == "Extraing" then
      text = LocUtil.GetLocalizeResStr(201017)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "MergeBGDownloadResources" then
      text = LocUtil.GetLocalizeResStr(7179)
      self.UIRoot.ProgressBar_Update:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.UpdateTips:SetWidgetVisibility(SelfHitTestInvisible)
    elseif self.currentStage == "Success" then
      text = LocUtil.GetLocalizeResStr(201029)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "ShaderDecompressing" then
      text = LocUtil.GetLocalizeResStr(7464)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "TouchTransMissionStart" then
      text = LocUtil.GetLocalizeResStr(7464)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "TouchTransMissionEnd" then
      text = LocUtil.GetLocalizeResStr(7464)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    elseif self.currentStage == "TouchTransMissionProgress" then
      text = LocUtil.GetLocalizeResStr(19110)
      self.UIRoot.ProgressBar_Update:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.UpdateTips:SetWidgetVisibility(SelfHitTestInvisible)
    else
      text = LocUtil.GetLocalizeResStr(201024)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
    end
    if self.useNewComp then
      self.UIRoot.TextBlock_SDLoading:SetText(text)
    else
      self.TextBlock_State:SetText(text)
    end
  end
end
function VersionUpdateUI:ShowSystemNotifyEntry(isEnabled)
  self:SetWidgetVisible(self.UIRoot.Button_SystemNotify, isEnabled, true)
  self:SetWidgetVisible(self.UIRoot.TextBlock_1, isEnabled)
  self:SetWidgetVisible(self.UIRoot.TextBlock_SysNotify, isEnabled)
  self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(13157))
end
function VersionUpdateUI:ShowBulletinEntry(isEnabled)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Bulletin, isEnabled)
end
function VersionUpdateUI:UpdateDownloadProgress()
  local updater = self:GetUpdater()
  if updater then
    local percent = updater:GetCurPercent()
    self.UIRoot.ProgressBar_Update:SetPercent(percent)
    if self.currentStage == "Downloading" or self.currentStage == "ApkUpdateMergeDiff" or self.currentStage == "MergeBGDownloadResources" then
      local current = updater:GetCurValue()
      local total = updater:GetTotalValue()
      if total / 1024 > 0 then
        self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(SelfHitTestInvisible)
        self.UIRoot.UpdateTips:SetWidgetVisibility(SelfHitTestInvisible)
        self.UIRoot.ProgressBar_Update:SetWidgetVisibility(SelfHitTestInvisible)
        local strText = ""
        if self.currentStage == "Downloading" then
          local strCur = string.format("%.1f", current / 1024)
          local strTotal = string.format("%.1f", total / 1024)
          strText = LocUtil.LocalizeResFormat(16190, strCur, strTotal)
        else
          self.TextBlock_DownloadSpeed:SetWidgetVisibility(Collapsed)
          self.TextBlock_RemainTime:SetWidgetVisibility(Hidden)
          strText = LocUtil.LocalizeResFormat(10283, math.floor(percent * 100))
        end
        self.TextBlock_SizeInfo:SetText(" " .. strText)
      else
        self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
        self.UIRoot.UpdateTips:SetWidgetVisibility(Hidden)
        self.TextBlock_DownloadSpeed:SetWidgetVisibility(Collapsed)
        self.TextBlock_RemainTime:SetWidgetVisibility(Hidden)
      end
    else
      self.TextBlock_State:SetWidgetVisibility(SelfHitTestInvisible)
      self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
      self.TextBlock_DownloadSpeed:SetWidgetVisibility(Collapsed)
      self.TextBlock_RemainTime:SetWidgetVisibility(Hidden)
      if self.currentStage == "GetingVerInfo" then
        self.TextBlock_RemainTime:SetWidgetVisibility(SelfHitTestInvisible)
      end
    end
  end
end
function VersionUpdateUI:StartCalculateDownloadSpeed()
  if self.currentStage == "Downloading" then
    if self.calculateSpeedState == 0 then
      self.calculateSpeedState = 1
    end
  else
    self.calculateSpeedState = 0
  end
end
function VersionUpdateUI:OnDolphinError(errorCode)
  log(bWriteLog and "VersionUpdateUI:OnDolphinError, errorCode = " .. tostring(errorCode))
  local IntlHelper = import("IntlHelper")
  IntlHelper.AddErrorCodeToHistory(string.format("dmp-%s", tostring(errorCode)))
  local code = tonumber(errorCode)
  if code == 221249538 then
    return
  end
  if errorCode == self.ErrCodeTimeOut then
    local updater = self:GetUpdater()
    if updater then
      updater:FinishUpdate()
    end
    return
  end
  local hdmpveLogic = require("client.slua.logic.hdmpve.logic_hdmpve")
  local hdmpInstanceIdMapper = hdmpveLogic:FetchInstanceIdMapper()
  local tips = ""
  local canIgnore = true
  if Client.HasDownloadedBasePak() and code ~= 154140709 then
    self.retriedUpdateTimes = self.retriedUpdateTimes + 1
  end
  if code == 689045511 or code == 689045510 or code == 353501190 or code == 353435649 or code == 353501191 or code == 353502185 or code == 353501240 or code == 353501600 or code == 353501588 or code == 353501587 or code == 353501236 or code == 353501207 or code == 353502189 or code == 353501202 or code == 353502085 or code == 353501684 or code == 353501584 or code == 353501687 or code == 353501598 or code == 353501212 or code == 353501686 or code == 353501585 or code == 353501219 or code == 689045908 or code == 689045556 or code == 554827782 or code == 554827832 or code == 554827828 or code == 554828180 or code == 554762241 or code == 554828781 or code == 554827783 or code == 154140673 or code == 154140674 or code == 154140675 or code == 353501185 or code == 154140713 or code == 154140714 or code == 154140715 or code == 154140716 or code == 154140711 or code == 154140712 or code == 154140719 or code == 154140720 or code == 554827804 or code == 689045532 or code == 420610452 or code == 154140706 or code == 87031824 or 154140677 <= code and code <= 154140697 then
    canIgnore = false
    tips = LocUtil.LocalizeResFormat(201010, string.format("%s, %s", tostring(errorCode), hdmpInstanceIdMapper))
    if code == 154140712 or code == 154140713 or code == 154140714 or code == 154140715 or code == 154140716 or code == 154140719 or code == 554827804 or code == 689045532 or code == 554762241 then
      local hasBasePakButTimeOut = Client.HasDownloadedBasePak() and (code == 154140713 or code == 154140716 or code == 154140712 or code == 554827804 or code == 689045532 or code == 554762241)
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      if self.haveRetried71X or hasBasePakButTimeOut then
        if not login_module.nReportedSkippedError then
          login_module:SetReportedSkippedError(code)
          if Client.HasDownloadedBasePak() then
            self:ReportIgnoredUpdateError(code)
          end
          local isNetReachable = Client.IsNetworkReachable()
          if isNetReachable == true then
            local param = {
              error_code = tostring(code),
              type = "1"
            }
            log(bWriteLog and "VersionUpdateUI:OnDolphinError, network is reachable")
            Client.GEMReportEvent(GameFrontendHUD, "71XButHasNet", param)
          end
        end
        if Client.HasDownloadedBasePak() then
          canIgnore = true
          if hasBasePakButTimeOut and self.haveRetried71X ~= true then
            local title = LocUtil.GetLocalizeResStr(201001)
            local okLabel = LocUtil.GetLocalizeResStr(110036)
            local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
            CommonMsgBoxMgr.Show(1, title, tips, function()
              if self.versionInfo.isAppUpdating == "2" then
                log(bWriteLog and "VersionUpdateUI:OnDolphinError, ignore udpate and disable repair")
                Client.DisableRepairResource(GameFrontendHUD)
              end
              local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
              PufferDownloader.UpdateGrayStep = PufferDownloader.UpdateGrayStep + 200
              version_up_module:SetbAlreadyGrayUpdate(true)
              local updater = self:GetUpdater()
              if updater then
                updater:FinishUpdate()
              end
            end, nil, okLabel, extraData)
            return
          end
        else
          self:ShowRetryDownloadPanel(tips)
        end
      else
        self.haveRetried71X = true
        self:ShowRetryDownloadPanel(tips)
      end
    elseif self.retriedUpdateTimes > self.maxRetryUpdateTimes then
      canIgnore = true
      self:ReportIgnoredUpdateError(code)
    else
      self:ShowRetryDownloadPanel(tips)
    end
  elseif self.retriedUpdateTimes > self.maxRetryUpdateTimes then
    canIgnore = true
    self:ReportIgnoredUpdateError(code)
  elseif code == 355471270 or code == 355467269 or code == 355469265 or code == 691011599 or code == 556793868 or code == 556793861 or code == 691011598 then
    tips = LocUtil.LocalizeResFormat(201011, tostring(errorCode))
    canIgnore = false
    self:ShowRetryDownloadPanel(tips)
  elseif code == 353697820 or code == 555745297 or code == 689963036 or code == 689242140 then
    tips = LocUtil.LocalizeResFormat(201012, tostring(errorCode))
    canIgnore = false
    self:ShowCancelPanel(tips)
  elseif code == 688914441 or code == 556793859 or code == 288358404 or code == 87031823 or code == 691011591 or code == 691011585 or 422576129 <= code and code <= 422576148 or 420478976 <= code and code <= 421527551 or 489684993 <= code and code <= 489685003 or 487587840 <= code and code <= 488636415 or 87031809 <= code and code <= 87031821 then
    tips = LocUtil.LocalizeResFormat(201012, tostring(errorCode))
    canIgnore = false
    self:ShowRetryDownloadPanel(tips)
  elseif code == 154140709 or code == 154140688 then
    tips = LocUtil.LocalizeResFormat(201013, tostring(errorCode))
  elseif code == 353697796 or code == 353697914 or code == 353697822 or code == 353697794 or code == 353697797 or code == 353697805 or code == 556793857 or code == 555745310 or code == 556793874 or code == 289407004 or code == 289406980 or code == 289406993 or code == 289407098 or code == 289407085 or code == 288358406 or code == 289407006 or code == 289407071 or code == 691011585 then
    tips = LocUtil.LocalizeResFormat(48105, tostring(errorCode)) .. "(" .. tostring(errorCode) .. ", " .. hdmpInstanceIdMapper .. ")"
    canIgnore = false
    self:ShowRetryDownloadPanel(tips)
  elseif code == 555745308 or code == 555024412 then
    tips = LocUtil.LocalizeResFormat(201032, tostring(errorCode))
    canIgnore = false
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:ShowConfirmPanelWhenLowMemory(tips)
  elseif code == 554828179 then
    tips = LocUtil.GetLocalizeResStr(5060) .. "(" .. tostring(errorCode) .. ", " .. hdmpInstanceIdMapper .. ")"
    canIgnore = false
    self:ShowCountDownRetryPanel(tips, 60)
  elseif code == 555024405 or code == 554828779 then
    local dir = ""
    if code == 555024405 then
      dir = Client.ProjectSavedDir() .. "Paks/new.filelist.mottd"
    elseif code == 554828779 then
      dir = Client.ProjectSavedDir() .. "Paks/new.filelist"
    end
    if dir ~= "" and 0 < #dir then
      Client.DeleteDirectory(dir)
      Client.DeleteFile(dir)
    end
    if self.retriedUpdateAfterDeleteFileTimes < self.maxRetryUpdateAfterDeleteFileTimes then
      self.retriedUpdateAfterDeleteFileTimes = self.retriedUpdateAfterDeleteFileTimes + 1
      if slua_GameFrontendHUD then
        slua_GameFrontendHUD:RetryDownload()
      end
    else
      tips = LocUtil.GetLocalizeResStr(48107) .. "(" .. tostring(errorCode) .. ", " .. hdmpInstanceIdMapper .. ")"
      canIgnore = false
      self:ShowRetryDownloadPanel(tips)
    end
  else
    tips = LocUtil.GetLocalizeResStr(48107) .. "(" .. tostring(errorCode) .. ", " .. hdmpInstanceIdMapper .. ")"
    canIgnore = false
    self:ShowRetryDownloadPanel(tips)
  end
  if canIgnore then
    local updater = self:GetUpdater()
    if updater then
      updater:FinishUpdate()
    end
    return
  end
end
function VersionUpdateUI:ReportIgnoredUpdateError(errorCode)
  log(bWriteLog and "VersionUpdateUI:ReportIgnoredUpdateError, errorCode = " .. tostring(errorCode))
  local strErrorCode = ""
  if errorCode ~= nil then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:SetReportedSkippedError(errorCode)
    strErrorCode = tostring(errorCode)
  end
  local isReportedError = false
  if self.reportedErrorList ~= nil then
    for k, p in pairs(self.reportedErrorList) do
      if p == strErrorCode then
        isReportedError = true
        break
      end
    end
  end
  if isReportedError then
    log(bWriteLog and "VersionUpdateUI:ReportIgnoredUpdateError, ignored same errorCode = " .. tostring(strErrorCode))
  else
    if self.reportedErrorList ~= nil then
      table.insert(self.reportedErrorList, strErrorCode)
    end
    local param = {
      current_version = Client.GetAppVersion() or "0.0.0.0",
      error_code = strErrorCode
    }
    log(bWriteLog and "VersionUpdateUI:ReportIgnoredUpdateError, report errorCode = " .. tostring(strErrorCode))
    Client.GEMReportEvent(GameFrontendHUD, "GCloud712Skip", param)
  end
end
function VersionUpdateUI:ShowRetryDownloadPanel(tips)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  log(bWriteLog and "VersionUpdateUI:ShowRetryDownloadPanel, tips = " .. tostring(tips) .. ", enableCDNGetVersion = " .. tostring(login_module.bEnableCDNGetVersion))
  self.tempTips = tips
  local title = LocUtil.GetLocalizeResStr(201001)
  local okLabel = LocUtil.GetLocalizeResStr(201002)
  local cancelLabel = LocUtil.GetLocalizeResStr(4539)
  if login_module.bEnableCDNGetVersion == true then
    okLabel = LocUtil.GetLocalizeResStr(110036)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, tips, function()
      if self.versionInfo.isAppUpdating == "2" then
        Client.DisableRepairResource(GameFrontendHUD)
      end
      local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
      PufferDownloader.UpdateGrayStep = PufferDownloader.UpdateGrayStep + 400
      version_up_module:SetbAlreadyGrayUpdate(true)
      local updater = self:GetUpdater()
      if updater then
        updater:FinishUpdate()
      end
    end, nil, okLabel, nil, extraData)
  else
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tips, function()
      logic_connection_waiting:Show(0)
      if slua_GameFrontendHUD then
        slua_GameFrontendHUD:RetryDownload()
      end
    end, function()
      self.cancelUpdateTimes = self.cancelUpdateTimes + 1
      if self.versionInfo.isForcedUpdating == "1" then
        self:ConfirmClickCancelBtn()
      else
        self.cancelUpdateTimes = 0
        self:CancelUpdate()
      end
    end, okLabel, cancelLabel, extraData)
  end
end
function VersionUpdateUI:ConfirmClickCancelBtn()
  log(bWriteLog and "VersionUpdateUI:ConfirmClickCancelBtn")
  if self.cancelUpdateTimes >= 5 then
    EventAndroidQuitGame()
  elseif self.cancelUpdateTimes >= 1 then
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Login)
    self:AddTimerOnce(2, function()
      self:ShowRetryDownloadPanel(self.tempTips)
    end)
  end
end
function VersionUpdateUI:ShowCancelPanel(tips)
  log(bWriteLog and "VersionUpdateUI:ShowCancelPanel, tips = " .. tostring(tips))
  local title = LocUtil.GetLocalizeResStr(201001)
  local cancelLabel = LocUtil.GetLocalizeResStr(110035)
  local warning = ""
  if self.versionInfo.isForcedUpdating == "1" then
    warning = LocUtil.GetLocalizeResStr(201022)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, tips .. warning, function()
    if self.versionInfo.isForcedUpdating == "1" then
      EventAndroidQuitGame()
    else
      self:CancelUpdate()
    end
  end, nil, cancelLabel, nil, extraData)
end
function VersionUpdateUI:ShowCountDownRetryPanel(tips, countdownTime, interval)
  log(bWriteLog and "VersionUpdateUI:ShowCountDownRetryPanel, tips = " .. tostring(tips) .. ", countdownTime = " .. tostring(countdownTime) .. ", interval = " .. tostring(interval))
  if interval == nil then
    interval = 1
  end
  self.tempTips = tips
  local title = LocUtil.GetLocalizeResStr(201001)
  local okLabel = LocUtil.GetLocalizeResStr(201002)
  local TimeUtil = require("client.common.time_util")
  self.CountDownRetryRefreshedTime = TimeUtil.OSTime()
  self.CountDownRetryRefreshPassedTime = 0
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.DisableOKBtn()
  CommonMsgBoxMgr.Show(1, title, tips .. "\n" .. tostring(countdownTime), function()
    logic_connection_waiting:Show(0)
    if slua_GameFrontendHUD then
      slua_GameFrontendHUD:RetryDownload()
    end
  end, nil, okLabel, nil, false, function()
    self.CountDownRetryRefreshPassedTime = self.CountDownRetryRefreshPassedTime + TimeUtil.OSTime() - self.CountDownRetryRefreshedTime
    if 0 < countdownTime and self.CountDownRetryRefreshPassedTime > 1 then
      self.CountDownRetryRefreshPassedTime = self.CountDownRetryRefreshPassedTime - 1
      countdownTime = countdownTime - 1
      CommonMsgBoxMgr.UpdateMsg(tips .. "\n" .. tostring(countdownTime))
    end
    if countdownTime == 0 then
      CommonMsgBoxMgr.UpdateMsg(tips)
      CommonMsgBoxMgr.EnableOKBtn()
    end
  end, nil, nil, extraData)
end
function VersionUpdateUI:OnDolphinNoticeInstallApk(skipInstall)
  self.UIRoot.GridPanel_NoWifiUpdated:SetWidgetVisibility(Hidden)
  self.UIRoot.GridPanel_WifiUpdated:SetWidgetVisibility(Hidden)
  log_format("VersionUpdateUI:OnDolphinNoticeInstallApk, currentStage = %s", self.currentStage)
  if self.currentStage == "ApkUpdateMergeDiff" then
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithParam(118, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
  end
  if skipInstall then
  else
    local AppUpdate = require("client.slua.umg.NewUpdate.app_update")
    AppUpdate:UpdateApp()
  end
  local title = LocUtil.GetLocalizeResStr(201001)
  local content = LocUtil.GetLocalizeResStr(201009)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, content, function()
    log(bWriteLog and "VersionUpdateUI:OnDolphinNoticeInstallApk, on click.")
    self:OnDolphinNoticeInstallApk(true)
  end, nil, nil, nil, extraData)
end
function VersionUpdateUI:RunLogicOnUpdateFinished()
  local ForceDisableCvm = HDmpveRemote.HDmpveRemoteConfigGetInt("ForceDisableCvm", 0)
  if ForceDisableCvm == 0 and Client.InitializeCvmWithRunPhase then
    Client.InitializeCvmWithRunPhase(3)
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local IOSCheckSymbolSource = HDmpveRemote.HDmpveRemoteConfigGetInt("IOSCheckSymbolSource", 1)
    if 0 < IOSCheckSymbolSource and Client.CheckMemorySymbolSource and Client.CheckMemorySymbolSource() == 1 then
      local DocumentDir = Client.GetPureIOSDocumentsDirectory()
      local FlagFilePath = DocumentDir .. "/OSMallocJudge.flag"
      local file = io.open(FlagFilePath, "w")
      if file then
        file:write("1")
        file:close()
        log(bWriteLog and "CheckSymbolSource SaveStringToFile:" .. FlagFilePath)
      else
        log(bWriteLog and "CheckSymbolSource create failed:" .. FlagFilePath)
      end
    end
  end
end
function VersionUpdateUI:OnUpdateFinished()
  self:ShowSystemNotifyEntry(false)
  self:ShowBulletinEntry(false)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local fitShaderExist = false
    local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
    local shaderPakName = ""
    if string.find(APILevel, "ES2") then
      shaderPakName = PufferConst.FIT_ES2SHADER
    else
      shaderPakName = PufferConst.FIT_ES3SHADER
    end
    local file_util = require("client.common.file_util")
    local fileList = file_util.FindFiles(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR, "pak")
    local StringUtil = require("common.string_util")
    for _, fileName in pairs(fileList) do
      if StringUtil.StrFind(fileName, shaderPakName) then
        fitShaderExist = true
      end
    end
    if not fitShaderExist then
      local gameInstance = slua_GameFrontendHUD:GetGameInstance()
      local renderQuality = gameInstance:GetRenderQualityLastSet()
      renderQuality.RenderQualitySetting = 1
      gameInstance:SetRenderQuality(renderQuality)
    end
  end
  local newLoginLogic = HDmpveRemote.HDmpveRemoteConfigGetBool("UseNewLoginLogic410", true)
  if self.gray == false then
    self:AfterFinishedUpdate()
    if not newLoginLogic then
      local USFSInitProcessOnceAgain = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSInitProcessOnceAgain", 0)
      log("logic_puffer_common.USFCacheInitProcess USFSInitProcessOnceAgain: " .. USFSInitProcessOnceAgain)
      if USFSInitProcessOnceAgain == 1 then
        local logic_puffer_file = require("client.slua.logic.download.puffer.logic_puffer_common")
        logic_puffer_file.USFCacheInitProcessPreDownload()
      end
    end
  else
    log("[AddTimer] Client.EnableShaderGroup map_lobby beg")
    local gameInstance = slua_GameFrontendHUD:GetGameInstance()
    log_format("OnUpdateFinished r.DeferSplitShaderLibraryLoaded: %s", 0)
    gameInstance:ExecuteCMD("r.DeferSplitShaderLibraryLoaded", 0)
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    local GEnableShaderGroupAsync = version_up_module:GetGEnableShaderGroupAsync()
    log_format("OnUpdateFinished GEnableShaderGroupAsync: %s", GEnableShaderGroupAsync)
    gameInstance:ExecuteCMD("r.EnableShaderGroupAsync", GEnableShaderGroupAsync)
    local platformName = Client.GetDevicePlatformName()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if 1 <= GEnableShaderGroupAsync and platformName == DevicePlatformNameMacros.IOS then
      if GEnableShaderGroupAsync == 2 then
        Client.EnableShaderGroupAsync_New("map_lobby,map_lobby_CSM")
      else
        Client.EnableShaderGroupAsync("map_lobby,map_lobby_CSM")
      end
    else
      Client.EnableShaderGroup("map_lobby")
      Client.EnableShaderGroup("map_lobby_CSM")
    end
    log("[AddTimer] Client.EnableShaderGroup map_lobby end")
    self:AddTimerOnce(0.5, function()
      log(bWriteLog and "[AddTimer] ShaderPreCompileSystem.OnFinishUpdate")
      FuncUtil.AddCrashContextMainFlow("40")
      Client.RestartShaderPrecompile()
      local ShaderPreCompileSystem = require("client.logic.ver_update.logic_shader_precompile")
      ShaderPreCompileSystem.OnFinishUpdate()
    end)
    if not newLoginLogic then
      self:RunLogicOnUpdateFinished()
      local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
      version_up_module:DeleteOldNeedUpdateFiles()
      local EnableVirtualMerge = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableVirtualMerge", false)
      if EnableVirtualMerge then
        log("VersionUpdateUI:AfterFinishedUpdate EnableVirtualMerge")
        local Enabled = Client.EnableMergeVirtual()
        log("VersionUpdateUI:AfterFinishedUpdate EnableVirtualMerge " .. tostring(Enabled))
      end
      local PufferODPakDelList = require("client.slua.logic.download.puffer.odpak.puffer_odpak_del_once")
      PufferODPakDelList.DeleteSYSOldFiles()
      local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
      PufferDeleteManager.DeleteLogicInLogin()
      PufferDeleteManager.HandleDeleteCrashFile()
      local logic_puffer_file = require("client.slua.logic.download.puffer.logic_puffer_common")
      logic_puffer_file.USFCacheInitProcessPreDownload()
    end
  end
end
function VersionUpdateUI:AfterFinishedUpdate()
  log(bWriteLog and "VersionUpdateUI:AfterFinishedUpdate")
  Client.AddCrashContextData(4, Client.GetAppVersion(), false, 100)
  Client.AddCrashContextData(5, self.gray and "1" or "0", false, 100)
  Client.CrashLog(NetInterface, 4, "Login", "UpdateFinish")
  Client.ReportEventLoadingCompleted()
  if self.gray or Client.isSkipUpdateByRepair(GameFrontendHUD) or Client.IsUpdateSkip(GameFrontendHUD) or _G.IsEditor then
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:InitializePuffer(true)
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if self.showSecondStageReward and Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    ShowNotice(8800601)
  end
  local LogicTouchTransmission = require("client.slua.logic.touch_transmission.logic_touch_transmission")
  LogicTouchTransmission:GenTransisionIndexFile()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  local pufferInited = PufferDownloader.InitSuccess
  log_format("VersionUpdateUI:AfterFinishedUpdate. isFitVersion=%s, pufferInited=%s", isFitVersion, pufferInited)
  if isFitVersion then
    local LanguageDownload = require("client.slua.logic.download.recommend.logic_language_download")
    local recordLang = LanguageDownload.GetSaveGameObjectLanguage()
    log_format("VersionUpdateUI:AfterFinishedUpdate. recordLang=%s", recordLang)
    if pufferInited and recordLang == nil then
      local lang = LanguageDownload.GetSystemDefaultLanguage()
      log_format("VersionUpdateUI:AfterFinishedUpdate. lang=%s", lang)
      if not LanguageDownload.GetResExist(lang) then
        local resPath = LanguageDownload.GetLocalizationResPath(lang)
        local pakName = Client.GetODPakName(resPath)
        if pakName and pakName ~= "" then
          local PufferUA = PufferDownloader.GetPufferUA(0)
          PufferDownloader.langDownloadTaskID = GCPufferDownloader.RequestFile(Puffer, pakName, true, PufferUA)
          log_format("VersionUpdateUI:AfterFinishedUpdate. PufferDownloader.langDownloadTaskID=%s", PufferDownloader.langDownloadTaskID)
          local time_ticker = require("common.time_ticker")
          time_ticker.AddTimerOnce(10, function()
            PufferDownloader.langDownloadTaskID = -1
            log(bWriteLog and "VersionUpdateUI:AfterFinishedUpdate FIT lang download time out")
            self:GoToNextStepLogin()
          end)
          return
        end
      else
        LanguageDownload.SetCurrentLanguageAndLocale(lang)
      end
    end
  end
  self:GoToNextStepLogin()
end
function VersionUpdateUI:GoToNextStepLogin()
  log(bWriteLog and "VersionUpdateUI:GoToNextStepLogin")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local isIOS = Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  local val = version_up_module:GetGEnableShaderGroupAsync()
  log_format("VersionUpdateUI:GoToNextStepLogin, isIOS: %s, val: %s", isIOS, val)
  if isIOS and val == 1 then
    local pct = Client.EnableShaderFinishPersent()
    log_format("VersionUpdateUI:GoToNextStepLogin, Shader decompression progress: %s", pct)
    if pct < 1 then
      self:UpdateShaderDecompressing()
      return
    end
  end
  if self.gray then
    if self.callbackAfterGrayUpdate then
      self.callbackAfterGrayUpdate()
      self.callbackAfterGrayUpdate = nil
    end
    self.gray = false
    self:CloseSelf()
  else
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:Transition(login_module.ELoginFSMEvent.Event_VUTL)
  end
end
function VersionUpdateUI:UpdateShaderDecompressing()
  log(bWriteLog and "VersionUpdateUI:UpdateShaderDecompressing")
  self.currentStage = "ShaderDecompressing"
  self:UpdateTextByStage()
  self:RemoveCheckUpdateTimer()
  local testPct = 0
  self.TextBlock_State:SetWidgetVisibility(SelfHitTestInvisible)
  self.shaderDecompressingTimer = self:AddTimerLoop(0, function()
    local pct = Client.EnableShaderFinishPersent()
    testPct = testPct + 0.02
    if 1 <= testPct then
      testPct = 0.99
    end
    log_format("VersionUpdateUI:UpdateShaderDecompressing, Shader decompression progress: %s", pct)
    if 1 <= pct then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.SaveTableToFile_N({
        version = Client.GetAppVersion()
      }, PlayerPrefsSystem.ePlayerPrefsType.eShaderDecompressingVersion)
      self:RemoveTimer(self.shaderDecompressingTimer)
      self.shaderDecompressingTimer = nil
      self:GoToNextStepLogin()
      return
    end
    log_format("VersionUpdateUI:UpdateShaderDecompressing. testPct=%s", testPct)
    self:UpdateProgressBar(testPct * 100, false)
  end, TIMER_INFINITE, 1)
end
function VersionUpdateUI:ShowRichTextLoadingTip(isShow)
  log(bWriteLog and "VersionUpdateUI:ShowRichTextLoadingTip " .. tostring(isShow))
  if self.UIRoot.UpdateTips:GetVisibility() ~= Hidden then
    self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(Hidden)
    return
  end
  if self.TextBlock_DownloadSpeed:GetVisibility() == SelfHitTestInvisible then
    self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(Hidden)
    return
  end
  if isShow then
    self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(SelfHitTestInvisible)
  else
    self.UIRoot.RichText_LoadingTip:SetWidgetVisibility(Hidden)
  end
end
function VersionUpdateUI:UpdateStageText(text)
  self.TextBlock_State:SetText(text)
  if text ~= LocUtil.GetLocalizeResStr(201018) then
    self:RemoveCheckUpdateTimer()
  end
end
function VersionUpdateUI:UpdateDownloadSpeedSizeInfo(nowSize, totalSize, curStage)
  printf("VersionUpdateUI:UpdateDownloadSpeedSizeInfo. nowSize=%s, totalSize=%s, curStage=%s", tostring(nowSize), tostring(totalSize), tostring(curStage))
  if not (self.useNewComp and nowSize) or not totalSize then
    return
  end
  self.secondDownloadCurStage = curStage
  self.secondDownloadCurSize = nowSize
  self.secondDownloadTotalSize = totalSize
  if self.calculateSpeedState == 0 then
    self.calculateSpeedState = 1
  end
end
function VersionUpdateUI:UpdateProgressBar(percent, isPrecompile)
  self.UIRoot.HorizontalBox_VersionSizeInfo:SetWidgetVisibility(Hidden)
  self.UIRoot.ProgressBar_Update:SetPercent(percent / 100)
  if isPrecompile then
    log_warning(bWriteLog and "  . UpdateProgressBar  isPrecompile")
    self:RemoveCheckUpdateTimer()
  end
  if 0 < percent then
    if isPrecompile then
      self.UIRoot.CanvasPanel_CarRoot:SetWidgetVisibility(SelfHitTestInvisible)
      local UIUtil = require("client.common.ui_util")
      local localSize = UIUtil.GetLocalSize(self.UIRoot.CanvasPanel_CarRoot)
      self.UIRoot.CanvasPanel_Car.Slot:SetPosition(FVector2D(percent * localSize.X / 100, 18.131989))
      local text = LocUtil.LocalizeResFormat(101723, tostring(math.floor(percent)))
      self.TextBlock_State:SetText(text)
    else
      self.UIRoot.CanvasPanel_CarRoot:SetWidgetVisibility(Collapsed)
    end
    if self.gray then
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_UPDATE_BACKGROUND_IMAGE, true)
      self.UIRoot.GridPanel_UpdateUI:SetWidgetVisibility(SelfHitTestInvisible)
    end
    if self.UIRoot.GridPanel_UpdateUI:IsVisible() then
      logic_connection_waiting:Hide(0)
    end
  end
end
function VersionUpdateUI:CancelUpdate()
  log(bWriteLog and "VersionUpdateUI:CancelUpdate")
  if self.versionInfo.isAppUpdating == "2" then
    Client.DisableRepairResource(GameFrontendHUD)
    if self.versionInfo.isGrayUpdate ~= "1" then
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      login_module:SetIgnoreResourceVersion(self.versionInfo.versionString)
    end
  end
  logic_connection_waiting:Hide(0)
  Client.CrashLog(NetInterface, 4, "Login", "UpdateFinish")
  local updater = self:GetUpdater()
  if updater then
    updater:CancelUpdate()
  else
    self:GoToNextStepLogin()
  end
end
function VersionUpdateUI:GetUpdater()
  local updater = slua_GameFrontendHUD:GetUpdater()
  if updater == nil then
    log(bWriteLog and "VersionUpdateUI:GetUpdater, result = " .. tostring(updater))
  end
  return updater
end
function VersionUpdateUI:OnClose()
  log(bWriteLog and "VersionUpdateUI:OnClose")
  self:ClosePlayer()
  logic_connection_waiting:Hide(0)
  self:TryHideNotices()
  local time_step_macros = require("client.slua.logic.performance.time_step_macros")
  local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
  logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.UpdatePatchStartToUpdatePatchEnd)
  logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.UpdatePatchEndToLoginUIShow)
  VersionUpdateUI.__super.OnClose(self)
end
function VersionUpdateUI:OnHide()
  log(bWriteLog and "VersionUpdateUI:OnHide")
  self.bShowing = false
  VersionUpdateUI.__super.OnHide(self)
end
function VersionUpdateUI:OnPufferInitialize()
  self:UpdateBackgroundByCDNImage()
end
function VersionUpdateUI:PlayCurVersionVideo()
  local version_util = require("client.common.version_util")
  local versionNum = version_util.GetCurVersionNumber()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local videoPath = ""
  local exts = {""}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    exts = {"_IN", ""}
  end
  for i = 0, 4 do
    for _, ext in ipairs(exts) do
      local path = "./MoviesPakDir/VersionUpdate_" .. tostring(versionNum - i * 100) .. tostring(ext) .. ".mp4"
      if VideoLibrary.IsVideoFileReady(path) then
        log_format("VersionUpdateUI:PlayCurVersionVideo. find videoPath=%s", tostring(path))
        videoPath = path
        break
      end
    end
    if videoPath ~= "" then
      break
    end
  end
  if videoPath == "" then
    log_format("VersionUpdateUI:PlayCurVersionVideo. not find videoPath")
    return
  end
  self:PlayVideo(videoPath)
end
function VersionUpdateUI:PlayVideo(videoPath)
  printf("VersionUpdateUI:PlayVideo. videoPath=%s", tostring(videoPath))
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if VideoLibrary.IsVideoFileReady(videoPath) then
    printf("VersionUpdateUI:PlayVideo. filePath=%s", tostring(videoPath))
    self:PlayNormalLocalVideo(self.UIRoot.MediaContainer, videoPath)
    local player = self:GetNormalLocalVideo()
    if player and player.SetLooping then
      player:SetLooping(true)
    end
  else
    printf("VersionUpdateUI:PlayVideo. video is not ready")
  end
end
function VersionUpdateUI:OnMediaPlayerOpenFail()
  log_format("VersionUpdateUI:OnMediaPlayerOpenFail.")
  self:ClosePlayer()
end
function VersionUpdateUI:OnMediaOpenFailed()
  log_format("VersionUpdateUI:OnMediaOpenFailed.")
  self:ClosePlayer()
end
function VersionUpdateUI:OnSetMediaContentResolution()
  log_format("VersionUpdateUI:OnSetMediaContentResolution.")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Details, true)
end
function VersionUpdateUI:OnClickButton_Bulletin()
  printf("VersionUpdateUI:OnClickButton_Bulletin.")
  self:PlayAudio(sound_config.click_v1)
  self:TryShowNotices()
end
function VersionUpdateUI:TryShowNotices()
  printf("VersionUpdateUI:TryShowNotices")
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  local CanShowNotice = NoticesModule:CanShowNotice(NoticesConst.Scene.VersionUpdate)
  if CanShowNotice then
    self:PausePlay()
    NoticesModule:ShowNotice(NoticesConst.Scene.VersionUpdate)
  end
end
function VersionUpdateUI:TryHideNotices()
  printf("VersionUpdateUI:TryHideNotices")
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  NoticesModule:ClearNoticesScene()
  UIManager.CloseUI(UIManager.UI_Config.Notices_Main_UIBP)
end
function VersionUpdateUI:PausePlay()
  printf("VersionUpdateUI:PausePlay.")
  self:NormalLocalVideoPause()
end
function VersionUpdateUI:ResumePlay()
  printf("VersionUpdateUI:ResumePlay.")
  self:NormalLocalVideoResume()
end
function VersionUpdateUI:ClosePlayer()
  printf("VersionUpdateUI:ClosePlayer.")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Details, false)
  self:ReleaseResource(self.UIRoot.MediaContainer)
end
function VersionUpdateUI:TouchTransMissionStart()
  log_format("VersionUpdateUI:TouchTransMissionStart")
  self.currentStage = "TouchTransMissionStart"
  self.TextBlock_SizeInfo:SetText("")
  self:UpdateTextByStage()
end
function VersionUpdateUI:TouchTransMissionProgress(copiedBytes, totalBytes)
  log_format("VersionUpdateUI:TouchTransMissionProgress. copiedBytes=%s, totalBytes=%s", copiedBytes, totalBytes)
  self.currentStage = "TouchTransMissionProgress"
  self:UpdateTextByStage()
  local percent = 0
  if 0 < totalBytes then
    percent = copiedBytes * 100 / totalBytes
  end
  self:UpdateProgressBar(percent, false)
end
function VersionUpdateUI:TouchTransMissionEnd(success)
  log_format("VersionUpdateUI:TouchTransMissionEnd. success=%s", success)
  self.currentStage = "TouchTransMissionEnd"
  self:UpdateTextByStage()
end
local ui_base = require("client.slua_ui_framework.base")
local Trait = require("common.trait")
local Traits = {
  require("client.slua.umg.common.video.video_trait")
}
local CVersionUpdateUI = Trait.TraitClass(ui_base, nil, VersionUpdateUI, Traits)
return CVersionUpdateUI