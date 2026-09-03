local IngameTeamPanel = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local uEGameModeSubType = import("EGameModeSubType")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function IngameTeamPanel:ctor()
  self.StatusConfigList = {}
  self.PositionStatusConfigList = {}
  self.TeammateMarks = {}
end
function IngameTeamPanel:OnInitialize()
  IngameTeamPanel.__super.OnInitialize(self)
  self:InitConfig()
  self:InitData()
  self:InitUI()
end
function IngameTeamPanel:OnPostInitialize()
  IngameTeamPanel.__super.OnPostInitialize(self)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MaincontrolBaseUI = InGameUITools.GetMainControlBaseUI()
  if MaincontrolBaseUI and MaincontrolBaseUI.CanvasPanel_0 then
    MaincontrolBaseUI.CanvasPanel_0:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  end
end
function IngameTeamPanel:OnClose()
  self.uLocalOwnerPlayerstate = nil
  self.uMainTeammatePos = nil
  self.uCurTeammateItem = nil
  self.PositionItemBP = nil
  self.nLastTeamID = -1
  self:ClearTeamItem()
  self:ClearFollowItem()
  self:ClearPosItem()
  self:ClearOnPlanePosItem()
  self.OtherPositionItemList = {}
  self.CustomStatusMapRight = {}
  self.CustomStatusMapLeft = {}
  self.CustomHPBuffIcon = {}
  self.UIRoot:RemoveFromParent()
  print(bWriteLog and "TeamPanel_Debug_Msg: !!! TeamPanel Close !!!")
end
function IngameTeamPanel:InitConfig()
  self.TeamPanelUIConfig = GamePlayTools.GetCurrentConfig("TeamPanelUIConfig")
  if self.TeamPanelUIConfig then
    self.bDisableTeamMatePanel = self.TeamPanelUIConfig.bDisableTeamMatePanel or false
    self.bDisableFollowPanel = self.TeamPanelUIConfig.bDisableFollowPanel or false
    self.bDisablePositionItems = self.TeamPanelUIConfig.bDisablePositionItems or false
    self.bDisableTeamPanel = self.TeamPanelUIConfig.bDisableTeamPanel or false
    self.bShowOtherAlias = self.TeamPanelUIConfig.bShowOtherAlias or false
  end
end
function IngameTeamPanel:InitUI()
  self:IsInfectMode()
  self:InitTeamPanel()
  self:InitSpecialUI()
end
function IngameTeamPanel:InitData()
  self.uLocalOwnerPlayerstate = nil
  self.uMainTeammatePos = nil
  self.uCurTeammateItem = nil
  self.PositionItemBP = nil
  self.TeamItemList = {}
  self.FollowItemList = {}
  self.TeammatePosItemList = {}
  self.OtherPositionItemList = {}
  self.OnPlanePosItemList = {}
  self.CustomStatusMapRight = {}
  self.CustomStatusMapLeft = {}
  self.CustomHPBuffIcon = {}
  self.CreatePosItemLoading = {}
  self.UpdateLiveStateCheck = {}
  self.bCalledInfectMode = false
  self.bInfectMode = false
  self.bIsVeteranRecruit = false
  self.bIsShow = false
  self.bIsPosItemLoading = false
  self.nTeamMateCount = 0
  self.nViewTargetTeamMemberIdx = -1
  self.nLocalOwnerTeamMemberIdx = 0
  self.IsShowAircraftPanel = false
  self.AircraftFollowItemList = {}
