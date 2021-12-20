class CreateUserKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :user_keywords do |t|
      t.references :user, null: false, foreign_key: true
      t.references :keyword, null: false, foreign_key: true

      t.timestamps
    end
  end
end
