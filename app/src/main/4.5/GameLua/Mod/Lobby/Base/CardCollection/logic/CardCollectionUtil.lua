local CardCollectionUtil = {}
local CardCollectionSeasonUIConfig = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionSeasonUIConfig")
local EPaneltype = CardCollectionSeasonUIConfig.ECardCollectionPanelType
local EPopuptype = CardCollectionSeasonUIConfig.ECardCollectionPopupType
local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
local C_Fragment_ID = 1024
function CardCollectionUtil.ShowFragmentTips(widget)
  local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
  local actURL = ThemeConfig.GetCurrentThemeShopActJump()
  local jumpSource = {}
  if actURL ~= "" then
    jumpSource[#jumpSource + 1] = {
      text = LocUtil.GetLocalizeResStr(6475),
      jumpURL = actURL
    }
  end
  jumpSource[#jumpSource + 1] = {
    text = LocUtil.GetLocalizeResStr(33020122),
    jumpFunction = function()
      CardCollectionUtil.OpenPopup(EPopuptype.DailyTask)
    end
  }
  local itemCfg = CDataTable.GetTableData("Item", C_Fragment_ID) or {}
  UIManager.ShowUI(UIManager.UI_Config.CardCollection_Fragment_Tips_UIBP, itemCfg, jumpSource, {
    widget = widget,
    customOffset = {X = -120, Y = 50}
  })
end
function CardCollectionUtil.ShowDuplicateCompensateTips(theme_count)
  UIManager.ShowUI(UIManager.UI_Config.SmartAssistant_RobotTips04_UIBP, {
    desc = LocUtil.LocalizeResFormat(33020248, theme_count),
    onClaim = function()
      UIManager.CloseUI(UIManager.UI_Config.SmartAssistant_RobotTips04_UIBP)
      local compensateModule = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionCompensateModule)
      if compensateModule then
        compensateModule:ClaimCompensation()
      end
    end
  })
end
function CardCollectionUtil.OpenPopup(Popuptype, extraData)
  local doOpenPopup = function()
    local popup_config = CardCollectionSeasonUIConfig.PopupConfig[Popuptype]
    UIManager.ShowUI(popup_config, extraData)
  end
  if LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_CardCollection) then
    doOpenPopup()
  else
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_CardCollection, function()
      doOpenPopup()
    end)
  end
end
function CardCollectionUtil.OpenPanel(Paneltype, extraData)
  local doOpenPanel = function()
    local panel_config = CardCollectionSeasonUIConfig.PanelConfig[Paneltype]
    if Paneltype == EPaneltype.Share or Paneltype == EPaneltype.SwapShare or Paneltype == EPaneltype.RareCardShare then
      local Util = require("client.slua_ui_framework.util")
      local logic_community = require("client.slua.logic.community.logic_community")
      local shareCfg = {}
      Util.ShowShare(shareCfg, panel_config, extraData)
      return
    end
    if Paneltype == EPaneltype.Main or Paneltype == EPaneltype.Set then
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      local jumpModuleID = Paneltype == EPaneltype.Main and BP_ENUM_MODULE_CARD_COLLECTION_MAIN or BP_ENUM_MODULE_CARD_COLLECTION_SET
      local ctorData = extraData or {}
      ui_jump_manager.OpenJumpModule(jumpModuleID, ctorData)
      return
    end
    UIManager.ShowUI(panel_config, extraData)
  end
  if LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_CardCollection) then
    doOpenPanel()
  else
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_CardCollection, function()
      doOpenPanel()
    end)
  end
end
function CardCollectionUtil.OpenMain(extraData)
  CardCollectionUtil.OpenPanel(EPaneltype.Main, extraData)
end
function CardCollectionUtil.OpenSet(extraData)
  CardCollectionUtil.OpenPanel(EPaneltype.Set, extraData)
