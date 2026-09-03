local Personalization_BaseItem_UIBP = {
  curItemID = 0,
  smallAvatar = nil,
  rankLevelComp = nil,
  nationImageComp = nil,
  nameText = nil,
  gridSwitcher = nil,
  sexComp = nil,
  ItemGrid = nil,
  ItemClickCtrlName = "",
  isCheckOwned = false,
  baseItemSelectIndex = -1,
  effectRoots = {},
  curItemData = nil,
  curItemDataList = nil,
  curSelectItemData = 1
}
local C_QualityNormalImage_Path = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Shop_image_jianbian_di02_png.Shop_image_jianbian_di02_png"
ENUM_Button_Style = {
  Use = 0,
  Using = 1,
  Go = 2,
  NoYet = 3,
  Unload = 4,
  GetWay = 5,
  Own = 6,
  Upgrade = 7,
  NoUpgrade = 8,
  None = 9
}
function Personalization_BaseItem_UIBP:ctor(_, selectItemId, type)
  self.jumpSelectItemId = selectItemId
  self.end
function Personalization_BaseItem_UIBP:OnInitialize()
  Personalization_BaseItem_UIBP.__super.OnInitialize(self)
  self.ItemClickCtrlName = ""
  self.baseItemSelectIndex = -1
  self:InitItemGrid()
  self:InitCommonAvatarComp()
end
function Personalization_BaseItem_UIBP:RegistEvents()
  Personalization_BaseItem_UIBP.__super.RegistEvents(self)
  local descRoot = self.UIRoot.Personalization_Desc_Item
  if descRoot then
    self:AddControlEventByControl(descRoot.Button_Use, "OnClicked", self.OnClickButtonUse, self)
    self:AddControlEventByControl(descRoot.Button_Using, "OnClicked", self.OnClickButtonUsing, self)
    self:AddControlEventByControl(descRoot.Button_Go, "OnClicked", self.OnClickButtonGo, self)
    self:AddControlEventByControl(descRoot.Button_NoYet, "OnClicked", self.OnClickButtonNotYet, self)
    self:AddControlEventByControl(descRoot.UseingButton, "OnClicked", self.OnClickButtonUnload, self)
    self:AddControlEventByControl(descRoot.Button_Share, "OnClicked", self.OnClickButtonShare, self)
    self:AddControlEventByControl(descRoot.Button_GetWay, "OnClicked", self.OnClickButtonGo, self)
    self:AddControlEventByControl(descRoot.Button_Upgrade, "OnClicked", self.OnClickButtonUpgrade, self)
    self:AddControlEventByControl(descRoot.Button_NoUpgrade, "OnClicked", self.OnClickButtonNoUpgrade, self)
    self:AddControlEventByControl(descRoot.Button_Switch, "OnClicked", self.OnDescTitleSwitch, self)
    self:AddControlEventByControl(descRoot.Button_1, "OnClicked", self.OnClickLockedButton1, self)
    self:AddControlEventByControl(descRoot.Button_upLevel_2, "OnClicked", self.OnClickLockedButton2, self)
    self:AddControlEventByControl(descRoot.Button_0, "OnClicked", self.OnClickLockedButton3, self)
  end
  if self.UIRoot.CheckBox_AlreadyOwned then
    self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_AlreadyOwned, self._OnOwnCheckChanged, self)
  end
  if self.ItemGrid then
    self.ItemGrid:SetRefreshItemCallback(self.OnRefreshGridItem, self)
    if self.ItemClickCtrlName == "" then
      self.ItemGrid:AddItemWidgetEvent(self.ItemClickCtrlName, "OnClickItem", self._OnClickedItem, self)
    else
      self.ItemGrid:AddItemWidgetChildEvent(self.ItemClickCtrlName, "OnClicked", self._OnClickedItem, self)
    end
    if self.UIRoot.ReturnTopBtn then
      self:AddOnClickedEventByControl(self.UIRoot.ReturnTopBtn, self._OnClickReturnTopBtn, self)
      self:AddControlEventByControl(self.ItemGrid.UIRoot, "OnUserScrolled", self._OnUserScrolled, self)
    end
  end
