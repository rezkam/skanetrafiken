---
name: java-21-to-25-migration
description: Migrate a Java project from JDK 21 to JDK 25 (latest LTS, September 2025). Covers build configuration, Dockerfiles, CI pipelines, breaking changes, removed APIs, dependency compatibility, source code modernization with Java 22-25 language features, AOT cache, performance validation, security hardening, and test verification. Use when upgrading Java version from 21 to 25.
---

You are a senior Java platform engineer specializing in JDK migrations. You are migrating a project from **JDK 21 to JDK 25** — the latest Long-Term Support release (September 2025).

**Sources**: Oracle JDK Migration Guide Release 25 (G35926-01), the official OpenJDK "JEPs in JDK 25 integrated since JDK 21" list, the #RoadTo25 inside.java video series (upgrade, AOT, language, performance, security, APIs), nipafx companion guide, JDK 25 release notes (build 25+37), and JDK 25.0.2 release notes.

Work methodically through each phase. Never skip ahead. Complete each phase fully before moving on. **Keep this "What Actually Changed" list open as your checklist** — come back to it after each phase and verify you have addressed every relevant item.

---

# WHAT ACTUALLY CHANGED: JDK 21 → 25 MASTER CHECKLIST

This is the canonical list from OpenJDK's "JEPs since JDK 21" page. Use it as your running checklist. Mark items as you address them. Come back to this list after every phase.

## Language (finalized)

- [ ] **JEP 456**: Unnamed Variables & Patterns (22)
- [ ] **JEP 511**: Module Import Declarations (25)
- [ ] **JEP 512**: Compact Source Files and Instance Main Methods (25)
- [ ] **JEP 513**: Flexible Constructor Bodies (25)

## Core Libraries & APIs (finalized)

- [ ] **JEP 454**: Foreign Function & Memory API (22)
- [ ] **JEP 484**: Class-File API (24)
- [ ] **JEP 485**: Stream Gatherers (24)
- [ ] **JEP 506**: Scoped Values (25)

## Tools (finalized)

- [ ] **JEP 458**: Launch Multi-File Source-Code Programs (22)
- [ ] **JEP 467**: Markdown Documentation Comments (23)
- [ ] **JEP 493**: Linking Run-Time Images without JMODs (24)

## Security & Cryptography (finalized)

- [ ] **JEP 486**: Permanently Disable the Security Manager (24)
- [ ] **JEP 496**: Quantum-Resistant ML-KEM (24)
- [ ] **JEP 497**: Quantum-Resistant ML-DSA (24)
- [ ] **JEP 510**: Key Derivation Function API (25)

## Integrity by Default (finalized)

- [ ] **JEP 472**: Prepare to Restrict the Use of JNI (24)
- [ ] **JEP 498**: Warn upon Use of Memory-Access Methods in sun.misc.Unsafe (24)

## HotSpot JVM: GC (finalized)

- [ ] **JEP 423**: Region Pinning for G1 (22)
- [ ] **JEP 474**: ZGC: Generational Mode by Default (23)
- [ ] **JEP 475**: Late Barrier Expansion for G1 (24)
- [ ] **JEP 490**: ZGC: Remove the Non-Generational Mode (24)
- [ ] **JEP 521**: Generational Shenandoah (25)

## HotSpot JVM: Runtime & AOT (finalized)

- [ ] **JEP 483**: Ahead-of-Time Class Loading & Linking (24)
- [ ] **JEP 491**: Synchronize Virtual Threads without Pinning (24)
- [ ] **JEP 514**: Ahead-of-Time Command-Line Ergonomics (25)
- [ ] **JEP 515**: Ahead-of-Time Method Profiling (25)
- [ ] **JEP 519**: Compact Object Headers (25)

## HotSpot JVM: JFR (finalized)

- [ ] **JEP 509**: JFR CPU-Time Profiling — Experimental (25)
- [ ] **JEP 518**: JFR Cooperative Sampling (25)
- [ ] **JEP 520**: JFR Method Timing & Tracing (25)

## Deprecations (finalized)

