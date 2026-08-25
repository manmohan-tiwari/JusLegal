# Keep Hive classes
-keep class io.hivedb.** { *; }
-keep class com.hivedb.** { *; }
-keep class hive.** { *; }
-dontwarn io.hivedb.**
-dontwarn com.hivedb.**
-dontwarn hive.**

# Keep Firebase classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Dio classes
-keep class io.dio.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn io.dio.**
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep model classes
-keep class com.juslegal.app.models.** { *; }
-keep class com.juslegal.app.** { *; }

# Keep Gson classes
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep generic signatures
-keepattributes Signature
-keepattributes *Annotation*

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
