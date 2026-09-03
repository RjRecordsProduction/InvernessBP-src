local StateMachineModule = require("client.lobby_ue_object.Actor.MiniTV.MiniTVStateMachine")
local StateBase = StateMachineModule.StateBase
local time_ticker = require("common.time_ticker")
local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
local MiniTVUtils = require("client.lobby_ue_object.Actor.MiniTV.MiniTVUtils")
local StateNames = MiniTVConst.StateNames
local MiniTVNormalState = StateBase:new(StateNames.Normal)
function MiniTVNormalState:OnEnter(actor)
  printf("MiniTVNormalState:OnEnter - Enter normal state")
  if not actor.normalTimer then
    actor.normalTimer = actor:AddTimerLoop(0, function()
      local bSuccess = actor:RandomEvent()
      if bSuccess then
      end
    end, 0, MiniTVConst.NORMAL_IDLE_TIME)
  end
end
function MiniTVNormalState:OnExit(actor)
  if actor.normalTimer then
    actor:RemoveTimer(actor.normalTimer)
    actor.normalTimer = nil
  end
end
local MiniTVWalkState = StateBase:new(StateNames.Walk)
function MiniTVWalkState:OnEnter(actor)
  printf("MiniTVWalkState:OnEnter - Enter walk state")
  actor:StopMontageAnim()
  actor:SetSpeed(MiniTVConst.WALK_SPEED)
  local stopRandomTime = math.random(MiniTVConst.WALK_TIME_MIN, MiniTVConst.WALK_TIME_MAX)
  actor.moveTime = stopRandomTime
end
function MiniTVWalkState:OnUpdate(actor, deltaTime)
  if actor.MiniTvSystem.GMNotMove == true then
    actor.moveTime = 0
    actor.stateMachine:ChangeState(StateNames.Normal)
    return
  end
  if actor.moveTime > 0 then
    actor:TickMove(deltaTime)
  else
    actor.stateMachine:ChangeState(StateNames.Wait)
  end
end
local MiniTVWaitState = StateBase:new(StateNames.Wait)
function MiniTVWaitState:OnEnter(actor)
  printf("MiniTVWaitState:OnEnter - Enter wait state")
  actor:SetSpeed(0)
  actor:K2_SetActorRotation(FRotator(0, 0, 0), false)
  if not actor.waitTimer then
    actor.waitTimer = actor:AddTimerLoop(0, function()
      actor:RandomEvent()
    end, 0, MiniTVConst.WAIT_TIME)
  end
end
function MiniTVWaitState:OnExit(actor)
  if actor.waitTimer then
    actor:RemoveTimer(actor.waitTimer)
    actor.waitTimer = nil
  end
end
local MiniTVDragState = StateBase:new(StateNames.Drag)
function MiniTVDragState:OnEnter(actor)
  printf("MiniTVDragState:OnEnter - Enter drag state")
  if actor:HaveValidAnimInstance() then
    actor.SkeletalMesh:GetAnimInstance():SetDrag(true)
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Mini_Drag)
end
function MiniTVDragState:OnUpdate(actor, deltaTime)
  if not actor.isPressed then
    actor:TryFloatOrDrop()
    return
  end
end
function MiniTVDragState:OnExit(actor)
  if actor:HaveValidAnimInstance() then
    actor.SkeletalMesh:GetAnimInstance():SetDrag(false)
  end
end
local MiniTVDropState = StateBase:new(StateNames.Drop)
function MiniTVDropState:OnEnter(actor)
  printf("MiniTVDropState:OnEnter - Enter drop state")
  if actor:HaveValidAnimInstance() then
    actor.SkeletalMesh:GetAnimInstance():SetDrag(false)
    actor.SkeletalMesh:GetAnimInstance():SetFloat(false)
  end
  self.dropSpeed = MiniTVConst.DOWN_SPEED
  self.location = FVector(actor.locationX, actor.locationY, actor.locationZ)
