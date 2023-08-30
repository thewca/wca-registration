bundle install --path vendor/bundle
# remove old zip if it exists
rm -f registration_status.zip
# We include the models here so we don't need to maintain two versions
# We have to copy them over, because we want to maintain the paths for the vendor folder, but not for the models
cp ../../app/models/registration.rb ./registration.rb
cp ../../app/models/lane.rb ./lane.rb
zip -r registration_status.zip registration.rb lane.rb registration_status.rb vendor
# remove model files again
rm -f lane.rb
rm -f registration.rb
