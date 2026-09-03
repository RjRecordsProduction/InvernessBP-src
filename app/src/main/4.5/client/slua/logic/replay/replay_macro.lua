local replay_macro = {}
local EWonderfulType = UEnums.EWonderfulType
local WonderfulPlayType = {
  None = 0,
  FromLobby = 1,
  FromBattle = 2
}
replay_macro.local DeathPlayType = {
  None = 0,
  FromLobby = 1,
  FromBattle = 2
}
replay_macro.local WonderFulErrorCode = {
  None = 0,
  FileNameError = 1,
  FileNotExist = 2,
  LoadFileError = 3,
  SerializeError = 4,
  InPlayState = 5,
  NullPtr = 6,
  UncompressError = 7
}
replay_macro.local DeathErrorCode = {
  None = 0,
  FileNameError = 1,
  FileNotExist = 2,
  LoadFileError = 3,
  SerializeError = 4,
  InPlayState = 5,
  NullPtr = 6,
  UncompressError = 7
}
replay_macro.local PathType = {
  RELATIVE = 1,
  FULL = 2,
  ABSOLUTE = 3
}
replay_macro.local FileType = {
  INFO = ".info",
  JSON = ".json",
  REPLAY = ".replay",
  DEATH_INFO = ".deathInfo"
}
replay_macro.local ResourceStatus = {
  NeedUpdate = 1,
  Corrupted = 2,
  Normal = 3
}
replay_macro.local Main_Scene = {BATTLE = "BATTLE", LOBBY = "LOBBY"}
local Sub_Scene = {
  HISTORY = "HISTORY",
  MOMENT = "MOMENT",
  CHAT = "CHAT",
  LINK = "LINK",
  ACHIEVEUI = "ACHIEVEUI",
  RESULT = "RESULT",
  XMISSION_HISTORY = "XMISSION_HISTORY"
}
local Action = {
  PLAY = "PLAY",
  SHARE = "SHARE",
  TYPE = "TYPE",
  CLICKSHOW = "CLICKSHOW"
}
local Share_Detail = {CHAT = "SHARECHAT", DEEPLINK = "DEEPLINK"}
local Share_App = {
  SMS = "SMS",
  WHATSAPP = "WHATSAPP",
  LINE = "LINE",
  MESSENGER = "MESSENGER",
  SYSTEM = "SYSTEM"
}
local Chat_Channel = {
  WORLDCHANNEL = "WORLDCHANNEL",
  PRIVATECHANNEL = "PRIVATECHANNEL",
  CROPCHANNEL = "CROPCHANNEL",
  CHATROOMCHANNEL = "CHATROOMCHANNEL"
}
local OWNER = {SELF = "SELF", OTHER = "OTHER"}
replay_macro.TLOG = {
  Main_Scene = Main_Scene,
  Sub_Scene = Sub_Scene,
  Action = Action,
  Share_Detail = Share_Detail,
  OWNER = OWNER,
  Share_App = Share_App,
  }
replay_macro.SourceType = {
  CHAT = 1,
  SHARE = 2,
  MOMENT = 3,
  REPORTERROR = 4
}
replay_macro.ShareFileType = {ONLINE = 0, LOCAL = 1}
function replay_macro.SortLog(logTbl)
  local getValue = function(tbl, matchTbl)
    for i, v1 in ipairs(tbl) do
      for k, v2 in pairs(matchTbl) do
        if v1 == v2 then
          table.remove(tbl, i)
          return v1
        end
      end
    end
  end
  local retTbl = {}
  retTbl[#retTbl + 1] = getValue(logTbl, Main_Scene)
  retTbl[#retTbl + 1] = getValue(logTbl, Sub_Scene)
  retTbl[#retTbl + 1] = getValue(logTbl, Action)
  retTbl[#retTbl + 1] = getValue(logTbl, OWNER)
  retTbl[#retTbl + 1] = getValue(logTbl, Share_Detail)
  for i, v in ipairs(logTbl) do
    retTbl[#retTbl + 1] = v
  end
  return retTbl
end
return replay_macro