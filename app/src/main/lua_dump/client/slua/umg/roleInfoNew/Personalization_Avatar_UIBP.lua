local Personalization_Avatar_UIBP = {}
local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
local EAvatarState = RoleInfoAvatarSystem.EAvatarState
function Personalization_Avatar_UIBP:ctor(_, jumpSelectItemId)
  self.selectId = 0
  self.selectUrl = ""
  self.jumpUrl = ""
  self.myUid = ""
  self.myFrameId = 0
  self.itemData = nil
end
local C_SocialHeadID = 10002
function Personalization_Avatar_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_FrameGrid)
end
function Personalization_Avatar_UIBP:RegistEvents()
  Personalization_Avatar_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, self.OnUpdateHeadInfo, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_IEGAL_PRIVAY_CHOICE_CHANGE, self.AfterUserAgreeAvatarRule, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_USE_AVATAR, self.OnUpdateUseAvatar, self)
end
function Personalization_Avatar_UIBP:OnPostInitialize()
  Personalization_Avatar_UIBP.__super.OnPostInitialize(self)
  self:InitData()
end
function Personalization_Avatar_UIBP:InitData()
  RoleInfoAvatarSystem.send_get_user_avatar_list()
  RoleInfoAvatarSystem.send_get_unlock_progress_req()
  self.myUid = tostring(DataMgr.roleData.uid)
  self.myFrameId = DataMgr.roleData.cur_avatar_box_id
  self.selectId = tonumber(DataMgr.roleData.headIconUrl)
  self.selectUrl = tostring(DataMgr.roleData.headIconUrl)
end
function Personalization_Avatar_UIBP:GetDefaultItemData()
  local itemData = {}
  for i, v in pairs(self.ItemGrid:GetSetData()) do
    if tostring(v.id) == self.selectUrl then
      itemData = v
      break
    elseif v.id == C_SocialHeadID and string.find(DataMgr.roleData.headIconUrl, "http") then
      itemData = v
      break
    end
  end
  return itemData
end
function Personalization_Avatar_UIBP:OnRefreshGridItem(widget, index)
  local info = self.ItemGrid:GetItemData(index)
  if not info then
    return
  end
  local selected = index == self.baseItemSelectIndex
  self:SetWidgetVisible(widget.Image_Select, selected)
  self:SetWidgetVisible(widget.TextBlock_0, info.state == EAvatarState.Use)
  self:SetWidgetVisible(widget.Image_Using, info.state == EAvatarState.Use)
  self:SetWidgetVisible(widget.Image_Time, info.expire_time > 1)
  self:SetWidgetVisible(widget.CanvasPanel_Lock, info.state == EAvatarState.None)
  if info.state == EAvatarState.None then
    local borderOpacity = FLinearColor(1, 1, 1, 0.4)
    widget.Common_Avatar_BP:SetColorAndOpacity(borderOpacity)
  end
  local isHas = info.state ~= EAvatarState.None
  local borderOpacity = isHas and FLinearColor(1, 1, 1, 1) or FLinearColor(1, 1, 1, 0.4)
  widget.Common_Avatar_BP:SetColorAndOpacity(borderOpacity)
  local common_avatar = widget.Common_Avatar_BP
  local frameID = 0
  if info.id == C_SocialHeadID and string.find(info.path or "", "http") then
    common_avatar:InitView(4, self.myUid, info.path, 0, frameID, nil, true)
  else
    common_avatar:InitView(4, self.myUid, info.id, 0, frameID, nil, true)
  end
  self:SetWidgetVisible(widget.Image_New, info.redPoint == 1)
end
function Personalization_Avatar_UIBP:UpdatePlayerInfo()
  Personalization_Avatar_UIBP.__super.UpdatePlayerInfo(self)
  self.UIRoot.TextBlock_FriendsText:SetText(LocUtil.GetLocalizeResStr(4020))
  self.UIRoot.TextBlock_FriendsText:SetColorAndOpacity(FSlateColor(FLinearColor(0.023, 0.888, 1, 1)))
