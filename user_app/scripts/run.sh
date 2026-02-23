#!/bin/bash
#
# AssignX User App - Flutter Run Script
# ======================================
# This script loads all credentials and runs the Flutter app
#
# Usage:
#   ./scripts/run.sh              # Run in debug mode
#   ./scripts/run.sh -d <device>  # Run on specific device
#   ./scripts/run.sh --release    # Run in release mode
#   ./scripts/run.sh --build-apk  # Build release APK
#   ./scripts/run.sh --build-ios  # Build iOS release
#   ./scripts/run.sh --clean      # Clean and run
#
# Author: AssignX Team
# ======================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║          AssignX User App - Flutter               ║"
echo "║              Build & Run Script                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================
# CREDENTIALS CONFIGURATION
# ============================================

# Supabase Configuration
SUPABASE_URL="https://eowrlcwcqrpavpfspcza.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvd3JsY3djcXJwYXZwZnNwY3phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY3NDgwNzEsImV4cCI6MjA4MjMyNDA3MX0.nnFxNJA2rBesIV-3mSj7zlBWCH0sP0RQjxGt5NrXUBI"

# Google OAuth Configuration
GOOGLE_WEB_CLIENT_ID="224490208184-iiri7u0nnu17r26b5vsh1ksc0otnm73c.apps.googleusercontent.com"

# Razorpay Configuration (Test Mode)
RAZORPAY_KEY_ID="rzp_test_Rv45IObrwfKRyf"
RAZORPAY_TEST_MODE="true"

# API Base URL (for server-side operations)
# NOTE: For Android emulator, localhost refers to the emulator itself.
# Use 10.0.2.2 to reach the host machine's localhost.
# This will be auto-detected below based on target device.
API_BASE_URL_LOCALHOST="http://localhost:3000"
API_BASE_URL_ANDROID_EMU="http://10.0.2.2:3000"
API_BASE_URL="$API_BASE_URL_LOCALHOST"  # Default, updated below

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME="drknn3ujj"

# ============================================
# BUILD DART DEFINES
# ============================================

DART_DEFINES=""
DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_URL=$SUPABASE_URL"
DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
DART_DEFINES="$DART_DEFINES --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID"
DART_DEFINES="$DART_DEFINES --dart-define=RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID"
DART_DEFINES="$DART_DEFINES --dart-define=RAZORPAY_TEST_MODE=$RAZORPAY_TEST_MODE"
DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=$API_BASE_URL"
DART_DEFINES="$DART_DEFINES --dart-define=CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME"

# ============================================
# DEFAULT DEVICE PREFERENCE
# ============================================
# Set to "android" to prefer Android emulator/device
# Set to "chrome" for web, "ios" for iOS simulator
# Set to "" to let Flutter prompt when multiple devices available
DEFAULT_DEVICE_TYPE="android"

# ============================================
# PARSE ARGUMENTS
# ============================================

MODE="debug"
DEVICE=""
BUILD_TYPE=""
CLEAN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        --release)
            MODE="release"
            shift
            ;;
        --profile)
            MODE="profile"
            shift
            ;;
        --build-apk)
            BUILD_TYPE="apk"
            shift
            ;;
        --build-appbundle)
            BUILD_TYPE="appbundle"
            shift
            ;;
        --build-ios)
            BUILD_TYPE="ios"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo -e "${YELLOW}Usage:${NC}"
            echo "  ./scripts/run.sh [options]"
            echo ""
            echo -e "${YELLOW}Options:${NC}"
            echo "  -d, --device <id>    Target device ID or name"
            echo "  --release            Run in release mode"
            echo "  --profile            Run in profile mode"
            echo "  --build-apk          Build release APK"
            echo "  --build-appbundle    Build release App Bundle (for Play Store)"
            echo "  --build-ios          Build iOS release"
            echo "  --clean              Run flutter clean first"
            echo "  -v, --verbose        Verbose output"
            echo "  -h, --help           Show this help"
            echo ""
            echo -e "${YELLOW}Examples:${NC}"
            echo "  ./scripts/run.sh                    # Debug on default device"
            echo "  ./scripts/run.sh -d chrome          # Run on Chrome (web)"
            echo "  ./scripts/run.sh -d emulator-5554   # Run on Android emulator"
            echo "  ./scripts/run.sh --release          # Run release build"
            echo "  ./scripts/run.sh --build-apk        # Build APK for distribution"
            echo "  ./scripts/run.sh --clean --release  # Clean build in release mode"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================
# PRE-FLIGHT CHECKS
# ============================================

echo -e "${BLUE}[1/4] Pre-flight checks...${NC}"

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Show Flutter version
if [ "$VERBOSE" = true ]; then
    echo -e "${CYAN}Flutter version:${NC}"
    flutter --version
fi

# Navigate to project root (parent of scripts directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo -e "${GREEN}  Project directory: $PROJECT_DIR${NC}"

# ============================================
# CLEAN (if requested)
# ============================================

if [ "$CLEAN" = true ]; then
    echo -e "${BLUE}[2/4] Cleaning project...${NC}"
    flutter clean
    flutter pub get
else
    echo -e "${BLUE}[2/4] Getting dependencies...${NC}"
    flutter pub get
fi

# ============================================
# SHOW CONFIGURATION
# ============================================

