local IngameLikeUIBP = {}
local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function IngameLikeUIBP:OnInitialize()
  print(bWriteLog and "[IngameLikeUIBP] OnInitialize")
  if self.RefreshFailed then
    self.RefreshFailed = false
    self:RefreshView(self.Message, self.bShowShakeHand)
  end
  IngameLikeUIBP.__super.OnInitialize(self)
  self.IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  self.ClickBtnRange = 10
end
function IngameLikeUIBP:RegistEvents()
  print(bWriteLog and "[IngameLikeUIBP] RegistEvents")
  IngameLikeUIBP.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEndedEvent", self.OnTouchEnded, self)
  self:AddCommonBtnEvent("ButtonLike", self.OnClickButtonLike)
  self:AddCommonBtnEvent("Button_Ganxie", self.OnClickButtonLike)
  self:AddCommonBtnEvent("Button_Jiayou", self.OnClickButtonLike)
  self:AddCommonBtnEvent("Button_Qinzhu", self.OnClickButtonLike)
  self:AddCommonBtnEvent("Button_Huikui", self.OnClickShakeHand)
  self:AddCommonBtnEvent("Button_Reply", self.OnClickReply)
  self:AddCommonBtnEvent("Button_ReplyTactical", self.OnClickReply)
  self:AddCommonBtnEvent("Button_EnterVehicle", self.OnClickReply)
  self:AddCommonBtnEvent("Button_HoldOn", self.OnClickReply)
  self:AddCommonBtnEvent("Button_Cooperate", self.OnClickReply)
  self:AddCommonBtnEvent("Button_QuickResponse", self.OnClickReply)
  self:AddCommonEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_ENTER_PLANE, self.HideTip, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_MVP_CAMERA_CLOSE, function()
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_MVP_CAMERA_Open, function()
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end, self)
end
function IngameLikeUIBP:AddCommonBtnEvent(BtnName, ClickFunc)
  self:AddControlEvent(BtnName, "OnPressedParam", self.OnPressBtn, self, ClickFunc)
end
function IngameLikeUIBP:OnPressBtn(ClickFunc, MyGeometry, MouseEvent)
  local UKismetInputLibrary = import("KismetInputLibrary")
  self.BtnDownScreenPos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  self.Curend
function IngameLikeUIBP:OnTouchEnded(MouseEvent)
  if self.CurClickFunc == nil then
    return
  end
  local UKismetInputLibrary = import("KismetInputLibrary")
  self.BtnCurScreenPos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  if self.BtnDownScreenPos == nil or self.BtnCurScreenPos == nil then
    self.CurClickFunc(self)
  elseif math.abs(self.BtnDownScreenPos.X - self.BtnCurScreenPos.X) < self.ClickBtnRange and math.abs(self.BtnDownScreenPos.Y - self.BtnCurScreenPos.Y) < self.ClickBtnRange then
    self.CurClickFunc(self)
  end
  self.CurClickFunc = nil
  self.BtnDownScreenPos = nil
  self.BtnCurScreenPos = nil
