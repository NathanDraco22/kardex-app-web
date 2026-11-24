allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Workaround para file_picker 11.0.2 con AGP 9.x + android.builtInKotlin=false:
// file_picker omite aplicar KGP cuando AGP >= 9 pensando que builtInKotlin está activo,
// pero el regex de FlutterPluginUtils detecta la línea dentro del `if (!isAgp9OrAbove)`
// y tampoco lo aplica automáticamente.
// Además, en AGP 9.3.1 sobre JDK 17, CommentDetector (EasterEgg/StopShip) falla con
// NoSuchMethodError: List.removeLast() (API de JDK 21).
subprojects {
    if (name == "file_picker") {
        pluginManager.withPlugin("com.android.library") {
            if (!pluginManager.hasPlugin("org.jetbrains.kotlin.android") &&
                !pluginManager.hasPlugin("com.android.built-in-kotlin")
            ) {
                pluginManager.apply("org.jetbrains.kotlin.android")
            }
        }
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }

    pluginManager.withPlugin("com.android.library") {
        extensions.configure(com.android.build.api.dsl.LibraryExtension::class.java) {
            lint {
                disable += listOf("EasterEgg", "StopShip")
            }
        }
    }
    pluginManager.withPlugin("com.android.application") {
        extensions.configure(com.android.build.api.dsl.ApplicationExtension::class.java) {
            lint {
                disable += listOf("EasterEgg", "StopShip")
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
