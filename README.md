my-default-rails-conf
=====================

This is how I setup my default Rails applications.

What is this?
-------------

I have four files:

  * app_builder.rb
  * app_template.rb
  * railsrc
  * templates/gitignore

These files allow me to begin writing a Rails application from scratch,
by taking care of what gems I require in my projects and default setup.

How to use?
-----------

First, clone the repository:

    git clone https://github.com/hagarelvikingo/my-default-rails-conf.git ~/.railsconf

Then create an alias to the railsrc command:

    ln -sfv ~/.railsrc ~/.railsconf/railsrc

And install the following gems:

  * rails
  * pg
  * sass-rails
  * coffee-rails
  * libv8
  * uglifier
  * jquery-rails
  * puma
  * mina
  * composite\_primary\_keys
  * foreigner
  * immigrant
  * awesome\_nested\_set
  * paperclip
  * bcrypt-ruby
  * state\_machine
  * globalize3
  * devise
  * devise-encryptable
  * cancan
  * nokogiri
  * simple_form
  * country_select
  * jbuilder
  * kaminari
  * rabl
  * ruby_parser
  * premailer-rails3
  * mail
  * tuktuk
  * better\_errors
  * binding\_of\_caller
  * ruby\_gntp
  * bullet
  * rspec-rails
  * rspec-rails-mocha
  * factory\_girl\_rails
  * webrat
  * ffaker
  * capybara
  * guard-rspec
  * launchy
  * database\_cleaner

There is some configuration you can do (for example configure Bullet to
use Growl with a password or not at all), but I will leave it to you.

Also, I'm more into PostgreSQL than into any database, hence I will not
create a configurator for now.

Questions and Answers
---------------------

### Will you maintain it?

Of course!

### Can I suggest you to put other gems in there?

You can. I will evaluate these gems before putting these. This is "my",
personal, unique (not too much I guess), default Rails setup, if you do
recommend other gems, don't do it as a pull request (that's for errors)
but as an e-mail to my account.

### Why you run "bundle install" so many times?

I'm working on that. But it's much easier to configure each gem without
taking care of other ones. If you have a better solution, perfect!