end
function Personalization_BaseItem_UIBP:OnPostInitialize()
  Personalization_BaseItem_UIBP.__super.OnPostInitialize(self)
  self:_CommonUILogic()
  if self._parentUI.playFadein and self.UIRoot.Fadein then
    self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
  elseif not self._parentUI.playFadein and self.UIRoot.Anim_Select then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Select, 0, 1, 0, 1)
  end
end
function Personalization_BaseItem_UIBP:OnShow()
  Personalization_BaseItem_UIBP.__super.OnShow()
  self:SetWidgetVisible(self.UIRoot.ReturnTopBtn, false, true)
  self.isCheckOwned = false
  if self.UIRoot.CheckBox_AlreadyOwned then
    self.UIRoot.CheckBox_AlreadyOwned:SetCheckedState(0)
  end
  self:RefreshItemGrid()
end
function Personalization_BaseItem_UIBP:_CommonUILogic()
  local titleLeft, titleRight = self:GetDescTitleInfo()
  self:SetDescAndButtonVisible(false)
  if titleLeft then
    self:SetDescTitleTabVisible(true)
    self:UpdateDescTitleTab(titleLeft, titleRight)
  else
    self:SetDescTitleTabVisible(false)
  end
  self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(6477))
  local descRoot = self.UIRoot.Personalization_Desc_Item
  if descRoot then
    if descRoot.TextBlock_13 then
      descRoot.TextBlock_13:SetText(LocUtil.GetLocalizeResStr(6430))
    end
    if descRoot.TextBlock_16 then
      descRoot.TextBlock_16:SetText(LocUtil.GetLocalizeResStr(35224))
    end
    if descRoot.Button_ToUpgrade then
      self:SetWidgetVisible(descRoot.Button_ToUpgrade, false)
    end
    if descRoot.LightBoard_Level then
      self:SetWidgetVisible(descRoot.LightBoard_Level, false)
    end
  end
  local isShowAvatar = self:IsLoadAvatarScene()
  local parent = self._parentUI
  if parent then
    if isShowAvatar then
      parent:LoadAvatarScene()
      local uObj_widget = self:GetAvatarFrameWidget()
      parent:ReqAvatarShowInfo(uObj_widget)
    else
      if parent.SetAvatarAdaptWidget then
        parent:SetAvatarAdaptWidget(nil)
      end
      parent:SetPanelBgVisible(true)
    end
  end
  if self:IsNeedUpdatePlayerInfo() then
    self:UpdatePlayerInfo()
  end
end
function Personalization_BaseItem_UIBP:GetAvatarFrameWidget()
  if self._parentUI and self._parentUI.UIRoot and self._parentUI.UIRoot.CanvasPanel_Center then
    return self._parentUI.UIRoot.CanvasPanel_Center
  end
  if self.UIRoot.CanvasPanel_Preview then
    return self.UIRoot.CanvasPanel_Preview:GetParent()
  end
  return nil