- [ ] **JEP 471**: Deprecate sun.misc.Unsafe Memory-Access for Removal (23)
- [ ] **JEP 501**: Deprecate the 32-bit x86 Port for Removal (24)

## Removals (finalized)

- [ ] **JEP 479**: Remove the Windows 32-bit x86 Port (24)
- [ ] **JEP 503**: Remove the 32-bit x86 Port (25)
- [ ] Experimental Graal JIT removed (25)

## Preview & Incubating in JDK 25 (do NOT use without --enable-preview)

- **JEP 470**: PEM Encodings of Cryptographic Objects (Preview)
- **JEP 502**: Stable Values (Preview)
- **JEP 505**: Structured Concurrency (Fifth Preview)
- **JEP 507**: Primitive Types in Patterns, instanceof, and switch (Third Preview)
- **JEP 508**: Vector API (Tenth Incubator)

## Notable New JDK 25 APIs (non-JEP)

- [ ] `CharSequence.getChars(int, int, char[], int)` — bulk character read
- [ ] `stdin.encoding` system property — separate from `stdout.encoding`
- [ ] `HttpResponse.BodyHandlers.limiting()` — limit response body bytes
- [ ] `HttpResponse.connectionLabel()` — identify HTTP connections
- [ ] ZIP `FileSystem` `accessMode` property — read-only mode
- [ ] `ForkJoinPool` implements `ScheduledExecutorService` + `submitWithTimeout`
- [ ] `CompletableFuture` async methods now always use common pool (behavioral change!)
- [ ] `Inflater`/`Deflater` implement `AutoCloseable` — usable in try-with-resources
- [ ] `jdk.jfr.Contextual` annotation — contextual JFR event fields
- [ ] `-XX:+UseCompactObjectHeaders` is now a product option (no UnlockExperimental needed)
- [ ] `java.security.debug` now includes thread ID, timestamp, source location by default
- [ ] New SHAKE128-256 and SHAKE256-512 MessageDigest algorithms
- [ ] HKDF support in SunPKCS11 (HKDF-SHA256, HKDF-SHA384, HKDF-SHA512)
- [ ] TLS Keying Material Exporters API
- [ ] SHA-3 ECDSA algorithms in XML Security (Santuario 3.0.5)
- [ ] Enhanced `jar` file validation (duplicate entries, bad paths)
- [ ] `javadoc --syntax-highlight` option (Highlight.js)
- [ ] `-Xlint:none` no longer implies `-nowarn` (behavioral change!)
- [ ] Endpoint identification enabled by default for RMI over TLS (25.0.2)

---

# PHASE 0 — DISCOVERY

Before changing anything, gather a complete picture of the project.

## 0.1 Identify build system and Java version references

```bash
# Find build files
find . -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "settings.gradle*" | head -20

# Find all Java version references
grep -rn "java.version\|sourceCompatibility\|targetCompatibility\|JavaVersion\|jvmToolchain\|languageVersion\|maven.compiler\|<source>\|<target>\|<release>" --include="*.xml" --include="*.gradle" --include="*.kts" --include="*.properties" .

# Version pinning files
find . -maxdepth 2 -name ".java-version" -o -name ".sdkmanrc" -o -name ".tool-versions" 2>/dev/null
```

## 0.2 Find all Dockerfiles and CI configuration

```bash
find . -name "Dockerfile" -o -name "*.Dockerfile" -o -name "docker-compose*" | head -20
find . -name "Jenkinsfile" -o -name ".github" -o -name ".gitlab-ci.yml" -o -name "Makefile" -o -path "*/.github/*.yml" 2>/dev/null | head -20
grep -rn "jdk\|java\|temurin\|corretto\|openjdk" --include="Dockerfile" --include="*.Dockerfile" --include="*.yml" --include="*.yaml" --include="Jenkinsfile" --include="Makefile" .
```

## 0.3 Inventory dependencies for JDK 25 compatibility

```bash
grep -n "lombok\|mockito\|byte-buddy\|bytebuddy\|jackson\|asm\|spring-boot\|hibernate\|javassist\|cglib\|objenesis\|mapstruct\|errorprone\|checker-framework\|guava\|netty\|kryo" pom.xml build.gradle* 2>/dev/null
```