end
function IngameLikeUIBP:OnClickButtonLike()
  print(bWriteLog and "[IngameLikeUIBP] OnClickButtonLike")
  if not self.Config then
    return
  end
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:SendLike(self.Message.PlayerKey, self.Config.ConditionID)
    local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
    ClientTLogUtil.ReportCommonTLogDataByBRPhase(216, 216, tostring(self.Config.ConditionID), 1)
  end
  local Data = CDataTable.GetTableData("IngameLikeConfigTable", self.Config.TeamChatMessageID)
  if Data then
    local StringUtil = require("common.string_util")
    local MsgIDs = StringUtil.Split(Data.Value, " ")
    local Random = math.random(1, #MsgIDs)
    if self:GetIngameLikeClientSubSystem() then
      if self.Config.bSendTo then
        self.IngameLikeClientSubSystem:SendTeamChat(MsgIDs[Random], self.Message.PlayerKey, self.Config.ConditionID)
      else
        self.IngameLikeClientSubSystem:SendTeamChat(MsgIDs[Random], "0", self.Config.ConditionID)
      end
    end
    sandbox.LogNormal(bWriteLog and "IngameLikeUIBP: OnClickButtonLike MsgIDs=" .. tostring(MsgIDs[Random]) .. " playerkey=" .. tostring(self.Message.PlayerKey) .. " condition=" .. tostring(self.Config.ConditionID))
  end
  self:SetButtonDisable()
  self:HideTip()
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  if self.Config and self.Config.ConditionID == IngameLikeConfig.Win then
    self:AddTimer(3, function()
      self:Close()
    end)
  elseif self.Config and self.Config.ConditionID == IngameLikeConfig.Start then
    self.HideTimer = self:AddTimer(3, function()
      self:Hide()
    end)
  else
    self:Hide()
  end
  self:ShowIntimacyTip()
end
function IngameLikeUIBP:SetButtonEnable()
  print(bWriteLog and "[IngameLikeUIBP] SetButtonEnable")
  if not self.UIRoot then
    print(bWriteLog and "[IngameLikeUIBP] invalid uiroot")
    return
  end
  self.UIRoot.ButtonLike:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_Ganxie:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_Jiayou:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_Qinzhu:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_Huikui:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_Reply:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_QuickResponse:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function IngameLikeUIBP:SetButtonDisable()
  print(bWriteLog and "[IngameLikeUIBP] SetButtonDisable")
  if not self.UIRoot then
    print(bWriteLog and "[IngameLikeUIBP] invalid uiroot")
    return
  end
  self.UIRoot.ButtonLike:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Button_Ganxie:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Button_Jiayou:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Button_Qinzhu:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Button_Huikui:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Button_Reply:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Button_QuickResponse:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function IngameLikeUIBP:GetIngameLikeClientSubSystem()
  if nil == self.IngameLikeClientSubSystem then
    self.IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
    if self.IngameLikeClientSubSystem == nil then
      print(bWriteLog and "Ingame_WatchLike_UIBP cannot get IngameLikeClientSubSystem!!!")
    end
  end
  return self.IngameLikeClientSubSystem
end
function IngameLikeUIBP:OnClickShakeHand()
  print(bWriteLog and "[IngameLikeUIBP] OnClickShakeHand")
  if not self.Config then
    return
  end
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:SendRespondLike(self.Config.ConditionID, self.Message.UID)
  end
  local Data = CDataTable.GetTableData("IngameLikeConfigTable", self.Config.ThanksChatMessageID)
  if Data then
    local StringUtil = require("common.string_util")
    local MsgIDs = StringUtil.Split(Data.Value, " ")
    local Random = math.random(1, #MsgIDs)
    if self:GetIngameLikeClientSubSystem() then
      self.IngameLikeClientSubSystem:SendTeamChat(MsgIDs[Random], "0", self.Config.ConditionID)
    end
  end
  self:SetButtonDisable()
  self:Hide()
end
function IngameLikeUIBP:OnClickReply()
  print(bWriteLog and "[IngameLikeUIBP] OnClickReply")
  if not self.Config then
    return
  end
  local Data = CDataTable.GetTableData("IngameLikeConfigTable", self.Config.TeamChatMessageID)
  if Data then
    local StringUtil = require("common.string_util")
    local MsgIDs = StringUtil.Split(Data.Value, " ")
    local Random = math.random(1, #MsgIDs)
    if self:GetIngameLikeClientSubSystem() then
      self.IngameLikeClientSubSystem:SendTeamChat(MsgIDs[Random], "0", self.Config.ConditionID)
    end
  end
  self:SetButtonDisable()
  self:Hide()
end
function IngameLikeUIBP:RefreshView(Message, bShowShakeHand)
  log_tree("[IngameLikeUIBP] RefreshView", Message)
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  if self.CurShowingType then
    print(bWriteLog and "IngameLikeUIBP:RefreshView Priority", IngameLikeConfig[Message.ConditionID].Priority, IngameLikeConfig[self.CurShowingType].Priority)
    if IngameLikeConfig[Message.ConditionID].Priority < IngameLikeConfig[self.CurShowingType].Priority then
      return
    end
  end
  self.  print(bWriteLog and "IngameLikeUIBP:RefreshView", Message.ConditionID)
  self.Config = IngameLikeConfig[Message.ConditionID]
  if not self.Config then
    return
  end
  self.  local WidgetSwitcherIndex = self.Config.WidgetSwitcherIndex
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    self.RefreshFailed = true
    return
  end
  if not self.UIRoot then
    return
  end
  if bShowShakeHand then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2)
  else
    local bHeartIcon = false
    if Message.ConditionID == IngameLikeConfig.KillBack or Message.ConditionID == IngameLikeConfig.Rescue or Message.ConditionID == IngameLikeConfig.SendItem then
      local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
      if slua.isValid(PlayerState) and PlayerState.UID == Message.OtherPlayerUID then
        bHeartIcon = true
      end
    end
    if bHeartIcon then
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    else
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(WidgetSwitcherIndex)
    end
  end
  self.CurShowingType = Message.ConditionID
  self:AddTimer(0.1, function()
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if MainControlBaseUI then
      self:Show()
      self:SetButtonEnable()
      self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.ShowTimeStamp = os.time()
      self:SetProgress()
    else
      self:Hide()
    end
  end)
  if not self.Config.bAlwaysShow then
    self.HideTimer = self:AddTimer(7, function()
      self:Hide(Message.ConditionID)
    end)
  end
end
function IngameLikeUIBP:Hide(CloseType)
  print(bWriteLog and "IngameLikeUIBP:Hide", self.CurShowingType, CloseType)
  if not CloseType or CloseType ~= self.CurShowingType then
  end
  IngameLikeUIBP.__super.Hide(self)
  self.CurShowingType = nil
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:OnLikeUIHide()
  end
  if self.HideTimer then
    self:RemoveTimer(self.HideTimer)
    self.HideTimer = nil
  end
end
function IngameLikeUIBP:SetProgress()
  local like_count = 0
  if self:GetIngameLikeClientSubSystem() then
    like_count = self.IngameLikeClientSubSystem:GetLikeCount()
  end
  local team_mate_num = IngameLikeUtilClient.GetTeammateCount()
  if not self.UIRoot then
    return
  end
  print(bWriteLog and "[IngameLikeUIBP] SetProgress", like_count, team_mate_num)
  if 0 < team_mate_num then
    if 0 < like_count then
      self.UIRoot.CanvasPanel_Progress_Circle:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.CanvasPanel_Progress_Circle:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local mat = self.UIRoot.Image_Progress:GetDynamicMaterial()
    if mat then
      mat:SetScalarParameterValue("Mask_Percent", like_count / team_mate_num)
    end
  else
    self.UIRoot.CanvasPanel_Progress_Circle:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  if not self.UIRoot.WidgetSwitcher_9 then
    return
  end
  if self.Config.ConditionID == IngameLikeConfig.Start then
    if team_mate_num == like_count then
      self.UIRoot.WidgetSwitcher_9:SetActiveWidgetIndex(1)
    else
      self.UIRoot.WidgetSwitcher_9:SetActiveWidgetIndex(0)
    end
  elseif self.Config.ConditionID == IngameLikeConfig.Win then
    self.UIRoot.WidgetSwitcher_9:SetActiveWidgetIndex(2)
  end
end
function IngameLikeUIBP:HideTip()
  print(bWriteLog and "[IngameLikeUIBP] HideTip")
  if self.Config and self.Config.bAlwaysShow then
    self:Hide()
  end
end
function IngameLikeUIBP:ShowIntimacyTip()
  print(bWriteLog and "[IngameLikeUIBP] ShowIntimacyTip")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local UID = IngameLikeUtilClient.GetTeammateUIDByPlayerKey(self.Message.PlayerKey)
  local isFriend = LogicFriend.IsMyFriend(UID)
  local bFirstLike = true
  if self.LikedPlayerKey and self.LikedPlayerKey[self.Message.PlayerKey] then
    bFirstLike = false
  end
  if isFriend and self.Config.bSendBack and not self.bShowShakeHand and bFirstLike then
    local Msg = LocUtil.GetLocalizeResStr(19236)
    local Config = CDataTable.GetTableData("IngameLikeConfigTable", 7)
    if Config then
      Msg = string.gsub(Msg, "{1}", Config.Value)
    else
      Msg = string.gsub(Msg, "{1}", "2")
    end
    IngameTipsTools.BattleNormalTips(Msg)
    if not self.LikedPlayerKey then
      self.LikedPlayerKey = {}
    end
    self.LikedPlayerKey[self.Message.PlayerKey] = true
  end
end
function IngameLikeUIBP:OnClose()
  IngameLikeUIBP.__super.OnClose(self)
end
local Class = require("class")
local DynamicMountUIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return Class(DynamicMountUIBase, nil, IngameLikeUIBP)