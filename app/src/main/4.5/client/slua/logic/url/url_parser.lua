local url_parser = {}
function url_parser:OnInitialize()
  url_parser.__super.OnInitialize(self)
  self.URLParamsCache = {}
end
function url_parser:OnPreSwitchGameStatus(_, next)
  log(bWriteLog and "  : url_parser clear before " .. tostring(next))
  self.URLParamsCache = {}
end
function url_parser:ParseURLParams(s)
  if self.URLParamsCache[s] then
    return self.URLParamsCache[s]
  end
  local StringUtil = require("common.string_util")
  local params = {}
  for k, v in string.gmatch(s, "([^&=?]+)=([^&=?]+)") do
    params[k] = StringUtil.DecodeURI(v)
  end
  self.URLParamsCache[s] = params
  return params
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUrlParser = class(CModuleBase, nil, url_parser)
return CLogicUrlParser