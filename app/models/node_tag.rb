class NodeTag < Tag
  default_scope {where(type_tag: self.name)}
end
