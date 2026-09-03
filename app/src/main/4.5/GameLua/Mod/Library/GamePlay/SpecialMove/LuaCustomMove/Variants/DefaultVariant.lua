local DefaultVariant = {
  ParamSet = {
    MaxWalkSpeed = 600.0,
    MaxAccelerationWalking = 2048.0,
    BrakingDecelerationWalking = 2048.0,
    GroundFriction = 8,
    MaxStepHeight = 45.0,
    WalkableFloorAngle = 44.765,
    MaxFallSpeed = 1200.0,
    BrakingDecelerationFalling = 0.0,
    GravityScale = 1.0,
    AirControl = 0.05,
    AirControlBoostMultiplier = 2.0,
    AirControlBoostVelocityThreshold = 25.0,
    JumpZVelocity = 600.0,
    FallingLateralFriction = 0.0,
    MaxFlySpeed = 800.0,
    MaxAccelerationFlying = 2048.0,
    BrakingDecelerationFlying = 2048.0
  }
}
function DefaultVariant:OnEnter(MoveObj, ParamSetKey, ParamSetIndex)
end
function DefaultVariant:OnLeave(MoveObj)
end
function DefaultVariant:OnEnterFlyingMode(MoveObj)
end
function DefaultVariant:OnExitFlyingMode(MoveObj)
end
return DefaultVariant