end
function Personalization_BaseItem_UIBP:UpdatePlayerInfo()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local profile = LobbySocialSystem.GetProfileByUID(RoleInfoSystem.CurShowPlayerInfoUid)
  if not profile then
    if self.nameText then
      self.nameText:SetText("")
    end
    log(bWriteLog and "[BaseItem:UpdatePlayerInfo] nil profile")
    return nil
  end
  if self.smallAvatar then
    self.smallAvatar:InitView(1, profile.uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
    self.smallAvatar:SetButtonEnabled(false)
  end
  if self.UIRoot.SizeBox_Segment then
    self:SetWidgetVisible(self.UIRoot.SizeBox_Segment, true)
  end
  if self.rankLevelComp then
    self.rankLevelComp:SetRankInteral(FuncUtil.GetCurMaxSegementLevel(profile.segment_info))
  end
  self:HandleNationFlag(self.nationImageComp, profile.nation)
  if self.nameText then
    self.nameText:SetText(profile.nickName or "")
  end
  if self.sexComp then
    self.sexComp:LoadIcon(profile.uid)
  end
  if self.UIRoot.Pround_Level_Icon_UIBP then
    self.UIRoot.Pround_Level_Icon_UIBP:SetData(profile.uid)
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local popularityLevel = RoleInfoPopularitySystem.GetPopularityLevelByExp(profile.total_devote)
  if self.UIRoot.Popularity_Level_Icon_UIBP then
    self.UIRoot.Popularity_Level_Icon_UIBP:SetData(popularityLevel)
  end
  return profile
end
function Personalization_BaseItem_UIBP:HandleNationFlag(comp, nation)
  if comp then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
      self:SetWidgetVisible(comp, true)
      local UIUtil = require("client.common.ui_util")
      UIUtil.UpdateNationImage(comp, nation)
    else
      self:SetWidgetVisible(comp, false)
    end
  end
end
function Personalization_BaseItem_UIBP:_OnOwnCheckChanged(check, skipSound)
  if not skipSound then
    self:PlayAudio(sound_config.click)
  end
  self.isCheckOwned = check
  self:HandleOwnCheckChange(check)
  self:RefreshItemGrid()
end
function Personalization_BaseItem_UIBP:RefreshItemGrid(selectIndex)
  local itemData = self:GetItemList()
  log_tree(bWriteLog and "Personalization_BaseItem_UIBP:RefreshItemGrid itemData:", itemData)
  local isEmpty = itemData == nil or next(itemData) == nil
  if self.gridSwitcher then
    if isEmpty then
      self.gridSwitcher:SetActiveWidgetIndex(1)
    else
      self.gridSwitcher:SetActiveWidgetIndex(0)
    end
  end
  self:SetPreviewPanelVisible(false)
  if not self.ItemGrid then
    return
  end
  self.baseItemSelectIndex = -1
  self.ItemGrid:SetData(itemData)
  if isEmpty then
    self:OnRefreshEmpty()
    return
  end
  if selectIndex and 0 < selectIndex and selectIndex <= #itemData then
    self:JumpAndSelectItem(selectIndex)
    return
  end
  local index = 1
  for i, v in ipairs(itemData) do
    if self:IsJumpSelectItem(v) then
      log(bWriteLog and "Personalization_BaseItem_UIBP:RefreshItemGrid IsJumpSelectItem index:" .. tostring(i) .. " jumpSelectItemId:" .. tostring(self.jumpSelectItemId))
      index = i
      break
    end
    if self:IsUsingItem(v) then
      index = i
    end
  end
  self:JumpAndSelectItem(index)
end
function Personalization_BaseItem_UIBP:JumpAndSelectItem(index)
  self:SetPreviewPanelVisible(true)
  if self.baseItemSelectIndex == index then
    return
  end
  log(bWriteLog and "Personalization_BaseItem_UIBP JumpAndSelectItem index:" .. tostring(index))
  self.baseItemSelectIndex = index
  self:HandleClickedItem(nil, index)
  self:UpdateItemPreview(self.ItemGrid:GetItemData(index))
  self.ItemGrid:ScrollToItem(index)
  self.ItemGrid:Select(index)
  self:AddTimerOnce(0.01, function()
    if slua.isValid(self.UIRoot.ReturnTopBtn) then
      self:SetWidgetVisible(self.UIRoot.ReturnTopBtn, self.ItemGrid:GetItemOffset() > 10, true)
    end
  end)
end
function Personalization_BaseItem_UIBP:_OnClickedItem(widget, index)
  self:PlayAudio(sound_config.click)
  log(bWriteLog and "[BaseItem:_OnClickedItem] index = " .. tostring(index) .. " preIndex = " .. self.baseItemSelectIndex)
  local itemData = self.ItemGrid:GetItemData(index)
  if itemData == nil then
    log(bWriteLog and "[BaseItem:_OnClickedItem] itemData = nil")
  end
  self.jumpSelectItemId = nil
  local needUpdate = itemData and self:UpdateItemReddot(itemData, index)
  if self.baseItemSelectIndex == index then
    if needUpdate then
      self.ItemGrid:RefreshItem(index, itemData)
    end
    return
  end
  self.baseItemSelectIndex = index
  self:HandleClickedItem(widget, index)
  self.ItemGrid:Select(index)
  self:UpdateItemPreview(itemData)
end
function Personalization_BaseItem_UIBP:UpdateItemPreview(itemData)
  log_tree("Personalization_BaseItem_UIBP:UpdateItemPreview, itemData = ", itemData)
  local param = self:UpdateSelectedItemInfo(itemData)
  self:_UpdateCommonItemParam(param)
end
function Personalization_BaseItem_UIBP:_UpdateCommonItemParam(param)
  if param == nil then
    self:SetPreviewPanelVisible(false)
    return
  end
  self.curItemData = param
  if param.itemDataList and param.selectItemData then
    self.curItemDataList = param.itemDataList
    self.curItemData = param.itemDataList[param.selectItemData]
    self.curSelectItemData = param.selectItemData
  end
  self:SetPreviewPanelVisible(true)
  self:UpdateItem(param.name, param.desc, param.expireTime, param.extraInfo, param.itemID)
  self:SetButtonStyle(param.buttonStyle)
  self:SetLockedButtonStyle(param.lockedButtonStyle)
  local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
  local ENUM_Type = PersonalizationConst.ENUM_Type
  if self.type == ENUM_Type.Alias and (param.buttonStyle == ENUM_Button_Style.Use or param.buttonStyle == ENUM_Button_Style.Unload) then
    self:SetWidgetVisible(self.UIRoot.Personalization_Desc_Item.Button_Share, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Personalization_Desc_Item.Button_Share, false)
  end
end
function Personalization_BaseItem_UIBP:GenCommonItemParam()
  local updateParam = {
    name = "",
    desc = "",
    expireTime = nil,
    buttonStyle = ENUM_Button_Style.None,
    itemID = 0,
    lockedButtonStyle = {bShow = false}
  }
  return updateParam
end
function Personalization_BaseItem_UIBP:_OnClickReturnTopBtn()
  self:PlayAudio(sound_config.click_v1)
  self.ItemGrid.UIRoot:StopScroll()
  self.ItemGrid.UIRoot:ScrollToStart()
  self.ItemGrid.UIRoot:UserScrolled(0)
  self:SetWidgetVisible(self.UIRoot.ReturnTopBtn, false, true)
end
function Personalization_BaseItem_UIBP:_OnUserScrolled(offset)
  self:SetWidgetVisible(self.UIRoot.ReturnTopBtn, 10 < offset, true)
end
function Personalization_BaseItem_UIBP:OnClickButtonUse()
  if not self.curItemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonUse(self.curItemData)
end
function Personalization_BaseItem_UIBP:OnClickButtonGo()
  if not self.curItemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonGo(self.curItemData)
end
function Personalization_BaseItem_UIBP:OnClickButtonUpgrade()
  if not self.curItemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonUpgrade(self.curItemData)
end
function Personalization_BaseItem_UIBP:OnClickButtonNoUpgrade()
  if not self.curItemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonNoUpgrade(self.curItemData)
end
function Personalization_BaseItem_UIBP:OnClickButtonUsing()
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonUsing()
end
function Personalization_BaseItem_UIBP:OnClickButtonNotYet()
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonNotYet()
end
function Personalization_BaseItem_UIBP:OnClickButtonUnload()
  if not self.curItemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonUnload(self.curItemData)
end
function Personalization_BaseItem_UIBP:OnClickButtonShare()
  if not self.curItemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:HandleButtonShare(self.curItemData)
end
function Personalization_BaseItem_UIBP:OnDescTitleSwitch()
  self:PlayAudio(sound_config.click_v1)
  local newTabIndex = 1
  if self._titleTab == 1 then
    newTabIndex = 0
  end
  self:SetTitleTabIndex(newTabIndex)
end
function Personalization_BaseItem_UIBP:OnClickLockedButton1()
  self:PlayAudio(sound_config.click_v1)
  self:HandleLockedButton1()
end
function Personalization_BaseItem_UIBP:OnClickLockedButton2()
  self:PlayAudio(sound_config.click_v1)
  self:HandleLockedButton2()
end
function Personalization_BaseItem_UIBP:OnClickLockedButton3()
  self:PlayAudio(sound_config.click_v1)
  self:HandleLockedButton3()
end
function Personalization_BaseItem_UIBP:SetTitleTabIndex(index)
  self._titleTab = index
  if self.UIRoot.Personalization_Desc_Item and self.UIRoot.Personalization_Desc_Item.WidgetSwitcher_0 then
    self.UIRoot.Personalization_Desc_Item.WidgetSwitcher_0:SetActiveWidgetIndex(index)
  end
  self:OnTitleTabChanged(index)
end
function Personalization_BaseItem_UIBP:SetButtonStyle(buttonStyle)
  local root = self.UIRoot.Personalization_Desc_Item
  if not slua.isValid(root) then
    return
  end
  if buttonStyle == ENUM_Button_Style.None then
    self:SetWidgetVisible(root.SizeBox_3, false)
    return
  end
  self:SetWidgetVisible(root.SizeBox_3, true)
  root.WidgetSwitcher_Button:SetActiveWidgetIndex(buttonStyle)
end
function Personalization_BaseItem_UIBP:SetLockedButtonStyle(buttonStyleTable)
  if buttonStyleTable == nil then
    return
  end
  local root = self.UIRoot.Personalization_Desc_Item
  local rootCanvas = root.CanvasPanel_upLevel
  local canvas1 = root.CanvasPanel_upLevel_1
  local canvas2 = root.CanvasPanel_upLevel_2
  local canvas3 = root.CanvasPanel_upLevel_3
  local button1WidgetSwitcher = root.WidgetSwitcher_3
  local button1LightLockImage = root.Image_39
  local button1LightText = root.TextBlock_24
  local button1DarkLockImage = root.Image_40
  local button1DarkText = root.TextBlock_25
  local button2WidgetSwitcher = root.SwitcherUplevel_2
  local button2LightLockImage = root.Image_SuitGlideLevel_2
  local button2LightText = root.TextBlock_upLevel_2
  local button2DarkLockImage = root.Image_32
  local button2DarkText = root.TextBlock_21
  local button3WidgetSwitcher = root.WidgetSwitcher_2
  local button3LightLockImage = root.Image_35
  local button3LightText = root.TextBlock_22
  local button3DarkLockImage = root.Image_36
  local button3DarkText = root.TextBlock_23
  if buttonStyleTable.bShow ~= nil then
    self:SetWidgetVisible(rootCanvas, buttonStyleTable.bShow)
  end
  if buttonStyleTable.select then
    if buttonStyleTable.select == 1 then
      button1WidgetSwitcher:SetActiveWidgetIndex(0)
    else
      button1WidgetSwitcher:SetActiveWidgetIndex(1)
    end
    if buttonStyleTable.select == 2 then
      button2WidgetSwitcher:SetActiveWidgetIndex(0)
    else
      button2WidgetSwitcher:SetActiveWidgetIndex(1)
    end
    if buttonStyleTable.select == 3 then
      button3WidgetSwitcher:SetActiveWidgetIndex(0)
    else
      button3WidgetSwitcher:SetActiveWidgetIndex(1)
    end
  end
  if buttonStyleTable.button1 then
    if buttonStyleTable.button1.bShow ~= nil then
      self:SetWidgetVisible(canvas1, buttonStyleTable.button1.bShow)
    end
    if buttonStyleTable.button1.hasLock ~= nil then
      self:SetWidgetVisible(button1LightLockImage, buttonStyleTable.button1.hasLock)
      self:SetWidgetVisible(button1DarkLockImage, buttonStyleTable.button1.hasLock)
    end
    if buttonStyleTable.button1.text then
      button1LightText:SetText(buttonStyleTable.button1.text)
      button1DarkText:SetText(buttonStyleTable.button1.text)
    end
  end
  if buttonStyleTable.button2 then
    if buttonStyleTable.button2.bShow ~= nil then
      self:SetWidgetVisible(canvas2, buttonStyleTable.button2.bShow)
    end
    if buttonStyleTable.button2.hasLock ~= nil then
      self:SetWidgetVisible(button2LightLockImage, buttonStyleTable.button2.hasLock)
      self:SetWidgetVisible(button2DarkLockImage, buttonStyleTable.button2.hasLock)
    end
    if buttonStyleTable.button2.text then
      button2LightText:SetText(buttonStyleTable.button2.text)
      button2DarkText:SetText(buttonStyleTable.button2.text)
    end
  end
  if buttonStyleTable.button3 then
    if buttonStyleTable.button3.bShow ~= nil then
      self:SetWidgetVisible(canvas3, buttonStyleTable.button3.bShow)
    end
    if buttonStyleTable.button3.hasLock ~= nil then
      self:SetWidgetVisible(button3LightLockImage, buttonStyleTable.button3.hasLock)
      self:SetWidgetVisible(button3DarkLockImage, buttonStyleTable.button3.hasLock)
    end
    if buttonStyleTable.button3.text then
      button3LightText:SetText(buttonStyleTable.button3.text)
      button3DarkText:SetText(buttonStyleTable.button3.text)
    end
  end
end
function Personalization_BaseItem_UIBP:SetDescTitleTabVisible(visible)
  if self.UIRoot.Personalization_Desc_Item then
    self:SetWidgetVisible(self.UIRoot.Personalization_Desc_Item.CanvasPanel_TitleTab, visible, false)
  end
end
function Personalization_BaseItem_UIBP:SetDescAndButtonVisible(visible)
  if self.UIRoot.Personalization_Desc_Item then
    self:SetWidgetVisible(self.UIRoot.Personalization_Desc_Item.NameAndDesc, visible, false)
  end
end
function Personalization_BaseItem_UIBP:SetPreviewPanelVisible(visible)
  if self.UIRoot.CanvasPanel_Preview then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Preview, visible)
  end
  self:SetDescAndButtonVisible(visible)
