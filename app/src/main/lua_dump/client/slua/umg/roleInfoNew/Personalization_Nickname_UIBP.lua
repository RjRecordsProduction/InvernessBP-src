local Personalization_Nickname_UIBP = {C_Currency_ID = 1703266}
function Personalization_Nickname_UIBP:ctor(_, jumpSelectItemId)
  self.dataList = {}
  self.defaultSkinID = 0
  self.curSkinID = 0
  self.select = 0
  self.currency = 0
end
function Personalization_Nickname_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_Nickname_UIBP:RegistEvents()
  Personalization_Nickname_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE, self.OnUpdateData, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.UpdateCurrencyCount, self)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main:AddOnClickedEventByControl(roleInfo_main.UIRoot.Button_3, self.OnButtonCurrency, self)
  end
end
function Personalization_Nickname_UIBP:OnPostInitialize()
  Personalization_Nickname_UIBP.__super.OnPostInitialize(self)
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_get_friend_nickname_skin_req()
  self:InitCurrency()
end
function Personalization_Nickname_UIBP:InitCommonAvatarComp()
  Personalization_Nickname_UIBP.__super.InitCommonAvatarComp(self)
  self.smallAvatar = self.UIRoot.Common_Avatar_BP
end
function Personalization_Nickname_UIBP:OnShow()
  Personalization_Nickname_UIBP.__super.OnShow(self)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main:SetWidgetVisible(roleInfo_main.UIRoot.Button_3, true, true)
  end
  self:UpdateCurrencyCount()
end
function Personalization_Nickname_UIBP.OnHide()
  Personalization_Nickname_UIBP.__super.OnHide(self)
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main:SetWidgetVisible(roleInfo_main.UIRoot.Button_3, false, true)
  end
end
function Personalization_Nickname_UIBP:OnUpdateData(_, _, bIsChangeFrame, bIsReddot)
  if bIsReddot then
    log(bWriteLog and "Personalization_Nickname_UIBP:OnUpdateData bIsReddot")
    return
  end
  if bIsChangeFrame then
    self.baseItemSelectIndex = 1
    self.jumpSelectItemId = nil
  end
  if self.jumpSelectItemId then
    self:RefreshItemGrid()
  else
    self:RefreshItemGrid(self.baseItemSelectIndex)
  end
end
function Personalization_Nickname_UIBP:UpdateItemReddot(data, index)
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  if not data.SubList and data.bReddot then
    data.bReddot = false
    logic_roleInfo_nicknameframe:RemoveRedDot(data.ID, index)
    return true
  elseif data.SubList and next(data.SubList) then
    for _, v in pairs(data.SubList) do
      if v.bReddot then
        v.bReddot = false
        logic_roleInfo_nicknameframe:RemoveRedDot(v.ID, index)
        return true
      end
    end
  end
  return false
end
function Personalization_Nickname_UIBP:HandleClickedItem(widget, index)
  local data = self.ItemGrid:GetItemData(index)
  if not data then
    log(bWriteLog and "Personalization_Nickname_UIBP:HandleClickedItem. data is nil")
    return
  elseif data.SubList then
    self.select = 1
    for _, v in ipairs(data.SubList) do
      if v.bIsUse then
        self.select = v.level
      end
    end
  end
end
function Personalization_Nickname_UIBP:OnRefreshGridItem(widget, index)
  local data = self.ItemGrid:GetItemData(index)
  local child = self:AddEffectSkinByCreateChildWindow(data.BPPath, widget.CanvasPanel_Effect, "Loop")
  widget.WidgetSwitcher_1:SetActiveWidgetIndex(child ~= nil and 1 or 0)
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_chatframe)
  local bIsUse = logic_roleInfo_nicknameframe:IsUsing(data)
  local bIsLock = logic_roleInfo_nicknameframe:IsLocked(data)
  local bReddot = logic_roleInfo_nicknameframe:IsReddot(data)
  self:SetWidgetVisible(widget.WidgetSwitcher_0, bIsUse or bIsLock)
  local isLock = bIsLock and 0 or 1
  if data.ID == self.defaultSkinID then
    isLock = 1
  end
  if bIsLock then
    local borderOpacity = FLinearColor(1, 1, 1, 0.4)
    local lockOpacity = FLinearColor(1, 1, 1, 0.7)
    widget.Border_Opacity:SetContentColorandOpacity(borderOpacity)
    widget.Image_Lock:SetColorAndOpacity(lockOpacity)
  else
    widget.Border_Opacity:SetContentColorandOpacity(FLinearColor(1, 1, 1, 1))
  end
  self:SetWidgetVisible(widget.Image_Using, bIsUse)
  widget.WidgetSwitcher_0:SetActiveWidgetIndex(isLock)
  self:SetWidgetVisible(widget.Image_Select, index == self.baseItemSelectIndex)
  self:SetWidgetVisible(widget.Image_Reddot, bReddot)
  self:SetWidgetVisible(widget.Image_LimitedTime, not bIsLock and data.expire_ts and 1 < data.expire_ts)
