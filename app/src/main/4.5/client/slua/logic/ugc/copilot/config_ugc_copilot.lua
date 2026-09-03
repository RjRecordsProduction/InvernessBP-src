local Config_UGC_Copilot = {
  bForceOpenDebugMode = false,
  DefaultRandomPromptCount = 3,
  DefaultModGenNameLength = 50,
  DefaultRetryCount = 3,
  UIGenProgressDuration = 250,
  ChatRateLimitMock = {
    Enable = false,
    TaskType = "task_ui",
    CurrentUsage = 10,
    MaxUsage = 10,
    Reason = "ui_usage_limit",
    NextAvailableTime = nil
  }
}
local CreateEditActionTypes = function(keyMap)
  return setmetatable({}, {
    __index = function(self, key)
      local actionKey = keyMap[key]
      if not actionKey then
        return nil
      end
      local ok, cfg = pcall(require, "GameLua.Mod.CreativeBase.Gameplay.Config.EditActionTypesConfig")
      if ok and cfg.Actions then
        local val = cfg.Actions[actionKey]
        rawset(self, key, val)
        return val
      end
      return nil
    end
  })
end
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
Config_UGC_Copilot.Enum_Copilot_RoleType = {
  Assistant = "assistant",
  User = "user",
  System = "system"
}
Config_UGC_Copilot.Enum_UGC_LLM_State = {
  INIT = "init",
  IDLE = "idle",
  COLLECTING_CONTEXT = "collecting_context",
  NEW_CHAT_PENDING = "new_chat_pending",
  STREAMING = "streaming",
  HISTORY_LOADING = "history_loading",
  ERROR = "error",
  INITIALIZING = "initializing",
  LONG_TASK_RUNNING = "long_task"
}
Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode = {
  ERR_CONCURRENT_REQUEST = 4001,
  ERR_INVALID_TRANSITION = 4002,
  ERR_TIMEOUT = 4003,
  ERR_STALE_RESPONSE = 4004,
  ERR_INIT_FAILED = 4005,
  ERR_HISTORY_LOAD_FAILED = 4006,
  ERR_INIT_FAILED = 4007,
  ERR_OUT_OF_QUOTA = 4008,
  ERR_NOT_INITED = 4009,
  ERR_MESSAGE_TOO_LONG = 4010,
  ERR_NETWORK = 4011
}
Config_UGC_Copilot.Enum_UGC_LLM_RequestSceneID = {
  Fight = 0,
  NonFight = 1,
  WoWEditor = 2
}
Config_UGC_Copilot.Enum_UGC_System_Msg = {
  START_NEW_CHAT = 17005212,
  OUT_OF_QUOTA = 8801018,
  STOP_NOW_CHAT = 8801017,
  REPORTED_CHAT = 97000023,
  FORBIDDEN_CHAT = 97000030
}
Config_UGC_Copilot.ExitConfirm = {
  DefaultTitleResID = 101001,
  DefaultContentResID = 2026060801,
  BySubscene = {}
}
function Config_UGC_Copilot.GetExitConfirmConfig(subsceneID)
  if subsceneID == nil then
    return nil
  end
  local cfg = Config_UGC_Copilot.ExitConfirm.BySubscene[subsceneID]
  if not cfg then
    return nil
  end
  if cfg == true then
    cfg = {}
  end
  return {
    TitleResID = cfg.TitleResID or Config_UGC_Copilot.ExitConfirm.DefaultTitleResID,
    ContentResID = cfg.ContentResID or Config_UGC_Copilot.ExitConfirm.DefaultContentResID
  }
end
Config_UGC_Copilot.Copilot_Consts = {
  MAX_MSG_CHAR_CNT_CHAT = 300,
  MAX_MSG_CHAR_CNT_BLOCKY_LUA_EDIT = 450,
  MAX_MESSAGES_PER_CHAT = 15
}
function Config_UGC_Copilot.GetMaxMsgCharCntChat()
  local fallbackMaxCharLength = Config_UGC_Copilot.Copilot_Consts.MAX_MSG_CHAR_CNT_CHAT
  local dataTable = rawget(_G, "CDataTable")
  if dataTable == nil or dataTable.GetTableData == nil then
    return fallbackMaxCharLength
  end
  local sysCfg = dataTable.GetTableData("SystemConfig", "UgcHelperUtf8LenMax")
  local maxCharLength = sysCfg and tonumber(sysCfg.ConfigValue) or nil
  if maxCharLength == nil or maxCharLength == 0 then
    return fallbackMaxCharLength
  end
  return maxCharLength
end
Config_UGC_Copilot.Enum_QuickCardCommand = {
  AudioGen = 1,
  PrimitiComboGen = 2,
  SkeletalAnimaGen = 3,
  PixelWordGen = 4,
  BuildingGen = 5,
  SceneEdit = 6,
  BlockyLuaEdit = 7,
  UIGen = 8
}
Config_UGC_Copilot.Enum_ChatSceneId = {
  SkeletalAnimaGen = 1,
  PrimitiComboGen = 2,
  AudioGen = 3,
  PixelModelGenByImage = 4,
  SimpleModelGenByImage = 5,
  SceneEdit = 101,
  BlockyLuaEdit = 102,
  UIGen = 103,
  BlockyLuaEditWithoutJson = 104,
  pilot = 1000
}
local _NormalizeUIGenPrecheckData = function(data)
  if not data or not data.gen_precheck then
    return
  end
  local genPrecheck = data.gen_precheck
  local genType = genPrecheck.gen_type
  local subscene = data.subscene or genPrecheck.subscene
  local subsceneId = tonumber(subscene) or subscene
  local bIsUIGen = genType == Config_UGC_Copilot.Enum_Copilot_MessageType.ChatUIDsl or genType == "task_ui" or subsceneId == Config_UGC_Copilot.Enum_ChatSceneId.UIGen or subsceneId == Config_UGC_Copilot.Enum_ChatSceneId.pilot
  if not bIsUIGen then
    return
  end
  genPrecheck.gen_type = Config_UGC_Copilot.Enum_Copilot_MessageType.ChatUIDsl
  genPrecheck.predict_duration = tonumber(genPrecheck.predict_duration) or Config_UGC_Copilot.UIGenProgressDuration
end
Config_UGC_Copilot.ExclusiveChatScenes = {
  [Config_UGC_Copilot.Enum_ChatSceneId.SceneEdit] = true,
  [Config_UGC_Copilot.Enum_ChatSceneId.BlockyLuaEdit] = true,
  [Config_UGC_Copilot.Enum_ChatSceneId.pilot] = true
}
Config_UGC_Copilot.ExitConfirm.BySubscene[Config_UGC_Copilot.Enum_ChatSceneId.pilot] = true
Config_UGC_Copilot.Enum_StopChatReason = {
  UserStop = 1,
  AssetCheckFailed = 2,
  SwitchToPlayMode = 3,
  Reconnect = 4
}
Config_UGC_Copilot.StopChatReasonToServerReason = {
  [1] = 1,
  [2] = 2,
  [3] = 1,
  [4] = 1
}
Config_UGC_Copilot.AutoStopOnInitGameScenes = {
  [Config_UGC_Copilot.Enum_ChatSceneId.SceneEdit] = true
}
function Config_UGC_Copilot.ShouldAutoStopOnInitGame(subsceneID)
  if not subsceneID then
    return false
  end
  return Config_UGC_Copilot.AutoStopOnInitGameScenes[subsceneID] == true
end
Config_UGC_Copilot.SubsceneOnStopConfig = {
  [Config_UGC_Copilot.Enum_ChatSceneId.SceneEdit] = {
    OnStop = function(TraceID, subsceneID)
      log(bWriteLog and string.format("SubsceneOnStopConfig.SceneEdit.OnStop: TraceID=%s, subsceneID=%s", tostring(TraceID), tostring(subsceneID)))
      if TraceID then
        Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_GEN, Config_UGC_Copilot.EnumServerGenErrorCode.UserStopped, Config_UGC_Copilot.ErrorOutputType.CHAT, {
          traceId = TraceID,
          hideFeedback = true,
          hideMessageBG = false,
          clearContent = true
        })
      end
    end
  },
  [Config_UGC_Copilot.Enum_ChatSceneId.BlockyLuaEdit] = {
    OnStop = function(TraceID, subsceneID)
      log(bWriteLog and string.format("SubsceneOnStopConfig.BlockyLuaEdit.OnStop: TraceID=%s, subsceneID=%s", tostring(TraceID), tostring(subsceneID)))
      if TraceID then
        Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_GEN, Config_UGC_Copilot.EnumServerGenErrorCode.UserStopped, Config_UGC_Copilot.ErrorOutputType.CHAT, {
          traceId = TraceID,
          hideFeedback = true,
          hideMessageBG = false,
          clearContent = true
        })
      end
    end
  },
  [Config_UGC_Copilot.Enum_ChatSceneId.UIGen] = {
    OnStop = function(TraceID, subsceneID)
      log(bWriteLog and string.format("SubsceneOnStopConfig.UIGen.OnStop: TraceID=%s, subsceneID=%s", tostring(TraceID), tostring(subsceneID)))
      if TraceID then
        Config_UGC_Copilot.OutputError(Config_UGC_Copilot.ErrorSource.SERVER_GEN, Config_UGC_Copilot.EnumServerGenErrorCode.UserStopped, Config_UGC_Copilot.ErrorOutputType.CHAT, {
          traceId = TraceID,
          hideFeedback = true,
          hideMessageBG = false,
          clearContent = true
        })
      end
    end
  }
}
Config_UGC_Copilot.Enum_ButtomUIWidgetIndexType = {
  SkeletalAnimaGen = 2,
  AudioGen = 3,
  PrimitiComboGen = 4,
  SceneEdit = 5,
  BlockyLuaEdit = 6,
  UIGen = 7
}
Config_UGC_Copilot.Enum_Copilot_AssetSavingType = {
  Error = -1,
  ToSave = 0,
  Saving = 1,
  HasSaved = 2
}
Config_UGC_Copilot.Enum_Copilot_GetAssetRspType = {
  Success = 0,
  URL_Error = 1,
  Download_Error = 2,
  Data_Error = 3
}
Config_UGC_Copilot.Enum_ContentClearReason = {Default = 0, OnStop = 1}
function Config_UGC_Copilot.CreateContentSegment(segmentType, content, role, extraFields)
  local segment = {
    type = segmentType,
    content = content,
    role = role or Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant
  }
  if extraFields then
    for k, v in pairs(extraFields) do
      segment[k] = v
    end
  end
  return segment
