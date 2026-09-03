local common_download_ui = {}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local MIN_SHOW_SIZE = 32.3
local MAX_SHOW_SIZE = 35
local DEFAULT_ALIGN_PARAMS = {Align = 1}
local TextPosDefault = FVector2D(0, 32)
local CENTER_ANCHORS = FAnchors(0.5, 0.5, 0.5, 0.5)
local CENTER_ALIGNMENT = FVector2D(0.5, 0.5)
local CENTER_PADDING = FMargin(0, 0, 0, 0)
local CENTER_POSITION = FVector2D(0, 0)
local DEFAULT_ANCHORS = FAnchors(0, 1, 0, 1)
local DEFAULT_ALIGNMENT = FVector2D(0, 1)
local DEFAULT_PADDING = FMargin(0, 0, 10, 0)
local DEFAULT_POSITION_SHOW_GRAY = FVector2D(78, -40)
local DEFAULT_POSITION_NO_GRAY = FVector2D(2, -2)
local DEFAULT_SLOT_ANCHORS = FAnchors(0, 0, 1, 1)
local DEFAULT_SLOT_PADDING = FMargin(0, 0, 0, 0)
local DEFAULT_TEXT_COLOR = FSlateColor(FLinearColor(1, 1, 1, 1))
local DEFAULT_PROGRESS_MASK_COLOR = FLinearColor(0, 0, 0, 0.35)
function common_download_ui:OnInitialize()
  printf("common_download_ui:OnInitialize.")
end
function common_download_ui:RegistEvents()
  self:AddControlEvent(self.Button_Download, "OnClicked", self.OnClickDownload, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTTYPE_TRIGGER_DOWNLOAD_CLICK, self.OnTriggerDownload, self)
end
function common_download_ui:OnClose()
  printf("common_download_ui:OnClose.")
  self:ResetData()
end
function common_download_ui:Initialize()
  printf("common_download_ui:Initialize.")
end
function common_download_ui:OnDestroy()
  printf("common_download_ui:OnDestroy.")
end
function common_download_ui:RemoveRefreshTimer()
  log(bWriteLog and "common_download_ui:RemoveRefreshTimer.")
  if self.timer then
    self:RemoveTimer(self.timer)
    self.timer = nil
  end
end
function common_download_ui:ResetData()
  self.callback = nil
  self.bHideMask = nil
  self.bHideButton = nil
  self.bShowProgress = nil
  self.useVerProgress = nil
  self.bHideProgressText = nil
  self.progressMaskColor = nil
  self.bShowSize = nil
  self.bHideIconBg = nil
  self.askTips = nil
  self.showDownloadTipsFunc = nil
  self.nSize = nil
  self.textContent = nil
  self.textContentColor = nil
  self.vecPos = nil
  self.textPos = nil
  self.textFillRect = nil
  self.uCanvasTextAlignment = nil
  self.uCanvasTextAnchors = nil
  self.clickCallback = nil
  self.from = nil
  self.bShowGray = nil
  self.isSpecial = nil
  self.is3DUI = nil
  self.isInCenter = nil
  self.skipSetTextPos = nil
  self.customGetSizeFunc = nil
  self.is_limit_time = false
  self.item_time_limit = 0
  self.disableClickDownLoadPutOn = false
  self.showTextBg = false
  self.useNewAni = false
  self.useNewProgress = false
  self.showImageLoop = false
  self.showWaitState = false
  self.ProgressBar = nil
  self.fakeSize = 0
  self.showAlertSize = false
  self.nResDownloadScene = nil
  self.progressFillType = nil
  self.UseGradationBg = false
  self.data = nil
  self.downloadTypeInfo = nil
