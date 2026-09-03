local Personalization_InformationCard_UIBP = {C_Currency_ID = 1703266}
local C_DefaultSegment = 101
function Personalization_InformationCard_UIBP:ctor(_)
  self.select = 0
  self.currency = 0
  self.isShowSkin = false
end
function Personalization_InformationCard_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_InformationCard_UIBP:InitCommonAvatarComp()
  Personalization_InformationCard_UIBP.__super.InitCommonAvatarComp(self)
  self.nameText = self.UIRoot.UTRichTextBlock_0
  self.smallAvatar = self.UIRoot.Common_Avatar_BP_C_145
  self.sexComp = self.UIRoot.Common_Gender_UIBP_C_0
end
function Personalization_InformationCard_UIBP:RegistEvents()
  Personalization_InformationCard_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CARTE_FRAME_UPDATE, self.UpdateAll, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CARTE_FRAME_CHANGE, self.UpdateAll, self)
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_SUMMARY, self.SetCorpsInfo, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.UpdateCurrencyCount, self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_3, self.OnButtonCurrency, self)
  end
end
function Personalization_InformationCard_UIBP:OnShow()
  Personalization_InformationCard_UIBP.__super.OnShow(self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_3, true, true)
  end
end
function Personalization_InformationCard_UIBP:OnHide()
  Personalization_InformationCard_UIBP.__super.OnHide(self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_3, false, true)
  end
end
function Personalization_InformationCard_UIBP:HandleClickedItem(widget, index)
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  local itemData = self.ItemGrid:GetItemData(index)
  if itemData and itemData.SubList then
    self.select = 1
    for _, v in ipairs(itemData.SubList) do
      if logic_roleinfo_carte_frame:IsHaveCarteFrame(v.config.SkinID) then
        self.select = v.config.Level
      end
      if v.config.SkinID == logic_roleinfo_carte_frame:GetCurrentCrateFrameBGID() then
        break
      end
    end
  end
  return nil
end
function Personalization_InformationCard_UIBP:HandleButtonGo()
  log(bWriteLog and "[InfoCard:SetCorpsInfo] click goto")
  local item_data = self.ItemGrid:GetItemData(self.ItemGrid._selectIndex)
  if item_data and item_data.SubList then
    item_data = item_data.SubList[self.curSelectItemData]
  end
  if not item_data then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil item data: " .. tostring(self.ItemGrid._selectIndex))
    return
  end
  if item_data.config.SourceJumpUrl and item_data.config.SourceJumpUrl ~= "" then
    local RoleInfoBigAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
    if RoleInfoBigAvatarSystem.IsShow() then
      RoleInfoBigAvatarSystem.CloseUI()
    end
    local moduleNumber = string.match(item_data.config.SourceJumpUrl, "module=(%d+)")
    if tonumber(moduleNumber) == BP_ENUM_MODULE_CORPS then
      GlobalData.JumpUrl(item_data.config.SourceJumpUrl .. "&extra=" .. item_data.config.SkinID)
    else
      GlobalData.JumpUrl(item_data.config.SourceJumpUrl)
    end
  end
end
function Personalization_InformationCard_UIBP:HandleItemExpiredPreRequest(item_data)
  if not (item_data and item_data.expire_ts) or item_data.expire_ts < 1 then
    return false
  end
  local ret = self:HandleItemExpired(item_data)
  if ret then
    ShowNotice(9910101)
  end
  return ret