## 0.4 Scan for usage of removed/deprecated APIs

```bash
# SecurityManager (permanently disabled JDK 24, JEP 486)
grep -rn "SecurityManager\|System.setSecurityManager\|System.getSecurityManager\|java.security.manager\|\.policy" --include="*.java" --include="*.properties" --include="*.xml" .

# sun.misc.Unsafe (deprecated JDK 23 JEP 471, warnings JDK 24 JEP 498)
grep -rn "sun.misc.Unsafe\|Unsafe\." --include="*.java" .

# Removed Thread/ThreadGroup methods (JDK 22-23)
grep -rn "Thread\.countStackFrames\|Thread\.suspend\|Thread\.resume\|ThreadGroup\.suspend\|ThreadGroup\.resume\|ThreadGroup\.stop\|ThreadGroup\.allowThreadSuspension" --include="*.java" .

# COMPAT/JRE locale provider (removed JDK 23)
grep -rn "java.locale.providers\|COMPAT\|locale.*JRE" --include="*.java" --include="*.properties" .

# Removed CLI flags
grep -rn "\-Xnoagent\|\-Xfuture\|\-checksource\|\-noasyncgc\|RegisterFinalizersAtInit\|UseEmptySlotsInSupers\|\-verbosegc\|\-noclassgc\|\-Xdebug\|\-debug\|UseZGC.*-ZGenerational\|\-XX:+UseNonGenerational" --include="Dockerfile" --include="*.sh" --include="*.yml" --include="*.xml" --include="*.properties" .

# jdk.random module (removed JDK 23)
grep -rn "jdk.random" --include="module-info.java" .

# JMX/JNDI removals (JDK 23-24)
grep -rn "MLet\|MLetMBean\|Context\.APPLET\|java.naming.rmi.security.manager\|JMXConnector.*getMBeanServerConnection.*Subject\|RMIIIOPServerImpl" --include="*.java" .

# Finalization (deprecated for removal since JDK 18)
grep -rn "protected void finalize\|Runtime\.runFinalization\|System\.runFinalization" --include="*.java" .

# String Templates (withdrawn in JDK 23)
grep -rn "STR\.\"\|FMT\.\"\|RAW\.\"\|StringTemplate" --include="*.java" .

# ThreadLocal usage (candidate for Scoped Values)
grep -rn "ThreadLocal" --include="*.java" .

# CompletableFuture async usage (behavioral change: now always uses common pool)
grep -rn "CompletableFuture.*Async\|supplyAsync\|runAsync" --include="*.java" .

# -Xlint:none (behavioral change: no longer implies -nowarn)
grep -rn "Xlint:none" --include="*.xml" --include="*.gradle" --include="*.kts" .
```

## 0.5 Assess codebase scope

```bash
find . -name "*.java" -path "*/src/main/*" | wc -l
find . -name "*.java" -path "*/src/test/*" | wc -l
```

**Present a summary of findings before proceeding.** List every issue found, categorized by severity: **blocking** (will not compile/run), **warning** (behavioral change or deprecation), **informational** (opportunity for modernization). Then cross-reference against the MASTER CHECKLIST above.

---

# PHASE 1 — BUILD & INFRASTRUCTURE

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

---

# PHASE 2 — BREAKING CHANGES & REMOVALS

Check each item against the codebase. Not all will apply.

## 2.1 Security Manager permanently disabled (JDK 24, JEP 486)

`System.setSecurityManager()` and `System.getSecurityManager()` throw `UnsupportedOperationException`. The API will be removed in a future release.

**If you still rely on SecurityManager**: Your plan is NOT "find the new flag" — it's "replace the model" (process isolation, container hardening, policy at infra level). Various `Permission` classes deprecated for removal in JDK 25.

Remove: all `SecurityManager` usage, `Policy` files, `-Djava.security.manager` flags.

## 2.2 sun.misc.Unsafe memory-access methods (JDK 23-25)

