class CreateTmtMachines < ActiveRecord::Migration
  def change
    create_table :tmt_machines do |t|
      t.references :user, index: true
      t.string :ip_address
      t.string :mac_address
      t.string :hostname
      t.string :fully_qualified_domain_name

      t.timestamps
    end
  end
end
