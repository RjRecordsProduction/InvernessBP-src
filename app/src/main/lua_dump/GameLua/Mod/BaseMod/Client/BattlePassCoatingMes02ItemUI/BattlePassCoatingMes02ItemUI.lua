local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local BattlePassCoatingMes02ItemUI = {}
local UGameplayStatics = import("GameplayStatics")
local EWingMan = {Card1 = 1, Card2 = 2}
local _nDistance = 10
local _GetIsChangePos = function(tPos1, tPos2)
  local nCurDis = math.sqrt((tPos1.X - tPos2.X) ^ 2 + (tPos1.Y - tPos2.Y) ^ 2)
  return nCurDis > _nDistance
end
function BattlePassCoatingMes02ItemUI:ctor(selfType, ShowBecauseRevive)
  self.LuaTimeHandler1 = nil
  self.LuaTimeHandler2 = nil
  self.LuaTimeHandler3 = nil
  self.LuaTimeHandler4 = nil
  self.LuaTimeHandler5 = nil
  self.LuaTimeHandler6 = nil
  self.DefaultGetAndShowDelayTime = 5
  self.FourInOneGetAndShowDelayTime = 1.5
  self.DefaultGetShowDelayTime = 2
  self.FourInOneGetShowDelayTime = 1.5
  self.TotleDefaultShowTime = 26
  self.BeginShowUIDelayTime = 0
  self.  self._tLastCardShowPos = {}
end
function BattlePassCoatingMes02ItemUI:OnInitialize()
  BattlePassCoatingMes02ItemUI.__super.OnInitialize(self)
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:OnInitialize")
  self.CanvasPanel_NumOfPeopleInAircraft = self.UIRoot.CanvasPanel_NumOfPeopleInAircraft
  self.TextBlock_NumOfPeopleInAircraft = self.UIRoot.TextBlock_NumOfPeopleInAircraft
  self.BattlePassItemList = self.UIRoot.battlePassItemList
  self.UpassShowInfoList = self.UIRoot.upassShowInfoList
  self.ImagePanel = self.UIRoot.imagePanel
  self.BattlePass_MainItem = self.UIRoot.BattlePass_MainItem
  self.PlayerListPanel = self.UIRoot.playerListPanel
  self.Image_plane = self.UIRoot.Image_plane
  self.BattlePass_CoatingMes01_Item_3 = self.UIRoot.BattlePass_CoatingMes01_Item_3
  self.BattlePass_CoatingMes01_Item_2 = self.UIRoot.BattlePass_CoatingMes01_Item_2
  self.BattlePass_CoatingMes01_Item_1 = self.UIRoot.BattlePass_CoatingMes01_Item_1
  self.BattlePass_CoatingMes01_Item_0 = self.UIRoot.BattlePass_CoatingMes01_Item_0
  self.BattlePass_CoatingMes01_Item = self.UIRoot.BattlePass_CoatingMes01_Item
  self.CanvasPanel_wingman1 = self.UIRoot.CanvasPanel_wingman1
  self.CanvasPanel_wingman2 = self.UIRoot.CanvasPanel_wingman2
  self.BattlePass_Coating_Wingman_Item_0 = self.UIRoot.BattlePass_Coating_Wingman_Item_0
  self.BattlePass_Coating_Wingman_Item_1 = self.UIRoot.BattlePass_Coating_Wingman_Item_1
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_BattlePassRoot, self, "BattlePassCoatingMes02ItemUI_CanvasPanel_BattlePassRoot")
end
function BattlePassCoatingMes02ItemUI:RegistEvents()
  BattlePassCoatingMes02ItemUI.__super.RegistEvents(self)
  self:AddUIMessageEvent("UIMsg_RefreshFlyNum", self.RefreshFlyNum, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RP_FIRST_PLAYER_XSUIT_ICON_RSP, self.OnXSuitIconRsp, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RP_FIRST_PLAYER_COLLECT_SCORE_RSP, self.OnCollectScoreRsp, self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_BattlePassRoot)
