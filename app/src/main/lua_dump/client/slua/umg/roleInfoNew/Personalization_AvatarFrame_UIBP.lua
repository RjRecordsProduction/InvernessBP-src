local Personalization_AvatarFrame_UIBP = {}
local _comboBoxTypeMap = {Time = 0, Quality = 1}
function Personalization_AvatarFrame_UIBP:ctor(_, jumpSelectItemId)
  self.jumpUrl = ""
  self.selectedItemID = 0
end
function Personalization_AvatarFrame_UIBP:OnInitialize()
  Personalization_AvatarFrame_UIBP.__super.OnInitialize(self)
  self.ComboBoxTimeItemTable = {}
  self.ComboBoxQualityItemTable = {}
  self.CurComboBoxTimeIndex  self.CurComboBoxQualityIndex  self.LoopScrollBoxTimeDataTable = {}
  self.LoopScrollBoxQualityDataTable = {}
  self.CurrLoopScrollBoxTimeSelectedTable = {}
  self.CurrLoopScrollBoxQualitySelectedTable = {}
  self.ComboBox_Time = nil
  self.Common_ComboBox_Quality = nil
  self.LoopScrollGrid_DropDown1_Time = self:InitScrollBox(self.UIRoot.LoopScrollGrid_DropDown1_1)
  self.LoopScrollGrid_DropDown1_Quality = self:InitScrollBox(self.UIRoot.LoopScrollGrid_DropDown1_2)
end
function Personalization_AvatarFrame_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_FrameGrid)
end
function Personalization_AvatarFrame_UIBP:RegistEvents()
  Personalization_AvatarFrame_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DropDown1, self.OnClickButtonDropDown, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickButtonClose, self)
  self.LoopScrollGrid_DropDown1_Time:SetRefreshItemCallback(self.OnRefreshDropDownTimeLoopScrollGrid, self)
  self.LoopScrollGrid_DropDown1_Time:AddItemWidgetChildEvent("Button_Select", "OnClicked", self.OnSelectDropDownTime, self)
  self.LoopScrollGrid_DropDown1_Quality:SetRefreshItemCallback(self.OnRefreshDropDownQualityLoopScrollGrid, self)
  self.LoopScrollGrid_DropDown1_Quality:AddItemWidgetChildEvent("Button_Select", "OnClicked", self.OnSelectDropDownQuality, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_FRAME_INFO, self.OnAvatarFrameInfoUpdate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_AVATAR, self.UpdateLobbyAvatar, self)
end
function Personalization_AvatarFrame_UIBP:OnPostInitialize()
  Personalization_AvatarFrame_UIBP.__super.OnPostInitialize(self)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  self.selectedItemID = DataMgr.roleData.cur_avatar_box_id
  self.UIRoot.TextBlock_DropDown1:SetText(LocUtil.GetLocalizeResStr(199437))
  self.UIRoot.TextBlock_DropDown1_1:SetText(LocUtil.GetLocalizeResStr(18010236))
  self.UIRoot.TextBlock_DropDown1_2:SetText(LocUtil.GetLocalizeResStr(12072))
  self:SetAvatarFrameLoopScrollGridDropDown1Time()
  self:SetAvatarFrameLoopScrollGridDropDown1Quality()
end
function Personalization_AvatarFrame_UIBP:OnHide()
  self:SetDropDown1Visibility(false)
  Personalization_AvatarFrame_UIBP.__super.OnHide(self)
end
function Personalization_AvatarFrame_UIBP:OnClose()
  Personalization_AvatarFrame_UIBP.__super.OnClose(self)
