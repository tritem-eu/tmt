module Tmt
  class CustomFieldType
    def self.type_names
      [
        :text,
        :string,
        :bool,
        :int,
        :date,
        #:datetime,
        :enum
      ]
    end

  end
end