end
function BattlePassCoatingMes02ItemUI:OnClose()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_BattlePassRoot)
  Client.ResetSlateTickEveryFrame(SlateUI_ID.BATTLE_PASS_COATINGMES02_ITEM)
  self.CanvasPanel_NumOfPeopleInAircraft = nil
  self.TextBlock_NumOfPeopleInAircraft = nil
  self.BattlePassItemList = nil
  self.UpassShowInfoList = nil
  self.ImagePanel = nil
  self.BattlePass_MainItem = nil
  self.PlayerListPanel = nil
  self.Image_plane = nil
  self.BattlePass_CoatingMes01_Item_3 = nil
  self.BattlePass_CoatingMes01_Item_2 = nil
  self.BattlePass_CoatingMes01_Item_1 = nil
  self.BattlePass_CoatingMes01_Item_0 = nil
  self.BattlePass_CoatingMes01_Item = nil
  self.CanvasPanel_wingman1 = nil
  self.CanvasPanel_wingman2 = nil
  self.BattlePass_Coating_Wingman_Item_0 = nil
  self.BattlePass_Coating_Wingman_Item_1 = nil
  if self.EnterBroadcastUI then
    self.EnterBroadcastUI:Close()
    self.EnterBroadcastUI = nil
  end
  BattlePassCoatingMes02ItemUI.__super.OnClose(self)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_BattlePassRoot)
end
function BattlePassCoatingMes02ItemUI:PostShowUIEnd(statUIInfo, showVisibility)
  BattlePassCoatingMes02ItemUI.__super.PostShowUIEnd(self, statUIInfo, showVisibility)
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:PostShowUIEnd, showVisibility = " .. tostring(showVisibility) .. ", ShowBecauseRevive = " .. tostring(self.ShowBecauseRevive))
  if self:ShouldShowUI() then
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self:ShouldShowUI() then
    if self:CheckIfExitPlane() then
      self:Hide()
    else
      self:RegisterSomeEvents()
    end
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and slua.isValid(MainControlBaseUI.CanvasPanel_42) then
    MainControlBaseUI.CanvasPanel_42:AddChildToCanvas(self.UIRoot)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
    self:SetZOrder(-9)
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModeType2 = GameMainConfig.GetModType()
  if ModType == "PlanAG" then
    if slua.isValid(self.PlayerListPanel) then
      self.PlayerListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if slua.isValid(self.ImagePanel) then
      self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if slua.isValid(self.BattlePass_MainItem) then
      self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if slua.isValid(self.CanvasPanel_wingman1) then
      self.CanvasPanel_wingman1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if slua.isValid(self.CanvasPanel_wingman2) then
      self.CanvasPanel_wingman2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if self.ShowBecauseRevive then
    self:SetVisibilityForRevive()
  end
end
function BattlePassCoatingMes02ItemUI:RegisterSomeEvents()
  if self.HaveRegistered == true then
    return
  end
  self.HaveRegistered = true
  print(bWriteLog and "BattlePassCoatingMes02ItemUI:RegisterSomeEvents")
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if not slua.isValid(UPlayerController) then
    return
  end
  if not UPlayerController.bIsForReplay and not UPlayerController:IsObserver() then
    self:AddControlEventByControl(UPlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChanged, self)
    self:AddControlEventByControl(UPlayerController, "OnPlayerNumOnPlaneChangedDelegate", self.RefreshFlyNum, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANESHOW_CHANGE_STATIC, self.ChangeStaticShowFlyingInfo, self)
  elseif not UPlayerController.bIsForReplay then
    local uPlayerState = UPlayerController.PlayerState
    if uPlayerState and slua.isValid(uPlayerState) and (uPlayerState.GetRevivalCount and 0 < uPlayerState:GetRevivalCount() or uPlayerState.GetLeftBuyLifeCounts and 0 < uPlayerState:GetLeftBuyLifeCounts()) then
      self:AddControlEventByControl(UPlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChanged, self)
    end
  end
  self:AddControlEventByControl(UPlayerController, "OnPlayerCanjump", self.OnPlayerCanJump, self)
  if UPlayerController:IsInPlane() then
    self:ShowFlyingInfo(true)
  end
end
function BattlePassCoatingMes02ItemUI:SetShowBecauseRevive()
  print(bWriteLog and "BattlePassCoatingMes02ItemUI:SetShowBecauseRevive")
  self.ShowBecauseRevive = true
  self.isShow = true
  self:RegisterSomeEvents()
