local MiniTvSystem = require("client.slua.logic.mini_tv.logic_mini_tv")
local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
local time_ticker = require("common.time_ticker")
local GameplayStatics = import("GameplayStatics")
local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
local MiniTV_Actor_Limit_Area_Tools = require("client.lobby_ue_object.Actor.MiniTV.MiniTV_Actor_Limit_Area_Tools")
local LoadingSystem = require("client.slua.logic.loading.logic_loading")
local StateMachineModule = require("client.lobby_ue_object.Actor.MiniTV.MiniTVStateMachine")
local StatesModule = require("client.lobby_ue_object.Actor.MiniTV.MiniTVStates")
local StateMachine = StateMachineModule.StateMachine
local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
local StateNames = MiniTVConst.StateNames
local States = StatesModule.States
local C_FaceEmotionMatSlotName = "Color2"
local C_FaceEmotionMatVariableName = "EmojiShift_Index"
local actorData = {
  NLocationX = MiniTVConst.INIT_LOCATION_X,
  NLocationY = MiniTVConst.INIT_LOCATION_Y,
  NLocationZ = MiniTVConst.INIT_LOCATION_Z,
  NDistance = 0,
  OverlapTag = nil
}
local ENUM_ANIMTYPE = MiniTVConst.ENUM_ANIMTYPE
local MiniTVActor = {}
function MiniTVActor:ctor()
  self.stateMachine = StateMachine:new()
  self.  self.nSplineDistance = 0
  self.moveTime = 0
  self.nSpeed = 0
  self.spline = nil
  self.nDistance = actorData.NDistance
  self.locationX = MiniTVConst.INIT_LOCATION_X
  self.locationY = MiniTVConst.INIT_LOCATION_Y
  self.locationZ = MiniTVConst.INIT_LOCATION_Z
  self.rotationYaw = MiniTVConst.INIT_ROTATION_Y
  self.rotationZ = 0
  self.animTime = 0
  self.isHigh = false
  self.hasPlayPhoneAnim = false
  self.isOverlaping = false
  self.overlapTag = nil
  self.clickTime = nil
  self.oneClickTimer = nil
  self.fingerIndex = nil
  self.isPressed = false
  self.touchStartX = 0
  self.touchStartY = 0
  self.lastX = 0
  self.lastY = 0
  self.isRotated = false
  self.isDragged = false
  self.isQuickRotate = false
  self.normalTimer = nil
  self.waitTimer = nil
  self.highDropTimer = nil
  self.lowDropTimer = nil
  self.playerCtr = nil
  self.bHidden = false
  self.ClothId = nil
  self.isNewComplete = false
end
function MiniTVActor:Init()
  printf("MiniTVActor:Init - Initialize actor and state machine")
  self.stateMachine:Init(self)
  for k, v in pairs(StateNames) do
    self.stateMachine:RegisterState(v, States[v])
  end
  self.nSplineDistance = 0
  self.nSpeed = 0
  self.moveTime = 0
  self.isHigh = false
  self.isOverlaping = false
  self.hasPlayPhoneAnim = false
  self.animTime = 0
  self.overlapTag = nil
  self.isNewComplete = growthprojectMgrB.IsFinishAllNewGuide()
  local savedData = MiniTvSystem.GetActorData()
  self.locationX = savedData.NLocationX
  self.locationY = savedData.NLocationY
  self.locationZ = 0
  self.nDistance = savedData.NDistance
  self.overlapTag = savedData.OverlapTag
  self.spline = self:GetSplineByTags("lobby_minitv_spline_1")
  if self.spline then
    self.nSplineDistance = self.spline:GetSplineLength()
  end
end
function MiniTVActor:ReceiveBeginPlay()
  printf("MiniTVActor:ReceiveBeginPlay - Begin play")
  MiniTVActor.__super.ReceiveBeginPlay(self)
  self:Init()
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.DeactivatDropFixed, self)
  self:AddCommonEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_RECV_ACTION, self.OnRecvAction, self)
  self.isPressed = false
  self.locationZ = MiniTVConst.INIT_LOCATION_Z
  self.rotationYaw = 0
  self:OnWidgetHide()
  self:ChangeState(StateNames.Normal)
end
function MiniTVActor:ReceiveEndPlay()
  printf("MiniTVActor:ReceiveEndPlay - End play and cleanup")
  if self.stateMachine then
    self.stateMachine:Destroy()
  end
  MiniTVActor.__super.ReceiveEndPlay(self)
end
function MiniTVActor:ReceiveTick(delta)
  if not self:HaveValidSkeletalMesh() then
    return
  end
  self.stateMachine:Update(delta)
  self:updateClickTimer(delta)
  self:handleDragAndRotate()
