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
local group_buying_ui_configs = {
  RroupBuying_Main_UIBP = {
    keyName = "RroupBuying_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/RroupBuying_Main_UIBP.RroupBuying_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\228\184\187\231\149\140\233\157\162"
    }
  },
  RroupBuying_All_UIBP = {
    keyName = "RroupBuying_All_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_All_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/RroupBuying_All_UIBP.RroupBuying_All_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\229\133\168\233\131\168\230\139\188\229\155\162\231\149\140\233\157\162"
    }
  },
  RroupBuying_My_Groups_UIBP = {
    keyName = "RroupBuying_My_Groups_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_My_Groups_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/RroupBuying_My_Popup_UIBP.RroupBuying_My_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\230\136\145\231\154\132\230\139\188\229\155\162\231\149\140\233\157\162"
    }
  },
  GroupBuying_Coupon_UIBP = {
    keyName = "GroupBuying_Coupon_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_Coupon_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/GroupBuying_Without_UIBP.GroupBuying_Without_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\229\133\168\233\131\168\230\139\188\229\155\162\231\149\140\233\157\162"
    }
  },
  GroupBuying_Members_UIBP = {
    keyName = "GroupBuying_Members_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_Members_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/RroupBuying_Member_Popup_UIBP.RroupBuying_Member_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\230\139\188\229\155\162\230\136\144\229\145\152\231\149\140\233\157\162"
    }
  },
  GroupBuying_Invite_UIBP = {
    keyName = "GroupBuying_Invite_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_Invite_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/RroupBuying_Invite_Popup_UIBP.RroupBuying_Invite_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  GroupBuying_Create_Box_UIBP = {
    keyName = "GroupBuying_Create_Box_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.GroupBuying_Create_Box_UIBP",
    path = "/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.Com_MsgBox_Slua_UIBP",
    uiStat = {
      name = "\230\150\176\229\155\162\232\180\173\229\136\155\229\187\186\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  Discount_Invite_Popup_UIBP = {
    keyName = "Discount_Invite_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.Discount_Invite_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/Discount/Discount_Invite_Popup_UIBP.Discount_Invite_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\231\160\141\228\187\183\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  Discount_Bargain_UIBP = {
    keyName = "Discount_Bargain_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.Discount_Bargain_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/Discount/Discount_Bargain_UIBP.Discount_Bargain_UIBP",
    asy = true,
    uiStat = {
      name = "\231\160\141\228\187\183\229\165\189\229\143\139\229\184\174\231\160\141\230\136\144\229\138\159\229\143\141\233\166\136\229\188\185\231\170\151"
    }
  },
  Discount_Feedback_Popup_UIBP = {
    keyName = "Discount_Feedback_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.Discount_Feedback_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/Discount/Discount_Feedback_Popup_UIBP.Discount_Feedback_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\231\160\141\228\187\183\232\174\162\229\141\149\229\143\141\233\166\136\229\188\185\231\170\151"
    }
  },
  Discount_My_Popup_UIBP = {
    keyName = "Discount_My_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.Discount_My_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/Discount/Discount_My_Popup_UIBP.Discount_My_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\231\160\141\228\187\183\230\136\145\231\154\132\232\174\162\229\141\149\229\188\185\231\170\151"
    }
  },
  Discount_Member_Popup_UIBP = {
    keyName = "Discount_Member_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.GroupBuying.UMG.Discount_Member_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/GroupBuying/UIBP/Discount/Discount_Member_Popup_UIBP.Discount_Member_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\231\160\141\228\187\183\229\165\189\229\143\139\229\138\169\229\138\155\230\166\156\229\188\185\231\170\151"
    }
  }
}
return group_buying_ui_configs