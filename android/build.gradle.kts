plugins {
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("dev.flutter.flutter-gradle-plugin") apply false // شلنا الـ version من هنا
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("${project.projectDir}/../build"))

subprojects {
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}