end
function BattlePassCoatingMes02ItemUI:SetVisibilityForRevive()
  print(bWriteLog and "BattlePassCoatingMes02ItemUI:SetVisibilityForRevive")
  self.BHidePassUI = true
  self.PlayerListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.CanvasPanel_NumOfPeopleInAircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BattlePassCoatingMes02ItemUI:ShouldShowUI()
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShouldShowUI ")
  if slua.isValid(UPlayerController) and not UPlayerController.bIsForReplay and not UPlayerController:IsObserver() and not UPlayerController:IsDemoPlayGlobalObserver() then
    log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShouldShowUI true ")
    return true
  end
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShouldShowUI UPlayerController.bIsForReplay" .. tostring(UPlayerController.bIsForReplay))
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShouldShowUI UPlayerController.IsObserver" .. tostring(UPlayerController:IsObserver()))
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShouldShowUI UPlayerController.IsDemoPlayGlobalObserver" .. tostring(UPlayerController:IsDemoPlayGlobalObserver()))
  return false
end
function BattlePassCoatingMes02ItemUI:GetInputControlPanel()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  return InGameUITools.GetMainControlPanelTochButton()
end
function BattlePassCoatingMes02ItemUI:CheckIfExitPlane()
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:CheckIfExitPlane ")
  local UIUtil = require("client.common.ui_util")
  local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if slua.isValid(GameState) then
    log(bWriteLog and "BattlePassCoatingMes02ItemUI:CheckIfExitPlane isValid GameState ")
    local GameModeState = GameState:GetGameModeState()
    if GameModeState == "ActiveState" or GameModeState == "ReadyState" then
      log(bWriteLog and "BattlePassCoatingMes02ItemUI:CheckIfExitPlane ActiveState or GameModeState == ReadyState ")
      return false
    elseif GameModeState == "FightingState" then
      local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
      local StateType = UPlayerController:GetCurrentStateType()
      local EStateType = import("EStateType")
      if StateType == EStateType.State_None or StateType == EStateType.State_Initial or StateType == EStateType.State_InPlane then
        return false
      else
        log(bWriteLog and "BattlePassCoatingMes02ItemUI:CheckIfExitPlane StateType true ")
        return true
      end
    else
      return true
    end
  end
end
function BattlePassCoatingMes02ItemUI:ShowFlyingInfo(IsShow)
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShowFlyingInfo IsShow")
  if IsShow then
    local UIUtil = require("client.common.ui_util")
    local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
    if slua.isValid(GameState) then
      local EGameModeType = import("EGameModeType")
      if GameState.GameModeType ~= EGameModeType.EWarGameMode then
        local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
        local ModType, ModeType2 = GameMainConfig.GetModType()
        if ModType == "PlanA" and GameState.bShouldPlayBornIslandSeq then
          self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
          self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
          self.BHidePassUI = true
        end
        self:RefreshFlyNum()
        if not slua.isValid(self.CanvasPanel_NumOfPeopleInAircraft) then
          return
        end
        self.CanvasPanel_NumOfPeopleInAircraft:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self:LuaShowUI()
      else
        log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShowFlyingInfo EWarGameMode")
        self:Hide()
      end
    end
  else
    log(bWriteLog and "BattlePassCoatingMes02ItemUI:ShowFlyingInfo GameMode not Valid")
    self:CloseSelf()
  end
end
function BattlePassCoatingMes02ItemUI:RefreshFlyNum()
  log(bWriteLog and "BattlePassCoatingMes02ItemUI: RefreshFlyNum")
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if slua.isValid(UPlayerController) then
    local PanelCharacter = UPlayerController:GetThePlane()
    if slua.isValid(PanelCharacter) then
      self.TextBlock_NumOfPeopleInAircraft:SetText(LocUtil.LocalizeResFormat(6411, PanelCharacter.PlayerNum))
    end
  end
end
function BattlePassCoatingMes02ItemUI:LuaShowUI()
  log(bWriteLog and "BattlePassCoatingMes02ItemUI: LuaShowUI")
  Client.RequireSlateTickEveryFrame(SlateUI_ID.BATTLE_PASS_COATINGMES02_ITEM)
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if (UPlayerController == nil or not UPlayerController:IsDemoPlaySpectator()) and not self.isShow then
    log(bWriteLog and "BattlePassCoatingMes02ItemUI:LuaShowUI SelfHitTestInvisible")
    self:SelfHitTestInvisible()
    self.isShow = true
    self.BattlePassItemList:Clear()
    self.BattlePassItemList:Add(self.BattlePass_CoatingMes01_Item_3)
    self.BattlePassItemList:Add(self.BattlePass_CoatingMes01_Item_2)
    self.BattlePassItemList:Add(self.BattlePass_CoatingMes01_Item_1)
    self.BattlePassItemList:Add(self.BattlePass_CoatingMes01_Item_0)
    self.BattlePassItemList:Add(self.BattlePass_CoatingMes01_Item)
    self.UpassShowInfoList:Clear()
    self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    local count = self.BattlePassItemList:Num()
    for i = 0, count - 1 do
      self.BattlePassItemList:Get(i):SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
    self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.PlayerListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ShowDataNum = 0
    self.DataListNum = 0
    self.CurShowDataNum = 0
    self.ShowAvatarId = 0
    self:ClearTimerHandler()
    self:ExtraShowMainItemAndAvatar()
    self.LuaTimeHandler1 = self:AddGameTimer(self:GetAndShowDelayTime(), false, function()
      self:LuaGetData()
      self:LuaShowData()
    end)
    self.LuaTimeHandler2 = self:AddGameTimer(200, false, function()
      self:LuaHideUI()
    end)
  end
end
function BattlePassCoatingMes02ItemUI:GetAndShowDelayTime()
  local UIUtil = require("client.common.ui_util")
  local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if slua.isValid(GameState) then
    local EGameModeType = import("EGameModeType")
    if GameState.GameModeType == EGameModeType.EFourInOneGameMode then
      return self.FourInOneGetAndShowDelayTime
    else
      return self.DefaultGetAndShowDelayTime
    end
  else
    return self.DefaultGetAndShowDelayTime
  end
end
function BattlePassCoatingMes02ItemUI:LuaGetData()
  local UIUtil = require("client.common.ui_util")
  local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if slua.isValid(GameState) then
    self.DataListNum = GameState.UpassInfoList:Num()
    if self.DataListNum > self.BattlePassItemList:Num() then
      self.ShowDataNum = self.BattlePassItemList:Num()
    else
      self.ShowDataNum = self.DataListNum
    end
    if self.ShowDataNum <= 0 then
      return
    end
    for i = self.ShowDataNum - 1, 0, -1 do
      self.UpassShowInfoList:Add(GameState.UpassInfoList:Get(i))
    end
    for i = 0, self.ShowDataNum - 1 do
      self.BattlePassItemList:Get(i):SetData(self.UpassShowInfoList:Get(i))
      if i == self.ShowDataNum - 1 then
        self:_SetBattlePass_MainItemAvatar(self.UpassShowInfoList:Get(i))
      end
    end
  end
end
function BattlePassCoatingMes02ItemUI:LuaShowData()
  if self.ShowDataNum > 0 then
    self.CurShowDataNum = 1
    self:LuaShowDataflowOne()
  else
    log(bWriteLog and "BattlePassCoatingMes02ItemUI:LuaShowData LuaHideUI")
    self:LuaHideUI()
  end
