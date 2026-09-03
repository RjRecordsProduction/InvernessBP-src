local CreativeModeAssetSeasonOnlyConfig = {
  SeasonOnlyAssetSet = {}
}
local delayPublish = {}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
if PublishRegionMacros.IsBLUEHOLE() then
  delayPublish = CDataTable.GetTable("UGCDelayPublishConfigBluehole")
else
  delayPublish = CDataTable.GetTable("UGCDelayPublishConfig")
end
for _, assetInfo in pairs(delayPublish) do
  local assetId = assetInfo.AssetId
  if assetId and assetInfo.IsIconTimerShown == 1 then
    CreativeModeAssetSeasonOnlyConfig.SeasonOnlyAssetSet[assetId] = true
  end
end
return CreativeModeAssetSeasonOnlyConfig