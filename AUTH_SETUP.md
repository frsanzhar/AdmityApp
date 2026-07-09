# Auth setup — Google (Gmail) + Supabase

The client code is done. To turn on **real** sign-in you fill in `env.json` and
run with `--dart-define-from-file=env.json`. Until then the app runs in offline
guest mode (sign-in buttons just create a local profile).

- Bundle id: `kz.admity.app`
- Supabase project ref: `sgpbozuzttvyojffeqlk`
- `env.json` is **git-ignored** — safe to keep keys in it.

`env.json` already has your Supabase URL + publishable key. You only need to add
the two Google client IDs (steps below).

---

## A. Supabase — enable Email + Google  (5 min)

Dashboard → **Authentication → Providers**:

1. **Email** — make sure it's enabled. (For testing, turn *off* "Confirm email"
   under Authentication → Providers → Email so you can sign in instantly.)
2. **Google** — enable it. In **Authorized Client IDs** paste BOTH client IDs you
   create in step B (web + iOS), comma-separated. (The `signInWithIdToken` flow
   the app uses validates the token's audience against this list.)
3. Dashboard → **Authentication → URL Configuration** → add redirect URL
   `kz.admity.app://login-callback/` (used by the OAuth fallback path).

> Nothing else from Supabase is needed in `env.json` — URL + publishable key are
> already filled.

---

## B. Google Cloud Console — create OAuth clients  (10 min)

<https://console.cloud.google.com/apis/credentials>

1. Create / pick a project.
2. **OAuth consent screen** → External → fill app name + support email →
   add yourself under **Test users** (so it works before verification).
3. **Credentials → Create credentials → OAuth client ID**, make TWO:
   - **iOS** → Bundle ID = `kz.admity.app`.
     Copy its **Client ID** → `GOOGLE_IOS_CLIENT_ID`.
     Note its **reversed client ID** (`com.googleusercontent.apps.XXXX`).
   - **Web application** → copy its **Client ID** → `GOOGLE_WEB_CLIENT_ID`.
4. Put both client IDs into Supabase **Authorized Client IDs** (step A.2).

---

## C. iOS — add the Google callback URL scheme  (2 min)

Add the iOS client's **reversed client ID** as a URL scheme so Google can return
to the app. In `ios/Runner/Info.plist`, inside the top `<dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXXXX-YYYYYYYY</string>
    </array>
  </dict>
</array>
```

(Replace with your iOS reversed client ID. Tell me when you have it and I'll add
this for you.)

> Do **not** add the "Sign in with Apple" entitlement yet — a free signing team
> can't provision it and the install will be rejected (the same trap that broke
> installs earlier). Apple sign-in waits for your paid Developer account.

---

## D. Fill env.json + run

```jsonc
{
  "SUPABASE_URL": "https://sgpbozuzttvyojffeqlk.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_...",        // already set
  "GOOGLE_WEB_CLIENT_ID": "xxxx.apps.googleusercontent.com",  // ← from B
  "GOOGLE_IOS_CLIENT_ID": "yyyy.apps.googleusercontent.com"   // ← from B
}
```

Then build/run **with the env file** (the values are baked in at compile time):

```bash
flutter run --release --dart-define-from-file=env.json -d 00008110-001064981A51A01E
```

That's it — "Продолжить с Google" will do a real Google → Supabase sign-in.