end
function BattlePassCoatingMes02ItemUI:LuaShowDataflowOne()
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:LuaShowDataflowOne")
  if self.CurShowDataNum > 0 and self.CurShowDataNum <= self.ShowDataNum then
    local BattlePassItem = self.BattlePassItemList:Get(self.CurShowDataNum - 1)
    BattlePassItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    BattlePassItem:PlayUserWidgetAnimation(BattlePassItem.DX_Entrance, 0, 1, 0, 1)
    self.ShowAvatarId = self.UpassShowInfoList:Get(self.CurShowDataNum - 1).planeAvatarId
    self.BNeedShowPlaneTex = self:CheckNeedShow()
    self:SetSelectBg(self.CurShowDataNum)
    local ShowDelayTime = self:GetShowDelayTime()
    if self.CurShowDataNum == self.ShowDataNum then
      self:SetArrow(0)
      self:ChangePlaneColor(self.ShowAvatarId)
      if not self.BHidePassUI then
        self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.BattlePass_MainItem:Show()
      end
      local ShowTime = self.TotleDefaultShowTime - self.ShowDataNum * ShowDelayTime
      if self.TotleTimeStart and CGameState then
        local curTime = CGameState:GetServerWorldTimeSeconds()
        ShowTime = ShowTime - curTime + self.TotleTimeStart
      end
      if ShowTime < 5 then
        ShowTime = 5
      end
      self.LuaTimeHandler5 = self:AddGameTimer(ShowTime, false, function()
        self:HidePlayerListPanel()
      end)
    else
      self:SetPlaneTex()
      self:SetArrow(self.CurShowDataNum)
      if not self.BHidePassUI and self.BNeedShowPlaneTex then
        self.LuaTimeHandler6 = self:AddGameTimer(0.2, false, function()
          self:ShowPlanePanel()
        end)
      end
    end
    self.CurShowDataNum = self.CurShowDataNum + 1
    local ShowDelayTime = self:GetShowDelayTime()
    self.LuaTimeHandler3 = self:AddGameTimer(ShowDelayTime, false, function()
      self:LuaShowDataflowOne()
    end)
    self.LuaTimeHandler4 = self:AddGameTimer(ShowDelayTime - 0.3, false, function()
      self:HidePlanePanel()
    end)
  elseif 0 < self.BattlePassItemList:Num() and 0 < self.UpassShowInfoList:Num() then
    local PlayerShowUPassInfo = self.UpassShowInfoList:Get(self.UpassShowInfoList:Num() - 1)
    if 0 < PlayerShowUPassInfo.nUpassPrimePlusCard and self.BattlePassItemList:Num() >= self.UpassShowInfoList:Num() then
      self.BattlePassItemList:Get(self.UpassShowInfoList:Num() - 1):SetSelectShow(false)
    end
  end
end
function BattlePassCoatingMes02ItemUI:HidePlanePanel()
  self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function BattlePassCoatingMes02ItemUI:ShowPlanePanel()
  self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function BattlePassCoatingMes02ItemUI:SetPlaneTex()
  local RecordData = CDataTable.GetTableData("Item", self.ShowAvatarId)
  if not (self.ShowAvatarId ~= 1801101 and RecordData) or RecordData.ItemID == 0 or RecordData.ItemBigIcon == nil or RecordData.ItemBigIcon == "" then
    self.Image_plane:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    local UIUtil = require("client.common.ui_util")
    local ItemBigIcon = UIUtil.GetItemBigIconNotPakCheck(tostring(RecordData.ItemID))
    local USTExtraUIBPUtils = import("STExtraUIUtils")
    USTExtraUIBPUtils.SetImageTextureAsyncWithCallback(ItemBigIcon, self.Image_plane, slua.createDelegate(function(LoadedObject)
      if slua.isValid(self.Image_plane) then
        if slua.isValid(LoadedObject) then
          self.Image_plane:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
          self.Image_plane:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      end
    end))
  end
end
function BattlePassCoatingMes02ItemUI:GetShowDelayTime()
  local UIUtil = require("client.common.ui_util")
  local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if slua.isValid(GameState) then
    local EGameModeType = import("EGameModeType")
    if GameState.GameModeType == EGameModeType.EFourInOneGameMode then
      return self.FourInOneGetShowDelayTime
    else
      return self.DefaultGetShowDelayTime
    end
  else
    return self.DefaultGetShowDelayTime
  end
end
function BattlePassCoatingMes02ItemUI:HidePlayerListPanel()
  self.PlayerListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function BattlePassCoatingMes02ItemUI:ChangePlaneColor(ItemId)
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if slua.isValid(PlayerController) then
    local Plane = PlayerController:GetThePlane()
    if slua.isValid(Plane) then
      local PlaneAvatarComponentClass = import("PlaneAvatarComponent")
      local PlaneAvatarComponent = Plane:GetComponentByClass(PlaneAvatarComponentClass)
      PlaneAvatarComponent:PreChangePlaneAvatar(ItemId)
    end
  end
end
function BattlePassCoatingMes02ItemUI:SetArrow(Num)
  local Length = self.BattlePassItemList:Num()
  if 0 < Num and Num <= Length then
    for i = 0, Length - 1 do
      if Num - 1 == i and not self.BHidePassUI and self.BNeedShowPlaneTex then
        self.BattlePassItemList:Get(i):SetArrowShow(true)
      else
        self.BattlePassItemList:Get(i):SetArrowShow(false)
      end
    end
  else
    for i = 0, Length - 1 do
      self.BattlePassItemList:Get(i):SetArrowShow(false)
    end
  end
