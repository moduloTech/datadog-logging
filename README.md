# Datadog::Logging

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/datadog/logging`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add datadog-logging

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install datadog-logging

## Usage

### In a pure-Ruby context

```ruby
# frozen_string_literal: true

require 'logger'
require 'net/http'
require 'json'
require 'datadog/logging'

class ApiRequest

  HEADERS = {
    'Content-Type' => 'application/json',
    'Accept' => 'application/json'
  }.freeze

  def add_stuff
    logger = Datadog::Logging::Logger.new(Logger.new(STDOUT))

    params = [
      {
        kind: 'thing'
      }
    ].to_json
    request_id = "add_stuff_#{Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')}"

    uri = URI('https://www.google.com')
    hostname = uri.hostname
    uri.path = '/api/stuffs'
    request = Net::HTTP::Post.new(uri, HEADERS)
    request.body = params
    response = Net::HTTP.start(hostname) do |http|
      http.request(request)
    end

    logger.http_request(method: 'POST', path: uri.path, controller: self.class.name, action: __method__,
                        params: params, headers: HEADERS, response: response, request_id: request_id,
                        user: { id: 1, name: 'Test TEST', email: 'test@test.test', role: 'test' })
    response
  end

  def add_stuff_with_format
    logger = Datadog::Logging::Logger.new(Logger.new(STDOUT, formatter: Datadog::Logging::Formatter::JsonFormatter))

    params = [
      {
        kind: 'thing'
      }
    ].to_json
    request_id = "add_stuff_#{Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')}"

    uri = URI('https://www.google.com')
    hostname = uri.hostname
    uri.path = '/api/stuffs'
    request = Net::HTTP::Post.new(uri, HEADERS)
    request.body = params
    response = Net::HTTP.start(hostname) do |http|
      http.request(request)
    end

    logger.http_request(method: 'POST', path: uri.path, controller: self.class.name, action: __method__,
                        params: params, headers: HEADERS, response: response, request_id: request_id,
                        user: { id: 1, name: 'Test TEST', email: 'test@test.test', role: 'test' })
    response
  end

end

ApiRequest.new.add_stuff # => I, [2023-09-20T12:30:20.490190 #273]  INFO -- : {:method=>"POST", :path=>"/api/stuffs", :format=>"application/json", :controller=>"ApiRequest", :action=>:add_stuff, :status=>"404", :request_id=>"add_stuff_2023-09-20T12:30:20+00:00", :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json"}, :params=>[{"kind"=>"thing"}], :response=>"Response body", :user=>{:id=>1, :username=>"Test TEST", :email=>"test@test.test", :role=>"test"}}
ApiRequest.new.add_stuff_with_format # => {"time":"2023-09-20 12:41:39 +0000","method":"POST","path":"/api/stuffs","format":"application/json","controller":"ApiRequest","action":"add_stuff_with_format","status":"404","request_id":"add_stuff_2023-09-20T12:41:39+00:00","headers":{"Content-Type":"application/json","Accept":"application/json"},"params":[{"kind":"thing"}],"response":"Response body","user":{"id":1,"username":"Test TEST","email":"test@test.test","role":"test"}}
```

### In a Rails context

```ruby
# frozen_string_literal: true

# Considering you added the gem to your Gemfile with auto-require

class ApiRequest
  
  HEADERS = {
    'Content-Type' => 'application/json',
    'Accept'       => 'application/json'
  }.freeze

  def add_stuff
    logger = Datadog::Logging::Logger.new(Rails.logger)

    params = [
      {
        kind: 'thing'
      }
    ].to_json
    request_id = "add_stuff_#{Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')}"

    uri = URI('https://www.google.com')
    hostname = uri.hostname
    uri.path = '/api/stuffs'
    request = Net::HTTP::Post.new(uri, HEADERS)
    request.body = params
    response = Net::HTTP.start(hostname) do |http|
      http.request(request)
    end

    logger.http_request(method: 'POST', path: uri.path, controller: self.class.name, action: __method__,
                   params: params, headers: HEADERS, response: response, request_id: request_id,
                   user: { id: 1, name: 'Test TEST', email: 'test@test.test', role: 'test' })
    response
  end

end