end
function Personalization_InformationCard_UIBP:HandleButtonUnload()
  log(bWriteLog and "[InfoCard:SetCorpsInfo] click unequip")
  local item_data = self.ItemGrid:GetItemData(self.ItemGrid._selectIndex)
  if not item_data then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil item data: " .. tostring(self.ItemGrid._selectIndex))
    return
  end
  if self:HandleItemExpiredPreRequest(item_data) then
    return
  end
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  logic_roleinfo_carte_frame:equip_carte_frame_req(item_data.config.SkinID, false)
end
function Personalization_InformationCard_UIBP:HandleButtonUse()
  log(bWriteLog and "[InfoCard:SetCorpsInfo] click equip")
  local item_data = self.ItemGrid:GetItemData(self.ItemGrid._selectIndex)
  if item_data.SubList then
    item_data = item_data.SubList[self.curSelectItemData]
  end
  if not item_data then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil item data: " .. tostring(self.ItemGrid._selectIndex))
    return
  end
  if self:HandleItemExpiredPreRequest(item_data) then
    return
  end
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  logic_roleinfo_carte_frame:equip_carte_frame_req(item_data.config.SkinID, true)
end
function Personalization_InformationCard_UIBP:HandleLockedButton1()
  log(bWriteLog and "Personalization_InformationCard_UIBP:HandleLockedButton1")
  self.select = 1
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_InformationCard_UIBP:HandleLockedButton2()
  log(bWriteLog and "Personalization_InformationCard_UIBP:HandleLockedButton2")
  self.select = 2
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_InformationCard_UIBP:HandleLockedButton3()
  log(bWriteLog and "Personalization_InformationCard_UIBP:HandleLockedButton3")
  self.select = 3
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_InformationCard_UIBP:HandleButtonUpgrade()
  log(bWriteLog and "Personalization_InformationCard_UIBP:HandleButtonUpgrade")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local curSelect = self.select
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItemData.config.SkinID)
  local need_item_config = CDataTable.GetTableData("Item", needItemData.config.SkinID)
  local needCurrency = upgradeCfg.Cost
  local sMsg = LocUtil.LocalizeResFormat(18010241, needCurrency, need_item_config.ItemName)
  local sTitle = LocUtil.GetLocalizeResStr(39012)
  local fClickOkCallback = function()
    self.jumpSelectItemId = itemData and itemData.config and itemData.config.SkinID
    local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
    self:AddPromise(PopularityPKHandler.send_psmatch_reward_upgrade_req(needItemData.config.SkinID)):Then(function(err_code, _, upgrade_item_id)
      if err_code == 0 then
        local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
        logic_roleinfo_carte_frame:equip_carte_frame_req(upgrade_item_id, true)
        self.select = curSelect
        self:UpdateItemPreview(itemData)
        ShowNotice(665020)
      else
      end
    end)
  end
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sMsg, fClickOkCallback)
end
function Personalization_InformationCard_UIBP:HandleButtonNoUpgrade()
  log(bWriteLog and "Personalization_InformationCard_UIBP:HandleButtonNoUpgrade")
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  if not logic_roleinfo_carte_frame:IsHaveCarteFrame(needItemData.config.SkinID) then
    ShowNotice(18010243)
  else
    ShowNotice(18010242)
  end
end
function Personalization_InformationCard_UIBP:OnPostInitialize()
  Personalization_InformationCard_UIBP.__super.OnPostInitialize(self)
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  self.DefaultSkinID = logic_roleinfo_carte_frame:GetDefaultSkinID()
  self:InitCurrency()
  self:UpdateAll()
end
function Personalization_InformationCard_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData and itemData.config) or not itemData.config.SkinID then
    return false
  end
  return itemData.config.SkinID == self.jumpSelectItemId
end
function Personalization_InformationCard_UIBP:GetItemList()
  local postFilterList = {}
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  local CarteFrameList = logic_roleinfo_carte_frame:GetCarteFrameList()
  if not CarteFrameList or not next(CarteFrameList) then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil carte frame list")
    logic_roleinfo_carte_frame:get_carte_frame_list_req()
    return postFilterList
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local table_util = require("common.table_util")
  local i = 1
  while i <= #CarteFrameList do
    if CarteFrameList[i].config.Type and CarteFrameList[i].config.Type ~= 0 then
      local itemList = {}
      local type = CarteFrameList[i].config.Type
      local j = i
      while j <= #CarteFrameList do
        if CarteFrameList[j].config.Type == type then
          table.insert(itemList, CarteFrameList[j])
          table.remove(CarteFrameList, j)
        else
          j = j + 1
        end
      end
      table.sort(itemList, function(l, r)
        return l.config.Level < r.config.Level
      end)
      local item = table_util.CopyTable(itemList[1])
      item.SubList = itemList
      table.insert(CarteFrameList, i, item)
    end
    i = i + 1
  end
  for _, carteFrame in ipairs(CarteFrameList) do
    if carteFrame.config and carteFrame.config.SourceShowTime and (carteFrame.config.bShow or not carteFrame.bLock) and (not (self.isCheckOwned and carteFrame.bLock) or carteFrame.config.SkinID == self.DefaultSkinID) then
      local SourceShowTime = tonumber(TimeUtil.TimeStringToUnixstamp(carteFrame.config.SourceShowTime))
      if nowTime >= SourceShowTime then
        table.insert(postFilterList, carteFrame)
      end
    end
  end
  return postFilterList