end
function BattlePassCoatingMes02ItemUI:CheckNeedShow()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local State = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    self.ShowAvatarId
  })
  if State == PufferConst.ENUM_DownloadState.Done and self.ShowAvatarId ~= 1801101 then
    return true
  end
  return false
end
function BattlePassCoatingMes02ItemUI:SetSelectBg(Num)
  local Length = self.BattlePassItemList:Num()
  if 0 < Num and Num <= Length then
    for i = 0, Length - 1 do
      if Num - 1 == i then
        self.BattlePassItemList:Get(i):SetSelectShow(true)
      else
        self.BattlePassItemList:Get(i):SetSelectShow(false)
      end
    end
  else
    for i = 0, Length - 1 do
      self.BattlePassItemList:Get(i):SetSelectShow(false)
    end
  end
end
function BattlePassCoatingMes02ItemUI:LuaHideUI()
  log(bWriteLog and "BattlePassCoatingMes02ItemUI:LuaHideUI")
  self:ClearTimerHandler()
  self.PlayerListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ImagePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BattlePassCoatingMes02ItemUI:ClearTimerHandler()
  if self.LuaTimeHandler1 ~= nil then
    self:RemoveGameTimer(self.LuaTimeHandler1)
  end
  if self.LuaTimeHandler2 ~= nil then
    self:RemoveGameTimer(self.LuaTimeHandler2)
  end
  if self.LuaTimeHandler3 ~= nil then
    self:RemoveGameTimer(self.LuaTimeHandler3)
  end
  if self.LuaTimeHandler4 ~= nil then
    self:RemoveGameTimer(self.LuaTimeHandler4)
  end
  if self.LuaTimeHandler5 ~= nil then
    self:RemoveGameTimer(self.LuaTimeHandler5)
  end
  if self.LuaTimeHandler6 ~= nil then
    self:RemoveGameTimer(self.LuaTimeHandler6)
  end
  self.LuaTimeHandler1 = nil
  self.LuaTimeHandler2 = nil
  self.LuaTimeHandler3 = nil
  self.LuaTimeHandler4 = nil
  self.LuaTimeHandler5 = nil
  self.LuaTimeHandler6 = nil
end
function BattlePassCoatingMes02ItemUI:OnPlayerControllerStateChanged(CurStateType)
  log(bWriteLog and "OnPlayerControllerStateChanged CurStateType" .. tostring(CurStateType))
  local EStateType = import("EStateType")
  if CurStateType == EStateType.State_InPlane then
    if CGameState then
      self.TotleTimeStart = CGameState:GetServerWorldTimeSeconds()
    end
    self.ShowFlyingInfoTimer = self:AddGameTimer(self:GetBeginShowUIDelayTime(), false, function()
      self:ShowFlyingInfo(true)
    end)
  elseif CurStateType == EStateType.State_None or CurStateType == EStateType.State_Initial or CurStateType == EStateType.State_Fight then
    print(bWriteLog and "BattlePassCoatingMes02ItemUI OnPlayerControllerStateChanged ")
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self:ShowFlyingInfo(false)
  end
end
function BattlePassCoatingMes02ItemUI:ChangeStaticShowFlyingInfo()
  print(bWriteLog and "BattlePassCoatingMes02ItemUI:ChangeStaticShowFlyingInfo:" .. tostring(self.ShowFlyingInfoTimer == nil))
  if self.ShowFlyingInfoTimer then
    self:RemoveGameTimer(self.ShowFlyingInfoTimer)
    self:ShowFlyingInfo(true)
    self.ShowFlyingInfoTimer = nil
  end
