local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
local RoleInfoHistoryUI = {}
local HunterVsHunterCompIcon = {
  [0] = "/Game/UMG/Texture/Lobby_NoAtlas/RoleInfo/Lobby_RoleInfo_Role01.Lobby_RoleInfo_Role01",
  [1] = "/Game/UMG/Texture/Lobby_NoAtlas/RoleInfo/Lobby_RoleInfo_Role02.Lobby_RoleInfo_Role02"
}
function RoleInfoHistoryUI:ctor(eventType)
  self.logic_roleinfo_history = require("client.logic.roleinfo.logic_roleinfo_history")
  self.roleinfo_history_data_mgr = require("client.logic.roleinfo.roleinfo_history_data_mgr")
  self.widgetPeakRankUIMap = {}
  self.hasAutoShowPromotionTip = false
  self.C_AutoShowPromotionTipTime = 5
  self.C_AutoShowPromotionTipCount = 5
end
function RoleInfoHistoryUI:OnInitialize()
  RoleInfoHistoryUI.__super.OnInitialize(self)
  self.ScrollBox = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
end
function RoleInfoHistoryUI:RegistEvents()
  RoleInfoHistoryUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_HISTORY_LIST_UI, self.OnGetRoleinfoHistoryList, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_guest_tip, self.OnClickGustTips, self)
  self.ScrollBox:SetRefreshItemCallback(self.OnUpdateItem, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_Open_detail", "OnClicked", self.OnShowRecord, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_0", "OnClicked", self.OnClickReplay, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_1", "OnClicked", self.OnShowTips, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_Limit", "OnClicked", self.OnClickButtonLimit, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_PromotionWarn", "OnClicked", self.OnClickButtonPromotionWarn, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_PromotionTip", "OnClicked", self.OnClickButtonPromotionTip, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_2", "OnClicked", self.OnClickButtonPromotionWarn, self)
end
function RoleInfoHistoryUI:OnShow()
  self:UpdateModeCombobox()
  self:SetRoleUID()
  self:UpdateUIByDataList()
  self:InitUIText()
  self:SetCurServerInfo()
  self:HideRedpoint()
  self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
end
function RoleInfoHistoryUI:OnClose()
  self.logic_roleinfo_history.SaveShowGlowData()
  self.widgetPeakRankUIMap = nil
  RoleInfoHistoryUI.__super.OnClose(self)
end
function RoleInfoHistoryUI:OnGetRoleinfoHistoryList()
  log(bWriteLog and "RoleInfoHistoryUI:OnGetRoleinfoHistoryList")
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  self:UpdateUI(history_combat_cfg.EBattleType.All)
end
function RoleInfoHistoryUI:UpdateModeCombobox()
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  local modeList = logic_history_combat:GetModeList()
  self.ComboBox_Type = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_UIBP)
  self.ComboBox_Type:SetRefreshOptionCallback(self.OnRefreshComboBoxItem, self)
  self.ComboBox_Type:SetSelectOptionCallback(self.OnSelectModeItem, self)
  self.ComboBox_Type:SetData(modeList)
  self.ComboBox_Type:SelectIndex(1)
end
function RoleInfoHistoryUI:OnRefreshComboBoxItem(widget, data, index, selectIndex)
end
function RoleInfoHistoryUI:OnSelectModeItem(widget, data)
  self:PlayAudio(sound_config.click_v1)
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  logic_history_combat:ReportTlog(data.type)
  self:UpdateUI(data.type)
  widget.TextBlock_ItemName:SetText(data.text)
end
function RoleInfoHistoryUI:SetRoleUID()
  local roleId = RoleInfoMainSystem.GetRoleId()
  self.logic_roleinfo_history.SetUID(roleId)
  self.uid = roleId
  if tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
    local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
    logic_history_combat:ClearHunterVsHuntedRecord()
  end
end
function RoleInfoHistoryUI:UpdateUIByDataList()
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  local type = history_combat_cfg.EBattleType.All
  if tonumber(self.logic_roleinfo_history.cachedUid) == tonumber(self.uid) then
    self.logic_roleinfo_history.SetRecordSummarylist(self.uid)
    self.logic_roleinfo_history.SetHistoryList()
    self:UpdateUI(type)
    return
  end
  log(bWriteLog and "[bgp] self.logic_roleinfo_history.privacy" .. tostring(self.logic_roleinfo_history.privacy))
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and self.logic_roleinfo_history.uid ~= DataMgr.roleData.uid then
    if self.logic_roleinfo_history.privacy == 0 then
      self.logic_roleinfo_history.UpdateHistoryEmptyType(false)
      self.logic_roleinfo_history.SetHistoryList()
      self:UpdateUI(type)
      return
    elseif self.logic_roleinfo_history.privacy == 1 then
    elseif self.logic_roleinfo_history.privacy == 2 then
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if not LogicFriend.IsMyFriend(self.logic_roleinfo_history.uid) then
        self.logic_roleinfo_history.UpdateHistoryEmptyType(false)
        self.logic_roleinfo_history.SetHistoryList()
        self:UpdateUI(type)
        return
      end
    end
  elseif not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and self.logic_roleinfo_history.uid ~= DataMgr.roleData.uid and not self.logic_roleinfo_history.privacy then
    self.logic_roleinfo_history.UpdateHistoryEmptyType(false)
    self.logic_roleinfo_history.SetHistoryList()
    self:UpdateUI(type)
    return
  end
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_get_history_record_summary(tonumber(self.uid))
  CharacterHandler.send_get_peakgame_history_summary_req(tonumber(self.uid))
