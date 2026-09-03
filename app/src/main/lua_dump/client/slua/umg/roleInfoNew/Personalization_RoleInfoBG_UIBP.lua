local Personalization_RoleInfoBG_UIBP = {C_Currency_ID = 1703266}
function Personalization_RoleInfoBG_UIBP:ctor(_, _, _)
  self.bUIShow = true
  self.bButtonClick = false
  self.select = 0
  self.currency = 0
end
function Personalization_RoleInfoBG_UIBP:OnInitialize()
  Personalization_RoleInfoBG_UIBP.__super.OnInitialize(self)
  self.curLevelName = nil
end
function Personalization_RoleInfoBG_UIBP:RegistEvents()
  Personalization_RoleInfoBG_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_UPDATE, self.UpdateAll, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.UpdateCurrencyCount, self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    self:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_1, self.OnButtonHideClick, self)
    self:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_2, self.OnButtonReplayClick, self)
    self:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_3, self.OnButtonCurrency, self)
  end
  local ScreenInput = import("ScreenInput")
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  self.screenInput = ScreenInput(worldContextObject)
  self.screenInput:Init()
  self:AddControlEventByControl(self.screenInput, "OnMouseButtonUp", self.OnMouseButtonUp, self)
end
function Personalization_RoleInfoBG_UIBP:OnPostInitialize()
  Personalization_RoleInfoBG_UIBP.__super.OnPostInitialize(self)
  self:InitCurrency()
end
function Personalization_RoleInfoBG_UIBP:OnShow()
  Personalization_RoleInfoBG_UIBP.__super.OnShow(self)
  self.UIRoot.Text_Title:SetText(LocUtil.GetLocalizeResStr(62382))
  self.UIRoot.TextBlock_Tips:SetText(LocUtil.GetLocalizeResStr(24838))
  self.jumpSelectItemId = nil
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_1, true, true)
    local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
    if logic_roleInfo_background:HasHighLevelEffect() then
      roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_2, true, true)
    end
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_3, true, true)
  end
end
function Personalization_RoleInfoBG_UIBP:OnHide()
  Personalization_RoleInfoBG_UIBP.__super.OnHide(self)
  self:ShowUIExceptHideAndReplay(true)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_1, false)
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_2, false)
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_3, false, true)
  end
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:ClearHighLevelEffect()
end
function Personalization_RoleInfoBG_UIBP:OnClose()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UpdatePlayerEquipBGLevel(DataMgr.roleData.uid)
  Personalization_RoleInfoBG_UIBP.__super.OnClose(self)
end
function Personalization_RoleInfoBG_UIBP:IsLoadAvatarScene()
  return true
end
function Personalization_RoleInfoBG_UIBP:InitCurrency()
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    local currency_cfg = CDataTable.GetTableData("Item", self.C_Currency_ID)
    roleinfo_main:SetTexture(roleinfo_main.UIRoot.Image_3, currency_cfg.ItemSmallIcon, {sync = true})
  end
  self:UpdateCurrencyCount()
end
function Personalization_RoleInfoBG_UIBP:UpdateItemReddot(itemData, index)
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  if logic_roleInfo_background:HasRedDotByID(itemData.ID) then
    logic_roleInfo_background:ReadRedDot(itemData.ID)
  end
end
function Personalization_RoleInfoBG_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_RoleInfoBG_UIBP:GetItemList()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  local roleInfoBGList = logic_roleInfo_background:GetRoleInfoBGList()
  if not roleInfoBGList then
    log(bWriteLog and "Personalization_RoleInfoBG_UIBP:GetItemList nil carte frame list")
    return
  end
  local table_util = require("common.table_util")
  local i = 1
  while i <= #roleInfoBGList do
    if roleInfoBGList[i].Type and roleInfoBGList[i].Type ~= 0 then
      local itemList = {}
      local type = roleInfoBGList[i].Type
      local j = i
      while j <= #roleInfoBGList do
        if roleInfoBGList[j].Type == type then
          table.insert(itemList, roleInfoBGList[j])
          table.remove(roleInfoBGList, j)
        else
          j = j + 1
        end
      end
      table.sort(itemList, function(l, r)
        return l.Level < r.Level
      end)
      local item = table_util.CopyTable(itemList[1])
      item.SubList = itemList
      table.insert(roleInfoBGList, i, item)
    end
    i = i + 1
  end
  if self.isCheckOwned then
    local list = {}
    for _, v in ipairs(roleInfoBGList) do
      if logic_roleInfo_background:IsHaveRoleInfoBG(v.ID) then
        table.insert(list, v)
      end
    end
    return list
  end
  return roleInfoBGList