end
function CardCollectionUtil.SearchPlayer(Players, text)
  local result = {}
  if not Players then
    return result
  end
  if not text or text == "" then
    return Players
  end
  local StringUtil = require("common.string_util")
  local searchKeyTable = {
    "nickName",
    "remark",
    "uid"
  }
  for _, playerData in ipairs(Players) do
    for _, searchKey in ipairs(searchKeyTable) do
      local src = playerData[searchKey]
      if src then
        local isPattrnFound = StringUtil.StrFind(string.lower(tostring(src)), string.lower(text))
        if isPattrnFound then
          table.insert(result, playerData)
          break
        end
      end
    end
  end
  return result
end
function CardCollectionUtil.IsCardCollectionOpen()
  return LobbySystem.CheckOpen(BP_ENUM_CARDCOLLECTION_SWITCH)
end
function CardCollectionUtil.CardGetPanel(itemIdList, buttonList, extendData)
  local cardCollectionCardModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardModule)
  local cardDataList = {}
  local setID
  for _, item in ipairs(itemIdList) do
    local cardData = cardCollectionCardModule:GetCardShowDataByItemId(item.res_id) or {}
    setID = cardData.SetID
    table.insert(cardDataList, {show_data = cardData})
    if not cardData.Grade then
      extendData = extendData or {}
      extendData.from = CardCollectionSeasonUIConfig.ECardFromType.NewVersion
    end
  end
  if #cardDataList == 0 then
    return
  end
  table.sort(cardDataList, function(a, b)
    return (a.show_data.Grade or 0) > (b.show_data.Grade or 0)
  end)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
  local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
  local Enum_BtnStyle = CommonItemGet_Const.Enum_BtnStyle
  local allButtonConfigs = {
    CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(6752), Enum_BtnStyle.Blue, extendData and extendData.ConfirmFunc),
    CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(33020174), Enum_BtnStyle.Blue, function()
      if setID then
        CardCollectionUtil.OpenPanel(EPaneltype.Set, {setID = setID})
      end
    end),
    CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(33020175), Enum_BtnStyle.Orange, function()
      local CardCollectionUIConfig = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionSeasonUIConfig")
      CardCollectionUtil.OpenPanel(EPaneltype.Share, {
        data = {
          CardData = cardDataList,
          shareType = CardCollectionUIConfig.EShareType.Card
        }
      })
    end)
  }
  local tAllBtnShowData = {}
  if not buttonList then
    tAllBtnShowData = allButtonConfigs
  else
    for _, btnIndex in ipairs(buttonList) do
      if allButtonConfigs[btnIndex] then
        table.insert(tAllBtnShowData, allButtonConfigs[btnIndex])
      end
    end
  end
  local tShowConfig = {
    nItemListStyle = CommonItemGet_Const.Enum_ItemListStyle.CardCollection,
    bCheckSpecialItem = false,
    tAllBtnShowData = tAllBtnShowData,
    extendData = extendData or {}
  }
  Logic_CommonItemGet.ShowPanel_FullCustom(cardDataList, tShowConfig)
end
function CardCollectionUtil.OpenSwapShare(give_card_list, expect_res_id, order_id, create_time)
  local panel_config = CardCollectionSeasonUIConfig.PanelConfig[EPaneltype.SwapShare]
  local Util = require("client.slua_ui_framework.util")
  local logic_community = require("client.slua.logic.community.logic_community")
  local shareCfg = {
    sceneType = ShareSceneType.CardCollectionExchange,
    clubShareParams = {
      bShowShareClub = true,
      publishFeedType = logic_community.PublishFeedType.CardExchange,
      gameScene = "CardExchange"
    }
  }
  local cardCollectionSwapModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionSwapModule)
  local orderData = {
    order_id = order_id,
    create_time = create_time,
    data = {give_card_list = give_card_list, expect_res_id = expect_res_id}
  }
  orderData.show_data = cardCollectionSwapModule:GetCardShowDataByOrderInfo(orderData)
  Util.ShowShare(shareCfg, panel_config, {orderInfo = orderData})
end
function CardCollectionUtil.IsCardOnline(showData)
  local dataModule = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionDataModule)
  if dataModule then
    return dataModule:IsCardOnline(showData)
  end
  return false
end
return CardCollectionUtil