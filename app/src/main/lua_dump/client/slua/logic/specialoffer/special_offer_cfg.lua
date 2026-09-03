local Cfg = {
  recharge = 1,
  subscribe = 2,
  golden = 3,
  MaterialsGift = 4,
  ConditionsGift = 5,
  ACTIVITY_TYPE_CONSUME_UC = 6,
  CONSUME_UC = 7,
  DiscountDirect = 8,
  SmallPayment = 11,
  Financial = 12,
  DailyFortunePack = 13,
  DailySpecialBundle = 14,
  PandoraPopular = 16,
  OPTIONAL_RECHARGE = 17,
  SmallRP = 18,
  TEMU = 19,
  NewGroupBuy = 20
}
local id2ActId = {
  [Cfg.golden] = 123022101
}
local ActId2Id = {
  [123022101] = Cfg.golden
}
local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
local RechargeSystemJK = require("client.logic.recharge.logic_recharge_jk")
local Logic_SpecialCoinUtils = require("client.slua.logic.specialoffer.Logic_SpecialCoinUtils")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
if PublishRegionMacros.IsJapanOrKorea() then
  Cfg.LimitedSet = 8
  Cfg.recharge_purchase = 9
  Cfg.JkGiftSet = 201
  id2ActId[Cfg.golden] = 227022101
  ActId2Id[227022101] = Cfg.golden
end
function Cfg.SetActId(id, ActId)
  log_warning(bWriteLog and "  :SetActId ActId: " .. tostring(ActId))
  log_warning(bWriteLog and "  :SetActId id: " .. tostring(id))
  id2ActId[id] = ActId
  ActId2Id[ActId] = id
end
local recharge, golden, recharge_purchase, ACTIVITY_TYPE_CONSUME_UC, JkGiftSet, LimitedSet, MaterialsGift, ConditionsGift, OPTIONAL_RECHARGE, CONSUME_UC, DailyFortunePack, DailySpecialBundle, Financial, DiscountDirect, TEMU, NewGroupBuy = Cfg.recharge, Cfg.golden, Cfg.recharge_purchase, Cfg.ACTIVITY_TYPE_CONSUME_UC, Cfg.JkGiftSet, Cfg.LimitedSet, Cfg.MaterialsGift, Cfg.ConditionsGift, Cfg.OPTIONAL_RECHARGE, Cfg.CONSUME_UC, Cfg.DailyFortunePack, Cfg.DailySpecialBundle, Cfg.Financial, Cfg.DiscountDirect, Cfg.TEMU, Cfg.NewGroupBuy
local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
logic_scrapgold_draw.ActivityId = id2ActId[golden]
Cfg.id2ResId = {
  [NewGroupBuy] = 166081,
  [golden] = 44720,
  [ACTIVITY_TYPE_CONSUME_UC] = 44721,
  [recharge] = 4085,
  [Cfg.subscribe] = 6504,
  [MaterialsGift] = 44722,
  [ConditionsGift] = 44723,
  [OPTIONAL_RECHARGE] = 54047,
  [DailyFortunePack] = 64118,
  [Financial] = 42976,
  [DailySpecialBundle] = 64114,
  [CONSUME_UC] = 44724,
  [Cfg.SmallRP] = 66014,
  [Cfg.PandoraPopular] = 65520,
  [DiscountDirect] = 76201,
  [TEMU] = 527065
}
Cfg.id2ResIdByIn = {
  [Financial] = 1,
  [DailySpecialBundle] = 2,
  [ConditionsGift] = 3,
  [golden] = 4,
  [Cfg.SmallRP] = 5,
  [recharge] = 6,
  [CONSUME_UC] = 7,
  [ACTIVITY_TYPE_CONSUME_UC] = 8,
  [MaterialsGift] = 9,
  [OPTIONAL_RECHARGE] = 10,
  [DailyFortunePack] = 11,
  [Cfg.subscribe] = 12,
  [Cfg.SmallPayment] = 13,
  [Cfg.PandoraPopular] = 14,
  [DiscountDirect] = 15,
  [TEMU] = 10,
  [NewGroupBuy] = 1
}
Cfg.uiCdg = {
  [golden] = "LuckySpinScrapGold",
  [recharge] = "ui_recharge",
  [ACTIVITY_TYPE_CONSUME_UC] = "SpecialOffer_ValueRebate_UIBP",
  [CONSUME_UC] = "SpecialOffer_ValueRebate_UIBP",
  [MaterialsGift] = "SpecialOffer_Material_UIBP",
  [ConditionsGift] = "SpecialOffer_Conditions_Container",
  [OPTIONAL_RECHARGE] = "CustomPack_Main_UIBP",
  [DailyFortunePack] = "everydaypack_activity_v2",
  [Financial] = "Financial_Template_UIBP",
  [DailySpecialBundle] = "everydaypack_activity",
  [Cfg.subscribe] = "Subscribe_HomePage_New_UIBP",
  [Cfg.SmallRP] = "SmallRP_Award_UIBP",
  [Cfg.PandoraPopular] = "Pandora_Popular_UIBP",
  [DiscountDirect] = "Lobby_Direct_Main_UIBP",
  [TEMU] = "SpecialOffer_Temu_Container",
  [NewGroupBuy] = "RroupBuying_Main_UIBP"
}
Cfg.id2Func = {
  [golden] = logic_scrapgold_draw.OpenUIWithActId
}
Cfg.waitShow = {
  [golden] = true,
  [Cfg.SmallRP] = true
}
Cfg.hideClickBolck = {
  [Cfg.SmallRP] = true
}
local smallTicket = CoinMacro.SmallTicket
if PublishRegionMacros.IsJapanOrKorea() then
  smallTicket = CoinMacro.SmallTicket_JK