end
function Personalization_Avatar_UIBP:UpdateSelectedItemInfo(itemData)
  if itemData and next(itemData) then
    self:SetDescAndButtonVisible(true)
  else
    self:SetDescAndButtonVisible(false)
    return
  end
  local root = self.UIRoot
  root.Common_Avatar_BP:InitView(3, self.myUid, self.selectUrl, 0, self.myFrameId)
  root.Common_Avatar_BP:SetButtonEnabled(false)
  self.smallAvatar:InitView(3, self.myUid, self.selectUrl, 0, self.myFrameId)
  local param = self:GenCommonItemParam()
  param.itemID = itemData.id
  param.name = itemData.name
  param.desc = itemData.desc
  param.buttonStyle = ENUM_Button_Style.Use
  param.expireTime = itemData.expire_time
  if itemData.state == EAvatarState.None then
    if itemData.desc_get and itemData.desc_get ~= "" then
      param.buttonStyle = self.jumpUrl and self.jumpUrl ~= "" and ENUM_Button_Style.Go or ENUM_Button_Style.None
      param.extraInfo = itemData.desc_get
    else
      param.buttonStyle = ENUM_Button_Style.NoYet
    end
  elseif itemData.state == EAvatarState.Use then
    param.buttonStyle = ENUM_Button_Style.Using
  end
  return param
end
function Personalization_Avatar_UIBP:UpdateHeadportraitIDByUrl(url)
  if string.find(url, "http") then
    self.selectId = C_SocialHeadID
  else
    self.selectId = tonumber(url)
  end
  if self.selectId == C_SocialHeadID then
    self.selectUrl = RoleInfoAvatarSystem.HeadportraitList[tostring(self.selectId)]
    if not self.selectUrl then
      self.selectUrl = ""
    end
  else
    self.selectUrl = tostring(self.selectId)
  end
end
function Personalization_Avatar_UIBP:OnUpdateHeadInfo(_, _, headportraiturl)
  self:UpdateHeadportraitIDByUrl(headportraiturl)
  self:RefreshItemGrid()
end
function Personalization_Avatar_UIBP:OnUpdateUseAvatar()
  ShowNotice(49951)
  self.jumpSelectItemId = nil
  local itemDataList = self.ItemGrid:GetSetData()
  for i, v in ipairs(itemDataList) do
    if i == self.baseItemSelectIndex then
      v.state = EAvatarState.Use
      self:UpdateItemPreview(v)
    elseif v.state == EAvatarState.Use then
      v.state = EAvatarState.Has
    end
  end
  self:RefreshItemGrid()
end
function Personalization_Avatar_UIBP:IsUsingItem(itemData)
  return itemData.state == EAvatarState.Use
end
function Personalization_Avatar_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData) or not itemData.id then
    return false
  end
  return itemData.id == self.jumpSelectItemId
