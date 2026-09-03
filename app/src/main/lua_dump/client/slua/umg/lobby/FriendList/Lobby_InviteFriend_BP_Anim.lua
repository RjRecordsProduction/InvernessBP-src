local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
function Lobby_InviteFriend_BP:OnEnterAnimationFinished()
  log(bWriteLog and "Lobby_InviteFriend_BP:OnEnterAnimationFinished")
  self:ShowTeamQuickGuide()
end