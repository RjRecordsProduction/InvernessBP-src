local NavigatorPanel = {}
local EWidgetVisible = import("EWidgetVisible")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local GameplayStatics = import("GameplayStatics")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local TableUtil = require("common.table_util")
function NavigatorPanel:ctor()
  self.LoadHandles = {}
  self.CustomMark = {}
  self.NeedAddCustomMark = {}
  self.StartInstanceID = 1
  self.PlayerMarkerShow = UEnums.ESlateVisibility.Hidden
  self.VoiceImageObjectList = {}
  self.VoiceShowList = {}
  self.VoiceCheck = nil
  self.TeamMatePSList = {}
  self.CurPlayerID = 0
  self.LocalPlayerIndex = 0
  self.bNeedUpdateTeamMateInfo = false
  self.CompassMat = nil
  self.ImageSize = 34.0
  self.HalfShowSize = 250.0
  self.HalfFullSize = 640.0
  self.PlayerIconTable = {}
  self.MarkItemPool = {}
  self.PlayerController = nil
  self.bShowFadeOutAnim = false
end
function NavigatorPanel:OnInitialize()
  local PositionUIPath = "/Game/BluePrints/UI/Map/Item/NavigatorPlayerMarkItem.NavigatorPlayerMarkItem_C"
  local PoolClass = import("UIDuplicatedItemPool")
  self.MarkItemPool = PoolClass(self.UIRoot)
  self.MarkItemPool.bActiveItemListHold = true
  self.MarkItemPool:InitItemPool(PositionUIPath, 4, false)
  self.UIRoot.NormalDirectionTextColor = FSlateColor(FLinearColor(1, 1, 1, 1))
end
function NavigatorPanel:OnPostInitialize()
  print(bWriteLog and "NavigatorPanel:OnPostInitialize")
  self:AttachToMainControl()
  for _, Data in pairs(self.NeedAddCustomMark) do
    self:AddCustomMark(Data.UIPath, Data.Position, Data.bAdjustBound, Data.bIsIcon, Data.MarkInstID, Data.CustomStatus)
  end
  self:InitParam()
  self:InitPanel()
  NavigatorPanel.__super.OnPostInitialize(self)
  self.UIRoot.HalfPix = -240
end
function NavigatorPanel:RegistEvents()
  print(bWriteLog and "NavigatorPanel:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.SetRootVisibilityByEvent, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_NAVIGATOR_RE_INIT, self.ReInitUI, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnectResetUIByPlayerControllerStateDelegate, self)
  self:AddControlEventByControl(self.UIRoot, "OnMarkOutDistanceDel", self.OnMarkOutDistanceChange, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root, self, "NavigatorPanel_CanvasPanelRoot")
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_RESIZE_MINIMAP, self.OnUpdateMinimapStand, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.OnRepPlayerState, self)
  if self.UIRoot.Anim_FadeOut then
    self:AddControlEvent("Anim_FadeOut", "OnAnimationFinished", self.OnFadeOutAnimationFinished, self)
  end
  self:AddControlEventByControl(self.UIRoot, "OnMarkOutDistanceDel", self.OnPlayerEnterSafeZone, self)
  NavigatorPanel.__super.RegistEvents(self)
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if DataLayerSubsystem then
    self:AddDataListener(DataLayerSubsystem:GetSuperData(), "InBornIslandMusicPlayer", self.OnInBornIslandMusicPlayerChange, self)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
end
function NavigatorPanel:OnInBornIslandMusicPlayerChange(_, InBornIslandMusicPlayer)
  print(bWriteLog and "NavigatorPanel:OnInBornIslandMusicPlayerChange", InBornIslandMusicPlayer)
  if InBornIslandMusicPlayer then
    self.UIRoot.CanvasPanel_Root:SetWidgetRender(EWidgetVisible.ForceNotVisible)
  else
    self.UIRoot.CanvasPanel_Root:SetWidgetRender(EWidgetVisible.ForceVisible)
  end
  if not self.TimerHandle then
    self.TimerHandle = self:AddGameTimer(60, false, function()
      self.UIRoot.CanvasPanel_Root:SetWidgetRender(EWidgetVisible.ForceVisible)
      self:SelfHitTestInvisible()
    end)
  end
