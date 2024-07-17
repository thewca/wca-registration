# frozen_string_literal: true

require 'money-rails'

module MoneyFormat
  def self.format_human_readable(amount_lowest_denominator, currency_code)
    money = Money.from_cents(amount_lowest_denominator, currency_code)
    "#{money.format} (#{money.currency.name})"
  end
end
