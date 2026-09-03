local achievement_macro = {
  ENUM_DISPLAY_TYPE = {
    ALL = 1,
    FINISHED = 2,
    NOTFINISH = 3
  },
  ENUM_SORT_RULE = {
    FINISHTIME = 1,
    SCORE = 2,
    PROGRESS = 3,
    QUALITY = 4
  },
  ENUM_SORT_NEWRULE = {
    DEFAULT = 1,
    FINISHTIMEUP = 3,
    FINISHTIMEDOWN = 2,
    SCOREUP = 5,
    SCOREDOWN = 4,
    PROGRESSUP = 7,
    PROGRESSDOWN = 6,
    QUALITYUP = 9,
    QUALITYDOWN = 8
  },
  ENUM_SORT_ORDER = {POSITIVE = 101, RESERVE = 102},
  ENUM_ACHIEVEMENT_CATEGORY = {
    COMMON = 0,
    DISCONTINUED = 1,
    HIDDEN = 2
  },
  VIRTUAL_CONDITION_ID = 1766
}
local DisplayTypeTextId = {
  [achievement_macro.ENUM_DISPLAY_TYPE.ALL] = 4462,
  [achievement_macro.ENUM_DISPLAY_TYPE.FINISHED] = 11149,
  [achievement_macro.ENUM_DISPLAY_TYPE.NOTFINISH] = 4037
}
achievement_macro.local SortRuleTextId = {
  [achievement_macro.ENUM_SORT_RULE.FINISHTIME] = 4542,
  [achievement_macro.ENUM_SORT_RULE.SCORE] = 9365,
  [achievement_macro.ENUM_SORT_RULE.PROGRESS] = 31149,
  [achievement_macro.ENUM_SORT_RULE.QUALITY] = 12072
}
achievement_macro.local SortOrderTextId = {
  [achievement_macro.ENUM_SORT_ORDER.POSITIVE] = 43336,
  [achievement_macro.ENUM_SORT_ORDER.RESERVE] = 43521
}
achievement_macro.local AchievementCategoryPriority = {
  [achievement_macro.ENUM_ACHIEVEMENT_CATEGORY.DISCONTINUED] = 1,
  [achievement_macro.ENUM_ACHIEVEMENT_CATEGORY.HIDDEN] = 2,
  [achievement_macro.ENUM_ACHIEVEMENT_CATEGORY.COMMON] = 3
}
achievement_macro.local AchievementSeqCfg_TabID = {
  ID_All = 0,
  ID_Common = 1,
  ID_Progress = 2,
  ID_Social = 3,
  ID_Honor = 4,
  ID_Pistol = 5,
  ID_Set = 6,
  ID_Glorious_Moment = 7,
  ID_Home = 8
}
achievement_macro.local AchievementSeqCfg_Index = {
  Index_Home = 0,
  Index_All = 1,
  Index_Glorious_Moment = 2,
  Index_Pistol = 3,
  Index_Honor = 4,
  Index_Progress = 5,
  Index_Set = 6,
  Index_Social = 7,
  Index_Common = 8
}
achievement_macro.local AchievementSeqCfg_SpecialHandler = {
  [602999] = {textNumber = 700},
  [603005] = {textNumber = 700},
  [603001] = {textNumber = 700},
  [603002] = {textNumber = 700},
  [70122] = {textNumber = 701}
}
achievement_macro.return achievement_macro