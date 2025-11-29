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

# Create partner users
partner_user = User.find_or_create_by!(email: "partner@preferreddeals.com") do |user|
  user.name = "Partner User"
  user.password = "Partner123!"
  user.user_type = "partner"
end
puts "✅ Partner user created"

partner_user2 = User.find_or_create_by!(email: "partner2@preferreddeals.com") do |user|
  user.name = "Sarah Johnson"
  user.password = "Partner123!"
  user.user_type = "partner"
end
puts "✅ Partner user 2 created"

partner_user3 = User.find_or_create_by!(email: "partner3@preferreddeals.com") do |user|
  user.name = "Michael Chen"
  user.password = "Partner123!"
  user.user_type = "partner"
end
puts "✅ Partner user 3 created"

# Create distribution partner users
distribution_user = User.find_or_create_by!(email: "distribution@preferreddeals.com") do |user|
  user.name = "Distribution Partner"
  user.password = "Distribution123!"
  user.user_type = "distribution"
end
puts "✅ Distribution partner user created"

distribution_user2 = User.find_or_create_by!(email: "distributor2@preferreddeals.com") do |user|
  user.name = "Regional Deals Network"
  user.password = "Distribution123!"
  user.user_type = "distribution"
end
puts "✅ Distribution partner 2 created"

distribution_user3 = User.find_or_create_by!(email: "distributor3@preferreddeals.com") do |user|
  user.name = "Local Business Hub"
  user.password = "Distribution123!"
  user.user_type = "distribution"
end
puts "✅ Distribution partner 3 created"

# Create businesses across multiple locations
puts ""
puts "📍 Creating businesses across multiple locations..."

# Cities and states for diverse location data
locations = [
  { city: "New York", state: "NY" },
  { city: "Los Angeles", state: "CA" },
  { city: "Chicago", state: "IL" },
  { city: "Houston", state: "TX" },
  { city: "Miami", state: "FL" },
  { city: "Austin", state: "TX" },
  { city: "Seattle", state: "WA" },
  { city: "Boston", state: "MA" },
  { city: "Denver", state: "CO" },
  { city: "Phoenix", state: "AZ" }
]

categories = ["Restaurant", "Retail", "Services", "Healthcare", "Technology", "Entertainment", "Beauty", "Fitness"]

businesses_created = 0
locations.each_with_index do |location, loc_index|
  # Create 2-3 businesses per location
  (2..3).each do |i|
    category = categories.sample
    business_name = case category
    when "Restaurant"
      ["#{location[:city]} Bistro", "Downtown #{location[:city]} Cafe", "The #{location[:city]} Grill"].sample
    when "Retail"
      ["#{location[:city]} Market", "City Center Store", "Main Street Shop"].sample
    when "Services"
      ["#{location[:city]} Services", "Professional Services Co", "City Services"].sample
    when "Healthcare"
      ["#{location[:city]} Health Center", "Wellness Clinic", "Medical Center"].sample
    when "Technology"
      ["Tech Solutions #{location[:city]}", "Digital Services", "IT Solutions"].sample
    when "Entertainment"
      ["#{location[:city]} Entertainment", "City Theater", "Entertainment Hub"].sample
    when "Beauty"
      ["#{location[:city]} Salon", "Beauty Spa", "Hair Studio"].sample
    when "Fitness"
      ["#{location[:city]} Gym", "Fitness Center", "Health Club"].sample
    else
      "#{category} Business #{i}"
    end
    
    # Assign to different partner users
    owner = [partner_user, partner_user2, partner_user3].sample
    
    # Some businesses have deals, some are featured
    has_deals = [true, false, false].sample
    featured = [true, false, false, false].sample
    approval_status = loc_index < 2 ? "pending" : "approved" # First 2 locations have pending businesses
    
    business = Business.find_or_create_by!(name: business_name, user: owner) do |b|
      b.category = category
      b.description = "A great #{category.downcase} business in #{location[:city]}, #{location[:state]}. Offering quality services and products to the local community."
      b.address = "#{rand(100..9999)} Main Street, #{location[:city]}, #{location[:state]} #{rand(10000..99999)}"
      b.phone = "(#{rand(200..999)}) #{rand(200..999)}-#{rand(1000..9999)}"
      b.email = "contact@#{business_name.downcase.gsub(/\s+/, '')}.com"
      b.website = "www.#{business_name.downcase.gsub(/\s+/, '')}.com"
      b.rating = rand(35..50) / 10.0
      b.review_count = rand(10..500)
      b.featured = featured
      b.has_deals = has_deals
      b.deal_description = has_deals ? ["20% off first visit", "Buy 1 Get 1 Free", "Free consultation", "10% discount"].sample : nil
      b.hours = {
        monday: "9:00 AM - 6:00 PM",
        tuesday: "9:00 AM - 6:00 PM",
        wednesday: "9:00 AM - 6:00 PM",
        thursday: "9:00 AM - 8:00 PM",
        friday: "9:00 AM - 8:00 PM",
        saturday: "10:00 AM - 5:00 PM",
        sunday: "Closed"
      }
      b.amenities = ["Free Wi-Fi", "Parking Available", "Wheelchair Accessible"].sample(rand(1..3))
      b.approval_status = approval_status
      b.approved_at = approval_status == "approved" ? Time.current : nil
      b.approved_by = approval_status == "approved" ? admin_user : nil
    end
    
    businesses_created += 1
  end
