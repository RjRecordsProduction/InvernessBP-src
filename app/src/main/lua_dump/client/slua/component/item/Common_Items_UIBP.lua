local UIUtil = require("client.common.ui_util")
local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
local CommonItem_ChildCfg = require("client.slua.component.item.ItemUtils.CommonItem_ChildCfg")
local CommonItem_OtherCfg = require("client.slua.component.item.ItemUtils.CommonItem_OtherCfg")
local Common_Items_UIBP = {}
local Enum_ChildName = CommonItem_Const.Enum_ChildName
local Enum_UIBP_NodeName = CommonItem_Const.Enum_UIBP_NodeName
local EHorizontalAlignment = UEnums.EHorizontalAlignment
local EVerticalAlignment = UEnums.EVerticalAlignment
local _uObj_iconSpacerShow = FMargin(0.0, 0.0, 0.0, 0.0)
local _uObj_3DisShow = FMargin(3.0, 0.0, 3.0, 0.0)
local _uObj_AvatarShow = FMargin(10.0, 10.0, 10.0, 10.0)
local _uObj_redColor = FSlateColor(FLinearColor(0.82, 0.033, 0.033, 1))
local _uObj_greenColor = FSlateColor(FLinearColor(0.11, 0.64, 0.25, 1))
function Common_Items_UIBP:ctor()
  self._nItemId = nil
  self._nLastShowItemId = nil
  self._nCount = nil
  self._nValidTime = nil
  self._tExtraData = nil
  self._uObj_itemCfg = nil
  self._bIsPlayingDecomposeAni = false
  self._nCountOriginalFontSize = nil
  self._tCountScaleSlotOriginalSize = nil
  self._nShowIconTimerId = nil
  self._cObj_downloadUI = nil
  self._bIsChangeCountScale = false
  self._bIsChangeFontSize = false
  self._bIsCustomSize = false
  self._bInitIconShow = false
  self._CDNImageDownloadIndex = nil
  self._ShowIconPath = nil
  self._gifWidget = nil
  self._gifWidget = nil
  self._decomposeItemID = nil
end
function Common_Items_UIBP:OnInitialize()
  Common_Items_UIBP.__super.OnInitialize(self)
  local node_root = self.UIRoot
  self._nCountOriginalFontSize = node_root.RichText_ItemCount.Font.Size
  local cObj_countScaleSlot = node_root.ScaleBox_Count.Slot
  local uObj_slotSize = cObj_countScaleSlot:GetOffsets()
  self._tCountScaleSlotOriginalSize = {
    uObj_slotSize.Left,
    uObj_slotSize.Top,
    uObj_slotSize.Right,
    uObj_slotSize.Bottom
  }
end
function Common_Items_UIBP:RegistEvents()
  Common_Items_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Item, self.OnItemBtnClick, self)
end
function Common_Items_UIBP:OnPostInitialize()
  Common_Items_UIBP.__super.OnPostInitialize(self)
  self:RestoreUIOperation()
end
function Common_Items_UIBP:OnClose()
  if not self:IsAsyncLoading() then
    self:_ResetSizeShow()
    self:_ResetScaleCountSize()
    self:_ResetFontSize()
    self:SetIconAndQualityAlpha(1)
    self:_ClearAvatarIcon(true)
    self:_ResetIconScaleAndRotation()
    if self._tExtraData and self._tExtraData.bIsIconSpacerShow then
      self:SetIconSpacerShow(false)
    end
    if self._tExtraData and self._tExtraData.bIsAvatarIcon then
      self:SetIconPaddingByIsAvatar(false)
    end
  end
  self._cObj_downloadUI = nil
  self._CDNImageDownloadIndex = nil
  self._ShowIconPath = nil
  if self._downloadPollTimer then
    self:RemoveTimer(self._downloadPollTimer)
    self._downloadPollTimer = nil
  end
  Common_Items_UIBP.__super.OnClose(self)
end
function Common_Items_UIBP:OnItemBtnClick()
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  if tExtraData.bDisableClick then
    return
  end
  self:PlayAudio(sound_config.click)
  if not self._nItemId then
    return
  end
  if tExtraData.fClickItemCallback then
    local tClickItemCallbackParam = tExtraData.tClickItemCallbackParam or {}
    local bIsReturn = tExtraData.fClickItemCallback(table.unpack(tClickItemCallbackParam))
    if bIsReturn then
      return
    end
  end
  local uObj_itemCfg = self:_GetItemCfg()
  if not uObj_itemCfg then
    return
  end
  if uObj_itemCfg.ItemType == ENUM_ITEM_TYPE.Applique then
    return
  end
  if self:_ShowSpecialItemTip(uObj_itemCfg, tExtraData) then
    return
  end
  if self:_ShowPreviewView() then
    return
  end
  if tExtraData.bIsShowTip then
    local tShowConfig = {
      bShowUseTime = tExtraData.bShowUseTime,
      displayResId = tExtraData.displayResId,
      time_s = tExtraData.sTimeShowStr or tExtraData.time_s,
      is_limit = tExtraData.bIsLimit or tExtraData.is_limit,
      affixInfo = tExtraData.affixs,
      haveAffix = tExtraData.haveAffix,
      is_chest = tExtraData.is_chest,
      jumpClickTxt = tExtraData.sJumpClickTxt,
      jumpCallback = tExtraData.fJumpCallback,
      specialContent = tExtraData.sSpecialContent,
      specialContentFontSize = tExtraData.nSpecialContentFontSize
    }
    local itemID = self._decomposeItemID and self._decomposeItemID or self._nItemId
    UIUtil.ShowItemTips(itemID, self.UIRoot.Button_Item, tExtraData.tipOffset or FVector2D(0, 0), self._nValidTime, 0, true, tShowConfig)
  end
end
function Common_Items_UIBP:_SetIconPadding(nItemId)
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if not uObj_itemCfg then
    return
  end
  self:SetIconPaddingByIsAvatar(uObj_itemCfg.ItemType == ENUM_ITEM_TYPE.HeadIcon)
end
function Common_Items_UIBP:_ClearShowIconTimer()
  if self._nShowIconTimerId then
    self:RemoveTimer(self._nShowIconTimerId)
  end
end
function Common_Items_UIBP:_CancelCDNImageDownload()
  if self._CDNImageDownloadIndex and self._CDNImageDownloadIndex > 0 then
    self:CancelImageDownloadByIndex(self._CDNImageDownloadIndex)
    self._CDNImageDownloadIndex = nil
  end
end
function Common_Items_UIBP:ReSetIconFromItemId(ItemId)
  self:_SetIconTextureByItemId(ItemId)
