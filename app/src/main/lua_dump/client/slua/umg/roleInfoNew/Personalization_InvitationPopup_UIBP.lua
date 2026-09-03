local Personalization_InvitationPopup_UIBP = {C_Currency_ID = 1703266}
local defaultSkinId = 61010001
function Personalization_InvitationPopup_UIBP:ctor(_, _, SelectedIdx)
  log(bWriteLog and "Personalization_InvitationPopup_UIBP:ctor SelectedIdx = " .. tostring(SelectedIdx))
  self.dataList = {}
  self.baseItemSelectIndex = SelectedIdx or 1
  self.select = 0
  self.currency = 0
  self.isShowSkin = false
end
function Personalization_InvitationPopup_UIBP:OnInitialize()
  Personalization_InvitationPopup_UIBP.__super.OnInitialize(self)
  self.UIRoot.UTRichTextBlock_MapName:SetText(LocUtil.GetLocalizeResStr(500052))
  self.UIRoot.UTRichTextBlock_Invite:SetText(LocUtil.GetLocalizeResStr(110028))
  self:InitCurrency()
end
function Personalization_InvitationPopup_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_InvitationPopup_UIBP:InitCommonAvatarComp()
  Personalization_InvitationPopup_UIBP.__super.InitCommonAvatarComp(self)
  self.smallAvatar = self.UIRoot.Common_Avatar_BP_C_144
  self.rankLevelComp = self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP_C_0
  self.nationImageComp = self.UIRoot.Image_Nation
  self.nameText = self.UIRoot.TextBlock_PlayerName
end
function Personalization_InvitationPopup_UIBP:RegistEvents()
  Personalization_InvitationPopup_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHANGE_TEAMUPFRAME, self.OnTeamUpFrameChange, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_TEAMUPFRAME, self.OnTeamUpFrameUpdate, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.UpdateCurrencyCount, self)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main:AddOnClickedEventByControl(roleInfo_main.UIRoot.Button_3, self.OnButtonCurrency, self)
  end
end
function Personalization_InvitationPopup_UIBP:OnPostInitialize()
  Personalization_InvitationPopup_UIBP.__super.OnPostInitialize(self)
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  logic_roleInfo_TeamUpFrame:send_get_team_notify_skin_list()
  self:InitData()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  log(bWriteLog and "tlog_report_utils.ReportTLogEvent id = " .. tostring(TLogEventDefine.TeamUpFrameUIShow))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.TeamUpFrameUIShow)
end
function Personalization_InvitationPopup_UIBP:OnShow()
  Personalization_InvitationPopup_UIBP.__super.OnShow(self)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main:SetWidgetVisible(roleInfo_main.UIRoot.Button_3, true, true)
  end
  self:UpdateCurrencyCount()
end
function Personalization_InvitationPopup_UIBP.OnHide()
  Personalization_InvitationPopup_UIBP.__super.OnHide(self)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main:SetWidgetVisible(roleInfo_main.UIRoot.Button_3, false, true)
  end
end
function Personalization_InvitationPopup_UIBP:HandleClickedItem(widget, index)
  local data = self.ItemGrid:GetItemData(index)
  if not data then
    log(bWriteLog and "Personalization_InvitationPopup_UIBP:HandleClickedItem. data is nil")
    return
  elseif data.SubList then
    self.select = 1
    for _, v in ipairs(data.SubList) do
      if v.bIsUse then
        self.select = v.cfg.level
      end
    end
  end
end
function Personalization_InvitationPopup_UIBP:OnRefreshGridItem(widget, index)
  local data = self.ItemGrid:GetItemData(index)
  if data.cfg.DynamicIconPath ~= "" then
    self:AddEffectSkinByCreateChildWindow(data.cfg.DynamicIconPath, widget.DynamicBG_Root, "Auto_Loop")
    self:SetWidgetVisible(widget.Image_Frame, false)
    self:SetWidgetVisible(widget.DynamicBG_Root, true)
  else
    self:SetWidgetVisible(widget.DynamicBG_Root, false)
    if data.cfg.Skin ~= "" then
      self:SetWidgetVisible(widget.Image_Frame, true)
      self:SetTexture(widget.Image_Frame, data.cfg.Skin)
    else
      self:SetWidgetVisible(widget.Image_Frame, false)
    end
  end
  if data.cfg.Skin ~= "" then
    self:SetWidgetVisible(widget.Image_Frame, true)
    self:SetTexture(widget.Image_Frame, data.cfg.Skin)
  else
    self:SetWidgetVisible(widget.Image_Frame, false)
  end
  self:SetWidgetVisible(widget.Image_Select, index == self.baseItemSelectIndex)
  self:SetWidgetVisible(widget.CanvasPanel_Lock, data.bIsLock)
  self:SetWidgetVisible(widget.Image_Mask, data.bIsLock)
  if data.bIsLock then
    local lockOpacity = FLinearColor(1, 1, 1, 0.7)
    widget.Image_Lock:SetColorAndOpacity(lockOpacity)
  end
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  self:SetWidgetVisible(widget.Image_Using, logic_roleInfo_TeamUpFrame:IsUsing(data))
  self:SetWidgetVisible(widget.Image_Reddot, logic_roleInfo_TeamUpFrame:IsReddot(data))
  local isExpireItem = false
  if not data.bIsLock and data.expireTime and 1 < data.expireTime then
    isExpireItem = true
  end
  self:SetWidgetVisible(widget.Image_LimitedTime, isExpireItem)
