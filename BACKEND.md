# Within Guide Backend

This repo includes a Vercel API route for the app's AI guide:

```text
POST /api/guide
```

Request body:

```json
{
  "message": "I feel anxious tonight",
  "focus": "anxiety",
  "companion": "capy"
}
```

Response body:

```json
{
  "message": "Capy-style guide response..."
}
```

## Environment Variables

Set these in Vercel. Do not put the OpenAI key in the iOS app.

```text
OPENAI_API_KEY=sk-proj_...
OPENAI_MODEL=gpt-5.6-terra
```

`OPENAI_MODEL` is optional. If it is missing, the backend uses `gpt-5.6-terra`.

## Local Run

```sh
npm install
cp .env.example .env
npm run dev
```

Then test:

```sh
curl -X POST http://localhost:3000/api/guide \
  -H "Content-Type: application/json" \
  -d '{"message":"I feel anxious","focus":"anxiety","companion":"capy"}'
```

## Deploy to Vercel

1. Push this repo to GitHub.
2. Import it in Vercel as a project.
3. Add `OPENAI_API_KEY` in Project Settings > Environment Variables.
4. Optionally add `OPENAI_MODEL` with `gpt-5.6-terra`.
5. Deploy.

After deployment, put the Vercel origin in the app's `WITHIN_API_BASE_URL` value:

```text
https://your-vercel-project.vercel.app/
```

Do not include `/api/guide` in `WITHIN_API_BASE_URL`; the iOS app already appends that path.
