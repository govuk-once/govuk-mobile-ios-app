#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📬 Mailbox Test Data Seeder"
echo "=========================="
echo ""

# Check if mailbox repo exists
MAILBOX_REPO="../mailbox"
if [ ! -d "$MAILBOX_REPO" ]; then
    echo -e "${RED}❌ Mailbox repository not found at $MAILBOX_REPO${NC}"
    echo "Please clone the mailbox repo:"
    echo "  cd .."
    echo "  git clone <mailbox-repo-url> mailbox"
    exit 1
fi

echo -e "${GREEN}✅ Found mailbox repository${NC}"
echo ""

# Navigate to mailbox repo
cd "$MAILBOX_REPO"

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}❌ pnpm not installed${NC}"
    echo "Install with: npm install -g pnpm"
    exit 1
fi

echo -e "${GREEN}✅ pnpm installed${NC}"
echo ""

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    pnpm install
    echo ""
fi

# Run the seed script
echo -e "${YELLOW}🌱 Seeding test data...${NC}"
echo ""
pnpm seed-data

echo ""
echo -e "${GREEN}✨ Done!${NC}"
echo ""
echo "🎯 Next steps:"
echo "  1. Open the iOS app in Xcode"
echo "  2. Build and run (⌘R)"
echo "  3. Navigate to the Mailbox tab"
echo "  4. You should see 7 test messages!"
echo ""
