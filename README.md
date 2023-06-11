To install: `bundle install`

To run locally: `middleman server`

To build: `middleman build`, then you can commit the `/doc` folder's content.

Basic workflow:
* `source/blog/released` contains the posts that are released. 
  Their code is public, both the source and the built content are saved in this public repository.
  The `/released` part is not in the final built paths.

* `source/blog/repo` is a second (private) git repository containing all blog post and the progression of them. 
  The directory is excluded from builds. That way incomplete stuff is not public and intermediary commits are also
  private.

* If I want to let someone read a post before I publish it:
  1) Add `preprint: true` to the yaml part (FrontMatter). This works for posts in `source/blog/repo` too
  2) `middleman build`, commit and push
  3) When done, remove the `preprint: true`

* When a post is to be published:
  1) Copy it over to `source/blog/released` 
  2) In the version that is in `source/blog/repo`, add `ignore: true` to the yaml part (FrontMatter). 
  3) `middleman build`, commit and push

* If you ever want to update/modify the post:
  1) Remove the `ignore: true` from the version in `source/blog/repo`. 
     The post will now appear in double when in server mode.
  2) Work on the post in `source/blog/repo`. 
  3) When ready, overwrite the post from `source/blog/released` with the one from `source/blog/repo`, and complete the "when a post is to be published".

The docs/CNAME is necessary to allow hosting on Github Pages with a custom domain, and putting it in source/CNAME avoids Middleman deleting it on each build.

## Embed source in a post
Using __RB__, before and after a :ruby block will make it disappear from the rendered file, but available
as the same file with .rb as extension.

This could be improved, but right now:

* URL to the page: `#{current_page.url.sub(/\.html$/, '.rb')}`
* Run the code from the page: `bin/console_on_post.rb path_to_post` (You can use reload! from it)
