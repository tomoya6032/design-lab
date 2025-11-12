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

ActiveRecord::Schema[8.0].define(version: 2025_11_11_001934) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "article_categories", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_categories_on_article_id"
    t.index ["category_id"], name: "index_article_categories_on_category_id"
  end

  create_table "article_tags", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_tags_on_article_id"
    t.index ["tag_id"], name: "index_article_tags_on_tag_id"
  end

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
    t.boolean "show_table_of_contents"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.integer "parent_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "subject", null: false
    t.text "message", null: false
    t.string "ip_address"
    t.text "user_agent"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_contacts_on_created_at"
    t.index ["email"], name: "index_contacts_on_email"
    t.index ["status"], name: "index_contacts_on_status"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title", null: false
    t.string "job_type", null: false
    t.text "description"
    t.string "capacity"
    t.string "salary_range"
    t.text "expectations"
    t.text "senior_message"
    t.boolean "published", default: false
    t.integer "display_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order"], name: "index_jobs_on_display_order"
    t.index ["job_type"], name: "index_jobs_on_job_type"
    t.index ["published"], name: "index_jobs_on_published"
  end

  create_table "media", force: :cascade do |t|
    t.string "filename"
    t.string "url"
    t.string "alt_text"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.string "file_type"
    t.integer "file_size"
    t.index ["user_id"], name: "index_media_on_user_id"
  end

  create_table "media_usages", force: :cascade do |t|
    t.bigint "medium_id", null: false
    t.string "mediable_type", null: false
    t.bigint "mediable_id", null: false
    t.string "usage_type"
    t.string "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mediable_type", "mediable_id"], name: "index_media_usages_on_mediable"
    t.index ["medium_id"], name: "index_media_usages_on_medium_id"
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
    t.boolean "show_table_of_contents"
    t.boolean "show_in_navigation"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "title", null: false
    t.string "production_period"
    t.text "description"
    t.boolean "published", default: false
    t.integer "display_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order"], name: "index_portfolios_on_display_order"
    t.index ["published"], name: "index_portfolios_on_published"
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

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "article_categories", "articles"
  add_foreign_key "article_categories", "categories"
  add_foreign_key "article_tags", "articles"
  add_foreign_key "article_tags", "tags"
  add_foreign_key "articles", "users"
  add_foreign_key "media", "users"
  add_foreign_key "media_usages", "media"
  add_foreign_key "pages", "users"
end
