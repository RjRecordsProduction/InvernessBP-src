local logic_card_collection = {}
function logic_card_collection:DefineAndResetData()
  self.card_collection_datas = require("common.LRU")(20, 600)
  self.temp_card_id_by_show = -1
  self.temp_set_action_version = nil
  self.temp_new_card_table = nil
  self.self_card_collection_datas = {}
  self.card_collection_table = nil
  self.card_version_list = nil
  self.card_version_red = nil
  self.unlockAction = nil
  self.jumpToLobby = false
  self.tipsLen = -1
  self.loadingDatas = nil
  self.tlogCache = {}
  self.bVersionOpen = nil
  self.bBluehole = nil
end
function logic_card_collection:OnInitialize()
end
function logic_card_collection:RegistEvents()
end
function logic_card_collection:OnLogin(bReLogin)
  self.self_card_collection_datas = {}
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  CardCollectionHandler.send_get_card_collect_data_req(tonumber(DataMgr.roleData.uid))
  self.bVersionOpen = nil
  self.bBluehole = nil
end
function logic_card_collection:OnLogOut()
end
function logic_card_collection:OnPreSwitchGameStatus(preState, nextState)
end
function logic_card_collection:OnPostSwitchGameStatus(preState, nextState)
end
function logic_card_collection:GetCardTipsText()
  if self.tipsLen == -1 then
    local i = 0
    local data = CDataTable.GetTable("CardTipsText")
    if data then
      for key, value in pairs(data) do
        i = i + 1
      end
      self.tipsLen = i
    else
      self.tipsLen = -2
    end
  elseif self.tipsLen == -2 then
    return LocUtil.LocalizeResFormat(79187)
  end
  local data = CDataTable.GetTableData("CardTipsText", math.random(self.tipsLen))
  local textStr = LocUtil.LocalizeResFormat(79187)
  if data then
    textStr = data.text
  end
  return textStr
end
function logic_card_collection:JumpToLobbyAction()
  self.jumpToLobby = true
end
function logic_card_collection:CheckToLobbyFlag()
  if self.jumpToLobby then
    self.jumpToLobby = false
    return true
  end
  self.jumpToLobby = false
  return false
end
function logic_card_collection:GetActionItemID()
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  local card_list = logic_card_collection_season:GetSelectVersionCardList(DataMgr.roleData.uid)
  if card_list then
    local CardNum = 0
    for _ in pairs(card_list) do
      CardNum = CardNum + 1
    end
    local Config = CDataTable.GetTableData("CardCollectionEmoteConfig", CardNum)
    if Config then
      return Config.EmoteID
    end
  end
  return 12220500
end
function logic_card_collection:GetLoadingData()
  return self.loadingDatas
end
function logic_card_collection:GetCardCacheData(uid)
  if uid == tonumber(DataMgr.roleData.uid) then
    return self.self_card_collection_datas
  end
  return self.card_collection_datas:Get(uid)
end
function logic_card_collection:GetCardIDData(uid, card_id)
  local card_list = self:GetCardCacheData(uid)
  if card_list and card_list.card_data and card_list.card_data[card_id] then
    return card_list.card_data[card_id]
  end
  return {
    level = 0,
    score = 0,
    gave_count = 0,
    cardImage = ""
  }
end
function logic_card_collection:GetCardCanGaveCount(id)
  local card_data = self:GetCardIDData(tonumber(DataMgr.roleData.uid), id)
  if not card_data or card_data.level == 0 then
    return 0
  end
  local table_data = self:GetTableDataByCardId(id)
  if card_data.level == 1 then
    return table_data.giftCount1
  elseif card_data.level == 2 then
    return table_data.giftCount2
  elseif card_data.level == 3 then
    return table_data.giftCount3
  end
  return 0
