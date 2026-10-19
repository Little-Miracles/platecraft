# Composes the calm background music for the PlateCraft demo video (~3 min).
# Pure synthesis, no samples: soft pad, piano-like arpeggio, bass, a gentle melody.
# Usage: python3 tool/compose_music.py out.wav
import sys
import numpy as np
from scipy.io import wavfile
from scipy.signal import fftconvolve

out = sys.argv[1]
SR = 44100
BPM = 72
BEAT = 60 / BPM
BAR = 4 * BEAT
BARS = 54                      # 54 bars × 3.33 s ≈ 180 s
LENGTH = BARS * BAR + 4        # room for the reverb tail
L = np.zeros(int(LENGTH * SR)); R = np.zeros_like(L)

def hz(m): return 440 * 2 ** ((m - 69) / 12)

def put(sig, start, pan=0.0):
    i = int(start * SR); j = min(i + len(sig), len(L)); sig = sig[:j - i]
    L[i:j] += sig * (1 - pan) / 2 ** 0.5 * 1.2
    R[i:j] += sig * (1 + pan) / 2 ** 0.5 * 1.2

def piano(m, dur, vel):
    """Additive piano-like tone: slightly stretched harmonics, each fading on its own."""
    t = np.arange(int((dur + 2.5) * SR)) / SR
    f = hz(m); s = np.zeros_like(t)
    for k in range(1, 9):
        fk = k * f * (1 + 0.0004 * k * k) ** 0.5
        if fk > 12000: break
        s += np.sin(2 * np.pi * fk * t) * np.exp(-t * (1.1 + 0.9 * k)) / k ** 1.6
    s *= np.minimum(1, t / 0.006)
    s *= np.where(t < dur, 1, np.exp(-(t - dur) * 3))   # key released
    return s * vel

def pad(m, dur, vel):
    """Three slightly detuned voices, slow swell in and out."""
    t = np.arange(int((dur + 1.6) * SR)) / SR
    f = hz(m); s = np.zeros_like(t)
    for cents in (-5, 0, 5):
        fc = f * 2 ** (cents / 1200)
        s += np.sin(2 * np.pi * fc * t) + 0.25 * np.sin(2 * np.pi * 2 * fc * t)
    env = np.minimum(1, t / 1.4) * np.where(t < dur, 1, np.exp(-(t - dur) * 2.2))
    return s * env * (1 + 0.06 * np.sin(2 * np.pi * 0.25 * t)) * vel / 3

def bass(m, dur, vel):
    t = np.arange(int((dur + 0.8) * SR)) / SR
    s = np.sin(2 * np.pi * hz(m) * t) + 0.2 * np.sin(2 * np.pi * 2 * hz(m) * t)
    env = np.minimum(1, t / 0.03) * np.exp(-t * 0.5) * np.where(t < dur, 1, np.exp(-(t - dur) * 5))
    return s * env * vel

# Chords as MIDI notes (pad voicing) plus the bass root.
CH = {
    'C':  ([60, 64, 67, 71], 36), 'Am': ([57, 60, 64, 67], 33),
    'F':  ([53, 57, 60, 64], 29), 'G':  ([55, 59, 62, 67], 31),
    'Em': ([55, 59, 64, 67], 28),
}
A = ['C', 'Am', 'F', 'G']
B = ['F', 'G', 'Em', 'Am']
PENTA = [72, 74, 76, 79, 81, 84]          # C major pentatonic, octave 5

rng = np.random.default_rng(7)
for bar in range(BARS):
    t0 = bar * BAR
    if bar < 4: section = 'intro'
    elif bar < 20: section = 'A'
    elif bar < 36: section = 'B'
    elif bar < 48: section = 'A2'
    else: section = 'outro'
    name = (B if section == 'B' else A)[bar % 4]
    notes, root = CH[name]

    for n in notes:
        put(pad(n, BAR, 0.05), t0)
    if section in ('A', 'B', 'A2'):
        put(bass(root, BAR * 0.9, 0.22), t0)
        arp = [notes[0] + 12, notes[1] + 12, notes[2] + 12, notes[3] + 12,
               notes[2] + 12, notes[1] + 12, notes[0] + 12, notes[1] + 12]
        soft = 0.6 if section == 'B' else 1.0
        for i, m in enumerate(arp):
            put(piano(m, BEAT / 2, 0.075 * soft * (1.15 if i % 4 == 0 else 1)),
                t0 + i * BEAT / 2, pan=0.35 if i % 2 else -0.35)
    if section in ('B', 'A2') and not (section == 'A2' and bar % 2):
        # a slow melody: a chord tone on beat 1, small steps after it
        chord_pcs = {n % 12 for n in notes}
        idx = [i for i, m in enumerate(PENTA) if m % 12 in chord_pcs] or [2]
        k = int(rng.choice(idx))
        rhythm = [2, 1, 1] if rng.random() < 0.5 else [3, 1]
        beat = 0
        for d in rhythm:
            put(piano(PENTA[k], d * BEAT, 0.16), t0 + beat * BEAT, pan=0.1)
            beat += d
            k = int(np.clip(k + rng.choice([-1, 1, 0]), 0, len(PENTA) - 1))
    if section == 'outro' and bar < BARS - 1:
        put(piano(notes[-1] + 12, BAR, 0.12), t0)

# Room: convolve with a soft decaying-noise impulse, a different one per ear.
def impulse(seed):
    t = np.arange(int(2.6 * SR)) / SR
    n = np.random.default_rng(seed).standard_normal(len(t)) * np.exp(-t / 0.55)
    n = np.convolve(n, np.ones(12) / 12, mode='same')   # darker
    return n / np.abs(n).sum() * 40
wetL = fftconvolve(L, impulse(1))[:len(L)]
wetR = fftconvolve(R, impulse(2))[:len(R)]
mix = np.stack([L + 0.35 * wetL, R + 0.35 * wetR], axis=1)

# Fade in 2 s, fade out over the last 8 s to silence, peak at -3 dBFS.
total = int((BARS * BAR + 2) * SR)
mix = mix[:total]
t = np.arange(total) / SR
fade = np.minimum(1, t / 2) * np.clip((t[-1] - t) / 8, 0, 1)
mix *= fade[:, None]
mix *= 10 ** (-3 / 20) / np.abs(mix).max()
wavfile.write(out, SR, (mix * 32767).astype(np.int16))
print(f'{out}: {total / SR:.1f} s')