end
function RoleInfoHistoryUI:InitUIText()
  local strTips = LocUtil.LocalizeResFormat(118002)
  self.UIRoot.TextBlock_0:SetText(strTips)
end
function RoleInfoHistoryUI:SetCurServerInfo()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  local zoneConfig = CDataTable.GetTableData("ZoneConfig", zoneID)
  if zoneConfig then
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    local name = logic_multiple_area:GetDisplayNameByZoneID(zoneID)
    self.UIRoot.TextBlock_CurServer:SetText(name)
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    local ms = logic_zone_delay.GetChoosenZoneDelay(360, 10000)
    local color = logic_zone_delay.GetPingColor(ms)
    self.UIRoot.Image_ZoneDelay:SetColorAndOpacity(color)
    self.UIRoot.CanvasPanel_Server:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Server:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfoHistoryUI:HideRedpoint()
  if RoleInfoMainSystem.IsShowSelf() then
    RoleInfoMainSystem.SetHistoryRed(false)
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ROLE_INFO, false)
  end
end
function RoleInfoHistoryUI:UpdateUI(type)
  log(bWriteLog and "[bgp] RoleInfoHistoryUI:UpdateUI")
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  type = type or history_combat_cfg.EBattleType.All
  local arrayData = logic_history_combat:GetHistoryList(type)
  if not arrayData or #arrayData <= 0 then
    self.UIRoot.GridPanel_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:HistoryEmptyTipsLogic()
    self.ScrollBox:SetData({})
    return
  end
  self.UIRoot.GridPanel_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ScrollBox:SetData(arrayData)
  if GlobalData.IsPlatformTourist() then
    self.UIRoot.CanvasPanel_guest_tip:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_guest_tip:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfoHistoryUI:HistoryEmptyTipsLogic()
  local emptyType = self.logic_roleinfo_history.GetHistoryEmtyType()
  if emptyType == 0 then
    return
  end
  local strContent = ""
  if emptyType == 1 then
    strContent = LocUtil.LocalizeResFormat(105007)
  elseif emptyType == 2 then
    strContent = LocUtil.LocalizeResFormat(105008)
  elseif emptyType == 3 then
    strContent = LocUtil.LocalizeResFormat(105009)
  end
  self.UIRoot.TextBlock_53:SetText(strContent)