end
function Personalization_InformationCard_UIBP:InitCurrency()
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    local currency_cfg = CDataTable.GetTableData("Item", self.C_Currency_ID)
    roleinfo_main:SetTexture(roleinfo_main.UIRoot.Image_3, currency_cfg.ItemSmallIcon, {sync = true})
  end
end
function Personalization_InformationCard_UIBP:UpdateAll()
  log(bWriteLog and "[InfoCard:SetCorpsInfo] Update All")
  if self.jumpSelectItemId then
    self:RefreshItemGrid(self.jumpSelectItemId)
  else
    self:RefreshItemGrid(1)
  end
  self:UpdateCurrencyCount()
end
function Personalization_InformationCard_UIBP:UpdateCurrencyCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local num = wardrobe_data:GetHallDepotItemCountByResID(self.C_Currency_ID)
  self.currency = num
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main.UIRoot.TextBlock_0:SetText(num)
  end
end
function Personalization_InformationCard_UIBP:IsLimitedItem(item_data)
  if not item_data then
    return false
  end
  if not item_data.expire_ts then
    return false
  end
  if type(item_data.expire_ts) == "string" then
    return true
  end
  return item_data.expire_ts > 1
end
function Personalization_InformationCard_UIBP:HandleItemExpired(item_data)
  if not self:IsLimitedItem(item_data) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  if type(item_data.expire_ts) == "number" and TimeUtil.GetServerTimeInSec() > item_data.expire_ts then
    item_data.expire_ts = 0
    item_data.bLock = true
    item_data.bRed = false
    local CurSelectID = self.DefaultSkinID
    local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
    if SocialCardSystem.SocialCard and SocialCardSystem.SocialCard.carte_frame_equip_id then
      CurSelectID = SocialCardSystem.SocialCard.carte_frame_equip_id
    end
    local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
    if item_data.config.SkinID == CurSelectID then
      SocialCardSystem.SocialCard.carte_frame_equip_id = self.DefaultSkinID
      logic_roleinfo_carte_frame:equip_carte_frame_req(item_data.config.SkinID, false)
    end
    logic_roleinfo_carte_frame:SortCarteFrameList()
    self:AddTimerOnce(0.01, function()
      if not slua.isValid(self.UIRoot) then
        return
      end
      self:RefreshItemGrid()
    end)
    return true
  end
  return false
end
function Personalization_InformationCard_UIBP:OnRefreshGridItem(widget, index)
  if not widget then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil widget for index: " .. tostring(index))
    return
  end
  local item_data = self.ItemGrid:GetItemData(index)
  if not item_data then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil item data for index: " .. tostring(index))
    return
  end
  local effect_bp = item_data.config.EffectBP
  local card_skin_bp = self:AddEffectSkinByCreateChildWindow(effect_bp, widget.CanvasPanel_Effect, item_data.config.bLoopAnim and "Auto_Loop" or nil)
  if card_skin_bp then
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  local skinID = item_data.config.SkinID
  local CurSelectID = self.DefaultSkinID
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.SocialCard and SocialCardSystem.SocialCard.carte_frame_equip_id then
    CurSelectID = SocialCardSystem.SocialCard.carte_frame_equip_id
  end
  local bUse = skinID == CurSelectID
  local bRed = item_data.bRed
  if item_data.SubList then
    for _, v in ipairs(item_data.SubList) do
      if v.config.SkinID == CurSelectID then
        bUse = true
      end
      if v.bRed then
        bRed = true
      end
    end
  end
  local isLimitedItem = self:IsLimitedItem(item_data)
  if isLimitedItem then
    self:HandleItemExpired(item_data)
  end
  self:SetWidgetVisible(widget.Image_LimitedTime, isLimitedItem)
  self:SetWidgetVisible(widget.Image_Select, index == self.baseItemSelectIndex)
  self:SetWidgetVisible(widget.Image_Reddot, bRed)
  self:SetWidgetVisible(widget.WidgetSwitcher_1, true)
  if bUse then
    widget.WidgetSwitcher_1:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    if skinID ~= self.DefaultSkinID then
      self:SetWidgetVisible(widget.WidgetSwitcher_1, item_data.bLock)
      self:SetWidgetVisible(widget.Image_Mask, item_data.bLock)
    else
      self:SetWidgetVisible(widget.WidgetSwitcher_1, false)
      self:SetWidgetVisible(widget.Image_Mask, false)
      return
    end
  end
end
function Personalization_InformationCard_UIBP:UpdateItemReddot(item_data, index)
  local needUpdate = false
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  if item_data.SubList then
    for _, subItem in ipairs(item_data.SubList) do
      if subItem.bRed then
        subItem.bRed = false
        logic_roleinfo_carte_frame:RemoveRedDot(subItem.config.SkinID)
        needUpdate = true
      end
    end
  end
  if item_data.bRed then
    item_data.bRed = false
    logic_roleinfo_carte_frame:RemoveRedDot(item_data.config.SkinID)
    needUpdate = true
  end
  return needUpdate
end
function Personalization_InformationCard_UIBP:GetDescTitleInfo()
  return LocUtil.GetLocalizeResStr(45874), LocUtil.GetLocalizeResStr(10071)
end
function Personalization_InformationCard_UIBP:UpdateSelectedItemInfo(item_data)
  if not item_data then
    log(bWriteLog and "[InfoCard:UpdateSelectedItemInfo] nil item data")
    return
  end
  local param = self:GenCommonItemParam()
  if item_data.SubList then
    param.lockedButtonStyle = self:GetLockedButtonStyleTable(item_data.SubList)
    param.lockedButtonStyle.select = self.select
    param.itemDataList = item_data.SubList
    param.selectItemData = self.select
    item_data = item_data.SubList[self.select]
  end
  local skinID = item_data.config.SkinID
  param.itemID = skinID
  local item_config = CDataTable.GetTableData("Item", skinID)
  if item_config then
    param.name = item_config.ItemName
  else
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil item config: " .. tostring(skinID))
  end
  if not item_data.bLock then
    param.expireTime = item_data.expire_ts
  end
  self:UpdateMainPageCarteFrame(skinID, item_data)
  self:UpdateInfoPageCarteFrame(item_data, skinID)
  if item_data.config.SourceDesc and item_data.config.SourceDesc ~= "" then
    param.extraInfo = LocUtil.LocalizeResFormat(item_data.config.SourceDesc)
  end
  local CurSelectID = self.DefaultSkinID
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.SocialCard and SocialCardSystem.SocialCard.carte_frame_equip_id then
    CurSelectID = SocialCardSystem.SocialCard.carte_frame_equip_id
  end
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  local isHave = logic_roleinfo_carte_frame:IsHaveCarteFrame(skinID)
  if skinID == self.DefaultSkinID then
    param.expireTime = 0
    if CurSelectID ~= self.DefaultSkinID then
      param.buttonStyle = ENUM_Button_Style.Use
    end
  elseif isHave then
    if skinID == CurSelectID then
      param.buttonStyle = ENUM_Button_Style.Unload
    else
      param.buttonStyle = ENUM_Button_Style.Use
    end
  elseif param.itemDataList and param.selectItemData > 1 and logic_roleinfo_carte_frame:IsHaveCarteFrame(param.itemDataList[1].config.SkinID) then
    local needItem = param.itemDataList[param.selectItemData - 1]
    local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItem.config.SkinID)
    local needCurrency = upgradeCfg.Cost
    local locString = LocUtil.LocalizeResFormat(18010254, needCurrency)
    if logic_roleinfo_carte_frame:IsHaveCarteFrame(needItem.config.SkinID) and needCurrency <= self.currency then
      param.buttonStyle = ENUM_Button_Style.Upgrade
      self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_1:SetText(locString)
    else
      param.buttonStyle = ENUM_Button_Style.NoUpgrade
      self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_2:SetText(locString)
    end
  elseif item_data.config.SourceJumpUrl and item_data.config.SourceJumpUrl ~= "" then
    param.buttonStyle = ENUM_Button_Style.Go
  else
    param.buttonStyle = ENUM_Button_Style.None
  end
  if item_data then
    self:UpdateItemReddot(item_data)
  end
  return param
