bundle install --path vendor/bundle
# remove old zip if it exists
rm -f registration_status.zip
# We include the models here so we don't need to maintain two versions
# We have to copy them over, because we want to maintain the paths for the vendor folder, but not for the models
lib_folder=registration_lib
mkdir $lib_folder
cp ../../app/models/registration.rb ./$lib_folder/registration.rb
cp ../../app/models/registration_history.rb ./$lib_folder/registration_history.rb
cp ../../lib/lane.rb ./$lib_folder/lane.rb
cp ../../lib/history.rb ./$lib_folder/history.rb
zip -r registration_status.zip registration_status.rb ./$lib_folder/*.rb vendor
# remove lib files again
rm -rf $lib_folder
# remove any bundler or vendor files
rm -rf .bundle
rm -rf vendor
