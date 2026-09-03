local lua_common_item = {}
local C_NormalAlphaValue = 1.0
local goldenQuality = 10
local oldGoldenQuality = 8
function lua_common_item:OnInitialize()
  self.resId = 0
  self.useCount = 0
  self.count = 0
  self.validHour = 0
  self.isEnableTipsShowLimit = true
  self.isItemPreview = false
  self.itemPreviewType = nil
  self.itemPreviewParams = nil
  self.iconAlpha = 1.0
  self.isShowMask = false
  self.hasGet = false
  self.bShowLight = false
  self.style = nil
  self.isShowTips = nil
  self.isNew = nil
  self.IsIncreaseProbability = nil
  self.isSelected = nil
  self.isLock = nil
  self.isUsing = nil
  self.isIsolated = nil
  self.isTryOn = nil
  self.haveLimitTime = nil
  self.colorId = nil
  self.patternId = nil
  self.targetUI = nil
  self.styleOperator = nil
  self.itemData = nil
  self.decomposeMat = nil
  self.ItemName = nil
  self.isRedEmotion = nil
  self.isUnlockParticle = nil
  self.bParticleOpen = nil
  self.isShowZero = false
  self.displayResId = nil
  self.itemExTimeStr = nil
  self.fromSelf = nil
  self.isShowPartnerItemPreview = false
  self.bShowPrimeShare = false
  self.nCountOriginalFontSize = nil
  self.nSetCountFontSize = nil
  self._nLastIconId = nil
  self.isShowPersonalizedItemPreview = false
  self.outSideDownloadPanel = nil
end
function lua_common_item:OnPostInitialize()
  if self.style ~= nil then
    self:_CreateItem(self.style)
    self:_UpdateView()
  end
end
function lua_common_item:OnClose()
  self:_ClearItem()
end
function lua_common_item:_ClearItem()
  self.clickItemCallback = nil
  self.clickItemCallbackParam = nil
  self._nLastIconId = nil
  if self.targetUI then
    if self.nSetCountFontSize then
      self:SetCountFontSize(self.nCountOriginalFontSize)
      self.nSetCountFontSize = nil
    end
    self.nCountOriginalFontSize = nil
    if self.targetUI.Image_Wardrobe_GunLogo then
      self.targetUI.Image_Wardrobe_GunLogo:SetRenderAngle(0)
      self.targetUI.Image_Wardrobe_GunLogo:SetRenderScale(FVector2D(1, 1))
    end
    self:SetImageIconAlpha(C_NormalAlphaValue)
    self:ClearAvatarIcon()
    self:StopDecomposeAni()
    local TableUtil = require("common.table_util")
    local quality8Item = TableUtil.GetTableValue(self.targetUI, "Common_Item_All_UIBP", "Quality8Item_UIBP")
    if slua.isValid(quality8Item) then
      quality8Item:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    EventSystem:unregistEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnPakDownloadFinish)
    self:_ClearEvent()
    self:_ClearDragEvent()
    local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.item_pool)
    pool:Release(self.targetUI)
    self.targetUI = nil
    if self._downloadPollTimer then
      self:RemoveTimer(self._downloadPollTimer)
      self._downloadPollTimer = nil
    end
  end
end
function lua_common_item:_CreateItem(style)
  if not assert(type(style) == "number", "_CreateItem from Item style should be number ") then
    return
  end
  self:_ClearItem()
  self.  local style_factory = require("client.slua.component.item.style_factory")
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.item_pool)
  self.targetUI = pool:Get(style_factory.StylePathMapping[style])
  if self.targetUI.Common_Item_All_UIBP then
    self.nCountOriginalFontSize = self.targetUI.Common_Item_All_UIBP.Count.Font.Size
  end
  self.GridPanel_0:AddChild(self.targetUI)
  self.targetUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.styleOperator = style_factory.GetStyleOperator(style)
  self.Button_Item = self.styleOperator:GetButtonItem(self.targetUI)
  if self.Button_Item then
    self.Button_Item:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:_BindEvent()
  end
  self:_BindDragEvent()
  EventSystem:registEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnPakDownloadFinish, self)
