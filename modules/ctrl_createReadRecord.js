const { ObjectId } = require('mongodb');
const mongoose = require('mongoose');
const mod_readRecord = require('../modules/model/mod_readRecord');
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

exports.uploadReadRecord = (req, res, callback) => {
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

exports.postCreateReadRecord = (req, callback) => {
    const _id = new ObjectId()
    const readRecordData = req.body
    const essayId = readRecordData['essayId'];
    const readRecordName = readRecordData['readRecordName'];
    const readRecordTime = readRecordData['readRecordTime'];
    const createDate = Date.now()
    const updateDate = Date.now()
    const createUser = readRecordData['createUser'];
    const updateUser = readRecordData['updateUser'];

    var readSchema = mongoose.model("read_record", mod_readRecord);
    readSchema.create({
        _id: _id,
        essay_id: essayId,
        read_record: readRecordName,
        record_time: readRecordTime,
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