end
function Personalization_InformationCard_UIBP:UpdateInfoPageCarteFrame(item_data, skinID)
  self.isShowSkin = false
  if skinID == self.DefaultSkinID then
    self.UIRoot.WidgetSwitcher_4:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(0)
  else
    local StringUtil = require("common.string_util")
    local effect_bp_path = item_data.config.EffectBP
    local bLoopAnim = item_data.config.bLoopAnim
    local extraData = {}
    local anim = bLoopAnim and "Auto_Loop"
    if item_data.config.Level == 1 then
    end
    if item_data.config.Level == 3 then
      extraData.bEnableGyroscope = true
    end
    local child = self:AddEffectSkinByCreateChildWindow(effect_bp_path, "GridPanel_1", anim, extraData)
    if child then
      self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(1)
      self.isShowSkin = true
    else
      self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(0)
    end
    local skin_path = item_data.config.SkinPath
    local pak_util = require("client.common.pak_util")
    if skin_path and skin_path ~= "" and pak_util.IsPufferDownloaded(skin_path) then
      self:SetTexture(self.UIRoot.Image_bg02, skin_path)
    else
      self:AddDownloadResPath(skin_path)
      self.UIRoot.WidgetSwitcher_4:SetActiveWidgetIndex(0)
    end
  end
  self:ChangeTextColorBySkin()
end
function Personalization_InformationCard_UIBP:OnButtonCurrency()
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
function Personalization_InformationCard_UIBP:OnTitleTabChanged(titleTab)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(titleTab)
end
function Personalization_InformationCard_UIBP:UpdatePlayerInfo()
  local profile = Personalization_InformationCard_UIBP.__super.UpdatePlayerInfo(self)
  if profile then
    self:updateInfoCard(profile)
    self:UpdateMainPage(profile)
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local corps_summary = LobbySocialSystem.CacheCorpsSummary[profile.corps_id] or nil
    if profile.corps_id > 0 and not corps_summary then
      local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
      ChatMenuSystem.get_corps_summary_req(profile.corps_id, tonumber(profile.uid))
    end
    self:SetCorpsInfo(nil, nil, corps_summary, profile)
  end
  return profile
