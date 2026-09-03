local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
local config = {
  PrivacyPolicy_Title = 37280,
  bUseDiffLanguage = true,
  defaultLanguage = LanguageMacros.EN,
  PrivacyPolicy_Global_Version = 29,
  PrivacyPolicy_jp_Version = 8,
  PrivacyPolicy_kr_Version = 19,
  japanContent = "client.slua.config.longs.privacy_agreement.jk_content_ja",
  koreaContent = "client.slua.config.longs.privacy_agreement.jk_content_ko",
  PrivacyPolicy_VNG_Version = 5,
  vngContent = "client.slua.config.longs.privacy_agreement.vng_content",
  PrivacyPolicy_TW_Version = 4,
  twContent = "client.slua.config.longs.privacy_agreement.tw_content",
  PrivacyPolicy_BH_Version = 14,
  bhContent = "client.slua.config.longs.privacy_agreement.bh_content"
}
return config