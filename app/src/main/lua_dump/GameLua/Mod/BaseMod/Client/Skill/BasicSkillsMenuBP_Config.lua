local BasicSkillsMenuBP_Config = {
  bNewVersionDoor = false,
  InteractTypes = {
    Type_InteractiveComponent = {
      IconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Common_Icon_Leave_png.Common_Icon_Leave_png",
      TextID = 4996,
      ActionOnClick = "Action_InteractiveComponent"
    },
    Type_HorseTranform = {
      IconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Common_Icon_Leave_png.Common_Icon_Leave_png",
      TextID = 4996,
      ActionOnClick = "Action_InteractiveComponent",
      bChangeOperation = true
    },
    Type_DesertDrinkMachine = {
      IconPath = "/Game/Arts/UI/TableIcons/ItemIcon/Ingame_ActivityBtn_Icon/Icon_VendingMachine.Icon_VendingMachine",
      TextID = 27939,
      ActionOnClick = "Action_DesertDrinkMachine"
    },
    Type_Activity1 = {
      ActionOnShow = "Action_Activity1Show",
      ActionOnClick = "Action_Activity1",
      ActionOnHide = "Aciton_Activity1Hide"
    },
    Type_Activity2 = {
      ActionOnShow = "Action_Activity2Show",
      ActionOnClick = "Action_Activity2"
    },
    Type_ActivityCancel = {
      ActionOnShow = "Action_ActivityCancelShow",
      ActionOnClick = "Action_ActivityCancel"
    },
    Type_OpenDoor = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_kaimen_png.ZD_icon_kaimen_png",
      TextID = 38710,
      ActionOnPress = "Action_OpenOrCloseDoor"
    },
    Type_CloseDoor = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_guanmen_png.ZD_icon_guanmen_png",
      TextID = 38711,
      ActionOnPress = "Action_OpenOrCloseDoor"
    },
    Type_MVPStatueCelerbrate = {
      IconPath = "/Game/Arts/UI/TableIcons/Emote/Icon_WrappingDacne1_128.Icon_WrappingDacne1_128",
      TextID = 48896,
      ActionOnPress = "Action_MVPStatueCelerbrate"
    },
    Type_MiniTV_Broadcast = {
      IconPath = "/Game/Mod/EvoBase/Atlas/MiniTv/Frames/ZD_icon_Bobao_png.ZD_icon_Bobao_png",
      TextID = 13590,
      ActionOnPress = "Action_Broadcast"
    },
    Type_EnterMegaDrop = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_jump_png.ZD_icon_jump_png",
      TextID = 38703,
      ActionOnClick = "Action_EnterMegaDrop",
      bChangeOperation = true
    },
    Type_LeaveMegaDrop = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_huidaodating_png.ZD_icon_huidaodating_png",
      TextID = 38705,
      ActionOnClick = "Action_LeaveMegaDrop",
      bChangeOperation = true
    },
    Type_LaunchMegaDrop = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_kaisan_1_png.ZD_icon_kaisan_1_png",
      TextID = 38704,
      ActionOnClick = "Action_LaunchMegaDrop",
      bChangeOperation = true
    },
    Type_SnowBoard = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_SkiboardOFF_01_png.ZD_icon_SkiboardOFF_01_png",
      TextID = 38707,
      ActionOnClick = "Action_SnowBoard",
      bChangeOperation = true
    },
    Type_Surfing = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Conglang_png.ZD_Conglang_png",
      TextID = 38706,
      ActionOnClick = "Action_Surfing",
      bChangeOperation = true
    },
    Type_TireRepair = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_TyreRepair_png.ZD_Icon_TyreRepair_png",
      TextID = 792276,
      ActionOnClick = "Action_TireRepair",
      bChangeOperation = true
    },
    Type_DriverEnter = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_jiashi_png.ZD_icon_jiashi_png",
      TextID = 38713,
      ActionOnShow = "Action_DriverEnterShow",
      ActionOnClick = "Action_DriverEnter",
      ActionOnPreShow = "Action_DriverEnterPreShow",
      bChangeOperation = true
    },
    Type_ApplyDrive = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_jiashi_png.ZD_icon_jiashi_png",
      TextID = 38714,
      ActionOnClick = "Action_ApplyDrive",
      bChangeOperation = true
    },
    Type_PassengerEnter = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_icon_chengzuo_png.ZD_icon_chengzuo_png",
      TextID = 33677,
      ActionOnClick = "Action_PassengerEnter",
      ActionOnPreShow = "Action_PassengerEnterPreShow",
      bChangeOperation = true
    },
    Type_BikeEnter = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_icon_Interact_Tap_png.ZD_icon_Interact_Tap_png",
      TextID = 38713,
      ActionOnClick = "Action_DriverEnter",
      bChangeOperation = true
    },
    Type_BikePick = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_icon_Interact_PickUp_png.ZD_icon_Interact_PickUp_png",
      TextID = 33678,
      ActionOnClick = "Action_PickupVehicle",
      bChangeOperation = true
    },
    Type_FollowEmote = {
      IconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Sink_Icon_FollowEmote_png.Sink_Icon_FollowEmote_png",
      TextID = 30170,
      ActionOnClick = "Action_FollowEmote"
    },
    Type_JoinCoopEmote = {
      IconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Sink_Icon_FitEmote_png.Sink_Icon_FitEmote_png",
      TextID = 44708,
      ActionOnClick = "Action_JoinCoopEmote"
    },
    Type_StoreSkate = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_icon_POI_png.ZD_icon_POI_png",
      TextID = 49994,
      ActionOnClick = "Action_StoreSkate"
    },
    Type_StoreBlanket = {
      IconPath = "/Game/Mod/ZNQ6th/Arts/UI/ZNQ6th_Atlas/Frames/ZD_Icon_Receive_png.ZD_Icon_Receive_png",
      TextID = 49994,
      ActionOnClick = "Action_StoreBlanket"
    },
    Type_MechaDance = {
      IconPath = "/Game/Library/Res/Vehicles/Mecha/Arts/UI/Atlas/Frames/ZD_Icon_Machine_Dance_png.ZD_Icon_Machine_Dance_png",
      TextID = 34311,
      ActionOnClick = "Action_MechaDance",
      bChangeOperation = true
    },
    Type_PandaDance = {
      IconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Panda_png.ZD_Icon_Panda_png",
      TextID = 34311,
      ActionOnClick = "Action_PandaDance",
      bChangeOperation = true,
      bLast = true
    },
    Type_FeedHorse = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
      TextID = 69814,
      ActionOnClick = "Action_FeedHorse",
      bChangeOperation = true,
      bLast = true
    },
    Type_StoreUpload = {
      IconPath = "/Game/Mod/Halloween4/Arts/UI/Atlas/Frames/ZD_Icon_Upload_png.ZD_Icon_Upload_png",
      TextID = 76672,
      ActionOnClick = "Action_StoreUpload",
      bChangeOperation = false,
      bLast = false
    },
    Type_StoreCamel = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_icon_POI_png.ZD_icon_POI_png",
      TextID = 49994,
      ActionOnClick = "Action_StoreCamel"
    },
    Type_LeaveForwardEmote = {
      IconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Exit_png.ZD_Icon_Exit_png",
      TextID = 38705,
      ActionOnClick = "Action_LeaveForwardEmote",
      bLast = true,
      Type = "Type_LeaveForwardEmote"
    },
    Type_HangGlider = {
      IconPath = "/Game/Mod/Turkey/Arts/UI/Icon/Turkey_Icon_Gliding.Turkey_Icon_Gliding",
      TextID = 10005,
      ActionOnClick = "Action_UseHangGlider",
      bIgnoreCustomPos = true
    }
  }
}
return BasicSkillsMenuBP_Config