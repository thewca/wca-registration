# frozen_string_literal: true

require 'rails_helper'

describe Lane do
  describe '#set_lane_details_property' do
    it 'changes the value of a property which already exists' do
      registration = FactoryBot.create(:registration, comment: 'this is a test comment')
      registration.competing_lane.set_lane_details_property('comment', 'another comment')
      expect(registration.competing_comment).to eq('another comment')
    end

    it 'creates and sets the value of a property which didnt exist' do
      registration = FactoryBot.create(:registration)
      registration.competing_lane.set_lane_details_property('arbitrary_field', 'arbitrary field value')
      expect(registration.competing_lane.lane_details['arbitrary_field']).to eq('arbitrary field value')
    end
  end
end
