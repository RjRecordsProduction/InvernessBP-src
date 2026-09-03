local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.GetSourceInfoByJumpInfo(jumpInfo, isCollectPage)
  if not jumpInfo then
    return ENUM_ItemSourceType.None, "", nil
  end
  local sourceText = ""
  local sourceType, jump = StoreUtils.GetSourceTypeByJumpInfo(jumpInfo)
  if sourceType == ENUM_ItemSourceType.Activity then
    sourceText = LocUtil.GetLocalizeResStr(7362)
  elseif sourceType == ENUM_ItemSourceType.Crate then
    sourceText = LocUtil.GetLocalizeResStr(7363)
  elseif sourceType == ENUM_ItemSourceType.Store then
    if type(jump) == "table" and jump.cant_buy ~= nil then
      sourceType = ENUM_ItemSourceType.None
    else
      sourceText = LocUtil.GetLocalizeResStr(7364)
    end
  elseif sourceType == ENUM_ItemSourceType.Chest then
    sourceText = LocUtil.GetLocalizeResStr(7365)
  elseif sourceType == ENUM_ItemSourceType.Direct then
    sourceText = LocUtil.GetLocalizeResStr(7365)
  elseif sourceType == ENUM_ItemSourceType.PDD then
    sourceText = LocUtil.GetLocalizeResStr(7366)
  elseif sourceType == ENUM_ItemSourceType.RP then
    sourceText = LocUtil.GetLocalizeResStr(7367)
  elseif sourceType == ENUM_ItemSourceType.BP then
    sourceText = LocUtil.GetLocalizeResStr(82171)
  elseif sourceType == ENUM_ItemSourceType.None then
    sourceText = ""
  end
  if isCollectPage then
    sourceType, sourceText = StoreUtils.JudgmentShopSaleState(sourceType, jump, tonumber(jumpInfo), sourceText)
  end
  return sourceType, sourceText, jump
end
function StoreUtils.JudgmentShopSaleState(sourceType, jump, itemId, sourceText)
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  if sourceType ~= ENUM_ItemSourceType.None then
    if jump and type(jump) == "table" and jump.end_time and jump.begin_time then
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      if jump.begin_time ~= 0 and serverTime < jump.begin_time then
        store_collect_data:RemoveFormNeedRedPointTab(itemId)
        return ENUM_ItemSourceType.None, ""
      elseif jump.end_time ~= 0 and serverTime > jump.end_time then
        store_collect_data:RemoveFormNeedRedPointTab(itemId)
        return ENUM_ItemSourceType.None, ""
      end
    end
  else
    store_collect_data:RemoveFormNeedRedPointTab(itemId)
  end
  return sourceType, sourceText
end
function StoreUtils.GetRPJumpInfo(tParams)
  local JumpUtils = require("client.logic.store.jump_utils")
  local nTab = tonumber(tParams.Tab1 or 0)
  local nItemId = tonumber(tParams.itemId or 0)
  local nSubTab = tonumber(tParams.Subtab or 0)
  local nPanelType = tonumber(tParams.panelType or 0)
  local info = {
    moduleId = JumpUtils.MODEL_ID_PASS,
    Tab1 = nTab,
    itemId = nItemId,
    Subtab = nSubTab,
    panelType = nPanelType
  }
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  local EnumPanelType = UnknowPassOpenUISystem.awardPanelType
  if nPanelType and nPanelType == EnumPanelType.BpAward then
    return ENUM_ItemSourceType.BP, info
  end
  return ENUM_ItemSourceType.RP, info
end
function StoreUtils.GetSourceTypeByJumpInfo(jumpInfo)
  local JumpUtils = require("client.logic.store.jump_utils")
  if string.find(jumpInfo, string.format("module=%d", JumpUtils.MODEL_ID_PASS)) or string.find(jumpInfo, string.format("module=%d", JumpUtils.MODEL_ID_BACKBOX_PASS)) or string.find(jumpInfo, string.format("module=%d", BP_ENUM_MODULE_UNKNOW_PASS)) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpInfo)
    return StoreUtils.GetRPJumpInfo(params)
  elseif string.find(jumpInfo, string.format("module=%d", JumpUtils.MODEL_ID_GIFT)) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpInfo)
    local itemId = tonumber(params.itemId)
    local chestItemId = JumpUtils.GetJumpToChestItemId(itemId)
    if chestItemId ~= -1 then
      local jumpInfoFromStore = JumpUtils.FindJumpInfoFirst(itemId, JumpUtils.MODEL_ID_STORE)
      return ENUM_ItemSourceType.Chest, jumpInfoFromStore
    else
      return ENUM_ItemSourceType.None, jumpInfo
    end
  elseif string.find(jumpInfo, string.format("module=%d", BP_ENUM_MODULE_MALL_CHILD)) then
    return ENUM_ItemSourceType.Store, jumpInfo
  elseif JumpUtils.IsGameJumpUrl(jumpInfo) and LobbySystem.CheckUrlCanJump(jumpInfo) then
    return ENUM_ItemSourceType.Activity, jumpInfo
  end
  local jumpInfoFromCollection = StoreConst.collection_jump_info[tonumber(jumpInfo)] or ""
  if jumpInfoFromCollection ~= "" then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpInfoFromCollection)
    local module = tonumber(params.module)
    if module == BP_ENUM_LOBBY_MENU_PURCHASE or module == BP_ENUM_LOBBY_MENU_PURCHASE_BANNER or module == BP_ENUM_MODULE_RECHARGE_PURCHASE then
      return ENUM_ItemSourceType.Direct, jumpInfoFromCollection
    elseif module == JumpUtils.MODEL_ID_PASS or module == JumpUtils.MODEL_ID_BACKBOX_PASS or module == BP_ENUM_MODULE_UNKNOW_PASS then
      return StoreUtils.GetRPJumpInfo(params)
    elseif JumpUtils.IsGameJumpUrl(jumpInfoFromCollection) and LobbySystem.CheckUrlCanJump(jumpInfoFromCollection) then
      return ENUM_ItemSourceType.Activity, jumpInfoFromCollection
    end
  end
  local jumpInfoFromStoreCrate = JumpUtils.FindJumpInfoFirst(jumpInfo, JumpUtils.MODEL_ID_STORE)
  if jumpInfoFromStoreCrate ~= nil then
    if jumpInfoFromStoreCrate.moduleId == JumpUtils.MODEL_ID_STORE then
      return ENUM_ItemSourceType.Store, jumpInfoFromStoreCrate
    elseif jumpInfoFromStoreCrate.moduleId == JumpUtils.MODEL_ID_SUPPLY then
      return ENUM_ItemSourceType.Crate, jumpInfoFromStoreCrate
    end
  end
  return ENUM_ItemSourceType.None, jumpInfo
