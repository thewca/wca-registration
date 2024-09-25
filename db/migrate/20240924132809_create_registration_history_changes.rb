# frozen_string_literal: true

class CreateRegistrationHistoryChanges < ActiveRecord::Migration[7.2]
  def change
    create_table :registration_history_changes do |t|
      t.string :key
      t.string :from
      t.string :to
      t.bigint :registration_history_entry_id

      t.timestamps
    end
    add_foreign_key :registration_history_changes, :registration_history_entries, column: :registration_history_entry_id
    add_index :registration_history_changes, :registration_history_entry_id
  end
end