end
function Common_Items_UIBP:_SetIconTextureByItemId(nItemId)
  local node_root = self.UIRoot
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if not uObj_itemCfg then
    log(bWriteLog and " Unable to find the item configuration with itemid = " .. nItemId)
    self:SetWidgetVisible(node_root.Image_Icon, false)
    return
  end
  if self._tExtraData.bIconCdnShow then
    log(bWriteLog and " CDN icon show")
    self:SetWidgetVisible(node_root.Image_Icon, false)
    return
  end
  self:SetWidgetVisible(node_root.Image_Icon, true)
  local tExtraData = self._tExtraData or {}
  local bIsShowBigIcon = tExtraData.bIsShowBigIcon
  local bIsShowBigIcon2 = tExtraData.bIsShowBigIcon2
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local bDIYColor, nColorId = weapon_diy_utils:IsDiyColor(nItemId)
  if bDIYColor then
    weapon_diy_utils:SetDiyColorImage(node_root.Image_Icon, nColorId)
  else
    node_root.Image_Icon:SetBrushFromTexture(nil, true)
    self:_ClearShowIconTimer()
    self:_CancelCDNImageDownload()
    node_root.Image_Icon:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
    local sIconPath, bHasAddKnownMissing = CommonItem_Utils.GetIconPath(nItemId, uObj_itemCfg, node_root.Image_Icon, bIsShowBigIcon, bIsShowBigIcon2)
    if not sIconPath then
      return
    end
    self._ShowIconPath = sIconPath
    local nDelayTime = (not self._bInitIconShow or tExtraData.bIconShowNoDelay) and 0.1 or 0
    self._bInitIconShow = true
    local params = {
      sync = false,
      bMatchSize = true,
          }
    if not self._bInitIconShow or tExtraData.bIconShowNoDelay then
      self:SetTexture(node_root.Image_Icon, sIconPath, params)
      if tExtraData.fCheckIconScaleCallback then
        tExtraData.fCheckIconScaleCallback(nItemId, sIconPath, node_root.Image_Icon)
        if tExtraData.bIsShowBigIcon or tExtraData.bIsShowBigIcon2 then
          local targetIconPath = tExtraData.bIsShowBigIcon2 and uObj_itemCfg.ItemBigIcon2 ~= "" and uObj_itemCfg.ItemBigIcon2 or uObj_itemCfg.ItemBigIcon
          if targetIconPath ~= sIconPath then
            self._downloadPollTimer = self:AddTimerLoop(0.5, function()
              local pak_util = require("client.common.pak_util")
              if targetIconPath and pak_util.IsFileExist(targetIconPath) then
                self:SetTexture(node_root.Image_Icon, targetIconPath, params)
                self:_ResetIconScaleAndRotation()
                self:RemoveTimer(self._downloadPollTimer)
                self._downloadPollTimer = nil
              end
            end, TIMER_INFINITE, 0.5)
          end
        end
      else
        self:_ResetIconScaleAndRotation()
      end
    else
      self._nShowIconTimerId = self:AddTimerOnce(nDelayTime, function()
        self:SetTexture(node_root.Image_Icon, sIconPath, params)
        if tExtraData.fCheckIconScaleCallback then
          tExtraData.fCheckIconScaleCallback(nItemId, sIconPath, node_root.Image_Icon)
          if tExtraData.bIsShowBigIcon or tExtraData.bIsShowBigIcon2 then
            local targetIconPath = tExtraData.bIsShowBigIcon2 and uObj_itemCfg.ItemBigIcon2 ~= "" and uObj_itemCfg.ItemBigIcon2 or uObj_itemCfg.ItemBigIcon
            if targetIconPath ~= sIconPath then
              self._downloadPollTimer = self:AddTimerLoop(0.5, function()
                local pak_util = require("client.common.pak_util")
                log(bWriteLog and "Common_Items_UIBP:_SetIconTextureByItemId widget Check " .. tostring(node_root.Image_Icon) .. " texture " .. tostring(targetIconPath))
                if targetIconPath and pak_util.IsFileExist(targetIconPath) then
                  log(bWriteLog and "Common_Items_UIBP:_SetIconTextureByItemId widget Set" .. tostring(node_root.Image_Icon) .. " texture " .. tostring(targetIconPath))
                  self:SetTexture(node_root.Image_Icon, targetIconPath, params)
                  self:_ResetIconScaleAndRotation()
                  self:RemoveTimer(self._downloadPollTimer)
                  self._downloadPollTimer = nil
                end
              end, TIMER_INFINITE, 0.5)
              log(bWriteLog and "Common_Items_UIBP:_SetIconTextureByItemId Handle widget" .. tostring(node_root.Image_Icon) .. " texture " .. tostring(targetIconPath) .. " handle " .. tostring(self._downloadPollTimer))
            end
          end
        else
          self:_ResetIconScaleAndRotation()
        end
      end)
    end
  end
end
function Common_Items_UIBP:_IsCanShowValidTimeIcon()
  local tDownloadAllItem = self:_GetDownloadList()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local nCurState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tDownloadAllItem)
  if nCurState == PufferConst.ENUM_DownloadState.Done then
    return true
  end
  return false
end
function Common_Items_UIBP:_GetDownloadList()
  local tExtraData = self._tExtraData or {}
  if tExtraData.bIsSkipDownload then
    return {}
  end
  local nItemId = self._nItemId > 0 and self._nItemId or nil
  local tDownloadList = {nItemId}
  local tempListForCheck = {
    [self._nItemId] = true
  }
  local displayResId = tExtraData.displayResId
  if displayResId and displayResId ~= 0 and not tempListForCheck[displayResId] then
    table.insert(tDownloadList, displayResId)
  end
  local relativeResIdList = tExtraData.relativeResIdList
  if relativeResIdList and next(relativeResIdList) then
    for _, resId in pairs(relativeResIdList) do
      if resId and resId ~= 0 and not tempListForCheck[resId] then
        tempListForCheck[resId] = true
        table.insert(tDownloadList, resId)
      end
    end
  end
  if tExtraData and tExtraData.fCheckIconScaleCallback then
    local cfg = CDataTable.GetTableData("Item", nItemId)
    if cfg and cfg.ItemBigIcon then
      table.insert(tDownloadList, cfg.ItemBigIcon)
    end
  end
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  if logic_ugc_inventory and nItemId then
    local TabID = logic_ugc_inventory:GetTabIDDigits(nItemId)
    local SubTabID = logic_ugc_inventory:GetSubTabIDDigits(nItemId)
    if TabID and 0 < TabID and SubTabID and 0 < SubTabID then
      local UGC_Inventory = require("client.slua.logic.ugc.ugc_Inventory")
      local tabIndex = logic_ugc_inventory:FindTabIndexByTabId(TabID)
      local subTabIndex = logic_ugc_inventory:FindSubTabIndexBySubTabId(tabIndex, SubTabID)
      if tabIndex and subTabIndex then
        local inventoryTabData = UGC_Inventory.InventoryList[tabIndex]
        if inventoryTabData and inventoryTabData[subTabIndex] then
          local Data = CDataTable.GetTableData(inventoryTabData[subTabIndex].DataName, nItemId)
          local DownData = logic_ugc_inventory:GetDownloadList(Data)
          if DownData and next(DownData) then
            for k, v in pairs(DownData) do
              if v and v ~= 0 and not tempListForCheck[v] then
                tempListForCheck[v] = true
                table.insert(tDownloadList, v)
              end
            end
          end
        end
      end
    end
  end
  return tDownloadList
end
function Common_Items_UIBP:_GetItemCfg()
  if not self._nItemId then
    return
  end
  if not self._uObj_itemCfg then
    if not self._nItemId then
      return
    end
    local uObj_itemCfg = CDataTable.GetTableData("Item", self._nItemId)
    self._  end
  return self._uObj_itemCfg
end
function Common_Items_UIBP:_ShowSpecialItemTip(uObj_itemCfg, tExtraData)
  local logic_roleinfo_personalization_util = require("client.logic.roleinfo.logic_roleinfo_personalization_util")
  if tExtraData.bIsShowPersonalizedItemPreview and logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview(uObj_itemCfg) then
    return true
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  if tExtraData.bIsShowPartnerItemPreview and logic_couple_avatar_util.CheckIfCouplePoseItem(uObj_itemCfg) and logic_couple_avatar_util.ShowPartnerItemPreview(self._nItemId) == true then
    return true
  end
end
function Common_Items_UIBP:_ShowPreviewView()
  local tExtraData = self._tExtraData
  if tExtraData.affixs and next(tExtraData.affixs) then
    return false
  end
  if not tExtraData or not tExtraData.bIsShowItemPreview then
    return false
  end
  local Social_Person_Space_UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  if not Social_Person_Space_UIBP then
    local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
    if (ItemPreviewSystem.IsNeedShow(self._nItemId) or LobbySystem.CheckShowPackagePreview(self._nItemId)) and LobbySystem.PlayItemPreviewAnimation(self._nItemId, false, tExtraData.nShowPreviewType, tExtraData.tShowPreviewParams, self._nValidTime, {
      fromSelf = tExtraData.bPreviewFromSelf
    }) then
      return true
    end
  end
