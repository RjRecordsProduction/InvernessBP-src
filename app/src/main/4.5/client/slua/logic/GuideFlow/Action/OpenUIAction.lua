local OpenUIAction = {
  HoldingAction = {},
  FriendSideNormal = 1,
  FriendSideSuper = 2,
  TeamNormal = 3,
  TeamSuper = 4,
  MentorNormal = 5,
  MentorSuper = 6,
  SocialIslandNormal = 7,
  SocialIslandSuper = 8,
  ShowingType = 0
}
function OpenUIAction.Run(node, uiType, param2)
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "OpenUIAction.Run uiType = " .. uiType)
  local isNormal = param2 == "Normal" and true or false
  if uiType == "FriendSide" then
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain then
      local Lobby_Mid_Friend_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Friend_UIBP)
      if Lobby_Mid_Friend_UIBP and (not UIManager.GetUI(UIManager.UI_Config.Common_Normal_Tips_UIBP) or OpenUIAction.ShowingType ~= 5) and (not UIManager.GetUI(UIManager.UI_Config.Common_Special_Tips_UIBP) or OpenUIAction.ShowingType ~= 6) then
        Lobby_Mid_Friend_UIBP:ShowFriendTipsGuideFlow(isNormal)
        return
      end
    end
    local label = isNormal and OpenUIAction.FriendSideNormal or OpenUIAction.FriendSideSuper
    OpenUIAction.HoldingAction[label] = 1
  elseif uiType == "TeamPlatform" then
    OpenUIAction.OpenBubbleUI(LobbyMidTipsType.TeamPlatformGuideFlow, isNormal)
  elseif uiType == "Mentor" then
    OpenUIAction.OpenBubbleUI(LobbyMidTipsType.MentorBubbleGuideFlow, isNormal)
  elseif uiType == "SocialIsland" then
    OpenUIAction.OpenBubbleUI(LobbyMidTipsType.SocialIslandGuideFlow, isNormal)
  end
end
function OpenUIAction.OpenBubbleUI(tipsType, isNormal)
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local Lobby_Mid_Message_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
    if Lobby_Mid_Message_UIBP and (tipsType ~= LobbyMidTipsType.MentorBubbleGuideFlow or (not UIManager.GetUI(UIManager.UI_Config.Common_Normal_Tips_UIBP) or OpenUIAction.ShowingType ~= 1) and (not UIManager.GetUI(UIManager.UI_Config.Common_Special_Tips_UIBP) or OpenUIAction.ShowingType ~= 2)) then
      Lobby_Mid_Message_UIBP:TryShowTipsOutSide(tipsType, isNormal)
      return
    end
  end
  local label = 0
  if tipsType == LobbyMidTipsType.TeamPlatformGuideFlow and isNormal then
    label = OpenUIAction.TeamNormal
  elseif tipsType == LobbyMidTipsType.TeamPlatformGuideFlow and not isNormal then
    label = OpenUIAction.TeamSuper
  elseif tipsType == LobbyMidTipsType.MentorBubbleGuideFlow and isNormal then
    label = OpenUIAction.MentorNormal
  elseif tipsType == LobbyMidTipsType.MentorBubbleGuideFlow and not isNormal then
    label = OpenUIAction.MentorSuper
  elseif tipsType == LobbyMidTipsType.SocialIslandGuideFlow and isNormal then
    label = OpenUIAction.SocialIslandNormal
  elseif tipsType == LobbyMidTipsType.SocialIslandGuideFlow and not isNormal then
    label = OpenUIAction.SocialIslandSuper
  end
  OpenUIAction.HoldingAction[label] = 1
end
function OpenUIAction.HandleHoldingAction()
  for k, v in pairs(OpenUIAction.HoldingAction) do
    OpenUIAction.HoldingAction[k] = nil
    if k == OpenUIAction.FriendSideNormal then
      OpenUIAction.Run(nil, "FriendSide", "Normal")
    elseif k == OpenUIAction.FriendSideSuper then
      OpenUIAction.Run(nil, "FriendSide", "Super")
    elseif k == OpenUIAction.TeamNormal then
      OpenUIAction.Run(nil, "TeamPlatform", "Normal")
    elseif k == OpenUIAction.TeamSuper then
      OpenUIAction.Run(nil, "TeamPlatform", "Super")
    elseif k == OpenUIAction.MentorNormal then
      OpenUIAction.Run(nil, "Mentor", "Normal")
    elseif k == OpenUIAction.MentorSuper then
      OpenUIAction.Run(nil, "Mentor", "Super")
    elseif k == OpenUIAction.SocialIslandNormal then
      OpenUIAction.Run(nil, "SocialIsland", "Normal")
    elseif k == OpenUIAction.SocialIslandSuper then
      OpenUIAction.Run(nil, "SocialIsland", "Super")
    end
  end
end
return OpenUIAction