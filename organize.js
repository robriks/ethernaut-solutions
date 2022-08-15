const fs = require('fs/promises')


// for loop that reads files with fs.readdir(), checks for endsWith('.txt)
const dirContent = await fs.readdir('./')

let txts = []
let subDirectories = []
let main = async (content) => {
    while (content.length) { // > 0
        let i = content.pop()
        if (i.endsWith('.txt')) {
            // populate txts array
            txts.push(i)
            // use fs.opendir() to match txts array to files?

            let sub = i.slice('.txt') // double check slice() removes from end of string            // fs.cp(i, i.subDirectory) // cp / copyfile? LOOK UP fs LIBRARY EQUIVALENT OF mv COMMAND
            subDirectories.push(sub)
        }

        while (subDirectories.length) { // > 0
            let j = subDirectories.pop()
            // use to match sub array items to directories and push txt files into them
            // let wd = fs.opendir(j)
            // let k = j+'.txt'
            // fs.cp('../k', wd)
        }
        // delete files in root directory after execution
        // fs.rm(txts)
    }
}

main(dirContent)
