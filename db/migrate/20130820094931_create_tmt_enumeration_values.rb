class CreateTmtEnumerationValues < ActiveRecord::Migration
  def change
    create_table :tmt_enumeration_values do |t|
      t.references :enumeration, index: true
      t.integer :numerical_value
      t.string :text_value

      t.timestamps
    end
  end
end
