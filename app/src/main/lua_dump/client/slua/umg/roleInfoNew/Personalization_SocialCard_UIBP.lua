local Personalization_SocialCard_UIBP = {C_Currency_ID = 1703266}
function Personalization_SocialCard_UIBP:ctor(_, selectItemId, type)
  self.select = 0
  self.currency = 0
  self.needRefreshCurItem = false
end
function Personalization_SocialCard_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_SocialCard_UIBP:InitCommonAvatarComp()
  Personalization_SocialCard_UIBP.__super.InitCommonAvatarComp(self)
  self.nameText = self.UIRoot.TextBlock_Name
  self.nationImageComp = self.UIRoot.Image_27
  self.smallAvatar = self.UIRoot.Common_Avatar_BP_C_0
  self.rankLevelComp = self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP_C_1
  self.sexComp = self.UIRoot.Common_Gender_UIBP_C_2
end
function Personalization_SocialCard_UIBP:RegistEvents()
  Personalization_SocialCard_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_SOCIAL_CARD_UPDATE, self.UpdateAll, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.UpdateCurrencyCount, self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_3, self.OnButtonCurrency, self)
  end
end
function Personalization_SocialCard_UIBP:OnPostInitialize()
  Personalization_SocialCard_UIBP.__super.OnPostInitialize(self)
  self:InitCurrency()
  self:UpdateAll()
end
function Personalization_SocialCard_UIBP:OnShow()
  Personalization_SocialCard_UIBP.__super.OnShow(self)
  self.jumpSelectItemId = nil
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_3, true, true)
  end
end
function Personalization_SocialCard_UIBP:OnHide()
  Personalization_SocialCard_UIBP.__super.OnHide(self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_3, false, true)
  end
end
function Personalization_SocialCard_UIBP:InitCurrency()
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    local currency_cfg = CDataTable.GetTableData("Item", self.C_Currency_ID)
    roleinfo_main:SetTexture(roleinfo_main.UIRoot.Image_3, currency_cfg.ItemSmallIcon, {sync = true})
  end
end
function Personalization_SocialCard_UIBP:UpdateItemReddot(item_data, index)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  if logic_social_card_bg:HasRedDotByID(item_data.ID) then
    logic_social_card_bg:ReadRedDot(item_data.ID)
  end
end
function Personalization_SocialCard_UIBP:HandleClickedItem(widget, index)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  local itemData = self.ItemGrid:GetItemData(index)
  if itemData.SubList then
    self.select = 1
    for _, v in ipairs(itemData.SubList) do
      if logic_social_card_bg:IsHaveCardSkin(v.ID) then
        self.select = v.Level
      end
      if v.ID == logic_social_card_bg:GetCurrentSocialCardBGID() then
        break
      end
    end
  end
  return nil
end
function Personalization_SocialCard_UIBP:HandleButtonUse()
  log(bWriteLog and "[SocialCard] click equip")
  local item_data = self.ItemGrid:GetItemData(self.ItemGrid:GetSelectIndex())
  if item_data.SubList then
    item_data = item_data.SubList[self.curSelectItemData]
  end
  if not item_data then
    log(bWriteLog and "[SocialCard] nil item data: " .. tostring(self.ItemGrid:GetSelectIndex()))
    return
  end
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  logic_social_card_bg:send_set_social_card_floor_req(item_data.ID)
end
function Personalization_SocialCard_UIBP:HandleButtonUnload()
  log(bWriteLog and "[SocialCard] click unequip")
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  logic_social_card_bg:send_set_social_card_floor_req(logic_social_card_bg:GetDefaultSocialCardBGID())
end
function Personalization_SocialCard_UIBP:HandleButtonGo()
  log(bWriteLog and "[SocialCard] click equip")
  local item_data = self.ItemGrid:GetItemData(self.ItemGrid:GetSelectIndex())
  if item_data.SubList then
    item_data = item_data.SubList[self.curSelectItemData]
  end
  if not item_data then
    log(bWriteLog and "[SocialCard] nil item data: " .. tostring(self.ItemGrid:GetSelectIndex()))
    return
  end
  if item_data.AcquiSitionMethodLink and item_data.AcquiSitionMethodLink ~= "" then
    local RoleInfoBigAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
    if RoleInfoBigAvatarSystem.IsShow() then
      RoleInfoBigAvatarSystem.CloseUI()
    end
    local moduleNumber = string.match(item_data.AcquiSitionMethodLink, "module=(%d+)")
    if tonumber(moduleNumber) == BP_ENUM_MODULE_CORPS then
      GlobalData.JumpUrl(item_data.AcquiSitionMethodLink .. "&extra=" .. item_data.ID)
    else
      GlobalData.JumpUrl(item_data.AcquiSitionMethodLink)
    end
  end
