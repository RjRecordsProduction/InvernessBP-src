local FriendsListReuseFall_Item = {}
function FriendsListReuseFall_Item:OnRefresh()
  local data = self.data
  local friend_macros = require("client.slua.logic.friend.friend_macros")
  local ListItemType = friend_macros.E_ListItemType
  if data.itemType == ListItemType.Title then
    self:UpdateTitle()
  elseif data.itemType == ListItemType.Friend then
    FriendsListReuseFall_Item.__super.OnRefresh(self, data)
  end
end
function FriendsListReuseFall_Item:RegistEvents()
  if self.UIRoot.Button_OpenList then
    self:AddOnClickedEventByControl(self.UIRoot.Button_OpenList, self.OnClickButton_OpenList, self)
  else
    FriendsListReuseFall_Item.__super.RegistEvents(self)
  end
end
function FriendsListReuseFall_Item:OnClickButton_OpenList()
  self:PlayAudio(sound_config.click_v1)
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  local groupID = self.data.reuseFallGroupID
  local bHas = logic_friend_group:IsHasSelectGroupID(groupID)
  if bHas then
    logic_friend_group:RemoveSelectGroupID(groupID)
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(0)
    logic_friend_group:SetFoldingFirstGroup(true)
  else
    logic_friend_group:AddSelectGroupID(groupID)
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(1)
  end
  local parentUI = self:GetLoopScrollBoxParentUI()
  if parentUI.SetOneTabData then
    parentUI:SetOneTabData(true)
  end
end
function FriendsListReuseFall_Item:OnSubRefresh(data, selectIndex, subSelectIndex)
  self.  FriendsListReuseFall_Item.__super.OnRefresh(self, self.data)
end
function FriendsListReuseFall_Item:UpdateTitle()
  local ModuleManager = require("client.module_framework.ModuleManager")
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  if self.data.reuseFallGroupID then
    local groupName = logic_friend_group:GetGroupNameByID(self.data.reuseFallGroupID)
    self.UIRoot.TextBlock_Name:SetText(groupName)
    self.UIRoot.TextBlock_Current:SetText(self.data.onlineNum or 0)
    self.UIRoot.TextBlock_Total:SetText(self.data.totalNum or 0)
    local ModuleManager = require("client.module_framework.ModuleManager")
    local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
    local bHas = logic_friend_group:IsHasSelectGroupID(self.data.reuseFallGroupID)
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(bHas and 1 or 0)
  end
end
local class = require("class")
local ui_base = require("client.slua.umg.lobby.FriendList.Item.FriendsListItem_BP")
return class(ui_base, nil, FriendsListReuseFall_Item)