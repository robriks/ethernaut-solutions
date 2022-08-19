const fs = require('fs/promises')

// while loop that reads files with fs.readdir(), checks for endsWith('.txt), copies files to subdirs and then cleans up
let main = async () => {
    const dirContent = await fs.readdir('./')
    
    while (dirContent.length) { // > 0
        let i = dirContent.pop()
        if (i.endsWith('.txt')) {
            let sub = i.replace('.txt', '')
            fs.cp('./' + i, './' + sub + '/' + i)
            fs.rm('./' + i)
        }
    }
}

main()
