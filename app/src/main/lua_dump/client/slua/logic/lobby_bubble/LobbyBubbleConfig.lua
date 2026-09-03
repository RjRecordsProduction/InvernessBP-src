local LobbyBubbleConfig = {
  E_ImportantActTab = 12,
  ENUM_CONDITION_TYPE = {
    RestrictZone = 1,
    IsBuy = 2,
    RPLimit = 3,
    SeasonId = 4,
    Version = 5,
    Client_Type = 6,
    Daily = 7,
    CountDown = 8
  },
  Enum_Open_Status = {Close = 0, Open = 1},
  Enum_Bubble_Queue_Type = {Middle = 1},
  Enum_Bubble_Status = {
    Hiding = 1,
    Waiting = 2,
    Showing = 3
  }
}
LobbyBubbleConfig.Enum_Lobby_Bubble_Type = {
  Shop = 1,
  Supply = 2,
  Rp = 3,
  Rp_CriticalHit = 4,
  Rp_Season_End = 5,
  SpecialOffer_End = 6,
  Activity = 7,
  LobbyBottomBanner = 8,
  RP_Experience = 101
}
LobbyBubbleConfig.Enum_Rp_Bubble_Type = {Item = 1, Act = 2}
local MiddleType = LobbyBubbleConfig.Enum_Bubble_Queue_Type.Middle
LobbyBubbleConfig.Enum_Bubble_Type = {
  [MiddleType] = {
    BlackFriday = 0,
    ReturnActivity = 1,
    SuperAirDrop = 2,
    SpecialOfferTips = 3,
    SpecialOfferEntrance = 4,
    SpecialActivityEntrance = 5,
    Activity = 6
  }
}
local MiddleBubbleType = LobbyBubbleConfig.Enum_Bubble_Type[MiddleType]
local Enum_Bubble_Status = LobbyBubbleConfig.Enum_Bubble_Status
LobbyBubbleConfig.Bubble_Queue = {
  [MiddleType] = {
    [MiddleBubbleType.ReturnActivity] = {
      status = Enum_Bubble_Status.Hiding,
      name = "ReturnActivity",
      bAutoShow = false,
      checkFunction = nil,
      action = nil
    },
    [MiddleBubbleType.SuperAirDrop] = {
      status = Enum_Bubble_Status.Hiding,
      name = "SuperAirDrop",
      bAutoShow = false,
      checkFunction = nil,
      action = nil
    },
    [MiddleBubbleType.SpecialOfferTips] = {
      status = Enum_Bubble_Status.Hiding,
      name = "SpecialOfferTips",
      bAutoShow = false,
      checkFunction = nil,
      action = nil
    },
    [MiddleBubbleType.SpecialOfferEntrance] = {
      status = Enum_Bubble_Status.Hiding,
      name = "SpecialOfferEntrance",
      bAutoShow = false,
      checkFunction = nil,
      action = nil
    },
    [MiddleBubbleType.SpecialActivityEntrance] = {
      status = Enum_Bubble_Status.Hiding,
      name = "SpecialActivityEntrance",
      bAutoShow = false,
      checkFunction = nil,
      action = nil
    },
    [MiddleBubbleType.Activity] = {
      status = Enum_Bubble_Status.Hiding,
      name = "Activity",
      bAutoShow = true,
      checkFunction = function()
        local ActivityBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityBubbleModule)
        local bubbleValid = ActivityBubbleModule:CheckBubbleValid()
        log(bWriteLog and "checkFunction bubbleValid = " .. tostring(bubbleValid))
        return bubbleValid
      end,
      action = {
        [Enum_Bubble_Status.Hiding] = function()
          EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_ACTIVITY_BUBBLE_UPDATE, false)
        end,
        [Enum_Bubble_Status.Waiting] = function()
          EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_ACTIVITY_BUBBLE_UPDATE, false)
          local ActivityBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityBubbleModule)
          ActivityBubbleModule:ResetShowTips()
        end,
        [Enum_Bubble_Status.Showing] = function()
          EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_ACTIVITY_BUBBLE_UPDATE, true)
        end
      }
    },
    [MiddleBubbleType.BlackFriday] = {
      status = Enum_Bubble_Status.Hiding,
      name = "BlackFriday",
      bAutoShow = false,
      checkFunction = function()
        local BlackFridayEntranceModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayEntranceModule)
        return BlackFridayEntranceModule:HasBubble()
      end,
      action = {
        [Enum_Bubble_Status.Hiding] = function()
          EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_ACTIVITY_BLACK_FRIDAY_LOBBY_ENTRANCE_SHOW_UPDATED, false)
        end,
        [Enum_Bubble_Status.Showing] = function()
          EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_ACTIVITY_BLACK_FRIDAY_LOBBY_ENTRANCE_SHOW_UPDATED, true)
        end
      }
    }
  }
}
return LobbyBubbleConfig