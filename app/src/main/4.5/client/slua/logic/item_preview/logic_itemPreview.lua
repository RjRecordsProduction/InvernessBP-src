local ItemPrewViewSystem = {
  Enum_Preview_Type = {
    EnumType_Default = 0,
    EnumType_Activity = 1,
    EnumType_Drop = 2,
    EnumType_Box = 3,
    EnumType_ThreeColumnPreview = 4,
    EnumType_MultiPool = 6,
    EnumType_Model = 7
  },
  Enum_List_Type = {
    EListType_Default = 0,
    EListType_Own = 1,
    EListType_Try = 2,
    EListType_Box = 3,
    EListType_ThreeCol = 4,
    EnumType_MultiPool = 6
  },
  Enum_BackGround_Type = {Default = 0, Hallowman = 1},
  IsFromGodzillaMainUI = false,
  CurBackGroundType = 0,
  BackGround_Path = {
    [0] = "/Game/Arts_Scenes/Lobby/Lobby_Roulettebackground/Lobby_jinzhuang_01_mat.Lobby_jinzhuang_01_mat",
    [1] = "/Game/Arts_UI/LuckySpin/2200/Global/Pumpkin/Lobby_Roululette_Halloween2022/MI_Roululette_Halloween2022_Inst.MI_Roululette_Halloween2022_Inst"
  }
}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function ItemPrewViewSystem.IsNeedShow(itemID, otherConfig)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.GM_ShowDetailItem then
    itemID = UIUtil.GM_ShowDetailItem
  end
  local isShow = false
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local fromSpin = otherConfig and otherConfig.fromSpin
  local isPandoraPreview = otherConfig and otherConfig.isPandoraPreview
  if itemCfg == nil then
    return isShow
  end
  local item_preview_type_config = require("client.slua.logic.item_preview.Item_preview_type_config")
  if item_preview_type_config[itemCfg.ItemType] then
    if type(item_preview_type_config[itemCfg.ItemType]) == "table" then
      isShow = item_preview_type_config[itemCfg.ItemType][itemCfg.ItemSubType] or false
    else
      isShow = true
    end
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and isPandoraPreview then
    isShow = true
  end
  if fromSpin then
    isShow = true
  end
  if itemID == 612004026 then
    isShow = true
  end
  if otherConfig and otherConfig.bForceShowPreview then
    isShow = true
  end
  if otherConfig and otherConfig.bFromThemeTask then
    isShow = true
  end
  return isShow
end
function ItemPrewViewSystem.FilterItems(itemList, otherConfig)
  local list = {}
  if itemList and next(itemList) then
    for i, v in pairs(itemList) do
      local itemID = v.itemId or v.item_id or v.itemID or v.resid
      local count = v.num or v.count or v.itemCount or v.item_num
      local valid_time = v.valid_time or v.valid_hours or v.vaild_time
      if ItemPrewViewSystem.IsNeedShow(itemID, otherConfig) then
        table.insert(list, {
          itemID = itemID,
          count = count,
          repeate_flag = v.repeate_flag,
          is_collected = v.is_collected,
          valid_time = valid_time,
          pool_id = v.pool_id
        })
      end
    end
  end
  return list
end
function ItemPrewViewSystem.OpenItemPreviewPanel(itemID, type, itemPara, validHours, other)
  if string.find(itemID, ",") == nil then
    local extraData = {bAutoDownload = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemID}, nil, nil, extraData)
  else
    local mid = string.find(itemID, ",")
    local first = tonumber(string.sub(itemID, 1, mid - 1))
    local second = tonumber(string.sub(itemID, mid + 1, #itemID))
    local extraData = {bAutoDownload = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {first, second}, nil, nil, extraData)
  end
  ItemPrewViewSystem.ShowItemPreviewPanel(itemID, type, itemPara, validHours, other)
end
function ItemPrewViewSystem.ShowItemPreviewPanel(itemID, nPreviewType, itemPara, validHours, other)
  local logic_itemPreview = require("client.slua.logic.item_preview.logic_itemPreview")
  local Enum_Preview_Type = logic_itemPreview.Enum_Preview_Type
  local tAllShowItem
  local nSelectItemId = itemID
  if type(itemID) == "string" then
    tAllShowItem = {}
    local StringUtil = require("common.string_util")
    local tAllItem = StringUtil.Split(itemID, ",")
    for _, v in ipairs(tAllItem) do
      table.insert(tAllShowItem, {
        itemID = tonumber(v)
      })
    end
    nSelectItemId = tAllShowItem[1].itemID
  elseif type(itemID) == "number" and (not itemPara or type(itemPara) == "table" and not next(itemPara)) then
    tAllShowItem = {
      {itemID = itemID}
    }
  elseif nPreviewType == Enum_Preview_Type.EnumType_Box or nPreviewType == Enum_Preview_Type.EnumType_Drop then
    nSelectItemId = itemPara and tonumber(itemPara) or itemID
  elseif nPreviewType == Enum_Preview_Type.EnumType_MultiPool then
    tAllShowItem = ItemPrewViewSystem.GenMultiPoolItemList(itemPara, other)
  else
    tAllShowItem = ItemPrewViewSystem.FilterItems(itemPara, other)
  end
  if tAllShowItem and #tAllShowItem == 1 and validHours and 0 < validHours then
    tAllShowItem[1].valid_time = validHours
  end
  UIManager.ShowUI(UIManager.UI_Config.ItemPreview_UIBP, nPreviewType, nSelectItemId, tAllShowItem, other)
end
function ItemPrewViewSystem.GenMultiPoolItemList(tAllItem, tExtraData)
  local tAllPool = {}
  for k, _ in ipairs(tExtraData.multiPoolTab) do
    tAllPool[k] = {}
  end
  for _, v in pairs(tAllItem) do
    local nItemId = v.resid
    local nCount = v.count or 1
    local nValidTime = v.valid_hours or 0
    if ItemPrewViewSystem.IsNeedShow(nItemId, tExtraData) then
      table.insert(tAllPool[v.pool_id], {
        itemID = nItemId,
        count = nCount,
        valid_time = nValidTime,
        pool_id = v.pool_id
      })
    end
  end
  return tAllPool
end
function ItemPrewViewSystem.CloseItemPreviewPanel()
  if UIManager.GetUI(UIManager.UI_Config.ItemPreview_UIBP) then
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_ITEM_PREVIEW)
  end
end
return ItemPrewViewSystem