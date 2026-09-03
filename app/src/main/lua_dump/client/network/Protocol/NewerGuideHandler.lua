local NetManager = require("client.network.comm.NetManager")
local NewerGuideHandler = {}
function NewerGuideHandler.OnLogin()
  NewerGuideHandler.send_sync_newer_guide_data_req(1, 0, nil)
end
function NewerGuideHandler.send_sync_newer_guide_data_req(type, add_value, params)
  NetManager.SendPkg(549094984, type, add_value, params)
end
function NewerGuideHandler.on_sync_newer_guide_data_res(errcode, newer_data, test_group)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "NewerGuideHandler.on_sync_newer_guide_data_res errorcode = " .. tostring(errcode))
  if errcode == 0 then
    LogicNewbie.newbieTotalGameCnt = newer_data
    if newer_data then
      log(bWriteLog and "NewerGuideHandler.on_sync_newer_guide_data_res newbieTotalGameCnt = " .. tostring(newer_data))
    end
    LogicNewbie.abcTestGroup = test_group
    if test_group then
      log(bWriteLog and "NewerGuideHandler.on_sync_newer_guide_data_res abcTestGroup = " .. tostring(test_group))
    end
    if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(10033) then
      local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
      NewFaceSlapSystem:SkipAllSlap()
      UIManager.AndroidBackToLobby()
      NewFaceSlapSystem:ReleaseBlockSlap()
    end
    if UIManager.IsAndroidStackEmpty() then
      EventSystem:postEvent(EVENTTYPE_NEWBIE, EVENTID_NEWBIE_SYNC_DATA)
      if LogicNewbie.IsNewbie() then
        local newbieState = LogicNewbie.GetNewbieGuideState(20002)
        if newbieState == ENUM_NewbieState.Force then
          UIManager.ShowUI(UIManager.UI_Config.newbie_mode_select_entry, true)
        elseif newbieState == ENUM_NewbieState.Week then
          UIManager.ShowUI(UIManager.UI_Config.newbie_mode_select_entry, false)
        end
      end
    end
  end
end
function NewerGuideHandler.send_set_fresher_type_req(BP_Newer_Guide_Selected_Type)
  NetManager.SendPkg(838225132, BP_Newer_Guide_Selected_Type)
end
return NewerGuideHandler