end
function common_download_ui:SetData(downloadType, data, params)
  self.bIsMixDownloadType = false
  if downloadType == nil and data and next(data) then
    local downloadTypeInfo = {}
    local typeCount = 0
    local lastDownloadType
    for k, v in ipairs(data) do
      local type = PufferManager.GetDownloadType(v) or PufferConst.ENUM_DownloadType.ODPAK
      if not downloadTypeInfo[type] then
        downloadTypeInfo[type] = {v}
        typeCount = typeCount + 1
        lastDownloadType = type
      else
        table.insert(downloadTypeInfo[type], v)
      end
    end
    if 1 < typeCount then
      self.bIsMixDownloadType = true
      self.    elseif typeCount == 1 then
      downloadType = lastDownloadType
    end
  end
  self.  self.  self.pakName = ""
  self.oldState = nil
  self.state = nil
  self.curSize = 0
  self.totalSize = 0
  if params then
    self.callback = params.callback
    self.bHideMask = params.hideMask
    self.bHideButton = params.hideButton
    self.bShowProgress = params.showProgress
    self.bHideProgressText = params.hideProgressText
    self.progressMaskColor = params.progressMaskColor
    self.bShowSize = params.showSize
    self.bHideIconBg = params.hideIconBg
    self.askTips = params.askTips
    self.showDownloadTipsFunc = params.showDownloadTipsFunc
    self.nSize = params.size
    self.textContent = params.textContent
    self.textContentColor = params.textContentColor
    self.vecPos = params.pos
    self.textPos = params.textPos
    self.textFillRect = params.textFillRect
    self.uCanvasTextAlignment = params.uCanvasTextAlignment
    self.uCanvasTextAnchors = params.uCanvasTextAnchors
    self.clickCallback = params.clickCallback
    self.from = params.from
    self.bShowGray = params.showGray
    self.isSpecial = params.isSpecial
    self.is3DUI = params.is3DUI
    self.isInCenter = params.isInCenter
    self.skipSetTextPos = params.skipSetTextPos
    self.customGetSizeFunc = params.customGetSizeFunc
    self.is_limit_time = params.is_limit_time
    self.item_time_limit = params.item_time_limit
    self.disableClickDownLoadPutOn = params.disableClickDownLoadPutOn
    self.showTextBg = params.showTextBg
    self.showImageLoop = params.showImageLoop
    self.showWaitState = params.showWaitState
    self.useVerProgress = params.useVerProgress
    self.showAlertSize = params.showAlertSize
    self.nResDownloadScene = params.nResDownloadScene
    self.progressFillType = params.progressFillType
    self.UseGradationBg = params.useGradationBg
    if params.useNewAni ~= nil then
      self.useNewAni = params.useNewAni
    else
      self.useNewAni = self.bShowSize
    end
    if params.useNewProgress ~= nil then
      self.useNewProgress = params.useNewProgress
    else
      self.useNewProgress = false
    end
  end
  self:UpdateUI()
  self:CheckFinishDownload()
  if self.Slot and self.Slot.SetAnchors then
    self.Slot:SetAnchors(DEFAULT_SLOT_ANCHORS)
    self.Slot:SetOffsets(DEFAULT_SLOT_PADDING)
  end
end
function common_download_ui:SetStateAndSize()
  self.oldState = self.state
  if self.bIsMixDownloadType then
    local state = PufferConst.ENUM_DownloadState.Done
    for downloadType, keyList in pairs(self.downloadTypeInfo) do
      local typeState = PufferManager.GetState(downloadType, keyList)
      state = PufferManager.GetMixDownloadState(state, typeState)
    end
    self.  else
    self.state = PufferManager.GetState(self.downloadType, self.data)
  end
  if self.data == PufferConst.EODPackID.DIY and self.state == PufferConst.ENUM_DownloadState.Done then
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    self.state = weapon_diy_system.GetDIYDownloadState()
  end
  if self.state == PufferConst.ENUM_DownloadState.Done then
    if self.Panel_Download then
      self.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self:RemoveRefreshTimer()
  end
  if self.customGetSizeFunc then
    local curSize, totalSize = PufferManager.GetSize(self.downloadType, self.data)
    self.totalSize = totalSize / PufferConst.MB
    self.curSize = curSize / PufferConst.MB
  elseif self.bIsMixDownloadType then
    self.curSize = 0
    self.totalSize = 0
    for downloadType, keyList in pairs(self.downloadTypeInfo) do
      local curSize, totalSize = PufferManager.GetSize(downloadType, keyList)
      self.curSize = self.curSize + curSize / PufferConst.MB
      self.totalSize = self.totalSize + totalSize / PufferConst.MB
    end
  else
    local curSize, totalSize = PufferManager.GetSize(self.downloadType, self.data)
    self.totalSize = totalSize / PufferConst.MB
    self.curSize = curSize / PufferConst.MB
  end
