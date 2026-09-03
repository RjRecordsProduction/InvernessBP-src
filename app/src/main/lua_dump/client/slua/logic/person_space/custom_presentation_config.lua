local custom_presentation_config = {}
custom_presentation_config.TabID = {
  All = 1,
  Strength = 2,
  Collect = 3,
  Home = 4,
  WOW = 5,
  Relation = 6,
  Othter = 7
}
custom_presentation_config.ModuleID = {
  Common_RankIntegralLevel = 1,
  PeakGame_RankIntegralLevel = 2,
  KingMark = 3,
  Collect_Level = 4,
  Home = 5,
  WOW_Author = 6,
  Relation = 7,
  WOW_Play = 8,
  MetroSegment = 9,
  SeasonYear = 10,
  Title = 11,
  Achievement = 12
}
custom_presentation_config.NewModuleID = {
  Common_RankIntegralLevelMax = 1,
  PeakGame_RankIntegralLevelMax = 2,
  KingMark = 3,
  Collect_Level = 4,
  Home = 5,
  WOW_Author = 6,
  Relation = 7,
  WOW_Play = 8,
  MetroSegment = 9,
  SeasonYear = 10,
  Common_RankIntegralLevel = 11,
  PeakGame_RankIntegralLevel = 12,
  Relax_RankIntegralLevel = 13,
  Relax_RankIntegralLevelMax = 14,
  KingMarkMax = 15,
  Title = 16,
  Achievement = 17,
  Popularity = 18,
  Honor = 19,
  RP_Level = 20,
  WoWpass_Level = 21,
  CardCollect = 22
}
custom_presentation_config.allPropertyMap = {
  "showType",
  "alias_id",
  "summary_id",
  "honer_id",
  "peakAce_id",
  "card_score",
  "rank_segment_id",
  "honer_count",
  "peakAce_count",
  "advance_num",
  "relation_uid",
  "alias_title",
  "pround_level",
  "popularity",
  "relex_rankId",
  "relation_type",
  "relation_intimacy",
  "bp_season",
  "bp_isBuyElite",
  "bp_level",
  "author_level"
}
custom_presentation_config.cantUsedProperty = {
  "showType",
  "honer_count",
  "peakAce_count",
  "alias_title",
  "card_score",
  "advance_num",
  "relation_type",
  "relation_intimacy",
  "bp_season",
  "bp_isBuyElite",
  "bp_level",
  "popularity",
  "pround_level",
  "relex_rankId",
  "author_level"
}
local ModuleID = custom_presentation_config.ModuleID
local NewModuleID = custom_presentation_config.NewModuleID
custom_presentation_config.EmptyModuleData = {
  mId = 0,
  mData = {}
}
custom_presentation_config.DefaultPresentationData = {
  [1] = {
    mId = ModuleID.Common_RankIntegralLevel,
    mData = {}
  },
  [2] = {
    mId = 0,
    mData = {}
  },
  [3] = {
    mId = 0,
    mData = {}
  },
  [4] = {
    mId = 0,
    mData = {}
  }
}
custom_presentation_config.SlotNum = 4
custom_presentation_config.LargeSlotIndex = 1
custom_presentation_config.LargeSlotNum = 1
custom_presentation_config.SmallModuleMinSelectedSlotNum = 2
function custom_presentation_config.GetUIItemByModuleID(moduleID, isLarge)
  log(bWriteLog and "custom_presentation_config.GetUIItemByModuleID moduleID = " .. moduleID .. ", isLarge = " .. (isLarge and "true" or "false"))
  local ui_config = UIManager.UI_Config
  local uiItems = {
    [ModuleID.Common_RankIntegralLevel] = {
      ui_config.Common_Info_RankIntegralLevel_Large_Item,
      ui_config.Common_Info_RankIntegralLevel_Small_Item
    },
    [ModuleID.PeakGame_RankIntegralLevel] = {
      ui_config.Common_Info_RankIntegralLevel_Large_Item,
      ui_config.Common_Info_RankIntegralLevel_Small_Item
    },
    [ModuleID.KingMark] = {
      ui_config.Common_Info_RankIntegralLevel_Large_Item,
      ui_config.Common_Info_RankIntegralLevel_Small_Item
    },
    [ModuleID.Collect_Level] = {
      ui_config.Common_Info_CollectLevel_Large_Item,
      ui_config.Common_Info_CollectLevel_Small_Item
    },
    [ModuleID.Home] = {
      ui_config.Common_Info_Home_Large_Item,
      ui_config.Common_Info_Home_Small_Item
    },
    [ModuleID.WOW_Author] = {
      ui_config.Common_Info_WowLevel_Large_Item,
      ui_config.Common_Info_WowLevel_Small_Item
    },
    [ModuleID.Relation] = {
      ui_config.Common_Info_Relation_Large_Item,
      ui_config.Common_Info_Relation_Small_Item
    },
    [ModuleID.WOW_Play] = {
      ui_config.Common_Info_WowPlay_Large_Item,
      ui_config.Common_Info_WowPlay_Small_Item
    },
    [ModuleID.MetroSegment] = {
      ui_config.Common_Info_RankIntegralLevel_Large_Item,
      ui_config.Common_Info_RankIntegralLevel_Small_Item
    },
    [ModuleID.SeasonYear] = {
      ui_config.Common_Info_AnnualBadge_Large_Item,
      ui_config.Common_Info_AnnualBadge_Small_Item
    }
  }
  local uiItemConfig = uiItems[moduleID]
  if uiItemConfig == nil then
    log_warning(bWriteLog and "custom_presentation_config.GetUIItemByModuleID moduleID " .. moduleID .. " not found")
    return nil
  end
  local uiItem = isLarge and uiItemConfig[1] or uiItemConfig[2]
  if uiItem == nil then
    log_warning(bWriteLog and "custom_presentation_config.GetUIItemByModuleID moduleID " .. moduleID .. " not found " .. (isLarge and "large" or "small") .. " UIItem")
    return nil
  end
  return uiItem
