# Chrome has a weird bug with table, where with `width: 100%`, they don't match a div's width.
# So to make all code block end correctly, we need to wrap all the code blocks in tables
# https://stackoverflow.com/questions/65052051/table-100-is-less-wide-than-siblbing-div
# https://bugs.webkit.org/show_bug.cgi?id=140371 (Maybe that's the right bug report...)
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
