local LogicSmartAssistant_SettingPartial = {}
local SettingSharedUtils = require("client.logic.NewSetting.SettingSharedUtils")
local LogicCustomAccessories = require("client.logic.setting.logic_setting_custom_accessiores")
local ROBOT_CD_CONFIG = {
  [1] = 604800,
  [2] = 864000,
  [3] = 864000,
  [4] = 864000,
  [5] = 1728000
}
if IsEditor then
  ROBOT_CD_CONFIG = {
    [1] = 10,
    [2] = 20,
    [3] = 20,
    [4] = 20,
    [5] = 30
  }
end
function LogicSmartAssistant_SettingPartial:DefineAndResetData()
  self.pickupPreviewHighlightIDs = nil
  self.pickupIsInPreviewMode = false
  self.attachmentPreviewHighlightData = nil
  self.attachmentIsInPreviewMode = false
  self.directPreviewSceneType = false
  self.cachedRecommendData = self.cachedRecommendData or {}
  self._lobbyRecommendTimerID = nil
end
function LogicSmartAssistant_SettingPartial:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SHOW_SETTING, self._OnSettingShow, self)
end
function LogicSmartAssistant_SettingPartial:_OnSettingShow(_, __, bShow)
  if not bShow then
    self.pickupIsInPreviewMode = false
    self.pickupPreviewHighlightIDs = nil
    self.attachmentIsInPreviewMode = false
    self.attachmentPreviewHighlightData = nil
    self.directPreviewSceneType = false
  end
end
function LogicSmartAssistant_SettingPartial:SetPickupPreviewState(isInPreview, highlightIDs)
  self.pickupIsInPreviewMode = isInPreview
  self.pickupPreviewHighlightIDs = highlightIDs
end
function LogicSmartAssistant_SettingPartial:GetPickupPreviewState()
  return self.pickupIsInPreviewMode, self.pickupPreviewHighlightIDs
end
function LogicSmartAssistant_SettingPartial:SetAttachmentPreviewState(isInPreview, highlightData)
  self.attachmentIsInPreviewMode = isInPreview
  self.attachmentPreviewHighlightData = highlightData
end
function LogicSmartAssistant_SettingPartial:GetAttachmentPreviewState()
  return self.attachmentIsInPreviewMode, self.attachmentPreviewHighlightData
end
function LogicSmartAssistant_SettingPartial:SetDirectPreviewSceneType(sceneType)
  self.directPreviewSceneType = sceneType or false
end
function LogicSmartAssistant_SettingPartial:ConsumeDirectPreviewSceneType()
  local sceneType = self.directPreviewSceneType
  self.directPreviewSceneType = false
  return sceneType
end
function LogicSmartAssistant_SettingPartial:GetCachedRecommendData(sceneType)
  return self.cachedRecommendData[sceneType]
end
function LogicSmartAssistant_SettingPartial:SetCachedRecommendData(sceneType, data)
  self.cachedRecommendData[sceneType] = data
end
function LogicSmartAssistant_SettingPartial:HasCachedRecommendData(sceneType)
  return self.cachedRecommendData[sceneType] ~= nil
end
function LogicSmartAssistant_SettingPartial:HasDiffWithLocalSettings(recommendData)
  if not recommendData then
    return false
  end
  local sceneType = recommendData.sceneType or 1
  if sceneType == 1 then
    return self:_HasDiffPickup(recommendData)
  elseif sceneType == 2 then
    local diffWeapon = self:_FindFirstDiffWeapon(recommendData)
    if diffWeapon then
      recommendData.recommendData = {
        ID = diffWeapon.ID,
        Acce = diffWeapon.Acce
      }
      return true
    end
    return false
  end
  return false
end
function LogicSmartAssistant_SettingPartial:_HasDiffPickup(recommendData)
  if not recommendData.items then
    return false
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  for _, item in ipairs(recommendData.items) do
    local currentValue = SettingSharedUtils.GetUserAutoLootCount(SettingConfig, item.id)
    if currentValue ~= item.recommendValue then
      return true
    end
  end
  return false
end
function LogicSmartAssistant_SettingPartial:_HasDiffAttachment(recommendData)
  return self:_FindFirstDiffWeapon(recommendData) ~= nil
end
function LogicSmartAssistant_SettingPartial:_FindFirstDiffWeapon(recommendData)
  local weapons = recommendData.weapons
  if not weapons or #weapons == 0 then
    return nil
  end
  for _, weapon in ipairs(weapons) do
    if weapon.ID and weapon.Acce and next(weapon.Acce) then
      if not LogicCustomAccessories.HasCurWeaponConfig(weapon.ID) then
        self:_EnsureWeaponExistsForLobby(weapon.ID)
        printf("LogicSmartAssistant_SettingPartial:_FindFirstDiffWeapon weapon:%d not in local, auto-add", weapon.ID)
        return weapon
      end
      for slotIndex, attachmentID in pairs(weapon.Acce) do
        local curID = LogicCustomAccessories.GetCurWeaponItemID(weapon.ID, slotIndex)
        if curID ~= attachmentID then
          printf("LogicSmartAssistant_SettingPartial:_FindFirstDiffWeapon diff found at weapon:%d index:%d", weapon.ID, weapon.index or 0)
          return weapon
        end
      end
    end
  end
  return nil
