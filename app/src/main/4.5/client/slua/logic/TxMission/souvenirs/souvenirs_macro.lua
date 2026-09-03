local souvenirs_macro = {
  TaskStatus = {
    NotFinish = 0,
    Finished = 1,
    Rewarded = 2
  },
  MinSeasons = 3,
  MaxTasksOneSeason = 4,
  DefaultProcessValue = 0.02,
  LobbySouvenirsStatus = {
    UnRelease = 0,
    CanRelease = 1,
    CanGet = 2,
    Got = 3
  },
  LobbySouvenirsType = {lobby = 1, xmission = 2},
  LobbySouvenirsLoginReleaseDay = 3,
  LobbyTSouvenirsGuideStepType = {
    EnumType_Click_Person_Space_Entry = 1,
    EnumType_Click_Souvenirs_Entry = 2,
    EnumType_Click_T_Souvenirs_Entry = 3,
    EnumType_Click_T_Souvenirs_Show = 4
  },
  ESouvenirsType = {
    Normal = 0,
    Anniversary = 1,
    PMGC = 2,
    Special = 3
  },
  EPMGCSouvenirsButtonState = {
    BeforeStart = 0,
    Enable = 1,
    Get = 2,
    Show = 3,
    HaveShow = 4,
    End = 5
  },
  ETSouvenirsType = {
    All = 0,
    Kill = 1,
    Money = 2,
    Submit = 3
  },
  ETBuffStatus = {
    Lock = 1,
    Unlock = 2,
    Vaild = 3,
    Expired = 4
  },
  TCabinetDefaultLimit = 18,
  TCabinetDefaultPageNum = 2,
  TCabinetOnePageNum = 9
}
local TSouvenirsTab_Config = {
  {
    Id = souvenirs_macro.ETSouvenirsType.All,
    IconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON1_png.XMission_Wardrobe_ICON1_png",
    IconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON1_1_png.XMission_Wardrobe_ICON1_1_png"
  },
  {
    Id = souvenirs_macro.ETSouvenirsType.Submit,
    IconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Souvenirs/Xmission_Souvenirs_Icon_Tab01.Xmission_Souvenirs_Icon_Tab01",
    IconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Souvenirs/Xmission_Souvenirs_Icon_Tab01_1.Xmission_Souvenirs_Icon_Tab01_1"
  },
  {
    Id = souvenirs_macro.ETSouvenirsType.Kill,
    IconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Souvenirs/Xmission_Souvenirs_Icon_Tab02.Xmission_Souvenirs_Icon_Tab02",
    IconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Souvenirs/Xmission_Souvenirs_Icon_Tab02_01.Xmission_Souvenirs_Icon_Tab02_01"
  },
  {
    Id = souvenirs_macro.ETSouvenirsType.Money,
    IconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Souvenirs/Xmission_Souvenirs_Icon_Tab03.Xmission_Souvenirs_Icon_Tab03",
    IconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Souvenirs/Xmission_Souvenirs_Icon_Tab03_01.Xmission_Souvenirs_Icon_Tab03_01"
  }
}
souvenirs_macro.return souvenirs_macro