end
function MiniTVDropState:OnUpdate(actor, deltaTime)
  actor.locationZ = actor.locationZ - self.dropSpeed
  self.dropSpeed = self.dropSpeed + MiniTVConst.SPEED_ADD
  if actor.locationZ < MiniTVConst.INIT_LOCATION_Z then
    actor.locationZ = MiniTVConst.INIT_LOCATION_Z
    actor:ChangeState(StateNames.LandAnim, {
      bHighDrop = actor.isHigh
    })
  end
  self.location.Z = actor.locationZ
  actor:K2_SetActorLocation(self.location, false, nil, false)
end
local MiniTVLandAnimState = StateBase:new(StateNames.LandAnim)
function MiniTVLandAnimState:OnEnter(actor, args)
  printf("MiniTVLandAnimState:OnEnter - Enter land anim state")
  if args.bHighDrop then
    actor.highDropTimer = actor:AddTimerOnce(MiniTVConst.HIGH_DROP_ANIM_TIME, function()
      actor.highDropTimer = nil
      actor:ChangeState(StateNames.FixLocation)
      actor:SetDropHigh(false)
    end)
  else
    actor.lowDropTimer = actor:AddTimerOnce(MiniTVConst.LOW_DROP_ANIM_TIME, function()
      actor.lowDropTimer = nil
      actor:ChangeState(StateNames.FixLocation)
    end)
  end
end
function MiniTVLandAnimState:OnExit(actor)
  actor.isHigh = false
  actor:releaseTimer(actor.highDropTimer)
  actor:releaseTimer(actor.lowDropTimer)
  actor.highDropTimer = nil
  actor.lowDropTimer = nil
end
local MiniTVPlayAnimState = StateBase:new(StateNames.PlayAnim)
function MiniTVPlayAnimState:OnEnter(actor, args)
  printf("MiniTVPlayAnimState:OnEnter - Enter play anim state")
  actor:StopMove()
  if args.bCarAnim then
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local CarId = HallThemeUtils.GetCarID()
    local RaceVehicleCfg = CDataTable.GetTableData("BetterVehicleEffect", CarId)
    if RaceVehicleCfg and RaceVehicleCfg.MiniTVVehiclePhoto == 1 then
      actor.animTime = 5.3
      actor:PlaySelfishAnim()
      self.animType = MiniTVConst.ENUM_ANIMTYPE.SPORTCAR_SELFIE_PHONE
    else
      actor:PlayMontageAnim(args.animType)
      self.animType = args.animType
    end
  elseif args.animPath then
    actor:PlayMontageAnimByPath(args.animPath)
  else
    self.animType = args.animType
    local bPlay = actor:PlayMontageAnim(args.animType)
    if args.animType == MiniTVConst.ENUM_ANIMTYPE.Win and bPlay then
      actor.MiniTvSystem.ShowWin()
    end
  end
  if args.emojiIndex then
    actor:ChangeFaceEmotionMat(args.emojiIndex)
  else
    actor:ChangeFaceEmotionMat(0)
  end
  if actor.animTimer then
    log_error("MiniTVPlayAnimState:OnEnter - animTimer already exists")
  end
  actor.animTimer = actor:AddTimerOnce(actor.animTime, function()
    actor:releaseTimer(actor.animTimer)
    actor.animTimer = nil
    actor.animTime = 0
    if actor.hasPlayPhoneAnim == true then
      actor.hasPlayPhoneAnim = false
      actor:ClearPhone()
    end
    if actor.overlapTag == "Edge" then
      actor.overlapTag = nil
      actor.stateMachine:ChangeState(StateNames.Walk)
      return
    end
    actor.stateMachine:ChangeState(StateNames.Wait)
  end)
end
function MiniTVPlayAnimState:OnExit(actor)
  actor:ChangeFaceEmotionMat(0)
end
function MiniTVPlayAnimState:GetStateName()
  return self.StateName .. "(" .. (self.animType or "nil") .. ")"