end
function Personalization_AvatarFrame_UIBP:UpdateSelectedItemInfo(itemData)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  local selectedItemData = itemData
  if self.selectedItemID then
    self.UIRoot.Common_Avatar_BP:InitView(3, DataMgr.roleData.uid, DataMgr.roleData.headIconUrl, 0, self.selectedItemID)
    self.smallAvatar:InitView(3, DataMgr.roleData.uid, DataMgr.roleData.headIconUrl, 0, self.selectedItemID)
    self.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
  end
  if selectedItemData == nil then
    return
  end
  if not selectedItemData or not next(selectedItemData) then
    self:SetDescAndButtonVisible(false)
    return
  end
  self:SetDescAndButtonVisible(true)
  local param = self:GenCommonItemParam()
  param.itemID = self.selectedItemID
  param.name = selectedItemData.name or ""
  param.desc = selectedItemData.desc or ""
  local itemState = selectedItemData.state
  if itemState == RoleInfoAvatarFrameSystem.ENUM_State.None then
    if selectedItemData.desc_get and selectedItemData.desc_get ~= "" then
      param.buttonStyle = self.jumpUrl and self.jumpUrl ~= "" and ENUM_Button_Style.Go or ENUM_Button_Style.None
      param.extraInfo = selectedItemData.desc_get
    else
      param.buttonStyle = ENUM_Button_Style.NoYet
    end
  elseif itemState == RoleInfoAvatarFrameSystem.ENUM_State.Use then
    param.buttonStyle = ENUM_Button_Style.Using
  elseif itemState == RoleInfoAvatarFrameSystem.ENUM_State.Has then
    param.buttonStyle = ENUM_Button_Style.Use
  end
  param.expireTime = selectedItemData.expire_time
  return param
end
function Personalization_AvatarFrame_UIBP:SetAvatarFrameComboBoxTime()
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:SetAvatarFrameComboBox"))
  local timeDataCDataTable = CDataTable.GetTable("AvatarFrameTimeFilter")
  self.ComboBoxTimeItemTable = {}
  for k, v in pairs(timeDataCDataTable) do
    local item = {
      type = _comboBoxTypeMap.Time,
      index0 = v.id - 1,
      str = v.TimeFilterTitle
    }
    table.insert(self.ComboBoxTimeItemTable, item)
  end
  self.ComboBox_Time = self:InitCustomComboBox(self.UIRoot.ComboBox_Time)
  self.ComboBox_Time:SetRefreshOptionCallback(self.OnRefreshComboBoxItem, self)
  self.ComboBox_Time:SetSelectOptionCallback(self.OnSelectComboBoxItem, self)
  self.ComboBox_Time:AddControlEventByControl(self.ComboBox_Time.UIRoot, "OnOpening", self.OnBoxOpening, self)
  self.ComboBox_Time:SetData(self.ComboBoxTimeItemTable)
  self.ComboBox_Time:SelectIndex(self.CurComboBoxTimeIndex0 + 1)
end
function Personalization_AvatarFrame_UIBP:SetAvatarFrameComboBoxQuality()
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:SetAvatarFrameComboBoxQuality"))
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local qualityDataCDataTable = CDataTable.GetTable("AvatarFrameQualityFilter")
  self.ComboBoxQualityItemTable = {}
  for k, v in pairs(qualityDataCDataTable) do
    local item = {
      type = _comboBoxTypeMap.Quality,
      index0 = v.id - 1,
      quality = v.Quality,
      str = v.QualityFilterTitle
    }
    table.insert(self.ComboBoxQualityItemTable, item)
  end
  self.ComboBox_Quality = self:InitCustomComboBox(self.UIRoot.ComboBox_Quality)
  self.ComboBox_Quality:SetRefreshOptionCallback(self.OnRefreshComboBoxItem, self)
  self.ComboBox_Quality:SetSelectOptionCallback(self.OnSelectComboBoxItem, self)
  self.ComboBox_Quality:AddControlEventByControl(self.ComboBox_Quality.UIRoot, "OnOpening", self.OnBoxOpening, self)
  self.ComboBox_Quality:SetData(self.ComboBoxQualityItemTable)
  self.ComboBox_Quality:SelectIndex(self.CurComboBoxQualityIndex0 + 1)
