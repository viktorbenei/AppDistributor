# README

## Setup - for test / development

    $ bundle install
    $ export DB_USER=[psql-user-name]
    $ bundle exec rake db:create
    $ bundle exec rake db:migrate
    $ bundle exec rails s -b 0.0.0.0