end
function MiniTVActor:DeactivatDropFixed()
  if self.isDragged then
    self:DropEvent()
  end
end
function MiniTVActor:OnNoticeLevelChanged(level, msg)
  log(bWriteLog and "MiniTVActor:OnNoticeLevelChanged - level: " .. level .. " msg: " .. tostring(msg))
  if level == 2 then
    local TipsManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.TipsManager)
    local TipsMacro = require("client.slua.logic.tip.TipsMacro")
    TipsManager:PushTip({
      tipId = TipsMacro.ENUM_TipID.MiniTv,
      word = msg
    })
  end
end
function MiniTVActor:OnWidgetHide()
  self:AddTimerOnce(1, function()
    if MiniTvSystem.NeedShowWin() then
      log(bWriteLog and "MiniTVActor: NeedShowWin")
      if UIManager.IsAndroidStackEmpty() and not LoadingSystem.IsShowing() then
        log(bWriteLog and "MiniTVActor: ShowWin")
        self:PlayWin()
        return true
      else
        local UILIst = UIManager.GetTopUINameList(3)
        log_tree("ShowWin UILIst", UILIst)
      end
    end
  end)
end
function MiniTVActor:ChangeState(stateName, args)
  if self.stateMachine:ChangeState(stateName, args) and self:IsCurrentNormalOrWaiting() then
    self.isNewComplete = growthprojectMgrB.IsFinishAllNewGuide()
    if self:OnWidgetHide() then
      log(bWriteLog and "MiniTVActor:ChangeState - Win chicken interrupted")
      return
    end
  end
end
function MiniTVActor:GetCurrentState()
  return self.stateMachine:GetCurrentStateName()
end
function MiniTVActor:IsCurrentNormalOrWaiting()
  local currentState = self:GetCurrentState()
  return currentState == StateNames.Normal or currentState == StateNames.Wait
end
function MiniTVActor:IsCurrentFixLocation()
  local currentState = self:GetCurrentState()
  return currentState == StateNames.FixLocation
end
function MiniTVActor:validateTouchInput(eventName)
  if self.frameCount == time_ticker.GFrameCount then
    return false
  end
  self.frameCount = time_ticker.GFrameCount
  if not self:ensurePlayerController() then
    log(bWriteLog and string.format("MiniTVActor:%s ignore by player controller not valid", eventName))
    return false
  end
  if not self:HaveValidSkeletalMesh() then
    log(bWriteLog and string.format("MiniTVActor:%s ignore by invalid skeletal mesh", eventName))
    return false
  end
  self.isNewComplete = growthprojectMgrB.IsFinishAllNewGuide()
  if not self.isNewComplete then
    log(bWriteLog and string.format("MiniTVActor:%s ignore by new guide not finished", eventName))
    return false
  end
  return true
end
function MiniTVActor:TouchStart(fingerIndex)
  if not self:validateTouchInput("TouchStart") then
    return
  end
  if self:IsHidden() then
    printf("MiniTVActor:TouchStart - ignore by hidden")
    return
  end
  local x, y, _ = self.playerCtr:GetInputTouchState(fingerIndex, nil, nil, nil)
  self.touchStartX = x
  self.touchStartY = y
  self.lastX = x
  self.lastY = y
  self.touchStartTime = slua.getMiliseconds()
  self.touchStartFingerIndex = fingerIndex
  self.isPressed = true
  printf("MiniTVActor:TouchStart x:%s, y:%s, fingerIndex:%s, time:%s", x, y, fingerIndex, self.touchStartTime)
end
function MiniTVActor:TouchEnd(fingerIndex)
  if not self:validateTouchInput("TouchEnd") then
    return
  end
  if self:IsHidden() then
    printf("MiniTVActor:TouchEnd - ignore by hidden")
    return
  end
  printf("MiniTVActor:TouchEnd - isDragged: %s, isRotated: %s", tostring(self.isDragged), tostring(self.isRotated))
  if self:handleDragEnd() then
    return
  end
  if self:handleRotateEnd() then
    return
  end
  self:handleClickEvent()
end
function MiniTVActor:handleDragEnd()
  if self.isDragged then
    self.isDragged = nil
    self:DropEvent()
    return true
  end
  return false
end
function MiniTVActor:handleRotateEnd()
  if self.isRotated then
    self:EndRotate()
    self.isRotated = nil
    return true
  end
  return false
end
function MiniTVActor:handleClickEvent()
  if not UIManager.IsAndroidStackEmpty() then
    printf("[WARN] MiniTVActor:handleClickEvent - Click failed, top UI: %s", UIManager.GetTopUIName())
    return
  end
  log(bWriteLog and "MiniTVActor:handleClickEvent - clickTime: " .. tostring(self.clickTime))
  if not self.clickTime then
    self:scheduleOneClickEvent()
  elseif self.clickTime < MiniTVConst.MIN_DOUBLE_CLICK_TIME and self.clickTime > 0 then
    self.clickTime = nil
    self:DoubleClick()
  end
end
function MiniTVActor:scheduleOneClickEvent()
  self.clickTime = 0
  self:RemoveOneClickTimer()
  self.oneClickTimer = self:AddTimerOnce(MiniTVConst.CLICK_DELAY, function()
    self:OneClicked()
  end)
end
function MiniTVActor:updateClickTimer(delta)
  if self.clickTime then
    self.clickTime = self.clickTime + delta
    if self.clickTime > MiniTVConst.MAX_CLICK_TIME then
      self.clickTime = nil
    end
  end
end
function MiniTVActor:RemoveOneClickTimer()
  self:releaseTimer(self.oneClickTimer)
  self.oneClickTimer = nil
end
function MiniTVActor:ensurePlayerController()
  if slua.isValid(self.playerCtr) then
    return true
  end
  self.playerCtr = GameplayStatics.GetPlayerController(self.Object, 0)
  if not slua.isValid(self.playerCtr) then
    printf("MiniTVActor:ensurePlayerController - PlayerCtr is nil")
    return false
  end
  printf("MiniTVActor:ensurePlayerController - PlayerCtr rebind")
  return true
end
function MiniTVActor:OneClicked()
  local currentState = self:GetCurrentState()
  printf("MiniTVActor:OneClicked - Current state: %s", currentState)
  if not self:IsCurrentNormalOrWaiting() then
    return
  end
  if self.animTime > 0 then
    self:StopMontageAnim()
  end
  if not self.clickTime then
    return
  end
  self.clickTime = nil
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click)
  MiniTvSystem.OneClicked()
end
function MiniTVActor:DoubleClick()
  local currentState = self:GetCurrentState()
  printf("MiniTVActor:DoubleClick - Current state: %s", currentState)
  self:RemoveOneClickTimer()
  local xrandom = require("client.common.uibase.xrandom")
  local randIndex = xrandom.Random2(0, 2)
  if randIndex == 0 then
    self:ChangeState(StateNames.PlayAnim, {
      animType = MiniTVConst.ENUM_ANIMTYPE.DOUBLE1
    })
  else
    self:ChangeState(StateNames.PlayAnim, {
      animType = MiniTVConst.ENUM_ANIMTYPE.DOUBLE2
    })
  end
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Mini_DoubleClick)
end
function MiniTVActor:handleDragAndRotate()
  if not self.isPressed then
    return
  end
  if not self:ensurePlayerController() then
    log(bWriteLog and "MiniTVActor:handleDragAndRotate - PlayerCtr is nil")
    return
  end
  local x, y, isCurrentlyPressed = self.playerCtr:GetInputTouchState(self.touchStartFingerIndex, nil, nil, nil)
  self.isPressed = isCurrentlyPressed
  if not isCurrentlyPressed then
    self:TouchEnd(self.touchStartFingerIndex)
    return
  end
  local diffX, diffY = x - self.lastX, y - self.lastY
  if diffX == 0 and diffY == 0 then
    return
  end
  lobbyMainLogic.OnPlayerRotate()
  self.lastX = x
  self.lastY = y
  if self.isRotated then
    self:handleRotate(diffX, diffY)
  elseif self.isDragged then
    self:handleDrag(diffX, diffY, x, y)
  else
    self:detectDragOrRotate(diffX, diffY, x, y)
  end
end
function MiniTVActor:detectDragOrRotate(diffX, diffY, x, y)
  if not self:IsCurrentNormalOrWaiting() and not self:IsCurrentFixLocation() then
    printf("MiniTVActor:detectDragOrRotate - Current state is not Normal or Waiting or FixLocation")
    return
  end
  local absDiffX = math.abs(diffX)
  local absDiffY = math.abs(diffY)
  if absDiffX > absDiffY and absDiffX > MiniTVConst.ROTATION_RULE_THRESHOLD then
    if self:IsCurrentFixLocation() then
      printf("MiniTVActor:detectDragOrRotate - Current state is FixLocation, ignore rotate")
      return
    end
    self:startRotate(diffX, diffY)
  elseif absDiffX <= absDiffY and diffY < -2 then
    self:startDrag(diffX, diffY, x, y)
  end
end
function MiniTVActor:startRotate(diffX, diffY)
  self.isRotated = true
  self:StopMove()
  self:handleRotate(diffX, diffY)