end
function LogicSmartAssistant_SettingPartial:_EnsureWeaponExistsForLobby(weaponID)
  if LogicCustomAccessories.HasCurWeaponConfig(weaponID) then
    return
  end
  local WeaponConfig = CDataTable.GetTableData("ArmoryConfig", weaponID)
  if not WeaponConfig then
    printf("LogicSmartAssistant_SettingPartial:_EnsureWeaponExistsForLobby weapon %s not found in ArmoryConfig, skip", weaponID)
    return
  end
  LogicCustomAccessories.AddWeaponAccessories(weaponID)
  LogicCustomAccessories.Save()
  LogicCustomAccessories.SetPlayer()
  printf("LogicSmartAssistant_SettingPartial:_EnsureWeaponExistsForLobby auto-add weapon %s", weaponID)
end
function LogicSmartAssistant_SettingPartial:IsUseTestData(sceneType)
  local USE_TEST_RECOMMEND_DATA = {
    [1] = false,
    [2] = false
  }
  return USE_TEST_RECOMMEND_DATA[sceneType] == true
end
function LogicSmartAssistant_SettingPartial:GetTestRawRecomItems(sceneType)
  if sceneType == 1 then
    return self:_GetTestPickupRawData()
  elseif sceneType == 2 then
    return self:_GetTestAttachmentRawData()
  end
  return nil
end
function LogicSmartAssistant_SettingPartial:_GetTestPickupRawData()
  return {
    [602001] = 4,
    [602002] = 7,
    [602003] = 3,
    [602004] = 5,
    [601001] = 1,
    [601002] = 8,
    [601003] = 6,
    [601004] = 2,
    [601005] = 7,
    [601006] = 1,
    [602123] = 8
  }
end
function LogicSmartAssistant_SettingPartial:_GetTestAttachmentRawData()
  return {
    [101001] = {
      index = 1,
      slot_recommend = {
        [3] = 204012
      }
    },
    [101002] = {
      index = 2,
      slot_recommend = {
        [3] = 204013
      }
    },
    [101003] = {
      index = 3,
      slot_recommend = {
        [2] = 202004,
        [3] = 204051
      }
    }
  }
end
local LOBBY_RECOMMEND_SCENE_TYPES = {1, 2}
function LogicSmartAssistant_SettingPartial:StartLobbyRecommendTimer()
  self:CancelLobbyRecommendTimer()
  local allCached = true
  for _, st in ipairs(LOBBY_RECOMMEND_SCENE_TYPES) do
    if not self:HasCachedRecommendData(st) then
      allCached = false
      break
    end
  end
  if allCached then
    return
  end
  self._lobbyRecommendTimerID = self:AddGameTimer(60, false, function()
    self._lobbyRecommendTimerID = nil
    self:TriggerLobbyRecommendRequest()
  end)
  printf("LogicSmartAssistant_SettingPartial:StartLobbyRecommendTimer timer started (60s)")
end
function LogicSmartAssistant_SettingPartial:CancelLobbyRecommendTimer()
  if self._lobbyRecommendTimerID then
    self:RemoveGameTimer(self._lobbyRecommendTimerID)
    self._lobbyRecommendTimerID = nil
    printf("LogicSmartAssistant_SettingPartial:CancelLobbyRecommendTimer timer cancelled")
  end
end
function LogicSmartAssistant_SettingPartial:TriggerLobbyRecommendRequest()
  for _, sceneType in ipairs(LOBBY_RECOMMEND_SCENE_TYPES) do
    self:_TriggerSingleSceneRequest(sceneType)
  end
end
function LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest(sceneType)
  if self:HasCachedRecommendData(sceneType) then
    printf("LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d already cached, skip", sceneType)
    return
  end
  printf("LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d sending request", sceneType)
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  SmartAssistantHandler.send_load_auto_equipment_req(sceneType):Then(function(err_code, respSceneType, recom_items)
    if err_code ~= 0 then
      printf("LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d err_code:%s", sceneType, err_code)
      return
    end
    local actualScene = respSceneType or sceneType
    local recommendData = self:GetCachedRecommendData(actualScene)
    if not recommendData then
      printf("[WARN] LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d no cached data after rsp", actualScene)
      return
    end
    printf("LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d cached", actualScene)
    local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
    local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
    if self:HasDiffWithLocalSettings(recommendData) then
      printf("LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d diff found", actualScene)
      local payload = {auto_equipment = actualScene}
      if actualScene == 2 then
        local itemId = recommendData.recommendData.ID
        local itemName = CDataTable.GetTableData("Item", itemId).ItemName
        payload.cur_weapon_name = itemName
      end
      SmartAssistantHandler.send_report_minitv_raw_event_req(MiniTVConst.RAW_EVENT_TYPE.SETTING_RECOM_TRIGGER, payload)
    else
      printf("LogicSmartAssistant_SettingPartial:_TriggerSingleSceneRequest scene:%d no diff, skip", actualScene)
    end
  end)