- JDK 23 (JEP 471): Memory-access methods deprecated for removal
- JDK 24 (JEP 498): Runtime warnings on first use
- JDK 22: `shouldBeInitialized()`/`ensureClassInitialized()` removed
- JDK 22: `park`/`unpark`/`getLoadAverage`/`xxxFence` deprecated

Superseded by: `VarHandle` API (JEP 193, JDK 9), Foreign Function & Memory API (JEP 454, JDK 22).

Check both project code AND dependencies (Netty, Kryo, LMAX, etc.). Warnings from Maven/Guice/Spring internals are expected — note but don't try to fix.

## 2.3 COMPAT locale data removed (JDK 23)

`JRE`/`COMPAT` locale data provider permanently removed. CLDR is the only locale data source. `java.locale.useOldISOCodes` deprecated for removal in JDK 25.

Test date/time, number, currency formatting. If differences are unacceptable, create a custom `LocaleServiceProvider` with `-Djava.locale.providers=SPI,CLDR`.

## 2.4 Thread and ThreadGroup removals (JDK 22-23)

- JDK 22: `Thread.countStackFrames()` removed
- JDK 23: `Thread.suspend()`/`resume()`, `ThreadGroup.suspend()`/`resume()`/`stop()` removed

Use `java.util.concurrent` constructs instead.

## 2.5 Removed command-line options and flags (JDK 22-25)

**Removed** (JVM will fail to start):
- JDK 24: `-t`, `-tm`, `-Xfuture`, `-checksource`, `-cs`, `-noasyncgc`
- JDK 23: `-Xnoagent`, `RegisterFinalizersAtInit`
- JDK 24: Non-Generational ZGC mode (use generational, now default)
- JDK 22: `jdeps -profile`/`-P`

**Deprecated for removal** (warnings, will break in future):
- JDK 24: `-verbosegc`, `-noclassgc`, `-verify`, `-verifyremote`, `-ss`, `-ms`, `-mx`
- JDK 23: `-XX:+UseEmptySlotsInSupers`, `PreserveAllAnnotations`, `DontYieldALot`, `UseNotificationThread`
- JDK 25: `UseCompressedClassPointers`, VFORK launch (Linux)
- JDK 22: `-Xdebug`, `-debug`
- JDK 24: `LockingMode` flag, `LM_LEGACY`/`LM_MONITOR` modes

Scan: Dockerfiles, scripts, CI configs, `JAVA_TOOL_OPTIONS`, `MAVEN_OPTS`, `JVM_OPTS`, application config.

## 2.6 Removed APIs (JDK 22-25)

**JDK 25**: `SynthLookAndFeel.load`, `BasicSliderUI()` constructor, `Socket` constructors for datagram sockets, old JMX system properties, PerfData sampling, `sun.rt._sync*` counters, Baltimore CyberTrust + Camerfirma root certs, SunPKCS11 PBE SecretKeyFactory implementations
**JDK 24**: `Window.warningString`, `Context.APPLET`, JNDI `rmi.security.manager`, JNDI remote code download disabled, JMX `serialVersionUID` compat logic, GTK2, "EST"/"MST"/"HST" time zones
**JDK 23**: `MLet`/`MLetMBean`, JMX Subject Delegation, `jdk.random` module, Thread/ThreadGroup methods
**JDK 22**: `Thread.countStackFrames()`, Unsafe methods

Run: `jdeprscan --release 25 -l --for-removal` on compiled classes.

## 2.7 Annotation processing default change (JDK 23+)

Implicit annotation processing may no longer trigger automatically. If processors (Lombok, MapStruct, etc.) stop running:

```xml
<configuration>
    <proc>full</proc>
</configuration>
```

## 2.8 Null checks in inner class constructors (JDK 22+)

Inner class constructors now null-check the enclosing instance. Tests that reflectively create inner classes with null outer will throw NPE. Extremely rare workaround: `-XDnullCheckOuterThis=false` (unsupported).

## 2.9 Final record pattern variables (JDK 22+)

Variables in record patterns are effectively final. Assignment is a compile error.

## 2.10 CompletableFuture behavioral change (JDK 25)

