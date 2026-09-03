local LogicLoadTexture = {}
function LogicLoadTexture.LoadTextureOrSprite(path)
  if not path or path == "" or type(path) ~= "string" then
    log_warning(bWriteLog and "LogicLoadTexture.LoadTextureOrSprite path is invalid")
    return nil
  end
  local texture_cache_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.texture_cache_mgr)
  local textureOrSprite = texture_cache_mgr:GetTextureCache(path)
  if slua.isValid(textureOrSprite) then
    return textureOrSprite
  end
  local asset_util = require("common.asset_util")
  textureOrSprite = asset_util.GetAssetSync(path)
  textureOrSprite = textureOrSprite or asset_util.GetSavedTextureSync(path)
  if slua.isValid(textureOrSprite) then
    texture_cache_mgr:SetTextureCache(textureOrSprite, path, false)
  else
    log(bWriteLog and "LogicLoadTexture.LoadTextureOrSprite faild")
  end
  return textureOrSprite
end
return LogicLoadTexture