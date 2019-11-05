class AddCurrentProjectIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :current_project, index: true
  end
end
