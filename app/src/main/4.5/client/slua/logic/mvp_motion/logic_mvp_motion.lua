local Mvp_Motion_System = {
  _Cur_Mvp_motion_item_id = -1,
  _Cur_Mvp_motion_ins_id = -1,
  _Delay_Net_Go = nil,
  _is_previewing = false,
  _enter_camara_id = 0,
  _Load_Asset_List = {},
  _character_id = 0,
  _call_back = nil,
  _is_playing = false
}
local subTabCurrentResIdCache = {
  [1] = {res_id = 0, ins_id = 0},
  [2] = {res_id = 0, ins_id = 0},
  [3] = {res_id = 0, ins_id = 0}
}
local subTabAllowSubtype = {
  {
    ENUM_ITEM_SUBTYPE.MVPAction,
    41001
  },
  {
    ENUM_ITEM_SUBTYPE.MVPIcon
  },
  {
    ENUM_ITEM_SUBTYPE.MVPPosition
  }
}
function Mvp_Motion_System:IsShowInSubTab(subTabIndex, subType)
  for i, v in pairs(subTabAllowSubtype[subTabIndex]) do
    if subType == v then
      return true
    end
  end
end
function Mvp_Motion_System:SubTypeToSubTabIndex(subType)
  for i, v in pairs(subTabAllowSubtype) do
    for j, k in pairs(v) do
      if k == subType then
        return i
      end
    end
  end
  log(bWriteLog and string.format("[lesterzy] Mvp_Motion_System:SubTypeToSubTabIndex subtype did not match any subTab"))
end
function Mvp_Motion_System:GetCache(subTabIndex)
  return subTabCurrentResIdCache[subTabIndex]
end
function Mvp_Motion_System:Get_Cur_MVP_Motion()
  local cache = subTabCurrentResIdCache[1]
  if cache and cache.res_id then
    return cache.res_id
  end
  log_error("Mvp_Motion_System:Get_Cur_MVP_Motion subTabCurrentResIdCache[1] Cache has no res_id")
end
function Mvp_Motion_System:Get_Cur_Motion_InsID(itemSubType)
  if not itemSubType then
    log_error("Mvp_Motion_System:Get_Cur_Motion_InsID itemSubType is nil")
    return nil
  end
  local subTabIndex = self:SubTypeToSubTabIndex(itemSubType)
  if not subTabIndex then
    log_error("Mvp_Motion_System:Get_Cur_Motion_InsID invalid itemSubType: " .. tostring(itemSubType))
    return nil
  end
  local cache = subTabCurrentResIdCache[subTabIndex]
  if cache and cache.ins_id then
    return cache.ins_id
  end
  log_error("Mvp_Motion_System:Get_Cur_Motion_InsID subTabCurrentResIdCache[itemSubType] Cache has no res_id")
end
function Mvp_Motion_System:Set_Cur_Motion_ResID_List(res_id_list)
  if type(res_id_list) ~= "table" then
    Mvp_Motion_System:Set_Cur_ResId_InsID(res_id_list)
    return
  end
  for _, res_id in ipairs(res_id_list) do
    Mvp_Motion_System:Set_Cur_ResId_InsID(res_id)
  end
end
function Mvp_Motion_System:Set_Cur_Motion_ResID(res_id)
  return Mvp_Motion_System:Set_Cur_ResId_InsID(res_id)
end
function Mvp_Motion_System:Set_Cur_ResId_InsID(resID)
  if resID == 0 then
    return nil
  end
  if resID then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemdata = wardrobe_data:GetHallDepotItemDataByResID(resID)
    if itemdata and itemdata.insID then
      log(bWriteLog and "itemdata.insID " .. tostring(itemdata.insID))
      local subTabIndex = self:SubTypeToSubTabIndex(itemdata.itemSubType)
      local cache = self:GetCache(subTabIndex)
      local oldInsID = cache.ins_id
      cache.res_id = resID
      cache.ins_id = itemdata.insID
      return oldInsID
    else
      log_error("itemdata incorrect")
    end
  else
    log_error("Mvp_Motion_System no item id")
  end
  return nil
