[![Code Climate](https://codeclimate.com/github/iZettle/api-model.png)](https://codeclimate.com/github/iZettle/api-model)
[![Build Status](https://travis-ci.org/iZettle/api-model.png?branch=master)](https://travis-ci.org/iZettle/api-model)

API Model
=========

API model is a simple wrapper for interacting with external APIs. It tries to make
it very simple and easy to make API calls and map the responses into objects.

A really simple example
-----------------------

To turn any class into an API model, it must inherit ApiModel::Base. If you want to
make attributes which will get automatically set from api responses, you can define them
as properties..

``` ruby
  class MyModel < ApiModel::Base
    property :name
  end
```

Then, let's say the API endpoint /foo returned JSON which looks like `{ "name": "Bar" }`...

```ruby
  example = MyModel.get_json "/foo"
  example.name #=> "Bar"
```

Request types and params
------------------------

There's a couple of convenience methods to make it simpler to send GET and POST requests, or you can send other request types:

```ruby
  # Params will be sent as url params, and options is used for other things which
  # can control ApiModel (such as custom builders)
  get_json url, params, options

  # The request body will be turned into json if it is a hash, otherwise it
  # should be a string. Options are handled the same as get.
  post_json url, request_body, options

  # Works the same as the ones above, except if you want to pass params or body,
  # they need to be within the options hash.
  call_api :put, url, options
```

Model properties
----------------

The properties which you can define on models are extended from the [Hashie](https://github.com/intridea/hashie#trash)
gem. You can use them to define simple attributes, but also for converting attributes from one name to another, or for
transforming the values as they are set. This is useful for dealing with APIs which use a different naming scheme
than you are using, or if you need to modify values as they come in.

### Translation

```ruby
  class MyModel < ApiModel::Base
    property :full_name, from: :fullName
  end

  MyModel.new(fullName: "Hello").full_name # => "Hello"
```

### Transformation

```ruby
  class MyModel < ApiModel::Base
    property :created_at, from: :timestamp, with: lambda { |t| Time.at(t) }
  end

  MyModel.new(timestamp: 1387550991).created_at # => 2013-12-20 15:49:51 +0100
```

### Defaults

```ruby
  class MyModel < ApiModel::Base
    property :name, default: "FooBar"
  end

  MyModel.new.name # => "FooBar"
```

For more information, check out the [Hashie::Trash docs](https://github.com/intridea/hashie#trash).

Building objects from responses
-------------------------------

If an API response begins with a hash, it is assumed that it represents a single object and so will be used
to try and build a single object. Likewise, if it is an array, it is assumed to be a collection of objects. For example:

```ruby
  # GET /foo returns { "name": "Foo" }
  MyModel.get_json("/foo") # => #<MyModel:0x007 @name="Foo">

  # GET /bar returns [{ "name": "Foo" }, { "name": "Bar" }]
  MyModel.get_json("/bar") # => [#<MyModel:0x007 @name="Foo">, #<MyModel:0x007 @name="Bar">]
```

You can override the default builder either on a per-call basis using the `:builder` option when making the API call, or by
using the `api_config` block.

```ruby
  class MyCustomBuilder
    def build(params)
      # build something with params...
    end
  end

  class MyModel < ApiModel::Base
    api_config do |config|
      config.builder = MyCustomBuilder.new
    end

    def self.fetch_something
      get_json "/foo", { some_param: "bar" }, builder: MyCustomBuilder.new
    end
  end
```
