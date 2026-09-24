# Chrome Web Store publication checklist

This project is ready to package, but the following items must be completed in the Chrome Web Store Developer Dashboard.

## Before packaging

- [ ] Revoke and rotate the API key currently stored in the local `text` file.
- [ ] Replace the support-contact placeholder in `PRIVACY.md` and `privacy.html`.
- [ ] Publish `privacy.html` (or the same policy) at a public HTTPS URL, such as GitHub Pages.
- [ ] Add that public privacy-policy URL to the store listing.
- [ ] Decide whether to support arbitrary OpenAI-compatible providers. The current optional `https://*/*` permission preserves that feature; narrow it to known provider hosts if possible.
- [ ] Check that the extension name is unique in the Chrome Web Store and does not imply an unrelated affiliation.

## Permissions justification

- `activeTab`: reads the current page only after the user invokes Lumen.
- `scripting`: extracts readable text from that active page.
- `storage`: saves settings, the user-provided API key, and privacy-consent status locally.
- Optional host access: requested only for the API origin selected by the user. The extension does not request permanent access to every website.

## Data disclosure

In the store questionnaire, disclose that the extension handles and transmits:

- current page title and URL;
- page description and readable page text (up to approximately 18,000 characters);
- the user-provided model name and system prompt;
- the user-provided API key to the selected API provider.

The extension has no analytics, advertising, or developer-operated proxy server. The selected API provider's own retention policy applies to the request it receives.

## Store assets

- [ ] 128×128 extension icon is present (`icons/icon128.png`).
- [ ] At least one clear screenshot of the main popup.
- [ ] At least one screenshot showing the settings/API configuration.
- [ ] Short description, detailed description, category, support email, and support/homepage URL.

## Package and test

From the project directory, run:

```powershell
.\package-extension.ps1
```

Upload `lumen-ai-page-summarizer.zip`. The script intentionally excludes `text`, `.env`, `README.md`, documentation files, and the previous ZIP so local secrets are not bundled.

Before submitting, test:

1. A normal `https://` page with a valid API endpoint.
2. A page with no readable text.
3. A restricted Chrome page.
4. An invalid API key and a non-JSON API error.
5. A `localhost` OpenAI-compatible server using `http://localhost`.
6. The first-use privacy consent and the endpoint permission prompt.
