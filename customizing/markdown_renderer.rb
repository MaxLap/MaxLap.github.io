class Customizing::MarkdownRenderer < Redcarpet::Render::HTML
  def header(text, header_level)
    original_text = "#" * header_level + " " + text
    default = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(::REDCARPET_RENDER_CONFIG), ::REDCARPET_CONFIG).render(original_text)
    default =~ /id=['"]([^'"]*)/
    header_id = $1
    # TODO...
    default
  end
end
