
module MyTools
  # Returns [source without the section, section, line_number of section]
  def self.extract_special_section(source, delim)
    parts = source.split(/^\s*#{delim}\s*$/, -1)

    if parts.size <= 1
      return [source, nil, nil]
    elsif parts.size == 2
      raise "Delim #{delim} was only found once. Should also be at the end of the section."
    elsif parts.size > 3
      raise "Delim #{delim} was only found more than twice."
    end

    if delim == '__RB__'
      parts[1] = parts[1].sub(/^:ruby/, '')
    end

    [parts[0] + parts[2], parts[1], parts[0].lines.size]
  end
end
