class SiteSerializer < ApplicationSerializer
  include SitePermissionsMixin
  include PreloadedTagsMixin
end
