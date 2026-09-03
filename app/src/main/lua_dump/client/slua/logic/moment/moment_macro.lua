local moment_macro = {
  ENUM_MOMENT_SHARE_TYPE = {
    PICTURE = 0,
    QUICK_SHOOT = 1,
    REPLAY = 2,
    OVB_REPORT = 3,
    SEASON_LOOKBACK_ENTRANCE = 4,
    SEASON_LOOKBACK_LONG_IMAGE = 5,
    MANOR_SHARE = 6
  },
  ENUM_KILL_TIME_UI_TYPE = {ONLY_SHOW_UI = 0, NORMAL = 1},
  ENUM_SOURCE_TYPE = {
    SELF = 1,
    FRIEND = 2,
    HOT = 3,
    OTHER = 4,
    SQUARE = 5,
    WOWSQUARE = 6
  },
  ENUM_TAB_LIMIT_TYPE = {
    SELF = 1,
    FRIEND = 2,
    HOT = 3,
    OTHER = 4,
    SQUARE = 5,
    MESSAGE = 6
  },
  ENUM_MOMENT_SHARE_SOURCE_TYPE = {
    PICTURE = 1,
    QUICK_SHOOT = 2,
    REPLAY = 3,
    OVB_REPORT = 4,
    SEASON_LOOKBACK_ENTRANCE = 5,
    SEASON_LOOKBACK_LONG_IMAGE = 6,
    UGC_COMMENT_SHARE = 7,
    MANOR_SHARE = 8,
    UGC_Friends_Share = 9,
    UGC_Work_Sharing = 10,
    UGC_WORK_SQUARE = 11,
    UGC_WORK_WONDERFUL = 12,
    POPULARITY_PK_HELP = 13
  },
  Enum_ID_TYPE = {
    Move = 1,
    ScaleOrRotate = 2,
    Complete = 5
  },
  ENUM_MOMENT_TYPE = {
    DEFAULT = 0,
    OVB_REPORT = 1,
    SEASON_LOOKBACK_ENTRANCE = 2,
    SEASON_LOOKBACK_LONG_IMAGE = 3,
    UGC_COMMENT_SHARE = 4,
    MANOR_SHARE = 5,
    UGC_COLLECTION_LIST = 6,
    UGC_Work_Sharing = 7,
    UGC_WORK_SQUARE = 8,
    UGC_WORK_WONDERFUL = 9,
    POPULARITY_PK_HELP = 10
  },
  ENUM_MOMENT_RANDOMTEXT_TYPE = {
    COMMON = 1,
    GET_ITEM = 2,
    RESULT_DATA = 3,
    RESULT_RANK = 4,
    REPLAY = 5,
    SEASON_LOOKBACK = 6,
    MANOR = 7,
    CARD_COLLECTION_EXCHANGE = 8
  },
  ENUM_MESSAGE_TYPE = {
    LIKE_TYPE = 1,
    REPLY_TYPE = 2,
    EMOJI_LIKE_TYPE = 3,
    BEEN_AT_TYPE = 4
  },
  ENUM_ALBUM_TAB_TYPE = {
    Photo = 1,
    Video = 2,
    HomeAlbum = 3,
    MainCity = 4
  }
}
local AlbumTabTextIdConfig = {
  [moment_macro.ENUM_ALBUM_TAB_TYPE.Photo] = 18949,
  [moment_macro.ENUM_ALBUM_TAB_TYPE.Video] = 24503,
  [moment_macro.ENUM_ALBUM_TAB_TYPE.HomeAlbum] = 64782,
  [moment_macro.ENUM_ALBUM_TAB_TYPE.MainCity] = 656026
}
moment_macro.
function moment_macro.CheckPhoto(type)
  if moment_macro.ENUM_MOMENT_SHARE_TYPE.PICTURE == type then
    return true
  elseif moment_macro.ENUM_MOMENT_SHARE_TYPE.QUICK_SHOOT == type then
    return true
  elseif moment_macro.ENUM_MOMENT_SHARE_TYPE.SEASON_LOOKBACK_LONG_IMAGE == type then
    return true
  elseif moment_macro.ENUM_MOMENT_SHARE_TYPE.MANOR_SHARE == type then
    return true
  end
  return false
end
function moment_macro.CheckReplay(type)
  if moment_macro.ENUM_MOMENT_SHARE_TYPE.REPLAY == type then
    return true
  end
  return false
end
function moment_macro.CheckReport(type)
  if moment_macro.ENUM_MOMENT_SHARE_TYPE.OVB_REPORT == type then
    return true
  end
  return false
end
function moment_macro.IsReportMomentType(type)
  if moment_macro.ENUM_MOMENT_TYPE.OVB_REPORT == type then
    return true
  end
  return false
end
function moment_macro.IsManorShareType(type)
  return moment_macro.ENUM_MOMENT_TYPE.MANOR_SHARE == type
end
function moment_macro.IsPopularityPKHelpType(type)
  return moment_macro.ENUM_MOMENT_TYPE.POPULARITY_PK_HELP == type
end
function moment_macro.IsSeasonLookBackEntranceType(type)
  if moment_macro.ENUM_MOMENT_TYPE.SEASON_LOOKBACK_ENTRANCE == type then
    return true
  end
  return false
end
function moment_macro.IsSeasonLookBackShareType(type)
  if moment_macro.ENUM_MOMENT_SHARE_TYPE.SEASON_LOOKBACK_ENTRANCE == type then
    return true
  end
  return false
end
function moment_macro.IsSeasonLookBackLongImageType(type)
  if moment_macro.ENUM_MOMENT_TYPE.SEASON_LOOKBACK_LONG_IMAGE == type then
    return true
  end
  return false
end
function moment_macro.IsSeasonLookBackLongImageShareType(type)
  if moment_macro.ENUM_MOMENT_SHARE_TYPE.SEASON_LOOKBACK_LONG_IMAGE == type then
    return true
  end
  return false
end
function moment_macro.IsUGCCommentShare(type)
  if moment_macro.ENUM_MOMENT_TYPE.UGC_COMMENT_SHARE == type or moment_macro.ENUM_MOMENT_TYPE.UGC_Work_Sharing == type or moment_macro.ENUM_MOMENT_TYPE.UGC_WORK_SQUARE == type then
    return true
  end
  return false
end
function moment_macro.IsUGCCollectionListShare(type)
  if moment_macro.ENUM_MOMENT_TYPE.UGC_COLLECTION_LIST == type then
    return true
  end
  return false
end
return moment_macro