local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
function Lobby_InviteFriend_BP:SearchFriendFuzzy(text)
  log(bWriteLog and string.format("teamup_side_bar:SearchFriendFuzzy, text: %s", text))
  local StringUtil = require("common.string_util")
  local searchKeyTable = {
    "nickName",
    "remark",
    "uid"
  }
  local matchTable = {}
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local friendList = LogicTeamUpSideBar.GetFriends() or {}
  for k, v in ipairs(friendList) do
    log(bWriteLog and bWriteLog and string.format("teamup_side_bar:SearchFriendFuzzy, ipairs(friendList), index: %s, name: %s, remark: %s, uid: %s", k, v.nickName, v.remark, v.uid))
    for _, searchKey in ipairs(searchKeyTable) do
      local src = v[searchKey]
      if src then
        local isPattrnFound = StringUtil.StrFind(string.lower(src), string.lower(text))
        if isPattrnFound then
          table.insert(matchTable, v)
          break
        end
      end
    end
  end
  log_tree("teamup_side_bar:SearchFriendFuzzy, matchTable", matchTable)
  return matchTable
end
function Lobby_InviteFriend_BP:OnClickButton_SearchFriendCommit()
  log(bWriteLog and string.format("teamup_side_bar:OnClickButton_SearchFriendCommit"))
  self:PlayAudio(sound_config.click_v1)
  local inputEditorText = self.UIRoot.Common_Search_Item_UIBP.message_input
  self:OnInputBoxCommitted(inputEditorText.Text)
end
function Lobby_InviteFriend_BP:OnInputBoxCommitted(text)
  log(bWriteLog and string.format("teamup_side_bar:OnInputBoxCommitted, text: %s", text))
  if not text or text == "" then
    return
  end
  if not self:IsFriendTagUnGroup() then
    self.Common_ScreenBox_UIBP:OnClickButton_Clear(false)
  end
  self.bEnableLocalSearchFriend = true
  self.tLocalSearchFriendDataList = self:SearchFriendFuzzy(text)
  self:SetOneTabData(true)
end
function Lobby_InviteFriend_BP:OnClickCancelSearch(bClick)
  log(bWriteLog and string.format("teamup_side_bar:OnClickCancelSearch"))
  if bClick ~= false then
    self:PlayAudio(sound_config.click_v1)
  end
  self.bEnableLocalSearchFriend = false
  self.tLocalSearchFriendDataList = {}
  self:ResetSearchText()
  self:SetOneTabData(true)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_SearchFriend, false, true)
  self:SetWidgetVisible(self.UIRoot.Button_SearchFriendLocal, true, true)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_TopButton, true, true)
  self:SetWidgetVisible(self.UIRoot.Common_ScreenBox_UIBP, true, true)
end
function Lobby_InviteFriend_BP:OnClickButtonSearchFriendLocal()
  log(bWriteLog and string.format("teamup_side_bar:OnClickButtonSearchFriendLocal"))
  self:PlayAudio(sound_config.click_v1)
  if self.UIRoot.CanvasPanel_Menu:IsVisible() then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  end
  if not self:IsFriendTagUnGroup() then
    self.Common_ScreenBox_UIBP:OnClickButton_Clear(false)
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_Search, 0, 1, 0, 1)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_SearchFriend, true, true)
  self:SetWidgetVisible(self.UIRoot.Button_SearchFriendLocal, false, true)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_TopButton, false, true)
  if self.SeekFriend_NewGuide_Tips_UIBP then
    self.SeekFriend_NewGuide_Tips_UIBP:CloseSelf()
  end
  self:SetWidgetVisible(self.UIRoot.Common_ScreenBox_UIBP, false, true)
end