local EventDataMgr = {}
function EventDataMgr:Init(bClient)
  self.EventData = {}
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local itemActionData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.ItemEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_ITEM] = itemActionData()
  local weaponEventData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.WeaponEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_WEAPON] = weaponEventData()
  local characterEventData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.CharacterEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_CHARACTER] = characterEventData()
  local skillBuffEventData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.SkillBuffEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_SKILLBUFF] = skillBuffEventData()
  local vehicleEventData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.VehicleEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_VEHICLE] = vehicleEventData()
  local avatarActionData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.AvatarEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_AVATAR] = avatarActionData()
  local equipmentActionData = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.EventData.EquipmentEventData", true))
  self.EventData[EVENTTYPE_PLAYEREVENT_EQUIPT] = equipmentActionData()
  for k, v in pairs(self.EventData) do
    v:Init(bClient)
  end
end
function EventDataMgr:GetData(eventTypeID)
  if eventTypeID == nil then
    return nil
  end
  return self.EventData[eventTypeID]
end
function EventDataMgr:Clear()
  for i, v in pairs(self.EventData) do
    v:Clear()
  end
end
return EventDataMgr