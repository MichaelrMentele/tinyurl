class CreateShortlinks < ActiveRecord::Migration[5.1]
  def change
    create_table :shortlinks do |t|
      t.string :slug
      t.string :destination
      t.timestamps
    end
  end
end
