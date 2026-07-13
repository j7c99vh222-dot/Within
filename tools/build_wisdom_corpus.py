#!/usr/bin/env python3
"""Build a source-attributed daily wisdom corpus from public-domain texts."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re


@dataclass(frozen=True)
class Source:
    file_name: str
    work: str
    attribution: str
    source_url: str
    start_line: str
    end_line: str | None = None
    start_from_last: bool = False
    limit: int = 500


SOURCES = (
    Source(
        "meditations.txt",
        "Meditations",
        "Marcus Aurelius · George Long translation",
        "https://www.gutenberg.org/ebooks/2680",
        "THE FIRST BOOK",
        "NOTES",
        limit=700,
    ),
    Source(
        "enchiridion.txt",
        "The Enchiridion",
        "Epictetus · T. W. Higginson translation",
        "https://www.gutenberg.org/ebooks/45109",
        "THE ENCHIRIDION",
        limit=350,
    ),
    Source(
        "dhammapada.txt",
        "The Dhammapada",
        "The Dhammapada · F. Max Müller translation",
        "https://www.gutenberg.org/ebooks/2017",
        "DHAMMAPADA",
        limit=450,
    ),
    Source(
        "gita.txt",
        "The Song Celestial (Bhagavad Gita)",
        "The Bhagavad Gita · Sir Edwin Arnold translation",
        "https://www.gutenberg.org/ebooks/2388",
        "CHAPTER I",
        limit=500,
    ),
    Source(
        "tao.txt",
        "Tao Te Ching",
        "Laozi · James Legge translation",
        "https://www.gutenberg.org/ebooks/216",
        "PART 1.",
        limit=400,
    ),
    Source(
        "as-a-man-thinketh.txt",
        "As a Man Thinketh",
        "James Allen",
        "https://www.gutenberg.org/ebooks/4507",
        "THOUGHT AND CHARACTER",
        start_from_last=True,
        limit=400,
    ),
    Source(
        "walden.txt",
        "Walden",
        "Henry David Thoreau",
        "https://www.gutenberg.org/ebooks/205",
        "Economy",
        start_from_last=True,
        limit=700,
    ),
    Source(
        "republic.txt",
        "The Republic",
        "Plato · Benjamin Jowett translation",
        "https://www.gutenberg.org/ebooks/1497",
        "BOOK I.",
        start_from_last=True,
        limit=300,
    ),
    Source(
        "emerson-essays.txt",
        "Essays — First Series",
        "Ralph Waldo Emerson",
        "https://www.gutenberg.org/ebooks/2944",
        "HISTORY",
        start_from_last=True,
        limit=650,
    ),
    Source(
        "analects.txt",
        "The Analects",
        "Confucius · James Legge translation",
        "https://www.gutenberg.org/ebooks/3330",
        "BOOK I.  HSIO R.",
        limit=450,
    ),
)

PREFERRED_WORDS = {
    "action", "attention", "awake", "beauty", "begin", "calm", "care",
    "change", "character", "choice", "compassion", "courage", "desire",
    "duty", "effort", "fear", "free", "friend", "good", "habit", "hope",
    "justice", "kind", "knowledge", "learn", "life", "love", "mind",
    "nature", "peace", "purpose", "reason", "self", "soul", "strength",
    "thought", "truth", "virtue", "wake", "wisdom", "work",
}

REJECTED_PHRASES = (
    "project gutenberg", "ebook", "copyright", "translator", "transcriber",
    "footnote", "chapter ", "book i", "contents", "editor", "publisher",
    "http://", "https://", "bibliography", "printed in", "release date",
    "i omit", "he said", "i said", "he replied", "i replied", "she said",
    "said socrates", "my dear", "sanskrit here", "interpolated",
    "following pages", "mr davis",
)

UNSUITABLE_HOME_WORDS = {
    "anger", "angry", "battle", "blood", "coward", "dead", "death",
    "destroy", "destroyed", "destroys", "die", "dying", "enemy", "enemies",
    "evil", "failure", "hate", "hatred", "kill", "killed", "misery",
    "murder", "punishment", "reptile", "shame", "sin", "sins", "slain",
    "slay", "suicide", "torture", "warfare", "weapon", "weapons", "wicked",
    "worm", "worms",
}

UNSUITABLE_STARTS = (
    "and there", "as i did", "i do not know", "no doubt", "now to this",
    "very good", "well, then", "why,", "yes,",
)


def body_between_markers(text: str, source: Source) -> str:
    lines = text.replace("\r\n", "\n").splitlines()
    matches = [
        index for index, line in enumerate(lines)
        if line.strip() == source.start_line
    ]
    if not matches:
        raise ValueError(
            f"Missing start marker {source.start_line!r} in {source.file_name}"
        )
    start = matches[-1] if source.start_from_last else matches[0]
    end = len(lines)
    if source.end_line:
        endings = [
            index for index, line in enumerate(lines[start + 1 :], start + 1)
            if line.strip() == source.end_line
        ]
    else:
        endings = [
            index for index, line in enumerate(lines[start + 1 :], start + 1)
            if "*** END OF THE PROJECT GUTENBERG EBOOK" in line
        ]
    if endings:
        end = endings[0]
    return "\n".join(lines[start + 1 : end])


def normalize(value: str) -> str:
    value = re.sub(r"\[[^\]]{0,120}\]", " ", value)
    value = value.replace("_", "")
    value = re.sub(r"^(?:\d+\.|[IVXLCDM]+\.)\s+", "", value.strip())
    value = re.sub(r"\s+", " ", value).strip(" -—–*\t\n")
    return value


def split_candidates(body: str) -> list[str]:
    paragraphs = re.split(r"\n\s*\n", body)
    candidates: list[str] = []
    for paragraph in paragraphs:
        clean = normalize(paragraph)
        if not clean or (clean.upper() == clean and len(clean) < 100):
            continue
        if len(clean) <= 300:
            candidates.append(clean)
            continue
        sentences = re.split(
            r"(?<=[.!?])\s+(?=[\"“‘A-Z0-9])",
            clean,
        )
        for sentence in sentences:
            sentence = normalize(sentence)
            if 65 <= len(sentence) <= 300:
                candidates.append(sentence)
    return candidates


def acceptable(value: str) -> bool:
    lowered = value.lower()
    if not 65 <= len(value) <= 300:
        return False
    if any(phrase in lowered for phrase in REJECTED_PHRASES):
        return False
    if lowered.startswith(UNSUITABLE_STARTS):
        return False
    if value.endswith((":", ";", ",")):
        return False
    if "?" in value:
        return False
    if value.count("(") != value.count(")"):
        return False
    if value.count("[") != value.count("]"):
        return False
    letters = sum(character.isalpha() for character in value)
    if letters / max(1, len(value)) < 0.67:
        return False
    words = value.split()
    normalized_words = set(re.findall(r"[a-z]+", lowered))
    if normalized_words & UNSUITABLE_HOME_WORDS:
        return False
    if not normalized_words & PREFERRED_WORDS:
        return False
    return 11 <= len(words) <= 58


def score(value: str) -> tuple[int, int]:
    words = set(re.findall(r"[a-z]+", value.lower()))
    inspiration = len(words & PREFERRED_WORDS)
    readable_length = 4 if 90 <= len(value) <= 220 else 1
    declarative = 2 if "?" not in value else -2
    return inspiration * 3 + readable_length + declarative, -abs(len(value) - 155)


def build(raw_dir: Path) -> list[dict[str, object]]:
    entries: list[dict[str, object]] = []
    seen: set[str] = set()
    for source in SOURCES:
        text = (raw_dir / source.file_name).read_text(encoding="utf-8-sig")
        body = body_between_markers(text, source)
        candidates = (
            item for item in split_candidates(body) if acceptable(item)
        )
        ranked = sorted(candidates, key=score, reverse=True)
        kept = 0
        for item in ranked:
            identity = re.sub(r"[^a-z]", "", item.lower())
            if identity in seen:
                continue
            seen.add(identity)
            digest = hashlib.sha1(
                f"{source.work}:{item}".encode()
            ).hexdigest()[:12]
            quality_score = score(item)[0]
            dialogue = re.search(
                r"\b(said|replied|asked|spake)\b",
                item.lower(),
            )
            entries.append({
                "id": digest,
                "text": item,
                "attribution": source.attribution,
                "work": source.work,
                "sourceURL": source.source_url,
                "qualityScore": quality_score,
                "featured": quality_score >= 12 and dialogue is None,
            })
            kept += 1
            if kept >= source.limit:
                break
    entries.sort(
        key=lambda item: hashlib.sha1(item["id"].encode()).hexdigest()
    )
    if len(entries) < 2_000:
        raise ValueError(
            f"Only produced {len(entries)} passages; at least 2,000 are required"
        )
    featured_count = sum(bool(entry["featured"]) for entry in entries)
    if featured_count < 365:
        raise ValueError(
            f"Only produced {featured_count} featured passages; 365 are required"
        )
    return entries


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw_dir", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    entries = build(args.raw_dir)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(entries, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"Wrote {len(entries)} source-attributed passages to {args.output}"
    )


if __name__ == "__main__":
    main()