end
function Personalization_AvatarFrame_UIBP:SetAvatarFrameLoopScrollGridDropDown1Time()
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:SetAvatarFrameLoopScrollGridDropDown1Time"))
  local timeDataCDataTable = CDataTable.GetTable("AvatarFrameTimeFilter")
  self.LoopScrollBoxTimeDataTable = {}
  for k, v in pairs(timeDataCDataTable) do
    local item = {
      nId = v.id,
      sStr = v.TimeFilterTitle
    }
    table.insert(self.LoopScrollBoxTimeDataTable, item)
  end
  self.CurrLoopScrollBoxTimeSelectedTable = {}
  self.LoopScrollGrid_DropDown1_Time:SetData(self.LoopScrollBoxTimeDataTable)
end
function Personalization_AvatarFrame_UIBP:SetAvatarFrameLoopScrollGridDropDown1Quality()
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:SetAvatarFrameLoopScrollGridDropDown1Quality"))
  local qualityDataCDataTable = CDataTable.GetTable("AvatarFrameQualityFilter")
  self.LoopScrollBoxQualityDataTable = {}
  for k, v in pairs(qualityDataCDataTable) do
    local item = {
      nId = v.id,
      nQuality = v.Quality,
      sStr = v.QualityFilterTitle
    }
    table.insert(self.LoopScrollBoxQualityDataTable, item)
  end
  self.CurrLoopScrollBoxQualitySelectedTable = {}
  self.LoopScrollGrid_DropDown1_Quality:SetData(self.LoopScrollBoxQualityDataTable)
end
function Personalization_AvatarFrame_UIBP:SetDropDown1Visibility(bVisible)
  log(bWriteLog and "Personalization_AvatarFrame_UIBP:SetDropDown1Visibility, bVisible = " .. tostring(bVisible))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_DropDown1, bVisible, false)
  self:SetWidgetVisible(self.UIRoot.Button_Close, bVisible, true)
  self.UIRoot.Image_arrow1:SetRenderAngle(bVisible and 180 or 0)
end
function Personalization_AvatarFrame_UIBP:OnAndroidBack()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
end
function Personalization_AvatarFrame_UIBP:HandleButtonUse()
  self:PlayAudio(sound_config.close_v1)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.change_avatar_box(self.selectedItemID)
end
function Personalization_AvatarFrame_UIBP:HandleButtonGo()
  self:PlayAudio(sound_config.click_v1)
  if self.jumpUrl and self.jumpUrl ~= "" then
    GlobalData.JumpUrl(self.jumpUrl)
    self:CloseSelf()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
  end
end
function Personalization_AvatarFrame_UIBP:HandleClickedItem(widget, index)
  local itemData = self.ItemGrid:GetItemData(index)
  if not itemData then
    return
  end
  log(bWriteLog and "HandleClickedItem.HandleClickedItem(frameId:" .. itemData.id .. ")")
  self.selectedItemID = itemData.id
  self.jumpUrl = itemData.jumpUrl
end
function Personalization_AvatarFrame_UIBP:UpdateItemReddot(itemData, index)
  if itemData.redPoint == 1 then
    local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
    RoleInfoAvatarFrameSystem.UpdateRedpoint(itemData.id)
    itemData.redPoint = 0
    return true
  end
  return false
end
function Personalization_AvatarFrame_UIBP:OnRefreshComboBoxItem(widget, data)
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnRefreshComboBoxItem, data.index0: %s, data.str: %s", data.index0, data.str))
  widget.TextBlock_ItemName:SetText(data.str)
end
function Personalization_AvatarFrame_UIBP:OnSelectComboBoxItem(widget, data)
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnSelectComboBoxItem, data.index0: %s", data.index0))
  if self.isInit then
    self:PlayAudio(sound_config.click_v1)
  end
  widget.TextBlock_ItemName:SetText(data.str)
  if data.type == _comboBoxTypeMap.Time then
    self.CurComboBoxTimeIndex0 = data.index0
  elseif data.type == _comboBoxTypeMap.Quality then
    self.CurComboBoxQualityIndex0 = data.index0
  end
  self:RefreshItemGrid()
