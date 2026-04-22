#!/bin/bash
# HILWAY Web Deployment Script
# This script builds the Flutter Web app and deploys it to Vercel.

# Ensure we are in the project root
cd "$(dirname "$0")/.."

echo "🚀 Building Flutter Web (Release)..."
flutter build web --release

echo "📦 Injecting Vercel configuration for SPA routing..."
if [ -f "vercel.json" ]; then
    cp vercel.json build/web/
    echo "✅ vercel.json copied to build/web/"
else
    echo "⚠️ Warning: vercel.json not found in root. SPA routing might fail on refresh."
fi

# Check if vercel CLI is installed
if command -v vercel &> /dev/null
then
    echo "☁️ Deploying to Vercel..."
    vercel deploy build/web --prod
else
    echo "💡 Vercel CLI not found."
    echo "👉 Please run: npm install -g vercel"
    echo "👉 Then run: vercel deploy build/web --prod"
fi

echo "✨ Done!"
