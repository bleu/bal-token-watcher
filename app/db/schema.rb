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

ActiveRecord::Schema[7.1].define(version: 2024_05_14_023515) do
  create_schema "ponder"
  create_schema "ponder_sync"

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "swaps", id: :text, force: :cascade do |t|
    t.binary "tokenIn", null: false
    t.binary "tokenOut", null: false
    t.binary "poolId", null: false
    t.decimal "amountIn", precision: 78, null: false
    t.decimal "amountOut", precision: 78, null: false
    t.integer "chainId", null: false
  end

  create_table "tokens", id: :text, force: :cascade do |t|
    t.text "name", null: false
    t.binary "address", null: false
    t.text "symbol", null: false
    t.integer "decimals", null: false
    t.integer "chainId", null: false
  end

end
