let express = require('express');
let router = express.Router();
let ctrlLogin = require('../modules/ctrl_login')

router.post('/api/login', function(req, res, next) {
    ctrlLogin.postLogin(req, (err, result) => {
        if (!err) {
          res.send(result);
        }
      });
});

module.exports = router;
