require "google/cloud/storage"

# Pull all valid keys from the database
valid_keys = ActiveStorage::Blob.pluck(:key)
valid_keys_set = Set.new(valid_keys)

# Connect to GCS
storage = Google::Cloud::Storage.new(
  project_id: "barkpark-411620",
  credentials: "config/secrets/barkpark-gcloud.json"
)

bucket = storage.bucket("bark_pups_bucket")

# Fetch all files in the bucket
puts "Fetching all files from bucket..."
all_files = bucket.files

puts "Checking for orphaned files..."
orphaned_files = all_files.reject { |file| valid_keys_set.include?(file.name) }

puts "Found #{orphaned_files.count} orphaned files."

# Confirm deletion first
if orphaned_files.any?
  puts "About to delete the following files:"
  orphaned_files.each { |file| puts "- #{file.name}" }

  print "Type 'yes' to continue deleting: "
  answer = STDIN.gets.chomp

  if answer == "yes"
    orphaned_files.each do |file|
      puts "Deleting #{file.name}..."
      file.delete
    end
    puts "All orphaned files deleted."
  else
    puts "Aborted."
  end
else
  puts "No orphaned files found."
end