goal: change proxy pointer to implementation by becoming admin
function to do so: proposeNewAdmin() -> approveNewAdmin()

function to become owner: init()
-needs maxBalance == 0

function to set maxBalance = 0: setMaxBalance()
-needs address(this).balance == 0 and onlyWhitelisted

function to become whitelisted: addToWhitelist()
-needs owner