end
function IngameTeamPanel:InitTeamPanel()
  print(bWriteLog and "TeamPanel_Debug_Msg: !!! Init TeamPanel !!!")
  self:Update_HorizontalBox_PlaneTeammate_Visibility()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController.PlayerState
    if slua.isValid(uPlayerState) and uPlayerState.GetTeamMatePlayerStateList then
      local TeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
      local TeamMateCount = self:GetValidTeammateStateNum()
      print(bWriteLog and "TeamPanel_Debug_Msg: TeamMateCount = " .. TeamMateCount .. " TeamMatePlayerStateList NUM = " .. TeamMatePlayerStateList:Num())
      local uGameState = GameplayData.GetGameState()
      if slua.isValid(uGameState) then
        local eGameModeSubType = uGameState.GameModeSubType
        if (eGameModeSubType == uEGameModeSubType.EPlanDGameMode or eGameModeSubType == uEGameModeSubType.EPlanETGameMode) and TeamMateCount < self.nTeamMateCount then
          return
        end
      end
      self.n      self.uLocalOwnerPlayerstate = uPlayerState
      local bNeedCreatItems = self:CheckNeedCreateItems()
      if bNeedCreatItems then
        if not self.bDisableTeamMatePanel then
          self:InitTeamItems(TeamMatePlayerStateList)
        end
        if not self.bDisableFollowPanel then
          self:ClearFollowItem()
          self:InitFollowItems(TeamMatePlayerStateList)
          self:InitAircraftItems(TeamMatePlayerStateList)
          self:RefreshAircraftControl()
        else
          self:OnPlayerEnterParachute_Handle()
        end
        if not self.bDisablePositionItems then
          self:InitPositionItems(TeamMatePlayerStateList)
        end
      end
      self:ConnectionInit(uPlayerState)
      self:FollowPanelControl()
      self:UpdateVeteranStatus()
      self:InitTeammateStatusIconUI()
      local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
      if IngameLikeClientSubSystem and IngameLikeClientSubSystem.OnRepPlayerState then
        IngameLikeClientSubSystem:OnRepPlayerState()
      end
    end
  end
end
function IngameTeamPanel:InitTeamItems(TeamMatePlayerStateList)
  print(bWriteLog and "IngameTeamPanel:InitTeamItems")
  local insert = table.insert
  local TeamItemConfig = UIManager.UI_Config_InGame.IngameTeamItem_New
  local GameState = GameplayData.GetGameState()
  if not Game:IsValid(GameState) then
    return
  end
  local GameModeState = GameState:GetGameModeState()
  if TeamItemConfig then
    local nVisibleIndex = self:GetValidTeammateStateNum()
    for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
      print(bWriteLog and string.format("IngameTeamPanel:InitTeamItems nIndex=%d PlayerName=%s ", nIndex, TeamMatePlayerState and TeamMatePlayerState.PlayerName or "nil"))
      local ExistTeamItem = self.TeamItemList[nIndex + 1]
      if slua.isValid(TeamMatePlayerState) then
        local InTeamIndex = self:GetInTeamIndex(TeamMatePlayerState)
        InTeamIndex = InTeamIndex + 1
        print(bWriteLog and "TeamPanel_Debug_Msg: InitTeamItems TeammatePlayerName = " .. TeamMatePlayerState.PlayerName .. " PlayerTeamIndex = " .. InTeamIndex .. " TeamID = " .. TeamMatePlayerState.TeamID)
        if ExistTeamItem then
          ExistTeamItem:Reset(InTeamIndex, TeamMatePlayerState)
          ExistTeamItem:InitTeamItem()
          ExistTeamItem:ShowSelf()
          ExistTeamItem.bUIHoldExitPlayer = true
        else
          local TeamItem = UIManager.ShowUI(TeamItemConfig, InTeamIndex, TeamMatePlayerState)
          if TeamItem then
            self:AttachChildWindow("TeamItemListBox", TeamItem)
            insert(self.TeamItemList, TeamItem)
            TeamItem.bUIHoldExitPlayer = true
          end
        end
      elseif ExistTeamItem then
        if GameModeState == "ReadyState" then
          ExistTeamItem.bUIHoldExitPlayer = true
        else
          ExistTeamItem.bUIHoldExitPlayer = false
        end
      end
    end
    for key, TeamItem in pairs(self.TeamItemList) do
      if TeamItem and key > nVisibleIndex and GameModeState ~= "ReadyState" then
        TeamItem:HideSelf()
        print(bWriteLog and "TeamPanel_Debug_Msg:TeamItem:HideSelf nVisibleIndex = " .. nVisibleIndex .. " key = " .. key)
      end
    end
  end
