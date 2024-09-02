# frozen_string_literal: true

REGISTRATION_TRANSITIONS = Registration::REGISTRATION_STATES.flat_map do |initial_status|
  Registration::REGISTRATION_STATES.map do |new_status| 
    { initial_status: initial_status, new_status: new_status }
  end
end

  

