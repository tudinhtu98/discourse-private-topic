class AddIsPrivateToTopics < ActiveRecord::Migration[7.0]
    def change
        add_column :topics, :is_private, :boolean, null: false, default: false
    end
end