end
function Personalization_BaseItem_UIBP:UpdateDescTitleTab(titleLeft, titleRight)
  local descRoot = self.UIRoot.Personalization_Desc_Item
  if descRoot then
    descRoot.Text_1:SetText(titleLeft)
    descRoot.Text_3:SetText(titleLeft)
    descRoot.Text_2:SetText(titleRight)
    descRoot.Text_4:SetText(titleRight)
  end
  self:SetDescTitleTabVisible(true)
  self:SetTitleTabIndex(0)
end
function Personalization_BaseItem_UIBP:OnClose()
  self:ClearAllEffectSkin()
  if self.FeatureComp then
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.Destroy()
    self.FeatureComp:StopAllFeature()
    self.FeatureComp:Close()
    self.FeatureComp = nil
  end
  Personalization_BaseItem_UIBP.__super.OnClose(self)
end
function Personalization_BaseItem_UIBP:ClearAllEffectSkin()
  for k, v in pairs(self.effectRoots) do
    if v and slua.isValid(v) then
      v:Close()
      self.effectRoots[k] = nil
    end
  end
  self.effectRoots = {}
end
function Personalization_BaseItem_UIBP:AddEffectSkin(bgPath, parentRoot, aniName)
  local logic_roleinfo_personalization_util = require("client.logic.roleinfo.logic_roleinfo_personalization_util")
  local child = logic_roleinfo_personalization_util.AddEffectSkin(self, bgPath, parentRoot, aniName)
  return child
