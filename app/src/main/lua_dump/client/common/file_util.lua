local file_util = {}
local SavedFileUtil = import("SavedFileUtil")
function file_util.FindFiles(targetDir, extension, recursive, asTable)
  extension = extension or ""
  if recursive == nil then
    recursive = false
  end
  local files = SavedFileUtil.FindFiles(targetDir, extension, recursive)
  if asTable then
    local fileList = {}
    for k, v in pairs(files) do
      fileList[k] = v
    end
    return fileList
  end
  return files
end
return file_util