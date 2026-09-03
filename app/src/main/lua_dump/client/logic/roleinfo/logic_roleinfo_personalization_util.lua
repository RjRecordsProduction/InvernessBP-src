local logic_roleinfo_personalization_util = {}
function logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview(itemCfg)
  if not (itemCfg and itemCfg.ItemID) or not itemCfg.ItemSubType then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview no itemCfg")
    return false
  end
  log(bWriteLog and "logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview itemId:" .. tostring(itemCfg.ItemID))
  local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
  if not PersonalizationConst.Preview_SubItemTypeToPageIndex[itemCfg.ItemSubType] then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview true")
    return false
  end
  if FuncUtil.IsInXMission() then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckAndShowPersonalizedItemPreview inxmission")
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_roleinfo_personalization_util CheckAndShowPersonalizedItemPreview is not in lobby")
    return false
  end
  if not logic_roleinfo_personalization_util.CheckIfUIShowItem(itemCfg) then
    log(bWriteLog and "logic_roleinfo_personalization_util CheckAndShowPersonalizedItemPreview check false")
    return false
  end
  log(bWriteLog and "logic_roleinfo_personalization_util CheckAndShowPersonalizedItemPreview JumpUrl")
  local jumpUrl = string.format(PersonalizationConst.Preview_ItemJumpUrl, PersonalizationConst.Preview_SubItemTypeToPageIndex[itemCfg.ItemSubType], itemCfg.ItemID)
  GlobalData.JumpUrl(jumpUrl)
  return true
end
function logic_roleinfo_personalization_util.CheckIfUIShowItem(itemCfg)
  if not itemCfg or not itemCfg.ItemID then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckIfUIShowItem no itemCfg")
    return false
  end
  if itemCfg.ItemSubType == 20001 then
    local HeadportraitCfg = CDataTable.GetTableData("Headportrait", itemCfg.ItemID)
    return HeadportraitCfg and HeadportraitCfg.DefaultDisplay == 1
  elseif itemCfg.ItemSubType == 2002 then
    local AvatarFrameCfg = CDataTable.GetTableData("AvatarFrame", itemCfg.ItemID)
    return AvatarFrameCfg and AvatarFrameCfg.DefaultDisplay == 1
  elseif itemCfg.ItemSubType == 2491 then
    local aliasCfg = CDataTable.GetTableData("AliasCfg", itemCfg.ItemID)
    return aliasCfg and aliasCfg.AliasIsLockedShow == 1
  else
    return true
  end
end
function logic_roleinfo_personalization_util.CheckIsPersonalizedItemPreview(itemCfg)
  if not (itemCfg and itemCfg.ItemID) or not itemCfg.ItemSubType then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckIsPersonalizedItemPreview no itemCfg")
    return false, nil
  end
  log(bWriteLog and "logic_roleinfo_personalization_util.CheckIsPersonalizedItemPreview itemId:" .. tostring(itemCfg.ItemID))
  local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
  if not PersonalizationConst.Preview_SubItemTypeToPageIndex[itemCfg.ItemSubType] then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckIsPersonalizedItemPreview true")
    return false, nil
  end
  if FuncUtil.IsInXMission() then
    log(bWriteLog and "logic_roleinfo_personalization_util.CheckIsPersonalizedItemPreview inxmission")
    return false, nil
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_roleinfo_personalization_util CheckIsPersonalizedItemPreview is not in lobby")
    return false, nil
  end
  if not logic_roleinfo_personalization_util.CheckIfUIShowItem(itemCfg) then
    log(bWriteLog and "logic_roleinfo_personalization_util CheckIsPersonalizedItemPreview check false")
    return false, nil
  end
  local jumpUrl = string.format(PersonalizationConst.Preview_ItemJumpUrl, PersonalizationConst.Preview_SubItemTypeToPageIndex[itemCfg.ItemSubType], itemCfg.ItemID)
  log(bWriteLog and "logic_roleinfo_personalization_util CheckIsPersonalizedItemPreview jumpUrl:" .. jumpUrl)
  return true, jumpUrl
end
function logic_roleinfo_personalization_util.AddEffectSkinByCreateChildWindow(parentUIBase, bgPath, parentPanel, aniName, extraData)
  if not parentUIBase.effectRoots then
    parentUIBase.effectRoots = {}
  end
  if parentUIBase.effectRoots[parentPanel] then
    parentUIBase.effectRoots[parentPanel]:Close()
    parentUIBase.effectRoots[parentPanel] = nil
  end
  local pak_util = require("client.common.pak_util")
  if bgPath and bgPath ~= "" then
    if pak_util.IsPufferDownloaded(bgPath) then
      local uiConfig = UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP
      local childUI = parentUIBase:CreateChildWindowWithBpPath(parentPanel, uiConfig, bgPath, aniName, extraData)
      parentUIBase.effectRoots[parentPanel] = childUI
      return childUI
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {bgPath})
    end
  else
    log(bWriteLog and "Personalization_BaseItem_UIBP:AddEffectSkinByCreateChildWindow Error bgPath" .. tostring(bgPath))
  end
  return nil
end
return logic_roleinfo_personalization_util