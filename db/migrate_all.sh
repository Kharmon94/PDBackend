#!/bin/bash
# Migration script for Preferred Deals API
# Runs all pending migrations and seeds database

echo "🚀 Running database migrations..."
bundle exec rails db:migrate

echo "✅ Migrations complete!"
echo ""
echo "📊 Seeding database with test accounts..."
bundle exec rails db:seed

echo ""
echo "✅ Database setup complete!"
echo ""
echo "Test accounts created:"
echo "  👑 Admin: admin@preferreddeals.com / Admin123!"
echo "  👤 User: user@preferreddeals.com / User123!"
echo "  🏢 Partner: partner@preferreddeals.com / Partner123!"
echo "  🤝 Distribution: distribution@preferreddeals.com / Distribution123!"
echo ""
echo "⚠️  IMPORTANT: Change all passwords in production!"

