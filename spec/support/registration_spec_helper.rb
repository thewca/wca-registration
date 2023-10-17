# frozen_string_literal: true

module Helpers
  module RegistrationHelper
    # SHARED CONTEXTS

    RSpec.shared_context 'competition information' do
      before do
        # Define competition IDs
        @includes_non_attending_registrations = 'CubingZANationalChampionship2023'
        @attending_registrations_only = 'LazarilloOpen2023'
        @empty_comp = '1AVG2013'
        @error_comp_404 = 'InvalidCompID'
        @error_comp_500 = 'BrightSunOpen2023'
        @error_comp_502 = 'GACubersStudyJuly2023'
        @registrations_exist_comp_500 = 'WinchesterWeeknightsIV2023'
        @registrations_exist_comp_502 = 'BangaloreCubeOpenJuly2023'
        @registrations_not_open = 'BrizZonSylwesterOpen2023'
        @comment_mandatory = 'LazarilloOpen2024'
        @full_competition = 'CubingZANationalChampionship2024'

        @base_comp_url = comp_api_url('')

        # TODO: Refctor these to be single lines that call a "stub competition" method?(how do I customise bodys and codes?)

        # COMP WITH ALL ATTENDING REGISTRATIONS
        competition_details = get_competition_details(@attending_registrations_only)
        stub_request(:get, "#{@base_comp_url}#{@attending_registrations_only}")
          .to_return(status: 200, body: competition_details.to_json)

        # COMP WITH DIFFERENT REGISTATION STATUSES - Stub competition info
        competition_details = get_competition_details(@includes_non_attending_registrations)
        stub_request(:get, "#{@base_comp_url}#{@includes_non_attending_registrations}")
          .to_return(status: 200, body: competition_details.to_json)

        # EMPTY COMP STUB
        competition_details = get_competition_details(@empty_comp)
        stub_request(:get, "#{@base_comp_url}#{@empty_comp}")
          .to_return(status: 200, body: competition_details.to_json)

        # REGISTRATIONS NOT OPEN
        competition_details = get_competition_details(@registrations_not_open)
        stub_request(:get, "#{@base_comp_url}#{@registrations_not_open}")
          .to_return(status: 200, body: competition_details.to_json)

        # COMMENT REQUIRED
        competition_details = get_competition_details(@comment_mandatory)
        stub_request(:get, "#{@base_comp_url}#{@comment_mandatory}")
          .to_return(status: 200, body: competition_details.to_json)

        # COMPETITOR LIMIT REACHED
        competition_details = get_competition_details(@full_competition)
        stub_request(:get, "#{@base_comp_url}#{@full_competition}")
          .to_return(status: 200, body: competition_details.to_json)

        # 404 COMP STUB
        wca_error_json = { error: 'Competition with id InvalidCompId not found' }.to_json
        stub_request(:get, "#{@base_comp_url}#{@error_comp_404}")
          .to_return(status: 404, body: wca_error_json)

        # 500 COMP STUB
        error_json = { error:
                         "Internal Server Error for url: /api/v0/competitions/#{@error_comp_500}" }.to_json
        stub_request(:get, "#{@base_comp_url}#{@error_comp_500}")
          .to_return(status: 500, body: error_json)

        error_json = { error:
                         "Internal Server Error for url: /api/v0/competitions/#{@registrations_exist_comp_500}" }.to_json
        stub_request(:get, "#{@base_comp_url}#{@registrations_exist_comp_500}")
          .to_return(status: 500, body: error_json)

        # 502 COMP STUB
        error_json = { error:
                         "Internal Server Error for url: /api/v0/competitions/#{@error_comp_502}" }.to_json
        stub_request(:get, "#{@base_comp_url}#{@error_comp_502}")
          .to_return(status: 502, body: error_json)
        error_json = { error:
                         "Internal Server Error for url: /api/v0/competitions/#{@registrations_exist_comp_502}" }.to_json
        stub_request(:get, "#{@base_comp_url}#{@registrations_exist_comp_502}")
          .to_return(status: 502, body: error_json)
      end
    end

    RSpec.shared_context 'auth_tokens' do
      before do
        @jwt_800 = fetch_jwt_token('800')
        @jwt_816 = fetch_jwt_token('158816')
        @jwt_817 = fetch_jwt_token('158817')
        @jwt_818 = fetch_jwt_token('158818')
        @jwt_819 = fetch_jwt_token('158819')
        @jwt_820 = fetch_jwt_token('158820')
        @jwt_823 = fetch_jwt_token('158823')
        @jwt_824 = fetch_jwt_token('158824')
        @jwt_200 = fetch_jwt_token('158200')
        @jwt_201 = fetch_jwt_token('158201')
        @jwt_202 = fetch_jwt_token('158202')
        @admin_token = fetch_jwt_token('15073')
        @admin_token_2 = fetch_jwt_token('15074')
        @organizer_token = fetch_jwt_token('1')
        @multi_comp_organizer_token = fetch_jwt_token('2')
        @banned_user_jwt = fetch_jwt_token('209943')
        @incomplete_user_jwt = fetch_jwt_token('999999')
      end
    end

    RSpec.shared_context 'registration_data' do
      before do
        # General
        @basic_registration = get_registration('CubingZANationalChampionship2023-158816', false)
        @required_fields_only = get_registration('CubingZANationalChampionship2023-158817', false)
        @no_attendee_id = get_registration('CubingZANationalChampionship2023-158818', false)
        @empty_payload = {}.to_json
        @reg_2 = get_registration('LazarilloOpen2023-158820', false)

        # Failure cases
        @admin_comp_not_open = get_registration('BrizZonSylwesterOpen2023-15074', false)
        @comp_not_open = get_registration('BrizZonSylwesterOpen2023-158817', false)
        @bad_comp_name = get_registration('InvalidCompID-158817', false)
        @banned_user_reg = get_registration('CubingZANationalChampionship2023-209943', false)
        @incomplete_user_reg = get_registration('CubingZANationalChampionship2023-999999', false)
        @events_not_held_reg = get_registration('CubingZANationalChampionship2023-158201', false)
        @events_not_exist_reg = get_registration('CubingZANationalChampionship2023-158202', false)
        @too_many_guests = get_registration('CubingZANationalChampionship2023-158824', false)

        # For 'various optional fields'
        @with_hide_name_publicly = get_registration('CubingZANationalChampionship2023-158820', false)

        # For 'bad request payloads'
        @missing_reg_fields = get_registration('CubingZANationalChampionship2023-158821', false)
        @empty_json = get_registration('', false)
        @missing_lane = get_registration('CubingZANationalChampionship2023-158822', false)
      end
    end

    RSpec.shared_context 'PATCH payloads' do
      before do
        # URL parameters
        @competiton_id = 'CubingZANationalChampionship2023'
        @user_id_816 = '158816'
        @user_id_823 = '158823'

        # Cancel payloads
        @bad_comp_cancellation = get_patch('816-cancel-bad-comp')
        @cancellation_with_events = get_patch('816-cancel-and-change-events')
        @bad_user_cancellation = get_patch('800-cancel-no-reg')
        @cancellation_1 = get_patch('1-cancel-full-registration')
        @cancellation_816 = get_patch('816-cancel-full-registration')
        @cancellation_816_2 = get_patch('816-cancel-full-registration_2')
        @cancellation_817 = get_patch('817-cancel-full-registration')
        @cancellation_818 = get_patch('818-cancel-full-registration')
        @cancellation_819 = get_patch('819-cancel-full-registration')
        @cancellation_823 = get_patch('823-cancel-full-registration')
        @cancellation_073 = get_patch('073-cancel-full-registration')
        @double_cancellation = get_patch('823-cancel-full-registration')
        @cancel_wrong_lane = get_patch('823-cancel-wrong-lane')

        # Update payloads
        @add_444 = get_patch('CubingZANationalChampionship2023-158816')
        @comment_update = get_patch('816-comment-update')
        @comment_update_2 = get_patch('817-comment-update')
        @comment_update_3 = get_patch('817-comment-update-2')
        @comment_update_4 = get_patch('820-missing-comment')
        @guest_update_1 = get_patch('816-guest-update')
        @guest_update_2 = get_patch('817-guest-update')
        @guest_update_3 = get_patch('817-guest-update-2')
        @events_update_1 = get_patch('816-events-update')
        @events_update_2 = get_patch('817-events-update')
        @events_update_3 = get_patch('817-events-update-2')
        @events_update_5 = get_patch('817-events-update-4')
        @events_update_6 = get_patch('817-events-update-5')
        @events_update_7 = get_patch('817-events-update-6')
        @pending_update_1 = get_patch('817-status-update-1')
        @pending_update_2 = get_patch('817-status-update-2')
        @pending_update_3 = get_patch('819-status-update-3')
        @waiting_update_1 = get_patch('819-status-update-1')
        @waiting_update_2 = get_patch('819-status-update-2')
        @accepted_update_1 = get_patch('816-status-update-1')
        @accepted_update_2 = get_patch('816-status-update-2')
        @invalid_status_update = get_patch('816-status-update-3')
        @delayed_update_1 = get_patch('820-delayed-update')
      end
    end

    RSpec.shared_context 'database seed' do
      before do
        create_registration(get_registration('CubingZANationalChampionship2023-158816', true)) # Accepted registration
        create_registration(get_registration('CubingZANationalChampionship2023-1', true)) # Accepted registration
        create_registration(get_registration('CubingZANationalChampionship2023-158817', true)) # Pending registration
        create_registration(get_registration('CubingZANationalChampionship2023-158818', true)) # update_pending registration
        create_registration(get_registration('CubingZANationalChampionship2023-158819', true)) # waiting_list registration
        create_registration(get_registration('CubingZANationalChampionship2023-158823', true)) # Cancelled registration

        # Create registrations for 'WinchesterWeeknightsIV2023' - all accepted
        create_registration(get_registration('WinchesterWeeknightsIV2023-158816', true))
        create_registration(get_registration('WinchesterWeeknightsIV2023-158817', true))
        create_registration(get_registration('WinchesterWeeknightsIV2023-158818', true))

        # Create registrations for 'BangaloreCubeOpenJuly2023' - all accepted
        create_registration(get_registration('BangaloreCubeOpenJuly2023-158818', true))
        create_registration(get_registration('BangaloreCubeOpenJuly2023-158819', true))

        # Create registrations for 'LazarilloOpen2023' - all accepted
        create_registration(get_registration('LazarilloOpen2023-158820', true))
        create_registration(get_registration('LazarilloOpen2023-158821', true))
        create_registration(get_registration('LazarilloOpen2023-158822', true))
        create_registration(get_registration('LazarilloOpen2023-158823', true))

        # Create registrations for LazarilloOpen2024 - all acceptd
        create_registration(get_registration('LazarilloOpen2024-158820', true))

        # Create registrations for CubingZANationals2024
        create_registration(get_registration('CubingZANationalChampionship2024-158816', true))
        create_registration(get_registration('CubingZANationalChampionship2024-158817', true))
        create_registration(get_registration('CubingZANationalChampionship2024-158818', true))
        create_registration(get_registration('CubingZANationalChampionship2024-158819', true))

        # Create registrations for 'BrizZonSylwesterOpen2023'
        create_registration(get_registration('BrizZonSylwesterOpen2023-15073', true))
      end
    end

    # HELPER METHODS

    # Create registration from raw registration JSON
    def create_registration(registration_data)
      registration = Registration.new(registration_data)
      registration.save
    end

    # For mocking - returns the saved JSON response of /api/v0/competitions for the given competition ID
    def get_competition_details(competition_id)
      File.open("#{Rails.root}/spec/fixtures/competition_details.json", 'r') do |f|
        competition_details = JSON.parse(f.read)

        # Retrieve the competition details when competition_id matches
        competition_details['competitions'].each do |competition|
          return competition if competition['id'] == competition_id
        end
      end
    end

    # Creates a JWT token for the given user_id
    def fetch_jwt_token(user_id)
      iat = Time.now.to_i
      jti_raw = [JwtOptions.secret, iat].join(':').to_s
      jti = Digest::MD5.hexdigest(jti_raw)
      payload = { data: { user_id: user_id }, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
      token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
      "Bearer #{token}"
    end

    # Returns a registration from registrations.json for the given attendee_id
    # If raw is true, returns it in the simplified format for submission to the POST registration endpoint
    # If raw is false, returns the database-like registration JSON object
    def get_registration(attendee_id, raw)
      File.open("#{Rails.root}/spec/fixtures/registrations.json", 'r') do |f|
        registrations = JSON.parse(f.read)

        # Retrieve the competition details when attendee_id matches
        registration = registrations.find { |r| r['attendee_id'] == attendee_id }
        begin
          registration['lanes'] = registration['lanes'].map { |lane| Lane.new(lane) }
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

    # "patch" object is the input to a PATCH request to an API endpoint.
    # This function returns a JSON patch object according to its "patch_name" (the key value in a JSON file)
    def get_patch(patch_name)
      File.open("#{Rails.root}/spec/fixtures/patches.json", 'r') do |f|
        patches = JSON.parse(f.read)

        # Retrieve the competition details when attendee_id matches
        patch = patches[patch_name]
        patch
      end
    end

    private

      # Converts a raw registration object (database-like format) to a payload which can be sent to the registration API
      def convert_registration_object_to_payload(registration)
        competing_lane = registration['lanes'].find { |l| l.lane_name == 'competing' }
        event_ids = get_event_ids_from_competing_lane(competing_lane)

        registration_payload = {
          user_id: registration['user_id'],
          competition_id: registration['competition_id'],
          competing: {
            event_ids: event_ids,
            registration_status: competing_lane.lane_state,
          },
        }
        if competing_lane.lane_details.key?('guests')
          registration_payload[:guests] = competing_lane.lane_details['guests']
        end
        registration_payload
      end

      # Returns an array of event_ids for the given competing lane
      # NOTE: Assumes that the given lane is a competing lane - it doesn't validate this
      def get_event_ids_from_competing_lane(competing_lane)
        event_ids = []
        competing_lane.lane_details['event_details'].each do |event|
          # Add the event["event_id"] to the list of event_ids
          event_ids << event['event_id']
        end
        event_ids
      end

      # Determines whether the two given values represent equiivalent registration hashes
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

      # Determines whether the given registration lanes are equivalent
      # Helper method to registration_equal
      def lanes_equal(lanes1, lanes2)
        lanes1.each_with_index do |el, i|
          unless el == lanes2[i]
            return false
          end
        end
        true
      end

      # Helper method to registration_equal
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
