# RSA Encryption Example — Explained

This is a worked example of RSA encryption using small numbers so the math stays manageable.

## Step 1: Bob Creates His Keys

Bob picks two prime numbers (numbers only divisible by 1 and themselves):

- p = 157
- q = 199

He multiplies them together to get **n = 31243**. This `n` is the foundation of both his public and private keys.

## Step 2: Bob Calculates the "Lock" and "Key" Numbers

Using a formula based on `p` and `q`, Bob calculates a number called **ϕ(n) = 30888**. This number is essentially scaffolding — it's only used to construct the public and private keys, but it's never shared.

From there, Bob picks two special numbers that are mathematically linked to each other through ϕ(n):

| Value | Role | Key |
|---|---|---|
| e = 163 | The "padlock" anyone can use to lock something | **Public key**: (31243, 163) |
| d = 379 | The "key to the padlock" only Bob keeps secret | **Private key**: (31243, 379) |

The special relationship between `e` and `d` is what makes RSA work: anything locked with `e` can only be unlocked with `d` — not with `e` itself or any other number.

## Step 3: Alice Encrypts a Message Using Bob's Public Key

Say Alice wants to send Bob the secret number **13**. She doesn't send it in plain sight — she locks it using Bob's public key:

```
y = x^e mod n
y = 13^163 mod 31243
y = 16341
```

She sends **16341** to Bob.

To anyone snooping, 16341 just looks like a random number — there's no obvious way to reverse it back to 13 without knowing the private key `d`.

## Step 4: Bob Decrypts Using His Private Key

Bob receives 16341 and uses his private key (`d = 379`) to unlock it:

```
x = y^d mod n
x = 16341^379 mod 31243
x = 13
```

Remarkably, this calculation produces 13 again — the original number Alice wanted to send.

## Why This Matters

Only Bob's private key (`d = 379`) can reverse what was locked with his public key (`e = 163`). Even though everyone can see Bob's public key and the locked message (16341), they can't reverse the math to recover 13 without knowing `d`.

This asymmetry — easy to lock, practically impossible to unlock without the right private key — is the entire foundation of RSA.

## One Important Caveat

In real life, `p` and `q` aren't small numbers like 157 and 199 — they're enormous, around **300 digits each**. The bigger these prime numbers are, the harder it becomes for an attacker to work backward and crack the private key, which is what keeps RSA secure in practice.