end
function Personalization_SocialCard_UIBP:HandleLockedButton1()
  log(bWriteLog and "Personalization_SocialCard_UIBP:HandleLockedButton1")
  self.select = 1
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_SocialCard_UIBP:HandleLockedButton2()
  log(bWriteLog and "Personalization_SocialCard_UIBP:HandleLockedButton2")
  self.select = 2
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_SocialCard_UIBP:HandleLockedButton3()
  log(bWriteLog and "Personalization_SocialCard_UIBP:HandleLockedButton3")
  self.select = 3
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_SocialCard_UIBP:HandleButtonUpgrade()
  log(bWriteLog and "Personalization_SocialCard_UIBP:HandleButtonUpgrade")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local curSelect = self.select
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItemData.ID)
  local needCurrency = upgradeCfg.Cost
  local sMsg = LocUtil.LocalizeResFormat(18010241, needCurrency, needItemData.SocialCardBGName)
  local sTitle = LocUtil.GetLocalizeResStr(39012)
  local fClickOkCallback = function()
    local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
    self:AddPromise(PopularityPKHandler.send_psmatch_reward_upgrade_req(needItemData.ID)):Then(function(err_code, _, upgrade_item_id)
      if err_code == 0 then
        local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
        logic_social_card_bg:send_set_social_card_floor_req(upgrade_item_id)
        self.select = curSelect
        self:UpdateItemPreview(itemData)
        ShowNotice(665020)
      else
      end
    end)
  end
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sMsg, fClickOkCallback)
end
function Personalization_SocialCard_UIBP:HandleButtonNoUpgrade()
  log(bWriteLog and "Personalization_SocialCard_UIBP:HandleButtonNoUpgrade")
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  if not logic_social_card_bg:IsHaveCardSkin(needItemData.ID) then
    ShowNotice(18010243)
  else
    ShowNotice(18010242)
  end
end
function Personalization_SocialCard_UIBP:GetItemList()
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  self.CardFrameList = logic_social_card_bg:GetSocialCardBGList()
  if not self.CardFrameList then
    log(bWriteLog and "[SocialCard] nil carte frame list")
    return
  end
  local table_util = require("common.table_util")
  local i = 1
  while i <= #self.CardFrameList do
    if self.CardFrameList[i].Type and self.CardFrameList[i].Type ~= 0 then
      local itemList = {}
      local type = self.CardFrameList[i].Type
      local j = i
      while j <= #self.CardFrameList do
        if self.CardFrameList[j].Type == type then
          table.insert(itemList, table_util.CopyTable(self.CardFrameList[j]))
          table.remove(self.CardFrameList, j)
        else
          j = j + 1
        end
      end
      table.sort(itemList, function(l, r)
        return l.Level < r.Level
      end)
      local item = table_util.CopyTable(itemList[1])
      item.SubList = itemList
      table.insert(self.CardFrameList, i, item)
    end
    i = i + 1
  end
  local list = self.CardFrameList
  if self.isCheckOwned then
    local DefaultSkinID = logic_social_card_bg:GetDefaultSocialCardBGID()
    list = {}
    for _, v in ipairs(self.CardFrameList) do
      if v.ID == DefaultSkinID or logic_social_card_bg:IsHaveCardSkin(v.ID) then
        table.insert(list, v)
      end
    end
  end
  return list
end
function Personalization_SocialCard_UIBP:UpdateAll()
  self:RefreshItemGrid(1)
  self:UpdateCurrencyCount()
