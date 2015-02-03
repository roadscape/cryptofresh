# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150119184918) do

  create_table "orders", force: true do |t|
    t.integer  "product_id"
    t.integer  "shipping_id"
    t.string   "address"
    t.integer  "cents"
    t.datetime "paid_at"
    t.string   "trx_id"
    t.datetime "due_at"
    t.string   "comments"
    t.string   "pub_id"
    t.boolean  "void",          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "ip"
    t.string   "referrer_acct"
    t.integer  "bts_amount"
    t.string   "bts_asset_id"
  end

  create_table "photos", force: true do |t|
    t.integer  "product_id"
    t.integer  "position"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.integer  "position"
    t.integer  "default_id"
    t.boolean  "is_category",        default: false, null: false
    t.integer  "parent_id"
    t.integer  "cents"
    t.string   "dl_file_name"
    t.string   "dl_content_type"
    t.integer  "dl_file_size"
    t.datetime "dl_updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "short_desc"
    t.string   "button_label"
    t.integer  "num_stock"
    t.integer  "num_sold"
    t.string   "node_type"
    t.string   "royalty_acct"
    t.integer  "royalty_cents"
    t.integer  "refer_cents"
  end

  create_table "shippings", force: true do |t|
    t.string   "name"
    t.integer  "cents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.string   "email"
    t.datetime "last_email_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "txes", force: true do |t|
    t.integer "block_num"
    t.string  "trx_id"
    t.text    "json"
    t.integer "order_id"
    t.text    "entries_json"
    t.string  "comment"
  end

  add_index "txes", ["block_num"], name: "index_txes_on_block_num", using: :btree
  add_index "txes", ["trx_id"], name: "index_txes_on_tx", unique: true, using: :btree

end