end
function BattlePassCoatingMes02ItemUI:SetWingManPlaneVisible(visible)
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if slua.isValid(UPlayerController) and UPlayerController.bIsForReplay then
    log(bWriteLog and "BattlePassCoatingMes02ItemUI:SetWingManPlaneVisible bIsForReplay Collapsed")
    if self.CanvasPanel_wingman1 then
      self.CanvasPanel_wingman1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.CanvasPanel_wingman2 then
      self.CanvasPanel_wingman2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    return
  end
  if not slua.isValid(self.CanvasPanel_wingman1) or not slua.isValid(self.CanvasPanel_wingman2) then
    return
  end
  if visible then
    self.CanvasPanel_wingman1:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.CanvasPanel_wingman2:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.CanvasPanel_wingman1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.CanvasPanel_wingman2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BattlePassCoatingMes02ItemUI:GetWingManPlaneVisible()
  if not slua.isValid(self.CanvasPanel_wingman1) or not slua.isValid(self.CanvasPanel_wingman2) then
    return false
  end
  local bVisibility = self.UIRoot:GetVisibility()
  local ESlateVisibility = UEnums.ESlateVisibility
  local bShowing = bVisibility == ESlateVisibility.Visible or bVisibility == ESlateVisibility.HitTestInvisible or bVisibility == ESlateVisibility.SelfHitTestInvisible
  return bShowing and self.CanvasPanel_wingman1:GetVisibility() == UEnums.ESlateVisibility.HitTestInvisible
end
function BattlePassCoatingMes02ItemUI:SetWinManPanelPos(number, Position)
  if not (Position and number and Position.X) or not Position.Y then
    return
  end
  local bIsChangePos = true
  if self._tLastCardShowPos[number] then
    bIsChangePos = _GetIsChangePos(self._tLastCardShowPos[number], Position)
  end
  if not bIsChangePos then
    return
  end
  if number == EWingMan.Card1 then
    if slua.isValid(self.CanvasPanel_wingman1) then
      self.CanvasPanel_wingman1.Slot:SetPosition(FVector2D(Position.X - 70, Position.Y))
    end
  elseif number == EWingMan.Card2 and slua.isValid(self.CanvasPanel_wingman2) then
    self.CanvasPanel_wingman2.Slot:SetPosition(FVector2D(Position.X - 70, Position.Y))
  end
  self._tLastCardShowPos[number] = Position
end
function BattlePassCoatingMes02ItemUI:SetWingManInfo(number, Info, XSuitIconId)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsHawkEyeSpectator and uPlayerController:IsHawkEyeSpectator() then
    Info.PlayerName = "***"
  end
  if number == EWingMan.Card1 then
    if slua.isValid(self.BattlePass_Coating_Wingman_Item_0) then
      self.BattlePass_Coating_Wingman_Item_0:SetData(Info)
      self:_SetWidgetXSuitIcon(self.BattlePass_Coating_Wingman_Item_0, XSuitIconId)
      if slua.isValid(uPlayerController) and uPlayerController.IsHawkEyeSpectator and uPlayerController:IsHawkEyeSpectator() then
        self.BattlePass_Coating_Wingman_Item_0.Image_nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  elseif number == EWingMan.Card2 and slua.isValid(self.BattlePass_Coating_Wingman_Item_1) then
    self.BattlePass_Coating_Wingman_Item_1:SetData(Info)
    self:_SetWidgetXSuitIcon(self.BattlePass_Coating_Wingman_Item_1, XSuitIconId)
    if slua.isValid(uPlayerController) and uPlayerController.IsHawkEyeSpectator and uPlayerController:IsHawkEyeSpectator() then
      self.BattlePass_Coating_Wingman_Item_1.Image_nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function BattlePassCoatingMes02ItemUI:_SetWidgetXSuitIcon(widget, XSuitIconId)
  local imageWidget = widget.Image_xsuit
  local CanvasPanel_xsuit = widget.CanvasPanel_xsuit
  print(bWriteLog and string.format("BattlePassCoatingMes02ItemUI:_SetWidgetXSuitIcon XSuitIconId:%s", XSuitIconId))
  local show = false
  if XSuitIconId and XSuitIconId ~= 0 then
    local XSuitIconCfgData = CDataTable.GetTableData("XSuitIconCfg", XSuitIconId)
    if XSuitIconCfgData then
      local XSuitIconPath = XSuitIconCfgData.Path
      if XSuitIconPath and XSuitIconPath ~= "" then
        show = true
        self:SetTexture(imageWidget, XSuitIconPath)
        CanvasPanel_xsuit:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      end
    end
  end
  if not show then
    CanvasPanel_xsuit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BattlePassCoatingMes02ItemUI:_SetWidgetCollectLevel(widget, bSuccess, sPlayerUID, collectScore, seasonCollectScore, privacy)
  local Common_Collect_Level_UIBP = widget.Common_Collect_Level_DynamicLoading_UIBP
  if Common_Collect_Level_UIBP then
    if not bSuccess or not collectScore then
      print(bWriteLog and "BattlePassCoatingMes02ItemUI:_SetWidgetCollectLevel not success")
      Common_Collect_Level_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    Common_Collect_Level_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
    local collect_data = {
      total_score = collectScore,
      cur_season_collect_score = seasonCollectScore,
      privacy = {
        [collect_cfg.privacy.DoubleShowCollectLevel] = privacy
      }
    }
    Common_Collect_Level_UIBP:InitCollectBadge(sPlayerUID, collect_data)
  end
