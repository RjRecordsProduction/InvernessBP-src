local PlaneShowConfig = {
  CabinShowItemConfig = {
    ShowItems = {
      [22200003] = {
        ShowType = "FinalNameUI",
        SwitchIndex = 1
      },
      [22200001] = {
        ShowType = "FinalNameUI",
        SwitchIndex = 2
      },
      [22200002] = {
        ShowType = "FinalNameUI",
        SwitchIndex = 3
      },
      [22200004] = {
        ShowType = "FinalNameUI",
        SwitchIndex = 4
      },
      [22200005] = {
        ShowType = "FinalNameUI",
        SwitchIndex = 5
      }
    }
  },
  Default = {
    EnableShow = false,
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
    DisableModeID = {
      1070,
      1071,
      1072,
      1094,
      1095,
      1096,
      20007,
      20008,
      20009,
      64943,
      64946,
      64949
    },
    SimpleModeID = {
      10003,
      10004,
      10009,
      10010,
      1037,
      1022,
      1034,
      1073,
      1023,
      1024,
      1025,
      1026,
      1027,
      1028,
      1029,
      1030,
      1031,
      1032,
      1033,
      1035,
      1036,
      1038,
      1039,
      1072,
      1074,
      1075,
      1076,
      1040,
      1041,
      1042,
      1045,
      1055,
      1056,
      1057,
      1058,
      1059,
      1060,
      1061,
      1062,
      1063
    },
    PlaneActorClassPath = "/Game/BluePrints/Plane/BP_PlaneCharacter.BP_PlaneCharacter_C",
    CheckPakDownLoadPath = "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C",
    EnableSkinTipsUI = true,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 21,
        SequenceActorPath = "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C",
        LevelSeq = "/Game/Library/Res/Actors/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4",
        LevelSeqBindKey = "PlaneShowActor",
        LevelSeqDirectionalLightBindKey = "PlaneShow_DirectionalLight",
        LobbyPawnClassPath = "/Game/Library/Res/Actors/PlaneShow/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn",
        LobbyPawnActorPath = "/Game/Library/Res/Actors/PlaneShow/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C",
        bNeedShowLobbyPawn = true,
        LobbyPawnBindKey = {
          "LobbyPawnForSeq",
          "LobbyPawnForSeq2",
          "LobbyPawnForSeq3",
          "LobbyPawnForSeq4"
        },
        UIPath = "/Game/Mod/EvoBase/BluePrints/UI/ID_Emergesr_UIBP.ID_Emergesr_UIBP_C",
        LevelSeqPathByTeammate = {
          "/Game/Library/Res/Actors/PlaneShow/SEQ_CabinShow01.SEQ_CabinShow01",
          "/Game/Library/Res/Actors/PlaneShow/SEQ_CabinShow02.SEQ_CabinShow02",
          "/Game/Library/Res/Actors/PlaneShow/SEQ_CabinShow03.SEQ_CabinShow03",
          "/Game/Library/Res/Actors/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4"
        },
        AudioPathByTeammate = {
          "/Game/WwiseEvent/Directing/Directing_BornIsland_CG/Play_Directing_BornIsland_CG_01.Play_Directing_BornIsland_CG_01",
          "/Game/WwiseEvent/Directing/Directing_BornIsland_CG/Play_Directing_BornIsland_CG_02.Play_Directing_BornIsland_CG_02",
          "/Game/WwiseEvent/Directing/Directing_BornIsland_CG/Play_Directing_BornIsland_CG_03.Play_Directing_BornIsland_CG_03",
          "/Game/WwiseEvent/Directing/Directing_BornIsland_CG/Play_Directing_BornIsland_CG_04.Play_Directing_BornIsland_CG_04"
        },
        ActorSeqPathByTeammate = {
          "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor01.PlaneShowActor01_C",
          "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor02.PlaneShowActor02_C",
          "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor03.PlaneShowActor03_C",
          "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C"
        },
        LevelSeqBindKeyByTeammate = {
          "PlaneShowActor01",
          "PlaneShowActor02",
          "PlaneShowActor03",
          "PlaneShowActor"
        },
        StateTimeByTeammate = {
          16,
          17.2,
          20.5,
          21.5
        },
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        },
        SeqActorNameDic = {
          "PlanShow_SMAircraftPerformance01",
          "PlanShow_SMAircraftPerformance01A",
          "PlanShow_SMAircraftPerformance01B",
          "PlaneShow_blockBOX",
          "PlaneShow_P_CabinShow_01",
          "PlaneShow_P_CabinShow_02",
          "PlaneShow_P_CabinShow_04",
          "PlaneShow_DirectionalLight",
          "PlaneShow_CameraActor02",
          "PlaneShow_CameraActor",
          "LobbyPawnForSeq",
          "LobbyPawnForSeq2",
          "LobbyPawnForSeq3",
          "LobbyPawnForSeq4"
        },
        ChangeCamereInvisibleActor = {
          "PlanShow_SMAircraftPerformance01",
          "PlanShow_SMAircraftPerformance01A",
          "PlanShow_SMAircraftPerformance01B",
          "PlaneShow_blockBOX",
          "PlaneShow_P_CabinShow_01",
          "PlaneShow_P_CabinShow_02",
          "PlaneShow_P_CabinShow_04",
          "LobbyPawnForSeq",
          "LobbyPawnForSeq2",
          "LobbyPawnForSeq3",
          "LobbyPawnForSeq4"
        },
        PlayEffectConfig = {
          [1] = {
            "PlaneShow_P_CabinShow_04"
          },
          [2] = {
            "PlaneShow_P_CabinShow_01",
            "PlaneShow_P_CabinShow_02"
          }
        },
        ShowActorConfig = {
          [1] = {
            "PlaneShow_blockBOX",
            "PlanShow_SMAircraftPerformance01",
            "PlanShow_SMAircraftPerformance01A",
            "PlanShow_SMAircraftPerformance01B",
            "LobbyPawnForSeq",
            "LobbyPawnForSeq2",
            "LobbyPawnForSeq3",
            "LobbyPawnForSeq4"
          },
          [2] = {
            "PlaneShow_blockBOX",
            "PlanShow_SMAircraftPerformance01",
            "PlanShow_SMAircraftPerformance01A",
            "PlanShow_SMAircraftPerformance01B",
            "LobbyPawnForSeq",
            "LobbyPawnForSeq2",
            "LobbyPawnForSeq3",
            "LobbyPawnForSeq4"
          }
        },
        CreateActorHide = {
          "PlanShow_SMAircraftPerformance01",
          "PlanShow_SMAircraftPerformance01A",
          "PlanShow_SMAircraftPerformance01B",
          "PlaneShow_blockBOX",
          "LobbyPawnForSeq",
          "LobbyPawnForSeq2",
          "LobbyPawnForSeq3",
          "LobbyPawnForSeq4"
        },
        CameraUseInfo = {
          StaticCameraName = "PlaneShow_CameraActor02",
          CabinShowCameraName = "PlaneShow_CameraActor"
        },
        SeqAddLightInfo = {
          "PlaneShow_DirectionalLight"
        },
        PlaneShowUIType = 2,
        AliasBroadcastDelay = 21,
        RealTimeBanAliasBroadcastDelay = 15
      },
      {
        Name = "FinishPlaneShow"
      }
    },
    PreLoadAssetKey = {
      "SequenceActorPath",
      "LevelSeq",
      "LobbyPawnActorPath",
      "LevelSeqPathByTeammate",
      "ActorSeqPathByTeammate",
      "AudioPathByTeammate",
      "UIPath"
    }
  },
  DefaultSimple = {
    EnableSwitchUI = false,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 7.1,
        SequenceActorPath = "/Game/Arts_PlayerBluePrints/PlaneShow/KC_PlaneShowActor_2.KC_PlaneShowActor_2_C",
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        }
      },
      {
        Name = "FinishPlaneShow"
      }
    }
  },
  Baltic_Main = {EnableShow = true, EnableSwitchUI = true},
  FourMaps_Main = {
    EnableShow = true,
    EnableSkinTipsUI = false,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 2.6,
        SequenceActorPath = "/Game/Arts_PlayerBluePrints/PlaneShow/KC_PlaneShowActor_short.KC_PlaneShowActor_short_C",
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        },
        ShowUIKey = {}
      },
      {
        Name = "FinishPlaneShow"
      }
    }
  },
  PUBG_Desert = {EnableShow = true, EnableSwitchUI = true},
  PUBG_Savage_Main = {
    EnableShow = true,
    EnableSkinTipsUI = false,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 2.6,
        SequenceActorPath = "/Game/Arts_PlayerBluePrints/PlaneShow/KC_PlaneShowActor_short.KC_PlaneShowActor_short_C",
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        },
        ShowUIKey = {}
      },
      {
        Name = "FinishPlaneShow"
      }
    }
  },
  PUBG_4Anniversary_ResultAvatar = {EnableShow = true, EnableSwitchUI = true},
  PUBG_Summerland_Mian = {
    EnableShow = true,
    EnableSkinTipsUI = false,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 2.6,
        SequenceActorPath = "/Game/Arts_PlayerBluePrints/PlaneShow/KC_PlaneShowActor_short.KC_PlaneShowActor_short_C",
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        },
        ShowUIKey = {}
      },
      {
        Name = "FinishPlaneShow"
      }
    }
  },
  Sink_Main = {
    EnableShow = true,
    EnableSkinTipsUI = false,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 2.6,
        SequenceActorPath = "/Game/Arts_PlayerBluePrints/PlaneShow/KC_PlaneShowActor_short.KC_PlaneShowActor_short_C",
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        },
        ShowUIKey = {}
      },
      {
        Name = "FinishPlaneShow"
      }
    }
  },
  DihorOtok_Main = {EnableShow = true, EnableSwitchUI = true},
  PUBG_Borderland_Main = {
    EnableShow = true,
    EnableSkinTipsUI = false,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 2.6,
        SequenceActorPath = "/Game/Arts_PlayerBluePrints/PlaneShow/KC_PlaneShowActor_short.KC_PlaneShowActor_short_C",
        PostEvent = {
          {
            DelayTime = 3,
            EventType = EVENTTYPE_INGAME_PLANESHOW,
            EventName = EVENTTYPE_INGAME_PLANESHOW_UI_LOGO,
            Params = "logoTexturePath",
            Params2 = "logo2"
          }
        },
        ShowUIKey = {}
      },
      {
        Name = "FinishPlaneShow"
      }
    }
  },
  PUBG_Neon_Main = {EnableSwitchUI = true, EnableShow = true}
}
return PlaneShowConfig