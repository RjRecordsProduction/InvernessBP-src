local MixItemConfig = {}
MixItemConfig.AwardColorConfig = {
  [0] = "000000",
  [1] = "000000",
  [2] = "868686",
  [3] = "39A277",
  [4] = "3770B6",
  [5] = "792FC6",
  [6] = "C22FA8",
  [7] = "E03C31",
  [8] = "D5971D"
}
MixItemConfig.AwardIconColorConfig = {
  [true] = "4C4C4C",
  [false] = "FFFFFF"
}
MixItemConfig.ChooseMode = {ChooseNumber = 1, ChooseAll = 2}
MixItemConfig.SmeltMode = {
  None = 0,
  Normal = 1,
  Exchange = 2,
  N_And_E = 3
}
MixItemConfig.OperationType = {
  None = 0,
  Add = 1,
  AddByNC = 2,
  Subtract = 3,
  ModifyCount = 4,
  ClearAll = 5
}
MixItemConfig.EETabConfig = {
  {
    txt = LocUtil.GetLocalizeResStr(3000048)
  },
  {
    txt = LocUtil.GetLocalizeResStr(3000049)
  }
}
MixItemConfig.EESelectTabType = {
  All = 1,
  LockedEE = 2,
  UnlockedEE = 3
}
MixItemConfig.EEClueStatus = {
  Unknown = 0,
  Triggered = 1,
  Solved = 2
}
MixItemConfig.EETabType = {UnknownEE = 1, UnlockedEE = 2}
MixItemConfig.EEStatus = {
  Unknown = 0,
  Unlocked = 1,
  Got = 2
}
MixItemConfig.EEOperationChar = {Equal = 1, GreaterEqual = 2}
MixItemConfig.EECCType = {
  SmeltOnceItemIDCount = 1,
  SmeltOnceItemCount = 2,
  SmeltOnceItemSubTypeCount = 3,
  TotalWealthConsumed = 4,
  SmeltOnceItemKindCount = 5,
  SmeltHistoryItemIDCount = 6,
  SmeltHistoryItemCount = 7,
  SmeltHistoryItemSubTypeCount = 8,
  SmeltHistoryItemKindCount = 9
}
MixItemConfig.ErrCode = {
  [20020001] = 505015,
  [20020002] = 3000059,
  [20020003] = 3000060,
  [20020004] = 3000061,
  [20020005] = 3000062,
  [20020006] = 3000063,
  [20020007] = 3000064,
  [20020008] = 3000065,
  [995006] = 3000066,
  [20020009] = 3000067,
  [20020010] = 3000068,
  [19840019] = 3000069
}
MixItemConfig.CommonItemName = {
  Subtract = "Subtract",
  WealthValue = "WealthValue",
  UseCount = "MixItemUseCount"
}
local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
MixItemConfig.CommonItemZOrder = CommonItem_Utils.CreateZOrderEnum("MixItemCommonItemShowCfg")
MixItemConfig.CommonItemConfig = {
  [MixItemConfig.CommonItemName.Subtract] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Subtract_UIBP.CommonItem_Subtract_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = MixItemConfig.CommonItemZOrder[MixItemConfig.CommonItemName.Subtract]
  },
  [MixItemConfig.CommonItemName.WealthValue] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_WealthValue_UIBP.CommonItem_WealthValue_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = MixItemConfig.CommonItemZOrder[MixItemConfig.CommonItemName.WealthValue]
  },
  [MixItemConfig.CommonItemName.UseCount] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/WorkShopItem/CommonItem_CostCount_UIBP.CommonItem_CostCount_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = MixItemConfig.CommonItemZOrder[MixItemConfig.CommonItemName.UseCount]
  }
}
MixItemConfig.DrawSession = {UnbackSession = 1, BackSession = 2}
MixItemConfig.NumInfinite = -1
MixItemConfig.EEConditionType = {Hint = 1, Got = 2}
MixItemConfig.GuideConfig = {
  [1] = {
    TitleID = 3000074,
    BPPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture02_Item_UIBP.Common_Popup_Theme_Explain_Picture02_Item_UIBP",
    RefreshFun = function(node_root)
      if not node_root then
        return
      end
      local Util = require("client.slua_ui_framework.util")
      Util.SetTexture(node_root.Image_Pic_1, "/Game/Arts_UI/FromUMG/MixItem/Main/NoAtlas/MixItem_GuidePopup_Image_Left.MixItem_GuidePopup_Image_Left")
      Util.SetTexture(node_root.Image_Pic_2, "/Game/Arts_UI/FromUMG/MixItem/Main/NoAtlas/MixItem_GuidePopup_Image_Right.MixItem_GuidePopup_Image_Right")
      node_root.Text_Pic_1:SetText(LocUtil.LocalizeResFormat(3000075))
      node_root.Text_Pic_2:SetText(LocUtil.LocalizeResFormat(3000076))
      node_root.Text_Desc:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      node_root.Text_Desc:SetText("")
    end
  }
}
MixItemConfig.SpecialEE = {
  PlannerChat = 4,
  NotFound404 = 5,
  GoldenVoucher = 8,
  ClickEffect = 9
}
MixItemConfig.SpecialHint = {
  [MixItemConfig.SpecialEE.NotFound404] = true
}
MixItemConfig.SpecialGot = {
  [MixItemConfig.SpecialEE.PlannerChat] = true,
  [MixItemConfig.SpecialEE.NotFound404] = true
}
MixItemConfig.AwardGetConfig = {
  [MixItemConfig.SpecialEE.PlannerChat] = {
    Title = LocUtil.GetLocalizeResStr(3000136),
    Desc = LocUtil.GetLocalizeResStr(3000137),
    Picture = "/Game/Arts_UI/FromUMG/MixItem/Main/NoAtlas/Popup/MixItem_Image_Popup_Funny_01.MixItem_Image_Popup_Funny_01",
    ConfirmText = LocUtil.GetLocalizeResStr(110036)
  },
  [MixItemConfig.SpecialEE.NotFound404] = {
    Title = LocUtil.GetLocalizeResStr(3000138),
    Desc = LocUtil.GetLocalizeResStr(3000139),
    Picture = "/Game/Arts_UI/FromUMG/MixItem/Main/NoAtlas/Popup/MixItem_Image_Popup_404.MixItem_Image_Popup_404",
    ConfirmText = LocUtil.GetLocalizeResStr(110036)
  }
}
MixItemConfig.PopupType = {
  Guide = 1,
  NotFound404 = 2,
  ItemGet = 3,
  PlannerChatGo = 4,
  DrawSwitch = 5,
  SpecialEEGet = 6
}
MixItemConfig.SpecialEEShowStatus = {
  Wait = 0,
  CanShow = 1,
  HasShowed = 2
}
MixItemConfig.PlanBindEasterEgg = {
  [2026001] = MixItemConfig.SpecialEE.ClickEffect
}
return MixItemConfig