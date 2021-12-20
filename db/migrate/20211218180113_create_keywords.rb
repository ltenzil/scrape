class CreateKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :keywords do |t|
      t.string :value, null: false, index: true
      t.bigint :hits, default: 0
      t.string :stats

      t.timestamps
    end
  end
end