end
function Personalization_Nickname_UIBP:HandleButtonUse()
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  local data = self.dataList[self.baseItemSelectIndex]
  local id = logic_roleInfo_nicknameframe:GetShowDataListGetDefaultID()
  if data and data.ID and not data.SubList then
    id = data.ID
  elseif data and data.SubList and data.SubList[self.select] then
    id = data.SubList[self.select].ID
  end
  local TimeUtil = require("client.common.time_util")
  if data and data.expire_ts and data.expire_ts ~= 0 and TimeUtil.GetServerTimeInSec() > data.expire_ts then
    ShowNotice(9910101)
    return
  end
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_set_friend_nickname_skin_req(id)
end
function Personalization_Nickname_UIBP:HandleButtonUnload()
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  RoleInfoHandler.send_set_friend_nickname_skin_req(logic_roleInfo_nicknameframe:GetShowDataListGetDefaultID())
end
function Personalization_Nickname_UIBP:HandleButtonGo()
  local RoleInfoBigAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
  if RoleInfoBigAvatarSystem.IsShow() then
    RoleInfoBigAvatarSystem.CloseUI()
  end
  local data = self.dataList[self.baseItemSelectIndex]
  if not data or data.GetJumpUrl == "" then
    return
  end
  GlobalData.JumpUrl(data.GetJumpUrl)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
end
function Personalization_Nickname_UIBP:GetItemList()
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  self.dataList = logic_roleInfo_nicknameframe:GetShowDataList()
  self.defaultSkinID = logic_roleInfo_nicknameframe:GetShowDataListGetDefaultID()
  self.curSkinID = DataMgr.roleData.friend_nickname_skin
  local list = self.dataList
  if self.isCheckOwned then
    list = {}
    for i, v in ipairs(self.dataList) do
      if not v.bIsLock or v.ID == self.defaultSkinID then
        table.insert(list, v)
      end
    end
  end
  return list
end
function Personalization_Nickname_UIBP:HandleOwnCheckChange()
  Personalization_Nickname_UIBP.__super.HandleOwnCheckChange(self)
  self.baseItemSelectIndex = 1
end
function Personalization_Nickname_UIBP:UpdateSelectedItemInfo(data)
  if not data then
    return
  end
  local param = self:GenCommonItemParam()
  if data.SubList then
    param.lockedButtonStyle = self:GetLockedButtonStyleTable(data.SubList)
    param.lockedButtonStyle.select = self.select
    param.itemDataList = data.SubList
    param.selectItemData = self.select
    data = data.SubList[self.select]
  end
  local UIUtil = require("client.common.ui_util")
  local cfg = UIUtil.GetItemCfg(data.ID)
  if not cfg then
    log(bWriteLog and "Lobby_RoleInfo_Nickname_UIBP:UpdateDesc invalid item item_id = " .. tostring(data.ID))
    return
  end
  param.itemID = data.ID
  if data.GetDescID ~= 0 then
    param.extraInfo = LocUtil.LocalizeResFormat(data.GetDescID)
  else
    param.buttonStyle = ENUM_Button_Style.None
  end
  param.name = cfg.ItemName
  self:AddNickNameEffect("CanvasPanel_Effect_1", data.BPPath)
  self:AddNickNameEffect("CanvasPanel_Effect_2", data.BPPath)
  local TimeUtil = require("client.common.time_util")
  if not data.bIsLock or data.ID == self.defaultSkinID then
    param.expireTime = data.expire_ts
  end
  if data.BPPath == "" and data.bIsUse then
    param.buttonStyle = ENUM_Button_Style.Using
  elseif param.itemDataList and param.selectItemData > 1 and data.bIsLock then
    local needItem = param.itemDataList[param.selectItemData - 1]
    local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItem.ID)
    local needCurrency = upgradeCfg.Cost
    local locString = LocUtil.LocalizeResFormat(18010254, needCurrency)
    local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
    if not logic_roleInfo_nicknameframe:IsLocked(needItem) then
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
    local showtime = TimeUtil.TimeStringToUnixstamp(data.access_display_ts)
    if data.bIsLock and data.ID ~= self.defaultSkinID then
      local remainTime = TimeUtil.GetDeltaTimeWithCurTime(showtime)
      if data.GetJumpUrl and data.GetJumpUrl ~= "" and remainTime == 0 then
        param.buttonStyle = ENUM_Button_Style.Go
      else
        param.buttonStyle = ENUM_Button_Style.None
      end
    elseif data.bIsUse then
      param.buttonStyle = ENUM_Button_Style.Using
    else
      param.buttonStyle = ENUM_Button_Style.Use
    end
  end
  return param
