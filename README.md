# Device Registry

A simple Rails application for tracking devices assigned to users within an organization.

## Overview

- Users can assign devices to themselves.
- Users can return devices that are being assigned to them.
- A device can be actively assigned to only one user at a time.
- Business rules:
  - User can assign the device only to themself.
  - User cannot assign a device that is already assigned to another user.
  - Only the user who assigned the device can return it.
  - If a user returned the device in the past, they cannot ever re-assign the same device to themself.

---

## Requirements

- Ruby `3.2.x`
- Rails `7.1.x`
- Bundler
- SQLite
- Tested on Ubuntu 22.04 LTS

---

## Setup

1. **Clone the repository**:
    - git clone <this-repo-url>
2. **Install dependencies**:
    - bundle install
3. **Prepare databases**:
    - bundle exec rails db:create
    - bundle exec rails db:migrate
    - RAILS_ENV=test bundle exec rails db:create
    - RAILS_ENV=test bundle exec rails db:migrate
    - bundle exec rake db:test:prepare
4. **Start Rails server**:
    - bundle exec rails server 
    - port 3000 by default
5. **Run the tests**:
    - for all spec: bundle exec rspec spec --format doc 
    - for chosen spec: 
        * bundle exec rspec spec/services/return_device_from_user_spec.rb --format doc
        * bundle exec rspec spec/services/assign_device_to_user_spec.rb --format doc
        * bundle exec rspec spec/controllers/devices_controller_spec.rb --format doc