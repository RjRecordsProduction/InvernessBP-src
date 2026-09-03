local EmulatorSystem = {
  timer = 0,
  timeLength = 5,
  retryCount = 3,
  waitWhiteListForShowTip = false,
  emulatorCheckData = nil,
  white_simulator_list = nil,
  is_first_lobby = true,
  is_first_check = true
}
EmulatorSystem.EmulatorTestMark = false
function EmulatorSystem.Tick(DeltaTime)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.bIsInitLogin then
    if EmulatorSystem.retryCount == 0 then
      return
    end
    EmulatorSystem.timer = EmulatorSystem.timer + DeltaTime
    if EmulatorSystem.timer >= EmulatorSystem.timeLength then
      EmulatorSystem.timer = 0
      local emulatorName = Client.GetEmulatorName()
      if EmulatorSystem.EmulatorTestMark then
        emulatorName = "test"
      end
      local isEmulator = EmulatorSystem.IsEmulator(emulatorName)
      log(bWriteLog and "EmulatorSystem.Tick() isEmulator = " .. tostring(isEmulator))
      DataMgr.roleData.      if isEmulator == true then
        EmulatorSystem.OnEmulatorStatusChange(isEmulator, emulatorName)
      else
        local deviceType = EmulatorSystem.CheckBLEDeviceType()
        if deviceType ~= 0 then
          log(bWriteLog and "EmulatorSystem.CheckBLEDeviceType() deviceType = " .. tostring(deviceType))
          local EmulatorHandler = require("client.network.Protocol.EmulatorHandler")
          EmulatorHandler.send_report_simulator_check(deviceType, emulatorName)
        elseif EmulatorSystem.retryCount then
          EmulatorSystem.retryCount = EmulatorSystem.retryCount - 1
          if EmulatorSystem.retryCount == 0 then
            EmulatorSystem.timeLength = 180
          end
        end
      end
    end
  end
end
function EmulatorSystem.BeEmulator()
  EmulatorSystem.OnEmulatorStatusChange(true, "test")
end
function EmulatorSystem.OnEmulatorStatusChange(isEmulator, emulatorName)
  log(bWriteLog and "OnEmulatorStatusChange isEmulator = " .. tostring(isEmulator) .. " emulatorName = " .. tostring(emulatorName))
  if isEmulator == true then
    log(bWriteLog and "report_simulator_check simulatorValue = 1")
    local EmulatorHandler = require("client.network.Protocol.EmulatorHandler")
    EmulatorHandler.send_report_simulator_check(1, emulatorName)
  end
end
function EmulatorSystem.notify_kick_out_game(reason)
  log(bWriteLog and "notify_kick_out_game reason = " .. tostring(reason))
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = ""
  if "simulator_not_allow_in_mobile" == reason then
    text = LocUtil.GetLocalizeResStr(101721)
  end
  local curStatus = GameStatus.GetGameStatus()
  if curStatus == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text, EmulatorSystem.ReturnToLobby)
  end
end
function EmulatorSystem.CheckBLEDeviceType()
  return 0
end
function EmulatorSystem.get_emulators_cfg_req()
  log(bWriteLog and "get_emulators_cfg_req")
  local EmulatorHandler = require("client.network.Protocol.EmulatorHandler")
  EmulatorHandler.send_get_emulators_cfg_req()
end
function EmulatorSystem.get_emulators_cfg_res(emulators_check_table, white_simulator_list)
  log(bWriteLog and "get_emulators_cfg_res")
  EmulatorSystem.  EmulatorSystem.ConvertEmulatorCheckData(emulators_check_table)
  EmulatorSystem.CheckSpecialEmulator()
  if EmulatorSystem.waitWhiteListForShowTip then
    EmulatorSystem.waitWhiteListForShowTip = false
    log(bWriteLog and "got white_simulator_list, waitWhiteListForShowTip is true")
    EmulatorSystem.CheckEmulatorTip()
  end
end
function EmulatorSystem.ConvertEmulatorCheckData(emulators_check_table)
  EmulatorSystem.emulatorCheckData = {}
  if emulators_check_table ~= nil then
    for k, v in pairs(emulators_check_table) do
      local emulator = {}
      emulator.name = tostring(k)
      emulator.paths = v
      table.insert(EmulatorSystem.emulatorCheckData, emulator)
    end
  end
end
function EmulatorSystem.CheckSpecialEmulator()
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local emulatorName = Client.GetEmulatorName()
  local isEmulator = EmulatorSystem.IsEmulator(emulatorName)
  local emulator_scanner = require("client.logic.login.emulator_scanner")
  if isEmulator == false then
    local findEmulatorRet, findEmulatorName = emulator_scanner.find_emulator()
    if findEmulatorRet == true then
      isEmulator = true
      emulatorName = tostring(findEmulatorName)
      log(bWriteLog and "emulator_scanner.find_emulator return true, and emulator name is " .. tostring(findEmulatorName))
    else
      log(bWriteLog and "emulator_scanner.find_emulator return false")
      local isSpecialEmulator = EmulatorSystem.IsSpecialEmulator(tostring(DeviceOSInfo.InfoList.SystemHardware))
      log(bWriteLog and "isSpecialEmulator = " .. tostring(isSpecialEmulator))
      if isSpecialEmulator == true then
        isEmulator = true
        emulatorName = tostring(DeviceOSInfo.InfoList.SystemHardware)
      end
    end
  end
  if isEmulator == true then
    log(bWriteLog and "EmulatorSystem.CheckSpecialEmulator report_simulator_check simulatorValue = 1")
    if DataMgr ~= nil and DataMgr.roleData ~= nil then
      DataMgr.roleData.isEmulator = true
    end
    log(bWriteLog and "report_simulator_check 1")
    local EmulatorHandler = require("client.network.Protocol.EmulatorHandler")
    EmulatorHandler.send_report_simulator_check(1, emulatorName)
  end