end
function Personalization_InformationCard_UIBP:updateInfoCard(SelfProfile)
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  logic_segment_title:SetMaxSegmentRankInteralWithTitle(self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP_C_1, SelfProfile.segment_info, SelfProfile.hsegment_title_det)
end
function Personalization_InformationCard_UIBP:UpdateMainPage(profile)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local showUid = RoleInfoSystem.CurShowPlayerInfoUid
  self.UIRoot.Common_Avatar_BP:InitView(1, profile.uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Common_Avatar_BP_C_0:InitView(1, profile.uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
  self.UIRoot.Common_Avatar_BP_C_0:SetButtonEnabled(false)
  self.UIRoot.Common_Avatar_BP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Common_Avatar_BP_C_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not RoleInfoSystem.IsSelf() then
    self.UIRoot.Common_Avatar_BP:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.Common_Avatar_BP_C_0:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP_C_0:SetRankInteral(profile.cur_max_segment_level or C_DefaultSegment, nil)
  local UIUtil = require("client.common.ui_util")
  self.UIRoot.TextBlock_PlayerName:SetText(profile.nickName or "")
  self.UIRoot.TextBlock_PlayerID:SetText(showUid or "")
  if profile.social_card and self.UIRoot.Common_Gender_UIBP then
    self.UIRoot.Common_Gender_UIBP:LoadIcon(showUid)
  end
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local upass_is_buy, upass_is_show, upass_keep_buy, upass_cur_value, pass_type = UnknowPassUtil.ParseUpassInfo(profile.upass)
  self.UIRoot.UnknowPass_ContinuousBuy_BP:SetTypeData(0, upass_keep_buy, upass_is_buy == 1, 1, upass_cur_value, pass_type or 0)
  self.UIRoot.UnknowPass_ContinuousBuy_BP_C_0:SetTypeData(0, upass_keep_buy, upass_is_buy == 1, 1, upass_cur_value, pass_type or 0)
  self.UIRoot.PassBig:SetWidgetVisibility(UIUtil.BoolToVisible(upass_is_show ~= 0))
  self.UIRoot.TextBlock_upass_level:SetText(profile.upass.level or 1)
  local platformIcon = UIUtil.GetPlatformlIcon(showUid)
  if platformIcon then
    self:SetTexture(self.UIRoot.Image_Platform, platformIcon)
    self.UIRoot.Image_Platform:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() and (BP_Platform == BP_ENUM_PLAYFORM_WX or BP_Platform == BP_ENUM_PLAYFORM_BGBGByiTOP) then
      self.UIRoot.Image_Platform:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.Image_Platform:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.UIRoot.Text_Upvote:SetText(profile.upvote or 0)
  self.UIRoot.Image_Flag_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  UIUtil.UpdateNationImage(self.UIRoot.Image_Flag_1, profile.nation)
  self.UIRoot.Image_Flag:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  UIUtil.UpdateNationImage(self.UIRoot.Image_Flag, profile.nation)
  if self.UIRoot.Common_LightBoard_UIBP_C_0 then
    self.UIRoot.Common_LightBoard_UIBP_C_0:ShowLightBoard(showUid)
    self.UIRoot.CanvasPanel_16:setWidgetVisibility(self.UIRoot.Common_LightBoard_UIBP_C_0:GetVisibility())
  end
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  if logic_oldfriend_care.IsRejoinPlayer(profile) then
    self:SetWidgetVisible(self.UIRoot.Image_57, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_57, false)
  end
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  logic_team_evaluation_view.RefreshEvaluationEntrance(showUid, self.UIRoot)
  if showUid == DataMgr.roleData.uid then
    self.UIRoot.TextBlock_12:SetText(LocUtil.LocalizeResFormat(601, profile.level or 1))
  else
    self.UIRoot.TextBlock_12:SetText(LocUtil.LocalizeResFormat(42632, profile.level or 1))
  end
  self.UIRoot.TextBlock_PlayerXP:SetText(profile.exp)
  local curlevel = tonumber(profile.level)
  local percent_exp = 1
  if 0 < curlevel and curlevel < 100 then
    local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
    local Exp = CorpsMgr.GetLevelExp(curlevel)
    percent_exp = profile.exp / Exp
    self.UIRoot.TextBlock_LimitMaxXP:SetText(Exp)
  end
  self.UIRoot.ProgressBar_Level:SetPercent(percent_exp)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Exp, curlevel < 100)
  self.UIRoot.TextBlock_13:SetText(LocUtil.LocalizeResFormat(680, profile.pve_level or 1))
  self.UIRoot.TextBlock_PVE_XP:SetText(profile.pve_exp or 0)
  local percent_pve_exp = 1
  local curPveLevel = tonumber(profile.pve_level) or 1
  if 0 < curPveLevel and curPveLevel < 100 then
    local curPveLevelItem = CDataTable.GetTableData("PveLevel", curPveLevel)
    self.UIRoot.TextBlock_PVE_MaxXP:SetText(curPveLevelItem.Exp or 0)
    percent_pve_exp = (profile.pve_exp or 0) / (curPveLevelItem.Exp or 1)
  end
  self.UIRoot.ProgressBar_0:SetPercent(percent_pve_exp)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_PVE_Exp, curPveLevel < 100)
  self:UpdateMainPageCarteFrame(profile.social_card.carte_frame_equip_id)
  local Personal_Info_UIBP = require("client.slua.umg.lobby_chat.Personal_Info_UIBP")
  local customSwitches = Personal_Info_UIBP.GetPlayerCustomSwitches(profile)
  local showBadge = customSwitches.collectLevel
  self:SetWidgetVisible(self.UIRoot.Common_Collect_Level_DynamicLoading_UIBP_C_0, false, false)
end
function Personalization_InformationCard_UIBP:UpdateMainPageCarteFrame(frameIndex, item_data)
  self.isShowSkin = false
  if frameIndex then
    local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
    local _, _, roleinfo_bp_path, bLoopAnim = logic_roleinfo_carte_frame:GetSkinPath(frameIndex)
    local extraData = {}
    local anim = bLoopAnim and "Auto_Loop"
    if item_data.config.Level == 1 then
    end
    if item_data and item_data.config.Level == 3 then
      extraData.bEnableGyroscope = true
    end
    local child = self:AddEffectSkinByCreateChildWindow(roleinfo_bp_path, "BG_Effect", anim, extraData)
    if child then
      self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(1)
      self.isShowSkin = true
    else
      self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
    end
  else
    self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  end
  self:ChangeTextColorBySkin()
