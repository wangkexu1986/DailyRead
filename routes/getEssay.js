let express = require('express');
let router = express.Router();
let ctrlGetEssay = require('../modules/ctrl_getEssay')

router.get('/api/getEssay', function(req, res) {
    ctrlGetEssay.getEssay(req, (err, result) => {
        if (!err) {
          res.send(result);
        }
      });
});

router.get('/api/downloadRecord', function(req, res) {
    ctrlGetEssay.downloadRecord(req, (err, result) => {
        if (!err) {
        //   res.send(result);
          res.download(result);
        }
      });
});

module.exports = router;
