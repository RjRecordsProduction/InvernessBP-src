local _DisableModeID = {
  60011,
  60012,
  60013,
  60014,
  60031,
  60032,
  880001,
  880002,
  880003,
  880004,
  880005,
  880006,
  880007,
  880008,
  880000,
  600074,
  600075,
  600076,
  600077,
  600078,
  600079,
  600080,
  600081,
  600082,
  600083,
  600084,
  600085,
  600090
}
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
for i = 1, #UGCMacros.UGC_SUB_GAME_MODE_ID_LIST do
  table.insert(_DisableModeID, UGCMacros.UGC_SUB_GAME_MODE_ID_LIST[i])
end
local BornIslandTeamShowConfig = {
  Default = {
    EnableShow = true,
    EnableMode = {
      "BaseMod",
      "Livik",
      "Borderland",
      "Sink2",
      "Karakin",
      "Neon"
    },
    EnableSubMode = {
      "Baltic",
      "Livik",
      "DihorOtok",
      "Savage",
      "Desert",
      "Neon"
    },
    DisableModeID = _DisableModeID,
    SequenceActorPath = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/BP_TeamShowSeqActor.BP_TeamShowSeqActor_C",
    SequencePath = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/BornIslandTeamShowSeq_Test.BornIslandTeamShowSeq_Test",
    SequencePosition = FVector(792880.0, 13599.40625, 540.210693),
    SequenceRotator = FRotator(0, 60, 0),
    PlayerAnimDelayTime = 1,
    MinItemQuality = 4,
    TotalShowTime = 7,
    UIDelayShowTime = 2,
    PlanelLocGroup = {
      [1.33] = {
        -300,
        -90,
        100,
        300
      },
      [1.5] = {
        -300,
        -100,
        100,
        300
      },
      [1.775] = {
        -300,
        -100,
        90,
        300
      },
      [2.164] = {
        -370,
        -100,
        100,
        330
      }
    },
    TeamShowToPlaneShowUIShowTime = 0.2,
    PlayerDefaultAnims = {
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/Animation/Team_assembly_loading_P1_Idle_Montage.Team_assembly_loading_P1_Idle_Montage",
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/Animation/Team_assembly_loading_P2_Idle_Montage.Team_assembly_loading_P2_Idle_Montage",
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/Animation/Team_assembly_loading_P3_Idle_Montage.Team_assembly_loading_P3_Idle_Montage",
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/Animation/Team_assembly_loading_P4_Idle_Montage.Team_assembly_loading_P4_Idle_Montage"
    },
    DefaultPlayerAnimOffset = {
      FVector(-11, -106, 0),
      FVector(22, -151, 0),
      FVector(0, -74, 0),
      FVector(0, 4.5, 0)
    },
    ItemSubTypeDefaultScale = {
      [963] = 0.7,
      [911] = 0.8,
      [968] = 0.4,
      [988] = 0.7,
      [987] = 1
    },
    ExtraNeedHiddenClassPath = {}
  },
  Baltic_Main = {EnableShow = true},
  FourMaps_Main = {
    EnableShow = true,
    SequencePosition = FVector(83133.492188, 154260.015625, 385.0),
    SequenceRotator = FRotator(0, -11.5, 0)
  },
  PUBG_Savage_Main = {
    EnableShow = true,
    SequencePosition = FVector(298160.0, 195630.0, 1400.0),
    SequenceRotator = FRotator(0, -70, 0)
  },
  DihorOtok_Main = {
    EnableShow = true,
    SequencePosition = FVector(446010.0, 450550.0, 2250.0),
    SequenceRotator = FRotator(0, -130, 0)
  },
  PUBG_Desert = {
    EnableShow = true,
    SequencePosition = FVector(81810.0, 730150.0, 5110.0),
    SequenceRotator = FRotator(0, -40, 0)
  },
  PUBG_Borderland_Main = {
    EnableShow = true,
    SequencePosition = FVector(89666.7, 113155.1, 70.0),
    SequenceRotator = FRotator(0, 70, 0),
    TotalShowTime = 5,
    UIDelayShowTime = 0,
    PlayerAnimDelayTime = 0,
    SequencePath = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/BornIslandTeamShowSeq_Test2.BornIslandTeamShowSeq_Test2"
  },
  PUBG_Summerland_Mian = {
    EnableShow = true,
    SequencePosition = FVector(160390.0, 165420.0, 640.0),
    SequenceRotator = FRotator(0, -170, 0)
  },
  PUBG_Neon_Main = {
    EnableShow = true,
    SequencePosition = FVector(473008.6875, 708685.4375, 14147.0),
    SequenceRotator = FRotator(0, 61.874905, 0)
  }
}
return BornIslandTeamShowConfig