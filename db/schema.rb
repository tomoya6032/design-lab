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

ActiveRecord::Schema[8.0].define(version: 2025_10_22_050553) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.jsonb "content_json"
    t.string "slug"
    t.integer "status"
    t.datetime "published_at"
    t.string "meta_description"
    t.jsonb "custom_fields"
    t.string "image_url"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "media", force: :cascade do |t|
    t.string "filename"
    t.string "url"
    t.string "alt_text"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_media_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.jsonb "content_json"
    t.string "slug"
    t.integer "status"
    t.datetime "published_at"
    t.string "meta_description"
    t.jsonb "custom_fields"
    t.string "image_url"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "site_name"
    t.text "site_description"
    t.string "logo_url"
    t.string "favicon_url"
    t.text "custom_css"
    t.text "custom_js"
    t.jsonb "social_links"
    t.jsonb "seo_settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme", default: "modern"
    t.string "contact_email"
    t.boolean "maintenance_mode", default: false
    t.string "meta_title"
    t.text "meta_description"
    t.string "meta_keywords"
    t.string "google_analytics_id"
    t.string "twitter_url"
    t.string "facebook_url"
    t.string "instagram_url"
    t.string "youtube_url"
    t.string "primary_color"
    t.string "secondary_color"
    t.string "accent_color"
    t.string "font_family"
    t.string "header_font"
    t.integer "header_height"
    t.integer "container_width"
    t.integer "sidebar_width"
    t.integer "border_radius"
    t.string "box_shadow"
    t.string "animation_speed"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "user"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "articles", "users"
  add_foreign_key "media", "users"
  add_foreign_key "pages", "users"
end
