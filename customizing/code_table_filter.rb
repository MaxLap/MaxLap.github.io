module CodeTable
  include Haml::Filters::Base
  def render(content)
    parts = []
    parts << %(<table class="table-for-code">)

    rows = content.split('%TR')

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

      html_text = Content.render(text)
      highlighted_code = Middleman::Syntax::Highlighter.highlight(code, language)

      parts << %(<tr><td class="markdown-body">#{html_text}</td><td class="highlight">#{highlighted_code}</td></tr>)
    end

    parts << %(</table>)
    parts.join
  end
end
