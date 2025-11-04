# This file creates initial user accounts for testing and development
# In production, change these passwords immediately after first login!

puts "🌱 Seeding database..."
puts ""

# Create admin user
admin_user = User.find_or_create_by!(email: "admin@preferreddeals.com") do |user|
  user.name = "Admin User"
  user.password = "Admin123!"
  user.user_type = "admin"
end
puts "✅ Admin user created"

# Create regular user
regular_user = User.find_or_create_by!(email: "user@preferreddeals.com") do |user|
  user.name = "Regular User"
  user.password = "User123!"
  user.user_type = "user"
end
puts "✅ Regular user created"

# Create partner user
partner_user = User.find_or_create_by!(email: "partner@preferreddeals.com") do |user|
  user.name = "Partner User"
  user.password = "Partner123!"
  user.user_type = "partner"
end
puts "✅ Partner user created"

# Create distribution partner user
distribution_user = User.find_or_create_by!(email: "distribution@preferreddeals.com") do |user|
  user.name = "Distribution Partner"
  user.password = "Distribution123!"
  user.user_type = "distribution"
end
puts "✅ Distribution partner user created"

puts ""
puts "=" * 60
puts "🎉 Seed data created successfully!"
puts "=" * 60
puts ""
puts "📋 LOGIN CREDENTIALS (⚠️  CHANGE THESE IN PRODUCTION!):"
puts ""
puts "👑 ADMIN:"
puts "   Email:    admin@preferreddeals.com"
puts "   Password: Admin123!"
puts "   Access:   Full platform control"
puts ""
puts "👤 REGULAR USER:"
puts "   Email:    user@preferreddeals.com"
puts "   Password: User123!"
puts "   Access:   Browse businesses, save deals"
puts ""
puts "🏢 BUSINESS PARTNER:"
puts "   Email:    partner@preferreddeals.com"
puts "   Password: Partner123!"
puts "   Access:   Create/manage businesses, view analytics"
puts ""
puts "🤝 DISTRIBUTION PARTNER:"
puts "   Email:    distribution@preferreddeals.com"
puts "   Password: Distribution123!"
puts "   Access:   Manage multiple businesses, white-label features"
puts ""
puts "=" * 60
puts ""
puts "🚀 Next steps:"
puts "   1. Start the server: rails server"
puts "   2. Log in with one of the accounts above"
puts "   3. ⚠️  CHANGE ALL PASSWORDS in production!"
puts ""
