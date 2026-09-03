local Lobby_RoleInfo_IntimateRelationship_Item_UIBP = {}
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ctor(_, bIsWeddingActivity)
  self.end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:OnInitialize()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Bonding, true)
end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Recommend, self.OnClickButton_Recommend, self)
end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:OnPostInitialize()
end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:OnClose()
end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:OnClickButton_Recommend()
  self:PlayAudio(sound_config.click_v1)
  printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:OnClickButton_Recommend recommendFirstUid: %s", self.recommendFirstUid)
  if self.bIsWeddingActivity then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.Show(RoleInfoMainSystem.IntimateRelationship_SubTab.Close, RoleInfoMainSystem.RoleInfoOpenFromType.WeddingActivitySquare, DataMgr.roleData.uid)
    return
  end
  if self.recommendFirstUid then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_INTIMACY_RELATIONSHIP_REFRESH_TAB, {tabIndex = 1, showRelationshipNet = false})
  end
end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI()
  printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI")
  local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local myUid = tonumber(DataMgr.roleData.uid)
  if logic_friend_intimacy:GetIntimacyCountByRelationAndState(myUid, IntimacyConst.EIntimacyType.Bonding, IntimacyConst.EStateType.Has_Build) > 0 then
    printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI already bonding")
    return
  end
  if 0 < logic_friend_intimacy:GetIntimacyCountByRelationAndState(myUid, IntimacyConst.EIntimacyType.Bonding, IntimacyConst.EStateType.Has_Send) then
    printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI already bonding applying")
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if #LogicFriend.GetAllFriendList() == 0 then
    printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI no game friend")
    return
  end
  local intimacyList = LogicFriend.GetIntimacyHasBuildSortV2()
  for i, v in ipairs(intimacyList) do
    if v.param == IntimacyConst.EIntimacyType.Lover then
      printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI can build with lover")
      self:UpdateUI(1, v.uid)
      return true
    end
  end
  local Show3Uids = {}
  local totalCount = 0
  for i, v in ipairs(intimacyList) do
    if v.param ~= IntimacyConst.EIntimacyType.Bonding then
      totalCount = totalCount + 1
      if #Show3Uids < 3 then
        table.insert(Show3Uids, v.uid)
      end
    end
  end
  if 0 < #Show3Uids then
    printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI can build with some one")
    self:UpdateUI(2, Show3Uids, totalCount)
    return true
  end
  printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:ExternalUpdateUI can build with everyone")
  return false
end
function Lobby_RoleInfo_IntimateRelationship_Item_UIBP:UpdateUI(type, uidOrList, totalCount)
  printf("Lobby_RoleInfo_IntimateRelationship_Item_UIBP:UpdateUI type: %s, uidOrList: %s, totalCount: %s", type, uidOrList, totalCount)
  self.recommendFirstUid = nil
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local myUid = DataMgr.roleData.uid
  local mp = logic_profile:GetLocalProfile(myUid)
  self.UIRoot.Common_Avatar_BP:InitView(1, myUid, mp.picUrl, mp.sex, mp.cur_avatar_box_id, mp.level, false, "")
  self.UIRoot.TextBlock_Matchmaker01Name:SetText(mp.nickName)
  self.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
  if type == 1 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.recommendFirstUid = uidOrList
    self.UIRoot.WidgetSwitcher_HasLover:SetActiveWidgetIndex(0)
    self.UIRoot.TextBlock_RecommendationText:SetText(LocUtil.GetLocalizeResStr(81224))
    local tp = logic_profile:GetLocalProfile(uidOrList)
    if tp then
      self.UIRoot.TextBlock_Matchmaker02Name:SetText(tp.nickName)
      self.UIRoot.Common_Avatar_BP_C_0:InitView(1, uidOrList, tp.picUrl, tp.sex, tp.cur_avatar_box_id, tp.level, false, "")
      self.UIRoot.Common_Avatar_BP_C_0:SetButtonEnabled(false)
    else
      log_error_format("Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:_SetRecommendBondingData profile is nil uid: %s", uidOrList)
    end
  elseif type == 2 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.recommendFirstUid = uidOrList[1]
    self.UIRoot.WidgetSwitcher_HasLover:SetActiveWidgetIndex(1)
    self.UIRoot.TextBlock_RecommendationText:SetText(LocUtil.GetLocalizeResStr(81225))
    if totalCount == 1 then
      local tp = logic_profile:GetLocalProfile(uidOrList[1])
      if tp then
        self.UIRoot.TextBlock_RecommendationTips:SetText(tp.nickName)
      else
        log_error_format("Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:_SetRecommendBondingData profile is nil uid: %s", uidOrList[1])
      end
    else
      self.UIRoot.TextBlock_RecommendationTips:SetText(LocUtil.LocalizeResFormat(81226, totalCount))
    end
    if uidOrList then
      for i = 1, totalCount do
        local widgetName = "Common_Avatar_BP_C_" .. i
        if uidOrList[i] then
          local tp = logic_profile:GetLocalProfile(uidOrList[i])
          if tp then
            self.UIRoot[widgetName]:InitView(1, uidOrList[i], tp.picUrl, tp.sex, tp.cur_avatar_box_id, tp.level, false, "")
            self.UIRoot[widgetName]:SetButtonEnabled(false)
            self:SetWidgetVisible(self.UIRoot[widgetName], true)
          else
            log_error_format("Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:_SetRecommendBondingData profile is nil uid: %s", uidOrList[i])
            self:SetWidgetVisible(self.UIRoot[widgetName], false)
          end
        else
          self:SetWidgetVisible(self.UIRoot[widgetName], false)
        end
      end
    else
      log_error_format("Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:_SetRecommendBondingData profile is nil uid: %s", uidOrList)
    end
  elseif type == 3 then
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_RoleInfo_IntimateRelationship_Item_UIBP)