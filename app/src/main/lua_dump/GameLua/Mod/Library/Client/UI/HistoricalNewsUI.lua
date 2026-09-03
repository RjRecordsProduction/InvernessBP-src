local GameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HistoricalNewsUI = {}
function HistoricalNewsUI:ctor()
  self.ChildTextConut = 4
  self.LocalizeSearchText = table.concat({
    ">",
    LocUtil.GetLocalizeResStr(101717),
    LocUtil.GetLocalizeResStr(4164),
    "<"
  })
  self.Index2ChildText = {
    [0] = "ChatTextOne",
    [1] = "ChatTextTwo",
    [2] = "ChatTextThree",
    [3] = "ChatTextFour"
  }
  self.Index2HorizontalBox = {
    [0] = "HorizontalBoxForChildOne",
    [1] = "HorizontalBoxForChildTwo",
    [2] = "HorizontalBoxForChildThree",
    [3] = "HorizontalBoxForChildFour"
  }
  self.Index2IngameTeamIdx = {
    [0] = "IngameTeamIdxOne",
    [1] = "IngameTeamIdxTwo",
    [2] = "IngameTeamIdxThree",
    [3] = "IngameTeamIdxFour"
  }
  self.SystemSearchText = "<ChatReportMail>"
  self.MinAlpha = 0.3
  self.BlazingDataMap = {}
end
function HistoricalNewsUI:OnInitialize()
  HistoricalNewsUI.__super.OnInitialize(self)
  self:AddUIMessageEvent("UIMsg_AddOneMsgtoUIInner", self.OnAddOneMsgtoUIInner, self)
  self:AddUIMessageEvent("UIMsg_CloseChatHistoryList", self.OnCloseChatHistoryList, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESH_CHAT, self.HandleOnAddOneMark, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVNETID_INGAME_CLEAN_CHAT_MSG, self.ClearMsg, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_BLAZING_STATE_CHANGED, self.OnBlazingStateChanged, self)
  self:AddControlEventByControl(self.UIRoot.CustomizeCanvasPanel_BP, "OnCustomLayoutChangeEvent", self.OnApplyCustomSetting, self)
  self:InitSpecialLikeMsg()
end
function HistoricalNewsUI:OnBlazingStateChanged(_, __, TeamIdx, BlazingState, BlazingScore)
  print(bWriteLog and "HistoricalNewsUI:OnBlazingStateChanged", TeamIdx, BlazingState, BlazingScore)
  self.BlazingDataMap[TeamIdx] = {
    State = BlazingState,
    Score = BlazingScore or 0
  }
  for _, WidgetName in pairs(self.Index2IngameTeamIdx) do
    local IngameTeamIdx = self.UIRoot[WidgetName]
    if slua.isValid(IngameTeamIdx) and IngameTeamIdx.TeamIdx == TeamIdx then
      self:_RefreshBlazingFire(IngameTeamIdx, BlazingState, BlazingScore or 0)
    end
  end
end
function HistoricalNewsUI:_RefreshBlazingFire(IngameTeamIdx, BlazingState, BlazingScore)
  if not slua.isValid(IngameTeamIdx) then
    return
  end
  local BlazeConfig = require("GameLua.Mod.BRMod.Gameplay.Feature.Blazing.BlazeConfig")
  local IsAnyBlaze = BlazingState == BlazeConfig.EBlazeState.Active or BlazingState == BlazeConfig.EBlazeState.FadeOut and BlazingScore >= BlazeConfig.BLAZE_SCORE_FADEOUT_THRESHOLD
  if IsAnyBlaze then
    if not IngameTeamIdx.BlazeAnimPlayed then
      IngameTeamIdx:PlayUserWidgetAnimation(IngameTeamIdx.Anim_Loop_01, 0, 1, 0, 1)
      IngameTeamIdx.BlazeAnimPlayed = true
    end
    IngameTeamIdx.Border_AnimBot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    IngameTeamIdx.Border_AnimBot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    IngameTeamIdx.BlazeAnimPlayed = false
  end