end
function lua_common_item:OnPakDownloadFinish(_, _, eventData)
  if not eventData or not eventData.itemID then
    return
  end
  if self.resId and self.resId == eventData.itemID or self.displayResId and self.displayResId == eventData.itemID then
    self:SetLimitCount(self.bShowLimit, self.hasCount, self.maxCount)
    self.styleOperator:SetHaveLimitTime(self.targetUI, self.haveLimitTime)
    self:UpdateDownloader()
  end
end
function lua_common_item:InitView(resId, count, style, validHour, isShowTips, isRedEmotion, extra)
  if Client and Client.IsDevelopment() then
    local utility = require("common.utility")
    local sMsg = "lua_common_item:InitView :Please stop using the Common_Item_BP component and switch to the Lua_CommonItems component"
    utility.ErrorMessageReporting(sMsg, 4, 1777305600)
  end
  if not assert(resId ~= nil, "lua_common_item InitView resId == nil") then
    return
  end
  self.  self.  if self.style ~= style or not self.targetUI then
    self:_CreateItem(style)
  end
  self.useCount = 0
  self.  self.  self.isUnlockParticle = false
  self.bParticleOpen = false
  self.isItemPreview = false
  self.itemPreviewType = nil
  self.itemPreviewParams = nil
  self.isShowPartnerItemPreview = false
  self.iconAlpha = 1.0
  self.imageIconAlpha = 1.0
  self.isShowMask = false
  self.isIsolated = nil
  self.isSelected = nil
  self.hasGet = false
  self.bShowLight = false
  self.isSpecailIconSwitch = false
  self.isExtraGet = false
  self.isShowBg = false
  self.isRandomGet = false
  self.bShowLimit = false
  self.bShowCost = false
  self.isShowZero = false
  self.hasCount = 0
  self.maxCount = 0
  self.costCount = 0
  self.hasOwn = false
  self.IsShowaffixBg = false
  self.haveAffix = nil
  self.affixInfo = nil
  self.havePVEAffix = false
  self.haveChest = nil
  self.bShowPrimeShare = false
  self.isShowPersonalizedItemPreview = false
  self.outSideDownloadPanel = nil
  local UIUtil = require("client.common.ui_util")
  self.itemData = UIUtil.GetItemCfg(resId)
  if not self.itemData then
  end
  if self.itemData and (not validHour or validHour <= 0) then
    validHour = self.itemData.ValidTimes or 0
  end
  self.  if not Client.IsShipping() and validHour and 100000000 < validHour then
    local utility = require("common.utility")
    utility.ErrorMessageHandler("[teddysjwu]lua_common_item.InitView, validHour is " .. validHour)
  end
  if self.itemData and self.itemData.ItemName then
    self.ItemName = self.itemData.ItemName
  end
  self.displayResId = extra and extra.displayResId
  self.relativeResIdList = extra and extra.relativeResIdList
  self.itemExTimeStr = extra and extra.time_s
  self.fromSelf = extra and extra.fromSelf
  self.needDownloadBigIcon = extra and extra.bCheckIconDownloaded
  if extra and extra.is_limit then
    self.haveLimitTime = extra.is_limit
  else
    local GlobalUIFunctionLibrary_C = require("client.slua.umg.ui_utility.global_ui_function_library")
    local _, haveLimitTime = GlobalUIFunctionLibrary_C:GetItemTimeS(resId, validHour, self.targetUI)
    self.  end
  if extra and extra.affixs and next(extra.affixs) then
    self.affixInfo = extra.affixs
  end
  if extra and extra.haveAffix then
    self.haveAffix = extra.haveAffix
  elseif extra and extra.is_chest then
    self.haveChest = extra.is_chest
  end
  if extra and extra.havePVEAffix then
    self.havePVEAffix = extra.havePVEAffix
  end
  if extra and extra.skipDownload then
    self.skipDownload = extra.skipDownload
  end
  if extra and extra.downloadPanel then
    self.outSideDownloadPanel = extra.downloadPanel
  end
  self:_UpdateView()
  if self._downloadPollTimer then
    self:RemoveTimer(self._downloadPollTimer)
    self._downloadPollTimer = nil
  end
  if extra and extra.bCheckIconDownloaded then
    self._downloadPollTimer = self:AddTimerLoop(0.5, function()
      local pak_util = require("client.common.pak_util")
      if self.itemData and pak_util.IsFileExist(self.itemData.ItemBigIcon) then
        self.styleOperator:SetIcon(self.targetUI, resId)
        self:RemoveTimer(self._downloadPollTimer)
        self._downloadPollTimer = nil
      end
    end, TIMER_INFINITE, 0.5)
  end
  return self
end
function lua_common_item:_UpdateView()
  self:ClearAvatarIcon()
  self:SetLimitCount(self.bShowLimit, self.hasCount, self.maxCount)
  self:SetCostCount(self.bShowCost, self.hasCount, self.costCount)
  self:SetSmallerIcon(false)
  self:SetUseCount(self.useCount)
  self:_SetIcon(self.displayResId or self.resId)
  self:SetBGVisibility(false)
  self:SetBlackBg(false)
  self:SetQuality(self:GetQuality(), self.displayResId or self.resId)
  self:SetIsHavePVEAffix()
  self:SetIsNew(self.isNew)
  self:SetIsIncreaseProbability(self.IsIncreaseProbability)
  self:SetUsingState(self.isUsing)
  self:SetSpecialNew(self.isNew)
  self:SetIsLock(self.isLock)
  self:ShowMask(self.isShowMask)
  self:SetColorAndPattern(self.colorId, self.patternId)
  self:_SetIsRedEmotion(self.isRedEmotion)
  self:SetIsUnlockParticleEmote(self.isUnlockParticle)
  self:SetIsOpenParticleEmote(self.bParticleOpen)
  self:SetIsolated(self.isIsolated)
  self:SetSelected(self.isSelected)
  self:SetIconAlpha(self.iconAlpha)
  self:SetImageIconAlpha(self.imageIconAlpha)
  self:SetHasGet(self.hasGet)
  self:SetLight(false)
  self:SetCollectNum(0)
  self:SetTakeState(false)
  self:SetEveryPackIcon(self.isSpecailIconSwitch)
  self:SetExtraGetText(self.isExtraGet)
  self:SetRandomGetText(self.isRandomGet)
  self:UpdateTimeLimitIcon(self.haveLimitTime)
  self:UpdateDownloader()
  self.styleOperator:ClearName(self.targetUI)
  self.styleOperator:ResetIcon(self.targetUI)
  self:SetHasGetText(self.hasOwn)
  self:SetLimitTimeBlackBG(false)
  self:SetIsWear(false)
  self:SetIsFreeze(false)
  self:SetBgVisible(self.isShowBg)
  self:SetShowUseTime(false)
  self:SetShowPriveShare(self.bShowPrimeShare)
  self:SetJumpConfig(nil, nil)
  self:SetSpecialJumpConfig()
  self:ShowOrHideExclusivePng(false)
end
function lua_common_item:UpdateDownloader()
  if self.skipDownload then
    return
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local downloadResIdList = self:_GetDownloadResIDList()
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, downloadResIdList)
  if self.styleOperator and self.haveLimitTime then
    if state ~= PufferConst.ENUM_DownloadState.Done then
      self.styleOperator:SetHaveLimitTime(self.targetUI, false)
    else
      self.styleOperator:SetHaveLimitTime(self.targetUI, true)
    end
  end
  local params = {
    callback = function()
      local downloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, downloadResIdList)
      if downloadState == PufferConst.ENUM_DownloadState.Done and self.styleOperator then
        self.styleOperator:SetHaveLimitTime(self.targetUI, self.haveLimitTime)
      end
    end
  }
  local parentWidget = self:GetDownloadPanelHandleWidget()
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, downloadResIdList, parentWidget, params)
end
function lua_common_item:GetDownloadPanelHandleWidget()
  return self.outSideDownloadPanel or self.Panel_Download