end
Config_UGC_Copilot.QuickCardConfig = {
  [Config_UGC_Copilot.Enum_QuickCardCommand.PrimitiComboGen] = {
    TitleResFormat = "97000011",
    WidgetIndex = Config_UGC_Copilot.Enum_ButtomUIWidgetIndexType.PrimitiComboGen,
    IconPath = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Smart_Assistant_PopIcon_AssemblyModel_png.Smart_Assistant_PopIcon_AssemblyModel_png",
    Condition = function()
      return IsEditor or LobbySystem.CheckOpen(BP_ENUM_WOW_INNER_ASSIST_COMBINE_MERGE)
    end,
    SortWeight = 3,
    TLogKey = "PrimitiComboGen"
  },
  [Config_UGC_Copilot.Enum_QuickCardCommand.SkeletalAnimaGen] = {
    TitleResFormat = "97000010",
    WidgetIndex = Config_UGC_Copilot.Enum_ButtomUIWidgetIndexType.SkeletalAnimaGen,
    IconPath = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Smart_Assistant_PopIcon_Motion_png.Smart_Assistant_PopIcon_Motion_png",
    Condition = function()
      return IsEditor or LobbySystem.CheckOpen(BP_ENUM_WOW_INNER_ASSIST_ACTION_GEN)
    end,
    SortWeight = 4,
    TLogKey = "SkeletalAnimaGen"
  },
  [Config_UGC_Copilot.Enum_QuickCardCommand.SceneEdit] = {
    TitleResFormat = "97001073",
    WidgetIndex = Config_UGC_Copilot.Enum_ButtomUIWidgetIndexType.SceneEdit,
    JumpFunc = function()
    end,
    IconPath = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Smart_Assistant_Poplcon_SceneEdit_png.Smart_Assistant_Poplcon_SceneEdit_png",
    Condition = function()
      if IsEditor then
        return true
      end
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot then
        return Logic_UGC_Copilot:IsLLMSceneEditEnabled()
      end
      return false
    end,
    bIsDemo = true,
    TLogKey = "SceneEdit",
    SortWeight = 2
  },
  [Config_UGC_Copilot.Enum_QuickCardCommand.BlockyLuaEdit] = {
    TitleResFormat = "8889007",
    WidgetIndex = Config_UGC_Copilot.Enum_ButtomUIWidgetIndexType.BlockyLuaEdit,
    JumpFunc = function()
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local dataToSave = {bFirstClick = false}
      PlayerPrefsSystem.SaveTableToFile_N(dataToSave, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotBlockyEdiFristTutorial)
      local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotBlockyAgreement) or {}
      local bShowTips = data.bShowTips
      local WELCOME_TIP_TRACE_ID_PREFIX = "blocky-edit-welcome-"
      local WELCOME_TIP_LOC_ID = 8889008
      local ModuleManager = require("client.module_framework.ModuleManager")
      local LogicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if not (LogicModule and LogicModule.MessageHandler) or not LogicModule.SessionManager then
        print(bWriteLog and "BlockyLuaEdit.JumpFunc - LogicModule not ready, skip welcome tip")
        return
      end
      local ActiveChat = LogicModule.SessionManager.ActiveChat
      if not ActiveChat then
        print(bWriteLog and "BlockyLuaEdit.JumpFunc - ActiveChat is nil, skip welcome tip")
        return
      end
      if ActiveChat.Messages then
        local PrefixLen = #WELCOME_TIP_TRACE_ID_PREFIX
        for _, Msg in ipairs(ActiveChat.Messages) do
          if Msg.TraceID and string.sub(Msg.TraceID, 1, PrefixLen) == WELCOME_TIP_TRACE_ID_PREFIX then
            print(bWriteLog and "BlockyLuaEdit.JumpFunc - welcome tip already pushed, skip")
            return
          end
        end
      end
      local TipContent = LocUtil.GetLocalizeResStr(WELCOME_TIP_LOC_ID)
      local TraceID = WELCOME_TIP_TRACE_ID_PREFIX .. tostring(os.time())
      LogicModule.MessageHandler:SimulateAIResponse({ret = 0}, nil, TipContent, nil, nil, TraceID, {HideFeedback = true})
      print(bWriteLog and string.format("BlockyLuaEdit.JumpFunc - pushed welcome tip, TraceID: %s", TraceID))
    end,
    IconPath = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Smart_Assistant_PopIcon_AI_png.Smart_Assistant_PopIcon_AI_png",
    Condition = function()
      if IsEditor then
        return true
      end
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot then
        return Logic_UGC_Copilot:IsBlockyluaEditEnabled()
      end
      return false
    end,
    bIsDemo = true,
    TLogKey = "BlockyLuaEdit",
    SortWeight = 0
  },
  [Config_UGC_Copilot.Enum_QuickCardCommand.UIGen] = {
    TitleResFormat = "2026040364",
    WidgetIndex = Config_UGC_Copilot.Enum_ButtomUIWidgetIndexType.UIGen,
    JumpFunc = function()
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local dataToSave = {bFirstClick = false}
      PlayerPrefsSystem.SaveTableToFile_N(dataToSave, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenFirstTutorial)
      local bEnableTipsPopup = false
      if bEnableTipsPopup then
        local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenAgreement) or {}
        local bShowTips = data.bShowTips
        if bShowTips ~= false then
          local CONFIRM_TIPS_TEXT = LocUtil.GetLocalizeResStr(97001201)
          local CHECK_BOX_TEXT = LocUtil.GetLocalizeResStr(8889010)
          local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
          CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, nil, CONFIRM_TIPS_TEXT, function(bIsChecked)
            if bIsChecked then
              PlayerPrefsSystem.SaveTableToFile_N({bShowTips = false}, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenAgreement)
            end
          end, function()
            EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_ON_CLICK_TOPICCARD)
          end, nil, nil, {
            showUIKey = "com_msg_box_slua",
            isShowCheckBox = true,
            checkBoxText = CHECK_BOX_TEXT,
            lockButtonOKBycheckBox = false,
            leftAlign = true
          })
          return
        end
      end
      local WELCOME_TIP_TRACE_ID_PREFIX = "ui-gen-welcome-"
      local WELCOME_TIP_LOC_ID = 2026040366
      local ModuleManager = require("client.module_framework.ModuleManager")
      local LogicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if not (LogicModule and LogicModule.MessageHandler) or not LogicModule.SessionManager then
        print(bWriteLog and "UIGen.JumpFunc - LogicModule not ready, skip welcome tip")
        return
      end
      local ActiveChat = LogicModule.SessionManager.ActiveChat
      if not ActiveChat then
        print(bWriteLog and "UIGen.JumpFunc - ActiveChat is nil, skip welcome tip")
        return
      end
      if ActiveChat.Messages then
        local PrefixLen = #WELCOME_TIP_TRACE_ID_PREFIX
        for _, Msg in ipairs(ActiveChat.Messages) do
          if Msg.TraceID and string.sub(Msg.TraceID, 1, PrefixLen) == WELCOME_TIP_TRACE_ID_PREFIX then
            print(bWriteLog and "UIGen.JumpFunc - welcome tip already pushed, skip")
            return
          end
        end
      end
      local TipContent = LocUtil.GetLocalizeResStr(WELCOME_TIP_LOC_ID)
      local TraceID = WELCOME_TIP_TRACE_ID_PREFIX .. tostring(os.time())
      LogicModule.MessageHandler:SimulateAIResponse({ret = 0}, nil, TipContent, nil, nil, TraceID, {HideFeedback = true})
      print(bWriteLog and string.format("UIGen.JumpFunc - pushed welcome tip, TraceID: %s", TraceID))
    end,
    IconPath = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Smart_Assistant_Poplcon_UIedit_png.Smart_Assistant_Poplcon_UIedit_png",
    Condition = function()
      if IsEditor then
        return true
      end
      if IsWoWEditor then
        return false
      end
      local CreativeUtility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
      if not CreativeUtility:IsModAuthor() then
        return false
      end
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot then
        return Logic_UGC_Copilot:IsUIGenEnabled()
      end
      return false
    end,
    bIsDemo = true,
    TLogKey = "UIGen",
    SortWeight = 1
  }
}
Config_UGC_Copilot.Enum_Copilot_MessageType = {
  Messages = "messages",
  Questions = "questions",
  Citations = "citations",
  Images = "images",
  Image = "image",
  System = "system",
  PrimitiComboGen = "modgen",
  PrimitiComboGenSingle = "modgensingle",
  AnimGen = "mocap",
  GenPrecheck = "gen_precheck",
  InGeneration = "ingen",
  Censoring = "censoring",
  CensoredFailed = "censor_failed",
  CodeBlock = "code_block",
  AudioGen = "audiogen",
  AudioGenSingle = "audiogensingle",
  Interaction = "interaction",
  ModSearch = "search",
  CheckAsset = "check_asset",
  UserRefImage = "user_ref_image",
  VoxelModGen = "voxelmodgen",
  ImgModGen = "imgmodgen",
  BlockyEdit = "blocky_edit",
  ChatUIDsl = "chat_ui_dsl"
}
Config_UGC_Copilot.MessageTypeV2ToEnum = {
  text = Config_UGC_Copilot.Enum_Copilot_MessageType.Messages
}
Config_UGC_Copilot.URLJumpConfig = {
  [Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGen] = {
    JumpFunc = function(AssetKey)
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      local LogicUGCMall = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall")
      UIManager.ShowUI(UIManager.UI_Config.CreativeModePrefabMallPrefabMainUI, Config_UGC.Enum_PrefaMall_ResMgrTagID.MyPrivate, LogicUGCMall.ENUM_PREFAB_TYPE.PREFAB)
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HIDE_MOVABLE_WINDOW)
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.AnimGen] = {
    JumpFunc = function(AssetKey)
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      local LogicUGCMall = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall")
      UIManager.ShowUI(UIManager.UI_Config.CreativeModePrefabMallPrefabMainUI, Config_UGC.Enum_PrefaMall_ResMgrTagID.MyPrivate, LogicUGCMall.ENUM_PREFAB_TYPE.ANIM)
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HIDE_MOVABLE_WINDOW)
    end
  }
}
Config_UGC_Copilot.MessageRspEventTypeEnum = {
  Data = "data",
  Intent = "intent",
  Hint = "hint",
  Error = "error",
  Finish = "finish",
  ChatAudit = "chat_audit",
  UserCancel = "cancel",
  InputSafety = "input_safety",
  ChatCode = "chat_code",
  ChatTaskInteraction = "interaction",
  HeartBeat = "heat_beat",
  BlockyEdit = "blocky_edit",
  ChatUIDsl = "chat_ui_dsl",
  ChatRateLimit = "chat_rate_limit"
}
Config_UGC_Copilot.EnumServerChatErrorCode = {
  UserSensitiveWord = 3010,
  ModelSensitiveWord = 3012,
  TextSecurityServiceError = 7001,
  QAServiceError = 7002,
  TranslateServiceError = 7003,
  IntentError = 7100,
  IntentOverload = 7201,
  ModgenOverload = 7202,
  MocapOverload = 7203,
  UnknownError = 7300,
  CostExceeded = 8101,
  LimitExceeded = 8102,
  UnknownErrorCommon = 1000,
  TextAuditRejected = 1001,
  ImageAuditRejected = 1002,
  AuditTimeout = 1003,
  AuditServiceError = 1004,
  UIGenProcessError = 9000,
  UIGenRequestError = 9001,
  UIGenImageGenError = 9002,
  UIGenImageUploadError = 9003,
  UIGenConvertError = 9004,
  UIGenConvertTimeout = 9005,
  UIGenDslInvalid = 9006
}
Config_UGC_Copilot.EnumServerErrorCode = {
  UserSensitiveWord = Config_UGC_Copilot.EnumServerChatErrorCode.UserSensitiveWord,
  ModelSensitiveWord = Config_UGC_Copilot.EnumServerChatErrorCode.ModelSensitiveWord,
  TextSecurityServiceError = Config_UGC_Copilot.EnumServerChatErrorCode.TextSecurityServiceError,
  QAServiceError = Config_UGC_Copilot.EnumServerChatErrorCode.QAServiceError,
  TranslateServiceError = Config_UGC_Copilot.EnumServerChatErrorCode.TranslateServiceError,
  IntentError = Config_UGC_Copilot.EnumServerChatErrorCode.IntentError,
  IntentOverload = Config_UGC_Copilot.EnumServerChatErrorCode.IntentOverload,
  ModgenOverload = Config_UGC_Copilot.EnumServerChatErrorCode.ModgenOverload,
  MocapOverload = Config_UGC_Copilot.EnumServerChatErrorCode.MocapOverload,
  UnknownError = Config_UGC_Copilot.EnumServerChatErrorCode.UnknownError
}
Config_UGC_Copilot.MessageRspEvenToV1Chat = {
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Data] = "100",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Error] = "101",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Finish] = "102"
}
Config_UGC_Copilot.MessageRspEvenToV2Chat = {
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Data] = "100",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Error] = "101",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Finish] = "102",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Hint] = "103",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.Intent] = "104",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.ChatAudit] = "105",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.InputSafety] = "106",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.UserCancel] = "999",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.ChatCode] = "107",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.ChatTaskInteraction] = "108",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.HeartBeat] = "109",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.BlockyEdit] = "110",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.ChatUIDsl] = "111",
  [Config_UGC_Copilot.MessageRspEventTypeEnum.ChatRateLimit] = "112"
}
Config_UGC_Copilot.HeartBeatPongConfig = {PongField = "pong", PongValue = "pong"}
Config_UGC_Copilot.PrecheckResultCode = {
  Normal = 0,
  Error = -1,
  Timeout = -1000,
  TooManyRequest = 5001,
  VideoNoHuman = -72100,
  VideoHalfHuman = -72101,
  LockAlreadyLocked = -80001,
  LockRequestTimeout = -80002,
  LockRequestFailed = -80003
}
Config_UGC_Copilot.MessageCDTime = 3.0
function Config_UGC_Copilot.NumOfEvent(MessageRspEventTypeEnum)
  if Config_UGC_Copilot.MessageRspEvenToV2Chat[MessageRspEventTypeEnum] then
    return tonumber(Config_UGC_Copilot.MessageRspEvenToV2Chat[MessageRspEventTypeEnum])
  end
  return nil
end
local _ModelGen_SplitHandler = function(deltaData, outputSegments, trace_id)
  if deltaData.content and type(deltaData.content) == "table" then
    local ModuleManager = require("client.module_framework.ModuleManager")
    local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
    table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, Logic_UGC_Copilot.GenerateModelFeature:GetGenModelCompleteDesc(deltaData.content), deltaData.role))
    for _, SingleContent in pairs(deltaData.content) do
      table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGenSingle, SingleContent, deltaData.role))
    end
    return true
  end
  return false
