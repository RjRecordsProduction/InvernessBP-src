local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local woweditor_ui_configs = {
  ugc_mine_main = {
    keyName = "ugc_mine_main",
    moduleName = "client.slua.umg.WoWEditor.WoWEditorLobbyUI",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_MainPanel_UIBP.UGC_Mine_MainPanel_UIBP",
    isMainUI = false,
    uiStat = {
      name = "WoWEditor\229\136\155\228\189\156\229\164\167\229\142\133"
    }
  },
  ugc_mine_works = {
    keyName = "ugc_mine_works",
    moduleName = "client.slua.umg.WoWEditor.WoWEditorMine",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_WorksPanel_UIBP.UGC_Mine_WorksPanel_UIBP",
    isMainUI = false,
    uiStat = {
      name = "WoWEditor-\230\136\145\231\154\132\228\189\156\229\147\129"
    }
  },
  WoWEditor_DownloadLobbyTip_Popup = {
    keyName = "WoWEditor_DownloadLobbyTip_Popup",
    moduleName = "client.slua.umg.WoWEditor.popup.WoWEditor_DownloadLobbyTip_Popup",
    path = "/Game/Mod/Lobby/Base/Downloader/UMG/UI_BP/Download/Popup/Download_Tips_Popup_UIBP.Download_Tips_Popup_UIBP",
    uiStat = {
      name = "WoWEditor-\228\184\139\232\189\189\228\184\173\229\191\131\232\181\132\230\186\144\231\188\186\229\164\177\229\188\185\231\170\151"
    }
  },
  ugc_team_edit = {
    keyName = "ugc_team_edit",
    moduleName = "client.slua.umg.WoWEditor.WoWEditorTeamUI",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_TeamEdit_Popup_UIBP.UGC_TeamEdit_Popup_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "ugc_team_edit"
    }
  },
  Team_Invite_Tip_UIBP = {
    keyName = "Team_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.WoWEditor.WoWEditorTeamInviteUI",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Invite_Tip_UIBP.Team_Invite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "UGC-\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  }
}
return woweditor_ui_configs