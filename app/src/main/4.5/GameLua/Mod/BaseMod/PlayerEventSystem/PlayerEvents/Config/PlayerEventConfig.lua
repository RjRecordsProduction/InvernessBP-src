local Event_Config = {
  {
    eventType = EVENTTYPE_PLAYEREVENT_ITEM,
    eventID = EVENTID_PLAYEREVENT_PICKUPITEM,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleItemEvent",
    funcName = "PickupItem"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_ITEM,
    eventID = EVENTID_PLAYEREVENT_CONSUMEITEM,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleItemEvent",
    funcName = "ConsumeItem"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_ITEM,
    eventID = EVENTID_PLAYEREVENT_DROPITEM,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleItemEvent",
    funcName = "DropItem"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_ITEM,
    eventID = EVENTID_PLAYEREVENT_BACKPACKITEM_CLEANUP,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleItemEvent",
    funcName = "CleanupItem"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_CHARACTER,
    eventID = EVENTTYPE_PLAYEREVENT_PRE_TAKE_DAMAGE,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleCharacterEvent",
    funcName = "HandlePlayerTakeDamage"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_CHARACTER,
    eventID = EVENTTYPE_PLAYEREVENT_PRE_CAUSE_DAMAGE,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleCharacterEvent",
    funcName = "HandlePlayerCauseDamage"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_CHARACTER,
    eventID = EVENTTYPE_PLAYEREVENT_AFTER_TAKE_DAMAGE,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleCharacterEvent",
    funcName = "HandleAfterPlayerTakeDamage"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_WEAPON,
    eventID = EVENTID_PLAYEREVENT_WEAPON_INIT,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleWeaponEvent",
    funcName = "HandleInitWeapon"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_HANDLE,
    eventID = EVENTTYPE_PLAYEREVENT_HANDLE_INIT_WEAPONHANDLE,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleItemHandleEvent",
    funcName = "HandleInitWeaponHandle"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_CHARACTER,
    eventID = EVENTID_PLAYEREVENT_TRANSFORM,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleCharacterEvent",
    funcName = "PlayerTransform"
  },
  {
    eventType = EVENTTYPE_PLAYEREVENT_CHARACTER,
    eventID = EVENTID_PLAYEREVENT_TRANSFORMBACK,
    moduleName = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleCharacterEvent",
    funcName = "PlayerTransformBack"
  }
}
return Event_Config