end
function common_download_ui:UpdateUI(isClick)
  self:ResetDownloadText()
  self:SetStateAndSize()
  if self.state == PufferConst.ENUM_DownloadState.Done then
    return
  end
  self:RefreshGray()
  self:RefreshMask(isClick)
  self:RefreshSize()
  self:RefreshPos()
  self:RefreshTextPos()
  self:RefreshGradationBg()
  self:AddTimerOnce(0, function()
    if not isClick then
      self:AutoDownload()
    end
    self:RefreshDownloadState()
    self:RefreshButton()
    self:RefreshDownloadSize()
    self:RefreshDownloadProgress()
    self:RefreshIconBg()
  end)
  self:RemoveRefreshTimer()
  self.timer = self:AddTimerLoop(1, function()
    if not self or not slua.isValid(self.CanvasPanel_State) then
      return
    end
    self:SetStateAndSize()
    self:RefreshDownloadState()
    self:RefreshButton()
    self:RefreshDownloadSize()
    self:RefreshDownloadProgress()
    self:CheckFinishDownload()
  end, TIMER_INFINITE, 0.5)
end
function common_download_ui:AutoDownload()
  if PufferSwitch.BanAutoDownload then
    return
  end
  if self.downloadType == PufferConst.ENUM_DownloadType.ODPAK and #self.data == 1 and type(self.data[1]) == "number" then
    local itemID = self.data[1]
    if self.state == PufferConst.ENUM_DownloadState.Not or self.state == PufferConst.ENUM_DownloadState.Wait or self.state == PufferConst.ENUM_DownloadState.Pause then
      do
        local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
        local fromType = PufferTlog.Enum_TLog_From.Auto
        if self.from then
          fromType = self.from
        end
        local extraData = {
          bAutoDownload = true,
          bDownloadAutoPutOn = self.disableClickDownLoadPutOn
        }
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, self.data, fromType, function()
          if self:CheckUIAndDataWithDownload() then
            EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_WEAR_AUTO_DOWNLOAD, itemID, extraData)
          end
        end, extraData)
      end
    end
  end
end
function common_download_ui:_GetShowState(state)
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  if state == ENUM_DownloadState.Wait and not self.showWaitState then
    state = ENUM_DownloadState.Download
  end
  if state == ENUM_DownloadState.Not and self.curSize and self.curSize > 0 then
    state = ENUM_DownloadState.Pause
  end
  return state
end
function common_download_ui:UpdateStateWidget(state)
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  state = self:_GetShowState(state)
  local widgetIndex = 0
  local path
  self.Image_State:SetIsEnabled(true)
  if self.useNewAni and state ~= ENUM_DownloadState.Error then
    widgetIndex = 1
    if state == ENUM_DownloadState.Done then
      self:SetWidgetVisible(self.ScaleBox_Ani, false)
    else
      self:SetWidgetVisible(self.ScaleBox_Ani, true)
      if state == ENUM_DownloadState.Download then
        self:PlayUserWidgetAnimation(self.Anim_Loop01, 0, 0, 0, 1)
      else
        self:StopAnimation(self.Anim_Loop01)
      end
    end
    self:SetWidgetVisible(self.Image_Loop, self.showImageLoop)
  else
    self:StopAnimation(self.Anim_Loop01)
    local util = require("client.slua_ui_framework.util")
    if state == ENUM_DownloadState.Download then
      if self.is3DUI then
        path = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Common_Icon_DL_DLing_png.Common_Icon_DL_DLing_png"
      elseif self.useNewAni then
        path = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Pause_png.Common_Icon_Pause_png"
      else
        path = "/Game/UMG/Texture_200/Atlas/Detail/Frames/Common_But_Pause_png.Common_But_Pause_png"
      end
    elseif state == ENUM_DownloadState.Not then
      path = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png"
    elseif state == ENUM_DownloadState.Pause then
      if self.bShowSize then
        path = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_But_Cache_png.Common_But_Cache_png"
      else
        path = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png"
      end
    elseif state == ENUM_DownloadState.Error then
      path = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_xiazai_02_png.Setting_icon_xiazai_02_png"
    end
    util.SetTexture(self.Image_State, path, {sync = false})
    self:SetWidgetVisible(self.Image_State, true)
  end
  self.WidgetSwitcher_State:SetActiveWidgetIndex(widgetIndex)
  self:SetWidgetVisible(self.WidgetSwitcher_State, state ~= ENUM_DownloadState.Done)