end
function MiniTVActor:startDrag(diffX, diffY, x, y)
  printf("MiniTVActor:startDrag")
  self.isDragged = true
  self:StopMove()
  self:ChangeState(StateNames.Drag)
  local SAUtils = require("client.slua.logic.sa.SAUtils")
  SAUtils.CloseMiniTVBubbleUI()
  self:handleDrag(diffX, diffY, x, y)
end
function MiniTVActor:handleRotate(diffX, diffY)
  self.rotationYaw = self.rotationYaw - diffX
  self:K2_SetActorRotation(FRotator(0, self.rotationYaw, self.rotationZ), false)
  self.isQuickRotate = math.abs(diffX) > MiniTVConst.QUICK_ROTATE_THRESHOLD
end
function MiniTVActor:RotateModel(diffX, diffY)
  if not self:HaveValidSkeletalMesh() then
    return
  end
  self.rotationYaw = self.rotationYaw - diffX
  self:K2_SetActorRotation(FRotator(0, self.rotationYaw, self.rotationZ), false)
end
function MiniTVActor:handleDrag(diffX, diffY, x, y)
  self.locationZ = self:clampLocationZ(self.locationZ - diffY * 0.2)
  self:K2_SetActorLocation(FVector(self.locationX, self.locationY, self.locationZ), false, nil, false)
  self:SetDropHigh(self.locationZ > MiniTVConst.HIGH_DRAG_THRESHOLD)
end
function MiniTVActor:clampLocationZ(z)
  if z > MiniTVConst.MAX_DRAG_HEIGHT then
    return MiniTVConst.MAX_DRAG_HEIGHT
  elseif z < MiniTVConst.INIT_LOCATION_Z then
    return MiniTVConst.INIT_LOCATION_Z
  end
  return z
end
function MiniTVActor:EndRotate()
  if self.isQuickRotate then
    self.isQuickRotate = nil
    local currentState = self:GetCurrentState()
    if self:IsCurrentNormalOrWaiting() then
      self:ChangeState(StateNames.PlayAnim, {
        animType = MiniTVConst.ENUM_ANIMTYPE.ROTATE
      })
    end
  else
    self:StopMontageAnim()
  end
end
function MiniTVActor:DropEvent()
  if self:GetCurrentState() ~= StateNames.Drag then
    printf("MiniTVActor:DropEvent - Current state is not Drag")
    return
  end
  self:TryFloatOrDrop()
  self.isRotated = nil
  self.isDragged = nil
  self.clickTime = nil
  local timer_tick = require("common.time_ticker")
  timer_tick.AddTimer(MiniTVConst.FloatTime, function()
    MiniTV_Actor_Limit_Area_Tools.UpdateGlowWidget(nil, -1)
  end)
  log(bWriteLog and "MiniTVActor:DropEvent - Drop event")
end
function MiniTVActor:SetDropHigh(isHigh)
  self.  if not self:HaveValidAnimInstance() then
    return
  end
  if isHigh then
    self.SkeletalMesh:GetAnimInstance():SetDragType(1)
  else
    self.SkeletalMesh:GetAnimInstance():SetDragType(0)
  end
end
function MiniTVActor:ReceiveActorBeginOverlap(OtherActor)
  log(bWriteLog and "MiniTVActor:ReceiveActorBeginOverlap - Overlap with: " .. tostring(OtherActor.EventName))
  local currentState = self:GetCurrentState()
  if currentState == StateNames.Drag or currentState == StateNames.Drop then
    printf("MiniTVActor:ReceiveActorBeginOverlap ignore not allowed state: %s", currentState)
    return
  end
  if not self:shouldProcessOverlap(OtherActor) then
    return
  end
  self.isOverlaping = true
  self.overlapTag = OtherActor.EventName
  self:handleOverlapByTag(self.overlapTag)
end
function MiniTVActor:shouldProcessOverlap(OtherActor)
  if self.isOverlaping then
    return false
  end
  if self.overlapTag ~= "Player" and self.overlapTag ~= "Partner" and self.overlapTag == OtherActor.EventName then
    return false
  end
  return true
end
function MiniTVActor:handleOverlapByTag(tag)
  local handlers = {
    Player = function()
      self:KeepMove()
    end,
    PlayerBehind = function()
      self:KeepMove()
    end,
    Car = function()
      self:PlayCarAnimEvent()
    end,
    Partner = function()
      self:KeepMoveOnPet()
    end,
    Edge = function()
      self:PlayEdgeAnimEvent()
    end,
    AirDrop = function()
      self:PlayAirDropAnimEvent()
    end
  }
  local handler = handlers[tag]
  if handler then
    handler()
  end