end
function Common_Items_UIBP:_ResetSizeShow()
  if not self._bIsCustomSize then
    return
  end
  local node_root = self.UIRoot
  node_root.CanvasPanel_Size.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
  node_root.CanvasPanel_Size.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  self._bIsCustomSize = false
end
function Common_Items_UIBP:_ResetScaleCountSize()
  local tOriginalSize = self._tCountScaleSlotOriginalSize
  if not self._bIsChangeCountScale or not tOriginalSize then
    return
  end
  local node_root = self.UIRoot
  local uObj_slot = node_root.ScaleBox_Count.Slot
  uObj_slot:SetAnchors(FAnchors(0, 1, 1, 1))
  uObj_slot:SetOffsets(FMargin(tOriginalSize[1], tOriginalSize[2], tOriginalSize[3], tOriginalSize[4]))
  self._bIsChangeCountScale = false
end
function Common_Items_UIBP:_ResetFontSize()
  if not self._bIsChangeFontSize then
    return
  end
  local node_root = self.UIRoot
  local uObj_font = node_root.RichText_ItemCount.Font
  uObj_font.Size = self._nCountOriginalFontSize or 18
  node_root.RichText_ItemCount:SetFont(uObj_font)
  self._bIsChangeFontSize = false
end
function Common_Items_UIBP:_ResetIconScaleAndRotation()
  local node_root = self.UIRoot
  node_root.Image_Icon:SetRenderAngle(0)
  node_root.Image_Icon:SetRenderScale(FVector2D(1, 1))
end
function Common_Items_UIBP:_ClearAvatarIcon(bIsForce)
  local node_root = self.UIRoot
  local nItemId = self._nItemId
  local tExtraData = self._tExtraData or {}
  local bIsCleanAvatarIcon = false
  local nShowItemId = tExtraData.displayResId or nItemId
  if nItemId then
    bIsCleanAvatarIcon = self._nLastShowItemId ~= nShowItemId
  end
  if bIsForce or bIsCleanAvatarIcon then
    local AvatarGIFImageBPPool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarGIFImageBPPool)
    AvatarGIFImageBPPool:RemoveAvatarChild(node_root.ScaleBox_AvatarIcon)
    self._gifWidget = nil
  end
end
function Common_Items_UIBP:_InitResetShow()
  self:SetIconIsShow(true)
  local node_root = self.UIRoot
  self:SetWidgetVisible(node_root.Button_Item, true, true)
  self._uObj_itemCfg = nil
  self._bIsPlayingDecomposeAni = false
  self._bIsChangeFontSize = false
  self._bIsChangeCountScale = false
  local tItemTipJumpCfg = CommonItem_OtherCfg.tSpecialItemShowJumpCfg[self._nItemId]
  if tItemTipJumpCfg then
    local sJumpClickTxt = LocUtil.GetLocalizeResStr(tItemTipJumpCfg.sJumpClickTxtKey)
    self:SetJumpConfig(tItemTipJumpCfg.fJumpCallback, sJumpClickTxt)
  end
  self:_ClearAvatarIcon()
  self:RemoveDecomposeItem()
  if self._downloadPollTimer and self._nLastShowItemId ~= self._nItemId then
    self:RemoveTimer(self._downloadPollTimer)
    self._downloadPollTimer = nil
  end
end
function Common_Items_UIBP:_CreateCommonItemChildUI(sChildName, tChildCfg)
  if self[sChildName] then
    return self[sChildName]
  end
  tChildCfg = tChildCfg or CommonItem_ChildCfg[sChildName]
  if not tChildCfg then
    log(bWriteLog and " Common Item Not Child Node Cfg By Name >>>>", sChildName)
    return
  end
  self[sChildName] = self:CreateChildWindowWithBpPath(tChildCfg.sParentName, UIManager.UI_Config.CommonItemChildUIWithoutBpPath, tChildCfg.sBpPath)
  self[sChildName]:SetZOrder(tChildCfg.nZOrder)
  return self[sChildName]
end
function Common_Items_UIBP:_RemoveCommonItemChildUI(sChildName)
  if not self[sChildName] then
    return
  end
  self[sChildName]:Close()
  self[sChildName] = nil
end
function Common_Items_UIBP:_CreateOrRemoveCommonItemChildUI(sChildName, bIsShow)
  if bIsShow then
    local cObj = self:_CreateCommonItemChildUI(sChildName)
    return cObj
  else
    self:_RemoveCommonItemChildUI(sChildName)
  end
end
function Common_Items_UIBP:_RefreshShow()
  self:_RefreshIconShow()
  self:RefreshQualityShow()
  self:_RefreshItemCountShow()
  self:_RefreshValidTimeShow()
  self:_RefreshDownloadUI()
end
function Common_Items_UIBP:_RefreshIconShow(nShowItemId)
  local node_root = self.UIRoot
  local tExtraData = self._tExtraData or {}
  self._decomposeItemID = nil
  if not nShowItemId then
    local nItemId = self._nItemId
    if not nItemId then
      return
    end
    nShowItemId = tExtraData.displayResId or nItemId
    if self._nLastShowItemId == nShowItemId then
      local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
      local sAvatarIconPath = headshot_module:GetAvatarIconCfg(nShowItemId)
      if sAvatarIconPath then
        if not self._gifWidget or not slua.isValid(self._gifWidget) then
          local AvatarGIFImageBPPool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarGIFImageBPPool)
          self._gifWidget = AvatarGIFImageBPPool:GetAvatarGIFImage(node_root.ScaleBox_AvatarIcon, sAvatarIconPath)
        end
        node_root.Switcher_IconShow:SetActiveWidgetIndex(1)
      end
      return
    end
  end
  local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
  local sAvatarIconPath = headshot_module:GetAvatarIconCfg(nShowItemId)
  if sAvatarIconPath then
    local AvatarGIFImageBPPool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarGIFImageBPPool)
    self._gifWidget = AvatarGIFImageBPPool:GetAvatarGIFImage(node_root.ScaleBox_AvatarIcon, sAvatarIconPath)
    node_root.Switcher_IconShow:SetActiveWidgetIndex(1)
  else
    self:_SetIconPadding(nShowItemId)
    self:_SetIconTextureByItemId(nShowItemId)
    node_root.Switcher_IconShow:SetActiveWidgetIndex(0)
  end
  self._nLastShowItemId = nShowItemId
  self:SetSpecialIconShow(true)
  self:_RefreshCoBrandedShow()
  self:SetSignIconShow(true)
  self:SetCheckIsPetSuitIcon(true)
end
function Common_Items_UIBP:_RefreshCoBrandedShow()
  local nItemId = self._nItemId
  local uObj_itemCoBrandedCfg = CDataTable.GetTableData("ItemCoBrandedConfig", nItemId)
  if uObj_itemCoBrandedCfg and uObj_itemCoBrandedCfg.coType and uObj_itemCoBrandedCfg.coType >= 2 then
    local cObj_coBranded = self:_CreateCommonItemChildUI(Enum_ChildName.CoBranded)
    if not cObj_coBranded then
      return
    end
    cObj_coBranded:UIOperation(function(cObj_ui)
      local node_coBrandedRoot = cObj_ui.UIRoot
      local nShowCoBrandedIndex = uObj_itemCoBrandedCfg.coType
      node_coBrandedRoot.Switcher_Joint:SetActiveWidgetIndex(nShowCoBrandedIndex - 1)
    end)
  else
    self:_RemoveCommonItemChildUI(Enum_ChildName.CoBranded)
  end
end
function Common_Items_UIBP:_RefreshGoldEquipQualityShow(nQuality)
  if nQuality == ItemMacros.QUALITY_GOLDEN then
    local cObj_goldEquipQuality = self:_CreateCommonItemChildUI(Enum_ChildName.GoldEquipQuality)
    if not cObj_goldEquipQuality then
      return
    end
    cObj_goldEquipQuality:SelfHitTestInvisible()
  else
    self:_RemoveCommonItemChildUI(Enum_ChildName.GoldEquipQuality)
  end
end
function Common_Items_UIBP:_RefreshItemCountShow()
  local nCount = tonumber(self._nCount) or 0
  local tExtraData = self._tExtraData or {}
  local node_root = self.UIRoot
  local bIsShowZero = tExtraData.bIsShowZero
  local bIsHideCount = tExtraData.bIsHideCount
  local bIsShow = bIsShowZero and 0 <= nCount or 0 < nCount
  self:SetWidgetVisible(node_root.RichText_ItemCount, bIsShow and not bIsHideCount)
  if not bIsShow then
    return
  end
  local bIsRoleWear = tExtraData.bIsRoleWear
  if bIsRoleWear then
    local nUseCount = tExtraData.nUseCount or 0
    node_root.RichText_ItemCount:SetText(LocUtil.LocalizeResFormat(6830, nCount - nUseCount, nCount))
    self:_RichTextItemCountForceLayoutPrepass()
    return
  end
  node_root.RichText_ItemCount:SetText(FuncUtil.TransformNumToFormatStr(nCount))
  self:_RichTextItemCountForceLayoutPrepass()
end
function Common_Items_UIBP:_RichTextItemCountForceLayoutPrepass()
  local node_root = self.UIRoot
  if self._tExtraData.bForceTextPrepass then
    node_root.RichText_ItemCount:ForceLayoutPrepass()
  end
end
function Common_Items_UIBP:_RefreshValidTimeShow()
  local bIsCanShowValidTimeIcon = self:_IsCanShowValidTimeIcon()
  if not bIsCanShowValidTimeIcon then
    self:_RemoveCommonItemChildUI(Enum_ChildName.LimitIcon)
    return
  end
  local tExtraData = self._tExtraData or {}
  local uObj_itemCfg = self:_GetItemCfg()
  if not uObj_itemCfg then
    self:_RemoveCommonItemChildUI(Enum_ChildName.LimitIcon)
    return
  end
  local bIsLimit = tExtraData.bIsLimit or tExtraData.is_limit
  local nValidTime = self._nValidTime or 0
  local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
  if not bIsLimit and not CommonItem_Utils.CheckIsValidTimeItem(self._nItemId, nValidTime) then
    self:_RemoveCommonItemChildUI(Enum_ChildName.LimitIcon)
    return
  end
  local colorOfLimitIcon = tExtraData.ColorOfLimitIcon or FLinearColor(1, 1, 1, 1)
  local cObj_limitIcon = self:_CreateCommonItemChildUI(Enum_ChildName.LimitIcon)
  if not cObj_limitIcon then
    return
  end
  cObj_limitIcon:UIOperation(function(cObj_ui)
    local node_limitIconRoot = cObj_ui.UIRoot
    node_limitIconRoot.Image_LimitTime:SetColorAndOpacity(colorOfLimitIcon)
  end)
end
function Common_Items_UIBP:_RefreshDownloadUI()
  local node_root = self.UIRoot
  local tDownloadAllItem = self:_GetDownloadList()
  local TableUtil = require("common.table_util")
  local bIsSame = TableUtil.IsSameTable(tDownloadAllItem, self._tLastDownList)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local nCurDownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tDownloadAllItem)
  if bIsSame and nCurDownloadState ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  self._tLastDownList = tDownloadAllItem
  local tExtraData = self._tExtraData or {}
  local common_download_handler = require("client.slua.common.common_download_handler")
  local tDownLoadParams = {
    callback = function()
      if not self._nItemId or not slua.isValid(self.UIRoot) then
        return
      end
      local nDownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tDownloadAllItem)
      if nDownloadState == PufferConst.ENUM_DownloadState.Done then
        self:_RefreshValidTimeShow()
        self:_RefreshDownloadUI()
        if tExtraData.fDownloadFinishedCallback then
          tExtraData.fDownloadFinishedCallback()
        end
      end
    end,
    clickCallback = tExtraData.fDownloadClickCallback,
    disableClickDownLoadPutOn = tExtraData.disableClickDownLoadPutOn,
    showSize = tExtraData.showDownloadSize,
    showAlertSize = tExtraData.showAlertSize,
    item_time_limit = self._nValidTime,
    is_limit_time = self._nValidTime > 0,
    hideIconBg = true,
    bShowIconOnly = true,
    from = tExtraData.nDownloadFrom
  }
  self._cObj_downloadUI = common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, tDownloadAllItem, self, node_root.Panel_Download, tDownLoadParams)
end
function Common_Items_UIBP:InitView(nItemId, nCount, nValidTime, tExtraData)
  self._cObj_promise = nil
  if not nItemId then
    log(bWriteLog and " Common_Items_UIBP InitView, nItemId is nil")
    return
  end
  local TableUtil = require("common.table_util")
  tExtraData = tExtraData and TableUtil.CopyTable(tExtraData) or {}
  if not Client.IsShipping() and nValidTime and 100000000 < nValidTime then
    local utility = require("common.utility")
    utility.ErrorMessageHandler("Lua_CommonItems.InitView, nItemId is " .. nItemId .. " >>> validHour is " .. nValidTime)
  end
  self._  self._nCount = nCount or 0
  self._nValidTime = nValidTime or 0
  self._  if tExtraData.affixs and not next(tExtraData.affixs) then
    tExtraData.affixs = nil
  end
  printf("Common_Items_UIBP:InitView. nItemId=%s", tostring(nItemId))
  self:UIOperation(function()
    self:_InitResetShow()
    self:_RefreshShow()
  end)
end
function Common_Items_UIBP:SetCustomSize(nWidth, nHeight)
  self:UIOperation(function()
    local node_root = self.UIRoot
    node_root.CanvasPanel_Size.Slot:SetAnchors(FAnchors(0, 0, 0, 0))
    node_root.CanvasPanel_Size.Slot:SetSize(FVector2D(nWidth, nHeight))
    self._bIsCustomSize = true
  end)
end
function Common_Items_UIBP:RefreshQualityShow(nShowItemId)
  self:UIOperation(function()
    nShowItemId = nShowItemId or self._nItemId
    if not nShowItemId then
      return
    end
    local tExtraData = self._tExtraData or {}
    local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
    local nQuality = CommonItem_Utils.GetQuality(nShowItemId, tExtraData)
    local specialBgID = nShowItemId
    if tExtraData.displayResId and tExtraData.displayResId ~= 0 then
      specialBgID = tExtraData.displayResId
    end
    self:SetQuality(nQuality, specialBgID)
  end)
end
function Common_Items_UIBP:OnDragClickHandler()
  if self._cObj_downloadUI and slua.isValid(self._cObj_downloadUI.UIRoot) then
    if not self._cObj_downloadUI:IsAsyncLoading() then
      self._cObj_downloadUI.UIRoot:OnClickDownload()
    end
    return
  end
  self:OnItemBtnClick()
end
function Common_Items_UIBP:SetIconPaddingByIsAvatar(bIsAvatarIcon)
  self:UIOperation(function()
    self._tExtraData.    local node_root = self.UIRoot
    if bIsAvatarIcon then
      node_root.ScaleBox_Icon.Slot:SetPadding(_uObj_AvatarShow)
    else
      node_root.ScaleBox_Icon.Slot:SetPadding(_uObj_3DisShow)
    end
  end)
end
function Common_Items_UIBP:SetIconFromTexture(uObj_texture, bMatchSize)
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:_ClearShowIconTimer()
    self._ShowIconPath = nil
    self:_CancelCDNImageDownload()
    node_root.Image_Icon:SetBrushFromTexture(uObj_texture, bMatchSize or false)
    self:SetWidgetVisible(node_root.Image_Icon, true)
    node_root.Switcher_IconShow:SetActiveWidgetIndex(0)
    self:_ClearAvatarIcon(true)
  end)