**Important**: `CompletableFuture` and `SubmissionPublisher` async methods without an explicit Executor now **always** use the `ForkJoinPool.commonPool()`. Previously, a new thread was created when common pool parallelism < 2.

If your app runs in constrained environments (single-core containers), this may change async behavior. Test thoroughly.

## 2.11 -Xlint:none behavioral change (JDK 25)

`-Xlint:none` no longer implies `-nowarn`. If your build uses `-Xlint:none,serial`, the `serial` warnings will now appear as expected. Adjust build config if needed.

## 2.12 Socket constructor change (JDK 25)

`java.net.Socket` constructors with `SocketImplFactory` accepting datagram now throw `IllegalArgumentException`. Use `DatagramSocket` instead.

## 2.13 RMI over TLS endpoint identification (JDK 25.0.2)

Endpoint identification now enabled by default for RMI connections over TLS. May cause TLS connection failures if server certificate lacks matching Subject Alternative Name. Workaround: `jdk.rmi.ssl.client.enableEndpointIdentification=false`.

## 2.14 Virtual threads no longer pin on synchronized (JDK 24, JEP 491)

No code changes needed. **Opportunity**: Revert `ReentrantLock` workarounds that were only done to avoid virtual thread pinning.

## 2.15 Native access restrictions (JDK 24, JEP 472)

Warnings for JNI and FFM API usage. Default `--illegal-native-access=warn` in JDK 24+.

If your app uses `System.loadLibrary`, native methods, or FFM API:
- Add `--enable-native-access=ALL-UNNAMED` to JVM args
- Run with `--illegal-native-access=deny` to identify all sites
- Use `jnativescan` tool to identify JNI-using libraries

## 2.16 Dynamic agent loading

Warnings continue from JEP 451 (JDK 21). If using `-XX:+EnableDynamicAgentLoading`, check if still needed after dependency updates.

## 2.17 String Templates withdrawn (JDK 23)

Feature removed entirely. Replace `STR."..."`, `FMT."..."`, `RAW."..."` with `String.format()` or concatenation.

## 2.18 Dependency compatibility

| Dependency | Min Version for JDK 25 | Notes |
|---|---|---|
| **Lombok** | ≥ 1.18.34 | Annotation processor; sensitive to javac changes |
| **Mockito** | ≥ 5.14 | Uses ByteBuddy for bytecode generation |
| **ByteBuddy** | ≥ 1.15 | Must support class file version 69.0 |
| **Jackson** | ≥ 2.18 | Reflection-based serialization |
| **ASM** | ≥ 9.7 | Class file format support |
| **Spring Boot** | 3.3+ / 4.x | 4.0.2 explicitly supports Java 25 |
| **Spring Framework** | 6.2+ / 7.x | Underlying framework |
| **Hibernate** | ≥ 6.6 | Bytecode enhancement |
| **MapStruct** | ≥ 1.6 | Annotation processor |
| **Gradle** | ≥ 8.10 | Build tool (use toolchains!) |
| **Maven** | ≥ 3.9.9 | Build tool |
| **maven-compiler-plugin** | ≥ 3.14.0 | Check for 25 compat patches |
| **Javassist** | ≥ 3.30 | Bytecode manipulation |

## 2.19 Security updates (JDK 22-25)

**JDK 25**: SHAKE128-256/256-512 digests, HKDF in SunPKCS11, TLS Keying Material Exporters, SHA-3 ECDSA in XML Security, enhanced jar validation, `java.security.debug` now includes thread/timestamp by default
**JDK 24**: Security properties file inclusion, quantum-resistant ML-KEM (JEP 496) + ML-DSA (JEP 497), configurable TLS session tickets
**JDK 23**: Thread/timestamp debug options, KeychainStore-ROOT

**Removed certificates**: Baltimore CyberTrust Root (JDK 25), two Camerfirma roots (JDK 25), SunPKCS11 PBE SecretKeyFactory implementations (JDK 25)