end
function lua_common_item:SetIsHavePVEAffix()
  if self.styleOperator.SetIsHavePVEAffix then
    self.styleOperator:SetIsHavePVEAffix(self.targetUI, self.havePVEAffix)
  end
end
function lua_common_item:SetEveryPackIcon(isSpecailIconSwitch)
  self.  self.styleOperator:SetEveryPackIcon(self.targetUI, isSpecailIconSwitch)
end
function lua_common_item:SetExtraGetText(isExtraGet)
  self.  self.styleOperator:SetExtraGetText(self.targetUI, isExtraGet)
end
function lua_common_item:SetRandomGetText(isRandomGet)
  self.  self.styleOperator:SetRandomGetText(self.targetUI, isRandomGet)
end
function lua_common_item:SetLight(bShow)
  self.bShowLight = bShow
  self.styleOperator:SetLight(self.targetUI, self.bShowLight)
end
function lua_common_item:SetCollectNum(num)
  self.styleOperator:SetCollectNum(self.targetUI, num)
end
function lua_common_item:ShowItemName()
  self.styleOperator:ShowItemName(self.targetUI, self.ItemName)
end
function lua_common_item:SetQuality(quality, resID)
  if quality <= 0 then
    self:SetBGVisibility(true)
  end
  self.styleOperator:SetQuality(self.targetUI, quality, resID)
end
function lua_common_item:SetIsNew(isNew)
  self.  self.styleOperator:SetIsNew(self.targetUI, isNew)
end
function lua_common_item:SetSpecialNew(isNew)
  self.styleOperator:SetSpecialNew(self.targetUI, isNew, self.resId)
end
function lua_common_item:SetIsIncreaseProbability(IsIncreaseProbability)
  self.  self.styleOperator:SetIsIncreaseProbability(self.targetUI, IsIncreaseProbability)
end
function lua_common_item:SetIsLock(isLock)
  self.  self.styleOperator:SetIsLock(self.targetUI, isLock)
end
function lua_common_item:SetUsingState(isUsing)
  self.  self.styleOperator:SetIsUsing(self.targetUI, isUsing)
  self:SetBGVisibility(true)
  if isUsing then
    self.styleOperator:SetIsNew(self.targetUI, false)
    self.styleOperator:SetSpecialNew(self.targetUI, false)
  end
end
function lua_common_item:SetIsWear(isWear)
  self.  self.styleOperator:SetIsWear(self.targetUI, isWear)
end
function lua_common_item:SetIsFreeze(isFreeze)
  self.  self.styleOperator:SetIsFreeze(self.targetUI, isFreeze)
end
function lua_common_item:SetBgVisible(isShow)
  self.isShowBg = isShow
  self.styleOperator:SetBgVisible(self.targetUI, isShow)
end
function lua_common_item:SetIsTryOn(isTryOn)
  self.  self.styleOperator:SetIsTryOn(self.targetUI, isTryOn)
end
function lua_common_item:SetIsolated(isIsolated)
  self.  self.styleOperator:SetIsIsolated(self.targetUI, isIsolated)
end
function lua_common_item:SetSelected(isSelected)
  self.  self.styleOperator:SetIsSelected(self.targetUI, isSelected)
end
function lua_common_item:SetUseCount(useCount, isRolewear, isShowZero)
  self.  self.  self.  self.styleOperator:SetCount(self.targetUI, self.count, self.useCount, self.isRolewear, self.isShowZero)
end
function lua_common_item:SetNumber(count, isShowZero)
  self.  self.  self.styleOperator:SetCount(self.targetUI, self.count, self.useCount, self.isRolewear, self.isShowZero)
