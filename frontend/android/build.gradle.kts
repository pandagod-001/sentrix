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

// Compatibility shim for legacy Android libraries that do not declare namespace.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val getNamespace = androidExt.javaClass.methods.find {
            it.name == "getNamespace" && it.parameterCount == 0
        } ?: return@afterEvaluate
        val setNamespace = androidExt.javaClass.methods.find {
            it.name == "setNamespace" && it.parameterCount == 1
        } ?: return@afterEvaluate

        val currentNamespace = getNamespace.invoke(androidExt) as? String
        if (currentNamespace.isNullOrBlank()) {
            val safeProjectName = project.name.replace(Regex("[^A-Za-z0-9_]"), "_")
            setNamespace.invoke(androidExt, "autofix.$safeProjectName")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
