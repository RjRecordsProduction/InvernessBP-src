local QuickSignComponent = {}
local PUBGDoor = import("/Script/ShadowTrackerExtra.PUBGDoor")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local UKismetTextLibrary = import("KismetTextLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local FQuickSignMark = import("QuickSignMark")
local FQuickSignMsg = import("QuickSignMsg")
function QuickSignComponent:ctor()
  self.QuickTableConfigTable = {}
  self.ShowDistanceType = {
    1,
    2,
    3,
    4,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    31,
    32,
    33,
    37,
    44
  }
  self.ExtraAudioID = {
    [68] = 33938
  }
  self.Text_Colon = LocUtil.GetLocalizeResStr(4164)
end
function QuickSignComponent:ReceiveBeginPlay()
  print(bWriteLog and "QuickSignComponent:ReceiveBeginPlay")
  self.Super:ReceiveBeginPlay()
  self.IsBlockWhomInVoiceBlackList = true
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("bCanIntelligentSign", function()
      self:RefreshIntelligentSign()
    end)
    self:RefreshIntelligentSign()
  end
  if Client then
    local IntelligentSignConfig = CDataTable.GetTable("IntelligentSignConfig")
    if IntelligentSignConfig then
      for Index, ConfigInfo in ipairs(IntelligentSignConfig) do
        if ConfigInfo.ClassPath ~= "" then
          local ConfigClass = import(ConfigInfo.ClassPath)
          self.CheckParam.ValidActorClass:Add(ConfigClass, Index)
        end
        if ConfigInfo.TagParam ~= "" then
          self:AnalysisValidActorTags(Index, ConfigInfo.TagParam)
        end
      end
    end
  end
  self:LoadTableConfig()
end
function QuickSignComponent:LoadTableConfig()
  self.QuickTableConfigTable = {}
  local QuickSignCfgTable = CDataTable.GetTable("QuickSignCfg")
  for TableKey, TableRow in pairs(QuickSignCfgTable) do
    self.QuickTableConfigTable[TableRow.ID] = TableRow
    if TableRow.TagParam ~= "" then
      self:AnalysisConfigKeyTag(TableRow.ID, TableRow.TagParam)
    end
    if TableRow.ScriptParam ~= "" then
      self:AnalysisConfigKeyClass(TableRow.ID, TableRow.ScriptParam)
    end
    self.ConfigKeyToTextID:Add(TableRow.ID, TableRow.TextID)
    self.ConfigKeyToSignSubType:Add(TableRow.ID, TableRow.SignSubType)
    print(bWriteLog and string.format("QuickSignComponent:LoadTableConfig ID: %s, TextID: %s, ScriptParam: %s", TableRow.ID, TableRow.TextID, TableRow.ScriptParam))
  end
end
function QuickSignComponent:GenerateMarkInfo(MsgItem, MarkInfo)
  local ConfigKey = MsgItem.ConfigKey
  if self.QuickTableConfigTable[ConfigKey] ~= nil then
    local QuickTableRow = self.QuickTableConfigTable[ConfigKey]
    local QuickSignMarkInfo = FQuickSignMark()
    QuickSignMarkInfo.MsgID = MsgItem.MsgID
    QuickSignMarkInfo.MarkType = QuickTableRow.ID
    QuickSignMarkInfo.IconPath = QuickTableRow.IconPath
    QuickSignMarkInfo.IconBGPath = QuickTableRow.IconBGPath
    QuickSignMarkInfo.IconOuterPath = ""
    QuickSignMarkInfo.IconOuterBGPath = ""
    QuickSignMarkInfo.IconOutScreenIconPath = QuickTableRow.IconOutScreenPath
    QuickSignMarkInfo.IconOutScreenBGPath = QuickTableRow.IconOutScreenBGPath
    QuickSignMarkInfo.IconOutScreenArrowPath = QuickTableRow.OutScreenArrowPath
    QuickSignMarkInfo.ReplyID = QuickTableRow.RespondID
    QuickSignMarkInfo.Loc = MsgItem.HitPos
    QuickSignMarkInfo.MaxNum = QuickTableRow.MaxNum
    QuickSignMarkInfo.LifeSpan = QuickTableRow.LifeSpan
    QuickSignMarkInfo.SenderPlayerKey = ""
    QuickSignMarkInfo.bControlByMaxShowDis = true
    if ConfigKey == "M_APickUpWrapperActor" then
      self:PickupWrapperActorHandleLua(MsgItem.ParamString, QuickSignMarkInfo)
    end
    return true, QuickSignMarkInfo
  else
    return false, FQuickSignMark()
  end
end
function QuickSignComponent:PickupWrapperActorHandleLua(ParamString, QuickSignMarkInfo)
  local ItemID = tonumber(ParamString)
  if not ItemID then
    local StringUtil = require("common.string_util")
    local ItemIDString = StringUtil.Split(ParamString, "|")
    ItemID = tonumber(ItemIDString[1])
  end
  if not ItemID then
    return
  end
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if not ItemCfg then
    return
  end
  QuickSignMarkInfo.IconOuterPath = QuickSignMarkInfo.IconPath
  QuickSignMarkInfo.IconPath = ItemCfg.ItemSmallIcon or ""
end
function QuickSignComponent:PlayVoiceAutoLanguage(ActorID, AudioID, EventPath)
  local VoiceTransformSubsystem = SubsystemMgr:Get("VoiceTransformSubsystem")
  if EventPath ~= "" then
    print(bWriteLog and "QuickSignComponent:PlayVoiceAutoLanguage ModEventPath: " .. EventPath)
    local AudioUtil = require("client.common.audio_util")
    AudioUtil.PlayAudioAsync(EventPath)
  else
    local BankName = ""
    local EventName = ""
    if VoiceTransformSubsystem and VoiceTransformSubsystem.GetAutoLanguageMsg then
      BankName, EventName = VoiceTransformSubsystem:GetAutoLanguageMsg(ActorID, AudioID)
      print(bWriteLog and "QuickSignComponent:PlayVoiceAutoLanguage VoiceTransformSubsystem", BankName, EventName)
    end
    self:SwitchandLoadBankandPlay("Character", "Voice_Normal_Battle", BankName, EventName)
  end
  self:PlayVoiceCD(1)
end
function QuickSignComponent:PlayVoiceCD(Duration)
  self.IsPlayVoiceCooldown = true
  self:AddGameTimer(Duration, false, function()
    self.IsPlayVoiceCooldown = false
  end)
end
function QuickSignComponent:OrganizeMsg(TextID, PlayerName, IsSelf, StrParam, HitPos, MsgType, PlayerKey)
  local MsgContent = ""
  self:SetDistanceText(HitPos, MsgType)
  local sMarkText = self:GetMarkTextShowedInChatBox(PlayerKey, TextID)
  local ESearchCase = import("ESearchCase")
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(sMarkText, "<ChatQuickMsg>") then
    MsgContent = sMarkText
  else
    MsgContent = "<ChatQuickMsg>" .. sMarkText .. "</>"
  end
  MsgContent = MsgContent .. self.distanceString
  if StringUtil.StrFind(MsgContent, "{0}") then
    MsgContent = FuncUtil.GetFormatText(MsgContent, StrParam)
  end
  local NewName = "***"
  if IsSelf then
    local EGameReplayType = import("EGameReplayType")
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.GameReplayType == EGameReplayType.EGameReplayType_CompletePlayback then
      NewName = "Reported Player"
      return self.SelfColor .. NewName .. self.Text_Colon .. self.EndChar .. MsgContent
    end
    return self.SelfColor .. LocUtil.GetLocalizeResStr(101717) .. self.Text_Colon .. self.EndChar .. MsgContent
  else
    local EGameReplayType = import("EGameReplayType")
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.GameReplayType == EGameReplayType.EGameReplayType_CompletePlayback then
      if PlayerName == "Teammate 1" or PlayerName == "Teammate 2" or PlayerName == "Teammate 3" or PlayerName == "Teammate 4" then
        NewName = PlayerName
      end
      return self.TeammateColor .. NewName .. self.Text_Colon .. self.EndChar .. MsgContent
    end
    return self.TeammateColor .. PlayerName .. self.Text_Colon .. self.EndChar .. MsgContent
  end
end
function QuickSignComponent:ReportQuickSign(MsgItem)
  local TextID = self.ConfigKeyToTextID:Get(MsgItem.ConfigKey)
  if not TextID then
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local UseQuickMsgMap = PlayerState.UseQuickMsgMap
  local CurrentCount = 0
  if UseQuickMsgMap:Get(TextID) then
    CurrentCount = UseQuickMsgMap:Get(TextID)
    UseQuickMsgMap:Add(TextID, CurrentCount + 1)
  else
    UseQuickMsgMap:Add(TextID, 1)
  end
  print(bWriteLog and "QuickSignComponent:ReportQuickSign", TextID, CurrentCount)
end
function QuickSignComponent:RefreshIntelligentSign()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    local SettingValue = SettingSubsystem:GetUserSettings_Bool("bCanIntelligentSign")
    self.bCanIntelligentSign = SettingValue
    if not SettingValue then
      self:ClearIntelligentType()
    end
  end
end
function QuickSignComponent:TryChangeConfigKeyFunctionName(TargetActor)
  if slua.isValid(TargetActor) and TargetActor.MarkParamConfigKey then
    self.MarkParamConfigKey = TargetActor.MarkParamConfigKey
    return true
  end
  return false
end
function QuickSignComponent:GetExtraMarkParam(TargetActor, MsgType, Tag)
  local EQuickSignSubType = import("EQuickSignSubType")
  if TargetActor.VehicleDisplayName then
    self.MarkParamString = tostring(TargetActor.VehicleDisplayName)
    self.MarkParamSubType = EQuickSignSubType.MarkVehicle
    return true
  elseif TargetActor.TreasureChestMarkName then
    if TargetActor.TreasureChestMarkName ~= "" then
      local bIsOpen = TargetActor.bOpened and 1 or 0
      self.MarkParamString = string.format("%s|%s", TargetActor.TreasureChestMarkName, bIsOpen)
      self.MarkParamSubType = 44
    else
      self.MarkParamSubType = EQuickSignSubType.MarkPos
    end
    return true
  end
  if TargetActor.MarkParamSubType then
    self.MarkParamString = TargetActor.MarkParamString or ""
    self.MarkParamSubType = TargetActor.MarkParamSubType
    return true
  end
  if TargetActor.GetExtraMarkParam then
    local MarkParamStringTemp, MarkParamSubTypeTemp = TargetActor:GetExtraMarkParam(MsgType, Tag)
    self.MarkParamString = MarkParamStringTemp or ""
    self.MarkParamSubType = MarkParamSubTypeTemp or MsgType
    return true
  end
  return false
end
function QuickSignComponent:PickupWrapperActorHandle(Param, MarkInfo)
  local SetMarkInfo = function(MarkInfo, ItemID)
    if ItemID ~= nil then
      local ItemInfo = CDataTable.GetTableData("Item", ItemID)
      if ItemInfo then
        MarkInfo.IconOuterPath = MarkInfo.IconPath
        MarkInfo.IconPath = ItemInfo.ItemSmallIcon
        MarkInfo.bControlByMaxShowDis = true
      end
    end
  end
  local ItemID = math.tointeger(Param)
  if ItemID ~= nil then
    SetMarkInfo(MarkInfo, ItemID)
  else
    local StringUtil = require("common.string_util")
    local Params = StringUtil.Split(Param, "|")
    ItemID = math.tointeger(Params[1])
    SetMarkInfo(MarkInfo, ItemID)
  end
end
function QuickSignComponent:GetVoiceAudioID(MsgType)
  if not Client then
    return 0
  end
  local UserSettings = slua_GameFrontendHUD:GetUserSettings()
  if slua.isValid(UserSettings) then
    if 8 < MsgType then
      local Index = MsgType - 9
      local IDList = UserSettings.QuickSignIDList
      if 0 <= Index and IDList and Index < IDList:Num() then
        return IDList:Get(Index)
      end
    else
      local Index = MsgType - 1
      local WheelIDList = UserSettings.QuickSignWheelIDList
      if 0 <= Index and Index < WheelIDList:Num() then
        return WheelIDList:Get(Index)
      end
    end
  end
  if self.ExtraAudioID[MsgType] then
    return self.ExtraAudioID[MsgType]
  end
  return 0
end
function QuickSignComponent:SetDistanceText(HidPosition, MsgType)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local Dist = FVector.Dist2D(HidPosition, PlayerCharacter:K2_GetActorLocation())
  self.isShowDistance = false
  for _, Value in pairs(self.ShowDistanceType) do
    if Value == MsgType then
      self.isShowDistance = true
      break
    end
  end
  local KismetMathLibrary = import("KismetMathLibrary")
  local Dist = KismetMathLibrary.Round(Dist / 100.0)
  if 0.0 < Dist then
    local GlobalBattleUIFunctionLibrary = require("GameLua.Mod.BaseMod.Client.InGameUI.GlobalBattleUIFunctionLibrary")
    local Text = GlobalBattleUIFunctionLibrary:GetLocalizeVoiceText(25144)
    if string.find(Text, "{0}") and self.isShowDistance then
      if 800 < Dist then
        self.distanceString = LocUtil.GetLocalizeResStr(33861)
      else
        self.distanceString = FuncUtil.GetFormatText(Text, Dist)
      end
      self.CurDistance = Dist
    else
      self.distanceString = ""
      self.CurDistance = 0
    end
  else
    self.distanceString = ""
    self.CurDistance = 0
  end
end
function QuickSignComponent:SpectatorActorMark(OriMarkInfo, Actor)
  local EQuickSignSubType = import("EQuickSignSubType")
  local ConfigKey = ""
  local SubType = EQuickSignSubType.Invalid
  local PUBGDoorNormal = import("/Script/ShadowTrackerExtra.PUBGDoorNormal")
  if Game:IsClassOf(Actor, PUBGDoor) then
    if Actor.DoorState ~= 0 then
      ConfigKey = "M_APUBGDoor"
      SubType = EQuickSignSubType.MarkOpenDoor
    else
      ConfigKey = "M_APUBGClosedDoor"
      SubType = 37
    end
  elseif Game:IsClassOf(Actor, PUBGDoorNormal) then
    if Actor.OpenState ~= 0 then
      ConfigKey = "M_APUBGDoorNormal"
      SubType = EQuickSignSubType.MarkOpenDoor
    else
      ConfigKey = "M_APUBGClosedDoorNormal"
      SubType = 37
    end
  else
    return OriMarkInfo
  end
  local QuickSignMsg = FQuickSignMsg()
  QuickSignMsg.MsgID = OriMarkInfo.MsgID
  QuickSignMsg.PlayerName = OriMarkInfo.PlayerName
  QuickSignMsg.HitPos = OriMarkInfo.HitPos
  QuickSignMsg.  QuickSignMsg.ParamString = OriMarkInfo.ParamString
  QuickSignMsg.MsgType = SubType
  return QuickSignMsg
end
function QuickSignComponent:GetMarkTextShowedInChatBox(PlayerKey, OldTextID)
  local GlobalBattleUIFunctionLibrary = require("GameLua.Mod.BaseMod.Client.InGameUI.GlobalBattleUIFunctionLibrary")
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    local Character = GameState:FindCharacterByPlayerKey(PlayerKey)
    if slua.isValid(Character) then
      local Vehicle = Character:GetCurrentVehicle()
      if slua.isValid(Vehicle) and Vehicle.GetCurrentMotionState then
        local CurrentMotionState = Vehicle:GetCurrentMotionState()
        local EBallVehicleMotionState = import("EBallVehicleMotionState")
        if CurrentMotionState == EBallVehicleMotionState.EReadyForKick then
          local Text = GlobalBattleUIFunctionLibrary:GetLocalizeBattleText(44578)
          return Text
        end
      end
    end
  end
  local Text = GlobalBattleUIFunctionLibrary:GetLocalizeVoiceText(OldTextID)
  return Text
end
function QuickSignComponent:SetBoxMarkText(InputParam)
  local FinalText = ""
  local StringUtil = require("common.string_util")
  local Params = StringUtil.Split(InputParam, "|")
  local BoxName = LocUtil.GetLocalizeResStr(tonumber(Params[1]))
  local bOpenState = Params[2]
  local OpenText
  if bOpenState == "1" then
    OpenText = LocUtil.GetLocalizeResStr(74086)
  else
    OpenText = LocUtil.GetLocalizeResStr(74087)
  end
  FinalText = LocUtil.LocalizeResFormat(74085, BoxName, OpenText)
  return FinalText
end
function QuickSignComponent:GetStrArgument(QuickSignID, StringParam)
  local StringUtil = require("common.string_util")
  local FinalString = ""
  local AttachSlotName = ""
  local   if QuickSignID == "C_NeedAttachment" then
    if StringParam ~= "" then
      local StringUtil = require("common.string_util")
      local StrList = StringUtil.Split(StringParam, "|")
      for _, Str in pairs(StrList) do
        if tonumber(Str) then
          local num = tonumber(Str)
          local AttachSlotLocalID = self.WeaponAttachmentSocketTextIDMap:Get(num)
          if AttachSlotLocalID then
            AttachSlotName = LocUtil.GetLocalizeResStr(AttachSlotLocalID)
            if FinalString ~= "" then
              FinalString = FinalString .. ","
              FinalString = FinalString .. AttachSlotName
            else
              FinalString = FinalString .. AttachSlotName
            end
          end
        end
      end
    end
    if FinalString == "" then
      FinalString = LocUtil.GetLocalizeResStr(33927)
    end
  elseif QuickSignID == "C_NeedAmmo" then
    if StringParam ~= "" then
      local ItemData = CDataTable.GetTableData("Item", tonumber(StringParam))
      if ItemData then
        FinalString = ItemData.ItemName
      end
    end
    if FinalString == "" then
      FinalString = LocUtil.GetLocalizeResStr(33928)
    end
  elseif QuickSignID == "M_APickUpWrapperActor" then
    if StringParam ~= "" then
      local NumList = StringUtil.Split(StringParam, "|", 2)
      local ItemData = CDataTable.GetTableData("Item", tonumber(NumList[1]))
      if ItemData then
        if NumList[2] == nil or NumList[2] == "" or tonumber(NumList[2]) == 0 or 1 >= ItemData.MaxCount then
          FinalString = ItemData.ItemName
        else
          FinalString = ItemData.ItemName .. LocUtil.LocalizeResFormat(77835, NumList[2])
        end
      end
    end
    if FinalString == "" then
      FinalString = LocUtil.GetLocalizeResStr(33926)
    end
  elseif QuickSignID == "M_ASTExtraVehicleBase" then
    if StringParam ~= "" then
      FinalString = LocUtil.GetLocalizeResStr(StringParam)
    end
  elseif QuickSignID == "M_TreasureChest" then
    local FinalText = self:SetBoxMarkText(StringParam)
    FinalString = FinalText
  else
    FinalString = StringParam
  end
  return FinalString
end
function QuickSignComponent:GetLocalizeActorID(AudioKey)
  local ActorID = AudioKey // 100000
  local bIsActorInGlobal = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = PlayerController:GetChatComponent()
    if slua.isValid(ChatComponent) then
      bIsActorInGlobal = ChatComponent:IsActorInGlobal(ActorID)
    end
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local bIsBankExist = PufferManager.IsBankExistByActorID(ActorID)
  if (FuncUtil.IsPlayerJPKR() or bIsActorInGlobal) and bIsBankExist then
    return ActorID
  elseif FuncUtil.IsPlayerJP() then
    return 1
  else
    return 0
  end
end
function QuickSignComponent:GetTextID(SignType)
  local Data = CDataTable.GetTableData("QuickSignDefaultVoice", SignType)
  if Data then
    return Data.DescriptionID
  else
    return 0
  end
end
function QuickSignComponent:GetAudioID(ActorID, SignType, MsgID)
  if ActorID == 0 then
    local Data = CDataTable.GetTableData("QuickSignDefaultVoice", SignType)
    if Data and Data.GlobalVoice then
      return Data.GlobalVoice
    end
  elseif ActorID == 1 then
    local Data = CDataTable.GetTableData("QuickSignDefaultVoice", SignType)
    if Data and Data.JapanVoice then
      return Data.JapanVoice
    end
  end
  return MsgID % 100000
end
function QuickSignComponent:ShowMsgTipsVoice(MsgItem, IsSelf, PlayerKey)
  self.currMsg = MsgItem
  local QuickSignConfig = self.QuickTableConfigTable[MsgItem.ConfigKey]
  if not QuickSignConfig then
    return
  end
  local SignType = MsgItem.MsgType
  local ActorID = self:GetLocalizeActorID(MsgItem.AudioID)
  local TextID = self:GetTextID(SignType)
  local AudioID = self:GetAudioID(ActorID, SignType, MsgItem.AudioID)
  if MsgItem.NoAudio then
    AudioID = 0
  end
  if ActorID == 0 and TextID == 0 and AudioID == 0 then
    return
  end
  self.bCanShowMsg = true
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_RECEIVE_QUICK_MSG, IsSelf, SignType)
  if not self.bCanShowMsg then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = PlayerController:GetChatComponent()
    if slua.isValid(ChatComponent) then
      local StrParam = self:GetStrArgument(QuickSignConfig.ID, MsgItem.ParamString)
      local MsgString = self:OrganizeMsg(TextID, MsgItem.PlayerName, IsSelf, StrParam, MsgItem.HitPos, SignType, PlayerKey)
      if self.isShowDistance then
        ChatComponent:AddOneMarkToUIInner(IsSelf, MsgString)
      else
        ChatComponent.addToUIText = MsgString
        ChatComponent:AddOneMsgToUIInner(IsSelf)
      end
      self.currMsg.MsgID = ""
      self.currMsg.PlayerName = ""
      self.currMsg.ConfigKey = ""
      self.currMsg.audioID = 0
      self.currMsg.NoAudio = false
      self.currMsg.ParamString = ""
      self.currMsg.BindActorGUID = 0
      self.currMsg.RelationID = -1
      self.currMsg.PlayerKey = 0
      self.currMsg.MiniMapIconTypeId = 0
      self.currMsg.MsgType = 0
      self.currMsg.HitPos.X = 0
      self.currMsg.HitPos.Y = 0
      self.currMsg.HitPos.Z = 0
    end
  end
  if not self.IsPlayVoiceCooldown and self.CurDistance <= self.MaxShowVoiceDistance then
    local VoiceSDKInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if slua.isValid(VoiceSDKInterface) and VoiceSDKInterface:TeamSpeakerEnable() and AudioID ~= 0 then
      self:PlayVoiceAutoLanguage(ActorID, AudioID, QuickSignConfig.EventPath)
      self:PlayVoiceCD(1)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_OPEN_QUICK_CHAT, TextID)
  if not IsSelf and MsgItem.ConfigKey then
    local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
    local TacticalMarkCfg = IngameLikeConfig and IngameLikeConfig[IngameLikeConfig.TacticalMark]
    if TacticalMarkCfg and TacticalMarkCfg.ConfigKeys then
      for _, Key in ipairs(TacticalMarkCfg.ConfigKeys) do
        if MsgItem.ConfigKey == Key then
          print(bWriteLog and "QuickSignComponent:ShowMsgTipsVoice - TacticalMark triggered, ConfigKey:" .. tostring(MsgItem.ConfigKey))
          EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_TACTICAL_MARK_WHEEL, MsgItem.ConfigKey)
          break
        end
      end
    end
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CQuickSignComponent = class(object, nil, QuickSignComponent)
return CQuickSignComponent