end
local MiniTVFixLocationState = StateBase:new(StateNames.FixLocation)
function MiniTVFixLocationState:OnEnter(actor)
  printf("MiniTVFixLocationState:OnEnter - Walk to target position")
  actor:K2_SetActorRotation(FRotator(0, 0, 0), false)
  local xRatio, yRatio = MiniTVUtils.GetActorViewRatio(actor)
  if xRatio <= 0.5 then
    self.targetX = MiniTVConst.INIT_LOCATION_X
    self.targetY = MiniTVConst.INIT_LOCATION_Y
    self.targetZ = MiniTVConst.INIT_LOCATION_Z
  else
    self.targetX = MiniTVConst.INIT_LOCATION_X_RIGHT
    self.targetY = MiniTVConst.INIT_LOCATION_Y_RIGHT
    self.targetZ = MiniTVConst.INIT_LOCATION_Z_RIGHT
  end
  local dx = self.targetX - actor.locationX
  local dy = self.targetY - actor.locationY
  local dz = self.targetZ - actor.locationZ
  local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
  if dist > MiniTVConst.FIX_LOCATION_RUN_THRESHOLD then
    self.moveSpeed = MiniTVConst.RUN_SPEED
  else
    self.moveSpeed = MiniTVConst.WALK_SPEED
  end
  actor:SetSpeed(self.moveSpeed)
end
function MiniTVFixLocationState:OnUpdate(actor, deltaTime)
  if actor.isPressed then
    actor:SetSpeed(0)
    return
  end
  actor:SetSpeed(self.moveSpeed)
  local dx = self.targetX - actor.locationX
  local dy = self.targetY - actor.locationY
  local dz = self.targetZ - actor.locationZ
  local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
  local step = self.moveSpeed * deltaTime
  if dist <= step then
    print("MiniTVFixLocationState:OnUpdate - Arrived at target")
    actor.locationX = self.targetX
    actor.locationY = self.targetY
    actor.locationZ = self.targetZ
    actor:K2_SetActorLocation(FVector(self.targetX, self.targetY, self.targetZ), false, nil, false)
    actor:AddTimerOnce(0, function()
      print("MiniTVFixLocationState:OnUpdate - Change to normal state")
      actor:ChangeState(StateNames.Normal)
    end)
    return
  end
  local moveAngleRad = math.atan(dy / dx)
  if dx < 0 then
    moveAngleRad = moveAngleRad + math.pi
  end
  local yaw = math.deg(moveAngleRad) - 90
  actor:K2_SetActorRotation(FRotator(0, yaw, 0), false)
  local moveRatio = step / dist
  actor.locationX = actor.locationX + dx * moveRatio
  actor.locationY = actor.locationY + dy * moveRatio
  actor.locationZ = actor.locationZ + dz * moveRatio
  actor:K2_SetActorLocation(FVector(actor.locationX, actor.locationY, actor.locationZ), false, nil, false)
end
function MiniTVFixLocationState:OnExit(actor)
  actor:SetSpeed(0)
  actor:K2_SetActorRotation(FRotator(0, 0, 0), false)
  self.targetX = nil
  self.targetY = nil
  self.targetZ = nil
  self.moveSpeed = nil
end
local MiniTVFloatState = StateBase:new(StateNames.Float)
function MiniTVFloatState:OnEnter(actor, args)
  printf("MiniTVFloatState:OnEnter - Enter float state")
  self.floatTimer = actor:AddTimerOnce(args, function()
    self.floatTimer = nil
    actor:ChangeState(StateNames.Drop)
  end)
  if actor:HaveValidAnimInstance() then
    actor.SkeletalMesh:GetAnimInstance():SetDrag(false)
    actor.SkeletalMesh:GetAnimInstance():SetFloat(true)
  end
end
function MiniTVFloatState:OnExit(actor)
  if actor:HaveValidAnimInstance() then
    actor.SkeletalMesh:GetAnimInstance():SetFloat(false)
  end
end
return {
  States = {
    [StateNames.Normal] = MiniTVNormalState,
    [StateNames.Walk] = MiniTVWalkState,
    [StateNames.Wait] = MiniTVWaitState,
    [StateNames.Drag] = MiniTVDragState,
    [StateNames.Drop] = MiniTVDropState,
    [StateNames.PlayAnim] = MiniTVPlayAnimState,
    [StateNames.LandAnim] = MiniTVLandAnimState,
    [StateNames.FixLocation] = MiniTVFixLocationState,
    [StateNames.Float] = MiniTVFloatState
  }
}