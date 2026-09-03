local GlobalBattleUIFunctionLibrary = {
  ModImpl = {}
}
function GlobalBattleUIFunctionLibrary:GetPlayerTeamColor(Index)
  if GlobalBattleUIFunctionLibrary.ModImpl.GetPlayerTeamColor then
    return GlobalBattleUIFunctionLibrary.ModImpl.GetPlayerTeamColor(Index)
  end
  local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
  if MapManagerSubsystem then
    return MapManagerSubsystem:GetPlayerColorByIndex(Index)
  end
  return self.Super:GetPlayerTeamColor(Index)
end
function GlobalBattleUIFunctionLibrary:GetQuickSignText(WorldContext, SignType, ActorID)
  print("GetQuickSignText:", SignType, ActorID)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  local item = ActorVoiceSystem.GetQuickSignItemBySignType(ActorID, SignType)
  if item then
    return item.DescID
  end
  return 0
end
function GlobalBattleUIFunctionLibrary:GetLocalizeText(TextID)
  return LocUtil.GetLocalizeResStr(TextID)
end
function GlobalBattleUIFunctionLibrary:GetLocalizeBattleText(Key)
  Key = math.tointeger(Key)
  local Localize = CDataTable.GetTableData("LocalizeRes", Key)
  if Localize then
    return Localize.TextValue
  end
  return nil
end
function GlobalBattleUIFunctionLibrary:GetLocalizeVoiceText(Key)
  Key = math.tointeger(Key)
  local VoiceText = CDataTable.GetTableData("VoiceText", Key)
  if VoiceText then
    return VoiceText.VoiceTextValue
  else
    return GlobalBattleUIFunctionLibrary:GetLocalizeBattleText(Key)
  end
end
local class = require("class")
local object = require("object")
return class(object, nil, GlobalBattleUIFunctionLibrary)