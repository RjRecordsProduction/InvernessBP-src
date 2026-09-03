local Logic_BonusPass_Const_Config = {
  specialShowLevel = {30, 60},
  colorful_guide_cfg = {
    TitleID = 6698901,
    BPPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture02_Item_UIBP.Common_Popup_Theme_Explain_Picture02_Item_UIBP",
    RefreshFun = function(node_root)
      if not node_root then
        return
      end
      local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
      local sVersionPath = UnknowPassUtil.GetVersionNumber()
      local Util = require("client.slua_ui_framework.util")
      local sPath1 = string.format("/Game/Arts_UI/UnknowPass/%s/NoAtlas/RP_Branch/New_Guide_ChangeColor01.New_Guide_ChangeColor01", sVersionPath)
      local sPath2 = string.format("/Game/Arts_UI/UnknowPass/%s/NoAtlas/RP_Branch/New_Guide_ChangeColor02.New_Guide_ChangeColor02", sVersionPath)
      Util.SetTexture(node_root.Image_Pic_1, sPath1)
      Util.SetTexture(node_root.Image_Pic_2, sPath2)
      node_root.Text_Pic_1:SetText(LocUtil.LocalizeResFormat(6698902))
      node_root.Text_Pic_2:SetText(LocUtil.LocalizeResFormat(6698903))
    end
  },
  ENUM_NEWGUIDE_KEY = {
    MainNewGuide = 1000,
    ColorfulGuide = 1001,
    ExtraReward = 1002
  },
  ENUM_BP_SPECIAL_REWARD_STATE = {
    NotReceive = 0,
    Receive = 1,
    NotEnough = 2
  },
  ENUM_FULL_BP_PRICE_TYPE = {
    None = 0,
    UC = 1,
    ExperienceCard = 2,
    HalfFullBP = 3,
    FullBP = 4,
    ExperienceRPCard = 5,
    NormalRPCard = 6,
    PlusRPCard = 7
  },
  ENUM_BP_TASK_TYPE = {
    AllTask = -1,
    ActiveTask = 1,
    BattleTask = 2,
    ExtraTask = 3
  },
  ENUM_BP_BUY_TYPE = {
    BuyType1 = 1,
    BuyType2 = 2,
    BuyType3 = 3,
    BuyType4 = 4,
    BuyType5 = 5,
    BuyType6 = 6,
    BuyType7 = 7,
    BuyType8 = 8,
    BuyType9 = 9,
    BuyType10 = 10,
    BuyType11 = 11,
    BuyType12 = 12,
    BuyType13 = 13,
    BuyType14 = 14,
    BuyType15 = 15,
    BuyType16 = 16,
    BuyType17 = 17,
    BuyType18 = 18,
    BuyType19 = 19,
    BuyType20 = 20,
    BuyType21 = 21,
    BuyType22 = 22,
    BuyType23 = 23,
    BuyType24 = 24,
    BuyType25 = 25,
    BuyType26 = 26,
    BuyType27 = 27,
    BuyType28 = 28,
    BuyType29 = 29,
    BuyType30 = 30,
    BuyType31 = 31,
    BuyType32 = 32,
    BuyType33 = 33,
    BuyType34 = 34,
    BuyType35 = 35,
    BuyType36 = 36,
    BuyType37 = 37,
    BuyType38 = 38,
    BuyType39 = 39,
    BuyType40 = 40,
    BuyType41 = 41,
    BuyType42 = 42,
    BuyType43 = 43,
    BuyType44 = 44,
    BuyType45 = 45,
    BuyType46 = 46,
    BuyType47 = 47,
    BuyType48 = 48,
    BuyType49 = 49,
    BuyType50 = 50,
    BuyType51 = 51,
    BuyType52 = 52,
    BuyType53 = 53,
    BuyType54 = 54,
    BuyType55 = 55,
    BuyType56 = 56,
    BuyType57 = 57,
    BuyType58 = 58,
    BuyType59 = 59,
    BuyType60 = 60,
    BuyType61 = 61,
    BuyType62 = 62,
    BuyType63 = 63,
    BuyType64 = 64,
    BuyType65 = 65,
    BuyType66 = 66,
    BuyType67 = 67,
    BuyType68 = 68,
    BuyType69 = 69,
    BuyType70 = 70,
    BuyType71 = 71,
    BuyType72 = 72,
    BuyType73 = 73,
    BuyType74 = 74,
    BuyType75 = 75,
    BuyType  }
}
return Logic_BonusPass_Const_Config