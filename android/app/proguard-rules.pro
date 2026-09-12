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

# ML Kit discovers its components through reflection during provider startup.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_bundled_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_bundled_latin.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_bundled_impl.** { *; }
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.latin.** { *; }
-keep class com.google.mlkit.vision.text.internal.** { *; }
-keep class com.google.mlkit.common.internal.** { *; }
-keep class com.google.mlkit.common.sdkinternal.** { *; }
-keepnames class com.google.mlkit.common.internal.MlKitComponentDiscoveryService
-keepnames class com.google.mlkit.common.internal.MlKitInitProvider
-keepclassmembers class * {
    @com.google.firebase.components.Component <init>(...);
}
-keepnames @com.google.android.gms.common.annotation.KeepName class *
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_**