end
function common_download_ui:RefreshDownloadState()
  if not slua.isValid(self.CanvasPanel_State) then
    return
  end
  self:_initProgressBar()
  self.CanvasPanel_State:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.Text_Progress:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.WidgetSwitcher_State:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  local percent = 1
  local needUpdate = false
  if self.state == ENUM_DownloadState.Download or self.bShowSize and self.state == ENUM_DownloadState.Wait then
    self.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.bShowProgress then
      if self.downloadType == PufferConst.ENUM_DownloadType.RES then
        local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
        percent = PufferResManager:GetPercentByKeyList(self.data)
        percent = percent / 1000
      elseif self.downloadType == PufferConst.ENUM_DownloadType.MAP then
        if self.totalSize > 0 then
          percent = self.curSize / self.totalSize
        end
      elseif (self.downloadType == PufferConst.ENUM_DownloadType.ODPAK or self.downloadType == PufferConst.ENUM_DownloadType.ODPACK or self.bIsMixDownloadType) and self.totalSize > 0 then
        percent = self.curSize / self.totalSize
      end
      if not self.bHideProgressText and self.downloadType ~= PufferConst.ENUM_DownloadType.RES then
        self.Text_Progress:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local strPer = string.format("%.1f", percent * 100)
        local str = LocUtil.LocalizeResFormat(20082, strPer)
        self.Text_Progress:SetText(str)
      end
      if self.oldState ~= self.state then
        self:UpdateStateWidget(self.state)
      end
      needUpdate = true
    elseif self.oldState ~= self.state then
      if self.is3DUI then
        self:UpdateStateWidget(ENUM_DownloadState.Download)
      elseif self.bShowSize or self.useNewAni then
        self:UpdateStateWidget(self.state)
      else
        self:UpdateStateWidget(ENUM_DownloadState.Done)
      end
    end
  elseif self.oldState ~= self.state then
    if self.state == ENUM_DownloadState.Not or self.state == ENUM_DownloadState.Pause or self.state == ENUM_DownloadState.Wait then
      self.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if 0 < self.curSize then
        self:UpdateStateWidget(ENUM_DownloadState.Pause)
      else
        self:UpdateStateWidget(ENUM_DownloadState.Not)
      end
      percent = 0
      if self.state ~= ENUM_DownloadState.Not and self.totalSize and self.totalSize > 0 then
        percent = self.curSize / self.totalSize
      end
      needUpdate = true
    elseif self.state == ENUM_DownloadState.Error then
      self:UpdateStateWidget(ENUM_DownloadState.Error)
      self.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self:UpdateStateWidget(ENUM_DownloadState.Done)
      self.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:RemoveRefreshTimer()
    end
  end
  if needUpdate and self.bShowProgress then
    self:_SetProgressBarPercent(percent)
  end
end
function common_download_ui:_SetProgressBarPercent(percent)
  log_format("common_download_ui:_SetProgressBarPercent. percent=%s", percent)
  if not self.useNewProgress and self.progressFillType ~= 0 then
    percent = 1 - percent
  end
  self.ProgressBar:SetPercent(percent)
