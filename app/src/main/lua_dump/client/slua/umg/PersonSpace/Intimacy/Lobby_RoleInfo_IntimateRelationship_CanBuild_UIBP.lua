local Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP = {}
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
local LogicRelationship = require("client.logic.personspace.logic_person_space_relationship")
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:ctor(_, uid)
  self.uid = uid or 0
  self.buildRelationCase = 0
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:OnInitialize()
  self.ReuseListMultiSize_Intimacy = self:InitReuseFallMultiSize(self.UIRoot.ReuseListMultiSize_Intimacy, "client.slua.umg.person_space.item.build_intimacy_item_new")
  local Lobby_RoleInfo_IntimateRelationship_Item_UIBP = require("client.slua.umg.PersonSpace.item.Lobby_RoleInfo_IntimateRelationship_Item_UIBP")
  self.child_Item = Lobby_RoleInfo_IntimateRelationship_Item_UIBP()
  self.child_Item:InitWithParentWidget(self, self.UIRoot.Lobby_RoleInfo_IntimateRelationship_Item_UIBP)
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.UpdateUI, self)
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:OnPostInitialize()
  self:UpdateUI()
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:OnClose()
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:SetCanBuildData(dataList, isEmpty)
  if isEmpty then
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP:PlayUserWidgetAnimation(self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.fadein, 0, 1, 0, 1)
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Lobby_RoleInfo_Intimacy_Kong_Item_UIBP.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(82949))
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.ReuseListMultiSize_Intimacy:SetData(dataList)
  end
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:UpdateUI")
  self.buildRelationCase = IntimacyUtils.GetBuildRelationCase()
  local table_util = require("common.table_util")
  local friendUidList = table_util.LiteCopy(LogicFriend.GetInnerList(false), true)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local myUid = tonumber(DataMgr.roleData.uid)
  for i = #friendUidList, 1, -1 do
    local intimacyInfo = logic_friend_intimacy:GetIntimacyInfo(myUid, friendUidList[i])
    if intimacyInfo and intimacyInfo.state == 4 then
      table.remove(friendUidList, i)
    end
  end
  table.sort(friendUidList, function(a, b)
    local fda = LogicFriend.GetFriendData(a)
    local fdb = LogicFriend.GetFriendData(b)
    if fda and fdb then
      local intimacyA = fda.intimacy or 0
      local intimacyB = fdb.intimacy or 0
      if intimacyA ~= intimacyB then
        return intimacyA > intimacyB
      end
      if fda.lastOnlineTime and fdb.lastOnlineTime and fda.lastOnlineTime ~= fdb.lastOnlineTime then
        return fda.lastOnlineTime > fdb.lastOnlineTime
      end
      return tonumber(a) < tonumber(b)
    end
    return false
  end)
  local dataList, isEmpty = IntimacyUtils.GetReuseListMultiSize_Intimacy_Data(friendUidList)
  self:SetCanBuildData(dataList, isEmpty)
  self:_SetRecommendBonding()
end
function Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:_SetRecommendBonding()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Bonding, false)
  if not IntimacyUtils.IsBondingSystemOpen() then
    print("Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP:_SetRecommendBonding not open")
    return
  end
  local result = self.child_Item:ExternalUpdateUI()
  if result then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Bonding, true)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP)