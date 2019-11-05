# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register("application/rdf+xml", :rdf)
Mime::Type.register("application/pdf", :pdf)
#Mime::Type.register("application/atom+xml", :atom)