end
function lua_common_item:SetIconFromTexture(texture)
  self.styleOperator:SetIconFromTexture(self.targetUI, texture)
end
function lua_common_item:_SetIcon(resId)
  if self._nLastIconId == resId then
    return
  end
  self.styleOperator:SetIcon(self.targetUI, resId)
  self._nLastIconId = resId
end
function lua_common_item:SetIconAlpha(alpha)
  self.iconAlpha = alpha
  self.styleOperator:SetIconAlpha(self.targetUI, alpha)
end
function lua_common_item:SetImageIconAlpha(alpha)
  self.imageIconAlpha = alpha
  if self.styleOperator then
    self.styleOperator:SetImageIconAlpha(self.targetUI, alpha)
  end
end
function lua_common_item:SetSpecialIconShow(bShow)
  self.styleOperator:SetSpecialIconShow(self.targetUI, bShow)
end
function lua_common_item:ShowMask(isShow)
  self.isShowMask = isShow
  self.styleOperator:ShowMask(self.targetUI, isShow)
end
function lua_common_item:SetHasGet(hasGet)
  self.  self.styleOperator:SetHasGet(self.targetUI, hasGet)
end
function lua_common_item:SetTakeState(canTake)
  self.  self.styleOperator:SetTakeState(self.targetUI, canTake)
end
function lua_common_item:SetColorAndPattern(colorId, patternId)
  self.  self.  self.styleOperator:SetColorAndPattern(self.targetUI, colorId, patternId)
end
function lua_common_item:_SetIsRedEmotion(isRedEmotion)
  self.styleOperator:SetIsRedEmotion(self.targetUI, isRedEmotion)
end
function lua_common_item:SetIsUnlockParticleEmote(isUnlockParticle)
  self.styleOperator:SetIsUnlockParticleEmote(self.targetUI, isUnlockParticle)
end
function lua_common_item:SetIsOpenParticleEmote(bParticleOpen)
  self.styleOperator:SetIsOpenParticleEmote(self.targetUI, bParticleOpen)
end
function lua_common_item:SetNameAddStr(extendName)
  self.styleOperator:SetNameAddStr(self.targetUI, extendName, self.haveLimitTime)
end
function lua_common_item:SetNameColor(color)
  self.styleOperator:SetNameColor(self.targetUI, color)
end
function lua_common_item:HideNameAddrStr()
  if self.styleOperator then
    self.styleOperator:HideNameAddrStr(self.targetUI)
  end
end
function lua_common_item:EnableShowTips(enable)
  self.isShowTips = enable
end
function lua_common_item:SetBGVisibility(visible)
  self.styleOperator:SetBGVisibility(self.targetUI, visible)
end
function lua_common_item:EnableShowLimit(enable)
  self.isEnableTipsShowLimit = enable
end
function lua_common_item:SetSpecialIcon(path)
  self.styleOperator:SetSpecialIcon(self.targetUI, path)
end
function lua_common_item:SetSmallerIcon(isNeedSmall)
  self.styleOperator:SetSmallerIcon(self.targetUI, isNeedSmall, self.count)
end
function lua_common_item:SetShowaffixBg(IsShow, data)
  self.IsShowaffixBg = IsShow
  self.affixData = data
end
function lua_common_item:EnableItemPreview(newPreviewType, previewParams)
  self.isItemPreview = true
  self.itemPreviewType = newPreviewType
  self.itemPreviewParams = previewParams
end
function lua_common_item:DisableItemPreview()
  self.isItemPreview = false
  self.itemPreviewType = nil
  self.itemPreviewParams = nil
end
function lua_common_item:SetPartnerItemShowPreview(bShowPreview)
  self.isShowPartnerItemPreview = bShowPreview or false
end
function lua_common_item:SetPersonalizedItemPreview(bShowPreview)
  log(bWriteLog and "lua common item SetPersonalizedItemPreview bShowPreview:" .. tostring(bShowPreview))
  self.isShowPersonalizedItemPreview = bShowPreview or false