end
function common_download_ui:RefreshIconBg()
  if self.Image_State_Bg == nil then
    return
  end
  self:SetWidgetVisible(self.Image_State_Bg, not self.bHideIconBg)
end
function common_download_ui:RefreshDownloadProgress()
  local dynamicMaterial
  if self.Image_Progress_2 == nil then
    return
  end
  local state = self.state
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  state = self:_GetShowState(state)
  local isPause = state == ENUM_DownloadState.Pause
  self.Panel_Progress_2:SetIsEnabled(not isPause)
  if not (isPause or state == ENUM_DownloadState.Download or self.bShowSize) or self.bShowProgress then
    self:_UpdateProgress2Visible(false, false)
  else
    dynamicMaterial = self.Image_Progress_2:GetDynamicMaterial()
    if self.bShowSize then
      self:_UpdateProgress2Visible(state ~= ENUM_DownloadState.Error, self.useNewAni)
    else
      self:_UpdateProgress2Visible(true, true)
    end
    local percent = 1
    local imageShow = false
    if self.totalSize > 0 then
      percent = self.curSize / self.totalSize
      if isPause then
        imageShow = self.curSize == 0
      end
    end
    self:SetWidgetVisible(self.Image_State, imageShow)
    if dynamicMaterial then
      dynamicMaterial:SetScalarParameterValue("Mask_Percent", percent)
      dynamicMaterial:SetScalarParameterValue("InternalRadius", 0.38)
    end
  end
  self.Image_State:SetIsEnabled(not isPause)
end
function common_download_ui:_UpdateProgress2Visible(show, bgShow)
  self:SetWidgetVisible(self.Image_Progress_2, show)
  self:SetWidgetVisible(self.Image_Progress_2_Bg, bgShow)
end
function common_download_ui:ResetDownloadText()
  if not self.Text_Download then
    return
  end
  self.Text_Download:SetText("")
end
function common_download_ui:RefreshDownloadSize()
  if not self.Text_Download then
    return
  end
  if self.bShowSize then
    self.Text_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Text_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if self.textContent then
    self.Text_Download:SetText(self.textContent)
  else
    local strCurSize, strTotalSize
    local displayOptimizedSize = false
    if displayOptimizedSize then
      strTotalSize = string.format("%.1f", MIN_SHOW_SIZE + self.fakeSize)
    elseif self.totalSize <= 0.1 then
      strTotalSize = "0.1"
    else
      strTotalSize = string.format("%.1f", self.totalSize)
    end
    local sizeText = ""
    if self.useNewAni then
      local remainSize = self.totalSize - self.curSize
      if displayOptimizedSize then
        remainSize = (MIN_SHOW_SIZE + self.fakeSize) * remainSize / self.totalSize
      end
      if remainSize < 0.1 then
        remainSize = 0.1
      end
      strCurSize = string.format("%.1f", remainSize)
      sizeText = LocUtil.LocalizeResFormat(32712, strCurSize)
    elseif self.curSize > 0 then
      if displayOptimizedSize then
        strCurSize = string.format("%.1f", (MIN_SHOW_SIZE + self.fakeSize) * self.curSize / self.totalSize)
      else
        strCurSize = string.format("%.1f", self.curSize)
      end
      sizeText = LocUtil.LocalizeResFormat(37442, strCurSize, strTotalSize)
    else
      sizeText = LocUtil.LocalizeResFormat(32712, strTotalSize)
    end
    if not Client.IsReleaseVersion(NetInterface) and PufferDownloader.TestSizeStr ~= nil then
      sizeText = PufferDownloader.TestSizeStr
    end
    self.Text_Download:SetText(sizeText)
  end
  if self.textContentColor then
    self.Text_Download:SetColorAndOpacity(self.textContentColor)
  else
    self.Text_Download:SetColorAndOpacity(DEFAULT_TEXT_COLOR)
  end
