let express = require('express');
let router = express.Router();
let ctrlCreateReadRecord = require('../modules/ctrl_createReadRecord')

router.post('/api/createReadRecord', function(req, res) {
    ctrlCreateReadRecord.postCreateReadRecord(req, (err, result) => {
        if (!err) {
          res.send(result);
        }
      });
});

router.post('/api/uploadReadFile', function(req, res) {
    ctrlCreateReadRecord.uploadReadRecord(req, res, (err, result) => {
        if (!err) {
            res.send(result);
        }
    });
});

module.exports = router;
