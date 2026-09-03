local CoopEmotePCFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function CoopEmotePCFeature:ctor()
  self.curEmotePlayer = nil
end
function CoopEmotePCFeature:ReceiveBeginPlay()
  CoopEmotePCFeature.__super.ReceiveBeginPlay(self)
  if self:IsAutonomousProxy() then
    self:AddControlEvent(self.Owner, "OnCoopEmoteChange", self.HandleOnCoopEmoteChange, self)
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnStartFightingState, self)
  end
end
function CoopEmotePCFeature:HandleOnCoopEmoteChange(bShow, EmotePlayer)
  local isMainCity = GameStatus.IsInMainCity()
  print(bWriteLog and string.format("CoopEmotePCFeature:HandleOnCoopEmoteChange bShow:%s, EmoteId:%s, isMainCity:%s", bShow, EmotePlayer.EmoteId, isMainCity))
  local UIUtil = require("client.common.ui_util")
  local IconPath = UIUtil.GetItemSmallIcon(EmotePlayer.EmoteId)
  if not isMainCity then
    local InteractiveConfig = {IconPath = IconPath, TextID = 44708}
    if bShow then
      self.cur      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_JoinCoopEmote", InteractiveConfig)
    else
      self.curEmotePlayer = nil
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_JoinCoopEmote")
    end
  else
    local UIConfig = {
      [1] = {
        BtnImagePath = IconPath,
        TextId = 44708,
        ClickFuncName = "OnClickJoinCoopEmote"
      }
    }
    if bShow then
      self.cur      EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAIN_CITY_INTERACTIVE_UI_UPDATE, self, UIConfig)
    else
      self.curEmotePlayer = nil
      EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAIN_CITY_INTERACTIVE_UI_HIDE, self)
    end
  end
end
function CoopEmotePCFeature:OnClickJoinCoopEmote()
  if self.curEmotePlayer then
    print(bWriteLog and string.format("CoopEmotePCFeature:OnClickJoinCoopEmote PlayerKey:%s, EmoteId:%s", self.curEmotePlayer.PlayerKey, self.curEmotePlayer.EmoteId))
    local uChar = self.Owner:GetPlayerCharacterSafety()
    if not uChar or not uChar.CoopEmoteCharFeature then
      print(bWriteLog and "CoopEmotePCFeature:OnClickJoinCoopEmote not CoopEmoteCharFeature")
      return
    end
    if uChar.CoopEmoteCharFeature:IsInCoopEmote() then
      print(bWriteLog and "CoopEmotePCFeature:OnClickJoinCoopEmote already in coop emote")
      ShowNotice(44711)
      return
    end
    uChar.CoopEmoteCharFeature:MarkPreEmoteID(self.curEmotePlayer.EmoteId)
    uChar:RPC_Server_JoinCoopEmote(self.curEmotePlayer)
    uChar:CheckNearPlayingCoopEmote()
  else
    print(bWriteLog and "CoopEmotePCFeature:OnClickJoinCoopEmote curEmotePlayer is nil")
  end
end
function CoopEmotePCFeature:OnStartFightingState()
  print(bWriteLog and "CoopEmotePCFeature:OnStartFightingState")
  self.curEmotePlayer = nil
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_JoinCoopEmote")
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCoopEmotePCFeature = class(CFeatureBase, nil, CoopEmotePCFeature)
return CCoopEmotePCFeature