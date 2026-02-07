-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
-ignorewarnings

-optimizationpasses 5
-allowaccessmodification
-repackageclasses ''

-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*,Signature,Exception

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

-keep class **.GeneratedPluginRegistrant { *; }

-keep class com.nematmirzayev.carcat.MainActivity { *; }

-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

-keep class com.flutter.awesome_dio_interceptor.** { *; }

-keep class http_parser.** { *; }
-dontwarn http_parser.**

-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.vision.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

-keep class io.flutter.plugins.camera.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

-keep class io.flutter.plugins.imagepicker.** { *; }

-keep class hive_flutter.** { *; }
-keep class io.flutter.plugins.hive.** { *; }

-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

-keep class io.flutter.plugins.pathprovider.** { *; }

-keep class io.flutter.plugins.urllauncher.** { *; }

-keep class com.baseflow.permissionhandler.** { *; }

-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

-keep class com.pichillilorenzo.flutter_svg.** { *; }

-keep class io.flutter.plugins.googlefonts.** { *; }

-keep class pointycastle.** { *; }
-dontwarn pointycastle.**

-keep class io.flutter.plugins.fluttertoast.** { *; }

-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.view.View
-keep public class * extends androidx.fragment.app.Fragment

-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepclassmembers class **.R$* {
    public static <fields>;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
}

-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn edu.umd.cs.findbugs.annotations.**