end
function logic_card_collection:GetSelectActionVersion(uid)
  local data = self:GetCardCacheData(uid)
  local sp_version = self:GetActionSpecificVersion()
  log_tree("logic_card_collection:GetSelectActionVersion data = ", {uid = uid, data = data})
  local select_version = data and data.action_card_version or sp_version
  if not data then
    if tonumber(DataMgr.roleData.uid) == uid then
      self:send_set_action_card_version_req(select_version)
    else
      self:send_get_card_collect_data_req(uid)
    end
  end
  if not self:GetCardsByVersionList(select_version) then
    select_version = sp_version
    log(bWriteLog and "logic_card_collection:GetSelectActionVersion not open version, over select_version = " .. select_version)
  end
  return select_version
end
function logic_card_collection:SetSelectActionVersion(version)
  if self.self_card_collection_datas.action_card_version == version then
    log(bWriteLog and "logic_card_collection:SetSelectActionVersion version is same = " .. version)
    return
  end
  if not self:GetCardsByVersionList(version) then
    log_error("logic_card_collection:SetSelectActionVersion version is error = " .. version)
    return
  end
  self:send_set_action_card_version_req(version)
end
function logic_card_collection:GetMyCardData()
  return self.self_card_collection_datas
end
function logic_card_collection:HasUnlockAction()
  return true
end
function logic_card_collection:GetActionSpecificVersion()
  return "3.9.0"
end
function logic_card_collection:IsBluehole()
  if self.bBluehole == nil then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    self.bBluehole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  end
  return self.bBluehole
end
function logic_card_collection:IsOpenCardCollection()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if self:IsBluehole() then
    log(bWriteLog and "logic_card_collection.IsOpenCardCollection BLUEHOLE")
    return false
  end
  if self.bVersionOpen == nil then
    local version_util = require("client.common.version_util")
    local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
    self.bVersionOpen = self:GetCardsByVersionList(ClientVersion) ~= nil
  end
  return self.bVersionOpen
end
function logic_card_collection:GetVersionList()
  if not self.card_collection_table then
    self:InitCardTableListData()
  end
  if self.card_version_list then
    return self.card_version_list
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  self.card_version_list = {}
  for version, _ in pairs(self.card_collection_table) do
    if version_util.CompareVersionStandard(ClientVersion, version) >= 0 then
      table.insert(self.card_version_list, {Title = version})
    end
  end
  table.sort(self.card_version_list, function(a, b)
    return version_util.CompareVersionStandard(a.Title, b.Title) == 1
  end)
  return self.card_version_list
end
function logic_card_collection:InitCardTableListData()
  self.card_collection_table = {}
  local data = CDataTable.GetTable("CardCollectionConfig")
  local version_util = require("client.common.version_util")
  for key, value in pairs(data) do
    local getVersion = version_util.GetMainFormat(value.version)
    if not self.card_collection_table[getVersion] then
      self.card_collection_table[getVersion] = {}
    end
    value.id = key
    table.insert(self.card_collection_table[getVersion], value)
  end
  for _, cardList in pairs(self.card_collection_table) do
    table.sort(cardList, function(a, b)
      return a.id < b.id
    end)
  end
end
function logic_card_collection:GetTableDataByCardId(id)
  return CDataTable.GetTableData("CardCollectionConfig", id)
end
function logic_card_collection:GetSelectVersionCardList(uid)
  local select_version = self:GetSelectActionVersion(uid)
  log(bWriteLog and "logic_card_collection:GetSelectVersionCardList select_version = " .. select_version)
  return self:GetCardsByVersionList(select_version)
end
function logic_card_collection:GetCardsByVersionList(version)
  if not version or version == "" then
    return nil
  end
  if not self.card_collection_table then
    self:InitCardTableListData()
  end
  local version_util = require("client.common.version_util")
  log(bWriteLog and "logic_card_collection:GetCardsByVersionList version = " .. version)
  if not self.card_collection_table[version] then
    local mainFormat = version_util.GetMainFormat(version)
    if not self.card_collection_table[mainFormat] then
      for v, value in pairs(self.card_collection_table) do
        if version_util.GetMainFormat(v) == mainFormat then
          return value
        end
      end
      log(bWriteLog and "logic_card_collection:GetCardsByVersionList not found version data, version = " .. version)
    end
    return self.card_collection_table[mainFormat]
  end
  return self.card_collection_table[version]
