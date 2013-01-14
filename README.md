# Resourced

Resourced adds a missing layer between model and controller.
It takes all parameter- and scope-related jobs from the model and makes your model thin. Here is example:

```ruby
class PostResource
  include Resourced::ActiveRecord

  model Post
  key :id

  params do
    allow :title, :body, :tags
    allow :category, if: -> { scope.admin? }
  end

  finders do
    restrict :search, if: -> { scope.guest? }

    finder :title do |val|
      chain.where(title: val)
    end

    finder :search do |val|
      chain.where(t[:body].matches("%#{val}%"))
    end
  end
end
```

Now you can do following:

```ruby
before_filter do
  posts = PostResource.new(params, current_user)
end

# Let params: { title: "My first post", body: "Lorem ipsum" }
post = posts.build
post # => #<Post id: nil, title: "My first post", body: "Lorem ipsum", category: nil>

# Let params: { id: 2, title: "My awesome post" }
posts.update! # Will update title for post with id 2
posts.first   # Will find first post with title "My awesome post"

# Let params: { search: "Atlas Shrugged" }
posts.all # Will return all posts which contains "Atlas Shrugged" unless current user is guest
```

## Installation

Add this line to your application's Gemfile:

    gem 'resourced'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resourced

## Usage

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
