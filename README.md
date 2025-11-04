# Preferred Deals API - Rails Backend

RESTful API built with Rails 8.0.2 for the Preferred Deals business directory platform.

## Quick Start

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start server
rails server -p 3001
```

API runs on `http://localhost:3001`

**Default admin account:**
- Email: `admin@preferreddeals.com`
- Password: `password123`
- ⚠️ **Change this password immediately in production!**

---

## 🔧 Configuration

### Database
PostgreSQL connection configured via `DATABASE_URL` environment variable or `config/database.yml`

### Environment Variables
```bash
DATABASE_URL=postgresql://user:pass@localhost/preferred_deals_api_development
SECRET_KEY_BASE=your_secret_key_here
RAILS_ENV=development
```

Generate secret: `rails secret`

---

## 📁 Project Structure

```
app/
├── controllers/
│   ├── api/v1/
│   │   ├── auth_controller.rb        # Authentication
│   │   ├── businesses_controller.rb  # Business CRUD
│   │   ├── saved_deals_controller.rb # Saved deals
│   │   └── admin_controller.rb       # Admin features
│   ├── concerns/
│   │   ├── authentication.rb         # JWT helpers
│   │   └── authorization.rb          # Role checks
│   └── application_controller.rb     # Base controller
│
├── models/
│   ├── user.rb              # User accounts
│   ├── business.rb          # Business listings
│   ├── saved_deal.rb        # User favorites
│   └── analytic.rb          # Event tracking
│
├── lib/
│   └── json_web_token.rb    # JWT encode/decode
│
config/
├── routes.rb                # API endpoints
├── database.yml             # DB configuration
└── initializers/
    └── cors.rb              # CORS setup

db/
├── migrate/                 # Database migrations
├── seeds.rb                 # Sample data
└── schema.rb                # Current schema
```

---

## 🔌 API Endpoints

### Authentication
- `POST /api/v1/auth/signup` - Create account
- `POST /api/v1/auth/login` - Login
- `GET /api/v1/auth/me` - Current user info
- `POST /api/v1/auth/logout` - Logout

### Businesses (Public)
- `GET /api/v1/businesses` - List businesses
  - Query params: `search`, `category`, `featured`, `deals`
- `GET /api/v1/businesses/:id` - Business details
- `POST /api/v1/businesses/:id/track_click` - Track interaction

### Businesses (Authenticated - Partner)
- `POST /api/v1/businesses` - Create business
- `PATCH /api/v1/businesses/:id` - Update business
- `DELETE /api/v1/businesses/:id` - Delete business
- `GET /api/v1/businesses/my` - My businesses
- `GET /api/v1/businesses/:id/analytics` - View analytics

### Saved Deals (Authenticated - User)
- `GET /api/v1/saved_deals` - List saved
- `POST /api/v1/saved_deals/toggle` - Toggle save status
- `DELETE /api/v1/saved_deals/:id` - Remove saved

### Admin (Authenticated - Admin Only)
- `GET /api/v1/admin/stats` - Platform statistics
- `GET /api/v1/admin/users` - User list (paginated)
- `GET /api/v1/admin/businesses` - Business list (paginated)
- `PATCH /api/v1/admin/businesses/:id/feature` - Toggle featured
- `DELETE /api/v1/admin/users/:id` - Delete user
- `DELETE /api/v1/admin/businesses/:id` - Delete business

---

## 🔐 Authentication

### JWT Tokens
- Login returns JWT token
- Token expires in 24 hours (configurable)
- Include in requests: `Authorization: Bearer <token>`

### User Types
- `user` - Regular user (browse, save deals)
- `partner` - Business owner (manage listings)
- `distribution` - Multi-business manager (future)
- `admin` - Platform administrator

### Authorization Helpers
```ruby
require_admin!              # Admin only
require_partner!            # Partner or admin
require_distribution!       # Distribution partner or admin
```

---

## 💾 Database Models

### User
```ruby
has_many :businesses
has_many :saved_deals
has_many :saved_businesses, through: :saved_deals

validates :name, presence: true
validates :email, presence: true, uniqueness: true
validates :user_type, inclusion: { in: %w[user partner distribution admin] }
```

### Business
```ruby
belongs_to :user
has_many :saved_deals
has_many :analytics

validates :name, :category, :address, presence: true
validates :rating, numericality: { in: 0..5 }

scope :featured, -> { where(featured: true) }
scope :with_deals, -> { where(has_deals: true) }
scope :by_category, ->(cat) { where(category: cat) }
```

