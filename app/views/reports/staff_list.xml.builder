xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.instruct! :'mso-application', :progid=>"Excel.Sheet"
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet",
  'xmlns:html' => "http://www.w3.org/TR/REC-html40"
  }) do

  xml.Styles do
    xml.Style({'ss:ID'=>"1"}) { xml.Font({'ss:Bold'=>"1"}) }
  end

  xml.Worksheet 'ss:Name' => 'Staff List' do
    xml.Table do

      # Columns
      xml.Column({'ss:Width'=>"110"})
      xml.Column({'ss:Width'=>"110"})
      @detail_types.each do |detail_type|
        width = (detail_type.field_type == 'string') ? '80' : '150'
        xml.Column({'ss:Width'=>width})
      end

      # Header
      xml.Row({'ss:StyleID'=>"1"}) do
        xml.Cell { xml.Data 'Full Name', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Email', 'ss:Type' => 'String' }
        @detail_types.each do |detail_type|
          xml.Cell { xml.Data detail_type.name, 'ss:Type' => 'String' }
        end
      end

      # Rows
      for staff in @staff
        xml.Row do
          xml.Cell { xml.Data staff.full_name, 'ss:Type' => 'String' }
          xml.Cell { xml.Data staff.email, 'ss:Type' => 'String' }
          @detail_types.each do |detail_type|
            xml.Cell { xml.Data staff.detail_types_hash[detail_type.id], 'ss:Type' => 'String' }
          end
        end
      end

    end
  end
end
