local ChatGreatUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MAX_LIKE_COUNT = 3
function ChatGreatUI:ctor()
  self.Index2LikeTeamIdx = {
    [1] = "Ingame_TeamIdx_1",
    [2] = "Ingame_TeamIdx_2",
    [3] = "Ingame_TeamIdx_3"
  }
  self.FontTagMap = {
    [0] = "<TeamIdxFont1>",
    [1] = "<TeamIdxFont2>",
    [2] = "<TeamIdxFont3>",
    [3] = "<TeamIdxFont4>"
  }
  self.ImageTagMap = {
    [0] = "<img src=\"TeamIdxImage1\"/>",
    [1] = "<img src=\"TeamIdxImage2\"/>",
    [2] = "<img src=\"TeamIdxImage3\"/>",
    [3] = "<img src=\"TeamIdxImage4\"/>"
  }
  self.SenderTeamIndex = nil
end
function ChatGreatUI:AddOneMark(QuickSignMsg, ChatMsg, Content)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local GetTeamIndexByName = function(Name)
    if not Name or Name == "" then
      return -1
    end
    if not uPlayerState.GetPlayerInTeamIndexByPlayerState then
      return -1
    end
    local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
    for _, uTeamPlayerState in pairs(TeammatePlayerStateList) do
      if slua.isValid(uTeamPlayerState) and Name == uTeamPlayerState.PlayerName then
        return uPlayerState:GetPlayerInTeamIndexByPlayerState(uTeamPlayerState)
      end
    end
    return -1
  end
  local SenderName = ChatMsg.playerName or ""
  local SenderTeamIndex = GetTeamIndexByName(SenderName)
  if SenderTeamIndex == -1 then
    SenderTeamIndex = 0
  end
  if slua.isValid(self.Ingame_TeamIdx) then
    self.Ingame_TeamIdx:SetTeamIndex(SenderTeamIndex)
    self.Ingame_TeamIdx:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  if slua.isValid(self.HorizontalBox_Like) then
    self.HorizontalBox_Like:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  local ReceiverName = ChatMsg.receiverName or ""
  local DisplayText = ""
  if SenderName ~= "" and ReceiverName ~= "" then
    local ReceiverTeamIndex = GetTeamIndexByName(ReceiverName)
    if ReceiverTeamIndex == -1 then
      ReceiverTeamIndex = 0
    end
    local SenderFontTag = self.FontTagMap[SenderTeamIndex]
    local SenderImageTag = self.ImageTagMap[SenderTeamIndex]
    local SenderTag
    if SenderFontTag then
      SenderTag = (SenderImageTag or "") .. SenderFontTag .. SenderName .. "</>"
    else
      SenderTag = SenderName
    end
    local ReceiverFontTag = self.FontTagMap[ReceiverTeamIndex]
    local ReceiverImageTag = self.ImageTagMap[ReceiverTeamIndex]
    local ReceiverTag
    if ReceiverFontTag then
      ReceiverTag = (ReceiverImageTag or "") .. ReceiverFontTag .. ReceiverName .. "</>"
    else
      ReceiverTag = ReceiverName
    end
    DisplayText = LocUtil.LocalizeResFormatByStr(Content, ReceiverTag, SenderTag)
  else
    local SenderFontTag = self.FontTagMap[SenderTeamIndex]
    local SenderTag
    if SenderFontTag then
      SenderTag = SenderFontTag .. SenderName .. " </>"
    else
      SenderTag = SenderName .. " "
    end
    DisplayText = SenderTag .. Content
    self.Ingame_TeamIdx:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
  self.ChatGreatText:SetText(DisplayText)
  self:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.  print("ChatGreatUI:AddOneMark", SenderTeamIndex)
  if self.FadeIn then
    self:PlayUserWidgetAnimation(self.FadeIn, 0, 1, 0, 1)
  end
end
function ChatGreatUI:AppendLikeTeamIdx(ChatMsg)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.GetPlayerInTeamIndexByPlayerState then
    return
  end
  local ReplierName = ChatMsg and (ChatMsg.playerName or "")
  local TeamIndex = -1
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  for _, uTeamPlayerState in pairs(TeammatePlayerStateList) do
    if slua.isValid(uTeamPlayerState) and uTeamPlayerState.PlayerName == ReplierName then
      TeamIndex = uPlayerState:GetPlayerInTeamIndexByPlayerState(uTeamPlayerState)
      break
    end
  end
  if TeamIndex == -1 then
    return
  end
  for i = 1, MAX_LIKE_COUNT do
    local WidgetName = self.Index2LikeTeamIdx[i]
    local Widget = self[WidgetName]
    if slua.isValid(Widget) then
      local Visibility = Widget:GetVisibility()
      local bEmpty = Visibility == UEnums.GSlateVisibility.Collapsed or Visibility == UEnums.GSlateVisibility.Hidden
      if bEmpty then
        print(bWriteLog and string.format("ChatGreatUI:AppendLikeTeamIdx - slot:%d TeamIndex:%d playerName:%s", i, TeamIndex, ReplierName))
        Widget:SetTeamIndex(TeamIndex)
        Widget:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
        if self.Anim_Like_Fadien then
          self:PlayUserWidgetAnimation(self.Anim_Like_Fadien, 0, 1, 0, 1)
        end
        break
      end
    end
  end
  if slua.isValid(self.HorizontalBox_Like) then
    self.HorizontalBox_Like:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
end
function ChatGreatUI:AddReplyMark(ChatMsg)
  self:AppendLikeTeamIdx(ChatMsg)
end
function ChatGreatUI:ClearMark()
  if slua.isValid(self.ChatGreatText) then
    self.ChatGreatText:SetText("")
  end
  if slua.isValid(self.Ingame_TeamIdx) then
    self.Ingame_TeamIdx:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  if slua.isValid(self.Ingame_TeamIdx_Receiver) then
    self.Ingame_TeamIdx_Receiver:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  if slua.isValid(self.HorizontalBox_Like) then
    self.HorizontalBox_Like:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  for i = 1, MAX_LIKE_COUNT do
    local WidgetName = self.Index2LikeTeamIdx[i]
    local Widget = self[WidgetName]
    if slua.isValid(Widget) then
      Widget:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self:StopAnimation(self.Anim_Fire_01)
  self:StopAnimation(self.Anim_Fire_02)
end
function ChatGreatUI:OnDestroy()
  print(bWriteLog and "ChatGreatUI:OnDestroy")
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CChatGreatUI = class(CDelegateContainer, nil, ChatGreatUI)
return CChatGreatUI