end
function IngameTeamPanel:InitPositionItems(TeamMatePlayerStateList)
  local insert = table.insert
  local PosItemConfig = UIManager.UI_Config_InGame.IngamePositionItem
  if PosItemConfig then
    local nVisibleIndex = self:GetValidTeammateStateNum()
    for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
      if slua.isValid(TeamMatePlayerState) then
        local InTeamIndex = self:GetInTeamIndex(TeamMatePlayerState)
        InTeamIndex = InTeamIndex + 1
        local ExistPosItem = self.TeammatePosItemList[nIndex + 1]
        print(bWriteLog and "TeamPanel_Debug_Msg: InitPosItems TeammatePlayerName = " .. TeamMatePlayerState.PlayerName .. " PlayerTeamIndex = " .. InTeamIndex)
        local PositionItem
        if ExistPosItem then
          PositionItem = ExistPosItem
          PositionItem:InitData(InTeamIndex, TeamMatePlayerState)
        else
          local PosItem = self:CreateChildWindow("CanvasPanel_TeammatePosition_new", PosItemConfig, InTeamIndex, TeamMatePlayerState)
          if PosItem then
            insert(self.TeammatePosItemList, PosItem)
            PositionItem = PosItem
          end
        end
        if PositionItem then
          if TeamMatePlayerState == self.uLocalOwnerPlayerstate then
            self.nLocalOwnerTeamMemberIdx = nIndex
            PositionItem:HideDistancePanel()
            PositionItem.UIRoot.TextBlock_TeamIndex:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            PositionItem.UIRoot.WidgetSwitcher_TeammateState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            if not self:CanShowSelfPositionItem() then
              PositionItem:SetCurrentWidgetVisible(false)
              PositionItem:SetAlphaBegin(0.6)
              PositionItem:SetAlphaStep(0.01)
            else
              PositionItem:SetCurrentWidgetVisible(true, true)
              PositionItem:SetAlphaBegin(0.8)
              PositionItem:SetAlphaStep(0.02)
            end
          else
            PositionItem:SetCurrentWidgetVisible(true)
            PositionItem:ShowDistancePanel()
            PositionItem.UIRoot.TextBlock_TeamIndex:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            PositionItem.UIRoot.WidgetSwitcher_TeammateState:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            if not self:CanShowSelfPositionItem() then
              PositionItem:SetAlphaBegin(0.6)
              PositionItem:SetAlphaStep(0.01)
            else
              PositionItem:SetAlphaBegin(0.8)
              PositionItem:SetAlphaStep(0.02)
            end
          end
          PositionItem:InitPosItem(InTeamIndex, TeamMatePlayerState)
        end
      end
    end
    for key, PositionItem in ipairs(self.TeammatePosItemList) do
      if PositionItem and key > nVisibleIndex then
        PositionItem:InitPosItem(-1, nil)
        PositionItem:SetCurrentWidgetVisible(false)
        print(bWriteLog and "TeamPanel_Debug_Msg:PositionItem HideSelf nVisibleIndex = " .. nVisibleIndex .. " key = " .. key)
      else
        PositionItem:SetCurrentWidgetVisible(true)
      end
    end
  end
  self:UpdateSelfInPlaneBox()
  self:ClearOnPlanePosItem()
  self:InitOnPlanePosItems(TeamMatePlayerStateList)
  EventSystem:postEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMPOS_ITEM_INITED)
end
function IngameTeamPanel:CanShowSelfPositionItem()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  local GameModeState = uGameState:GetGameModeState()
  local bIsInReadyState = GameModeState == "ReadyState" or GameModeState == "ActiveState"
  if bIsInReadyState then
    return true
  else
    return false
  end
end
function IngameTeamPanel:InitFollowItems(TeamMatePlayerStateList)
  local FollowItemList = {}
  local insert = table.insert
  local FollowItemConfig = UIManager.UI_Config_InGame.IngameFollowItem_New
  if FollowItemConfig then
    for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
      if slua.isValid(TeamMatePlayerState) then
        local InTeamIndex = self:GetInTeamIndex(TeamMatePlayerState)
        InTeamIndex = InTeamIndex + 1
        local FollowItem = UIManager.ShowUI(FollowItemConfig, nIndex, TeamMatePlayerState)
        if FollowItem then
          self:AttachChildWindow("FollowItemListBox", FollowItem)
          insert(FollowItemList, FollowItem)
        end
      end
    end
    self.  end
  local LastItem
  for _, FollowItem in pairs(FollowItemList) do
    if FollowItem and Game:IsValid(FollowItem.UIRoot) then
      FollowItem.UIRoot:SetPadding(FMargin(0, 0, 0, 0))
      LastItem = FollowItem
    end
  end
  if LastItem and Game:IsValid(LastItem.UIRoot) then
    LastItem.UIRoot:SetPadding(FMargin(0, 0, 0, 0))
  end
