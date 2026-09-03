local ChatTeammateItemUI = {}
function ChatTeammateItemUI:ctor()
end
function ChatTeammateItemUI:SetContent(MarkInfo)
  print(bWriteLog and "ChatTeammateItemUI:SetContent:" .. MarkInfo.Content)
  self.ChatChannelText:SetText(MarkInfo.Content)
  local uGlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local Color = uGlobalBattleUIFunctionLibrary.GetPlayerTeamColor(MarkInfo.TeamIndex)
  self.Image_Mark:SetColorAndOpacity(Color)
  self.Image_MarkBG:SetColorAndOpacity(Color)
  self.Image_Mark:SetBrushfromPathAsync(MarkInfo.IconPath, false)
  self:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function ChatTeammateItemUI:OnDestroy()
  print(bWriteLog and "ChatTeammateItemUI:OnDestroy")
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CChatTeammateItemUI = class(CDelegateContainer, nil, ChatTeammateItemUI)
return CChatTeammateItemUI