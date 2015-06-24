#!/usr/bin/ruby
require 'rexml/document'
include REXML

class Xml2As
  
  AS_TYPES_MAP = {
    :string => "String",
    :integer => "Number",
    :float => "Number",
    :date => "Date",
    :datetime => "Date",
    :boolean => "Boolean"
  }
  
  def convert(filename,options ={}, out = STDOUT)
    file = File.new(filename)
    doc = Document.new(file)
    options[:from_xml_return_var] = "#{options[:class_name].downcase}" unless options[:from_xml_return_var]
    options[:from_xml_xml_param] = "#{options[:class_name].downcase}XML" unless options[:from_xml_xml_param]
    from_xml,to_xml = "",""
    doc.root.elements.each do |elem|
      convert_elem(elem,from_xml,to_xml,options,out) unless get_as_name(elem.name) == "id"
    end
    from_xml_method = <<-EOM
    
    public static function fromXML(#{options[:from_xml_xml_param]}:XML):#{options[:class_name]}{
      var #{options[:from_xml_return_var]}:#{options[:class_name]} = null;
      if(#{options[:from_xml_xml_param]}.hasComplexContent()){                 
        #{options[:from_xml_return_var]} = new #{options[:class_name]}(Number(#{options[:from_xml_xml_param]}.id));
#{from_xml}
      }
      return #{options[:from_xml_return_var]}
    }
    EOM
    out << from_xml_method
    
    to_xml_method = <<-EOM

    public function toXML(root:String = "#{options[:from_xml_return_var]}"):XML{
          var xml:XML =
            <{root}>
              #{to_xml}
            </{root}>      
      return xml;
    }
    EOM
     out << to_xml_method
  end  
    
  private
  
  def convert_elem(elem , from_xml, to_xml, options,out)
    if(elem)
      attribute_type = get_attribute_type(elem.attributes["type"])
      as_name = get_as_name(elem.name)      
      out << getter_setters(as_name,AS_TYPES_MAP[attribute_type])
      from_xml << from_xml_method_content(elem.name,as_name,attribute_type,options)
      to_xml << to_xml_method_content(elem.name,as_name,attribute_type,options)
    end
  end
    
  def getter_setters(as_name,as_type)
    template = <<-EOT
    
    //@private _#{as_name}
    private var _#{as_name}:#{as_type.to_s};
    //#{as_name} getter
    public function get #{as_name}():#{as_type.to_s}\{
        return _#{as_name};
    \}
    
    //#{as_name} setter
    public function set #{as_name}(value:#{as_type.to_s}):void\{
      _#{as_name} = value;
    \}

    EOT
    template
  end
  
  #append the line to set the property in the fromXML method
  # @param as_name : property name (setter/getter)
  # @param as_type : property AS type (Number, Date, ...)
  def from_xml_method_content(element_name,as_name,as_type,options)
    # value = "#{options[:from_xml_xml_param]}.child(\"#{element_name}\").valueOf()"    
    value = "#{options[:from_xml_xml_param]}.#{element_name}"    
    template = <<-EOT    
        #{options[:from_xml_return_var]}.#{as_name} = #{cast_xml_value(as_type,value)}    
    EOT
    if(as_type == :date)
      template = "if(!StringUtils.isBlank(#{value}))\n#{template}"
    end
    template
  end
  
  #append the line to set the property in the toXML method
  # @param as_name : property name (setter/getter)
  # @param as_type : property AS type (Number, Date, ...)
  def to_xml_method_content(element_name,as_name,as_type,options)
    template = <<-EOT
    <#{element_name}>{#{cast_as_value(as_type,as_name)}}</#{element_name}>
    EOT
    template
  end
  
  
  #cast the as value to xml object 
  def cast_as_value(as_type,as_property)
   if(as_type == :date)
     return "XMLUtils.dateToXML(#{as_property})"
   elsif(as_type == :datetime)
       return "TolDateUtils.toTimeParam(#{as_property})"
   else
     return as_property
   end
  end 
 
  #cast the xml value to as object
  def cast_xml_value(as_type,value)
    if(as_type == :date)
      return "XMLUtils.xmlListToDate(#{value});"
    elsif(as_type == :datetime)
        return "DateUtil.parseW3CDTF(#{value}.toString());"
    elsif(as_type == :boolean)
        return "XMLUtils.xmlListToBoolean(#{value});"    
    elsif(as_type == :integer or as_type == :float)
        return "Number(#{value});"
    end
    cast_value = "#{value};"
  end

  
  ##
  # 
  #
  def get_attribute_type(type)
    as_type = :string
    as_type = type.to_sym unless(type.nil? or type == "enum")
    return as_type
  end
  
  def get_as_name(name)
    # return camelize(undasherize(name),false)
    return camelize(name,false)
  end
  
  def undasherize(underscored_word)
   underscored_word.gsub(/-/, "_")
  end
  
  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
    str =  lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
   end  
end

class String
  def first(limit = 1)
    self[0..(limit - 1)]
  end  
end

parser = Xml2As.new
parser.convert("./admin/restaurant_translation.xml", :class_name => "RestaurantTranslation")