end
function custom_presentation_config.GetUIItemByModuleIDForRoleInfoCardShow(moduleID, isLarge, isV)
  log(bWriteLog and "custom_presentation_config.GetUIItemByModuleIDForRoleInfoCardShow moduleID = " .. moduleID .. ", isLarge = " .. (isLarge and "true" or "false"))
  local ui_config = UIManager.UI_Config
  local uiItems = {
    [ModuleID.Common_RankIntegralLevel] = {
      large = {
        V = ui_config.Common_Info_RankIntegralLevel_Large_New_Item,
        default = ui_config.Common_Info_RankIntegralLevel_Large_Item
      },
      small = {
        default = ui_config.Common_Info_RankIntegralLevel_Small_Item
      }
    },
    [ModuleID.PeakGame_RankIntegralLevel] = {
      large = {
        V = ui_config.Common_Info_RankIntegralLevel_Large_New_Item,
        default = ui_config.Common_Info_RankIntegralLevel_Large_Item
      },
      small = {
        default = ui_config.Common_Info_RankIntegralLevel_Small_Item
      }
    },
    [ModuleID.KingMark] = {
      large = {
        V = ui_config.Common_Info_RankIntegralLevel_Large_New_Item,
        default = ui_config.Common_Info_RankIntegralLevel_Large_Item
      },
      small = {
        default = ui_config.Common_Info_RankIntegralLevel_Small_Item
      }
    },
    [ModuleID.Collect_Level] = {
      large = {
        V = ui_config.Common_Info_CollectLevel_Large_Item_V_UIBP,
        default = ui_config.Common_Info_CollectLevel_Large_Item
      },
      small = {
        default = ui_config.Common_Info_CollectLevel_Small_Item
      }
    },
    [ModuleID.Home] = {
      large = {
        V = ui_config.Common_Info_Home_Large_Item_V_UIBP,
        default = ui_config.Common_Info_Home_Large_Item
      },
      small = {
        default = ui_config.Common_Info_Home_Small_Item
      }
    },
    [ModuleID.WOW_Author] = {
      large = {
        V = ui_config.Common_Info_WowLevel_Large_Item_V_UIBP,
        default = ui_config.Common_Info_WowLevel_Large_Item
      },
      small = {
        default = ui_config.Common_Info_WowLevel_Small_Item
      }
    },
    [ModuleID.Relation] = {
      large = {
        V = ui_config.Common_Info_Relation_Large_Item_V_UIBP,
        default = ui_config.Common_Info_Relation_Large_Item
      },
      small = {
        default = ui_config.Common_Info_Relation_Small_Item
      }
    },
    [ModuleID.WOW_Play] = {
      large = {
        V = ui_config.Common_Info_WowPlay_Large_Item_V_UIBP,
        default = ui_config.Common_Info_WowPlay_Large_Item
      },
      small = {
        default = ui_config.Common_Info_WowPlay_Small_Item
      }
    },
    [ModuleID.MetroSegment] = {
      large = {
        V = ui_config.Common_Info_RankIntegralLevel_Large_New_Item,
        default = ui_config.Common_Info_RankIntegralLevel_Large_Item
      },
      small = {
        default = ui_config.Common_Info_RankIntegralLevel_Small_Item
      }
    },
    [ModuleID.SeasonYear] = {
      large = {
        V = ui_config.Common_Info_AnnualBadge_Large_New_Item,
        default = ui_config.Common_Info_AnnualBadge_Large_Item
      },
      small = {
        default = ui_config.Common_Info_AnnualBadge_Small_Item
      }
    }
  }
  local uiItemConfig = uiItems[moduleID]
  if uiItemConfig == nil then
    log_warning(bWriteLog and "custom_presentation_config.GetUIItemByModuleIDForRoleInfoCardShow moduleID " .. moduleID .. " not found")
    return nil
  end
  local uiItem
  if isLarge then
    if isV then
      uiItem = uiItemConfig.large.V or uiItemConfig.large.default
    else
      uiItem = uiItemConfig.large.default
    end
  else
    uiItem = uiItemConfig.small.default
  end
  if uiItem == nil then
    log_warning(bWriteLog and "custom_presentation_config.GetUIItemByModuleIDForRoleInfoCardShow moduleID " .. moduleID .. " not found " .. (isLarge and "large" or "small") .. " UIItem")
    return nil
  end
  return uiItem
