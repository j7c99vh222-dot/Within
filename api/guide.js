import OpenAI from "openai";

const DEFAULT_MODEL = "gpt-5.6-terra";
const MAX_MESSAGE_LENGTH = 2400;

const companionProfiles = {
  capy: {
    name: "Capy",
    voice:
      "Super friendly, soft, encouraging, and emotionally warm. Make the user feel welcomed and not judged. Use gentle reassurance and simple next steps."
  },
  oreo: {
    name: "Oreo",
    voice:
      "Curious, attentive, and gently investigative. Ask one thoughtful question when useful, notice patterns, and help the user explore what is really going on."
  },
  axel: {
    name: "Axel",
    voice:
      "Funny, playful, and light without making serious pain into a joke. Use tiny bits of humor to lower pressure, then land on practical support."
  },
  jagy: {
    name: "Jags",
    voice:
      "Calm, grounded, steady, and clear. Keep the tone composed, protective, and confident. Help the user slow down and choose the next right action."
  },
  jags: {
    name: "Jags",
    voice:
      "Calm, grounded, steady, and clear. Keep the tone composed, protective, and confident. Help the user slow down and choose the next right action."
  }
};

const focusLabels = {
  anxiety: "anxiety and nervous-system regulation",
  depression: "low mood, energy, and gentle reconnection",
  addiction: "cravings, recovery support, and relapse prevention",
  relationships: "relationships, repair, boundaries, and communication",
  growth: "personal growth, discipline, and meaning",
  health: "general wellness, sleep, movement, and nutrition"
};

const dangerTerms = [
  "kill myself",
  "suicide",
  "end my life",
  "hurt myself",
  "overdose now",
  "someone will hurt me",
  "i want to die",
  "i am going to die",
  "i might hurt someone"
];

const openai = process.env.OPENAI_API_KEY
  ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
  : null;

export default async function handler(req, res) {
  setCommonHeaders(res);

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  if (req.method !== "POST") {
    res.setHeader("Allow", "POST, OPTIONS");
    return res.status(405).json({ error: "method_not_allowed" });
  }

  if (!openai) {
    return res.status(500).json({ error: "missing_openai_api_key" });
  }

  let body;
  try {
    body = await readJsonBody(req);
  } catch {
    return res.status(400).json({ error: "invalid_json" });
  }

  const message = cleanText(body?.message, MAX_MESSAGE_LENGTH);
  const focus = cleanText(body?.focus, 60).toLowerCase();
  const companionKey = cleanText(body?.companion, 32).toLowerCase();

  if (!message) {
    return res.status(400).json({ error: "missing_message" });
  }

  const companion = companionProfiles[companionKey] ?? companionProfiles.capy;
  const focusLabel = focusLabels[focus] ?? "general wellness and reflection";

  if (containsImmediateDanger(message)) {
    return res.status(200).json({
      message:
        "Your immediate safety matters more than this chat. Call emergency services now if danger is present. In the U.S. or Canada, call or text 988. Move near another person and tell them clearly that you need immediate help."
    });
  }

  try {
    const response = await openai.responses.create({
      model: process.env.OPENAI_MODEL || DEFAULT_MODEL,
      instructions: buildInstructions(companion, focusLabel),
      input: buildInput(message, focusLabel, companion.name),
      max_output_tokens: 450,
      store: false
    });

    const reply = cleanText(response.output_text || extractOutputText(response), 4000);

    if (!reply) {
      throw new Error("empty_model_response");
    }

    return res.status(200).json({ message: reply });
  } catch (error) {
    console.error("guide_generation_failed", {
      status: error?.status,
      code: error?.code,
      message: error?.message
    });

    return res.status(502).json({ error: "guide_generation_failed" });
  }
}

function setCommonHeaders(res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

async function readJsonBody(req) {
  if (req.body && typeof req.body === "object" && !Buffer.isBuffer(req.body)) {
    return req.body;
  }

  if (typeof req.body === "string" || Buffer.isBuffer(req.body)) {
    return JSON.parse(req.body.toString("utf8"));
  }

  const chunks = [];
  for await (const chunk of req) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }

  if (chunks.length === 0) {
    return {};
  }

  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function cleanText(value, maxLength) {
  if (typeof value !== "string") {
    return "";
  }

  return value.replace(/\s+/g, " ").trim().slice(0, maxLength);
}

function containsImmediateDanger(text) {
  const normalized = text.toLowerCase();
  return dangerTerms.some((term) => normalized.includes(term));
}

function buildInstructions(companion, focusLabel) {
  return [
    "You are Within's in-app AI guide for a mental wellness iPhone app.",
    "You are supportive coaching, reflection, and emotional first-aid. You are not a therapist, doctor, emergency service, or replacement for professional care.",
    `The user's current focus is ${focusLabel}.`,
    `You are speaking as ${companion.name}. Voice: ${companion.voice}`,
    "Return only the guide message text. Do not return JSON, labels, headings, or markdown tables.",
    "Keep replies concise: usually 3 to 7 short sentences.",
    "Make the response feel personal to the user's message, then give one concrete next step they can do now.",
    "Ask at most one question, and only when it helps the user take the next step.",
    "Do not diagnose, prescribe medication, give meal plans for eating disorders, or give medical instructions beyond encouraging professional care.",
    "For panic, cravings, hopelessness, conflict, sleep, food, or stress, keep advice practical, non-shaming, and focused on safety, support, and the next small action.",
    "If the user mentions self-harm, suicide, overdose, immediate danger, abuse, or intent to hurt someone, prioritize emergency support and trusted human help immediately."
  ].join("\n");
}

function buildInput(message, focusLabel, companionName) {
  return [
    `Focus: ${focusLabel}`,
    `Companion: ${companionName}`,
    "User message:",
    message
  ].join("\n");
}

function extractOutputText(response) {
  const chunks = [];

  for (const item of response?.output ?? []) {
    for (const content of item?.content ?? []) {
      if (typeof content?.text === "string") {
        chunks.push(content.text);
      }
      if (typeof content?.output_text === "string") {
        chunks.push(content.output_text);
      }
    }
  }

  return chunks.join("\n").trim();
}
