module Customizing::Filters::CodeBook
  include Haml::Filters::Base
  def compile(compiler, content)
    content = Customizing::Filters::Content.filter_footnotes(compiler, content)
    super(compiler, content)
  end

  def render(content)
    parts = []
    parts << %(<div class="code-book #{top_classes.join(' ')}">)

    rows = content.split(/^\s*%ROW\s*\n?/)

    rows.each do |row_content|
      next if row_content.blank?

      row_content, sep, after = row_content.partition(/^\s*(%AFTER)\s*\n?/)
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
      if after.present?
        has_after_left = ' code-book__left--has-after'
        has_after_right = ' code-book__right--has-after'
      end
      parts << %(<div class="code-book__left#{has_after_left}">#{html_text}</div>)
      parts << %(<div class="highlight code-book__right#{has_after_right}"><div class="code-book__right-wrapper">#{highlighted_code}</div></div>)
      if after.present?
        html_after = Customizing::Filters::Content.render(after)
        parts << %(<div class="code-book__left code-book__left--after">#{html_after}</div>)
        parts << %(<div class="highlight code-book__right code-book__right--after"></div>)
      end
    end

    parts << %(</div>)
    parts.join
  end

  def top_classes
    []
  end
end

module Customizing::Filters::CodeBook1L
  include Customizing::Filters::CodeBook
  include Haml::Filters::Base

  def top_classes
    ['code-book--1l']
  end
end


module Customizing::Filters::CodeBook2L
  include Customizing::Filters::CodeBook
  include Haml::Filters::Base

  def top_classes
    ['code-book--2l']
  end
end

module Customizing::Filters::CodeBook3L
  include Customizing::Filters::CodeBook
  include Haml::Filters::Base

  def top_classes
    ['code-book--3l']
  end
end
