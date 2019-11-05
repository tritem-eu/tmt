# A Resource Shape
#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestCase
module Oslc
  module Automation
    module Adapter
      class ResourceShape < Oslc::Core::ResourceShape
        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            rqm_auto: :rqm_auto
          }
        end

        after_initialize do
          request_uri do
            @routes.oslc_automation_resource_shape_url(:adapter)
          end

          title_of_shape 'QM V2 Automation Request'

          resource_type 'http://open-services.net/ns/auto#AutomationRequest'
        end

        define_properties do
          [
            [:property_definition,               :occurs,             :read_only, :value_type,       :representation,   :range,                :value_shape,           :hidden,  :description],
            ["rqm_auto:workAvailable",           "oslc:Zero-or-one",  "true",     "xmls:boolean",    nil,               nil,                   nil,                    "false",  "True if work is assigned to the adapter"],
            ["rqm_auto:workAvailableUrl",        "oslc:Zero-or-one",  "true",     "oslc:Resource",   nil,               nil,                   nil,                    "false",  "Handy URL to query rqm_qm:workAvailable property of Automation Adapter"],
            ["rqm_auto:assignedWorkUrl",         "oslc:Exactly-one",  "true",     "oslc:Resource",   nil,               nil,                   nil,                    "false",  "Handy URL to query new Automation Requests assigned to the adapter to execute"],
            ["dcterms:creator",                  "oslc:Zero-or-many", "true",     "oslc:Resource",   "oslc:Reference",  "foaf:Person",         nil,                    "false",  "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:modified",                 "oslc:Zero-or-one",  "true",     "xmls:dateTime",   nil,               nil,                   nil,                    "false",  "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["rqm_auto:macAddress",              "oslc:Exactly-one",  "true",     "rdf:string",      nil,               nil,                   nil,                    "false",  "MAC Address of the machine where adapter is running"],
            ["dcterms:title",                    "oslc:Exactly-one",  "false",    "xmls:string",     nil,               nil,                   nil,                    "false",  "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["dcterms:type",                     "oslc:Exactly-one",  "false",    "xmls:string",     nil,               nil,                   nil,                    "false",  "The resource type URIs."],
            ["rqm_auto:runsOnMachine",           "oslc:Zero-or-one",  "true",     "oslc:Resource",   "oslc:Reference",  nil,                   nil,                    "false",  "The actual machine where automation adapter is running. It is likely that the target resource will be an LabResource but that is not necessarily the case."],
            ["dcterms:description",              "oslc:Zero-or-one",  "false",    "rdf:XMLLiteral",  nil,               nil,                   nil,                    "fasle",  "Descriptive text (reference: Dublin Core) about resource represented as rich text in XHTML content. SHOULD include only content that is valid and suitable inside an XHTML &lt;div&gt; element. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["rdf:type",                         "oslc:Zero-or-many", "true",     "oslc:Resource",   'oslc:Reference',  nil,                   nil,                    "true",   "The resource type URIs."],
            ["dcterms:identifier",               "oslc:Exactly-one",  "true",     "xmls:string",     nil,               nil,                   nil,                    "true",   "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["oslc:serviceProvider",             "oslc:Exactly-one",  "true",     "oslc:Resource",   "oslc:Reference",  "oslc:ServiceProvider","oslc:ServiceProvider", "true",   "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc:instanceShape",               "oslc:Zero-or-one",  "true",     "oslc:Resource",   "oslc:Reference",  "oslc:ResourceShape",  "oslc:ResourceShape" ,  "true",   "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["rqm_auto:pollingInterval",         "oslc:Exactly-one",  "false",    "xmls:integer",    nil,               nil,                   nil,                    "false",  "The polling interval in milliseconds. Automation Adapter is expected to query for rqm_qm:workAvailable property within this polling interval to maintain it's availability status. Also see rqm_qm:workAvailableUrl property."],
            ["rqm_auto:hostname",                "oslc:Exactly-one",  "true",     "xmls:string",     nil,               nil,                   nil,                    "false",  "Hostname of the machine where adapter is running."],
            ["rqm_auto:fullyQualifiedDomainName","oslc:Exactly-one",  "true",     "xmls:string",     nil,               nil,                   nil,                    "false",  "Fully qualified domain name of the machine where adapter is running."],
            ["rqm_auto:ipAddress",               "oslc:Zero-or-many", "true",     "xmls:string",     nil,               nil,                   nil,                    "false",  "IP Address of the machine where adapter is running"]
          ]
        end
      end
    end
  end
end
