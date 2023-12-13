import * as currencies from '@dinero.js/currencies'
import { dinero, toDecimal } from 'dinero.js'

export function displayMoneyISO4217(amount: number, currencyCode: string) {
  return toDecimal(
    dinero({
      amount,
      currency: currencies[currencyCode],
    }),
    ({ value, currency }) => `${currency.code} ${value}`
  )
}
