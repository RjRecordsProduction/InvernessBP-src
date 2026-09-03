local PufferConst = require("client.slua.logic.download.puffer_const")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
local ESlateVisibility = UEnums and UEnums.ESlateVisibility or {}
local Visible = ESlateVisibility.Visible
local Collapsed = ESlateVisibility.Collapsed
require("client.slua.config.ClientMacros.bp_macros")
require("client.common.game_status")
require("client.slua.config.ClientMacros.EFixedZOrder")
require("client.slua.config.ClientMacros.UIContainers")
require("client.common.SlateUI_ID")
local login_ui_configs = {
  splash_screen = {
    keyName = "splash_screen",
    moduleName = "client.slua.umg.NewUpdate.splash_screen_ui",
    path = "/Game/UMG/UI_BP/NewUpdate/SplashScreen_UIBP.SplashScreen_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\184\184\230\136\143\229\144\175\229\138\168-\233\151\170\229\177\143\231\149\140\233\157\162"
    }
  },
  splash_screen_ani_ui = {
    keyName = "splash_screen_ani_ui",
    moduleName = "client.slua.umg.NewUpdate.splash_screen_ani_ui",
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\184\184\230\136\143\229\144\175\229\138\168-\233\151\170\229\177\143\231\149\140\233\157\162-\229\138\168\231\148\187"
    }
  },
  version_update = {
    keyName = "version_update_ui",
    moduleName = "client.slua.umg.NewUpdate.version_update_ui",
    path = "/Game/UMG/UI_BP/NewUpdate/VersionUpdate_UIBP.VersionUpdate_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\137\136\230\156\172\230\155\180\230\150\176\231\149\140\233\157\162"
    }
  },
  Login_UIBP = {
    keyName = "Login_UIBP",
    moduleName = "client.slua.umg.NewLogin.Login_UIBP",
    path = "/Game/UMG/UI_BP/NewLogin/NewLogin_UIBP.NewLogin_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\231\153\187\233\153\134\231\149\140\233\157\162"
    }
  },
  login_video = {
    keyName = "login_video",
    moduleName = "client.slua.umg.NewLogin.login_video",
    path = "/Game/UMG/UI_BP/NewLogin/Login_Video_UIBP.Login_Video_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\231\153\187\233\153\134\231\149\140\233\157\162-\232\131\140\230\153\175-\232\167\134\233\162\145"
    }
  },
  login_background = {
    keyName = "login_background",
    moduleName = "client.slua.umg.NewLogin.login_background",
    path = "/Game/UMG/UI_BP/NewLogin/Login_Background_UIBP.Login_Background_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\231\153\187\233\153\134\231\149\140\233\157\162-\232\131\140\230\153\175-\232\147\157\229\155\190/\233\157\153\230\128\129\229\155\190\231\137\135"
    }
  },
  login_forcerepair = {
    keyName = "login_forcerepair",
    moduleName = "client.slua.umg.NewLogin.login_forcerepair",
    path = "/Game/UMG/UI_BP/NewLogin/Login_ForceRepair_UIBP.Login_ForceRepair_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149\231\149\140\233\157\162\226\128\148\229\188\186\229\136\182\228\191\174\229\164\141\229\188\149\229\175\188"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  repair_forceconfirm = {
    keyName = "repair_forceconfirm",
    moduleName = "client.slua.umg.NewLogin.repair_forceconfirm",
    path = "/Game/UMG/UI_BP/NewLogin/Repair_ForceConfirm_UIBP.Repair_ForceConfirm_UIBP",
    uiStat = {
      name = "\228\191\174\229\164\141\231\149\140\233\157\162\226\128\148\229\188\186\229\136\182\231\161\174\229\174\154"
    }
  },
  ServerList_UIBP = {
    keyName = "ServerList_UIBP",
    moduleName = "client.slua.umg.NewLogin.ServerList_UIBP",
    path = "/Game/UMG/UI_BP/NewLogin/ServerList_UIBP.ServerList_UIBP",
    uiStat = {
      name = "\230\156\141\229\138\161\229\153\168\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  repair = {
    keyName = "repair",
    moduleName = "client.slua.umg.NewLogin.repair_ui",
    path = "/Game/UMG/UI_BP/NewLogin/Login_Repair_UIBP.Login_Repair_UIBP",
    asy = true,
    uiStat = {
      name = "\230\184\184\230\136\143\228\191\174\229\164\141\231\149\140\233\157\162"
    }
  },
  Login_QRCode_Popup_UIBP = {
    keyName = "Login_QRCode_Popup_UIBP",
    moduleName = "client.slua.umg.NewLogin.Login_QRCode_Popup_UIBP",
    path = "/Game/UMG/UI_BP/NewLogin/Login_QRCode_Popup_UIBP.Login_QRCode_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\228\186\140\231\187\180\231\160\129\231\153\187\229\189\149\231\149\140\233\157\162"
    }
  },
  Login_QRCode_Success_Popup_UIBP = {
    keyName = "Login_QRCode_Success_Popup_UIBP",
    moduleName = "client.slua.umg.NewLogin.Login_QRCode_Success_Popup_UIBP",
    path = "/Game/UMG/UI_BP/NewLogin/Login_QRCode_Popup_UIBP.Login_QRCode_Popup_UIBP",
    asy = true,
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    uiStat = {
      name = "\228\186\140\231\187\180\231\160\129\231\153\187\229\189\149\230\136\144\229\138\159\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  login_no_auth = {
    keyName = "login_no_auth",
    moduleName = "client.slua.umg.login.login_no_auth",
    path = "/Game/UMG/UI_BP/Login/Item/Login_NoAuth_UIBP.Login_NoAuth_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149-\230\151\160\233\137\180\230\157\131\229\188\185\231\170\151"
    }
  },
  login_choice = {
    keyName = "login_choice",
    moduleName = "client.slua.umg.login.login_choice",
    path = "/Game/UMG/UI_BP/Login/LoginChoice_PanelBP.LoginChoice_PanelBP",
    uiStat = {
      name = "\231\153\187\229\189\149-\233\128\137\230\139\169\231\153\187\233\153\134\230\184\160\233\129\147"
    }
  },
  login_phone_mail = {
    keyName = "login_phone_mail",
    moduleName = "client.slua.umg.login.login_phone_mail",
    path = "/Game/UMG/UI_BP/Login/LoginChoice_phone_UIBP.LoginChoice_phone_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149-\230\137\139\230\156\186\233\130\174\231\174\177\231\153\187\229\189\149"
    },
    asy = true
  },
  login_verify_confirm = {
    keyName = "login_verify_confirm",
    moduleName = "client.slua.umg.login.login_verify_confirm",
    path = "/Game/UMG/UI_BP/Login/Login_Verify_Confirm_UIBP.Login_Verify_Confirm_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149\228\186\140\230\172\161\233\170\140\232\175\129\229\188\185\231\170\151"
    }
  },
  login_verify_code_box = {
    keyName = "login_verify_code_box",
    moduleName = "client.slua.umg.login.login_verify_code_box",
    path = "/Game/UMG/UI_BP/Login/Login_Verify_Code_Box_UIBP.Login_Verify_Code_Box_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149\233\170\140\232\175\129\231\160\129\233\128\154\231\148\168\229\188\185\231\170\151"
    }
  },
  login_scanlogin = {
    keyName = "login_scanlogin",
    moduleName = "client.slua.umg.login.login_scanlogin",
    path = "/Game/UMG/UI_BP/Login/Login_Scanlogin_UIBP.Login_Scanlogin_UIBP",
    uiStat = {
      name = "\231\153\187\233\153\134\230\137\171\231\160\129\230\143\144\231\164\186"
    }
  },
  Protection_UIBP = {
    keyName = "Protection_UIBP",
    moduleName = "client.slua.umg.NewLogin.Protection_UIBP",
    path = "/Game/UMG/UI_BP/NewLogin/Protection_UIBP.Protection_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149-\231\164\190\229\170\146\229\188\130\229\184\184\229\188\185\231\170\151"
    }
  },
  LoginPunchInAct = {
    keyName = "LoginPunchInAct",
    moduleName = "client.slua.umg.activity.new_activity_center.LoginPunchInAct",
    path = "/Game/UMG/UI_BP/Avtivity_WeekSign/LoginPunchInAct_UIBP.LoginPunchInAct_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\231\180\175\232\174\161\231\153\187\229\189\1495\230\160\188\230\137\147\229\141\161\230\180\187\229\138\168"
    }
  },
  Newbie_Loading_Guide_UIBP = {
    keyName = "Newbie_Loading_Guide_UIBP",
    moduleName = "client.slua.umg.LoginLoading.Newbie_Loading_Guide_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/Newbie_Loading_Guide_UIBP.Newbie_Loading_Guide_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139-loading\226\128\148\229\188\149\229\175\188"
    },
    isMainUI = false,
    closeOnSwitch = false,
    loadFromPool = EUIConfigPoolType.None
  },
  Return_Loading_Guide_UIBP = {
    keyName = "Return_Loading_Guide_UIBP",
    moduleName = "client.slua.umg.LoginLoading.Return_Loading_Guide_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/Return_Loading_Guide_UIBP.Return_Loading_Guide_UIBP",
    uiStat = {
      name = "\229\155\158\229\189\146-loading\226\128\148\229\188\149\229\175\188"
    },
    isMainUI = false,
    closeOnSwitch = false,
    loadFromPool = EUIConfigPoolType.None
  },
  QRCode_Restrict_Pop_UIBP = {
    keyName = "QRCode_Restrict_Pop_UIBP",
    moduleName = "client.slua.umg.QRcodeLogin.QRCode_Restrict_Pop_UIBP",
    path = "/Game/UMG/UI_BP/QRCodeLogin/Popup/QRCode_Restrict_Pop_UIBP.QRCode_Restrict_Pop_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\137\171\231\160\129\231\153\187\229\189\149\229\177\128\229\164\150\233\153\144\229\136\182\229\188\185\231\170\151"
    }
  },
  LoginPhoneBH_UIBP = {
    keyName = "LoginPhoneBH_UIBP",
    moduleName = "client.slua.umg.login.LoginPhoneBH_UIBP",
    path = "/Game/UMG/UI_BP/Login/LoginPhoneBH_UIBP.LoginPhoneBH_UIBP",
    uiStat = {
      name = "\229\141\176\229\186\166\230\137\139\230\156\186\229\143\183\231\153\187\229\189\149"
    }
  },
  mentee_invite_notice = {
    keyName = "mentee_invite_notice",
    moduleName = "client.slua.umg.mentor.mentee_invite_notice",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Invite_UIBP.PartnerReadiness_Invite_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\233\130\128\232\175\183\231\187\132\233\152\159"
    }
  },
  ui_complaint_base = {
    keyName = "ui_complaint_base",
    moduleName = "client.slua.umg.complaint.ui_complaint_base",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_UIBP.Inform_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\136\182\231\149\140\233\157\162"
    }
  },
  ui_complaint_voice = {
    keyName = "ui_complaint_voice",
    moduleName = "client.slua.umg.complaint.ui_complaint_voice",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Voice_UIBP.Inform_Voice_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\232\175\173\233\159\179\228\184\190\230\138\165"
    },
    isSingleton = false
  },
  ReportExplain_UIBP = {
    keyName = "ReportExplain_UIBP",
    moduleName = "client.slua.umg.complaint.ReportExplain_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/ReportExplain_UIBP.ReportExplain_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\228\184\190\230\138\165\232\175\180\230\152\142"
    },
    containerName = UIContainers.Top
  },
  FaceTeam_UIBP = {
    keyName = "FaceTeam_UIBP",
    moduleName = "client.slua.umg.FaceTeam.FaceTeam_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/Faceteam_UIBP.Faceteam_UIBP",
    uiStat = {
      name = "\233\157\162\229\175\185\233\157\162\231\187\132\233\152\159-\229\136\155\229\187\186"
    }
  },
  FaceTeamEnter_UIBP = {
    keyName = "FaceTeamEnter_UIBP",
    moduleName = "client.slua.umg.FaceTeam.FaceTeamEnter_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/Faceteam_UIPB2.Faceteam_UIPB2",
    uiStat = {
      name = "\233\157\162\229\175\185\233\157\162\231\187\132\233\152\159-\232\191\155\233\152\159"
    }
  },
  gdpr_jpage = {
    keyName = "gdpr_jpage",
    moduleName = "client.slua.umg.GDPR.gdpr_jpage",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Protection07_BP.Protection07_BP",
    uiStat = {
      name = "gdpr-jpage\233\166\150\229\133\133"
    }
  },
  gdpr_jpage_delete = {
    keyName = "gdpr_jpage_delete",
    moduleName = "client.slua.umg.GDPR.gdpr_jpage_delete",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Protection04_BP.Protection04_BP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\229\143\150\230\182\136\229\136\160\233\153\164\232\180\166\229\143\183"
    }
  },
  ios_delete = {
    keyName = "ios_delete",
    moduleName = "client.slua.umg.GDPR.ios_delete",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/CancelDeleteIos_UIBP.CancelDeleteIos_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "ios\229\143\150\230\182\136\229\136\160\233\153\164\232\180\166\229\143\183"
    }
  },
  aos_delete = {
    keyName = "aos_delete",
    moduleName = "client.slua.umg.GDPR.aos_delete",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/CancelDeleteAos_UIBP.CancelDeleteAos_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "aos\229\143\150\230\182\136\229\136\160\233\153\164\232\180\166\229\143\183"
    }
  },
  eu_gdpr_jpage = {
    keyName = "eu_gdpr_jpage",
    moduleName = "client.slua.umg.GDPR.eu_gdpr_jpage",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup2_UIBP.AgeGate_Popup2_UIBP",
    uiStat = {
      name = "gdpr-\229\135\186\231\148\159\229\146\140\229\155\189\229\174\182"
    }
  },
  eu_gdpr_agreement = {
    keyName = "eu_gdpr_agreement",
    moduleName = "client.slua.umg.GDPR.eu_gdpr_agreement",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Protection05_BP.Protection05_BP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\233\154\144\231\167\129\229\188\185\231\170\151"
    }
  },
  eu_gdpr_delete_box = {
    keyName = "eu_gdpr_delete_box",
    moduleName = "client.slua.umg.GDPR.eu_gdpr_delete_box",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Protection03_BP.Protection03_BP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\230\143\144\231\164\186box"
    }
  },
  EEAVoiceVerify_Popup_2_UIBP = {
    keyName = "EEAVoiceVerify_Popup_2_UIBP",
    moduleName = "client.slua.umg.PopupNotice.EEAVoiceVerify_Popup_2_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/EEAVoiceVerify_Popup_2_UIBP.EEAVoiceVerify_Popup_2_UIBP",
    uiStat = {
      name = "\230\156\170\230\136\144\229\185\180\228\186\186\232\175\173\233\159\179\233\170\140\232\175\129\231\149\140\233\157\162"
    }
  },
  EEAVoiceVerify_Popup_UIBP = {
    keyName = "EEAVoiceVerify_Popup_UIBP",
    moduleName = "client.slua.umg.PopupNotice.EEAVoiceVerify_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/EEAVoiceVerify_Popup_UIBP.EEAVoiceVerify_Popup_UIBP",
    uiStat = {
      name = "\230\156\170\230\136\144\229\185\180\228\186\186\232\175\173\233\159\179\233\170\140\232\175\129\231\149\140\233\157\162-\233\130\174\231\174\177"
    }
  },
  Explore_Whole_Linkage_UIBP = {
    keyName = "Explore_Whole_Linkage_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Whole_Linkage_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Global_Server_Exploration/Explore_Whole_Linkage_UIBP.Explore_Whole_Linkage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\133\168\230\156\141\230\142\162\231\180\162\231\149\140\233\157\162"
    }
  },
  SelectArea_UIBP = {
    keyName = "SelectArea_UIBP",
    moduleName = "client.slua.umg.select_area.SelectArea_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/SelectArea/SelectArea_UIBP.SelectArea_UIBP",
    uiStat = {
      name = "\228\191\132\231\189\151\230\150\175\228\184\147\233\161\185-\233\151\170\229\177\143\229\144\142\233\128\137\230\156\141\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Ban
  }
}
return login_ui_configs