end
function MiniTVActor:ReceiveActorEndOverlap(OtherActor)
  self.isOverlaping = false
  if self.overlapTag == "Partner" then
    self:enablePetRotation()
  end
end
function MiniTVActor:enablePetRotation()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local pet = TeamAvatarManager.GetPet()
  if pet then
    pet:EnableRotation(true)
  end
end
function MiniTVActor:PlayCarAnimEvent()
  if math.random() < MiniTVConst.CAR_ANIM_PROBABILITY then
    log(bWriteLog and "MiniTVActor:PlayCarAnimEvent - Play car animation")
    self:ChangeState(StateNames.PlayAnim, {
      bCarAnim = true,
      animType = MiniTVConst.ENUM_ANIMTYPE.NORMALCAR
    })
  end
end
function MiniTVActor:KeepMoveOnPet()
  log(bWriteLog and "MiniTVActor:KeepMoveOnPet - Current state: " .. tostring(self:GetCurrentState()))
  local currentState = self:GetCurrentState()
  if currentState == StateNames.Walk then
    local MiniTVUtils = require("client.lobby_ue_object.Actor.MiniTV.MiniTVUtils")
    if MiniTVUtils.EquipedLandPet() and self.moveTime < MiniTVConst.PET_WALK_TIME then
      log(bWriteLog and "MiniTVActor:KeepMoveOnPet - Extend move time to: " .. tostring(MiniTVConst.PET_WALK_TIME))
      self.moveTime = MiniTVConst.PET_WALK_TIME
    end
  elseif currentState == StateNames.Normal then
    self:ChangeState(StateNames.Walk)
  end
end
function MiniTVActor:PlayEdgeAnimEvent()
  log(bWriteLog and "MiniTVActor:PlayEdgeAnimEvent - Play edge animation while moving")
  self:PlayMontageAnim(MiniTVConst.ENUM_ANIMTYPE.EDGE)
  self:ChangeState(StateNames.Walk)
  self.moveTime = self.moveTime + MiniTVConst.EDGE_MOVE_TIME_ADD
end
function MiniTVActor:PlaySelfishAnim()
  self.hasPlayPhoneAnim = true
  self:PlayPhoneAnim()
end
function MiniTVActor:PlayAirDropAnimEvent()
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  local AriDropTime = LuckAirDropSystem.GetLeftTime()
  if AriDropTime < 1 then
    log(bWriteLog and "MiniTVActor:PlayAirDropAnimEvent - AriDropTime < 1: " .. tostring(AriDropTime))
    return
  end
  local AirDropActors = FuncUtil.GetAllActorsByTag("Actor", "LobbyLuckyAirDrop")
  if AirDropActors and 1 <= AirDropActors:Num() then
    log(bWriteLog and "MiniTVActor:PlayAirDropAnimEvent - Play airdrop animation")
    self:ChangeState(StateNames.PlayAnim, {
      animType = MiniTVConst.ENUM_ANIMTYPE.AIRDROP
    })
  end
end
function MiniTVActor:PlayWin()
  log(bWriteLog and "MiniTVActor:PlayWin - Play win animation")
  self:ChangeState(StateNames.PlayAnim, {
    animType = MiniTVConst.ENUM_ANIMTYPE.Win
  })
end
function MiniTVActor:KeepMove()
  local currentState = self:GetCurrentState()
  printf("MiniTVActor:KeepMove - Current state: %s", currentState)
  if currentState == StateNames.Walk then
    self.moveTime = self.moveTime + MiniTVConst.WALK_MOVE_TIME_ADD_FRONT_CHAR
  elseif self:IsCurrentNormalOrWaiting() then
    self:ChangeState(StateNames.Walk)
  end
end
function MiniTVActor:StopMove()
  local currentState = self:GetCurrentState()
  if currentState == StateNames.Walk or currentState == StateNames.Wait then
    self:ChangeState(StateNames.Normal)
  end
  self.moveTime = 0
  self:K2_SetActorRotation(FRotator(0, 0, 0), false)
  self:SetSpeed(0)
end
function MiniTVActor:FGetSplineDistance(nDistance, nDelta)
  if nDistance == nil then
    return 0
  end
  nDistance = nDistance + nDelta * self.nSpeed
  return nDistance % self.nSplineDistance
end
function MiniTVActor:SetSpeed(speed)
  if not self:HaveValidAnimInstance() then
    return
  end
  if 70 < speed then
    self.nSpeed = speed * 1.2
  else
    self.nSpeed = speed * 1.65
  end
  self.SkeletalMesh:GetAnimInstance():SetSpeed(speed)
