local EPawnState = import("EPawnState")
local GeneralShowSpotConfig = {
  ShowSpotOccupiedTips = 69956,
  BlockCheckProfile = "Pawn",
  DefaultBlockCheckRadius = 34,
  DefaultBlockCheckHalfHeight = 88,
  DefaultAttachRelativeLocation = FVector(0, 0, 0),
  DefaultAttachRelativeRotation = FRotator(0, 0, 0),
  DefaultMontagePlayRate = 1.0,
  ShowSpotPhotoUIMode = 3,
  EnterShowSpotTimeout = 5.0,
  ExitSelfieDebounceTime = 1.0,
  DisabledPawnStatesOnShowSpot = {
    EPawnState.MeleeAttack,
    EPawnState.Pick,
    EPawnState.GunADS,
    EPawnState.Skill,
    EPawnState.HoldGrenade,
    EPawnState.Save,
    EPawnState.CarryBack,
    EPawnState.PlayEmote,
    EPawnState.Vault
  },
  DisallowInteractPawnStates = {
    EPawnState.GunADS,
    EPawnState.Build,
    EPawnState.ControlWeapon,
    EPawnState.PlayEmote,
    EPawnState.Vault
  }
}
return GeneralShowSpotConfig