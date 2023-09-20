class AddTypeToTags < ActiveRecord::Migration[7.0]
  def change
    add_column :tags, :type, :string, default: "Tag", null: false
  end
end
