local PufferShaderManager = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function PufferShaderManager:DefineAndResetData()
  self.ShaderPaks = {}
  self.MapToShaders = {}
end
function PufferShaderManager:InitShaderPaks()
  local info = PufferDownloader.GetPufferFileListJson()
  if not (info and next(info)) or not info.MapAdditionalShaderInfo then
    return
  end
  for mapPakName, v in pairs(info.MapAdditionalShaderInfo) do
    self.MapToShaders[mapPakName] = {}
    for _, shaderName in pairs(v) do
      table.insert(self.MapToShaders[mapPakName], shaderName)
      self.ShaderPaks[shaderName] = {}
      if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. shaderName) then
        self.ShaderPaks[shaderName].state = PufferConst.ENUM_DownloadState.Done
      else
        self.ShaderPaks[shaderName].state = PufferConst.ENUM_DownloadState.Not
      end
    end
  end
end
function PufferShaderManager:IsShader(shaderName)
  if self.ShaderPaks[shaderName] then
    return true
  end
  return false
end
function PufferShaderManager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends)
  local result = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for _, v in pairs(keyList) do
    local state = self:GetStateByMapKey(v)
    result = PufferManager.GetMixDownloadState(result, state)
  end
  return result
end
function PufferShaderManager:GetStateByMapKey(mapKey)
  local state = PufferConst.ENUM_DownloadState.Done
  for i, v in pairs(self.MapToShaders) do
    if string.find(i, mapKey) then
      for _, shaderName in pairs(v) do
        local tempState = self:GetState(shaderName)
        if tempState == PufferConst.ENUM_DownloadState.Download then
          return PufferConst.ENUM_DownloadState.Download
        end
        if tempState ~= PufferConst.ENUM_DownloadState.Done then
          state = tempState
        end
      end
    end
  end
  return state
end
function PufferShaderManager:GetState(shaderName)
  if not self.ShaderPaks[shaderName] then
    return PufferConst.ENUM_DownloadState.Done
  end
  return self.ShaderPaks[shaderName].state
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferShaderManager = class(CModuleBase, nil, PufferShaderManager)
return CPufferShaderManager