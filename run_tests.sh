# Test Runner Script
# Run all tests and generate coverage report

echo "🧪 WAZEET App - Test Suite Runner"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "🔍 Running Flutter Analyze..."
flutter analyze --no-pub > analyze_report.txt 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Static analysis passed${NC}"
else
    echo -e "${YELLOW}⚠️  Static analysis found issues. See analyze_report.txt${NC}"
    cat analyze_report.txt
fi

echo ""
echo "🧪 Running Unit Tests..."
flutter test test/ --coverage --coverage-path=coverage/lcov.info

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Unit tests passed${NC}"
else
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

echo ""
echo "🔗 Running Integration Tests..."
flutter test integration_test/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Integration tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Integration tests failed or not run${NC}"
fi

echo ""
echo "📊 Generating Coverage Report..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ Coverage report generated at coverage/html/index.html${NC}"
    echo "   Open with: open coverage/html/index.html"
else
    echo -e "${YELLOW}⚠️  genhtml not installed. Install with: brew install lcov${NC}"
fi

echo ""
echo "📈 Coverage Summary:"
if command -v lcov &> /dev/null; then
    lcov --summary coverage/lcov.info 2>&1 | grep -A 3 "Summary"
else
    echo -e "${YELLOW}⚠️  lcov not installed. Install with: brew install lcov${NC}"
fi

echo ""
echo "=================================="
echo "✅ Test suite completed!"
echo ""
echo "📄 Generated files:"
echo "   - analyze_report.txt (static analysis)"
echo "   - coverage/lcov.info (coverage data)"
echo "   - coverage/html/index.html (coverage report)"
echo ""
echo "🎯 Next steps:"
echo "   1. Review analyze_report.txt for issues"
echo "   2. Open coverage report in browser"
echo "   3. Fix failing tests"
echo "   4. Aim for 60%+ coverage"
