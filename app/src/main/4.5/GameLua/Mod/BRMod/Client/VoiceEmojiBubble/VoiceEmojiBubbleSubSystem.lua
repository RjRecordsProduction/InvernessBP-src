local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
local BUBBLE_CFG_TABLE_NAME = "VoiceBubbleConfig"
local LOG_TAG = "[VoiceBubble]"
local VoiceEmojiBubbleSubSystem = {}
function VoiceEmojiBubbleSubSystem:OnInit()
  VoiceEmojiBubbleSubSystem.__super.OnInit(self)
  print(bWriteLog and LOG_TAG .. " OnInit")
  self.BubbleMap = {}
  self:RegistEvents()
end
function VoiceEmojiBubbleSubSystem:OnRelease()
  print(bWriteLog and LOG_TAG .. " OnRelease")
  self:ClearAllBubbles()
  VoiceEmojiBubbleSubSystem.__super.OnRelease(self)
end
function VoiceEmojiBubbleSubSystem:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_VOICE_BUBBLE, self.OnQuickVoice, self)
  if EVENTID_INGAME_ON_BATTLE_RESULT then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnBattleResult, self)
  end
end
function VoiceEmojiBubbleSubSystem:GetBubbleDataByMsgID(MsgID)
  if type(MsgID) ~= "number" or MsgID <= 0 then
    return nil
  end
  local Data = CDataTable.GetTableData(BUBBLE_CFG_TABLE_NAME, MsgID)
  if not Data then
    return nil
  end
  local BasePath = Data.BasePath or ""
  local BubblePath = Data.BubblePath or ""
  if BasePath == "" and BubblePath == "" then
    return nil
  end
  return {BasePath = BasePath, BubblePath = BubblePath}
end
function VoiceEmojiBubbleSubSystem:OnQuickVoice(_, __, MsgItem, ___)
  if not MsgItem then
    print(bWriteLog and LOG_TAG .. " OnQuickVoice skip: MsgItem is nil")
    return
  end
  local MsgID = MsgItem.msgID
  local PlayerIdentifier = MsgItem.playerIdentifier
  print(bWriteLog and string.format("%s OnQuickVoice recv MsgID=%s PlayerIdentifier=%s IsMe=%s", LOG_TAG, tostring(MsgID), tostring(PlayerIdentifier), tostring(___)))
  if not MsgID or MsgID == 0 then
    print(bWriteLog and LOG_TAG .. " OnQuickVoice skip: MsgID invalid")
    return
  end
  local BubbleData = self:GetBubbleDataByMsgID(MsgID)
  if not BubbleData then
    print(bWriteLog and string.format("%s OnQuickVoice skip: no BubbleConfig for MsgID=%s", LOG_TAG, tostring(MsgID)))
    return
  end
  if type(PlayerIdentifier) ~= "number" or PlayerIdentifier <= 0 then
    print(bWriteLog and string.format("%s OnQuickVoice skip: bad PlayerIdentifier=%s", LOG_TAG, tostring(PlayerIdentifier)))
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and LOG_TAG .. " OnQuickVoice skip: GameState invalid")
    return
  end
  local Character = GameState:FindCharacterByPlayerKey(PlayerIdentifier)
  if not slua.isValid(Character) then
    print(bWriteLog and string.format("%s OnQuickVoice skip: FindCharacterByPlayerKey failed, PlayerIdentifier=%s", LOG_TAG, tostring(PlayerIdentifier)))
    return
  end
  local PlayerState = Character.PlayerState
  if not slua.isValid(PlayerState) then
    print(bWriteLog and string.format("%s OnQuickVoice skip: PlayerState invalid, PlayerIdentifier=%s", LOG_TAG, tostring(PlayerIdentifier)))
    return
  end
  local MapKey = tostring(PlayerIdentifier)
  if not self:CheckCanShow(PlayerState, Character) then
    print(bWriteLog and string.format("%s OnQuickVoice skip: CheckCanShow=false, MapKey=%s", LOG_TAG, MapKey))
    self:RemoveBubble(MapKey)
    return
  end
  print(bWriteLog and string.format("%s OnQuickVoice pass to ShowOrUpdateBubble MapKey=%s", LOG_TAG, MapKey))
  self:ShowOrUpdateBubble(MapKey, PlayerState, BubbleData)
end
function VoiceEmojiBubbleSubSystem:OnBattleResult()
  self:ClearAllBubbles()
