#!/bin/bash

# Start Sidekiq in the background
# bundle exec sidekiq &

# Start the Rails server
./bin/rails server -b 0.0.0.0 -p ${PORT:-1000}
