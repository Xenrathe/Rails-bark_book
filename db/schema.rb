# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_05_08_203056) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_one", null: false
    t.string "address_two"
    t.string "city", null: false
    t.string "state"
    t.string "postal_code"
    t.string "country", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "barks", force: :cascade do |t|
    t.bigint "num", default: 1
    t.bigint "user_id"
    t.string "barkable_type", null: false
    t.bigint "barkable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barkable_type", "barkable_id"], name: "index_barks_on_barkable"
    t.index ["user_id"], name: "index_barks_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "body", limit: 250, null: false
    t.bigint "user_id"
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contents", force: :cascade do |t|
    t.string "content_type", null: false
    t.string "title"
    t.text "body"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contents_on_user_id"
  end

  create_table "contents_dogs", force: :cascade do |t|
    t.bigint "dog_id", null: false
    t.bigint "content_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_contents_dogs_on_content_id"
    t.index ["dog_id"], name: "index_contents_dogs_on_dog_id"
  end

  create_table "dog_park_followings", force: :cascade do |t|
    t.bigint "dog_park_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dog_park_id"], name: "index_dog_park_followings_on_dog_park_id"
    t.index ["user_id"], name: "index_dog_park_followings_on_user_id"
  end

  create_table "dog_parks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "dog_size", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dogs", force: :cascade do |t|
    t.string "breed", null: false
    t.string "name", null: false
    t.integer "weight", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "birthdate", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_dogs_on_user_id"
  end

  create_table "dogs_play_dates", id: false, force: :cascade do |t|
    t.bigint "play_date_id", null: false
    t.bigint "dog_id", null: false
    t.index ["dog_id", "play_date_id"], name: "index_dogs_play_dates_on_dog_id_and_play_date_id"
    t.index ["play_date_id", "dog_id"], name: "index_dogs_play_dates_on_play_date_id_and_dog_id"
  end

  create_table "followings", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "dog_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dog_id"], name: "index_followings_on_dog_id"
    t.index ["user_id"], name: "index_followings_on_user_id"
  end

  create_table "play_dates", force: :cascade do |t|
    t.datetime "date", null: false
    t.text "description"
    t.bigint "dog_park_id", null: false
    t.integer "dog_size", default: 2, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dog_park_id"], name: "index_play_dates_on_dog_park_id"
    t.index ["user_id"], name: "index_play_dates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", limit: 25, null: false
    t.bigint "primary_address_id"
    t.string "time_zone", default: "UTC", null: false
    t.string "bark_sound", default: "mute"
    t.string "provider"
    t.string "uid"
    t.string "unconfirmed_email"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["primary_address_id"], name: "index_users_on_primary_address_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "barks", "users", on_delete: :nullify
  add_foreign_key "comments", "users", on_delete: :nullify
  add_foreign_key "contents", "users"
  add_foreign_key "contents_dogs", "contents"
  add_foreign_key "contents_dogs", "dogs"
  add_foreign_key "dog_park_followings", "dog_parks"
  add_foreign_key "dog_park_followings", "users"
  add_foreign_key "dogs", "users"
  add_foreign_key "followings", "dogs"
  add_foreign_key "followings", "users"
  add_foreign_key "play_dates", "dog_parks"
  add_foreign_key "play_dates", "users"
  add_foreign_key "users", "addresses", column: "primary_address_id"
end
