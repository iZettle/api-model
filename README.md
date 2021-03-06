[![Code Climate](https://codeclimate.com/github/iZettle/api-model.png)](https://codeclimate.com/github/iZettle/api-model)
[![Build Status](https://travis-ci.org/iZettle/api-model.png?branch=master)](https://travis-ci.org/iZettle/api-model)

API Model
=========

---

**Deprecated:** iZettle is gradually moving away from ApiModel and will eventually discontinue the project. If you're looking for an alternative, check out [iZettle/api-blueprint](https://github.com/iZettle/api-blueprint).

---

API model is a simple wrapper for interacting with external APIs. It tries to make
it very simple and easy to make API calls and map the responses into objects.

A really simple example
-----------------------

To turn any class into an API model, it must inherit ApiModel::Base. If you want to
make attributes which will get automatically set from api responses, you can define them
as attributes..

``` ruby
  class MyModel < ApiModel::Base
    attribute :name, String
  end
```

Then, let's say the API endpoint /foo returned JSON which looks like `{ "name": "Bar" }`...

```ruby
  example = MyModel.get_json "/foo"
  example.name #=> "Bar"
```

Request types and params
------------------------

There's a couple of convenience methods to make it simpler to send GET and POST requests,
or you can send other request types:

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

Model attributes
----------------

The attributes which you can define on models are included from the [Virtus](https://github.com/solnic/virtus)
gem. You can use them to define simple attributes, coercing values as they come in, or just type-casting. Be sure
to check out the Virtus docs for more info on what can be achieved.

To make it easier to work with APIs which have different naming schemes from your models, you can define attribute
synonyms, which are really just simple aliases.

For example, say you have a `Car` model which has a `number_of_wheels` attribute but with the APIs you're using, sometimes
it the attribute is named `numberOfWheels`, sometimes it's `nrOfWheels` and sometimes it's `wheel_count`, you can easily handle
them all at once:

```ruby
  class Car < ApiModel::Base
    attribute :number_of_wheels, Integer
    attribute_synonym :number_of_wheels, :numberOfWheels, :nrOfWheels, :wheel_count
  end
```

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

You can override the default builder either on a per-call basis using the `:builder` option. The class which you
use as a builder should respond to `#build`, with the instance hash as an argument:

```ruby
  class MyCustomBuilder
    def build(params)
      # build something with params...
    end
  end

  MyModel.get_json "/foo", { some_param: "bar" }, builder: MyCustomBuilder.new
```

It is also possible to create slightly more advanced builders which can access the entire response object,
so that they can modify the return result more directly, or add to the `metadata` object on the response.

```ruby
  class MyCustomBuilder
    def build(response, hash)
      response.metadata.pagination = hash["pagination"]
      MyModel.new name: hash["name"]
    end
  end

  result = MyModel.get_json "/foo", { some_param: "bar" }, builder: MyCustomBuilder.new
  result.name # => whatever was in hash["name"]
  result.metadata # => OpenStruct of values
```

Handling validation errors in responses
---------------------------------------

ApiModel uses a bunch of Rails' ActiveModel enhancements to make it easy to use things such as validation errors.
You can define validations in the normal ActiveModel::Validations style and check validity before posting
to external APIs should you wish to. Or, if an external API returns errors which you would like to convert to
ActiveModel validations, you can do that, too:

```ruby
  class Car
    attribute :name, String
  end

  car = Car.new
  car.set_errors_from_hash name: "cannot be blank"
  car.errors[:name] # => ["cannot be blank"]
```

Metadata
--------

Metadata can be stored directly on the response object, even when it contains an array. By using custom builders,
you can leverage this to store useful data such as pagination metadata (see the builders section for an example).

Configuring API Model
---------------------

You can configure API model in a number of places; globally using `ApiModel::Base.api_config`, per-model
using `MyModel.api_config`, and per-api call by passing in options in the options hash (although some
configuration options may not be available on the per-api call technique).

### API Host

```ruby
  ApiModel::Base.api_config do |config|
    config.host = "http:://someserver.com"
  end
```

This will set the root of all api calls so that you can just use paths in your models instead of having
to refer to the full url all the time.

### JSON root

```ruby
  ApiModel::Base.api_config do |config|
    config.json_root = "data.posts"
  end
```

If the API response which you receive is deeply nested and you want to cut out some levels of nesting, you
can use `json_root` to set which key objects should be built from.

You can dig down multiple levels by separating keys with a period. With the example above, say the server
was returning JSON which looked like `{"data":{"posts":{"name":"Foo"}}}`, it would behave as if the
response was really just `{"name":"Foo"}`.

### Builder

```ruby
  ApiModel::Base.api_config do |config|
    config.builder = MyCustomBuilder.new
  end
```

Sets a custom builder for all API calls. See [building objects from responses](#building-objects-from-responses)
for more details on how custom builders should behave.

### Parser

```ruby
  ApiModel::Base.api_config do |config|
    config.parser = MyCustomParser.new
  end
```

ApiModel is built on the assumption that most modern APIs are JSON-based, but if you need to interact with
an API which returns something other than JSON, you can set custom parsers to deal with objectifying responses
before they are sent to builder classes. The parser should work in the same way as a custom builder, except it needs
to respond to `#parse`, with the raw response body as an argument.

Parsers can also access the raw `response` object, like builders, by using a #parse method which takes two
arguments.

### Raising exceptions

```ruby
  ApiModel::Base.api_config do |config|
    config.raise_on_not_found = true
    config.raise_on_unauthenticated = true
    config.raise_on_server_error = true
  end
```

This will cause any API requests which return a 404 status to raise an ApiModel::NotFoundError exception,
requests which return 500 to raise an ApiModel::ServerError exception, and requests which return a 401
to raise an ApiModel::UnauthenticatedError exception. All default to `false`.

### Cache strategy & settings

```ruby
  ApiModel::Base.api_config do |config|
    config.cache_strategy = MyCustomCacheStrategy
    config.cache_settings = { any_custom_settings: 123 }
  end
```

Currently, ApiModel has no built-in cache strategy, but provides the interface for you to insert your own caching
strategy. On each API call, the cache strategy class will be initialized with two arguments; the cache id, which
is generated from the path and params, and the `cache_settings` which you can define on the config object as
shown above. It will then call `#cache` with the ApiModel response block. So your custom cache class needs to look
something like this:

```ruby
  class MyCustomCacheStrategy
    attr_accessor :id, :options

    def initialize(id, options)
      @id = id
      @options = options
    end

    def cache(&block)
      # here you can check whether you want to actually call the api by running
      # block.call, or want to find and return your cached response.
    end
  end
```

By default, the unique id for the cache store/fetch will be a combination of the path and parameters. If you want to override
this, you can either redefine the `cache_id` method, or set the cache_id when making requests:

```ruby
  MyModel.get_json "/foo", { some_param: "bar" }, cache_id: "whatever!"
```

### Headers

```ruby
  ApiModel::Base.api_config do |config|
    config.headers = { some_custom_header: "foo" }
  end
```

Adds custom headers to the requests. By default, ApiModel will add these headers:

```ruby
  { "Content-Type" => "application/json; charset=utf-8",  "Accept" => "application/json" }
```

These can of course be overridden by just re-defining them in the headers config:

```ruby
  ApiModel::Base.api_config do |config|
    config.headers = { "Content-Type" => "application/soap+xml" }
  end
```

### Logging requests

You can hook onto a callback on the `ApiModel::HttpRequest` class in order to perform tasks before, after or around an
API request. This is useful for logging requests. For example, if you wanted to add a custom NewRelic tracer, you could
add the following callback to make external API calls show up nicely in NewRelic:

```ruby
require 'new_relic/agent/method_tracer'

ApiModel::HttpRequest.class_eval do
  include NewRelic::Agent::MethodTracer
  around_run :trace_with_newrelic

  def trace_with_newrelic
    trace_execution_scoped(["API/#{self.method}/#{self.path}"]) do
      yield
    end
  end
end
```
