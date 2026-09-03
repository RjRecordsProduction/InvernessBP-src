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
local pet_ui_configs = {
  pet_main = {
    keyName = "pet_main",
    moduleName = "client.slua.umg.pet.pet_main",
    jumpModuleID = BP_ENUM_MODULE_PET_ENTER,
    path = "/Game/UMG/UI_BP/Pet/Pet_UIBP.Pet_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159"
    },
    useBatchOptimization = true
  },
  pet_main_tips = {
    keyName = "pet_main_tips",
    moduleName = "client.slua.umg.pet.pet_main_tips",
    path = "/Game/UMG/UI_BP/Pet/Pet_Tips_UIBP.Pet_Tips_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true
  },
  pet_access = {
    keyName = "pet_access",
    moduleName = "client.slua.umg.pet.pet_access",
    path = "/Game/UMG/UI_BP/Pet/Pet_PopUp_UIBP.Pet_PopUp_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\232\142\183\229\143\150\229\173\144\231\179\187\231\187\159"
    }
  },
  pet_feed = {
    keyName = "pet_feed",
    moduleName = "client.slua.umg.pet.pet_feed",
    path = "/Game/UMG/UI_BP/Pet/Pet_UseProps_UIBP.Pet_UseProps_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\229\150\130\229\133\187\229\173\144\231\179\187\231\187\159"
    }
  },
  pet_dress_card = {
    keyName = "pet_dress_card",
    moduleName = "client.slua.umg.pet.pet_dress_card",
    path = "/Game/UMG/UI_BP/Pet/Pet_PopUp01_UIBP.Pet_PopUp01_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\228\189\147\233\170\140\229\141\161\229\173\144\231\179\187\231\187\159"
    }
  },
  pet_rename = {
    keyName = "pet_rename",
    moduleName = "client.slua.umg.pet.pet_rename",
    path = "/Game/UMG/UI_BP/Pet/Pet_ReviseName_UIBP.Pet_ReviseName_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\230\148\185\229\144\141\229\173\144\231\179\187\231\187\159"
    }
  },
  pet_share = {
    keyName = "pet_share",
    moduleName = "client.slua.umg.pet.pet_share",
    path = "/Game/UMG/UI_BP/Pet/Pet_Share_01_UIBP.Pet_Share_01_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\229\136\134\228\186\171-\228\188\153\228\188\180"
    }
  },
  pet_setting = {
    keyName = "pet_setting",
    moduleName = "client.slua.umg.pet.pet_setting",
    path = "/Game/UMG/UI_BP/Pet/Pet_PopUp_01_UIBP.Pet_PopUp_01_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\232\174\190\231\189\174\229\173\144\231\179\187\231\187\159"
    }
  },
  pet_share_choose = {
    keyName = "pet_share_choose",
    moduleName = "client.slua.umg.pet.pet_share_choose",
    path = "/Game/UMG/UI_BP/Pet/Pet_Share_UIBP.Pet_Share_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\228\188\153\228\188\180-\229\185\179\229\143\176\233\128\137\230\139\169"
    }
  },
  pet_levelup = {
    keyName = "pet_levelup",
    moduleName = "client.slua.umg.pet.pet_levelup",
    path = "/Game/UMG/UI_BP/Pet/Pet_Levelup_01_UIBP.Pet_Levelup_01_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    asy = true,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\229\141\135\231\186\167\229\188\185\231\170\151"
    }
  },
  pet_choosepet = {
    keyName = "pet_choosepet",
    moduleName = "client.slua.umg.pet.pet_choosepet",
    path = "/Game/UMG/UI_BP/Pet/Pet_UIBP_01.Pet_UIBP_01",
    ODPackID = PufferConst.EODPackID.Pet,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\233\128\137\230\139\169\228\188\153\228\188\180"
    }
  },
  pet_decompose_notice = {
    keyName = "pet_decompose_notice",
    moduleName = "client.slua.umg.pet.pet_decompose_notice",
    path = "/Game/UMG/UI_BP/Pet/Pet_Decompose_Popup_UIBP.Pet_Decompose_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.Pet,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\233\128\137\230\139\169\228\188\153\228\188\180"
    }
  },
  pet_carry_select = {
    keyName = "pet_carry_select",
    moduleName = "client.slua.umg.pet.pet_carry_select",
    path = "/Game/UMG/UI_BP/Pet/Pet_UIBP_01.Pet_UIBP_01",
    ODPackID = PufferConst.EODPackID.Pet,
    uiStat = {
      name = "\228\188\153\228\188\180\231\179\187\231\187\159-\230\144\186\229\184\166\228\188\153\228\188\180\233\128\137\230\139\169"
    }
  },
  Pet_Portal_UIBP = {
    keyName = "Pet_Portal_UIBP",
    isMainUI = false,
    moduleName = "client.slua.umg.pet.Pet_Portal_UIBP",
    path = "/Game/UMG/UI_BP/Pet/Pet_Portal_UIBP.Pet_Portal_UIBP",
    uiStat = {
      name = "\229\174\160\231\137\169\229\183\165\229\157\138-\233\155\134\231\187\147\231\137\185\230\149\136\233\128\137\230\139\169"
    }
  },
  arena_weapon = {
    keyName = "arena_weapon",
    moduleName = "client.slua.umg.arena.arena_weapon",
    path = "/Game/UMG/UI_BP/Team_competition/WeaponSet/Team_competition_gun_UIBP.Team_competition_gun_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ARENA_WEAPON,
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\230\158\170\230\162\176"
    }
  },
  Team_competition_Leisure_UIBP = {
    keyName = "Team_competition_Leisure_UIBP",
    moduleName = "client.slua.umg.arena.Team_competition_Leisure_UIBP",
    path = "/Game/UMG/UI_BP/Team_competition/Leisure/Team_competition_Leisure_UIBP.Team_competition_Leisure_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ARENA_FEATURE,
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\231\137\185\230\128\167"
    }
  },
  arena_weapon_upgrade = {
    keyName = "arena_weapon_upgrade",
    moduleName = "client.slua.umg.arena.arena_weapon_upgrade",
    path = "/Game/UMG/UI_BP/Team_competition/Gun_upgrade.Gun_upgrade",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\230\158\170\230\162\176\229\141\135\231\186\167\232\167\163\233\148\129"
    }
  },
  ui_prepare_scheme_main = {
    keyName = "ui_prepare_scheme_main",
    moduleName = "client.slua.umg.prepareScheme.ui_prepare_scheme_main",
    path = "/Game/UMG/UI_BP/Team_competition/Team_competition_battle_preparation_UIBP.Team_competition_battle_preparation_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\162\231\171\158\230\136\152\229\164\135-\228\184\187\231\149\140\233\157\162"
    }
  },
  arena_weapon_levelup = {
    keyName = "arena_weapon_levelup",
    moduleName = "client.slua.umg.arena.arena_weapon_level_up",
    path = "/Game/UMG/UI_BP/Team_competition/Tmode_Upgrade_UIBP.Tmode_Upgrade_UIBP",
    uiStat = {
      name = "\229\141\135\231\186\167\231\149\140\233\157\162-\230\158\170\230\162\176"
    },
    containerName = UIContainers.Top
  },
  Team_Competition_Invite_Tip_UIBP = {
    keyName = "Team_Competition_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.LoginLoading.Team_competition.Team_Competition_Invite_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Competition_Invite_Tip_UIBP.Team_Competition_Invite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\229\133\172\229\133\177-\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  }
}
return pet_ui_configs