end
custom_presentation_config.EditCheckCanShowModule = {
  [ModuleID.PeakGame_RankIntegralLevel] = function(uid)
    if not uid then
      return
    end
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local peakgame_segment_id = LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
    return peakgame_segment_id ~= nil
  end,
  [ModuleID.WOW_Author] = function(uid)
    if not uid then
      return
    end
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    return LogicUGCAuthor:NewCheckPlayerIsAuthor(tonumber(uid))
  end,
  [ModuleID.WOW_Play] = function(uid)
    return false
  end,
  [ModuleID.SeasonYear] = function(uid)
    if not uid then
      return
    end
    local season_year_util = require("client.logic.season_year.util.season_year_util")
    if season_year_util.CheckFunctionIsOpen() then
      return true
    else
      return false
    end
  end
}
custom_presentation_config.EditCheckCanShowModuleNew = {
  [NewModuleID.PeakGame_RankIntegralLevel] = function(uid)
    if not uid then
      return
    end
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local peakgame_segment_id = LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
    return peakgame_segment_id ~= nil
  end,
  [NewModuleID.WOW_Author] = function(uid)
    if not uid then
      return
    end
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    return LogicUGCAuthor:NewCheckPlayerIsAuthor(tonumber(uid))
  end,
  [NewModuleID.SeasonYear] = function(uid)
    if not uid then
      return
    end
    local season_year_util = require("client.logic.season_year.util.season_year_util")
    if season_year_util.CheckFunctionIsOpen() then
      return true
    else
      return false
    end
  end,
  [NewModuleID.Relax_RankIntegralLevelMax] = function(uid)
    return false
  end,
  [NewModuleID.WoWpass_Level] = function(uid)
    return false
  end,
  [NewModuleID.WOW_Play] = function(uid)
    return false
  end
}
local ESlateColorStylingMode = import("ESlateColorStylingMode")
custom_presentation_config.LargeBGColor = {
  [ModuleID.Common_RankIntegralLevel] = {
    SpecifiedColor = {
      R = 0.337164,
      G = 0.015209,
      B = 0.021219,
      A = 1.0
    },
    ColorUseRule = ESlateColorStylingMode.UseColor_Specified
  },
  [ModuleID.PeakGame_RankIntegralLevel] = {
    SpecifiedColor = {
      R = 0.337164,
      G = 0.015209,
      B = 0.021219,
      A = 1.0
    },
    ColorUseRule = ESlateColorStylingMode.UseColor_Specified
  },
  [ModuleID.KingMark] = function(args)
    if args and not args.isKingMarkEmpty then
      return {
        SpecifiedColor = {
          R = 0.337164,
          G = 0.015209,
          B = 0.021219,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      }
    end
  end,
  [ModuleID.MetroSegment] = {
    SpecifiedColor = {
      R = 0.492188,
      G = 0.258521,
      B = 0.02179,
      A = 1.0
    },
    ColorUseRule = ESlateColorStylingMode.UseColor_Specified
  },
  [ModuleID.Collect_Level] = function(args)
    local rank = args.rank
    local colorList = {
      [1] = {
        SpecifiedColor = {
          R = 1.0,
          G = 0.508881,
          B = 0.242281,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [2] = {
        SpecifiedColor = {
          R = 1.0,
          G = 0.508881,
          B = 0.242281,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [3] = {
        SpecifiedColor = {
          R = 1.0,
          G = 0.508881,
          B = 0.242281,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [4] = {
        SpecifiedColor = {
          R = 1.0,
          G = 0.508881,
          B = 0.242281,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [5] = {
        SpecifiedColor = {
          R = 1.0,
          G = 1.0,
          B = 0.3564,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [6] = {
        SpecifiedColor = {
          R = 1.0,
          G = 1.0,
          B = 0.3564,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [7] = {
        SpecifiedColor = {
          R = 0.238398,
          G = 0.313989,
          B = 0.496933,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      }
    }
    return colorList[rank]
  end,
  [ModuleID.WOW_Author] = function(args)
    local level = args.level
    local colorList = {
      {
        levelRange = {0, 0},
        color = {
          SpecifiedColor = {
            R = 0.122139,
            G = 0.122139,
            B = 0.122139,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {1, 8},
        color = {
          SpecifiedColor = {
            R = 0.033105,
            G = 0.366253,
            B = 0.191202,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {1, 8},
        color = {
          SpecifiedColor = {
            R = 0.033105,
            G = 0.366253,
            B = 0.191202,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {9, 17},
        color = {
          SpecifiedColor = {
            R = 0.0185,
            G = 0.141263,
            B = 0.514918,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {18, 20},
        color = {
          SpecifiedColor = {
            R = 0.181164,
            G = 0.016807,
            B = 0.658375,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {21, 23},
        color = {
          SpecifiedColor = {
            R = 0.651406,
            G = 0.01096,
            B = 0.450786,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {24, 26},
        color = {
          SpecifiedColor = {
            R = 0.283149,
            G = 0.021219,
            B = 0.027321,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {27, 29},
        color = {
          SpecifiedColor = {
            R = 0.760525,
            G = 0.351533,
            B = 0.016807,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      },
      {
        levelRange = {30, 30},
        color = {
          SpecifiedColor = {
            R = 1.0,
            G = 0.181164,
            B = 0.043735,
            A = 1.0
          },
          ColorUseRule = ESlateColorStylingMode.UseColor_Specified
        }
      }
    }
    for k, v in pairs(colorList) do
      if level >= v.levelRange[1] and level <= v.levelRange[2] then
        return v.color
      end
    end
    return nil
  end,
  [ModuleID.Relation] = function(args)
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    local EIntimacyType = IntimacyAwardSystem.EIntimacyType
    local param = args.param
    local colorList = {
      [EIntimacyType.Bromance] = {
        SpecifiedColor = {
          R = 0.059511,
          G = 0.502887,
          B = 1.0,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [EIntimacyType.Lover] = {
        SpecifiedColor = {
          R = 0.610496,
          G = 0.076185,
          B = 0.514918,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [EIntimacyType.Buddy] = {
        SpecifiedColor = {
          R = 0.863157,
          G = 0.450786,
          B = 0.021219,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [EIntimacyType.BFF] = {
        SpecifiedColor = {
          R = 0.83077,
          G = 0.238398,
          B = 0.337164,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      },
      [EIntimacyType.Family] = {
        SpecifiedColor = {
          R = 0.982251,
          G = 0.23074,
          B = 0.109462,
          A = 1.0
        },
        ColorUseRule = ESlateColorStylingMode.UseColor_Specified
      }
    }
    return colorList[param]
  end
}
custom_presentation_config.SmallItemTipsPrefix = {
  [ModuleID.Common_RankIntegralLevel] = 79770,
  [ModuleID.PeakGame_RankIntegralLevel] = 79771,
  [ModuleID.Collect_Level] = 79774,
  [ModuleID.WOW_Author] = 79772,
  [ModuleID.Relation] = function(args)
    local friendType = args.friendType
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local namePrefix = LogicFriend.GetRelationText(friendType)
    return namePrefix .. "-"
  end,
  [ModuleID.WOW_Play] = 79773,
  [ModuleID.SeasonYear] = 85103
}
custom_presentation_config.GetShowModuleDataFunc = {
  [ModuleID.Relation] = function(uid)
    uid = tonumber(uid)
    local friend_intimacy_net_tool = require("client.slua.logic.friend.Intimacy.friend_intimacy_net_tool")
    local uidInfoList = friend_intimacy_net_tool.GetBuildInitmacyUidList(uid)
    local list = {}
    for k, v in pairs(uidInfoList) do
      list[k] = {
        uid = v.uid
      }
    end
    return list
  end
}
custom_presentation_config.GetCheckModuleDataFunc = {
  [ModuleID.Relation] = function(mData1, mData2)
    return mData1.uid == mData2.uid
  end
}
custom_presentation_config.GetServerDataFunc = {
  [ModuleID.KingMark] = function(args)
    local AceImprintHandler = require("client.network.Protocol.AceImprintHandler")
    AceImprintHandler.send_get_ace_imprint_detail_req(args.uid)
  end,
  [ModuleID.WOW_Play] = function(args)
    if not (args and args.uid) or tonumber(args.uid) == tonumber(DataMgr.roleData.uid) then
      return
    end
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    LogicUGCAuthor:RequestAuthorInfo(tonumber(args.uid))
  end,
  [ModuleID.WOW_Author] = function(args)
    if not (args and args.uid) or tonumber(args.uid) == tonumber(DataMgr.roleData.uid) then
      return
    end
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    LogicUGCAuthor:RequestAuthorInfo(tonumber(args.uid))
  end,
  [ModuleID.Relation] = function(args)
    if not args or not args.uid then
      return
    end
    local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
    if tonumber(args.uid) == tonumber(DataMgr.roleData.uid) then
      PersonSpaceSystem.get_intimacy_relation_req()
    else
      PersonSpaceSystem.get_other_intimacy_relation_req(args.uid)
    end
  end,
  [ModuleID.SeasonYear] = function(args)
    if not args or not args.uid then
      return
    end
    local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
    if tonumber(args.uid) == tonumber(DataMgr.roleData.uid) then
      logic_season_year_badge:ReqSeasonYearBadgeInfo(false)
    else
      logic_season_year_badge:ReqOtherSeasonYearBadgeInfo(tonumber(args.uid))
    end
  end
}
custom_presentation_config.CheckModuleDataCanUse = {
  [ModuleID.Relation] = {
    func = function(uid, mdata)
      if not (uid and mdata) or not mdata.uid then
        return false
      end
      local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
      local intimacyInfo = logic_friend_intimacy:GetIntimacyInfo(uid, mdata.uid)
      local intimacyType = logic_friend_intimacy:GetIntimacyType(uid, mdata.uid)
      return intimacyInfo ~= nil and 0 < intimacyType
    end,
    notice = 656039
  },
  [ModuleID.WOW_Author] = {
    func = function(uid, mdata)
      if not uid then
        return false
      end
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      return LogicUGCAuthor:NewCheckPlayerIsAuthor(tonumber(uid))
    end,
    notice = 33853
  }
}
custom_presentation_config.WOWSmallTipsShowOffset = {
  Lobby_RoleInfo_Card_Show_UIBP = {X = -32.0, Y = 0},
  Lobby_RoleInfo_Card_Editor_UIBP = {X = -32.0, Y = 0},
  MainCity_Info_UIBP = {X = -27.0, Y = 0}
}
return custom_presentation_config