end
function NavigatorPanel:AttachToMainControl()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    self.InitializeFailed = true
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "NavigatorPanel:OnPostInitialize Failed Case MainControlBaseUI")
    return
  end
  local ParentPanelRoot = MainControlBaseUI.CanvasPanel_42
  if slua.isValid(ParentPanelRoot) then
    ParentPanelRoot:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 0))
    self.UIRoot.Slot:SetOffsets(FMargin(350, -3.347113, 350, 85))
    self.UIRoot:SetRenderScale(FVector2D(0.9, 0.9))
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.InitializeFailed = false
    self.UIRoot:InitWidget(true)
    self:OnAddPlayer()
    if MainControlBaseUI.NavigatorIsShow ~= nil then
      self:SetRootVisibility(MainControlBaseUI.NavigatorIsShow)
    else
      self:SetRootVisibility(true)
    end
  else
    self.InitializeFailed = true
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "NavigatorPanel:OnPostInitialize Failed Case ParentPanelRoot")
  end
end
function NavigatorPanel:PostShowUIEnd(statUIInfo, showVisibility)
  NavigatorPanel.__super.PostShowUIEnd(self, statUIInfo, nil)
end
function NavigatorPanel:OnAddPlayer()
  if self:IsInfectMode() then
    return
  end
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local NumPerTeam = GameState.PlayerNumPerTeam
  if NumPerTeam == 1 then
    self:AddOnePlayer(0)
  else
    local uPlayerState = GameplayData.GetPlayerState()
    if not slua.isValid(uPlayerState) or not uPlayerState.GetTeamMatePlayerStateList then
      return
    end
    local TeammateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
    for i = 0, TeammateList:Num() - 1 do
      self:AddOnePlayer(i)
    end
    self.UIRoot:OnMapMarkChange_NoParam()
  end
end
function NavigatorPanel:AddCustomMark(UIPath, Position, bAdjustBound, bIsIcon, MarkInstID, CustomStatus)
  if not MarkInstID then
    MarkInstID = self.StartInstanceID
    self.StartInstanceID = self.StartInstanceID + 1
  end
  if not slua.isValid(self.UIRoot) then
    self.NeedAddCustomMark[MarkInstID] = {}
    self.NeedAddCustomMark[MarkInstID].    self.NeedAddCustomMark[MarkInstID].    self.NeedAddCustomMark[MarkInstID].    self.NeedAddCustomMark[MarkInstID].    self.NeedAddCustomMark[MarkInstID].    self.NeedAddCustomMark[MarkInstID].    return
  end
  if self.CustomMark[MarkInstID] then
    print(bWriteLog and "NavigatorPanel:AddCustomMark Already Has InstID :" .. MarkInstID)
    return self.CustomMark[MarkInstID], MarkInstID
  end
  self.CustomMark[MarkInstID] = {}
  if bIsIcon then
    local uNewCustomMark = CGame:NewObjectFromPath("/Script/UMG.Image", self.UIRoot)
    if not uNewCustomMark then
      return nil
    end
    self.CustomMark[MarkInstID].Widget = uNewCustomMark
    self.CustomMark[MarkInstID].Mark    uNewCustomMark:SetBrushfromPathAsync(UIPath, true)
    self:AfterGetAsset(uNewCustomMark, Position, bAdjustBound, MarkInstID)
  else
    self.CustomMark[MarkInstID].Mark    local LoadUIHandle = slua.AsyncLoadUI(UIPath, function(_, Widget)
      if slua.isValid(Widget) then
        if not self.CustomMark[MarkInstID] then
          self.CustomMark[MarkInstID] = {}
        end
        self.CustomMark[MarkInstID].        self:AfterGetAsset(Widget, Position, bAdjustBound, MarkInstID, CustomStatus)
      end
    end)
    self.LoadHandles[MarkInstID] = LoadUIHandle
  end
  return self.CustomMark[MarkInstID], MarkInstID
