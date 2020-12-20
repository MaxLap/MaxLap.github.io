module Customizing::Filters::Content
  include Haml::Filters::Base
  def render(text)
    text = text.rstrip.encode(Encoding::UTF_8)

    # Turn trailing ^ (possible with spaces after it) into 2 spaces.
    # This allows bypassing text editors which remove trailing spaces, which is usually just fine.
    # The HAML files don't know that the :content filter is trailing-spaces dependant.
    text = text.gsub(/\^\s*$/, '  ')

    parts = []
    parts << %(<div class="markdown-body">)
    parts << Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true).render(text)
    parts << %(</div>)
    parts.join
  end
end
