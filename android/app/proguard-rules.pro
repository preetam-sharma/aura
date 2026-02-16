# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Specific
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# App Specific (Aura)
-keep class com.aura.finance.app.** { *; }

# Google Play Services & Play Core
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
