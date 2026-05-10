# AssignX Postman collection

## Files

| File | Description |
|------|-------------|
| `AssignX-API.generated.json` | Full API collection generated from [`api-server/openapi.yaml`](../api-server/openapi.yaml). Re-import when the OpenAPI spec changes. |

## Import

1. Open Postman → **Import** → select `AssignX-API.generated.json`.
2. In the collection **Variables** tab, set:
   - **`baseUrl`** — local: `http://localhost:4000/api` (default)
   - For production, copy the value from **`baseUrlProd`** (`https://api.assignx.com/api`) into **`baseUrl`**, or duplicate the collection and use different environments (recommended).
   - **`bearerToken`** — paste your JWT **access** token after `POST /auth/verify` or `POST /auth/login` (collection auth is Bearer token).

## Regenerate from OpenAPI

From the repo root (requires Node/npm):

```powershell
New-Item -ItemType Directory -Force -Path postman | Out-Null
cd api-server
npx --yes openapi-to-postmanv2 -s openapi.yaml -o ../postman/AssignX-API.generated.json -p
```

Then re-apply collection variables (`baseUrlProd`, `bearerToken`) if the converter overwrites them, or maintain a Postman **Environment** with `baseUrl` and `bearerToken` instead.

## Notes

- The API serves JSON; many routes require `Authorization: Bearer <accessToken>`.
- OTP flow: `POST /auth/send-otp` → `POST /auth/verify` (see **auth** folder in the collection).
- **Health** in OpenAPI may be documented under the API base path; the Express app also exposes `GET /health` at the server root (port 4000) without the `/api` prefix.
