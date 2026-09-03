local IntimacyUtils = {}
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
function IntimacyUtils.GetRelationRichText(relation)
  local mapping = IntimacyConst.C_IntimacyRelationRichText
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not mapping[relation] then
    log_error_format("IntimacyUtils.GetRelationRichText relation invalid, relation = %s", relation)
    return ""
  end
  if not bIsBondingSystem and relation == 6 then
    return LocUtil.GetLocalizeResStr(mapping[2])
  else
    return LocUtil.GetLocalizeResStr(mapping[relation])
  end
end
function IntimacyUtils.GetRelationText(relation)
  local mapping = IntimacyConst.C_IntimacyRelationText
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not mapping[relation] then
    log_error_format("IntimacyUtils.GetRelationText relation invalid, relation = %s", relation)
    return ""
  end
  if not bIsBondingSystem and relation == 6 then
    return LocUtil.GetLocalizeResStr(mapping[2])
  else
    return LocUtil.GetLocalizeResStr(mapping[relation])
  end
end
function IntimacyUtils.GetRelationTextColor(relation)
  local mapping = IntimacyConst.C_IntimacyRelationTextColor
  if not mapping[relation] then
    log_error_format("IntimacyUtils.GetRelationTextColor relation invalid, relation = %s", relation)
    return FLinearColor(1, 1, 1, 1)
  end
  return mapping[relation]
end
function IntimacyUtils.GetRelationMaxCnt(relation)
  local maxCnt = IntimacyConst.C_IntimacyMaxCount[relation]
  if not maxCnt then
    log_error_format("IntimacyUtils.GetRelationMaxCnt relation invalid, relation = %s", relation)
    return 6
  end
  return maxCnt
end
function IntimacyUtils.GetRelationTypeIcon(relation)
  local icon = IntimacyConst.C_IntimacyTypeIcon[relation]
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not icon then
    log_error_format("IntimacyUtils.GetRelationTypeIcon relation invalid, relation = %s", relation)
  end
  if not bIsBondingSystem and relation == 6 then
    return IntimacyConst.C_IntimacyTypeIcon[2]
  else
    return icon
  end
end
function IntimacyUtils.GetRelationTypeSmallIcon(relation)
  local icon = IntimacyConst.C_IntimacyTypeSmallIcon[relation]
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not icon then
    log_error_format("IntimacyUtils.GetRelationTypeIcon relation invalid, relation = %s", relation)
  end
  if not bIsBondingSystem and relation == 6 then
    return IntimacyConst.C_IntimacyTypeSmallIcon[2]
  else
    return icon
  end
end
function IntimacyUtils.IsBondingSystemOpen()
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  return logic_friend_intimacy:GetSoulmateSystemOpen()
end
function IntimacyUtils.ShowIntimacyApplyUI(...)
  local bOpen = IntimacyUtils.IsBondingSystemOpen()
  if bOpen then
    UIManager.ShowUI(UIManager.UI_Config.friend_intimacy_apply, ...)
  else
    UIManager.ShowUI(UIManager.UI_Config.friend_intimacy_apply_old, ...)
  end
end
function IntimacyUtils.ShouldCheckBondingGender()
  return true
end
function IntimacyUtils.GetReuseListMultiSize_Intimacy_Data(friendList)
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local lineDataList = {}
  local isEmpty = true
  local lineCount = 2
  if 0 < #friendList then
    local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
    local threshold = logic_new_friend.Friend_Intimacy_Threshold
    local oneLineData
    for k, v in pairs(friendList) do
      if oneLineData == nil then
        oneLineData = {
          uids = {},
          states = {}
        }
      end
      table.insert(oneLineData.uids, v)
      isEmpty = false
      local intimacyData = logic_new_friend.GetIntimacyData(v)
      if intimacyData then
        table.insert(oneLineData.states, intimacyData.state)
      else
        table.insert(oneLineData.states, 0)
      end
      if lineCount <= #oneLineData.uids then
        table.insert(lineDataList, oneLineData)
        oneLineData = nil
      end
    end
    if oneLineData then
      table.insert(lineDataList, oneLineData)
      oneLineData = nil
    end
  end
  return lineDataList, isEmpty
end
function IntimacyUtils.ShowCrystalTips(crystalData, uiArgs)
  if crystalData.crystalType == 1 then
    local widget, offsetX, offsetY, data, uid = uiArgs.widget, uiArgs.offsetX, uiArgs.offsetY, uiArgs.data, uiArgs.uid
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Crystal_Tips_UIBP, widget, offsetX, offsetY, data, uid)
  elseif crystalData.crystalType == 2 then
    local id = crystalData.cfg.ID
    if id == 1 then
      local widget, offsetX, offsetY, data, uid = uiArgs.widget, uiArgs.offsetX, uiArgs.offsetY, uiArgs.data, uiArgs.uid
      UIManager.ShowUI(UIManager.UI_Config.Lobby_Crystal_Tips_UIBP, widget, offsetX, offsetY, data, uid)
    elseif id == 2 then
      UIManager.ShowUI(UIManager.UI_Config.Intimacy_BondingBook_UIBP, IntimacyConst.EShowMode.Display, crystalData.ownerUid)
    end
  end
end
function IntimacyUtils.GetBuildRelationCase()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  local intimacyList = logic_new_friend:GetIntimacyHasBuildSortV2()
  local bHasOtherRelation = false
  for i, v in ipairs(intimacyList) do
    if v.param == IntimacyConst.EIntimacyType.Bonding then
      return 4
    end
    if v.param == IntimacyConst.EIntimacyType.Lover then
      return 1
    end
    bHasOtherRelation = true
  end
  if bHasOtherRelation then
    return 2
  end
  return 3
end
function IntimacyUtils.ShouldShowMyBondingCrystal(friendUid, bIsPartner)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if myProfile then
    local soulmate_summary = myProfile.soulmate_summary
    if soulmate_summary and tonumber(soulmate_summary.mate_uid) == tonumber(friendUid) then
      local bSelected1, bSelected2 = false, false
      if bIsPartner then
        if soulmate_summary.partner_keepsake_show_switchs then
          bSelected1 = soulmate_summary.partner_keepsake_show_switchs[1] and true or false
          bSelected2 = soulmate_summary.partner_keepsake_show_switchs[2] and true or false
        end
      elseif soulmate_summary.relation_keepsake_show_switchs then
        bSelected1 = soulmate_summary.relation_keepsake_show_switchs[1] and true or false
        bSelected2 = soulmate_summary.relation_keepsake_show_switchs[2] and true or false
      end
      return true, {bSelected1, bSelected2}
    end
  end
end
function IntimacyUtils.ShouldShowOtherBondingCrystal(uid, bIsPartner)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    local soulmate_summary = profile.soulmate_summary
    if soulmate_summary then
      local bSelected1, bSelected2 = false, false
      if bIsPartner then
        if soulmate_summary.partner_keepsake_show_switchs then
          bSelected1 = soulmate_summary.partner_keepsake_show_switchs[1] and true or false
          bSelected2 = soulmate_summary.partner_keepsake_show_switchs[2] and true or false
        end
      elseif soulmate_summary.relation_keepsake_show_switchs then
        bSelected1 = soulmate_summary.relation_keepsake_show_switchs[1] and true or false
        bSelected2 = soulmate_summary.relation_keepsake_show_switchs[2] and true or false
      end
      return true, {bSelected1, bSelected2}
    end
  end
end
return IntimacyUtils