end
function EmulatorSystem.GetEmulatorName()
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local emulatorName = Client.GetEmulatorName()
  local isEmulator = EmulatorSystem.IsEmulator(emulatorName)
  if isEmulator == true then
    return emulatorName
  end
  local emulator_scanner = require("client.logic.login.emulator_scanner")
  local findEmulatorRet, findEmulatorName = emulator_scanner.find_emulator()
  if findEmulatorRet == true then
    isEmulator = true
    return findEmulatorName
  else
    local isSpecialEmulator = EmulatorSystem.IsSpecialEmulator(tostring(DeviceOSInfo.InfoList.SystemHardware))
    log(bWriteLog and "isSpecialEmulator = " .. tostring(isSpecialEmulator))
    if isSpecialEmulator == true then
      isEmulator = true
      return tostring(DeviceOSInfo.InfoList.SystemHardware)
    end
  end
  return "NoEmulator"
end
function EmulatorSystem.IsX86Phone()
  local emulatorName = Client.GetEmulatorName()
  log(bWriteLog and "EmulatorSystem.IsX86Phone emulatorName = " .. tostring(emulatorName) .. " || isX86 = " .. tostring(emulatorName == "RX86"))
  return emulatorName == "RX86"
end
function EmulatorSystem.IsSpecialEmulator(myDevice)
  local GlobalSpecialEmulatorList = require("client.logic.login.special_emulator_define")
  if GlobalSpecialEmulatorList ~= nil then
    for k, v in pairs(GlobalSpecialEmulatorList) do
      if tostring(myDevice) == tostring(v) then
        log(bWriteLog and "LoginSystem.IsSpecialEmulator() = true, myDevice = " .. tostring(myDevice))
        return true
      end
    end
  else
    log(bWriteLog and "GlobalSpecialEmulatorList is nil")
  end
  return false
end
function EmulatorSystem.ReturnToLobby()
  log(bWriteLog and "EmulatorSystem.ReturnToLobby")
  LobbySystem.ReturnToLobby()
end
function EmulatorSystem.IsEmulator(emulatorName)
  return emulatorName ~= "NoEmulator"
end
function EmulatorSystem.is_blue_simulator(simulator_name)
  local isEmulator = EmulatorSystem.IsEmulator(simulator_name)
  if isEmulator then
    if EmulatorSystem.white_simulator_list then
      if not simulator_name then
        return false
      end
      for key, _ in pairs(EmulatorSystem.white_simulator_list) do
        local pos = string.find(simulator_name, key, 1, true)
        if pos then
          return true
        end
      end
      return false
    else
      log(bWriteLog and "white_simulator_list is nil")
      return true
    end
  else
    return false
  end
end
function EmulatorSystem.CheckEmulatorTip()
  log(bWriteLog and "CheckEmulatorTip")
  if EmulatorSystem.white_simulator_list then
    if EmulatorSystem.is_first_lobby then
      local emulatorName = EmulatorSystem.GetEmulatorName()
      local isEmulator = EmulatorSystem.IsEmulator(emulatorName) and EmulatorSystem.IsX86Phone() == false
      local tips = ""
      local title = DataMgr.GetMsgByID(101001)
      if isEmulator then
        local isBlueEmulator = EmulatorSystem.is_blue_simulator(emulatorName)
        if isBlueEmulator then
          tips = DataMgr.GetMsgByID(110137)
        else
          tips = DataMgr.GetMsgByID(110423)
        end
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(1, title, tips)
        EmulatorSystem.is_first_lobby = false
      end
    end
  else
    log(bWriteLog and "CheckEmulatorTip, but white_simulator_list is nil")
    EmulatorSystem.waitWhiteListForShowTip = true
  end
end
function EmulatorSystem.FirstCheckEmulatorTip()
  if EmulatorSystem.is_first_check then
    local isEmulator = Client.IsEmulator() and not EmulatorSystem.IsX86Phone()
    local isEmulatorNoChromoBook = Client.IsEmulatorWhenInit()
    local isX86Phone = EmulatorSystem.IsX86Phone()
    log(bWriteLog and string.format("EmulatorSystem.FirstCheckEmulatorTip. isEmulator=%s,isEmulatorNoChromoBook=%s,isX86Phone=%s", tostring(isEmulator), tostring(isEmulatorNoChromoBook), tostring(isX86Phone)))
    if isEmulator and not isX86Phone then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local title = LocUtil.GetLocalizeResStr(101001)
      local tips
      if isEmulatorNoChromoBook then
        tips = LocUtil.GetLocalizeResStr(4051)
      else
        tips = LocUtil.GetLocalizeResStr(6055)
      end
      CommonMsgBoxMgr.Show(1, title, tips)
      EmulatorSystem.is_first_check = false
    end
  end
end
return EmulatorSystem