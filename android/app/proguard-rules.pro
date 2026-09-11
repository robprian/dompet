# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent R8 from removing native platform channels and callbacks
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-dontwarn io.flutter.plugin.**
-dontwarn com.google.android.play.core.**

# Quick Actions and Shortcuts
-keep class io.flutter.plugins.quickactions.** { *; }
-keep class androidx.core.content.pm.ShortcutInfoCompat** { *; }
-keep class androidx.core.content.pm.ShortcutManagerCompat** { *; }
-keep class androidx.core.graphics.drawable.IconCompat** { *; }

# ML Kit text recognition references optional language models (Chinese,
# Devanagari, Japanese, Korean) that are not bundled. Silence R8 so the Latin
# recognizer we actually use builds without pulling every script.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }

