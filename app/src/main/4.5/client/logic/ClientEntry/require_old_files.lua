local RequireAllLuaFiles = function()
  require("client.logic.gm.RequireBlackList")
  if Client.IsDevelopment() then
    if Client.IsEditor() then
      RequireBlackList("blacklist.editor.fast_load_tool_in_PIE.fast_load_tool_in_PIE")
    end
    RequireBlackList("blacklist.editor.debugger.logic_hot_update")
    local CPlusPlusAPITimetracer = RequireBlackList("blacklist.editor.runtime_check.CPlusPlusAPITimetracer")
    if CPlusPlusAPITimetracer then
      CPlusPlusAPITimetracer.Init()
    end
    local LuaAPITimeTracer = RequireBlackList("blacklist.editor.runtime_check.LuaAPITimeTracer")
    if LuaAPITimeTracer then
      LuaAPITimeTracer.Init()
    end
    RequireBlackList("blacklist.onlydev.statis_widget")
  end
  if Client.IsShipping() == false then
    RequireBlackList("blacklist.memory_tool.MemoryReferenceInfo")
    RequireBlackList("blacklist.memory_tool.memory_util")
  end
  local old_file_config = require("client.logic.ClientEntry.old_file_config")
  local utility = require("common.utility")
  for _, moduleName in ipairs(old_file_config) do
    xpcall(require, utility.ErrorMessageHandler, moduleName)
  end
end
RequireAllLuaFiles()