echo -e "${BLUE}[3/4] Configuration:${NC}"
echo -e "  ${CYAN}Mode:${NC} $MODE"
echo -e "  ${CYAN}Supabase:${NC} $SUPABASE_URL"
echo -e "  ${CYAN}Razorpay:${NC} $RAZORPAY_KEY_ID (Test: $RAZORPAY_TEST_MODE)"
echo -e "  ${CYAN}API URL:${NC} $API_BASE_URL"
echo -e "  ${CYAN}Cloudinary:${NC} $CLOUDINARY_CLOUD_NAME"

if [ -n "$DEVICE" ]; then
    echo -e "  ${CYAN}Device:${NC} $DEVICE"
fi

# ============================================
# AUTO-SELECT DEVICE
# ============================================

# If no device specified, try to auto-select based on DEFAULT_DEVICE_TYPE
if [ -z "$DEVICE" ] && [ -n "$DEFAULT_DEVICE_TYPE" ] && [ -z "$BUILD_TYPE" ]; then
    echo -e "${BLUE}[3.5/4] Auto-selecting $DEFAULT_DEVICE_TYPE device...${NC}"

    # Get list of available devices
    AVAILABLE_DEVICES=$(flutter devices --machine 2>/dev/null | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

    case $DEFAULT_DEVICE_TYPE in
        android)
            # Look for Android emulator or device
            for dev in $AVAILABLE_DEVICES; do
                if [[ "$dev" == emulator* ]] || [[ "$dev" == *android* ]] || [[ "$dev" =~ ^[A-Z0-9]{10,}$ ]]; then
                    DEVICE="$dev"
                    echo -e "${GREEN}  Auto-selected: $DEVICE${NC}"
                    break
                fi
            done
            ;;
        chrome)
            DEVICE="chrome"
            echo -e "${GREEN}  Auto-selected: chrome${NC}"
            ;;
        ios)
            for dev in $AVAILABLE_DEVICES; do
                if [[ "$dev" == *iPhone* ]] || [[ "$dev" == *iPad* ]] || [[ "$dev" == *simulator* ]]; then
                    DEVICE="$dev"
                    echo -e "${GREEN}  Auto-selected: $DEVICE${NC}"
                    break
                fi
            done
            ;;
    esac

    if [ -z "$DEVICE" ]; then
        echo -e "${YELLOW}  No $DEFAULT_DEVICE_TYPE device found, Flutter will prompt...${NC}"
    fi
fi

# ============================================
# ADJUST API_BASE_URL FOR ANDROID EMULATOR
# ============================================
# Android emulator can't reach localhost on the host - use 10.0.2.2 instead
if [[ "$DEVICE" == emulator* ]] || [[ "$DEFAULT_DEVICE_TYPE" == "android" && -z "$DEVICE" ]]; then
    # Check if we're targeting an emulator
    if [[ "$DEVICE" == emulator* ]] || flutter devices 2>/dev/null | grep -q "emulator"; then
        API_BASE_URL="$API_BASE_URL_ANDROID_EMU"
        echo -e "${CYAN}  Using Android emulator API URL: $API_BASE_URL${NC}"
    fi
fi

# Rebuild DART_DEFINES with correct API_BASE_URL
DART_DEFINES=""
DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_URL=$SUPABASE_URL"
DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
DART_DEFINES="$DART_DEFINES --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID"
DART_DEFINES="$DART_DEFINES --dart-define=RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID"
DART_DEFINES="$DART_DEFINES --dart-define=RAZORPAY_TEST_MODE=$RAZORPAY_TEST_MODE"
DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=$API_BASE_URL"
DART_DEFINES="$DART_DEFINES --dart-define=CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME"

# ============================================
# BUILD OR RUN
# ============================================

echo -e "${BLUE}[4/4] Building & Running...${NC}"

# Build device argument
DEVICE_ARG=""
if [ -n "$DEVICE" ]; then
    DEVICE_ARG="-d $DEVICE"
fi

# Execute build or run command
case $BUILD_TYPE in
    apk)
        echo -e "${YELLOW}Building Release APK...${NC}"
        flutter build apk --release $DART_DEFINES
        echo -e "${GREEN}APK built successfully!${NC}"
        echo -e "${CYAN}Location: build/app/outputs/flutter-apk/app-release.apk${NC}"
        ;;
    appbundle)
        echo -e "${YELLOW}Building Release App Bundle...${NC}"
        flutter build appbundle --release $DART_DEFINES
        echo -e "${GREEN}App Bundle built successfully!${NC}"
        echo -e "${CYAN}Location: build/app/outputs/bundle/release/app-release.aab${NC}"
        ;;
    ios)
        echo -e "${YELLOW}Building iOS Release...${NC}"
        flutter build ios --release $DART_DEFINES
        echo -e "${GREEN}iOS build completed!${NC}"
        ;;
    *)
        # Run the app
        case $MODE in
            release)
                echo -e "${YELLOW}Running in RELEASE mode...${NC}"
                flutter run --release $DEVICE_ARG $DART_DEFINES
                ;;
            profile)
                echo -e "${YELLOW}Running in PROFILE mode...${NC}"
                flutter run --profile $DEVICE_ARG $DART_DEFINES
                ;;
            *)
                echo -e "${YELLOW}Running in DEBUG mode...${NC}"
                flutter run $DEVICE_ARG $DART_DEFINES
                ;;
        esac
        ;;
esac

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║                    Complete!                      ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"
