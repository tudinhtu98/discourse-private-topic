class AddTypeTagToTags < ActiveRecord::Migration[7.0]
  def change
    add_column :tags, :type_tag, :string, default: "Tag", null: false
  end
end
