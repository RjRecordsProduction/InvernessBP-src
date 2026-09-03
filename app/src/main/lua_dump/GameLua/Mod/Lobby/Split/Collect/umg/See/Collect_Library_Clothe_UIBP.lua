local Collect_Library_Clothe_UIBP = {}
local local ClotheBannerPath = "/Game/Mod/Lobby/Split/Collect/Texture/Library/Collect_Library_GuestState_Icon02.Collect_Library_GuestState_Icon02"
local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
function Collect_Library_Clothe_UIBP:ctor(_, personalizeExtraData)
  local tabIndex, PopupData
  local personalizeExtraData = personalizeExtraData or {}
  if personalizeExtraData.subData and personalizeExtraData.subData.ctorData then
    tabIndex, PopupData = table.unpack(personalizeExtraData.subData.ctorData)
  end
  self.SelectTabIndex = tabIndex
  self.  if personalizeExtraData.extraTab then
    self.SelectSubTabId = tonumber(personalizeExtraData.extraTab)
  end
end
function Collect_Library_Clothe_UIBP:OnInitialize()
  self.SeriesTabScroll = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_0, "GameLua.Mod.Lobby.Split.Collect.umg.See.Item.Collect_Library_Clothe_Tab_Item_UIBP")
  self.SeriesItemScroll = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Item, "GameLua.Mod.Lobby.Split.Collect.umg.See.Item.Collect_Library_Clothe_Item_UIBP")
  self.SeriesAwardScroll = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Award, "GameLua.Mod.Lobby.Split.Collect.umg.See.Item.Collect_Library_Clothe_Award_Item_UIBP")
end
function Collect_Library_Clothe_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_All, self.OnClickedAllClothe, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Get, self.OnClickedGet, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Collection, self.OnClickedCollection, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GetAll, self.OnClickButton_GetAll, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DETAIL_DATA, self.RefreshDynamicContext, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_BATCH_TAKE_AWARD_RESP, self.OnBatchTakeAwardRes, self)
end
function Collect_Library_Clothe_UIBP:OnPostInitialize()
  self:RefreshStaticContext()
  self:ReqData()
  self:RefreshWithAward()
end
function Collect_Library_Clothe_UIBP:GetDataForJumpBack()
  return {
    ctorData = {
      self.SeriesTabScroll and self.SeriesTabScroll:GetSelectIndex() or 1,
      {
        bOpen = self:IsCollectionPopupOpen(),
        UserOffset = self:GetCollectionPopupScrollOffset()
      }
    }
  }
end
function Collect_Library_Clothe_UIBP:OnClose()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  reddot_node_collect_manager:ClearCacheRemoveRedDot()
end
function Collect_Library_Clothe_UIBP:OnClickedAllClothe()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  UIManager.ShowUI(UIManager.UI_Config.Collect_Library_DetailsGoods_UIBP, {
    nShowUId = RoleInfoSystem.GetCurShowUserId()
  })
end
function Collect_Library_Clothe_UIBP:OnClickedGet()
  self:PlayAudio(sound_config.click_v1)
  local seriesData = self.SeriesTabScroll:GetItemData(self.SeriesTabScroll:GetSelectIndex())
  if not seriesData then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local urlMap = {}
  local orderList = {}
  for _, itemData in pairs(seriesData.ItemList) do
    local subThemeId = itemData.SubThemeID
    if subThemeId and not urlMap[subThemeId] then
      local cfg = collect_module:GetSplitTableData("CollectClotheSubTheme", collect_module.E_ColCfgMode.DifJK, subThemeId)
      if cfg and cfg.JumpUrl and cfg.Time and cfg.Version and not collect_encryption_module:IsEncryptionSeries(cfg.Version, cfg.Time) then
        urlMap[subThemeId] = cfg.JumpUrl
        table.insert(orderList, {
          Time = cfg.Time,
          JumpUrl = cfg.JumpUrl
        })
      end
    end
  end
  table.sort(orderList, function(a, b)
    local aTime = TimeUtil.TimeStringToUnixstamp(a.Time)
    local bTime = TimeUtil.TimeStringToUnixstamp(b.Time)
    return aTime > bTime
  end)
  local JumpUtil = require("client.logic.store.jump_utils")
  log_tree("Collect_Library_Clothe_UIBP:OnClickedGet orderList = ", orderList)
  for _, data in pairs(orderList) do
    local url = data.JumpUrl
    if url and url ~= "" and JumpUtil.CheckUrlCanJump(url) then
      GlobalData.JumpUrl(url)
      return
    end
  end
  ShowNotice(6430)
end
function Collect_Library_Clothe_UIBP:OnClickedCollection()
  log(bWriteLog and "Collect_Library_Clothe_UIBP:OnClickedCollection.")
  local seriesData = self.SeriesTabScroll:GetItemData(self.SeriesTabScroll:GetSelectIndex())
  if not seriesData then
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  local subThemeData = collect_library_module:GeneratePopupData(seriesData.ItemList or {}, "CollectClotheSubTheme", collect_module.E_ColCfgMode.DifJK)
  if next(subThemeData) then
    self:PlayAudio(sound_config.click_v1)
    local seriesScoreText = ""
    local seriesId = seriesData.SeriesID
    local seriesDiffScore = collect_clothe_module:GetClotheSeriesScoreNextDiff(seriesId)
    local curAwardLevel = collect_clothe_module:GetClotheSeriesMaxTakeAwardLevel(seriesId)
    local maxAwardLevel = collect_clothe_module:GetClotheSeriesMaxAwardLevel(seriesId)
    if curAwardLevel < maxAwardLevel then
      seriesScoreText = LocUtil.LocalizeResFormat(77567, seriesDiffScore)
    else
      local score = collect_clothe_module:GetClotheSeriesScore(seriesId)
      seriesScoreText = LocUtil.LocalizeResFormat(77497, score)
    end
    UIManager.ShowUI(UIManager.UI_Config.Collect_Library_Clothe_Popup_Collection_UIBP, subThemeData, seriesData.SeriesName, seriesScoreText)
  end
end
function Collect_Library_Clothe_UIBP:OnClickTab(tabIndex, bIgnoreRedDot)
  local seriesData = self.SeriesTabScroll:GetItemData(tabIndex)
  if not seriesData or not seriesData.SeriesID then
    return
  end
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  if not bIgnoreRedDot then
    reddot_node_collect_manager:ClearCacheRemoveRedDot()
    reddot_node_collect_manager:RemoveReddot(seriesData.SeriesID)
  else
    reddot_node_collect_manager:CacheRemoveRedDot(seriesData.SeriesID)
  end
  self.SeriesTabScroll:Select(tabIndex)
  self.UIRoot.TextBlock_SeriesName:SetText(seriesData.SeriesName)
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  local seriesDiffScore = collect_clothe_module:GetClotheSeriesScoreNextDiff(seriesData.SeriesID)
  local curAwardLevel = collect_clothe_module:GetClotheSeriesMaxTakeAwardLevel(seriesData.SeriesID)
  local maxAwardLevel = collect_clothe_module:GetClotheSeriesMaxAwardLevel(seriesData.SeriesID)
  if curAwardLevel < maxAwardLevel then
    self.UIRoot.RTextBlock_NextScore:SetText(LocUtil.LocalizeResFormat(77567, seriesDiffScore))
  else
    local score = collect_clothe_module:GetClotheSeriesScore(seriesData.SeriesID)
    self.UIRoot.RTextBlock_NextScore:SetText(LocUtil.LocalizeResFormat(79718, score))
  end
  local itemList = {}
  local collect_introduction_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_introduction_module)
  local _, __, itemInfo = collect_introduction_module:GetOwnedScoreAndTotalScore(seriesData.ItemList, true)
  for _, data in pairs(seriesData.ItemList) do
    if itemInfo[data.ItemID] then
      table.insert(itemList, data)
    end
  end
  self.SeriesItemScroll:SetData(itemList)
  local awardList = seriesData.AwardList
  self.SeriesAwardScroll:SetData(awardList)
  self:CanAutoScrollToCollectible(awardList, seriesData.SeriesID)
end
function Collect_Library_Clothe_UIBP:CanAutoScrollToCollectible(awardList, seriesID)
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  for level, v in ipairs(awardList) do
    for subIndex = 1, 2 do
      local status = collect_clothe_module:GetClotheSeriesAwardStatus(seriesID, level, subIndex)
      if v["Drop" .. subIndex] ~= 0 and status == ActivityProgressStatus.Done then
        self.SeriesAwardScroll:ScrollToCenter(level - 1)
        return
      end
    end
  end
end
function Collect_Library_Clothe_UIBP:OnClickedAward(seriesID, awardIndex, subIndex, status, itemId, num, time)
  log(bWriteLog and string.format("Collect_Library_Clothe_UIBP:OnClickedAward seriesID=%s, awardIndex=%s, subIndex=%s, status=%s, itemId=%s, num=%s, time=%s", tostring(seriesID), tostring(awardIndex), tostring(subIndex), tostring(status), tostring(itemId), tostring(num), tostring(time)))
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  if status == ActivityProgressStatus.Done then
    local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
    ModCollectHandler.send_take_collect_level_award_req(3, awardIndex, subIndex, seriesID):Then(function(_, _, res_list)
      log_warning(bWriteLog and "Collect_Library_Clothe_UIBP:OnClickedAward res_list: " .. tostring(res_list))
      collect_library_module:UpdateSeriesAwardStatus(seriesID, awardIndex, subIndex, 3)
      self:OnGetDrop(itemId, num, time, awardIndex, subIndex)
      local _ = self.UIRoot and self.SeriesAwardScroll:RefreshItem(awardIndex)
      local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
      collect_reddot_module:RefreshLibrarySubTabRed(collect_cfg.Sys2Index.Clothes)
      self.SeriesTabScroll:RefreshItem(self.SeriesTabScroll:GetSelectIndex())
    end)
  else
    local seriesData = self.SeriesTabScroll:GetItemData(self.SeriesTabScroll:GetSelectIndex())
    local maxTakeAwardLevel = collect_clothe_module:GetClotheSeriesMaxTakeAwardLevel(seriesData.SeriesID)
    local progress = collect_clothe_module:GetClotheSeriesProgress(seriesData.SeriesID, maxTakeAwardLevel)
    local data = {
      index = awardIndex,
      subIndex = subIndex,
      list = seriesData.AwardList,
      level = maxTakeAwardLevel,
      progress = progress,
      sysId = 3
    }
    UIManager.ShowUI(UIManager.UI_Config.Collect_Award_Preview_UIBP, data)
  end
end
function Collect_Library_Clothe_UIBP:OnClickButton_GetAll()
  self:PlayAudio(sound_config.click_v1)
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_batch_take_all_sub_page_level_award_req(collect_cfg.Sys2Index.Clothes)
end
function Collect_Library_Clothe_UIBP:RefreshStaticContext()
  self:SetTexture(self.UIRoot.Image_Banner, ClotheBannerPath)
  self:PlayUserWidgetAnimation(self.UIRoot.FadeIn, 0, 1, 0, 1)
  self.UIRoot.TextBlock_ClotheScore:SetText(LocUtil.GetLocalizeResStr(77529))
  self.UIRoot.TextBlock_Num:SetText(LocUtil.GetLocalizeResStr(77495))
  self.UIRoot.TextBlock_All:SetText(LocUtil.GetLocalizeResStr(77524))
  self.UIRoot.TextBlock_GoDraw:SetText(LocUtil.GetLocalizeResStr(48324))
  self.UIRoot.TextBlock_GetAll:SetText(LocUtil.GetLocalizeResStr(77468))
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(77468))
  local path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg01.Collect_Bg01"
  self:SetTexture(self.UIRoot.Image_Bg, path)
end
function Collect_Library_Clothe_UIBP:GetSelectTabIndex(seriesData)
  if self.SelectSubTabId then
    local targetId = self.SelectSubTabId
    self.SelectSubTabId = nil
    for i, data in ipairs(seriesData) do
      if data.SeriesID == targetId then
        return i
      end
    end
  end
  if self.SelectTabIndex then
    local index = self.SelectTabIndex
    self.SelectTabIndex = nil
    return index or 1
  end
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  for i, data in ipairs(seriesData) do
    if collect_clothe_module:IsRedOneClothe(data) then
      log(bWriteLog and string.format("Collect_Library_Clothe_UIBP:GetSelectTabIndex: select red dot tab SeriesID %s", data.SeriesID))
      return i
    end
  end
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  for i, data in ipairs(seriesData) do
    if reddot_node_collect_manager:CheckShowNewReddot(data.SeriesID) then
      log(bWriteLog and string.format("Collect_Library_Clothe_UIBP:GetSelectTabIndex: select new tab SeriesID %s", data.SeriesID))
      return i
    end
  end
  return 1
end
function Collect_Library_Clothe_UIBP:RefreshDynamicContext(_, _, data, other_uid)
  local selfUid = DataMgr.roleData.uid
  if tostring(selfUid) ~= tostring(other_uid) then
    log(bWriteLog and string.format("Collect_Library_Clothe_UIBP:RefreshDynamicContext uid mismatch, selfUid=%s other_uid=%s", tostring(selfUid), tostring(other_uid)))
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  local clothTotalScore = collect_clothe_module:GetClotheSeriesTotalScore()
  self.UIRoot.Text_Score:SetText(clothTotalScore)
  local clotheCount = collect_theme_module:GetClotheTotalCount()
  self.UIRoot.TextBlock_Amount:SetText(clotheCount)
  local seriesData = collect_clothe_module:GetAllClotheSeriesData()
  self.SeriesTabScroll:SetData(seriesData)
  local nSelectTab = self:GetSelectTabIndex(seriesData)
  if 1 < nSelectTab then
    self.SeriesTabScroll:ScrollToItem(nSelectTab)
  end
  self:OnClickTab(nSelectTab, true)
  if self.PopupData and self.PopupData.bOpen then
    local selectSeriesData = self.SeriesTabScroll:GetItemData(self.SeriesTabScroll:GetSelectIndex())
    local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
    local subThemeData = collect_library_module:GeneratePopupData(selectSeriesData.ItemList or {}, "CollectClotheSubTheme", collect_module.E_ColCfgMode.DifJK)
    if next(subThemeData) then
      local seriesScoreText = ""
      local seriesId = selectSeriesData.SeriesID
      local seriesDiffScore = collect_clothe_module:GetClotheSeriesScoreNextDiff(seriesId)
      local curAwardLevel = collect_clothe_module:GetClotheSeriesMaxTakeAwardLevel(seriesId)
      local maxAwardLevel = collect_clothe_module:GetClotheSeriesMaxAwardLevel(seriesId)
      if curAwardLevel < maxAwardLevel then
        seriesScoreText = LocUtil.LocalizeResFormat(77567, seriesDiffScore)
      else
        local score = collect_clothe_module:GetClotheSeriesScore(seriesId)
        seriesScoreText = LocUtil.LocalizeResFormat(77497, score)
      end
      UIManager.ShowUI(UIManager.UI_Config.Collect_Library_Clothe_Popup_Collection_UIBP, subThemeData, selectSeriesData.SeriesName, seriesScoreText, self.PopupData.UserOffset)
    end
  end
end
function Collect_Library_Clothe_UIBP:RefreshWithAward()
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  local hasAward = collect_clothe_module:HasRed()
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(hasAward and 1 or 0)
  self:SetTexture(self.UIRoot.Image_10, collect_cfg.E_AwardGet_Type[hasAward])
end
function Collect_Library_Clothe_UIBP:RefreshWithAwardAndItem()
  self.SeriesTabScroll:RefreshAllItems()
  self.SeriesAwardScroll:RefreshAllItems()
end
function Collect_Library_Clothe_UIBP:ReqData()
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  local uid = tonumber(DataMgr.roleData.uid)
  CollectHandler.send_get_collect_detail_req(uid, 1)
end
function Collect_Library_Clothe_UIBP:OnGetDrop(itemId, num, time, index, subIndex)
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnGetItem. itemId: " .. tostring(itemId))
  local itemList = {
    {
      res_id = itemId,
      count = num,
      valid_hours = time
    }
  }
  local collect_award_module = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.collect_award_module)
  collect_award_module:ShowGet(itemList)
  self:RefreshWithAward()
end
function Collect_Library_Clothe_UIBP:OnBatchTakeAwardRes(_, _, sys_id, award_list, award_status)
  self:RefreshWithAward()
  self:RefreshWithAwardAndItem()
end
function Collect_Library_Clothe_UIBP:IsCollectionPopupOpen()
  return UIManager.IsUIShow(UIManager.UI_Config.Collect_Library_Clothe_Popup_Collection_UIBP)
end
function Collect_Library_Clothe_UIBP:GetCollectionPopupScrollOffset()
  local ui = UIManager.GetUI(UIManager.UI_Config.Collect_Library_Clothe_Popup_Collection_UIBP)
  return ui and ui:GetUserScrollOffset() or 0
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCollect_Library_Clothe_UIBP = class(ui_base, nil, Collect_Library_Clothe_UIBP)
return CCollect_Library_Clothe_UIBP