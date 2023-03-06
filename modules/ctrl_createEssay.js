const { ObjectId } = require('mongodb');
const mongoose = require('mongoose');
const mod_essay = require('../modules/model/mod_essay');
var fs = require('fs');
var multer = require('multer');

var createFolder = function (folder) {
	try {
		fs.accessSync(folder);
	} catch (e) {
		fs.mkdirSync(folder);
	}
};

var uploadFolder = './upload/'; 
createFolder(uploadFolder);

var Storage = multer.diskStorage({
  destination: function(req, file, callback) {
    callback(null, './upload');
  },
  filename: function(req, file, callback) {
    callback(null, file.fieldname + file.originalname);
  }
});
var upload = multer({
  storage: Storage
}).single("record");

exports.uploadRecord = (req, res, callback) => {
    upload(req, res, function(err) {
        if (err) {
            console.log(err);
            let resultData = {
              data: {result: 'failure'}
          }
          callback(undefined, resultData);
        } else {
          console.log(req.file)
          let resultData = {
              data: {result: 'success', filePath: req.file.filename}
          }
          callback(undefined, resultData);
       } 
    });
}

exports.postCreateEssay = (req, callback) => {
    const _id = new ObjectId()
    const essayData = req.body
    const essayTitle = essayData['essayTitle'];
    const essayContent = essayData['essayContent'];
    const essayRecord = essayData['essayRecord'];
    const createDate = Date.now()
    const updateDate = Date.now()
    const createUser = essayData['createUser'];
    const updateUser = essayData['updateUser'];

    var essaySchema = mongoose.model("essay", mod_essay);
    essaySchema.create({
        _id: _id,
        essay_title: essayTitle,
        essay_content: essayContent,
        essay_record: essayRecord,
        create_date: createDate,
        update_date: updateDate,
        create_user: createUser,
        update_user: updateUser
    }, function(err) {
        if(!err){
            let resultData = {
                data: {result: 'success'}
            }
            callback(undefined, resultData);
        } else {
            let resultData = {
                data: {result: 'failure'}
            }
            callback(err, resultData);
        }
    })
}