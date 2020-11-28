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
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/blog/done/*.html', layout: 'blog_post'
page '/blog/wip/*.html', layout: 'blog_post'
page '/blog/*.html', layout: 'blog'

configure :build do
  # The source/blog/wip is where work in progress posts are placed, this should be a symbolic link
  # pointing to another git repository, so that the only time you modify the blog is when you want to add
  # a completed article by copying it from wip to done.
  Dir['source/blog/wip/*'].each do |path|
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


# Adds a [WIP] to title of articles from the wip blogdir
# Must be after the blog engine ran
class WIPMarker < Middleman::Extension
  def manipulate_resource_list(resources)
    resources.each do |resource|
      if resource.data[:blogdir] == 'wip'
        resource.data[:title] += ' [WIP]'
        resource.destination_path = resource.destination_path.gsub(/\.html$/, '-wip.html')
      end
    end
  end
end
::Middleman::Extensions.register(:wip_marker, WIPMarker)
activate :wip_marker


helpers do
  def table_for_code
    content_tag 'table', class: 'table-for-code' do
      capture_haml {
        yield
      }
    end
  end

  # Chrome has a weird bug with table, where with `width: 100%`, they don't match a div's width.
  # So to make all code block end correctly, we need to wrap all the code blocks in tables
  # https://stackoverflow.com/questions/65052051/table-100-is-less-wide-than-siblbing-div
  # https://bugs.webkit.org/show_bug.cgi?id=140371 (Maybe that's the right bug report...)
  def code_in_table
    table_for_code do
      content_tag 'td' do
        capture_haml {
          yield
        }
      end
    end
  end
end
