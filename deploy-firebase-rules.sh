#!/bin/bash

# Deploy Firebase Rules
echo "🚀 Deploying Firebase rules..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Login to Firebase (if not already logged in)
echo "🔐 Checking Firebase authentication..."
if ! firebase projects:list &> /dev/null; then
    echo "Please login to Firebase..."
    firebase login
fi

# Deploy Firestore rules
echo "📋 Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Deploy Storage rules
echo "💾 Deploying Storage rules..."
firebase deploy --only storage

echo "✅ Firebase rules deployed successfully!"
echo ""
echo "📝 Rules deployed:"
echo "- Firestore rules: Allow public read, admin write"
echo "- Storage rules: Allow public read, authenticated write"
