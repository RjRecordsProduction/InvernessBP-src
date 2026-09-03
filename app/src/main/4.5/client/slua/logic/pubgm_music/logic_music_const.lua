local data_config_marco = require("client.logic.data.data_config_marco")
local logic_music_const = {
  C_ServerConfigName = data_config_marco.music_box_music_table,
  C_DefaultCoverPath = "/Game/UMG/Texture/Lobby_NoAtlas/Music_Player/Music_icon_CD/Music_icon_CD_01_128.Music_icon_CD_01_128",
  DRAG_DROP_ITEM_PATH = "/Game/UMG/UI_BP/Music_Player/Music_Player_car_Item.Music_Player_car_Item",
  SAMPLETIME = 20,
  ShowNameDuration = 5,
  E_MusicGiftState = {
    Can = 0,
    Gifted = 1,
    Cannot = 2
  },
  E_CurPage = {
    LobbyEdit = 0,
    CarEdit = 1,
    Lobby = 2,
    DynamicMusic = 3,
    ClassicalMusic = 4,
    OtherSocialLobby = 5,
    Component = 6,
    Home = 7,
    HomeConsoleMusic = 8,
    HomePlayerMusic = 9,
    Wedding = 10
  },
  E_DontPlaySamplePage = {
    [7] = true,
    [8] = true,
    [10] = true
  },
  E_CurPageRepresentation = {
    [9] = 2
  },
  E_MusicPlayMode = {
    Loop = 0,
    Random = 1,
    SingleLoop = 2
  },
  E_MusicDownloadType = {
    None = 0,
    HDmpve = 1,
    CDN = 2
  },
  E_MusicPlayStage = {
    Pause = 0,
    Play = 1,
    Stop = 2
  },
  E_MusicOwnedState = {
    All = 1,
    AllValid = 2,
    Owned = 3,
    NotOwned = 4,
    Expire = 5
  },
  E_Step = {NEXT = 1, PRE = -1},
  E_CurMusicTime = {
    Duration = 1,
    PlayTime = 2,
    RemainTime = 3
  },
  MusicEditStateLocalizeTextList = {
    [0] = 29402,
    [1] = 29403,
    [2] = 64836
  },
  MusicOwnedStateLocalizeText = {
    [3] = 6483,
    [4] = 6484
  }
}
return logic_music_const