# TFT Team Builder

> **Important:** This Rails app now serves as a JSON API that powers the Vue 3 SPA in `../frontend/tft-builder`. UI/Stimulus references below describe the original milestone build and are no longer active. See the repository root `README.md` for the consolidated stack and workflow.

A web application for creating and managing Teamfight Tactics (TFT) team compositions. Users can browse champions, create custom team lineups, and analyze trait synergies.

## 🚀 Live Demo

**Deployed on Heroku:** [https://milestone0-c472c40be832.herokuapp.com/](https://milestone0-c472c40be832.herokuapp.com/)

## 📋 Core Features

### 1. Champion Browser
- **Browse all available champions** with visual cards displaying champion portraits
- **View detailed champion information** including cost/tier and traits
- **Responsive grid layout** that adapts to different screen sizes
- **Champion portraits** displayed using sprite-based images for optimal performance

### 2. Team Composition Builder
- **Interactive drag-and-click interface** for building team compositions
- **Real-time lineup management** with instant visual feedback
- **Champion selection from a visual pool** with image previews
- **Dynamic team counter** showing current team size
- **Save and name custom team compositions** with descriptions

### 3. Team Management
- **View all saved team compositions** in a organized list format
- **Edit existing teams** with pre-loaded champion selections
- **Visual team preview** showing champion portraits in team cards
- **Team composition metadata** including name and description

### 4. Trait Analysis
- **Automatic trait calculation** based on selected champions
- **Active trait display** showing synergy counts
- **Real-time trait updates** as champions are added/removed

## 🏗️ Architecture Overview

### Frontend
- **Rails Views (ERB Templates)** - Server-side rendered HTML
- **Stimulus.js Controllers** - Client-side interactivity for team building
- **Bootstrap 5** - UI framework for responsive design
- **JavaScript ES6** - Modern JavaScript for dynamic interactions

### Backend
- **Ruby on Rails 8.0.3** - Web application framework
- **PostgreSQL** - Primary database for production
- **Active Record** - ORM for database interactions
- **Rails Controllers** - HTTP request handling and business logic

### Infrastructure
- **Heroku** - Cloud platform for deployment
- **Git** - Version control
- **Bundler** - Ruby dependency management

## 🛠️ Technology Stack

### Core Framework
- **Ruby on Rails 8.0.3** - Main web framework
- **Ruby 3.3.9** - Programming language

### Database & ORM
- **PostgreSQL** - Production database (Heroku Postgres)
- **Active Record** - Database abstraction layer
- **Rails Migrations** - Database schema management

### Frontend Technologies
- **ERB (Embedded Ruby)** - Template engine
- **Stimulus.js** - JavaScript framework for Rails
- **Importmap** - Modern JavaScript module loading
- **Turbo Rails** - SPA-like navigation without full page reloads

### UI Framework: Bootstrap 5
Bootstrap is extensively used throughout the application for:

#### Layout & Grid System
```erb
<!-- Responsive grid for champion cards -->
<div class="col-6 col-md-4 col-lg-2 mb-4">
  <!-- Champion card content -->
</div>
```

#### Navigation
```erb
<!-- Tab-style navigation in application layout -->
<ul class="nav nav-tabs">
  <li class="nav-item">
    <%= link_to "Champions List", champions_path, class: "nav-link" %>
  </li>
</ul>
```

#### Cards & Components
```erb
<!-- Champion and team composition cards -->
<div class="card h-100 text-dark">
  <%= image_tag champion.image_url, class: "card-img-top" %>
  <div class="card-body p-2">
    <h6 class="card-title"><%= champion.name %></h6>
  </div>
</div>
```

#### Forms & Buttons
```erb
<!-- Form styling and button components -->
<%= form.text_field :name, class: "form-control" %>
<%= link_to "Create New Team", new_team_comp_path, class: "btn btn-primary" %>
```

#### Utility Classes
- **Spacing:** `mb-4`, `mt-4`, `p-3`, `gap-2`
- **Flexbox:** `d-flex`, `flex-wrap`, `justify-content-between`
- **Typography:** `text-center`, `small`, `text-muted`
- **Borders:** `border`, `rounded`, `shadow-sm`

### Production Features
- **Solid Queue** - Background job processing
- **Solid Cache** - Database-backed caching
- **Solid Cable** - WebSocket connections
- **Thruster** - HTTP asset caching and compression
- **Propshaft** - Modern asset pipeline

## 📁 Core Files & Directory Structure

### Models (`app/models/`)
```
app/models/
├── champion.rb          # Champion data model
├── team_comp.rb         # Team composition model
├── trait.rb             # Trait/synergy model
└── application_record.rb
```

### Controllers (`app/controllers/`)
```
app/controllers/
├── champions_controller.rb    # Champion browsing and details
├── team_comps_controller.rb   # Team CRUD operations
├── pages_controller.rb        # Static pages (home)
└── application_controller.rb
```

### Views (`app/views/`)
```
app/views/
├── champions/
│   ├── index.html.erb    # Champion grid display
│   └── show.html.erb     # Individual champion details
├── team_comps/
│   ├── index.html.erb    # Team list view
│   ├── new.html.erb      # Team creation form
│   ├── edit.html.erb     # Team editing form
│   └── show.html.erb     # Team detail view
├── pages/
│   └── home.html.erb     # Landing page
└── layouts/
    └── application.html.erb  # Main layout with navigation
```

### JavaScript (`app/javascript/`)
```
app/javascript/
├── application.js
└── controllers/
    └── builder_controller.js  # Team building interactivity
```

### Database (`db/`)
```
db/
├── migrate/
│   ├── 20251011030427_create_champions.rb
│   ├── 20251011030436_create_team_comps.rb
│   ├── 20251011040930_add_sprite_info_to_champions.rb
│   ├── 20251011041100_create_traits.rb
│   └── 20251011041503_rename_cost_to_tier_in_champions.rb
├── seeds.rb             # Sample data for development
└── schema.rb           # Current database structure
```

### Configuration (`config/`)
```
config/
├── database.yml        # Database configuration
├── routes.rb          # URL routing
├── environments/
│   ├── development.rb
│   ├── production.rb  # Heroku deployment settings
│   └── test.rb
└── initializers/      # Framework configuration
```

## 🔧 Development & Modification Guide

### Adding New Features

#### 1. Adding a New Champion Attribute
**Files to modify:**
1. **Migration**: Create new migration file
   ```bash
   rails generate migration AddNewAttributeToChampions new_attribute:string
   ```

2. **Model** (`app/models/champion.rb`):
   ```ruby
   class Champion < ApplicationRecord
     # Add validation or methods for new attribute
     validates :new_attribute, presence: true
   end
   ```

3. **Views** (`app/views/champions/`):
   - Update `show.html.erb` to display new attribute
   - Update `index.html.erb` if needed in card display

4. **Controller** (`app/controllers/champions_controller.rb`):
   - Add to strong parameters if needed for forms

#### 2. Creating a New Page/Feature
**Files to create/modify:**

1. **Route** (`config/routes.rb`):
   ```ruby
   resources :new_feature
   ```

2. **Controller** (`app/controllers/new_feature_controller.rb`):
   ```ruby
   class NewFeatureController < ApplicationController
     def index
       # Your logic here
     end
   end
   ```

3. **Views** (`app/views/new_feature/`):
   ```erb
   <!-- Create index.html.erb, show.html.erb, etc. -->
   ```

4. **Model** (if needed) (`app/models/new_feature.rb`):
   ```ruby
   class NewFeature < ApplicationRecord
     # Model logic
   end
   ```

5. **Navigation** (`app/views/layouts/application.html.erb`):
   ```erb
   <!-- Add new tab to navigation -->
   <li class="nav-item">
     <%= link_to "New Feature", new_feature_path, class: "nav-link" %>
   </li>
   ```

#### 3. Modifying Team Builder Functionality
**Key files:**

1. **JavaScript Controller** (`app/javascript/controllers/builder_controller.js`):
   - Modify `add()` and `remove()` methods for champion selection
   - Update DOM manipulation logic
   - Add new interactive features

2. **Team Builder Views**:
   - `app/views/team_comps/new.html.erb` - New team creation
   - `app/views/team_comps/edit.html.erb` - Team editing
   - Add new Stimulus data attributes for interactions

3. **Team Model** (`app/models/team_comp.rb`):
   - Add business logic for team validation
   - Add trait calculation methods

#### 4. Styling and UI Changes
**Files to modify:**

1. **Global Styles** (`app/assets/stylesheets/application.css`):
   ```css
   /* Add custom CSS that overrides Bootstrap */
   .custom-champion-card {
     /* Your styles */
   }
   ```

2. **Bootstrap Classes**: Modify existing ERB templates to use different Bootstrap classes

3. **Layout** (`app/views/layouts/application.html.erb`):
   - Modify navigation structure
   - Add global UI components

#### 5. Database Schema Changes
**Process:**

1. **Create Migration**:
   ```bash
   rails generate migration DescriptiveName
   ```

2. **Edit Migration File** (`db/migrate/timestamp_descriptive_name.rb`):
   ```ruby
   def change
     add_column :table_name, :column_name, :type
     # or other changes
   end
   ```

3. **Run Migration**:
   ```bash
   rails db:migrate
   ```

4. **Update Model Validations/Associations** as needed

### Testing Changes

#### Local Development
```bash
# Start the Rails server
rails server

# Run database migrations
rails db:migrate

# Seed database with sample data
rails db:seed
```

#### Deployment to Heroku
```bash
# Deploy changes
git add .
git commit -m "Description of changes"
git push heroku main

# Run migrations on Heroku
heroku run rails db:migrate

# Check logs
heroku logs --tail
```

### Common Development Tasks

#### Adding New Champions
1. Update `db/seeds.rb` with new champion data
2. Run `rails db:seed` locally
3. For production, use Heroku console:
   ```bash
   heroku run rails console
   # Then create champions manually
   ```

#### Modifying Champion Images
1. Add images to `app/assets/images/tft-champion/`
2. Update champion records with correct `image_url`
3. Ensure sprite coordinates are correct for `sprite_x`, `sprite_y`

#### Changing Page Layout
1. Modify `app/views/layouts/application.html.erb` for global changes
2. Use Bootstrap classes for responsive design
3. Add custom CSS in `app/assets/stylesheets/application.css`

## 🚀 Getting Started

### Prerequisites
- Ruby 3.3.9
- Rails 8.0.3
- PostgreSQL
- Node.js (for JavaScript dependencies)

### Local Setup
```bash
# Clone the repository
git clone <repository-url>
cd tft_team_builder

# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start the server
rails server
```

### Environment Variables
For production deployment, set:
- `DATABASE_URL` - PostgreSQL connection string
- `RAILS_ENV=production`

## 📝 License

This project is created for educational purposes as part of CS397 Software Studio at Northwestern University.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Note**: This application uses Rails 8.0 with modern features including Solid Queue, Solid Cache, and Solid Cable for enhanced performance in production environments.
