let express = require('express');
let router = express.Router();
let ctrlCreateEssay = require('../modules/ctrl_createEssay')

router.post('/api/createEssay', function(req, res) {
    ctrlCreateEssay.postCreateEssay(req, (err, result) => {
        if (!err) {
          res.send(result);
        }
      });
});

router.post('/api/uploadEssayFile', function(req, res) {
    ctrlCreateEssay.uploadRecord(req, res, (err, result) => {
        if (!err) {
            res.send(result);
        }
    });
});

module.exports = router;
