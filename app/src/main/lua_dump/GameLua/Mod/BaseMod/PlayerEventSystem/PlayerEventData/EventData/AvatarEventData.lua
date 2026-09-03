local AvatarEventData = {
  AvatarActionType = {LOGIC_EQUIP = 4, MESH_EQUIP = 5}
}
function AvatarEventData:Init(bClient)
  AvatarEventData.__super.Init(self, bClient)
  self.ItemEventIDToOprType = {}
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_AVATAR_LOGIC_EQUIPPED] = self.AvatarActionType.LOGIC_EQUIP
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_AVATAR_MESH_EQUIPPED] = self.AvatarActionType.MESH_EQUIP
  self.ItemIdToEventActions = nil
end
function AvatarEventData:Clear()
  AvatarEventData.__super.Clear(self)
end
local class = require("class")
local CItemEventData = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.ItemEventData")
local CAvatarEventData = class(CItemEventData, nil, AvatarEventData)
return CAvatarEventData