end
function logic_card_collection:GetGaveLog()
  local datas = self:GetMyCardData()
  if not datas or not datas.card_data then
    return {}
  end
  local result = {}
  local TimeUtil = require("client.common.time_util")
  local fomat_str = "{0}" .. LocUtil.LocalizeResFormat(36349)
  for key, value in pairs(datas.card_data) do
    if value.be_gave_data then
      table.insert(result, {
        content = LocUtil.GeneralFormat(fomat_str, "", value.be_gave_data.be_gave_name, self:GetTableDataByCardId(key).name),
        conclusion = TimeUtil.FormatTime_YMDHMS(value.be_gave_data.be_gave_time),
        time = tonumber(value.be_gave_data.be_gave_time)
      })
    end
  end
  table.sort(result, function(a, b)
    return a.time > b.time
  end)
  return result
end
function logic_card_collection:ClearCardNewFormVersion(version)
  local card_list = self:GetCardsByVersionList(version)
  if not card_list then
    log_error("logic_card_collection:ClearCardNewFormVersion not found cards from verison = " .. version)
    return
  end
  local new_list = {}
  self.card_version_red = self.card_version_red or {}
  for key, value in ipairs(card_list) do
    if self.self_card_collection_datas and self.self_card_collection_datas.card_data and self.self_card_collection_datas.card_data[value.id] and self.self_card_collection_datas.card_data[value.id].is_new then
      table.insert(new_list, value.id)
    end
  end
  if 0 < #new_list then
    self:send_clear_card_new_req(new_list)
  end
end
function logic_card_collection:ClearRedForVersion(verison)
  self:ClearCardNewFormVersion(verison)
  if not self:GetRedPointFromVersion(verison) then
    return
  end
  self.card_version_red[verison] = false
end
function logic_card_collection:GetRedPointFromVersion(version)
  if not self.card_version_red or not self.card_version_red[version] then
    return false
  end
  return self.card_version_red[version]
end
function logic_card_collection:UpdateRedData()
  self.card_version_red = self.card_version_red or {}
  if not self.self_card_collection_datas or not self.self_card_collection_datas.card_data then
    return
  end
  local version = ""
  for key, value in pairs(self.self_card_collection_datas.card_data) do
    local data = CDataTable.GetTableData("CardCollectionConfig", key)
    if not data then
      log_tree("logic_card_collection:UpdateRedData card_data = ", self.self_card_collection_datas.card_data)
      log_error("logic_card_collection:UpdateRedData not key = " .. key)
    else
      version = data.version
      if self.card_version_red and not self.card_version_red[version] then
        self.card_version_red[version] = value.is_new or false
      end
    end
  end
end
function logic_card_collection:GetDailyTaskRedPoint()
  local AssemblyRedPointData = require("client.slua.logic.task.assembly_reddot_data")
  local redData = AssemblyRedPointData.GetSubData(AssemblyRedPointData.reddot_id.dailyTask)
end
function logic_card_collection:IsCurrentVersion(version)
  if not version or version == "" then
    return false
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  ClientVersion = version_util.GetMainFormat(ClientVersion)
  local card_version = version_util.GetMainFormat(version)
  log(bWriteLog and string.format("logic_card_collection:IsCurrentVersion card_version = [%s] ClientVersion = [%s]", card_version, ClientVersion))
  return card_version == ClientVersion
