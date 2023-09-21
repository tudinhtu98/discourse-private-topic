class Tag
  scope :normal, -> { where(type_tag: self.name) }

  before_create :set_type_tag
  private

  def set_type_tag
    self.type_tag = self.class.name
  end
end
