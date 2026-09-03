local NoticesConst = {}
NoticesConst.Scene = {
  VersionUpdate = "VersionUpdate",
  Login = "Login",
  Lobby = "Lobby",
  TxMission = "TxMission",
  Gamelet = "Gamelet",
  DelayNotices = "DelayNotices",
  DebugTest = "DebugTest"
}
NoticesConst.LogoutResetNotices = {
  [NoticesConst.Scene.Lobby] = true,
  [NoticesConst.Scene.TxMission] = true,
  [NoticesConst.Scene.Gamelet] = true,
  [NoticesConst.Scene.DelayNotices] = true
}
NoticesConst.MultiShowNotices = {
  [NoticesConst.Scene.VersionUpdate] = true,
  [NoticesConst.Scene.DebugTest] = true,
  [NoticesConst.Scene.Lobby] = true
}
NoticesConst.ITopScene = {
  UPDATE_SCENE_NOTICE = "1",
  MAINTENANCE_NOTICE_BEFORE_LOGIN = "2",
  COMMON_SCENE_BEFORE_LOGIN = "3",
  SLAP_SCENE_AFTER_LOGIN = "4",
  UPDATE_SHOW_IMAGE = "62",
  DOWNLOAD_SCENE_BEFORE_LOGIN = "65"
}
NoticesConst.NoticeContentType = {
  Text = 1,
  ImageOrBlueprint = 2,
  Gamelet = 3
}
NoticesConst.DataSource = {iTop = 1, Activity = 2}
return NoticesConst