end
function logic_card_collection:ShowCardHelp()
  local logic_version_album_macro = require("client.slua.logic.version_album.logic_version_album_macro")
  local allInfo = {}
  for index, value in ipairs(logic_version_album_macro.AlbumTabList) do
    local value = {
      tab = LocUtil.GetLocalizeResStr(value.title),
      title = LocUtil.GetLocalizeResStr(69088),
      textInfo = {
        {
          type = 1,
          content1 = LocUtil.GetLocalizeResStr(value.content)
        }
      }
    }
    if index == 1 then
      if not self:IsBluehole() then
        table.insert(allInfo, value)
      end
    else
      table.insert(allInfo, value)
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_two, allInfo)
end
function logic_card_collection:UpdateCardUI(uibase, widget, card_data, target_uid, style, extra_data)
  if not widget then
    log_error("logic_card_collection:UpdateCardUI widget is nil")
    return
  end
  local version_util = require("client.common.version_util")
  log(bWriteLog and "logic_card_collection:UpdateCardUI style: " .. style)
  if card_data and card_data.version then
    card_data.version = version_util.GetMainFormat(card_data.version)
  end
  if extra_data and extra_data.version then
    extra_data.version = version_util.GetMainFormat(extra_data.version)
  end
  log_tree("logic_card_collection:UpdateCardUI card_data = ", card_data)
  if style == 1 then
    log_tree("logic_card_collection:UpdateCardUI extra_data", extra_data)
  end
  log(bWriteLog and "logic_card_collection:UpdateCardUI target_uid: " .. target_uid)
  style = style or 0
  if style == 0 then
    self:UpdateCardWidget(uibase, widget, target_uid, card_data)
  else
    self:UpdateCardShowWidget(uibase, widget, target_uid, card_data, extra_data)
  end
end
function logic_card_collection:UpdateCardWidget(uibase, widget, target_uid, card_data)
  local cc_data = self:GetCardCacheData(target_uid)
  log_tree("logic_card_collection:UpdateCardWidget cc_data = ", cc_data)
  card_data = card_data or {id = 0}
  local card_net_data = self:GetCardIDData(target_uid, card_data.id)
  local isShowText = ""
  if cc_data and cc_data.show_card_id == card_data.id and self:IsCurrentVersion(card_data.version) then
    isShowText = LocUtil.GetLocalizeResStr(655737)
  end
  if widget.CanvasPanel_GaveCount then
    uibase:SetWidgetVisible(widget.CanvasPanel_GaveCount, false)
    if widget.TextBlock_GaveText then
      widget.TextBlock_GaveText:SetText(LocUtil.GetLocalizeResStr(76990))
    end
    if widget.TextBlock_GaveText then
      widget.TextBlock_GaveCount:SetText(LocUtil.LocalizeResFormat(6830, card_net_data.gave_count, self:GetCardCanGaveCount(card_data.id)))
    end
  end
  if widget.TextBlock_0 then
    widget.TextBlock_0:SetText(isShowText)
  end
  if widget.TextBlock_PlayerName then
    widget.TextBlock_PlayerName:SetText(card_data.name)
    if IsEditor then
      widget.TextBlock_PlayerName:SetText(card_data.name .. (card_net_data.is_new and "(New)" or ""))
    end
  end
  if widget.Image_0 then
    uibase:SetWidgetVisible(widget.Image_0, false)
    if card_net_data.is_new then
      uibase:SetWidgetVisible(widget.Image_0, true)
    end
  end
  self:UpdateCardFrameEffect(uibase, widget, card_data, {
    level = card_net_data.level,
    is_new = card_net_data.is_new or false
  })
