class AddUserToKeyword < ActiveRecord::Migration[6.0]
  def change
    add_reference :keywords, :user, index: true
  end
end
