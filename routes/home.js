let express = require('express');
let router = express.Router();
let ctrlHome = require("../modules/ctrl_home")

router.get('/api/homeList', function(req, res) {
  ctrlHome.getHomeList(req, res, (err, result) => {
    if (!err) {
      res.send(result);
    }
  });
});

module.exports = router;
