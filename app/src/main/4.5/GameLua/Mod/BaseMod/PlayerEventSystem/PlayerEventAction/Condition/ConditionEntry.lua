local ConditionEntry = {
  EventConditions = {
    Event_InitWeapon = {
      EventType = "EVENTTYPE_PLAYEREVENT_WEAPON",
      EventID = "EVENTID_PLAYEREVENT_WEAPON_INIT",
      Constructor = "EventCondInitWeapon"
    },
    Event_PawnEnterState = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_PAWN_ENTER_STATE",
      Constructor = "EventCondPawnEnterOrLeaveState"
    },
    Event_PawnLeaveState = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_PAWN_LEAVE_STATE",
      Constructor = "EventCondPawnEnterOrLeaveState"
    },
    Event_KillPawn = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_KILL_PAWN",
      Constructor = "EventCondKillPawn"
    },
    Event_SwitchWeapon = {
      EventType = "EVENTTYPE_PLAYEREVENT_WEAPON",
      EventID = "EVENTID_PLAYEREVENT_WEAPON_SWITCHWEAPON"
    },
    Event_PawnModifyAttr = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTID_PLAYEREVENT_CHAR_ATTR",
      Constructor = "EventCondPawnModifyAttr"
    },
    Event_CauseDamage = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_PRE_CAUSE_DAMAGE",
      Constructor = "EventCauseDamage"
    },
    Event_TakeDamage = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_PRE_TAKE_DAMAGE",
      Constructor = "EventTakeDamage"
    },
    Event_CauseDamageOver = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_AFTER_CAUSE_DAMAGE",
      Constructor = "EventConditionBase"
    },
    Event_TakeDamageOver = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_AFTER_TAKE_DAMAGE",
      Constructor = "EventConditionBase"
    },
    Event_WeaponCauseDamage = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_WEPAON_PRE_TAKE_DAMAGE",
      Constructor = "EventConditionBase"
    },
    Event_WeaponCauseDamageOver = {
      EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
      EventID = "EVENTTYPE_PLAYEREVENT_WEPAON_AFTER_TAKE_DAMAGE",
      Constructor = "EventConditionBase"
    },
    Event_SkillEnterCoolDown = {
      EventType = "EVENTTYPE_PLAYEREVENT_SKILLBUFF",
      EventID = "EVENTID_PLAYEREVENT_SKILL_ENTER_COOLDOWN",
      Constructor = "EventConditionBase"
    }
  },
  ObjectConditions = {
    Cond_EmptyOrSubWeapon = {
      Constructor = "ObjectCondEmptyOrSubWeapon"
    },
    Cond_EmptyWeapon = {
      Constructor = "ObjectCondEmptyWeapon"
    },
    Cond_WeaponType = {
      Constructor = "ObjectCondWeaponType"
    },
    Cond_PawnState = {
      Constructor = "ObjectCondPawnState"
    },
    Cond_PawnStateNot = {
      Constructor = "ObjectCondPawnStateNot"
    },
    Cond_PawnAttrOpr = {
      Constructor = "ObjectCondPawnAttrOpr"
    },
    Cond_PawnType = {
      Constructor = "ObjectCondPawnType"
    },
    Cond_PawnHP = {
      Constructor = "ObjectCondPawnHP"
    },
    Cond_Distance = {
      Constructor = "ObjectCondDistance"
    },
    Cond_TargetClass = {
      Constructor = "ObjectCondTargetClass"
    },
    Cond_CustomDamage = {
      Constructor = "ObjectCondCustomDamage"
    },
    Cond_Probability = {
      Constructor = "ObjectCondProbability"
    },
    Cond_HitPos = {
      Constructor = "ObjectCondHitPos"
    },
    Cond_ExceptOtherTalent = {
      Constructor = "ObjectCondExceptOtherTalent"
    },
    Cond_DamageType = {
      Constructor = "ObjectCondDamageType"
    },
    Cond_CurrentWeaponType = {
      Constructor = "ObjectCondCurrentWeaponType"
    }
  }
}
function ConditionEntry.ActiveEventByFilterKey(FilterKey, EventTypeStr, EventIDStr, bActive)
  local LuaEventBridgeFunction = ConditionEntry.GetLuaEventBridgeFunction()
  if LuaEventBridgeFunction == nil then
    return false
  end
  LuaEventBridgeFunction:ActiveEventByFilterKey(FilterKey, EventTypeStr, EventIDStr, bActive)
  return true
end
function ConditionEntry.DeactivateEventsByFilterKey(FilterKey)
  local LuaEventBridgeFunction = ConditionEntry.GetLuaEventBridgeFunction()
  if LuaEventBridgeFunction == nil then
    return
  end
  LuaEventBridgeFunction:DeactivateEventsByFilterKey(FilterKey)