end
function lua_common_item:SetClickItemCallback(clickItemCallback, ...)
  self.  self.clickItemCallbackParam = table.pack(...)
end
function lua_common_item:SetEmptyName()
  self.ItemName = ""
end
function lua_common_item:SetCombatReadinessIcon(visibility)
  self.styleOperator:SetCombatReadinessIcon(self.targetUI, visibility)
end
function lua_common_item:SetAwardState(state)
  if state == 1 or state == 2 then
    self.isLock = false
  elseif state == 0 then
    self.isLock = true
  end
  self.styleOperator:SetAwardState(self.targetUI, state)
end
function lua_common_item:SetBlackBg(isShow)
  if self.styleOperator then
    self.styleOperator:SetBlackBg(self.targetUI, isShow)
  end
end
function lua_common_item:SetGrayBg(isShow)
  self.styleOperator:SetGrayBg(self.targetUI, isShow)
end
function lua_common_item:SetIsShowSubTransparentBg(isShow)
  self.styleOperator:SetIsShowSubTransparentBg(self.targetUI, isShow)
end
function lua_common_item:SetValidTime(validtime)
  self.styleOperator:SetValidTime(self.targetUI, validtime)
end
function lua_common_item:SetTimeLimitIcon(show)
  if self.styleOperator then
    self.styleOperator:SetHaveLimitTime(self.targetUI, show)
  end
  self.haveLimitTime = show
  self:UpdateDownloader()
end
function lua_common_item:HideQuality()
  self.styleOperator:HideQuality(self.targetUI)
end
function lua_common_item:HideQualityOfBG()
  self.styleOperator:HideQualityOfBG(self.targetUI)
end
function lua_common_item:SetLimitCount(IsShow, Has, Max)
  self.bShowLimit = IsShow
  self.hasCount = Has
  self.maxCount = Max
  self.styleOperator:SetLimitCount(self.targetUI, IsShow, Has, Max)
end
function lua_common_item:SetCostCount(IsShow, Has, Cost)
  self.bShowCost = IsShow
  self.hasCount = Has
  self.costCount = Cost
  self.styleOperator:SetCostCount(self.targetUI, IsShow, Has, Cost)
end
function lua_common_item:SetHasGetText(hasGet)
  self.hasOwn = hasGet
  self.styleOperator:SetHasGetText(self.targetUI, hasGet)
end
function lua_common_item:SetLimitTimeBlackBG(isBlack)
  self.styleOperator:SetLimitTimeBlackBG(self.targetUI, isBlack)
end
function lua_common_item:SetShowUseTime(bShowUseTime)
  self.end
function lua_common_item:UpdateTimeLimitIcon(bShow)
  if bShow ~= nil then
    self:SetTimeLimitIcon(bShow)
    return
  end
  bShow = false
  if self.haveLimitTime then
    local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
    if self.itemExTimeStr ~= "" or self.validHour ~= 0 then
      bShow = true
    elseif CommonItem_Utils.SpecialCheckIsValidTimeItem(self.resId) then
      bShow = true
    end
  end
  if self.itemData then
    if self.itemData.ExTime and self.itemData.ExTime ~= "" then
      bShow = true
    end
    if self.itemData.ValidTimes and self.itemData.ValidTimes ~= 0 then
      bShow = true
    end
  end
  self:SetTimeLimitIcon(bShow)
end
function lua_common_item:GetQuality()
  local itemData = self.itemData
  if self.displayResId and self.displayResId ~= 0 then
    local UIUtil = require("client.common.ui_util")
    itemData = UIUtil.GetItemCfg(self.displayResId)
  end
  local ItemQuality = 0
  if self.affixInfo or self.haveAffix then
    ItemQuality = goldenQuality
  elseif self.haveChest then
    if itemData and itemData.ItemQuality == oldGoldenQuality then
      ItemQuality = goldenQuality
    else
      ItemQuality = itemData and itemData.ItemQuality or 0
    end
  else
    ItemQuality = itemData and itemData.ItemQuality or 0
  end
  return ItemQuality