end
function Personalization_AvatarFrame_UIBP:OnBoxOpening(widget)
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnBoxOpening"))
  self:PlayAudio(sound_config.popup_v1)
end
function Personalization_AvatarFrame_UIBP:OnClickButtonDropDown()
  log(bWriteLog and "Personalization_AvatarFrame_UIBP:OnClickButtonDropDown")
  self:PlayAudio(sound_config.click_v1)
  local bDropDown1Visible = self.UIRoot.CanvasPanel_DropDown1.Visibility == UEnums.ESlateVisibility.SelfHitTestInvisible
  self:SetDropDown1Visibility(not bDropDown1Visible)
end
function Personalization_AvatarFrame_UIBP:OnClickButtonClose()
  log(bWriteLog and "Personalization_AvatarFrame_UIBP:OnClickButtonClose")
  self:SetDropDown1Visibility(false)
end
function Personalization_AvatarFrame_UIBP:OnRefreshDropDownTimeLoopScrollGrid(widget, index)
  local itemData = self.LoopScrollGrid_DropDown1_Time:GetItemData(index)
  if not itemData then
    log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnRefreshDropDownTimeLoopScrollGrid, not itemData, index: %s", index))
    return
  end
  local checkBox = widget.CheckBox_Multi
  widget.TextBlock_Name:SetText(itemData.sStr)
  widget.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
  if self.CurrLoopScrollBoxTimeSelectedTable[itemData.nId] then
    checkBox:SetCheckedState(UEnums.ECheckBoxState.Checked)
  else
    checkBox:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
  end
end
function Personalization_AvatarFrame_UIBP:OnRefreshDropDownQualityLoopScrollGrid(widget, index)
  local itemData = self.LoopScrollGrid_DropDown1_Quality:GetItemData(index)
  if not itemData then
    log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnRefreshDropDownQualityLoopScrollGrid, not itemData, index: %s", index))
    return
  end
  local checkBox = widget.CheckBox_Multi
  widget.TextBlock_Name:SetText(itemData.sStr)
  widget.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
  if self.CurrLoopScrollBoxQualitySelectedTable[itemData.nQuality] then
    checkBox:SetCheckedState(UEnums.ECheckBoxState.Checked)
  else
    checkBox:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
  end
end
function Personalization_AvatarFrame_UIBP:OnSelectDropDownTime(widget, index)
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnSelectDropDownTime, index: %s", index))
  self:PlayAudio(sound_config.toggle_v1)
  local itemData = self.LoopScrollGrid_DropDown1_Time:GetItemData(index)
  if not itemData then
    log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnSelectDropDownTime, not itemData, index: %s", index))
    return
  end
  if self.CurrLoopScrollBoxTimeSelectedTable[itemData.nId] then
    self.CurrLoopScrollBoxTimeSelectedTable[itemData.nId] = nil
  else
    self.CurrLoopScrollBoxTimeSelectedTable[itemData.nId] = true
  end
  self.LoopScrollGrid_DropDown1_Time:RefreshAllItems()
  self:RefreshItemGrid()
  self:SetDropDownText()
end
function Personalization_AvatarFrame_UIBP:OnSelectDropDownQuality(widget, index)
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnSelectDropDownQuality, index: %s", index))
  self:PlayAudio(sound_config.toggle_v1)
  local itemData = self.LoopScrollGrid_DropDown1_Quality:GetItemData(index)
  if not itemData then
    log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:OnSelectDropDownQuality, not itemData, index: %s", index))
    return
  end
  if self.CurrLoopScrollBoxQualitySelectedTable[itemData.nQuality] then
    self.CurrLoopScrollBoxQualitySelectedTable[itemData.nQuality] = nil
  else
    self.CurrLoopScrollBoxQualitySelectedTable[itemData.nQuality] = true
  end
  self.LoopScrollGrid_DropDown1_Quality:RefreshAllItems()
  self:RefreshItemGrid()
  self:SetDropDownText()
