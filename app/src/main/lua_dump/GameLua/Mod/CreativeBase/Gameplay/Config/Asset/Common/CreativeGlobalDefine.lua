local CreativeGlobalDefine = {}
CreativeGlobalDefine.NumberMinValue = -2147483648
CreativeGlobalDefine.NumberMaxValue = 2147483647
CreativeGlobalDefine.UnsignedNumberMaxValue = 4294967295
CreativeGlobalDefine.Unsigned64NumberMaxValue = math.maxinteger
CreativeGlobalDefine.SkillSlotMaxNum = 4
CreativeGlobalDefine.DynamicCastSkillSlotMaxNum = 20
CreativeGlobalDefine.Enum_ParameterType = {
  Number = 0,
  Integer = 1,
  String = 2,
  Boolean = 3,
  Array = 4,
  Vector = 5,
  Struct = 6,
  Rotator = 7,
  Map = 8,
  Color = 9,
  Any = 10
}
CreativeGlobalDefine.CanOnlyOverrideParameterTypes = {
  [CreativeGlobalDefine.Enum_ParameterType.Array] = true,
  [CreativeGlobalDefine.Enum_ParameterType.Map] = true,
  [CreativeGlobalDefine.Enum_ParameterType.Struct] = true,
  [CreativeGlobalDefine.Enum_ParameterType.Vector] = true,
  [CreativeGlobalDefine.Enum_ParameterType.Rotator] = true,
  [CreativeGlobalDefine.Enum_ParameterType.Color] = true
}
CreativeGlobalDefine.Enum_ParameterEditType = {
  AccParameterType = 0,
  InputBox = 1,
  OptionBox = 2,
  SwitchBox = 3,
  ProgressBarBox = 4,
  SinglePictureSelect = 5,
  MultiPictureSelect = 6,
  CheckBox = 7,
  NumberInputBox = 8,
  Vector = 9,
  Expression = 10,
  Select = 11,
  Struct = 12,
  Array = 13,
  Hidden = 15,
  DataExpression = 17,
  ConditionExpression = 18,
  VariableSelect = 19,
  ObjectSelect = 20,
  ImageSwitchBox = 21,
  ColorSelect = 22,
  NumberInputKB = 23,
  MultiSelect = 24,
  Custom = 25,
  BindFunction = 26,
  BindEvent = 27,
  ArrayContainer = 28,
  RewardArray = 29,
  SinglePictureSelectWithMultiLevelTab = 30,
  SingleSelectText = 31,
  BooleanSwitchBox = 32
}
CreativeGlobalDefine.FloatPrecision = 1000
CreativeGlobalDefine.Enum_ReviveActorType = {
  PersonalRevive = 0,
  TeamRevive = 1,
  GlobalRevive = 2,
  PersonalReviveTeamMateSurvival = 3,
  UGCLuaCodeCustomRevive = 4
}
CreativeGlobalDefine.Enum_CustomParameterAttributionType = {
  None = -1,
  Player = 0,
  Global = 1
}
CreativeGlobalDefine.Enum_ActiveActiveChoose = {
  None = 0,
  All = 1,
  GameMatching = 2,
  GameReady = 3,
  GameFighting = 4,
  GameStage = 5
}
CreativeGlobalDefine.E_AssetType = {
  LogicObject = 1,
  Building = 2,
  SceneObject = 3,
  PrefabPackage = 4,
  PrefabGroup = 5,
  PrefabBuilding = 6,
  CustomPrefabs = 7,
  ObbyObject = 8,
  CustomUI = 9,
  CustomUIGroup = 10,
  CustomUIPrefab = 11,
  All = 12,
  UserActor = 13,
  CustomModel = 14
}
CreativeGlobalDefine.Enum_AssetType = CreativeGlobalDefine.E_AssetType
CreativeGlobalDefine.ArrayElementParameterNodeKey = "ArrayElementParameterNodeConfig"
CreativeGlobalDefine.MapElementKeyParameterNodeKey = "MapElementKeyParameterNodeConfig"
CreativeGlobalDefine.MapElementValueParameterNodeKey = "MapElementValueParameterNodeConfig"
CreativeGlobalDefine.DefaultStaticMeshGameObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/GameObjects/BP_CreativeMode_StaticMeshObject.BP_CreativeMode_StaticMeshObject_C"
CreativeGlobalDefine.BaseEditorObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/BP_CreativeMode_EditorObject.BP_CreativeMode_EditorObject_C"
CreativeGlobalDefine.DefaultGroupGameObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/GameObjects/BP_GameObject_Group.BP_GameObject_Group_C"
CreativeGlobalDefine.ActorBuildBaseEditorObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/EditorObjects/BP_CreativeEditorObject_ActorBuild.BP_CreativeEditorObject_ActorBuild_C"
CreativeGlobalDefine.ActorBuildBaseGameObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/GameObjects/BP_CreativeGameObject_ActorBuild.BP_CreativeGameObject_ActorBuild_C"
CreativeGlobalDefine.DefaultDestructibleMeshObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/GameObjects/BP_Creative_DestructibleMeshObject.BP_Creative_DestructibleMeshObject_C"
CreativeGlobalDefine.DebugObjectPath = "/Game/Mod/CreativeBase/Arts_PlayerBluePrints/DebugObject/BP_CreativeModeEditorActor_DebugObject.BP_CreativeModeEditorActor_DebugObject_C"
CreativeGlobalDefine.OpenDrawline = false
CreativeGlobalDefine.MaxArrayNum = 30
CreativeGlobalDefine.AssetDependType = {
  LogicDevice = 1,
  BlockyLuaPreset = 2,
  BlockyLuaFunc = 3,
  SkillParam = 4,
  MonsterParam = 5,
  CustomAttribute = 6,
  ModuleTask = 7,
  Talent = 8,
  Script = 9,
  ItemDropParam = 10,
  FakePlayerParam = 11
}
CreativeGlobalDefine.ResType = {
  None = 0,
  Monster = 1,
  Effect = 2,
  Item = 3,
  Vehicle = 4,
  Buff = 5,
  ArmedAI = 6,
  Skill = 7,
  Pickup = 8,
  BankProduct = 9,
  DodgeBall = 10,
  MusicTone = 11,
  BankType = 12,
  Audio = 13,
  AirDrop = 14,
  C4Bomb = 15,
  AIWayPoints = 16,
  DancerType = 17,
  ShootingTargetType = 18,
  Poker = 19,
  ProjectileMeshPreset = 20,
  Cloth = 21,
  Icon = 22,
  Skill_ThrowActor = 23,
  Skill_ThrowMesh = 24,
  Skill_BuildActor = 25,
  Skill_ScreenEffect = 26,
  Skill_CharacterType = 27,
  Skill_CharacterEffect = 28,
  Skill_ScreenShake = 29,
  Skill_Emo = 30,
  Skill_HalfEmo = 31,
  Skill_StaticMesh = 32,
  Skill_WeaponMesh = 33,
  Skill_BindBone = 34,
  Skill_Template = 35,
  Skill_LimitState = 36,
  Skill_BreakState = 37,
  Skill_SoundPlayType = 38,
  Skill_WeaponSlot = 39,
  Skill_UseEnergy = 40,
  Skill_IsSkillGroup = 41,
  Skill_NextPolicy = 42,
  Skill_RangeType = 43,
  Skill_DamageType = 44,
  Skill_SummonType = 45,
  Skill_BuildingAsset = 46,
  Skill_LogicAsset = 47,
  Image = 48,
  Treasure = 49,
  TextShow = 50,
  EnvironmentManager = 51,
  SelectorDevice = 52,
  RandomDevice = 53,
  CustomProgressManager = 54,
  ChatBubble = 55,
  RoleSwitch = 56,
  NPC = 57,
  ProjectilePreset = 58,
  SpecialBuild = 59,
  Decal = 60,
  SpecialWater = 61,
  Other = 62,
  CustomModel = 63
}
CreativeGlobalDefine.ResReferenceType = {
  Instance = 1,
  SkillEditor = 2,
  Code = 3,
  PropShop = 4,
  CustomItem = 5,
  Buff = 6
}
CreativeGlobalDefine.BankProductType = {
  CopperChicken = 1,
  SilverChicken = 2,
  GoldChicken = 3,
  RedFlag = 4,
  GreenFlag = 5,
  BlueFlag = 6,
  Rugby = 7
}
CreativeGlobalDefine.BankType = {
  Empty = 1,
  ChickenCoop = 2,
  Gate = 3
}
CreativeGlobalDefine.DodgeBallType = {
  BladeBall = 1,
  EnergyBladeBall = 2,
  GrenadeBladeBall = 3,
  SandbagBladeBall = 4
}
CreativeGlobalDefine.MusicToneType = {
  Piano = 1,
  Drum = 2,
  Bass = 3,
  Synth1 = 4,
  Synth2 = 5
}
CreativeGlobalDefine.DecalType = {BL = 1}
CreativeGlobalDefine.ObjectEventStructConfig = {
  {
    ParameterName = "InstanceID",
    ParameterType = CreativeGlobalDefine.Enum_ParameterType.Integer,
    DefaultValue = "0",
    MinValue = "0",
    MaxValue = "4294967295",
    ProtoIndexSort = 1
  },
  {
    ParameterName = "FunctionIndex",
    ParameterType = CreativeGlobalDefine.Enum_ParameterType.Integer,
    DefaultValue = "0",
    ProtoIndexSort = 1
  }
}
CreativeGlobalDefine.ObjectAndCustomEventStructConfig = {
  BindEvent = {
    {
      ParameterName = "InstanceID",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.String,
      DefaultValue = "0",
      ProtoIndexSort = 1
    },
    {
      ParameterName = "EventName",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.String,
      DefaultValue = "",
      ProtoIndexSort = 2
    },
    {
      ParameterName = "SignalName",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.String,
      DefaultValue = "",
      ProtoIndexSort = 3
    },
    {
      ParameterName = "BranchKey",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.Integer,
      DefaultValue = "0",
      ProtoIndexSort = 4
    }
  },
  BindFunction = {
    {
      ParameterName = "InstanceID",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.String,
      DefaultValue = "0",
      ProtoIndexSort = 1
    },
    {
      ParameterName = "FunctionIndex",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.Integer,
      DefaultValue = "0",
      ProtoIndexSort = 2
    },
    {
      ParameterName = "SignalName",
      ParameterType = CreativeGlobalDefine.Enum_ParameterType.String,
      DefaultValue = "",
      ProtoIndexSort = 3
    }
  }
}
CreativeGlobalDefine.ObjectEventArrayNodeConfig = {
  ParameterName = CreativeGlobalDefine.ArrayElementParameterNodeKey,
  ParameterType = CreativeGlobalDefine.Enum_ParameterType.Struct,
  DefaultValue = "",
  PrarmeterStruct = CreativeGlobalDefine.ObjectEventStructConfig,
  IsEventArrayNode = true
}
CreativeGlobalDefine.ObjectBranchEventConfig = {
  KeyParameterNode = {
    ParameterName = CreativeGlobalDefine.MapElementKeyParameterNodeKey,
    ParameterType = CreativeGlobalDefine.Enum_ParameterType.Integer,
    MinValue = "0",
    DefaultValue = "0"
  },
  ValueParameterNode = {
    ParameterName = CreativeGlobalDefine.MapElementValueParameterNodeKey,
    ParameterType = CreativeGlobalDefine.Enum_ParameterType.Struct,
    DefaultValue = "",
    PrarmeterStruct = {
      {
        ParameterName = "ReferenceList",
        ParameterType = CreativeGlobalDefine.Enum_ParameterType.Array,
        DefaultValue = "",
        ArrayElementParameterNode = CreativeGlobalDefine.ObjectEventArrayNodeConfig,
        ProtoIndexSort = 1
      }
    }
  },
  IsBranchEventMapNode = true
}
CreativeGlobalDefine.COMPONENT_PARAMETER_KEYS = "ComponentParameterKeys"
CreativeGlobalDefine.EditModeUIStateEnum = {Editing = 0, Playing = 1}
CreativeGlobalDefine.OverridePriority = {
  MIN = 0,
  VERY_LOW = 1,
  LOW = 2,
  MEDIUM_LOW = 3,
  MEDIUM = 4,
  MEDIUM_HIGH = 5,
  HIGH = 6,
  VERY_HIGH = 7,
  Max = 8
}
CreativeGlobalDefine.ActorAttributePriority = {
  GameParameter = CreativeGlobalDefine.OverridePriority.MIN,
  PlayerStart = CreativeGlobalDefine.OverridePriority.VERY_LOW,
  TeamManager = CreativeGlobalDefine.OverridePriority.LOW,
  ActionManager = CreativeGlobalDefine.OverridePriority.LOW,
  UserRuntimeCode = CreativeGlobalDefine.OverridePriority.MEDIUM_LOW
}
CreativeGlobalDefine.InstanceEditSwitchTypeEnum = {
  CrossHairSelected = 0,
  Copy = 1,
  Delete = 2,
  GiveObby = 3,
  SwitchMaterials = 4,
  ParameterEdit = 5,
  Modify = 6,
  SignalSelected = 7,
  DisassembleGroup = 8,
  ChangeGroupChildren = 9,
  CreateCustomPrefab = 10,
  GroupChildrenFocus = 11,
  PlaceInShortBarFromWorld = 12
}
CreativeGlobalDefine.Enum_ObjectState = {
  EditLocked = "EditLocked",
  ParentEditLocked = "ParentEditLocked",
  GroupEditLocked = "GroupEditLocked",
  AIGroupEditLocked = "AIGroupEditLocked",
  PrefabEditLocked = "PrefabEditLocked"
}
CreativeGlobalDefine.ObjectStateToInstanceBlockConfigs = {
  [CreativeGlobalDefine.Enum_ObjectState.EditLocked] = {
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.Copy,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.Delete,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.SwitchMaterials,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.ParameterEdit,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.Modify,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.SignalSelected
  },
  [CreativeGlobalDefine.Enum_ObjectState.ParentEditLocked] = {
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.Copy,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.Delete,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.SwitchMaterials,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.ParameterEdit,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.Modify,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.SignalSelected
  },
  [CreativeGlobalDefine.Enum_ObjectState.GroupEditLocked] = {
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.DisassembleGroup,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.ChangeGroupChildren,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.CreateCustomPrefab,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.GiveObby,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.GroupChildrenFocus,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.PlaceInShortBarFromWorld
  },
  [CreativeGlobalDefine.Enum_ObjectState.AIGroupEditLocked] = {
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.DisassembleGroup,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.ChangeGroupChildren,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.GroupChildrenFocus,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.CreateCustomPrefab
  },
  [CreativeGlobalDefine.Enum_ObjectState.PrefabEditLocked] = {
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.DisassembleGroup,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.ChangeGroupChildren,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.CreateCustomPrefab,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.GroupChildrenFocus,
    CreativeGlobalDefine.InstanceEditSwitchTypeEnum.PlaceInShortBarFromWorld
  }
}
CreativeGlobalDefine.Enum_UndoRedoCommandType = {
  Scene = 0,
  Skill = 1,
  UI = 2
}
CreativeGlobalDefine.Enum_EditorSwitchType = {
  TopSettingPanel = 0,
  GameParameterEdit = 1,
  EditSetting = 2,
  ScreenShot = 3,
  GlobalManager = 4,
  BattleUISwitch = 5,
  DebugGame = 6,
  SignOutBtn = 7,
  SaveBtn = 9,
  NomalBtn = 10,
  PresetManager = 11,
  UnDoReDo = 8,
  RightTopPanel = 20,
  MiniMap = 21,
  GameSetting = 22,
  ObjectManager = 23,
  DebugGameLog = 24,
  VoiceUI = 25,
  LeftTopPanel = 40,
  FreeViewMode = 41,
  SnapGrid = 42,
  GroupEdit = 43,
  MultiSelect = 44,
  RightBottomPanel = 60,
  FlyBtn = 61,
  GroupSelectTypeBtn = 62,
  RightBackpackBtn = 63,
  PlacingPanel = 64,
  TowPlacing = 65,
  BottomSettingPanel = 80,
  ObjectBackpack = 81,
  ShortcutTab = 82,
  QuickAddShortcut = 83,
  CameraPreviewExit = 100,
  BackpackBanCommonType = 200,
  BackpackOpenCloseBtn = 201,
  BattleMiscs = 300,
  CopilotIcon = 400
}
CreativeGlobalDefine.Enum_ObjectGroupTag = {Text = 1, TempGroup = 2}
CreativeGlobalDefine.Enum_MsgRecvPlayerType = {
  AllPlayer = 0,
  MsgTriggerPlayer = 1,
  MsgTriggerTeam = 2,
  AllEnemy = 3,
  TargetPlayer = 4,
  TargetTeam = 5
}
CreativeGlobalDefine.Enum_UGCPawnType = {
  FakePlayer = 1,
  HumanEnemy = 2,
  Tower = 3,
  Monster = 4
}
CreativeGlobalDefine.Enum_BlockyLuaErrorType = {
  None = 1,
  Info = 2,
  Warning = 3,
  Error = 4,
  EditorWarning = 5,
  EditorError = 6,
  EditorDirtyWord = 7
}
CreativeGlobalDefine.ACESceneId = {
  Default = 133,
  BillboardAuditText = 135,
  Interaction = 145,
  ChatBubble = 146,
  VisualCodeAuditText = 1025,
  CustomUI = 152,
  WoWTaskName = 162,
  WoWTaskDesc = 163,
  WoWTaskStageName = 167,
  WoWTaskProcessName = 168,
  WoWTaskRewardName = 169,
  WoWTaskJumpDesc = 170,
  TalentTitle = 172,
  TalentDesc = 173,
  AIGCAssetName_Ani = 176,
  AIGCAssetName_Mod = 164,
  CustomUIPrefabName = 178,
  CustomUIPrefabDesc = 179,
  PropShopPropName = 3031,
  PropShopPropDesc = 3032,
  PropShopShopName = 3033
}
CreativeGlobalDefine.TimerCntType = {Ascending = 0, Descending = 1}
CreativeGlobalDefine.EnvironmentParam = {
  LightIntensity = 1,
  LightColor = 2,
  DirLightPitch = 3,
  DirLightYaw = 4,
  SkyLightIntensity = 5
}
CreativeGlobalDefine.CollisionType = {Default = 0, Ignore_Vehicle_Vehicle = 1}
CreativeGlobalDefine.PlayerClientEditorState = {Active = 1, Idle = 2}
CreativeGlobalDefine.AssignItemReason = {Nil = -1, InitialEquip = 0}
CreativeGlobalDefine.GameParameterTypeEnum = {
  Default = 0,
  CustomUIEdit = 1,
  PersonalCreationSetting = 2,
  MonsterSetting = 3,
  FakePlayerSetting = 4,
  CustomSkillEdit = 5,
  CustomSkillNodeEdit = 6,
  GameTaskAcquisitionSettingsEdit = 7,
  GameTaskProcessSettingsEdit = 8,
  GameTaskGuidePointSetting = 9,
  CustomWeaponEdit = 10,
  GameTaskStageInfoEdit = 11,
  GameTaskEventActionEdit = 12,
  GameTaskPrecondition = 13,
  GameTaskRewardItem = 14,
  CustomItemsSetting = 15,
  Talent = 16,
  PropShop = 17,
  Talent_PopUpEdit = 18,
  CustomUIEdit_MultiSelect = 19,
  CustomUIEdit_AdaptationEdit = 20
}
CreativeGlobalDefine.ShapeTypeEnum = {
  Sphere = 0,
  Box = 1,
  Cylinder = 2
}
CreativeGlobalDefine.CharacterTypeEnum = {
  All = 0,
  PlayerCharacter = 1,
  MonsterCharacter = 2,
  FakePlayerCharacter = 3
}
CreativeGlobalDefine.CustomCodePresetValidAssetIds = {
  [3101112] = true,
  [3101114] = true,
  [3101115] = true,
  [3101116] = true
}
CreativeGlobalDefine.AssetParamExpiredState = {
  NotLimited = 1,
  LimitedButNotExpired = 2,
  Expired = 3
}
CreativeGlobalDefine.MonsterOffcialCodePlanList = {
  {
    CodePlanID = 0,
    ShowName = 18710022,
    Desc = 18710001,
    CanSelect = true,
    Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/BlockyluaTexture/TemplateGraph/LevelTemplate/TemplateGraph_Image_MonsterLevelTemplate.TemplateGraph_Image_MonsterLevelTemplate"
  },
  {
    CodePlanID = 1,
    ShowName = 17005112,
    Desc = 18710002,
    CanSelect = false,
    Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/BlockyluaTexture/TemplateGraph/LevelTemplate/TemplateGraph_Image_MonsterBlankTemplate.TemplateGraph_Image_MonsterBlankTemplate"
  }
}
CreativeGlobalDefine.ArmedAIOffcialCodePlanList = {
  {
    CodePlanID = 0,
    ShowName = 18710022,
    Desc = 18710003,
    CanSelect = true,
    Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/BlockyluaTexture/TemplateGraph/LevelTemplate/TemplateGraph_Image_ArmedAILevelTemplate.TemplateGraph_Image_ArmedAILevelTemplate"
  },
  {
    CodePlanID = 1,
    ShowName = 17005112,
    Desc = 18710004,
    CanSelect = false,
    Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/BlockyluaTexture/TemplateGraph/LevelTemplate/TemplateGraph_Image_ArmedAIBlankTemplate.TemplateGraph_Image_ArmedAIBlankTemplate"
  }
}
CreativeGlobalDefine.GameTaskSystem_ArrayItemType = {
  None = 0,
  Item = 1,
  Plus = 2
}
CreativeGlobalDefine.GameTaskSystem_RewardType = {
  Item = 0,
  Skill = 1,
  Buff = 2,
  Character = 3,
  Player = 4,
  Custom = 5
}
CreativeGlobalDefine.PANEL_TYPE = {
  SingleSelect = 0,
  CustomItems = 1,
  Monster = 2,
  CustomFakePlayer = 3,
  CustomBuff = 4,
  CustomSkill = 5,
  CustomWeapon = 6,
  Preset = 7,
  ParamEditEventTab = 8,
  ParamEditFunctionTab = 9,
  CameraDevicePreview = 10,
  ItemDrop = 11
}
return CreativeGlobalDefine