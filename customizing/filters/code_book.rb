module Customizing::Filters::CodeBook
  include Haml::Filters::Base
  def render(content, top_classes: nil)
    top_classes = Array(top_classes)
    parts = []
    parts << %(<div class="code-book #{top_classes.join(' ')}">)

    rows = content.split(/^\s*%ROW\s*\n?/)

    rows.each do |row_content|
      next if row_content.blank?

      text, sep, code = row_content.partition(/^\s*(%RUBY|%CODE)\s*\n?/)
      code = code.rstrip.encode(Encoding::UTF_8)

      # Remove starting blank lines? Not sure if I want the possibility of starting with empty lines.
      # code = code.sub(/\A( *\n)*/, '')

      language = sep =~ /%RUBY\b/ ? 'ruby' : nil

      # Allow language to be specified via a special comment like:
      #  # lang: ruby
      if code.lines.first =~ /\A\s*#\s*lang:\s*(\w+)$/
        language = $1
        code = code.lines.to_a[1..-1].join # Strip first line
      end

      html_text = Customizing::Filters::Content.render(text)
      highlighted_code = Middleman::Syntax::Highlighter.highlight(code, language)

      parts << %(<div class="code-book__left">#{html_text}</div>)
      parts << %(<div class="highlight code-book__right"><div class="code-book__right-wrapper">#{highlighted_code}</div></div>)
    end

    parts << %(</div>)
    parts.join
  end
end

module Customizing::Filters::CodeBook1L
  include Haml::Filters::Base

  def render(content)
    Customizing::Filters::CodeBook.render(content, top_classes: 'code-book--1l')
  end
end


module Customizing::Filters::CodeBook2L
  include Haml::Filters::Base

  def render(content)
    Customizing::Filters::CodeBook.render(content, top_classes: 'code-book--2l')
  end
end

module Customizing::Filters::CodeBook3L
  include Haml::Filters::Base

  def render(content)
    Customizing::Filters::CodeBook.render(content, top_classes: 'code-book--3l')
  end
end
