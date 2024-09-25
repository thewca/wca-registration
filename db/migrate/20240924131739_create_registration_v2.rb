# frozen_string_literal: true

class CreateRegistrationV2 < ActiveRecord::Migration[7.2]
  def change
    create_table :v2_registrations do |t|
      t.integer :user_id
      t.integer :guests
      t.string :competition_id

      t.timestamps
    end
  end
end
