local MapDataBase = {}
local slua_isValid = slua.isValid
local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local uSTExtraBlueprintFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraBlueprintFunctionLibrary")
function MapDataBase:ctor(selfType)
  self.GlobalForbidReson = {}
  self.MultiMarkItems = {}
  self.TickRate = 0.25
  self.PlayerItemMap = {}
  self.PlayerNumPerTeam = 0
  self.PlayerIconUIArray = {}
  self.PlayerMarkUIArray = {}
  self.PlayerMultiMarkUIArray = {}
end
function MapDataBase:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_PLAYERICON, self.HandleOnMapShowOrHidePlayerIcon, self)
end
function MapDataBase:CleanCircle()
  self.CircleData = nil
end
function MapDataBase:GetFullPath(sDirectPath, sItemPath)
  local sPoolPath = self.DuplicatedPoolPath
  local sFullPath = sDirectPath .. sPoolPath .. sItemPath .. "." .. sPoolPath .. sItemPath .. "_C"
  log(bWriteLog and "MapDataBase:GetFullPath:" .. sFullPath)
  return sFullPath
end
function MapDataBase:RefreshTeammateIcon(teammateIndex)
  local uMyPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uMyPlayerController) then
    return
  end
  local uPlayerState = uMyPlayerController:GetCurPlayerState()
  local uOriPlayerState = uMyPlayerController.PlayerState
  if not (slua.isValid(uPlayerState) and slua.isValid(uOriPlayerState)) or not uOriPlayerState.GetTeamMatePlayerStateList then
    return
  end
  local myMapTags = uOriPlayerState.ShowingMapTags
  local TeammatePlayerStateList = uOriPlayerState:GetTeamMatePlayerStateList({}, false)
  local PlayerBpMarkArray = self:GetPlayerBPMarkArray()
  for index, uTeamPlayerState in pairs(TeammatePlayerStateList) do
    if slua.isValid(uTeamPlayerState) then
      if uTeamPlayerState ~= uPlayerState and (teammateIndex == -1 or teammateIndex == index) then
        local OtherMapTags = uTeamPlayerState.CurMapTags
        local bIsShow = OtherMapTags == myMapTags
        local visibility = bIsShow and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed
        if index < PlayerBpMarkArray:Num() and slua.isValid(PlayerBpMarkArray:Get(index)) then
          PlayerBpMarkArray:Get(index):SetWidgetVisibility(visibility)
        end
        if teammateIndex ~= -1 then
          break
        end
      elseif uTeamPlayerState == uPlayerState and index < PlayerBpMarkArray:Num() and slua.isValid(PlayerBpMarkArray:Get(index)) then
        PlayerBpMarkArray:Get(index):SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif index < PlayerBpMarkArray:Num() and slua.isValid(PlayerBpMarkArray:Get(index)) then
      PlayerBpMarkArray:Get(index):SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function MapDataBase:SetPlayerBpIconVisible(index, reason, bIsShow)
  local PlayerBpIconArray = self:GetPlayerInfoBPArray()
  if index >= PlayerBpIconArray:Num() or not PlayerBpIconArray:Get(index) then
    return
  end
  local PlayerBgIcon = PlayerBpIconArray:Get(index)
  if PlayerBgIcon.SetPlayerBpIconVisible then
    PlayerBgIcon:SetPlayerBpIconVisible(reason, bIsShow)
  end
end
function MapDataBase:HandleOnMapShowOrHidePlayerIcon(_, __, index, reason, bIsShow)
  print(bWriteLog and string.format("MapDataBase:HandleOnMapShowOrHidePlayerIcon - %s %s %s", tostring(index), tostring(reason), tostring(bIsShow)))
  if index == -1 then
    local PlayerBpIconArray = self:GetPlayerInfoBPArray()
    for iconIndex = 0, PlayerBpIconArray:Num() do
      self:SetPlayerBpIconVisible(iconIndex, reason, bIsShow)
    end
    if bIsShow then
      self.GlobalForbidReson[reason] = nil
    else
      self.GlobalForbidReson[reason] = true
    end
  else
    self:SetPlayerBpIconVisible(index, reason, bIsShow)
  end
