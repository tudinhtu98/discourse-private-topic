class AddTypeToTagGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :tag_groups, :type, :string, default: "TagGroup", null: false
  end
end