### SavedDeal
```ruby
belongs_to :user
belongs_to :business

validates :user_id, uniqueness: { scope: :business_id }
```

### Analytic
```ruby
belongs_to :business

# event_type: 'view' | 'click'
# event_data: { click_type: 'phone' | 'email' | 'website' }
```

---

## 🌱 Seed Data

```bash
# Run seeds
rails db:seed

# Reset database
rails db:reset
```

Creates:
- 3 sample users (admin, partner, regular)
- 12 sample businesses across categories
- Featured and deal flags

Sample credentials:
- Admin: `admin@preferreddeals.com` / `password123`
- Partner: `partner@preferreddeals.com` / `password123`
- User: `user@preferreddeals.com` / `password123`

---

## 🧪 Testing

```bash
# Run all tests
rails test

# Run specific test
rails test test/controllers/api/v1/businesses_controller_test.rb

# With coverage
COVERAGE=true rails test
```

---

## 🔄 Database Migrations

```bash
# Create migration
rails generate migration AddFieldToModel field:type

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Check status
rails db:migrate:status
```

---

## 📊 Console

```bash
# Open Rails console
rails console

# Example queries
User.count
Business.featured.count
Business.by_category('Restaurant')
```

---

## 🚀 Deployment

### Railway
1. Connect repository
2. Set environment variables:
   ```
   DATABASE_URL (from Postgres service)
   SECRET_KEY_BASE (generate with: rails secret)
   RAILS_ENV=production
   RAILS_SERVE_STATIC_FILES=true
   ```
3. Deploy automatically on push to main

### Docker
```bash
# Build
docker build -t preferred-deals-api .

# Run
docker run -p 3001:3001 \
  -e DATABASE_URL=postgresql://... \
  -e SECRET_KEY_BASE=... \
  preferred-deals-api
```

---

## 🐛 Debugging

### Enable detailed logging
```ruby
# config/environments/development.rb
config.log_level = :debug
```

### Check database connection
```bash
rails db:version
```

### View routes
```bash
rails routes | grep api/v1
```

### Check model validations
```bash
rails console
> business = Business.new
> business.valid?
> business.errors.full_messages
```

---

## 📦 Dependencies

### Core
- `rails (~> 8.0.2)` - Framework
- `pg (~> 1.1)` - PostgreSQL adapter
- `puma (>= 5.0)` - Web server
- `bcrypt (~> 3.1.7)` - Password hashing
- `jwt` - JSON Web Tokens
- `rack-cors` - Cross-origin requests

### Development/Test
- `debug` - Debugging tools
- `rspec-rails` - Testing framework (if added)

---

## 🔧 Configuration Files

### `config/database.yml`
Database connections for each environment

### `config/routes.rb`
API endpoint definitions

### `config/initializers/cors.rb`
CORS configuration for frontend

### `config/application.rb`
Rails application settings

---

## 📝 API Response Format

### Success Response
```json
{
  "id": 1,
  "name": "Business Name",
  ...
}
```

### Error Response
```json
{
  "error": "Error message"
}
// or
{
  "errors": ["Error 1", "Error 2"]
}
```

### Paginated Response
```json
{
  "users": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 125,
    "per_page": 25
  }
}
```

---

## 🔒 Security

- Passwords hashed with BCrypt
- JWT tokens with expiration
- CORS restricted to frontend domain (production)
- SQL injection prevention via ActiveRecord
- Authorization checks on all protected endpoints

---

## 📊 Performance

- Database indexes on foreign keys
- Eager loading with `includes` to prevent N+1 queries
- JSON API responses (no views)
- Connection pooling via Puma

---

## 🆘 Common Issues

### "PG::ConnectionBad"
- Check DATABASE_URL is correct
- Verify PostgreSQL is running
- Run: `rails db:create`

### "JWT::DecodeError"
- Token expired (re-login)
- SECRET_KEY_BASE changed
- Token format incorrect

### "ActiveRecord::RecordInvalid"
- Check model validations
- View errors: `record.errors.full_messages`

---

## 📚 Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [JWT Introduction](https://jwt.io/introduction)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

**Version**: 1.0.0  
**Rails**: 8.0.2  
**Ruby**: 3.3.6