end
function Personalization_AvatarFrame_UIBP:SetDropDownText()
  local bIsSelectedTime = next(self.CurrLoopScrollBoxTimeSelectedTable) ~= nil
  local bIsSelectedQuality = next(self.CurrLoopScrollBoxQualitySelectedTable) ~= nil
  local sNewDropDownButtonText = ""
  local sTime = self:GetCurrDropDownButtonTimeText()
  local sQuality = self:GetCurrDropDownButtonQualityText()
  if bIsSelectedTime == false and bIsSelectedQuality == false then
    sNewDropDownButtonText = LocUtil.GetLocalizeResStr(199437)
  elseif bIsSelectedTime and bIsSelectedQuality then
    sNewDropDownButtonText = string.format("%s - %s", sTime, sQuality)
  else
    sNewDropDownButtonText = sTime ~= "" and sTime or sQuality
  end
  self.UIRoot.TextBlock_DropDown1:SetText(sNewDropDownButtonText)
end
function Personalization_AvatarFrame_UIBP:GetCurrDropDownButtonTimeText()
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:GetCurrDropDownButtonTimeText"))
  local res = ""
  for k, v in pairs(self.CurrLoopScrollBoxTimeSelectedTable) do
    local data = self.LoopScrollBoxTimeDataTable[k]
    if v then
      res = res == "" and data.sStr or string.format("%s %s", res, data.sStr)
    end
  end
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:GetCurrDropDownButtonTimeText, res: %s", res))
  return res
end
function Personalization_AvatarFrame_UIBP:GetCurrDropDownButtonQualityText()
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:GetCurrDropDownButtonQualityText"))
  local res = ""
  for k, v in pairs(self.CurrLoopScrollBoxQualitySelectedTable) do
    if v then
      local data = {}
      for kk, vv in pairs(self.LoopScrollBoxQualityDataTable) do
        if vv.nQuality == k then
          data = vv
          break
        end
      end
      res = res == "" and data.sStr or string.format("%s %s", res, data.sStr)
    end
  end
  log(bWriteLog and string.format("Personalization_AvatarFrame_UIBP:GetCurrDropDownButtonQualityText, res: %s", res))
  return res
end
function Personalization_AvatarFrame_UIBP:GetItemList()
  log(bWriteLog and "Personalization_AvatarFrame_UIBP:GetItemList")
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.UsedGotData()
  local data = CDataTable.GetTable("AvatarFrame")
  local cfu = DataMgr.roleData.cur_avatar_box_id
  local e = RoleInfoAvatarFrameSystem.ENUM_State
  local rpl = RoleInfoAvatarFrameSystem.RedPointList
  local _GetRedPoint = function(id, state)
    id = tonumber(id)
    local res = 0
    local tmpRedItem = rpl[id]
    if tmpRedItem ~= nil then
      res = 1
      if state == e.None then
        rpl[id] = nil
      end
    end
    return res
  end
  local frameListData = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local itemCDataTable = CDataTable.GetTable("Item")
  for _, v in pairs(data) do
    local itm = RoleInfoAvatarFrameSystem.AvatarFrameList[v.ID]
    local continue = false
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE and (v.ID == 30119 or v.ID == 30141 or v.ID == 2002207 or v.ID == 2005016) then
      continue = true
    end
    if self.isCheckOwned and not itm then
      continue = true
    end
    if next(self.CurrLoopScrollBoxTimeSelectedTable) and not self.CurrLoopScrollBoxTimeSelectedTable[v.TimeFilterId] then
      continue = true
    end
    if next(self.CurrLoopScrollBoxQualitySelectedTable) then
      local itemCData = itemCDataTable[v.ID]
      local itemQuality = itemCData.ItemQuality ~= 0 and itemCData.ItemQuality or -1
      if not self.CurrLoopScrollBoxQualitySelectedTable[itemQuality] then
        continue = true
      end
    end
    if not continue then
      local TimeUtil = require("client.common.time_util")
      if (v.DefaultDisplay == 1 or v.DefaultDisplay == 0 and itm ~= nil) and TimeUtil.CheckAfterTimeStr(v.ShowTime) then
        local expireTime = 0
        if itm then
          expireTime = itm.expire_time
        else
          expireTime = nil
        end
        local tmp = {
          id = v.ID,
          name = v.Name,
          desc = v.Desc,
          desc_get = v.DescGet,
          jumpUrl = v.JumpUrl,
          expire_time = expireTime,
          state = cfu == v.ID and e.Use or itm ~= nil and e.Has or e.None,
          redPoint = 0
        }
        tmp.redPoint = _GetRedPoint(tmp.id, tmp.state)
        table.insert(frameListData, tmp)
      end
    end
  end
  local sortMap = {
    [e.Has] = 2,
    [e.None] = 3,
    [e.Use] = 1
  }
  local _Sort = function(a, b)
    if a.state == b.state then
      if a.redPoint ~= b.redPoint then
        return a.redPoint > b.redPoint
      else
        return a.id < b.id
      end
    else
      return sortMap[a.state] < sortMap[b.state]
    end
  end
  table.sort(frameListData, _Sort)
  return frameListData