end
function NavigatorPanel:DestroyCustomMark(MarkInstID)
  if self.NeedAddCustomMark[MarkInstID] then
    self.NeedAddCustomMark[MarkInstID] = nil
    return
  end
  if self.CustomMark[MarkInstID] == nil or not slua.isValid(self.CustomMark[MarkInstID].Widget) then
    return
  end
  self.CustomMark[MarkInstID].Widget:RemoveFromParent()
  self.CustomMark[MarkInstID].Widget:ConditionalBeginDestroy()
  self.CustomMark[MarkInstID] = nil
end
function NavigatorPanel:GetCustomMark(MarkInstID)
  return self.CustomMark[MarkInstID]
end
function NavigatorPanel:AfterGetAsset(Asset, Position, bAdjustBound, MarkInstID, CustomStatus)
  local uCanvasSlot = self.UIRoot.CanvasPanel_Navigator_NoClip:AddChildToCanvas(Asset)
  uCanvasSlot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
  uCanvasSlot:SetAutoSize(true)
  uCanvasSlot:SetPosition(FVector2D(0, 0))
  local uFCustomMarkDataInNavigator = import("CustomMarkDataInNavigator")()
  uFCustomMarkDataInNavigator.  uFCustomMarkDataInNavigator.MarkWidget = Asset
  if Asset.GetMarkDistWidget then
    uFCustomMarkDataInNavigator.MarkDistanceText = Asset:GetMarkDistWidget()
  end
  if Asset.GetMaxDistance then
    uFCustomMarkDataInNavigator.MaxDistance = Asset:GetMaxDistance()
  end
  if Asset.InitCustomData then
    Asset:InitCustomData(CustomStatus)
  end
  uFCustomMarkDataInNavigator.MarkLocation = Position
  uFCustomMarkDataInNavigator.bAdjustWhenOutRange = bAdjustBound
  self.UIRoot.CustomMarkDataInNavigator:Add(uFCustomMarkDataInNavigator)
  self.LoadHandles[MarkInstID] = nil
end
function NavigatorPanel:OnClose()
  print(bWriteLog and "NavigatorPanel:OnClose")
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  for _, LoadHandle in pairs(self.LoadHandles) do
    if LoadHandle then
      slua.CancelLoadUI(LoadHandle)
    end
  end
  self.LoadHandles = {}
  for _, MarkInfo in pairs(self.CustomMark) do
    if MarkInfo.Widget then
      MarkInfo.Widget:RemoveFromParent()
      MarkInfo.Widget:ConditionalBeginDestroy()
    end
  end
  self.CustomMark = {}
  if self.UIRoot and self.UIRoot.CanvasPanel_Root then
    HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root)
  end
end
function NavigatorPanel:SetRootVisibilityByEvent(_, _, bIsShow)
  print(bWriteLog and "NavigatorPanel:SetRootVisibilityByEvent " .. tostring(bIsShow))
  self:SetRootVisibility(bIsShow)
end
function NavigatorPanel:SetRootVisibility(bIsShow)
  if bIsShow then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function NavigatorPanel:OnMarkOutDistanceChange(InstID, bIsOutDis)
  if not self.CustomMark[InstID] then
    print(bWriteLog and "NavigatorPanel:OnMarkOutDistanceChange DO NOT Has InstID :" .. InstID)
    return
  end
  local UIWidget = self.CustomMark[InstID].Widget
  if slua.isValid(UIWidget) and UIWidget.OnOutDistanceStateChange then
    UIWidget:OnOutDistanceStateChange(bIsOutDis)
  end
end
function NavigatorPanel:ReInitUI()
  self:DemoReplayReInit()
end
function NavigatorPanel:ReSetPara(Extent, Center)
  self.UIRoot:SetExtentAndCenter(Extent, Center)
end
function NavigatorPanel:DemoReplayReInit()
  self:InitPanel()
