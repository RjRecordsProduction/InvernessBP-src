local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
local Enum_ChildName = CommonItem_Const.Enum_ChildName
local Enum_ItemChildZOrder = CommonItem_Const.Enum_ItemChildZOrder
local CommonItem_ChildCfg = {
  [Enum_ChildName.GoldEquipQuality] = {
    sBpPath = "/Game/UMG/UI_BP/Common/Quality8Item_UIBP.Quality8Item_UIBP",
    sParentName = "CanvasPanel_Quality",
    nZOrder = Enum_ItemChildZOrder.Default
  },
  [Enum_ChildName.Selected] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Selected_UIBP.CommonItem_Selected_UIBP",
    sParentName = "CanvasPanel_NotScale",
    nZOrder = Enum_ItemChildZOrder.Default
  },
  [Enum_ChildName.BlackMask] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_BlackMask_UIBP.CommonItem_BlackMask_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.BlackMask]
  },
  [Enum_ChildName.HasGet] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_HasGet_UIBP.CommonItem_HasGet_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.HasGet]
  },
  [Enum_ChildName.ContentText] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_ContentText_UIBP.CommonItem_ContentText_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.ContentText]
  },
  [Enum_ChildName.GlowingEffect] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_GlowingEffect_UIBP.CommonItem_GlowingEffect_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.GlowingEffect]
  },
  [Enum_ChildName.Equipping] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Equipping_UIBP.CommonItem_Equipping_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Equipping]
  },
  [Enum_ChildName.CoBranded] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_CoBranded_UIBP.CommonItem_CoBranded_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.CoBranded]
  },
  [Enum_ChildName.CollectStatus] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_CollectStatusShow_UIBP.CommonItem_CollectStatusShow_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.CollectStatus]
  },
  [Enum_ChildName.ProbabilityUp] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_ProbabilityUp_UIBP.CommonItem_ProbabilityUp_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.ProbabilityUp]
  },
  [Enum_ChildName.Using] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_LeftTopImage_UIBP.CommonItem_LeftTopImage_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Using]
  },
  [Enum_ChildName.Exclusive] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_LeftTopImage_UIBP.CommonItem_LeftTopImage_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Exclusive]
  },
  [Enum_ChildName.ExculsiveOneYear] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/Common_Home_MerchantAnniversary_UIBP.Common_Home_MerchantAnniversary_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.ProbabilityUp]
  },
  [Enum_ChildName.PetSuitIcon] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/Commonitem_PetSuit_UIBP.Commonitem_PetSuit_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.PetSuitIcon]
  },
  [Enum_ChildName.PlusSuperscript] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Plus_UIBP.CommonItem_Plus_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.PlusSuperscript]
  },
  [Enum_ChildName.NewTip] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_NewTip_UIBP.CommonItem_NewTip_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.NewTip]
  },
  [Enum_ChildName.SpecialIcon] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_SpecialIcon_UIBP.CommonItem_SpecialIcon_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.SpecialIcon]
  },
  [Enum_ChildName.Lock] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Lock_UIBP.CommonItem_Lock_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Lock]
  },
  [Enum_ChildName.SharedBackpack] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_SharedBackpack_UIBP.CommonItem_SharedBackpack_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.SharedBackpack]
  },
  [Enum_ChildName.TryOnText] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_TryOnText_UIBP.CommonItem_TryOnText_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.TryOnText]
  },
  [Enum_ChildName.LimitIcon] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_LimitTime_UIBP.CommonItem_LimitTime_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.LimitIcon]
  },
  [Enum_ChildName.AffixPVEIcon] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_AffixPVEIcon_UIBP.CommonItem_AffixPVEIcon_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.AffixPVEIcon]
  },
  [Enum_ChildName.ParticleStar] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_ParticleStar_UIBP.CommonItem_ParticleStar_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.ParticleStar]
  },
  [Enum_ChildName.CollectNum] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_CollectNum_UIBP.CommonItem_CollectNum_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.CollectNum]
  },
  [Enum_ChildName.RedEmotion] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_RedEmotion_UIBP.CommonItem_RedEmotion_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.RedEmotion]
  },
  [Enum_ChildName.InheritIcon] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_InheritancePrivileges_UIBP.CommonItem_InheritancePrivileges_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.InheritIcon]
  },
  [Enum_ChildName.MatchNum] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_MatchNum_UIBP.CommonItem_MatchNum_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.MatchNum]
  },
  [Enum_ChildName.UpgradeDiscountNum] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/WorkShopItem/CommonItem_CostCount_SpecialOffer_UIBP.CommonItem_CostCount_SpecialOffer_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.UpgradeDiscountNum]
  },
  [Enum_ChildName.TeamTimes] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_WecomeBack_UIBP.CommonItem_WecomeBack_UIBP",
    sParentName = "CanvasPanel_ItemShow",
    nZOrder = Enum_ItemChildZOrder.Default
  },
  [Enum_ChildName.Signature] = {
    sBpPath = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Signature_UIBP.CommonItem_Signature_UIBP",
    sParentName = "CanvasPanel_Signature",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Signature]
  }
}
return CommonItem_ChildCfg