end
function MiniTVActor:TickMove(delta)
  if not self.spline then
    self:Init()
    return
  end
  if self.moveTime <= 0 then
    self.moveTime = 0
    return
  end
  self.moveTime = self.moveTime - delta
  local nDistance = self.nDistance
  local nDelta = delta
  self.nDistance = self:FGetSplineDistance(nDistance, nDelta)
  local ESplineCoordinateSpace = import("ESplineCoordinateSpace")
  local transform = self.spline:GetTransformAtDistanceAlongSpline(self.nDistance, ESplineCoordinateSpace.World, false)
  local rotator = transform:Rotator()
  local location = transform:GetLocation()
  self.locationX, self.locationY, self.locationZ = location.X, location.Y, location.Z
  self:K2_SetActorRotation(FRotator(rotator.Pitch, rotator.Yaw - 90, rotator.Roll), false)
  self:K2_SetActorLocation(location, false, nil, false)
end
function MiniTVActor:RandomEvent()
  if UIManager.IsUIShow(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP) then
    return false
  end
  if self.isPressed then
    return false
  end
  self:ChangeState(StateNames.Walk)
  return true
end
function MiniTVActor:GetSplineByTags(tag)
  local splineActor
  local bgActors1 = FuncUtil.GetAllActorsByTag("Actor", tag)
  if bgActors1 and bgActors1:Num() >= 1 then
    splineActor = bgActors1:Get(0)
  end
  local spline
  if splineActor then
    spline = splineActor.spline
  end
  return spline
end
function MiniTVActor:PlayMontageAnim(AnimType)
  local path = MiniTVConst.MONTAGE_PATH[AnimType]
  if not path then
    printf("[WARN] MiniTVActor:PlayMontageAnim - path is nil. AnimType: %s", AnimType)
    return false
  end
  return self:PlayMontageAnimByPath(path)
end
function MiniTVActor:PlayMontageAnimByPath(MontagePath, bImmediatePlay)
  log(bWriteLog and "MiniTVActor:PlayMontageAnimByPath - MontagePath: " .. tostring(MontagePath))
  if not self:HaveValidAnimInstance() then
    printf("MiniTVActor:PlayMontageAnimByPath - animInstance is not valid")
    return false
  end
  local asset = self:GetAnimAssetByPath(MontagePath)
  if asset == nil then
    printf("MiniTVActor:PlayMontageAnimByPath - asset is nil")
    return false
  end
  if nil == bImmediatePlay then
    bImmediatePlay = true
  end
  self:StopMontageAnim()
  if bImmediatePlay then
    local animInstance = self.SkeletalMesh:GetAnimInstance()
    local EMontagePlayReturnType = import("EMontagePlayReturnType")
    local playTime = animInstance:Montage_Play(asset, 1, EMontagePlayReturnType.MontageLength, 0)
    self.animTime = playTime
    printf("MiniTVActor:PlayMontageAnimByPath - animTime: %s", tostring(self.animTime))
    return true, playTime
  else
    self:AddTimerOnce(0, function()
      local animInstance = self.SkeletalMesh:GetAnimInstance()
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      local playTime = animInstance:Montage_Play(asset, 1, EMontagePlayReturnType.MontageLength, 0)
      self.animTime = playTime
      printf("MiniTVActor:PlayMontageAnimByPath - animTime: %s", tostring(self.animTime))
    end)
    return true
  end
end
function MiniTVActor:GetFaceEmotionMat()
  local index = self.SkeletalMesh:GetMaterialIndex(C_FaceEmotionMatSlotName)
  if index ~= -1 then
    return self.SkeletalMesh:GetMaterial(index)
  else
    return nil
  end
end
function MiniTVActor:ChangeFaceEmotionMat(emojiIndex)
  print(bWriteLog and "MiniTVActor:ChangeFaceEmotionMat - emojiIndex: " .. tostring(emojiIndex))
  local faceEmotionMat = self:GetFaceEmotionMat()
  if not faceEmotionMat or not slua.isValid(faceEmotionMat) then
    print(bWriteLog and "MiniTVActor:ChangeFaceEmotionMat - faceEmotionMat is nil")
    return
  end
  if faceEmotionMat.SetScalarParameterValue then
    faceEmotionMat:SetScalarParameterValue(C_FaceEmotionMatVariableName, emojiIndex)
  end
end
function MiniTVActor:StopMontageAnim()
  if self.hasPlayPhoneAnim then
    self.hasPlayPhoneAnim = false
    self:DestoryPhoneMesh()
    self.animTime = 0
    return
  end
  if not self:HaveValidAnimInstance() then
    return
  end
  self.SkeletalMesh:GetAnimInstance():Montage_Stop(0.0, nil)
  self.animTime = 0
