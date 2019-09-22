const express = require('express')
const app = express()
const port = 6868
const fs = require('fs')

app.use(express.json({ limit: '50mb' })) // for parsing application/json
app.use(express.urlencoded({ extended: true, limit: '50mb' })) // for parsing application/x-www-form-urlencoded

const basePath = 'I:/iphoneBackup/auto/';

app.get('/photo', (req, res) => {
    let existCount = 0;
    let existFileName = basePath + existCount + '.jpeg';
    while (fs.existsSync(existFileName)) {
        existCount = existCount + 1;
        existFileName = basePath + existCount + '.jpeg';
    }

    res.status(200).send(`${existCount}`);
})


app.post('/photo', (req, res) => {
    const { data, name } = req.body;

    const pathFileName = basePath + name + '.jpeg';

    fs.writeFile(pathFileName, Buffer.from(data, 'base64'), () => {
        res.send('ok');
    })
})

app.listen(port, () => console.log(`Backup photo app listening on port ${port}!`))