end
function Common_Items_UIBP:SetIconFromPath(sPicPath, extendedParams)
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:_ClearShowIconTimer()
    extendedParams = extendedParams or {}
    extendedParams.sync = false
    self._ShowIconPath = sPicPath
    self:_CancelCDNImageDownload()
    local downloadImageIndex = self:SetTexture(node_root.Image_Icon, sPicPath, extendedParams)
    if downloadImageIndex and 0 < downloadImageIndex then
      self._CDNImageDownloadIndex = downloadImageIndex
    end
    self:SetWidgetVisible(node_root.Image_Icon, true)
    node_root.Switcher_IconShow:SetActiveWidgetIndex(0)
    self:_ClearAvatarIcon(true)
  end)
end
function Common_Items_UIBP:SetQualityBg(sPicPath)
  self:UIOperation(function()
    local node_root = self.UIRoot
    node_root.Image_Quality:SetBrushFromTexture(nil, true)
    self:_RemoveCommonItemChildUI(Enum_ChildName.GoldEquipQuality)
    self:SetTexture(node_root.Image_Quality, sPicPath, {sync = false})
    self:SetWidgetVisible(node_root.Image_Quality, true)
  end)
end
function Common_Items_UIBP:SetUseCount(nUseCount, bIsRoleWear, bIsShowZero)
  self:UIOperation(function()
    local tExtraData = self._tExtraData
    if not tExtraData then
      return
    end
    tExtraData.    tExtraData.    tExtraData.    self:_RefreshItemCountShow()
  end)
end
function Common_Items_UIBP:SetNumber(nCount, bIsShowZero)
  self:UIOperation(function()
    local tExtraData = self._tExtraData
    if not tExtraData then
      return
    end
    self._    tExtraData.    self:_RefreshItemCountShow()
  end)
end
function Common_Items_UIBP:EnableShowTips(bIsShowTip)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.end
function Common_Items_UIBP:EnableItemPreview(nShowPreviewType, tShowPreviewParams, bPreviewFromSelf)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.bIsShowItemPreview = true
  tExtraData.  tExtraData.  tExtraData.end
function Common_Items_UIBP:DisableItemPreview()
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.bIsShowItemPreview = false
  tExtraData.nShowPreviewType = nil
  tExtraData.tShowPreviewParams = nil
  tExtraData.bPreviewFromSelf = nil
end
function Common_Items_UIBP:EnableClick()
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.bDisableClick = false
end
function Common_Items_UIBP:DisableClick()
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.bDisableClick = true
end
function Common_Items_UIBP:SetPartnerItemShowPreview(bShow)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.bIsShowPartnerItemPreview = bShow
end
function Common_Items_UIBP:SetPersonalizedItemPreview(bShow)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.bIsShowPersonalizedItemPreview = bShow
end
function Common_Items_UIBP:SetClickItemCallback(fCallback, ...)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.fClickItemCallback = fCallback
  tExtraData.tClickItemCallbackParam = table.pack(...)
end
function Common_Items_UIBP:SetCountScaleSize()
  self:UIOperation(function()
    local node_root = self.UIRoot
    local nLeftDis = 4
    if self[Enum_ChildName.LimitIcon] then
      nLeftDis = 40
    end
    self._bIsChangeCountScale = true
    local uObj_slot = node_root.ScaleBox_Count.Slot
    uObj_slot:SetAnchors(FAnchors(0, 1, 1, 1))
    uObj_slot:SetOffsets(FMargin(nLeftDis, 0, 4, 40))
  end)
end
function Common_Items_UIBP:SetCountFontSize(nFontSize)
  self:UIOperation(function()
    self._bIsChangeFontSize = true
    local node_root = self.UIRoot
    local uObj_font = node_root.RichText_ItemCount.Font
    uObj_font.Size = nFontSize
    node_root.RichText_ItemCount:SetFont(uObj_font)
    self:_RichTextItemCountForceLayoutPrepass()
  end)
end
function Common_Items_UIBP:SetCostCount(nHasCount, nNeedCount)
  self:UIOperation(function()
    if not nHasCount or not nNeedCount then
      return
    end
    local node_root = self.UIRoot
    local sTextKey = 69919
    if nHasCount < nNeedCount then
      sTextKey = 69918
    end
    local tExtraData = self._tExtraData or {}
    node_root.RichText_ItemCount:SetText(LocUtil.LocalizeResFormat(sTextKey, nHasCount, nNeedCount))
    local bIsHideCount = tExtraData.bIsHideCount
    self:SetWidgetVisible(node_root.RichText_ItemCount, not bIsHideCount)
    self:_RichTextItemCountForceLayoutPrepass()
  end)
end
function Common_Items_UIBP:SetShadowCostCount(nHasCount, nNeedCount)
  self:UIOperation(function()
    if not nHasCount or not nNeedCount then
      return
    end
    local node_root = self.UIRoot
    local sTextKey = 200000634
    if nHasCount < nNeedCount then
      sTextKey = 200000635
    end
    local tExtraData = self._tExtraData or {}
    node_root.RichText_ItemCount:SetText(LocUtil.LocalizeResFormat(sTextKey, nHasCount, nNeedCount))
    local bIsHideCount = tExtraData.bIsHideCount
    self:SetWidgetVisible(node_root.RichText_ItemCount, not bIsHideCount)
    self:_RichTextItemCountForceLayoutPrepass()
  end)
end
function Common_Items_UIBP:SetIsNew(bIsNew, newColor)
  self:UIOperation(function()
    local cObj_New = self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.NewTip, bIsNew)
    if not cObj_New then
      return
    end
    cObj_New:UIOperation(function(cObj_ui)
      local defaultColor = FSlateColor(FLinearColor(1, 0.92, 0, 1))
      cObj_ui.UIRoot.Text_New:SetColorAndOpacity(newColor or defaultColor)
    end)
  end)
end
function Common_Items_UIBP:SetIsIncreaseProbability(bIsShowUp)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.ProbabilityUp, bIsShowUp)
  end)
end
function Common_Items_UIBP:SetPlusSuperscript(bIsShowUp)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.PlusSuperscript, bIsShowUp)
  end)
end
function Common_Items_UIBP:SetCheckIsPetSuitIcon(bIsShowUp)
  self:UIOperation(function()
    local itemCfg = self:_GetItemCfg()
    if not itemCfg or not bIsShowUp then
      self:_RemoveCommonItemChildUI(Enum_ChildName.PetSuitIcon)
      return
    end
    if itemCfg.ItemType ~= ENUM_ITEM_TYPE.Buddy_New then
      self:_RemoveCommonItemChildUI(Enum_ChildName.PetSuitIcon)
      return
    end
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.PetSuitIcon, bIsShowUp)
  end)
end
function Common_Items_UIBP:SetIsShowExclusiveOneYearPng(bIsShow)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.ExculsiveOneYear, bIsShow)
  end)
