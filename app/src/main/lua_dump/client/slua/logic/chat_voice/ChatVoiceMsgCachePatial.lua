local ChatVoiceMsgCachePatial = {}
local EXTENSION = ".voice"
function ChatVoiceMsgCachePatial:InitVars()
  self.bInit = false
  self.voiceCacheEnabled = true
  self.voiceCacheMap = {}
  self.maxCacheSizeInKb = 10240
end
function ChatVoiceMsgCachePatial:InitVoiceCache()
  if not self.voiceCacheEnabled then
    return
  end
  if self.bInit then
    return
  end
  self.bInit = true
  self:loadCacheInfo()
end
function ChatVoiceMsgCachePatial:OnLogOut()
  self.voiceCacheMap = {}
  self.bInit = false
end
function ChatVoiceMsgCachePatial:PlayVoiceFile(file_id, msg_length, extra_para)
  if not self.voiceCacheEnabled then
    printf("ChatVoiceMsgCachePatial:PlayVoiceFile, voiceCacheEnabled is false")
    self:AddDownloadFile(file_id, msg_length, extra_para)
    return
  end
  if not self.voiceCacheMap[file_id] then
    printf("ChatVoiceMsgCachePatial:PlayVoiceFile cache missing. need download file_id:%s", file_id)
    self:AddDownloadFile(file_id, msg_length, extra_para)
    return
  end
  printf("ChatVoiceMsgCachePatial:PlayVoiceFile cache exist. file_id:%s", file_id)
  self:StopPlayRecordFile()
  self:PlayVoiceFileInternal(file_id, msg_length, extra_para)
end
function ChatVoiceMsgCachePatial:getVoiceCachePath()
  local dir = Client.ProjectSavedDir() .. "Voice/"
  return dir
end
function ChatVoiceMsgCachePatial:addToCache(file_id)
  self.voiceCacheMap[file_id] = true
end
function ChatVoiceMsgCachePatial:loadCacheInfo()
  self:CleanCacheIfNeeded()
  local dir = self:getVoiceCachePath()
  local FileUtil = require("client.common.file_util")
  local voiceFiles = FileUtil.FindFiles(dir, EXTENSION, false)
  self.voiceCacheMap = {}
  for _, filePath in pairs(voiceFiles) do
    local fileId = string.sub(filePath, 1, -7)
    self.voiceCacheMap[fileId] = true
  end
  printf("ChatVoiceMsgCachePatial:LoadCacheInfo voiceFiles length:%s", voiceFiles:Num())
end
function ChatVoiceMsgCachePatial:CleanCacheIfNeeded()
  if not self.voiceCacheEnabled then
    return
  end
  local SavedFileUtil = import("SavedFileUtil")
  local dir = self:getVoiceCachePath()
  local curSize = SavedFileUtil.GetDirSize(dir, true)
  local maxSize = self.maxCacheSizeInKb
  if curSize > maxSize then
    local bCleared = SavedFileUtil.CleanupDirectoryBySize(dir, maxSize, EXTENSION)
    if bCleared then
      local preSize = curSize
      curSize = SavedFileUtil.GetDirSize(dir, true)
      printf("ChatVoiceMsgCachePatial:CleanCacheIfNeeded cleare succes. preSize:%s, curSize:%s", preSize, curSize)
    else
      printf("ChatVoiceMsgCachePatial:CleanCacheIfNeeded cleare failed.")
    end
  else
    printf("ChatVoiceMsgCachePatial:CleanCacheIfNeeded curSize:%s < maxSize:%s", curSize, maxSize)
  end
end
return ChatVoiceMsgCachePatial