end
function MapDataBase:OnAfterAddPlayer(index)
  print(bWriteLog and "MapDataBase:OnAfterAddPlayer ", index)
  for key, value in pairs(self.GlobalForbidReson) do
    self:SetPlayerBpIconVisible(index, key, value)
  end
end
function MapDataBase:UpdateMultiMark(index, MultiMarkLocs, IsShow, Opacity)
  if self.MultiMarkItems[index] == nil then
    self.MultiMarkItems[index] = {}
  end
  local LocsNum = MultiMarkLocs:Num()
  local diffNum = LocsNum - #self.MultiMarkItems[index]
  if 0 < diffNum then
    for i = 1, diffNum do
      local newMarkItemUI = UIManager.ShowUI(UIManager.UI_Config.MapPlayerMultiMark)
      if newMarkItemUI then
        local newMarkItem = newMarkItemUI.UIRoot
        self:UniformScaling(newMarkItem)
        self.CurrentMapUI_BP.CurrentMapUI.PlayerAddPanel:AddChild(newMarkItem)
        table.insert(self.MultiMarkItems[index], newMarkItem)
        self.PlayerMultiMarkUIArray[#self.PlayerMultiMarkUIArray + 1] = newMarkItemUI
      end
    end
  end
  local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
  local Color = FLinearColor(1, 1, 1, 1)
  if MapManagerSubsystem then
    Color = MapManagerSubsystem:GetPlayerColorByIndex(index)
  end
  for pointIndex, value in pairs(self.MultiMarkItems[index]) do
    if slua.isValid(value) then
      if LocsNum >= pointIndex then
        local startPoint = MultiMarkLocs:Get(pointIndex - 1)
        local endPoint = startPoint
        local bIsEndPoint = false
        if LocsNum >= pointIndex + 1 then
          endPoint = MultiMarkLocs:Get(pointIndex)
        else
          bIsEndPoint = true
        end
        value:SetRenderTranslation(startPoint)
        value:RepositonMarkAngle(bIsEndPoint, startPoint, endPoint, Color)
        value:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      else
        value:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      end
    end
  end
end
function MapDataBase:AddOnePlayerIcon(playerIndex, localPlayerIndex)
  if self.PlayerNumPerTeam == nil or self.PlayerNumPerTeam <= 0 then
    local uGameState = GameplayData.GetGameState()
    if not slua.isValid(uGameState) then
      return
    end
    self.PlayerNumPerTeam = uGameState.PlayerNumPerTeam
  end
  print(bWriteLog and "MapDataBase:AddOnePlayerIcon playerIndex :" .. playerIndex .. " : " .. localPlayerIndex)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  local PlayerIcon
  local bIsSelf = playerIndex == localPlayerIndex
  local MapPlayerIcon = "EntireMapPlayerIcon"
  if self.CurrentMapUI_BP.bIsMiniMap then
    MapPlayerIcon = "MiniMapPlayerIcon"
  end
  if playerIndex >= PlayerInfoBPArray:Num() or not slua.isValid(PlayerInfoBPArray:Get(playerIndex)) then
    local PlayerIconUI = UIManager.ShowUI(UIManager.UI_Config[MapPlayerIcon])
    if not PlayerIconUI then
      return
    end
    PlayerIcon = PlayerIconUI.UIRoot
    self:UniformScaling(PlayerIcon)
    self.PlayerIconUIArray[#self.PlayerIconUIArray + 1] = PlayerIconUI
    self:SetPlayerInfoBpArray(playerIndex, PlayerIcon, true)
    local displayWidget = PlayerIcon:GetRotationDisplayWidget()
    self:SetPlayerRotBpArray(playerIndex, displayWidget, true)
    local uGlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
    local Color = uGlobalBattleUIFunctionLibrary.GetPlayerTeamColor(playerIndex)
    PlayerIcon:SetTeammateInfo(playerIndex + 1, Color)
    local ZOrder = 0
    if bIsSelf then
      ZOrder = self.PlayerNumPerTeam + 1
    else
      ZOrder = self.PlayerNumPerTeam - playerIndex
    end
    self:AddtoRootPanel(PlayerIcon, ZOrder, self.CurrentMapUI_BP.CurrentMapUI.PlayerAddPanel)
  else
    PlayerIcon = PlayerInfoBPArray:Get(playerIndex)
  end
  if slua.isValid(PlayerIcon) then
    PlayerIcon:SetSelfStyle(bIsSelf)
    PlayerIcon:SwitchVisibility(true)
    PlayerIcon.CachePlayerIndex = playerIndex
  end
  self:OnAfterAddPlayer(playerIndex)
end
function MapDataBase:SetSelfStype(index, bIsSelf)
  print(bWriteLog and "MapDataBase:SetSelfStype Index : ", index, " bIsSelf :", bIsSelf)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if index < PlayerInfoBPArray:Num() and slua.isValid(PlayerInfoBPArray:Get(index)) then
    local PlayerIcon = PlayerInfoBPArray:Get(index)
    local ZOrder = 0
    if bIsSelf then
      ZOrder = self.PlayerNumPerTeam + 1
    else
      ZOrder = self.PlayerNumPerTeam - index
    end
    PlayerIcon.Slot:SetZOrder(ZOrder)
    PlayerIcon:SetSelfStyle(bIsSelf)
  end
end
function MapDataBase:AddOnePlayerMark(playerIndex, localPlayerIndex)
  print(bWriteLog and "MapDataBase:AddOnePlayerMark playerIndex :", playerIndex, " : ", localPlayerIndex)
  local PlayerInfoBPArray = self:GetPlayerBPMarkArray()
  if 0 <= playerIndex and playerIndex < PlayerInfoBPArray:Num() and slua.isValid(PlayerInfoBPArray:Get(playerIndex)) then
    return
  end
  local MapPlayerMark = "EntireMapPlayerMark"
  if self.CurrentMapUI_BP.bIsMiniMap then
    MapPlayerMark = "MiniMapPlayerMark"
  end
  local PlayerMarkUI = UIManager.ShowUI(UIManager.UI_Config[MapPlayerMark])
  if not PlayerMarkUI then
    return
  end
  local PlayerMark = PlayerMarkUI.UIRoot
  self:UniformScaling(PlayerMark)
  self.PlayerMarkUIArray[#self.PlayerMarkUIArray + 1] = PlayerMarkUI
  self:SetPlayerMarkBpArray(playerIndex, PlayerMark, true)
  local uGlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local Color = uGlobalBattleUIFunctionLibrary.GetPlayerTeamColor(playerIndex)
  PlayerMark:SetMarkColor(Color)
  local slot = self.CurrentMapUI_BP.CurrentMapUI.PlayerAddPanel:AddChildtoCanvas(PlayerMark)
  slot:SetAnchors(FAnchors(0.5, 0.5, 0.5, 0.5))
  local ZOrder = -playerIndex
  if playerIndex == localPlayerIndex then
    ZOrder = 1
  end
  slot:SetZOrder(ZOrder)
  slot:SetSize(FVector2D(20, 28))
end
function MapDataBase:TickWidget()
  if self.CurHoldWidget and self.CurHoldWidget:IsVisible() then
    for key, value in pairs(self.PlayerItemMap) do
      value:UpdateWidgetForReplay(false)
    end
  end
end
function MapDataBase:InitPlayerItemInMap(bIsResetOnViewerChanged)
  log(bWriteLog and "MapDataBase:InitPlayerItemInMap start")
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    log(bWriteLog and "MapDataBase:InitPlayerItemInMap GameState invalid")
    return
  end
  self.PlayerNumPerTeam = uGameState.PlayerNumPerTeam
  log(bWriteLog and "MapDataBase:InitPlayerItemInMap PlayerNumPerTeam " .. self.PlayerNumPerTeam)
  local tPlayerStates = uGameState.PlayerArray
  local nPlayerStateNum = tPlayerStates:Num()
  if nPlayerStateNum <= 0 then
    log(bWriteLog and "MapDataBase:InitPlayerItemInMap tPlayerStates empty")
    return
  end
  for i = 0, nPlayerStateNum - 1 do
    local uPlayerStateInst = tPlayerStates:Get(i)
    if slua.isValid(uPlayerStateInst) and uPlayerStateInst.GetPlayerKey then
      local sPlayerKey = uPlayerStateInst:GetPlayerKey()
      if sPlayerKey and sPlayerKey ~= 0 then
        local uFoundPlayerState = self.PlayerItemMap[sPlayerKey]
        if slua.isValid(uFoundPlayerState) then
          self:ReInitPlayerItemInMap(uPlayerStateInst, bIsResetOnViewerChanged)
        else
          self:CreatePlayerItemInMap(uPlayerStateInst)
        end
      end
    end
  end
  if self.TickWidgetTimer == nil then
    self.CurHoldWidget = self.CurrentMapUI_BP.HoldWidget
    log(bWriteLog and "MapDataBase:InitPlayerItemInMap init CurHoldWidget")
    self.TickWidgetTimer = self:AddGameTimer(self.TickRate, true, function()
      self:TickWidget()
    end)
    log(bWriteLog and "MapDataBase:InitPlayerItemInMap Add Tick Function")
  end
  if self.CurrentMapUI_BP then
    local bIsMiniMap = self.CurrentMapUI_BP.bIsMiniMap
    if bIsMiniMap then
      self.CurrentMapUI_BP:SetNotChangeScale(true)
      log(bWriteLog and "MapDataBase:InitPlayerItemInMap SetNotChangeScale false")
    end
  end
  log(bWriteLog and "MapDataBase:InitPlayerItemInMap end")
end
function MapDataBase:CreatePlayerItemInMap(uInPlayerState)
  log(bWriteLog and "MapDataBase:CreatePlayerItemInMap start")
  if not slua.isValid(uInPlayerState) then
    log(bWriteLog and "MapDataBase:CreatePlayerItemInMap uInPlayerState invalid")
    return
  end
  if not uInPlayerState.GetPlayerKey then
    log(bWriteLog and "MapDataBase:ReInitPlayerItemInMap uInPlayerState.GetPlayerKey invalid")
    return
  end
  local PlayerItem = uSTExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/UI/Map/Item/PlayerItem_BP.PlayerItem_BP_C", uInPlayerState)
  if PlayerItem then
    local CurMapUI = self.CurrentMapUI_BP.CurrentMapUI
    local bIsMiniMap = self.CurrentMapUI_BP.bIsMiniMap
    if CurMapUI and bIsMiniMap ~= nil then
      PlayerItem:InitByMapData(bIsMiniMap)
      PlayerItem:InitWidgetForReplay(uInPlayerState, self.PlayerNumPerTeam == 1, CurMapUI)
      self.PlayerItemMap[uInPlayerState:GetPlayerKey()] = PlayerItem
      self:AddtoRootPanel(PlayerItem, 20, CurMapUI.PlayerAddPanel)
      PlayerItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      if uInPlayerState:IsAlive() then
        PlayerItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        PlayerItem:UpdateWidgetForReplay(false)
      end
    end
  end
  log(bWriteLog and "MapDataBase:CreatePlayerItemInMap end")
end
function MapDataBase:ReInitPlayerItemInMap(uInPlayerState, bIsResetOnViewerChanged)
  log(bWriteLog and "MapDataBase:ReInitPlayerItemInMap start")
  if not slua.isValid(uInPlayerState) then
    log(bWriteLog and "MapDataBase:ReInitPlayerItemInMap uInPlayerState invalid")
    return
  end
  if not uInPlayerState.GetPlayerKey then
    log(bWriteLog and "MapDataBase:ReInitPlayerItemInMap uInPlayerState.GetPlayerKey invalid")
    return
  end
  local OldItem = self.PlayerItemMap[uInPlayerState:GetPlayerKey()]
  if OldItem then
    OldItem:InitWidgetForReplay(uInPlayerState, self.PlayerNumPerTeam == 1, nil)
    OldItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if uInPlayerState:IsAlive() then
      OldItem:UpdateWidgetForReplay(bIsResetOnViewerChanged)
    end
  end
  log(bWriteLog and "MapDataBase:ReInitPlayerItemInMap end")
end
function MapDataBase:OnDestroy()
  for _, PlayerIconTemp in ipairs(self.PlayerIconUIArray) do
    PlayerIconTemp:Close()
  end
  self.PlayerIconUIArray = {}
  local PlayerInfoBPArray = slua.IndexReference(self.CurrentMapData, "PlayerInfoBPArrayC")
  if PlayerInfoBPArray then
    for _, PlayerInfoItem in pairs(PlayerInfoBPArray) do
      if slua.isValid(PlayerInfoItem) then
        PlayerInfoItem:ConditionalBeginDestroy()
      end
    end
    PlayerInfoBPArray:Clear()
  end
  local PlayerRotBPArray = slua.IndexReference(self.CurrentMapData, "PlayerInfoRotWidgetArrayC")
  if PlayerRotBPArray then
    for _, PlayerRotItem in pairs(PlayerRotBPArray) do
      if slua.isValid(PlayerRotItem) then
        PlayerRotItem:ConditionalBeginDestroy()
      end
    end
    PlayerRotBPArray:Clear()
  end
  for _, PlayerMark in ipairs(self.PlayerMarkUIArray) do
    PlayerMark:Close()
  end
  self.PlayerMarkUIArray = {}
  local PlayerMarkBPArray = slua.IndexReference(self.CurrentMapData, "PlayerMarkBPArrayC")
  if PlayerMarkBPArray then
    for _, MarkBPItem in pairs(PlayerMarkBPArray) do
      if slua.isValid(MarkBPItem) then
        MarkBPItem:ConditionalBeginDestroy()
      end
    end
    PlayerMarkBPArray:Clear()
  end
  for _, MultiMark in ipairs(self.PlayerMultiMarkUIArray) do
    MultiMark:Close()
  end
  self.PlayerMultiMarkUIArray = {}
  if self.MultiMarkItems then
    for Index, ArrayValue in pairs(self.MultiMarkItems) do
      for pointIndex, value in pairs(ArrayValue) do
        if slua.isValid(value) then
          value:RemoveFromParent()
          value:ConditionalBeginDestroy()
        end
      end
    end
  end
  self.MultiMarkItems = {}
  self.CurHoldWidget = nil
  if self.TickWidgetTimer then
    self:RemoveGameTimer(self.TickWidgetTimer)
    self.TickWidgetTimer = nil
  end
  self.PlayerItemMap = nil
  self:Dispose()
end
function MapDataBase:InitMapData()
  self.CurrentMapData = CGame:NewObjectFromPath("/Script/ShadowTrackerExtra.MapDataBase", self)
end
function MapDataBase:GetPlayerInfoBPArray()
  return self.CurrentMapData.PlayerInfoBPArrayC
end
function MapDataBase:AddExtraTopPlayerIcon()
end
function MapDataBase:ResetPlayerInfoBPArray()
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  for Index = 0, PlayerInfoBPArray:Num() - 1 do
    local PlayerInfoBP = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfoBP) then
      PlayerInfoBP:SwitchVisibility(false)
    end
  end
end
function MapDataBase:SetPlayerInfoBpArray(Index, Item, bSizeToFit)
  local PlayerInfoArray = self.CurrentMapData.PlayerInfoBPArrayC
  local Num = PlayerInfoArray:Num()
  if bSizeToFit then
    while Index >= Num do
      PlayerInfoArray:Add(nil)
      Num = PlayerInfoArray:Num()
    end
    PlayerInfoArray:Set(Index, Item)
  elseif Index < Num then
    PlayerInfoArray:Set(Index, Item)
  end
end
function MapDataBase:GetPlayerInfoRotWidgetArray()
  return self.CurrentMapData.PlayerInfoRotWidgetArrayC
end
function MapDataBase:HandleConstruct(InMapUI)
  self.CurrentMapUI_BP = InMapUI
  self.CurrentHoldMapUI = self.CurrentMapUI_BP.CurrentMapUI
  self.DuplicatedPoolPath = self.CurrentMapUI_BP.DuplicatedPoolPath
  self:InitMapData()
  self.CurrentMapData:Init(self.CurrentMapUI_BP.CurrentMapUI)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_ON_MAP_DATA_CONSTRUCTED)
end
function MapDataBase:GetCurrentMapUI()
  if slua_isValid(self.CurrentMapUI_BP) then
    return self.CurrentMapUI_BP.CurrentMapUI
  end
end
function MapDataBase:SetSpectatorInfoAndColor(PlayerState)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local uPlayerState = PlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) then
      local OutList = uPlayerState:GetTeamMatePlayerStateList({}, false)
      for ArrayIndex, ArrayElement in pairs(OutList) do
        local bIsSelf = ArrayElement == PlayerState
        self:SetSelfStype(ArrayIndex, bIsSelf)
      end
    end
  end