end
function common_download_ui:RefreshGray()
  if self.bShowGray or self.showTextBg then
    self.Image_Gray:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.Image_Gray:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function common_download_ui:RefreshButton()
  if not self.Button_Download or not slua.isValid(self.Button_Download) then
    return
  end
  if self.Progress then
    self.Button_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    return
  end
  if self.bHideButton then
    self.Button_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  self.Button_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function common_download_ui:RefreshPos()
  if not self.HorizontalBox_0 then
    return
  end
  if not self.HorizontalBox_0.Slot then
    return
  end
  if self.isInCenter then
    self.HorizontalBox_0.Slot:SetAnchors(CENTER_ANCHORS)
    self.HorizontalBox_0.Slot:SetAlignment(CENTER_ALIGNMENT)
    self.HorizontalBox_0.Slot:SetPosition(self.vecPos or CENTER_POSITION)
    self.CanvasPanel_State.Slot:SetPadding(CENTER_PADDING)
  else
    self.HorizontalBox_0.Slot:SetAnchors(DEFAULT_ANCHORS)
    self.CanvasPanel_State.Slot:SetPadding(DEFAULT_PADDING)
    self.HorizontalBox_0.Slot:SetAlignment(DEFAULT_ALIGNMENT)
    if self.vecPos then
      self.HorizontalBox_0.Slot:SetPosition(self.vecPos)
    elseif self.bShowGray then
      self.HorizontalBox_0.Slot:SetPosition(DEFAULT_POSITION_SHOW_GRAY)
    else
      self.HorizontalBox_0.Slot:SetPosition(DEFAULT_POSITION_NO_GRAY)
    end
  end
end
function common_download_ui:RefreshTextPos()
  if self.skipSetTextPos then
    return
  end
  if not self.SrcTextPos and self.CanvasPanel_Text and self.CanvasPanel_Text.Slot and self.CanvasPanel_Text.Slot.GetPosition then
    self.SrcTextPos = self.CanvasPanel_Text.Slot:GetPosition()
  end
  if self.CanvasPanel_Text then
    local ScaleBoxSlot = self.CanvasPanel_Text.Slot
    ScaleBoxSlot:SetAutoSize(not self.textFillRect)
    if self.textFillRect and self.textFillRect.Pos and self.textFillRect.Size then
      ScaleBoxSlot:SetPosition(self.textFillRect.Pos)
      ScaleBoxSlot:SetSize(self.textFillRect.Size)
    elseif self.SrcTextPos ~= nil then
      ScaleBoxSlot:SetPosition(self.SrcTextPos)
    end
    if self.uCanvasTextAlignment then
      ScaleBoxSlot:SetAlignment(self.uCanvasTextAlignment)
    else
      ScaleBoxSlot:SetAlignment(CENTER_ALIGNMENT)
    end
    if self.uCanvasTextAnchors then
      ScaleBoxSlot:SetAnchors(self.uCanvasTextAnchors)
    else
      ScaleBoxSlot:SetAnchors(CENTER_ANCHORS)
    end
  end
  if self.SizeBox_Text then
    if self.textFillRect and self.textFillRect.Size then
      self.SizeBox_Text:SetMinDesiredWidth(self.textFillRect.Size.X)
    else
      self.SizeBox_Text:ClearMinDesiredWidth()
    end
  end
  local TextDownloadSlot = self.CanvasPanel_Text and self.CanvasPanel_Text.Slot
  if TextDownloadSlot and TextDownloadSlot.SetPosition then
    local textPos = TextPosDefault
    if self.textPos then
      textPos = FVector2D(self.textPos.X, self.textPos.Y + 32)
    end
    if self.textFillRect and self.textFillRect.Pos then
      textPos = self.textFillRect.Pos
    end
    TextDownloadSlot:SetPosition(FVector2D(textPos.X, textPos.Y))
  end
  if self.textFillRect and type(self.textFillRect.Align) == "number" then
    self.Text_Download:SetJustification(self.textFillRect.Align)
  else
    self.Text_Download:SetJustification(DEFAULT_ALIGN_PARAMS.Align)
  end
end
function common_download_ui:RefreshGradationBg()
  if self.UseGradationBg then
    log(bWriteLog and "common_download_ui:RefreshGradationBg")
    self:SetWidgetVisible(self.WidgetSwitcher_ProgressBar, true)
    self.WidgetSwitcher_ProgressBar:SetActiveWidgetIndex(2)
  end
end
function common_download_ui:RefreshSize()
  local UIUtil = require("client.common.ui_util")
  local size = self.nSize or 28
  local progressSize = size - 1
  if self.useNewAni then
    progressSize = size
    size = size * 0.9 // 1
    local padding = size // 8
    self.CanvasPanel_Ani.Slot:SetPadding(FMargin(padding, padding, padding, padding))
  end
  UIUtil.SetSize(self.WidgetSwitcher_State, size, size)
  local bgSize = size
  UIUtil.SetSize(self.Panel_Progress_2, progressSize, progressSize)
  UIUtil.SetSize(self.Image_State_Bg, bgSize, bgSize)
end
function common_download_ui:_initProgressBar()
  if self.ProgressBar then
    return
  end
  self.ProgressBar = self.ProgressBar_Mask
  printf("common_download_ui:_initProgressBar")
  if self.useNewProgress then
    self.ProgressBar = self.ProgressBar_Ani
  else
    local BarFillType = self.ProgressBar.BarFillType
    local pre    if self.useVerProgress then
      BarFillType = 4
    else
      BarFillType = 1
    end
    if self.progressFillType then
      BarFillType = self.progressFillType
    end
    if preBarFillType ~= BarFillType then
      printf("common_download_ui:_initProgressBar. BarFillType=%s", tostring(BarFillType))
      self.ProgressBar.      local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
      if UCreativeModeBlueprintLibrary.SynchronizePropertiesWidget then
        UCreativeModeBlueprintLibrary.SynchronizePropertiesWidget(self.ProgressBar)
      end
    end
  end
end
function common_download_ui:RefreshMask(isClick)
  self:SetWidgetVisible(self.WidgetSwitcher_ProgressBar, not self.bHideMask, false)
  if not self.bHideMask then
    self.ProgressBar = nil
    self:ReplaceSource()
    if not isClick and not self.bShowProgress then
      self:_SetProgressBarPercent(0)
    end
  end
end
function common_download_ui:OnClickDownload()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local fromType = PufferTlog.Enum_TLog_From.Click
  if self.from then
    fromType = self.from
  end
  local ENUM_DownloadType = PufferConst.ENUM_DownloadType
  if self.state == PufferConst.ENUM_DownloadState.Download or self.bShowSize and self.state == PufferConst.ENUM_DownloadState.Wait then
    if self.bIsMixDownloadType then
      for downloadType, keyList in pairs(self.downloadTypeInfo) do
        PufferManager.Pause(downloadType, keyList)
      end
    else
      PufferManager.Pause(self.downloadType, self.data)
    end
    if self.downloadType == ENUM_DownloadType.MAP then
      ShowNotice(34993)
    end
  else
    if not PufferDownloader.InitSuccess then
      PufferDownloader.ShowPufferInitProgressNotice()
    end
    local callbackFunc = function()
      self:CheckFinishDownload()
    end
    local remainSize = self.totalSize - self.curSize
    local nResDownloadScene = self.nResDownloadScene
    if nResDownloadScene then
      local sTLogStr = string.format("Scene:%s_Size:%s", nResDownloadScene, remainSize)
      local TLogReportUtils = require("client.slua.config.tlog.tlog_report_utils")
      TLogReportUtils.ReportTLogEvent(TLogEventDefine.CommonDownloadUI_ClickStartDownload, 0, sTLogStr)
    end
    if self.bIsMixDownloadType then
      for downloadType, keyList in pairs(self.downloadTypeInfo) do
        local extraData
        if self.downloadType ~= ENUM_DownloadType.UGCPAK and self.downloadType ~= ENUM_DownloadType.UGCPACK then
          extraData = {bFirst = true}
        end
        PufferManager.Download(downloadType, keyList, fromType, callbackFunc, extraData)
      end
    else
      local extraData = {
        bSkipPopUp = true,
        nResDownloadScene = nResDownloadScene,
        nNeedDownloadSize = remainSize
      }
      local askTips = self.askTips
      local showDownloadTips = askTips ~= nil
      if self.showDownloadTipsFunc then
        local show, tips = self.showDownloadTipsFunc(self.data)
        showDownloadTips = show
        if show and tips then
          askTips = tips
        end
      end
      local download = PufferSwitch.CanAutoDownload()
      local alertSize = HDmpveRemote.HDmpveRemoteConfigGetInt("CommonDownloadUIAlterSize", 10)
      if self.showAlertSize and not download and self.downloadType == ENUM_DownloadType.ODPAK and remainSize >= alertSize then
        PufferManager.ShowAlertSizeTips(self.downloadType, self.data, fromType, callbackFunc, extraData)
      elseif not (not self.textContent or download) or showDownloadTips then
        PufferManager.ShowDownloadTips(self.downloadType, self.data, askTips, fromType, callbackFunc, extraData)
      elseif self.downloadType == ENUM_DownloadType.UGCPAK or self.downloadType == ENUM_DownloadType.UGCPACK then
        PufferManager.Download(ENUM_DownloadType.UGCPAK, self.data, fromType)
      else
        extraData.bFirst = self.data and #self.data <= 2
        log_tree("common_download_ui:OnClickDownload. self.data = ", self.data)
        EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_CLICK_DOWNLOAD, self.data, {
          from = self.from,
          is_limit_time = self.is_limit_time,
          item_time_limit = self.item_time_limit,
          disableClickDownLoadPutOn = self.disableClickDownLoadPutOn
        })
        PufferManager.Download(self.downloadType, self.data, fromType, callbackFunc, extraData)
      end
    end
  end
  if self.clickCallback then
    self.clickCallback(self.data)
  end
  self:UpdateUI(true)
  self:CheckFinishDownload()
