const express = require('express')
const app = express()
const port = 6868
const fs = require('fs')

app.use(express.json({ limit: '50mb' })) // for parsing application/json
app.use(express.urlencoded({ extended: true, limit: '50mb' })) // for parsing application/x-www-form-urlencoded

app.post('/photo', (req, res) => {
    const { data, name } = req.body;

    fs.writeFile('I:/iphoneBackup/auto/' + name + '.jpeg', Buffer.from(data, 'base64'), () => {
        res.send('ok');
    })

})

app.listen(port, () => console.log(`Example app listening on port ${port}!`))