end
function MapDataBase:AddOnePlayer(Index, LocalPlayerIndex)
  local PlayerIndex = 0
  local PlayerColor = FLinearColor(0.0, 0.0, 0.0, 0.0)
  self:AddOnePlayerIcon(Index, LocalPlayerIndex)
  self:AddExtraTopPlayerIcon(Index, LocalPlayerIndex)
  self:AddOnePlayerMark(Index, LocalPlayerIndex)
end
function MapDataBase:AddToRootPanel(BPWidget, Zorder, RootPanel)
  if not RootPanel:HasChild(BPWidget) then
    local Canvas = RootPanel:AddChildToCanvas(BPWidget)
    Canvas:SetAnchors(FAnchors(0.5, 0.5, 0.5, 0.5))
    Canvas:SetPosition(FVector2D(0.0, 0.0))
    Canvas:SetZOrder(Zorder)
    Canvas:SetAlignment(FVector2D(0.5, 0.5))
  end
end
function MapDataBase:GetPlayerBPMarkArray()
  return self.CurrentMapData.PlayerMarkBPArrayC
end
function MapDataBase:UpdateMark(Index, FLoc, bIsShow, Opacity)
  local MarkArray = self:GetPlayerBPMarkArray()
  if 0 <= Index and Index < MarkArray:Num() then
    local Mark = MarkArray:Get(Index)
    if slua_isValid(Mark) then
      Mark:UpdateMark(bIsShow, FLoc, Opacity)
    end
  end
