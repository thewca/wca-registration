# frozen_string_literal: true

class CreateLane < ActiveRecord::Migration[7.2]
  def change
    create_table :registration_lanes do |t|
      t.bigint :registration_id, null: false
      t.string :lane_name
      t.string :lane_state
      t.json :completed_steps
      t.json :lane_details

      t.timestamps
    end
    add_foreign_key :registration_lanes, :v2_registrations, column: :registration_id
    add_index :registration_lanes, :registration_id
  end
end
