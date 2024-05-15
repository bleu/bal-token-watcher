class CreateSwaps < ActiveRecord::Migration[7.1]
  def change
    create_table "swaps", id: :text, force: :cascade do |t|
      t.binary "tokenIn", null: false
      t.binary "tokenOut", null: false
      t.binary "poolId", null: false
      t.decimal "amountIn", precision: 78, null: false
      t.decimal "amountOut", precision: 78, null: false
      t.integer "chainId", null: false
    end
  end
end
