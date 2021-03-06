# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions
require_relative 'customizing/__init__'

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

# Customization of the workflow that must be done before the blog has loaded and transformed resources.
# We want it before the blog extension runs so that it fully ignores some content.
# Doing this "ignore" later would still create tags.
class MyCustomizeResourcesPreBlog < Middleman::Extension
  def manipulate_resource_list(resources)
    if app.config[:environment] == :production
      # When building:

      # Ignore posts in source/blog/repo/ unless they have preprint: true
      resources = resources.select do |resource|
        !resource.normalized_path.start_with?('blog/repo/') || resource.data[:preprint]
      end
    else
      # When developing (server):

      # Nothing to do for this at the moment
    end

    resources
  end
end
::Middleman::Extensions.register(:my_customize_resources_pre_blog, MyCustomizeResourcesPreBlog)
activate :my_customize_resources_pre_blog

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

  if config[:environment] == :production
    # When building, do not show preprint in index and css and etc.
    # They will still be available as paths, but won't be visible unless you have the url
    blog.filter = proc { |abc| !abc.data[:preprint] }
  end


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
    underline: true,
}
Object.send(:remove_const, :REDCARPET_CONFIG) rescue nil
Object.const_set(:REDCARPET_CONFIG, redcarpet_config)

redcarpet_render_config = {
    with_toc_data: true,
}
Object.send(:remove_const, :REDCARPET_RENDER_CONFIG) rescue nil
Object.const_set(:REDCARPET_RENDER_CONFIG, redcarpet_render_config)


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

# Customization of the workflow that must be done after the blog has loaded and transformed resources happens here.
# We are editing some of the fields.
class MyCustomizeResourcesPostBlog < Middleman::Extension
  def manipulate_resource_list(resources)
    # Add [PREPRINT] posts pages that have preprint: true
    resources = resources.each do |resource|
      next unless resource.data[:preprint]
      resource.data[:title] += ' [PREPRINT]'
      resource.metadata[:page][:title] += ' [PREPRINT]'
      resource.destination_path = resource.destination_path.gsub(/\.html$/, '-preprint.html')
    end

    if app.config[:environment] == :production
      # When building:

      # Nothing to do for this at the moment
    else
      # When developing (server):

      # Add [REPO] to title of articles from source/blog/repo/
      resources.each do |resource|
        if resource.normalized_path.start_with?('blog/repo/')
          resource.metadata[:page][:title] += ' [REPO]'
          resource.destination_path = resource.destination_path.gsub(/\.html$/, '-repo.html')
        end
      end
    end

    resources
  end
end
::Middleman::Extensions.register(:my_customize_resources_post_blog, MyCustomizeResourcesPostBlog)
activate :my_customize_resources_post_blog

after_build do
  # Having a .rb file in source just breaks middleman. It want to use tilt to render it with opal
  # But I don't want that! I can't even monkey-patch middleman/tilt, because the exception happens
  # before the config is executed!
  # Even installing the gem, I still had the exception.
  # So now, this is dumb work-around, every time I build, I must see that middleman removed
  # the file. Knowing full well that I'm just copying it over. Awesome!
  FileUtils.cp_r(File.join(__dir__, 'ruby_sources'), File.join(__dir__, 'docs'))
end

helpers do
  def spoiler_toggler(text, html_class: "btn-default")
    content_tag 'button', class: "spoiler-toggler btn btn-xs #{html_class}" do
      text
    end
  end

  def spoiler_target(tag, text)
    content_tag tag, class: 'spoiler-target' do
      if text.html_safe?
        text
      else
        simple_format(text.strip)
      end
    end
  end

  def link_with_icon(text, url, icon)
    link_to url do
      content_tag('span', class: 'icon-of-link') do
        icon
      end + text
    end
  end

  def tooltip(text, tooltip_content)
    content_tag('span', class: 'with-tooltip', 'data-tippy-content' => tooltip_content.gsub(/\s+/, ' ')) do
      text
    end
  end

  def content(text)
    Customizing::Filters::Content.render(text)
  end
end
