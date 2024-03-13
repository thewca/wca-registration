import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import resources from './translations/resources'

export const TRANSLATIONS_NAMESPACE = 'translations'

const shared = {
  interpolation: {
    escapeValue: false, // react already safes from xss
    prefix: '%{',
    suffix: '}',
  },
  useSuspense: false,
  defaultNS: TRANSLATIONS_NAMESPACE,
}

if (process.env.NODE_ENV === 'production') {
  // Use the monoliths translations object
  const monolithTranslations = {}
  monolithTranslations[window.I18n.locale] = {
    translations: window.I18n[TRANSLATIONS_NAMESPACE][window.I18n.locale],
  }
  i18n.use(initReactI18next).init({
    ...shared,
    resources: monolithTranslations,
    lng: window.I18n.locale,
  })
} else {
  i18n.use(initReactI18next).init({
    ...shared,
    lng: 'en',
    resources,
  })
}

export default i18n