end
function ConditionEntry.CheckNeedPostEventWithFilterKey(FilterKey, EventTypeStr, EventIDStr, bCheckPostToLua)
  local LuaEventBridgeFunction = ConditionEntry.GetLuaEventBridgeFunction()
  if LuaEventBridgeFunction == nil then
    return false
  end
  return LuaEventBridgeFunction:CheckNeedPostEventWithFilterKey(FilterKey, EventTypeStr, EventIDStr, bCheckPostToLua)
end
function ConditionEntry.GetLuaEventBridgeFunction()
  local LuaEventBridgeFunction
  if Client and slua_GameFrontendHUD and slua_GameFrontendHUD.GetLuaEventBridge then
    LuaEventBridgeFunction = slua_GameFrontendHUD:GetLuaEventBridge()
  else
    local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
    local UGameLuaEnv = import("GameLuaEnv")
    local uLuaEnv = USubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, UGameLuaEnv)
    if slua.isValid(uLuaEnv) then
      LuaEventBridgeFunction = uLuaEnv:GetLuaEventBridge()
    end
  end
  return LuaEventBridgeFunction
end
function ConditionEntry.CreateEventConditions(PlayerKey, Params)
  local EventConditionsTable = {}
  local PushToRetTable = function(EventTypeStr, EventIDStr, CondInst)
    local EventTypeReal = _G[EventTypeStr]
    local EventIDReal = _G[EventIDStr]
    if EventTypeReal == nil or EventIDReal == nil then
      print(bWriteLog and string.format("ConditionFactory:CreateEventConditions failed, EventType:[%d], EventID:[%s] error", EventTypeStr, EventIDStr))
      return
    end
    local Type2IDTable = EventConditionsTable[EventTypeReal]
    if Type2IDTable == nil then
      Type2IDTable = {}
      EventConditionsTable[EventTypeReal] = Type2IDTable
    end
    Type2IDTable[EventIDReal] = CondInst
  end
  for _, Param in pairs(SplitStr(Params, "|")) do
    local BeginBracket = string.find(Param, "%(")
    local EndBracket = string.find(Param, "%)")
    local TypeID = ""
    local ParamsTable = {}
    if BeginBracket and EndBracket then
      TypeID = string.sub(Param, 1, BeginBracket - 1)
      ParamsTable = SplitStr(string.sub(Param, BeginBracket + 1, EndBracket - 1), "&")
    else
      TypeID = Param
    end
    local ConditionDefine = ConditionEntry.EventConditions[TypeID]
    if ConditionDefine == nil then
    elseif not ConditionEntry.ActiveEventByFilterKey(PlayerKey, ConditionDefine.EventType, ConditionDefine.EventID, true) then
    elseif ConditionDefine.Constructor ~= nil then
      local PList = {
        "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.EventCondition.",
        ConditionDefine.Constructor
      }
      local EventCond = require(table.concat(PList))
      if EventCond == nil then
      else
        PushToRetTable(ConditionDefine.EventType, ConditionDefine.EventID, EventCond(table.unpack(ParamsTable)))
      end
    else
      PushToRetTable(ConditionDefine.EventType, ConditionDefine.EventID, true)
    end
  end
  return EventConditionsTable
end
function ConditionEntry.CreateObjectConditions(Params)
  local RetTable = {}
  for _, Param in pairs(SplitStr(Params, "|")) do
    local BeginBracket = string.find(Param, "%(")
    local EndBracket = string.find(Param, "%)")
    local TypeID = ""
    local ParamsTable = {}
    if BeginBracket and EndBracket then
      TypeID = string.sub(Param, 1, BeginBracket - 1)
      ParamsTable = SplitStr(string.sub(Param, BeginBracket + 1, EndBracket - 1), "&")
    else
      TypeID = Param
    end
    local ConditionDefine = ConditionEntry.ObjectConditions[TypeID]
    if ConditionDefine == nil then
    else
      local PList = {
        "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ObjectCondition.",
        ConditionDefine.Constructor
      }
      local ObjCond = require(table.concat(PList))
      if ObjCond == nil then
      else
        local ObjCondInst = ObjCond(table.unpack(ParamsTable))
        table.insert(RetTable, ObjCondInst)
      end
    end
  end
  return RetTable
end
function ConditionEntry.EvaluateConditions(ObjectConditions, ...)
  if _G.next(ObjectConditions) ~= nil then
    for _, CondElement in pairs(ObjectConditions) do
      if not CondElement:Evaluate(...) then
        return false
      end
    end
  end
  return true
end
return ConditionEntry