end
function Mvp_Motion_System.Play_MVP_Motion(motion_item_id, startCallback, endCallback, character_id)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  if motion_item_id and not Mvp_Motion_System._is_playing then
    local motionCfg = CDataTable.GetTableData("MVPActionInfo", motion_item_id)
    if motionCfg and motionCfg.EmotionID and motionCfg.LevelName and motionCfg.LevelSequenceID then
      log(bWriteLog and "Mvp_Motion_System.Play_MVP_Motion motion_item_id\239\188\154" .. tostring(motion_item_id) .. "\239\188\140character_id\239\188\154" .. tostring(character_id))
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local list = {motion_item_id}
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, list)
      if state ~= PufferConst.ENUM_DownloadState.Done then
        endCallback()
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, list, nil, nil, {bAutoDownload = true, bFirst = true})
        ShowNotice(7421)
        return
      end
      Mvp_Motion_System._ShowLoadingMask()
      log(bWriteLog and "Mvp_Motion_System.Play_MVP_Motion [TEST] 1s delay finished, loading mask should be visible")
      local wrappedStartCallback = function()
        log(bWriteLog and "Mvp_Motion_System.Play_MVP_Motion wrappedStartCallback - close loading mask")
        Mvp_Motion_System._HideLoadingMask()
        if startCallback then
          startCallback()
        end
      end
      logic_achievement_float_tip.BlockPopTip()
      local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
      ui_show_queue_manager.SetIsBlock(true, true)
      Mvp_Motion_System._is_playing = true
      Mvp_Motion_System._Cur_Mvp_      Mvp_Motion_System._end_call_back = endCallback
      Mvp_Motion_System._start_call_back = wrappedStartCallback
      Mvp_Motion_System._      LobbySceneManager.LoadStreamLevel(true, motionCfg.LevelName)
      Mvp_Motion_System.ShowMvpAction(Mvp_Motion_System._Cur_Mvp_motion_item_id, Mvp_Motion_System._character_id)
    end
    UIManager.ShowUI(UIManager.UI_Config.ui_mvp_motion, motion_item_id)
  end
end
function Mvp_Motion_System.MVP_End_Call_Back()
  local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  log(bWriteLog and "Mvp_Motion_System.MVP_End_Call_Back ")
  Mvp_Motion_System._HideLoadingMask()
  NewCharacterAvatarSystem:DestroyMvpAvatar()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.ui_mvp_motion)
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(Mvp_Motion_System._enter_camara_id)
  end
  Mvp_Motion_System._is_playing = false
  Mvp_Motion_System._is_previewing = false
  Mvp_Motion_System._Load_Asset_List = nil
  Mvp_Motion_System._character_id = 0
  if Mvp_Motion_System._end_call_back then
    Mvp_Motion_System._end_call_back()
    log(bWriteLog and "Mvp_Motion_System.MVP_End_Call_Back _end_call_back")
  end
  Mvp_Motion_System._end_call_back = nil
  logic_achievement_float_tip.UnblockPopTip()
  local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
  ui_show_queue_manager.SetIsBlock(false)
end
function Mvp_Motion_System.ShowMvpAction(motion_item_id, character_id)
  local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
  local motionCfg = CDataTable.GetTableData("MVPActionInfo", motion_item_id)
  if motionCfg and motionCfg.EmotionID and motionCfg.LevelName and motionCfg.LevelSequenceID then
    log(bWriteLog and "Mvp_Motion_System.ShowMvpAction ShowMvpAction motion_item_id\239\188\154" .. tostring(motion_item_id) .. ", character_id\239\188\154" .. tostring(character_id))
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:LevelSequence_SetCallbacks(Mvp_Motion_System._start_call_back, Mvp_Motion_System.MVP_End_Call_Back)
    NewCharacterAvatarSystem:ShowMvpAvatar(motion_item_id, character_id)
    LobbySceneManager.LoadLightLevel("Billing_interface_Light")
    Mvp_Motion_System._is_previewing = true
    Mvp_Motion_System._enter_camara_id = Lobby_camera_manager_module.currentCameraID
  end
end
function Mvp_Motion_System.Stop_Mvp_Motion(motion_item_id)
  local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
  if motion_item_id then
    local montionCfg = CDataTable.GetTableData("MVPActionInfo", motion_item_id)
    if montionCfg and montionCfg.LevelName then
      local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
      LobbySceneModule:UnloadStreamLevel(montionCfg.LevelName, true)
      NewCharacterAvatarSystem:StopMVPAction()
    end
  end
end
function Mvp_Motion_System.Event_Stop_Mvp_Motion()
  log(bWriteLog and "Event_Stop_Mvp_Motion")
  if Mvp_Motion_System._is_previewing then
    Mvp_Motion_System.Stop_Mvp_Motion(Mvp_Motion_System:Get_Cur_MVP_Motion())
  end
end
function Mvp_Motion_System.Stop_Mvp_Motion_Without_End_Call_Back()
  if Mvp_Motion_System._is_previewing then
    log(bWriteLog and string.format("Stop_Mvp_Motion_Without_End_Call_Back."))
    Mvp_Motion_System.Stop_Mvp_Motion(Mvp_Motion_System:Get_Cur_MVP_Motion())
  end
end
function Mvp_Motion_System._ShowLoadingMask()
  log(bWriteLog and "Mvp_Motion_System._ShowLoadingMask")
  if UIManager.IsUIShow(UIManager.UI_Config.mvp_loading_mask) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.mvp_loading_mask)
end
function Mvp_Motion_System._HideLoadingMask()
  log(bWriteLog and "Mvp_Motion_System._HideLoadingMask")
  if UIManager.IsUIShow(UIManager.UI_Config.mvp_loading_mask) then
    UIManager.CloseUI(UIManager.UI_Config.mvp_loading_mask)
  end
end
return Mvp_Motion_System