end
function Personalization_RoleInfoBG_UIBP:UpdateAll()
  self:RefreshItemGrid(1)
  self:UpdateCurrencyCount()
end
function Personalization_RoleInfoBG_UIBP:UpdateCurrencyCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local num = wardrobe_data:GetHallDepotItemCountByResID(self.C_Currency_ID)
  self.currency = num
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main.UIRoot.TextBlock_0:SetText(num)
  end
end
function Personalization_RoleInfoBG_UIBP:UpdateSelectedItemInfo(itemData)
  if not itemData then
    log(bWriteLog and "Personalization_RoleInfoBG_UIBP:UpdateSelectedItemInfo nil item data for right display")
    return
  end
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  local curSelectID = logic_roleInfo_background:GetSelfRoleInfoBGID()
  local defaultSkinID = logic_roleInfo_background:GetDefaultRoleInfoBGID()
  local loadedCallback = function(bgID)
    if not slua.isValid(self.UIRoot) then
      return
    end
    if not (self.curItemData and self.curItemData.itemID) or self.curItemData.itemID == bgID then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, false)
    end
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, true)
  local param = self:GenCommonItemParam()
  if itemData.SubList then
    param.lockedButtonStyle = self:GetLockedButtonStyleTable(itemData.SubList)
    param.lockedButtonStyle.select = self.select
    param.itemDataList = itemData.SubList
    param.selectItemData = self.select
    itemData = itemData.SubList[self.select]
  end
  param.itemID = itemData.ID
  param.name = itemData.RoleInfoBGName
  param.extraInfo = LocUtil.LocalizeResFormat(itemData.ObtainDescID)
  param.expireTime = logic_roleInfo_background:GetRoleInfoBGTime(itemData.ID)
  logic_roleInfo_background:UpdateRoleInfoBGByBGID(itemData.ID, loadedCallback)
  if logic_roleInfo_background:HasHighLevelEffect() then
    self:PlayEffect()
  else
    logic_roleInfo_background:ClearHighLevelEffect()
  end
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if logic_roleInfo_background:HasHighLevelEffect() then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_2, true, true)
  else
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_2, false)
  end
  if itemData.ID == defaultSkinID then
    param.expireTime = 0
    if curSelectID ~= defaultSkinID then
      param.buttonStyle = ENUM_Button_Style.Use
    else
      param.buttonStyle = ENUM_Button_Style.None
    end
  else
    local isHave = logic_roleInfo_background:IsHaveRoleInfoBG(itemData.ID)
    if isHave then
      if itemData.ID == curSelectID then
        param.buttonStyle = ENUM_Button_Style.Unload
      else
        param.buttonStyle = ENUM_Button_Style.Use
      end
    elseif param.itemDataList and param.selectItemData > 1 and logic_roleInfo_background:IsHaveRoleInfoBG(param.itemDataList[1].ID) then
      local needItem = param.itemDataList[param.selectItemData - 1]
      local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItem.ID)
      local needCurrency = upgradeCfg.Cost
      local locString = LocUtil.LocalizeResFormat(18010254, needCurrency)
      if logic_roleInfo_background:IsHaveRoleInfoBG(needItem.ID) and needCurrency <= self.currency then
        param.buttonStyle = ENUM_Button_Style.Upgrade
        self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_1:SetText(locString)
      else
        param.buttonStyle = ENUM_Button_Style.NoUpgrade
        self.UIRoot.Personalization_Desc_Item.UTRichTextBlock_2:SetText(locString)
      end
    elseif itemData.ObtainJumpLink and itemData.ObtainJumpLink ~= "" then
      param.buttonStyle = ENUM_Button_Style.Go
    else
      param.buttonStyle = ENUM_Button_Style.None
    end
  end
  if itemData then
    self:UpdateItemReddot(itemData)
  end
  return param