end
function MapDataBase:HideAllMapMark()
  for Index, Mark in pairs(self:GetPlayerBPMarkArray()) do
    if slua_isValid(Mark) then
      self:UpdateMark(Index, FVector2D(0.0, 0.0), false, 0.0)
    end
  end
end
function MapDataBase:SetSingleStype(Index, bIsSingle)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if 0 <= Index and Index < PlayerInfoBPArray:Num() then
    local PlayerInfo = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfo) then
      PlayerInfo:SetSingleStyle(bIsSingle)
    end
  end
end
function MapDataBase:SwitchVisiblity(Index, bIsShow)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if 0 <= Index and Index < PlayerInfoBPArray:Num() then
    local PlayerInfo = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfo) then
      PlayerInfo:SwitchVisibility(bIsShow)
    end
  end
end
function MapDataBase:SetPlayerName(Index, Name)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if 0 <= Index and Index < PlayerInfoBPArray:Num() then
    local PlayerInfo = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfo) then
      PlayerInfo:SetPlayerName("")
    end
  end
end
function MapDataBase:UpdateVeteranStatus(Index, MentorType, VeteranLevel)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if 0 <= Index and Index < PlayerInfoBPArray:Num() then
    local PlayerInfo = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfo) then
      PlayerInfo:UpdateVeteranStatus(MentorType, VeteranLevel)
    end
  end
