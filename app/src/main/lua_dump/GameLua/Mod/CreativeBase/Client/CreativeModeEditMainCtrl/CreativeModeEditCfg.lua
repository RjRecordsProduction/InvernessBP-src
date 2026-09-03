local CreativeGlobalDefine = require("GameLua.Mod.CreativeBase.Gameplay.Config.Asset.Common.CreativeGlobalDefine")
local MODIFY_TICK_FRAME_CFG = 60
local CreativeModeEditCfg = {
  SWITCH_EDIT_PLAYER_CD = 1,
  SHORTCUT_BAR_ITEM_NUM = 8,
  SHORTCUT_BAR_TAB_NUM = 3,
  SHORTCUT_ITEM_MAX_NUM = 20,
  SHORTCUT_TAB_MAX_NUM = 6,
  SWITCH_FLY_STATE_CD = 2,
  ROTATING_TICK_RATE = 1 / MODIFY_TICK_FRAME_CFG,
  ROTATING_TICK_ROLLUNIT = 180 / MODIFY_TICK_FRAME_CFG,
  ROTATING_TICK_DELAY = 0.3,
  ROTATING_CLICKED_ROLLUNIT = 18.0,
  MODIFY_TICK_RATE = 1 / MODIFY_TICK_FRAME_CFG,
  MODIFY_TICK_DELAY = 0.3,
  MODIFY_TICK_ROTATE_UNIT = 180 / MODIFY_TICK_FRAME_CFG,
  MODIFY_CLICKED_ROTATE_UNIT = 18.0,
  MODIFY_TICK_SCALE_UNIT = 1 / MODIFY_TICK_FRAME_CFG,
  MODIFY_CLICKED_SCALE_UNIT = 0.1,
  MODIFY_TICK_LOC_UNIT = 500 / MODIFY_TICK_FRAME_CFG,
  MODIFY_CLICKED_LOC_UNIT = 100,
  PLACE_Z_OFFSET = 0,
  CROSS_HAIR_CHECK_INTERVAL = 0.1,
  CROSS_HAIR_CHECK_DISTANCE = 2000,
  CROSS_HAIR_CHECK_SELECTED_OUTLINE_COLOR = FLinearColor(0.090842, 0.093059, 0.879622, 1),
  CROSS_HAIR_CHECK_SELECTED_OUTLINE_THICKNESS = 1,
  SECTOR_CHECK_INTERVAL = 0.1,
  SECTOR_CHECK_DISTANCE = 2010,
  SECTOR_CHECK_ANGLE = 60,
  SECTOR_CHECK_DISTANCE_FACTOR = 1,
  SECTOR_CHECK_ANGLE_FACTOR = 1,
  EDITOR_MODE_RELIEVE_BATCH_ADD_DISTANCE = 100,
  EDITOR_MODE_RE_BATCH_ADD_DISTANCE = 400,
  EDITOR_MODE_MODIFY_CHANGE_DISTANCE = 20,
  RotatingShafEnum = {
    Pitch = 0,
    Yaw = 1,
    Roll = 2,
    Max = 3
  },
  ModifingPropertyEnum = {
    None = 0,
    Location = 1,
    Rotation = 2,
    Scale = 3
  },
  ModifingAxisEnum = {
    X = 0,
    Y = 1,
    Z = 2,
    All = 3,
    Count = 4
  },
  ParameterEditTabEnum = {
    All = 0,
    Change = 1,
    Base = 2,
    Channel = 3,
    Advanced = 4,
    Function = 5,
    Event = 6,
    ObjectBase = 7,
    Obby = 8,
    Destructible = 9,
    Push = 10,
    Pickup = 11,
    DestructibleMesh = 12,
    PresetAttribute = 13,
    MaterialEdit = 14,
    Add = 99
  },
  ParameterEditTag = {
    Basic = 1,
    Transform = 2,
    Appearance = 3,
    Data = 4,
    Logic = 5,
    MonsterData = 6,
    BasicSkill = 7,
    AdvancedSkill = 8,
    Custom = 9,
    Others = 10
  },
  SNAP_BASE_LEN = 400,
  SNAP_SPLIT_COUNT_MAX = 32,
  SnapModeEnum = {
    SnapSpace = 0,
    SnapObject = 1,
    SnapModeCount = 2
  },
  FreeViewModeType = {Free = 1, Top = 2},
  TransformEditTypeWidgetNameArray = {
    [2] = {
      "Unselected_Rotation",
      "Selected_Rotation",
      "Button_Rotation"
    },
    [3] = {
      "Unselected_Zoom",
      "Selected_Zoom",
      "Button_Zoom"
    },
    [1] = {
      "Unselected_Distance",
      "Selected_Distance",
      "Button_Distance"
    }
  },
  TransformAxisEditTypeWidgetNameArray = {
    [2] = {
      "UnselectedR",
      "SelectedR"
    },
    [3] = {
      "UnselectedS",
      "SelectedS"
    },
    [1] = {
      "UnselectedL",
      "SelectedL"
    }
  },
  RotateModifingAxisWidgetNameArray = {
    [0] = {
      "Unselected_Y",
      "Selected_Y",
      "Button_Y"
    },
    [1] = {
      "Unselected_Z",
      "Selected_Z",
      "Button_Z"
    },
    [2] = {
      "Unselected_X",
      "Selected_X",
      "Button_X"
    },
    [3] = {
      "Unselected_ALL",
      "Selected_ALL",
      "Button_ALL"
    }
  },
  ScaleModifingAxisWidgetNameArray = {
    [0] = {
      "Unselected_X",
      "Selected_X",
      "Button_X"
    },
    [1] = {
      "Unselected_Y",
      "Selected_Y",
      "Button_Y"
    },
    [2] = {
      "Unselected_Z",
      "Selected_Z",
      "Button_Z"
    },
    [3] = {
      "Unselected_ALL",
      "Selected_ALL",
      "Button_ALL"
    }
  },
  BUILDING_SCALE_MAX_LEN = 800,
  BUILDING_SCALE_MIN_LEN = 50,
  BUILDING_GRID_MIN_LEN = 50,
  BUILDING_GRID_1M_LEN = 100,
  BUILDING_GRID_2M_LEN = 200,
  BUILDING_GRID_USE_SPLIT = 151,
  SNAP_BASE_DISTANCE = 200,
  SNAP_DISTANCE_PRIORITY_MAX = 100,
  SNAP_LAST_BUILD_FACTOR = 1.2,
  DEFAULT_SHORTCUT_BAR_DATA_CONFIG = {
    3101001,
    3101027,
    3101003,
    3101004,
    3101039
  },
  MAX_SCREENSHOT = 6,
  MAX_GROUP_CHILDREN_NUM = 300,
  EditObjectTransfromEnum = {
    Disabled = 0,
    Rotaion = 1,
    RotaionPitch = 2,
    RotaionYaw = 3,
    RotaionRoll = 4,
    Scale = 5,
    ScaleX = 6,
    ScaleY = 7,
    ScaleZ = 8,
    ScaleAll = 9,
    Move = 10,
    All = 11
  },
  EditObjectTransfromDirectionEnum = {
    ScaleAdd = 0,
    ScaleSub = 1,
    RotationAdd = 0,
    RotationSub = 1
  },
  UserSliderOperation = {Increase = 1, Decrease = -1},
  EDIT_OBJECT_TRANSFORM_SCALE_UNIT = 0.01,
  EDIT_OBJECT_TRANSFORM_ROTATE_UNIT = 0.1,
  EDIT_OBJECT_TRANSFORM_MOVE_UNIT = 1,
  EDIT_OBJECT_TRANSFORM_MOVE_ROTATOIN_JUDGE_DEGREE = 45,
  EDIT_OBJECT_TRANSFORM_SCALE_UPPER_LIMIT = 3,
  EDIT_OBJECT_TRANSFORM_SCALE_LOWER_LIMIT = 0.1,
  EDIT_OBJECT_TRANSFORM_MOVE_ROTATOIN_JUDGE_DISTANCE = 50,
  EDIT_OBJECT_TRANSFORM_PUSH_UPPER_LIMIT = 2500,
  EDIT_OBJECT_TRANSFORM_PULL_LOWER_LIMIT = 500,
  EDIT_OBJECT_ROTATION_LIMIT = 360,
  FixedMaterialTag = "AxisStaticMeshesComponent",
  OccupationAreaDirectionList = {
    "Left",
    "Right",
    "Bottom",
    "Up",
    "Middle"
  },
  OccupationAreaColorList = {
    "white",
    "blue",
    "red"
  },
  MapSaveCD = 60000,
  MapInitSaveCD = 20000
}
CreativeModeEditCfg.EditStateEnum = CreativeGlobalDefine.EditModeUIStateEnum
CreativeModeEditCfg.SwitchBattleUIBtnIcon = {
  [CreativeModeEditCfg.EditStateEnum.Editing] = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_SwitchEdit_png.ZD_icon_SwitchEdit_png",
  [CreativeModeEditCfg.EditStateEnum.Playing] = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_SwitchBattles_png.ZD_icon_SwitchBattles_png"
}
CreativeModeEditCfg.SwitchModifyAxisBtnIcon = {
  [CreativeModeEditCfg.ModifingAxisEnum.All] = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Zooming_png.ZD_icon_Zooming_png",
  [CreativeModeEditCfg.ModifingAxisEnum.X] = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_X_Magnify_png.ZD_icon_X_Magnify_png",
  [CreativeModeEditCfg.ModifingAxisEnum.Y] = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Y_Magnify_png.ZD_icon_Y_Magnify_png",
  [CreativeModeEditCfg.ModifingAxisEnum.Z] = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Z_Magnify_png.ZD_icon_Z_Magnify_png"
}
CreativeModeEditCfg.RotatingBtnIcon = {
  [CreativeModeEditCfg.RotatingShafEnum.Roll] = {
    SwitchBtnIcon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Y_Axis_png.ZD_icon_Y_Axis_png",
    RightRotationBtn = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Clockwise_Y_png.ZD_icon_Clockwise_Y_png",
    LeftRotationBtn = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Anticlockwise_Y_png.ZD_icon_Anticlockwise_Y_png"
  },
  [CreativeModeEditCfg.RotatingShafEnum.Yaw] = {
    SwitchBtnIcon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Z_Axis_png.ZD_icon_Z_Axis_png",
    RightRotationBtn = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Clockwise_Z_png.ZD_icon_Clockwise_Z_png",
    LeftRotationBtn = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Anticlockwise_Z_png.ZD_icon_Anticlockwise_Z_png"
  },
  [CreativeModeEditCfg.RotatingShafEnum.Pitch] = {
    SwitchBtnIcon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_X_Axis_png.ZD_icon_X_Axis_png",
    RightRotationBtn = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Clockwise_X_png.ZD_icon_Clockwise_X_png",
    LeftRotationBtn = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Anticlockwise_X_png.ZD_icon_Anticlockwise_X_png"
  }
}
CreativeModeEditCfg.Enum_EventBindingChangeType = {
  RemoveNode = 0,
  AddNode = 1,
  ChangeNode = 2
}
CreativeModeEditCfg.SetInstanceDataContentTime = 6.0
CreativeModeEditCfg.Enum_InstanceEditCommandType = {
  InstanceAdd = 0,
  InstanceRemove = 1,
  InstanceChange = 2,
  InstanceParameterChange = 3,
  CreateGroup = 4,
  RelieveGroup = 5,
  ChildrenChange = 6,
  GroupReName = 7,
  EmpowerBuild = 8,
  DisempowerBuild = 9,
  InstanceReName = 10,
  DisempowerBuildAndRelieveGroup = 11,
  CustomUIDragInGroupPanel = 12,
  PresetApply = 13,
  EditVMBatchChange = 14
}
CreativeModeEditCfg.Enum_SkillEditCommandType = {
  NodeAdd = 1,
  NodeRemove = 2,
  NodeChange = 3,
  TrackAdd = 4,
  TrackRemove = 5,
  TrackChange = 6
}
CreativeModeEditCfg.Enum_MultiSelectShowType = {
  ForceState = 0,
  MultiMode = 1,
  GroupEditMode = 2,
  Max = 2
}
CreativeModeEditCfg.bIgnoreZSnap = false
CreativeModeEditCfg.FreeViewHeight = 28800
CreativeModeEditCfg.FreeViewHeightStep = 12.5
CreativeModeEditCfg.FreeViewHeightChangeStep = CreativeModeEditCfg.FreeViewHeightStep / CreativeModeEditCfg.FreeViewHeight
CreativeModeEditCfg.Enum_ButtonType = {
  CreatorSetting = 1,
  GlobalManagement = 2,
  DemoSetting = 3,
  Setting = 4,
  TeamEdit = 5,
  Camera = 6,
  Help = 7,
  VisualPrograming = 8,
  GenerateContent = 9,
  CustomUI = 10,
  CustomSkill = 11,
  Copilot = 12,
  PresetManagement = 13,
  GameTaskManagement = 14,
  PrefabMall = 15,
  PropShop = 16
}
CreativeModeEditCfg.FirstMoreBtn = {
  CreativeModeEditCfg.Enum_ButtonType.CreatorSetting,
  CreativeModeEditCfg.Enum_ButtonType.GlobalManagement,
  CreativeModeEditCfg.Enum_ButtonType.DemoSetting,
  CreativeModeEditCfg.Enum_ButtonType.TeamEdit,
  CreativeModeEditCfg.Enum_ButtonType.Setting,
  CreativeModeEditCfg.Enum_ButtonType.Camera,
  CreativeModeEditCfg.Enum_ButtonType.Help
}
CreativeModeEditCfg.AdvanceMoreBtn = {
  CreativeModeEditCfg.Enum_ButtonType.Copilot,
  CreativeModeEditCfg.Enum_ButtonType.GenerateContent
}
CreativeModeEditCfg.SecondMoreBtn = {
  CreativeModeEditCfg.Enum_ButtonType.VisualPrograming,
  CreativeModeEditCfg.Enum_ButtonType.PresetManagement,
  CreativeModeEditCfg.Enum_ButtonType.PropShop,
  CreativeModeEditCfg.Enum_ButtonType.CustomUI,
  CreativeModeEditCfg.Enum_ButtonType.CustomSkill,
  CreativeModeEditCfg.Enum_ButtonType.GameTaskManagement
}
CreativeModeEditCfg.CooperateMoreBtn = {
  CreativeModeEditCfg.Enum_ButtonType.PrefabMall
}
CreativeModeEditCfg.AdvanceEdit = {
  [CreativeModeEditCfg.Enum_ButtonType.VisualPrograming] = true
}
CreativeModeEditCfg.MoreBtnConfig = {
  [CreativeModeEditCfg.Enum_ButtonType.CreatorSetting] = {
    Title = 8500158,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Parameter01_png.ZD_icon_Parameter01_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      return CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.EditSetting)
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.GlobalManagement] = {
    Title = 8400003,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_Manage_png.ZD_Icon_Manage_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      if not CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.GlobalManager) then
        return false
      end
      local CreativeModeTeamEditDefine = require("GameLua.Mod.CreativeBase.Gameplay.TeamEdit.CreativeModeTeamEditDefine")
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uPlayerCtrl = GameplayData.GetPlayerController()
      return slua.isValid(uPlayerCtrl) and uPlayerCtrl.TeamEditFeature:HasAccessibility(CreativeModeTeamEditDefine.AccessControlType.GameParameterRead)
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.DemoSetting] = {
    Title = 8500591,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_Game_4_png.ZD_Icon_Game_4_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      return CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.EditSetting)
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.Setting] = {
    Title = 9413,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Set_png.ZD_icon_Set_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      return CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.GameSetting)
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.TeamEdit] = {
    Title = 8500928,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_TeamSetup_1_png.ZD_Icon_TeamSetup_1_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      if not CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.EditSetting) then
        return false
      end
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor()
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.Camera] = {
    Title = 34428,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Screenshot_png.ZD_icon_Screenshot_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      if not CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.ScreenShot) then
        return false
      end
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor()
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.Help] = {
    Title = 4539,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Help_png.ZD_icon_Help_png",
    Condition = function()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsBLUEHOLE() then
        return false
      end
      return true
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.Copilot] = {
    Title = 97000032,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_SmartAssistant_png.ZD_Icon_SmartAssistant_png",
    Condition = function()
      local UGC_Assistant_Define = require("client.slua.umg.ugc.creator.center.UGC_Assistant_Define")
      return UGC_Assistant_Define.CheckAssistantAvaliable()
    end,
    RedDotFunc = function()
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      local RedDotData = LogicUGCAuthor:RefreshAiCopilotRedDotData()
      if RedDotData and 0 < RedDotData then
        return true
      end
      return false
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.PresetManagement] = {
    Title = 8700280,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Preset_png.ZD_icon_Preset_png",
    Condition = function()
      local CreativeModeEditMainCtrlSubSystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
      if not CreativeModeEditMainCtrlSubSystem:GetEditorSwitchForType(CreativeGlobalDefine.Enum_EditorSwitchType.PresetManager) then
        return false
      end
      local CreativeModeTeamEditDefine = require("GameLua.Mod.CreativeBase.Gameplay.TeamEdit.CreativeModeTeamEditDefine")
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uPlayerCtrl = GameplayData.GetPlayerController()
      return slua.isValid(uPlayerCtrl) and uPlayerCtrl.TeamEditFeature:HasAccessibility(CreativeModeTeamEditDefine.AccessControlType.GameParameterRead)
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.PrefabMall] = {
    Title = 8880027,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Prefab_png.ZD_icon_Prefab_png",
    Condition = function()
      if LobbySystem.CheckOpen(BP_ENUM_NEW_UGC_PREFAB_MALL_SWITCH) then
        return true
      else
        return false
      end
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.VisualPrograming] = {
    Title = 8500964,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_VisualProgramming_png.ZD_Icon_VisualProgramming_png",
    Condition = function()
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor() and CreativeUtility:CanOpenFunctionVS()
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.GenerateContent] = {
    Title = 8600000,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_IntelligentGeneration_png.ZD_Icon_IntelligentGeneration_png",
    Condition = function()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsBLUEHOLE() then
        return false
      end
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor()
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.CustomUI] = {
    Title = 8700258,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_Icon_CustomUI_png.ZD_Icon_CustomUI_png",
    Condition = function()
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor() and CreativeUtility:CanOpenFunctionVS()
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.CustomSkill] = {
    Title = 8600292,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_CustomSkill_png.ZD_icon_CustomSkill_png",
    Condition = function()
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor()
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.GameTaskManagement] = {
    Title = 8880133,
    Icon = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Task02_png.ZD_icon_Task02_png",
    Condition = function()
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      return CreativeUtility:IsModAuthor()
    end,
    PostClick = function()
      local ActionsConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.EditActionTypesConfig")
      local ActionsType = ActionsConfig.Actions
      local CreativeEditTLogSubsystem = SubsystemMgr:Get("CreativeEditTLogSubsystem")
      CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.GameTaskOpenCount)
    end
  },
  [CreativeModeEditCfg.Enum_ButtonType.PropShop] = {
    Title = 81580,
    Icon = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_icon_MapStore_png.ZD_icon_MapStore_png",
    Condition = function()
      local CreativePropShopConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.CreativePropShopConfig")
      return CreativePropShopConfig.CanEditPropShop()
    end
  }
}
CreativeModeEditCfg.FreeViewArmLength = {Min = 500, Max = 3000}
CreativeModeEditCfg.FreeViewMoveSpeeds = {
  [1] = {Title = 8500179, Value = 0.5},
  [2] = {Title = 8500961, Value = 1},
  [3] = {Title = 8500180, Value = 2},
  [4] = {Title = 8500962, Value = 3},
  [5] = {Title = 8500181, Value = 5}
}
CreativeModeEditCfg.EditMode = {FreeView = 1, TPView = 2}
CreativeModeEditCfg.MAX_BIN_SIZE = 1966080
CreativeModeEditCfg.Enum_BinaryDataContentType = {
  All = 1,
  GameParameterData = 2,
  CodeData = 3,
  PresetData = 4,
  InstanceTree = 5,
  InstanceTree_Logic = 6,
  InstanceTree_Obb = 7,
  InstanceTree_Presetbuilding = 8
}
CreativeModeEditCfg.Enum_ModelPerformance = {
  Low = 1,
  Medium = 2,
  High = 3
}
return CreativeModeEditCfg