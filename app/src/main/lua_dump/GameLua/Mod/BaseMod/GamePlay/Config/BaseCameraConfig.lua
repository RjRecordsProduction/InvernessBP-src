local BaseCameraConfig = {
  WaterVehicle = {
    SocketOffset = FVector(0, 0, 0),
    TargetOffset = FVector(0, 0, 0),
    SpringArmLength = 800,
    AdditiveOffsetFov = 0,
    FixedFov = 0,
    BeginInterpSpeed = 0,
    EndInterpSpeed = 0
  },
  Helecopte = {
    SocketOffset = FVector(0, 0, 0),
    TargetOffset = FVector(0, 0, 0),
    SpringArmLength = 700,
    AdditiveOffsetFov = 0,
    FixedFov = 0,
    BeginInterpSpeed = 0,
    EndInterpSpeed = 0
  },
  MortarWeapon = {
    SocketOffset = FVector(0, 50, -5),
    TargetOffset = FVector(0, 0, 0),
    SpringArmLength = 250,
    AdditiveOffsetFov = 0,
    FixedFov = 0,
    BeginInterpSpeed = 1,
    EndInterpSpeed = 1
  },
  MortarWeaponPrecise = {
    SocketOffset = FVector(0, 20, 48),
    TargetOffset = FVector(0, 0, 0),
    SpringArmLength = 400,
    AdditiveOffsetFov = 0,
    FixedFov = 90,
    BeginInterpSpeed = 1,
    EndInterpSpeed = 1
  },
  PenguinRocketWeaponHold = {
    SocketOffset = FVector(0, 35, 0),
    TargetOffset = FVector(0, 0, 0),
    SpringArmLength = 220,
    AdditiveOffsetFov = 0,
    FixedFov = 0,
    BeginInterpSpeed = 1,
    EndInterpSpeed = 1
  }
}
return BaseCameraConfig