end
function NavigatorPanel:InitParam()
  local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
  local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
  if not MapManagerSubsystem or not MapIconSubsystem then
    return
  end
  local AreaID = MapIconSubsystem:GetAreaID()
  local StandParam = MapManagerSubsystem:GetTagParam(AreaID)
  if StandParam == nil then
    return
  end
  self:ReSetPara(StandParam.BoundExtent, StandParam.Loc)
end
function NavigatorPanel:InitPanel()
  self:InitCompassWidget()
  self:GetLandscapeRotation()
  self.UIRoot:BindMapMarkChangeDelegate()
  local IngamePlayerDataSys = require("GameLua.Mod.BaseMod.Client.IngamePlayerDataSys")
  if IngamePlayerDataSys:GetPlayerLevel() <= 5 then
    self.UIRoot.Border_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function NavigatorPanel:InitPlayerState()
  local uTeamMatePlayerStateList, CurPlayerID = self:GetTeamPSListAndCurPlayerID()
  if not uTeamMatePlayerStateList then
    return
  end
  for key, uTeammatePlayerState in pairs(uTeamMatePlayerStateList) do
    if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.PlayerId and uTeammatePlayerState.PlayerId == CurPlayerID then
      self.LocalPlayerIndex = key - 1
      break
    end
  end
  if 1 < uTeamMatePlayerStateList.Num then
    self.bNeedUpdateTeamMateInfo = true
  end
  self:BindTeamMapMarkDelegate()
end
function NavigatorPanel:GetPlayerColorByIndex(Index)
  local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
  local Color = TeamPanelConfig.TeamPlayerColorTable[Index + 1]
  if Color then
    return Color
  end
  return FLinearColor(1, 1, 1, 1)
end
function NavigatorPanel:CreateTipsImage(Type)
  local NowImage = CGame:NewObjectFromPath("/Script/UMG.Image", self.UIRoot)
  if not NowImage then
    return nil
  end
  self.UIRoot.TipsCanvas:AddChildToCanvas(NowImage)
  if Type == "PlayerMoveVoice" then
    NowImage:SetBrush(self.UIRoot.FootTips.Brush)
  elseif Type == "VehicleMoveVoice" then
    NowImage:SetBrush(self.UIRoot.CarTips.Brush)
  elseif Type == "WeponVoice" then
    NowImage:SetBrush(self.UIRoot.ShotTips.Brush)
  end
  local ImageSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(NowImage)
  ImageSlot:SetAutoSize(true)
  ImageSlot:SetPosition(FVector2D(0, 0))
  ImageSlot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
  ImageSlot:SetAlignment(FVector2D(0.5, 0))
  NowImage:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  return NowImage
end
function NavigatorPanel:InitVoiceImageList()
  for i = 1, 5 do
    table.insert(self.VoiceImageObjectList, self:CreateVoiceCheckObject("PlayerMoveVoice"))
  end
  for i = 1, 5 do
    table.insert(self.VoiceImageObjectList, self:CreateVoiceCheckObject("VehicleMoveVoice"))
  end
  for i = 1, 5 do
    table.insert(self.VoiceImageObjectList, self:CreateVoiceCheckObject("WeaponVoice"))
  end
end
function NavigatorPanel:CreateVoiceCheckObject(CheckType)
  local VoiceObj = CGame:NewObjectFromPath("/Game/BluePrints/Environment/BP_VoiceUIObject.BP_VoiceUIObject", self.UIRoot)
  if not slua.isValid(VoiceObj) then
    return nil
  end
  VoiceObj.middleImage = self:CreateTipsImage(CheckType)
  VoiceObj.showType = CheckType
  VoiceObj.playerController = self.PlayerController
  return VoiceObj
end
function NavigatorPanel:GetVoicePostion(Index, Scale)
  local ResultPosX = 15 * Index * self.angleToPiexl + self.angleToPiexl * 7.5
  local ResultPosY = Scale - 19.5
  return ResultPosX, ResultPosY
