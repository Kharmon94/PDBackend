# Create sample users
admin_user = User.create!(
  name: "Admin User",
  email: "admin@preferreddeals.com",
  password: "password123",
  user_type: "admin"
)

regular_user = User.create!(
  name: "John Doe",
  email: "john@example.com",
  password: "password123",
  user_type: "user"
)

partner_user = User.create!(
  name: "Jane Smith",
  email: "jane@example.com",
  password: "password123",
  user_type: "partner"
)

# Create sample businesses
businesses_data = [
  {
    name: "Bella Vista Restaurant",
    category: "Restaurant",
    description: "Authentic Italian cuisine with a modern twist. Family-owned since 1985.",
    address: "123 Main Street, Downtown",
    phone: "(555) 123-4567",
    email: "info@bellavista.com",
    website: "www.bellavista.com",
    rating: 4.8,
    review_count: 127,
    image_url: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80",
    featured: true,
    has_deals: true,
    deal_description: "20% off dinner entrees Monday-Thursday!",
    hours: {
      monday: "11:00 AM - 10:00 PM",
      tuesday: "11:00 AM - 10:00 PM",
      wednesday: "11:00 AM - 10:00 PM",
      thursday: "11:00 AM - 10:00 PM",
      friday: "11:00 AM - 11:00 PM",
      saturday: "11:00 AM - 11:00 PM",
      sunday: "12:00 PM - 9:00 PM"
    },
    amenities: ["Outdoor Seating", "Wheelchair Accessible", "Free Wi-Fi", "Parking Available"],
    gallery: [
      "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80",
      "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80",
      "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80"
    ]
  },
  {
    name: "Tech Solutions Pro",
    category: "Technology",
    description: "Professional IT services and computer repair for businesses and individuals.",
    address: "456 Tech Park Boulevard",
    phone: "(555) 234-5678",
    email: "contact@techsolutions.com",
    website: "www.techsolutions.com",
    rating: 4.9,
    review_count: 89,
    image_url: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&q=80",
    featured: true,
    has_deals: false,
    hours: {
      monday: "9:00 AM - 6:00 PM",
      tuesday: "9:00 AM - 6:00 PM",
      wednesday: "9:00 AM - 6:00 PM",
      thursday: "9:00 AM - 6:00 PM",
      friday: "9:00 AM - 5:00 PM",
      saturday: "10:00 AM - 4:00 PM",
      sunday: "Closed"
    },
    amenities: ["Free Consultation", "Warranty Available", "Remote Support"],
    gallery: []
  },
  {
    name: "Green Leaf Wellness",
    category: "Healthcare",
    description: "Holistic health center offering yoga, massage therapy, and wellness programs.",
    address: "789 Wellness Avenue",
    phone: "(555) 345-6789",
    email: "info@greenleafwellness.com",
    website: "www.greenleafwellness.com",
    rating: 4.7,
    review_count: 156,
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&q=80",
    featured: false,
    has_deals: true,
    deal_description: "First massage session 50% off for new clients",
    hours: {
      monday: "8:00 AM - 8:00 PM",
      tuesday: "8:00 AM - 8:00 PM",
      wednesday: "8:00 AM - 8:00 PM",
      thursday: "8:00 AM - 8:00 PM",
      friday: "8:00 AM - 6:00 PM",
      saturday: "9:00 AM - 5:00 PM",
      sunday: "10:00 AM - 4:00 PM"
    },
    amenities: ["Parking Available", "Wheelchair Accessible", "Group Classes"],
    gallery: []
  }
]

businesses_data.each do |business_data|
  Business.create!(business_data.merge(user: partner_user))
end

puts "Seed data created successfully!"
puts "Admin user: admin@preferreddeals.com / password123"
puts "Regular user: john@example.com / password123"
puts "Partner user: jane@example.com / password123"