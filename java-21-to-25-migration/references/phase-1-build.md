# Phase 1 — Build & Infrastructure

**Goal**: Make the build capable of producing Java 25 bytecode and running the test suite on JDK 25.

## 1.1 Build files

### Maven (`pom.xml`)

Update all Java version properties:
- `<java.version>` → `25`
- `<maven.compiler.source>` / `<maven.compiler.target>` / `<maven.compiler.release>` → `25`
- `maven-compiler-plugin` `<source>`, `<target>`, `<release>` → `25`

**Use `--release 25`** (or `<release>25</release>`) instead of separate `-source`/`-target`. Per Oracle guide: supported `-source`/`-target` values are 25 (default) through 9. Value 8 is deprecated.

Verify plugin versions — **known landmine**: there are reported Java 25 compatibility issues in specific `maven-compiler-plugin` versions (see [GitHub #986](https://github.com/apache/maven-compiler-plugin/issues/986)). Fix is: upgrade the plugin (and sometimes Maven itself).
- `maven-compiler-plugin` ≥ 3.14.0 (check for 25 compat fixes)
- `maven-surefire-plugin` ≥ 3.5
- `maven-failsafe-plugin` ≥ 3.5
- Maven itself ≥ 3.9.9

Check `<argLine>` and `MAVEN_OPTS` for obsolete JVM flags (see Phase 2.5).

If annotation processors stop running, add explicit `<proc>full</proc>` to compiler config (Phase 2.7).

### Gradle (`build.gradle` / `build.gradle.kts`)

**Known landmine**: There is real friction running Gradle 8 on JDK 25 (see [GitHub #35111](https://github.com/gradle/gradle/issues/35111)). Use **Gradle toolchains** to *compile/test* with JDK 25 even if Gradle itself runs on a different JDK:

```kotlin
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(25))
    }
}
```

Gradle's compatibility rules explicitly separate "running Gradle" from "using Java for compilation/testing" — exploit this. Keep the Gradle runtime on a known-good JDK if you hit wrapper failures.

Gradle wrapper must be ≥ 8.10 for JDK 25 compilation support.

### Framework compatibility

- **Spring Boot 4.0.2** officially states: "requires at least Java 17 and is compatible with versions up to and including Java 25" (see [Spring Boot System Requirements](https://docs.spring.io/spring-boot/system-requirements.html))
- Spring Boot applications can be converted to Native Image using GraalVM 25+

## 1.2 Dockerfiles

Update all base images:
- `eclipse-temurin:21-jdk` → `eclipse-temurin:25-jdk`
- `eclipse-temurin:21-jre` → `eclipse-temurin:25-jre`
- `amazoncorretto:21` → `amazoncorretto:25`
- Any internal/corporate images (e.g., `corretto-jdk21-buildenv` → `corretto-jdk25-buildenv`)

**Multi-stage Docker builds**: If the project uses a multi-stage build (or should), follow this pattern:
- **Build stage**: Use the JDK image (`eclipse-temurin:25-jdk`) — needed for compilation, annotation processing, and test execution
- **Run stage**: Use the JRE image (`eclipse-temurin:25-jre`) — smaller footprint, no compiler or dev tools
- Preserve the existing Dockerfile pattern: if the codebase already uses multi-stage builds, keep the same structure and only update the image tags. If it uses a single-stage JDK image, don't introduce multi-stage unless asked.
- Verify the run stage still works: some apps need JDK-only tools at runtime (e.g., `jstack`, `jmap`, `jcmd`, native compilation). If the existing Dockerfile uses JDK for the run stage, there's likely a reason — keep it.

Check for JVM flags in `ENTRYPOINT`/`CMD`/`ENV` — remove obsolete flags (Phase 2.5).

## 1.3 CI configuration and version pinning

- `.java-version` → `25`
- `.sdkmanrc` → `java=25.0.x-tem`
- `.tool-versions` → `java temurin-25.0.x`
- GitHub Actions `setup-java`: `java-version: '25'`
- Jenkinsfile / GitLab CI: update JDK tool references

**Keep builds reproducible via toolchains** so developers can use a stable JDK locally while CI builds target 25.

## 1.4 First compilation and test

```bash
mvn clean compile -DskipTests
mvn test
```

If compilation fails, triage:
1. **Plugin version** → upgrade maven-compiler-plugin, surefire, etc.
2. **"unknown release" error** → upgrade the plugin (known issue)
3. **Dependency incompatibility** → update the library (Phase 2.15)
4. **Removed API** → fix in Phase 2
5. **`--add-opens`/`--add-exports`** → check if still needed after dependency updates

Record baseline: total tests, pass, fail, skip. **All tests should pass before proceeding.**
