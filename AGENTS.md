# Codex Repo Rules

This repository uses `.windsurfrules` as a source of truth for engineering style. When working in this repo, Codex must follow the rules below in addition to its built-in system instructions.

## Source Of Truth

- Read and follow `D:\code\flutter-template\.windsurfrules`.
- If this file and `.windsurfrules` overlap, treat them as consistent restatements of the same policy.
- If a rule here is less detailed than `.windsurfrules`, prefer the more specific requirement from `.windsurfrules`.

## Required Working Style

- Use Vue/TypeScript-like layering when writing Flutter/Dart code: clear module boundaries, explicit types, centralized singletons, thin API wrappers, immutable state, semantic naming.
- Keep initialization, side effects, business logic, and UI composition separated.
- Prefer strong typed model classes over long-lived `dynamic` or raw `Map<String, dynamic>` in business code.
- Do not keep placeholder or demo naming such as `path1`, `testPage`, `data1`.

## Network Layer

- Do not create `Dio()` or `DioClient()` inside pages, widgets, or business API files.
- Reuse the centralized request infrastructure from `lib/utils/request.dart`.
- API files should declare business requests only. Interceptors, token injection, refresh token logic, cookie handling, and request logging belong in the shared client layer.
- If a new backend domain is needed, add its shared client in the request infrastructure layer instead of instantiating ad hoc clients inside feature files.

## API Layer

- Put new API code under `lib/api/**`.
- API methods must have explicit return types.
- API methods should map responses into model classes before returning.
- Do not pass raw `response.data` through to the UI layer for feature code.

## Models And Types

- Put new business models under `lib/model/**`.
- Business entities should use typed classes with semantic field names.
- `fromJson` and `toJson` belong on the model type.
- Do not use TypeScript-style `IUserInfo` naming in Dart.

## State Management

- Store state should be immutable and strongly typed.
- Prefer `copyWith`-style updates for state transitions.
- Reducers and actions should stay explicitly typed.

## Widget And Page Boundaries

- Widgets should primarily handle UI composition.
- App startup initialization belongs in `main.dart` or `bootstrap.dart`.
- Pages belong in `lib/pages/**`.
- Reusable UI belongs in `lib/components/**`.
- Do not perform request client, router, or store initialization inside page widgets.

## UI Data Rules

- In `lib/pages/**`, do not use `json['xx']` or `response.data['xx']` for direct rendering.
- Page widgets should consume typed models or page-specific view models only.
- Keep `build()` pure: no network requests, no dispatch side effects, no storage reads or writes in `build()`.

## Side Effects

- Allowed places for side effects: `initState`, `didChangeDependencies`, user interaction callbacks, or dedicated controller/service abstractions already used by the repo.
- Do not trigger business side effects during render.

## Singletons And Dependency Creation

- Only create router and store singletons in `main.dart` or `bootstrap.dart`.
- Only create request clients and similar infrastructure singletons in infrastructure files such as `lib/utils/request.dart`.
- Feature pages and components must not instantiate `FluroRouter`, `Store`, `Dio`, or `DioClient` directly.

## Import Boundaries

- `lib/model/**` must not import `lib/api/**`, `lib/pages/**`, or `lib/store/**`.
- `lib/api/**` must not import `lib/pages/**`.
- `lib/components/**` must not import concrete business pages.
- Avoid page-to-page mesh dependencies.

## Naming And Config

- Classes use `UpperCamelCase`.
- Variables, fields, and methods use `lowerCamelCase`.
- Route names, API method names, and model names must reflect business meaning.
- Config classes should use Dart naming such as `AppConfig`.
- Prefer `--dart-define` for environment configuration.

## Error Handling

- Do not use `print` for business logging.
- Preserve useful error context in catches.
- Shared network error handling should live in the request infrastructure.
- UI handles only user-visible feedback and local recovery actions.

## Directory Conventions

- `lib/utils/`: infrastructure helpers.
- `lib/api/`: API declaration layer.
- `lib/model/`: typed business models.
- `lib/store/`: global state.
- `lib/pages/`: route entry pages.
- `lib/components/`: reusable UI components.
- `lib/router/`: routing.
- `lib/constants/`: constants and enum-like keys.

## Cross Platform Checks

- For each new feature involving networking, media, files, cache, permissions, WebView, or plugins, check whether Android, iOS, Web, and Windows need extra configuration.
- Do not assume single-platform validation is enough.
- Network-related changes must consider Android internet and cleartext rules, iOS ATS, Web CORS and mixed content, and Windows proxy or certificate behavior.
- Media-related changes must verify platform support matrix, HTTPS and Range requirements, format support, and actionable failure logging.
- If a plugin does not support all target platforms, provide a fallback or block feature entry on unsupported platforms.

## Change Process

- When adding a new API: add API code first, then model, then page consumption.
- When adding a new response shape: define the model before wiring UI.
- If repeated client creation, repeated base URLs, or repeated token handling are found, refactor toward the shared infrastructure layer.
- If Dart best practice differs from a Vue/TypeScript analogy, choose the Dart-idiomatic implementation but explain it using Vue/TypeScript framing when useful.