end
local onlyUc = {
  CoinMacro.Uc
}
Cfg.id2Coins = {
  [golden] = {
    smallTicket,
    CoinMacro.GoldenMark,
    CoinMacro.GoldenMarkScrap,
    CoinMacro.Uc
  },
  [recharge] = onlyUc,
  [MaterialsGift] = {
    smallTicket,
    CoinMacro.Uc
  },
  [ConditionsGift] = {
    smallTicket,
    CoinMacro.Uc,
    CoinMacro.Ag
  },
  [Cfg.subscribe] = {smallTicket},
  [DiscountDirect] = onlyUc,
  [CONSUME_UC] = {
    smallTicket,
    CoinMacro.Uc
  },
  [ACTIVITY_TYPE_CONSUME_UC] = {
    smallTicket,
    CoinMacro.Uc
  },
  [DailySpecialBundle] = {
    smallTicket,
    CoinMacro.Uc
  },
  [Financial] = {
    smallTicket,
    CoinMacro.Uc
  },
  [DailyFortunePack] = {
    smallTicket,
    CoinMacro.Uc,
    CoinMacro.LuckyScrap
  },
  [OPTIONAL_RECHARGE] = {
    smallTicket,
    CoinMacro.Uc
  },
  [Cfg.SmallRP] = Logic_SpecialCoinUtils.GetSmallRPCoinShowCfg(),
  [Cfg.TEMU] = {
    CoinMacro.Uc
  },
  [NewGroupBuy] = logic_group_buying:GetGroupBuyShowCfg()
}
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local GetPandoraAct = function(id)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  return special_offer_module:GetPandoraActData(id)
end
local Get3940Act = function(id)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  return special_offer_module:Get3940ActData(id)
end
Cfg.id2CheckShow = {
  [Cfg.golden] = function()
    local actData = ActivityNewSystem.GetActivityByID(id2ActId[Cfg.golden])
    return actData ~= nil
  end,
  [Cfg.PandoraPopular] = function()
    return GetPandoraAct(Cfg.PandoraPopular)
  end,
  [ACTIVITY_TYPE_CONSUME_UC] = function()
    return Get3940Act(ACTIVITY_TYPE_CONSUME_UC)
  end,
  [CONSUME_UC] = function()
    return Get3940Act(CONSUME_UC)
  end,
  [OPTIONAL_RECHARGE] = function()
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local nCurAOSSHOP = Client.GetAOSSHOP()
    local TimeUtil = require("client.common.time_util")
    local actData = ActivityNewSystem.GetActivityByType(ActivityType.OPTIONAL_RECHARGE)
    local bIsShow = nCurAOSSHOP ~= AOSSHOPMacros.Samsung and nCurAOSSHOP ~= AOSSHOPMacros.Amazon
    if actData and actData.EndTime > TimeUtil.GetServerTimeInSec() and bIsShow then
      return true
    end
    return false
  end,
  [MaterialsGift] = function()
    local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
    local bHasData = logic_special_offer_material:CheckGiftData()
    return bHasData
  end,
  [ConditionsGift] = function(tArgs)
    local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
    local bIsHide = logic_special_offer_condition:IsHidePage()
    if bIsHide then
      return false
    end
    local data = logic_special_offer_condition:GetGiftsData()
    if not data or not next(data) then
      log(bWriteLog and "ConditionsGift is not data")
      return false
    end
    local isInExpDate = logic_special_offer_condition:IsInExpirationDate()
    if not isInExpDate then
      return false
    end
    if tArgs and tArgs.shopid then
      for _, GiftData in pairs(data) do
        if 0 < #GiftData and GiftData[1] then
          local goodsId = GiftData[1].goodsId
          if goodsId == tonumber(tArgs.shopid) then
            return true
          end
        end
      end
      return false
    end
    return true
  end,
  [Cfg.subscribe] = function()
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    local bIsSubscribeOpen = subscribeModuleObj:GetIsPrimeOpen()
    return bIsSubscribeOpen
  end,
  [Cfg.SmallRP] = function(tArgs)
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    local special_offer_net_cfg = require("client.slua.logic.specialoffer.special_offer_net_cfg")
    special_offer_net_cfg.SendActNetByType(Cfg.SmallRP)
    if tArgs and tArgs.round then
      return Logic_SmallRP:GetIsOpen() and tonumber(tArgs.round) == Logic_SmallRP:GetActRoundId()
    end
    return Logic_SmallRP:GetIsOpen()
  end,
  [Cfg.DailyFortunePack] = function()
    local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local TimeUtil = require("client.common.time_util")
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    local data = EveryDayPackSystem.everydayV2SystemData
    local aosShop = Client.GetAOSSHOP()
    local bIsHideTab = aosShop == AOSSHOPMacros.Samsung or aosShop == AOSSHOPMacros.Amazon
    if data and next(data) and not bIsHideTab and data.end_ts >= TimeUtil.GetServerTimeInSec() then
      return true
    end
    if data and data.end_ts and data.end_ts < TimeUtil.GetServerTimeInSec() then
      special_offer_module:SwitchToWorkShop(Cfg.uiCdg[DailyFortunePack])
    end
    if data and next(data) then
      EveryDayPackSystem.everydayV2SystemData = nil
      EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, Cfg.DailyFortunePack)
    end
    return false
  end,
  [Cfg.DailySpecialBundle] = function()
    local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local TimeUtil = require("client.common.time_util")
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    local data = EveryDayPackSystem.everydaySystemData
    local aosShop = Client.GetAOSSHOP()
    local bIsHideTab = aosShop == AOSSHOPMacros.Samsung or aosShop == AOSSHOPMacros.Amazon
    if data and next(data) and not bIsHideTab and data.end_ts and data.end_ts >= TimeUtil.GetServerTimeInSec() then
      return true
    end
    if data and data.end_ts and data.end_ts < TimeUtil.GetServerTimeInSec() then
      special_offer_module:SwitchToWorkShop(Cfg.uiCdg[DailySpecialBundle])
    end
    return false
  end,
  [Cfg.Financial] = function()
    local Logic_Financial = require("client.slua.logic.Financial.Logic_Financial")
    local TimeUtil = require("client.common.time_util")
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    local tAllData = Logic_Financial.GetAllBoxData()
    local data = Logic_Financial.GetActivityBannerData()
    local _, nEndTime = Logic_Financial.GetActivityTime()
    local bIsOutTime = nEndTime and nEndTime < TimeUtil.GetServerTimeInSec()
    if not (tAllData and next(tAllData)) or bIsOutTime then
      if data then
        local FinancialHandler = require("client.network.Protocol.FinancialHandler")
        FinancialHandler.send_get_make_money_plan_req(data.ID)
      end
      if bIsOutTime then
        special_offer_module:SwitchToWorkShop(Cfg.uiCdg[Financial])
      end
      return false
    end
    return true
  end,
  [DiscountDirect] = function()
    local Discount_Direct_Logic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Discount_Direct_Logic)
    return Discount_Direct_Logic:IsShow()
  end,
  [Cfg.TEMU] = function()
    local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
    local seasonID = Logic_temu:GetCurSeasonID()
    if not seasonID or seasonID == 0 then
      return false
    end
    local isInTime = Logic_temu:IsCurSeasonInTime()
    if not isInTime then
      return false
    end
    return true
  end,
  [NewGroupBuy] = function()
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    return logic_group_buying:IsShow()
  end
}
if PublishRegionMacros.IsJapanOrKorea() then
  Cfg.id2Coins[golden] = {
    CoinMacro.SmallTicket_JK,
    CoinMacro.GoldenMark,
    CoinMacro.GoldenMarkScrap,
    CoinMacro.Uc
  }
  Cfg.id2ResId[recharge_purchase] = 31159
  Cfg.id2ResId[JkGiftSet] = 512295
  Cfg.id2ResId[LimitedSet] = 512296
  Cfg.id2Coins[recharge_purchase] = onlyUc
  Cfg.id2Coins[ACTIVITY_TYPE_CONSUME_UC] = onlyUc
  Cfg.id2Coins[JkGiftSet] = onlyUc
  Cfg.id2Coins[LimitedSet] = onlyUc
  Cfg.id2Coins[ConditionsGift] = {
    smallTicket,
    CoinMacro.Uc,
    CoinMacro.PigCoin
  }
  Cfg.id2Coins[DailyFortunePack] = {
    smallTicket,
    CoinMacro.Uc,
    CoinMacro.LuckyScrapJK
  }
  Cfg.uiCdg[recharge] = "ui_recharge_jk"
  Cfg.uiCdg[JkGiftSet] = "Lobby_DirectPurchase_LimitedTimeGiftSet"
  Cfg.uiCdg[LimitedSet] = "limited_purchase"
  Cfg.id2CheckShow[JkGiftSet] = function()
    return RechargeSystemJK.bShowSpecialChestTab
  end
  Cfg.id2CheckShow[LimitedSet] = RechargeSystemJK.IsCanShowLimitJk
