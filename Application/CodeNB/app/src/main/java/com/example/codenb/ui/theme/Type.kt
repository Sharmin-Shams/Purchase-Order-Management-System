package com.example.codenb.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import com.example.codenb.R

val interFontFamily = FontFamily(
    Font(R.font.inter_variable_font)  // Replace with your font file name
)

// Default Material 3 typography values
val baseline = Typography()

val AppTypography = Typography(
    displayLarge = baseline.displayLarge.copy(fontFamily = interFontFamily),
    displayMedium = baseline.displayMedium.copy(fontFamily = interFontFamily),
    displaySmall = baseline.displaySmall.copy(fontFamily = interFontFamily),
    headlineLarge = baseline.headlineLarge.copy(fontFamily = interFontFamily),
    headlineMedium = baseline.headlineMedium.copy(fontFamily = interFontFamily),
    headlineSmall = baseline.headlineSmall.copy(fontFamily = interFontFamily),
    titleLarge = baseline.titleLarge.copy(fontFamily = interFontFamily),
    titleMedium = baseline.titleMedium.copy(fontFamily = interFontFamily),
    titleSmall = baseline.titleSmall.copy(fontFamily = interFontFamily),
    bodyLarge = baseline.bodyLarge.copy(fontFamily = interFontFamily),
    bodyMedium = baseline.bodyMedium.copy(fontFamily = interFontFamily),
    bodySmall = baseline.bodySmall.copy(fontFamily = interFontFamily),
    labelLarge = baseline.labelLarge.copy(fontFamily = interFontFamily),
    labelMedium = baseline.labelMedium.copy(fontFamily = interFontFamily),
    labelSmall = baseline.labelSmall.copy(fontFamily = interFontFamily),
)