end
function Personalization_InvitationPopup_UIBP:UpdateItemReddot(data, index)
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  if not data.SubList and data.bReddot then
    data.bReddot = false
    logic_roleInfo_TeamUpFrame:RemoveRedDot(data.cfg.ID)
    return true
  elseif data.SubList and next(data.SubList) then
    for _, v in pairs(data.SubList) do
      if v.bReddot then
        v.bReddot = true
        logic_roleInfo_TeamUpFrame:RemoveRedDot(v.cfg.ID)
        return true
      end
    end
  end
  return false
end
function Personalization_InvitationPopup_UIBP:HandleButtonUse()
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  local data = self.dataList[self.baseItemSelectIndex]
  local id = logic_roleInfo_TeamUpFrame:GetDefaultSkinId()
  if data and data.cfg and data.cfg.ID and not data.SubList then
    id = data.cfg.ID
  elseif data and data.SubList and data.SubList[self.select] then
    id = data.SubList[self.select].cfg.ID
  end
  local TimeUtil = require("client.common.time_util")
  if data and data.expireTime and data.expireTime ~= 1 and TimeUtil.GetServerTimeInSec() > data.expireTime then
    ShowNotice(9910101)
    return
  end
  logic_roleInfo_TeamUpFrame:send_change_team_notify_skin(id)
end
function Personalization_InvitationPopup_UIBP:HandleButtonUnload()
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  logic_roleInfo_TeamUpFrame:send_change_team_notify_skin(logic_roleInfo_TeamUpFrame:GetDefaultSkinId())
end
function Personalization_InvitationPopup_UIBP:HandleButtonGo()
  local bigUI = UIManager.GetUI(UIManager.UI_Config.role_info_big_avatar)
  if bigUI then
    bigUI:CloseSelf()
  end
  local data = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  if not (data and data.cfg and data.cfg.JumpUrl) or data.cfg.JumpUrl == "" then
    return
  end
  GlobalData.JumpUrl(data.cfg.JumpUrl .. "&itemId=" .. data.cfg.ID)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
end
function Personalization_InvitationPopup_UIBP:OnTeamUpFrameUpdate()
  self:InitData()
  self:UpdateUI()
end
function Personalization_InvitationPopup_UIBP:OnTeamUpFrameChange()
  ShowNotice(49951)
  self.jumpSelectItemId = nil
  self:InitData()
  for _, v in ipairs(self.dataList) do
    if v.cfg.ID == DataMgr.roleData.cur_team_notify_skin_id then
      v.bIsSelected = true
    end
    v.bIsSelected = false
  end
  self:RefreshItemGrid(1)
end
function Personalization_InvitationPopup_UIBP:IsUsingItem(itemData)
  return itemData.bIsUse
end
function Personalization_InvitationPopup_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData and itemData.cfg) or not itemData.cfg.ID then
    return false
  end
  return itemData.cfg.ID == self.jumpSelectItemId
end
function Personalization_InvitationPopup_UIBP:GetItemList()
  local list = self.dataList
  if self.isCheckOwned then
    list = {}
    for i, v in ipairs(self.dataList) do
      if not v.bIsLock then
        table.insert(list, v)
      end
    end
  end
  return list
end
function Personalization_InvitationPopup_UIBP:InitData()
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  self.dataList = logic_roleInfo_TeamUpFrame:GetSkinList()
end
function Personalization_InvitationPopup_UIBP:UpdateUI()
  local nSelectIndex
  if not self.jumpSelectItemId then
    nSelectIndex = self.baseItemSelectIndex
  end
  self:RefreshItemGrid(nSelectIndex)
  self:UpdatePlayerInfo()