end
function MiniTVActor:GetAnimAssetByPath(MontagePath)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local softObjPath = UKismetSystemLibrary.MakeSoftObjectPath(MontagePath)
  if softObjPath == nil then
    return nil
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local animAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(softObjPath)
  if animAsset == nil then
    return nil
  end
  return animAsset
end
function MiniTVActor:IsPlayingAnim()
  return self.animTime > 0
end
function MiniTVActor:GetActorNowScreenLocation(SlotType)
  local ScreenLocation = FVector2D(0, 0)
  if not self:HaveValidSkeletalMesh() then
    return ScreenLocation
  end
  SlotType = SlotType or MiniTVConst.ENUM_SLOTTYPE.Head
  local SlotNameMapping = {
    [MiniTVConst.ENUM_SLOTTYPE.Head] = "UISlot",
    [MiniTVConst.ENUM_SLOTTYPE.Left] = "UISlotLeft",
    [MiniTVConst.ENUM_SLOTTYPE.Right] = "UISlotRight"
  }
  local SlotName = SlotNameMapping[SlotType]
  local mesh = self.SkeletalMesh
  local meshSocketLocation = mesh:GetSocketTransform(SlotName, 0):GetLocation()
  if not meshSocketLocation then
    return ScreenLocation
  end
  local playerController = GameplayStatics.GetPlayerController(self.Object, 0)
  if not playerController then
    return ScreenLocation
  end
  local screenPos = FVector2D(0, 0)
  playerController:ProjectWorldLocationToScreen(meshSocketLocation, screenPos, true)
  ScreenLocation = screenPos
  return ScreenLocation
end
function MiniTVActor:LogicShow()
  if self:IsHidden() then
    log_tree("MiniTVActor:LogicShow - Show actor", actorData)
    self:SetActorTickEnabled(true)
    self:K2_SetActorLocation(FVector(actorData.NLocationX, actorData.NLocationY, 0), false, nil, false)
    self:K2_SetActorRotation(FRotator(0, self.rotationYaw, 0), false)
    MiniTvSystem.PutOnClothe()
    self:SetHidden(false)
    self:ClearPhone()
    if self:HaveValidAnimInstance() then
      local animInstance = self.SkeletalMesh:GetAnimInstance()
      if animInstance.SetDrag then
        animInstance:SetDrag(false)
      else
        log_warning(bWriteLog and "MiniTVActor:LogicShow - AnimInstance has no SetDrag method, skip")
      end
      if animInstance.SetFloat then
        animInstance:SetFloat(false)
      else
        log_warning(bWriteLog and "MiniTVActor:LogicShow - AnimInstance has no SetFloat method, skip")
      end
    end
  end
end
function MiniTVActor:LogicHide()
  log(bWriteLog and "MiniTVActor:LogicHide - Hide actor")
  if self:IsMarkedInRT() then
    return
  end
  self:StopMontageAnim()
  MiniTvSystem.SaveActorData()
  self:SetHidden(true)
  self:SetActorTickEnabled(false)
end
function MiniTVActor:SetHidden(bHidden)
  self.  if self.SkeletalMesh then
    self.SkeletalMesh:SetHiddenInGame(bHidden, false)
  end
end
function MiniTVActor:IsHidden()
  return self.bHidden
end
function MiniTVActor:MarkInRT(uiBase)
  if not self.markMap then
    self.markMap = {}
  end
  self.markMap[uiBase] = true
  self:SetHidden(false)
  self:SetActorTickEnabled(true)
end
function MiniTVActor:UnmarkInRT(uiBase)
  if self.markMap and self.markMap[uiBase] then
    self.markMap[uiBase] = nil
  end
end
function MiniTVActor:IsMarkedInRT()
  return self.markMap and next(self.markMap) ~= nil
end
function MiniTVActor:RevertModifyInPreview()
  self:PutOnCloth(DataMgr.minitv_dressid)
  self.rotationYaw = MiniTVConst.INIT_ROTATION_Y
  self:K2_SetActorRotation(FRotator(0, self.rotationYaw, 0), false)
end
function MiniTVActor:PutOnCloth(itemId)
  log(bWriteLog and "MiniTVActor:PutOnCloth - itemId: " .. tostring(itemId))
  if self.ClothId == itemId then
    log(bWriteLog and "MiniTVActor:PutOnCloth - ClothId == itemId, ignore")
    return
  end
  self.ClothId = itemId
  self.MinitvAvatarComponent_BP:RayEquipItemById(itemId)
end
function MiniTVActor:ClearPhone()
  if slua.isValid(self.PhoneMesh) then
    self:DestoryPhoneMesh()
  end