end
function HistoricalNewsUI:GetChatBox(Index)
  local ChatBox = self.Index2HorizontalBox[Index]
  if ChatBox then
    return self.UIRoot[ChatBox]
  end
  return nil
end
function HistoricalNewsUI:InitSpecialLikeMsg()
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  local StringUtil = require("common.string_util")
  self.GreatMsgTypeMap = {}
  local CollectMsgIDs = function(TableID)
    if not TableID then
      return
    end
    local Data = CDataTable.GetTableData("IngameLikeConfigTable", TableID)
    if Data and Data.Value then
      local MsgIDs = StringUtil.Split(Data.Value, " ")
      for _, MsgID in ipairs(MsgIDs) do
        local MsgIDNum = tonumber(MsgID)
        if MsgIDNum then
          self.GreatMsgTypeMap[MsgIDNum] = true
        end
      end
    end
  end
  for k, v in pairs(IngameLikeConfig) do
    if type(k) == "number" and type(v) == "table" and v.bSendBack then
      CollectMsgIDs(v.TeamChatMessageID)
      CollectMsgIDs(v.ThanksChatMessageID)
    end
  end
end
function HistoricalNewsUI:OnAddOneMsgtoUIInner()
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  local ChatComponent = PC:GetChatComponent()
  if not slua.isValid(ChatComponent) or not ChatComponent.UITextArray then
    return
  end
  local ChatMsg = ChatComponent.CurrMsg
  local MsgID = ChatMsg and ChatMsg.msgID
  local bIsMultiLikeReply = ChatComponent.bIsMultiLikeReply
  local bIspendingSoleLikeMsg = ChatComponent.bIsSoleLikeMsg
  if bIsMultiLikeReply or bIspendingSoleLikeMsg then
    local UITextArray = ChatComponent.UITextArray
    if bIsMultiLikeReply then
      self:AddGreatReplyMark(ChatMsg)
      ChatComponent.bIsMultiLikeReply = false
      if UITextArray and UITextArray:Num() > 0 then
        UITextArray:Remove(UITextArray:Num() - 1)
      end
    else
      ChatComponent.bIsSoleLikeMsg = false
      if MsgID and self.GreatMsgTypeMap[MsgID] and UITextArray and UITextArray:Num() > 0 then
        UITextArray:Remove(UITextArray:Num() - 1)
      end
    end
    return
  end
  local UITextArray = ChatComponent.UITextArray
  local UITextArrayLen = UITextArray:Num()
  local LeftChildTextCount = self.ChildTextConut - UITextArrayLen - 1
  if 0 < LeftChildTextCount then
    for i = 0, LeftChildTextCount do
      self:SetChatScrollText(i, "")
    end
  end
  local FirstIndex = self.ChildTextConut - UITextArrayLen
  local LastIndex = self.ChildTextConut - 1
  ChatComponent.firstIndex = FirstIndex
  for i = 0, LastIndex do
    local ActualIndex = i - FirstIndex
    if 0 <= ActualIndex and UITextArrayLen > ActualIndex then
      local TextContent = UITextArray:Get(ActualIndex)
      if TextContent then
        self:SetChatScrollText(i, TextContent)
      end
    end
  end
  self:SetWidgetVisible(self.UIRoot.ChatScrollBox, true)
  self:SetWidgetVisible(self.UIRoot.HistoricalNews, true)
  self.UIRoot.ChatScrollBox:ScrollToEnd()
  ChatComponent.lastShowChatTime = GameplayStatics.GetTimeSeconds(CGameWorld)
end
function HistoricalNewsUI:OnCloseChatHistoryList()
  self:SetWidgetVisible(self.UIRoot.ChatScrollBox, false)
  self:SetWidgetVisible(self.UIRoot.HistoricalNews, false)
  self:ClearMark()
