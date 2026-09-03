local config_ugc_season_template = {}
local _TabID = {
  Award = 1,
  Rule = 2,
  MyMod = 3,
  AllMod = 4
}
config_ugc_season_template.Clocal _Award = {
  ID = _TabID.Award,
  LocKey = 68704,
  Module = "UGC_SeasonTemplate_Main",
  TLog = TLogEventDefine.UGC_EventThem_TemplateUITableShow,
  BGIndex = 0
}
local _Rule = {
  ID = _TabID.Rule,
  LocKey = 68705,
  Module = "UGC_SeasonTemplate_Main",
  TLog = TLogEventDefine.UGC_EventThem_TemplateUITableShow,
  BGIndex = 0
}
local _MyMod = {
  ID = _TabID.MyMod,
  LocKey = 68706,
  Module = "UGC_SeasonTemplate_Mod",
  TLog = TLogEventDefine.UGC_EventThem_TemplateUITableShow,
  BGIndex = 0
}
local _AllMod = {
  ID = _TabID.AllMod,
  LocKey = 85048,
  Module = "UGC_SeasonTemplate_AllMod",
  TLog = TLogEventDefine.UGC_EventThem_TemplateUITableShow,
  BGIndex = 0
}
local _MyAllModPrefab = {
  ID = _TabID.MyMod,
  LocKey = 68706,
  Module = "UGC_SeasonTemplate_AllMod_Prefab",
  TLog = TLogEventDefine.UGC_EventThem_TemplateUITableShow,
  Param = {IsMine = true},
  BGIndex = 1
}
local _AllModPrefab = {
  ID = _TabID.AllMod,
  LocKey = 85048,
  Module = "UGC_SeasonTemplate_AllMod_Prefab",
  TLog = TLogEventDefine.UGC_EventThem_TemplateUITableShow,
  Param = {IsMine = false},
  BGIndex = 1
}
local _Tab = {
  _Award,
  _Rule,
  _MyMod,
  _AllMod
}
local _TabPrefab = {
  _Award,
  _Rule,
  _MyAllModPrefab,
  _AllModPrefab
}
config_ugc_season_template.Cconfig_ugc_season_template.Clocal _Sort = {
  [1] = {LocKey = 1000, SortID = 1},
  [2] = {LocKey = 1001, SortID = 2}
}
config_ugc_season_template.Clocal _AwardTypeID = {
  Rank = 1,
  Join = 2,
  Hot = 3,
  Community = 4
}
local _AwardType = {
  [1] = {
    LocKey = 1000,
    Type = _AwardTypeID.Rank
  },
  [2] = {
    LocKey = 1001,
    Type = _AwardTypeID.Join
  },
  [3] = {
    LocKey = 1002,
    Type = _AwardTypeID.Hot
  },
  [4] = {
    LocKey = 1003,
    Type = _AwardTypeID.Community
  }
}
config_ugc_season_template.Clocal _ReuseFullType = {
  Content = 1,
  ActivityTime = 2,
  ParticipationCondition = 3
}
config_ugc_season_template.Clocal _EnumStep = {
  CreationPeriod = 1,
  PlayPeriod = 2,
  AuditPeriod = 3,
  ComplaintPeriod = 4,
  PublicityPeriod = 5
}
config_ugc_season_template.Clocal _RuleParamID = {
  Components = 1,
  EditTime = 2,
  ObjCnt = 3,
  LuaCodeBlockCnt = 4,
  LuaCodeTriggerCnt = 5,
  CopyMod = 6
}
config_ugc_season_template.Clocal _RequestType = {gamecenter = "gamecenter", match_hub = "match_hub"}
config_ugc_season_template.Clocal C_ModSearchRankType = {
  [1] = {
    Type = "type_publish_time",
    Name = 72014,
    LocRankType = "update_date"
  },
  [2] = {
    Type = "type_play_time_week_all_region",
    Name = 72011,
    LocRankType = "play_total_time"
  },
  [3] = {
    Type = "type_play_cnt",
    Name = 72012,
    LocRankType = "play_cnt"
  },
  [4] = {
    Type = "type_collect_cnt",
    Name = 72013,
    LocRankType = "collect_cnt"
  }
}
config_ugc_season_template.local Enum_CollectionPageTabType = {
  progress = 1,
  Over = 2,
  Joined = 3
}
config_ugc_season_template.C_return config_ugc_season_template