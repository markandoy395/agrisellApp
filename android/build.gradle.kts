allprojects {
    repositories {
        google()
        mavenCentral()
    }

    configurations.configureEach {
        resolutionStrategy.eachDependency {
            // integration_test uses floating versions that require Maven metadata
            // even when the artifacts are cached. Pin only those SDK requests;
            // leave explicit versions and normal transitive conflict resolution intact.
            val pinnedVersion = when (requested.toString()) {
                "androidx.test:runner:1.2+" -> "1.2.0"
                "androidx.test:rules:1.2+" -> "1.2.0"
                "androidx.test.espresso:espresso-core:3.3+" -> "3.3.0"
                else -> null
            }
            if (pinnedVersion != null) {
                useVersion(pinnedVersion)
                because("Avoid floating AndroidX versions from Flutter integration_test")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
