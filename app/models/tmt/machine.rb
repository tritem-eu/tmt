module Tmt
  class Machine < ActiveRecord::Base
    belongs_to :user, class_name: '::User'
    validates :user_id, presence: true, uniqueness: true
    validates :mac_address, allow_blank: true, format: {
      with: /\A([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\Z/,
      message: "MAC address should consists of six groups of two hexadecimal digits, separated by hyphens (-) or colons (:)."
    }
    validates :ip_address, allow_blank: true, format: {
      with: Resolv::IPv4::Regex,
    }
  end
end
