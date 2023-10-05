class TagGroup
  scope :normal, -> { where(type: self.name) }
end
