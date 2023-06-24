module Customizing::Filters::Paperscript
  include Haml::Filters::Base

  def self.next_canvas_id=(value)
    Thread.current[:paperscript_next_canvas_id] = value
  end

  def self.take_next_canvas_id
    value = Thread.current[:paperscript_next_canvas_id]
    Thread.current[:paperscript_next_canvas_id] = nil
    value
  end

  # The default compile, but acts as if there is always interpollations.
  # This makes it so that render is called every time, which is needed since we use a global variable to communicate
  # between the haml and the filter...
  def compile(compiler, text)
    filter = self
    compiler.instance_eval do
      return if options[:suppress_eval]

      escape = options[:escape_filter_interpolations]
      # `escape_filter_interpolations` defaults to `escape_html` if unset.
      escape = options[:escape_html] if escape.nil?

      text = unescape_interpolation(text, escape).gsub(/(\\+)n/) do |s|
        escapes = $1.size
        next s if escapes % 2 == 0
        "#{'\\' * (escapes - 1)}\n"
      end
      # We need to add a newline at the beginning to get the
      # filter lines to line up (since the Haml filter contains
      # a line that doesn't show up in the source, namely the
      # filter name). Then we need to escape the trailing
      # newline so that the whole filter block doesn't take up
      # too many.
      text = %[\n#{text.sub(/\n"\Z/, "\\n\"")}]
      push_script <<RUBY.rstrip, :escape_html => false
find_and_preserve(#{filter.inspect}.render_with_options(#{text}, _hamlout.options))
RUBY
      nil
    end
  end

  def render_with_options(text, options)
    indent = options[:cdata] ? '    ' : '  ' # 4 or 2 spaces
    type = " type=#{options[:attr_wrapper]}text/paperscript#{options[:attr_wrapper]}"

    text = text.rstrip
    text = <<~PAPER + text
      project.currentStyle = {
        strokeColor: 'black',
        fillColor: 'black',
        strokeWidth: 1,
      };
    PAPER
    text.gsub!("\n", "\n#{indent}")
    canvas_id = Customizing::Filters::Paperscript.take_next_canvas_id
    raise "Need to call #paperscript_canvas or #next_paperscript_canvas_id before a paperscript filter" if canvas_id.nil?
    %!<script#{type} data-paper-canvas="#{canvas_id}">\n#{"  //<![CDATA[\n" if options[:cdata]}#{indent}#{text}\n#{"  //]]>\n" if options[:cdata]}</script>!
  end
end
