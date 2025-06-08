import 'package:flutter/material.dart';

// Modern color scheme with purple/blue theme
const primaryColor = Color(0xFF6366F1); // Modern indigo
const secondaryColor = Color(0xFFEC4899); // Modern pink
const accentColor = Color(0xFF8B5CF6); // Purple accent

const textColor = Color(0xFF1F2937);
const lightgrayColor = Color(0x44948282);
const whiteColor = Color(0xFFFFFFFF);
const blackColor = Color(0xFF111827);

// Light theme colors
Color lightBackgroundColor = const Color(0xFFFAFAFA);
Color lightTextColor = const Color(0xFF374151);
Color lightCardColor = const Color(0xFFFFFFFF);

// Dark theme colors
Color darkBackgroundColor = const Color(0xFF0F172A);
Color darkTextColor = const Color(0xFFF1F5F9);
Color darkCardColor = const Color(0xFF1E293B);

// Modern gradient combinations
const modernPurple = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
);

const modernBlue = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
);

const modernPink = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
);

const grayBack = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF334155), Color(0xFF1E293B)],
);

const grayWhite = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
);

const buttonGradi = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
);

const contactGradi = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
);

// Modern shadow effects
BoxShadow primaryColorShadow = BoxShadow(
  color: primaryColor.withOpacity(0.3),
  blurRadius: 20.0,
  offset: const Offset(0.0, 8.0),
  spreadRadius: 0,
);

BoxShadow modernCardShadow = BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 24.0,
  offset: const Offset(0.0, 4.0),
  spreadRadius: 0,
);

BoxShadow blackColorShadow = BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16.0,
  offset: const Offset(0.0, 4.0),
  spreadRadius: 0,
);

BoxShadow glowShadow = BoxShadow(
  color: primaryColor.withOpacity(0.4),
  blurRadius: 32.0,
  offset: const Offset(0.0, 0.0),
  spreadRadius: 0,
);
