class Oslc::Base
  # handle - Tmt::XML::RDFXML instance
  def self.foaf_person(handle, user)
    handle.add('foaf:Person') do |handle|
      handle.add('foaf:name') { user.name }
    end
  end
end
