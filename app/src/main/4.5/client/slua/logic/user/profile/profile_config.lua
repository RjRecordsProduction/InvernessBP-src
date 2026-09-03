local profile_config = {
  CDTime = 1800,
  ENUM_REQ_SIZE = {
    WITH_RANK = 13,
    WITH_LBS = 30,
    NORMAL = 45
  }
}
local TimeUtil = require("client.common.time_util")
profile_config.Online2ProfileKey = {
  online = {key = "", default = 0},
  teamState = {
    key = "teamStateNew",
    default = 0
  },
  currentTeamAmount = {default = 0},
  maxTeamAmount = {default = 0},
  timeSinceGameBegin = {default = 0},
  timeSinceGameBeginStr = {
    key = "timeSinceGameBegin",
    default = "",
    func = TimeUtil.GetOpenedTimeStr
  },
  gameMode = {key = "game_mode", default = 0},
  gameSubMode = {
    key = "game_sub_mode",
    default = 0
  },
  watchUid = {key = "watch_uid", default = 0},
  enableWatch = {
    key = "enable_watch",
    default = 1
  },
  mentor_medal = {default = 0}
}
profile_config.Flag2ProfileKey = {
  rankdata = 1,
  lbs_warzone_info = 2,
  history_max_segment_level = 4,
  achieve_summary = 8,
  weapon_power_data = 16,
  history_max_segment_season_id = 2048
}
profile_config.InitKeyMap = {
  upvote = {default = 0},
  recent_upvote = {default = 0},
  startup_type = {
    func = GetSafeNumber
  },
  cur_avatar_box_id = {default = 0},
  chat_banned_ts = {default = 0},
  remarks_name = {default = ""},
  intimacy = {default = 0},
  online = {default = 0},
  teamState = {default = 0},
  currentTeamAmount = {default = 0},
  maxTeamAmount = {default = 0},
  timeSinceGameBegin = {default = 0},
  timeSinceGameBeginStr = {default = ""},
  gameMode = {default = 0},
  gameSubMode = {default = 0},
  watchUid = {default = 0},
  enableWatch = {
    key = "enable_watch",
    default = 1
  },
  segment_rankInfo = {
    key = "allstar_segment_rank_info"
  },
  timestamp = {
    default = 0,
    func = FuncUtil.GetServerTimeInSec
  },
  pve_level = {default = 1},
  pve_exp = {default = 0},
  ip_region = {default = ""},
  is_del = {default = false},
  mentor_medal = {default = 0},
  custom_setting_share_info = {
    key = "csetting_share_info",
    default = {}
  },
  activity_teams = {
    default = {}
  },
  allstar_zone_id = {key = "zone_id"},
  evaluation = {
    default = {}
  },
  frd_status_id = {default = 0},
  frd_status_end_time = {default = 0},
  frd_custom_txt = {default = ""},
  frd_icon_idx = {default = 0},
  pround_info = {
    default = {}
  },
  psmatch_view_pk_switch = {default = 1}
}
return profile_config