end
function NavigatorPanel:UpdateShowVoiceIcon(DeltaTime)
  if not slua.isValid(self.VoiceCheck) then
    return
  end
  local DeleteList = {}
  for key, ShowObj in pairs(self.VoiceShowList) do
    if ShowObj then
      if ShowObj:UpdateState(DeltaTime) then
        local ResultPosX, ResultPosY = self:GetVoicePostion(ShowObj.NowIndex, ShowObj.nowshowScale)
        WidgetLayoutLibrary.SlotAsCanvasSlot(ShowObj.middleImage):SetPosition(FVector2D(self.UIRoot.GetFinalX(0, ResultPosX, ShowObj.nowshowScale), 0))
      else
        table.insert(DeleteList, ShowObj)
      end
    end
  end
  self.VoiceShowList = TableUtil.Diff(self.VoiceShowList, DeleteList)
  for key, ShowObj in pairs(self.VoiceImageObjectList) do
    if ShowObj and ShowObj.middleImage:IsVisible() and not TableUtil.IsInTable(self.VoiceShowList, ShowObj) then
      ShowObj.middleImage:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
  end
end
function NavigatorPanel:UpdateNewVocieState()
  if not slua.isValid(self.VoiceCheck) then
    return
  end
  if slua.isValid(self.VoiceCheck.playerMoveCheck) then
    local PlayerMoveCheck = self.VoiceCheck.playerMoveCheck
    if PlayerMoveCheck.IsRefresh then
      self:UpdateVoiceStateOneType(PlayerMoveCheck)
    end
  end
  if slua.isValid(self.VoiceCheck.vehicleMoveCheck) then
    local VehicleMoveCheck = self.VoiceCheck.vehicleMoveCheck
    if VehicleMoveCheck.IsRefresh then
      self:UpdateVoiceStateOneType(VehicleMoveCheck)
    end
  end
  if slua.isValid(self.VoiceCheck.weaponCheck) then
    local WeaponCheck = self.VoiceCheck.weaponCheck
    if WeaponCheck.IsRefresh then
      self:UpdateVoiceStateOneType(WeaponCheck)
    end
  end
end
function NavigatorPanel:GetMinShowTimeObject(NowSubObject)
  local NowTime = 1000000
  local NowShowObj
  for key, ShowObj in pairs(self.VoiceImageObjectList) do
    if ShowObj then
      if self:IsSamVoiceObject(NowSubObject, ShowObj) then
        return ShowObj
      end
      if ShowObj.showType == NowSubObject.checkType and NowTime > ShowObj.ShowTimeLeave then
        Now        NowTime = ShowObj.ShowTimeLeave
      end
    end
  end
  return NowShowObj
end
function NavigatorPanel:UpdateVoiceStateOneType(NowObj)
  if slua.isValid(NowObj) then
    return
  end
  NowObj.IsRefresh = false
  for key, NowSubObject in pairs(NowObj.subCheckList) do
    if not NowSubObject.isShow then
      return
    end
    local NowUIObj = self:GetMinShowTimeObject(NowSubObject)
    self:SetOneData(NowUIObj, NowSubObject)
    self:RemoveSameActorShow(NowUIObj)
    if not TableUtil.IsInTable(self.VoiceShowList, NowUIObj) then
      table.insert(self.VoiceShowList, NowUIObj)
    end
    self:SetVoiceChekImageZorder()
  end
end
function NavigatorPanel:IsSamVoiceObject(SubObject, ShowObj)
  if SubObject.checkType ~= ShowObj.showType then
    return false
  end
  local bIsSame = false
  if SubObject.checkType == "PlayerMoveVoice" then
    if slua.isValid(SubObject.nowplayer) then
      bIsSame = SubObject.nowplayer == ShowObj.nowPlayer
    end
  elseif SubObject.checkType == "VehicleMoveVoice" then
    if slua.isValid(SubObject.vehicle) then
      bIsSame = SubObject.vehicle == ShowObj.Vehicle
    end
  elseif slua.isValid(SubObject.noweapon) then
    bIsSame = SubObject.noweapon == ShowObj.Weapon
  end
  return bIsSame
