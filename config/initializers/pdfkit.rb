PDFKit.configure do |config|
  config.default_options = {
      :encoding=>"UTF-8",
      :page_size => 'A4',
      :print_media_type => true,
      :disable_javascript => true,
      :disable_smart_shrinking=>false
  }
end