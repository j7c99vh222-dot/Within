#!/usr/bin/env python3
"""Generate small loopable ambient beds used by the native demo."""

from array import array
import math
from pathlib import Path
import random
import wave

RATE = 22_050
DURATION = 18
COUNT = RATE * DURATION
OUT = Path(__file__).resolve().parents[1] / "Within" / "Resources" / "Audio"


def clamp(value: float) -> int:
    return max(-32_767, min(32_767, int(value * 32_767)))


def save(name: str, samples: array) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(samples.tobytes())


def tone_432() -> array:
    result = array("h")
    for index in range(COUNT):
        time = index / RATE
        fade = min(1.0, time / 1.5, (DURATION - time) / 1.5)
        pulse = 0.82 + 0.18 * math.sin(2 * math.pi * time / 9)
        value = (
            0.045 * math.sin(2 * math.pi * 432 * time)
            + 0.016 * math.sin(2 * math.pi * 216 * time)
            + 0.008 * math.sin(2 * math.pi * 864 * time)
        ) * fade * pulse
        result.append(clamp(value))
    return result


def gentle_rain() -> array:
    random.seed(432)
    result = array("h")
    smooth = 0.0
    drop = 0.0
    for index in range(COUNT):
        noise = random.uniform(-1, 1)
        smooth = 0.65 * smooth + 0.35 * noise
        if random.random() < 0.00065:
            drop = random.uniform(0.15, 0.38)
        drop *= 0.991
        time = index / RATE
        shimmer = math.sin(2 * math.pi * (2100 + 120 * math.sin(time / 5)) * time)
        result.append(clamp(0.045 * smooth + drop * shimmer * 0.12))
    return result


def ocean_breath() -> array:
    random.seed(864)
    result = array("h")
    low = 0.0
    for index in range(COUNT):
        time = index / RATE
        low = 0.992 * low + 0.008 * random.uniform(-1, 1)
        swell = 0.12 + 0.88 * ((math.sin(2 * math.pi * time / 7.5 - 1.2) + 1) / 2) ** 2
        undertone = math.sin(2 * math.pi * 72 * time) * 0.008
        result.append(clamp(low * swell * 0.85 + undertone * swell))
    return result


def morning_birds() -> array:
    random.seed(1296)
    chirps = []
    cursor = 0.9
    while cursor < DURATION - 1:
        length = random.uniform(0.16, 0.42)
        chirps.append((cursor, length, random.uniform(1450, 2600), random.uniform(300, 900)))
        cursor += random.uniform(1.4, 2.8)

    result = array("h")
    forest = 0.0
    for index in range(COUNT):
        time = index / RATE
        forest = 0.985 * forest + 0.015 * random.uniform(-1, 1)
        value = forest * 0.035
        for start, length, base, sweep in chirps:
            local = time - start
            if 0 <= local <= length:
                envelope = math.sin(math.pi * local / length) ** 2
                frequency = base + sweep * local / length
                value += 0.10 * envelope * math.sin(2 * math.pi * frequency * local)
                value += 0.035 * envelope * math.sin(2 * math.pi * frequency * 1.51 * local)
        result.append(clamp(value))
    return result


def white_noise() -> array:
    random.seed(1728)
    result = array("h")
    for _ in range(COUNT):
        result.append(clamp(random.uniform(-0.055, 0.055)))
    return result


def brown_noise() -> array:
    random.seed(2160)
    result = array("h")
    low = 0.0
    for _ in range(COUNT):
        low = 0.997 * low + 0.003 * random.uniform(-1, 1)
        result.append(clamp(low * 1.8))
    return result


def soft_wind() -> array:
    random.seed(2592)
    result = array("h")
    low = 0.0
    for index in range(COUNT):
        time = index / RATE
        low = 0.994 * low + 0.006 * random.uniform(-1, 1)
        swell = 0.32 + 0.68 * ((math.sin(2 * math.pi * time / 8.5) + 1) / 2)
        result.append(clamp(low * swell * 0.85))
    return result


def forest_rain() -> array:
    random.seed(3024)
    result = array("h")
    rain = 0.0
    canopy = 0.0
    drop = 0.0
    for index in range(COUNT):
        time = index / RATE
        rain = 0.72 * rain + 0.28 * random.uniform(-1, 1)
        canopy = 0.996 * canopy + 0.004 * random.uniform(-1, 1)
        if random.random() < 0.00045:
            drop = random.uniform(0.10, 0.30)
        drop *= 0.989
        leaf = math.sin(2 * math.pi * (1500 + 180 * math.sin(time / 4)) * time)
        value = 0.038 * rain + 0.35 * canopy + 0.09 * drop * leaf
        result.append(clamp(value))
    return result


def night_crickets() -> array:
    random.seed(3456)
    result = array("h")
    forest = 0.0
    for index in range(COUNT):
        time = index / RATE
        forest = 0.992 * forest + 0.008 * random.uniform(-1, 1)
        pulse = max(0.0, math.sin(2 * math.pi * 6.8 * time)) ** 9
        chorus = 0.55 + 0.45 * math.sin(2 * math.pi * time / 5.4)
        chirp = math.sin(2 * math.pi * 3100 * time) * pulse * chorus
        result.append(clamp(0.025 * forest + 0.045 * chirp))
    return result


def classical_arpeggio() -> array:
    chords = (
        (261.63, 329.63, 392.00, 523.25),
        (220.00, 261.63, 329.63, 440.00),
        (174.61, 220.00, 261.63, 349.23),
        (196.00, 246.94, 293.66, 392.00),
        (261.63, 329.63, 392.00, 523.25),
        (196.00, 246.94, 329.63, 392.00),
    )
    step = 0.375
    result = array("h")
    for index in range(COUNT):
        time = index / RATE
        note_index = int(time / step)
        chord = chords[min(len(chords) - 1, int(time / 3.0))]
        frequency = chord[note_index % len(chord)]
        local = time - note_index * step
        envelope = math.exp(-5.2 * local)
        value = envelope * (
            0.052 * math.sin(2 * math.pi * frequency * local)
            + 0.018 * math.sin(2 * math.pi * frequency * 2 * local)
        )
        value += 0.008 * math.sin(2 * math.pi * chord[0] / 2 * time)
        result.append(clamp(value))
    return result


if __name__ == "__main__":
    save("tone-432.wav", tone_432())
    save("gentle-rain.wav", gentle_rain())
    save("ocean-breath.wav", ocean_breath())
    save("morning-birds.wav", morning_birds())
    save("classical-arpeggio.wav", classical_arpeggio())
    save("white-noise.wav", white_noise())
    save("brown-noise.wav", brown_noise())
    save("forest-rain.wav", forest_rain())
    save("night-crickets.wav", night_crickets())
    save("soft-wind.wav", soft_wind())