end
function NavigatorPanel:ShowTrigerVoiceIcom(NowObj)
  local UIObj = self:GetMinShowTimeObject(NowObj)
  self:SetOneData(UIObj, NowObj)
  self:RemoveSameActorShow(UIObj)
  if not TableUtil.IsInTable(self.VoiceShowList, UIObj) then
    table.insert(self.VoiceShowList, UIObj)
  end
  self:SetVoiceChekImageZorder()
end
function NavigatorPanel:SetOneData(UIObj, SubObj)
  if not slua.isValid(UIObj) or not slua.isValid(SubObj) then
    return
  end
  UIObj.MaxCheckLength = SubObj.MaxCheckLength
  UIObj.MaxScale = SubObj.maxShowScale
  UIObj.minScale = SubObj.minShowScale
  UIObj.ShowTimeLeave = SubObj.ShowCD
  UIObj.worldPos = SubObj.worldPos
  UIObj:UpdateState(0.0)
  UIObj.middleImage:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  if SubObj.checkType == "PlayerMoveVoice" then
    UIObj.nowPlayer = SubObj.nowplayer
  elseif SubObj.checkType == "VehicleMoveVoice" then
    UIObj.Vehicle = SubObj.vehicle
  else
    UIObj.Weapon = SubObj.noweapon
  end
end
function NavigatorPanel:SetVoiceChekImageZorder(...)
  local NowZoder = 0
  local Length = self.VoiceShowList.Num
  local NowUIObj, NextUIObj
  for i = 1, Length - 1 do
    for j = 1, Length - i do
      local NowUIObj = self.VoiceShowList[j]
      local NextUIObj = self.VoiceShowList[j + 1]
      if NextUIObj and NowUIObj and NextUIObj.ShowTimeLeave < NowUIObj.ShowTimeLeave then
        self.VoiceShowList[j] = NextUIObj
        self.VoiceShowList[j + 1] = NowUIObj
      end
    end
  end
  for key, ShowObj in pairs(self.VoiceShowList) do
    if ShowObj and ShowObj.ShowTimeLeave > 0.0 then
      ShowObj.nowZorder = NowZoder
      NowZoder = NowZoder + 1
    end
  end
end
function NavigatorPanel:InitCompassWidget()
  local asset_util = require("common.asset_util")
  local KismetMaterialLibrary = import("KismetMaterialLibrary")
  local UIUtil = require("client.common.ui_util")
  local material = asset_util.GetAssetSync("/Game/Arts/UI/BattleInfo/CompassMaterial.CompassMaterial")
  if not material then
    log(bWriteLog and bwritelog("NavigatorPanel:InitCompassWidget", "material is nil"))
    return
  end
  local CurMatIns = KismetMaterialLibrary.CreateDynamicMaterialInstance(UIUtil.GetGameInstance(), material)
  if not slua.isValid(CurMatIns) then
    log(bWriteLog and bwritelog("NavigatorPanel:InitCompassWidget", "CurMatIns is nil"))
    return
  end
  self.UIRoot:SetCompassMat(CurMatIns)
  self.UIRoot.CompassImage:SetBrushFromMaterial(CurMatIns)
end
function NavigatorPanel:UpdateDirection()
  self.CompassMat:SetScalarParameterValue("X", 0.0)
end
function NavigatorPanel:GetFinalX(MiddlsX, PlayerX, Scale)
  local Show  local NowLeftSize = self.HalfShowSize - ShowScale * self.ImageSize * 0.5
  local AbsOffset = math.abs(MiddlsX - PlayerX)
  local FinalOffset = 0.0
  if AbsOffset >= self.HalfShowSize then
    FinalOffset = self.HalfFullSize * 2 - AbsOffset
  else
    FinalOffset = AbsOffset
  end
  local Now  local Now  if NowMiddlsX == NowPlayerX then
    return 0.0
  end
  local ZhengFu = 1
  if NowMiddlsX > NowPlayerX and AbsOffset <= self.HalfFullSize or NowMiddlsX < NowPlayerX and AbsOffset > self.HalfFullSize then
    ZhengFu = -1
  end
  if NowLeftSize < FinalOffset then
    return NowLeftSize * ZhengFu
  else
    return FinalOffset * ZhengFu
  end