end
function IngameTeamPanel:InitAircraftItems(TeamMatePlayerStateList)
  local FollowItemList = {}
  local insert = table.insert
  local FollowItemConfig = UIManager.UI_Config_InGame.Ingame_FollowItem_Aircraft_UIBP
  if FollowItemConfig then
    for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
      if slua.isValid(TeamMatePlayerState) then
        local FollowItem = UIManager.ShowUI(FollowItemConfig, nIndex, TeamMatePlayerState)
        if FollowItem then
          self:AttachChildWindow("FollowItemListBox", FollowItem)
          insert(FollowItemList, FollowItem)
        end
      end
    end
    self.Aircraft  end
  local LastItem
  for _, FollowItem in pairs(FollowItemList) do
    if FollowItem and Game:IsValid(FollowItem.UIRoot) then
      FollowItem.UIRoot:SetPadding(FMargin(0, 0, 0, 0))
      LastItem = FollowItem
    end
  end
  if LastItem and Game:IsValid(LastItem.UIRoot) then
    LastItem.UIRoot:SetPadding(FMargin(0, 0, 0, 0))
  end
end
function IngameTeamPanel:RefreshAircraftControl()
  local USTExtraUIUtils = import("STExtraUIUtils")
  local uPawn = USTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not slua.isValid(uPawn) then
    self.UIRoot.Button_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local TeammateParachuteFollowStateList = uPawn.TeammateParachuteFollowState
  if TeammateParachuteFollowStateList and TeammateParachuteFollowStateList:Num() <= 1 then
    print(bWriteLog and "IngameTeamPanel:RefreshAircraftControl TeammateParachuteFollowState:Num() <= 1")
    self.UIRoot.Button_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  for _, FParachuteFollowState in pairs(TeammateParachuteFollowStateList) do
    if FParachuteFollowState.EquipTwoPersonAircraftID > 0 then
      self.UIRoot.Button_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      return
    end
  end
  self.UIRoot.Button_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamPanel:ConnectionInit(uPlayerState)
  if slua.isValid(uPlayerState) then
    self:OnReconnected(uPlayerState)
    self:OnLostDelegate(uPlayerState)
    self:OnPlayerExitGame(uPlayerState)
  end
end
function IngameTeamPanel:ClearTeamItem()
  local TeamItemList = self.TeamItemList or {}
  for _, Item in pairs(TeamItemList) do
    if Item then
      Item:Close()
    end
  end
  self.TeamItemList = {}
end
function IngameTeamPanel:ClearFollowItem()
  local FollowItemList = self.FollowItemList or {}
  for _, Item in pairs(FollowItemList) do
    if Item then
      Item:Close()
    end
  end
  self.FollowItemList = {}
  self:ClearAircraftItem()
end
function IngameTeamPanel:ClearAircraftItem()
  local FollowItemList = self.AircraftFollowItemList or {}
  for _, Item in pairs(FollowItemList) do
    if Item then
      Item:Close()
    end
  end
  self.AircraftFollowItemList = {}
end
function IngameTeamPanel:ClearPosItem()
  local TeammatePosItemList = self.TeammatePosItemList or {}
  for _, Item in pairs(TeammatePosItemList) do
    if Item then
      Item:Close()
    end
  end
  self.TeammatePosItemList = {}
end
function IngameTeamPanel:ClearOnPlanePosItem()
  local OnPlanePosItemList = self.OnPlanePosItemList or {}
  for _, Item in pairs(OnPlanePosItemList) do
    if Item then
      Item:Close()
    end
  end
  self.OnPlanePosItemList = {}
end
function IngameTeamPanel:InitSpecialUI()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, import("WarGameState")) then
    self.UIRoot.FollowBtn_WarControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.FollowPanel_WarControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if uGameState.PlayerNumPerTeam <= 1 then
      self.UIRoot.Canvas_Border_Team:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      print(bWriteLog and "TeamPanel_Debug_Msg: InitSpecialUI Hide TeamPanel")
      self:ClearTeamItem()
      self:ClearFollowItem()
    end
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and (uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator()) then
    self.UIRoot.FollowParachute_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.FollowItemListBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamPanel:InitTeamUpTips()
  local TeamUpTipsConfig = UIManager.UI_Config_InGame.IngameTeamUpTips
  if TeamUpTipsConfig and not UIManager.GetUI(TeamUpTipsConfig) then
    UIManager.ShowUI(TeamUpTipsConfig)
  end
end