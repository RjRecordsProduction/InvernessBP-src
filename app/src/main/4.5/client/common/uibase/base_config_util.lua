local base_config_util = {}
local whitelist = require("client.slua.config.cdo_ui_whitelist")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local StringUtil = require("common.string_util")
function base_config_util.EnableCDNCompress(config)
  return config and config.enableCDNCompress
end
function base_config_util.IsSingleton(config)
  return config and config.isSingleton ~= false
end
function base_config_util.IsMainUI(config)
  return config and config.isMainUI ~= false
end
function base_config_util.IsBanAndroidBack(config)
  return config and config.AndroidBackType == EAndroidBackType.Ban
end
function base_config_util.IsSkipAndroidBack(config)
  return config and config.AndroidBackType == EAndroidBackType.Skip
end
function base_config_util.IsCloseOnHide(config)
  return config and config.closeOnHide ~= false
end
function base_config_util.IsForceLayoutPrepass(config)
  return config and config.Prepass == true
end
function base_config_util.IsCloseOnSwitch(config)
  return config and config.closeOnSwitch ~= false
end
function base_config_util.GetKeyName(config)
  return config and config.keyName or ""
end
function base_config_util.IsUniquePath(config)
  if not config or not config.path then
    return false
  end
  if whitelist[config.path] then
    return true
  end
  return false
end
function base_config_util.GetClassName(classPath)
  if not classPath or classPath == "" then
    return ""
  end
  local pathArray = StringUtil.Split(classPath, ".")
  local totalLen = #pathArray
  return pathArray[totalLen] or ""
end
return base_config_util