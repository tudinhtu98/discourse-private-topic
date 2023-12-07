class RemoveConstraintNotNullOfIsPrivate < ActiveRecord::Migration[7.0]
  def change
    change_column_null :topics, :is_private, true
    change_column_null :tags, :type_tag, true
    change_column_null :tag_groups, :type, true
  end
end
