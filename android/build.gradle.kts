allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
    val fixNamespace = {
        val extension = project.extensions.findByType<com.android.build.gradle.BaseExtension>()
        if (extension != null && extension.namespace == null) {
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val manifestXml = manifestFile.readText()
                val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestXml)
                if (packageMatch != null) {
                    extension.namespace = packageMatch.groupValues[1]
                }
            }
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate { fixNamespace() }
    }
}
