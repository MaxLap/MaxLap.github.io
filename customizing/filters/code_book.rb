module ::Customizing::Filters::CodeBook
  include Haml::Filters::Base
  def render(content)
    parts = []
    parts << %(<div class="code-book">)

    rows = content.split('%ROW')

    rows.each do |row_content|
      text, _, code = row_content.partition('%RUBY')
      code = code.rstrip.sub(/\A( *\n)*/, '').encode(Encoding::UTF_8)

      # Allow language to be specified via a special comment like:
      #  # lang: ruby
      if code.lines.first =~ /\A\s*#\s*lang:\s*(\w+)$/
        language = $1
        code = code.lines.to_a[1..-1].join # Strip first line
      else
        language = 'ruby'
      end

      html_text = ::Customizing::Filters::Content.render(text)
      highlighted_code = Middleman::Syntax::Highlighter.highlight(code, language)

      parts << %(<div class="code-book__left">#{html_text}</div>)
      parts << %(<div class="highlight code-book__right"><div class="code-book__right-wrapper">#{highlighted_code}</div></div>)
    end

    parts << %(</div>)
    parts.join
  end
end