end
function Personalization_SocialCard_UIBP:UpdateCurrencyCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local num = wardrobe_data:GetHallDepotItemCountByResID(self.C_Currency_ID)
  self.currency = num
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main.UIRoot.TextBlock_0:SetText(num)
  end
end
function Personalization_SocialCard_UIBP:GetDescTitleInfo()
  return LocUtil.GetLocalizeResStr(9502), LocUtil.GetLocalizeResStr(45867)
end
function Personalization_SocialCard_UIBP:OnTitleTabChanged(titleTab)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(titleTab)
end
function Personalization_SocialCard_UIBP:UpdatePlayerInfo()
  local profile = Personalization_SocialCard_UIBP.__super.UpdatePlayerInfo(self)
  if profile then
    self.UIRoot.Common_Avatar_BP_C_144:InitView(1, profile.uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
    self.UIRoot.Common_Avatar_BP_C_144:SetButtonEnabled(false)
    self.UIRoot.TextBlock_PlayerID:SetText(profile.uid)
    self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP_C_0:SetRankInteral(profile.cur_max_segment_level or 101)
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local corps_summary = LobbySocialSystem.CacheCorpsSummary[profile.corps_id] or nil
    self.UIRoot.UTRichTextBlock_Invite:SetText(corps_summary and corps_summary.name or LocUtil.GetLocalizeResStr(5085))
    self:SetWidgetVisible(self.UIRoot.Image_11, corps_summary ~= nil and corps_summary.name ~= nil)
    self.UIRoot.TextBlock_PlayerName:SetText(profile.nickName or "")
    self:HandleNationFlag(self.UIRoot.Image_Nation, profile.nation)
  end
  return profile
end
function Personalization_SocialCard_UIBP:UpdateSelectedItemInfo(item_data)
  if not item_data then
    log(bWriteLog and "[SocialCard] nil item data for right display")
    return
  end
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  local CurSelectID = logic_social_card_bg:GetCurrentSocialCardBGID()
  local DefaultSkinID = logic_social_card_bg:GetDefaultSocialCardBGID()
  local param = self:GenCommonItemParam()
  if item_data.SubList then
    param.lockedButtonStyle = self:GetLockedButtonStyleTable(item_data.SubList)
    param.lockedButtonStyle.select = self.select
    param.itemDataList = item_data.SubList
    param.selectItemData = self.select
    item_data = item_data.SubList[self.select]
  end
  param.itemID = item_data.ID
  local item_config = CDataTable.GetTableData("SocialCardBGInfo", item_data.ID)
  if item_config then
    param.name = item_config.SocialCardBGName
    param.extraInfo = LocUtil.LocalizeResFormat(item_data.AcquiSitionMethod)
  else
    log(bWriteLog and "[SocialCard] nil item config: " .. tostring(item_data.ID))
  end
  self:UpdateSocialCardPanel(item_data)
  self:UpdateChatPanel(item_data, CurSelectID, DefaultSkinID, logic_social_card_bg)
  param.expireTime = logic_social_card_bg:GetCardSkinTime(item_data.ID)
  if item_data.ID == DefaultSkinID then
    param.expireTime = 0
    if CurSelectID ~= DefaultSkinID then
      param.buttonStyle = ENUM_Button_Style.Use
    else
      param.buttonStyle = ENUM_Button_Style.None
    end
  else
    local isHave = logic_social_card_bg:IsHaveCardSkin(item_data.ID)
    if isHave then
      if item_data.ID == CurSelectID then
        param.buttonStyle = ENUM_Button_Style.Unload
      else
        param.buttonStyle = ENUM_Button_Style.Use
      end
    elseif param.itemDataList and param.selectItemData > 1 and logic_social_card_bg:IsHaveCardSkin(param.itemDataList[1].ID) then
      local needItem = param.itemDataList[param.selectItemData - 1]
      local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItem.ID)
      local needCurrency = upgradeCfg.Cost
      local locString = LocUtil.LocalizeResFormat(18010254, needCurrency)
      if logic_social_card_bg:IsHaveCardSkin(needItem.ID) and needCurrency <= self.currency then
        param.buttonStyle = ENUM_Button_Style.Upgrade
        self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_1:SetText(locString)
      else
        param.buttonStyle = ENUM_Button_Style.NoUpgrade
        self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_2:SetText(locString)
      end
    elseif item_data.AcquiSitionMethodLink and item_data.AcquiSitionMethodLink ~= "" then
      param.buttonStyle = ENUM_Button_Style.Go
    else
      param.buttonStyle = ENUM_Button_Style.None
    end
  end
  if item_data then
    self:UpdateItemReddot(item_data)
  end
  return param
