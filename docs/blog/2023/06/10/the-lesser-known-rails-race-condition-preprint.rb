#!/usr/bin/env ruby
# frozen_string_literal: true
#
# This is a little self contained script which automatically loads the needed gems and runs tests which
# show most behaviors as seen in the blog post.
#
# This uses Thread.new to execute code in a new transaction at a specific point in time to avoid the random
# nature associated with race conditions. This basically picks which path you want the test to take by specifying
# the exact order.
#
# Need to have PostgreSQL installer and to run this first:
#   CREATE DATABASE repeatable_read_demo;
require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Activate the gem you are reporting the issue against.
  gem "activerecord", "~> 7.0.0"
  gem "pg"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "postgresql",
  database: "repeatable_read_demo",
  pool: 5)
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.text :name
    t.integer :foo
    t.boolean :published, null: false, default: false
  end

  create_table :comments, force: true do |t|
    t.text :name
    t.integer :foo
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
end

class ReadRepeatableExampleTest < Minitest::Test
  def create_initial_data
    Post.delete_all
    Post.create!(published: true)
    Post.create!
  end


  def test_it_works_as_expected_without_the_race
    create_initial_data

    report = []

    report << Post.count
    report << Post.where(published: true).count
    report << Post.where(published: false).count

    # This is what you want, this is the report you expect
    assert_equal([2, 1, 1], report)
  end

  def test_race_without_the_transaction
    create_initial_data

    report = []

    report << Post.count
    report << Post.where(published: true).count

    Thread.new { Post.create! }.join

    report << Post.where(published: false).count

    # This is NOT what you want, your report is incoherent becuase of the race condition
    assert_equal([2, 1, 2], report)
  end

  def test_race_with_regular_transaction
    create_initial_data

    report = []
    Post.transaction do
      report << Post.count
      report << Post.where(published: true).count

      Thread.new { Post.create! }.join

      report << Post.where(published: false).count
    end

    # This is NOT what you want, your report is incoherent becuase of the race condition
    assert_equal([2, 1, 2], report)
  end

  def test_no_race_with_read_repeatable_transaction
    create_initial_data

    report = []
    Post.transaction(isolation: :repeatable_read) do
      report << Post.count
      report << Post.where(published: true).count

      Thread.new { Post.create! }.join

      report << Post.where(published: false).count
    end

    # This is what you want, your report is correct because of the repeatable_read transaction
    assert_equal([2, 1, 1], report)
  end


  def test_read_repeatable_transaction_affect_table_not_used_yet
    create_initial_data

    report = []
    Post.transaction(isolation: :repeatable_read) do
      # There needs to be a query for the transaction to actually begin. Doing it on an unrelated model
      Comment.count

      Thread.new { Post.create! }.join
      report << Post.count
      report << Post.where(published: true).count

      report << Post.where(published: false).count
    end

    # This is what you want, your report is correct because of the repeatable_read transaction
    assert_equal([2, 1, 1], report)
  end

  def test_no_place_for_race_with_group
    create_initial_data

    report = []

    post_counts = Post.group(:published).count

    report << post_counts[true] + post_counts[false]
    report << post_counts[true]
    report << post_counts[false]

    # This is what you want, your report is correct because of the repeatable_read transaction
    assert_equal([2, 1, 1], report)
  end

  def test_no_place_for_race_with_group
    create_initial_data

    report = []

    post_counts = Post.group(:published).count

    report << post_counts[true] + post_counts[false]
    report << post_counts[true]
    report << post_counts[false]

    # This is what you want, your report is correct because of the repeatable_read transaction
    assert_equal([2, 1, 1], report)
  end
end