end
function lua_common_item:SetShowPriveShare(bShow, ShreType)
  self.bShowPrimeShare = bShow
  self.styleOperator:SetShowPriveShare(self.targetUI, bShow, ShreType)
end
function lua_common_item:_GetDownloadResIDList()
  local downloadResIDList = {
    self.resId
  }
  local tempListForCheck = {
    [self.resId] = true
  }
  if self.displayResId and self.displayResId ~= 0 and not tempListForCheck[self.displayResId] then
    tempListForCheck[self.displayResId] = true
    downloadResIDList[#downloadResIDList + 1] = self.displayResId
  end
  if self.relativeResIdList and next(self.relativeResIdList) then
    for _, resId in pairs(self.relativeResIdList) do
      if resId and resId ~= 0 and not tempListForCheck[resId] then
        tempListForCheck[resId] = true
        downloadResIDList[#downloadResIDList + 1] = resId
      end
    end
  end
  if self.needDownloadBigIcon then
    local cfg = CDataTable.GetTableData("Item", self.resId)
    if cfg and cfg.ItemBigIcon then
      downloadResIDList[#downloadResIDList + 1] = cfg.ItemBigIcon
    end
  end
  return downloadResIDList
end
function lua_common_item:OnClickItem()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  if self.clickItemCallback then
    local ret = self.clickItemCallback(table.unpack(self.clickItemCallbackParam))
    if ret == true then
      return
    end
  end
  local itemData = CDataTable.GetTableData("Item", self.resId)
  if not itemData then
    return
  end
  if itemData.ItemType == 37 then
    return
  end
  local logic_roleinfo_personalization_util = require("client.logic.roleinfo.logic_roleinfo_personalization_util")
  if self.isShowPersonalizedItemPreview and logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview(itemData) then
    return
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  if self.isShowPartnerItemPreview and logic_couple_avatar_util.CheckIfCouplePoseItem(itemData) and logic_couple_avatar_util.ShowPartnerItemPreview(self.resId) == true then
    return
  end
  if self.isItemPreview then
    local Social_Person_Space_UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
    if not Social_Person_Space_UIBP then
      local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
      if (ItemPreviewSystem.IsNeedShow(self.resId) or LobbySystem.CheckShowPackagePreview(self.resId)) and LobbySystem.PlayItemPreviewAnimation(self.resId, false, self.itemPreviewType, self.itemPreviewParams, self.validHour, {
        fromSelf = self.fromSelf
      }) then
        return
      end
    end
  end
  if self.isShowTips then
    local UIUtil = require("client.common.ui_util")
    local Config = {
      bShowUseTime = self.bShowUseTime,
      displayResId = self.displayResId,
      time_s = self.itemExTimeStr,
      is_limit = self.haveLimitTime,
      affixInfo = self.affixInfo,
      haveAffix = self.haveAffix,
      is_chest = self.haveChest,
      jumpClickTxt = self.jumpClickTxt,
      jumpCallback = self.jumpCallback
    }
    UIUtil.ShowItemTips(self.resId, self.Button_Item, FVector2D(0, 0), self.validHour, 0, true, Config)
  end
end
function lua_common_item:PlayDecomposeAni(oldItemID, newItemID, newCnt)
  self.styleOperator:PlayDecomposeAni(self.targetUI, oldItemID, newItemID, newCnt)
  self.resId = newItemID
end
function lua_common_item:StopDecomposeAni()
  self.styleOperator:StopDecomposeAni(self.targetUI)
end
function lua_common_item:PlayDecomposeAniUP()
  self.styleOperator:PlayDecomposeAniUP(self.targetUI)
end
function lua_common_item:PlayDecomposeAnim()
  self:SetNumber(self.decomposeToCount)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local itemRoot = self.targetUI
  local animDecompose = itemRoot.TransForm
  if KismetSystemLibrary.IsValid(itemRoot) and KismetSystemLibrary.IsValid(animDecompose) then
    itemRoot:PlayUserWidgetAnimation(animDecompose, 0, 1, 0, 1)
  end
end
function lua_common_item:_BeginPlayDecomposeAnim()
  local itemRoot = self.targetUI
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local animDecompose = itemRoot.TransForm
  if KismetSystemLibrary.IsValid(animDecompose) then
    itemRoot:PlayAnimationTo(animDecompose, 0, 1.0E-4, 1, 0, 1)
  end
end
local GetIconPathByResID = function(resId)
  local UIUtil = require("client.common.ui_util")
  local itemCfgPath = UIUtil.GetItemSmallIcon(resId)
  return itemCfgPath
end
function lua_common_item:SetDecomposeEffectIcon(fromId, toId, toCount, playAnimDelayTime)
  self:_BeginPlayDecomposeAnim()
  local fromIconPath = GetIconPathByResID(fromId)
  local asset_util = require("common.asset_util")
  local fromTexture = asset_util.GetAssetSync(fromIconPath)
  if fromTexture ~= nil then
    local toIconPath = self:GetIconPathByResID(toId)
    local toTexture = asset_util.GetAssetSync(toIconPath)
    if toTexture ~= nil then
      local decomposeMat = self.decomposeMat
      local KismetSystemLibrary = import("KismetSystemLibrary")
      if not KismetSystemLibrary.IsValid(decomposeMat) then
        local KismetMaterialLibrary = import("KismetMaterialLibrary")
        decomposeMat = KismetMaterialLibrary.CreateDynamicMaterialInstance("/Game/UMG/UI_Effect/Materials/DX_UITransform03_Inst.DX_UITransform03_Inst")
        self.      end
      decomposeMat:SetTextureParameterValue("Tex_1", fromTexture)
      decomposeMat:SetTextureParameterValue("Tex_2", toTexture)
      self.targetUI.Image_Icon:SetBrushFromMaterial(decomposeMat)
    end
  end
  self.decomposeToCount = toCount
  local KismetSystemLibrary = import("KismetSystemLibrary")
  KismetSystemLibrary.K2_SetTimer(self, "PlayDecomposeAnim", playAnimDelayTime, false)
end
function lua_common_item:SetCountFontSize(nFontSize)
  if not nFontSize then
    return
  end
  if self.targetUI and self.targetUI.Common_Item_All_UIBP then
    self.nSetCountFontSize = nFontSize
    local Common_Item_All_UIBP = self.targetUI.Common_Item_All_UIBP
    local Font = Common_Item_All_UIBP.Count.Font
    Font.Size = nFontSize
    Common_Item_All_UIBP.Count:SetFont(Font)
  end
end
function lua_common_item:SetTexture(control, path)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(control, path, {sync = false})
end
function lua_common_item:SetIconFromPath(path)
  self.styleOperator:SetIconFromPath(self.targetUI, path)
end
function lua_common_item:SetQualityBg(path)
  self.styleOperator:SetQualityBg(self.targetUI, path)
end
function lua_common_item:SetJumpConfig(jumpCallback, jumpClickTxt)
  self.  self.end
function lua_common_item:SetSpecialJumpConfig()
  local callback, txt
  if self.resId == 1024 then
    function callback()
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {tab = "exchange"})
    end
    txt = LocUtil.GetLocalizeResStr(9018)
  end
  self:SetJumpConfig(callback, txt)
end
function lua_common_item:ShowOrHideExclusivePng(show)
  self.styleOperator:ShowOrHideExclusivePng(self.targetUI, show)
end
function lua_common_item:ClearAvatarIcon()
  if self._nLastIconId == self.resId then
    return
  end
  if self.styleOperator then
    self.styleOperator:ClearAvatarIcon(self.targetUI)
  end
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_common_item)