end
function Personalization_RoleInfoBG_UIBP:OnRefreshGridItem(widget, index)
  if not widget then
    log(bWriteLog and "Personalization_RoleInfoBG_UIBP:OnRefreshGridItem nil widget for index: " .. tostring(index))
    return
  end
  local itemData = self.ItemGrid:GetItemData(index)
  if not itemData then
    log(bWriteLog and "Personalization_RoleInfoBG_UIBP:OnRefreshGridItem nil item data for index: " .. tostring(index))
    return
  end
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  if itemData.ImagePath ~= "" then
    self:SetTexture(widget.Image_Frame, itemData.ImagePath)
    self:SetWidgetVisible(widget.Image_Frame, true)
  else
    self:SetWidgetVisible(widget.Image_Frame, false)
  end
  local isCurrentBG = logic_roleInfo_background:IsCurrentRoleInfoBG(itemData.ID)
  local bRed = logic_roleInfo_background:HasRedDotByID(itemData.ID)
  if itemData.SubList then
    for _, v in ipairs(itemData.SubList) do
      if logic_roleInfo_background:IsCurrentRoleInfoBG(v.ID) then
        isCurrentBG = true
      end
      if logic_roleInfo_background:HasRedDotByID(v.ID) then
        bRed = true
      end
    end
  end
  self:SetWidgetVisible(widget.Image_Select, index == self.ItemGrid:GetSelectIndex())
  self:SetWidgetVisible(widget.Image_Reddot, bRed)
  self:SetWidgetVisible(widget.Image_Using, isCurrentBG)
  local bHaveBG = logic_roleInfo_background:IsHaveRoleInfoBG(itemData.ID)
  self:SetWidgetVisible(widget.CanvasPanel_Lock, not bHaveBG)
  local showTime = logic_roleInfo_background:GetRoleInfoBGTime(itemData.ID)
  self:SetWidgetVisible(widget.Image_LimitedTime, showTime and 1 < showTime)
end
function Personalization_RoleInfoBG_UIBP:HandleButtonUse()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleButtonUse")
  local itemData = self.ItemGrid:GetItemData(self.ItemGrid:GetSelectIndex())
  if itemData.SubList then
    itemData = itemData.SubList[self.curSelectItemData]
  end
  if not itemData then
    log(bWriteLog and "Personalization_RoleInfoBG_UIBP nil item data: " .. tostring(self.ItemGrid:GetSelectIndex()))
    return
  end
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:send_set_social_info_bg_req(itemData.ID)
end
function Personalization_RoleInfoBG_UIBP:HandleButtonUnload()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleButtonUnload")
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:send_set_social_info_bg_req(logic_roleInfo_background:GetDefaultRoleInfoBGID())
end
function Personalization_RoleInfoBG_UIBP:HandleButtonGo()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleButtonGo")
  local itemData = self.ItemGrid:GetItemData(self.ItemGrid:GetSelectIndex())
  if itemData.SubList then
    itemData = itemData.SubList[self.curSelectItemData]
  end
  if not itemData then
    log(bWriteLog and "Personalization_RoleInfoBG_UIBP nil item data: " .. tostring(self.ItemGrid:GetSelectIndex()))
    return
  end
  if itemData.ObtainJumpLink and itemData.ObtainJumpLink ~= "" then
    local RoleInfoBigAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
    if RoleInfoBigAvatarSystem.IsShow() then
      RoleInfoBigAvatarSystem.CloseUI()
    end
    GlobalData.JumpUrl(itemData.ObtainJumpLink)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
  end
end
function Personalization_RoleInfoBG_UIBP:HandleClickedItem(widget, index)
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  local itemData = self.ItemGrid:GetItemData(index)
  if itemData.SubList then
    self.select = 1
    for _, v in ipairs(itemData.SubList) do
      if logic_roleInfo_background:IsHaveRoleInfoBG(v.ID) then
        self.select = v.Level
      end
      if v.ID == logic_roleInfo_background:GetSelfRoleInfoBGID() then
        break
      end
    end
  end
  return nil
