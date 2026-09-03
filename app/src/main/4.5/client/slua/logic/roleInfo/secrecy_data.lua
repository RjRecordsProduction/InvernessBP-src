local SecrecySystemData = {
  serData = {
    [0] = false,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true
  }
}
function SecrecySystemData.OnServerData(serverData)
  log_tree("  : serverData", serverData)
  if serverData and next(serverData) then
    for i, v in pairs(serverData) do
      SecrecySystemData.serData[i] = v
    end
  else
    SecrecySystemData.serData = {
      [0] = false,
      [1] = true,
      [2] = true,
      [3] = true,
      [4] = true,
      [5] = true,
      [6] = true
    }
  end
  log_tree("  :OnServerData SecrecySystemData.serData", SecrecySystemData.serData)
end
function SecrecySystemData.ChangeSwitch(index, value)
  log(bWriteLog and "  :SecrecySystemData.ChangeSwitch index" .. tostring(index))
  local TableUtil = require("common.table_util")
  local tempData = TableUtil.CopyTable(SecrecySystemData.serData)
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and index == 0 then
    tempData[index] = value
  else
    local newState = not tempData[index]
    tempData[index] = newState
    if index == 2 then
      tempData[6] = newState
    end
  end
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_set_intimacy_relation_visible_req(tempData)
end
function SecrecySystemData.GetOneSwitch(index)
  return SecrecySystemData.serData[index]
end
return SecrecySystemData