class AddDefaultDestinationToShortlinks < ActiveRecord::Migration[5.1]
  def change
    change_column :shortlinks, :destination, :string, :default => nil
  end
end
