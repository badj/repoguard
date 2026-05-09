# RepoGuard: Pre-Install Security Scanner

> RepoGuard is a lightweight bash script designed to audit third-party repositories before you run npm install or npm start.
> Script from ["Real-world malware analysis" by Ryan Oberholzer](https://medium.com/@ryan.oberholzer/i-was-sent-a-technical-assessment-it-was-malware-heres-the-full-story-30797665d940) / [_local copy of article_](Article/Real-world-malware-analysis-by-Ryan-Oberholzer.pdf). This tool helps detect backdoors, obfuscated code, and credential-stealing patterns common in "technical assessment" scams.

## Why to use this?

In modern supply-chain attacks, malware is often hidden in plain sight—stitched to the end of config files like tailwind.config.js or tucked into post-install scripts. This tool scans for:

- **Exfiltration:** Attempts to send data to unknown external URLs.
- **Credential Theft:** Accessing .ssh folders or process.env secrets.
- **Obfuscation:** Unusually long config files (100+ lines) containing hex/Base64 strings.
- **Remote Execution:** Use of eval(), exec(), or child_process.

---

## Table of contents

- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Project Structure](#project-structure)
    - [How to Use](#how-to-use)
    - [Output sample – no backdoors found](#output-sample--no-backdoors-found)
    - [Output sample – backdoors found](#output-sample--backdoors-found)
    - [What it Checks](#what-it-checks)
- [Safety Best Practices](#safety-best-practices)
- [Contributing](#contributing)
- [License](#license)

---

## Getting Started

### Prerequisites

1. A Unix-based environment (Linux, macOS, WSL).
2. grep and wc installed _(standard on most systems)_.

[_⇡ Return to the Table of Contents_](#table-of-contents)

### Installation

Clone this repository or download the check-repo.sh file and make the script executable:

```Bash
git clone https://github.com/badj/repoguard.git
cd repoguard
chmod +x check-repo.sh
```

[_⇡ Return to the Table of Contents_](#table-of-contents)

### Project Structure

```terminaloutput
repoguard
├── Article             // local copy of article
│ └── Real-world-malware-analysis-by-Ryan-Oberholzer.pdf
├── LICENSE
├── README.md
├── babel.config.js     // Test Sample File
├── backend             // Test Sample Folder 
│ └── package.json      // Test Sample File
├── check-repo.sh       // RepoGuard Bash Script
├── decoder-catch.js    // Test Sample File
├── package.json        // Test Sample File
├── postcss.config.js   // Test Sample File
├── tailwind.config.js  // Test Sample File
├── vulnerable_test.ts  // Test Sample File
└── webpack.config.js   // Test Sample File

3 directories, 12 files
```

[_⇡ Return to the Table of Contents_](#table-of-contents)

### How to Use

Move the [script - check-repo.sh](check-repo.sh) into the root of the project you want to inspect and run:

```Bash
./check-repo.sh
```

[_⇡ Return to the Table of Contents_](#table-of-contents)

### Output sample – no backdoors found

```terminaloutput
  jjbadenhorst:repoguard (main) % chmod +x check-repo.sh
  jjbadenhorst:repoguard (main) % ./check-repo.sh
  
  --- 1. Dangerous patterns (eval, exec, private keys) ---
    (none found)
  
  --- 2. Base64 / encoded strings ---
    (none found)
  
  --- 3. Config file lengths (obfuscation = very long) ---
    (none found)
  
  --- 4. Post install / preinstall scripts ---
    (none found)
  
  --- 5. Suspicious dependencies (0.0.0, 0.0.1) ---
    (none found)
  
  === DONE ===
  Review the output above. If you see:
    - Unknown external URLs (not Infura, Alchemy, your backend)
    - process.env.Wallet* or process.env.*Private* sent anywhere
    - Config files with 100+ lines (scroll to end and look for hex/obfuscation)
    - post install scripts from unknown packages
    -> DO NOT RUN npm install or npm start. Investigate further or run in Docker only!
```

### Output sample – backdoors found

> Refer to [Project Structure](#project-structure) for the test files used to generate this output. 
>
> Run `check-repo.sh` in this project to demo DANGEROUS PATTERNS found. 

```terminaloutput
  jjbadenhorst:repoguard (main) % ./check-repo.sh
  
  --- 1. Dangerous patterns (eval, exec, private keys) ---
  ./vulnerable_test.ts:8:    eval(input);
  ./vulnerable_test.ts:13:child_process.exec(command);
  ./vulnerable_test.ts:16:const dynamicFunction = new Function('a', 'b', 'return a + b');
  ./vulnerable_test.ts:20:    apiKey: process.env.PrivateKey,    // Should be caught
  ./vulnerable_test.ts:21:    walletId: process.env.WalletAddress, // Should be caught
  ./vulnerable_test.ts:22:    token: process.env.SecretToken,    // Should be caught
  ./vulnerable_test.ts:23:    encryption: process.env.EKEY_VALUE, // Should be caught
  
  --- 2. Base64 / encoded strings ---
  ./decoder-catch.js:8:        Buffer[at(0x66)](s1, r)[aw(0x68)+au(0x4c)](t)  // Buffer.from(s1, 'base64').toString('utf8')
  
  --- 3. Config file lengths (obfuscation = very long) ---
    tailwind.config.js:      126 lines
    ^ WARNING: Config > 100 lines - scroll to end and check for obfuscated code
    webpack.config.js:      126 lines
    ^ WARNING: Config > 100 lines - scroll to end and check for obfuscated code
    babel.config.js:      126 lines
    ^ WARNING: Config > 100 lines - scroll to end and check for obfuscated code
    postcss.config.js:      126 lines
    ^ WARNING: Config > 100 lines - scroll to end and check for obfuscated code
  
  --- 4. Post install / preinstall scripts ---
  package.json:    "postinstall": "npx fakeApp test 1",
  package.json:    "preinstall": "npx fakeApp test 2",
  package.json:    "prepare": "npx fakeApp test 3"
  backend/package.json:    "postinstall": "npx fakeApp test 1",
  backend/package.json:    "preinstall": "npx fakeApp test 2",
  backend/package.json:    "prepare": "npx fakeApp test 3"
  
  --- 5. Suspicious dependencies (0.0.0, 0.0.1) ---
  package.json:    "@catchMe/test4": "0.0.0",
  package.json:    "@catchMe/test5": "0.0.1",
  backend/package.json:    "@catchMe/test4": "0.0.0",
  backend/package.json:    "@catchMe/test5": "0.0.1",
  
  === DONE ===
  Review the output above. If you see:
    - Unknown external URLs (not Infura, Alchemy, your backend)
    - process.env.Wallet* or process.env.*Private* sent anywhere
    - Config files with 100+ lines (scroll to end and look for hex/obfuscation)
    - post install scripts from unknown packages
    -> DO NOT RUN npm install or npm start. Investigate further or run in Docker only!
```

[_⇡ Return to the Table of Contents_](#table-of-contents)

### What it Checks

1. **Dangerous Code:** Looks for eval, exec, and references to private keys.
2. **Encoding:** Detects Base64 or Buffer from calls used to hide malicious payloads.
3. **Config Integrity:** Flags configuration files (Tailwind, Webpack, etc.) that are suspiciously long.
4. **Lifecycle Hooks:** Scans package.json for pre-install or post-install scripts that run code automatically.
5. **Suspicious Dependencies:** Flags packages using placeholder versions like 0.0.0.

[_⇡ Return to the Table of Contents_](#table-of-contents)

## Safety Best Practices

- Never trust a "Technical Assessment" blindly. If a recruiter pressures you to run code immediately, be cautious.
- Use Docker. If you must run the code, run it in a container without mounting your home directory.
- Review the Output. This script is a helper, not a guarantee.
- If it flags a 500-line tailwind.config.js, open that file and scroll to the bottom!

[_⇡ Return to the Table of Contents_](#table-of-contents)

## Contributing

Found a new malware pattern? Please open an Issue or submit a Pull Request to update the grep patterns.

[_⇡ Return to the Table of Contents_](#table-of-contents)

## License

Distributed under the MIT License. See LICENSE for more information.
**Disclaimer:** This tool is for educational and auditing purposes. It cannot detect 100% of all threats. Always use your best judgment when running untrusted code.

[_⇡ Return to the Table of Contents_](#table-of-contents)
