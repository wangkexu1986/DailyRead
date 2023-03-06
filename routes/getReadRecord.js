let express = require('express');
let router = express.Router();
let ctrlReadRecord = require('../modules/ctrl_getReadRecord')

router.get('/api/getReadRecordList', function(req, res) {
    ctrlReadRecord.getReadRecordList(req, (err, result) => {
        if (!err) {
          res.send(result);
        }
      });
});

router.get('/api/downloadRecord', function(req, res) {
    ctrlReadRecord.downloadRecord(req, (err, result) => {
        if (!err) {
        //   res.send(result);
          res.download(result);
        }
      });
});

module.exports = router;
