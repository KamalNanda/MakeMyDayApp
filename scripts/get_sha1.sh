#!/usr/bin/env bash
# Run from project root: ./scripts/get_sha1.sh
# Prints debug keystore SHA-1 and instructions to fix Google Sign-In ApiException 10.

set -e
cd "$(dirname "$0")/.."

echo "Fetching debug SHA-1..."
echo ""

KEYSTORE="${ANDROID_DEBUG_KEYSTORE:-$HOME/.android/debug.keystore}"

if command -v keytool &>/dev/null && [[ -f "$KEYSTORE" ]]; then
  SHA1=$(keytool -list -v -keystore "$KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:" | sed 's/.*SHA1: *//')
else
  SHA1=""
fi

if [[ -z "$SHA1" ]]; then
  echo "Run one of these to get your SHA-1:"
  echo "  cd android && ./gradlew signingReport"
  echo "  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
  echo ""
else
  echo "Debug SHA-1: $SHA1"
  echo ""
fi

echo "Fix ApiException 10 (DEVELOPER_ERROR):"
echo "  1. Open: https://console.firebase.google.com/project/make-my-day-now/settings/general"
echo "  2. Your apps > Android (com.makemyday.makemyday) > Add fingerprint"
echo "  3. Add your SHA-1 (see above)"
echo "  4. Download new google-services.json"
echo "  5. Replace android/app/google-services.json"
echo "  6. Uninstall app, then: flutter clean && flutter run"
echo ""
