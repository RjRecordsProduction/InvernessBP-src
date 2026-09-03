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
local xmission_ui_configs = {
  CommonItem_TX_SlotList_UIBP = {
    keyName = "CommonItem_TX_SlotList_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.CommonItemEx.CommonItem_TX_SlotList_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/CommonItemEx/CommonItem_TX_SlotList_UIBP.CommonItem_TX_SlotList_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    asy = true,
    uiStat = {
      name = "CommonItem\229\136\134\232\167\163\229\138\168\231\148\187\232\138\130\231\130\185"
    }
  },
  HeritageArmed_Share_UIBP = {
    keyName = "HeritageArmed_Share_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.heirloom.HeritageArmed_Share_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/HeritageArmed/HeritageArmed_Share_UIBP.HeritageArmed_Share_UIBP",
    uiStat = {
      name = "XMission-\228\188\160\228\184\150\230\173\166\232\163\133\230\139\141\232\132\184"
    }
  },
  HeritageArmed_Show_UIBP = {
    keyName = "HeritageArmed_Show_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.heirloom.HeritageArmed_Show_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/HeritageArmed/HeritageArmed_Show_UIBP.HeritageArmed_Show_UIBP",
    jumpModuleID = BP_EMUM_MODULE_TXMISSION_HEIRLOOM,
    uiStat = {
      name = "t\231\142\169\230\179\149-\228\188\160\228\184\150\230\173\166\232\163\133\228\184\187\231\149\140\233\157\162"
    }
  },
  ModeSelection_XMission_UIBP = {
    keyName = "ModeSelection_XMission_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_XMission_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Select_UIBP.ModeSelection_Select_UIBP",
    zOrder = 0,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\143\179\228\190\167\229\191\171\230\141\183\229\184\184\233\169\187\230\168\161\229\188\143T\231\142\169\230\179\149\231\149\140\233\157\162"
    }
  },
  Prepare_BagExtend_UIBP = {
    keyName = "Prepare_BagExtend_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Prepare_BagExtend_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Popup/Prepare_Bage_Expansion_Popup_UIBP.Prepare_Bage_Expansion_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "XMission-\232\131\140\229\140\133\230\137\169\229\177\149\229\188\185\231\170\151"
    }
  },
  Prepare_Bage_Modification_Popup_UIBP = {
    keyName = "Prepare_Bage_Modification_Popup_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Prepare_Bage_Modification_Popup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Prepare_Bage_Modification_Popup_UIBP.Prepare_Bage_Modification_Popup_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149\230\136\152\229\164\135\230\150\185\230\161\136\230\148\185\229\144\141"
    }
  },
  Prepare_Bage_Programme_Popup_UIBP = {
    keyName = "Prepare_Bage_Programme_Popup_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Prepare_Bage_Programme_Popup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Prepare_Bage_Programme_Popup_UIBP.Prepare_Bage_Programme_Popup_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149\230\136\152\229\164\135\230\150\185\230\161\136\231\149\140\233\157\162"
    }
  },
  Prepare_Consumables_Guide_UIBP = {
    keyName = "Prepare_Consumables_Guide_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Prepare_Consumables_Guide_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Prepare_Consumables_Guide_UIBP.Prepare_Consumables_Guide_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149\230\136\152\229\164\135\229\188\149\229\175\188\230\176\148\230\179\161"
    }
  },
  Prepare_Consumables_Main_UIBP = {
    keyName = "Prepare_Consumables_Main_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Prepare_Consumables_Main_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Prepare_Consumables_Main_UIBP.Prepare_Consumables_Main_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149\230\136\152\229\164\135\233\162\132\232\174\190\228\184\187\231\149\140\233\157\162"
    }
  },
  TPlan_TeamPlatform_Filter_UIBP = {
    keyName = "TPlan_TeamPlatform_Filter_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.team_platform.TPlan_TeamPlatform_Filter_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/Item/TeamPlatform_Dropdown_TPlan_Item.TeamPlatform_Dropdown_TPlan_Item",
    isMainUI = false,
    uiStat = {
      name = "XMission\231\187\132\233\152\159\229\164\167\229\142\133-\231\173\155\233\128\137\231\149\140\233\157\162"
    }
  },
  TPlan_TeamPlatform_MyTeam_Item = {
    keyName = "TPlan_TeamPlatform_MyTeam_Item",
    moduleName = "client.slua.umg.TxMission.xMission.team_platform.TPlan_TeamPlatform_MyTeam_Item",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/Item/TeamPlatform_8p_Myteam_Item.TeamPlatform_8p_Myteam_Item",
    isMainUI = false,
    uiStat = {
      name = "XMission\231\187\132\233\152\159\229\164\167\229\142\133-\233\152\159\228\188\141\231\174\161\231\144\134\231\149\140\233\157\162\233\161\182\233\131\168item"
    }
  },
  TPlan_TeamPlatform_MyTeam_UIBP = {
    keyName = "TPlan_TeamPlatform_MyTeam_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.team_platform.TPlan_TeamPlatform_MyTeam_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_MyTeam_UIBP.TeamPlatform_MyTeam_UIBP",
    uiStat = {
      name = "XMission\231\187\132\233\152\159\229\164\167\229\142\133-\233\152\159\228\188\141\231\174\161\231\144\134-\230\150\176"
    }
  },
  TPlan_TeamPlatform_Recruit_UIBP = {
    keyName = "TPlan_TeamPlatform_Recruit_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.team_platform.TPlan_TeamPlatform_Recruit_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_Recruit_UIBP.TeamPlatform_Recruit_UIBP",
    uiStat = {
      name = "XMission\231\187\132\233\152\159\229\164\167\229\142\133-\230\139\155\229\139\159\231\149\140\233\157\162"
    }
  },
  TPlan_TeamPlatform_UIBP = {
    keyName = "TPlan_TeamPlatform_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.team_platform.TPlan_TeamPlatform_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_Main_UIBP.TeamPlatform_Main_UIBP",
    uiStat = {
      name = "XMission\231\187\132\233\152\159\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162-\230\150\176"
    }
  },
  UnknowPass_Newbie_Xmission_UIBP = {
    keyName = "UnknowPass_Newbie_Xmission_UIBP",
    moduleName = "client.slua.umg.UnknowPass.RP_Newbie.UnknowPass_Newbie_Xmission_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Newbie/UnknowPass_Newbie_Xmission_UIBP.UnknowPass_Newbie_Xmission_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "XMission-\233\128\154\232\161\140\232\175\129\228\187\187\229\138\161\229\188\149\229\175\188"
    }
  },
  Wardrobe_Popup_Set_UIBP = {
    keyName = "Wardrobe_Popup_Set_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.wardrobe.Wardrobe_Popup_Set_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Popup_Set_UIBP.Wardrobe_Popup_Set_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\228\187\147\229\186\147\232\174\190\231\189\174"
    }
  },
  Wardrobe_Popup_Tips_UIBP = {
    keyName = "Wardrobe_Popup_Tips_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.match_history.Wardrobe_Popup_Tips_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Popup_Tips_UIBP.Wardrobe_Popup_Tips_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.TopZOrder,
    uiStat = {
      name = "Xmission-\229\142\134\229\143\178\232\174\176\229\189\149-\229\155\162\231\171\158\230\168\161\229\188\143-\231\130\185\229\135\187\231\137\169\229\147\129tips"
    }
  },
  Wardrobe_Popup_Tips_UIBP_02 = {
    keyName = "Wardrobe_Popup_Tips_UIBP_02",
    moduleName = "client.slua.umg.TxMission.xMission.match_history.Wardrobe_Popup_Tips_UIBP_02",
    path = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Popup_Tips_UIBP_02.Wardrobe_Popup_Tips_UIBP_02",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.TopZOrder,
    uiStat = {
      name = "Xmission-\229\142\134\229\143\178\232\174\176\229\189\149-\229\155\162\231\171\158\230\168\161\229\188\143-\231\130\185\229\135\187\233\133\141\228\187\182tips"
    }
  },
  XMission_Box_Detail_UIBP = {
    keyName = "XMission_Box_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Box_Detail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Reward_Information/Xmission_Box_Detail_UIBP.Xmission_Box_Detail_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\183\165\228\189\156\229\143\176\231\186\162\229\140\133\232\175\166\231\187\134\228\191\161\230\129\175"
    }
  },
  XMission_Exchange_UIBP = {
    keyName = "XMission_Exchange_UIBP",
    moduleName = "client.slua.umg.XMission_Exchange_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/XMission_Exchange_UIBP.XMission_Exchange_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149-\233\128\154\231\148\168\231\177\187-\232\180\173\228\185\176\229\133\145\230\141\162\228\186\140\230\172\161\231\161\174\232\174\164\231\149\140\233\157\162"
    }
  },
  XMission_Souvenirs_Share_BG_UIBP = {
    keyName = "XMission_Souvenirs_Share_BG_UIBP",
    moduleName = "client.slua.umg.shareChild.XMission_Souvenirs_Share_BG_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/XMission_Souvenirs_Share_BG_UIBP.XMission_Souvenirs_Share_BG_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129"
    }
  },
  XMission_StoreBuyPopup_UIBP = {
    keyName = "XMission_StoreBuyPopup_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.XMission_StoreBuyPopup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/XMission_StoreBuyPopup_UIBP.XMission_StoreBuyPopup_UIBP",
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\230\137\185\233\135\143\229\148\174\229\141\150"
    },
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE
  },
  Xmission_Affix_Entry_UIBP = {
    keyName = "Xmission_Affix_Entry_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.affix.Xmission_Affix_Entry_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Affix_Entry_UIBP.Xmission_Affix_Entry_UIBP",
    uiStat = {
      name = "\232\175\141\231\188\128\229\155\190\233\137\180\229\133\165\229\143\163"
    }
  },
  Xmission_Affix_Operate_Popup_UIBP = {
    keyName = "Xmission_Affix_Operate_Popup_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Affix_Operate_Popup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Affix_Operate_Popup_UIBP.Xmission_Affix_Operate_Popup_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\232\175\141\231\188\128\230\147\141\228\189\156-\229\188\185\231\170\151"
    }
  },
  Xmission_Affix_UIBP = {
    keyName = "Xmission_Affix_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.affix.Xmission_Affix_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Affix_UIBP.Xmission_Affix_UIBP",
    uiStat = {
      name = "\232\175\141\231\188\128\229\155\190\233\137\180\231\149\140\233\157\162"
    }
  },
  Xmission_Application_UIBP = {
    keyName = "Xmission_Application_UIBP",
    moduleName = "client.slua.umg.Xmission_Application_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_Application_UIBP.Xmission_Application_UIBP",
    uiStat = {
      name = "XMission-\229\164\169\232\181\139\229\186\148\231\148\168\231\170\151\229\143\163"
    }
  },
  Xmission_Conversation_LD_UIBP = {
    keyName = "Xmission_Conversation_LD_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.Xmission_Conversation_LD_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Conversation_LD_UIBP.Xmission_Conversation_LD_UIBP",
    isMainUI = false,
    uiStat = {
      name = "XMission-NPC\229\175\185\232\175\157-\229\173\144\231\149\140\233\157\1621"
    }
  },
  Xmission_Conversation_MD_UIBP = {
    keyName = "Xmission_Conversation_MD_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.Xmission_Conversation_MD_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Conversation_MD_UIBP.Xmission_Conversation_MD_UIBP",
    isMainUI = false,
    uiStat = {
      name = "XMission-NPC\229\175\185\232\175\157-\229\173\144\231\149\140\233\157\1623"
    }
  },
  Xmission_Conversation_RD_UIBP = {
    keyName = "Xmission_Conversation_RD_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.Xmission_Conversation_RD_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Conversation_RD_UIBP.Xmission_Conversation_RD_UIBP",
    isMainUI = false,
    uiStat = {
      name = "XMission-NPC\229\175\185\232\175\157-\229\173\144\231\149\140\233\157\1622"
    }
  },
  Xmission_Conversation_UIBP = {
    keyName = "Xmission_Conversation_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.Xmission_Conversation_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Conversation_UIBP.Xmission_Conversation_UIBP",
    uiStat = {
      name = "XMission-NPC\228\188\154\232\175\157\229\174\185\229\153\168\231\149\140\233\157\162"
    }
  },
  Xmission_Cultivate_Store_Picture_Item_UIBP = {
    keyName = "Xmission_Cultivate_Store_Picture_Item_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.collection.story.xmission_collection_story_item",
    path = "/Game/Mod/TPlan/XMission/UMG/Cultivate/Item/Xmission_Cultivate_Store_Picture_Item_UIBP.Xmission_Cultivate_Store_Picture_Item_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  Xmission_Cultivate_Store_Text_Item_UIBP = {
    keyName = "Xmission_Cultivate_Store_Text_Item_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.collection.story.xmission_collection_story_item",
    path = "/Game/Mod/TPlan/XMission/UMG/Cultivate/Item/Xmission_Cultivate_Store_Text_Item_UIBP.Xmission_Cultivate_Store_Text_Item_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  Xmission_Dialog_UIBP = {
    keyName = "Xmission_Dialog_UIBP",
    moduleName = "client.slua.umg.Xmission_Dialog_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_Dialog_UIBP.Xmission_Dialog_UIBP",
    isSingleton = false,
    uiStat = {
      name = "T\231\142\169\230\179\149\229\145\168\230\156\171\229\188\128\230\148\190\230\187\161\229\164\169\232\181\139-\229\175\185\232\175\157\230\161\134"
    }
  },
  Xmission_Dismantling_Make_UIBP = {
    keyName = "Xmission_Dismantling_Make_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Dismantling_Make_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Dismantling_Make_UIBP.Xmission_Dismantling_Make_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\183\165\228\189\156\229\143\176-\232\175\141\231\188\128\230\137\147\233\128\160\230\180\151\231\130\188"
    },
    isMainUI = false
  },
  Xmission_Dismantling_Popup_UIBP = {
    keyName = "Xmission_Dismantling_Popup_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Dismantling_Popup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Dismantling_Popup_UIBP.Xmission_Dismantling_Popup_UIBP",
    uiStat = {
      name = "\230\147\141\228\189\156\229\143\176\228\184\187\231\149\140\233\157\162\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Xmission_Dismantling_UIBP = {
    keyName = "Xmission_Dismantling_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Dismantling_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Dismantling_UIBP.Xmission_Dismantling_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\183\165\228\189\156\229\143\176-\230\139\134\232\167\163\229\174\157\231\174\177"
    },
    isMainUI = false
  },
  Xmission_Enhance_Make_UIBP = {
    keyName = "Xmission_Enhance_Make_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Enhance_Make_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Enhance_Make_UIBP.Xmission_Enhance_Make_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\183\165\228\189\156\229\143\176-\232\175\141\231\188\128\229\188\186\229\140\150"
    },
    isMainUI = false
  },
  Xmission_Enhance_Tip_UIBP = {
    keyName = "Xmission_Enhance_Tip_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Enhance_Tip_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Enhance_Tip_UIBP.Xmission_Enhance_Tip_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149\232\175\141\231\188\128\229\188\186\229\140\150tips"
    }
  },
  Xmission_FashionShows_UIBP = {
    keyName = "Xmission_FashionShows_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.team.Xmission_FashionShows_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_FashionShows_UIBP.Xmission_FashionShows_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149\231\187\132\233\152\159-\230\151\182\232\163\133\230\152\190\231\164\186\232\174\190\231\189\174"
    }
  },
  Xmission_Gift_Popup_UIBP = {
    keyName = "Xmission_Gift_Popup_UIBP",
    moduleName = "GameLua.Mod.TPlan.Client.UI.RedEnvelope.Xmission_Gift_Popup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/RedEnvelope/Xmission_Gift_Popup_UIBP.Xmission_Gift_Popup_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\231\186\162\229\140\133-\229\143\145\233\128\129"
    }
  },
  Xmission_Guide_Skip_UIBP = {
    keyName = "Xmission_Guide_Skip_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.Xmission_Guide_Skip_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Guide_Skip_UIBP.Xmission_Guide_Skip_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation,
    uiStat = {
      name = "t\231\142\169\230\179\149\228\184\187\231\186\191\229\188\149\229\175\188\232\183\179\232\191\135"
    }
  },
  Xmission_Heirloom_Entry_UIBP = {
    keyName = "Xmission_Heirloom_Entry_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Heirloom_Entry_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Heirloom_Entry_UIBP.Xmission_Heirloom_Entry_UIBP",
    uiStat = {
      name = "\228\188\160\228\184\150\230\173\166\232\163\133-\229\133\165\229\143\163"
    }
  },
  Xmission_History_Detail_UIBP = {
    keyName = "Xmission_History_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.history_record.Xmission_History_Detail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/RoleInfo_History_Record/Xmission_History_Detail_UIBP.Xmission_History_Detail_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149\229\134\133\229\142\134\229\143\178\230\136\152\231\187\169\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Xmission_Information_Item_UIBP = {
    keyName = "Xmission_Information_Item_UIBP",
    moduleName = "GameLua.Mod.TPlan.Client.UI.RedEnvelope.Item.Xmission_Information_Item_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/TplanRedPacket/Item/Xmission_Information_Item_UIBP.Xmission_Information_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "t\231\142\169\230\179\149-\230\142\137\229\135\186\231\137\169\229\147\129\232\175\166\230\131\133"
    }
  },
  Xmission_MatchEntryTip_UIBP = {
    keyName = "Xmission_MatchEntryTip_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Xmission_MatchEntryTip_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_MatchEntryTip_UIBP.Xmission_MatchEntryTip_UIBP",
    uiStat = {
      name = "XMission-\229\140\185\233\133\141\229\133\165\229\143\163-\229\143\140\229\128\141\229\138\159\229\139\139\230\143\144\231\164\186"
    }
  },
  Xmission_MessageMail_UIBP = {
    keyName = "Xmission_MessageMail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.Xmission_MessageMail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_MessageMail_UIBP.Xmission_MessageMail_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149-\232\163\133\229\164\135\229\184\166\229\155\158\229\188\185\231\170\151"
    }
  },
  Xmission_Open_Photo_Popup_UIBP = {
    keyName = "Xmission_Open_Photo_Popup_UIBP",
    moduleName = "GameLua.Mod.TPlan.Client.UI.RedEnvelope.Xmission_Open_Photo_Popup_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/TplanRedPacket/Popup/Xmission_Open_Photo_Popup_UIBP.Xmission_Open_Photo_Popup_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\231\186\162\229\140\133-\233\162\134\229\143\150\231\186\162\229\140\133"
    }
  },
  Xmission_Operation_Main_UIBP = {
    keyName = "Xmission_Operation_Main_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Operation_Main_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Operation_Main_UIBP.Xmission_Operation_Main_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\183\165\228\189\156\229\143\176-\228\184\187\231\149\140\233\157\162"
    }
  },
  Xmission_Operations_Area_UIBP = {
    keyName = "Xmission_Operations_Area_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Research.Operation.Xmission_Operations_Area_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Operations_Area_UIBP.Xmission_Operations_Area_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\164\167\229\142\133\229\183\165\228\189\156\229\143\176-3DUI"
    }
  },
  Xmission_PKSetting_UIBP = {
    keyName = "Xmission_PKSetting_UIBP",
    moduleName = "client.slua.umg.Xmission_PKSetting_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_PKSetting_UIBP.Xmission_PKSetting_UIBP",
    uiStat = {
      name = "Solo-\229\143\130\230\149\176\233\128\137\230\139\169T\231\149\140\233\157\162"
    }
  },
  Xmission_Pop_UIBP = {
    keyName = "Xmission_Pop_UIBP",
    moduleName = "client.slua.umg.Xmission_Pop_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_Pop_UIBP.Xmission_Pop_UIBP",
    uiStat = {
      name = "XMission-\229\164\169\232\181\139\233\133\141\231\189\174\230\149\136\230\158\156\233\162\132\232\167\136\229\188\185\231\170\151"
    }
  },
  Xmission_Popup_Equipment_UIBP = {
    keyName = "Xmission_Popup_Equipment_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Xmission_Popup_Equipment_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Popup_Equipment_UIBP.Xmission_Popup_Equipment_UIBP",
    uiStat = {
      name = "XMission-\229\184\166\229\155\158\233\152\159\229\143\139\232\163\133\229\164\135\229\188\185\231\170\151"
    }
  },
  Xmission_Popup_Newbie_Restriction_UIBP = {
    keyName = "Xmission_Popup_Newbie_Restriction_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Xmission_Popup_Newbie_Restriction_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Popup_Newbie_Restriction_UIBP.Xmission_Popup_Newbie_Restriction_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149\230\150\176\230\137\139\229\156\186\233\153\144\229\136\182\229\188\185\231\170\151"
    }
  },
  Xmission_Popup_TeamCompetition_Tips_UIBP = {
    keyName = "Xmission_Popup_TeamCompetition_Tips_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Xmission_Popup_TeamCompetition_Tips_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Item/Xmission_Popup_TeamCompetition_Tips_UIBP.Xmission_Popup_TeamCompetition_Tips_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\155\162\231\171\158\230\136\152\229\164\135-\233\133\141\228\187\182tips"
    }
  },
  Xmission_Popup_TeamCompetition_UIBP = {
    keyName = "Xmission_Popup_TeamCompetition_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.Xmission_Popup_TeamCompetition_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Popup_TeamCompetition_UIBP.Xmission_Popup_TeamCompetition_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\229\155\162\231\171\158\230\136\152\229\164\135\231\149\140\233\157\162"
    }
  },
  Xmission_Readiness_Popup_UIBP = {
    keyName = "Xmission_Readiness_Popup_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.Xmission_Readiness_Popup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Readiness_Popup_UIBP.Xmission_Readiness_Popup_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149\230\136\152\229\137\141\229\135\134\229\164\135\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  Xmission_RecommendedPlan_UIBP = {
    keyName = "Xmission_RecommendedPlan_UIBP",
    moduleName = "client.slua.umg.Xmission_RecommendedPlan_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_RecommendedPlan_UIBP.Xmission_RecommendedPlan_UIBP",
    uiStat = {
      name = "XMission\229\164\169\232\181\139\233\161\181\230\142\168\232\141\144\230\150\185\230\161\136"
    }
  },
  Xmission_RedPacket_Other_Popup_UIBP = {
    keyName = "Xmission_RedPacket_Other_Popup_UIBP",
    moduleName = "GameLua.Mod.TPlan.Client.UI.RedEnvelope.Xmission_RedPacket_Other_Popup_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/TplanRedPacket/Popup/Xmission_RedPacket_Other_Popup_UIBP.Xmission_RedPacket_Other_Popup_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\231\186\162\229\140\133-\233\162\134\229\143\150\231\186\162\229\140\1332"
    }
  },
  Xmission_RedPacket_Self_UIBP = {
    keyName = "Xmission_RedPacket_Self_UIBP",
    moduleName = "GameLua.Mod.TPlan.Client.UI.RedEnvelope.Xmission_RedPacket_Self_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/TplanRedPacket/Xmission_RedPacket_Self_UIBP.Xmission_RedPacket_Self_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\231\186\162\229\140\133-\233\162\134\229\143\150\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Xmission_RoleInfo_History_UIBP = {
    keyName = "Xmission_RoleInfo_History_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.history_record.Xmission_RoleInfo_History_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/RoleInfo_History_Record/Xmission_RoleInfo_History_UIBP.Xmission_RoleInfo_History_UIBP",
    uiStat = {
      name = "T\231\142\169\230\179\149\229\134\133\229\142\134\229\143\178\230\136\152\231\187\169\228\184\187\231\149\140\233\157\162"
    }
  },
  Xmission_Room_Equip_Detail_UIBP = {
    keyName = "Xmission_Room_Equip_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.room.Xmission_Room_Equip_Detail_UIBP",
    path = "/Game/Mod/TPlan/BluePrints/UI/OBUI/TPlan_OB_StGroup_UIBP.TPlan_OB_StGroup_UIBP",
    uiStat = {
      name = "XMission-\230\136\191\233\151\180\229\142\134\229\143\178\229\175\185\229\177\128 \232\163\133\229\164\135\232\175\166\230\131\133"
    }
  },
  Xmission_Room_History_UIBP = {
    keyName = "Xmission_Room_History_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.room.Xmission_Room_History_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Room/Xmission_Room_History_UIBP.Xmission_Room_History_UIBP",
    uiStat = {
      name = "XMission-\230\136\191\233\151\180\229\142\134\229\143\178\229\175\185\229\177\128"
    }
  },
  Xmission_Room_Team_Detail_UIBP = {
    keyName = "Xmission_Room_Team_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.room.Xmission_Room_Team_Detail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Room/TPlan_OB_StGroup_02_UIBP.TPlan_OB_StGroup_02_UIBP",
    uiStat = {
      name = "XMission-\230\136\191\233\151\180\229\142\134\229\143\178\229\175\185\229\177\128 \233\152\159\228\188\141\232\175\166\230\131\133"
    }
  },
  Xmission_Room_UIBP = {
    keyName = "Xmission_Room_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.room.Xmission_Room_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Room/Xmission_Room_UIBP.Xmission_Room_UIBP",
    jumpModuleID = BP_ENUM_MODULE_XMISSION_ROOM_WAITING,
    asy = true,
    uiStat = {
      name = "XMission-\230\136\191\233\151\180\228\184\187\231\149\140\233\157\162"
    }
  },
  Xmission_Select_Optional_Chest_UIBP = {
    keyName = "Xmission_Select_Optional_Chest_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.wardrobe.Xmission_Select_Optional_Chest_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Select_Optional_Chest_UIBP.Xmission_Select_Optional_Chest_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149\232\135\170\233\128\137\229\174\157\231\174\177\231\149\140\233\157\162"
    }
  },
  Xmission_Share_UIBP = {
    keyName = "Xmission_Share_UIBP",
    moduleName = "GameLua.Mod.TPlan.Client.UI.RedEnvelope.Xmission_Share_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/RedEnvelope/Xmission_Share_UIBP.Xmission_Share_UIBP",
    uiStat = {
      name = "t\231\142\169\230\179\149-\231\186\162\229\140\133-\233\135\145\232\137\178\231\137\169\229\147\129\230\180\187\231\154\132\229\188\185\231\170\151"
    }
  },
  Xmission_Souvenirs_Banner_UIBP = {
    keyName = "Xmission_Souvenirs_Banner_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Banner_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_Banner_UIBP.Xmission_Souvenirs_Banner_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\150\176\231\137\136t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129Banner-\231\149\140\233\157\162"
    }
  },
  Xmission_Souvenirs_Buff_Item = {
    keyName = "Xmission_Souvenirs_Buff_Item",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Buff_Item",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/New/Item/Xmission_Souvenirs_Buff_Item.Xmission_Souvenirs_Buff_Item",
    uiStat = {
      name = "\230\150\176\231\137\136t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129Buff-Item"
    },
    isMainUI = false,
    isSingleton = false
  },
  Xmission_Souvenirs_Detail_UIBP = {
    keyName = "Xmission_Souvenirs_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Detail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_Detail_UIBP.Xmission_Souvenirs_Detail_UIBP",
    uiStat = {
      name = "\231\186\170\229\191\181\231\179\187\231\187\159-\231\186\170\229\191\181\229\147\129\232\175\166\230\131\133"
    }
  },
  Xmission_Souvenirs_Detail_UIBP_New = {
    keyName = "Xmission_Souvenirs_Detail_UIBP_New",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Detail_UIBP_New",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/New/Xmission_Souvenirs_Detail_UIBP_New.Xmission_Souvenirs_Detail_UIBP_New",
    uiStat = {
      name = "\230\150\176\231\137\136t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129\232\175\166\230\131\133-\231\149\140\233\157\162"
    }
  },
  Xmission_Souvenirs_Edit_UIBP_New = {
    keyName = "Xmission_Souvenirs_Edit_UIBP_New",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Edit_UIBP_New",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/New/Xmission_Souvenirs_Edit_UIBP_New.Xmission_Souvenirs_Edit_UIBP_New",
    uiStat = {
      name = "t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129\231\188\150\232\190\145-\231\149\140\233\157\162"
    }
  },
  Xmission_Souvenirs_Entry_UIBP = {
    keyName = "Xmission_Souvenirs_Entry_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Entry_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_Entry_UIBP.Xmission_Souvenirs_Entry_UIBP",
    uiStat = {
      name = "\231\186\170\229\191\181\231\179\187\231\187\159-\229\177\149\230\159\156\229\133\165\229\143\163"
    }
  },
  Xmission_Souvenirs_Friend_Detail_UIBP = {
    keyName = "Xmission_Souvenirs_Friend_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Friend_Detail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_Friend_Detail_UIBP.Xmission_Souvenirs_Friend_Detail_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139\231\186\170\229\191\181\231\179\187\231\187\159-\231\186\170\229\191\181\229\147\129\232\175\166\230\131\133"
    }
  },
  Xmission_Souvenirs_Friend_UIBP = {
    keyName = "Xmission_Souvenirs_Friend_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Friend_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_Friend_UIBP.Xmission_Souvenirs_Friend_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139\231\186\170\229\191\181\231\179\187\231\187\159-\231\186\170\229\191\181\229\147\129\229\177\149\230\159\156"
    }
  },
  Xmission_Souvenirs_Obtained_Detail_UIBP = {
    keyName = "Xmission_Souvenirs_Obtained_Detail_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Obtained_Detail_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/New/Xmission_Souvenirs_Obtained_Detail_UIBP.Xmission_Souvenirs_Obtained_Detail_UIBP",
    uiStat = {
      name = "\230\150\176\231\137\136t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129\229\183\178\232\142\183\229\190\151\232\175\166\230\131\133-\231\149\140\233\157\162"
    }
  },
  Xmission_Souvenirs_TV_UIBP = {
    keyName = "Xmission_Souvenirs_TV_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_TV_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/New/Xmission_Souvenirs_TV_UIBP.Xmission_Souvenirs_TV_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\150\176\231\137\136t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129TV-\231\149\140\233\157\162"
    }
  },
  Xmission_Souvenirs_Task_Progress_UIBP = {
    keyName = "Xmission_Souvenirs_Task_Progress_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_Task_Progress_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_Task_Progress_UIBP.Xmission_Souvenirs_Task_Progress_UIBP",
    uiStat = {
      name = "\231\186\170\229\191\181\231\179\187\231\187\159-\229\141\135\231\186\167\232\191\155\229\186\166\229\188\185\231\170\151"
    }
  },
  Xmission_Souvenirs_UIBP = {
    keyName = "Xmission_Souvenirs_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/Xmission_Souvenirs_UIBP.Xmission_Souvenirs_UIBP",
    uiStat = {
      name = "\231\186\170\229\191\181\231\179\187\231\187\159-\230\137\128\230\156\137\232\181\155\229\173\163\231\154\132\231\186\170\229\191\181\229\147\129"
    }
  },
  Xmission_Souvenirs_UIBP_New = {
    keyName = "Xmission_Souvenirs_UIBP_New",
    moduleName = "client.slua.umg.TxMission.xMission.souvenirs.Xmission_Souvenirs_UIBP_New",
    path = "/Game/Mod/TPlan/XMission/UMG/Souvenirs/New/Xmission_Souvenirs_UIBP_New.Xmission_Souvenirs_UIBP_New",
    uiStat = {
      name = "\230\150\176\231\137\136t\231\142\169\230\179\149\231\186\170\229\191\181\229\147\129-\231\149\140\233\157\162"
    }
  },
  Xmission_Store_NewQuickConfigPopup_UIBP = {
    keyName = "Xmission_Store_NewQuickConfigPopup_UIBP",
    moduleName = "client.slua.umg.Xmission_Store_NewQuickConfigPopup_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/Xmission_Store_NewQuickConfigPopup_UIBP.Xmission_Store_NewQuickConfigPopup_UIBP",
    uiStat = {
      name = "XMission\228\187\147\229\186\147\230\150\176\229\191\171\230\141\183\232\180\173\228\185\176"
    }
  },
  Xmission_TeamCompetitionHistory_UIBP = {
    keyName = "Xmission_TeamCompetitionHistory_UIBP",
    moduleName = "client.slua.umg.TxMission.xMission.match_history.Xmission_TeamCompetitionHistory_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/RoleInfo_History_Record/Xmission_TeamCompetitionHistory_UIBP.Xmission_TeamCompetitionHistory_UIBP",
    uiStat = {
      name = "Xmission-\229\142\134\229\143\178\232\174\176\229\189\149-\229\155\162\231\171\158\230\168\161\229\188\143"
    }
  },
  black_market_buy = {
    keyName = "black_market_buy",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.black_market_buy",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/Xmission_Store_Main_UIBP.Xmission_Store_Main_UIBP",
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\232\180\173\228\185\176\231\179\187\231\187\159"
    },
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE
  },
  black_market_detail_component = {
    keyName = "black_market_detail_component",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.black_market_detail_component",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/XMission_StoreItem_Detail_UIBP.XMission_StoreItem_Detail_UIBP",
    isSingleton = false,
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\232\175\166\230\131\133\231\187\132\228\187\182"
    }
  },
  black_market_page = {
    keyName = "black_market_page",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.black_market_page",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/Xmission_Store_GeneralPage_UIBP.Xmission_Store_GeneralPage_UIBP",
    isSingleton = false,
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\233\128\154\231\148\168\233\161\181\231\173\190"
    }
  },
  black_market_sell = {
    keyName = "black_market_sell",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.black_market_sell",
    path = "/Game/Mod/TPlan/XMission/UMG/Sell/Sell_Main_UIBP.Sell_Main_UIBP",
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\229\135\186\229\148\174\231\179\187\231\187\159"
    }
  },
  black_market_treasure_component = {
    keyName = "black_market_treasure_component",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.black_market_treasure_component",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/XMission_Store_Treasure_BP.XMission_Store_Treasure_BP",
    isSingleton = false,
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\231\164\188\229\140\133\231\187\132\228\187\182"
    }
  },
  black_market_wholesale = {
    keyName = "black_market_wholesale",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.black_market_wholesale",
    path = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Shop_Popup.Wardrobe_Shop_Popup",
    uiStat = {
      name = "xMission-\233\187\145\229\184\130\230\137\185\233\135\143\229\148\174\229\141\150"
    }
  },
  chat_recruit_filter_t_plan_new = {
    keyName = "chat_recruit_filter_t_plan_new",
    moduleName = "client.slua.umg.lobby_chat.recruit.chat_recruit_filter_t_plan_new",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Chatteam_Screen_TPlan_UIBP.Chatteam_Screen_TPlan_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\230\139\155\229\139\159\231\173\155\233\128\137\231\149\140\233\157\162-T\231\142\169\230\179\149180\231\137\136\230\156\172"
    }
  },
  chat_recruit_panel_t_plan_new = {
    keyName = "chat_recruit_panel_t_plan_new",
    moduleName = "client.slua.umg.lobby_chat.recruit.chat_recruit_panel_t_plan_new",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Chatteam2_TPlan_UIBP.Chatteam2_TPlan_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\230\139\155\229\139\159\231\149\140\233\157\162-T180\231\137\136\230\156\172"
    }
  },
  item_super_mode_selection_main = {
    keyName = "item_super_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Map01_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Map03_Item.ModeSelection_Main_Map03_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-t\231\142\169\230\179\149\232\182\133\229\164\167\232\167\134\229\155\190item"
    }
  },
  season_award_tips = {
    keyName = "season_award_tips",
    moduleName = "client.slua.umg.TxMission.xMission.season.season_award_tips",
    isMainUI = false,
    path = "/Game/Mod/TPlan/XMission/UMG/Season/Xmission_Season_Tips_UIBP.Xmission_Season_Tips_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "XMission-\229\165\150\229\138\177tip"
    }
  },
  ui_complaint_xmissionmetro = {
    keyName = "ui_complaint_xmissionmetro",
    moduleName = "client.slua.umg.complaint.ui_complaint_xmissionmetro",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-T\231\142\169\230\179\149"
    },
    isSingleton = false
  },
  xMission_Collection_Story = {
    keyName = "xMission_Collection_Story",
    moduleName = "client.slua.umg.TxMission.xMission.collection.story.xmission_collection_story_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Cultivate/Xmission_Cultivate_Store_UIBP.Xmission_Cultivate_Store_UIBP",
    uiStat = {
      name = "XMission-\230\148\182\233\155\134-\230\149\133\228\186\139"
    }
  },
  xMission_Mode_Select = {
    keyName = "xMission_Mode_Select",
    moduleName = "client.slua.umg.TxMission.xMission.team.xmission_select_mode",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Enter_ModeSelect_UIBP.Xmission_Enter_ModeSelect_UIBP",
    uiStat = {
      name = "XMission-\230\168\161\229\188\143\233\128\137\230\139\169"
    }
  },
  xMission_Mode_Select_Detail = {
    keyName = "xMission_Mode_Select_Detail",
    moduleName = "client.slua.umg.TxMission.xMission.team.xmission_select_mode_detail",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Enter_ModeSelec_Details_UIBP.Xmission_Enter_ModeSelec_Details_UIBP",
    uiStat = {
      name = "XMission-\230\168\161\229\188\143\233\128\137\230\139\169\232\175\166\230\131\133"
    }
  },
  xmission_RightBottom_Tip_UIBP = {
    keyName = "xmission_RightBottom_Tip_UIBP",
    moduleName = "client.slua.umg.common.Common_RightBottom_Tip_UIBP",
    closeOnHide = false,
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "XMission-\229\143\179\228\184\139\229\188\185\231\170\151"
    }
  },
  xmission_beginner_guide = {
    keyName = "xmission_beginner_guide",
    moduleName = "client.slua.umg.TxMission.xMission.xmission_beginner_guide",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Novice_warehouse_UIBP.Xmission_Novice_warehouse_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "xMission-\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  xmission_com_msg_box = {
    keyName = "xmission_com_msg_box",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Common_Popup_Small_UIBP.Xmission_Common_Popup_Small_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "XMission-\233\128\154\231\148\168\229\188\185\231\170\151"
    }
  },
  xmission_com_msg_box_2 = {
    keyName = "xmission_com_msg_box_2",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/Mod/TPlan/XMission/UMG/HeritageArmed/Popup/Heritage__Popup_Small_UIBP.Heritage__Popup_Small_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "XMission-\233\128\154\231\148\168\229\188\185\231\170\151-2"
    }
  },
  xmission_download = {
    keyName = "xmission_download",
    moduleName = "client.slua.umg.TxMission.xMission.xmission_download",
    path = "/Game/UMG/UI_BP/TPlan/Tplan_Download_Popup_UIBP.Tplan_Download_Popup_UIBP",
    uiStat = {
      name = "XMission-\228\184\139\232\189\189\231\149\140\233\157\162"
    }
  },
  xmission_enter_confirm = {
    keyName = "xmission_enter_confirm",
    moduleName = "client.slua.umg.TxMission.xMission.xmission_enter_confirm",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_Popup_Enter_UIBP.Xmission_Popup_Enter_UIBP",
    uiStat = {
      name = "XMission-\229\184\166\233\152\159\232\191\155\229\133\165\228\186\140\230\172\161\231\161\174\232\174\164\230\161\134"
    }
  },
  xmission_event3d_entry = {
    keyName = "xmission_event3d_entry",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.xmission_event3d_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_RankTv_UIBP.Xmission_RankTv_UIBP",
    uiStat = {
      name = "XMission-\230\180\187\229\138\168\229\133\165\229\143\163"
    }
  },
  xmission_friend_entry = {
    keyName = "xmission_friend_entry",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.xmission_friend_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Friend_UIBP.Xmission_Friend_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\229\165\189\229\143\139\230\160\143"
    }
  },
  xmission_gift_packet = {
    keyName = "xmission_gift_packet",
    moduleName = "client.slua.umg.TxMission.xMission.Settlement.xmission_gift_packet",
    path = "/Game/Mod/TPlan/XMission/UMG/Gift_Package/GP_Main_UIBP.GP_Main_UIBP",
    uiStat = {
      name = "XMission-\232\181\132\233\135\145\231\164\188\229\140\133"
    }
  },
  xmission_insurance_ui = {
    keyName = "xmission_insurance_ui",
    moduleName = "client.slua.umg.TxMission.xMission.insurance.xmission_insurance_ui",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Prepa_Insurance_item.Prepa_Insurance_item",
    uiStat = {
      name = "XMission-\230\138\149\228\191\157"
    }
  },
  xmission_levelup = {
    keyName = "xmission_levelup",
    moduleName = "client.slua.umg.TxMission.xMission.prestige.xmission_level_up",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmisson_World_Upgrade_UIBP.Xmisson_World_Upgrade_UIBP",
    uiStat = {
      name = "XMission-\229\163\176\230\156\155\231\173\137\231\186\167\229\141\135\231\186\167"
    }
  },
  xmission_mail_alert = {
    keyName = "xmission_mail_alert",
    moduleName = "client.slua.umg.TxMission.xMission.season.xmission_mail_alert",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_EmailAlert.Xmission_EmailAlert",
    uiStat = {
      name = "XMission-\233\130\174\228\187\182\230\143\144\233\134\146"
    }
  },
  xmission_main = {
    keyName = "xmission_main",
    moduleName = "client.slua.umg.TxMission.xMission.xmission_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_UIBP.Xmission_UIBP",
    limitScene = GameStatus.Lobby,
    uiStat = {
      name = "XMission-\228\184\187\231\149\140\233\157\162"
    }
  },
  xmission_match_entry = {
    keyName = "xmission_match_entry",
    moduleName = "client.slua.umg.TxMission.xMission.xmission_match_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_MatchEntryUIBP.Xmission_MatchEntryUIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\229\140\185\233\133\141\229\133\165\229\143\163"
    }
  },
  xmission_match_history_detail = {
    keyName = "xmission_match_history_detail",
    moduleName = "client.slua.umg.TxMission.xMission.match_history.xmission_match_history_detail",
    path = "/Game/Mod/TPlan/EvoBase/BluePrints/UI/Settlement/XT_St_history_Evacuate_UIBP.XT_St_history_Evacuate_UIBP",
    uiStat = {
      name = "XMission-\229\142\134\229\143\178\230\136\152\231\187\169\232\175\166\231\187\134\233\161\181\233\157\162"
    }
  },
  xmission_npc_conversation = {
    keyName = "xmission_npc_conversation",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.xmission_npc_conversation",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Conversation_UIBP.Xmission_Conversation_UIBP",
    uiStat = {
      name = "XMission-NPC\228\188\154\232\175\157"
    }
  },
  xmission_npc_dialog = {
    keyName = "xmission_npc_dialog",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.xmission_npc_dialog",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Conversation_LD_UIBP.Xmission_Conversation_LD_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-NPC\229\175\185\232\175\157\230\161\134"
    }
  },
  xmission_npc_favor_detail = {
    keyName = "xmission_npc_favor_detail",
    moduleName = "client.slua.umg.TxMission.xMission.npc.xmission_npc_favor_detail",
    path = "/Game/Mod/TPlan/XMission/UMG/NPC_System/Xmisson_NPC_Rewards_UIBP.Xmisson_NPC_Rewards_UIBP",
    uiStat = {
      name = "XMission-NPC\231\174\128\228\187\139"
    }
  },
  xmission_npc_gift = {
    keyName = "xmission_npc_gift",
    moduleName = "client.slua.umg.TxMission.xMission.npc.xmission_npc_gift",
    path = "/Game/Mod/TPlan/XMission/UMG/NPC_System/Xmission_NPC_Give_UIBP.Xmission_NPC_Give_UIBP",
    uiStat = {
      name = "XMission-NPC\233\128\129\231\164\188"
    }
  },
  xmission_npc_levelup = {
    keyName = "xmission_npc_levelup",
    moduleName = "client.slua.umg.TxMission.xMission.npc.xmission_npc_levelup",
    path = "/Game/Mod/TPlan/XMission/UMG/NPC_System/Xmission_NPC_Favorability_UIBP.Xmission_NPC_Favorability_UIBP",
    uiStat = {
      name = "XMission-NPC\229\165\189\230\132\159\229\141\135\231\186\167"
    }
  },
  xmission_npc_main = {
    keyName = "xmission_npc_main",
    moduleName = "client.slua.umg.TxMission.xMission.npc.xmission_npc_main",
    path = "/Game/Mod/TPlan/XMission/UMG/NPC_System/Xmisson_NPC_MainI_UIBP.Xmisson_NPC_MainI_UIBP",
    uiStat = {
      name = "XMission-NPC\228\184\187\231\149\140\233\157\162"
    }
  },
  xmission_npc_menu = {
    keyName = "xmission_npc_menu",
    moduleName = "client.slua.umg.TxMission.xMission.npc.xmission_npc_menu",
    path = "/Game/Mod/TPlan/XMission/UMG/NPC_System/Xmisson_NPC_MainItem_UIBP.Xmisson_NPC_MainItem_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-NPC\232\143\156\229\141\149\228\191\161\230\129\175"
    }
  },
  xmission_npc_talk = {
    keyName = "xmission_npc_talk",
    moduleName = "client.slua.umg.TxMission.xMission.npc.xmission_npc_talk",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmission_NpcTalk_Tips_UIBP.Xmission_NpcTalk_Tips_UIBP",
    uiStat = {
      name = "XMission-\229\164\167\229\142\133npc\230\143\144\231\164\186\232\175\173"
    }
  },
  xmission_npc_talk_entry = {
    keyName = "xmission_npc_talk_entry",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.xmission_npc_talk_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_NpcTalk_UIBP.Xmission_NpcTalk_UIBP",
    uiStat = {
      name = "XMission-\229\164\167\229\142\133npc\231\130\185\229\135\187\229\133\165\229\143\163"
    }
  },
  xmission_part_store = {
    keyName = "xmission_part_store",
    moduleName = "client.slua.umg.TxMission.xMission.black_market.xmission_part_store",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/Xmisson_PartStore_UIBP.Xmisson_PartStore_UIBP",
    uiStat = {
      name = "XMission-\233\133\141\228\187\182\229\149\134\229\159\142"
    }
  },
  xmission_prepare_ui = {
    keyName = "xmission_prepare_ui",
    moduleName = "client.slua.umg.TxMission.xMission.prepare.xmission_prepare_ui",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Wardrobe_Prepare_UIBP.Wardrobe_Prepare_UIBP",
    isMainUI = false,
    uiStat = {
      name = "XMission-\230\144\186\229\184\166\230\149\176\233\135\143"
    }
  },
  xmission_prestige = {
    keyName = "xmission_prestige",
    moduleName = "client.slua.umg.TxMission.xMission.prestige.xmission_prestige",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Xmisson_ReputationLevel_Popup_UIBP.Xmisson_ReputationLevel_Popup_UIBP",
    uiStat = {
      name = "XMission-\229\163\176\230\156\155\231\173\137\231\186\167"
    }
  },
  xmission_prestige_entry = {
    keyName = "xmission_prestige_entry",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.xmission_prestige_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Prestige_UIBP.Xmission_Prestige_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\229\163\176\230\156\155\231\173\137\231\186\167\229\133\165\229\143\163"
    }
  },
  xmission_rank_ui = {
    keyName = "xmission_rank_ui",
    moduleName = "client.slua.umg.TxMission.xMission.rank.xmission_rank_ui",
    path = "/Game/Mod/TPlan/XMission/UMG/Rank/XMRankUIBP.XMRankUIBP",
    uiStat = {
      name = "XMission-\230\142\146\232\161\140\230\166\156"
    }
  },
  xmission_rp = {
    keyName = "xmission_rp",
    moduleName = "client.slua.umg.TxMission.xMission.xmission_rp",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_UnknowPass_UIBP.Xmission_UnknowPass_UIBP",
    uiStat = {
      name = "XMission-\233\128\154\232\161\140\232\175\129\229\133\165\229\143\163"
    }
  },
  xmission_season_detail = {
    keyName = "xmission_season_detail",
    moduleName = "client.slua.umg.TxMission.xMission.season.xmission_season_detail",
    path = "/Game/Mod/TPlan/XMission/UMG/Season/Xmission_Season_Details_UIBP.Xmission_Season_Details_UIBP",
    uiStat = {
      name = "XMission-\232\181\155\229\173\163\232\175\166\230\131\133"
    }
  },
  xmission_season_levelup = {
    keyName = "xmission_season_levelup",
    moduleName = "client.slua.umg.TxMission.xMission.season.xmission_season_levelup",
    path = "/Game/Mod/TPlan/XMission/UMG/Season/Xmission_Levelup_UIBP.Xmission_Levelup_UIBP",
    uiStat = {
      name = "XMission-\229\134\155\229\138\159\229\141\135\231\186\167"
    }
  },
  xmission_season_main = {
    keyName = "xmission_season_main",
    moduleName = "client.slua.umg.TxMission.xMission.season.xmission_season_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Season/Xmission_Season_UIBP.Xmission_Season_UIBP",
    uiStat = {
      name = "XMission-\232\181\155\229\173\163\228\184\187\233\161\181"
    }
  },
  xmission_select_quantity = {
    keyName = "xmission_select_quantity",
    moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_select_quantity",
    path = "/Game/Mod/TPlan/XMission/UMG/Prepare/Prepare_CarryingQuantity.Prepare_CarryingQuantity",
    uiStat = {
      name = "XMission-\230\144\186\229\184\166\230\149\176\233\135\143"
    }
  },
  xmission_settle_award_tips = {
    keyName = "xmission_settle_award_tips",
    moduleName = "client.slua.umg.TxMission.xMission.Settlement.xmission_settle_award_tips",
    path = "/Game/Mod/TPlan/XMission/UMG/Gift_Package/GP_Tips_UIBP.GP_Tips_UIBP",
    uiStat = {
      name = "XMission-\232\181\132\233\135\145\231\164\188\229\140\133tips"
    }
  },
  xmission_sub_segment = {
    keyName = "xmission_sub_segment",
    moduleName = "client.slua.umg.TxMission.xMission.season.xmission_sub_segment",
    path = "/Game/Mod/TPlan/XMission/UMG/Season/Item/Xmission_Season_Deatails_Item_02_UIBP.Xmission_Season_Deatails_Item_02_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\229\173\144\230\174\181\228\189\141"
    }
  },
  xmission_talent = {
    keyName = "xmission_talent",
    moduleName = "client.slua.umg.TxMission.xMission.talent.talent_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_Talent_UIBP.Xmission_Talent_UIBP",
    uiStat = {
      name = "XMission-\229\164\169\232\181\139\231\179\187\231\187\159"
    }
  },
  xmission_talent_jump = {
    keyName = "xmission_talent_jump",
    moduleName = "client.slua.umg.TxMission.xMission.talent.talent_jump",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_Talent_Jump_UIBP.Xmission_Talent_Jump_UIBP",
    uiStat = {
      name = "XMission-\229\164\169\232\181\139\231\179\187\231\187\159\229\188\185\231\170\151\232\175\180\230\152\142"
    }
  },
  xmission_talent_newbie = {
    keyName = "xmission_talent_newbie",
    moduleName = "client.slua.umg.TxMission.xMission.talent.talent_newbie",
    path = "/Game/Mod/TPlan/XMission/UMG/Talent/Xmission_Talent_NoviceGuide_UIBP.Xmission_Talent_NoviceGuide_UIBP",
    uiStat = {
      name = "XMission-\229\164\169\232\181\139\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  xmission_task_brief = {
    keyName = "xmission_task_brief",
    moduleName = "client.slua.umg.TxMission.xMission.task.xmission_task_brief",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Misson_UIBP.Xmission_Misson_UIBP",
    uiStat = {
      name = "XMission-\228\187\187\229\138\161\231\174\128\232\166\129"
    }
  },
  xmission_task_main = {
    keyName = "xmission_task_main",
    moduleName = "client.slua.umg.TxMission.xMission.task.xmission_task_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Task/Xmission_Task_UIBP.Xmission_Task_UIBP",
    uiStat = {
      name = "XMission-\228\187\187\229\138\161\232\175\166\230\131\133"
    }
  },
  xmission_team_detail = {
    keyName = "xmission_team_detail",
    moduleName = "client.slua.umg.TxMission.xMission.team.xmission_team_detail",
    path = "/Game/Mod/TPlan/XMission/UMG/Item/Xmission_Team_PlayerInformation_Item_UIBP.Xmission_Team_PlayerInformation_Item_UIBP",
    uiStat = {
      name = "XMission-\233\152\159\229\143\139\232\175\166\230\131\133"
    }
  },
  xmission_team_main = {
    keyName = "xmission_team_main",
    moduleName = "client.slua.umg.TxMission.xMission.team.xmission_team_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Team_UIBP.Xmission_Team_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\233\152\159\228\188\141\229\173\144\231\149\140\233\157\162"
    }
  },
  xmission_team_menu = {
    keyName = "xmission_team_menu",
    moduleName = "client.slua.umg.TxMission.xMission.team.xmission_team_menu",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Team_Player_Information_UIBP.Xmission_Team_Player_Information_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\233\152\159\229\143\139\228\191\161\230\129\175\230\161\134"
    }
  },
  xmission_team_platform_entry = {
    keyName = "xmission_team_platform_entry",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.xmission_team_platform_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_TeamPlatformEntry_UIBP.Xmission_TeamPlatformEntry_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\231\187\132\233\152\159\229\185\179\229\143\176\229\133\165\229\143\163"
    }
  },
  xmission_team_platform_evaluation = {
    keyName = "xmission_team_platform_evaluation",
    moduleName = "client.slua.umg.TxMission.xMission.team_platform.xmission_team_platform_evaluation",
    path = "/Game/Mod/TPlan/XMission/UMG/TeamPlatform/XM_TeamPlatform_Experience_UIBP.XM_TeamPlatform_Experience_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "XMission-\231\187\132\233\152\159\229\185\179\229\143\176-\232\175\132\228\187\183"
    }
  },
  xmission_team_quick_msg = {
    keyName = "xmission_team_quick_msg",
    moduleName = "client.slua.umg.TxMission.xMission.team.xmission_team_quick_msg",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_Team_QuickMsg_UIBP.Xmission_Team_QuickMsg_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\233\152\159\229\143\139\232\129\138\229\164\169\230\176\148\230\179\161"
    }
  },
  xmission_treasure_entry = {
    keyName = "xmission_treasure_entry",
    moduleName = "client.slua.umg.TxMission.xMission.lobby.xmission_treasure_entry",
    path = "/Game/Mod/TPlan/XMission/UMG/Xmission_MoneyBox_UIBP.Xmission_MoneyBox_UIBP",
    uiStat = {
      name = "XMission-\232\181\132\233\135\145\229\174\157\231\174\177\229\133\165\229\143\163"
    }
  },
  xmission_voice_over_dialog = {
    keyName = "xmission_voice_over_dialog",
    moduleName = "client.slua.umg.TxMission.xMission.conversation.xmission_voice_over_dialog",
    path = "/Game/Mod/TPlan/XMission/UMG/Conversation/Xmission_Dialogue_UIBP.Xmission_Dialogue_UIBP",
    isSingleton = false,
    uiStat = {
      name = "XMission-\230\151\129\231\153\189\229\175\185\232\175\157\230\161\134"
    }
  },
  xmission_wardrobe = {
    keyName = "xmission_wardrobe",
    moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_wardrobe_main",
    path = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Main_UIBP.Wardrobe_Main_UIBP",
    uiStat = {
      name = "XMission\228\187\147\229\186\147"
    }
  },
  xmission_wardrobe_purchase_gift = {
    keyName = "xmission_wardrobe_purchase_gift",
    moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_wardrobe_purchase_gift",
    path = "/Game/Mod/TPlan/XMission/UMG/Store/Xmission_Store_QuickConfigPopup_UIBP.Xmission_Store_QuickConfigPopup_UIBP",
    uiStat = {
      name = "XMission\228\187\147\229\186\147\229\191\171\230\141\183\232\180\173\228\185\176"
    }
  },
  TExpressionPop_New_UIBP = {
    keyName = "TExpressionPop_New_UIBP",
    moduleName = "client.slua.umg.Souvenirs.ExpressionPop_New_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/ExpressionPop_New_UIBP.ExpressionPop_New_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "t\229\164\167\229\142\133\232\161\168\230\131\133\229\177\149\231\164\186"
    }
  },
  TLobby_Main_FunProp_List_UIBP = {
    keyName = "TLobby_Main_FunProp_List_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_Main_FunProp_List_UIBP",
    path = "/Game/Mod/TPlan/XMission/UMG/Lobby_Main_FunProp_List_UIBP.Lobby_Main_FunProp_List_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "t\229\164\167\229\142\133-\231\142\169\229\133\183\228\189\191\231\148\168\229\188\185\229\135\186\231\149\140\233\157\162"
    }
  }
}
return xmission_ui_configs