end
function MiniTVActor:GetActorData()
  actorData.NLocationX = self.locationX
  actorData.NLocationY = self.locationY
  actorData.NLocationZ = self.locationZ
  actorData.NDistance = self.nDistance
  actorData.OverlapTag = self.overlapTag
  return actorData
end
function MiniTVActor:HaveValidSkeletalMesh()
  if slua.isValid(self.SkeletalMesh) and slua.isValid(self.SkeletalMesh.SkeletalMesh) then
    return true
  end
  log(bWriteLog and "MiniTVActor:HaveValidSkeletalMesh - SkeletalMesh is not valid")
  return false
end
function MiniTVActor:HaveValidAnimInstance()
  if slua.isValid(self.SkeletalMesh) and slua.isValid(self.SkeletalMesh:GetAnimInstance()) then
    return true
  end
  log(bWriteLog and "MiniTVActor:HaveValidAnimInstance - AnimInstance is not valid")
  return false
end
function MiniTVActor:releaseTimer(timer)
  if timer then
    self:RemoveTimer(timer)
  end
end
function MiniTVActor:TryFloatOrDrop()
  local x, y, isCurrentlyPressed = self.playerCtr:GetInputTouchState(self.touchStartFingerIndex, nil, nil, nil)
  local ret = MiniTV_Actor_Limit_Area_Tools.CheckLimitAreaIndex(x, y)
  if 1 <= ret and ret <= 3 then
    local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
    SmartAssistantHandler.send_report_minitv_raw_event_req(MiniTVConst.RAW_EVENT_TYPE.DRAG_ASSISTANT, {position_type = ret})
    printf("MiniTVActor:TryFloatOrDrop - Float state ret: %d", ret)
    self:ChangeState(StateNames.Float, MiniTVConst.FloatTime)
    return
  end
  printf("MiniTVActor:TryFloatOrDrop - Drop state")
  self:ChangeState(StateNames.Drop)
end
function MiniTVActor:TryEndFloatState()
  if self:GetCurrentState() == StateNames.Float then
    self:ChangeState(StateNames.Drop)
  end
end
function MiniTVActor:OnRecvAction()
  local currentState = self:GetCurrentState()
  if currentState ~= StateNames.Normal and currentState ~= StateNames.Wait and currentState ~= StateNames.Float then
    printf("MiniTVActor:OnRecvAction - ignore by not allowed state: %s", currentState)
    return false
  end
  if self:IsHidden() then
    printf("MiniTVActor:OnRecvAction - ignore by hidden")
    return false
  end
  local SAUtils = require("client.slua.logic.sa.SAUtils")
  if SAUtils.IsShowingMiniTVBubble() then
    printf("MiniTVActor:OnRecvAction - ignore by showing bubble")
    return false
  end
  if not UIManager.IsAndroidStackEmpty() or LoadingSystem.IsShowing() then
    printf("MiniTVActor:OnRecvAction - ignore by loading or android stack not empty")
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local isSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  local isNewbie = NewFaceSlapSystem:CheckIsNewBie()
  local isBlocked = NewFaceSlapSystem:IsCloseFaceSlap()
  if not isBlocked and not isSlapEnd and not isNewbie then
    printf("MiniTVActor:OnRecvAction - ignore by not slap end and not newbie")
    return false
  end
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  local action = LogicSmartAssistant:PopPriorityAction()
  if not action then
    return false
  end
  local ActionCfg = CDataTable.GetTableData("MiniTVActionCfg", action.action_id)
  local dialog = action.dialog
  if dialog then
    local dialog_type = dialog.dialog_type or 0
    local symbolId = dialog.symbol_id or nil
    local text = dialog.text or ""
    local FloatingStyle = ActionCfg and ActionCfg.FloatingStyle or 0
    local uiType = dialog_type
    if FloatingStyle ~= 0 then
      uiType = 2
    end
    local args = {
      type = uiType,
      symbolId = symbolId,
      floatingStyle = FloatingStyle,
      content = text,
      sdAction = action
    }
    printf("MiniTVActor:OnRecvAction - show ui text: %s", text)
    local ui = UIManager.GetUI(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP)
    if not ui then
      UIManager.ShowUI(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP, args)
    else
      ui:UpdateUIArgs(args)
    end
  else
    printf("MiniTVActor:OnRecvAction - dialog is nil, skip UI")
  end
  if ActionCfg and ActionCfg.MontagePath ~= "" and currentState ~= StateNames.Float then
    printf("MiniTVActor:OnRecvAction - play anim: %s", ActionCfg.MontagePath)
    self:ChangeState(StateNames.PlayAnim, {
      animPath = ActionCfg.MontagePath,
      emojiIndex = ActionCfg.EmoteMatID
    })
  end
  return true
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
return class(CActorBase, nil, MiniTVActor)