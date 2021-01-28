#!/usr/bin/env ruby
# frozen_string_literal: true
#
# This is a little self contained script which automatically loads the needed gems
# It then runs asserts with the same code as the post, then you get an interactive shell.

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Activate the gem you are reporting the issue against.
  gem "activerecord", "6.1.1"
  gem "sqlite3"
  gem "activerecord_where_assoc"
end

require "active_record"
require "minitest/autorun"
require "logger"
require "irb"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :content
    t.boolean :spam
    t.timestamps
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  scope :is_spam, -> { where(spam: true) }
end

def assert(boolean)
  raise 'Assertion failed!' if !boolean
end

p = Post.create!
p.comments.create!(content: 'hello', spam: true)
p.comments.create!(content: 'world')

# distinct because joins can make duplicates
# I dislike using joins for this.
posts = Post.joins(:comments).distinct
            .where(comments: {spam: true})

assert posts.first.comments.to_a.size == 2

assert posts.includes(:comments).first.comments.to_a.size == 1
assert posts.includes(:comments).first.comments.count == 2
assert posts.includes(:comments).first.comments.size == 1

assert(Post.includes(:comments)
           .where(comments: {spam: true})
           .first.comments.size == 1)

assert posts.preload(:comments).first.comments.to_a.size == 2
assert posts.preload(:comments).first.comments.count == 2
assert posts.preload(:comments).first.comments.size == 2

puts "Every asserts in the code passed. Feel free to toy around with Post and Comment"
puts "The activerecord_where_assoc gem is also loaded if you want to try it out"
puts "Ex: Post.where_assoc_exists(:comments, spam: true)"

IRB.start(__FILE__)
