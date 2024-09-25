# frozen_string_literal: true

class CreateRegistrationHistoryEntry < ActiveRecord::Migration[7.2]
  def change
    create_table :registration_history_entries do |t|
      t.string :actor_type
      t.string :actor_id
      t.date :timestamp
      t.string :action
      t.integer :registration_id

      t.timestamps
    end
  end
end
