import { readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const toolDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(toolDirectory, "../../..");
const sourcePath = resolve(toolDirectory, "../Within/Models/LearningContent.swift");
const outputPath = resolve(projectRoot, "app/content/learning-library.json");

const source = await readFile(sourcePath, "utf8");
const argument = '"((?:[^"\\\\]|\\\\.)*)"';
const lessonPattern = new RegExp(`lesson\\(${Array.from({ length: 7 }, () => argument).join(",\\s*")}\\)`, "g");
const focusByPrefix = {
  anx: "anxiety",
  dep: "depression",
  rec: "addiction",
  rel: "relationships",
  gro: "growth",
  hea: "health",
};
const library = Object.fromEntries(Object.values(focusByPrefix).map((focus) => [focus, []]));

for (const match of source.matchAll(lessonPattern)) {
  const values = match.slice(1).map((value) => JSON.parse(`"${value}"`));
  const [id, module, title, principle, practice, sourceLabel, sourceURL] = values;
  const focus = focusByPrefix[id.slice(0, 3)];
  if (!focus) throw new Error(`Unknown lesson prefix: ${id}`);
  library[focus].push({ id, module, title, principle, practice, sourceLabel, source: sourceURL });
}

const lessonCount = Object.values(library).reduce((total, lessons) => total + lessons.length, 0);
if (lessonCount !== 76) throw new Error(`Expected 76 lessons, found ${lessonCount}`);

await writeFile(outputPath, `${JSON.stringify(library, null, 2)}\n`, "utf8");
console.log(`Wrote ${lessonCount} web lessons to ${outputPath}`);