end
function RoleInfoHistoryUI:OnUpdateItem(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  if not data then
    return
  end
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  if logic_history_combat:IsShowEffect(data.battle_id) then
    self:PlayWidgetAnimation(widget, widget.Animation_Sweep, 0, 1, 0, 1)
    self:SetWidgetVisible(widget.Image_Sweep, true)
  else
    self:SetWidgetVisible(widget.Image_Sweep, false)
  end
  local totalRating = self.logic_roleinfo_history.GetTotalRating(data)
  local iconPath = self.logic_roleinfo_history.GetRatingIconPath(data, data.raw_battle_type)
  widget.WidgetSwitcher_Icon:SetActiveWidgetIndex(0)
  if totalRating and 0 < totalRating then
    widget.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetWidgetVisible(widget.CanvasPanel_6, true)
    widget.WidgetSwitcher_5:SetActiveWidgetIndex(1)
    widget.TextBlock_13:SetText(string.format("+%s", totalRating))
  elseif iconPath then
    widget.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetWidgetVisible(widget.CanvasPanel_6, true)
    widget.WidgetSwitcher_5:SetActiveWidgetIndex(0)
    self:SetTexture(widget.Image_3, iconPath)
  elseif data.season_status_for_display then
    widget.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetWidgetVisible(widget.CanvasPanel_6, true)
    widget.SizeBox_8:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.WidgetSwitcher_5:SetActiveWidgetIndex(2)
  else
    widget.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(widget.CanvasPanel_6, false)
  end
  if data.peakgame_cross_zone_team_limit then
    self:SetWidgetVisible(widget.Button_1, true, true)
    widget.WidgetSwitcher_Icon:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(widget.CanvasPanel_6, true)
  end
  widget.WidgetSwitcher_individualRank:SetActiveWidgetIndex(0)
  widget.Image_numberOne:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetBtnReplayVisible(widget, index)
  self:SetWidgetVisible(widget.HorizontalBox_MetroWorth, false)
  if data.is_txMission and not FuncUtil.IsXmissionTeamMode(data.raw_battle_type) then
    self:SetWidgetVisible(widget.WidgetSwitcher_2, false)
    self:RefershItemToTxMission(widget, data)
  else
    self:SetWidgetVisible(widget.WidgetSwitcher_2, true)
    self:RefershItemToNormal(widget, index)
  end
  self:UpdateHunterVsHunterItem(widget, data, index)
  self:SetPromotion(widget, data, index)
end
function RoleInfoHistoryUI:SetBtnReplayVisible(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  local battle_id = data.battle_id or 0
  if not LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH) then
    widget.SizeBox_replay:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  local has_replay = logic_share_replay.CheckHasBattleReplay(battle_id)
  if has_replay then
    local has_show = self.logic_roleinfo_history.CheckIsShowGlowEffect(battle_id, data.timestamp)
    if has_show then
      widget.PlayBack_Glow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      widget.PlayBack_Glow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    widget.SizeBox_replay:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.WidgetSwitcher_replay:SetActiveWidgetIndex(0)
  else
    widget.SizeBox_replay:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  log(bWriteLog and "[v_wllwu] RoleInfoHistoryUI SetBtnReplayVisible battle_id is " .. tostring(battle_id) .. " isShow = " .. tostring(has_replay))
  widget.SizeBox_Server:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function RoleInfoHistoryUI:RefershItemToTxMission(widget, data)
  widget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.TextBlock_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.TextBlock_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.WidgetSwitcher_3:SetActiveWidgetIndex(1)
  widget.TextBlockKill:SetText(data.kill or 0)
  local zone_name = data.zone_name
  if zone_name == nil or zone_name == "" then
    log(bWriteLog and "RoleInfoHistoryUI:RefershItemToTxMission zone_name is invalid")
    widget.TextBlockTime:SetText(data.time)
  else
    widget.TextBlockTime:SetText(LocUtil.LocalizeResFormat(45903, tostring(zone_name), tostring(data.time)))
  end
  widget.TextBlock_4:SetText(data.battle_mode)
  widget.TextBlockBattleType:SetText(data.battle_type or 0)
  widget.CanvasPanel_Subscript:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.CanvasPanel_17:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if data.txMissionEscaped then
    widget.TextBlock_hvhWinText:SetText(LocUtil.GetLocalizeResStr(67793))
    widget.WidgetSwitcher_individualRank:SetActiveWidgetIndex(1)
  else
    widget.TextBlock_hvhLoseText:SetText(LocUtil.GetLocalizeResStr(67794))
    widget.WidgetSwitcher_individualRank:SetActiveWidgetIndex(2)
  end
  local worth_change = data.worth_change or -1
  log(bWriteLog and "RoleInfoHistoryUI:RefershItemToTxMission worth_change = " .. tostring(worth_change))
  if data.compatibility_flag and data.compatibility_flag == 1 and 0 <= worth_change then
    worth_change = FuncUtil.Conv_Int64ToText(math.floor(tonumber(worth_change)))
    widget.TextBlock_BringOut:SetText(worth_change)
    self:SetWidgetVisible(widget.HorizontalBox_MetroWorth, true)
  else
    self:SetWidgetVisible(widget.HorizontalBox_MetroWorth, false)
  end
  widget.TextBlock_8:SetText(data.final_level or "")
end
function RoleInfoHistoryUI:RefershItemToNormal(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  if data.is_team_athletics or FuncUtil.IsXmissionTeamMode(data.raw_battle_type) then
    self:SetTeamAthletics(widget, index)
  else
    self:SetNormalMode(widget, index)
  end
  widget.WidgetSwitcher_3:SetActiveWidgetIndex(0)
end
function RoleInfoHistoryUI:SetTeamAthletics(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  self:SetFinalLevel(widget, data.final_level)
  self:SetWidgetByIsTeamAthleicsWin(widget, index)
  widget.Image_invalid:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.TextBlock_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.TextBlock_6:SetText("--")
  widget.TextBlock_4:SetText(data.battle_mode)
  widget.TextBlockBattleType:SetText(data.battle_type)
  local zone_name = data.zone_name
  if zone_name == nil or zone_name == "" then
    log(bWriteLog and "RoleInfoHistoryUI:SetTeamAthletics zone_name is invalid")
    widget.TextBlockTime:SetText(data.time)
  else
    widget.TextBlockTime:SetText(LocUtil.LocalizeResFormat(45903, tostring(zone_name), tostring(data.time)))
  end
  widget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.TextBlockRank:SetText("--")
  widget.TextBlockKill:SetText(data.kill)
  self:SetSegmentWidget(widget, index, true)
  widget.TextBlockRating:SetText(data.rating)
  if data.is_escape and data.is_escape == 1 then
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(3)
    self:SetTexture(widget.Image_8, "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/JS_icon_taobao_png.JS_icon_taobao_png")
  elseif self.logic_roleinfo_history.IsOffline(data.offline_time) then
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(3)
    self:SetTexture(widget.Image_8, "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/JS_Icon_Disconnected_png.JS_Icon_Disconnected_png")
  else
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(2)
  end
  if data.is_team_athletics_mvp then
    widget.WidgetSwitcher_ResultItem_MVP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if data.is_team_athletics_win then
      widget.WidgetSwitcher_ResultItem_MVP:SetActiveWidgetIndex(0)
    else
      widget.WidgetSwitcher_ResultItem_MVP:SetActiveWidgetIndex(1)
    end
  else
    widget.WidgetSwitcher_ResultItem_MVP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if not data.team_athletics_hits or tostring(data.team_athletics_hits) == "" then
    widget.CanvasPanel_ResultItem_MultiKill:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    widget.CanvasPanel_ResultItem_MultiKill:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.TextBlock_ResultItem_MultiKill:SetText(data.team_athletics_hits)
  end
end
function RoleInfoHistoryUI:SetWidgetByIsTeamAthleicsWin(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  widget.CanvasPanel_Subscript:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if data.is_team_athletics_draw then
    widget.Image_Win:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_Failure:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_Draw:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local str = LocUtil.GetLocalizeResStr(45973)
    widget.TextBlock_3:SetText(str)
  elseif data.is_team_athletics_win then
    widget.Image_Win:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_Failure:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_Draw:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local str = LocUtil.GetLocalizeResStr(509021)
    widget.TextBlock_3:SetText(str)
  else
    widget.Image_Win:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_Failure:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_Draw:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local str = LocUtil.GetLocalizeResStr(7733)
    widget.TextBlock_3:SetText(str)
  end
end
function RoleInfoHistoryUI:SetNormalMode(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  widget.CanvasPanel_Subscript:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetFinalLevel(widget, data.final_level)
  self:SetInvalidWidget(widget, index)
  widget.TextBlock_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.TextBlock_6:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if data.is_peakgame then
    widget.TextBlock_6:SetText(data.peakgame_team_rank)
  else
    widget.TextBlock_6:SetText(data.team_rank)
  end
  widget.TextBlock_4:SetText(data.battle_mode)
  widget.TextBlockBattleType:SetText(data.battle_type)
  local zone_name = data.zone_name
  if zone_name == nil or zone_name == "" then
    log(bWriteLog and "RoleInfoHistoryUI:SetNormalMode zone_name is invalid")
    widget.TextBlockTime:SetText(data.time)
  else
    widget.TextBlockTime:SetText(LocUtil.LocalizeResFormat(45903, tostring(zone_name), tostring(data.time)))
  end
  widget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.TextBlockRank:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.TextBlockRank:SetText(data.person_rank or "")
  widget.TextBlockKill:SetText(data.kill)
  self:SetSegmentWidget(widget, index)
  widget.TextBlockRating:SetText(data.rating)
  self:SetNewTitle(widget, index)
end
function RoleInfoHistoryUI:SetFinalLevel(widget, level)
  local stringlen = #level
  if 4 < stringlen or level == "" or level == "B" or level == "B+" then
    widget.CanvasPanel_17:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  widget.CanvasPanel_17:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.UTRichTextBlock_0:SetText(level)
end
function RoleInfoHistoryUI:SetRankTextAndLabelTextColor(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  if tonumber(data.team_rank) > 10 then
    local color = FSlateColor((FLinearColor(0.02, 0.027, 0.03, 1)))
    widget.TextBlock_6:SetColorAndOpacity(color)
  else
    local color = FSlateColor((FLinearColor(0.59, 0.147, 0, 1)))
    widget.TextBlock_6:SetColorAndOpacity(color)
  end
end
function RoleInfoHistoryUI:SetRankTextToNumberOne(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  local GetFont = function(text, is_frist)
    local font = text.Font
    if is_frist then
      font.Size = 33
    else
      font.Size = 18
    end
    return font
  end
  if tonumber(data.team_rank) > 10 then
    local color = FSlateColor((FLinearColor(0.02, 0.027, 0.03, 1)))
    local font = GetFont(widget.TextBlock_5, false)
    widget.TextBlock_5:SetColorAndOpacity(color)
    widget.TextBlock_5:SetFont(font)
    widget.TextBlock_6:SetColorAndOpacity(color)
    widget.TextBlock_6:SetFont(font)
  else
    if tonumber(data.team_rank) == 1 then
      widget.Image_numberOne:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local font = GetFont(widget.TextBlock_5, true)
      widget.TextBlock_5:SetFont(font)
      widget.TextBlock_6:SetFont(font)
    else
      local font = GetFont(widget.TextBlock_5, false)
      widget.TextBlock_5:SetFont(font)
      widget.TextBlock_6:SetFont(font)
    end
    local color = FSlateColor((FLinearColor(0.59, 0.147, 0, 1)))
    widget.TextBlock_5:SetColorAndOpacity(color)
    widget.TextBlock_6:SetColorAndOpacity(color)
  end
end
function RoleInfoHistoryUI:SetSegmentWidget(widget, index, is_invalid)
  local data = self.ScrollBox:GetItemData(index)
  if data.show_score then
    widget.WidgetSwitcher_1:SetActiveWidgetIndex(0)
  else
    widget.WidgetSwitcher_1:SetActiveWidgetIndex(1)
  end
  widget.WidgetSwitcher_9:SetActiveWidgetIndex(0)
  self:SetWidgetVisible(widget.WidgetSwitcher_9, true)
  widget.TextBlockChangeRating:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not is_invalid then
    if data.is_sink_mode then
      local UISinkSegment = require("client.slua.umg.sink.ui_sink_segment")
      UISinkSegment.SetSinkSegmentSmallIconWithName(widget.Sink_RankIntegralLevel_Style_Small_UIBP, data.segment, widget.TextBlock_Sink_Segment_Name)
      self:SetWidgetVisible(widget.WidgetSwitcher_9, false)
    elseif data.is_peakgame then
      self:SetWidgetVisible(widget.Sink_RankIntegralLevel_Style_Small_UIBP, false)
      self:SetWidgetVisible(widget.TextBlock_Sink_Segment_Name, false)
      if not self.widgetPeakRankUIMap[widget] then
        local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
        local peakrankui = LogicPeakGameUtil.InitSmallPeakRankIntegralWidget(self, widget.PeakGame_RankIntegralLevel_Style_Small_UIBP)
        self.widgetPeakRankUIMap[widget] = peakrankui
      end
      self.widgetPeakRankUIMap[widget]:SetPeakRankIntegral(data.segment)
      widget.WidgetSwitcher_9:SetActiveWidgetIndex(1)
    else
      widget.Sink_RankIntegralLevel_Style_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.TextBlock_Sink_Segment_Name:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.Common_RankIntegralLevel_Style_Small_UIBP:SetRankCustomColorWithSegmentTitle(data.segment, nil, FSlateColor((FLinearColor(1, 1, 1, 1))), data.season_id or 0, nil, data.rating)
    end
    if tostring(data.change_rating) ~= "" then
      widget.TextBlockChangeRating:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.TextBlockChangeRating:SetText(data.change_rating)
    end
  else
    widget.Sink_RankIntegralLevel_Style_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.TextBlock_Sink_Segment_Name:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Common_RankIntegralLevel_Style_Small_UIBP:SetArenaRankInteralWithCustomColor(data.segment, nil, FSlateColor((FLinearColor(1, 1, 1, 1))))
    if tostring(data.change_rating) ~= "" then
      widget.TextBlockChangeRating:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.TextBlockChangeRating:SetText(data.change_rating)
    end
  end
end
function RoleInfoHistoryUI:SetInvalidWidget(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  if data.is_invalid then
    widget.Image_invalid:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.Image_invalid:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfoHistoryUI:SetNewTitle(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  if not data then
    return
  end
  if data.praise_medal_data and next(data.praise_medal_data) then
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(5)
    local CombatMedalUIUtil = require("client.slua.umg.combat_medal.combat_medal_ui_util")
    local medalList = CombatMedalUIUtil.ProcessingMedalData(data.praise_medal_data)
    CombatMedalUIUtil.SetMedalItem(widget.Medal_Item_Tips, medalList, {
      r = 1,
      g = 1,
      b = 1,
      a = 1
    })
    return
  end
  if data.praise_title_data and data.praise_title_data.title_id then
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(5)
    local titleData = data.praise_title_data
    local CombatMedalUIUtil = require("client.slua.umg.combat_medal.combat_medal_ui_util")
    CombatMedalUIUtil.SetTitleItem(widget.Medal_Item_Tips, titleData)
    return
  end
  if tonumber(data.new_title_id) ~= 0 then
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(0)
    widget.ResultRanking_DetailTitel_UIBP:InitTitle(data.new_title_id)
  else
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(1)
    widget.Lobby_RoleInfo_History_Title_UIBP:SetTitleId(data.title_id)
  end
end
function RoleInfoHistoryUI:SetZoneTipsText(widget, index)
  local data = self.ScrollBox:GetItemData(index)
  if data.cross_zone_flag then
    widget.TextBlock_CrossZone:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.TextBlock_CrossZone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfoHistoryUI:UpdateHunterVsHunterItem(widget, data, index)
  local bIsHVH = data.camp_type and true or false
  self:SetWidgetVisible(widget.WidgetSwitcher_CampStatus, bIsHVH)
  self:SetWidgetVisible(widget.HorizontalBox_Rank, not bIsHVH)
  self:SetWidgetVisible(widget.Image_numberOne, not bIsHVH)
  self:SetWidgetVisible(widget.HorizontalBox_RankIcon, not bIsHVH)
  self:SetWidgetVisible(widget.TextBlockKill, true)
  if not bIsHVH then
    return
  end
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  local isWinState = data.win_state
  local bIsHunter = data.camp_type == history_combat_cfg.EHvHCampType.Hunter
  data.person_rank = 2
  local imageIndex = bIsHunter and 0 or 1
  widget.WidgetSwitcher_CampStatus:SetActiveWidgetIndex(isWinState)
  self:SetTexture(widget.Image_Camp1, HunterVsHunterCompIcon[imageIndex])
  self:SetTexture(widget.Image_Camp2, HunterVsHunterCompIcon[imageIndex])
  self:SetTexture(widget.Image_camp3, HunterVsHunterCompIcon[imageIndex])
  widget.WidgetSwitcher_individualRank:SetActiveWidgetIndex(isWinState ~= 0 and 2 or 1)
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  local state_str = history_combat_util.GetHvHSettlementStr(data.person_state)
  widget.TextBlock_hvhWinText:SetText(state_str)
  widget.TextBlock_hvhLoseText:SetText(state_str)
  if bIsHunter then
    widget.TextBlockKill:SetText(data.kill)
  else
    widget.TextBlockKill:SetText("--")
  end
  if data.is_escape == 1 then
    self:SetTexture(widget.Image_8, "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/JS_icon_taobao_png.JS_icon_taobao_png")
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(3)
  else
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(6)
  end
  widget.TextBlock_Rank:SetText(data.behavior_score)
  self:SetWidgetVisible(widget.ImageMvpIcon, data.is_mvp)
  widget.TextBlockRating:SetText(data.rating)
  widget.TextBlockChangeRating:SetText(data.change_rating)
end
function RoleInfoHistoryUI:SetPromotion(widget, data, index)
  log_tree(bWriteLog and "RoleInfoHistoryUI:SetPromotion promotion_data: ", {
    data.is_promotion_win,
    data.cur_lock_index,
    data.promotion_progress,
    data.target_promo_progress,
    data.promotion_protect,
    data.unlocked_mode_promo_rating,
    data.is_unlocked_promo_mode,
    data.normal_add_promo_rating,
    data.unlocked_mode_total_rating
  })
  self:SetWidgetVisible(widget.HorizontalBox_Promotion, false)
  self:SetWidgetVisible(widget.CanvasPanel_PromotionWarn, false)
  self:SetWidgetVisible(widget.CanvasPanel_29, false)
  self:SetWidgetVisible(widget.CanvasPanel_PromotionTip, false)
  self:SetWidgetVisible(widget.WidgetSwitcher_4, false)
  self:SetWidgetVisible(widget.WidgetSwitcher_4, true)
  widget.WidgetSwitcher_4:SetActiveWidgetIndex(0)
  if data.is_promotion_win then
    self:SetWidgetVisible(widget.HorizontalBox_Promotion, true)
    widget.WidgetSwitcher_PromotionState:SetActiveWidgetIndex(data.is_promotion_win == 1 and 0 or 1)
    widget.TextBlock_Promotion:SetText(LocUtil.LocalizeResFormat(805872, data.promotion_progress, data.target_promo_progress))
    self:SetWidgetVisible(widget.CanvasPanel_PromotionProtect, data.promotion_protect == 1)
    local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
    local promotion_cfgs = logic_promotion_homepage.promotion_base_config or {}
    local promotion_cfg = promotion_cfgs[data.cur_lock_index]
    local IsNoPromoRating = logic_promotion_homepage.IsNoPromoRating(data.season_id)
    if IsNoPromoRating then
      widget.WidgetSwitcher_4:SetActiveWidgetIndex(0)
      self:SetWidgetVisible(widget.TextBlockChangeRating, true)
      local rating_text = ""
      if data.is_unlocked_promo_mode == 0 then
        self:SetWidgetVisible(widget.CanvasPanel_29, true)
        if data.max_rating_mode_change_rating and 0 > data.max_rating_mode_change_rating then
          rating_text = string.format("(%d)", data.max_rating_mode_change_rating)
        elseif data.max_rating_mode_change_rating and 0 < data.max_rating_mode_change_rating then
          rating_text = string.format("(+%d)", data.max_rating_mode_change_rating)
        elseif data.promotion_protect == 1 then
          rating_text = string.format("(+%d)", 0)
        elseif not promotion_cfg or tonumber(data.rating) ~= promotion_cfg.max_soft_rank_rating then
          rating_text = string.format("(+%d)", 0)
        else
          data.change_rating = ""
          self:SetWidgetVisible(widget.CanvasPanel_29, false)
        end
      else
        self:SetWidgetVisible(widget.CanvasPanel_29, false)
        rating_text = tostring(data.change_rating)
      end
      if rating_text == "" and promotion_cfg and tonumber(data.rating) == promotion_cfg.max_soft_rank_rating then
        rating_text = string.format("(+%d)", 0)
        self:SetWidgetVisible(widget.CanvasPanel_PromotionWarn, true)
      end
      widget.TextBlockChangeRating:SetText(rating_text)
    elseif data.is_unlocked_promo_mode == 0 then
      widget.WidgetSwitcher_4:SetActiveWidgetIndex(1)
      local rating_text
      if data.unlocked_mode_total_rating and data.unlocked_mode_total_rating < 0 then
        rating_text = string.format("(%d)", data.unlocked_mode_total_rating)
      elseif data.unlocked_mode_total_rating and data.unlocked_mode_total_rating > 0 then
        rating_text = string.format("(+%d)", data.unlocked_mode_total_rating)
      else
        rating_text = string.format("(+%d)", 0)
      end
      widget.TextBlock_7:SetText(rating_text)
      local oldSeasonId = 47
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsBLUEHOLE() then
        oldSeasonId = 46
      end
      if oldSeasonId < DataMgr.season_id and (not data.cur_unlocked_mode or data.cur_unlocked_mode == 0) then
        self:SetWidgetVisible(widget.CanvasPanel_PromotionWarn, false)
      else
        self:SetWidgetVisible(widget.CanvasPanel_PromotionWarn, true)
      end
    elseif data.is_unlocked_promo_mode == 1 then
      widget.WidgetSwitcher_4:SetActiveWidgetIndex(0)
      self:SetWidgetVisible(widget.TextBlockChangeRating, true)
      local rating_text = data.change_rating
      if data.change_rating == "" and promotion_cfg and tonumber(data.rating) == promotion_cfg.max_soft_rank_rating then
        rating_text = string.format("(+%d)", 0)
        self:SetWidgetVisible(widget.CanvasPanel_PromotionWarn, true)
      end
      widget.TextBlockChangeRating:SetText(rating_text)
    end
  elseif data.is_classic_mode then
    if data.normal_add_promo_rating and data.normal_add_promo_rating ~= 0 then
      self:SetWidgetVisible(widget.CanvasPanel_PromotionTip, true)
      if self.hasAutoShowPromotionTip == false and index <= self.C_AutoShowPromotionTipCount then
        self.hasAutoShowPromotionTip = true
        self:AddTimerOnce(0.1, function()
          local TipsParam = {
            widget = widget.Button_PromotionTip,
            content = LocUtil.GetLocalizeResStr(85147)
          }
          local tip_ui = UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
          if tip_ui and slua.isValid(tip_ui.UIRoot) then
            self:AddTimerOnce(self.C_AutoShowPromotionTipTime, function()
              if tip_ui and slua.isValid(tip_ui.UIRoot) then
                tip_ui:CloseSelf()
              end
            end)
          end
        end)
      end
    end
    local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
    if data.change_rating == "" and logic_promotion_homepage:IsOpen() then
      local promotion_cfgs = logic_promotion_homepage.promotion_base_config or {}
      for promotion_id, promotion_cfg in ipairs(promotion_cfgs) do
        if tonumber(data.rating) == promotion_cfg.max_soft_rank_rating and data.segment <= promotion_cfg.pre_promo_level then
          widget.TextBlockChangeRating:SetText(string.format("(+%d)", 0))
          self:SetWidgetVisible(widget.CanvasPanel_PromotionWarn, true)
          self:SetWidgetVisible(widget.TextBlockChangeRating, true)
          widget.WidgetSwitcher_4:SetActiveWidgetIndex(0)
          break
        end
      end
    end
  end
end
function RoleInfoHistoryUI:OnShowTips(widget, index)
  self.  local data = self.ScrollBox:GetItemData(index)
  local iconAndText = self.logic_roleinfo_history.GetRatingIconText(data, data.raw_battle_type)
  if iconAndText then
    self:PlayAudio(sound_config.click_v1)
    widget.CanvasPanel_10:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.CanvasPanel_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.UTRichTextBlock_ProtectTips:SetText(iconAndText)
    EventSystem:postEvent(EVENTTYPE_CLICK, EVENTID_ICON_SHOW)
  end
end
function RoleInfoHistoryUI:OnClickButtonLimit(widget, index)
  log(bWriteLog and "RoleInfoHistoryUI:OnClickButtonLimit")
  self:PlayAudio(sound_config.click_v1)
  self.  widget.CanvasPanel_10:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.CanvasPanel_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.UTRichTextBlock_ProtectTips:SetText(LocUtil.GetLocalizeResStr(68428))
  EventSystem:postEvent(EVENTTYPE_CLICK, EVENTID_ICON_SHOW)
end
function RoleInfoHistoryUI:OnClickButtonPromotionWarn(widget, index)
  log(bWriteLog and "RoleInfoHistoryUI:OnClickButtonPromotionWarn")
  self:PlayAudio(sound_config.click_v1)
  local data = self.ScrollBox:GetItemData(index)
  if not data then
    return
  end
  local content = ""
  local promo_cache = ""
  local buttonWidget = widget.Button_PromotionWarn
  if data.is_promotion_win then
    local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
    local IsNoPromoRating = logic_promotion_homepage.IsNoPromoRating(data.season_id)
    if IsNoPromoRating and data.is_unlocked_promo_mode == 0 then
      if data.change_rating == "" and (not data.max_rating_mode_change_rating or data.max_rating_mode_change_rating == 0) then
        content = LocUtil.GetLocalizeResStr(85127)
      else
        local ModeNameConfig = require("client.logic.season.promotion_match.config.promotion_config").ModeNameConfig
        local config = ModeNameConfig[data.promo_result_max_rating_mode]
        local modeStr = ""
        if config then
          modeStr = string.format("%s-%s", LocUtil.GetLocalizeResStr(config.ModeId), LocUtil.GetLocalizeResStr(config.NumId))
        end
        content = LocUtil.LocalizeResFormat(85399, modeStr)
        buttonWidget = widget.Button_2
      end
    elseif data.is_unlocked_promo_mode == 0 then
      local ModeNameConfig = require("client.logic.season.promotion_match.config.promotion_config").ModeNameConfig
      local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
      local promotion_data = promotion_match_util.GetPromotionData()
      local unlocked_mode = promotion_data.locked_info[data.cur_lock_index].unlocked_mode
      local oldSeasonId = 47
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsBLUEHOLE() then
        oldSeasonId = 46
      end
      if oldSeasonId < DataMgr.season_id and (not data.cur_unlocked_mode or data.cur_unlocked_mode == 0) then
      else
        unlocked_mode = data.cur_unlocked_mode
      end
      local config = ModeNameConfig[unlocked_mode]
      local modeStr = ""
      if config then
        modeStr = string.format("%s-%s", LocUtil.GetLocalizeResStr(config.ModeId), LocUtil.GetLocalizeResStr(config.NumId))
      end
      content = LocUtil.LocalizeResFormat(805899, modeStr)
      local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
      local is_max_promo_open = logic_promotion_homepage.IsMaxPromoOpen(data.season_id)
      local promotion_base_config = logic_promotion_homepage.promotion_base_config and logic_promotion_homepage.promotion_base_config[data.cur_lock_index]
      if is_max_promo_open and promotion_base_config and promotion_base_config.max_promo_result_rating_cnt then
        promo_cache = LocUtil.LocalizeResFormat(85386, data.unlocked_mode_total_rating, promotion_base_config.max_promo_result_rating_cnt)
      end
    elseif data.is_unlocked_promo_mode == 1 and data.change_rating == "" then
      content = LocUtil.GetLocalizeResStr(85127)
    end
  elseif data.change_rating == "" then
    content = LocUtil.GetLocalizeResStr(85127)
  end
  local TipsParam = {
    widget = buttonWidget,
    content = content,
      }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function RoleInfoHistoryUI:OnClickButtonPromotionTip(widget, index)
  log(bWriteLog and "RoleInfoHistoryUI:OnClickButtonPromotionTip")
  self:PlayAudio(sound_config.click_v1)
  local TipsParam = {
    widget = widget.Button_PromotionTip,
    content = LocUtil.GetLocalizeResStr(85147)
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function RoleInfoHistoryUI:OnShowRecord(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local data = self.ScrollBox:GetItemData(index)
  if not data then
    return
  end
  if data.is_invalid then
    ShowNotice(8500429)
    return
  end
  local battle_id = data.battle_id or 0
  if data.is_txMission and data.compatibility_flag and data.compatibility_flag == 1 and not FuncUtil.IsXmissionTeamMode(data.raw_battle_type) then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if not LogicTxMissionMain.MountXMissionPak() then
      ShowNotice(32557)
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Xmission_History_Detail_UIBP, tonumber(self.uid), tonumber(battle_id), data.timestamp)
    return
  end
  self.logic_roleinfo_history.SetRecordBattleId(tonumber(battle_id))
  local tData = self.logic_roleinfo_history.role_history_record[tonumber(battle_id)]
  if tData and tData.uid and tonumber(tData.uid) ~= tonumber(self.uid) then
    self.logic_roleinfo_history.role_history_record[tonumber(battle_id)] = nil
    tData = nil
  end
  if tData then
    self.logic_roleinfo_history.ShowRecord(tData)
  else
    self.logic_roleinfo_history.ReqRecord(tonumber(battle_id))
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PersonSpaceCombatDetail)
end
function RoleInfoHistoryUI:OnClickReplay(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local data = self.ScrollBox:GetItemData(index)
  self.logic_roleinfo_history.UpdateShowGlowSaveData(data.battle_id, data.timestamp)
  self.ScrollBox:RefreshItem(index)
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  local file_name = logic_share_replay.GetJsonFileByBattleId(data.battle_id)
  if not file_name then
    return
  end
  local replay_file_name = logic_replay.GetReplayFileByInfoFile(file_name)
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  logic_share_replay.ShowPlayReplayPopUI(replay_macro.TLOG.Sub_Scene.HISTORY, file_name, replay_file_name, nil, data.battle_id)
  local ShareHandler = require("client.network.Protocol.ShareHandler")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ClickWonderfulRePlayWindow, 3, tostring(data.battle_id), true)
end
function RoleInfoHistoryUI:OnClickGustTips()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.AccessRestriction)
end
function RoleInfoHistoryUI:OnClickButtonClose()
  self:PlayAudio(sound_config.click_v1)
  self:PlayUserWidgetAnimation(self.UIRoot.out, 0, 1, 0, 1)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CRoleInfoHistoryUI = class(ui_base, nil, RoleInfoHistoryUI)
return CRoleInfoHistoryUI