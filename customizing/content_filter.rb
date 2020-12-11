module Content
  include Haml::Filters::Base
  def render(text)
    text = text.rstrip.sub(/\A( *\n)*/, '').encode(Encoding::UTF_8)

    parts = []
    parts << %(<div class="markdown-body">)
    parts << Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(render_options = {})).render(text)
    parts << %(</div>)
    parts.join
  end
end
