local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
function Lobby_InviteFriend_BP:SetWOWWorkName()
  if self.modInfo and self.modInfo.setting then
    local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
    local Data = LogicTeamUpSideBar.GetFriends() or {}
    local AllData = logic_ugc_mode:GetWOWFriendList(self.modInfo.mod_id, Data)
    self.UIRoot.TextBlock_Name:SetText(self.modInfo.setting.name)
    local Index = #AllData or 0
    self.UIRoot.TextBlock_Nomber_friends:SetText(Index)
  else
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local ugcMatchInfo = LogicUGCMatch:GetUgcMatchModInfo()
    if ugcMatchInfo and ugcMatchInfo.setting then
      self.UIRoot.TextBlock_Name:SetText(ugcMatchInfo.setting.name)
    end
  end
end
function Lobby_InviteFriend_BP:ShowFriendWOW()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local TabID = logic_friend_list_ui:GetTabID()
  if TabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG or self.modInfo then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_WowFriend, true)
    self:SetWOWWorkName()
    self:SetWidgetVisible(self.UIRoot.ExtendedLoopScrollGrid_1, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_WowFriend, false)
    self:SetWidgetVisible(self.UIRoot.ExtendedLoopScrollGrid_1, false, true)
  end
end