end
function logic_card_collection:UpdateCardShowWidget(uibase, widget, target_uid, card_data, extra_data)
  local cc_data = self:GetCardCacheData(target_uid) or {show_card_id = 0}
  if not card_data or not card_data.id then
    card_data = self:GetTableDataByCardId(cc_data.show_card_id) or {id = 0}
    if card_data.version and not self:IsCurrentVersion(card_data.version) then
      card_data = {id = 0}
    end
  end
  local card_net_data = self:GetCardIDData(target_uid, card_data.id)
  local level = card_net_data.level
  if not extra_data then
    widget.TextBlock_PlayerName:SetText(card_data and card_data.name or "")
    uibase:SetWidgetVisible(widget.Image_flag, false, false)
  else
    level = extra_data.level or level
    widget.TextBlock_PlayerName:SetText(extra_data.playerName or "")
    if extra_data.nation and extra_data.nation ~= "IN" then
      local UIUtil = require("client.common.ui_util")
      if target_uid == tonumber(DataMgr.roleData.uid) then
        extra_data.nation = DataMgr.roleData.nation
      end
      UIUtil.UpdateNationImage(widget.Image_flag, extra_data.nation)
      uibase:SetWidgetVisible(widget.Image_flag, true, false)
    else
      uibase:SetWidgetVisible(widget.Image_flag, false, false)
    end
  end
  local versionStr
  if extra_data and extra_data.version then
    versionStr = extra_data.version
  end
  self:UpdateCardFrameEffect(uibase, widget, card_data, {
    level = level,
    is_new = card_net_data.is_new or false,
    version = versionStr
  })
end
function logic_card_collection:UpdateCardFrameEffect(uibase, widget, card_data, extra_data)
  local versionStr = card_data.version or extra_data.version or "3.7.0"
  local fe_data = logic_card_collection:GetCardFrameEffect(versionStr, extra_data.level or 0)
  if card_data.cardImage and card_data.cardImage ~= "" then
    uibase:SetTexture(widget.Image_Card, card_data.cardImage)
    if widget.Image_Black then
      uibase:SetWidgetVisible(widget.Image_Black, extra_data.level == 0)
    end
  else
    if not fe_data.cardBackPath then
      uibase:SetTexture(widget.Image_Card, "/Game/UMG/Texture_200/Lobby_NoAtlas/EventPhoto/ContainerTrucks/Cards_Back.Cards_Back")
    else
      uibase:SetTexture(widget.Image_Card, fe_data.cardBackPath)
    end
    if widget.Image_Black then
      uibase:SetWidgetVisible(widget.Image_Black, false)
    end
  end
  uibase:SetWidgetVisible(widget.Image_Effect1, false)
  uibase:SetWidgetVisible(widget.Image_Effect2, false)
  uibase:SetWidgetVisible(widget.Image_Effect3, false)
  if extra_data.level > 1 then
    local logic_version_album_macro = require("client.slua.logic.version_album.logic_version_album_macro")
    local zOrders = logic_version_album_macro.CardEffectZOrder[versionStr]
    if fe_data.effect_data and fe_data.effect_data ~= "" then
      local StringUtil = require("common.string_util")
      local effects = StringUtil.Split(fe_data.effect_data, "|")
      for i = 1, 3 do
        if effects[i] and effects[i] ~= "" then
          uibase:SetTexture(widget["Image_Effect" .. i], effects[i])
          uibase:SetWidgetVisible(widget["Image_Effect" .. i], true)
          widget["Image_Effect" .. i].Slot:SetZOrder(zOrders[i])
        end
      end
    end
  end
  uibase:SetWidgetVisible(widget.Image_Frame, false)
  uibase:SetWidgetVisible(widget.Image_Frame2, false)
  uibase:SetWidgetVisible(widget.Image_Frame3, false)
  local setFrame = function()
    uibase:SetWidgetVisible(widget.Image_Frame, extra_data.level == 1)
    uibase:SetWidgetVisible(widget.Image_Frame2, extra_data.level == 2)
    uibase:SetWidgetVisible(widget.Image_Frame3, extra_data.level == 3)
    local widgetName = extra_data.level == 1 and "" or tostring(extra_data.level)
    uibase:SetTexture(widget["Image_Frame" .. widgetName], fe_data.frame_data)
  end
  if widget.CanvasPanel_Card and extra_data.is_new then
    if fe_data.levelupSound and fe_data.levelupSound ~= "" then
      uibase:PlayAudio(fe_data.levelupSound)
    end
    if fe_data.effect_path and 0 < extra_data.level and extra_data.level < 4 then
      uibase:CreateChildWindowWithLuaAndBpPath(widget.CanvasPanel_Card, nil, "client.slua.umg.EventPhoto.Popup.Item.VersionAlbum_CardLevelup_Effect", fe_data.effect_path, extra_data.level, setFrame, versionStr)
    end
  else
    setFrame()
  end
