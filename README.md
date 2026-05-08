# RepoGuard: Pre-Install Security Scanner

> RepoGuard is a lightweight bash script designed to audit third-party repositories before you run npm install or npm start.
> Script from ["Real-world malware analysis" by Ryan Oberholzer](https://medium.com/@ryan.oberholzer/i-was-sent-a-technical-assessment-it-was-malware-heres-the-full-story-30797665d940), this tool helps detect backdoors, obfuscated code, and credential-stealing patterns common in "technical assessment" scams.

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
    - [How to Use](#how-to-use)
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

Clone this repository or download the check-repo.sh file:

```Bash
git clone https://github.com/badj/repoguard.git
cd repoguard
chmod +x check-repo.sh
```

[_⇡ Return to the Table of Contents_](#table-of-contents)

### How to Use

Do not run this [script - check-repo.sh](check-repo.sh) inside the malicious repo's directory if you are unsure. Instead, move the script into the root of the project you want to inspect and run:

```Bash
./check-repo.sh
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
