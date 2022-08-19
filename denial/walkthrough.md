ideas:
-make malicious contract partner, set fallback function to always revert() ? Possibly stops execution before transfer
-set partner to 0 address? maybe rejects call
-write malicious contract partner that uses up enough gas on its receive() that line 31 can never execute ?