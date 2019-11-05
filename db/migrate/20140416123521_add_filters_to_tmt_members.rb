class AddFiltersToTmtMembers < ActiveRecord::Migration
  def change
    add_column :tmt_members, :filters, :text
  end
end