end
function StoreUtils.AddParameterToJumpURL(t, key, source)
  if t ~= nil and type(t) == "table" and t[key] ~= nil then
    local isCrateURL, urlType = StoreUtils.IsJumpToCrateURL(t[key])
    if isCrateURL then
      if urlType == "table" then
        t[key].from = tostring(source)
        log_tree("StoreOtherUtils.AddParameterToJumpURL, after t[key] = ", t[key])
      elseif urlType == "string" and string.find(t[key], "from") == nil then
        t[key] = t[key] .. "&from=" .. tostring(source)
        log(bWriteLog and "StoreOtherUtils.AddParameterToJumpURL, after t[key] = " .. tostring(t[key]))
      end
    end
  end
end
function StoreUtils.IsJumpToCrateURL(url)
  local JumpUtils = require("client.logic.store.jump_utils")
  if type(url) == "table" then
    if tonumber(url.module) == BP_ENUM_MODULE_SUPPLY or tonumber(url.moduleId) == JumpUtils.MODEL_ID_SUPPLY then
      return true, "table"
    end
  elseif type(url) == "string" then
    local m1 = "module=" .. tostring(BP_ENUM_MODULE_SUPPLY)
    local m2 = "moduleId=" .. tostring(JumpUtils.MODEL_ID_SUPPLY)
    if string.find(url, m1) ~= nil or string.find(url, m2) ~= nil then
      return true, "string"
    end
  end
  return false, ""
end
function StoreUtils.JumpByInfo(jump)
  local JumpUtils = require("client.logic.store.jump_utils")
  if type(jump) == "string" then
    log(bWriteLog and "StoreOtherUtils.JumpByInfo, jump = " .. tostring(jump))
    GlobalData.JumpUrl(jump)
  elseif type(jump) == "table" then
    log_tree("StoreOtherUtils.JumpByInfo, jump = ", jump)
    local moduleId = tonumber(jump.moduleId)
    if moduleId == JumpUtils.MODEL_ID_STORE then
      jump.module = BP_ENUM_MODULE_MALL_CHILD
    elseif moduleId == JumpUtils.MODEL_ID_SUPPLY then
      jump.module = BP_ENUM_MODULE_SUPPLY
    elseif moduleId == JumpUtils.MODEL_ID_PASS then
      jump.module = BP_ENUM_MODULE_UNKNOW_PASS
    else
      jump.module = BP_ENUM_MODULE_LOBBY
    end
    local jump_utils = require("client.logic.store.jump_utils")
    jump_utils.OpenJumpModule(jump.module, jump)
  end
end
function StoreUtils.Jump(JumpInfo)
  local JumpUtils = require("client.logic.store.jump_utils")
  local thisJumpInfo = tostring(JumpInfo)
  if string.find(thisJumpInfo, string.format("module=%d", JumpUtils.MODEL_ID_PASS)) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(thisJumpInfo)
    local tab1 = tonumber(params.Tab1)
    local itemId = tonumber(params.itemId)
    local Subtab = tonumber(params.Subtab or 0)
    local info = {}
    info.    info.Tab1 = tab1
    info.SubTab = Subtab
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    UnknowPassTunnelSystem.ShowRP(info)
  elseif string.find(thisJumpInfo, string.format("module=%d", JumpUtils.MODEL_ID_GIFT)) then
  elseif JumpUtils.IsGameJumpUrl(thisJumpInfo) then
    GlobalData.JumpUrl(thisJumpInfo)
  else
    JumpUtils.Jump(JumpUtils.MODEL_ID_STORE, tonumber(thisJumpInfo))
  end
end
function StoreUtils.JumpFirst(JumpInfo)
  local JumpUtils = require("client.logic.store.jump_utils")
  local thisJumpInfo = tostring(JumpInfo)
  if JumpUtils.IsGameJumpUrl(thisJumpInfo) then
    GlobalData.JumpUrl(thisJumpInfo)
  else
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:JumpToStoreCrateByItemId(JumpInfo)
  end
end
function StoreUtils.CheckCanShowJumpChestByTabId(TabId)
  if TabId == StoreConst.Page_New_ID_Recommend or TabId == StoreConst.Page_New_ID_Cloth or TabId == StoreConst.Page_New_ID_Weapon or TabId == StoreConst.Page_New_ID_Car then
    return true
  else
    return false
  end
end