end
function Personalization_SocialCard_UIBP:UpdateSocialCardPanel(item_data)
  local canLoop = item_data.CanLoop and "Auto_Loop"
  local effect_bp_path = item_data.PersonInfoBGUMG
  local extraData = {}
  if item_data.Level == 1 then
  end
  if item_data.Level == 3 then
    extraData.bEnableGyroscope = true
  end
  if item_data.ID == 61200100 then
    canLoop = nil
  end
  self:AddEffectSkinByCreateChildWindow(effect_bp_path, "CanvasPanel_BG", canLoop, extraData)
end
function Personalization_SocialCard_UIBP:UpdateChatPanel(item_data, CurSelectID, DefaultSkinID, logic_social_card_bg)
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
  if item_data.ID == DefaultSkinID then
    self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(1)
    local canLoop = item_data.CanLoop and "Auto_Loop"
    local effect_bp_path = item_data.MainUMG
    local extraData = {}
    if item_data.Level == 1 then
    end
    if item_data.Level == 3 then
      extraData.bEnableGyroscope = true
    end
    local child = self:AddEffectSkinByCreateChildWindow(effect_bp_path, "GridPanel_0", canLoop, extraData)
    self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(child ~= nil and 1 or 0)
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  local bBlock = SocialCardSystem.CheckBlockNewData()
  local profile = LobbySocialSystem.GetProfileByUID(DataMgr.roleData.uid)
  local social_card = profile.social_card
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Sound, true)
  self:SetWidgetVisible(self.UIRoot.TextBlock_6, false)
  self.UIRoot.TextBlock_Sound_Title:SetText(LocUtil.LocalizeResFormat(45878))
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Voice, not bBlock)
  self.UIRoot.TextBlock_Voice_Title:SetText(LocUtil.LocalizeResFormat(45913))
  local voice = social_card.voice_state or "--"
  if voice and type(voice) == "number" then
    voice = SocialCardSystem.GetVoiceValue(voice)
  end
  self.UIRoot.TextBlock_Voice:SetText(voice)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Mode, not bBlock)
  self.UIRoot.TextBlock_Mode_Title:SetText(LocUtil.LocalizeResFormat(45914))
  local mode = SocialCardSystem.GetFormatData(social_card.expert_mode, SocialCardSystem.GetModeValue)
  self.UIRoot.TextBlock_Mode:SetText(mode)
  local cardTagList = SocialCardSystem.UnifyCardData(social_card)
  if cardTagList and next(cardTagList) then
    for index, value in pairs(cardTagList) do
      if value then
        self.UIRoot["TextBlock_Label" .. tostring(index)]:SetText(value)
        self:SetWidgetVisible(self.UIRoot["TextBlock_Label" .. tostring(index)], true)
        if self.UIRoot["Image_Line" .. tostring(index - 1)] then
          self:SetWidgetVisible(self.UIRoot["Image_Line" .. tostring(index - 1)], true)
        end
      end
    end
  else
    self:SetWidgetVisible(self.UIRoot.TextBlock_Label1, true)
    self.UIRoot.TextBlock_Label1:SetText("--")
    self:SetWidgetVisible(self.UIRoot.TextBlock_Label2, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_Label3, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_Label4, false)
    self:SetWidgetVisible(self.UIRoot.Image_Line1, false)
    self:SetWidgetVisible(self.UIRoot.Image_Line2, false)
    self:SetWidgetVisible(self.UIRoot.Image_Line3, false)
  end
end
function Personalization_SocialCard_UIBP:OnRefreshGridItem(widget, index)
  if not widget then
    log(bWriteLog and "[SocialCard] nil widget for index: " .. tostring(index))
    return
  end
  local item_data = self.ItemGrid:GetItemData(index)
  if not item_data then
    log(bWriteLog and "[SocialCard] nil item data for index: " .. tostring(index))
    return
  end
  local effect_bp = item_data.MainUMG
  local child = self:AddEffectSkinByCreateChildWindow(effect_bp, widget.CanvasPanel_Effect, item_data.CanLoop and "Auto_Loop" or nil)
  widget.WidgetSwitcher_1:SetActiveWidgetIndex(child ~= nil and 1 or 0)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  self:SetWidgetVisible(widget.Image_Select, index == self.ItemGrid:GetSelectIndex())
  local haveRed = logic_social_card_bg:HasRedDotByID(item_data.ID)
  if item_data.SubList then
    for _, v in ipairs(item_data.SubList) do
      if logic_social_card_bg:HasRedDotByID(v.ID) then
        haveRed = true
      end
    end
  end
  self:SetWidgetVisible(widget.Image_Reddot, haveRed)
  self:ToolIsUsing(widget, item_data)
  local showTime = logic_social_card_bg:GetCardSkinTime(item_data.ID)
  if type(showTime) == "string" then
    self:SetWidgetVisible(widget.Image_LimitedTime, showTime ~= "")
  else
    self:SetWidgetVisible(widget.Image_LimitedTime, showTime and 1 < showTime)
  end
end
function Personalization_SocialCard_UIBP:ToolIsUsing(widget, item_data)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  self:SetWidgetVisible(widget.WidgetSwitcher_0, true)
  local isCurrentID = logic_social_card_bg:IsCurrentSocialCardBGID(item_data.ID)
  if item_data.SubList then
    for _, v in ipairs(item_data.SubList) do
      if logic_social_card_bg:IsCurrentSocialCardBGID(v.ID) then
        isCurrentID = true
      end
    end
  end
  if isCurrentID then
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    local isDefaultID = logic_social_card_bg:IsDefaultSocialCardBGID(item_data.ID)
    if not isDefaultID then
      local isHave = logic_social_card_bg:IsHaveCardSkin(item_data.ID)
      self:SetWidgetVisible(widget.WidgetSwitcher_0, not isHave)
      self:SetWidgetVisible(widget.Image_Mask, not isHave)
    else
      self:SetWidgetVisible(widget.WidgetSwitcher_0, false)
      self:SetWidgetVisible(widget.Image_Mask, false)
    end
  end
end
function Personalization_SocialCard_UIBP:OnButtonCurrency()
  self:PlayAudio(sound_config.click_v1)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    local itemCfg = CDataTable.GetTableData("Item", self.C_Currency_ID) or {}
    UIManager.ShowUI(UIManager.UI_Config.ItemUp_Mat_Tips_UIBP, itemCfg, nil, {
      widget = roleinfo_main.UIRoot.Button_3,
      customOffset = {X = -120, Y = 50}
    })
  end
end
function Personalization_SocialCard_UIBP:GetLockedButtonStyleTable(itemDataList)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  local lockedButtonStyle = {
    bShow = false,
    button1 = {bShow = false, hasLock = true},
    button2 = {bShow = false, hasLock = true},
    button3 = {bShow = false, hasLock = true}
  }
  if itemDataList then
    lockedButtonStyle.bShow = true
    for _, v in ipairs(itemDataList) do
      local buttonName = "button" .. v.Level
      lockedButtonStyle[buttonName].bShow = true
      if logic_social_card_bg:IsHaveCardSkin(v.ID) then
        lockedButtonStyle[buttonName].hasLock = false
      end
      lockedButtonStyle[buttonName].text = LocUtil.GetLocalizeResStr(18010254 + v.Level)
    end
  end
  return lockedButtonStyle
end
function Personalization_SocialCard_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData) or not itemData.ID then
    return false
  end
  return itemData.ID == self.jumpSelectItemId
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CRolelnfo_Social_Card_Popup_UIBP = class(ui_base, nil, Personalization_SocialCard_UIBP)
return CRolelnfo_Social_Card_Popup_UIBP