end
function Personalization_AvatarFrame_UIBP:OnAvatarFrameInfoUpdate()
  self:RefreshItemGrid()
end
function Personalization_AvatarFrame_UIBP:UpdateLobbyAvatar()
  ShowNotice(49951)
end
function Personalization_AvatarFrame_UIBP:IsUsingItem(itemData)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  return itemData.state == RoleInfoAvatarFrameSystem.ENUM_State.Use
end
function Personalization_AvatarFrame_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData) or not itemData.id then
    return false
  end
  return itemData.id == self.jumpSelectItemId
end
function Personalization_AvatarFrame_UIBP:OnRefreshGridItem(widget, index)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  local e = RoleInfoAvatarFrameSystem.ENUM_State
  local itemData = self.ItemGrid:GetItemData(index)
  if not itemData then
    return
  end
  self:SetWidgetVisible(widget.Image_Select, self.baseItemSelectIndex == index)
  local lock = widget.CanvasPanel_Lock
  local check = widget.Image_Using
  if itemData.state == e.Use then
    check:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    lock:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  elseif itemData.state == e.Has then
    check:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    lock:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  elseif itemData.state == e.None then
    check:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local lockOpacity = FLinearColor(1, 1, 1, 0.7)
    widget.Image_Lock:SetColorAndOpacity(lockOpacity)
  end
  local isHas = itemData.state ~= e.None
  local borderOpacity = isHas and FLinearColor(1, 1, 1, 1) or FLinearColor(1, 1, 1, 0.4)
  widget.Common_Avatar_BP:SetColorAndOpacity(borderOpacity)
  local common_avatar = widget.Common_Avatar_BP
  common_avatar:InitView(4, self.myUid, nil, 0, itemData.id, nil, nil, nil, nil, {DisableIcon = true})
  common_avatar:SetButtonEnabled(false)
  self:SetWidgetVisible(widget.Image_New, itemData.redPoint == 1)
  local isExpireItem = type(itemData.expire_time) == "number" and 1 < itemData.expire_time
  self:SetWidgetVisible(widget.Image_LimitedTime, itemData.state ~= e.None and isExpireItem)
end
function Personalization_AvatarFrame_UIBP:UpdatePlayerInfo()
  Personalization_AvatarFrame_UIBP.__super.UpdatePlayerInfo(self)
  self.UIRoot.TextBlock_FriendsText:SetText(LocUtil.GetLocalizeResStr(4020))
  self.UIRoot.TextBlock_FriendsText:SetColorAndOpacity(FSlateColor(FLinearColor(0.023, 0.888, 1, 1)))
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CUI_RoleInfo_AvatarFrame = class(ui_base, nil, Personalization_AvatarFrame_UIBP)
return CUI_RoleInfo_AvatarFrame