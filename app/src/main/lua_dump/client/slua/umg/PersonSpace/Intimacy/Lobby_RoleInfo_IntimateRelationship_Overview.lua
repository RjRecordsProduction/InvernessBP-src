local Lobby_RoleInfo_IntimateRelationship_Overview = {}
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
local LogicRelationship = require("client.logic.personspace.logic_person_space_relationship")
function Lobby_RoleInfo_IntimateRelationship_Overview:ctor(selfType, uid)
  self.uid = uid or 0
end
function Lobby_RoleInfo_IntimateRelationship_Overview:OnInitialize()
  local Lobby_RoleInfo_IntimateRelationship_Loop_UIBP = require("client.slua.umg.PersonSpace.Lobby_RoleInfo_IntimateRelationship_Loop_UIBP")
  self.child_ListLoop = Lobby_RoleInfo_IntimateRelationship_Loop_UIBP()
  self.child_ListLoop:InitWithParentWidget(self, self.UIRoot.Lobby_RoleInfo_IntimateRelationship_Loop_UIBP)
  local intimacyList = LogicFriend.GetIntimacyHasBuildSortV2()
  local IsSelf = LogicRelationship.IsMySelf(self.uid)
  if IsSelf then
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP:PlayUserWidgetAnimation(self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.fadein, 0, 1, 0, 1)
  end
  if IsSelf and (intimacyList == nil or #intimacyList == 0) then
    self:IsSetKong(intimacyList)
  elseif not IsSelf and (PersonSpaceSystem.FriendDetailsDatas == nil or #PersonSpaceSystem.FriendDetailsDatas == 0) then
    self:IsSetKong(PersonSpaceSystem.FriendDetailsDatas)
  end
  self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(44366))
  self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(73245))
end
function Lobby_RoleInfo_IntimateRelationship_Overview:RegistEvents()
  Lobby_RoleInfo_IntimateRelationship_Overview.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.Button_award, "OnClicked", self.OnClickButton_Award, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, self.UpdateUI, self)
end
function Lobby_RoleInfo_IntimateRelationship_Overview:OnClickButton_Award(widget, index)
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Strategy_UIBP, 3)
end
function Lobby_RoleInfo_IntimateRelationship_Overview:OnShow()
  Lobby_RoleInfo_IntimateRelationship_Overview.__super.OnShow(self)
  local IsSelf = LogicRelationship.IsMySelf(self.uid)
  if IsSelf then
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Overview:UpdateUI()
  printf("Lobby_RoleInfo_IntimateRelationship_Overview:UpdateUI")
  local IsSelf = LogicRelationship.IsMySelf(self.uid)
  if IsSelf then
    local intimacyList = LogicFriend.GetIntimacyHasBuildSortV2()
    local tmpList = {}
    for _, v in ipairs(intimacyList) do
      table.insert(tmpList, v)
    end
    for i = 1, 3 do
      table.insert(tmpList, {})
    end
    self.child_ListLoop:SetHasBuildData(tmpList)
    self:IsSetKong(intimacyList)
  else
    local switchStatus = LogicRelationship.RelationShip_SwitchStatus
    if switchStatus.IsAllSwitch_Closed or switchStatus.IsAllChildSwitch_Closed then
      return
    end
    local TableUtil = require("common.table_util")
    local HasBuildList = TableUtil.DeepCloneTable(PersonSpaceSystem.FriendDetailsDatas)
    table.sort(HasBuildList, function(a, b)
      return a.intimacy > b.intimacy
    end)
    local switchSetting = LogicRelationship.RelationShip_SwitchSetting
    for i = #HasBuildList, 1, -1 do
      for k, v in pairs(switchSetting) do
        if HasBuildList[i].relation == v.relation and not v.isVisible then
          table.remove(HasBuildList, i)
          break
        end
      end
    end
    self.child_ListLoop:SetHasBuildData(HasBuildList)
    self:IsSetKong(HasBuildList)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Overview:SetSwicher(index)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(index)
end
function Lobby_RoleInfo_IntimateRelationship_Overview:SetTextShow(show)
  if show then
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Overview:IsSetKong(data)
  if data == nil or #data == 0 then
    self:SetSwicher(1)
  else
    self:SetSwicher(0)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Overview:AutoExpandFirstItemMenu()
  self.child_ListLoop:ExpandFirstItemMenu()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, Lobby_RoleInfo_IntimateRelationship_Overview)
return CUITemplate