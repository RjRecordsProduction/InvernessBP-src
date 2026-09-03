local PlaneShowConfig = {
  Baltic_Main = {
    EnableMode = {"GodTrial"},
    EnableShow = true,
    EnableSwitchUI = true,
    EnableSkinTipsUI = true,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 21,
        SequenceActorPath = "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C",
        LevelSeq = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4",
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
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow01.SEQ_CabinShow01",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow02.SEQ_CabinShow02",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow03.SEQ_CabinShow03",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4"
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
            "PlaneShow_P_CabinShow_04",
            "P_Halloween5_Mirror_01_Gate_L3",
            "P_Halloween5_Mirror_01_Idle_L4"
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
    }
  },
  PUBG_Neon_Main = {
    EnableMode = {"GodTrial"},
    EnableShow = true,
    EnableSkinTipsUI = true,
    EnableSwitchUI = true,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 21,
        SequenceActorPath = "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C",
        LevelSeq = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4",
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
        LevelSeqPathByTeammate = {
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow01.SEQ_CabinShow01",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow02.SEQ_CabinShow02",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow03.SEQ_CabinShow03",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4"
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
    }
  },
  PUBG_Desert = {
    EnableMode = {"GodTrial"},
    EnableShow = true,
    EnableSwitchUI = true,
    EnableSkinTipsUI = true,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 21,
        SequenceActorPath = "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C",
        LevelSeq = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4",
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
        LevelSeqPathByTeammate = {
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow01.SEQ_CabinShow01",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow02.SEQ_CabinShow02",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow03.SEQ_CabinShow03",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4"
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
            "PlaneShow_P_CabinShow_04",
            "P_Halloween5_Mirror_01_Gate_L3",
            "P_Halloween5_Mirror_01_Idle_L4"
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
    }
  },
  DihorOtok_Main = {
    EnableMode = {"GodTrial"},
    EnableShow = true,
    EnableSwitchUI = true,
    EnableSkinTipsUI = true,
    StateConfig = {
      {
        Name = "PlaneActorSequenceShow",
        StateTime = 21,
        SequenceActorPath = "/Game/Library/Res/Actors/PlaneShow/PlaneShowActor.PlaneShowActor_C",
        LevelSeq = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4",
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
        LevelSeqPathByTeammate = {
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow01.SEQ_CabinShow01",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow02.SEQ_CabinShow02",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow03.SEQ_CabinShow03",
          "/Game/Mod/GodTrial/Arts_PlayerBluePrints/PlaneShow/SEQ_CabinShow_4.SEQ_CabinShow_4"
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
            "PlaneShow_P_CabinShow_04",
            "P_Halloween5_Mirror_01_Gate_L3",
            "P_Halloween5_Mirror_01_Idle_L4"
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
            "Planeshow_Scene_Item_Int_1",
            "Planeshow_Scene_Item_Int_2",
            "Planeshow_Scene_Item_Int_3",
            "Planeshow_Scene_Item_Int_4",
            "Planeshow_Scene_Item_Int_5",
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
          "Planeshow_Scene_Item_Int_1",
          "Planeshow_Scene_Item_Int_2",
          "Planeshow_Scene_Item_Int_3",
          "Planeshow_Scene_Item_Int_4",
          "Planeshow_Scene_Item_Int_5",
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
    }
  }
}
return PlaneShowConfig