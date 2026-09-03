local Lobby_RoleInfo_CustomInformation_Popup_UIBP = {}
local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:ctor()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnInitialize()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnInitialize")
  self.Common_Tab_Vertical_LevelOne_Text_UIBP = self:InitVerticalTextTab(self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP, true, true)
  self.LoopScrollGrid_Four = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Four, "client.slua.umg.PersonSpace.Popup.Item.Common_InformationCustom_Item")
  self.LoopScrollGrid_Two = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Two, "client.slua.umg.PersonSpace.Popup.Item.Common_InformationCustom_Item")
  self.LoopScrollGrid_One = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_One, "client.slua.umg.PersonSpace.Popup.Item.Common_InformationCustom_Item")
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.typeList = {}
  self.typeList[1] = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.LobbyChat_InformationCustomButton_UIBP, self.UIRoot.LobbyChat_InformationCustomButton_UIBP)
  self.typeList[2] = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.LobbyChat_InformationCustomButton_UIBP, self.UIRoot.LobbyChat_InformationCustomButton_UIBP_105)
  self.typeList[3] = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.LobbyChat_InformationCustomButton_UIBP, self.UIRoot.LobbyChat_InformationCustomButton_UIBP_209)
  self.LobbyChat_InformationCustomProfile_UIBP = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.LobbyChat_InformationCustomProfile_UIBP, self.UIRoot.LobbyChat_InformationCustomProfile_UIBP)
  self.UIRoot.UTRichTextBlock_Title:SetText(LocUtil.GetLocalizeResStr(87358))
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(87357))
  self._cpData = nil
  self.onKeyCount = 0
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:RegistEvents()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:RegistEvents")
  self:AddOnClickedEventByControl(self.UIRoot.Common_Popup_Large_UIBP.close, self.OnClickClose, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Confirm, self.OnClickButton_Confirm, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Cancel, self.OnClickButton_Cancel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Delete, self.OnClickButton_Delete, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_2, self.OnClickOneKeyCreate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, self.OnItemSelect, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_LEFT_ITEM_DRAG, self.OnLeftItemDrag, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP, self.ResetAllEquip, self)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnPostInitialize()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnPostInitialize")
  local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
  local originData = custom_presentation_util.GetDataByUID(DataMgr.roleData.uid)
  local TableUtil = require("common.table_util")
  local copyCPData = TableUtil.CopyTable(originData)
  self._cpData = custom_presentation_util.CheckCPDataIsValid(DataMgr.roleData.uid, copyCPData, true)
  self.Common_Popup_Large_UIBP = self:InitCommonPopup(self.UIRoot.Common_Popup_Large_UIBP)
  self:SetWidgetVisible(self.UIRoot.Lobby_RoleInfo_CustomPresentation_Item_UIBP, true)
  local extraData = {
    helpInfo = {
      titleText = LocUtil.GetLocalizeResStr(6067),
      contentText = LocUtil.GetLocalizeResStr(656037)
    }
  }
  self.Common_Popup_Large_UIBP:SetData(self, LocUtil.GetLocalizeResStr(87356), extraData)
  self.UIRoot.TextBlock_Cancel:SetText(LocUtil.GetLocalizeResStr(110035))
  self.UIRoot.TextBlock_Confirm:SetText(LocUtil.GetLocalizeResStr(110036))
  self.Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabClickedCallback(self.OnVerticalIconTabClickedCallback, self)
  self.Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabSelectedCallback(self.OnVerticalIconTabSelectedCallback, self)
  local tab_data = custom_presentation_util.GetShowTabData()
  self._tabList = {}
  for k, v in pairs(tab_data) do
    self._tabList[k] = {
      configData = v,
      cpData = self._cpData,
      bMatchSize = true,
      isLarge = self._selectLargeSlot,
      isEndIndex = k == #tab_data,
      text = LocUtil.GetLocalizeResStr(v.Name)
    }
  end
  self.Common_Tab_Vertical_LevelOne_Text_UIBP:SetTabs(self._tabList, 1)
  self:InitTopTab()
  self:SetSelectIndex(1)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Delete, false, true)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnShow()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnShow")
  if self.LobbyChat_InformationCustomProfile_UIBP then
    self.LobbyChat_InformationCustomProfile_UIBP:OnShow()
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClose()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClose")
  if self.LobbyChat_InformationCustomProfile_UIBP then
    self.LobbyChat_InformationCustomProfile_UIBP:OnClose()
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Large()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Large")
  self:PlayAudio(sound_config.click_v1)
  self._selectLargeSlot = true
  self:UpdatePresentationSelected()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Small()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Small")
  self:PlayAudio(sound_config.click_v1)
  self._selectLargeSlot = false
  self:UpdatePresentationSelected()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Cancel()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Cancel")
  self:PlayAudio(sound_config.click_v1)
  self:CloseSelf()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickClose()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickClose")
  self:PlayAudio(sound_config.click_v1)
  self:CloseSelf()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Confirm()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Confirm")
  self:PlayAudio(sound_config.click_v1)
  local allData, isChange = self.LobbyChat_InformationCustomProfile_UIBP:GetAllItemData()
  if not isChange then
    self:CloseSelf()
    return
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_set_custom_presentation_req(allData)
  self:CloseSelf()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:SetSelectIndex(index)
  local scrollbox = self:GetScrollBox()
  local allCnt = scrollbox:GetItemCount()
  for i = 1, allCnt do
    local widget = scrollbox:GetIndexOfWidget(index)
    if widget then
      widget:SetSelected(index == i)
    end
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:ResetAllEquip()
  local allItemData = self.LobbyChat_InformationCustomProfile_UIBP:GetAllSpawnItem()
  local scrollbox = self:GetScrollBox()
  if not scrollbox then
    return
  end
  local allCnt = scrollbox:GetItemCount()
  local newAllData = {}
  for i = 1, allCnt do
    local widgetData = scrollbox:GetItemData(i)
    if widgetData then
      widgetData.hadEquip = 0
      for k, v in pairs(allItemData) do
        if widgetData.moduleData and v.moduleData.mId == widgetData.moduleData.mId and v.mmId == widgetData.mmId then
          widgetData.hadEquip = 1
        end
      end
      if widgetData.moduleData then
        table.insert(newAllData, widgetData)
      end
    end
  end
  for i = 1, #newAllData do
    for j = i + 1, #newAllData do
      if newAllData[i].hadEquip < newAllData[j].hadEquip then
        newAllData[i], newAllData[j] = newAllData[j], newAllData[i]
      end
    end
  end
  scrollbox:RefreshAllItems(newAllData)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:GetScrollBox()
  if self.topSelectIndex == 1 then
    return self.LoopScrollGrid_Four
  elseif self.topSelectIndex == 2 then
    return self.LoopScrollGrid_Two
  elseif self.topSelectIndex == 3 then
    return self.LoopScrollGrid_One
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:IsTopTabCanSelect(index)
  if self._selectedTab == 1 then
    return true
  end
  local moduleConfigList = CDataTable.GetTable("CustomPresentationModule")
  for _, moduleCfg in ipairs(moduleConfigList) do
    if self._selectedTab == moduleCfg.TabID then
      local includeSize = moduleCfg.IncludeSize
      if includeSize then
        local StringUtil = require("common.string_util")
        local sizeList = StringUtil.Split(includeSize, ";")
        for _, size in ipairs(sizeList) do
          if tonumber(size) == index then
            return true
          end
        end
      end
    end
  end
  return false
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnVerticalIconTabClickedCallback(widget, index)
  local data = self.Common_Tab_Vertical_LevelOne_Text_UIBP:GetTabData(index)
  if data then
    self._selectedTab = data.configData.ID
    local moduleConfigList = CDataTable.GetTable("CustomPresentationModule")
    for i, moduleCfg in ipairs(moduleConfigList) do
      log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP index -----:" .. i)
      if self._selectedTab == moduleCfg.TabID then
        local includeSize = moduleCfg.IncludeSize
        if includeSize then
          local StringUtil = require("common.string_util")
          local sizeList = StringUtil.Split(includeSize, ";")
          for _, size in ipairs(sizeList) do
            self.typeList[tonumber(size)]:SetSwitchIndex(0)
            self:OnSelectCallBack(tonumber(size))
            return
          end
        end
      end
    end
    self:OnSelectCallBack(1)
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnVerticalIconTabSelectedCallback(lastIndex, index, bFromClick)
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnVerticalIconTabSelectedCallback")
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, nil, nil, true)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnItemSelect(_, _, selectData, index, isSelectCancel)
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnItemSelect")
  if isSelectCancel then
    self.UIRoot.UTRichTextBlock_Title:SetText(LocUtil.GetLocalizeResStr(87358))
  else
    local cfg = CDataTable.GetTableData("CustomPresentationModule", selectData.moduleData.mId)
    if cfg then
      self.UIRoot.UTRichTextBlock_Title:SetText(LocUtil.GetLocalizeResStr(cfg.TextID))
    end
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnLeftItemDrag(_, _, isDrag)
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnItemSelect")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Delete, isDrag, true)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:UpdateUI")
  self:UpdateShowItem()
  self:CreateTab()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnDefaultPresentationSelect()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnDefaultPresentationSelect")
  self._selectLargeSlot = true
  self:UpdatePresentationSelected()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:UpdatePresentationSelected()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:UpdatePresentationSelected")
  self:SetWidgetVisible(self.UIRoot.Common_selected_UIBP_Large, self._selectLargeSlot)
  self:SetWidgetVisible(self.UIRoot.Common_selected_UIBP_Small, not self._selectLargeSlot)
  self:CreateTab()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:CreateTab()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:CreateTab")
  local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
  local tab_data = custom_presentation_util.GetShowTabData()
  self._tabList = {}
  for k, v in pairs(tab_data) do
    self._tabList[k] = {
      configData = v,
      cpData = self._cpData,
      isLarge = self._selectLargeSlot,
      isEndIndex = k == #tab_data
    }
  end
  self.LoopScrollBox_Tab:SetData(self._tabList)
  self:OnDefaultTabSelect()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:InitTopTab(selectIdx)
  local selectIndex = selectIdx or 1
  for i, widget in ipairs(self.typeList) do
    widget:SetSelectCallBack(i, function()
      self:OnSelectCallBack(i)
    end)
    widget:SetSelected(selectIndex == i)
  end
  self.topSelectIndex = selectIndex
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  logic_custom_presentation:SetInformationType(self.topSelectIndex)
  self:OnVerticalIconTabClickedCallback(_, selectIndex)
  self:CreateModule()
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnDefaultTabSelect()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnDefaultTabSelect")
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local selectedTab = self._selectedTab or custom_presentation_config.TabID.All
  for i = 1, #self._tabList do
    local itemData = self.LoopScrollBox_Tab:GetItemData(i)
    if itemData.configData.ID == selectedTab then
      self:OnClickTab(i)
      break
    end
  end
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:CreateModule(selectTab)
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:CreateModule")
  local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
  local module_config_data = custom_presentation_util.GetShowModuleByTabID(selectTab or self._selectedTab, true)
  local moduleList = custom_presentation_util.GetShowModuleListByUIDNew(DataMgr.roleData.uid, module_config_data)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local TableUtil = require("common.table_util")
  local moduleConfigList = CDataTable.GetTable("CustomPresentationModule")
  local tmpModuleList = {}
  for _, module in pairs(moduleList) do
    for _, moduleCfg in ipairs(moduleConfigList) do
      if module.moduleData.mId == moduleCfg.ID then
        if not selectTab then
          local includeSize = moduleCfg.IncludeSize
          if includeSize then
            local StringUtil = require("common.string_util")
            local sizeList = StringUtil.Split(includeSize, ";")
            for _, size in ipairs(sizeList) do
              if tonumber(size) == self.topSelectIndex then
                module.hadEquip = 0
                module.mmId = module.moduleData.mId
                table.insert(tmpModuleList, module)
                break
              end
            end
          end
        else
          module.mmId = module.moduleData.mId
          table.insert(tmpModuleList, module)
        end
      end
    end
  end
  moduleList = tmpModuleList
  for _, v in pairs(moduleList) do
    for _, cpData in ipairs(self._cpData) do
      if cpData.mId == v.ID then
        v.        break
      end
    end
    v.uid = DataMgr.roleData.uid
    v.showType = self.topSelectIndex
    v.isEdit = true
  end
  local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  local aliasListData = logic_roleinfo_title.GetAliasListData()
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local RemoveType = function(moduleType)
    local data
    for i, v in pairs(moduleList) do
      if v.moduleData.mId == moduleType then
        data = v
        table.remove(moduleList, i)
        break
      end
    end
    return data
  end
  if aliasListData then
    local data = RemoveType(custom_presentation_config.NewModuleID.Title)
    if data then
      for key, value in pairs(aliasListData) do
        if value.state ~= 0 then
          local newTb = TableUtil.CopyTable(data)
          newTb.alias_id = key
          newTb.alias_title = value.title
          newTb.mmId = newTb.alias_id
          table.insert(moduleList, newTb)
        end
      end
    end
  end
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local Summary = AchieveHandler.GetSummaryInfoByUid(tonumber(DataMgr.roleData.uid))
  if Summary then
    local data = RemoveType(custom_presentation_config.NewModuleID.Achievement)
    if data then
      for _, value in pairs(Summary.show) do
        if 0 < value then
          local newTb = TableUtil.CopyTable(data)
          newTb.summary_id = value
          newTb.mmId = newTb.summary_id
          table.insert(moduleList, newTb)
        end
      end
    end
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  local HonerDataList = ace_util.GetHonerImprintData(DataMgr.roleData.uid)
  local HonerData = {}
  for cfgId, v in pairs(HonerDataList) do
    if 0 < v.count then
      HonerData[cfgId] = v
    end
  end
  if HonerData then
    local data = RemoveType(custom_presentation_config.NewModuleID.KingMark)
    if data then
      for cfgId, v in pairs(HonerData) do
        if 0 < v.advance_num then
          local newTb = TableUtil.CopyTable(data)
          newTb.honer_id = cfgId
          newTb.advance_num = v.advance_num
          newTb.honer_count = v.count
          newTb.mmId = newTb.honer_id
          table.insert(moduleList, newTb)
        end
      end
    end
  end
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  local showList = ace_util.GetPeakGameShowListData(profile.peakgame_all_season_segment_info)
  if showList and 0 < #showList then
    local data = RemoveType(custom_presentation_config.NewModuleID.KingMarkMax)
    if data then
      for _, value in pairs(showList) do
        if 0 < value.count then
          local newTb = TableUtil.CopyTable(data)
          newTb.peakAce_id = value.id
          newTb.peakAce_count = value.count
          newTb.mmId = newTb.peakAce_id
          table.insert(moduleList, newTb)
        end
      end
    end
  end
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  local MaxScore = logic_card_collection_season:GetCardScroreByUid(DataMgr.roleData.uid)
  if MaxScore then
    for i, v in pairs(moduleList) do
      if v.moduleData.mId == custom_presentation_config.NewModuleID.CardCollect then
        v.card_score = MaxScore
        break
      end
    end
  end
  for _, v in pairs(moduleList) do
    if v.moduleData.mId == custom_presentation_config.NewModuleID.Common_RankIntegralLevel then
      local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
      local rankShowType = RoleInfoMainSystem.GetRankShowType()
      local _, segment = RoleInfoMainSystem.GetMaxSegmentInfo(rankShowType)
      v.rank_segment_id = segment
      v.mmId = segment
      break
    end
  end
  local pround_info = DataMgr.roleData.pround_info
  if pround_info then
    for _, v in pairs(moduleList) do
      if v.moduleData.mId == custom_presentation_config.NewModuleID.Honor then
        v.pround_level = pround_info.level
        break
      end
    end
  end
  local data = RoleInfoPopularitySystem.PopularitySimpleCache[tostring(DataMgr.roleData.uid)]
  if data then
    for _, v in pairs(moduleList) do
      if v.moduleData.mId == custom_presentation_config.NewModuleID.Popularity then
        v.popularity = data.total_devote
        break
      end
    end
  end
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  local segmentID = logic_leisure_season:GetLeisureSegmentIDByUID(DataMgr.roleData.uid)
  if segmentID and 0 < segmentID then
    for _, v in pairs(moduleList) do
      if v.moduleData.mId == custom_presentation_config.NewModuleID.Relax_RankIntegralLevel then
        v.relex_rankId = segmentID
        break
      end
    end
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  for _, value in pairs(moduleList) do
    if value.moduleData.mId == custom_presentation_config.NewModuleID.Relation then
      value.relation_uid = value.moduleData.mData.uid
      local intimacyInfo = logic_friend_intimacy:GetIntimacyInfo(DataMgr.roleData.uid, value.relation_uid)
      value.relation_type = intimacyInfo.param or intimacyInfo.relation
      value.relation_intimacy = intimacyInfo.intimacy
      value.mmId = value.moduleData.mData.uid
    end
  end
  local pkgMaxData = RemoveType(custom_presentation_config.NewModuleID.PeakGame_RankIntegralLevelMax)
  if pkgMaxData then
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local peakSegment = LogicPeakGameSegmentUtil.GetProfileHistoryMaxSegmentId(profile)
    if peakSegment then
      local newTb = TableUtil.CopyTable(pkgMaxData)
      table.insert(moduleList, newTb)
    end
  end
  for i, value in pairs(moduleList) do
    if value.moduleData.mId == custom_presentation_config.NewModuleID.RP_Level then
      value.mmId = custom_presentation_config.NewModuleID.RP_Level
      value.bp_season = UnknowPassSystem.Season
      value.bp_isBuyElite = UnknowPassSystem.IsBuyElite
      value.bp_level = UnknowPassSystem.Level
      break
    end
  end
  for i, value in pairs(moduleList) do
    if value.moduleData.mId == custom_presentation_config.NewModuleID.WOW_Author then
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      local AuthorInfo = LogicUGCAuthor:GetAuthorInfo(DataMgr.roleData.uid)
      if AuthorInfo then
        value.author_level = AuthorInfo.new_level or AuthorInfo.level or 0
      end
      break
    end
  end
  if not selectTab then
    self._    local list = self._moduleList
    if self.topSelectIndex == 1 then
      self.LoopScrollGrid_Four:SetData(list)
    elseif self.topSelectIndex == 2 then
      self.LoopScrollGrid_Two:SetData(list)
    elseif self.topSelectIndex == 3 then
      self.LoopScrollGrid_One:SetData(list)
    end
    self.UIRoot.WidgetSwitcher_Page:SetActiveWidgetIndex(0)
    self:ResetAllEquip()
  end
  return moduleList
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnSelectCallBack(index)
  if not self:IsTopTabCanSelect(index) then
    return
  end
  for i, widget in ipairs(self.typeList) do
    if index == i then
      widget:SetSelected(true)
    elseif self:IsTopTabCanSelect(i) then
      widget:SetSelected(false)
    else
      widget:SetSwitchIndex(2)
    end
  end
  self.topSelectIndex = index
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  logic_custom_presentation:SetInformationType(self.topSelectIndex)
  self:CreateModule()
  self.UIRoot.WidgetSwitcher_Page:SetActiveWidgetIndex(index - 1)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_TYPE_CHANGE)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:UpdateShowItem()
  log(bWriteLog and "Lobby_RoleInfo_CustomInformation_Popup_UIBP:UpdateShowItem")
  self.ShowItem:UpdateUI(DataMgr.roleData.uid, self._cpData, true)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickButton_Delete()
  self:PlayAudio(sound_config.click_v1)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_DELETE, true)
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:IndexToRowCol(Index)
  local row = math.ceil(Index / 4)
  local col = Index % 4
  if col == 0 then
    col = 4
  end
  return row, col
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:CreateOne(result, weightMap, mIdModuleList)
  local maxWeight = 0
  for weight, _ in pairs(weightMap) do
    if weight > maxWeight then
      maxWeight = weight
    end
  end
  if 0 < maxWeight then
    local weightCfgList = weightMap[maxWeight]
    if weightCfgList then
      local count = 0
      for _, cfg in pairs(weightCfgList) do
        if cfg then
          count = count + 1
        end
      end
      if 0 < count then
        local index = math.random(1, count)
        local cfg = weightCfgList[index]
        if cfg then
          local includeSize = cfg.IncludeSize
          if includeSize then
            local StringUtil = require("common.string_util")
            local sizeList = StringUtil.Split(includeSize, ";")
            local moduleList = mIdModuleList[cfg.ID]
            local moduleCfg = moduleList[math.random(1, #moduleList)]
            if self.insertFailed >= 3 then
              local sizeIdx = math.random(1, #sizeList)
              local size = sizeList[sizeIdx]
              moduleCfg.showType = tonumber(size)
            else
              moduleCfg.showType = tonumber(sizeList[#sizeList])
            end
            local checkValed = function(index)
              if result[index] and result[index].mId and result[index].mId == 0 then
                return true
              end
              return false
            end
            function checkCanInsert(moduleCfg)
              local isInsert = false
              for i = 1, 16 do
                local _, col = self:IndexToRowCol(i)
                if moduleCfg.showType == 1 then
                  if checkValed(i) and checkValed(i + 1) and checkValed(i + 4) and checkValed(i + 5) and col ~= 4 then
                    result[i] = moduleCfg
                    result[i + 1] = moduleCfg
                    result[i + 4] = moduleCfg
                    result[i + 5] = moduleCfg
                    isInsert = true
                    break
                  end
                elseif moduleCfg.showType == 2 then
                  if checkValed(i) and checkValed(i + 1) and col ~= 4 then
                    result[i] = moduleCfg
                    result[i + 1] = moduleCfg
                    isInsert = true
                    break
                  end
                elseif moduleCfg.showType == 3 and checkValed(i) then
                  result[i] = moduleCfg
                  isInsert = true
                  break
                end
              end
              return isInsert
            end
            local isInsert = checkCanInsert(moduleCfg)
            if not isInsert then
              moduleCfg.showType = tonumber(sizeList[#sizeList])
              isInsert = checkCanInsert(moduleCfg)
              if not isInsert then
                self.insertFailed = self.insertFailed - 1
                if self.insertFailed <= 0 then
                  return result
                end
              else
                self.insertFailed = 10
              end
            else
              self.insertFailed = 10
            end
            if isInsert then
              if 1 < maxWeight then
                weightMap[maxWeight] = nil
              else
                table.remove(weightMap[maxWeight], index)
                if #weightMap[maxWeight] == 0 then
                  weightMap[maxWeight] = nil
                end
              end
            end
            if isInsert or self.insertFailed > 0 then
              return self:CreateOne(result, weightMap, mIdModuleList)
            else
              return result
            end
          end
        end
      end
    end
  end
  return result
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:CreateData(insertData, _moduleData)
  insertData.uid = tonumber(DataMgr.roleData.uid)
  insertData.showType = _moduleData.mData.showType or 1
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  if insertData.configData.ID == custom_presentation_config.NewModuleID.Relation and insertData.showType == 1 then
    insertData.showType = 3
  end
  for _, property in ipairs(custom_presentation_config.allPropertyMap) do
    if _moduleData.mData[property] then
      insertData[property] = _moduleData.mData[property]
      local TableUtil = require("common.table_util")
      local isCantUsed = TableUtil.IsInTable(custom_presentation_config.cantUsedProperty, property)
      if not isCantUsed then
        insertData.mmId = _moduleData.mData[property]
      end
    end
  end
  if not insertData.mmId then
    insertData.mmId = _moduleData.mId
  end
  return insertData
end
function Lobby_RoleInfo_CustomInformation_Popup_UIBP:OnClickOneKeyCreate()
  self:PlayAudio(sound_config.click_v1)
  if self.onKeyCount >= 20 then
    return
  end
  if self.lastTime and os.time() - self.lastTime < 1 then
    ShowNotice(34735)
    return
  end
  self.lastTime = os.time()
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local moduleList = self:CreateModule(custom_presentation_config.TabID.All)
  local moduleConfigList = CDataTable.GetTable("CustomPresentationModule")
  local weightList = {}
  local weightMap = {}
  local mIdModuleList = {}
  for _, v in ipairs(moduleList) do
    if v.moduleData then
      local mId = v.moduleData.mId
      if mIdModuleList[mId] == nil then
        mIdModuleList[mId] = {}
      end
      table.insert(mIdModuleList[mId], v)
    end
  end
  for mId, cfgList in pairs(mIdModuleList) do
    for _, moduleCfg in pairs(moduleConfigList) do
      if moduleCfg.ID == mId then
        table.insert(weightList, moduleCfg)
      end
    end
  end
  table.sort(weightList, function(a, b)
    return a.Weight > b.Weight
  end)
  for _, moduleCfg in ipairs(weightList) do
    if weightMap[moduleCfg.Weight] == nil then
      weightMap[moduleCfg.Weight] = {}
    end
    table.insert(weightMap[moduleCfg.Weight], moduleCfg)
  end
  local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
  local TableUtil = require("common.table_util")
  local cppData = TableUtil.CopyTable(custom_presentation_util.GetDataByUID(DataMgr.roleData.uid))
  local isOld = false
  if cppData and #cppData == 4 then
    isOld = true
  end
  if isOld then
    local tmp = {}
    for i = 1, 16 do
      table.insert(tmp, {
        mId = 0,
        mData = {showType = 1}
      })
    end
    local maxCppCnt = math.min(4, #self._cpData)
    for i = 1, maxCppCnt do
      local data = self._cpData[i]
      if data then
        if i == 1 then
          tmp[1] = data
        elseif i == 2 then
          tmp[3] = data
        elseif i == 3 then
          tmp[9] = data
        elseif i == 4 then
          tmp[11] = data
        end
      end
    end
    for _, cpData in ipairs(tmp) do
      if cpData.mId == custom_presentation_config.NewModuleID.Relation then
        cpData.mData.showType = 3
      end
    end
    cppData = tmp
  end
  for i = #cppData, 1, -1 do
    local cpData = cppData[i]
    for _, moduleConfig in ipairs(moduleConfigList) do
      local moduleId = moduleConfig.ID
      if moduleId == cpData.mId and cpData.mId > 0 then
        local insertData = {configData = moduleConfig, moduleData = cpData}
        insertData.        insertData = self:CreateData(insertData, cpData)
        local showType = cpData.mData.showType or 1
        if showType == 1 then
          cppData[i] = insertData
          cppData[i + 1] = insertData
          cppData[i + 4] = insertData
          cppData[i + 5] = insertData
        elseif showType == 2 then
          cppData[i] = insertData
          cppData[i + 1] = insertData
        else
          cppData[i] = insertData
        end
        if 1 < moduleConfig.Weight then
          weightMap[moduleConfig.Weight] = nil
        else
          local maxLen = #weightMap[moduleConfig.Weight]
          for j = maxLen, 1, -1 do
            if weightMap[moduleConfig.Weight][j].ID == moduleId then
              table.remove(weightMap[moduleConfig.Weight], j)
              break
            end
          end
        end
      end
    end
  end
  self.insertFailed = 10
  local ret = self:CreateOne(cppData, weightMap, mIdModuleList)
  if ret then
    self.LobbyChat_InformationCustomProfile_UIBP:OnClickOneKeyCreate(ret)
  end
  self.onKeyCount = self.onKeyCount + 1
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_RoleInfo_CustomInformation_Popup_UIBP)