end
function NavigatorPanel:RemoveSameActorShow(UIObj)
  for key, ShowObj in pairs(self.VoiceShowList) do
    if ShowObj then
      local Player = ShowObj:GetNowOwnPlayer()
      if slua.isValid(Player) and Player == UIObj:GetNowOwnPlayer() and ShowObj ~= UIObj then
        ShowObj.ShowTimeLeave = 0.0
        ShowObj.middleImage:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
        TableUtil.Remove(self.VoiceShowList, ShowObj)
        return
      end
    end
  end
end
function NavigatorPanel:TestPlayerController()
end
function NavigatorPanel:HideAllMarks()
  for i = 0, self.UIRoot.TeamPlayerMarkerArray_Cpp:Num() - 1 do
    local PlayerMarker = self.UIRoot.TeamPlayerMarkerArray_Cpp:Get(i)
    if slua.isValid(PlayerMarker) then
      PlayerMarker:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function NavigatorPanel:SetSpecialBigTipsText(Rotation)
  local TextBolck = self.UIRoot.TextBlock_Bigtips
  if Rotation % 360 == 0 then
    TextBolck:SetText("N")
    TextBolck:SetColorAndOpacity(FLinearColor(0.988235, 0.764706, 0.372549, 1.0))
  else
    local Text = ""
    if Rotation < 45 then
      Text = "N"
    elseif Rotation < 90 then
      Text = "NE"
    elseif Rotation < 135 then
      Text = "E"
    elseif Rotation < 180 then
      Text = "SE"
    elseif Rotation < 225 then
      Text = "S"
    elseif Rotation < 270 then
      Text = "SW"
    elseif Rotation < 315 then
      Text = "W"
    else
      Text = "NW"
    end
    TextBolck:SetText(Text)
    TextBolck:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
  local font = TextBolck.Font
  font.Size = 20
  font.IsBold = false
  TextBolck:SetFont(font)
end
function NavigatorPanel:AddOnePlayer(Index)
  local luaArrIndex = Index + 1
  log(bWriteLog and "NavigatorPanel:AddOnePlayer with index: " .. luaArrIndex)
  if not self.PlayerIconTable[luaArrIndex] then
    if not self.MarkItemPool or not slua.isValid(self.MarkItemPool) then
      return
    end
    local item = self.MarkItemPool:GetOneItem()
    if slua.isValid(item) then
      item:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.PlayerIconTable[luaArrIndex] = item
      item:GetIconDisplayWidget()
      self:luaSetArrayElem(self.UIRoot.TeamPlayerMarkerArray_Cpp, Index, item)
      local DistWidget = item:GetMarkDistWidget()
      self:luaSetArrayElem(self.UIRoot.TeamPlayerMarkDistArray_Cpp, Index, DistWidget)
      local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
      local Color = TeamPanelConfig.TeamPlayerColorTable[luaArrIndex]
      Color = Color or FLinearColor(1, 1, 1, 1)
      item:SetMarkColor(Color)
    end
  end
  if not self.UIRoot.CanvasPanel_Navigator:HasChild(self.PlayerIconTable[luaArrIndex]) then
    local IconSlot = self.UIRoot.CanvasPanel_Navigator:AddChild(self.PlayerIconTable[luaArrIndex])
    if not IconSlot then
      return
    end
    IconSlot:SetAnchors(FAnchors(0.5, 0.0, 0.5, 0.0))
    IconSlot:SetSize(FVector2D(68.0, 21.0))
    local PS = GameplayData.GetPlayerState()
    if not slua.isValid(PS) then
      return
    end
    if PS.PlayerId == Index then
      IconSlot:SetZOrder(1)
    else
      IconSlot:SetZOrder(0 - Index)
    end
  end