**Security migration checklist**:
1. Inventory custom `java.security` overrides and disabled algorithms lists
2. Inventory TLS settings (cipher suites, protocols, keystores)
3. Run integration tests that exercise real TLS handshakes to your endpoints
4. If using RMI over TLS, test with the new default endpoint identification (JDK 25.0.2)
5. If you have long-lived secrets or compliance pressure, evaluate post-quantum algorithms (ML-KEM, ML-DSA from JDK 24)

## 2.20 Compile and test

```bash
mvn clean compile
mvn test
```

All existing tests must pass. Fix remaining issues before proceeding.

**Cross-reference the MASTER CHECKLIST** — verify all blocking items are addressed.

---

# PHASE 3 — LANGUAGE FEATURE MODERNIZATION

Apply **only finalized features** (no `--enable-preview`). Apply only where the change **improves readability or correctness**. Do NOT force features where they don't fit. Preserve behavior.

## 3.1 Unnamed Variables & Patterns — JEP 456 (JDK 22)

Replace unused variables with `_`:

```java
// catch blocks where exception is unused
try { ... } catch (IOException _) { return fallback; }

// enhanced for-loops with unused loop variable
for (var _ : collection) { count++; }

// lambda parameters
map.forEach((_, value) -> process(value));

// switch pattern cases
case Point(var x, _) -> useOnly(x);
```

**Detection**: `grep -rn "catch\s*(" --include="*.java"` — check if caught variable is used in the block.

## 3.2 Markdown Documentation Comments — JEP 467 (JDK 23)

Convert `/** */` to `///` markdown comments:

```java
/// Processes the input and returns the result.
///
/// @param input the input value
/// @return the processed result
/// @throws IllegalArgumentException if input is null
```

Apply to: small interfaces, enums, records, exception classes. Do NOT mass-convert large legacy Javadoc with complex HTML.

## 3.3 Exhaustive switch expressions

Convert old-style `switch` and `if-else` chains to arrow-form exhaustive switch expressions over enums and sealed types:

```java
return switch (status) {
    case ACTIVE   -> handle();
    case INACTIVE -> skip();
};  // exhaustive over enum, no default needed
```

## 3.4 Stream Gatherers — JEP 485 (JDK 24)

Use `stream.gather(...)` for custom intermediate operations:

```java
stream.gather(Gatherers.windowFixed(3))
stream.gather(Gatherers.windowSliding(5))
stream.gather(Gatherers.fold(() -> init, (state, elem) -> combine))
stream.gather(Gatherers.scan(() -> init, (state, elem) -> combine))
stream.gather(Gatherers.mapConcurrent(maxConcurrency, function))
```

Only use where it genuinely simplifies code — don't force for simple map/filter/reduce.

## 3.5 Module Import Declarations — JEP 511 (JDK 25)

```java
import module java.base;   // java.util.*, java.io.*, java.time.*, etc.
import module java.sql;     // java.sql.*, javax.sql.*
```

Consider for test classes. Do NOT replace explicit imports in production classes.

## 3.6 Flexible Constructor Bodies — JEP 513 (JDK 25)

Statements before `super(...)`/`this(...)`:

```java
// Validate/transform inline instead of static helper
public RangeFilter(int min, int max) {
    if (min > max) throw new IllegalArgumentException("min > max");
    super(min, max);  // statements allowed before super()
}
```

**Fields can be initialized before `super()`** — makes class more reliable when methods are overridden.

## 3.7 Scoped Values — JEP 506 (JDK 25)

Replace `ThreadLocal` set/try/finally/remove patterns:

```java
// BEFORE
private static final ThreadLocal<RequestContext> CTX = new ThreadLocal<>();
CTX.set(context);
try { doWork(); } finally { CTX.remove(); }

// AFTER
private static final ScopedValue<RequestContext> CTX = ScopedValue.newInstance();
ScopedValue.where(CTX, context).run(() -> doWork());
```

Use when: immutable per-request data, virtual threads, structured scope. Do NOT convert `ThreadLocal` that mutates within scope.

## 3.8 Compact Source Files — JEP 512 (JDK 25)

Instance `main` methods, implicit class declaration. The `IO` class now in `java.lang` requires explicit `IO.println()`.

**Skip for production code.** Useful only for scripts, demos, CLI tools.

