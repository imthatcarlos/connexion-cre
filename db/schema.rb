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

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "job_active_session", primary_key: "sessionid", id: :string, limit: 255, force: :cascade do |t|
    t.string   "login_time", limit: 255
    t.datetime "user_id"
    t.string   "node",       limit: 255
  end

  create_table "job_activity", primary_key: ["username", "jobid"], force: :cascade do |t|
    t.string  "username",      limit: 255, null: false
    t.integer "jobid",                     null: false
    t.date    "activity_date"
    t.time    "activity_time"
  end

  create_table "job_actor", id: :integer, force: :cascade do |t|
    t.integer "job_id"
    t.string  "manager_id",   limit: 255
    t.string  "manager_name", limit: 255
    t.integer "type",                     null: false
    t.string  "user_id",      limit: 255, null: false
    t.string  "user_name",    limit: 255, null: false
  end

  create_table "job_address", id: :integer, force: :cascade do |t|
    t.string "name",         limit: 255
    t.string "state",        limit: 255
    t.string "country",      limit: 255
    t.string "addl_address", limit: 255
    t.string "city",         limit: 255
    t.string "phone",        limit: 255
    t.string "street",       limit: 255
    t.string "zipcode",      limit: 255
    t.string "email",        limit: 255
    t.string "fax",          limit: 255
    t.string "addl_name",    limit: 255
  end

  create_table "job_adjustment", id: :integer, force: :cascade do |t|
    t.integer "bom_id"
    t.decimal "cost",                         precision: 19, scale: 2
    t.decimal "sell",                         precision: 19, scale: 2
    t.date    "transaction_date"
    t.string  "transaction_id",   limit: 255
    t.time    "transaction_time"
    t.integer "vendor_id"
    t.string  "vendor_name",      limit: 255
    t.index ["bom_id"], name: "job_adjustment_bom_id_index", using: :btree
  end

  create_table "job_admin_default", primary_key: "name", id: :string, limit: 20, force: :cascade do |t|
    t.string "value_id", limit: 255, null: false
  end

  create_table "job_alternatives", id: :integer, force: :cascade do |t|
    t.integer "alt_bom_id"
    t.integer "bom_id"
    t.string  "name",        limit: 255
    t.boolean "substituted"
    t.index ["alt_bom_id"], name: "job_alternatives_alt_bom_id_index", using: :btree
    t.index ["bom_id"], name: "job_alternatives_bom_id_index", using: :btree
  end

  create_table "job_bom", id: :integer, force: :cascade do |t|
    t.integer "optlock"
    t.string  "category",         limit: 255
    t.string  "description",      limit: 255
    t.integer "job_id"
    t.date    "stock_on_hold"
    t.time    "transaction_time"
    t.decimal "total_margin",                 precision: 19, scale: 6
    t.decimal "total_markup",                 precision: 19, scale: 6
    t.decimal "total_ext_cost",               precision: 19, scale: 2
    t.decimal "total_ext_price",              precision: 19, scale: 2
    t.boolean "active_schedule"
    t.boolean "lock_cost"
    t.boolean "lock_sell"
    t.string  "default_customer", limit: 255
    t.integer "rows_per_page"
    t.integer "type"
    t.string  "quote_number",     limit: 255
  end

  create_table "job_category", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.integer "job_icon"
    t.string  "description",   limit: 255
    t.string  "prod_category", limit: 255
    t.string  "prod_line",     limit: 255
  end

  create_table "job_change", id: :integer, force: :cascade do |t|
    t.string  "vendor_name",       limit: 255
    t.string  "ship_via",          limit: 255
    t.text    "internal_notes"
    t.integer "vendor_id"
    t.string  "transaction_id",    limit: 255
    t.decimal "total_cost",                    precision: 19, scale: 2
    t.text    "shipping_notes"
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.decimal "total_sell",                    precision: 19, scale: 2
    t.string  "freight_terms",     limit: 255
    t.integer "bom_id"
    t.integer "status"
    t.boolean "original_po"
    t.integer "pending_count"
    t.integer "address_id"
    t.string  "document_fk",       limit: 255
    t.integer "customer_fk"
    t.boolean "releasematerial"
    t.integer "processing_status"
    t.string  "batch_id",          limit: 255
    t.date    "external_date"
    t.index ["customer_fk"], name: "job_change_customer_fk_index", using: :btree
  end

  create_table "job_change_item", id: :bigint, force: :cascade do |t|
    t.integer "transaction_qty"
    t.string  "new_description",    limit: 255
    t.integer "status"
    t.decimal "new_price",                      precision: 19, scale: 3
    t.decimal "new_cost",                       precision: 19, scale: 3
    t.string  "new_stock_pn"
    t.integer "new_vendor"
    t.decimal "new_extended_cost",              precision: 19, scale: 2
    t.decimal "new_extended_price",             precision: 19, scale: 2
    t.string  "new_fixture_type",   limit: 255
    t.string  "old_description",    limit: 255
    t.integer "old_status"
    t.integer "old_quantity"
    t.boolean "extend"
    t.decimal "old_cost",                       precision: 19, scale: 3
    t.string  "old_fixture_type",   limit: 255
    t.decimal "old_price",                      precision: 19, scale: 3
    t.decimal "old_extended_cost",              precision: 19, scale: 2
    t.decimal "old_extended_price",             precision: 19, scale: 2
    t.bigint  "fixture_fk"
    t.integer "order_fk"
    t.bigint  "component_fk"
    t.integer "transaction_fkey"
    t.string  "qty_uom",            limit: 255
    t.string  "old_qty_uom",        limit: 255
    t.integer "um_qty"
    t.integer "old_um_qty"
    t.string  "pricing_uom",        limit: 255
    t.string  "old_pricing_uom",    limit: 255
    t.integer "price_per_qty"
    t.integer "old_price_per_qty"
    t.integer "hfr_quantity"
    t.index ["component_fk"], name: "job_change_item_component_fk_index", using: :btree
    t.index ["fixture_fk"], name: "job_change_item_fixture_fk_index", using: :btree
    t.index ["order_fk"], name: "job_change_item_order_fk_index", using: :btree
  end

  create_table "job_change_order_log", id: :integer, force: :cascade do |t|
    t.text    "comment",                   null: false
    t.date    "date",                      null: false
    t.time    "time",                      null: false
    t.string  "user_id",        limit: 15, null: false
    t.integer "cust_change_fk",            null: false
  end

  create_table "job_competitor", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
  end

  create_table "job_component", primary_key: "fixture_id", id: :bigint, force: :cascade do |t|
    t.string   "description",           limit: 255
    t.integer  "quantity",                          null: false
    t.string   "stock_pn",                          null: false
    t.string   "matrix_cell",           limit: 255
    t.datetime "create_stamp",                      null: false
    t.string   "uom",                   limit: 255
    t.string   "submittal_status",      limit: 255
    t.boolean  "has_notes"
    t.string   "addl_desc",             limit: 255
    t.bigint   "customer_item_fk"
    t.bigint   "total_id"
    t.bigint   "vendor_item_fk"
    t.bigint   "fixture_fk"
    t.date     "update_stamp"
    t.string   "qty_uom",               limit: 255
    t.integer  "um_qty"
    t.string   "pricing_uom",           limit: 255
    t.integer  "price_per_qty"
    t.boolean  "ns_stock"
    t.string   "order_number",          limit: 255
    t.string   "classification",        limit: 255
    t.string   "prod_cat",              limit: 255
    t.string   "prod_line",             limit: 255
    t.boolean  "draft_item",                        null: false
    t.integer  "vendor_pricing_vendor",             null: false
    t.string   "customer_po",           limit: 255
    t.index ["customer_item_fk"], name: "job_component_customer_item_fk_index", using: :btree
    t.index ["fixture_fk"], name: "job_component_fixture_fk_index", using: :btree
    t.index ["vendor_item_fk"], name: "job_component_vendor_item_fk_index", using: :btree
  end

  create_table "job_contact", id: :integer, force: :cascade do |t|
    t.integer "contact_id"
    t.string  "contact_method", limit: 255
    t.integer "address_fk"
  end

  create_table "job_cost", id: :bigint, force: :cascade do |t|
    t.decimal "cost",                             precision: 19, scale: 3,                 null: false
    t.string  "formula",              limit: 255
    t.integer "vendor_id"
    t.decimal "extended_cost",                    precision: 19, scale: 2
    t.decimal "received_cost",                    precision: 19, scale: 2, default: "0.0", null: false
    t.decimal "returned_cost",                    precision: 19, scale: 2, default: "0.0", null: false
    t.decimal "received_return_cost",             precision: 19, scale: 2, default: "0.0", null: false
  end

  create_table "job_cust_change", id: :integer, force: :cascade do |t|
    t.integer  "status"
    t.integer  "customer_id"
    t.text     "internal_notes"
    t.string   "change_number",     limit: 255
    t.text     "reason_for_change"
    t.decimal  "total_cost",                    precision: 19, scale: 2
    t.datetime "follow_up_date"
    t.date     "transaction_date"
    t.time     "transaction_time"
    t.string   "po_number",         limit: 255
    t.decimal  "total_sell",                    precision: 19, scale: 2
    t.integer  "bom_id"
    t.text     "approval_notes"
    t.string   "approved_by",       limit: 255
    t.string   "initiated_by",      limit: 255
    t.boolean  "supress_customer"
    t.boolean  "supress_vendor"
    t.string   "created_by",        limit: 255
    t.boolean  "new_customer_po"
    t.boolean  "internal_change"
    t.string   "document_fk",       limit: 255
    t.integer  "processing_status"
    t.boolean  "freight_in_exempt"
  end

  create_table "job_customer", id: :integer, force: :cascade do |t|
    t.string  "name",                  limit: 255, null: false
    t.integer "job_id"
    t.integer "actor_id"
    t.string  "inside_sales",          limit: 255
    t.string  "outside_sales",         limit: 255
    t.string  "sales_source",          limit: 255
    t.string  "credit_br",             limit: 255
    t.string  "ship_to"
    t.string  "customer_po",           limit: 255
    t.string  "dflt_cfrt_terms",       limit: 255
    t.string  "dflt_vfrt_terms",       limit: 255
    t.boolean "freight_in_exempt"
    t.string  "ship_from_br",          limit: 255
    t.string  "ship_via_cust",         limit: 255
    t.string  "ship_via_vend",         limit: 255
    t.text    "shipping_instr"
    t.boolean "override_address"
    t.integer "shipaddress_fk"
    t.integer "address_fk"
    t.integer "main_contact_fk"
    t.date    "awarded_date"
    t.boolean "use_alternate_address"
    t.integer "altaddress_fk"
    t.string  "ship_via_cust_direct",  limit: 255
    t.integer "alt_contact_fk"
    t.string  "shipto_index",          limit: 255
    t.string  "tax_code",              limit: 255
    t.index ["address_fk"], name: "job_customer_address_fk_index", using: :btree
    t.index ["altaddress_fk"], name: "job_customer_altaddress_fk_index", using: :btree
    t.index ["inside_sales"], name: "job_customer_inside_sales", using: :btree
    t.index ["job_id"], name: "job_customer_job_id", using: :btree
    t.index ["outside_sales"], name: "job_customer_outside_sales", using: :btree
    t.index ["shipaddress_fk"], name: "job_customer_shipaddress_fk_index", using: :btree
  end

  create_table "job_customer_job_contact", id: false, force: :cascade do |t|
    t.integer "job_customer_id",      null: false
    t.integer "alternatecontacts_id", null: false
    t.index ["alternatecontacts_id"], name: "job_customer_job_contact_alternatecontacts_id_key", unique: true, using: :btree
  end

  create_table "job_document_defaults", id: :string, limit: 255, force: :cascade do |t|
    t.boolean "bid_print_style"
    t.boolean "bid_hide_comp"
    t.boolean "bid_roll_comp"
    t.boolean "bid_hide_ext_pricing"
    t.boolean "bid_hide_vendor"
    t.integer "bid_ship_instr"
    t.boolean "rfq_only_vendor_items"
    t.boolean "rfq_exclude_stock"
    t.integer "rfq_vend_instr"
    t.boolean "sub_for_approval"
    t.boolean "sub_hide_comp"
    t.boolean "res_show_line_info"
    t.boolean "res_show_cost"
    t.integer "hfr_vend_instr"
    t.boolean "rel_show_cost"
    t.integer "rel_vend_instr"
    t.boolean "cust_disp_changed"
    t.integer "cust_ship_instr"
    t.boolean "vend_orig_po"
    t.boolean "vend_release_now"
    t.boolean "vend_disp_changed"
    t.integer "vend_instr"
    t.boolean "bid_subtotal_comp",                      default: false
    t.boolean "res_subtotal_comp",                      default: false
    t.boolean "hfr_subtotal_comp",                      default: false
    t.boolean "rel_subtotal_comp",                      default: false
    t.integer "hfr_return_instr"
    t.boolean "cust_change_show_lot_line"
    t.boolean "hfr_show_lot_line"
    t.boolean "rel_show_lot_line"
    t.boolean "res_show_lot_line"
    t.integer "vend_change_new_po_form"
    t.boolean "vend_change_show_lot_line"
    t.integer "bid_alternative_total_type"
    t.boolean "sub_hide_qty"
    t.boolean "sub_hide_vendor"
    t.boolean "bid_hide_comp_qty"
    t.boolean "rep_print_open_qty"
    t.boolean "rep_zero_qty"
    t.boolean "vend_neg_use_hfr_qty"
    t.boolean "bid_hide_zero_qty"
    t.boolean "rel_show_billto_addr"
    t.boolean "rfq_show_billto_addr"
    t.boolean "vend_show_billto_addr"
    t.boolean "cust_disp_change_value"
    t.boolean "bid_hide_totals"
    t.string  "ack_title",                  limit: 255
    t.integer "bid_address_opt"
    t.boolean "bid_show_pm"
    t.string  "bid_title",                  limit: 255
    t.string  "cust_title",                 limit: 255
    t.string  "hfr_title",                  limit: 255
    t.string  "rel_title",                  limit: 255
    t.string  "rep_title",                  limit: 255
    t.string  "res_title",                  limit: 255
    t.string  "ret_title",                  limit: 255
    t.string  "rfq_title",                  limit: 255
    t.string  "sub_title",                  limit: 255
    t.string  "vend_title",                 limit: 255
    t.boolean "bid_only_items_on_order"
  end

  create_table "job_document_log", primary_key: "document_name", id: :string, limit: 255, force: :cascade do |t|
    t.integer "transaction_type"
    t.string  "user_name",          limit: 255
    t.integer "job_id"
    t.string  "archive_path",       limit: 255
    t.boolean "customer_document"
    t.text    "xml_document"
    t.string  "po_number",          limit: 255
    t.date    "generated_date"
    t.time    "generated_time"
    t.string  "recipient_name",     limit: 255
    t.string  "recipient_id",       limit: 255
    t.integer "document_action"
    t.text    "transaction_detail"
    t.string  "transaction_prefix", limit: 255
    t.string  "order_number",       limit: 255
    t.integer "faxstatus"
    t.text    "notes"
    t.integer "resend_number",                  null: false
    t.index ["job_id"], name: "job_document_log_job_id_index", using: :btree
  end

  create_table "job_document_props", primary_key: "document_definition", id: :string, limit: 255, force: :cascade do |t|
    t.string  "password",              limit: 255
    t.string  "user_name",             limit: 255
    t.string  "forms_path",            limit: 255
    t.string  "pdf_path",              limit: 255
    t.string  "archive_path",          limit: 255
    t.integer "archive_method"
    t.string  "email_server",          limit: 255
    t.string  "fax_server",            limit: 255
    t.string  "fax_prefix",            limit: 255
    t.string  "logo_path",             limit: 255
    t.string  "webserviceurl",         limit: 255
    t.string  "formscapexmlpath",      limit: 255
    t.string  "email_from",            limit: 255
    t.boolean "form_defaults_pricebr"
  end

  create_table "job_fee_change", id: :integer, force: :cascade do |t|
    t.integer "rep_id"
    t.decimal "fee_change",                    precision: 19, scale: 2
    t.integer "status"
    t.string  "name",              limit: 255
    t.string  "purchase_order",    limit: 255
    t.integer "bom_id"
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.integer "customerchange_id"
    t.integer "fee_id"
    t.integer "processing_status"
  end

  create_table "job_fees", id: :integer, force: :cascade do |t|
    t.decimal "fee",                          precision: 19, scale: 2
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.decimal "received_amount",              precision: 19, scale: 2
    t.string  "purchase_order",   limit: 255
    t.integer "bom_id"
    t.decimal "fee_change",                   precision: 19, scale: 2
  end

  create_table "job_fixture", primary_key: "fixture_id", id: :bigint, force: :cascade do |t|
    t.string   "description",           limit: 255
    t.integer  "quantity",                          null: false
    t.string   "stock_pn",                          null: false
    t.string   "matrix_cell",           limit: 255
    t.datetime "create_stamp",                      null: false
    t.string   "uom",                   limit: 255
    t.string   "submittal_status",      limit: 255
    t.boolean  "has_notes"
    t.string   "addl_desc",             limit: 255
    t.string   "fixture_type",          limit: 255
    t.string   "sort_order",            limit: 255
    t.bigint   "vendor_item_fk"
    t.bigint   "customer_item_fk"
    t.integer  "bom_fk"
    t.bigint   "total_id"
    t.date     "update_stamp"
    t.string   "qty_uom",               limit: 255
    t.integer  "um_qty"
    t.string   "pricing_uom",           limit: 255
    t.integer  "price_per_qty"
    t.boolean  "ns_stock"
    t.string   "order_number",          limit: 255
    t.string   "prod_cat",              limit: 255
    t.string   "prod_line",             limit: 255
    t.boolean  "draft_item",                        null: false
    t.integer  "vendor_pricing_vendor",             null: false
    t.string   "customer_po",           limit: 255
    t.index ["bom_fk"], name: "job_fixture_bom_fk_index", using: :btree
    t.index ["customer_item_fk"], name: "job_fixture_customer_item_fk_index", using: :btree
    t.index ["vendor_item_fk"], name: "job_fixture_vendor_item_fk_index", using: :btree
  end

  create_table "job_form_notes", id: :integer, force: :cascade do |t|
    t.string  "source",    limit: 255, null: false
    t.integer "form_id"
    t.integer "form_area"
    t.string  "branch",    limit: 255
    t.string  "job_type",  limit: 255
  end

  create_table "job_gl_debit", id: :integer, force: :cascade do |t|
    t.integer "bom_id",                                                null: false
    t.string  "comment",          limit: 256
    t.string  "description",      limit: 256
    t.string  "order_by",         limit: 256
    t.string  "payable_id",       limit: 256,                          null: false
    t.string  "stock_pn",         limit: 256,                          null: false
    t.decimal "total_sell",                   precision: 19, scale: 2, null: false
    t.date    "transaction_date",                                      null: false
    t.string  "transaction_id",   limit: 256,                          null: false
    t.time    "transaction_time",                                      null: false
    t.integer "vendor_id",                                             null: false
    t.string  "vendor_name",      limit: 256,                          null: false
  end

  create_table "job_ledger", primary_key: "job_id", id: :integer, force: :cascade do |t|
    t.integer "bom_id"
    t.decimal "original_cost",    precision: 19, scale: 2
    t.decimal "original_sell",    precision: 19, scale: 2
    t.decimal "original_margin",  precision: 19, scale: 6
    t.decimal "change_cost",      precision: 19, scale: 2
    t.decimal "change_sell",      precision: 19, scale: 2
    t.decimal "change_margin",    precision: 19, scale: 6
    t.decimal "current_cost",     precision: 19, scale: 2
    t.decimal "current_sell",     precision: 19, scale: 2
    t.decimal "current_margin",   precision: 19, scale: 6
    t.decimal "percent_complete", precision: 19, scale: 2, default: "0.0", null: false
    t.decimal "ar_billed",        precision: 19, scale: 2
    t.decimal "ap_billed",        precision: 19, scale: 2
    t.decimal "total_job_cost",   precision: 19, scale: 2, default: "0.0", null: false
    t.decimal "bidding_sell",     precision: 19, scale: 2, default: "0.0", null: false
  end

  create_table "job_line_status", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.string "action", limit: 255
  end

  create_table "job_logos", primary_key: ["classifier", "type"], force: :cascade do |t|
    t.string  "classifier",  limit: 255, null: false
    t.integer "type",                    null: false
    t.string  "path",        limit: 255
    t.string  "document_fk", limit: 255
  end

  create_table "job_lost_reason", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.string "description", limit: 255
  end

  create_table "job_note_entry", primary_key: ["note_id", "note_key"], force: :cascade do |t|
    t.integer "note_id",              null: false
    t.string  "note_key", limit: 255, null: false
  end

  create_table "job_notes", id: :integer, force: :cascade do |t|
    t.text    "content"
    t.integer "source"
    t.string  "user_id",      limit: 255
    t.date    "create_date"
    t.boolean "createtask",               null: false
    t.integer "doc_area"
    t.integer "display_type"
  end

  create_table "job_opened_job", primary_key: "job_id", id: :integer, force: :cascade do |t|
    t.string "sessionid", limit: 255
  end

  create_table "job_order", id: :integer, force: :cascade do |t|
    t.string  "vendor_name",      limit: 255
    t.string  "ship_via",         limit: 255
    t.text    "internal_notes"
    t.integer "vendor_id"
    t.string  "hold_id",          limit: 255
    t.decimal "total_cost",                   precision: 19, scale: 2
    t.text    "shipping_notes"
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.decimal "total_sell",                   precision: 19, scale: 2
    t.string  "freight_terms",    limit: 255
    t.integer "bom_id"
    t.integer "source"
    t.date    "ship_date"
    t.date    "reserve_date"
    t.string  "po_num",           limit: 255
    t.integer "address_id"
    t.integer "vendorquote_id"
    t.string  "document_fk",      limit: 255
    t.boolean "original_po",                                           null: false
    t.string  "batch_id",         limit: 255
    t.date    "external_date"
    t.index ["bom_id"], name: "job_order_bom_id_index", using: :btree
  end

  create_table "job_overrides", primary_key: "user_id", id: :string, limit: 255, force: :cascade do |t|
    t.string  "ship_branch",     limit: 255
    t.string  "price_branch",    limit: 255
    t.string  "sales_source",    limit: 255
    t.boolean "use_margin"
    t.decimal "default_percent",             precision: 19, scale: 2
    t.string  "default_printer", limit: 255
    t.string  "job_type",        limit: 255
  end

  create_table "job_printers", id: :integer, force: :cascade do |t|
    t.string "path",        limit: 255
    t.string "name",        limit: 255
    t.string "document_fk", limit: 255
  end

  create_table "job_profile", primary_key: "user_id", id: :string, limit: 255, force: :cascade do |t|
    t.string  "skin",             limit: 255
    t.string  "home_page",        limit: 255
    t.string  "locale",           limit: 255
    t.string  "email_address",    limit: 255
    t.string  "text_server",      limit: 255
    t.integer "default_followup"
    t.string  "phonenumber",      limit: 255
    t.string  "cc_address",       limit: 255
    t.string  "bcc_address",      limit: 255
    t.string  "contact_number",   limit: 255
    t.string  "form_signature",   limit: 255
    t.string  "time_zone",        limit: 255
    t.string  "alt_user_id",      limit: 255
    t.string  "fax_number",       limit: 255
  end

  create_table "job_project", id: :integer, force: :cascade do |t|
    t.string   "name",                limit: 255, null: false
    t.string   "state",               limit: 255
    t.integer  "optlock"
    t.string   "job_cat",             limit: 255
    t.string   "status",              limit: 255
    t.string   "city",                limit: 255
    t.string   "inside_sales",        limit: 255
    t.string   "outside_sales",       limit: 255
    t.date     "follow_up_date"
    t.date     "rebid_date"
    t.string   "bidder",              limit: 255
    t.string   "project_manager",     limit: 255
    t.date     "completion_date"
    t.string   "next_action",         limit: 255
    t.string   "architect",           limit: 255
    t.string   "engineer",            limit: 255
    t.boolean  "no_bid"
    t.string   "job_lost_reason",     limit: 255
    t.boolean  "take_off"
    t.boolean  "approval_req"
    t.datetime "created_date"
    t.integer  "awardedcustomer_id"
    t.integer  "awardedschedule_id"
    t.boolean  "job_lost"
    t.string   "credit_br",           limit: 255
    t.string   "ship_from_br",        limit: 255
    t.string   "job_lost_competitor", limit: 255
    t.string   "job_project_type",    limit: 255
    t.string   "job_win_confidence",  limit: 255
    t.integer  "pgm_version"
    t.datetime "bid_date_time",                   null: false
    t.string   "batch_id",            limit: 255
    t.index ["awardedcustomer_id"], name: "job_project_awardedcustomer_id_index", using: :btree
    t.index ["bidder"], name: "job_project_bidder", using: :btree
    t.index ["project_manager"], name: "job_project_project_manager", using: :btree
  end

  create_table "job_project_type", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.string "description", limit: 255
  end

  create_table "job_quote", id: :bigint, force: :cascade do |t|
    t.decimal "price",                 precision: 19, scale: 3
    t.decimal "extended_price",        precision: 19, scale: 2
    t.decimal "margin",                precision: 19, scale: 6
    t.decimal "markup",                precision: 19, scale: 6
    t.decimal "returned_price",        precision: 19, scale: 2
    t.decimal "received_price",        precision: 19, scale: 2, default: "0.0", null: false
    t.decimal "received_return_price", precision: 19, scale: 2, default: "0.0", null: false
  end

  create_table "job_receive", id: :integer, force: :cascade do |t|
    t.string  "vendor_name",      limit: 255
    t.integer "vendor_id"
    t.string  "transaction_id",   limit: 255
    t.string  "payable_id",       limit: 255
    t.decimal "total_cost",                   precision: 19, scale: 2
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.decimal "total_sell",                   precision: 19, scale: 2
    t.decimal "reconcile_amt",                precision: 19, scale: 2
    t.integer "bom_id"
    t.string  "fee_payable",      limit: 255
    t.integer "fee_fk"
    t.decimal "fee_amount",                   precision: 19, scale: 2
    t.index ["bom_id"], name: "job_receive_bom_id_index", using: :btree
  end

  create_table "job_receive_item", id: :bigint, force: :cascade do |t|
    t.integer "transaction_qty"
    t.decimal "sell",             precision: 19, scale: 2
    t.decimal "cost",             precision: 19, scale: 2
    t.bigint  "fixture_fk"
    t.integer "transaction_fkey"
    t.integer "order_fk"
    t.bigint  "component_fk"
    t.index ["component_fk"], name: "job_receive_item_component_fk_index", using: :btree
    t.index ["fixture_fk"], name: "job_receive_item_fixture_fk_index", using: :btree
    t.index ["order_fk"], name: "job_receive_item_order_fk_index", using: :btree
  end

  create_table "job_release", id: :integer, force: :cascade do |t|
    t.string  "vendor_name",      limit: 255
    t.string  "ship_via",         limit: 255
    t.text    "internal_notes"
    t.integer "vendor_id"
    t.string  "transaction_id",   limit: 255
    t.decimal "total_cost",                   precision: 19, scale: 2
    t.text    "shipping_notes"
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.decimal "total_sell",                   precision: 19, scale: 2
    t.string  "freight_terms",    limit: 255
    t.integer "bom_id"
    t.date    "external_date"
    t.string  "release_number",   limit: 255
    t.date    "internal_date"
    t.string  "truck_number",     limit: 255
    t.string  "document_fk",      limit: 255
    t.integer "address_id"
    t.string  "batch_id",         limit: 255
    t.index ["bom_id"], name: "job_release_bom_id_index", using: :btree
  end

  create_table "job_release_item", id: :bigint, force: :cascade do |t|
    t.integer "transaction_qty"
    t.bigint  "fixture_fk"
    t.bigint  "component_fk"
    t.integer "release_fk"
    t.integer "transaction_fkey"
    t.index ["component_fk"], name: "job_release_item_component_fk_index", using: :btree
    t.index ["fixture_fk"], name: "job_release_item_fixture_fk_index", using: :btree
    t.index ["release_fk"], name: "job_release_item_release_fk_index", using: :btree
  end

  create_table "job_report_users", id: :integer, force: :cascade do |t|
    t.string  "user_name",     limit: 255
    t.string  "email_address", limit: 255
    t.integer "report_fk"
  end

  create_table "job_reports", id: :integer, force: :cascade do |t|
    t.datetime "start_date",               null: false
    t.datetime "end_date",                 null: false
    t.string   "title",        limit: 255
    t.string   "user_id",      limit: 255
    t.integer  "recurrance"
    t.integer  "week_day"
    t.text     "parameters"
    t.string   "service_name", limit: 255
    t.integer  "job_id"
    t.integer  "expire"
  end

  create_table "job_return", id: :integer, force: :cascade do |t|
    t.string  "vendor_name",        limit: 255
    t.string  "ship_via",           limit: 255
    t.text    "internal_notes"
    t.integer "vendor_id"
    t.string  "transaction_id",     limit: 255
    t.decimal "total_cost",                     precision: 19, scale: 2
    t.text    "shipping_notes"
    t.date    "transaction_date"
    t.time    "transaction_time"
    t.decimal "total_sell",                     precision: 19, scale: 2
    t.string  "freight_terms",      limit: 255
    t.integer "bom_id"
    t.string  "reason_return",      limit: 255
    t.string  "return_oid",         limit: 255
    t.decimal "misc_amount",                    precision: 19, scale: 2
    t.integer "address_id"
    t.string  "document_fk",        limit: 255
    t.integer "transaction_type"
    t.decimal "misc_credit_amount",             precision: 19, scale: 2
    t.string  "batch_id",           limit: 255
    t.date    "external_date"
  end

  create_table "job_return_item", id: :bigint, force: :cascade do |t|
    t.integer "transaction_qty"
    t.integer "order_fk"
    t.bigint  "component_fk"
    t.bigint  "fixture_fk"
    t.integer "transaction_fkey"
    t.decimal "return_cost",                  precision: 19, scale: 2
    t.decimal "return_sell",                  precision: 19, scale: 2
    t.string  "stock_desc",       limit: 255
    t.string  "stock_pn",         limit: 255
    t.string  "stock_prodcat",    limit: 255
    t.string  "stock_prodline",   limit: 255
  end

  create_table "job_shipment", id: :integer, force: :cascade do |t|
    t.integer  "quantity"
    t.date     "ship_date"
    t.datetime "follow_up_date"
    t.date     "shipment_date"
    t.string   "shipper",          limit: 255
    t.string   "tracking_number",  limit: 255
    t.string   "external_note",    limit: 255
    t.string   "internal_note",    limit: 255
    t.bigint   "component_fk"
    t.bigint   "fixture_fk"
    t.string   "country_origin",   limit: 255
    t.string   "htc_code",         limit: 255
    t.date     "required_on_site"
    t.date     "required_release"
    t.string   "erp_ship_id",      limit: 255
    t.index ["component_fk"], name: "job_shipment_component_fk_index", using: :btree
    t.index ["fixture_fk"], name: "job_shipment_fixture_fk_index", using: :btree
  end

  create_table "job_specific_notes", id: :integer, force: :cascade do |t|
    t.integer "type"
    t.text    "content", null: false
    t.integer "job_id"
    t.index ["job_id"], name: "job_specific_notes_job_id_index", using: :btree
  end

  create_table "job_status", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.string  "description", limit: 255
    t.boolean "inactive"
    t.integer "event"
  end

  create_table "job_tasks", primary_key: ["id", "source"], force: :cascade do |t|
    t.integer  "id",                         null: false
    t.integer  "source",                     null: false
    t.integer  "priority"
    t.date     "start_date"
    t.string   "description",    limit: 255
    t.string   "subject",        limit: 255
    t.string   "status",         limit: 255
    t.boolean  "completed"
    t.binary   "note"
    t.string   "user_id",        limit: 255
    t.integer  "job_id"
    t.date     "due_date"
    t.boolean  "reminder"
    t.datetime "reminder_date"
    t.integer  "reminder_time"
    t.string   "email_address",  limit: 255
    t.integer  "follow_up_type"
    t.string   "text_server",    limit: 255
  end

  create_table "job_tasks_assignedusers", id: false, force: :cascade do |t|
    t.integer "job_tasks_id",                 null: false
    t.integer "job_tasks_source",             null: false
    t.string  "element",          limit: 255
  end

  create_table "job_totals", id: :bigint, force: :cascade do |t|
    t.integer "return_qty"
    t.integer "change_qty"
    t.integer "pending_qty"
    t.integer "release_qty"
    t.integer "receive_qty"
    t.integer "receive_return_qty"
  end

  create_table "job_transaction_log", id: :integer, force: :cascade do |t|
    t.integer  "transaction_type"
    t.string   "action",           limit: 255
    t.bigint   "line_item_key"
    t.boolean  "component"
    t.datetime "transaction_date"
    t.integer  "transaction_qty"
    t.integer  "order_key"
    t.string   "document_key",     limit: 255
  end

  create_table "job_user_preferences", id: :integer, force: :cascade do |t|
    t.string "key",     limit: 255
    t.string "user_id", limit: 255
    t.text   "value"
  end

  create_table "job_vendor", id: :integer, force: :cascade do |t|
    t.string  "name",              limit: 255, null: false
    t.integer "job_id"
    t.integer "actor_id"
    t.string  "vendor_short_name", limit: 255
    t.string  "frieght_terms",     limit: 255
    t.boolean "rep"
    t.string  "next_po",           limit: 255
    t.string  "ship_from_br",      limit: 255
    t.text    "shipping_instr"
    t.string  "ship_via",          limit: 255
    t.integer "ship_from"
    t.integer "address_fk"
    t.integer "shipaddress_fk"
    t.string  "quote_number",      limit: 255
    t.string  "payment_terms",     limit: 255
    t.integer "vendor_type"
    t.index ["address_fk"], name: "job_vendor_address_fk_index", using: :btree
    t.index ["job_id"], name: "job_vendor_job_id_index", using: :btree
    t.index ["shipaddress_fk"], name: "job_vendor_shipaddress_fk_index", using: :btree
  end

  create_table "job_vendor_pricing", id: :bigint, force: :cascade do |t|
    t.integer "bom_id"
    t.decimal "cost",                     precision: 19, scale: 3, null: false
    t.string  "formula",      limit: 255
    t.integer "vendor_fk"
    t.bigint  "component_fk"
    t.bigint  "fixture_fk"
  end

  create_table "job_win_confidence", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.string "description", limit: 255
  end

  create_table "task_assignedusers", id: false, force: :cascade do |t|
    t.integer "task_id",                   null: false
    t.integer "task_source",               null: false
    t.string  "assignedusers", limit: 255
  end

  add_foreign_key "job_actor", "job_project", column: "job_id", name: "fk56bd26f3d6b513aa"
  add_foreign_key "job_alternatives", "job_bom", column: "alt_bom_id", name: "fkea6f57a859861eb5"
  add_foreign_key "job_alternatives", "job_bom", column: "bom_id", name: "fkea6f57a8895b1b5f"
  add_foreign_key "job_bom", "job_project", column: "job_id", name: "fkaa50223ed6b513aa"
  add_foreign_key "job_change", "job_address", column: "address_id", name: "fk848f36727dab9cd6"
  add_foreign_key "job_change", "job_cust_change", column: "customer_fk", name: "fk848f3672d938bf24"
  add_foreign_key "job_change", "job_document_log", column: "document_fk", primary_key: "document_name", name: "fk848f367288edfc14"
  add_foreign_key "job_change_item", "job_change", column: "order_fk", name: "fkea7734c09323e436"
  add_foreign_key "job_change_item", "job_component", column: "component_fk", primary_key: "fixture_id", name: "fkea7734c0c82bfc64"
  add_foreign_key "job_change_item", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fkea7734c0724bd8e4"
  add_foreign_key "job_change_item", "job_transaction_log", column: "transaction_fkey", name: "fkea7734c06485c84c"
  add_foreign_key "job_change_order_log", "job_cust_change", column: "cust_change_fk", name: "fk794a4d4687ebf726"
  add_foreign_key "job_component", "job_cost", column: "vendor_item_fk", name: "fk6ba3eafbf51528e1"
  add_foreign_key "job_component", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fk6ba3eafb724bd8e4"
  add_foreign_key "job_component", "job_quote", column: "customer_item_fk", name: "fk6ba3eafb937633a1"
  add_foreign_key "job_component", "job_totals", column: "total_id", name: "fk6ba3eafb700f8171"
  add_foreign_key "job_contact", "job_address", column: "address_fk", name: "fk1a03599e7dab9c80", on_delete: :cascade
  add_foreign_key "job_cust_change", "job_document_log", column: "document_fk", primary_key: "document_name", name: "fk84285d9a88edfc14"
  add_foreign_key "job_customer", "job_address", column: "address_fk", name: "fk6c5bfa207dab9c80", on_delete: :cascade
  add_foreign_key "job_customer", "job_address", column: "altaddress_fk", name: "fk6c5bfa2093e3d6e9"
  add_foreign_key "job_customer", "job_address", column: "shipaddress_fk", name: "fk6c5bfa202572dbbc", on_delete: :cascade
  add_foreign_key "job_customer", "job_contact", column: "alt_contact_fk", name: "fk6c5bfa20a4e00556", on_delete: :cascade
  add_foreign_key "job_customer", "job_contact", column: "main_contact_fk", name: "fk6c5bfa20ed994f46", on_delete: :cascade
  add_foreign_key "job_customer", "job_project", column: "job_id", name: "fk6c5bfa20d6b513aa"
  add_foreign_key "job_customer_job_contact", "job_contact", column: "alternatecontacts_id", name: "fk758581ffdb679f89"
  add_foreign_key "job_customer_job_contact", "job_customer", name: "fk758581ff2cdc774"
  add_foreign_key "job_fee_change", "job_cust_change", column: "customerchange_id", name: "fk43e5944bd1633c4a"
  add_foreign_key "job_fee_change", "job_fees", column: "fee_id", name: "fk43e5944bf65080fa"
  add_foreign_key "job_fixture", "job_bom", column: "bom_fk", name: "fkaf062f87895b1b09"
  add_foreign_key "job_fixture", "job_cost", column: "vendor_item_fk", name: "fkaf062f87f51528e1"
  add_foreign_key "job_fixture", "job_quote", column: "customer_item_fk", name: "fkaf062f87937633a1"
  add_foreign_key "job_fixture", "job_totals", column: "total_id", name: "fkaf062f87700f8171"
  add_foreign_key "job_logos", "job_document_props", column: "document_fk", primary_key: "document_definition", name: "fk575d6d264ae88f55"
  add_foreign_key "job_opened_job", "job_active_session", column: "sessionid", primary_key: "sessionid", name: "fk561928a93ddade7a"
  add_foreign_key "job_order", "job_address", column: "address_id", name: "fk5789044c7dab9cd6"
  add_foreign_key "job_order", "job_bom", column: "bom_id", name: "fk5789044c895b1b5f", on_delete: :cascade
  add_foreign_key "job_order", "job_document_log", column: "document_fk", primary_key: "document_name", name: "fk5789044c88edfc14"
  add_foreign_key "job_order", "job_vendor", column: "vendorquote_id", name: "fk5789044c36056b6"
  add_foreign_key "job_printers", "job_document_props", column: "document_fk", primary_key: "document_definition", name: "fk2b5b5db4ae88f55"
  add_foreign_key "job_profile", "job_overrides", column: "user_id", primary_key: "user_id", name: "fkcedabf2781425083"
  add_foreign_key "job_project", "job_bom", column: "awardedschedule_id", name: "fkcedc8097b23f71ec"
  add_foreign_key "job_project", "job_customer", column: "awardedcustomer_id", name: "fkcedc809781a4afba"
  add_foreign_key "job_receive", "job_fees", column: "fee_fk", name: "fk21cea861f65080a4"
  add_foreign_key "job_receive_item", "job_component", column: "component_fk", primary_key: "fixture_id", name: "fk280ca031c82bfc64"
  add_foreign_key "job_receive_item", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fk280ca031724bd8e4"
  add_foreign_key "job_receive_item", "job_receive", column: "order_fk", name: "fk280ca03170086d62"
  add_foreign_key "job_receive_item", "job_transaction_log", column: "transaction_fkey", name: "fk280ca0316485c84c"
  add_foreign_key "job_release", "job_address", column: "address_id", name: "fk224d5d857dab9cd6"
  add_foreign_key "job_release", "job_document_log", column: "document_fk", primary_key: "document_name", name: "fk224d5d8588edfc14"
  add_foreign_key "job_release_item", "job_component", column: "component_fk", primary_key: "fixture_id", name: "fke0e5818dc82bfc64"
  add_foreign_key "job_release_item", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fke0e5818d724bd8e4"
  add_foreign_key "job_release_item", "job_release", column: "release_fk", name: "fke0e5818d8d1c5651"
  add_foreign_key "job_release_item", "job_transaction_log", column: "transaction_fkey", name: "fke0e5818d6485c84c"
  add_foreign_key "job_report_users", "job_reports", column: "report_fk", name: "fk8e8f187fa3098749"
  add_foreign_key "job_return", "job_address", column: "address_id", name: "fk9e065ff27dab9cd6"
  add_foreign_key "job_return", "job_document_log", column: "document_fk", primary_key: "document_name", name: "fk9e065ff288edfc14"
  add_foreign_key "job_return_item", "job_component", column: "component_fk", primary_key: "fixture_id", name: "fkf47dfb40c82bfc64"
  add_foreign_key "job_return_item", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fkf47dfb40724bd8e4"
  add_foreign_key "job_return_item", "job_return", column: "order_fk", name: "fkf47dfb40ac9b0db6"
  add_foreign_key "job_return_item", "job_transaction_log", column: "transaction_fkey", name: "fkf47dfb406485c84c"
  add_foreign_key "job_shipment", "job_component", column: "component_fk", primary_key: "fixture_id", name: "fk2973ebdcc82bfc64"
  add_foreign_key "job_shipment", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fk2973ebdc724bd8e4"
  add_foreign_key "job_specific_notes", "job_project", column: "job_id", name: "fk7bf4ae36d6b513aa"
  add_foreign_key "job_tasks_assignedusers", "job_tasks", column: "job_tasks_id", name: "fkf5b7e66796d0bf19"
  add_foreign_key "job_user_preferences", "job_profile", column: "user_id", primary_key: "user_id", name: "fk5e60e8c684f05110"
  add_foreign_key "job_vendor", "job_address", column: "address_fk", name: "fka4d6c80a7dab9c80", on_delete: :cascade
  add_foreign_key "job_vendor", "job_address", column: "shipaddress_fk", name: "fka4d6c80a2572dbbc"
  add_foreign_key "job_vendor", "job_project", column: "job_id", name: "fka4d6c80ad6b513aa"
  add_foreign_key "job_vendor_pricing", "job_component", column: "component_fk", primary_key: "fixture_id", name: "fk2a036491c82bfc64"
  add_foreign_key "job_vendor_pricing", "job_fixture", column: "fixture_fk", primary_key: "fixture_id", name: "fk2a036491724bd8e4"
  add_foreign_key "job_vendor_pricing", "job_vendor", column: "vendor_fk", name: "vendor_fk_constraint"
  add_foreign_key "task_assignedusers", "job_tasks", column: "task_id", name: "fk86bb37c07bb51c67"
end
