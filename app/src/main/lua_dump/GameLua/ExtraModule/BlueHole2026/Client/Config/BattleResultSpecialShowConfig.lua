local BattleResultSpecialShowConfig = {
  Baltic = {
    MinumPlayerCount = 4,
    MaxmumPlayerCount = 4,
    LoadingMaxTime = 30,
    TotalShowTime = 25,
    LevelAssetPath = "/Game/Mod/BlueHole2026/Maps/PUBG_Baltic/Baltic_LevelSeq_BlueHole2026.Baltic_LevelSeq_BlueHole2026",
    LevelAssetName = "Baltic_LevelSeq_BlueHole2026",
    ViewTargetPos = FVector(999992.0, 2297.72168, 326.963135),
    ViewTargetRot = FRotator(1.62984, -89.999977, 3.0E-6),
    SequencePath = "/Game/Mod/BlueHole2026/Arts_PlayerBluePrints/Dance_Seq.Dance_Seq",
    SequenceActorPath = "/Game/Mod/BlueHole2026/BluePrints/Actor/BHFABattleSeqActor.BHFABattleSeqActor",
    SequenceActorPos = FVector(999150.0, 323, 286.5),
    SequenceActorRot = FRotator(0, 0, 0),
    LobbyPawnClassPath = "/Game/Mod/BlueHole2026/BluePrints/Actor/BP_SpecialWin_ShowPawn.BP_SpecialWin_ShowPawn",
    TransitionUIName = "SpecialWinShowTransitionUI",
    TransitionUIPath = "/Game/Mod/BlueHole2026/BluePrints/UI/SpecialWin_Transition_UIBP.SpecialWin_Transition_UIBP",
    CameraButtonUIName = "SpecialWinShowButtonUI",
    ButtonUIPath = "/Game/Mod/BlueHole2026/BluePrints/UI/SpecialWin_NameInfo_UIBP.SpecialWin_NameInfo_UIBP",
    PawnBindMap = {
      [1] = "BP_SpecialWin_ShowPawn",
      [2] = "BP_SpecialWin_ShowPawn2",
      [3] = "BP_SpecialWin_ShowPawn3",
      [4] = "BP_SpecialWin_ShowPawn4"
    },
    sShowTypeName = "BasicShowType",
    NameCardIDMap = {
      [1] = "NameCard_Basic_1",
      [2] = "NameCard_Basic_2",
      [3] = "NameCard_Basic_3",
      [4] = "NameCard_Basic_4"
    },
    NameCardFinalPos = {
      [1] = FVector2D(-110.0, 80.0),
      [2] = FVector2D(-270.0, 130.0),
      [3] = FVector2D(70.0, 40.0),
      [4] = FVector2D(190, 210.0)
    }
  }
}
return BattleResultSpecialShowConfig