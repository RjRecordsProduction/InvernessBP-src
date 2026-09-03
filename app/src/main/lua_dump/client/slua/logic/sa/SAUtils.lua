local SAUtils = {DEFAULTSUIT = 1601019}
local IsInOneClickUI = false
function SAUtils.IsShowingMiniTVBubble()
  local ui = UIManager.GetUI(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP)
  if ui then
    return true
  end
  return false
end
function SAUtils.CheckProtocolNotice()
  local Promise = require("common.Promise")
  local promise = Promise.new()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eSmartAssistantV2
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  if saveData.hasAgreed then
    promise:Resolve(true)
  else
    UIManager.ShowUI(UIManager.UI_Config.SmartAssistantV2_AIChat_Popups_UIBP, function()
      promise:Resolve(true)
    end, function()
      promise:Reject()
    end)
  end
  return promise
end
function SAUtils.ShowSAAIChat(question, bFirstMySelf)
  if GlobalData.IsJapanOrKorea() then
    printf("SAUtils.ShowSAAIChat GlobalData.IsJapanOrKorea()")
    return
  end
  SAUtils.CheckProtocolNotice():Then(function(isAgreed)
    if isAgreed then
      local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
      return LogicSmartAssistant:PromiseAIChatAvaliable()
    end
  end):Then(function(isAIChatAvaliable)
    if isAIChatAvaliable then
      local args = {
        from = 1,
        question = question or "",
              }
      UIManager.ShowUI(UIManager.UI_Config.SmartAssistantV2_MainDialogue_UIBP, args)
    end
  end)
end
function SAUtils.ShowSmartAssistantMainUI(from)
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MINI_TV_SMART_ASSISTANT) then
    log(bWriteLog and "SAUtils.ShowSmartAssistantMainUI BP_ENUM_LOBBY_MINI_TV_SMART_ASSISTANT close")
    return
  end
  SAUtils.SetIsInOneClickUI(true)
  local args = {
    curSelectedTabIndex = 1,
    curSelectedSubTabIndex = 1,
    sdTopicList = nil
  }
  UIManager.ShowUI(UIManager.UI_Config.SmartAssistantV2_Lobby_Panel_UIBP, args)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local str = string.format("uid:%s,from:%s", DataMgr.roleData.uid, from)
  BasicDataTLogReport:ReportDelay(TLogEventDefine.SmartAssistantV2EnterMainUI, 0, str)
end
function SAUtils.CloseMiniTVBubbleUI()
  printf("SAUtils.CloseMiniTVBubbleUI")
  UIManager.CloseUI(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP)
end
function SAUtils.ShowSmartAssistantSetting()
  printf("SAUtils.ShowSmartAssistantSetting")
  UIManager.ShowUI(UIManager.UI_Config.SmartAssistant_SettingPopup_UIBP)
end
function SAUtils.SaveSettingOptions(options)
  log_tree(" SAUtils.SaveSettingOptions options", options)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(options, PlayerPrefsSystem.ePlayerPrefsType.eSmartAssistant)
end
function SAUtils.LoadSettingOptions()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tb = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmartAssistant) or {}
  return tb
end
function SAUtils.IsSettingOptionsOpen(key, default)
  local options = SAUtils.LoadSettingOptions()
  if options[key] == nil then
    return default
  end
  return options[key] == 1
end
function SAUtils.GetAssistantType()
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MINI_TV_SMART_ASSISTANT) then
    log(bWriteLog and "SAUtils.GetAssistantType BP_ENUM_LOBBY_MINI_TV_SMART_ASSISTANT close")
    return 3
  end
  local showType
  local options = SAUtils.LoadSettingOptions()
  if options and options.showType then
    log(bWriteLog and " SAUtils.GetAssistantType use local saved. options.showType :" .. tostring(options.showType))
    showType = options.showType
  end
  if nil == showType then
    local skinId = DataMgr.minitv_dressid
    if skinId == nil or skinId == 0 or skinId == SAUtils.DEFAULTSUIT then
      showType = 2
    else
      showType = 3
    end
    log(bWriteLog and " SAUtils.GetAssistantType use default. showType :" .. tostring(showType) .. " skinId:" .. tostring(skinId))
  end
  return showType
end
function SAUtils.PandoraId2ActivityId(pandoraId)
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  local activityId = pandoraSystem.pandora2Id[tonumber(pandoraId)]
  return activityId
end
function SAUtils.ActivityId2PandoraId(activityId)
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  for k, v in pairs(pandoraSystem.pandora2Id) do
    if v == activityId then
      return k
    end
  end
  printf("ActivityId2PandoraId not found activityId:%s", activityId)
end
function SAUtils.FindActivity(activityId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local subActivity = ActivityNewSystem.GetActivityByID(activityId)
  if not subActivity then
    for k, v in pairs(ActivityNewSystem.dataMap) do
      for kk, vv in pairs(v.List) do
        if vv.ID == activityId then
          printf("SAUtils.FindActivity found activityId:%s", activityId)
          return vv
        end
      end
    end
  end
  return subActivity
end
function SAUtils.JumpUrl(videoUrl, jumpUrl)
  printf("SAUtils.JumpUrl videoUrl:%s, jumpUrl:%s", videoUrl, jumpUrl)
  if videoUrl and videoUrl ~= "" then
    local video_url = SAUtils.GetVideoUrlByLanguage(videoUrl)
    printf("SAUtils.JumpUrl video_url:%s", video_url)
    UIManager.ShowUI(UIManager.UI_Config.SaLiveVideoFullScreenPlayer, video_url)
    return
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local jump_url = webModule:AddParameterByPersonalInfo(jumpUrl, true, true)
  printf("SAUtils.JumpUrl jump_url:%s", jump_url)
  GlobalData.JumpUrl(jump_url)
end
function SAUtils.GetVideoUrlByLanguage(videoUrl)
  if string.find(videoUrl, "CN") then
    local lan = Client.GetCurrentLanguage()
    videoUrl = string.gsub(videoUrl, "CN", lan)
  end
  return videoUrl
end
function SAUtils.IsMainCityJump(jumpUrl)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jumpUrl)
  return params and params.module == tostring(BP_ENUM_MODULE_MAIN_CITY_ENTER)
end
function SAUtils.GetCurrentSuitInfo()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
  if not myAvatar then
    return nil, nil
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local suitItemID, customData = myAvatar:GetModel():GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if not suitItemID or suitItemID == 0 then
    return nil, nil
  end
  local itemConfig = CDataTable.GetTableData("Item", suitItemID)
  if not itemConfig then
    return suitItemID, nil
  end
  local itemQuality = itemConfig.ItemQuality
  local clothLevel = 3
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(suitItemID) then
    clothLevel = 1
  else
    if itemQuality == 7 then
      clothLevel = 2
    end
    if 8 <= itemQuality then
      clothLevel = 1
    end
  end
  return suitItemID, itemQuality, clothLevel
end
function SAUtils.SetIsInOneClickUI(value)
  IsInOneClickUI = value
end
function SAUtils.GetIsInOneClickUI()
  return IsInOneClickUI
end
return SAUtils