local ChatTeammateUI = {}
function ChatTeammateUI:ctor()
  self.DefaultIcon = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_biaodian_baise_png.DJ_Icon_biaodian_baise_png"
end
function ChatTeammateUI:AddOneMark(QuickSignMsg, ChatMsg, Content)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    return
  end
  if not self.CurrentMark then
    self.CurrentMark = {}
  elseif self.CurrentMark[1] then
    self.CurrentMark[0] = self.CurrentMark[1]
    self.CurrentMark[1] = nil
    self.Chat_Item1:SetContent(self.CurrentMark[0])
  end
  local newIndex = self.CurrentMark[0] and 1 or 0
  local PlayerName = ""
  if QuickSignMsg.MsgID ~= "" then
    if 0 < QuickSignMsg.BindActorGUID then
      self.CurrentMark[newIndex] = {}
      self.CurrentMark[newIndex].      PlayerName = QuickSignMsg.PlayerName
    else
      self.CurrentMark[newIndex] = {}
      self.CurrentMark[newIndex].      PlayerName = QuickSignMsg.PlayerName
    end
    self.CurrentMark[newIndex].MsgID = QuickSignMsg.MsgID
    local IconPath = self:GetQuickSignIcon(QuickSignMsg.ConfigKey)
    self.CurrentMark[newIndex].  elseif ChatMsg.msgID ~= 0 then
    if 0 < ChatMsg.itemID then
      self.CurrentMark[newIndex] = {}
      self.CurrentMark[newIndex].      PlayerName = ChatMsg.playerName
      local IconPath = self:GetChatSignIcon(true)
      self.CurrentMark[newIndex].    else
      self.CurrentMark[newIndex] = {}
      self.CurrentMark[newIndex].      PlayerName = ChatMsg.playerName
      local IconPath = self:GetChatSignIcon(false)
      self.CurrentMark[newIndex].    end
  end
  self.CurrentMark[newIndex].TeamIndex = 0
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  for index, uTeamPlayerState in pairs(TeammatePlayerStateList) do
    if slua.isValid(uTeamPlayerState) and PlayerName == uTeamPlayerState.PlayerName then
      self.CurrentMark[newIndex].TeamIndex = index
    end
  end
  if newIndex == 0 then
    self.Chat_Item1:SetContent(self.CurrentMark[newIndex])
  elseif newIndex == 1 then
    self.Chat_Item2:SetContent(self.CurrentMark[newIndex])
  end
  self:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function ChatTeammateUI:GetQuickSignIcon(ConfigKey)
  local ConfigData = CDataTable.GetTableData("QuickSignCfg", ConfigKey)
  if ConfigData then
    return ConfigData.IconPath
  end
  return self.DefaultIcon
end
function ChatTeammateUI:GetChatSignIcon(bIsItem)
  if bIsItem then
    return "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_KJZL_wuzhi_png.ZD_image_KJZL_wuzhi_png"
  else
    return "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_jingshi_png.DJ_Icon_jingshi_png"
  end
end
function ChatTeammateUI:ClearMark()
  self.CurrentMark = {}
  self.Chat_Item1:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.Chat_Item2:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function ChatTeammateUI:OnDestroy()
  print(bWriteLog and "ChatTeammateUI:OnDestroy")
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CChatTeammateUI = class(CDelegateContainer, nil, ChatTeammateUI)
return CChatTeammateUI