end
local _ModelGen_ResourceFinishHandler = function(ntf_data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if Logic_UGC_Copilot.GenerateModelFeature then
    Logic_UGC_Copilot.GenerateModelFeature:HandleResourceFinishNtf(0, ntf_data)
  end
  log(bWriteLog and "Processing model generation resources, type: " .. tostring(ntf_data.type))
  for _, resource in ipairs(ntf_data.content) do
    if resource and type(resource) == "table" then
      log(bWriteLog and string.format("Resource ID: %s", tostring(resource.id)))
      log(bWriteLog and string.format("File path: %s", tostring(resource.path)))
      log(bWriteLog and string.format("Bucket: %s", tostring(resource.bucket)))
      log(bWriteLog and string.format("Region: %s", tostring(resource.region)))
      log(bWriteLog and string.format("Resource name: %s", tostring(resource.name)))
    else
      log(bWriteLog and "Warning: Invalid resource data skipped")
    end
  end
  Config_UGC_Copilot.ProcessAndOutputMessages(ntf_data.type, ntf_data.trace_id, ntf_data.content, Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {HideFeedback = false, HideMessageBG = false})
end
local _ModelGen_OnLongTaskStart = function(TraceID, Data)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if Logic_UGC_Copilot.GenerateModelFeature then
    Logic_UGC_Copilot.GenerateModelFeature:OnPreCheck(Data)
  end
  local AIGC3DModelSubSystem = SubsystemMgr:Get("AIGC3DModelSubSystem")
  if AIGC3DModelSubSystem then
    AIGC3DModelSubSystem:OnTEGPreCheck(Data)
  end
end
Config_UGC_Copilot.Copilot_MessageTypeConfig = {
  [Config_UGC_Copilot.Enum_Copilot_MessageType.Messages] = {
    UIKey = "UGC_Assistant_Copilot_Sub_TextBlock_UIBP",
    ContentKey = "text",
    EndPoint = "VerticalBox_SubItems",
    PreCheck = function(Data)
      print(bWriteLog and "Config_UGC_Copilot.Enum_Copilot_MessageType.Messages")
    end,
    GetCopyText = function(content)
      if type(content) == "string" then
        local result = string.gsub(content, "<[^>]*>", "")
        return result
      end
      return nil
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.CodeBlock] = {
    UIKey = "UGC_Assistant_Copilot_CodeBlock_UIBP",
    EndPoint = "VerticalBox_SubItems"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.Questions] = {
    UIKey = "UGC_Assistant_Copilot_Sub_Questions_UIBP",
    EndPoint = "VerticalBox_PostContent"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.Citations] = {
    ContentKey = "citations",
    UIKey = "UGC_Assistant_Copilot_Sub_Citations_UIBP",
    EndPoint = "VerticalBox_PostContent"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.Image] = {
    UIKey = "UGC_Assistant_Copilot_Sub_Image_UIBP",
    EndPoint = "VerticalBox_SubItems",
    TypeConversion = function(contentData)
      if contentData.images then
        contentData.content = contentData.images
        contentData.images = nil
        contentData.type = Config_UGC_Copilot.Enum_Copilot_MessageType.Images
        return true
      end
      return false
    end,
    GetCopyText = function(content)
      if type(content) == "table" then
        local urls = {}
        for _, imageData in ipairs(content) do
          if imageData.url then
            table.insert(urls, imageData.url)
          end
        end
        if 0 < #urls then
          return table.concat(urls, "\n")
        end
      end
      return nil
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.System] = {
    UIKey = "UGC_Assistant_Copilot_Sub_System_TextBlock_UIBP",
    EndPoint = "VerticalBox_SystemMsg"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGen] = {
    UIKey = "NULL",
    EndPoint = "HorizontalBox_ComposeItem",
    SplitHandler = _ModelGen_SplitHandler,
    PreCheck = function(Data, TraceID, OutputMessage)
      log(bWriteLog and string.format("PrimitiComboGen PreCheck: TraceID=%s, ContentCount=%d", tostring(TraceID), Data.content and type(Data.content) == "table" and #Data.content or 0))
    end,
    ResourceFinishHandler = _ModelGen_ResourceFinishHandler,
    bIsLongTask = true,
    OnLongTaskStart = _ModelGen_OnLongTaskStart,
    OnLongTaskFailed = function(OutMsgs)
    end,
    OnLongTaskFinished = function(TraceID)
    end,
    ContentKey = "media_content",
    EditActionTypes = CreateEditActionTypes({
      StopGen = "AIGCModelStopClick"
    })
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGenSingle] = {
    UIKey = "UGC_Assistant_Copilot_Sub_ModGen_UIBP",
    EndPoint = "HorizontalBox_ComposeItem"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.AnimGen] = {
    UIKey = "UGC_Assistant_Copilot_Sub_AnimGen_UIBP",
    EndPoint = "VerticalBox_SubItems",
    bIsLongTask = true,
    OnLongTaskStart = function(TraceID, Data)
      local AIGCCreateSkAnimSubSystem = SubsystemMgr:Get("AIGCCreateSkAnimSubSystem")
      if AIGCCreateSkAnimSubSystem then
        AIGCCreateSkAnimSubSystem:OnTEGPreCheck(Data)
      end
    end,
    OnLongTaskFailed = function(OutMsgs)
      local AIGCCreateSkAnimSubSystem = SubsystemMgr:Get("AIGCCreateSkAnimSubSystem")
      if AIGCCreateSkAnimSubSystem then
        AIGCCreateSkAnimSubSystem:OnTEGTaskTimeout(OutMsgs)
      end
    end,
    OnLongTaskFinished = function(TraceID)
      local AIGCCreateSkAnimSubSystem = SubsystemMgr:Get("AIGCCreateSkAnimSubSystem")
      if AIGCCreateSkAnimSubSystem then
        AIGCCreateSkAnimSubSystem:OnStopOrFinished()
      end
    end,
    ResourceFinishHandler = function(ntf_data)
      log(bWriteLog and "Processing dance motion generation resources")
      for _, resource in ipairs(ntf_data.content) do
        if resource and type(resource) == "table" then
          log(bWriteLog and string.format("Resource ID: %s", tostring(resource.id)))
          log(bWriteLog and string.format("File path: %s", tostring(resource.path)))
          log(bWriteLog and string.format("Bucket: %s", tostring(resource.bucket)))
          log(bWriteLog and string.format("Region: %s", tostring(resource.region)))
          log(bWriteLog and string.format("Animation length: %s", tostring(resource.length)))
        else
          log(bWriteLog and "Warning: Invalid resource data skipped")
        end
      end
      Config_UGC_Copilot.ProcessAndOutputMessages(ntf_data.type, ntf_data.trace_id, ntf_data.content, Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {HideFeedback = false, HideMessageBG = false})
    end,
    ContentKey = "media_content",
    EditActionTypes = CreateEditActionTypes({
      StopGen = "AIGCAnimStopCounts",
      ReportGenRes = "AIGCAnimAICopilotReport"
    })
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.GenPrecheck] = {
    UIKey = "NULL",
    SplitHandler = function(deltaData, outputSegments, trace_id)
      print(bWriteLog and "Config_UGC_Copilot.Enum_Copilot_MessageType.GenPrecheck SplitHandler")
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      _NormalizeUIGenPrecheckData(deltaData)
      if deltaData and deltaData.gen_precheck and deltaData.gen_precheck.precheck_result and deltaData.gen_precheck.precheck_result == 0 then
        table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.InGeneration, deltaData, Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant))
      end
      return true
    end,
    PreCheck = function(Data, TraceID, AIMessage)
      print(bWriteLog and "Config_UGC_Copilot.Enum_Copilot_MessageType.GenPrecheck PreCheck")
      _NormalizeUIGenPrecheckData(Data)
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      local stateMachine = Logic_UGC_Copilot.StateMachine
      stateMachine:UpdateState(Config_UGC_Copilot.Enum_UGC_LLM_State.LONG_TASK_RUNNING, "GenPrecheck")
      stateMachine:SetCurrentLongTaskContext({precheck = Data, trace_id = TraceID})
      local TaskType = Data.gen_precheck and Data.gen_precheck.gen_type
      local TaskConfig = Config_UGC_Copilot.GetCopilotMessageTypeConfig(TaskType)
      if TaskConfig and TaskConfig.bIsLongTask then
        if TaskConfig.OnLongTaskStart then
          TaskConfig.OnLongTaskStart(TraceID, Data)
        end
        local currentTime = os.time()
        if Data then
          Data.StartTime = currentTime
        end
        if Data and Data.gen_precheck and Data.gen_precheck.precheck_result then
          if Data.gen_precheck.precheck_result ~= 0 then
            Logic_UGC_Copilot:CommitLongTaskFinish(TraceID, Data.gen_precheck.precheck_result, Data.gen_precheck.gen_type, {
              Data.gen_precheck.predict_duration or 60
            })
          elseif AIMessage then
            AIMessage.HideMessageBG = true
            AIMessage.HideFeedback = true
          end
        end
      end
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.InGeneration] = {
    UIKey = "UGC_Assistant_Copilot_Sub_InGen_UIBP",
    EndPoint = "VerticalBox_SubItems",
    DelayToClearTime = 2,
    OnContextClear = function(message, messages, index, chatID)
      table.remove(messages, index)
      print(bWriteLog and "Removed InGeneration message at index " .. index .. " from chat " .. chatID .. " via config.")
      message.Content = {
        Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, LocUtil.GetLocalizeResStr(97000036))
      }
      message.HideMessageBG = false
      message.HideFeedback = true
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, message.TraceID, chatID, message)
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.Images] = {
    UIKey = "NULL",
    ContentKey = "images",
    SplitHandler = function(deltaData, outputSegments, trace_id)
      if deltaData.content and type(deltaData.content) == "table" then
        for _, imageData in ipairs(deltaData.content) do
          table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Image, imageData, deltaData.role))
        end
        return true
      end
      return false
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.Censoring] = {
    UIKey = "UGC_Assistant_Copilot_Loading_UIBP",
    EndPoint = "VerticalBox_SubItems",
    OnContextClear = function(message, messages, index, chatID, Reason)
      table.remove(messages, index)
      print(bWriteLog and "Removed InGeneration message at index " .. index .. " from chat " .. tostring(chatID) .. " via config.")
      local ShowText = LocUtil.GetLocalizeResStr(511070)
      if Reason == Config_UGC_Copilot.Enum_ContentClearReason.OnStop then
        ShowText = LocUtil.GetLocalizeResStr(8801017)
      end
      message.Content = {
        Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, ShowText)
      }
      message.HideMessageBG = false
      message.HideFeedback = true
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_MESSAGE_REVOKED, message.TraceID, chatID, message)
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.CensoredFailed] = {
    UIKey = "UGC_Assistant_Copilot_Censor_Failed_UIBP",
    EndPoint = "VerticalBox_SystemMsg"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.AudioGen] = {
    UIKey = "NULL",
    EndPoint = "VerticalBox_SubItems",
    SplitHandler = function(deltaData, outputSegments, trace_id)
      if deltaData.content and type(deltaData.content) == "table" then
        for _, SingleContent in pairs(deltaData.content) do
          table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.AudioGenSingle, SingleContent, deltaData.role))
        end
        return true
      end
      return false
    end,
    PreCheck = function(Data, TraceID, OutputMessage)
      log(bWriteLog and string.format("AudioGen PreCheck: TraceID=%s, ContentCount=%d", tostring(TraceID), Data.content and type(Data.content) == "table" and #Data.content or 0))
    end,
    bIsLongTask = true,
    OnLongTaskStart = function(TraceID, Data)
    end,
    OnLongTaskFailed = function(OutMsgs)
    end,
    OnLongTaskFinished = function(TraceID)
    end,
    ContentKey = "media_content",
    EditActionTypes = {}
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.AudioGenSingle] = {
    UIKey = "UGC_Smart_Assistant_MusicPlayer_UIBP",
    EndPoint = "VerticalBox_SubItems"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.ModSearch] = {
    UIKey = "NULL",
    EndPoint = "HorizontalBox_ComposeItem",
    ContentKey = "media_content",
    SplitHandler = function(deltaData, outputSegments, trace_id)
      if deltaData.search and deltaData.search.media_content and type(deltaData.search.media_content) == "table" then
        local ModuleManager = require("client.module_framework.ModuleManager")
        local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
        if Logic_UGC_Copilot and Logic_UGC_Copilot.SessionManager then
          Logic_UGC_Copilot.SessionManager:SetTraceDetailByKey(trace_id, Config_UGC_Copilot.MessageDetailKeyEnum.HasSearchResult, true)
        end
        table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, Logic_UGC_Copilot.GenerateModelFeature:GetGenModelCompleteSearchDesc(deltaData.search.media_content), deltaData.role))
        for _, SingleContent in pairs(deltaData.search.media_content) do
          table.insert(outputSegments, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGenSingle, SingleContent, deltaData.role))
        end
        return true
      end
      return false
    end,
    PreCheck = function(Data, TraceID, OutputMessage)
      log(bWriteLog and string.format("PrimitiComboGen PreCheck: TraceID=%s, ContentCount=%d", tostring(TraceID), Data.search.media_content and type(Data.search.media_content) == "table" and #Data.search.media_content or 0))
    end,
    ResourceFinishHandler = function(ntf_data)
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot.GenerateModelFeature then
        Logic_UGC_Copilot.GenerateModelFeature:HandleResourceFinishNtf(0, ntf_data)
      end
      log(bWriteLog and "Processing mod generation resources")
      for _, resource in ipairs(ntf_data.content) do
        if resource and type(resource) == "table" then
          log(bWriteLog and string.format("Resource ID: %s", tostring(resource.id)))
          log(bWriteLog and string.format("File path: %s", tostring(resource.path)))
          log(bWriteLog and string.format("Bucket: %s", tostring(resource.bucket)))
          log(bWriteLog and string.format("Region: %s", tostring(resource.region)))
          log(bWriteLog and string.format("Resource name: %s", tostring(resource.name)))
        else
          log(bWriteLog and "Warning: Invalid resource data skipped")
        end
      end
      Config_UGC_Copilot.ProcessAndOutputMessages(ntf_data.type, ntf_data.trace_id, ntf_data.content, Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant, {HideFeedback = false, HideMessageBG = false})
    end,
    bIsLongTask = true,
    OnLongTaskStart = function(TraceID, Data)
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot.GenerateModelFeature then
        Logic_UGC_Copilot.GenerateModelFeature:OnPreCheck(Data)
      end
    end,
    OnLongTaskFailed = function(OutMsgs)
    end,
    OnLongTaskFinished = function(TraceID)
    end,
    EditActionTypes = CreateEditActionTypes({
      StopGen = "AIGCModelStopClick"
    })
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.CheckAsset] = {
    UIKey = "UGC_Assistant_Copilot_Sub_CheckAsset_UIBP",
    EndPoint = "VerticalBox_SubItems"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.VoxelModGen] = {
    UIKey = "NULL",
    EndPoint = "HorizontalBox_ComposeItem",
    SplitHandler = _ModelGen_SplitHandler,
    PreCheck = function(Data, TraceID, OutputMessage)
      log(bWriteLog and string.format("VoxelModGen PreCheck: TraceID=%s, ContentCount=%d", tostring(TraceID), Data.content and type(Data.content) == "table" and #Data.content or 0))
    end,
    ResourceFinishHandler = _ModelGen_ResourceFinishHandler,
    bIsLongTask = true,
    OnLongTaskStart = _ModelGen_OnLongTaskStart,
    OnLongTaskFailed = function(OutMsgs)
    end,
    OnLongTaskFinished = function(TraceID)
    end,
    ContentKey = "media_content",
    EditActionTypes = CreateEditActionTypes({
      StopGen = "AIGCModelStopClick"
    })
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.ImgModGen] = {
    UIKey = "NULL",
    EndPoint = "HorizontalBox_ComposeItem",
    SplitHandler = _ModelGen_SplitHandler,
    PreCheck = function(Data, TraceID, OutputMessage)
      log(bWriteLog and string.format("ImgModGen PreCheck: TraceID=%s, ContentCount=%d", tostring(TraceID), Data.content and type(Data.content) == "table" and #Data.content or 0))
    end,
    ResourceFinishHandler = _ModelGen_ResourceFinishHandler,
    bIsLongTask = true,
    OnLongTaskStart = _ModelGen_OnLongTaskStart,
    OnLongTaskFailed = function(OutMsgs)
    end,
    OnLongTaskFinished = function(TraceID)
    end,
    ContentKey = "media_content",
    EditActionTypes = CreateEditActionTypes({
      StopGen = "AIGCModelStopClick"
    })
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.UserRefImage] = {
    UIKey = "UGC_Assistant_Copilot_Sub_UserRefImage_UIBP",
    EndPoint = "VerticalBox_SubItems"
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.ChatUIDsl] = {
    UIKey = "NULL",
    EndPoint = "VerticalBox_SubItems",
    bIsLongTask = true,
    OnLongTaskFailed = function(OutMsgs, TraceID)
    end,
    OnLongTaskFinished = function(TraceID)
    end
  },
  [Config_UGC_Copilot.Enum_Copilot_MessageType.BlockyEdit] = {
    UIKey = "UGC_Assistant_Copilot_Sub_BlockyEdit_UIBP",
    EndPoint = "WrapBox_FeedbackBtn"
  }
}
Config_UGC_Copilot.CopilotStateConfig = {
  [Config_UGC_Copilot.Enum_UGC_LLM_State.LONG_TASK_RUNNING] = {
    OnTimeOut = function()
      print(bWriteLog and "Config_UGC_Copilot.Enum_UGC_LLM_State.LONG_TASK_RUNNING Timeout")
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      local LongTaskContext = Logic_UGC_Copilot.StateMachine:GetCurrentLongTaskContext()
      if LongTaskContext then
        Logic_UGC_Copilot:CommitLongTaskFinish(LongTaskContext.trace_id, Config_UGC_Copilot.EnumServerGenErrorCode.Timeout, LongTaskContext.precheck.gen_precheck.gen_type)
      end
    end
  }
}
function Config_UGC_Copilot.GetContentKeyToTypeMapping()
  local mapping = {}
  for messageType, config in pairs(Config_UGC_Copilot.Copilot_MessageTypeConfig) do
    if config.ContentKey then
      mapping[config.ContentKey] = messageType
    end
  end
  return mapping
end
function Config_UGC_Copilot.IsLongTaskType(Type)
  local TypeConfig = Config_UGC_Copilot.Copilot_MessageTypeConfig[Type]
  if TypeConfig then
    return TypeConfig.bIsLongTask
  end
end
function Config_UGC_Copilot.GetCopilotMessageTypeConfig(messageType)
  return Config_UGC_Copilot.Copilot_MessageTypeConfig[messageType]
end
function Config_UGC_Copilot.HasCopilotMessageTypeConfig(messageType)
  return Config_UGC_Copilot.Copilot_MessageTypeConfig[messageType] ~= nil
end
function Config_UGC_Copilot.GetAllCopilotMessageTypeConfigs()
  return Config_UGC_Copilot.Copilot_MessageTypeConfig
end
Config_UGC_Copilot.InteractionEnum = {
  DoThink = "do_think",
  SearchAsset = "search_asset",
  FoundAsset = "found_asset",
  CheckAsset = "check_asset",
  DoExecute = "do_execute",
  DoneInstance = "done_instance",
  UIDslGen = "ui_dsl_gen",
  UIDslValidate = "ui_dsl_validate",
  UIRequirementAnalyze = "ui_requirement_analyze",
  UIImageGen = "ui_image_gen",
  UIAssetProcess = "ui_asset_process",
  UILayoutAdjust = "ui_layout_adjust",
  BlockyLuaThink = "blocky_lua_think"
}
Config_UGC_Copilot.InteractionStatusEnum = {
  Pending = "pending",
  Success = "success",
  Failed = "failed",
  Timeout = "timeout"
}
Config_UGC_Copilot.UIGenLabelLocIdMap = {
  analyzing_requirement = 2026051124,
  generating_image = 2026051125,
  processing_asset = 2026051126,
  adjusting_layout = 2026051127
}
local _UIGen_GetDynamicShowText = function(data)
  if not data or not data.label then
    log("[copilot_uigen] GetDynamicShowText: data or label is nil, using default locId=2026051124")
    return LocUtil.GetLocalizeResStr(2026051124)
  end
  local locId = Config_UGC_Copilot.UIGenLabelLocIdMap[data.label]
  locId = locId or 2026051124
  local localizedText = LocUtil.GetLocalizeResStr(locId)
  log(string.format("[copilot_uigen] GetDynamicShowText: label=%s, locId=%d, localizedText=%s", tostring(data.label), locId, tostring(localizedText)))
  return localizedText
end
local _UIGenInteractionConfig = {
  ShowText = 97001077,
  bNotifyOnly = true,
  GetDynamicShowText = _UIGen_GetDynamicShowText
}
Config_UGC_Copilot.InteractionConfig = {
  [Config_UGC_Copilot.InteractionEnum.DoThink] = {ShowText = 97001077},
  [Config_UGC_Copilot.InteractionEnum.UIDslGen] = _UIGenInteractionConfig,
  [Config_UGC_Copilot.InteractionEnum.UIDslValidate] = _UIGenInteractionConfig,
  [Config_UGC_Copilot.InteractionEnum.UIRequirementAnalyze] = {
    ShowText = _UIGenInteractionConfig.ShowText,
    bNotifyOnly = _UIGenInteractionConfig.bNotifyOnly,
    GetDynamicShowText = _UIGenInteractionConfig.GetDynamicShowText,
    OnInteractionHandler = function(TraceID, data)
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot and Logic_UGC_Copilot.MessageHandler then
        Logic_UGC_Copilot.MessageHandler:AppendUIGenProgress(TraceID)
      end
    end
  },
  [Config_UGC_Copilot.InteractionEnum.UIImageGen] = _UIGenInteractionConfig,
  [Config_UGC_Copilot.InteractionEnum.UIAssetProcess] = _UIGenInteractionConfig,
  [Config_UGC_Copilot.InteractionEnum.UILayoutAdjust] = _UIGenInteractionConfig,
  [Config_UGC_Copilot.InteractionEnum.BlockyLuaThink] = {
    ShowText = 97001077,
    bNotifyOnly = true,
    OnInteractionHandler = function(TraceID, data)
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot and Logic_UGC_Copilot.MessageHandler then
        Logic_UGC_Copilot.MessageHandler:AppendBlockyLuaProgress(TraceID)
      end
    end
  },
  [Config_UGC_Copilot.InteractionEnum.SearchAsset] = {
    ShowText = 97001074,
    OnInteractionHandler = function(TraceID, data)
      print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.SearchAsset")
    end
  },
  [Config_UGC_Copilot.InteractionEnum.FoundAsset] = {ShowText = 97001075},
  [Config_UGC_Copilot.InteractionEnum.CheckAsset] = {
    ShowText = 97001076,
    bAsync = true,
    TimeoutSeconds = 35,
    bSkipProtocolOnFailed = true,
    InitUIState = function(data)
      local content = data.content or {}
      local categories = content.categories or {}
      local totalItems = 0
      for _, category in ipairs(categories) do
        totalItems = totalItems + #(category.items or {})
      end
      local countdownDuration = 12
      if 6 < totalItems then
        countdownDuration = 20
      elseif 3 < totalItems then
        countdownDuration = 15
      end
      local defaultSelections = {}
      for i, _ in ipairs(categories) do
        defaultSelections[i] = 1
      end
      return {
        countdown_duration = countdownDuration,
        user_interacted = false,
        completed = false,
        selections = defaultSelections
      }
    end,
    BuildDefaultResult = function(data)
      local content = data or {}
      local categories = content.categories or {}
      local ui_state = data.ui_state or {}
      local selections = ui_state.selections or {}
      return {
        interaction_type = "check_asset",
        categories = categories,
        trace_id = data.trace_id,
        seq_id = data.seq_id,
        user_      }
    end,
    OnCountdownComplete = function(TraceID, data, DefaultResultData, OnComplete)
      print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.CheckAsset OnCountdownComplete - TraceID: " .. tostring(TraceID))
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot and Logic_UGC_Copilot.PlacePrefabFeature then
        Logic_UGC_Copilot.PlacePrefabFeature:HandleCheckAsset(DefaultResultData, function(Response)
          print(bWriteLog and "Config_UGC_Copilot OnCountdownComplete - HandleCheckAsset complete, cancelled: " .. tostring(Response.cancelled))
          EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_CHECK_ASSET_COMPLETE, Response)
          local bAllSuccess = true
          for _, item in ipairs(Response.selected or {}) do
            if not item.success then
              bAllSuccess = false
              print(bWriteLog and "Config_UGC_Copilot OnCountdownComplete - CheckAsset failed for category: " .. tostring(item.category))
              break
            end
          end
          local FilteredResponse = {
            seq_id = Response.seq_id,
            type = "check_asset",
            selected = {},
            error_code = bAllSuccess and 0 or -1
          }
          for _, item in ipairs(Response.selected or {}) do
            table.insert(FilteredResponse.selected, {
              category = item.category,
              selected_id = item.selected_id
            })
          end
          if OnComplete then
            OnComplete(FilteredResponse)
          end
        end)
      else
        print(bWriteLog and "Config_UGC_Copilot OnCountdownComplete - PlacePrefabFeature not available")
        if OnComplete then
          OnComplete({
            seq_id = data.seq_id,
            type = "check_asset",
            selected = {},
            error_code = -1,
            error_msg = "PlacePrefabFeature not available"
          })
        end
      end
    end,
    OnFinish = function(TraceID, data, bTimeout, ResultData)
      print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.CheckAsset OnFinish - TraceID: " .. tostring(TraceID) .. ", bTimeout: " .. tostring(bTimeout))
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      if Logic_UGC_Copilot then
        Logic_UGC_Copilot:SimulateAdvancedMessage(TraceID, Config_UGC_Copilot.Enum_Copilot_MessageType.CheckAsset, nil, {
          HideFeedback = false,
          HideMessageBG = false,
          ClearContent = true
        })
      end
      local errorCode = ResultData and ResultData.error_code
      if errorCode and errorCode ~= 0 then
        print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.CheckAsset OnFinish - error_code: " .. tostring(errorCode) .. ", stopping chat")
        if Logic_UGC_Copilot then
          Logic_UGC_Copilot:StopChat(Config_UGC_Copilot.Enum_StopChatReason.AssetCheckFailed)
        end
      end
      if bTimeout then
      end
    end,
    OnInteractionHandler = function(TraceID, data, AsyncCallback)
      print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.CheckAsset OnInteractionHandler - TraceID: " .. tostring(TraceID))
      local ModuleManager = require("client.module_framework.ModuleManager")
      local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
      local CheckAssetData = {
        interaction_type = "check_asset",
        categories = data.categories or {},
        trace_id = TraceID,
        seq_id = data.seq_id
      }
      if Logic_UGC_Copilot then
        Logic_UGC_Copilot:SimulateAdvancedMessage(TraceID, Config_UGC_Copilot.Enum_Copilot_MessageType.CheckAsset, CheckAssetData, {HideFeedback = true, HideMessageBG = true})
      end
    end
  },
  [Config_UGC_Copilot.InteractionEnum.DoExecute] = {
    ShowText = 97001079,
    StatusText = {
      [Config_UGC_Copilot.InteractionStatusEnum.Pending] = 97001079,
      [Config_UGC_Copilot.InteractionStatusEnum.Success] = 97001111,
      [Config_UGC_Copilot.InteractionStatusEnum.Failed] = 97001080,
      [Config_UGC_Copilot.InteractionStatusEnum.Timeout] = 97001080
    }
  },
  [Config_UGC_Copilot.InteractionEnum.DoneInstance] = {
    ShowText = 97001111,
    OnInteractionHandler = function(TraceID, data)
      print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.DoneInstance")
      local deleted_insts_id = data.deleted
      local added_insts_id = data.added
      local modified_insts_id = data.modified
      local instanceIds = {}
      if added_insts_id then
        for _, id in ipairs(added_insts_id) do
          if tonumber(id) then
            table.insert(instanceIds, tostring(id))
          end
        end
      end
      if modified_insts_id then
        for _, id in ipairs(modified_insts_id) do
          if tonumber(id) then
            table.insert(instanceIds, tostring(id))
          end
        end
      end
      if 1 < #instanceIds then
        local selectionSubSystem = SubsystemMgr:Get("CreativeModeEditSelectionSubSystem")
        EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_TRY_ENTER_MULTISELECT_MODE)
        if selectionSubSystem:IsMultiSelectMode() then
          local success = selectionSubSystem:SelectInstances(instanceIds, true)
          if success then
            print("\230\136\144\229\138\159\233\128\137\228\184\173\230\140\135\229\174\154instanceId\239\188\140\230\149\176\233\135\143: " .. #instanceIds)
            local selectedInstances = selectionSubSystem:GetSelectedInstances()
            print("\229\189\147\229\137\141\233\128\137\228\184\173\230\149\176\233\135\143: " .. #selectedInstances)
          else
            print("\233\128\137\228\184\173instanceId\229\164\177\232\180\165")
          end
        else
          print("\229\164\154\233\128\137\230\168\161\229\188\143\230\156\170\229\188\128\229\144\175")
        end
        local AICopilotSubSystem = SubsystemMgr:Get("AICopilotSubSystem")
        AICopilotSubSystem:TryHideCopilotWindowIfNotPegged()
      elseif #instanceIds == 1 then
        local topUIName = UIManager.GetTopVisibleUIName()
        if topUIName ~= "CreativeModeEditModeUI" then
          print(bWriteLog and "Config_UGC_Copilot.InteractionEnum.DoneInstance: topUIName is not CreativeModeEditModeUI")
          return
        end
        local CreativeModeObjectEditSubSystem = SubsystemMgr:Get("CreativeModeObjectEditSubSystem")
        CreativeModeObjectEditSubSystem:StartEdit(instanceIds[1])
        local AICopilotSubSystem = SubsystemMgr:Get("AICopilotSubSystem")
        AICopilotSubSystem:TryHideCopilotWindowIfNotPegged()
      else
        print("\230\178\161\230\156\137\233\156\128\232\166\129\230\147\141\228\189\156\231\154\132instanceId")
      end
    end
  }
}
Config_UGC_Copilot.MessageDetailKeyEnum = {
  InteractionDetails = "interactions",
  HasSearchResult = "has_search_result"
}
function Config_UGC_Copilot.GetInteractionDisplayText(interactionType, status)
  status = status or Config_UGC_Copilot.InteractionStatusEnum.Pending
  local config = Config_UGC_Copilot.InteractionConfig[interactionType]
  if not config then
    return ""
  end
  if config.StatusText and config.StatusText[status] then
    return Util_UGC.GetLocalizeResStr(config.StatusText[status])
  end
  if config.ShowText then
    return Util_UGC.GetLocalizeResStr(config.ShowText)
  end
  return ""
end
function Config_UGC_Copilot.IsExclusiveChatScene(sceneId)
  return Config_UGC_Copilot.ExclusiveChatScenes[sceneId] == true
end
function Config_UGC_Copilot.HandleMessageSplitting(deltaData, outputSegments, trace_id)
  local config = Config_UGC_Copilot.GetCopilotMessageTypeConfig(deltaData.type)
  if config and config.SplitHandler then
    return config.SplitHandler(deltaData, outputSegments, trace_id)
  end
  return false
end
function Config_UGC_Copilot.HandleResourceFinish(ntf_data)
  local config = Config_UGC_Copilot.GetCopilotMessageTypeConfig(ntf_data.type)
  if config and config.ResourceFinishHandler then
    config.ResourceFinishHandler(ntf_data)
    return true
  end
  return false
end
function Config_UGC_Copilot.ProcessAndOutputMessages(message_type, trace_id, content, role, ui_options)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  local MsgConfig = Config_UGC_Copilot.GetCopilotMessageTypeConfig(message_type)
  if not MsgConfig then
    log(bWriteLog and string.format("No config found for message type: %s", tostring(message_type)))
    return
  end
  local deltaData = {
    type = message_type,
    role = role or Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant,
      }
  local OutMessages = {}
  local wasSplit = Config_UGC_Copilot.HandleMessageSplitting(deltaData, OutMessages, trace_id)
  if not wasSplit then
    table.insert(OutMessages, Config_UGC_Copilot.CreateContentSegment(message_type, content, deltaData.role))
  end
  if MsgConfig.PreCheck then
    MsgConfig.PreCheck(deltaData, trace_id, OutMessages)
  end
  local defaultUIOptions = {HideFeedback = false, HideMessageBG = false}
  local finalUIOptions = ui_options or defaultUIOptions
  for _, MsgContent in pairs(OutMessages) do
    Logic_UGC_Copilot:SimulateAdvancedMessage(trace_id, MsgContent.type, MsgContent.content, finalUIOptions)
  end
  log(bWriteLog and string.format("Processed and output %d messages for type: %s", #OutMessages, tostring(message_type)))
end
function Config_UGC_Copilot.HandleMessageTypeConversion(contentData)
  local config = Config_UGC_Copilot.GetCopilotMessageTypeConfig(contentData.type)
  if config and config.TypeConversion then
    return config.TypeConversion(contentData)
  end
  return false
end
Config_UGC_Copilot.ErrorSource = {
  CLIENT = "client",
  SERVER_CHAT = "server_chat",
  SERVER_GEN = "server_gen",
  LOCK = "lock",
  VIDEO = "video"
}
Config_UGC_Copilot.EnumServerGenErrorCode = {
  Normal = 0,
  Error = -1,
  Timeout = -1000,
  TooManyRequest = 5001,
  UserStopped = -2000,
  ReviewModGenCountTooFew = -80001,
  ReviewModGenResultError = -80002
}
Config_UGC_Copilot.EnumVideoErrorCode = {NoHuman = -72100, HalfHuman = -72101}
Config_UGC_Copilot.EnumLockErrorCode = {
  AlreadyLocked = -80001,
  RequestTimeout = -80002,
  RequestFailed = -80003,
  NoEditPermission = -80004
}
Config_UGC_Copilot.ErrorOutputType = {
  CHAT = "chat",
  HISTORY = "history",
  TOAST = "toast"
}
Config_UGC_Copilot.ErrorTextBySource = {
  [Config_UGC_Copilot.ErrorSource.CLIENT] = {
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_CONCURRENT_REQUEST] = 511070,
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_INVALID_TRANSITION] = 511070,
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_TIMEOUT] = 97000031,
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_OUT_OF_QUOTA] = 8801018,
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NOT_INITED] = 511070,
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_MESSAGE_TOO_LONG] = 511070,
    [Config_UGC_Copilot.Enum_UGC_LLM_ErrorCode.ERR_NETWORK] = 511070
  },
  [Config_UGC_Copilot.ErrorSource.SERVER_CHAT] = {
    [Config_UGC_Copilot.EnumServerChatErrorCode.UserSensitiveWord] = 17005211,
    [Config_UGC_Copilot.EnumServerChatErrorCode.ModelSensitiveWord] = 97000030,
    [Config_UGC_Copilot.EnumServerChatErrorCode.TextSecurityServiceError] = 97000042,
    [Config_UGC_Copilot.EnumServerChatErrorCode.QAServiceError] = 97000042,
    [Config_UGC_Copilot.EnumServerChatErrorCode.TranslateServiceError] = 97000042,
    [Config_UGC_Copilot.EnumServerChatErrorCode.IntentError] = 97000042,
    [Config_UGC_Copilot.EnumServerChatErrorCode.IntentOverload] = 97000043,
    [Config_UGC_Copilot.EnumServerChatErrorCode.ModgenOverload] = 97000042,
    [Config_UGC_Copilot.EnumServerChatErrorCode.MocapOverload] = 97000043,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UnknownError] = 97000042,
    [Config_UGC_Copilot.EnumServerChatErrorCode.CostExceeded] = 97001084,
    [Config_UGC_Copilot.EnumServerChatErrorCode.LimitExceeded] = 97001100,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenProcessError] = 2026060253,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenRequestError] = 2026060254,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenImageGenError] = 2026060255,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenImageUploadError] = 2026060256,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenConvertError] = 2026060257,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenConvertTimeout] = 2026060258,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UIGenDslInvalid] = 2026060259,
    [Config_UGC_Copilot.EnumServerChatErrorCode.UnknownErrorCommon] = 2026060400,
    [Config_UGC_Copilot.EnumServerChatErrorCode.TextAuditRejected] = 2026060401,
    [Config_UGC_Copilot.EnumServerChatErrorCode.ImageAuditRejected] = 2026060402,
    [Config_UGC_Copilot.EnumServerChatErrorCode.AuditTimeout] = 2026060403,
    [Config_UGC_Copilot.EnumServerChatErrorCode.AuditServiceError] = 2026060404
  },
  [Config_UGC_Copilot.ErrorSource.SERVER_GEN] = {
    [Config_UGC_Copilot.EnumServerGenErrorCode.Normal] = nil,
    [Config_UGC_Copilot.EnumServerGenErrorCode.Error] = 97000042,
    [Config_UGC_Copilot.EnumServerGenErrorCode.Timeout] = 97000031,
    [Config_UGC_Copilot.EnumServerGenErrorCode.TooManyRequest] = {
      default = 97000043,
      [Config_UGC_Copilot.ErrorOutputType.HISTORY] = 97000042
    },
    [Config_UGC_Copilot.EnumServerGenErrorCode.UserStopped] = 8801017,
    [Config_UGC_Copilot.EnumServerGenErrorCode.ReviewModGenCountTooFew] = 97001113,
    [Config_UGC_Copilot.EnumServerGenErrorCode.ReviewModGenResultError] = 97001113
  },
  [Config_UGC_Copilot.ErrorSource.VIDEO] = {
    [Config_UGC_Copilot.EnumVideoErrorCode.NoHuman] = 99009970,
    [Config_UGC_Copilot.EnumVideoErrorCode.HalfHuman] = 99009970
  },
  [Config_UGC_Copilot.ErrorSource.LOCK] = {
    [Config_UGC_Copilot.EnumLockErrorCode.AlreadyLocked] = 97001057,
    [Config_UGC_Copilot.EnumLockErrorCode.RequestTimeout] = 97000042,
    [Config_UGC_Copilot.EnumLockErrorCode.RequestFailed] = 97000042,
    [Config_UGC_Copilot.EnumLockErrorCode.NoEditPermission] = 97001110
  }
}
Config_UGC_Copilot.PrecheckResultCode = {
  Normal = Config_UGC_Copilot.EnumServerGenErrorCode.Normal,
  Error = Config_UGC_Copilot.EnumServerGenErrorCode.Error,
  Timeout = Config_UGC_Copilot.EnumServerGenErrorCode.Timeout,
  TooManyRequest = Config_UGC_Copilot.EnumServerGenErrorCode.TooManyRequest,
  VideoNoHuman = Config_UGC_Copilot.EnumVideoErrorCode.NoHuman,
  VideoHalfHuman = Config_UGC_Copilot.EnumVideoErrorCode.HalfHuman,
  LockAlreadyLocked = Config_UGC_Copilot.EnumLockErrorCode.AlreadyLocked,
  LockRequestTimeout = Config_UGC_Copilot.EnumLockErrorCode.RequestTimeout,
  LockRequestFailed = Config_UGC_Copilot.EnumLockErrorCode.RequestFailed
}
Config_UGC_Copilot.PrecheckResultText = {
  [Config_UGC_Copilot.EnumServerGenErrorCode.Error] = 97000042,
  [Config_UGC_Copilot.EnumServerGenErrorCode.Timeout] = 97000031,
  [Config_UGC_Copilot.EnumServerGenErrorCode.TooManyRequest] = 97000043,
  [Config_UGC_Copilot.EnumVideoErrorCode.NoHuman] = 99009970,
  [Config_UGC_Copilot.EnumVideoErrorCode.HalfHuman] = 99009970
}
Config_UGC_Copilot.DefaultErrorText = 511070
function Config_UGC_Copilot.GetErrorText(source, errorCode, params, outputType)
  local sourceTable = Config_UGC_Copilot.ErrorTextBySource[source]
  local textKey
  if sourceTable then
    local errorConfig = sourceTable[errorCode]
    if type(errorConfig) == "table" then
      if outputType and errorConfig[outputType] then
        textKey = errorConfig[outputType]
      else
        textKey = errorConfig.default
      end
    else
      textKey = errorConfig
    end
  end
  textKey = textKey or Config_UGC_Copilot.DefaultErrorText
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if type(textKey) == "string" and string.sub(textKey, 1, 2) == "##" then
    if params and type(params) == "table" then
      return Util_UGC.GetLocalizeResStr(textKey, table.unpack(params))
    else
      return Util_UGC.GetLocalizeResStr(textKey)
    end
  elseif params and type(params) == "table" then
    return Util_UGC.GetLocalizeResStr(textKey, table.unpack(params))
  else
    return LocUtil.GetLocalizeResStr(textKey)
  end