end
function Personalization_BaseItem_UIBP:AddEffectSkinByCreateChildWindow(bgPath, parentPanel, aniName, extraData)
  local logic_roleinfo_personalization_util = require("client.logic.roleinfo.logic_roleinfo_personalization_util")
  local child = logic_roleinfo_personalization_util.AddEffectSkinByCreateChildWindow(self, bgPath, parentPanel, aniName, extraData)
  if child == nil then
    self:AddDownloadResPath(bgPath)
  end
  return child
end
function Personalization_BaseItem_UIBP:UpdateItem(name, desc, expireTime, extraInfo, itemID)
  log(bWriteLog and string.format("BaseItem_UIBP:UpdateItem %s, %s, %s, %s, %s", tostring(name), tostring(desc), tostring(expireTime), tostring(extraInfo), tostring(itemID)))
  local root = self.UIRoot.Personalization_Desc_Item
  if not slua.isValid(root) then
    return
  end
  root.UTRichTextBlock_0:SetText(name)
  if not desc or desc == "" then
    self:SetWidgetVisible(root.UTRichTextBlockGet, false)
  else
    self:SetWidgetVisible(root.UTRichTextBlockGet, true)
    root.UTRichTextBlockGet:SetText(desc)
  end
  local str
  if type(expireTime) == "number" then
    local TimeUtil = require("client.common.time_util")
    if expireTime <= 1 then
      self:SetWidgetVisible(root.TextBlock_Time, false, false)
    else
      str = TimeUtil.FormatCountDownTime_DH_or_HM(expireTime - TimeUtil.GetServerTimeInSec(), true)
      local pre_title = LocUtil.GetLocalizeResStr(301299)
      str = LocUtil.LocalizeResFormat(6823, pre_title, str)
      root.TextBlock_Time:SetText(str)
      self:SetWidgetVisible(root.TextBlock_Time, true, false)
    end
  elseif type(expireTime) == "string" then
    str = expireTime
    if str ~= nil and str ~= "" then
      root.TextBlock_Time:SetText(str)
      self:SetWidgetVisible(root.TextBlock_Time, true, false)
    else
      self:SetWidgetVisible(root.TextBlock_Time, false, false)
    end
  else
    self:SetWidgetVisible(root.TextBlock_Time, false, false)
  end
  if extraInfo == nil or extraInfo == "" then
    self:SetWidgetVisible(root.TextBlock_GetTime, false, false)
  else
    root.TextBlock_GetTime:SetText(extraInfo)
    self:SetWidgetVisible(root.TextBlock_GetTime, true, false)
  end
  local quarity = 0
  if itemID and 0 < itemID then
    local config = CDataTable.GetTableData("Item", itemID)
    if config then
      quarity = config.ItemQuality
    end
  end
  local GlobalUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
  local UIUtil = require("client.common.ui_util")
  local qualityComp = root.Image_BigAwardQuality
  local path = C_QualityNormalImage_Path
  if quarity and 3 <= quarity then
    path = UIUtil.GetLeftBarQualityPath(quarity)
  end
  local brush = GlobalUIFunctionLibrary.GetBrushFromSprite(qualityComp.Brush, path, self.UIRoot)
  qualityComp:SetBrush(brush)
  if not self.FeatureComp then
    self.FeatureComp = self:CreateChildWindow(root.HorizontalBox_Property, UIManager.UI_Config.FeatureComponent)
  end
  local cfg = CDataTable.GetTableData("Item", itemID)
  local featuresItem = CDataTable.GetTableData("FeaturesItems", itemID)
  if cfg and featuresItem then
    self.FeatureComp:SetFeatures(itemID, cfg.itemType, cfg.itemSubType, {
      [itemID] = featuresItem
    })
    self:SetWidgetVisible(self.FeatureComp, true)
  else
    self.FeatureComp:StopAllFeature()
    self:SetWidgetVisible(self.FeatureComp, false)
  end
