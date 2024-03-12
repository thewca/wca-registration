import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import resources from './translations/resources'

if (process.env.NODE_ENV === 'production') {
  i18n.use(initReactI18next).init({
    // Use the monoliths translations object
    resources: window.I18n.translations,
    lng: window.I18n.locale,
    interpolation: {
      escapeValue: false, // react already safes from xss
      prefix: '%{',
      suffix: '}',
    },
    useSuspense: false,
  })
} else {
  i18n.use(initReactI18next).init({
    resources,
    lng: 'en',
    interpolation: {
      escapeValue: false, // react already safes from xss
      prefix: '%{',
      suffix: '}',
    },
    useSuspense: false,
  })
}

export default i18n
