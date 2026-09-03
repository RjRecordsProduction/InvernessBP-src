local card__config = require("client.slua.umg.PersonSpace.Card.Card_Config")
local PufferTlog = {}
PufferTlog.Enum_TLog_Optype = {
  Start = 1,
  Cancel = 2,
  Finish = 3,
  UIOperate = 4
}
PufferTlog.Enum_TLog_From = {
  None = -1,
  Click = 0,
  RecommendDownload = 1,
  RecommendDelete = 2,
  Delete = 3,
  Setting = 4,
  Auto = 5,
  Battle = 6,
  Prefetch = 7,
  PufferPatch = 8,
  JKBankPak = 9,
  PreDownload = 10,
  LobbyEntrance = 11,
  ModeSelect = 12,
  LobbyDownloader = 13,
  Room = 14,
  MissingPak = 16,
  InitFail = 17,
  NotEnoughSpace = 18,
  SetSpeedToZero = 19,
  SpeedIsZero = 20,
  DownloadError = 21,
  Illegal = 22,
  DeleteSavedCache = 23,
  AutoDownloadCfg = 24,
  SpaceAlert = 25,
  UGCMode = 26,
  UGCDownload = 27,
  UGCPause = 28,
  HomeDetails = 29,
  ChatMenuBp = 30,
  PlanPH_Navigation = 31,
  SocialIsland_PlayerInteract = 32,
  HomeDoorPlate = 33,
  PlanPH_GoldenTree = 34,
  PlanPH_Scene = 35,
  DetailAvatar = 36,
  DetailItemList = 37,
  CollectItem = 38,
  HomeAnniversary = 39,
  UFS = 40,
  MainCity = 41,
  Passive = 42,
  Stream = 43,
  UGCTeamEdit = 44,
  UploadSize = 45,
  Loading = 46,
  CollectionHall = 47,
  SocialLobby = 48,
  Card = 49,
  Wardrobe = 50
}
local Enum_DownloadDoubleConfirmScene = {
  None = 0,
  LobbyMainUI_Theme = 1,
  LobbyMainUI_SelfAvatar = 2,
  LobbyMainUI_TeamAvatar = 3
}
PufferTlog.
function PufferTlog.SendTLog(from, optype, key, extpara, force)
  local rate = 0
  if DataMgr.roleData and DataMgr.roleData.uid then
    local uid = tonumber(DataMgr.roleData.uid)
    uid = uid or 0
    rate = uid % 100
  end
  if rate ~= 0 and force ~= true then
    return
  end
  if GameStatus.IsInMainCity() then
    extpara = extpara or {}
    if type(extpara) == "table" then
      extpara.IsInMainCity = 1
    end
  end
  from = from or PufferTlog.Enum_TLog_From.Click
  log_format("PufferTlog.SendTLog. from=%s, optype=%s, key=%s, force=%s", from, optype, key, force)
  log_tree("PufferTlog.SendTLog. extpara = ", extpara)
  local PufferDownloadHandler = require("client.network.Protocol.PufferDownloadHandler")
  local info = {}
  info.  info.  info.  info.  PufferDownloadHandler.send_report_res_download_log(info)
end
function PufferTlog.IsNeedAutoPutOnAfterDownload(extraData, skipType)
  if extraData and extraData.bDownloadAutoPutOn and extraData.from then
    if skipType and 0 < skipType then
      for i = PufferTlog.Enum_TLog_From.DetailAvatar, PufferTlog.Enum_TLog_From.CollectItem do
        if extraData.from == i and i ~= skipType then
          return false
        end
      end
    elseif extraData.from >= PufferTlog.Enum_TLog_From.DetailAvatar or extraData.from <= PufferTlog.Enum_TLog_From.CollectItem then
      return false
    end
  end
  return true
end
return PufferTlog