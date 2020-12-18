# Override the :code filter of middleman-syntax to instead:
# * Add a wrapping div (yes, another... no comment on the spam of those).
#   We want the outer one to have a special class so that we want add padding to it, without
#   it being anywhere we use highlighter...
# * We want it to default to ruby's highlighting

module Code
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

    %(<div class="highlight lone-highlighted-code">#{Middleman::Syntax::Highlighter.highlight(code, language)}</div>)
  end
end
