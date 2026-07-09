# Hosting the Privacy Policy — Quick Instructions

1. **GitHub Pages via repo** (fastest): Push `PRIVACY_POLICY.md` to your public GitHub repo (`github.com/frsanzhar/admity-flutter`), then enable Pages under Settings → Pages → branch `main`, folder `/`. Your URL becomes `https://frsanzhar.github.io/admity-flutter/PRIVACY_POLICY`. GitHub renders `.md` at that URL; alternatively rename the file `privacy-policy.html` or add a minimal `index.html` wrapper for a cleaner look.

2. **GitHub Gist** (quickest one-file option): Go to `gist.github.com`, paste the contents of `PRIVACY_POLICY.md`, save as public. Share the raw URL (`https://gist.githubusercontent.com/frsanzhar/…/raw/PRIVACY_POLICY.md`) — App Store Connect accepts raw text URLs.

3. **Notion** (polish, no code): Create a new Notion page, paste the policy, click "Share" → "Publish to web" → copy the public link. Works immediately.

4. **Vercel / Netlify drop** (for a custom domain): Drag-and-drop a folder containing `index.html` (wrap the markdown in basic HTML) to `vercel.com/new` or `app.netlify.com/drop`. Free tier, HTTPS included, deploys in under 60 seconds.

5. **Paste URL into App Store Connect**: In ASC → your app → App Information → scroll to "Privacy Policy URL" → paste the public link. The URL must be publicly reachable without a login — verify in a private/incognito browser window before submitting for review.
