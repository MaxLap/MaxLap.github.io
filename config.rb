# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Allow a file to self ignore using frontmatter. Just put ignore: true
# Must be before activating the blog extension, or it will have already
# processed the files
class FrontMatterIgnorer < Middleman::Extension
  def manipulate_resource_list(resources)
    resources.reject do |resource|
      resource.data[:ignore] == true
    end
  end
end
::Middleman::Extensions.register(:front_matter_ignorer, FrontMatterIgnorer)
activate :front_matter_ignorer

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = ":blogdir/{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "blog_post"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

activate :livereload
activate :syntax

set :build_dir, 'docs'

redcarpet_config = {
    fenced_code_blocks: true,
    no_intra_emphasis: true,
    autolink: true,
    strikethrough: true,
    lax_spacing: true,
    footnotes: true,
}
Object.send(:remove_const, :REDCARPET_CONFIG) rescue nil
Object.const_set(:REDCARPET_CONFIG, redcarpet_config)

set :markdown_engine, :redcarpet
set :markdown, redcarpet_config

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/blog/released/*.html', layout: 'blog_post'
page '/blog/repo/*.html', layout: 'blog_post'
page '/blog/*.html', layout: 'blog'

configure :build do
  # The source/blog/repo is where work in progress posts are placed.
  # It is either a 2nd git repository, or a symbolic link to a 2nd repository.
  # Details are in the readme's workflow section.
  Dir['source/blog/repo/*'].each do |path|
    ignore path.gsub(/\.md$/, '').gsub(%r{^source/}, '')
  end
end

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end


# Adds a [REPO] to title of articles from the repo blog dir
# Must be after the blog engine ran
class REPOMarker < Middleman::Extension
  def manipulate_resource_list(resources)
    resources.each do |resource|
      if resource.data[:blogdir] == 'repo'
        resource.data[:title] += ' [REPO]'
        resource.destination_path = resource.destination_path.gsub(/\.html$/, '-repo.html')
      end
    end
  end
end
::Middleman::Extensions.register(:repo_marker, REPOMarker)
activate :repo_marker


helpers do
  def spoiler_toggler(text)
    content_tag 'span', class: 'spoiler-toggler btn btn-default btn-flat btn-xs' do
      text
    end
  end

  def spoiler_target(tag, text)
    content_tag tag, class: 'spoiler-target' do
      text
    end
  end
end


require_relative 'customizing/filters/__init__'
