bundle install --path vendor/bundle
# We include the models here so we don't need to maintain two versions
zip -r registration_status.zip registration_status.rb ../../app/models/registration.rb ../../app/models/lane.rb vendor
