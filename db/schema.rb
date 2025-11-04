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

ActiveRecord::Schema[8.0].define(version: 2025_01_04_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "analytics", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "event_type", null: false
    t.string "event_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "event_type"], name: "index_analytics_on_business_id_and_event_type"
    t.index ["business_id"], name: "index_analytics_on_business_id"
    t.index ["created_at"], name: "index_analytics_on_created_at"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.text "description"
    t.string "address", null: false
    t.string "phone"
    t.string "email"
    t.string "website"
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.integer "review_count", default: 0
    t.string "image_url"
    t.boolean "featured", default: false
    t.boolean "has_deals", default: false
    t.text "deal_description"
    t.json "hours"
    t.json "amenities"
    t.json "gallery"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "approval_status", default: "approved"
    t.datetime "approved_at"
    t.integer "approved_by_id"
    t.index ["approval_status"], name: "index_businesses_on_approval_status"
    t.index ["category"], name: "index_businesses_on_category"
    t.index ["featured"], name: "index_businesses_on_featured"
    t.index ["has_deals"], name: "index_businesses_on_has_deals"
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "saved_deals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_saved_deals_on_business_id"
    t.index ["user_id", "business_id"], name: "index_saved_deals_on_user_id_and_business_id", unique: true
    t.index ["user_id"], name: "index_saved_deals_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "user_type", default: "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "suspended", default: false
    t.datetime "suspended_at"
    t.integer "suspended_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["suspended"], name: "index_users_on_suspended"
  end

  create_table "white_labels", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "domain"
    t.string "subdomain"
    t.string "brand_name"
    t.string "logo_url"
    t.string "primary_color"
    t.string "secondary_color"
    t.text "custom_css"
    t.json "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_white_labels_on_domain", unique: true
    t.index ["subdomain"], name: "index_white_labels_on_subdomain", unique: true
    t.index ["user_id"], name: "index_white_labels_on_user_id"
  end

  add_foreign_key "analytics", "businesses"
  add_foreign_key "businesses", "users"
  add_foreign_key "businesses", "users", column: "approved_by_id"
  add_foreign_key "saved_deals", "businesses"
  add_foreign_key "saved_deals", "users"
  add_foreign_key "users", "users", column: "suspended_by_id"
  add_foreign_key "white_labels", "users"
end