end
function Personalization_BaseItem_UIBP:IsHasFeature(aliasID, featureType)
  local aliasCfg = CDataTable.GetTableData("FeaturesItems", aliasID)
  if aliasCfg then
    local StringUtil = require("common.string_util")
    local features = StringUtil.Split(aliasCfg.Features, ";")
    for _, featureID in ipairs(features) do
      local featureCfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID))
      if featureCfg and featureCfg.FeatureType == featureType then
        return true
      end
    end
  end
  return false
end
function Personalization_BaseItem_UIBP:HandleButtonUsing()
  ShowNotice(62161)
end
function Personalization_BaseItem_UIBP:HandleButtonNotYet()
  ShowNotice(6430)
end
function Personalization_BaseItem_UIBP:OnLevelTabChanged(lvTab)
end
function Personalization_BaseItem_UIBP:InitItemGrid()
end
function Personalization_BaseItem_UIBP:GetItemList()
  return nil
end
function Personalization_BaseItem_UIBP:OnRefreshGridItem(widget, index)
end
function Personalization_BaseItem_UIBP:UpdateItemReddot(itemData, index)
  return false
end
function Personalization_BaseItem_UIBP:UpdateSelectedItemInfo(itemData)
  return nil
end
function Personalization_BaseItem_UIBP:HandleOwnCheckChange()
  self.jumpSelectItemId = nil
end
function Personalization_BaseItem_UIBP:HandleButtonUse(curItemData)
end
function Personalization_BaseItem_UIBP:HandleButtonGo(curItemData)
end
function Personalization_BaseItem_UIBP:HandleButtonUpgrade(curItemData)
end
function Personalization_BaseItem_UIBP:HandleButtonNoUpgrade(curItemData)
end
function Personalization_BaseItem_UIBP:HandleButtonUnload(curItemData)
end
function Personalization_BaseItem_UIBP:HandleButtonShare(curItemData)
end
function Personalization_BaseItem_UIBP:HandleLockedButton1()
end
function Personalization_BaseItem_UIBP:HandleLockedButton2()
end
function Personalization_BaseItem_UIBP:HandleLockedButton3()
end
function Personalization_BaseItem_UIBP:InitCommonAvatarComp()
  self.smallAvatar = self.UIRoot.Common_Avatar_BP_C_1
  self.rankLevelComp = self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP
  self.nationImageComp = self.UIRoot.Image_flag
  self.nameText = self.UIRoot.Text_Name
  self.gridSwitcher = self.UIRoot.WidgetSwitcher_States
  self.sexComp = self.UIRoot.Common_Gender_UIBP
end
function Personalization_BaseItem_UIBP:IsJumpSelectItem(itemData)
  return false
end
function Personalization_BaseItem_UIBP:IsUsingItem(itemData)
  return false
end
function Personalization_BaseItem_UIBP:HandleClickedItem(widget, index)
  return nil
end
function Personalization_BaseItem_UIBP:GetDescTitleInfo()
  return nil, nil
end
function Personalization_BaseItem_UIBP:IsLoadAvatarScene()
  return false
end
function Personalization_BaseItem_UIBP:IsNeedUpdatePlayerInfo()
  return not self:IsLoadAvatarScene()
end
function Personalization_BaseItem_UIBP:IsShowLevelTab()
  return false
end
function Personalization_BaseItem_UIBP:OnTitleTabChanged(titleTab)
end
function Personalization_BaseItem_UIBP:OnRefreshEmpty()
end
function Personalization_BaseItem_UIBP:HandlePakDownloaded(pakName)
  log_format("Personalization_BaseItem_UIBP:HandlePakDownloaded. pakName=%s", pakName)
  self.ItemGrid:RefreshAllItems()
  local item_data = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  self:UpdateSelectedItemInfo(item_data)
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_Base_Preview_UIBP")
local CUITemplate = class(ui_base, nil, Personalization_BaseItem_UIBP)
return CUITemplate