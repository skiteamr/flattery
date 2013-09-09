# Flattery [![Build Status](https://secure.travis-ci.org/evendis/flattery.png?branch=master)](http://travis-ci.org/evendis/flattery)

Sometimes you want to do the non-DRY thing and repeat yourself, by caching values from associated records in a master model.
The two main reasons you might want to do this are probably:
* for performance - to avoid joins in search queries and display
* to save values from association records that are subject to deletion yet still have them available when looking at the master record - if you are using the [https://rubygems.org/gems/paranoid](paranoid) gem for example.

Hence flattery - a gem that provides a simple declarative method for caching and maintaining such values.

Flattery is primarily intended for use with relational Active::Record storage, and is only tested with sqlite and PostgreSQL.
If you are using NoSQL, you probably wouldn't design your schema in a way for which flattery adds any value - but if you find a situation where this makes sense, then feel free to fork and add the support .. or lobby for it's inclusion!

## Requirements

* Ruby 1.9 or 2
* Rails 3.x/4.x
* ActiveRecord (only sqlite and PostgreQL tested. Others _should_ work; raise an issue if you find problems)

## Installation

Add this line to your application's Gemfile:

    gem 'flattery'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flattery

## Usage

### How to define a model that has cached values from a :belongs_to association

Given a model with a :category assoociation, and you want to cache instance.category.name as instance.category_name.

First, add a migration to add :category_name column to your table with the same type as category.name.
Then just include Flattery::ValueCache in your model and define flatten_values like this:

    class Note < ActiveRecord::Base
      belongs_to :category

      include Flattery::ValueCache
      flatten_value :category => :name
    end

### How to cache the value in a specific column name

In the usual case, the cache column name is inferred from the association (e.g. category_name in the example above).
If you want to store in another column name, use the :as option on the +flatten_value+ call:

    class Note < ActiveRecord::Base
      belongs_to :category

      include Flattery::ValueCache
      flatten_value :category => :name, :as => 'cat_name'
    end

### How to push updates to cached values from the source model

Given a model with a :category assoociation, and a flattery config that caches instance.category.name to instance.category_name,
you want the category_name cached value updated if the category.name changes.

This is achieved by adding the Flattery::ValueProvider to the source model and defining push_flattened_values_for like this:

    class Category < ActiveRecord::Base
      has_many :notes

      include Flattery::ValueProvider
      push_flattened_values_for :name => :notes
    end

This will respect the flatten_value settings defined in that target mode (Note in this example).

### How to push updates to cached values from the source model to a specific cache column name

If the cache column name cannot be inferred correctly, an error will be raised. Inference errors can occur if the inverse association relation cannot be determined.

To 'help' flattery figure out the correct column name, specify the column name with an :as option:

    class Category < ActiveRecord::Base
      has_many :notes

      include Flattery::ValueProvider
      push_flattened_values_for :name => :notes, :as => 'cat_name'
    end



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