end
function BattlePassCoatingMes02ItemUI:OnPlayerCanJump()
  self:SetWingManPlaneVisible(false)
end
function BattlePassCoatingMes02ItemUI:GetBeginShowUIDelayTime()
  local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
  if ConfigDrivePlaneShowSubsystem and ConfigDrivePlaneShowSubsystem.GetBattlePassDelayTime then
    return ConfigDrivePlaneShowSubsystem:GetBattlePassDelayTime()
  end
  return self.BeginShowUIDelayTime
end
function BattlePassCoatingMes02ItemUI:ExtraShowMainItemAndAvatar()
  if self.ShowBecauseRevive then
    print(bWriteLog and "BattlePassCoatingMes02ItemUI:ExtraShowMainItemAndAvatar, return because of ShowBecauseRevive")
    return
  end
  if slua.isValid(CGameState) and CGameState.UpassInfoList and CGameState.UpassInfoList:Num() >= 1 then
    local UpassInfoData = CGameState.UpassInfoList:Get(0)
    self.BattlePass_MainItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:_SetBattlePass_MainItemAvatar(UpassInfoData)
    self.ShowAvatarId = UpassInfoData.planeAvatarId
    self:ChangePlaneColor(self.ShowAvatarId)
    print(bWriteLog and "BattlePassCoatingMes02ItemUI:ExtraShowMainItemAndAvatar self.ShowAvatarId:", self.ShowAvatarId)
  else
    print(bWriteLog and "BattlePassCoatingMes02ItemUI:ExtraShowMainItemAndAvatar UpassInfoList Invalid")
  end
end
function BattlePassCoatingMes02ItemUI:_SetBattlePass_MainItemAvatar(UpassInfoData)
  print(bWriteLog and "BattlePassCoatingMes02ItemUI:_SetBattlePass_MainItemAvatar PlayerUID:", UpassInfoData.PlayerUID)
  self.BattlePass_MainItem:SetData(UpassInfoData)
  local PlayerUid = UpassInfoData.PlayerUID
  local PC = UGameplayStatics.GetPlayerController(CGameState, 0)
  if Game:IsValid(PC) and PC.CommerFeature then
    PC.CommerFeature:RPCServer_XSuitIconReq(PlayerUid)
    PC.CommerFeature:RPCServer_CollectScoreReq(PlayerUid)
  end
end
function BattlePassCoatingMes02ItemUI:OnXSuitIconRsp(_, _, bSuccess, XSuitIconId)
  print(bWriteLog and string.format("BattlePassCoatingMes02ItemUI:OnXSuitIconRsp bSuccess:%s,XSuitIconId:%s", bSuccess, XSuitIconId))
  self:_SetWidgetXSuitIcon(self.BattlePass_MainItem, XSuitIconId)
end
function BattlePassCoatingMes02ItemUI:OnCollectScoreRsp(_, _, bSuccess, sPlayerUID, collectScore, seasonCollectScore, privacy)
  print(bWriteLog and string.format("BattlePassCoatingMes02ItemUI:OnCollectScoreRsp bSuccess:%s, collectScore:%s, seasonCollectScore%s", bSuccess, collectScore, seasonCollectScore))
  self:_SetWidgetCollectLevel(self.BattlePass_MainItem, bSuccess, sPlayerUID, collectScore, seasonCollectScore, privacy)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CBattlePassCoatingMes02ItemUI = class(ui_base, nil, BattlePassCoatingMes02ItemUI)
return CBattlePassCoatingMes02ItemUI