end
function Personalization_InvitationPopup_UIBP:UpdateSelectedItemInfo(data)
  local param = self:GenCommonItemParam()
  if data.SubList then
    param.lockedButtonStyle = self:GetLockedButtonStyleTable(data.SubList)
    param.lockedButtonStyle.select = self.select
    param.itemDataList = data.SubList
    param.selectItemData = self.select
    data = data.SubList[self.select]
  end
  if data.cfg.ID == 61010002 then
    self:SetWidgetVisible(self.UIRoot.Image_RP02, true)
    self:SetWidgetVisible(self.UIRoot.Image_RP01, true)
    self:SetWidgetVisible(self.UIRoot.Image_Normal04, false)
    self:SetWidgetVisible(self.UIRoot.Image_Normal02, false)
  else
    self:SetWidgetVisible(self.UIRoot.Image_RP02, false)
    self:SetWidgetVisible(self.UIRoot.Image_RP01, false)
    self:SetWidgetVisible(self.UIRoot.Image_Normal04, true)
    self:SetWidgetVisible(self.UIRoot.Image_Normal02, true)
  end
  self:SetWidgetVisible(self.UIRoot.Image_Normal06, data.cfg.ID == defaultSkinId)
  self:SetWidgetVisible(self.UIRoot.Image_Normal05, data.cfg.ID == defaultSkinId)
  if data.cfg.DescGet and data.cfg.DescGet ~= "" then
    param.extraInfo = LocUtil.LocalizeResFormat(data.cfg.DescGet)
  end
  local UIUtil = require("client.common.ui_util")
  param.itemID = data.cfg.ID
  local cfg = UIUtil.GetItemCfg(data.cfg.ID)
  if cfg then
    param.name = cfg.ItemName
  else
    log(bWriteLog and "Lobby_TeamUpFrame_UIBP:UpdateDesc invalid item item_id = " .. tostring(data.cfg.ID))
  end
  self.isShowSkin = false
  if data.cfg.DynamicIconPath ~= "" then
    self:AddEffectSkinByCreateChildWindow(data.cfg.DynamicIconPath, "DynamicBG_Root", "Auto_Loop")
    self:SetWidgetVisible(self.UIRoot.Background_RP, false)
    self:SetWidgetVisible(self.UIRoot.DynamicBG_Root, true)
    self.isShowSkin = true
  else
    self:SetWidgetVisible(self.UIRoot.DynamicBG_Root, false)
    if data.cfg.Skin ~= "" then
      self:SetTexture(self.UIRoot.Background_RP, data.cfg.Skin)
      self:SetWidgetVisible(self.UIRoot.Background_RP, true)
      local default_bg = "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Popup/Common_Popup_250UI_Small_BG.Common_Popup_250UI_Small_BG"
      if default_bg ~= data.cfg.Skin then
        self.isShowSkin = true
      end
    else
      self:SetWidgetVisible(self.UIRoot.Background_RP, false)
    end
  end
  self:ChangeTextColorBySkin()
  local TimeUtil = require("client.common.time_util")
  if not data.bIsLock then
    if data.cfg.DescTime and data.cfg.DescTime ~= "" then
      param.expireTime = LocUtil.GetLocalizeResStr(data.cfg.DescTime)
    else
      param.expireTime = data.expireTime
    end
  end
  if data.cfg.ID == defaultSkinId and data.bIsUse then
    param.buttonStyle = ENUM_Button_Style.None
  else
    local showtime = TimeUtil.TimeStringToUnixstamp(data.cfg.BeginShowTime)
    if data.bIsLock then
      if param.itemDataList and param.selectItemData > 1 then
        local needItem = param.itemDataList[param.selectItemData - 1]
        local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItem.cfg.ID)
        local needCurrency = upgradeCfg.Cost
        local locString = LocUtil.LocalizeResFormat(18010254, needCurrency)
        local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
        if not logic_roleInfo_TeamUpFrame:IsLocked(needItem) then
          if needCurrency <= self.currency then
            param.buttonStyle = ENUM_Button_Style.Upgrade
            self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_1:SetText(locString)
          else
            param.buttonStyle = ENUM_Button_Style.NoUpgrade
            self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_2:SetText(locString)
          end
        else
          param.buttonStyle = ENUM_Button_Style.None
        end
      else
        local remainTime = TimeUtil.GetDeltaTimeWithCurTime(showtime or TimeUtil.GetServerTimeInSec())
        if data.cfg.JumpUrl and data.cfg.JumpUrl ~= "" and remainTime == 0 then
          param.buttonStyle = ENUM_Button_Style.Go
        end
      end
    elseif data.bIsUse then
      param.buttonStyle = ENUM_Button_Style.Using
    else
      param.buttonStyle = ENUM_Button_Style.Use
    end
  end
  return param
end
function Personalization_InvitationPopup_UIBP:InitCurrency()
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    local currency_cfg = CDataTable.GetTableData("Item", self.C_Currency_ID)
    roleInfo_main:SetTexture(roleInfo_main.UIRoot.Image_3, currency_cfg.ItemSmallIcon, {sync = true})
  end
end
function Personalization_InvitationPopup_UIBP:UpdateCurrencyCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local num = wardrobe_data:GetHallDepotItemCountByResID(self.C_Currency_ID)
  self.currency = num
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main.UIRoot.TextBlock_0:SetText(num)
  end
end
function Personalization_InvitationPopup_UIBP:OnButtonCurrency()
  self:PlayAudio(sound_config.click_v1)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    local itemCfg = CDataTable.GetTableData("Item", self.C_Currency_ID) or {}
    UIManager.ShowUI(UIManager.UI_Config.ItemUp_Mat_Tips_UIBP, itemCfg, nil, {
      widget = roleInfo_main.UIRoot.Button_3,
      customOffset = {X = -120, Y = 50}
    })
  end
end
function Personalization_InvitationPopup_UIBP:HandleLockedButton1()
  log(bWriteLog and "Personalization_InvitationPopup_UIBP:HandleLockedButton1")
  self.select = 1
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_InvitationPopup_UIBP:HandleLockedButton2()
  log(bWriteLog and "Personalization_InvitationPopup_UIBP:HandleLockedButton2")
  self.select = 2
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_InvitationPopup_UIBP:HandleLockedButton3()
  log(bWriteLog and "Personalization_InvitationPopup_UIBP:HandleLockedButton3")
  self.select = 3
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_InvitationPopup_UIBP:HandleButtonUpgrade()
  log(bWriteLog and "Personalization_InvitationPopup_UIBP:HandleButtonUpgrade")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local curSelect = self.select
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItemData.cfg.ID)
  local UIUtil = require("client.common.ui_util")
  local cfg = UIUtil.GetItemCfg(needItemData.cfg.ID)
  local needCurrency = upgradeCfg.Cost
  local msgData = {
    styleType = CommonMsgBoxMgr.SHOW_TYPE_TWO,
    msg = LocUtil.LocalizeResFormat(18010241, needCurrency, cfg.ItemName),
    title = LocUtil.GetLocalizeResStr(39012),
    clickOkCallback = function()
      local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
      self:AddPromise(PopularityPKHandler.send_psmatch_reward_upgrade_req(needItemData.cfg.ID)):Then(function(err_code, _, _)
        if err_code == 0 then
          local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
          logic_roleInfo_TeamUpFrame:send_change_team_notify_skin(upgradeCfg.TargetItemID)
          logic_roleInfo_TeamUpFrame:send_get_team_notify_skin_list()
          ShowNotice(665020)
          self:AddTimerLoop(0.5, function()
            self.select = curSelect
            self:UpdateItemPreview(itemData)
          end)
        else
        end
      end)
    end
  }
  local UIManager = require("client.slua_ui_framework.manager")
  UIManager.ShowUI(UIManager.UI_Config.com_msg_box_slua, msgData)
end
function Personalization_InvitationPopup_UIBP:HandleButtonNoUpgrade()
  log(bWriteLog and "Personalization_InvitationPopup_UIBP:HandleButtonNoUpgrade")
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  if needItemData.bIsLock then
    ShowNotice(18010243)
  else
    ShowNotice(18010242)
  end
end
function Personalization_InvitationPopup_UIBP:GetLockedButtonStyleTable(itemDataList)
  local lockedButtonStyle = {
    bShow = false,
    button1 = {bShow = false, hasLock = true},
    button2 = {bShow = false, hasLock = true},
    button3 = {bShow = false, hasLock = true}
  }
  if itemDataList then
    lockedButtonStyle.bShow = true
    for _, v in ipairs(itemDataList) do
      local buttonName = "button" .. v.cfg.level
      lockedButtonStyle[buttonName].bShow = true
      if not v.bIsLock then
        lockedButtonStyle[buttonName].hasLock = false
      end
      lockedButtonStyle[buttonName].text = LocUtil.GetLocalizeResStr(18010254 + v.cfg.level)
    end
  end
  return lockedButtonStyle
end
function Personalization_InvitationPopup_UIBP:ChangeTextColorBySkin()
  local color
  if self.isShowSkin then
    color = FSlateColor(FLinearColor(1, 1, 1, 1))
  else
    color = FSlateColor(FLinearColor(0, 0, 0, 1))
  end
  self.UIRoot.TextBlock_FromType:SetColorAndOpacity(color)
  self.UIRoot.UTRichTextBlock_MapName:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_PlayerName:SetColorAndOpacity(color)
  self.UIRoot.UTRichTextBlock_Invite:SetColorAndOpacity(color)
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CLobby_TeamUpFrame_UIBP = class(ui_base, nil, Personalization_InvitationPopup_UIBP)
return CLobby_TeamUpFrame_UIBP