end
function logic_card_collection:GetCardFrameEffect(version, level)
  if not version then
    local version_util = require("client.common.version_util")
    version = version_util.GetClientFormat(Client.GetAppVersion())
  end
  local frame_data = CDataTable.GetTableData("CardFrameEffect", version)
  frame_data = frame_data or CDataTable.GetTableData("CardFrameEffect", "3.7.0")
  local result = {}
  result.cardBackPath = frame_data.cardBackPath
  result.levelupSound = frame_data.levelupSound
  result.effect_path = frame_data.effectPath or "/Game/UMG/UI_BP/EventPhoto/Item/VersionAlbum_CardLevelup_Effect_370.VersionAlbum_CardLevelup_Effect_370"
  if level == 1 then
    result.frame_data = frame_data.frame1
    result.effect_data = frame_data.effect1
  elseif level == 2 then
    result.frame_data = frame_data.frame2
    result.effect_data = frame_data.effect2
  elseif level == 3 then
    result.frame_data = frame_data.frame3
    result.effect_data = frame_data.effect3
  end
  return result
end
function logic_card_collection:GetPercentColor()
  return FLinearColor(1, 0.563919, 0, 1)
end
function logic_card_collection:PreInitCardListData(uidList)
  self.tlogCache = {}
  self.loadingDatas = {}
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  log_tree("logic_card_collection:PreInitCardListData uidList = ", uidList)
  for index, value in ipairs(uidList) do
    local uid = tonumber(value)
    log(bWriteLog and "logic_card_collection:PreInitCardListData uid = " .. uid)
    self.loadingDatas[uid] = {
      name = "",
      nation = "",
      index = 1
    }
    if uid ~= tonumber(DataMgr.roleData.uid) then
      self:send_get_card_collect_data_req(uid)
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, function(list)
    log_tree("logic_card_collection:PreInitCardListData list = ", list)
    if not list then
      return
    end
    local bAnchorNameEnable = LogicPeakGame:DoesMatchGame()
    log(bWriteLog and "logic_card_collection:PreInitCardListData bAnchorNameEnable = " .. (bAnchorNameEnable == true and "true" or "false"))
    for index, value in ipairs(list) do
      local uid = tonumber(value.uid)
      if uid and self.loadingDatas[uid] then
        if bAnchorNameEnable then
          self.loadingDatas[uid].name = value.anchor_random_name or value.nickName
        else
          self.loadingDatas[uid].name = value.nickName
        end
        self.loadingDatas[uid].nation = value.nation
      end
    end
    EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_GET_CARDLIST_FORLOADING)
    local listData = self:GetLoadingData()
    log_tree("logic_card_collection:PreInitCardListData listData", listData)
  end, Enum_PROFILE_REPORT_CFG.VersionAlbum, Enum_PROFILE_REPORT_CFG.VersionAlbum, true)
end
function logic_card_collection:_UpdateCardData(uid, card_collect_data)
  log(bWriteLog and "logic_card_collection:_UpdateCardData uid = " .. tostring(uid))
  log_tree("logic_card_collection:_UpdateCardData card_collect_data = ", card_collect_data)
  if uid == tonumber(DataMgr.roleData.uid) then
    self.self_card_collection_datas = card_collect_data
    self:UpdateRedData()
  else
    self.card_collection_datas:Set(uid, card_collect_data)
  end
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_GET_CARD_DATA, uid)
end
function logic_card_collection:SetTeammateSelectActionVersion(uid, version)
  local collectionData = self.card_collection_datas:Get(uid)
  if collectionData then
    log(bWriteLog and string.format("logic_card_collection:SetTeammateSelectActionVersion uid=%s, version=%s->%s", tostring(uid), tostring(collectionData.action_card_version), tostring(version)))
    collectionData.action_card_  end