# The Datadog::Logging::Formatter::JsonFormatter is automatically configured as the default log_formatter for Rails.
ApiRequest.new.add_stuff # => {"time":"2023-09-20T13:20:08.392+00:00","method":"POST","path":"/api/stuffs","format":"application/json","controller":"ApiRequest","action":"add_stuff","status":"404","request_id":"add_stuff_2023-09-20T13:20:08+00:00","headers":{"Content-Type":"application/json","Accept":"application/json"},"params":[{"kind":"thing"}],"response":"Response body","user":{"id":1,"username":"Test TEST","email":"test@test.test","role":"test"}}
```

When the gem is required in a Rails context, the `Datadog::Logging::Middleware::LogExceptions` middleware is inserted
after the `ActionDispatch::DebugExceptions` middleware.

When an exception is raised (and not catched) in your application, it will be logged
(with formatter `Datadog::Logging::Formatter::JsonFormatter`) as:

```json
{
  "time": "2023-09-20T13:22:17.553+00:00",
  "error": {
    "kind": "RuntimeError",
    "message": "test",
    "stack": [
      "(irb):35:in `\u003cmain\u003e'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/workspace.rb:119:in `eval'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/workspace.rb:119:in `evaluate'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/context.rb:502:in `evaluate'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:590:in `block (2 levels) in eval_input'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:779:in `signal_status'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:569:in `block in eval_input'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/ruby-lex.rb:267:in `block (2 levels) in each_top_level_statement'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/ruby-lex.rb:249:in `loop'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/ruby-lex.rb:249:in `block in each_top_level_statement'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/ruby-lex.rb:248:in `catch'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb/ruby-lex.rb:248:in `each_top_level_statement'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:568:in `eval_input'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:502:in `block in run'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:501:in `catch'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:501:in `run'",
      "/usr/local/bundle/gems/irb-1.5.0/lib/irb.rb:419:in `start'",
      "/usr/local/bundle/gems/railties-7.0.4/lib/rails/commands/console/console_command.rb:70:in `start'",
      "/usr/local/bundle/gems/railties-7.0.4/lib/rails/commands/console/console_command.rb:19:in `start'",
      "/usr/local/bundle/gems/railties-7.0.4/lib/rails/commands/console/console_command.rb:102:in `perform'",
      "/usr/local/bundle/gems/thor-1.2.1/lib/thor/command.rb:27:in `run'",
      "/usr/local/bundle/gems/thor-1.2.1/lib/thor/invocation.rb:127:in `invoke_command'",
      "/usr/local/bundle/gems/thor-1.2.1/lib/thor.rb:392:in `dispatch'",
      "/usr/local/bundle/gems/railties-7.0.4/lib/rails/command/base.rb:87:in `perform'",
      "/usr/local/bundle/gems/railties-7.0.4/lib/rails/command.rb:48:in `invoke'",
      "/usr/local/bundle/gems/railties-7.0.4/lib/rails/commands.rb:18:in `\u003cmain\u003e'",
      "/usr/local/bundle/gems/bootsnap-1.14.0/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:32:in `require'",
      "/usr/local/bundle/gems/bootsnap-1.14.0/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:32:in `require'",
      "bin/rails:4:in `\u003cmain\u003e'"
    ]
  }
}
```

### Log HTTP requests

You can change the log level used by `Datadog::Logging::Logger`:
```ruby
logger = Datadog::Logging::Logger.new(Logger.new(STDOUT), log_level: :debug)
logger.log_level = :unknown
```

You can change the way `Datadog::Logging::Logger` format the user:
```ruby
user_formatter = ->(user) {
  user.nil? ? 'unknown user' : %Q(<user id="#{user.id}"></user>)
}

class MyCustomFormatter
  
  def call(user)
    user.hash
  end

end

logger = Datadog::Logging::Logger.new(Logger.new(STDOUT), user_formatter: user_formatter)
# => I, [2023-09-20T14:27:08.108397 #63]  INFO -- : {:method=>"POST", :path=>"/api/stuffs", :format=>"application/json", :controller=>"Object", :action=>nil, :status=>"404", :request_id=>"add_stuff_2023-09-20T14:25:57+00:00", :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json"}, :params=>[{"kind"=>"thing"}], :response=>"Response body", :user=>"<user id=\"1\"></user>"}
logger.user_formatter = MyCustomFormatter.new
# => I, [2023-09-20T14:27:08.108397 #63]  INFO -- : {:method=>"POST", :path=>"/api/stuffs", :format=>"application/json", :controller=>"Object", :action=>nil, :status=>"404", :request_id=>"add_stuff_2023-09-20T14:25:57+00:00", :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json"}, :params=>[{"kind"=>"thing"}], :response=>"Response body", :user=>2724891290560623810}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/modulotech/datadog-logging. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/datadog-logging/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Datadog::Logging project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/datadog-logging/blob/master/CODE_OF_CONDUCT.md).
