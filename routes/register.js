let express = require('express');
let router = express.Router();
let ctrlRegister = require('../modules/ctrl_register')

router.post('/api/register', function(req, res) {
    ctrlRegister.postRegister(req, (err, result) => {
        if (!err) {
          res.send(result);
        }
      });
});

module.exports = router;
