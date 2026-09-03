local TeampanelConfig = {
  HP_Phase_Color = {
    HpColor_Phase1 = FLinearColor(1, 1, 1, 1),
    HpColor_Phase2 = FLinearColor(0.947917, 0.232042, 0.232042, 0.812),
    HpColor_Phase3 = FLinearColor(0.863157, 0.090842, 0.008023, 1),
    FullColor = FLinearColor(1, 1, 1, 0.5)
  },
  AutoCloseVoiceDelay = 0.5,
  UAV_AkEventPath = {
    UAVVheicleSoundPath = "/Game/WwiseEvent/Voice_ExtremelyCold/Play_wurenji_02.Play_wurenji_02",
    UAVMoveSoundPath = "/Game/WwiseEvent/Voice_ExtremelyCold/Play_wurenji_04.Play_wurenji_04",
    UAVShotSoundPath = "/Game/WwiseEvent/Voice_ExtremelyCold/Play_wurenji_03.Play_wurenji_03",
    UAVHurtSoundPath = "/Game/WwiseEvent/Voice_ExtremelyCold/Play_wurenji_05.Play_wurenji_05"
  },
  TeamPlayerColorTable = {
    [1] = FLinearColor(0.645833, 0.550796, 0.029071, 0.9),
    [2] = FLinearColor(0.545724, 0.144128, 0.024158, 0.9),
    [3] = FLinearColor(0.022174, 0.258183, 0.462077, 0.9),
    [4] = FLinearColor(0.104616, 0.371238, 0.028426, 0.9),
    [5] = FLinearColor(0.51, 0.08, 0.48, 0.9),
    [6] = FLinearColor(0.1, 0.39, 0.38, 0.9),
    [7] = FLinearColor(0.73, 0.13, 0.16, 0.9),
    [8] = FLinearColor(0.19, 0.17, 0.71, 0.9)
  },
  TeamPlayerColorTable_OnPlane = {
    [1] = FLinearColor(0.645833, 0.550796, 0.029071, 1),
    [2] = FLinearColor(0.545724, 0.144128, 0.024158, 1),
    [3] = FLinearColor(0.022174, 0.258183, 0.462077, 1),
    [4] = FLinearColor(0.104616, 0.371238, 0.028426, 1),
    [5] = FLinearColor(0.51, 0.08, 0.48, 1),
    [6] = FLinearColor(0.1, 0.39, 0.38, 1),
    [7] = FLinearColor(0.73, 0.13, 0.16, 1),
    [8] = FLinearColor(0.19, 0.17, 0.71, 1)
  },
  InviteCD = 5,
  ShotRemindDist = 400,
  TextAlphaColor = {
    [1] = FLinearColor(1, 1, 1, 0.3),
    [2] = FLinearColor(1, 1, 1, 1)
  },
  PosItemDyingColor = FLinearColor(0.806952, 0.074214, 0.005182, 1),
  BeingRescuedColor = FLinearColor(1, 1, 1, 1)
}
return TeampanelConfig