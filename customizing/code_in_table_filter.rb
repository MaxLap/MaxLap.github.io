module CodeInTable
  include Haml::Filters::Base
  def render(code)
    code = code.rstrip.sub(/\A( *\n)*/, '').encode(Encoding::UTF_8)

    # Allow language to be specified via a special comment like:
    #  # lang: ruby
    if code.lines.first =~ /\A\s*#\s*lang:\s*(\w+)$/
      language = $1
      code = code.lines.to_a[1..-1].join # Strip first line
    else
      language = 'ruby'
    end

    highlighted_code = Middleman::Syntax::Highlighter.highlight(code, language)

    parts = []
    parts << %(<table class="table-for-code">)
    parts << %(<tr><td class="highlight">#{highlighted_code}</td></tr>)
    parts << %(</table>)
    parts.join
  end
end