end
function HistoricalNewsUI:SetChatScrollText(Index, TextContent)
  if TextContent == nil or TextContent == "" then
    local ChatBox = self:GetChatBox(Index)
    if ChatBox then
      ChatBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    return
  end
  local ChatBox = self:GetChatBox(Index)
  if ChatBox then
    ChatBox:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
  local ChildText = self:GetChatScrollBoxChildText(Index)
  if ChildText then
    ChildText:SetText(TextContent)
    self:AddTimer(0.1, function()
      if ChildText and slua.isValid(ChildText) then
        ChildText:ForceLayoutPrepass()
        ChildText:InvalidateLayoutCache()
      end
    end)
  end
  self:SetChatScrollBoxTeamIdx(Index, TextContent)
  self:SetCustomTeamIdxView(Index)
end
function HistoricalNewsUI:SetChatScrollBoxTeamIdx(Index, TextContent)
  if TextContent == nil then
    return
  end
  local IngameTeamIdx = self:GetChatScrollBoxChildTeamIdx(Index)
  local ColonText = LocUtil.GetLocalizeResStr(4164)
  if IngameTeamIdx then
    print(bWriteLog and "HistoricalNewsUI:SetChatScrollBoxTeamIdx")
    self:SetWidgetVisible(IngameTeamIdx, false)
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) and PlayerState.GetTeamMatePlayerStateList then
      local PlayerStateList = PlayerState:GetTeamMatePlayerStateList({}, false)
      local TargetPlayerKey = PlayerState:GetStringPlayerKey()
      local bFindSearchText = false
      if string.find(TextContent, self.LocalizeSearchText) or string.find(TextContent, self.SystemSearchText) then
        bFindSearchText = true
      end
      for i = 0, PlayerStateList:Num() - 1 do
        local TeamMatePlayerState = PlayerStateList:Get(i)
        if slua.isValid(TeamMatePlayerState) then
          local bCanEnterNextStep = false
          if bFindSearchText then
            local TeamMatePlayerKey = TeamMatePlayerState:GetStringPlayerKey()
            if TargetPlayerKey == TeamMatePlayerKey then
              bCanEnterNextStep = true
            end
          elseif string.find(TextContent, ">" .. TeamMatePlayerState.PlayerName .. ColonText) then
            bCanEnterNextStep = true
          end
          if bCanEnterNextStep then
            self:SetWidgetVisible(IngameTeamIdx, true)
            IngameTeamIdx:SetTeamIndex(i)
            local CachedData = self.BlazingDataMap[i]
            if CachedData ~= nil then
              self:_RefreshBlazingFire(IngameTeamIdx, CachedData.State, CachedData.Score)
            else
              IngameTeamIdx.Border_AnimBot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
              IngameTeamIdx.BlazeAnimPlayed = false
            end
          end
        end
      end
    end
  end
end
function HistoricalNewsUI:SetCustomTeamIdxView(Index)
  local IngameTeamIdx = self:GetChatScrollBoxChildTeamIdx(Index)
  if not slua.isValid(IngameTeamIdx) then
    return
  end
  IngameTeamIdx.TextBlock_TeamIdx:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  IngameTeamIdx.Image_IDBG:SetBrush(nil)
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  local ChatComponent = PC:GetChatComponent()
  if not slua.isValid(ChatComponent) or not ChatComponent.UITextArray then
    return
  end
  local UITextArray = ChatComponent.UITextArray
  local UITextArrayLen = UITextArray:Num()
  local CurMsgIndex = Index - (self.UIRoot.ChatScrollBox:GetChildrenCount() - UITextArrayLen)
  local CurMsgID = ChatComponent.UIMsgIDMap:Get(CurMsgIndex)
  if not CurMsgID or CurMsgID == 0 then
    return
  end
  local CustomTeamIdxConfig = require("GameLua.Mod.BaseMod.Client.ShootingUI.CustomTeamIdxConfig")
  local CustomCfg = CustomTeamIdxConfig[CurMsgID]
  if CustomCfg and CustomCfg.ModulePath and CustomCfg.RefreshFunctionName then
    local CustomTeamIdxModule = require(CustomCfg.ModulePath)
    if CustomTeamIdxModule and CustomTeamIdxModule[CustomCfg.RefreshFunctionName] then
      local RefreshTeamIdxFunc = CustomTeamIdxModule[CustomCfg.RefreshFunctionName]
      RefreshTeamIdxFunc(IngameTeamIdx, Index, CurMsgID)
    end
  end