end
function VoiceEmojiBubbleSubSystem:ShowOrUpdateBubble(MapKey, PlayerState, BubbleData)
  local Existing = self.BubbleMap[MapKey]
  if Existing and slua.isValid(Existing.UIRoot) and Existing.SavedPlayerState == PlayerState then
    print(bWriteLog and string.format("%s ShowOrUpdateBubble reuse MapKey=%s", LOG_TAG, MapKey))
    Existing:ResetWith(BubbleData)
    return
  end
  if Existing then
    print(bWriteLog and string.format("%s ShowOrUpdateBubble drop stale MapKey=%s", LOG_TAG, MapKey))
    self:RemoveBubble(MapKey)
  end
  local UIConfig = UIManager.UI_Config_InGame.VoiceEmojiBubble
  if not UIConfig then
    print(bWriteLog and LOG_TAG .. " ShowOrUpdateBubble abort: UIConfig.VoiceEmojiBubble not registered")
    return
  end
  local Bubble = UIManager.ShowUI(UIConfig, PlayerState, BubbleData, MapKey)
  if not Bubble then
    print(bWriteLog and string.format("%s ShowOrUpdateBubble abort: UIManager.ShowUI returns nil, MapKey=%s", LOG_TAG, MapKey))
    return
  end
  print(bWriteLog and string.format("%s ShowOrUpdateBubble created MapKey=%s", LOG_TAG, MapKey))
  function Bubble.OnSelfClose(Key)
    if self.bIsValid and Key and self.BubbleMap[Key] == Bubble then
      self.BubbleMap[Key] = nil
    end
  end
  self.BubbleMap[MapKey] = Bubble
  self:RegistPlayerStateLifeWatch(MapKey, PlayerState)
end
function VoiceEmojiBubbleSubSystem:RemoveBubble(MapKey)
  local Bubble = self.BubbleMap[MapKey]
  if not Bubble then
    return
  end
  self.BubbleMap[MapKey] = nil
  if slua.isValid(Bubble) then
    Bubble.OnSelfClose = nil
    Bubble:CloseImmediately()
  end
end
function VoiceEmojiBubbleSubSystem:ClearAllBubbles()
  if not self.BubbleMap then
    return
  end
  for Key, Bubble in pairs(self.BubbleMap) do
    if slua.isValid(Bubble) then
      Bubble.OnSelfClose = nil
      Bubble:CloseImmediately()
    end
    self.BubbleMap[Key] = nil
  end
  self.BubbleMap = {}
end
function VoiceEmojiBubbleSubSystem:CheckCanShow(PlayerState, Character)
  if not slua.isValid(PlayerState) or not slua.isValid(Character) then
    print(bWriteLog and LOG_TAG .. " CheckCanShow=false reason=invalid PS/Character")
    return false
  end
  if PlayerState.LiveState == ExtraPlayerLiveState.InDied then
    print(bWriteLog and LOG_TAG .. " CheckCanShow=false reason=PlayerDied")
    return false
  end
  if Character.IsActorHiddenInGame and Character:IsActorHiddenInGame() then
    print(bWriteLog and LOG_TAG .. " CheckCanShow=false reason=ActorHiddenInGame")
    return false
  end
  if Character.IsHidden and Character:IsHidden() then
    print(bWriteLog and LOG_TAG .. " CheckCanShow=false reason=IsHidden")
    return false
  end
  return true
end
function VoiceEmojiBubbleSubSystem:RegistPlayerStateLifeWatch(MapKey, PlayerState)
  if not slua.isValid(PlayerState) then
    return
  end
  self:RemoveControlEvent(PlayerState, "OnLiveStateChangeEvent")
  self:AddControlEvent(PlayerState, "OnLiveStateChangeEvent", function()
    self:OnPlayerLiveStateChanged(MapKey, PlayerState)
  end, self)
end
function VoiceEmojiBubbleSubSystem:OnPlayerLiveStateChanged(MapKey, PlayerState)
  if not self.BubbleMap or not self.BubbleMap[MapKey] then
    return
  end
  if not slua.isValid(PlayerState) then
    self:RemoveBubble(MapKey)
    return
  end
  if PlayerState.LiveState == ExtraPlayerLiveState.InDied then
    self:RemoveBubble(MapKey)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VoiceEmojiBubbleSubSystem)