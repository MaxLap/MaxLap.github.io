To run locally: `middleman server`

To build: `middleman build`

Posts that are done go in `source/blog/done`. The `/done` part of the path will not be in the final built paths.

`source/blog/wip` is a private git repository pointing containing all blog posts, including work in progress ones. `/wip` is never included in builds. Thay way incomplete stuff is not public.

When a post is complete and to be published, copy it over to `/done`, then in the `/wip` version, add a `ignore: true` to the frontmatter so that you don't see it in double.

The docs/CNAME is necessary to allow hosting on Github Pages with a custom domain, and putting it in source/CNAME avoids Middleman deleting it on each build.
