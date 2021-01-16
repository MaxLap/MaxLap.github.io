module Customizing::Filters::Content
  include Haml::Filters::Base

  def filter_footnotes(compiler, text)
    fn_data = compiler.options.context.instance_variable_get(:@custom_footnotes_data)
    if fn_data.nil?
      fn_data = {}
      compiler.options.context.instance_variable_set(:@custom_footnotes_data, fn_data)
    end

    fn_data[:name_to_content] ||= {}
    fn_data[:next_number] ||= 1
    fn_data[:name_to_number] ||= {}
    text = text.gsub(/^\s*\[\^(\w+)\]:(.*?)(\n\s*\n|\Z)/m) do
      footnote_name = $1
      footnote_content = $2
      if fn_data[:name_to_content].include?(footnote_name)
        raise %(Footnote "#{footnote_name}" is already used in this page, use a new name)
      end

      fn_data[:name_to_content][footnote_name] = render(footnote_content.strip)
      "\n\n"
    end
    text.gsub!(/(\\*)\[\^(\w+)\]/) do
      escapes = $1
      footnote_name = $2
      if escapes.size.odd?
        next "#{escapes[0...-1]}[^#{footnote_name}]"
      end
      footnote_number = fn_data[:name_to_number][footnote_name]
      if footnote_number.nil?
        footnote_number = fn_data[:next_number]
        fn_data[:next_number] += 1
        fn_data[:name_to_number][footnote_name] = footnote_number
      end
      %(<sup id="fn-ref-#{footnote_name}"><a href="#fn-#{footnote_name}">#{footnote_number}</a></sup>)
    end
    text
  end

  def compile(compiler, text)
    text = filter_footnotes(compiler, text)
    super(compiler, text)
  end

  def render(text)
    text = text.rstrip.encode(Encoding::UTF_8)

    # Turn trailing ^ (possible with spaces after it) into 2 spaces.
    # This allows bypassing text editors which remove trailing spaces, which is usually just fine.
    # The HAML files don't know that the :content filter is trailing-spaces dependant.
    text = text.gsub(/\^\s*$/, '  ')

    parts = []
    parts << %(<div class="markdown-body">)
    parts << Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(::REDCARPET_RENDER_CONFIG), ::REDCARPET_CONFIG).render(text)
    parts << %(</div>)
    parts.join
  end
end
