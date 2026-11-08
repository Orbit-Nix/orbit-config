# Lunar Mail & hi@muvex.dev Setup Guide

This guide details the complete configuration for running `hi@muvex.dev` self-hosted on Lunar (`srv-c4030-nix`), with Material 3 Expressive webmail on Orion, native M3 Android mail on Nebula, and automatic dual-delivery to `musamurad@proton.me`.

---

## 1. Cloudflare DNS Records (muvex.dev)

Configure the following DNS records in the Cloudflare Dashboard for `muvex.dev`:

### Inbound (Cloudflare Email Routing)
| Type | Name | Content | Priority |
| :--- | :--- | :--- | :--- |
| `MX` | `@` | `route1.mx.cloudflare.net` | 13 |
| `MX` | `@` | `route2.mx.cloudflare.net` | 57 |
| `MX` | `@` | `route3.mx.cloudflare.net` | 91 |
| `TXT` | `@` | `v=spf1 include:_spf.mx.cloudflare.net include:resend.com ~all` | - |
| `TXT` | `_dmarc` | `v=DMARC1; p=quarantine; rua=mailto:musamurad@proton.me` | - |

### Outbound DKIM (from Resend)
When you add `muvex.dev` to your free Resend account ([resend.com](https://resend.com)):
- Add the 2 or 3 `TXT` / `CNAME` DKIM records provided by Resend into your Cloudflare DNS.

---

## 2. Cloudflare Email Worker (Dual-Delivery)

In the Cloudflare Dashboard, go to **Email Routing > Email Workers**, create a new Worker named `lunar-mail-router`, and deploy this script:

```javascript
export default {
  async email(message, env, ctx) {
    // 1. Forward copy directly to Proton
    await message.forward("musamurad@proton.me");

    // 2. Deliver to Lunar self-hosted mailbox via Cloudflare Tunnel
    try {
      const rawEmail = await new Response(message.raw).text();
      const webhookUrl = env.LUNAR_WEBHOOK_URL || "https://inbound-mail.muvex.dev";
      const webhookSecret = env.WEBHOOK_SECRET || "lunar-mail-secret-2026";

      const res = await fetch(webhookUrl, {
        method: "POST",
        headers: {
          "Content-Type": "message/rfc822",
          "X-Webhook-Secret": webhookSecret,
          "X-Mail-To": message.to,
          "X-Mail-From": message.from
        },
        body: rawEmail
      });

      if (!res.ok) {
        console.error(`Lunar delivery failed with status ${res.status}`);
      }
    } catch (err) {
      console.error("Error posting to Lunar webhook:", err);
    }
  }
};
```

### Route Rule:
In **Email Routing > Routing Rules**:
- **Custom Address:** `hi@muvex.dev`
- **Action:** Send to Worker -> `lunar-mail-router`

---

## 3. Cloudflare Tunnel Ingress

In the Cloudflare Zero Trust Dashboard under your Lunar tunnel:
- Add a Public Hostname:
  - **Subdomain:** `inbound-mail`
  - **Domain:** `muvex.dev`
  - **Service:** `HTTP` -> `host.docker.internal:8089` (or `100.100.5.5:8089`)

---

## 4. Lunar First-Run & Stalwart Outbound Relay

When the stack deploys on Lunar:

1. **Get Stalwart Bootstrap Password:**
   ```bash
   docker logs stalwart 2>&1 | grep -A8 'bootstrap mode'
   ```
2. Open `https://stalwart.lunar.srv` (or `http://100.100.5.5:8080/admin`).
3. Log in with `admin` and the temporary password.
4. Run the wizard:
   - **Hostname:** `mail.muvex.dev`
   - **Domain:** `muvex.dev`
   - **Account Directory:** Internal
5. Under **Management > Accounts**, create `hi@muvex.dev` and set your password under Authentication credentials.
6. Under **Settings > Outbound Routing**:
   - Add Relay: `smtp.resend.com`
   - Port: `587`
   - Auth: Username `resend`, Password: `<your_resend_api_key>`
   - Require TLS: Yes

---

## 5. Client Access

### Orion Web Dashboard:
- URL: `https://mail.lunar.srv` (or `http://100.100.5.5:8082`)
- Log in with `hi@muvex.dev`.
- SOGo will automatically load with the **Material 3 Expressive** theme (floating theme toggle, capsule navigation, dark mode).

### Nebula Android App:
- Install **3mail** (or MonoMail) from F-Droid / GitHub.
- Add Account (Manual IMAP/SMTP):
  - **Email:** `hi@muvex.dev`
  - **IMAP Server:** `100.100.5.5` (or `srv-c4030-nix`), Port: `993` (SSL/TLS)
  - **SMTP Server:** `100.100.5.5` (or `srv-c4030-nix`), Port: `587` (STARTTLS)
  - **Username:** `hi@muvex.dev`
  - **Password:** `<your_stalwart_password>`