end
function HistoricalNewsUI:GetChatScrollBoxChildTeamIdx(Index)
  local IngameTeamIdxName = self.Index2IngameTeamIdx[Index]
  if IngameTeamIdxName then
    return self.UIRoot[IngameTeamIdxName]
  end
  return nil
end
function HistoricalNewsUI:GetChatScrollBoxChildText(Index)
  local ChildTextName = self.Index2ChildText[Index]
  if ChildTextName then
    return self.UIRoot[ChildTextName]
  end
  return nil
end
function HistoricalNewsUI:HandleOnAddOneMark()
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  local ChatComponent = PC:GetChatComponent()
  if not slua.isValid(ChatComponent) or not ChatComponent.UITextArray then
    return
  end
  local QuickSignComponent = PC:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) then
    return
  end
  local ChatMsg = ChatComponent.CurrMsg
  local MsgComtent = ChatComponent.MarkText
  local QuickSignMsg = QuickSignComponent.currMsg
  self:AddOneMark(QuickSignMsg, ChatMsg, MsgComtent)
  self:SetWidgetVisible(self.UIRoot.ChatScrollBox, true)
  self:SetWidgetVisible(self.UIRoot.HistoricalNews, true)
  ChatComponent.lastShowChatTime = GameplayStatics.GetTimeSeconds(CGameWorld)
end
function HistoricalNewsUI:AddOneMark(QuickSignMsg, ChatMsg, MsgComtent)
  self.UIRoot.Chat_Teammate_UIBP:AddOneMark(QuickSignMsg, ChatMsg, MsgComtent)
end
function HistoricalNewsUI:AddGreatMark(QuickSignMsg, ChatMsg, MsgComtent)
  self.UIRoot.Chat_Great_BP:AddOneMark(QuickSignMsg, ChatMsg, MsgComtent)
  self:SetWidgetVisible(self.UIRoot.HistoricalNews, true)
  local PC = GameplayData.GetPlayerController()
  if slua.isValid(PC) then
    local ChatComponent = PC:GetChatComponent()
    if slua.isValid(ChatComponent) then
      ChatComponent.lastShowChatTime = GameplayStatics.GetTimeSeconds(CGameWorld)
    end
  end
end
function HistoricalNewsUI:AddGreatReplyMark(ChatMsg)
  self.UIRoot.Chat_Great_BP:AddReplyMark(ChatMsg)
  self:SetWidgetVisible(self.UIRoot.HistoricalNews, true)
  local PC = GameplayData.GetPlayerController()
  if slua.isValid(PC) then
    local ChatComponent = PC:GetChatComponent()
    if slua.isValid(ChatComponent) then
      ChatComponent.lastShowChatTime = GameplayStatics.GetTimeSeconds(CGameWorld)
    end
  end
end
function HistoricalNewsUI:ClearMark()
  for i = 0, self.ChildTextConut - 1 do
    self:SetChatScrollText(i, "")
  end
  self.UIRoot.Chat_Teammate_UIBP:ClearMark()
  self.UIRoot.Chat_Great_BP:ClearMark()
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  local ChatComponent = PC:GetChatComponent()
  if not slua.isValid(ChatComponent) or not ChatComponent.UITextArray then
    return
  end
  ChatComponent.UITextArray:Clear()
end
function HistoricalNewsUI:ClearMsg()
  self:ClearMark()
end
function HistoricalNewsUI:OnApplyCustomSetting()
  print(bWriteLog and "HistoricalNewsUI:OnApplyCustomSetting")
  if not slua.isValid(self.UIRoot.CustomizeCanvasPanel_BP) then
    return
  end
  local Opacity = self.UIRoot.CustomizeCanvasPanel_BP:GetOpacity()
  if Opacity then
    Opacity = math.max(Opacity, self.MinAlpha)
    self.UIRoot.CustomizeCanvasPanel_BP:SetOpacity(Opacity)
  end
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, HistoricalNewsUI)