end
function Personalization_Avatar_UIBP:GetRoleInfoHeadList()
  local dataTable = CDataTable.GetTable("Headportrait")
  local headIconUrl = DataMgr.roleData.headIconUrl
  local RoleInfoHeadportraitList = {}
  local TimeUtil = require("client.common.time_util")
  local UIUtil = require("client.common.ui_util")
  for _, v in pairs(dataTable) do
    local item = RoleInfoAvatarSystem.HeadportraitList[tostring(v.ID)]
    if v.isShow and (v.DefaultDisplay == 1 or v.DefaultDisplay == 0 and item ~= nil) and TimeUtil.CheckAfterTimeStr(v.ShowTime) then
      local state, path
      if item then
        if v.ID == C_SocialHeadID then
          path = item
        end
        state = EAvatarState.Has
        if headIconUrl == tostring(v.ID) then
          state = EAvatarState.Use
        elseif v.ID == C_SocialHeadID and string.find(headIconUrl, "http") then
          state = EAvatarState.Use
        end
      else
        state = EAvatarState.None
      end
      local redPoint
      if RoleInfoAvatarSystem.RedPointList[tostring(v.ID)] then
        redPoint = 1
      else
        redPoint = 0
      end
      local expire_time = tonumber(item)
      local temp = {
        id = v.ID or 0,
        name = v.Name or "",
        desc = v.desc or "",
        desc_get = v.UnlockDesc or "",
        jumpUrl = v.JumpUrl or "",
        state = state,
        redPoint = redPoint,
        expire_time = expire_time or 1
      }
      temp.path = path or UIUtil.GetItemSmallIcon(v.ID, nil, nil, true) or ""
      RoleInfoHeadportraitList[#RoleInfoHeadportraitList + 1] = temp
    end
  end
  return RoleInfoHeadportraitList
end
function Personalization_Avatar_UIBP:GetItemList()
  local itemData = self:GetRoleInfoHeadList()
  if self.isCheckOwned then
    self.itemData = {}
    for k, v in pairs(itemData) do
      if v.state ~= EAvatarState.None then
        table.insert(self.itemData, v)
      end
    end
  else
    self.  end
  local sortOrder = {
    [EAvatarState.Use] = 1,
    [EAvatarState.Has] = 2,
    [EAvatarState.None] = 3
  }
  table.sort(self.itemData, function(a, b)
    if a.state ~= b.state then
      return sortOrder[a.state] < sortOrder[b.state]
    elseif a.redPoint == b.redPoint then
      return a.id < b.id
    else
      return a.redPoint > b.redPoint
    end
  end)
  return self.itemData
end
function Personalization_Avatar_UIBP:AfterUserAgreeAvatarRule(_, _, tabType, bAgree)
  if not bAgree then
    return
  end
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  if tabType ~= LeagalMsgSystem.Enum_Tab_Choose.AvatarRule then
    return
  end
  LeagalMsgSystem.ReqSendChoice()
  RoleInfoAvatarSystem.send_change_user_avatar(tostring(self.selectId))
end
function Personalization_Avatar_UIBP:HandleButtonUse()
  self:PlayAudio(sound_config.click_v1)
  if self.selectId == C_SocialHeadID then
    local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
    if not LeagalMsgSystem.GetAvatarPrivacyState() then
      LeagalMsgSystem.ShowlegalAvatarRule()
      return
    end
  end
  RoleInfoAvatarSystem.send_change_user_avatar(tostring(self.selectId))
end
function Personalization_Avatar_UIBP:HandleButtonGo()
  self:PlayAudio(sound_config.click_v1)
  if self.jumpUrl and self.jumpUrl ~= "" then
    GlobalData.JumpUrl(self.jumpUrl)
    self:CloseSelf()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
  end
end
function Personalization_Avatar_UIBP:UpdateItemReddot(itemData, index)
  if itemData.redPoint == 1 then
    itemData.redPoint = 0
    RoleInfoAvatarSystem.UpdateRedpoint(tostring(itemData.id))
    return true
  end
  return false
end
function Personalization_Avatar_UIBP:HandleClickedItem(widget, index)
  local itemData = self.ItemGrid:GetItemData(index)
  if not itemData then
    return
  end
  log_tree("[chub]UI_RoleInfo_Avatar:OnClickAvatar, itemData = ", itemData)
  self.selectId = itemData.id
  self.jumpUrl = itemData.jumpUrl
  local strID = tostring(self.selectId)
  if self.selectId == C_SocialHeadID then
    self.selectUrl = RoleInfoAvatarSystem.HeadportraitList[strID] or ""
  else
    self.selectUrl = strID
  end
  log_tree("[YY]OnClickAvatar==HeadportraitList==", RoleInfoAvatarSystem.HeadportraitList)
end
function Personalization_Avatar_UIBP:OnAndroidBack()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CUIRoleInfo_Avatar = class(ui_base, nil, Personalization_Avatar_UIBP)
return CUIRoleInfo_Avatar