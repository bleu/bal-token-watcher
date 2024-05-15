class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table "tokens", id: :text, force: :cascade do |t|
      t.text "name", null: false
      t.binary "address", null: false
      t.text "symbol", null: false
      t.integer "decimals", null: false
      t.integer "chainId", null: false
    end
  end
end