end
function MapDataBase:SwitchAliveDeadIconBool(Index, bIsDead)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if 0 <= Index and Index < PlayerInfoBPArray:Num() then
    local PlayerInfoBP = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfoBP) then
      if PlayerInfoBP.SwitchAliveDeadIcon then
        PlayerInfoBP:SwitchAliveDeadIcon(bIsDead)
      else
        local SwitchAliveDeadIconFunc = PlayerInfoBP["SwitchAlive/DeadIcon"]
        if SwitchAliveDeadIconFunc then
          SwitchAliveDeadIconFunc(PlayerInfoBP, bIsDead)
        end
      end
    end
  end
end
function MapDataBase:HandleReceiveInitWidget(RootPanel)
  self.Markend
function MapDataBase:GetOwningPlayer()
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) then
    return PlayerController
  end
end
function MapDataBase:SwitchAllAliveDeadIcon(bIsDead)
  print(bWriteLog and "MapDataBase:SwitchAllAliveDeadIcon")
  for Index, PlayerInfo in pairs(self:GetPlayerInfoBPArray()) do
    self:SwitchAliveDeadIconBool(Index, bIsDead)
  end
end
function MapDataBase:SetPlayerRotBpArray(Index, Item, bSizeToFit)
  local PlayerInfoArray = self.CurrentMapData.PlayerInfoRotWidgetArrayC
  local Num = PlayerInfoArray:Num()
  if bSizeToFit then
    while Index >= Num do
      PlayerInfoArray:Add(nil)
      Num = PlayerInfoArray:Num()
    end
    PlayerInfoArray:Set(Index, Item)
  elseif Index < Num then
    PlayerInfoArray:Set(Index, Item)
  end