end
function common_download_ui:OnTriggerDownload(_, __, resId)
  if resId == nil then
    return
  end
  if self.downloadType ~= PufferConst.ENUM_DownloadType.ODPAK then
    return
  end
  if self.data == nil or not next(self.data) then
    return
  end
  local itemID = self.data[1]
  if itemID and type(itemID) == "number" and tonumber(resId) == tonumber(itemID) then
    self:OnClickDownload()
  end
end
function common_download_ui:CheckFinishDownload()
  if self.state == PufferConst.ENUM_DownloadState.Done and self.callback then
    local callback = self.callback
    self.callback = nil
    callback()
  end
end
function common_download_ui:ReplaceSource()
  local switcherIndex = 0
  local useNewProgress = self.useNewProgress
  if useNewProgress then
    switcherIndex = 1
  end
  self:_initProgressBar()
  self:SetWidgetVisible(self.ProgressBar, true)
  self.WidgetSwitcher_ProgressBar:SetActiveWidgetIndex(switcherIndex)
  local path
  if useNewProgress then
    return
  else
    path = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Common_Image_WhiteBlock_png.Common_Image_WhiteBlock_png"
    if self.isSpecial then
      path = "/Game/UMG/Texture/Atlas/LobbyUI/Frames/Lobby_PharaohRises_icon_Black_png.Lobby_PharaohRises_icon_Black_png"
    end
  end
  local style = self.ProgressBar.WidgetStyle
  if style == nil then
    return
  end
  local fillImage = style.FillImage
  local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
  local textureOrSprite = LogicLoadTexture.LoadTextureOrSprite(path)
  fillImage.ResourceObject = textureOrSprite
  style.FillImage = fillImage
  self.ProgressBar.WidgetStyle = style
  local color = DEFAULT_PROGRESS_MASK_COLOR
  if self.progressMaskColor then
    color = self.progressMaskColor
  end
  self.ProgressBar:SetFillColorAndOpacity(color)
end
function common_download_ui:CheckUIAndDataWithDownload()
  if self and self.data and slua.isValid(self.Panel_Download) then
    return true
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.OverrideUIBase")
local CCommon_Download_UI = class(ui_base, nil, common_download_ui)
return CCommon_Download_UI