end
function LogicSmartAssistant_SettingPartial:BuildRecommendDataFromResponse(sceneType, recom_items)
  if sceneType == 2 then
    return self:_BuildAttachmentRecommendData(sceneType, recom_items)
  end
  return self:_BuildPickupRecommendData(sceneType, recom_items)
end
function LogicSmartAssistant_SettingPartial:_BuildPickupRecommendData(sceneType, recom_items)
  local items = {}
  if recom_items then
    for itemID, recommendValue in pairs(recom_items) do
      table.insert(items, {id = itemID, recommendValue = recommendValue})
    end
  end
  return {sceneType = sceneType, items = items}
end
function LogicSmartAssistant_SettingPartial:_BuildAttachmentRecommendData(sceneType, recom_items)
  if not recom_items then
    return {
      sceneType = sceneType,
      weapons = {},
      recommendData = nil
    }
  end
  local sortedWeapons = {}
  for weaponIDKey, data in pairs(recom_items) do
    local weaponID = tonumber(weaponIDKey)
    local acce = {}
    if type(data) ~= "table" then
      log_warning(bWriteLog and string.format("LogicSmartAssistant_SettingPartial:_BuildAttachmentRecommendData weapon %s data is not table (got %s), skip", tostring(weaponIDKey), type(data)))
    elseif data.slot_recommend then
      for slotIndex, attachmentID in pairs(data.slot_recommend) do
        local supportList = LogicCustomAccessories.GetWeaponSupportAccessiories(weaponID, slotIndex)
        if supportList then
          printf("LogicSmartAssistant_SettingPartial:_BuildAttachmentRecommendData weapon %s slot %s supportList: %s", weaponID, slotIndex, json.encode(supportList))
          local supported = false
          for _, itemID in ipairs(supportList) do
            if itemID == attachmentID then
              supported = true
              break
            end
          end
          if supported then
            acce[slotIndex] = attachmentID
          else
            printf("[WARN] LogicSmartAssistant_SettingPartial:_BuildAttachmentRecommendData attachment %s not in weapon %s slot %s support list, filtered", attachmentID, weaponID, slotIndex)
          end
        else
          printf("[WARN] LogicSmartAssistant_SettingPartial:_BuildAttachmentRecommendData weapon %s slot %s has no support list, filtered attachment %s", weaponID, slotIndex, attachmentID)
        end
      end
    end
    if next(acce) then
      table.insert(sortedWeapons, {
        ID = weaponID,
        Acce = acce,
        index = data.index or 0
      })
    else
      printf("[WARN] LogicSmartAssistant_SettingPartial:_BuildAttachmentRecommendData weapon %s all attachments filtered, skip", weaponID)
    end
  end
  table.sort(sortedWeapons, function(a, b)
    return a.index < b.index
  end)
  local firstWeapon = sortedWeapons[1]
  local recData
  if firstWeapon then
    recData = {
      ID = firstWeapon.ID,
      Acce = firstWeapon.Acce
    }
  end
  return {
    sceneType = sceneType,
    weapons = sortedWeapons,
    recommendData = recData
  }
end
function LogicSmartAssistant_SettingPartial:GetRobotCDConfig()
  return ROBOT_CD_CONFIG
end
function LogicSmartAssistant_SettingPartial:SaveRobotCDRecord(sceneType, state)
  if not sceneType or not state then
    printf("[WARN] LogicSmartAssistant_SettingPartial:SaveRobotCDRecord invalid params sceneType:%s state:%s", tostring(sceneType), tostring(state))
    return
  end
  local SAUtils = require("client.slua.logic.sa.SAUtils")
  local options = SAUtils.LoadSettingOptions()
  if not options.setting_robot_cd then
    options.setting_robot_cd = {}
  end
  options.setting_robot_cd[sceneType] = {
    lastCloseTs = os.time(),
    lastState = state
  }
  SAUtils.SaveSettingOptions(options)
  printf("LogicSmartAssistant_SettingPartial:SaveRobotCDRecord sceneType:%d state:%d ts:%d", sceneType, state, os.time())
end
function LogicSmartAssistant_SettingPartial:IsRobotInCD(sceneType)
  if not sceneType then
    return false, 0
  end
  local SAUtils = require("client.slua.logic.sa.SAUtils")
  local options = SAUtils.LoadSettingOptions()
  local cdData = options.setting_robot_cd and options.setting_robot_cd[sceneType]
  if not (cdData and cdData.lastCloseTs) or not cdData.lastState then
    return false, 0
  end
  local cdSeconds = ROBOT_CD_CONFIG[cdData.lastState] or 0
  if cdSeconds <= 0 then
    return false, 0
  end
  local elapsed = os.time() - cdData.lastCloseTs
  if cdSeconds > elapsed then
    local remain = cdSeconds - elapsed
    printf("LogicSmartAssistant_SettingPartial:IsRobotInCD sceneType:%s in CD, remain:%s s (state:%s cd:%s s)", sceneType, remain, cdData.lastState, cdSeconds)
    return true, remain
  end
  return false, 0
end
return LogicSmartAssistant_SettingPartial