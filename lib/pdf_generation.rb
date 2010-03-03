require 'fileutils'

class PdfGeneration

  def self.method_missing(method_symbol, *parameters, &block)
    if method_symbol.to_s =~ /^create_(\w+)$/
      new($1, *parameters)
    elsif method_symbol.to_s =~ /^generate_(\w+)$/
      new($1, *parameters).save
    else
      super
    end
  end

  attr_accessor :pdf, :filename, :filepath

  def initialize(method_symbol, *parameters)
    @filepath = File.expand_path(default_options[:filepath] || '.')
    @filename = "#{method_symbol.to_s}.pdf"

    @pdf = Prawn::Document.new
    header
    send(method_symbol, *parameters)
    footer
  end

  def method_missing(method_symbol, *parameters, &block)
    if pdf.respond_to?(method_symbol)
      pdf.send(method_symbol, *parameters, &block)
    else
      super
    end
  end

  def save_path
    File.join(filepath, filename)
  end

  def save
    pdf.render_file(save_path)
    self
  end

  def delete!
    FileUtils.rm(save_path) if File.exist?(save_path)
    true
  end

  def header
    # lazy_bounding_box bounds.top_left, :height => margin_box.height, :width => margin_box.width do
    #   text "Company details", :size => 15, :style => :bold, :align => :right
    # end.draw
  end

  def footer
    # lazy_bounding_box bounds.bottom_left, :height => margin_box.height, :width => margin_box.width do
    #   stroke { horizontal_rule }
    #   move_down 10
    #   text "Copright information for the pdf", :size => 6, :align => :center
    # end.draw
  end

  def default_options
    { :filepath => 'pdfs/' }
  end

end
