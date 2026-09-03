local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
local config = {
  PrivacyPolicy_Title = 37280,
  bUseDiffLanguage = true,
  defaultLanguage = LanguageMacros.EN,
  PrivacyPolicy_Global_Version = 28,
  globalContent = {
    [LanguageMacros.AR] = "client.slua.config.longs.privacy_agreement.global_content_ar",
    [LanguageMacros.DE] = "client.slua.config.longs.privacy_agreement.global_content_de",
    [LanguageMacros.EN] = "client.slua.config.longs.privacy_agreement.global_content_en",
    [LanguageMacros.ES] = "client.slua.config.longs.privacy_agreement.global_content_es",
    [LanguageMacros.FR] = "client.slua.config.longs.privacy_agreement.global_content_fr",
    [LanguageMacros.HK] = "client.slua.config.longs.privacy_agreement.global_content_hk",
    [LanguageMacros.ID] = "client.slua.config.longs.privacy_agreement.global_content_id",
    [LanguageMacros.MS] = "client.slua.config.longs.privacy_agreement.global_content_ms",
    [LanguageMacros.NL] = "client.slua.config.longs.privacy_agreement.global_content_nl",
    [LanguageMacros.PT] = "client.slua.config.longs.privacy_agreement.global_content_pt",
    [LanguageMacros.RU] = "client.slua.config.longs.privacy_agreement.global_content_ru",
    [LanguageMacros.TH] = "client.slua.config.longs.privacy_agreement.global_content_th",
    [LanguageMacros.TR] = "client.slua.config.longs.privacy_agreement.global_content_tr",
    [LanguageMacros.TW] = "client.slua.config.longs.privacy_agreement.global_content_tw"
  },
  PrivacyPolicy_jp_Version = 8,
  PrivacyPolicy_kr_Version = 19,
  japanContent = "client.slua.config.longs.privacy_agreement.jk_content_ja",
  koreaContent = "client.slua.config.longs.privacy_agreement.jk_content_ko",
  PrivacyPolicy_VNG_Version = 4,
  vngContent = "client.slua.config.longs.privacy_agreement.vng_content",
  PrivacyPolicy_TW_Version = 4,
  twContent = "client.slua.config.longs.privacy_agreement.tw_content",
  PrivacyPolicy_BH_Version = 14,
  bhContent = "client.slua.config.longs.privacy_agreement.bh_content"
}
return config