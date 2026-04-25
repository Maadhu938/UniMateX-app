# UniMateX ProGuard Rules

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Core (required for Play Store)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Google Play Core tasks
-keep class com.google.android.play.core.tasks.** { *; }

# Hive
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Keep model classes
-keep class com.unimatex.app.domain.models.** { *; }
-keep class com.unimatex.app.data.** { *; }

# General
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile