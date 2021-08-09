#!/usr/bin/env ruby
# frozen_string_literal: true

path = ARGV.shift

if !File.exist?(path)
  puts "Couldn't find file: #{path.inspect}"
  exit(1)
end

if ENV['CONSOLE_ON_POST_IN_LOOP'] == '1'
  require_relative '../my_tools/extract_special_section'
  full_content = File.read(path)
  source, code, line_no = MyTools.extract_special_section(full_content, '__RB__')

  if code.nil?
    puts "Couldn't find __RB__ section in file: #{path}"
    exit(1)
  end

  def reload!
    # IRB overrides the regular exit, so need to use Kernel
    Kernel.exit(116)
  end

  eval(code, binding, path, line_no + 1)
else
  ENV['CONSOLE_ON_POST_IN_LOOP'] = '1'
  trap("SIGINT") do
    nil
  end
  while true
    system(__FILE__, path)
    if $?.exitstatus != 116
      break
    end
  end
end
