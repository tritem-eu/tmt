class AddVisitedToTmtUsers < ActiveRecord::Migration
  def change
    add_column :users, :visited, :string
  end
end
