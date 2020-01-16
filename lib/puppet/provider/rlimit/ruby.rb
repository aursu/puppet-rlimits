Puppet::Type.type(:rlimit).provide(:ruby) do
# https://docs.puppet.com/guides/provider_development.html
  def exists?
    if count_matches(match_regex) > 0
      lines.find do |line|
        line.chomp =~ match_regex_value(value)
      end
    end
  end

  def create
    if count_matches(match_regex) > 0
      File.open(path, 'w') do |fh|
        lines.each do |l|
          fh.puts(match_regex.match(l) ? line : l)
        end
      end
    else
      append_line
    end
  end

  def destroy
    if count_matches(match_regex) > 0
      local_lines = lines
      File.open(resource[:path],'w') do |fh|
        fh.write(local_lines.reject{|l| match_regex.match(l) }.join(''))
      end
    end
  end

  def path
    @path ||= "/etc/security/limits.d/#{item}.conf"
  end

  def lines
    # If this type is ever used with very large files, we should
    #  write this in a different way, using a temp
    #  file; for now assuming that this type is only used on
    #  small-ish config files that can fit into memory without
    #  too much trouble.
    if File.file?(path)
      @lines ||= File.readlines(path)
    else
      @lines ||= []
    end
  end

  def domain
    @domain ||= resource[:domain]
  end

  def item
    @item ||= resource[:item].to_s
  end

  def type
    stype = resource[:type].to_s
    @type ||= stype == "any" ? "-" : stype
  end

  def value
    @value ||= resource[:value].to_s
  end

  def line
    @line ||= "#{domain}\t#{type}\t#{item}\t#{value}"
  end

  def match_regex
    match_regex_value('(\d+|-\d+|unlimited|infinity)')
  end

  def match_regex_value(value)
    svalue = value.is_a?(String) ? value : value.to_s
    Regexp.new(/#{Regexp.escape(domain)}\s+#{type}\s+#{item}\s+#{svalue}/)
  end

  def count_matches(regex)
    lines.select{|l| l.match(regex)}.size
  end

  ##
  # append the line to the file.
  def append_line
    File.open(path, 'w') do |fh|
      lines.each do |l|
        fh.puts(l)
      end
      fh.puts line
    end
  end
end