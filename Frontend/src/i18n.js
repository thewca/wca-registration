import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import resources from './translations/resources'

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

export default i18n
