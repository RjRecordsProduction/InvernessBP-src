local texture_cache_mgr = {}
function texture_cache_mgr:OnInitialize()
  texture_cache_mgr.__super.OnInitialize(self)
  self:InitData()
end
function texture_cache_mgr:Destory()
  log(bWriteLog and "texture_cache_mgr Destory")
  self:ClearData()
end
function texture_cache_mgr:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "texture_cache_mgr OnPreSwitchGameStatus")
  self:ClearData()
end
function texture_cache_mgr:OnLogOut()
  log(bWriteLog and "texture_cache_mgr OnLogOut")
  self:ClearData()
end
function texture_cache_mgr:GetTextureCache(path, ifAddRef)
  if not path or path == "" then
    log_error(bWriteLog and "texture_cache_mgr:GetTextureCache path is nil")
    return nil
  end
  self.getCacheNum = self.getCacheNum + 1
  local texture
  if not self.strongTextureCache then
    self.strongTextureCache = {}
  end
  texture = self.strongTextureCache[path]
  if slua.isValid(texture) then
    self.cacheHitNum = self.cacheHitNum + 1
    return texture
  end
  if not self.weakTextureCache then
    self.weakTextureCache = setmetatable({}, {__mode = "v"})
  end
  texture = self.weakTextureCache[path]
  if slua.isValid(texture) then
    self.cacheHitNum = self.cacheHitNum + 1
    if ifAddRef then
      self:SetTextureCache(texture, path, true)
    end
    return texture
  end
  self.strongTextureCache[path] = nil
  self.weakTextureCache[path] = nil
  return nil
end
function texture_cache_mgr:SetTextureCache(texture, path, ifAddRef)
  if not path or path == "" then
    log_error(bWriteLog and "texture_cache_mgr:SetTextureCache path is nil")
    return
  end
  if not slua.isValid(texture) then
    log_error(bWriteLog and "texture_cache_mgr:SetTextureCache texture is invalid")
    return
  end
  if ifAddRef then
    if not self.strongTextureCache then
      self.strongTextureCache = {}
    end
    slua.addRef(texture)
    self.strongTextureCache[path] = texture
  else
    if not self.weakTextureCache then
      self.weakTextureCache = setmetatable({}, {__mode = "v"})
    end
    self.weakTextureCache[path] = texture
  end
end
function texture_cache_mgr:RemoveTextureCache(path)
  if not path or path == "" then
    log_error(bWriteLog and "texture_cache_mgr:RemoveTextureCache path is nil")
    return
  end
  log(bWriteLog and "texture_cache_mgr:RemoveTextureCache, path:" .. tostring(path))
  if self.strongTextureCache and self.strongTextureCache[path] then
    local texture = self.strongTextureCache[path]
    if slua.isValid(texture) then
      slua.removeRef(texture)
    end
    self.strongTextureCache[path] = nil
  end
  if self.weakTextureCache and self.weakTextureCache[path] then
    self.weakTextureCache[path] = nil
  end
end
function texture_cache_mgr:RemoveStrongTextureCache(path)
  if not path or path == "" then
    log_error(bWriteLog and "texture_cache_mgr:RemoveStrongTextureCache path is nil")
    return
  end
  log(bWriteLog and "texture_cache_mgr:RemoveStrongTextureCache, path:" .. tostring(path))
  if not self.strongTextureCache or not self.strongTextureCache[path] then
    log(bWriteLog and "texture_cache_mgr:RemoveStrongTextureCache no texture")
    return
  end
  local texture = self.strongTextureCache[path]
  if slua.isValid(texture) then
    slua.removeRef(texture)
  end
  self.strongTextureCache[path] = nil
end
function texture_cache_mgr:RemoveWeakTextureCache(path)
  if not path or path == "" then
    log_error(bWriteLog and "texture_cache_mgr:RemoveWeakTextureCache path is nil")
    return
  end
  log(bWriteLog and "texture_cache_mgr:RemoveWeakTextureCache, path:" .. tostring(path))
  if not self.weakTextureCache then
    log(bWriteLog and "texture_cache_mgr:RemoveWeakTextureCache no texture")
    return
  end
  self.weakTextureCache[path] = nil
end
function texture_cache_mgr:RemoveAllTextureCache()
  self:ClearTextureCache()
end
function texture_cache_mgr:InitData()
  log(bWriteLog and "texture_cache_mgr:InitData")
  self.strongTextureCache = nil
  self.weakTextureCache = nil
  self.cacheHitNum = 0
  self.getCacheNum = 0
  self.debugSwitch = false
end
function texture_cache_mgr:ClearData()
  log(bWriteLog and "texture_cache_mgr:ClearData")
  self:ClearTextureCache()
end
function texture_cache_mgr:ClearTextureCache()
  log(bWriteLog and "texture_cache_mgr:ClearTextureCache")
  self.weakTextureCache = nil
  if type(self.strongTextureCache) == "table" then
    for _, cacheTexture in pairs(self.strongTextureCache) do
      if cacheTexture and slua.isValid(cacheTexture) then
        slua.removeRef(cacheTexture)
      end
    end
  end
  self.strongTextureCache = nil
  if self.debugSwitch then
    log(bWriteLog and "texture_cache_mgr:ClearTextureCache getCacheNum:" .. tostring(self.getCacheNum) .. " cacheHitNum:" .. tostring(self.cacheHitNum))
  end
end
function texture_cache_mgr:SetSwitchState(bIfOpen)
  self.debugSwitch = bIfOpen or false
  log(bWriteLog and "texture_cache_mgr:SetSwitchState swicth is " .. tostring(bIfOpen))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTextureCache = class(CModuleBase, nil, texture_cache_mgr)
return CTextureCache