end
function Personalization_RoleInfoBG_UIBP:HandleLockedButton1()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleLockedButton1")
  self.select = 1
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_RoleInfoBG_UIBP:HandleLockedButton2()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleLockedButton2")
  self.select = 2
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_RoleInfoBG_UIBP:HandleLockedButton3()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleLockedButton3")
  self.select = 3
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateItemPreview(itemData)
end
function Personalization_RoleInfoBG_UIBP:HandleButtonUpgrade()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleButtonUpgrade")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local curSelect = self.select
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  local upgradeCfg = CDataTable.GetTableData("PopularPKItemUpgradeConfig", needItemData.ID)
  local needCurrency = upgradeCfg.Cost
  local sMsg = LocUtil.LocalizeResFormat(18010241, needCurrency, itemData.RoleInfoBGName)
  local sTitle = LocUtil.GetLocalizeResStr(39012)
  local fClickOkCallback = function()
    local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
    self:AddPromise(PopularityPKHandler.send_psmatch_reward_upgrade_req(needItemData.ID)):Then(function(err_code, _, upgrade_item_id)
      if err_code == 0 then
        local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
        logic_roleInfo_background:send_set_social_info_bg_req(upgrade_item_id)
        self.select = curSelect
        self:UpdateItemPreview(itemData)
        ShowNotice(665020)
      else
      end
    end)
  end
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sMsg, fClickOkCallback)
end
function Personalization_RoleInfoBG_UIBP:HandleButtonNoUpgrade()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:HandleButtonNoUpgrade")
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  local needItemData = self.curItemDataList[self.curSelectItemData - 1]
  if not logic_roleInfo_background:IsHaveRoleInfoBG(needItemData.ID) then
    ShowNotice(18010243)
  else
    ShowNotice(18010242)
  end
end
function Personalization_RoleInfoBG_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData) or not itemData.ID then
    return false
  end
  return itemData.ID == self.jumpSelectItemId
end
function Personalization_RoleInfoBG_UIBP:OnButtonHideClick()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:OnButtonHideClick")
  self:PlayAudio(sound_config.click_v1)
  self.bUIShow = not self.bUIShow
  self:ShowUIExceptHideAndReplay(self.bUIShow)
  self.bButtonClick = true
end
function Personalization_RoleInfoBG_UIBP:OnButtonReplayClick()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:OnButtonReplayClick")
  self:PlayAudio(sound_config.click_v1)
  self:PlayEffect()
  self.bButtonClick = true
end
function Personalization_RoleInfoBG_UIBP:OnButtonCurrency()
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
function Personalization_RoleInfoBG_UIBP:OnMouseButtonUp()
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:OnMouseButtonUp")
  self:AddTimerOnce(0, function()
    if self.bButtonClick == true then
      self.bButtonClick = false
      return
    end
    if self.bUIShow == false then
      self.bUIShow = true
      self:ShowUIExceptHideAndReplay(self.bUIShow)
    end
  end)
end
function Personalization_RoleInfoBG_UIBP:ShowUIExceptHideAndReplay(bShow)
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:ShowUIExceptHideAndReplay: " .. tostring(bShow))
  self:SetWidgetVisible(self.UIRoot.Personalization_Desc_Item, bShow)
  self:SetWidgetVisible(self.UIRoot.Border_0, bShow)
  local Personalization_UIBP = UIManager.GetUI(UIManager.UI_Config.Personalization_UIBP)
  if Personalization_UIBP and Personalization_UIBP.UIRoot then
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Common_Tab_Vertical_LevelTwo_Icon_UIBP, bShow)
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Image_mask_1, bShow)
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Image_mask_2, bShow)
  end
  local Lobby_NewRoleInfo_Mgr_UIBP = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if Lobby_NewRoleInfo_Mgr_UIBP and Lobby_NewRoleInfo_Mgr_UIBP.UIRoot then
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.CanvasPanel_11, bShow)
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP, bShow)
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.Button_3, bShow, true)
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.Image_SideMask, bShow)
  end
end
function Personalization_RoleInfoBG_UIBP:PlayEffect(callback)
  log(bWriteLog and "Personalization_RoleInfoBG_UIBP:PlayEffect")
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:PlayHighLevelEffect(function()
    if callback then
      callback()
    end
  end)
end
function Personalization_RoleInfoBG_UIBP:GetLockedButtonStyleTable(itemDataList)
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
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
      if logic_roleInfo_background:IsHaveRoleInfoBG(v.ID) then
        lockedButtonStyle[buttonName].hasLock = false
      end
      lockedButtonStyle[buttonName].text = LocUtil.GetLocalizeResStr(18010254 + v.Level)
    end
  end
  return lockedButtonStyle
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CPersonalization_RoleInfoBG_UIBP = class(ui_base, nil, Personalization_RoleInfoBG_UIBP)
return CPersonalization_RoleInfoBG_UIBP