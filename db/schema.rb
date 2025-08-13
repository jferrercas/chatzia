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

ActiveRecord::Schema[8.0].define(version: 2025_08_13_091000) do
  create_table "agentes", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.string "channels"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "status"], name: "index_agentes_on_user_id_and_status"
    t.index ["user_id"], name: "index_agentes_on_user_id"
  end

  create_table "conversacions", force: :cascade do |t|
    t.integer "agente_id", null: false
    t.integer "duracion"
    t.text "resumen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agente_id", "created_at"], name: "index_conversacions_on_agente_id_and_created_at"
    t.index ["agente_id"], name: "index_conversacions_on_agente_id"
    t.index ["created_at"], name: "index_conversacions_on_created_at"
  end

  create_table "mensajes", force: :cascade do |t|
    t.text "contenido"
    t.integer "conversacion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversacion_id", "created_at"], name: "index_mensajes_on_conversacion_id_and_created_at"
    t.index ["conversacion_id"], name: "index_mensajes_on_conversacion_id"
    t.index ["created_at"], name: "index_mensajes_on_created_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_sessions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "agentes", "users"
  add_foreign_key "conversacions", "agentes"
  add_foreign_key "mensajes", "conversacions"
  add_foreign_key "sessions", "users"
end