end
function NavigatorPanel:IsInfectMode()
  local GameState = GameplayData.GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) then
    return GameState.GameModeType == EGameModeType.EPVEInfectionGameMode
  end
  return false
end
function NavigatorPanel:OnReconnectResetUIByPlayerControllerStateDelegate()
  local PC = GameplayData.GetPlayerController()
  if slua.isValid(PC) then
    self.PlayerController = PC
  end
  self.VoiceCheck = nil
end
function NavigatorPanel:OnRepPlayerState()
  if self:IsInfectMode() then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local PlayerNumPerTeam = uGameState.PlayerNumPerTeam or 0
  if PlayerNumPerTeam == 1 then
    self:AddOnePlayer(0)
    return
  end
  local uTeamMatePlayerStateList = self:GetTeamPSListAndCurPlayerID()
  if not uTeamMatePlayerStateList then
    return
  end
  for key, uTeammatePlayerState in pairs(uTeamMatePlayerStateList) do
    if slua.isValid(uTeammatePlayerState) then
      self:AddOnePlayer(key)
    end
  end
  self.UIRoot:OnMapMarkChange_NoParam()
end
function NavigatorPanel:OnFadeOutAnimationFinished()
  self.UIRoot.Border_0:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 0.6))
  self.UIRoot.CanvasPanel_SafeArea:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function NavigatorPanel:BindTeamMapMarkDelegate()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnMapMarkChangeDelegate", self.RepositionMapMark, self)
end
function NavigatorPanel:RepositionMapMark(Index)
  log(bWriteLog and "NavigatorPanel:RepositionMapMark with index: " .. Index)
end
function NavigatorPanel:OnUpdateMinimapStand()
  log(bWriteLog and "NavigatorPanel:OnUpdateMinimapStand")
  self.UIRoot:GetLevelLandscapeExtent(true)
  self.UIRoot:GetLevelLandscapeCenter(true)
end
function NavigatorPanel:OnPlayerEnterSafeZone()
  self.UIRoot.CanvasPanel_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.bShowFadeOutAnim then
    self:AddGameTimer(2, false, function()
      self:StopAnimation("StopAnimation")
      self:StopAnimation("Anim_FadeOut")
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_FadeOut, 0, 1, 0, 1)
    end)
  else
    self.UIRoot.CanvasPanel_SafeArea:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function NavigatorPanel:GetLandscapeRotation()
  local BP_MiniMapStandardPoint = import("/Game/BluePrints/Core/BP_MiniMapStandardPoint.BP_MiniMapStandardPoint_C")
  local uActorClass = import("/Script/Engine.Actor")
  local OutActors = slua.Array(UEnums.EPropertyClass.Object, uActorClass)
  OutActors = GameplayStatics.GetAllActorsOfClass(self.UIRoot, BP_MiniMapStandardPoint, OutActors)
  if OutActors:Num() > 0 then
    local OutActor = OutActors:Get(0)
    if slua.isValid(OutActor) then
      self.UIRoot.LandscapeRotation = OutActor:K2_GetActorRotation().Yaw
    end
  end
end
function NavigatorPanel:GetTeamPSListAndCurPlayerID()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return nil, nil
  end
  if uPlayerState.GetTeamMatePlayerStateList then
    self.TeamMatePSList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  end
  if uPlayerState.PlayerId and self.CurPlayerID ~= uPlayerState.PlayerId then
    self.CurPlayerID = uPlayerState.PlayerId
  end
  return self.TeamMatePSList, self.CurPlayerID
end
function NavigatorPanel:luaSetArrayElem(Array, Index, Value)
  if not slua.isValid(Array) or Index < 0 then
    return
  end
  if Index >= Array:Num() then
    local extendLength = Index - Array:Num() + 1
    for i = 1, extendLength do
      Array:Add(nil)
    end
  end
  Array:Set(Index, Value)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, NavigatorPanel)