end
local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
if Client.GetAOSSHOP() == AOSSHOPMacros.Samsung or Client.GetAOSSHOP() == AOSSHOPMacros.Amazon then
  Cfg.id2Coins[golden] = {
    CoinMacro.GoldenMark,
    CoinMacro.GoldenMarkScrap,
    CoinMacro.Uc
  }
  Cfg.id2Coins[MaterialsGift] = onlyUc
  Cfg.id2Coins[Cfg.subscribe] = {}
  Cfg.id2Coins[CONSUME_UC] = onlyUc
  Cfg.id2Coins[ACTIVITY_TYPE_CONSUME_UC] = onlyUc
  Cfg.id2Coins[DailySpecialBundle] = onlyUc
  Cfg.id2Coins[Financial] = onlyUc
  Cfg.id2Coins[DailyFortunePack] = onlyUc
  Cfg.id2Coins[ConditionsGift] = {
    CoinMacro.Uc,
    CoinMacro.Ag
  }
  if PublishRegionMacros.IsJapanOrKorea() then
    Cfg.id2Coins[ConditionsGift] = {
      CoinMacro.Uc,
      CoinMacro.PigCoin
    }
  end
  Cfg.id2Coins[DiscountDirect] = onlyUc
end
if RechargeSystemJK.IsCanShowPurchaseTab() then
  Cfg.uiCdg[recharge_purchase] = "recharge_purchase"
end
function Cfg.Init()
  Get3940Act(ACTIVITY_TYPE_CONSUME_UC)
  Get3940Act(CONSUME_UC)
end
Cfg.Cfg.return Cfg