end
function Config_UGC_Copilot.OutputError(source, errorCode, outputType, context, params)
  local errorText = Config_UGC_Copilot.GetErrorText(source, errorCode, params, outputType)
  context = context or {}
  if outputType == Config_UGC_Copilot.ErrorOutputType.CHAT then
    local ModuleManager = require("client.module_framework.ModuleManager")
    local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
    if Logic_UGC_Copilot then
      local options = {
        HideFeedback = context.hideFeedback ~= false and true or false,
        HideMessageBG = context.hideMessageBG or false,
        ClearContent = context.clearContent or false
      }
      Logic_UGC_Copilot:SimulateAdvancedMessage(context.traceId, Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, errorText, options)
    end
  elseif outputType == Config_UGC_Copilot.ErrorOutputType.HISTORY then
    if context.formattedMsg and context.formattedMsg.Content then
      table.insert(context.formattedMsg.Content, Config_UGC_Copilot.CreateContentSegment(Config_UGC_Copilot.Enum_Copilot_MessageType.Messages, errorText, Config_UGC_Copilot.Enum_Copilot_RoleType.Assistant))
    end
  elseif outputType == Config_UGC_Copilot.ErrorOutputType.TOAST then
    ShowNotice(errorText)
  end
  return errorText
end
return Config_UGC_Copilot