end
function logic_card_collection:send_get_card_collect_data_req(target_uid)
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  CardCollectionHandler.send_get_card_collect_data_req(tonumber(target_uid))
end
function logic_card_collection:on_get_card_collect_data_rsp(target_uid, card_collect_data)
  self:_UpdateCardData(target_uid, card_collect_data)
end
function logic_card_collection:send_give_collect_card_req(card_id, accept_uid)
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  CardCollectionHandler.send_give_collect_card_req(card_id, tonumber(accept_uid))
end
function logic_card_collection:on_give_collect_card_rsp(card_id, gave_count)
  if not self.self_card_collection_datas.card_data or not self.self_card_collection_datas.card_data[card_id] then
    log_tree("logic_card_collection:on_give_collect_card_rsp err = ", self.self_card_collection_datas)
    return
  end
  self.self_card_collection_datas.card_data[card_id].  ShowNotice(200018)
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_CARD_GAVE_SUCCESS, card_id)
end
function logic_card_collection:send_set_show_card_req(card_id)
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  self.temp_card_id_by_show = card_id
  CardCollectionHandler.send_set_show_card_req(card_id)
end
function logic_card_collection:on_set_show_card_rsp()
  self.self_card_collection_datas.show_card_id = self.temp_card_id_by_show
  self.temp_card_id_by_show = -1
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_SET_SHOW_CARD)
end
function logic_card_collection:send_clear_be_gave_new_req()
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  CardCollectionHandler.send_clear_be_gave_new_req()
  self.self_card_collection_datas.be_gave_new_count = 0
end
function logic_card_collection:send_clear_card_new_req(new_card_table)
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  self.temp_  CardCollectionHandler.send_clear_card_new_req(new_card_table)
end
function logic_card_collection:on_clear_card_new_rsp()
  log_tree("logic_card_collection:on_clear_card_new_rsp temp_new_card_table = ", self.temp_new_card_table)
  log_tree("logic_card_collection:on_clear_card_new_rsp self_car_collection_datas = ", self.self_card_collection_datas)
  if not self.temp_new_card_table or not self.self_card_collection_datas then
    return
  end
  if not self.self_card_collection_datas.card_data then
    self.self_card_collection_datas.card_data = {}
  end
  for _, value in pairs(self.temp_new_card_table) do
    if self.self_card_collection_datas.card_data[value] then
      self.self_card_collection_datas.card_data[value].is_new = false
    end
  end
  self.temp_new_card_table = nil
end
function logic_card_collection:on_notify_new_card_accept(accept_uid, give_uid, card_id, be_gave_new_count)
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_CARD_GAVE_NOTIFY)
end
function logic_card_collection:on_notify_card_collect_data(card_collect_data)
  if not self.self_card_collection_datas then
    self.self_card_collection_datas = {}
  end
  self.self_card_collection_datas.card_data = card_collect_data
  self:_UpdateCardData(tonumber(DataMgr.roleData.uid), self.self_card_collection_datas)
end
function logic_card_collection:send_set_action_card_version_req(version)
  log(bWriteLog and "logic_card_collection:send_set_action_card_version_req version=" .. tostring(version))
  local CardCollectionHandler = require("client.network.Protocol.CardCollectionHandler")
  CardCollectionHandler.send_set_action_card_version_req(version)
  self.temp_set_action_end
function logic_card_collection:on_set_action_card_version_rsp()
  log(bWriteLog and "logic_card_collection:on_set_action_card_version_rsp")
  if self.temp_set_action_version == nil or self.temp_set_action_version == "" then
    log_error("logic_card_collection:on_set_action_card_version_rsp temp_set_action_version == nil")
    return
  end
  self.self_card_collection_datas.action_card_version = self.temp_set_action_version
  self.temp_set_action_version = nil
  self:_UpdateCardData(tonumber(DataMgr.roleData.uid), self.self_card_collection_datas)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_card_collection = class(CModuleBase, nil, logic_card_collection)
return Clogic_card_collection