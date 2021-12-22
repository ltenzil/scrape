class AddResponseToKeyword < ActiveRecord::Migration[6.0]
  def change
    add_column :keywords, :response, :jsonb, default: {}
  end
end