end
function Personalization_Nickname_UIBP:AddNickNameEffect(rootName, bpPath)
  self:AddEffectSkinByCreateChildWindow(bpPath, rootName, "Anim_In")
end
function Personalization_Nickname_UIBP:UpdatePlayerInfo()
  Personalization_Nickname_UIBP.__super.UpdatePlayerInfo(self)
  self.UIRoot.Common_Avatar_BP:InitView(3, DataMgr.roleData.uid, DataMgr.roleData.headIconUrl, 0, DataMgr.roleData.cur_avatar_box_id, DataMgr.roleData.level, false, DataMgr.roleData.nation)
  self.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
  self.UIRoot.TextBlock_FriendsText:SetText(LocUtil.GetLocalizeResStr(4020))
  self.UIRoot.TextBlock_FriendsText:SetColorAndOpacity(FSlateColor(FLinearColor(0.023, 0.888, 1, 1)))
end
function Personalization_Nickname_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData) or not itemData.ID then
    return false
  end
  return itemData.ID == self.jumpSelectItemId
end
function Personalization_Nickname_UIBP:InitCurrency()
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    local currency_cfg = CDataTable.GetTableData("Item", self.C_Currency_ID)
    roleInfo_main:SetTexture(roleInfo_main.UIRoot.Image_3, currency_cfg.ItemSmallIcon, {sync = true})
  end
end
function Personalization_Nickname_UIBP:UpdateCurrencyCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local num = wardrobe_data:GetHallDepotItemCountByResID(self.C_Currency_ID)
  self.currency = num
  local roleInfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleInfo_main then
    roleInfo_main.UIRoot.TextBlock_0:SetText(num)
  end
end
function Personalization_Nickname_UIBP:OnButtonCurrency()
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
function Personalization_Nickname_UIBP:HandleLockedButton1()
  log(bWriteLog and "Personalization_Nickname_UIBP:HandleLockedButton1")
  self.select = 1
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_Nickname_UIBP:HandleLockedButton2()
  log(bWriteLog and "Personalization_Nickname_UIBP:HandleLockedButton2")
  self.select = 2
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_Nickname_UIBP:HandleLockedButton3()
  log(bWriteLog and "Personalization_Nickname_UIBP:HandleLockedButton3")
  self.select = 3
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_Nickname_UIBP:HandleButtonUpgrade()
  log(bWriteLog and "Personalization_Nickname_UIBP:HandleButtonUpgrade")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local curSelect = self.select
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItemData.ID)
  local UIUtil = require("client.common.ui_util")
  local cfg = UIUtil.GetItemCfg(itemData.ID)
  local needCurrency = upgradeCfg.Cost
  local msgData = {
    styleType = CommonMsgBoxMgr.SHOW_TYPE_TWO,
    msg = LocUtil.LocalizeResFormat(18010241, needCurrency, cfg.ItemName),
    title = LocUtil.GetLocalizeResStr(39012),
    clickOkCallback = function()
      local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
      self:AddPromise(PopularityPKHandler.send_psmatch_reward_upgrade_req(needItemData.ID)):Then(function(err_code, _, _)
        if err_code == 0 then
          local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
          RoleInfoHandler.send_get_friend_nickname_skin_req()
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
function Personalization_Nickname_UIBP:HandleButtonNoUpgrade()
  log(bWriteLog and "Personalization_Nickname_UIBP:HandleButtonNoUpgrade")
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  if needItemData.bIsLock then
    ShowNotice(18010243)
  else
    ShowNotice(18010242)
  end
end
function Personalization_Nickname_UIBP:GetLockedButtonStyleTable(itemDataList)
  local lockedButtonStyle = {
    bShow = false,
    button1 = {bShow = false, hasLock = true},
    button2 = {bShow = false, hasLock = true},
    button3 = {bShow = false, hasLock = true}
  }
  if itemDataList then
    lockedButtonStyle.bShow = true
    for _, v in ipairs(itemDataList) do
      local buttonName = "button" .. v.level
      lockedButtonStyle[buttonName].bShow = true
      if not v.bIsLock then
        lockedButtonStyle[buttonName].hasLock = false
      end
      lockedButtonStyle[buttonName].text = LocUtil.GetLocalizeResStr(18010254 + v.level)
    end
  end
  return lockedButtonStyle
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CLobby_RoleInfo_Nickname_UIBP = class(ui_base, nil, Personalization_Nickname_UIBP)
return CLobby_RoleInfo_Nickname_UIBP