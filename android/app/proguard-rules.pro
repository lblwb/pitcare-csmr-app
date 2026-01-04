# Сохраняем имена классов, которые использует рефлексия (например, JSON-сериализация)
-keep class ru.lblw.pit_care.model.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName *;
}

# Flutter-specific
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
# Если используете Firebase, Crashlytics и т.д. — добавьте их правила