end
function Common_Items_UIBP:SetUsingState(bIsUsing)
  self:UIOperation(function()
    if bIsUsing then
      self:SetIsNew(false)
    end
    self:CORChildUIRefreshImage(Enum_ChildName.Using, nil, bIsUsing, Enum_UIBP_NodeName.Image_LeftTopIcon, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Image_Using_png.Common_Image_Using_png")
  end)
end
function Common_Items_UIBP:SetSpecialIcon(sPath, bHasAddKnownMissing)
  self:UIOperation(function()
    if sPath and sPath ~= "" then
      local cObj_specialIcon = self:_CreateCommonItemChildUI(Enum_ChildName.SpecialIcon)
      if not cObj_specialIcon then
        return
      end
      cObj_specialIcon:UIOperation(function(cObj_ui)
        local params = {bMatchSize = true, bHasAddKnownMissing = bHasAddKnownMissing}
        cObj_ui:SetTexture(cObj_ui.UIRoot.Image_SpecialIcon, sPath, params)
        local GlobalUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
        local nWidth, nHeight = GlobalUIFunctionLibrary.GetImagePixelSize(sPath)
        local sizeX, sizeY
        if nWidth == nHeight then
          sizeX, sizeY = 55, 55
        elseif nHeight < nWidth then
          sizeX, sizeY = 110, math.min(nHeight, 55)
        else
          sizeX, sizeY = math.min(nWidth, 55), 110
        end
        cObj_ui:AddTimerOnce(0, function()
          cObj_ui.UIRoot.ScaleBox_SpecialIcon.Slot:SetSize(FVector2D(sizeX, sizeY))
        end)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.SpecialIcon)
    end
  end)
end
function Common_Items_UIBP:SetSignIcon(sPath, bHasAddKnownMissing)
  self:UIOperation(function()
    if sPath and sPath ~= "" then
      local _cObj_signature = self:_CreateCommonItemChildUI(Enum_ChildName.Signature)
      if not _cObj_signature then
        return
      end
      _cObj_signature:UIOperation(function(cObj_ui)
        local params = {
          sync = false,
          bMatchSize = true,
                  }
        cObj_ui:SetTexture(cObj_ui.UIRoot.Image_Icon, sPath, params)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.Signature)
    end
  end)
end
function Common_Items_UIBP:SetIsHavePVEAffix(bIsHave)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.AffixPVEIcon, bIsHave)
  end)
end
function Common_Items_UIBP:SetIsLock(bIsLock, bIsCheckMask)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.Lock, bIsLock)
    if bIsCheckMask then
      self:SetBlackMask(bIsLock)
    end
  end)
end
function Common_Items_UIBP:SetHasGet(bHasGet)
  self:UIOperation(function()
    if bHasGet then
      self:_CreateCommonItemChildUI(Enum_ChildName.HasGet)
      self:SetBlackMask(true)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.HasGet)
      self:SetBlackMask(false)
    end
  end)
end
function Common_Items_UIBP:SetBlackMask(bIsShowMask)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.BlackMask, bIsShowMask)
  end)
end
function Common_Items_UIBP:SetAwardState(nState)
  self:UIOperation(function()
    local Enum_ItemStatus = CommonItem_Const.Enum_ItemStatus
    if nState == Enum_ItemStatus.Not then
      self:SetHasGet(false)
      self:SetBlackMask(false)
      self:SetIsLock(true)
      self:SetLight(false)
    elseif nState == Enum_ItemStatus.Done then
      self:SetHasGet(false)
      self:SetBlackMask(false)
      self:SetIsLock(false)
      self:SetLight(true)
    elseif nState == Enum_ItemStatus.Got then
      self:SetHasGet(true)
      self:SetBlackMask(true)
      self:SetIsLock(false)
      self:SetLight(false)
    end
  end)
end
function Common_Items_UIBP:SetColorAndPattern(nColorId, nPatternId)
  self:UIOperation(function()
    if nColorId ~= 0 or nPatternId ~= 0 then
      local cObj_diyClothingIcon = self[Enum_ChildName.DiyClothingIcon]
      if not cObj_diyClothingIcon then
        cObj_diyClothingIcon = self:CreateChildWindow("CanvasPanel_ItemShow", UIManager.UI_Config.CommonItem_DiyClothingIcon_UIBP, nColorId, nPatternId)
        self[Enum_ChildName.DiyClothingIcon] = cObj_diyClothingIcon
      end
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.DiyClothingIcon)
    end
  end)
end
function Common_Items_UIBP:SetIsUnlockParticleEmote(bIsShow)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.ParticleStar, bIsShow)
  end)
end
function Common_Items_UIBP:SetIsOpenParticleEmote(bIsOpen)
  self:UIOperation(function()
    if not self[Enum_ChildName.ParticleStar] then
      return
    end
    local nIndex = bIsOpen and 1 or 0
    local node_starRoot = self[Enum_ChildName.ParticleStar].UIRoot
    node_starRoot.Switcher_ParticleStar:SetActiveWidgetIndex(nIndex)
  end)
end
function Common_Items_UIBP:SetCenterTextShow(sContentStr, nFontSize)
  self:UIOperation(function()
    if sContentStr and sContentStr ~= "" then
      local cObj_contentText = self:_CreateCommonItemChildUI(Enum_ChildName.ContentText)
      if not cObj_contentText then
        return
      end
      cObj_contentText:UIOperation(function(cObj_ui)
        local node_contentTextRoot = cObj_ui.UIRoot
        node_contentTextRoot.Text_Content:SetText(sContentStr)
        local Font = node_contentTextRoot.Text_Content.Font
        Font.Size = nFontSize or 15
        node_contentTextRoot.Text_Content:SetFont(Font)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.ContentText)
    end
  end)
end
function Common_Items_UIBP:SetIsolated(bIsIsolated, sCustomText)
  self:UIOperation(function()
    local str = LocUtil.GetLocalizeResStr(7474)
    if sCustomText then
      str = sCustomText
    end
    self:SetCenterTextShow(bIsIsolated and str)
  end)
end
function Common_Items_UIBP:SetSelected(bIsSelected)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.Selected, bIsSelected)
  end)
end
function Common_Items_UIBP:SetIconAndQualityAlpha(nAlpha)
  self:UIOperation(function()
    if not nAlpha then
      return
    end
    local node_root = self.UIRoot
    node_root.Image_Icon:SetOpacity(nAlpha)
    node_root.Image_Quality:SetOpacity(nAlpha)
  end)
end
function Common_Items_UIBP:SetIconAlpha(nAlpha)
  self:UIOperation(function()
    if not nAlpha then
      return
    end
    local node_root = self.UIRoot
    node_root.Image_Icon:SetOpacity(nAlpha)
  end)
end
function Common_Items_UIBP:SetIconIsShow(bIsShow)
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:SetWidgetVisible(node_root.Switcher_IconShow, bIsShow)
  end)
end
function Common_Items_UIBP:SetQuality(nQuality, specialBgID)
  self:UIOperation(function()
    if not nQuality then
      return
    end
    local node_root = self.UIRoot
    node_root.Image_Quality:SetBrushFromTexture(nil, true)
    self:_RefreshGoldEquipQualityShow(nQuality)
    local specialQualityBg, bHasAddKnownMissing = UIUtil.GetSpecialQualityBg(specialBgID, node_root.Image_Quality)
    if specialQualityBg and specialQualityBg ~= "" then
      log(bWriteLog and "[SY]Common_Items_UIBP:SetQuality.specialQualityBg: " .. tostring(specialQualityBg))
      self:SetTexture(node_root.Image_Quality, specialQualityBg, {sync = false, bHasAddKnownMissing = bHasAddKnownMissing})
    else
      local sQualityIcon = UIUtil.GetBgQualityPath(nQuality)
      self:SetTexture(node_root.Image_Quality, sQualityIcon, {sync = false, bHasAddKnownMissing = bHasAddKnownMissing})
    end
    self:SetWidgetVisible(node_root.Image_Quality, true)
  end)
end
function Common_Items_UIBP:SetLight(bIsShow, bIsHideSweepLight)
  self:UIOperation(function()
    if bIsShow then
      local cObj_effect = self:_CreateCommonItemChildUI(Enum_ChildName.GlowingEffect)
      if not cObj_effect then
        return
      end
      cObj_effect:UIOperation(function(cObj_ui)
        local node_childRoot = cObj_ui.UIRoot
        self:SetWidgetVisible(node_childRoot.Image_SweepLight, not bIsHideSweepLight)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.GlowingEffect)
    end
  end)
end
function Common_Items_UIBP:SetCollectNum(nScore)
  self:UIOperation(function()
    if nScore and 0 < nScore then
      local cObj_collectNum = self:_CreateCommonItemChildUI(Enum_ChildName.CollectNum)
      if not cObj_collectNum then
        return
      end
      cObj_collectNum:UIOperation(function(cObj_ui)
        local node_collectNumRoot = cObj_ui.UIRoot
        node_collectNumRoot.Text_Collect:SetText(nScore)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.CollectNum)
    end
  end)
end
function Common_Items_UIBP:SetShowInheritIcon(bShow)
  self:UIOperation(function()
    if bShow then
      self:_CreateCommonItemChildUI(Enum_ChildName.InheritIcon)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.InheritIcon)
    end
  end)
end
function Common_Items_UIBP:SetTimeLimitIcon(bIsShow)
  self:UIOperation(function()
    local tExtraData = self._tExtraData
    if not tExtraData then
      return
    end
    tExtraData.bIsLimit = bIsShow
    self:_RefreshValidTimeShow()
  end)
end
function Common_Items_UIBP:SetIsWear(bIsEquipping)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.Equipping, bIsEquipping)
  end)
end
function Common_Items_UIBP:SetShowSharedIcon(bIsShow, nShareType)
  self:UIOperation(function()
    if bIsShow then
      local cObj_sharedBackpack = self:_CreateCommonItemChildUI(Enum_ChildName.SharedBackpack)
      if not cObj_sharedBackpack then
        return
      end
      cObj_sharedBackpack:UIOperation(function(cObj_ui)
        local node_sharedBackpackRoot = cObj_ui.UIRoot
        local nIndex = nShareType == 2 and 1 or 0
        node_sharedBackpackRoot.WidgetSwitcher_Shared:SetActiveWidgetIndex(nIndex)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.SharedBackpack)
    end
  end)
end
function Common_Items_UIBP:SetIsTryOn(bIsTryOn)
  self:UIOperation(function()
    self:_CreateOrRemoveCommonItemChildUI(Enum_ChildName.TryOnText, bIsTryOn)
  end)
end
function Common_Items_UIBP:HideQuality()
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:SetWidgetVisible(node_root.Image_Quality, false)
  end)
end
function Common_Items_UIBP:HideItemButton()
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:SetWidgetVisible(node_root.Button_Item, false, true)
  end)
end
function Common_Items_UIBP:HideImageIcon()
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:SetWidgetVisible(node_root.Image_Icon, false, false)
  end)
end
function Common_Items_UIBP:SetShowUseTime(bShowUseTime)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.end
function Common_Items_UIBP:SetMatchNum(bShow, nNum)
  self:UIOperation(function()
    if bShow then
      local cObj_MatchNum = self:_CreateCommonItemChildUI(Enum_ChildName.MatchNum)
      if not cObj_MatchNum then
        return
      end
      cObj_MatchNum:UIOperation(function(cObj_ui)
        local node_childRoot = cObj_ui.UIRoot
        if slua.isValid(node_childRoot) and node_childRoot.Text_Num then
          node_childRoot.Text_Num:SetText(nNum)
        end
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.MatchNum)
    end
  end)
end
function Common_Items_UIBP:SetJumpConfig(fJumpCallback, sJumpClickTxt)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.  tExtraData.end
function Common_Items_UIBP:SetSpecialContent(sSpecialContent, nSpecialContentFontSize)
  local tExtraData = self._tExtraData
  if not tExtraData then
    return
  end
  tExtraData.  tExtraData.end
function Common_Items_UIBP:SetIsRedEmotion(bIsRedEmotion, bIsRed)
  self:UIOperation(function()
    if bIsRedEmotion then
      local color = FLinearColor(1, 1, 1, 1)
      if bIsRed then
        color = FLinearColor(1, 0, 0, 0.7)
      end
      local cObj_redEmotion = self:_CreateCommonItemChildUI(Enum_ChildName.RedEmotion)
      if not cObj_redEmotion then
        return
      end
      cObj_redEmotion:UIOperation(function(cObj_ui)
        local node_childRoot = cObj_ui.UIRoot
        if slua.isValid(node_childRoot) and node_childRoot.Image_BanIcon then
          node_childRoot.Image_BanIcon:SetColorAndOpacity(color)
        end
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.RedEmotion)
    end
  end)
end
function Common_Items_UIBP:PlayDecomposeAni(nOldItemID, tDecItem)
  self:UIOperation(function()
    local nItemId = not tDecItem or tDecItem.itemid or tDecItem.resid
    if nOldItemID and 0 < nOldItemID and nItemId and 0 < nItemId then
      local node_root = self.UIRoot
      node_root.Switcher_IconShow:SetActiveWidgetIndex(2)
      self._decomposeItemID = nItemId
      local cObj_decompose = self[Enum_ChildName.Decompose]
      if not cObj_decompose then
        cObj_decompose = self:CreateChildWindow("Canvas_Decompose", UIManager.UI_Config.CommonItem_Decompose_UIBP, nOldItemID, tDecItem)
        self[Enum_ChildName.Decompose] = cObj_decompose
      end
      cObj_decompose:UIOperation(function(cObj_ui)
        local cObj_temp = cObj_ui
        self._bIsPlayingDecomposeAni = true
        cObj_temp:PlayDecomposeAni()
      end)
    else
      self:RemoveDecomposeItem()
    end
  end)
end
function Common_Items_UIBP:ShowDecompose(nOldItemID, tDecItem)
  self:UIOperation(function()
    local nItemId = not tDecItem or tDecItem.itemid or tDecItem.resid
    if nOldItemID and 0 < nOldItemID and nItemId and 0 < nItemId then
      local node_root = self.UIRoot
      node_root.Switcher_IconShow:SetActiveWidgetIndex(2)
      self._decomposeItemID = nItemId
      local cObj_decompose = self[Enum_ChildName.Decompose]
      if not cObj_decompose then
        cObj_decompose = self:CreateChildWindow("Canvas_Decompose", UIManager.UI_Config.CommonItem_Decompose_UIBP, nOldItemID, tDecItem)
        self[Enum_ChildName.Decompose] = cObj_decompose
      end
      cObj_decompose:UIOperation(function(cObj_ui)
        local cObj_temp = cObj_ui
        self._bIsPlayingDecomposeAni = true
        cObj_temp:ShowDecompose()
      end)
    else
      self:RemoveDecomposeItem()
    end
  end)
end
function Common_Items_UIBP:RemoveDecomposeItem()
  self:UIOperation(function()
    local node_root = self.UIRoot
    self:_RemoveCommonItemChildUI(Enum_ChildName.Decompose)
    node_root.Switcher_IconShow:SetActiveWidgetIndex(0)
  end)
end
function Common_Items_UIBP:GetExtraData()
  return self._tExtraData or {}
end
function Common_Items_UIBP:SetSpecialIconShow(bIsShow)
  self:UIOperation(function()
    local nItemId = self._nItemId
    if not nItemId then
      return
    end
    local uObj_itemCfg = self:_GetItemCfg()
    if not (bIsShow and uObj_itemCfg and uObj_itemCfg.SpecialIcon) or uObj_itemCfg.SpecialIcon == "" then
      self:_RemoveCommonItemChildUI(Enum_ChildName.SpecialIcon)
      return
    end
    local cObj_specialIcon = self:_CreateCommonItemChildUI(Enum_ChildName.SpecialIcon)
    if not cObj_specialIcon then
      return
    end
    cObj_specialIcon:UIOperation(function(cObj_ui)
      local Image_SpecialIcon = cObj_ui.UIRoot.Image_SpecialIcon
      local sSpecialIcon, bHasAddKnownMissingSp = UIUtil.GetItemSpecialIcon(nItemId, Image_SpecialIcon)
      self:SetSpecialIcon(sSpecialIcon, bHasAddKnownMissingSp)
    end)
  end)
end
function Common_Items_UIBP:SetSignIconShow(bIsShow)
  self:UIOperation(function()
    local nItemId = self._nItemId
    if not nItemId then
      return
    end
    local signEffectCfg = CDataTable.GetTableData("SignEffectCfg", nItemId)
    if not (bIsShow and signEffectCfg and signEffectCfg.Icon) or signEffectCfg.Icon == "" then
      self:_RemoveCommonItemChildUI(Enum_ChildName.Signature)
      return
    end
    local store_utils = require("client.slua.logic.store.utils.store_utils")
    if not store_utils.HasItem(nItemId) then
      self:_RemoveCommonItemChildUI(Enum_ChildName.Signature)
      return
    end
    local _cObj_signature = self:_CreateCommonItemChildUI(Enum_ChildName.Signature)
    if not _cObj_signature then
      return
    end
    _cObj_signature:UIOperation(function(cObj_ui)
      local Image_Icon = cObj_ui.UIRoot.Image_Icon
      local icon, bHasAddKnownMissing = UIUtil.GetSignatureIcon(nItemId, Image_Icon)
      self:SetSignIcon(icon, bHasAddKnownMissing)
    end)
  end)
end
function Common_Items_UIBP:SetUpgradeDiscountNumShow(nHasCount, nCostOriPrice, nCostDisPrice, bIsInActivityTime)
  self:UIOperation(function()
    if bIsInActivityTime and nHasCount and nCostOriPrice and nCostDisPrice and 0 < nCostDisPrice and nCostOriPrice > nCostDisPrice then
      local cObj_upgradeDiscountNum = self:_CreateCommonItemChildUI(Enum_ChildName.UpgradeDiscountNum)
      if not cObj_upgradeDiscountNum then
        return
      end
      cObj_upgradeDiscountNum:UIOperation(function(cObj_ui)
        cObj_ui.UIRoot.TextBlock_ItemNum:SetText(nHasCount)
        cObj_ui.UIRoot.TextBlock_OriPrice:SetText(nCostOriPrice)
        cObj_ui.UIRoot.TextBlock_DisPrice:SetText(nCostDisPrice)
        if nHasCount >= nCostDisPrice then
          cObj_ui.UIRoot.TextBlock_ItemNum:SetColorAndOpacity(_uObj_greenColor)
        else
          cObj_ui.UIRoot.TextBlock_ItemNum:SetColorAndOpacity(_uObj_redColor)
        end
        local nDiscount = (nCostOriPrice - nCostDisPrice) / nCostOriPrice * 100
        local nFinalDiscount = math.floor(nDiscount * 10) / 10
        local nCostDisRate = string.format("%.1f", nFinalDiscount)
        cObj_ui.UIRoot.TextBlock_DiscountRate:SetText(LocUtil.LocalizeResFormat(37287, nCostDisRate))
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.UpgradeDiscountNum)
    end
  end)
end
function Common_Items_UIBP:SetIsShowExclusivePng(bIsShow)
  self:UIOperation(function()
    self:CORChildUIRefreshImage(Enum_ChildName.Exclusive, nil, bIsShow, Enum_UIBP_NodeName.Image_LeftTopIcon, "/Game/UMG/Texture/Atlas/CommonConer_Atlas/Frames/Icon_Exclusive_png.Icon_Exclusive_png")
  end)
end
function Common_Items_UIBP:SetCollectStatus(bIsShow, bIsCollected)
  self:UIOperation(function()
    if bIsShow then
      local cObj_collectStatus = self:_CreateCommonItemChildUI(Enum_ChildName.CollectStatus)
      if not cObj_collectStatus then
        return
      end
      cObj_collectStatus:UIOperation(function(cObj_ui)
        local node_childRoot = cObj_ui.UIRoot
        if not node_childRoot then
          return
        end
        node_childRoot.WidgetSwitcher_CollectStatus:SetActiveWidgetIndex(bIsCollected and 1 or 0)
      end)
    else
      self:_RemoveCommonItemChildUI(Enum_ChildName.CollectStatus)
    end
  end)
end
function Common_Items_UIBP:SetIconSpacerShow(bIsIconSpacerShow)
  self:UIOperation(function()
    self._tExtraData.    local node_root = self.UIRoot
    if bIsIconSpacerShow then
      node_root.ScaleBox_Icon.Slot:SetPadding(_uObj_iconSpacerShow)
      node_root.Image_Icon.Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Fill)
      node_root.Image_Icon.Slot:SetVerticalAlignment(EVerticalAlignment.VAlign_Fill)
    else
      node_root.ScaleBox_Icon.Slot:SetPadding(_uObj_3DisShow)
      node_root.Image_Icon.Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Center)
      node_root.Image_Icon.Slot:SetVerticalAlignment(EVerticalAlignment.VAlign_Center)
    end
  end)
end
function Common_Items_UIBP:CORChildUIRefreshImage(sChildName, tChildCfg, bIsShow, sNodeName, sIconPath)
  self:UIOperation(function()
    if bIsShow then
      tChildCfg = tChildCfg or CommonItem_ChildCfg[sChildName]
      if not tChildCfg then
        return
      end
      local cObj_tempUI = self:_CreateCommonItemChildUI(sChildName, tChildCfg)
      if not cObj_tempUI then
        return
      end
      cObj_tempUI:UIOperation(function(cObj_ui)
        local node_childRoot = cObj_ui.UIRoot
        if not node_childRoot[sNodeName] then
          return
        end
        local params = {sync = false, bMatchSize = true}
        self:SetTexture(node_childRoot[sNodeName], sIconPath, params)
        if tChildCfg.tOffsetPos then
          node_childRoot[sNodeName].Slot:SetPosition(FVector2D(tChildCfg.tOffsetPos.X, tChildCfg.tOffsetPos.Y))
        end
      end)
    else
      self:_RemoveCommonItemChildUI(sChildName)
    end
  end)
end
function Common_Items_UIBP:InitChildShowByChildCfg(sChildName, tChildCfg, bIsShow, fShowedCallback)
  self:UIOperation(function()
    if not (sChildName and tChildCfg and tChildCfg.sParentName) or not tChildCfg.sBpPath then
      return nil
    end
    if bIsShow then
      local cObj_ui = self:_CreateCommonItemChildUI(sChildName, tChildCfg)
      if fShowedCallback and type(fShowedCallback) == "function" then
        fShowedCallback(cObj_ui)
      end
    else
      self:_RemoveCommonItemChildUI(sChildName)
    end
  end)
end
function Common_Items_UIBP:InitChildShowByUIConfig(sChildName, tUIConfig, bIsShow, fShowedCallback, nZOrder, ...)
  local tUIAllParams = {
    ...
  }
  self:UIOperation(function()
    if not sChildName or not tUIConfig then
      return nil
    end
    local cObj_ui = self[sChildName]
    if bIsShow then
      if not cObj_ui then
        cObj_ui = self:CreateChildWindow("CanvasPanel_ItemShow", tUIConfig, table.unpack(tUIAllParams))
        if not cObj_ui then
          return
        end
        cObj_ui:SetZOrder(nZOrder or 0)
        self[sChildName] = cObj_ui
      end
      if fShowedCallback and type(fShowedCallback) == "function" then
        fShowedCallback(cObj_ui)
      end
    else
      self:_RemoveCommonItemChildUI(sChildName)
    end
  end)
end
function Common_Items_UIBP:OnPakDownloadFinish(_, _, eventData)
  if self._tExtraData and self._tExtraData.fIconDownloadCallback then
    self._tExtraData.fIconDownloadCallback(eventData)
  end
end
local class = require("class")
local ui_base = require("client.slua.component.item.ItemChildren.CommonItem_UIBase")
local CCommon_Items_UIBP = class(ui_base, nil, Common_Items_UIBP)
return CCommon_Items_UIBP