end
puts "✅ Created #{businesses_created} businesses across #{locations.length} locations"

# Create white label entries for distribution partners
puts ""
puts "🎨 Creating white label platforms for distribution partners..."

white_label1 = WhiteLabel.find_or_create_by!(user: distribution_user) do |wl|
  wl.brand_name = "Preferred Deals Network"
  wl.subdomain = "network"
  wl.domain = "network.preferreddeals.com"
  wl.primary_color = "#000000"
  wl.secondary_color = "#FFFFFF"
  wl.settings = {
    enable_community_accounts: true,
    enable_save_deals: true,
    enable_messages: false,
    custom_categories: [],
    header_menu: [],
    footer_menu: []
  }
end
puts "✅ White label 1 created for #{distribution_user.name}"

white_label2 = WhiteLabel.find_or_create_by!(user: distribution_user2) do |wl|
  wl.brand_name = "Regional Deals"
  wl.subdomain = "regional"
  wl.domain = "regional.deals.com"
  wl.primary_color = "#1a56db"
  wl.secondary_color = "#e0e7ff"
  wl.settings = {
    enable_community_accounts: true,
    enable_save_deals: true,
    enable_messages: true,
    custom_categories: ["Local Services", "Regional Offers"],
    header_menu: [],
    footer_menu: []
  }
end
puts "✅ White label 2 created for #{distribution_user2.name}"

white_label3 = WhiteLabel.find_or_create_by!(user: distribution_user3) do |wl|
  wl.brand_name = "Local Business Hub"
  wl.subdomain = "localhub"
  wl.domain = nil
  wl.primary_color = "#059669"
  wl.secondary_color = "#d1fae5"
  wl.settings = {
    enable_community_accounts: false,
    enable_save_deals: true,
    enable_messages: false,
    custom_categories: [],
    header_menu: [],
    footer_menu: []
  }
end
puts "✅ White label 3 created for #{distribution_user3.name}"

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
puts "🏢 BUSINESS PARTNERS:"
puts "   Email:    partner@preferreddeals.com"
puts "   Password: Partner123!"
puts "   Email:    partner2@preferreddeals.com"
puts "   Email:    partner3@preferreddeals.com"
puts "   Access:   Create/manage businesses, view analytics"
puts ""
puts "🤝 DISTRIBUTION PARTNERS:"
puts "   Email:    distribution@preferreddeals.com"
puts "   Password: Distribution123!"
puts "   Email:    distributor2@preferreddeals.com"
puts "   Email:    distributor3@preferreddeals.com"
puts "   Access:   Manage multiple businesses, white-label features"
puts ""
puts "📍 LOCATIONS CREATED:"
locations.each do |loc|
  puts "   - #{loc[:city]}, #{loc[:state]}"
end
puts ""
puts "🏢 BUSINESSES CREATED: #{businesses_created} businesses across #{locations.length} cities"
puts ""
puts "=" * 60
puts ""
puts "🚀 Next steps:"
puts "   1. Start the server: rails server"
puts "   2. Log in with one of the accounts above"
puts "   3. ⚠️  CHANGE ALL PASSWORDS in production!"
puts ""
