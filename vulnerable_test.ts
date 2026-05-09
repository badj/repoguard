/**
 * DANGEROUS PATTERN SAMPLE - repoguard test file to be detected by check-repo.sh
 * This file contains patterns that your grep command is designed to catch.
 */

// 1. Catches "eval\("
const dangerousEval = (input: string) => {
    eval(input); // Should be caught
};

// 2. Catches "exec\("
const child_process = require('child_process');
child_process.exec(command); // Should be caught

// 3. Catches "Function\("
const dynamicFunction = new Function('a', 'b', 'return a + b'); // Should be caught

// 4. Catches "process.env.(Wallet|Private|Key|Secret|EKEY)"
const config = {
    apiKey: process.env.PrivateKey,    // Should be caught
    walletId: process.env.WalletAddress, // Should be caught
    token: process.env.SecretToken,    // Should be caught
    encryption: process.env.EKEY_VALUE, // Should be caught
    path: process.env.NODE_ENV         // Should NOT be caught (not in your list)
};

console.log("Security audit test patterns loaded.");