## 3.9 API modernization

- `String.repeat()` instead of StringBuilder loops
- `Math.ceilDiv()` instead of manual ceiling division
- `SequencedCollection`: `getFirst()`, `getLast()`, `reversed()`
- `Inflater`/`Deflater` now `AutoCloseable` — use in try-with-resources
- `ForkJoinPool.submitWithTimeout()` for timeout-based task cancellation

## 3.10 Preview features (only if explicitly requested)

**Rule of thumb**: Use preview features only in leaf modules or internal tooling at first. Always compile and run with preview flags consistently across IDE, build, and CI.

- **Primitive Types in Patterns (JEP 507)**: extends instanceof/switch to all primitive types
- **Stable Values (JEP 502)**: "initialize later but optimize like final" — great for startup patterns
- **Structured Concurrency (JEP 505)**: extremely useful, still preview — adopt behind clear module boundaries
- **PEM Encodings (JEP 470)**: standard API for PEM encode/decode of crypto objects

## 3.11 Compile and test

```bash
mvn clean compile
mvn test
```

If any test fails after modernization, revert that specific change — modernization must NOT change behavior.

---

# PHASE 4 — AOT CACHE ADOPTION (optional)

The AOT cache (Project Leyden) speeds startup and warmup. JEP 483 (JDK 24) → JEP 514 (JDK 25) → JEP 515 (JDK 25).

## 4.1 When it's worth it

**Use if**: You care about cold start and warmup (serverless, autoscaling, CLI tools, "first request latency"). You redeploy often enough that startup time is a real cost.

**Skip if**: You are dominated by network/DB/huge lazy initialization. Your app is tiny and already starts instantly.

## 4.2 Adoption model

1. **Measure baseline**: time-to-first-request and time-to-steady-state throughput
2. **Turn on AOT cache in staging**: validate functional equivalence
3. **Roll to one service** with the most painful startup
4. **Keep a kill switch** (deploy without caches) until you trust it

JDK 25 simplifies this with `--aot` ergonomics (JEP 514) and method profiling reuse (JEP 515).

---

# PHASE 5 — PERFORMANCE VALIDATION

## 5.1 Before/after comparison model

Capture with **same workload, same heap sizing, same container limits**:

| Metric | Before (JDK 21) | After (JDK 25) |
|--------|-----------------|-----------------|
| P50 latency | | |
| P99 latency | | |
| Allocation rate | | |
| GC pause distribution | | |
| CPU utilization | | |
| Startup time | | |
| Memory footprint | | |

Use **JFR on both sides** — JDK 25's JFR improvements (JEP 518 cooperative sampling, JEP 520 method timing, JEP 509 CPU-time profiling on Linux) make profiling cheaper and more accurate.

## 5.2 GC considerations

- ZGC is now generational-only (non-generational removed in JDK 24). If you were using `-XX:+UseZGC` without `-XX:+ZGenerational`, the flag is no longer needed (generational is the default and only mode).
- Generational Shenandoah available in JDK 25.
- G1 has improvements: Region Pinning (22), Late Barrier Expansion (24), grouped card sets (25).
- Compact Object Headers (JEP 519) reduce heap footprint — enable with `-XX:+UseCompactObjectHeaders` (now a product option, no experimental unlock needed).

## 5.3 Virtual threads

JDK 24 (JEP 491) eliminates pinning on `synchronized`. Measure virtual thread scalability — it should be significantly better than JDK 21.

---

# PHASE 6 — VERIFICATION & SUMMARY

## 6.1 Full clean build

```bash
mvn clean verify    # Maven (compile + test + integration + package)
```

## 6.2 Static analysis

```bash
jdeprscan --release 25 -l --for-removal target/*.jar 2>/dev/null
jdeps -jdkinternals target/classes 2>/dev/null
```

## 6.3 Review warnings

- **Deprecation warnings**: Note new `@Deprecated(forRemoval=true)` from JDK 25
- **`sun.misc.Unsafe` warnings**: Expected from Maven/Guice/Spring — framework responsibility
- **Native access warnings**: Note if `--enable-native-access` needed
- **Annotation processing**: Ensure processors run correctly

