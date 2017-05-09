class IndexSlug < ActiveRecord::Migration[5.1]
  def change
    add_index :shortlinks, :slug
  end
end