end
function MapDataBase:SetPlayerMarkBpArray(Index, Item, bSizeToFit)
  local PlayerInfoArray = self.CurrentMapData.PlayerMarkBPArrayC
  local Num = PlayerInfoArray:Num()
  if bSizeToFit then
    while Index >= Num do
      PlayerInfoArray:Add(nil)
      Num = PlayerInfoArray:Num()
    end
    PlayerInfoArray:Set(Index, Item)
  elseif Index < Num then
    PlayerInfoArray:Set(Index, Item)
  end
end
function MapDataBase:CheckNeedZoomToFit()
  return false, 0.0, FVector2D(0.0, 0.0)
end
function MapDataBase:OnModPaint(PaintContext, PaintType, CircleColor)
end
function MapDataBase:RepositionSelfMarker()
end
function MapDataBase:SwitchAliveDeadIcon(Index, LiveState)
  local PlayerInfoBPArray = self:GetPlayerInfoBPArray()
  if 0 <= Index and Index < PlayerInfoBPArray:Num() then
    local PlayerInfo = PlayerInfoBPArray:Get(Index)
    if slua_isValid(PlayerInfo) then
      local bIsDead = false
      if LiveState == ExtraPlayerLiveState.InDied then
        bIsDead = true
      elseif LiveState == ExtraPlayerLiveState.Offline then
        return
      end
      PlayerInfo:SwitchAliveDeadIcon(bIsDead)
    end
  end
end
function MapDataBase:UniformScaling(Widget)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CMapDataBase = class(CDelegateContainer, nil, MapDataBase)
return CMapDataBase