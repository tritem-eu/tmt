class RemoveChildrenCountFromTmtSets < ActiveRecord::Migration
  def change
    remove_column :tmt_sets, :children_count, :integer
  end
end
