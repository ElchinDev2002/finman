# Finance Manager — Flutter client

Каркас мобильного клиента под твой Next.js backend (тот же `finance-manager`
проект, задеплоенный на AWS). Дизайн (цвета/шрифт/скругления) скопирован
из `src/app/globals.css` и `tailwind.config.ts`, структура экранов — из
`src/components/Sidebar.tsx`.

## Что уже готово
- `lib/app_theme.dart` — тёмная тема 1:1 с веб-версией (accent `#3fe0a5`, фон `rgb(11,14,20)` и т.д.)
- `lib/api/api_client.dart` — Dio-клиент с хранением JWT в Keychain/Keystore и авто-подстановкой `Authorization: Bearer`
- `lib/screens/login_screen.dart`, `register_screen.dart` — повторяют вёрстку `login/page.tsx`
- `lib/screens/shell_screen.dart` — Drawer со всеми разделами из Sidebar.tsx
- `lib/screens/dashboard_screen.dart` — реально дёргает `/api/dashboard` и печатает сырой ответ (замени на нормальную вёрстку, когда проверишь, что данные приходят)
- Остальные разделы (`transactions`, `budget`, ...) — заглушки `PlaceholderScreen`, их нужно доделать по аналогии с dashboard

## Шаг 1 — обязательная правка backend

Сейчас `/api/auth/login` и `/api/auth/register` кладут JWT только в
`httpOnly` cookie. Flutter-клиенту нужен токен в теле ответа. Правки
минимальные и вебу не мешают.

В `src/app/api/auth/login/route.ts`, замени:

```ts
const res = NextResponse.json({ id: user.id, name: user.name, email: user.email });
```

на:

```ts
const res = NextResponse.json({ id: user.id, name: user.name, email: user.email, token });
```

То же самое в `src/app/api/auth/register/route.ts` (добавь `token` в
JSON-ответ рядом с созданием пользователя).

Дальше пересобери и передеплой backend (`docker compose up -d --build`).

## Шаг 2 — HTTPS

`kApiBaseUrl` в `lib/api/api_client.dart` должен быть `https://...`.
Голый `http://3.80.51.211:3000` не пройдёт App Transport Security на iOS
и cleartext-политику на Android 9+ в релизной сборке.

Быстрый вариант: домен + Nginx + Let's Encrypt перед контейнером на том
же EC2 (порт 443 → проксирует на 127.0.0.1:3000).

**Если хочешь просто проверить на своём телефоне до того, как настроишь
HTTPS** — можно временно разрешить cleartext только для тестовой сборки:
- Android: в `android/app/src/main/AndroidManifest.xml` добавь в `<application>`
  `android:usesCleartextTraffic="true"` (убери перед TestFlight/Play-релизом).
- iOS в симуляторе/дебаге обычно достаточно `NSAllowsArbitraryLoads` в
  `Info.plist` для локальных тестов — тоже убери перед TestFlight.

## Шаг 3 — собрать проект локально

У меня в песочнице нет Flutter SDK и доступа к pub.dev, поэтому платформенные
папки (`android/`, `ios/`) я сгенерировать не могу — это можно сделать одной
командой у тебя:

```bash
# распакуй зип, зайди в папку
cd finance_manager_app

# сгенерирует android/, ios/, test/, .gitignore и т.д.,
# ничего из lib/ и pubspec.yaml не тронет
flutter create .

flutter pub get

# укажи свой домен в lib/api/api_client.dart (kApiBaseUrl), затем:
flutter run
```

## Шаг 4 — перед TestFlight

- Убери временные cleartext-разрешения из шага 2, если добавлял
- Проверь `ios/Runner/Info.plist`: `CFBundleDisplayName`, иконка приложения (замени дефолтную)
- `flutter build ipa` → загрузка через Xcode Organizer или Transporter