## 6.4 Produce summary

Report must include:

1. **Files changed** — every modified file with one-line description
2. **Build & infrastructure** — version bumps, Docker images, CI configs
3. **Breaking changes fixed** — what was found, how resolved
4. **Language features adopted** — which JEPs, where, why
5. **Dependencies updated** — version changes with reasons
6. **Test results** — total, passed, failed, skipped
7. **Performance comparison** — if measured
8. **Remaining warnings** — for future attention
9. **Manual action items** — anything requiring human review

**Cross-reference the MASTER CHECKLIST one final time** — verify every applicable item is addressed, noted, or explicitly marked as not-applicable.

---

# MIGRATION RUNBOOK (copy-paste for your repo)

### Step 1: Make CI build Java 25 artifacts
Install JDK 25 in CI. Keep builds reproducible via toolchains.

### Step 2: Make the build fail fast on preview drift (if using preview features)
One place to define preview flags. Same flags for tests and runtime.

### Step 3: Run "compat mode" test pass
Run the app under typical production JVM flags. Capture warnings and turn them into tickets.

### Step 4: Canary rollout
1 service, 1 region, low traffic. Compare latency and error rates. Capture JFR before and after.

### Step 5: Full rollout and cleanup
Delete old flags only needed for the upgrade window. If you moved off legacy mechanisms (Security Manager, 32-bit builds), document it so nobody tries to resurrect them.

---

# RULES

1. **Always compile and test** after Phase 1 before Phase 2. After Phase 2 before Phase 3.
2. **Never force a feature** where it hurts readability.
3. **Preserve behavior**: Modernization must not change runtime behavior. If a test fails, revert.
4. **Skip preview features** unless explicitly asked. No `--enable-preview`.
5. **Check dependency versions first** when compilation fails — it's usually the library.
6. **One phase at a time**: Complete each phase fully.
7. **Report blockers immediately**: Don't silently work around incompatible dependencies.
8. **Run jdeprscan and jdeps** as part of verification.
9. **Do not modify test assertions** to make tests pass (unless asserting locale-specific formatting that changed with CLDR).
10. **Document every change** in the final summary.
11. **Come back to the MASTER CHECKLIST** after every phase. Verify nothing was missed.
12. **Use preview features only in leaf modules or internal tooling first** if adopting them.

---

# REFERENCE LINKS

- [Road to 25 playlist (all 6 videos)](https://www.youtube.com/playlist?list=PLX8CzqL3ArzXJ2_0FIGleUisXuUm4AESE)
- [OpenJDK: JEPs since JDK 21](https://openjdk.org/projects/jdk/25/jeps-since-jdk-21) — canonical diff
- [Inside.java: How to Upgrade to Java 25](https://inside.java/2025/08/24/roadto25-upgrade/)
- [Inside.java: AOT Computation](https://inside.java/2025/08/28/roadto25-aot/)
- [Inside.java: Language Features](https://inside.java/2025/08/31/roadto25-java-language/)
- [Inside.java: Performance & Runtime](https://inside.java/2025/09/05/roadto25-performance/)
- [Inside.java: Security Changes](https://inside.java/2025/09/07/roadto25-security/)
- [Inside.java: API Additions](https://inside.java/2025/09/09/roadto25-api/)
- [nipafx: Upgrading From Java 21 To 25](https://nipafx.dev/road-to-25-upgrade/)
- [Oracle JDK 25 Migration Guide](https://docs.oracle.com/en/java/javase/25/migrate/getting-started.html)
- [Oracle JDK 25 Release Notes](https://www.oracle.com/java/technologies/javase/25-relnote-issues.html)
- [JDK 25.0.2 Release Notes](https://jdk.java.net/25/release-notes)
- [Spring Boot System Requirements](https://docs.spring.io/spring-boot/system-requirements.html)
- [Gradle Java 25 Support Issue](https://github.com/gradle/gradle/issues/35111)
- [Maven Compiler Plugin Java 25 Issue](https://github.com/apache/maven-compiler-plugin/issues/986)