end
function Personalization_InformationCard_UIBP:SetCorpsInfo(_, __, corps_summary, profile)
  log(bWriteLog and "[InfoCard:SetCorpsInfo] SetCorpsInfo")
  if not self.UIRoot then
    return
  end
  if not corps_summary or not corps_summary.name then
    log(bWriteLog and "[InfoCard:SetCorpsInfo] nil corps_summary")
    self:UpdateCorpsInfo(false, LocUtil.GetLocalizeResStr(5085))
    return
  end
  self:UpdateCorpsInfo(true, corps_summary.name, corps_summary)
  local cfg = CDataTable.GetTableData("corps_alias_table", profile and profile.corp_alias_id or 0)
  if cfg and cfg.Default == 1 then
    self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    if cfg then
      self.UIRoot["aliasName" .. cfg.background]:SetText(cfg.CorpAliasName)
      self.UIRoot.WidgetSwitcher_21:SetActiveWidgetIndex(cfg.background - 1)
    end
  end
end
function Personalization_InformationCard_UIBP:GetLockedButtonStyleTable(itemDataList)
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  local lockedButtonStyle = {
    bShow = false,
    button1 = {bShow = false, hasLock = true},
    button2 = {bShow = false, hasLock = true},
    button3 = {bShow = false, hasLock = true}
  }
  if itemDataList then
    lockedButtonStyle.bShow = true
    for _, v in ipairs(itemDataList) do
      local buttonName = "button" .. v.config.Level
      lockedButtonStyle[buttonName].bShow = true
      if logic_roleinfo_carte_frame:IsHaveCarteFrame(v.config.SkinID) then
        lockedButtonStyle[buttonName].hasLock = false
      end
      lockedButtonStyle[buttonName].text = LocUtil.GetLocalizeResStr(18010254 + v.config.Level)
    end
  end
  return lockedButtonStyle
end
function Personalization_InformationCard_UIBP:UpdateCorpsInfo(visible, corpsName, corps_summary)
  local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
  self:SetWidgetVisible(self.UIRoot.Image_icon_juntuan, visible)
  self:SetWidgetVisible(self.UIRoot.Image_icon_juntuan02, visible)
  if corps_summary then
    local Icon = ChatMenuSystem.GetCorpsSummaryIcon(corps_summary)
    if Icon ~= "" then
      self:SetTexture(self.UIRoot.Image_icon_juntuan, Icon)
      self:SetTexture(self.UIRoot.Image_icon_juntuan02, Icon)
    end
    self.UIRoot.WidgetSwitcher_6:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local pos = corps_summary and corps_summary.position or 0
    if pos == 0 then
      self.UIRoot.WidgetSwitcher_6:SetActiveWidgetIndex(3)
    elseif pos == 1 then
      self.UIRoot.WidgetSwitcher_6:SetActiveWidgetIndex(0)
    elseif pos == 2 then
      self.UIRoot.WidgetSwitcher_6:SetActiveWidgetIndex(1)
    elseif pos == 3 then
      self.UIRoot.WidgetSwitcher_6:SetActiveWidgetIndex(2)
    else
      self.UIRoot.WidgetSwitcher_6:SetActiveWidgetIndex(3)
    end
  else
    self.UIRoot.WidgetSwitcher_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  corpsName = corpsName or ""
  self.UIRoot.txt_juntuan:SetText(corpsName)
  self.UIRoot.txt_juntuan02:SetText(corpsName)
end
function Personalization_InformationCard_UIBP:ChangeTextColorBySkin()
  local color
  if self.isShowSkin then
    color = FSlateColor(FLinearColor(1, 1, 1, 1))
  else
    color = FSlateColor(FLinearColor(0, 0, 0, 1))
  end
  self.UIRoot.TextBlock_PlayerName:SetColorAndOpacity(color)
  self.UIRoot.txt_juntuan:SetColorAndOpacity(color)
  self.UIRoot.txt_juntuan02:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_PlayerID:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_PlayerIDLabel:SetColorAndOpacity(color)
  self.UIRoot.Image_9:SetColorAndOpacity(self.isShowSkin and FLinearColor(1, 1, 1, 1) or FLinearColor(0, 0, 0, 1))
  self.UIRoot.Image_fuzhi:SetColorAndOpacity(self.isShowSkin and FLinearColor(1, 1, 1, 1) or FLinearColor(0, 0, 0, 1))
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local InfoCardUIBP = class(ui_base, nil, Personalization_InformationCard_UIBP)
return InfoCardUIBP