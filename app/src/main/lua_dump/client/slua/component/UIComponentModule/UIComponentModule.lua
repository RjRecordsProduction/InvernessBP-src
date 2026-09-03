local UIComponentModule = {}
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
function UIComponentModule:DefineAndResetData()
  self.Config = require("client.slua.component.config.UIComponentConfig")
end
function UIComponentModule:InitWithParentComponent(parentWindow, config, widget, ...)
  if not assert(config ~= nil, "UIComponentModule:InitWithParentComponent config should not be nil") then
    return nil
  end
  log(bWriteLog and "UIComponentModule:InitWithParentComponent mouduleName:" .. config.LuaClassPath)
  local childClass = require(config.LuaClassPath)
  local childWindow = childClass(...)
  childWindow:InitWithParentWidget(parentWindow, widget)
  return childWindow
end
function UIComponentModule:InitWithoutParentComponent(config, widget, ...)
  if not assert(config ~= nil, "UIComponentModule:InitWithoutParentComponent config should not be nil") then
    return nil
  end
  log(bWriteLog and "UIComponentModule:InitWithoutParentComponent mouduleName:" .. config.LuaClassPath)
  local childClass = require(config.LuaClassPath)
  local subWindow = childClass(...)
  subWindow:InitWithWidget(widget)
  return subWindow
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, UIComponentModule)
return CModuleTemplate