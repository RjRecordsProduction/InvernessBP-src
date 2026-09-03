local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
local logic_music_const = require("client.slua.logic.pubgm_music.logic_music_const")
local logic_pubgm_music_util = require("client.slua.logic.pubgm_music.logic_pubgm_music_util")
local LOBBY = logic_music_const.E_CurPage.LobbyEdit
local CAR = logic_music_const.E_CurPage.CarEdit
local HomePlayerMusic = logic_music_const.E_CurPageRepresentation[logic_music_const.E_CurPage.HomePlayerMusic]
local E_MusicOwnedState = logic_music_const.E_MusicOwnedState
local logic_pubgm_music_option = {
  maxNum = {
    [LOBBY] = 10,
    [CAR] = 5,
    [HomePlayerMusic] = 10
  },
  musicList = {
    [LOBBY] = nil,
    [CAR] = nil,
    [HomePlayerMusic] = nil
  },
  repeatMode = {
    [LOBBY] = 0,
    [CAR] = 0,
    [HomePlayerMusic] = 0
  },
  repeatSong = {
    [LOBBY] = nil,
    [CAR] = nil,
    [HomePlayerMusic] = nil
  },
  isDataInit = {
    [LOBBY] = false,
    [CAR] = false,
    [HomePlayerMusic] = false
  }
}
function logic_pubgm_music_option.GetLobbyDetailData()
  if logic_pubgm_music_option.isDataInit[LOBBY] then
    return logic_pubgm_music_option.musicList[LOBBY], logic_pubgm_music_option.repeatMode[LOBBY], logic_pubgm_music_option.repeatSong[LOBBY]
  end
  logic_pubgm_music_option.isDataInit[LOBBY] = true
  local lobbyMusicList
  lobbyMusicList, logic_pubgm_music_option.repeatMode[LOBBY], logic_pubgm_music_option.repeatSong[LOBBY], logic_pubgm_music_option.maxNum[LOBBY] = logic_pubgm_music.GetSvrLobbyList()
  if not lobbyMusicList or not next(lobbyMusicList) then
    log(bWriteLog and "[muidarzhang] logic_pubgm_music_option.GetLobbyDetailData()\239\188\154 lobbyMusicList == nil")
    logic_pubgm_music_option.musicList[LOBBY] = nil
  else
    logic_pubgm_music_option.musicList[LOBBY] = logic_pubgm_music.ProcessLobbyMusic(E_MusicOwnedState.All, lobbyMusicList)
  end
  if not logic_pubgm_music_option.repeatMode[LOBBY] then
    logic_pubgm_music_option.repeatMode[LOBBY] = logic_music_const.E_MusicPlayMode.Loop
  end
  return logic_pubgm_music_option.musicList[LOBBY], logic_pubgm_music_option.repeatMode[LOBBY], logic_pubgm_music_option.repeatSong[LOBBY], logic_pubgm_music_option.maxNum[LOBBY]
end
function logic_pubgm_music_option.GetCarDetailData()
  if logic_pubgm_music_option.isDataInit[CAR] then
    return logic_pubgm_music_option.musicList[CAR]
  end
  logic_pubgm_music_option.isDataInit[CAR] = true
  local carMusicList
  carMusicList, logic_pubgm_music_option.maxNum[CAR] = logic_pubgm_music.GetSvrCarList()
  if not carMusicList or not next(carMusicList) then
    log(bWriteLog and "[muidarzhang] logic_pubgm_music_option.GetCarDetailData()\239\188\154 carMusicList == nil")
    logic_pubgm_music_option.musicList[CAR] = nil
  else
    local musicData = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.Owned)
    logic_pubgm_music_option.musicList[CAR] = logic_pubgm_music_util.FilterData(carMusicList, musicData)
  end
  return logic_pubgm_music_option.musicList[CAR], logic_pubgm_music_option.maxNum[CAR]
end
function logic_pubgm_music_option.GetHomePlayerDetailData()
  if logic_pubgm_music_option.isDataInit[HomePlayerMusic] then
    return logic_pubgm_music_option.musicList[HomePlayerMusic]
  end
  logic_pubgm_music_option.isDataInit[HomePlayerMusic] = true
  local homePlayerMusicList
  local HomePlayerMusicMaxNum = 0
  homePlayerMusicList, HomePlayerMusicMaxNum = logic_pubgm_music.GetSvrHomePlayerList()
  logic_pubgm_music_option.maxNum[HomePlayerMusic] = HomePlayerMusicMaxNum or 10
  if not homePlayerMusicList or not next(homePlayerMusicList) then
    log(bWriteLog and "[wzp] logic_pubgm_music_option.GetHomePlayerDetailData(): homePlayerMusicList == nil")
    logic_pubgm_music_option.musicList[HomePlayerMusic] = nil
  else
    local musicData = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.All)
    logic_pubgm_music_option.musicList[HomePlayerMusic] = logic_pubgm_music_util.FilterData(homePlayerMusicList, musicData)
  end
  if not logic_pubgm_music_option.repeatMode[HomePlayerMusic] then
    logic_pubgm_music_option.repeatMode[HomePlayerMusic] = logic_music_const.E_MusicPlayMode.Loop
  end
  return logic_pubgm_music_option.musicList[HomePlayerMusic], logic_pubgm_music_option.maxNum[HomePlayerMusic]
end
function logic_pubgm_music_option.OnMusicBoxSetBgmRsp()
  logic_pubgm_music_option.ClearLobbyData()
end
function logic_pubgm_music_option.OnCarMusicSetRsp()
  logic_pubgm_music_option.ClearCarData()
end
function logic_pubgm_music_option.OnHomePlayerMusicSetRsp()
  logic_pubgm_music_option.ClearHomePlayerData()
end
function logic_pubgm_music_option.OnMusicBoxDataRsp()
  logic_pubgm_music_option.ClearLobbyData()
  logic_pubgm_music_option.ClearCarData()
  logic_pubgm_music_option.ClearHomePlayerData()
end
function logic_pubgm_music_option.ClearLobbyData()
  logic_pubgm_music_option.musicList[LOBBY] = nil
  logic_pubgm_music_option.repeatMode[LOBBY] = logic_music_const.E_MusicPlayMode.Loop
  logic_pubgm_music_option.repeatSong[LOBBY] = nil
  logic_pubgm_music_option.maxNum[LOBBY] = 10
  logic_pubgm_music_option.isDataInit[LOBBY] = false
end
function logic_pubgm_music_option.ClearCarData()
  logic_pubgm_music_option.musicList[CAR] = nil
  logic_pubgm_music_option.maxNum[CAR] = 5
  logic_pubgm_music_option.isDataInit[CAR] = false
end
function logic_pubgm_music_option.ClearHomePlayerData()
  logic_pubgm_music_option.musicList[HomePlayerMusic] = nil
  logic_pubgm_music_option.maxNum[HomePlayerMusic] = 20
  logic_pubgm_music_option.isDataInit[HomePlayerMusic] = false
end
function logic_pubgm_music_option.Destroy()
  UIManager.CloseUI(UIManager.UI_Config.pubgm_music_option)
end
return logic_pubgm_music_option