# frozen_string_literal: true

module Helpers
  module RegistrationHelper
    RSpec.shared_context 'competition information' do
      before do
        # Define competition IDs
        @comp_with_registrations = 'CubingZANationalChampionship2023'
        @empty_comp = '1AVG2013'
        @error_comp_404 = 'InvalidCompID'
        @error_comp_500 = 'BrightSunOpen2023'
        @error_comp_502 = 'GACubersStudyJuly2023'

        # COMP WITH REGISTATIONS - Stub competition info
        competition_details = get_competition_details(@comp_with_registrations)
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{@comp_with_registrations}")
          .to_return(status: 200, body: competition_details.to_json)

        # EMPTY COMP STUB
        competition_details = get_competition_details(@empty_comp)
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{@empty_comp}")
          .to_return(status: 200, body: competition_details.to_json)

        # 404 COMP STUB
        wca_error_json = { error: 'Competition with id InvalidCompId not found' }.to_json
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{@error_comp_404}")
          .to_return(status: 404, body: wca_error_json)

        # 500 COMP STUB
        error_json = { error:
                         "Internal Server Error for url: /api/v0/competitions/#{@error_comp_500}" }.to_json
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{@error_comp_500}")
          .to_return(status: 500, body: error_json)

        # 502 COMP STUB
        error_json = { error:
                         "Internal Server Error for url: /api/v0/competitions/#{@error_comp_502}" }.to_json
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{@error_comp_502}")
          .to_return(status: 502, body: error_json)
      end
    end

    RSpec.shared_context 'stub ZA champs comp info' do
      before do
        competition_id = "CubingZANationalChampionship2023"
        competition_details = get_competition_details(competition_id)

        # Stub the request to the Competition Service
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
          .to_return(status: 200, body: competition_details.to_json)
      end
    end

    def fetch_jwt_token(user_id)
      iat = Time.now.to_i
      jti_raw = [JwtOptions.secret, iat].join(':').to_s
      jti = Digest::MD5.hexdigest(jti_raw)
      payload = { data: { user_id: user_id }, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
      token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
      "Bearer #{token}"
    end

    RSpec.shared_context 'basic_auth_token' do
      before do
        @jwt_token = fetch_jwt_token('158817')
        # @jwt_token_2 = fetch_jwt_token('158817')
      end
    end

    RSpec.shared_context 'registration_data' do
      let(:required_fields_only) { get_registration('CubingZANationalChampionship2023-158817', false) }

      before do
        # General
        @basic_registration = get_registration('CubingZANationalChampionship2023-158816', false)
        @required_fields_only = get_registration('CubingZANationalChampionship2023-158817', false)
        @no_attendee_id = get_registration('CubingZANationalChampionship2023-158818', false)

        # # For 'various optional fields'
        # @with_is_attending = get_registration('CubingZANationalChampionship2023-158819')
        @with_hide_name_publicly = get_registration('CubingZANationalChampionship2023-158820', false)
        @with_all_optional_fields = @basic_registration

        # # For 'bad request payloads'
        @missing_reg_fields = get_registration('CubingZANationalChampionship2023-158821', false)
        @empty_json = get_registration('', false)
        @missing_lane = get_registration('CubingZANationalChampionship2023-158822', false)
      end
    end

    RSpec.shared_context 'PATCH payloads' do
      before do
        # URL parameters
        @competiton_id = "CubingZANationalChampionship2023"
        @user_id_816 = "158816"
        @user_id_823 = "158823"

        # Cancel payloads
        @cancellation = get_patch("816-cancel-full-registration")
        @double_cancellation = get_patch("823-cancel-full-registration")
        @cancel_wrong_lane = get_patch('823-cancel-wrong-lane')

        # Update payloads
        @add_444 = get_patch('CubingZANationalChampionship2023-158816')
      end
    end

    # NOTE: Remove this once post_attendee_spec.rb tests are passing
    # RSpec.shared_context 'various optional fields' do
    #   include_context 'registration_data'
    #   before do
    #     @payloads = [@with_is_attending, @with_hide_name_publicly, @with_all_optional_fields]
    #   end
    # end

    # NOTE: Remove this once post_attendee_spec.rb tests are passing
    # RSpec.shared_context 'bad request payloads' do
    #   include_context 'registration_data'
    #   before do
    #     @bad_payloads = [@missing_reg_fields, @empty_json, @missing_lane]
    #   end
    # end

    RSpec.shared_context 'database seed' do
      before do
        # Create a "normal" registration entry
        basic_registration = get_registration('CubingZANationalChampionship2023-158816', true)
        registration = Registration.new(basic_registration)
        registration.save

        # Create a registration that is already cancelled
        cancelled_registration = get_registration('CubingZANationalChampionship2023-158823', true)
        registration = Registration.new(cancelled_registration)
        registration.save
      end
    end

    RSpec.shared_context '200 response from competition service' do
      before do
        competition_details = get_competition_details('CubingZANationalChampionship2023')

        # Stub the request to the Competition Service
        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/CubingZANationalChampionship2023")
          .to_return(status: 200, body: competition_details.to_json)
      end
    end

    RSpec.shared_context '500 response from competition service' do
      before do
        puts "in 500"
        error_json = { error:
                         'Internal Server Error for url: /api/v0/competitions/1AVG2013' }.to_json

        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/1AVG2013")
          .to_return(status: 500, body: error_json)
      end
    end

    RSpec.shared_context '502 response from competition service' do
      before do
        error_json = { error: 'Internal Server Error for url: /api/v0/competitions/BrightSunOpen2023' }.to_json

        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/BrightSunOpen2023")
          .to_return(status: 502, body: error_json)
      end
    end

    # Retrieves the saved JSON response of /api/v0/competitions for the given competition ID
    def get_competition_details(competition_id)
      File.open("#{Rails.root}/spec/fixtures/competition_details.json", 'r') do |f|
        competition_details = JSON.parse(f.read)

        # Retrieve the competition details when competition_id matches
        competition_details['competitions'].each do |competition|
          return competition if competition['id'] == competition_id
        end
      end
    end

    def get_registration(attendee_id, raw)
      File.open("#{Rails.root}/spec/fixtures/registrations.json", 'r') do |f|
        registrations = JSON.parse(f.read)

        # Retrieve the competition details when attendee_id matches
        registration = registrations.find { |r| r["attendee_id"] == attendee_id }
        begin
          registration["lanes"] = registration["lanes"].map { |lane| Lane.new(lane) }
          if raw
            return registration
          end
        rescue NoMethodError
          # puts e
          return registration
        end
        convert_registration_object_to_payload(registration)
      end
    end

    def convert_registration_object_to_payload(registration)
      competing_lane = registration["lanes"].find { |l| l.lane_name == "competing" }
      event_ids = get_event_ids_from_competing_lane(competing_lane)

      {
        user_id: registration["user_id"],
        competition_id: registration["competition_id"],
        competing: {
          event_ids: event_ids,
          registration_status: competing_lane.lane_state,
        },
      }
    end

    def get_event_ids_from_competing_lane(competing_lane)
      event_ids = []
      competing_lane.lane_details["event_details"].each do |event|
        # Add the event["event_id"] to the list of event_ids
        event_ids << event["event_id"]
      end
      event_ids
    end

    def get_patch(patch_name)
      File.open("#{Rails.root}/spec/fixtures/patches.json", 'r') do |f|
        patches = JSON.parse(f.read)

        # Retrieve the competition details when attendee_id matches
        patch = patches[patch_name]
        patch
      end
    end

    def registration_equal(registration_model, registration_hash)
      unchecked_attributes = [:created_at, :updated_at]

      registration_model.attributes.each do |k, v|
        unless unchecked_attributes.include?(k)
          hash_value = registration_hash[k.to_s]

          if v.is_a?(Hash) && hash_value.is_a?(Hash)
            return false unless nested_hash_equal?(v, hash_value)
          elsif v.is_a?(Array) && hash_value.is_a?(Array)
            return false unless lanes_equal(v, hash_value)
          elsif hash_value != v
            puts "#{hash_value} does not equal #{v}"
            return false
          end
        end
      end

      true
    end

    def lanes_equal(lanes1, lanes2)
      lanes1.each_with_index do |el, i|
        unless el == lanes2[i]
          return false
        end
      end
      true
    end

    def nested_hash_equal?(hash1, hash2)
      hash1.each do |k, v|
        if v.is_a?(Hash) && hash2[k].is_a?(Hash)
          return false unless nested_hash_equal?(v, hash2[k])
        elsif hash2[k.to_s] != v
          puts "#{hash2[k.to_s]} does not equal to #{v}"
          return false
        end
      end
      true
    end
  end
end
